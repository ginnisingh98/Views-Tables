--------------------------------------------------------
--  DDL for Package Body PA_FP_ROLLUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_ROLLUP_PKG" as
/* $Header: PAFPRLPB.pls 120.3 2005/09/26 12:20:20 rnamburi noship $ */

l_module_name           VARCHAR2(100) := 'pa.plsql.pa_fp_rollup_pkg';
g_plsql_max_array_size  NUMBER        := 200;
g_first_ra_id           pa_resource_assignments.RESOURCE_ASSIGNMENT_ID%TYPE;

-- Bug Fix: 4569365. Removed MRC code.
-- g_mrc_exception         EXCEPTION; /* FPB2: MRC */

   /* when called in context of entire version g_first_ra_id will be set to zero else it will be set to
      the current value of resource assigmnet id in the pa_resource_assignment_s sequence to track as
      which resource assignments are inserted in this run */

/*=================================================================================================
 POPULATE_LOCAL_VARS: This is a common api which takes care of populating the local variables
 based on a budget version id. These local variables are required for processing in other APIs.
 Hence this procedure is called wherever local variables need to be populated.
=================================================================================================*/

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE POPULATE_LOCAL_VARS(p_budget_version_id     IN NUMBER
                             ,x_project_id           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                             ,x_resource_list_id     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                             ,x_uncat_flag           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                             ,x_uncat_rlm_id         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                             ,x_rl_group_type_id     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                             ,x_planning_level       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                             ,x_return_status        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                             ,x_msg_count            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                             ,x_msg_data             OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

        l_uncat_res_list_id         pa_resource_lists.RESOURCE_LIST_ID%TYPE;
        l_uncat_res_list_mem_id     pa_resource_list_members.RESOURCE_LIST_MEMBER_ID%TYPE;
        l_uncat_res_id              pa_resource_list_members.RESOURCE_ID%TYPE;
        l_uncat_track_as_labor_flg  pa_resource_assignments.TRACK_AS_LABOR_FLAG%TYPE;
        l_err_code                  NUMBER;
        l_err_stage                 VARCHAR2(100);
        l_err_stack                 VARCHAR2(1000);

        l_msg_count       NUMBER := 0;
        l_data            VARCHAR2(2000);
        l_msg_data        VARCHAR2(2000);
        l_msg_index_out   NUMBER;
        l_return_status   VARCHAR2(2000);
        l_debug_mode      VARCHAR2(30);

BEGIN

          -- Set the error stack.

             pa_debug.set_err_stack('PA_FP_ROLLUP_PKG.Populate_Local_Vars');

          -- Get the Debug mode into local variable and set it to 'Y'if its NULL

             fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
             l_debug_mode := NVL(l_debug_mode, 'Y');

          -- Initialize the return status to success
              x_return_status := FND_API.G_RET_STS_SUCCESS;
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.set_process('POPULATE_LOCAL_VARS: ' || 'PLSQL','LOG',l_debug_mode);
              END IF;

              pa_debug.g_err_stage := 'In PA_FP_ROLLUP_PKG.Populate_Local_Vars ';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('POPULATE_LOCAL_VARS: ' || l_module_name,pa_debug.g_err_stage,2);
              END IF;

           /* Check for Budget Version ID not being NULL. */
           IF ( p_budget_version_id IS NULL) THEN
                   pa_debug.g_err_stage := 'Err- Budget Version ID cannot be NULL.';
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('POPULATE_LOCAL_VARS: ' || l_module_name,pa_debug.g_err_stage,5);
                   END IF;
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                        p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
                   RAISE PA_FP_ROLLUP_PKG.Invalid_Arg_Exc;
           END IF;

       /* Populating the Resource List ID, Uncategorized flag of the Resource List and the Group Type ID
          of the Resource list attached to the Budget version. */

       pa_debug.g_err_stage := 'Getting the value of the local variables.';
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('POPULATE_LOCAL_VARS: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

          SELECT pbv.resource_list_id
                ,prl.uncategorized_flag
                ,prl.group_resource_type_id
                ,pbv.project_id
            INTO x_resource_list_id
                ,x_uncat_flag
                ,x_rl_group_type_id
                ,x_project_id
            FROM pa_budget_versions pbv
                ,pa_resource_lists  prl
           WHERE budget_version_id = p_budget_version_id
             AND pbv.resource_list_id = prl.resource_list_id; /* M21-AUG: Join was missing */


        /* Only if the Resource List is uncategorized, set the x_uncat_rlm_id
           as the uncat resource list member id else it will remain as default 0. */

        IF (x_uncat_flag = 'Y') THEN

          /* Populating the variable l_uncat_rlm_id which contains the Resource List Member ID if
             the Resource List attached is uncategorized, else its value is 0. */

             /* M21-AUG: made call to this procedure parameterized */
             pa_debug.g_err_stage := 'calling pa_get_resource.get_uncateg_resource_info';
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write('POPULATE_LOCAL_VARS: ' || l_module_name,pa_debug.g_err_stage,3);
             END IF;

             pa_get_resource.get_uncateg_resource_info(p_resource_list_id        => l_uncat_res_list_id
                                                      ,p_resource_list_member_id => l_uncat_res_list_mem_id
                                                      ,p_resource_id             => l_uncat_res_id
                                                      ,p_track_as_labor_flag     => l_uncat_track_as_labor_flg
                                                      ,p_err_code                => l_err_code
                                                      ,p_err_stage               => l_err_stage
                                                      ,p_err_stack               => l_err_stack);

             x_uncat_rlm_id := l_uncat_res_list_mem_id;

        ELSE

            x_uncat_rlm_id := 0;

        END IF;

          /* Getting the Planning Level of the Budget Version ID. */
           pa_debug.g_err_stage := 'calling pa_fin_plan_utils.Get_Fin_Plan_Level_Code';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('POPULATE_LOCAL_VARS: ' || l_module_name,pa_debug.g_err_stage,3);
           END IF;

           x_planning_level := pa_fin_plan_utils.Get_Fin_Plan_Level_Code(p_budget_version_id);
           /* M23-AUG: changed following select to function call
           SELECT  decode(fin_plan_preference_code, PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY,cost_fin_plan_level_code,
                        PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY,revenue_fin_plan_level_code,
                        PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME,all_fin_plan_level_code) planning_level
             INTO  x_planning_level
             FROM  pa_proj_fp_options
            WHERE  fin_plan_version_id = p_budget_version_id;
           */

      pa_debug.reset_err_stack;

EXCEPTION
  WHEN PA_FP_ROLLUP_PKG.Invalid_Arg_Exc THEN
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
      ELSE
             x_msg_count := l_msg_count;
      END IF;
      pa_debug.reset_err_stack;
    RAISE;
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_FP_ROLLUP_PKG'
            ,p_procedure_name => 'POPULATE_LOCAL_VARS');
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('POPULATE_LOCAL_VARS: ' || l_module_name,SQLERRM,5);
        END IF;
        pa_debug.reset_err_stack;

        raise FND_API.G_EXC_UNEXPECTED_ERROR;

END POPULATE_LOCAL_VARS;


/*=================================================================================================
 INSERT_PARENT_REC_TMP: This is a common api which is used to insert records into pa_fp_ra_map_tmp
 based on the Level of the records being inserted (i.e Resource Group level, Task level and Parent
 Task level) for rollup of amounts into the Denorm table. This procedure is called from
 Refresh_Period_Denorm and Insert_Parent_Rec_Tmp.
=================================================================================================*/
PROCEDURE INSERT_PARENT_REC_TMP(p_budget_version_id               IN pa_budget_versions.budget_version_id%TYPE
                               ,PX_INSERTING_RES_GROUP_LEVEL       IN OUT NOCOPY boolean --File.Sql.39 bug 4440895
                               ,PX_INSERTING_TASK_LEVEL            IN OUT NOCOPY boolean --File.Sql.39 bug 4440895
                               ,PX_INSERTING_PARENT_TASK_LEVEL     IN OUT NOCOPY boolean --File.Sql.39 bug 4440895
                               ,p_curr_rollup_level               IN NUMBER) IS

l_debug_mode        VARCHAR2(30);
l_resource_list_id  pa_resource_lists.RESOURCE_LIST_ID%TYPE;
l_uncat_flag        pa_resource_lists.UNCATEGORIZED_FLAG%TYPE;
l_rl_group_type_id  pa_resource_lists.GROUP_RESOURCE_TYPE_ID%TYPE;
l_uncat_rlm_id      pa_resource_lists.RESOURCE_LIST_ID%TYPE;
l_project_id        pa_projects.project_id%TYPE;
l_planning_level    pa_proj_fp_options.ALL_FIN_PLAN_LEVEL_CODE%TYPE;

l_msg_count         NUMBER := 0;
l_msg_data          VARCHAR2(2000);
l_return_status     VARCHAR2(2000);

BEGIN

        /* #2723515: Added call to Populate_Local_Vars to get the uncat rlm id
           which will be used down the line to retrieve task level records. */

        populate_local_vars(p_budget_version_id    => p_budget_version_id,
                            x_project_id           => l_project_id,
                            x_resource_list_id     => l_resource_list_id,
                            x_uncat_flag           => l_uncat_flag,
                            x_uncat_rlm_id         => l_uncat_rlm_id,
                            x_rl_group_type_id     => l_rl_group_type_id,
                            x_planning_level       => l_planning_level,
                            x_return_status        => l_return_status,
                            x_msg_count            => l_msg_count,
                            x_msg_data             => l_msg_data);

        -- The variable isn't set when the refresh _period_denorm api is called
        -- from refresh_period_profile api.

        IF g_first_ra_id IS NULL THEN
              g_first_ra_id := 0;
        END IF;

        /* delete older records not to be used in this table. */
        DELETE from pa_fp_ra_map_tmp;

        pa_debug.g_err_stage := 'deleted ' || sql%rowcount || ' records';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('INSERT_PARENT_REC_TMP: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        /* Insert Parent Records into PA_FP_RA_MAP_TMP table with the system_reference1
           as that passed to this procedure. */

        pa_debug.g_err_stage := 'Inserting recs into pa_fp_ra_map_tmp';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('INSERT_PARENT_REC_TMP: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        IF PX_INSERTING_RES_GROUP_LEVEL THEN
              /* we need to insert only last that is resource level records in tmp table.
                 This is required because in case resource list is grouped users can enter amounts at
                 resource group level.
              */
              INSERT INTO PA_FP_RA_MAP_TMP
                        (RESOURCE_ASSIGNMENT_ID
                        ,PARENT_ASSIGNMENT_ID
                        ,UNIT_OF_MEASURE)
              SELECT resource_assignment_id
                    ,parent_assignment_id
                    ,decode(resource_assignment_type,PA_FP_CONSTANTS_PKG.G_ROLLED_UP,
                             PA_FP_CONSTANTS_PKG.G_UNIT_OF_MEASURE_HOURS,pra.unit_of_measure) unit_of_measure
                FROM pa_resource_assignments pra, pa_resource_list_members prlm
               WHERE pra.budget_version_id = p_budget_version_id
                 AND pra.resource_list_member_id = prlm.resource_list_member_id
                 AND prlm.parent_member_id IS NOT NULL
                 AND pra.parent_assignment_id > g_first_ra_id;

              PX_INSERTING_RES_GROUP_LEVEL := false;
              PX_INSERTING_TASK_LEVEL := true;


        ELSIF PX_INSERTING_TASK_LEVEL THEN
              /* When inserting task level records we need to select those records from resource assignments
                 for which parent member id is null. These could be either resource group level records or
                 resource level records depending upon whether resource list is grouped or not.
              */
              INSERT INTO PA_FP_RA_MAP_TMP
                        (RESOURCE_ASSIGNMENT_ID
                        ,PARENT_ASSIGNMENT_ID
                        ,UNIT_OF_MEASURE)
              SELECT resource_assignment_id
                    ,parent_assignment_id
                    ,decode(resource_assignment_type,PA_FP_CONSTANTS_PKG.G_ROLLED_UP,
                             PA_FP_CONSTANTS_PKG.G_UNIT_OF_MEASURE_HOURS,pra.unit_of_measure) unit_of_measure
                FROM pa_resource_assignments pra, pa_resource_list_members prlm
               WHERE pra.budget_version_id = p_budget_version_id
                 AND pra.resource_list_member_id = prlm.resource_list_member_id
                 AND prlm.parent_member_id IS NULL
                 AND pra.parent_assignment_id > g_first_ra_id;

              PX_INSERTING_PARENT_TASK_LEVEL := true;
              PX_INSERTING_TASK_LEVEL := false;
              PX_INSERTING_RES_GROUP_LEVEL := false;

        ELSIF PX_INSERTING_PARENT_TASK_LEVEL THEN
              /* in this case we should start with last level in wbs and then go up the ladder. This is to avoid
                 selecting the same parent twice due to differnece in wbs across various branches
              */
              INSERT INTO pa_fp_ra_map_tmp
                    (RESOURCE_ASSIGNMENT_ID
                    ,PARENT_ASSIGNMENT_ID
                    ,UNIT_OF_MEASURE)
              SELECT pra.resource_assignment_id
                    ,pra.parent_assignment_id
                    ,decode(resource_assignment_type,PA_FP_CONSTANTS_PKG.G_ROLLED_UP,
                             PA_FP_CONSTANTS_PKG.G_UNIT_OF_MEASURE_HOURS,pra.unit_of_measure) unit_of_measure
               FROM pa_resource_assignments pra, pa_tasks pt
              WHERE pra.budget_version_id = p_budget_version_id
                AND pra.task_id = pt.task_id
                AND pra.resource_list_member_id in (0,l_uncat_rlm_id) -- Added for bug #2723515
                and pt.wbs_level = p_curr_rollup_level
                AND pra.parent_assignment_id > g_first_ra_id;

        END IF;

        /* we need to insert only those records which match the current wbs level */

        pa_debug.g_err_stage := 'inserted ' || sql%rowcount || ' records now deleting previous level records ';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('INSERT_PARENT_REC_TMP: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

EXCEPTION
  WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_FP_ROLLUP_PKG'
            ,p_procedure_name => 'Insert_Parent_Rec_Tmp');
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('INSERT_PARENT_REC_TMP: ' || l_module_name,SQLERRM,5);
        END IF;

        raise FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Parent_Rec_Tmp;

/*====================================================================================================
  ROLLUP_BUDGET_VERSION: This is the main API which will do whatever necessary for doing rollup into
  pa_resource_assignments, PA_PROJ_PERIODS_DENORM and pa_budget_versions_tables.


      r11.5 FP.M Developement ----------------------------------

      08-JAN-2004 jwhite    Bug 3362316
                            Extensively rewrote  Rollup_Budget_Version. Purged
                            most of the obsolete logic because there was
                            a lot of it.


                            - Replaced pre-M rollup logic with two-level rollup:
                              a) pa_budget_lines to pa_resource_assignments
                              b) pa_resource_assignments to pa_budget_versions

                            - For p_entire_version = 'N', gutted all logic for
                              this condition. All logic was obsolete.

      18-FEB-2004 jwhite     Bug 3441943
                             For the Rollup_Budget_Version procedure, modified cursor and
                             update logic to separately total people (labor) and equiment quantities.




 ===================================================================================================*/

PROCEDURE ROLLUP_BUDGET_VERSION(
           p_budget_version_id      IN NUMBER
          ,p_entire_version         IN VARCHAR2
          ,p_context                IN VARCHAR2
          ,x_return_status         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count             OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data              OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895

        l_resource_list_id       pa_resource_lists.RESOURCE_LIST_ID%TYPE;
        l_uncat_flag             pa_resource_lists.UNCATEGORIZED_FLAG%TYPE;
        l_rl_group_type_id       pa_resource_lists.GROUP_RESOURCE_TYPE_ID%TYPE;
        l_uncat_rlm_id           pa_resource_lists.RESOURCE_LIST_ID%TYPE;
        l_project_id             pa_projects.project_id%TYPE;
        l_planning_level         pa_proj_fp_options.ALL_FIN_PLAN_LEVEL_CODE%TYPE;
        l_proj_raw_cost          pa_resource_assignments.TOTAL_PROJECT_RAW_COST%TYPE;
        l_proj_burdened_cost     pa_resource_assignments.TOTAL_PROJECT_BURDENED_COST%TYPE;
        l_proj_revenue           pa_resource_assignments.TOTAL_PROJECT_REVENUE%TYPE;
    /*    l_quantity               pa_resource_assignments.TOTAL_PLAN_QUANTITY%TYPE;  -- bug 3441943 */
        l_projfunc_raw_cost      pa_resource_assignments.TOTAL_PLAN_RAW_COST%TYPE;
        l_projfunc_burdened_cost pa_resource_assignments.TOTAL_PLAN_BURDENED_COST%TYPE;
        l_projfunc_revenue       pa_resource_assignments.TOTAL_PLAN_REVENUE%TYPE;
        l_rec_insert             NUMBER;
        l_data_source            VARCHAR2(20);
        l_proj_raw_cost_tbl      l_proj_raw_cost_tbl_typ;
        l_proj_burd_cost_tbl     l_proj_burd_cost_tbl_typ;
        l_proj_revenue_tbl       l_proj_revenue_tbl_typ;
        l_projfunc_raw_cost_tbl  l_projfunc_raw_cost_tbl_typ;
        l_projfunc_burd_cost_tbl l_projfunc_burd_cost_tbl_typ;
        l_projfunc_revenue_tbl   l_projfunc_revenue_tbl_typ;
        l_quantity_tbl           l_quantity_tbl_typ;
        l_uom_tbl                l_unit_of_measure_tbl_typ;
        l_ra_id_tbl              l_ra_id_tbl_typ;

        l_period_profile_id      PA_BUDGET_VERSIONS.PERIOD_PROFILE_ID%TYPE;

        l_msg_count       NUMBER := 0;
        l_data            VARCHAR2(2000);
        l_msg_data        VARCHAR2(2000);
        l_msg_index_out   NUMBER;
        l_return_status   VARCHAR2(2000);
        l_debug_mode      VARCHAR2(30);

        -- Bug 3362316, 08-JAN-2004:  ---------------------

        l_org_forecast_flag	PA_PROJECT_TYPES_ALL.org_project_flag%TYPE;

        -- End, Bug 3362316, 08-JAN-2004:  ---------------------

        -- Bug 3441943, 18-FEB-2004: New Vars to sum people (labor) and equipment quantities ------------

        l_labor_quantity               pa_resource_assignments.TOTAL_PLAN_QUANTITY%TYPE;
        l_equip_quantity               pa_resource_assignments.TOTAL_PLAN_QUANTITY%TYPE;

        -- End, Bug 3441943, 18-FEB-2004: New Vars to sum people and equipment quantities -------


        /* #2800670: Added the following cursor instead of a Single Select so that
           if the Project Level rolled up record does not exist then the select
           does not give an error. */

        -- Bug 3362316, 08-JAN-2004: changed to query all version assignment records  --------------------------

        -- Bug 3441943, 18-FEB-2004: Added DECODE to separately sum people (labor) and equipment quantities ------------

        -- Bug 3968340, 29-OCT-2004: Added DECODE to rollup quantity only if UOM is hours

        CURSOR c_proj_level_amounts(p_budget_version_id IN NUMBER) IS
          SELECT sum(nvl(total_project_raw_cost,0))
                ,sum(nvl(total_project_burdened_cost,0))
                ,sum(nvl(total_project_revenue,0))
                ,sum(nvl(total_plan_raw_cost,0))
                ,sum(nvl(total_plan_burdened_cost,0))
                ,sum(nvl(total_plan_revenue,0))
                ,sum(decode(RESOURCE_CLASS_CODE, 'PEOPLE', decode(unit_of_measure,'HOURS',nvl(total_plan_quantity,0),0),0 ) )
                ,sum(decode(RESOURCE_CLASS_CODE, 'EQUIPMENT',decode(unit_of_measure,'HOURS',nvl(total_plan_quantity,0),0),0 ) )
           FROM  pa_resource_assignments
          WHERE  budget_version_id = p_budget_version_id;


        -- End, Bug 3441943, 18-FEB-2004: Added DECODE to separately sum people and equipment quantities ---------

        -- End, Bug 3362316, 08-JAN-2004: changed to query all version assignment records  -----------------------

        --For bug 3489929
        CURSOR c_res_amt_diffs IS
        SELECT resource_assignment_id
           ,sum(nvl(project_raw_cost,0) - nvl(old_proj_raw_cost,0))                 project_raw_cost_diff
           ,sum(nvl(project_burdened_cost,0) - nvl(old_proj_burdened_cost,0))       project_burdened_cost_diff
           ,sum(nvl(project_revenue,0) - nvl(old_proj_revenue,0))                   project_revenue_diff
           ,sum(nvl(projfunc_raw_cost,0) - nvl(old_projfunc_raw_cost,0))            projfunc_raw_cost_diff
           ,sum(nvl(projfunc_burdened_cost,0) - nvl(old_projfunc_burdened_cost,0))  projfunc_burdened_cost_diff
           ,sum(nvl(projfunc_revenue,0) - nvl(old_projfunc_revenue,0))              projfunc_revenue_diff
           ,sum(nvl(quantity,0) - nvl(old_quantity,0))                              quantity_diff
        FROM PA_FP_ROLLUP_TMP
        GROUP BY resource_assignment_id;

BEGIN

       -- Initialize and Set the error stack.
          FND_MSG_PUB.initialize;
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.set_err_stack('PA_FP_ROLLUP_PKG.Rollup_Budget_Version');
          END IF;

       -- Get the Debug mode into local variable and set it to 'Y'if its NULL
          fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
          l_debug_mode := NVL(l_debug_mode, 'Y');

       -- Initialize the return status to success
           x_return_status := FND_API.G_RET_STS_SUCCESS;

           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.set_process('ROLLUP_BUDGET_VERSION: ' || 'PLSQL','LOG',l_debug_mode);
           END IF;
           x_msg_count := 0;

           pa_debug.g_err_stage := 'In PA_FP_ROLLUP_PKG.Rollup_Budget_Version';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('ROLLUP_BUDGET_VERSION: ' || l_module_name,pa_debug.g_err_stage,3);
           END IF;

        /* Check for Budget Version ID not being NULL. */
        IF ( p_budget_version_id IS NULL) THEN
                pa_debug.g_err_stage := 'Err- Budget Version ID cannot be NULL.';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('ROLLUP_BUDGET_VERSION: ' || l_module_name,pa_debug.g_err_stage,5);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                     p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
                RAISE PA_FP_ROLLUP_PKG.Invalid_Arg_Exc;
        END IF;

        pa_debug.g_err_stage := 'Budget Version ID is '||p_budget_version_id;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('ROLLUP_BUDGET_VERSION: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        /* Populate Local Variables */
        /* M21-AUG: made call parameterized */
        pa_debug.g_err_stage := 'calling populate_local_vars';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('ROLLUP_BUDGET_VERSION: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;


        SELECT PERIOD_PROFILE_ID
          INTO l_period_profile_id
          FROM PA_BUDGET_VERSIONS
         WHERE budget_version_id = p_budget_version_id;


        IF (p_entire_version = 'Y') THEN



              g_first_ra_id := 0;

            pa_debug.g_err_stage := 'Update All Version Resource_Assignments';
            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write('ROLLUP_BUDGET_VERSION: ' || l_module_name,pa_debug.g_err_stage,3);
            END IF;

        -- Bug 3362316, 08-JAN-2004:  Purged Obsolete for FP.M. Added Update ---------------------

              pa_debug.g_err_stage := 'Update All Version Resource_Assignments';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('ROLLUP_BUDGET_VERSION: ' || l_module_name,pa_debug.g_err_stage,3);
              END IF;

			 --code modified for bug 4160258.
			 IF p_context IS NOT NULL AND p_context = 'DELETE_RA'
				THEN NULL;
			 ELSE
					UPDATE pa_resource_assignments pra
					SET (parent_assignment_id
						,total_project_raw_cost
						,total_project_burdened_cost
						,total_project_revenue
						,total_plan_raw_cost
						,total_plan_burdened_cost
						,total_plan_revenue
						,total_plan_quantity) =
						 (SELECT NULL
								,sum(nvl(project_raw_cost,0))
								,sum(nvl(project_burdened_cost,0))
								,sum(nvl(project_revenue,0))
								,sum(nvl(raw_cost,0))
								,sum(nvl(burdened_cost,0))
								,sum(nvl(revenue,0))
								,sum(nvl(quantity,0))
							FROM pa_budget_lines pbl
							WHERE pbl.resource_assignment_id = pra.resource_assignment_id
							and    pbl.cost_rejection_code IS NULL
							and    pbl.revenue_rejection_code IS NULL
							and    pbl.burden_rejection_code IS NULL
							and    pbl.other_rejection_code IS NULL
							and    pbl.pc_cur_conv_rejection_code IS NULL
							and    pbl.pfc_cur_conv_rejection_code IS NULL
                            and    pbl.budget_version_id = p_budget_version_id )  --Added for bug 4141042
					 WHERE budget_version_id = p_budget_version_id;
                    --AND resource_assignment_type = PA_FP_CONSTANTS_PKG.G_USER_ENTERED; For bug 3668727
			END IF; --end of changes for bug 4160258.

       -- End, Bug 3362316, 08-JAN-2004:  Obsolete for FP.M; Added Update ---------------------


       -- Bug 3362316, 08-JAN-2004: Added Conditional Logic for ORG_FORECAST  ---------------------



              IF l_period_profile_id IS NOT NULL
                THEN



                BEGIN
                    SELECT org_project_flag
                    INTO   l_org_forecast_flag
                    FROM   pa_budget_versions v
                           , pa_projects_all  p
                           , pa_project_types_all pt
                    WHERE  v.budget_version_id = p_budget_version_id
                    AND    v.project_id =  p.project_id
                    AND    p.project_type = pt.project_type
                    /* Bug fix: 4510784 AND    Nvl(p.org_id, -99) = nvl(pt.org_id,-99); */ /* Bug 4193069*/
                    AND    p.org_id = pt.org_id;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_org_forecast_flag := NULL;
                END;

                IF (l_org_forecast_flag = 'Y')
                  THEN


                     pa_debug.g_err_stage := 'Entire Version is Y , calling Refresh_Period_Denorm';
                     IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.write('ROLLUP_BUDGET_VERSION: ' || l_module_name,pa_debug.g_err_stage,3);
                     END IF;

                     REFRESH_PERIOD_DENORM(p_budget_version_id => p_budget_version_id
                                      ,x_return_status     => x_return_status
                                      ,x_msg_count         => x_msg_count
                                      ,x_msg_data          => x_msg_data);


                END IF; -- (l_org_forecast_flag = 'Y'



            END IF; -- l_period_profile_id IS NOT NULL


       -- End, Bug 3362316, 08-JAN-2004: Added Conditional Logic for ORG_FORECAST  ------------------
   ELSIF p_entire_version = 'N' THEN


		   --Update the amounts for the resource assignments available in pa_fp_rollup_tmp . Bug 3489929
		   OPEN c_res_amt_diffs;
		   FETCH c_res_amt_diffs BULK COLLECT INTO
			   l_ra_id_tbl
			  ,l_proj_raw_cost_tbl
			  ,l_proj_burd_cost_tbl
			  ,l_proj_revenue_tbl
			  ,l_projfunc_raw_cost_tbl
			  ,l_projfunc_burd_cost_tbl
			  ,l_projfunc_revenue_tbl
			  ,l_quantity_tbl;
		   CLOSE  c_res_amt_diffs;

			   IF l_ra_id_tbl.COUNT > 0 THEN

					 FORALL i IN l_ra_id_tbl.first..l_ra_id_tbl.last
						UPDATE pa_resource_assignments
						SET TOTAL_PROJECT_RAW_COST      = nvl(TOTAL_PROJECT_RAW_COST,0)      + l_proj_raw_cost_tbl(i)
						   ,TOTAL_PROJECT_BURDENED_COST = nvl(TOTAL_PROJECT_BURDENED_COST,0) + l_proj_burd_cost_tbl(i)
						   ,TOTAL_PROJECT_REVENUE       = nvl(TOTAL_PROJECT_REVENUE,0)       + l_proj_revenue_tbl(i)
						   ,TOTAL_PLAN_RAW_COST         = nvl(TOTAL_PLAN_RAW_COST,0)         + l_projfunc_raw_cost_tbl(i)
						   ,TOTAL_PLAN_BURDENED_COST    = nvl(TOTAL_PLAN_BURDENED_COST,0)    + l_projfunc_burd_cost_tbl(i)
						   ,TOTAL_PLAN_REVENUE          = nvl(TOTAL_PLAN_REVENUE,0)          + l_projfunc_revenue_tbl(i)
						   ,TOTAL_PLAN_QUANTITY         = nvl(TOTAL_PLAN_QUANTITY,0)         + l_quantity_tbl(i)
						WHERE resource_assignment_id = l_ra_id_tbl(i);
			   END IF;

   END IF; -- p_entire_version = 'Y'


   /* Update Budget Versions Table with rolled up amounts. Update budget versions table
      using top_task level records from pa_resource_assignments. */

          pa_debug.g_err_stage := 'selecting Amounts from project level record';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('ROLLUP_BUDGET_VERSION: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;

          /* #2593261: Added the total_plan_quantity column which was missed out
              earlier, because of which labor_quantity was not being updated
              in pa_budget_versions. */


          /* Opening a cursor to get the project levee amounts. */


      -- Bug 3362316, 08-JAN-2004: Removed l_uncat_rlm_id parameter ---------------

         OPEN c_proj_level_amounts(p_budget_version_id);

      -- End, Bug 3362316, 08-JAN-2004: Removed l_uncat_rlm_id parameter ---------------

             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage := 'fetching project level amounts';
                pa_debug.write('ROLLUP_BUDGET_VERSION: '||l_module_name,pa_debug.g_err_stage,3);
             END IF;


      -- Bug 3441943, 18-FEB-2004: New Vars to sum people (labor) and equipment quantities ------------

             FETCH c_proj_level_amounts INTO
                   l_proj_raw_cost
                  ,l_proj_burdened_cost
                  ,l_proj_revenue
                  ,l_projfunc_raw_cost
                  ,l_projfunc_burdened_cost
                  ,l_projfunc_revenue
                  ,l_labor_quantity
                  ,l_equip_quantity;

      -- End,Bug 3441943, 18-FEB-2004: New Vars to sum people (labor) and equipment quantities ------------

             --Commented out this condition for bug 3801879. The budget versions table should always be
	     --updated with the sum of amounts in the budget lines table in this API.

             --IF (l_proj_raw_cost IS NOT NULL) THEN
                /* If records exist at the Top Task Level. */

	     pa_debug.g_err_stage := 'updating project level amounts on budget version';
	     IF P_PA_DEBUG_MODE = 'Y' THEN
	        pa_debug.write('ROLLUP_BUDGET_VERSION: ' || l_module_name,pa_debug.g_err_stage,3);
	     END IF;

-- Bug 3441943, 18-FEB-2004: New Vars for people (labor) and equipment quantities ------------

	     UPDATE pa_budget_versions
	     SET  raw_cost                    = l_projfunc_raw_cost
		 ,burdened_cost               = l_projfunc_burdened_cost
		 ,revenue                     = l_projfunc_revenue
		 ,total_project_raw_cost      = l_proj_raw_cost
		 ,total_project_burdened_cost = l_proj_burdened_cost
		 ,total_project_revenue       = l_proj_revenue
		 ,labor_quantity              = l_labor_quantity
		 ,equipment_quantity          = l_equip_quantity
		 ,last_update_date            = SYSDATE -- Added for bug 3394907
		 ,last_updated_by             = FND_GLOBAL.user_id -- Added for bug 3394907
		 ,last_update_login           = FND_GLOBAL.login_id -- Added for bug 3394907
	    WHERE budget_version_id = p_budget_version_id;

-- End, Bug 3441943, 18-FEB-2004: New Vars for people (labor) and equipment quantities ------------


	    pa_debug.g_err_stage := 'updated ' || sql%rowcount || ' budget version';
	    IF P_PA_DEBUG_MODE = 'Y' THEN
	       pa_debug.write('ROLLUP_BUDGET_VERSION: ' || l_module_name,pa_debug.g_err_stage,3);
	    END IF;

            --END IF; -- l_proj_raw_cost IS NOT NULL)

              CLOSE c_proj_level_amounts;
         pa_debug.reset_err_stack;

EXCEPTION
  WHEN PA_FP_ROLLUP_PKG.Invalid_Arg_Exc THEN
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
      ELSE
             x_msg_count := l_msg_count;
      END IF;
      pa_debug.reset_err_stack;
    RAISE;
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_FP_ROLLUP_PKG'
            ,p_procedure_name => 'Rollup_Budget_Version');
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('ROLLUP_BUDGET_VERSION: ' || l_module_name,SQLERRM,5);
        END IF;
        pa_debug.reset_err_stack;

        raise FND_API.G_EXC_UNEXPECTED_ERROR;
END ROLLUP_BUDGET_VERSION;

/*===================================================================================================
   REFRESH_RESOURCE_ASSIGNMENTS: This API refreshes the complete resource assignments table.
   It does following deletes all rolled up records from pa_resource_assignments.Update amounts
   from pa_budget_lines on all user_entered records. Insert parents for all the records with amounts.
   Stamps the parent_assignment_id on all the records.
   This procedure returns without any action in case there are no records in PA_RESOURCE_ASSIGNMENTS.
===================================================================================================*/

PROCEDURE REFRESH_RESOURCE_ASSIGNMENTS(p_budget_version_id IN NUMBER
                                      ,x_return_status    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                      ,x_msg_count        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                      ,x_msg_data         OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

        /* #2697999: For the Resource group, UOM is dependent on the track as labor flag
           of the corresponding resource list member id. If the track as labor flag is
           'Y', then unit_of_measure is 'HOURS', else it is NULL.
           For all other rolled up records, the uom is 'HOURS' and track as labor flag is
           'Y'. */

        CURSOR Cur_Res_Level(c_budget_version_id IN NUMBER) is
           SELECT pra.task_id
                 ,prlm.parent_member_id resource_list_member_id
                 ,sum(nvl(pra.total_project_raw_cost,0))
                 ,sum(nvl(pra.total_project_burdened_cost,0))
                 ,sum(nvl(pra.total_project_revenue,0))
                 ,sum(nvl(pra.total_plan_raw_cost,0))
                 ,sum(nvl(pra.total_plan_burdened_cost,0))
                 ,sum(nvl(pra.total_plan_revenue,0))
                 ,SUM(DECODE(parent_prlm.track_as_labor_flag,'Y',
                             NVL(DECODE(pra.unit_of_measure,'HOURS',
                                        pra.total_plan_quantity,0),0)
                     ,NULL)) total_plan_quantity               -- Modified for bug #2697999
                 ,MAX(DECODE(parent_prlm.track_as_labor_flag,'Y',
                            'HOURS',NULL)) unit_of_measure     -- Modified for bug #2697999
                 ,MAX(parent_prlm.track_as_labor_flag) track_as_labor_flag
                                                               -- Modified for bug #2697999
            FROM  pa_resource_assignments pra
                 ,pa_resource_list_members prlm
                 ,pa_resource_list_members parent_prlm         -- Added for bug #2697999
           WHERE  pra.budget_version_id = c_budget_version_id
           AND    pra.resource_list_member_id <> 0
           AND    pra.resource_list_member_id = prlm.resource_list_member_id
           AND    prlm.parent_member_id = parent_prlm.resource_list_member_id
           AND    prlm.parent_member_id IS NOT NULL
           AND    (pra.total_plan_quantity IS NOT NULL         -- Added for bug #2784520
                   OR pra.total_plan_raw_cost IS NOT NULL
                   OR pra.total_plan_revenue  IS NOT NULL
                   OR pra.total_plan_burdened_cost IS NOT NULL)
           GROUP  BY pra.task_id, prlm.parent_member_id;

        CURSOR Cur_Task_Level(c_budget_version_id IN NUMBER) is
           SELECT task_id
                 ,0   resource_list_member_id
                 ,sum(nvl(pra.total_project_raw_cost,0))
                 ,sum(nvl(pra.total_project_burdened_cost,0))
                 ,sum(nvl(pra.total_project_revenue,0))
                 ,sum(nvl(pra.total_plan_raw_cost,0))
                 ,sum(nvl(pra.total_plan_burdened_cost,0))
                 ,sum(nvl(pra.total_plan_revenue,0))
                 ,sum(nvl(decode(pra.unit_of_measure,PA_FP_CONSTANTS_PKG.G_UNIT_OF_MEASURE_HOURS,
                                                          pra.total_plan_quantity,0),0)) quantity
                 ,PA_FP_CONSTANTS_PKG.G_UNIT_OF_MEASURE_HOURS -- Modified for bug #2697999
                 ,'Y'                                         -- Modified for bug #2697999
             FROM pa_resource_assignments pra
            WHERE pra.budget_version_id = c_budget_version_id
              AND pra.resource_list_member_id <> 0
              AND pra.resource_assignment_type = PA_FP_CONSTANTS_PKG.G_USER_ENTERED
              AND (pra.total_plan_quantity IS NOT NULL        -- Added for bug #2784520
                   OR pra.total_plan_raw_cost IS NOT NULL
                   OR pra.total_plan_revenue  IS NOT NULL
                   OR pra.total_plan_burdened_cost IS NOT NULL)
            GROUP BY task_id;

        CURSOR Cur_Parent_Task(c_uncat_rlm_id IN NUMBER,
                               c_curr_res_assignment_id IN NUMBER,
                               c_budget_version_id IN NUMBER,
                               c_process_wbs_level IN NUMBER) IS
           SELECT pt.PARENT_TASK_ID task_id
                 ,0   resource_list_member_id
                 ,sum(nvl(pra.total_project_raw_cost,0))
                 ,sum(nvl(pra.total_project_burdened_cost,0))
                 ,sum(nvl(pra.total_project_revenue,0))
                 ,sum(nvl(pra.total_plan_raw_cost,0))
                 ,sum(nvl(pra.total_plan_burdened_cost,0))
                 ,sum(nvl(pra.total_plan_revenue,0))
                 ,sum(nvl(pra.total_plan_quantity,0)) quantity /* no decode required on quantity */
                 ,PA_FP_CONSTANTS_PKG.G_UNIT_OF_MEASURE_HOURS -- Modified for bug #2697999
                 ,'Y'                                         -- Modified for bug #2697999
             FROM pa_resource_assignments pra
                 ,pa_tasks pt
            WHERE pra.budget_version_id = c_budget_version_id
              AND pra.resource_list_member_id IN (c_uncat_rlm_id,0)
--            AND resource_assignment_id > c_curr_res_assignment_id /* mano: this is wrong with new logic */
              AND pt.wbs_level = c_process_wbs_level /* added due to bug during UT */
              AND pra.task_id = pt.task_id
              AND pt.parent_task_id IS NOT NULL /* M23-08 missed even after review comment */
              AND (pra.total_plan_quantity IS NOT NULL        -- Added for bug #2784520
                   OR pra.total_plan_raw_cost IS NOT NULL
                   OR pra.total_plan_revenue  IS NOT NULL
                   OR pra.total_plan_burdened_cost IS NOT NULL)
            GROUP BY pt.parent_task_id;

        /* #2800670: Added the following cursors to get the project level amounts
           instead of using Singular Selects which might return a No_Data_Found. */


        /* Planning Level is Project. Hence looking at User Entered records.
           Project Level record should be created when the amounts exist at
           User Entered level.  */
        CURSOR c_proj_level_amts1(p_budget_version_id IN NUMBER) IS
            SELECT pra.project_id
                  ,0 task_id
                  ,0 resource_list_member_id
                  ,sum(pra.total_project_raw_cost)
                  ,sum(pra.total_project_burdened_cost)
                  ,sum(pra.total_project_revenue)
                  ,sum(pra.total_plan_raw_cost)
                  ,sum(pra.total_plan_burdened_cost)
                  ,sum(pra.total_plan_revenue)
                  ,sum(decode(unit_of_measure,PA_FP_CONSTANTS_PKG.G_UNIT_OF_MEASURE_HOURS,
                              nvl(total_plan_quantity,0),0)) quantity
                  ,PA_FP_CONSTANTS_PKG.G_UNIT_OF_MEASURE_HOURS unit_of_measure --Modified for bug #2697999
                  ,'Y' track_as_labor_flag                                     --Modified for bug #2697999
             FROM  pa_resource_assignments pra
            WHERE  pra.budget_version_id = p_budget_Version_id
              AND  pra.resource_assignment_type = 'USER_ENTERED'
              AND  (pra.total_plan_quantity IS NOT NULL
                    OR pra.total_plan_raw_cost IS NOT NULL
                    OR pra.total_plan_revenue IS NOT NULL
                    OR pra.total_plan_burdened_cost IS NOT NULL)
           GROUP BY pra.project_id;


        /* Planning Level not Project. */
        CURSOR c_proj_level_amts2(p_budget_version_id IN NUMBER ,
                                  l_uncat_rlm_id IN NUMBER ) IS
            SELECT pra.project_id
                  ,0 task_id
                  ,0 resource_list_member_id
                  ,sum(pra.total_project_raw_cost)
                  ,sum(pra.total_project_burdened_cost)
                  ,sum(pra.total_project_revenue)
                  ,sum(pra.total_plan_raw_cost)
                  ,sum(pra.total_plan_burdened_cost)
                  ,sum(pra.total_plan_revenue)
                  ,sum(nvl(total_plan_quantity,0)) quantity
                  ,PA_FP_CONSTANTS_PKG.G_UNIT_OF_MEASURE_HOURS unit_of_measure --Modified for bug #2697999
                  ,'Y' track_as_labor_flag                                     --Modified for bug #2697999
             FROM  pa_resource_assignments pra,
                   pa_tasks pt
            WHERE  pra.budget_version_id = p_budget_Version_id
              AND  pra.resource_list_member_id in (l_uncat_rlm_id,0)
              AND  pra.project_id = pt.project_id -- Fixed for #2807678
              AND  pra.task_id = pt.task_id
              AND  pra.task_id = pt.top_task_id
           GROUP BY pra.project_id;

        /* #2808442: Cursor to check if there are any Budget Lines for the Version. */

        CURSOR c_budget_lines_exist(p_budget_version_id IN NUMBER) IS
            SELECT 1
              FROM DUAL
             WHERE EXISTS (SELECT resource_assignment_id
                             FROM pa_budget_lines
                            WHERE budget_version_id = p_budget_version_id);

        l_budget_line_exists      NUMBER;

        l_proj_raw_cost_tbl       l_proj_raw_cost_tbl_typ;
        l_proj_burd_cost_tbl      l_proj_burd_cost_tbl_typ;
        l_proj_revenue_tbl        l_proj_revenue_tbl_typ;

        l_projfunc_raw_cost_tbl   l_projfunc_raw_cost_tbl_typ;
        l_projfunc_burd_cost_tbl  l_projfunc_burd_cost_tbl_typ;
        l_projfunc_revenue_tbl    l_projfunc_revenue_tbl_typ;

        l_quantity_tbl            l_quantity_tbl_typ;

        l_task_id_tbl             l_task_id_tbl_typ;
        l_res_list_mem_id_tbl     l_res_list_mem_id_tbl_typ;
        l_unit_of_measure_tbl     l_unit_of_measure_tbl_typ;
        l_track_as_labor_flag_tbl l_track_as_labor_flag_tbl_typ;

        l_curr_res_assignment_id  pa_resource_assignments.resource_assignment_id%TYPE ;
        l_resource_list_id        pa_resource_lists.RESOURCE_LIST_ID%TYPE;
        l_uncat_flag              pa_resource_lists.UNCATEGORIZED_FLAG%TYPE;
        l_rl_group_type_id        pa_resource_lists.GROUP_RESOURCE_TYPE_ID%TYPE;
        l_uncat_rlm_id            pa_resource_lists.RESOURCE_LIST_ID%TYPE;
        l_project_id              pa_projects.project_id%TYPE;
        l_planning_level          pa_proj_fp_options.ALL_FIN_PLAN_LEVEL_CODE%TYPE;

        l_proj_raw_cost           pa_resource_assignments.total_project_raw_cost%TYPE;
        l_proj_burd_cost          pa_resource_assignments.total_project_burdened_cost%TYPE;
        l_proj_revenue            pa_resource_assignments.total_project_revenue%TYPE;
        l_projfunc_raw_cost       pa_resource_assignments.total_plan_raw_cost%TYPE;
        l_projfunc_burd_cost      pa_resource_assignments.total_plan_burdened_cost%TYPE;
        l_proj_func_revenue       pa_resource_assignments.total_plan_revenue%TYPE;

        l_quantity                pa_resource_assignments.total_plan_quantity%TYPE;

        l_uom                     pa_resource_assignments.unit_of_measure%TYPE;
        l_track_labor_flag        pa_resource_assignments.track_as_labor_flag%TYPE;
        l_proj_ra_id              pa_resource_assignments.resource_assignment_id%TYPE ;

        /* Variables to be used for debugging purpose */

        l_msg_count                   NUMBER := 0;
        l_data                        VARCHAR2(2000);
        l_msg_data                    VARCHAR2(2000);
        l_msg_index_out               NUMBER;
        l_return_status               VARCHAR2(2000);
        l_debug_mode                  VARCHAR2(10);

        l_curr_wbs_level              NUMBER := null;
        l_continue_processing_flag    VARCHAR2(1) := 'Y';

        l_count                       NUMBER;

BEGIN

       -- Set the error stack.
          pa_debug.set_err_stack('PA_FP_ROLLUP_PKG.Refresh_Resource_Assignments');

       -- Get the Debug mode into local variable and set it to 'Y'if its NULL
          fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
          l_debug_mode := NVL(l_debug_mode, 'Y');

       -- Initialize the return status to success
           x_return_status := FND_API.G_RET_STS_SUCCESS;

           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.set_process('REFRESH_RESOURCE_ASSIGNMENTS: ' || 'PLSQL','LOG',l_debug_mode);
           END IF;

           pa_debug.g_err_stage := 'In PA_FP_ROLLUP_PKG.Refresh_Resource_Assignments';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,3);
           END IF;


        /* Check for Budget Version ID not being NULL. */
           IF ( p_budget_version_id IS NULL) THEN
                pa_debug.g_err_stage := 'Err- Budget Version ID cannot be NULL.';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,5);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                     p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
                RAISE PA_FP_ROLLUP_PKG.Invalid_Arg_Exc;
           END IF;

        /* Populate the local variables for usage. */
           pa_debug.g_err_stage := 'calling populate_local_vars';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,3);
           END IF;

           populate_local_vars(p_budget_version_id    => p_budget_version_id,
                               x_project_id           => l_project_id,
                               x_resource_list_id     => l_resource_list_id,
                               x_uncat_flag           => l_uncat_flag,
                               x_uncat_rlm_id         => l_uncat_rlm_id,
                               x_rl_group_type_id     => l_rl_group_type_id,
                               x_planning_level       => l_planning_level,
                               x_return_status        => x_return_status,
                               x_msg_count            => x_msg_count,
                               x_msg_data             => x_msg_data);

        /* Delete all ROLLED_UP records from pa_resource_assignments for the
           budget_version_id. */

             pa_debug.g_err_stage := 'deleting rolled up records from pa_resource_assignments';
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,3);
             END IF;

             DELETE FROM pa_resource_assignments
             WHERE budget_version_id = p_budget_version_id
             AND   resource_assignment_type = PA_FP_CONSTANTS_PKG.G_ROLLED_UP;

        /* Update the pa_resource_assignments USER_ENTERED records set
           parent_assignment_id as null. Also update the amounts. Amounts need to
           be updated as in case of copy from and copy actual amounts may not be updated.
           We assume that in certain other cases also it may be difficult to update amounts
           before calling this api.*/

           pa_debug.g_err_stage := 'Updating the Parent_Assignment_ID of User Entered records';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,3);
           END IF;

             UPDATE pa_resource_assignments pra
                SET (parent_assignment_id
                    ,total_project_raw_cost
                    ,total_project_burdened_cost
                    ,total_project_revenue
                    ,total_plan_raw_cost
                    ,total_plan_burdened_cost
                    ,total_plan_revenue
                    ,total_plan_quantity) =
                     (SELECT NULL
                            ,sum(nvl(project_raw_cost,0))
                            ,sum(nvl(project_burdened_cost,0))
                            ,sum(nvl(project_revenue,0))
                            ,sum(nvl(raw_cost,0))
                            ,sum(nvl(burdened_cost,0))
                            ,sum(nvl(revenue,0))
                            ,sum(nvl(quantity,0))
                        FROM pa_budget_lines pbl
                       WHERE pbl.resource_assignment_id = pra.resource_assignment_id)
              WHERE budget_version_id = p_budget_version_id
                AND resource_assignment_type = PA_FP_CONSTANTS_PKG.G_USER_ENTERED;

           l_count := sql%rowcount; /* 2598502 - Used local variable for sql%rowcount */

           pa_debug.g_err_stage := 'updated ' || l_count || ' records';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,3);
           END IF;

           IF l_count = 0 THEN
              pa_debug.g_err_stage := 'resource assignments table does not have any records. Hence returning';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,3);
              END IF;
              pa_debug.reset_err_stack;
              RETURN;
           END IF;

           /* #2808442: Check if any Budget Lines exist for the Budget Version. Return without doing
              Rollup in case there are no budget lines for the budget version.*/
           OPEN c_budget_lines_exist(p_budget_Version_id);
                FETCH c_budget_lines_exist INTO l_budget_line_exists;
                IF c_budget_lines_exist%NOTFOUND THEN
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.g_err_stage := 'No budget lines found for the budget version. Hence returning';
                       pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                    END IF;
                    pa_debug.reset_err_stack;
                    RETURN;
                 END IF;
           CLOSE c_budget_lines_exist;

       IF (l_uncat_flag <> 'Y') THEN /* If Resource List is not uncategorized */
           IF nvl(l_rl_group_type_id,0) <> 0  THEN /* If Res List is grouped */

                 /* If Resource List is not uncategorized and Resource List is not grouped,
                    then Resource Groups have to be inserted for the Resource Level records. */

                 pa_debug.g_err_stage := 'Opening Cur_Res_Level cursor';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                 END IF;

                 OPEN Cur_Res_Level(p_budget_version_id);
                 LOOP
                    pa_debug.g_err_stage := 'Fetching from Cur_Res_Level';
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                    END IF;

                    FETCH Cur_Res_Level BULK COLLECT INTO
                                      l_task_id_tbl
                                     ,l_res_list_mem_id_tbl
                                     ,l_proj_raw_cost_tbl
                                     ,l_proj_burd_cost_tbl
                                     ,l_proj_revenue_tbl
                                     ,l_projfunc_raw_cost_tbl
                                     ,l_projfunc_burd_cost_tbl
                                     ,l_projfunc_revenue_tbl
                                     ,l_quantity_tbl
                                     ,l_unit_of_measure_tbl
                                     ,l_track_as_labor_flag_tbl
                    LIMIT g_plsql_max_array_size;

                      IF nvl(l_task_id_tbl.last,0) >= 1 THEN /* only if something is fetched */

                         /* Call a common API to bulk insert into pa_resource_assignments. */

                         pa_debug.g_err_stage := 'got ' || l_task_id_tbl.last || ' records ' || 'calling Insert_Bulk_Rows_Res';
                         IF P_PA_DEBUG_MODE = 'Y' THEN
                            pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                         END IF;

                         Insert_Bulk_Rows_Res(p_project_id                => l_project_id
                                             ,p_plan_version_id           => p_budget_version_id
                                             ,p_task_id_tbl               => l_task_id_tbl
                                             ,p_res_list_mem_id_tbl       => l_res_list_mem_id_tbl
                                             ,p_proj_raw_cost_tbl         => l_proj_raw_cost_tbl
                                             ,p_proj_burdened_cost_tbl    => l_proj_burd_cost_tbl
                                             ,p_proj_revenue_tbl          => l_proj_revenue_tbl
                                             ,p_projfunc_raw_cost_tbl     => l_projfunc_raw_cost_tbl
                                             ,p_projfunc_burd_cost_tbl    => l_projfunc_burd_cost_tbl
                                             ,p_projfunc_revenue_tbl      => l_projfunc_revenue_tbl
                                             ,p_quantity_tbl              => l_quantity_tbl
                                             ,p_unit_of_measure_tbl       => l_unit_of_measure_tbl
                                             ,p_track_as_labor_flag_tbl   => l_track_as_labor_flag_tbl
                                             ,x_return_status             => x_return_status
                                             ,x_msg_count                 => x_msg_count
                                             ,x_msg_data                  => x_msg_data  );


                      END IF;  /* end of only if something is fetched */

                      EXIT WHEN nvl(l_task_id_tbl.last,0) < g_plsql_max_array_size;

                 END LOOP;
                 CLOSE Cur_Res_Level;

           END IF; /* Resource List Grouped */

          /* Clear the PL/SQL tables to be used later */
          l_task_id_tbl.delete;
          l_res_list_mem_id_tbl.delete;
          l_proj_raw_cost_tbl.delete;
          l_proj_burd_cost_tbl.delete;
          l_proj_revenue_tbl.delete;
          l_projfunc_raw_cost_tbl.delete;
          l_projfunc_burd_cost_tbl.delete;
          l_projfunc_revenue_tbl.delete;
          l_quantity_tbl.delete;
          l_unit_of_measure_tbl.delete;
          l_track_as_labor_flag_tbl.delete;

     /* If planning_level is not 'PROJECT'then Inserting Task Level records for all USER_ENTERED
        level records. This step need to be done whether resource list is grouped or not. We select
        USER_ENTEREDrecords only because for certain records amounts could be entered at resource
        group or resource level. Hence it makes our task easy to look only at user entered records. */

        IF l_planning_level <> PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT THEN

           pa_debug.g_err_stage := 'Inserting the Task Level Records';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,3);
           END IF;

           OPEN Cur_Task_Level(p_budget_version_id);
           LOOP

                pa_debug.g_err_stage := 'fetching from Cur_Task_Level ';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                END IF;

                FETCH Cur_Task_Level BULK COLLECT INTO l_task_id_tbl
                                 ,l_res_list_mem_id_tbl
                                 ,l_proj_raw_cost_tbl
                                 ,l_proj_burd_cost_tbl
                                 ,l_proj_revenue_tbl
                                 ,l_projfunc_raw_cost_tbl
                                 ,l_projfunc_burd_cost_tbl
                                 ,l_projfunc_revenue_tbl
                                 ,l_quantity_tbl
                                 ,l_unit_of_measure_tbl
                                 ,l_track_as_labor_flag_tbl
                LIMIT g_plsql_max_array_size;

                  IF nvl(l_task_id_tbl.last,0) >= 1 THEN /* only if something is fetched */

                         Insert_Bulk_Rows_Res(p_project_id                => l_project_id
                                             ,p_plan_version_id           => p_budget_version_id
                                             ,p_task_id_tbl               => l_task_id_tbl
                                             ,p_res_list_mem_id_tbl       => l_res_list_mem_id_tbl
                                             ,p_proj_raw_cost_tbl         => l_proj_raw_cost_tbl
                                             ,p_proj_burdened_cost_tbl    => l_proj_burd_cost_tbl
                                             ,p_proj_revenue_tbl          => l_proj_revenue_tbl
                                             ,p_projfunc_raw_cost_tbl     => l_projfunc_raw_cost_tbl
                                             ,p_projfunc_burd_cost_tbl    => l_projfunc_burd_cost_tbl
                                             ,p_projfunc_revenue_tbl      => l_projfunc_revenue_tbl
                                             ,p_quantity_tbl              => l_quantity_tbl
                                             ,p_unit_of_measure_tbl       => l_unit_of_measure_tbl
                                             ,p_track_as_labor_flag_tbl   => l_track_as_labor_flag_tbl
                                             ,x_return_status             => x_return_status
                                             ,x_msg_count                 => x_msg_count
                                             ,x_msg_data                  => x_msg_data  );

                  END IF;  /* end of only if something is fetched */

                  EXIT WHEN nvl(l_task_id_tbl.last,0) < g_plsql_max_array_size;

            END LOOP;
            CLOSE Cur_Task_Level;

        END IF; /* l_planning_level <> PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT*/

     END IF;  /* If Resource List is not uncategorized */


     /* Clear the PL/SQL tables to be used later */
     l_task_id_tbl.delete;
     l_res_list_mem_id_tbl.delete;
     l_proj_raw_cost_tbl.delete;
     l_proj_burd_cost_tbl.delete;
     l_proj_revenue_tbl.delete;
     l_projfunc_raw_cost_tbl.delete;
     l_projfunc_burd_cost_tbl.delete;
     l_projfunc_revenue_tbl.delete;
     l_quantity_tbl.delete;
     l_unit_of_measure_tbl.delete;
     l_track_as_labor_flag_tbl.delete;

     /* If planning_level is not 'project'or 'top_task'then we need to insert Parent Task
        Level records. */

        IF l_planning_level NOT IN (PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT,
                                      PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_TOP) THEN
                                      /* Insert Parent Level Records */

            /* Initialise the variable l_cur_res_assignment_id to 0. */
               l_curr_res_assignment_id := 0;

            /* Creating a Loop where the steps of insertion into PA_Resource_Assignments
               for the Parent_Task records and then selecting records for the Resource Assignments
               for the records that have been created. */

               pa_debug.g_err_stage := 'Inserting the Parent Task Level Records';
               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,3);
               END IF;

               l_curr_wbs_level := null;

               select max(wbs_level)
                 into l_curr_wbs_level
                 from pa_tasks
                where project_id = l_project_id;

               LOOP
               EXIT WHEN l_curr_wbs_level = 1;


                      pa_debug.g_err_stage := 'opening Cur_Parent_Task';
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                      END IF;

                      OPEN Cur_Parent_Task(l_uncat_rlm_id,
                                           l_curr_res_assignment_id,
                                           p_budget_version_id,
                                           l_curr_wbs_level);

                         /* Get the current/next value of sequence for resource assignment
                            id into l_curr_res_assignment_id just after opening the cursor. */

                            IF l_curr_res_assignment_id = 0 THEN
                              SELECT PA_RESOURCE_ASSIGNMENTS_S.nextval
                                INTO l_curr_res_assignment_id
                                FROM dual;
                            ELSE
                              SELECT PA_RESOURCE_ASSIGNMENTS_S.currval
                                INTO l_curr_res_assignment_id
                                FROM dual;
                            END IF;
                            pa_debug.g_err_stage := 'l_curr_res_assignment_id = ' || l_curr_res_assignment_id;
                            IF P_PA_DEBUG_MODE = 'Y' THEN
                               pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                            END IF;

                      LOOP
                              pa_debug.g_err_stage := 'fetching from Cur_Parent_Task ';
                              IF P_PA_DEBUG_MODE = 'Y' THEN
                                 pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                              END IF;

                              FETCH Cur_Parent_Task BULK COLLECT INTO
                                                  l_task_id_tbl
                                                 ,l_res_list_mem_id_tbl
                                                 ,l_proj_raw_cost_tbl
                                                 ,l_proj_burd_cost_tbl
                                                 ,l_proj_revenue_tbl
                                                 ,l_projfunc_raw_cost_tbl
                                                 ,l_projfunc_burd_cost_tbl
                                                 ,l_projfunc_revenue_tbl
                                                 ,l_quantity_tbl
                                                 ,l_unit_of_measure_tbl
                                                 ,l_track_as_labor_flag_tbl
                              LIMIT g_plsql_max_array_size;

                              pa_debug.g_err_stage := 'fetched ' || l_task_id_tbl.last || ' records';
                              IF P_PA_DEBUG_MODE = 'Y' THEN
                                 pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                              END IF;

                              IF nvl(l_task_id_tbl.last,0) >= 1 THEN /* only if something is fetched */

                                   pa_debug.g_err_stage := 'l_task_id_tbl.last = ' || l_task_id_tbl.last || ' inserting in ra tbl';
                                   IF P_PA_DEBUG_MODE = 'Y' THEN
                                      pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                                   END IF;


                                   Insert_Bulk_Rows_Res(p_project_id                => l_project_id
                                                       ,p_plan_version_id           => p_budget_version_id
                                                       ,p_task_id_tbl               => l_task_id_tbl
                                                       ,p_res_list_mem_id_tbl       => l_res_list_mem_id_tbl
                                                       ,p_proj_raw_cost_tbl         => l_proj_raw_cost_tbl
                                                       ,p_proj_burdened_cost_tbl    => l_proj_burd_cost_tbl
                                                       ,p_proj_revenue_tbl          => l_proj_revenue_tbl
                                                       ,p_projfunc_raw_cost_tbl     => l_projfunc_raw_cost_tbl
                                                       ,p_projfunc_burd_cost_tbl    => l_projfunc_burd_cost_tbl
                                                       ,p_projfunc_revenue_tbl      => l_projfunc_revenue_tbl
                                                       ,p_quantity_tbl              => l_quantity_tbl
                                                       ,p_unit_of_measure_tbl       => l_unit_of_measure_tbl
                                                       ,p_track_as_labor_flag_tbl   => l_track_as_labor_flag_tbl
                                                       ,x_return_status             => x_return_status
                                                       ,x_msg_count                 => x_msg_count
                                                       ,x_msg_data                  => x_msg_data  );

                              END IF;  /* end of only if something is fetched */

                              EXIT WHEN nvl(l_task_id_tbl.last,0) < g_plsql_max_array_size;

                       END LOOP; /* End Loop of the Cursor. */

                    CLOSE Cur_Parent_Task;
                    pa_debug.g_err_stage := 'closing Cur_Parent_Task';
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                    END IF;

                    l_curr_wbs_level := l_curr_wbs_level - 1;

               END LOOP; /* End Loop of the outer loop */

         END IF; /* l_planning_level not in PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT,
                      PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_TOP*/

     /* Creating a project level record in pa_resource_assignment table. Resource
        list member id should be l_uncat_rlm_id for such record. Store the
        resource_assignment_id of this record in l_proj_ra_id for later use. */

     /* Clear the PL/SQL tables to be used later */
        l_task_id_tbl.delete;
        l_res_list_mem_id_tbl.delete;
        l_proj_raw_cost_tbl.delete;
        l_proj_burd_cost_tbl.delete;
        l_proj_revenue_tbl.delete;
        l_projfunc_raw_cost_tbl.delete;
        l_projfunc_burd_cost_tbl.delete;
        l_projfunc_revenue_tbl.delete;
        l_quantity_tbl.delete;
        l_unit_of_measure_tbl.delete;
        l_track_as_labor_flag_tbl.delete;


        /* #2598502: Modified the following condition. */

        IF l_planning_level = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT THEN
           IF l_uncat_flag =  'Y' THEN
              /* For project level and resource list none we don't need to create proejct
                 level record */
                pa_debug.g_err_stage := 'Not creating a Project Level Record';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                END IF;

                NULL;

           ELSE

                /* #2598502: If the Planning Level is 'Project' then we should not
                   join with PA_TASKS table as there would be no record in PA_TASKS
                   table with Task_ID as 0. We should also have no condition for
                   checking the resource list member id. */

                pa_debug.g_err_stage := 'Creating Project Level Record - 1';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                END IF;

                OPEN c_proj_level_amts1(p_budget_version_id);

                FETCH c_proj_level_amts1 INTO
                      l_project_id
                     ,l_task_id_tbl(1)
                     ,l_res_list_mem_id_tbl(1)
                     ,l_proj_raw_cost_tbl(1)
                     ,l_proj_burd_cost_tbl(1)
                     ,l_proj_revenue_tbl(1)
                     ,l_projfunc_raw_cost_tbl(1)
                     ,l_projfunc_burd_cost_tbl(1)
                     ,l_projfunc_revenue_tbl(1)
                     ,l_quantity_tbl(1)
                     ,l_unit_of_measure_tbl(1)
                     ,l_track_as_labor_flag_tbl(1);

                CLOSE c_proj_level_amts1;

           END IF; /* l_uncat_flag = 'Y' */

         ELSE /* Planning Level is not Project. */

                pa_debug.g_err_stage := 'Creating Project Level Record - 2';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                END IF;

                OPEN c_proj_level_amts2(p_budget_version_id,l_uncat_rlm_id);

                FETCH c_proj_level_amts2 INTO
                      l_project_id
                     ,l_task_id_tbl(1)
                     ,l_res_list_mem_id_tbl(1)
                     ,l_proj_raw_cost_tbl(1)
                     ,l_proj_burd_cost_tbl(1)
                     ,l_proj_revenue_tbl(1)
                     ,l_projfunc_raw_cost_tbl(1)
                     ,l_projfunc_burd_cost_tbl(1)
                     ,l_projfunc_revenue_tbl(1)
                     ,l_quantity_tbl(1)
                     ,l_unit_of_measure_tbl(1)
                     ,l_track_as_labor_flag_tbl(1);

                CLOSE c_proj_level_amts2;

        END IF; /* l_planning_level = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT */

        -- bug#2659956 : Added the IF condition to avoid the issue of
        -- PA_RESOURCE_ASSIGNMENTS_S.CURRVAL not yet defined ,when
        -- planning level is project and resource list is uncategorized.

        IF l_planning_level = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT
           AND l_uncat_flag =  'Y' THEN
               pa_debug.g_err_stage := 'project level uncategorized. hence not inserting project level record';
               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,3);
               END IF;

           NULL;
        ELSE

               pa_debug.g_err_stage := 'calling Insert_Bulk_Rows_Res';
               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,3);
               END IF;

               /* Call Insert_Bulk_Rows_Res only if there are any records
                  fetched in the PL/SQL tables. */

               IF nvl(l_task_id_tbl.last,0) > 0 THEN

                  Insert_Bulk_Rows_Res(p_project_id                => l_project_id
                                      ,p_plan_version_id           => p_budget_version_id
                                      ,p_task_id_tbl               => l_task_id_tbl
                                      ,p_res_list_mem_id_tbl       => l_res_list_mem_id_tbl
                                      ,p_proj_raw_cost_tbl         => l_proj_raw_cost_tbl
                                      ,p_proj_burdened_cost_tbl    => l_proj_burd_cost_tbl
                                      ,p_proj_revenue_tbl          => l_proj_revenue_tbl
                                      ,p_projfunc_raw_cost_tbl     => l_projfunc_raw_cost_tbl
                                      ,p_projfunc_burd_cost_tbl    => l_projfunc_burd_cost_tbl
                                      ,p_projfunc_revenue_tbl      => l_projfunc_revenue_tbl
                                      ,p_quantity_tbl              => l_quantity_tbl
                                      ,p_unit_of_measure_tbl       => l_unit_of_measure_tbl
                                      ,p_track_as_labor_flag_tbl   => l_track_as_labor_flag_tbl
                                      ,x_return_status             => x_return_status
                                      ,x_msg_count                 => x_msg_count
                                      ,x_msg_data                  => x_msg_data );

                  select pa_resource_assignments_s.currval
                    into l_proj_ra_id
                    from dual;

              END IF;

                 /* Calling the procedure UPDATE_RES_PARENT_ASSIGN_ID to update the parent assignment
                    IDs of all the records. */

                  pa_debug.g_err_stage := 'Calling UPDATE_RES_PARENT_ASSIGN_ID to update the Parent Assignment IDs';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                  END IF;

                  UPDATE_RES_PARENT_ASSIGN_ID(p_budget_version_id      =>  p_budget_version_id
                                             ,p_proj_ra_id             =>  l_proj_ra_id
                                             ,x_return_status          =>  x_return_status
                                             ,x_msg_count              =>  x_msg_count
                                             ,x_msg_data               =>  x_msg_data);

        END IF; /* l_planning_level = PROJECT  AND l_uncat_flag =  'Y' THEN */

        pa_debug.reset_err_stack;

