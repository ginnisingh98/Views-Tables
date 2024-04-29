--------------------------------------------------------
--  DDL for Package Body PA_PROGRESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROGRESS_PVT" as
/* $Header: PAPCPVTB.pls 120.30.12010000.8 2009/06/27 01:08:38 asahoo ship $ */

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_PROGRESS_PVT';

g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',fnd_global.user_id,fnd_global.login_id,275,null,null), 'N');

-- Start of comments
--      API name        : ROLLUP_PROGRESS_PVT
--      Type            : Public
--      Pre-reqs        : For Program Rollup, the sub project buckets should be populated.
--      Purpose         : Rolls up the structure
--      Parameters Desc :
--              P_OBJECT_TYPE                   Possible values PA_ASSIGNMENTS, PA_DELIVERABLES, PA_TASKS
--              P_OBJECT_ID                     For assignments, pass resource_assignment_id, otherwise
--                                              proj_element_id of the deliverable and task
--              p_object_version_id             For Assignments, pass task_version_id, otherwise
--                                              element_version_id of the deliverable and task
--              p_task_version_id               For tasks, assignments, deliverables pass the task version id
--                                              , for struture pass null
--              p_lowest_level_task             Does not seem to be required
--              p_process_whole_tree            To indicate if whole tree rollup is not required. It will
--                                              do just 2 level rollup if N
--              p_structure_version_id          Structure version id of the publsihed or working structure version
--              p_structure_type                Possible values WORKPLAN, FINANCIAL
--              p_fin_rollup_method             Possible values are COST, EFFORT
--              p_wp_rollup_method              Possible values are COST, EFFORT, MANUAL, DURATION
--              p_rollup_entire_wbs             To indicate if it requires the whole structure rollup, in this
--                                              case it will ignore the passed object and starts with the lowest
--                                              task
--      History         : 17-MAR-04  amksingh   Rewritten For FPM Development Tracking Bug 3420093
-- End of comments

-- Bug 4218507  : Rewritten rollup code to use bulk approach and also merged update_rollup code in this
-- Bug 4317491  : Added check of WORKPLAN
-- 23-Jun-2009  rthumma   Bug 6854114 : Changes done for 8 digit precision  for physical percent complete.

PROCEDURE ROLLUP_PROGRESS_PVT(
 p_api_version                          IN      NUMBER          :=1.0
,p_init_msg_list                        IN      VARCHAR2        :=FND_API.G_TRUE
,p_commit                               IN      VARCHAR2        :=FND_API.G_FALSE
,p_validate_only                        IN      VARCHAR2        :=FND_API.G_TRUE
,p_validation_level                     IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
,p_calling_module                       IN      VARCHAR2        :='SELF_SERVICE'
,p_calling_mode                         IN      VARCHAR2        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_debug_mode                           IN      VARCHAR2        :='N'
,p_max_msg_count                        IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_progress_mode                        IN      VARCHAR2        := 'FUTURE'
,p_project_id                           IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_object_type                          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_object_id                            IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_object_version_id                    IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_task_version_id                      IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_as_of_date                           IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
,p_lowest_level_task                    IN      VARCHAR2        := 'N'
,p_process_whole_tree                   IN      VARCHAR2        := 'Y'
,p_structure_version_id                 IN      NUMBER
,p_structure_type                       IN      VARCHAR2        := 'WORKPLAN'
,p_fin_rollup_method                    IN      VARCHAR2        := 'COST'
,p_wp_rollup_method                     IN      VARCHAR2        := 'COST'
,p_rollup_entire_wbs                    IN      VARCHAR2        := 'N'
,p_task_version_id_tbl                  IN      SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type() -- Bug 4218507
,p_working_wp_prog_flag                 IN      VARCHAR2        := 'N'  --maansari7/18  to be passed form apply lp progress to  select regular  planned amounts to send to schduling api for    percent comnplete and earned    value calculations.
,p_upd_new_elem_ver_id_flag             IN      VARCHAR2        := 'Y'  -- rtarway, 3951024
,x_return_status                        OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count                            OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data                             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
 IS

l_api_name                      CONSTANT VARCHAR(30) := 'ROLLUP_PROGRESS_PVT';
l_api_version                   CONSTANT NUMBER         :=      1.0                     ;
l_return_status                 VARCHAR2(1)                                     ;
l_msg_count                     NUMBER                                          ;
l_msg_data                      VARCHAR2(250)                                   ;
l_data                          VARCHAR2(250)                                   ;
l_msg_index_out                 NUMBER                                          ;
l_error_msg_code                VARCHAR2(250)                                   ;
l_user_id                       NUMBER :=       FND_GLOBAL.USER_ID                      ;
l_login_id                      NUMBER :=       FND_GLOBAL.LOGIN_ID                     ;
l_lowest_task                   VARCHAR2(1)                                     ;
l_published_structure           VARCHAR2(1)                                     ;
l_task_version_id               NUMBER                                          ;
l_rollup_table1                 PA_SCHEDULE_OBJECTS_PVT.PA_SCHEDULE_OBJECTS_TBL_TYPE;
l_rollup_table2                 PA_SCHEDULE_OBJECTS_PVT.PA_SCHEDULE_OBJECTS_TBL_TYPE;
l_index                         NUMBER   := 0;
l_parent_count                  NUMBER   := 0;
l_process_number                NUMBER;
l_wbs_level                     NUMBER                                                                           ;
l_action_allowed                VARCHAR2(1)                                                                      ;
l_sharing_Enabled               VARCHAR2(1)                                                                      ;
l_split_workplan                VARCHAR2(1)                                                                      ;
l_structure_version_id          NUMBER                                                                           ;
g1_debug_mode                   VARCHAR2(1)                                                                      ;
l_Rollup_Method                 pa_proj_progress_attr.task_weight_basis_code%TYPE                                ;


   -- Rollup Cases
   -- 1. Workplan Publsihed Version Rollup.
   -- 2. Workplan Working Version Rollup.
   -- 3. Financial Structure Rollup.
   -- 4. Entire WBS using       structure       version id.
   -- 5. Program Rollup

   --This       cursor selects  the parents of  a given task.


CURSOR cur_reverse_tree_update IS
SELECT proj_element_id, object_id_to1, object_type
FROM
        ( select object_id_from1, object_id_to1
        from pa_object_relationships
        where relationship_type ='S'
        and object_type_from in ('PA_STRUCTURES','PA_TASKS') -- Bug 6429275
        and object_type_to = 'PA_TASKS'
        and p_rollup_entire_wbs='N'
        start with object_id_to1 = p_task_version_id
        and relationship_type = 'S'
        connect by prior object_id_from1 = object_id_to1
        and relationship_type =     'S'
        ) pobj
        , pa_proj_element_versions ppev
WHERE element_version_id = object_id_to1
and p_rollup_entire_wbs='N'
--select        structure
UNION
SELECT proj_element_id, element_version_id, object_type
FROM pa_proj_element_versions
WHERE element_version_id = p_structure_version_id
and project_id = p_project_id
and object_type = 'PA_STRUCTURES'
and p_rollup_entire_wbs='N'
UNION
SELECT proj_element_id, element_version_id, object_type
FROM pa_proj_element_versions
WHERE project_id = p_project_id
and parent_structure_version_id = p_structure_version_id
and object_type IN ('PA_TASKS','PA_STRUCTURES')
and p_rollup_entire_wbs='Y'
;


l_mass_rollup_prog_exists_tab       SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_mass_rollup_prog_rec_tab      SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();

l_tsk_object_id_from1_tab       SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_parent_object_type_tab        SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_tsk_object_id_to1_tab         SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_object_type_tab           SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_tsk_wbs_level_tab         SYSTEM.PA_NUM_TBL_TYPE      := SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_weighting_percent_tab     SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_roll_comp_percent_tab     SYSTEM.PA_NUM_TBL_TYPE      := SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_over_percent_comp_tab     SYSTEM.PA_NUM_TBL_TYPE      := SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_as_of_date_tab            SYSTEM.pa_date_tbl_type     := SYSTEM.pa_date_tbl_type();
l_tsk_actual_start_date_tab     SYSTEM.pa_date_tbl_type     := SYSTEM.pa_date_tbl_type();
l_tsk_actual_finish_date_tab            SYSTEM.pa_date_tbl_type     := SYSTEM.pa_date_tbl_type();
l_tsk_est_start_date_tab                SYSTEM.pa_date_tbl_type     := SYSTEM.pa_date_tbl_type();
l_tsk_est_finish_date_tab       SYSTEM.pa_date_tbl_type     :=   SYSTEM.pa_date_tbl_type();
l_tsk_rollup_weight1_tab                SYSTEM.PA_NUM_TBL_TYPE      := SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_override_weight2_tab      SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_base_weight3_tab          SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_task_weight4_tab          SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_status_code_tab           SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_tsk_object_id_tab         SYSTEM.PA_NUM_TBL_TYPE      := SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_proj_element_id_tab       SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_ppl_act_eff_tab           SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_ppl_act_cost_tc_tab       SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_ppl_act_cost_pc_tab       SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_ppl_act_cost_fc_tab       SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_ppl_act_rawcost_tc_tab        SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_ppl_act_rawcost_pc_tab        SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_ppl_act_rawcost_fc_tab        SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_est_rem_effort_tab                SYSTEM.PA_NUM_TBL_TYPE      := SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_ppl_etc_cost_tc_tab       SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_ppl_etc_cost_pc_tab       SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_ppl_etc_cost_fc_tab       SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_ppl_etc_rawcost_tc_tab        SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_ppl_etc_rawcost_pc_tab        SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_ppl_etc_rawcost_fc_tab        SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_eqpmt_act_effort_tab      SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_eqpmt_act_cost_tc_tab     SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_eqpmt_act_cost_pc_tab     SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_eqpmt_act_cost_fc_tab     SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_eqpmt_act_rawcost_tc_tab          SYSTEM.PA_NUM_TBL_TYPE      := SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_eqpmt_act_rawcost_pc_tab          SYSTEM.PA_NUM_TBL_TYPE      := SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_eqpmt_act_rawcost_fc_tab          SYSTEM.PA_NUM_TBL_TYPE      := SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_eqpmt_etc_effort_tab      SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_eqpmt_etc_cost_tc_tab     SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_eqpmt_etc_cost_pc_tab     SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_eqpmt_etc_cost_fc_tab     SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_eqpmt_etc_rawcost_tc_tab          SYSTEM.PA_NUM_TBL_TYPE      := SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_eqpmt_etc_rawcost_pc_tab          SYSTEM.PA_NUM_TBL_TYPE      := SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_eqpmt_etc_rawcost_fc_tab          SYSTEM.PA_NUM_TBL_TYPE      := SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_oth_quantity_tab          SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_oth_act_cost_tc_tab       SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_oth_act_cost_pc_tab       SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_oth_act_cost_fc_tab       SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_oth_act_rawcost_tc_tab        SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_oth_act_rawcost_pc_tab        SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_oth_act_rawcost_fc_tab        SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_oth_etc_quantity_tab      SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_oth_etc_cost_tc_tab       SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_oth_etc_cost_pc_tab       SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_oth_etc_cost_fc_tab       SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_oth_etc_rawcost_tc_tab        SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_oth_etc_rawcost_pc_tab        SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_oth_etc_rawcost_fc_tab        SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_current_flag_tab          SYSTEM.PA_VARCHAR2_1_TBL_TYPE   := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_tsk_pf_cost_rate_type_tab     SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_tsk_pf_cost_exc_rate_tab      SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_pf_cost_rate_date_tab     SYSTEM.pa_date_tbl_type     :=   SYSTEM.pa_date_tbl_type();
l_tsk_p_cost_rate_type_tab      SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_tsk_p_cost_exc_rate_tab       SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_p_cost_rate_date_tab      SYSTEM.pa_date_tbl_type     :=   SYSTEM.pa_date_tbl_type();
l_tsk_txn_currency_code_tab     SYSTEM.PA_VARCHAR2_15_TBL_TYPE  := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
l_tsk_prog_pa_period_name_tab       SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_tsk_prog_gl_period_name_tab       SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_tsk_bac_value_tab         SYSTEM.PA_NUM_TBL_TYPE      := SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_bac_self_value_tab        SYSTEM.PA_NUM_TBL_TYPE      := SYSTEM.PA_NUM_TBL_TYPE(); -- Bug 4493105
l_tsk_earned_value_tab          SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_deriv_method_tab          SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_tsk_progress_rollup_id_tab        SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_rollup_rec_ver_num_tab        SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_object_version_id_tab             SYSTEM.PA_NUM_TBL_TYPE      := SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_progress_stat_code_tab            SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_tsk_incremental_wq_tab                SYSTEM.PA_NUM_TBL_TYPE      := SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_cumulative_wq_tab                 SYSTEM.PA_NUM_TBL_TYPE      := SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_base_prog_stat_code_tab           SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_tsk_eff_roll_prg_st_code_tab          SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_tsk_percent_complete_id_tab           SYSTEM.PA_NUM_TBL_TYPE      := SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_task_wt_basis_code_tab            SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_tsk_base_percent_comp_tab     SYSTEM.PA_NUM_TBL_TYPE      :=   SYSTEM.PA_NUM_TBL_TYPE();
l_tsk_structure_version_id_tab          SYSTEM.PA_NUM_TBL_TYPE      := SYSTEM.PA_NUM_TBL_TYPE();

l_tsk_create_required                   SYSTEM.PA_VARCHAR2_1_TBL_TYPE   := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_tsk_update_required                   SYSTEM.PA_VARCHAR2_1_TBL_TYPE   := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();


l_prj_currency_code             VARCHAR2(15);
l_total_tasks                   NUMBER;
l_prog_pa_period_name           VARCHAR2(30);
l_prog_gl_period_name           VARCHAR2(30);
task_index                      NUMBER;
l_task_id                       NUMBER;
l_child_rollup_rec_exists       VARCHAR2(1);
l_sch_rec_ver_number            NUMBER;

l_equipment_hours               NUMBER;
l_pou_labor_brdn_cost           NUMBER;
l_prj_labor_brdn_cost           NUMBER;
l_pou_equip_brdn_cost           NUMBER;
l_prj_equip_brdn_cost           NUMBER;
l_pou_labor_raw_cost            NUMBER;
l_prj_labor_raw_cost            NUMBER;
l_pou_equip_raw_cost            NUMBER;
l_prj_equip_raw_cost            NUMBER;
l_labor_hours                   NUMBER;
l_pou_oth_brdn_cost             NUMBER;
l_prj_oth_brdn_cost             NUMBER;
l_pou_oth_raw_cost              NUMBER;
l_prj_oth_raw_cost              NUMBER;
l_remaining_effort1             NUMBER;
l_percent_complete1             NUMBER;
l_percent_complete2             NUMBER;
l_etc_cost_pc                   NUMBER;
l_ppl_etc_cost_pc               NUMBER;
l_eqpmt_etc_cost_pc             NUMBER;
l_etc_cost_fc                   NUMBER;
l_ppl_etc_cost_fc               NUMBER;
l_eqpmt_etc_cost_fc             NUMBER;
l_bac_value1                    NUMBER;
l_ppl_act_cost_to_date_pc       NUMBER;
l_eqpmt_act_cost_to_date_pc     NUMBER;
l_oth_act_cost_to_date_fc       NUMBER;
l_ppl_act_cost_to_date_fc       NUMBER;
l_eqpmt_act_cost_to_date_fc     NUMBER;
l_ppl_act_effort_to_date        NUMBER;
l_oth_act_rawcost_to_date_pc    NUMBER;
l_ppl_act_rawcost_to_date_pc    NUMBER;
l_eqpmt_act_rawcost_to_date_pc  NUMBER;
l_etc_rawcost_pc                NUMBER;
l_ppl_etc_rawcost_pc            NUMBER;
l_eqpmt_act_rawcost_to_date_fc  NUMBER;
l_ppl_act_rawcost_to_date_fc    NUMBER;
l_oth_act_rawcost_to_date_fc    NUMBER;
l_eqpmt_act_effort_to_date      NUMBER;
l_eqpmt_etc_effort              NUMBER;
l_earned_value1                 NUMBER;
l_oth_act_cost_to_date_pc       NUMBER;
l_percent_complete_id           NUMBER;
l_progress_rollup_id            NUMBER;
l_rollup_rec_ver_number         NUMBER;
l_eqpmt_etc_rawcost_fc          NUMBER;
l_ppl_etc_rawcost_fc            NUMBER;
l_etc_rawcost_fc                NUMBER;
l_eqpmt_etc_rawcost_pc          NUMBER;
l_period_name                   VARCHAR2(30);
l_existing_object_status        VARCHAR2(150);
l_status_code                   VARCHAR2(150);
l_system_status_code            VARCHAR2(150);
l_status_code_temp              VARCHAR2(150); --Bug#5374114
l_system_status_code_temp       VARCHAR2(150); --Bug#5374114
l_max_rollup_as_of_date2        DATE;
l_current_flag                  VARCHAR2(1);
l_pev_schedule_id               NUMBER;
l_actual_exists                 VARCHAR2(1):='N';
l_tsk_scheduled_start_date      Date;
l_tsk_scheduled_finish_date     Date;
l_actual_start_date             Date;
l_actual_finish_date            Date;
l_estimated_start_date          Date;
l_estimated_finish_date         Date;
l_eff_rollup_status_code        VARCHAR2(150);
l_progress_status_code          VARCHAR2(150);
l_rolled_up_base_per_comp       NUMBER;
l_rolled_up_base_prog_stat      VARCHAR2(150);
l_rolled_up_per_comp            NUMBER;
l_rolled_up_prog_stat           VARCHAR2(150);


CURSOR cur_sch_id( c_object_version_id NUMBER )
IS
SELECT pev_schedule_id, record_version_number
FROM pa_proj_elem_ver_schedule
WHERE project_id = p_project_id
AND element_version_id = c_object_version_id;


CURSOR c_get_dates (c_project_id NUMBER, c_element_version_id NUMBER)
IS
SELECT scheduled_start_date, scheduled_finish_date
FROM pa_proj_elem_ver_schedule
WHERE PROJECT_ID = c_project_id
AND element_version_id = c_element_version_id;

CURSOR c_get_dlv_status(c_task_id NUMBER) IS
SELECT 'Y' FROM DUAL
WHERE EXISTS
(SELECT 'xyz'
FROM    pa_percent_completes
WHERE project_id = p_project_id
AND task_id = c_task_id
AND object_type = 'PA_DELIVERABLES'
AND trunc(date_computed)<= trunc(p_as_of_date)
AND structure_type = 'WORKPLAN'
AND published_flag = 'Y'
AND PA_PROGRESS_UTILS.get_system_task_status( status_code, 'PA_DELIVERABLES') = 'DLVR_IN_PROGRESS'
);


CURSOR c_get_object_status (l_project_id NUMBER, l_proj_element_id NUMBER)
IS
SELECT STATUS_CODE
FROM PA_PROJ_ELEMENTS
WHERE PROJ_ELEMENT_ID = l_proj_element_id
AND PROJECT_ID = l_project_id;

CURSOR cur_status( c_status_weight      VARCHAR2 )
IS
select lookup_code
from fnd_lookup_values
where attribute4 = c_status_weight
and lookup_type = 'PROGRESS_SYSTEM_STATUS'
and language = 'US'
AND VIEW_APPLICATION_ID = 275 ; -- Bug ref # 6507900;

CURSOR cur_task_status( c_status_weight VARCHAR2 )
IS
select project_status_code
from pa_project_statuses
where project_status_weight =   c_status_weight
and status_type = 'TASK'
and predefined_flag = 'Y';

l_process_number_temp   NUMBER;

   --This cursor selects the immediate child taks of a given task.
   CURSOR cur_tasks(c_parent_task_ver_id NUMBER)
   IS
          --select      structure
    SELECT to_number(null) object_id_from1
                , ppev.object_type parent_object_type
                , element_version_id object_id_to1
                , ppev.object_type object_type
                , ppev.wbs_level wbs_level
                , to_number( null ) weighting_percentage
                , ppr.EFF_ROLLUP_PERCENT_COMP rollup_completed_percentage
                , ppr.completed_percentage override_percent_complete
		, ppr.as_of_date
                , ppr.actual_start_date
                , ppr.actual_finish_date
                , ppr.estimated_start_date
                , ppr.estimated_finish_date
                , pps1.project_status_weight rollup_weight1 ---rollup progress status   code
                , pps2.project_status_weight override_weight2 ---override progress status code
                , pps3.project_status_weight base_weight3        --base prog status
                , to_number( null )     task_weight4        --task status
                , to_char(null) status_code
                , ppev.proj_element_id object_id
                , ppev.proj_element_id
		, ppr.PPL_ACT_EFFORT_TO_DATE
                , ppr.PPL_ACT_COST_TO_DATE_TC
                , ppr.PPL_ACT_COST_TO_DATE_PC
                , ppr.PPL_ACT_COST_TO_DATE_FC
		, ppr.PPL_ACT_RAWCOST_TO_DATE_TC
		, ppr.PPL_ACT_RAWCOST_TO_DATE_PC
		, ppr.PPL_ACT_RAWCOST_TO_DATE_FC
                , ppr.ESTIMATED_REMAINING_EFFORT
                , ppr.PPL_ETC_COST_TC
                , ppr.PPL_ETC_COST_PC
                , ppr.PPL_ETC_COST_FC
                , ppr.PPL_ETC_RAWCOST_TC
                , ppr.PPL_ETC_RAWCOST_PC
                , ppr.PPL_ETC_RAWCOST_FC
		, ppr.EQPMT_ACT_EFFORT_TO_DATE
                , ppr.EQPMT_ACT_COST_TO_DATE_TC
                , ppr.EQPMT_ACT_COST_TO_DATE_PC
                , ppr.EQPMT_ACT_COST_TO_DATE_FC
		, ppr.EQPMT_ACT_RAWCOST_TO_DATE_TC
		, ppr.EQPMT_ACT_RAWCOST_TO_DATE_PC
		, ppr.EQPMT_ACT_RAWCOST_TO_DATE_FC
                , ppr.EQPMT_ETC_EFFORT
                , ppr.EQPMT_ETC_COST_TC
                , ppr.EQPMT_ETC_COST_PC
                , ppr.EQPMT_ETC_COST_FC
                , ppr.EQPMT_ETC_RAWCOST_TC
                , ppr.EQPMT_ETC_RAWCOST_PC
                , ppr.EQPMT_ETC_RAWCOST_FC
		, ppr.OTH_QUANTITY_TO_DATE
                , ppr.OTH_ACT_COST_TO_DATE_TC
                , ppr.OTH_ACT_COST_TO_DATE_PC
                , ppr.OTH_ACT_COST_TO_DATE_FC
		, ppr.OTH_ACT_RAWCOST_TO_DATE_TC
		, ppr.OTH_ACT_RAWCOST_TO_DATE_PC
		, ppr.OTH_ACT_RAWCOST_TO_DATE_FC
		, ppr.OTH_ETC_QUANTITY
                , ppr.OTH_ETC_COST_TC
                , ppr.OTH_ETC_COST_PC
                , ppr.OTH_ETC_COST_FC
                , ppr.OTH_ETC_RAWCOST_TC
                , ppr.OTH_ETC_RAWCOST_PC
                , ppr.OTH_ETC_RAWCOST_FC
                , ppr.CURRENT_FLAG
                , ppr.PROJFUNC_COST_RATE_TYPE
                , ppr.PROJFUNC_COST_EXCHANGE_RATE
                , ppr.PROJFUNC_COST_RATE_DATE
                , ppr.PROJ_COST_RATE_TYPE
                , ppr.PROJ_COST_EXCHANGE_RATE
                , ppr.PROJ_COST_RATE_DATE
                , ppr.TXN_CURRENCY_CODE
                , ppr.PROG_PA_PERIOD_NAME
                , ppr.PROG_GL_PERIOD_NAME
                , pa_progress_utils.Get_BAC_Value(ppev.project_id, decode(p_structure_type,'WORKPLAN',p_wp_rollup_method,'FINANCIAL',p_fin_rollup_method), ppev.proj_element_id, ppev.element_version_id, p_structure_type,p_working_wp_prog_flag) BAC_value
                , pa_progress_utils.Get_BAC_Value(ppev.project_id, decode(p_structure_type,'WORKPLAN',p_wp_rollup_method,'FINANCIAL',p_fin_rollup_method), ppev.proj_element_id, ppev.element_version_id, p_structure_type,p_working_wp_prog_flag,'N')
                  BAC_value_self -- bug 4493105
                , null earned_value
		, to_char(null) task_derivation_method
		, ppr.progress_rollup_id
		, ppr.record_version_number
	--	, element_version_id object_version_id Bug 4651304 : select ppr.object_version_id
		, ppr.object_version_id -- Bug 4651304
                , ppr.progress_status_code
                , ppr.incremental_work_quantity
                , ppr.cumulative_work_quantity
		-- 4533112 : Added decode to select N and Y only
                , decode(ppr.base_progress_status_code, 'Y', 'Y', 'N')
                , ppr.EFF_ROLLUP_PROG_STAT_CODE
                , ppr.percent_complete_id
                , ppr.TASK_WT_BASIS_CODE
                , ppr.structure_version_id
                ,'N' create_required
                ,'N' update_required
        , ppr.base_percent_complete -- 4392189 : Program Reporting Changes - Phase 2
    FROM pa_proj_element_versions ppev,
            pa_progress_rollup ppr,
            pa_project_statuses pps1,
            pa_project_statuses pps2,
            pa_project_statuses pps3 ,
            pa_proj_rollup_temp temp
    WHERE  --BUG 4355204 rtarway, removed in clause and added pa_proj_rollup_temp in FROM
               --element_version_id IN (SELECT object_id from pa_proj_rollup_temp where process_number = l_process_number_temp)
               temp.object_id = ppev.element_version_id
        AND    temp.process_number = l_process_number_temp
	AND    ppev.object_type = 'PA_STRUCTURES'
        AND    ppr.project_id  = ppev.project_id
        AND    ppr.object_id = ppev.proj_element_id
        AND    ppr.object_type =  'PA_STRUCTURES'
        AND    ppr.as_of_date  = pa_progress_utils.get_max_rollup_asofdate(ppev.project_id,
                                 ppev.proj_element_id, ppev.object_type,p_as_of_date, ppev.element_version_id, p_structure_type, l_structure_version_id, ppev.proj_element_id/* Bug 3764224 */) -- FPM Dev CR 3
        AND    ppr.current_flag <>     'W'
        AND    ppr.EFF_ROLLUP_PROG_STAT_CODE = pps1.project_status_code(+)
        AND    ppr.progress_status_code = pps2.project_status_code(+)
        AND    ppr.base_progress_status_code = pps3.project_status_code(+)
        AND    ppr.structure_type = p_structure_type
        AND    ((l_published_structure = 'Y' AND ppr.structure_version_id is null) OR (l_published_structure = 'N' AND ppr.structure_version_id = p_structure_version_id))
AND temp.object_type = 'PA_TASKS' --  cklee bug: 6610612
        UNION
        --      select tasks
        SELECT pobj.object_id_from1
                , ppev1.object_type     parent_object_type
                , pobj.object_id_to1
                , ppev2.object_type     object_type
                , ppev2.wbs_level wbs_level
                , pobj.weighting_percentage
                , ppr.EFF_ROLLUP_PERCENT_COMP   rollup_completed_percentage
                , ppr.completed_percentage override_percent_complete
		, ppr.as_of_date
                , ppr.actual_start_date
                , ppr.actual_finish_date
                , ppr.estimated_start_date
                , ppr.estimated_finish_date
                , pps1.project_status_weight rollup_weight1     ---rollup       progress        status code
                , pps2.project_status_weight override_weight2 ---override progress status code
                , pps3.project_status_weight base_weight3        ---base prog status
                , pps4.project_status_weight    task_weight4
                , ppe.status_code
                , ppev2.proj_element_id object_id
                , ppev2.proj_element_id
		, ppr.PPL_ACT_EFFORT_TO_DATE
                , ppr.PPL_ACT_COST_TO_DATE_TC
                , ppr.PPL_ACT_COST_TO_DATE_PC
                , ppr.PPL_ACT_COST_TO_DATE_FC
		, ppr.PPL_ACT_RAWCOST_TO_DATE_TC
		, ppr.PPL_ACT_RAWCOST_TO_DATE_PC
		, ppr.PPL_ACT_RAWCOST_TO_DATE_FC
                , ppr.ESTIMATED_REMAINING_EFFORT
                , ppr.PPL_ETC_COST_TC
                , ppr.PPL_ETC_COST_PC
                , ppr.PPL_ETC_COST_FC
                , ppr.PPL_ETC_RAWCOST_TC
                , ppr.PPL_ETC_RAWCOST_PC
                , ppr.PPL_ETC_RAWCOST_FC
		, ppr.EQPMT_ACT_EFFORT_TO_DATE
		, ppr.EQPMT_ACT_COST_TO_DATE_TC
                , ppr.EQPMT_ACT_COST_TO_DATE_PC
                , ppr.EQPMT_ACT_COST_TO_DATE_FC
		, ppr.EQPMT_ACT_RAWCOST_TO_DATE_TC
		, ppr.EQPMT_ACT_RAWCOST_TO_DATE_PC
		, ppr.EQPMT_ACT_RAWCOST_TO_DATE_FC
                , ppr.EQPMT_ETC_EFFORT
                , ppr.EQPMT_ETC_COST_TC
                , ppr.EQPMT_ETC_COST_PC
                , ppr.EQPMT_ETC_COST_FC
                , ppr.EQPMT_ETC_RAWCOST_TC
                , ppr.EQPMT_ETC_RAWCOST_PC
                , ppr.EQPMT_ETC_RAWCOST_FC
		, ppr.OTH_QUANTITY_TO_DATE
                , ppr.OTH_ACT_COST_TO_DATE_TC
                , ppr.OTH_ACT_COST_TO_DATE_PC
                , ppr.OTH_ACT_COST_TO_DATE_FC
		, ppr.OTH_ACT_RAWCOST_TO_DATE_TC
		, ppr.OTH_ACT_RAWCOST_TO_DATE_PC
		, ppr.OTH_ACT_RAWCOST_TO_DATE_FC
		, ppr.OTH_ETC_QUANTITY
                , ppr.OTH_ETC_COST_TC
                , ppr.OTH_ETC_COST_PC
                , ppr.OTH_ETC_COST_FC
                , ppr.OTH_ETC_RAWCOST_TC
                , ppr.OTH_ETC_RAWCOST_PC
                , ppr.OTH_ETC_RAWCOST_FC
                , ppr.CURRENT_FLAG
                , ppr.PROJFUNC_COST_RATE_TYPE
                , ppr.PROJFUNC_COST_EXCHANGE_RATE
                , ppr.PROJFUNC_COST_RATE_DATE
                , ppr.PROJ_COST_RATE_TYPE
                , ppr.PROJ_COST_EXCHANGE_RATE
                , ppr.PROJ_COST_RATE_DATE
                , ppr.TXN_CURRENCY_CODE
                , ppr.PROG_PA_PERIOD_NAME
                , ppr.PROG_GL_PERIOD_NAME
                , pa_progress_utils.Get_BAC_Value(ppev2.project_id, decode(p_structure_type,'WORKPLAN',p_wp_rollup_method,
                                        'FINANCIAL',p_fin_rollup_method), ppev2.proj_element_id, ppev2.parent_structure_version_id,
                                         p_structure_type,p_working_wp_prog_flag) BAC_value
                , pa_progress_utils.Get_BAC_Value(ppev2.project_id, decode(p_structure_type,'WORKPLAN',p_wp_rollup_method,
                                        'FINANCIAL',p_fin_rollup_method), ppev2.proj_element_id, ppev2.parent_structure_version_id,
                                         p_structure_type,p_working_wp_prog_flag,'N') BAC_value_self -- bug 4493105
                , null earned_value
		, decode(ppe.base_percent_comp_deriv_code,    null, ttype.base_percent_comp_deriv_code,'^',ttype.base_percent_comp_deriv_code,ppe.base_percent_comp_deriv_code) task_derivation_method
		, ppr.progress_rollup_id
		, ppr.record_version_number
	--	, pobj.object_id_to1 object_version_id Bug 4651304 : select ppr.object_version_id
		, ppr.object_version_id -- Bug 4651304
                , ppr.progress_status_code
                , ppr.incremental_work_quantity
                , ppr.cumulative_work_quantity
		-- 4533112 : Added decode to select N and Y only
                , decode(ppr.base_progress_status_code, 'Y', 'Y', 'N')
                , ppr.EFF_ROLLUP_PROG_STAT_CODE
                , ppr.percent_complete_id
                , ppr.TASK_WT_BASIS_CODE
                , ppr.structure_version_id
                ,'N' create_required
                ,'N' update_required
		, ppr.base_percent_complete -- 4392189 : Program Reporting Changes - Phase 2
          FROM
                  pa_object_relationships       pobj,
                  pa_proj_element_versions      ppev1,
                  pa_proj_element_versions      ppev2,
                  pa_progress_rollup ppr,
                  pa_proj_elements      ppe,
                  pa_project_statuses pps1,
                  pa_project_statuses pps2,
                  pa_project_statuses pps3,
                  pa_project_statuses pps4,
            pa_task_types ttype ,
            pa_proj_rollup_temp temp
        WHERE --BUG 4355204 rtarway, removed in clause and added pa_proj_rollup_temp in FROM
          --IN (SELECT object_id from pa_proj_rollup_temp where process_number = l_process_number_temp)
              temp.object_id = pobj.object_id_from1
          AND temp.process_number = l_process_number_temp
          AND pobj.object_id_from1 = ppev1.element_version_id
          AND pobj.object_id_to1 = ppev2.element_version_id
          AND pobj.relationship_type = 'S'
          AND ppr.project_id = ppev2.project_id
          AND ppr.as_of_date = pa_progress_utils.get_max_rollup_asofdate(ppev2.project_id,
                                  ppev2.proj_element_id, ppev2.object_type,p_as_of_date, ppev2.element_version_id, p_structure_type, l_structure_version_id, ppev2.proj_element_id/*Bug 3764224 */) -- FPM Dev CR 3
          AND ppr.current_flag <> 'W'
          AND ppr.object_id     = ppev2.proj_element_id
          AND ppr.project_id = ppev2.project_id
          AND ppr.object_type = 'PA_TASKS'
          AND ppe.proj_element_id = ppev2.proj_element_id
          AND ppr.EFF_ROLLUP_PROG_STAT_CODE = pps1.project_status_code(+)
          AND ppr.progress_status_code = pps2.project_status_code(+)
          AND ppr.base_progress_status_code = pps3.project_status_code(+)
          AND ppe.status_code = pps4.project_status_code(+)
          AND ppe.project_id = ppev2.project_id
          AND ppe.object_type = ppev2.object_type
          AND ppev2.object_type = 'PA_TASKS'
          AND ppe.object_type = 'PA_TASKS'
          AND ppe.link_task_flag <> 'Y' -- 4392189
          AND pobj.object_type_to = 'PA_TASKS'
          AND pobj.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
          AND ppe.type_id = ttype.task_type_id
          AND ((l_published_structure = 'Y' AND ppr.structure_version_id is null) OR (l_published_structure = 'N' AND ppr.structure_version_id = p_structure_version_id))
          AND ppr.structure_type = p_structure_type
	  AND ((ppev2.financial_task_flag = 'Y' AND p_structure_type = 'FINANCIAL') OR p_structure_type = 'WORKPLAN') -- Bug 4346483
AND temp.object_type = 'PA_TASKS' --  cklee bug: 6610612
UNION ALL
          SELECT to_number(null)        object_id_from1
                , ppev.object_type parent_object_type
                , element_version_id object_id_to1
                , ppev.object_type object_type
                , ppev.wbs_level wbs_level
                , to_number( null )     weighting_percentage
                , to_number(null) rollup_completed_percentage
                , to_number(null) override_percent_complete
		, to_date(null) as_of_date
                , to_date(null) actual_start_date
                , to_date(null) actual_finish_date
                , to_date(null) estimated_start_date
                , to_date(null) estimated_finish_date
                , to_number(null) rollup_weight1 ---rollup progress status code
                , to_number(null) override_weight2      ---override progress    status code
                , to_number(null) base_weight3     --base       prog    status
                , to_number( null )     task_weight4        --task status
                , to_char(null) status_code
                , ppev.proj_element_id object_id
                , ppev.proj_element_id
		, to_number(  null    ) PPL_ACT_EFFORT_TO_DATE
                , to_number( null )     PPL_ACT_COST_TO_DATE_TC
                , to_number( null )     PPL_ACT_COST_TO_DATE_PC
                , to_number( null )     PPL_ACT_COST_TO_DATE_FC
		, to_number(  null    ) PPL_ACT_RAWCOST_TO_DATE_TC
		, to_number(  null    ) PPL_ACT_RAWCOST_TO_DATE_PC
		, to_number(  null    ) PPL_ACT_RAWCOST_TO_DATE_FC
                , to_number( null )     ESTIMATED_REMAINING_EFFORT
                , to_number( null )     PPL_ETC_COST_TC
                , to_number( null )     PPL_ETC_COST_PC
                , to_number( null )     PPL_ETC_COST_FC
                , to_number( null )     PPL_ETC_RAWCOST_TC
                , to_number( null )     PPL_ETC_RAWCOST_PC
                , to_number( null )     PPL_ETC_RAWCOST_FC
		, to_number(  null    ) EQPMT_ACT_EFFORT_TO_DATE
                , to_number( null )     EQPMT_ACT_COST_TO_DATE_TC
                , to_number( null )     EQPMT_ACT_COST_TO_DATE_PC
                , to_number( null )     EQPMT_ACT_COST_TO_DATE_FC
		, to_number(  null    ) EQPMT_ACT_RAWCOST_TO_DATE_TC
		, to_number(  null    ) EQPMT_ACT_RAWCOST_TO_DATE_PC
		, to_number(  null    ) EQPMT_ACT_RAWCOST_TO_DATE_FC
                , to_number( null )     EQPMT_ETC_EFFORT
                , to_number( null )     EQPMT_ETC_COST_TC
                , to_number( null )     EQPMT_ETC_COST_PC
                , to_number( null )     EQPMT_ETC_COST_FC
                , to_number( null )     EQPMT_ETC_RAWCOST_TC
                , to_number( null )     EQPMT_ETC_RAWCOST_PC
                , to_number( null )     EQPMT_ETC_RAWCOST_FC
		, to_number(  null    ) OTH_QUANTITY_TO_DATE
                , to_number( null )     OTH_ACT_COST_TO_DATE_TC
                , to_number( null )     OTH_ACT_COST_TO_DATE_PC
                , to_number( null )     OTH_ACT_COST_TO_DATE_FC
		, to_number(  null    ) OTH_ACT_RAWCOST_TO_DATE_TC
		, to_number(  null    ) OTH_ACT_RAWCOST_TO_DATE_PC
		, to_number(  null    ) OTH_ACT_RAWCOST_TO_DATE_FC
		, to_number(  null    ) OTH_ETC_QUANTITY
                , to_number( null )     OTH_ETC_COST_TC
                , to_number( null )     OTH_ETC_COST_PC
                , to_number( null )     OTH_ETC_COST_FC
                , to_number( null )     OTH_ETC_RAWCOST_TC
                , to_number( null )     OTH_ETC_RAWCOST_PC
                , to_number( null )     OTH_ETC_RAWCOST_FC
                , to_char(null) CURRENT_FLAG
                , to_char(null)  PROJFUNC_COST_RATE_TYPE
                , to_number( null )     PROJFUNC_COST_EXCHANGE_RATE
                , to_date(null) PROJFUNC_COST_RATE_DATE
                , to_char(null) PROJ_COST_RATE_TYPE
                , to_number( null )     PROJ_COST_EXCHANGE_RATE
                , to_date(null) PROJ_COST_RATE_DATE
                , to_char(null) TXN_CURRENCY_CODE
                , to_char(null) PROG_PA_PERIOD_NAME
                , to_char(null) PROG_GL_PERIOD_NAME
                , pa_progress_utils.Get_BAC_Value(ppev.project_id, decode(p_structure_type,'WORKPLAN',p_wp_rollup_method,'FINANCIAL',p_fin_rollup_method), ppev.proj_element_id, ppev.element_version_id, p_structure_type,p_working_wp_prog_flag) BAC_value
                , pa_progress_utils.Get_BAC_Value(ppev.project_id, decode(p_structure_type,'WORKPLAN',p_wp_rollup_method,'FINANCIAL',p_fin_rollup_method), ppev.proj_element_id, ppev.element_version_id, p_structure_type,p_working_wp_prog_flag,'N')
                   BAC_value_self -- bug 4493105
                , null earned_value
		, to_char(null) task_derivation_method
		, to_number(null)     progress_rollup_id
		, to_number(null)     record_version_number
                , element_version_id object_version_id
                , to_char(null) progress_status_code
                , to_number(null) incremental_work_quantity
                , to_number(null) cumulative_work_quantity
		-- 4533112 : Added N only
                , 'N' base_progress_status_code
                , to_char(null) EFF_ROLLUP_PROG_STAT_CODE
                , to_number(null) percent_complete_id
                , to_char(null) TASK_WT_BASIS_CODE
                , to_number(null) structure_version_id
                ,'N'    create_required
                ,'N'    update_required
		, to_number(null) base_percent_complete -- 4392189 : Program Reporting Changes - Phase 2
          FROM pa_proj_element_versions ppev , pa_proj_rollup_temp temp
          WHERE --BUG 4355204 rtarway, removed in clause and added pa_proj_rollup_temp in FROM
            --IN (SELECT object_id from pa_proj_rollup_temp where process_number = l_process_number_temp)
            element_version_id  = temp.object_id
                AND temp.process_number = l_process_number_temp
         AND    ppev.object_type =      'PA_STRUCTURES'
         AND    pa_progress_utils.get_max_rollup_asofdate(ppev.project_id,
                        ppev.proj_element_id, ppev.object_type,p_as_of_date, ppev.element_version_id, p_structure_type, l_structure_version_id, ppev.proj_element_id/*Bug 3764224 */)
                        IS      NULL
AND temp.object_type = 'PA_TASKS' --  cklee bug: 6610612
        UNION
        --      select tasks
        SELECT pobj.object_id_from1
                , ppev1.object_type     parent_object_type
                , pobj.object_id_to1
                , ppev2.object_type     object_type
                , ppev2.wbs_level wbs_level
                , pobj.weighting_percentage
                , to_number(null) rollup_completed_percentage
                , to_number(null) override_percent_complete
		, to_date(null) as_of_date
                , to_date(null) actual_start_date
                , to_date(null) actual_finish_date
                , to_date(null) estimated_start_date
                , to_date(null) estimated_finish_date
                , to_number(null) rollup_weight1 ---rollup progress status code
                , to_number(null) override_weight2      ---override progress    status code
                , to_number(null) base_weight3     --base       prog    status
                , to_number( null )     task_weight4        --task status
                , to_char(null) status_code
                , ppev2.proj_element_id object_id
                , ppev2.proj_element_id
		, to_number(  null    ) PPL_ACT_EFFORT_TO_DATE
                , to_number( null )     PPL_ACT_COST_TO_DATE_TC
                , to_number( null )     PPL_ACT_COST_TO_DATE_PC
                , to_number( null )     PPL_ACT_COST_TO_DATE_FC
		, to_number(  null    ) PPL_ACT_RAWCOST_TO_DATE_TC
		, to_number(  null    ) PPL_ACT_RAWCOST_TO_DATE_PC
		, to_number(  null    ) PPL_ACT_RAWCOST_TO_DATE_FC
                , to_number( null )     ESTIMATED_REMAINING_EFFORT
                , to_number( null )     PPL_ETC_COST_TC
                , to_number( null )     PPL_ETC_COST_PC
                , to_number( null )     PPL_ETC_COST_FC
                , to_number( null )     PPL_ETC_RAWCOST_TC
                , to_number( null )     PPL_ETC_RAWCOST_PC
                , to_number( null )     PPL_ETC_RAWCOST_FC
		, to_number(  null    ) EQPMT_ACT_EFFORT_TO_DATE
                , to_number( null )     EQPMT_ACT_COST_TO_DATE_TC
                , to_number( null )     EQPMT_ACT_COST_TO_DATE_PC
                , to_number( null )     EQPMT_ACT_COST_TO_DATE_FC
		, to_number(  null    ) EQPMT_ACT_RAWCOST_TO_DATE_TC
		, to_number(  null    ) EQPMT_ACT_RAWCOST_TO_DATE_PC
		, to_number(  null    ) EQPMT_ACT_RAWCOST_TO_DATE_FC
                , to_number( null )     EQPMT_ETC_EFFORT
                , to_number( null )     EQPMT_ETC_COST_TC
                , to_number( null )     EQPMT_ETC_COST_PC
                , to_number( null )     EQPMT_ETC_COST_FC
                , to_number( null )     EQPMT_ETC_RAWCOST_TC
                , to_number( null )     EQPMT_ETC_RAWCOST_PC
                , to_number( null )     EQPMT_ETC_RAWCOST_FC
		, to_number(  null    ) OTH_QUANTITY_TO_DATE
                , to_number( null )     OTH_ACT_COST_TO_DATE_TC
                , to_number( null )     OTH_ACT_COST_TO_DATE_PC
                , to_number( null )     OTH_ACT_COST_TO_DATE_FC
		, to_number(  null    ) OTH_ACT_RAWCOST_TO_DATE_TC
		, to_number(  null    ) OTH_ACT_RAWCOST_TO_DATE_PC
		, to_number(  null    ) OTH_ACT_RAWCOST_TO_DATE_FC
		, to_number(  null    ) OTH_ETC_QUANTITY
                , to_number( null )     OTH_ETC_COST_TC
                , to_number( null )     OTH_ETC_COST_PC
                , to_number( null )     OTH_ETC_COST_FC
                , to_number( null )     OTH_ETC_RAWCOST_TC
                , to_number( null )     OTH_ETC_RAWCOST_PC
                , to_number( null )     OTH_ETC_RAWCOST_FC
                , to_char(null) CURRENT_FLAG
                , to_char(null)  PROJFUNC_COST_RATE_TYPE
                , to_number( null )     PROJFUNC_COST_EXCHANGE_RATE
                , to_date(null) PROJFUNC_COST_RATE_DATE
                , to_char(null) PROJ_COST_RATE_TYPE
                , to_number( null )     PROJ_COST_EXCHANGE_RATE
                , to_date(null) PROJ_COST_RATE_DATE
                , to_char(null) TXN_CURRENCY_CODE
                , to_char(null) PROG_PA_PERIOD_NAME
                , to_char(null) PROG_GL_PERIOD_NAME
                , pa_progress_utils.Get_BAC_Value(ppev2.project_id, decode(p_structure_type,'WORKPLAN',p_wp_rollup_method,'FINANCIAL',
                                   p_fin_rollup_method), ppev2.proj_element_id,  ppev2.parent_structure_version_id,
                                    p_structure_type,p_working_wp_prog_flag) BAC_value
                , pa_progress_utils.Get_BAC_Value(ppev2.project_id, decode(p_structure_type,'WORKPLAN',p_wp_rollup_method,'FINANCIAL',
                                   p_fin_rollup_method), ppev2.proj_element_id,  ppev2.parent_structure_version_id,
                                    p_structure_type,p_working_wp_prog_flag,'N') BAC_value_self -- bug 4493105
                , null earned_value
		, decode(ppe.base_percent_comp_deriv_code,    null, ttype.base_percent_comp_deriv_code,'^',ttype.base_percent_comp_deriv_code,ppe.base_percent_comp_deriv_code) task_derivation_method
		, to_number(null) progress_rollup_id
		, to_number(null) record_version_number
                , pobj.object_id_to1 object_version_id
                , to_char(null) progress_status_code
                , to_number(null) incremental_work_quantity
                , to_number(null) cumulative_work_quantity
		-- 4533112 : Added N only
                , 'N' base_progress_status_code
                , to_char(null) EFF_ROLLUP_PROG_STAT_CODE
                , to_number(null) percent_complete_id
                , to_char(null) TASK_WT_BASIS_CODE
                , to_number(null) structure_version_id
                ,'N' create_required
                ,'N' update_required
		, to_number(null) base_percent_complete -- 4392189 : Program Reporting Changes - Phase 2
          FROM
                  pa_object_relationships       pobj,
                  pa_proj_element_versions      ppev1,
                  pa_proj_element_versions      ppev2,
                  pa_proj_elements      ppe,
                  pa_project_statuses pps4,
            pa_task_types ttype ,
            pa_proj_rollup_temp temp
        WHERE --BUG 4355204 rtarway, removed in clause and added pa_proj_rollup_temp in FROM
          --IN (SELECT object_id from pa_proj_rollup_temp where process_number = l_process_number_temp)
          pobj.object_id_from1  = temp.object_id
          AND temp.process_number = l_process_number_temp
          AND pobj.object_id_from1 = ppev1.element_version_id
          AND pobj.object_id_to1 = ppev2.element_version_id
          AND pobj.relationship_type = 'S'
          AND ppe.proj_element_id = ppev2.proj_element_id
          AND ppe.status_code = pps4.project_status_code(+)
          AND ppe.project_id = ppev2.project_id
          AND ppe.object_type = ppev2.object_type
          AND ppev2.object_type = 'PA_TASKS'
          AND ppe.object_type = 'PA_TASKS'
          AND ppe.link_task_flag <> 'Y' -- 4392189
          AND pobj.object_type_to = 'PA_TASKS'
          AND pobj.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
          AND ppe.type_id = ttype.task_type_id
          AND pa_progress_utils.get_max_rollup_asofdate(ppev2.project_id,
                  ppev2.proj_element_id, ppev2.object_type,p_as_of_date, ppev2.element_version_id, p_structure_type, l_structure_version_id,     ppev2.proj_element_id/*Bug      3764224 */)
                  IS NULL
      AND ( (ppev2.financial_task_flag = 'Y' AND p_structure_type = 'FINANCIAL') OR p_structure_type = 'WORKPLAN') -- Bug 4346483
AND temp.object_type = 'PA_TASKS' --  cklee bug: 6610612
      ;

   -- FPM       Dev CR 6 : Added Union ALL

   l_asgn_task_version_id_tab                    SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
   l_asgn_rate_based_flag_tab                    SYSTEM.PA_VARCHAR2_1_TBL_TYPE    :=    SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
   l_asgn_resource_class_code_tab                SYSTEM.PA_VARCHAR2_30_TBL_TYPE :=      SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
   l_asgn_res_assignment_id_tab                 SYSTEM.PA_NUM_TBL_TYPE  :=      SYSTEM.PA_NUM_TBL_TYPE();
   l_asgn_planned_quantity_tab                  SYSTEM.PA_NUM_TBL_TYPE  :=      SYSTEM.PA_NUM_TBL_TYPE();
   l_asgn_plan_bur_cost_pc_tab                  SYSTEM.PA_NUM_TBL_TYPE  :=      SYSTEM.PA_NUM_TBL_TYPE();
   l_asgn_res_list_member_id_tab                SYSTEM.PA_NUM_TBL_TYPE  :=      SYSTEM.PA_NUM_TBL_TYPE();

   CURSOR       cur_assgn_rec_bulk(     c_task_ver_id NUMBER, c_task_id NUMBER )        IS
   SELECT       a.wbs_element_version_id
   ,    a.rate_based_flag
   ,    a.resource_class_code
   ,    a.resource_assignment_id
   ,    a.total_plan_quantity planned_quantity
   ,    a.total_project_burdened_cost   planned_bur_cost_proj_cur
   ,    a.resource_list_member_id
   from pa_resource_assignments a
   WHERE a.wbs_element_version_id = c_task_ver_id
   AND a.project_id     = p_project_id
   AND a.task_id = c_task_id
--   AND a.ta_display_flag        = 'Y' --Bug 4323537
;

CURSOR cur_get_asgn_progress(c_object_id NUMBER, c_proj_element_id NUMBER)      IS
SELECT ppr.*
FROM    pa_progress_rollup      ppr
WHERE ppr.project_id = p_project_id
AND ppr.object_id =     c_object_id
AND ppr.proj_element_id = c_proj_element_id
AND ppr.object_type     = 'PA_ASSIGNMENTS'
AND ppr.current_flag <> 'W'
AND ppr.structure_type =        p_structure_type
AND ppr.as_of_date <= p_as_of_date
AND ((l_published_structure =   'Y' AND ppr.structure_version_id is null)       OR (l_published_structure = 'N' AND ppr.structure_version_id = p_structure_version_id))
AND rownum =1
ORDER BY as_of_date     desc
;

l_asgn_progress_rec     cur_get_asgn_progress%ROWTYPE;
l_asgn_act_start_date    DATE;
l_asgn_act_finish_date   DATE;
l_asgn_est_start_date    DATE;
l_asgn_est_finish_date   DATE;
l_asgn_as_of_date       DATE;
l_asgn_ppl_act_eff      NUMBER;
l_asgn_eqp_act_eff      NUMBER;
l_asgn_ppl_act_cost     NUMBER;
l_asgn_eqp_act_cost     NUMBER;
l_asgn_oth_act_cost     NUMBER;
l_asgn_ppl_etc_eff      NUMBER;
l_asgn_eqp_etc_eff      NUMBER;
l_asgn_ppl_etc_cost     NUMBER;
l_asgn_eqp_etc_cost     NUMBER;
l_asgn_oth_etc_cost     NUMBER;
l_asgn_earned_value     NUMBER;
l_asgn_bac_value        NUMBER;

/*
   --This cursor selects  the task assignments of a given task.
   -- sql id: 14904837  bug: 4871809  NOT USED IN CODE
   CURSOR cur_assgn( c_task_ver_id        NUMBER, c_task_per_comp_deriv_method    VARCHAR2 )
   IS
        SELECT asgn.task_version_id
        , 'PA_TASKS' parent_object_type
        , asgn.resource_assignment_id   object_id_to1     --maansari4/8 --      Bug 3764224, ideally this shdould be changes    to      RLM id. But keeping this as     is due to       Scheduling API  behaviour
        , asgn.task_version_id object_id_from1
        , 'PA_ASSIGNMENTS' object_type
        , asgn.resource_class_code
        , asgn.rate_based_flag
        , decode(asgn.rate_based_flag,'Y','EFFORT','N','COST')  assignment_type
        , ppr.actual_start_date
        , ppr.actual_finish_date
        , ppr.estimated_start_date
        , ppr.estimated_finish_date
        , ppr.ESTIMATED_REMAINING_EFFORT
        , ppr.STRUCTURE_VERSION_ID
        , ppr.STRUCTURE_TYPE
        , ppr.PROJ_ELEMENT_ID
        , ppr.PPL_ACT_EFFORT_TO_DATE
        , ppr.EQPMT_ACT_EFFORT_TO_DATE
        , ppr.PPL_ACT_EFFORT_TO_DATE + ppr.EQPMT_ACT_EFFORT_TO_DATE     total_act_effort_to_date
        , ppr.EQPMT_ETC_EFFORT
        , ppr.EQPMT_ETC_EFFORT +        ppr.estimated_remaining_effort  total_etc_effort
        , ppr.OTH_ACT_COST_TO_DATE_TC
        , ppr.OTH_ACT_COST_TO_DATE_PC
        , ppr.OTH_ACT_COST_TO_DATE_FC
        , ppr.OTH_ETC_COST_TC
        , ppr.OTH_ETC_COST_PC
        , ppr.OTH_ETC_COST_FC
        , ppr.PPL_ACT_COST_TO_DATE_TC
        , ppr.PPL_ACT_COST_TO_DATE_PC
        , ppr.PPL_ACT_COST_TO_DATE_FC
        , ppr.PPL_ETC_COST_TC
        , ppr.PPL_ETC_COST_PC
        , ppr.PPL_ETC_COST_FC
        , ppr.EQPMT_ACT_COST_TO_DATE_TC
        , ppr.EQPMT_ACT_COST_TO_DATE_PC
        , ppr.EQPMT_ACT_COST_TO_DATE_FC
        , ppr.OTH_ACT_COST_TO_DATE_TC   +       ppr.PPL_ACT_COST_TO_DATE_TC +   ppr.EQPMT_ACT_COST_TO_DATE_TC   total_act_cost_to_date_tc
        , ppr.OTH_ACT_COST_TO_DATE_PC   +       ppr.PPL_ACT_COST_TO_DATE_PC +   ppr.EQPMT_ACT_COST_TO_DATE_PC   total_act_cost_to_date_pc
        , ppr.OTH_ACT_COST_TO_DATE_FC   +       ppr.PPL_ACT_COST_TO_DATE_FC +   ppr.EQPMT_ACT_COST_TO_DATE_FC   total_act_cost_to_date_fc
        , ppr.EQPMT_ETC_COST_TC
        , ppr.EQPMT_ETC_COST_PC
        , ppr.EQPMT_ETC_COST_FC
        , ppr.OTH_ETC_COST_TC + ppr.PPL_ETC_COST_TC     + ppr.EQPMT_ETC_COST_TC total_etc_cost_tc
        , ppr.OTH_ETC_COST_PC + ppr.PPL_ETC_COST_PC     + ppr.EQPMT_ETC_COST_PC total_etc_cost_pc
        , ppr.OTH_ETC_COST_FC + ppr.PPL_ETC_COST_FC     + ppr.EQPMT_ETC_COST_FC total_etc_cost_fc
--      , ppr.EARNED_VALUE
        , ppr.SUBPRJ_PPL_ACT_EFFORT
        , ppr.SUBPRJ_EQPMT_ACT_EFFORT
        , ppr.SUBPRJ_PPL_ETC_EFFORT
        , ppr.SUBPRJ_EQPMT_ETC_EFFORT
        , ppr.SUBPRJ_OTH_ACT_COST_TO_DATE_TC
        , ppr.SUBPRJ_OTH_ACT_COST_TO_DATE_FC
        , ppr.SUBPRJ_OTH_ACT_COST_TO_DATE_PC
        , ppr.SUBPRJ_PPL_ACT_COST_TC
        , ppr.SUBPRJ_PPL_ACT_COST_FC
        , ppr.SUBPRJ_PPL_ACT_COST_PC
        , ppr.SUBPRJ_EQPMT_ACT_COST_TC
        , ppr.SUBPRJ_EQPMT_ACT_COST_FC
        , ppr.SUBPRJ_EQPMT_ACT_COST_PC
        , ppr.SUBPRJ_OTH_ACT_COST_TO_DATE_TC + ppr.SUBPRJ_PPL_ACT_COST_TC + ppr.SUBPRJ_EQPMT_ACT_COST_TC total_subproj_act_cost_tc
        , ppr.SUBPRJ_OTH_ACT_COST_TO_DATE_PC + ppr.SUBPRJ_PPL_ACT_COST_PC + ppr.SUBPRJ_EQPMT_ACT_COST_PC total_subproj_act_cost_pc
        , ppr.SUBPRJ_OTH_ACT_COST_TO_DATE_FC + ppr.SUBPRJ_PPL_ACT_COST_FC + ppr.SUBPRJ_EQPMT_ACT_COST_FC total_subproj_act_cost_fc
        , ppr.SUBPRJ_OTH_ETC_COST_TC
        , ppr.SUBPRJ_OTH_ETC_COST_FC
        , ppr.SUBPRJ_OTH_ETC_COST_PC
        , ppr.SUBPRJ_PPL_ETC_COST_TC
        , ppr.SUBPRJ_PPL_ETC_COST_FC
        , ppr.SUBPRJ_PPL_ETC_COST_PC
        , ppr.SUBPRJ_EQPMT_ETC_COST_TC
        , ppr.SUBPRJ_EQPMT_ETC_COST_FC
        , ppr.SUBPRJ_EQPMT_ETC_COST_PC
        , ppr.SUBPRJ_OTH_ETC_COST_TC + ppr.SUBPRJ_PPL_ETC_COST_TC +     ppr.SUBPRJ_EQPMT_ETC_COST_TC total_subproj_etc_cost_tc
        , ppr.SUBPRJ_OTH_ETC_COST_PC + ppr.SUBPRJ_PPL_ETC_COST_PC +     ppr.SUBPRJ_EQPMT_ETC_COST_PC total_subproj_etc_cost_pc
        , ppr.SUBPRJ_OTH_ETC_COST_FC + ppr.SUBPRJ_PPL_ETC_COST_FC +     ppr.SUBPRJ_EQPMT_ETC_COST_FC total_subproj_etc_cost_fc
        , ppr.SUBPRJ_EARNED_VALUE
        , ppr.CURRENT_FLAG
        , ppr.PROJFUNC_COST_RATE_TYPE
        , ppr.PROJFUNC_COST_EXCHANGE_RATE
        , ppr.PROJFUNC_COST_RATE_DATE
        , ppr.PROJ_COST_RATE_TYPE
        , ppr.PROJ_COST_EXCHANGE_RATE
        , ppr.PROJ_COST_RATE_DATE
        , ppr.TXN_CURRENCY_CODE
        , ppr.PROG_PA_PERIOD_NAME
        , ppr.PROG_GL_PERIOD_NAME
        ,decode(c_task_per_comp_deriv_method,'EFFORT', ( nvl(ppr.PPL_ACT_EFFORT_TO_DATE,0) +    nvl(ppr.EQPMT_ACT_EFFORT_TO_DATE,0)),
                                    ( nvl(ppr.OTH_ACT_COST_TO_DATE_PC,0) + nvl(ppr.PPL_ACT_COST_TO_DATE_PC,0) + nvl(ppr.EQPMT_ACT_COST_TO_DATE_PC,0))  ) earned_value
        , decode(p_wp_rollup_method, 'COST', nvl(ppr.OTH_ACT_COST_TO_DATE_PC,0) + nvl(ppr.PPL_ACT_COST_TO_DATE_PC,0)
                + nvl(ppr.EQPMT_ACT_COST_TO_DATE_PC,0) + nvl(ppr.OTH_ETC_COST_PC,0) +   nvl(ppr.PPL_ETC_COST_PC,0)
                + nvl(ppr.EQPMT_ETC_COST_PC,0), 'EFFORT',       decode(rate_based_flag,'N', 0, nvl(ppr.PPL_ACT_EFFORT_TO_DATE,0)
                + nvl(ppr.EQPMT_ACT_EFFORT_TO_DATE,0) + nvl(ppr.EQPMT_ETC_EFFORT,0) +   nvl(ppr.estimated_remaining_effort,0)), 0) bac_value_in_rollup_method
        ,decode(c_task_per_comp_deriv_method,'EFFORT', ( NVL( decode( asgn.rate_based_flag, 'Y',
                                        decode( asgn.resource_class_code,
                                            'PEOPLE', nvl(ppr.PPL_ACT_EFFORT_TO_DATE,0) + nvl(ppr.estimated_remaining_effort,
                                                 decode( sign(nvl(asgn.planned_quantity,0)-nvl(ppr.PPL_ACT_EFFORT_TO_DATE,0)), -1,      0,
                                                 nvl( asgn.planned_quantity-ppr.PPL_ACT_EFFORT_TO_DATE,0))),
                                            'EQUIPMENT', nvl(ppr.EQPMT_ACT_EFFORT_TO_DATE,0) +  nvl(ppr.EQPMT_ETC_EFFORT,
                                                 decode( sign(nvl(asgn.planned_quantity,0)-nvl(ppr.EQPMT_ACT_EFFORT_TO_DATE,0)), -1,    0,
                                                 nvl( asgn.planned_quantity-ppr.EQPMT_ACT_EFFORT_TO_DATE,0)))),0),0)
                                   ),
                                 ( NVL( decode( asgn.resource_class_code,
                                          'FINANCIAL_ELEMENTS',
                                         nvl(ppr.OTH_ACT_COST_TO_DATE_PC,0) + nvl(ppr.OTH_ETC_COST_PC,
                                            decode( sign(nvl(asgn.planned_bur_cost_proj_cur,0)-nvl(ppr.OTH_ACT_COST_TO_DATE_PC,0)), -1, 0,
                                                 nvl( asgn.planned_bur_cost_proj_cur-ppr.OTH_ACT_COST_TO_DATE_PC,0))),
                                          'MATERIAL_ITEMS',
                                         nvl(ppr.OTH_ACT_COST_TO_DATE_PC,0) + nvl(ppr.OTH_ETC_COST_PC,
                                            decode( sign(nvl(asgn.planned_bur_cost_proj_cur,0)-nvl(ppr.OTH_ACT_COST_TO_DATE_PC,0)), -1, 0,
                                                 nvl( asgn.planned_bur_cost_proj_cur-ppr.OTH_ACT_COST_TO_DATE_PC,0))),
                                          'PEOPLE',
                                        nvl(ppr.PPL_ACT_COST_TO_DATE_PC,0)      + nvl(ppr.PPL_ETC_COST_PC,
                                         decode( sign(nvl(asgn.planned_bur_cost_proj_cur,0)-nvl(ppr.PPL_ACT_COST_TO_DATE_PC,0)), -1, 0,
                                                          nvl(asgn.planned_bur_cost_proj_cur-ppr.PPL_ACT_COST_TO_DATE_PC,0))),
                                          'EQUIPMENT',
                                        nvl(ppr.EQPMT_ACT_COST_TO_DATE_PC,0) + nvl(ppr.EQPMT_ETC_COST_PC,
                                         decode( sign(nvl(asgn.planned_bur_cost_proj_cur,0)-nvl(ppr.EQPMT_ACT_COST_TO_DATE_PC,0)), -1,  0,
                                                          nvl(asgn.planned_bur_cost_proj_cur-ppr.EQPMT_ACT_COST_TO_DATE_PC,0)))),
                                    nvl(asgn.planned_bur_cost_proj_cur,0)
                                    ))
                                          ) bac_value_in_task_deriv
    FROM
                  pa_task_asgmts_v       asgn,
                  pa_progress_rollup ppr
        WHERE asgn.task_version_id      = c_task_ver_id
          AND asgn.project_id = ppr.project_id
          AND asgn.RESOURCE_LIST_MEMBER_ID      = ppr.object_id -- Bug 3764224
          AND asgn.task_id      = ppr.proj_element_id --        Bug 3764224
          AND ppr.object_type = 'PA_ASSIGNMENTS'
  --        AND asgn.ta_display_flag      = 'Y'   --Bug 4323537.
          AND ppr.as_of_date = pa_progress_utils.get_max_rollup_asofdate(asgn.project_id,
                                  asgn.RESOURCE_LIST_MEMBER_ID, 'PA_ASSIGNMENTS',p_as_of_date,asgn.task_version_id, p_structure_type, l_structure_version_id, asgn.task_id)  ---Bug 3764224      -- FPM Dev CR 3
          AND ppr.current_flag <> 'W'
          AND ppr.structure_type        =       p_structure_type
          AND ((l_published_structure   = 'Y' AND       ppr.structure_version_id        is null) OR (l_published_structure      = 'N' AND       ppr.structure_version_id        = p_structure_version_id))
UNION ALL
        SELECT asgn.task_version_id
        , 'PA_TASKS' parent_object_type
        , asgn.resource_assignment_id   object_id_to1 -- Bug 3764224,   ideally this shdould be changes to      RLM id. But keeping     this    as is due       to Scheduling   API behaviour
        , asgn.task_version_id object_id_from1
        , 'PA_ASSIGNMENTS' object_type
        , asgn.resource_class_code
        , asgn.rate_based_flag
        , decode(asgn.rate_based_flag,'Y','EFFORT','N','COST')  assignment_type
        , to_date(null) actual_start_date
        , to_date(null) actual_finish_date
        , to_date(null) estimated_start_date
        , to_date(null) estimated_finish_date
        , to_number(null) ESTIMATED_REMAINING_EFFORT
        , to_number(null) STRUCTURE_VERSION_ID
        , to_char(null) STRUCTURE_TYPE
        , to_number(null) PROJ_ELEMENT_ID
        , to_number(null) PPL_ACT_EFFORT_TO_DATE
        , to_number(null) EQPMT_ACT_EFFORT_TO_DATE
        , to_number(null) total_act_effort_to_date
        , to_number(null) EQPMT_ETC_EFFORT
        , to_number(null) total_etc_effort
        , to_number(null) OTH_ACT_COST_TO_DATE_TC
        , to_number(null) OTH_ACT_COST_TO_DATE_PC
        , to_number(null) OTH_ACT_COST_TO_DATE_FC
        , to_number(null) OTH_ETC_COST_TC
        , to_number(null) OTH_ETC_COST_PC
        , to_number(null) OTH_ETC_COST_FC
        , to_number(null) PPL_ACT_COST_TO_DATE_TC
        , to_number(null) PPL_ACT_COST_TO_DATE_PC
        , to_number(null) PPL_ACT_COST_TO_DATE_FC
        , to_number(null) PPL_ETC_COST_TC
        , to_number(null) PPL_ETC_COST_PC
        , to_number(null) PPL_ETC_COST_FC
        , to_number(null) EQPMT_ACT_COST_TO_DATE_TC
        , to_number(null) EQPMT_ACT_COST_TO_DATE_PC
        , to_number(null) EQPMT_ACT_COST_TO_DATE_FC
        , to_number(null) total_act_cost_to_date_tc
        , to_number(null) total_act_cost_to_date_pc
        , to_number(null) total_act_cost_to_date_fc
        , to_number(null) EQPMT_ETC_COST_TC
        , to_number(null) EQPMT_ETC_COST_PC
        , to_number(null) EQPMT_ETC_COST_FC
        , to_number(null) total_etc_cost_tc
        , to_number(null) total_etc_cost_pc
        , to_number(null) total_etc_cost_fc
--      , ppr.EARNED_VALUE
        , to_number(null) SUBPRJ_PPL_ACT_EFFORT
        , to_number(null) SUBPRJ_EQPMT_ACT_EFFORT
        , to_number(null) SUBPRJ_PPL_ETC_EFFORT
        , to_number(null) SUBPRJ_EQPMT_ETC_EFFORT
        , to_number(null) SUBPRJ_OTH_ACT_COST_TO_DATE_TC
        , to_number(null) SUBPRJ_OTH_ACT_COST_TO_DATE_FC
        , to_number(null) SUBPRJ_OTH_ACT_COST_TO_DATE_PC
        , to_number(null) SUBPRJ_PPL_ACT_COST_TC
        , to_number(null) SUBPRJ_PPL_ACT_COST_FC
        , to_number(null) SUBPRJ_PPL_ACT_COST_PC
        , to_number(null) SUBPRJ_EQPMT_ACT_COST_TC
        , to_number(null) SUBPRJ_EQPMT_ACT_COST_FC
        , to_number(null) SUBPRJ_EQPMT_ACT_COST_PC
        , to_number(null) total_subproj_act_cost_tc
        , to_number(null) total_subproj_act_cost_pc
        , to_number(null) total_subproj_act_cost_fc
        , to_number(null) SUBPRJ_OTH_ETC_COST_TC
        , to_number(null) SUBPRJ_OTH_ETC_COST_FC
        , to_number(null) SUBPRJ_OTH_ETC_COST_PC
        , to_number(null) SUBPRJ_PPL_ETC_COST_TC
        , to_number(null) SUBPRJ_PPL_ETC_COST_FC
        , to_number(null) SUBPRJ_PPL_ETC_COST_PC
        , to_number(null) SUBPRJ_EQPMT_ETC_COST_TC
        , to_number(null) SUBPRJ_EQPMT_ETC_COST_FC
        , to_number(null) SUBPRJ_EQPMT_ETC_COST_PC
        , to_number(null) total_subproj_etc_cost_tc
        , to_number(null) total_subproj_etc_cost_pc
        , to_number(null) total_subproj_etc_cost_fc
        , to_number(null) SUBPRJ_EARNED_VALUE
        , to_char(null) CURRENT_FLAG
        , to_char(null) PROJFUNC_COST_RATE_TYPE
        , to_number(null) PROJFUNC_COST_EXCHANGE_RATE
        , to_date(null) PROJFUNC_COST_RATE_DATE
        , to_char(null) PROJ_COST_RATE_TYPE
        , to_number(null) PROJ_COST_EXCHANGE_RATE
        , to_date(null) PROJ_COST_RATE_DATE
        , to_char(null) TXN_CURRENCY_CODE
        , to_char(null) PROG_PA_PERIOD_NAME
        , to_char(null) PROG_GL_PERIOD_NAME
        , to_number(null) earned_value
        , to_number(null) bac_value_in_rollup_method
--        , decode(c_task_per_comp_deriv_method,'EFFORT',decode(asgn.rate_based_flag,'Y',asgn.planned_quantity,0),asgn.planned_quantity) bac_value_in_task_deriv --3801780
--bug 3815252
   ,    decode(c_task_per_comp_deriv_method,'EFFORT',decode(asgn.rate_based_flag,'Y',
                                 decode(asgn.resource_class_code,'PEOPLE', asgn.planned_quantity, 'EQUIPMENT', asgn.planned_quantity, 0),0)
                                ,asgn.planned_bur_cost_proj_cur) bac_value_in_task_deriv --3801780
    FROM
                  pa_task_asgmts_v       asgn
        WHERE asgn.task_version_id      = c_task_ver_id
        AND     pa_progress_utils.get_max_rollup_asofdate(asgn.project_id,
                                  asgn.RESOURCE_LIST_MEMBER_ID, 'PA_ASSIGNMENTS',p_as_of_date,asgn.task_version_id, p_structure_type, l_structure_version_id, asgn.task_id   )   --- Bug 3764224
                        IS NULL
          --bug 3958686, now hidden assignments should not      to be selected
    --      AND asgn.ta_display_flag      = 'Y'  -- Bug 4323537
        ; */

-- FPM Dev CR 5 : Reverted back the outer       join
-- FPM Dev CR 4 : Removed       Outer   Join    from    rollup table.   No need to select       deliverables which do   not have rollup records
   --This       cursor selects  the deliverables of     a given task.
   CURSOR cur_deliverables(c_task_proj_elem_id NUMBER,    c_task_ver_id NUMBER, c_project_id      NUMBER)
   IS
        SELECT obj.object_type_from
        , 'PA_TASKS' parent_object_type
        ,       obj.object_id_to2 object_id
        ,       obj.object_id_to1
        ,       obj.object_id_from1
        , 'PA_DELIVERABLES'     object_type
        , ppr.actual_finish_date
        , ppr.as_of_date
        , ppr.completed_percentage
        , ppr.STRUCTURE_TYPE
        , ppr.PROJ_ELEMENT_ID
        , ppr.STRUCTURE_VERSION_ID
        , ppr.TASK_WT_BASIS_CODE
        , elem.progress_weight weighting_percentage
        , ppr.base_percent_complete
        , pps2.project_status_weight override_weight    ---override progress status code
        , pps3.project_status_weight base_weight          --base prog status
    FROM pa_proj_elements elem
    , pa_object_relationships   obj
    , pa_progress_rollup        ppr
    , pa_project_statuses pps2
    , pa_project_statuses pps3
        WHERE  obj.object_id_from2= c_task_proj_elem_id
        AND obj.object_type_from        =       'PA_TASKS'
        AND obj.object_type_to =        'PA_DELIVERABLES'
        AND obj.relationship_type = 'A'
        AND obj.relationship_subtype = 'TASK_TO_DELIVERABLE'
        AND elem.proj_element_id        =       obj.object_id_to2
        AND elem.object_type = 'PA_DELIVERABLES'
        and elem.project_id     = p_project_id
--        AND obj.object_id_to1 = ppr.object_version_id(+)
        AND ppr.object_type(+) =        'PA_DELIVERABLES'
        AND ppr.project_id(+) = c_project_id
        AND ppr.object_id(+) = obj.object_id_to2
        AND ppr.as_of_date(+) = pa_progress_utils.get_max_rollup_asofdate(c_project_id,
                                  obj.object_id_to2, 'PA_DELIVERABLES',p_as_of_date,obj.object_id_to1, p_structure_type, l_structure_version_id, obj.object_id_from2 /* Bug     3764224 */) --  FPM Dev CR 3
        AND ppr.structure_type(+) = p_structure_type
        AND ppr.structure_version_id is null -- deliverable progress for        working version is not allowed
        AND ppr.base_progress_status_code = pps3.project_status_code(+)
        AND ppr.progress_status_code = pps2.project_status_code(+)
        AND ppr.current_flag(+) <>      'W'
        ;

    CURSOR c_mass_rollup_tasks IS
    select distinct object_id_from1
    from    pa_object_relationships
    start with  object_id_to1 IN (select object_id from pa_proj_rollup_temp  where process_number = l_process_number_temp)
    and relationship_type = 'S'
    connect by prior object_id_from1 = object_id_to1
    and relationship_type = 'S'
    MINUS
    select object_id object_id_from1 from pa_proj_rollup_temp  where process_number = l_process_number_temp
    ;

    CURSOR c_mass_rollup_tasks_temp IS
    select object_id
    from pa_proj_rollup_temp where process_number = l_process_number_temp
        ;

   CURSOR cur_check_published_version(c_structure_version_id number, c_project_id number)
   IS
   SELECT decode(status.project_system_status_code, 'STRUCTURE_PUBLISHED','Y','N')
   FROM pa_proj_elem_ver_structure str
   ,    pa_project_statuses     status
   where str.element_version_id = c_structure_version_id
   AND str.project_id = c_project_id
   AND str.status_code =        status.project_status_code;

   CURSOR cur_get_deepest_task(c_structure_version_id number, c_project_id number)
   IS
   SELECT element_version_id
   FROM pa_proj_element_versions
   where project_id = c_project_id
   and object_type = 'PA_TASKS'
   AND parent_structure_version_id      = c_structure_version_id
   AND wbs_level = (Select max(wbs_level)
                  From pa_proj_element_versions
                  where project_id = c_project_id
                  and object_type =     'PA_TASKS'
                  AND parent_structure_version_id = c_structure_version_id);

l_track_wp_cost_flag            VARCHAR2(1) :=  'Y';    --bug 3830434
l_assignment_exists      VARCHAR2(1) ;  -- Bug 3830673
l_digit_number           number; --BUG  3950574,        rtarway

--bug 4045979,  start
l_base_struct_ver_id NUMBER;

CURSOR check_task_baselined(c_structure_ver_id NUMBER,  c_task_version_id NUMBER)
IS
  select 'Y' from pa_proj_element_versions ppev1
  where ppev1.parent_structure_version_id = c_structure_ver_id
  and ppev1.proj_element_id =   (select proj_element_id from pa_proj_element_versions ppev2
                                  where ppev2.element_version_id =      c_task_version_id
                                  and ppev2.project_id =        p_project_id);

l_task_baselined VARCHAR2(1) := 'N';
l_parent_task_baselined VARCHAR2(1) :=  'N';

--bug 4045979,  end

l_tsk_progress_exists VARCHAR2(1);
l_mapping_tasks_to_rollup_tab   PA_PLSQL_DATATYPES.NumTabTyp;

-- Bug 4242787 : Added Cursor cur_tree_rollup_dates
CURSOR cur_tree_rollup_dates
IS
select ppr.as_of_date, ver2.proj_element_id child_task_id, ver2.element_version_id child_task_ver_id
from pa_object_relationships obj
, pa_proj_element_versions ver
, pa_progress_rollup ppr
, pa_proj_rollup_temp rollup
, pa_proj_element_versions ver2
where rollup.object_id = obj.object_id_to1
AND rollup.process_number = l_process_number_temp
AND obj.relationship_type = 'S'
AND obj.object_type_from IN ('PA_STRUCTURES' ,'PA_TASKS')
AND obj.object_type_to = 'PA_TASKS'
AND obj.object_id_from1= ver.element_version_id
AND ver.project_id = p_project_id
AND ver.object_type IN ('PA_TASKS', 'PA_STRUCTURES')
AND ver.project_id = ppr.project_id
AND ppr.as_of_date > p_as_of_date
AND ppr.object_id = ver.proj_element_id
AND ppr.current_flag = 'Y'
AND ppr.proj_element_id = ver.proj_element_id
AND ppr.structure_type = p_structure_type
AND ppr.structure_version_id is null
AND obj.object_id_to1 = ver2.element_version_id
AND ver2.project_id = p_project_id
AND ver2.object_type = 'PA_TASKS'
AND rollup.object_type = 'PA_TASKS' --  cklee bug: 6610612
order by ppr.as_of_date;


-- Bug 4392189 Begin
CURSOR c_get_sub_project (c_task_version_id NUMBER, c_task_per_comp_deriv_method VARCHAR2) IS
SELECT
  ppv2.project_id                     sub_project_id
 ,ppv2.element_version_id             sub_structure_ver_id
 ,ppv2.proj_element_id                sub_proj_element_id
, pa_progress_utils.Get_BAC_Value(ppv2.project_id, c_task_per_comp_deriv_method,  ppv2.proj_element_id,  ppv2.parent_structure_version_id,
                                    'WORKPLAN','N')    sub_project_bac_value
FROM
     pa_proj_element_versions ppv2
    ,pa_proj_elem_ver_structure ppevs2
    ,pa_object_relationships por1
    ,pa_object_relationships por2
WHERE
  por1.object_id_from1 = c_task_version_id
 AND por1.object_id_to1 = por2.object_id_from1
 AND por2.object_id_to1 = ppv2.element_version_id
 AND ppv2.object_type = 'PA_STRUCTURES'
-- AND por2.relationship_type in ( 'LW', 'LF' )
 AND por2.relationship_type = 'LW'
 AND ppevs2.element_version_id = ppv2.element_version_id
 AND ppevs2.project_id = ppv2.project_id
 AND ppevs2.status_code = 'STRUCTURE_PUBLISHED'
 AND ppevs2.latest_eff_published_flag = 'Y';

l_sub_project_id    NUMBER;
l_sub_structure_ver_id  NUMBER;
l_sub_proj_element_id   NUMBER;
l_sub_project_bac_value NUMBER;

CURSOR c_get_sub_project_progress (c_sub_project_id NUMBER, c_sub_str_version_id NUMBER, c_sub_proj_element_id NUMBER
, c_as_of_date Date, c_task_per_comp_deriv_method VARCHAR2) IS
SELECT
ppr.progress_rollup_id
,ppr.actual_start_date
,ppr.actual_finish_date
,ppr.estimated_start_date
,ppr.estimated_finish_date
,pps1.project_status_weight rollup_weight1
,pps2.project_status_weight override_weight2
,pps3.project_status_weight base_weight3
,pps4.project_status_weight task_weight4
-- Bug 4506009 --,decode(c_task_per_comp_deriv_method,'EFFORT', ( nvl(ppr.PPL_ACT_EFFORT_TO_DATE,0) + nvl(ppr.EQPMT_ACT_EFFORT_TO_DATE,0)),
--                                    ( nvl(ppr.OTH_ACT_COST_TO_DATE_PC,0) + nvl(ppr.PPL_ACT_COST_TO_DATE_PC,0) + nvl(ppr.EQPMT_ACT_COST_TO_DATE_PC,0))) earned_value
,decode(c_task_per_comp_deriv_method,'EFFORT', nvl(ppr.PPL_ACT_EFFORT_TO_DATE,0) + nvl(ppr.estimated_remaining_effort,0) + nvl(ppr.EQPMT_ACT_EFFORT_TO_DATE,0) +  nvl(ppr.EQPMT_ETC_EFFORT,0)
        , nvl(ppr.OTH_ACT_COST_TO_DATE_PC,0) + nvl(ppr.OTH_ETC_COST_PC,0) +  nvl(ppr.PPL_ACT_COST_TO_DATE_PC,0) + nvl(ppr.PPL_ETC_COST_PC,0) +  nvl(ppr.EQPMT_ACT_COST_TO_DATE_PC,0) + nvl(ppr.EQPMT_ETC_COST_PC,0)) bac_value
, nvl(ppr.completed_percentage, ppr.eff_rollup_percent_comp) completed_percentage --Bug 4506009
FROM
pa_progress_rollup ppr
,pa_project_statuses pps1
,pa_project_statuses pps2
,pa_project_statuses pps3
,pa_project_statuses pps4
,pa_proj_elements ppe
WHERE
ppr.project_id = c_sub_project_id
AND ppe.project_id = c_sub_project_id
AND ppe.object_type = 'PA_STRUCTURES'
AND ppe.proj_element_id = c_sub_proj_element_id
AND ppr.object_id = c_sub_proj_element_id
AND ppr.object_type = 'PA_STRUCTURES'
AND ppr.structure_version_id is null
AND ppr.structure_type = 'WORKPLAN'
AND ppr.current_flag IN ('Y', 'N')
AND ppr.as_of_date <= c_as_of_date
AND ppr.EFF_ROLLUP_PROG_STAT_CODE = pps1.project_status_code(+)
AND ppr.progress_status_code =  pps2.project_status_code(+)
AND ppr.base_progress_status_code = pps3.project_status_code(+)
AND ppe.status_code = pps4.project_status_code(+)
order by as_of_date desc
 ;


l_subproj_prog_rollup_id    NUMBER;
l_subproj_act_start_date    DATE;
l_subproj_act_finish_date   DATE;
l_subproj_est_start_date    DATE;
l_subproj_est_finish_date   DATE;
l_subproj_rollup_weight1    NUMBER;
l_subproj_override_weight2  NUMBER;
l_subproj_base_weight3      NUMBER;
l_subproj_task_weight4      NUMBER;
l_subproj_earned_value      NUMBER;
l_subproj_bac_value     NUMBER;
l_subproj_comp_percentage       NUMBER; --Bug 4506009
l_actual_lowest_task        VARCHAR2(1) := 'N';
-- Bug 4392189 End

l_summary_object_flag       VARCHAR2(1); -- 4370746

-- Bug 4506461 Begin
CURSOR c_get_any_childs_have_subprj(c_task_version_id NUMBER) IS
SELECT 'Y'
FROM pa_object_relationships
WHERE --relationship_type in ( 'LW', 'LF' )
relationship_type = 'LW'
AND object_id_from1 IN
    (SELECT object_id_to1
    FROM pa_object_relationships
    START WITH  object_id_from1 = c_task_version_id
    AND relationship_type = 'S'
    CONNECT BY PRIOR object_id_to1 = object_id_from1
    AND relationship_type = 'S')
    ;
l_subproject_found VARCHAR2(1):='N';
l_rederive_base_pc VARCHAR2(1):='N';
-- Bug 4506461 End

l_last_as_of_date   DATE;--4573257
l_subproj_task_version_id NUMBER;--4582956
l_org_id NUMBER; -- 4746476
BEGIN

        -- Rollup       Cases
        -- 1. Workplan  Publsihed       Version Rollup.
        -- 2. Workplan  Working Version Rollup.
        -- 3. Financial Structure       Rollup.
        -- 4. Entire WBS using structure version id.
        -- 5. Program Rollup


        g1_debug_mode := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',fnd_global.user_id,fnd_global.login_id,275,null,null), 'N');

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.init_err_stack ('PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT');
        END IF;


        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT Start : Passed Parameters :', x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'p_init_msg_list='||p_init_msg_list, x_Log_Level=>     3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'p_commit='||p_commit, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'p_validate_only='||p_validate_only, x_Log_Level=>     3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'p_validation_level='||p_validation_level, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'p_calling_module='||p_calling_module, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'p_calling_mode='||p_calling_mode, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'p_debug_mode='||p_debug_mode, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'p_max_msg_count='||p_max_msg_count, x_Log_Level=>     3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'p_project_id='||p_project_id, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'P_OBJECT_TYPE='||P_OBJECT_TYPE, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'P_OBJECT_ID='||P_OBJECT_ID, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'p_object_version_id='||p_object_version_id, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'p_task_version_id='||p_task_version_id,       x_Log_Level=>   3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'p_as_of_date='||p_as_of_date, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'p_lowest_level_task='||p_lowest_level_task, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'p_process_whole_tree='||p_process_whole_tree, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'p_structure_version_id='||p_structure_version_id,     x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'p_structure_type='||p_structure_type, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'p_fin_rollup_method='||p_fin_rollup_method, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'p_wp_rollup_method='||p_wp_rollup_method, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'p_rollup_entire_wbs='||p_rollup_entire_wbs, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'p_upd_new_elem_ver_id_flag'||p_upd_new_elem_ver_id_flag, x_Log_Level=> 3);
        END IF;

        -- 20 May : Amit : If Structure_version_id is null, then no rocessing shd  be done
        --      Bug 3856161 : Added     p_as_of_date check also
        IF p_structure_version_id IS NULL OR (p_as_of_date IS NULL OR p_as_of_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE ) THEN
                return;
        END IF;

        --bug 4045979
        l_base_struct_ver_id := pa_project_structure_utils.get_baseline_struct_ver(p_project_id);

        --BUG 4355204, rtarway
        --IF (p_commit =  FND_API.G_TRUE) THEN
                savepoint ROLLUP_PROGRESS_PVT2;
        --END IF;

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE))     THEN
                FND_MSG_PUB.initialize;
        END IF;

        l_sharing_Enabled := PA_PROJECT_STRUCTURE_UTILS.check_sharing_enabled(p_project_id);
        l_track_wp_cost_flag :=  pa_fp_wp_gen_amt_utils.get_wp_track_cost_amt_flag(p_project_id);  --bug 3830434
    -- 4746476 : added org_id in below select
    SELECT project_currency_code, org_id INTO l_prj_currency_code, l_org_id FROM pa_projects_all WHERE project_id = p_project_id;

        IF l_sharing_Enabled = 'N' AND p_structure_type = 'WORKPLAN' THEN
                l_split_workplan := 'Y';
        ELSE
                l_split_workplan := 'N';
        END IF;

	-- Bug 4938333
	-- In case of financial struture, no need to check for published version
	-- populate structure_version_id always null.
	IF p_structure_type = 'WORKPLAN' THEN -- Bug 4938333

		-- This is to find out  whether passed  struture version id     is published or not.
		-- bcoz progress for workplna workplan version also exists

		OPEN  cur_check_published_version(p_structure_version_id, p_project_id);
		FETCH cur_check_published_version INTO l_published_structure;
		CLOSE cur_check_published_version;

		IF l_published_structure = 'Y' THEN
			l_structure_version_id := null;
		ELSE
			l_structure_version_id := p_structure_version_id;
		END IF;
	ELSE -- Bug 4938333
		l_published_structure := 'Y'; -- Bug 4938333
                l_structure_version_id := null; -- Bug 4938333
	END IF;

        l_task_version_id := p_task_version_id;

        IF p_structure_type = 'WORKPLAN' THEN
                l_rollup_method := p_wp_rollup_method;
        ELSE
                l_rollup_method := p_fin_rollup_method;
        END IF;

        IF g1_debug_mode  =     'Y'     THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_sharing_Enabled='||l_sharing_Enabled,       x_Log_Level=>   3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_split_workplan='||l_split_workplan, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_published_structure='||l_published_structure, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_task_version_id='||l_task_version_id,       x_Log_Level=>   3);
        END IF;

        --l_lowest_task := p_lowest_task;
        -- Loop thru all the parents of the passed task

        SELECT PA_PROJ_ROLLUP_TEMP_S.nextval
        INTO  l_process_number_temp FROM dual;

    IF p_rollup_entire_wbs = 'N' THEN
                INSERT INTO pa_proj_rollup_temp(process_number, object_id, object_type, wbs_level)
                SELECT distinct l_process_number_temp, object_id_from1, 'PA_TASKS', 1
                FROM pa_object_relationships
                WHERE relationship_type = 'S'
                START WITH object_id_to1 = l_task_version_id
                AND relationship_type = 'S'
                CONNECT BY PRIOR object_id_from1 = object_id_to1
                AND relationship_type = 'S'
        UNION ALL -- 4563049 : Rollup Structure also if passed, so that it can populate ETC from PJI
        SELECT distinct l_process_number_temp, l_task_version_id object_id_from1, 'PA_TASKS', 1
        FROM dual
        WHERE l_task_version_id = p_structure_version_id
        ;
        ELSE
        IF g1_debug_mode = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'Mass Rollup Case', x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'p_task_version_id_tbl.count='||p_task_version_id_tbl.count, x_Log_Level=> 3);
            FOR i in 1..p_task_version_id_tbl.count LOOP
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'p_task_version_id_tbl(i)='||p_task_version_id_tbl(i), x_Log_Level=> 3);
            END LOOP;
        END IF;

                IF p_task_version_id_tbl.count > 0 THEN
                        FORALL i in 1..p_task_version_id_tbl.count
                                INSERT INTO pa_proj_rollup_temp(process_number, object_id, object_type, wbs_level)
                                VALUES(l_process_number_temp,p_task_version_id_tbl(i),  'PA_TASKS',1 );

                        l_mass_rollup_prog_rec_tab.delete;
                        OPEN  c_mass_rollup_tasks;
                        FETCH c_mass_rollup_tasks BULK COLLECT INTO l_mass_rollup_prog_rec_tab;
                        CLOSE c_mass_rollup_tasks;

            FORALL i IN 1..l_mass_rollup_prog_rec_tab.COUNT
              INSERT INTO PA_PROJ_ROLLUP_TEMP(
                PROCESS_NUMBER,
                OBJECT_TYPE,
                OBJECT_ID,
                wbs_level)
              VALUES(l_process_number_temp, 'PA_TASKS',l_mass_rollup_prog_rec_tab(i), 1);

            l_mass_rollup_prog_rec_tab.delete;
                ELSE
                        INSERT INTO pa_proj_rollup_temp(process_number, object_id, object_type, wbs_level)
                        SELECT l_process_number_temp,   element_version_id object_id_from1, 'PA_TASKS', 1
                        FROM pa_proj_element_versions
                        WHERE project_id = p_project_id
                        AND parent_structure_version_id = p_structure_version_id
                        --AND PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(element_version_id) = 'N'
            -- 4490532 : changed from IS_LOWEST_TASK to is_summary_task_or_structure
            AND PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(element_version_id) = 'Y'
                        AND object_type = 'PA_TASKS'
                        UNION
                        SELECT l_process_number_temp, p_structure_version_id object_id_from1, 'PA_TASKS', 1
                        FROM dual
                        ;
                END IF;
        END IF;

    IF g1_debug_mode = 'Y' THEN
        l_mass_rollup_prog_rec_tab.delete;
                OPEN  c_mass_rollup_tasks_temp;
                FETCH c_mass_rollup_tasks_temp BULK COLLECT INTO l_mass_rollup_prog_rec_tab;
                CLOSE c_mass_rollup_tasks_temp;
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg =>'l_mass_rollup_prog_rec_tab.count='||l_mass_rollup_prog_rec_tab.count, x_Log_Level=> 3);
        FOR i in 1..l_mass_rollup_prog_rec_tab.count loop
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg =>'l_mass_rollup_prog_rec_tab(i)='||l_mass_rollup_prog_rec_tab(i), x_Log_Level=> 3);
        END LOOP;
        l_mass_rollup_prog_rec_tab.delete;

        END IF;


    OPEN cur_tasks(1);
    FETCH cur_tasks BULK COLLECT INTO
    l_tsk_object_id_from1_tab
    ,l_tsk_parent_object_type_tab
    ,l_tsk_object_id_to1_tab
    ,l_tsk_object_type_tab
    ,l_tsk_wbs_level_tab
    ,l_tsk_weighting_percent_tab
    ,l_tsk_roll_comp_percent_tab
    ,l_tsk_over_percent_comp_tab
    ,l_tsk_as_of_date_tab
    ,l_tsk_actual_start_date_tab
    ,l_tsk_actual_finish_date_tab
    ,l_tsk_est_start_date_tab
    ,l_tsk_est_finish_date_tab
    ,l_tsk_rollup_weight1_tab
    ,l_tsk_override_weight2_tab
    ,l_tsk_base_weight3_tab
    ,l_tsk_task_weight4_tab
    ,l_tsk_status_code_tab
    ,l_tsk_object_id_tab
    ,l_tsk_proj_element_id_tab
    ,l_tsk_PPL_ACT_EFF_tab
    ,l_tsk_PPL_ACT_COST_TC_tab
    ,l_tsk_PPL_ACT_COST_PC_tab
    ,l_tsk_PPL_ACT_COST_FC_tab
    ,l_tsk_PPL_ACT_RAWCOST_TC_tab
    ,l_tsk_PPL_ACT_RAWCOST_PC_tab
    ,l_tsk_PPL_ACT_RAWCOST_FC_tab
    ,l_tsk_EST_REM_EFFORT_tab
    ,l_tsk_PPL_ETC_COST_TC_tab
    ,l_tsk_PPL_ETC_COST_PC_tab
    ,l_tsk_PPL_ETC_COST_FC_tab
    ,l_tsk_PPL_ETC_RAWCOST_TC_tab
    ,l_tsk_PPL_ETC_RAWCOST_PC_tab
    ,l_tsk_PPL_ETC_RAWCOST_FC_tab
    ,l_tsk_EQPMT_ACT_EFFORT_tab
    ,l_tsk_EQPMT_ACT_COST_TC_tab
    ,l_tsk_EQPMT_ACT_COST_PC_tab
    ,l_tsk_EQPMT_ACT_COST_FC_tab
    ,l_tsk_EQPMT_ACT_RAWCOST_TC_tab
    ,l_tsk_EQPMT_ACT_RAWCOST_PC_tab
    ,l_tsk_EQPMT_ACT_RAWCOST_FC_tab
    ,l_tsk_EQPMT_ETC_EFFORT_tab
    ,l_tsk_EQPMT_ETC_COST_TC_tab
    ,l_tsk_EQPMT_ETC_COST_PC_tab
    ,l_tsk_EQPMT_ETC_COST_FC_tab
    ,l_tsk_EQPMT_ETC_RAWCOST_TC_tab
    ,l_tsk_EQPMT_ETC_RAWCOST_PC_tab
    ,l_tsk_EQPMT_ETC_RAWCOST_FC_tab
    ,l_tsk_OTH_QUANTITY_tab
    ,l_tsk_OTH_ACT_COST_TC_tab
    ,l_tsk_OTH_ACT_COST_PC_tab
    ,l_tsk_OTH_ACT_COST_FC_tab
    ,l_tsk_OTH_ACT_RAWCOST_TC_tab
    ,l_tsk_OTH_ACT_RAWCOST_PC_tab
    ,l_tsk_OTH_ACT_RAWCOST_FC_tab
    ,l_tsk_OTH_ETC_QUANTITY_tab
    ,l_tsk_OTH_ETC_COST_TC_tab
    ,l_tsk_OTH_ETC_COST_PC_tab
    ,l_tsk_OTH_ETC_COST_FC_tab
    ,l_tsk_OTH_ETC_RAWCOST_TC_tab
    ,l_tsk_OTH_ETC_RAWCOST_PC_tab
    ,l_tsk_OTH_ETC_RAWCOST_FC_tab
    ,l_tsk_CURRENT_FLAG_tab
    ,l_tsk_PF_COST_RATE_TYPE_tab
    ,l_tsk_PF_COST_EXC_RATE_tab
    ,l_tsk_PF_COST_RATE_DATE_tab
    ,l_tsk_P_COST_RATE_TYPE_tab
    ,l_tsk_P_COST_EXC_RATE_tab
    ,l_tsk_P_COST_RATE_DATE_tab
    ,l_tsk_TXN_CURRENCY_CODE_tab
    ,l_tsk_PROG_PA_PERIOD_NAME_tab
    ,l_tsk_PROG_GL_PERIOD_NAME_tab
    ,l_tsk_bac_value_tab
    ,l_tsk_bac_self_value_tab -- Bug 4493105
    ,l_tsk_earned_value_tab
    ,l_tsk_deriv_method_tab
    ,l_tsk_progress_rollup_id_tab
    ,l_tsk_rollup_rec_ver_num_tab
    ,l_tsk_object_version_id_tab
    ,l_tsk_progress_stat_code_tab
    ,l_tsk_incremental_wq_tab
    ,l_tsk_cumulative_wq_tab
    ,l_tsk_base_prog_stat_code_tab
    ,l_tsk_eff_roll_prg_st_code_tab
    ,l_tsk_percent_complete_id_tab
    ,l_tsk_task_wt_basis_code_tab
    ,l_tsk_structure_version_id_tab
    ,l_tsk_create_required
    ,l_tsk_update_required
    ,l_tsk_base_percent_comp_tab -- 4392189 : Program Reporting Changes - Phase 2
         ;
    CLOSE cur_tasks;

        DELETE from pa_proj_rollup_temp where process_number= l_process_number_temp;

    IF g1_debug_mode = 'Y' THEN
              pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg =>'l_tsk_object_id_to1_tab.count='||l_tsk_object_id_to1_tab.count, x_Log_Level=> 3);
        END IF;


    FOR k in 1..l_tsk_object_id_to1_tab.count LOOP
	-- Bug 4636100 Issue 2 : Added following if
	-- The intention of this IF is to just pass the structure level record
	-- to scheduling API. Note that in structure case, we just pass one level
	-- records below say task A, and if that below task A has an assignment, it will calculate
	-- wrong % complete because we are not sending A's childs
	IF (   (nvl(l_task_version_id,-11) <> nvl(p_structure_version_id,-12))
	     OR(p_rollup_entire_wbs = 'N' AND nvl(l_task_version_id,-11) = nvl(p_structure_version_id,-12) AND l_tsk_object_id_to1_tab(k) = p_structure_version_id)
	     OR (p_rollup_entire_wbs = 'Y')
	    )
	THEN

        IF g1_debug_mode = 'Y' THEN
                  pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg =>'l_tsk_object_id_to1_tab('||k||')='||l_tsk_object_id_to1_tab(k), x_Log_Level=> 3);
                  pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg =>'l_tsk_deriv_method_tab('||k||')='||l_tsk_deriv_method_tab(k), x_Log_Level=> 3);
                  pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg =>'l_tsk_base_prog_stat_code_tab('||k||')='||l_tsk_base_prog_stat_code_tab(k), x_Log_Level=> 3);
                END IF;
                l_tsk_progress_exists := 'N';
                l_parent_count := l_parent_count + 1;
                l_action_allowed := PA_PROJ_ELEMENTS_UTILS.CHECK_TASK_STUS_ACTION_ALLOWED( l_tsk_status_code_tab(k), 'PROGRESS_ROLLUP' );
                l_summary_object_flag := PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(l_tsk_object_id_to1_tab(k)); -- 4370746


                IF g1_debug_mode = 'Y' THEN
                         pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT',x_Msg => 'l_action_allowed='||l_action_allowed, x_Log_Level=> 3);
                         pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT',x_Msg => 'l_summary_object_flag='||l_summary_object_flag, x_Log_Level=> 3);
                END IF;

        -- Bug 4392189 : Program Changes Begin
        IF l_published_structure = 'Y' AND p_structure_type = 'WORKPLAN' THEN
            l_sub_project_id := null;
            l_subproj_prog_rollup_id := null;
            l_subproj_act_start_date := null;
            l_subproj_act_finish_date := null;
            l_subproj_est_start_date := null;
            l_subproj_est_finish_date := null;
            l_subproj_rollup_weight1 := null;
            l_subproj_override_weight2 := null;
            l_subproj_base_weight3 := null;
            l_subproj_task_weight4 := null;
            l_subproj_earned_value := null;
            l_subproj_bac_value := null;

            -- 4587527 : It was not supporting multiple sub projects at link task
            -- So converted it into FOR LOOP
            FOR rec_subproj IN c_get_sub_project(l_tsk_object_id_to1_tab(k),l_tsk_deriv_method_tab(k)) LOOP


                --OPEN c_get_sub_project (l_tsk_object_id_to1_tab(k),l_tsk_deriv_method_tab(k));
                --FETCH c_get_sub_project INTO l_sub_project_id, l_sub_structure_ver_id, l_sub_proj_element_id, l_sub_project_bac_value;
                --CLOSE c_get_sub_project;

                --IF l_sub_project_id IS NOT NULL THEN
                IF g1_debug_mode = 'Y' THEN
                     pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT',x_Msg => 'rec_subproj.sub_project_id='||rec_subproj.sub_project_id, x_Log_Level=> 3);
                     pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT',x_Msg => 'rec_subproj.sub_structure_ver_id='||rec_subproj.sub_structure_ver_id, x_Log_Level=> 3);
                     pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT',x_Msg => 'rec_subproj.sub_proj_element_id='||rec_subproj.sub_proj_element_id, x_Log_Level=> 3);
                     pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT',x_Msg => 'rec_subproj.sub_project_bac_value='||rec_subproj.sub_project_bac_value, x_Log_Level=> 3);
                END IF;
                l_subproject_found := 'Y'; -- Bug 4506461
                l_subproj_task_version_id := l_tsk_object_id_to1_tab(k);--4582956
                IF l_tsk_object_id_to1_tab(k) = p_task_version_id THEN
                    l_actual_lowest_task := 'Y';
                END IF;

                l_subproj_prog_rollup_id    := null;
                l_subproj_act_start_date    := null;
                l_subproj_act_finish_date   := null;
                l_subproj_est_start_date    := null;
                l_subproj_est_finish_date   := null;
                l_subproj_rollup_weight1    := null;
                l_subproj_override_weight2  := null;
                l_subproj_base_weight3      := null;
                l_subproj_task_weight4      := null;
                l_subproj_bac_value     := null;
                l_subproj_comp_percentage   := null;

                OPEN c_get_sub_project_progress (rec_subproj.sub_project_id, rec_subproj.sub_structure_ver_id, rec_subproj.sub_proj_element_id, p_as_of_date, l_tsk_deriv_method_tab(k));
                FETCH c_get_sub_project_progress INTO
                  l_subproj_prog_rollup_id
                , l_subproj_act_start_date
                , l_subproj_act_finish_date
                , l_subproj_est_start_date
                , l_subproj_est_finish_date
                , l_subproj_rollup_weight1
                , l_subproj_override_weight2
                , l_subproj_base_weight3
                , l_subproj_task_weight4
                --, l_subproj_earned_value Bug 4506009
                , l_subproj_bac_value
                , l_subproj_comp_percentage -- Bug 4506009
                ;
                CLOSE c_get_sub_project_progress;

                IF g1_debug_mode = 'Y' THEN
                     pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT',x_Msg => 'l_subproj_prog_rollup_id='||l_subproj_prog_rollup_id, x_Log_Level=> 3);
                END IF;

                l_index := l_index + 1;

                l_rollup_table1(l_index).OBJECT_TYPE                    := 'PA_SUBPROJECTS';
                l_rollup_table1(l_index).OBJECT_ID                      := (-1 * l_index);
                l_rollup_table1(l_index).PARENT_OBJECT_TYPE             := 'PA_TASKS';
                l_rollup_table1(l_index).PARENT_OBJECT_ID               := l_tsk_object_id_to1_tab(k);
                l_rollup_table1(l_index).WBS_LEVEL                      := 9999999; --  Assigning some value so that order by in   scheduling API  works
                l_rollup_table1(l_index).CALENDAR_ID                    := l_index;

		-- 4533112 : Added following check
		IF nvl(l_tsk_base_prog_stat_code_tab(k), 'N') <> 'Y' THEN
			l_rollup_table1(l_index).START_DATE1			:= l_subproj_act_start_date;
			l_rollup_table1(l_index).FINISH_DATE1                   := l_subproj_act_finish_date;
			l_rollup_table1(l_index).START_DATE2                    := l_subproj_est_start_date;
			l_rollup_table1(l_index).FINISH_DATE2                   := l_subproj_est_finish_date;
		END IF;

                -- 4582956 Begin : LInk task should be treated as summaru task which means
                -- we should be passing % complete of sub project and bac value of sub project
                /*

                -- Bug 4563049 : Do not take l_subproj_bac_value as it may be 0 if actuals and etc is not there
                -- This is additional sefety fix

                -- Bug 4506009 : Deriving l_subproj_earned_value
                IF l_tsk_deriv_method_tab(k) = 'EFFORT' THEN
                    --l_subproj_earned_value := nvl(round((NVL(l_subproj_bac_value, NVL(l_sub_project_bac_value, 0))*nvl(l_subproj_comp_percentage,0)/100), 5),0);
                    -- 4579654 : For more accuracy, Do not round the earned value here.
                    --l_subproj_earned_value := nvl(round((NVL(l_sub_project_bac_value, 0)*nvl(l_subproj_comp_percentage,0)/100), 5),0);
                    l_subproj_earned_value := nvl((NVL(l_sub_project_bac_value, 0)*nvl(l_subproj_comp_percentage,0)/100),0);
                ELSE
                    --l_subproj_earned_value := nvl(pa_currency.round_trans_currency_amt((NVL(l_subproj_bac_value, NVL(l_sub_project_bac_value, 0))*nvl(l_subproj_comp_percentage,0)/100), l_prj_currency_code),0);
                    -- 4579654 : For more accuracy, Do not round the earned value here.
                    --l_subproj_earned_value := nvl(pa_currency.round_trans_currency_amt((NVL(l_sub_project_bac_value, 0)*nvl(l_subproj_comp_percentage,0)/100), l_prj_currency_code),0);
                    l_subproj_earned_value := nvl((NVL(l_sub_project_bac_value, 0)*nvl(l_subproj_comp_percentage,0)/100),0);
                END IF;

                IF l_tsk_deriv_method_tab(k) = 'COST' and l_track_wp_cost_flag = 'N' THEN
                    l_rollup_table1(l_index).EARNED_VALUE1                  := 0;
                    l_rollup_table1(l_index).BAC_VALUE1                     := 1;
                ELSE
                    l_rollup_table1(l_index).EARNED_VALUE1                  := NVL( l_subproj_earned_value, 0 );
                    --l_rollup_table1(l_index).BAC_VALUE1                     := NVL(l_subproj_bac_value, NVL(l_sub_project_bac_value, 0));
                    l_rollup_table1(l_index).BAC_VALUE1                     := NVL(l_sub_project_bac_value, 0);
                END IF;

                */
                l_rollup_table1(l_index).PERCENT_COMPLETE1               := nvl(l_subproj_comp_percentage, 0);
                l_rollup_table1(l_index).BAC_VALUE1                      := NVL(rec_subproj.sub_project_bac_value, 0);
                -- 4582956 End

                --    Rollup Progress Status Rollup
                l_rollup_table1(l_index).PROGRESS_STATUS_WEIGHT1         := nvl(l_subproj_rollup_weight1,0);       --rollup prog status
                l_rollup_table1(l_index).PROGRESS_override1              := l_subproj_override_weight2;    --override prg  status

                --    Base Progress Status Rollup
		-- 4533112 : Base progress status is not used
                --l_rollup_table1(l_index).PROGRESS_STATUS_WEIGHT2     := nvl( l_subproj_base_weight3, 0 );  --base prog status
                --l_rollup_table1(l_index).PROGRESS_override2                 :=      0;  -- FPM Dev  CR 2

                --    Task Status Rollup
                l_rollup_table1(l_index).task_status1                    := nvl( l_subproj_task_weight4, 0 );  -- task status


                l_rollup_table1(l_index).DIRTY_FLAG1            := 'Y';
                l_rollup_table1(l_index).DIRTY_FLAG2            := 'Y';
                l_action_allowed                := 'Y';
                l_rollup_table1(l_index).rollup_node1           := l_action_allowed;
                l_rollup_table1(l_index).rollup_node2           := l_action_allowed;

                IF p_rollup_entire_wbs = 'Y' AND l_subproj_prog_rollup_id IS NOT NULL THEN
                    -- This means  Progress exists for the  corresponding task
                    l_tsk_progress_exists := 'Y';
                END IF;
                --END IF; -- l_sub_project_id IS NOT NULL THEN
            END LOOP;
        END IF; -- l_published_structure = 'Y' AND p_structure_type = 'WORKPLAN' THEN
        -- Bug 4392189 : Program Changes End

                -- Loop thru all task assignments of a passed parent
                IF p_structure_type = 'WORKPLAN'
        THEN
            l_asgn_task_version_id_tab.delete;
            l_asgn_rate_based_flag_tab.delete;
            l_asgn_resource_class_code_tab.delete;
            l_asgn_res_assignment_id_tab.delete;
            l_asgn_planned_quantity_tab.delete;
            l_asgn_plan_bur_cost_pc_tab.delete;
            l_asgn_res_list_member_id_tab.delete;

            OPEN cur_assgn_rec_bulk(l_tsk_object_id_to1_tab(k), l_tsk_proj_element_id_tab(k));
            FETCH cur_assgn_rec_bulk BULK COLLECT INTO l_asgn_task_version_id_tab, l_asgn_rate_based_flag_tab
            , l_asgn_resource_class_code_tab, l_asgn_res_assignment_id_tab
            , l_asgn_planned_quantity_tab, l_asgn_plan_bur_cost_pc_tab, l_asgn_res_list_member_id_tab;
            CLOSE cur_assgn_rec_bulk;

                    IF g1_debug_mode = 'Y' THEN
                     pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT',x_Msg => 'l_asgn_task_version_id_tab.count='||l_asgn_task_version_id_tab.count, x_Log_Level=> 3);
                END IF;

            FOR i in 1..l_asgn_task_version_id_tab.count LOOP

                IF g1_debug_mode = 'Y' THEN
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_asgn_res_assignment_id_tab('||i||')='||l_asgn_res_assignment_id_tab(i), x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_asgn_res_list_member_id_tab('||i||')='||l_asgn_res_list_member_id_tab(i), x_Log_Level=> 3);
                END IF;

                l_asgn_progress_rec := null;
                l_asgn_act_start_date := null;
                l_asgn_act_finish_date := null;
                l_asgn_est_start_date := null;
                l_asgn_est_finish_date := null;
                l_asgn_as_of_date := null;
                l_asgn_ppl_act_eff := null;
                l_asgn_eqp_act_eff := null;
                l_asgn_ppl_act_cost := null;
                l_asgn_eqp_act_cost := null;
                l_asgn_oth_act_cost := null;
                l_asgn_ppl_etc_eff := null;
                l_asgn_eqp_etc_eff := null;
                l_asgn_ppl_etc_cost := null;
                l_asgn_eqp_etc_cost := null;
                l_asgn_oth_etc_cost := null;

                OPEN cur_get_asgn_progress(l_asgn_res_list_member_id_tab(i),l_tsk_proj_element_id_tab(k));
                FETCH cur_get_asgn_progress INTO l_asgn_progress_rec;
                CLOSE cur_get_asgn_progress;

                IF g1_debug_mode  = 'Y' THEN
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_asgn_progress_rec.object_id='||l_asgn_progress_rec.object_id, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_asgn_progress_rec.as_of_date='||l_asgn_progress_rec.as_of_date, x_Log_Level=> 3);
                END IF;

                IF l_asgn_progress_rec.object_id is not null THEN
                    l_asgn_act_start_date := l_asgn_progress_rec.actual_start_date;
                    l_asgn_act_finish_date := l_asgn_progress_rec.actual_finish_date;
                    l_asgn_est_start_date := l_asgn_progress_rec.estimated_start_date;
                    l_asgn_est_finish_date := l_asgn_progress_rec.estimated_finish_date;
                    l_asgn_as_of_date := l_asgn_progress_rec.as_of_date;

                    l_asgn_ppl_act_eff := l_asgn_progress_rec.ppl_act_effort_to_date;
                    l_asgn_eqp_act_eff := l_asgn_progress_rec.eqpmt_act_effort_to_date;
                    l_asgn_ppl_act_cost := l_asgn_progress_rec.ppl_act_cost_to_date_pc;
                    l_asgn_eqp_act_cost := l_asgn_progress_rec.eqpmt_act_cost_to_date_pc;
                    l_asgn_oth_act_cost := l_asgn_progress_rec.oth_act_cost_to_date_pc;

                    l_asgn_ppl_etc_eff := l_asgn_progress_rec.estimated_remaining_effort;
                    l_asgn_eqp_etc_eff := l_asgn_progress_rec.eqpmt_etc_effort;
                    l_asgn_ppl_etc_cost := l_asgn_progress_rec.ppl_etc_cost_pc;
                    l_asgn_eqp_etc_cost := l_asgn_progress_rec.eqpmt_etc_cost_pc;
                    l_asgn_oth_etc_cost := l_asgn_progress_rec.oth_etc_cost_pc;

                     IF l_tsk_deriv_method_tab(k) = 'EFFORT' THEN
                         l_asgn_earned_value := nvl(l_asgn_ppl_act_eff,0) +  nvl(l_asgn_eqp_act_eff,0);
                         IF l_asgn_rate_based_flag_tab(i) = 'Y' AND l_asgn_resource_class_code_tab(i) = 'PEOPLE' THEN
                            IF l_asgn_ppl_etc_eff IS NULL THEN
                                l_asgn_bac_value := l_asgn_planned_quantity_tab(i);
                            ELSE
                                l_asgn_bac_value := nvl(l_asgn_ppl_act_eff,0) + nvl(l_asgn_ppl_etc_eff,0);
                            END IF;
                         ELSIF l_asgn_rate_based_flag_tab(i) = 'Y' AND l_asgn_resource_class_code_tab(i) = 'EQUIPMENT' THEN
                            IF l_asgn_eqp_etc_eff IS NULL THEN
                                l_asgn_bac_value := l_asgn_planned_quantity_tab(i);
                            ELSE
                                l_asgn_bac_value := nvl(l_asgn_eqp_act_eff,0) + nvl(l_asgn_eqp_etc_eff,0);
                            END IF;
                         ELSE
                            l_asgn_bac_value := 0;
                         END IF;
                     ELSE
                         l_asgn_earned_value := nvl(l_asgn_ppl_act_cost,0) + nvl(l_asgn_eqp_act_cost,0) + nvl(l_asgn_oth_act_cost,0);
                         IF l_asgn_resource_class_code_tab(i) = 'PEOPLE' THEN
                            IF l_asgn_ppl_etc_cost IS NULL THEN
                                l_asgn_bac_value := l_asgn_plan_bur_cost_pc_tab(i);
                            ELSE
                                l_asgn_bac_value := nvl(l_asgn_ppl_act_cost,0) + nvl(l_asgn_ppl_etc_cost,0);
                            END IF;
                         ELSIF l_asgn_resource_class_code_tab(i) = 'EQUIPMENT' THEN
                               IF l_asgn_eqp_etc_cost IS NULL THEN
                                l_asgn_bac_value := l_asgn_plan_bur_cost_pc_tab(i);
                               ELSE
                                l_asgn_bac_value := nvl(l_asgn_eqp_act_cost,0) + nvl(l_asgn_eqp_etc_cost,0);
                               END IF;
                         ELSE
                               IF l_asgn_oth_etc_cost IS NULL THEN
                                l_asgn_bac_value := l_asgn_plan_bur_cost_pc_tab(i);
                               ELSE
                                l_asgn_bac_value := nvl(l_asgn_oth_act_cost,0) + nvl(l_asgn_oth_etc_cost,0);
                               END IF;
                         END IF;
                     END IF;
                ELSE
                    l_asgn_earned_value := 0;
                    IF l_tsk_deriv_method_tab(k) = 'EFFORT' THEN
                        IF l_asgn_rate_based_flag_tab(i) = 'Y' AND l_asgn_resource_class_code_tab(i) IN('PEOPLE', 'EQUIPMENT') THEN
                            l_asgn_bac_value := l_asgn_planned_quantity_tab(i);
                        ELSE
                            l_asgn_bac_value := 0;
                        END IF;
                    ELSE
                        l_asgn_bac_value := l_asgn_plan_bur_cost_pc_tab(i);
                    END IF;
                END IF;

                l_index := l_index + 1;

                l_rollup_table1(l_index).OBJECT_TYPE                    := 'PA_ASSIGNMENTS';
                l_rollup_table1(l_index).OBJECT_ID                      := l_asgn_res_assignment_id_tab(i);
                l_rollup_table1(l_index).PARENT_OBJECT_TYPE             := 'PA_TASKS';
                l_rollup_table1(l_index).PARENT_OBJECT_ID               := l_asgn_task_version_id_tab(i);
                l_rollup_table1(l_index).WBS_LEVEL                      := 9999999; --  Assigning       some    value so that order     by in   scheduling API  works
                l_rollup_table1(l_index).CALENDAR_ID                    := l_index;

                -- Percent Complete needs to be derived using Earned Value and BAC Value

                -- Percent Complete at Assignment level does not get calculated
		-- 4533112 : Added following check for l_tsk_base_prog_stat_code_tab
                IF l_tsk_deriv_method_tab(k) IN ('EFFORT', 'COST')  AND nvl(l_tsk_base_prog_stat_code_tab(k), 'N') <> 'Y'  THEN
                     -- Actual Date Rollup : Only Start     Date    gets    rolls up.
                     l_rollup_table1(l_index).START_DATE1                    := l_asgn_act_start_date;
                     l_rollup_table1(l_index).FINISH_DATE1                    := l_asgn_act_finish_date;

                     -- Estimated Date Rollup  : Only Start Date    gets    rolls   up.
                     l_rollup_table1(l_index).START_DATE2                    := l_asgn_est_start_date;
                     l_rollup_table1(l_index).FINISH_DATE2                    := l_asgn_est_finish_date;
                END IF;

                -- Progress Status entry is not  there at assignment     level

                -- Assignment Status entry is not there at assignment level


                -- Earned Value and BAC Rollup
                IF l_tsk_deriv_method_tab(k) = 'COST' and l_track_wp_cost_flag = 'N' THEN
                    l_rollup_table1(l_index).EARNED_VALUE1                  := 0;
                    l_rollup_table1(l_index).BAC_VALUE1                     := 1;
                    -- 4392189 : Program Reporting Changes - Phase 2
                    -- Having Set2 columns to get Project level % complete
                    l_rollup_table1(l_index).EARNED_VALUE2                  := 0;
                    l_rollup_table1(l_index).BAC_VALUE2                     := 1;
                ELSE
                    l_rollup_table1(l_index).EARNED_VALUE1                  := NVL( l_asgn_earned_value, 0 );
                    l_rollup_table1(l_index).BAC_VALUE1                     := NVL( l_asgn_bac_value, 0 );
                    -- 4392189 : Program Reporting Changes - Phase 2
                    -- Having Set2 columns to get Project level % complete
                    l_rollup_table1(l_index).EARNED_VALUE2                  := NVL( l_asgn_earned_value, 0 );
                    l_rollup_table1(l_index).BAC_VALUE2                     := NVL( l_asgn_bac_value, 0 );
                END IF;

                l_rollup_table1(l_index).DIRTY_FLAG1            :=      'Y';
                l_rollup_table1(l_index).DIRTY_FLAG2            :=      'Y';
                l_action_allowed :=     'Y';
                l_rollup_table1(l_index).rollup_node1                       := l_action_allowed;
                l_rollup_table1(l_index).rollup_node2                       := l_action_allowed;

                IF p_rollup_entire_wbs = 'Y' AND l_asgn_progress_rec.object_id IS   NOT NULL THEN
                    -- This means  Progress exists for the  corresponding task
                    l_tsk_progress_exists := 'Y';
                END IF;
            END LOOP;       -- Assignments  Loop
        END IF;

        -- Bug 3957792 : Added check for Cancelled tasks
                IF p_structure_type = 'WORKPLAN' AND l_published_structure = 'Y' AND l_tsk_deriv_method_tab(k)   = 'DELIVERABLE'
                AND (PA_PROGRESS_UTILS.get_system_task_status(PA_PROGRESS_UTILS.get_task_status( p_project_id, l_tsk_proj_element_id_tab(k))) <> 'CANCELLED')
                THEN

            FOR cur_del_rec in cur_deliverables(l_tsk_proj_element_id_tab(k), l_tsk_object_id_to1_tab(k), p_project_id)   LOOP    -- FPM Change
                IF g1_debug_mode  = 'Y' THEN
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'cur_del_rec.object_id_to1='||cur_del_rec.object_id_to1, x_Log_Level=> 3);
                                END IF;

                                l_index := l_index + 1;

                                l_rollup_table1(l_index).OBJECT_TYPE             := cur_del_rec.object_type;
                                l_rollup_table1(l_index).OBJECT_ID               := cur_del_rec.object_id_to1;--Object Version Id       of Deliverable
                                l_rollup_table1(l_index).PARENT_OBJECT_TYPE      := cur_del_rec.parent_object_type;
                                l_rollup_table1(l_index).PARENT_OBJECT_ID        := l_tsk_object_id_to1_tab(k);--Object Version Id      of Task
                                l_rollup_table1(l_index).WBS_LEVEL               := 9999999;
                                l_rollup_table1(l_index).CALENDAR_ID             := l_index;

                                -- Rollup       Percent Complete Rollup
                                l_rollup_table1(l_index).task_weight1            := nvl( cur_del_rec.weighting_percentage, 0 );
                                l_rollup_table1(l_index).PERCENT_COMPLETE1       := nvl( cur_del_rec.completed_percentage, 0 );
				-- 4392189 : Program Reporting Changes - Phase 2
				-- Having Set2 columns to get Project level % complete
                                l_rollup_table1(l_index).task_weight2            := nvl( cur_del_rec.weighting_percentage, 0 );
                                l_rollup_table1(l_index).PERCENT_COMPLETE2       := nvl( cur_del_rec.completed_percentage, 0 );

                                --l_rollup_table1(l_index).PERCENT_OVERRIDE1    := 0; -- FPM Dev CR     2

                                -- Base Percent Complete Rollup

                                -- Dates will not get rolled up for deliverable

                                -- Rollup       Progress Status Rollup

                                -- l_rollup_table1(l_index).PROGRESS_STATUS_WEIGHT1 :=  0;       --rollup       prog    status is       0 for deliverable as it is      lowest --       FPM Dev CR 2
                                l_rollup_table1(l_index).PROGRESS_override1      := cur_del_rec.override_weight;         --override prg status

                                -- Base Progress Status Rollup
				-- 4533112 : Now base progress status is not used
                                --l_rollup_table1(l_index).PROGRESS_STATUS_WEIGHT2 := nvl( cur_del_rec.base_weight, 0);
                                -- l_rollup_table1(l_index).PROGRESS_override2      := 0;        -- FPM Dev CR  2

                                l_rollup_table1(l_index).DIRTY_FLAG1      :=    'Y';
                                l_rollup_table1(l_index).DIRTY_FLAG2      :=    'Y';

				-- Deliverable Status will not      get rolled up for deliverable

                                l_action_allowed  := PA_PROJ_ELEMENTS_UTILS.CHECK_TASK_STUS_ACTION_ALLOWED(l_tsk_status_code_tab(k), 'PROGRESS_ROLLUP' );

                                IF nvl( l_tsk_weighting_percent_tab(k), 0 ) = 0 THEN
					l_action_allowed := 'N';
                                END IF;

                                IF nvl( cur_del_rec.weighting_percentage, 0 ) = 0 THEN
					l_action_allowed := 'N';
                                END IF;

                                IF g1_debug_mode  =     'Y'     THEN
					pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'Deliverable l_action_allowed='||l_action_allowed,     x_Log_Level=> 3);
                                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'Deliverable cur_del_rec.weighting_percentage='||cur_del_rec.weighting_percentage, x_Log_Level=> 3);
                                END IF;

                                l_rollup_table1(l_index).rollup_node1             :=    l_action_allowed;
                                l_rollup_table1(l_index).rollup_node2             :=    l_action_allowed;

                                --maansari4/10  temporarily passing     'Y' to rollup node.
                                -- need to investigate  why l_action_allowed is coming always as        'N'

                                l_rollup_table1(l_index).rollup_node1             :=    'Y';
                                l_rollup_table1(l_index).rollup_node2             :=    'Y';

                IF p_rollup_entire_wbs = 'Y' AND cur_del_rec.as_of_date IS NOT NULL     THEN
                    -- This means  Progress        exists for the  corresponding task
                    l_tsk_progress_exists := 'Y';
                        END IF;
            END LOOP;       -- Delivertables Loop
        END IF;       -- l_tsk_deriv_method_tab(k) = 'DELIVERABLES'   THEN

        l_index := l_index + 1;

        l_rollup_table1(l_index).OBJECT_TYPE                     := l_tsk_object_type_tab(k);
        l_rollup_table1(l_index).OBJECT_ID                       := l_tsk_object_id_to1_tab(k);--Task Version Id
        l_rollup_table1(l_index).PARENT_OBJECT_TYPE              := l_tsk_parent_object_type_tab(k);
        l_rollup_table1(l_index).PARENT_OBJECT_ID                := l_tsk_object_id_from1_tab(k); --Parent    Task    Version Id
        l_rollup_table1(l_index).WBS_LEVEL                       := NVL( l_tsk_wbs_level_tab(k),      0 );
        l_rollup_table1(l_index).CALENDAR_ID                     := l_index;
        -- 4582956 Begin
                -- l_rollup_table1(l_index).SUMMARY_OBJECT_FLAG      := l_summary_object_flag; -- 4370746
        IF l_tsk_object_id_to1_tab(k) = nvl(l_subproj_task_version_id, -789) THEN
            -- 4586449 : Passing L for link tasks
            --l_rollup_table1(l_index).SUMMARY_OBJECT_FLAG       := 'Y'; --Link task shd be treated as summary task
            l_rollup_table1(l_index).SUMMARY_OBJECT_FLAG         := 'L'; --Link task shd be treated as summary task
        ELSE
            l_rollup_table1(l_index).SUMMARY_OBJECT_FLAG         := l_summary_object_flag;
        END IF;
        -- 4582956 end

        -- Rollup Percent  Complete Rollup
        l_rollup_table1(l_index).task_weight1                    := nvl( l_tsk_weighting_percent_tab(k), 0    );
        l_rollup_table1(l_index).PERCENT_COMPLETE1               := nvl( l_tsk_roll_comp_percent_tab(k), 0    );
        -- 4392189 : Program Reporting Changes - Phase 2
        -- Having Set2 columns to get Project level % complete
        l_rollup_table1(l_index).task_weight2                    := nvl( l_tsk_weighting_percent_tab(k), 0    );
        l_rollup_table1(l_index).PERCENT_COMPLETE2               := nvl( l_tsk_base_percent_comp_tab(k), 0    );

        --bug 4045979, start
        l_task_baselined := 'N';
        l_parent_task_baselined := 'N';
        OPEN check_task_baselined(l_base_struct_ver_id, l_tsk_object_id_to1_tab(k));
        FETCH check_task_baselined INTO l_task_baselined;
        CLOSE check_task_baselined;

        OPEN check_task_baselined(l_base_struct_ver_id, l_tsk_object_id_from1_tab(k));
        FETCH check_task_baselined INTO l_parent_task_baselined;
        CLOSE check_task_baselined;

        -- 4392189 : Program Reporting Changes - Phase 2
        -- Having Set2 columns to get Project level % complete

        IF p_structure_type = 'WORKPLAN' AND  l_rollup_method IN ('COST', 'EFFORT') AND (l_task_baselined = 'N' AND l_parent_task_baselined = 'Y')
        THEN
            l_rollup_table1(l_index).PERCENT_OVERRIDE1        := 0;
            l_rollup_table1(l_index).PERCENT_OVERRIDE2        := 0;
        ELSE
            l_rollup_table1(l_index).PERCENT_OVERRIDE1        := l_tsk_over_percent_comp_tab(k);
            --4557541 : For self % complete Override at tasks level would not be considered
            --l_rollup_table1(l_index).PERCENT_OVERRIDE2        := l_tsk_over_percent_comp_tab(k);
            l_rollup_table1(l_index).PERCENT_OVERRIDE2        := null;

        END IF;

        -- Bug 4284353 : Added below code
        IF p_structure_type = 'FINANCIAL' and p_progress_mode = 'TRANSFER_WP_PC' THEN
            l_rollup_table1(l_index).PERCENT_OVERRIDE1 := null;
            l_rollup_table1(l_index).PERCENT_COMPLETE1 := l_tsk_over_percent_comp_tab(k);
        END IF;

        --    Actual Date Rollup
        l_rollup_table1(l_index).START_DATE1                     := l_tsk_actual_start_date_tab(k);
        l_rollup_table1(l_index).FINISH_DATE1                    := l_tsk_actual_finish_date_tab(k);

        --    Estimated Date Rollup
        l_rollup_table1(l_index).START_DATE2                     := l_tsk_est_start_date_tab(k);
        l_rollup_table1(l_index).FINISH_DATE2                    := l_tsk_est_finish_date_tab(k);

        --    Rollup Progress Status Rollup
        l_rollup_table1(l_index).PROGRESS_STATUS_WEIGHT1         := nvl(l_tsk_rollup_weight1_tab(k),0);       --rollup prog status
        l_rollup_table1(l_index).PROGRESS_override1              := l_tsk_override_weight2_tab(k);    --override prg  status

        --    Base Progress Status Rollup
	-- 4533112 : base progress status is not used
        --l_rollup_table1(l_index).PROGRESS_STATUS_WEIGHT2 := nvl( l_tsk_base_weight3_tab(k), 0 );  --base prog status
        --l_rollup_table1(l_index).PROGRESS_override2                 :=      0;  -- FPM Dev  CR 2

        --    Task Status Rollup
        l_rollup_table1(l_index).task_status1                    := nvl( l_tsk_task_weight4_tab(k), 0 );  -- task status

        -- ETC Effort      Rollup
        --    l_rollup_table1(l_index).REMAINING_EFFORT1                       := NVL( cur_tasks_rec.ESTIMATED_REMAINING_EFFORT,      0 );    --etc_people_effort
        --    l_rollup_table1(l_index).EQPMT_ETC_EFFORT1                       := NVL( cur_tasks_rec.EQPMT_ETC_EFFORT, 0      );

        -- ETC Cost in Project     Currency Rollup
        --    l_rollup_table1(l_index).ETC_COST1                               := NVL( cur_tasks_rec.OTH_ETC_COST_PC, 0 );
        --    l_rollup_table1(l_index).PPL_ETC_COST1                   := NVL( cur_tasks_rec.PPL_ETC_COST_PC, 0 );
        --    l_rollup_table1(l_index).EQPMT_ETC_COST1                         := NVL( cur_tasks_rec.EQPMT_ETC_COST_PC, 0 );

        -- ETC Cost in  Project Functional Currency Rollup
        --    l_rollup_table1(l_index).ETC_COST2                               := NVL( cur_tasks_rec.OTH_ETC_COST_FC, 0 );
        --    l_rollup_table1(l_index).PPL_ETC_COST2                   := NVL( cur_tasks_rec.PPL_ETC_COST_FC, 0 );
        --    l_rollup_table1(l_index).EQPMT_ETC_COST2                         := NVL( cur_tasks_rec.EQPMT_ETC_COST_FC, 0 );

        -- Sub Project  ETC Effort Rollup
        --    l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_EFFORT1 := NVL( cur_tasks_rec.SUBPRJ_PPL_ETC_EFFORT, 0 );
        --    l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_EFFORT1      := NVL( cur_tasks_rec.SUBPRJ_EQPMT_ETC_EFFORT, 0 );

        -- Sub Project ETC Cost in Project Currency     Rollup
        --    l_rollup_table1(l_index).SUB_PRJ_ETC_COST1               := NVL( cur_tasks_rec.SUBPRJ_OTH_ETC_COST_PC, 0 );
        --    l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_COST1   := NVL( cur_tasks_rec.SUBPRJ_PPL_ETC_COST_PC,  0 );
        --    l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_COST1 := NVL( cur_tasks_rec.SUBPRJ_EQPMT_ETC_COST_PC, 0      );

        -- Sub Project ETC Cost in Project Functional Currency Rollup
        --    l_rollup_table1(l_index).SUB_PRJ_ETC_COST2               := NVL( cur_tasks_rec.SUBPRJ_OTH_ETC_COST_FC, 0 );
        --    l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_COST2   := NVL( cur_tasks_rec.SUBPRJ_PPL_ETC_COST_FC,  0 );
        --    l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_COST2 := NVL( cur_tasks_rec.SUBPRJ_EQPMT_ETC_COST_FC, 0      );

        -- Earned Value and BAC Rollup
        --    Bug 3830673, 3879461 : We should pass the earned value  for     lowest task which do not        have    assignments
        --IF NVL(l_lowest_task, 'N') = 'Y' AND NVL(l_assignment_exists, 'N') = 'N' THEN
        --      IF    l_tsk_deriv_method_tab(k) = 'EFFORT' THEN
        --        l_rollup_table1(l_index).EARNED_VALUE1 := nvl(cur_tasks_rec.PPL_ACT_EFFORT_TO_DATE,0)       + nvl(cur_tasks_rec.EQPMT_ACT_EFFORT_TO_DATE,0);
        --      ELSE
        --        l_rollup_table1(l_index).EARNED_VALUE1 := nvl(cur_tasks_rec.OTH_ACT_COST_TO_DATE_PC,0) + nvl(cur_tasks_rec.PPL_ACT_COST_TO_DATE_PC,0) +     nvl(cur_tasks_rec.EQPMT_ACT_COST_TO_DATE_PC,0);
        --      END IF;
        --ELSE

        -- 4392189 : Program Reporting Changes - Phase 2
        -- Having Set2 columns to get Project level % complete
        l_rollup_table1(l_index).EARNED_VALUE1           := 0; --NVL( cur_tasks_rec.EARNED_VALUE, 0 );
        l_rollup_table1(l_index).EARNED_VALUE2           := 0; --NVL( cur_tasks_rec.EARNED_VALUE, 0 );

        --END IF;

        -- 4586449 Begin : For link tasks, pass BAC_VALUE in terms of derivation method of the task
        -- in earned_value1 set
        IF p_structure_type = 'WORKPLAN' AND l_tsk_object_id_to1_tab(k) = nvl(l_subproj_task_version_id, -789) THEN

            l_rollup_table1(l_index).EARNED_VALUE1 := pa_progress_utils.Get_BAC_Value(p_project_id
                    , l_tsk_deriv_method_tab(k), l_tsk_proj_element_id_tab(k),  p_structure_version_id,
                    'WORKPLAN','N','Y');
 	    -- Bug 4636100 Issue 1 : We should always pass self plan for link task as 1
            --l_rollup_table1(l_index).EARNED_VALUE2 := NVL( l_tsk_bac_self_value_tab(k), 0 );
	    l_rollup_table1(l_index).EARNED_VALUE2 := 1;
        END IF;

        l_rollup_table1(l_index).BAC_VALUE1              := NVL( l_tsk_bac_value_tab(k), 0 );

        IF g1_debug_mode = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_rollup_table1(l_index).BAC_VALUE1='||l_rollup_table1(l_index).BAC_VALUE1,     x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_rollup_table1(l_index).EARNED_VALUE1='||l_rollup_table1(l_index).EARNED_VALUE1, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_rollup_table1(l_index).EARNED_VALUE2='||l_rollup_table1(l_index).EARNED_VALUE2, x_Log_Level=> 3);
                END IF;

        -- 4586449 End

        l_rollup_table1(l_index).BAC_VALUE2              := NVL( l_tsk_bac_self_value_tab(k), 0 ); -- Bug 4493105 --NVL( l_tsk_bac_value_tab(k),      0 );

        -- Bug 4344292 : Do not pass DELIVERABLE to scheduling API for summary tasks
        -- Otheriwse it will look for deliverables and will result in 0 % complete
        IF l_tsk_deriv_method_tab(k) = 'DELIVERABLE' AND p_structure_type = 'FINANCIAL' THEN
            l_rollup_table1(l_index).PERC_COMP_DERIVATIVE_CODE1 := 'COST';
        ELSE
            l_rollup_table1(l_index).PERC_COMP_DERIVATIVE_CODE1 := l_tsk_deriv_method_tab(k);
            l_rollup_table1(l_index).PERC_COMP_DERIVATIVE_CODE2 := l_tsk_deriv_method_tab(k);
        END IF;

        --    Bug 4207995 : Passing Dirty_flags always Y
        --               IF (cur_tasks_rec.object_id_to1 =      p_object_version_id)    THEN
                l_rollup_table1(l_index).DIRTY_FLAG1         := 'Y';
                l_rollup_table1(l_index).DIRTY_FLAG2         := 'Y';
        --               ELSE
        --                       l_rollup_table1(l_index).DIRTY_FLAG1      := 'N';
        --                       l_rollup_table1(l_index).DIRTY_FLAG2      := 'N';
        --               END    IF;

        l_action_allowed := PA_PROJ_ELEMENTS_UTILS.CHECK_TASK_STUS_ACTION_ALLOWED(l_tsk_status_code_tab(k), 'PROGRESS_ROLLUP' );

        IF nvl(l_tsk_weighting_percent_tab(k), 0) = 0 THEN
            l_action_allowed :=     'N';
        END IF;

        IF g1_debug_mode   = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'Tasks l_action_allowed='||l_action_allowed,    x_Log_Level=> 3);
                END IF;

        l_rollup_table1(l_index).rollup_node1                    := l_action_allowed;
        l_rollup_table1(l_index).rollup_node2                    := l_action_allowed;

                --maansari4/10  temporarily passing     'Y' to rollup node.
                -- need to investigate  why l_action_allowed is coming always as        'N'

                l_rollup_table1(l_index).rollup_node1             :=    'Y';
                l_rollup_table1(l_index).rollup_node2             :=    'Y';


        IF p_rollup_entire_wbs = 'Y' THEN
                  --    This    means Progress  exists for the  corresponding task
            IF l_tsk_progress_exists        = 'Y' THEN
                l_mass_rollup_prog_exists_tab.extend(1);
                l_mass_rollup_prog_exists_tab(l_mass_rollup_prog_exists_tab.count):=l_tsk_object_id_to1_tab(k) ;
            ELSIF l_tsk_as_of_date_tab(k) IS NOT NULL THEN
                l_mass_rollup_prog_exists_tab.extend(1);
                l_mass_rollup_prog_exists_tab(l_mass_rollup_prog_exists_tab.count):=l_tsk_object_id_to1_tab(k) ;
            END IF;
        END IF;

        l_mapping_tasks_to_rollup_tab(l_index):= k;

        --IF (p_process_whole_tree = 'N' and l_parent_count  = 2) THEN
                --        exit;
                --END IF;
	END IF; -- Bug 4636100 Issue 2 : Added Endif
    END LOOP;       -- End Tasks Loop

        --begin bug 3951982
        IF p_lowest_level_task = 'N' AND p_rollup_entire_wbs = 'N'
          AND pa_progress_utils.check_assignment_exists(p_project_id,p_task_version_id, 'PA_TASKS') = 'Y'
      AND l_actual_lowest_task = 'N' -- Bug 4392189
        THEN
        INSERT INTO pa_proj_rollup_temp(process_number, object_id, object_type, wbs_level)
        SELECT l_process_number_temp, p_task_version_id, 'PA_TASKS',  1
        FROM dual;

        FOR cur_tasks_rec in cur_tasks(1) LOOP
            IF cur_tasks_rec.object_type = 'PA_TASKS' THEN
                IF g1_debug_mode  = 'Y' THEN
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'Second task cursor for summary task with assignments',        x_Log_Level=>   3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'cur_tasks_rec.object_id_to1='||cur_tasks_rec.object_id_to1,   x_Log_Level=> 3);
                END IF;
                l_action_allowed  := PA_PROJ_ELEMENTS_UTILS.CHECK_TASK_STUS_ACTION_ALLOWED(  cur_tasks_rec.status_code, 'PROGRESS_ROLLUP'    );

                l_index := l_index + 1;

                l_rollup_table1(l_index).OBJECT_TYPE                        :=      cur_tasks_rec.object_type;
                l_rollup_table1(l_index).OBJECT_ID                          :=      cur_tasks_rec.object_id_to1;--Task      Version Id
                l_rollup_table1(l_index).PARENT_OBJECT_TYPE                 :=      cur_tasks_rec.parent_object_type;
                l_rollup_table1(l_index).PARENT_OBJECT_ID                   :=      cur_tasks_rec.object_id_from1; --Parent Task    Version Id
                l_rollup_table1(l_index).WBS_LEVEL                          :=      NVL( cur_tasks_rec.wbs_level, 0 );
                l_rollup_table1(l_index).CALENDAR_ID                        :=      l_index;
                        l_rollup_table1(l_index).SUMMARY_OBJECT_FLAG            :=      'Y'; -- 4370746

                -- Rollup Percent Complete Rollup
                l_rollup_table1(l_index).task_weight1                       :=      nvl( cur_tasks_rec.weighting_percentage, 0 );
                l_rollup_table1(l_index).PERCENT_COMPLETE1                  :=      nvl( cur_tasks_rec.rollup_completed_percentage, 0 );
                -- 4392189 : Program Reporting Changes - Phase 2
                -- Having Set2 columns to get Project level % complete
                l_rollup_table1(l_index).task_weight2                       :=      nvl( cur_tasks_rec.weighting_percentage, 0 );
                l_rollup_table1(l_index).PERCENT_COMPLETE2                  :=      nvl( cur_tasks_rec.base_percent_complete, 0 );

                --bug 4045979, start
                l_task_baselined := 'N';
                l_parent_task_baselined := 'N';
                OPEN check_task_baselined(l_base_struct_ver_id, cur_tasks_rec.object_id_to1);
                FETCH check_task_baselined INTO l_task_baselined;
                CLOSE check_task_baselined;

                OPEN check_task_baselined(l_base_struct_ver_id, cur_tasks_rec.object_id_from1);
                FETCH check_task_baselined INTO l_parent_task_baselined;
                CLOSE check_task_baselined;

                -- 4392189 : Program Reporting Changes - Phase 2
                -- Having Set2 columns to get Project level % complete

                IF p_structure_type = 'WORKPLAN' AND l_rollup_method IN ('COST', 'EFFORT') AND (l_task_baselined = 'N' AND l_parent_task_baselined = 'Y')
                THEN
                    l_rollup_table1(l_index).PERCENT_OVERRIDE1      := 0;
                    l_rollup_table1(l_index).PERCENT_OVERRIDE2      := 0;
                ELSE
                    l_rollup_table1(l_index).PERCENT_OVERRIDE1      := cur_tasks_rec.override_percent_complete;
                    --4557541 : For self % complete Override at tasks level would not be considered
                    --l_rollup_table1(l_index).PERCENT_OVERRIDE2      := cur_tasks_rec.override_percent_complete;
                    l_rollup_table1(l_index).PERCENT_OVERRIDE2      := null;
                END IF;
                --bug       4045979, end

                -- Actual Date Rollup
                l_rollup_table1(l_index).START_DATE1                        :=      cur_tasks_rec.actual_start_date;
                l_rollup_table1(l_index).FINISH_DATE1                       :=      cur_tasks_rec.actual_finish_date;

                -- Estimated Date Rollup
                l_rollup_table1(l_index).START_DATE2                        :=      cur_tasks_rec.estimated_start_date;
                l_rollup_table1(l_index).FINISH_DATE2                       :=      cur_tasks_rec.estimated_finish_date;

                -- Rollup Progress Status   Rollup
                l_rollup_table1(l_index).PROGRESS_STATUS_WEIGHT1            :=      nvl(cur_tasks_rec.rollup_weight1,0);    --rollup prog status
                l_rollup_table1(l_index).PROGRESS_override1                 :=      cur_tasks_rec.override_weight2;    --override prg status

                -- Base Progress Status Rollup
		-- 4533112 : Base Progress Status is not used
                --l_rollup_table1(l_index).PROGRESS_STATUS_WEIGHT2 := nvl(    cur_tasks_rec.base_weight3, 0   );  --base prog status
                --l_rollup_table1(l_index).PROGRESS_override2                 :=    0;  -- FPM Dev  CR 2

                -- Task Status Rollup
                l_rollup_table1(l_index).task_status1                       :=      nvl(    cur_tasks_rec.task_weight4, 0   );  -- task status

                -- ETC Effort Rollup
                l_rollup_table1(l_index).REMAINING_EFFORT1                  :=      NVL(    cur_tasks_rec.ESTIMATED_REMAINING_EFFORT, 0 ); --etc_people_effort
                l_rollup_table1(l_index).EQPMT_ETC_EFFORT1                  :=      NVL(    cur_tasks_rec.EQPMT_ETC_EFFORT, 0 );

                -- ETC Cost in Project Currency     Rollup
                l_rollup_table1(l_index).ETC_COST1                          :=      NVL(    cur_tasks_rec.OTH_ETC_COST_PC, 0 );
                l_rollup_table1(l_index).PPL_ETC_COST1                      :=      NVL(    cur_tasks_rec.PPL_ETC_COST_PC, 0 );
                l_rollup_table1(l_index).EQPMT_ETC_COST1                    :=      NVL(    cur_tasks_rec.EQPMT_ETC_COST_PC, 0      );

                -- ETC Cost in Project Functional Currency Rollup
                l_rollup_table1(l_index).ETC_COST2                          :=      NVL(    cur_tasks_rec.OTH_ETC_COST_FC, 0 );
                l_rollup_table1(l_index).PPL_ETC_COST2                      :=      NVL(    cur_tasks_rec.PPL_ETC_COST_FC, 0 );
                l_rollup_table1(l_index).EQPMT_ETC_COST2                    :=      NVL(    cur_tasks_rec.EQPMT_ETC_COST_FC, 0      );

                -- Sub Project ETC Effort   Rollup
                -- l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_EFFORT1 := NVL( cur_tasks_rec.SUBPRJ_PPL_ETC_EFFORT, 0 );
                -- l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_EFFORT1 := NVL( cur_tasks_rec.SUBPRJ_EQPMT_ETC_EFFORT,        0 );

                  --    Sub Project ETC Cost in Project Currency Rollup
                -- l_rollup_table1(l_index).SUB_PRJ_ETC_COST1       := NVL( cur_tasks_rec.SUBPRJ_OTH_ETC_COST_PC, 0 );
                -- l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_COST1   := NVL( cur_tasks_rec.SUBPRJ_PPL_ETC_COST_PC, 0 );
                -- l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_COST1 := NVL( cur_tasks_rec.SUBPRJ_EQPMT_ETC_COST_PC, 0 );

                  --    Sub Project ETC Cost in Project Functional      Currency Rollup
                -- l_rollup_table1(l_index).SUB_PRJ_ETC_COST2       := NVL( cur_tasks_rec.SUBPRJ_OTH_ETC_COST_FC, 0 );
                -- l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_COST2   := NVL( cur_tasks_rec.SUBPRJ_PPL_ETC_COST_FC, 0 );
                -- l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_COST2 := NVL( cur_tasks_rec.SUBPRJ_EQPMT_ETC_COST_FC, 0 );

                -- 4392189 : Program Reporting Changes - Phase 2
                -- Having Set2 columns to get Project level % complete

                l_rollup_table1(l_index).EARNED_VALUE1              :=      0; --NVL(       cur_tasks_rec.EARNED_VALUE, 0   );
                l_rollup_table1(l_index).BAC_VALUE1                 :=      NVL( cur_tasks_rec.BAC_VALUE, 0 );

                l_rollup_table1(l_index).EARNED_VALUE2              :=      0; --NVL(       cur_tasks_rec.EARNED_VALUE, 0   );
                l_rollup_table1(l_index).BAC_VALUE2                 :=      NVL( cur_tasks_rec.BAC_VALUE_SELF, 0 ); -- Bug 4493105

                l_rollup_table1(l_index).PERC_COMP_DERIVATIVE_CODE1 := cur_tasks_rec.task_derivation_method;
                l_rollup_table1(l_index).PERC_COMP_DERIVATIVE_CODE2 := cur_tasks_rec.task_derivation_method;
                -- Bug 4207995 : Passing Dirty_flags always Y
                -- IF (cur_tasks_rec.object_id_to1 = p_object_version_id) THEN
                 l_rollup_table1(l_index).DIRTY_FLAG1            := 'Y';
                 l_rollup_table1(l_index).DIRTY_FLAG2            := 'Y';
                -- ELSE
                --      l_rollup_table1(l_index).DIRTY_FLAG1         := 'N';
                --      l_rollup_table1(l_index).DIRTY_FLAG2         := 'N';
                -- END IF;

                l_action_allowed  := PA_PROJ_ELEMENTS_UTILS.CHECK_TASK_STUS_ACTION_ALLOWED(cur_tasks_rec.status_code, 'PROGRESS_ROLLUP' );

                IF nvl( cur_tasks_rec.weighting_percentage, 0 ) = 0 THEN
                    l_action_allowed := 'N';
                END IF;

                IF g1_debug_mode  = 'Y' THEN
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'Tasks l_action_allowed='||l_action_allowed, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'Tasks cur_tasks_rec.weighting_percentage='||cur_tasks_rec.weighting_percentage, x_Log_Level=> 3);
                END IF;

                l_rollup_table1(l_index).rollup_node1                       := l_action_allowed;
                l_rollup_table1(l_index).rollup_node2                       := l_action_allowed;

                --maansari4/10 temporarily passing 'Y' to rollup node.
                -- need to  investigate why l_action_allowed        is coming       always as       'N'
                l_rollup_table1(l_index).rollup_node1 := 'Y';
                l_rollup_table1(l_index).rollup_node2 := 'Y';
            END IF;       --<<cur_tasks_rec.object_type   = 'PA_TASKS'
        END LOOP;
    END IF; --  p_lowest_level_task = 'N' AND p_rollup_entire_wbs = 'N'
        --end bug 3951982

        DELETE from pa_proj_rollup_temp where process_number= l_process_number_temp;

    IF g1_debug_mode = 'Y' THEN
        FOR i in 1..l_mass_rollup_prog_exists_tab.count loop
            pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'First l_mass_rollup_prog_exists_tab(i)='||l_mass_rollup_prog_exists_tab(i), x_Log_Level=> 3);
        END LOOP;
    END IF;

        IF p_rollup_entire_wbs = 'Y' THEN
        FORALL i IN 1..l_mass_rollup_prog_exists_tab.COUNT
        INSERT INTO PA_PROJ_ROLLUP_TEMP(
        PROCESS_NUMBER,
        OBJECT_TYPE,
        OBJECT_ID,
        wbs_level)
        VALUES(l_process_number_temp, 'PA_TASKS',l_mass_rollup_prog_exists_tab(i), 1);

        l_mass_rollup_prog_exists_tab.delete;

        OPEN c_mass_rollup_tasks;
        FETCH c_mass_rollup_tasks BULK COLLECT INTO l_mass_rollup_prog_exists_tab;
        CLOSE c_mass_rollup_tasks;

        IF g1_debug_mode = 'Y' THEN
            FOR i in 1..l_mass_rollup_prog_exists_tab.count loop
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'Second l_mass_rollup_prog_exists_tab(i)='||l_mass_rollup_prog_exists_tab(i), x_Log_Level=> 3);
            END LOOP;
        END IF;

        FORALL i IN 1..l_mass_rollup_prog_exists_tab.COUNT
        INSERT INTO PA_PROJ_ROLLUP_TEMP(
        PROCESS_NUMBER,
        OBJECT_TYPE,
        OBJECT_ID,
        wbs_level)
        VALUES(l_process_number_temp, 'PA_TASKS',l_mass_rollup_prog_exists_tab(i), 1);
    END IF;


        -- FPM Dev CR 2 : Printing the  Rollup Table before     calling Generate Schedule
        IF g1_debug_mode  =     'Y'     THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'Calling GENERATE_SCHEDULE', x_Log_Level=> 3);
                FOR i IN 1..l_rollup_table1.count LOOP
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'OBJECT_TYPE ='||l_rollup_table1(i).OBJECT_TYPE, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'OBJECT_ID     ='||l_rollup_table1(i).OBJECT_ID, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'PARENT_OBJECT_TYPE ='||l_rollup_table1(i).PARENT_OBJECT_TYPE, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'PARENT_OBJECT_ID ='||l_rollup_table1(i).PARENT_OBJECT_ID, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'WBS_LEVEL     ='||l_rollup_table1(i).WBS_LEVEL, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'START_DATE1 ='||l_rollup_table1(i).START_DATE1||
                                ' FINISH_DATE1  ='||l_rollup_table1(i).FINISH_DATE1||
                                ' START_DATE2 ='||l_rollup_table1(i).START_DATE2||' FINISH_DATE2        ='||l_rollup_table1(i).FINISH_DATE2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'TASK_STATUS1 ='||l_rollup_table1(i).TASK_STATUS1||
                                ' TASK_STATUS2  ='||l_rollup_table1(i).TASK_STATUS2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'PROGRESS_STATUS_WEIGHT1 ='||l_rollup_table1(i).PROGRESS_STATUS_WEIGHT1||
                                ' PROGRESS_OVERRIDE1 ='||l_rollup_table1(i).PROGRESS_OVERRIDE1||' PROGRESS_STATUS_WEIGHT2       ='||l_rollup_table1(i).PROGRESS_STATUS_WEIGHT2||
                                        ' PROGRESS_OVERRIDE2 ='||l_rollup_table1(i).PROGRESS_OVERRIDE2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'PERCENT_COMPLETE1 ='||l_rollup_table1(i).PERCENT_COMPLETE1||
                                ' PERCENT_OVERRIDE1     ='||l_rollup_table1(i).PERCENT_OVERRIDE1||'     PERCENT_COMPLETE2 ='||l_rollup_table1(i).PERCENT_COMPLETE2||
                                        ' PERCENT_OVERRIDE2     ='||l_rollup_table1(i).PERCENT_OVERRIDE2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'TASK_WEIGHT1 ='||l_rollup_table1(i).TASK_WEIGHT1||
                                ' TASK_WEIGHT2  ='||l_rollup_table1(i).TASK_WEIGHT2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'ROLLUP_NODE1 ='||l_rollup_table1(i).ROLLUP_NODE1||
                                ' DIRTY_FLAG1 ='||l_rollup_table1(i).DIRTY_FLAG1||' ROLLUP_NODE2        ='||l_rollup_table1(i).ROLLUP_NODE2||
                                        ' DIRTY_FLAG2 ='||l_rollup_table1(i).DIRTY_FLAG2,       x_Log_Level=>   3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'ETC_Cost1     ='||l_rollup_table1(i).ETC_Cost1||
                                ' PPL_ETC_COST1 ='||l_rollup_table1(i).PPL_ETC_COST1||' EQPMT_ETC_COST1 ='||l_rollup_table1(i).EQPMT_ETC_COST1||
                                        ' ETC_Cost2 ='||l_rollup_table1(i).ETC_Cost2||' PPL_ETC_COST2 ='||l_rollup_table1(i).PPL_ETC_COST2||
                                                ' EQPMT_ETC_COST2 ='||l_rollup_table1(i).EQPMT_ETC_COST2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'REMAINING_EFFORT1 ='||l_rollup_table1(i).REMAINING_EFFORT1||
                                ' EQPMT_ETC_EFFORT1     ='||l_rollup_table1(i).EQPMT_ETC_EFFORT1||'     REMAINING_EFFORT2 ='||l_rollup_table1(i).REMAINING_EFFORT2||
                                        ' EQPMT_ETC_EFFORT2     ='||l_rollup_table1(i).EQPMT_ETC_EFFORT2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'SUB_PRJ_ETC_Cost1 ='||l_rollup_table1(i).SUB_PRJ_ETC_Cost1||
                                ' SUB_PRJ_PPL_ETC_COST1 ='||l_rollup_table1(i).SUB_PRJ_PPL_ETC_COST1||' SUB_PRJ_EQPMT_ETC_COST1 ='||l_rollup_table1(i).SUB_PRJ_EQPMT_ETC_COST1||
                          ' SUB_PRJ_ETC_Cost2 ='||l_rollup_table1(i).SUB_PRJ_ETC_Cost2||' SUB_PRJ_PPL_ETC_COST2 ='||l_rollup_table1(i).SUB_PRJ_PPL_ETC_COST2||' SUB_PRJ_EQPMT_ETC_COST2 ='||l_rollup_table1(i).SUB_PRJ_EQPMT_ETC_COST2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'SUB_PRJ_PPL_ETC_EFFORT1 ='||l_rollup_table1(i).SUB_PRJ_PPL_ETC_EFFORT1||' SUB_PRJ_EQPMT_ETC_EFFORT1   ='||l_rollup_table1(i).SUB_PRJ_EQPMT_ETC_EFFORT1||
                                ' SUB_PRJ_PPL_ETC_EFFORT2 ='||l_rollup_table1(i).SUB_PRJ_PPL_ETC_EFFORT2||' SUB_PRJ_EQPMT_ETC_EFFORT2 ='||l_rollup_table1(i).SUB_PRJ_EQPMT_ETC_EFFORT2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'EARNED_VALUE1 ='||l_rollup_table1(i).EARNED_VALUE1||' BAC_VALUE1 ='||l_rollup_table1(i).BAC_VALUE1||' EARNED_VALUE2 ='||l_rollup_table1(i).EARNED_VALUE2||
                                ' BAC_VALUE2 ='||l_rollup_table1(i).BAC_VALUE2||' BAC_VALUE6 ='||l_rollup_table1(i).BAC_VALUE6, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT',
                  x_Msg =>      'PERC_COMP_DERIVATIVE_CODE1 ='||l_rollup_table1(i).PERC_COMP_DERIVATIVE_CODE1||' PERC_COMP_DERIVATIVE_CODE2 ='||l_rollup_table1(i).PERC_COMP_DERIVATIVE_CODE2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => '**********************************************************', x_Log_Level=>    3);
                END LOOP;
        END IF;

        IF l_rollup_table1.count <= 0 THEN
        return;
        END IF;

        --Added by rtarway for  bug 3950574
        IF p_structure_type = 'WORKPLAN' THEN
            l_digit_number := 8;  --Bug 6854114
        ELSE
            l_digit_number := 8;  --Bug 6854114
        END IF;

        --  Bug 4207995 : Commented partial_flags in the below call

        PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE(
        p_commit                                => p_commit
        ,p_debug_mode                           => 'Y'
        ,x_return_status                        => l_return_status
        ,x_msg_count                            => l_msg_count
        ,x_msg_data                             => l_msg_data
        ,x_process_number                       => l_process_number
        ,p_data_structure                       => l_rollup_table1
        ,p_number_digit                         => l_digit_number
        ,p_process_flag1                        => 'Y'
        ,p_process_rollup_flag1                 => 'Y'
        ,p_process_progress_flag1               => 'Y'
        ,p_process_percent_flag1                => 'Y'
        ,p_process_effort_flag1                 => 'Y'
        ,p_process_task_status_flag1            => 'Y'
        ,p_process_flag2                        => 'Y'
        ,p_process_rollup_flag2                 => 'Y'
        ,p_process_progress_flag2               => 'Y'
        ,p_process_percent_flag2                => 'Y'
        ,p_process_ETC_Flag1                    => 'Y'
        ,p_process_ETC_Flag2                    => 'Y'
        ,p_Rollup_Method                        => l_Rollup_Method
        ,p_calling_module                       =>'ROLLUP_API'
                );

    IF g1_debug_mode = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'After  GENERATE_SCHEDULE', x_Log_Level=>      3);
        END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                     p_msg_name       => l_msg_data
                                );
                x_msg_data := l_msg_data;
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
        END IF;


        IF g1_debug_mode = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'Doing  UPDATE_ROLLUP_PROGRESS_PVT',   x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'p_upd_new_elem_ver_id_flag'||p_upd_new_elem_ver_id_flag, x_Log_Level=> 3);
        END IF;

        ----    **************  Updation Starts  ******************  ----------

        IF g1_debug_mode = 'Y' THEN
		pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_rollup_table1.count ='||l_rollup_table1.count, x_Log_Level=> 3);
		FOR i IN 1..l_rollup_table1.count LOOP
				pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'OBJECT_TYPE ='||l_rollup_table1(i).OBJECT_TYPE, x_Log_Level=> 3);
				pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'OBJECT_ID     ='||l_rollup_table1(i).OBJECT_ID, x_Log_Level=> 3);
				pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'PARENT_OBJECT_TYPE ='||l_rollup_table1(i).PARENT_OBJECT_TYPE, x_Log_Level=> 3);
				pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'PARENT_OBJECT_ID ='||l_rollup_table1(i).PARENT_OBJECT_ID, x_Log_Level=> 3);
				pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'WBS_LEVEL     ='||l_rollup_table1(i).WBS_LEVEL, x_Log_Level=> 3);
				pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'START_DATE1 ='||l_rollup_table1(i).START_DATE1||
					' FINISH_DATE1  ='||l_rollup_table1(i).FINISH_DATE1||
					' START_DATE2 ='||l_rollup_table1(i).START_DATE2||' FINISH_DATE2        ='||l_rollup_table1(i).FINISH_DATE2, x_Log_Level=> 3);
				pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'TASK_STATUS1 ='||l_rollup_table1(i).TASK_STATUS1||
					' TASK_STATUS2  ='||l_rollup_table1(i).TASK_STATUS2, x_Log_Level=> 3);
				pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'PROGRESS_STATUS_WEIGHT1 ='||l_rollup_table1(i).PROGRESS_STATUS_WEIGHT1||
					' PROGRESS_OVERRIDE1 ='||l_rollup_table1(i).PROGRESS_OVERRIDE1||' PROGRESS_STATUS_WEIGHT2       ='||l_rollup_table1(i).PROGRESS_STATUS_WEIGHT2||
						' PROGRESS_OVERRIDE2 ='||l_rollup_table1(i).PROGRESS_OVERRIDE2, x_Log_Level=> 3);
				pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'PERCENT_COMPLETE1 ='||l_rollup_table1(i).PERCENT_COMPLETE1||
					' PERCENT_OVERRIDE1     ='||l_rollup_table1(i).PERCENT_OVERRIDE1||'     PERCENT_COMPLETE2 ='||l_rollup_table1(i).PERCENT_COMPLETE2||
						' PERCENT_OVERRIDE2     ='||l_rollup_table1(i).PERCENT_OVERRIDE2, x_Log_Level=> 3);
				pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'TASK_WEIGHT1 ='||l_rollup_table1(i).TASK_WEIGHT1||
					' TASK_WEIGHT2  ='||l_rollup_table1(i).TASK_WEIGHT2, x_Log_Level=> 3);
				pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'ROLLUP_NODE1 ='||l_rollup_table1(i).ROLLUP_NODE1||
					' DIRTY_FLAG1 ='||l_rollup_table1(i).DIRTY_FLAG1||' ROLLUP_NODE2        ='||l_rollup_table1(i).ROLLUP_NODE2||
						' DIRTY_FLAG2 ='||l_rollup_table1(i).DIRTY_FLAG2,       x_Log_Level=>   3);
				pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'ETC_Cost1     ='||l_rollup_table1(i).ETC_Cost1||
					' PPL_ETC_COST1 ='||l_rollup_table1(i).PPL_ETC_COST1||' EQPMT_ETC_COST1 ='||l_rollup_table1(i).EQPMT_ETC_COST1||
						' ETC_Cost2 ='||l_rollup_table1(i).ETC_Cost2||' PPL_ETC_COST2 ='||l_rollup_table1(i).PPL_ETC_COST2||
							' EQPMT_ETC_COST2 ='||l_rollup_table1(i).EQPMT_ETC_COST2, x_Log_Level=> 3);
				pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'REMAINING_EFFORT1 ='||l_rollup_table1(i).REMAINING_EFFORT1||
					' EQPMT_ETC_EFFORT1     ='||l_rollup_table1(i).EQPMT_ETC_EFFORT1||'     REMAINING_EFFORT2 ='||l_rollup_table1(i).REMAINING_EFFORT2||
						' EQPMT_ETC_EFFORT2     ='||l_rollup_table1(i).EQPMT_ETC_EFFORT2, x_Log_Level=> 3);
				pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'SUB_PRJ_ETC_Cost1 ='||l_rollup_table1(i).SUB_PRJ_ETC_Cost1||
					' SUB_PRJ_PPL_ETC_COST1 ='||l_rollup_table1(i).SUB_PRJ_PPL_ETC_COST1||' SUB_PRJ_EQPMT_ETC_COST1 ='||l_rollup_table1(i).SUB_PRJ_EQPMT_ETC_COST1||
				  ' SUB_PRJ_ETC_Cost2 ='||l_rollup_table1(i).SUB_PRJ_ETC_Cost2||' SUB_PRJ_PPL_ETC_COST2 ='||l_rollup_table1(i).SUB_PRJ_PPL_ETC_COST2||' SUB_PRJ_EQPMT_ETC_COST2 ='||l_rollup_table1(i).SUB_PRJ_EQPMT_ETC_COST2, x_Log_Level=> 3);
				pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'SUB_PRJ_PPL_ETC_EFFORT1 ='||l_rollup_table1(i).SUB_PRJ_PPL_ETC_EFFORT1||' SUB_PRJ_EQPMT_ETC_EFFORT1   ='||l_rollup_table1(i).SUB_PRJ_EQPMT_ETC_EFFORT1||
					' SUB_PRJ_PPL_ETC_EFFORT2 ='||l_rollup_table1(i).SUB_PRJ_PPL_ETC_EFFORT2||' SUB_PRJ_EQPMT_ETC_EFFORT2 ='||l_rollup_table1(i).SUB_PRJ_EQPMT_ETC_EFFORT2, x_Log_Level=> 3);
				pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'EARNED_VALUE1 ='||l_rollup_table1(i).EARNED_VALUE1||' BAC_VALUE1 ='||l_rollup_table1(i).BAC_VALUE1||' EARNED_VALUE2 ='
			    ||l_rollup_table1(i).EARNED_VALUE2||
					' BAC_VALUE2 ='||l_rollup_table1(i).BAC_VALUE2||' BAC_VALUE6 ='||l_rollup_table1(i).BAC_VALUE6, x_Log_Level=> 3);
				pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT',
			  x_Msg =>      'PERC_COMP_DERIVATIVE_CODE1 ='||l_rollup_table1(i).PERC_COMP_DERIVATIVE_CODE1||' PERC_COMP_DERIVATIVE_CODE2 ='||l_rollup_table1(i).PERC_COMP_DERIVATIVE_CODE2, x_Log_Level=> 3);
				pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => '**********************************************************', x_Log_Level=>    3);
		END LOOP;
		pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg   => 'Getting Periods', x_Log_Level=> 3);
		pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg   => 'OU Context='||MO_GLOBAL.get_access_mode, x_Log_Level=> 3);
        END IF;


        BEGIN
	  -- 4746476 : Added org_id in functions call below
          l_prog_pa_period_name := nvl(PA_PROGRESS_UTILS.Prog_Get_Pa_Period_Name(p_as_of_date,l_org_id),null);
          l_prog_gl_period_name := nvl(PA_PROGRESS_UTILS.Prog_Get_GL_Period_Name(p_as_of_date,l_org_id),null);
        EXCEPTION
          WHEN OTHERS THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name               => 'PA_FP_INVALID_DATE_RANGE');
                 x_msg_data :=  'PA_FP_INVALID_DATE_RANGE';
                 x_return_status :=     'E';
                 x_msg_count := fnd_msg_pub.count_msg;
                 RAISE  FND_API.G_EXC_ERROR;
        END ;

        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg   => 'After Getting Periods', x_Log_Level=> 3);



        FOR cur_reverse_tree_rec in cur_reverse_tree_update LOOP
        IF g1_debug_mode   = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'cur_reverse_tree_rec.object_id_to1='||cur_reverse_tree_rec.object_id_to1,      x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'cur_reverse_tree_rec.proj_element_id='||cur_reverse_tree_rec.proj_element_id, x_Log_Level=> 3);
                END IF;

                FOR i in 1..l_rollup_table1.count LOOP
                IF cur_reverse_tree_rec.object_id_to1 = l_rollup_table1(i).object_id AND
                  (l_rollup_table1(i).object_type = 'PA_TASKS' OR l_rollup_table1(i).object_type = 'PA_STRUCTURES')
                  --((p_calling_mode = 'FUTURE_ROLLUP' AND cur_reverse_tree_rec.object_id_to1 <> p_object_version_id)OR p_calling_mode <> 'FUTURE_ROLLUP' OR p_calling_mode IS NULL)
        THEN
                    -- Find the corresponding task rollup record data position
                    task_index  := l_mapping_tasks_to_rollup_tab(i);


                    IF g1_debug_mode  = 'Y' THEN
                         pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_rollup_table1(i).object_id='||l_rollup_table1(i).object_id, x_Log_Level=> 3);
                         pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'task_index='||task_index, x_Log_Level=>       3);
                                END IF;
                    -- Bug 3919211      Begin
                    IF p_structure_type = 'FINANCIAL' AND cur_reverse_tree_rec.object_type = 'PA_STRUCTURES' THEN
                         l_task_id := 0;
                    ELSE
                         l_task_id := cur_reverse_tree_rec.proj_element_id;
                    END IF;
                    -- Bug 3919211 End


                    l_child_rollup_rec_exists := 'N';
                    IF p_rollup_entire_wbs='Y' THEN
                         BEGIN
                                 SELECT 'Y' into l_child_rollup_rec_exists
                                 FROM dual
                                 WHERE exists
                                 (
                                   SELECT       'xyz'
                                   from pa_proj_rollup_temp
                                   WHERE object_id = cur_reverse_tree_rec.object_id_to1
                                   and process_number = l_process_number_temp
                                 );
                         EXCEPTION
                                 WHEN OTHERS THEN
                                   l_child_rollup_rec_exists := 'N';
                         END;
                    END IF;


                    IF p_rollup_entire_wbs='N' OR l_child_rollup_rec_exists = 'Y' THEN


                         l_eff_rollup_status_code := null;
                         l_progress_status_code := null;

                         OPEN cur_status( to_char(l_rollup_table1(i).progress_status_weight1) ); --get the eff rollup status
                         FETCH cur_status INTO l_eff_rollup_status_code;
                         CLOSE cur_status;

                         OPEN cur_status( to_char(l_rollup_table1(i).progress_status_weight2) );  --get the base prog status
                         FETCH cur_status INTO l_progress_status_code;
                         CLOSE cur_status;

                         IF g1_debug_mode  = 'Y' THEN
                                 pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_eff_rollup_status_code='||l_eff_rollup_status_code, x_Log_Level=> 3);
                                 pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_progress_status_code='||l_progress_status_code,     x_Log_Level=>   3);
                         END    IF;


                         -- FPM dev CR 4 : Initialized the values to null
                         l_rolled_up_per_comp :=        null;
                         l_rolled_up_prog_stat := null;
                         l_rolled_up_base_prog_stat := null;
                         l_rolled_up_prog_stat := null;
                         l_remaining_effort1 := null;
                         l_percent_complete1 := null;
                         l_ETC_Cost_PC    :=    null;
                         l_PPL_ETC_COST_PC := null;
                         l_EQPMT_ETC_COST_PC := null;
                         l_ETC_Cost_FC          :=      null;
                         l_PPL_ETC_COST_FC       :=     null;
                         l_EQPMT_ETC_COST_FC := null;
                         l_EQPMT_ETC_EFFORT     := null;
                         l_BAC_VALUE1 := null;
                         l_EARNED_VALUE1 :=     null;
                         l_remaining_effort1 := null;
                         l_EQPMT_ETC_EFFORT     := null;
                         l_OTH_ACT_COST_TO_DATE_PC :=   null;
                         l_PPL_ACT_COST_TO_DATE_PC :=   null;
                         l_EQPMT_ACT_COST_TO_DATE_PC := null;
                         l_OTH_ACT_COST_TO_DATE_FC :=   null;
                         l_PPL_ACT_COST_TO_DATE_FC :=   null;
                         l_EQPMT_ACT_COST_TO_DATE_FC := null;
                         l_PPL_ACT_EFFORT_TO_DATE := null;
                         l_EQPMT_ACT_EFFORT_TO_DATE := null;
                         -- Bug 3621404 : Raw Cost Changes
                         l_OTH_ACT_RAWCOST_TO_DATE_PC   := null;
                         l_PPL_ACT_RAWCOST_TO_DATE_PC   := null;
                         l_EQPMT_ACT_RAWCOST_TO_DATE_PC := null;
                         l_OTH_ACT_RAWCOST_TO_DATE_FC   := null;
                         l_PPL_ACT_RAWCOST_TO_DATE_FC   := null;
                         l_EQPMT_ACT_RAWCOST_TO_DATE_FC := null;
                         l_ETC_RAWCost_PC := null;
                         l_PPL_ETC_RAWCOST_PC :=        null;
                         l_EQPMT_ETC_RAWCOST_PC := null;
                         l_ETC_RAWCost_FC := null;
                         l_PPL_ETC_RAWCOST_FC :=        null;
                         l_EQPMT_ETC_RAWCOST_FC := null;
                         l_actual_start_date := l_rollup_table1(i).start_date1;
                         l_actual_finish_date :=        l_rollup_table1(i).finish_date1;
                         l_estimated_start_date := l_rollup_table1(i).start_date2;
                         l_estimated_finish_date        := l_rollup_table1(i).finish_date2;

                         --OPEN cur_pa_rollup1( cur_reverse_tree_rec.proj_element_id );
                         --FETCH        cur_pa_rollup1  INTO    l_cur_pa_rollup1_rec;
                         --CLOSE cur_pa_rollup1;


                         l_rolled_up_per_comp := l_tsk_over_percent_comp_tab(task_index);
                         l_rolled_up_prog_stat := l_tsk_progress_stat_code_tab(task_index);


                         IF g1_debug_mode  = 'Y' THEN
                                 pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_rolled_up_per_comp='||l_rolled_up_per_comp, x_Log_Level=>   3);
                                 pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_rolled_up_prog_stat='||l_rolled_up_prog_stat,       x_Log_Level=> 3);
                         END IF;

                         IF p_lowest_level_task = 'Y' -- ?? This will just return the initial submitted task    value, we       shd get it for  each    task
                         THEN
                                 -- l_rolled_up_base_per_comp   := nvl(l_rollup_table1(i).percent_complete2,0);
                                 l_rolled_up_base_prog_stat := l_progress_status_code;
                         ELSE
                                 -- l_rolled_up_base_per_comp   := nvl(l_cur_pa_rollup1_rec.base_percent_complete,0);
                                 l_rolled_up_base_prog_stat := l_tsk_base_prog_stat_code_tab(task_index);
                         END IF;


                         l_PROGRESS_ROLLUP_ID := null;
                         l_rollup_rec_ver_number := null;
                         l_percent_complete_id := null;
                         IF l_tsk_progress_rollup_id_tab(task_index) IS NOT NULL AND l_tsk_as_of_date_tab(task_index) = p_as_of_date THEN
                                 l_PROGRESS_ROLLUP_ID := l_tsk_progress_rollup_id_tab(task_index);
                                 l_rollup_rec_ver_number := l_tsk_rollup_rec_ver_num_tab(task_index);
                         END IF;



            IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_PROGRESS_ROLLUP_ID='||l_PROGRESS_ROLLUP_ID, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_rollup_rec_ver_number='||l_rollup_rec_ver_number, x_Log_Level=> 3);
            END IF;

            -- 4392189 : Program Reporting Changes - Phase 2
            -- Having Set2 columns to get Project level % complete

            IF p_structure_type = 'WORKPLAN' THEN
                                 l_percent_complete1 := nvl(round(l_rollup_table1(i).percent_complete1,8),0); --Bug 6854114
                                 l_percent_complete2 := nvl(round(l_rollup_table1(i).percent_complete2,8),0); --Bug 6854114
            ELSE
                                 l_percent_complete1 := nvl(l_rollup_table1(i).percent_complete1,0);
                                 l_percent_complete2 := nvl(l_rollup_table1(i).percent_complete2,0);
            END IF;

                        l_remaining_effort1 := nvl(round(l_rollup_table1(i).remaining_effort1,5),0);
            l_BAC_VALUE1 := nvl(l_rollup_table1(i).BAC_VALUE1,0);

            IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_rollup_table1(i).summary_object_flag='||l_rollup_table1(i).summary_object_flag, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_rollup_table1(i).BAC_VALUE1='||l_rollup_table1(i).BAC_VALUE1, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_rollup_table1(i).EARNED_VALUE1='||l_rollup_table1(i).EARNED_VALUE1, x_Log_Level=> 3);
            END IF;

            l_EARNED_VALUE1 := l_rollup_table1(i).EARNED_VALUE1;

            IF p_wp_rollup_method = 'EFFORT' THEN
                 l_EARNED_VALUE1 := nvl(round(l_EARNED_VALUE1, 5),0);
            ELSE
                 l_EARNED_VALUE1 := nvl(pa_currency.round_trans_currency_amt(l_EARNED_VALUE1, l_prj_currency_code),0);
            END IF;

        --bug 4317491, added a check of WORKPLAN
        IF p_structure_type = 'WORKPLAN' THEN
                        BEGIN
                                 SELECT

                                 /*+    INDEX(pji_fm_xbs_accum_tmp1 pji_fm_xbs_accum_tmp1_n1)*/ -- Fix for Bug # 4162534.
                    PERIOD_NAME
                                 ,      ACT_PRJ_BRDN_COST-ACT_PRJ_EQUIP_BRDN_COST-ACT_PRJ_LABOR_BRDN_COST
                                 ,      ACT_PRJ_LABOR_BRDN_COST
                                 ,      ACT_PRJ_EQUIP_BRDN_COST
                                 ,      ACT_POU_BRDN_COST-ACT_POU_LABOR_BRDN_COST-ACT_POU_EQUIP_BRDN_COST
                                 ,      ACT_POU_LABOR_BRDN_COST
                                 ,      ACT_POU_EQUIP_BRDN_COST
                                 ,      ACT_LABOR_HRS
                                 ,      ACT_EQUIP_HRS
                                 ,      ETC_PRJ_BRDN_COST-ETC_PRJ_EQUIP_BRDN_COST-ETC_PRJ_LABOR_BRDN_COST
                                 ,      ETC_PRJ_LABOR_BRDN_COST
                                 ,      ETC_PRJ_EQUIP_BRDN_COST
                                 ,      ETC_POU_BRDN_COST-ETC_POU_LABOR_BRDN_COST-ETC_POU_EQUIP_BRDN_COST
                                 ,      ETC_POU_LABOR_BRDN_COST
                                 ,      ETC_POU_EQUIP_BRDN_COST
                                 ,      ETC_LABOR_HRS
                                 ,      ETC_EQUIP_HRS
                                 ,      ACT_PRJ_RAW_COST-ACT_PRJ_EQUIP_RAW_COST-ACT_PRJ_LABOR_RAW_COST
                                 ,      ACT_PRJ_LABOR_RAW_COST
                                 ,      ACT_PRJ_EQUIP_RAW_COST
                                 ,      ACT_POU_RAW_COST-ACT_POU_LABOR_RAW_COST-ACT_POU_EQUIP_RAW_COST
                                 ,      ACT_POU_LABOR_RAW_COST
                                 ,      ACT_POU_EQUIP_RAW_COST
                                 ,      ETC_PRJ_RAW_COST-ETC_PRJ_EQUIP_RAW_COST-ETC_PRJ_LABOR_RAW_COST
                                 ,      ETC_PRJ_LABOR_RAW_COST
                                 ,      ETC_PRJ_EQUIP_RAW_COST
                                 ,      ETC_POU_RAW_COST-ETC_POU_LABOR_RAW_COST-ETC_POU_EQUIP_RAW_COST
                                 ,      ETC_POU_LABOR_RAW_COST
                                 ,      ETC_POU_EQUIP_RAW_COST
                                 ,  LABOR_HOURS
                                 ,  EQUIPMENT_HOURS
                                 ,  POU_LABOR_BRDN_COST
                                 ,  PRJ_LABOR_BRDN_COST
                                 ,  POU_EQUIP_BRDN_COST
                                 ,  PRJ_EQUIP_BRDN_COST
                                 ,  POU_BRDN_COST - (     POU_EQUIP_BRDN_COST     + POU_LABOR_BRDN_COST )
                                 ,  PRJ_BRDN_COST - (     PRJ_EQUIP_BRDN_COST     + PRJ_LABOR_BRDN_COST )
                                 ,  POU_LABOR_RAW_COST
                                 ,  PRJ_LABOR_RAW_COST
                                 ,  POU_EQUIP_RAW_COST
                                 ,  PRJ_EQUIP_RAW_COST
                                 ,  POU_RAW_COST  - (     POU_EQUIP_RAW_COST + POU_LABOR_RAW_COST )
                                 ,  PRJ_RAW_COST  - (     PRJ_EQUIP_RAW_COST + PRJ_LABOR_RAW_COST )
                                 INTO
                    l_PERIOD_NAME
                                 ,      l_OTH_ACT_COST_TO_DATE_PC
                                 ,      l_PPL_ACT_COST_TO_DATE_PC
                                 ,      l_EQPMT_ACT_COST_TO_DATE_PC
                                 ,      l_OTH_ACT_COST_TO_DATE_FC
                                 ,      l_PPL_ACT_COST_TO_DATE_FC
                                 ,      l_EQPMT_ACT_COST_TO_DATE_FC
                                 ,      l_PPL_ACT_EFFORT_TO_DATE
                                 ,      l_EQPMT_ACT_EFFORT_TO_DATE
                                 ,      l_ETC_Cost_PC
                                 ,      l_PPL_ETC_COST_PC
                                 ,      l_EQPMT_ETC_COST_PC
                                 ,      l_ETC_Cost_FC
                                 ,      l_PPL_ETC_COST_FC
                                 ,      l_EQPMT_ETC_COST_FC
                                 ,      l_remaining_effort1
                                 ,      l_EQPMT_ETC_EFFORT
                                 ,      l_OTH_ACT_RAWCOST_TO_DATE_PC
                                 ,      l_PPL_ACT_RAWCOST_TO_DATE_PC
                                 ,      l_EQPMT_ACT_RAWCOST_TO_DATE_PC
                                 ,      l_OTH_ACT_RAWCOST_TO_DATE_FC
                                 ,      l_PPL_ACT_RAWCOST_TO_DATE_FC
                                 ,      l_EQPMT_ACT_RAWCOST_TO_DATE_FC
                                 ,      l_ETC_RAWCost_PC
                                 ,      l_PPL_ETC_RAWCOST_PC
                                 ,      l_EQPMT_ETC_RAWCOST_PC
                                 ,      l_ETC_RAWCost_FC
                                 ,      l_PPL_ETC_RAWCOST_FC
                                 ,      l_EQPMT_ETC_RAWCOST_FC
                                 ,      l_LABOR_HOURS
                                 ,      l_EQUIPMENT_HOURS
                                 ,      l_POU_LABOR_BRDN_COST
                                 ,      l_PRJ_LABOR_BRDN_COST
                                 ,      l_POU_EQUIP_BRDN_COST
                                 ,      l_PRJ_EQUIP_BRDN_COST
                                 ,      l_POU_OTH_BRDN_COST
                                 ,      l_PRJ_OTH_BRDN_COST
                                 ,      l_POU_LABOR_RAW_COST
                                 ,      l_PRJ_LABOR_RAW_COST
                                 ,      l_POU_EQUIP_RAW_COST
                                 ,      l_PRJ_EQUIP_RAW_COST
                                 ,      l_POU_OTH_RAW_COST
                                 ,      l_PRJ_OTH_RAW_COST
                                 FROM PJI_FM_XBS_ACCUM_TMP1
                                  WHERE project_id      = p_project_id
                                  AND struct_version_id = p_structure_version_id
                                  AND project_element_id        =       cur_reverse_tree_rec.proj_element_id
                                  AND plan_version_id > 0
                                  AND txn_currency_code is      null
                                  AND calendar_type     = 'A'
                                  AND res_list_member_id        is null;
                         EXCEPTION
                                 WHEN NO_DATA_FOUND     THEN
                                   null;
                                 WHEN OTHERS THEN
                                   fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_PVT',
                                                                   p_procedure_name     => 'ROLLUP_PROGRESS_PVT',
                                                                   p_error_text     => SUBSTRB('Call of PJI_FM_XBS_ACCUM_TMP1 Failed:'||SQLERRM,1,120));
                                   RAISE FND_API.G_EXC_ERROR;
                         END;



                         IF g1_debug_mode  = 'Y'        THEN
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'Printing all the values retrieved from PJI ', x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_OTH_ACT_COST_TO_DATE_PC: '||l_OTH_ACT_COST_TO_DATE_PC, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_PPL_ACT_COST_TO_DATE_PC: '||l_PPL_ACT_COST_TO_DATE_PC, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_EQPMT_ACT_COST_TO_DATE_PC: '||l_EQPMT_ACT_COST_TO_DATE_PC, x_Log_Level=>    3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_OTH_ACT_COST_TO_DATE_FC: '||l_OTH_ACT_COST_TO_DATE_FC, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_PPL_ACT_COST_TO_DATE_FC: '||l_PPL_ACT_COST_TO_DATE_FC, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_EQPMT_ACT_COST_TO_DATE_FC: '||l_EQPMT_ACT_COST_TO_DATE_FC, x_Log_Level=>    3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_PPL_ACT_EFFORT_TO_DATE: '||l_PPL_ACT_EFFORT_TO_DATE,        x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_EQPMT_ACT_EFFORT_TO_DATE: '||l_EQPMT_ACT_EFFORT_TO_DATE, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_ETC_Cost_PC:        '||l_ETC_Cost_PC, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_PPL_ETC_COST_PC: '||l_PPL_ETC_COST_PC, x_Log_Level=>        3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_EQPMT_ETC_COST_PC: '||l_EQPMT_ETC_COST_PC,  x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_ETC_Cost_FC:        '||l_ETC_Cost_FC, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_PPL_ETC_COST_FC: '||l_PPL_ETC_COST_FC, x_Log_Level=>        3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_EQPMT_ETC_COST_FC: '||l_EQPMT_ETC_COST_FC,  x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_remaining_effort1: '||l_remaining_effort1,  x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_EQPMT_ETC_EFFORT:   '||l_EQPMT_ETC_EFFORT, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_OTH_ACT_RAWCOST_TO_DATE_PC: '||l_OTH_ACT_RAWCOST_TO_DATE_PC, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_PPL_ACT_RAWCOST_TO_DATE_PC: '||l_PPL_ACT_RAWCOST_TO_DATE_PC, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_EQPMT_ACT_RAWCOST_TO_DATE_PC: '||l_EQPMT_ACT_RAWCOST_TO_DATE_PC, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_OTH_ACT_RAWCOST_TO_DATE_FC: '||l_OTH_ACT_RAWCOST_TO_DATE_FC, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_PPL_ACT_RAWCOST_TO_DATE_FC: '||l_PPL_ACT_RAWCOST_TO_DATE_FC, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_EQPMT_ACT_RAWCOST_TO_DATE_FC: '||l_EQPMT_ACT_RAWCOST_TO_DATE_FC, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_ETC_RAWCost_PC: '||l_ETC_RAWCost_PC, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_PPL_ETC_RAWCOST_PC: '||l_PPL_ETC_RAWCOST_PC,        x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_EQPMT_ETC_RAWCOST_PC: '||l_EQPMT_ETC_RAWCOST_PC, x_Log_Level=>      3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_ETC_RAWCost_FC: '||l_ETC_RAWCost_FC, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_PPL_ETC_RAWCOST_FC: '||l_PPL_ETC_RAWCOST_FC,        x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_EQPMT_ETC_RAWCOST_FC: '||l_EQPMT_ETC_RAWCOST_FC, x_Log_Level=>      3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_LABOR_HOURS:        '||l_LABOR_HOURS, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_EQUIPMENT_HOURS: '||l_EQUIPMENT_HOURS, x_Log_Level=>        3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_POU_LABOR_BRDN_COST: '||l_POU_LABOR_BRDN_COST, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_PRJ_LABOR_BRDN_COST: '||l_PRJ_LABOR_BRDN_COST, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_POU_EQUIP_BRDN_COST: '||l_POU_EQUIP_BRDN_COST, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_PRJ_EQUIP_BRDN_COST: '||l_PRJ_EQUIP_BRDN_COST, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_POU_OTH_BRDN_COST: '||l_POU_OTH_BRDN_COST,  x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_PRJ_OTH_BRDN_COST: '||l_PRJ_OTH_BRDN_COST,  x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_POU_LABOR_RAW_COST: '||l_POU_LABOR_RAW_COST,        x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_PRJ_LABOR_RAW_COST: '||l_PRJ_LABOR_RAW_COST,        x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_POU_EQUIP_RAW_COST: '||l_POU_EQUIP_RAW_COST,        x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_PRJ_EQUIP_RAW_COST: '||l_PRJ_EQUIP_RAW_COST,        x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_POU_OTH_RAW_COST:   '||l_POU_OTH_RAW_COST, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_PRJ_OTH_RAW_COST:   '||l_PRJ_OTH_RAW_COST, x_Log_Level=> 3);
                         END IF;

                         /* 5726773                         --bug 3829341
                         --bug 3824042, the check       for whether exisitng etc(l_cur_rollup_rec. )
                         -- is null is  not required as we are always   taking from pji.

                         IF     ( L_EQPMT_ETC_EFFORT IS NULL AND L_EQUIPMENT_HOURS      >= L_EQPMT_ACT_EFFORT_TO_DATE)
                         THEN
                                 L_EQPMT_ETC_EFFORT     := (L_EQUIPMENT_HOURS - L_EQPMT_ACT_EFFORT_TO_DATE);
                         END    IF;

                         IF L_EQPMT_ETC_EFFORT <        0
                         THEN
                                 L_EQPMT_ETC_EFFORT     :=0;
                         END    IF;

                         IF (L_REMAINING_EFFORT1        IS NULL AND L_LABOR_HOURS >= L_PPL_ACT_EFFORT_TO_DATE)   THEN
                                 L_REMAINING_EFFORT1 := (L_LABOR_HOURS - L_PPL_ACT_EFFORT_TO_DATE);
                         END    IF;

                         IF L_REMAINING_EFFORT1 <0
                         THEN
                                 L_REMAINING_EFFORT1 := 0;
                         END    IF;

                         IF ( L_ETC_COST_FC     IS NULL AND     L_POU_OTH_BRDN_COST     >= L_OTH_ACT_COST_TO_DATE_FC)   THEN
                                 L_ETC_COST_FC:= L_POU_OTH_BRDN_COST - L_OTH_ACT_COST_TO_DATE_FC;
                         END    IF;

                         IF L_ETC_COST_FC <     0
                         THEN
                                 L_ETC_COST_FC  := 0;
                         END    IF;

                         IF (L_ETC_COST_PC IS NULL AND L_PRJ_OTH_BRDN_COST >= L_OTH_ACT_COST_TO_DATE_PC) THEN
                                 L_ETC_COST_PC:= L_PRJ_OTH_BRDN_COST - L_OTH_ACT_COST_TO_DATE_PC;
                         END    IF;

                         IF L_ETC_COST_PC <0
                         THEN
                                 L_ETC_COST_PC  :=0;
                         END    IF;

                         IF (L_PPL_ETC_COST_FC IS NULL AND      L_POU_LABOR_BRDN_COST >=        L_PPL_ACT_COST_TO_DATE_FC) THEN
                                 L_PPL_ETC_COST_FC      := (L_POU_LABOR_BRDN_COST - L_PPL_ACT_COST_TO_DATE_FC);
                         END    IF;

                         IF L_PPL_ETC_COST_FC <0
                         THEN
                                 L_PPL_ETC_COST_FC      :=0;
                         END    IF;

                         IF (L_PPL_ETC_COST_PC IS NULL AND      L_PRJ_LABOR_BRDN_COST >=        L_PPL_ACT_COST_TO_DATE_PC) THEN
                                 L_PPL_ETC_COST_PC      := (L_PRJ_LABOR_BRDN_COST - L_PPL_ACT_COST_TO_DATE_PC);
                         END    IF;

                         IF L_PPL_ETC_COST_PC <0
                         THEN
                                 L_PPL_ETC_COST_PC      :=0;
                         END    IF;

                         IF ( L_EQPMT_ETC_COST_FC IS NULL AND L_POU_EQUIP_BRDN_COST     >= L_EQPMT_ACT_COST_TO_DATE_FC) THEN
                         L_EQPMT_ETC_COST_FC := (L_POU_EQUIP_BRDN_COST -        L_EQPMT_ACT_COST_TO_DATE_FC);
                         END    IF;

                         IF L_EQPMT_ETC_COST_FC <0
                         THEN
                         L_EQPMT_ETC_COST_FC :=0;
                         END    IF;

                         IF (L_EQPMT_ETC_COST_PC        IS NULL AND L_PRJ_EQUIP_BRDN_COST >= L_EQPMT_ACT_COST_TO_DATE_PC)  THEN
                                 L_EQPMT_ETC_COST_PC := (L_PRJ_EQUIP_BRDN_COST - L_EQPMT_ACT_COST_TO_DATE_PC);
                         END    IF;

                         IF L_EQPMT_ETC_COST_PC <0
                         THEN
                                 L_EQPMT_ETC_COST_PC :=0;
                         END    IF;

                         IF (L_ETC_RAWCOST_FC IS        NULL    AND L_POU_OTH_RAW_COST >=       L_OTH_ACT_RAWCOST_TO_DATE_FC)    THEN
                                 L_ETC_RAWCOST_FC:=     L_POU_OTH_RAW_COST - L_OTH_ACT_RAWCOST_TO_DATE_FC;
                         END    IF;

                         IF L_ETC_RAWCOST_FC <0
                         THEN
                                 L_ETC_RAWCOST_FC :=0;
                         END    IF;

                         IF (L_ETC_RAWCOST_PC IS        NULL    AND L_PRJ_OTH_RAW_COST >=       L_OTH_ACT_RAWCOST_TO_DATE_PC)   THEN
                                 L_ETC_RAWCOST_PC:=     L_PRJ_OTH_RAW_COST - L_OTH_ACT_RAWCOST_TO_DATE_PC;
                         END    IF;

                         IF L_ETC_RAWCOST_PC <0
                         THEN
                                 L_ETC_RAWCOST_PC :=0;
                         END    IF;

                         IF (L_PPL_ETC_RAWCOST_FC IS NULL AND L_POU_LABOR_RAW_COST >= L_PPL_ACT_RAWCOST_TO_DATE_FC) THEN
                                 L_PPL_ETC_RAWCOST_FC :=        (L_POU_LABOR_RAW_COST - L_PPL_ACT_RAWCOST_TO_DATE_FC);
                         END    IF;

                         IF L_PPL_ETC_RAWCOST_FC        <0
                         THEN
                                 L_PPL_ETC_RAWCOST_FC :=0;
                         END    IF;

                         IF (L_PPL_ETC_RAWCOST_PC IS NULL AND L_PRJ_LABOR_RAW_COST >= L_PPL_ACT_RAWCOST_TO_DATE_PC) THEN
                                 L_PPL_ETC_RAWCOST_PC :=        (L_PRJ_LABOR_RAW_COST - L_PPL_ACT_RAWCOST_TO_DATE_PC);
                         END    IF;

                         IF L_PPL_ETC_RAWCOST_PC        <0
                         THEN
                                 L_PPL_ETC_RAWCOST_PC :=0;
                         END    IF;

                         IF ( L_EQPMT_ETC_RAWCOST_FC IS NULL    AND L_POU_EQUIP_RAW_COST        >= L_EQPMT_ACT_RAWCOST_TO_DATE_FC)      THEN
                         L_EQPMT_ETC_RAWCOST_FC := (L_POU_EQUIP_RAW_COST        - L_EQPMT_ACT_RAWCOST_TO_DATE_FC);
                         END    IF;

                         IF L_EQPMT_ETC_RAWCOST_FC <0
                         THEN
                                 L_EQPMT_ETC_RAWCOST_FC :=0;
                         END    IF;

                         IF ( L_EQPMT_ETC_RAWCOST_PC IS NULL    AND L_PRJ_EQUIP_RAW_COST        >= L_EQPMT_ACT_RAWCOST_TO_DATE_PC)      THEN
                                 L_EQPMT_ETC_RAWCOST_PC :=      (L_PRJ_EQUIP_RAW_COST - L_EQPMT_ACT_RAWCOST_TO_DATE_PC);
                         END    IF;

                         IF L_EQPMT_ETC_RAWCOST_PC <0
                         THEN
                                 L_EQPMT_ETC_RAWCOST_PC :=0;
                         END    IF;
*/

                         IF p_working_wp_prog_flag = 'Y' OR l_published_structure =     'N'
                         --for working  version p_working_wp_prog_flag may      not be 'Y' because of   bug 3846353
                         THEN
                                 l_EQPMT_ETC_EFFORT     := null;
                                 l_remaining_effort1:= null;
                                 l_ETC_Cost_FC:= null;
                                 l_ETC_Cost_PC:= null;
                                 l_PPL_ETC_COST_FC:= null;
                                 l_PPL_ETC_COST_PC      := null;
                                 l_EQPMT_ETC_COST_FC:= null;
                                 l_EQPMT_ETC_COST_PC:= null;
                                 l_ETC_RAWCost_FC:=     null;
                                 l_ETC_RAWCost_PC := null;
                                 l_PPL_ETC_RAWCOST_FC:= null;
                                 l_PPL_ETC_RAWCOST_PC:= null;
                                 l_EQPMT_ETC_RAWCOST_FC:= null;
                                 l_EQPMT_ETC_RAWCOST_PC:= null;
                         END    IF;

                         -- Bug 3922325 : Move the task status Defauilting logic from above after Extraction of Actuals
                         IF g1_debug_mode  = 'Y' THEN
                                 pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'Defaulting of Task Status', x_Log_Level=> 3);
                                 pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_rollup_table1(i).task_statusl       ='||l_rollup_table1(i).task_status1, x_Log_Level=> 3);
                                 pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_rollup_table1(i).percent_complete1 ='||l_rollup_table1(i).percent_complete1, x_Log_Level=> 3);
                         END    IF;

                         IF cur_reverse_tree_rec.object_type = 'PA_TASKS' THEN

                                  --do not rollup on-hold task status. We dont need to worry   about
                                  --cancelled bcoz they are not selected.

                                 -- If Actual exists or Deliverable is In Progress for the task, Then Task SHould be In Progress
                                 l_actual_exists := 'N';
                                 ---5726773  changed '>0' to '<>0'
 	                         IF (l_PPL_ACT_EFFORT_TO_DATE   <> 0 OR l_EQPMT_ACT_EFFORT_TO_DATE <>0 OR l_OTH_ACT_COST_TO_DATE_PC <> 0) THEN
                                   IF g1_debug_mode      = 'Y' THEN
                                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'Actual Exists', x_Log_Level=> 3);
                                   END IF;
                                   l_actual_exists := 'Y';
                                 END    IF;

                                 IF l_actual_exists = 'N' THEN -- Added This IF for performance: No need to open this if variable is already set to Y
                                   -- 14-Feb-2005 Patched thru Bug      4180026
                                   OPEN c_get_dlv_status(cur_reverse_tree_rec.proj_element_id);
                                   FETCH c_get_dlv_status INTO l_actual_exists;
                                   CLOSE c_get_dlv_status;
                                 END    IF;

                                 IF g1_debug_mode = 'Y' THEN
                                   pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_actual_exists='||l_actual_exists, x_Log_Level=> 3);
                                 END    IF;

                                 IF ( ( nvl(l_rollup_table1(i).task_status1,0) <> 0 )
                                   OR
                                   ( l_percent_complete1 > 0 OR  l_rolled_up_per_comp > 0 )
                                   OR l_actual_exists = 'Y'
                                 )      THEN
                                   -- Bug        3842084 : Initilaized l_status_code with l_existing_object_status
                                         --get the existing      status
                                   OPEN  c_get_object_status ( p_project_id, cur_reverse_tree_rec.proj_element_id);
                                         FETCH c_get_object_status INTO l_existing_object_status;
                                         CLOSE c_get_object_status;

                                   l_status_code := l_existing_object_status;
                                   l_system_status_code := PA_PROGRESS_UTILS.get_system_task_status( l_status_code ); --Bug#5374114
                                   l_status_code_temp := l_status_code; --Bug#5374114
                                   l_system_status_code_temp := l_system_status_code; --Bug#5374114

                                         IF ( nvl(l_rollup_table1(i).task_status1,0)    <>      0 )
                                         THEN
                                        OPEN     cur_task_status (      to_char(l_rollup_table1(i).task_status1) );
                                                 FETCH cur_task_status INTO l_status_code;
                                        CLOSE cur_task_status;
                                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_status_code ='||l_status_code, x_Log_Level=> 3);
                                   END IF;
                                   -- Now       Defaulting of   Status will happen even if the status is returned by Scheuling API, but it is wrong

                                         l_system_status_code := PA_PROGRESS_UTILS.get_system_task_status( l_status_code ); -- Bug 3956299
                                   IF g1_debug_mode      = 'Y' THEN
                                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_status_code='||l_status_code, x_Log_Level=> 3);
                                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_existing_object_status='||l_existing_object_status, x_Log_Level=> 3);
                                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_system_status_code='||l_system_status_code, x_Log_Level=> 3);
                                   END IF;

                                         IF (NVL(l_rolled_up_per_comp, l_percent_complete1) = 100 AND l_system_status_code <> 'COMPLETED')
                                         THEN
                                        l_status_code := '127';
                                        l_system_status_code := 'COMPLETED';
                                         ELSIF (((NVL(l_rolled_up_per_comp, l_percent_complete1) > 0 AND NVL(l_rolled_up_per_comp, l_percent_complete1)  < 100)) AND l_system_status_code        IN ('NOT_STARTED','COMPLETED'))
                                         THEN
                                        l_status_code := '125';
                                        l_system_status_code := 'IN_PROGRESS';
                                        l_actual_finish_date := null;
                                   -- This is done to first time make task In Progress  if any sub-objects are in Progress
                                   ELSIF (l_actual_exists ='Y' AND      l_system_status_code    = 'NOT_STARTED')
                                   THEN
                                        l_status_code := '125';
                                        l_system_status_code := 'IN_PROGRESS';
                                        l_actual_finish_date := null;
                                   END IF;

/* Changes by shanif for bug#5374114 - START */

                    IF (l_system_status_code = l_system_status_code_temp) THEN
                        l_system_status_code := l_system_status_code_temp;
                        l_status_code  := l_status_code_temp;
                    END IF;

/* Changes by shanif for bug#5374114 - END */

                                   IF g1_debug_mode      = 'Y' THEN
                                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'After Defaulting l_status_code='||l_status_code, x_Log_Level=> 3);
                                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'After Defaulting l_system_status_code='||l_system_status_code, x_Log_Level=> 3);
                                   END IF;

                                   IF l_structure_version_id IS NULL THEN -- Bug 3922325  : This  does    not make sense  for     working wp version rollup
                                        UPDATE pa_proj_elements
                                        SET status_code = l_status_code
                                        WHERE project_id = p_project_id
                                        AND proj_element_id     = cur_reverse_tree_rec.proj_element_id;
                                   END IF;


                                   IF p_structure_type = 'WORKPLAN' THEN
                                        OPEN c_get_dates (p_project_id, cur_reverse_tree_rec.object_id_to1);
                                        FETCH c_get_dates INTO l_tsk_scheduled_start_date, l_tsk_scheduled_finish_date;
                                        CLOSE c_get_dates;
                                        IF l_actual_start_date IS NULL AND l_system_status_code = 'IN_PROGRESS' THEN
                                                l_actual_start_date := nvl(l_estimated_start_date,l_tsk_scheduled_start_date);
                                                l_actual_finish_date := to_date(null);
                                        END IF;
                    -- Bug 4232099 : added folling IF
                    IF l_actual_finish_date IS NOT NULL AND l_system_status_code = 'IN_PROGRESS' THEN
                        l_actual_finish_date := to_date(null);
                    END IF;
                                        IF l_actual_start_date IS NULL AND l_system_status_code = 'COMPLETED' THEN
                                                l_actual_start_date := nvl(l_estimated_start_date,l_tsk_scheduled_start_date);
                                        END IF;
                                        IF l_actual_finish_date IS NULL AND l_system_status_code = 'COMPLETED' THEN
                                                l_actual_finish_date := nvl(l_estimated_finish_date,l_tsk_scheduled_finish_date);
                                        END IF;

                                        IF l_actual_start_date IS NOT NULL AND l_actual_finish_date IS NOT NULL     THEN
                                                IF l_actual_finish_date < l_actual_start_date THEN
                                                  IF TRUNC(SYSDATE)  < l_actual_start_date THEN
                                                          l_actual_finish_date := l_actual_start_date;
                                                  ELSE
                                                          l_actual_finish_date := TRUNC(SYSDATE);
                                                  END IF;
                                                END IF;
                                        END IF;
                                   END IF;

                                   UPDATE pa_percent_completes
                                   SET status_code = l_status_code
                                   , actual_start_date = l_actual_start_date     --      Bug 3956299
                                   , actual_finish_date = l_actual_finish_date -- Bug   3956299
                                   WHERE object_id = cur_reverse_tree_rec.proj_element_id
                                   AND object_Type = cur_reverse_tree_rec.object_Type ---4743866
                                   AND project_id = p_project_id
                                   --AND PA_PROGRESS_UTILS.get_system_task_status( status_code )        NOT IN  ( 'CANCELLED',  'COMPLETED' )
                                   AND PA_PROGRESS_UTILS.get_system_task_status( status_code ) NOT IN   (       'CANCELLED' ) -- 02/06/04 Satish
                                   AND structure_type = p_structure_type --     FPM     Dev CR 3
                                   AND current_flag = 'N' and published_flag  = 'N'
                                   ;

                                   -- 14-Feb-2005 :     Added Patched thru Bug 4180026
                                   UPDATE pa_percent_completes
                                   SET status_code = l_status_code
                                   , actual_start_date = l_actual_start_date     --      Bug 3956299
                                   , actual_finish_date = l_actual_finish_date -- Bug   3956299
                                   WHERE object_id = cur_reverse_tree_rec.proj_element_id
                                   AND object_Type = cur_reverse_tree_rec.object_Type ---4743866
                                   AND project_id = p_project_id
                                   AND PA_PROGRESS_UTILS.get_system_task_status( status_code ) NOT IN   (       'CANCELLED' ) -- 02/06/04 Satish
                                   AND structure_type = p_structure_type --     FPM     Dev CR 3
                                   AND published_flag = 'Y' ---4743866
                                   AND current_flag = 'Y'
                                   AND trunc(date_computed) = trunc(p_as_of_date)
                                   ;

                                 END    IF;
                         END    IF;

                         IF NVL(l_track_wp_cost_flag,'Y') = 'N' THEN
                                 l_ETC_Cost_FC:= null;
                                 l_ETC_Cost_PC:= null;
                                 l_PPL_ETC_COST_FC:= null;
                                 l_PPL_ETC_COST_PC      := null;
                                 l_EQPMT_ETC_COST_FC:= null;
                                 l_EQPMT_ETC_COST_PC:= null;
                                 l_ETC_RAWCost_FC:=     null;
                                 l_ETC_RAWCost_PC := null;
                                 l_PPL_ETC_RAWCOST_FC:= null;
                                 l_PPL_ETC_RAWCOST_PC:= null;
                                 l_EQPMT_ETC_RAWCOST_FC:= null;
                                 l_EQPMT_ETC_RAWCOST_PC:= null;
                                 l_OTH_ACT_COST_TO_DATE_PC:= null;
                                 l_OTH_ACT_COST_TO_DATE_FC:= null;
                                 l_PPL_ACT_COST_TO_DATE_PC:= null;
                                 l_PPL_ACT_COST_TO_DATE_FC:= null;
                                 l_EQPMT_ACT_COST_TO_DATE_PC:= null;
                                 l_EQPMT_ACT_COST_TO_DATE_FC:= null;
                                 l_OTH_ACT_RAWCOST_TO_DATE_PC:= null;
                                 l_OTH_ACT_RAWCOST_TO_DATE_FC:= null;
                                 l_PPL_ACT_RAWCOST_TO_DATE_PC:= null;
                                 l_PPL_ACT_RAWCOST_TO_DATE_FC:= null;
                                 l_EQPMT_ACT_RAWCOST_TO_DATE_PC:= null;
                                 l_EQPMT_ACT_RAWCOST_TO_DATE_FC:= null;
                        END IF;


                END IF; -- IF  p_structure_type = 'WORKPLAN' --bug 4317491


		-- Bug 4651304 Begin
		-- One solution for this issue could be to pass
		-- p_upd_new_elem_ver_id_flag as 'N' from rollup API call in
		-- program_rollup_pvt, rollup_future_progress_pvt, and recursive call of Rollup API
		-- within Rollup API. This solution works for Case 1 and Case2, but not Case 3
		-- Best way is to always retain the existing object_version_id in pa_progress_rollup
		-- table in case of update, in case of insert, use the new object version id

		-- Commented below code and added new condition


		--IF p_upd_new_elem_ver_id_flag = 'Y' THEN
		--	l_tsk_object_version_id_tab(task_index) := l_rollup_table1(i).object_id;
		--END IF;

		IF l_PROGRESS_ROLLUP_ID IS NOT NULL AND l_tsk_object_version_id_tab(task_index) IS NOT NULL AND p_structure_type = 'WORKPLAN' AND l_published_structure = 'Y' THEN
			null; -- Don't do anything .. let l_tsk_object_version_id_tab old value to be retained
		ELSE
			l_tsk_object_version_id_tab(task_index) := l_rollup_table1(i).object_id;
		END IF;
		-- Bug 4651304 End

		l_tsk_proj_element_id_tab(task_index) := l_task_id;
		l_tsk_roll_comp_percent_tab(task_index) := l_percent_complete1;
                    -- 4392189 : Program Reporting Changes - Phase 2
                    -- Having Set2 columns to get Project level % complete
                                        -- 4506461 l_tsk_base_percent_comp_tab(task_index) := l_percent_complete2;
                    -- Bug 4506461 Begin
                    l_tsk_base_percent_comp_tab(task_index) := nvl(l_tsk_over_percent_comp_tab(task_index),l_percent_complete1);
                    -- 4540890 : Removed l_subproject_found check from below
                    IF p_structure_type = 'WORKPLAN' THEN --AND l_subproject_found = 'Y' THEN
                        l_rederive_base_pc := 'N';
                        OPEN c_get_any_childs_have_subprj(l_rollup_table1(i).object_id);
                        FETCH c_get_any_childs_have_subprj INTO l_rederive_base_pc;
                        CLOSE c_get_any_childs_have_subprj;
                        IF nvl(l_rederive_base_pc,'N') = 'Y' THEN
                            l_tsk_base_percent_comp_tab(task_index) := l_percent_complete2;
                        END IF;
                    END IF;
                    -- Bug 4506461 End

                    l_tsk_earned_value_tab(task_index) := l_earned_value1;
                                        l_tsk_task_wt_basis_code_tab(task_index) := l_rollup_method;
                                        l_tsk_structure_version_id_tab(task_index) := l_structure_version_id;


                                        IF p_structure_type = 'WORKPLAN' THEN
                                                l_tsk_est_start_date_tab(task_index) := l_rollup_table1(i).start_date2;
                                                l_tsk_est_finish_date_tab(task_index) := l_rollup_table1(i).finish_date2;
                                                l_tsk_actual_start_date_tab(task_index) := l_actual_start_date;
                                                l_tsk_actual_finish_date_tab(task_index) := l_actual_finish_date;
						-- 4533112 : Base Progress Status is not used
                                                --l_tsk_base_prog_stat_code_tab(task_index) :=    l_rolled_up_base_prog_stat;
                                                l_tsk_EFF_ROLL_PRG_ST_CODE_tab(task_index) := l_eff_rollup_status_code;

                                                IF p_progress_mode <> 'BACKDATED' THEN
                                                        l_tsk_ppl_act_eff_tab(task_index) := l_ppl_act_effort_to_date;
                                                        l_tsk_ppl_act_cost_pc_tab(task_index) := l_ppl_act_cost_to_date_pc;
                                                        l_tsk_ppl_act_cost_fc_tab(task_index) := l_ppl_act_cost_to_date_fc;
                                                        l_tsk_ppl_act_rawcost_pc_tab(task_index) := l_ppl_act_rawcost_to_date_pc;
                                                        l_tsk_ppl_act_rawcost_fc_tab(task_index) := l_ppl_act_rawcost_to_date_fc;
                                                        l_tsk_est_rem_effort_tab(task_index) := l_remaining_effort1;
                                                        l_tsk_ppl_etc_cost_pc_tab(task_index) := l_ppl_etc_cost_pc;
                                                        l_tsk_ppl_etc_cost_fc_tab(task_index) := l_ppl_etc_cost_fc;
                                                        l_tsk_ppl_etc_rawcost_pc_tab(task_index) := l_ppl_etc_rawcost_pc;
                                                        l_tsk_ppl_etc_rawcost_fc_tab(task_index) := l_ppl_etc_rawcost_fc;

                                                        l_tsk_eqpmt_act_effort_tab(task_index) := l_eqpmt_act_effort_to_date;
                                                        l_tsk_eqpmt_act_cost_pc_tab(task_index) := l_eqpmt_act_cost_to_date_pc;
                                                        l_tsk_eqpmt_act_cost_fc_tab(task_index) := l_eqpmt_act_cost_to_date_fc;
                                                        l_tsk_eqpmt_act_rawcost_pc_tab(task_index) := l_eqpmt_act_rawcost_to_date_pc;
                                                        l_tsk_eqpmt_act_rawcost_fc_tab(task_index) := l_eqpmt_act_rawcost_to_date_fc;
                                                        l_tsk_eqpmt_etc_effort_tab(task_index) := l_eqpmt_etc_effort;
                                                        l_tsk_eqpmt_etc_cost_pc_tab(task_index) := l_eqpmt_etc_cost_pc;
                                                        l_tsk_eqpmt_etc_cost_fc_tab(task_index) := l_eqpmt_etc_cost_fc;
                                                        l_tsk_eqpmt_etc_rawcost_pc_tab(task_index) := l_eqpmt_etc_rawcost_pc;
                                                        l_tsk_eqpmt_etc_rawcost_fc_tab(task_index) := l_eqpmt_etc_rawcost_fc;

                                                        l_tsk_oth_act_cost_pc_tab(task_index) := l_oth_act_cost_to_date_pc;
                                                        l_tsk_oth_act_cost_fc_tab(task_index) := l_oth_act_cost_to_date_fc;
                                                        l_tsk_oth_act_rawcost_pc_tab(task_index) := l_oth_act_rawcost_to_date_pc;
                                                        l_tsk_oth_act_rawcost_fc_tab(task_index) := l_oth_act_rawcost_to_date_fc;
                                                        l_tsk_oth_etc_cost_pc_tab(task_index) := l_etc_cost_pc;
                                                        l_tsk_oth_etc_cost_fc_tab(task_index) := l_etc_cost_fc;
                                                        l_tsk_oth_etc_rawcost_pc_tab(task_index) := l_etc_rawcost_pc;
                                                        l_tsk_oth_etc_rawcost_fc_tab(task_index) := l_etc_rawcost_fc;

                                                END IF; -- p_progress_mode <> 'BACKDATED'

                                                -- 5119716 Begin
                                                -- In early Rollup API, there used to be call of PA_TASK_PUB1.update_schedule_version API
                                                -- For performance changes, it was removed and replaced with direct update statement
                                                -- The follwoing portion for dirty schedule was missing out.
                                                IF PA_PROJECT_STRUCTURE_UTILS.CHECK_THIRD_PARTY_SCH_FLAG(p_project_id)= 'Y' THEN

                                                        PA_PROJECT_STRUCTURE_PVT1.update_sch_dirty_flag(
                                                                p_structure_version_id  => p_structure_version_id
                                                                ,p_dirty_flag           => 'Y'
                                                                ,x_return_status        => x_return_status
                                                                ,x_msg_count            => x_msg_count
                                                                ,x_msg_data             => x_msg_data
                                                                );

                                                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                                raise FND_API.G_EXC_ERROR;
                                                        END IF;

                                                END IF;
                                                -- 5119716 End

                                                 UPDATE pa_proj_elem_ver_schedule
                                                 SET    ACTUAL_START_DATE = l_actual_start_date
                                                 , ACTUAL_FINISH_DATE = l_actual_finish_date
                                                 , ESTIMATED_START_DATE = l_rollup_table1(i).start_date2
                                                 , ESTIMATED_FINISH_DATE = l_rollup_table1(i).finish_date2
                                                 , record_version_number = record_version_number+1
                                                 -- 5119716 Begin
                                                 , estimated_duration = trunc(l_rollup_table1(i).finish_date2) - trunc(l_rollup_table1(i).start_date2) + 1
                                                 , actual_duration = trunc(l_actual_finish_date) - trunc(l_actual_start_date) + 1
                                                 -- 5119716 End
                                                 , last_updated_by = l_user_id
                                                 , last_update_date= sysdate
                                                 , last_update_login = l_login_id
                                                 WHERE project_id = p_project_id
                                                 AND element_version_id = l_rollup_table1(i).object_id;


                                                IF l_rollup_table1(i).object_type = 'PA_STRUCTURES' THEN
                                                        UPDATE pa_projects_all
                                                        SET actual_start_date = l_rollup_table1(i).start_date1,
                                                            actual_finish_date = l_rollup_table1(i).finish_date1
                                                        WHERE project_id = p_project_id;
                                                END IF;
                                        END IF; -- p_structure_type     = 'WORKPLAN'

                    IF l_PROGRESS_ROLLUP_ID IS NOT NULL THEN
                        l_tsk_update_required(task_index):='Y';
                    ELSE
                        -- Bug 4320336 : Added the following condition for FUTURE_ROLLUP
                        IF p_calling_mode <> 'FUTURE_ROLLUP' OR p_calling_mode IS NULL THEN
                            l_tsk_create_required(task_index):='Y';
                            BEGIN
                                SELECT percent_complete_id
                                INTO l_percent_complete_id
                                FROM pa_percent_completes
                                WHERE project_id = p_project_id
                                AND object_id =  cur_reverse_tree_rec.proj_element_id
                                AND object_Type = l_rollup_table1(i).object_Type
                                AND structure_type = p_structure_type
                                AND date_computed = ( SELECT max(date_computed)
                                            FROM    pa_percent_completes
                                            WHERE project_id = p_project_id
                                            AND object_id =  cur_reverse_tree_rec.proj_element_id
                                            AND object_Type = l_rollup_table1(i).object_Type
                                            AND structure_type = p_structure_type
                                            AND date_computed <= p_as_of_date);
                            EXCEPTION WHEN OTHERS THEN
                                l_percent_complete_id := null;
                            END;
                            l_max_rollup_as_of_date2 := PA_PROGRESS_UTILS.get_max_rollup_asofdate2
                                            (p_project_id   => p_project_id,
                                            p_object_id     => cur_reverse_tree_rec.proj_element_id,
                                            p_object_type   => l_rollup_table1(i).object_type,
                                            p_structure_type =>     p_structure_type,
                                            p_structure_version_id => l_structure_version_id,
                                            p_proj_element_id => cur_reverse_tree_rec.proj_element_id
                                     );

                            IF l_max_rollup_as_of_date2 > p_as_of_date  THEN
                                l_current_flag  := 'N';
                            ELSE
                                l_current_flag  := 'Y';
                            END IF;
                            l_tsk_current_flag_tab(task_index)      := l_current_flag;
                            l_tsk_prog_pa_period_name_tab(task_index) :=    l_prog_pa_period_name;
                            l_tsk_prog_gl_period_name_tab(task_index) :=    l_prog_gl_period_name;


                            IF l_max_rollup_as_of_date2 < p_as_of_date THEN
                                UPDATE pa_progress_rollup
                                   SET current_flag = 'N'
                                 WHERE project_id = p_project_id
                                   AND object_id = cur_reverse_tree_rec.proj_element_id
                                   AND object_type = l_rollup_table1(i).object_type
                                   AND current_flag <> 'W'
                                   AND structure_type = p_structure_type
                                   AND ((l_published_structure = 'Y'   AND structure_version_id is null) OR (l_published_structure =        'N' AND structure_version_id =  p_structure_version_id))
                                   ;
                            END IF;
                        END IF; -- IF p_calling_mode <> 'FUTURE_ROLLUP' OR p_calling_mode IS NULL THEN
                    END IF; -- l_PROGRESS_ROLLUP_ID IS NOT NULL THEN
                END IF;--       p_rollup_entire_wbs='N' OR l_child_rollup_rec_exists =  'Y'
                exit;
            END IF; -- cur_reverse_tree_rec.object_id_to1 = p_rollup_table(i).object_id
        END LOOP;
        END LOOP;

        FORALL i in 1..l_tsk_object_version_id_tab.count
                UPDATE pa_progress_rollup
                SET
                object_version_id = l_tsk_object_version_id_tab(i)
                , last_update_date = sysdate
                , last_updated_by = l_user_id
                , last_update_login = l_login_id
                , eff_rollup_percent_comp = l_tsk_roll_comp_percent_tab(i)
                , completed_percentage = decode(p_progress_mode,'TRANSFER_WP_PC', l_tsk_roll_comp_percent_tab(i), completed_percentage)
        -- Bug 4284353 : Used decode above
                , estimated_start_date = l_tsk_est_start_date_tab(i)
                , estimated_finish_date = l_tsk_est_finish_date_tab(i)
                , actual_start_date = l_tsk_actual_start_date_tab(i)
                , actual_finish_date = l_tsk_actual_finish_date_tab(i)
                , record_version_number = record_version_number +1
                , base_percent_comp_deriv_code = l_tsk_deriv_method_tab(i)
                , base_progress_status_code = l_tsk_base_prog_stat_code_tab(i)
                , eff_rollup_prog_stat_code = l_tsk_eff_roll_prg_st_code_tab(i)
                , percent_complete_id = l_tsk_percent_complete_id_tab(i)
                , ppl_act_effort_to_date = l_tsk_ppl_act_eff_tab(i)
                , ppl_act_cost_to_date_pc = l_tsk_ppl_act_cost_pc_tab(i)
                , ppl_act_cost_to_date_fc = l_tsk_ppl_act_cost_fc_tab(i)
                , ppl_act_rawcost_to_date_pc = l_tsk_ppl_act_rawcost_pc_tab(i)
                , ppl_act_rawcost_to_date_fc = l_tsk_ppl_act_rawcost_fc_tab(i)
                , estimated_remaining_effort = l_tsk_est_rem_effort_tab(i)
                , ppl_etc_cost_pc = l_tsk_ppl_etc_cost_pc_tab(i)
                , ppl_etc_cost_fc = l_tsk_ppl_etc_cost_fc_tab(i)
                , ppl_etc_rawcost_pc = l_tsk_ppl_etc_rawcost_pc_tab(i)
                , ppl_etc_rawcost_fc = l_tsk_ppl_etc_rawcost_fc_tab(i)
                , eqpmt_act_effort_to_date = l_tsk_eqpmt_act_effort_tab(i)
                , eqpmt_act_cost_to_date_pc = l_tsk_eqpmt_act_cost_pc_tab(i)
                , eqpmt_act_cost_to_date_fc = l_tsk_eqpmt_act_cost_fc_tab(i)
                , eqpmt_act_rawcost_to_date_pc = l_tsk_eqpmt_act_rawcost_pc_tab(i)
                , eqpmt_act_rawcost_to_date_fc = l_tsk_eqpmt_act_rawcost_fc_tab(i)
                , eqpmt_etc_effort = l_tsk_eqpmt_etc_effort_tab(i)
                , eqpmt_etc_cost_pc = l_tsk_eqpmt_etc_cost_pc_tab(i)
                , eqpmt_etc_cost_fc = l_tsk_eqpmt_etc_cost_fc_tab(i)
                , eqpmt_etc_rawcost_pc = l_tsk_eqpmt_etc_rawcost_pc_tab(i)
                , eqpmt_etc_rawcost_fc = l_tsk_eqpmt_etc_rawcost_fc_tab(i)
                , oth_act_cost_to_date_pc = l_tsk_oth_act_cost_pc_tab(i)
                , oth_act_cost_to_date_fc = l_tsk_oth_act_cost_fc_tab(i)
                , oth_act_rawcost_to_date_pc = l_tsk_oth_act_rawcost_pc_tab(i)
                , oth_act_rawcost_to_date_fc = l_tsk_oth_act_rawcost_fc_tab(i)
                , oth_etc_cost_pc= l_tsk_oth_etc_cost_pc_tab(i)
                , oth_etc_cost_fc = l_tsk_oth_etc_cost_fc_tab(i)
                , oth_etc_rawcost_pc = l_tsk_oth_etc_rawcost_pc_tab(i)
                , oth_etc_rawcost_fc = l_tsk_oth_etc_rawcost_fc_tab(i)
                , earned_value = l_tsk_earned_value_tab(i)
                , task_wt_basis_code = l_tsk_task_wt_basis_code_tab(i)
        , base_percent_complete = l_tsk_base_percent_comp_tab(i) -- 4392189 : Program Reporting Changes - Phase 2
                WHERE l_tsk_update_required(i) = 'Y'
                AND progress_rollup_id = l_tsk_progress_rollup_id_tab(i)
                ;


        IF p_structure_type = 'WORKPLAN' AND l_structure_version_id IS NULL AND p_progress_mode <> 'BACKDATED'  THEN
                FORALL i in 1..l_tsk_object_version_id_tab.count
                        UPDATE pa_progress_rollup
                        SET
                        object_version_id =     l_tsk_object_version_id_tab(i)
                        , last_update_date = sysdate
                        , last_updated_by =     l_user_id
                        , last_update_login     = l_login_id
                        , eff_rollup_percent_comp = l_tsk_roll_comp_percent_tab(i)
                        , estimated_start_date =        l_tsk_est_start_date_tab(i)
                        , estimated_finish_date = l_tsk_est_finish_date_tab(i)
                        , actual_start_date     = l_tsk_actual_start_date_tab(i)
                        , actual_finish_date = l_tsk_actual_finish_date_tab(i)
                        , record_version_number = record_version_number +1
                        , base_percent_comp_deriv_code = l_tsk_deriv_method_tab(i)
                        , base_progress_status_code =   l_tsk_base_prog_stat_code_tab(i)
                        , eff_rollup_prog_stat_code =   l_tsk_eff_roll_prg_st_code_tab(i)
                        , percent_complete_id = l_tsk_percent_complete_id_tab(i)
                        , ppl_act_effort_to_date        = l_tsk_ppl_act_eff_tab(i)
                        , ppl_act_cost_to_date_pc = l_tsk_ppl_act_cost_pc_tab(i)
                        , ppl_act_cost_to_date_fc = l_tsk_ppl_act_cost_fc_tab(i)
                        , ppl_act_rawcost_to_date_pc = l_tsk_ppl_act_rawcost_pc_tab(i)
                        , ppl_act_rawcost_to_date_fc = l_tsk_ppl_act_rawcost_fc_tab(i)
                        , estimated_remaining_effort = l_tsk_est_rem_effort_tab(i)
                        , ppl_etc_cost_pc =     l_tsk_ppl_etc_cost_pc_tab(i)
                        , ppl_etc_cost_fc =     l_tsk_ppl_etc_cost_fc_tab(i)
                        , ppl_etc_rawcost_pc = l_tsk_ppl_etc_rawcost_pc_tab(i)
                        , ppl_etc_rawcost_fc = l_tsk_ppl_etc_rawcost_fc_tab(i)
                        , eqpmt_act_effort_to_date = l_tsk_eqpmt_act_effort_tab(i)
                        , eqpmt_act_cost_to_date_pc =   l_tsk_eqpmt_act_cost_pc_tab(i)
                        , eqpmt_act_cost_to_date_fc =   l_tsk_eqpmt_act_cost_fc_tab(i)
                        , eqpmt_act_rawcost_to_date_pc = l_tsk_eqpmt_act_rawcost_pc_tab(i)
                        , eqpmt_act_rawcost_to_date_fc = l_tsk_eqpmt_act_rawcost_fc_tab(i)
                        , eqpmt_etc_effort = l_tsk_eqpmt_etc_effort_tab(i)
                        , eqpmt_etc_cost_pc     = l_tsk_eqpmt_etc_cost_pc_tab(i)
                        , eqpmt_etc_cost_fc     = l_tsk_eqpmt_etc_cost_fc_tab(i)
                        , eqpmt_etc_rawcost_pc =        l_tsk_eqpmt_etc_rawcost_pc_tab(i)
                        , eqpmt_etc_rawcost_fc =        l_tsk_eqpmt_etc_rawcost_fc_tab(i)
                        , oth_act_cost_to_date_pc = l_tsk_oth_act_cost_pc_tab(i)
                        , oth_act_cost_to_date_fc = l_tsk_oth_act_cost_fc_tab(i)
                        , oth_act_rawcost_to_date_pc = l_tsk_oth_act_rawcost_pc_tab(i)
                        , oth_act_rawcost_to_date_fc = l_tsk_oth_act_rawcost_fc_tab(i)
                        , oth_etc_cost_pc= l_tsk_oth_etc_cost_pc_tab(i)
                        , oth_etc_cost_fc =     l_tsk_oth_etc_cost_fc_tab(i)
                        , oth_etc_rawcost_pc = l_tsk_oth_etc_rawcost_pc_tab(i)
                        , oth_etc_rawcost_fc = l_tsk_oth_etc_rawcost_fc_tab(i)
                        , earned_value  = l_tsk_earned_value_tab(i)
                        , task_wt_basis_code = l_tsk_task_wt_basis_code_tab(i)
                , base_percent_complete = l_tsk_base_percent_comp_tab(i) -- 4392189 : Program Reporting Changes - Phase 2
                        WHERE l_tsk_update_required(i) = 'Y'
                        AND project_id  = p_project_id
                        AND object_id = l_tsk_object_id_tab(i)
                        AND proj_element_id     = l_tsk_proj_element_id_tab(i)
                        AND object_type = l_tsk_object_type_tab(i)
                        AND as_of_date  >= p_as_of_date
                        AND current_flag = 'W'
                        AND structure_type = 'WORKPLAN'
                        AND structure_version_id is null
                        ;
        END IF;

    -- Bug 4242787 : This is effective solution for the bug 4097710
    -- We should not create new records if the rollup is called from Future Rollup API
    -- It should just update.
    IF p_calling_mode <> 'FUTURE_ROLLUP' OR p_calling_mode IS NULL THEN
        FORALL i in 1..l_tsk_object_version_id_tab.count
                INSERT INTO pa_progress_rollup
                (
                progress_rollup_id
                ,project_id
                ,object_id
                ,object_type
                ,as_of_date
                ,object_version_id
                ,last_update_date
                ,last_updated_by
                ,creation_date
                ,created_by
                ,progress_status_code
                ,last_update_login
                ,eff_rollup_percent_comp
                ,completed_percentage
                ,estimated_start_date
                ,estimated_finish_date
                ,actual_start_date
                ,actual_finish_date
                ,record_version_number
                ,base_percent_comp_deriv_code
                ,base_progress_status_code
                ,eff_rollup_prog_stat_code
                ,percent_complete_id
                ,structure_type
                ,proj_element_id
                ,structure_version_id
                ,ppl_act_effort_to_date
                ,ppl_act_cost_to_date_pc
                ,ppl_act_cost_to_date_fc
                ,ppl_act_rawcost_to_date_pc
                ,ppl_act_rawcost_to_date_fc
                ,estimated_remaining_effort
                ,ppl_etc_cost_pc
                ,ppl_etc_cost_fc
                ,ppl_etc_rawcost_pc
                ,ppl_etc_rawcost_fc
                ,eqpmt_act_effort_to_date
                ,eqpmt_act_cost_to_date_pc
                ,eqpmt_act_cost_to_date_fc
                ,eqpmt_act_rawcost_to_date_pc
                ,eqpmt_act_rawcost_to_date_fc
                ,eqpmt_etc_effort
                ,eqpmt_etc_cost_pc
                ,eqpmt_etc_cost_fc
                ,eqpmt_etc_rawcost_pc
                ,eqpmt_etc_rawcost_fc
                ,oth_quantity_to_date
                ,oth_act_cost_to_date_pc
                ,oth_act_cost_to_date_fc
                ,oth_act_rawcost_to_date_pc
                ,oth_act_rawcost_to_date_fc
                ,oth_etc_quantity
                ,oth_etc_cost_pc
                ,oth_etc_cost_fc
                ,oth_etc_rawcost_pc
                ,oth_etc_rawcost_fc
                ,earned_value
                ,task_wt_basis_code
                ,current_flag
                ,projfunc_cost_rate_type
                ,projfunc_cost_exchange_rate
                ,projfunc_cost_rate_date
                ,proj_cost_rate_type
                ,proj_cost_exchange_rate
                ,proj_cost_rate_date
                ,txn_currency_code
                ,prog_pa_period_name
                ,prog_gl_period_name
        ,base_percent_complete
                )
                SELECT
                PA_PROGRESS_ROLLUP_S.nextval
                , p_project_id
                , l_tsk_object_id_tab(i)
                , l_tsk_object_type_tab(i)
                , p_as_of_date
                , l_tsk_object_version_id_tab(i)
                , sysdate
                , l_user_id
                , sysdate
                , l_user_id
                , l_tsk_progress_stat_code_tab(i)
                , l_login_id
                , l_tsk_roll_comp_percent_tab(i)
                ,  decode(p_progress_mode,'TRANSFER_WP_PC',l_tsk_roll_comp_percent_tab(i),l_tsk_over_percent_comp_tab(i))
        -- Bug 4284353 : Used decode above
                , l_tsk_est_start_date_tab(i)
                , l_tsk_est_finish_date_tab(i)
                , l_tsk_actual_start_date_tab(i)
                , l_tsk_actual_finish_date_tab(i)
                , 1
                , l_tsk_deriv_method_tab(i)
                , l_tsk_base_prog_stat_code_tab(i)
                , l_tsk_eff_roll_prg_st_code_tab(i)
                , l_tsk_percent_complete_id_tab(i)
                , p_structure_type
                , l_tsk_proj_element_id_tab(i)
                , l_structure_version_id
                , l_tsk_ppl_act_eff_tab(i)
                , l_tsk_ppl_act_cost_pc_tab(i)
                , l_tsk_ppl_act_cost_fc_tab(i)
                , l_tsk_ppl_act_rawcost_pc_tab(i)
                , l_tsk_ppl_act_rawcost_fc_tab(i)
                , l_tsk_est_rem_effort_tab(i)
                , l_tsk_ppl_etc_cost_pc_tab(i)
                , l_tsk_ppl_etc_cost_fc_tab(i)
                , l_tsk_ppl_etc_rawcost_pc_tab(i)
                , l_tsk_ppl_etc_rawcost_fc_tab(i)
                , l_tsk_eqpmt_act_effort_tab(i)
                , l_tsk_eqpmt_act_cost_pc_tab(i)
                , l_tsk_eqpmt_act_cost_fc_tab(i)
                , l_tsk_eqpmt_act_rawcost_pc_tab(i)
                , l_tsk_eqpmt_act_rawcost_fc_tab(i)
                , l_tsk_eqpmt_etc_effort_tab(i)
                , l_tsk_eqpmt_etc_cost_pc_tab(i)
                , l_tsk_eqpmt_etc_cost_fc_tab(i)
                , l_tsk_eqpmt_etc_rawcost_pc_tab(i)
                , l_tsk_eqpmt_etc_rawcost_fc_tab(i)
                , l_tsk_oth_quantity_tab(i)
                , l_tsk_oth_act_cost_pc_tab(i)
                , l_tsk_oth_act_cost_fc_tab(i)
                , l_tsk_oth_act_rawcost_pc_tab(i)
                , l_tsk_oth_act_rawcost_fc_tab(i)
                , l_tsk_oth_etc_quantity_tab(i)
                , l_tsk_oth_etc_cost_pc_tab(i)
                , l_tsk_oth_etc_cost_fc_tab(i)
                , l_tsk_oth_etc_rawcost_pc_tab(i)
                , l_tsk_oth_etc_rawcost_fc_tab(i)
                , l_tsk_earned_value_tab(i)
                , l_tsk_task_wt_basis_code_tab(i)
                , l_tsk_current_flag_tab(i)
                , l_tsk_pf_cost_rate_type_tab(i)
                , l_tsk_pf_cost_exc_rate_tab(i)
                , l_tsk_pf_cost_rate_date_tab(i)
                , l_tsk_p_cost_rate_type_tab(i)
                , l_tsk_p_cost_exc_rate_tab(i)
                , l_tsk_p_cost_rate_date_tab(i)
                , l_tsk_txn_currency_code_tab(i)
                , l_tsk_prog_pa_period_name_tab(i)
                , l_tsk_prog_gl_period_name_tab(i)
        , l_tsk_base_percent_comp_tab(i) -- 4392189 : Program Reporting Changes - Phase 2
                FROM
                DUAL
                WHERE l_tsk_create_required(i) = 'Y'
                ;
    END IF; -- IF p_calling_mode <> 'FUTURE_ROLLUP'  OR p_calling_mode IS NULL THEN

    -- Bug 4242787
    -- Do not delete here. Delete it at last. This will be used in Future Rollup Too.
        -- DELETE from pa_proj_rollup_temp where process_number= l_process_number_temp;

        ----    **************  Updation Ends   ******************      ----------

    -- Bug 4242787
    -- In Mass Rollup Case, Future Rollup is also done here. The calling API's need not call
    -- Future rollup seprately if they are calling Mass Rollup
    IF p_rollup_entire_wbs = 'Y' AND l_structure_version_id IS NULL THEN
        IF g1_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'Future Rollup Starts', x_Log_Level=> 3);
        END IF;

        FOR cur_tree_rollup_rec IN cur_tree_rollup_dates LOOP
            IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'cur_tree_rollup_rec.child_task_id='||cur_tree_rollup_rec.child_task_id, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'cur_tree_rollup_rec.child_task_ver_id='||cur_tree_rollup_rec.child_task_ver_id, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'cur_tree_rollup_rec.as_of_date='||cur_tree_rollup_rec.as_of_date, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'Calling Rollup for Future Date', x_Log_Level=> 3);
            END IF;
            -- Bug 4573257 Begin
            -- We need to call PJI tmp table population
            -- otherwise we will get incorrect actual and etc for future dates records
            IF l_last_as_of_date IS NULL OR cur_tree_rollup_rec.as_of_date <> l_last_as_of_date THEN

                IF (l_base_struct_ver_id = -1) THEN
                    l_base_struct_ver_id := p_structure_version_id;
                END IF;

                PA_PROGRESS_PUB.POPULATE_PJI_TAB_FOR_PLAN(
                    p_calling_module    => p_calling_module
                    ,p_project_id           => p_project_id
                    ,p_structure_version_id => p_structure_version_id
                    ,p_baselined_str_ver_id => l_base_struct_ver_id
                    ,p_program_rollup_flag  => 'Y'
                    ,p_calling_context  => 'ROLLUP'
                    ,p_as_of_date       => cur_tree_rollup_rec.as_of_date
                    ,x_return_status        => x_return_status
                    ,x_msg_count            => x_msg_count
                    ,x_msg_data             => x_msg_data
                    );
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE  FND_API.G_EXC_ERROR;
                END IF;
                l_last_as_of_date := cur_tree_rollup_rec.as_of_date;
            END IF;
            -- Bug 4573257 End

            PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT(
                 p_init_msg_list                => 'F'
                ,p_calling_module       => p_calling_module
                ,p_calling_mode         => 'FUTURE_ROLLUP'
                ,p_commit                       => 'F'
                ,p_validate_only                => 'F'
                ,p_project_id                   => p_project_id
                ,P_OBJECT_TYPE                  => 'PA_TASKS'
                ,P_OBJECT_ID                    => cur_tree_rollup_rec.child_task_id
                ,p_object_version_id            => cur_tree_rollup_rec.child_task_ver_id
                ,p_as_of_date                   => cur_tree_rollup_rec.as_of_date
                ,p_lowest_level_task            => p_lowest_level_task
                ,p_process_whole_tree           => 'N'
                ,p_structure_type               => p_structure_type
                ,p_structure_version_id         => p_structure_version_id
                ,p_rollup_entire_wbs            => 'N'
                ,p_fin_rollup_method            => p_fin_rollup_method
                ,p_wp_rollup_method             => p_wp_rollup_method
                ,p_task_version_id              => cur_tree_rollup_rec.child_task_ver_id
                ,x_return_status                => x_return_status
                ,x_msg_count                    => x_msg_count
                ,x_msg_data                     => x_msg_data);

            IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'Rollup For Future Date x_return_status='||x_return_status, x_Log_Level=> 3);
            END IF;

            IF x_return_status <> 'S' THEN
                raise FND_API.G_EXC_ERROR;
            END IF;
        END LOOP;
    END IF; -- p_rollup_entire_wbs = 'Y'

        DELETE from pa_proj_rollup_temp where process_number= l_process_number_temp;



        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (p_commit =  FND_API.G_TRUE) THEN
                COMMIT;
        END IF;


        IF g1_debug_mode  =     'Y'     THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT END', x_Log_Level=> 3);
        END IF;

EXCEPTION
        WHEN    FND_API.G_EXC_ERROR     THEN
                --BUG 4355204
        --IF p_commit = FND_API.G_TRUE THEN
                        rollback to ROLLUP_PROGRESS_PVT2;
                --END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN    FND_API.G_EXC_UNEXPECTED_ERROR THEN
                --BUG 4355204
        --IF p_commit = FND_API.G_TRUE THEN
                        rollback to ROLLUP_PROGRESS_PVT2;
                --END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_PVT',
                                 p_procedure_name => 'ROLLUP_PROGRESS_PVT',
                                 p_error_text      => SUBSTRB(SQLERRM,1,120));
        WHEN    OTHERS THEN
                --BUG 4355204
        --IF p_commit = FND_API.G_TRUE THEN
                        rollback to ROLLUP_PROGRESS_PVT2;
                --END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_PVT',
                                 p_procedure_name => 'ROLLUP_PROGRESS_PVT',
                                 p_error_text      => SUBSTRB(SQLERRM,1,120));
                raise;
END ROLLUP_PROGRESS_PVT;

-- Start of comments
--      API name        : UPDATE_ROLLUP_PROGRESS_PVT
--      Type            : Private
--      Pre-reqs        : ROLLUP_PROGRESS_PVT shd have been called.
--      Purpose         : Updates the Rolled up data
--      Parameters Desc :
--              P_OBJECT_TYPE                   Possible values PA_ASSIGNMENTS, PA_DELIVERABLES, PA_TASKS
--              P_OBJECT_ID                     For assignments, pass resource_assignment_id, otherwise
--                                              proj_element_id of the deliverable and task
--              p_object_version_id             For Assignments, pass task_version_id, otherwise
--                                              element_version_id of the deliverable and task
--              p_task_version_id               For tasks, assignments, deliverables pass the task version id
--                                              , for struture pass null
--              p_lowest_level_task             Does not seem to be required
--              p_structure_version_id          Structure version id of the publsihed or working structure version
--              p_structure_type                Possible values WORKPLAN, FINANCIAL
--              p_fin_rollup_method             Possible values are COST, EFFORT
--              p_wp_rollup_method              Possible values are COST, EFFORT, MANUAL, DURATION
--              p_published_structure           To indicate if the passed structure version is published
--      History         : 17-MAR-04  amksingh   Rewritten For FPM Development Tracking Bug 3420093

-- End of comments

PROCEDURE UPDATE_ROLLUP_PROGRESS_PVT(
  p_api_version                         IN      NUMBER                  :=1.0
 ,p_init_msg_list                       IN      VARCHAR2                :=FND_API.G_TRUE
 ,p_commit                              IN      VARCHAR2                :=FND_API.G_FALSE
 ,p_validate_only                       IN      VARCHAR2                :=FND_API.G_TRUE
 ,p_validation_level                    IN      NUMBER                  :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module                      IN      VARCHAR2                :='SELF_SERVICE'
 ,p_calling_mode            IN      VARCHAR2                :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR -- Bug 4097710
 ,p_debug_mode                          IN      VARCHAR2                :='N'
 ,p_max_msg_count                       IN      NUMBER                  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id                          IN      NUMBER                  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_object_version_id                   IN      NUMBER                  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_as_of_date                          IN      DATE                    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_rollup_table                        IN      PA_SCHEDULE_OBJECTS_PVT.PA_SCHEDULE_OBJECTS_TBL_TYPE
 ,p_lowest_level_task                   IN      VARCHAR2                := 'N'
 ,p_task_version_id                     IN      NUMBER
 ,p_structure_version_id                IN      NUMBER
 ,p_structure_type                      IN      VARCHAR2                := 'WORKPLAN'
 ,p_fin_rollup_method                   IN      VARCHAR2                := 'COST'
 ,p_wp_rollup_method                    IN      VARCHAR2                := 'COST'
 ,p_published_structure                 IN      VARCHAR2
 ,p_rollup_entire_wbs                   IN      VARCHAR2                := 'N' -- FPM Dev CR 7
 ,p_working_wp_prog_flag                 IN      VARCHAR2        := 'N'  --bug 3829341
 ,p_upd_new_elem_ver_id_flag             IN      VARCHAR2        := 'Y'  -- rtarway, for BUG 3951024
 ,p_progress_mode           IN  VARCHAR2        := 'FUTURE'  -- 4091457
 ,x_return_status                       OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                           OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                            OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
   l_api_name                      CONSTANT VARCHAR(30) := 'UPDATE_ROLLUP_PROGRESS_PVT' ;
   l_api_version                   CONSTANT NUMBER      := 1.0                          ;

   l_return_status                 VARCHAR2(1)                                          ;
   l_msg_count                     NUMBER                                               ;
   l_msg_data                      VARCHAR2(250)                                        ;
   l_data                          VARCHAR2(250)                                        ;
   l_msg_index_out                 NUMBER                                               ;
   l_error_msg_code                VARCHAR2(250)                                        ;
   l_user_id                       NUMBER                       := FND_GLOBAL.USER_ID   ;
   l_login_id                      NUMBER                       := FND_GLOBAL.LOGIN_ID  ;

BEGIN
-- Bug 4242787 : Commented update_rollup_progress_pvt, IT is merged into rollup_progress_pvt
x_return_status := FND_API.G_RET_STS_SUCCESS;
        IF (p_commit = FND_API.G_TRUE) THEN
                COMMIT;
        END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                IF g1_debug_mode  = 'Y' THEN
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ROLLUP_PROGRESS_PVT', x_Msg => 'FND_API.G_EXC_ERROR', x_Log_Level=> 3);
                END IF;

                IF p_commit = FND_API.G_TRUE THEN
                rollback to UPDATE_ROLLUP_PROGRESS_PVT2;
                END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                IF g1_debug_mode  = 'Y' THEN
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ROLLUP_PROGRESS_PVT', x_Msg => 'FND_API.G_EXC_UNEXPECTED_ERROR', x_Log_Level=> 3);
                END IF;

                IF p_commit = FND_API.G_TRUE THEN
                        rollback to UPDATE_ROLLUP_PROGRESS_PVT2;
                END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_PVT',
                              p_procedure_name => 'UPDATE_ROLLUP_PROGRESS_PVT',
                              p_error_text     => SUBSTRB(SQLERRM,1,120));
    WHEN OTHERS THEN
                IF g1_debug_mode  = 'Y' THEN
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ROLLUP_PROGRESS_PVT', x_Msg => 'OTHERS = '||sqlerrm, x_Log_Level=> 3);
                END IF;

                IF p_commit = FND_API.G_TRUE THEN
                        rollback to UPDATE_ROLLUP_PROGRESS_PVT2;
                END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_PVT',
                              p_procedure_name => 'UPDATE_ROLLUP_PROGRESS_PVT',
                              p_error_text     => SUBSTRB(SQLERRM,1,120));
                raise;
END UPDATE_ROLLUP_PROGRESS_PVT;

PROCEDURE ROLLUP_FUTURE_PROGRESS_PVT(
 p_project_id              IN   NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,P_OBJECT_TYPE            IN   VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_OBJECT_ID              IN   NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_object_version_id      IN   NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_as_of_date             IN   DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_lowest_level_task      IN   VARCHAR2        := 'N'
 ,p_calling_module         IN   VARCHAR2        := 'SELF_SERVICE'
 ,p_calling_mode       IN VARCHAR2          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR -- Bug 4097710
 ,p_structure_type         IN   VARCHAR2        := 'WORKPLAN'
 ,p_structure_version_id   IN   NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_fin_rollup_method      IN   VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_wp_rollup_method       IN   VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_rollup_entire_wbs      IN   VARCHAR2        := 'N' -- Bug 3606627
 ,x_return_status          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count              OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
 IS

-- 4537865
     l_msg_count                  NUMBER ;
     l_data                       VARCHAR2(2000);
     l_msg_data                   VARCHAR2(2000);
     l_msg_index_out              NUMBER;

   CURSOR cur_reverse_tree
   IS
   SELECT proj_element_id, object_id_from1, object_id_to1, object_type
       FROM
      ( select object_id_from1, object_id_to1
          from pa_object_relationships
          where p_rollup_entire_wbs='N'
          AND relationship_type = 'S' -- FPM
         start with object_id_to1 = p_object_version_id
         --and relationship_type = 'S'  -- Bug 3603636
         and relationship_type = 'S' -- Bug 4122809 : Added this
         connect by prior object_id_from1 = object_id_to1
     and relationship_type = 'S'  -- Bug 3958686
     ) pobj, pa_proj_element_versions ppev
       WHERE element_version_id = object_id_to1
       AND p_rollup_entire_wbs='N'
   UNION -- AMG Changes
     SELECT ever.proj_element_id, obj.object_id_from1 object_id_from1, ever.element_version_id object_id_to1, ever.object_type object_type
     FROM pa_proj_element_versions ever
     , pa_object_relationships obj
     WHERE ever.project_id = p_project_id
     and ever.parent_structure_version_id = p_structure_version_id
     -- 4490532 : changed from IS_LOWEST_TASK to is_summary_task_or_structure
--     and PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(ever.element_version_id) = 'N'
     and PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(ever.element_version_id) = 'Y'
     and ever.object_type = 'PA_TASKS'
     AND obj.object_id_to1 = ever.element_version_id
     AND obj.relationship_type = 'S'
     and p_rollup_entire_wbs='Y';


    l_object_id    NUMBER;
    -- Bug 3764224 : This cursor deals with tasks only, so no need to add join of proj_element_id
    CURSOR cur_tree_rollup_dates
    IS
    select as_of_date, published_flag, ppc.current_flag
      from pa_progress_rollup ppr, pa_percent_completes ppc
     where ppr.project_id = p_project_id
       and ppr.object_id = l_object_id
       and ppr.as_of_Date > p_as_of_date
       and ppr.project_id = ppc.project_id(+)
       and ppr.object_id = ppc.object_id(+)
       and ppr.as_of_date = ppc.date_computed(+)
       and ppr.structure_type = p_structure_type
       and ppr.structure_version_id is null -- For Future Rollup no need to check for structure version id
     order by as_of_date;

     cur_tree_rollup_rec  cur_tree_rollup_dates%rowtype;
     l_structure_version_id            NUMBER;
     g1_debug_mode                     VARCHAR2(1);

     l_base_struct_ver_id       NUMBER; -- Bug 4573257
     l_last_as_of_date          DATE; -- Bug 4573257
BEGIN

        g1_debug_mode := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',fnd_global.user_id,fnd_global.login_id,275,null,null), 'N');

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.init_err_stack ('PA_PROGRESS_PVT.ROLLUP_FUTURE_PROGRESS_PVT');
        END IF;

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_FUTURE_PROGRESS_PVT', x_Msg => 'PA_PROGRESS_PVT.ROLLUP_FUTURE_PROGRESS_PVT Start : Passed Parameters :', x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_FUTURE_PROGRESS_PVT', x_Msg => 'p_project_id='||p_project_id, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_FUTURE_PROGRESS_PVT', x_Msg => 'P_OBJECT_TYPE='||P_OBJECT_TYPE, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_FUTURE_PROGRESS_PVT', x_Msg => 'P_OBJECT_ID='||P_OBJECT_ID, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_FUTURE_PROGRESS_PVT', x_Msg => 'p_object_version_id='||p_object_version_id, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_FUTURE_PROGRESS_PVT', x_Msg => 'p_as_of_date='||p_as_of_date, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_FUTURE_PROGRESS_PVT', x_Msg => 'p_lowest_level_task='||p_lowest_level_task, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_FUTURE_PROGRESS_PVT', x_Msg => 'p_structure_version_id='||p_structure_version_id, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_FUTURE_PROGRESS_PVT', x_Msg => 'p_structure_type='||p_structure_type, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_FUTURE_PROGRESS_PVT', x_Msg => 'p_fin_rollup_method='||p_fin_rollup_method, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_FUTURE_PROGRESS_PVT', x_Msg => 'p_wp_rollup_method='||p_wp_rollup_method, x_Log_Level=> 3);
        END IF;

    For cur_tree_rec in cur_reverse_tree loop

           select proj_element_id into l_object_id
             from pa_proj_element_versions
            where element_version_id = cur_tree_rec.object_id_from1;

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_FUTURE_PROGRESS_PVT', x_Msg => 'l_object_id'||l_object_id, x_Log_Level=> 3);
        END IF;


          open cur_tree_rollup_dates;
          loop
             fetch cur_tree_rollup_dates into cur_tree_rollup_rec;
             if cur_tree_rollup_dates%notfound then
                exit;
             end if;
             ----------------dbms_output.put_line(cur_tree_rec.proj_element_id||'  '||cur_tree_rollup_rec.as_of_date);
             if nvl(cur_tree_rollup_rec.current_flag,'X') = 'N' and nvl(cur_tree_rollup_rec.published_flag,'X') = 'Y' then
                null;
             else

            IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_FUTURE_PROGRESS_PVT', x_Msg => 'Calling ROLLUP_PROGRESS_PVT', x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_FUTURE_PROGRESS_PVT', x_Msg => 'cur_tree_rollup_rec.as_of_date='||cur_tree_rollup_rec.as_of_date, x_Log_Level=> 3);
            END IF;

        -- Bug 4573257 Begin
        -- We need to call PJI tmp table population
        -- otherwise we will get incorrect actual and etc for future dates records
        IF l_last_as_of_date IS NULL OR cur_tree_rollup_rec.as_of_date <> l_last_as_of_date THEN
                l_base_struct_ver_id := pa_project_structure_utils.get_baseline_struct_ver(p_project_id);
            IF (l_base_struct_ver_id = -1) THEN
                l_base_struct_ver_id := p_structure_version_id;
            END IF;

            PA_PROGRESS_PUB.POPULATE_PJI_TAB_FOR_PLAN(
                p_calling_module    => p_calling_module
                ,p_project_id           => p_project_id
                ,p_structure_version_id => p_structure_version_id
                ,p_baselined_str_ver_id => l_base_struct_ver_id
                ,p_program_rollup_flag  => 'Y'
                ,p_calling_context  => 'ROLLUP'
                ,p_as_of_date       => cur_tree_rollup_rec.as_of_date
                ,x_return_status        => x_return_status
                ,x_msg_count            => x_msg_count
                ,x_msg_data             => x_msg_data
                );
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE  FND_API.G_EXC_ERROR;
            END IF;
            l_last_as_of_date := cur_tree_rollup_rec.as_of_date;
        END IF;
        -- Bug 4573257 End

        -- Bug 4097710 : Changed the API from PUB to PVT.
        -- It is not good idea to call PUB APi from PVT

                PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT(
                 p_init_msg_list                => 'F'
            --Added by rtarway for BUG 3696263
                ,p_calling_module       => p_calling_module
        ,p_calling_mode         => 'FUTURE_ROLLUP' -- Bug 4097710, 4242787 Changed back to FUTURE_ROLLUP
                ,p_commit                       => 'F'
                ,p_validate_only                => 'F'
                ,p_project_id                   => p_project_id
                ,P_OBJECT_TYPE                  => 'PA_TASKS'
                ,P_OBJECT_ID                    => cur_tree_rec.proj_element_id
                ,p_object_version_id            => cur_tree_rec.object_id_to1
                ,p_as_of_date                   => cur_tree_rollup_rec.as_of_date
                ,p_lowest_level_task            => p_lowest_level_task
                ,p_process_whole_tree           => 'N'
                ,p_structure_type               => p_structure_type
                ,p_structure_version_id         => p_structure_version_id
                ,p_rollup_entire_wbs            => 'N'
                ,p_fin_rollup_method            => p_fin_rollup_method
                ,p_wp_rollup_method             => p_wp_rollup_method
                ,p_task_version_id              => cur_tree_rec.object_id_to1
                ,x_return_status                => x_return_status
                ,x_msg_count                    => x_msg_count
                ,x_msg_data                     => x_msg_data);

        -- Start : 4537865
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_ERROR;
            END IF;
        -- End : 4537865
             end if;
          end loop;
          close cur_tree_rollup_dates;
    END loop;
    IF g1_debug_mode  = 'Y' THEN
         pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_FUTURE_PROGRESS_PVT', x_Msg => 'End ', x_Log_Level=> 3);
    END IF;
EXCEPTION
-- 4537865 : Start
    when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR;

      l_msg_count := Fnd_Msg_Pub.count_msg;

      IF l_msg_count = 1 AND x_msg_data IS NULL
      THEN
          Pa_Interface_Utils_Pub.get_messages
              ( p_encoded        => Fnd_Api.G_FALSE
              , p_msg_index      => 1
              , p_msg_count      => l_msg_count
              , p_msg_data       => l_msg_data
              , p_data           => l_data
              , p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
      x_msg_count := l_msg_count;
      END IF;

-- 4537865 : End
    WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1 ; -- 4537865
        x_msg_data := SUBSTRB(SQLERRM,1,120); -- 4537865
                fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_PVT',
                              p_procedure_name => 'ROLLUP_FUTURE_PROGRESS_PVT',
                              p_error_text     => SUBSTRB(SQLERRM,1,120));
                raise;
END ROLLUP_FUTURE_PROGRESS_PVT;

PROCEDURE program_rollup_pvt(
  p_api_version                 IN      NUMBER          :=1.0
 ,p_init_msg_list               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_commit                      IN      VARCHAR2        :=FND_API.G_FALSE
 ,p_validate_only               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validation_level            IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module              IN      VARCHAR2        :='SELF_SERVICE'
 ,p_debug_mode                  IN      VARCHAR2        :='N'
 ,p_max_msg_count               IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id                  IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_as_of_date                  IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_structure_type              IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_structure_ver_id            IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,x_return_status               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_api_name           CONSTANT   VARCHAR2(30)    := 'PROGRAM_ROLLUP_PVT';
   l_api_version        CONSTANT   NUMBER          := p_api_version;
   l_user_id                       NUMBER          := FND_GLOBAL.USER_ID;
   l_login_id                      NUMBER          := FND_GLOBAL.LOGIN_ID;
   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);

   l_parent_task_id                NUMBER;
   l_parent_struc_ver_id           NUMBER;

CURSOR c1 (p_project_id NUMBER) IS
       /* select *
        from pa_structures_links_v
        where sub_project_id = p_project_id;*/
--bug 4033869
SELECT
  ppv2.project_id                     sub_project_id
 ,ppv2.element_version_id             SUB_STRUCTURE_VER_ID
 ,ppv1.project_id                     PARENT_PROJECT_ID
 ,ppv1.parent_structure_version_id    PARENT_STRUCTURE_VER_ID
 ,ppv1.element_version_id             PARENT_TASK_VERSION_ID
 ,ppv1.proj_element_id                PARENT_TASK_ID
FROM
     pa_proj_element_versions ppv1
    ,pa_proj_elem_ver_structure ppevs1
    ,pa_proj_element_versions ppv2
    ,pa_proj_elem_ver_structure ppevs2
    ,pa_object_relationships por1
    ,pa_object_relationships por2
WHERE
     ppv2.element_version_id = por1.object_id_to1
 AND por1.object_id_from1 = por2.object_id_to1
 AND por2.object_id_from1 = ppv1.element_version_id
 AND ppv2.object_type = 'PA_STRUCTURES'
-- AND por1.relationship_type in ( 'LW', 'LF' )
 AND por1.relationship_type = 'LW'
 AND ppevs1.element_version_id = ppv1.parent_structure_version_id
 AND ppevs1.project_id = ppv1.project_id
 AND ppevs1.status_code = 'STRUCTURE_PUBLISHED'
 AND ppevs1.latest_eff_published_flag = 'Y'
 AND ppevs2.element_version_id = ppv2.element_version_id
 AND ppevs2.project_id = ppv2.project_id
 AND ppevs2.status_code = 'STRUCTURE_PUBLISHED'
 AND ppevs2.latest_eff_published_flag = 'Y'
 AND ppv2.project_id=p_project_id
 ;

l_parent_task_status     VARCHAR2(30);
l_parent_as_of_date      DATE;
l_pln_parent_task_self   NUMBER;
l_parent_plan_version_id NUMBER;

--This cursor returns self planned value for a task.
CURSOR cur_self_planned ( c_project_id NUMBER, c_proj_element_id NUMBER,
                          c_plan_version_id NUMBER, c_base_percnt_deriv_code VARCHAR2)
IS
select decode(c_base_percnt_deriv_code, 'COST',  sum(brdn_cost), 'EFFORT', sum(nvl(labor_hrs,0)+nvl(equipment_hours,0)))
from pji_fp_xbs_accum_f
where project_id =  c_project_id
and plan_version_id = c_plan_version_id
and project_element_id = c_proj_element_id
and calendar_type = 'A'
and wbs_rollup_flag = 'N'
and bitand(curr_record_type_id,  8) = 8
and rbs_aggr_level = 'T'
and prg_rollup_flag = 'N'
;
--end bug 4033869
l_c1rec                         c1%rowtype;
l_base_prcnt_comp_drv_code      VARCHAR2(30);

l_bcwp                  NUMBER := 0;
l_bac                   NUMBER := 0;
l_pln_parent_task       NUMBER :=0;
l_pln_sub_project       NUMBER :=0;
l_eff_rollup_prcnt_comp NUMBER :=0;
l_mode                  VARCHAR2(1) := NULL;
l_progress_rollup_id    NUMBER;

l_msg_code NUMBER;
l_calling_module        VARCHAR2(30);

CURSOR c_get_parent_base_per_comp_der(c_project_id number, c_task_id number) IS
SELECT base_percent_comp_deriv_code
      ,status_code   --bug 4033869
FROM pa_proj_elements
WHERE project_id = c_project_id
AND proj_element_id = c_task_id;

CURSOR c_get_task_weightage_method(c_project_id number) IS
SELECT task_weight_basis_code,progress_cycle_id   ---4701759, 4701727
FROM pa_proj_progress_attr
WHERE project_id = c_project_id
AND structure_type = 'WORKPLAN';

CURSOR c_get_sub_proj_rollup IS
SELECT *
FROM pa_progress_rollup
WHERE project_id = p_project_id
AND object_type = 'PA_STRUCTURES'
AND structure_type = 'WORKPLAN'
AND structure_version_id  is NULL
AND as_of_date = p_as_of_date;

CURSOR c_get_par_task_rollup(c_object_id NUMBER, c_project_id NUMBER) IS
SELECT *
FROM pa_progress_rollup
WHERE object_id = c_object_id
AND project_id = c_project_id
AND object_type = 'PA_TASKS'
AND structure_type = 'WORKPLAN'
AND structure_version_id is null
AND as_of_date = p_as_of_date;

CURSOR cur_get_status( c_status_weight VARCHAR2, c_status_type VARCHAR2  ) IS
SELECT project_status_code
FROM pa_project_statuses
WHERE project_status_weight = c_status_weight
AND status_type = c_status_type
AND predefined_flag = 'Y';

CURSOR cur_get_status_weight(c_status_code VARCHAR2, c_status_type VARCHAR2 ) IS
SELECT project_status_weight
FROM pa_project_statuses
WHERE project_status_code = c_status_code
AND status_type = c_status_type;

l_child_prog_cycle_id       number;  ---4701759, 4701727
l_par_prog_cycle_id         number;
l_sub_project_rec  c_get_sub_proj_rollup%ROWTYPE;
l_parent_task_rec  c_get_par_task_rollup%ROWTYPE;
l_task_weight_basis_code pa_proj_progress_attr.task_weight_basis_code%TYPE;
L_BASE_STRUCT_VER_ID   NUMBER;

l_remaining_effort1    NUMBER ;
l_ETC_Cost_PC              NUMBER ;
l_PPL_ETC_COST_PC          NUMBER ;
l_EQPMT_ETC_COST_PC        NUMBER ;
l_ETC_Cost_FC              NUMBER ;
l_PPL_ETC_COST_FC          NUMBER ;
l_EQPMT_ETC_COST_FC        NUMBER ;
l_EQPMT_ETC_EFFORT         NUMBER ;
l_OTH_ACT_COST_TO_DATE_PC  NUMBER ;
l_PPL_ACT_COST_TO_DATE_PC  NUMBER ;
l_EQPMT_ACT_COST_TO_DATE_PC NUMBER;
l_OTH_ACT_COST_TO_DATE_FC  NUMBER ;
l_PPL_ACT_COST_TO_DATE_FC  NUMBER ;
l_EQPMT_ACT_COST_TO_DATE_FC NUMBER;
l_PPL_ACT_EFFORT_TO_DATE   NUMBER ;
l_EQPMT_ACT_EFFORT_TO_DATE NUMBER ;
l_PERIOD_NAME              VARCHAR2(10);
g1_debug_mode              VARCHAR2(1);
l_OTH_ACT_RAWCOST_TO_DATE_PC         NUMBER;
l_PPL_ACT_RAWCOST_TO_DATE_PC         NUMBER;
l_EQPMT_ACT_RAWCOST_TO_DATE_PC       NUMBER;
l_OTH_ACT_RAWCOST_TO_DATE_FC         NUMBER;
l_PPL_ACT_RAWCOST_TO_DATE_FC         NUMBER;
l_EQPMT_ACT_RAWCOST_TO_DATE_FC       NUMBER;
l_ETC_RAWCost_PC                     NUMBER;
l_PPL_ETC_RAWCOST_PC                 NUMBER;
l_EQPMT_ETC_RAWCOST_PC               NUMBER;
l_ETC_RAWCost_FC                     NUMBER;
l_PPL_ETC_RAWCOST_FC                 NUMBER;
l_EQPMT_ETC_RAWCOST_FC               NUMBER;
l_LABOR_HOURS           NUMBER;
l_EQUIPMENT_HOURS           NUMBER;
l_POU_LABOR_BRDN_COST   NUMBER := null;
l_PRJ_LABOR_BRDN_COST   NUMBER := null;
l_POU_EQUIP_BRDN_COST   NUMBER := null;
l_PRJ_EQUIP_BRDN_COST   NUMBER := null;
l_POU_LABOR_RAW_COST    NUMBER := null;
l_PRJ_LABOR_RAW_COST    NUMBER := null;
l_POU_EQUIP_RAW_COST    NUMBER := null;
l_PRJ_EQUIP_RAW_COST    NUMBER := null;
l_POU_OTH_BRDN_COST     NUMBER := null;
l_PRJ_OTH_BRDN_COST     NUMBER := null;
l_POU_OTH_RAW_COST     NUMBER := null;
l_PRJ_OTH_RAW_COST     NUMBER := null;
l_current_flag         VARCHAR2(1);
l_dummy VARCHAR2(1);
l_parent_progress_status pa_progress_rollup.progress_status_code%TYPE;
l_child_progress_status pa_progress_rollup.progress_status_code%TYPE;
l_par_progress_status_weight pa_project_statuses.project_status_weight%TYPE;
l_child_progress_status_weight pa_project_statuses.project_status_weight%TYPE;
l_progress_status_weight pa_project_statuses.project_status_weight%TYPE;
l_eff_rollup_progress_status pa_progress_rollup.progress_status_code%TYPE;
l_actual_start_date DATE;
l_actual_finish_date DATE;
l_estimated_start_date DATE;
l_estimated_finish_date DATE;
BEGIN

--Open Question:
--1. The parent Project progress record should go to the parent project cycle date.
--As of now it is going with just passed as of date.
--2.
    g1_debug_mode := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',fnd_global.user_id,fnd_global.login_id,275,null,null), 'N');

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.init_err_stack ('PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT');
        END IF;

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT Start : Passed Parameters :', x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'p_project_id='||p_project_id, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'p_structure_ver_id='||p_structure_ver_id, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'p_as_of_date='||p_as_of_date, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'p_structure_type='||p_structure_type, x_Log_Level=> 3);
        END IF;

    IF g1_debug_mode  = 'Y' THEN
                pa_debug.init_err_stack ('PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT');
        END IF;

        IF (p_commit = FND_API.G_TRUE) THEN
                savepoint PROGRAM_ROLLUP_PVT2;
        END IF;

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Get the parent task of the project.

    IF p_structure_type <> 'WORKPLAN' THEN
        return;
    END IF;

        l_calling_module := p_calling_module;  ---4492493

        IF (l_calling_module = 'ASGMT_PLAN_CHANGE') then  --4492493
            l_calling_module := 'SELF_SERVICE';
        END IF;

        OPEN c1(p_project_id);
        ---4701759, 4701727
        OPEN c_get_task_weightage_method(p_project_id);
        FETCH c_get_task_weightage_method INTO l_task_weight_basis_code,l_child_prog_cycle_id;
        CLOSE c_get_task_weightage_method;
    LOOP
             if ((p_calling_module = 'ASGMT_PLAN_CHANGE' and  NVL(PA_PROJ_TASK_STRUC_PUB.IS_WP_VERSIONING_ENABLED(l_c1rec.parent_project_id), 'N' ) = 'N') OR
                (p_calling_module <> 'ASGMT_PLAN_CHANGE')) then  --4492493
            FETCH c1 INTO l_c1rec;
            EXIT WHEN c1%NOTFOUND;

            IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_c1rec.parent_project_id='||l_c1rec.parent_project_id, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_c1rec.parent_task_id='||l_c1rec.parent_task_id, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_c1rec.parent_structure_ver_id='||l_c1rec.parent_structure_ver_id, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_c1rec.parent_task_version_id='||l_c1rec.parent_task_version_id, x_Log_Level=> 3);
            END IF;

            IF (p_structure_type = 'WORKPLAN') THEN

                -- Bug 3807299 Program_rollup redesign
                --l_base_prcnt_comp_drv_code    := null;

                --OPEN c_get_parent_base_per_comp_der(l_c1rec.parent_project_id,l_c1rec.parent_task_id);
                --FETCH c_get_parent_base_per_comp_der INTO l_base_prcnt_comp_drv_code,
                --  l_parent_task_status;   --bug 4033869
                --CLOSE c_get_parent_base_per_comp_der;

                OPEN c_get_task_weightage_method(l_c1rec.parent_project_id);
                FETCH c_get_task_weightage_method INTO l_task_weight_basis_code,l_par_prog_cycle_id;
                CLOSE c_get_task_weightage_method;

                ---4701759, 4701727
                if (l_child_prog_cycle_id <> l_par_prog_cycle_id) then
                    l_parent_as_of_date := pa_progress_utils.get_next_progress_cycle(
                                           p_project_id => l_c1rec.parent_project_id
                                          ,p_task_id => l_c1rec.parent_task_id
                                          ,p_start_date => trunc(p_as_of_date)-1);
                else
                    l_parent_as_of_date := trunc(p_as_of_date);
                end if;

                IF g1_debug_mode  = 'Y' THEN
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_task_weight_basis_code='||l_task_weight_basis_code, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_parent_as_of_date='||l_parent_as_of_date, x_Log_Level=> 3);
                END IF;

                -- 4586449 : This is not related to this but but putting this fix with this bug.
                -- In this API we earlier decided that we do not need to call PJI temp table
                -- population, because update_progress_bulk or get_summarized_actuals have already
                -- populated it for the entire hierarchy upwards for the given p_as_of_date.
                -- But note that program project next cycle date  might be ahead than the passed p_as_of_date.
                -- In this case, we will get wrong data for program. So we need to populate it here too..

                IF l_parent_as_of_date > p_as_of_date THEN
                    pa_progress_pub.populate_pji_tab_for_plan(
                            p_init_msg_list     => FND_API.G_FALSE
                            ,p_commit       => FND_API.G_FALSE
                            ,p_calling_module   => l_calling_module
                            ,p_project_id       => l_c1rec.parent_project_id
                            ,p_structure_version_id => l_c1rec.parent_structure_ver_id
                            ,p_baselined_str_ver_id => PA_PROJECT_STRUCTURE_UTILS.Get_Baseline_Struct_Ver(l_c1rec.parent_project_id)
                            ,p_structure_type       => 'WORKPLAN'
                            ,p_program_rollup_flag  => 'Y'
                            ,p_calling_context  => 'SUMMARIZE'
                            ,p_as_of_date       => l_parent_as_of_date
                            ,x_return_status        => x_return_status
                            ,x_msg_count            => x_msg_count
                            ,x_msg_data             => x_msg_data);

                    IF x_return_status <> 'S' THEN
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
                END IF;

                /* Bug 4392189 : Now Rollup API will take care of everything. No need to do anything here

                -- Amit : Reducing the scope of this IF condition as COST or EFFORT should rollup even
                -- if task derivation method is other than COST or EFFORT
                --IF (l_base_prcnt_comp_drv_code = 'COST' or l_base_prcnt_comp_drv_code = 'EFFORT')
                --THEN
                -- Calculating BCWP.
                l_sub_project_rec := null;

                OPEN c_get_sub_proj_rollup;
                FETCH c_get_sub_proj_rollup INTO l_sub_project_rec;
                CLOSE c_get_sub_proj_rollup;

                l_parent_task_rec := null;

                OPEN c_get_par_task_rollup(l_c1rec.parent_task_id, l_c1rec.parent_project_id);
                FETCH c_get_par_task_rollup INTO l_parent_task_rec;
                CLOSE c_get_par_task_rollup;

                                --bug 4033869
                -- Get sub project plan in terms of derivation method of parent task
                l_pln_sub_project := pa_progress_utils.Get_BAC_Value(p_project_id => p_project_id
                                 ,p_task_weight_method => l_base_prcnt_comp_drv_code
                                 ,p_proj_element_id => l_sub_project_rec.object_id
                                 ,p_structure_version_id => p_structure_ver_id
                                 ,p_structure_type => 'WORKPLAN');
                                --l_pln_parent_task_self
                --get the plan version id of the parent structure ver id.
                IF g1_debug_mode  = 'Y' THEN
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_pln_sub_project='||l_pln_sub_project, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'Before calling Pa_Fp_wp_gen_amt_utils.get_wp_version_id', x_Log_Level=> 3);
                END IF;

                BEGIN
                    l_parent_plan_version_id := Pa_Fp_wp_gen_amt_utils.get_wp_version_id(
                                                      p_project_id => l_c1rec.parent_project_id,
                                                      p_plan_type_id => -1,
                                                      p_proj_str_ver_id => l_c1rec.parent_structure_ver_id) ;
                                EXCEPTION
                    WHEN OTHERS THEN
                        fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROGRESS_PVT',
                        p_procedure_name => 'PROGRAM_ROLLUP_PVT',
                        p_error_text => SUBSTRB('Call of PA_FP_WP_GEN_AMT_UTILS.GET_WP_VERSION_ID Failed: SQLERRM'||SQLERRM,1,120));
                        RAISE FND_API.G_EXC_ERROR;
                                END;

                IF g1_debug_mode  = 'Y' THEN
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_parent_plan_version_id='||l_parent_plan_version_id, x_Log_Level=> 3);
                END IF;

                --if l_base_prcnt_comp_drv_code is COST then select self planned COST for parent task in l_pln_parent_task_self
                --if l_base_prcnt_comp_drv_code is EFFORT then select self planned EFFORT for parent task in l_pln_parent_task_self

                OPEN cur_self_planned ( l_c1rec.parent_project_id, l_c1rec.parent_task_id,
                                                       l_parent_plan_version_id, l_base_prcnt_comp_drv_code);
                                FETCH cur_self_planned INTO l_pln_parent_task_self;
                CLOSE cur_self_planned;
                                --End bug 4033869

                IF g1_debug_mode  = 'Y' THEN
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_pln_parent_task_self='||l_pln_parent_task_self, x_Log_Level=> 3);
                END IF;

                IF l_parent_task_rec.project_id IS NOT NULL THEN
                    IF g1_debug_mode  = 'Y' THEN
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'Mode is Update U', x_Log_Level=> 3);
                    END IF;

                    l_mode := 'U';

                                        --l_bcwp := nvl(l_parent_task_rec.earned_value,0) + nvl(l_sub_project_rec.earned_value,0);
                    l_bcwp :=nvl((nvl(l_parent_task_rec.completed_percentage,l_parent_task_rec.eff_rollup_percent_comp)*l_pln_parent_task_self)/100,0) + --bug 4033869 nvl(l_parent_task_rec.earned_value,0)
                             nvl((nvl(l_sub_project_rec.completed_percentage,l_sub_project_rec.eff_rollup_percent_comp)*l_pln_sub_project)/100,0); --bug 4033869
                    --l_eff_rollup_prcnt_comp := l_parent_task_rec.eff_rollup_percent_comp;

                    IF g1_debug_mode  = 'Y' THEN
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_parent_task_rec.completed_percentage='||l_parent_task_rec.completed_percentage, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_parent_task_rec.eff_rollup_percent_comp='||l_parent_task_rec.eff_rollup_percent_comp, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_parent_task_rec.as_of_date='||l_parent_task_rec.as_of_date, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_sub_project_rec.completed_percentage='||l_sub_project_rec.completed_percentage, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_sub_project_rec.eff_rollup_percent_comp='||l_sub_project_rec.eff_rollup_percent_comp, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_sub_project_rec.as_of_date='||l_sub_project_rec.as_of_date, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_bcwp='||l_bcwp, x_Log_Level=> 3);
                    END IF;


                    IF PA_PROGRESS_UTILS.get_system_task_status(l_parent_task_status) NOT IN ( 'CANCELLED', 'ON_HOLD', 'COMPLETED' )
                    --bug 4033869 If parent is ON-HOLD, CANCELLED or COMPLETED then do not rollup any progress attributes.
                    THEN
                        --l_parent_progress_status := nvl(l_parent_task_rec.PROGRESS_STATUS_CODE, l_parent_task_rec.EFF_ROLLUP_PROG_STAT_CODE);
                        --l_child_progress_status := nvl(l_sub_project_rec.PROGRESS_STATUS_CODE, l_sub_project_rec.EFF_ROLLUP_PROG_STAT_CODE);
                        l_parent_progress_status := l_parent_task_rec.EFF_ROLLUP_PROG_STAT_CODE;
                        l_child_progress_status := nvl(l_sub_project_rec.PROGRESS_STATUS_CODE, l_sub_project_rec.EFF_ROLLUP_PROG_STAT_CODE);

                        IF g1_debug_mode  = 'Y' THEN
                            pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_parent_progress_status='||l_parent_progress_status, x_Log_Level=> 3);
                            pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_child_progress_status='||l_child_progress_status, x_Log_Level=> 3);
                        END IF;

                        IF l_parent_progress_status IS NOT NULL AND l_child_progress_status IS NOT NULL THEN
                            OPEN cur_get_status_weight(l_parent_progress_status, 'PROGRESS');
                            FETCH cur_get_status_weight INTO l_par_progress_status_weight;
                            CLOSE cur_get_status_weight;

                            OPEN cur_get_status_weight(l_child_progress_status, 'PROGRESS');
                            FETCH cur_get_status_weight INTO l_child_progress_status_weight;
                            CLOSE cur_get_status_weight;

                            SELECT GREATEST(l_par_progress_status_weight, l_child_progress_status_weight)
                            INTO l_progress_status_weight
                            FROM DUAL;

                            IF g1_debug_mode  = 'Y' THEN
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_par_progress_status_weight='||l_par_progress_status_weight, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_child_progress_status_weight='||l_child_progress_status_weight, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_progress_status_weight='||l_progress_status_weight, x_Log_Level=> 3);
                            END IF;

                            OPEN cur_get_status(l_progress_status_weight, 'PROGRESS');
                            FETCH cur_get_status INTO l_eff_rollup_progress_status;
                            CLOSE cur_get_status;

                            IF l_eff_rollup_progress_status IS NULL THEN
                                l_eff_rollup_progress_status := l_parent_progress_status;
                            END IF;
                        ELSIF l_parent_progress_status IS NULL AND l_child_progress_status IS NOT NULL THEN
                            l_eff_rollup_progress_status := l_child_progress_status;
                        ELSIF l_parent_progress_status IS NOT NULL AND l_child_progress_status IS NULL THEN
                            l_eff_rollup_progress_status := l_parent_progress_status;
                        ELSE
                            l_eff_rollup_progress_status := null;
                        END IF;

                        IF g1_debug_mode  = 'Y' THEN
                            pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_eff_rollup_progress_status='||l_eff_rollup_progress_status, x_Log_Level=> 3);
                        END IF;


                        IF l_sub_project_rec.ACTUAL_START_DATE IS NOT NULL AND l_parent_task_rec.ACTUAL_START_DATE IS NOT NULL THEN
                            SELECT LEAST(l_sub_project_rec.ACTUAL_START_DATE, l_parent_task_rec.ACTUAL_START_DATE)
                            INTO l_actual_start_date
                            FROM DUAL;
                        ELSIF l_sub_project_rec.ACTUAL_START_DATE IS NULL AND l_parent_task_rec.ACTUAL_START_DATE IS NOT NULL THEN
                            l_actual_start_date := l_parent_task_rec.ACTUAL_START_DATE;
                        ELSIF l_sub_project_rec.ACTUAL_START_DATE IS NOT NULL AND l_parent_task_rec.ACTUAL_START_DATE IS NULL THEN
                            l_actual_start_date := l_sub_project_rec.ACTUAL_START_DATE;
                        ELSE
                            l_actual_start_date := null;
                        END IF;

                        IF l_sub_project_rec.ACTUAL_FINISH_DATE IS NOT NULL AND l_parent_task_rec.ACTUAL_FINISH_DATE IS NOT NULL THEN
                            SELECT GREATEST(l_sub_project_rec.ACTUAL_FINISH_DATE, l_parent_task_rec.ACTUAL_FINISH_DATE)
                            INTO l_actual_finish_date
                            FROM DUAL;
                        ELSIF l_sub_project_rec.ACTUAL_FINISH_DATE IS NULL AND l_parent_task_rec.ACTUAL_FINISH_DATE IS NOT NULL THEN
                            l_actual_finish_date := l_parent_task_rec.ACTUAL_FINISH_DATE;
                        ELSIF l_sub_project_rec.ACTUAL_FINISH_DATE IS NOT NULL AND l_parent_task_rec.ACTUAL_FINISH_DATE IS NULL THEN
                            l_actual_finish_date := l_sub_project_rec.ACTUAL_FINISH_DATE;
                        ELSE
                            l_actual_finish_date := null;
                        END IF;

                        IF l_sub_project_rec.ESTIMATED_START_DATE IS NOT NULL AND l_parent_task_rec.ESTIMATED_START_DATE IS NOT NULL THEN
                            SELECT LEAST(l_sub_project_rec.ESTIMATED_START_DATE, l_parent_task_rec.ESTIMATED_START_DATE)
                            INTO l_estimated_start_date
                            FROM DUAL;
                        ELSIF l_sub_project_rec.ESTIMATED_START_DATE IS NULL AND l_parent_task_rec.ESTIMATED_START_DATE IS NOT NULL THEN
                            l_estimated_start_date := l_parent_task_rec.ESTIMATED_START_DATE;
                        ELSIF l_sub_project_rec.ESTIMATED_START_DATE IS NOT NULL AND l_parent_task_rec.ESTIMATED_START_DATE IS NULL THEN
                            l_estimated_start_date := l_sub_project_rec.ESTIMATED_START_DATE;
                        ELSE
                            l_estimated_start_date := null;
                        END IF;

                        IF l_sub_project_rec.ESTIMATED_FINISH_DATE IS NOT NULL AND l_parent_task_rec.ESTIMATED_FINISH_DATE IS NOT NULL THEN
                            SELECT GREATEST(l_sub_project_rec.ESTIMATED_FINISH_DATE, l_parent_task_rec.ESTIMATED_FINISH_DATE)
                            INTO l_estimated_finish_date
                            FROM DUAL;
                        ELSIF l_sub_project_rec.ESTIMATED_FINISH_DATE IS NULL AND l_parent_task_rec.ESTIMATED_FINISH_DATE IS NOT NULL THEN
                            l_estimated_finish_date := l_parent_task_rec.ESTIMATED_FINISH_DATE;
                        ELSIF l_sub_project_rec.ESTIMATED_START_DATE IS NOT NULL AND l_parent_task_rec.ESTIMATED_FINISH_DATE IS NULL THEN
                            l_estimated_finish_date := l_sub_project_rec.ESTIMATED_FINISH_DATE;
                        ELSE
                            l_estimated_finish_date := null;
                        END IF;

                        IF g1_debug_mode  = 'Y' THEN
                            pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_actual_start_date='||l_actual_start_date, x_Log_Level=> 3);
                            pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_actual_finish_date='||l_actual_finish_date, x_Log_Level=> 3);
                            pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_estimated_start_date='||l_estimated_start_date, x_Log_Level=> 3);
                            pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_estimated_finish_date='||l_estimated_finish_date, x_Log_Level=> 3);
                        END IF;

                    -- For Task Status Rollup, we can use PA_SCHEDULE_OBJECTS_PVT.GET_PROGRESS_STATUS
                    -- First we need to confirm that whether we are inserting/updating in PPC table
                    END IF;  --PA_PROGRESS_UTILS.get_system_task_status bug 4033869
                ELSE
                    IF g1_debug_mode  = 'Y' THEN
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'Mode is Insert I', x_Log_Level=> 3);
                    END IF;

                                        l_mode := 'I';
                    l_bcwp := nvl((nvl(l_sub_project_rec.completed_percentage,l_sub_project_rec.eff_rollup_percent_comp)*l_pln_sub_project)/100,0); --bug 4033869
                    l_eff_rollup_prcnt_comp := null;
                    l_actual_start_date := l_sub_project_rec.ACTUAL_START_DATE;
                    l_actual_finish_date := l_sub_project_rec.ACTUAL_FINISH_DATE;
                    l_estimated_start_date := l_sub_project_rec.ESTIMATED_START_DATE;
                    l_estimated_finish_date := l_sub_project_rec.ESTIMATED_FINISH_DATE;
                    --task status can not rollup as we are not creating records in percent complete table
                    --l_task_status :=
                    l_eff_rollup_progress_status := nvl(l_sub_project_rec.PROGRESS_STATUS_CODE, l_sub_project_rec.EFF_ROLLUP_PROG_STAT_CODE);
                END IF;

                IF g1_debug_mode  = 'Y' THEN
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_parent_task_rec.earned_value='||l_parent_task_rec.earned_value, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_sub_project_rec.earned_value='||l_sub_project_rec.earned_value, x_Log_Level=> 3);
                END IF;
                */


                /* Bug 4392189 : No need to call populate_pji_tab_for_plan for parnet here.
                 The temp table will be having data up in the complete hierrachy of program
                l_base_struct_ver_id := pa_project_structure_utils.get_baseline_struct_ver(l_c1rec.parent_project_id);

                pa_progress_pub.populate_pji_tab_for_plan(
                    p_init_msg_list => 'F',
                    p_calling_module => l_calling_module,
                    p_project_id   => l_c1rec.parent_project_id,
                    p_structure_version_id => l_c1rec.parent_structure_ver_id,
                    p_baselined_str_ver_id => l_base_struct_ver_id,
                    p_structure_type => 'WORKPLAN',
                    x_return_status => x_return_status,
                    x_msg_count     =>  x_msg_count,
                    x_msg_data      =>  x_msg_data);

                IF x_return_status <> 'S' THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
                */
                /*

                l_pln_parent_task := pa_progress_utils.Get_BAC_Value(p_project_id => l_c1rec.parent_project_id
                                 ,p_task_weight_method => l_base_prcnt_comp_drv_code
                                 ,p_proj_element_id => l_c1rec.parent_task_id
                                 ,p_structure_version_id => l_c1rec.parent_structure_ver_id
                                 ,p_structure_type => 'WORKPLAN');


                                --parent plan includes child plan. --bug 4033869
                                l_bac := nvl(l_pln_parent_task,0);

                IF g1_debug_mode  = 'Y' THEN
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_bcwp='||l_bcwp, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_bac='||l_bac, x_Log_Level=> 3);
                END IF;

                                -- Calculating rollup percent_complete.
                IF (l_base_prcnt_comp_drv_code = 'COST' or l_base_prcnt_comp_drv_code = 'EFFORT') THEN
                    IF (l_bac > 0) THEN
                        l_eff_rollup_prcnt_comp := (l_bcwp/l_bac) * 100;
                    ELSE
                        l_eff_rollup_prcnt_comp := NULL;
                    END IF;
                END IF;

                IF g1_debug_mode  = 'Y' THEN
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_eff_rollup_prcnt_comp='||l_eff_rollup_prcnt_comp, x_Log_Level=> 3);
                END IF;


                BEGIN
                                       SELECT
                */
                        /*+ INDEX(pji_fm_xbs_accum_tmp1 pji_fm_xbs_accum_tmp1_n1)*/ -- Fix for Bug # 4162534.
                /*
                           PERIOD_NAME
                                             , ACT_PRJ_BRDN_COST-ACT_PRJ_EQUIP_BRDN_COST-ACT_PRJ_LABOR_BRDN_COST
                                             , ACT_PRJ_LABOR_BRDN_COST
                                             , ACT_PRJ_EQUIP_BRDN_COST
                                             , ACT_POU_BRDN_COST-ACT_POU_LABOR_BRDN_COST-ACT_POU_EQUIP_BRDN_COST
                                             , ACT_POU_LABOR_BRDN_COST
                                             , ACT_POU_EQUIP_BRDN_COST
                                             , ACT_LABOR_HRS
                                             , ACT_EQUIP_HRS
                                             , ETC_PRJ_BRDN_COST-ETC_PRJ_EQUIP_BRDN_COST-ETC_PRJ_LABOR_BRDN_COST
                                             , ETC_PRJ_LABOR_BRDN_COST
                                             , ETC_PRJ_EQUIP_BRDN_COST
                                             , ETC_POU_BRDN_COST-ETC_POU_LABOR_BRDN_COST-ETC_POU_EQUIP_BRDN_COST
                                             , ETC_POU_LABOR_BRDN_COST
                                             , ETC_POU_EQUIP_BRDN_COST
                                             , ETC_LABOR_HRS
                                             , ETC_EQUIP_HRS
                                             , ACT_PRJ_RAW_COST-ACT_PRJ_EQUIP_RAW_COST-ACT_PRJ_LABOR_RAW_COST
                                             , ACT_PRJ_LABOR_RAW_COST
                                             , ACT_PRJ_EQUIP_RAW_COST
                                             , ACT_POU_RAW_COST-ACT_POU_LABOR_RAW_COST-ACT_POU_EQUIP_RAW_COST
                                             , ACT_POU_LABOR_RAW_COST
                                             , ACT_POU_EQUIP_RAW_COST
                                             , ETC_PRJ_RAW_COST-ETC_PRJ_EQUIP_RAW_COST-ETC_PRJ_LABOR_RAW_COST
                                             , ETC_PRJ_LABOR_RAW_COST
                                             , ETC_PRJ_EQUIP_RAW_COST
                                             , ETC_POU_RAW_COST-ETC_POU_LABOR_RAW_COST-ETC_POU_EQUIP_RAW_COST
                                             , ETC_POU_LABOR_RAW_COST
                                             , ETC_POU_EQUIP_RAW_COST
                         , LABOR_HOURS
                         , EQUIPMENT_HOURS
                             , POU_LABOR_BRDN_COST
                         , PRJ_LABOR_BRDN_COST
                             , POU_EQUIP_BRDN_COST
                         , PRJ_EQUIP_BRDN_COST
                         , POU_BRDN_COST - ( POU_EQUIP_BRDN_COST + POU_LABOR_BRDN_COST )
                                             , PRJ_BRDN_COST - ( PRJ_EQUIP_BRDN_COST + PRJ_LABOR_BRDN_COST )
                                             , POU_LABOR_RAW_COST
                                             , PRJ_LABOR_RAW_COST
                                             , POU_EQUIP_RAW_COST
                                             , PRJ_EQUIP_RAW_COST
                                             , POU_RAW_COST - ( POU_EQUIP_RAW_COST + POU_LABOR_RAW_COST )
                                             , PRJ_RAW_COST - ( PRJ_EQUIP_RAW_COST + PRJ_LABOR_RAW_COST )
                                        INTO   l_PERIOD_NAME
                                             , l_OTH_ACT_COST_TO_DATE_PC
                                             , l_PPL_ACT_COST_TO_DATE_PC
                                             , l_EQPMT_ACT_COST_TO_DATE_PC
                                             , l_OTH_ACT_COST_TO_DATE_FC
                                             , l_PPL_ACT_COST_TO_DATE_FC
                                             , l_EQPMT_ACT_COST_TO_DATE_FC
                                             , l_PPL_ACT_EFFORT_TO_DATE
                                             , l_EQPMT_ACT_EFFORT_TO_DATE
                                             , l_ETC_Cost_PC
                                             , l_PPL_ETC_COST_PC
                                             , l_EQPMT_ETC_COST_PC
                                             , l_ETC_Cost_FC
                                             , l_PPL_ETC_COST_FC
                                             , l_EQPMT_ETC_COST_FC
                                             , l_remaining_effort1
                                             , l_EQPMT_ETC_EFFORT
                                             , l_OTH_ACT_RAWCOST_TO_DATE_PC
                                             , l_PPL_ACT_RAWCOST_TO_DATE_PC
                                             , l_EQPMT_ACT_RAWCOST_TO_DATE_PC
                                             , l_OTH_ACT_RAWCOST_TO_DATE_FC
                                             , l_PPL_ACT_RAWCOST_TO_DATE_FC
                                             , l_EQPMT_ACT_RAWCOST_TO_DATE_FC
                                             , l_ETC_RAWCost_PC
                                             , l_PPL_ETC_RAWCOST_PC
                                             , l_EQPMT_ETC_RAWCOST_PC
                                             , l_ETC_RAWCost_FC
                                             , l_PPL_ETC_RAWCOST_FC
                                             , l_EQPMT_ETC_RAWCOST_FC
                         , l_LABOR_HOURS
                         , l_EQUIPMENT_HOURS
                                             , l_POU_LABOR_BRDN_COST
                                             , l_PRJ_LABOR_BRDN_COST
                                             , l_POU_EQUIP_BRDN_COST
                                             , l_PRJ_EQUIP_BRDN_COST
                         , l_POU_OTH_BRDN_COST
                         , l_PRJ_OTH_BRDN_COST
                         , l_POU_LABOR_RAW_COST
                         , l_PRJ_LABOR_RAW_COST
                         , l_POU_EQUIP_RAW_COST
                         , l_PRJ_EQUIP_RAW_COST
                         , l_POU_OTH_RAW_COST
                         , l_PRJ_OTH_RAW_COST
                                         FROM PJI_FM_XBS_ACCUM_TMP1
                                         WHERE project_id = l_c1rec.parent_project_id
                                         AND struct_version_id = l_c1rec.parent_structure_ver_id
                                         AND project_element_id = l_c1rec.parent_task_id
                                         AND plan_version_id > 0
                                         AND txn_currency_code is null
                                         AND calendar_type = 'A'
                                         AND res_list_member_id is null;
                                EXCEPTION
                                         WHEN NO_DATA_FOUND THEN
                                              null;
                                         WHEN OTHERS THEN
                                              fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_PVT',
                                                                   p_procedure_name => 'PROGRAM_ROLLUP_PVT',
                                                                   p_error_text     => SUBSTRB('Select from PJI_FM_XBS_ACCUM_TMP1 Failed: SQLERRM'||SQLERRM,1,120));
                                             RAISE FND_API.G_EXC_ERROR;
                END;


                IF g1_debug_mode  = 'Y' THEN
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_PPL_ACT_COST_TO_DATE_PC='||l_PPL_ACT_COST_TO_DATE_PC, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'l_PPL_ACT_EFFORT_TO_DATE='||l_PPL_ACT_EFFORT_TO_DATE, x_Log_Level=> 3);
                END IF;


                -- Rollup the attributes from the structure progress record into parent task record
                IF l_mode = 'U' THEN

                    l_parent_as_of_date := l_parent_task_rec.AS_OF_DATE;   --bug 4033869

                    PA_PROGRESS_ROLLUP_PKG.UPDATE_ROW(
                    X_PROGRESS_ROLLUP_ID            =>      l_parent_task_rec.PROGRESS_ROLLUP_ID
                    ,X_PROJECT_ID                   =>      l_parent_task_rec.PROJECT_ID
                    ,X_OBJECT_ID                    =>      l_parent_task_rec.OBJECT_ID
                    ,X_OBJECT_TYPE                  =>      l_parent_task_rec.OBJECT_TYPE
                    ,X_AS_OF_DATE                   =>      l_parent_task_rec.AS_OF_DATE
                    ,X_OBJECT_VERSION_ID            =>      l_parent_task_rec.OBJECT_VERSION_ID
                    ,X_LAST_UPDATE_DATE             =>      sysdate
                    ,X_LAST_UPDATED_BY              =>      l_user_id
                    ,X_PROGRESS_STATUS_CODE         =>      l_parent_task_rec.PROGRESS_STATUS_CODE
                    ,X_LAST_UPDATE_LOGIN            =>      l_login_id
                    ,X_INCREMENTAL_WORK_QTY         =>      l_parent_task_rec.INCREMENTAL_WORK_QUANTITY
                    ,X_CUMULATIVE_WORK_QTY          =>      l_parent_task_rec.CUMULATIVE_WORK_QUANTITY
                    ,X_BASE_PERCENT_COMPLETE        =>      l_parent_task_rec.BASE_PERCENT_COMPLETE
                    ,X_EFF_ROLLUP_PERCENT_COMP      =>      l_eff_rollup_prcnt_comp
                    ,X_COMPLETED_PERCENTAGE         =>      l_parent_task_rec.COMPLETED_PERCENTAGE
                    ,X_ESTIMATED_START_DATE         =>      l_estimated_start_date -- l_parent_task_rec.ESTIMATED_START_DATE
                    ,X_ESTIMATED_FINISH_DATE        =>      l_estimated_finish_date -- l_parent_task_rec.ESTIMATED_FINISH_DATE
                    ,X_ACTUAL_START_DATE            =>      l_actual_start_date --l_parent_task_rec.ACTUAL_START_DATE
                    ,X_ACTUAL_FINISH_DATE           =>      l_actual_finish_date -- l_parent_task_rec.ACTUAL_FINISH_DATE
                    ,X_EST_REMAINING_EFFORT         =>      l_remaining_effort1
                    ,X_BASE_PERCENT_COMP_DERIV_CODE =>      l_parent_task_rec.BASE_PERCENT_COMP_DERIV_CODE
                    ,X_BASE_PROGRESS_STATUS_CODE    =>      l_parent_task_rec.BASE_PROGRESS_STATUS_CODE
                    ,X_EFF_ROLLUP_PROG_STAT_CODE    =>      l_eff_rollup_progress_status--l_parent_task_rec.EFF_ROLLUP_PROG_STAT_CODE
                    ,X_RECORD_VERSION_NUMBER        =>      l_parent_task_rec.RECORD_VERSION_NUMBER
                    ,X_percent_complete_id          =>      l_parent_task_rec.percent_complete_id
                    ,X_STRUCTURE_TYPE               =>      l_parent_task_rec.STRUCTURE_TYPE
                    ,X_PROJ_ELEMENT_ID              =>      l_parent_task_rec.PROJ_ELEMENT_ID
                    ,X_STRUCTURE_VERSION_ID         =>      l_parent_task_rec.STRUCTURE_VERSION_ID
                    ,X_PPL_ACT_EFFORT_TO_DATE       =>      l_PPL_ACT_EFFORT_TO_DATE
                    ,X_EQPMT_ACT_EFFORT_TO_DATE     =>      l_EQPMT_ACT_EFFORT_TO_DATE
                    ,X_EQPMT_ETC_EFFORT             =>      l_EQPMT_ETC_EFFORT
                    ,X_OTH_ACT_COST_TO_DATE_TC      =>      l_parent_task_rec.OTH_ACT_COST_TO_DATE_TC
                    ,X_OTH_ACT_COST_TO_DATE_FC      =>      l_OTH_ACT_COST_TO_DATE_FC
                    ,X_OTH_ACT_COST_TO_DATE_PC      =>      l_OTH_ACT_COST_TO_DATE_PC
                    ,X_OTH_ETC_COST_TC              =>      l_parent_task_rec.OTH_ETC_COST_TC
                    ,X_OTH_ETC_COST_FC              =>      l_ETC_Cost_FC
                    ,X_OTH_ETC_COST_PC              =>      l_ETC_Cost_PC
                    ,X_PPL_ACT_COST_TO_DATE_TC      =>      l_parent_task_rec.PPL_ACT_COST_TO_DATE_TC
                    ,X_PPL_ACT_COST_TO_DATE_FC      =>      l_PPL_ACT_COST_TO_DATE_FC
                    ,X_PPL_ACT_COST_TO_DATE_PC      =>      l_PPL_ACT_COST_TO_DATE_PC
                    ,X_PPL_ETC_COST_TC              =>      l_parent_task_rec.PPL_ETC_COST_TC
                    ,X_PPL_ETC_COST_FC              =>      l_PPL_ETC_COST_FC
                    ,X_PPL_ETC_COST_PC              =>      l_PPL_ETC_COST_PC
                    ,X_EQPMT_ACT_COST_TO_DATE_TC    =>      l_parent_task_rec.EQPMT_ACT_COST_TO_DATE_TC
                    ,X_EQPMT_ACT_COST_TO_DATE_FC    =>      l_EQPMT_ACT_COST_TO_DATE_FC
                    ,X_EQPMT_ACT_COST_TO_DATE_PC    =>      l_EQPMT_ACT_COST_TO_DATE_PC
                    ,X_EQPMT_ETC_COST_TC            =>      l_parent_task_rec.EQPMT_ETC_COST_TC
                    ,X_EQPMT_ETC_COST_FC            =>      l_EQPMT_ETC_COST_FC
                    ,X_EQPMT_ETC_COST_PC            =>      l_EQPMT_ETC_COST_PC
                    ,X_EARNED_VALUE                 =>      l_bcwp
                    ,X_TASK_WT_BASIS_CODE           =>      l_parent_task_rec.TASK_WT_BASIS_CODE
                    ,X_SUBPRJ_PPL_ACT_EFFORT        =>      null
                    ,X_SUBPRJ_EQPMT_ACT_EFFORT      =>      null
                    ,X_SUBPRJ_PPL_ETC_EFFORT        =>      null
                    ,X_SUBPRJ_EQPMT_ETC_EFFORT      =>      null
                    ,X_SBPJ_OTH_ACT_COST_TO_DATE_TC =>      null
                    ,X_SBPJ_OTH_ACT_COST_TO_DATE_FC =>      null
                    ,X_SBPJ_OTH_ACT_COST_TO_DATE_PC =>      null
                    ,X_SUBPRJ_PPL_ACT_COST_TC       =>      null
                    ,X_SUBPRJ_PPL_ACT_COST_FC       =>      null
                    ,X_SUBPRJ_PPL_ACT_COST_PC       =>      null
                    ,X_SUBPRJ_EQPMT_ACT_COST_TC     =>      null
                    ,X_SUBPRJ_EQPMT_ACT_COST_FC     =>      null
                    ,X_SUBPRJ_EQPMT_ACT_COST_PC     =>      null
                    ,X_SUBPRJ_OTH_ETC_COST_TC       =>      null
                    ,X_SUBPRJ_OTH_ETC_COST_FC       =>      null
                    ,X_SUBPRJ_OTH_ETC_COST_PC       =>      null
                    ,X_SUBPRJ_PPL_ETC_COST_TC       =>      null
                    ,X_SUBPRJ_PPL_ETC_COST_FC       =>      null
                    ,X_SUBPRJ_PPL_ETC_COST_PC       =>      null
                    ,X_SUBPRJ_EQPMT_ETC_COST_TC     =>      null
                    ,X_SUBPRJ_EQPMT_ETC_COST_FC     =>      null
                    ,X_SUBPRJ_EQPMT_ETC_COST_PC     =>      null
                    ,X_SUBPRJ_EARNED_VALUE          =>      null
                    ,X_CURRENT_FLAG                 =>      l_parent_task_rec.CURRENT_FLAG
                    ,X_PROJFUNC_COST_RATE_TYPE      =>      l_parent_task_rec.PROJFUNC_COST_RATE_TYPE
                    ,X_PROJFUNC_COST_EXCHANGE_RATE  =>      l_parent_task_rec.PROJFUNC_COST_EXCHANGE_RATE
                    ,X_PROJFUNC_COST_RATE_DATE      =>      l_parent_task_rec.PROJFUNC_COST_RATE_DATE
                    ,X_PROJ_COST_RATE_TYPE          =>      l_parent_task_rec.PROJ_COST_RATE_TYPE
                    ,X_PROJ_COST_EXCHANGE_RATE      =>      l_parent_task_rec.PROJ_COST_EXCHANGE_RATE
                    ,X_PROJ_COST_RATE_DATE          =>      l_parent_task_rec.PROJ_COST_RATE_DATE
                    ,X_TXN_CURRENCY_CODE            =>      l_parent_task_rec.TXN_CURRENCY_CODE
                    ,X_PROG_PA_PERIOD_NAME          =>      l_parent_task_rec.PROG_PA_PERIOD_NAME
                    ,X_PROG_GL_PERIOD_NAME          =>      l_parent_task_rec.PROG_GL_PERIOD_NAME
                    ,X_OTH_QUANTITY_TO_DATE         =>      l_parent_task_rec.oth_quantity_to_date
                    ,X_OTH_ETC_QUANTITY             =>      l_parent_task_rec.oth_etc_quantity
                    ,X_OTH_ACT_RAWCOST_TO_DATE_TC   =>  l_parent_task_rec.OTH_ACT_RAWCOST_TO_DATE_TC
                    ,X_OTH_ACT_RAWCOST_TO_DATE_FC   =>  l_OTH_ACT_RAWCOST_TO_DATE_FC
                    ,X_OTH_ACT_RAWCOST_TO_DATE_PC   =>  l_OTH_ACT_RAWCOST_TO_DATE_PC
                    ,X_OTH_ETC_RAWCOST_TC       =>  l_parent_task_rec.OTH_ETC_RAWCOST_TC
                    ,X_OTH_ETC_RAWCOST_FC       =>  l_ETC_RAWCost_FC
                    ,X_OTH_ETC_RAWCOST_PC       =>  l_ETC_RAWCost_PC
                    ,X_PPL_ACT_RAWCOST_TO_DATE_TC   =>  l_parent_task_rec.PPL_ACT_RAWCOST_TO_DATE_TC
                    ,X_PPL_ACT_RAWCOST_TO_DATE_FC   =>  l_PPL_ACT_RAWCOST_TO_DATE_FC
                    ,X_PPL_ACT_RAWCOST_TO_DATE_PC   =>  l_PPL_ACT_RAWCOST_TO_DATE_PC
                    ,X_PPL_ETC_RAWCOST_TC       =>  l_parent_task_rec.PPL_ETC_RAWCOST_TC
                    ,X_PPL_ETC_RAWCOST_FC       =>  l_PPL_ETC_RAWCOST_FC
                    ,X_PPL_ETC_RAWCOST_PC       =>  l_PPL_ETC_RAWCOST_PC
                    ,X_EQPMT_ACT_RAWCOST_TO_DATE_TC =>  l_parent_task_rec.EQPMT_ACT_RAWCOST_TO_DATE_TC
                    ,X_EQPMT_ACT_RAWCOST_TO_DATE_FC =>  l_EQPMT_ACT_RAWCOST_TO_DATE_FC
                    ,X_EQPMT_ACT_RAWCOST_TO_DATE_PC =>  l_EQPMT_ACT_RAWCOST_TO_DATE_PC
                    ,X_EQPMT_ETC_RAWCOST_TC     =>  l_parent_task_rec.EQPMT_ETC_RAWCOST_TC
                    ,X_EQPMT_ETC_RAWCOST_FC     =>  l_EQPMT_ETC_RAWCOST_FC
                    ,X_EQPMT_ETC_RAWCOST_PC     =>  l_EQPMT_ETC_RAWCOST_PC
                    ,X_SP_OTH_ACT_RAWCOST_TODATE_TC =>  null
                    ,X_SP_OTH_ACT_RAWCOST_TODATE_FC =>  null
                    ,X_SP_OTH_ACT_RAWCOST_TODATE_PC =>  null
                    ,X_SUBPRJ_PPL_ACT_RAWCOST_TC    =>  null
                    ,X_SUBPRJ_PPL_ACT_RAWCOST_FC    =>  null
                    ,X_SUBPRJ_PPL_ACT_RAWCOST_PC    =>  null
                    ,X_SUBPRJ_EQPMT_ACT_RAWCOST_TC  =>  null
                    ,X_SUBPRJ_EQPMT_ACT_RAWCOST_FC  =>  null
                    ,X_SUBPRJ_EQPMT_ACT_RAWCOST_PC  =>  null
                    ,X_SUBPRJ_OTH_ETC_RAWCOST_TC    =>  null
                    ,X_SUBPRJ_OTH_ETC_RAWCOST_FC    =>  null
                    ,X_SUBPRJ_OTH_ETC_RAWCOST_PC    =>  null
                    ,X_SUBPRJ_PPL_ETC_RAWCOST_TC    =>  null
                    ,X_SUBPRJ_PPL_ETC_RAWCOST_FC    =>  null
                    ,X_SUBPRJ_PPL_ETC_RAWCOST_PC    =>  null
                    ,X_SUBPRJ_EQPMT_ETC_RAWCOST_TC  =>  null
                    ,X_SUBPRJ_EQPMT_ETC_RAWCOST_FC  =>  null
                    ,X_SUBPRJ_EQPMT_ETC_RAWCOST_PC  =>  null
                    );

                    -- FPM Dev CR 6
                    IF Fnd_Msg_Pub.count_msg > 0 THEN
                        RAISE  FND_API.G_EXC_ERROR;
                    END IF;
                  ELSE -- IF l_mode = 'U' THEN
                      BEGIN
                        SELECT 'X'
                        INTO l_dummy
                        FROM pa_progress_rollup
                        WHERE project_id =  l_c1rec.parent_project_id
                        AND object_id = l_c1rec.parent_task_id
                        AND object_type = 'PA_TASKS'
                        AND structure_type = 'WORKPLAN'
                        AND structure_version_id is NULL
                        AND trunc(as_of_date) > p_as_of_date
                        AND current_flag = 'Y';

                        l_current_flag := 'N';
                      EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            l_current_flag := 'Y';

                        UPDATE pa_progress_rollup
                        SET current_flag = 'N'
                        WHERE project_id =  l_c1rec.parent_project_id
                        AND object_id = l_c1rec.parent_task_id
                        AND object_type = 'PA_TASKS'
                        AND structure_type = 'WORKPLAN'
                        AND structure_version_id is NULL
                        AND current_flag = 'Y';
                      END;
                      --bug 4033869
                                          --derive as of date for parent task relative to p_as_of_date
                      l_parent_as_of_date := pa_progress_utils.get_next_progress_cycle(
                                                     p_project_id => l_c1rec.parent_project_id
                                                    ,p_task_id => l_c1rec.parent_task_id
                                                    ,p_start_date => p_as_of_date);
                      --End bug 4033869
                      PA_PROGRESS_ROLLUP_PKG.INSERT_ROW(
                           X_PROGRESS_ROLLUP_ID              => l_progress_rollup_id
                          ,X_PROJECT_ID                      => l_c1rec.parent_project_id
                          ,X_OBJECT_ID                       => l_c1rec.parent_task_id
                          ,X_OBJECT_TYPE                     => 'PA_TASKS'
                          ,X_AS_OF_DATE                      => l_parent_as_of_date    --bug 4033869
                          ,X_OBJECT_VERSION_ID               => l_c1rec.parent_task_version_id
                          ,X_LAST_UPDATE_DATE                => SYSDATE
                          ,X_LAST_UPDATED_BY                 => l_user_id
                          ,X_CREATION_DATE                   => SYSDATE
                          ,X_CREATED_BY                      => l_user_id
                          ,X_PROGRESS_STATUS_CODE            => null
                          ,X_LAST_UPDATE_LOGIN               => l_login_id
                          ,X_INCREMENTAL_WORK_QTY            => null
                          ,X_CUMULATIVE_WORK_QTY             => null
                          ,X_BASE_PERCENT_COMPLETE           => null
                          ,X_EFF_ROLLUP_PERCENT_COMP         => l_eff_rollup_prcnt_comp
                          ,X_COMPLETED_PERCENTAGE            => null
                          ,X_ESTIMATED_START_DATE            => l_estimated_start_date
                          ,X_ESTIMATED_FINISH_DATE           => l_estimated_finish_date
                          ,X_ACTUAL_START_DATE               => l_actual_start_date
                          ,X_ACTUAL_FINISH_DATE              => l_actual_finish_date
                          ,X_EST_REMAINING_EFFORT            => l_remaining_effort1
                          ,X_BASE_PERCENT_COMP_DERIV_CODE    => null
                          ,X_BASE_PROGRESS_STATUS_CODE       => null
                          ,X_EFF_ROLLUP_PROG_STAT_CODE       => l_eff_rollup_progress_status
                          ,x_percent_complete_id             => null
                          ,X_STRUCTURE_TYPE                  => 'WORKPLAN'
                          ,X_PROJ_ELEMENT_ID                 => l_c1rec.parent_task_id
                          ,X_STRUCTURE_VERSION_ID            => null
                          ,X_PPL_ACT_EFFORT_TO_DATE      => l_PPL_ACT_EFFORT_TO_DATE
                          ,X_EQPMT_ACT_EFFORT_TO_DATE    => l_EQPMT_ACT_EFFORT_TO_DATE
                          ,X_EQPMT_ETC_EFFORT                => l_EQPMT_ETC_EFFORT
                          ,X_OTH_ACT_COST_TO_DATE_TC         => l_parent_task_rec.OTH_ACT_COST_TO_DATE_TC
                          ,X_OTH_ACT_COST_TO_DATE_FC         => l_OTH_ACT_COST_TO_DATE_FC
                          ,X_OTH_ACT_COST_TO_DATE_PC         => l_OTH_ACT_COST_TO_DATE_PC
                          ,X_OTH_ETC_COST_TC                 => l_parent_task_rec.OTH_ETC_COST_TC
                          ,X_OTH_ETC_COST_FC                 => l_ETC_Cost_FC
                          ,X_OTH_ETC_COST_PC                 => l_ETC_Cost_PC
                          ,X_PPL_ACT_COST_TO_DATE_TC         => l_parent_task_rec.PPL_ACT_COST_TO_DATE_TC
                          ,X_PPL_ACT_COST_TO_DATE_FC         => l_PPL_ACT_COST_TO_DATE_FC
                          ,X_PPL_ACT_COST_TO_DATE_PC         => l_PPL_ACT_COST_TO_DATE_PC
                          ,X_PPL_ETC_COST_TC                 => l_parent_task_rec.PPL_ETC_COST_TC
                          ,X_PPL_ETC_COST_FC                 => l_PPL_ETC_COST_FC
                          ,X_PPL_ETC_COST_PC                 => l_PPL_ETC_COST_PC
                          ,X_EQPMT_ACT_COST_TO_DATE_TC       => l_parent_task_rec.EQPMT_ACT_COST_TO_DATE_TC
                          ,X_EQPMT_ACT_COST_TO_DATE_FC       => l_EQPMT_ACT_COST_TO_DATE_FC
                          ,X_EQPMT_ACT_COST_TO_DATE_PC       => l_EQPMT_ACT_COST_TO_DATE_PC
                          ,X_EQPMT_ETC_COST_TC               => l_parent_task_rec.EQPMT_ETC_COST_TC
                          ,X_EQPMT_ETC_COST_FC               => l_EQPMT_ETC_COST_FC
                          ,X_EQPMT_ETC_COST_PC               => l_EQPMT_ETC_COST_PC
                          ,X_EARNED_VALUE                    => l_bcwp
                          ,X_TASK_WT_BASIS_CODE              => l_task_weight_basis_code
                          ,X_SUBPRJ_PPL_ACT_EFFORT           => null
                          ,X_SUBPRJ_EQPMT_ACT_EFFORT         => null
                          ,X_SUBPRJ_PPL_ETC_EFFORT           => null
                          ,X_SUBPRJ_EQPMT_ETC_EFFORT         => null
                          ,X_SBPJ_OTH_ACT_COST_TO_DATE_TC    => null
                          ,X_SBPJ_OTH_ACT_COST_TO_DATE_FC    => null
                          ,X_SBPJ_OTH_ACT_COST_TO_DATE_PC    => null
                          ,X_SUBPRJ_PPL_ACT_COST_TC          => null
                          ,X_SUBPRJ_PPL_ACT_COST_FC          => null
                          ,X_SUBPRJ_PPL_ACT_COST_PC          => null
                          ,X_SUBPRJ_EQPMT_ACT_COST_TC        => null
                          ,X_SUBPRJ_EQPMT_ACT_COST_FC        => null
                          ,X_SUBPRJ_EQPMT_ACT_COST_PC        => null
                          ,X_SUBPRJ_OTH_ETC_COST_TC          => null
                          ,X_SUBPRJ_OTH_ETC_COST_FC          => null
                          ,X_SUBPRJ_OTH_ETC_COST_PC          => null
                          ,X_SUBPRJ_PPL_ETC_COST_TC          => null
                          ,X_SUBPRJ_PPL_ETC_COST_FC          => null
                          ,X_SUBPRJ_PPL_ETC_COST_PC          => null
                          ,X_SUBPRJ_EQPMT_ETC_COST_TC        => null
                          ,X_SUBPRJ_EQPMT_ETC_COST_FC        => null
                          ,X_SUBPRJ_EQPMT_ETC_COST_PC        => null
                          ,X_SUBPRJ_EARNED_VALUE             => null
                          ,X_CURRENT_FLAG                    => l_current_flag
                          ,X_PROJFUNC_COST_RATE_TYPE         => l_sub_project_rec.PROJFUNC_COST_RATE_TYPE
                          ,X_PROJFUNC_COST_EXCHANGE_RATE     => l_sub_project_rec.PROJFUNC_COST_EXCHANGE_RATE
                              ,X_PROJFUNC_COST_RATE_DATE         => l_sub_project_rec.PROJFUNC_COST_RATE_DATE
                          ,X_PROJ_COST_RATE_TYPE             => l_sub_project_rec.PROJ_COST_RATE_TYPE
                              ,X_PROJ_COST_EXCHANGE_RATE         => l_sub_project_rec.PROJ_COST_EXCHANGE_RATE
                              ,X_PROJ_COST_RATE_DATE             => l_sub_project_rec.PROJ_COST_RATE_DATE
                              ,X_TXN_CURRENCY_CODE               => l_sub_project_rec.TXN_CURRENCY_CODE
                              ,X_PROG_PA_PERIOD_NAME             => l_sub_project_rec.PROG_PA_PERIOD_NAME
                              ,X_PROG_GL_PERIOD_NAME             => l_sub_project_rec.PROG_GL_PERIOD_NAME
                              ,X_OTH_QUANTITY_TO_DATE            => null
                              ,X_OTH_ETC_QUANTITY                => null
                              ,X_OTH_ACT_RAWCOST_TO_DATE_TC      => null
                              ,X_OTH_ACT_RAWCOST_TO_DATE_FC      => l_OTH_ACT_RAWCOST_TO_DATE_FC
                              ,X_OTH_ACT_RAWCOST_TO_DATE_PC      => l_OTH_ACT_RAWCOST_TO_DATE_PC
                              ,X_OTH_ETC_RAWCOST_TC      => null
                              ,X_OTH_ETC_RAWCOST_FC      => l_ETC_RAWCost_FC
                              ,X_OTH_ETC_RAWCOST_PC      => l_ETC_RAWCost_PC
                              ,X_PPL_ACT_RAWCOST_TO_DATE_TC      => null
                              ,X_PPL_ACT_RAWCOST_TO_DATE_FC      => l_PPL_ACT_RAWCOST_TO_DATE_FC
                              ,X_PPL_ACT_RAWCOST_TO_DATE_PC      => l_PPL_ACT_RAWCOST_TO_DATE_PC
                              ,X_PPL_ETC_RAWCOST_TC      => null
                              ,X_PPL_ETC_RAWCOST_FC      => l_PPL_ETC_RAWCOST_FC
                              ,X_PPL_ETC_RAWCOST_PC      => l_PPL_ETC_RAWCOST_PC
                              ,X_EQPMT_ACT_RAWCOST_TO_DATE_TC    => null
                              ,X_EQPMT_ACT_RAWCOST_TO_DATE_FC    => l_EQPMT_ACT_RAWCOST_TO_DATE_FC
                              ,X_EQPMT_ACT_RAWCOST_TO_DATE_PC    => l_EQPMT_ACT_RAWCOST_TO_DATE_PC
                              ,X_EQPMT_ETC_RAWCOST_TC        => null
                              ,X_EQPMT_ETC_RAWCOST_FC        => l_EQPMT_ETC_RAWCOST_FC
                              ,X_EQPMT_ETC_RAWCOST_PC        => l_EQPMT_ETC_RAWCOST_PC
                              ,X_SP_OTH_ACT_RAWCOST_TODATE_TC    => null
                              ,X_SP_OTH_ACT_RAWCOST_TODATE_FC    => null
                              ,X_SP_OTH_ACT_RAWCOST_TODATE_PC    => null
                              ,X_SUBPRJ_PPL_ACT_RAWCOST_TC       => null
                              ,X_SUBPRJ_PPL_ACT_RAWCOST_FC       => null
                              ,X_SUBPRJ_PPL_ACT_RAWCOST_PC       => null
                              ,X_SUBPRJ_EQPMT_ACT_RAWCOST_TC     => null
                              ,X_SUBPRJ_EQPMT_ACT_RAWCOST_FC     => null
                              ,X_SUBPRJ_EQPMT_ACT_RAWCOST_PC     => null
                              ,X_SUBPRJ_OTH_ETC_RAWCOST_TC       => null
                              ,X_SUBPRJ_OTH_ETC_RAWCOST_FC       => null
                              ,X_SUBPRJ_OTH_ETC_RAWCOST_PC       => null
                              ,X_SUBPRJ_PPL_ETC_RAWCOST_TC       => null
                              ,X_SUBPRJ_PPL_ETC_RAWCOST_FC       => null
                              ,X_SUBPRJ_PPL_ETC_RAWCOST_PC       => null
                              ,X_SUBPRJ_EQPMT_ETC_RAWCOST_TC     => null
                              ,X_SUBPRJ_EQPMT_ETC_RAWCOST_FC     => null
                              ,X_SUBPRJ_EQPMT_ETC_RAWCOST_PC     => null
                          );
                  END IF;
                */
                  -- Call rollup_progress_pvt api for the parent project.

                 IF g1_debug_mode  = 'Y' THEN
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'Done with Insert/Update, Calling Rollup', x_Log_Level=> 3);
                 END IF;
                    -- Bug 4097710 : Changed the API from PUB to PVT.
                    -- It is not good idea to call PUB APi from PVT

                  PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT(
                     p_init_msg_list             => p_init_msg_list
                    ,p_commit                    => p_commit
                    ,p_calling_module        => l_calling_module
                    ,p_validate_only             => p_validate_only
                    ,p_project_id                => l_c1rec.parent_project_id
                    ,p_object_type           => 'PA_TASKS'
                    ,p_object_id                 => l_c1rec.parent_task_id
                    ,p_object_version_id         => l_c1rec.parent_task_version_id
                    ,p_task_version_id       => l_c1rec.parent_task_version_id
                    ,p_structure_version_id      => l_c1rec.parent_structure_ver_id
                    ,p_structure_type            => 'WORKPLAN'
                    ,p_wp_rollup_method      => l_task_weight_basis_code
                    ,p_as_of_date                => l_parent_as_of_date   --bug 4033869
                    ,p_lowest_level_task         => 'Y'  -- Bug 4392189
                    ,x_return_status             => l_return_status
                    ,x_msg_count                 => l_msg_count
                    ,x_msg_data                  => l_msg_data);

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    x_msg_data := l_msg_data;
                    x_return_status := 'E';
                    x_msg_count := l_msg_count;
                    RAISE  FND_API.G_EXC_ERROR;
                END IF;

                -- 4392189 : Added call of ROLLUP_FUTURE_PROGRESS_PVT

                PA_PROGRESS_PVT.ROLLUP_FUTURE_PROGRESS_PVT(
                      p_project_id               => l_c1rec.parent_project_id
                     ,P_OBJECT_TYPE              => 'PA_TASKS'
                     ,P_OBJECT_ID                => l_c1rec.parent_task_id
                     ,p_object_version_id        => l_c1rec.parent_task_version_id
                     ,p_as_of_date               => l_parent_as_of_date
                     ,p_lowest_level_task        => 'Y'
                     ,p_calling_module           => l_calling_module
                     ,p_structure_type           => 'WORKPLAN'
                     ,p_structure_version_id     => l_c1rec.parent_structure_ver_id
                     ,p_wp_rollup_method         => l_task_weight_basis_code
                     ,x_return_status            => l_return_status
                     ,x_msg_count                => l_msg_count
                     ,x_msg_data                 => l_msg_data
                   );

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    x_msg_data := l_msg_data;
                    x_return_status := 'E';
                    x_msg_count := l_msg_count;
                    RAISE  FND_API.G_EXC_ERROR;
                END IF;

                         --  END IF; -- IF (l_base_prcnt_comp_drv_code = 'COST' or l_base_prcnt_comp_drv_code = 'EFFORT')
            END IF; -- p_structure_type = 'WORKPLAN'

                        --bug 4033869
                IF g1_debug_mode  = 'Y' THEN
                           pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'Calling program_rollup_pvt in recursion', x_Log_Level=> 3);
                        END IF;
            -- Bug 4097710 : Changed the API from PUB to PVT.
            -- It is not good idea to call PUB APi from PVT
                        pa_progress_pvt.program_rollup_pvt(
                             p_init_msg_list        => 'F'
                            ,p_calling_module       => p_calling_module  --4492493
                            ,p_commit               => 'F'
                            ,p_validate_only        => 'F'
                            ,p_project_id           => l_c1rec.parent_project_id
                            ,p_as_of_date           => p_as_of_date
                            ,p_structure_type       => p_structure_type
                            ,p_structure_ver_id     => l_c1rec.parent_structure_ver_id
                            ,x_return_status        => l_return_status
                            ,x_msg_count            => l_msg_count
                            ,x_msg_data             => l_msg_data);
                       IF g1_debug_mode  = 'Y' THEN
                           pa_debug.write(x_Module=>'PA_PROGRESS_PVT.PROGRAM_ROLLUP_PVT', x_Msg => 'After Calling program_rollup_pvt recursively l_return_status='||l_return_status, x_Log_Level=> 3);
                       END IF;

                   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              x_msg_data := l_msg_data;
              x_return_status := 'E';
              x_msg_count := l_msg_count;
              RAISE  FND_API.G_EXC_ERROR;
               END IF;
                       --end bug 4033869
                    end if;   ---4492493
                END LOOP;
        CLOSE C1;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                x_msg_data := l_msg_data;
                x_return_status := 'E';
                x_msg_count := l_msg_count;
                RAISE  FND_API.G_EXC_ERROR;
        END IF;

        IF (p_commit = FND_API.G_TRUE) THEN
                COMMIT;
        END IF;


EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to PROGRAM_ROLLUP_PVT2;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to PROGRAM_ROLLUP_PVT2;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_PVT',
                              p_procedure_name => 'PROGRAM_ROLLUP_PVT',
                              p_error_text     => SUBSTRB(SQLERRM,1,120));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to PROGRAM_ROLLUP_PVT2;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_PVT',
                              p_procedure_name => 'PROGRAM_ROLLUP_PVT',
                              p_error_text     => SUBSTRB(SQLERRM,1,120));
      raise;
END program_rollup_pvt;

-- Bug 3614828 : Created this procedure for partial rollup.
-- Start of comments
--      API name        : ASGN_DLV_TO_TASK_ROLLUP_PVT
--      Type            : Private
--      Pre-reqs        : None.
--      Purpose         : This API is intdended to be called for Assignment, Deliverables in Task Progress Details page when user clicks Recalculate button
--                      : This does partial rollup of working progress records
--      History         : 15-JUNE-04  amksingh   Rewritten For FPM Development Bug 3614828
-- End of comments

PROCEDURE ASGN_DLV_TO_TASK_ROLLUP_PVT(
 p_api_version                          IN      NUMBER          :=1.0
,p_init_msg_list                        IN      VARCHAR2        :=FND_API.G_FALSE -- Since it is a private API so false
,p_commit                               IN      VARCHAR2        :=FND_API.G_FALSE
,p_validate_only                        IN      VARCHAR2        :=FND_API.G_TRUE
,p_validation_level                     IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
,p_calling_module                       IN      VARCHAR2        :='SELF_SERVICE'
,p_debug_mode                           IN      VARCHAR2        :='N'
,p_max_msg_count                        IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_project_id                           IN      NUMBER
,p_task_id                              IN      NUMBER
,p_task_version_id                      IN      NUMBER
,p_as_of_date                           IN      DATE
,p_structure_version_id                 IN      NUMBER
,p_wp_rollup_method                     IN      VARCHAR2        := 'COST'
,x_return_status                        OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count                            OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data                             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
 IS

   l_api_name                   CONSTANT VARCHAR(30) := 'ASGN_DLV_TO_TASK_ROLLUP_PVT'                           ;
   l_api_version                CONSTANT NUMBER      := 1.0                                                     ;
   l_return_status              VARCHAR2(1)                                                                     ;
   l_msg_count                  NUMBER                                                                          ;
   l_msg_data                   VARCHAR2(250)                                                                   ;
   l_data                       VARCHAR2(250)                                                                   ;
   l_msg_index_out              NUMBER                                                                          ;
   l_error_msg_code             VARCHAR2(250)                                                                   ;
   l_user_id                    NUMBER := FND_GLOBAL.USER_ID                                                    ;
   l_login_id                   NUMBER := FND_GLOBAL.LOGIN_ID                                                   ;
   l_lowest_task                VARCHAR2(1)                                                                     ;
   l_published_structure        VARCHAR2(1)                                                                     ;
   l_task_version_id            NUMBER                                                                          ;
   l_rollup_table1              PA_SCHEDULE_OBJECTS_PVT.PA_SCHEDULE_OBJECTS_TBL_TYPE                            ;
   l_index                      NUMBER   := 0                                                                   ;
   l_parent_count               NUMBER   := 0                                                                   ;
   l_process_number             NUMBER                                                                          ;
   j                            NUMBER                                                                          ;
   l_wbs_level                  NUMBER                                                                          ;
   l_action_allowed             VARCHAR2(1)                                                                     ;
   l_sharing_Enabled            VARCHAR2(1)                                                                     ;
   L_TASK_DERIVATION_CODE       pa_proj_elements.base_percent_comp_deriv_code%TYPE                              ;
   l_split_workplan             VARCHAR2(1)                                                                     ;
   l_structure_version_id       NUMBER                                                                          ;
   g1_debug_mode                VARCHAR2(1)                                                                     ;
   l_Rollup_Method              pa_proj_progress_attr.task_weight_basis_code%TYPE                               ;


   --This cursor selects the given task.
   CURSOR cur_tasks( c_task_ver_id NUMBER )
   IS
       SELECT     obj.object_id_from1
                , obj.object_type_from parent_object_type
                , ppev.wbs_level-1 parent_wbs_level
                , ppev.element_version_id object_id_to1
                , ppev.object_type object_type
                , ppev.wbs_level wbs_level
                , obj.weighting_percentage
                , ppr.EFF_ROLLUP_PERCENT_COMP rollup_completed_percentage
                , ppr.completed_percentage override_percent_complete
                , ppr.base_percent_complete
                , ppr.actual_start_date
                , ppr.actual_finish_date
                , ppr.estimated_start_date
                , ppr.estimated_finish_date
                , pps1.project_status_weight rollup_weight1 ---rollup progress status code
                , pps2.project_status_weight override_weight2 ---override progress status code
                , pps3.project_status_weight base_weight3     --base prog status
                , ppr.ESTIMATED_REMAINING_EFFORT
                , to_number( null ) task_weight4       --task status
                , to_char(null) status_code
                , ppev.proj_element_id
                , ppr.STRUCTURE_TYPE
                , ppr.PROJ_ELEMENT_ID rollup_proj_element_id
                , ppr.PPL_ACT_EFFORT_TO_DATE
                , ppr.EQPMT_ACT_EFFORT_TO_DATE
                , ppr.PPL_ACT_EFFORT_TO_DATE + ppr.EQPMT_ACT_EFFORT_TO_DATE total_act_effort_to_date
                , ppr.EQPMT_ETC_EFFORT
                , ppr.EQPMT_ETC_EFFORT + ppr.estimated_remaining_effort total_etc_effort
                , ppr.OTH_ACT_COST_TO_DATE_TC
                , ppr.OTH_ACT_COST_TO_DATE_PC
                , ppr.OTH_ACT_COST_TO_DATE_FC
                , ppr.OTH_ETC_COST_TC
                , ppr.OTH_ETC_COST_PC
                , ppr.OTH_ETC_COST_FC
                , ppr.PPL_ACT_COST_TO_DATE_TC
                , ppr.PPL_ACT_COST_TO_DATE_PC
                , ppr.PPL_ACT_COST_TO_DATE_FC
                , ppr.PPL_ETC_COST_TC
                , ppr.PPL_ETC_COST_PC
                , ppr.PPL_ETC_COST_FC
                , ppr.EQPMT_ACT_COST_TO_DATE_TC
                , ppr.EQPMT_ACT_COST_TO_DATE_PC
                , ppr.EQPMT_ACT_COST_TO_DATE_FC
                , ppr.OTH_ACT_COST_TO_DATE_TC + ppr.PPL_ACT_COST_TO_DATE_TC + ppr.EQPMT_ACT_COST_TO_DATE_TC total_act_cost_to_date_tc
                , ppr.OTH_ACT_COST_TO_DATE_PC + ppr.PPL_ACT_COST_TO_DATE_PC + ppr.EQPMT_ACT_COST_TO_DATE_PC total_act_cost_to_date_pc
                , ppr.OTH_ACT_COST_TO_DATE_FC + ppr.PPL_ACT_COST_TO_DATE_FC + ppr.EQPMT_ACT_COST_TO_DATE_FC total_act_cost_to_date_fc
                , ppr.EQPMT_ETC_COST_TC
                , ppr.EQPMT_ETC_COST_PC
                , ppr.EQPMT_ETC_COST_FC
                , ppr.OTH_ETC_COST_TC + ppr.PPL_ETC_COST_TC + ppr.EQPMT_ETC_COST_TC total_etc_cost_tc
                , ppr.OTH_ETC_COST_PC + ppr.PPL_ETC_COST_PC + ppr.EQPMT_ETC_COST_PC total_etc_cost_pc
                , ppr.OTH_ETC_COST_FC + ppr.PPL_ETC_COST_FC + ppr.EQPMT_ETC_COST_FC total_etc_cost_fc
--Bug 3614828 Begin
                , ppr.OTH_ACT_RAWCOST_TO_DATE_TC
                , ppr.OTH_ACT_RAWCOST_TO_DATE_PC
                , ppr.OTH_ACT_RAWCOST_TO_DATE_FC
                , ppr.EQPMT_ACT_RAWCOST_TO_DATE_TC
                , ppr.EQPMT_ACT_RAWCOST_TO_DATE_PC
                , ppr.EQPMT_ACT_RAWCOST_TO_DATE_FC
                , ppr.PPL_ACT_RAWCOST_TO_DATE_TC
                , ppr.PPL_ACT_RAWCOST_TO_DATE_PC
                , ppr.PPL_ACT_RAWCOST_TO_DATE_FC
                , ppr.OTH_ETC_RAWCost_TC
                , ppr.OTH_ETC_RAWCost_PC
                , ppr.OTH_ETC_RAWCost_FC
                , ppr.PPL_ETC_RAWCOST_TC
                , ppr.PPL_ETC_RAWCOST_PC
                , ppr.PPL_ETC_RAWCOST_FC
                , ppr.EQPMT_ETC_RAWCOST_TC
                , ppr.EQPMT_ETC_RAWCOST_PC
                , ppr.EQPMT_ETC_RAWCOST_FC
--Bug 3614828 End
                , ppr.SUBPRJ_PPL_ACT_EFFORT
                , ppr.SUBPRJ_EQPMT_ACT_EFFORT
                , ppr.SUBPRJ_PPL_ETC_EFFORT
                , ppr.SUBPRJ_EQPMT_ETC_EFFORT
                , ppr.SUBPRJ_OTH_ACT_COST_TO_DATE_TC
                , ppr.SUBPRJ_OTH_ACT_COST_TO_DATE_FC
                , ppr.SUBPRJ_OTH_ACT_COST_TO_DATE_PC
                , ppr.SUBPRJ_PPL_ACT_COST_TC
                , ppr.SUBPRJ_PPL_ACT_COST_FC
                , ppr.SUBPRJ_PPL_ACT_COST_PC
                , ppr.SUBPRJ_EQPMT_ACT_COST_TC
                , ppr.SUBPRJ_EQPMT_ACT_COST_FC
                , ppr.SUBPRJ_EQPMT_ACT_COST_PC
                , ppr.SUBPRJ_OTH_ACT_COST_TO_DATE_TC + ppr.SUBPRJ_PPL_ACT_COST_TC + ppr.SUBPRJ_EQPMT_ACT_COST_TC total_subproj_act_cost_tc
                , ppr.SUBPRJ_OTH_ACT_COST_TO_DATE_PC + ppr.SUBPRJ_PPL_ACT_COST_PC + ppr.SUBPRJ_EQPMT_ACT_COST_PC total_subproj_act_cost_pc
                , ppr.SUBPRJ_OTH_ACT_COST_TO_DATE_FC + ppr.SUBPRJ_PPL_ACT_COST_FC + ppr.SUBPRJ_EQPMT_ACT_COST_FC total_subproj_act_cost_fc
                , ppr.SUBPRJ_OTH_ETC_COST_TC
                , ppr.SUBPRJ_OTH_ETC_COST_FC
                , ppr.SUBPRJ_OTH_ETC_COST_PC
                , ppr.SUBPRJ_PPL_ETC_COST_TC
                , ppr.SUBPRJ_PPL_ETC_COST_FC
                , ppr.SUBPRJ_PPL_ETC_COST_PC
                , ppr.SUBPRJ_EQPMT_ETC_COST_TC
                , ppr.SUBPRJ_EQPMT_ETC_COST_FC
                , ppr.SUBPRJ_EQPMT_ETC_COST_PC
                , ppr.SUBPRJ_OTH_ETC_COST_TC + ppr.SUBPRJ_PPL_ETC_COST_TC + ppr.SUBPRJ_EQPMT_ETC_COST_TC total_subproj_etc_cost_tc
                , ppr.SUBPRJ_OTH_ETC_COST_PC + ppr.SUBPRJ_PPL_ETC_COST_PC + ppr.SUBPRJ_EQPMT_ETC_COST_PC total_subproj_etc_cost_pc
                , ppr.SUBPRJ_OTH_ETC_COST_FC + ppr.SUBPRJ_PPL_ETC_COST_FC + ppr.SUBPRJ_EQPMT_ETC_COST_FC total_subproj_etc_cost_fc
                , ppr.SUBPRJ_EARNED_VALUE
                , ppr.CURRENT_FLAG
                , ppr.PROJFUNC_COST_RATE_TYPE
                , ppr.PROJFUNC_COST_EXCHANGE_RATE
                , ppr.PROJFUNC_COST_RATE_DATE
                , ppr.PROJ_COST_RATE_TYPE
                , ppr.PROJ_COST_EXCHANGE_RATE
                , ppr.PROJ_COST_RATE_DATE
                , ppr.TXN_CURRENCY_CODE
                , ppr.PROG_PA_PERIOD_NAME
                , ppr.PROG_GL_PERIOD_NAME
                , pa_progress_utils.Get_BAC_Value(ppev.project_id, p_wp_rollup_method, ppev.proj_element_id, ppev.parent_structure_version_id, 'WORKPLAN') BAC_value
                , pa_progress_utils.Get_BAC_Value(ppev.project_id, p_wp_rollup_method, ppev.proj_element_id, ppev.parent_structure_version_id, 'WORKPLAN','N','N') BAC_value_self -- bug 4493105
                , null earned_value
		, ppr.Oth_quantity_to_date
		, ppr.Oth_etc_quantity
		-- 4533112 : Added base_progress_status_code
		, decode(ppr.base_progress_status_code, 'Y' , 'Y', 'N') base_progress_status_code
       FROM pa_proj_element_versions ppev,
            pa_object_relationships  obj,
            pa_progress_rollup ppr,
            pa_project_statuses pps1,
            pa_project_statuses pps2,
            pa_project_statuses pps3,
        pa_proj_elements ppe -- 4392189
       WHERE ppev.element_version_id = c_task_ver_id
       AND ppev.element_version_id = obj.object_id_to1
       AND obj.relationship_type = 'S'
       AND ppev.object_type = 'PA_TASKS'
       AND ppev.proj_element_id = ppe.proj_element_id -- 4392189
       AND ppe.link_task_flag <> 'Y' -- 4392189
       AND ppr.project_id = ppev.project_id
       AND ppr.object_id = ppev.proj_element_id
       AND ppr.proj_element_id = ppev.proj_element_id -- Bug 3764224
--       AND ppr.as_of_date = trunc(p_as_of_date)
       -- Bug 3879461 : After discussion with Sameer Realeraskar, Majid
       -- It is to select only the rollup record till passed as of date
       AND ppr.as_of_date = (SELECT max(as_of_date)
                 FROM pa_progress_rollup
                 WHERE project_id = p_project_id
                 AND object_id = ppev.proj_element_id
                 AND proj_element_id = ppev.proj_element_id
                 AND object_type = 'PA_TASKS'
                 AND structure_type = 'WORKPLAN'
                 AND structure_version_id is null
                 AND as_of_date <= p_as_of_date
                )
        AND (ppr.current_flag = 'W'
           OR (ppr.current_flag IN( 'Y', 'N') -- Bug 4336720 : Added Y and N Both
           AND NOT EXISTS (select 1
                           from pa_progress_rollup ppc1
                          where ppc1.project_id = p_project_id
                            and ppc1.object_id = ppev.proj_element_id
                            and ppc1.proj_element_id = ppev.proj_element_id
                            and ppc1.object_Type = 'PA_TASKS'
                            and ppc1.structure_type = 'WORKPLAN'
                and ppc1.as_of_date <= p_as_of_date
                            and ppc1.structure_version_id is null
                            and ppc1.current_flag = 'W')))
--       AND ppr.as_of_date = pa_progress_utils.get_max_rollup_asofdate2(ppev.project_id,
--                              ppev.proj_element_id, ppev.object_type,'WORKPLAN',null, ppev.proj_element_id/* Bug 3764224 */)
         AND ppr.EFF_ROLLUP_PROG_STAT_CODE = pps1.project_status_code(+)
         AND ppr.progress_status_code = pps2.project_status_code(+)
         AND ppr.base_progress_status_code = pps3.project_status_code(+)
         AND ppr.structure_type = 'WORKPLAN'
         AND ppr.structure_version_id is null
--         AND ppr.current_flag = 'W'     --bug 3879461
UNION ALL
       SELECT to_number(null) object_id_from1
                , ppev.object_type parent_object_type
                , wbs_level parent_wbs_level
                , element_version_id object_id_to1
                , ppev.object_type object_type
                , wbs_level wbs_level
                , to_number( null ) weighting_percentage
                , to_number(null) rollup_completed_percentage
                , to_number(null) override_percent_complete
                , to_number(null) base_percent_complete
                , to_date(null) actual_start_date
                , to_date(null) actual_finish_date
                , to_date(null) estimated_start_date
                , to_date(null) estimated_finish_date
                , to_number(null) rollup_weight1 ---rollup progress status code
                , to_number(null) override_weight2 ---override progress status code
                , to_number(null) base_weight3     --base prog status
                , to_number(null) ESTIMATED_REMAINING_EFFORT
                , to_number( null ) task_weight4       --task status
                , to_char(null) status_code
                , ppev.proj_element_id
                , to_char(null) STRUCTURE_TYPE
                , to_number(null) rollup_proj_element_id
                , to_number(null) PPL_ACT_EFFORT_TO_DATE
                , to_number(null) EQPMT_ACT_EFFORT_TO_DATE
                , to_number(null) total_act_effort_to_date
                , to_number(null) EQPMT_ETC_EFFORT
                , to_number(null) total_etc_effort
                , to_number(null) OTH_ACT_COST_TO_DATE_TC
                , to_number(null) OTH_ACT_COST_TO_DATE_PC
                , to_number(null) OTH_ACT_COST_TO_DATE_FC
                , to_number(null) OTH_ETC_COST_TC
                , to_number(null) OTH_ETC_COST_PC
                , to_number(null) OTH_ETC_COST_FC
                , to_number(null) PPL_ACT_COST_TO_DATE_TC
                , to_number(null) PPL_ACT_COST_TO_DATE_PC
                , to_number(null) PPL_ACT_COST_TO_DATE_FC
                , to_number(null) PPL_ETC_COST_TC
                , to_number(null) PPL_ETC_COST_PC
                , to_number(null) PPL_ETC_COST_FC
                , to_number(null) EQPMT_ACT_COST_TO_DATE_TC
                , to_number(null) EQPMT_ACT_COST_TO_DATE_PC
                , to_number(null) EQPMT_ACT_COST_TO_DATE_FC
                , to_number(null) total_act_cost_to_date_tc
                , to_number(null) total_act_cost_to_date_pc
                , to_number(null) total_act_cost_to_date_fc
                , to_number(null) EQPMT_ETC_COST_TC
                , to_number(null) EQPMT_ETC_COST_PC
                , to_number(null) EQPMT_ETC_COST_FC
                , to_number(null) total_etc_cost_tc
                , to_number(null) total_etc_cost_pc
                , to_number(null) total_etc_cost_fc
--Bug 3614828 Begin
                , to_number(null) OTH_ACT_RAWCOST_TO_DATE_TC
                , to_number(null) OTH_ACT_RAWCOST_TO_DATE_PC
                , to_number(null) OTH_ACT_RAWCOST_TO_DATE_FC
                , to_number(null) EQPMT_ACT_RAWCOST_TO_DATE_TC
                , to_number(null) EQPMT_ACT_RAWCOST_TO_DATE_PC
                , to_number(null) EQPMT_ACT_RAWCOST_TO_DATE_FC
                , to_number(null) PPL_ACT_RAWCOST_TO_DATE_TC
                , to_number(null) PPL_ACT_RAWCOST_TO_DATE_PC
                , to_number(null) PPL_ACT_RAWCOST_TO_DATE_FC
                , to_number(null) OTH_ETC_RAWCost_TC
                , to_number(null) OTH_ETC_RAWCost_PC
                , to_number(null) OTH_ETC_RAWCost_FC
                , to_number(null) PPL_ETC_RAWCOST_TC
                , to_number(null) PPL_ETC_RAWCOST_PC
                , to_number(null) PPL_ETC_RAWCOST_FC
                , to_number(null) EQPMT_ETC_RAWCOST_TC
                , to_number(null) EQPMT_ETC_RAWCOST_PC
                , to_number(null) EQPMT_ETC_RAWCOST_FC
--Bug 3614828 End
                , to_number(null) SUBPRJ_PPL_ACT_EFFORT
                , to_number(null) SUBPRJ_EQPMT_ACT_EFFORT
                , to_number(null) SUBPRJ_PPL_ETC_EFFORT
                , to_number(null) SUBPRJ_EQPMT_ETC_EFFORT
                , to_number(null) SUBPRJ_OTH_ACT_COST_TO_DATE_TC
                , to_number(null) SUBPRJ_OTH_ACT_COST_TO_DATE_FC
                , to_number(null) SUBPRJ_OTH_ACT_COST_TO_DATE_PC
                , to_number(null) SUBPRJ_PPL_ACT_COST_TC
                , to_number(null) SUBPRJ_PPL_ACT_COST_FC
                , to_number(null) SUBPRJ_PPL_ACT_COST_PC
                , to_number(null) SUBPRJ_EQPMT_ACT_COST_TC
                , to_number(null) SUBPRJ_EQPMT_ACT_COST_FC
                , to_number(null) SUBPRJ_EQPMT_ACT_COST_PC
                , to_number(null) total_subproj_act_cost_tc
                , to_number(null) total_subproj_act_cost_pc
                , to_number(null) total_subproj_act_cost_fc
                , to_number(null) SUBPRJ_OTH_ETC_COST_TC
                , to_number(null) SUBPRJ_OTH_ETC_COST_FC
                , to_number(null) SUBPRJ_OTH_ETC_COST_PC
                , to_number(null) SUBPRJ_PPL_ETC_COST_TC
                , to_number(null) SUBPRJ_PPL_ETC_COST_FC
                , to_number(null) SUBPRJ_PPL_ETC_COST_PC
                , to_number(null) SUBPRJ_EQPMT_ETC_COST_TC
                , to_number(null) SUBPRJ_EQPMT_ETC_COST_FC
                , to_number(null) SUBPRJ_EQPMT_ETC_COST_PC
                , to_number(null) total_subproj_etc_cost_tc
                , to_number(null) total_subproj_etc_cost_pc
                , to_number(null) total_subproj_etc_cost_fc
                , to_number(null) SUBPRJ_EARNED_VALUE
                , to_char(null) CURRENT_FLAG
                , to_char(null) PROJFUNC_COST_RATE_TYPE
                , to_number(null) PROJFUNC_COST_EXCHANGE_RATE
                , to_date(null) PROJFUNC_COST_RATE_DATE
                , to_char(null) PROJ_COST_RATE_TYPE
                , to_number(null) PROJ_COST_EXCHANGE_RATE
                , to_date(null) PROJ_COST_RATE_DATE
                , to_char(null) TXN_CURRENCY_CODE
                , to_char(null) PROG_PA_PERIOD_NAME
                , to_char(null) PROG_GL_PERIOD_NAME
                , pa_progress_utils.Get_BAC_Value(ppev.project_id, p_wp_rollup_method, ppev.proj_element_id, ppev.parent_structure_version_id, 'WORKPLAN') BAC_value
                , pa_progress_utils.Get_BAC_Value(ppev.project_id, p_wp_rollup_method, ppev.proj_element_id, ppev.parent_structure_version_id, 'WORKPLAN','N','N') BAC_value_self -- bug 4493105
                , null earned_value
		, to_number(null) Oth_quantity_to_date
		, to_number(null) Oth_etc_quantity
		-- 4533112 : Added base_progress_status_code
		, 'N' base_progress_status_code
       FROM pa_proj_element_versions ppev
       WHERE ppev.element_version_id = c_task_ver_id
       AND ppev.object_type = 'PA_TASKS'
       -- Bug 3879461 Begin
       AND NOT EXISTS (SELECT 1
                 FROM pa_progress_rollup
                 WHERE project_id = p_project_id
                 AND object_id = ppev.proj_element_id
                 AND proj_element_id = ppev.proj_element_id
                 AND object_type = 'PA_TASKS'
                 AND structure_type = 'WORKPLAN'
                 AND structure_version_id is null
                 AND as_of_date <= p_as_of_date
                )
--       AND pa_progress_utils.get_max_rollup_asofdate2(ppev.project_id,
--                              ppev.proj_element_id, ppev.object_type,'WORKPLAN',null, ppev.proj_element_id/* Bug 3764224 */) IS NULL
       -- Bug 3879461 End
-- Begin fix for Bug # 4032987.
-- This query returns the progress of immediate sub-tasks of the input task.
UNION ALL
       SELECT     obj.object_id_from1
                , obj.object_type_from parent_object_type
                , ppev1.wbs_level-1 parent_wbs_level
                , ppev2.element_version_id object_id_to1
                , ppev2.object_type object_type
                , ppev2.wbs_level wbs_level
                , obj.weighting_percentage
                , ppr.EFF_ROLLUP_PERCENT_COMP rollup_completed_percentage
                , ppr.completed_percentage override_percent_complete
                , ppr.base_percent_complete
                , ppr.actual_start_date
                , ppr.actual_finish_date
                , ppr.estimated_start_date
                , ppr.estimated_finish_date
                , pps1.project_status_weight rollup_weight1 ---rollup progress status code
                , pps2.project_status_weight override_weight2 ---override progress status code
                , pps3.project_status_weight base_weight3     --base prog status
                , ppr.ESTIMATED_REMAINING_EFFORT
                , to_number( null ) task_weight4       --task status
                , to_char(null) status_code
                , ppev2.proj_element_id
                , ppr.STRUCTURE_TYPE
                , ppr.PROJ_ELEMENT_ID rollup_proj_element_id
                , ppr.PPL_ACT_EFFORT_TO_DATE
                , ppr.EQPMT_ACT_EFFORT_TO_DATE
                , ppr.PPL_ACT_EFFORT_TO_DATE + ppr.EQPMT_ACT_EFFORT_TO_DATE total_act_effort_to_date
                , ppr.EQPMT_ETC_EFFORT
                , ppr.EQPMT_ETC_EFFORT + ppr.estimated_remaining_effort total_etc_effort
                , ppr.OTH_ACT_COST_TO_DATE_TC
                , ppr.OTH_ACT_COST_TO_DATE_PC
                , ppr.OTH_ACT_COST_TO_DATE_FC
                , ppr.OTH_ETC_COST_TC
                , ppr.OTH_ETC_COST_PC
                , ppr.OTH_ETC_COST_FC
                , ppr.PPL_ACT_COST_TO_DATE_TC
                , ppr.PPL_ACT_COST_TO_DATE_PC
                , ppr.PPL_ACT_COST_TO_DATE_FC
                , ppr.PPL_ETC_COST_TC
                , ppr.PPL_ETC_COST_PC
                , ppr.PPL_ETC_COST_FC
                , ppr.EQPMT_ACT_COST_TO_DATE_TC
                , ppr.EQPMT_ACT_COST_TO_DATE_PC
                , ppr.EQPMT_ACT_COST_TO_DATE_FC
                , ppr.OTH_ACT_COST_TO_DATE_TC + ppr.PPL_ACT_COST_TO_DATE_TC + ppr.EQPMT_ACT_COST_TO_DATE_TC total_act_cost_to_date_tc
                , ppr.OTH_ACT_COST_TO_DATE_PC + ppr.PPL_ACT_COST_TO_DATE_PC + ppr.EQPMT_ACT_COST_TO_DATE_PC total_act_cost_to_date_pc
                , ppr.OTH_ACT_COST_TO_DATE_FC + ppr.PPL_ACT_COST_TO_DATE_FC + ppr.EQPMT_ACT_COST_TO_DATE_FC total_act_cost_to_date_fc
                , ppr.EQPMT_ETC_COST_TC
                , ppr.EQPMT_ETC_COST_PC
                , ppr.EQPMT_ETC_COST_FC
                , ppr.OTH_ETC_COST_TC + ppr.PPL_ETC_COST_TC + ppr.EQPMT_ETC_COST_TC total_etc_cost_tc
                , ppr.OTH_ETC_COST_PC + ppr.PPL_ETC_COST_PC + ppr.EQPMT_ETC_COST_PC total_etc_cost_pc
                , ppr.OTH_ETC_COST_FC + ppr.PPL_ETC_COST_FC + ppr.EQPMT_ETC_COST_FC total_etc_cost_fc
                , ppr.OTH_ACT_RAWCOST_TO_DATE_TC
                , ppr.OTH_ACT_RAWCOST_TO_DATE_PC
                , ppr.OTH_ACT_RAWCOST_TO_DATE_FC
                , ppr.EQPMT_ACT_RAWCOST_TO_DATE_TC
                , ppr.EQPMT_ACT_RAWCOST_TO_DATE_PC
                , ppr.EQPMT_ACT_RAWCOST_TO_DATE_FC
                , ppr.PPL_ACT_RAWCOST_TO_DATE_TC
                , ppr.PPL_ACT_RAWCOST_TO_DATE_PC
                , ppr.PPL_ACT_RAWCOST_TO_DATE_FC
                , ppr.OTH_ETC_RAWCost_TC
                , ppr.OTH_ETC_RAWCost_PC
                , ppr.OTH_ETC_RAWCost_FC
                , ppr.PPL_ETC_RAWCOST_TC
                , ppr.PPL_ETC_RAWCOST_PC
                , ppr.PPL_ETC_RAWCOST_FC
                , ppr.EQPMT_ETC_RAWCOST_TC
                , ppr.EQPMT_ETC_RAWCOST_PC
                , ppr.EQPMT_ETC_RAWCOST_FC
                , ppr.SUBPRJ_PPL_ACT_EFFORT
                , ppr.SUBPRJ_EQPMT_ACT_EFFORT
                , ppr.SUBPRJ_PPL_ETC_EFFORT
                , ppr.SUBPRJ_EQPMT_ETC_EFFORT
                , ppr.SUBPRJ_OTH_ACT_COST_TO_DATE_TC
                , ppr.SUBPRJ_OTH_ACT_COST_TO_DATE_FC
                , ppr.SUBPRJ_OTH_ACT_COST_TO_DATE_PC
                , ppr.SUBPRJ_PPL_ACT_COST_TC
                , ppr.SUBPRJ_PPL_ACT_COST_FC
                , ppr.SUBPRJ_PPL_ACT_COST_PC
                , ppr.SUBPRJ_EQPMT_ACT_COST_TC
                , ppr.SUBPRJ_EQPMT_ACT_COST_FC
                , ppr.SUBPRJ_EQPMT_ACT_COST_PC
                , ppr.SUBPRJ_OTH_ACT_COST_TO_DATE_TC + ppr.SUBPRJ_PPL_ACT_COST_TC + ppr.SUBPRJ_EQPMT_ACT_COST_TC total_subproj_act_cost_tc
                , ppr.SUBPRJ_OTH_ACT_COST_TO_DATE_PC + ppr.SUBPRJ_PPL_ACT_COST_PC + ppr.SUBPRJ_EQPMT_ACT_COST_PC total_subproj_act_cost_pc
                , ppr.SUBPRJ_OTH_ACT_COST_TO_DATE_FC + ppr.SUBPRJ_PPL_ACT_COST_FC + ppr.SUBPRJ_EQPMT_ACT_COST_FC total_subproj_act_cost_fc
                , ppr.SUBPRJ_OTH_ETC_COST_TC
                , ppr.SUBPRJ_OTH_ETC_COST_FC
                , ppr.SUBPRJ_OTH_ETC_COST_PC
                , ppr.SUBPRJ_PPL_ETC_COST_TC
                , ppr.SUBPRJ_PPL_ETC_COST_FC
                , ppr.SUBPRJ_PPL_ETC_COST_PC
                , ppr.SUBPRJ_EQPMT_ETC_COST_TC
                , ppr.SUBPRJ_EQPMT_ETC_COST_FC
                , ppr.SUBPRJ_EQPMT_ETC_COST_PC
                , ppr.SUBPRJ_OTH_ETC_COST_TC + ppr.SUBPRJ_PPL_ETC_COST_TC + ppr.SUBPRJ_EQPMT_ETC_COST_TC total_subproj_etc_cost_tc
                , ppr.SUBPRJ_OTH_ETC_COST_PC + ppr.SUBPRJ_PPL_ETC_COST_PC + ppr.SUBPRJ_EQPMT_ETC_COST_PC total_subproj_etc_cost_pc
                , ppr.SUBPRJ_OTH_ETC_COST_FC + ppr.SUBPRJ_PPL_ETC_COST_FC + ppr.SUBPRJ_EQPMT_ETC_COST_FC total_subproj_etc_cost_fc
                , ppr.SUBPRJ_EARNED_VALUE
                , ppr.CURRENT_FLAG
                , ppr.PROJFUNC_COST_RATE_TYPE
                , ppr.PROJFUNC_COST_EXCHANGE_RATE
                , ppr.PROJFUNC_COST_RATE_DATE
                , ppr.PROJ_COST_RATE_TYPE
                , ppr.PROJ_COST_EXCHANGE_RATE
                , ppr.PROJ_COST_RATE_DATE
                , ppr.TXN_CURRENCY_CODE
                , ppr.PROG_PA_PERIOD_NAME
                , ppr.PROG_GL_PERIOD_NAME
                , pa_progress_utils.Get_BAC_Value(ppev2.project_id, p_wp_rollup_method, ppev2.proj_element_id, ppev2.parent_structure_version_id, 'WORKPLAN') BAC_value
                , pa_progress_utils.Get_BAC_Value(ppev2.project_id, p_wp_rollup_method, ppev2.proj_element_id, ppev2.parent_structure_version_id, 'WORKPLAN','N','N') BAC_value_self -- bug 4493105
                , null earned_value
		, ppr.Oth_quantity_to_date
		, ppr.Oth_etc_quantity
		-- 4533112 : Added base_progress_status_code
		, decode(ppr.base_progress_status_code,'Y','Y','N') base_progress_status_code
       FROM pa_proj_element_versions ppev1,
        pa_proj_element_versions ppev2,
            pa_object_relationships  obj,
            pa_progress_rollup ppr,
            pa_project_statuses pps1,
            pa_project_statuses pps2,
            pa_project_statuses pps3,
        pa_proj_elements ppe -- 4392189
       WHERE obj.object_id_from1 = c_task_ver_id
       AND obj.object_id_from1 = ppev1.element_version_id
       AND obj.object_id_to1 = ppev2.element_version_id
       AND obj.relationship_type = 'S'
       AND ppev1.object_type = 'PA_TASKS'
       AND ppev2.object_type = 'PA_TASKS'
       AND ppev2.proj_element_id = ppe.proj_element_id -- 4392189
       AND ppe.link_task_flag <> 'Y' -- 4392189
       AND ppr.project_id = ppev2.project_id
       AND ppr.object_id = ppev2.proj_element_id
       AND ppr.proj_element_id = ppev2.proj_element_id
       AND ppr.as_of_date = (SELECT max(as_of_date)
                 FROM pa_progress_rollup
                 WHERE project_id = p_project_id
                 AND object_id = ppev2.proj_element_id
                 AND proj_element_id = ppev2.proj_element_id
                 AND object_type = 'PA_TASKS'
                 AND structure_type = 'WORKPLAN'
                 AND structure_version_id is null
                 AND as_of_date <= p_as_of_date
                 )
        AND (ppr.current_flag = 'W'
           OR (ppr.current_flag IN( 'Y', 'N') -- Bug 4336720 : Added Y and N Both
           AND NOT EXISTS (select 1
                           from pa_progress_rollup ppc1
                          where ppc1.project_id = p_project_id
                            and ppc1.object_id = ppev2.proj_element_id
                            and ppc1.proj_element_id = ppev2.proj_element_id
                            and ppc1.object_Type = 'PA_TASKS'
                            and ppc1.structure_type = 'WORKPLAN'
                and ppc1.as_of_date <= p_as_of_date
                            and ppc1.structure_version_id is null
                            and ppc1.current_flag = 'W')))
         AND ppr.EFF_ROLLUP_PROG_STAT_CODE = pps1.project_status_code(+)
         AND ppr.progress_status_code = pps2.project_status_code(+)
         AND ppr.base_progress_status_code = pps3.project_status_code(+)
         AND ppr.structure_type = 'WORKPLAN'
         AND ppr.structure_version_id is null
-- This query returns etc value = planned value when ther is no progress for the immediate sub-tasks.
UNION ALL
       SELECT
        /*+ INDEX(pji_fm_xbs_accum_tmp1 pji_fm_xbs_accum_tmp1_n1)*/ -- Fix for Bug # 4162534.
         obj.object_id_from1 object_id_from1
                , ppev1.object_type parent_object_type
                , ppev1.wbs_level-1 parent_wbs_level
                , ppev2.element_version_id object_id_to1
                , ppev2.object_type object_type
                , ppev2.wbs_level wbs_level
                --, to_number( null ) weighting_percentage --bug 4191181
                , obj.weighting_percentage weighting_percentage
                , to_number(null) rollup_completed_percentage
                , to_number(null) override_percent_complete
                , to_number(null) base_percent_complete
                , to_date(null) actual_start_date
                , to_date(null) actual_finish_date
                , to_date(null) estimated_start_date
                , to_date(null) estimated_finish_date
                , to_number(null) rollup_weight1 ---rollup progress status code
                , to_number(null) override_weight2 ---override progress status code
                , to_number(null) base_weight3     --base prog status
                , (nvl(pfxat.LABOR_HOURS,0) + nvl(pfxat.EQUIPMENT_HOURS,0)) ESTIMATED_REMAINING_EFFORT
                , to_number( null ) task_weight4       --task status
                , to_char(null) status_code
                , ppev2.proj_element_id
                , to_char(null) STRUCTURE_TYPE
                , to_number(null) rollup_proj_element_id
                , to_number(null) PPL_ACT_EFFORT_TO_DATE
                , to_number(null) EQPMT_ACT_EFFORT_TO_DATE
                , to_number(null) total_act_effort_to_date
                , pfxat.equipment_hours EQPMT_ETC_EFFORT
                , (nvl(pfxat.LABOR_HOURS,0) + nvl(pfxat.EQUIPMENT_HOURS,0)) total_etc_effort
                , to_number(null) OTH_ACT_COST_TO_DATE_TC
                , to_number(null) OTH_ACT_COST_TO_DATE_PC
                , to_number(null) OTH_ACT_COST_TO_DATE_FC
                , (nvl(pfxat.txn_brdn_cost,0) - (nvl(pfxat.txn_labor_brdn_cost,0) + nvl(pfxat.txn_equip_brdn_cost,0))) OTH_ETC_COST_TC
                , (nvl(pfxat.prj_brdn_cost,0) - (nvl(pfxat.prj_labor_brdn_cost,0) + nvl(pfxat.prj_equip_brdn_cost,0))) OTH_ETC_COST_PC
                , (nvl(pfxat.pou_brdn_cost,0) - (nvl(pfxat.pou_labor_brdn_cost,0) + nvl(pfxat.pou_equip_brdn_cost,0))) OTH_ETC_COST_FC
                , to_number(null) PPL_ACT_COST_TO_DATE_TC
                , to_number(null) PPL_ACT_COST_TO_DATE_PC
                , to_number(null) PPL_ACT_COST_TO_DATE_FC
                , pfxat.txn_labor_brdn_cost PPL_ETC_COST_TC
                , pfxat.prj_labor_brdn_cost PPL_ETC_COST_PC
                , pfxat.pou_labor_brdn_cost PPL_ETC_COST_FC
                , to_number(null) EQPMT_ACT_COST_TO_DATE_TC
                , to_number(null) EQPMT_ACT_COST_TO_DATE_PC
                , to_number(null) EQPMT_ACT_COST_TO_DATE_FC
                , to_number(null) total_act_cost_to_date_tc
                , to_number(null) total_act_cost_to_date_pc
                , to_number(null) total_act_cost_to_date_fc
                , pfxat.txn_equip_brdn_cost EQPMT_ETC_COST_TC
                , pfxat.prj_equip_brdn_cost EQPMT_ETC_COST_PC
                , pfxat.pou_equip_brdn_cost EQPMT_ETC_COST_FC
                , pfxat.txn_brdn_cost total_etc_cost_tc
                , pfxat.prj_brdn_cost total_etc_cost_pc
                , pfxat.pou_brdn_cost total_etc_cost_fc
                , to_number(null) OTH_ACT_RAWCOST_TO_DATE_TC
                , to_number(null) OTH_ACT_RAWCOST_TO_DATE_PC
                , to_number(null) OTH_ACT_RAWCOST_TO_DATE_FC
                , to_number(null) EQPMT_ACT_RAWCOST_TO_DATE_TC
                , to_number(null) EQPMT_ACT_RAWCOST_TO_DATE_PC
                , to_number(null) EQPMT_ACT_RAWCOST_TO_DATE_FC
                , to_number(null) PPL_ACT_RAWCOST_TO_DATE_TC
                , to_number(null) PPL_ACT_RAWCOST_TO_DATE_PC
                , to_number(null) PPL_ACT_RAWCOST_TO_DATE_FC
                , (nvl(pfxat.txn_raw_cost,0) - (nvl(pfxat.txn_labor_raw_cost,0) + nvl(pfxat.txn_equip_raw_cost,0))) OTH_ETC_RAWCost_TC
                , (nvl(pfxat.prj_raw_cost,0) - (nvl(pfxat.prj_labor_raw_cost,0) + nvl(pfxat.prj_equip_raw_cost,0))) OTH_ETC_RAWCost_PC
                , (nvl(pfxat.pou_raw_cost,0) - (nvl(pfxat.pou_labor_raw_cost,0) + nvl(pfxat.pou_equip_raw_cost,0))) OTH_ETC_RAWCost_FC
                , pfxat.txn_labor_raw_cost PPL_ETC_RAWCOST_TC
                , pfxat.prj_labor_raw_cost PPL_ETC_RAWCOST_PC
                , pfxat.pou_labor_raw_cost PPL_ETC_RAWCOST_FC
                , pfxat.txn_equip_raw_cost EQPMT_ETC_RAWCOST_TC
                , pfxat.prj_equip_raw_cost EQPMT_ETC_RAWCOST_PC
                , pfxat.pou_equip_raw_cost EQPMT_ETC_RAWCOST_FC
                , to_number(null) SUBPRJ_PPL_ACT_EFFORT
                , to_number(null) SUBPRJ_EQPMT_ACT_EFFORT
                , to_number(null) SUBPRJ_PPL_ETC_EFFORT
                , to_number(null) SUBPRJ_EQPMT_ETC_EFFORT
                , to_number(null) SUBPRJ_OTH_ACT_COST_TO_DATE_TC
                , to_number(null) SUBPRJ_OTH_ACT_COST_TO_DATE_FC
                , to_number(null) SUBPRJ_OTH_ACT_COST_TO_DATE_PC
                , to_number(null) SUBPRJ_PPL_ACT_COST_TC
                , to_number(null) SUBPRJ_PPL_ACT_COST_FC
                , to_number(null) SUBPRJ_PPL_ACT_COST_PC
                , to_number(null) SUBPRJ_EQPMT_ACT_COST_TC
                , to_number(null) SUBPRJ_EQPMT_ACT_COST_FC
                , to_number(null) SUBPRJ_EQPMT_ACT_COST_PC
                , to_number(null) total_subproj_act_cost_tc
                , to_number(null) total_subproj_act_cost_pc
                , to_number(null) total_subproj_act_cost_fc
                , to_number(null) SUBPRJ_OTH_ETC_COST_TC
                , to_number(null) SUBPRJ_OTH_ETC_COST_FC
                , to_number(null) SUBPRJ_OTH_ETC_COST_PC
                , to_number(null) SUBPRJ_PPL_ETC_COST_TC
                , to_number(null) SUBPRJ_PPL_ETC_COST_FC
                , to_number(null) SUBPRJ_PPL_ETC_COST_PC
                , to_number(null) SUBPRJ_EQPMT_ETC_COST_TC
                , to_number(null) SUBPRJ_EQPMT_ETC_COST_FC
                , to_number(null) SUBPRJ_EQPMT_ETC_COST_PC
                , to_number(null) total_subproj_etc_cost_tc
                , to_number(null) total_subproj_etc_cost_pc
                , to_number(null) total_subproj_etc_cost_fc
                , to_number(null) SUBPRJ_EARNED_VALUE
                , to_char(null) CURRENT_FLAG
                , to_char(null) PROJFUNC_COST_RATE_TYPE
                , to_number(null) PROJFUNC_COST_EXCHANGE_RATE
                , to_date(null) PROJFUNC_COST_RATE_DATE
                , to_char(null) PROJ_COST_RATE_TYPE
                , to_number(null) PROJ_COST_EXCHANGE_RATE
                , to_date(null) PROJ_COST_RATE_DATE
                , to_char(null) TXN_CURRENCY_CODE
                , to_char(null) PROG_PA_PERIOD_NAME
                , to_char(null) PROG_GL_PERIOD_NAME
                , pa_progress_utils.Get_BAC_Value(ppev2.project_id, p_wp_rollup_method, ppev2.proj_element_id, ppev2.parent_structure_version_id, 'WORKPLAN') BAC_value
                , pa_progress_utils.Get_BAC_Value(ppev2.project_id, p_wp_rollup_method, ppev2.proj_element_id, ppev2.parent_structure_version_id, 'WORKPLAN','N','N') BAC_value_self -- bug 4493105
                , null earned_value
		, to_number(null) Oth_quantity_to_date
		, to_number(null) Oth_etc_quantity
		-- 4533112 : Added base_progress_status_code
		, 'N' base_progress_status_code
       FROM pa_proj_element_versions ppev1,
        pa_proj_element_versions ppev2,
        pa_object_relationships  obj,
        pji_fm_xbs_accum_tmp1 pfxat,
        pa_proj_elements ppe -- 4392189
       WHERE obj.object_id_from1 = c_task_ver_id
       AND obj.object_id_from1 = ppev1.element_version_id
       AND obj.object_id_to1 = ppev2.element_version_id
       AND obj.relationship_type = 'S'
       AND ppev2.proj_element_id = ppe.proj_element_id -- 4392189
       AND ppe.link_task_flag <> 'Y' -- 4392189
       AND ppev1.object_type = 'PA_TASKS'
       AND ppev2.object_type = 'PA_TASKS'
       AND pfxat.project_id(+) = ppev2.project_id
       AND pfxat.struct_version_id(+) = ppev2.parent_structure_version_id
       AND pfxat.project_element_id(+) = ppev2.proj_element_id
       AND pfxat.calendar_type(+) = 'A'
       AND pfxat.plan_version_id(+) > 0
       AND pfxat.txn_currency_code(+) is null
       AND NOT EXISTS (SELECT 1
                 FROM pa_progress_rollup
                 WHERE project_id = p_project_id
                 AND object_id = ppev2.proj_element_id
                 AND proj_element_id = ppev2.proj_element_id
                 AND object_type = 'PA_TASKS'
                 AND structure_type = 'WORKPLAN'
                 AND structure_version_id is null
                 AND as_of_date <= p_as_of_date
            )
-- End fix for Bug # 4032987.
;

   --This cursor selects the task assignments of a given task.
   --sql id:14905993  bug:4871809
   CURSOR cur_assgn( c_task_id NUMBER, c_task_ver_id NUMBER, c_task_per_comp_deriv_method VARCHAR2 )
   IS
     SELECT asgn.task_version_id
        , 'PA_TASKS' parent_object_type
        , asgn.resource_assignment_id object_id_to1
        , asgn.task_version_id object_id_from1
        , 'PA_ASSIGNMENTS' object_type
        , asgn.resource_class_code
        , asgn.rate_based_flag
        , decode(asgn.rate_based_flag,'Y','EFFORT','N','COST') assignment_type
        , ppr.actual_start_date
        , ppr.actual_finish_date
        , ppr.estimated_start_date
        , ppr.estimated_finish_date
        --, ppr.ESTIMATED_REMAINING_EFFORT --bug 3977167
        , nvl(ppr.ESTIMATED_REMAINING_EFFORT,
          decode(asgn.resource_class_code,'PEOPLE',
                            decode(sign(nvl(asgn.planned_quantity,0) - nvl(ppr.PPL_ACT_EFFORT_TO_DATE, 0)), -1, 0,
                            nvl(asgn.planned_quantity,0) - nvl(ppr.PPL_ACT_EFFORT_TO_DATE,0))
          , 0)) ESTIMATED_REMAINING_EFFORT
        , ppr.STRUCTURE_VERSION_ID
        , ppr.STRUCTURE_TYPE
        , ppr.PROJ_ELEMENT_ID
        , ppr.PPL_ACT_EFFORT_TO_DATE
        , ppr.EQPMT_ACT_EFFORT_TO_DATE
        , ppr.PPL_ACT_EFFORT_TO_DATE + ppr.EQPMT_ACT_EFFORT_TO_DATE total_act_effort_to_date
        --, ppr.EQPMT_ETC_EFFORT --bug 3977167
        , nvl(ppr.EQPMT_ETC_EFFORT,
            decode(asgn.resource_class_code,'EQUIPMENT',
                            decode(sign(nvl(asgn.planned_quantity,0) - nvl(ppr.EQPMT_ACT_EFFORT_TO_DATE, 0)), -1, 0,
                            nvl(asgn.planned_quantity,0) - nvl(ppr.EQPMT_ACT_EFFORT_TO_DATE, 0))
           , 0)) EQPMT_ETC_EFFORT
        , ppr.EQPMT_ETC_EFFORT + ppr.estimated_remaining_effort total_etc_effort
        , ppr.OTH_ACT_COST_TO_DATE_TC
        , ppr.OTH_ACT_COST_TO_DATE_PC
        , ppr.OTH_ACT_COST_TO_DATE_FC
        --, ppr.OTH_ETC_COST_TC  --bug 3977167
        --, ppr.OTH_ETC_COST_PC  --bug 3977167
        --, ppr.OTH_ETC_COST_FC  --bug 3977167
        , nvl(ppr.OTH_ETC_COST_TC,
              decode(asgn.resource_class_code,'PEOPLE', 0, 'EQUIPMENT', 0,
                     decode( sign(nvl(asgn.planned_bur_cost_txn_cur,0) - nvl(ppr.OTH_ACT_COST_TO_DATE_TC, 0)), -1, 0,
                         nvl(asgn.planned_bur_cost_txn_cur,0) - nvl(ppr.OTH_ACT_COST_TO_DATE_TC, 0))
          )) OTH_ETC_COST_TC
        ,nvl(ppr.OTH_ETC_COST_PC,
             decode(asgn.resource_class_code,'PEOPLE', 0, 'EQUIPMENT', 0,
                   decode( sign(nvl(asgn.planned_bur_cost_proj_cur,0) - nvl(ppr.OTH_ACT_COST_TO_DATE_PC, 0)), -1, 0,
                   nvl(asgn.planned_bur_cost_proj_cur,0) - nvl(ppr.OTH_ACT_COST_TO_DATE_PC, 0))
          )) OTH_ETC_COST_PC
        , nvl(ppr.OTH_ETC_COST_FC,
            decode(asgn.resource_class_code,'PEOPLE', 0, 'EQUIPMENT', 0,
                decode( sign(nvl(asgn.planned_bur_cost_projfunc,0) - nvl(ppr.OTH_ACT_COST_TO_DATE_FC, 0)), -1, 0,
                nvl(asgn.planned_bur_cost_projfunc,0) - nvl(ppr.OTH_ACT_COST_TO_DATE_FC, 0))
           )) OTH_ETC_COST_FC
        , ppr.PPL_ACT_COST_TO_DATE_TC
        , ppr.PPL_ACT_COST_TO_DATE_PC
        , ppr.PPL_ACT_COST_TO_DATE_FC
        --, ppr.PPL_ETC_COST_TC  --bug 3977167
        --, ppr.PPL_ETC_COST_PC  --bug 3977167
        --, ppr.PPL_ETC_COST_FC  --bug 3977167
        , nvl(ppr.PPL_ETC_COST_TC,
                 decode(asgn.resource_class_code,'PEOPLE',
                           decode(sign(nvl(asgn.planned_bur_cost_txn_cur,0) - nvl(ppr.PPL_ACT_COST_TO_DATE_TC, 0)), -1, 0,
                               nvl(asgn.planned_bur_cost_txn_cur,0) - nvl(ppr.PPL_ACT_COST_TO_DATE_TC, 0))
             ,0)) PPL_ETC_COST_TC
        , nvl(ppr.PPL_ETC_COST_PC,
               decode(asgn.resource_class_code,'PEOPLE',
                            decode(sign(nvl(asgn.planned_bur_cost_proj_cur,0) - nvl(ppr.PPL_ACT_COST_TO_DATE_PC, 0)), -1, 0,
                               nvl(asgn.planned_bur_cost_proj_cur,0) - nvl(ppr.PPL_ACT_COST_TO_DATE_PC, 0))
             ,0)) PPL_ETC_COST_PC
        , nvl(ppr.PPL_ETC_COST_FC,
                  decode(asgn.resource_class_code,'PEOPLE',
                            decode(sign(nvl(asgn.planned_bur_cost_projfunc,0) - nvl(ppr.PPL_ACT_COST_TO_DATE_FC, 0)), -1, 0,
                                   nvl(asgn.planned_bur_cost_projfunc,0) - nvl(ppr.PPL_ACT_COST_TO_DATE_FC, 0))
            ,0)) PPL_ETC_COST_FC
        , ppr.EQPMT_ACT_COST_TO_DATE_TC
        , ppr.EQPMT_ACT_COST_TO_DATE_PC
        , ppr.EQPMT_ACT_COST_TO_DATE_FC
        , ppr.OTH_ACT_COST_TO_DATE_TC + ppr.PPL_ACT_COST_TO_DATE_TC + ppr.EQPMT_ACT_COST_TO_DATE_TC total_act_cost_to_date_tc
        , ppr.OTH_ACT_COST_TO_DATE_PC + ppr.PPL_ACT_COST_TO_DATE_PC + ppr.EQPMT_ACT_COST_TO_DATE_PC total_act_cost_to_date_pc
        , ppr.OTH_ACT_COST_TO_DATE_FC + ppr.PPL_ACT_COST_TO_DATE_FC + ppr.EQPMT_ACT_COST_TO_DATE_FC total_act_cost_to_date_fc
        --, ppr.EQPMT_ETC_COST_TC  --bug 3977167
        --, ppr.EQPMT_ETC_COST_PC  --bug 3977167
        --, ppr.EQPMT_ETC_COST_FC  --bug 3977167
        , nvl(ppr.EQPMT_ETC_COST_TC,
             decode(asgn.resource_class_code,'EQUIPMENT',
                  decode(sign(nvl(asgn.planned_bur_cost_txn_cur,0) - nvl(ppr.EQPMT_ACT_COST_TO_DATE_TC, 0)), -1, 0,
                         nvl(asgn.planned_bur_cost_txn_cur,0) - nvl(ppr.EQPMT_ACT_COST_TO_DATE_TC, 0))
            ,0)) EQPMT_ETC_COST_TC
        , nvl(ppr.EQPMT_ETC_COST_PC,
                decode(asgn.resource_class_code,'EQUIPMENT',
                            decode(sign(nvl(asgn.planned_bur_cost_proj_cur,0) - nvl(ppr.EQPMT_ACT_COST_TO_DATE_PC, 0)), -1, 0,
                                   nvl(asgn.planned_bur_cost_proj_cur,0) - nvl(ppr.EQPMT_ACT_COST_TO_DATE_PC, 0))
             ,0)) EQPMT_ETC_COST_PC
        , nvl(ppr.EQPMT_ETC_COST_FC,
                     decode(asgn.resource_class_code,'EQUIPMENT',
                              decode(sign(nvl(asgn.planned_bur_cost_projfunc,0) - nvl(ppr.EQPMT_ACT_COST_TO_DATE_FC, 0)), -1, 0,
                                   nvl(asgn.planned_bur_cost_projfunc,0) - nvl(ppr.EQPMT_ACT_COST_TO_DATE_FC, 0))
           ,0)) EQPMT_ETC_COST_FC
        , ppr.OTH_ETC_COST_TC + ppr.PPL_ETC_COST_TC + ppr.EQPMT_ETC_COST_TC total_etc_cost_tc
        , ppr.OTH_ETC_COST_PC + ppr.PPL_ETC_COST_PC + ppr.EQPMT_ETC_COST_PC total_etc_cost_pc
        , ppr.OTH_ETC_COST_FC + ppr.PPL_ETC_COST_FC + ppr.EQPMT_ETC_COST_FC total_etc_cost_fc
--Bug 3614828 Begin
        , ppr.OTH_ACT_RAWCOST_TO_DATE_TC
        , ppr.OTH_ACT_RAWCOST_TO_DATE_PC
        , ppr.OTH_ACT_RAWCOST_TO_DATE_FC
        , ppr.EQPMT_ACT_RAWCOST_TO_DATE_TC
        , ppr.EQPMT_ACT_RAWCOST_TO_DATE_PC
        , ppr.EQPMT_ACT_RAWCOST_TO_DATE_FC
        , ppr.PPL_ACT_RAWCOST_TO_DATE_TC
        , ppr.PPL_ACT_RAWCOST_TO_DATE_PC
        , ppr.PPL_ACT_RAWCOST_TO_DATE_FC
        --, ppr.OTH_ETC_RAWCost_TC  --bug 3977167
        --, ppr.OTH_ETC_RAWCost_PC  --bug 3977167
        --, ppr.OTH_ETC_RAWCost_FC  --bug 3977167
        , nvl(ppr.OTH_ETC_RAWCost_TC,
                         decode(asgn.resource_class_code,'PEOPLE', 0, 'EQUIPMENT', 0,
                                 decode( sign(nvl(asgn.planned_raw_cost_txn_cur,0) - nvl(ppr.OTH_ACT_RAWCOST_TO_DATE_TC, 0)), -1, 0,
                                      nvl(asgn.planned_raw_cost_txn_cur,0) - nvl(ppr.OTH_ACT_RAWCOST_TO_DATE_TC, 0))
           )) OTH_ETC_RAWCost_TC
        , nvl(ppr.OTH_ETC_RAWCost_PC,
                      decode(asgn.resource_class_code,'PEOPLE', 0, 'EQUIPMENT', 0,
                               decode(sign(nvl(asgn.planned_raw_cost_proj_cur,0) - nvl(ppr.OTH_ACT_RAWCOST_TO_DATE_PC, 0)), -1, 0,
                                      nvl(asgn.planned_raw_cost_proj_cur,0) - nvl(ppr.OTH_ACT_RAWCOST_TO_DATE_PC, 0))
             )) OTH_ETC_RAWCost_PC
        , nvl(ppr.OTH_ETC_RAWCost_FC,
                         decode(asgn.resource_class_code,'PEOPLE', 0, 'EQUIPMENT', 0,
                                      decode(sign(nvl(asgn.planned_raw_cost_projfunc,0) - nvl(ppr.OTH_ACT_RAWCOST_TO_DATE_FC, 0)), -1, 0,
                                             nvl(asgn.planned_raw_cost_projfunc,0) - nvl(ppr.OTH_ACT_RAWCOST_TO_DATE_FC, 0))
             )) OTH_ETC_RAWCost_FC
        --, ppr.PPL_ETC_RAWCOST_TC  --bug 3977167
        --, ppr.PPL_ETC_RAWCOST_PC  --bug 3977167
        --, ppr.PPL_ETC_RAWCOST_FC  --bug 3977167
        , nvl(ppr.PPL_ETC_RAWCOST_TC,
                     decode(asgn.resource_class_code,'PEOPLE',
                       decode(sign(nvl(asgn.planned_raw_cost_txn_cur,0) - nvl(ppr.PPL_ACT_RAWCOST_TO_DATE_TC, 0)),-1,0,
                               nvl(asgn.planned_raw_cost_txn_cur,0) - nvl(ppr.PPL_ACT_RAWCOST_TO_DATE_TC, 0))
               ,0)) PPL_ETC_RAWCOST_TC
        , nvl(ppr.PPL_ETC_RAWCOST_PC,
                   decode(asgn.resource_class_code,'PEOPLE',
                               decode(sign(nvl(asgn.planned_raw_cost_proj_cur,0) - nvl(ppr.PPL_ACT_RAWCOST_TO_DATE_PC, 0)),-1,0,
                                        nvl(asgn.planned_raw_cost_proj_cur,0) - nvl(ppr.PPL_ACT_RAWCOST_TO_DATE_PC, 0))
            ,0)) PPL_ETC_RAWCOST_PC
        , nvl(ppr.PPL_ETC_RAWCOST_FC,
                  decode(asgn.resource_class_code,'PEOPLE',
                         decode(sign(nvl(asgn.planned_raw_cost_projfunc,0) - nvl(ppr.PPL_ACT_RAWCOST_TO_DATE_FC, 0)),-1,0,
                                 nvl(asgn.planned_raw_cost_projfunc,0) - nvl(ppr.PPL_ACT_RAWCOST_TO_DATE_FC, 0))
           ,0)) PPL_ETC_RAWCOST_FC
        --, ppr.EQPMT_ETC_RAWCOST_TC  --bug 3977167
        --, ppr.EQPMT_ETC_RAWCOST_PC  --bug 3977167
        --, ppr.EQPMT_ETC_RAWCOST_FC  --bug 3977167
        , nvl(ppr.EQPMT_ETC_RAWCOST_TC,
                     decode(asgn.resource_class_code,'EQUIPMENT',
                       decode(sign(nvl(asgn.planned_raw_cost_txn_cur,0) - nvl(ppr.EQPMT_ACT_RAWCOST_TO_DATE_TC, 0)),-1,0,
                               nvl(asgn.planned_raw_cost_txn_cur,0) - nvl(ppr.EQPMT_ACT_RAWCOST_TO_DATE_TC, 0))
               ,0)) EQPMT_ETC_RAWCOST_TC
        , nvl(ppr.EQPMT_ETC_RAWCOST_PC,
                   decode(asgn.resource_class_code,'EQUIPMENT',
                               decode(sign(nvl(asgn.planned_raw_cost_proj_cur,0) - nvl(ppr.EQPMT_ACT_RAWCOST_TO_DATE_PC, 0)),-1,0,
                                        nvl(asgn.planned_raw_cost_proj_cur,0) - nvl(ppr.EQPMT_ACT_RAWCOST_TO_DATE_PC, 0))
            ,0)) EQPMT_ETC_RAWCOST_PC
        , nvl(ppr.EQPMT_ETC_RAWCOST_FC,
                  decode(asgn.resource_class_code,'EQUIPMENT',
                         decode(sign(nvl(asgn.planned_raw_cost_projfunc,0) - nvl(ppr.EQPMT_ACT_RAWCOST_TO_DATE_FC, 0)),-1,0,
                                 nvl(asgn.planned_raw_cost_projfunc,0) - nvl(ppr.EQPMT_ACT_RAWCOST_TO_DATE_FC, 0))
           ,0)) EQPMT_ETC_RAWCOST_FC
--Bug 3614828 End
        , ppr.CURRENT_FLAG
        , ppr.PROJFUNC_COST_RATE_TYPE
        , ppr.PROJFUNC_COST_EXCHANGE_RATE
        , ppr.PROJFUNC_COST_RATE_DATE
        , ppr.PROJ_COST_RATE_TYPE
        , ppr.PROJ_COST_EXCHANGE_RATE
        , ppr.PROJ_COST_RATE_DATE
        , ppr.TXN_CURRENCY_CODE
        , ppr.PROG_PA_PERIOD_NAME
        , ppr.PROG_GL_PERIOD_NAME
        ,decode(c_task_per_comp_deriv_method,'EFFORT', ( nvl(ppr.PPL_ACT_EFFORT_TO_DATE,0) + nvl(ppr.EQPMT_ACT_EFFORT_TO_DATE,0)),
            ( nvl(ppr.OTH_ACT_COST_TO_DATE_PC,0) + nvl(ppr.PPL_ACT_COST_TO_DATE_PC,0) + nvl(ppr.EQPMT_ACT_COST_TO_DATE_PC,0))  ) earned_value
        ,decode(p_wp_rollup_method, 'COST', nvl(ppr.OTH_ACT_COST_TO_DATE_PC,0) + nvl(ppr.PPL_ACT_COST_TO_DATE_PC,0)
                + nvl(ppr.EQPMT_ACT_COST_TO_DATE_PC,0) + nvl(ppr.OTH_ETC_COST_PC,0) + nvl(ppr.PPL_ETC_COST_PC,0)
                + nvl(ppr.EQPMT_ETC_COST_PC,0), 'EFFORT', decode(rate_based_flag,'N', 0, nvl(ppr.PPL_ACT_EFFORT_TO_DATE,0)
                + nvl(ppr.EQPMT_ACT_EFFORT_TO_DATE,0) + nvl(ppr.EQPMT_ETC_EFFORT,0) + nvl(ppr.estimated_remaining_effort,0)), 0) bac_value_in_rollup_method
--bug 3815252
        ,decode(c_task_per_comp_deriv_method,'EFFORT', ( NVL( decode( asgn.rate_based_flag, 'Y',
                                        decode( asgn.resource_class_code,
                                            'PEOPLE', nvl(ppr.PPL_ACT_EFFORT_TO_DATE,0) + nvl(ppr.estimated_remaining_effort,
                                              decode( sign(nvl(asgn.planned_quantity,0)-nvl(ppr.PPL_ACT_EFFORT_TO_DATE,0)), -1, 0,
                                                 nvl(asgn.planned_quantity,0)-nvl(ppr.PPL_ACT_EFFORT_TO_DATE,0))),
                                            'EQUIPMENT', nvl(ppr.EQPMT_ACT_EFFORT_TO_DATE,0) + nvl(ppr.EQPMT_ETC_EFFORT,
                                              decode( sign(nvl(asgn.planned_quantity,0)-nvl(ppr.EQPMT_ACT_EFFORT_TO_DATE,0)), -1, 0,
                                                 nvl(asgn.planned_quantity,0)-nvl(ppr.EQPMT_ACT_EFFORT_TO_DATE,0)))),0),0) -- Bug 4213130 nvl(asgn.planned_quantity,0))
                                   ),
                                 ( NVL( decode( asgn.resource_class_code,
                                       'FINANCIAL_ELEMENTS',
                                         nvl(ppr.OTH_ACT_COST_TO_DATE_PC,0) + nvl(ppr.OTH_ETC_COST_PC,
                                            decode( sign(nvl(asgn.planned_bur_cost_proj_cur,0)-nvl(ppr.OTH_ACT_COST_TO_DATE_PC,0)), -1, 0,
                                                 nvl(asgn.planned_bur_cost_proj_cur,0)-nvl(ppr.OTH_ACT_COST_TO_DATE_PC,0))),
                                       'MATERIAL_ITEMS',
                                         nvl(ppr.OTH_ACT_COST_TO_DATE_PC,0) + nvl(ppr.OTH_ETC_COST_PC,
                                            decode( sign(nvl(asgn.planned_bur_cost_proj_cur,0)-nvl(ppr.OTH_ACT_COST_TO_DATE_PC,0)), -1, 0,
                                                 nvl(asgn.planned_bur_cost_proj_cur,0)-nvl(ppr.OTH_ACT_COST_TO_DATE_PC,0))),
                                       'PEOPLE',
                                        nvl(ppr.PPL_ACT_COST_TO_DATE_PC,0) + nvl(ppr.PPL_ETC_COST_PC,
                                         decode( sign(nvl(asgn.planned_bur_cost_proj_cur,0)-nvl(ppr.PPL_ACT_COST_TO_DATE_PC,0)), -1, 0,
                                                       nvl(asgn.planned_bur_cost_proj_cur,0)-nvl(ppr.PPL_ACT_COST_TO_DATE_PC,0))),
                                       'EQUIPMENT',
                                        nvl(ppr.EQPMT_ACT_COST_TO_DATE_PC,0) + nvl(ppr.EQPMT_ETC_COST_PC,
                                         decode( sign(nvl(asgn.planned_bur_cost_proj_cur,0)-nvl(ppr.EQPMT_ACT_COST_TO_DATE_PC,0)), -1, 0,
                                                       nvl(asgn.planned_bur_cost_proj_cur,0)-nvl(ppr.EQPMT_ACT_COST_TO_DATE_PC,0)))),
                                    nvl(asgn.planned_bur_cost_proj_cur,0)
                                    ))
                                       ) bac_value_in_task_deriv
        , ppr.Oth_quantity_to_date
        , ppr.Oth_etc_quantity
    FROM
               pa_task_asgmts_v  asgn,
               pa_progress_rollup ppr
     WHERE asgn.task_version_id = c_task_ver_id
       AND asgn.task_id = c_task_id
       AND asgn.project_id = p_project_id
       AND asgn.project_id = ppr.project_id(+)
       AND asgn.RESOURCE_LIST_MEMBER_ID = ppr.object_id(+) -- Bug 3764224
       AND asgn.task_id = ppr.proj_element_id(+) -- Bug 3764224
       AND ppr.object_type(+) = 'PA_ASSIGNMENTS'
       -- Bug 3879461 : After discussion with Sameer Realeraskar, Majid
       -- It is to select only the rollup record till passed as of date
       AND ppr.structure_type(+) = 'WORKPLAN'
       AND ppr.structure_version_id(+) is null
       AND ppr.as_of_date(+) <= p_as_of_date
       AND nvl(ppr.progress_rollup_id,-99) = pa_progress_utils.get_w_pub_prupid_asofdate(p_project_id,asgn.RESOURCE_LIST_MEMBER_ID,'PA_ASSIGNMENTS',asgn.task_id,p_as_of_date);

     /* (SELECT nvl(max(progress_rollup_id),-99)
                 FROM pa_progress_rollup
                 WHERE project_id = p_project_id
                 AND object_id = asgn.RESOURCE_LIST_MEMBER_ID
                 AND proj_element_id = asgn.task_id
                 AND object_type = 'PA_ASSIGNMENTS'
                 AND structure_type = 'WORKPLAN'
                 AND structure_version_id is null
                 AND as_of_date <= p_as_of_date
                 AND (ppr.current_flag = 'W'
                 --OR (ppr.current_flag ='Y' --bug 4183176
                 OR (ppr.current_flag IN ('Y', 'N')
                     AND NOT EXISTS (select 1
                           from pa_progress_rollup ppc1
                          where ppc1.project_id = p_project_id
                            and ppc1.object_id = asgn.RESOURCE_LIST_MEMBER_ID
                            and ppc1.proj_element_id = asgn.task_id
                            and ppc1.object_Type = 'PA_ASSIGNMENTS'
                            and ppc1.structure_type = 'WORKPLAN'
                            and ppc1.as_of_date <= p_as_of_date
                            and ppc1.structure_version_id is null
                            and ppc1.current_flag = 'W'))))
--       AND ppr.as_of_date = pa_progress_utils.get_max_rollup_asofdate2(asgn.project_id,
--                               asgn.RESOURCE_LIST_MEMBER_ID, 'PA_ASSIGNMENTS','WORKPLAN', null, asgn.task_id)  ---Bug 3764224
       --bug 3958686, hidden assignments should not to be selected
--       AND asgn.ta_display_flag = 'Y' --   Bug 4323537
        ; */


   --sql id: 14906033  bug: 4871809
   --This cursor selects the deliverables of a given task.
   CURSOR cur_deliverables(c_task_proj_elem_id NUMBER, c_task_ver_id NUMBER, c_project_id NUMBER)
   IS
     SELECT obj.object_type_from
     , 'PA_TASKS' parent_object_type
     ,  obj.object_id_to2 object_id
     ,  obj.object_id_to1
     ,  obj.object_id_from1
     , 'PA_DELIVERABLES' object_type
     , ppr.actual_finish_date
     , ppr.completed_percentage
     , ppr.STRUCTURE_TYPE
     , ppr.PROJ_ELEMENT_ID
     , ppr.STRUCTURE_VERSION_ID
     , ppr.TASK_WT_BASIS_CODE
     , elem.progress_weight weighting_percentage
     , ppr.base_percent_complete
     , pps2.project_status_weight override_weight ---override progress status code
     , pps3.project_status_weight base_weight     --base prog status
    FROM pa_proj_elements elem
    , pa_object_relationships obj
    , pa_progress_rollup ppr
    , pa_project_statuses pps2
    , pa_project_statuses pps3
     WHERE  obj.object_id_from2= c_task_proj_elem_id
     ---AND obj.object_id_from1 = c_task_ver_id ---to get delv for specific task ver  , object_id_from1 is not populated in this case
     AND obj.object_type_from = 'PA_TASKS'
     AND obj.object_type_to = 'PA_DELIVERABLES'
     AND obj.relationship_type = 'A'
     AND obj.relationship_subtype = 'TASK_TO_DELIVERABLE'
     AND elem.proj_element_id = obj.object_id_to2
     AND elem.object_type = 'PA_DELIVERABLES'
     and elem.project_id = c_project_id
     AND ppr.project_id(+) = c_project_id
     AND ppr.object_id(+) = obj.object_id_to2
     AND ppr.object_type(+) = 'PA_DELIVERABLES'
     AND ppr.as_of_date(+) <= p_as_of_date
       -- Bug 3879461 : After discussion with Sameer Realeraskar, Majid
       -- It is to select only the rollup record till passed as of date
     AND nvl(ppr.progress_rollup_id,-99) = pa_progress_utils.get_w_pub_prupid_asofdate(c_project_id,obj.object_id_to2,'PA_DELIVERABLES',obj.object_id_from2,p_as_of_date)
     AND ppr.base_progress_status_code = pps3.project_status_code(+)
     AND ppr.progress_status_code = pps2.project_status_code(+);

    /* (SELECT nvl(max(progress_rollup_id),-99)
                 FROM pa_progress_rollup
                 WHERE project_id = p_project_id
                 AND object_id = obj.object_id_to2
                 --bug 4250623, do not check for proj_element_id as deliverable may not be associated with task
                 --AND proj_element_id = obj.object_id_from2
                 AND object_type = 'PA_DELIVERABLES'
                 AND structure_type = 'WORKPLAN'
                 AND structure_version_id is null
                 AND as_of_date <= p_as_of_date
    --bug 4182870, added for selecting only one record
                 AND (ppr.current_flag = 'W'
                      OR (ppr.current_flag IN ('Y', 'N')
                      AND NOT EXISTS (select 1
                           from pa_progress_rollup ppc1
                          where ppc1.project_id = p_project_id
                            and ppc1.object_id = obj.object_id_to2
                --bug 4250623, do not check for proj_element_id as deliverable may not be associated with task
                            --and ppc1.proj_element_id = obj.object_id_from2
                            and ppc1.object_Type = 'PA_DELIVERABLES'
                            and ppc1.structure_type = 'WORKPLAN'
                            and ppc1.as_of_date <= p_as_of_date
                            and ppc1.structure_version_id is null
                            and ppc1.current_flag = 'W'))))
--     AND ppr.as_of_date(+) = pa_progress_utils.get_max_rollup_asofdate2(c_project_id,
--                               obj.object_id_to2, 'PA_DELIVERABLES','WORKPLAN', null, obj.object_id_from2 ) -- bug 3764224 Bug 3808044 : Changed to2 to from2
     AND ppr.structure_type(+) = 'WORKPLAN'
     AND ppr.structure_version_id(+) is null
--     AND ppr.current_flag(+) = 'W'     --bug 3879461
     AND ppr.base_progress_status_code = pps3.project_status_code(+)
     AND ppr.progress_status_code = pps2.project_status_code(+)
     ; */

   CURSOR cur_base_p_comp_deriv_code(c_task_proj_elem_id NUMBER, c_project_id NUMBER)
   IS
   SELECT elem.status_code, stat.project_system_status_code, decode(elem.base_percent_comp_deriv_code, null, ttype.base_percent_comp_deriv_code,'^',ttype.base_percent_comp_deriv_code,elem.base_percent_comp_deriv_code), ttype.prog_entry_enable_flag
   FROM pa_proj_elements elem
   , pa_task_types ttype
   , pa_project_statuses stat
   where elem.proj_element_id = c_task_proj_elem_id
   AND elem.project_id = c_project_id
   AND elem.object_type ='PA_TASKS'
   AND elem.type_id = ttype.task_type_id
   AND elem.status_code = stat.project_status_code(+);

   CURSOR cur_status( c_status_weight VARCHAR2 )
   IS
     select lookup_code
       from fnd_lookup_values
      where attribute4 = c_status_weight
        and lookup_type = 'PROGRESS_SYSTEM_STATUS'
        and language = 'US'
	AND VIEW_APPLICATION_ID = 275 ; -- Bug ref # 6507900;

   CURSOR cur_task_status( c_status_weight VARCHAR2 )
   IS
     select project_status_code
       from pa_project_statuses
      where project_status_weight = c_status_weight
        and status_type = 'TASK'
        and predefined_flag = 'Y';

   CURSOR cur_rollup( c_progress_rollup_id NUMBER )
   IS
     SELECT * from pa_progress_rollup
       WHERE progress_rollup_id = c_progress_rollup_id;

   CURSOR cur_pa_rollup1( c_proj_element_id NUMBER )
   IS
     SELECT *
       FROM pa_progress_rollup
      WHERE project_id = p_project_id
        AND object_id = c_proj_element_id
        AND structure_type = 'WORKPLAN'
         AND structure_version_id is null
        AND as_of_date = ( SELECT max( as_of_date )
                             FROM pa_progress_rollup
                            WHERE project_id = p_project_id
                              AND object_id = c_proj_element_id
                              AND structure_type = 'WORKPLAN'
                              AND structure_version_id is null
                              AND as_of_date <= p_as_of_date );



        l_eff_rollup_status_code        VARCHAR2(150)                                   ;
        l_cur_rollup_rec                cur_rollup%ROWTYPE                              ;
        l_pev_schedule_id               NUMBER                                          ;
        l_sch_rec_ver_number            NUMBER                                          ;
        l_total_tasks                   NUMBER                                          ;
        l_PROGRESS_ROLLUP_ID            NUMBER                                          ;
        l_progress_exists_on_aod        VARCHAR2(15)                                    ;
        l_percent_complete_id           NUMBER                                          ;
        l_rollup_rec_ver_number         NUMBER                                          ;
        l_progress_status_code          VARCHAR2(150)                                   ;
        l_rolled_up_base_per_comp       NUMBER                                          ;
        l_rolled_up_base_prog_stat      VARCHAR2(150)                                   ;
        l_rolled_up_per_comp            NUMBER                                          ;
        l_rolled_up_prog_stat           VARCHAR2(150)                                   ;
        l_cur_pa_rollup1_rec            cur_pa_rollup1%ROWTYPE                          ;
        l_status_code                   VARCHAR2(150)                                   ;
        l_working_aod                   DATE                                            ;
        l_PROGRESS_ROLLUP_ID2           NUMBER                                          ;
        l_rollup_rec_ver_number2        NUMBER                                          ;
        l_cur_rollup_rec2               cur_rollup%ROWTYPE                              ;
        l_remaining_effort1             NUMBER                                          ;
        l_percent_complete1             NUMBER                                          ;
        l_percent_complete2             NUMBER                                          ;
        l_ETC_Cost_PC                   NUMBER                                          ;
        l_PPL_ETC_COST_PC               NUMBER                                          ;
        l_EQPMT_ETC_COST_PC             NUMBER                                          ;
        l_ETC_Cost_FC                   NUMBER                                          ;
        l_PPL_ETC_COST_FC               NUMBER                                          ;
        l_EQPMT_ETC_COST_FC             NUMBER                                          ;
        l_EQPMT_ETC_EFFORT              NUMBER                                          ;
        l_SUB_PRJ_ETC_COST_PC           NUMBER                                          ;
        l_SUB_PRJ_PPL_ETC_COST_PC       NUMBER                                          ;
        l_SUB_PRJ_EQPMT_ETC_COST_PC     NUMBER                                          ;
        l_SUB_PRJ_ETC_COST_FC           NUMBER                                          ;
        l_SUB_PRJ_PPL_ETC_COST_FC       NUMBER                                          ;
        l_SUB_PRJ_EQPMT_ETC_COST_FC     NUMBER                                          ;
        l_SUB_PRJ_PPL_ETC_EFFORT        NUMBER                                          ;
        l_SUB_PRJ_EQPMT_ETC_EFFORT      NUMBER                                          ;
        l_BAC_VALUE1                    NUMBER                                          ;
        l_EARNED_VALUE1                 NUMBER                                          ;
        l_bcwp                          NUMBER                                          ;
        l_OTH_ACT_COST_TO_DATE_PC       NUMBER                                          ;
        l_PPL_ACT_COST_TO_DATE_PC       NUMBER                                          ;
        l_EQPMT_ACT_COST_TO_DATE_PC     NUMBER                                          ;
        l_OTH_ACT_COST_TO_DATE_FC       NUMBER                                          ;
        l_PPL_ACT_COST_TO_DATE_FC       NUMBER                                          ;
        l_EQPMT_ACT_COST_TO_DATE_FC     NUMBER                                          ;
        l_PPL_ACT_EFFORT_TO_DATE        NUMBER                                          ;
        l_EQPMT_ACT_EFFORT_TO_DATE      NUMBER                                          ;
        l_PERIOD_NAME                   VARCHAR2(10)                                    ;
        l_project_ids                   SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type()      ;
        l_struture_version_ids          SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type()      ;
        l_proj_thru_dates_tbl           SYSTEM.pa_date_tbl_type:= SYSTEM.pa_date_tbl_type()     ;
        l_prog_pa_period_name           VARCHAR2(30)                                    ;
        l_prog_gl_period_name           VARCHAR2(30)                                    ;
        l_current_flag                  VARCHAR2(1):= 'W'               ;
        l_max_rollup_as_of_date2        DATE                                            ;
        l_structure_sharing_code        pa_projects_all.structure_sharing_code%TYPE     ;
        l_OTH_ACT_RAWCOST_TO_DATE_PC    NUMBER                                          ;
        l_PPL_ACT_RAWCOST_TO_DATE_PC    NUMBER                                          ;
        l_EQPMT_ACT_RAWCOST_TO_DATE_PC  NUMBER                                          ;
        l_OTH_ACT_RAWCOST_TO_DATE_FC    NUMBER                                          ;
        l_PPL_ACT_RAWCOST_TO_DATE_FC    NUMBER                                          ;
        l_EQPMT_ACT_RAWCOST_TO_DATE_FC  NUMBER                                          ;
        l_ETC_RAWCost_PC                NUMBER                                          ;
        l_PPL_ETC_RAWCOST_PC            NUMBER                                          ;
        l_EQPMT_ETC_RAWCOST_PC          NUMBER                                          ;
        l_ETC_RAWCost_FC                NUMBER                                          ;
        l_PPL_ETC_RAWCOST_FC            NUMBER                                          ;
        l_EQPMT_ETC_RAWCOST_FC          NUMBER                                          ;
        l_EQUIPMENT_HOURS               NUMBER                                          ;
        l_POU_LABOR_BRDN_COST           NUMBER                                          ;
        l_PRJ_LABOR_BRDN_COST           NUMBER                                          ;
        l_POU_EQUIP_BRDN_COST           NUMBER                                          ;
        l_PRJ_EQUIP_BRDN_COST           NUMBER                                          ;
        l_POU_LABOR_RAW_COST            NUMBER                                          ;
        l_PRJ_LABOR_RAW_COST            NUMBER                                          ;
        l_POU_EQUIP_RAW_COST            NUMBER                                          ;
        l_PRJ_EQUIP_RAW_COST            NUMBER                                          ;
        L_TASK_STATUS_CODE              pa_project_statuses.project_status_code%TYPE    ;
        l_task_system_status_code       pa_project_statuses.project_system_status_code%TYPE;
        L_TASK_WEIGHTING_PERCENTAGE     NUMBER                                          ;
        L_PROG_ENTRY_ENABLE_FLAG        VARCHAR2(1)                                     ;
        l_BASE_PERCENT_COMP_DERIV_CODE  VARCHAR2(30)                                    ;
        -- Bug 5675437
        l_PROGRESS_ROLLUP_ID3           NUMBER                                          ;
        l_cur_rollup_rec3               cur_rollup%ROWTYPE                              ;
        l_rollup_rec_ver_number3        NUMBER                                          ;

-- Bug 3879461 Begin
CURSOR c_get_object_status (l_project_id NUMBER, l_proj_element_id NUMBER)
IS
SELECT STATUS_CODE
FROM PA_PROJ_ELEMENTS
WHERE PROJ_ELEMENT_ID=l_proj_element_id
AND PROJECT_ID = l_project_id;

L_EXISTING_OBJECT_STATUS        pa_project_statuses.project_status_code%TYPE    ;
l_Oth_quantity_to_date NUMBER;
l_Oth_etc_quantity NUMBER;

-- Bug 3879461 End

l_prj_currency_code VARCHAR2(15); --bug 3949093

-- Bug 3956299 Begin
CURSOR c_get_dates (c_project_id NUMBER, c_element_version_id NUMBER)
IS
SELECT scheduled_start_date, scheduled_finish_date
FROM pa_proj_elem_ver_schedule
WHERE PROJECT_ID = c_project_id
AND element_version_id = c_element_version_id;

l_tsk_scheduled_start_date Date;
l_tsk_scheduled_finish_date Date;
l_actual_start_date Date;
l_actual_finish_date Date;
l_estimated_start_date Date;
l_estimated_finish_date Date;
-- Bug 3956299 End

-- Bug 3922325 Begin
CURSOR c_get_dlv_status IS
SELECT 'Y' FROM DUAL
WHERE EXISTS
(SELECT 'xyz'
FROM pa_percent_completes
WHERE project_id = p_project_id
AND task_id = p_task_id
AND object_type = 'PA_DELIVERABLES'
AND trunc(date_computed)<= trunc(p_as_of_date)
AND structure_type = 'WORKPLAN'
AND PA_PROGRESS_UTILS.get_system_task_status( status_code, 'PA_DELIVERABLES') = 'DLVR_IN_PROGRESS'
);

l_actual_exists VARCHAR2(1):='N';
-- Bug 3922325 End

-- Bug 4392189 Begin
CURSOR c_get_sub_project (c_task_version_id NUMBER, c_task_per_comp_deriv_method VARCHAR2) IS
SELECT
  ppv2.project_id                     sub_project_id
 ,ppv2.element_version_id             sub_structure_ver_id
 ,ppv2.proj_element_id                sub_proj_element_id
, pa_progress_utils.Get_BAC_Value(ppv2.project_id, c_task_per_comp_deriv_method,  ppv2.proj_element_id,  ppv2.parent_structure_version_id,
                                    'WORKPLAN','N')    sub_project_bac_value
FROM
     pa_proj_element_versions ppv2
    ,pa_proj_elem_ver_structure ppevs2
    ,pa_object_relationships por1
    ,pa_object_relationships por2
WHERE
  por1.object_id_from1 = c_task_version_id
 AND por1.object_id_to1 = por2.object_id_from1
 AND por2.object_id_to1 = ppv2.element_version_id
 AND ppv2.object_type = 'PA_STRUCTURES'
-- AND por2.relationship_type in ( 'LW', 'LF' )
 AND por2.relationship_type = 'LW'
 AND ppevs2.element_version_id = ppv2.element_version_id
 AND ppevs2.project_id = ppv2.project_id
 AND ppevs2.status_code = 'STRUCTURE_PUBLISHED'
 AND ppevs2.latest_eff_published_flag = 'Y';

l_sub_project_id    NUMBER;
l_sub_structure_ver_id  NUMBER;
l_sub_proj_element_id   NUMBER;
l_sub_project_bac_value NUMBER;

--- sql id: 14906260  bug 4871809
CURSOR c_get_sub_project_progress (c_sub_project_id NUMBER, c_sub_str_version_id NUMBER, c_sub_proj_element_id NUMBER
, c_as_of_date Date, c_task_per_comp_deriv_method VARCHAR2) IS
SELECT /*+ index(pfxat pji_fm_xbs_accum_tmp1_n1) */
ppr.progress_rollup_id
, ppr.as_of_date
, ppr.actual_start_date
, ppr.actual_finish_date
, ppr.estimated_start_date
, ppr.estimated_finish_date
, ppr.PPL_ACT_EFFORT_TO_DATE
, ppr.PPL_ACT_COST_TO_DATE_TC
, ppr.PPL_ACT_COST_TO_DATE_PC
, ppr.PPL_ACT_COST_TO_DATE_FC
, ppr.PPL_ACT_RAWCOST_TO_DATE_TC
, ppr.PPL_ACT_RAWCOST_TO_DATE_PC
, ppr.PPL_ACT_RAWCOST_TO_DATE_FC
, ppr.EQPMT_ACT_EFFORT_TO_DATE
, ppr.EQPMT_ACT_COST_TO_DATE_TC
, ppr.EQPMT_ACT_COST_TO_DATE_PC
, ppr.EQPMT_ACT_COST_TO_DATE_FC
, ppr.EQPMT_ACT_RAWCOST_TO_DATE_TC
, ppr.EQPMT_ACT_RAWCOST_TO_DATE_PC
, ppr.EQPMT_ACT_RAWCOST_TO_DATE_FC
, ppr.OTH_QUANTITY_TO_DATE
, ppr.OTH_ACT_COST_TO_DATE_TC
, ppr.OTH_ACT_COST_TO_DATE_PC
, ppr.OTH_ACT_COST_TO_DATE_FC
, ppr.OTH_ACT_RAWCOST_TO_DATE_TC
, ppr.OTH_ACT_RAWCOST_TO_DATE_PC
, ppr.OTH_ACT_RAWCOST_TO_DATE_FC
, decode(ppr.progress_rollup_id,null,pfxat.ETC_LABOR_HRS,ppr.ESTIMATED_REMAINING_EFFORT) ESTIMATED_REMAINING_EFFORT
, ppr.PPL_ETC_COST_TC
, decode(ppr.progress_rollup_id,null,pfxat.ETC_PRJ_LABOR_BRDN_COST,ppr.PPL_ETC_COST_PC) PPL_ETC_COST_PC
, decode(ppr.progress_rollup_id,null,pfxat.ETC_POU_LABOR_BRDN_COST,ppr.PPL_ETC_COST_FC) PPL_ETC_COST_FC
, ppr.PPL_ETC_RAWCOST_TC
, decode(ppr.progress_rollup_id,null,pfxat.ETC_PRJ_LABOR_RAW_COST,ppr.PPL_ETC_RAWCOST_PC) PPL_ETC_RAWCOST_PC
, decode(ppr.progress_rollup_id,null,pfxat.ETC_POU_LABOR_RAW_COST,ppr.PPL_ETC_RAWCOST_FC) PPL_ETC_RAWCOST_FC
, decode(ppr.progress_rollup_id,null,pfxat.ETC_EQUIP_HRS,ppr.EQPMT_ETC_EFFORT) EQPMT_ETC_EFFORT
, ppr.EQPMT_ETC_COST_TC
, decode(ppr.progress_rollup_id,null,pfxat.ETC_PRJ_EQUIP_BRDN_COST,ppr.EQPMT_ETC_COST_PC) EQPMT_ETC_COST_PC
, decode(ppr.progress_rollup_id,null,pfxat.ETC_POU_EQUIP_BRDN_COST,ppr.EQPMT_ETC_COST_FC) EQPMT_ETC_COST_FC
, ppr.EQPMT_ETC_RAWCOST_TC
, decode(ppr.progress_rollup_id,null,pfxat.ETC_PRJ_EQUIP_RAW_COST,ppr.EQPMT_ETC_RAWCOST_PC) EQPMT_ETC_RAWCOST_PC
, decode(ppr.progress_rollup_id,null,pfxat.ETC_POU_EQUIP_RAW_COST,ppr.EQPMT_ETC_RAWCOST_FC) EQPMT_ETC_RAWCOST_FC
, ppr.OTH_ETC_QUANTITY
, ppr.OTH_ETC_COST_TC
, decode(ppr.progress_rollup_id,null,(pfxat.ETC_PRJ_BRDN_COST-nvl(pfxat.ETC_PRJ_EQUIP_BRDN_COST,0)-nvl(pfxat.ETC_PRJ_LABOR_BRDN_COST,0)),ppr.OTH_ETC_COST_PC) OTH_ETC_COST_PC
, decode(ppr.progress_rollup_id,null,(pfxat.ETC_POU_BRDN_COST-nvl(pfxat.ETC_POU_EQUIP_BRDN_COST,0)-nvl(pfxat.ETC_POU_LABOR_BRDN_COST,0)),ppr.OTH_ETC_COST_FC) OTH_ETC_COST_FC
, ppr.OTH_ETC_RAWCost_TC
, decode(ppr.progress_rollup_id,null,(pfxat.ETC_PRJ_RAW_COST-nvl(pfxat.ETC_PRJ_EQUIP_RAW_COST,0)-nvl(pfxat.ETC_PRJ_LABOR_RAW_COST,0)),ppr.OTH_ETC_RAWCost_PC) OTH_ETC_RAWCost_PC
, decode(ppr.progress_rollup_id,null,(pfxat.ETC_POU_RAW_COST-nvl(pfxat.ETC_POU_EQUIP_RAW_COST,0)-nvl(pfxat.ETC_POU_LABOR_RAW_COST,0)),ppr.OTH_ETC_RAWCost_FC) OTH_ETC_RAWCost_FC
, pps1.project_status_weight rollup_weight1
, pps2.project_status_weight override_weight2
, pps3.project_status_weight base_weight3
, pps4.project_status_weight task_weight4
-- Bug 4506009, decode(c_task_per_comp_deriv_method,'EFFORT', ( nvl(ppr.PPL_ACT_EFFORT_TO_DATE,0) + nvl(ppr.EQPMT_ACT_EFFORT_TO_DATE,0)),
--                                    ( nvl(ppr.OTH_ACT_COST_TO_DATE_PC,0) + nvl(ppr.PPL_ACT_COST_TO_DATE_PC,0) + nvl(ppr.EQPMT_ACT_COST_TO_DATE_PC,0))) earned_value
, decode(c_task_per_comp_deriv_method,'EFFORT', decode(nvl(ppr.PPL_ACT_EFFORT_TO_DATE,0) + nvl(ppr.estimated_remaining_effort,0) + nvl(ppr.EQPMT_ACT_EFFORT_TO_DATE,0) +  nvl(ppr.EQPMT_ETC_EFFORT,0),0,
     nvl(pfxat.ETC_LABOR_HRS,0) + nvl(pfxat.ETC_EQUIP_HRS,0),nvl(ppr.PPL_ACT_EFFORT_TO_DATE,0) + nvl(ppr.estimated_remaining_effort,0) + nvl(ppr.EQPMT_ACT_EFFORT_TO_DATE,0) +  nvl(ppr.EQPMT_ETC_EFFORT,0))
        , decode(nvl(ppr.OTH_ACT_COST_TO_DATE_PC,0) + nvl(ppr.OTH_ETC_COST_PC,0) +  nvl(ppr.PPL_ACT_COST_TO_DATE_PC,0) + nvl(ppr.PPL_ETC_COST_PC,0) +  nvl(ppr.EQPMT_ACT_COST_TO_DATE_PC,0) + nvl(ppr.EQPMT_ETC_COST_PC,0),0,
        nvl(pfxat.ETC_PRJ_BRDN_COST,0), nvl(ppr.OTH_ACT_COST_TO_DATE_PC,0) + nvl(ppr.OTH_ETC_COST_PC,0) +  nvl(ppr.PPL_ACT_COST_TO_DATE_PC,0) + nvl(ppr.PPL_ETC_COST_PC,0) +  nvl(ppr.EQPMT_ACT_COST_TO_DATE_PC,0) + nvl(ppr.EQPMT_ETC_COST_PC,0))) bac_value
, nvl(ppr.completed_percentage, ppr.eff_rollup_percent_comp) completed_percentage -- Bug 4506009
FROM
pa_progress_rollup ppr
,pa_project_statuses pps1
,pa_project_statuses pps2
,pa_project_statuses pps3
,pa_project_statuses pps4
,pa_proj_elements ppe
,pji_fm_xbs_accum_tmp1 pfxat
WHERE
ppr.project_id = c_sub_project_id
AND ppe.project_id = c_sub_project_id
AND ppe.object_type = 'PA_STRUCTURES'
AND ppe.proj_element_id = c_sub_proj_element_id
AND ppr.object_id(+) = c_sub_proj_element_id
AND ppr.object_type(+) = 'PA_STRUCTURES'
AND ppr.structure_version_id(+) is null
AND ppr.structure_type(+) = 'WORKPLAN'
AND ppr.current_flag(+) <> 'W'  ---IN ('Y', 'N')
AND ppr.as_of_date(+) <= c_as_of_date
AND ppr.EFF_ROLLUP_PROG_STAT_CODE = pps1.project_status_code(+)
AND ppr.progress_status_code =  pps2.project_status_code(+)
AND ppr.base_progress_status_code = pps3.project_status_code(+)
AND ppe.status_code = pps4.project_status_code(+)
AND pfxat.project_id = ppe.project_id
AND pfxat.struct_version_id = c_sub_str_version_id
AND pfxat.project_element_id = ppe.proj_element_id
AND pfxat.plan_version_id > 0
AND pfxat.txn_currency_code is null
AND pfxat.calendar_type = 'A'
AND pfxat.res_list_member_id is null
order by as_of_date desc
 ;

l_sub_rec           c_get_sub_project_progress%ROWTYPE;
l_subproj_prog_rollup_id    NUMBER;
l_subproj_act_start_date    DATE;
l_subproj_act_finish_date   DATE;
l_subproj_est_start_date    DATE;
l_subproj_est_finish_date   DATE;
l_subproj_rollup_weight1    NUMBER;
l_subproj_override_weight2  NUMBER;
l_subproj_base_weight3      NUMBER;
l_subproj_task_weight4      NUMBER;
l_subproj_earned_value      NUMBER;
l_subproj_bac_value     NUMBER;
l_actual_lowest_task        VARCHAR2(1) := 'N';
-- Bug 4392189 End

-- Bug 4506461 Begin
CURSOR c_get_any_childs_have_subprj(c_task_version_id NUMBER) IS
SELECT 'Y'
FROM pa_object_relationships
WHERE --relationship_type in ( 'LW', 'LF' )
relationship_type = 'LW'
AND object_id_from1 IN
    (SELECT object_id_to1
    FROM pa_object_relationships
    START WITH  object_id_from1 = c_task_version_id
    AND relationship_type = 'S'
    CONNECT BY PRIOR object_id_to1 = object_id_from1
    AND relationship_type = 'S')
    ;
l_subproject_found VARCHAR2(1):='N';
l_rederive_base_pc VARCHAR2(1):='N';
l_override_pc_temp NUMBER;
l_base_pc_temp     NUMBER;
-- Bug 4506461 End

l_subproj_task_version_id NUMBER;--4582956

BEGIN

        g1_debug_mode := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',fnd_global.user_id,fnd_global.login_id,275,null,null), 'N');

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.init_err_stack ('PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT');
        END IF;

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT Start : Passed Parameters :', x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'p_init_msg_list='||p_init_msg_list, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'p_commit='||p_commit, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'p_validate_only='||p_validate_only, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'p_validation_level='||p_validation_level, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'p_calling_module='||p_calling_module, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'p_debug_mode='||p_debug_mode, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'p_max_msg_count='||p_max_msg_count, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'p_project_id='||p_project_id, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'p_task_id='||p_task_id, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'p_task_version_id='||p_task_version_id, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'p_as_of_date='||p_as_of_date, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'p_structure_version_id='||p_structure_version_id, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'p_wp_rollup_method='||p_wp_rollup_method, x_Log_Level=> 3);
        END IF;

        IF p_structure_version_id IS NULL THEN
                return;
        END IF;

        IF (p_commit = FND_API.G_TRUE) THEN
                savepoint ASGN_DLV_TO_TASK_ROLLUP_PVT2;
        END IF;

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        l_sharing_Enabled := PA_PROJECT_STRUCTURE_UTILS.check_sharing_enabled(p_project_id);
        l_structure_sharing_code := PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(p_project_id);

        --bug 3949093
        SELECT project_currency_code  INTO  l_prj_currency_code  FROM pa_projects_all WHERE project_id = p_project_id;

        IF (l_sharing_Enabled = 'N' OR (l_sharing_Enabled = 'Y' AND l_structure_sharing_code <> 'SHARE_FULL')) THEN
                l_split_workplan := 'Y';
        ELSE
                l_split_workplan := 'N';
        END IF;

        l_structure_version_id := null;
        l_task_version_id := p_task_version_id;
        l_rollup_method := p_wp_rollup_method;

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_sharing_Enabled='||l_sharing_Enabled, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_structure_sharing_code='||l_structure_sharing_code, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_split_workplan='||l_split_workplan, x_Log_Level=> 3);
        END IF;


        l_task_derivation_code := null;
        l_task_status_code := null;
        l_task_weighting_percentage := 0;

        OPEN cur_base_p_comp_deriv_code(p_task_id, p_project_id);
        FETCH cur_base_p_comp_deriv_code INTO l_task_status_code, l_task_system_status_code, l_task_derivation_code, l_prog_entry_enable_flag;
        CLOSE cur_base_p_comp_deriv_code;


        IF g1_debug_mode  = 'Y' THEN
               pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_task_derivation_code='||l_task_derivation_code, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_task_status_code='||l_task_status_code, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_prog_entry_enable_flag='||l_prog_entry_enable_flag, x_Log_Level=> 3);
        END IF;

        -- Cursor: cur_tasks returns the input task and its immediate sub-tasks. -- Fix for Bug # 4032987.
        FOR cur_tasks_rec in cur_tasks(p_task_version_id) LOOP

                IF g1_debug_mode  = 'Y' THEN
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'Inside Tasks Loop', x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'cur_tasks_rec.base_progress_status_code='||cur_tasks_rec.base_progress_status_code, x_Log_Level=> 3);
                END IF;

                l_action_allowed  := PA_PROJ_ELEMENTS_UTILS.CHECK_TASK_STUS_ACTION_ALLOWED( cur_tasks_rec.status_code, 'PROGRESS_ROLLUP' );

    -- We only populate the asssignment and deliverable records n the PL/SQL table for the input task
    -- , assignments and deliverables of the sub-tasks are not considered. -- Fix for Bug # 4032987.

    if (cur_tasks_rec.object_id_to1 = p_task_version_id) then -- Fix for Bug # 4032987.

        l_override_pc_temp := cur_tasks_rec.override_percent_complete; -- Bug 4506461

        -- Bug 4392189 : Program Changes Begin
        l_sub_project_id := null;
        l_sub_rec   := null;

        -- 4587527 : It was not supporting multiple sub projects at link task
        -- So converted it into FOR LOOP

        FOR rec_subproj IN c_get_sub_project(p_task_version_id, l_task_derivation_code) LOOP
            --OPEN c_get_sub_project (p_task_version_id, l_task_derivation_code);
            --FETCH c_get_sub_project INTO l_sub_project_id, l_sub_structure_ver_id, l_sub_proj_element_id,l_sub_project_bac_value;
            --CLOSE c_get_sub_project;

            --IF l_sub_project_id IS NOT NULL THEN
            IF g1_debug_mode = 'Y' THEN
                 pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT',x_Msg => 'rec_subproj.sub_project_id='||rec_subproj.sub_project_id, x_Log_Level=> 3);
                 pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT',x_Msg => 'rec_subproj.sub_structure_ver_id='||rec_subproj.sub_structure_ver_id, x_Log_Level=> 3);
                 pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT',x_Msg => 'rec_subproj.sub_proj_element_id='||rec_subproj.sub_proj_element_id, x_Log_Level=> 3);
                 pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT',x_Msg => 'rec_subproj.sub_project_bac_value='||rec_subproj.sub_project_bac_value, x_Log_Level=> 3);
            END IF;
            l_subproject_found := 'Y' ; -- Bug 4506461
            l_subproj_task_version_id := p_task_version_id;--4582956

            OPEN c_get_sub_project_progress (rec_subproj.sub_project_id, rec_subproj.sub_structure_ver_id, rec_subproj.sub_proj_element_id, p_as_of_date, l_task_derivation_code);
            FETCH c_get_sub_project_progress INTO l_sub_rec;
            CLOSE c_get_sub_project_progress;

            IF g1_debug_mode = 'Y' THEN
                 pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT',x_Msg => 'l_subproj_prog_rollup_id='||l_sub_rec.progress_rollup_id, x_Log_Level=> 3);
            END IF;

            l_index := l_index + 1;

            l_rollup_table1(l_index).OBJECT_TYPE                    := 'PA_SUBPROJECTS';
            l_rollup_table1(l_index).OBJECT_ID                      := (-1 * l_index);
            l_rollup_table1(l_index).PARENT_OBJECT_TYPE             := 'PA_TASKS';
            l_rollup_table1(l_index).PARENT_OBJECT_ID               := p_task_version_id;
            l_rollup_table1(l_index).WBS_LEVEL                      := 9999999; --  Assigning some value so that order by in   scheduling API  works
            l_rollup_table1(l_index).CALENDAR_ID                    := l_index;

	    -- 4533112 : Added following check
	    IF nvl(cur_tasks_rec.base_progress_status_code, 'N') <> 'Y' THEN
		l_rollup_table1(l_index).START_DATE1			:= l_sub_rec.actual_start_date;
		l_rollup_table1(l_index).FINISH_DATE1                   := l_sub_rec.actual_finish_date;
		l_rollup_table1(l_index).START_DATE2                    := l_sub_rec.estimated_start_date;
		l_rollup_table1(l_index).FINISH_DATE2                   := l_sub_rec.estimated_finish_date;
	    END IF;


            -- 4582956 Begin : LInk task should be treated as summaru task which means
            -- we should be passing % complete of sub project and bac value of sub project
            /*

            -- Bug 4563049 : Do not take l_subproj_bac_value as it may be 0 if actuals and etc is not there
            -- This is additional sefety fix

            -- Bug 4506009 : Deriving l_subproj_earned_value
            IF l_task_derivation_code = 'EFFORT' THEN
                --l_subproj_earned_value := nvl(round((NVL(l_sub_rec.bac_value, NVL(l_sub_project_bac_value, 0))*nvl(l_sub_rec.completed_percentage,0)/100), 5),0);
                -- 4579654 : For more accuracy, Do not round the earned value here.
                --l_subproj_earned_value := nvl(round((NVL(l_sub_project_bac_value, 0)*nvl(l_sub_rec.completed_percentage,0)/100), 5),0);
                l_subproj_earned_value := nvl((NVL(l_sub_project_bac_value, 0)*nvl(l_sub_rec.completed_percentage,0)/100),0);
            ELSE
                --l_subproj_earned_value := nvl(pa_currency.round_trans_currency_amt((NVL(l_sub_rec.bac_value, NVL(l_sub_project_bac_value, 0))*nvl(l_sub_rec.completed_percentage,0)/100), l_prj_currency_code),0);
                -- 4579654 : For more accuracy, Do not round the earned value here.
                --l_subproj_earned_value := nvl(pa_currency.round_trans_currency_amt((NVL(l_sub_project_bac_value, 0)*nvl(l_sub_rec.completed_percentage,0)/100), l_prj_currency_code),0);
                l_subproj_earned_value := nvl((NVL(l_sub_project_bac_value, 0)*nvl(l_sub_rec.completed_percentage,0)/100),0);
            END IF;

            l_rollup_table1(l_index).EARNED_VALUE1                  := nvl(l_subproj_earned_value,0) ; --NVL( l_sub_rec.earned_value, 0 );
            --l_rollup_table1(l_index).BAC_VALUE1                     := NVL( l_sub_rec.bac_value, NVL(l_sub_project_bac_value, 0) );
            l_rollup_table1(l_index).BAC_VALUE1                     := NVL(l_sub_project_bac_value, 0);
            */

            l_rollup_table1(l_index).PERCENT_COMPLETE1               := nvl(l_sub_rec.completed_percentage, 0);
            l_rollup_table1(l_index).BAC_VALUE1                      := NVL(rec_subproj.sub_project_bac_value, 0);
            -- 4582956 End


            --    Rollup Progress Status Rollup
            l_rollup_table1(l_index).PROGRESS_STATUS_WEIGHT1         := nvl(l_sub_rec.rollup_weight1,0);       --rollup prog status
            l_rollup_table1(l_index).PROGRESS_override1              := l_sub_rec.override_weight2;    --override prg  status

            --    Base Progress Status Rollup
	    -- 4533112 : Now base progress status is not used
            --l_rollup_table1(l_index).PROGRESS_STATUS_WEIGHT2 := nvl( l_sub_rec.base_weight3, 0 );  --base prog status
            --l_rollup_table1(l_index).PROGRESS_override2                 :=      0;  -- FPM Dev  CR 2

            --    Task Status Rollup
            l_rollup_table1(l_index).task_status1                    := nvl(l_sub_rec.task_weight4, 0 );  -- task status


            l_rollup_table1(l_index).REMAINING_EFFORT1              := NVL( l_sub_rec.ESTIMATED_REMAINING_EFFORT, 0 ); --etc_people_effort
            l_rollup_table1(l_index).EQPMT_ETC_EFFORT1              := NVL( l_sub_rec.EQPMT_ETC_EFFORT, 0 );

            -- ETC Burden Cost in Project Currency Rollup
            l_rollup_table1(l_index).ETC_COST1                      := NVL( l_sub_rec.OTH_ETC_COST_PC, 0 );
            l_rollup_table1(l_index).PPL_ETC_COST1                  := NVL( l_sub_rec.PPL_ETC_COST_PC, 0 );
            l_rollup_table1(l_index).EQPMT_ETC_COST1                := NVL( l_sub_rec.EQPMT_ETC_COST_PC, 0 );

            -- ETC Burden Cost in Project Functional Currency Rollup
            l_rollup_table1(l_index).ETC_COST2                      := NVL( l_sub_rec.OTH_ETC_COST_FC, 0 );
            l_rollup_table1(l_index).PPL_ETC_COST2                  := NVL( l_sub_rec.PPL_ETC_COST_FC, 0 );
            l_rollup_table1(l_index).EQPMT_ETC_COST2                := NVL( l_sub_rec.EQPMT_ETC_COST_FC, 0 );



            -- ETC Burden Cost in Transaction Currency Rollup
            l_rollup_table1(l_index).ETC_COST3                      := NVL( l_sub_rec.OTH_ETC_COST_TC, 0 );
            l_rollup_table1(l_index).PPL_ETC_COST3                  := NVL( l_sub_rec.PPL_ETC_COST_TC, 0 );
            l_rollup_table1(l_index).EQPMT_ETC_COST3                := NVL( l_sub_rec.EQPMT_ETC_COST_TC, 0 );

            -- ETC Raw Cost in Transaction Currency Rollup
            -- We do not use Transaction currency, so we can utilize this set to do actual effort rollup
            --l_rollup_table1(l_index).ETC_COST4                    := NVL( cur_assgn_rec.OTH_ETC_RAWCost_TC, 0 );
            --l_rollup_table1(l_index).PPL_ETC_COST4                        := NVL( cur_assgn_rec.PPL_ETC_RAWCOST_TC, 0 );
            --l_rollup_table1(l_index).EQPMT_ETC_COST4              := NVL( cur_assgn_rec.EQPMT_ETC_RAWCOST_TC, 0 );

            l_rollup_table1(l_index).ETC_COST4                      := NVL( l_sub_rec.PPL_ACT_EFFORT_TO_DATE, 0 );
            l_rollup_table1(l_index).PPL_ETC_COST4                  := NVL( l_sub_rec.EQPMT_ACT_EFFORT_TO_DATE, 0 );

            -- ETC Raw Cost in Project Currency Rollup
            l_rollup_table1(l_index).ETC_COST5                      := NVL( l_sub_rec.OTH_ETC_RAWCost_PC, 0 );
            l_rollup_table1(l_index).PPL_ETC_COST5                  := NVL( l_sub_rec.PPL_ETC_RAWCOST_PC, 0 );
            l_rollup_table1(l_index).EQPMT_ETC_COST5                := NVL( l_sub_rec.EQPMT_ETC_RAWCOST_PC, 0 );

            -- ETC Raw Cost in PRoject Functional Currency Rollup
            l_rollup_table1(l_index).ETC_COST6                      := NVL( l_sub_rec.OTH_ETC_RAWCost_FC, 0 );
            l_rollup_table1(l_index).PPL_ETC_COST6                  := NVL( l_sub_rec.PPL_ETC_RAWCOST_FC, 0 );
            l_rollup_table1(l_index).EQPMT_ETC_COST6                := NVL( l_sub_rec.EQPMT_ETC_RAWCOST_FC, 0 );

            -- Actual Burden Cost in Transaction Currency Rollup
            l_rollup_table1(l_index).SUB_PRJ_ETC_COST3              := NVL( l_sub_rec.OTH_ACT_COST_TO_DATE_TC, 0 );
            l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_COST3          := NVL( l_sub_rec.PPL_ACT_COST_TO_DATE_TC, 0 );
            l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_COST3        := NVL( l_sub_rec.EQPMT_ACT_COST_TO_DATE_TC, 0 );
            -- Actual Burden Cost in Project Currency Rollup
            l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_EFFORT3        := NVL( l_sub_rec.OTH_ACT_COST_TO_DATE_PC, 0 );
            l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_EFFORT3      := NVL( l_sub_rec.PPL_ACT_COST_TO_DATE_PC, 0 );
            l_rollup_table1(l_index).PPL_UNPLAND_EFFORT3            := NVL( l_sub_rec.EQPMT_ACT_COST_TO_DATE_PC, 0 );
            -- Actual Burden Cost in Project Functional Currency Rollup
            l_rollup_table1(l_index).SUB_PRJ_ETC_COST4              := NVL( l_sub_rec.OTH_ACT_COST_TO_DATE_FC, 0 );
            l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_COST4          := NVL( l_sub_rec.PPL_ACT_COST_TO_DATE_FC, 0 );
            l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_COST4        := NVL( l_sub_rec.EQPMT_ACT_COST_TO_DATE_FC, 0 );

            -- Actual Raw Cost in Transaction Currency Rollup
            l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_EFFORT4        := NVL( l_sub_rec.OTH_ACT_RAWCOST_TO_DATE_TC, 0 );
            l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_EFFORT4      := NVL( l_sub_rec.PPL_ACT_RAWCOST_TO_DATE_TC, 0 );
            l_rollup_table1(l_index).PPL_UNPLAND_EFFORT4            := NVL( l_sub_rec.EQPMT_ACT_RAWCOST_TO_DATE_TC, 0 );
            -- Actual Raw Cost in Project Currency Rollup
            l_rollup_table1(l_index).SUB_PRJ_ETC_COST5              := NVL( l_sub_rec.OTH_ACT_RAWCOST_TO_DATE_PC, 0 );
            l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_COST5          := NVL( l_sub_rec.PPL_ACT_RAWCOST_TO_DATE_PC, 0 );
            l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_COST5        := NVL( l_sub_rec.EQPMT_ACT_RAWCOST_TO_DATE_PC, 0 );
            -- Actual Raw Cost in Project Functional Currency Rollup
            l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_EFFORT5        := NVL( l_sub_rec.OTH_ACT_RAWCOST_TO_DATE_FC, 0 );
            l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_EFFORT5      := NVL( l_sub_rec.PPL_ACT_RAWCOST_TO_DATE_FC, 0 );
            l_rollup_table1(l_index).PPL_UNPLAND_EFFORT5            := NVL( l_sub_rec.EQPMT_ACT_RAWCOST_TO_DATE_FC, 0 );

            l_rollup_table1(l_index).SUB_PRJ_ETC_COST6              := NVL( l_sub_rec.Oth_quantity_to_date, 0 );
            l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_COST6          := NVL( l_sub_rec.oth_etc_quantity, 0 );


            l_rollup_table1(l_index).DIRTY_FLAG1         := 'Y';
            l_rollup_table1(l_index).DIRTY_FLAG2         := 'Y';
            l_rollup_table1(l_index).DIRTY_FLAG3         := 'Y';
            l_rollup_table1(l_index).DIRTY_FLAG4         := 'Y';
            l_rollup_table1(l_index).DIRTY_FLAG5         := 'Y';
            l_rollup_table1(l_index).DIRTY_FLAG6         := 'Y';

            IF nvl( l_task_weighting_percentage, 0 ) = 0 OR nvl(l_prog_entry_enable_flag,'N') = 'N' THEN
                l_action_allowed := 'N';
            END IF;

            l_action_allowed := 'Y';   --temporarrily setting it to Y, need to investigate as why it is N

            pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'Assgn l_action_allowed='||l_action_allowed, x_Log_Level=> 3);

            l_rollup_table1(l_index).rollup_node1                       := l_action_allowed;
            l_rollup_table1(l_index).rollup_node2                       := l_action_allowed;
            l_rollup_table1(l_index).rollup_node3                       := l_action_allowed;
            l_rollup_table1(l_index).rollup_node4                       := l_action_allowed;
            l_rollup_table1(l_index).rollup_node5                       := l_action_allowed;
            l_rollup_table1(l_index).rollup_node6                       := l_action_allowed;
        END LOOP;
            --END IF;
            -- Bug 4392189 : Program Changes End


        -- Loop thru all task assignments of a passed task
                FOR cur_assgn_rec in cur_assgn(p_task_id, p_task_version_id, l_task_derivation_code) LOOP

                        l_index := l_index + 1;

                        l_rollup_table1(l_index).OBJECT_TYPE                    := cur_assgn_rec.object_type;
                        l_rollup_table1(l_index).OBJECT_ID                      := cur_assgn_rec.object_id_to1; -- Reaource Assignment Id
                        l_rollup_table1(l_index).PARENT_OBJECT_TYPE             := cur_assgn_rec.parent_object_type;
                        l_rollup_table1(l_index).PARENT_OBJECT_ID               := cur_assgn_rec.object_id_from1; -- Task Version Id
                        l_rollup_table1(l_index).WBS_LEVEL                      := 9999999; -- Assigning some value so that order by in scheduling API works

                        -- Percent Complete needs to be derived using Earned Value and BAC Value

                        -- Percent Complete at Assignment level does not get calculated

			-- 4533112 : Added following check for base_progress_status_code
			    IF l_task_derivation_code IN ('EFFORT', 'COST') AND nvl(cur_tasks_rec.base_progress_status_code, 'N') <> 'Y' THEN -- Bug 3956299
				-- Actual Date Rollup : Only Start Date gets rolls up.
				l_rollup_table1(l_index).START_DATE1                    := cur_assgn_rec.actual_start_date;
				l_rollup_table1(l_index).FINISH_DATE1                    := cur_assgn_rec.actual_finish_date;

				-- Estimated Date Rollup  : Only Start Date gets rolls up.
				l_rollup_table1(l_index).START_DATE2                    := cur_assgn_rec.estimated_start_date;
				l_rollup_table1(l_index).FINISH_DATE2                    := cur_assgn_rec.estimated_finish_date;
			    END IF;


                        -- Progress Status entry is not there at assignment level

                        -- Assignment Status entry is not there at assignment level

                        -- ETC Effort Rollup
                        l_rollup_table1(l_index).REMAINING_EFFORT1              := NVL( cur_assgn_rec.ESTIMATED_REMAINING_EFFORT, 0 ); --etc_people_effort
                        l_rollup_table1(l_index).EQPMT_ETC_EFFORT1              := NVL( cur_assgn_rec.EQPMT_ETC_EFFORT, 0 );

                        -- ETC Burden Cost in Project Currency Rollup
                        l_rollup_table1(l_index).ETC_COST1                      := NVL( cur_assgn_rec.OTH_ETC_COST_PC, 0 );
                        l_rollup_table1(l_index).PPL_ETC_COST1                  := NVL( cur_assgn_rec.PPL_ETC_COST_PC, 0 );
                        l_rollup_table1(l_index).EQPMT_ETC_COST1                := NVL( cur_assgn_rec.EQPMT_ETC_COST_PC, 0 );

                        -- ETC Burden Cost in Project Functional Currency Rollup
                        l_rollup_table1(l_index).ETC_COST2                      := NVL( cur_assgn_rec.OTH_ETC_COST_FC, 0 );
                        l_rollup_table1(l_index).PPL_ETC_COST2                  := NVL( cur_assgn_rec.PPL_ETC_COST_FC, 0 );
                        l_rollup_table1(l_index).EQPMT_ETC_COST2                := NVL( cur_assgn_rec.EQPMT_ETC_COST_FC, 0 );

                        -- Earned Value and BAC Rollup
                        l_rollup_table1(l_index).EARNED_VALUE1                  := NVL( cur_assgn_rec.EARNED_VALUE, 0 );
                        l_rollup_table1(l_index).BAC_VALUE1                     := NVL( cur_assgn_rec.bac_value_in_task_deriv, 0 );

			-- 4392189 : Program Reporting Changes - Phase 2
			-- Having Set2 columns to get Project level % complete
                        l_rollup_table1(l_index).EARNED_VALUE2                  := NVL( cur_assgn_rec.EARNED_VALUE, 0 );
                        l_rollup_table1(l_index).BAC_VALUE2                     := NVL( cur_assgn_rec.bac_value_in_task_deriv, 0 );


                        --Bug 3614828 Begin

                        -- ETC Burden Cost in Transaction Currency Rollup
                        l_rollup_table1(l_index).ETC_COST3                      := NVL( cur_assgn_rec.OTH_ETC_COST_TC, 0 );
                        l_rollup_table1(l_index).PPL_ETC_COST3                  := NVL( cur_assgn_rec.PPL_ETC_COST_TC, 0 );
                        l_rollup_table1(l_index).EQPMT_ETC_COST3                := NVL( cur_assgn_rec.EQPMT_ETC_COST_TC, 0 );

                        -- ETC Raw Cost in Transaction Currency Rollup
                        -- We do not use Transaction currency, so we can utilize this set to do actual effort rollup
                        --l_rollup_table1(l_index).ETC_COST4                    := NVL( cur_assgn_rec.OTH_ETC_RAWCost_TC, 0 );
                        --l_rollup_table1(l_index).PPL_ETC_COST4                        := NVL( cur_assgn_rec.PPL_ETC_RAWCOST_TC, 0 );
                        --l_rollup_table1(l_index).EQPMT_ETC_COST4              := NVL( cur_assgn_rec.EQPMT_ETC_RAWCOST_TC, 0 );

                        l_rollup_table1(l_index).ETC_COST4                      := NVL( cur_assgn_rec.PPL_ACT_EFFORT_TO_DATE, 0 );
                        l_rollup_table1(l_index).PPL_ETC_COST4                  := NVL( cur_assgn_rec.EQPMT_ACT_EFFORT_TO_DATE, 0 );

                        -- ETC Raw Cost in Project Currency Rollup
                        l_rollup_table1(l_index).ETC_COST5                      := NVL( cur_assgn_rec.OTH_ETC_RAWCost_PC, 0 );
                        l_rollup_table1(l_index).PPL_ETC_COST5                  := NVL( cur_assgn_rec.PPL_ETC_RAWCOST_PC, 0 );
                        l_rollup_table1(l_index).EQPMT_ETC_COST5                := NVL( cur_assgn_rec.EQPMT_ETC_RAWCOST_PC, 0 );

                        -- ETC Raw Cost in PRoject Functional Currency Rollup
                        l_rollup_table1(l_index).ETC_COST6                      := NVL( cur_assgn_rec.OTH_ETC_RAWCost_FC, 0 );
                        l_rollup_table1(l_index).PPL_ETC_COST6                  := NVL( cur_assgn_rec.PPL_ETC_RAWCOST_FC, 0 );
                        l_rollup_table1(l_index).EQPMT_ETC_COST6                := NVL( cur_assgn_rec.EQPMT_ETC_RAWCOST_FC, 0 );

                        -- Actual Burden Cost in Transaction Currency Rollup
                        l_rollup_table1(l_index).SUB_PRJ_ETC_COST3              := NVL( cur_assgn_rec.OTH_ACT_COST_TO_DATE_TC, 0 );
                        l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_COST3          := NVL( cur_assgn_rec.PPL_ACT_COST_TO_DATE_TC, 0 );
                        l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_COST3        := NVL( cur_assgn_rec.EQPMT_ACT_COST_TO_DATE_TC, 0 );
                        -- Actual Burden Cost in Project Currency Rollup
                        l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_EFFORT3        := NVL( cur_assgn_rec.OTH_ACT_COST_TO_DATE_PC, 0 );
                        l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_EFFORT3      := NVL( cur_assgn_rec.PPL_ACT_COST_TO_DATE_PC, 0 );
                        l_rollup_table1(l_index).PPL_UNPLAND_EFFORT3            := NVL( cur_assgn_rec.EQPMT_ACT_COST_TO_DATE_PC, 0 );
                        -- Actual Burden Cost in Project Functional Currency Rollup
                        l_rollup_table1(l_index).SUB_PRJ_ETC_COST4              := NVL( cur_assgn_rec.OTH_ACT_COST_TO_DATE_FC, 0 );
                        l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_COST4          := NVL( cur_assgn_rec.PPL_ACT_COST_TO_DATE_FC, 0 );
                        l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_COST4        := NVL( cur_assgn_rec.EQPMT_ACT_COST_TO_DATE_FC, 0 );

                        -- Actual Raw Cost in Transaction Currency Rollup
                        l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_EFFORT4        := NVL( cur_assgn_rec.OTH_ACT_RAWCOST_TO_DATE_TC, 0 );
                        l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_EFFORT4      := NVL( cur_assgn_rec.PPL_ACT_RAWCOST_TO_DATE_TC, 0 );
                        l_rollup_table1(l_index).PPL_UNPLAND_EFFORT4            := NVL( cur_assgn_rec.EQPMT_ACT_RAWCOST_TO_DATE_TC, 0 );
                        -- Actual Raw Cost in Project Currency Rollup
                        l_rollup_table1(l_index).SUB_PRJ_ETC_COST5              := NVL( cur_assgn_rec.OTH_ACT_RAWCOST_TO_DATE_PC, 0 );
                        l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_COST5          := NVL( cur_assgn_rec.PPL_ACT_RAWCOST_TO_DATE_PC, 0 );
                        l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_COST5        := NVL( cur_assgn_rec.EQPMT_ACT_RAWCOST_TO_DATE_PC, 0 );
                        -- Actual Raw Cost in Project Functional Currency Rollup
                        l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_EFFORT5        := NVL( cur_assgn_rec.OTH_ACT_RAWCOST_TO_DATE_FC, 0 );
                        l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_EFFORT5      := NVL( cur_assgn_rec.PPL_ACT_RAWCOST_TO_DATE_FC, 0 );
                        l_rollup_table1(l_index).PPL_UNPLAND_EFFORT5            := NVL( cur_assgn_rec.EQPMT_ACT_RAWCOST_TO_DATE_FC, 0 );

			-- Bug 3879461 : Oth_quantity_to_date and oth_etc_quantity was not getting rolled up.
                        l_rollup_table1(l_index).SUB_PRJ_ETC_COST6              := NVL( cur_assgn_rec.Oth_quantity_to_date, 0 );
                        l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_COST6          := NVL( cur_assgn_rec.oth_etc_quantity, 0 );


                        --Bug 3614828 End


                        l_rollup_table1(l_index).DIRTY_FLAG1         := 'Y';
                        l_rollup_table1(l_index).DIRTY_FLAG2         := 'Y';
                        l_rollup_table1(l_index).DIRTY_FLAG3         := 'Y';
                        l_rollup_table1(l_index).DIRTY_FLAG4         := 'Y';
                        l_rollup_table1(l_index).DIRTY_FLAG5         := 'Y';
                        l_rollup_table1(l_index).DIRTY_FLAG6         := 'Y';

                        IF nvl( l_task_weighting_percentage, 0 ) = 0 OR nvl(l_prog_entry_enable_flag,'N') = 'N' THEN
                                l_action_allowed := 'N';
                        END IF;

                        l_action_allowed := 'Y';   --temporarrily setting it to Y, need to investigate as why it is N

                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'Assgn l_action_allowed='||l_action_allowed, x_Log_Level=> 3);

                        l_rollup_table1(l_index).rollup_node1                       := l_action_allowed;
                        l_rollup_table1(l_index).rollup_node2                       := l_action_allowed;
                        l_rollup_table1(l_index).rollup_node3                       := l_action_allowed;
                        l_rollup_table1(l_index).rollup_node4                       := l_action_allowed;
                        l_rollup_table1(l_index).rollup_node5                       := l_action_allowed;
                        l_rollup_table1(l_index).rollup_node6                       := l_action_allowed;
                END LOOP; -- Assignments Loop cur_assgn_rec


                IF l_task_derivation_code = 'DELIVERABLE' THEN

                        FOR cur_del_rec in cur_deliverables(p_task_id, p_task_version_id, p_project_id) LOOP

                                l_index := l_index + 1;

                                l_rollup_table1(l_index).OBJECT_TYPE          := cur_del_rec.object_type;
                                l_rollup_table1(l_index).OBJECT_ID            := cur_del_rec.object_id_to1;--Object Version Id of Deliverable
                                l_rollup_table1(l_index).PARENT_OBJECT_TYPE   := cur_del_rec.parent_object_type;
                                l_rollup_table1(l_index).PARENT_OBJECT_ID     := p_task_version_id;
                                l_rollup_table1(l_index).WBS_LEVEL            := 9999999;

                                -- Rollup Percent Complete Rollup
                                l_rollup_table1(l_index).task_weight1         := nvl( cur_del_rec.weighting_percentage, 0 );
                                l_rollup_table1(l_index).PERCENT_COMPLETE1    := nvl( cur_del_rec.completed_percentage, 0 );
                                --l_rollup_table1(l_index).PERCENT_OVERRIDE1    := 0; -- FPM Dev CR 2

				-- 4392189 : Program Reporting Changes - Phase 2
				-- Having Set2 columns to get Project level % complete
                                l_rollup_table1(l_index).task_weight2         := nvl( cur_del_rec.weighting_percentage, 0 );
                                l_rollup_table1(l_index).PERCENT_COMPLETE2    := nvl( cur_del_rec.completed_percentage, 0 );


                                -- Base Percent Complete Rollup
                                -- l_rollup_table1(l_index).task_weight2      := nvl( cur_del_rec.weighting_percentage, 0 );
                                -- l_rollup_table1(l_index).PERCENT_COMPLETE2 := nvl( cur_del_rec.base_percent_complete, 0 );
                                -- l_rollup_table1(l_index).PERCENT_OVERRIDE2 := 0;

                                -- Dates will not get rolled up for deliverable
                                -- Rollup Progress Status Rollup

                                -- l_rollup_table1(l_index).PROGRESS_STATUS_WEIGHT1 := 0;    --rollup prog status is 0 for deliverable as it is lowest -- FPM Dev CR 2
                                l_rollup_table1(l_index).PROGRESS_override1      := cur_del_rec.override_weight;    --override prg status

                                -- Base Progress Status Rollup
				-- 4533112 : Now base progress status weight is not used
                                --l_rollup_table1(l_index).PROGRESS_STATUS_WEIGHT2 := nvl( cur_del_rec.base_weight, 0);
                                -- l_rollup_table1(l_index).PROGRESS_override2      := 0;

                                l_rollup_table1(l_index).DIRTY_FLAG1      := 'Y';
                                l_rollup_table1(l_index).DIRTY_FLAG2      := 'Y';

                                -- Deliverable Status will not get rolled up for deliverable

                                l_action_allowed  := PA_PROJ_ELEMENTS_UTILS.CHECK_TASK_STUS_ACTION_ALLOWED(cur_tasks_rec.status_code, 'PROGRESS_ROLLUP' );

                                IF nvl( l_task_weighting_percentage, 0 ) = 0 THEN
                                     l_action_allowed := 'N';
                                END IF;

                                IF nvl( cur_del_rec.weighting_percentage, 0 ) = 0 THEN
                                     l_action_allowed := 'N';
                                END IF;

                                IF g1_debug_mode  = 'Y' THEN
                                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'Deliverable l_action_allowed='||l_action_allowed, x_Log_Level=> 3);
                                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'Deliverable cur_del_rec.weighting_percentage='||cur_del_rec.weighting_percentage, x_Log_Level=> 3);
                                END IF;

                                l_rollup_table1(l_index).rollup_node1          := l_action_allowed;
                                l_rollup_table1(l_index).rollup_node2          := l_action_allowed;

                                l_rollup_table1(l_index).rollup_node1          := 'Y';
                                l_rollup_table1(l_index).rollup_node2          := 'Y';

                        END LOOP; -- Delivertables Loop cur_del_rec
                END IF; -- l_task_derivation_code = 'DELIVERABLES' THEN

    end if;  -- Fix for Bug # 4032987.

                l_index := l_index + 1;

                l_rollup_table1(l_index).OBJECT_TYPE                     := cur_tasks_rec.object_type;
                l_rollup_table1(l_index).OBJECT_ID                       := cur_tasks_rec.object_id_to1;--Task Version Id
                l_rollup_table1(l_index).PARENT_OBJECT_TYPE              := cur_tasks_rec.parent_object_type;
                l_rollup_table1(l_index).PARENT_OBJECT_ID                := cur_tasks_rec.object_id_from1; --Parent Task Version Id
                l_rollup_table1(l_index).WBS_LEVEL                       := NVL( cur_tasks_rec.wbs_level, 0 );

		-- 4582956 Begin
                -- l_rollup_table1(l_index).SUMMARY_OBJECT_FLAG             := PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(cur_tasks_rec.object_id_to1);--4370746
		IF cur_tasks_rec.object_id_to1 = nvl(l_subproj_task_version_id, -789) THEN
			-- 4586449 : Passing L for link tasks
			l_rollup_table1(l_index).SUMMARY_OBJECT_FLAG         := 'L'; --Link task shd be treated as summary task
			--l_rollup_table1(l_index).SUMMARY_OBJECT_FLAG       := 'Y'; --Link task shd be treated as summary task
		ELSE
			l_rollup_table1(l_index).SUMMARY_OBJECT_FLAG         := PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(cur_tasks_rec.object_id_to1);
		END IF;
		-- 4582956 end

                     -- Rollup Percent Complete Rollup
                l_rollup_table1(l_index).task_weight1                    := nvl( cur_tasks_rec.weighting_percentage, 0 );
                l_rollup_table1(l_index).PERCENT_COMPLETE1               := nvl( cur_tasks_rec.rollup_completed_percentage, 0 );
                l_rollup_table1(l_index).PERCENT_OVERRIDE1               := cur_tasks_rec.override_percent_complete;

		-- 4392189 : Program Reporting Changes - Phase 2
		-- Having Set2 columns to get Project level % complete
                l_rollup_table1(l_index).task_weight2                    := nvl( cur_tasks_rec.weighting_percentage, 0 );
                l_rollup_table1(l_index).PERCENT_COMPLETE2               := nvl( cur_tasks_rec.base_percent_complete, 0 );
		--4557541 : For self % complete Override at tasks level would not be considered
                --l_rollup_table1(l_index).PERCENT_OVERRIDE2               := cur_tasks_rec.override_percent_complete;
		l_rollup_table1(l_index).PERCENT_OVERRIDE2               := null;


                     -- Base Percent Complete Rollup
                        -- l_rollup_table1(l_index).task_weight2            := nvl( cur_tasks_rec.weighting_percentage, 0 );
                        -- l_rollup_table1(l_index).PERCENT_COMPLETE2       := nvl( cur_tasks_rec.base_percent_complete, 0 );
                        -- l_rollup_table1(l_index).PERCENT_OVERRIDE2       := 0;

                     -- Actual Date Rollup
                l_rollup_table1(l_index).START_DATE1                     := cur_tasks_rec.actual_start_date;
                l_rollup_table1(l_index).FINISH_DATE1                    := cur_tasks_rec.actual_finish_date;

                     -- Estimated Date Rollup
                l_rollup_table1(l_index).START_DATE2                     := cur_tasks_rec.estimated_start_date;
                l_rollup_table1(l_index).FINISH_DATE2                    := cur_tasks_rec.estimated_finish_date;

                     -- Rollup Progress Status Rollup
                l_rollup_table1(l_index).PROGRESS_STATUS_WEIGHT1         := nvl(cur_tasks_rec.rollup_weight1,0);    --rollup prog status
                l_rollup_table1(l_index).PROGRESS_override1              := cur_tasks_rec.override_weight2;    --override prg status

                -- Base Progress Status Rollup
		-- 4533112 : Now base_progress_status_code is not used
                --l_rollup_table1(l_index).PROGRESS_STATUS_WEIGHT2 := nvl( cur_tasks_rec.base_weight3, 0 );  --base prog status
                --l_rollup_table1(l_index).PROGRESS_override2              := 0;  -- FPM Dev CR 2

                     -- Task Status Rollup
                l_rollup_table1(l_index).task_status1                    := nvl( cur_tasks_rec.task_weight4, 0 );  -- task status

                     -- ETC Effort Rollup
                l_rollup_table1(l_index).REMAINING_EFFORT1               := NVL( cur_tasks_rec.ESTIMATED_REMAINING_EFFORT, 0 ); --etc_people_effort
                l_rollup_table1(l_index).EQPMT_ETC_EFFORT1               := NVL( cur_tasks_rec.EQPMT_ETC_EFFORT, 0 );

                     -- ETC Burden Cost in Project Currency Rollup
                l_rollup_table1(l_index).ETC_COST1                       := NVL( cur_tasks_rec.OTH_ETC_COST_PC, 0 );
                l_rollup_table1(l_index).PPL_ETC_COST1                   := NVL( cur_tasks_rec.PPL_ETC_COST_PC, 0 );
                l_rollup_table1(l_index).EQPMT_ETC_COST1                 := NVL( cur_tasks_rec.EQPMT_ETC_COST_PC, 0 );

                -- ETC Burden Cost in Project Functional Currency Rollup
                l_rollup_table1(l_index).ETC_COST2                       := NVL( cur_tasks_rec.OTH_ETC_COST_FC, 0 );
                l_rollup_table1(l_index).PPL_ETC_COST2                   := NVL( cur_tasks_rec.PPL_ETC_COST_FC, 0 );
                l_rollup_table1(l_index).EQPMT_ETC_COST2                 := NVL( cur_tasks_rec.EQPMT_ETC_COST_FC, 0 );

                     -- Sub Project ETC Effort Rollup
                l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_EFFORT1 := NVL( cur_tasks_rec.SUBPRJ_PPL_ETC_EFFORT, 0 );
                l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_EFFORT1 := NVL( cur_tasks_rec.SUBPRJ_EQPMT_ETC_EFFORT, 0 );

                     -- Sub Project ETC Cost in Project Currency Rollup
                l_rollup_table1(l_index).SUB_PRJ_ETC_COST1       := NVL( cur_tasks_rec.SUBPRJ_OTH_ETC_COST_PC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_COST1   := NVL( cur_tasks_rec.SUBPRJ_PPL_ETC_COST_PC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_COST1 := NVL( cur_tasks_rec.SUBPRJ_EQPMT_ETC_COST_PC, 0 );

                -- Sub Project ETC Cost in Project Functional Currency Rollup
                l_rollup_table1(l_index).SUB_PRJ_ETC_COST2       := NVL( cur_tasks_rec.SUBPRJ_OTH_ETC_COST_FC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_COST2   := NVL( cur_tasks_rec.SUBPRJ_PPL_ETC_COST_FC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_COST2 := NVL( cur_tasks_rec.SUBPRJ_EQPMT_ETC_COST_FC, 0 );

		-- 4392189 : Program Reporting Changes - Phase 2
		-- Having Set2 columns to get Project level % complete

                 -- Earned Value and BAC Rollup
                l_rollup_table1(l_index).EARNED_VALUE1           := 0; --NVL( cur_tasks_rec.EARNED_VALUE, 0 );
		l_rollup_table1(l_index).EARNED_VALUE2           := 0; --NVL( cur_tasks_rec.EARNED_VALUE, 0 );

		-- 4586449 Begin : For link tasks, pass BAC_VALUE in terms of derivation method of the task
		-- in EARNED_VALUE1
		IF cur_tasks_rec.object_id_to1 = nvl(l_subproj_task_version_id, -789)
		AND cur_tasks_rec.object_id_to1 = p_task_version_id
		THEN

			l_rollup_table1(l_index).EARNED_VALUE1 := pa_progress_utils.Get_BAC_Value(p_project_id
				, l_task_derivation_code, p_task_id,  p_structure_version_id,
				'WORKPLAN','N','Y');
			-- Bug 4636100 Issue 1 : We should always pass self plan for link task as 1
			--l_rollup_table1(l_index).EARNED_VALUE2 := NVL( cur_tasks_rec.BAC_VALUE_SELF, 0 );
			l_rollup_table1(l_index).EARNED_VALUE2 := 1;
		END IF;

		l_rollup_table1(l_index).BAC_VALUE1              := NVL( cur_tasks_rec.BAC_VALUE, 0 );

		IF g1_debug_mode = 'Y' THEN
			pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_rollup_table1(l_index).BAC_VALUE1='||l_rollup_table1(l_index).BAC_VALUE1,     x_Log_Level=> 3);
			pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_rollup_table1(l_index).EARNED_VALUE1='||l_rollup_table1(l_index).EARNED_VALUE1, x_Log_Level=> 3);
			pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_rollup_table1(l_index).EARNED_VALUE2='||l_rollup_table1(l_index).EARNED_VALUE2, x_Log_Level=> 3);
                END IF;
		-- 4586449 End


                l_rollup_table1(l_index).BAC_VALUE2              := NVL( cur_tasks_rec.BAC_VALUE_SELF, 0 ); -- Bug 4493105


                l_rollup_table1(l_index).PERC_COMP_DERIVATIVE_CODE1 := l_task_derivation_code;
                l_rollup_table1(l_index).PERC_COMP_DERIVATIVE_CODE2 := l_task_derivation_code;

                --Bug 3614828 Begin
                        -- ETC Burden Cost in Transaction Currency Rollup
                l_rollup_table1(l_index).ETC_COST3                      := NVL( cur_tasks_rec.OTH_ETC_COST_TC, 0 );
                l_rollup_table1(l_index).PPL_ETC_COST3                  := NVL( cur_tasks_rec.PPL_ETC_COST_TC, 0 );
                l_rollup_table1(l_index).EQPMT_ETC_COST3                := NVL( cur_tasks_rec.EQPMT_ETC_COST_TC, 0 );

                -- ETC Raw Cost in Transaction Currency Rollup
                -- We do not use Transaction currency, so we can utilize this set to do actual effort rollup
                --l_rollup_table1(l_index).ETC_COST4                    := NVL( cur_tasks_rec.OTH_ETC_RAWCost_TC, 0 );
                --l_rollup_table1(l_index).PPL_ETC_COST4                        := NVL( cur_tasks_rec.PPL_ETC_RAWCOST_TC, 0 );
                --l_rollup_table1(l_index).EQPMT_ETC_COST4              := NVL( cur_tasks_rec.EQPMT_ETC_RAWCOST_TC, 0 );

                l_rollup_table1(l_index).ETC_COST4                      := NVL( cur_tasks_rec.PPL_ACT_EFFORT_TO_DATE, 0 );
                l_rollup_table1(l_index).PPL_ETC_COST4                  := NVL( cur_tasks_rec.EQPMT_ACT_EFFORT_TO_DATE, 0 );

                -- ETC Raw Cost in Project Currency Rollup
                l_rollup_table1(l_index).ETC_COST5                      := NVL( cur_tasks_rec.OTH_ETC_RAWCost_PC, 0 );
                l_rollup_table1(l_index).PPL_ETC_COST5                  := NVL( cur_tasks_rec.PPL_ETC_RAWCOST_PC, 0 );
                l_rollup_table1(l_index).EQPMT_ETC_COST5                := NVL( cur_tasks_rec.EQPMT_ETC_RAWCOST_PC, 0 );

                -- ETC Raw Cost in PRoject Functional Currency Rollup
                l_rollup_table1(l_index).ETC_COST6                      := NVL( cur_tasks_rec.OTH_ETC_RAWCost_FC, 0 );
                l_rollup_table1(l_index).PPL_ETC_COST6                  := NVL( cur_tasks_rec.PPL_ETC_RAWCOST_FC, 0 );
                l_rollup_table1(l_index).EQPMT_ETC_COST6                := NVL( cur_tasks_rec.EQPMT_ETC_RAWCOST_FC, 0 );


                -- Actual Burden Cost in Transaction Currency Rollup
                l_rollup_table1(l_index).SUB_PRJ_ETC_COST3              := NVL( cur_tasks_rec.OTH_ACT_COST_TO_DATE_TC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_COST3          := NVL( cur_tasks_rec.PPL_ACT_COST_TO_DATE_TC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_COST3        := NVL( cur_tasks_rec.EQPMT_ACT_COST_TO_DATE_TC, 0 );
                -- Actual Burden Cost in Project Currency Rollup
                l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_EFFORT3        := NVL( cur_tasks_rec.OTH_ACT_COST_TO_DATE_PC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_EFFORT3      := NVL( cur_tasks_rec.PPL_ACT_COST_TO_DATE_PC, 0 );
                l_rollup_table1(l_index).PPL_UNPLAND_EFFORT3            := NVL( cur_tasks_rec.EQPMT_ACT_COST_TO_DATE_PC, 0 );
                -- Actual Burden Cost in Project Functional Currency Rollup
                l_rollup_table1(l_index).SUB_PRJ_ETC_COST4              := NVL( cur_tasks_rec.OTH_ACT_COST_TO_DATE_FC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_COST4          := NVL( cur_tasks_rec.PPL_ACT_COST_TO_DATE_FC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_COST4        := NVL( cur_tasks_rec.EQPMT_ACT_COST_TO_DATE_FC, 0 );

                -- Actual Raw Cost in Transaction Currency Rollup
                l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_EFFORT4        := NVL( cur_tasks_rec.OTH_ACT_RAWCOST_TO_DATE_TC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_EFFORT4      := NVL( cur_tasks_rec.PPL_ACT_RAWCOST_TO_DATE_TC, 0 );
                l_rollup_table1(l_index).PPL_UNPLAND_EFFORT4            := NVL( cur_tasks_rec.EQPMT_ACT_RAWCOST_TO_DATE_TC, 0 );
                -- Actual Raw Cost in Project Currency Rollup
                l_rollup_table1(l_index).SUB_PRJ_ETC_COST5              := NVL( cur_tasks_rec.OTH_ACT_RAWCOST_TO_DATE_PC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_COST5          := NVL( cur_tasks_rec.PPL_ACT_RAWCOST_TO_DATE_PC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_COST5        := NVL( cur_tasks_rec.EQPMT_ACT_RAWCOST_TO_DATE_PC, 0 );
                -- Actual Raw Cost in Project Functional Currency Rollup
                l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_EFFORT5        := NVL( cur_tasks_rec.OTH_ACT_RAWCOST_TO_DATE_FC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_EFFORT5      := NVL( cur_tasks_rec.PPL_ACT_RAWCOST_TO_DATE_FC, 0 );
                l_rollup_table1(l_index).PPL_UNPLAND_EFFORT5            := NVL( cur_tasks_rec.EQPMT_ACT_RAWCOST_TO_DATE_FC, 0 );

                --Bug 3614828 End

        -- Bug 3879461 : Oth_quantity_to_date and oth_etc_quantity was not getting rolled up.
                l_rollup_table1(l_index).SUB_PRJ_ETC_COST6              := NVL( cur_tasks_rec.Oth_quantity_to_date, 0 );
                l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_COST6          := NVL( cur_tasks_rec.oth_etc_quantity, 0 );



                l_rollup_table1(l_index).DIRTY_FLAG1         := 'Y';
                l_rollup_table1(l_index).DIRTY_FLAG2         := 'Y';
                l_rollup_table1(l_index).DIRTY_FLAG3         := 'Y';
                l_rollup_table1(l_index).DIRTY_FLAG4         := 'Y';
                l_rollup_table1(l_index).DIRTY_FLAG5         := 'Y';
                l_rollup_table1(l_index).DIRTY_FLAG6         := 'Y';

                IF nvl( cur_tasks_rec.weighting_percentage, 0 ) = 0 THEN
                        l_action_allowed := 'N';
                END IF;

                IF g1_debug_mode  = 'Y' THEN
                     pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'Tasks l_action_allowed='||l_action_allowed, x_Log_Level=> 3);
                     pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'Tasks cur_tasks_rec.weighting_percentage='||cur_tasks_rec.weighting_percentage, x_Log_Level=> 3);
                END IF;

                l_rollup_table1(l_index).rollup_node1                    := l_action_allowed;
                l_rollup_table1(l_index).rollup_node2                    := l_action_allowed;
                l_rollup_table1(l_index).rollup_node3                    := l_action_allowed;
                l_rollup_table1(l_index).rollup_node4                    := l_action_allowed;
                l_rollup_table1(l_index).rollup_node5                    := l_action_allowed;
                l_rollup_table1(l_index).rollup_node6                    := l_action_allowed;

                l_rollup_table1(l_index).rollup_node1          := 'Y';
                l_rollup_table1(l_index).rollup_node2          := 'Y';
                l_rollup_table1(l_index).rollup_node3          := 'Y';
                l_rollup_table1(l_index).rollup_node4          := 'Y';
                l_rollup_table1(l_index).rollup_node5          := 'Y';
                l_rollup_table1(l_index).rollup_node6          := 'Y';

        END LOOP; -- Tasks Loop

/*
        --bug 3951982
        --populate scheduling pl/sql table with sub-tasks of a summary tasks if it has assignments.
        IF PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(p_task_version_id => p_task_version_id ) = 'N'
           AND pa_progress_utils.check_assignment_exists(p_project_id,p_task_version_id, 'PA_TASKS') = 'Y'
        THEN
            -- Loop thru all tasks of a passed task
            FOR cur_tasks_rec in cur_tasks( p_task_version_id ) LOOP
              IF cur_tasks_rec.object_type = 'PA_TASKS'
              THEN
                IF g1_debug_mode  = 'Y' THEN
                   pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'Inside Tasks Loop: Second pass', x_Log_Level=> 3);
                   pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'p_task_version_id='||p_task_version_id, x_Log_Level=> 3);
                END IF;

                l_action_allowed  := PA_PROJ_ELEMENTS_UTILS.CHECK_TASK_STUS_ACTION_ALLOWED( cur_tasks_rec.status_code, 'PROGRESS_ROLLUP' );

                IF g1_debug_mode  = 'Y' THEN
                   pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_index='||l_index, x_Log_Level=> 3);
                END IF;

                l_index := l_index + 1;

                l_rollup_table1(l_index).OBJECT_TYPE                     := cur_tasks_rec.object_type;
                l_rollup_table1(l_index).OBJECT_ID                       := cur_tasks_rec.object_id_to1;--Task Version Id
                l_rollup_table1(l_index).PARENT_OBJECT_TYPE              := cur_tasks_rec.parent_object_type;
                l_rollup_table1(l_index).PARENT_OBJECT_ID                := cur_tasks_rec.object_id_from1; --Parent Task Version Id
                l_rollup_table1(l_index).WBS_LEVEL                       := NVL( cur_tasks_rec.wbs_level, 0 );

                     -- Rollup Percent Complete Rollup
                l_rollup_table1(l_index).task_weight1                    := nvl( cur_tasks_rec.weighting_percentage, 0 );
                l_rollup_table1(l_index).PERCENT_COMPLETE1               := nvl( cur_tasks_rec.rollup_completed_percentage, 0 );
                l_rollup_table1(l_index).PERCENT_OVERRIDE1               := cur_tasks_rec.override_percent_complete;

                     -- Base Percent Complete Rollup
                        -- l_rollup_table1(l_index).task_weight2            := nvl( cur_tasks_rec.weighting_percentage, 0 );
                        -- l_rollup_table1(l_index).PERCENT_COMPLETE2       := nvl( cur_tasks_rec.base_percent_complete, 0 );
                        -- l_rollup_table1(l_index).PERCENT_OVERRIDE2       := 0;

                     -- Actual Date Rollup
                l_rollup_table1(l_index).START_DATE1                     := cur_tasks_rec.actual_start_date;
                l_rollup_table1(l_index).FINISH_DATE1                    := cur_tasks_rec.actual_finish_date;

                     -- Estimated Date Rollup
                l_rollup_table1(l_index).START_DATE2                     := cur_tasks_rec.estimated_start_date;
                l_rollup_table1(l_index).FINISH_DATE2                    := cur_tasks_rec.estimated_finish_date;

                     -- Rollup Progress Status Rollup
                l_rollup_table1(l_index).PROGRESS_STATUS_WEIGHT1         := nvl(cur_tasks_rec.rollup_weight1,0);    --rollup prog status
                l_rollup_table1(l_index).PROGRESS_override1              := cur_tasks_rec.override_weight2;    --override prg status

                     -- Base Progress Status Rollup
                l_rollup_table1(l_index).PROGRESS_STATUS_WEIGHT2 := nvl( cur_tasks_rec.base_weight3, 0 );  --base prog status
                --l_rollup_table1(l_index).PROGRESS_override2              := 0;  -- FPM Dev CR 2

                     -- Task Status Rollup
                l_rollup_table1(l_index).task_status1                    := nvl( cur_tasks_rec.task_weight4, 0 );  -- task status

                     -- ETC Effort Rollup
                l_rollup_table1(l_index).REMAINING_EFFORT1               := NVL( cur_tasks_rec.ESTIMATED_REMAINING_EFFORT, 0 ); --etc_people_effort
                l_rollup_table1(l_index).EQPMT_ETC_EFFORT1               := NVL( cur_tasks_rec.EQPMT_ETC_EFFORT, 0 );

                     -- ETC Burden Cost in Project Currency Rollup
                l_rollup_table1(l_index).ETC_COST1                       := NVL( cur_tasks_rec.OTH_ETC_COST_PC, 0 );
                l_rollup_table1(l_index).PPL_ETC_COST1                   := NVL( cur_tasks_rec.PPL_ETC_COST_PC, 0 );
                l_rollup_table1(l_index).EQPMT_ETC_COST1                 := NVL( cur_tasks_rec.EQPMT_ETC_COST_PC, 0 );

                -- ETC Burden Cost in Project Functional Currency Rollup
                l_rollup_table1(l_index).ETC_COST2                       := NVL( cur_tasks_rec.OTH_ETC_COST_FC, 0 );
                l_rollup_table1(l_index).PPL_ETC_COST2                   := NVL( cur_tasks_rec.PPL_ETC_COST_FC, 0 );
                l_rollup_table1(l_index).EQPMT_ETC_COST2                 := NVL( cur_tasks_rec.EQPMT_ETC_COST_FC, 0 );

                     -- Sub Project ETC Effort Rollup
                l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_EFFORT1 := NVL( cur_tasks_rec.SUBPRJ_PPL_ETC_EFFORT, 0 );
                l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_EFFORT1 := NVL( cur_tasks_rec.SUBPRJ_EQPMT_ETC_EFFORT, 0 );

                     -- Sub Project ETC Cost in Project Currency Rollup
                l_rollup_table1(l_index).SUB_PRJ_ETC_COST1       := NVL( cur_tasks_rec.SUBPRJ_OTH_ETC_COST_PC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_COST1   := NVL( cur_tasks_rec.SUBPRJ_PPL_ETC_COST_PC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_COST1 := NVL( cur_tasks_rec.SUBPRJ_EQPMT_ETC_COST_PC, 0 );

                -- Sub Project ETC Cost in Project Functional Currency Rollup
                l_rollup_table1(l_index).SUB_PRJ_ETC_COST2       := NVL( cur_tasks_rec.SUBPRJ_OTH_ETC_COST_FC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_COST2   := NVL( cur_tasks_rec.SUBPRJ_PPL_ETC_COST_FC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_COST2 := NVL( cur_tasks_rec.SUBPRJ_EQPMT_ETC_COST_FC, 0 );

                       -- Earned Value and BAC Rollup
                l_rollup_table1(l_index).EARNED_VALUE1           := 0; --NVL( cur_tasks_rec.EARNED_VALUE, 0 );
                l_rollup_table1(l_index).BAC_VALUE1              := NVL( cur_tasks_rec.BAC_VALUE, 0 );

                l_rollup_table1(l_index).PERC_COMP_DERIVATIVE_CODE1 := l_task_derivation_code;

                --Bug 3614828 Begin
                        -- ETC Burden Cost in Transaction Currency Rollup
                l_rollup_table1(l_index).ETC_COST3                      := NVL( cur_tasks_rec.OTH_ETC_COST_TC, 0 );
                l_rollup_table1(l_index).PPL_ETC_COST3                  := NVL( cur_tasks_rec.PPL_ETC_COST_TC, 0 );
                l_rollup_table1(l_index).EQPMT_ETC_COST3                := NVL( cur_tasks_rec.EQPMT_ETC_COST_TC, 0 );

                -- ETC Raw Cost in Transaction Currency Rollup
                -- We do not use Transaction currency, so we can utilize this set to do actual effort rollup
                --l_rollup_table1(l_index).ETC_COST4                    := NVL( cur_tasks_rec.OTH_ETC_RAWCost_TC, 0 );
                --l_rollup_table1(l_index).PPL_ETC_COST4                        := NVL( cur_tasks_rec.PPL_ETC_RAWCOST_TC, 0 );
                --l_rollup_table1(l_index).EQPMT_ETC_COST4              := NVL( cur_tasks_rec.EQPMT_ETC_RAWCOST_TC, 0 );

                l_rollup_table1(l_index).ETC_COST4                      := NVL( cur_tasks_rec.PPL_ACT_EFFORT_TO_DATE, 0 );
                l_rollup_table1(l_index).PPL_ETC_COST4                  := NVL( cur_tasks_rec.EQPMT_ACT_EFFORT_TO_DATE, 0 );

                -- ETC Raw Cost in Project Currency Rollup
                l_rollup_table1(l_index).ETC_COST5                      := NVL( cur_tasks_rec.OTH_ETC_RAWCost_PC, 0 );
                l_rollup_table1(l_index).PPL_ETC_COST5                  := NVL( cur_tasks_rec.PPL_ETC_RAWCOST_PC, 0 );
                l_rollup_table1(l_index).EQPMT_ETC_COST5                := NVL( cur_tasks_rec.EQPMT_ETC_RAWCOST_PC, 0 );

                -- ETC Raw Cost in PRoject Functional Currency Rollup
                l_rollup_table1(l_index).ETC_COST6                      := NVL( cur_tasks_rec.OTH_ETC_RAWCost_FC, 0 );
                l_rollup_table1(l_index).PPL_ETC_COST6                  := NVL( cur_tasks_rec.PPL_ETC_RAWCOST_FC, 0 );
                l_rollup_table1(l_index).EQPMT_ETC_COST6                := NVL( cur_tasks_rec.EQPMT_ETC_RAWCOST_FC, 0 );


                -- Actual Burden Cost in Transaction Currency Rollup
                l_rollup_table1(l_index).SUB_PRJ_ETC_COST3              := NVL( cur_tasks_rec.OTH_ACT_COST_TO_DATE_TC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_COST3          := NVL( cur_tasks_rec.PPL_ACT_COST_TO_DATE_TC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_COST3        := NVL( cur_tasks_rec.EQPMT_ACT_COST_TO_DATE_TC, 0 );
                -- Actual Burden Cost in Project Currency Rollup
                l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_EFFORT3        := NVL( cur_tasks_rec.OTH_ACT_COST_TO_DATE_PC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_EFFORT3      := NVL( cur_tasks_rec.PPL_ACT_COST_TO_DATE_PC, 0 );
                l_rollup_table1(l_index).PPL_UNPLAND_EFFORT3            := NVL( cur_tasks_rec.EQPMT_ACT_COST_TO_DATE_PC, 0 );
                -- Actual Burden Cost in Project Functional Currency Rollup
                l_rollup_table1(l_index).SUB_PRJ_ETC_COST4              := NVL( cur_tasks_rec.OTH_ACT_COST_TO_DATE_FC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_COST4          := NVL( cur_tasks_rec.PPL_ACT_COST_TO_DATE_FC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_COST4        := NVL( cur_tasks_rec.EQPMT_ACT_COST_TO_DATE_FC, 0 );

                -- Actual Raw Cost in Transaction Currency Rollup
                l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_EFFORT4        := NVL( cur_tasks_rec.OTH_ACT_RAWCOST_TO_DATE_TC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_EFFORT4      := NVL( cur_tasks_rec.PPL_ACT_RAWCOST_TO_DATE_TC, 0 );
                l_rollup_table1(l_index).PPL_UNPLAND_EFFORT4            := NVL( cur_tasks_rec.EQPMT_ACT_RAWCOST_TO_DATE_TC, 0 );
                -- Actual Raw Cost in Project Currency Rollup
                l_rollup_table1(l_index).SUB_PRJ_ETC_COST5              := NVL( cur_tasks_rec.OTH_ACT_RAWCOST_TO_DATE_PC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_COST5          := NVL( cur_tasks_rec.PPL_ACT_RAWCOST_TO_DATE_PC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_COST5        := NVL( cur_tasks_rec.EQPMT_ACT_RAWCOST_TO_DATE_PC, 0 );
                -- Actual Raw Cost in Project Functional Currency Rollup
                l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_EFFORT5        := NVL( cur_tasks_rec.OTH_ACT_RAWCOST_TO_DATE_FC, 0 );
                l_rollup_table1(l_index).SUB_PRJ_EQPMT_ETC_EFFORT5      := NVL( cur_tasks_rec.PPL_ACT_RAWCOST_TO_DATE_FC, 0 );
                l_rollup_table1(l_index).PPL_UNPLAND_EFFORT5            := NVL( cur_tasks_rec.EQPMT_ACT_RAWCOST_TO_DATE_FC, 0 );

                --Bug 3614828 End

        -- Bug 3879461 : Oth_quantity_to_date and oth_etc_quantity was not getting rolled up.
                l_rollup_table1(l_index).SUB_PRJ_ETC_COST6              := NVL( cur_tasks_rec.Oth_quantity_to_date, 0 );
                l_rollup_table1(l_index).SUB_PRJ_PPL_ETC_COST6          := NVL( cur_tasks_rec.oth_etc_quantity, 0 );



                l_rollup_table1(l_index).DIRTY_FLAG1         := 'Y';
                l_rollup_table1(l_index).DIRTY_FLAG2         := 'Y';
                l_rollup_table1(l_index).DIRTY_FLAG3         := 'Y';
                l_rollup_table1(l_index).DIRTY_FLAG4         := 'Y';
                l_rollup_table1(l_index).DIRTY_FLAG5         := 'Y';
                l_rollup_table1(l_index).DIRTY_FLAG6         := 'Y';

                IF nvl( cur_tasks_rec.weighting_percentage, 0 ) = 0 THEN
                        l_action_allowed := 'N';
                END IF;

                IF g1_debug_mode  = 'Y' THEN
                     pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'Tasks l_action_allowed='||l_action_allowed, x_Log_Level=> 3);
                     pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'Tasks cur_tasks_rec.weighting_percentage='||cur_tasks_rec.weighting_percentage, x_Log_Level=> 3);
                END IF;

                l_rollup_table1(l_index).rollup_node1                    := l_action_allowed;
                l_rollup_table1(l_index).rollup_node2                    := l_action_allowed;
                l_rollup_table1(l_index).rollup_node3                    := l_action_allowed;
                l_rollup_table1(l_index).rollup_node4                    := l_action_allowed;
                l_rollup_table1(l_index).rollup_node5                    := l_action_allowed;
                l_rollup_table1(l_index).rollup_node6                    := l_action_allowed;

                l_rollup_table1(l_index).rollup_node1          := 'Y';
                l_rollup_table1(l_index).rollup_node2          := 'Y';
                l_rollup_table1(l_index).rollup_node3          := 'Y';
                l_rollup_table1(l_index).rollup_node4          := 'Y';
                l_rollup_table1(l_index).rollup_node5          := 'Y';
                l_rollup_table1(l_index).rollup_node6          := 'Y';

              END IF; --<<cur_tasks_rec.object_type = 'PA_TASKS'
            END LOOP;
        END IF;
        --end bug 3951982
*/

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'Calling GENERATE_SCHEDULE', x_Log_Level=> 3);
                FOR i IN 1..l_rollup_table1.count LOOP
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'OBJECT_TYPE ='||l_rollup_table1(i).OBJECT_TYPE, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'OBJECT_ID ='||l_rollup_table1(i).OBJECT_ID, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'PARENT_OBJECT_TYPE ='||l_rollup_table1(i).PARENT_OBJECT_TYPE, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'PARENT_OBJECT_ID ='||l_rollup_table1(i).PARENT_OBJECT_ID, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'WBS_LEVEL ='||l_rollup_table1(i).WBS_LEVEL, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'START_DATE1 ='||l_rollup_table1(i).START_DATE1||
                                ' FINISH_DATE1 ='||l_rollup_table1(i).FINISH_DATE1||
                                ' START_DATE2 ='||l_rollup_table1(i).START_DATE2||' FINISH_DATE2 ='||l_rollup_table1(i).FINISH_DATE2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'TASK_STATUS1 ='||l_rollup_table1(i).TASK_STATUS1||
                                ' TASK_STATUS2 ='||l_rollup_table1(i).TASK_STATUS2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'PROGRESS_STATUS_WEIGHT1 ='||l_rollup_table1(i).PROGRESS_STATUS_WEIGHT1||
                                ' PROGRESS_OVERRIDE1 ='||l_rollup_table1(i).PROGRESS_OVERRIDE1||' PROGRESS_STATUS_WEIGHT2 ='||l_rollup_table1(i).PROGRESS_STATUS_WEIGHT2||
                                        ' PROGRESS_OVERRIDE2 ='||l_rollup_table1(i).PROGRESS_OVERRIDE2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'PERCENT_COMPLETE1 ='||l_rollup_table1(i).PERCENT_COMPLETE1||
                                ' PERCENT_OVERRIDE1 ='||l_rollup_table1(i).PERCENT_OVERRIDE1||' PERCENT_COMPLETE2 ='||l_rollup_table1(i).PERCENT_COMPLETE2||
                                        ' PERCENT_OVERRIDE2 ='||l_rollup_table1(i).PERCENT_OVERRIDE2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'TASK_WEIGHT1 ='||l_rollup_table1(i).TASK_WEIGHT1||
                                ' TASK_WEIGHT2 ='||l_rollup_table1(i).TASK_WEIGHT2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'ROLLUP_NODE1 ='||l_rollup_table1(i).ROLLUP_NODE1||
                                ' DIRTY_FLAG1 ='||l_rollup_table1(i).DIRTY_FLAG1||' ROLLUP_NODE2 ='||l_rollup_table1(i).ROLLUP_NODE2||
                                        ' DIRTY_FLAG2 ='||l_rollup_table1(i).DIRTY_FLAG2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'ETC_Cost1 ='||l_rollup_table1(i).ETC_Cost1||
                                ' PPL_ETC_COST1 ='||l_rollup_table1(i).PPL_ETC_COST1||' EQPMT_ETC_COST1 ='||l_rollup_table1(i).EQPMT_ETC_COST1||
                                        ' ETC_Cost2 ='||l_rollup_table1(i).ETC_Cost2||' PPL_ETC_COST2 ='||l_rollup_table1(i).PPL_ETC_COST2||
                                                ' EQPMT_ETC_COST2 ='||l_rollup_table1(i).EQPMT_ETC_COST2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'REMAINING_EFFORT1 ='||l_rollup_table1(i).REMAINING_EFFORT1||
                                ' EQPMT_ETC_EFFORT1 ='||l_rollup_table1(i).EQPMT_ETC_EFFORT1||' REMAINING_EFFORT2 ='||l_rollup_table1(i).REMAINING_EFFORT2||
                                        ' EQPMT_ETC_EFFORT2 ='||l_rollup_table1(i).EQPMT_ETC_EFFORT2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'SUB_PRJ_ETC_Cost1 ='||l_rollup_table1(i).SUB_PRJ_ETC_Cost1||
                                ' SUB_PRJ_PPL_ETC_COST1 ='||l_rollup_table1(i).SUB_PRJ_PPL_ETC_COST1||' SUB_PRJ_EQPMT_ETC_COST1 ='||l_rollup_table1(i).SUB_PRJ_EQPMT_ETC_COST1||
                        ' SUB_PRJ_ETC_Cost2 ='||l_rollup_table1(i).SUB_PRJ_ETC_Cost2||' SUB_PRJ_PPL_ETC_COST2 ='||l_rollup_table1(i).SUB_PRJ_PPL_ETC_COST2||' SUB_PRJ_EQPMT_ETC_COST2 ='||l_rollup_table1(i).SUB_PRJ_EQPMT_ETC_COST2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT',
            x_Msg => 'SUB_PRJ_PPL_ETC_EFFORT1 ='||l_rollup_table1(i).SUB_PRJ_PPL_ETC_EFFORT1||' SUB_PRJ_EQPMT_ETC_EFFORT1 ='||l_rollup_table1(i).SUB_PRJ_EQPMT_ETC_EFFORT1||
                                ' SUB_PRJ_PPL_ETC_EFFORT2 ='||l_rollup_table1(i).SUB_PRJ_PPL_ETC_EFFORT2||' SUB_PRJ_EQPMT_ETC_EFFORT2 ='||l_rollup_table1(i).SUB_PRJ_EQPMT_ETC_EFFORT2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT',
            x_Msg => 'EARNED_VALUE1 ='||l_rollup_table1(i).EARNED_VALUE1||' BAC_VALUE1 ='||l_rollup_table1(i).BAC_VALUE1||' EARNED_VALUE2 ='||l_rollup_table1(i).EARNED_VALUE2||
                                ' BAC_VALUE2 ='||l_rollup_table1(i).BAC_VALUE2|| ' BAC_VALUE6 ='||l_rollup_table1(i).BAC_VALUE6, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'PERC_COMP_DERIVATIVE_CODE1 ='||l_rollup_table1(i).PERC_COMP_DERIVATIVE_CODE1||' PERC_COMP_DERIVATIVE_CODE2 ='
                                ||l_rollup_table1(i).PERC_COMP_DERIVATIVE_CODE2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'ETC_COST4 ='||l_rollup_table1(i).ETC_COST4||' PPL_ETC_COST4 ='
                                ||l_rollup_table1(i).PPL_ETC_COST4, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'ETC_COST4 ='||l_rollup_table1(i).ETC_COST4, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => '**********************************************************', x_Log_Level=> 3);
                END LOOP;
        END IF;
    -- Bug 4207995 : Commented partial_flags in the below call
        --Call generate schedule with the second table.
        PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE(
                 p_commit                                => p_commit
                ,p_debug_mode                           => 'Y'
                ,x_return_status                        => l_return_status
                ,x_msg_count                            => l_msg_count
                ,x_msg_data                             => l_msg_data
                ,x_process_number                       => l_process_number
		,p_number_digit                         => 2               --bug 3941447
                ,p_data_structure                       => l_rollup_table1
                ,p_process_flag1                        => 'Y'
                ,p_process_rollup_flag1                 => 'Y'
                ,p_process_progress_flag1               => 'Y'
                ,p_process_percent_flag1                => 'Y'
                ,p_process_effort_flag1                 => 'Y'
                ,p_process_task_status_flag1            => 'Y'
                ,p_process_flag2                        => 'Y'
                ,p_process_rollup_flag2                 => 'Y'
                ,p_process_progress_flag2               => 'Y'
                ,p_process_percent_flag2                => 'Y'
--                ,p_partial_process_flag1                => 'Y'
--                ,p_partial_process_flag2                => 'Y'
--                ,p_partial_dates_flag1                  => 'Y'
--                ,p_partial_dates_flag2                  => 'Y'
--                ,p_partial_progress_flag1               => 'Y'
--                ,p_partial_progress_flag2               => 'Y'
--                ,p_partial_task_status_flag1            => 'N'
--                ,p_partial_effort_flag1                 => 'Y'
--                ,p_partial_percent_flag1                => 'Y'
--                ,p_partial_percent_flag2                => 'Y'
--                ,p_process_ETC_Flag1                    => 'Y'
--                ,p_partial_ETC_Flag1                    => 'Y'
--                ,p_process_ETC_Flag2                    => 'Y'
--                ,p_partial_ETC_Flag2                    => 'Y'
                --Bug 3614828 Begin
                ,p_process_flag3                        => 'Y'
                ,p_process_rollup_flag3                 => 'Y'
                ,p_process_progress_flag3               => 'Y'
                ,p_process_percent_flag3                => 'Y'
                ,p_process_effort_flag3                 => 'Y'
                ,p_process_task_status_flag3            => 'Y'
                ,p_process_ETC_Flag3                    => 'Y'
--                ,p_partial_ETC_Flag3                    => 'Y'
                ,p_process_flag4                        => 'Y'
                ,p_process_rollup_flag4                 => 'Y'
                ,p_process_progress_flag4               => 'Y'
                ,p_process_percent_flag4                => 'Y'
                ,p_process_effort_flag4                 => 'Y'
                ,p_process_task_status_flag4            => 'Y'
                ,p_process_ETC_Flag4                    => 'Y'
--                ,p_partial_ETC_Flag4                    => 'Y'
                ,p_process_flag5                        => 'Y'
                ,p_process_rollup_flag5                 => 'Y'
                ,p_process_progress_flag5               => 'Y'
                ,p_process_percent_flag5                => 'Y'
                ,p_process_effort_flag5                 => 'Y'
                ,p_process_task_status_flag5            => 'Y'
                ,p_process_ETC_Flag5                    => 'Y'
--                ,p_partial_ETC_Flag5                    => 'Y'
                ,p_process_flag6                        => 'Y'
                ,p_process_rollup_flag6                 => 'Y'
                ,p_process_progress_flag6               => 'Y'
                ,p_process_percent_flag6                => 'Y'
                ,p_process_effort_flag6                 => 'Y'
                ,p_process_task_status_flag6            => 'Y'
                ,p_process_ETC_Flag6                    => 'Y'
--                ,p_partial_ETC_Flag6                    => 'Y'
                --Bug 3614828 End
                ,p_Rollup_Method                        => l_Rollup_Method
                );

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'After  GENERATE_SCHEDULE', x_Log_Level=> 3);
        END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                           p_msg_name       => l_msg_data
                                );
                x_msg_data := l_msg_data;
          x_return_status := 'E';
          RAISE  FND_API.G_EXC_ERROR;
        END IF;

        -- Updating the Rolled up Task Record
        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => '******Returned from Genertate Schedule ***', x_Log_Level=> 3);
                FOR i IN 1..l_rollup_table1.count LOOP
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'OBJECT_TYPE ='||l_rollup_table1(i).OBJECT_TYPE, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'OBJECT_ID ='||l_rollup_table1(i).OBJECT_ID, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'PARENT_OBJECT_TYPE ='||l_rollup_table1(i).PARENT_OBJECT_TYPE, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'PARENT_OBJECT_ID ='||l_rollup_table1(i).PARENT_OBJECT_ID, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'WBS_LEVEL ='||l_rollup_table1(i).WBS_LEVEL, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'START_DATE1 ='||l_rollup_table1(i).START_DATE1||
                                ' FINISH_DATE1 ='||l_rollup_table1(i).FINISH_DATE1||
                                ' START_DATE2 ='||l_rollup_table1(i).START_DATE2||' FINISH_DATE2 ='||l_rollup_table1(i).FINISH_DATE2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'TASK_STATUS1 ='||l_rollup_table1(i).TASK_STATUS1||
                                ' TASK_STATUS2 ='||l_rollup_table1(i).TASK_STATUS2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'PROGRESS_STATUS_WEIGHT1 ='||l_rollup_table1(i).PROGRESS_STATUS_WEIGHT1||
                                ' PROGRESS_OVERRIDE1 ='||l_rollup_table1(i).PROGRESS_OVERRIDE1||' PROGRESS_STATUS_WEIGHT2 ='||l_rollup_table1(i).PROGRESS_STATUS_WEIGHT2||
                                        ' PROGRESS_OVERRIDE2 ='||l_rollup_table1(i).PROGRESS_OVERRIDE2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'PERCENT_COMPLETE1 ='||l_rollup_table1(i).PERCENT_COMPLETE1||
                                ' PERCENT_OVERRIDE1 ='||l_rollup_table1(i).PERCENT_OVERRIDE1||' PERCENT_COMPLETE2 ='||l_rollup_table1(i).PERCENT_COMPLETE2||
                                        ' PERCENT_OVERRIDE2 ='||l_rollup_table1(i).PERCENT_OVERRIDE2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'TASK_WEIGHT1 ='||l_rollup_table1(i).TASK_WEIGHT1||
                                ' TASK_WEIGHT2 ='||l_rollup_table1(i).TASK_WEIGHT2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'ROLLUP_NODE1 ='||l_rollup_table1(i).ROLLUP_NODE1||
                                ' DIRTY_FLAG1 ='||l_rollup_table1(i).DIRTY_FLAG1||' ROLLUP_NODE2 ='||l_rollup_table1(i).ROLLUP_NODE2||
                                        ' DIRTY_FLAG2 ='||l_rollup_table1(i).DIRTY_FLAG2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'ETC_Cost1 ='||l_rollup_table1(i).ETC_Cost1||
                                ' PPL_ETC_COST1 ='||l_rollup_table1(i).PPL_ETC_COST1||' EQPMT_ETC_COST1 ='||l_rollup_table1(i).EQPMT_ETC_COST1||
                                        ' ETC_Cost2 ='||l_rollup_table1(i).ETC_Cost2||' PPL_ETC_COST2 ='||l_rollup_table1(i).PPL_ETC_COST2||
                                                ' EQPMT_ETC_COST2 ='||l_rollup_table1(i).EQPMT_ETC_COST2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'REMAINING_EFFORT1 ='||l_rollup_table1(i).REMAINING_EFFORT1||
                                ' EQPMT_ETC_EFFORT1 ='||l_rollup_table1(i).EQPMT_ETC_EFFORT1||' REMAINING_EFFORT2 ='||l_rollup_table1(i).REMAINING_EFFORT2||
                                        ' EQPMT_ETC_EFFORT2 ='||l_rollup_table1(i).EQPMT_ETC_EFFORT2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'SUB_PRJ_ETC_Cost1 ='||l_rollup_table1(i).SUB_PRJ_ETC_Cost1||
                                ' SUB_PRJ_PPL_ETC_COST1 ='||l_rollup_table1(i).SUB_PRJ_PPL_ETC_COST1||' SUB_PRJ_EQPMT_ETC_COST1 ='||l_rollup_table1(i).SUB_PRJ_EQPMT_ETC_COST1||
                        ' SUB_PRJ_ETC_Cost2 ='||l_rollup_table1(i).SUB_PRJ_ETC_Cost2||' SUB_PRJ_PPL_ETC_COST2 ='||l_rollup_table1(i).SUB_PRJ_PPL_ETC_COST2||' SUB_PRJ_EQPMT_ETC_COST2 ='||l_rollup_table1(i).SUB_PRJ_EQPMT_ETC_COST2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT',
			x_Msg => 'SUB_PRJ_PPL_ETC_EFFORT1 ='||l_rollup_table1(i).SUB_PRJ_PPL_ETC_EFFORT1||' SUB_PRJ_EQPMT_ETC_EFFORT1 ='||l_rollup_table1(i).SUB_PRJ_EQPMT_ETC_EFFORT1||
                                ' SUB_PRJ_PPL_ETC_EFFORT2 ='||l_rollup_table1(i).SUB_PRJ_PPL_ETC_EFFORT2||' SUB_PRJ_EQPMT_ETC_EFFORT2 ='||l_rollup_table1(i).SUB_PRJ_EQPMT_ETC_EFFORT2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT',
			x_Msg => 'EARNED_VALUE1 ='||l_rollup_table1(i).EARNED_VALUE1||' BAC_VALUE1 ='||l_rollup_table1(i).BAC_VALUE1||' EARNED_VALUE2 ='||l_rollup_table1(i).EARNED_VALUE2||
                                ' BAC_VALUE2 ='||l_rollup_table1(i).BAC_VALUE2||' BAC_VALUE6 ='||l_rollup_table1(i).BAC_VALUE6, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'PERC_COMP_DERIVATIVE_CODE1 ='||l_rollup_table1(i).PERC_COMP_DERIVATIVE_CODE1||' PERC_COMP_DERIVATIVE_CODE2 ='
                                ||l_rollup_table1(i).PERC_COMP_DERIVATIVE_CODE2, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'ETC_COST4 ='||l_rollup_table1(i).ETC_COST4||' PPL_ETC_COST4 ='
                                ||l_rollup_table1(i).PPL_ETC_COST4, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'ETC_COST4 ='||l_rollup_table1(i).ETC_COST4, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => '**********************************************************', x_Log_Level=> 3);
                END LOOP;
    END IF;

        l_percent_complete_id := null;

        l_total_tasks := l_rollup_table1.count; -- Actually it is not the tasks count, it is count of all the objects.

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_rollup_table1.count ='||l_rollup_table1.count, x_Log_Level=> 3);
                FOR i IN 1..l_total_tasks LOOP
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_rollup_table1(i).object_id ='||l_rollup_table1(i).object_id, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_rollup_table1(i).object_type ='||l_rollup_table1(i).object_type, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_rollup_table1(i).percent_complete1 ='||l_rollup_table1(i).percent_complete1, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_rollup_table1(i).task_statusl ='||l_rollup_table1(i).task_status1, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_rollup_table1(i).ETC_COST4 ='||l_rollup_table1(i).ETC_COST4, x_Log_Level=> 3);
                END LOOP;
        END IF;

        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'Getting Periods', x_Log_Level=> 3);
        BEGIN
                l_prog_pa_period_name := nvl(PA_PROGRESS_UTILS.Prog_Get_Pa_Period_Name(p_as_of_date),null);
                l_prog_gl_period_name := nvl(PA_PROGRESS_UTILS.Prog_Get_GL_Period_Name(p_as_of_date),null);
        EXCEPTION
                WHEN OTHERS THEN
                        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_FP_INVALID_DATE_RANGE');
                        x_msg_data := 'PA_FP_INVALID_DATE_RANGE';
                        x_return_status := 'E';
                        x_msg_count := fnd_msg_pub.count_msg;
                        RAISE  FND_API.G_EXC_ERROR;
        END ;

        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'After Getting Periods', x_Log_Level=> 3);


        IF l_total_tasks > 0 THEN
                FOR i in 1..l_total_tasks LOOP
                        IF p_task_version_id = l_rollup_table1(i).object_id AND l_rollup_table1(i).object_type = 'PA_TASKS'
                        THEN
                                IF g1_debug_mode  = 'Y' THEN
                                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_rollup_table1(i).object_id='||l_rollup_table1(i).object_id, x_Log_Level=> 3);
                                END IF;

                                l_BASE_PERCENT_COMP_DERIV_CODE := l_rollup_table1(i).PERC_COMP_DERIVATIVE_CODE1;
                                l_eff_rollup_status_code := null;
                                l_progress_status_code := null;

                                OPEN cur_status( to_char(l_rollup_table1(i).progress_status_weight1) ); --get the eff rollup status
                                FETCH cur_status INTO l_eff_rollup_status_code;
                                CLOSE cur_status;

                                OPEN cur_status( to_char(l_rollup_table1(i).progress_status_weight2) );  --get the base prog status
                                FETCH cur_status INTO l_progress_status_code;
                                CLOSE cur_status;

                                IF g1_debug_mode  = 'Y' THEN
                                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_eff_rollup_status_code='||l_eff_rollup_status_code, x_Log_Level=> 3);
                                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_progress_status_code='||l_progress_status_code, x_Log_Level=> 3);
                                END IF;



                                l_rolled_up_per_comp := null;
                                l_rolled_up_prog_stat := null;
                                l_rolled_up_base_prog_stat := null;
                                l_rolled_up_prog_stat := null;
                                l_remaining_effort1 := null;
                                l_percent_complete1 := null;
                                l_ETC_Cost_PC    := null;
                                l_PPL_ETC_COST_PC := null;
                                l_EQPMT_ETC_COST_PC := null;
                                l_ETC_Cost_FC       := null;
                                l_PPL_ETC_COST_FC   := null;
                                l_EQPMT_ETC_COST_FC := null;
                                l_EQPMT_ETC_EFFORT := null;
                                l_SUB_PRJ_ETC_COST_PC := null;
                                l_SUB_PRJ_PPL_ETC_COST_PC := null;
                                l_SUB_PRJ_EQPMT_ETC_COST_PC := null;
                                l_SUB_PRJ_ETC_COST_FC := null;
                                l_SUB_PRJ_PPL_ETC_COST_FC := null;
                                l_SUB_PRJ_EQPMT_ETC_COST_FC := null;
                                l_SUB_PRJ_PPL_ETC_EFFORT := null;
                                l_SUB_PRJ_EQPMT_ETC_EFFORT := null;
                                l_BAC_VALUE1 := null;
                                l_EARNED_VALUE1 := null;
                                l_remaining_effort1 := null;
                                l_EQPMT_ETC_EFFORT := null;
                                l_OTH_ACT_COST_TO_DATE_PC := null;
                                l_PPL_ACT_COST_TO_DATE_PC := null;
                                l_EQPMT_ACT_COST_TO_DATE_PC := null;
                                l_OTH_ACT_COST_TO_DATE_FC := null;
                                l_PPL_ACT_COST_TO_DATE_FC := null;
                                l_EQPMT_ACT_COST_TO_DATE_FC := null;
                                l_PPL_ACT_EFFORT_TO_DATE := null;
                                l_EQPMT_ACT_EFFORT_TO_DATE := null;
                                l_cur_pa_rollup1_rec := null;
                                l_cur_rollup_rec := null;
                                -- Bug 3621404 : Raw Cost Changes
                                l_OTH_ACT_RAWCOST_TO_DATE_PC := null;
                                l_PPL_ACT_RAWCOST_TO_DATE_PC := null;
                                l_EQPMT_ACT_RAWCOST_TO_DATE_PC := null;
                                l_OTH_ACT_RAWCOST_TO_DATE_FC := null;
                                l_PPL_ACT_RAWCOST_TO_DATE_FC := null;
                                l_EQPMT_ACT_RAWCOST_TO_DATE_FC := null;
                                l_ETC_RAWCost_PC := null;
                                l_PPL_ETC_RAWCOST_PC := null;
                                l_EQPMT_ETC_RAWCOST_PC := null;
                                l_ETC_RAWCost_FC := null;
                                l_PPL_ETC_RAWCOST_FC := null;
                                l_EQPMT_ETC_RAWCOST_FC := null;
				-- Bug 3879461 : Oth_quantity_to_date and oth_etc_quantity was not getting rolled up.
				l_Oth_quantity_to_date := null;
				l_oth_etc_quantity := null;
				-- Bug 3956299 Begin
				l_actual_start_date := l_rollup_table1(i).start_date1;
				l_actual_finish_date := l_rollup_table1(i).finish_date1;
				l_estimated_start_date := l_rollup_table1(i).start_date2;
				l_estimated_finish_date := l_rollup_table1(i).finish_date2;
				-- Bug 3956299 End

                                -- Bug 5675437
                                l_cur_rollup_rec3 := null;

                                OPEN cur_pa_rollup1(p_task_id);
                                FETCH  cur_pa_rollup1 INTO l_cur_pa_rollup1_rec;
                                CLOSE cur_pa_rollup1;

                                l_rolled_up_per_comp :=  l_cur_pa_rollup1_rec.completed_percentage;
                                l_rolled_up_prog_stat := l_cur_pa_rollup1_rec.progress_status_code;
                                IF g1_debug_mode  = 'Y' THEN
                                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_rolled_up_per_comp='||l_rolled_up_per_comp, x_Log_Level=> 3);
                                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_rolled_up_prog_stat='||l_rolled_up_prog_stat, x_Log_Level=> 3);
                                END IF;
                                -- 4490532 : changed from IS_LOWEST_TASK to is_summary_task_or_structure
				-- 4533112 : Now base_progress_status_code is not used
				/*
                                IF PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(p_task_version_id )= 'Y'
                                THEN
                                        -- l_rolled_up_base_per_comp := nvl(l_cur_pa_rollup1_rec.base_percent_complete,0);
                                        l_rolled_up_base_prog_stat := l_cur_pa_rollup1_rec.base_progress_status_code;
                                ELSE
					-- l_rolled_up_base_per_comp := nvl(l_rollup_table1(i).percent_complete2,0);
                                        l_rolled_up_base_prog_stat := l_progress_status_code;
                                END IF;
				*/
				l_rolled_up_base_prog_stat := l_cur_pa_rollup1_rec.base_progress_status_code;

                                --Check whether there exists any rollup record for the task.
                                --if exists then update otherwise create.
                                l_PROGRESS_ROLLUP_ID := PA_PROGRESS_UTILS.get_prog_rollup_id(
                                                   p_project_id                 => p_project_id
                                                  ,p_object_id                  => p_task_id
                                                  ,p_object_type                => 'PA_TASKS'
                                                  ,p_object_version_id          => p_task_version_id
                                                  ,p_as_of_date                 => p_as_of_date
                                                  ,p_structure_type             => 'WORKPLAN'
                                                  ,p_structure_version_id       => l_structure_version_id
						  ,p_proj_element_id            => p_task_id
						  ,p_action                     => 'SAVE' -- Bug 3879461
                                                  ,x_record_version_number      => l_rollup_rec_ver_number
                                                );

                                IF g1_debug_mode  = 'Y' THEN
                                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_PROGRESS_ROLLUP_ID='||l_PROGRESS_ROLLUP_ID, x_Log_Level=> 3);
                                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_rollup_rec_ver_number='||l_rollup_rec_ver_number, x_Log_Level=> 3);
                                END IF;


				--bug 3949093, round the values
                                --l_percent_complete1 := nvl(l_rollup_table1(i).percent_complete1,0);
                                --l_remaining_effort1 := nvl(l_rollup_table1(i).remaining_effort1,0);

				-- 4392189 : Program Reporting Changes - Phase 2
				-- Having Set2 columns to get Project level % complete

                                l_percent_complete1 := nvl(round(l_rollup_table1(i).percent_complete1,8),0); --Bug 6854114
                                -- 4506461 l_percent_complete2 := nvl(round(l_rollup_table1(i).percent_complete2,2),0);
                                l_base_pc_temp      := nvl(round(l_rollup_table1(i).percent_complete2,8),0); --Bug 6854114
                                l_remaining_effort1 := nvl(round(l_rollup_table1(i).remaining_effort1,5),0);
                                --bug 3949093, end

				-- Bug 4506461 Begin
				l_percent_complete2 := nvl(l_override_pc_temp,l_percent_complete1);
				-- 4540890 : Removed l_subproject_found check from below
				--IF  l_subproject_found = 'Y' THEN
				l_rederive_base_pc := 'N';
				OPEN c_get_any_childs_have_subprj(l_rollup_table1(i).object_id);
				FETCH c_get_any_childs_have_subprj INTO l_rederive_base_pc;
				CLOSE c_get_any_childs_have_subprj;
				IF nvl(l_rederive_base_pc,'N') = 'Y' THEN
					l_percent_complete2 := l_base_pc_temp;
				END IF;
                --END IF;
                -- Bug 4506461 End


                                --do not rollup on-hold task status. We dont need to worry about
                                --cancelled bcoz they are not selected.
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_rollup_table1(i).task_statusl ='||l_rollup_table1(i).task_status1, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_rollup_table1(i).percent_complete1 ='||l_rollup_table1(i).percent_complete1, x_Log_Level=> 3);

                -- Bug 3922325 : Moved the code for status defaulting and updating after Actual is derived

                --Bug 3614828 Begin

                                l_BAC_VALUE1 := nvl(l_rollup_table1(i).BAC_VALUE1,0); -- Bug 3764224
                --bug 3949093, rund the earned value
                                --l_EARNED_VALUE1 := nvl(l_rollup_table1(i).EARNED_VALUE1,0); -- Bug 3764224

                IF g1_debug_mode  = 'Y' THEN
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_rollup_table1(i).summary_object_flag='||l_rollup_table1(i).summary_object_flag, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_rollup_table1(i).BAC_VALUE1='||l_rollup_table1(i).BAC_VALUE1, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT', x_Msg => 'l_rollup_table1(i).EARNED_VALUE1='||l_rollup_table1(i).EARNED_VALUE1, x_Log_Level=> 3);
                END IF;

                l_EARNED_VALUE1 := l_rollup_table1(i).EARNED_VALUE1;

                IF p_wp_rollup_method = 'EFFORT'
                THEN
                    l_EARNED_VALUE1 := nvl(round(l_EARNED_VALUE1, 5),0);
                ELSE
                    l_EARNED_VALUE1 := nvl(pa_currency.round_trans_currency_amt(l_EARNED_VALUE1, l_prj_currency_code),0);
                END IF;
                --bug 3949093, end

                                l_OTH_ACT_COST_TO_DATE_PC := l_rollup_table1(i).SUB_PRJ_PPL_ETC_EFFORT3;
                                l_PPL_ACT_COST_TO_DATE_PC := l_rollup_table1(i).SUB_PRJ_EQPMT_ETC_EFFORT3;
                                l_EQPMT_ACT_COST_TO_DATE_PC := l_rollup_table1(i).PPL_UNPLAND_EFFORT3;
                                l_OTH_ACT_COST_TO_DATE_FC := l_rollup_table1(i).SUB_PRJ_ETC_COST4;
                                l_PPL_ACT_COST_TO_DATE_FC := l_rollup_table1(i).SUB_PRJ_PPL_ETC_COST4;
                                l_EQPMT_ACT_COST_TO_DATE_FC := l_rollup_table1(i).SUB_PRJ_EQPMT_ETC_COST4;
                                l_PPL_ACT_EFFORT_TO_DATE := l_rollup_table1(i).ETC_COST4;
                                l_EQPMT_ACT_EFFORT_TO_DATE := l_rollup_table1(i).PPL_ETC_COST4;
                                l_ETC_Cost_PC := l_rollup_table1(i).ETC_COST1;
                                l_PPL_ETC_COST_PC := l_rollup_table1(i).PPL_ETC_COST1;
                                l_EQPMT_ETC_COST_PC := l_rollup_table1(i).EQPMT_ETC_COST1;
                                l_ETC_Cost_FC := l_rollup_table1(i).ETC_COST2;
                                l_PPL_ETC_COST_FC := l_rollup_table1(i).PPL_ETC_COST2;
                                l_EQPMT_ETC_COST_FC := l_rollup_table1(i).EQPMT_ETC_COST2;
                                l_remaining_effort1 := l_rollup_table1(i).REMAINING_EFFORT1;
                                l_EQPMT_ETC_EFFORT := l_rollup_table1(i).EQPMT_ETC_EFFORT1;
                                l_OTH_ACT_RAWCOST_TO_DATE_PC := l_rollup_table1(i).SUB_PRJ_ETC_COST5;
                                l_PPL_ACT_RAWCOST_TO_DATE_PC := l_rollup_table1(i).SUB_PRJ_PPL_ETC_COST5;
                                l_EQPMT_ACT_RAWCOST_TO_DATE_PC := l_rollup_table1(i).SUB_PRJ_EQPMT_ETC_COST5;
                                l_OTH_ACT_RAWCOST_TO_DATE_FC := l_rollup_table1(i).SUB_PRJ_PPL_ETC_EFFORT5;
                                l_PPL_ACT_RAWCOST_TO_DATE_FC := l_rollup_table1(i).SUB_PRJ_EQPMT_ETC_EFFORT5;
                                l_EQPMT_ACT_RAWCOST_TO_DATE_FC := l_rollup_table1(i).PPL_UNPLAND_EFFORT5;
                                l_ETC_RAWCost_PC := l_rollup_table1(i).ETC_COST5;
                                l_PPL_ETC_RAWCOST_PC := l_rollup_table1(i).PPL_ETC_COST5;
                                l_EQPMT_ETC_RAWCOST_PC := l_rollup_table1(i).EQPMT_ETC_COST5;
                                l_ETC_RAWCost_FC := l_rollup_table1(i).ETC_COST6;
                                l_PPL_ETC_RAWCOST_FC := l_rollup_table1(i).PPL_ETC_COST6;
                                l_EQPMT_ETC_RAWCOST_FC := l_rollup_table1(i).EQPMT_ETC_COST6;
                -- Bug 3879461 : Oth_quantity_to_date and oth_etc_quantity was not getting rolled up.
                l_Oth_quantity_to_date := l_rollup_table1(i).SUB_PRJ_ETC_COST6;
                l_oth_etc_quantity := l_rollup_table1(i).SUB_PRJ_PPL_ETC_COST6;


                                --Bug 3614828 End

                -- Bug 3922325 : Moved here the code from above
                -- Begin


                -- Bug 3879461 Begin : Commented this logic for defaulting status and added new
                                /*IF (l_percent_complete1 > 0) THEN
                                        l_status_code := null;

                                        OPEN cur_task_status( to_char(l_rollup_table1(i).task_status1) );
                                        FETCH cur_task_status INTO l_status_code;
                                        CLOSE cur_task_status;

                                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_status_code ='||l_status_code, x_Log_Level=> 3);

                                        IF (l_percent_complete1 = 100 AND l_task_system_status_code = 'NOT_STARTED')
                                        THEN
                                                l_status_code := '127';
                                        ELSIF (l_percent_complete1 > 0 AND l_task_system_status_code = 'NOT_STARTED')
                                        THEN
                                                l_status_code := '125';
                                        END IF;


                                        UPDATE pa_percent_completes
                                        SET status_code = l_status_code
                                        WHERE object_id = p_task_id
                                        AND project_id = p_project_id
                                        AND PA_PROGRESS_UTILS.get_system_task_status( status_code ) NOT IN ( 'CANCELLED' )
                                        AND structure_type = 'WORKPLAN'
                                        AND current_flag = 'N' and published_flag = 'N';

                                END IF;*/
                -- If Actual Exists or Deliverable is in progress then task shd be In PRogress
                l_actual_exists := 'N';
                ---5726773  changed '>0' to '<>0'
 	        IF (l_PPL_ACT_EFFORT_TO_DATE <> 0 OR l_EQPMT_ACT_EFFORT_TO_DATE <>0 OR l_OTH_ACT_COST_TO_DATE_PC <> 0) THEN
                                    IF g1_debug_mode  = 'Y' THEN
                                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'Actual Exists', x_Log_Level=> 3);
                    END IF;
                    l_actual_exists := 'Y';
                END IF;
                OPEN c_get_dlv_status;
                FETCH c_get_dlv_status INTO l_actual_exists;
                CLOSE c_get_dlv_status;

                                IF g1_debug_mode  = 'Y' THEN
                                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_actual_exists='||l_actual_exists, x_Log_Level=> 3);
                                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'Defaulting Status and Actual Dates', x_Log_Level=> 3);
                                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_percent_complete1='||l_percent_complete1, x_Log_Level=> 3);
                                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_rolled_up_per_comp='||l_rolled_up_per_comp, x_Log_Level=> 3);
                                END IF;


                                IF  (  ( nvl(l_rollup_table1(i).task_status1,0) <> 0 )
                                       OR
                                      ( l_percent_complete1 > 0 OR l_rolled_up_per_comp > 0 )
                      OR l_actual_exists = 'Y'
                                     ) THEN

                                        OPEN  c_get_object_status ( p_project_id, p_task_id);
                                        FETCH c_get_object_status INTO l_existing_object_status;
                                        CLOSE c_get_object_status;

                    l_status_code := l_existing_object_status;

                                        IF ( nvl(l_rollup_table1(i).task_status1,0) <> 0 )
                                        THEN
                        OPEN  cur_task_status ( to_char(l_rollup_table1(i).task_status1) );
                                                FETCH cur_task_status INTO l_status_code;
                                                CLOSE cur_task_status;
                                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ROLLUP_PROGRESS_PVT', x_Msg => 'l_status_code ='||l_status_code, x_Log_Level=> 3);
                    END IF; -- Bug 3956299 : Reduced scope of IF.
                        -- Now Defaulting of Status will happen even if the status is returned by Scheuling API, but it is wrong
                                        --ELSE
                                        --l_task_system_status_code := PA_PROGRESS_UTILS.get_system_task_status( l_existing_object_status );  Bug 3956299
                                        l_task_system_status_code := PA_PROGRESS_UTILS.get_system_task_status( l_status_code ); -- Bug 3956299

                                    IF g1_debug_mode  = 'Y' THEN
                                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_status_code='||l_status_code, x_Log_Level=> 3);
                                    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_existing_object_status='||l_existing_object_status, x_Log_Level=> 3);
                                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'l_task_system_status_code='||l_task_system_status_code, x_Log_Level=> 3);
                    END IF;


                                    IF ( NVL(l_rolled_up_per_comp, l_percent_complete1) = 100 AND l_task_system_status_code <> 'COMPLETED')
                                        THEN
                                            l_status_code := '127';
                        l_task_system_status_code := 'COMPLETED';
                    -- In the below check, Completed is also added as Scheduling API may return status as COMPLETED but % complete may not be as 100
                            ELSIF (((NVL(l_rolled_up_per_comp, l_percent_complete1) > 0 AND NVL(l_rolled_up_per_comp, l_percent_complete1) < 100)) AND l_task_system_status_code IN ('NOT_STARTED','COMPLETED'))
                                        THEN
                                            l_status_code := '125';
                        l_task_system_status_code := 'IN_PROGRESS';
                        l_actual_finish_date := null;
                    -- This is done to first time make task In Progress if any sub-objects are in Progress
                            ELSIF (l_actual_exists ='Y' AND l_task_system_status_code = 'NOT_STARTED')
                                        THEN
                                            l_status_code := '125';
						l_task_system_status_code := 'IN_PROGRESS';
                        l_actual_finish_date := null;
                                        END IF;
                                        --END IF;

                                    IF g1_debug_mode  = 'Y' THEN
                                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'After Defaulting l_status_code='||l_status_code, x_Log_Level=> 3);
                                        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'After Defaulting l_task_system_status_code='||l_task_system_status_code, x_Log_Level=> 3);
                    END IF;


                    -- Bug 3956299 Begin
                    OPEN c_get_dates (p_project_id, p_task_version_id);
                    FETCH c_get_dates INTO l_tsk_scheduled_start_date, l_tsk_scheduled_finish_date;
                    CLOSE c_get_dates;
                    /* Bug 3922325  : Date defaulting should be based on Status rather % complete
                    IF l_actual_start_date IS NULL AND NVL(l_rolled_up_per_comp, l_percent_complete1) > 0 THEN
                         l_actual_start_date := nvl(l_estimated_start_date,l_tsk_scheduled_start_date);
                    END IF;
                    IF l_actual_start_date IS NULL AND NVL(l_rolled_up_per_comp, l_percent_complete1) > 0 AND NVL(l_rolled_up_per_comp, l_percent_complete1) < 100 THEN
                         l_actual_finish_date := null;
                    END IF;
                    IF l_actual_finish_date IS NULL AND NVL(l_rolled_up_per_comp, l_percent_complete1) = 100 THEN
                         l_actual_finish_date := nvl(l_estimated_finish_date,l_tsk_scheduled_finish_date);
                    END IF;
                    */
                    IF l_actual_start_date IS NULL AND l_task_system_status_code = 'IN_PROGRESS' THEN
                        l_actual_start_date := nvl(l_estimated_start_date,l_tsk_scheduled_start_date);
                        l_actual_finish_date := to_date(null);
                    END IF;
                    -- Bug 4232099 : added folling IF
                    IF l_actual_finish_date IS NOT NULL AND l_task_system_status_code = 'IN_PROGRESS' THEN
                        l_actual_finish_date := to_date(null);
                    END IF;
                    IF l_actual_start_date IS NULL AND l_task_system_status_code = 'COMPLETED' THEN
                        l_actual_start_date := nvl(l_estimated_start_date,l_tsk_scheduled_start_date);
                    END IF;
                    IF l_actual_finish_date IS NULL AND l_task_system_status_code = 'COMPLETED' THEN
                        l_actual_finish_date := nvl(l_estimated_finish_date,l_tsk_scheduled_finish_date);
                    END IF;

                    IF l_actual_start_date IS NOT NULL AND l_actual_finish_date IS NOT NULL THEN
                        IF l_actual_finish_date < l_actual_start_date THEN
                            IF TRUNC(SYSDATE) < l_actual_start_date THEN
                                l_actual_finish_date := l_actual_start_date;
                            ELSE
                                l_actual_finish_date := TRUNC(SYSDATE);
                            END IF;
                        END IF;
                    END IF;
                -- Bug 3956299 End

                                        UPDATE pa_percent_completes
                                        SET status_code = l_status_code
                    , actual_start_date = l_actual_start_date -- Bug 3956299
                    , actual_finish_date = l_actual_finish_date -- Bug 3956299
                                        WHERE object_id = p_task_id
                                        AND project_id = p_project_id
                                        AND PA_PROGRESS_UTILS.get_system_task_status( status_code ) NOT IN ( 'CANCELLED' )
                                        AND structure_type = 'WORKPLAN'
                                        AND current_flag = 'N' and published_flag = 'N';
                                END IF;
                -- Bug 3879461 End
                -- Bug 3922325 End


                                --Bug 3614828 Begin
                                /* In Save action, Actuals and ETC is not to be read from PJI.
                                BEGIN
                                       SELECT
                        PERIOD_NAME
                                                , ACT_PRJ_BRDN_COST-ACT_PRJ_EQUIP_BRDN_COST-ACT_PRJ_LABOR_BRDN_COST
                                                , ACT_PRJ_LABOR_BRDN_COST
                                                , ACT_PRJ_EQUIP_BRDN_COST
                                                , ACT_POU_BRDN_COST-ACT_POU_LABOR_BRDN_COST-ACT_POU_EQUIP_BRDN_COST
                                                , ACT_POU_LABOR_BRDN_COST
                                                , ACT_POU_EQUIP_BRDN_COST
                                                , ACT_LABOR_HRS
                                                , ACT_EQUIP_HRS
                                                , ETC_PRJ_BRDN_COST-ETC_PRJ_EQUIP_BRDN_COST-ETC_PRJ_LABOR_BRDN_COST
                                                , ETC_PRJ_LABOR_BRDN_COST
                                                , ETC_PRJ_EQUIP_BRDN_COST
                                                , ETC_POU_BRDN_COST-ETC_POU_LABOR_BRDN_COST-ETC_POU_EQUIP_BRDN_COST
                                                , ETC_POU_LABOR_BRDN_COST
                                                , ETC_POU_EQUIP_BRDN_COST
                                                , ETC_LABOR_HRS
                                                , ETC_EQUIP_HRS
                                                , ACT_PRJ_RAW_COST-ACT_PRJ_EQUIP_RAW_COST-ACT_PRJ_LABOR_RAW_COST
                                                , ACT_PRJ_LABOR_RAW_COST
                                                , ACT_PRJ_EQUIP_RAW_COST
                                                , ACT_POU_RAW_COST-ACT_POU_LABOR_RAW_COST-ACT_POU_EQUIP_RAW_COST
                                                , ACT_POU_LABOR_RAW_COST
                                                , ACT_POU_EQUIP_RAW_COST
                                                , ETC_PRJ_RAW_COST-ETC_PRJ_EQUIP_RAW_COST-ETC_PRJ_LABOR_RAW_COST
                                                , ETC_PRJ_LABOR_RAW_COST
                                                , ETC_PRJ_EQUIP_RAW_COST
                                                , ETC_POU_RAW_COST-ETC_POU_LABOR_RAW_COST-ETC_POU_EQUIP_RAW_COST
                                                , ETC_POU_LABOR_RAW_COST
                                                , ETC_POU_EQUIP_RAW_COST
                                                ,EQUIPMENT_HOURS
                                                ,POU_LABOR_BRDN_COST
                                                ,PRJ_LABOR_BRDN_COST
                                                ,POU_EQUIP_BRDN_COST
                                                ,PRJ_EQUIP_BRDN_COST
                                                ,POU_LABOR_RAW_COST
                                                ,PRJ_LABOR_RAW_COST
                                                ,POU_EQUIP_RAW_COST
                                                ,PRJ_EQUIP_RAW_COST
                                        INTO    l_PERIOD_NAME
                                                , l_OTH_ACT_COST_TO_DATE_PC
                                                , l_PPL_ACT_COST_TO_DATE_PC
                                                , l_EQPMT_ACT_COST_TO_DATE_PC
                                                , l_OTH_ACT_COST_TO_DATE_FC
                                                , l_PPL_ACT_COST_TO_DATE_FC
                                                , l_EQPMT_ACT_COST_TO_DATE_FC
                                                , l_PPL_ACT_EFFORT_TO_DATE
                                                , l_EQPMT_ACT_EFFORT_TO_DATE
                                                , l_ETC_Cost_PC
                                                , l_PPL_ETC_COST_PC
                                                , l_EQPMT_ETC_COST_PC
                                                , l_ETC_Cost_FC
                                                , l_PPL_ETC_COST_FC
                                                , l_EQPMT_ETC_COST_FC
                                                , l_remaining_effort1
                                                , l_EQPMT_ETC_EFFORT
                                                , l_OTH_ACT_RAWCOST_TO_DATE_PC
                                                , l_PPL_ACT_RAWCOST_TO_DATE_PC
                                                , l_EQPMT_ACT_RAWCOST_TO_DATE_PC
                                                , l_OTH_ACT_RAWCOST_TO_DATE_FC
                                                , l_PPL_ACT_RAWCOST_TO_DATE_FC
                                                , l_EQPMT_ACT_RAWCOST_TO_DATE_FC
                                                , l_ETC_RAWCost_PC
                                                , l_PPL_ETC_RAWCOST_PC
                                                , l_EQPMT_ETC_RAWCOST_PC
                                                , l_ETC_RAWCost_FC
                                                , l_PPL_ETC_RAWCOST_FC
                                                , l_EQPMT_ETC_RAWCOST_FC
                                                ,l_EQUIPMENT_HOURS
                                                ,l_POU_LABOR_BRDN_COST
                                                ,l_PRJ_LABOR_BRDN_COST
                                                ,l_POU_EQUIP_BRDN_COST
                                                ,l_PRJ_EQUIP_BRDN_COST
                                                ,l_POU_LABOR_RAW_COST
                                                ,l_PRJ_LABOR_RAW_COST
                                                ,l_POU_EQUIP_RAW_COST
                                                ,l_PRJ_EQUIP_RAW_COST
                                         FROM PJI_FM_XBS_ACCUM_TMP1
                                         WHERE project_id = p_project_id
                                         AND struct_version_id = p_structure_version_id
                                         AND project_element_id = p_task_id
                                         AND plan_version_id > 0
                                         AND txn_currency_code is null
                                         AND calendar_type = 'A'
                                         AND res_list_member_id is null;
                                EXCEPTION
                                         WHEN NO_DATA_FOUND THEN
                                              null;
                                         WHEN OTHERS THEN
                                              fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_PVT',
                                                                   p_procedure_name => 'ASGN_DLV_TO_TASK_ROLLUP_PVT',
                                                                   p_error_text     => SUBSTRB('PJI_FM_XBS_ACCUM_TMP1:'||SQLERRM,1,120));
                                             RAISE FND_API.G_EXC_ERROR;
                                END;
                                */
                                --Bug 3614828 End


                                IF l_PROGRESS_ROLLUP_ID IS NOT NULL
                                THEN
                                        --update
                                        OPEN cur_rollup( l_PROGRESS_ROLLUP_ID );
                                        FETCH cur_rollup INTO l_cur_rollup_rec;
                                        CLOSE cur_rollup;
                                        /* Do not update actuals if the project is of shared type. */
                                        -- 4623833 : Added l_subproj_task_version_id check
					-- update_task_progress makes equip amount as null for link task
					-- This should be updated back with the rolled amounts from sub projects
					-- Ideally, the below code should not be there at all and alwsy values shd rollup
					-- but for precuations at this last stage of build, just including link task check here

                                        IF l_split_workplan = 'N' AND l_subproj_task_version_id IS NULL
                                        THEN
                                           /* Start of changes for bug 5675437*/
                                             -- For hidden assignment case, we need to get the actuals from submitted record rather than current working one

                                             IF l_rollup_table1(i).SUMMARY_OBJECT_FLAG = 'N' AND PA_PROGRESS_UTILS.check_assignment_exists(p_project_id, p_task_version_id, 'PA_TASKS') = 'N' THEN

                                                l_PROGRESS_ROLLUP_ID3 := PA_PROGRESS_UTILS.get_prog_rollup_id(
                                                     p_project_id                 => p_project_id
                                                    ,p_object_id                  => p_task_id
                                                    ,p_object_type                => 'PA_TASKS'
                                                    ,p_object_version_id          => p_task_version_id
                                                    ,p_as_of_date                 => p_as_of_date
                                                    ,p_structure_type             => 'WORKPLAN'
                                                    ,p_structure_version_id       => l_structure_version_id
                                                    ,p_proj_element_id            => p_task_id
                                                    ,x_record_version_number      => l_rollup_rec_ver_number3
                                                  );
                                                OPEN cur_rollup( l_PROGRESS_ROLLUP_ID3 );
                                                 FETCH cur_rollup INTO l_cur_rollup_rec3;
                                                 CLOSE cur_rollup;

                                                 l_PPL_ACT_EFFORT_TO_DATE         :=     l_cur_rollup_rec3.PPL_ACT_EFFORT_TO_DATE;
                                                 l_EQPMT_ACT_EFFORT_TO_DATE       :=     l_cur_rollup_rec3.EQPMT_ACT_EFFORT_TO_DATE;
                                                 l_OTH_ACT_COST_TO_DATE_FC        :=     l_cur_rollup_rec3.OTH_ACT_COST_TO_DATE_FC;
                                                 l_OTH_ACT_COST_TO_DATE_PC        :=     l_cur_rollup_rec3.OTH_ACT_COST_TO_DATE_PC;
                                                 l_PPL_ACT_COST_TO_DATE_FC        :=     l_cur_rollup_rec3.PPL_ACT_COST_TO_DATE_FC;
                                                 l_PPL_ACT_COST_TO_DATE_PC        :=     l_cur_rollup_rec3.PPL_ACT_COST_TO_DATE_PC;
                                                 l_EQPMT_ACT_COST_TO_DATE_FC      :=     l_cur_rollup_rec3.EQPMT_ACT_COST_TO_DATE_FC;
                                                 l_EQPMT_ACT_COST_TO_DATE_PC      :=     l_cur_rollup_rec3.EQPMT_ACT_COST_TO_DATE_PC;
                                                 l_OTH_ACT_RAWCOST_TO_DATE_FC     :=     l_cur_rollup_rec3.OTH_ACT_RAWCOST_TO_DATE_FC;
                                                 l_OTH_ACT_RAWCOST_TO_DATE_PC     :=     l_cur_rollup_rec3.OTH_ACT_RAWCOST_TO_DATE_PC;
                                                 l_PPL_ACT_RAWCOST_TO_DATE_FC     :=     l_cur_rollup_rec3.PPL_ACT_RAWCOST_TO_DATE_FC;
                                                 l_PPL_ACT_RAWCOST_TO_DATE_PC     :=     l_cur_rollup_rec3.PPL_ACT_RAWCOST_TO_DATE_PC;
                                                 l_EQPMT_ACT_RAWCOST_TO_DATE_FC   :=     l_cur_rollup_rec3.EQPMT_ACT_RAWCOST_TO_DATE_FC;l_EQPMT_ACT_RAWCOST_TO_DATE_PC   :=     l_cur_rollup_rec3.EQPMT_ACT_RAWCOST_TO_DATE_PC;
                                                 l_Oth_quantity_to_date           :=     l_cur_rollup_rec3.Oth_quantity_to_date;

                                             ELSE

                                             /* End of changes for bug 5675437*/

                                                l_PPL_ACT_EFFORT_TO_DATE         :=     l_cur_rollup_rec.PPL_ACT_EFFORT_TO_DATE;
                                                l_EQPMT_ACT_EFFORT_TO_DATE       :=     l_cur_rollup_rec.EQPMT_ACT_EFFORT_TO_DATE;
                                                l_OTH_ACT_COST_TO_DATE_FC        :=     l_cur_rollup_rec.OTH_ACT_COST_TO_DATE_FC;
                                                l_OTH_ACT_COST_TO_DATE_PC        :=     l_cur_rollup_rec.OTH_ACT_COST_TO_DATE_PC;
                                                l_PPL_ACT_COST_TO_DATE_FC        :=     l_cur_rollup_rec.PPL_ACT_COST_TO_DATE_FC;
                                                l_PPL_ACT_COST_TO_DATE_PC        :=     l_cur_rollup_rec.PPL_ACT_COST_TO_DATE_PC;
                                                l_EQPMT_ACT_COST_TO_DATE_FC      :=     l_cur_rollup_rec.EQPMT_ACT_COST_TO_DATE_FC;
                                                l_EQPMT_ACT_COST_TO_DATE_PC      :=     l_cur_rollup_rec.EQPMT_ACT_COST_TO_DATE_PC;
                                                l_OTH_ACT_RAWCOST_TO_DATE_FC     :=     l_cur_rollup_rec.OTH_ACT_RAWCOST_TO_DATE_FC;
                                                l_OTH_ACT_RAWCOST_TO_DATE_PC     :=     l_cur_rollup_rec.OTH_ACT_RAWCOST_TO_DATE_PC;
                                                l_PPL_ACT_RAWCOST_TO_DATE_FC     :=     l_cur_rollup_rec.PPL_ACT_RAWCOST_TO_DATE_FC;
                                                l_PPL_ACT_RAWCOST_TO_DATE_PC     :=     l_cur_rollup_rec.PPL_ACT_RAWCOST_TO_DATE_PC;
                                                l_EQPMT_ACT_RAWCOST_TO_DATE_FC   :=     l_cur_rollup_rec.EQPMT_ACT_RAWCOST_TO_DATE_FC;
                                                l_EQPMT_ACT_RAWCOST_TO_DATE_PC   :=     l_cur_rollup_rec.EQPMT_ACT_RAWCOST_TO_DATE_PC;
                        l_Oth_quantity_to_date           :=     l_cur_rollup_rec.Oth_quantity_to_date;
                                            END IF;  --5675437

                                        END IF;


                                        /* if etc values are null, set them as planned - actual. */

                                                        PA_PROGRESS_ROLLUP_PKG.UPDATE_ROW(
                                                                    X_PROGRESS_ROLLUP_ID              => l_PROGRESS_ROLLUP_ID
                                                                   ,X_PROJECT_ID                      => p_project_id
                                                                   ,X_OBJECT_ID                       => p_task_id
                                                                   ,X_OBJECT_TYPE                     => l_rollup_table1(i).object_type
                                                                   ,X_AS_OF_DATE                      => p_as_of_date
                                                                   ,X_OBJECT_VERSION_ID               => l_rollup_table1(i).object_id
                                                                   ,X_LAST_UPDATE_DATE                => SYSDATE
                                                                   ,X_LAST_UPDATED_BY                 => l_user_id
                                                                   ,X_PROGRESS_STATUS_CODE            => l_cur_rollup_rec.progress_status_code
                                                                   ,X_LAST_UPDATE_LOGIN               => l_login_id
                                                                   ,X_INCREMENTAL_WORK_QTY            => l_cur_rollup_rec.incremental_work_quantity
                                                                   ,X_CUMULATIVE_WORK_QTY             => l_cur_rollup_rec.cumulative_work_quantity
                                                                   ,X_BASE_PERCENT_COMPLETE           => l_percent_complete2 -- 4392189 : Program Reporting Changes - Phase 2
                                                                   ,X_EFF_ROLLUP_PERCENT_COMP         => l_percent_complete1
                                                                   ,X_COMPLETED_PERCENTAGE            => l_cur_rollup_rec.completed_percentage
                                                                   ,X_ESTIMATED_START_DATE            => l_rollup_table1(i).start_date2
                                                                   ,X_ESTIMATED_FINISH_DATE           => l_rollup_table1(i).finish_date2
                                                                   ,X_ACTUAL_START_DATE               => l_actual_start_date -- Bug 3956299 l_rollup_table1(i).start_date1
                                                                   ,X_ACTUAL_FINISH_DATE              => l_actual_finish_date -- Bug 3956299 l_rollup_table1(i).finish_date1
                                                                   ,X_EST_REMAINING_EFFORT            => l_remaining_effort1
                                                                   ,X_RECORD_VERSION_NUMBER           => l_rollup_rec_ver_number
                                                                   ,X_BASE_PERCENT_COMP_DERIV_CODE    => l_cur_rollup_rec.BASE_PERCENT_COMP_DERIV_CODE
                                                                   ,X_BASE_PROGRESS_STATUS_CODE       => l_rolled_up_base_prog_stat
                                                                   ,X_EFF_ROLLUP_PROG_STAT_CODE       => l_eff_rollup_status_code
                                                                   ,x_percent_complete_id             => null
                                                                   ,X_STRUCTURE_TYPE                  => 'WORKPLAN'
                                                                   ,X_PROJ_ELEMENT_ID                 => p_task_id
                                                                   ,X_STRUCTURE_VERSION_ID            => l_structure_version_id
                                                                   ,X_PPL_ACT_EFFORT_TO_DATE          => l_PPL_ACT_EFFORT_TO_DATE
                                                                   ,X_EQPMT_ACT_EFFORT_TO_DATE        => l_EQPMT_ACT_EFFORT_TO_DATE
                                                                   ,X_EQPMT_ETC_EFFORT                => l_EQPMT_ETC_EFFORT
                                                                   ,X_OTH_ACT_COST_TO_DATE_TC         => null
                                                                   ,X_OTH_ACT_COST_TO_DATE_FC         => l_OTH_ACT_COST_TO_DATE_FC
                                                                   ,X_OTH_ACT_COST_TO_DATE_PC         => l_OTH_ACT_COST_TO_DATE_PC
                                                                   ,X_OTH_ETC_COST_TC                 => null
                                                                   ,X_OTH_ETC_COST_FC                 => l_ETC_Cost_FC
                                                                   ,X_OTH_ETC_COST_PC                 => l_ETC_Cost_PC
                                                                   ,X_PPL_ACT_COST_TO_DATE_TC         => null
                                                                   ,X_PPL_ACT_COST_TO_DATE_FC         => l_PPL_ACT_COST_TO_DATE_FC
                                                                   ,X_PPL_ACT_COST_TO_DATE_PC         => l_PPL_ACT_COST_TO_DATE_PC
                                                                   ,X_PPL_ETC_COST_TC                 => null
                                                                   ,X_PPL_ETC_COST_FC                 => l_PPL_ETC_COST_FC
                                                                   ,X_PPL_ETC_COST_PC                 => l_PPL_ETC_COST_PC
                                                                   ,X_EQPMT_ACT_COST_TO_DATE_TC       => null
                                                                   ,X_EQPMT_ACT_COST_TO_DATE_FC       => l_EQPMT_ACT_COST_TO_DATE_FC
                                                                   ,X_EQPMT_ACT_COST_TO_DATE_PC       => l_EQPMT_ACT_COST_TO_DATE_PC
                                                                   ,X_EQPMT_ETC_COST_TC               => null
                                                                   ,X_EQPMT_ETC_COST_FC               => l_EQPMT_ETC_COST_FC
                                                                   ,X_EQPMT_ETC_COST_PC               => l_EQPMT_ETC_COST_PC
                                                                   ,X_EARNED_VALUE                    => l_earned_value1
                                                                   ,X_TASK_WT_BASIS_CODE              => l_rollup_method
                                                                   ,X_SUBPRJ_PPL_ACT_EFFORT           => l_cur_rollup_rec.SUBPRJ_PPL_ACT_EFFORT
                                                                   ,X_SUBPRJ_EQPMT_ACT_EFFORT         => l_cur_rollup_rec.SUBPRJ_EQPMT_ACT_EFFORT
                                                                   ,X_SUBPRJ_PPL_ETC_EFFORT           => l_cur_rollup_rec.SUBPRJ_PPL_ETC_EFFORT
                                                                   ,X_SUBPRJ_EQPMT_ETC_EFFORT         => l_cur_rollup_rec.SUBPRJ_EQPMT_ETC_EFFORT
                                                                   ,X_SBPJ_OTH_ACT_COST_TO_DATE_TC    => null
                                                                   ,X_SBPJ_OTH_ACT_COST_TO_DATE_FC    => l_cur_rollup_rec.SUBPRJ_OTH_ACT_COST_TO_DATE_FC
                                                                   ,X_SBPJ_OTH_ACT_COST_TO_DATE_PC    => l_cur_rollup_rec.SUBPRJ_OTH_ACT_COST_TO_DATE_PC
                                                                   ,X_SUBPRJ_PPL_ACT_COST_TC          => l_cur_rollup_rec.SUBPRJ_PPL_ACT_COST_TC
                                                                   ,X_SUBPRJ_PPL_ACT_COST_FC          => l_cur_rollup_rec.SUBPRJ_PPL_ACT_COST_FC
                                                                   ,X_SUBPRJ_PPL_ACT_COST_PC          => l_cur_rollup_rec.SUBPRJ_PPL_ACT_COST_PC
                                                                   ,X_SUBPRJ_EQPMT_ACT_COST_TC        => l_cur_rollup_rec.SUBPRJ_EQPMT_ACT_COST_TC
                                                                   ,X_SUBPRJ_EQPMT_ACT_COST_FC        => l_cur_rollup_rec.SUBPRJ_EQPMT_ACT_COST_FC
                                                                   ,X_SUBPRJ_EQPMT_ACT_COST_PC        => l_cur_rollup_rec.SUBPRJ_EQPMT_ACT_COST_PC
                                                                   ,X_SUBPRJ_OTH_ETC_COST_TC          => l_cur_rollup_rec.SUBPRJ_OTH_ETC_COST_TC
                                                                   ,X_SUBPRJ_OTH_ETC_COST_FC          => l_cur_rollup_rec.SUBPRJ_OTH_ETC_COST_FC
                                                                   ,X_SUBPRJ_OTH_ETC_COST_PC          => l_cur_rollup_rec.SUBPRJ_OTH_ETC_COST_PC
                                                                   ,X_SUBPRJ_PPL_ETC_COST_TC          => l_cur_rollup_rec.SUBPRJ_PPL_ETC_COST_TC
                                                                   ,X_SUBPRJ_PPL_ETC_COST_FC          => l_cur_rollup_rec.SUBPRJ_PPL_ETC_COST_FC
                                                                   ,X_SUBPRJ_PPL_ETC_COST_PC          => l_cur_rollup_rec.SUBPRJ_PPL_ETC_COST_PC
                                                                   ,X_SUBPRJ_EQPMT_ETC_COST_TC        => l_cur_rollup_rec.SUBPRJ_EQPMT_ETC_COST_TC
                                                                   ,X_SUBPRJ_EQPMT_ETC_COST_FC        => l_cur_rollup_rec.SUBPRJ_EQPMT_ETC_COST_FC
                                                                   ,X_SUBPRJ_EQPMT_ETC_COST_PC        => l_cur_rollup_rec.SUBPRJ_EQPMT_ETC_COST_PC
                                                                   ,X_SUBPRJ_EARNED_VALUE             => l_cur_rollup_rec.SUBPRJ_EARNED_VALUE
                                                                   ,X_CURRENT_FLAG                    => l_cur_rollup_rec.CURRENT_FLAG
                                                                   ,X_PROJFUNC_COST_RATE_TYPE         => l_cur_rollup_rec.PROJFUNC_COST_RATE_TYPE
                                                                   ,X_PROJFUNC_COST_EXCHANGE_RATE     => l_cur_rollup_rec.PROJFUNC_COST_EXCHANGE_RATE
                                                                   ,X_PROJFUNC_COST_RATE_DATE         => l_cur_rollup_rec.PROJFUNC_COST_RATE_DATE
                                                                   ,X_PROJ_COST_RATE_TYPE             => l_cur_rollup_rec.PROJ_COST_RATE_TYPE
                                                                   ,X_PROJ_COST_EXCHANGE_RATE         => l_cur_rollup_rec.PROJ_COST_EXCHANGE_RATE
                                                                   ,X_PROJ_COST_RATE_DATE             => l_cur_rollup_rec.PROJ_COST_RATE_DATE
                                                                   ,X_TXN_CURRENCY_CODE               => l_cur_rollup_rec.TXN_CURRENCY_CODE
                                                                   ,X_PROG_PA_PERIOD_NAME             => l_cur_rollup_rec.PROG_PA_PERIOD_NAME
                                                                   ,X_PROG_GL_PERIOD_NAME             => l_cur_rollup_rec.PROG_GL_PERIOD_NAME
                                                                   ,X_OTH_QUANTITY_TO_DATE            => l_Oth_quantity_to_date
                                                                   ,X_OTH_ETC_QUANTITY                => l_Oth_etc_quantity
                                                                   -- Bug 3621404 : Raw Cost Changes
                                                                   ,X_OTH_ACT_RAWCOST_TO_DATE_TC      => null
                                                                   ,X_OTH_ACT_RAWCOST_TO_DATE_FC      => l_OTH_ACT_RAWCOST_TO_DATE_FC
                                                                   ,X_OTH_ACT_RAWCOST_TO_DATE_PC      => l_OTH_ACT_RAWCOST_TO_DATE_PC
                                                                   ,X_OTH_ETC_RAWCOST_TC              => null
                                                                   ,X_OTH_ETC_RAWCOST_FC              => l_ETC_RAWCost_FC
                                                                   ,X_OTH_ETC_RAWCOST_PC              => l_ETC_RAWCost_PC
                                                                   ,X_PPL_ACT_RAWCOST_TO_DATE_TC      => null
                                                                   ,X_PPL_ACT_RAWCOST_TO_DATE_FC      => l_PPL_ACT_RAWCOST_TO_DATE_FC
                                                                   ,X_PPL_ACT_RAWCOST_TO_DATE_PC      => l_PPL_ACT_RAWCOST_TO_DATE_PC
                                                                   ,X_PPL_ETC_RAWCOST_TC              => null
                                                                   ,X_PPL_ETC_RAWCOST_FC              => l_PPL_ETC_RAWCOST_FC
                                                                   ,X_PPL_ETC_RAWCOST_PC              => l_PPL_ETC_RAWCOST_PC
                                                                   ,X_EQPMT_ACT_RAWCOST_TO_DATE_TC    => null
                                                                   ,X_EQPMT_ACT_RAWCOST_TO_DATE_FC    => l_EQPMT_ACT_RAWCOST_TO_DATE_FC
                                                                   ,X_EQPMT_ACT_RAWCOST_TO_DATE_PC    => l_EQPMT_ACT_RAWCOST_TO_DATE_PC
                                                                   ,X_EQPMT_ETC_RAWCOST_TC            => null
                                                                   ,X_EQPMT_ETC_RAWCOST_FC            => l_EQPMT_ETC_RAWCOST_FC
                                                                   ,X_EQPMT_ETC_RAWCOST_PC            => l_EQPMT_ETC_RAWCOST_PC
                                                                   ,X_SP_OTH_ACT_RAWCOST_TODATE_TC    => l_cur_rollup_rec.SPJ_OTH_ACT_RAWCOST_TO_DATE_TC
                                                                   ,X_SP_OTH_ACT_RAWCOST_TODATE_FC    => l_cur_rollup_rec.SPJ_OTH_ACT_RAWCOST_TO_DATE_FC
                                                                   ,X_SP_OTH_ACT_RAWCOST_TODATE_PC    => l_cur_rollup_rec.SPJ_OTH_ACT_RAWCOST_TO_DATE_PC
                                                                   ,X_SUBPRJ_PPL_ACT_RAWCOST_TC       => l_cur_rollup_rec.SUBPRJ_PPL_ACT_RAWCOST_TC
                                                                   ,X_SUBPRJ_PPL_ACT_RAWCOST_FC       => l_cur_rollup_rec.SUBPRJ_PPL_ACT_RAWCOST_FC
                                                                   ,X_SUBPRJ_PPL_ACT_RAWCOST_PC       => l_cur_rollup_rec.SUBPRJ_PPL_ACT_RAWCOST_PC
                                                                   ,X_SUBPRJ_EQPMT_ACT_RAWCOST_TC     => l_cur_rollup_rec.SUBPRJ_EQPMT_ACT_RAWCOST_TC
                                                                   ,X_SUBPRJ_EQPMT_ACT_RAWCOST_FC     => l_cur_rollup_rec.SUBPRJ_EQPMT_ACT_RAWCOST_FC
                                                                   ,X_SUBPRJ_EQPMT_ACT_RAWCOST_PC     => l_cur_rollup_rec.SUBPRJ_EQPMT_ACT_RAWCOST_PC
                                                                   ,X_SUBPRJ_OTH_ETC_RAWCOST_TC       => l_cur_rollup_rec.SUBPRJ_OTH_ETC_RAWCOST_TC
                                                                   ,X_SUBPRJ_OTH_ETC_RAWCOST_FC       => l_cur_rollup_rec.SUBPRJ_OTH_ETC_RAWCOST_FC
                                                                   ,X_SUBPRJ_OTH_ETC_RAWCOST_PC       => l_cur_rollup_rec.SUBPRJ_OTH_ETC_RAWCOST_PC
                                                                   ,X_SUBPRJ_PPL_ETC_RAWCOST_TC       => l_cur_rollup_rec.SUBPRJ_PPL_ETC_RAWCOST_TC
                                                                   ,X_SUBPRJ_PPL_ETC_RAWCOST_FC       => l_cur_rollup_rec.SUBPRJ_PPL_ETC_RAWCOST_FC
                                                                   ,X_SUBPRJ_PPL_ETC_RAWCOST_PC       => l_cur_rollup_rec.SUBPRJ_PPL_ETC_RAWCOST_PC
                                                                   ,X_SUBPRJ_EQPMT_ETC_RAWCOST_TC     => l_cur_rollup_rec.SUBPRJ_EQPMT_ETC_RAWCOST_TC
                                                                   ,X_SUBPRJ_EQPMT_ETC_RAWCOST_FC     => l_cur_rollup_rec.SUBPRJ_EQPMT_ETC_RAWCOST_FC
                                                                   ,X_SUBPRJ_EQPMT_ETC_RAWCOST_PC     => l_cur_rollup_rec.SUBPRJ_EQPMT_ETC_RAWCOST_PC
                                                             );
                                                                -- FPM Dev CR 6
                                                                IF Fnd_Msg_Pub.count_msg > 0 THEN
                                                                        RAISE  FND_API.G_EXC_ERROR;
                                                                END IF;

                                                --update progress_outdated_flag for summary tasks if there exists any ppc record
                                                --for the summary task

                                                l_progress_exists_on_aod := PA_PROGRESS_UTILS.check_prog_exists_on_aod(
                                                      p_task_id          => p_task_id
                              ,p_object_id       => p_task_id -- Bug 3764224
                                                     ,p_as_of_date         => p_as_of_date
                                                     ,p_project_id         => p_project_id
                                                     ,p_object_version_id  => l_rollup_table1(i).object_id
                                                     ,p_object_type        => l_rollup_table1(i).object_type
                                                  ,p_structure_type     => 'WORKPLAN'
                                                    );

                                       /* commenting out the code for bug   3851528
                                        IF l_progress_exists_on_aod = 'PUBLISHED' THEN
                                                UPDATE pa_proj_elements
                                                SET progress_outdated_flag = 'Y'
                                                WHERE proj_element_id = p_task_id
                                                AND project_id = p_project_id
                                                AND object_type = l_rollup_table1(i).object_type;
                                        END IF;
                                       */
                                ELSE --l_PROGRESS_ROLLUP_ID IS NOT NULL
                                        -- get percent_complete_id
                                        BEGIN
                                                SELECT percent_complete_id
                                                INTO l_percent_complete_id
                                                FROM pa_percent_completes
                                                WHERE project_id = p_project_id
                                                AND object_id =  p_task_id
                                                AND object_Type = l_rollup_table1(i).object_Type
                                                AND structure_type = 'WORKPLAN'
                                                AND date_computed = ( SELECT max(date_computed)
                                                                FROM pa_percent_completes
                                                                WHERE project_id = p_project_id
                                                                AND object_id =  p_task_id
                                                                AND object_Type = l_rollup_table1(i).object_Type
                                                                AND structure_type = 'WORKPLAN'
                                                                AND date_computed <= p_as_of_date
                                                                );
                                        EXCEPTION WHEN OTHERS THEN
                                                l_percent_complete_id := null;
                                        END;

                    -- Bug 3879461 Begin : Code Not Required now
                    /*
                                        l_max_rollup_as_of_date2 := PA_PROGRESS_UTILS.get_max_rollup_asofdate2
                                                                (p_project_id   => p_project_id,
                                                                 p_object_id    => p_task_id,
                                                                 p_object_type  => l_rollup_table1(i).object_type,
                                                                 p_structure_type => 'WORKPLAN',
                                                                 p_structure_version_id => l_structure_version_id,
                                 p_proj_element_id => p_task_id -- Bug 3764224
                                                                 );


                                        IF l_max_rollup_as_of_date2 > p_as_of_date
                                        THEN
                                                l_current_flag := 'N';  --this means that there is a future record than the current one.
                                        ELSE
                                                l_current_flag := 'Y';
                                        END IF;
                    */
                    -- Bug 3879461 End

                                        -- This code is not required if we do not do partail rollup from assignmnet progress details page

                                                         PA_PROGRESS_ROLLUP_PKG.INSERT_ROW(
                                                                          X_PROGRESS_ROLLUP_ID              => l_PROGRESS_ROLLUP_ID
                                                                         ,X_PROJECT_ID                      => p_project_id
                                                                         ,X_OBJECT_ID                       => p_task_id
                                                                         ,X_OBJECT_TYPE                     => l_rollup_table1(i).object_type
                                                                         ,X_AS_OF_DATE                      => p_as_of_date
                                                                         ,X_OBJECT_VERSION_ID               => l_rollup_table1(i).object_id
                                                                         ,X_LAST_UPDATE_DATE                => SYSDATE
                                                                         ,X_LAST_UPDATED_BY                 => l_user_id
                                                                         ,X_CREATION_DATE                   => SYSDATE
                                                                         ,X_CREATED_BY                      => l_user_id
                                                                         ,X_PROGRESS_STATUS_CODE            => l_rolled_up_prog_stat
                                                                         ,X_LAST_UPDATE_LOGIN               => l_login_id
                                                                         ,X_INCREMENTAL_WORK_QTY            => null
                                                                         ,X_CUMULATIVE_WORK_QTY             => null
                                                                         ,X_BASE_PERCENT_COMPLETE           => l_percent_complete2 -- 4392189 : Program Reporting Changes - Phase 2
                                                                         ,X_EFF_ROLLUP_PERCENT_COMP         => l_percent_complete1
                                                                         ,X_COMPLETED_PERCENTAGE            => l_rolled_up_per_comp
                                                                         ,X_ESTIMATED_START_DATE            => l_rollup_table1(i).start_date2
                                                                         ,X_ESTIMATED_FINISH_DATE           => l_rollup_table1(i).finish_date2
                                                                         ,X_ACTUAL_START_DATE               => l_actual_start_date -- Bug 3956299 l_rollup_table1(i).start_date1
                                                                         ,X_ACTUAL_FINISH_DATE              => l_actual_finish_date -- Bug 3956299 l_rollup_table1(i).finish_date1
                                                                         ,X_EST_REMAINING_EFFORT            => l_remaining_effort1
                                                                         ,X_BASE_PERCENT_COMP_DERIV_CODE    => l_BASE_PERCENT_COMP_DERIV_CODE
                                                                         ,X_BASE_PROGRESS_STATUS_CODE       => l_rolled_up_base_prog_stat
                                                                         ,X_EFF_ROLLUP_PROG_STAT_CODE       => l_eff_rollup_status_code
                                                                         ,x_percent_complete_id             => l_percent_complete_id
                                                                         ,X_STRUCTURE_TYPE                  => 'WORKPLAN'
                                                                         ,X_PROJ_ELEMENT_ID                 => p_task_id
                                                                         ,X_STRUCTURE_VERSION_ID            => l_structure_version_id
                                                                         ,X_PPL_ACT_EFFORT_TO_DATE          => l_PPL_ACT_EFFORT_TO_DATE
                                                                         ,X_EQPMT_ACT_EFFORT_TO_DATE        => l_EQPMT_ACT_EFFORT_TO_DATE
                                                                         ,X_EQPMT_ETC_EFFORT                => l_EQPMT_ETC_EFFORT
                                                                         ,X_OTH_ACT_COST_TO_DATE_TC         => null
                                                                         ,X_OTH_ACT_COST_TO_DATE_FC         => l_OTH_ACT_COST_TO_DATE_FC
                                                                         ,X_OTH_ACT_COST_TO_DATE_PC         => l_OTH_ACT_COST_TO_DATE_PC
                                                                         ,X_OTH_ETC_COST_TC                 => null
                                                                         ,X_OTH_ETC_COST_FC                 => l_ETC_Cost_FC
                                                                         ,X_OTH_ETC_COST_PC                 => l_ETC_Cost_PC
                                                                         ,X_PPL_ACT_COST_TO_DATE_TC         => null
                                                                         ,X_PPL_ACT_COST_TO_DATE_FC         => l_PPL_ACT_COST_TO_DATE_FC
                                                                         ,X_PPL_ACT_COST_TO_DATE_PC         => l_PPL_ACT_COST_TO_DATE_PC
                                                                         ,X_PPL_ETC_COST_TC                 => null
                                                                         ,X_PPL_ETC_COST_FC                 => l_PPL_ETC_COST_FC
                                                                         ,X_PPL_ETC_COST_PC                 => l_PPL_ETC_COST_PC
                                                                         ,X_EQPMT_ACT_COST_TO_DATE_TC       => null
                                                                         ,X_EQPMT_ACT_COST_TO_DATE_FC       => l_EQPMT_ACT_COST_TO_DATE_FC
                                                                         ,X_EQPMT_ACT_COST_TO_DATE_PC       => l_EQPMT_ACT_COST_TO_DATE_PC
                                                                         ,X_EQPMT_ETC_COST_TC               => null
                                                                         ,X_EQPMT_ETC_COST_FC               => l_EQPMT_ETC_COST_FC
                                                                         ,X_EQPMT_ETC_COST_PC               => l_EQPMT_ETC_COST_PC
                                                                         ,X_EARNED_VALUE                    => l_earned_value1
                                                                         ,X_TASK_WT_BASIS_CODE              => l_rollup_method
                                                                         ,X_SUBPRJ_PPL_ACT_EFFORT           => l_cur_pa_rollup1_rec.SUBPRJ_PPL_ACT_EFFORT
                                                                         ,X_SUBPRJ_EQPMT_ACT_EFFORT         => l_cur_pa_rollup1_rec.SUBPRJ_EQPMT_ACT_EFFORT
                                                                         ,X_SUBPRJ_PPL_ETC_EFFORT           => l_SUB_PRJ_PPL_ETC_EFFORT
                                                                         ,X_SUBPRJ_EQPMT_ETC_EFFORT         => l_SUB_PRJ_EQPMT_ETC_EFFORT
                                                                         ,X_SBPJ_OTH_ACT_COST_TO_DATE_TC    => null
                                                                         ,X_SBPJ_OTH_ACT_COST_TO_DATE_FC    => l_cur_pa_rollup1_rec.SUBPRJ_OTH_ACT_COST_TO_DATE_FC
                                                                         ,X_SBPJ_OTH_ACT_COST_TO_DATE_PC    => l_cur_pa_rollup1_rec.SUBPRJ_OTH_ACT_COST_TO_DATE_PC
                                                                         ,X_SUBPRJ_PPL_ACT_COST_TC          => null
                                                                         ,X_SUBPRJ_PPL_ACT_COST_FC          => l_cur_pa_rollup1_rec.SUBPRJ_PPL_ACT_COST_FC
                                                                         ,X_SUBPRJ_PPL_ACT_COST_PC          => l_cur_pa_rollup1_rec.SUBPRJ_PPL_ACT_COST_PC
                                                                         ,X_SUBPRJ_EQPMT_ACT_COST_TC        => null
                                                                         ,X_SUBPRJ_EQPMT_ACT_COST_FC        => l_cur_pa_rollup1_rec.SUBPRJ_EQPMT_ACT_COST_FC
                                                                         ,X_SUBPRJ_EQPMT_ACT_COST_PC        => l_cur_pa_rollup1_rec.SUBPRJ_EQPMT_ACT_COST_PC
                                                                         ,X_SUBPRJ_OTH_ETC_COST_TC          => null
                                                                         ,X_SUBPRJ_OTH_ETC_COST_FC          => l_SUB_PRJ_ETC_COST_FC
                                                                         ,X_SUBPRJ_OTH_ETC_COST_PC          => l_SUB_PRJ_ETC_COST_PC
                                                                         ,X_SUBPRJ_PPL_ETC_COST_TC          => null
                                                                         ,X_SUBPRJ_PPL_ETC_COST_FC          => l_SUB_PRJ_PPL_ETC_COST_FC
                                                                         ,X_SUBPRJ_PPL_ETC_COST_PC          => l_SUB_PRJ_PPL_ETC_COST_PC
                                                                         ,X_SUBPRJ_EQPMT_ETC_COST_TC        => null
                                                                         ,X_SUBPRJ_EQPMT_ETC_COST_FC        => l_SUB_PRJ_EQPMT_ETC_COST_FC
                                                                         ,X_SUBPRJ_EQPMT_ETC_COST_PC        => l_SUB_PRJ_EQPMT_ETC_COST_PC
                                                                         ,X_SUBPRJ_EARNED_VALUE             => l_cur_pa_rollup1_rec.SUBPRJ_EARNED_VALUE
                                                                         ,X_CURRENT_FLAG                    => l_current_flag --maaansari FPM Dev CR2
                                                                         ,X_PROJFUNC_COST_RATE_TYPE         => l_cur_pa_rollup1_rec.PROJFUNC_COST_RATE_TYPE
                                                                         ,X_PROJFUNC_COST_EXCHANGE_RATE     => l_cur_pa_rollup1_rec.PROJFUNC_COST_EXCHANGE_RATE
                                                                         ,X_PROJFUNC_COST_RATE_DATE         => l_cur_pa_rollup1_rec.PROJFUNC_COST_RATE_DATE
                                                                         ,X_PROJ_COST_RATE_TYPE             => l_cur_pa_rollup1_rec.PROJ_COST_RATE_TYPE
                                                                         ,X_PROJ_COST_EXCHANGE_RATE         => l_cur_pa_rollup1_rec.PROJ_COST_EXCHANGE_RATE
                                                                         ,X_PROJ_COST_RATE_DATE             => l_cur_pa_rollup1_rec.PROJ_COST_RATE_DATE
                                                                         ,X_TXN_CURRENCY_CODE               => l_cur_pa_rollup1_rec.TXN_CURRENCY_CODE
                                                                         ,X_PROG_PA_PERIOD_NAME             => l_prog_pa_period_name
                                                                         ,X_PROG_GL_PERIOD_NAME             => l_prog_gl_period_name
                                                                       ,X_OTH_QUANTITY_TO_DATE            => l_Oth_quantity_to_date
                                                                   ,X_OTH_ETC_QUANTITY                => l_Oth_etc_quantity
                                                                           -- Bug 3621404 : Raw Cost Changes
                                                                           ,X_OTH_ACT_RAWCOST_TO_DATE_TC      => null
                                                                           ,X_OTH_ACT_RAWCOST_TO_DATE_FC      => l_OTH_ACT_RAWCOST_TO_DATE_FC
                                                                           ,X_OTH_ACT_RAWCOST_TO_DATE_PC      => l_OTH_ACT_RAWCOST_TO_DATE_PC
                                                                           ,X_OTH_ETC_RAWCOST_TC              => null
                                                                           ,X_OTH_ETC_RAWCOST_FC              => l_ETC_RAWCost_FC
                                                                           ,X_OTH_ETC_RAWCOST_PC              => l_ETC_RAWCost_PC
                                                                           ,X_PPL_ACT_RAWCOST_TO_DATE_TC      => null
                                                                           ,X_PPL_ACT_RAWCOST_TO_DATE_FC      => l_PPL_ACT_RAWCOST_TO_DATE_FC
                                                                           ,X_PPL_ACT_RAWCOST_TO_DATE_PC      => l_PPL_ACT_RAWCOST_TO_DATE_PC
                                                                           ,X_PPL_ETC_RAWCOST_TC              => null
                                                                           ,X_PPL_ETC_RAWCOST_FC              => l_PPL_ETC_RAWCOST_FC
                                                                           ,X_PPL_ETC_RAWCOST_PC              => l_PPL_ETC_RAWCOST_PC
                                                                           ,X_EQPMT_ACT_RAWCOST_TO_DATE_TC    => null
                                                                           ,X_EQPMT_ACT_RAWCOST_TO_DATE_FC    => l_EQPMT_ACT_RAWCOST_TO_DATE_FC
                                                                           ,X_EQPMT_ACT_RAWCOST_TO_DATE_PC    => l_EQPMT_ACT_RAWCOST_TO_DATE_PC
                                                                           ,X_EQPMT_ETC_RAWCOST_TC            => null
                                                                           ,X_EQPMT_ETC_RAWCOST_FC            => l_EQPMT_ETC_RAWCOST_FC
                                                                           ,X_EQPMT_ETC_RAWCOST_PC            => l_EQPMT_ETC_RAWCOST_PC
                                                                         ,X_SP_OTH_ACT_RAWCOST_TODATE_TC         => l_cur_pa_rollup1_rec.SPJ_OTH_ACT_RAWCOST_TO_DATE_TC
                                                                         ,X_SP_OTH_ACT_RAWCOST_TODATE_FC         => l_cur_pa_rollup1_rec.SPJ_OTH_ACT_RAWCOST_TO_DATE_FC
                                                                         ,X_SP_OTH_ACT_RAWCOST_TODATE_PC         => l_cur_pa_rollup1_rec.SPJ_OTH_ACT_RAWCOST_TO_DATE_PC
                                                                         ,X_SUBPRJ_PPL_ACT_RAWCOST_TC    => l_cur_pa_rollup1_rec.SUBPRJ_PPL_ACT_RAWCOST_TC
                                                                         ,X_SUBPRJ_PPL_ACT_RAWCOST_FC    => l_cur_pa_rollup1_rec.SUBPRJ_PPL_ACT_RAWCOST_FC
                                                                         ,X_SUBPRJ_PPL_ACT_RAWCOST_PC    => l_cur_pa_rollup1_rec.SUBPRJ_PPL_ACT_RAWCOST_PC
                                                                         ,X_SUBPRJ_EQPMT_ACT_RAWCOST_TC  => l_cur_pa_rollup1_rec.SUBPRJ_EQPMT_ACT_RAWCOST_TC
                                                                         ,X_SUBPRJ_EQPMT_ACT_RAWCOST_FC  => l_cur_pa_rollup1_rec.SUBPRJ_EQPMT_ACT_RAWCOST_FC
                                                                         ,X_SUBPRJ_EQPMT_ACT_RAWCOST_PC  => l_cur_pa_rollup1_rec.SUBPRJ_EQPMT_ACT_RAWCOST_PC
                                                                         ,X_SUBPRJ_OTH_ETC_RAWCOST_TC    => l_cur_pa_rollup1_rec.SUBPRJ_OTH_ETC_RAWCOST_TC
                                                                         ,X_SUBPRJ_OTH_ETC_RAWCOST_FC    => l_cur_pa_rollup1_rec.SUBPRJ_OTH_ETC_RAWCOST_FC
                                                                         ,X_SUBPRJ_OTH_ETC_RAWCOST_PC    => l_cur_pa_rollup1_rec.SUBPRJ_OTH_ETC_RAWCOST_PC
                                                                         ,X_SUBPRJ_PPL_ETC_RAWCOST_TC    => l_cur_pa_rollup1_rec.SUBPRJ_PPL_ETC_RAWCOST_TC
                                                                         ,X_SUBPRJ_PPL_ETC_RAWCOST_FC    => l_cur_pa_rollup1_rec.SUBPRJ_PPL_ETC_RAWCOST_FC
                                                                         ,X_SUBPRJ_PPL_ETC_RAWCOST_PC    => l_cur_pa_rollup1_rec.SUBPRJ_PPL_ETC_RAWCOST_PC
                                                                         ,X_SUBPRJ_EQPMT_ETC_RAWCOST_TC  => l_cur_pa_rollup1_rec.SUBPRJ_EQPMT_ETC_RAWCOST_TC
                                                                         ,X_SUBPRJ_EQPMT_ETC_RAWCOST_FC  => l_cur_pa_rollup1_rec.SUBPRJ_EQPMT_ETC_RAWCOST_FC
                                                                         ,X_SUBPRJ_EQPMT_ETC_RAWCOST_PC  => l_cur_pa_rollup1_rec.SUBPRJ_EQPMT_ETC_RAWCOST_PC
                                                       );
                    -- Bug 3879461 Begin : Code nOt required now
                    /*
                                         --update all previous record current flag to 'N'
                                        IF l_max_rollup_as_of_date2 < p_as_of_date --creating a new progress record.
                                        THEN
                                                UPDATE pa_progress_rollup
                                                SET current_flag = 'N'
                                                WHERE progress_rollup_id <> l_progress_rollup_id
                                                AND project_id = p_project_id
                                                AND object_id = p_task_id
                                                AND object_type = l_rollup_table1(i).object_type
                                                AND structure_type = 'WORKPLAN'
                                                AND structure_version_id is null
                                                           ;
                                        END IF;


                                        --update progress_outdated_flag for summary tasks if there exists any ppc record
                                        --for the summary task

                                        l_progress_exists_on_aod := PA_PROGRESS_UTILS.check_prog_exists_on_aod(
                                                      p_task_id          => p_task_id
                              ,p_object_id       => p_task_id -- Bug 3764224
                                                     ,p_as_of_date         => p_as_of_date
                                                     ,p_project_id         => p_project_id
                                                     ,p_object_version_id  => l_rollup_table1(i).object_id
                                                     ,p_object_type        => l_rollup_table1(i).object_type
                                                     ,p_structure_type     => 'WORKPLAN'
                                                   );
                           */
                    -- Bug 3879461 End

                                      /* commenting out the code for bug    3851528
                                        IF l_progress_exists_on_aod = 'PUBLISHED' THEN
                                                UPDATE pa_proj_elements
                                                SET progress_outdated_flag = 'Y'
                                                WHERE proj_element_id = p_task_id
                                                AND project_id = p_project_id
                                                AND object_type = l_rollup_table1(i).object_type;
                                        END IF;
                                      */
                                END IF; -- l_PROGRESS_ROLLUP_ID IS NOT NULL
                        END IF; -- IF p_task_version_id = l_rollup_table1(i).object_id AND l_rollup_table1(i).object_type = 'PA_TASKS'
                        END LOOP;
                END IF;  --<< l_total_tasks >>

                /* We need to confirm that whether this needs to be called for working progress rollup or not
                IF l_split_workplan =  'Y'
                THEN
                BEGIN
                        l_project_ids.extend(1);
                        l_project_ids(1) := p_project_id;
                        l_struture_version_ids.extend(1);
                        l_struture_version_ids(1) := p_structure_version_id;
                        l_proj_thru_dates_tbl.extend(1);
                        l_proj_thru_dates_tbl(1) := p_as_of_date;
                        PA_FP_MAINTAIN_ACTUAL_PUB.MAINTAIN_ACTUAL_AMT_WRP
                          (P_PROJECT_ID_TAB                   => l_project_ids,
                           P_WP_STR_VERSION_ID_TAB            => l_struture_version_ids,
                           P_ACTUALS_THRU_DATE     => l_proj_thru_dates_tbl,
                           P_CALLING_CONTEXT                  => 'WP_PROGRESS',
                           X_RETURN_STATUS                    => l_return_status,
                           X_MSG_COUNT                        => l_msg_count,
                           X_MSG_DATA                         => l_msg_data
                        );


                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                        p_msg_name       => l_msg_data);
                                       x_msg_data := l_msg_data;
                                       x_return_status := 'E';
                                       x_msg_count := l_msg_count;
                                       RAISE  FND_API.G_EXC_ERROR;
                        END IF;
                EXCEPTION
                 WHEN OTHERS THEN
                     fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_PVT',
                                   p_procedure_name => 'update_ASGN_DLV_TO_TASK_ROLLUP_PVT',
                     p_error_text     => SUBSTRB('PA_FP_MAINTAIN_ACTUAL_PUB.MAINTAIN_ACTUAL_AMT_WRP:'||SQLERRM,1,120));
                     RAISE FND_API.G_EXC_ERROR;
                END;
                END IF;*/


        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (p_commit = FND_API.G_TRUE) THEN
                COMMIT;
        END IF;

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.UPDATE_ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT End', x_Log_Level=> 3);
        END IF;


        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (p_commit = FND_API.G_TRUE) THEN
                COMMIT;
        END IF;


        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT', x_Msg => 'PA_PROGRESS_PVT.ASGN_DLV_TO_TASK_ROLLUP_PVT END', x_Log_Level=> 3);
        END IF;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                IF p_commit = FND_API.G_TRUE THEN
                        rollback to ASGN_DLV_TO_TASK_ROLLUP_PVT2;
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF p_commit = FND_API.G_TRUE THEN
                        rollback to ASGN_DLV_TO_TASK_ROLLUP_PVT2;
                END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_PVT',
                              p_procedure_name => 'ASGN_DLV_TO_TASK_ROLLUP_PVT',
                              p_error_text     => SUBSTRB(SQLERRM,1,120));
        WHEN OTHERS THEN
                IF p_commit = FND_API.G_TRUE THEN
                        rollback to ASGN_DLV_TO_TASK_ROLLUP_PVT2;
                END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_PVT',
                              p_procedure_name => 'ASGN_DLV_TO_TASK_ROLLUP_PVT',
                              p_error_text     => SUBSTRB(SQLERRM,1,120));
                raise;
END ASGN_DLV_TO_TASK_ROLLUP_PVT;


 --bug 3935699


PROCEDURE convert_task_prog_to_assgn
(
 p_api_version                          IN      NUMBER          :=1.0
,p_init_msg_list                        IN      VARCHAR2        :=FND_API.G_FALSE -- Since it is a private API so false
,p_commit                               IN      VARCHAR2        :=FND_API.G_FALSE
,p_validate_only                        IN      VARCHAR2        :=FND_API.G_TRUE
,p_validation_level                     IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
,p_calling_module                       IN      VARCHAR2        :='SELF_SERVICE'
,p_debug_mode                           IN      VARCHAR2        :='N'
,p_max_msg_count                        IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_resource_list_mem_id         IN      NUMBER
,p_project_id               IN      NUMBER
,p_task_id              IN      NUMBER
,p_structure_version_id         IN      NUMBER
,p_as_of_date               IN      DATE -- Bug 3958686
,p_action               IN      VARCHAR2 -- Bug 3958686
,p_subprj_actual_exists         IN      VARCHAR2 := 'N' -- Bug 4490532
,p_object_version_id            IN      NUMBER := null -- Bug 4490532
,x_return_status            OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count                OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

   g1_debug_mode                VARCHAR2(1);
   l_version_enabled_flag        VARCHAR2(1);

   x_percent_complete_id     NUMBER;
   X_PROGRESS_ROLLUP_ID      NUMBER;

   l_api_name                   CONSTANT VARCHAR(30) := 'ASGN_DLV_TO_TASK_ROLLUP_PVT'                           ;
   l_api_version                CONSTANT NUMBER      := 1.0                                                     ;
   l_return_status              VARCHAR2(1)                                                                     ;
   l_msg_count                  NUMBER                                                                          ;
   l_msg_data                   VARCHAR2(250)                                                                   ;
   l_data                       VARCHAR2(250)                                                                   ;
   l_msg_index_out              NUMBER                                                                          ;
   l_error_msg_code             VARCHAR2(250)                                                                   ;
   l_user_id                    NUMBER          := FND_GLOBAL.USER_ID                                           ;
   l_login_id                   NUMBER          := FND_GLOBAL.LOGIN_ID                                          ;

   -- Bug 3958686 : Commented
   /*
   CURSOR cur_chk_asgn
   IS
     SELECT 'x'
      FROM pa_progress_rollup
     WHERE object_id = p_resource_list_mem_id
       and structure_version_id = p_structure_version_id
       and proj_element_id = p_task_id
       and structure_type = 'WORKPLAN'
       and object_type = 'PA_ASSIGNMENTS'
       and current_flag = 'Y';
   */

-- Bug 4490532 Begin
CURSOR c_get_subproject IS
SELECT obj2.object_id_to1 subprj_str_ver_id
, obj2.object_id_to2 subprj_id
, ver.proj_element_id subprj_proj_elem_id
from pa_object_relationships obj1
, pa_object_relationships obj2
, pa_proj_element_versions ver
WHERE obj1.object_id_from1 = p_object_version_id
AND obj1.relationship_type = 'S'
AND obj1.object_id_to1 = obj2.object_id_from1
AND obj2.relationship_type = 'LW'
AND obj2.object_id_to1 = ver.element_version_id
;
l_subprj_str_ver_id NUMBER;
l_subprj_id NUMBER;
l_subprj_proj_elem_id NUMBER;

-- We canot use directly the parent project
-- from pji_fm_xbs_accum_tmp1 table
-- because PJI table stores self amounts p_xxx
-- only for PC and not for PFC.

CURSOR c_get_subproj_act(c_str_version_id NUMBER, c_project_id NUMBER, c_proj_element_id NUMBER) IS
  SELECT
       ETC_LABOR_HRS ESTIMATED_REMAINING_EFFORT
      ,ACT_LABOR_HRS PPL_ACT_EFFORT_TO_DATE
      ,ACT_EQUIP_HRS EQPMT_ACT_EFFORT_TO_DATE
      ,ETC_EQUIP_HRS EQPMT_ETC_EFFORT
      ,ACT_POU_BRDN_COST-ACT_POU_LABOR_BRDN_COST-ACT_POU_EQUIP_BRDN_COST OTH_ACT_COST_TO_DATE_FC
      ,ACT_PRJ_BRDN_COST-ACT_PRJ_EQUIP_BRDN_COST-ACT_PRJ_LABOR_BRDN_COST  OTH_ACT_COST_TO_DATE_PC
      ,ETC_POU_BRDN_COST-ETC_POU_LABOR_BRDN_COST-ETC_POU_EQUIP_BRDN_COST OTH_ETC_COST_FC
      ,ETC_PRJ_BRDN_COST-ETC_PRJ_EQUIP_BRDN_COST-ETC_PRJ_LABOR_BRDN_COST OTH_ETC_COST_PC
      ,ACT_POU_LABOR_BRDN_COST PPL_ACT_COST_TO_DATE_FC
      ,ACT_PRJ_LABOR_BRDN_COST PPL_ACT_COST_TO_DATE_PC
      ,ETC_POU_LABOR_BRDN_COST PPL_ETC_COST_FC
      ,ETC_PRJ_LABOR_BRDN_COST PPL_ETC_COST_PC
      ,ACT_POU_EQUIP_BRDN_COST EQPMT_ACT_COST_TO_DATE_FC
      ,ACT_PRJ_EQUIP_BRDN_COST EQPMT_ACT_COST_TO_DATE_PC
      ,ETC_POU_EQUIP_BRDN_COST EQPMT_ETC_COST_FC
      ,ETC_PRJ_EQUIP_BRDN_COST EQPMT_ETC_COST_PC
      ,ACT_POU_RAW_COST-ACT_POU_LABOR_RAW_COST-ACT_POU_EQUIP_RAW_COST OTH_ACT_RAWCOST_TO_DATE_FC
      ,ACT_PRJ_RAW_COST-ACT_PRJ_EQUIP_RAW_COST-ACT_PRJ_LABOR_RAW_COST OTH_ACT_RAWCOST_TO_DATE_PC
      ,ETC_POU_RAW_COST-ETC_POU_LABOR_RAW_COST-ETC_POU_EQUIP_RAW_COST OTH_ETC_RAWCOST_FC
      ,ETC_PRJ_RAW_COST-ETC_PRJ_EQUIP_RAW_COST-ETC_PRJ_LABOR_RAW_COST OTH_ETC_RAWCOST_PC
      ,ACT_POU_LABOR_RAW_COST PPL_ACT_RAWCOST_TO_DATE_FC
      ,ACT_PRJ_LABOR_RAW_COST PPL_ACT_RAWCOST_TO_DATE_PC
      ,ETC_POU_LABOR_RAW_COST PPL_ETC_RAWCOST_FC
      ,ETC_PRJ_LABOR_RAW_COST PPL_ETC_RAWCOST_PC
      ,ACT_POU_EQUIP_RAW_COST EQPMT_ACT_RAWCOST_TO_DATE_FC
      ,ACT_PRJ_EQUIP_RAW_COST EQPMT_ACT_RAWCOST_TO_DATE_PC
      ,ETC_POU_EQUIP_RAW_COST EQPMT_ETC_RAWCOST_FC
      ,ETC_PRJ_EQUIP_RAW_COST EQPMT_ETC_RAWCOST_PC
  FROM pji_fm_xbs_accum_tmp1 pjitmp
 WHERE pjitmp.project_id  = c_project_id
AND struct_version_id = c_str_version_id
AND project_element_id =  c_proj_element_id
AND plan_version_id > 0
AND txn_currency_code is null
AND calendar_type = 'A'
AND res_list_member_id is null;
l_subproj_rec  c_get_subproj_act%ROWTYPE;
-- Bug 4490532 End

-- Bug 4661350 begin : Introduced local variables for sum of subprojects values
sp_ESTIMATED_REMAINING_EFFORT		NUMBER;
sp_PPL_ACT_EFFORT_TO_DATE		NUMBER;
sp_EQPMT_ACT_EFFORT_TO_DATE		NUMBER;
sp_EQPMT_ETC_EFFORT			NUMBER;
sp_OTH_ACT_COST_TO_DATE_FC		NUMBER;
sp_OTH_ACT_COST_TO_DATE_PC		NUMBER;
sp_OTH_ETC_COST_FC			NUMBER;
sp_OTH_ETC_COST_PC			NUMBER;
sp_PPL_ACT_COST_TO_DATE_FC		NUMBER;
sp_PPL_ACT_COST_TO_DATE_PC		NUMBER;
sp_PPL_ETC_COST_FC			NUMBER;
sp_PPL_ETC_COST_PC			NUMBER;
sp_EQPMT_ACT_COST_TO_DATE_FC		NUMBER;
sp_EQPMT_ACT_COST_TO_DATE_PC		NUMBER;
sp_EQPMT_ETC_COST_FC			NUMBER;
sp_EQPMT_ETC_COST_PC			NUMBER;
sp_OTH_ACT_RAWCOST_TO_DATE_FC		NUMBER;
sp_OTH_ACT_RAWCOST_TO_DATE_PC		NUMBER;
sp_OTH_ETC_RAWCOST_FC			NUMBER;
sp_OTH_ETC_RAWCOST_PC			NUMBER;
sp_PPL_ACT_RAWCOST_TO_DATE_FC		NUMBER;
sp_PPL_ACT_RAWCOST_TO_DATE_PC		NUMBER;
sp_PPL_ETC_RAWCOST_FC			NUMBER;
sp_PPL_ETC_RAWCOST_PC			NUMBER;
sp_EQPMT_ACT_RAWCOST_TODATE_FC		NUMBER;
sp_EQPMT_ACT_RAWCOST_TODATE_PC		NUMBER;
sp_EQPMT_ETC_RAWCOST_FC			NUMBER;
sp_EQPMT_ETC_RAWCOST_PC			NUMBER;
-- Bug 4661350 end

BEGIN

        g1_debug_mode := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',fnd_global.user_id,fnd_global.login_id,275,null,null), 'N');

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.init_err_stack ('PA_PROGRESS_PVT.convert_task_prog_to_assgn');
        END IF;

        IF (p_commit = FND_API.G_TRUE) THEN
                savepoint convert_task_prog_to_assgn;
        END IF;

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

     IF g1_debug_mode  = 'Y' THEN

         pa_debug.write(x_Module=>'PA_PROGRESS_PVT.convert_task_prog_to_assgn', x_Msg => 'p_resource_list_mem_id='||p_resource_list_mem_id, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_PVT.convert_task_prog_to_assgn', x_Msg => 'p_project_id='||p_project_id, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_PVT.convert_task_prog_to_assgn', x_Msg => 'p_structure_version_id='||p_structure_version_id, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_PVT.convert_task_prog_to_assgn', x_Msg => 'p_task_id='||p_task_id, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_PVT.convert_task_prog_to_assgn', x_Msg => 'p_as_of_date='||p_as_of_date, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_PROGRESS_PVT.convert_task_prog_to_assgn', x_Msg => 'p_action='||p_action, x_Log_Level=> 3);
     END IF;

     --bug 3958686, start

       IF p_action = 'SAVE' THEN
     delete from pa_percent_completes
         where project_id= p_project_id
         and task_id = p_task_id
         and object_id = p_resource_list_mem_id
     and object_type = 'PA_ASSIGNMENTS'
         and published_flag = 'N'
         and structure_type = 'WORKPLAN'
         ;

         delete from pa_progress_rollup
         where project_id= p_project_id
         and proj_element_id = p_task_id
         and object_id = p_resource_list_mem_id
         and current_flag = 'W'
     and object_type = 'PA_ASSIGNMENTS'
         and structure_type = 'WORKPLAN'
         and structure_version_id is null
         ;
       END IF;


    IF  p_action = 'PUBLISH' THEN
         delete from pa_percent_completes
         where project_id= p_project_id
         and task_id = p_task_id
         and object_id = p_resource_list_mem_id
     and object_type = 'PA_ASSIGNMENTS'
         and published_flag = 'N'
         and date_computed <= p_as_of_date
         and structure_type = 'WORKPLAN'
         ;

     delete from pa_percent_completes
     WHERE project_id = p_project_id
         and object_id = p_resource_list_mem_id
     and task_id = p_task_id
     and trunc(date_computed) = trunc(p_as_of_date)
     and structure_type = 'WORKPLAN'
     and object_type = 'PA_ASSIGNMENTS'
     and published_flag = 'Y';


         delete from pa_progress_rollup
         where project_id= p_project_id
         and proj_element_id = p_task_id
         and object_id = p_resource_list_mem_id
     and object_type = 'PA_ASSIGNMENTS'
         and current_flag = 'W'
         and as_of_date <= p_as_of_date
         and structure_type = 'WORKPLAN'
         and structure_version_id is null
         ;

         delete from pa_progress_rollup
         WHERE project_id = p_project_id
         and object_id = p_resource_list_mem_id
     and structure_version_id is null
         and proj_element_id = p_task_id
         and trunc(as_of_date) = trunc(p_as_of_date)
         and structure_type = 'WORKPLAN'
         and object_type = 'PA_ASSIGNMENTS'
         and current_flag in ('Y', 'N');

    end if;

     --bug 3958686, end

       --Create records in percent completes and rollup table for new assignment.


-- Added update code to set current_flag as N otherwise upon publishinh it will give error
-- ORA-00001: unique constraint (PA.PA_BUDGET_LINES_U1) violated in Package PA_FP_MAINTAIN_ACTUAL_PUB Procedure MAINTAIN_ACTUAL_AMT_RA
-- Patched thru Bug 4183307
IF  p_action = 'PUBLISH' THEN
  UPDATE pa_percent_completes
        SET current_flag = 'N'
        WHERE project_id = p_project_id
        AND object_id = p_resource_list_mem_id
        AND task_id = p_task_id
        AND current_flag = 'Y'
        AND object_type =  'PA_ASSIGNMENTS';

 UPDATE pa_progress_rollup
        SET current_flag = 'N'
        WHERE project_id = p_project_id
        AND object_id = p_resource_list_mem_id
        AND proj_element_id = p_task_id
        AND current_flag = 'Y'
        AND object_type = 'PA_ASSIGNMENTS'
    AND structure_version_id is null
    AND structure_type = 'WORKPLAN'
    ;
 END IF;

    -- Bug 4490532 Begin
    IF g1_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.convert_task_prog_to_assgn', x_Msg => 'p_subprj_actual_exists='||p_subprj_actual_exists, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_PVT.convert_task_prog_to_assgn', x_Msg => 'p_object_version_id='||p_object_version_id, x_Log_Level=> 3);
    END IF;
    l_subproj_rec := null;
    IF p_subprj_actual_exists = 'Y' THEN
	-- Bug 4661350 : Converted to FOR loop to support multiple sub projects
        --OPEN c_get_subproject;
        --FETCH c_get_subproject INTO l_subprj_str_ver_id, l_subprj_id, l_subprj_proj_elem_id;
        --CLOSE c_get_subproject;

		FOR l_rec IN c_get_subproject LOOP

			l_subproj_rec := null;

			OPEN c_get_subproj_act(l_rec.subprj_str_ver_id, l_rec.subprj_id, l_rec.subprj_proj_elem_id);
			FETCH c_get_subproj_act INTO l_subproj_rec;
			CLOSE c_get_subproj_act;
			-- Bug 4661350 : introduced local variable to store subprojects sum value

			sp_ESTIMATED_REMAINING_EFFORT	:= nvl(sp_ESTIMATED_REMAINING_EFFORT,0) + nvl(l_subproj_rec.ESTIMATED_REMAINING_EFFORT,0);
			sp_PPL_ACT_EFFORT_TO_DATE	:= nvl(sp_PPL_ACT_EFFORT_TO_DATE,0) + nvl(l_subproj_rec.PPL_ACT_EFFORT_TO_DATE,0);
			sp_EQPMT_ACT_EFFORT_TO_DATE	:= nvl(sp_EQPMT_ACT_EFFORT_TO_DATE,0) + nvl(l_subproj_rec.EQPMT_ACT_EFFORT_TO_DATE,0);
			sp_EQPMT_ETC_EFFORT		:= nvl(sp_EQPMT_ETC_EFFORT,0) + nvl(l_subproj_rec.EQPMT_ETC_EFFORT,0);
			sp_OTH_ACT_COST_TO_DATE_FC	:= nvl(sp_OTH_ACT_COST_TO_DATE_FC,0) + nvl(l_subproj_rec.OTH_ACT_COST_TO_DATE_FC,0);
			sp_OTH_ACT_COST_TO_DATE_PC	:= nvl(sp_OTH_ACT_COST_TO_DATE_PC,0) + nvl(l_subproj_rec.OTH_ACT_COST_TO_DATE_PC,0);
			sp_OTH_ETC_COST_FC		:= nvl(sp_OTH_ETC_COST_FC,0) + nvl(l_subproj_rec.OTH_ETC_COST_FC,0);
			sp_OTH_ETC_COST_PC		:= nvl(sp_OTH_ETC_COST_PC,0) + nvl(l_subproj_rec.OTH_ETC_COST_PC,0);
			sp_PPL_ACT_COST_TO_DATE_FC	:= nvl(sp_PPL_ACT_COST_TO_DATE_FC,0) + nvl(l_subproj_rec.PPL_ACT_COST_TO_DATE_FC,0);
			sp_PPL_ACT_COST_TO_DATE_PC	:= nvl(sp_PPL_ACT_COST_TO_DATE_PC,0) + nvl(l_subproj_rec.PPL_ACT_COST_TO_DATE_PC,0);
			sp_PPL_ETC_COST_FC		:= nvl(sp_PPL_ETC_COST_FC,0) + nvl(l_subproj_rec.PPL_ETC_COST_FC,0);
			sp_PPL_ETC_COST_PC		:= nvl(sp_PPL_ETC_COST_PC,0) + nvl(l_subproj_rec.PPL_ETC_COST_PC,0);
			sp_EQPMT_ACT_COST_TO_DATE_FC	:= nvl(sp_EQPMT_ACT_COST_TO_DATE_FC,0) + nvl(l_subproj_rec.EQPMT_ACT_COST_TO_DATE_FC,0);
			sp_EQPMT_ACT_COST_TO_DATE_PC	:= nvl(sp_EQPMT_ACT_COST_TO_DATE_PC,0) + nvl(l_subproj_rec.EQPMT_ACT_COST_TO_DATE_PC,0);
			sp_EQPMT_ETC_COST_FC		:= nvl(sp_EQPMT_ETC_COST_FC,0) + nvl(l_subproj_rec.EQPMT_ETC_COST_FC,0);
			sp_EQPMT_ETC_COST_PC		:= nvl(sp_EQPMT_ETC_COST_PC,0) + nvl(l_subproj_rec.EQPMT_ETC_COST_PC,0);
			sp_OTH_ACT_RAWCOST_TO_DATE_FC	:= nvl(sp_OTH_ACT_RAWCOST_TO_DATE_FC,0) + nvl(l_subproj_rec.OTH_ACT_RAWCOST_TO_DATE_FC,0);
			sp_OTH_ACT_RAWCOST_TO_DATE_PC	:= nvl(sp_OTH_ACT_RAWCOST_TO_DATE_PC,0) + nvl(l_subproj_rec.OTH_ACT_RAWCOST_TO_DATE_PC,0);
			sp_OTH_ETC_RAWCOST_FC		:= nvl(sp_OTH_ETC_RAWCOST_FC,0) + nvl(l_subproj_rec.OTH_ETC_RAWCOST_FC,0);
			sp_OTH_ETC_RAWCOST_PC		:= nvl(sp_OTH_ETC_RAWCOST_PC,0) + nvl(l_subproj_rec.OTH_ETC_RAWCOST_PC,0);
			sp_PPL_ACT_RAWCOST_TO_DATE_FC	:= nvl(sp_PPL_ACT_RAWCOST_TO_DATE_FC,0) + nvl(l_subproj_rec.PPL_ACT_RAWCOST_TO_DATE_FC,0);
			sp_PPL_ACT_RAWCOST_TO_DATE_PC	:= nvl(sp_PPL_ACT_RAWCOST_TO_DATE_PC,0) + nvl(l_subproj_rec.PPL_ACT_RAWCOST_TO_DATE_PC,0);
			sp_PPL_ETC_RAWCOST_FC		:= nvl(sp_PPL_ETC_RAWCOST_FC,0) + nvl(l_subproj_rec.PPL_ETC_RAWCOST_FC,0);
			sp_PPL_ETC_RAWCOST_PC		:= nvl(sp_PPL_ETC_RAWCOST_PC,0) + nvl(l_subproj_rec.PPL_ETC_RAWCOST_PC,0);
			sp_EQPMT_ACT_RAWCOST_TODATE_FC	:= nvl(sp_EQPMT_ACT_RAWCOST_TODATE_FC,0) + nvl(l_subproj_rec.EQPMT_ACT_RAWCOST_TO_DATE_FC,0);
			sp_EQPMT_ACT_RAWCOST_TODATE_PC	:= nvl(sp_EQPMT_ACT_RAWCOST_TODATE_PC,0) + nvl(l_subproj_rec.EQPMT_ACT_RAWCOST_TO_DATE_PC,0);
			sp_EQPMT_ETC_RAWCOST_FC		:= nvl(sp_EQPMT_ETC_RAWCOST_FC,0) + nvl(l_subproj_rec.EQPMT_ETC_RAWCOST_FC,0);
			sp_EQPMT_ETC_RAWCOST_PC		:= nvl(sp_EQPMT_ETC_RAWCOST_PC,0) + nvl(l_subproj_rec.EQPMT_ETC_RAWCOST_PC,0);
		END LOOP;

    END IF;
    -- Bug 4490532 End


        select PA_PERCENT_COMPLETES_S.nextval
          into x_percent_complete_id
        from dual;

        select PA_PROGRESS_ROLLUP_S.nextval
          into X_PROGRESS_ROLLUP_ID
          from dual;
     IF g1_debug_mode  = 'Y' THEN
         pa_debug.write(x_Module=>'PA_PROGRESS_PVT.convert_task_prog_to_assgn', x_Msg => 'Before Inserting into pa_percent_completes', x_Log_Level=> 3);
     END IF;
        INSERT INTO pa_percent_completes(
                  TASK_ID
                 ,DATE_COMPUTED
                 ,LAST_UPDATE_DATE
                 ,LAST_UPDATED_BY
                 ,CREATION_DATE
                 ,CREATED_BY
                 ,LAST_UPDATE_LOGIN
                 ,COMPLETED_PERCENTAGE
                 ,DESCRIPTION
                 ,PROJECT_ID
                 ,PM_PRODUCT_CODE
                 ,CURRENT_FLAG
                 ,PERCENT_COMPLETE_ID
                 ,OBJECT_ID
                 ,OBJECT_VERSION_ID
                 ,OBJECT_TYPE
                 ,STATUS_CODE
                 ,PROGRESS_STATUS_CODE
                 ,ESTIMATED_START_DATE
                 ,ESTIMATED_FINISH_DATE
                 ,ACTUAL_START_DATE
                 ,ACTUAL_FINISH_DATE
                 ,PUBLISHED_FLAG
                 ,PUBLISHED_BY_PARTY_ID
                 ,RECORD_VERSION_NUMBER
                 ,PROGRESS_COMMENT
                 ,HISTORY_FLAG
                 ,ATTRIBUTE_CATEGORY
                 ,ATTRIBUTE1
                 ,ATTRIBUTE2
                 ,ATTRIBUTE3
                 ,ATTRIBUTE4
                 ,ATTRIBUTE5
                 ,ATTRIBUTE6
                 ,ATTRIBUTE7
                 ,ATTRIBUTE8
                 ,ATTRIBUTE9
                 ,ATTRIBUTE10
                 ,ATTRIBUTE11
                 ,ATTRIBUTE12
                 ,ATTRIBUTE13
                 ,ATTRIBUTE14
                 ,ATTRIBUTE15
                 ,STRUCTURE_TYPE
                 )
          SELECT
                  TASK_ID
                 ,DATE_COMPUTED
                 ,SYSDATE
                 ,l_user_id
                 ,SYSDATE
                 ,l_user_id
                 ,l_login_id
                 ,null   --COMPLETED_PERCENTAGE
                 ,null   --DESCRIPTION
                 ,PROJECT_ID
                 ,PM_PRODUCT_CODE
                 ,CURRENT_FLAG
                 ,x_PERCENT_COMPLETE_ID
                 ,p_resource_list_mem_id  --OBJECT_ID
                 ,OBJECT_VERSION_ID
                 ,'PA_ASSIGNMENTS'  --OBJECT_TYPE
                 ,null              --STATUS_CODE
                 ,PROGRESS_STATUS_CODE
                 ,ESTIMATED_START_DATE
                 ,ESTIMATED_FINISH_DATE
                 ,ACTUAL_START_DATE
                 ,ACTUAL_FINISH_DATE
                 ,PUBLISHED_FLAG
                 ,PUBLISHED_BY_PARTY_ID
                 ,RECORD_VERSION_NUMBER
                 ,PROGRESS_COMMENT
                 ,HISTORY_FLAG
                 ,ATTRIBUTE_CATEGORY
                 ,ATTRIBUTE1
                 ,ATTRIBUTE2
                 ,ATTRIBUTE3
                 ,ATTRIBUTE4
                 ,ATTRIBUTE5
                 ,ATTRIBUTE6
                 ,ATTRIBUTE7
                 ,ATTRIBUTE8
                 ,ATTRIBUTE9
                 ,ATTRIBUTE10
                 ,ATTRIBUTE11
                 ,ATTRIBUTE12
                 ,ATTRIBUTE13
                 ,ATTRIBUTE14
                 ,ATTRIBUTE15
                 ,STRUCTURE_TYPE
           FROM pa_percent_completes
          WHERE project_id = p_project_id
              and object_id = p_task_id
              and task_id = p_task_id
              and structure_type = 'WORKPLAN'
          and trunc(date_computed) = trunc(p_as_of_date)
              --and published_flag = 'Y' --bug 3958686
              --and current_flag = 'Y'
              and ((p_action = 'SAVE' and published_flag = 'N')
                or (p_action = 'PUBLISH' and published_flag = 'Y' and current_flag = 'Y'))
              ;

     IF g1_debug_mode  = 'Y' THEN
         pa_debug.write(x_Module=>'PA_PROGRESS_PVT.convert_task_prog_to_assgn', x_Msg => 'Done Inserting into pa_percent_completes', x_Log_Level=> 3);
     END IF;
         -- Bug 4490532 : Subtracting the subproject amounts if available.
	 -- Bug 4661350 : Using newly introduced local variable to store subprojects sum value
          INSERT INTO pa_progress_rollup(
               PROGRESS_ROLLUP_ID
              ,PERCENT_COMPLETE_ID
              ,PROJECT_ID
              ,OBJECT_ID
              ,OBJECT_TYPE
              ,AS_OF_DATE
              ,OBJECT_VERSION_ID
              ,LAST_UPDATE_DATE
              ,LAST_UPDATED_BY
              ,CREATION_DATE
              ,CREATED_BY
              ,PROGRESS_STATUS_CODE
              ,LAST_UPDATE_LOGIN
              ,INCREMENTAL_WORK_QUANTITY
              ,CUMULATIVE_WORK_QUANTITY
              ,BASE_PERCENT_COMPLETE
              ,EFF_ROLLUP_PERCENT_COMP
              ,COMPLETED_PERCENTAGE
              ,ESTIMATED_START_DATE
              ,ESTIMATED_FINISH_DATE
              ,ACTUAL_START_DATE
              ,ACTUAL_FINISH_DATE
              ,ESTIMATED_REMAINING_EFFORT
              ,RECORD_VERSION_NUMBER
              ,BASE_PERCENT_COMP_DERIV_CODE
              ,BASE_PROGRESS_STATUS_CODE
              ,EFF_ROLLUP_PROG_STAT_CODE
              ,STRUCTURE_TYPE
              ,PROJ_ELEMENT_ID
              ,STRUCTURE_VERSION_ID
              ,PPL_ACT_EFFORT_TO_DATE
              ,EQPMT_ACT_EFFORT_TO_DATE
              ,EQPMT_ETC_EFFORT
              ,OTH_ACT_COST_TO_DATE_TC
              ,OTH_ACT_COST_TO_DATE_FC
              ,OTH_ACT_COST_TO_DATE_PC
              ,OTH_ETC_COST_TC
              ,OTH_ETC_COST_FC
              ,OTH_ETC_COST_PC
              ,PPL_ACT_COST_TO_DATE_TC
              ,PPL_ACT_COST_TO_DATE_FC
              ,PPL_ACT_COST_TO_DATE_PC
              ,PPL_ETC_COST_TC
              ,PPL_ETC_COST_FC
              ,PPL_ETC_COST_PC
              ,EQPMT_ACT_COST_TO_DATE_TC
              ,EQPMT_ACT_COST_TO_DATE_FC
              ,EQPMT_ACT_COST_TO_DATE_PC
              ,EQPMT_ETC_COST_TC
              ,EQPMT_ETC_COST_FC
              ,EQPMT_ETC_COST_PC
              ,EARNED_VALUE
              ,TASK_WT_BASIS_CODE
              ,CURRENT_FLAG
              ,PROJFUNC_COST_RATE_TYPE
              ,PROJFUNC_COST_EXCHANGE_RATE
              ,PROJFUNC_COST_RATE_DATE
              ,PROJ_COST_RATE_TYPE
              ,PROJ_COST_EXCHANGE_RATE
              ,PROJ_COST_RATE_DATE
              ,TXN_CURRENCY_CODE
              ,PROG_PA_PERIOD_NAME
              ,PROG_GL_PERIOD_NAME
              ,OTH_QUANTITY_TO_DATE
              ,OTH_ETC_QUANTITY
              ,OTH_ACT_RAWCOST_TO_DATE_TC
              ,OTH_ACT_RAWCOST_TO_DATE_FC
              ,OTH_ACT_RAWCOST_TO_DATE_PC
              ,OTH_ETC_RAWCOST_TC
              ,OTH_ETC_RAWCOST_FC
              ,OTH_ETC_RAWCOST_PC
              ,PPL_ACT_RAWCOST_TO_DATE_TC
              ,PPL_ACT_RAWCOST_TO_DATE_FC
              ,PPL_ACT_RAWCOST_TO_DATE_PC
              ,PPL_ETC_RAWCOST_TC
              ,PPL_ETC_RAWCOST_FC
              ,PPL_ETC_RAWCOST_PC
              ,EQPMT_ACT_RAWCOST_TO_DATE_TC
              ,EQPMT_ACT_RAWCOST_TO_DATE_FC
              ,EQPMT_ACT_RAWCOST_TO_DATE_PC
              ,EQPMT_ETC_RAWCOST_TC
              ,EQPMT_ETC_RAWCOST_FC
              ,EQPMT_ETC_RAWCOST_PC
              )
          SELECT
               X_PROGRESS_ROLLUP_ID
              ,x_percent_complete_id
              ,PROJECT_ID
              ,p_resource_list_mem_id
              ,'PA_ASSIGNMENTS'
              ,AS_OF_DATE
              ,OBJECT_VERSION_ID
              ,SYSDATE
              ,LAST_UPDATED_BY
              ,SYSDATE
              ,CREATED_BY
              ,PROGRESS_STATUS_CODE
              ,LAST_UPDATE_LOGIN
              ,null                 --INCREMENTAL_WORK_QUANTITY
              ,null                 --CUMULATIVE_WORK_QUANTITY
              ,null                 --BASE_PERCENT_COMPLETE
              ,null                 --EFF_ROLLUP_PERCENT_COMP
              ,null                 --COMPLETED_PERCENTAGE
              ,ESTIMATED_START_DATE
              ,ESTIMATED_FINISH_DATE
              ,ACTUAL_START_DATE
              ,ACTUAL_FINISH_DATE
              ,ESTIMATED_REMAINING_EFFORT - nvl(sp_ESTIMATED_REMAINING_EFFORT,0)
              ,1
              ,null                --BASE_PERCENT_COMP_DERIV_CODE
              ,BASE_PROGRESS_STATUS_CODE
              ,null                --EFF_ROLLUP_PROG_STAT_CODE
              ,STRUCTURE_TYPE
              ,PROJ_ELEMENT_ID
              ,STRUCTURE_VERSION_ID
              ,PPL_ACT_EFFORT_TO_DATE- nvl(sp_PPL_ACT_EFFORT_TO_DATE,0)
              ,EQPMT_ACT_EFFORT_TO_DATE- nvl(sp_EQPMT_ACT_EFFORT_TO_DATE,0)
              ,EQPMT_ETC_EFFORT- nvl(sp_EQPMT_ETC_EFFORT,0)
              ,OTH_ACT_COST_TO_DATE_TC
              ,OTH_ACT_COST_TO_DATE_FC- nvl(sp_OTH_ACT_COST_TO_DATE_FC,0)
              ,OTH_ACT_COST_TO_DATE_PC- nvl(sp_OTH_ACT_COST_TO_DATE_PC,0)
              ,OTH_ETC_COST_TC
              ,OTH_ETC_COST_FC- nvl(sp_OTH_ETC_COST_FC,0)
              ,OTH_ETC_COST_PC- nvl(sp_OTH_ETC_COST_PC,0)
              ,PPL_ACT_COST_TO_DATE_TC
              ,PPL_ACT_COST_TO_DATE_FC- nvl(sp_PPL_ACT_COST_TO_DATE_FC,0)
              ,PPL_ACT_COST_TO_DATE_PC- nvl(sp_PPL_ACT_COST_TO_DATE_PC,0)
              ,PPL_ETC_COST_TC
              ,PPL_ETC_COST_FC- nvl(sp_PPL_ETC_COST_FC,0)
              ,PPL_ETC_COST_PC- nvl(sp_PPL_ETC_COST_PC,0)
              ,EQPMT_ACT_COST_TO_DATE_TC
              ,EQPMT_ACT_COST_TO_DATE_FC- nvl(sp_EQPMT_ACT_COST_TO_DATE_FC,0)
              ,EQPMT_ACT_COST_TO_DATE_PC- nvl(sp_EQPMT_ACT_COST_TO_DATE_PC,0)
              ,EQPMT_ETC_COST_TC
              ,EQPMT_ETC_COST_FC- nvl(sp_EQPMT_ETC_COST_FC,0)
              ,EQPMT_ETC_COST_PC- nvl(sp_EQPMT_ETC_COST_PC,0)
              ,EARNED_VALUE
              ,TASK_WT_BASIS_CODE
              ,CURRENT_FLAG
              ,PROJFUNC_COST_RATE_TYPE
              ,PROJFUNC_COST_EXCHANGE_RATE
              ,PROJFUNC_COST_RATE_DATE
              ,PROJ_COST_RATE_TYPE
              ,PROJ_COST_EXCHANGE_RATE
              ,PROJ_COST_RATE_DATE
              ,TXN_CURRENCY_CODE
              ,PROG_PA_PERIOD_NAME
              ,PROG_GL_PERIOD_NAME
              ,OTH_QUANTITY_TO_DATE
              ,OTH_ETC_QUANTITY
              ,OTH_ACT_RAWCOST_TO_DATE_TC
              ,OTH_ACT_RAWCOST_TO_DATE_FC- nvl(sp_OTH_ACT_RAWCOST_TO_DATE_FC,0)
              ,OTH_ACT_RAWCOST_TO_DATE_PC- nvl(sp_OTH_ACT_RAWCOST_TO_DATE_PC,0)
              ,OTH_ETC_RAWCOST_TC
              ,OTH_ETC_RAWCOST_FC- nvl(sp_OTH_ETC_RAWCOST_FC,0)
              ,OTH_ETC_RAWCOST_PC- nvl(sp_OTH_ETC_RAWCOST_PC,0)
              ,PPL_ACT_RAWCOST_TO_DATE_TC
              ,PPL_ACT_RAWCOST_TO_DATE_FC- nvl(sp_PPL_ACT_RAWCOST_TO_DATE_FC,0)
              ,PPL_ACT_RAWCOST_TO_DATE_PC- nvl(sp_PPL_ACT_RAWCOST_TO_DATE_PC,0)
              ,PPL_ETC_RAWCOST_TC
              ,PPL_ETC_RAWCOST_FC- nvl(sp_PPL_ETC_RAWCOST_FC,0)
              ,PPL_ETC_RAWCOST_PC- nvl(sp_PPL_ETC_RAWCOST_PC,0)
              ,EQPMT_ACT_RAWCOST_TO_DATE_TC
              ,EQPMT_ACT_RAWCOST_TO_DATE_FC- nvl(sp_EQPMT_ACT_RAWCOST_TODATE_FC,0)
              ,EQPMT_ACT_RAWCOST_TO_DATE_PC- nvl(sp_EQPMT_ACT_RAWCOST_TODATE_PC,0)
              ,EQPMT_ETC_RAWCOST_TC
              ,EQPMT_ETC_RAWCOST_FC- nvl(sp_EQPMT_ETC_RAWCOST_FC,0)
              ,EQPMT_ETC_RAWCOST_PC- nvl(sp_EQPMT_ETC_RAWCOST_PC,0)
          FROM pa_progress_rollup
         WHERE project_id = p_project_id
           and object_id = p_task_id
           and structure_version_id is NULL
           and proj_element_id = p_task_id
           and structure_type = 'WORKPLAN'
           --and current_flag = 'Y'; --bug 3958686
	   and trunc(as_of_date) = trunc(p_as_of_date)
           and ((p_action = 'SAVE' and current_flag = 'W')
             or (p_action = 'PUBLISH' and current_flag in ('Y', 'N')));


     IF g1_debug_mode  = 'Y' THEN
         pa_debug.write(x_Module=>'PA_PROGRESS_PVT.convert_task_prog_to_assgn', x_Msg => 'Done Inserting into pa_progress_rollup', x_Log_Level=> 3);
     END IF;

    -- END IF;

     x_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                IF p_commit = FND_API.G_TRUE THEN
                        rollback to convert_task_prog_to_assgn;
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF p_commit = FND_API.G_TRUE THEN
                        rollback to convert_task_prog_to_assgn;
                END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_PVT',
                              p_procedure_name => 'convert_task_prog_to_assgn',
                              p_error_text     => SUBSTRB(SQLERRM,1,120));
        WHEN OTHERS THEN
                IF p_commit = FND_API.G_TRUE THEN
                        rollback to ASGN_DLV_TO_TASK_ROLLUP_PVT2;
                END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_PVT',
                              p_procedure_name => 'convert_task_prog_to_assgn',
                              p_error_text     => SUBSTRB(SQLERRM,1,120));
                raise;

END convert_task_prog_to_assgn;


--bug 4046422, moved this api from PAFPCPFB.pls to this package
/*=============================================================================
 This is a private api that copies progress/actuals from one workplan version
 to another with in the project. Functionally this is called to copy progress
 from last published version while publishing a new version

  p_calling_context will have values WP_PROGRESS and WP_APPLY_PROGRESS_TO_WORKING.
==============================================================================*/

PROCEDURE copy_actuals_for_workplan(
           p_calling_context            IN   VARCHAR2 DEFAULT 'WP_PROGRESS'
          ,p_project_id                 IN   pa_projects_all.project_id%TYPE
          ,p_source_struct_ver_id       IN   pa_proj_element_versions.element_version_id%TYPE
          ,p_target_struct_ver_id       IN   pa_proj_element_versions.element_version_id%TYPE
          ,x_return_status              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                  OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                   OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

    --Start of variables used for debugging

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER := 0;
    l_msg_data           VARCHAR2(2000);
    l_data               VARCHAR2(2000);
    l_msg_index_out      NUMBER;
    l_debug_mode         VARCHAR2(30);

    --End of variables used for debugging

    l_res_list_mismatch_flag        VARCHAR2(1);
    l_target_people_rlm_id          pa_resource_list_members.resource_list_member_id%TYPE;

    CURSOR budget_version_info_cur(c_str_ver_id NUMBER) IS
    SELECT resource_list_id,
           etc_start_date,
           budget_version_id
    FROM   pa_budget_versions
    WHERE  project_id = p_project_id
    AND    wp_version_flag = 'Y'
    AND    project_structure_version_id = c_str_ver_id;

    l_source_str_ver_info_rec    budget_version_info_cur%ROWTYPE;
    l_target_str_ver_info_rec    budget_version_info_cur%ROWTYPE;

    l_project_ids                 SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    l_struture_version_ids        SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    l_proj_thru_dates_tbl         SYSTEM.PA_DATE_TBL_TYPE:= SYSTEM.PA_DATE_TBL_TYPE();
    l_no_of_recs_for_processing   NUMBER;--Bug 3953743

    /* Begin code to fix Bug # 4144300. */

    CURSOR cur_ppabpt(c_budget_version_id NUMBER, t_budget_version_id NUMBER) IS
    SELECT source.project_id               PROJECT_ID
           ,p_target_struct_ver_id         STRUCTURE_VERSION_ID
           ,source.task_id                 TASK_ID
           ,target.resource_assignment_id  RESOURCE_ASSIGNMENT_ID
           ,bl.txn_init_burdened_cost      ACTUAL_COST
           ,bl.init_quantity               ACTUAL_EFFORT
           ,bl.period_name                 PERIOD_NAME
           ,bl.txn_currency_code           TXN_CURRENCY_CODE
           ,bl.project_init_burdened_cost  ACTUAL_COST_PC
           ,bl.init_burdened_cost          ACTUAL_COST_FC
           ,bl.txn_init_raw_cost           ACTUAL_RAWCOST
           ,bl.project_init_raw_cost       ACTUAL_RAWCOST_PC
           ,bl.init_raw_cost               ACTUAL_RAWCOST_FC
           ,bl.start_date                  START_DATE
           ,bl.end_date                    END_DATE
           ,source.resource_list_member_id RESOURCE_LIST_MEMBER_ID
    FROM  pa_resource_assignments source,
          pa_resource_assignments target,
          pa_budget_lines bl
    WHERE bl.resource_assignment_id = source.resource_assignment_id
    and   source.budget_version_id =  c_budget_version_id
    and   target.budget_version_id = t_budget_version_id
    and   target.resource_list_member_id = decode(l_res_list_mismatch_flag, 'N', source.resource_list_member_id, l_target_people_rlm_id)
    and   source.task_id = target.task_id
    and   source.project_id = target.project_id
    and   bl.budget_version_id = c_budget_version_id
    and   (bl.init_quantity is not null or
           bl.txn_init_raw_cost is not null);

    cur_ppabpt_rec cur_ppabpt%ROWTYPE;

    I_PROJECT_ID        PA_PLSQL_DATATYPES.Num15TabTyp;
    I_STRUCTURE_VERSION_ID  PA_PLSQL_DATATYPES.Num15TabTyp;
    I_TASK_ID           PA_PLSQL_DATATYPES.Num15TabTyp;
    I_RESOURCE_ASSIGNMENT_ID    PA_PLSQL_DATATYPES.Num15TabTyp;
    I_ACTUAL_COST       PA_PLSQL_DATATYPES.AmtTabTyp;
    I_ACTUAL_EFFORT     PA_PLSQL_DATATYPES.QtyTabtyp;
    I_PERIOD_NAME       PA_PLSQL_DATATYPES.Char30TabTyp;
    I_TXN_CURRENCY_CODE     PA_PLSQL_DATATYPES.Char15TabTyp;
    I_ACTUAL_COST_PC        PA_PLSQL_DATATYPES.AmtTabTyp;
    I_ACTUAL_COST_FC        PA_PLSQL_DATATYPES.AmtTabTyp;
    I_ACTUAL_RAWCOST        PA_PLSQL_DATATYPES.AmtTabTyp;
    I_ACTUAL_RAWCOST_PC     PA_PLSQL_DATATYPES.AmtTabTyp;
    I_ACTUAL_RAWCOST_FC     PA_PLSQL_DATATYPES.AmtTabTyp;
    I_RESOURCE_LIST_MEMBER_ID   PA_PLSQL_DATATYPES.Num15TabTyp;
    I_START_DATE                PA_PLSQL_DATATYPES.DateTabTyp;
    I_END_DATE                  PA_PLSQL_DATATYPES.DateTabTyp;

    l_index NUMBER := null;
    i       NUMBER := null;

    /* End code to fix Bug # 4144300. */

   /* Begin code to fix Bug # 4141850. */

   cursor cur_as_of_date(p_project_id NUMBER) is
   select max(as_of_date)
   from pa_progress_rollup ppr
   where ppr.project_id = p_project_id
   and ppr.structure_version_id is null
   and ppr.structure_type = 'WORKPLAN'
   and ppr.current_flag <> 'W';

   /* End code to fix Bug # 4141850. */

--bug 4255329
   l_as_of_date      DATE;
   l_bv_id           NUMBER;
--end bug 4255329
BEGIN
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_debug_mode := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',fnd_global.user_id,fnd_global.login_id,275,null,null), 'N');

    -- Set curr function
    pa_debug.set_curr_function(
                p_function   =>'pa_fp_copy_from_pkg.copy_actuals_for_workplan'
               ,p_debug_mode => l_debug_mode );

    -- Check for business rules violations
    IF l_debug_mode = 'Y' THEN
    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.copy_actuals_for_workplan', x_Msg => 'Validating input parameters', x_Log_Level=> 3);
    END IF;

    IF (p_project_id IS NULL) OR
       (p_source_struct_ver_id IS NULL) OR
       (p_target_struct_ver_id IS NULL)
    THEN

        IF l_debug_mode = 'Y' THEN
       pa_debug.write(x_Module=>'PA_PROGRESS_PVT.copy_actuals_for_workplan', x_Msg => 'Project_id = '||p_project_id, x_Log_Level=> 3);
       pa_debug.write(x_Module=>'PA_PROGRESS_PVT.copy_actuals_for_workplan', x_Msg => 'p_source_struct_ver_id = '||p_source_struct_ver_id, x_Log_Level=> 3);
       pa_debug.write(x_Module=>'PA_PROGRESS_PVT.copy_actuals_for_workplan', x_Msg => 'p_target_struct_ver_id = '||p_target_struct_ver_id, x_Log_Level=> 3);
        END IF;

        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                              p_token1         => 'PROCEDURENAME',
                              p_value1         => 'pa_progress_pvt.copy_actuals_for_workplan');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    -- Fetch resource lists for both source and target structure versions
    OPEN budget_version_info_cur(p_source_struct_ver_id);
    FETCH budget_version_info_cur INTO l_source_str_ver_info_rec;
    CLOSE budget_version_info_cur;

    OPEN budget_version_info_cur(p_target_struct_ver_id);
    FETCH budget_version_info_cur INTO l_target_str_ver_info_rec;
    CLOSE budget_version_info_cur;

    -- If resource lists are different as of now the only possible case is that
    -- source resource list is uncategorized res list and target res list is a
    -- categorized res list in which case all the actuals from source would get
    -- mapped to the 'PEOPLE' res class rlm id of target res list

    IF l_source_str_ver_info_rec.resource_list_id <> l_target_str_ver_info_rec.resource_list_id THEN
        l_res_list_mismatch_flag := 'Y';

        BEGIN
            -- Fetch PEOPLE res class member id for the target target res list
            SELECT resource_list_member_id
            INTO   l_target_people_rlm_id
            FROM   pa_resource_list_members rlm,
                   pa_resource_lists_all_bg rl
            WHERE  rl.resource_list_id = l_target_str_ver_info_rec.resource_list_id
            AND    rl.resource_list_id = rlm.resource_list_id
            AND    object_type = Decode(control_flag, 'Y','RESOURCE_LIST','PROJECT')
            AND    object_id = Decode(control_flag, 'Y',rl.resource_list_id,p_project_id)
            AND    resource_class_flag = 'Y'
            AND    resource_class_code = 'PEOPLE';
        EXCEPTION
          WHEN OTHERS THEN
             RAISE;
        END;
    ELSE
        l_res_list_mismatch_flag := 'N';
    END IF;

    -- Delete any existing records from the table first
    DELETE FROM PA_PROG_ACT_BY_PERIOD_TEMP;

    -- Populate the PA_PROG_ACT_BY_PERIOD_TEMP table from pa_budget_lines init columns data
    -- Using task_id and resource list member id fetch mapping target resource assignment id

    /* Begin code to fix Bug # 4144300. */

    -- Populate the PL/SQL tables that will be used for the Bulk insert.

    l_index := 0;

    for cur_ppabpt_rec in cur_ppabpt(l_source_str_ver_info_rec.budget_version_id, l_target_str_ver_info_rec.budget_version_id)
    loop

    l_index := l_index+1;

    I_PROJECT_ID(l_index) := cur_ppabpt_rec.PROJECT_ID;
    I_STRUCTURE_VERSION_ID(l_index) := cur_ppabpt_rec.STRUCTURE_VERSION_ID;
    I_TASK_ID(l_index) := cur_ppabpt_rec.TASK_ID;
    I_RESOURCE_ASSIGNMENT_ID(l_index) := cur_ppabpt_rec.RESOURCE_ASSIGNMENT_ID;
    I_ACTUAL_COST(l_index) := cur_ppabpt_rec.ACTUAL_COST;
    I_ACTUAL_EFFORT(l_index) := cur_ppabpt_rec.ACTUAL_EFFORT;
    I_PERIOD_NAME(l_index) := cur_ppabpt_rec.PERIOD_NAME;
    I_TXN_CURRENCY_CODE(l_index) := cur_ppabpt_rec.TXN_CURRENCY_CODE;
    I_ACTUAL_COST_PC(l_index) := cur_ppabpt_rec.ACTUAL_COST_PC;
    I_ACTUAL_COST_FC(l_index) := cur_ppabpt_rec.ACTUAL_COST_FC;
    I_ACTUAL_RAWCOST(l_index) := cur_ppabpt_rec.ACTUAL_RAWCOST;
    I_ACTUAL_RAWCOST_PC(l_index) := cur_ppabpt_rec.ACTUAL_RAWCOST_PC;
    I_ACTUAL_RAWCOST_FC(l_index) := cur_ppabpt_rec.ACTUAL_RAWCOST_FC;
    I_RESOURCE_LIST_MEMBER_ID(l_index) := cur_ppabpt_rec.RESOURCE_LIST_MEMBER_ID;
    I_START_DATE(l_index) := cur_ppabpt_rec.start_date;
    I_END_DATE(l_index) := cur_ppabpt_rec.end_date;

    end loop;

    -- Bulk insert the PL/SQL tables into the table: PA_PROG_ACT_BY_PERIOD_TEMP.

    forall i in 1..l_index

        INSERT INTO PA_PROG_ACT_BY_PERIOD_TEMP
            (
            PROJECT_ID
            ,STRUCTURE_VERSION_ID
            ,TASK_ID
            ,RESOURCE_ASSIGNMENT_ID
            ,AS_OF_DATE
            ,ACTUAL_COST
            ,ACTUAL_EFFORT
            ,PERIOD_NAME
            ,TXN_CURRENCY_CODE
            ,ACTUAL_COST_PC
            ,ACTUAL_COST_FC
            ,ACTUAL_RAWCOST
            ,ACTUAL_RAWCOST_PC
            ,ACTUAL_RAWCOST_FC
            ,RESOURCE_LIST_MEMBER_ID
            ,HIDDEN_RES_ASSGN_ID
            ,CURRENT_FLAG
            ,OBJECT_TYPE
            ,PERCENT_COMPLETE_ID
            ,ATTRIBUTE1
            ,ATTRIBUTE2
            ,ATTRIBUTE3
            ,ATTRIBUTE4
            ,ATTRIBUTE5
            ,ATTRIBUTE6
            ,start_date
            ,finish_date
            )
    VALUES
        (
        I_PROJECT_ID(i)
        ,I_STRUCTURE_VERSION_ID(i)
        ,I_TASK_ID(i)
        ,I_RESOURCE_ASSIGNMENT_ID(i)
        ,to_date(null)
        ,I_ACTUAL_COST(i)
        ,I_ACTUAL_EFFORT(i)
        ,I_PERIOD_NAME(i)
        ,I_TXN_CURRENCY_CODE(i)
        ,I_ACTUAL_COST_PC(i)
        ,I_ACTUAL_COST_FC(i)
        ,I_ACTUAL_RAWCOST(i)
        ,I_ACTUAL_RAWCOST_PC(i)
        ,I_ACTUAL_RAWCOST_FC(i)
        ,I_RESOURCE_LIST_MEMBER_ID(i)
        ,to_number(null)
        ,to_char(null)
        ,to_char(null)
        ,to_number(null)
        ,to_char(null)
        ,to_char(null)
        ,to_char(null)
        ,to_number(null)
        ,to_number(null)
        ,to_number(null)
        ,I_START_DATE(i)
        ,I_END_DATE(i)
        );

    /* End code to fix Bug # 4144300. */

    /* Begin commenting out the following code to fix Bug # 4144300.

    INSERT INTO PA_PROG_ACT_BY_PERIOD_TEMP
    (
        PROJECT_ID
        ,STRUCTURE_VERSION_ID
        ,TASK_ID
        ,RESOURCE_ASSIGNMENT_ID
        ,AS_OF_DATE
        ,ACTUAL_COST
        ,ACTUAL_EFFORT
        ,PERIOD_NAME
        ,TXN_CURRENCY_CODE
        ,ACTUAL_COST_PC
        ,ACTUAL_COST_FC
        ,ACTUAL_RAWCOST
        ,ACTUAL_RAWCOST_PC
        ,ACTUAL_RAWCOST_FC
        ,RESOURCE_LIST_MEMBER_ID
        ,HIDDEN_RES_ASSGN_ID
        ,CURRENT_FLAG
        ,OBJECT_TYPE
        ,PERCENT_COMPLETE_ID
        ,ATTRIBUTE1
        ,ATTRIBUTE2
        ,ATTRIBUTE3
        ,ATTRIBUTE4
        ,ATTRIBUTE5
        ,ATTRIBUTE6
    )
    SELECT   target.project_id               PROJECT_ID
             ,p_target_struct_ver_id         STRUCTURE_VERSION_ID
             ,target.task_id                 TASK_ID
             ,target.resource_assignment_id  RESOURCE_ASSIGNMENT_ID
             ,NULL                           AS_OF_DATE
             ,bl.txn_init_burdened_cost      ACTUAL_COST
             ,bl.init_quantity               ACTUAL_EFFORT
             ,bl.period_name                 PERIOD_NAME
             ,bl.txn_currency_code           TXN_CURRENCY_CODE
             ,bl.project_init_burdened_cost  ACTUAL_COST_PC
             ,bl.init_burdened_cost          ACTUAL_COST_FC
             ,bl.txn_init_raw_cost           ACTUAL_RAWCOST
             ,bl.project_init_raw_cost       ACTUAL_RAWCOST_PC
             ,bl.init_raw_cost               ACTUAL_RAWCOST_FC
             ,target.resource_list_member_id RESOURCE_LIST_MEMBER_ID
             ,NULL                           HIDDEN_RES_ASSGN_ID
             ,NULL                           CURRENT_FLAG
             ,NULL                           OBJECT_TYPE
             ,NULL                           PERCENT_COMPLETE_ID
             ,NULL                           ATTRIBUTE1
             ,NULL                           ATTRIBUTE2
             ,NULL                           ATTRIBUTE3
             ,NULL                           ATTRIBUTE4
             ,NULL                           ATTRIBUTE5
             ,NULL                           ATTRIBUTE6
    FROM  pa_resource_assignments source,
          pa_budget_lines bl,
          pa_resource_assignments target
    WHERE bl.budget_version_id = l_source_str_ver_info_rec.budget_version_id
    and   bl.resource_assignment_id = source.resource_assignment_id
    AND   target.budget_version_id = l_target_str_ver_info_rec.budget_version_id
    AND   target.task_id = source.task_id
    AND   target.resource_list_member_id =
                decode(l_res_list_mismatch_flag, 'N', source.resource_list_member_id,
                                                 l_target_people_rlm_id)
    --bug 3956258
    AND   'Y' = PA_PROGRESS_UTILS.check_object_has_prog(
                                     source.project_id   --p_project_id
                                    ,source.task_id      --p_proj_element_id
                                    -- ,decode( source.ta_display_flag, 'N', source.task_id,source.resource_list_member_id) --p_object_id -- Fix for Bug # 4112283.
                    ,source.resource_list_member_id -- Fix for Bug # 4112283.
                                    -- ,decode( source.ta_display_flag, 'N','PA_TASKS', 'PA_ASSIGNMENTS') --p_object_type -- Fix for Bug # 4112283.
                    ,'PA_ASSIGNMENTS' -- Fix for Bug # 4112283.
                                    ,'WORKPLAN') --p_structure_type

    --end bug 3956258
    ;

    End commenting out the following code to fix Bug # 4144300. */

    l_no_of_recs_for_processing := SQL%ROWCOUNT;

    IF l_debug_mode = 'Y' THEN
    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.copy_actuals_for_workplan', x_Msg => 'No of records inserted into PA_PROG_ACT_BY_PERIOD_TEMP '||l_no_of_recs_for_processing, x_Log_Level=> 3);
    END IF;

    --Bug 3953743. If No records are inserted into the tmp table then the API need not be called at all.
    IF l_no_of_recs_for_processing > 0 THEN

        -- Call api that either creates/updates existing budget lines using the temp table
        l_project_ids.extend(1);
        l_project_ids(1) := p_project_id;
        l_struture_version_ids.extend(1);
        l_struture_version_ids(1) := p_target_struct_ver_id;
        l_proj_thru_dates_tbl.extend(1);

        /* Begin code to fix Bug # 4141850. */

        -- l_proj_thru_dates_tbl(1) := (l_source_str_ver_info_rec.etc_start_date - 1);

    open cur_as_of_date(p_project_id);
    fetch cur_as_of_date into l_proj_thru_dates_tbl(1);
    close cur_as_of_date;

        /* End code to fix Bug # 4141850. */
        PA_FP_MAINTAIN_ACTUAL_PUB.MAINTAIN_ACTUAL_AMT_WRP
              (P_PROJECT_ID_TAB                   => l_project_ids,
               P_WP_STR_VERSION_ID_TAB            => l_struture_version_ids,
               P_ACTUALS_THRU_DATE                => l_proj_thru_dates_tbl,
               P_CALLING_CONTEXT                  => p_calling_context,
               X_RETURN_STATUS                    => l_return_status,
               X_MSG_COUNT                        => l_msg_count,
               X_MSG_DATA                         => l_msg_data
             );

        IF l_return_status <> 'S' THEN
            IF l_debug_mode = 'Y' THEN
           pa_debug.write(x_Module=>'PA_PROGRESS_PVT.copy_actuals_for_workplan', x_Msg => 'Called API MAINTAIN_ACTUAL_AMT_WRP api returned error', x_Log_Level=> 3);
            END IF;

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

   --bug 4255329
    ELSE

       IF l_debug_mode = 'Y' THEN
          pa_debug.write(x_Module=>'PA_PROGRESS_PVT.copy_actuals_for_workplan', x_Msg => 'Opening cursor cur_as_of_date before updating BV etc start date', x_Log_Level=> 3);
       END IF;

       open cur_as_of_date(p_project_id);
       fetch cur_as_of_date into l_as_of_date;
       close cur_as_of_date;

       IF l_debug_mode = 'Y' THEN
          pa_debug.write(x_Module=>'PA_PROGRESS_PVT.copy_actuals_for_workplan', x_Msg => 'l_as_of_date='||l_as_of_date, x_Log_Level=> 3);
       END IF;

       SELECT budget_version_id into l_bv_id
         FROM PA_BUDGET_VERSIONS
        WHERE project_id = P_PROJECT_ID
          AND project_structure_version_id = p_target_struct_ver_id
          AND nvl(wp_version_flag,'N')  = 'Y';

       IF l_debug_mode = 'Y' THEN
          pa_debug.write(x_Module=>'PA_PROGRESS_PVT.copy_actuals_for_workplan', x_Msg => 'l_bv_id='||l_bv_id, x_Log_Level=> 3);
       END IF;

       UPDATE  pa_budget_versions
          SET  etc_start_date = l_as_of_date + 1
        WHERE  budget_version_id = l_bv_id;

       IF l_debug_mode = 'Y' THEN
          pa_debug.write(x_Module=>'PA_PROGRESS_PVT.copy_actuals_for_workplan', x_Msg => 'Done with updating pa_budget_versions ETC start date', x_Log_Level=> 3);
       END IF;

   --bug 4255329

    END IF;--IF l_no_of_recs_for_processing > 0 THEN

    IF l_debug_mode = 'Y' THEN
    pa_debug.write(x_Module=>'PA_PROGRESS_PVT.copy_actuals_for_workplan', x_Msg => 'Exiting copy_actuals_for_workplan', x_Log_Level=> 3);
    END IF;

    -- reset curr function
    pa_debug.reset_curr_function();

EXCEPTION

   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
       l_msg_count := FND_MSG_PUB.count_msg;
       IF l_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE
                  ,p_msg_index      => 1
                  ,p_msg_count      => l_msg_count
                  ,p_msg_data       => l_msg_data
                  ,p_data           => l_data
                  ,p_msg_index_out  => l_msg_index_out);

           x_msg_data := l_data;
           x_msg_count := l_msg_count;
       ELSE
           x_msg_count := l_msg_count;
       END IF;

       x_return_status := FND_API.G_RET_STS_ERROR;

       IF l_debug_mode = 'Y' THEN
      pa_debug.write(x_Module=>'PA_PROGRESS_PVT.copy_actuals_for_workplan', x_Msg => 'Invalid Arguments Passed Or called api raised an error', x_Log_Level=> 3);
       END IF;

       -- reset curr function
       pa_debug.reset_curr_function();

       RETURN;
   WHEN Others THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'pa_fp_copy_from_pkg'
                               ,p_procedure_name  => 'copy_actuals_for_workplan');

       IF l_debug_mode = 'Y' THEN
       pa_debug.write(x_Module=>'PA_PROGRESS_PVT.copy_actuals_for_workplan', x_Msg => 'Unexpected Error'||SQLERRM, x_Log_Level=> 3);
       END IF;

       -- reset curr function
       pa_debug.Reset_Curr_Function();

       RAISE;
END copy_actuals_for_workplan;

-- Bug 4575855 : Added rollup_prog_from_subprojs
PROCEDURE ROLLUP_PROG_FROM_SUBPROJS(
  p_api_version                 IN      NUMBER          :=1.0
 ,p_init_msg_list               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_commit                      IN      VARCHAR2        :=FND_API.G_FALSE
 ,p_validate_only               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validation_level            IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module              IN      VARCHAR2        :='SELF_SERVICE'
 ,p_debug_mode                  IN      VARCHAR2        :='N'
 ,p_max_msg_count               IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id                  IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_structure_version_id        IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,x_return_status               OUT  NOCOPY VARCHAR2  -- 4565506 Added while merging
 ,x_msg_count                   OUT  NOCOPY NUMBER    -- 4565506 Added while merging
 ,x_msg_data                    OUT  NOCOPY VARCHAR2 -- 4565506 Added while merging
)
IS

l_api_name           CONSTANT   VARCHAR2(30)    := 'ROLLUP_PROG_FROM_SUBPROJS';
l_api_version        CONSTANT   NUMBER          := p_api_version;
l_user_id                       NUMBER          := FND_GLOBAL.USER_ID;
l_login_id                      NUMBER          := FND_GLOBAL.LOGIN_ID;
l_return_status                 VARCHAR2(1);
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(250);
g1_debug_mode           VARCHAR2(1);
/*
CURSOR cur_select_grid
IS
SELECT distinct -- 4600547 Added distinct
a.project_id
, a.element_version_id
, a.prg_level
, ppr.as_of_date
FROM pa_proj_element_versions a,
pa_proj_elem_ver_structure b,
pa_proj_structure_types ppst,
pa_proj_element_versions c,
pa_progress_rollup ppr
WHERE
c.project_id = p_project_id
AND c.element_version_id = p_structure_version_id  ---5095632
AND c.prg_group = a.prg_group
AND a.project_id = b.project_id
AND a.element_version_id = b.element_version_id
AND b.status_code = 'STRUCTURE_PUBLISHED'
AND b.latest_eff_published_flag = 'Y'
AND a.proj_element_id = ppst.proj_element_id
AND ppst.structure_type_id =1
AND a.prg_level > 1
AND a.proj_element_id = ppr.object_id
AND a.project_id = ppr.project_id
AND ppr.object_type = 'PA_STRUCTURES'
AND ppr.structure_version_id is null
AND ppr.structure_type = 'WORKPLAN'
AND ppr.current_flag = 'Y'
order by a.prg_level desc;    --select the lowest level of projects first.
*/

CURSOR cur_select_grid
IS
SELECT distinct -- 4600547 Added distinct
a.project_id
, a.element_version_id
, a.prg_level
, ppr.as_of_date
FROM pa_proj_element_versions a,
pa_proj_elem_ver_structure b,
pa_proj_structure_types ppst,
pa_proj_element_versions c,
pa_progress_rollup ppr
WHERE
c.project_id = p_project_id
AND c.element_version_id = p_structure_version_id  -- Backported performance fix from R12 bug 5095632
AND c.prg_group = a.prg_group
AND a.project_id = b.project_id
AND a.element_version_id = b.element_version_id
AND b.status_code = 'STRUCTURE_PUBLISHED'
AND b.latest_eff_published_flag = 'Y'
AND a.proj_element_id = ppst.proj_element_id
AND ppst.structure_type_id =1
AND a.prg_level > 1
AND a.proj_element_id = ppr.object_id
AND a.project_id = ppr.project_id
AND ppr.object_type = 'PA_STRUCTURES'
AND ppr.structure_version_id is null
AND ppr.structure_type = 'WORKPLAN'
AND ppr.current_flag = 'Y'
AND c.prg_group is not null --Bug 7607077
AND (a.project_id = p_project_id OR a.project_id IN (
      -- Bottom up
      SELECT object_id_from2
      FROM pa_object_relationships
      START with object_id_to2 = p_project_id and relationship_type = 'LW'
      CONNECT BY PRIOR object_id_from2 = object_id_to2
      UNION
      -- Top down
      SELECT object_id_to2
      FROM pa_object_relationships
      START with object_id_from2 = p_project_id and relationship_type = 'LW'
      CONNECT BY PRIOR object_id_to2 = object_id_from2
))
order by a.prg_level desc;    --select the lowest level of projects first.

BEGIN

    g1_debug_mode := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',fnd_global.user_id,fnd_global.login_id,275,null,null), 'N');

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.init_err_stack ('PA_PROGRESS_PVT.ROLLUP_PROG_FROM_SUBPROJS');
        END IF;

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROG_FROM_SUBPROJS', x_Msg => 'PA_PROGRESS_PVT.ROLLUP_PROG_FROM_SUBPROJS Start : Passed Parameters :', x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROG_FROM_SUBPROJS', x_Msg => 'p_project_id='||p_project_id, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROG_FROM_SUBPROJS', x_Msg => 'p_structure_version_id='||p_structure_version_id, x_Log_Level=> 3);
        END IF;

    IF g1_debug_mode  = 'Y' THEN
                pa_debug.init_err_stack ('PA_PROGRESS_PVT.ROLLUP_PROG_FROM_SUBPROJS');
        END IF;

        IF (p_commit = FND_API.G_TRUE) THEN
                savepoint rollup_prog_from_subprojs2;
        END IF;

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

    FOR rec_subprojs IN cur_select_grid LOOP
        IF g1_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROG_FROM_SUBPROJS', x_Msg => 'rec_subprojs.project_id='||rec_subprojs.project_id, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROG_FROM_SUBPROJS', x_Msg => 'rec_subprojs.element_version_id='||rec_subprojs.element_version_id, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROG_FROM_SUBPROJS', x_Msg => 'rec_subprojs.as_of_date='||rec_subprojs.as_of_date, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROG_FROM_SUBPROJS', x_Msg => 'Calling populate_pji_tab_for_plan', x_Log_Level=> 3);
        END IF;

        pa_progress_pub.populate_pji_tab_for_plan(
            p_init_msg_list     => FND_API.G_FALSE
            ,p_commit       => FND_API.G_FALSE
            ,p_calling_module   => p_calling_module
            ,p_project_id       => rec_subprojs.project_id
            ,p_structure_version_id => rec_subprojs.element_version_id
            ,p_baselined_str_ver_id => PA_PROJECT_STRUCTURE_UTILS.Get_Baseline_Struct_Ver(rec_subprojs.project_id)
            ,p_structure_type       => 'WORKPLAN'
            ,p_program_rollup_flag  => 'Y'
            ,p_calling_context  => 'SUMMARIZE'
            ,p_as_of_date       => rec_subprojs.as_of_date
            ,x_return_status        => x_return_status
            ,x_msg_count            => x_msg_count
            ,x_msg_data             => x_msg_data);

        IF g1_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROG_FROM_SUBPROJS', x_Msg => 'After Calling populate_pji_tab_for_plan x_return_status='||x_return_status, x_Log_Level=> 3);
        END IF;


        IF x_return_status <> 'S' THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF g1_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROG_FROM_SUBPROJS', x_Msg => 'Calling program_rollup_pvt', x_Log_Level=> 3);
        END IF;

        pa_progress_pvt.program_rollup_pvt(
            p_init_msg_list         => FND_API.G_FALSE
            ,p_commit               => FND_API.G_FALSE
            ,p_validate_only        => FND_API.G_FALSE
            ,p_project_id           => rec_subprojs.project_id
            ,p_as_of_date           => rec_subprojs.as_of_date
            ,p_structure_type       => 'WORKPLAN'
            ,p_structure_ver_id     => rec_subprojs.element_version_id
            ,x_return_status        => x_return_status
            ,x_msg_count            => x_msg_count
            ,x_msg_data             => x_msg_data);

        IF g1_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROGRESS_PVT.ROLLUP_PROG_FROM_SUBPROJS', x_Msg => 'After Calling program_rollup_pvt x_return_status='||x_return_status, x_Log_Level=> 3);
        END IF;

        IF x_return_status <> 'S' THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END LOOP;

        IF (p_commit = FND_API.G_TRUE) THEN
                COMMIT;
        END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to rollup_prog_from_subprojs2;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to rollup_prog_from_subprojs2;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_PVT',
                              p_procedure_name => 'ROLLUP_PROG_FROM_SUBPROJS',
                              p_error_text     => SUBSTRB(SQLERRM,1,120));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to rollup_prog_from_subprojs2;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_PVT',
                              p_procedure_name => 'ROLLUP_PROG_FROM_SUBPROJS',
                              p_error_text     => SUBSTRB(SQLERRM,1,120));
      raise;
END ROLLUP_PROG_FROM_SUBPROJS;

--Added following procedure for MRup3 merge
PROCEDURE UPD_PROG_RECS_STR_DELETE(p_project_id         IN  NUMBER,
                                   p_str_ver_id_to_del  IN  NUMBER,
                                   x_return_status      OUT NOCOPY VARCHAR2,
                                   x_msg_count          OUT NOCOPY NUMBER,
                                   x_msg_data           OUT NOCOPY VARCHAR2) IS

cursor new_str_version_id is
select ppevs.element_version_id
  from pa_proj_elem_ver_structure ppevs, pa_proj_structure_types ppst
 where ppevs.project_id = p_project_id
   and ppevs.proj_element_id = ppst.proj_element_id
   and ppst.structure_type_id = 1
   and ppevs.STATUS_CODE = 'STRUCTURE_PUBLISHED'
   and ppevs.PUBLISHED_DATE = (select min(ppevs.published_date)
                               from pa_proj_elem_ver_structure ppevs,
                                    pa_proj_structure_types ppst
                               where ppevs.project_id = p_project_id
                               and ppevs.proj_element_id = ppst.proj_element_id
                               and ppst.structure_type_id = 1
                               and ppevs.STATUS_CODE = 'STRUCTURE_PUBLISHED'
                               and ppevs.published_date > (select published_date
                                                from pa_proj_elem_ver_structure
                                                where project_id = p_project_id
                                                and element_version_id = p_str_ver_id_to_del));

l_str_ver_id   number;
  -- Begin. Bug 5452282
  cursor obj_version_id (x_str_ver_id  pa_proj_element_versions.element_version_id%type)is
    select ppev.element_version_id  old_element_version_id,
           ppev1.element_version_id new_element_version_id,
           ppev.proj_element_id
      from pa_proj_element_versions ppev,
           pa_proj_element_versions ppev1
     where ppev.project_id = p_project_id
       and ppev.parent_structure_version_id = p_str_ver_id_to_del
       and ppev.proj_element_id = ppev1.proj_element_id
       and ppev1.parent_structure_version_id = x_str_ver_id;

  l_old_element_version_id_tab          SYSTEM.PA_NUM_TBL_TYPE  := SYSTEM.PA_NUM_TBL_TYPE();
  l_new_element_version_id_tab          SYSTEM.PA_NUM_TBL_TYPE  := SYSTEM.PA_NUM_TBL_TYPE();
  l_proj_element_id_tab                 SYSTEM.PA_NUM_TBL_TYPE  := SYSTEM.PA_NUM_TBL_TYPE();
  -- End. Bug 5452282

BEGIN
x_return_status := 'S';
  open new_str_version_id;
  fetch new_str_version_id into l_str_ver_id;
  close new_str_version_id;

  if (l_str_ver_id is null) then
     raise FND_API.G_EXC_ERROR;
  end if;

  -- Begin bug 5452282
  open obj_version_id(l_str_ver_id);
  fetch obj_version_id bulk collect into l_old_element_version_id_tab,
                                         l_new_element_version_id_tab,
                                         l_proj_element_id_tab;
  close obj_version_id;

  --- update pa_percent_completes table with new object_version_ids
  IF l_new_element_version_id_tab.count > 0 THEN
  --- update pa_percent_completes table with new object_version_ids
  Forall i in l_new_element_version_id_tab.first..l_new_element_version_id_tab.last
    update pa_percent_completes  ppc
       set object_version_id = l_new_element_version_id_tab(i)
     where project_id = p_project_id
       and task_id = l_proj_element_id_tab(i)
       and structure_type = 'WORKPLAN'
       and object_version_id = l_old_element_version_id_tab(i);

  --- update pa_progress_rollup table with new object_version_ids
  Forall i in l_new_element_version_id_tab.first..l_new_element_version_id_tab.last
    update pa_progress_rollup ppr
       set object_version_id = l_new_element_version_id_tab(i)
      where project_id = p_project_id
       and proj_element_id = l_proj_element_id_tab(i)
       and structure_type = 'WORKPLAN'
       and structure_version_id is null
       and object_version_id = l_old_element_version_id_tab(i);
  End if;

exception
when FND_API.G_EXC_ERROR then
  x_return_status := 'E';
  fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_PVT',
                          p_procedure_name => 'UPD_PROG_RECS_STR_DELETE',
                          p_error_text     => 'This workplan structure cannot be deleted.');

when OTHERS then
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROGRESS_PVT',
                          p_procedure_name => 'UPD_PROG_RECS_STR_DELETE',
                          p_error_text     => SUBSTRB(SQLERRM,1,120));
  raise;

END UPD_PROG_RECS_STR_DELETE;

end PA_PROGRESS_PVT;

/