EXCEPTION
  WHEN PA_FP_ROLLUP_PKG.Invalid_Arg_Exc THEN
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
      ELSE
             x_msg_count := l_msg_count;
      END IF;
      pa_debug.reset_err_stack;
    RAISE;
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_FP_ROLLUP_PKG'
            ,p_procedure_name => 'REFRESH_RESOURCE_ASSIGNMENTS');
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('REFRESH_RESOURCE_ASSIGNMENTS: ' || l_module_name,SQLERRM,5);
        END IF;
        pa_debug.reset_err_stack;

        raise FND_API.G_EXC_UNEXPECTED_ERROR;
END REFRESH_RESOURCE_ASSIGNMENTS;


/*==============================================================================================
UPDATE_RES_PARENT_ASSIGN_ID: This api will be stamping the parent assignment id on all records.
==============================================================================================*/

PROCEDURE UPDATE_RES_PARENT_ASSIGN_ID
          (p_budget_version_id    IN NUMBER
          ,p_proj_ra_id           IN NUMBER
          ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data            OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

        l_resource_list_id        pa_resource_lists.RESOURCE_LIST_ID%TYPE;
        l_uncat_flag              pa_resource_lists.UNCATEGORIZED_FLAG%TYPE;
        l_rl_group_type_id        pa_resource_lists.GROUP_RESOURCE_TYPE_ID%TYPE;
        l_uncat_rlm_id            pa_resource_lists.RESOURCE_LIST_ID%TYPE;
        l_project_id              pa_projects.project_id%TYPE;
        l_planning_level          pa_proj_fp_options.ALL_FIN_PLAN_LEVEL_CODE%TYPE;

        l_msg_count       NUMBER := 0;
        l_data            VARCHAR2(2000);
        l_msg_data        VARCHAR2(2000);
        l_msg_index_out   NUMBER;
        l_return_status   VARCHAR2(2000);
        l_debug_mode      VARCHAR2(30);

BEGIN

       -- Set the error stack.
          pa_debug.set_err_stack('PA_FP_ROLLUP_PKG.UPDATE_RES_PARENT_ASSIGN_ID');

       -- Get the Debug mode into local variable and set it to 'Y'if its NULL
          fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
          l_debug_mode := NVL(l_debug_mode, 'Y');

       -- Initialize the return status to success
           x_return_status := FND_API.G_RET_STS_SUCCESS;

           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.set_process('UPDATE_RES_PARENT_ASSIGN_ID: ' || 'PLSQL','LOG',l_debug_mode);
           END IF;

           pa_debug.g_err_stage := 'In PA_FP_ROLLUP_PKG.UPDATE_RES_PARENT_ASSIGN_ID';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('UPDATE_RES_PARENT_ASSIGN_ID: ' || l_module_name,pa_debug.g_err_stage,3);
           END IF;


        /* Check for Budget Version ID not being NULL. */
        IF ( p_budget_version_id IS NULL) THEN
                pa_debug.g_err_stage := 'Err- Budget Version ID cannot be NULL.';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('UPDATE_RES_PARENT_ASSIGN_ID: ' || l_module_name,pa_debug.g_err_stage,5);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                     p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
                RAISE PA_FP_ROLLUP_PKG.Invalid_Arg_Exc;
        END IF;

        /* Populate the local variables. */

        pa_debug.g_err_stage := 'calling populate_local_vars';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('UPDATE_RES_PARENT_ASSIGN_ID: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        populate_local_vars(p_budget_version_id    => p_budget_version_id,
                            x_project_id           => l_project_id,
                            x_resource_list_id     => l_resource_list_id,
                            x_uncat_flag           => l_uncat_flag,
                            x_uncat_rlm_id         => l_uncat_rlm_id,
                            x_rl_group_type_id     => l_rl_group_type_id,
                            x_planning_level       => l_planning_level,
                            x_return_status        => x_return_status,
                            x_msg_count            => x_msg_count,
                            x_msg_data             => x_msg_data);

        /* SET PARENT ASSIGNMENT ID FOR ALL TASK LEVEL RECORDS ONLY IF PLANNING_LEVEL
           IS NOT 'PROJECT'or 'TOP_TASK'. */

           IF l_planning_level NOT IN (PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT,
                                        PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_TOP) THEN

                pa_debug.g_err_stage := 'Updating the Parent Assignment IDs';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('UPDATE_RES_PARENT_ASSIGN_ID: ' || l_module_name,pa_debug.g_err_stage,3);
                END IF;

                UPDATE pa_resource_assignments pra1
                   SET parent_assignment_id =
                       (SELECT resource_assignment_id
                          FROM pa_resource_assignments pra2
                              ,pa_tasks t
                         WHERE pra2.task_id = t.parent_task_id
                           AND pra1.task_id = t.task_id
                           AND pra2.budget_version_id = p_budget_version_id
                           AND pra2.resource_list_member_id = 0
                           AND pra2.project_id = pra1.project_id ) -- Bug 2814165
                 WHERE budget_version_id = p_budget_version_id
                   AND resource_list_member_id IN (l_uncat_rlm_id,0)
                   AND parent_assignment_id is null
                   AND task_id <> 0;

                pa_debug.g_err_stage := 'Updated ' || sql%rowcount || ' records' ;
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('UPDATE_RES_PARENT_ASSIGN_ID: ' || l_module_name,pa_debug.g_err_stage,3);
                END IF;


            END IF;

        /* IF RESOURCE LIST ATTACHED IS NOT UNCATEGORIZED AND RESOURCE LIST IS GROUPED THEN
           SET PARENT ASSIGNMENT ID FOR RESOURCE LEVEL RECORDS. */

          IF l_uncat_flag <> 'Y'THEN /* Res List not uncategorized */
              IF nvl(l_rl_group_type_id,0) <> 0  THEN /* Res List is grouped */

                pa_debug.g_err_stage := 'Updating the Parent Assignment IDs for Resource Level recs';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('UPDATE_RES_PARENT_ASSIGN_ID: ' || l_module_name,pa_debug.g_err_stage,3);
                END IF;

                UPDATE pa_resource_assignments pra1
                   SET parent_assignment_id =
                       (SELECT resource_assignment_id
                          FROM pa_resource_assignments pra2
                              ,pa_resource_list_members prlm
                         WHERE pra1.resource_list_member_id = prlm.resource_list_member_id
                           AND pra1.task_id = pra2.task_id
                           AND pra2.resource_list_member_id = prlm.parent_member_id
                           AND pra2.budget_version_id = p_budget_version_id
                           AND pra2.resource_list_member_id <> 0)
                 WHERE budget_version_id = p_budget_version_id
                   AND resource_list_member_id <> 0
                   AND parent_assignment_id is null;

                pa_debug.g_err_stage := 'Updated ' || sql%rowcount || ' records' ;
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('UPDATE_RES_PARENT_ASSIGN_ID: ' || l_module_name,pa_debug.g_err_stage,3);
                END IF;

              END IF;

        /* FOR RECORDS NOT YET UPDATED CAN BE THE RESOURCE LEVEL RECORDS FOR WHICH TASK LEVEL
           RECORDS ARE THE PARENTS.  (IN CASE RESOURCE LIST IS GROUPED THEN RESOURCE GROUP LEVEL
           ELSE RESOURCE LEVEL) UPDATE PARENT MEMBER ID FOR SUCH RECORDS. THIS STEP NEED TO BE
           EXECUTED ONLY IF RESOURCE LIST ATTACHED IS NOT UNCATEGORIZED. */

                pa_debug.g_err_stage := 'Updating the Parent Assignment IDs';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('UPDATE_RES_PARENT_ASSIGN_ID: ' || l_module_name,pa_debug.g_err_stage,3);
                END IF;

             /* Do the following only when Planning Level is not 'Project' */

                IF l_planning_level <> PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT THEN

                     UPDATE pa_resource_assignments pra1
                        SET parent_assignment_id =
                            (SELECT resource_assignment_id
                               FROM pa_resource_assignments pra2
                              WHERE pra1.task_id = pra2.task_id
                                AND pra2.resource_list_member_id = 0
                                AND pra2.budget_version_id = p_budget_version_id
				AND pra2.project_id = pra1.project_id )  -- Bug 2814165
                      WHERE budget_version_id = p_budget_version_id
                        AND resource_list_member_id <> 0
                        AND parent_assignment_id is null;

                pa_debug.g_err_stage := 'Updated ' || sql%rowcount || ' records' ;
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('UPDATE_RES_PARENT_ASSIGN_ID: ' || l_module_name,pa_debug.g_err_stage,3);
                END IF;

                 END IF;

          END IF;  /* l_uncat_flag <> 'Y'*/

        /*  UPDATE THE TOP_TASK LEVEL RECORDS WITH PROJECT LEVEL RECORD'S RA ID AS PARENT_ASSIGNMENT_ID.
            THIS IS APPLICABLE ONLY WHEN PLANNING LEVEL IS NOT PROJECT. */

            pa_debug.g_err_stage := 'Updating the Parent Assignment IDs for Top Task Level recs';
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('UPDATE_RES_PARENT_ASSIGN_ID: ' || l_module_name,pa_debug.g_err_stage,3);
            END IF;

            IF l_planning_level <> PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT THEN

                UPDATE pa_resource_assignments pra
                   SET parent_assignment_id = p_proj_ra_id
                 WHERE task_id in
                       (SELECT top_task_id
                          FROM pa_tasks
                         WHERE project_id = l_project_id)
                   AND budget_version_id = p_budget_version_id
                   AND project_id = l_project_id     -- bug#2708524
                   AND resource_list_member_id IN (l_uncat_rlm_id,0)
                   AND parent_assignment_id is null;

             pa_debug.g_err_stage := 'Updated ' || sql%rowcount || ' records' ;
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write('UPDATE_RES_PARENT_ASSIGN_ID: ' || l_module_name,pa_debug.g_err_stage,3);
             END IF;


            END IF;

        /*  UPDATE THE RESOURCE/RESOURCE GROUP LEVEL RECORDS WITH PROJECT LEVEL RECORD'S
            RA ID AS PARENT_ASSIGNMENT_ID. THIS IS APPLICABLE ONLY WHEN PLANNING LEVEL IS PROJECT AND
            RESOURCE LIST IS ATTACHED. UPDATE ONLY THOSE RECORDS FOR WHICH PARENT_ASSIGNMENT_ID IS NULL. */

            IF l_planning_level = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT
               AND l_uncat_flag <> 'Y' THEN

                pa_debug.g_err_stage := 'Updating the Parent Assignment IDs for Res/Res Grp level recs';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('UPDATE_RES_PARENT_ASSIGN_ID: ' || l_module_name,pa_debug.g_err_stage,3);
                END IF;

                UPDATE pa_resource_assignments pra
                   SET parent_assignment_id = p_proj_ra_id
                 WHERE parent_assignment_id is null
                   AND budget_version_id = p_budget_version_id -- bug 2760675, missing version_id join condition
                   AND resource_list_member_id <> 0
                   AND task_id = 0;

             pa_debug.g_err_stage := 'Updated ' || sql%rowcount || ' records' ;
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write('UPDATE_RES_PARENT_ASSIGN_ID: ' || l_module_name,pa_debug.g_err_stage,3);
             END IF;
            END IF;

 pa_debug.g_err_stage := 'end of UPDATE_RES_PARENT_ASSIGN_ID' ;
 IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.write('UPDATE_RES_PARENT_ASSIGN_ID: ' || l_module_name,pa_debug.g_err_stage,3);
 END IF;
 pa_debug.reset_err_stack;

EXCEPTION
  WHEN PA_FP_ROLLUP_PKG.Invalid_Arg_Exc THEN
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
      ELSE
             x_msg_count := l_msg_count;
      END IF;
      pa_debug.reset_err_stack;
    RAISE;
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_FP_ROLLUP_PKG'
            ,p_procedure_name => 'UPDATE_RES_PARENT_ASSIGN_ID');
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('UPDATE_RES_PARENT_ASSIGN_ID: ' || l_module_name,SQLERRM,5);
        END IF;
        pa_debug.reset_err_stack;

        raise FND_API.G_EXC_UNEXPECTED_ERROR;

END UPDATE_RES_PARENT_ASSIGN_ID;

/*==================================================================================================
 INSERT_BULK_ROWS_RES: This procedure inserts records into PA_FP_ELEMENTS in BULK mode.
===================================================================================================*/

PROCEDURE Insert_Bulk_Rows_Res (
            p_project_id               IN NUMBER
           ,p_plan_version_id          IN NUMBER
           ,p_task_id_tbl              IN l_task_id_tbl_typ
           ,p_res_list_mem_id_tbl      IN l_res_list_mem_id_tbl_typ
           ,p_proj_raw_cost_tbl        IN l_proj_raw_cost_tbl_typ
           ,p_proj_burdened_cost_tbl   IN l_proj_burd_cost_tbl_typ
           ,p_proj_revenue_tbl         IN l_proj_revenue_tbl_typ
           ,p_projfunc_raw_cost_tbl    IN l_projfunc_raw_cost_tbl_typ
           ,p_projfunc_burd_cost_tbl   IN l_projfunc_burd_cost_tbl_typ
           ,p_projfunc_revenue_tbl     IN l_projfunc_revenue_tbl_typ
           ,p_quantity_tbl             IN l_quantity_tbl_typ
           ,p_unit_of_measure_tbl      IN l_unit_of_measure_tbl_typ
           ,p_track_as_labor_flag_tbl  IN l_track_as_labor_flag_tbl_typ
           ,x_return_status           OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count               OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data                OUT  NOCOPY VARCHAR2 ) is --File.Sql.39 bug 4440895

        l_msg_count       NUMBER := 0;
        l_data            VARCHAR2(2000);
        l_msg_data        VARCHAR2(2000);
        l_msg_index_out   NUMBER;
        l_return_status   VARCHAR2(2000);
        l_debug_mode      VARCHAR2(30);


 BEGIN

       -- Set the error stack.
          pa_debug.set_err_stack('PA_FP_ROLLUP_PKG.Insert_Bulk_Rows_Res');

       -- Get the Debug mode into local variable and set it to 'Y'if its NULL
          fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
          l_debug_mode := NVL(l_debug_mode, 'Y');

       -- Initialize the return status to success
           x_return_status := FND_API.G_RET_STS_SUCCESS;

           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.set_process('Insert_Bulk_Rows_Res: ' || 'PLSQL','LOG',l_debug_mode);
           END IF;

           pa_debug.g_err_stage := 'In PA_FP_ROLLUP_PKG.Insert_Bulk_Rows_Res ';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('Insert_Bulk_Rows_Res: ' || l_module_name,pa_debug.g_err_stage,3);
           END IF;


       /* Bulk Insert records into PA_RESOURCE_ASSIGNMENTS table for the records fetched
          from cursor top_task_cur. */

    pa_debug.g_err_stage := 'In  Insert_Bulk_Rows_Res';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Insert_Bulk_Rows_Res: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    pa_debug.g_err_stage := 'Bulk inserting into PA_RESOURCE_ASSIGNMENTS';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Insert_Bulk_Rows_Res: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF nvl(p_task_id_tbl.LAST,0) > 0 THEN

    FORALL i in p_task_id_tbl.first..p_task_id_tbl.last

        INSERT INTO pa_resource_assignments
            (RESOURCE_ASSIGNMENT_ID
            ,BUDGET_VERSION_ID
            ,PROJECT_ID
            ,TASK_ID
            ,RESOURCE_LIST_MEMBER_ID
            ,TOTAL_PROJECT_RAW_COST
            ,TOTAL_PROJECT_BURDENED_COST
            ,TOTAL_PROJECT_REVENUE
            ,TOTAL_PLAN_QUANTITY
            ,TOTAL_PLAN_RAW_COST
            ,TOTAL_PLAN_BURDENED_COST
            ,TOTAL_PLAN_REVENUE
            ,LAST_UPDATE_DATE
            ,LAST_UPDATED_BY
            ,CREATION_DATE
            ,CREATED_BY
            ,LAST_UPDATE_LOGIN
            ,UNIT_OF_MEASURE
            ,TRACK_AS_LABOR_FLAG
            ,PROJECT_ASSIGNMENT_ID
            ,RESOURCE_ASSIGNMENT_TYPE )
        VALUES
            (PA_RESOURCE_ASSIGNMENTS_S.NEXTVAL
            ,p_plan_version_id                -- BUDGET_VERSION_ID
            ,p_project_id                     -- PROJECT_ID
            ,p_task_id_tbl(i)                 -- TASK_ID
            ,nvl(p_res_list_mem_id_tbl(i),0)  -- RESOURCE_LIST_MEMBER_ID
            ,p_proj_raw_cost_tbl(i)
            ,p_proj_burdened_cost_tbl(i)
            ,p_proj_revenue_tbl(i)
            ,p_quantity_tbl(i)
            ,p_projfunc_raw_cost_tbl(i)
            ,p_projfunc_burd_cost_tbl(i)
            ,p_projfunc_revenue_tbl(i)
            ,sysdate
            ,fnd_global.user_id
            ,sysdate
            ,fnd_global.user_id
            ,fnd_global.login_id
            ,p_unit_of_measure_tbl(i)
            ,p_track_as_labor_flag_tbl(i)
            ,-1
            ,PA_FP_CONSTANTS_PKG.G_ROLLED_UP)   ;

    pa_debug.g_err_stage := 'inserted ' || sql%rowcount || ' records';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Insert_Bulk_Rows_Res: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;
    END IF;

    pa_debug.reset_err_stack;

EXCEPTION
  WHEN PA_FP_ROLLUP_PKG.Invalid_Arg_Exc THEN
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
      ELSE
             x_msg_count := l_msg_count;
      END IF;
      pa_debug.reset_err_stack;
    RAISE;
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_FP_ROLLUP_PKG'
            ,p_procedure_name => 'Insert_Bulk_Rows_Res') ;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Insert_Bulk_Rows_Res: ' || l_module_name,SQLERRM,5);
        END IF;
        pa_debug.reset_err_stack;

        raise FND_API.G_EXC_UNEXPECTED_ERROR;
END Insert_Bulk_Rows_Res;

/**************************************************************************************
   REFRESH_PERIOD_DENORM: This api does complete rollup of period denorm. It completely
   refreshes the table for entered and rollup records both. It does following
   - delete all rolled up records from denorm table.
   - refreshes the amount at user entered level.
   - insert parent records with amounts.
***************************************************************************************/

PROCEDURE REFRESH_PERIOD_DENORM(p_budget_version_id IN NUMBER
                               ,x_return_status    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                               ,x_msg_count        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                               ,x_msg_data         OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

        l_res_id_tbl                l_ra_id_tbl_typ;
        l_par_id_tbl                l_par_id_tbl_typ;
        l_unit_of_measure_tbl       l_unit_of_measure_tbl_typ;

/* Declare the local variables. to get the values of OUT parameters. */

        l_period_profile_id         pa_budget_versions.PERIOD_PROFILE_ID%TYPE;
        l_resource_list_id          pa_resource_lists.RESOURCE_LIST_ID%TYPE;
        l_uncat_flag                pa_resource_lists.UNCATEGORIZED_FLAG%TYPE;
        l_rl_group_type_id          pa_resource_lists.GROUP_RESOURCE_TYPE_ID%TYPE;
        l_uncat_rlm_id              pa_resource_lists.RESOURCE_LIST_ID%TYPE;
        l_project_id                pa_projects.project_id%TYPE;
        l_planning_level            pa_proj_fp_options.ALL_FIN_PLAN_LEVEL_CODE%TYPE;
        l_data_source               VARCHAR2(20);

        l_msg_count       NUMBER := 0;
        l_data            VARCHAR2(2000);
        l_msg_data        VARCHAR2(2000);
        l_msg_index_out   NUMBER;
        l_return_status   VARCHAR2(2000);
        l_debug_mode      VARCHAR2(30);

        l_curr_rollup_level  NUMBER := 0;

        L_INSERTING_RES_GROUP_LEVEL       boolean := false;
        L_INSERTING_TASK_LEVEL            boolean := false;
        L_INSERTING_PARENT_TASK_LEVEL     boolean := false;

        l_proj_currency_code              pa_projects_all.project_currency_code%TYPE;

BEGIN

       -- Set the error stack.
          pa_debug.set_err_stack('PA_FP_ROLLUP_PKG.Refresh_Period_Denorm');

       -- Get the Debug mode into local variable and set it to 'Y'if its NULL
          fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
          l_debug_mode := NVL(l_debug_mode, 'Y');

       -- Initialize the return status to success
           x_return_status := FND_API.G_RET_STS_SUCCESS;

           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.set_process('REFRESH_PERIOD_DENORM: ' || 'PLSQL','LOG',l_debug_mode);
           END IF;

           pa_debug.g_err_stage := 'In PA_FP_ROLLUP_PKG.Refresh_Period_Denorm ';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('REFRESH_PERIOD_DENORM: ' || l_module_name,pa_debug.g_err_stage,3);
           END IF;


        /* Check for Budget Version ID not being NULL. */
        IF ( p_budget_version_id IS NULL) THEN
                pa_debug.g_err_stage := 'Err- Budget Version ID cannot be NULL.';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('REFRESH_PERIOD_DENORM: ' || l_module_name,pa_debug.g_err_stage,5);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                     p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
                RAISE PA_FP_ROLLUP_PKG.Invalid_Arg_Exc;
        END IF;

        /* Populate the local variables. */
        /* M21-AUG: made call parameterized */
        pa_debug.g_err_stage := 'calling populate_local_vars';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('REFRESH_PERIOD_DENORM: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        populate_local_vars(p_budget_version_id    => p_budget_version_id,
                            x_project_id           => l_project_id,
                            x_resource_list_id     => l_resource_list_id,
                            x_uncat_flag           => l_uncat_flag,
                            x_uncat_rlm_id         => l_uncat_rlm_id,
                            x_rl_group_type_id     => l_rl_group_type_id,
                            x_planning_level       => l_planning_level,
                            x_return_status        => x_return_status,
                            x_msg_count            => x_msg_count,
                            x_msg_data             => x_msg_data);

        pa_debug.g_err_stage := 'selecting period profile id from budget versions ';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('REFRESH_PERIOD_DENORM: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        SELECT period_profile_id
          INTO l_period_profile_id
          FROM pa_budget_versions
         WHERE budget_version_id = p_budget_version_id;

        pa_debug.g_err_stage := 'period profile id = ' || l_period_profile_id ;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('REFRESH_PERIOD_DENORM: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        /* #2801522: Getting the project currency code for storing in the 'QAUNTITY' record. */

        SELECT project_currency_code
          INTO l_proj_currency_code
          FROM pa_projects_all
         WHERE project_id = l_project_id;

        IF (l_period_profile_id IS NOT NULL) THEN

                /* Delete all the records from PA_PROJ_PERIODS_DENORM as new resource assignment IDs
                   would have been generated. */
                pa_debug.g_err_stage := 'period profile id not null deleting denorm records ';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('REFRESH_PERIOD_DENORM: ' || l_module_name,pa_debug.g_err_stage,3);
                END IF;

                DELETE FROM pa_proj_periods_denorm
                 WHERE budget_version_id = p_budget_version_id;

                /* Call call_maintain_plan_matrix API with data source as 'BUDGET_LINES' to dump all budget lines
                   into PA_PROJ_PERIODS_DENORM table.  */

               pa_debug.g_err_stage := 'deleted ' || sql%rowcount || ' records. Calling CALL_MAINTAIN_PLAN_MATRIX' ;
               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.write('REFRESH_PERIOD_DENORM: ' || l_module_name,pa_debug.g_err_stage,3);
               END IF;

               l_data_source := PA_FP_CONSTANTS_PKG.G_DATA_SOURCE_BUDGET_LINE;
               PA_FIN_PLAN_PUB.CALL_MAINTAIN_PLAN_MATRIX(p_budget_version_id => p_budget_version_id
                                                         ,p_data_source      => l_data_source
                                                         ,x_return_status    => x_return_status
                                                         ,x_msg_count        => x_msg_count
                                                         ,x_msg_data         => x_msg_data);

               pa_debug.g_err_stage := 'returned from CALL_MAINTAIN_PLAN_MATRIX' ;
               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.write('REFRESH_PERIOD_DENORM: ' || l_module_name,pa_debug.g_err_stage,3);
               END IF;
               /* set total number of levels in rollup.
                  Total number of level = number of levels in WBS + resource group (in case resource list is grouped)
                                          + resource (in case resource list attached) + 1 (project level)
               */

               IF l_planning_level = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT THEN
                    l_curr_rollup_level := 0;
               ELSIF l_planning_level = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_TOP THEN
                    l_curr_rollup_level := 1;
               ELSE /* planning level is lowest task or top and lowest */
                  select max(wbs_level)
                    into l_curr_rollup_level
                    from pa_tasks
                   where project_id = l_project_id;
               END IF;

               IF l_uncat_flag <> 'Y' THEN /* resource list is attached */
                  l_curr_rollup_level := l_curr_rollup_level + 1;
                  IF l_rl_group_type_id <> 0 THEN /* if resource attached is grouped */
                      L_INSERTING_RES_GROUP_LEVEL := true;
                      l_curr_rollup_level := l_curr_rollup_level + 1;
                  ELSE
                      L_INSERTING_TASK_LEVEL := true;
                  END IF;
               ELSE
                   L_INSERTING_PARENT_TASK_LEVEL := true;
               END IF;

                /* If the amount_type_code is QUANTITY in pa_proj_periods_denorm, then the records
                with unit_of_measure as that in the temp table are rolled up. Hence the temp
                table should contain the uom as HOURS for the first user_enetered_level so that
                the Quantity in the next upper level records are automatically inserted correctly. */

                /* Perform the following steps in a loop until there are no records in the temp
                table PA_FP_RA_MAP_TMP */

                LOOP
                EXIT WHEN l_curr_rollup_level = 0;

                       pa_debug.g_err_stage := 'Inserting into PA_FP_RA_MAP_TMP for User Entered recs';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write('REFRESH_PERIOD_DENORM: ' || l_module_name,pa_debug.g_err_stage,3);
                       END IF;

                       /* Call the procedure insert_parent_rec_temp to insert the parent
                          records into the pa_fp_ra_map_tmp table so that they can be
                          processed in the next loop; */

                        pa_debug.g_err_stage := 'Calling Insert_Parent_Rec_Tmp';
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                           pa_debug.write('REFRESH_PERIOD_DENORM: ' || l_module_name,pa_debug.g_err_stage,3);
                        END IF;

                        INSERT_PARENT_REC_TMP(p_budget_version_id             => p_budget_version_id
                                             ,PX_INSERTING_RES_GROUP_LEVEL    => L_INSERTING_RES_GROUP_LEVEL
                                             ,PX_INSERTING_TASK_LEVEL         => L_INSERTING_TASK_LEVEL
                                             ,PX_INSERTING_PARENT_TASK_LEVEL  => L_INSERTING_PARENT_TASK_LEVEL
                                             ,p_curr_rollup_level             => l_curr_rollup_level);

                        pa_debug.g_err_stage := 'Inserting into PA_Proj_Periods_Denorm';
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                           pa_debug.write('REFRESH_PERIOD_DENORM: ' || l_module_name,pa_debug.g_err_stage,3);
                        END IF;

                        INSERT INTO PA_PROJ_PERIODS_DENORM(
                               PROJECT_ID
                              ,BUDGET_VERSION_ID
                              ,RESOURCE_ASSIGNMENT_ID
                              ,PARENT_ASSIGNMENT_ID
                              ,OBJECT_ID
                              ,OBJECT_TYPE_CODE
                              ,PERIOD_PROFILE_ID
                              ,AMOUNT_TYPE_CODE
                              ,AMOUNT_SUBTYPE_CODE
                              ,AMOUNT_TYPE_ID
                              ,AMOUNT_SUBTYPE_ID
                              ,CURRENCY_TYPE
                              ,CURRENCY_CODE
                              ,PRECEDING_periods_amount
                              ,SUCCEEDING_periods_amount
                              ,PRIOR_PERIOD_AMOUNT
                              ,PERIOD_AMOUNT1
                              ,PERIOD_AMOUNT2
                              ,PERIOD_AMOUNT3
                              ,PERIOD_AMOUNT4
                              ,PERIOD_AMOUNT5
                              ,PERIOD_AMOUNT6
                              ,PERIOD_AMOUNT7
                              ,PERIOD_AMOUNT8
                              ,PERIOD_AMOUNT9
                              ,PERIOD_AMOUNT10
                              ,PERIOD_AMOUNT11
                              ,PERIOD_AMOUNT12
                              ,PERIOD_AMOUNT13
                              ,PERIOD_AMOUNT14
                              ,PERIOD_AMOUNT15
                              ,PERIOD_AMOUNT16
                              ,PERIOD_AMOUNT17
                              ,PERIOD_AMOUNT18
                              ,PERIOD_AMOUNT19
                              ,PERIOD_AMOUNT20
                              ,PERIOD_AMOUNT21
                              ,PERIOD_AMOUNT22
                              ,PERIOD_AMOUNT23
                              ,PERIOD_AMOUNT24
                              ,PERIOD_AMOUNT25
                              ,PERIOD_AMOUNT26
                              ,PERIOD_AMOUNT27
                              ,PERIOD_AMOUNT28
                              ,PERIOD_AMOUNT29
                              ,PERIOD_AMOUNT30
                              ,PERIOD_AMOUNT31
                              ,PERIOD_AMOUNT32
                              ,PERIOD_AMOUNT33
                              ,PERIOD_AMOUNT34
                              ,PERIOD_AMOUNT35
                              ,PERIOD_AMOUNT36
                              ,PERIOD_AMOUNT37
                              ,PERIOD_AMOUNT38
                              ,PERIOD_AMOUNT39
                              ,PERIOD_AMOUNT40
                              ,PERIOD_AMOUNT41
                              ,PERIOD_AMOUNT42
                              ,PERIOD_AMOUNT43
                              ,PERIOD_AMOUNT44
                              ,PERIOD_AMOUNT45
                              ,PERIOD_AMOUNT46
                              ,PERIOD_AMOUNT47
                              ,PERIOD_AMOUNT48
                              ,PERIOD_AMOUNT49
                              ,PERIOD_AMOUNT50
                              ,PERIOD_AMOUNT51
                              ,PERIOD_AMOUNT52
                              ,LAST_UPDATE_DATE
                              ,LAST_UPDATED_BY
                              ,CREATION_DATE
                              ,CREATED_BY
                              ,LAST_UPDATE_LOGIN
                              )
                        SELECT ppd.project_id
                              ,ppd.budget_version_id
                              ,tmp.parent_assignment_id  resource_assignment_id
                              ,NULL                      -- parent_Assignment_id
                              ,tmp.parent_assignment_id  -- #2723515: object_id should be the same as ra id
                              ,object_type_code
                              ,period_profile_id
                              ,amount_type_code
                              ,amount_subtype_code
                              ,amount_type_id
                              ,amount_subtype_id
                              ,currency_type
                              ,decode(amount_subtype_code,PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_QUANTITY,
                                      l_proj_currency_code,currency_code) --#2801522:For Qty, store Proj Curr Code
                              ,sum(nvl(preceding_periods_amount,0))
                              ,sum(nvl(succeeding_periods_amount,0))
                              ,sum(nvl(prior_period_amount,0))
                              ,sum(nvl(period_amount1,0))       period_amount1
                              ,sum(nvl(period_amount2,0))       period_amount2
                              ,sum(nvl(period_amount3,0))       period_amount3
                              ,sum(nvl(period_amount4,0))       period_amount4
                              ,sum(nvl(period_amount5,0))       period_amount5
                              ,sum(nvl(period_amount6,0))       period_amount6
                              ,sum(nvl(period_amount7,0))       period_amount7
                              ,sum(nvl(period_amount8,0))       period_amount8
                              ,sum(nvl(period_amount9,0))       period_amount9
                              ,sum(nvl(period_amount10,0))      period_amount10
                              ,sum(nvl(period_amount11,0))      period_amount11
                              ,sum(nvl(period_amount12,0))      period_amount12
                              ,sum(nvl(period_amount13,0))      period_amount13
                              ,sum(nvl(period_amount14,0))      period_amount14
                              ,sum(nvl(period_amount15,0))      period_amount15
                              ,sum(nvl(period_amount16,0))      period_amount16
                              ,sum(nvl(period_amount17,0))      period_amount17
                              ,sum(nvl(period_amount18,0))      period_amount18
                              ,sum(nvl(period_amount19,0))      period_amount19
                              ,sum(nvl(period_amount20,0))      period_amount20
                              ,sum(nvl(period_amount21,0))      period_amount21
                              ,sum(nvl(period_amount22,0))      period_amount22
                              ,sum(nvl(period_amount23,0))      period_amount23
                              ,sum(nvl(period_amount24,0))      period_amount24
                              ,sum(nvl(period_amount25,0))      period_amount25
                              ,sum(nvl(period_amount26,0))      period_amount26
                              ,sum(nvl(period_amount27,0))      period_amount27
                              ,sum(nvl(period_amount28,0))      period_amount28
                              ,sum(nvl(period_amount29,0))      period_amount29
                              ,sum(nvl(period_amount30,0))      period_amount30
                              ,sum(nvl(period_amount31,0))      period_amount31
                              ,sum(nvl(period_amount32,0))      period_amount32
                              ,sum(nvl(period_amount33,0))      period_amount33
                              ,sum(nvl(period_amount34,0))      period_amount34
                              ,sum(nvl(period_amount35,0))      period_amount35
                              ,sum(nvl(period_amount36,0))      period_amount36
                              ,sum(nvl(period_amount37,0))      period_amount37
                              ,sum(nvl(period_amount38,0))      period_amount38
                              ,sum(nvl(period_amount39,0))      period_amount39
                              ,sum(nvl(period_amount40,0))      period_amount40
                              ,sum(nvl(period_amount41,0))      period_amount41
                              ,sum(nvl(period_amount42,0))      period_amount42
                              ,sum(nvl(period_amount43,0))      period_amount43
                              ,sum(nvl(period_amount44,0))      period_amount44
                              ,sum(nvl(period_amount45,0))      period_amount45
                              ,sum(nvl(period_amount46,0))      period_amount46
                              ,sum(nvl(period_amount47,0))      period_amount47
                              ,sum(nvl(period_amount48,0))      period_amount48
                              ,sum(nvl(period_amount49,0))      period_amount49
                              ,sum(nvl(period_amount50,0))      period_amount50
                              ,sum(nvl(period_amount51,0))      period_amount51
                              ,sum(nvl(period_amount52,0))      period_amount52
                              ,sysdate
                              ,fnd_global.user_id
                              ,sysdate
                              ,fnd_global.user_id
                              ,fnd_global.login_id
                         FROM pa_fp_ra_map_tmp tmp,
                              pa_proj_periods_denorm ppd
                        WHERE tmp.resource_assignment_id = ppd.resource_assignment_id
                          AND ppd.budget_version_id = p_budget_version_id -- performance bug 2802862
                          AND ((currency_type <> PA_FP_CONSTANTS_PKG.G_CURRENCY_TYPE_TRANSACTION) OR
                               (amount_type_code = PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_QUANTITY AND
                                   currency_type = PA_FP_CONSTANTS_PKG.G_CURRENCY_TYPE_TRANSACTION))
                          AND decode(ppd.amount_type_code,PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_QUANTITY,
                                      tmp.unit_of_measure,PA_FP_CONSTANTS_PKG.G_UNIT_OF_MEASURE_HOURS) =
                                                                         PA_FP_CONSTANTS_PKG.G_UNIT_OF_MEASURE_HOURS
                        GROUP BY tmp.parent_assignment_id, currency_type,
                              currency_code, amount_type_code, amount_subtype_code,
                              amount_type_id,amount_subtype_id,
                              ppd.project_id ,ppd.budget_version_id,
                              /*object_id,*/ object_type_code, period_profile_id ; -- bug 2740741

                         /*************** comment for the above change ************************
                          Object_id is popultated same as resource_assignment_id.The intention
                          was to group by parent assignment id and not resource_assignment_id.
                          So, the object_id has been commented from the group by list.
                          *************** comment for the above change ************************/

                         pa_debug.g_err_stage := 'Inserted ' || sql%rowcount || ' records into denorm table';
                         IF P_PA_DEBUG_MODE = 'Y' THEN
                            pa_debug.write('REFRESH_PERIOD_DENORM: ' || l_module_name,pa_debug.g_err_stage,3);
                         END IF;

                         /* set the exist condition */
                         l_curr_rollup_level := l_curr_rollup_level - 1;

                END LOOP; /* End Loop for the whole cycle of insertion of records */

                /* Call the procedure UPDATE_DENORM_PARENT_ASSIGN_ID to update the Parent
                   Assignment IDs on the Denorm Table. */

                pa_debug.g_err_stage := 'Calling UPDATE_DENORM_PARENT_ASSIGN_ID';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('REFRESH_PERIOD_DENORM: ' || l_module_name,pa_debug.g_err_stage,3);
                END IF;
                UPDATE_DENORM_PARENT_ASSIGN_ID(p_budget_version_id => p_budget_version_id
                                              ,x_return_status     => x_return_status
                                              ,x_msg_count         => x_msg_count
                                              ,x_msg_data          => x_msg_data);

        END IF; /* END IF for period_profile_id */

        pa_debug.g_err_stage := 'end of refresh_period_denorm';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('REFRESH_PERIOD_DENORM: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        pa_debug.reset_err_stack;

EXCEPTION
  WHEN PA_FP_ROLLUP_PKG.Invalid_Arg_Exc THEN
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
      ELSE
             x_msg_count := l_msg_count;
      END IF;
      pa_debug.reset_err_stack;
    RAISE;
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_FP_ROLLUP_PKG'
            ,p_procedure_name => 'Refresh_Period_Denorm');
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('REFRESH_PERIOD_DENORM: ' || l_module_name,SQLERRM,5);
        END IF;
        pa_debug.reset_err_stack;

        raise FND_API.G_EXC_UNEXPECTED_ERROR;
END REFRESH_PERIOD_DENORM;


/***********************************************************************************************
UPDATE_DENORM_PARENT_ASSIGN_ID: This procedure updates the Parent Assignment ID on the
pa_proj_periods_denorm table.
***********************************************************************************************/
PROCEDURE UPDATE_DENORM_PARENT_ASSIGN_ID(
          p_budget_version_id   IN  NUMBER
         ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data            OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

        l_msg_count       NUMBER := 0;
        l_data            VARCHAR2(2000);
        l_msg_data        VARCHAR2(2000);
        l_msg_index_out   NUMBER;
        l_return_status   VARCHAR2(2000);
        l_debug_mode      VARCHAR2(30);

BEGIN

       -- Set the error stack.
          pa_debug.set_err_stack('PA_FP_ROLLUP_PKG.Update_Denorm_Parent_Assign_ID');

       -- Get the Debug mode into local variable and set it to 'Y'if its NULL
          fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
          l_debug_mode := NVL(l_debug_mode, 'Y');

       -- Initialize the return status to success
           x_return_status := FND_API.G_RET_STS_SUCCESS;

           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.set_process('UPDATE_DENORM_PARENT_ASSIGN_ID: ' || 'PLSQL','LOG',l_debug_mode);
           END IF;

           /* Updating the records present in the table pa_proj_periods_denorm with the Parent
              Assignment ID. */
          pa_debug.g_err_stage := 'updating parents on denorm table';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('UPDATE_DENORM_PARENT_ASSIGN_ID: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;

          UPDATE pa_proj_periods_denorm ppd
             SET ppd.parent_assignment_id =
                 (SELECT parent_assignment_id
                    FROM pa_resource_assignments pra
                   WHERE pra.resource_assignment_id = ppd.resource_assignment_id)
           WHERE ppd.budget_version_id = p_budget_version_id; /* M21-AUG: added this condition */

          pa_debug.g_err_stage := 'updated ' || sql%rowcount || ' records';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('UPDATE_DENORM_PARENT_ASSIGN_ID: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;
          pa_debug.reset_err_stack;

EXCEPTION
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_FP_ROLLUP_PKG'
            ,p_procedure_name => 'UPDATE_DENORM_PARENT_ASSIGN_ID');
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('UPDATE_DENORM_PARENT_ASSIGN_ID: ' || l_module_name,SQLERRM,5);
        END IF;
        pa_debug.reset_err_stack;

        raise FND_API.G_EXC_UNEXPECTED_ERROR;
END UPDATE_DENORM_PARENT_ASSIGN_ID;

/***********************************************************************************************
   INSERT_MISSING_RES_PARENTS: This api creates missing parents for the records in input
   temp table. For newly created parents it also updates the parent assignment id.This api will
   just create the records and will not update the amounts.
***********************************************************************************************/

PROCEDURE INSERT_MISSING_RES_PARENTS(p_budget_version_id IN NUMBER
                                    ,x_return_status     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                    ,x_msg_count         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                    ,x_msg_data          OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

        /* Added for the bug #2622594. */
        CURSOR cur_parent_ra_id(c_budget_version_id IN NUMBER
                               ,c_project_id        IN NUMBER ) IS    --bug#2708524
            SELECT pra1.resource_assignment_id child_ra_id , pra2.resource_assignment_id parent_ra_id
               FROM pa_resource_assignments pra1,
                    pa_resource_assignments pra2,
                    pa_resource_list_members prlm
              WHERE pra1.resource_list_member_id = prlm.resource_list_member_id
                AND pra2.resource_list_member_id = prlm.parent_member_id
                AND pra1.task_id = pra2.task_id
                AND pra2.budget_version_id = c_budget_version_id
                AND pra1.budget_version_id = c_budget_version_id
                AND pra2.project_id = c_project_id                    --bug#2708524
                AND pra1.project_id = c_project_id                    --bug#2771574
                AND pra1.resource_list_member_id <> 0
                AND pra1.parent_assignment_id IS NULL  /* manokuma: added during unit testing */
                AND pra1.resource_assignment_id IN
                    (SELECT resource_assignment_id FROM pa_fp_ra_map_tmp);

     /* #2697999: Modified the below cursor to fetch the uom and track_as_labor_flag for
        the Resource group. If the Track as labor flag is 'Y', only then the UOM
        is populated as 'HOURS' for the res grp, else it is populated as NULL.
        For all the other rolled up records the uom is 'HOURS' and track as labor flag
        is 'Y'. */

        CURSOR cur_parent_res_rec(c_budget_version_id IN NUMBER
                                 ,c_project_id        IN NUMBER )  IS --bug#2708524
         SELECT TASK_ID
               ,prlm.PARENT_MEMBER_ID    RESOURCE_LIST_MEMBER_ID
               ,max(decode(parent_prlm.track_as_labor_flag,'Y',
                       PA_FP_CONSTANTS_PKG.G_UNIT_OF_MEASURE_HOURS
                       ,NULL))  unit_of_measure         -- Added for bug #2697999
               ,max(parent_prlm.track_as_labor_flag) track_as_labor_flag
                                                        -- Added for bug #2697999
           FROM pa_resource_assignments pra
               ,pa_resource_list_members prlm
               ,pa_resource_list_members parent_prlm
          WHERE pra.project_id = c_project_id                         --bug#2708524
            AND pra.budget_version_id = c_budget_version_id
            AND pra.resource_list_member_id <> 0
            AND pra.resource_list_member_id = prlm.resource_list_member_id
            AND prlm.parent_member_id = parent_prlm.resource_list_member_id
            AND prlm.parent_member_id is not null
            AND resource_assignment_id in
                (SELECT resource_assignment_id FROM pa_fp_ra_map_tmp)
          GROUP BY pra.task_id, prlm.parent_member_id;

        CURSOR cur_task_rec(c_budget_version_id IN NUMBER
                           ,c_project_id        IN NUMBER) IS         --bug#2708524
         SELECT task_id
           FROM pa_resource_assignments pra
          WHERE pra.budget_version_id = c_budget_version_id
            AND pra.project_id = c_project_id
            AND pra.resource_list_member_id <> 0
            AND pra.resource_assignment_id IN
                (SELECT resource_assignment_id FROM pa_fp_ra_map_tmp)
          GROUP BY task_id;

        CURSOR cur_parent_task_rec(c_curr_wbs_level    IN NUMBER
                                  ,c_budget_version_id IN NUMBER      --bug#2708524
                                  ,c_project_id        IN NUMBER) IS  --bug#2708524
         SELECT PARENT_TASK_ID    TASK_ID
           FROM pa_resource_assignments pra
               ,pa_tasks pt
          WHERE pra.resource_assignment_id IN
                (select resource_assignment_id FROM pa_fp_ra_map_tmp )
            AND pra.project_id = c_project_id                       --bug#2708524
            AND pra.budget_version_id = c_budget_version_id         --bug#2708524
            AND pra.task_id = pt.task_id
            AND pt.parent_task_id IS NOT NULL
            AND pt.wbs_level = c_curr_wbs_level
          GROUP BY pt.parent_task_id;

        l_continue_processing_flag VARCHAR2(1);
        l_uncat_rlm_id              pa_resource_assignments.RESOURCE_LIST_MEMBER_ID%TYPE;
        l_resource_list_id          pa_resource_lists.RESOURCE_LIST_ID%TYPE;
        l_uncat_flag                pa_resource_lists.UNCATEGORIZED_FLAG%TYPE;
        l_rl_group_type_id          pa_resource_lists.GROUP_RESOURCE_TYPE_ID%TYPE;
        l_project_id                pa_projects.project_id%TYPE;
        l_planning_level            pa_proj_fp_options.ALL_FIN_PLAN_LEVEL_CODE%TYPE;

        l_ra_id_tbl           l_ra_id_tbl_typ;
        l_parent_res_id_tbl   l_ra_id_tbl_typ;
        l_parent_ra_id_tbl    l_par_id_tbl_typ;
        l_task_id_tbl         l_task_id_tbl_typ;
        l_res_list_mem_id_tbl l_res_list_mem_id_tbl_typ;
        l_proj_count_rec      NUMBER;
        l_proj_ra_id          pa_resource_assignments.RESOURCE_ASSIGNMENT_ID%TYPE;
        l_unit_of_measure_tbl     l_unit_of_measure_tbl_typ;
        l_track_as_labor_flag_tbl l_track_as_labor_flag_tbl_typ;

        l_msg_count       NUMBER := 0;
        l_data            VARCHAR2(2000);
        l_msg_data        VARCHAR2(2000);
        l_msg_index_out   NUMBER;
        l_return_status   VARCHAR2(2000);
        l_debug_mode      VARCHAR2(30);

        l_curr_wbs_level  NUMBER;


BEGIN

       -- Set the error stack.
          pa_debug.set_err_stack('PA_FP_ROLLUP_PKG.Insert_Missing_Res_Parents');

       -- Get the Debug mode into local variable and set it to 'Y'if its NULL
          fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
          l_debug_mode := NVL(l_debug_mode, 'Y');

       -- Initialize the return status to success
           x_return_status := FND_API.G_RET_STS_SUCCESS;

           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.set_process('INSERT_MISSING_RES_PARENTS: ' || 'PLSQL','LOG',l_debug_mode);
           END IF;

           pa_debug.g_err_stage := 'In PA_FP_ROLLUP_PKG.Insert_Missing_Res_Parents ';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
           END IF;


        /* Check for Budget Version ID not being NULL. */
        IF ( p_budget_version_id IS NULL) THEN
                pa_debug.g_err_stage := 'Err- Budget Version ID cannot be NULL.';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,5);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                     p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
                RAISE PA_FP_ROLLUP_PKG.Invalid_Arg_Exc;
        END IF;

      /* Populate the local variables. */

      pa_debug.g_err_stage := 'calling populate_local_vars';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
      END IF;

      populate_local_vars(p_budget_version_id    => p_budget_version_id,
                          x_project_id           => l_project_id,
                          x_resource_list_id     => l_resource_list_id,
                          x_uncat_flag           => l_uncat_flag,
                          x_uncat_rlm_id         => l_uncat_rlm_id,
                          x_rl_group_type_id     => l_rl_group_type_id,
                          x_planning_level       => l_planning_level,
                          x_return_status        => x_return_status,
                          x_msg_count            => x_msg_count,
                          x_msg_data             => x_msg_data);

     pa_debug.g_err_stage := 'checking if resource list is attached and is grouped';
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF l_uncat_flag <> 'Y' THEN /* if Resource List is not uncategorized */

          pa_debug.g_err_stage := 'resource list is attached';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;

          IF nvl(l_rl_group_type_id,0) <> 0  THEN /* Res List is grouped */

             pa_debug.g_err_stage := 'resource list is grouped';
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
             END IF;

          LOOP

          /* Update parent_assignment_id on pa_resource_assignments for the resource level records
             for which parents are inserted in last step. */

            pa_debug.g_err_stage := 'Updating Parent_Assignment_IDs for Recs having parents */';
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
            END IF;

            /* Bug #2622594: Modified the logic of updating the resource asignments for the
               resource level records. Using a cursor instead of a direct update. */

            /*      UPDATE pa_resource_assignments pra1
                       SET parent_assignment_id =
                           (SELECT resource_assignment_id
                              FROM pa_resource_assignments pra2, pa_resource_list_members prlm
                             WHERE pra1.resource_list_member_id = prlm.resource_list_member_id
                               AND pra2.resource_list_member_id = prlm.parent_member_id
                               AND pra1.task_id = pra2.task_id
                               AND pra2.budget_version_id = p_budget_version_id)
                     WHERE budget_version_id = p_budget_version_id
                       AND resource_list_member_id <> 0
                       AND parent_assignment_id IS NULL  -- manokuma: added during unit testing
                       AND resource_assignment_id in
                          (select resource_assignment_id from pa_fp_ra_map_tmp)
                    RETURNING pra1.resource_assignment_id, pra1.parent_assignment_id
                    BULK COLLECT INTO l_ra_id_tbl, l_parent_ra_id_tbl; */

                    OPEN cur_parent_ra_id(p_budget_version_id,l_project_id);

                    FETCH cur_parent_ra_id
                    BULK COLLECT INTO l_ra_id_tbl, l_parent_ra_id_tbl;

                    IF nvl(l_ra_id_tbl.last,0) > 0 THEN

                         FORALL i in l_ra_id_tbl.first..l_ra_id_tbl.last
                           UPDATE pa_resource_assignments
                              SET parent_assignment_id =  l_parent_ra_id_tbl(i)
                            WHERE resource_assignment_id = l_ra_id_tbl(i);

                           pa_debug.g_err_stage := 'updated ' || sql%rowcount || ' records';
                           IF P_PA_DEBUG_MODE = 'Y' THEN
                              pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                           END IF;

                    END IF;

                    CLOSE cur_parent_ra_id;

                    IF nvl(l_ra_id_tbl.last,0) >= 1 THEN /* only if something is fetched */

                     /* Delete the records from pa_fp_ra_map_tmp table where Resource Assignments are
                        present in the PL/SQL table returned and the Parent ID is NOT NULL. */

                        FORALL i in l_ra_id_tbl.first..l_ra_id_tbl.last

                          DELETE FROM pa_fp_ra_map_tmp
                           WHERE resource_assignment_id = l_ra_id_tbl(i)
                             AND l_parent_ra_id_tbl(i) IS NOT NULL;

                          pa_debug.g_err_stage := 'deleted  ' || sql%rowcount || ' records from ra map tmp';
                          IF P_PA_DEBUG_MODE = 'Y' THEN
                             pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                          END IF;


                    END IF;

               /* For the resource level records in pa_fp_ra_map_tmp, Insert the
                  resource group level records. */

                  pa_debug.g_err_stage := 'Inserting Resource Group Level records';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                  END IF;
                  OPEN cur_parent_res_rec(p_budget_version_id,l_project_id);

                     /* #2697999: Added two more PL/SQL tables to fetch the uom and track as labor flag */
                     FETCH cur_parent_res_rec BULK COLLECT INTO
                           l_task_id_tbl, l_res_list_mem_id_tbl,l_unit_of_measure_tbl,l_track_as_labor_flag_tbl;
                      EXIT WHEN nvl(l_task_id_tbl.last,0) <= 0; /* manokuma changes during ut cur_parent_res_rec%NOTFOUND; */

                           IF nvl(l_task_id_tbl.last,0) > 0 THEN

                           FORALL i in l_task_id_tbl.first..l_task_id_tbl.last

                                    INSERT INTO pa_resource_assignments
                                           (RESOURCE_ASSIGNMENT_ID
                                           ,BUDGET_VERSION_ID
                                           ,PROJECT_ID
                                           ,TASK_ID
                                           ,RESOURCE_LIST_MEMBER_ID
                                           ,LAST_UPDATE_DATE
                                           ,LAST_UPDATED_BY
                                           ,CREATION_DATE
                                           ,CREATED_BY
                                           ,LAST_UPDATE_LOGIN
                                           ,UNIT_OF_MEASURE
                                           ,TRACK_AS_LABOR_FLAG
                                           ,PROJECT_ASSIGNMENT_ID
                                           ,RESOURCE_ASSIGNMENT_TYPE )
                                    VALUES
                                           (PA_RESOURCE_ASSIGNMENTS_S.NEXTVAL
                                           ,p_budget_version_id
                                           ,l_project_id
                                           ,l_task_id_tbl(i)
                                           ,l_res_list_mem_id_tbl(i)
                                           ,sysdate
                                           ,fnd_global.user_id
                                           ,sysdate
                                           ,fnd_global.user_id
                                           ,fnd_global.login_id
                                           ,l_unit_of_measure_tbl(i)
                                           ,l_track_as_labor_flag_tbl(i)
                                           ,-1
                                           ,PA_FP_CONSTANTS_PKG.G_ROLLED_UP)
                                 RETURNING resource_assignment_id
                                 BULK COLLECT INTO l_parent_res_id_tbl;

                           END IF;
                                  pa_debug.g_err_stage := 'inserted  ' || sql%rowcount || ' records in res assignments';
                                  IF P_PA_DEBUG_MODE = 'Y' THEN
                                     pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                                  END IF;


                           /* Insert the parent returned into l_parent_ra_id_tbl
                              into the Temp table pa_fp_ra_map_tmp. */

                              IF nvl(l_parent_res_id_tbl.last,0) > 0 THEN

                              FORALL i in l_parent_res_id_tbl.first..l_parent_res_id_tbl.last

                                      INSERT INTO pa_fp_ra_map_tmp
                                             (RESOURCE_ASSIGNMENT_ID)
                                      VALUES
                                             (l_parent_res_id_tbl(i));
                              END IF;

                              pa_debug.g_err_stage := 'inserted  ' || sql%rowcount || ' records in map tmp';
                              IF P_PA_DEBUG_MODE = 'Y' THEN
                                 pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                              END IF;

                          CLOSE cur_parent_res_rec;      /* M21-08: a wrong cursor was closed here */

              END LOOP; /* Close of the loop */
         END IF; /* Res List is grouped */

         pa_debug.g_err_stage := 'done processing when resource list is grouped';
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
         END IF;


         /* If resource list is not grouped (group_resource_type_id = 0) then the temp table will
            contain only resource level records. For these records we need to insert task level
            records only. Following step is common for resource group level as well as resource level. */

         IF l_planning_level <> PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT THEN

             /* Creating a Loop to continuously stamp the parent_assignment_id. By the end of this
                loop, pa_fp_ra_map_tmp table will contain only task level records. */
             l_task_id_tbl.delete;  /* Deleting records from TASKID pl/sql table so that it can be used later. */

             LOOP

                /* If task level records are already present in the PA_Resource_Assignments table,
                   then parent_assignment_id needs to be stamped on pa_Resource_assignments table. */

                  pa_debug.g_err_stage := 'Updating the Parent Assignment IDs for resource level records';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                  END IF;
                  UPDATE pa_resource_assignments pra1
                     SET parent_assignment_id =
                         (SELECT resource_assignment_id
                            FROM pa_resource_assignments pra2
                            WHERE pra2.task_id = pra1.task_id
                              AND pra2.resource_list_member_id = 0
                              AND pra2.budget_version_id = p_budget_version_id)
                    WHERE resource_assignment_id in
                          (select resource_assignment_id from pa_fp_ra_map_tmp)
                      AND pra1.resource_list_member_id <> 0
                      AND pra1.budget_version_id = p_budget_version_id
                   RETURNING resource_assignment_id, parent_assignment_id
                   BULK COLLECT INTO l_ra_id_tbl, l_parent_ra_id_tbl;

                   pa_debug.g_err_stage := 'updated ' || sql%rowcount || ' records';
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                   END IF;

                   /* Delete the records from pa_fp_ra_map_tmp table where Resource Assignments are
                      present in the PL/SQL table returned and the Parent ID is NOT NULL. */

                   IF nvl(l_ra_id_tbl.last,0) > 0 THEN

                    FORALL i in l_ra_id_tbl.first..l_ra_id_tbl.last

                      DELETE FROM pa_fp_ra_map_tmp
                       WHERE resource_assignment_id = l_ra_id_tbl(i)
                         AND l_parent_ra_id_tbl(i) IS NOT NULL;
                   END IF;

                    pa_debug.g_err_stage := 'deleted ' || sql%rowcount || ' records from ra map tmp';
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                    END IF;

                    /* Insert task level records for the records available in pa_fp_ra_map_tmp table
                     (as of now only those records are available for which task level records do not exist). */

                     pa_debug.g_err_stage := 'Inserting Task Level Records';
                     IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                     END IF;
                     OPEN cur_task_rec(p_budget_version_id,l_project_id);

                     FETCH cur_task_rec BULK COLLECT INTO l_task_id_tbl;
                     EXIT WHEN nvl(l_task_id_tbl.last,0) <= 0; /* manokuma changed during ut cur_task_rec%NOTFOUND; */

                     IF nvl(l_task_id_tbl.last,0) > 0 THEN

                     FORALL i in l_task_id_tbl.first..l_task_id_tbl.last
                         INSERT INTO PA_RESOURCE_ASSIGNMENTS
                                     (RESOURCE_ASSIGNMENT_ID
                                     ,BUDGET_VERSION_ID
                                     ,PROJECT_ID
                                     ,TASK_ID
                                     ,RESOURCE_LIST_MEMBER_ID
                                     ,LAST_UPDATE_DATE
                                     ,LAST_UPDATED_BY
                                     ,CREATION_DATE
                                     ,CREATED_BY
                                     ,LAST_UPDATE_LOGIN
                                     ,UNIT_OF_MEASURE
                                     ,TRACK_AS_LABOR_FLAG
                                     ,PROJECT_ASSIGNMENT_ID
                                     ,RESOURCE_ASSIGNMENT_TYPE )
                              VALUES
                                     (PA_RESOURCE_ASSIGNMENTS_S.NEXTVAL
                                     ,p_budget_version_id
                                             ,l_project_id
                                             ,l_task_id_tbl(i)
                                             ,0                  -- res_list_mem_id is 0 for tasks
                                             ,sysdate
                                             ,fnd_global.user_id
                                             ,sysdate
                                             ,fnd_global.user_id
                                             ,fnd_global.login_id
                                             ,PA_FP_CONSTANTS_PKG.G_UNIT_OF_MEASURE_HOURS -- Modified for #2697999
                                             ,'Y'                                         -- Modified for #2697999
                                             ,-1
                                             ,PA_FP_CONSTANTS_PKG.G_ROLLED_UP)
                                   RETURNING resource_assignment_id
                                   BULK COLLECT INTO l_ra_id_tbl;
                     END IF;

                     pa_debug.g_err_stage := 'inserted ' || sql%rowcount || ' records in res assignments';
                     IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                     END IF;

                     /* Insert the newly generated resource assignment ids into pa_fp_ra_map_tmp table as for these
                       records either parents need to be find or inserted. */

                     IF nvl(l_ra_id_tbl.last,0) > 0 THEN

                     FORALL i in l_ra_id_tbl.first..l_ra_id_tbl.last

                        INSERT INTO pa_fp_ra_map_tmp(resource_assignment_id)
                        VALUES (l_ra_id_tbl(i));

                     END IF;

                    CLOSE  cur_task_rec;

             END LOOP;

         END IF; /* l_planning_level <> PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT*/

     END IF;  /* if Resource List is not uncategorized */

     /* The Following steps have to be done irrespective of whether the Resource List is attached or not.*/

     pa_debug.g_err_stage := 'now processing task level records. Inserting parent task level records for these';
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

     l_task_id_tbl.delete;

     BEGIN

          SELECT 'Y'
            INTO l_continue_processing_flag
            FROM dual
           WHERE EXISTS (SELECT 1
                           FROM pa_fp_ra_map_tmp);

     EXCEPTION

     WHEN NO_DATA_FOUND THEN
         l_continue_processing_flag := 'N';
     END;

     pa_debug.g_err_stage := 'l_continue_processing_flag is '||l_continue_processing_flag;
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF (l_continue_processing_flag = 'Y') THEN /* Only if there are records existing in pa_fp_ra_map_tmp */

          pa_debug.g_err_stage := 'there are task level records to be processed';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;

          IF (l_planning_level NOT IN (PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_TOP,
                                        PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT)) THEN

          /* If task planning level for the version is not 'TOP_TASK'or 'PROJECT' THEN Insert middle
             level tasks and top task records into PA_RESOURCE_ASSIGNMENTS. */

             l_curr_wbs_level := 0;
             select max(wbs_level)
             into l_curr_wbs_level
             from pa_tasks
             where project_id = l_project_id;

           pa_debug.g_err_stage := 'l_curr_wbs_level =' || l_curr_wbs_level ;
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
           END IF;

           LOOP
           EXIT WHEN l_curr_wbs_level = 0; /* manokuma: changed during ut cur_parent_task_rec%NOTFOUND; */


                /* Before starting the insert we need to check if parent task records already exists or not
                   and if yes then update PARENT_ASSIGNMENT_ID */

                   pa_debug.g_err_stage := 'Updating the Parent Assignment IDs for task level records';
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                   END IF;

                   l_ra_id_tbl.delete;
                   l_parent_ra_id_tbl.delete;

                   UPDATE /*+ INDEX(pra1 PA_RESOURCE_ASSIGNMENTS_U1)*/ pa_resource_assignments pra1 --Bug 2782166
                      SET parent_assignment_id =
                          (select resource_assignment_id
                             from pa_resource_assignments pra2
                                 ,pa_tasks t
                            where pra2.task_id = t.parent_task_id
                              and pra1.task_id = t.task_id
                              and pra2.budget_version_id = p_budget_version_id) /* manokuma: fixed during ut */
                   WHERE resource_assignment_id in
                         (select resource_assignment_id from pa_fp_ra_map_tmp)
                   RETURNING resource_assignment_id, parent_assignment_id
                   BULK COLLECT INTO l_ra_id_tbl, l_parent_ra_id_tbl;

                   pa_debug.g_err_stage := 'updated ' || sql%rowcount || ' records ';
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                   END IF;

                   /* Delete the records from pa_fp_ra_map_tmp table where Resource Assignments are
                      present in the PL/SQL table returned and the Parent ID is NOT NULL. */

                   IF nvl(l_ra_id_tbl.last,0) > 0 THEN
                      FORALL i in l_ra_id_tbl.first..l_ra_id_tbl.last

                        DELETE FROM pa_fp_ra_map_tmp
                         WHERE resource_assignment_id = l_ra_id_tbl(i)
                           AND l_parent_ra_id_tbl(i) IS NOT NULL;

                       pa_debug.g_err_stage := 'deleted ' || sql%rowcount || ' records from map tmp';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                       END IF;
                   END IF;

                    /* Insert the Parent task level records for the records available in pa_fp_ra_map_tmp table */

                     pa_debug.g_err_stage := 'Inserting the Parent Task Level records';
                     IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                     END IF;

                     l_task_id_tbl.delete;
                     OPEN cur_parent_task_rec(l_curr_wbs_level,p_budget_version_id,l_project_id);

                     FETCH cur_parent_task_rec BULK COLLECT INTO l_task_id_tbl;

                     IF nvl(l_task_id_tbl.last,0) > 0 THEN -- if parent records found
                        FORALL i in l_task_id_tbl.first..l_task_id_tbl.last
                        INSERT INTO PA_RESOURCE_ASSIGNMENTS
                                 (RESOURCE_ASSIGNMENT_ID
                                 ,BUDGET_VERSION_ID
                                 ,PROJECT_ID
                                 ,TASK_ID
                                 ,RESOURCE_LIST_MEMBER_ID
                                 ,LAST_UPDATE_DATE
                                 ,LAST_UPDATED_BY
                                 ,CREATION_DATE
                                 ,CREATED_BY
                                 ,LAST_UPDATE_LOGIN
                                 ,UNIT_OF_MEASURE
                                 ,TRACK_AS_LABOR_FLAG
                                 ,PROJECT_ASSIGNMENT_ID
                                 ,RESOURCE_ASSIGNMENT_TYPE )
                            VALUES
                                (PA_RESOURCE_ASSIGNMENTS_S.NEXTVAL
                                ,p_budget_version_id
                                ,l_project_id
                                ,l_task_id_tbl(i)
                                ,0                  -- res_list_mem_id is 0 for tasks
                                ,sysdate
                                ,fnd_global.user_id
                                ,sysdate
                                ,fnd_global.user_id
                                ,fnd_global.login_id
                                ,PA_FP_CONSTANTS_PKG.G_UNIT_OF_MEASURE_HOURS -- Modified for #2697999
                                ,'Y'                                         -- Modified for #2697999
                                ,-1
                                ,PA_FP_CONSTANTS_PKG.G_ROLLED_UP)
                        RETURNING resource_assignment_id
                        BULK COLLECT INTO l_ra_id_tbl;

                        pa_debug.g_err_stage := 'inserted ' || sql%rowcount || ' records in res assignments';
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                           pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                        END IF;

                        /* #2697890: Moved the following code for inserting into pa_fp_ra_map_tmp from outside the
                           IF statement to inside the IF statement. The last time this loop is executed for the Top
                           Task record, there is no parent found and hence the above INSERT will not be executed.
                           The PL/SQL table l_ra_id_tbl will be holding the previous value i.e. one task lower than
                           the Top task.
                           If the Insert into the Temp Table is done outside the IF condition irrespective of the
                           above Insert, then the Lower level task record is again inserted into the Temp Table
                           because of which the update statement to update the Parent Assignment for the Top Task
                           level record is executed even for the lower task and the amounts are not updated for
                           the Top Task record because of wrong stamping of the parent assignment id on the lower
                           level task record. */

                        /* Insert the newly generated resource assignment ids into pa_fp_ra_map_tmp table. */

                        IF nvl(l_ra_id_tbl.last,0) > 0  THEN

                           FORALL i in l_ra_id_tbl.first..l_ra_id_tbl.last

                              INSERT INTO pa_fp_ra_map_tmp(resource_assignment_id)
                              VALUES (l_ra_id_tbl(i));

                              pa_debug.g_err_stage := 'inserted ' || sql%rowcount || ' records in map tmp';
                              IF P_PA_DEBUG_MODE = 'Y' THEN
                                 pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                              END IF;

                        END IF;

                     END IF; -- if parent records found

                     l_curr_wbs_level := l_curr_wbs_level - 1;

                     CLOSE cur_parent_task_rec; /* manokuma: during ut review moved this to inside loop */

           END LOOP; /* End of the Repetitive loop. */

        END IF; /* l_planning_level NOT IN (PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_TOP,PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT) */

    END IF; /* l_continue_procesing_flag = 'Y'*/


   /* By now, all parent task level records would have been inserted into PA_RESOURCE_ASSIGNMENTS
      table with parent_assignment_id stamped correctly. PA_RA_MAP temp table will contain only
      top task level records. In case planning level is project or top task and resource list is
      attached then pa_fp_ra_map_tmp table will contain resource/resource group level records with
      task_id as 0.  */

   /* For all the records in pa_fp_ra_map_tmp table we need to insert project level records.
      Check if a Project level record exists for the Budget Version */

    /* Bug 2647043 : This needs to be done only when planning level is not project and resource
       attached is not categorized as in this case the user entered record is project
       level record.
    */

    /* Bug #2597846: The fix mentioned above for the bug #2647043 is being modified.
       The Project Level record should not be created, if the Planning Level is 'Project'
       and the Uncat Flag is 'Y'. In all other cases, the Project Level Record has to be
       created. */

    IF ((l_planning_level = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT)
         AND l_uncat_flag = 'Y' ) THEN

             pa_debug.g_err_stage := 'Not inserting Project Level Record';
	     IF P_PA_DEBUG_MODE = 'Y' THEN
	        pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
	     END IF;

             NULL;

    ELSE

              BEGIN
		 SELECT resource_assignment_id
		   INTO l_proj_ra_id
		   FROM pa_resource_assignments
		  WHERE budget_version_id = p_budget_version_id
		    AND task_id = 0
		    AND resource_list_member_id IN (l_uncat_rlm_id,0);

	      EXCEPTION

	      WHEN NO_DATA_FOUND THEN /* Project Level Record not found. Insert a Project Level record */

		  pa_debug.g_err_stage := 'Inserting Project Level Record';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
                  END IF;

		  INSERT INTO pa_resource_assignments
		       (RESOURCE_ASSIGNMENT_ID
		       ,BUDGET_VERSION_ID
		       ,PROJECT_ID
		       ,TASK_ID
		       ,RESOURCE_LIST_MEMBER_ID
		       ,LAST_UPDATE_DATE
		       ,LAST_UPDATED_BY
		       ,CREATION_DATE
		       ,CREATED_BY
		       ,LAST_UPDATE_LOGIN
		       ,UNIT_OF_MEASURE
		       ,TRACK_AS_LABOR_FLAG
		       ,PROJECT_ASSIGNMENT_ID
		       ,RESOURCE_ASSIGNMENT_TYPE)
		  VALUES
		       (PA_RESOURCE_ASSIGNMENTS_S.NEXTVAL
		       ,p_budget_version_id
		       ,l_project_id
		       ,0
		       ,0                  -- res_list_mem_id is 0 for tasks
		       ,sysdate
		       ,fnd_global.user_id
		       ,sysdate
		       ,fnd_global.user_id
		       ,fnd_global.login_id
		       ,PA_FP_CONSTANTS_PKG.G_UNIT_OF_MEASURE_HOURS -- Modified for #2697999
		       ,'Y'                                         -- Modified for #2697999
		       ,-1
		       ,PA_FP_CONSTANTS_PKG.G_ROLLED_UP)
		       RETURNING resource_assignment_id
		       INTO l_proj_ra_id;

		   pa_debug.g_err_stage := 'inserted ' || sql%rowcount || ' records in res assignments';
		   IF P_PA_DEBUG_MODE = 'Y' THEN
		      pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
		   END IF;

	      END;

	     /* Update all PA_RESOURCE_ASSIGNMENTS for resource_assignment id in pa_fp_ra_map_tmp table
		with parent_assignment_id as that obtained earlier. */

	      pa_debug.g_err_stage := 'updating top records with project level record as parent ';
	      IF P_PA_DEBUG_MODE = 'Y' THEN
	         pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
	      END IF;

	      UPDATE PA_RESOURCE_ASSIGNMENTS
		 SET parent_assignment_id = l_proj_ra_id
	       WHERE resource_assignment_id IN
		     (SELECT resource_assignment_id
			FROM pa_fp_ra_map_tmp)
                 AND project_id = l_project_id                  --bug#2708524
                 AND budget_version_id = p_budget_version_id  ; --bug#2708524

	      pa_debug.g_err_stage := 'updated ' || sql%rowcount || ' records. end of INSERT_MISSING_RES_PARENTS';
	      IF P_PA_DEBUG_MODE = 'Y' THEN
	         pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,pa_debug.g_err_stage,3);
	      END IF;

    END IF; /* planning level = project and resource list is uncategorized */
    pa_debug.reset_err_stack;


EXCEPTION
  WHEN PA_FP_ROLLUP_PKG.Invalid_Arg_Exc THEN
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
      ELSE
             x_msg_count := l_msg_count;
      END IF;
      pa_debug.reset_err_stack;
    RAISE;
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_FP_ROLLUP_PKG'
            ,p_procedure_name => 'Insert_Missing_Res_Parents');
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('INSERT_MISSING_RES_PARENTS: ' || l_module_name,SQLERRM,5);
        END IF;
        pa_debug.reset_err_stack;

        raise FND_API.G_EXC_UNEXPECTED_ERROR;
END INSERT_MISSING_RES_PARENTS;

/***********************************************************************************************
   ROLLUP_RES_ASSIGNMENT_AMOUNTS: This API will take input from PA_FP_ROLLUP_TMP table
   and will update rollup amount for each level in pa_resource_assignments table.
   Before this API is called, INSERT_MISSING_RES_PARENTS would have created parents for all the
   records affected in PA_RESOURCE_ASSIGNMENTS. This API will just rollup the amounts.
   Pre-requisite: For an existing element users should have populated old and new amount fields
                  into the temp table PA_FP_ROLLUP_TMP before calling this API.
                  For a new element (thru excel sheets) users will populate old as null and new
                  as the current value.
***********************************************************************************************/

PROCEDURE ROLLUP_RES_ASSIGNMENT_AMOUNTS(p_budget_version_id IN NUMBER
                                       ,x_return_status    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                       ,x_msg_count        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                       ,x_msg_data         OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

     /* Cursor to Select all data from PA_FP_ROLLUP_TMP table, grouped by resource_assignment_id
        and take sum of amount diffs (use nvl for new and old amounts) in project and project
        functional currencies. */

     CURSOR c_res_amt_diffs IS
     SELECT resource_assignment_id
           ,sum(nvl(project_raw_cost,0) - nvl(old_proj_raw_cost,0))                 project_raw_cost_diff
           ,sum(nvl(project_burdened_cost,0) - nvl(old_proj_burdened_cost,0))       project_burdened_cost_diff
           ,sum(nvl(project_revenue,0) - nvl(old_proj_revenue,0))                   project_revenue_diff
           ,sum(nvl(projfunc_raw_cost,0) - nvl(old_projfunc_raw_cost,0))            projfunc_raw_cost_diff
           ,sum(nvl(projfunc_burdened_cost,0) - nvl(old_projfunc_burdened_cost,0))  projfunc_burdened_cost_diff
           ,sum(nvl(projfunc_revenue,0) - nvl(old_projfunc_revenue,0))              projfunc_revenue_diff
           ,sum(nvl(quantity,0) - nvl(old_quantity,0))                              quantity_diff
       FROM PA_FP_ROLLUP_TMP
      GROUP BY resource_assignment_id;

     l_proj_raw_cost_tbl          l_proj_raw_cost_tbl_typ;
     l_proj_burd_cost_tbl         l_proj_burd_cost_tbl_typ;
     l_proj_revenue_tbl           l_proj_revenue_tbl_typ;
     l_projfunc_raw_cost_tbl      l_projfunc_raw_cost_tbl_typ;
     l_projfunc_burd_cost_tbl     l_projfunc_burd_cost_tbl_typ;
     l_projfunc_revenue_tbl       l_projfunc_revenue_tbl_typ;
     l_quantity_tbl               l_quantity_tbl_typ;
     l_uom_tbl                    l_unit_of_measure_tbl_typ;
     l_ra_id_tbl                  l_ra_id_tbl_typ;
     l_par_id_tbl                 l_par_id_tbl_typ;
     l_upd_user_entered_rec_flg   VARCHAR2(1);
     l_upd_rec                    NUMBER;

     l_msg_count       NUMBER := 0;
     l_data            VARCHAR2(2000);
     l_msg_data        VARCHAR2(2000);
     l_msg_index_out   NUMBER;
     l_return_status   VARCHAR2(2000);
     l_debug_mode      VARCHAR2(30);

     l_index           NUMBER; /* M21-AUG: added for correcting the exit condition for loop */

BEGIN

       -- Set the error stack.
          pa_debug.set_err_stack('PA_FP_ROLLUP_PKG.Rollup_Res_Assignment_Amounts');

       -- Get the Debug mode into local variable and set it to 'Y'if its NULL
          fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
          l_debug_mode := NVL(l_debug_mode, 'Y');

       -- Initialize the return status to success
           x_return_status := FND_API.G_RET_STS_SUCCESS;

           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.set_process('ROLLUP_RES_ASSIGNMENT_AMOUNTS: ' || 'PLSQL','LOG',l_debug_mode);
           END IF;

           pa_debug.g_err_stage := 'In PA_FP_ROLLUP_PKG.Rollup_Res_Assignment_Amounts ';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('ROLLUP_RES_ASSIGNMENT_AMOUNTS: ' || l_module_name,pa_debug.g_err_stage,3);
           END IF;

        /* Check for Budget Version ID not being NULL. */
        IF ( p_budget_version_id IS NULL) THEN
                pa_debug.g_err_stage := 'Err- Budget Version ID cannot be NULL.';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('ROLLUP_RES_ASSIGNMENT_AMOUNTS: ' || l_module_name,pa_debug.g_err_stage,5);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                     p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
                RAISE PA_FP_ROLLUP_PKG.Invalid_Arg_Exc;
        END IF;

     OPEN c_res_amt_diffs;

          /* Bulk collect the amount diffs into PL/SQL tables */

          pa_debug.g_err_stage := 'Bulk collecting the amount diffs into PL/SQL tables';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('ROLLUP_RES_ASSIGNMENT_AMOUNTS: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;
          FETCH c_res_amt_diffs BULK COLLECT INTO
               l_ra_id_tbl
              ,l_proj_raw_cost_tbl
              ,l_proj_burd_cost_tbl
              ,l_proj_revenue_tbl
              ,l_projfunc_raw_cost_tbl
              ,l_projfunc_burd_cost_tbl
              ,l_projfunc_revenue_tbl
              ,l_quantity_tbl;
          CLOSE  c_res_amt_diffs;

          pa_debug.g_err_stage := 'fetched ' || sql%rowcount || ' records';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('ROLLUP_RES_ASSIGNMENT_AMOUNTS: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;

          /* Creating a Loop to keep updating the amount difference on the resource
             assignments and their parent assignments until no parent records are found. */

          l_upd_user_entered_rec_flg := null;

          LOOP
               if (l_upd_user_entered_rec_flg is null) then
                   l_upd_user_entered_rec_flg := 'Y';
               else
                   l_upd_user_entered_rec_flg := 'N';
               end if;

		  pa_debug.g_err_stage := 'l_upd_user_entered_rec_flg = ' || l_upd_user_entered_rec_flg;
		  IF P_PA_DEBUG_MODE = 'Y' THEN
		     pa_debug.write('ROLLUP_RES_ASSIGNMENT_AMOUNTS: ' || l_module_name,pa_debug.g_err_stage,3);
		  END IF;

               IF nvl(l_ra_id_tbl.last,0) >= 1 THEN

                    IF l_upd_user_entered_rec_flg = 'Y' THEN

                      /* The flag l_updating_user_entered_flag is being used to populate the quantity
                         correctly. If we are updating the User_Entered records, then we directly add
                         the difference in quantity to the resource_assignment_quantity.
                                       But if the records are not USER_ENTERED, we have to consider
                         the quantities only if the Unit OF Measure is HOURS. Hence the Update stmt
                         has been split into two depending on the value of the flag. */

                         pa_debug.g_err_stage := 'Updating amounts on pa_resource_assignments for user_entered recs- 1';
                         IF P_PA_DEBUG_MODE = 'Y' THEN
                            pa_debug.write('ROLLUP_RES_ASSIGNMENT_AMOUNTS: ' || l_module_name,pa_debug.g_err_stage,3);
                         END IF;

                         FORALL i in l_ra_id_tbl.first..l_ra_id_tbl.last
                               /* Update pa_resource_assignments for the records found in last step
                                  adding all the amount diffs */
                              UPDATE pa_resource_assignments
                                 SET TOTAL_PROJECT_RAW_COST      = nvl(TOTAL_PROJECT_RAW_COST,0)      + l_proj_raw_cost_tbl(i)
                                    ,TOTAL_PROJECT_BURDENED_COST = nvl(TOTAL_PROJECT_BURDENED_COST,0) + l_proj_burd_cost_tbl(i)
                                    ,TOTAL_PROJECT_REVENUE       = nvl(TOTAL_PROJECT_REVENUE,0)       + l_proj_revenue_tbl(i)
                                    ,TOTAL_PLAN_RAW_COST         = nvl(TOTAL_PLAN_RAW_COST,0)         + l_projfunc_raw_cost_tbl(i)
                                    ,TOTAL_PLAN_BURDENED_COST    = nvl(TOTAL_PLAN_BURDENED_COST,0)    + l_projfunc_burd_cost_tbl(i)
                                    ,TOTAL_PLAN_REVENUE          = nvl(TOTAL_PLAN_REVENUE,0)          + l_projfunc_revenue_tbl(i)
                                    ,TOTAL_PLAN_QUANTITY         = nvl(TOTAL_PLAN_QUANTITY,0)         + l_quantity_tbl(i)
                               WHERE resource_assignment_id = l_ra_id_tbl(i)
                             RETURNING parent_assignment_id, unit_of_measure
                             BULK COLLECT INTO l_par_id_tbl, l_uom_tbl;

                          pa_debug.g_err_stage := 'updated ' || sql%rowcount || ' records';
                          IF P_PA_DEBUG_MODE = 'Y' THEN
                             pa_debug.write('ROLLUP_RES_ASSIGNMENT_AMOUNTS: ' || l_module_name,pa_debug.g_err_stage,3);
                          END IF;

                             -- l_upd_rec := SQL%ROWCOUNT; Not required now.
                    ELSE

                         pa_debug.g_err_stage := 'Updating amounts on pa_resource_assignments for rolled up recs ';
                         IF P_PA_DEBUG_MODE = 'Y' THEN
                            pa_debug.write('ROLLUP_RES_ASSIGNMENT_AMOUNTS: ' || l_module_name,pa_debug.g_err_stage,3);
                         END IF;

                         FORALL i in l_ra_id_tbl.first..l_ra_id_tbl.last
                               /* Update pa_resource_assignments for the records found in last step
                                  adding all the amount diffs */
                              UPDATE pa_resource_assignments
                                 SET TOTAL_PROJECT_RAW_COST      = nvl(TOTAL_PROJECT_RAW_COST,0)      + l_proj_raw_cost_tbl(i)
                                    ,TOTAL_PROJECT_BURDENED_COST = nvl(TOTAL_PROJECT_BURDENED_COST,0) + l_proj_burd_cost_tbl(i)
                                    ,TOTAL_PROJECT_REVENUE       = nvl(TOTAL_PROJECT_REVENUE,0)       + l_proj_revenue_tbl(i)
                                    ,TOTAL_PLAN_RAW_COST         = nvl(TOTAL_PLAN_RAW_COST,0)         + l_projfunc_raw_cost_tbl(i)
                                    ,TOTAL_PLAN_BURDENED_COST    = nvl(TOTAL_PLAN_BURDENED_COST,0)    + l_projfunc_burd_cost_tbl(i)
                                    ,TOTAL_PLAN_REVENUE          = nvl(TOTAL_PLAN_REVENUE,0)          + l_projfunc_revenue_tbl(i)
                                    ,TOTAL_PLAN_QUANTITY         = nvl(TOTAL_PLAN_QUANTITY,0)         + decode(l_uom_tbl(i),
                                                                      PA_FP_CONSTANTS_PKG.G_UNIT_OF_MEASURE_HOURS,l_quantity_tbl(i),0)
                               WHERE resource_assignment_id = l_ra_id_tbl(i)
                             RETURNING parent_assignment_id
                             BULK COLLECT INTO l_par_id_tbl;

                          pa_debug.g_err_stage := 'updated ' || sql%rowcount || ' records';
                          IF P_PA_DEBUG_MODE = 'Y' THEN
                             pa_debug.write('ROLLUP_RES_ASSIGNMENT_AMOUNTS: ' || l_module_name,pa_debug.g_err_stage,3);
                          END IF;

                    END IF;

               END IF;

               /* Put back the parent records from l_par_id_tbl into l_ra_id_tbl so that
               they can be processed again in the loop. */

               pa_debug.g_err_stage := 'Putting the Parent Assignment IDs into the original table';
               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.write('ROLLUP_RES_ASSIGNMENT_AMOUNTS: ' || l_module_name,pa_debug.g_err_stage,3);
               END IF;

               l_ra_id_tbl.delete;

               l_index := 1;  -- initialize to zero.

               IF nvl(l_par_id_tbl.last,0) >= 1 THEN

                       FOR i in l_par_id_tbl.first..l_par_id_tbl.last
                       LOOP
		         pa_debug.g_err_stage := 'i = ' || i || ' l_par_id_tbl.first = ' || l_par_id_tbl.first || ' l_par_id_tbl.last = ' || l_par_id_tbl.last;
		         IF P_PA_DEBUG_MODE = 'Y' THEN
		            pa_debug.write('ROLLUP_RES_ASSIGNMENT_AMOUNTS: ' || l_module_name,pa_debug.g_err_stage,3);
		         END IF;

		         pa_debug.g_err_stage := 'l_par_id_tbl(i) = ' || l_par_id_tbl(i);
		         IF P_PA_DEBUG_MODE = 'Y' THEN
		            pa_debug.write('ROLLUP_RES_ASSIGNMENT_AMOUNTS: ' || l_module_name,pa_debug.g_err_stage,3);
		         END IF;

                         IF l_par_id_tbl(i) IS NOT NULL THEN
                            l_ra_id_tbl(l_index) := l_par_id_tbl(i);

                            -- Bug#2767271
                            -- This re-assignment of table values is required to
                            -- have consistency in the mapping of record in l_ra_id_tbl
                            -- and other amount/quantity tables.For a project having
                            -- tasks at not some wbs level this is required.
                            -- Added the re-assignment of the uom tbl also.

                            l_proj_raw_cost_tbl(l_index)      :=  l_proj_raw_cost_tbl(i)     ;
                            l_proj_burd_cost_tbl(l_index)     :=  l_proj_burd_cost_tbl(i)    ;
                            l_proj_revenue_tbl(l_index)       :=  l_proj_revenue_tbl(i)      ;
                            l_projfunc_raw_cost_tbl(l_index)  :=  l_projfunc_raw_cost_tbl(i) ;
                            l_projfunc_burd_cost_tbl(l_index) :=  l_projfunc_burd_cost_tbl(i);
                            l_projfunc_revenue_tbl(l_index)   :=  l_projfunc_revenue_tbl(i)  ;
                            l_quantity_tbl(l_index)           :=  l_quantity_tbl(i)          ;
                            l_uom_tbl(l_index)                :=  l_uom_tbl(i)               ;


                            l_index := l_index + 1;
                         END IF;

		         pa_debug.g_err_stage := 'l_index = ' || l_index;
		         IF P_PA_DEBUG_MODE = 'Y' THEN
		            pa_debug.write('ROLLUP_RES_ASSIGNMENT_AMOUNTS: ' || l_module_name,pa_debug.g_err_stage,3);
		         END IF;

                       END LOOP;

               END IF;

               IF l_index = 1 THEN /* means no not null parent was found */
		  pa_debug.g_err_stage := 'exiting ' || ' l_index = ' || l_index;
		  IF P_PA_DEBUG_MODE = 'Y' THEN
		     pa_debug.write('ROLLUP_RES_ASSIGNMENT_AMOUNTS: ' || l_module_name,pa_debug.g_err_stage,3);
		  END IF;

                  EXIT;
               END IF;

          END LOOP;

     pa_debug.g_err_stage := 'end of ROLLUP_RES_ASSIGNMENT_AMOUNTS' ;
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write('ROLLUP_RES_ASSIGNMENT_AMOUNTS: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;
     pa_debug.reset_err_stack;

EXCEPTION
  WHEN PA_FP_ROLLUP_PKG.Invalid_Arg_Exc THEN
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
      ELSE
             x_msg_count := l_msg_count;
      END IF;
      pa_debug.reset_err_stack;
    RAISE;
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_FP_ROLLUP_PKG'
            ,p_procedure_name => 'Rollup_Res_Assignment_Amounts');
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('ROLLUP_RES_ASSIGNMENT_AMOUNTS: ' || l_module_name,SQLERRM,5);
        END IF;
        pa_debug.reset_err_stack;

        raise FND_API.G_EXC_UNEXPECTED_ERROR;
END ROLLUP_RES_ASSIGNMENT_AMOUNTS;

/***********************************************************************************************
   INSERT_MISSING_PARENT_DENORM: This API will only insert the parent level records for all the
   records for which rollup API is called. It expects input in pa_fp_ra_map_tmp table. This API
   creates parent record for each currency type and amount type available for child level
   records.
   Prerequisite: The USER_ENTERED level records have to be updated with all amounts and
                 currencies.
                 Records have to be inserted into pa_fp_ra_map_tmp table. This API will be called
                 only if there are some records in pa_fp_ra_map_tmp table.
***********************************************************************************************/

PROCEDURE INSERT_MISSING_PARENT_DENORM(p_budget_version_id IN NUMBER
                                       ,x_return_status    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                       ,x_msg_count        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                       ,x_msg_data         OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

        l_msg_count       NUMBER := 0;
        l_data            VARCHAR2(2000);
        l_msg_data        VARCHAR2(2000);
        l_msg_index_out   NUMBER;
        l_return_status   VARCHAR2(2000);
        l_debug_mode      VARCHAR2(30);


        l_ra_id_tbl                   l_ra_id_tbl_typ;
        l_object_id_tbl               l_object_id_tbl_typ;
        l_object_type_code_tbl        l_obj_typ_code_tbl_typ;
        l_amount_type_code_tbl        l_amount_type_code_tbl_typ;
        l_amount_subtype_code_tbl     l_amount_subtype_code_tbl_typ;
        l_amount_type_id_tbl          l_amount_type_id_tbl_typ;
        l_amount_subtype_id_tbl       l_amount_subtype_id_tbl_typ;
        l_currency_type_tbl           l_currency_type_tbl_typ;
        l_currency_code_tbl           l_currency_code_tbl_typ;


        l_uncat_rlm_id              pa_resource_assignments.RESOURCE_LIST_MEMBER_ID%TYPE;
        l_resource_list_id          pa_resource_lists.RESOURCE_LIST_ID%TYPE;
        l_uncat_flag                pa_resource_lists.UNCATEGORIZED_FLAG%TYPE;
        l_rl_group_type_id          pa_resource_lists.GROUP_RESOURCE_TYPE_ID%TYPE;
        l_project_id                pa_projects.project_id%TYPE;
        l_planning_level            pa_proj_fp_options.ALL_FIN_PLAN_LEVEL_CODE%TYPE;
        l_proj_currency_code        pa_projects_all.project_currency_code%TYPE;

        l_period_profile_id         pa_budget_versions.period_profile_id%TYPE;

        l_curr_rollup_level  NUMBER := 0;

        L_INSERTING_RES_GROUP_LEVEL       boolean := false;
        L_INSERTING_TASK_LEVEL            boolean := false;
        L_INSERTING_PARENT_TASK_LEVEL     boolean := false;

        CURSOR pd_denorm_par_cur(l_proj_currency_code IN VARCHAR2) IS
        SELECT distinct pra.parent_assignment_id,
               /* two resource assignment could share the same parent hence distinct */
               pra.parent_assignment_id, -- #2723515: object_id should be the ra id
               ppd.object_type_code,
               ppd.amount_type_code,
               ppd.amount_subtype_code,
               ppd.amount_type_id,
               ppd.amount_subtype_id,
               ppd.currency_type,
               decode(ppd.amount_subtype_code,PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_QUANTITY,
                      l_proj_currency_code,ppd.currency_code) --#2801522:For Qty, store Proj Curr Code
          FROM pa_resource_assignments pra,
               pa_proj_periods_denorm ppd
         WHERE ppd.budget_version_id = p_budget_version_id -- #2839138
           AND pra.resource_assignment_id = ppd.resource_assignment_id
           AND ppd.object_type_code = PA_FP_CONSTANTS_PKG.G_OBJECT_TYPE_RES_ASSIGNMENT -- #2839138
           AND ppd.object_id = ppd.resource_assignment_id                              -- #2839138
           AND ((ppd.currency_type <> PA_FP_CONSTANTS_PKG.G_CURRENCY_TYPE_TRANSACTION) OR
                  (ppd.amount_type_code = PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_QUANTITY AND
                      ppd.currency_type = PA_FP_CONSTANTS_PKG.G_CURRENCY_TYPE_TRANSACTION))
           AND pra.resource_assignment_id in
               (SELECT resource_assignment_id
                  FROM pa_fp_ra_map_tmp)
           AND pra.parent_assignment_id IS NOT NULL;

BEGIN


       -- Set the error stack.
          pa_debug.set_err_stack('PA_FP_ROLLUP_PKG.Insert_Missing_Parent_Denorm');

       -- Get the Debug mode into local variable and set it to 'Y'if its NULL
          fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
          l_debug_mode := NVL(l_debug_mode, 'Y');

       -- Initialize the return status to success
           x_return_status := FND_API.G_RET_STS_SUCCESS;

           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.set_process('INSERT_MISSING_PARENT_DENORM: ' || 'PLSQL','LOG',l_debug_mode);
           END IF;

           pa_debug.g_err_stage := 'In PA_FP_ROLLUP_PKG.Insert_Missing_Parent_Denorm ';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('INSERT_MISSING_PARENT_DENORM: ' || l_module_name,pa_debug.g_err_stage,3);
           END IF;


        /* Check for Budget Version ID not being NULL. */
        IF ( p_budget_version_id IS NULL) THEN
                pa_debug.g_err_stage := 'Err- Budget Version ID cannot be NULL.';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('INSERT_MISSING_PARENT_DENORM: ' || l_module_name,pa_debug.g_err_stage,5);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                     p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
                RAISE PA_FP_ROLLUP_PKG.Invalid_Arg_Exc;
        END IF;

        populate_local_vars(p_budget_version_id    => p_budget_version_id,
                            x_project_id           => l_project_id,
                            x_resource_list_id     => l_resource_list_id,
                            x_uncat_flag           => l_uncat_flag,
                            x_uncat_rlm_id         => l_uncat_rlm_id,
                            x_rl_group_type_id     => l_rl_group_type_id,
                            x_planning_level       => l_planning_level,
                            x_return_status        => x_return_status,
                            x_msg_count            => x_msg_count,
                            x_msg_data             => x_msg_data);


        SELECT period_profile_id
          INTO l_period_profile_id
          FROM pa_budget_versions
         WHERE budget_version_id = p_budget_version_id;

        pa_debug.g_err_stage := 'period profile id = ' || l_period_profile_id ;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('INSERT_MISSING_PARENT_DENORM: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        /* #2801522: Getting the project currency code for storing in the 'QAUNTITY' record. */

        SELECT project_currency_code
          INTO l_proj_currency_code
          FROM pa_projects_all
         WHERE project_id = l_project_id;

        /* set total number of levels in rollup.
           Total number of level = number of levels in WBS + resource group (in case resource list is grouped)
                                   + resource (in case resource list attached) + 1 (project level)
        */

        IF l_planning_level = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT THEN
             l_curr_rollup_level := 0;
        ELSIF l_planning_level = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_TOP THEN
             l_curr_rollup_level := 1;
        ELSE /* planning level is lowest task or top and lowest */
          select max(wbs_level)
            into l_curr_rollup_level
            from pa_tasks
           where project_id = l_project_id;
        END IF;

        IF l_uncat_flag <> 'Y' THEN /* resource list is attached */
           l_curr_rollup_level := l_curr_rollup_level + 1;
           IF l_rl_group_type_id <> 0 THEN /* if resource attached is grouped */
               L_INSERTING_RES_GROUP_LEVEL := true;
               l_curr_rollup_level := l_curr_rollup_level + 1;
           ELSE
               L_INSERTING_TASK_LEVEL := true;
           END IF;
        ELSE
            L_INSERTING_PARENT_TASK_LEVEL := true;
        END IF;

        pa_debug.g_err_stage := 'Inserting Parent Records into pa_proj_periods_denorm in a loop';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('INSERT_MISSING_PARENT_DENORM: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        LOOP
        EXIT WHEN l_curr_rollup_level = 0;

        /* Insert parents for the records in pa_fp_ra_map_tmp table. As of now the amounts are
           inserted as NULL. For each parent we need to insert records for each currency type
           and amount type for which their child exists. */
          INSERT_PARENT_REC_TMP(p_budget_version_id             => p_budget_version_id
                               ,PX_INSERTING_RES_GROUP_LEVEL    => L_INSERTING_RES_GROUP_LEVEL
                               ,PX_INSERTING_TASK_LEVEL         => L_INSERTING_TASK_LEVEL
                               ,PX_INSERTING_PARENT_TASK_LEVEL  => L_INSERTING_PARENT_TASK_LEVEL
                               ,p_curr_rollup_level             => l_curr_rollup_level);

          OPEN pd_denorm_par_cur(l_proj_currency_code);

          FETCH pd_denorm_par_cur BULK COLLECT INTO
                 l_ra_id_tbl
                ,l_object_id_tbl
                ,l_object_type_code_tbl
                ,l_amount_type_code_tbl
                ,l_amount_subtype_code_tbl
                ,l_amount_type_id_tbl
                ,l_amount_subtype_id_tbl
                ,l_currency_type_tbl
                ,l_currency_code_tbl;

          CLOSE pd_denorm_par_cur;

          IF nvl(l_ra_id_tbl.last,0) > 0 THEN

                  FORALL i in l_ra_id_tbl.first..l_ra_id_tbl.last
                  INSERT INTO pa_proj_periods_denorm
                         (RESOURCE_ASSIGNMENT_ID
                         ,PROJECT_ID
                         ,BUDGET_VERSION_ID
                         ,PARENT_ASSIGNMENT_ID
                         ,OBJECT_ID
                         ,OBJECT_TYPE_CODE
                         ,PERIOD_PROFILE_ID
                         ,AMOUNT_TYPE_CODE
                         ,AMOUNT_SUBTYPE_CODE
                         ,AMOUNT_TYPE_ID
                         ,AMOUNT_SUBTYPE_ID
                         ,CURRENCY_TYPE
                         ,CURRENCY_CODE
                         ,LAST_UPDATE_DATE
                         ,LAST_UPDATED_BY
                         ,CREATION_DATE
                         ,CREATED_BY
                         ,LAST_UPDATE_LOGIN)
                    VALUES
                         (l_ra_id_tbl(i)
                         ,l_project_id
                         ,p_budget_version_id
                         ,null
                         ,l_object_id_tbl(i)
                         ,l_object_type_code_tbl(i)
                         ,l_period_profile_id
                         ,l_amount_type_code_tbl(i)
                         ,l_amount_subtype_code_tbl(i)
                         ,l_amount_type_id_tbl(i)
                         ,l_amount_subtype_id_tbl(i)
                         ,l_currency_type_tbl(i)
                         ,l_currency_code_tbl(i)
                         ,sysdate
                         ,fnd_global.user_id
                         ,sysdate
                         ,fnd_global.user_id
                         ,fnd_global.login_id);

                  pa_debug.g_err_stage := 'Inserted ' || sql%rowcount || ' records into denorm table';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write('INSERT_MISSING_PARENT_DENORM: ' || l_module_name,pa_debug.g_err_stage,3);
                  END IF;
          END IF;
          pa_debug.g_err_stage := 'current rollup level = ' || l_curr_rollup_level;
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('INSERT_MISSING_PARENT_DENORM: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;

          l_curr_rollup_level := l_curr_rollup_level - 1;
    END LOOP;

    /* Update the Parent Assignment IDs of the records that have been entered. */
    /* M21-AUG moved this out of the loop */
    pa_debug.g_err_stage := 'Calling UPDATE_DENORM_PARENT_ASSIGN_ID';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('INSERT_MISSING_PARENT_DENORM: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;
    UPDATE_DENORM_PARENT_ASSIGN_ID(p_budget_version_id =>     p_budget_version_id
                                  ,x_return_status     =>     x_return_status
                                  ,x_msg_count         =>     x_msg_count
                                  ,x_msg_data          =>     x_msg_data);

    pa_debug.g_err_stage := 'end of INSERT_MISSING_PARENT_DENORM';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('INSERT_MISSING_PARENT_DENORM: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    pa_debug.reset_err_stack;

EXCEPTION
  WHEN PA_FP_ROLLUP_PKG.Invalid_Arg_Exc THEN
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
      ELSE
             x_msg_count := l_msg_count;
      END IF;
      pa_debug.reset_err_stack;
    RAISE;
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_FP_ROLLUP_PKG'
            ,p_procedure_name => 'Insert_Missing_Parent_Denorm');
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('INSERT_MISSING_PARENT_DENORM: ' || l_module_name,'sqlerrm = ' || SQLERRM,5);
        END IF;
        pa_debug.reset_err_stack;

        raise FND_API.G_EXC_UNEXPECTED_ERROR;
END INSERT_MISSING_PARENT_DENORM;


/***********************************************************************************************
   ROLLUP_DENORM_AMOUNTS: This API assumes that all parent level records for the updated records
   are available in denorm table. This API takes sum of amounts at child level records and
   updates the amounts on the parent records.
***********************************************************************************************/

PROCEDURE ROLLUP_DENORM_AMOUNTS(p_budget_version_id IN NUMBER
                               ,x_return_status    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                               ,x_msg_count        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                               ,x_msg_data         OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

        l_first_level VARCHAR2(1) := NULL;
        l_parent_ra_id_tbl l_par_id_tbl_typ;

        l_msg_count       NUMBER := 0;
        l_data            VARCHAR2(2000);
        l_msg_data        VARCHAR2(2000);
        l_msg_index_out   NUMBER;
        l_return_status   VARCHAR2(2000);
        l_debug_mode      VARCHAR2(30);
        l_upd_rec         NUMBER;

BEGIN

       -- Set the error stack.
          pa_debug.set_err_stack('PA_FP_ROLLUP_PKG.Rollup_Denorm_Amounts');

       -- Get the Debug mode into local variable and set it to 'Y'if its NULL
          fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
          l_debug_mode := NVL(l_debug_mode, 'Y');

       -- Initialize the return status to success
           x_return_status := FND_API.G_RET_STS_SUCCESS;

           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.set_process('ROLLUP_DENORM_AMOUNTS: ' || 'PLSQL','LOG',l_debug_mode);
           END IF;

           pa_debug.g_err_stage := 'In PA_FP_ROLLUP_PKG.Rollup_Denorm_Amounts ';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('ROLLUP_DENORM_AMOUNTS: ' || l_module_name,pa_debug.g_err_stage,3);
           END IF;


        /* Check for Budget Version ID not being NULL. */
        IF ( p_budget_version_id IS NULL) THEN
                pa_debug.g_err_stage := 'Err- Budget Version ID cannot be NULL.';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('ROLLUP_DENORM_AMOUNTS: ' || l_module_name,pa_debug.g_err_stage,5);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                     p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
                RAISE PA_FP_ROLLUP_PKG.Invalid_Arg_Exc;
        END IF;

     /* Inserting the parent level records that need to be updated into pa_fp_ra_map_tmp
        from Resource_Assignments and those that are present in the pa_fp_rollup_tmp
        (i.e. records that have got updated).*/

          DELETE from pa_fp_ra_map_tmp;

          pa_debug.g_err_stage := 'inserting into map tmp table';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('ROLLUP_DENORM_AMOUNTS: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;

          INSERT into pa_fp_ra_map_tmp(resource_assignment_id)
                (SELECT DISTINCT tmp.parent_assignment_id
                   FROM pa_fp_rollup_tmp tmp);

          pa_debug.g_err_stage := 'inserted ' || sql%rowcount || ' records';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('ROLLUP_DENORM_AMOUNTS: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;

     /* For the first level of records i.e. for the first level parents, if the amount type code
        is QUANTITY, then the uom is that in the table else it is HOURS.
        But always populate unit_of_measure as HOURS for second level of records. The flag
        l_first_level is being used for this purpose. */

          l_first_level := 'Y';

          pa_debug.g_err_stage := 'Updating the amounts in pa_proj_periods_denorm for 1st level';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('ROLLUP_DENORM_AMOUNTS: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;
          LOOP
               IF l_first_level = 'Y' THEN

                  pa_debug.g_err_stage := 'updating period denorm for first level';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write('ROLLUP_DENORM_AMOUNTS: ' || l_module_name,pa_debug.g_err_stage,3);
                  END IF;

                    UPDATE PA_PROJ_PERIODS_DENORM ppd1
                       SET (preceding_periods_amount
                           ,succeeding_periods_amount
                           ,prior_period_amount
                           ,period_amount1
                           ,period_amount2
                           ,period_amount3
                           ,period_amount4
                           ,period_amount5
                           ,period_amount6
                           ,period_amount7
                           ,period_amount8
                           ,period_amount9
                           ,period_amount10
                           ,period_amount11
                           ,period_amount12
                           ,period_amount13
                           ,period_amount14
                           ,period_amount15
                           ,period_amount16
                           ,period_amount17
                           ,period_amount18
                           ,period_amount19
                           ,period_amount20
                           ,period_amount21
                           ,period_amount22
                           ,period_amount23
                           ,period_amount24
                           ,period_amount25
                           ,period_amount26
                           ,period_amount27
                           ,period_amount28
                           ,period_amount29
                           ,period_amount30
                           ,period_amount31
                           ,period_amount32
                           ,period_amount33
                           ,period_amount34
                           ,period_amount35
                           ,period_amount36
                           ,period_amount37
                           ,period_amount38
                           ,period_amount39
                           ,period_amount40
                           ,period_amount41
                           ,period_amount42
                           ,period_amount43
                           ,period_amount44
                           ,period_amount45
                           ,period_amount46
                           ,period_amount47
                           ,period_amount48
                           ,period_amount49
                           ,period_amount50
                           ,period_amount51
                           ,period_amount52) =
                           (SELECT sum(nvl(preceding_periods_amount,0))
                                  ,sum(nvl(succeeding_periods_amount,0))
                                  ,sum(nvl(prior_period_amount,0))
                                  ,sum(nvl(period_amount1,0))
                                  ,sum(nvl(period_amount2,0))
                                  ,sum(nvl(period_amount3,0))
                                  ,sum(nvl(period_amount4,0))
                                  ,sum(nvl(period_amount5,0))
                                  ,sum(nvl(period_amount6,0))
                                  ,sum(nvl(period_amount7,0))
                                  ,sum(nvl(period_amount8,0))
                                  ,sum(nvl(period_amount9,0))
                                  ,sum(nvl(period_amount10,0))
                                  ,sum(nvl(period_amount11,0))
                                  ,sum(nvl(period_amount12,0))
                                  ,sum(nvl(period_amount13,0))
                                  ,sum(nvl(period_amount14,0))
                                  ,sum(nvl(period_amount15,0))
                                  ,sum(nvl(period_amount16,0))
                                  ,sum(nvl(period_amount17,0))
                                  ,sum(nvl(period_amount18,0))
                                  ,sum(nvl(period_amount19,0))
                                  ,sum(nvl(period_amount20,0))
                                  ,sum(nvl(period_amount21,0))
                                  ,sum(nvl(period_amount22,0))
                                  ,sum(nvl(period_amount23,0))
                                  ,sum(nvl(period_amount24,0))
                                  ,sum(nvl(period_amount25,0))
                                  ,sum(nvl(period_amount26,0))
                                  ,sum(nvl(period_amount27,0))
                                  ,sum(nvl(period_amount28,0))
                                  ,sum(nvl(period_amount29,0))
                                  ,sum(nvl(period_amount30,0))
                                  ,sum(nvl(period_amount31,0))
                                  ,sum(nvl(period_amount32,0))
                                  ,sum(nvl(period_amount33,0))
                                  ,sum(nvl(period_amount34,0))
                                  ,sum(nvl(period_amount35,0))
                                  ,sum(nvl(period_amount36,0))
                                  ,sum(nvl(period_amount37,0))
                                  ,sum(nvl(period_amount38,0))
                                  ,sum(nvl(period_amount39,0))
                                  ,sum(nvl(period_amount40,0))
                                  ,sum(nvl(period_amount41,0))
                                  ,sum(nvl(period_amount42,0))
                                  ,sum(nvl(period_amount43,0))
                                  ,sum(nvl(period_amount44,0))
                                  ,sum(nvl(period_amount45,0))
                                  ,sum(nvl(period_amount46,0))
                                  ,sum(nvl(period_amount47,0))
                                  ,sum(nvl(period_amount48,0))
                                  ,sum(nvl(period_amount49,0))
                                  ,sum(nvl(period_amount50,0))
                                  ,sum(nvl(period_amount51,0))
                                  ,sum(nvl(period_amount52,0))
                              FROM PA_PROJ_PERIODS_DENORM ppd2, pa_resource_assignments pra
                             WHERE ppd1.resource_assignment_id = ppd2.parent_assignment_id
                             AND ppd1.currency_type = ppd2.currency_type
                             AND ppd1.currency_code = decode(ppd2.amount_subtype_code,PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_QUANTITY,
                                                             ppd1.currency_code,ppd2.currency_code) --#2801522:Dont check curr code for Qty
                             AND ppd1.amount_type_id  = ppd2.amount_type_id
                             AND ppd1.amount_subtype_id  = ppd2.amount_subtype_id
                             AND decode(ppd2.amount_type_code,PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_QUANTITY,
                                        pra.unit_of_measure,PA_FP_CONSTANTS_PKG.G_UNIT_OF_MEASURE_HOURS) =
                                                PA_FP_CONSTANTS_PKG.G_UNIT_OF_MEASURE_HOURS
                             AND ppd2.resource_assignment_id = pra.resource_assignment_id  -- Modified for 2801522
                             )
                      WHERE ppd1.budget_version_id = p_budget_version_id -- #2839138
                        AND ppd1.resource_assignment_id in
                    (SELECT tmp.resource_assignment_id from pa_fp_ra_map_tmp tmp)
                    RETURNING parent_assignment_id
                    BULK COLLECT INTO l_parent_ra_id_tbl;

                    pa_debug.g_err_stage := 'updated ' || sql%rowcount || ' records';
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.write('ROLLUP_DENORM_AMOUNTS: ' || l_module_name,pa_debug.g_err_stage,3);
                    END IF;

                    l_first_level := 'N';
                    l_upd_rec := nvl(l_parent_ra_id_tbl.last,0);

               ELSE

                   pa_debug.g_err_stage := 'Updating the amounts in pa_proj_periods_denorm for 2nd level';
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('ROLLUP_DENORM_AMOUNTS: ' || l_module_name,pa_debug.g_err_stage,3);
                   END IF;

                    UPDATE PA_PROJ_PERIODS_DENORM ppd1
                       SET (preceding_periods_amount
                           ,succeeding_periods_amount
                           ,prior_period_amount
                           ,period_amount1
                           ,period_amount2
                           ,period_amount3
                           ,period_amount4
                           ,period_amount5
                           ,period_amount6
                           ,period_amount7
                           ,period_amount8
                           ,period_amount9
                           ,period_amount10
                           ,period_amount11
                           ,period_amount12
                           ,period_amount13
                           ,period_amount14
                           ,period_amount15
                           ,period_amount16
                           ,period_amount17
                           ,period_amount18
                           ,period_amount19
                           ,period_amount20
                           ,period_amount21
                           ,period_amount22
                           ,period_amount23
                           ,period_amount24
                           ,period_amount25
                           ,period_amount26
                           ,period_amount27
                           ,period_amount28
                           ,period_amount29
                           ,period_amount30
                           ,period_amount31
                           ,period_amount32
                           ,period_amount33
                           ,period_amount34
                           ,period_amount35
                           ,period_amount36
                           ,period_amount37
                           ,period_amount38
                           ,period_amount39
                           ,period_amount40
                           ,period_amount41
                           ,period_amount42
                           ,period_amount43
                           ,period_amount44
                           ,period_amount45
                           ,period_amount46
                           ,period_amount47
                           ,period_amount48
                           ,period_amount49
                           ,period_amount50
                           ,period_amount51
                           ,period_amount52) =
                           (SELECT sum(nvl(preceding_periods_amount,0))
                                  ,sum(nvl(succeeding_periods_amount,0))
                                  ,sum(nvl(prior_period_amount,0))
                                  ,sum(nvl(period_amount1,0))
                                  ,sum(nvl(period_amount2,0))
                                  ,sum(nvl(period_amount3,0))
                                  ,sum(nvl(period_amount4,0))
                                  ,sum(nvl(period_amount5,0))
                                  ,sum(nvl(period_amount6,0))
                                  ,sum(nvl(period_amount7,0))
                                  ,sum(nvl(period_amount8,0))
                                  ,sum(nvl(period_amount9,0))
                                  ,sum(nvl(period_amount10,0))
                                  ,sum(nvl(period_amount11,0))
                                  ,sum(nvl(period_amount12,0))
                                  ,sum(nvl(period_amount13,0))
                                  ,sum(nvl(period_amount14,0))
                                  ,sum(nvl(period_amount15,0))
                                  ,sum(nvl(period_amount16,0))
                                  ,sum(nvl(period_amount17,0))
                                  ,sum(nvl(period_amount18,0))
                                  ,sum(nvl(period_amount19,0))
                                  ,sum(nvl(period_amount20,0))
                                  ,sum(nvl(period_amount21,0))
                                  ,sum(nvl(period_amount22,0))
                                  ,sum(nvl(period_amount23,0))
                                  ,sum(nvl(period_amount24,0))
                                  ,sum(nvl(period_amount25,0))
                                  ,sum(nvl(period_amount26,0))
                                  ,sum(nvl(period_amount27,0))
                                  ,sum(nvl(period_amount28,0))
                                  ,sum(nvl(period_amount29,0))
                                  ,sum(nvl(period_amount30,0))
                                  ,sum(nvl(period_amount31,0))
                                  ,sum(nvl(period_amount32,0))
                                  ,sum(nvl(period_amount33,0))
                                  ,sum(nvl(period_amount34,0))
                                  ,sum(nvl(period_amount35,0))
                                  ,sum(nvl(period_amount36,0))
                                  ,sum(nvl(period_amount37,0))
                                  ,sum(nvl(period_amount38,0))
                                  ,sum(nvl(period_amount39,0))
                                  ,sum(nvl(period_amount40,0))
                                  ,sum(nvl(period_amount41,0))
                                  ,sum(nvl(period_amount42,0))
                                  ,sum(nvl(period_amount43,0))
                                  ,sum(nvl(period_amount44,0))
                                  ,sum(nvl(period_amount45,0))
                                  ,sum(nvl(period_amount46,0))
                                  ,sum(nvl(period_amount47,0))
                                  ,sum(nvl(period_amount48,0))
                                  ,sum(nvl(period_amount49,0))
                                  ,sum(nvl(period_amount50,0))
                                  ,sum(nvl(period_amount51,0))
                                  ,sum(nvl(period_amount52,0))
                              FROM PA_PROJ_PERIODS_DENORM ppd2
                             WHERE ppd1.resource_assignment_id = ppd2.parent_assignment_id
                             AND ppd1.currency_type = ppd2.currency_type
                             AND ppd1.currency_code = decode(ppd2.amount_subtype_code,PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_QUANTITY,
                                                             ppd1.currency_code,ppd2.currency_code) --#2801522:Dont check curr code for Qty
                             AND ppd1.amount_type_id  = ppd2.amount_type_id
                             AND ppd1.amount_subtype_id  = ppd2.amount_subtype_id
                             )
                      WHERE ppd1.budget_version_id = p_budget_version_id -- #2839138
                        AND ppd1.resource_assignment_id in
                    (SELECT tmp.resource_assignment_id from pa_fp_ra_map_tmp tmp)
                    RETURNING parent_assignment_id
                    BULK COLLECT INTO l_parent_ra_id_tbl;

                    pa_debug.g_err_stage := 'updated ' || sql%rowcount || ' records';
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.write('ROLLUP_DENORM_AMOUNTS: ' || l_module_name,pa_debug.g_err_stage,3);
                    END IF;

                    l_upd_rec := nvl(l_parent_ra_id_tbl.last,0);

               END IF;

               EXIT WHEN l_upd_rec = 0;

               DELETE FROM pa_fp_ra_map_tmp;

               IF nvl(l_parent_ra_id_tbl.last,0) >= 1 THEN

                    FORALL i IN l_parent_ra_id_tbl.first..l_parent_ra_id_tbl.last

                           INSERT INTO pa_fp_ra_map_tmp
                                       (RESOURCE_ASSIGNMENT_ID)
                           VALUES (l_parent_ra_id_tbl(i));

                    pa_debug.g_err_stage := 'inserted ' || sql%rowcount || ' records in map tmp';
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.write('ROLLUP_DENORM_AMOUNTS: ' || l_module_name,pa_debug.g_err_stage,3);
                    END IF;

               END IF;

          END LOOP;

          pa_debug.reset_err_stack;

EXCEPTION
  WHEN PA_FP_ROLLUP_PKG.Invalid_Arg_Exc THEN
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
      ELSE
             x_msg_count := l_msg_count;
      END IF;
      pa_debug.reset_err_stack;
    RAISE;
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_FP_ROLLUP_PKG'
            ,p_procedure_name => 'Rollup_Denorm_Amounts');
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('ROLLUP_DENORM_AMOUNTS: ' || l_module_name,SQLERRM,5);
        END IF;
        pa_debug.reset_err_stack;

        raise FND_API.G_EXC_UNEXPECTED_ERROR;
END ROLLUP_DENORM_AMOUNTS;

/***********************************************************************************************
   DELETE_ELEMENT: Given a resource assignment id and txn currency code this API will delete the
   element from budget lines table and also from resource assignments table. This API will also
   do the necessary so that amounts get rolled up to higher level
***********************************************************************************************/

PROCEDURE DELETE_ELEMENT(p_budget_version_id           IN NUMBER
                        ,p_resource_assignment_id      IN NUMBER
                        ,p_txn_currency_code           IN VARCHAR2
                        ,x_return_status              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                        ,x_msg_count                  OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                        ,x_msg_data                   OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895


        l_uncat_rlm_id              pa_resource_assignments.RESOURCE_LIST_MEMBER_ID%TYPE;
        l_resource_list_id          pa_resource_lists.RESOURCE_LIST_ID%TYPE;
        l_uncat_flag                pa_resource_lists.UNCATEGORIZED_FLAG%TYPE;
        l_rl_group_type_id          pa_resource_lists.GROUP_RESOURCE_TYPE_ID%TYPE;
        l_project_id                pa_projects.project_id%TYPE;
        l_planning_level            pa_proj_fp_options.ALL_FIN_PLAN_LEVEL_CODE%TYPE;

        l_parent_assignment_id      pa_resource_assignments.PARENT_ASSIGNMENT_ID%TYPE;
        l_rec_exists                VARCHAR2(1);
        l_child_res_count           NUMBER;
        l_proj_raw_cost             pa_resource_assignments.TOTAL_PROJECT_RAW_COST%TYPE;
        l_proj_burdened_cost        pa_resource_assignments.TOTAL_PROJECT_BURDENED_COST%TYPE;
        l_proj_revenue              pa_resource_assignments.TOTAL_PROJECT_REVENUE%TYPE;
        l_projfunc_raw_cost         pa_resource_assignments.TOTAL_PLAN_RAW_COST%TYPE;
        l_projfunc_burdened_cost    pa_resource_assignments.TOTAL_PLAN_BURDENED_COST%TYPE;
        l_projfunc_revenue          pa_resource_assignments.TOTAL_PLAN_REVENUE%TYPE;
        l_quantity                  pa_resource_assignments.TOTAL_PLAN_QUANTITY%TYPE;
        l_records_deleted           NUMBER;

        l_msg_count       NUMBER := 0;
        l_data            VARCHAR2(2000);
        l_msg_data        VARCHAR2(2000);
        l_msg_index_out   NUMBER;
        l_return_status   VARCHAR2(2000);
        l_debug_mode      VARCHAR2(30);

        l_task_id                   pa_tasks.task_id%type;
        l_resource_list_member_id   pa_resource_list_members.resource_list_member_id%type;

        --Bug # 2615807.
         l_project_currency_code     pa_projects_all.project_currency_code%type;
        l_projfunc_currency_code    pa_projects_all.projfunc_currency_code%type;


        l_resource_assignment_id_tbl SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type();
        l_period_name_tbl            SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type();
        l_start_date_tbl             SYSTEM.pa_date_tbl_type          DEFAULT SYSTEM.pa_date_tbl_type();
        l_end_date_tbl               SYSTEM.pa_date_tbl_type          DEFAULT SYSTEM.pa_date_tbl_type();
        l_txn_currency_code_tbl      SYSTEM.pa_varchar2_15_tbl_type   DEFAULT SYSTEM.pa_varchar2_15_tbl_type();
        l_txn_raw_cost_tbl           SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type();
        l_txn_burdened_cost_tbl      SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type();
        l_txn_revenue_tbl            SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type();
        l_project_raw_cost_tbl       SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type();
        l_project_burdened_cost_tbl  SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type();
        l_project_revenue_tbl        SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type();
        l_raw_cost_tbl               SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type();
        l_burdened_cost_tbl          SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type();
        l_revenue_tbl                SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type();
        l_cost_rejection_code_tbl    SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type();
        l_revenue_rejection_code_tbl SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type();
        l_burden_rejection_code_tbl  SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type();
        l_other_rejection_code_tbl   SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type();
        l_pc_cur_conv_rej_code_tbl   SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type();
        l_pfc_cur_conv_rej_code_tbl  SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type();
        l_quantity_tbl               SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type();
        l_rbs_element_id_tbl         SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type();
        l_task_id_tbl                SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type();
        l_res_class_code_tbl         SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type();
        l_rate_based_flag_tbl        SYSTEM.pa_varchar2_1_tbl_type    DEFAULT SYSTEM.pa_varchar2_1_tbl_type();

BEGIN

       -- Set the error stack.
          pa_debug.set_err_stack('PA_FP_ROLLUP_PKG.Delete_Element');

       -- Get the Debug mode into local variable and set it to 'Y'if its NULL
          fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
          l_debug_mode := NVL(l_debug_mode, 'Y');

       -- Initialize the return status to success
           x_return_status := FND_API.G_RET_STS_SUCCESS;

           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.set_process('DELETE_ELEMENT: ' || 'PLSQL','LOG',l_debug_mode);
           END IF;

           pa_debug.g_err_stage := 'In PA_FP_ROLLUP_PKG.Delete_Element ';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,3);
           END IF;


        /* Check for Budget Version ID not being NULL. */
        IF ( p_budget_version_id IS NULL) THEN
                pa_debug.g_err_stage := 'Err- Budget Version ID cannot be NULL.';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,5);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                     p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
                RAISE PA_FP_ROLLUP_PKG.Invalid_Arg_Exc;
        END IF;

        /* Check for Resource Assignment ID not being NULL. */
        IF ( p_resource_assignment_id IS NULL) THEN
                pa_debug.g_err_stage := 'Err- Resource Assignment ID cannot be NULL.';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,5);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                     p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
                RAISE PA_FP_ROLLUP_PKG.Invalid_Arg_Exc;
        END IF;

        /* Populate the local variables. */

        pa_debug.g_err_stage := 'calling populate_local_vars';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        populate_local_vars(p_budget_version_id    => p_budget_version_id,
                            x_project_id           => l_project_id,
                            x_resource_list_id     => l_resource_list_id,
                            x_uncat_flag           => l_uncat_flag,
                            x_uncat_rlm_id         => l_uncat_rlm_id,
                            x_rl_group_type_id     => l_rl_group_type_id,
                            x_planning_level       => l_planning_level,
                            x_return_status        => x_return_status,
                            x_msg_count            => x_msg_count,
                            x_msg_data             => x_msg_data);

          --Bug # 2615807.
          select project_currency_code,projfunc_currency_code
          into l_project_currency_code,l_projfunc_currency_code
          from pa_projects_all
          where project_id = l_project_id;

         IF (p_txn_currency_code IS NULL) THEN

            pa_debug.g_err_stage := 'Transaction Currency Code is NULL';
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,3);
            END IF;

               DELETE FROM pa_fp_rollup_tmp;  /* M20-AUG: delete from rollup_tmp should be unconditional */

              /* At this point, l_parent_assginment_id contains the assignment id of an impacted
                 parent under which some other (undeleted) children exist. Hence Rollup has to be
                 done for the parent level records. */

              /* For the Parent Assignment ID, populating the Rollup Table PA_FP_ROLLUP_TMP, with
                 the old and new amounts. Call Rollup_Resource_Assignment_Amounts to roll up the
                 Resource Assignments data and Rollup_Denorm_Amounts to roll up the Denorm data.*/

              pa_debug.g_err_stage := 'Insert records into Rollup Temp Table with the amounts';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,3);
              END IF;

              /* M20-AUG: we have to insert all the records for the deleted resource assignment */

              INSERT INTO PA_FP_ROLLUP_TMP
                     ( BUDGET_LINE_ID                   /* FPB2 */
                      ,OLD_START_DATE                   /* FPB2 */
                      ,START_DATE                       /* FPB2 */
                      ,RESOURCE_ASSIGNMENT_ID
                      ,PARENT_ASSIGNMENT_ID
                      ,OLD_PROJ_RAW_COST
                      ,OLD_PROJ_BURDENED_COST
                      ,OLD_PROJ_REVENUE
                      ,OLD_PROJFUNC_RAW_COST
                      ,OLD_PROJFUNC_BURDENED_COST
                      ,OLD_PROJFUNC_REVENUE
                      ,OLD_QUANTITY
                      ,PROJECT_RAW_COST
                      ,PROJECT_BURDENED_COST
                      ,PROJECT_REVENUE
                      ,PROJFUNC_RAW_COST
                      ,PROJFUNC_BURDENED_COST
                      ,PROJFUNC_REVENUE
                      ,TXN_RAW_COST
                      ,TXN_BURDENED_COST
                      ,TXN_REVENUE
                      ,QUANTITY
                      ,DELETE_FLAG
                      ,PROJECT_CURRENCY_CODE             --Bug # 2615807
                      ,PROJFUNC_CURRENCY_CODE)            --Bug # 2615807
              SELECT bl.budget_line_id                  /* FPB2 */
                    ,bl.start_Date                      /* FPB2 */
                    ,bl.start_Date                      /* FPB2 */
                    ,bl.resource_assignment_id
                    ,pra.parent_assignment_id
                    ,bl.project_raw_cost        old_proj_raw_cost
                    ,bl.project_burdened_cost   old_proj_burdened_cost
                    ,bl.project_revenue         old_proj_revenue
                    ,bl.raw_cost                old_projfunc_raw_cost
                    ,bl.burdened_cost           old_projfunc_burdened_cost
                    ,bl.revenue                 old_projfunc_revenue
                    ,bl.quantity                old_quantity
                    ,null                       project_raw_cost
                    ,null                       project_burdened_cost
                    ,null                       project_revenue
                    ,null                       projfunc_raw_cost
                    ,null                       projfunc_burdened_cost
                    ,null                       projfunc_revenue
                    ,null                       txn_raw_cost
                    ,null                       txn_burdened_cost
                    ,null                       txn_revenue
                    ,null                       quantity
                    ,'Y'                        delete_flag
                    ,l_project_currency_code                     --Bug # 2615807
                    ,l_projFunc_currency_code                    --Bug # 2615807
               FROM pa_budget_lines bl
                   ,pa_resource_assignments pra
              WHERE bl.resource_assignment_id = p_resource_assignment_id
                AND pra.resource_assignment_id = bl.resource_assignment_id
              /* FPB2: Removed grouped by and null handling in select columns as
                       budget_line_id needs to be included
              GROUP BY bl.resource_assignment_id
                      ,pra.parent_assignment_id */ ;

              pa_debug.g_err_stage := 'inserted ' || sql%rowcount || ' records in rollup tmp';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,3);
              END IF;

         ELSE

	      pa_debug.g_err_stage := 'Transaction Currency Code is Not Null';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,3);
              END IF;

              /* Since the details of the records being deleted are required for rolling
                 up data, we need to get the amounts from the Budget Lines table for the
                 resource assignment that is being deleted. */

              /* First, delete the records from pa_fp_rollup_tmp if any. */

                   DELETE FROM pa_fp_rollup_tmp;

                   pa_debug.g_err_stage := 'Insert Records into Rollup Temp Table for txn currency';
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,3);
                   END IF;

                   INSERT INTO pa_fp_rollup_tmp
                             ( budget_line_id           /* FPB2 */
                              ,old_start_date           /* FPB2 */
                              ,start_date               /* FPB2 */
                              ,resource_assignment_id
                              ,txn_currency_code
                              ,delete_flag
                              ,old_proj_raw_cost
                              ,old_proj_burdened_cost
                              ,old_proj_revenue
                              ,old_projfunc_raw_cost
                              ,old_projfunc_burdened_cost
                              ,old_projfunc_revenue
                              ,old_quantity
                              ,project_raw_cost
                              ,project_burdened_cost
                              ,project_revenue
                              ,projfunc_raw_cost
                              ,projfunc_burdened_cost
                              ,projfunc_revenue
                              ,quantity
                              ,project_currency_code       --Bug#2615807
                              ,projFunc_currency_code)     --Bug#2615807
                   SELECT budget_line_id                /* FPB2 */
                         ,start_date                    /* FPB2 */
                         ,start_date                    /* FPB2 */
                         ,resource_assignment_id
                         ,txn_currency_code
                         ,'Y'
                         ,project_raw_cost
                         ,project_burdened_cost
                         ,revenue
                         ,raw_cost
                         ,burdened_cost
                         ,revenue
                         ,quantity
                         ,decode(txn_currency_code,p_txn_currency_code,0,project_raw_cost)
                         ,decode(txn_currency_code,p_txn_currency_code,0,project_burdened_cost)
                         ,decode(txn_currency_code,p_txn_currency_code,0,project_revenue)
                         ,decode(txn_currency_code,p_txn_currency_code,0,raw_cost)
                         ,decode(txn_currency_code,p_txn_currency_code,0,burdened_cost)
                         ,decode(txn_currency_code,p_txn_currency_code,0,revenue)
                         ,decode(txn_currency_code,p_txn_currency_code,0,quantity)
                         ,l_project_currency_code    --Bug#2615807
                         ,l_projFunc_currency_code     --Bug#2615807
                     FROM pa_budget_lines
                    WHERE resource_assignment_id = p_resource_assignment_id
              /* FPB2: Removed grouped by and null handling in select columns as
                       budget_line_id needs to be included
                    GROUP BY resource_assignment_id, txn_currency_code */ ;

                 pa_debug.g_err_stage := 'inserted ' || sql%rowcount || ' records into rollup tmp';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,3);
                 END IF;

	 END IF;

         Select
               a.resource_assignment_id
               ,a.period_name
               ,a.start_date
               ,a.end_date
               ,a.txn_currency_code
               ,-a.txn_raw_cost
               ,-a.txn_burdened_cost
               ,-a.txn_revenue
               ,-a.project_raw_cost
               ,-a.project_burdened_cost
               ,-a.project_revenue
               ,-a.raw_cost
               ,-a.burdened_cost
               ,-a.revenue
               ,a.cost_rejection_code
               ,a.revenue_rejection_code
               ,a.burden_rejection_code
               ,a.other_rejection_code
               ,a.pc_cur_conv_rejection_code
               ,a.pfc_cur_conv_rejection_code
               ,-a.quantity
               ,b.rbs_element_id
               ,b.task_id
               ,b.resource_class_code
               ,b.rate_based_flag
	 Bulk Collect Into
                l_resource_assignment_id_tbl
                ,l_period_name_tbl
                ,l_start_date_tbl
                ,l_end_date_tbl
                ,l_txn_currency_code_tbl
                ,l_txn_raw_cost_tbl
                ,l_txn_burdened_cost_tbl
                ,l_txn_revenue_tbl
                ,l_project_raw_cost_tbl
                ,l_project_burdened_cost_tbl
                ,l_project_revenue_tbl
                ,l_raw_cost_tbl
                ,l_burdened_cost_tbl
                ,l_revenue_tbl
                ,l_cost_rejection_code_tbl
                ,l_revenue_rejection_code_tbl
                ,l_burden_rejection_code_tbl
                ,l_other_rejection_code_tbl
                ,l_pc_cur_conv_rej_code_tbl
                ,l_pfc_cur_conv_rej_code_tbl
                ,l_quantity_tbl
                ,l_rbs_element_id_tbl
                ,l_task_id_tbl
                ,l_res_class_code_tbl
                ,l_rate_based_flag_tbl
	 From
	       pa_budget_lines a,
	       pa_resource_assignments b
	 Where  a.resource_assignment_id = b.resource_assignment_id
	 and    b.budget_version_id = p_budget_version_id
	 and    b.resource_assignment_id = p_resource_assignment_id
	 and    a.txn_currency_code = nvl(p_txn_currency_code,a.txn_currency_code);

	 IF l_resource_assignment_id_tbl.count > 0 THEN

	     IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.write('DELETE_ELEMENT: ' || l_module_name,'There are budget lines to be deleted... ',3);
             END IF;

             pa_planning_transaction_utils.call_update_rep_lines_api
                        (
                           p_source                     => 'PL-SQL'
                          ,p_budget_version_id          => p_budget_version_id
                          ,p_resource_assignment_id_tbl => l_resource_assignment_id_tbl
                          ,p_period_name_tbl		=> l_period_name_tbl
                          ,p_start_date_tbl		=> l_start_date_tbl
                          ,p_end_date_tbl		=> l_end_date_tbl
                          ,p_txn_currency_code_tbl	=> l_txn_currency_code_tbl
                          ,p_txn_raw_cost_tbl		=> l_txn_raw_cost_tbl
                          ,p_txn_burdened_cost_tbl	=> l_txn_burdened_cost_tbl
                          ,p_txn_revenue_tbl		=> l_txn_revenue_tbl
                          ,p_project_raw_cost_tbl	=> l_project_raw_cost_tbl
                          ,p_project_burdened_cost_tbl	=> l_project_burdened_cost_tbl
                          ,p_project_revenue_tbl	=> l_project_revenue_tbl
                          ,p_raw_cost_tbl		=> l_raw_cost_tbl
                          ,p_burdened_cost_tbl		=> l_burdened_cost_tbl
                          ,p_revenue_tbl		=> l_revenue_tbl
                          ,p_cost_rejection_code_tbl	=> l_cost_rejection_code_tbl
                          ,p_revenue_rejection_code_tbl	=> l_revenue_rejection_code_tbl
                          ,p_burden_rejection_code_tbl	=> l_burden_rejection_code_tbl
                          ,p_other_rejection_code	=> l_other_rejection_code_tbl
                          ,p_pc_cur_conv_rej_code_tbl	=> l_pc_cur_conv_rej_code_tbl
                          ,p_pfc_cur_conv_rej_code_tbl	=> l_pfc_cur_conv_rej_code_tbl
                          ,p_quantity_tbl		=> l_quantity_tbl
                          ,p_rbs_element_id_tbl		=> l_rbs_element_id_tbl
                          ,p_task_id_tbl		=> l_task_id_tbl
                          ,p_res_class_code_tbl		=> l_res_class_code_tbl
                          ,p_rate_based_flag_tbl	=> l_rate_based_flag_tbl
                          ,x_return_status              => x_return_status
                          ,x_msg_count                  => x_msg_count
                          ,x_msg_data                   => x_msg_data);

             IF x_return_Status <> FND_API.G_RET_STS_SUCCESS  THEN
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.g_err_stage := 'pa_planning_transaction_utils.call_update_rep_lines_api errored .... ' || x_msg_data;
                     pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,5);
                  END IF;
                  RAISE PA_FP_ROLLUP_PKG.Invalid_Arg_Exc;
             END IF;

	 END IF;

         IF (p_txn_currency_code IS NULL) THEN

	      /* Transaction Currency Code is NULL and hence we can delete records
                 from the tables PA_BUDGET_LINES */

              DELETE FROM pa_budget_lines
               WHERE resource_assignment_id = p_resource_assignment_id;

              l_records_deleted := sql%rowcount;

              pa_debug.g_err_stage := 'deleted ' || l_records_deleted || ' records from budget lines';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,3);
              END IF;

              -- Bug Fix: 4569365. Removed MRC code.
              /*
              IF l_records_deleted > 0 THEN
	          -- FPB2: MRC

                   IF PA_MRC_FINPLAN. G_MRC_ENABLED_FOR_BUDGETS IS NULL THEN
                        PA_MRC_FINPLAN.CHECK_MRC_INSTALL
                            (x_return_status      => x_return_status,
                             x_msg_count          => x_msg_count,
                             x_msg_data           => x_msg_data);
                   END IF;

                   IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS AND
                      PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A' THEN

                        PA_MRC_FINPLAN.MAINTAIN_ALL_MC_BUDGET_LINES
                           (p_fin_plan_version_id => p_budget_version_id,
                            p_entire_version      => 'N',
                            x_return_status       => x_return_status,
                            x_msg_count           => x_msg_count,
                            x_msg_data            => x_msg_data);
                   END IF;

                   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE g_mrc_exception;
                   END IF;

              END IF;
              */

              DELETE FROM pa_resource_assignments
              WHERE resource_assignment_id = p_resource_assignment_id
              RETURNING parent_assignment_id, task_id, resource_list_member_id
                  INTO l_parent_assignment_id
                      ,l_task_id
                      ,l_resource_list_member_id;

              pa_debug.g_err_stage := 'Calling Rollup_budget_versions';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,3);
              END IF;

              ROLLUP_BUDGET_VERSION(p_budget_version_id => p_budget_version_id
                                    ,p_entire_version   => 'N'
                                    ,x_return_status    => x_return_status
                                    ,x_msg_count        => x_msg_count
                                    ,x_msg_data         => x_msg_data);

              DELETE FROM pa_proj_periods_denorm
               WHERE resource_assignment_id = p_resource_assignment_id;

              pa_debug.g_err_stage := 'deleted ' || sql%rowcount || ' records from denorm';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,3);
              END IF;

         ELSE

              /* Deleting records from pa_budget_lines (for resource_assignment_id
                 and txn_currency_code) and pa_proj_periods_denorm (for 'TRANSACTION'
                 currency type. */

              DELETE FROM pa_budget_lines
              WHERE  resource_assignment_id = p_resource_assignment_id
              AND    txn_currency_code      = p_txn_currency_code;

              l_records_deleted := sql%rowcount;
              pa_debug.g_err_stage := 'deleted ' || l_records_deleted || ' records from budget lines';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,3);
              END IF;

              -- Bug Fix: 4569365. Removed MRC code.
              /*
              IF l_records_deleted > 0 THEN

              -- FPB2: MRC

                   IF PA_MRC_FINPLAN. G_MRC_ENABLED_FOR_BUDGETS IS NULL THEN
                     PA_MRC_FINPLAN.CHECK_MRC_INSTALL
                              (x_return_status      => x_return_status,
                               x_msg_count          => x_msg_count,
                               x_msg_data           => x_msg_data);
                   END IF;

                   IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS AND
                      PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A' THEN

                      PA_MRC_FINPLAN.MAINTAIN_ALL_MC_BUDGET_LINES
                             (p_fin_plan_version_id => p_budget_version_id,
                              p_entire_version      => 'N',
                              x_return_status       => x_return_status,
                              x_msg_count           => x_msg_count,
                              x_msg_data            => x_msg_data);
                   END IF;

                   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     RAISE g_mrc_exception;
                   END IF;

              END IF;
              */

              /* Call the Rollup API so that the parents and the subsequent parents
                 are rolled up. */

              pa_debug.g_err_stage := 'Calling Rollup_Budget_Version';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,3);
              END IF;

              ROLLUP_BUDGET_VERSION(p_budget_version_id => p_budget_version_id
                                   ,p_entire_version   => 'N'
                                   ,x_return_status    => x_return_status
                                   ,x_msg_count        => x_msg_count
                                   ,x_msg_data         => x_msg_data);

              /* Delete from pa_proj_periods_denorm. */

              DELETE FROM pa_proj_periods_denorm
               WHERE resource_assignment_id = p_resource_assignment_id
                 AND currency_type = PA_FP_CONSTANTS_PKG.G_CURRENCY_TYPE_TRANSACTION
                 AND currency_code = p_txn_currency_code;

              pa_debug.g_err_stage := 'deleted ' || sql%rowcount || ' records from denorm';

              IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,3);
              END IF;

              /* Check if there are any more Budget Lines existing for this resource. */

              BEGIN

                   SELECT 'Y'
                     INTO l_rec_exists /* PK: use exists */
                     FROM dual
                    WHERE exists
                          (SELECT 1
                             FROM pa_budget_lines bl
                            WHERE resource_assignment_id = p_resource_assignment_id
                              AND ROWNUM = 1);

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     l_rec_exists := 'N';

              END;


              IF (nvl(l_rec_exists,'N') = 'Y') THEN

                  /* If Budget Lines exist for the resource_assignment_id, Setting the Parent
                     Assignment ID to NULL as no more processing is required for this case. */

                     pa_debug.g_err_stage := 'Budget Lines exist for the Parent Assignment ID';
                     IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,3);
                     END IF;

                     l_parent_assignment_id := NULL;

              ELSE

              /* If there are no budget lines then this assignment id eligible for deletion.
                 Get the parent assignment id in l_parent_assignment_id */

                   pa_debug.g_err_stage := 'No Budget Lines for Parent Assignment ID';
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,3);
                   END IF;

                   DELETE FROM pa_resource_assignments
                    WHERE resource_assignment_id = p_resource_assignment_id
                RETURNING parent_assignment_id, task_id, resource_list_member_id
                     INTO l_parent_assignment_id
                         ,l_task_id
                         ,l_resource_list_member_id;

                   pa_debug.g_err_stage := 'deleted ' || sql%rowcount || ' records from res assignment';
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,3);
                   END IF;

                   DELETE FROM pa_proj_periods_denorm
                    WHERE resource_assignment_id = p_resource_assignment_id;

                   pa_debug.g_err_stage := 'deleted ' || sql%rowcount || ' records from denorm';
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,3);
                   END IF;

              END IF;

         END IF; /* txn_currency_code IS NULL */

         /* bug 2649117 Moved the LOOP out of the l_parent_assignment_id condition
            Else when parent assignment id becomes null it was going in an infinite loop
         */
         LOOP
             IF (l_parent_assignment_id IS NOT NULL) THEN

                   pa_debug.g_err_stage := 'Parent Assignment ID is NOT NULL';
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,3);
                   END IF;

                   l_child_res_count := 0;

                   SELECT count(1)
                     INTO l_child_res_count
                     FROM pa_resource_assignments pra
                    WHERE pra.parent_assignment_id = l_parent_assignment_id;

                   IF l_child_res_count = 0 THEN

                      /* If no child is found for this Parent Assignment ID,then delete this
                         resource_assignment_id record from pa_resource_assignments and pa
                         pa_proj_periods_denorm. Get the parent of this resource assignment id.
                         Continue this loop until some parent is found with child records. */

                             pa_debug.g_err_stage := 'no child found. deleting the parent';
                             IF P_PA_DEBUG_MODE = 'Y' THEN
                                pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,3);
                             END IF;

                             /* the delete below is moved before the next delete as after the next delte
                                l_parent_assignment_id value will change
                             */

                             DELETE FROM pa_proj_periods_denorm
                              WHERE resource_assignment_id = l_parent_assignment_id;
                           /* WHERE resource_assignment_id = p_resource_assignment_id   during bug fix 2649117 found that it
                              was p_resource_assignment_id */

                             DELETE FROM pa_resource_assignments
                              WHERE resource_assignment_id = l_parent_assignment_id
                          RETURNING parent_assignment_id INTO l_parent_assignment_id;

                             pa_debug.g_err_stage := 'deleted ' || sql%rowcount || ' from denorm';
                             IF P_PA_DEBUG_MODE = 'Y' THEN
                                pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,3);
                             END IF;

                   ELSE /* Child records are found */

                   /* Resource Assignments need to be rolled up from this point.
                      So, exit the loop. */
                        pa_debug.g_err_stage := 'some child found. no action';
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                           pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,3);
                        END IF;

                        EXIT;
                   END IF;
             ELSE
                /* bug 2649117 added else and the exit condition. So that when
                   no parent is found it exits out of the loop
                */
                pa_debug.g_err_stage := 'parent assignment id is NULL';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('DELETE_ELEMENT: ' || l_module_name,pa_debug.g_err_stage,3);
                END IF;

                EXIT;
             END IF;
        END LOOP;

       pa_debug.reset_err_stack;

EXCEPTION
  WHEN PA_FP_ROLLUP_PKG.Invalid_Arg_Exc THEN
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
      ELSE
             x_msg_count := l_msg_count;
      END IF;
      pa_debug.reset_err_stack;
    RAISE;
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_FP_ROLLUP_PKG'
            ,p_procedure_name => 'Delete_Element');
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('DELETE_ELEMENT: ' || l_module_name,SQLERRM,5);
        END IF;
        pa_debug.reset_err_stack;

        raise FND_API.G_EXC_UNEXPECTED_ERROR;
END DELETE_ELEMENT;

END PA_FP_ROLLUP_PKG;

/
