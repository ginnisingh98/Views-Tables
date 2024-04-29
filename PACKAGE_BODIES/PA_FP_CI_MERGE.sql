--------------------------------------------------------
--  DDL for Package Body PA_FP_CI_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_CI_MERGE" AS
/* $Header: PAFPCIMB.pls 120.14.12010000.10 2010/06/03 12:18:16 racheruv ship $ */
-- Bug Fix: 4569365. Removed MRC code.
-- g_mrc_exception EXCEPTION; /* FPB2 */

l_module_name VARCHAR2(100) := 'pa.plsql.pa_fp_ci_merge';
P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

--This record type will contain items for budget version id, ci id and the code which indicates whether
--the type of impact that can be implemented into the target version. Bug 3550073
--The valid values for impact_type can be
----COST
----REVENUE
----BOTH (If both cost and revenue ci versions can be implemented)
----ALL(If the the ci id has ALL impact and if it can be implemented)
----NONE(Impact can be implemented)
--impl_cost_flag and impl_rev_flag will be either Y or N indicating whether the ci id can be implemented in
--the budget version id or not
TYPE budget_ci_map_rec IS RECORD
(budget_version_id            pa_budget_versions.budget_version_id%TYPE
,ci_id                        pa_control_items.ci_id%TYPE
,impact_type_code             VARCHAR2(10)
,impl_cost_flag               VARCHAR2(1)
,impl_rev_flag                VARCHAR2(1));

TYPE budget_ci_map_rec_tbl_type IS TABLE OF budget_ci_map_rec
      INDEX BY BINARY_INTEGER;

--This record type will be used in change order merge. This will help in identifying the target resource assignment
--id corresponding to a task id and resource list member id in the target. ra_dml_code can be either INSERT or UPDATE.
--INSERT indicates that the target resource assignment has to be inserted . UPDATE indicates that the target
--resource assignment already exists.Bug 3678314
TYPE res_assmt_map_rec IS RECORD
(task_id                      pa_tasks.task_id%TYPE
,resource_list_member_id      pa_resource_list_members.resource_list_member_id%TYPE
,resource_assignment_id       pa_resource_assignments.resource_assignment_id%TYPE
,ra_dml_code                  VARCHAR2(30));

TYPE res_assmt_map_rec_tbl_type IS TABLE OF res_assmt_map_rec
      INDEX BY BINARY_INTEGER;

--This record type will contain key and a value. A pl/sql tbl of this record type can be declared and it can be
--used for different purposes. One such case is : if its required to get the top task id for a task id at many
--places in the code then instead of firing a select each time we can fetch it and store in this record. The key
--will be the task id and the value will be top task id.
--Created for bug 3678314
TYPE key_value_rec IS RECORD
(key                          NUMBER
,value                        NUMBER);

TYPE key_value_rec_tbl_type IS TABLE OF key_value_rec
      INDEX BY BINARY_INTEGER;

--Tables for implement_ci_into_single_ver
l_src_targ_task_tbl        key_value_rec_tbl_type;
l_res_assmt_map_rec_tbl    res_assmt_map_rec_tbl_type;


--End of tables for implement_ci_into_single_ver

/*
  This API will be called when one control item has been
  merged into another control item or plan version. This
  API inserts records in the merged control items table
  and links two control items that have already merged.
  */

PROCEDURE FP_CI_LINK_CONTROL_ITEMS
(
  p_project_id           IN  NUMBER,
  p_s_fp_version_id      IN  pa_budget_versions.budget_version_id%TYPE,
  p_t_fp_version_id      IN  pa_budget_versions.budget_version_id%TYPE,
  p_inclusion_method     IN  VARCHAR2,
  p_included_by               IN  NUMBER,
  --Added for bug 3550073
  p_version_type        IN  pa_budget_versions.version_type%TYPE,
  p_ci_id               IN  pa_control_items.ci_id%TYPE,
  p_cost_ppl_qty        IN  pa_fp_merged_ctrl_items.impl_quantity%TYPE,
  p_rev_ppl_qty         IN  pa_fp_merged_ctrl_items.impl_quantity%TYPE,
  p_cost_equip_qty      IN  pa_fp_merged_ctrl_items.impl_equipment_quantity%TYPE,
  p_rev_equip_qty       IN  pa_fp_merged_ctrl_items.impl_equipment_quantity%TYPE,
  p_impl_pfc_raw_cost   IN  pa_fp_merged_ctrl_items.impl_proj_func_raw_cost%TYPE,
  p_impl_pfc_revenue    IN  pa_fp_merged_ctrl_items.impl_proj_func_revenue%TYPE,
  p_impl_pfc_burd_cost  IN  pa_fp_merged_ctrl_items.impl_proj_func_burdened_cost%TYPE,
  p_impl_pc_raw_cost    IN  pa_fp_merged_ctrl_items.impl_proj_raw_cost%TYPE,
  p_impl_pc_revenue     IN  pa_fp_merged_ctrl_items.impl_proj_revenue%TYPE,
  p_impl_pc_burd_cost   IN  pa_fp_merged_ctrl_items.impl_proj_burdened_cost%TYPE,
  p_impl_agr_revenue    IN  pa_fp_merged_ctrl_items.impl_agr_revenue%TYPE,
  x_return_status        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )
 IS
-- Local Variable Declaration

      l_last_updated_by       NUMBER := FND_GLOBAL.USER_ID;
      l_created_by            NUMBER := FND_GLOBAL.USER_ID;
      l_creation_date         DATE   := SYSDATE;
      l_last_update_date      DATE   := l_creation_date;
      l_last_update_login   NUMBER := FND_GLOBAL.LOGIN_ID;

      l_s_ci_id                   pa_budget_versions.ci_id%TYPE;
      l_included_by          NUMBER := 0;
      l_party_id             NUMBER := 0;
      l_debug_mode       VARCHAR2(30);
      l_module_name         VARCHAR2(100):='PAFPCIMB.FP_CI_LINK_CONTROL_ITEMS';

BEGIN
    IF p_pa_debug_mode = 'Y' THEN
         pa_debug.init_err_stack('PAFPCIMB.FP_CI_LINK_CONTROL_ITEMS');
    END IF;
     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');
   IF p_pa_debug_mode = 'Y' THEN
    PA_DEBUG.Set_Curr_Function( p_function   => l_module_name,
                                p_debug_mode => l_debug_mode );
   END IF;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     x_msg_count := 0;
    --------dbms_output.put_line('FP_CI_LINK_CONTROL_ITEMS - 1');
    --Check for nulls for mandatory parameters
    IF p_s_fp_version_id IS NULL THEN
        PA_UTILS.ADD_MESSAGE
        ( p_app_short_name => 'PA',
          p_msg_name       => 'PA_FP_CI_NULL_PARAM_PASSED');

        /*PA_UTILS.ADD_MESSAGE
          ( p_app_short_name => 'PA',
            p_msg_name       => 'The source budget version id passed is null');
          */

    IF p_pa_debug_mode = 'Y' THEN
         PA_DEBUG.g_err_stage := 'The source budget version id passed is null';
         PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          --------dbms_output.put_line('FP_CI_LINK_CONTROL_ITEMS - ***2');
     IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
     END IF;
          RETURN;
     END IF;

     IF p_t_fp_version_id IS NULL THEN
        PA_UTILS.ADD_MESSAGE
        ( p_app_short_name => 'PA',
        p_msg_name       => 'PA_FP_CI_NULL_PARAM_PASSED');
          /*PA_UTILS.ADD_MESSAGE
          ( p_app_short_name => 'PA',
            p_msg_name       => 'The target budget version id passed is null');
            */
    IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.g_err_stage := 'The target budget version id passed is null';
        PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
          --------dbms_output.put_line('FP_CI_LINK_CONTROL_ITEMS - ***3');
      IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.Reset_Curr_Function;
      END IF;
          RETURN;
     END IF;

     IF p_project_id IS NULL THEN
          PA_UTILS.ADD_MESSAGE
          ( p_app_short_name => 'PA',
            p_msg_name       => 'PA_FP_CI_NULL_PARAM_PASSED');
          /*PA_UTILS.ADD_MESSAGE
          ( p_app_short_name => 'PA',
            p_msg_name       => 'The project id passed is null');
          */
    IF p_pa_debug_mode = 'Y' THEN
             PA_DEBUG.g_err_stage := 'The project id passed is null';
             PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          --------dbms_output.put_line('FP_CI_LINK_CONTROL_ITEMS -*** 4');
      IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.Reset_Curr_Function;
     END IF;
          RETURN;
     END IF;

    IF p_version_type IS NULL  OR
       p_version_type NOT IN ('COST', 'REVENUE', 'BOTH') THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Invalid p_version_type passed is '||p_version_type;
            pa_debug.write(L_module_name,pa_debug.g_err_stage,5);
        END IF;
        PA_UTILS.ADD_MESSAGE
          ( p_app_short_name => 'PA',
            p_msg_name       => 'PA_FP_CI_NULL_PARAM_PASSED');
          x_return_status := FND_API.G_RET_STS_ERROR;
          --------dbms_output.put_line('FP_CI_LINK_CONTROL_ITEMS -*** 4');
       IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.Reset_Curr_Function;
       END IF;
          RETURN;


    END IF;

    -- Get the control item id for the source version
    -- from the budget version table
    IF p_ci_id IS NULL THEN
        BEGIN
            SELECT
                  bv.ci_id
            INTO
                  l_s_ci_id
            FROM  pa_budget_versions bv
            WHERE bv.budget_version_id = p_s_fp_version_id
            AND   bv.project_id = p_project_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                PA_UTILS.ADD_MESSAGE
                ( p_app_short_name => 'PA',
                  p_msg_name       => 'PA_FP_CI_NO_CI_ID_FOUND');
                --------dbms_output.put_line('FP_CI_LINK_CONTROL_ITEMS - 5****');
                x_return_status := FND_API.G_RET_STS_ERROR;
        END;
    ELSE
        l_s_ci_id := p_ci_id;
    END IF;

     IF p_included_by IS NOT NULL THEN
          l_included_by := p_included_by;
     ELSE
          l_included_by := FND_GLOBAL.USER_ID;
     END IF;

     BEGIN
          SELECT hp.party_id
          INTO
               l_party_id
          FROM      fnd_user fu,
               hz_parties hp
          WHERE
             user_id = l_included_by
             and employee_id IS NOT NULL
             and hp.orig_system_reference = 'PER:' || fu.employee_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        SELECT hp.party_id
        INTO   l_party_id
        FROM   fnd_user fu,
               hz_parties hp
        WHERE
              user_id = l_included_by
        AND   employee_id IS NULL
        -- Bug 4931044: R12 ATG Mandate: Moving customer_id to
        --   person_party_id in fnd_user
        AND   hp.party_id =  fu.person_party_id;
        -- AND   hp.party_id =  fu.customer_id;
    END;

     -- Insert in the merged control items table
     IF p_version_type IN ('COST', 'BOTH') THEN
        INSERT INTO pa_fp_merged_ctrl_items
        (
             PROJECT_ID
            ,PLAN_VERSION_ID
            ,CI_ID
            ,CI_PLAN_VERSION_ID
            ,RECORD_VERSION_NUMBER
            ,last_update_date
            ,last_updated_by
            ,creation_date
            ,created_by
            ,last_update_login
            ,inclusion_method_code
            ,included_by_person_id
            --Included for bug 3550073
            ,version_type
            ,impl_proj_func_raw_cost
            ,impl_proj_func_burdened_cost
            ,impl_proj_func_revenue
            ,impl_proj_raw_cost
            ,impl_proj_burdened_cost
            ,impl_proj_revenue
            ,impl_quantity
            ,impl_equipment_quantity
            ,impl_agr_revenue
        )
        VALUES
        (
             p_project_id
            ,p_t_fp_version_id
            ,l_s_ci_id
            ,p_s_fp_version_id
            ,1
            ,l_last_update_date
            ,l_last_updated_by
            ,l_creation_date
            ,l_created_by
            ,l_last_update_login
            ,p_inclusion_method
            ,l_party_id
            --Included for bug 3550073
            ,'COST'
            ,p_impl_pfc_raw_cost
            ,p_impl_pfc_burd_cost
            ,p_impl_pfc_revenue -- Bug 5845142
            ,p_impl_pc_raw_cost
            ,p_impl_pc_burd_cost
            ,p_impl_pc_revenue -- Bug 5845142
            ,p_cost_ppl_qty
            ,p_cost_equip_qty
            ,NULL
        );
    END IF;

    IF p_version_type IN ('REVENUE', 'BOTH') THEN
        INSERT INTO pa_fp_merged_ctrl_items
        (
             PROJECT_ID
            ,PLAN_VERSION_ID
            ,CI_ID
            ,CI_PLAN_VERSION_ID
            ,RECORD_VERSION_NUMBER
            ,last_update_date
            ,last_updated_by
            ,creation_date
            ,created_by
            ,last_update_login
            ,inclusion_method_code
            ,included_by_person_id
            --Included for bug 3550073
            ,version_type
            ,impl_proj_func_raw_cost
            ,impl_proj_func_burdened_cost
            ,impl_proj_func_revenue
            ,impl_proj_raw_cost
            ,impl_proj_burdened_cost
            ,impl_proj_revenue
            ,impl_quantity
            ,impl_equipment_quantity
            ,impl_agr_revenue
        )
        VALUES
        (
             p_project_id
            ,p_t_fp_version_id
            ,l_s_ci_id
            ,p_s_fp_version_id
            ,1
            ,l_last_update_date
            ,l_last_updated_by
            ,l_creation_date
            ,l_created_by
            ,l_last_update_login
            ,p_inclusion_method
            ,l_party_id
            --Included for bug 3550073
            ,'REVENUE'
            ,NULL
            ,NULL
            ,p_impl_pfc_revenue
            ,NULL
            ,NULL
            ,p_impl_pc_revenue
            ,p_rev_ppl_qty
            ,p_rev_equip_qty
            ,p_impl_agr_revenue
        );

    END IF;
 IF p_pa_debug_mode = 'Y' THEN
    PA_DEBUG.Reset_Curr_Function;
END IF;
EXCEPTION
     WHEN OTHERS THEN
         FND_MSG_PUB.add_exc_msg
                  ( p_pkg_name       => 'PA_FP_CI_MERGE.' ||
                   'fp_ci_link_control_items'
                   ,p_procedure_name => PA_DEBUG.G_Err_Stack);
    IF p_pa_debug_mode = 'Y' THEN
         PA_DEBUG.g_err_stage := 'Unexpected error in fp_ci_link_control_items';
         PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         --------dbms_output.put_line('FP_CI_LINK_CONTROL_ITEMS - 6****');
    IF p_pa_debug_mode = 'Y' THEN
         PA_DEBUG.Reset_Curr_Function;
     END IF;
         RAISE;

END FP_CI_LINK_CONTROL_ITEMS;
-- end of fp_ci_link_control_items

/****************************************************************
  This API is called to update the estimated amounts for control
  items budget versions. The main updation in this API is to update
  the estimated amounts for the target budget version of control item
  ***************************************************************/

  PROCEDURE FP_CI_UPDATE_EST_AMOUNTS
  (
    p_project_id         IN pa_budget_versions.project_id%TYPE,
    p_source_version_id       IN pa_budget_versions.budget_version_id%TYPE,
    p_target_version_id       IN pa_budget_versions.budget_version_id%TYPE,
    p_merge_unmerge_mode IN VARCHAR2 ,
    p_commit_flag        IN VARCHAR2 ,
    p_init_msg_list      IN VARCHAR2 ,
    p_update_agreement        IN VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   )
   IS
  -- Local Variable Declaration

        l_last_updated_by     NUMBER := FND_GLOBAL.USER_ID;
     l_last_update_date       DATE := SYSDATE;
        l_last_update_login     NUMBER := FND_GLOBAL.LOGIN_ID;

        l_debug_mode          VARCHAR2(30);

        l_target_ver_type     pa_budget_versions.version_type%TYPE;

     l_est_project_raw_cost        pa_budget_versions.est_project_raw_cost%TYPE;
     l_est_project_burdened_cost   pa_budget_versions.est_project_burdened_cost%TYPE;
     l_est_project_revenue         pa_budget_versions.est_project_revenue%TYPE;
     l_est_quantity           pa_budget_versions.est_quantity%TYPE;
     l_est_projfunc_raw_cost       pa_budget_versions.est_projfunc_raw_cost%TYPE;
     l_est_projfunc_burdened_cost  pa_budget_versions.est_projfunc_burdened_cost%TYPE;
     l_est_projfunc_revenue        pa_budget_versions.est_projfunc_revenue%TYPE;
     l_agreement_id           pa_budget_versions.agreement_id%TYPE;
    l_est_equipment_quantity  pa_budget_versions.est_equipment_quantity%TYPE;

  BEGIN
    IF p_pa_debug_mode = 'Y' THEN
         pa_debug.init_err_stack('PAFPCIMB.FP_CI_UPDATE_EST_AMOUNTS');
    END IF;
     IF NVL(p_init_msg_list,'N') = 'Y' THEN
               FND_MSG_PUB.initialize;
     END IF;
     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');
   IF p_pa_debug_mode = 'Y' THEN
     pa_debug.set_process('PLSQL','LOG',l_debug_mode);
   END IF;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
          x_msg_count := 0;
          --------dbms_output.put_line('FP_CI_UPDATE_EST_AMOUNTS - 1');
          --Check for nulls for mandatory parameters
     IF p_source_version_id IS NULL THEN
          PA_UTILS.ADD_MESSAGE
          ( p_app_short_name => 'PA',
            p_msg_name       => 'PA_FP_CI_NULL_PARAM_PASSED');
    IF p_pa_debug_mode = 'Y' THEN
          PA_DEBUG.g_err_stage := 'The source budget version id passed is null';
          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
     END IF;

     IF p_target_version_id IS NULL THEN
          PA_UTILS.ADD_MESSAGE
          ( p_app_short_name => 'PA',
            p_msg_name       => 'PA_FP_CI_NULL_PARAM_PASSED');
    IF p_pa_debug_mode = 'Y' THEN
          PA_DEBUG.g_err_stage := 'The target budget version id passed is null';
          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
     END IF;

     IF p_project_id IS NULL THEN
          PA_UTILS.ADD_MESSAGE
          ( p_app_short_name => 'PA',
            p_msg_name       => 'PA_FP_CI_NULL_PARAM_PASSED');
    IF p_pa_debug_mode = 'Y' THEN
          PA_DEBUG.g_err_stage := 'The project id passed is null';
          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
     END IF;

          -- Get the target version type
          BEGIN
          SELECT bv.version_type
          INTO l_target_ver_type
          FROM pa_budget_versions bv
          WHERE
          bv.project_id = p_project_id
          AND bv.budget_version_id = p_target_version_id;
     EXCEPTION
          WHEN NO_DATA_FOUND THEN
              PA_UTILS.ADD_MESSAGE
               ( p_app_short_name => 'PA',
                 p_msg_name       => 'PA_FP_CI_NO_VERSION_DATA_FOUND');
              ------dbms_output.put_line('FP_CI_UPDATE_EST_AMOUNTS - 2***');
              x_return_status := FND_API.G_RET_STS_ERROR;
     END;

     -- Get the estimated amounts for the source version

     BEGIN
          SELECT
               NVL(est_project_raw_cost,0),
               NVL(est_project_burdened_cost,0),
               NVL(est_project_revenue,0),
               NVL(est_quantity,0),
               NVL(est_projfunc_raw_cost,0),
               NVL(est_projfunc_burdened_cost,0),
               NVL(est_projfunc_revenue,0),
            NVL(est_equipment_quantity,0),
               agreement_id
          INTO
               l_est_project_raw_cost,
               l_est_project_burdened_cost,
               l_est_project_revenue,
               l_est_quantity,
               l_est_projfunc_raw_cost,
               l_est_projfunc_burdened_cost,
               l_est_projfunc_revenue,
            l_est_equipment_quantity,
               l_agreement_id
          FROM PA_BUDGET_VERSIONS bv
          WHERE
          bv.project_id = p_project_id
          AND bv.budget_version_id = p_source_version_id;

     EXCEPTION
          WHEN NO_DATA_FOUND THEN
              PA_UTILS.ADD_MESSAGE
               ( p_app_short_name => 'PA',
                 p_msg_name       => 'PA_FP_CI_NO_VERSION_DATA_FOUND');
              ------dbms_output.put_line('FP_CI_UPDATE_EST_AMOUNTS - 2***');
              x_return_status := FND_API.G_RET_STS_ERROR;
     END;

     -- Update the budget versions table for the target version
     -- based on version type
     IF(l_target_ver_type = 'ALL') THEN
          UPDATE PA_BUDGET_VERSIONS bv
          SET
          est_project_raw_cost = NVL(est_project_raw_cost,0) + DECODE
                                             (p_merge_unmerge_mode,
                                             'MERGE', l_est_project_raw_cost,
                                             'UNMERGE', (-1 * l_est_project_raw_cost)),
          est_project_burdened_cost = NVL(est_project_burdened_cost,0) + DECODE
                                             (p_merge_unmerge_mode,
                                             'MERGE', l_est_project_burdened_cost,
                                             'UNMERGE', (-1 * l_est_project_burdened_cost)),
          est_project_revenue = NVL(est_project_revenue,0) + DECODE
                                             (p_merge_unmerge_mode,
                                             'MERGE', l_est_project_revenue,
                                             'UNMERGE', (-1 * l_est_project_revenue)),
          est_quantity = NVL(est_quantity,0) + DECODE
                                             (p_merge_unmerge_mode,
                                             'MERGE', l_est_quantity,
                                             'UNMERGE', (-1 * l_est_quantity)),
        est_equipment_quantity=NVL(est_equipment_quantity,0) + DECODE
                                             (p_merge_unmerge_mode,
                                             'MERGE', l_est_equipment_quantity,
                                             'UNMERGE', (-1 * l_est_equipment_quantity)),
          est_projfunc_raw_cost = NVL(est_projfunc_raw_cost,0) + DECODE
                                             (p_merge_unmerge_mode,
                                             'MERGE', l_est_projfunc_raw_cost,
                                             'UNMERGE', (-1 * l_est_projfunc_raw_cost)),
          est_projfunc_burdened_cost = NVL(est_projfunc_burdened_cost,0) + DECODE
                                             (p_merge_unmerge_mode,
                                             'MERGE', l_est_projfunc_burdened_cost,
                                             'UNMERGE', (-1 * l_est_projfunc_burdened_cost)),
          est_projfunc_revenue = NVL(est_projfunc_revenue,0) + DECODE
                                             (p_merge_unmerge_mode,
                                             'MERGE', l_est_projfunc_revenue,
                                             'UNMERGE', (-1 * l_est_projfunc_revenue))
          WHERE
               bv.project_id = p_project_id
          AND bv.budget_version_id = p_target_version_id;
          IF (SQL%ROWCOUNT = 0) THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
     ELSIF(l_target_ver_type = 'COST') THEN
          UPDATE PA_BUDGET_VERSIONS bv
          SET
          est_project_raw_cost = NVL(est_project_raw_cost,0) + DECODE
                                             (p_merge_unmerge_mode,
                                             'MERGE', l_est_project_raw_cost,
                                             'UNMERGE', (-1 * l_est_project_raw_cost)),
          est_project_burdened_cost = NVL(est_project_burdened_cost,0) + DECODE
                                             (p_merge_unmerge_mode,
                                             'MERGE', l_est_project_burdened_cost,
                                             'UNMERGE', (-1 * l_est_project_burdened_cost)),
          est_quantity = NVL(est_quantity,0) + DECODE
                                             (p_merge_unmerge_mode,
                                             'MERGE', l_est_quantity,
                                             'UNMERGE', (-1 * l_est_quantity)),
          est_projfunc_raw_cost = NVL(est_projfunc_raw_cost,0) + DECODE
                                             (p_merge_unmerge_mode,
                                             'MERGE', l_est_projfunc_raw_cost,
                                             'UNMERGE', (-1 * l_est_projfunc_raw_cost)),
          est_projfunc_burdened_cost = NVL(est_projfunc_burdened_cost,0) + DECODE
                                             (p_merge_unmerge_mode,
                                             'MERGE', l_est_projfunc_burdened_cost,
                                             'UNMERGE', (-1 * l_est_projfunc_burdened_cost))
          WHERE
               bv.project_id = p_project_id
          AND bv.budget_version_id = p_target_version_id;
          IF (SQL%ROWCOUNT = 0) THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
     ELSIF(l_target_ver_type = 'REVENUE') THEN
          UPDATE PA_BUDGET_VERSIONS bv
          SET
          est_project_revenue = NVL(est_project_revenue,0) + DECODE
                                             (p_merge_unmerge_mode,
                                             'MERGE', l_est_project_revenue,
                                             'UNMERGE', (-1 * l_est_project_revenue)),
          est_quantity = NVL(est_quantity,0) + DECODE
                                             (p_merge_unmerge_mode,
                                             'MERGE', l_est_quantity,
                                             'UNMERGE', (-1 * l_est_quantity)),
          est_projfunc_revenue = NVL(est_projfunc_revenue,0) + DECODE
                                             (p_merge_unmerge_mode,
                                             'MERGE', l_est_projfunc_revenue,
                                             'UNMERGE', (-1 * l_est_projfunc_revenue))
          WHERE
               bv.project_id = p_project_id
          AND bv.budget_version_id = p_target_version_id;
          IF (SQL%ROWCOUNT = 0) THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
     END IF;

     IF (p_update_agreement = 'Y') THEN
          UPDATE PA_BUDGET_VERSIONS bv
          SET
          agreement_id = l_agreement_id
          WHERE
               bv.project_id = p_project_id
          AND bv.budget_version_id = p_target_version_id;
          IF (SQL%ROWCOUNT = 0) THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
     END IF;
  IF NVL(p_commit_flag,'N') = 'Y' THEN
     COMMIT;
  END IF;
  EXCEPTION
     WHEN OTHERS THEN
         FND_MSG_PUB.add_exc_msg
                  ( p_pkg_name       => 'PA_FP_CI_MERGE.' ||
                   'fp_ci_update_est_amounts'
                   ,p_procedure_name => PA_DEBUG.G_Err_Stack);
    IF p_pa_debug_mode = 'Y' THEN
         PA_DEBUG.g_err_stage := 'Unexpected error in FP_CI_UPDATE_EST_AMOUNTS';
         PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         --------dbms_output.put_line('FP_CI_UPDATE_EST_AMOUNTS - 6****');
 IF p_pa_debug_mode = 'Y' THEN
         PA_DEBUG.Reset_Curr_Function;
END IF;
         RAISE;

  END FP_CI_UPDATE_EST_AMOUNTS;
-- end of fp_ci_update_est_amounts

/****************************************************************
  This API is called to update the financial impact for control
  items. The main updation in this API is to update the status
  code of the impact and the person who caused that impact
  ***************************************************************/
  --Added p_impact_type_code for bug 3550073.
  --p_impact_type can be FINPLAN_COST, FINPLAN_REVENUE or
  --FINPLAN_BOTH in which case both FINPLAN_COST and FINPLAN_REVENUE records will be updated
  PROCEDURE FP_CI_UPDATE_IMPACT
  (
    p_ci_id                      IN  pa_ci_impacts.ci_id%TYPE,
    p_status_code            IN  pa_ci_impacts.status_code%TYPE,
    p_implementation_date     IN  pa_ci_impacts.implementation_date%TYPE,
    p_implemented_by          IN  pa_ci_impacts.implemented_by%TYPE,
    p_record_version_number   IN  pa_ci_impacts.record_version_number%TYPE,
    p_impacted_task_id        IN  pa_ci_impacts.impacted_task_id%TYPE,
    p_impact_type_code      IN  pa_ci_impacts.impact_type_code%TYPE,
    p_commit_flag            IN  VARCHAR2 ,
    p_init_msg_list          IN  VARCHAR2 ,
    x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   )
   IS
  -- Local Variable Declaration

        l_last_updated_by     NUMBER := FND_GLOBAL.USER_ID;
     l_last_update_date       DATE := SYSDATE;
        l_last_update_login     NUMBER := FND_GLOBAL.LOGIN_ID;

        l_party_id       NUMBER := 0;
        l_implemented_by NUMBER := 0;
        l_impact_type_code    VARCHAR2(30);
        l_debug_mode          VARCHAR2(30);

  BEGIN
    IF p_pa_debug_mode = 'Y' THEN
         pa_debug.init_err_stack('PAFPCIMB.FP_CI_UPDATE_IMPACT');
    END IF;
     IF NVL(p_init_msg_list,'N') = 'Y' THEN
               FND_MSG_PUB.initialize;
     END IF;
     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');
   IF p_pa_debug_mode = 'Y' THEN
     pa_debug.set_process('PLSQL','LOG',l_debug_mode);
   END IF;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
          x_msg_count := 0;
          --------dbms_output.put_line('FP_CI_UPDATE_IMPACT - 1');
          --Checking for a valid implementation date
          IF (p_implementation_date > SYSDATE) THEN
          PA_UTILS.Add_Message ( p_app_short_name => 'PA',
                           p_msg_name => 'PA_FP_CI_INV_IMPACT_DATE'
                         );
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
     END IF;

     --Checking if control item id is null
     IF p_ci_id IS NULL THEN
          PA_UTILS.Add_Message ( p_app_short_name => 'PA',
                                   p_msg_name => 'PA_FP_CI_NULL_CI_ID'
                                 );
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
     END IF;

    IF p_impact_type_code  IS NULL OR
       p_impact_type_code NOT IN ('FINPLAN_COST', 'FINPLAN_REVENUE', 'FINPLAN_BOTH') THEN
          PA_UTILS.Add_Message ( p_app_short_name => 'PA',
                                   p_msg_name => 'PA_FP_INV_PARAM_PASSED',
                               p_token1=>'PROCEDURENAME',
                               p_value1=>'FP_CI_UPDATE_IMPACT'
                                 );
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
     END IF;


     --Setting impact type code to FINPLAN
     l_impact_type_code := p_impact_type_code;

     IF p_implemented_by IS NOT NULL THEN
          l_implemented_by := p_implemented_by;
     ELSE
          l_implemented_by := FND_GLOBAL.USER_ID;
     END IF;

     BEGIN
          SELECT hp.party_id
          INTO
               l_party_id
          FROM      fnd_user fu,
               hz_parties hp
          WHERE
             user_id = l_implemented_by
             and employee_id IS NOT NULL
             and hp.orig_system_reference = 'PER:' || fu.employee_id;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
               SELECT hp.party_id
               INTO
               l_party_id
               FROM fnd_user fu,
             hz_parties hp
          WHERE
             user_id = l_implemented_by
             and employee_id IS NULL
             -- Bug 4931044: R12 ATG Mandate: Moving customer_id to
             --    person_party_id in fnd_user
             and hp.party_id =  fu.person_party_id;
             --and hp.party_id =  fu.customer_id;
        END;

     -- Update the PA_CI_IMPACTS table

     UPDATE PA_CI_IMPACTS
     SET
         STATUS_CODE = NVL(p_status_code,status_code),
         IMPLEMENTATION_DATE = NVL(p_implementation_date,SYSDATE),
         IMPLEMENTED_BY = l_party_id,
         IMPACTED_TASK_ID = NVL(p_impacted_task_id,impacted_task_id),
         LAST_UPDATE_DATE = l_last_update_date,
         LAST_UPDATED_BY = l_last_updated_by,
         LAST_UPDATE_LOGIN = l_last_update_login,
         RECORD_VERSION_NUMBER = NVL(p_record_version_number, record_version_number +1)
         WHERE ci_id = p_ci_id
        AND   ((l_impact_type_code ='FINPLAN_BOTH' AND impact_type_code IN ('FINPLAN_COST', 'FINPLAN_REVENUE'))
          OR   (impact_type_code = l_impact_type_code));
     --------dbms_output.put_line('SQL%ROWCOUNT****' || SQL%ROWCOUNT);
     IF (SQL%ROWCOUNT = 0) THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  IF NVL(p_commit_flag,'N') = 'Y' THEN
     COMMIT;
  END IF;
  EXCEPTION
     WHEN OTHERS THEN
         FND_MSG_PUB.add_exc_msg
                  ( p_pkg_name       => 'PA_FP_CI_MERGE.' ||
                   'fp_ci_update_impact'
                   ,p_procedure_name => PA_DEBUG.G_Err_Stack);
    IF p_pa_debug_mode = 'Y' THEN
         PA_DEBUG.g_err_stage := 'Unexpected error in FP_CI_UPDATE_IMPACT';
         PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         --------dbms_output.put_line('FP_CI_UPDATE_IMPACT - 6****');
 IF p_pa_debug_mode = 'Y' THEN
         PA_DEBUG.Reset_Curr_Function;
END IF;
         RAISE;

  END FP_CI_UPDATE_IMPACT;
-- end of fp_ci_update_impact



PROCEDURE FP_CI_MERGE_CI_ITEMS
(
  p_project_id           IN NUMBER,
  p_s_fp_ci_id           IN pa_budget_versions.ci_id%TYPE,
  p_t_fp_ci_id           IN pa_budget_versions.ci_id%TYPE,
  p_merge_unmerge_mode        IN VARCHAR2 ,
  p_commit_flag               IN VARCHAR2 ,
  p_init_msg_list        IN VARCHAR2 ,
  p_calling_context      IN VARCHAR2,
  x_warning_flag         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )
  IS
 --Defining PL/SQL local variables
       l_s_fp_ci_id      pa_budget_versions.ci_id%TYPE;
       l_t_fp_ci_id      pa_budget_versions.ci_id%TYPE;
       l_budget_version_id    pa_budget_versions.budget_version_id%TYPE;
       l_target_version_id    pa_budget_versions.budget_version_id%TYPE;
       l_target_version_id_tmp  pa_budget_versions.budget_version_id%TYPE;
       l_source_version_id    pa_budget_versions.budget_version_id%TYPE;
       l_counter         NUMBER := 0;
       l_task_id         NUMBER;
       l_s_version_id         pa_budget_versions.budget_version_id%TYPE;
       l_s_fin_plan_pref_code      pa_proj_fp_options.fin_plan_preference_code%TYPE;
       l_s_multi_curr_flag    pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;
       l_s_time_phased_code   pa_proj_fp_options. all_time_phased_code%TYPE;
       l_s_resource_list_id   pa_proj_fp_options.all_resource_list_id%TYPE;
       l_s_fin_plan_level_code     pa_proj_fp_options.all_fin_plan_level_code%TYPE;
       l_s_uncategorized_flag pa_resource_lists_all_bg.uncategorized_flag %TYPE;
       l_s_group_res_type_id  pa_resource_lists_all_bg.group_resource_type_id%TYPE;
       l_s_version_type  pa_budget_versions.version_type%TYPE;
       l_s_ci_id         pa_budget_versions.ci_id%TYPE;
       l_t_version_id         pa_budget_versions.budget_version_id%TYPE;
       l_t_fin_plan_pref_code      pa_proj_fp_options.fin_plan_preference_code%TYPE;
       l_t_time_phased_code   pa_proj_fp_options. all_time_phased_code%TYPE;
       l_t_resource_list_id   pa_proj_fp_options.all_resource_list_id%TYPE;
       l_t_multi_curr_flag    pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;
       l_t_fin_plan_level_code     pa_proj_fp_options.all_fin_plan_level_code%TYPE;
       l_t_uncategorized_flag pa_resource_lists_all_bg.uncategorized_flag %TYPE;
       l_t_group_res_type_id  pa_resource_lists_all_bg.group_resource_type_id%TYPE;
       l_t_version_type  pa_budget_versions.version_type%TYPE;
       l_t_ci_id         pa_budget_versions.ci_id%TYPE;
       l_source_ver_type pa_budget_versions.version_type%TYPE;
       l_target_ver_type pa_budget_versions.version_type%TYPE;
       l_target_plan_type_p_code pa_proj_fp_options.fin_plan_preference_code%TYPE;

     --Defining Local PL/SQL variables for source version
       l_source_id_tbl PA_PLSQL_DATATYPES.IdTabTyp;
       l_s_fp_version_id_tbl PA_PLSQL_DATATYPES.IdTabTyp;
       l_s_fin_plan_pref_code_tbl PA_PLSQL_DATATYPES.Char30TabTyp;
       l_s_multi_curr_flag_tbl     PA_PLSQL_DATATYPES.Char1TabTyp;
       l_s_fin_plan_level_code_tbl PA_PLSQL_DATATYPES.Char30TabTyp;
       l_s_uncategorized_flag_tbl PA_PLSQL_DATATYPES.Char1TabTyp;
       l_s_group_res_type_id_tbl   PA_PLSQL_DATATYPES.IdTabTyp;
       l_s_version_type_tbl   PA_PLSQL_DATATYPES.Char30TabTyp;
       l_s_time_phased_code_tbl    PA_PLSQL_DATATYPES.Char30TabTyp;
       l_source_fp_version_id_tbl PA_PLSQL_DATATYPES.IdTabTyp;

   --Defining Local PL/SQL variables for target version
       l_target_id_tbl PA_PLSQL_DATATYPES.IdTabTyp;
       l_t_fp_version_id_tbl  PA_PLSQL_DATATYPES.IdTabTyp;
       l_t_fin_plan_pref_code_tbl PA_PLSQL_DATATYPES.Char30TabTyp;
       l_t_multi_curr_flag_tbl     PA_PLSQL_DATATYPES.Char1TabTyp;
       l_t_fin_plan_level_code_tbl PA_PLSQL_DATATYPES.Char30TabTyp;
       l_t_uncategorized_flag_tbl PA_PLSQL_DATATYPES.Char1TabTyp;
       l_t_version_type_tbl   PA_PLSQL_DATATYPES.Char30TabTyp;
       l_t_group_res_type_id_tbl   PA_PLSQL_DATATYPES.IdTabTyp;
       l_t_time_phased_code_tbl    PA_PLSQL_DATATYPES.Char30TabTyp;
       l_target_fp_version_id_tbl PA_PLSQL_DATATYPES.IdTabTyp;

   --Other Local Variables
       l_merge_possible_code_tbl PA_PLSQL_DATATYPES.Char1TabTyp;
       l_count_merged_versions     NUMBER := 0;
       l_copy_version_flag    VARCHAR2(1);
       l_copy_possible_flag   VARCHAR2(1);
       l_debug_mode           VARCHAR2(30);
       l_bulk_fetch_count     NUMBER := 0;
       l_index           NUMBER := 1;
       l_count           NUMBER := 0;
       l_t_count_versions          NUMBER := 0;
       l_count_projects       NUMBER := 0;
       l_target_plan_types_cnt  NUMBER := 0;
       l_merged_count         NUMBER := 0;
       l_insert_flag          VARCHAR2(1) := 'N';
       l_merge_possible_code    VARCHAR2(1);
       l_s_version_id_count   NUMBER := 0;
       l_update_agreement_flag     VARCHAR2(1) := 'N';

       l_ci_id_tbl                      SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
       l_ci_cost_version_id_tbl         SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
       l_ci_rev_version_id_tbl          SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
       l_ci_all_version_id_tbl          SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
       l_target_version_id_tbl          SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
       l_impl_cost_flag_tbl             SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
       l_impl_rev_flag_tbl              SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
       l_translated_msgs_tbl            SYSTEM.pa_varchar2_2000_tbl_type:=SYSTEM.pa_varchar2_2000_tbl_type();
       l_translated_err_msg_count       NUMBER;
       l_translated_err_msg_level_tbl   SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();

       l_impact_record_exists   VARCHAR2(1); -- Bug 3677924 Raja 02-Jul-04

       -- Bug 5845142
       l_s_app_cost_flag                pa_budget_versions.approved_cost_plan_type_flag%TYPE;
       l_s_app_rev_flag                 pa_budget_versions.approved_rev_plan_type_flag%TYPE;
       l_t_app_cost_flag                pa_budget_versions.approved_cost_plan_type_flag%TYPE;
       l_t_app_rev_flag                 pa_budget_versions.approved_rev_plan_type_flag%TYPE;

BEGIN

IF p_pa_debug_mode = 'Y' THEN
pa_debug.init_err_stack('PAFPINCB.FP_CI_MERGE_CI_ITEMS');
END IF;
IF NVL(p_init_msg_list,'N') = 'Y' THEN
     FND_MSG_PUB.initialize;
END IF;
fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
l_debug_mode := NVL(l_debug_mode, 'Y');
IF p_pa_debug_mode = 'Y' THEN
  pa_debug.set_process('PLSQL','LOG',l_debug_mode);
END IF;
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_msg_count := 0;

l_target_version_id := NULL;
l_update_agreement_flag  := 'N';
l_copy_version_flag := 'N';
x_warning_flag := 'N';
savepoint before_fp_ci_copy;

--Getting the target ci_id from the parameter
     l_s_fp_ci_id := p_s_fp_ci_id;
     l_t_fp_ci_id := p_t_fp_ci_id;

     ------dbms_output.put_line('l_s_fp_ci_id : ' || l_s_fp_ci_id);
     ------dbms_output.put_line('l_t_fp_ci_id : ' || l_t_fp_ci_id);

--Check if any budget versions exist for the target
--control item id or not
SELECT COUNT(*) INTO l_t_count_versions
FROM pa_budget_versions bv
WHERE
bv.project_id = p_project_id
AND bv.ci_id = l_t_fp_ci_id
AND (NVL(bv.approved_rev_plan_type_flag,'N') = 'Y'
     OR NVL(bv.approved_cost_plan_type_flag,'N') = 'Y');

--Get number of approved plan types
SELECT count(*)
INTO l_target_plan_types_cnt
FROM pa_proj_fp_options po
WHERE
project_id = p_project_id
and fin_plan_option_level_code = 'PLAN_TYPE'
and (NVL(po.approved_rev_plan_type_flag,'N') = 'Y'
OR NVL(po.approved_cost_plan_type_flag,'N') = 'Y');

-- Get the number of source budget versions
SELECT count(*)
INTO l_s_version_id_count
FROM pa_budget_versions bv
WHERE
bv.project_id = p_project_id
AND bv.ci_id = l_s_fp_ci_id
AND (NVL(bv.approved_rev_plan_type_flag,'N') = 'Y'
OR NVL(bv.approved_cost_plan_type_flag,'N') = 'Y');

IF (l_s_version_id_count = 1) THEN

     --Get source version id
     SELECT bv.budget_version_id
     BULK COLLECT INTO l_source_id_tbl
     FROM pa_budget_versions bv
     WHERE
     bv.project_id = p_project_id
     AND bv.ci_id = l_s_fp_ci_id
     AND (NVL(bv.approved_rev_plan_type_flag,'N') = 'Y'
     OR NVL(bv.approved_cost_plan_type_flag,'N') = 'Y');

     For i in l_source_id_tbl.FIRST.. l_source_id_tbl.LAST
     LOOP
          --Get source version id in local variable
          l_source_version_id := l_source_id_tbl(i);
     END LOOP;

     -- Get the source version type. Bug 5845142
     SELECT bv.version_type,
            NVL(bv.approved_cost_plan_type_flag,'N'),
            NVL(bv.approved_rev_plan_type_flag,'N')
     INTO l_source_ver_type,
          l_s_app_cost_flag,
          l_s_app_rev_flag
     FROM pa_budget_versions bv
     WHERE
     bv.project_id = p_project_id
     AND bv.budget_version_id = l_source_version_id;

     IF (l_t_count_versions = 1) THEN
          --Get target version id
          BEGIN
               SELECT bv.budget_version_id
               INTO l_target_version_id
               FROM pa_budget_versions bv
               WHERE
               bv.project_id = p_project_id
               AND bv.ci_id = l_t_fp_ci_id
               AND bv.version_type = l_source_ver_type
               AND (NVL(bv.approved_rev_plan_type_flag,'N') = 'Y'
               OR NVL(bv.approved_cost_plan_type_flag,'N') = 'Y');
          EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_t_count_versions := 0;
          END;
     END IF;


     IF (l_t_count_versions = 0) THEN
          l_copy_version_flag := 'Y';
          -- We must copy the target version from source version

          --Call the check API to see if the copy should
          --go through or not

          --Before that get details of source version
          Pa_Fp_Control_Items_Utils.FP_CI_GET_VERSION_DETAILS
          (
               p_project_id        => p_project_id,
               p_budget_version_id => l_source_version_id,
               x_fin_plan_pref_code     => l_s_fin_plan_pref_code,
               x_multi_curr_flag   => l_s_multi_curr_flag,
               x_fin_plan_level_code    => l_s_fin_plan_level_code,
               x_resource_list_id  => l_s_resource_list_id,
               x_time_phased_code  => l_s_time_phased_code,
               x_uncategorized_flag     => l_s_uncategorized_flag,
               x_group_res_type_id => l_s_group_res_type_id,
               x_version_type      => l_s_version_type,
               x_ci_id             => l_s_ci_id,
               x_return_status          => x_return_status,
               x_msg_count              => x_msg_count,
               x_msg_data               => x_msg_data
          )  ;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RETURN;
          END IF;

          -- Bug 3677924 Jul 06 2004 Raja
          -- Check if target change order has corresponding impact record
          -- Note: If the target change order type does not allow the impact, the record
          -- would not have been created. For ALL ci version type, there would be two
          -- records in the impacts table. If ALL ci version can not be copied
          -- then no impact records would be present.
          BEGIN
               SELECT 'Y'
               INTO   l_impact_record_exists
               FROM   DUAL
               WHERE  EXISTS
                      (SELECT 1
                       FROM   pa_ci_impacts
                       WHERE  ci_id = l_t_fp_ci_id
                       AND    (l_s_version_type IN ('REVENUE','ALL') AND impact_type_code = 'FINPLAN_REVENUE'
                                OR l_s_version_type IN ('COST','ALL') AND impact_type_code = 'FINPLAN_COST'));
          EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_impact_record_exists := 'N';
          END;

          -- Bug 3677924 If the impact record does not exist do not proceed
          IF l_impact_record_exists = 'N' THEN
             RETURN;
          END IF;

          -- Call Copy version API
          PA_FIN_PLAN_PUB.Copy_Version
          (p_project_id           => p_project_id,
           p_source_version_id    => l_source_version_id,
           p_copy_mode            => PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_WORKING,
           p_calling_module   => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN,
           px_target_version_id   => l_target_version_id,
           x_return_status        => x_return_status,
           x_msg_count            => x_msg_count,
           x_msg_data             => x_msg_data);

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               ROLLBACK TO before_fp_ci_copy;
               RETURN;
           END IF;

           l_update_agreement_flag := 'Y';
           --Stamp the Control item ids for these budget versions
           UPDATE pa_budget_versions bv
           SET CI_ID = l_t_fp_ci_id
              ,VERSION_NUMBER = 1 -- bug 3677924
           WHERE
           p_project_id = bv.project_id
           AND bv.budget_version_id = l_target_version_id
           AND (NVL(bv.approved_rev_plan_type_flag,'N') = 'Y'
           OR NVL(bv.approved_cost_plan_type_flag,'N') = 'Y');

           /* copy the supplier data to the target control item
            * This will copy only the new suppler cost data  as part of Enc
            */

           copy_supplier_cost_data(p_ci_id_to             => l_t_fp_ci_id,
                                   p_ci_id_from           => l_s_fp_ci_id,
                                   x_return_status        => x_return_status,
                                   x_msg_count            => x_msg_count,
                                   x_msg_data             => x_msg_data );

          /* added for Enc 12.1.3 to copy direct cost data for target control item*/
             copy_direct_cost_data(p_ci_id_to             => l_t_fp_ci_id,
                                   p_ci_id_from           => l_s_fp_ci_id,
                                   p_bv_id                => l_target_version_id,
                                   p_project_id           => p_project_id,
                                   x_return_status        => x_return_status,
                                   x_msg_count            => x_msg_count,
                                   x_msg_data             => x_msg_data );

            -- p_commit_flag :='Y';
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               ROLLBACK TO before_fp_ci_copy;
               RETURN;
           END IF;
     ELSE
          --Target version already exists
          IF (l_t_count_versions = 2) THEN
               --Get target version id for correct source version type
               BEGIN
                    SELECT bv.budget_version_id
                    INTO l_target_version_id
                    FROM pa_budget_versions bv
                    WHERE
                    bv.project_id = p_project_id
                    AND bv.ci_id = l_t_fp_ci_id
                    AND bv.version_type = l_source_ver_type
                    AND (NVL(bv.approved_rev_plan_type_flag,'N') = 'Y'
                    OR NVL(bv.approved_cost_plan_type_flag,'N') = 'Y');
               EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        PA_UTILS.ADD_MESSAGE
                         ( p_app_short_name => 'PA',
                           p_msg_name       => 'PA_FP_CI_C_INV_VER_TYPE_MATCH');
                        ------dbms_output.put_line('FP_CI_CHECK_COPY_POSSIBLE - 2***');
                        x_return_status := FND_API.G_RET_STS_ERROR;
               END;
          END IF;

            l_impl_cost_flag_tbl.extend(1);
            l_impl_rev_flag_tbl.extend(1);
            l_impl_cost_flag_tbl(1):='N';
            l_impl_rev_flag_tbl(1):='N';
            l_ci_id_tbl.extend(1); -- Bug 3787567
            l_ci_id_tbl(1):=l_s_fp_ci_id;
            l_target_version_id_tbl.extend(1); -- Bug 3787567
            l_target_version_id_tbl(1):=l_target_version_id;
            IF l_source_ver_type ='COST' THEN
                l_ci_cost_version_id_tbl.extend(1);
                l_ci_cost_version_id_tbl(1):=l_source_version_id;
                l_impl_cost_flag_tbl(1):='Y';
            ELSIF l_source_ver_type ='REVENUE' THEN
                l_ci_rev_version_id_tbl.extend(1);
                l_ci_rev_version_id_tbl(1):=l_source_version_id;
                l_impl_rev_flag_tbl(1):='Y';
            ELSIF l_source_ver_type ='ALL' THEN

              -- Bug 5845142. Cost CI version can be of version type ALL.
              IF l_s_app_cost_flag ='Y' AND l_s_app_rev_flag = 'Y'  THEN

                l_ci_all_version_id_tbl.extend(1);
                l_ci_all_version_id_tbl(1):=l_source_version_id;
                l_impl_cost_flag_tbl(1):='Y';
                l_impl_rev_flag_tbl(1):='Y';

              ELSIF l_s_app_cost_flag ='Y' AND l_s_app_rev_flag = 'N'  THEN

                l_ci_cost_version_id_tbl.extend(1);
                l_ci_cost_version_id_tbl(1):=l_source_version_id;
                l_impl_cost_flag_tbl(1):='Y';

              END IF;

            END IF;

            implement_change_document
            (  p_context                       => 'CI_MERGE'
               ,p_ci_id_tbl                     => l_ci_id_tbl
               ,p_ci_cost_version_id_tbl        => l_ci_cost_version_id_tbl
               ,p_ci_rev_version_id_tbl         => l_ci_rev_version_id_tbl
               ,p_ci_all_version_id_tbl         => l_ci_all_version_id_tbl
               ,p_budget_version_id_tbl         => l_target_version_id_tbl
               ,p_impl_cost_flag_tbl            => l_impl_cost_flag_tbl
               ,p_impl_rev_flag_tbl             => l_impl_rev_flag_tbl
               ,x_translated_msgs_tbl           => l_translated_msgs_tbl
               ,x_translated_err_msg_count      => l_translated_err_msg_count
               ,x_translated_err_msg_level_tbl  => l_translated_err_msg_level_tbl
               ,x_return_status                 => x_return_status
               ,x_msg_count                     => x_msg_count
               ,x_msg_data                      => x_msg_data);
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                ROLLBACK TO before_fp_ci_copy;
                --------dbms_output.put_line('FP_CI_MERGE_CI_ITEMS - 11*****');
                RETURN;
            END IF;

            l_update_agreement_flag     := 'N';

               --------dbms_output.put_line('FP_CI_MERGE_CI_ITEMS - 10');
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                ROLLBACK TO before_fp_ci_copy;
                --------dbms_output.put_line('FP_CI_MERGE_CI_ITEMS - 11*****');
                RETURN;
            END IF;

           copy_supplier_cost_data(p_ci_id_to             => l_t_fp_ci_id,
                                   p_ci_id_from           => l_s_fp_ci_id,
                                   x_return_status        => x_return_status,
                                   x_msg_count            => x_msg_count,
                                   x_msg_data             => x_msg_data );

          /* added for Enc 12.1.3 to copy direct cost data for target control item*/
             copy_direct_cost_data(p_ci_id_to             => l_t_fp_ci_id,
                                   p_ci_id_from           => l_s_fp_ci_id,
                                   p_bv_id                => l_target_version_id,
                                   p_project_id           => p_project_id,
                                   x_return_status        => x_return_status,
                                   x_msg_count            => x_msg_count,
                                   x_msg_data             => x_msg_data );

            -- p_commit_flag :='Y';
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               ROLLBACK TO before_fp_ci_copy;
               RETURN;
           END IF;

     END IF;

     --Call the update estimated amounts API to update the estimated amounts
      FP_CI_UPDATE_EST_AMOUNTS
       (
         p_project_id         => p_project_id,
         p_source_version_id       => l_source_version_id,
         p_target_version_id       => l_target_version_id,
         p_merge_unmerge_mode => p_merge_unmerge_mode ,
         p_commit_flag        => 'N' ,
         p_init_msg_list      => 'N',
         p_update_agreement        => l_update_agreement_flag,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data
       );
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          --------dbms_output.put_line('FP_CI_MERGE_CI_ITEMS - 150****');
          ROLLBACK TO before_fp_ci_copy;
          RETURN;
       END IF;
ELSIF (l_s_version_id_count = 2) THEN
     --Get both source version ids
     SELECT bv.budget_version_id
     BULK COLLECT INTO l_source_fp_version_id_tbl
     FROM pa_budget_versions bv
     WHERE
     bv.project_id = p_project_id
     AND bv.ci_id = l_s_fp_ci_id
     AND (NVL(bv.approved_rev_plan_type_flag,'N') = 'Y'
     OR NVL(bv.approved_cost_plan_type_flag,'N') = 'Y')
     ORDER BY bv.version_type;


     IF (l_t_count_versions = 0) THEN
          For i in l_source_fp_version_id_tbl.FIRST.. l_source_fp_version_id_tbl.LAST
          LOOP
          BEGIN
               --Get source version id in local variable
               l_source_version_id := l_source_fp_version_id_tbl(i);
               l_target_version_id := NULL;
               -- We must copy the target version from source version

               --Before that get details of source version
               Pa_Fp_Control_Items_Utils.FP_CI_GET_VERSION_DETAILS
               (
                    p_project_id        => p_project_id,
                    p_budget_version_id => l_source_version_id,
                    x_fin_plan_pref_code     => l_s_fin_plan_pref_code,
                    x_multi_curr_flag   => l_s_multi_curr_flag,
                    x_fin_plan_level_code    => l_s_fin_plan_level_code,
                    x_resource_list_id  => l_s_resource_list_id,
                    x_time_phased_code  => l_s_time_phased_code,
                    x_uncategorized_flag     => l_s_uncategorized_flag,
                    x_group_res_type_id => l_s_group_res_type_id,
                    x_version_type      => l_s_version_type,
                    x_ci_id             => l_s_ci_id,
                    x_return_status          => x_return_status,
                    x_msg_count              => x_msg_count,
                    x_msg_data               => x_msg_data
               )  ;

               IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RETURN;
               END IF;

               -- Bug 3677924 Jul 06 2004 Raja
               -- Check if target change order has corresponding impact record
               -- Note: If the target change order type does not allow the corresponding
               -- impact,the impact record would not have been created. The fact that there
               -- are two source versions version type would be either cost or rev only.
               -- Bug 5845142. Cost CI Impact can be of type ALL
               BEGIN
                    SELECT 'Y'
                    INTO   l_impact_record_exists
                    FROM   DUAL
                    WHERE  EXISTS
                           (SELECT 1
                            FROM   pa_ci_impacts
                            WHERE  ci_id = l_t_fp_ci_id
                            AND    (l_s_version_type IN ('REVENUE') AND impact_type_code = 'FINPLAN_REVENUE'
                                     OR l_s_version_type IN ('COST','ALL') AND impact_type_code = 'FINPLAN_COST'));
               EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_impact_record_exists := 'N';
               END;

               -- Bug 3677924 If the impact record does not exist skip processing
               IF l_impact_record_exists = 'Y' THEN
                   -- Call Copy version API
                   PA_FIN_PLAN_PUB.Copy_Version
                   (p_project_id           => p_project_id,
                    p_source_version_id    => l_source_version_id,
                    p_copy_mode            => PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_WORKING,
                    p_calling_module   => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN,
                    px_target_version_id   => l_target_version_id,
                    x_return_status        => x_return_status,
                    x_msg_count            => x_msg_count,
                    x_msg_data             => x_msg_data);

                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        ROLLBACK TO before_fp_ci_copy;
                        RETURN;
                    END IF;

                    l_update_agreement_flag := 'Y';

                    --Stamp the Control item ids for this budget versions
                    UPDATE pa_budget_versions bv
                    SET CI_ID = l_t_fp_ci_id
                       ,version_number = 1  -- Bug 3677924 Jul 06 2004 Raja
                    WHERE
                    p_project_id = bv.project_id
                    AND bv.budget_version_id = l_target_version_id
                    AND (NVL(bv.approved_rev_plan_type_flag,'N') = 'Y'
                         OR NVL(bv.approved_cost_plan_type_flag,'N') = 'Y');

                    --Call the update estimated amounts API to update the estimated amounts
                    FP_CI_UPDATE_EST_AMOUNTS
                     (
                       p_project_id         => p_project_id,
                       p_source_version_id       => l_source_version_id,
                       p_target_version_id       => l_target_version_id,
                       p_merge_unmerge_mode => p_merge_unmerge_mode ,
                       p_commit_flag        => 'N' ,
                       p_init_msg_list      => 'N',
                       p_update_agreement        => l_update_agreement_flag,
                       x_return_status      => x_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data
                     );



           /* For Enc 12.1.3 start */
           SELECT bv.approved_cost_plan_type_flag
          INTO l_t_app_cost_flag
          FROM pa_budget_versions bv
          WHERE budget_version_id = l_target_version_id  ;

          if(l_t_app_cost_flag ='Y') then
          /*  call the below procedure only for cost budget */

           copy_supplier_cost_data(p_ci_id_to             => l_t_fp_ci_id,
                                   p_ci_id_from           => l_s_fp_ci_id,
                                   x_return_status        => x_return_status,
                                   x_msg_count            => x_msg_count,
                                   x_msg_data             => x_msg_data );

          /* added for Enc 12.1.3 to copy direct cost data for target control item*/
             copy_direct_cost_data(p_ci_id_to             => l_t_fp_ci_id,
                                   p_ci_id_from           => l_s_fp_ci_id,
                                   p_bv_id                => l_target_version_id,
                                   p_project_id           => p_project_id,
                                   x_return_status        => x_return_status,
                                   x_msg_count            => x_msg_count,
                                   x_msg_data             => x_msg_data );
          --p_commit_flag :='Y';
         end if;
         l_t_app_cost_flag := null ;
            /* For Enc 12.1.3 end */
                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        --------dbms_output.put_line('FP_CI_MERGE_CI_ITEMS - 150****');
                        ROLLBACK TO before_fp_ci_copy;
                        RETURN;
                     END IF;
              END IF;  -- if impact record exists copy amounts
          EXCEPTION
               WHEN RAISE_COPY_ERROR THEN
                    x_warning_flag := 'Y';
                    x_return_status := FND_API.G_RET_STS_ERROR;
          END;
          END LOOP;
     ELSIF(l_t_count_versions = 2) THEN

          --Get target version id
        --Since ordered by version type, the first version should be cost and the second one should be revenue
          SELECT bv.budget_version_id
          BULK COLLECT INTO l_target_fp_version_id_tbl
          FROM pa_budget_versions bv
          WHERE
          bv.project_id = p_project_id
          AND bv.ci_id = l_t_fp_ci_id
          AND (NVL(bv.approved_rev_plan_type_flag,'N') = 'Y'
          OR NVL(bv.approved_cost_plan_type_flag,'N') = 'Y')
          ORDER BY bv.version_type;


        --Prepare the pl/sql tables for change document
        l_ci_id_tbl.extend(1);
        l_ci_cost_version_id_tbl.extend(1);
        l_ci_rev_version_id_tbl.extend(1);
        l_ci_id_tbl(1):=l_s_fp_ci_id;
        l_ci_cost_version_id_tbl(1):=l_source_fp_version_id_tbl(1);--Cost Version
        l_ci_rev_version_id_tbl(1):=l_source_fp_version_id_tbl(2);--Revenue Version


        --Prepare pl/sql tbls for target version
        l_target_version_id_tbl.extend(2);
        l_impl_cost_flag_tbl.extend(2);
        l_impl_rev_flag_tbl.extend(2);
        l_target_version_id_tbl(1):=l_target_fp_version_id_tbl(1);
        l_target_version_id_tbl(2):=l_target_fp_version_id_tbl(2);
        l_impl_cost_flag_tbl(1):='Y';
        l_impl_rev_flag_tbl(1):='N';
        l_impl_cost_flag_tbl(2):='N';
        l_impl_rev_flag_tbl(2):='Y';

        implement_change_document
        (      p_context                       => 'CI_MERGE'
           ,p_ci_id_tbl                     => l_ci_id_tbl
           ,p_ci_cost_version_id_tbl        => l_ci_cost_version_id_tbl
           ,p_ci_rev_version_id_tbl         => l_ci_rev_version_id_tbl
           ,p_ci_all_version_id_tbl         => l_ci_all_version_id_tbl
           ,p_budget_version_id_tbl         => l_target_version_id_tbl
           ,p_impl_cost_flag_tbl            => l_impl_cost_flag_tbl
           ,p_impl_rev_flag_tbl             => l_impl_rev_flag_tbl
           ,x_translated_msgs_tbl           => l_translated_msgs_tbl
           ,x_translated_err_msg_count      => l_translated_err_msg_count
           ,x_translated_err_msg_level_tbl  => l_translated_err_msg_level_tbl
           ,x_return_status                 => x_return_status
           ,x_msg_count                     => x_msg_count
           ,x_msg_data                      => x_msg_data);
        l_update_agreement_flag    := 'N';
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            ROLLBACK TO before_fp_ci_copy;
            --------dbms_output.put_line('FP_CI_MERGE_CI_ITEMS - 11*****');
            RETURN;
        END IF;

          l_budget_version_id := l_target_fp_version_id_tbl(1);

          /*  call the below procedure only for cost budget */
           copy_supplier_cost_data(p_ci_id_to             => l_t_fp_ci_id,
                                   p_ci_id_from           => l_s_fp_ci_id,
                                   x_return_status        => x_return_status,
                                   x_msg_count            => x_msg_count,
                                   x_msg_data             => x_msg_data );

          /* added for Enc 12.1.3 to copy direct cost data for target control item*/
             copy_direct_cost_data(p_ci_id_to             => l_t_fp_ci_id,
                                   p_ci_id_from           => l_s_fp_ci_id,
                                   p_bv_id                => l_budget_version_id,
                                   p_project_id           => p_project_id,
                                   x_return_status        => x_return_status,
                                   x_msg_count            => x_msg_count,
                                   x_msg_data             => x_msg_data );
          --p_commit_flag :='Y';

        --Bug 4132915. Passing the correct source and target version id.
        FOR i IN 1..2
        LOOP
                FP_CI_UPDATE_EST_AMOUNTS
        (
          p_project_id            => p_project_id,
          p_source_version_id => l_source_fp_version_id_tbl(i),
          p_target_version_id => l_target_fp_version_id_tbl(i),
          p_merge_unmerge_mode     => p_merge_unmerge_mode ,
          p_commit_flag           => 'N' ,
          p_init_msg_list          => 'N',
          p_update_agreement  => l_update_agreement_flag,
          x_return_status          => x_return_status,
          x_msg_count              => x_msg_count,
          x_msg_data               => x_msg_data
        );

        END LOOP;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          --------dbms_output.put_line('FP_CI_MERGE_CI_ITEMS - 150****');
          ROLLBACK TO before_fp_ci_copy;
          RETURN;
        END IF;

     ELSIF(l_t_count_versions = 1) THEN

          --Get target version id and version type
          -- Bug 5845142
          SELECT bv.budget_version_id, bv.version_type,
                 bv.approved_cost_plan_type_flag,bv.approved_rev_plan_type_flag
          INTO l_target_version_id, l_target_ver_type,
               l_t_app_cost_flag,l_t_app_rev_flag
          FROM pa_budget_versions bv
          WHERE
          bv.project_id = p_project_id
          AND bv.ci_id = l_t_fp_ci_id
          AND (NVL(bv.approved_rev_plan_type_flag,'N') = 'Y'
          OR NVL(bv.approved_cost_plan_type_flag,'N') = 'Y');

          l_target_version_id_tmp := l_target_version_id;

        --Bug 5845142. In any scenario the code should never come into this IF. all the conditions are taken
        --care in the ELSE block below. This will happen because a CR's cost impact and CO's cost impact
        --will be of same version type and similarly CR's revenue impact and CO's revenue impact too will be
        --of same version type.
        IF l_target_ver_type='ALL' AND
           l_t_app_cost_flag ='Y' AND
           l_t_app_rev_flag ='Y' THEN

            --Prepare the pl/sql tables for change document
            l_ci_id_tbl.extend(1);
            l_ci_cost_version_id_tbl.extend(1);
            l_ci_rev_version_id_tbl.extend(1);
            l_ci_id_tbl(1):=l_s_fp_ci_id;
            l_ci_cost_version_id_tbl(1):=l_source_fp_version_id_tbl(1);--Cost Version
            l_ci_rev_version_id_tbl(1):=l_source_fp_version_id_tbl(2);--Revenue Version


            --Prepare pl/sql tbls for target version
            l_target_version_id_tbl.extend(1);
            l_impl_cost_flag_tbl.extend(1);
            l_impl_rev_flag_tbl.extend(1);
            l_target_version_id_tbl(1):=l_target_fp_version_id_tbl(1);
            l_impl_cost_flag_tbl(1):='Y';
            l_impl_rev_flag_tbl(1):='Y';

            implement_change_document
            (   p_context                       => 'CI_MERGE'
               ,p_ci_id_tbl                     => l_ci_id_tbl
               ,p_ci_cost_version_id_tbl        => l_ci_cost_version_id_tbl
               ,p_ci_rev_version_id_tbl         => l_ci_rev_version_id_tbl
               ,p_ci_all_version_id_tbl         => l_ci_all_version_id_tbl
               ,p_budget_version_id_tbl         => l_target_version_id_tbl
               ,p_impl_cost_flag_tbl            => l_impl_cost_flag_tbl
               ,p_impl_rev_flag_tbl             => l_impl_rev_flag_tbl
               ,x_translated_msgs_tbl           => l_translated_msgs_tbl
               ,x_translated_err_msg_count      => l_translated_err_msg_count
               ,x_translated_err_msg_level_tbl  => l_translated_err_msg_level_tbl
               ,x_return_status                 => x_return_status
               ,x_msg_count                     => x_msg_count
               ,x_msg_data                      => x_msg_data);
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                ROLLBACK TO before_fp_ci_copy;
                --------dbms_output.put_line('FP_CI_MERGE_CI_ITEMS - 11*****');
                RETURN;
            END IF;

            l_update_agreement_flag     := 'N';

            --Bug 4132915. Passing the correct source and target version id.
            FOR i IN 1..2
            LOOP
            FP_CI_UPDATE_EST_AMOUNTS
            (
              p_project_id             => p_project_id,
              p_source_version_id  => l_source_fp_version_id_tbl(i),
              p_target_version_id  => l_target_version_id_tbl(1),
              p_merge_unmerge_mode => p_merge_unmerge_mode ,
              p_commit_flag            => 'N' ,
              p_init_msg_list      => 'N',
              p_update_agreement   => l_update_agreement_flag,
              x_return_status      => x_return_status,
              x_msg_count          => x_msg_count,
              x_msg_data           => x_msg_data
            );

            END LOOP;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              --------dbms_output.put_line('FP_CI_MERGE_CI_ITEMS - 150****');
              ROLLBACK TO before_fp_ci_copy;
              RETURN;
            END IF;

        ELSE

            --Process for each source version id
            FOR i in l_source_fp_version_id_tbl.FIRST.. l_source_fp_version_id_tbl.LAST
            LOOP
                --------dbms_output.put_line('FP_CI_MERGE_CI_ITEMS - 2');
                l_source_version_id := l_source_fp_version_id_tbl(i);

                -- Get the source version type
                SELECT bv.version_type,bv.approved_cost_plan_type_flag, bv.approved_rev_plan_type_flag
                INTO l_source_ver_type,l_s_app_cost_flag,l_s_app_rev_flag
                FROM pa_budget_versions bv
                WHERE bv.project_id = p_project_id
                AND   bv.budget_version_id = l_source_version_id;

                IF(l_source_ver_type <> l_target_ver_type) THEN
                --The target should be copied from the source
                BEGIN
                    --Since the current target is not for the present source
                    l_target_version_id := NULL;
                    --Before that get details of source version
                    Pa_Fp_Control_Items_Utils.FP_CI_GET_VERSION_DETAILS
                    (
                        p_project_id         => p_project_id,
                        p_budget_version_id  => l_source_version_id,
                        x_fin_plan_pref_code => l_s_fin_plan_pref_code,
                        x_multi_curr_flag    => l_s_multi_curr_flag,
                        x_fin_plan_level_code     => l_s_fin_plan_level_code,
                        x_resource_list_id   => l_s_resource_list_id,
                        x_time_phased_code   => l_s_time_phased_code,
                        x_uncategorized_flag => l_s_uncategorized_flag,
                        x_group_res_type_id  => l_s_group_res_type_id,
                        x_version_type       => l_s_version_type,
                        x_ci_id              => l_s_ci_id,
                        x_return_status      => x_return_status,
                        x_msg_count          => x_msg_count,
                        x_msg_data           => x_msg_data
                    )  ;

                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RETURN;
                    END IF;

                    -- Bug 3677924 Jul 06 2004 Raja
                    -- Check if target change order has corresponding impact record
                    -- Note: If the target change order type does not allow the corresponding
                    -- impact,the impact record would not have been created. The fact that there
                    -- are two source versions version type would be either cost or rev only.
                    -- Bug 5845142
                    BEGIN
                         SELECT 'Y'
                         INTO   l_impact_record_exists
                         FROM   DUAL
                         WHERE  EXISTS
                                (SELECT 1
                                 FROM   pa_ci_impacts
                                 WHERE  ci_id = l_t_fp_ci_id
                                 AND    (l_s_version_type IN ('REVENUE') AND impact_type_code = 'FINPLAN_REVENUE'
                                          OR l_s_version_type IN ('COST','ALL') AND impact_type_code = 'FINPLAN_COST'));
                    EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                             l_impact_record_exists := 'N';
                    END;

                    -- Bug 3677924 If the impact record does not exist skip processing
                    IF l_impact_record_exists = 'Y' THEN

                        -- Call Copy version API
                        PA_FIN_PLAN_PUB.Copy_Version
                        (p_project_id           => p_project_id,
                         p_source_version_id    => l_source_version_id,
                         p_copy_mode            => PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_WORKING,
                         p_calling_module   => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN,
                         px_target_version_id   => l_target_version_id,
                         x_return_status        => x_return_status,
                         x_msg_count            => x_msg_count,
                         x_msg_data             => x_msg_data);

                         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                            ROLLBACK TO before_fp_ci_copy;
                            RETURN;
                         END IF;
                         l_update_agreement_flag := 'Y';
                         --Stamp the Control item ids for these budget versions
                         UPDATE pa_budget_versions bv
                         SET CI_ID = l_t_fp_ci_id
                         WHERE
                         p_project_id = bv.project_id
                         AND bv.budget_version_id = l_target_version_id
                         AND (NVL(bv.approved_rev_plan_type_flag,'N') = 'Y'
                              OR NVL(bv.approved_cost_plan_type_flag,'N') = 'Y');

                         --Call the update estimated amounts API to update the estimated amounts
                         FP_CI_UPDATE_EST_AMOUNTS
                          (
                            p_project_id         => p_project_id,
                            p_source_version_id       => l_source_version_id,
                            p_target_version_id       => l_target_version_id,
                            p_merge_unmerge_mode => p_merge_unmerge_mode ,
                            p_commit_flag        => 'N' ,
                            p_init_msg_list      => 'N',
                            p_update_agreement        => l_update_agreement_flag,
                            x_return_status      => x_return_status,
                            x_msg_count          => x_msg_count,
                            x_msg_data           => x_msg_data
                          );
                          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                            --------dbms_output.put_line('FP_CI_MERGE_CI_ITEMS - 150****');
                            ROLLBACK TO before_fp_ci_copy;
                            RETURN;
                          END IF;

                    END IF; -- copy only if impact record exists

                EXCEPTION
                    WHEN RAISE_COPY_ERROR THEN
                        x_warning_flag := 'Y';
                        x_return_status := FND_API.G_RET_STS_ERROR;
                END;
                ELSE
                --Merge the source into the target
                    l_source_id_tbl.DELETE;
                    --------dbms_output.put_line('FP_CI_MERGE_CI_ITEMS - 3');
                    l_source_id_tbl(1) := l_source_version_id;
                    l_target_version_id := l_target_version_id_tmp;

                    --Prepare the pl/sql tables for change document
                    l_ci_id_tbl.extend(1);
                    l_ci_id_tbl(1):=l_s_fp_ci_id;
                    l_impl_cost_flag_tbl.extend(1);
                    l_impl_rev_flag_tbl.extend(1);
                    l_impl_cost_flag_tbl(1):='N';
                    l_impl_rev_flag_tbl(1):='N';
                    --Bug 5845142
                    IF l_s_app_cost_flag='Y' THEN
                        l_ci_cost_version_id_tbl.extend(1);
                        l_ci_cost_version_id_tbl(1):=l_source_fp_version_id_tbl(i);--Cost Version
                        l_impl_cost_flag_tbl(1):='Y';
                    ELSIF l_s_app_rev_flag='Y' THEN
                        l_ci_rev_version_id_tbl.extend(1);
                        l_ci_rev_version_id_tbl(1):=l_source_fp_version_id_tbl(i);--Revenue Version
                        l_impl_rev_flag_tbl(1):='Y';
                    END IF;


                    --Prepare pl/sql tbls for target version
                    l_target_version_id_tbl.extend(1);

                    --l_target_version_id_tbl(1):=l_target_fp_version_id_tbl(1);   --Bug 4132915.
                    l_target_version_id_tbl(1) := l_target_version_id;

                    -- Bug 5845142. Moved this code above
                    /* l_impl_cost_flag_tbl(1):='Y';
                    l_impl_rev_flag_tbl(1):='Y'; */

                    implement_change_document
                    (   p_context                       => 'CI_MERGE'
                       ,p_ci_id_tbl                     => l_ci_id_tbl
                       ,p_ci_cost_version_id_tbl        => l_ci_cost_version_id_tbl
                       ,p_ci_rev_version_id_tbl         => l_ci_rev_version_id_tbl
                       ,p_ci_all_version_id_tbl         => l_ci_all_version_id_tbl
                       ,p_budget_version_id_tbl         => l_target_version_id_tbl
                       ,p_impl_cost_flag_tbl            => l_impl_cost_flag_tbl
                       ,p_impl_rev_flag_tbl             => l_impl_rev_flag_tbl
                       ,x_translated_msgs_tbl           => l_translated_msgs_tbl
                       ,x_translated_err_msg_count      => l_translated_err_msg_count
                       ,x_translated_err_msg_level_tbl  => l_translated_err_msg_level_tbl
                       ,x_return_status                 => x_return_status
                       ,x_msg_count                     => x_msg_count
                       ,x_msg_data                      => x_msg_data);
                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        ROLLBACK TO before_fp_ci_copy;
                        --------dbms_output.put_line('FP_CI_MERGE_CI_ITEMS - 11*****');
                        RETURN;
                    END IF;

                    l_update_agreement_flag  := 'N';

                    --Bug 4132915. Passing the correct source and target version id.
                    FP_CI_UPDATE_EST_AMOUNTS
                    (
                      p_project_id          => p_project_id,
                      p_source_version_id    => l_source_id_tbl(1),
                      p_target_version_id    => l_target_version_id_tbl(1),
                      p_merge_unmerge_mode   => p_merge_unmerge_mode ,
                      p_commit_flag              => 'N' ,
                      p_init_msg_list        => 'N',
                      p_update_agreement     => l_update_agreement_flag,
                      x_return_status        => x_return_status,
                      x_msg_count            => x_msg_count,
                      x_msg_data             => x_msg_data
                    );

                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      --------dbms_output.put_line('FP_CI_MERGE_CI_ITEMS - 150****');
                      ROLLBACK TO before_fp_ci_copy;
                      RETURN;
                    END IF;

               END IF;
          END LOOP;
        END IF;
     END IF;
END IF;
IF NVL(p_commit_flag,'N') = 'Y' THEN
     COMMIT;
END IF;
EXCEPTION
     WHEN OTHERS THEN
         ROLLBACK TO before_fp_ci_copy;
         FND_MSG_PUB.add_exc_msg
                  ( p_pkg_name       => 'PA_FP_CI_MERGE.' ||
                   'fp_ci_merge_ci_items'
                   ,p_procedure_name => PA_DEBUG.G_Err_Stack);
    IF p_pa_debug_mode = 'Y' THEN
         PA_DEBUG.g_err_stage := 'Unexpected error in FP_CI_MERGE_CI_ITEMS';
         PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         --------dbms_output.put_line('FP_CI_MERGE_CI_ITEMS - 14');
 IF p_pa_debug_mode = 'Y' THEN
         PA_DEBUG.Reset_Curr_Function;
END IF;
         RAISE;
END FP_CI_MERGE_CI_ITEMS;
-- end of fp_ci_merge_ci_items



/*==================================================================
   This api copies the merged ctrl items from source budget version
   to target budget version.

--###

 r11.5 FP.M Developement ----------------------------------

 08-JAN-2004 jwhite        Bug 3362316

                           Extensively rewrote copy_merged_ctrl_items
                           - INSERT INTO pa_fp_merged_ctrl_items (

 ==================================================================*/

--Bug 4247703. Added the parameter p_calling_context. The valid values are NULL or GENERATION
PROCEDURE copy_merged_ctrl_items
   (  p_project_id            IN   pa_budget_versions.project_id%TYPE
     ,p_source_version_id     IN   pa_budget_versions.budget_version_id%TYPE
     ,p_target_version_id     IN   pa_budget_versions.budget_version_id%TYPE
     ,p_calling_context       IN   VARCHAR2
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_return_status                 VARCHAR2(2000);
l_debug_mode                    VARCHAR2(30);

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_pa_debug_mode = 'Y' THEN
          pa_debug.set_err_stack('PA_FP_CI_MERGE.copy_merged_ctrl_items');
    END IF;
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
    IF p_pa_debug_mode = 'Y' THEN
      pa_debug.set_process('PLSQL','LOG',l_debug_mode);
      -- Check for business rules violations

      pa_debug.g_err_stage:= 'Validating input parameters';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;
      --Check if plan version id is null

      IF (p_project_id        IS NULL) OR
         (p_source_version_id IS NULL) OR
         (p_target_version_id IS NULL)
      THEN
             IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'p_project_id = '|| p_project_id;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                pa_debug.g_err_stage:= 'p_source_version_id = '|| p_source_version_id;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                pa_debug.g_err_stage:= 'p_target_version_id = '|| p_target_version_id;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
             END IF;
                PA_UTILS.ADD_MESSAGE
                       (p_app_short_name => 'PA',
                        p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
             IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'Invalid Arguments Passed';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
            END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      IF NVL(p_calling_context,'GENERATION')<>'GENERATION' THEN

            IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'p_calling_context = '|| p_calling_context;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
            END IF;
                PA_UTILS.ADD_MESSAGE
                       (p_app_short_name => 'PA',
                        p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                         p_token1        => 'PROCEDURENAME',
                         p_value1        => 'PAFPCIMB.copy_merged_ctrl_items',
                         p_token2        => 'STAGE',
                         p_value2        => 'Invalid p_calling_context '||p_calling_context);

                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      --Bug 4247703. When called in generation flow, the CI links in the source should be inserted into the
      --target only if they are not already there in the target. In other flows(copy version) the ci links in the
      --target will be deleted before this API is called and hence the check is not required.

      IF p_calling_context ='GENERATION' THEN

          --Bug 5845142. If approved budget (approved only for cost) is created with "Cost and Revenue together"
          --setup then it is not possible to include change orders. Change orders can only be implemented.
          IF Pa_Fp_Control_Items_Utils.check_valid_combo
             ( p_project_id         => p_project_id
              ,p_targ_app_cost_flag => 'N'
              ,p_targ_app_rev_flag  => 'N') = 'N' THEN

             IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.reset_err_stack;
             END IF;
             RETURN;

          END IF;

          MERGE INTO pa_fp_merged_ctrl_items target
          USING
             (SELECT
                      p_project_id                     project_id
                     ,p_target_version_id              plan_version_id
                     ,pmc.ci_id                        ci_id
                     ,pmc.ci_plan_version_id           ci_plan_version_id
                     ,1                                record_version_number
                     ,sysdate                          creation_date
                     ,fnd_global.user_id               created_by
                     ,fnd_global.login_id              last_update_login
                     ,fnd_global.user_id               last_updated_by
                     ,sysdate                          last_update_date
                     ,'COPIED'                         inclusion_method_code
                     ,pmc.included_by_person_id        included_by_person_id
                     ,pmc.version_type                 version_type
                     ,pmc.impl_proj_func_raw_cost      impl_proj_func_raw_cost
                     ,pmc.impl_proj_func_burdened_cost impl_proj_func_burdened_cost
                     ,pmc.impl_proj_func_revenue       impl_proj_func_revenue
                     ,pmc.impl_proj_raw_cost           impl_proj_raw_cost
                     ,pmc.impl_proj_burdened_cost      impl_proj_burdened_cost
                     ,pmc.impl_proj_revenue            impl_proj_revenue
                     ,pmc.impl_quantity                impl_quantity
                     ,pmc.impl_equipment_quantity      impl_equipment_quantity
                     ,pmc.impl_agr_revenue             impl_agr_revenue
              FROM  pa_fp_merged_ctrl_items pmc,
                    pa_budget_versions sourcever,
                    pa_budget_versions targetver    -- Bug 3720445
              WHERE plan_version_id = p_source_version_id
              AND   sourcever.budget_version_id=p_source_version_id
              AND   targetver.budget_version_id=p_target_version_id   -- Bug 3720445
              AND   pmc.version_type = Decode (targetver.version_type, 'ALL', pmc.version_type,
                                                                        targetver.version_type)
              AND   (sourcever.fin_plan_type_id=targetver.fin_plan_type_id         OR
                     EXISTS (SELECT 1
                             FROM   pa_pt_co_impl_statuses ptco,
                                    pa_control_items pci
                             WHERE  ptco.fin_plan_type_id=targetver.fin_plan_type_id
                             AND    pci.ci_id=pmc.ci_id
                             AND    ptco.ci_type_id=pci.ci_type_id
                             AND    ptco.version_type=pmc.version_type
                             AND    ptco.status_code=pci.status_code))) source
          ON (target.project_id=source.project_id AND
              target.plan_version_id=source.plan_version_id AND
              target.ci_id=source.ci_id AND
              target.ci_plan_version_id=source.ci_plan_version_id AND
              target.version_type=source.version_type)
          WHEN MATCHED THEN
             UPDATE  SET target.last_update_date = sysdate
          WHEN NOT MATCHED THEN
             INSERT(
                    target.project_id
                   ,target.plan_version_id
                   ,target.ci_id
                   ,target.ci_plan_version_id
                   ,target.record_version_number
                   ,target.creation_date
                   ,target.created_by
                   ,target.last_update_login
                   ,target.last_updated_by
                   ,target.last_update_date
                   ,target.inclusion_method_code
                   ,target.included_by_person_id
                   ,target.version_type
                   ,target.impl_proj_func_raw_cost
                   ,target.impl_proj_func_burdened_cost
                   ,target.impl_proj_func_revenue
                   ,target.impl_proj_raw_cost
                   ,target.impl_proj_burdened_cost
                   ,target.impl_proj_revenue
                   ,target.impl_quantity
                   ,target.impl_equipment_quantity
                   ,target.impl_agr_revenue
                   )
            VALUES(
                    source.project_id
                   ,source.plan_version_id
                   ,source.ci_id
                   ,source.ci_plan_version_id
                   ,source.record_version_number
                   ,source.creation_date
                   ,source.created_by
                   ,source.last_update_login
                   ,source.last_updated_by
                   ,source.last_update_date
                   ,source.inclusion_method_code
                   ,source.included_by_person_id
                   ,source.version_type
                   ,source.impl_proj_func_raw_cost
                   ,source.impl_proj_func_burdened_cost
                   ,source.impl_proj_func_revenue
                   ,source.impl_proj_raw_cost
                   ,source.impl_proj_burdened_cost
                   ,source.impl_proj_revenue
                   ,source.impl_quantity
                   ,source.impl_equipment_quantity
                   ,source.impl_agr_revenue);

      ELSE--Calling Context is not GENERATION

          -- Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------
          -- The control items which are partially implemented should not be copied. Bug 3550073
          -- Bug 3720445, 29-JUL-2004: copy based on ci version type and target version type values
          -- Bug 3784823, 29-JUL-2004: It is incorrect not to copy links if ci is partially implemented.
          -- Bug 3882920: Links will be copied only if the target version's plan type allows inclusion of CIs. This
          -- Bug 4493425: Added another condition in the where clause of select to improve performance.
          --check is made only if source/target plan types are different. See bug for details.
          INSERT INTO pa_fp_merged_ctrl_items (
                   project_id
                  ,plan_version_id
                  ,ci_id
                  ,ci_plan_version_id
                  ,record_version_number
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,last_updated_by
                  ,last_update_date
                  ,inclusion_method_code
                  ,included_by_person_id
                  ,version_type
                  ,impl_proj_func_raw_cost
                  ,impl_proj_func_burdened_cost
                  ,impl_proj_func_revenue
                  ,impl_proj_raw_cost
                  ,impl_proj_burdened_cost
                  ,impl_proj_revenue
                  ,impl_quantity
                  ,impl_equipment_quantity
                  ,impl_agr_revenue
                    )
          SELECT
                  p_project_id
                 ,p_target_version_id
                 ,pmc.ci_id
                 ,pmc.ci_plan_version_id
                 ,1
                 ,sysdate
                 ,fnd_global.user_id
                 ,fnd_global.login_id
                 ,fnd_global.user_id
                 ,sysdate
                 ,'COPIED'
                 ,pmc.included_by_person_id
                 ,pmc.version_type
                 ,pmc.impl_proj_func_raw_cost
                 ,pmc.impl_proj_func_burdened_cost
                 ,pmc.impl_proj_func_revenue
                 ,pmc.impl_proj_raw_cost
                 ,pmc.impl_proj_burdened_cost
                 ,pmc.impl_proj_revenue
                 ,pmc.impl_quantity
                 ,pmc.impl_equipment_quantity
                 ,pmc.impl_agr_revenue
          FROM  pa_fp_merged_ctrl_items pmc,
                pa_budget_versions sourcever,
                pa_budget_versions targetver    -- Bug 3720445
          WHERE plan_version_id = p_source_version_id
          AND   sourcever.budget_version_id=p_source_version_id
          AND   targetver.budget_version_id=p_target_version_id   -- Bug 3720445
          AND   pmc.project_id = p_project_id  -- Bug 4493425
          AND   pmc.version_type = Decode (targetver.version_type, 'ALL', pmc.version_type,
                                                                    targetver.version_type)
          AND   (sourcever.fin_plan_type_id=targetver.fin_plan_type_id         OR
                 EXISTS (SELECT 1
                         FROM   pa_pt_co_impl_statuses ptco,
                                pa_control_items pci
                         WHERE  ptco.fin_plan_type_id=targetver.fin_plan_type_id
                         AND    pci.ci_id=pmc.ci_id
                         AND    ptco.ci_type_id=pci.ci_type_id
                         AND    ptco.version_type=pmc.version_type
                         AND    ptco.status_code=pci.status_code)); -- Bug 3720445
          -- Bug 3784823 AND   nvl(civer.rev_partially_impl_flag,'N')  <> 'Y';

          -- End: Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------

      END IF;--IF p_calling_context ='GENERATION' THEN

    IF p_pa_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:= 'Exiting copy_merged_ctrl_items';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      pa_debug.reset_err_stack;
    END IF;

  EXCEPTION

     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

           x_return_status := FND_API.G_RET_STS_ERROR;
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
    IF p_pa_debug_mode = 'Y' THEN
           pa_debug.reset_err_stack;
    END IF;
           RAISE;

   WHEN others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg
                          ( p_pkg_name        => 'PA_FP_CI_MERGE'
                           ,p_procedure_name  => 'copy_merged_ctrl_items'
                           ,p_error_text      => sqlerrm);
     IF p_pa_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          pa_debug.reset_err_stack;
    END IF;
          RAISE;

END copy_merged_ctrl_items;

/*==================================================================
   This api is a wrapper API which is called when the user clicks on
   Mark As Included button on the page. Included for bug 2681589.
 ==================================================================*/
 --Changed the API to accept the additional parameters. It now accepts ci version ids for ci id and the version type
 --of the target.Based on the version type of target either 1 or 2 records will be created in
 --pa_fp_merged_ctrl_items.

 -- bug 3978200  29-0ct-04  Donot throw an error if target version is 'ALL' version and
 -- change order has no cost/revenue impact. Create a record in pa_fp_merged_ctrl_items
 -- only if there is corresponding impact

PROCEDURE FP_CI_MANUAL_MERGE
(
     p_project_id                  IN  NUMBER,
     p_ci_id                       IN  pa_ci_impacts.ci_id%TYPE,
     p_ci_cost_version_id          IN  pa_budget_versions.budget_version_id%TYPE,
     p_ci_rev_version_id           IN  pa_budget_versions.budget_version_id%TYPE,
     p_ci_all_version_id           IN  pa_budget_versions.budget_version_id%TYPE,
     p_t_fp_version_id             IN  pa_budget_versions.budget_version_id%TYPE,
     p_targ_version_type           IN  pa_budget_versions.version_type%TYPE,
     x_return_status               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;

l_update_impact_allowed         varchar2(1);

l_debug_mode                     varchar2(1);
l_s_ci_id                       pa_control_items.ci_id%TYPE;
l_impl_version_type             pa_fp_merged_ctrl_items.version_type%TYPE;

    --This cursor is introduced for bug 3550073. In manual merge a link will be created which
    --indicates that the amounts are copied from the source to the target version. The user has to
    CURSOR c_impl_dtls_csr (c_ci_version_id pa_budget_versions.budget_version_id%TYPE)
    IS
    SELECT pbvs.burdened_cost pfc_burd_cost,
           pbvs.revenue pfc_revenue,
           pbvs.raw_cost pfc_raw_cost,
           pbvs.total_project_raw_cost pc_raw_cost,
           pbvs.total_project_burdened_cost pc_burd_cost,
           pbvs.total_project_revenue pc_revenue,
           DECODE(pbvs.version_type,'REVENUE',NULL,pbvs.labor_quantity) cost_ppl_qty,
           DECODE(pbvs.version_type,'REVENUE',NULL,pbvs.equipment_quantity) cost_equip_qty,
           DECODE(pbvs.version_type,'REVENUE',pbvs.labor_quantity,NULL) rev_ppl_qty,
           DECODE(pbvs.version_type,'REVENUE',pbvs.equipment_quantity,NULL) rev_equip_qty
    FROM   pa_budget_versions pbvs
    WHERE  pbvs.budget_version_id=c_ci_version_id;

    l_impl_dtls_rec   c_impl_dtls_csr%ROWTYPE;

    l_upd_cost_impact_allowed   VARCHAR2(1);
    l_upd_rev_impact_allowed    VARCHAR2(1);
    --Bug 4136386
    l_impact_type_implemented   pa_fp_merged_ctrl_items.version_type%TYPE;
    l_impl_version_type_tbl     SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
      IF l_debug_mode = 'Y' THEN
              pa_debug.set_err_stack('PA_FP_CI_MERGE.FP_CI_MANUAL_MERGE');
              pa_debug.set_process('PLSQL','LOG',l_debug_mode);
      END IF;

      -- Check for business rules violations

      IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Validating input parameters';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                         PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      IF (p_project_id IS NULL) OR
         (p_ci_id is NULL) OR
         (p_t_fp_version_id is NULL) OR
         (p_targ_version_type is NULL) THEN

              IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'p_project_id = '|| p_project_id;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                                 PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        pa_debug.g_err_stage:= 'p_ci_id = '|| p_ci_id;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                                 PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        pa_debug.g_err_stage:= 'p_t_fp_version_id = '|| p_t_fp_version_id;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                                 PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        pa_debug.g_err_stage:= 'p_targ_version_type = '|| p_targ_version_type;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                                 PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
              END IF;
              PA_UTILS.ADD_MESSAGE
                      (p_app_short_name => 'PA',
                       p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                       p_token1         => 'PROCEDURENAME',
                       p_value1         => 'PAFPCIMB.FP_CI_MANUAL_MERGE');
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      --Bug 4136386.If either cost or revenue part of the change order impact has already got implemented then the
      --impact that  got implemented should not be manually merged. This block will find that impact and
      --initialize the variable l_impact_type_implemented accordingly
      SELECT version_type
      BULK COLLECT INTO l_impl_version_type_tbl
      FROM   pa_fp_merged_ctrl_items
      WHERE  project_id=p_project_id
      AND    plan_version_id=p_t_fp_version_id
      AND    ci_id=p_ci_id
      AND    ci_plan_version_id IN ( NVL(p_ci_cost_version_id,-99),NVL(p_ci_rev_version_id,-99),NVL(p_ci_all_version_id,-99))
      AND    version_type IN ('COST','REVENUE');

      IF l_impl_version_type_tbl.COUNT=0 THEN

          l_impact_type_implemented:='NONE';

      ELSIF l_impl_version_type_tbl.COUNT=1 THEN

          l_impact_type_implemented := l_impl_version_type_tbl(1);

      ELSE

          --This is the case where the impact is fully implemented. In this case the api should not have been called
          --at all. Hence throw error.
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                p_token1         => 'PROCEDURENAME',
                p_value1         => 'PAFPCIMB.FP_CI_MANUAL_MERGE',
                p_token2         => 'STAGE',
                p_value2         => 'Manual merge called for a ci which is fully impl.['||p_ci_id||', '||p_t_fp_version_id||']');

          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      IF p_targ_version_type IN ('ALL','COST')
         AND nvl(p_ci_cost_version_id,p_ci_all_version_id) IS NOT NULL -- bug 3978200
         AND l_impact_type_implemented <> 'COST' --Bug 4136386
      THEN
          /* commented for bug 3978200
          IF nvl(p_ci_cost_version_id,p_ci_all_version_id) IS NULL THEN
              IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'p_ci_cost_version_id = '|| p_ci_cost_version_id;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);

                  pa_debug.g_err_stage:= 'p_ci_all_version_id = '|| p_ci_all_version_id;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);

              END IF;
              PA_UTILS.ADD_MESSAGE
                      (p_app_short_name => 'PA',
                       p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                       p_token1         => 'PROCEDURENAME',
                       p_value1         => 'PAFPCIMB.FP_CI_MANUAL_MERGE');
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;
          */

          /* Call FP_CI_LINK_CONTROL_ITEMS*/
          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'B F p_ci_cost_version_id = '|| p_ci_cost_version_id;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);

             pa_debug.g_err_stage:= 'B F p_ci_all_version_id = '|| p_ci_all_version_id;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          END IF;

          OPEN  c_impl_dtls_csr(NVL(p_ci_cost_version_id,p_ci_all_version_id));
          FETCH c_impl_dtls_csr INTO l_impl_dtls_rec ;
          CLOSE c_impl_dtls_csr;

          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'COST - AFTER FETCH of cursor c_impl_dtls_csr';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          END IF;

         --Though all the amounts are passed while calling the FP_CI_LINK_CONTROL_ITEMS, the called API
         --will take care of nulling out the amounts depending on the version type. Nulling out of cost amts
         --for rev vesion types is not done here as it will be easier to put the logic in FP_CI_LINK_CONTROL_ITEMS
          FP_CI_LINK_CONTROL_ITEMS
         (
           p_project_id           => p_project_id
          ,p_s_fp_version_id  => NVL(p_ci_cost_version_id,p_ci_all_version_id)
          ,p_t_fp_version_id  => p_t_fp_version_id
          ,p_inclusion_method => 'MANUAL'
          ,p_included_by     => NULL
          ,p_version_type       => 'COST'
          ,p_ci_id              =>  p_ci_id
          ,p_cost_ppl_qty       => l_impl_dtls_rec.cost_ppl_qty
          ,p_rev_ppl_qty        => NULL
          ,p_cost_equip_qty     => l_impl_dtls_rec.cost_equip_qty
          ,p_rev_equip_qty      => NULL
          ,p_impl_pfc_raw_cost  => l_impl_dtls_rec.pfc_raw_cost
          ,p_impl_pfc_revenue   => NULL
          ,p_impl_pfc_burd_cost => l_impl_dtls_rec.pfc_burd_cost
          ,p_impl_pc_raw_cost   => l_impl_dtls_rec.pc_raw_cost
          ,p_impl_pc_revenue    => NULL
          ,p_impl_pc_burd_cost  => l_impl_dtls_rec.pc_burd_cost
          ,p_impl_agr_revenue   => NULL
          ,x_return_status         => x_return_status
          ,x_msg_count             => x_msg_count
          ,x_msg_data              => x_msg_data
        );

          IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:= 'Error calling FP_CI_LINK_CONTROL_ITEMS';
            pa_debug.write('FP_CI_MANUAL_MERGE: ' || l_module_name,pa_debug.g_err_stage,
                                                                PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;

      END IF;

      IF  p_targ_version_type IN ('ALL','REVENUE')
          AND nvl(p_ci_rev_version_id,p_ci_all_version_id) IS NOT NULL -- bug 3978200
          AND l_impact_type_implemented <> 'REVENUE' --Bug 4136386
      THEN
          /* commented for bug 3978200
          IF nvl(p_ci_rev_version_id,p_ci_all_version_id) IS NULL THEN
              IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'p_ci_rev_version_id = '|| p_ci_rev_version_id;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);

                  pa_debug.g_err_stage:= 'p_ci_all_version_id = '|| p_ci_all_version_id;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);

              END IF;
              PA_UTILS.ADD_MESSAGE
                      (p_app_short_name => 'PA',
                       p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                       p_token1         => 'PROCEDURENAME',
                       p_value1         => 'PAFPCIMB.FP_CI_MANUAL_MERGE');
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;
          */

          IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'B F p_ci_rev_version_id = '|| p_ci_rev_version_id;
              pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);

              pa_debug.g_err_stage:= 'B F p_ci_all_version_id = '|| p_ci_all_version_id;
              pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          END IF;

          /* Call FP_CI_LINK_CONTROL_ITEMS*/
          OPEN  c_impl_dtls_csr(NVL(p_ci_rev_version_id,p_ci_all_version_id));
          FETCH c_impl_dtls_csr INTO l_impl_dtls_rec ;
          CLOSE c_impl_dtls_csr;

          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'REV - AFTER FETCH of cursor c_impl_dtls_csr';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          END IF;

         --Though all the amounts are passed while calling the FP_CI_LINK_CONTROL_ITEMS, the called API
         --will take care of nulling out the amounts depending on the version type. Nulling out of cost amts
         --for rev vesion types is not done here as it will be easier to put the logic in FP_CI_LINK_CONTROL_ITEMS
          FP_CI_LINK_CONTROL_ITEMS
        (
           p_project_id           => p_project_id
          ,p_s_fp_version_id  => NVL(p_ci_rev_version_id,p_ci_all_version_id)
          ,p_t_fp_version_id  => p_t_fp_version_id
          ,p_inclusion_method => 'MANUAL'
          ,p_included_by     => NULL
          ,p_version_type       => 'REVENUE'
          ,p_ci_id              =>  p_ci_id
          ,p_cost_ppl_qty       => NULL
          ,p_rev_ppl_qty        => l_impl_dtls_rec.rev_ppl_qty
          ,p_cost_equip_qty     => NULL
          ,p_rev_equip_qty      => l_impl_dtls_rec.rev_equip_qty
          ,p_impl_pfc_raw_cost  => NULL
          ,p_impl_pfc_revenue   => l_impl_dtls_rec.pfc_revenue
          ,p_impl_pfc_burd_cost => NULL
          ,p_impl_pc_raw_cost   => NULL
          ,p_impl_pc_revenue    => l_impl_dtls_rec.pc_revenue
          ,p_impl_pc_burd_cost  => NULL
          ,p_impl_agr_revenue   => NULL
          ,x_return_status         => x_return_status
          ,x_msg_count             => x_msg_count
          ,x_msg_data              => x_msg_data
        );

          IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:= 'Error calling FP_CI_LINK_CONTROL_ITEMS';
            pa_debug.write('FP_CI_MANUAL_MERGE: ' || l_module_name,pa_debug.g_err_stage,
                                                                PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;
      END IF;

      /*
         call Pa_Fp_Control_Items_Utils.FP_CI_VALIDATE_UPDATE_IMPACT to determine whether we can
      update impact as implemented or not
      */

      Pa_Fp_Control_Items_Utils.FP_CI_VALIDATE_UPDATE_IMPACT
      (
        p_project_id               => p_project_id
       ,p_ci_id                    => p_ci_id
       ,p_source_version_id        => NULL
       ,p_target_version_id        => p_t_fp_version_id
       ,x_upd_cost_impact_allowed  => l_upd_cost_impact_allowed
       ,x_upd_rev_impact_allowed   => l_upd_rev_impact_allowed
       ,x_msg_data                 => x_msg_data
       ,x_msg_count                => x_msg_count
       ,x_return_status            => x_return_status
      );

      IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
            IF  l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'Error calling Pa_Fp_Control_Items_Utils.FP_CI_VALIDATE_UPDATE_IMPACT';
          pa_debug.write('FP_CI_MANUAL_MERGE: ' || l_module_name,pa_debug.g_err_stage,
                                                              PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
            END IF;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'l_update_impact_allowed' || l_update_impact_allowed;
         pa_debug.write('FP_CI_MANUAL_MERGE: ' || l_module_name,pa_debug.g_err_stage,
                                                              PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      /*
     call FP_CI_UPDATE_IMPACT if flag is Y.
     pass only ci id and the status code as we need to only them
     in this case.
      */
      IF l_upd_cost_impact_allowed = 'Y' THEN

          IF p_targ_version_type IN ('ALL','COST') THEN

              FP_CI_UPDATE_IMPACT
              (
                p_ci_id                => p_ci_id
                ,p_status_code          => 'CI_IMPACT_IMPLEMENTED'
                ,p_impact_type_code => 'FINPLAN_COST'
                ,p_commit_flag          => 'Y'
                ,x_return_status   => x_return_status
                ,x_msg_count       => x_msg_count
                ,x_msg_data             => x_msg_data
               );

              IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:= 'Error calling FP_CI_UPDATE_IMPACT';
                    pa_debug.write('FP_CI_MANUAL_MERGE: ' || l_module_name,pa_debug.g_err_stage,
                                                PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
              END IF;
          END IF;

     END IF;

     IF l_upd_rev_impact_allowed = 'Y' THEN

          IF p_targ_version_type IN ('ALL','COST') THEN

              FP_CI_UPDATE_IMPACT
              (
                p_ci_id                => p_ci_id
                ,p_status_code          => 'CI_IMPACT_IMPLEMENTED'
                ,p_impact_type_code => 'FINPLAN_REVENUE'
                ,p_commit_flag          => 'Y'
                ,x_return_status   => x_return_status
                ,x_msg_count       => x_msg_count
                ,x_msg_data             => x_msg_data
               );

              IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:= 'Error calling FP_CI_UPDATE_IMPACT';
                    pa_debug.write('FP_CI_MANUAL_MERGE: ' || l_module_name,pa_debug.g_err_stage,
                                                PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
              END IF;
          END IF;
      END IF; -- update_impact_allowed = 'Y'

      IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Exiting FP_CI_MANUAL_MERGE';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                         PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
              pa_debug.reset_err_stack;

      END IF;

 EXCEPTION

     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

           x_return_status := FND_API.G_RET_STS_ERROR;
           l_msg_count := FND_MSG_PUB.count_msg;

           IF l_msg_count = 1 and x_msg_data IS NULL THEN
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
           IF l_debug_mode = 'Y' THEN
                   pa_debug.reset_err_stack;
           END IF;
           -- RAISE; /* bug 3978200 Directly called from middle tier donot raise */

   WHEN others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          FND_MSG_PUB.add_exc_msg
                          ( p_pkg_name        => 'PA_FP_CI_MERGE'
                           ,p_procedure_name  => 'FP_CI_MANUAL_MERGE'
                           ,p_error_text      => x_msg_data);

          IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
              pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                     PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
              pa_debug.reset_err_stack;

          END IF;
          RAISE;

END FP_CI_MANUAL_MERGE;


-- Start of functions to be used only in implement_ci_into_single_ver API

FUNCTION get_task_id(p_planning_level IN pa_proj_fp_options.cost_fin_plan_level_code%TYPE,
                     p_task_id        IN pa_resource_assignments.task_id%TYPE)
RETURN NUMBER IS
l_temp  NUMBER;
BEGIN
   IF P_PA_DEBUG_MODE='Y' THEN
       pa_debug.write('PAFPCIMB.get_task_id','p_task_id IS '||p_task_id,3);
       pa_debug.write('PAFPCIMB.get_task_id','p_planning_level IS '||p_task_id,3);
   END IF;
   if p_task_id=0 THEN
      return 0;
   END IF;

   FOR kk IN 1..l_src_targ_task_tbl.COUNT LOOP

        IF l_src_targ_task_tbl(kk).key=p_task_id THEN

            RETURN l_src_targ_task_tbl(kk).value;

        END IF;

   END LOOP;

   l_temp := l_src_targ_task_tbl.COUNT +1;
   l_src_targ_task_tbl(l_temp).key:=p_task_id;
   select decode(p_planning_level, 'P',0,'T',pt.top_task_id, pt.task_id)
   into l_src_targ_task_tbl(l_temp).value
   from pa_tasks pt
   where pt.task_id = p_task_id;

   IF P_PA_DEBUG_MODE='Y' THEN
        pa_debug.write('PAFPCIMB.get_task_id','l_src_targ_task_tbl(l_temp).value is '||l_src_targ_task_tbl(l_temp).value,3);
   END IF;
   return  l_src_targ_task_tbl(l_temp).value;
END;

FUNCTION get_mapped_ra_id(p_task_id                IN pa_resource_assignments.task_id%TYPE,
                          p_rlm_id                 IN pa_resource_assignments.resource_list_member_id%TYPE,
                          p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE,
                          p_fin_plan_level_code    IN pa_proj_fp_options.cost_fin_plan_level_code%TYPE
                          )
RETURN NUMBER IS
l_index     NUMBER;
l_task_id  pa_tasks.task_id%TYPE;
l_rlm_id   pa_resource_list_members.resource_list_member_id%TYPE;
BEGIN
     IF p_resource_assignment_id IS NULL AND p_fin_plan_level_code IS NULL THEN

        l_task_id:=p_task_id;
        l_rlm_id:=p_rlm_id;

     ELSE
        SELECT get_task_id(p_fin_plan_level_code,task_id),
               resource_list_member_id
        INTO   l_task_id,
               l_rlm_id
        FROM   pa_resource_assignments
        WHERE  resource_assignment_id=p_resource_assignment_id;
     END IF;

     l_index := 1;
     LOOP
        EXIT WHEN (l_index > l_res_assmt_map_rec_tbl.COUNT) OR
                  ( l_res_assmt_map_rec_tbl(l_index).task_id=l_task_id AND
                    l_res_assmt_map_rec_tbl(l_index).resource_list_member_id=l_rlm_id) ;

        l_index:=l_index+1;

     END LOOP;
     IF (l_index<=l_res_assmt_map_rec_tbl.COUNT) THEN

         RETURN l_res_assmt_map_rec_tbl(l_index).resource_assignment_id;

     ELSE

         RETURN NULL;

     END IF;
END;

FUNCTION get_mapped_dml_code(p_task_id        IN pa_resource_assignments.task_id%TYPE,
                             p_rlm_id         IN pa_resource_assignments.resource_list_member_id%TYPE,
                             p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE,
                             p_fin_plan_level_code    IN pa_proj_fp_options.cost_fin_plan_level_code%TYPE

                             )
RETURN VARCHAR2 IS
l_index    NUMBER;
l_task_id  pa_tasks.task_id%TYPE;
l_rlm_id   pa_resource_list_members.resource_list_member_id%TYPE;

BEGIN
     IF p_resource_assignment_id IS NULL AND p_fin_plan_level_code IS NULL THEN

        l_task_id:=p_task_id;
        l_rlm_id:=p_rlm_id;

     ELSE
        SELECT get_task_id(p_fin_plan_level_code,task_id),
               resource_list_member_id
        INTO   l_task_id,
               l_rlm_id
        FROM   pa_resource_assignments
        WHERE  resource_assignment_id=p_resource_assignment_id;
     END IF;

     l_index := 1;
     LOOP
        EXIT WHEN (l_index > l_res_assmt_map_rec_tbl.COUNT) OR
                  ( l_res_assmt_map_rec_tbl(l_index).task_id=l_task_id AND
                    l_res_assmt_map_rec_tbl(l_index).resource_list_member_id=l_rlm_id) ;

        l_index:=l_index+1;
     END LOOP;
     IF (l_index<=l_res_assmt_map_rec_tbl.COUNT) THEN

         RETURN l_res_assmt_map_rec_tbl(l_index).ra_dml_code;

     ELSE

         RETURN NULL;

     END IF;
END;

-- End of functions to be used only in implement_ci_into_single_ver API

--   Implements the impact of the change order into the target budget version id passed

-- Bug 3934574 Oct 14 2004  Added a new parameter p_calling_context that would be populated when
-- called as part of budget/forecast generation

PROCEDURE implement_ci_into_single_ver(p_context                    IN     VARCHAR2
                                      ,p_calling_context            IN     VARCHAR2                             DEFAULT NULL -- bug 3934574
                                      ,P_ci_id                      IN     Pa_control_items.ci_id%TYPE --  The Id of the chg doc that needs to be implemented
                                      ,P_ci_cost_version_id         IN     Pa_budget_versions.budget_version_id%TYPE  DEFAULT  NULL -- The cost budget version id corresponding to the p_ci_id passed. This will be derived internally if not passed
                                      ,P_ci_rev_version_id          IN     Pa_budget_versions.budget_version_id%TYPE  DEFAULT  NULL -- The rev budget version id corresponding to the p_ci_id passed. This will be derived internally if not passed
                                      ,P_ci_all_version_id          IN     Pa_budget_versions.budget_version_id%TYPE   DEFAULT  NULL -- The all budget_version_id corresponding to the p_ci_id passed. This will be derived internally if not passed
                                      ,P_budget_version_id          IN     Pa_budget_versions.budget_version_id%TYPE -- The Id of the  budget version into which the CO needs to be implemented
                                      ,p_fin_plan_type_id           IN     pa_fin_plan_types_b.fin_plan_type_id%TYPE
                                      ,p_fin_plan_type_name         IN     pa_fin_plan_types_tl.name%TYPE
                                      ,P_partial_impl_rev_amt       IN     NUMBER    DEFAULT  NULL -- The revenue amount that should be implemented into the target. This will be passed only in the case of partial implementation
                                      ,p_cost_impl_flag             IN     VARCHAR2 -- Can be Y or N. Indicates whether cost can be implemented or not.
                                      ,p_rev_impl_flag              IN     VARCHAR2 -- Can be Y or N. Indicates whether rev can be implemented or not.
                                      ,P_submit_version_flag        IN     VARCHAR2 -- Can be Y or N. Indicates whether the version can be submitted for baseline after implementing CO or not.
                                      ,P_agreement_id               IN     Pa_agreements_all.agreement_id%TYPE  DEFAULT  NULL -- The id of the agreement that is linked with the CO.
                                      ,P_update_agreement_amt_flag  IN     VARCHAR2  DEFAULT  NULL -- Indicates whether to  update the agreement amt or not. Null is considered as N
                                      ,P_funding_category           IN     VARCHAR2  DEFAULT  NULL -- The funding category for the agreement
                                      ,p_raTxn_rollup_api_call_flag IN     VARCHAR2 -- Indicates whether the pa_resource_asgn_curr maintenance api should be called
                                      ,x_return_status              OUT    NOCOPY VARCHAR2 -- Indicates the exit status of the API --File.Sql.39 bug 4440895
                                      ,x_msg_data                   OUT    NOCOPY VARCHAR2 -- Indicates the error occurred --File.Sql.39 bug 4440895
                                      ,X_msg_count                  OUT    NOCOPY NUMBER)  -- Indicates the number of error messages --File.Sql.39 bug 4440895
IS

   -- Start of variables used for debugging purpose

     l_msg_count          NUMBER :=0;
     l_data               VARCHAR2(2000);
     l_msg_data           VARCHAR2(2000);
     l_msg_index_out      NUMBER;
     l_return_status      VARCHAR2(2000);
     l_debug_mode         VARCHAR2(1) :=P_PA_DEBUG_MODE;
     l_debug_level3       CONSTANT NUMBER := 3;
     l_debug_level5       CONSTANT NUMBER := 5;
     l_module_name        VARCHAR2(100) := 'PAFPCIMB.implement_ci_into_single_ver' ;
     l_token_name         VARCHAR2(30) :='PROCEDURENAME';
     l_msg_code           VARCHAR2(2000);

     -- End of variables used for debugging purpose

     l_Projfunc_Currency_Code    pa_projects_all.projfunc_currency_code%TYPE := NULL;
     l_Project_Currency_Code     pa_projects_all.project_currency_code%TYPE := NULL;
     l_Txn_Currency_Code         pa_projects_all.projfunc_currency_code%TYPE := NULL;
     l_baseline_funding_flag     pa_projects_all.baseline_funding_flag%TYPE;
     l_cost_impl_flag            VARCHAR2(1);
     l_rev_impl_flag             VARCHAR2(1);
     l_cost_impact_impl_flag     VARCHAR2(1);
     l_rev_impact_impl_flag      VARCHAR2(1);
     l_partially_impl_flag       VARCHAR2(1);
     l_agreement_num             pa_agreements_all.agreement_num%TYPE;
     l_approved_fin_pt_id        pa_fin_plan_types_b.fin_plan_type_id%TYPE;
     l_call_rep_lines_api        VARCHAR2(1):='N';
     l_id_before_bl_insertion    pa_budget_lines.budget_line_id%TYPE;
     l_id_after_bl_insertion     pa_budget_lines.budget_line_id%TYPE;
     l_dummy                     NUMBER;





     I   NUMBER;

     l_fp_version_ids_tbl SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();

     l_src_ver_id_tbl     SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
     l_impl_type_tbl      SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_impl_qty_tbl       SYSTEM.PA_VARCHAR2_1_TBL_TYPE  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();

     l_impact_type_code                 pa_ci_impacts.impact_type_code%TYPE;

     l_record_version_number            pa_budget_versions.record_version_number%TYPE;
     l_partial_factor                   NUMBER := 1;
     l_impl_amt                         pa_fp_merged_ctrl_items.impl_proj_revenue%TYPE;
     l_total_amt                        pa_budget_versions.total_project_revenue%TYPE;
     l_total_amt_in_pfc                 pa_budget_lines.revenue%TYPE;
     l_total_amt_in_pc                  pa_budget_lines.project_revenue%TYPE;

     l_src_proj_fp_options_id           pa_proj_fp_options.proj_fp_options_id%TYPE;
     l_src_multi_curr_flag              pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;
     l_src_fin_plan_type_id             pa_proj_fp_options.fin_plan_type_id%TYPE;
     l_src_time_phased_code             pa_proj_fp_options.cost_time_phased_code%TYPE;
     l_src_report_lbr_hrs_frm_code      pa_proj_fp_options.report_labor_hrs_from_code%TYPE;


     l_targ_proj_fp_options_id          pa_proj_fp_options.proj_fp_options_id%TYPE;
     l_targ_multi_curr_flag             pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;

     l_targ_time_phased_code            pa_proj_fp_options.cost_time_phased_code%TYPE;
     L_REPORT_COST_USING                pa_proj_fp_options.report_labor_hrs_from_code%TYPE;
     l_targ_app_rev_flag                pa_proj_fp_options.report_labor_hrs_from_code%TYPE;
     l_copy_pfc_for_txn_amt_flag        VARCHAR2(1);

     l_project_id                       pa_proj_fp_options.project_id%TYPE;

     l_txn_curr_code_tbl                SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();
     l_src_resource_list_id             pa_proj_fp_options.cost_resource_list_id%TYPE;
     l_targ_resource_list_id            pa_proj_fp_options.cost_resource_list_id%TYPE;
     l_rbs_version_id                   pa_proj_fp_options.rbs_version_id%TYPE;
     l_targ_plan_level_code             pa_proj_fp_options.cost_fin_plan_level_code%TYPE;
     l_src_plan_level_code              pa_proj_fp_options.cost_fin_plan_level_code%TYPE;

     l_txn_source_id_tbl                system.PA_NUM_TBL_TYPE:= system.PA_NUM_TBL_TYPE();
     l_res_list_member_id_tbl           system.PA_NUM_TBL_TYPE:= system.PA_NUM_TBL_TYPE();
     l_rbs_element_id_prm_tbl           system.PA_NUM_TBL_TYPE:= system.PA_NUM_TBL_TYPE();
     l_txn_accum_header_id_prm_tbl      system.PA_NUM_TBL_TYPE:= system.PA_NUM_TBL_TYPE();

 -- for Start bug 5291484
         l_txn_source_id_tbl_1             system.PA_NUM_TBL_TYPE:= system.PA_NUM_TBL_TYPE();
         ltxnaccumheader_id_prm_tbl_1      system.PA_NUM_TBL_TYPE:= system.PA_NUM_TBL_TYPE();
         l_res_list_member_id_tbl_1        system.PA_NUM_TBL_TYPE:= system.PA_NUM_TBL_TYPE();
         l_rbs_element_id_prm_tbl_1        system.PA_NUM_TBL_TYPE:= system.PA_NUM_TBL_TYPE();
-- for End  bug 5291484


     -- Start of tables used to bulk collect and insert into pa_resource_assignments
     L_TARG_RLM_ID_TBL                  SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
     L_TARG_RA_ID_TBL                   SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
     L_RA_DML_CODE_TBL                  SYSTEM.PA_VARCHAR2_15_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
     L_targ_task_id_tbl                 SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
     l_src_ra_id_cnt_tbl                SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
     l_planning_start_date_tbl          SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
     l_planning_end_date_tbl            SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
     l_targ_rbs_element_id_tbl          SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
     l_targ_spread_curve_id_tbl         SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
     l_targ_etc_method_code_tbl         SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_targ_fc_res_type_code_tbl        SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_targ_organization_id_tbl         SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
     l_targ_job_id_tbl                  SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
     l_targ_person_id_tbl               SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
     l_targ_expenditure_type_tbl        SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_targ_expend_category_tbl         SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_targ_rev_category_code_tbl       SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_targ_event_type_tbl              SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_targ_supplier_id_tbl             SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
     l_targ_project_role_id_tbl         SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
     l_targ_resource_type_code_tbl      SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_targ_person_type_code_tbl        SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_targ_non_labor_resource_tbl      SYSTEM.PA_VARCHAR2_20_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_20_TBL_TYPE();
     l_targ_bom_resource_id_tbl         SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
     l_targ_inventory_item_id_tbl       SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
     l_targ_item_category_id_tbl        SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
     l_targ_INCURED_BY_RES_FLAG_tbl     SYSTEM.PA_VARCHAR2_1_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
     l_targ_RATE_BASED_FLAG_tbl         SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_targ_RES_RATE_BASED_FLAG_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE(); --IPM Architecture Enhancement
     l_targ_RESOURCE_CLASS_FLAG_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_targ_NAMED_ROLE_tbl              SYSTEM.PA_VARCHAR2_80_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
     l_targ_txn_accum_header_id_tbl     SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
     l_targ_unit_of_measure_tbl         SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_targ_RESOURCE_CLASS_CODE_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_targ_assignment_description      SYSTEM.PA_VARCHAR2_240_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
     l_targ_mfc_cost_type_id_tbl        SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
     l_targ_RATE_JOB_ID_tbl             SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
     l_targ_RATE_EXPEND_TYPE_tbl        SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_targ_RATE_EXP_FC_CUR_COD_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_targ_RATE_EXPEND_ORG_ID_tbl      SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
     l_targ_INCR_BY_RES_CLS_COD_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_targ_INCUR_BY_ROLE_ID_tbl        SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
     l_targ_sp_fixed_date_tbl           SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE(); -- Bug 8350296

     -- End of tables used to bulk collect and insert into pa_resource_assignments

     --These pl/sql tbls will store the data corresponding to the details such as task_id, rate based flag
     --etc of RAs that have got updated. Bug 3678314.
     l_upd_ra_task_id_tbl               SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
     l_upd_ra_rbs_elem_id_tbl           SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
     l_upd_ra_res_class_code_tbl        SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_upd_ra_rbf_tbl                   SYSTEM.PA_VARCHAR2_1_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
     l_upd_ra_res_asmt_id_tbl           SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();


     l_index                                    NUMBER;
     l_matching_index                           NUMBER;
     -- Start of local Variables for calling get_resource_defaults API
     l_da_resource_list_members_tab             SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
     l_da_resource_class_flag_tab               SYSTEM.PA_VARCHAR2_1_TBL_TYPE:=   SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
     l_da_resource_class_code_tab               SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_da_resource_class_id_tab                 SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
     l_da_res_type_code_tab                     SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_da_person_id_tab                         SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
     l_da_job_id_tab                            SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
     l_da_person_type_code_tab                  SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_da_named_role_tab                        SYSTEM.PA_VARCHAR2_80_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
     l_da_bom_resource_id_tab                   SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
     l_da_non_labor_resource_tab                SYSTEM.PA_VARCHAR2_20_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_20_TBL_TYPE();
     l_da_inventory_item_id_tab                 SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
     l_da_item_category_id_tab                  SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
     l_da_project_role_id_tab                   SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
     l_da_organization_id_tab                   SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
     l_da_fc_res_type_code_tab                  SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_da_expenditure_type_tab                  SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_da_expenditure_category_tab              SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_da_event_type_tab                        SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_da_revenue_category_code_tab             SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_da_supplier_id_tab                       SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
     l_da_spread_curve_id_tab                   SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
     l_da_etc_method_code_tab                   SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_da_mfc_cost_type_id_tab                  SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
     l_da_incurred_by_res_flag_tab              SYSTEM.PA_VARCHAR2_1_TBL_TYPE:=   SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
     l_da_incur_by_res_cls_code_tab             SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_da_incur_by_role_id_tab                  SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
     l_da_unit_of_measure_tab                   SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_da_org_id_tab                            SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
     l_da_rate_based_flag_tab                   SYSTEM.PA_VARCHAR2_1_TBL_TYPE:=   SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
     l_da_rate_expenditure_type_tab             SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_da_rate_func_curr_code_tab               SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_da_incur_by_res_type_tab                 SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();

  --for Start bug 5291484
        lresource_list_members_tab_1             SYSTEM.PA_NUM_TBL_TYPE:= SYSTEM.PA_NUM_TBL_TYPE();
        lresource_class_flag_tab_1               SYSTEM.PA_VARCHAR2_1_TBL_TYPE:=   SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
        lresource_class_code_tab_1               SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
        lresource_class_id_tab_1                 SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
        lres_type_code_tab_1                     SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
        lperson_id_tab_1                         SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
        ljob_id_tab_1                            SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
        lperson_type_code_tab_1                  SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
        lnamed_role_tab_1                        SYSTEM.PA_VARCHAR2_80_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
        lbom_resource_id_tab_1                   SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
        lnon_labor_resource_tab_1                SYSTEM.PA_VARCHAR2_20_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_20_TBL_TYPE();
        linventory_item_id_tab_1                 SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
        litem_category_id_tab_1                  SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
        lproject_role_id_tab_1                   SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
        lorganization_id_tab_1                   SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
        lfc_res_type_code_tab_1                  SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
        lexpenditure_type_tab_1                  SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
        lexpenditure_category_tab_1              SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
        l_da_event_type_tab_1                    SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
        lrevenue_category_code_tab_1             SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
        l_da_supplier_id_tab_1                   SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
        l_da_spread_curve_id_tab_1               SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
        l_da_etc_method_code_tab_1               SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
        l_da_mfc_cost_type_id_tab_1              SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
        lincurred_by_res_flag_tab_1              SYSTEM.PA_VARCHAR2_1_TBL_TYPE:=   SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
        lincur_by_res_cls_code_tab_1             SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
        l_da_incur_by_role_id_tab_1              SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
        l_da_unit_of_measure_tab_1               SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
        l_da_org_id_tab_1                        SYSTEM.PA_NUM_TBL_TYPE:=          SYSTEM.PA_NUM_TBL_TYPE();
        l_da_rate_based_flag_tab_1               SYSTEM.PA_VARCHAR2_1_TBL_TYPE:=   SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
        lrate_expenditure_type_tab_1             SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
        l_da_rate_func_curr_code_tab_1           SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
        l_da_incur_by_res_type_tab_1             SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
        ltxnsrctyp_code_rbs_prm_tbl_1            SYSTEM.pa_varchar2_30_tbl_type:=  SYSTEM.pa_varchar2_30_tbl_type();

   --for End bug 5291484



     -- Endof local Variables for calling get_resource_defaults API

     l_project_structure_version_id       pa_proj_element_versions.parent_structure_version_id%TYPE;

     -- Start of variable to be used in Calculate API Call
     l_line_start_date_tbl         SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
     l_line_end_date_tbl           SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();

     l_currency_code_tbl               SYSTEM.PA_VARCHAR2_15_TBL_TYPE:= SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
     l_total_quantity_tbl              SYSTEM.PA_NUM_TBL_TYPE        := SYSTEM.PA_NUM_TBL_TYPE();
     l_total_raw_cost_tbl              SYSTEM.PA_NUM_TBL_TYPE        := SYSTEM.PA_NUM_TBL_TYPE();
     l_total_burdened_cost_tbl         SYSTEM.PA_NUM_TBL_TYPE        := SYSTEM.PA_NUM_TBL_TYPE();
     l_total_revenue_tbl               SYSTEM.PA_NUM_TBL_TYPE        := SYSTEM.PA_NUM_TBL_TYPE();
     l_cost_rate_tbl                   SYSTEM.PA_NUM_TBL_TYPE        := SYSTEM.PA_NUM_TBL_TYPE();
     l_burden_multiplier_tbl           SYSTEM.PA_NUM_TBL_TYPE        := SYSTEM.PA_NUM_TBL_TYPE();
     l_bill_rate_tbl                   SYSTEM.PA_NUM_TBL_TYPE        := SYSTEM.PA_NUM_TBL_TYPE();
     l_txn_src_typ_code_rbs_prm_tbl    SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
     l_prm_bl_start_date_tbl           SYSTEM.PA_DATE_TBL_TYPE       :=SYSTEM.PA_DATE_TBL_TYPE();
     l_prm_bl_end_date_tbl             SYSTEM.PA_DATE_TBL_TYPE       :=SYSTEM.PA_DATE_TBL_TYPE();
     l_period_name_tbl                 SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
     l_pc_raw_cost_tbl                 SYSTEM.PA_NUM_TBL_TYPE        := SYSTEM.PA_NUM_TBL_TYPE();
     l_pc_burd_cost_tbl                SYSTEM.PA_NUM_TBL_TYPE        := SYSTEM.PA_NUM_TBL_TYPE();
     l_pc_revenue_tbl                  SYSTEM.PA_NUM_TBL_TYPE        := SYSTEM.PA_NUM_TBL_TYPE();
     l_pfc_raw_cost_tbl                SYSTEM.PA_NUM_TBL_TYPE        := SYSTEM.PA_NUM_TBL_TYPE();
     l_pfc_burd_cost_tbl               SYSTEM.PA_NUM_TBL_TYPE        := SYSTEM.PA_NUM_TBL_TYPE();
     l_pfc_revenue_tbl                 SYSTEM.PA_NUM_TBL_TYPE        := SYSTEM.PA_NUM_TBL_TYPE();
     l_cost_rejection_code             SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
     l_revenue_rejection_code          SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
     l_burden_rejection_code           SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
     l_other_rejection_code            SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
     l_pc_cur_conv_rejection_code      SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
     l_pfc_cur_conv_rejection_code     SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
     l_pji_prm_task_id_tbl             SYSTEM.PA_NUM_TBL_TYPE        := SYSTEM.PA_NUM_TBL_TYPE();
     l_pji_prm_rbs_elem_id_tbl         SYSTEM.PA_NUM_TBL_TYPE        := SYSTEM.PA_NUM_TBL_TYPE();
     l_pji_prm_res_cls_code_tbl        SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
     l_pji_prm_rbf_tbl                 SYSTEM.pa_varchar2_1_tbl_type :=SYSTEM.pa_varchar2_1_tbl_type();
     l_upd_bl_id_tbl                   SYSTEM.PA_NUM_TBL_TYPE        := SYSTEM.PA_NUM_TBL_TYPE();
     l_upd_period_name_tbl             SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
     l_upd_currency_code_tbl           SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
     l_upd_bl_start_date_tbl           SYSTEM.PA_DATE_TBL_TYPE       :=SYSTEM.PA_DATE_TBL_TYPE();
     l_upd_bl_end_date_tbl             SYSTEM.PA_DATE_TBL_TYPE       :=SYSTEM.PA_DATE_TBL_TYPE();
     l_upd_cost_rejection_code         SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
     l_upd_revenue_rejection_code      SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
     l_upd_burden_rejection_code       SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
     l_upd_other_rejection_code        SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
     l_upd_pc_cur_conv_rej_code        SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
     l_upd_pfc_cur_conv_rej_code       SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();

     l_res_assignment_id_tbl           SYSTEM.pa_num_tbl_type        := SYSTEM.pa_num_tbl_type();
     l_delete_budget_lines_tbl         SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
     L_SPREAD_AMOUNT_FLAGS_TBL         SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();


      -- End of variable to be used in Calculate API Call



     l_proj_raw_cost          pa_resource_assignments.TOTAL_PROJECT_RAW_COST%TYPE;
     l_proj_burdened_cost     pa_resource_assignments.TOTAL_PROJECT_BURDENED_COST%TYPE;
     l_proj_revenue           pa_resource_assignments.TOTAL_PROJECT_REVENUE%TYPE;

     l_projfunc_raw_cost      pa_resource_assignments.TOTAL_PLAN_RAW_COST%TYPE;
     l_projfunc_burdened_cost pa_resource_assignments.TOTAL_PLAN_BURDENED_COST%TYPE;
     l_projfunc_revenue       pa_resource_assignments.TOTAL_PLAN_REVENUE%TYPE;
     l_labor_quantity         pa_resource_assignments.TOTAL_PLAN_QUANTITY%TYPE;
     l_equip_quantity         pa_resource_assignments.TOTAL_PLAN_QUANTITY%TYPE;




     -- Start of tables prepared to insert/update into pa_budget_lines
     l_bl_RESOURCE_ASIGNMENT_ID_tbl     SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_upd_ra_bl_dml_code_tbl          SYSTEM.PA_VARCHAR2_15_TBL_TYPE := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
     l_bl_START_DATE_tbl               SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
     l_bl_END_DATE_tbl                 SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
     l_bl_PERIOD_NAME_tbl              SYSTEM.PA_VARCHAR2_30_TBL_TYPE :=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_bl_QUANTITY_tbl                 SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_RAW_COST_tbl                 SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_BURDENED_COST_tbl            SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_REVENUE_tbl                  SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_CHANGE_REASON_CODE_tbl       SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_bl_DESCRIPTION_tbl              SYSTEM.PA_VARCHAR2_2000_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
     l_bl_ATTRIBUTE_CATEGORY_tbl       SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_bl_ATTRIBUTE1_tbl               SYSTEM.PA_VARCHAR2_150_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
     l_bl_ATTRIBUTE2_tbl               SYSTEM.PA_VARCHAR2_150_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
     l_bl_ATTRIBUTE3_tbl               SYSTEM.PA_VARCHAR2_150_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
     l_bl_ATTRIBUTE4_tbl               SYSTEM.PA_VARCHAR2_150_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
     l_bl_ATTRIBUTE5_tbl               SYSTEM.PA_VARCHAR2_150_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
     l_bl_ATTRIBUTE6_tbl               SYSTEM.PA_VARCHAR2_150_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
     l_bl_ATTRIBUTE7_tbl               SYSTEM.PA_VARCHAR2_150_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
     l_bl_ATTRIBUTE8_tbl               SYSTEM.PA_VARCHAR2_150_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
     l_bl_ATTRIBUTE9_tbl               SYSTEM.PA_VARCHAR2_150_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
     l_bl_ATTRIBUTE10_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
     l_bl_ATTRIBUTE11_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
     l_bl_ATTRIBUTE12_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
     l_bl_ATTRIBUTE13_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
     l_bl_ATTRIBUTE14_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
     l_bl_ATTRIBUTE15_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
     l_bl_PM_PRODUCT_CODE_tbl          SYSTEM.PA_VARCHAR2_150_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
     l_bl_PM_BUDGET_LINE_REF_tbl       SYSTEM.PA_VARCHAR2_150_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
     l_bl_COST_REJECTION_CODE_tbl      SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_bl_REVENUE_REJ_CODE_tbl         SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_bl_BURDEN_REJECTION_CODE_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_bl_OTHER_REJECTION_CODE_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_bl_CODE_COMBINATION_ID_tbl      SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_CCID_GEN_STATUS_CODE_tbl     SYSTEM.PA_VARCHAR2_1_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
     l_bl_CCID_GEN_REJ_MESSAGE_tbl     SYSTEM.PA_VARCHAR2_2000_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
     l_bl_REQUEST_ID_tbl               SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_BORROWED_REVENUE_tbl         SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_TP_REVENUE_IN_tbl            SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_TP_REVENUE_OUT_tbl           SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_REVENUE_ADJ_tbl              SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_LENT_RESOURCE_COST_tbl       SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_TP_COST_IN_tbl               SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_TP_COST_OUT_tbl              SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_COST_ADJ_tbl                 SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_UNASSIGNED_TIME_COST_tbl     SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_UTILIZATION_PERCENT_tbl      SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_UTILIZATION_HOURS_tbl        SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_UTILIZATION_ADJ_tbl          SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_CAPACITY_tbl                 SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_HEAD_COUNT_tbl               SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_HEAD_COUNT_ADJ_tbl           SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_PROJFUNC_CUR_CODE_tbl        SYSTEM.PA_VARCHAR2_15_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
     l_bl_PROJFUNC_COST_RAT_TYP_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_bl_PJFN_COST_RAT_DAT_TYP_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_bl_PROJFUNC_COST_RAT_DAT_tbl     SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
     l_bl_PROJFUNC_REV_RATE_TYP_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_bl_PJFN_REV_RAT_DAT_TYPE_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_bl_PROJFUNC_REV_RAT_DATE_tbl     SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
     l_bl_PROJECT_COST_RAT_TYPE_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_bl_PROJ_COST_RAT_DAT_TYP_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_bl_PROJ_COST_RATE_DATE_tbl      SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
     l_bl_PROJECT_RAW_COST_tbl         SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_PROJECT_BURDENED_COST_tbl     SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_PROJECT_REV_RATE_TYPE_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_bl_PRJ_REV_RAT_DATE_TYPE_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_bl_PROJECT_REV_RATE_DATE         SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
     l_bl_PROJECT_REVENUE_tbl          SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_TXN_CURRENCY_CODE_tbl        SYSTEM.PA_VARCHAR2_15_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
     l_bl_TXN_RAW_COST_tbl             SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_TXN_BURDENED_COST_tbl        SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_TXN_REVENUE_tbl              SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_BUCKETING_PERIOD_CODE_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_bl_TXN_STD_COST_RATE_tbl        SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_TXN_COST_RATE_OVERIDE_tbl     SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_COST_IND_CMPLD_SET_ID_tbl     SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_TXN_BURDEN_MULTIPLIER_tbl     SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_TXN_BRD_MLTIPLI_OVRID_tbl     SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_TXN_STD_BILL_RATE_tbl        SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_TXN_BILL_RATE_OVERRID_tbl     SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_TXN_MARKUP_PERCENT_tbl       SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_TXN_MRKUP_PER_OVERIDE_tbl     SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_TXN_DISC_PERCENTAGE_tbl      SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_TRANSFER_PRICE_RATE_tbl      SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_BURDEN_COST_RATE_tbl         SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_BURDEN_COST_RAT_OVRID_tbl    SYSTEM.PA_NUM_TBL_TYPE :=          SYSTEM.PA_NUM_TBL_TYPE();
     l_bl_PC_CUR_CONV_REJ_CODE_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_bl_PFC_CUR_CONV_REJ_CODE_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_bl_rbf_flag_tbl                  SYSTEM.PA_VARCHAR2_1_TBL_TYPE:=  SYSTEM.PA_VARCHAR2_1_TBL_TYPE();

     -- End of tables prepared to insert/update into pa_budget_lines

     l_ci_cost_version_id     pa_budget_versions.budget_version_id%TYPE;
     l_ci_rev_version_id      pa_budget_versions.budget_version_id%TYPE;
     l_ci_all_version_id      pa_budget_versions.budget_version_id%TYPE;

     l_etc_start_date         pa_budget_versions.etc_start_date%TYPE;
     L_TARG_APP_COST_FLAG     pa_proj_fp_options.approved_cost_plan_type_flag%TYPE;

     L_SAME_MULTI_CURR_FLAG   VARCHAR2(1);
     l_amt_used_for_rate_calc NUMBER;

      CURSOR c_proj_level_amounts IS
          SELECT nvl(total_project_raw_cost,0)
                ,nvl(total_project_burdened_cost,0)
                ,nvl(total_project_revenue,0)
                ,nvl(raw_cost,0)
                ,nvl(burdened_cost,0)
                ,nvl(revenue,0)
                ,nvl(labor_quantity,0)
                ,nvl(equipment_quantity,0)
           FROM  pa_budget_versions
          WHERE  budget_version_id = p_budget_version_id;


     -- Variables for calling FP_CI_LINK_CONTROL_ITEMS
     l_version_type                  pa_budget_versions.version_type%TYPE;
     l_cost_ppl_qty                  pa_fp_merged_ctrl_items.impl_quantity%TYPE;
     l_rev_ppl_qty                   pa_fp_merged_ctrl_items.impl_quantity%TYPE;
     l_cost_equip_qty                pa_fp_merged_ctrl_items.impl_equipment_quantity%TYPE;
     l_rev_equip_qty                 pa_fp_merged_ctrl_items.impl_equipment_quantity%TYPE;
     l_impl_pfc_raw_cost             pa_fp_merged_ctrl_items.impl_proj_func_raw_cost%TYPE;
     l_impl_pfc_revenue              pa_fp_merged_ctrl_items.impl_proj_func_revenue%TYPE;
     l_impl_pfc_burd_cost            pa_fp_merged_ctrl_items.impl_proj_func_burdened_cost%TYPE;
     l_impl_pc_raw_cost              pa_fp_merged_ctrl_items.impl_proj_raw_cost%TYPE;
     l_impl_pc_revenue               pa_fp_merged_ctrl_items.impl_proj_revenue%TYPE;
     l_impl_pc_burd_cost             pa_fp_merged_ctrl_items.impl_proj_burdened_cost%TYPE;
     l_target_version_type           pa_budget_versions.version_type%TYPE;
     l_baselined_fp_options_id       pa_proj_fp_options.proj_fp_options_id%TYPE;
     l_baselined_version_id          pa_budget_versions.budget_version_id%TYPE;
     l_orig_record_version_number    pa_budget_versions.record_version_number%TYPE;
     l_fc_version_created_flag       VARCHAR2(1);
     l_targ_lab_qty_before_merge     pa_budget_versions.labor_quantity%TYPE;
     l_targ_eqp_qty_before_merge     pa_budget_versions.equipment_quantity%TYPE;
     l_targ_pfc_rawc_before_merge    pa_budget_versions.raw_cost%TYPE;
     l_targ_pfc_burdc_before_merge   pa_budget_versions.burdened_cost%TYPE;
     l_targ_pfc_rev_before_merge     pa_budget_versions.revenue%TYPE;
     l_targ_pc_rawc_before_merge     pa_budget_versions.total_project_raw_cost%TYPE;
     l_targ_pc_burdc_before_merge    pa_budget_versions.total_project_burdened_cost%TYPE;
     l_targ_pc_rev_before_merge      pa_budget_versions.total_project_revenue%TYPE;
     l_targ_lab_qty_after_merge      pa_budget_versions.labor_quantity%TYPE;
     l_targ_eqp_qty_after_merge      pa_budget_versions.equipment_quantity%TYPE;
     l_targ_pfc_rawc_after_merge     pa_budget_versions.raw_cost%TYPE;
     l_targ_pfc_burdc_after_merge    pa_budget_versions.burdened_cost%TYPE;
     l_targ_pfc_rev_after_merge      pa_budget_versions.revenue%TYPE;
     l_targ_pc_rawc_after_merge      pa_budget_versions.total_project_raw_cost%TYPE;
     l_targ_pc_burdc_after_merge     pa_budget_versions.total_project_burdened_cost%TYPE;
     l_targ_pc_rev_after_merge       pa_budget_versions.total_project_revenue%TYPE;
     l_impl_earlier                  VARCHAR2(1);
     l_total_agr_revenue             pa_budget_lines.txn_revenue%TYPE;

     l_partial_impl_rev_amt          NUMBER;
     l_partial_rev_impl_flag         VARCHAR2(1);

     --Variable used for passing ci id to the change management baseline API.
     l_CI_ID_Tab                     PA_PLSQL_DATATYPES.IdTabTyp;
     l_temp                          NUMBER;
     X_Err_Code                      NUMBER;
     l_current_working_flag          pa_budget_versions.current_working_flag%TYPE;

     -- variables introduced for bug 3934574
     l_retain_manual_lines_flag     VARCHAR2(1);

   -- Start of variables declared for bug 4035856
     l_src_delta_amt_adj_task_id    pa_tasks.task_id%TYPE;
     l_targ_delta_amt_adj_rlm_id    pa_resource_list_members.resource_list_member_id%TYPE;
     l_src_delta_amt_adj_ra_id      pa_resource_assignments.resource_assignment_id%TYPE;
     l_src_delta_amt_adj_start_date pa_budget_lines.start_date%TYPE;
     l_pc_revenue_delta             pa_budget_lines.project_revenue%TYPE;
     l_pfc_revenue_delta            pa_budget_lines.revenue%TYPE;
     l_pc_rev_merged                pa_budget_lines.project_revenue%TYPE;
     l_pfc_rev_merged               pa_budget_lines.revenue%TYPE;
     l_pc_rev_for_merge             pa_budget_lines.project_revenue%TYPE;
     l_pfc_rev_for_merge            pa_budget_lines.revenue%TYPE;
     l_src_dummy1                   number;
     l_src_dummy2                   pa_resource_list_members.alias%TYPE;
     l_impl_proj_func_revenue       pa_fp_merged_ctrl_items.impl_proj_func_revenue%TYPE;-- bug 4035856
     l_impl_proj_revenue            pa_fp_merged_ctrl_items.impl_proj_revenue%TYPE;-- bug 4035856
     l_impl_quantity                pa_fp_merged_ctrl_items.impl_quantity%TYPE;-- bug 4035856
     l_agreement_id                 pa_agreements_all.agreement_id%TYPE;
     l_agreement_currency_code      pa_agreements_all.agreement_currency_code%TYPE;
     l_rounded_bl_id                pa_budget_lines.budget_line_id%TYPE;
     l_rounded_bl_rbf               pa_resource_assignments.rate_based_flag%TYPE;
     l_qty_adjusted_flag            VARCHAR2(1);
     --These variables will be used in calling create_ci_impact_fund_lines
     l_impl_pc_rev_amt              NUMBER;
     l_impl_pfc_rev_amt             NUMBER;

     --This variable will be used to call pa_resource_asgn_curr maintenance api
     l_fp_cols_rec                  PA_FP_GEN_AMOUNT_UTILS.FP_COLS;

     -- Cursor to identify resource assignment id against which the adjustment amount should be placed
     -- The idea is to choose the last ra in the edit plan page in the default view for ci version
     -- Added a condition to choose only the RA having the budget lines as the LAST RA.This cursor will be
     -- used in the case when both source and target have the same resource lists.(Please note that any changes
     -- in this cursor might have to be done in src_delta_amt_adj_ra_cur1 also)
     CURSOR src_delta_amt_adj_ra_cur
         (c_budget_version_id pa_budget_versions.budget_version_id%TYPE)IS
     SELECT pra.task_id, pra.resource_list_member_id, pra.resource_assignment_id,
            PA_PROJ_ELEMENTS_UTILS.GET_DISPLAY_SEQUENCE(pra.task_id) as dispSeq, rlm.alias
     FROM   pa_resource_assignments pra, pa_resource_list_members rlm
     WHERE  pra.budget_version_id = c_budget_version_id
     AND    rlm.resource_list_member_id = pra.resource_list_member_id
     AND    EXISTS (SELECT 1
                    FROM   pa_budget_lines pbl
                    WHERE  pbl.resource_assignment_id = pra.resource_assignment_id)
     ORDER BY dispSeq DESC , rlm.alias DESC;

     --This cursor is same as src_delta_amt_adj_ra_cur. This will be used when the source and target
     --have different resource lists.(Please note that any changes in this cursor might have to be
     --done in src_delta_amt_adj_ra_cur also)
     CURSOR src_delta_amt_adj_ra_cur1
         (c_budget_version_id pa_budget_versions.budget_version_id%TYPE)IS
     SELECT pra.task_id, tmp4.resource_list_member_id, pra.resource_assignment_id,
            PA_PROJ_ELEMENTS_UTILS.GET_DISPLAY_SEQUENCE(pra.task_id) as dispSeq, rlm.alias
     FROM   pa_resource_assignments pra, pa_resource_list_members rlm,pa_res_list_map_tmp4 tmp4
     WHERE  pra.budget_version_id = c_budget_version_id
     AND    pra.resource_assignment_id=tmp4.txn_source_id
     AND    rlm.resource_list_member_id = tmp4.resource_list_member_id
     AND    EXISTS (SELECT 1
                    FROM   pa_budget_lines pbl
                    WHERE  pbl.resource_assignment_id = pra.resource_assignment_id)
     ORDER BY dispSeq DESC , rlm.alias DESC;

     -- Cursor to identify against which period/date the adjustment amount should be placed
     -- Note that revenue only change orders can have amounts against agreement currency only.
     CURSOR src_delta_amt_adj_date_cur
         (c_resource_assignment_id pa_resource_assignments.resource_assignment_id%TYPE)IS
     SELECT max(start_date)
     FROM   pa_budget_lines
     WHERE  resource_assignment_id = c_resource_assignment_id;


   -- End of variables declared for bug 4035856

     --For Bug 3980129. These variables will hold the values that indicate whether cost/revenue implementation is OK or NOT
     --l_cost_impl_flag , l_rev_impl_flag will also have the values. But l_rev_impl_flag will be set to N when cost
     --is being impelemented and l_cost_impl_flag will be set to N when revenue is being implemented. If cost gets
     --implemented first then l_rev_impl_flag will be set to l_derv_rev_impl_flag when revenue gets implemented and
     --vice-versa.
     l_derv_cost_impl_flag          VARCHAR2(1);
     l_derv_rev_impl_flag           VARCHAR2(1);

     l_spread_curve_id              pa_spread_curves_b.spread_curve_id%TYPE; -- Bug 8350296

BEGIN
     FND_MSG_PUB.initialize;

     IF p_pa_debug_mode = 'Y' THEN
     pa_debug.set_curr_function( p_function   => 'implement_ci_into_single_ver',
                                     p_debug_mode => P_PA_debug_mode );
     END IF;
     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     SAVEPOINT implement_ci_into_single_ver;

     --dbms_output.put_line('I1');
     IF P_PA_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Entering implement_ci_into_single_ver';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
     END IF;

     --dbms_output.put_line('I2');
     -- Derive the version ids for the change order if none of them is passed
     IF p_ci_cost_version_id IS NULL AND p_ci_rev_version_id IS NULL AND p_ci_all_version_id IS NULL THEN
         IF P_PA_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Calling GET_CI_VERSIONS p_ci_id :'||p_ci_id;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
         END IF;
         Pa_Fp_Control_Items_Utils.GET_CI_VERSIONS
                                          ( p_ci_id                   => p_ci_id
                                           ,X_cost_budget_version_id  => l_ci_cost_version_id
                                           ,X_rev_budget_version_id   => l_ci_rev_version_id
                                           ,X_all_budget_version_id   => l_ci_all_version_id
                                           ,x_return_status           => l_return_status
                                           ,x_msg_count               => l_msg_data
                                           ,x_msg_data                => l_msg_count);

          IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
               IF P_PA_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:= 'Error in GET_CI_VERSIONS';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
               END IF;
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;
     ELSE
          l_ci_cost_version_id     := p_ci_cost_version_id;
          l_ci_rev_version_id      := p_ci_rev_version_id;
          l_ci_all_version_id      := p_ci_all_version_id;

     END IF;

     -- Bug 8350296
     SELECT spread_curve_id INTO l_spread_curve_id
     FROM pa_spread_curves_b
     WHERE spread_curve_code = 'FIXED_DATE';

     --dbms_output.put_line('I3');
     BEGIN
          -- Select the details required from pa_budget_versions so that they can be used in the later part of the code
          SELECT  etc_start_date
                 ,project_id
                 ,version_type
                 ,PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(project_id )
                 ,nvl(labor_quantity,0)
                 ,nvl(equipment_quantity,0)
                 ,nvl(raw_cost,0)
                 ,nvl(burdened_cost,0)
                 ,nvl(revenue,0)
                 ,nvl(total_project_raw_cost,0)
                 ,nvl(total_project_burdened_cost,0)
                 ,nvl(total_project_revenue,0)
                 ,current_working_flag
          into    l_etc_start_date
                 ,l_project_id
                 ,l_target_version_type
                 ,l_project_structure_version_id
                 ,l_targ_lab_qty_before_merge
                 ,l_targ_eqp_qty_before_merge
                 ,l_targ_pfc_rawc_before_merge
                 ,l_targ_pfc_burdc_before_merge
                 ,l_targ_pfc_rev_before_merge
                 ,l_targ_pc_rawc_before_merge
                 ,l_targ_pc_burdc_before_merge
                 ,l_targ_pc_rev_before_merge
                 ,l_current_working_flag
          from   pa_budget_versions
          WHERE budget_version_id = p_budget_version_id;

         IF P_PA_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Fetching l_etc_start_date :'||l_etc_start_date;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

               pa_debug.g_err_stage:= 'Fetching l_project_id :'||l_project_id;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

               pa_debug.g_err_stage:= 'Fetching l_target_version_type :'||l_target_version_type;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

               pa_debug.g_err_stage:= 'Fetching l_project_structure_version_id :'||l_project_structure_version_id;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
         END IF;

          -- Select the details required from pa_projects_all so that they can be used in the later part of the code
          SELECT project_currency_code
                ,projfunc_currency_code
                ,nvl(baseline_funding_flag,'N')
          INTO   l_project_currency_code
                ,l_projfunc_currency_code
                ,l_baseline_funding_flag
          FROM   pa_projects_all
          WHERE  project_id=l_project_id;

         IF P_PA_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Fetching l_project_currency_code :'||l_project_currency_code;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

               pa_debug.g_err_stage:= 'Fetching l_projfunc_currency_code :'||l_projfunc_currency_code;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

               pa_debug.g_err_stage:= 'Fetching l_baseline_funding_flag :'||l_baseline_funding_flag;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
         END IF;

          -- Select the details required from pa_proj_fp_options so that they can be used in the later part of the code
          SELECT proj_fp_options_id,
                 plan_in_multi_curr_flag,
                 nvl(cost_time_phased_code,nvl(revenue_time_phased_code,all_time_phased_code)),
                 margin_derived_from_code,
                 approved_cost_plan_type_flag,
                 approved_rev_plan_type_flag,
                 nvl(cost_resource_list_id,nvl(revenue_resource_list_id,all_resource_list_id)),
                 rbs_version_id,
                 nvl(cost_fin_plan_level_code,nvl(revenue_fin_plan_level_code,all_fin_plan_level_code)),
                 decode(fin_plan_preference_code, 'COST_ONLY',    gen_cost_ret_manual_line_flag,
                                  'REVENUE_ONLY', gen_rev_ret_manual_line_flag,
                                 'COST_AND_REV_SAME', gen_all_ret_manual_line_flag)
          INTO   l_targ_proj_fp_options_id,
                 l_targ_multi_curr_flag,
                 l_targ_time_phased_code,
                 L_REPORT_COST_USING,
                 l_targ_app_cost_flag,
                 l_targ_app_rev_flag,
                 l_targ_resource_list_id,
                 l_rbs_version_id,
                 l_targ_plan_level_code,
                 l_retain_manual_lines_flag -- bug 3934574
          FROM   pa_proj_fp_options
          WHERE  fin_plan_version_id = p_budget_version_id
          AND    fin_plan_type_id    = p_fin_plan_type_id;

          /*l_copy_pfc_for_txn_amt_flag will be set to Y if the amounts can be entered only in project functinal
           *Curreny in target. If the target is a change document then the amounts should always be copied in txn
           *currency and hence the flag will be set to N. If the target is not a change document and if it is a
           *approved revenue version then the amounts should always be copied in project functional currency and
           *hence the flag will be Y.
           */
          l_copy_pfc_for_txn_amt_flag:='N';
          IF p_context = 'CI_MERGE' THEN
               l_copy_pfc_for_txn_amt_flag := 'N';
          ELSIF l_targ_app_rev_flag='Y' THEN
               l_copy_pfc_for_txn_amt_flag :='Y';
          END IF;

         IF P_PA_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Fetching l_targ_proj_fp_options_id :'||l_targ_proj_fp_options_id;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

               pa_debug.g_err_stage:= 'Fetching l_targ_multi_curr_flag :'||l_targ_multi_curr_flag;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

               pa_debug.g_err_stage:= 'Fetching l_targ_time_phased_code :'||l_targ_time_phased_code;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

               pa_debug.g_err_stage:= 'Fetching L_REPORT_COST_USING :'||L_REPORT_COST_USING;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

               pa_debug.g_err_stage:= 'Fetching l_targ_app_cost_flag :'||l_targ_app_cost_flag;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

               pa_debug.g_err_stage:= 'Fetching l_targ_app_rev_flag :'||l_targ_app_rev_flag;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

               pa_debug.g_err_stage:= 'Fetching l_copy_pfc_for_txn_amt_flag :'||l_copy_pfc_for_txn_amt_flag;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

               pa_debug.g_err_stage:= 'Fetching l_targ_resource_list_id :'||l_targ_resource_list_id;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

               pa_debug.g_err_stage:= 'Fetching l_rbs_version_id :'||l_rbs_version_id;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

               pa_debug.g_err_stage:= 'Fetching l_targ_plan_level_code :'||l_targ_plan_level_code;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
       END IF;

     EXCEPTION
          WHEN NO_DATA_FOUND THEN
              IF P_PA_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='NO_DATA_FOUND while getting details required to be used in the later part of the code';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
              END IF;
              RAISE NO_DATA_FOUND;
     END;

     --dbms_output.put_line('I4');
     --Derive cost/rev impl flags if they are passed as null
     IF p_cost_impl_flag IS NULL OR
        p_rev_impl_flag IS NULL THEN

         IF P_PA_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Calling get_impl_details';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
         END IF;

         pa_fp_control_items_utils.get_impl_details
         ( P_fin_plan_type_id       => p_fin_plan_type_id
          ,P_project_id             => l_project_id
          ,P_ci_id                  => p_ci_id
          ,P_ci_cost_version_id     => l_ci_cost_version_id
          ,P_ci_rev_version_id      => l_ci_rev_version_id
          ,P_ci_all_version_id      => l_ci_all_version_id
          ,p_targ_bv_id             => p_budget_version_id
          ,x_cost_impl_flag         => l_cost_impl_flag
          ,x_rev_impl_flag          => l_rev_impl_flag
          ,X_cost_impact_impl_flag  => l_cost_impact_impl_flag
          ,x_rev_impact_impl_flag   => l_rev_impact_impl_flag
          ,x_partially_impl_flag    => l_partially_impl_flag
          ,x_agreement_num          => l_agreement_num
          ,x_approved_fin_pt_id     => l_approved_fin_pt_id
          ,x_return_status          => l_return_status
          ,x_msg_data               => l_msg_data
          ,x_msg_count              => l_msg_count);

          IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
               IF P_PA_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:= 'pa_fp_control_items_utils.get_impl_details returned error';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
               END IF;
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;

     END IF;

    IF P_PA_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:= '--BEFORE IMPL DETAILS-- p_ci_id --'||p_ci_id;
       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

       pa_debug.g_err_stage:= '--BEFORE IMPL DETAILS-- l_cost_impl_flag --'||l_cost_impl_flag;
       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

       pa_debug.g_err_stage:= '--BEFORE IMPL DETAILS-- l_rev_impl_flag --'||l_rev_impl_flag;
       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
    END IF;

     IF p_cost_impl_flag IS NULL THEN

        --This check is required since get_impl_details can assign values other than Y / N to l_cost_impl_flag
        --Refer to the API for the possible values of l_cost_impl_flag
        IF l_cost_impl_flag <>'Y' THEN

            l_cost_impl_flag :='N';

        END IF;

    ELSE

        l_cost_impl_flag:=p_cost_impl_flag;

    END IF;


    -- We will consider the value 'R' as 'Y' for l_rev_impl_flag
    IF p_rev_impl_flag IS NULL THEN

        --This check is required since get_impl_details can assign values other than Y / N to l_rev_impl_flag
        --Refer to the API for the possible values of l_rev_impl_flag
        IF l_rev_impl_flag NOT IN ('Y','R') THEN

            l_rev_impl_flag :='N';

        ELSIF l_rev_impl_flag = 'R' THEN

            l_rev_impl_flag :='Y';
            l_partial_rev_impl_flag := 'R'; --caching this value so that we may use this to skip/execute chunks of code based on its value

        END IF;

    ELSE

        IF p_rev_impl_flag = 'R' THEN
            l_rev_impl_flag:='Y';
            l_partial_rev_impl_flag := 'R'; --caching this value so that we may use this to skip/execute chunks of code based on its value
        ELSE
            l_rev_impl_flag:=p_rev_impl_flag;
        END IF;

    END IF;

    --dbms_output.put_line('I5');

    IF P_PA_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:= '--AFTER IMPL DETAILS-- p_fin_plan_type_id --'||p_fin_plan_type_id;
       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

       pa_debug.g_err_stage:= '--AFTER IMPL DETAILS-- l_project_id --'||l_project_id;
       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

       pa_debug.g_err_stage:= '--AFTER IMPL DETAILS-- p_ci_id --'||p_ci_id;
       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

       pa_debug.g_err_stage:= '--AFTER IMPL DETAILS-- l_ci_cost_version_id --'||l_ci_cost_version_id;
       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

       pa_debug.g_err_stage:= '--AFTER IMPL DETAILS-- l_ci_rev_version_id --'||l_ci_rev_version_id;
       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

       pa_debug.g_err_stage:= '--AFTER IMPL DETAILS-- l_ci_all_version_id --'||l_ci_all_version_id;
       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

       pa_debug.g_err_stage:= '--AFTER IMPL DETAILS-- l_cost_impl_flag --'||l_cost_impl_flag;
       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

       pa_debug.g_err_stage:= '--AFTER IMPL DETAILS-- l_rev_impl_flag --'||l_rev_impl_flag;
       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

       pa_debug.g_err_stage:= '--AFTER IMPL DETAILS-- l_cost_impact_impl_flag --'||l_cost_impact_impl_flag;
       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

       pa_debug.g_err_stage:= '--AFTER IMPL DETAILS-- l_rev_impact_impl_flag --'||l_rev_impact_impl_flag;
       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

       pa_debug.g_err_stage:= '--AFTER IMPL DETAILS-- l_partially_impl_flag --'||l_partially_impl_flag;
       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

       pa_debug.g_err_stage:= '--AFTER IMPL DETAILS-- l_agreement_num --'||l_agreement_num;
       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

       pa_debug.g_err_stage:= '--AFTER IMPL DETAILS-- l_approved_fin_pt_id --'||l_approved_fin_pt_id;
       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
    END IF;

    --Bug 4136238.Moved it to later part of the code
    --l_partial_impl_rev_amt := p_partial_impl_rev_amt; -- Bug 3732446

    I:=1;
    IF l_cost_impl_flag = 'Y' THEN
         l_src_ver_id_tbl.extend();
         l_impl_type_tbl.extend();
         l_impl_qty_tbl.extend();
         l_src_ver_id_tbl(i) := nvl(l_ci_cost_version_id, l_ci_all_version_id);
         l_impl_type_tbl(i) := 'COST';
         l_impl_qty_tbl(i) := 'Y'; -- l_impl_qty_tbl(i) contains whether quantity needs to be implemented or not
         I:= I+1;
    END IF;

    --Bug 5845142. It could be that the COST ci impact is of type ALL. In this case even revenue impact is
    --not considered to be implemented.
    IF l_rev_impl_flag = 'Y' AND
     (NVL(l_ci_all_version_id,-1) <> -1 OR
      NVL(l_ci_rev_version_id,-1) <> -1) THEN
         IF I = 2 THEN
              IF l_src_ver_id_tbl(1) <> nvl(l_ci_all_version_id,-99) THEN -- Bug 3662136
                   l_src_ver_id_tbl.extend();
                   l_impl_type_tbl.extend();
                   l_impl_qty_tbl.extend();
                   l_src_ver_id_tbl(i) :=  l_ci_rev_version_id;
                   l_impl_type_tbl(i) := 'REVENUE';
                   --If the target verison type is ALL then quantity should be merged only with Cost and not with
                   --Revenue.Hence the impl qty should be N.
                   IF l_target_version_type ='ALL' THEN
                       l_impl_qty_tbl(i) := 'N';
                   ELSE
                       l_impl_qty_tbl(i) := 'Y';
                   END IF;
              ELSE
                   l_impl_type_tbl(1) := 'ALL';
              END IF;
         --Only Revenue impact is being implemented. The target should always be of type REVENUE in this case since
         --revenue impact can be implemented either into a ALL or REVENUE version and revenue impact alone can not
         --be implemented into an ALL version
         ELSE
              l_src_ver_id_tbl.extend();
              l_impl_type_tbl.extend();
              l_impl_qty_tbl.extend();
              l_src_ver_id_tbl(i) := nvl(l_ci_rev_version_id, l_ci_all_version_id);
              l_impl_type_tbl(i) := 'REVENUE';
              --Merge quantity while merging either an ALL CI or a REVENUE CI verison into a revenue target version
              l_impl_qty_tbl(i) := 'Y';
         END IF;
    END IF;

    --Bug 3980129. Store the derived values for cost/rev impl flags
    l_derv_cost_impl_flag := l_cost_impl_flag;
    l_derv_rev_impl_flag  := l_rev_impl_flag;
    --dbms_output.put_line('I6');
    -- For each source version id of the change order for which there is an impact
    FOR J IN l_src_ver_id_tbl.FIRST..l_src_ver_id_tbl.LAST LOOP

         --Initialize parital factor to 1. It will be derived later
         l_partial_factor :=1;

         --Bug 3980129.Derive the values for l_cost/rev_impl_flags
         --Bug 4136238. Initialized l_partial_impl_rev_amt only in revenue implementation.
         IF l_impl_type_tbl(J)= 'COST' THEN

              l_cost_impl_flag := l_derv_cost_impl_flag;
              --Bug 5845142. Add revenue amounts to the target version if the source version is of type ALL but
              --is approved only for REVENUE. Note that this does not mean that revenue impact will be
              --implemented into the target version.
              IF l_target_version_type='ALL' AND
                 l_targ_app_cost_flag ='Y' AND
                 l_targ_app_rev_flag='N' THEN

                   l_rev_impl_flag  := 'Y';
              ELSE
                   l_rev_impl_flag  := 'N';
              END IF;
              l_partial_impl_rev_amt := NULL;

         ELSIF l_impl_type_tbl(J)= 'REVENUE' THEN

              l_cost_impl_flag := 'N';
              l_rev_impl_flag  := l_derv_rev_impl_flag;
              l_partial_impl_rev_amt := p_partial_impl_rev_amt;

         ELSIF l_impl_type_tbl(J)= 'ALL' THEN

              l_cost_impl_flag := l_derv_cost_impl_flag;
              l_rev_impl_flag  := l_derv_rev_impl_flag;
              l_partial_impl_rev_amt := p_partial_impl_rev_amt;

         END IF;
         --Delete the lables which will be used for caching
         l_src_targ_task_tbl.delete;
         l_res_assmt_map_rec_tbl.delete;

         l_impl_earlier:='N';

         --One CO  can be implemented more than once into the target version only when it gets
         --implemented partially . IN other cases a case will never arise where this API is called for the
         --same CO and target version combination for more than once for implementing the same impact.
         --In case a CO is getting implemented partially and if a record already exists in pa_fp_mergedc_ctrl_items
         --then that existing record should be updated.
         --The difference between the amounts existing before merge and the resulting amounts after merge
         --will be updated in pa_fp_merged_ctrl_items
         IF  p_context='PARTIAL_REV' OR
         (p_context = 'INCLUDE' AND l_partial_rev_impl_flag = 'R' AND l_impl_type_tbl(j) IN ( 'REVENUE', 'ALL')) THEN

              BEGIN

                  SELECT impl_agr_revenue,
                         nvl(impl_proj_func_revenue,0), -- bug 4035856
                         nvl(impl_proj_revenue,0),      -- bug 4035856
                         nvl(impl_quantity,0)           -- bug 4035856
                  INTO   l_impl_amt,
                         l_impl_proj_func_revenue, -- bug 4035856
                         l_impl_proj_revenue,      -- bug 4035856
                         l_impl_quantity           -- bug 4035856
                  FROM   pa_fp_merged_ctrl_items
                  WHERE  project_id=l_project_id
                  AND    plan_version_id=p_budget_version_id
                  AND    ci_id=p_ci_id
                  AND    ci_plan_version_id=l_src_ver_id_tbl(j)
                  AND    version_type='REVENUE';

                  l_impl_earlier:='Y';
              EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  l_impl_amt:=0;
                  l_impl_proj_func_revenue:=0;
                  l_impl_proj_revenue :=0;
                  l_impl_quantity:=0;
                  l_impl_earlier:='N';
              END;


              IF p_context = 'PARTIAL_REV' OR l_impl_earlier = 'Y' THEN

                  BEGIN
                       SELECT nvl(sum(pbl.txn_revenue),0) total_amt,
                              nvl(sum(pbl.revenue),0) total_amt_in_pfc,
                              nvl(sum(pbl.project_revenue),0) total_amt_in_pc
                       INTO   L_total_amt,
                              l_total_amt_in_pfc,
                              l_total_amt_in_pc
                       FROM   Pa_budget_lines pbl
                       WHERE  pbl.budget_Version_id= l_src_ver_id_tbl(j);
                     --IPM Arch Enhancement Bug 4865563
                        /*
                       and    pbl.cost_rejection_code IS NULL
                       and    pbl.revenue_rejection_code IS NULL
                       and    pbl.burden_rejection_code IS NULL
                       and    pbl.other_rejection_code IS NULL
                       and    pbl.pc_cur_conv_rejection_code IS NULL
                       and    pbl.pfc_cur_conv_rejection_code IS NULL; */


                  IF P_PA_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Fetching l_impl_amt'||l_impl_amt;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

                    pa_debug.g_err_stage:='Fetching L_total_amt'||L_total_amt;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  EXCEPTION
                       WHEN OTHERS THEN
                            IF P_PA_debug_mode = 'Y' THEN
                                  pa_debug.g_err_stage:='Error while getting total and implemented rev ';
                                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                            END IF;
                       RAISE;
                  END;

                  --For bug 3814932
                  IF l_total_amt = 0 THEN

                      l_partial_factor:=1;

                  ELSE

                      --If l_partial_factor is 0 only Resource assignments will be copied. Control will return
                      --from API without copying the budget lines.

                      IF p_context = 'INCLUDE' THEN
                           l_partial_impl_rev_amt := l_total_amt - l_impl_amt;
                      END IF;
                      l_partial_factor:=l_partial_impl_rev_amt/(l_total_amt);

                  END IF;
              END IF;
         END IF;

         --Bug 4136238. The variable l_partial_impl_rev_amt will always(not only in partial impl case) contain the
         --revenue amount in txn currency that will get implemented. The below block of code will take care of
         --populating that variable when the revenue gets implemented fully
         IF  l_impl_type_tbl(J) <>'COST' AND
             (p_context = 'IMPL_FIN_IMPACT' OR
              (p_context = 'INCLUDE' AND l_impl_earlier ='N')) THEN

             IF P_PA_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Deriving l_partial_impl_rev_amt in FULL Rev impl case ';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
             END IF;

             SELECT NVL(sum(txn_revenue),0)
             INTO   l_partial_impl_rev_amt
             FROM   pa_budget_lines
             WHERE  budget_version_id=l_src_ver_id_tbl(j);

             IF P_PA_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='l_partial_impl_rev_amt derived is '||l_partial_impl_rev_amt;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
             END IF;

        END IF;


        IF P_PA_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='l_partial_factor IS '||l_partial_factor;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;


         BEGIN
              SELECT proj_fp_options_id,
                     plan_in_multi_curr_flag,
                     fin_plan_type_id,
                     nvl(cost_time_phased_code,nvl(revenue_time_phased_code,all_time_phased_code)),
                     report_labor_hrs_from_code,
                     nvl(cost_resource_list_id,nvl(revenue_resource_list_id,all_resource_list_id)),
                     nvl(cost_fin_plan_level_code,nvl(revenue_fin_plan_level_code,all_fin_plan_level_code))
              INTO   l_src_proj_fp_options_id,
                     l_src_multi_curr_flag,
                     l_src_fin_plan_type_id,
                     l_src_time_phased_code,
                     l_src_report_lbr_hrs_frm_code,
                     l_src_resource_list_id,
                     l_src_plan_level_code
              FROM   pa_proj_fp_options
              WHERE  fin_plan_version_id = l_src_ver_id_tbl(j);

        IF P_PA_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Fetching l_src_proj_fp_options_id'||l_src_proj_fp_options_id;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

           pa_debug.g_err_stage:='Fetching l_src_multi_curr_flag'||l_src_multi_curr_flag;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

           pa_debug.g_err_stage:='Fetching l_src_fin_plan_type_id'||l_src_fin_plan_type_id;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

           pa_debug.g_err_stage:='Fetching l_src_time_phased_code'||l_src_time_phased_code;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

           pa_debug.g_err_stage:='Fetching l_src_report_lbr_hrs_frm_code'||l_src_report_lbr_hrs_frm_code;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

           pa_debug.g_err_stage:='Fetching l_src_resource_list_id'||l_src_resource_list_id;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

           pa_debug.g_err_stage:='Fetching l_src_plan_level_code'||l_src_plan_level_code;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
        END IF;


         EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   IF P_PA_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:='NO_DATA_FOUND while getting src attributes ';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                   END IF;
              RAISE NO_DATA_FOUND;
         END;

         --dbms_output.put_line('I8');
         -- Add the currencies in the source which are not there already to PA_FP_TXN_CURRENCIES
         IF l_src_multi_curr_flag = 'Y' AND l_targ_multi_curr_flag = 'Y' AND nvl(l_targ_app_rev_flag, 'N') = 'N' THEN

               SELECT ptxn_s.txn_currency_code
               BULK COLLECT INTO l_txn_curr_code_tbl
               FROM    pa_fp_txn_currencies ptxn_s
               WHERE   ptxn_s.proj_fp_options_id=l_src_proj_fp_options_id
               AND     NOT EXISTS (SELECT 'X'
                                   FROM   pa_fp_txn_currencies ptxn_t
                                   WHERE  ptxn_t.proj_fp_options_id=l_targ_proj_fp_options_id
                                   AND    ptxn_t.txn_currency_code=ptxn_s.txn_currency_code);


               IF l_txn_curr_code_tbl.COUNT > 0 THEN
                   For i in l_txn_curr_code_tbl.FIRST..l_txn_curr_code_tbl.LAST LOOP
                        IF P_PA_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage:='INSERTING l_targ_proj_fp_options_id'||l_targ_proj_fp_options_id;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

                           pa_debug.g_err_stage:='INSERTING l_PROJECT_ID'||l_PROJECT_ID;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

                           pa_debug.g_err_stage:='INSERTING p_budget_version_id'||p_budget_version_id;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

                           pa_debug.g_err_stage:='INSERTING l_txn_curr_code_tbl'||l_txn_curr_code_tbl(i);
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                        END IF;
                   END LOOP;
               END IF;

               IF l_txn_curr_code_tbl.COUNT > 0 THEN
                    Forall jj in l_txn_curr_code_tbl.FIRST..l_txn_curr_code_tbl.LAST
                    INSERT INTO PA_FP_TXN_CURRENCIES (
                       fp_txn_currency_id
                       ,proj_fp_options_id
                       ,project_id
                       ,fin_plan_type_id
                       ,fin_plan_version_id
                       ,txn_currency_code
                       ,default_rev_curr_flag
                       ,default_cost_curr_flag
                       ,default_all_curr_flag
                       ,project_currency_flag
                       ,projfunc_currency_flag
                       ,last_update_date
                       ,last_updated_by
                       ,creation_date
                       ,created_by
                       ,last_update_login
                       ,project_cost_exchange_rate
                       ,project_rev_exchange_rate
                       ,projfunc_cost_exchange_Rate
                       ,projfunc_rev_exchange_Rate
                       )
                       VALUES
                       ( pa_fp_txn_currencies_s.NEXTVAL
                       , l_targ_proj_fp_options_id
                       , l_PROJECT_ID
                       , p_fin_plan_type_id
                       , p_budget_version_id
                       , l_txn_curr_code_tbl(jj)
                       , 'N'
                       , 'N'
                       , 'N'
                       , 'N'
                       , 'N'
                       , sysdate
                       , fnd_global.user_id
                       , sysdate
                       , fnd_global.user_id
                       , fnd_global.login_id
                       , NULL
                       , NULL
                       , NULL
                       , NULL);

               END IF; -- l_txn_curr_code_tbl.COUNT > 0
         END IF; -- l_src_multi_curr_flag = 'Y' AND l_targ_multi_curr_flag = 'Y' AND nvl(l_targ_app_rev_flag, 'N') = 'N'

         --dbms_output.put_line('I9');
         IF l_src_resource_list_id <> l_targ_resource_list_id THEN

              -- When the resource lists are different we need to call the mapping API.
              PA_RLMI_RBS_MAP_PUB.Map_Rlmi_Rbs(
              p_budget_version_id           => l_src_ver_id_tbl(j)
             ,p_resource_list_id            => l_targ_resource_list_id
             ,p_calling_process             => 'BUDGET_GENERATION'
             ,p_calling_context             => 'PLSQL'
             ,p_process_code                => 'RES_MAP'
             ,p_calling_mode                => 'BUDGET_VERSION'
             ,p_init_msg_list_flag          => 'N'
             ,p_commit_flag                 => 'N'
             ,x_txn_source_id_tab           => l_txn_source_id_tbl
             ,x_res_list_member_id_tab      => l_res_list_member_id_tbl
             ,x_rbs_element_id_tab          => l_rbs_element_id_prm_tbl
             ,x_txn_accum_header_id_tab     => l_txn_accum_header_id_prm_tbl
             ,x_return_status               => l_return_status
             ,x_msg_count                   => l_msg_count
             ,x_msg_data                    => l_msg_data);

             IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                  IF P_PA_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage:= 'PA_RLMI_RBS_MAP_PUB.Map_Rlmi_Rbs returned error';
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
             END IF;

             -- bug 3934574 In generation context, if retain manual edited lines is 'Y' filter
             -- all RAs with null transaction souce code
             SELECT rlmap.resource_list_member_id -- rlm id for the target
             ,DECODE(prat.resource_assignment_id,null, 'INSERT','UPDATE') --Indicates whether the records needs to be updated/inserted in the target
             ,get_task_id(l_targ_plan_level_code,rlmap.task_id),
              prat.resource_assignment_id,
             decode(COUNT(rlmap.txn_source_id),1,max(rlmap.txn_source_id),null),
             min(LEAST(nvl(prat.planning_start_date, rlmap.planning_start_date),rlmap.planning_start_date)),
             max(GREATEST(nvl(prat.planning_end_date, rlmap.planning_end_date),rlmap.planning_end_date)),
             decode(COUNT(rlmap.txn_source_id),1,max(rlmap.txn_spread_curve_id),null),
             decode(COUNT(rlmap.txn_source_id),1,max(rlmap.sp_fixed_date),null), -- Bug 8350296
             decode(COUNT(rlmap.txn_source_id),1,max(rlmap.txn_etc_method_code),null),
             decode(COUNT(rlmap.txn_source_id),1,max(rlmap.resource_type_code),null),
             decode(COUNT(rlmap.txn_source_id),1,max(rlmap.fc_res_type_code),null),
             decode(COUNT(rlmap.txn_source_id),1,max(rlmap.RESOURCE_CLASS_CODE),null),
             decode(COUNT(rlmap.txn_source_id),1,max(rlmap.organization_id),null),
             decode(COUNT(rlmap.txn_source_id),1,max(rlmap.job_id),null),
             decode(COUNT(rlmap.txn_source_id),1,max(rlmap.person_id),null),
             decode(COUNT(rlmap.txn_source_id),1,max(rlmap.expenditure_type),null),
             decode(COUNT(rlmap.txn_source_id),1,max(rlmap.expenditure_category),null),
             decode(COUNT(rlmap.txn_source_id),1,max(rlmap.revenue_category),null),
             decode(COUNT(rlmap.txn_source_id),1,max(rlmap.event_type),null),
             decode(COUNT(rlmap.txn_source_id),1,max(rlmap.vendor_id),null),
             decode(COUNT(rlmap.txn_source_id),1,max(rlmap.project_role_id),null),
             decode(COUNT(rlmap.txn_source_id),1,max(rlmap.person_type_code),null),
             decode(COUNT(rlmap.txn_source_id),1,max(rlmap.non_labor_resource),null),
             decode(COUNT(rlmap.txn_source_id),1,max(rlmap.bom_resource_id),null),
             decode(COUNT(rlmap.txn_source_id),1,max(rlmap.inventory_item_id),null),
             decode(COUNT(rlmap.txn_source_id),1,max(rlmap.item_category_id),null),
             decode(COUNT(rlmap.txn_source_id),1,max(rlmap.mfc_cost_type_id),null),
             decode(COUNT(rlmap.txn_source_id),1,max(rlmap.INCURRED_BY_RES_FLAG),null),
             decode(COUNT(rlmap.txn_source_id),1,max(rlmap.RESOURCE_CLASS_FLAG),null),
             decode(COUNT(rlmap.txn_source_id),1,max(rlmap.NAMED_ROLE),null),
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             --The below decodes will return the Rate Based Flag(rbf) and unit of measure(uom) for the target
             --resource assignment. These decodes will derive the rbf and uom based on following logic
             ------If multiple source planning transactions are being merged into a single target transaction
             ----------If the all the source planning transactions have same UOM AND RBF then
             --------------if the UOM and RBF are equal to those of target planning transaction then
             ------------------take UOM and RBF from the source
             --------------else
             ------------------take DOLLARS and N for UOM and RBF
             ----------else
             --------------take DOLLARS and N for UOM and RBF
             ------else if there is one to one mapping
             ----------If the UOM and RBF of the source and target plannig transactions are same then
             --------------take UOM and RBF from source
             ----------else
             --------------take DOLLARS and N for UOM and RBF
             ------else if there is no matching target transaction(In this case one should be inserted into target)
             ----------source's RBF and UOM will be compared with the RBF and UOM returned be get_resource_defaults.
             ----------This is done below
             decode(max(rlmap.rbf),
                    min(rlmap.rbf),decode(max(rlmap.uom),
                                          min(rlmap.uom),decode(prat.resource_assignment_id,
                                                                null, max(rlmap.rbf),
                                                                decode(max(rlmap.rbf),
                                                                       max(prat.rate_based_flag),decode(max(rlmap.uom),
                                                                                                        max(prat.unit_of_measure),max(rlmap.rbf),
                                                                                                        'N'),
                                                                      'N')),
                                         'N'),
                    'N'),
               /* bug 5073816: Changed the following */
                max(rlmap.rrbf),  --IPM Arch Enhancement
             decode(max(rlmap.rbf),
                    min(rlmap.rbf),decode(max(rlmap.uom),
                                          min(rlmap.uom),decode(prat.resource_assignment_id,
                                                                null, max(rlmap.uom),
                                                                decode(max(rlmap.rbf),
                                                                       max(prat.rate_based_flag),decode(max(rlmap.uom),
                                                                                                        max(prat.unit_of_measure),max(rlmap.uom),
                                                                                                        'DOLLARS'),
                                                                      'DOLLARS')),
                                         'DOLLARS'),
                    'DOLLARS'),
             --Bug 3752352. If the resource lists are differnt then initialise the rbs element id and
             --txn accum header tbls .
             NULL,
             NULL
             BULK COLLECT INTO
               L_targ_rlm_id_tbl,
               L_ra_dml_code_tbl,
               L_targ_task_id_tbl,
               L_targ_ra_id_tbl,
               l_src_ra_id_cnt_tbl,
               l_planning_start_date_tbl,
               l_planning_end_date_tbl,
               l_targ_spread_curve_id_tbl,
               l_targ_sp_fixed_date_tbl, -- Bug 8350296
               l_targ_etc_method_code_tbl,
               l_targ_resource_type_code_tbl,
               l_targ_fc_res_type_code_tbl,
               l_targ_RESOURCE_CLASS_CODE_tbl,
               l_targ_organization_id_tbl,
               l_targ_job_id_tbl,
               l_targ_person_id_tbl,
               l_targ_expenditure_type_tbl,
               l_targ_expend_category_tbl,
               l_targ_rev_category_code_tbl,
               l_targ_event_type_tbl,
               l_targ_supplier_id_tbl,
               l_targ_project_role_id_tbl,
               l_targ_person_type_code_tbl,
               l_targ_non_labor_resource_tbl,
               l_targ_bom_resource_id_tbl,
               l_targ_inventory_item_id_tbl,
               l_targ_item_category_id_tbl,
               l_targ_mfc_cost_type_id_tbl,
               l_targ_INCURED_BY_RES_FLAG_tbl,
               l_targ_RESOURCE_CLASS_FLAG_tbl,
               l_targ_NAMED_ROLE_tbl ,
               l_targ_RATE_EXPEND_TYPE_tbl,
               l_targ_RATE_EXP_FC_CUR_COD_tbl,
               l_targ_RATE_EXPEND_ORG_ID_tbl,
               l_targ_INCR_BY_RES_CLS_COD_tbl,
               l_targ_INCUR_BY_ROLE_ID_tbl,
               l_targ_RATE_BASED_FLAG_tbl,
               l_targ_RES_RATE_BASED_FLAG_tbl, --IPM Arch Enhancement
               l_targ_unit_of_measure_tbl,
               l_targ_rbs_element_id_tbl,
               l_targ_txn_accum_header_id_tbl

             FROM    Pa_resource_assignments prat,
                     (SELECT
                       rlmap.txn_spread_curve_id,
                       rlmap.txn_etc_method_code,
                       rlmap.resource_type_code,
                       rlmap.fc_res_type_code,
                       rlmap.RESOURCE_CLASS_CODE,
                       rlmap.organization_id,
                       rlmap.job_id,
                       rlmap.person_id,
                       rlmap.expenditure_type,
                       rlmap.expenditure_category,
                       rlmap.revenue_category,
                       rlmap.event_type,
                       rlmap.vendor_id,
                       rlmap.project_role_id,
                       rlmap.person_type_code,
                       rlmap.non_labor_resource,
                       rlmap.bom_resource_id,
                       rlmap.inventory_item_id,
                       rlmap.item_category_id,
                       rlmap.mfc_cost_type_id,
                       rlmap.INCURRED_BY_RES_FLAG,
                       rlmap.TXN_RATE_BASED_FLAG,
                       rlmap.RESOURCE_CLASS_FLAG,
                       rlmap.NAMED_ROLE,
                       rlmap.txn_source_id,
                       rlmap.resource_list_member_id,
                       pra.planning_start_date,
                       pra.planning_end_date,
                       pra.task_id,
                       pra.rate_based_flag as rbf,
                       pra.resource_rate_based_flag as rrbf,    --IPM Arch Enhancement
                       pra.unit_of_measure as uom,
                       pra.sp_fixed_date AS sp_fixed_date -- Bug 8350296
                      FROM
                       pa_resource_assignments pra,
                       pa_res_list_map_tmp4 rlmap
                      WHERE
                       pra.resource_assignment_id=rlmap.txn_source_id)rlmap
             WHERE   prat.budget_version_id(+)=p_budget_version_id
             AND     prat.resource_list_member_id(+)=rlmap.resource_list_member_id
             AND     prat.task_id(+)=get_task_id(l_targ_plan_level_code,rlmap.task_id)
             AND     prat.project_assignment_id(+)=-1
/* Bug 7287101 - skkoppul - commented
             AND     (prat.resource_assignment_id is null  --> target ra doesnot exist
                      OR decode(p_calling_context,
                                 'BUDGET_GENERATION', decode(l_retain_manual_lines_flag, 'Y', prat.transaction_source_code, 'x'),
                                 'FORECAST_GENERATION', decode(l_retain_manual_lines_flag, 'Y', prat.transaction_source_code, 'x'),
                                   -99) is not null) -- bug 3934574 */
             GROUP BY get_task_id(l_targ_plan_level_code,rlmap.task_id) ,
                      rlmap.resource_list_member_id, prat.resource_assignment_id;
        ELSE

            IF P_PA_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'About to select the RAs with same res list for INS/UPD';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;

             -- bug 3934574 In generation context, if retain manual edited lines is 'Y' filter
             -- all RAs with null transaction souce code
             SELECT pras.resource_list_member_id -- rlm id for the target
             ,DECODE(prat.resource_assignment_id,null, 'INSERT','UPDATE') --Indicates whether the records needs to be updated/inserted in the target
             , get_task_id(l_targ_plan_level_code,pras.task_id),
                prat.resource_assignment_id,
             decode(COUNT(pras.resource_assignment_id),1,max(pras.resource_assignment_id),null),
             min(LEAST(nvl(prat.planning_start_date, pras.planning_start_date),pras.planning_start_date)),
             max(GREATEST(nvl(prat.planning_end_date, pras.planning_end_date),pras.planning_end_date)),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.rbs_element_id),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.spread_curve_id),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.sp_fixed_date),null), -- Bug 8350296
             decode(COUNT(pras.resource_assignment_id),1,max(pras.etc_method_code),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.fc_res_type_code),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.organization_id),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.job_id),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.person_id),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.expenditure_type),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.expenditure_category),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.revenue_category_code),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.event_type),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.supplier_id),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.project_role_id),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.res_type_code),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.person_type_code),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.non_labor_resource),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.bom_resource_id),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.inventory_item_id),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.item_category_id),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.INCURRED_BY_RES_FLAG),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.RESOURCE_CLASS_FLAG),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.NAMED_ROLE),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.TXN_ACCUM_HEADER_ID),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.RESOURCE_CLASS_CODE),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.ASSIGNMENT_DESCRIPTION),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.MFC_COST_TYPE_ID),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.RATE_JOB_ID),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.RATE_EXPENDITURE_TYPE),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.RATE_EXP_FUNC_CURR_CODE),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.RATE_EXPENDITURE_ORG_ID),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.INCUR_BY_RES_CLASS_CODE),null),
             decode(COUNT(pras.resource_assignment_id),1,max(pras.INCUR_BY_ROLE_ID),null),
             --The below decodes will return the Rate Based Flag(rbf) and unit of measure(uom) for the target
             --resource assignment. These decodes will derive the rbf and uom based on following logic
             ------If multiple source planning transactions are being merged into a single target transaction
             ----------If the all the source planning transactions have same UOM AND RBF then
             --------------if the UOM and RBF are equal to those of target planning transaction then
             ------------------take UOM and RBF from the source
             --------------else
             ------------------take DOLLARS and N for UOM and RBF
             ----------else
             --------------take DOLLARS and N for UOM and RBF
             ------else if there is one to one mapping
             ----------If the UOM and RBF of the source and target plannig transactions are same then
             --------------take UOM and RBF from source
             ----------else
             --------------take DOLLARS and N for UOM and RBF
             ------else if there is no matching target transaction(In this case one should be inserted into target)
             ----------source's RBF and UOM will be compared with the RBF and UOM returned be get_resource_defaults.
             ----------This is done below
             decode(max(pras.rate_based_flag),
                    min(pras.rate_based_flag),decode(max(pras.unit_of_measure),
                                                     min(pras.unit_of_measure),decode(prat.resource_assignment_id,
                                                                                      null,  max(pras.rate_based_flag),
                                                                                      decode(max(pras.rate_based_flag),
                                                                                             max(prat.rate_based_flag),decode(max(pras.unit_of_measure),
                                                                                                                              max(prat.unit_of_measure),max(pras.rate_based_flag),
                                                                                                                              'N'),
                                                                                             'N')),
                                                    'N'),
                    'N'),
            /* bug 5073816: Changed the following */
                max(pras.resource_rate_based_flag),    --IPM Arch Enhancement Bug 4865563
             decode(max(pras.rate_based_flag),
                    min(pras.rate_based_flag),decode(max(pras.unit_of_measure),
                                                     min(pras.unit_of_measure),decode(prat.resource_assignment_id,
                                                                                      null,  max(pras.unit_of_measure),
                                                                                      decode(max(pras.rate_based_flag),
                                                                                             max(prat.rate_based_flag),decode(max(pras.unit_of_measure),
                                                                                                                              max(prat.unit_of_measure),max(pras.unit_of_measure),
                                                                                                                              'DOLLARS'),
                                                                                             'DOLLARS')),
                                                     'DOLLARS'),
                   'DOLLARS')
             BULK COLLECT INTO
               L_targ_rlm_id_tbl,
               L_ra_dml_code_tbl,
               L_targ_task_id_tbl,
               L_targ_ra_id_tbl,
               l_src_ra_id_cnt_tbl,
               l_planning_start_date_tbl,
               l_planning_end_date_tbl,
               l_targ_rbs_element_id_tbl,
               l_targ_spread_curve_id_tbl,
               l_targ_sp_fixed_date_tbl, -- Bug 8350296
               l_targ_etc_method_code_tbl,
               l_targ_fc_res_type_code_tbl,
               l_targ_organization_id_tbl,
               l_targ_job_id_tbl,
               l_targ_person_id_tbl,
               l_targ_expenditure_type_tbl,
               l_targ_expend_category_tbl,
               l_targ_rev_category_code_tbl,
               l_targ_event_type_tbl,
               l_targ_supplier_id_tbl,
               l_targ_project_role_id_tbl,
               l_targ_resource_type_code_tbl,
               l_targ_person_type_code_tbl,
               l_targ_non_labor_resource_tbl,
               l_targ_bom_resource_id_tbl,
               l_targ_inventory_item_id_tbl,
               l_targ_item_category_id_tbl,
               l_targ_INCURED_BY_RES_FLAG_tbl,
               l_targ_RESOURCE_CLASS_FLAG_tbl,
               l_targ_NAMED_ROLE_tbl,
               l_targ_txn_accum_header_id_tbl,
               l_targ_RESOURCE_CLASS_CODE_tbl,
               l_targ_assignment_description,
               l_targ_mfc_cost_type_id_tbl,
               l_targ_RATE_JOB_ID_tbl,
               l_targ_RATE_EXPEND_TYPE_tbl,
               l_targ_RATE_EXP_FC_CUR_COD_tbl,
               l_targ_RATE_EXPEND_ORG_ID_tbl,
               l_targ_INCR_BY_RES_CLS_COD_tbl,
               l_targ_INCUR_BY_ROLE_ID_tbl,
               l_targ_RATE_BASED_FLAG_tbl,
               l_targ_RES_RATE_BASED_FLAG_tbl,    --IPM Arch Enhancement Bug 4865563
               l_targ_unit_of_measure_tbl
             FROM    pa_resource_assignments pras,
                     Pa_resource_assignments prat
             WHERE   pras.budget_version_id=l_src_ver_id_tbl(j)
             AND     prat.budget_version_id(+)=p_budget_version_id
             AND     prat.resource_list_member_id(+)=pras.resource_list_member_id
             AND     prat.task_id(+)=get_task_id(l_targ_plan_level_code,pras.task_id)
             AND     prat.project_assignment_id(+)=-1
/* Bug 7287101 - skkoppul - commented
             AND     (prat.resource_assignment_id is null --> target ra doesnot exist
                      OR decode(p_calling_context,
                                 'BUDGET_GENERATION', decode(l_retain_manual_lines_flag, 'Y', prat.transaction_source_code, 'x'),
                                 'FORECAST_GENERATION', decode(l_retain_manual_lines_flag, 'Y', prat.transaction_source_code, 'x'),
                                   -99) is not null) -- bug 3934574 */
             GROUP BY get_task_id(l_targ_plan_level_code,pras.task_id) , pras.resource_list_member_id,
                       prat.resource_assignment_id;

            IF P_PA_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= ' selected the RAs with same res list for INS/UPD '||l_targ_ra_id_tbl.count;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;

        END IF;

        IF P_PA_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= ' Collected the Target Ras that should either be ins or upd. Count is '||l_targ_ra_id_tbl.count;
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;

         --dbms_output.put_line('I10 '||l_targ_ra_id_tbl.COUNT);

        IF l_targ_ra_id_tbl.COUNT >0 THEN

            --The variable can be made Y now as there are some resource assignments that can be merged. Note that even if this variable is Y
            --the reporting lines API will not be called if calculate API is called in the flow
            l_call_rep_lines_api:='Y';

             --dbms_output.put_line('I11');

            /* Store the values for target task id, target rlm id and target resource assignment id in the form of a record.
               so that it will be easy later to identify the  resource assignment id corresponding to the given task id
               and resource list member id*/
            FOR ind IN L_targ_ra_id_tbl.FIRST..L_targ_ra_id_tbl.LAST LOOP
                  IF L_targ_ra_id_tbl(ind) IS NULL THEN
                       SELECT pa_resource_assignments_s.nextval
                       INTO L_targ_ra_id_tbl(ind)
                       FROM dual;
                  END IF;
                  l_res_assmt_map_rec_tbl(ind).task_id:=l_targ_task_id_tbl(ind);
                  l_res_assmt_map_rec_tbl(ind).resource_list_member_id:=l_targ_rlm_id_tbl(ind);
                  l_res_assmt_map_rec_tbl(ind).resource_assignment_id:=L_targ_ra_id_tbl(ind);
                  l_res_assmt_map_rec_tbl(ind).ra_dml_code:=L_ra_dml_code_tbl(ind);
            END LOOP;

            l_da_resource_list_members_tab:=SYSTEM.PA_NUM_TBL_TYPE();
            l_txn_src_typ_code_rbs_prm_tbl :=SYSTEM.pa_varchar2_30_tbl_type();

            --dbms_output.put_line('I12');
            IF l_src_resource_list_id = l_targ_resource_list_id THEN
                  --Calling resource default API

                   --dbms_output.put_line('I13');
                   FOR kk in 1 .. L_targ_rlm_id_tbl.count LOOP

                       --Find the distinct rlms among the resoruce assignments that have to be inserted .
                       --This is done to call get_resource_defaults only for distinct rlms. Bug 3859738
                       IF   L_ra_dml_code_tbl(kk) = 'INSERT'
                       AND l_src_ra_id_cnt_tbl(KK) IS NULL THEN

                            l_temp:= NULL;
                            FOR LL IN 1..l_da_resource_list_members_tab.COUNT LOOP
                                IF l_da_resource_list_members_tab(LL)= L_targ_rlm_id_tbl(kk) THEN
                                    l_temp:=LL;
                                    EXIT;
                                END IF;
                            END LOOP;

                            IF l_temp IS NULL THEN
                                --Indicates that the resource list member is not already selected and hence it has to be
                                --considered while calling get_resource_defaults.Bug 3859738

                                l_da_resource_list_members_tab.extend;
                                l_da_resource_list_members_tab(l_da_resource_list_members_tab.COUNT) := L_targ_rlm_id_tbl(kk);
                                l_txn_src_typ_code_rbs_prm_tbl.extend;
                                l_txn_src_typ_code_rbs_prm_tbl(l_txn_src_typ_code_rbs_prm_tbl.COUNT):='RES_ASSIGNMENT';
                            END IF;
--for Start Bug 5291484
                          ELSIF L_ra_dml_code_tbl(kk) = 'INSERT'
                          AND l_src_ra_id_cnt_tbl(KK) IS NOT NULL THEN

                               l_temp := NULL; --Bug 5532905.
                               FOR LL IN 1..lresource_list_members_tab_1.COUNT LOOP
                                   IF lresource_list_members_tab_1(LL)= L_targ_rlm_id_tbl(kk) THEN
                                       l_temp:=LL;
                                       EXIT;
                                   END IF;
                               END LOOP;

                                  IF P_PA_debug_mode = 'Y' THEN
                                         pa_debug.g_err_stage:= 'before check l_temp ' || l_temp;
                                         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                  END IF;

                               IF l_temp IS NULL THEN
                                   lresource_list_members_tab_1.extend;
                                   lresource_list_members_tab_1(lresource_list_members_tab_1.COUNT) := L_targ_rlm_id_tbl(kk);
                                   ltxnsrctyp_code_rbs_prm_tbl_1.extend;
                                   ltxnsrctyp_code_rbs_prm_tbl_1(ltxnsrctyp_code_rbs_prm_tbl_1.COUNT) := 'RES_ASSIGNMENT';
                                   lperson_id_tab_1.extend;
                                   lperson_id_tab_1(lperson_id_tab_1.COUNT) := l_targ_person_id_tbl(kk);
                                   ljob_id_tab_1.extend;
                                   ljob_id_tab_1(ljob_id_tab_1.COUNT) := l_targ_job_id_tbl(kk);
                                   lorganization_id_tab_1.extend;
                                   lorganization_id_tab_1(lorganization_id_tab_1.COUNT) := l_targ_organization_id_tbl(kk);
                                   l_da_supplier_id_tab_1.extend;
                                   l_da_supplier_id_tab_1(l_da_supplier_id_tab_1.COUNT) := l_targ_supplier_id_tbl(kk);
                                   lexpenditure_type_tab_1.extend;
                                   lexpenditure_type_tab_1(lexpenditure_type_tab_1.COUNT) := l_targ_expenditure_type_tbl(kk);
                                   l_da_event_type_tab_1.extend;
                                   l_da_event_type_tab_1(l_da_event_type_tab_1.COUNT) := l_targ_event_type_tbl(kk);
                                   lnon_labor_resource_tab_1.extend;
                                   lnon_labor_resource_tab_1(lnon_labor_resource_tab_1.COUNT) := l_targ_non_labor_resource_tbl(kk);
                                   lexpenditure_category_tab_1.extend;
                                   lexpenditure_category_tab_1(lexpenditure_category_tab_1.COUNT) := l_targ_expend_category_tbl(kk);
                                   lrevenue_category_code_tab_1.extend;
                                   lrevenue_category_code_tab_1(lrevenue_category_code_tab_1.COUNT) := l_targ_rev_category_code_tbl(kk);
                                   lproject_role_id_tab_1.extend;
                                   lproject_role_id_tab_1(lproject_role_id_tab_1.COUNT) := l_targ_project_role_id_tbl(kk);
                                   lresource_class_code_tab_1.extend;
                                   lresource_class_code_tab_1(lresource_class_code_tab_1.COUNT) := l_targ_RESOURCE_CLASS_CODE_tbl(kk);
                                   l_da_mfc_cost_type_id_tab_1.extend;
                                   l_da_mfc_cost_type_id_tab_1(l_da_mfc_cost_type_id_tab_1.COUNT) := l_targ_mfc_cost_type_id_tbl(kk);
                                   lresource_class_flag_tab_1.extend;
                                   lresource_class_flag_tab_1(lresource_class_flag_tab_1.COUNT) := l_targ_resource_class_flag_tbl(kk);
                                   lfc_res_type_code_tab_1.extend;
                                   lfc_res_type_code_tab_1(lfc_res_type_code_tab_1.COUNT) := l_targ_fc_res_type_code_tbl(kk);
                                   linventory_item_id_tab_1.extend;
                                   linventory_item_id_tab_1(linventory_item_id_tab_1.COUNT) := l_targ_inventory_item_id_tbl(kk);
                                   litem_category_id_tab_1.extend;
                                   litem_category_id_tab_1(litem_category_id_tab_1.COUNT) := l_targ_item_category_id_tbl(kk);
                                   lperson_type_code_tab_1.extend;
                                   lperson_type_code_tab_1(lperson_type_code_tab_1.COUNT) :=  l_targ_person_type_code_tbl(kk);
                                   lbom_resource_id_tab_1.extend;
                                   lbom_resource_id_tab_1(lbom_resource_id_tab_1.COUNT) := l_targ_bom_resource_id_tbl(kk);
                                   lnamed_role_tab_1.extend;
                                   lnamed_role_tab_1(lnamed_role_tab_1.COUNT) := l_targ_NAMED_ROLE_tbl(kk);
                                   lincurred_by_res_flag_tab_1.extend;
                                   lincurred_by_res_flag_tab_1(lincurred_by_res_flag_tab_1.COUNT) := l_targ_incured_by_res_flag_tbl(kk);
                                   l_da_rate_based_flag_tab_1.extend;
                                   l_da_rate_based_flag_tab_1(l_da_rate_based_flag_tab_1.COUNT) := l_targ_rate_based_flag_tbl(kk);
                               END IF;
   --for End Bug 5291484

                       END IF;
                   END LOOP;

                   IF P_PA_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:= 'Calling res defaults with l_da_resource_list_members_tab '||l_da_resource_list_members_tab.count;
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                   END IF;


                   IF l_da_resource_list_members_tab.COUNT > 0 THEN
                        PA_PLANNING_RESOURCE_UTILS.get_resource_defaults (
                        P_resource_list_members      => l_da_resource_list_members_tab,
                        P_project_id                 => l_project_id,
                        X_resource_class_flag        => l_da_resource_class_flag_tab,
                        X_resource_class_code        => l_da_resource_class_code_tab,
                        X_resource_class_id          => l_da_resource_class_id_tab,
                        X_res_type_code              => l_da_res_type_code_tab,
                        X_incur_by_res_type          => l_da_incur_by_res_type_tab,
                        X_person_id                  => l_da_person_id_tab,
                        X_job_id                     => l_da_job_id_tab,
                        X_person_type_code           => l_da_person_type_code_tab,
                        X_named_role                 => l_da_named_role_tab,
                        X_bom_resource_id            => l_da_bom_resource_id_tab,
                        X_non_labor_resource         => l_da_non_labor_resource_tab,
                        X_inventory_item_id          => l_da_inventory_item_id_tab,
                        X_item_category_id           => l_da_item_category_id_tab,
                        X_project_role_id            => l_da_project_role_id_tab,
                        X_organization_id            => l_da_organization_id_tab,
                        X_fc_res_type_code           => l_da_fc_res_type_code_tab,
                        X_expenditure_type           => l_da_expenditure_type_tab,
                        X_expenditure_category       => l_da_expenditure_category_tab,
                        X_event_type                 => l_da_event_type_tab,
                        X_revenue_category_code      => l_da_revenue_category_code_tab,
                        X_supplier_id                => l_da_supplier_id_tab,
                        X_spread_curve_id            => l_da_spread_curve_id_tab,
                        X_etc_method_code            => l_da_etc_method_code_tab,
                        X_mfc_cost_type_id           => l_da_mfc_cost_type_id_tab,
                        X_incurred_by_res_flag       => l_da_incurred_by_res_flag_tab,
                        X_incur_by_res_class_code    => l_da_incur_by_res_cls_code_tab,
                        X_incur_by_role_id           => l_da_incur_by_role_id_tab,
                        X_unit_of_measure            => l_da_unit_of_measure_tab,
                        X_org_id                     => l_da_org_id_tab,
                        X_rate_based_flag            => l_da_rate_based_flag_tab,
                        X_rate_expenditure_type      => l_da_rate_expenditure_type_tab,
                        X_rate_func_curr_code        => l_da_rate_func_curr_code_tab,
                        X_msg_data                   => l_MSG_DATA,
                        X_msg_count                  => l_MSG_COUNT,
                        X_return_status              => l_RETURN_STATUS);


                        IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                              IF P_PA_debug_mode = 'Y' THEN
                                   pa_debug.g_err_stage:= 'Error in get_resource_defaults';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                              END IF;
                              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                        END IF;

                        --The above API (resource defaults) returns resource attributes for the distinct resource list members passed.
                        --The below loop will copy the resource attributes from the distinct resource list members into all the
                        --resource assignments that have to be copied into the target. Bug 3678314.
                        IF P_PA_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Same RL About to copy the resource attributes for the distinct rlms into the tbls that will be used copying RAs into target';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;

                        FOR kk in 1 .. l_targ_ra_id_tbl.count LOOP

                            --The attributes returned by the get_resource_defaults should be considered only if
                            --there is no one to one mapping between source and target (i.e l_src_ra_id_cnt_tbl(KK) is null)
                            --and the resource assignment has to be inserted into target(i.e  L_ra_dml_code_tbl(kk) = 'INSERT')
                            --In other cases the attributes in the source will be copied into target.
                            --Bug 3678314
                            IF   L_ra_dml_code_tbl(kk) = 'INSERT'
                            AND l_src_ra_id_cnt_tbl(KK) IS NULL THEN

                                l_temp:=1;
                                FOR LL IN 1..l_da_resource_list_members_tab.COUNT LOOP

                                    IF l_da_resource_list_members_tab(LL)=l_targ_rlm_id_tbl(kk) THEN
                                        l_temp:=LL;
                                        EXIT;
                                    END IF;

                                END LOOP;

                                --Raise an error if the resource list member in l_da_resource_list_members_tab does not
                                --exist in l_targ_rlm_id_tbl (This should never happen). Bug 3678314.
                                IF l_da_resource_list_members_tab(l_temp)<>l_targ_rlm_id_tbl(kk) THEN

                                    IF P_PA_debug_mode = 'Y' THEN
                                          pa_debug.g_err_stage:= 'Match for l_targ_rlm_id_tbl('||kk||') '||l_targ_rlm_id_tbl(kk) ||' not found in l_da_resource_list_members_tab';
                                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

                                    END IF;
                                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                                END IF;

                                l_targ_RESOURCE_CLASS_FLAG_tbl(kk)   := l_da_resource_class_flag_tab(l_temp)       ;
                                l_targ_RESOURCE_CLASS_CODE_tbl(kk)   := l_da_resource_class_code_tab(l_temp)       ;
                                -- If incurred_by_res_flag is 'Y', incur_by_res_type should be used
                                IF nvl(l_da_incurred_by_res_flag_tab(l_temp),'N') = 'Y'  THEN
                                   l_targ_resource_type_code_tbl(kk) := l_da_incur_by_res_type_tab(l_temp)         ;
                                ELSE
                                   l_targ_resource_type_code_tbl(kk) := l_da_res_type_code_tab(l_temp)             ;
                                END IF;
                                l_targ_person_id_tbl(kk)             := l_da_person_id_tab(l_temp)                 ;
                                l_targ_job_id_tbl(kk)                := l_da_job_id_tab(l_temp)                    ;
                                l_targ_person_type_code_tbl(kk)      := l_da_person_type_code_tab(l_temp)          ;
                                l_targ_NAMED_ROLE_tbl(kk)            := l_da_named_role_tab(l_temp)                ;
                                l_targ_bom_resource_id_tbl(kk)       := l_da_bom_resource_id_tab(l_temp)           ;
                                l_targ_non_labor_resource_tbl(kk)    := l_da_non_labor_resource_tab(l_temp)        ;
                                l_targ_inventory_item_id_tbl(kk)     := l_da_inventory_item_id_tab(l_temp)         ;
                                l_targ_item_category_id_tbl(kk)      := l_da_item_category_id_tab(l_temp)          ;
                                l_targ_project_role_id_tbl(kk)       := l_da_project_role_id_tab(l_temp)           ;
                                l_targ_organization_id_tbl(kk)       := l_da_organization_id_tab(l_temp)           ;
                                l_targ_fc_res_type_code_tbl(kk)      := l_da_fc_res_type_code_tab(l_temp)          ;
                                l_targ_expenditure_type_tbl(kk)      := l_da_expenditure_type_tab(l_temp)          ;
                                l_targ_expend_category_tbl(kk)       := l_da_expenditure_category_tab(l_temp)      ;
                                l_targ_event_type_tbl(kk)            := l_da_event_type_tab(l_temp)                ;
                                l_targ_rev_category_code_tbl(kk)     := l_da_revenue_category_code_tab(l_temp)     ;
                                l_targ_supplier_id_tbl(kk)           := l_da_supplier_id_tab(l_temp)               ;
                                l_targ_spread_curve_id_tbl(kk)       := l_da_spread_curve_id_tab(l_temp)           ;
                                l_targ_etc_method_code_tbl(kk)       := l_da_etc_method_code_tab(l_temp)           ;
                                l_targ_mfc_cost_type_id_tbl(kk)      := l_da_mfc_cost_type_id_tab(l_temp)          ;
                                l_targ_INCURED_BY_RES_FLAG_tbl(kk)   := l_da_incurred_by_res_flag_tab(l_temp)      ;
                                l_targ_INCR_BY_RES_CLS_COD_tbl(kk)   := l_da_incur_by_res_cls_code_tab(l_temp)     ;
                                l_targ_INCUR_BY_ROLE_ID_tbl(kk)      := l_da_incur_by_role_id_tab(l_temp)          ;
                                l_targ_RATE_EXPEND_TYPE_tbl(kk)      := l_da_rate_expenditure_type_tab(l_temp)     ;
                                l_targ_RATE_EXP_FC_CUR_COD_tbl(kk)   := l_da_rate_func_curr_code_tab(l_temp)       ;
                                l_targ_RATE_EXPEND_ORG_ID_tbl(kk)    := l_da_org_id_tab(l_temp);
                                l_targ_res_rate_based_flag_tbl(kk)   := l_da_rate_based_flag_tab(l_temp);  --IPM Architecture Enhancement. This flag will be the same through out as derived from the resource list

                                --For the resoruce assignments that should be inserted, the RBF flag and UOM derived from the source
                                --planning transactions should be equal to the RBF and UOM returned by the get_resource_defaults API.
                                --If they are not equal then RBF should be inserted as N in the target planning transaction and UOM
                                --should be inserted as DOLLARS(i.e. Currency). Bug 3621847
                                IF P_PA_debug_mode = 'Y' THEN
                                      pa_debug.g_err_stage:= 'About to derive the rbs and UOM for the target txn that should be inserted';
                                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                END IF;

                                IF P_PA_debug_mode = 'Y' THEN
                                      pa_debug.g_err_stage:= 'l_targ_rate_based_flag_tbl('||kk||') '||l_targ_rate_based_flag_tbl(kk);
                                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                                      pa_debug.g_err_stage:= 'l_targ_unit_of_measure_tbl('||kk||') '||l_targ_unit_of_measure_tbl(kk);
                                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                                END IF;

                                --If there is one to one mapping between source and target then UOM and RBF will be copied directly
                                --from source. Otherwise, the UOM and RBF derived from source should be compared with the ones returned
                                --by get_resource_defaults . If the source's UOM/RBF and default UOM/RBF are same then they will be
                                --copied to target . Otherwise DOLLARS/N will be copied for UOM/RBF

                                IF P_PA_debug_mode = 'Y' THEN
                                      pa_debug.g_err_stage:= 'l_targ_rate_based_flag_tbl('||kk||') '||l_targ_rate_based_flag_tbl(kk);
                                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                                      pa_debug.g_err_stage:= 'l_targ_unit_of_measure_tbl('||kk||') '||l_targ_unit_of_measure_tbl(kk);
                                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                                END IF;

                                IF l_targ_rate_based_flag_tbl(kk)=l_da_rate_based_flag_tab(l_temp) AND
                                   l_targ_unit_of_measure_tbl(kk)=l_da_unit_of_measure_tab(l_temp) THEN

                                    NULL;--Do Nothing in this case

                                ELSE

                                    l_targ_rate_based_flag_tbl(kk):='N';
                                    l_targ_unit_of_measure_tbl(kk):='DOLLARS';

                                END IF;
                                IF P_PA_debug_mode = 'Y' THEN
                                      pa_debug.g_err_stage:= 'Al_targ_rate_based_flag_tbl('||kk||') '||l_targ_rate_based_flag_tbl(kk);
                                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                                      pa_debug.g_err_stage:= 'Al_targ_unit_of_measure_tbl('||kk||') '||l_targ_unit_of_measure_tbl(kk);
                                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                                END IF;

                            END IF; --IF   L_ra_dml_code_tbl(kk) = 'INSERT'
                                    --AND l_src_ra_id_cnt_tbl(KK) IS NULL THEN

                       END LOOP;

                       --dbms_output.put_line('I14');
                       IF P_PA_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Done with the loop for preparing the pl/sql tbls for res attrs ';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                       END IF;

                       l_rbs_element_id_prm_tbl.EXTEND(l_da_resource_list_members_tab.COUNT);
                       l_txn_accum_header_id_prm_tbl.EXTEND(l_da_resource_list_members_tab.COUNT);

                       IF l_rbs_version_id IS NOT NULL THEN
                           PA_RLMI_RBS_MAP_PUB.Map_Rlmi_Rbs
                            (p_budget_version_id              => l_src_ver_id_tbl(j)
                            ,p_rbs_version_id                 => l_rbs_version_id
                            ,p_calling_process                => 'RBS_REFRESH'
                            ,p_calling_context                => 'PLSQL'
                            ,p_process_code                   => 'RBS_MAP'
                            ,p_calling_mode                   => 'PLSQL_TABLE'
                            ,p_init_msg_list_flag             => 'N'
                            ,p_commit_flag                    => 'N'
                            ,p_TXN_SOURCE_ID_tab           => l_da_resource_list_members_tab
                            ,p_TXN_SOURCE_TYPE_CODE_tab    => l_txn_src_typ_code_rbs_prm_tbl
                            ,p_PERSON_ID_tab               => l_da_person_id_tab
                            ,p_JOB_ID_tab                  => l_da_job_id_tab
                            ,p_ORGANIZATION_ID_tab         => l_da_organization_id_tab
                            ,p_VENDOR_ID_tab               => l_da_supplier_id_tab
                            ,p_EXPENDITURE_TYPE_tab        => l_da_expenditure_type_tab
                            ,p_EVENT_TYPE_tab              => l_da_event_type_tab
                            ,p_NON_LABOR_RESOURCE_tab      => l_da_non_labor_resource_tab
                            ,p_EXPENDITURE_CATEGORY_tab    => l_da_expenditure_category_tab
                            ,p_REVENUE_CATEGORY_CODE_tab   => l_da_revenue_category_code_tab
                    --        ,p_NLR_ORGANIZATION_ID_tab     =>
                    --        ,p_EVENT_CLASSIFICATION_tab    =>
                    --        ,p_SYS_LINK_FUNCTION_tab       =>
                            ,p_PROJECT_ROLE_ID_tab         => l_da_project_role_id_tab
                            ,p_RESOURCE_CLASS_CODE_tab     => l_da_resource_class_code_tab
                            ,p_MFC_COST_TYPE_ID_tab        => l_da_mfc_cost_type_id_tab
                            ,p_RESOURCE_CLASS_FLAG_tab     => l_da_resource_class_flag_tab
                            ,p_FC_RES_TYPE_CODE_tab        => l_da_fc_res_type_code_tab
                            ,p_INVENTORY_ITEM_ID_tab       => l_da_inventory_item_id_tab
                            ,p_ITEM_CATEGORY_ID_tab        => l_da_item_category_id_tab
                            ,p_PERSON_TYPE_CODE_tab        => l_da_person_type_code_tab
                            ,p_BOM_RESOURCE_ID_tab         => l_da_bom_resource_id_tab
                            ,p_NAMED_ROLE_tab              => l_da_named_role_tab
                            ,p_INCURRED_BY_RES_FLAG_tab    => l_da_incurred_by_res_flag_tab
                            ,p_RATE_BASED_FLAG_tab         => l_da_rate_based_flag_tab
                    --        ,p_TXN_TASK_ID_tab             =>
                    --        ,p_TXN_WBS_ELEMENT_VER_ID_tab  =>
                    --        ,p_TXN_RBS_ELEMENT_ID_tab      =>
                    --        ,p_TXN_PLAN_START_DATE_tab     =>
                    --        ,p_TXN_PLAN_END_DATE_tab       =>
                              ,x_txn_source_id_tab           => l_txn_source_id_tbl
                              ,x_res_list_member_id_tab      => l_res_list_member_id_tbl
                              ,x_rbs_element_id_tab          => l_rbs_element_id_prm_tbl
                              ,x_txn_accum_header_id_tab     => l_txn_accum_header_id_prm_tbl
                              ,x_return_status               => l_return_status
                              ,x_msg_count                   => l_msg_count
                              ,x_msg_data                    => l_msg_data);

                           IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                                  IF P_PA_debug_mode = 'Y' THEN
                                       pa_debug.g_err_stage:= 'Error in get_resource_defaults';
                                       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                                  END IF;
                                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                           END IF;

                           IF P_PA_debug_mode = 'Y' THEN
                                  pa_debug.g_err_stage:= 'Returned from PA_RLMI_RBS_MAP_PUB.Map_Rlmi_Rbs for getting rbs elem id for new RAs';
                                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                                  pa_debug.g_err_stage:= 'l_rbs_element_id_prm_tbl.COUNT '||l_rbs_element_id_prm_tbl.COUNT ||' l_txn_accum_header_id_prm_tbl.COUNT '||l_txn_accum_header_id_prm_tbl.COUNT;
                                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                           END IF;

                           -- The rbs element id and txn accum header id are returned for distinct resource list members. These attributes
                           -- should be copied for all the target resoruce assignments also. Bug 3678314.
                           FOR kk in 1 .. l_targ_ra_id_tbl.count LOOP

                                IF   L_ra_dml_code_tbl(kk) = 'INSERT'
                                AND  l_src_ra_id_cnt_tbl(KK) IS NULL THEN

                                    l_temp:=1;
                                    FOR LL IN 1..l_da_resource_list_members_tab.COUNT LOOP

                                        IF l_da_resource_list_members_tab(LL)=l_targ_rlm_id_tbl(kk) THEN
                                            l_temp:=LL;
                                            EXIT;
                                        END IF;

                                    END LOOP;

                                    --Raise an error if the resource list member in l_da_resource_list_members_tab does not
                                    --exist in l_targ_rlm_id_tbl (This should never happen).Bug 3678314.
                                    IF l_da_resource_list_members_tab(l_temp)<>l_targ_rlm_id_tbl(kk) THEN

                                        IF P_PA_debug_mode = 'Y' THEN
                                              pa_debug.g_err_stage:= 'Match for l_targ_rlm_id_tbl('||kk||') '||l_targ_rlm_id_tbl(kk) ||' not found in l_da_resource_list_members_tab';
                                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

                                        END IF;
                                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                                    END IF;

                                    l_targ_txn_accum_header_id_tbl(kk) := l_txn_accum_header_id_prm_tbl(l_temp);
                                    l_targ_rbs_element_id_tbl(kk)      := l_rbs_element_id_prm_tbl(l_temp);

                                END IF;--IF   L_ra_dml_code_tbl(kk) = 'INSERT'
                                       --AND  l_src_ra_id_cnt_tbl(KK) IS NULL THEN
                           END LOOP;

                           IF P_PA_debug_mode = 'Y' THEN
                                  pa_debug.g_err_stage:= 'Done with preparing tbls of indexed txn accum header and rbs elem ids';
                                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                           END IF;

                       END IF; --IF l_rbs_version_id IS NOT NULL THEN

 -- for Start Bug 5291484

                      ELSIF lresource_list_members_tab_1.COUNT > 0 THEN

                          l_rbs_element_id_prm_tbl_1.EXTEND(lresource_list_members_tab_1.COUNT);
                          ltxnaccumheader_id_prm_tbl_1.EXTEND(lresource_list_members_tab_1.COUNT);

                          IF l_rbs_version_id IS NOT NULL THEN
                              PA_RLMI_RBS_MAP_PUB.Map_Rlmi_Rbs
                               (p_budget_version_id              => l_src_ver_id_tbl(j)
                               ,p_rbs_version_id                 => l_rbs_version_id
                               ,p_calling_process                => 'RBS_REFRESH'
                               ,p_calling_context                => 'PLSQL'
                               ,p_process_code                   => 'RBS_MAP'
                               ,p_calling_mode                   => 'PLSQL_TABLE'
                               ,p_init_msg_list_flag             => 'N'
                               ,p_commit_flag                    => 'N'
                               ,p_TXN_SOURCE_ID_tab           => lresource_list_members_tab_1
                               ,p_TXN_SOURCE_TYPE_CODE_tab    => ltxnsrctyp_code_rbs_prm_tbl_1
                               ,p_PERSON_ID_tab               => lperson_id_tab_1
                               ,p_JOB_ID_tab                  => ljob_id_tab_1
                               ,p_ORGANIZATION_ID_tab         => lorganization_id_tab_1
                               ,p_VENDOR_ID_tab               => l_da_supplier_id_tab_1
                               ,p_EXPENDITURE_TYPE_tab        => lexpenditure_type_tab_1
                               ,p_EVENT_TYPE_tab              => l_da_event_type_tab_1
                               ,p_NON_LABOR_RESOURCE_tab      => lnon_labor_resource_tab_1
                               ,p_EXPENDITURE_CATEGORY_tab    => lexpenditure_category_tab_1
                               ,p_REVENUE_CATEGORY_CODE_tab   => lrevenue_category_code_tab_1
                               ,p_PROJECT_ROLE_ID_tab         => lproject_role_id_tab_1
                               ,p_RESOURCE_CLASS_CODE_tab     => lresource_class_code_tab_1
                               ,p_MFC_COST_TYPE_ID_tab        => l_da_mfc_cost_type_id_tab_1
                               ,p_RESOURCE_CLASS_FLAG_tab     => lresource_class_flag_tab_1
                               ,p_FC_RES_TYPE_CODE_tab        => lfc_res_type_code_tab_1
                               ,p_INVENTORY_ITEM_ID_tab       => linventory_item_id_tab_1
                               ,p_ITEM_CATEGORY_ID_tab        => litem_category_id_tab_1
                               ,p_PERSON_TYPE_CODE_tab        => lperson_type_code_tab_1
                               ,p_BOM_RESOURCE_ID_tab         => lbom_resource_id_tab_1
                               ,p_NAMED_ROLE_tab              => lnamed_role_tab_1
                               ,p_INCURRED_BY_RES_FLAG_tab    => lincurred_by_res_flag_tab_1
                               ,p_RATE_BASED_FLAG_tab         => l_da_rate_based_flag_tab_1
                                 ,x_txn_source_id_tab           => l_txn_source_id_tbl_1
                                 ,x_res_list_member_id_tab      => l_res_list_member_id_tbl_1
                                 ,x_rbs_element_id_tab          => l_rbs_element_id_prm_tbl_1
                                 ,x_txn_accum_header_id_tab     => ltxnaccumheader_id_prm_tbl_1
                                 ,x_return_status               => l_return_status
                                 ,x_msg_count                   => l_msg_count
                                 ,x_msg_data                    => l_msg_data);

                              IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                                     IF P_PA_debug_mode = 'Y' THEN
                                          pa_debug.g_err_stage:= 'Error in Map_Rlmi_Rbs';
                                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                                     END IF;
                                     RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                              END IF;

                              FOR kk in 1 .. l_targ_ra_id_tbl.count LOOP

                                   IF   L_ra_dml_code_tbl(kk) = 'INSERT'
                                   AND  l_src_ra_id_cnt_tbl(KK) IS NOT NULL THEN
                                       l_temp:=1;
                                       FOR LL IN 1..lresource_list_members_tab_1.COUNT LOOP

                                           IF lresource_list_members_tab_1(LL)=l_targ_rlm_id_tbl(kk) THEN
                                               l_temp:=LL;
                                               EXIT;
                                           END IF;

                                       END LOOP;

                                       --Raise an error if the resource list member in l_da_resource_list_members_tab does not
                                       --exist in l_targ_rlm_id_tbl (This should never happen).Bug 3678314.
                                       IF lresource_list_members_tab_1(l_temp)<>l_targ_rlm_id_tbl(kk) THEN
                                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                                       END IF;
                                       l_targ_txn_accum_header_id_tbl(kk) := ltxnaccumheader_id_prm_tbl_1(l_temp);
                                       l_targ_rbs_element_id_tbl(kk)      := l_rbs_element_id_prm_tbl_1(l_temp);

                                   END IF;
                              END LOOP;
                          END IF;

   -- for End Bug 5291484


                   END IF;--IF l_da_resource_list_members_tab.COUNT > 0


            ELSE --Resource lists are different

               --dbms_output.put_line('I15');

               IF P_PA_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:= 'About to prepare input table for get resource defaults API';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
               END IF;
               l_da_resource_list_members_tab:=SYSTEM.PA_NUM_TBL_TYPE();
               l_txn_src_typ_code_rbs_prm_tbl :=SYSTEM.pa_varchar2_30_tbl_type();

               FOR kk in 1 .. L_targ_rlm_id_tbl.count LOOP

                   --Find the distinct rlms among the resoruce assignments that have to be inserted .
                   --This is done to call get_resource_defaults only for distinct rlms. Bug 3859738
                   IF  L_ra_dml_code_tbl(kk) = 'INSERT' THEN

                        l_temp:= NULL;
                        FOR LL IN 1..l_da_resource_list_members_tab.COUNT LOOP
                            IF l_da_resource_list_members_tab(LL)= L_targ_rlm_id_tbl(kk) THEN
                                l_temp:=LL;
                                EXIT;
                            END IF;
                        END LOOP;

                        IF l_temp IS NULL THEN
                            --Indicates that the resource list member is not already selected and hence it has to be
                            --considered while calling get_resource_defaults.Bug 3859738

                            l_da_resource_list_members_tab.extend;
                            l_da_resource_list_members_tab(l_da_resource_list_members_tab.COUNT) := L_targ_rlm_id_tbl(kk);
                            l_txn_src_typ_code_rbs_prm_tbl.EXTEND;
                            l_txn_src_typ_code_rbs_prm_tbl(l_txn_src_typ_code_rbs_prm_tbl.COUNT):='RES_ASSIGNMENT';

                        END IF;
                   END IF;
               END LOOP;

               IF l_da_resource_list_members_tab.COUNT > 0 THEN
                    PA_PLANNING_RESOURCE_UTILS.get_resource_defaults (
                    P_resource_list_members      => l_da_resource_list_members_tab,
                    P_project_id                 => l_project_id,
                    X_resource_class_flag        => l_da_resource_class_flag_tab,
                    X_resource_class_code        => l_da_resource_class_code_tab,
                    X_resource_class_id          => l_da_resource_class_id_tab,
                    X_res_type_code              => l_da_res_type_code_tab,
                    X_incur_by_res_type          => l_da_incur_by_res_type_tab,
                    X_person_id                  => l_da_person_id_tab,
                    X_job_id                     => l_da_job_id_tab,
                    X_person_type_code           => l_da_person_type_code_tab,
                    X_named_role                 => l_da_named_role_tab,
                    X_bom_resource_id            => l_da_bom_resource_id_tab,
                    X_non_labor_resource         => l_da_non_labor_resource_tab,
                    X_inventory_item_id          => l_da_inventory_item_id_tab,
                    X_item_category_id           => l_da_item_category_id_tab,
                    X_project_role_id            => l_da_project_role_id_tab,
                    X_organization_id            => l_da_organization_id_tab,
                    X_fc_res_type_code           => l_da_fc_res_type_code_tab,
                    X_expenditure_type           => l_da_expenditure_type_tab,
                    X_expenditure_category       => l_da_expenditure_category_tab,
                    X_event_type                 => l_da_event_type_tab,
                    X_revenue_category_code      => l_da_revenue_category_code_tab,
                    X_supplier_id                => l_da_supplier_id_tab,
                    X_spread_curve_id            => l_da_spread_curve_id_tab,
                    X_etc_method_code            => l_da_etc_method_code_tab,
                    X_mfc_cost_type_id           => l_da_mfc_cost_type_id_tab,
                    X_incurred_by_res_flag       => l_da_incurred_by_res_flag_tab,
                    X_incur_by_res_class_code    => l_da_incur_by_res_cls_code_tab,
                    X_incur_by_role_id           => l_da_incur_by_role_id_tab,
                    X_unit_of_measure            => l_da_unit_of_measure_tab,
                    X_org_id                     => l_da_org_id_tab,
                    X_rate_based_flag            => l_da_rate_based_flag_tab,
                    X_rate_expenditure_type      => l_da_rate_expenditure_type_tab,
                    X_rate_func_curr_code        => l_da_rate_func_curr_code_tab,
                    X_msg_data                   => l_MSG_DATA,
                    X_msg_count                  => l_MSG_COUNT,
                    X_return_status              => l_RETURN_STATUS);


                    IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                          IF P_PA_debug_mode = 'Y' THEN
                               pa_debug.g_err_stage:= 'Error in get_resource_defaults';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                          END IF;
                          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;


                    --The above API (resource defaults) returns resource attributes for the distinct resource list members passed.
                    --The below loop will copy the resource attributes from the distinct resource list members into all the
                    --resource assignments that have to be copied into the target. Bug 3678314.
                    IF P_PA_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:= 'Diff RL About to copy the resource attributes for the distinct rlms into the tbls that will be used copying RAs into target';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                    END IF;

                    FOR kk in 1 .. l_targ_ra_id_tbl.count LOOP

                        --The attributes returned by the get_resource_defaults should be considered only if
                        --the resource assignment has to be inserted into target(i.e  L_ra_dml_code_tbl(kk) = 'INSERT')
                        --If there is one-one mapping then the attributes in the source can not be used since
                        --the resource lists are different.
                        --If the resource assignment is already available then the attributes of the resource assignment
                        --will not change because of merge.
                        --Bug 3678314
                        IF l_ra_dml_code_tbl(kk)='INSERT'  THEN
                            l_temp:=1;
                            FOR LL IN 1..l_da_resource_list_members_tab.COUNT LOOP

                                IF l_da_resource_list_members_tab(LL)=l_targ_rlm_id_tbl(kk) THEN
                                    l_temp:=LL;
                                    EXIT;
                                END IF;

                            END LOOP;

                            --Raise an error if the resource list member in l_da_resource_list_members_tab does not
                            --exist in l_targ_rlm_id_tbl (This should never happen). Bug 3678314.
                            IF l_da_resource_list_members_tab(l_temp)<>l_targ_rlm_id_tbl(kk) THEN

                                IF P_PA_debug_mode = 'Y' THEN
                                      pa_debug.g_err_stage:= 'Match for l_targ_rlm_id_tbl('||kk||') '||l_targ_rlm_id_tbl(kk) ||' not found in l_da_resource_list_members_tab';
                                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

                                END IF;
                                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                            END IF;

                            l_targ_RESOURCE_CLASS_FLAG_tbl(kk)   := l_da_resource_class_flag_tab(l_temp)       ;
                            l_targ_RESOURCE_CLASS_CODE_tbl(kk)   := l_da_resource_class_code_tab(l_temp)       ;
                            -- If incurred_by_res_flag is 'Y', incur_by_res_type should be used
                            IF nvl(l_da_incurred_by_res_flag_tab(l_temp),'N') = 'Y'  THEN
                               l_targ_resource_type_code_tbl(kk) := l_da_incur_by_res_type_tab(l_temp)         ;
                            ELSE
                               l_targ_resource_type_code_tbl(kk) := l_da_res_type_code_tab(l_temp)             ;
                            END IF;
                            l_targ_person_id_tbl(kk)             := l_da_person_id_tab(l_temp)                 ;
                            l_targ_job_id_tbl(kk)                := l_da_job_id_tab(l_temp)                    ;
                            l_targ_person_type_code_tbl(kk)      := l_da_person_type_code_tab(l_temp)          ;
                            l_targ_NAMED_ROLE_tbl(kk)            := l_da_named_role_tab(l_temp)                ;
                            l_targ_bom_resource_id_tbl(kk)       := l_da_bom_resource_id_tab(l_temp)           ;
                            l_targ_non_labor_resource_tbl(kk)    := l_da_non_labor_resource_tab(l_temp)        ;
                            l_targ_inventory_item_id_tbl(kk)     := l_da_inventory_item_id_tab(l_temp)         ;
                            l_targ_item_category_id_tbl(kk)      := l_da_item_category_id_tab(l_temp)          ;
                            l_targ_project_role_id_tbl(kk)       := l_da_project_role_id_tab(l_temp)           ;
                            l_targ_organization_id_tbl(kk)       := l_da_organization_id_tab(l_temp)           ;
                            l_targ_fc_res_type_code_tbl(kk)      := l_da_fc_res_type_code_tab(l_temp)          ;
                            l_targ_expenditure_type_tbl(kk)      := l_da_expenditure_type_tab(l_temp)          ;
                            l_targ_expend_category_tbl(kk)       := l_da_expenditure_category_tab(l_temp)      ;
                            l_targ_event_type_tbl(kk)            := l_da_event_type_tab(l_temp)                ;
                            l_targ_rev_category_code_tbl(kk)     := l_da_revenue_category_code_tab(l_temp)     ;
                            l_targ_supplier_id_tbl(kk)           := l_da_supplier_id_tab(l_temp)               ;
                            l_targ_spread_curve_id_tbl(kk)       := l_da_spread_curve_id_tab(l_temp)           ;
                            l_targ_etc_method_code_tbl(kk)       := l_da_etc_method_code_tab(l_temp)           ;
                            l_targ_mfc_cost_type_id_tbl(kk)      := l_da_mfc_cost_type_id_tab(l_temp)          ;
                            l_targ_INCURED_BY_RES_FLAG_tbl(kk)   := l_da_incurred_by_res_flag_tab(l_temp)      ;

                            l_targ_INCR_BY_RES_CLS_COD_tbl(kk)   := l_da_incur_by_res_cls_code_tab(l_temp)     ;
                            l_targ_INCUR_BY_ROLE_ID_tbl(kk)      := l_da_incur_by_role_id_tab(l_temp)          ;
                            l_targ_RATE_EXPEND_TYPE_tbl(kk)      := l_da_rate_expenditure_type_tab(l_temp)     ;
                            l_targ_RATE_EXP_FC_CUR_COD_tbl(kk)   := l_da_rate_func_curr_code_tab(l_temp)       ;
                            l_targ_RATE_EXPEND_ORG_ID_tbl(kk)    := l_da_org_id_tab(l_temp);
                            l_targ_RES_RATE_BASED_FLAG_tbl(kk)   := l_targ_rate_based_flag_tbl(l_temp)         ; --IPM

                            --For the resoruce assignments that should be inserted, the RBF flag and UOM derived from the source
                            --planning transactions should be equal to the RBF and UOM returned by the get_resource_defaults API.
                            --If they are not equal then RBF should be inserted as N in the target planning transaction and UOM
                            --should be inserted as DOLLARS(i.e. Currency). Bug 3678314
                            IF P_PA_debug_mode = 'Y' THEN
                                  pa_debug.g_err_stage:= 'About to derive the rbs and UOM for the target txn that should be inserted';
                                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                            END IF;

                            IF P_PA_debug_mode = 'Y' THEN
                                  pa_debug.g_err_stage:= 'l_targ_rate_based_flag_tbl('||kk||') '||l_targ_rate_based_flag_tbl(kk);
                                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                                  pa_debug.g_err_stage:= 'l_targ_unit_of_measure_tbl('||kk||') '||l_targ_unit_of_measure_tbl(kk);
                                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                            END IF;


                            --If the RBF/UOM derived through resource list mapping are not same as RBF/UOM returned by get_resource_defaults
                            --then RBF/UOM should be changed to DOLLARS/N. Bug 3678314
                            IF P_PA_debug_mode = 'Y' THEN
                                  pa_debug.g_err_stage:= 'l_targ_rate_based_flag_tbl('||kk||') '||l_targ_rate_based_flag_tbl(kk);
                                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                                  pa_debug.g_err_stage:= 'l_targ_unit_of_measure_tbl('||kk||') '||l_targ_unit_of_measure_tbl(kk);
                                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                            END IF;

                            IF l_targ_rate_based_flag_tbl(kk)=l_da_rate_based_flag_tab(l_temp) AND
                               l_targ_unit_of_measure_tbl(kk)=l_da_unit_of_measure_tab(l_temp) THEN

                                NULL;--Do Nothing in this case

                            ELSE

                                l_targ_rate_based_flag_tbl(kk):='N';
                                l_targ_unit_of_measure_tbl(kk):='DOLLARS';

                            END IF;
                            IF P_PA_debug_mode = 'Y' THEN
                                  pa_debug.g_err_stage:= 'Al_targ_rate_based_flag_tbl('||kk||') '||l_targ_rate_based_flag_tbl(kk);
                                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                                  pa_debug.g_err_stage:= 'Al_targ_unit_of_measure_tbl('||kk||') '||l_targ_unit_of_measure_tbl(kk);
                                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                            END IF;

                        END IF;-- IF l_ra_dml_code_tbl(kk)='INSERT'  THEN

                    END LOOP;

                    l_rbs_element_id_prm_tbl:=SYSTEM.pa_num_tbl_type();
                    l_txn_accum_header_id_prm_tbl:=SYSTEM.pa_num_tbl_type();
                    l_rbs_element_id_prm_tbl.EXTEND(l_da_resource_list_members_tab.COUNT);
                    l_txn_accum_header_id_prm_tbl.EXTEND(l_da_resource_list_members_tab.COUNT);
                    IF l_rbs_version_id IS NOT NULL THEN

                        IF P_PA_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'About to call PA_RLMI_RBS_MAP_PUB.Map_Rlmi_Rbs when RLS are different for RBS REF';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;


                        PA_RLMI_RBS_MAP_PUB.Map_Rlmi_Rbs
                                 (p_budget_version_id              => l_src_ver_id_tbl(j)
                                 ,p_rbs_version_id                 => l_rbs_version_id
                                 ,p_calling_process                => 'RBS_REFRESH'
                                 ,p_calling_context                => 'PLSQL'
                                 ,p_process_code                   => 'RBS_MAP'
                                 ,p_calling_mode                   => 'PLSQL_TABLE'
                                 ,p_init_msg_list_flag             => 'N'
                                 ,p_commit_flag                    => 'N'
                                 ,p_TXN_SOURCE_ID_tab           => l_da_resource_list_members_tab
                                 ,p_TXN_SOURCE_TYPE_CODE_tab    => l_txn_src_typ_code_rbs_prm_tbl
                                 ,p_PERSON_ID_tab               => l_da_person_id_tab
                                 ,p_JOB_ID_tab                  => l_da_job_id_tab
                                 ,p_ORGANIZATION_ID_tab         => l_da_organization_id_tab
                                 ,p_VENDOR_ID_tab               => l_da_supplier_id_tab
                                 ,p_EXPENDITURE_TYPE_tab        => l_da_expenditure_type_tab
                                 ,p_EVENT_TYPE_tab              => l_da_event_type_tab
                                 ,p_NON_LABOR_RESOURCE_tab      => l_da_non_labor_resource_tab
                                 ,p_EXPENDITURE_CATEGORY_tab    => l_da_expenditure_category_tab
                                 ,p_REVENUE_CATEGORY_CODE_tab   => l_da_revenue_category_code_tab
                         --        ,p_NLR_ORGANIZATION_ID_tab     =>
                         --        ,p_EVENT_CLASSIFICATION_tab    =>
                         --        ,p_SYS_LINK_FUNCTION_tab       =>
                                 ,p_PROJECT_ROLE_ID_tab         => l_da_project_role_id_tab
                                 ,p_RESOURCE_CLASS_CODE_tab     => l_da_resource_class_code_tab
                                 ,p_MFC_COST_TYPE_ID_tab        => l_da_mfc_cost_type_id_tab
                                 ,p_RESOURCE_CLASS_FLAG_tab     => l_da_resource_class_flag_tab
                                 ,p_FC_RES_TYPE_CODE_tab        => l_da_fc_res_type_code_tab
                                 ,p_INVENTORY_ITEM_ID_tab       => l_da_inventory_item_id_tab
                                 ,p_ITEM_CATEGORY_ID_tab        => l_da_item_category_id_tab
                                 ,p_PERSON_TYPE_CODE_tab        => l_da_person_type_code_tab
                                 ,p_BOM_RESOURCE_ID_tab         => l_da_bom_resource_id_tab
                                 ,p_NAMED_ROLE_tab              => l_da_named_role_tab
                                 ,p_INCURRED_BY_RES_FLAG_tab    => l_da_incurred_by_res_flag_tab
                                 ,p_RATE_BASED_FLAG_tab         => l_da_rate_based_flag_tab
                         --        ,p_TXN_TASK_ID_tab             =>
                         --        ,p_TXN_WBS_ELEMENT_VER_ID_tab  =>
                         --        ,p_TXN_RBS_ELEMENT_ID_tab      =>
                         --        ,p_TXN_PLAN_START_DATE_tab     =>
                         --        ,p_TXN_PLAN_END_DATE_tab       =>
                                   ,x_txn_source_id_tab           => l_txn_source_id_tbl
                                   ,x_res_list_member_id_tab      => l_res_list_member_id_tbl
                                   ,x_rbs_element_id_tab          => l_rbs_element_id_prm_tbl
                                   ,x_txn_accum_header_id_tab     => l_txn_accum_header_id_prm_tbl
                                   ,x_return_status               => l_return_status
                                   ,x_msg_count                   => l_msg_count
                                   ,x_msg_data                    => l_msg_data);

                         IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                             IF P_PA_debug_mode = 'Y' THEN
                                   pa_debug.g_err_stage:= 'Error in get_resource_defaults ';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                             END IF;
                             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                         END IF;

                         IF P_PA_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Preparing TXN Accum Header Id and RBS Elem Id tbls';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                              pa_debug.g_err_stage:= 'l_txn_accum_header_id_prm_tbl.count is '||l_txn_accum_header_id_prm_tbl.count ||' l_rbs_element_id_prm_tbl.count is '||l_rbs_element_id_prm_tbl.count;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                         END IF;


                         -- The rbs element id and txn accum header id are returned for distinct resource list members. These attributes
                         -- should be copied for all the target resoruce assignments also. Bug 3678314.
                         FOR kk in 1 .. l_targ_ra_id_tbl.count LOOP

                              IF l_ra_dml_code_tbl(kk)='INSERT'  THEN

                                  l_temp:=1;
                                  FOR LL IN 1..l_da_resource_list_members_tab.COUNT LOOP

                                      IF l_da_resource_list_members_tab(LL)=l_targ_rlm_id_tbl(kk) THEN
                                          l_temp:=LL;
                                          EXIT;
                                      END IF;

                                  END LOOP;

                                  --Raise an error if the resource list member in l_da_resource_list_members_tab does not
                                  --exist in l_targ_rlm_id_tbl (This should never happen).Bug 3678314.
                                  IF l_da_resource_list_members_tab(l_temp)<>l_targ_rlm_id_tbl(kk) THEN

                                      IF P_PA_debug_mode = 'Y' THEN
                                            pa_debug.g_err_stage:= 'Match for l_targ_rlm_id_tbl('||kk||') '||l_targ_rlm_id_tbl(kk) ||' not found in l_da_resource_list_members_tab';
                                            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

                                      END IF;
                                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                                  END IF;

                                  l_targ_txn_accum_header_id_tbl(kk) := l_txn_accum_header_id_prm_tbl(l_temp);
                                  l_targ_rbs_element_id_tbl(kk) := l_rbs_element_id_prm_tbl(l_temp);

                              END IF;-- IF l_ra_dml_code_tbl(kk)='INSERT'  THEN

                         END LOOP;

                    END IF;--IF l_rbs_version_id IS NOT NULL THEN

               END IF; -- IF l_da_resource_list_members_tab.COUNT > 0

            END IF;  --IF l_src_resource_list_id = l_targ_resource_list_id

            --dbms_output.put_line('I16');

            --dbms_output.put_line('I17');


            IF P_PA_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'About to bulk insert into PRA';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

               IF l_targ_rlm_id_tbl.COUNT>1 THEN
                  pa_debug.g_err_stage:= 'l_targ_rlm_id_tbl(1) is '||l_targ_rlm_id_tbl(1)||' l_targ_rlm_id_tbl(2) is '||l_targ_rlm_id_tbl(2);
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                  pa_debug.g_err_stage:= 'L_targ_ra_id_tbl(1) is '||L_targ_ra_id_tbl(1)||' L_targ_ra_id_tbl(2) is '||L_targ_ra_id_tbl(2);
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                  pa_debug.g_err_stage:= 'L_targ_task_id_tbl(1) is '||L_targ_task_id_tbl(1)||' L_targ_task_id_tbl(2) is '||L_targ_task_id_tbl(2);
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                  pa_debug.g_err_stage:= 'l_src_ra_id_cnt_tbl(1) is '||l_src_ra_id_cnt_tbl(1)||' l_src_ra_id_cnt_tbl(2) is '||l_src_ra_id_cnt_tbl(2);
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                 pa_debug.g_err_stage:= 'l_src_resource_list_id is '||l_src_resource_list_id||' l_targ_resource_list_id is '||l_targ_resource_list_id;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                 pa_debug.g_err_stage:= 'L_ra_dml_code_tbl(1) is '||L_ra_dml_code_tbl(1)||' L_ra_dml_code_tbl(2) is '||L_ra_dml_code_tbl(2);
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                 pa_debug.g_err_stage:= 'l_targ_txn_accum_header_id_tbl(1) is '||l_targ_txn_accum_header_id_tbl(1)||' l_targ_txn_accum_header_id_tbl(2) is '||l_targ_txn_accum_header_id_tbl(2);
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                 pa_debug.g_err_stage:= 'l_targ_rbs_element_id_tbl(1) is '||l_targ_rbs_element_id_tbl(1)||' l_targ_rbs_element_id_tbl(2) is '||l_targ_rbs_element_id_tbl(2);
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);


               END IF;

            END IF;

            --dbms_output.put_line('I18');
            -- Bug 3934574 The following business rules are incorporated in the insert
            -- 1) If p_calling_context is null, insert transaction source code as null
            -- 2) If p_calling_context is generation insert transaction source code as 'CHANGE DOCUMENTS'

            FORALL kk in L_targ_ra_id_tbl.FIRST ..L_targ_ra_id_tbl.LAST
            INSERT INTO PA_RESOURCE_ASSIGNMENTS (
                    RESOURCE_ASSIGNMENT_ID,BUDGET_VERSION_ID,PROJECT_ID,TASK_ID,RESOURCE_LIST_MEMBER_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY
                    ,LAST_UPDATE_LOGIN,UNIT_OF_MEASURE,TRACK_AS_LABOR_FLAG,STANDARD_BILL_RATE,AVERAGE_BILL_RATE,AVERAGE_COST_RATE
                    ,PROJECT_ASSIGNMENT_ID,PLAN_ERROR_CODE,TOTAL_PLAN_REVENUE,TOTAL_PLAN_RAW_COST,TOTAL_PLAN_BURDENED_COST,TOTAL_PLAN_QUANTITY
                    ,AVERAGE_DISCOUNT_PERCENTAGE,TOTAL_BORROWED_REVENUE,TOTAL_TP_REVENUE_IN,TOTAL_TP_REVENUE_OUT,TOTAL_REVENUE_ADJ
                    ,TOTAL_LENT_RESOURCE_COST,TOTAL_TP_COST_IN,TOTAL_TP_COST_OUT,TOTAL_COST_ADJ,TOTAL_UNASSIGNED_TIME_COST
                    ,TOTAL_UTILIZATION_PERCENT,TOTAL_UTILIZATION_HOURS,TOTAL_UTILIZATION_ADJ,TOTAL_CAPACITY,TOTAL_HEAD_COUNT
                    ,TOTAL_HEAD_COUNT_ADJ,RESOURCE_ASSIGNMENT_TYPE,TOTAL_PROJECT_RAW_COST,TOTAL_PROJECT_BURDENED_COST,TOTAL_PROJECT_REVENUE
                    ,PARENT_ASSIGNMENT_ID,WBS_ELEMENT_VERSION_ID,RBS_ELEMENT_ID,PLANNING_START_DATE,PLANNING_END_DATE
                    ,SPREAD_CURVE_ID,ETC_METHOD_CODE,RES_TYPE_CODE,ATTRIBUTE_CATEGORY,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5
                    ,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15
                    ,ATTRIBUTE16,ATTRIBUTE17,ATTRIBUTE18,ATTRIBUTE19,ATTRIBUTE20,ATTRIBUTE21,ATTRIBUTE22,ATTRIBUTE23,ATTRIBUTE24,ATTRIBUTE25
                    ,ATTRIBUTE26,ATTRIBUTE27,ATTRIBUTE28,ATTRIBUTE29,ATTRIBUTE30,FC_RES_TYPE_CODE,RESOURCE_CLASS_CODE,ORGANIZATION_ID,JOB_ID
                    ,PERSON_ID,EXPENDITURE_TYPE,EXPENDITURE_CATEGORY,REVENUE_CATEGORY_CODE,EVENT_TYPE,SUPPLIER_ID,NON_LABOR_RESOURCE
                    ,BOM_RESOURCE_ID,INVENTORY_ITEM_ID,ITEM_CATEGORY_ID,RECORD_VERSION_NUMBER,BILLABLE_PERCENT
                    ,TRANSACTION_SOURCE_CODE,MFC_COST_TYPE_ID,PROCURE_RESOURCE_FLAG,ASSIGNMENT_DESCRIPTION
                    ,INCURRED_BY_RES_FLAG,RATE_JOB_ID,RATE_EXPENDITURE_TYPE,TA_DISPLAY_FLAG
                    ,SP_FIXED_DATE,PERSON_TYPE_CODE,RATE_BASED_FLAG,RESOURCE_RATE_BASED_FLAG            --IPM Arch Enhancement
                    ,USE_TASK_SCHEDULE_FLAG,RATE_EXP_FUNC_CURR_CODE
                    ,RATE_EXPENDITURE_ORG_ID,INCUR_BY_RES_CLASS_CODE,INCUR_BY_ROLE_ID
                    ,PROJECT_ROLE_ID,RESOURCE_CLASS_FLAG,NAMED_ROLE,TXN_ACCUM_HEADER_ID)
                 SELECT  L_targ_ra_id_tbl(kk)               -- RESOURCE_ASSIGNMENT_ID
                        ,p_budget_version_id                -- BUDGET_VERSION_ID
                        ,l_project_id                       -- PROJECT_ID
                        ,L_targ_task_id_tbl(kk)             -- TASK_ID
                        ,L_targ_rlm_id_tbl(kk)              -- RESOURCE_LIST_MEMBER_ID
                        ,sysdate                            -- LAST_UPDATE_DATE
                        ,fnd_global.user_id                 -- LAST_UPDATED_BY
                        ,sysdate                            -- CREATION_DATE
                        ,fnd_global.user_id                 -- CREATED_BY
                        ,fnd_global.login_id                -- LAST_UPDATE_LOGIN
                        ,l_targ_unit_of_measure_tbl(kk)     -- UNIT_OF_MEASURE
                        ,NULL                               -- TRACK_AS_LABOR_FLAG
                        ,NULL                               -- STANDARD_BILL_RATE
                        ,NULL                               -- AVERAGE_BILL_RATE
                        ,NULL                               -- AVERAGE_COST_RATE
                        ,-1                                 -- PROJECT_ASSIGNMENT_ID
                        ,NULL                               -- PLAN_ERROR_CODE
                        ,NULL                               -- TOTAL_PLAN_REVENUE
                        ,NULL                               -- TOTAL_PLAN_RAW_COST
                        ,NULL                               -- TOTAL_PLAN_BURDENED_COST
                        ,NULL                               -- TOTAL_PLAN_QUANTITY
                        ,NULL                               -- AVERAGE_DISCOUNT_PERCENTAGE
                        ,NULL                               -- TOTAL_BORROWED_REVENUE
                        ,NULL                               -- TOTAL_TP_REVENUE_IN
                        ,NULL                               -- TOTAL_TP_REVENUE_OUT
                        ,NULL                               -- TOTAL_REVENUE_ADJ
                        ,NULL                               -- TOTAL_LENT_RESOURCE_COST
                        ,NULL                               -- TOTAL_TP_COST_IN
                        ,NULL                               -- TOTAL_TP_COST_OUT
                        ,NULL                               -- TOTAL_COST_ADJ
                        ,NULL                               -- TOTAL_UNASSIGNED_TIME_COST
                        ,NULL                               -- TOTAL_UTILIZATION_PERCENT
                        ,NULL                               -- TOTAL_UTILIZATION_HOURS
                        ,NULL                               -- TOTAL_UTILIZATION_ADJ
                        ,NULL                               -- TOTAL_CAPACITY
                        ,NULL                               -- TOTAL_HEAD_COUNT
                        ,NULL                               -- TOTAL_HEAD_COUNT_ADJ
                        ,'USER_ENTERED'                     -- RESOURCE_ASSIGNMENT_TYPE
                        ,NULL                               -- TOTAL_PROJECT_RAW_COST
                        ,NULL                               -- TOTAL_PROJECT_BURDENED_COST
                        ,NULL                               -- TOTAL_PROJECT_REVENUE
                        ,NULL                               -- PARENT_ASSIGNMENT_ID
                        ,NULL                               -- WBS_ELEMENT_VERSION_ID
                        ,l_targ_rbs_element_id_tbl(kk)      -- RBS_ELEMENT_ID
                        ,l_planning_start_date_tbl(kk)      -- PLANNING_START_DATE
                        ,l_planning_end_date_tbl(kk)        -- PLANNING_END_DATE
                        ,l_targ_spread_curve_id_tbl(kk)     -- SPREAD_CURVE_ID
                        ,l_targ_etc_method_code_tbl(kk)     -- ETC_METHOD_CODE
                        ,l_targ_resource_type_code_tbl(kk)  -- RES_TYPE_CODE
                        ,NULL                               -- ATTRIBUTE_CATEGORY
                        ,NULL                               -- ATTRIBUTE1
                        ,NULL                               -- ATTRIBUTE2
                        ,NULL                               -- ATTRIBUTE3
                        ,NULL                               -- ATTRIBUTE4
                        ,NULL                               -- ATTRIBUTE5
                        ,NULL                               -- ATTRIBUTE6
                        ,NULL                               -- ATTRIBUTE7
                        ,NULL                               -- ATTRIBUTE8
                        ,NULL                               -- ATTRIBUTE9
                        ,NULL                               -- ATTRIBUTE10
                        ,NULL                               -- ATTRIBUTE11
                        ,NULL                               -- ATTRIBUTE12
                        ,NULL                               -- ATTRIBUTE13
                        ,NULL                               -- ATTRIBUTE14
                        ,NULL                               -- ATTRIBUTE15
                        ,NULL                               -- ATTRIBUTE16
                        ,NULL                               -- ATTRIBUTE17
                        ,NULL                               -- ATTRIBUTE18
                        ,NULL                               -- ATTRIBUTE19
                        ,NULL                               -- ATTRIBUTE20
                        ,NULL                               -- ATTRIBUTE21
                        ,NULL                               -- ATTRIBUTE22
                        ,NULL                               -- ATTRIBUTE23
                        ,NULL                               -- ATTRIBUTE24
                        ,NULL                               -- ATTRIBUTE25
                        ,NULL                               -- ATTRIBUTE26
                        ,NULL                               -- ATTRIBUTE27
                        ,NULL                               -- ATTRIBUTE28
                        ,NULL                               -- ATTRIBUTE29
                        ,NULL                               -- ATTRIBUTE30
                        ,l_targ_fc_res_type_code_tbl(kk)    -- FC_RES_TYPE_CODE
                        ,l_targ_resource_class_code_tbl(kk) -- RESOURCE_CLASS_CODE
                        ,l_targ_organization_id_tbl(kk)     -- ORGANIZATION_ID
                        ,l_targ_job_id_tbl(kk)              -- JOB_ID
                        ,l_targ_person_id_tbl(kk)           -- PERSON_ID
                        ,l_targ_expenditure_type_tbl(kk)    -- EXPENDITURE_TYPE
                        ,l_targ_expend_category_tbl(kk)     -- EXPENDITURE_CATEGORY
                        ,l_targ_rev_category_code_tbl(kk)   -- REVENUE_CATEGORY_CODE
                        ,l_targ_event_type_tbl(kk)          -- EVENT_TYPE
                        ,l_targ_supplier_id_tbl(kk)         -- SUPPLIER_ID
                        ,l_targ_non_labor_resource_tbl(kk)  -- NON_LABOR_RESOURCE
                        ,l_targ_bom_resource_id_tbl(kk)     -- BOM_RESOURCE_ID
                        ,l_targ_inventory_item_id_tbl(kk)   -- INVENTORY_ITEM_ID
                        ,l_targ_item_category_id_tbl(kk)    -- ITEM_CATEGORY_ID
                        ,1                                  -- RECORD_VERSION_NUMBER
                        ,NULL                               -- BILLABLE_PERCENT
                        , Decode(p_calling_context, null, null, -- BUG 3934574
                                  'BUDGET_GENERATION', 'CHANGE_DOCUMENTS',
                                  'FORECAST_GENERATION','CHANGE_DOCUMENTS') -- TRANSACTION_SOURCE_CODE
                        ,l_targ_mfc_cost_type_id_tbl(kk)    -- MFC_COST_TYPE_ID
                        ,NULL                               -- PROCURE_RESOURCE_FLAG
                        ,NULL                               -- ASSIGNMENT_DESCRIPTION
                        ,l_targ_incured_by_res_flag_tbl(kk) -- INCURRED_BY_RES_FLAG
                        ,NULL                               -- RATE_JOB_ID
                        ,l_targ_RATE_EXPEND_TYPE_tbl(kk)    -- RATE_EXPENDITURE_TYPE
                        ,NULL                               -- TA_DISPLAY_FLAG
                        ,DECODE(l_targ_spread_curve_id_tbl(kk),
                                  l_spread_curve_id, l_targ_sp_fixed_date_tbl(kk),
                                  NULL)                     -- SP_FIXED_DATE -- Bug 8350296
                        ,l_targ_person_type_code_tbl(kk)    -- PERSON_TYPE_CODE
                        ,l_targ_RATE_BASED_FLAG_tbl(kk)     -- RATE_BASED_FLAG
                        ,l_targ_RES_RATE_BASED_FLAG_tbl(kk) -- RESOURCE_RATE_BASED_FLAG IPM Arch Enhancement
                        ,NULL                               -- USE_TASK_SCHEDULE_FLAG
                        ,l_targ_RATE_EXP_FC_CUR_COD_tbl(kk) -- RATE_EXP_FUNC_CURR_CODE
                        ,l_targ_RATE_EXPEND_ORG_ID_tbl(kk)  -- RATE_EXPENDITURE_ORG_ID
                        ,l_targ_INCR_BY_RES_CLS_COD_tbl(kk) -- INCUR_BY_RES_CLASS_CODE
                        ,l_targ_INCUR_BY_ROLE_ID_tbl(kk)    -- INCUR_BY_ROLE_ID
                        ,l_targ_project_role_id_tbl(kk)     -- PROJECT_ROLE_ID
                        ,l_targ_RESOURCE_CLASS_FLAG_tbl(kk) -- RESOURCE_CLASS_FLAG
                        ,l_targ_NAMED_ROLE_tbl(kk)          -- NAMED_ROLE
                        ,l_targ_txn_accum_header_id_tbl(kk) -- TXN ACCUM HEADER ID
                 FROM    dual
                 WHERE  L_ra_dml_code_tbl(kk)='INSERT';


            IF P_PA_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Done with bulk insert into PRA';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;

            --dbms_output.put_line('I19');

            --The pl/sql tbls prepared thru this DML will be used later while calling the PJI reporting API.
            --It is assumed that all the resource assignments that are updated are available in the below
            --pl/sql tbls. Hence changing the WHERE clause of this DML will have an impact on the way these
            --tbls are used . Bug 3678314

            -- Bug 3934574 The following business rules are incorporated in the update
            -- 1) If p_calling_context is null, null out transaction source code
            -- 2) If p_calling_context is generation
            --       a) if retain manually edited lines is Y do not update ras with transaction source code as null
            --       b) for ras that can be updated do not override transaction source code if there are already amounts
            --          if no amounts stamp transaction source code as 'CHANGE DOCUMENTS'
            -- Please note that the select against pa_budget_lines is unnecessary when p_calling_context is null
            -- Howeever, in oracle 8i select can not be used inside a decode. So, two sqls are used for better performance
            -- Bug 4171006: Updating UOM and rate_based_flag as well with the values already derived.
            IF p_calling_context IN ('BUDGET_GENERATION','FORECAST_GENERATION') THEN
                FORALL kk IN L_targ_ra_id_tbl.FIRST ..L_targ_ra_id_tbl.LAST
                UPDATE pa_resource_assignments pra
                SET    PLANNING_START_DATE         = l_planning_start_date_tbl(kk),
                       PLANNING_END_DATE           = l_planning_end_date_tbl(kk),
                       UNIT_OF_MEASURE             = l_targ_unit_of_measure_tbl(kk), -- bug 4171006
                       TRANSACTION_SOURCE_CODE     =
                          (SELECT DECODE(COUNT(*),0,'CHANGE_DOCUMENTS',TRANSACTION_SOURCE_CODE)
                           FROM pa_budget_lines pbl
                           WHERE  pbl.resource_assignment_id = pra.resource_assignment_id),
                       RATE_BASED_FLAG             = l_targ_RATE_BASED_FLAG_tbl(kk), -- bug 4171006
                       LAST_UPDATE_DATE            = sysdate,
                       LAST_UPDATED_BY             = fnd_global.user_id,
                       LAST_UPDATE_LOGIN           = fnd_global.login_id,
                       RECORD_VERSION_NUMBER       = NVL( RECORD_VERSION_NUMBER, 0 )  + 1
                WHERE  l_ra_dml_code_tbl (kk)= 'UPDATE' -- Bug 3662136
                AND    resource_assignment_id=l_targ_ra_id_tbl(kk)
                RETURNING
                task_id,
                rbs_element_id,
                resource_class_code,
                rate_based_flag,
                resource_assignment_id
                BULK COLLECT INTO
                l_upd_ra_task_id_tbl,
                l_upd_ra_rbs_elem_id_tbl,
                l_upd_ra_res_class_code_tbl,
                l_upd_ra_rbf_tbl,
                l_upd_ra_res_asmt_id_tbl;
            ELSE
                FORALL kk IN L_targ_ra_id_tbl.FIRST ..L_targ_ra_id_tbl.LAST
                UPDATE pa_resource_assignments pra
                SET    PLANNING_START_DATE         = l_planning_start_date_tbl(kk),
                       PLANNING_END_DATE           = l_planning_end_date_tbl(kk),
                       UNIT_OF_MEASURE             = l_targ_unit_of_measure_tbl(kk), -- bug 4171006
                       TRANSACTION_SOURCE_CODE     = null,
                       RATE_BASED_FLAG             = l_targ_RATE_BASED_FLAG_tbl(kk), -- bug 4171006
                       LAST_UPDATE_DATE            = sysdate,
                       LAST_UPDATED_BY             = fnd_global.user_id,
                       LAST_UPDATE_LOGIN           = fnd_global.login_id,
                       RECORD_VERSION_NUMBER       = NVL( RECORD_VERSION_NUMBER, 0 )  + 1
                WHERE  l_ra_dml_code_tbl (kk)= 'UPDATE' -- Bug 3662136
                AND    resource_assignment_id=l_targ_ra_id_tbl(kk)
                RETURNING
                task_id,
                rbs_element_id,
                resource_class_code,
                rate_based_flag,
                resource_assignment_id
                BULK COLLECT INTO
                l_upd_ra_task_id_tbl,
                l_upd_ra_rbs_elem_id_tbl,
                l_upd_ra_res_class_code_tbl,
                l_upd_ra_rbf_tbl,
                l_upd_ra_res_asmt_id_tbl;
            END IF;
            -- For bug 3814932
            --At this point in code, l_partial_factor can be 0 only if the user has chosen to implement 0 amount
            --into target. Please note that if the total amount in the change order itself is 0 parital factor
            --will be 1. It will be 0 only if the user did not chose to transfer amounts from source to target.
            --Hence budget lines need not be copied.

            IF l_partial_factor<>0 THEN

                IF P_PA_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:= 'Done with bulk update of PRA';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 END IF;


                l_same_multi_curr_flag := 'N';
                IF  l_src_multi_curr_flag  = l_targ_multi_curr_flag THEN
                  l_same_multi_curr_flag := 'Y';
                END IF;

                IF P_PA_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:= 'Done with deriving elem ver ids.';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                END IF;

                --dbms_output.put_line('I20');


                --dbms_output.put_line('I22');
                IF l_src_time_phased_code = 'N' AND (l_targ_time_phased_code = 'P' OR l_targ_time_phased_code = 'G') THEN

                   IF l_src_resource_list_id = l_targ_resource_list_id THEN

                      IF P_PA_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:= 'About to fire select for deriving params to calc API. Same Rls';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                      END IF;


                      SELECT get_mapped_ra_id(get_task_id(l_targ_plan_level_code,pbls.task_id),pbls.resource_list_member_id),
                      DECODE(l_copy_pfc_for_txn_amt_flag,'Y',l_projfunc_currency_code,
                         DECODE(l_same_multi_curr_flag,'Y', pbls.txn_currency_code,l_project_currency_code)),
                      'N', --delete
                      'Y', --spread
                      decode(l_cost_impl_flag,'Y',pbls.quantity,decode(l_rev_impl_flag,'Y',
                                                              decode(l_impl_qty_tbl(j),'Y', nvl(pbls.quantity,0) * l_partial_factor,0),0)) + nvl(pblt.quantity,0), --total
                      Decode(l_cost_impl_flag ,'Y',DECODE(l_copy_pfc_for_txn_amt_flag,'Y', nvl(pbls.raw_cost,nvl(pbls.txn_raw_cost,0)),
                                                   DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_raw_cost,0),
                                                   nvl(pbls.project_raw_cost,nvl(pbls.txn_raw_cost,0)))),0) +
                      DECODE(l_copy_pfc_for_txn_amt_flag,'Y', nvl(pblt.raw_cost,nvl(pblt.txn_raw_cost,0)),
                                                   DECODE(l_same_multi_curr_flag, 'Y', nvl(pblt.txn_raw_cost,0),
                                                   nvl(pblt.project_raw_cost,nvl(pblt.txn_raw_cost,0)))) , --total
                      Decode(l_cost_impl_flag ,'Y',DECODE(l_copy_pfc_for_txn_amt_flag,'Y', nvl(pbls.burdened_cost,nvl(pbls.txn_burdened_cost,0)),
                                                   DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_burdened_cost,0),
                                                   nvl(pbls.project_burdened_cost,nvl(pbls.txn_burdened_cost,0)))),0) +
                      DECODE(l_copy_pfc_for_txn_amt_flag,'Y', nvl(pblt.burdened_cost,nvl(pblt.txn_burdened_cost,0)),
                                                   DECODE(l_same_multi_curr_flag, 'Y', nvl(pblt.txn_burdened_cost,0),
                                                   nvl(pblt.project_burdened_cost,nvl(pblt.txn_burdened_cost,0)))), --total
                      Decode(l_rev_impl_flag ,'Y',DECODE(l_copy_pfc_for_txn_amt_flag,'Y', nvl(pbls.revenue,nvl(pbls.txn_revenue,0)),
                                                   DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_revenue,0),
                                                        nvl(pbls.project_revenue,nvl(pbls.txn_revenue,0)))),0)*l_partial_factor  +
                      DECODE(l_copy_pfc_for_txn_amt_flag,'Y', nvl(pblt.revenue,nvl(pblt.txn_revenue,0)),
                                                   DECODE(l_same_multi_curr_flag, 'Y', nvl(pblt.txn_revenue,0),
                                                        nvl(pblt.project_revenue,nvl(pblt.txn_revenue,0)))), --total
                      NULL,
                      NULL,
                      NULL
                      BULK COLLECT INTO
                      l_res_assignment_id_tbl,
                      l_currency_code_tbl,
                      l_delete_budget_lines_tbl,
                      l_spread_amount_flags_tbl,
                      l_total_quantity_tbl,
                      l_total_raw_cost_tbl,
                      l_total_burdened_cost_tbl,
                      l_total_revenue_tbl,
                      l_bl_TXN_COST_RATE_OVERIDE_tbl,
                      l_bl_BURDEN_COST_RAT_OVRID_tbl,
                      l_bl_TXN_BILL_RATE_OVERRID_tbl
                      from  (SELECT pra.resource_assignment_id resource_assignment_id,
                                    pra.task_id task_id,
                                    pra.resource_list_member_id resource_list_member_id,
                                    sum(quantity) quantity,
                                    sum(pbl.txn_raw_cost) txn_raw_cost,
                                    sum(pbl.txn_burdened_cost) txn_burdened_cost,
                                    sum(pbl.txn_revenue) txn_revenue,
                                    sum(pbl.project_raw_cost) project_raw_cost,
                                    sum(pbl.project_burdened_cost) project_burdened_cost,
                                    sum(pbl.project_revenue) project_revenue,
                                    sum(pbl.raw_cost) raw_cost,
                                    sum(pbl.burdened_cost) burdened_cost,
                                    sum(pbl.revenue) revenue,
                                    DECODE(l_copy_pfc_for_txn_amt_flag,'Y',l_projfunc_currency_code,
                                           DECODE(l_same_multi_curr_flag,'Y', pbl.txn_currency_code,l_project_currency_code)) txn_currency_code
                             FROM   pa_budget_lines pbl,
                                    pa_resource_assignments pra
                             WHERE  pbl.resource_assignment_id = pra.resource_assignment_id
                             AND    pra.budget_version_id=l_src_ver_id_tbl(j)
                             GROUP BY pra.resource_assignment_id, pra.task_id, pra.resource_list_member_id,
                                      DECODE(l_copy_pfc_for_txn_amt_flag,'Y',l_projfunc_currency_code,
                                             DECODE(l_same_multi_curr_flag,'Y', pbl.txn_currency_code,l_project_currency_code))  ) pbls,
                            (SELECT pbl.resource_assignment_id,
                                    sum(quantity) quantity,
                                    sum(pbl.txn_raw_cost) txn_raw_cost,
                                    sum(pbl.txn_burdened_cost) txn_burdened_cost,
                                    sum(pbl.txn_revenue) txn_revenue,
                                    sum(pbl.project_raw_cost) project_raw_cost,
                                    sum(pbl.project_burdened_cost) project_burdened_cost,
                                    sum(pbl.project_revenue) project_revenue,
                                    sum(pbl.raw_cost) raw_cost,
                                    sum(pbl.burdened_cost) burdened_cost,
                                    sum(pbl.revenue) revenue,
                                    pbl.txn_currency_code
                             FROM   pa_budget_lines pbl
                             WHERE  pbl.budget_Version_id = p_budget_version_id
                             GROUP BY pbl.resource_assignment_id, pbl.txn_currency_code)pblt
                      where get_mapped_ra_id(get_task_id(l_targ_plan_level_code,pbls.task_id),pbls.resource_list_member_id)=pblt.resource_assignment_id(+)
                      and   pblt.txn_Currency_code(+)= pbls.txn_currency_code;
                      IF P_PA_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:= 'Done with select for deriving params to calc API. Same Rls';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                      END IF;


                   ELSE

                      IF P_PA_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:= 'About to bulk collect BLs with diff RLs for calling calc API';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                      END IF;

                      select get_mapped_ra_id(get_task_id(l_targ_plan_level_code,pbls.task_id),pbls.resource_list_member_id),
                      DECODE(l_copy_pfc_for_txn_amt_flag,'Y',l_projfunc_currency_code,
                         DECODE(l_same_multi_curr_flag,'Y', pbls.txn_currency_code,l_project_currency_code)),
                      'N', --delete
                      'Y', --spread
                      decode(l_cost_impl_flag,'Y',pbls.quantity,decode(l_rev_impl_flag,'Y',
                                                              decode(l_impl_qty_tbl(j),'Y', nvl(pbls.quantity,0) * l_partial_factor,0),0)) +
                                                                     nvl(pblt.quantity,0), --total
                      Decode(l_cost_impl_flag ,'Y',DECODE(l_copy_pfc_for_txn_amt_flag,'Y', nvl(pbls.raw_cost,nvl(pbls.txn_raw_cost,0)),
                                                   DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_raw_cost,0),
                                                   nvl(pbls.project_raw_cost,nvl(pbls.txn_raw_cost,0)))),0) +
                      DECODE(l_copy_pfc_for_txn_amt_flag,'Y', nvl(pblt.raw_cost,nvl(pblt.txn_raw_cost,0)),
                                                DECODE(l_same_multi_curr_flag, 'Y', nvl(pblt.txn_raw_cost,0),
                                                       nvl(pblt.project_raw_cost,nvl(pblt.txn_raw_cost,0)))), --total
                      Decode(l_cost_impl_flag ,'Y',DECODE(l_copy_pfc_for_txn_amt_flag,'Y', nvl(pbls.burdened_cost,nvl(pbls.txn_burdened_cost,0)),
                                                   DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_burdened_cost,0),
                                                   nvl(pbls.project_burdened_cost,nvl(pbls.txn_burdened_cost,0)))),0) +
                      DECODE(l_copy_pfc_for_txn_amt_flag,'Y', nvl(pblt.burdened_cost,nvl(pblt.txn_burdened_cost,0)),
                                                   DECODE(l_same_multi_curr_flag, 'Y', nvl(pblt.txn_burdened_cost,0),
                                                   nvl(pblt.project_burdened_cost,nvl(pblt.txn_burdened_cost,0)))), --total
                      Decode(l_rev_impl_flag ,'Y',DECODE(l_copy_pfc_for_txn_amt_flag,'Y', nvl(pbls.revenue,nvl(pbls.txn_revenue,0)),
                                                   DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_revenue,0),
                                                        nvl(pbls.project_revenue,nvl(pbls.txn_revenue,0)))),0)*l_partial_factor +
                      DECODE(l_copy_pfc_for_txn_amt_flag,'Y', nvl(pblt.revenue,nvl(pblt.txn_revenue,0)),
                                                   DECODE(l_same_multi_curr_flag, 'Y', nvl(pblt.txn_revenue,0),
                                                        nvl(pblt.project_revenue,nvl(pblt.txn_revenue,0)))),  --total
                      NULL,
                      NULL,
                      NULL
                      BULK COLLECT INTO
                      l_res_assignment_id_tbl,
                      l_currency_code_tbl,
                      l_delete_budget_lines_tbl,
                      l_spread_amount_flags_tbl,
                      l_total_quantity_tbl,
                      l_total_raw_cost_tbl,
                      l_total_burdened_cost_tbl,
                      l_total_revenue_tbl,
                      l_bl_TXN_COST_RATE_OVERIDE_tbl,
                      l_bl_BURDEN_COST_RAT_OVRID_tbl,
                      l_bl_TXN_BILL_RATE_OVERRID_tbl
                      from (SELECT pra.task_id task_id,
                                   tmp.resource_list_member_id resource_list_member_id,
                                   pra.resource_assignment_id resource_assignment_id,
                                   sum(quantity) quantity,
                                   sum(pbl.txn_raw_cost) txn_raw_cost,
                                   sum(pbl.txn_burdened_cost) txn_burdened_cost,
                                   sum(pbl.txn_revenue) txn_revenue,
                                   sum(pbl.project_raw_cost) project_raw_cost,
                                   sum(pbl.project_burdened_cost) project_burdened_cost,
                                   sum(pbl.project_revenue) project_revenue,
                                   sum(pbl.raw_cost) raw_cost,
                                   sum(pbl.burdened_cost) burdened_cost,
                                   sum(pbl.revenue) revenue,
                                   DECODE(l_copy_pfc_for_txn_amt_flag,'Y',l_projfunc_currency_code,
                                          DECODE(l_same_multi_curr_flag,'Y', pbl.txn_currency_code,l_project_currency_code)) txn_currency_code
                            FROM   pa_resource_assignments pra
                                  ,pa_res_list_map_tmp4 tmp
                                  ,pa_budget_lines pbl
                            WHERE  pra.resource_assignment_id=tmp.txn_source_id
                            AND    pra.budget_version_id=l_src_ver_id_tbl(j)
                            AND    pbl.resource_assignment_id=pra.resource_assignment_id
                            GROUP BY pra.resource_assignment_id, pra.task_id, tmp.resource_list_member_id,
                                     DECODE(l_copy_pfc_for_txn_amt_flag,'Y',l_projfunc_currency_code,
                                          DECODE(l_same_multi_curr_flag,'Y', pbl.txn_currency_code,l_project_currency_code)) ) pbls,
                            (SELECT pbl.resource_assignment_id resource_assignment_id,
                                    sum(quantity) quantity,
                                    sum(pbl.txn_raw_cost) txn_raw_cost,
                                    sum(pbl.txn_burdened_cost) txn_burdened_cost,
                                    sum(pbl.txn_revenue) txn_revenue,
                                    sum(pbl.project_raw_cost) project_raw_cost,
                                    sum(pbl.project_burdened_cost) project_burdened_cost,
                                    sum(pbl.project_revenue) project_revenue,
                                    sum(pbl.raw_cost) raw_cost,
                                    sum(pbl.burdened_cost) burdened_cost,
                                    sum(pbl.revenue) revenue,
                                    pbl.txn_currency_code txn_currency_code
                             FROM   pa_budget_lines pbl
                             WHERE  pbl.budget_Version_id = p_budget_version_id
                             GROUP BY pbl.resource_assignment_id, pbl.txn_currency_code)pblt
                      where get_mapped_ra_id(get_task_id(l_targ_plan_level_code,pbls.task_id),pbls.resource_list_member_id)=pblt.resource_assignment_id(+)
                      and   pblt.txn_currency_code(+)= pbls.txn_currency_code;

                      IF P_PA_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:= 'Done with bulk collect BLs with diff RLs for calling calc API';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                      END IF;

                   END IF;

                   --dbms_output.put_line('I23');

                   IF l_res_assignment_id_tbl.COUNT>0 THEN

                     --The below loop will calculate the override rates. These override rates are required because
                     --the amounts in the source should be added to the corresponding amounts in the target and there
                     --should not be re-derivation of amounts in the target based on the changed quantity in the target.
                     --For example, Consider the implementaion of a COST impact into a cost and revenue together
                     --version. In this case the quantity in the target will change but this in turn should not change
                     --the revenue amount in the target as only cost amounts should be impacted in the target.

                     FOR kk IN  l_res_assignment_id_tbl.FIRST..l_res_assignment_id_tbl.LAST LOOP

                        IF P_PA_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Before finding the RBF flag for  l_res_assignment_id_tbl('||kk||')'||l_res_assignment_id_tbl(kk);
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;


                        FOR ww IN l_targ_ra_id_tbl.FIRST..l_targ_ra_id_tbl.LAST LOOP

                            IF P_PA_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage:= 'l_targ_ra_id_tbl('||ww||')'||l_targ_ra_id_tbl(ww);
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                            END IF;

                            IF l_targ_ra_id_tbl(ww)=l_res_assignment_id_tbl(kk) THEN

                              IF P_PA_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage:= 'Exiting with ww '||ww;
                                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                              END IF;

                              l_matching_index := ww;

                              EXIT;

                            END IF;

                        END LOOP;

                        IF P_PA_debug_mode = 'Y' THEN

                              pa_debug.g_err_stage:= 'l_matching_index is '||l_matching_index;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                        END IF;


                        IF  l_targ_RATE_BASED_FLAG_tbl(l_matching_index)='Y' THEN

                            l_amt_used_for_rate_calc := l_total_quantity_tbl(kk);

                        ELSE

                            l_amt_used_for_rate_calc := l_total_raw_cost_tbl(kk);

                        END IF;

                        IF l_amt_used_for_rate_calc=0 THEN

                            l_bl_TXN_COST_RATE_OVERIDE_tbl(kk):=0;
                            l_bl_BURDEN_COST_RAT_OVRID_tbl(kk):=0;
                            l_bl_TXN_BILL_RATE_OVERRID_tbl(kk):=0;

                        ELSE

                            l_bl_TXN_COST_RATE_OVERIDE_tbl(kk):=l_total_raw_cost_tbl(kk)/l_amt_used_for_rate_calc;
                            l_bl_BURDEN_COST_RAT_OVRID_tbl(kk):=l_total_burdened_cost_tbl(kk)/l_amt_used_for_rate_calc;
                            l_bl_TXN_BILL_RATE_OVERRID_tbl(kk):=l_total_revenue_tbl(kk)/l_amt_used_for_rate_calc;

                        END IF;


                     END LOOP;

                     IF P_PA_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:= 'Calling Calc';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

                          FOR kk IN l_res_assignment_id_tbl.FIRST..l_res_assignment_id_tbl.LAST LOOP

                              pa_debug.g_err_stage:= 'l_res_assignment_id_tbl('||KK||') IS'||l_res_assignment_id_tbl(kk);
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

                              pa_debug.g_err_stage:= 'l_delete_budget_lines_tbl('||KK||') IS'||l_delete_budget_lines_tbl(kk);
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

                              pa_debug.g_err_stage:= 'l_spread_amount_flags_tbl('||KK||') IS'||l_spread_amount_flags_tbl(kk);
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

                              pa_debug.g_err_stage:= 'l_currency_code_tbl('||KK||') IS'||l_currency_code_tbl(kk);
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

                              pa_debug.g_err_stage:= 'l_total_quantity_tbl('||KK||') IS'||l_total_quantity_tbl(kk);
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

                              pa_debug.g_err_stage:= 'l_total_raw_cost_tbl('||KK||') IS'||l_total_raw_cost_tbl(kk);
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

                              pa_debug.g_err_stage:= 'l_total_burdened_cost_tbl('||KK||') IS'||l_total_burdened_cost_tbl(kk);
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

                              pa_debug.g_err_stage:= 'l_total_revenue_tbl('||KK||') IS'||l_total_revenue_tbl(kk);
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

                              pa_debug.g_err_stage:= 'l_bl_TXN_COST_RATE_OVERIDE_tbl('||KK||') IS'||l_bl_TXN_COST_RATE_OVERIDE_tbl(kk);
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

                              pa_debug.g_err_stage:= 'l_bl_BURDEN_COST_RAT_OVRID_tbl('||KK||') IS'||l_bl_BURDEN_COST_RAT_OVRID_tbl(kk);
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

                              pa_debug.g_err_stage:= 'l_bl_TXN_BILL_RATE_OVERRID_tbl('||KK||') IS'||l_bl_TXN_BILL_RATE_OVERRID_tbl(kk);
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);

                          END LOOP;

                     END IF;

                     PA_FP_CALC_PLAN_PKG.calculate(
                      p_project_id                 =>   l_project_id
                     ,p_budget_version_id          =>   p_budget_version_id
                     ,p_source_context             =>   PA_FP_CONSTANTS_PKG.G_CALC_API_RESOURCE_CONTEXT
                     ,p_resource_assignment_tab    =>   l_res_assignment_id_tbl
                     ,p_delete_budget_lines_tab    =>   l_delete_budget_lines_tbl
                     ,p_spread_amts_flag_tab       =>   l_spread_amount_flags_tbl
                     ,p_txn_currency_code_tab      =>   l_currency_code_tbl
                     ,p_total_qty_tab              =>   l_total_quantity_tbl
                     ,p_total_raw_cost_tab         =>   l_total_raw_cost_tbl -- dervie
                     ,p_total_burdened_cost_tab    =>   l_total_burdened_cost_tbl -- dervie
                     ,p_total_revenue_tab          =>   l_total_revenue_tbl -- derive
                     ,p_rw_cost_rate_override_tab  =>   l_bl_TXN_COST_RATE_OVERIDE_tbl
                     ,p_b_cost_rate_override_tab   =>   l_bl_BURDEN_COST_RAT_OVRID_tbl
                     ,p_bill_rate_override_tab     =>   l_bl_TXN_BILL_RATE_OVERRID_tbl
                     ,p_raTxn_rollup_api_call_flag =>   p_raTxn_rollup_api_call_flag --Indicates whether the pa_resource_asgn_curr maintenance api should be called
                     ,x_return_status              =>   l_return_status
                     ,x_msg_count                  =>   l_msg_count
                     ,x_msg_data                   =>   l_msg_data);

                    IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                         IF P_PA_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Error in calculate';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                         END IF;
                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;

                    --dbms_output.put_line('I24');

                   END IF;--IF l_res_assignment_id_tbl.COUNT>0 THEN

                END IF;--IF l_src_time_phased_code = 'N' AND (l_targ_time_phased_code = 'P' OR l_targ_time_phased_code = 'G') THEN

                --Get the budget line sequence before inserting data into budget lines. After inserting the budget lines
                --the sequence is again compared to see the no. of budget lines that have got inserted. Since pa_budget_lines_s.currval
                --is used at a later part of code this SELECT should not be removed
                SELECT pa_budget_lines_s.nextval
                INTO   l_id_before_bl_insertion
                FROM   DUAL;

                --dbms_output.put_line('I25');
                IF l_src_time_phased_code  = l_targ_time_phased_code OR l_targ_time_phased_code = 'N' THEN
                   IF l_targ_time_phased_code = 'N' THEN
                     IF l_src_resource_list_id = l_targ_resource_list_id THEN

                        IF P_PA_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'About to bulk insert Budget lines with same RLs';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;

                        --dbms_output.put_line('I26');
                        FORALL kk in L_targ_ra_id_tbl.FIRST ..L_targ_ra_id_tbl.LAST
                            INSERT INTO PA_BUDGET_LINES(
                                    RESOURCE_ASSIGNMENT_ID,
                                    START_DATE,
                                    LAST_UPDATE_DATE,
                                    LAST_UPDATED_BY,
                                    CREATION_DATE,
                                    CREATED_BY,
                                    LAST_UPDATE_LOGIN,
                                    END_DATE,
                                    PERIOD_NAME,
                                    QUANTITY,
                                    RAW_COST,
                                    BURDENED_COST,
                                    REVENUE,
                                    CHANGE_REASON_CODE,
                                    DESCRIPTION,
                                    ATTRIBUTE_CATEGORY,
                                    ATTRIBUTE1,
                                    ATTRIBUTE2,
                                    ATTRIBUTE3,
                                    ATTRIBUTE4,
                                    ATTRIBUTE5,
                                    ATTRIBUTE6,
                                    ATTRIBUTE7,
                                    ATTRIBUTE8,
                                    ATTRIBUTE9,
                                    ATTRIBUTE10,
                                    ATTRIBUTE11,
                                    ATTRIBUTE12,
                                    ATTRIBUTE13,
                                    ATTRIBUTE14,
                                    ATTRIBUTE15,
                                    RAW_COST_SOURCE,
                                    BURDENED_COST_SOURCE,
                                    QUANTITY_SOURCE,
                                    REVENUE_SOURCE,
                                    PM_PRODUCT_CODE,
                                    PM_BUDGET_LINE_REFERENCE,
                                    COST_REJECTION_CODE,
                                    REVENUE_REJECTION_CODE,
                                    BURDEN_REJECTION_CODE,
                                    OTHER_REJECTION_CODE,
                                    CODE_COMBINATION_ID,
                                    CCID_GEN_STATUS_CODE,
                                    CCID_GEN_REJ_MESSAGE,
                                    REQUEST_ID,
                                    BORROWED_REVENUE,
                                    TP_REVENUE_IN,
                                    TP_REVENUE_OUT,
                                    REVENUE_ADJ,
                                    LENT_RESOURCE_COST,
                                    TP_COST_IN,
                                    TP_COST_OUT,
                                    COST_ADJ,
                                    UNASSIGNED_TIME_COST,
                                    UTILIZATION_PERCENT,
                                    UTILIZATION_HOURS,
                                    UTILIZATION_ADJ,
                                    CAPACITY,
                                    HEAD_COUNT,
                                    HEAD_COUNT_ADJ,
                                    PROJFUNC_CURRENCY_CODE,
                                    PROJFUNC_COST_RATE_TYPE,
                                    PROJFUNC_COST_EXCHANGE_RATE,
                                    PROJFUNC_COST_RATE_DATE_TYPE,
                                    PROJFUNC_COST_RATE_DATE,
                                    PROJFUNC_REV_RATE_TYPE,
                                    PROJFUNC_REV_EXCHANGE_RATE,
                                    PROJFUNC_REV_RATE_DATE_TYPE,
                                    PROJFUNC_REV_RATE_DATE,
                                    PROJECT_CURRENCY_CODE,
                                    PROJECT_COST_RATE_TYPE,
                                    PROJECT_COST_EXCHANGE_RATE,
                                    PROJECT_COST_RATE_DATE_TYPE,
                                    PROJECT_COST_RATE_DATE,
                                    PROJECT_RAW_COST,
                                    PROJECT_BURDENED_COST,
                                    PROJECT_REV_RATE_TYPE,
                                    PROJECT_REV_EXCHANGE_RATE,
                                    PROJECT_REV_RATE_DATE_TYPE,
                                    PROJECT_REV_RATE_DATE,
                                    PROJECT_REVENUE,
                                    TXN_CURRENCY_CODE,
                                    TXN_RAW_COST,
                                    TXN_BURDENED_COST,
                                    TXN_REVENUE,
                                    BUCKETING_PERIOD_CODE,
                                    BUDGET_LINE_ID,
                                    BUDGET_VERSION_ID,
                                    TXN_STANDARD_COST_RATE,
                                    TXN_COST_RATE_OVERRIDE,
                                    COST_IND_COMPILED_SET_ID,
                          --            TXN_BURDEN_MULTIPLIER,
                          --            TXN_BURDEN_MULTIPLIER_OVERRIDE,
                                    TXN_STANDARD_BILL_RATE,
                                    TXN_BILL_RATE_OVERRIDE,
                                    TXN_MARKUP_PERCENT,
                                    TXN_MARKUP_PERCENT_OVERRIDE,
                                    TXN_DISCOUNT_PERCENTAGE,
                                    TRANSFER_PRICE_RATE,
                                    BURDEN_COST_RATE,
                                    BURDEN_COST_RATE_OVERRIDE,
                                    PC_CUR_CONV_REJECTION_CODE,
                                    PFC_CUR_CONV_REJECTION_CODE
                                    )
                              SELECT  pbl.resource_assignment_id,
                                    l_planning_start_date_tbl(kk) start_date,
                                    pbl.last_update_date,
                                    pbl.last_updated_by,
                                    pbl.creation_date,
                                    pbl.created_by,
                                    pbl.last_update_login,
                                    l_planning_end_date_tbl(kk) end_date,
                                    pbl.period_name,
                                    DECODE(l_targ_rate_based_flag_tbl(kk),
                                           'N',DECODE(l_target_version_type,
                                                      'REVENUE',pbl.txn_revenue
                                                               ,pbl.txn_raw_cost),
                                           pbl.quantity),
                                    pbl.raw_cost,
                                    pbl.burdened_cost,
                                    pbl.revenue,
                                    pbl.change_reason_code,
                                    pbl.description,
                                    pbl.attribute_category,
                                    pbl.attribute1,
                                    pbl.attribute2,
                                    pbl.attribute3,
                                    pbl.attribute4,
                                    pbl.attribute5,
                                    pbl.attribute6,
                                    pbl.attribute7,
                                    pbl.attribute8,
                                    pbl.attribute9,
                                    pbl.attribute10,
                                    pbl.attribute11,
                                    pbl.attribute12,
                                    pbl.attribute13,
                                    pbl.attribute14,
                                    pbl.attribute15,
                                    pbl.raw_cost_source,
                                    pbl.burdened_cost_source,
                                    pbl.quantity_source,
                                    pbl.revenue_source,
                                    pbl.pm_product_code,
                                    pbl.pm_budget_line_reference,
                                    pbl.cost_rejection_code,
                                    pbl.revenue_rejection_code,
                                    pbl.burden_rejection_code,
                                    pbl.other_rejection_code,
                                    pbl.code_combination_id,
                                    pbl.ccid_gen_status_code,
                                    pbl.ccid_gen_rej_message,
                                    pbl.request_id,
                                    pbl.borrowed_revenue,
                                    pbl.tp_revenue_in,
                                    pbl.tp_revenue_out,
                                    pbl.revenue_adj,
                                    pbl.lent_resource_cost,
                                    pbl.tp_cost_in,
                                    pbl.tp_cost_out,
                                    pbl.cost_adj,
                                    pbl.unassigned_time_cost,
                                    pbl.utilization_percent,
                                    pbl.utilization_hours,
                                    pbl.utilization_adj,
                                    pbl.capacity,
                                    pbl.head_count,
                                    pbl.head_count_adj,
                                    pbl.projfunc_currency_code,
                                    pbl.projfunc_cost_rate_type,
                                    DECODE(l_cost_impl_flag,'Y', DECODE(l_targ_multi_curr_flag,'Y',
                                        Decode(decode(l_report_cost_using, 'R', nvl(pbl.txn_raw_cost,0),
                                                                  'B', nvl(pbl.txn_burdened_cost,0)),0,0,
                                            (decode(l_report_cost_using,'R',nvl(pbl.raw_cost,0),
                                                                  'B',nvl(pbl.burdened_cost,0)) /decode(l_report_cost_using,'R', pbl.txn_raw_cost,
                                                                                                            'B', pbl.txn_burdened_cost))),Null),Null), --Bug 3839273
                                    pbl.projfunc_cost_rate_date_type,
                                    pbl.projfunc_cost_rate_date,
                                    pbl.projfunc_rev_rate_type,
                                    Decode(l_rev_impl_flag,'Y',DECODE(l_targ_multi_curr_flag,'Y',  Decode(nvl(pbl.txn_revenue,0),0,0,nvl(pbl.revenue,0) / pbl.txn_revenue),Null),Null), --Bug 3839273
                                    pbl.projfunc_rev_rate_date_type,
                                    pbl.projfunc_rev_rate_date,
                                    pbl.project_currency_code,
                                    pbl.project_cost_rate_type,
                                    DECODE(l_cost_impl_flag,'Y', DECODE(l_targ_multi_curr_flag,'Y', Decode(decode(l_report_cost_using, 'R',nvl(pbl.txn_raw_cost,0),
                                                                  'B', nvl(pbl.txn_burdened_cost,0)),0,0,(decode(l_report_cost_using,'R',nvl(pbl.project_raw_cost,0),
                                                                         'B',nvl(pbl.project_burdened_cost,0)) / decode(l_report_cost_using,'R',pbl.txn_raw_cost,
                                                                         'B',pbl.txn_burdened_cost))),Null),Null), --Bug 3839273
                                    pbl.project_cost_rate_date_type,
                                    pbl.project_cost_rate_date,
                                    pbl.project_raw_cost,
                                    pbl.project_burdened_cost,
                                    pbl.project_rev_rate_type,
                                    Decode(l_rev_impl_flag,'Y',DECODE(l_targ_multi_curr_flag,'Y', Decode(nvl(pbl.txn_revenue,0),0,0,nvl(pbl.project_revenue,0) /pbl.txn_revenue),Null),Null), --Bug 3839273
                                    pbl.project_rev_rate_date_type,
                                    pbl.project_rev_rate_date,
                                    pbl.project_revenue,
                                    pbl.txn_currency_code,
                                    pbl.txn_raw_cost,
                                    pbl.txn_burdened_cost,
                                    pbl.txn_revenue,
                                    pbl.bucketing_period_code,
                                    pa_budget_lines_s.nextval,
                                    pbl.budget_version_id,
                                    pbl.txn_standard_cost_rate,
                                    DECODE(l_target_version_type,
                                         'REVENUE',pbl.txn_cost_rate_override,
                                          DECODE(l_targ_rate_based_flag_tbl(kk),
                                                'N',1,
                                                pbl.txn_cost_rate_override)),
                                    pbl.cost_ind_compiled_set_id,
                          --          pbl.  txn_burden_multiplier,
                          --          pbl.  txn_burden_multiplier_override,
                                    pbl.txn_standard_bill_rate,
                                    DECODE(l_target_version_type,
                                           'REVENUE',DECODE(l_targ_rate_based_flag_tbl(kk),
                                                            'N',1,
                                                            pbl.txn_bill_rate_override)
                                           ,pbl.txn_bill_rate_override),
                                    pbl.txn_markup_percent,
                                    pbl.txn_markup_percent_override,
                                    pbl.txn_discount_percentage,
                                    pbl.transfer_price_rate,
                                    pbl.burden_cost_rate,
                                    DECODE(l_target_version_type,
                                         'REVENUE',pbl.burden_cost_rate_override,
                                          DECODE(l_targ_rate_based_flag_tbl(kk),
                                                'Y',pbl.burden_cost_rate_override,
                                                 DECODE(nvl(pbl.txn_raw_cost,0),
                                                        0,null,
                                                        pbl.txn_burdened_cost/pbl.txn_raw_cost))),
                                    pbl.pc_cur_conv_rejection_code,
                                    pbl.pfc_cur_conv_rejection_code
                              FROM
                                 --The entire SELECT is moved to the sub query in FROM clause as nextval would not work with group by
                                (SELECT get_mapped_ra_id(get_task_id(l_targ_plan_level_code,pras.task_id), pras.resource_list_member_id) resource_assignment_id,
                                   sysdate last_update_date,
                                   fnd_global.user_id last_updated_by,
                                   sysdate creation_date,
                                   fnd_global.user_id created_by,
                                   fnd_global.login_id last_update_login,
                                   NULL period_name,
                                   decode(l_cost_impl_flag,
                                             'Y',sum(pbls.quantity),
                                             decode(l_rev_impl_flag,
                                                      'Y',decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),
                                                      null)) quantity,
                                   sum(Decode(l_cost_impl_flag ,'Y', pbls.raw_cost,null)) raw_cost,
                                   sum(Decode(l_cost_impl_flag ,'Y', pbls.burdened_cost,null)) burdened_cost,
                                   sum(Decode(l_rev_impl_flag ,'Y',  pbls.revenue,null))*l_partial_factor revenue,
                                   decode(count(pbls.budget_line_id),1,max(pbls.change_reason_code),null) change_reason_code,
                                   decode(count(pbls.budget_line_id),1,max(pbls.description),null) description,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute_category),null) attribute_category,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute1),null) attribute1,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute2),null) attribute2,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute3),null) attribute3,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute4),null) attribute4,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute5),null) attribute5,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute6),null) attribute6,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute7),null) attribute7,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute8),null) attribute8,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute9),null) attribute9,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute10),null) attribute10,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute11),null) attribute11,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute12),null) attribute12,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute13),null) attribute13,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute14),null) attribute14,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute15),null) attribute15,
                                   'I' raw_cost_source,
                                   'I' burdened_cost_source,
                                   'I' quantity_source,
                                   'I' revenue_source,
                                   decode(count(pbls.budget_line_id),1,max(pbls.pm_product_code),null) pm_product_code,
                                   decode(count(pbls.budget_line_id),1,max(pbls.pm_budget_line_reference),null) pm_budget_line_reference,
                                   decode(count(pbls.budget_line_id),1,max(pbls.cost_rejection_code),null) cost_rejection_code,
                                   decode(count(pbls.budget_line_id),1,max(pbls.revenue_rejection_code),null) revenue_rejection_code,
                                   decode(count(pbls.budget_line_id),1,max(pbls.burden_rejection_code),null) burden_rejection_code,
                                   decode(count(pbls.budget_line_id),1,max(pbls.other_rejection_code),null)other_rejection_code,
                                   decode(count(pbls.budget_line_id),1,max(pbls.code_combination_id),null) code_combination_id,
                                   decode(count(pbls.budget_line_id),1,max(pbls.ccid_gen_status_code),null) ccid_gen_status_code,
                                   decode(count(pbls.budget_line_id),1,max(pbls.CCID_GEN_REJ_MESSAGE),null) ccid_gen_rej_message,
                                   decode(count(pbls.budget_line_id),1,max(pbls.REQUEST_ID),null) request_id,
                                   decode(count(pbls.budget_line_id),1,max(pbls.BORROWED_REVENUE),null) borrowed_revenue,
                                   decode(count(pbls.budget_line_id),1,max(pbls.TP_REVENUE_IN),null) tp_revenue_in,
                                   decode(count(pbls.budget_line_id),1,max(pbls.TP_REVENUE_OUT),null) tp_revenue_out,
                                   decode(count(pbls.budget_line_id),1,max(pbls.REVENUE_ADJ),null) revenue_adj,
                                   decode(count(pbls.budget_line_id),1,max(pbls.LENT_RESOURCE_COST),null) lent_resource_cost,
                                   decode(count(pbls.budget_line_id),1,max(pbls.TP_COST_IN),null) tp_cost_in,
                                   decode(count(pbls.budget_line_id),1,max(pbls.TP_COST_OUT),null) tp_cost_out,
                                   decode(count(pbls.budget_line_id),1,max(pbls.COST_ADJ),null) cost_adj,
                                   decode(count(pbls.budget_line_id),1,max(pbls.UNASSIGNED_TIME_COST),null) unassigned_time_cost,
                                   decode(count(pbls.budget_line_id),1,max(pbls.UTILIZATION_PERCENT),null) utilization_percent,
                                   decode(count(pbls.budget_line_id),1,max(pbls.UTILIZATION_HOURS),null) utilization_hours,
                                   decode(count(pbls.budget_line_id),1,max(pbls.UTILIZATION_ADJ),null) utilization_adj,
                                   decode(count(pbls.budget_line_id),1,max(pbls.CAPACITY),null) capacity,
                                   decode(count(pbls.budget_line_id),1,max(pbls.HEAD_COUNT),null) head_count,
                                   decode(count(pbls.budget_line_id),1,max(pbls.HEAD_COUNT_ADJ),null) head_count_adj,
                                   l_projfunc_currency_code projfunc_currency_code,
                                   DECODE(l_cost_impl_flag,'Y', DECODE(l_targ_multi_curr_flag,'Y', 'User', null),Null) projfunc_cost_rate_type,
                                   null projfunc_cost_exchange_rate, --Bug 3839273
                                   null projfunc_cost_rate_date_type,
                                   null projfunc_cost_rate_date,
                                   Decode(l_rev_impl_flag,'Y',DECODE(l_targ_multi_curr_flag,'Y', 'User', null),Null) projfunc_rev_rate_type,
                                   null projfunc_rev_exchange_rate, --Bug 3839273
                                   null projfunc_rev_rate_date_type,
                                   null projfunc_rev_rate_date,
                                   l_project_currency_code project_currency_code ,
                                   DECODE(l_cost_impl_flag,'Y',DECODE(l_targ_multi_curr_flag, 'Y','User', null),Null) project_cost_rate_type,
                                   null project_cost_exchange_rate, --Bug 3839273
                                   null project_cost_rate_date_type,
                                   null project_cost_rate_date,
                                   sum(Decode(l_cost_impl_flag ,'Y',pbls.project_raw_cost,null)) project_raw_cost,
                                   sum(Decode(l_cost_impl_flag ,'Y',pbls.project_burdened_cost,null)) project_burdened_cost,
                                   Decode(l_rev_impl_flag, 'Y', DECODE(l_targ_multi_curr_flag, 'Y', 'User', null),Null) project_rev_rate_type,
                                   null project_rev_exchange_rate, --Bug 3839273
                                   null project_rev_rate_date_type,
                                   null project_rev_rate_date,
                                   sum(Decode(l_rev_impl_flag , 'Y', pbls.project_revenue,null))*l_partial_factor project_revenue,
                                   DECODE(l_copy_pfc_for_txn_amt_flag,'Y',l_projfunc_currency_code,DECODE(l_same_multi_curr_flag,'Y', pbls.txn_currency_code,l_project_currency_code)) txn_currency_code,

                                   --Bug 4224757. Code changes for bug#4224757 starts here
                                   SUM(decode(l_cost_impl_flag,'Y', decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.raw_cost,0),
                                   DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_raw_cost,0), nvl(pbls.project_raw_cost,0)))))
                                   txn_raw_cost,
                                   SUM(decode(l_cost_impl_flag,'Y', decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.burdened_cost,0),
                                   DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_burdened_cost,0),
                                   nvl(pbls.project_burdened_cost,0))))) txn_burdened_cost,
                                   SUM(decode(l_rev_impl_flag,'Y',decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.revenue,0),
                                   DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_revenue,0),
                                   nvl(pbls.project_revenue,0)))))*l_partial_factor txn_revenue,
                                   --Bug 4224757.. Code changes for bug#4224757 ends here

                                   null bucketing_period_code,
                                   p_budget_version_id  budget_version_id,
                                   decode(count(pbls.budget_line_id),1,max(pbls.txn_standard_cost_rate),null) txn_standard_cost_rate,

                                   --Bug 4224757. Code changes for bug#4224757 starts here
                                   decode(nvl(sum(pbls.quantity),0),0,0,SUM(decode(l_cost_impl_flag,'Y',
                                   decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.raw_cost,0), DECODE(l_same_multi_curr_flag, 'Y',
                                   nvl(pbls.txn_raw_cost,0), nvl(pbls.project_raw_cost,0))) ))/
                                   decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                                        decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null)))     txn_cost_rate_override,
                                   --Bug 4224757. Code changes for bug#4224757 ends here




                                   decode(count(pbls.budget_line_id),1,max(pbls.cost_ind_compiled_set_id),null) cost_ind_compiled_set_id,
                               --      decode(count(pbls.budget_line_id),1,max(pbls.txn_burden_multiplier),null),
                                   decode(count(pbls.budget_line_id),1,max(pbls.txn_standard_bill_rate),null) txn_standard_bill_rate ,

                                   --Bug 4224757. Code changes for bug#4224757 starts here
                                   decode(nvl(sum(pbls.quantity),0),0,0,sum(Decode(l_rev_impl_flag ,'Y',
                                          decode(l_copy_pfc_for_txn_amt_flag,'Y', nvl(pbls.revenue,0), DECODE(l_same_multi_curr_flag,
                                          'Y', nvl(pbls.txn_revenue,0), nvl(pbls.project_revenue,0)))))*l_partial_factor/
                                   decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                                        decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null)))txn_bill_rate_override,
                                   --Bug 4224757. Code changes for bug#4224757 ends here

                                   decode(count(pbls.budget_line_id),1,max(pbls.TXN_MARKUP_PERCENT),null)   txn_markup_percent,
                                   decode(count(pbls.budget_line_id),1,max(pbls.TXN_MARKUP_PERCENT_OVERRIDE),null) txn_markup_percent_override,
                                   decode(count(pbls.budget_line_id),1,max(pbls.TXN_DISCOUNT_PERCENTAGE),null)   txn_discount_percentage,
                                   decode(count(pbls.budget_line_id),1,max(pbls.TRANSFER_PRICE_RATE),null) transfer_price_rate,
                                   decode(count(pbls.budget_line_id),1,max(pbls.BURDEN_COST_RATE),null) burden_cost_rate,

                                   --Bug 4224757. Code changes for bug#4224757 starts here
                                   decode(nvl(sum(pbls.quantity),0),0,0,SUM(decode(l_cost_impl_flag,'Y',
                                   decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.burdened_cost,0), DECODE(l_same_multi_curr_flag,
                                   'Y', nvl(pbls.txn_burdened_cost,0), nvl(pbls.project_burdened_cost,0))) ))/
                                   decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                                        decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null))) burden_cost_rate_override,
                                   --Bug 4224757. Code changes for bug#4224757 ends here



                                   decode(count(pbls.budget_line_id),1,max(pbls.PC_CUR_CONV_REJECTION_CODE),null) pc_cur_conv_rejection_code,
                                   decode(count(pbls.budget_line_id),1,max(pbls.PFC_CUR_CONV_REJECTION_CODE),null) pfc_cur_conv_rejection_code
                              from   pa_budget_lines pbls,
                                   pa_resource_assignments pras
                              where  l_ra_dml_code_tbl(kk)='INSERT'
                              and    pras.resource_assignment_id = pbls.resource_assignment_id
                              and    pras.budget_version_id = l_src_ver_id_tbl(j)
                              and    PA_FP_CI_MERGE.get_mapped_ra_id(PA_FP_CI_MERGE.get_task_id(l_targ_plan_level_code,pras.task_id), pras.resource_list_member_id)= L_targ_ra_id_tbl(kk)
                               --IPM Arch Enhancement Bug 4865563
                              /*and    pbls.cost_rejection_code IS NULL
                              and    pbls.revenue_rejection_code IS NULL
                              and    pbls.burden_rejection_code IS NULL
                              and    pbls.other_rejection_code IS NULL
                              and    pbls.pc_cur_conv_rejection_code IS NULL
                              and    pbls.pfc_cur_conv_rejection_code IS NULL*/
                              GROUP BY get_mapped_ra_id(get_task_id(l_targ_plan_level_code,pras.task_id),pras.resource_list_member_id) ,
                                     DECODE(l_copy_pfc_for_txn_amt_flag,'Y', l_projfunc_currency_code,DECODE(l_same_multi_curr_flag, 'Y', pbls.txn_currency_code,l_project_currency_code)))pbl;

                        IF P_PA_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'After bulk-inserting resource assignments';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;
                        --dbms_output.put_line('I27');

                   ELSE-- Resource lists are different

                      IF P_PA_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:= 'About to bulk insert Budget lines with diff RLs and with targ TP as None';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                      END IF;

                      --dbms_output.put_line('I28');
                      FORALL kk in L_targ_ra_id_tbl.FIRST ..L_targ_ra_id_tbl.LAST
                      INSERT INTO PA_BUDGET_LINES(RESOURCE_ASSIGNMENT_ID,
                               START_DATE,
                               LAST_UPDATE_DATE,
                               LAST_UPDATED_BY,
                               CREATION_DATE,
                               CREATED_BY,
                               LAST_UPDATE_LOGIN,
                               END_DATE,
                               PERIOD_NAME,
                               QUANTITY,
                               RAW_COST,
                               BURDENED_COST,
                               REVENUE,
                               CHANGE_REASON_CODE,
                               DESCRIPTION,
                               ATTRIBUTE_CATEGORY,
                               ATTRIBUTE1,
                               ATTRIBUTE2,
                               ATTRIBUTE3,
                               ATTRIBUTE4,
                               ATTRIBUTE5,
                               ATTRIBUTE6,
                               ATTRIBUTE7,
                               ATTRIBUTE8,
                               ATTRIBUTE9,
                               ATTRIBUTE10,
                               ATTRIBUTE11,
                               ATTRIBUTE12,
                               ATTRIBUTE13,
                               ATTRIBUTE14,
                               ATTRIBUTE15,
                               RAW_COST_SOURCE,
                               BURDENED_COST_SOURCE,
                               QUANTITY_SOURCE,
                               REVENUE_SOURCE,
                               PM_PRODUCT_CODE,
                               PM_BUDGET_LINE_REFERENCE,
                               COST_REJECTION_CODE,
                               REVENUE_REJECTION_CODE,
                               BURDEN_REJECTION_CODE,
                               OTHER_REJECTION_CODE,
                               CODE_COMBINATION_ID,
                               CCID_GEN_STATUS_CODE,
                               CCID_GEN_REJ_MESSAGE,
                               REQUEST_ID,
                               BORROWED_REVENUE,
                               TP_REVENUE_IN,
                               TP_REVENUE_OUT,
                               REVENUE_ADJ,
                               LENT_RESOURCE_COST,
                               TP_COST_IN,
                               TP_COST_OUT,
                               COST_ADJ,
                               UNASSIGNED_TIME_COST,
                               UTILIZATION_PERCENT,
                               UTILIZATION_HOURS,
                               UTILIZATION_ADJ,
                               CAPACITY,
                               HEAD_COUNT,
                               HEAD_COUNT_ADJ,
                               PROJFUNC_CURRENCY_CODE,
                               PROJFUNC_COST_RATE_TYPE,
                               PROJFUNC_COST_EXCHANGE_RATE,
                               PROJFUNC_COST_RATE_DATE_TYPE,
                               PROJFUNC_COST_RATE_DATE,
                               PROJFUNC_REV_RATE_TYPE,
                               PROJFUNC_REV_EXCHANGE_RATE,
                               PROJFUNC_REV_RATE_DATE_TYPE,
                               PROJFUNC_REV_RATE_DATE,
                               PROJECT_CURRENCY_CODE,
                               PROJECT_COST_RATE_TYPE,
                               PROJECT_COST_EXCHANGE_RATE,
                               PROJECT_COST_RATE_DATE_TYPE,
                               PROJECT_COST_RATE_DATE,
                               PROJECT_RAW_COST,
                               PROJECT_BURDENED_COST,
                               PROJECT_REV_RATE_TYPE,
                               PROJECT_REV_EXCHANGE_RATE,
                               PROJECT_REV_RATE_DATE_TYPE,
                               PROJECT_REV_RATE_DATE,
                               PROJECT_REVENUE,
                               TXN_CURRENCY_CODE,
                               TXN_RAW_COST,
                               TXN_BURDENED_COST,
                               TXN_REVENUE,
                               BUCKETING_PERIOD_CODE,
                               BUDGET_LINE_ID,
                               BUDGET_VERSION_ID,
                               TXN_STANDARD_COST_RATE,
                               TXN_COST_RATE_OVERRIDE,
                               COST_IND_COMPILED_SET_ID,
                        --           TXN_BURDEN_MULTIPLIER,
                        --           TXN_BURDEN_MULTIPLIER_OVERRIDE,
                               TXN_STANDARD_BILL_RATE,
                               TXN_BILL_RATE_OVERRIDE,
                               TXN_MARKUP_PERCENT,
                               TXN_MARKUP_PERCENT_OVERRIDE,
                               TXN_DISCOUNT_PERCENTAGE,
                               TRANSFER_PRICE_RATE,
                               BURDEN_COST_RATE,
                               BURDEN_COST_RATE_OVERRIDE,
                               PC_CUR_CONV_REJECTION_CODE,
                               PFC_CUR_CONV_REJECTION_CODE
                               )
                        SELECT  pbl.resource_assignment_id,
                              l_planning_start_date_tbl(kk) start_date,
                              pbl.last_update_date,
                              pbl.last_updated_by,
                              pbl.creation_date,
                              pbl.created_by,
                              pbl.last_update_login,
                              l_planning_end_date_tbl(kk) end_date,
                              pbl.period_name,
                              DECODE(l_targ_rate_based_flag_tbl(kk),
                                     'N',DECODE(l_target_version_type,
                                                'REVENUE',pbl.txn_revenue
                                                         ,pbl.txn_raw_cost),
                                      pbl.quantity),
                              pbl.raw_cost,
                              pbl.burdened_cost,
                              pbl.revenue,
                              pbl.change_reason_code,
                              pbl.description,
                              pbl.attribute_category,
                              pbl.attribute1,
                              pbl.attribute2,
                              pbl.attribute3,
                              pbl.attribute4,
                              pbl.attribute5,
                              pbl.attribute6,
                              pbl.attribute7,
                              pbl.attribute8,
                              pbl.attribute9,
                              pbl.attribute10,
                              pbl.attribute11,
                              pbl.attribute12,
                              pbl.attribute13,
                              pbl.attribute14,
                              pbl.attribute15,
                              pbl.raw_cost_source,
                              pbl.burdened_cost_source,
                              pbl.quantity_source,
                              pbl.revenue_source,
                              pbl.pm_product_code,
                              pbl.pm_budget_line_reference,
                              pbl.cost_rejection_code,
                              pbl.revenue_rejection_code,
                              pbl.burden_rejection_code,
                              pbl.other_rejection_code,
                              pbl.code_combination_id,
                              pbl.ccid_gen_status_code,
                              pbl.ccid_gen_rej_message,
                              pbl.request_id,
                              pbl.borrowed_revenue,
                              pbl.tp_revenue_in,
                              pbl.tp_revenue_out,
                              pbl.revenue_adj,
                              pbl.lent_resource_cost,
                              pbl.tp_cost_in,
                              pbl.tp_cost_out,
                              pbl.cost_adj,
                              pbl.unassigned_time_cost,
                              pbl.utilization_percent,
                              pbl.utilization_hours,
                              pbl.utilization_adj,
                              pbl.capacity,
                              pbl.head_count,
                              pbl.head_count_adj,
                              pbl.projfunc_currency_code,
                              pbl.projfunc_cost_rate_type,
                              DECODE(l_cost_impl_flag,'Y', DECODE(l_targ_multi_curr_flag,'Y', Decode(decode(l_report_cost_using, 'R',nvl(pbl.txn_raw_cost,0),
                                              'B', nvl(pbl.txn_burdened_cost,0)),0,0,(decode(l_report_cost_using,'R',nvl(pbl.raw_cost,0),
                                              'B',nvl(pbl.burdened_cost,0)) / decode(l_report_cost_using,'R',pbl.txn_raw_cost,
                                              'B', pbl.txn_burdened_cost))),Null),Null), --Bug 3839273
                              pbl.projfunc_cost_rate_date_type,
                              pbl.projfunc_cost_rate_date,
                              pbl.projfunc_rev_rate_type,
                              Decode(l_rev_impl_flag,'Y',DECODE(l_targ_multi_curr_flag,'Y',  Decode(nvl(pbl.txn_revenue,0),0,0,nvl(pbl.revenue,0) /pbl.txn_revenue),Null),Null), --Bug 3839273
                              pbl.projfunc_rev_rate_date_type,
                              pbl.projfunc_rev_rate_date,
                              pbl.project_currency_code,
                              pbl.project_cost_rate_type,
                              DECODE(l_cost_impl_flag,'Y', DECODE(l_targ_multi_curr_flag,'Y', Decode(decode(l_report_cost_using, 'R',nvl(pbl.txn_raw_cost,0),
                                               'B', nvl(pbl.txn_burdened_cost,0)),0,0,(decode(l_report_cost_using,'R',nvl(pbl.project_raw_cost,0),
                                               'B',nvl(pbl.project_burdened_cost,0)) / decode(l_report_cost_using,'R',pbl.txn_raw_cost,
                                               'B',pbl.txn_burdened_cost))),Null),Null), --Bug 3839273
                              pbl.project_cost_rate_date_type,
                              pbl.project_cost_rate_date,
                              pbl.project_raw_cost,
                              pbl.project_burdened_cost,
                              pbl.project_rev_rate_type,
                              Decode(l_rev_impl_flag,'Y',DECODE(l_targ_multi_curr_flag,'Y', Decode(nvl(pbl.txn_revenue,0),0,0,(nvl(pbl.project_revenue,0) /pbl.txn_revenue)),Null),Null), --Bug 3839273
                              pbl.project_rev_rate_date_type,
                              pbl.project_rev_rate_date,
                              pbl.project_revenue,
                              pbl.txn_currency_code,
                              pbl.txn_raw_cost,
                              pbl.txn_burdened_cost,
                              pbl.txn_revenue,
                              pbl.bucketing_period_code,
                              pa_budget_lines_s.nextval,
                              pbl.budget_version_id,
                              pbl.txn_standard_cost_rate,
                              DECODE(l_target_version_type,
                                   'REVENUE',pbl.txn_cost_rate_override,
                                    DECODE(l_targ_rate_based_flag_tbl(kk),
                                           'N',1,
                                           pbl.txn_cost_rate_override)),
                              pbl.cost_ind_compiled_set_id,
                    --          pbl.  txn_burden_multiplier,
                    --          pbl.  txn_burden_multiplier_override,
                              pbl.txn_standard_bill_rate,
                              DECODE(l_target_version_type,
                                     'REVENUE',DECODE(l_targ_rate_based_flag_tbl(kk),
                                                      'N',1,
                                                      pbl.txn_bill_rate_override),
                                     pbl.txn_bill_rate_override),
                              pbl.txn_markup_percent,
                              pbl.txn_markup_percent_override,
                              pbl.txn_discount_percentage,
                              pbl.transfer_price_rate,
                              pbl.burden_cost_rate,
                              DECODE(l_target_version_type,
                                   'REVENUE',pbl.burden_cost_rate_override,
                                    DECODE(l_targ_rate_based_flag_tbl(kk),
                                          'Y',pbl.burden_cost_rate_override,
                                          DECODE(nvl(pbl.txn_raw_cost,0),
                                                 0,null,
                                                 pbl.txn_burdened_cost/pbl.txn_raw_cost))),
                              pbl.pc_cur_conv_rejection_code,
                              pbl.pfc_cur_conv_rejection_code
                        FROM
                                 --The entier SELECT is moved to the sub query in FROM clause as nextval would not work with group by
                         (SELECT pa_fp_ci_merge.get_mapped_ra_id(pa_fp_ci_merge.get_task_id(l_targ_plan_level_code,pras.task_id), rlmap.resource_list_member_id) resource_assignment_id,
                              sysdate    last_update_date,
                              fnd_global.user_id  last_updated_by,
                              sysdate  creation_date,
                              fnd_global.user_id  created_by,
                              fnd_global.login_id last_update_login,
                              NULL period_name,
                              decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                                   decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null)) quantity,
                              sum(Decode(l_cost_impl_flag ,'Y', pbls.raw_cost,null)) raw_cost,
                              sum(Decode(l_cost_impl_flag ,'Y', pbls.burdened_cost,null)) burdened_cost,
                              sum(Decode(l_rev_impl_flag ,'Y', pbls.revenue,null))*l_partial_factor revenue,
                              decode(count(pbls.budget_line_id),1,max(pbls.change_reason_code),null) change_reason_code,
                              decode(count(pbls.budget_line_id),1,max(pbls.description),null) description,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute_category),null) attribute_category,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute1),null)   attribute1 ,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute2),null)   attribute2 ,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute3),null)   attribute3 ,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute4),null)   attribute4 ,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute5),null)   attribute5 ,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute6),null)   attribute6 ,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute7),null)   attribute7 ,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute8),null)   attribute8 ,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute9),null)   attribute9 ,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute10),null)attribute10 ,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute11),null)attribute11 ,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute12),null)attribute12 ,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute13),null)attribute13 ,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute14),null)attribute14 ,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute15),null)attribute15 ,
                              'I' raw_cost_source     ,
                              'I' burdened_cost_source,
                              'I' quantity_source     ,
                              'I' revenue_source      ,
                              decode(count(pbls.budget_line_id),1,max(pbls.pm_product_code),null) pm_product_code,
                              decode(count(pbls.budget_line_id),1,max(pbls.pm_budget_line_reference),null) pm_budget_line_reference,
                              decode(count(pbls.budget_line_id),1,max(pbls.cost_rejection_code),null) cost_rejection_code,
                              decode(count(pbls.budget_line_id),1,max(pbls.revenue_rejection_code),null) revenue_rejection_code,
                              decode(count(pbls.budget_line_id),1,max(pbls.burden_rejection_code),null) burden_rejection_code,
                              decode(count(pbls.budget_line_id),1,max(pbls.other_rejection_code),null) other_rejection_code,
                              decode(count(pbls.budget_line_id),1,max(pbls.code_combination_id),null) code_combination_id,
                              decode(count(pbls.budget_line_id),1,max(pbls.ccid_gen_status_code),null) ccid_gen_status_code,
                              decode(count(pbls.budget_line_id),1,max(pbls.CCID_GEN_REJ_MESSAGE),null) ccid_gen_rej_message,
                              decode(count(pbls.budget_line_id),1,max(pbls.REQUEST_ID),null) request_id,
                              decode(count(pbls.budget_line_id),1,max(pbls.BORROWED_REVENUE),null) borrowed_revenue,
                              decode(count(pbls.budget_line_id),1,max(pbls.TP_REVENUE_IN),null) tp_revenue_in,
                              decode(count(pbls.budget_line_id),1,max(pbls.TP_REVENUE_OUT),null) tp_revenue_out,
                              decode(count(pbls.budget_line_id),1,max(pbls.REVENUE_ADJ),null)revenue_adj,
                              decode(count(pbls.budget_line_id),1,max(pbls.LENT_RESOURCE_COST),null) lent_resource_cost,
                              decode(count(pbls.budget_line_id),1,max(pbls.TP_COST_IN),null) tp_cost_in,
                              decode(count(pbls.budget_line_id),1,max(pbls.TP_COST_OUT),null) tp_cost_out,
                              decode(count(pbls.budget_line_id),1,max(pbls.COST_ADJ),null) cost_adj,
                              decode(count(pbls.budget_line_id),1,max(pbls.UNASSIGNED_TIME_COST),null) unassigned_time_cost,
                              decode(count(pbls.budget_line_id),1,max(pbls.UTILIZATION_PERCENT),null) utilization_percent,
                              decode(count(pbls.budget_line_id),1,max(pbls.UTILIZATION_HOURS),null) utilization_hours,
                              decode(count(pbls.budget_line_id),1,max(pbls.UTILIZATION_ADJ),null) utilization_adj,
                              decode(count(pbls.budget_line_id),1,max(pbls.CAPACITY),null) capacity,
                              decode(count(pbls.budget_line_id),1,max(pbls.HEAD_COUNT),null) head_count,
                              decode(count(pbls.budget_line_id),1,max(pbls.HEAD_COUNT_ADJ),null) head_count_adj,
                              l_projfunc_currency_code projfunc_currency_code,
                              DECODE(l_cost_impl_flag,'Y', DECODE(l_targ_multi_curr_flag,'Y', 'User', null),Null) projfunc_cost_rate_type,
                              null projfunc_cost_exchange_rate, --Bug 3839273
                              decode(count(pbls.budget_line_id),1,max(pbls.PROJFUNC_COST_RATE_DATE_TYPE),null) projfunc_cost_rate_date_type,
                              decode(count(pbls.budget_line_id),1,max(pbls.PROJFUNC_COST_RATE_DATE),null) projfunc_cost_rate_date,
                              Decode(l_rev_impl_flag,'Y',DECODE(l_targ_multi_curr_flag,'Y', 'User', null),Null) projfunc_rev_rate_type,
                              null projfunc_rev_exchange_rate, --Bug 3839273
                              decode(count(pbls.budget_line_id),1,max(pbls.PROJFUNC_REV_RATE_DATE_TYPE),null) projfunc_rev_rate_date_type,
                              decode(count(pbls.budget_line_id),1,max(pbls.PROJFUNC_REV_RATE_DATE),null) projfunc_rev_rate_date,
                              l_project_currency_code project_currency_code,
                              DECODE(l_cost_impl_flag,'Y',DECODE(l_targ_multi_curr_flag, 'Y','User', null),Null) project_cost_rate_type,
                              null project_cost_exchange_rate, --Bug 3839273
                              decode(count(pbls.budget_line_id),1,max(pbls.PROJECT_COST_RATE_DATE_TYPE),null) project_cost_rate_date_type,
                              decode(count(pbls.budget_line_id),1,max(pbls.PROJECT_COST_RATE_DATE),null) project_cost_rate_date,
                              sum(Decode(l_cost_impl_flag ,'Y',pbls.project_raw_cost,null)) project_raw_cost,
                              sum(Decode(l_cost_impl_flag ,'Y',pbls.project_burdened_cost,null)) project_burdened_cost,
                              Decode(l_rev_impl_flag, 'Y', DECODE(l_targ_multi_curr_flag, 'Y', 'User', null),Null) project_rev_rate_type,
                              null project_rev_exchange_rate, --Bug 3839273
                              decode(count(pbls.budget_line_id),1,max(pbls.PROJECT_REV_RATE_DATE_TYPE),null) project_rev_rate_date_type,
                              decode(count(pbls.budget_line_id),1,max(pbls.PROJECT_REV_RATE_DATE),null) project_rev_rate_date,
                              sum(Decode(l_rev_impl_flag , 'Y', pbls.project_revenue,null))*l_partial_factor project_revenue,
                              DECODE(l_copy_pfc_for_txn_amt_flag,'Y',l_projfunc_currency_code,DECODE(l_same_multi_curr_flag,'Y', pbls.txn_currency_code,l_project_currency_code)) txn_currency_code,

                              --Bug 4224757.. Code changes for bug#4224757 starts here
                              SUM(decode(l_cost_impl_flag,'Y', decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.raw_cost,0),
                              DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_raw_cost,0), nvl(pbls.project_raw_cost,0)))))
                              txn_raw_cost,
                              SUM(decode(l_cost_impl_flag,'Y', decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.burdened_cost,0),
                              DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_burdened_cost,0),
                              nvl(pbls.project_burdened_cost,0))))) txn_burdened_cost,
                              SUM(decode(l_rev_impl_flag,'Y',decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.revenue,0),
                              DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_revenue,0),
                              nvl(pbls.project_revenue,0)))))*l_partial_factor txn_revenue,
                              --Bug 4224757.. Code changes for bug#4224757 ends here

                              decode(count(pbls.budget_line_id),1,max(pbls.BUCKETING_PERIOD_CODE),null) bucketing_period_code,
                              p_budget_version_id budget_version_id,
                              decode(count(pbls.budget_line_id),1,max(pbls.txn_standard_cost_rate),null) txn_standard_cost_rate,

                              --Bug 4224757. Code changes for bug#4224757 starts here
                              decode(nvl(sum(pbls.quantity),0),0,0,SUM(decode(l_cost_impl_flag,'Y',
                              decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.raw_cost,0), DECODE(l_same_multi_curr_flag, 'Y',
                               nvl(pbls.txn_raw_cost,0), nvl(pbls.project_raw_cost,0))) ))/
                              decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                                  decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null)))     txn_cost_rate_override,
                              --Bug 4224757. Code changes for bug#4224757 ends here



                              decode(count(pbls.budget_line_id),1,max(pbls.cost_ind_compiled_set_id),null) cost_ind_compiled_set_id,
                        --        decode(count(pbls.budget_line_id),1,max(pbls.txn_burden_multiplier),null),

                              decode(count(pbls.budget_line_id),1,max(pbls.txn_standard_bill_rate),null) txn_standard_bill_rate,

                              --Bug 4224757. Code changes for bug#4224757 starts here
                              decode(nvl(sum(pbls.quantity),0),0,0,sum(Decode(l_rev_impl_flag ,'Y',
                                   decode(l_copy_pfc_for_txn_amt_flag,'Y', nvl(pbls.revenue,0), DECODE(l_same_multi_curr_flag,
                                     'Y', nvl(pbls.txn_revenue,0), nvl(pbls.project_revenue,0)))))*l_partial_factor/
                                     decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                                   decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null))) txn_bill_rate_override,
                              --Bug 4224757. Code changes for bug#4224757 ends here

                              decode(count(pbls.budget_line_id),1,max(pbls.TXN_MARKUP_PERCENT),null) txn_markup_percent,
                              decode(count(pbls.budget_line_id),1,max(pbls.TXN_MARKUP_PERCENT_OVERRIDE),null) txn_markup_percent_override,
                              decode(count(pbls.budget_line_id),1,max(pbls.TXN_DISCOUNT_PERCENTAGE),null) txn_discount_percentage,
                              decode(count(pbls.budget_line_id),1,max(pbls.TRANSFER_PRICE_RATE),null) transfer_price_rate,
                              decode(count(pbls.budget_line_id),1,max(pbls.BURDEN_COST_RATE),null) burden_cost_rate,

                              --Bug 4224757. Code changes for bug#4224757 starts here
                              decode(nvl(sum(pbls.quantity),0),0,0,SUM(decode(l_cost_impl_flag,'Y',
                              decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.burdened_cost,0), DECODE(l_same_multi_curr_flag, 'Y',
                                nvl(pbls.txn_burdened_cost,0), nvl(pbls.project_burdened_cost,0))) ))/
                              decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                               decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null))) burden_cost_rate_override,
                              --Bug 4224757. Code changes for bug#4224757 ends here



                              decode(count(pbls.budget_line_id),1,max(pbls.PC_CUR_CONV_REJECTION_CODE),null) pc_cur_conv_rejection_code,
                              decode(count(pbls.budget_line_id),1,max(pbls.PFC_CUR_CONV_REJECTION_CODE),null) pfc_cur_conv_rejection_code
                         from   pa_budget_lines pbls,
                              pa_resource_assignments pras,
                              pa_res_list_map_tmp4  rlmap
                         where  l_ra_dml_code_tbl(kk)='INSERT'
                         and    pras.resource_assignment_id = pbls.resource_assignment_id
                         and    pras.budget_version_id = l_src_ver_id_tbl(j)
                         AND    pras.resource_assignment_id=rlmap.txn_source_id
                         and    pa_fp_ci_merge.get_mapped_ra_id(get_task_id(l_targ_plan_level_code,pras.task_id), rlmap.resource_list_member_id)=l_targ_ra_id_tbl(kk)
                            --IPM Arch Enhancement Bug 4865563
                       /*and    pbls.cost_rejection_code IS NULL
                         and    pbls.revenue_rejection_code IS NULL
                         and    pbls.burden_rejection_code IS NULL
                         and    pbls.other_rejection_code IS NULL
                         and    pbls.pc_cur_conv_rejection_code IS NULL
                         and    pbls.pfc_cur_conv_rejection_code IS NULL*/
                         GROUP BY pa_fp_ci_merge.get_mapped_ra_id(pa_fp_ci_merge.get_task_id(l_targ_plan_level_code,pras.task_id),rlmap.resource_list_member_id) ,
                                DECODE(l_copy_pfc_for_txn_amt_flag,'Y', l_projfunc_currency_code,DECODE(l_same_multi_curr_flag, 'Y', pbls.txn_currency_code,l_project_currency_code)))pbl;

                        IF P_PA_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Done with bulk insert Budget lines with diff RLs and with targ TP as None';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;
                        --dbms_output.put_line('I29');
                   END IF;
                ELSE -- Time phased code is not N and src time phasing = target time phasing

                   IF P_PA_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'SRC tp =targ TP. same RLS. About to bulk insert BLs';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                   END IF;

                   --dbms_output.put_line('I30');
                   IF l_src_resource_list_id = l_targ_resource_list_id THEN
                      FORALL kk in L_targ_ra_id_tbl.FIRST ..L_targ_ra_id_tbl.LAST
                         INSERT INTO PA_BUDGET_LINES(
                                    RESOURCE_ASSIGNMENT_ID,
                                    START_DATE,
                                    LAST_UPDATE_DATE,
                                    LAST_UPDATED_BY,
                                    CREATION_DATE,
                                    CREATED_BY,
                                    LAST_UPDATE_LOGIN,
                                    END_DATE,
                                    PERIOD_NAME,
                                    QUANTITY,
                                    RAW_COST,
                                    BURDENED_COST,
                                    REVENUE,
                                    CHANGE_REASON_CODE,
                                    DESCRIPTION,
                                    ATTRIBUTE_CATEGORY,
                                    ATTRIBUTE1,
                                    ATTRIBUTE2,
                                    ATTRIBUTE3,
                                    ATTRIBUTE4,
                                    ATTRIBUTE5,
                                    ATTRIBUTE6,
                                    ATTRIBUTE7,
                                    ATTRIBUTE8,
                                    ATTRIBUTE9,
                                    ATTRIBUTE10,
                                    ATTRIBUTE11,
                                    ATTRIBUTE12,
                                    ATTRIBUTE13,
                                    ATTRIBUTE14,
                                    ATTRIBUTE15,
                                    RAW_COST_SOURCE,
                                    BURDENED_COST_SOURCE,
                                    QUANTITY_SOURCE,
                                    REVENUE_SOURCE,
                                    PM_PRODUCT_CODE,
                                    PM_BUDGET_LINE_REFERENCE,
                                    COST_REJECTION_CODE,
                                    REVENUE_REJECTION_CODE,
                                    BURDEN_REJECTION_CODE,
                                    OTHER_REJECTION_CODE,
                                    CODE_COMBINATION_ID,
                                    CCID_GEN_STATUS_CODE,
                                    CCID_GEN_REJ_MESSAGE,
                                    REQUEST_ID,
                                    BORROWED_REVENUE,
                                    TP_REVENUE_IN,
                                    TP_REVENUE_OUT,
                                    REVENUE_ADJ,
                                    LENT_RESOURCE_COST,
                                    TP_COST_IN,
                                    TP_COST_OUT,
                                    COST_ADJ,
                                    UNASSIGNED_TIME_COST,
                                    UTILIZATION_PERCENT,
                                    UTILIZATION_HOURS,
                                    UTILIZATION_ADJ,
                                    CAPACITY,
                                    HEAD_COUNT,
                                    HEAD_COUNT_ADJ,
                                    PROJFUNC_CURRENCY_CODE,
                                    PROJFUNC_COST_RATE_TYPE,
                                    PROJFUNC_COST_EXCHANGE_RATE,
                                    PROJFUNC_COST_RATE_DATE_TYPE,
                                    PROJFUNC_COST_RATE_DATE,
                                    PROJFUNC_REV_RATE_TYPE,
                                    PROJFUNC_REV_EXCHANGE_RATE,
                                    PROJFUNC_REV_RATE_DATE_TYPE,
                                    PROJFUNC_REV_RATE_DATE,
                                    PROJECT_CURRENCY_CODE,
                                    PROJECT_COST_RATE_TYPE,
                                    PROJECT_COST_EXCHANGE_RATE,
                                    PROJECT_COST_RATE_DATE_TYPE,
                                    PROJECT_COST_RATE_DATE,
                                    PROJECT_RAW_COST,
                                    PROJECT_BURDENED_COST,
                                    PROJECT_REV_RATE_TYPE,
                                    PROJECT_REV_EXCHANGE_RATE,
                                    PROJECT_REV_RATE_DATE_TYPE,
                                    PROJECT_REV_RATE_DATE,
                                    PROJECT_REVENUE,
                                    TXN_CURRENCY_CODE,
                                    TXN_RAW_COST,
                                    TXN_BURDENED_COST,
                                    TXN_REVENUE,
                                    BUCKETING_PERIOD_CODE,
                                    BUDGET_LINE_ID,
                                    BUDGET_VERSION_ID,
                                    TXN_STANDARD_COST_RATE,
                                    TXN_COST_RATE_OVERRIDE,
                                    COST_IND_COMPILED_SET_ID,
                             --         TXN_BURDEN_MULTIPLIER,
                             --         TXN_BURDEN_MULTIPLIER_OVERRIDE,
                                    TXN_STANDARD_BILL_RATE,
                                    TXN_BILL_RATE_OVERRIDE,
                                    TXN_MARKUP_PERCENT,
                                    TXN_MARKUP_PERCENT_OVERRIDE,
                                    TXN_DISCOUNT_PERCENTAGE,
                                    TRANSFER_PRICE_RATE,
                                    BURDEN_COST_RATE,
                                    BURDEN_COST_RATE_OVERRIDE,
                                    PC_CUR_CONV_REJECTION_CODE,
                                    PFC_CUR_CONV_REJECTION_CODE
                                    )
                         SELECT       pbl.resource_assignment_id,
                                    pbl.start_date,
                                    pbl.last_update_date,
                                    pbl.last_updated_by,
                                    pbl.creation_date,
                                    pbl.created_by,
                                    pbl.last_update_login,
                                    pbl.end_date,
                                    pbl.period_name,
                                    DECODE(l_targ_rate_based_flag_tbl(kk),
                                           'N',DECODE(l_target_version_type,
                                                      'REVENUE',pbl.txn_revenue
                                                               ,pbl.txn_raw_cost),
                                           pbl.quantity),
                                    pbl.raw_cost,
                                    pbl.burdened_cost,
                                    pbl.revenue,
                                    pbl.change_reason_code,
                                    pbl.description,
                                    pbl.attribute_category,
                                    pbl.attribute1,
                                    pbl.attribute2,
                                    pbl.attribute3,
                                    pbl.attribute4,
                                    pbl.attribute5,
                                    pbl.attribute6,
                                    pbl.attribute7,
                                    pbl.attribute8,
                                    pbl.attribute9,
                                    pbl.attribute10,
                                    pbl.attribute11,
                                    pbl.attribute12,
                                    pbl.attribute13,
                                    pbl.attribute14,
                                    pbl.attribute15,
                                    pbl.raw_cost_source,
                                    pbl.burdened_cost_source,
                                    pbl.quantity_source,
                                    pbl.revenue_source,
                                    pbl.pm_product_code,
                                    pbl.pm_budget_line_reference,
                                    pbl.cost_rejection_code,
                                    pbl.revenue_rejection_code,
                                    pbl.burden_rejection_code,
                                    pbl.other_rejection_code,
                                    pbl.code_combination_id,
                                    pbl.ccid_gen_status_code,
                                    pbl.ccid_gen_rej_message,
                                    pbl.request_id,
                                    pbl.borrowed_revenue,
                                    pbl.tp_revenue_in,
                                    pbl.tp_revenue_out,
                                    pbl.revenue_adj,
                                    pbl.lent_resource_cost,
                                    pbl.tp_cost_in,
                                    pbl.tp_cost_out,
                                    pbl.cost_adj,
                                    pbl.unassigned_time_cost,
                                    pbl.utilization_percent,
                                    pbl.utilization_hours,
                                    pbl.utilization_adj,
                                    pbl.capacity,
                                    pbl.head_count,
                                    pbl.head_count_adj,
                                    pbl.projfunc_currency_code,
                                    pbl.projfunc_cost_rate_type,
                                    DECODE(l_cost_impl_flag,'Y', DECODE(l_targ_multi_curr_flag,'Y', Decode(decode(l_report_cost_using, 'R',nvl(pbl.txn_raw_cost,0),
                                                     'B', nvl(pbl.txn_burdened_cost,0)),0,0,(decode(l_report_cost_using,'R',nvl(pbl.raw_cost,0),
                                                     'B',nvl(pbl.burdened_cost,0)) / decode(l_report_cost_using,'R',pbl.txn_raw_cost,
                                                     'B', pbl.txn_burdened_cost))),Null),Null), --Bug 3839273
                                    pbl.projfunc_cost_rate_date_type,
                                    pbl.projfunc_cost_rate_date,
                                    pbl.projfunc_rev_rate_type,
                                    Decode(l_rev_impl_flag,'Y',DECODE(l_targ_multi_curr_flag,'Y',  Decode(nvl(pbl.txn_revenue,0),0,0,(nvl(pbl.revenue,0) /pbl.txn_revenue)),Null),Null), --Bug 3839273
                                    pbl.projfunc_rev_rate_date_type,
                                    pbl.projfunc_rev_rate_date,
                                    pbl.project_currency_code,
                                    pbl.project_cost_rate_type,
                                    DECODE(l_cost_impl_flag,'Y', DECODE(l_targ_multi_curr_flag,'Y', Decode(decode(l_report_cost_using, 'R',nvl(pbl.txn_raw_cost,0),
                                                                   'B', nvl(pbl.txn_burdened_cost,0)),0,0,(decode(l_report_cost_using,'R',nvl(pbl.project_raw_cost,0),
                                                                   'B',nvl(pbl.project_burdened_cost,0)) / decode(l_report_cost_using,'R',pbl.txn_raw_cost,
                                                                   'B',pbl.txn_burdened_cost))),Null),Null), --Bug 3839273
                                    pbl.project_cost_rate_date_type,
                                    pbl.project_cost_rate_date,
                                    pbl.project_raw_cost,
                                    pbl.project_burdened_cost,
                                    pbl.project_rev_rate_type,
                                    Decode(l_rev_impl_flag,'Y',DECODE(l_targ_multi_curr_flag,'Y', Decode(nvl(pbl.txn_revenue,0),0,0,(nvl(pbl.project_revenue,0) /pbl.txn_revenue)),Null),Null), --Bug 3839273
                                    pbl.project_rev_rate_date_type,
                                    pbl.project_rev_rate_date,
                                    pbl.project_revenue,
                                    pbl.txn_currency_code,
                                    pbl.txn_raw_cost,
                                    pbl.txn_burdened_cost,
                                    pbl.txn_revenue,
                                    pbl.bucketing_period_code,
                                    pa_budget_lines_s.nextval,
                                    pbl.budget_version_id,
                                    pbl.txn_standard_cost_rate,
                                    DECODE(l_target_version_type,
                                         'REVENUE',pbl.txn_cost_rate_override,
                                          DECODE(l_targ_rate_based_flag_tbl(kk),
                                                 'N',1,
                                                 pbl.txn_cost_rate_override)),
                                    pbl.cost_ind_compiled_set_id,
                             --       pbl.  txn_burden_multiplier,
                             --       pbl.  txn_burden_multiplier_override,
                                    pbl.txn_standard_bill_rate,
                                    DECODE(l_target_version_type,
                                           'REVENUE',DECODE(l_targ_rate_based_flag_tbl(kk),
                                                            'N',1,
                                                            pbl.txn_bill_rate_override),
                                           pbl.txn_bill_rate_override),
                                    pbl.txn_markup_percent,
                                    pbl.txn_markup_percent_override,
                                    pbl.txn_discount_percentage,
                                    pbl.transfer_price_rate,
                                    pbl.burden_cost_rate,
                                    DECODE(l_target_version_type,
                                         'REVENUE',pbl.burden_cost_rate_override,
                                          DECODE(l_targ_rate_based_flag_tbl(kk),
                                                 'Y',pbl.burden_cost_rate_override,
                                                  DECODE(nvl(pbl.txn_raw_cost,0),
                                                         0,null,
                                                         pbl.txn_burdened_cost/pbl.txn_raw_cost))),
                                    pbl.pc_cur_conv_rejection_code,
                                    pbl.pfc_cur_conv_rejection_code
                         FROM(SELECT get_mapped_ra_id(get_task_id(l_targ_plan_level_code,pras.task_id), pras.resource_list_member_id) resource_assignment_id,
                                   pbls.start_date start_date,
                                   sysdate last_update_date,
                                   fnd_global.user_id last_updated_by,
                                   sysdate creation_date,
                                   fnd_global.user_id created_by,
                                   fnd_global.login_id last_update_login,
                                   pbls.end_date end_date,
                                   pbls.period_name period_name,
                                   decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                                      decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null)) quantity,
                                   sum(Decode(l_cost_impl_flag ,'Y', pbls.raw_cost,null)) raw_cost,
                                   sum(Decode(l_cost_impl_flag ,'Y', pbls.burdened_cost,null)) burdened_cost,
                                   sum(Decode(l_rev_impl_flag ,'Y', pbls.revenue, null))*l_partial_factor revenue,
                                   decode(count(pbls.budget_line_id),1,max(pbls.change_reason_code),null) change_reason_code,
                                   decode(count(pbls.budget_line_id),1,max(pbls.description),null) description,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute_category),null) attribute_category,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute1),null) attribute1,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute2),null) attribute2,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute3),null) attribute3,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute4),null) attribute4,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute5),null) attribute5,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute6),null) attribute6,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute7),null) attribute7,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute8),null) attribute8,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute9),null) attribute9,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute10),null) attribute10,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute11),null) attribute11,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute12),null) attribute12,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute13),null) attribute13,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute14),null) attribute14,
                                   decode(count(pbls.budget_line_id),1,max(pbls.attribute15),null) attribute15,
                                   'I' raw_cost_source     ,
                                   'I' burdened_cost_source,
                                   'I' quantity_source     ,
                                   'I' revenue_source      ,
                                   decode(count(pbls.budget_line_id),1,max(pbls.pm_product_code),null) pm_product_code,
                                   decode(count(pbls.budget_line_id),1,max(pbls.pm_budget_line_reference),null) pm_budget_line_reference,
                                   decode(count(pbls.budget_line_id),1,max(pbls.cost_rejection_code),null) cost_rejection_code,
                                   decode(count(pbls.budget_line_id),1,max(pbls.revenue_rejection_code),null) revenue_rejection_code,
                                   decode(count(pbls.budget_line_id),1,max(pbls.burden_rejection_code),null) burden_rejection_code,
                                   decode(count(pbls.budget_line_id),1,max(pbls.other_rejection_code),null) other_rejection_code,
                                   decode(count(pbls.budget_line_id),1,max(pbls.code_combination_id),null) code_combination_id,
                                   decode(count(pbls.budget_line_id),1,max(pbls.ccid_gen_status_code),null) ccid_gen_status_code,
                                   decode(count(pbls.budget_line_id),1,max(pbls.CCID_GEN_REJ_MESSAGE),null) ccid_gen_rej_message,
                                   decode(count(pbls.budget_line_id),1,max(pbls.REQUEST_ID),null) request_id,
                                   decode(count(pbls.budget_line_id),1,max(pbls.BORROWED_REVENUE),null) borrowed_revenue,
                                   decode(count(pbls.budget_line_id),1,max(pbls.TP_REVENUE_IN),null) tp_revenue_in,
                                   decode(count(pbls.budget_line_id),1,max(pbls.TP_REVENUE_OUT),null) tp_revenue_out,
                                   decode(count(pbls.budget_line_id),1,max(pbls.REVENUE_ADJ),null) revenue_adj,
                                   decode(count(pbls.budget_line_id),1,max(pbls.LENT_RESOURCE_COST),null) lent_resource_cost,
                                   decode(count(pbls.budget_line_id),1,max(pbls.TP_COST_IN),null) tp_cost_in,
                                   decode(count(pbls.budget_line_id),1,max(pbls.TP_COST_OUT),null)  tp_cost_out,
                                   decode(count(pbls.budget_line_id),1,max(pbls.COST_ADJ),null) cost_adj,
                                   decode(count(pbls.budget_line_id),1,max(pbls.UNASSIGNED_TIME_COST),null) unassigned_time_cost,
                                   decode(count(pbls.budget_line_id),1,max(pbls.UTILIZATION_PERCENT),null) utilization_percent,
                                   decode(count(pbls.budget_line_id),1,max(pbls.UTILIZATION_HOURS),null) utilization_hours,
                                   decode(count(pbls.budget_line_id),1,max(pbls.UTILIZATION_ADJ),null) utilization_adj,
                                   decode(count(pbls.budget_line_id),1,max(pbls.CAPACITY),null) capacity,
                                   decode(count(pbls.budget_line_id),1,max(pbls.HEAD_COUNT),null) head_count,
                                   decode(count(pbls.budget_line_id),1,max(pbls.HEAD_COUNT_ADJ),null) head_count_adj,
                                   l_projfunc_currency_code projfunc_currency_code,
                                   DECODE(l_cost_impl_flag,'Y', DECODE(l_targ_multi_curr_flag,'Y', 'User', null),Null) projfunc_cost_rate_type,
                                   null projfunc_cost_exchange_rate, --Bug 3839273
                                   null projfunc_cost_rate_date_type,
                                   null projfunc_cost_rate_date,
                                   Decode(l_rev_impl_flag,'Y',DECODE(l_targ_multi_curr_flag,'Y', 'User', null),Null) projfunc_rev_rate_type,
                                   null projfunc_rev_exchange_rate, --Bug 3839273
                                   null projfunc_rev_rate_date_type,
                                   null projfunc_rev_rate_date,
                                   l_project_currency_code project_currency_code,
                                   DECODE(l_cost_impl_flag,'Y',DECODE(l_targ_multi_curr_flag, 'Y','User', null),Null) project_cost_rate_type,
                                   null project_cost_exchange_rate, --Bug 3839273
                                   null project_cost_rate_date_type,
                                   null project_cost_rate_date,
                                   sum(Decode(l_cost_impl_flag ,'Y',pbls.project_raw_cost,null)) project_raw_cost,
                                   sum(Decode(l_cost_impl_flag ,'Y',pbls.project_burdened_cost,null)) project_burdened_cost,
                                   Decode(l_rev_impl_flag, 'Y', DECODE(l_targ_multi_curr_flag, 'Y', 'User', null),Null) project_rev_rate_type,
                                   null project_rev_exchange_rate, --Bug 3839273
                                   null project_rev_rate_date_type,
                                   null project_rev_rate_date,
                                   sum(Decode(l_rev_impl_flag , 'Y', pbls.project_revenue,null))*l_partial_factor project_revenue,
                                   DECODE(l_copy_pfc_for_txn_amt_flag,'Y',l_projfunc_currency_code,DECODE(l_same_multi_curr_flag,'Y', pbls.txn_currency_code,l_project_currency_code)) txn_currency_code,


                                   --Bug 4224757.. Code changes for bug#4224757 starts here
                                   SUM(decode(l_cost_impl_flag,'Y', decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.raw_cost,0),
                                   DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_raw_cost,0), nvl(pbls.project_raw_cost,0)))))
                                   txn_raw_cost,
                                   SUM(decode(l_cost_impl_flag,'Y', decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.burdened_cost,0),
                                   DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_burdened_cost,0),
                                   nvl(pbls.project_burdened_cost,0))))) txn_burdened_cost,
                                   SUM(decode(l_rev_impl_flag,'Y',decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.revenue,0),
                                   DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_revenue,0),
                                   nvl(pbls.project_revenue,0)))))*l_partial_factor txn_revenue,
                                   --Bug 4224757.. Code changes for bug#4224757 ends here

                                   decode(count(pbls.budget_line_id),1,max(pbls.BUCKETING_PERIOD_CODE),null) bucketing_period_code,
                                   p_budget_version_id budget_version_id,
                                   decode(count(pbls.budget_line_id),1,max(pbls.txn_standard_cost_rate),null) txn_standard_cost_rate,

                                   --Bug 4224757. Code changes for bug#4224757 starts here
                                   decode(nvl(sum(pbls.quantity),0),0,0,SUM(decode(l_cost_impl_flag,'Y',
                                   decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.raw_cost,0), DECODE(l_same_multi_curr_flag, 'Y',
                                  nvl(pbls.txn_raw_cost,0), nvl(pbls.project_raw_cost,0))) ))/
                                   decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                                        decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null)))     txn_cost_rate_override,
                                   --Bug 4224757. Code changes for bug#4224757 ends here



                                   decode(count(pbls.budget_line_id),1,max(pbls.cost_ind_compiled_set_id),null) cost_ind_compiled_set_id,
                            --         decode(count(pbls.budget_line_id),1,max(pbls.txn_burden_multiplier),null),

                                   decode(count(pbls.budget_line_id),1,max(pbls.txn_standard_bill_rate),null) txn_standard_bill_rate,

                                   --Bug 4224757. Code changes for bug#4224757 starts here
                                   decode(nvl(sum(pbls.quantity),0),0,0,sum(Decode(l_rev_impl_flag ,'Y',
                                          decode(l_copy_pfc_for_txn_amt_flag,'Y', nvl(pbls.revenue,0), DECODE(l_same_multi_curr_flag,
                                          'Y', nvl(pbls.txn_revenue,0), nvl(pbls.project_revenue,0)))))*l_partial_factor/
                                   decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                                        decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null))) txn_bill_rate_override,
                                   --Bug 4224757. Code changes for bug#4224757 ends here

                                   decode(count(pbls.budget_line_id),1,max(pbls.TXN_MARKUP_PERCENT),null) txn_markup_percent,
                                   decode(count(pbls.budget_line_id),1,max(pbls.TXN_MARKUP_PERCENT_OVERRIDE),null) txn_markup_percent_override,
                                   decode(count(pbls.budget_line_id),1,max(pbls.TXN_DISCOUNT_PERCENTAGE),null) txn_discount_percentage,
                                   decode(count(pbls.budget_line_id),1,max(pbls.TRANSFER_PRICE_RATE),null) transfer_price_rate,
                                   decode(count(pbls.budget_line_id),1,max(pbls.BURDEN_COST_RATE),null) burden_cost_rate,

                                   --Bug 4224757. Code changes for bug#4224757 starts here
                                   decode(nvl(sum(pbls.quantity),0),0,0,SUM(decode(l_cost_impl_flag,'Y',
                                   decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.burdened_cost,0), DECODE(l_same_multi_curr_flag,
                                  'Y', nvl(pbls.txn_burdened_cost,0), nvl(pbls.project_burdened_cost,0))) ))/
                                   decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                                        decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null))) burden_cost_rate_override,
                                   --Bug 4224757. Code changes for bug#4224757 ends here


                                   decode(count(pbls.budget_line_id),1,max(pbls.PC_CUR_CONV_REJECTION_CODE),null) pc_cur_conv_rejection_code,
                                   decode(count(pbls.budget_line_id),1,max(pbls.PFC_CUR_CONV_REJECTION_CODE),null) pfc_cur_conv_rejection_code
                              from   pa_budget_lines pbls,
                                   pa_resource_assignments pras
                              where  l_ra_dml_code_tbl(kk)='INSERT'
                              and    pras.budget_version_id = l_src_ver_id_tbl(j)
                              and    pras.resource_assignment_id = pbls.resource_assignment_id
                              and    get_mapped_ra_id(get_task_id(l_targ_plan_level_code,pras.task_id), pras.resource_list_member_id)=L_targ_ra_id_tbl(kk)
                                 --IPM Arch Enhancement Bug 4865563
                            /*and    pbls.cost_rejection_code IS NULL
                              and    pbls.revenue_rejection_code IS NULL
                              and    pbls.burden_rejection_code IS NULL
                              and    pbls.other_rejection_code IS NULL
                              and    pbls.pc_cur_conv_rejection_code IS NULL
                              and    pbls.pfc_cur_conv_rejection_code IS NULL*/
                              and    pbls.start_date >= nvl(l_etc_start_date,pbls.start_date)
                              GROUP BY get_mapped_ra_id(get_task_id(l_targ_plan_level_code,pras.task_id),pras.resource_list_member_id) ,
                                     DECODE(l_copy_pfc_for_txn_amt_flag,'Y', l_projfunc_currency_code,DECODE(l_same_multi_curr_flag, 'Y', pbls.txn_currency_code,l_project_currency_code))
                                     ,pbls.start_date,pbls.end_date,pbls.period_name)pbl;

                               IF P_PA_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage:= 'SRC tp =targ TP. same RLS.Done with bulk insert BLs';
                                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                               END IF;
                               --dbms_output.put_line('I31');

                   ELSE
                      IF P_PA_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:= 'About to bulk insert Budget lines with different RLs and  TP not N and src Tp= targ TP';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                      END IF;

                      --dbms_output.put_line('I32');
                      FORALL kk in L_targ_ra_id_tbl.FIRST ..L_targ_ra_id_tbl.LAST
                      INSERT INTO PA_BUDGET_LINES(
                               RESOURCE_ASSIGNMENT_ID,
                               START_DATE,
                               LAST_UPDATE_DATE,
                               LAST_UPDATED_BY,
                               CREATION_DATE,
                               CREATED_BY,
                               LAST_UPDATE_LOGIN,
                               END_DATE,
                               PERIOD_NAME,
                               QUANTITY,
                               RAW_COST,
                               BURDENED_COST,
                               REVENUE,
                               CHANGE_REASON_CODE,
                               DESCRIPTION,
                               ATTRIBUTE_CATEGORY,
                               ATTRIBUTE1,
                               ATTRIBUTE2,
                               ATTRIBUTE3,
                               ATTRIBUTE4,
                               ATTRIBUTE5,
                               ATTRIBUTE6,
                               ATTRIBUTE7,
                               ATTRIBUTE8,
                               ATTRIBUTE9,
                               ATTRIBUTE10,
                               ATTRIBUTE11,
                               ATTRIBUTE12,
                               ATTRIBUTE13,
                               ATTRIBUTE14,
                               ATTRIBUTE15,
                               RAW_COST_SOURCE,
                               BURDENED_COST_SOURCE,
                               QUANTITY_SOURCE,
                               REVENUE_SOURCE,
                               PM_PRODUCT_CODE,
                               PM_BUDGET_LINE_REFERENCE,
                               COST_REJECTION_CODE,
                               REVENUE_REJECTION_CODE,
                               BURDEN_REJECTION_CODE,
                               OTHER_REJECTION_CODE,
                               CODE_COMBINATION_ID,
                               CCID_GEN_STATUS_CODE,
                               CCID_GEN_REJ_MESSAGE,
                               REQUEST_ID,
                               BORROWED_REVENUE,
                               TP_REVENUE_IN,
                               TP_REVENUE_OUT,
                               REVENUE_ADJ,
                               LENT_RESOURCE_COST,
                               TP_COST_IN,
                               TP_COST_OUT,
                               COST_ADJ,
                               UNASSIGNED_TIME_COST,
                               UTILIZATION_PERCENT,
                               UTILIZATION_HOURS,
                               UTILIZATION_ADJ,
                               CAPACITY,
                               HEAD_COUNT,
                               HEAD_COUNT_ADJ,
                               PROJFUNC_CURRENCY_CODE,
                               PROJFUNC_COST_RATE_TYPE,
                               PROJFUNC_COST_EXCHANGE_RATE,
                               PROJFUNC_COST_RATE_DATE_TYPE,
                               PROJFUNC_COST_RATE_DATE,
                               PROJFUNC_REV_RATE_TYPE,
                               PROJFUNC_REV_EXCHANGE_RATE,
                               PROJFUNC_REV_RATE_DATE_TYPE,
                               PROJFUNC_REV_RATE_DATE,
                               PROJECT_CURRENCY_CODE,
                               PROJECT_COST_RATE_TYPE,
                               PROJECT_COST_EXCHANGE_RATE,
                               PROJECT_COST_RATE_DATE_TYPE,
                               PROJECT_COST_RATE_DATE,
                               PROJECT_RAW_COST,
                               PROJECT_BURDENED_COST,
                               PROJECT_REV_RATE_TYPE,
                               PROJECT_REV_EXCHANGE_RATE,
                               PROJECT_REV_RATE_DATE_TYPE,
                               PROJECT_REV_RATE_DATE,
                               PROJECT_REVENUE,
                               TXN_CURRENCY_CODE,
                               TXN_RAW_COST,
                               TXN_BURDENED_COST,
                               TXN_REVENUE,
                               BUCKETING_PERIOD_CODE,
                               BUDGET_LINE_ID,
                               BUDGET_VERSION_ID,
                               TXN_STANDARD_COST_RATE,
                               TXN_COST_RATE_OVERRIDE,
                               COST_IND_COMPILED_SET_ID,
                         --        TXN_BURDEN_MULTIPLIER,
                         --        TXN_BURDEN_MULTIPLIER_OVERRIDE,
                               TXN_STANDARD_BILL_RATE,
                               TXN_BILL_RATE_OVERRIDE,
                               TXN_MARKUP_PERCENT,
                               TXN_MARKUP_PERCENT_OVERRIDE,
                               TXN_DISCOUNT_PERCENTAGE,
                               TRANSFER_PRICE_RATE,
                               BURDEN_COST_RATE,
                               BURDEN_COST_RATE_OVERRIDE,
                               PC_CUR_CONV_REJECTION_CODE,
                               PFC_CUR_CONV_REJECTION_CODE
                               )
                         SELECT    pbl.resource_assignment_id,
                               pbl.start_date,
                               pbl.last_update_date,
                               pbl.last_updated_by,
                               pbl.creation_date,
                               pbl.created_by,
                               pbl.last_update_login,
                               pbl.end_date,
                               pbl.period_name,
                               DECODE(l_targ_rate_based_flag_tbl(kk),
                                      'N',DECODE(l_target_version_type,
                                                 'REVENUE',pbl.txn_revenue
                                                          ,pbl.txn_raw_cost),
                                       pbl.quantity),
                               pbl.raw_cost,
                               pbl.burdened_cost,
                               pbl.revenue,
                               pbl.change_reason_code,
                               pbl.description,
                               pbl.attribute_category,
                               pbl.attribute1,
                               pbl.attribute2,
                               pbl.attribute3,
                               pbl.attribute4,
                               pbl.attribute5,
                               pbl.attribute6,
                               pbl.attribute7,
                               pbl.attribute8,
                               pbl.attribute9,
                               pbl.attribute10,
                               pbl.attribute11,
                               pbl.attribute12,
                               pbl.attribute13,
                               pbl.attribute14,
                               pbl.attribute15,
                               pbl.raw_cost_source,
                               pbl.burdened_cost_source,
                               pbl.quantity_source,
                               pbl.revenue_source,
                               pbl.pm_product_code,
                               pbl.pm_budget_line_reference,
                               pbl.cost_rejection_code,
                               pbl.revenue_rejection_code,
                               pbl.burden_rejection_code,
                               pbl.other_rejection_code,
                               pbl.code_combination_id,
                               pbl.ccid_gen_status_code,
                               pbl.ccid_gen_rej_message,
                               pbl.request_id,
                               pbl.borrowed_revenue,
                               pbl.tp_revenue_in,
                               pbl.tp_revenue_out,
                               pbl.revenue_adj,
                               pbl.lent_resource_cost,
                               pbl.tp_cost_in,
                               pbl.tp_cost_out,
                               pbl.cost_adj,
                               pbl.unassigned_time_cost,
                               pbl.utilization_percent,
                               pbl.utilization_hours,
                               pbl.utilization_adj,
                               pbl.capacity,
                               pbl.head_count,
                               pbl.head_count_adj,
                               pbl.projfunc_currency_code,
                               pbl.projfunc_cost_rate_type,
                               DECODE(l_cost_impl_flag,'Y', DECODE(l_targ_multi_curr_flag,'Y', Decode(decode(l_report_cost_using, 'R',nvl(pbl.txn_raw_cost,0),
                                                 'B', nvl(pbl.txn_burdened_cost,0)),0,0,(decode(l_report_cost_using,'R',nvl(pbl.raw_cost,0),
                                                 'B',nvl(pbl.burdened_cost,0)) / decode(l_report_cost_using,'R',pbl.txn_raw_cost,
                                                 'B', pbl.txn_burdened_cost))),Null),Null), --Bug 3839273
                               pbl.projfunc_cost_rate_date_type,
                               pbl.projfunc_cost_rate_date,
                               pbl.projfunc_rev_rate_type,
                               Decode(l_rev_impl_flag,'Y',DECODE(l_targ_multi_curr_flag,'Y',  Decode(nvl(pbl.txn_revenue,0),0,0,(nvl(pbl.revenue,0) /pbl.txn_revenue)),Null),Null), --Bug 3839273
                               pbl.projfunc_rev_rate_date_type,
                               pbl.projfunc_rev_rate_date,
                               pbl.project_currency_code,
                               pbl.project_cost_rate_type,
                               DECODE(l_cost_impl_flag,'Y', DECODE(l_targ_multi_curr_flag,'Y', Decode(decode(l_report_cost_using, 'R',nvl(pbl.txn_raw_cost,0),
                                                 'B', nvl(pbl.txn_burdened_cost,0)),0,0,(decode(l_report_cost_using,'R',nvl(pbl.project_raw_cost,0),
                                                 'B',nvl(pbl.project_burdened_cost,0)) / decode(l_report_cost_using,'R',pbl.txn_raw_cost,
                                                 'B',pbl.txn_burdened_cost))),Null),Null), --Bug 3839273
                               pbl.project_cost_rate_date_type,
                               pbl.project_cost_rate_date,
                               pbl.project_raw_cost,
                               pbl.project_burdened_cost,
                               pbl.project_rev_rate_type,
                               Decode(l_rev_impl_flag,'Y',DECODE(l_targ_multi_curr_flag,'Y', Decode(nvl(pbl.txn_revenue,0),0,0,(nvl(pbl.project_revenue,0) /pbl.txn_revenue)),Null),Null), --Bug 3839273
                               pbl.project_rev_rate_date_type,
                               pbl.project_rev_rate_date,
                               pbl.project_revenue,
                               pbl.txn_currency_code,
                               pbl.txn_raw_cost,
                               pbl.txn_burdened_cost,
                               pbl.txn_revenue,
                               pbl.bucketing_period_code,
                               pa_budget_lines_s.nextval,
                               pbl.budget_version_id,
                               pbl.txn_standard_cost_rate,
                               DECODE(l_target_version_type,
                                      'REVENUE',pbl.txn_cost_rate_override,
                                      DECODE(l_targ_rate_based_flag_tbl(kk),
                                             'N',1,
                                             pbl.txn_cost_rate_override)),
                               pbl.cost_ind_compiled_set_id,
                         --      pbl.  txn_burden_multiplier,
                         --      pbl.  txn_burden_multiplier_override,
                               pbl.txn_standard_bill_rate,
                               DECODE(l_target_version_type,
                                      'REVENUE',DECODE(l_targ_rate_based_flag_tbl(kk),
                                                       'N',1,
                                                       pbl.txn_bill_rate_override),
                                      pbl.txn_bill_rate_override),
                               pbl.txn_markup_percent,
                               pbl.txn_markup_percent_override,
                               pbl.txn_discount_percentage,
                               pbl.transfer_price_rate,
                               pbl.burden_cost_rate,
                               DECODE(l_target_version_type,
                                      'REVENUE',pbl.burden_cost_rate_override,
                                       DECODE(l_targ_rate_based_flag_tbl(kk),
                                              'Y',pbl.burden_cost_rate_override,
                                              DECODE(nvl(pbl.txn_raw_cost,0),
                                                     0,null,
                                                     pbl.txn_burdened_cost/pbl.txn_raw_cost))),
                               pbl.pc_cur_conv_rejection_code,
                               pbl.pfc_cur_conv_rejection_code
                         FROM(SELECT get_mapped_ra_id(get_task_id(l_targ_plan_level_code,rlmap.task_id), rlmap.resource_list_member_id) resource_assignment_id,
                              pbls.start_date start_date,
                              sysdate last_update_date,
                              fnd_global.user_id last_updated_by,
                              sysdate creation_date,
                              fnd_global.user_id created_by,
                              fnd_global.login_id last_update_login,
                              pbls.end_date end_date,
                              pbls.period_name period_name,
                              decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                                   decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null)) quantity,
                              sum(Decode(l_cost_impl_flag ,'Y', pbls.raw_cost,null)) raw_cost,
                              sum(Decode(l_cost_impl_flag ,'Y', pbls.burdened_cost,null)) burdened_cost,
                              sum(Decode(l_rev_impl_flag ,'Y', pbls.revenue, null))*l_partial_factor revenue,
                              decode(count(pbls.budget_line_id),1,max(pbls.change_reason_code),null) change_reason_code,
                              decode(count(pbls.budget_line_id),1,max(pbls.description),null) description,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute_category),null) attribute_category,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute1),null) attribute1,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute2),null) attribute2,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute3),null) attribute3,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute4),null) attribute4,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute5),null) attribute5,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute6),null) attribute6,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute7),null) attribute7,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute8),null) attribute8,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute9),null) attribute9,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute10),null) attribute10,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute11),null) attribute11,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute12),null) attribute12,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute13),null) attribute13,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute14),null) attribute14,
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute15),null) attribute15,
                              'I' raw_cost_source     ,
                              'I' burdened_cost_source,
                              'I' quantity_source     ,
                              'I' revenue_source      ,
                              decode(count(pbls.budget_line_id),1,max(pbls.pm_product_code),null) pm_product_code,
                              decode(count(pbls.budget_line_id),1,max(pbls.pm_budget_line_reference),null) pm_budget_line_reference,
                              decode(count(pbls.budget_line_id),1,max(pbls.cost_rejection_code),null) cost_rejection_code,
                              decode(count(pbls.budget_line_id),1,max(pbls.revenue_rejection_code),null) revenue_rejection_code,
                              decode(count(pbls.budget_line_id),1,max(pbls.burden_rejection_code),null) burden_rejection_code,
                              decode(count(pbls.budget_line_id),1,max(pbls.other_rejection_code),null) other_rejection_code,
                              decode(count(pbls.budget_line_id),1,max(pbls.code_combination_id),null) code_combination_id,
                              decode(count(pbls.budget_line_id),1,max(pbls.ccid_gen_status_code),null) ccid_gen_status_code,
                              decode(count(pbls.budget_line_id),1,max(pbls.CCID_GEN_REJ_MESSAGE),null) ccid_gen_rej_message,
                              decode(count(pbls.budget_line_id),1,max(pbls.REQUEST_ID),null) request_id,
                              decode(count(pbls.budget_line_id),1,max(pbls.BORROWED_REVENUE),null) borrowed_revenue,
                              decode(count(pbls.budget_line_id),1,max(pbls.TP_REVENUE_IN),null) tp_revenue_in,
                              decode(count(pbls.budget_line_id),1,max(pbls.TP_REVENUE_OUT),null) tp_revenue_out,
                              decode(count(pbls.budget_line_id),1,max(pbls.REVENUE_ADJ),null) revenue_adj,
                              decode(count(pbls.budget_line_id),1,max(pbls.LENT_RESOURCE_COST),null) lent_resource_cost,
                              decode(count(pbls.budget_line_id),1,max(pbls.TP_COST_IN),null) tp_cost_in,
                              decode(count(pbls.budget_line_id),1,max(pbls.TP_COST_OUT),null) tp_cost_out,
                              decode(count(pbls.budget_line_id),1,max(pbls.COST_ADJ),null) cost_adj,
                              decode(count(pbls.budget_line_id),1,max(pbls.UNASSIGNED_TIME_COST),null) unassigned_time_cost,
                              decode(count(pbls.budget_line_id),1,max(pbls.UTILIZATION_PERCENT),null) utilization_percent,
                              decode(count(pbls.budget_line_id),1,max(pbls.UTILIZATION_HOURS),null) utilization_hours,
                              decode(count(pbls.budget_line_id),1,max(pbls.UTILIZATION_ADJ),null) utilization_adj,
                              decode(count(pbls.budget_line_id),1,max(pbls.CAPACITY),null) capacity,
                              decode(count(pbls.budget_line_id),1,max(pbls.HEAD_COUNT),null) head_count,
                              decode(count(pbls.budget_line_id),1,max(pbls.HEAD_COUNT_ADJ),null) head_count_adj,
                              l_projfunc_currency_code projfunc_currency_code,
                              DECODE(l_cost_impl_flag,'Y', DECODE(l_targ_multi_curr_flag,'Y', 'User', null),Null) projfunc_cost_rate_type,
                              null projfunc_cost_exchange_rate, --Bug 3839273
                              null projfunc_cost_rate_date_type,
                              null projfunc_cost_rate_date,
                              Decode(l_rev_impl_flag,'Y',DECODE(l_targ_multi_curr_flag,'Y', 'User', null),Null) projfunc_rev_rate_type,
                              null projfunc_rev_exchange_rate, --Bug 3839273
                              null projfunc_rev_rate_date_type,
                              null projfunc_rev_rate_date,
                              l_project_currency_code project_currency_code,
                              DECODE(l_cost_impl_flag,'Y',DECODE(l_targ_multi_curr_flag, 'Y','User', null),Null) project_cost_rate_type,
                              null project_cost_exchange_rate, --Bug 3839273
                              null project_cost_rate_date_type,
                              null project_cost_rate_date,
                              sum(Decode(l_cost_impl_flag ,'Y',pbls.project_raw_cost, null)) project_raw_cost,
                              sum(Decode(l_cost_impl_flag ,'Y',pbls.project_burdened_cost, null)) project_burdened_cost,
                              Decode(l_rev_impl_flag, 'Y', DECODE(l_targ_multi_curr_flag, 'Y', 'User', null),Null) project_rev_rate_type,
                              null project_rev_exchange_rate, --Bug 3839273
                              null project_rev_rate_date_type ,
                              null project_rev_rate_date ,
                              sum(Decode(l_rev_impl_flag , 'Y', pbls.project_revenue,null))*l_partial_factor project_revenue,
                              DECODE(l_copy_pfc_for_txn_amt_flag,'Y',l_projfunc_currency_code,DECODE(l_same_multi_curr_flag,'Y', pbls.txn_currency_code,l_project_currency_code)) txn_currency_code,


                              --Bug 4224757.. Code changes for bug#4224757 starts here
                              SUM(decode(l_cost_impl_flag,'Y', decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.raw_cost,0),
                              DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_raw_cost,0), nvl(pbls.project_raw_cost,0)))))
                              txn_raw_cost,
                              SUM(decode(l_cost_impl_flag,'Y', decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.burdened_cost,0),
                              DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_burdened_cost,0),
                              nvl(pbls.project_burdened_cost,0))))) txn_burdened_cost,
                              SUM(decode(l_rev_impl_flag,'Y',decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.revenue,0),
                              DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_revenue,0),
                              nvl(pbls.project_revenue,0)))))*l_partial_factor txn_revenue,
                              --Bug 4224757.. Code changes for bug#4224757 ends here

                              decode(count(pbls.budget_line_id),1,max(pbls.BUCKETING_PERIOD_CODE),null) bucketing_period_code,
                              p_budget_version_id budget_version_id,
                              decode(count(pbls.budget_line_id),1,max(pbls.txn_standard_cost_rate),null) txn_standard_cost_rate,

                              --Bug 4224757. Code changes for bug#4224757 starts here
                              decode(nvl(sum(pbls.quantity),0),0,0,SUM(decode(l_cost_impl_flag,'Y',
                              decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.raw_cost,0), DECODE(l_same_multi_curr_flag, 'Y',
                               nvl(pbls.txn_raw_cost,0), nvl(pbls.project_raw_cost,0))) ))/
                              decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                              decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null)))     txn_cost_rate_override,
                              --Bug 4224757. Code changes for bug#4224757 ends here

                              decode(count(pbls.budget_line_id),1,max(pbls.cost_ind_compiled_set_id),null) cost_ind_compiled_set_id,
                      --            decode(count(pbls.budget_line_id),1,max(pbls.txn_burden_multiplier),null),

                              decode(count(pbls.budget_line_id),1,max(pbls.txn_standard_bill_rate),null) txn_standard_bill_rate,

                              --Bug 4224757. Code changes for bug#4224757 starts here
                              decode(nvl(sum(pbls.quantity),0),0,0,sum(Decode(l_rev_impl_flag ,'Y',
                                  decode(l_copy_pfc_for_txn_amt_flag,'Y', nvl(pbls.revenue,0), DECODE(l_same_multi_curr_flag,
                                    'Y', nvl(pbls.txn_revenue,0), nvl(pbls.project_revenue,0)))))*l_partial_factor/
                              decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                                   decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null))) txn_bill_rate_override,
                              --Bug 4224757. Code changes for bug#4224757 ends here

                              decode(count(pbls.budget_line_id),1,max(pbls.TXN_MARKUP_PERCENT),null) txn_markup_percent,
                              decode(count(pbls.budget_line_id),1,max(pbls.TXN_MARKUP_PERCENT_OVERRIDE),null) txn_markup_percent_override,
                              decode(count(pbls.budget_line_id),1,max(pbls.TXN_DISCOUNT_PERCENTAGE),null) txn_discount_percentage,
                              decode(count(pbls.budget_line_id),1,max(pbls.TRANSFER_PRICE_RATE),null) transfer_price_rate,
                              decode(count(pbls.budget_line_id),1,max(pbls.BURDEN_COST_RATE),null) burden_cost_rate,

                              --Bug 4224757. Code changes for bug#4224757 starts here
                              decode(nvl(sum(pbls.quantity),0),0,0,SUM(decode(l_cost_impl_flag,'Y',
                              decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.burdened_cost,0), DECODE(l_same_multi_curr_flag, 'Y',
                                nvl(pbls.txn_burdened_cost,0), nvl(pbls.project_burdened_cost,0))) ))/
                              decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                                decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null))) burden_cost_rate_override,
                              --Bug 4224757. Code changes for bug#4224757 ends here

                              decode(count(pbls.budget_line_id),1,max(pbls.PC_CUR_CONV_REJECTION_CODE),null) pc_cur_conv_rejection_code,
                              decode(count(pbls.budget_line_id),1,max(pbls.PFC_CUR_CONV_REJECTION_CODE),null)  pfc_cur_conv_rejection_code
                         from   pa_budget_lines pbls,
                              (SELECT pra.task_id task_id,
                                    tmp4.resource_list_member_id resource_list_member_id,
                                    tmp4.txn_source_id resource_assignment_id
                               FROM   pa_resource_assignments pra,
                                    pa_res_list_map_tmp4 tmp4
                               WHERE  tmp4.txn_source_id=pra.resource_assignment_id) rlmap
                         where  l_ra_dml_code_tbl(kk)='INSERT'
                         and    rlmap.resource_assignment_id = pbls.resource_assignment_id
                         and    get_mapped_ra_id(get_task_id(l_targ_plan_level_code,rlmap.task_id), rlmap.resource_list_member_id)=L_targ_ra_id_tbl(kk)
                         --IPM Arch Enhancement Bug 4865563
                       /*and    pbls.cost_rejection_code IS NULL
                         and    pbls.revenue_rejection_code IS NULL
                         and    pbls.burden_rejection_code IS NULL
                         and    pbls.other_rejection_code IS NULL
                         and    pbls.pc_cur_conv_rejection_code IS NULL
                         and    pbls.pfc_cur_conv_rejection_code IS NULL*/
                         and    pbls.start_date >= nvl(l_etc_start_date, pbls.start_date)
                         GROUP BY get_mapped_ra_id(get_task_id(l_targ_plan_level_code,rlmap.task_id),rlmap.resource_list_member_id) ,
                                DECODE(l_copy_pfc_for_txn_amt_flag,'Y', l_projfunc_currency_code,DECODE(l_same_multi_curr_flag, 'Y', pbls.txn_currency_code,l_project_currency_code))
                                ,pbls.start_date,pbls.end_date,pbls.period_name)pbl;

                      IF P_PA_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:= 'Done with bulk insert Budget lines with different RLs and  TP not N and src Tp= targ TP'||SQL%ROWCOUNT;
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                      END IF;
                      --dbms_output.put_line('I33');
                    END IF;
                   END IF;
                   --Update

                   IF l_targ_time_phased_code = 'N' THEN
                    IF l_src_resource_list_id = l_targ_resource_list_id THEN
                             IF P_PA_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage:= 'About to bulk insert resource assignments';
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                             END IF;

                             --dbms_output.put_line('I34');
                             SELECT get_mapped_ra_id(null,null,pbls.resource_assignment_id,l_targ_plan_level_code),
                             decode(pblt.resource_assignment_id,null, 'INSERT',
                                                   decode(pblt.txn_currency_code, null,'INSERT','UPDATE')),
                             decode(pblt.resource_assignment_id,null, prat.planning_start_date,
                                                   decode(pblt.txn_currency_code, null,prat.planning_start_date,pblt.start_date)),
                             decode(pblt.resource_assignment_id,null, prat.planning_end_date,
                                                   decode(pblt.txn_currency_code, null,prat.planning_end_date,pblt.end_date)),
                             NULL,
                             decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                                decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null)),
                             sum(Decode(l_cost_impl_flag ,'Y', pbls.raw_cost,null)),
                             sum(Decode(l_cost_impl_flag ,'Y', pbls.burdened_cost,null)),
                             sum(Decode(l_rev_impl_flag ,'Y', pbls.revenue, null))*l_partial_factor,
                             decode(count(pbls.budget_line_id),1,max(pbls.change_reason_code),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.description),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.attribute_category),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.attribute1),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.attribute2),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.attribute3),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.attribute4),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.attribute5),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.attribute6),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.attribute7),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.attribute8),null),

                             decode(count(pbls.budget_line_id),1,max(pbls.attribute9),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.attribute10),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.attribute11),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.attribute12),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.attribute13),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.attribute14),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.attribute15),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.pm_product_code),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.pm_budget_line_reference),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.cost_rejection_code),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.revenue_rejection_code),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.burden_rejection_code),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.other_rejection_code),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.code_combination_id),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.ccid_gen_status_code),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.CCID_GEN_REJ_MESSAGE),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.REQUEST_ID),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.BORROWED_REVENUE),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.TP_REVENUE_IN),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.TP_REVENUE_OUT),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.REVENUE_ADJ),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.LENT_RESOURCE_COST),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.TP_COST_IN),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.TP_COST_OUT),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.COST_ADJ),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.UNASSIGNED_TIME_COST),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.UTILIZATION_PERCENT),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.UTILIZATION_HOURS),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.UTILIZATION_ADJ),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.CAPACITY),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.HEAD_COUNT),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.HEAD_COUNT_ADJ),null),
                             l_projfunc_currency_code,
                             DECODE(l_cost_impl_flag,'Y', DECODE(l_targ_multi_curr_flag,'Y', 'User', null),Null),
                             decode(count(pbls.budget_line_id),1,max(pbls.PROJFUNC_COST_RATE_DATE_TYPE),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.PROJFUNC_COST_RATE_DATE),null),
                             Decode(l_rev_impl_flag,'Y',DECODE(l_targ_multi_curr_flag,'Y', 'User', null),Null),
                             decode(count(pbls.budget_line_id),1,max(pbls.PROJFUNC_REV_RATE_DATE_TYPE),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.PROJFUNC_REV_RATE_DATE),null),
                             DECODE(l_cost_impl_flag,'Y',DECODE(l_targ_multi_curr_flag, 'Y','User', null),Null),
                             decode(count(pbls.budget_line_id),1,max(pbls.PROJECT_COST_RATE_DATE_TYPE),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.PROJECT_COST_RATE_DATE),null),
                             sum(Decode(l_cost_impl_flag ,'Y',pbls.project_raw_cost,null)),
                             sum(Decode(l_cost_impl_flag ,'Y',pbls.project_burdened_cost, null)),
                             Decode(l_rev_impl_flag, 'Y', DECODE(l_targ_multi_curr_flag, 'Y', 'User', null),Null),
                             decode(count(pbls.budget_line_id),1,max(pbls.PROJECT_REV_RATE_DATE_TYPE),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.PROJECT_REV_RATE_DATE),null),
                             sum(Decode(l_rev_impl_flag , 'Y', pbls.project_revenue,null))*l_partial_factor,
                             DECODE(l_copy_pfc_for_txn_amt_flag,'Y',l_projfunc_currency_code,DECODE(l_same_multi_curr_flag,'Y', pbls.txn_currency_code,l_project_currency_code)),


                             --Bug 4224757.. Code changes for bug#4224757 starts here
                             SUM(decode(l_cost_impl_flag,'Y', decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.raw_cost,0),
                             DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_raw_cost,0), nvl(pbls.project_raw_cost,0))))) ,
                             SUM(decode(l_cost_impl_flag,'Y', decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.burdened_cost,0),
                             DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_burdened_cost,0),
                             nvl(pbls.project_burdened_cost,0))))) ,
                             SUM(decode(l_rev_impl_flag,'Y',decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.revenue,0),
                             DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_revenue,0),
                             nvl(pbls.project_revenue,0)))))*l_partial_factor ,
                             --Bug 4224757.. Code changes for bug#4224757 ends here

                             decode(count(pbls.budget_line_id),1,max(pbls.BUCKETING_PERIOD_CODE),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.txn_standard_cost_rate),null),

                             --Bug 4224757. Code changes for bug#4224757 starts here
                             decode(nvl(sum(pbls.quantity),0),0,0,SUM(decode(l_cost_impl_flag,'Y',
                             decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.raw_cost,0), DECODE(l_same_multi_curr_flag, 'Y',
                              nvl(pbls.txn_raw_cost,0), nvl(pbls.project_raw_cost,0))) ))/
                             decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                             decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null)))   ,
                             --Bug 4224757. Code changes for bug#4224757 ends here

                             decode(count(pbls.budget_line_id),1,max(pbls.cost_ind_compiled_set_id),null),
                        --     decode(count(pbls.budget_line_id),1,max(pbls.txn_burden_multiplier),null),

                             decode(count(pbls.budget_line_id),1,max(pbls.txn_standard_bill_rate),null),

                             --Bug 4224757. Code changes for bug#4224757 starts here
                             decode(nvl(sum(pbls.quantity),0),0,0,sum(Decode(l_rev_impl_flag ,'Y',
                                  decode(l_copy_pfc_for_txn_amt_flag,'Y', nvl(pbls.revenue,0), DECODE(l_same_multi_curr_flag,
                                    'Y', nvl(pbls.txn_revenue,0), nvl(pbls.project_revenue,0)))))*l_partial_factor/
                             decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                                  decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null))),
                             --Bug 4224757. Code changes for bug#4224757 ends here

                             decode(count(pbls.budget_line_id),1,max(pbls.TXN_MARKUP_PERCENT),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.TXN_MARKUP_PERCENT_OVERRIDE),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.TXN_DISCOUNT_PERCENTAGE),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.TRANSFER_PRICE_RATE),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.BURDEN_COST_RATE),null),


                             --Bug 4224757. Code changes for bug#4224757 starts here
                             decode(nvl(sum(pbls.quantity),0),0,0,SUM(decode(l_cost_impl_flag,'Y',
                             decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.burdened_cost,0), DECODE(l_same_multi_curr_flag, 'Y',
                             nvl(pbls.txn_burdened_cost,0), nvl(pbls.project_burdened_cost,0))) ))/
                             decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                           decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null))) ,
                             --Bug 4224757. Code changes for bug#4224757 ends here

                             decode(count(pbls.budget_line_id),1,max(pbls.PC_CUR_CONV_REJECTION_CODE),null),
                             decode(count(pbls.budget_line_id),1,max(pbls.PFC_CUR_CONV_REJECTION_CODE),null)
                        BULK COLLECT INTO
                         l_bl_RESOURCE_ASIGNMENT_ID_tbl,
                         l_upd_ra_bl_dml_code_tbl,
                         l_bl_START_DATE_tbl,
                         l_bl_END_DATE_tbl,
                         l_bl_PERIOD_NAME_tbl,
                         l_bl_QUANTITY_tbl,
                         l_bl_RAW_COST_tbl,
                         l_bl_BURDENED_COST_tbl,
                         l_bl_REVENUE_tbl,
                         l_bl_CHANGE_REASON_CODE_tbl,
                         l_bl_DESCRIPTION_tbl,
                         l_bl_ATTRIBUTE_CATEGORY_tbl,
                         l_bl_ATTRIBUTE1_tbl,
                         l_bl_ATTRIBUTE2_tbl,
                         l_bl_ATTRIBUTE3_tbl,
                         l_bl_ATTRIBUTE4_tbl,
                         l_bl_ATTRIBUTE5_tbl,
                         l_bl_ATTRIBUTE6_tbl,
                         l_bl_ATTRIBUTE7_tbl,
                         l_bl_ATTRIBUTE8_tbl,
                         l_bl_ATTRIBUTE9_tbl,
                         l_bl_ATTRIBUTE10_tbl,
                         l_bl_ATTRIBUTE11_tbl,
                         l_bl_ATTRIBUTE12_tbl,
                         l_bl_ATTRIBUTE13_tbl,
                         l_bl_ATTRIBUTE14_tbl,
                         l_bl_ATTRIBUTE15_tbl,
                         l_bl_PM_PRODUCT_CODE_tbl,
                         l_bl_PM_BUDGET_LINE_REF_tbl,
                         l_bl_COST_REJECTION_CODE_tbl,
                         l_bl_REVENUE_REJ_CODE_tbl,
                         l_bl_BURDEN_REJECTION_CODE_tbl,
                         l_bl_OTHER_REJECTION_CODE_tbl,
                         l_bl_CODE_COMBINATION_ID_tbl,
                         l_bl_CCID_GEN_STATUS_CODE_tbl,
                         l_bl_CCID_GEN_REJ_MESSAGE_tbl,
                         l_bl_REQUEST_ID_tbl,
                         l_bl_BORROWED_REVENUE_tbl,
                         l_bl_TP_REVENUE_IN_tbl,
                         l_bl_TP_REVENUE_OUT_tbl,
                         l_bl_REVENUE_ADJ_tbl,
                         l_bl_LENT_RESOURCE_COST_tbl,
                         l_bl_TP_COST_IN_tbl,
                         l_bl_TP_COST_OUT_tbl,
                         l_bl_COST_ADJ_tbl,
                         l_bl_UNASSIGNED_TIME_COST_tbl,
                         l_bl_UTILIZATION_PERCENT_tbl,
                         l_bl_UTILIZATION_HOURS_tbl,
                         l_bl_UTILIZATION_ADJ_tbl,
                         l_bl_CAPACITY_tbl,
                         l_bl_HEAD_COUNT_tbl,
                         l_bl_HEAD_COUNT_ADJ_tbl,
                         l_bl_PROJFUNC_CUR_CODE_tbl,
                         l_bl_PROJFUNC_COST_RAT_TYP_tbl,
                         l_bl_PJFN_COST_RAT_DAT_TYP_tbl,
                         l_bl_PROJFUNC_COST_RAT_DAT_tbl,
                         l_bl_PROJFUNC_REV_RATE_TYP_tbl,
                         l_bl_PJFN_REV_RAT_DAT_TYPE_tbl,
                         l_bl_PROJFUNC_REV_RAT_DATE_tbl,
                         l_bl_PROJECT_COST_RAT_TYPE_tbl,
                         l_bl_PROJ_COST_RAT_DAT_TYP_tbl,
                         l_bl_PROJ_COST_RATE_DATE_tbl,
                         l_bl_PROJECT_RAW_COST_tbl,
                         l_bl_PROJECT_BURDENED_COST_tbl,
                         l_bl_PROJECT_REV_RATE_TYPE_tbl,
                         l_bl_PRJ_REV_RAT_DATE_TYPE_tbl,
                         l_bl_PROJECT_REV_RATE_DATE,
                         l_bl_PROJECT_REVENUE_tbl,
                         l_bl_TXN_CURRENCY_CODE_tbl,
                         l_bl_TXN_RAW_COST_tbl,
                         l_bl_TXN_BURDENED_COST_tbl,
                         l_bl_TXN_REVENUE_tbl,
                         l_bl_BUCKETING_PERIOD_CODE_tbl,
                         l_bl_TXN_STD_COST_RATE_tbl,
                         l_bl_TXN_COST_RATE_OVERIDE_tbl,
                         l_bl_COST_IND_CMPLD_SET_ID_tbl,
                   --        l_bl_TXN_BURDEN_MULTIPLIER_tbl,
                   --        l_bl_TXN_BRD_MLTIPLI_OVRID_tbl,
                         l_bl_TXN_STD_BILL_RATE_tbl,
                         l_bl_TXN_BILL_RATE_OVERRID_tbl,
                         l_bl_TXN_MARKUP_PERCENT_tbl,
                         l_bl_TXN_MRKUP_PER_OVERIDE_tbl,
                         l_bl_TXN_DISC_PERCENTAGE_tbl,
                         l_bl_TRANSFER_PRICE_RATE_tbl,
                         l_bl_BURDEN_COST_RATE_tbl,
                         l_bl_BURDEN_COST_RAT_OVRID_tbl,
                         l_bl_PC_CUR_CONV_REJ_CODE_tbl,
                         l_bl_PFC_CUR_CONV_REJ_CODE_tbl
                        from   pa_budget_lines pbls,
                               pa_budget_lines pblt,
                               pa_resource_assignments prat
                        where  get_mapped_dml_code(null,null,pbls.resource_assignment_id,l_targ_plan_level_code)='UPDATE'
                        and    pbls.budget_version_id = l_src_ver_id_tbl(j)
                        and    pblt.budget_version_id(+) = p_budget_version_id
                        and    pblt.resource_assignment_id(+)=get_mapped_ra_id(null,null,pbls.resource_assignment_id,l_targ_plan_level_code)
                        AND    pblt.txn_currency_code(+)=DECODE(l_copy_pfc_for_txn_amt_flag,'Y', l_projfunc_currency_code,
                                                      DECODE(l_same_multi_curr_flag, 'Y', pbls.txn_currency_code,l_project_currency_code))
                        and    prat.resource_assignment_id = get_mapped_ra_id(null,null,pbls.resource_assignment_id,l_targ_plan_level_code)
                        --IPM Arch Enhancement Bug 4865563
                      /*and    pbls.cost_rejection_code IS NULL
                        and    pbls.revenue_rejection_code IS NULL
                        and    pbls.burden_rejection_code IS NULL
                        and    pbls.other_rejection_code IS NULL
                        and    pbls.pc_cur_conv_rejection_code IS NULL
                        and    pbls.pfc_cur_conv_rejection_code IS NULL*/
                        GROUP BY get_mapped_ra_id(null,null,pbls.resource_assignment_id,l_targ_plan_level_code),
                        DECODE(l_copy_pfc_for_txn_amt_flag,'Y',l_projfunc_currency_code,DECODE(l_same_multi_curr_flag,'Y', pbls.txn_currency_code,l_project_currency_code)),
                        pblt.resource_assignment_id,
                        pblt.txn_currency_code,
                        pblt.start_date,
                        pblt.end_date,
                        prat.planning_start_date,
                        prat.planning_end_date;

                        --dbms_output.put_line('I35');

                  ELSE--Resource lists are different , target time phasing is N and the target resource assignments already exist in prat
                              IF P_PA_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage:= 'About to bulk select for ins/upd the budget lins with targ NTP and Diff RLS';
                                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                              END IF;
                              --dbms_output.put_line('I36');

                              SELECT get_mapped_ra_id(get_task_id(l_targ_plan_level_code,pbls.task_id), pbls.resource_list_member_id),
                              decode(pblt.resource_assignment_id,null, 'INSERT',
                                                         decode(pblt.txn_currency_code, null,'INSERT','UPDATE')),
                              decode(pblt.resource_assignment_id,null, prat.planning_start_date,
                                                         decode(pblt.txn_currency_code, null,prat.planning_start_date,pblt.start_date)),
                              decode(pblt.resource_assignment_id,null, prat.planning_end_date,
                                                         decode(pblt.txn_currency_code, null,prat.planning_end_date,pblt.end_date)),
                              NULL,
                              decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                                   decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null)),
                              sum(Decode(l_cost_impl_flag ,'Y', pbls.raw_cost,null)),
                              sum(Decode(l_cost_impl_flag ,'Y', pbls.burdened_cost,null)),
                              sum(Decode(l_rev_impl_flag ,'Y', pbls.revenue, null))*l_partial_factor,
                              decode(count(pbls.budget_line_id),1,max(pbls.change_reason_code),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.description),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute_category),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute1),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute2),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute3),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute4),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute5),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute6),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute7),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute8),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute9),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute10),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute11),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute12),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute13),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute14),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.attribute15),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.pm_product_code),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.pm_budget_line_reference),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.cost_rejection_code),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.revenue_rejection_code),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.burden_rejection_code),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.other_rejection_code),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.code_combination_id),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.ccid_gen_status_code),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.CCID_GEN_REJ_MESSAGE),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.REQUEST_ID),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.BORROWED_REVENUE),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.TP_REVENUE_IN),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.TP_REVENUE_OUT),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.REVENUE_ADJ),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.LENT_RESOURCE_COST),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.TP_COST_IN),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.TP_COST_OUT),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.COST_ADJ),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.UNASSIGNED_TIME_COST),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.UTILIZATION_PERCENT),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.UTILIZATION_HOURS),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.UTILIZATION_ADJ),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.CAPACITY),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.HEAD_COUNT),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.HEAD_COUNT_ADJ),null),
                              l_projfunc_currency_code,
                              DECODE(l_cost_impl_flag,'Y', DECODE(l_targ_multi_curr_flag,'Y', 'User', null),Null),
                              decode(count(pbls.budget_line_id),1,max(pbls.PROJFUNC_COST_RATE_DATE_TYPE),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.PROJFUNC_COST_RATE_DATE),null),
                              Decode(l_rev_impl_flag,'Y',DECODE(l_targ_multi_curr_flag,'Y', 'User', null),Null),
                              decode(count(pbls.budget_line_id),1,max(pbls.PROJFUNC_REV_RATE_DATE_TYPE),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.PROJFUNC_REV_RATE_DATE),null),
                              DECODE(l_cost_impl_flag,'Y',DECODE(l_targ_multi_curr_flag, 'Y','User', null),Null),
                              decode(count(pbls.budget_line_id),1,max(pbls.PROJECT_COST_RATE_DATE_TYPE),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.PROJECT_COST_RATE_DATE),null),
                              sum(Decode(l_cost_impl_flag ,'Y',pbls.project_raw_cost, null)),
                              sum(Decode(l_cost_impl_flag ,'Y',pbls.project_burdened_cost,null)),
                              Decode(l_rev_impl_flag, 'Y', DECODE(l_targ_multi_curr_flag, 'Y', 'User', null),Null),
                              decode(count(pbls.budget_line_id),1,max(pbls.PROJECT_REV_RATE_DATE_TYPE),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.PROJECT_REV_RATE_DATE),null),
                              sum(Decode(l_rev_impl_flag , 'Y', pbls.project_revenue,null))*l_partial_factor,
                              DECODE(l_copy_pfc_for_txn_amt_flag,'Y',l_projfunc_currency_code,DECODE(l_same_multi_curr_flag,'Y', pbls.txn_currency_code,l_project_currency_code)),


                              --Bug 4224757.. Code changes for bug#4224757 starts here
                              SUM(decode(l_cost_impl_flag,'Y', decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.raw_cost,0),
                              DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_raw_cost,0), nvl(pbls.project_raw_cost,0))))),
                              SUM(decode(l_cost_impl_flag,'Y', decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.burdened_cost,0),
                              DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_burdened_cost,0),
                              nvl(pbls.project_burdened_cost,0))))) ,
                              SUM(decode(l_rev_impl_flag,'Y',decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.revenue,0),
                              DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_revenue,0),
                              nvl(pbls.project_revenue,0)))))*l_partial_factor ,
                              --Bug 4224757.. Code changes for bug#4224757 ends here

                              decode(count(pbls.budget_line_id),1,max(pbls.BUCKETING_PERIOD_CODE),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.txn_standard_cost_rate),null),

                              --Bug 4224757. Code changes for bug#4224757 starts here
                              decode(nvl(sum(pbls.quantity),0),0,0,SUM(decode(l_cost_impl_flag,'Y',
                              decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.raw_cost,0), DECODE(l_same_multi_curr_flag, 'Y',
                               nvl(pbls.txn_raw_cost,0), nvl(pbls.project_raw_cost,0))) ))/
                              decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                                decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null)))   ,
                              --Bug 4224757. Code changes for bug#4224757 ends here

                              decode(count(pbls.budget_line_id),1,max(pbls.cost_ind_compiled_set_id),null),
                           --     decode(count(pbls.budget_line_id),1,max(pbls.txn_burden_multiplier),null),

                              decode(count(pbls.budget_line_id),1,max(pbls.txn_standard_bill_rate),null),

                              --Bug 4224757. Code changes for bug#4224757 starts here
                              decode(nvl(sum(pbls.quantity),0),0,0,sum(Decode(l_rev_impl_flag ,'Y',
                                 decode(l_copy_pfc_for_txn_amt_flag,'Y', nvl(pbls.revenue,0), DECODE(l_same_multi_curr_flag,
                                   'Y', nvl(pbls.txn_revenue,0), nvl(pbls.project_revenue,0)))))*l_partial_factor/
                              decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                                   decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null))),
                                 --Bug 4224757. Code changes for bug#4224757 ends here

                              decode(count(pbls.budget_line_id),1,max(pbls.TXN_MARKUP_PERCENT),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.TXN_MARKUP_PERCENT_OVERRIDE),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.TXN_DISCOUNT_PERCENTAGE),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.TRANSFER_PRICE_RATE),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.BURDEN_COST_RATE),null),

                              --Bug 4224757. Code changes for bug#4224757 starts here
                              decode(nvl(sum(pbls.quantity),0),0,0,SUM(decode(l_cost_impl_flag,'Y',
                              decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.burdened_cost,0), DECODE(l_same_multi_curr_flag, 'Y',
                               nvl(pbls.txn_burdened_cost,0), nvl(pbls.project_burdened_cost,0))) ))/
                              decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                         decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null))) ,
                              --Bug 4224757. Code changes for bug#4224757 ends here

                              decode(count(pbls.budget_line_id),1,max(pbls.PC_CUR_CONV_REJECTION_CODE),null),
                              decode(count(pbls.budget_line_id),1,max(pbls.PFC_CUR_CONV_REJECTION_CODE),null)
                         BULK COLLECT INTO
                               l_bl_RESOURCE_ASIGNMENT_ID_tbl,
                               l_upd_ra_bl_dml_code_tbl,
                               l_bl_START_DATE_tbl,
                               l_bl_END_DATE_tbl,
                               l_bl_PERIOD_NAME_tbl,
                               l_bl_QUANTITY_tbl,
                               l_bl_RAW_COST_tbl,
                               l_bl_BURDENED_COST_tbl,
                               l_bl_REVENUE_tbl,
                               l_bl_CHANGE_REASON_CODE_tbl,
                               l_bl_DESCRIPTION_tbl,
                               l_bl_ATTRIBUTE_CATEGORY_tbl,
                               l_bl_ATTRIBUTE1_tbl,
                               l_bl_ATTRIBUTE2_tbl,
                               l_bl_ATTRIBUTE3_tbl,
                               l_bl_ATTRIBUTE4_tbl,
                               l_bl_ATTRIBUTE5_tbl,
                               l_bl_ATTRIBUTE6_tbl,
                               l_bl_ATTRIBUTE7_tbl,
                               l_bl_ATTRIBUTE8_tbl,
                               l_bl_ATTRIBUTE9_tbl,
                               l_bl_ATTRIBUTE10_tbl,
                               l_bl_ATTRIBUTE11_tbl,
                               l_bl_ATTRIBUTE12_tbl,
                               l_bl_ATTRIBUTE13_tbl,
                               l_bl_ATTRIBUTE14_tbl,
                               l_bl_ATTRIBUTE15_tbl,
                               l_bl_PM_PRODUCT_CODE_tbl,
                               l_bl_PM_BUDGET_LINE_REF_tbl,
                               l_bl_COST_REJECTION_CODE_tbl,
                               l_bl_REVENUE_REJ_CODE_tbl,
                               l_bl_BURDEN_REJECTION_CODE_tbl,
                               l_bl_OTHER_REJECTION_CODE_tbl,
                               l_bl_CODE_COMBINATION_ID_tbl,
                               l_bl_CCID_GEN_STATUS_CODE_tbl,
                               l_bl_CCID_GEN_REJ_MESSAGE_tbl,
                               l_bl_REQUEST_ID_tbl,
                               l_bl_BORROWED_REVENUE_tbl,
                               l_bl_TP_REVENUE_IN_tbl,
                               l_bl_TP_REVENUE_OUT_tbl,
                               l_bl_REVENUE_ADJ_tbl,
                               l_bl_LENT_RESOURCE_COST_tbl,
                               l_bl_TP_COST_IN_tbl,
                               l_bl_TP_COST_OUT_tbl,
                               l_bl_COST_ADJ_tbl,
                               l_bl_UNASSIGNED_TIME_COST_tbl,
                               l_bl_UTILIZATION_PERCENT_tbl,
                               l_bl_UTILIZATION_HOURS_tbl,
                               l_bl_UTILIZATION_ADJ_tbl,
                               l_bl_CAPACITY_tbl,
                               l_bl_HEAD_COUNT_tbl,
                               l_bl_HEAD_COUNT_ADJ_tbl,
                               l_bl_PROJFUNC_CUR_CODE_tbl,
                               l_bl_PROJFUNC_COST_RAT_TYP_tbl,
                               l_bl_PJFN_COST_RAT_DAT_TYP_tbl,
                               l_bl_PROJFUNC_COST_RAT_DAT_tbl,
                               l_bl_PROJFUNC_REV_RATE_TYP_tbl,
                               l_bl_PJFN_REV_RAT_DAT_TYPE_tbl,
                               l_bl_PROJFUNC_REV_RAT_DATE_tbl,
                               l_bl_PROJECT_COST_RAT_TYPE_tbl,
                               l_bl_PROJ_COST_RAT_DAT_TYP_tbl,
                               l_bl_PROJ_COST_RATE_DATE_tbl,
                               l_bl_PROJECT_RAW_COST_tbl,
                               l_bl_PROJECT_BURDENED_COST_tbl,
                               l_bl_PROJECT_REV_RATE_TYPE_tbl,
                               l_bl_PRJ_REV_RAT_DATE_TYPE_tbl,
                               l_bl_PROJECT_REV_RATE_DATE,
                               l_bl_PROJECT_REVENUE_tbl,
                               l_bl_TXN_CURRENCY_CODE_tbl,
                               l_bl_TXN_RAW_COST_tbl,
                               l_bl_TXN_BURDENED_COST_tbl,
                               l_bl_TXN_REVENUE_tbl,
                               l_bl_BUCKETING_PERIOD_CODE_tbl,
                               l_bl_TXN_STD_COST_RATE_tbl,
                               l_bl_TXN_COST_RATE_OVERIDE_tbl,
                               l_bl_COST_IND_CMPLD_SET_ID_tbl,
                           --      l_bl_TXN_BURDEN_MULTIPLIER_tbl,
                           --      l_bl_TXN_BRD_MLTIPLI_OVRID_tbl,
                               l_bl_TXN_STD_BILL_RATE_tbl,
                               l_bl_TXN_BILL_RATE_OVERRID_tbl,
                               l_bl_TXN_MARKUP_PERCENT_tbl,
                               l_bl_TXN_MRKUP_PER_OVERIDE_tbl,
                               l_bl_TXN_DISC_PERCENTAGE_tbl,
                               l_bl_TRANSFER_PRICE_RATE_tbl,
                               l_bl_BURDEN_COST_RATE_tbl,
                               l_bl_BURDEN_COST_RAT_OVRID_tbl,
                               l_bl_PC_CUR_CONV_REJ_CODE_tbl,
                               l_bl_PFC_CUR_CONV_REJ_CODE_tbl
                         from   pa_budget_lines pblt,
                                pa_resource_assignments prat,
                           (SELECT  pbls.resource_assignment_id
                                 ,pbls.start_date
                                 ,pbls.last_update_date
                                 ,pbls.last_updated_by
                                 ,pbls.creation_date
                                 ,pbls.created_by
                                 ,pbls.last_update_login
                                 ,pbls.end_date
                                 ,pbls.period_name
                                 ,pbls.quantity
                                 ,pbls.raw_cost
                                 ,pbls.burdened_cost
                                 ,pbls.revenue
                                 ,pbls.change_reason_code
                                 ,pbls.description
                                 ,pbls.attribute_category
                                 ,pbls.attribute1
                                 ,pbls.attribute2
                                 ,pbls.attribute3
                                 ,pbls.attribute4
                                 ,pbls.attribute5
                                 ,pbls.attribute6
                                 ,pbls.attribute7
                                 ,pbls.attribute8
                                 ,pbls.attribute9
                                 ,pbls.attribute10
                                 ,pbls.attribute11
                                 ,pbls.attribute12
                                 ,pbls.attribute13
                                 ,pbls.attribute14
                                 ,pbls.attribute15
                                 ,pbls.raw_cost_source
                                 ,pbls.burdened_cost_source
                                 ,pbls.quantity_source
                                 ,pbls.revenue_source
                                 ,pbls.pm_product_code
                                 ,pbls.pm_budget_line_reference
                                 ,pbls.cost_rejection_code
                                 ,pbls.revenue_rejection_code
                                 ,pbls.burden_rejection_code
                                 ,pbls.other_rejection_code
                                 ,pbls.code_combination_id
                                 ,pbls.ccid_gen_status_code
                                 ,pbls.ccid_gen_rej_message
                                 ,pbls.request_id
                                 ,pbls.borrowed_revenue
                                 ,pbls.tp_revenue_in
                                 ,pbls.tp_revenue_out
                                 ,pbls.revenue_adj
                                 ,pbls.lent_resource_cost
                                 ,pbls.tp_cost_in
                                 ,pbls.tp_cost_out
                                 ,pbls.cost_adj
                                 ,pbls.unassigned_time_cost
                                 ,pbls.utilization_percent
                                 ,pbls.utilization_hours
                                 ,pbls.utilization_adj
                                 ,pbls.capacity
                                 ,pbls.head_count
                                 ,pbls.head_count_adj
                                 ,pbls.projfunc_currency_code
                                 ,pbls.projfunc_cost_rate_type
                                 ,pbls.projfunc_cost_exchange_rate
                                 ,pbls.projfunc_cost_rate_date_type
                                 ,pbls.projfunc_cost_rate_date
                                 ,pbls.projfunc_rev_rate_type
                                 ,pbls.projfunc_rev_exchange_rate
                                 ,pbls.projfunc_rev_rate_date_type
                                 ,pbls.projfunc_rev_rate_date
                                 ,pbls.project_currency_code
                                 ,pbls.project_cost_rate_type
                                 ,pbls.project_cost_exchange_rate
                                 ,pbls.project_cost_rate_date_type
                                 ,pbls.project_cost_rate_date
                                 ,pbls.project_raw_cost
                                 ,pbls.project_burdened_cost
                                 ,pbls.project_rev_rate_type
                                 ,pbls.project_rev_exchange_rate
                                 ,pbls.project_rev_rate_date_type
                                 ,pbls.project_rev_rate_date
                                 ,pbls.project_revenue
                                 ,pbls.txn_currency_code
                                 ,pbls.txn_raw_cost
                                 ,pbls.txn_burdened_cost
                                 ,pbls.txn_revenue
                                 ,pbls.bucketing_period_code
                                 ,pbls.budget_line_id
                                 ,pbls.budget_version_id
                                 ,pbls.txn_standard_cost_rate
                                 ,pbls.txn_cost_rate_override
                                 ,pbls.cost_ind_compiled_set_id
                                 ,pbls.txn_standard_bill_rate
                                 ,pbls.txn_bill_rate_override
                                 ,pbls.txn_markup_percent
                                 ,pbls.txn_markup_percent_override
                                 ,pbls.txn_discount_percentage
                                 ,pbls.transfer_price_rate
                                 ,pbls.burden_cost_rate
                                 ,pbls.burden_cost_rate_override
                                 ,pbls.pc_cur_conv_rejection_code
                                 ,pbls.pfc_cur_conv_rejection_code
                                 ,pras.resource_assignment_id
                                 ,pras.task_id
                                 ,tmp4.resource_list_member_id
                             FROM   pa_resource_assignments pras,
                                  pa_res_list_map_tmp4 tmp4,
                                  pa_budget_lines pbls
                             WHERE  tmp4.txn_source_id=pras.resource_assignment_id
                             AND    pbls.resource_assignment_id=pras.resource_assignment_id) pbls
                         where  get_mapped_dml_code(get_task_id(l_targ_plan_level_code,pbls.task_id),pbls.resource_list_member_id)='UPDATE'
                         and    pblt.budget_version_id(+) = p_budget_version_id
                         and    pblt.resource_assignment_id(+)=get_mapped_ra_id(get_task_id(l_targ_plan_level_code,pbls.task_id), pbls.resource_list_member_id)
                         AND    pblt.txn_currency_code(+)=DECODE(l_copy_pfc_for_txn_amt_flag,'Y', l_projfunc_currency_code,
                                                       DECODE(l_same_multi_curr_flag, 'Y', pbls.txn_currency_code,l_project_currency_code))
                         and    prat.resource_assignment_id=get_mapped_ra_id(get_task_id(l_targ_plan_level_code,pbls.task_id), pbls.resource_list_member_id)
                         --IPM Arch Enhancement Bug 4865563
                       /*and    pbls.cost_rejection_code IS NULL
                         and    pbls.revenue_rejection_code IS NULL
                         and    pbls.burden_rejection_code IS NULL
                         and    pbls.other_rejection_code IS NULL
                         and    pbls.pc_cur_conv_rejection_code IS NULL
                         and    pbls.pfc_cur_conv_rejection_code IS NULL*/
                         GROUP BY get_mapped_ra_id(get_task_id(l_targ_plan_level_code,pbls.task_id), pbls.resource_list_member_id), DECODE(l_same_multi_curr_flag, 'Y', pbls.txn_currency_code,l_project_currency_code),
                                pblt.resource_assignment_id,pblt.txn_currency_code,pblt.start_date,prat.planning_start_date, prat.planning_end_date,pblt.end_date ;

                         IF P_PA_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Done with bulk select for ins/upd the budget lins with targ NTP and Diff RLS';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                         END IF;
                         --dbms_output.put_line('I37');

                  END IF;


                ELSE -- Time phased code is not N and src time phasing = target time phasing
                  IF l_src_resource_list_id = l_targ_resource_list_id THEN

                     IF P_PA_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:='About to select bls for PA/GL TP and same resource list';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                     END IF;

                     --dbms_output.put_line('I38');

                     SELECT get_mapped_ra_id(null,null,pbls.resource_assignment_id,l_targ_plan_level_code),
                         decode(pblt.resource_assignment_id,null, 'INSERT',
                                                   decode(pblt.txn_currency_code, null,'INSERT',
                                                      decode(pblt.start_date,null,'INSERT','UPDATE'))),
                         pbls.start_date,
                         pbls.end_date,
                         pbls.period_name,
                         decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                            decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null)),
                         sum(Decode(l_cost_impl_flag ,'Y', pbls.raw_cost,null)),
                         sum(Decode(l_cost_impl_flag ,'Y', pbls.burdened_cost, null)),
                         sum(Decode(l_rev_impl_flag ,'Y', pbls.revenue, null))*l_partial_factor,
                         decode(count(pbls.budget_line_id),1,max(pbls.change_reason_code),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.description),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.attribute_category),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.attribute1),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.attribute2),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.attribute3),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.attribute4),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.attribute5),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.attribute6),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.attribute7),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.attribute8),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.attribute9),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.attribute10),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.attribute11),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.attribute12),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.attribute13),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.attribute14),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.attribute15),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.pm_product_code),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.pm_budget_line_reference),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.cost_rejection_code),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.revenue_rejection_code),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.burden_rejection_code),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.other_rejection_code),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.code_combination_id),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.ccid_gen_status_code),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.CCID_GEN_REJ_MESSAGE),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.REQUEST_ID),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.BORROWED_REVENUE),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.TP_REVENUE_IN),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.TP_REVENUE_OUT),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.REVENUE_ADJ),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.LENT_RESOURCE_COST),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.TP_COST_IN),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.TP_COST_OUT),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.COST_ADJ),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.UNASSIGNED_TIME_COST),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.UTILIZATION_PERCENT),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.UTILIZATION_HOURS),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.UTILIZATION_ADJ),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.CAPACITY),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.HEAD_COUNT),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.HEAD_COUNT_ADJ),null),
                         l_projfunc_currency_code,
                         DECODE(l_cost_impl_flag,'Y', DECODE(l_targ_multi_curr_flag,'Y', 'User', null),Null),
                         decode(count(pbls.budget_line_id),1,max(pbls.PROJFUNC_COST_RATE_DATE_TYPE),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.PROJFUNC_COST_RATE_DATE),null),
                         Decode(l_rev_impl_flag,'Y',DECODE(l_targ_multi_curr_flag,'Y', 'User', null),Null),
                         decode(count(pbls.budget_line_id),1,max(pbls.PROJFUNC_REV_RATE_DATE_TYPE),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.PROJFUNC_REV_RATE_DATE),null),
                         DECODE(l_cost_impl_flag,'Y',DECODE(l_targ_multi_curr_flag, 'Y','User', null),Null),
                         decode(count(pbls.budget_line_id),1,max(pbls.PROJECT_COST_RATE_DATE_TYPE),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.PROJECT_COST_RATE_DATE),null),
                         sum(Decode(l_cost_impl_flag ,'Y',pbls.project_raw_cost,null)),
                         sum(Decode(l_cost_impl_flag ,'Y',pbls.project_burdened_cost, null)),
                         Decode(l_rev_impl_flag, 'Y', DECODE(l_targ_multi_curr_flag, 'Y', 'User', null),Null),
                         decode(count(pbls.budget_line_id),1,max(pbls.PROJECT_REV_RATE_DATE_TYPE),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.PROJECT_REV_RATE_DATE),null),
                         sum(Decode(l_rev_impl_flag , 'Y', pbls.project_revenue,null))*l_partial_factor,
                         DECODE(l_copy_pfc_for_txn_amt_flag,'Y',l_projfunc_currency_code,DECODE(l_same_multi_curr_flag,'Y', pbls.txn_currency_code,l_project_currency_code)),
                         --Bug 4247568. Code changes for bug 4247568  starts here. If src multi curr flag and targ multi curr flag are  -- diff then reutrn project raw cost, project burdened cost  and project  revenue.
                         SUM(decode(l_cost_impl_flag,'Y', decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.raw_cost,0), DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_raw_cost,0), nvl(pbls.project_raw_cost,0))))),
                         SUM(decode(l_cost_impl_flag,'Y', decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.burdened_cost,0),
                         DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_burdened_cost,0), nvl(pbls.project_burdened_cost,0))))),
                         SUM(decode(l_rev_impl_flag,'Y',decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.revenue,0),
                         DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_revenue,0), nvl(pbls.project_revenue,0)))))*l_partial_factor,
                         --Bug 4247568. Code changes for bug 4247568  ends here.
                         decode(count(pbls.budget_line_id),1,max(pbls.BUCKETING_PERIOD_CODE),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.txn_standard_cost_rate),null),

                         --Bug 4224757. Code changes for bug#4224757 starts here
                         decode(nvl(sum(pbls.quantity),0),0,0,SUM(decode(l_cost_impl_flag,'Y',
                         decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.raw_cost,0), DECODE(l_same_multi_curr_flag, 'Y',
                        nvl(pbls.txn_raw_cost,0), nvl(pbls.project_raw_cost,0))) ))/
                         decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                         decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null)))   ,
                         --Bug 4224757. Code changes for bug#4224757 ends here

                         decode(count(pbls.budget_line_id),1,max(pbls.cost_ind_compiled_set_id),null),
                    --       decode(count(pbls.budget_line_id),1,max(pbls.txn_burden_multiplier),null),

                         decode(count(pbls.budget_line_id),1,max(pbls.txn_standard_bill_rate),null),

                         --Bug 4224757. Code changes for bug#4224757 starts here
                         decode(nvl(sum(pbls.quantity),0),0,0,sum(Decode(l_rev_impl_flag ,'Y',
                               decode(l_copy_pfc_for_txn_amt_flag,'Y', nvl(pbls.revenue,0), DECODE(l_same_multi_curr_flag,
                                   'Y', nvl(pbls.txn_revenue,0), nvl(pbls.project_revenue,0)))))*l_partial_factor/
                         decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                              decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null))),
                         --Bug 4224757. Code changes for bug#4224757 ends here


                         decode(count(pbls.budget_line_id),1,max(pbls.TXN_MARKUP_PERCENT),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.TXN_MARKUP_PERCENT_OVERRIDE),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.TXN_DISCOUNT_PERCENTAGE),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.TRANSFER_PRICE_RATE),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.BURDEN_COST_RATE),null),

                         --Bug 4224757. Code changes for bug#4224757 starts here
                         decode(nvl(sum(pbls.quantity),0),0,0,SUM(decode(l_cost_impl_flag,'Y',
                         decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.burdened_cost,0), DECODE(l_same_multi_curr_flag, 'Y',
                          nvl(pbls.txn_burdened_cost,0), nvl(pbls.project_burdened_cost,0))) ))/
                         decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                      decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null))),
                         --Bug 4224757. Code changes for bug#4224757 ends here

                         decode(count(pbls.budget_line_id),1,max(pbls.PC_CUR_CONV_REJECTION_CODE),null),
                         decode(count(pbls.budget_line_id),1,max(pbls.PFC_CUR_CONV_REJECTION_CODE),null)
                        BULK COLLECT INTO
                         l_bl_RESOURCE_ASIGNMENT_ID_tbl,
                         l_upd_ra_bl_dml_code_tbl,
                         l_bl_START_DATE_tbl,
                         l_bl_END_DATE_tbl,
                         l_bl_PERIOD_NAME_tbl,
                         l_bl_QUANTITY_tbl,
                         l_bl_RAW_COST_tbl,
                         l_bl_BURDENED_COST_tbl,
                         l_bl_REVENUE_tbl,
                         l_bl_CHANGE_REASON_CODE_tbl,
                         l_bl_DESCRIPTION_tbl,
                         l_bl_ATTRIBUTE_CATEGORY_tbl,
                         l_bl_ATTRIBUTE1_tbl,
                         l_bl_ATTRIBUTE2_tbl,
                         l_bl_ATTRIBUTE3_tbl,
                         l_bl_ATTRIBUTE4_tbl,
                         l_bl_ATTRIBUTE5_tbl,
                         l_bl_ATTRIBUTE6_tbl,
                         l_bl_ATTRIBUTE7_tbl,
                         l_bl_ATTRIBUTE8_tbl,
                         l_bl_ATTRIBUTE9_tbl,
                         l_bl_ATTRIBUTE10_tbl,
                         l_bl_ATTRIBUTE11_tbl,
                         l_bl_ATTRIBUTE12_tbl,
                         l_bl_ATTRIBUTE13_tbl,
                         l_bl_ATTRIBUTE14_tbl,
                         l_bl_ATTRIBUTE15_tbl,
                         l_bl_PM_PRODUCT_CODE_tbl,
                         l_bl_PM_BUDGET_LINE_REF_tbl,
                         l_bl_COST_REJECTION_CODE_tbl,
                         l_bl_REVENUE_REJ_CODE_tbl,
                         l_bl_BURDEN_REJECTION_CODE_tbl,
                         l_bl_OTHER_REJECTION_CODE_tbl,
                         l_bl_CODE_COMBINATION_ID_tbl,
                         l_bl_CCID_GEN_STATUS_CODE_tbl,
                         l_bl_CCID_GEN_REJ_MESSAGE_tbl,
                         l_bl_REQUEST_ID_tbl,
                         l_bl_BORROWED_REVENUE_tbl,
                         l_bl_TP_REVENUE_IN_tbl,
                         l_bl_TP_REVENUE_OUT_tbl,
                         l_bl_REVENUE_ADJ_tbl,
                         l_bl_LENT_RESOURCE_COST_tbl,
                         l_bl_TP_COST_IN_tbl,
                         l_bl_TP_COST_OUT_tbl,
                         l_bl_COST_ADJ_tbl,
                         l_bl_UNASSIGNED_TIME_COST_tbl,
                         l_bl_UTILIZATION_PERCENT_tbl,
                         l_bl_UTILIZATION_HOURS_tbl,
                         l_bl_UTILIZATION_ADJ_tbl,
                         l_bl_CAPACITY_tbl,
                         l_bl_HEAD_COUNT_tbl,
                         l_bl_HEAD_COUNT_ADJ_tbl,
                         l_bl_PROJFUNC_CUR_CODE_tbl,
                         l_bl_PROJFUNC_COST_RAT_TYP_tbl,
                         l_bl_PJFN_COST_RAT_DAT_TYP_tbl,
                         l_bl_PROJFUNC_COST_RAT_DAT_tbl,
                         l_bl_PROJFUNC_REV_RATE_TYP_tbl,
                         l_bl_PJFN_REV_RAT_DAT_TYPE_tbl,
                         l_bl_PROJFUNC_REV_RAT_DATE_tbl,
                         l_bl_PROJECT_COST_RAT_TYPE_tbl,
                         l_bl_PROJ_COST_RAT_DAT_TYP_tbl,
                         l_bl_PROJ_COST_RATE_DATE_tbl,
                         l_bl_PROJECT_RAW_COST_tbl,
                         l_bl_PROJECT_BURDENED_COST_tbl,
                         l_bl_PROJECT_REV_RATE_TYPE_tbl,
                         l_bl_PRJ_REV_RAT_DATE_TYPE_tbl,
                         l_bl_PROJECT_REV_RATE_DATE,
                         l_bl_PROJECT_REVENUE_tbl,
                         l_bl_TXN_CURRENCY_CODE_tbl,
                         l_bl_TXN_RAW_COST_tbl,
                         l_bl_TXN_BURDENED_COST_tbl,
                         l_bl_TXN_REVENUE_tbl,
                         l_bl_BUCKETING_PERIOD_CODE_tbl,
                         l_bl_TXN_STD_COST_RATE_tbl,
                         l_bl_TXN_COST_RATE_OVERIDE_tbl,
                         l_bl_COST_IND_CMPLD_SET_ID_tbl,
                      --     l_bl_TXN_BURDEN_MULTIPLIER_tbl,
                      --     l_bl_TXN_BRD_MLTIPLI_OVRID_tbl,
                         l_bl_TXN_STD_BILL_RATE_tbl,
                         l_bl_TXN_BILL_RATE_OVERRID_tbl,
                         l_bl_TXN_MARKUP_PERCENT_tbl,
                         l_bl_TXN_MRKUP_PER_OVERIDE_tbl,
                         l_bl_TXN_DISC_PERCENTAGE_tbl,
                         l_bl_TRANSFER_PRICE_RATE_tbl,
                         l_bl_BURDEN_COST_RATE_tbl,
                         l_bl_BURDEN_COST_RAT_OVRID_tbl,
                         l_bl_PC_CUR_CONV_REJ_CODE_tbl,
                         l_bl_PFC_CUR_CONV_REJ_CODE_tbl
                        from   pa_budget_lines pbls,
                             pa_budget_lines pblt
                        where  get_mapped_dml_code(null,null,pbls.resource_assignment_id,l_targ_plan_level_code)='UPDATE'
                        and    pbls.budget_version_id = l_src_ver_id_tbl(j)
                        and    pblt.budget_version_id(+) = p_budget_version_id
                        and    pblt.resource_assignment_id(+)=get_mapped_ra_id(null,null,pbls.resource_assignment_id,l_targ_plan_level_code)
                        AND    pblt.txn_currency_code(+)=DECODE(l_copy_pfc_for_txn_amt_flag,'Y', l_projfunc_currency_code,
                                                      DECODE(l_same_multi_curr_flag, 'Y', pbls.txn_currency_code,l_project_currency_code))
                        AND    pblt.start_date(+)=pbls.start_date
                        --IPM Arch Enhancement Bug 4865563
                      /*and    pbls.cost_rejection_code IS NULL
                        and    pbls.revenue_rejection_code IS NULL
                        and    pbls.burden_rejection_code IS NULL
                        and    pbls.other_rejection_code IS NULL
                        and    pbls.pc_cur_conv_rejection_code IS NULL
                        and    pbls.pfc_cur_conv_rejection_code IS NULL*/
                        and    pbls.start_date >= nvl(l_etc_start_date,pbls.start_date)
                        GROUP BY get_mapped_ra_id(null,null,pbls.resource_assignment_id,l_targ_plan_level_code), DECODE(l_same_multi_curr_flag, 'Y', pbls.txn_currency_code,l_project_currency_code)
                              ,pbls.start_date, pbls.period_name,pbls.end_date,pblt.resource_assignment_id,
                              pblt.start_Date,pblt.txn_currency_code;

                       IF P_PA_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:='selected bls for PA/GL TP and same resource list';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                       END IF;
                       --dbms_output.put_line('I39');

                  ELSE--Time phased code is not None and Resource lists are different

                      --dbms_output.put_line('I40');
                      SELECT get_mapped_ra_id(get_task_id(l_targ_plan_level_code,pbls.task_id), pbls.resource_list_member_id),
                           decode(pblt.resource_assignment_id,null, 'INSERT',
                                                      decode(pblt.txn_currency_code, null,'INSERT',
                                                           decode(pblt.start_date,null,'INSERT','UPDATE'))),
                           pbls.start_date,
                           pbls.end_date,
                           pbls.period_name,
                           decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                              decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null)),
                           sum(Decode(l_cost_impl_flag ,'Y', pbls.raw_cost, null)),
                           sum(Decode(l_cost_impl_flag ,'Y', pbls.burdened_cost,null)),
                           sum(Decode(l_rev_impl_flag ,'Y', pbls.revenue,null))*l_partial_factor,
                           decode(count(pbls.budget_line_id),1,max(pbls.change_reason_code),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.description),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.attribute_category),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.attribute1),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.attribute2),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.attribute3),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.attribute4),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.attribute5),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.attribute6),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.attribute7),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.attribute8),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.attribute9),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.attribute10),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.attribute11),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.attribute12),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.attribute13),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.attribute14),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.attribute15),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.pm_product_code),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.pm_budget_line_reference),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.cost_rejection_code),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.revenue_rejection_code),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.burden_rejection_code),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.other_rejection_code),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.code_combination_id),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.ccid_gen_status_code),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.CCID_GEN_REJ_MESSAGE),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.REQUEST_ID),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.BORROWED_REVENUE),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.TP_REVENUE_IN),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.TP_REVENUE_OUT),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.REVENUE_ADJ),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.LENT_RESOURCE_COST),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.TP_COST_IN),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.TP_COST_OUT),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.COST_ADJ),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.UNASSIGNED_TIME_COST),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.UTILIZATION_PERCENT),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.UTILIZATION_HOURS),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.UTILIZATION_ADJ),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.CAPACITY),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.HEAD_COUNT),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.HEAD_COUNT_ADJ),null),
                           l_projfunc_currency_code,
                           DECODE(l_cost_impl_flag,'Y', DECODE(l_targ_multi_curr_flag,'Y', 'User', null),Null),
                           decode(count(pbls.budget_line_id),1,max(pbls.PROJFUNC_COST_RATE_DATE_TYPE),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.PROJFUNC_COST_RATE_DATE),null),
                           Decode(l_rev_impl_flag,'Y',DECODE(l_targ_multi_curr_flag,'Y', 'User', null),Null),
                           decode(count(pbls.budget_line_id),1,max(pbls.PROJFUNC_REV_RATE_DATE_TYPE),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.PROJFUNC_REV_RATE_DATE),null),
                           DECODE(l_cost_impl_flag,'Y',DECODE(l_targ_multi_curr_flag, 'Y','User', null),Null),
                           decode(count(pbls.budget_line_id),1,max(pbls.PROJECT_COST_RATE_DATE_TYPE),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.PROJECT_COST_RATE_DATE),null),
                           sum(Decode(l_cost_impl_flag ,'Y',pbls.project_raw_cost,null)),
                           sum(Decode(l_cost_impl_flag ,'Y',pbls.project_burdened_cost,null)),
                           Decode(l_rev_impl_flag, 'Y', DECODE(l_targ_multi_curr_flag, 'Y', 'User', null),Null),
                           decode(count(pbls.budget_line_id),1,max(pbls.PROJECT_REV_RATE_DATE_TYPE),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.PROJECT_REV_RATE_DATE),null),
                           sum(Decode(l_rev_impl_flag , 'Y', pbls.project_revenue,null))*l_partial_factor,
                           DECODE(l_copy_pfc_for_txn_amt_flag,'Y',l_projfunc_currency_code,DECODE(l_same_multi_curr_flag,'Y', pbls.txn_currency_code,l_project_currency_code)),


                           --Bug 4224757.. Code changes for bug#4224757 starts here
                           SUM(decode(l_cost_impl_flag,'Y', decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.raw_cost,0),
                           DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_raw_cost,0), nvl(pbls.project_raw_cost,0))))),
                           SUM(decode(l_cost_impl_flag,'Y', decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.burdened_cost,0),
                           DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_burdened_cost,0),
                           nvl(pbls.project_burdened_cost,0))))) ,
                           SUM(decode(l_rev_impl_flag,'Y',decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.revenue,0),
                           DECODE(l_same_multi_curr_flag, 'Y', nvl(pbls.txn_revenue,0),
                           nvl(pbls.project_revenue,0)))))*l_partial_factor ,
                           --Bug 4224757.. Code changes for bug#4224757 ends here


                           decode(count(pbls.budget_line_id),1,max(pbls.BUCKETING_PERIOD_CODE),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.txn_standard_cost_rate),null),

                           --Bug 4224757. Code changes for bug#4224757 starts here
                           decode(nvl(sum(pbls.quantity),0),0,0,SUM(decode(l_cost_impl_flag,'Y',
                           decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.raw_cost,0), DECODE(l_same_multi_curr_flag, 'Y',
                            nvl(pbls.txn_raw_cost,0), nvl(pbls.project_raw_cost,0))) ))/
                           decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                       decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null)))  ,
                           --Bug 4224757. Code changes for bug#4224757 ends here

                           decode(count(pbls.budget_line_id),1,max(pbls.cost_ind_compiled_set_id),null),
                      --      decode(count(pbls.budget_line_id),1,max(pbls.txn_burden_multiplier),null),

                           decode(count(pbls.budget_line_id),1,max(pbls.txn_standard_bill_rate),null),

                           --Bug 4224757. Code changes for bug#4224757 starts here
                           decode(nvl(sum(pbls.quantity),0),0,0,sum(Decode(l_rev_impl_flag ,'Y',
                                decode(l_copy_pfc_for_txn_amt_flag,'Y', nvl(pbls.revenue,0), DECODE(l_same_multi_curr_flag,
                                   'Y', nvl(pbls.txn_revenue,0), nvl(pbls.project_revenue,0)))))*l_partial_factor/
                           decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                                decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null))),
                           --Bug 4224757. Code changes for bug#4224757 ends here

                           decode(count(pbls.budget_line_id),1,max(pbls.TXN_MARKUP_PERCENT),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.TXN_MARKUP_PERCENT_OVERRIDE),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.TXN_DISCOUNT_PERCENTAGE),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.TRANSFER_PRICE_RATE),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.BURDEN_COST_RATE),null),

                           --Bug 4224757. Code changes for bug#4224757 starts here
                           decode(nvl(sum(pbls.quantity),0),0,0,SUM(decode(l_cost_impl_flag,'Y',
                           decode(l_copy_pfc_for_txn_amt_flag,'Y',nvl(pbls.burdened_cost,0), DECODE(l_same_multi_curr_flag, 'Y',
                           nvl(pbls.txn_burdened_cost,0), nvl(pbls.project_burdened_cost,0))) ))/
                           decode(l_cost_impl_flag,'Y',sum(pbls.quantity),decode(l_rev_impl_flag,'Y',
                                                             decode(l_impl_qty_tbl(j),'Y', sum(pbls.quantity) * l_partial_factor,null),null))) ,
                           --Bug 4224757. Code changes for bug#4224757 ends here

                           decode(count(pbls.budget_line_id),1,max(pbls.PC_CUR_CONV_REJECTION_CODE),null),
                           decode(count(pbls.budget_line_id),1,max(pbls.PFC_CUR_CONV_REJECTION_CODE),null)
                      BULK COLLECT INTO
                            l_bl_RESOURCE_ASIGNMENT_ID_tbl,
                            l_upd_ra_bl_dml_code_tbl,
                            l_bl_START_DATE_tbl,
                            l_bl_END_DATE_tbl,
                            l_bl_PERIOD_NAME_tbl,
                            l_bl_QUANTITY_tbl,
                            l_bl_RAW_COST_tbl,
                            l_bl_BURDENED_COST_tbl,
                            l_bl_REVENUE_tbl,
                            l_bl_CHANGE_REASON_CODE_tbl,
                            l_bl_DESCRIPTION_tbl,
                            l_bl_ATTRIBUTE_CATEGORY_tbl,
                            l_bl_ATTRIBUTE1_tbl,
                            l_bl_ATTRIBUTE2_tbl,
                            l_bl_ATTRIBUTE3_tbl,
                            l_bl_ATTRIBUTE4_tbl,
                            l_bl_ATTRIBUTE5_tbl,
                            l_bl_ATTRIBUTE6_tbl,
                            l_bl_ATTRIBUTE7_tbl,
                            l_bl_ATTRIBUTE8_tbl,
                            l_bl_ATTRIBUTE9_tbl,
                            l_bl_ATTRIBUTE10_tbl,
                            l_bl_ATTRIBUTE11_tbl,
                            l_bl_ATTRIBUTE12_tbl,
                            l_bl_ATTRIBUTE13_tbl,
                            l_bl_ATTRIBUTE14_tbl,
                            l_bl_ATTRIBUTE15_tbl,
                            l_bl_PM_PRODUCT_CODE_tbl,
                            l_bl_PM_BUDGET_LINE_REF_tbl,
                            l_bl_COST_REJECTION_CODE_tbl,
                            l_bl_REVENUE_REJ_CODE_tbl,
                            l_bl_BURDEN_REJECTION_CODE_tbl,
                            l_bl_OTHER_REJECTION_CODE_tbl,
                            l_bl_CODE_COMBINATION_ID_tbl,
                            l_bl_CCID_GEN_STATUS_CODE_tbl,
                            l_bl_CCID_GEN_REJ_MESSAGE_tbl,
                            l_bl_REQUEST_ID_tbl,
                            l_bl_BORROWED_REVENUE_tbl,
                            l_bl_TP_REVENUE_IN_tbl,
                            l_bl_TP_REVENUE_OUT_tbl,
                            l_bl_REVENUE_ADJ_tbl,
                            l_bl_LENT_RESOURCE_COST_tbl,
                            l_bl_TP_COST_IN_tbl,
                            l_bl_TP_COST_OUT_tbl,
                            l_bl_COST_ADJ_tbl,
                            l_bl_UNASSIGNED_TIME_COST_tbl,
                            l_bl_UTILIZATION_PERCENT_tbl,
                            l_bl_UTILIZATION_HOURS_tbl,
                            l_bl_UTILIZATION_ADJ_tbl,
                            l_bl_CAPACITY_tbl,
                            l_bl_HEAD_COUNT_tbl,
                            l_bl_HEAD_COUNT_ADJ_tbl,
                            l_bl_PROJFUNC_CUR_CODE_tbl,
                            l_bl_PROJFUNC_COST_RAT_TYP_tbl,
                            l_bl_PJFN_COST_RAT_DAT_TYP_tbl,
                            l_bl_PROJFUNC_COST_RAT_DAT_tbl,
                            l_bl_PROJFUNC_REV_RATE_TYP_tbl,
                            l_bl_PJFN_REV_RAT_DAT_TYPE_tbl,
                            l_bl_PROJFUNC_REV_RAT_DATE_tbl,
                            l_bl_PROJECT_COST_RAT_TYPE_tbl,
                            l_bl_PROJ_COST_RAT_DAT_TYP_tbl,
                            l_bl_PROJ_COST_RATE_DATE_tbl,
                            l_bl_PROJECT_RAW_COST_tbl,
                            l_bl_PROJECT_BURDENED_COST_tbl,
                            l_bl_PROJECT_REV_RATE_TYPE_tbl,
                            l_bl_PRJ_REV_RAT_DATE_TYPE_tbl,
                            l_bl_PROJECT_REV_RATE_DATE,
                            l_bl_PROJECT_REVENUE_tbl,
                            l_bl_TXN_CURRENCY_CODE_tbl,
                            l_bl_TXN_RAW_COST_tbl,
                            l_bl_TXN_BURDENED_COST_tbl,
                            l_bl_TXN_REVENUE_tbl,
                            l_bl_BUCKETING_PERIOD_CODE_tbl,
                            l_bl_TXN_STD_COST_RATE_tbl,
                            l_bl_TXN_COST_RATE_OVERIDE_tbl,
                            l_bl_COST_IND_CMPLD_SET_ID_tbl,
                         --     l_bl_TXN_BURDEN_MULTIPLIER_tbl,
                         --     l_bl_TXN_BRD_MLTIPLI_OVRID_tbl,
                            l_bl_TXN_STD_BILL_RATE_tbl,
                            l_bl_TXN_BILL_RATE_OVERRID_tbl,
                            l_bl_TXN_MARKUP_PERCENT_tbl,
                            l_bl_TXN_MRKUP_PER_OVERIDE_tbl,
                            l_bl_TXN_DISC_PERCENTAGE_tbl,
                            l_bl_TRANSFER_PRICE_RATE_tbl,
                            l_bl_BURDEN_COST_RATE_tbl,
                            l_bl_BURDEN_COST_RAT_OVRID_tbl,
                            l_bl_PC_CUR_CONV_REJ_CODE_tbl,
                            l_bl_PFC_CUR_CONV_REJ_CODE_tbl
                      from   pa_budget_lines pblt,
                           (SELECT  pbls.resource_assignment_id
                                 ,pbls.start_date
                                 ,pbls.last_update_date
                                 ,pbls.last_updated_by
                                 ,pbls.creation_date
                                 ,pbls.created_by
                                 ,pbls.last_update_login
                                 ,pbls.end_date
                                 ,pbls.period_name
                                 ,pbls.quantity
                                 ,pbls.raw_cost
                                 ,pbls.burdened_cost
                                 ,pbls.revenue
                                 ,pbls.change_reason_code
                                 ,pbls.description
                                 ,pbls.attribute_category
                                 ,pbls.attribute1
                                 ,pbls.attribute2
                                 ,pbls.attribute3
                                 ,pbls.attribute4
                                 ,pbls.attribute5
                                 ,pbls.attribute6
                                 ,pbls.attribute7
                                 ,pbls.attribute8
                                 ,pbls.attribute9
                                 ,pbls.attribute10
                                 ,pbls.attribute11
                                 ,pbls.attribute12
                                 ,pbls.attribute13
                                 ,pbls.attribute14
                                 ,pbls.attribute15
                                 ,pbls.raw_cost_source
                                 ,pbls.burdened_cost_source
                                 ,pbls.quantity_source
                                 ,pbls.revenue_source
                                 ,pbls.pm_product_code
                                 ,pbls.pm_budget_line_reference
                                 ,pbls.cost_rejection_code
                                 ,pbls.revenue_rejection_code
                                 ,pbls.burden_rejection_code
                                 ,pbls.other_rejection_code
                                 ,pbls.code_combination_id
                                 ,pbls.ccid_gen_status_code
                                 ,pbls.ccid_gen_rej_message
                                 ,pbls.request_id
                                 ,pbls.borrowed_revenue
                                 ,pbls.tp_revenue_in
                                 ,pbls.tp_revenue_out
                                 ,pbls.revenue_adj
                                 ,pbls.lent_resource_cost
                                 ,pbls.tp_cost_in
                                 ,pbls.tp_cost_out
                                 ,pbls.cost_adj
                                 ,pbls.unassigned_time_cost
                                 ,pbls.utilization_percent
                                 ,pbls.utilization_hours
                                 ,pbls.utilization_adj
                                 ,pbls.capacity
                                 ,pbls.head_count
                                 ,pbls.head_count_adj
                                 ,pbls.projfunc_currency_code
                                 ,pbls.projfunc_cost_rate_type
                                 ,pbls.projfunc_cost_exchange_rate
                                 ,pbls.projfunc_cost_rate_date_type
                                 ,pbls.projfunc_cost_rate_date
                                 ,pbls.projfunc_rev_rate_type
                                 ,pbls.projfunc_rev_exchange_rate
                                 ,pbls.projfunc_rev_rate_date_type
                                 ,pbls.projfunc_rev_rate_date
                                 ,pbls.project_currency_code
                                 ,pbls.project_cost_rate_type
                                 ,pbls.project_cost_exchange_rate
                                 ,pbls.project_cost_rate_date_type
                                 ,pbls.project_cost_rate_date
                                 ,pbls.project_raw_cost
                                 ,pbls.project_burdened_cost
                                 ,pbls.project_rev_rate_type
                                 ,pbls.project_rev_exchange_rate
                                 ,pbls.project_rev_rate_date_type
                                 ,pbls.project_rev_rate_date
                                 ,pbls.project_revenue
                                 ,pbls.txn_currency_code
                                 ,pbls.txn_raw_cost
                                 ,pbls.txn_burdened_cost
                                 ,pbls.txn_revenue
                                 ,pbls.bucketing_period_code
                                 ,pbls.budget_line_id
                                 ,pbls.budget_version_id
                                 ,pbls.txn_standard_cost_rate
                                 ,pbls.txn_cost_rate_override
                                 ,pbls.cost_ind_compiled_set_id
                                 ,pbls.txn_standard_bill_rate
                                 ,pbls.txn_bill_rate_override
                                 ,pbls.txn_markup_percent
                                 ,pbls.txn_markup_percent_override
                                 ,pbls.txn_discount_percentage
                                 ,pbls.transfer_price_rate
                                 ,pbls.burden_cost_rate
                                 ,pbls.burden_cost_rate_override
                                 ,pbls.pc_cur_conv_rejection_code
                                 ,pbls.pfc_cur_conv_rejection_code
                                 ,pras.resource_assignment_id
                                 ,pras.task_id
                                 ,tmp4.resource_list_member_id
                             FROM   pa_resource_assignments pras,
                                  pa_res_list_map_tmp4 tmp4,
                                  pa_budget_lines pbls
                             WHERE  tmp4.txn_source_id=pras.resource_assignment_id
                             AND    pbls.resource_assignment_id=pras.resource_assignment_id) pbls
                      where  get_mapped_dml_code(get_task_id(l_targ_plan_level_code,pbls.task_id),pbls.resource_list_member_id)='UPDATE'
                      and    pblt.budget_version_id(+) = p_budget_version_id
                      and    pblt.resource_assignment_id(+)=get_mapped_ra_id(get_task_id(l_targ_plan_level_code,pbls.task_id), pbls.resource_list_member_id)
                      AND    pblt.txn_currency_code(+)=DECODE(l_copy_pfc_for_txn_amt_flag,'Y', l_projfunc_currency_code,
                                                    DECODE(l_same_multi_curr_flag, 'Y', pbls.txn_currency_code,l_project_currency_code))
                      AND    pblt.start_date(+)=pbls.start_date
                      --IPM Arch Enhancement Bug 4865563
                    /*and    pbls.cost_rejection_code IS NULL
                      and    pbls.revenue_rejection_code IS NULL
                      and    pbls.burden_rejection_code IS NULL
                      and    pbls.other_rejection_code IS NULL
                      and    pbls.pc_cur_conv_rejection_code IS NULL
                      and    pbls.pfc_cur_conv_rejection_code IS NULL*/
                      and    pbls.start_date >= nvl(l_etc_start_date,pbls.start_date)
                      GROUP BY get_mapped_ra_id(get_task_id(l_targ_plan_level_code,pbls.task_id), pbls.resource_list_member_id), DECODE(l_same_multi_curr_flag, 'Y', pbls.txn_currency_code,l_project_currency_code)
                      ,pbls.start_date,pbls.end_date,pbls.period_name,pblt.resource_assignment_id,pblt.txn_currency_code,pblt.start_date;

                      --dbms_output.put_line('I41');

                  END IF;
                  END IF;
                END IF;


                --Prepare a pl/sql table equal in length to l_upd_ra_bl_dml_code_tbl which contains the rate based flag
                --for the resource assignment to which the budget line corresponds. This will help in populating
                --correct values in quantity and rate columns of budget lines.Bug 3621847
                IF l_upd_ra_bl_dml_code_tbl.COUNT>0 THEN

                      l_bl_rbf_flag_tbl :=  SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
                      l_bl_rbf_flag_tbl.EXTEND(l_bl_RESOURCE_ASIGNMENT_ID_tbl.COUNT);
                      --dbms_output.put_line('I42');
                      FOR KK IN l_bl_RESOURCE_ASIGNMENT_ID_tbl.FIRST..l_bl_RESOURCE_ASIGNMENT_ID_tbl.LAST LOOP

                        FOR jj IN l_targ_ra_id_tbl.FIRST..l_targ_ra_id_tbl.LAST LOOP

                            IF l_bl_RESOURCE_ASIGNMENT_ID_tbl(kk)=l_targ_ra_id_tbl(jj) THEN

                              l_bl_rbf_flag_tbl(kk):=l_targ_rate_based_flag_tbl(jj);

                              EXIT;

                            END IF;

                        END LOOP;

                      END LOOP;

                      --Round the amounts prepared in the pl/sql tbls in case of partial implementation

                      IF l_partial_factor <> 1 THEN

                          IF l_debug_mode = 'Y' THEN
                               pa_debug.g_err_stage:='Fetching the agreement details';
                               pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
                          END IF;
                          -- Select agreement currency code
                          SELECT agr.agreement_id,
                                 agr.agreement_currency_code
                          INTO   l_agreement_id,
                                 l_agreement_currency_code
                          FROM   pa_budget_versions cibv,
                                 pa_agreements_all  agr
                          WHERE  cibv.budget_version_id = l_src_ver_id_tbl(j)
                          AND    cibv.agreement_id = agr.agreement_id;

                          IF l_debug_mode = 'Y' THEN
                               pa_debug.g_err_stage:='Calling pa_fp_multi_currency_pkg.round_amounts';
                               pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
                          END IF;

                          pa_fp_multi_currency_pkg.round_amounts
                            ( px_quantity_tbl               => l_bl_QUANTITY_tbl
                             ,p_agr_currency_code           => l_agreement_currency_code
                             ,px_txn_raw_cost_tbl           => l_bl_TXN_RAW_COST_tbl
                             ,px_txn_burdened_cost_tbl      => l_bl_TXN_BURDENED_COST_tbl
                             ,px_txn_revenue_tbl            => l_bl_TXN_REVENUE_tbl
                             ,p_project_currency_code       => l_Project_Currency_Code
                             ,px_project_raw_cost_tbl       => l_bl_PROJECT_RAW_COST_tbl
                             ,px_project_burdened_cost_tbl  => l_bl_PROJECT_BURDENED_COST_tbl
                             ,px_project_revenue_tbl        => l_bl_PROJECT_REVENUE_tbl
                             ,p_projfunc_currency_code      => l_Projfunc_Currency_Code
                             ,px_projfunc_raw_cost_tbl      => l_bl_RAW_COST_tbl
                             ,px_projfunc_burdened_cost_tbl => l_bl_BURDENED_COST_tbl
                             ,px_projfunc_revenue_tbl       => l_bl_REVENUE_tbl
                             ,x_return_status               => x_return_status
                             ,x_msg_count                   => x_msg_count
                             ,x_msg_data                    => x_msg_data    );

                          IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN

                              IF P_PA_debug_mode = 'Y' THEN
                                   pa_debug.g_err_stage:= 'pa_fp_multi_currency_pkg.round_amounts returned error';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                              END IF;
                              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                          END IF;

                       END IF; --IF l_partial_factor <> 1

                      --dbms_output.put_line('I43');
                      FORALL kk in 1..l_upd_ra_bl_dml_code_tbl.count
                        INSERT INTO PA_BUDGET_LINES(RESOURCE_ASSIGNMENT_ID,
                                   START_DATE,
                                   LAST_UPDATE_DATE,
                                   LAST_UPDATED_BY,
                                   CREATION_DATE,
                                   CREATED_BY,
                                   LAST_UPDATE_LOGIN,
                                   END_DATE,
                                   PERIOD_NAME,
                                   QUANTITY,
                                   RAW_COST,
                                   BURDENED_COST,
                                   REVENUE,
                                   CHANGE_REASON_CODE,
                                   DESCRIPTION,
                                   ATTRIBUTE_CATEGORY,
                                   ATTRIBUTE1,
                                   ATTRIBUTE2,
                                   ATTRIBUTE3,
                                   ATTRIBUTE4,
                                   ATTRIBUTE5,
                                   ATTRIBUTE6,
                                   ATTRIBUTE7,
                                   ATTRIBUTE8,
                                   ATTRIBUTE9,
                                   ATTRIBUTE10,
                                   ATTRIBUTE11,
                                   ATTRIBUTE12,
                                   ATTRIBUTE13,
                                   ATTRIBUTE14,
                                   ATTRIBUTE15,
                                   RAW_COST_SOURCE,
                                   BURDENED_COST_SOURCE,
                                   QUANTITY_SOURCE,
                                   REVENUE_SOURCE,
                                   PM_PRODUCT_CODE,
                                   PM_BUDGET_LINE_REFERENCE,
                                   COST_REJECTION_CODE,
                                   REVENUE_REJECTION_CODE,
                                   BURDEN_REJECTION_CODE,
                                   OTHER_REJECTION_CODE,
                                   CODE_COMBINATION_ID,
                                   CCID_GEN_STATUS_CODE,
                                   CCID_GEN_REJ_MESSAGE,
                                   REQUEST_ID,
                                   BORROWED_REVENUE,
                                   TP_REVENUE_IN,
                                   TP_REVENUE_OUT,
                                   REVENUE_ADJ,
                                   LENT_RESOURCE_COST,
                                   TP_COST_IN,
                                   TP_COST_OUT,
                                   COST_ADJ,
                                   UNASSIGNED_TIME_COST,
                                   UTILIZATION_PERCENT,
                                   UTILIZATION_HOURS,
                                   UTILIZATION_ADJ,
                                   CAPACITY,
                                   HEAD_COUNT,
                                   HEAD_COUNT_ADJ,
                                   PROJFUNC_CURRENCY_CODE,
                                   PROJFUNC_COST_RATE_TYPE,
                                   PROJFUNC_COST_EXCHANGE_RATE,
                                   PROJFUNC_COST_RATE_DATE_TYPE,
                                   PROJFUNC_COST_RATE_DATE,
                                   PROJFUNC_REV_RATE_TYPE,
                                   PROJFUNC_REV_EXCHANGE_RATE,
                                   PROJFUNC_REV_RATE_DATE_TYPE,
                                   PROJFUNC_REV_RATE_DATE,
                                   PROJECT_CURRENCY_CODE,
                                   PROJECT_COST_RATE_TYPE,
                                   PROJECT_COST_EXCHANGE_RATE,
                                   PROJECT_COST_RATE_DATE_TYPE,
                                   PROJECT_COST_RATE_DATE,
                                   PROJECT_RAW_COST,
                                   PROJECT_BURDENED_COST,
                                   PROJECT_REV_RATE_TYPE,
                                   PROJECT_REV_EXCHANGE_RATE,
                                   PROJECT_REV_RATE_DATE_TYPE,
                                   PROJECT_REV_RATE_DATE,
                                   PROJECT_REVENUE,
                                   TXN_CURRENCY_CODE,
                                   TXN_RAW_COST,
                                   TXN_BURDENED_COST,
                                   TXN_REVENUE,
                                   BUCKETING_PERIOD_CODE,
                                   BUDGET_LINE_ID,
                                   BUDGET_VERSION_ID,
                                   TXN_STANDARD_COST_RATE,
                                   TXN_COST_RATE_OVERRIDE,
                                   COST_IND_COMPILED_SET_ID,
                              --     TXN_BURDEN_MULTIPLIER,
                              --     TXN_BURDEN_MULTIPLIER_OVERRIDE,
                                   TXN_STANDARD_BILL_RATE,
                                   TXN_BILL_RATE_OVERRIDE,
                                   TXN_MARKUP_PERCENT,
                                   TXN_MARKUP_PERCENT_OVERRIDE,
                                   TXN_DISCOUNT_PERCENTAGE,
                                   TRANSFER_PRICE_RATE,
                                   BURDEN_COST_RATE,
                                   BURDEN_COST_RATE_OVERRIDE,
                                   PC_CUR_CONV_REJECTION_CODE,
                                   PFC_CUR_CONV_REJECTION_CODE
                                   )
                             SELECT l_bl_RESOURCE_ASIGNMENT_ID_tbl(kk),
                                  l_bl_START_DATE_tbl(kk),
                                  sysdate,
                                  fnd_global.user_id,
                                  sysdate,
                                  fnd_global.user_id,
                                  fnd_global.login_id,
                                  l_bl_END_DATE_tbl(kk),
                                  l_bl_PERIOD_NAME_tbl(kk),
                                  Decode(l_bl_rbf_flag_tbl(kk),
                                         'N',Decode(l_target_version_type,
                                                    'REVENUE',l_bl_TXN_REVENUE_tbl(kk),
                                                              l_bl_TXN_RAW_COST_tbl(kk)),
                                          l_bl_QUANTITY_tbl(kk)),
                                  l_bl_RAW_COST_tbl(kk),
                                  l_bl_BURDENED_COST_tbl(kk),
                                  l_bl_REVENUE_tbl(kk),
                                  l_bl_CHANGE_REASON_CODE_tbl(kk),
                                  l_bl_DESCRIPTION_tbl(kk),
                                  l_bl_ATTRIBUTE_CATEGORY_tbl(kk),
                                  l_bl_ATTRIBUTE1_tbl(kk),
                                  l_bl_ATTRIBUTE2_tbl(kk),
                                  l_bl_ATTRIBUTE3_tbl(kk),
                                  l_bl_ATTRIBUTE4_tbl(kk),
                                  l_bl_ATTRIBUTE5_tbl(kk),
                                  l_bl_ATTRIBUTE6_tbl(kk),
                                  l_bl_ATTRIBUTE7_tbl(kk),
                                  l_bl_ATTRIBUTE8_tbl(kk),
                                  l_bl_ATTRIBUTE9_tbl(kk),
                                  l_bl_ATTRIBUTE10_tbl(kk),
                                  l_bl_ATTRIBUTE11_tbl(kk),
                                  l_bl_ATTRIBUTE12_tbl(kk),
                                  l_bl_ATTRIBUTE13_tbl(kk),
                                  l_bl_ATTRIBUTE14_tbl(kk),
                                  l_bl_ATTRIBUTE15_tbl(kk),
                                  'I',
                                  'I',
                                  'I',
                                  'I',
                                  l_bl_PM_PRODUCT_CODE_tbl(kk),
                                  l_bl_PM_BUDGET_LINE_REF_tbl(kk),
                                  l_bl_COST_REJECTION_CODE_tbl(kk),
                                  l_bl_REVENUE_REJ_CODE_tbl(kk),
                                  l_bl_BURDEN_REJECTION_CODE_tbl(kk),
                                  l_bl_OTHER_REJECTION_CODE_tbl(kk),
                                  l_bl_CODE_COMBINATION_ID_tbl(kk),
                                  l_bl_CCID_GEN_STATUS_CODE_tbl(kk),
                                  l_bl_CCID_GEN_REJ_MESSAGE_tbl(kk),
                                  l_bl_REQUEST_ID_tbl(kk),
                                  l_bl_BORROWED_REVENUE_tbl(kk),
                                  l_bl_TP_REVENUE_IN_tbl(kk),
                                  l_bl_TP_REVENUE_OUT_tbl(kk),
                                  l_bl_REVENUE_ADJ_tbl(kk),
                                  l_bl_LENT_RESOURCE_COST_tbl(kk),
                                  l_bl_TP_COST_IN_tbl(kk),
                                  l_bl_TP_COST_OUT_tbl(kk),
                                  l_bl_COST_ADJ_tbl(kk),
                                  l_bl_UNASSIGNED_TIME_COST_tbl(kk),
                                  l_bl_UTILIZATION_PERCENT_tbl(kk),
                                  l_bl_UTILIZATION_HOURS_tbl(kk),
                                  l_bl_UTILIZATION_ADJ_tbl(kk),
                                  l_bl_CAPACITY_tbl(kk),
                                  l_bl_HEAD_COUNT_tbl(kk),
                                  l_bl_HEAD_COUNT_ADJ_tbl(kk),
                                  l_bl_PROJFUNC_CUR_CODE_tbl(kk),
                                  l_bl_PROJFUNC_COST_RAT_TYP_tbl(kk),
                                  DECODE(l_bl_PROJFUNC_COST_RAT_TYP_tbl(kk),'User', DECODE(l_targ_multi_curr_flag,'Y', Decode(decode(l_report_cost_using, 'R',nvl(l_bl_TXN_RAW_COST_tbl(kk),0),
                                          'B', nvl(l_bl_TXN_BURDENED_COST_tbl(kk),0)),0,0,(decode(l_report_cost_using,'R',nvl(l_bl_RAW_COST_tbl(kk),0),
                                          'B',nvl(l_bl_BURDENED_COST_tbl(kk),0)) / (decode(l_report_cost_using,'R',nvl(l_bl_TXN_RAW_COST_tbl(kk),0),
                                          'B', nvl(l_bl_TXN_BURDENED_COST_tbl(kk),0))))),Null),Null), -- Bug 3839273
                                  l_bl_PJFN_COST_RAT_DAT_TYP_tbl(kk),
                                  l_bl_PROJFUNC_COST_RAT_DAT_tbl(kk),
                                  l_bl_PROJFUNC_REV_RATE_TYP_tbl(kk),
                                  Decode(l_bl_PROJFUNC_REV_RATE_TYP_tbl(kk),'User',DECODE(l_targ_multi_curr_flag,'Y', Decode(nvl(l_bl_TXN_REVENUE_tbl(kk),0),0,0,nvl(l_bl_REVENUE_tbl(kk),0) /
                                         nvl(l_bl_TXN_REVENUE_tbl(kk),0)),Null),Null), -- Bug 3839273
                                  l_bl_PJFN_REV_RAT_DAT_TYPE_tbl(kk),
                                  l_bl_PROJFUNC_REV_RAT_DATE_tbl(kk),
                                  l_project_currency_code,
                                  l_bl_PROJECT_COST_RAT_TYPE_tbl(kk),
                                  DECODE(l_bl_PROJECT_COST_RAT_TYPE_tbl(kk),'User', DECODE(l_targ_multi_curr_flag,'Y', Decode(decode(l_report_cost_using, 'R',nvl(l_bl_TXN_RAW_COST_tbl(kk),0),
                                        'B', nvl(l_bl_TXN_BURDENED_COST_tbl(kk),0)),0,0,(decode(l_report_cost_using,'R',nvl(l_bl_PROJECT_RAW_COST_tbl(kk),0),
                                        'B',nvl(l_bl_PROJECT_BURDENED_COST_tbl(kk),0)) / (decode(l_report_cost_using,'R',nvl(l_bl_TXN_RAW_COST_tbl(kk),0),
                                        'B',nvl(l_bl_TXN_BURDENED_COST_tbl(kk),0))))),Null),Null), -- Bug 3839273
                                  l_bl_PROJ_COST_RAT_DAT_TYP_tbl(kk),
                                  l_bl_PROJ_COST_RATE_DATE_tbl(kk),
                                  l_bl_PROJECT_RAW_COST_tbl(kk),
                                  l_bl_PROJECT_BURDENED_COST_tbl(kk),
                                  l_bl_PROJECT_REV_RATE_TYPE_tbl(kk),
                                  Decode(l_bl_PROJECT_REV_RATE_TYPE_tbl(kk),'User',DECODE(l_targ_multi_curr_flag,'Y', Decode(nvl(l_bl_TXN_REVENUE_tbl(kk),0),0,0,nvl(l_bl_PROJECT_REVENUE_tbl(kk),0) /
                                         nvl(l_bl_TXN_REVENUE_tbl(kk),0)),Null),Null), -- Bug 3839273
                                  l_bl_PRJ_REV_RAT_DATE_TYPE_tbl(kk),
                                  l_bl_PROJECT_REV_RATE_DATE(kk),
                                  l_bl_PROJECT_REVENUE_tbl(kk),
                                  l_bl_TXN_CURRENCY_CODE_tbl(kk),
                                  l_bl_TXN_RAW_COST_tbl(kk),
                                  l_bl_TXN_BURDENED_COST_tbl(kk),
                                  l_bl_TXN_REVENUE_tbl(kk),
                                  l_bl_BUCKETING_PERIOD_CODE_tbl(kk),
                                  pa_budget_lines_s.nextval,
                                  p_budget_version_id,
                                  l_bl_TXN_STD_COST_RATE_tbl(kk),
                                  DECODE(l_target_version_type,
                                       'REVENUE',l_bl_TXN_COST_RATE_OVERIDE_tbl(kk),
                                        DECODE(l_bl_rbf_flag_tbl(kk),
                                               'N',1,
                                               l_bl_TXN_COST_RATE_OVERIDE_tbl(kk))),
                                  l_bl_COST_IND_CMPLD_SET_ID_tbl(kk),
                              --      l_bl_TXN_BURDEN_MULTIPLIER_tbl(kk),
                              --      l_bl_TXN_BRD_MLTIPLI_OVRID_tbl(kk),
                                  l_bl_TXN_STD_BILL_RATE_tbl(kk),
                                  DECODE(l_target_version_type,
                                         'REVENUE',DECODE(l_bl_rbf_flag_tbl(kk),
                                                          'N',1,
                                                           l_bl_TXN_BILL_RATE_OVERRID_tbl(kk)),
                                         l_bl_TXN_BILL_RATE_OVERRID_tbl(kk)),
                                  l_bl_TXN_MARKUP_PERCENT_tbl(kk),
                                  l_bl_TXN_MRKUP_PER_OVERIDE_tbl(kk),
                                  l_bl_TXN_DISC_PERCENTAGE_tbl(kk),
                                  l_bl_TRANSFER_PRICE_RATE_tbl(kk),
                                  l_bl_BURDEN_COST_RATE_tbl(kk),
                                  DECODE(l_target_version_type,
                                       'REVENUE',l_bl_BURDEN_COST_RAT_OVRID_tbl(kk),
                                        DECODE(l_bl_rbf_flag_tbl(kk),
                                             'Y',l_bl_BURDEN_COST_RAT_OVRID_tbl(kk),
                                             DECODE(nvl(l_bl_TXN_RAW_COST_tbl(kk),0),
                                                    0,null,
                                                    l_bl_TXN_BURDENED_COST_tbl(kk)/l_bl_TXN_RAW_COST_tbl(kk)))),
                                  l_bl_PC_CUR_CONV_REJ_CODE_tbl(kk),
                                  l_bl_PFC_CUR_CONV_REJ_CODE_tbl(kk)
                             from   dual
                             where  l_upd_ra_bl_dml_code_tbl(kk)='INSERT';

                   --dbms_output.put_line('I43');

                   --Fix for bug 3734888. Null handled the pl/sql tbls while updating.
                   FORALL kk in 1..l_upd_ra_bl_dml_code_tbl.count
                      UPDATE PA_BUDGET_LINES
                      SET    LAST_UPDATE_DATE=sysdate,
                           LAST_UPDATED_BY=fnd_global.user_id,
                           LAST_UPDATE_LOGIN=fnd_global.login_id,
                           QUANTITY= DECODE(l_bl_rbf_flag_tbl(kk),
                                            'N',DECODE(l_target_version_type,
                                                       'REVENUE',nvl(TXN_REVENUE,0)+ nvl(l_bl_TXN_REVENUE_tbl(kk),0)
                                                                ,nvl(TXN_RAW_COST,0) + nvl(l_bl_TXN_RAW_COST_tbl(kk),0)),
                                            nvl(QUANTITY,0)+ nvl(l_bl_QUANTITY_tbl(kk),0)),
                           RAW_COST= nvl(RAW_COST,0) + nvl(l_bl_RAW_COST_tbl(kk),0),
                           BURDENED_COST= nvl(BURDENED_COST,0) + nvl(l_bl_BURDENED_COST_tbl(kk),0),
                           REVENUE= nvl(REVENUE,0) + nvl(l_bl_REVENUE_tbl(kk),0),
                           PROJFUNC_COST_RATE_TYPE= nvl(l_bl_PROJFUNC_COST_RAT_TYP_tbl(kk),PROJFUNC_COST_RATE_TYPE),
                           PROJFUNC_COST_EXCHANGE_RATE= DECODE(nvl(l_bl_PROJFUNC_COST_RAT_TYP_tbl(kk),PROJFUNC_COST_RATE_TYPE),'User', Decode(decode(l_report_cost_using, 'R',nvl(nvl(TXN_RAW_COST,0) + nvl(l_bl_TXN_RAW_COST_tbl(kk),0),0),
                                                       'B',nvl(nvl(TXN_BURDENED_COST,0) + nvl(l_bl_TXN_BURDENED_COST_tbl(kk),0),0) ),0,0,
                                                       (decode(l_report_cost_using,'R',nvl(nvl(RAW_COST,0) + nvl(l_bl_RAW_COST_tbl(kk),0),0),
                                                                           'B',nvl(nvl(BURDENED_COST,0) + nvl(l_bl_BURDENED_COST_tbl(kk),0),0)) / decode(l_report_cost_using,'R', nvl(TXN_RAW_COST,0) + nvl(l_bl_TXN_RAW_COST_tbl(kk),0),
                                                                                                    'B', nvl(TXN_BURDENED_COST,0) + nvl(l_bl_TXN_BURDENED_COST_tbl(kk),0)))),PROJFUNC_COST_EXCHANGE_RATE),
                           PROJFUNC_REV_RATE_TYPE= nvl(l_bl_PROJFUNC_REV_RATE_TYP_tbl(kk),PROJFUNC_REV_RATE_TYPE),
                           PROJFUNC_REV_EXCHANGE_RATE= DECODE(nvl(l_bl_PROJFUNC_REV_RATE_TYP_tbl(kk),PROJFUNC_REV_RATE_TYPE),'User',
                                                      Decode(nvl(nvl(TXN_REVENUE,0) + nvl(l_bl_TXN_REVENUE_tbl(kk),0),0),0,0,
                                                (nvl(nvl(REVENUE,0) + nvl(l_bl_REVENUE_tbl(kk),0),0) /(nvl(TXN_REVENUE,0) + nvl(l_bl_TXN_REVENUE_tbl(kk),0)))),PROJFUNC_REV_EXCHANGE_RATE),
                           PROJECT_COST_RATE_TYPE= nvl(l_bl_PROJECT_COST_RAT_TYPE_tbl(kk),PROJECT_COST_RATE_TYPE),
                           PROJECT_COST_EXCHANGE_RATE= DECODE(nvl(l_bl_PROJECT_COST_RAT_TYPE_tbl(kk),PROJECT_COST_RATE_TYPE),'User', Decode(decode(l_report_cost_using, 'R',nvl(nvl(TXN_RAW_COST,0) + nvl(l_bl_TXN_RAW_COST_tbl(kk),0),0),
                                                       'B',nvl(nvl(TXN_BURDENED_COST,0) + nvl(l_bl_TXN_BURDENED_COST_tbl(kk),0),0) ),0,0,
                                                       (decode(l_report_cost_using,'R',nvl(nvl(PROJECT_RAW_COST,0) + nvl(l_bl_PROJECT_RAW_COST_tbl(kk),0),0),
                                                                           'B',nvl(nvl(PROJECT_BURDENED_COST,0) + nvl(l_bl_PROJECT_BURDENED_COST_tbl(kk),0),0)) / decode(l_report_cost_using,
                                                                                                    'R', nvl(TXN_RAW_COST,0) + nvl(l_bl_TXN_RAW_COST_tbl(kk),0),
                                                                                                    'B', nvl(TXN_BURDENED_COST,0) + nvl(l_bl_TXN_BURDENED_COST_tbl(kk),0)))),PROJECT_COST_EXCHANGE_RATE),
                           PROJECT_RAW_COST = nvl(PROJECT_RAW_COST,0) + nvl(l_bl_PROJECT_RAW_COST_tbl(kk),0),
                           PROJECT_BURDENED_COST = nvl(PROJECT_BURDENED_COST,0) + nvl(l_bl_PROJECT_BURDENED_COST_tbl(kk),0),
                           PROJECT_REV_RATE_TYPE = nvl(l_bl_PROJECT_REV_RATE_TYPE_tbl(kk),PROJECT_REV_RATE_TYPE),
                           PROJECT_REV_EXCHANGE_RATE =  DECODE(nvl(l_bl_PROJECT_REV_RATE_TYPE_tbl(kk),PROJECT_REV_RATE_TYPE),'User',
                                                      Decode(nvl(nvl(TXN_REVENUE,0) + nvl(l_bl_TXN_REVENUE_tbl(kk),0),0),0,0,
                                                      (nvl(nvl(PROJECT_REVENUE,0) + nvl(l_bl_PROJECT_REVENUE_tbl(kk),0),0) /(nvl(TXN_REVENUE,0) + nvl(l_bl_TXN_REVENUE_tbl(kk),0)))),PROJECT_REV_EXCHANGE_RATE),
                           PROJECT_REVENUE =  nvl(PROJECT_REVENUE,0) + nvl(l_bl_PROJECT_REVENUE_tbl(kk),0),
                           TXN_RAW_COST =  nvl(TXN_RAW_COST,0) + nvl(l_bl_TXN_RAW_COST_tbl(kk),0),
                           TXN_BURDENED_COST= nvl(TXN_BURDENED_COST,0) + nvl(l_bl_TXN_BURDENED_COST_tbl(kk),0),
                           TXN_REVENUE =  nvl(TXN_REVENUE,0) + nvl(l_bl_TXN_REVENUE_tbl(kk),0),
                           TXN_COST_RATE_OVERRIDE = DECODE(l_target_Version_type,
                                                   'REVENUE', TXN_COST_RATE_OVERRIDE,
                                                   DECODE(l_bl_rbf_flag_tbl(kk),
                                                         'N',1,
                                                         decode((nvl(QUANTITY,0) + nvl(l_bl_QUANTITY_tbl(kk),0)),0,0,((nvl(TXN_RAW_COST,0) + nvl(l_bl_TXN_RAW_COST_tbl(kk),0))/
                                                              (nvl(QUANTITY,0) + nvl(l_bl_QUANTITY_tbl(kk),0)))))),
                           BURDEN_COST_RATE_OVERRIDE = DECODE( l_target_Version_type,
                                                       'REVENUE',BURDEN_COST_RATE_OVERRIDE,
                                                       DECODE(l_bl_rbf_flag_tbl(kk),
                                                            'N',decode((nvl(TXN_RAW_COST,0) + nvl(l_bl_TXN_RAW_COST_tbl(kk),0)),0,0,((nvl(TXN_BURDENED_COST,0) + nvl(l_bl_TXN_BURDENED_COST_tbl(kk),0))/
                                                                   (nvl(TXN_RAW_COST,0) + nvl(l_bl_TXN_RAW_COST_tbl(kk),0)))),
                                                             decode((nvl(QUANTITY,0) + nvl(l_bl_QUANTITY_tbl(kk),0)),0,0,((nvl(TXN_BURDENED_COST,0) + nvl(l_bl_TXN_BURDENED_COST_tbl(kk),0))/
                                                            (nvl(QUANTITY,0) + nvl(l_bl_QUANTITY_tbl(kk),0)))))),
                           TXN_BILL_RATE_OVERRIDE =  DECODE(l_bl_rbf_flag_tbl(kk),
                                                            'N',DECODE(l_target_version_type,
                                                                       'REVENUE',1,
                                                                        decode((nvl(TXN_RAW_COST,0) + nvl(l_bl_TXN_RAW_COST_tbl(kk),0)),0,0,((nvl(TXN_REVENUE,0) + nvl(l_bl_TXN_REVENUE_tbl(kk),0))/
                                                                                   (nvl(TXN_RAW_COST,0) + nvl(l_bl_TXN_RAW_COST_tbl(kk),0))))),
                                                            decode((nvl(QUANTITY,0) + nvl(l_bl_QUANTITY_tbl(kk),0)),0,0,((nvl(TXN_REVENUE,0) + nvl(l_bl_TXN_REVENUE_tbl(kk),0))/
                                                                   (nvl(QUANTITY,0) + nvl(l_bl_QUANTITY_tbl(kk),0)))))
                       WHERE l_upd_ra_bl_dml_code_tbl(kk) = 'UPDATE'
                       AND   resource_assignment_id       = l_bl_RESOURCE_ASIGNMENT_ID_tbl(kk)
                       AND   start_date                   = l_bl_START_DATE_tbl(kk)
                       AND   txn_currency_code            = l_bl_TXN_CURRENCY_CODE_tbl(kk)
                       RETURNING
                       period_name,
                       txn_currency_code,
                       start_date,
                       end_date,
                       cost_rejection_code,
                       revenue_rejection_code,
                       burden_rejection_code,
                       other_rejection_code,
                       pc_cur_conv_rejection_code,
                       pfc_cur_conv_rejection_code,
                       budget_line_id
                       BULK COLLECT INTO
                       l_upd_period_name_tbl,
                       l_upd_currency_code_tbl,
                       l_upd_bl_start_date_tbl,
                       l_upd_bl_end_date_tbl,
                       l_upd_cost_rejection_code,
                       l_upd_revenue_rejection_code,
                       l_upd_burden_rejection_code,
                       l_upd_other_rejection_code,
                       l_upd_pc_cur_conv_rej_code,
                       l_upd_pfc_cur_conv_rej_code,
                       l_upd_bl_id_tbl;


                   --dbms_output.put_line('I44');

                END IF;--   IF l_upd_ra_bl_dml_code_tbl.COUNT>0 THEN

                -- Bug 4035856 Call rounding api if partial implementation has happened
                IF  l_partial_factor <> 1 THEN
                    -- Call rounding api
                    PA_FP_MULTI_CURRENCY_PKG.Round_Budget_Line_Amounts
                           (  p_budget_version_id     => p_budget_version_id
                             ,p_calling_context       => 'CHANGE_ORDER_MERGE'
                             ,p_bls_inserted_after_id => l_id_before_bl_insertion
                             ,x_return_status         => l_return_status
                             ,x_msg_count             => l_msg_count
                             ,x_msg_data              => l_msg_data);

                     IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                         IF P_PA_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Error in PA_FP_MULTI_CURRENCY_PKG.Round_Budget_Line_Amounts';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                         END IF;
                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                     END IF;
                     IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:='Start of residual amount logic';
                         pa_debug.write('Round_Budget_Line_Amounts: ' || l_module_name,pa_debug.g_err_stage,3);
                     END IF;

                     Begin

                         -- Compute the total revenue sum of target budget version in PC,PFC (TXN=PFC)
                         SELECT nvl(sum(nvl(revenue,0)),0), nvl(sum(nvl(project_revenue,0)),0)
                         INTO   l_targ_pfc_rev_after_merge, l_targ_pc_rev_after_merge
                         FROM   pa_budget_lines
                         WHERE  budget_version_id = p_budget_version_id;

                         -- Initialise residual amount variables to zero
                         l_pc_revenue_delta := 0;
                         l_pfc_revenue_delta := 0;

                         -- Compute the total implemented amount using already implemented amount and currently
                         -- implemented amount
                         l_pc_rev_merged := l_impl_proj_revenue -- already impl amt from pa_fp_merged_ctrl_items
                                            +  (l_targ_pc_rev_after_merge - l_targ_pc_rev_before_merge);
                         l_pfc_rev_merged := l_impl_proj_func_revenue -- already impl amt from pa_fp_merged_ctrl_items
                                            +  (l_targ_pfc_rev_after_merge - l_targ_pfc_rev_before_merge);

                         -- If all the remaining agreement amount is being implemented, make sure that
                         -- implemeted PC, PFC amounts in pa_fp_merged_ctrl_items tally with ci version totals
                         IF (nvl(l_impl_amt,0) + nvl(l_partial_impl_rev_amt,0) = nvl(l_total_amt,0)) THEN

                            l_pfc_revenue_delta := l_total_amt_in_pfc - l_pfc_rev_merged;
                            l_pc_revenue_delta := l_total_amt_in_pc - l_pc_rev_merged;

                         ELSE

                            --Find out the PC, PFC amount that should have got merged. This will be calculated as follows:
                            --In the CI version, let us say, TotTxnRev is the total revenue in txn currency, TotPfcRev is the
                            --total revenue in PFC, ParTxnRev is the amount that the user has entered for implementation and
                            --ParPfcRev is the amount in PFC corresponding to ParTxnRev. If TotPfcRev corresponds to TotTxnRev
                            --in PFC then ParPfcRev is nothging but ((ParTxnRev + ImplTxnRev) *TotPfcRev)/TotTxnRev. Here ImplTxnRev is
                            --the revenue amount in txn currency that has already been implemented
                            --Similary Partial amount in Project currency can also be calculated.
                            IF l_total_amt_in_pfc = 0 THEN

                                l_pfc_rev_for_merge := 0;

                            ELSE

                                --(l_partial_impl_rev_amt + nvl(l_impl_amt,0) would constitute the total amount in
                                --txn currency of the source version that has got implemented.
                                l_pfc_rev_for_merge := ( (l_partial_impl_rev_amt + nvl(l_impl_amt,0)) * l_total_amt_in_pfc )/l_total_amt;
                                l_pfc_rev_for_merge :=
                                   Pa_currency.round_trans_currency_amt1(l_pfc_rev_for_merge,
                                                                         l_projfunc_currency_code);

                            END IF;

                            IF l_total_amt_in_pc = 0 THEN

                                l_pc_rev_for_merge := 0;

                            ELSE

                                l_pc_rev_for_merge := ((l_partial_impl_rev_amt + nvl(l_impl_amt,0)) * l_total_amt_in_pc )/l_total_amt;
                                l_pc_rev_for_merge :=
                                   Pa_currency.round_trans_currency_amt1(l_pc_rev_for_merge,
                                                                         l_project_currency_code);

                            END IF;

                            l_pfc_revenue_delta := l_pfc_rev_for_merge - l_pfc_rev_merged;
                            l_pc_revenue_delta := l_pc_rev_for_merge - l_pc_rev_merged;

                         END IF;
                         IF l_debug_mode = 'Y' THEN
                             pa_debug.g_err_stage:='l_pfc_revenue_delta = '||l_pfc_revenue_delta
                                                   || 'l_pc_revenue_delta = ' || l_pc_revenue_delta;
                             pa_debug.write('Round_Budget_Line_Amounts: ' || l_module_name,pa_debug.g_err_stage,3);
                         END IF;

                         IF (l_pfc_revenue_delta <> 0 OR l_pc_revenue_delta <> 0) THEN

                             -- Find source resource assignment id, budget line start_date into which
                             -- the residual amount should be added
                             IF l_src_resource_list_id = l_targ_resource_list_id THEN

                                 OPEN   src_delta_amt_adj_ra_cur(l_src_ver_id_tbl(j));
                                 FETCH  src_delta_amt_adj_ra_cur INTO
                                         l_src_delta_amt_adj_task_id,
                                         l_targ_delta_amt_adj_rlm_id,
                                         l_src_delta_amt_adj_ra_id,
                                         l_src_dummy1,
                                         l_src_dummy2;
                                 CLOSE  src_delta_amt_adj_ra_cur;

                             ELSE

                                 OPEN   src_delta_amt_adj_ra_cur1(l_src_ver_id_tbl(j));
                                 FETCH  src_delta_amt_adj_ra_cur1 INTO
                                         l_src_delta_amt_adj_task_id,
                                         l_targ_delta_amt_adj_rlm_id,
                                         l_src_delta_amt_adj_ra_id,
                                         l_src_dummy1,
                                         l_src_dummy2;
                                 CLOSE  src_delta_amt_adj_ra_cur1;

                             END IF;

                             OPEN  src_delta_amt_adj_date_cur(l_src_delta_amt_adj_ra_id);
                             FETCH src_delta_amt_adj_date_cur
                             INTO  l_src_delta_amt_adj_start_date;
                             CLOSE src_delta_amt_adj_date_cur;

                             IF l_debug_mode = 'Y' THEN
                                 pa_debug.g_err_stage:= 'target ra id = '||get_mapped_ra_id(get_task_id(l_targ_plan_level_code,
                                                                 l_src_delta_amt_adj_task_id), l_targ_delta_amt_adj_rlm_id);
                                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                                 pa_debug.g_err_stage:= 'l_src_delta_amt_adj_start_date = '||l_src_delta_amt_adj_start_date;
                                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                                 pa_debug.g_err_stage:= 'l_targ_plan_level_code = '||l_targ_plan_level_code
                                          || 'l_src_delta_amt_adj_task_id = '||l_src_delta_amt_adj_task_id ;
                                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                             END IF;

                             -- Using the source res assigment and target assignment mapping update
                             -- the target version budget line. Note for AR Versions there can be amounts
                             -- against txn currency only
                             UPDATE pa_budget_lines
                             SET    revenue = nvl(revenue,0) + nvl(l_pfc_revenue_delta,0),
                                    txn_revenue = nvl(revenue,0) + nvl(l_pfc_revenue_delta,0), -- TXN and PFC should be same for AR versions
                                    project_revenue = nvl(project_revenue,0) + nvl(l_pc_revenue_delta,0)
                             WHERE  resource_assignment_id =
                                      get_mapped_ra_id(get_task_id(l_targ_plan_level_code,l_src_delta_amt_adj_task_id),
                                                       l_targ_delta_amt_adj_rlm_id)
                             AND    l_src_delta_amt_adj_start_date  BETWEEN start_date AND end_date
                             AND    budget_version_id = p_budget_version_id
                             AND    rownum < 2 -- not really necessary
                             RETURNING
                             budget_line_id
                             INTO
                             l_rounded_bl_id;

                             IF SQL%ROWCOUNT = 0 THEN
                                 -- If no row is updated, target must be None time phased version.
                                 -- So there would be only one line
                                 UPDATE pa_budget_lines
                                 SET    revenue = nvl(revenue,0) + nvl(l_pfc_revenue_delta,0),
                                        txn_revenue = nvl(revenue,0) + nvl(l_pfc_revenue_delta,0), -- TXN and PFC should be same for AR versions
                                        project_revenue = nvl(project_revenue,0) + nvl(l_pc_revenue_delta,0)
                                 WHERE  resource_assignment_id =
                                          get_mapped_ra_id(get_task_id(l_targ_plan_level_code,l_src_delta_amt_adj_task_id),
                                                           l_targ_delta_amt_adj_rlm_id)
                                 AND    budget_version_id = p_budget_version_id
                                 AND    rownum < 2
                                 RETURNING
                                 budget_line_id
                                 INTO
                                 l_rounded_bl_id;

                             END IF;

                             --For non rate-based transaction, quantity should always be same as revenue. In the above update
                             --revenue is modified. If the revenue is adjusted for non rate-based transaction then the change
                             --should be made in quantity also. If the budget line is among those that are updated then in the
                             --below FOR Loop will that budget line would also get updated. If the budget line is among those
                             --budget lines that are inserted then it will be changed after the FOR loop. This variable
                             --l_qty_adjusted_flag will be used to track this
                             l_qty_adjusted_flag:='N';

                             --Since the amount is changed for a budget line in above update, the change has to be
                             --propogated to the corresponding entry of pl/sql tbls prepared above
                             FOR kk IN 1..l_upd_bl_id_tbl.COUNT LOOP

                                 IF l_upd_bl_id_tbl(kk)=l_rounded_bl_id THEN

                                     l_bl_REVENUE_tbl(kk) := nvl(l_bl_REVENUE_tbl(kk),0) + nvl(l_pfc_revenue_delta,0);
                                     l_bl_PROJECT_REVENUE_tbl(kk) := nvl(l_bl_PROJECT_REVENUE_tbl(kk),0) + nvl(l_pc_revenue_delta,0);
                                     l_bl_TXN_REVENUE_tbl(kk) := nvl(l_bl_TXN_REVENUE_tbl(kk),0) + nvl(l_pfc_revenue_delta,0); -- TXN and PFC should be same for AR versions
                                     --For non rate based transactions quantity should be same as revenue
                                     IF l_bl_rbf_flag_tbl(kk) = 'N' THEN

                                         l_bl_QUANTITY_tbl(kk) := nvl(l_bl_TXN_REVENUE_tbl(kk),0) + nvl(l_pfc_revenue_delta,0);

                                         UPDATE pa_budget_lines
                                         SET    quantity=txn_revenue
                                         WHERE  budget_line_id=l_rounded_bl_id;

                                         l_qty_adjusted_flag:='Y';

                                     END IF;

                                     EXIT;

                                 END IF;

                             END LOOP;

                             IF l_qty_adjusted_flag = 'N' THEN

                                SELECT pra.rate_based_flag
                                INTO   l_rounded_bl_rbf
                                FROM   pa_resource_assignments pra,
                                       pa_budget_lines pbl
                                WHERE  pra.resource_assignment_id = pbl.resource_assignment_id
                                AND    pbl.budget_line_id = l_rounded_bl_id;

                                IF l_rounded_bl_rbf ='N' THEN

                                    UPDATE pa_budget_lines
                                    SET    quantity=txn_revenue
                                    WHERE  budget_line_id=l_rounded_bl_id;

                                END IF;

                             END IF;


                         END IF;
                     Exception
                         WHEN OTHERS THEN
                             IF P_PA_DEBUG_MODE = 'Y' THEN
                              pa_debug.g_err_stage:='Error in residual amount adjust logic'||SQLERRM;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                             END IF;
                             RAISE;
                     End;

                     IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:='End of residual amount logic';
                        pa_debug.write('Round_Budget_Line_Amounts: ' || l_module_name,pa_debug.g_err_stage,3);
                     END IF;

                END IF;

                --dbms_output.put_line('I45');
                -- Needs to execute only when calculate API has not been called
                IF NOT (l_src_time_phased_code = 'N' AND (l_targ_time_phased_code = 'P' OR l_targ_time_phased_code = 'G')) THEN

                     /* Bug 5726773:
 	                 Start of coding done for Support of negative quantity/amounts enhancement.
 	                 Call to the api CheckZeroQtyNegETC has been commented out below to allow
 	                 creation of -ve quantity/amounts in the target version due to the change order
 	                 merge. Commented out the delete and forall statements below which populate
 	                 pa_fp_spread_calc_tmp with the resource assignment ids and budget version ids
 	                 which will be used by the CheckZeroQtyNegETC api.
 	             */
		     --Check if the budget lines have -Ve ETC because of the change order merge. This need not
                     --not be done when calculate API is called since calculate API internally calls this API
                     --Bug 4395494
		     /*
                     DELETE FROM pa_fp_spread_calc_tmp;

                     FORALL kk IN 1..l_targ_ra_id_tbl.COUNT
                        INSERT INTO pa_fp_spread_calc_tmp
                        (budget_version_id,
                         resource_assignment_id)
                        VALUES
                        (p_budget_version_id,
                         l_targ_ra_id_tbl(kk));

                     PA_FP_CALC_PLAN_PKG.CheckZeroQTyNegETC
                     (p_budget_version_id     => p_budget_version_id
                     ,p_initialize            => 'Y'
                     ,x_return_status         => l_return_status
                     ,x_msg_count             => l_msg_count
                     ,x_msg_data              => l_msg_data);

                     IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                         IF P_PA_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Error CALLING PAFPCALB.CheckZeroQTyNegETC';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                         END IF;
                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                     END IF;
		     */
 	             /* Bug 5726773: End of coding done for Support of negative quantity/amounts enhancement. */

                     ----Prepare the pl/sql tbls to call the API in planning transaction utils that calls PJI API
                     ----plan_update

                     SELECT pa_budget_lines_s.currval
                     INTO   l_dummy
                     FROM   dual;

                     IF l_dummy=l_id_before_bl_insertion THEN

                        l_id_after_bl_insertion := l_id_before_bl_insertion;

                     ELSE

                         SELECT pa_budget_lines_s.nextval
                         INTO   l_id_after_bl_insertion
                         FROM   dual;

                     END IF;

                     IF  l_id_before_bl_insertion <> l_id_after_bl_insertion THEN

                         IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.g_err_stage:='Preparing input tbls for calculate API';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                         END IF;

                         SELECT pra.resource_assignment_id,
                              'N',
                              'Y',
                              pbl.txn_currency_code,
                              pbl.quantity,
                              pbl.txn_raw_cost,
                              pbl.txn_burdened_cost,
                              pbl.txn_revenue,
                              pbl.start_date,
                              pbl.end_date,
                              pbl.period_name,
                              pbl.project_raw_cost,
                              pbl.project_burdened_cost,
                              pbl.project_revenue,
                              pbl.raw_cost,
                              pbl.burdened_cost,
                              pbl.revenue,
                              pbl.cost_rejection_code,
                              pbl.revenue_rejection_code,
                              pbl.burden_rejection_code,
                              pbl.other_rejection_code,
                              pbl.pc_cur_conv_rejection_code,
                              pbl.pfc_cur_conv_rejection_code,
                              pra.task_id,
                              pra.rbs_element_id,
                              pra.resource_class_code,
                              pra.rate_based_flag
                        BULK COLLECT INTO
                              l_res_assignment_id_tbl,
                              l_delete_budget_lines_tbl,
                              l_spread_amount_flags_tbl,
                              l_currency_code_tbl,
                              l_total_quantity_tbl,
                              l_total_raw_cost_tbl,
                              l_total_burdened_cost_tbl,
                              l_total_revenue_tbl,
                              l_prm_bl_start_date_tbl,
                              l_prm_bl_end_date_tbl,
                              l_period_name_tbl,
                              l_pc_raw_cost_tbl,
                              l_pc_burd_cost_tbl,
                              l_pc_revenue_tbl,
                              l_pfc_raw_cost_tbl,
                              l_pfc_burd_cost_tbl,
                              l_pfc_revenue_tbl,
                              l_cost_rejection_code,
                              l_revenue_rejection_code,
                              l_burden_rejection_code,
                              l_other_rejection_code,
                              l_pc_cur_conv_rejection_code,
                              l_pfc_cur_conv_rejection_code,
                              l_pji_prm_task_id_tbl,
                              l_pji_prm_rbs_elem_id_tbl,
                              l_pji_prm_res_cls_code_tbl,
                              l_pji_prm_rbf_tbl
                        FROM    pa_resource_assignments pra,
                              pa_budget_lines pbl
                        WHERE   pra.resource_assignment_id = pbl.resource_assignment_id
                        AND     (pbl.budget_line_id BETWEEN l_id_before_bl_insertion AND l_id_after_bl_insertion)
                        AND     pra.budget_Version_id=p_budget_version_id;

                        IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.g_err_stage:='l_res_assignment_id_tbl.COUNT IS '||l_res_assignment_id_tbl.COUNT;
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                          pa_debug.g_err_stage:='l_rev_impl_flag  '||l_rev_impl_flag;
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                          pa_debug.g_err_stage:=' l_impl_qty_tbl('||j ||  ') is '|| l_impl_qty_tbl(j);
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                        END IF;

                    END IF;--IF  l_id_before_bl_insertion <> l_id_after_bl_insertion THEN

                    --Budget lines might have got updated in addition to getting inserted because of merge
                    --Those budget lines should also be considered while calling PJI API Plan_Update
                    --Note that l_bl_RESOURCE_ASIGNMENT_ID_tbl will contain BLs corresponding to BLs that got inserted
                    --as well as updated. Here we should consider only those BLs that have got updated. BLs that
                    --are inserted are considered in the earlier block

                    /* Bug 5335211: Removing the check for null rbs_version_id, to populate the variables always
                     * so that they contain proper values when calling the PJI rollup API, irrespective of whether
                     * a RBS is present in the target version or not.
                    IF l_rbs_version_id IS NOT NULL THEN */
                    IF l_bl_RESOURCE_ASIGNMENT_ID_tbl.COUNT > 0 THEN

                      IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.g_err_stage:='Preparing tbls for for the lines that got update';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                      END IF;


                      --This index will be used for l_updXXX tbls containinng data for the BLs that have got
                      --updated. As told above l_bl_RESOURCE_ASIGNMENT_ID_tbl contains data for BLs  that have
                      --inserted as well as updated. Here we need to cosider only those rows that have got updated
                      --Hence differenct index is required
                      l_index:=0;
                      FOR kk in l_bl_RESOURCE_ASIGNMENT_ID_tbl.FIRST..l_bl_RESOURCE_ASIGNMENT_ID_tbl.LAST LOOP

                          IF l_upd_ra_bl_dml_code_tbl(kk) = 'UPDATE' THEN

                            l_index:=l_index+1;

                            l_res_assignment_id_tbl.extend;
                            l_period_name_tbl.extend;
                            l_currency_code_tbl.extend;
                            l_total_quantity_tbl.extend;
                            l_total_raw_cost_tbl.extend;
                            l_total_burdened_cost_tbl.extend;
                            l_total_revenue_tbl.extend;
                            l_prm_bl_start_date_tbl.extend;
                            l_prm_bl_end_date_tbl.extend;
                            l_pc_raw_cost_tbl.extend;
                            l_pc_burd_cost_tbl.extend;
                            l_pc_revenue_tbl.extend;
                            l_pfc_raw_cost_tbl.extend;
                            l_pfc_burd_cost_tbl.extend;
                            l_pfc_revenue_tbl.extend;
                            l_cost_rejection_code.extend;
                            l_revenue_rejection_code.extend;
                            l_burden_rejection_code.extend;
                            l_other_rejection_code.extend;
                            l_pc_cur_conv_rejection_code.extend;
                            l_pfc_cur_conv_rejection_code.extend;

                            IF P_PA_DEBUG_MODE = 'Y' THEN
                                pa_debug.g_err_stage:='Done with tbl extending';
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                            END IF;


                            --Here l_res_assignment_id_tbl, l_delete_budget_lines_tbl are already populated above with the
                            --budget line details that have got inserted. Also all the will have the same length.
                            --Hence using l_res_assignment_id_tbl.count as index

                            IF P_PA_DEBUG_MODE = 'Y' THEN
                                pa_debug.g_err_stage:=' B l_res_assignment_id_tbl.count is '||l_res_assignment_id_tbl.count;
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                            END IF;

                            l_res_assignment_id_tbl(l_res_assignment_id_tbl.count)      := l_bl_RESOURCE_ASIGNMENT_ID_tbl(kk);

                            IF P_PA_DEBUG_MODE = 'Y' THEN

                                pa_debug.g_err_stage:=' A l_res_assignment_id_tbl.count is '||l_res_assignment_id_tbl.count;
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                                pa_debug.g_err_stage:='Done with l_res_assignment_id_tbl';
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                                pa_debug.g_err_stage:='l_period_name_tbl.count is '||l_period_name_tbl.count;
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                                pa_debug.g_err_stage:='l_upd_period_name_tbl('||kk||') is '||l_upd_period_name_tbl(l_index);
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);


                            END IF;

                            l_period_name_tbl(l_period_name_tbl.count)            :=l_upd_period_name_tbl(l_index);

                            IF P_PA_DEBUG_MODE = 'Y' THEN
                                pa_debug.g_err_stage:='Done with l_period_name_tbl';
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                            END IF;

                            l_currency_code_tbl(l_res_assignment_id_tbl.count)          := l_upd_currency_code_tbl(l_index);

                            IF P_PA_DEBUG_MODE = 'Y' THEN
                                pa_debug.g_err_stage:='Done with l_currency_code_tbl';
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                            END IF;

                            l_total_quantity_tbl(l_res_assignment_id_tbl.count)         := nvl(l_bl_QUANTITY_tbl(kk),0);
                            l_total_raw_cost_tbl(l_res_assignment_id_tbl.count)         := nvl(l_bl_TXN_RAW_COST_tbl(kk),0);
                            l_total_burdened_cost_tbl(l_res_assignment_id_tbl.count)    := nvl(l_bl_TXN_BURDENED_COST_tbl(kk),0);
                            l_total_revenue_tbl(l_res_assignment_id_tbl.count)          := nvl(l_bl_TXN_REVENUE_tbl(kk),0);
                            l_prm_bl_start_date_tbl(l_res_assignment_id_tbl.count)      := l_upd_bl_start_date_tbl(l_index);
                            l_prm_bl_end_date_tbl(l_res_assignment_id_tbl.count)        := l_upd_bl_end_date_tbl(l_index);
                            l_cost_rejection_code(l_res_assignment_id_tbl.count)        := l_upd_cost_rejection_code(l_index);
                            l_revenue_rejection_code(l_res_assignment_id_tbl.count)     := l_upd_revenue_rejection_code(l_index);
                            l_burden_rejection_code(l_res_assignment_id_tbl.count)      := l_upd_burden_rejection_code(l_index);
                            l_other_rejection_code(l_res_assignment_id_tbl.count)       := l_upd_other_rejection_code(l_index);
                            l_pc_cur_conv_rejection_code(l_res_assignment_id_tbl.count) := l_upd_pc_cur_conv_rej_code(l_index);
                            l_pfc_cur_conv_rejection_code(l_res_assignment_id_tbl.count):= l_upd_pfc_cur_conv_rej_code(l_index);
                            l_pc_raw_cost_tbl(l_res_assignment_id_tbl.count)            := nvl(l_bl_PROJECT_RAW_COST_tbl(kk),0);
                            l_pc_burd_cost_tbl(l_res_assignment_id_tbl.count)           := nvl(l_bl_PROJECT_BURDENED_COST_tbl(kk),0);
                            l_pc_revenue_tbl(l_res_assignment_id_tbl.count)             := nvl(l_bl_PROJECT_REVENUE_tbl(kk),0);
                            l_pfc_raw_cost_tbl(l_res_assignment_id_tbl.count)           := nvl(l_bl_RAW_COST_tbl(kk),0);
                            l_pfc_burd_cost_tbl(l_res_assignment_id_tbl.count)          := nvl(l_bl_BURDENED_COST_tbl(kk),0);
                            l_pfc_revenue_tbl(l_res_assignment_id_tbl.count)            := nvl(l_bl_REVENUE_tbl(kk),0);

                            IF P_PA_DEBUG_MODE = 'Y' THEN
                                pa_debug.g_err_stage:='Done with bl tbl copy. Proceeding to get RA attributes';
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                            END IF;

                            l_temp:=NULL;
                            --Loop thru the resource assignments that were updated earlier to get the details
                            --such as task id, resource class code etc.Bug 3678314
                            FOR LL IN 1..l_upd_ra_res_asmt_id_tbl.COUNT LOOP
                                IF l_bl_RESOURCE_ASIGNMENT_ID_tbl(kk)=l_upd_ra_res_asmt_id_tbl(LL) THEN

                                    l_temp:=LL;
                                    EXIT;

                                END IF;

                            END LOOP;

                            --The below condition should never happen since if a budget line gets updated then
                            --the corresponding RA should also get updated and hence it should be part of l_upd_ra_res_asmt_id_tbl
                            --Bug 3678314
                            IF l_temp IS NULL THEN

                                IF P_PA_DEBUG_MODE = 'Y' THEN
                                    pa_debug.g_err_stage:='RA in l_bl_RESOURCE_ASIGNMENT_ID_tbl '||l_bl_RESOURCE_ASIGNMENT_ID_tbl(kk) ||' doesnt exist in l_upd_ra_res_asmt_id_tbl ';
                                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                                END IF;

                                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                            END IF;

                            l_pji_prm_task_id_tbl.extend;
                            l_pji_prm_rbs_elem_id_tbl.extend;
                            l_pji_prm_res_cls_code_tbl.extend;
                            l_pji_prm_rbf_tbl.extend;
                            l_pji_prm_task_id_tbl(l_res_assignment_id_tbl.count):=l_upd_ra_task_id_tbl(l_temp);
                            l_pji_prm_rbs_elem_id_tbl(l_res_assignment_id_tbl.count):=l_upd_ra_rbs_elem_id_tbl(l_temp);
                            l_pji_prm_res_cls_code_tbl(l_res_assignment_id_tbl.count):=l_upd_ra_res_class_code_tbl(l_temp);
                            l_pji_prm_rbf_tbl(l_res_assignment_id_tbl.count):=l_upd_ra_rbf_tbl(l_temp);

                            IF P_PA_DEBUG_MODE = 'Y' THEN
                                pa_debug.g_err_stage:='Done with ra tbl copy';
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                            END IF;

                          END IF;

                      END LOOP;-- FOR kk in l_bl_RESOURCE_ASIGNMENT_ID_tbl.FIRST..l_bl_RESOURCE_ASIGNMENT_ID_tbl..LAST LOOP

                    END IF;--IF l_bl_RESOURCE_ASIGNMENT_ID_tbl.COUNT>O THEN

                    /* END IF;--IF l_rbs_version_id IS NOT NULL THEN : Bug 5335211 */

                     IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.g_err_stage:='Calling rollup api ........ ';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                     END IF;

                     PA_FP_ROLLUP_PKG.ROLLUP_BUDGET_VERSION
                     (      p_budget_version_id     => p_budget_version_id
                         ,p_entire_version        => 'Y'
                         ,x_return_status         => l_return_status
                         ,x_msg_count             => l_msg_count
                         ,x_msg_data              => l_msg_data);

                     IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                         IF P_PA_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Error in ROLLUP_BUDGET_VERSION';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                         END IF;
                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                     END IF;

                     --dbms_output.put_line('I46');

                     -- Bug Fix: 4569365. Removed MRC code.
                     /*
                     IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.g_err_stage:='Calling mrc api ........ ';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                     END IF;

                     IF PA_MRC_FINPLAN.g_mrc_enabled_for_budgets IS NULL THEN
                          PA_MRC_FINPLAN.check_mrc_install
                                  (x_return_status      => l_return_status,
                                   x_msg_count          => l_msg_count,
                                   x_msg_data           => l_msg_data);
                     END IF;

                     IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                         IF P_PA_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Error in g_mrc_enabled_for_budgets';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                         END IF;
                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                     END IF;

                     --dbms_output.put_line('I47');

                     IF PA_MRC_FINPLAN.g_mrc_enabled_for_budgets AND
                          PA_MRC_FINPLAN.g_finplan_mrc_option_code = 'A' THEN

                             PA_MRC_FINPLAN.g_calling_module := NULL;

                             PA_MRC_FINPLAN.maintain_all_mc_budget_lines
                                  (p_fin_plan_version_id => p_budget_version_id,
                                   p_entire_version      => 'Y',
                                   x_return_status       => x_return_status,
                                   x_msg_count           => x_msg_count,
                                   x_msg_data            => x_msg_data);


                             IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                                 IF P_PA_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage:= 'Error in maintain_all_mc_budget_lines';
                                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                                 END IF;
                                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                            END IF;


                     END IF;
                     */

              --IPM Architecture Enhancement: Start Bug 4865563
                -- The PA_RESOURCE_ASGN_CURR maintenance api updates the pa_budget_lines manually.
                -- populate_display_quantity populates the display_quantity appropriately

                --This api will take care of inserting display_quantity appropriately.Not necessary to insert every time in the budget lines
                PA_BUDGET_LINES_UTILS.populate_display_qty
                    (p_budget_version_id          => p_budget_version_id,
                     p_context                    => 'FINANCIAL',
                     --p_use_temp_table_flag  => 'N',
                     --p_resource_assignment_id_tab  => l_res_assignment_id_tbl,
                     p_set_disp_qty_null_for_nrbf => 'Y',
                     x_return_status              => l_return_status);

                    IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                        IF P_PA_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage:= 'Error in PA_BUDGET_LINES_UTILS.populate_display_qty';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                        END IF;
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;


                PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
                   (P_BUDGET_VERSION_ID              => p_budget_version_id,
                    X_FP_COLS_REC                    => l_fp_cols_rec,
                    X_RETURN_STATUS                  => l_return_status,
                    X_MSG_COUNT                      => l_msg_count,
                    X_MSG_DATA                       => l_msg_data);

                    IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                        IF P_PA_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage:= 'Error in PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DETAILS';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                        END IF;
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;


                pa_res_asg_currency_pub.maintain_data
                   (p_fp_cols_rec           => l_fp_cols_rec,
                    p_calling_module        => 'CHANGE_MGT',
                    p_rollup_flag           => 'Y',
                    p_version_level_flag    => 'Y',
                    p_called_mode           => 'SELF_SERVICE',
                    x_return_status         => l_return_status,
                    x_msg_data              => l_msg_data,
                    x_msg_count             => l_msg_count);

                    IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                        IF P_PA_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage:= 'Error in PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                        END IF;
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;

                /* bug 5073816: At this point of time, the new entity would have records
                 * from the resource assignments in the target versions which have amounts.
                 * it is possible that some of the RAs created in the target version which
                 * do not have any budget lines would not be inserted into pa_resource_asgn_curr
                 * by the maintenance API. So to insert those left over RAs, we are calling
                 * the following.
                 */
                pa_fin_plan_pub.create_default_plan_txn_rec
                 (p_budget_version_id   => p_budget_version_id,
                  p_calling_module      => 'CHANGE_MGT',
                  x_return_status       => l_return_status,
                  x_msg_count           => l_msg_count,
                  x_msg_data            => l_msg_data);

                  IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                      IF P_PA_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:= 'Error in pa_fin_plan_pub.create_default_plan_txn_rec';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                      END IF;
                      RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;

                --IPM Architecture Enhancement: End Bug 4865563


                     --Call the PJI Plan Updte API only if the calculate API is not called earlier
                     IF (NOT (l_src_time_phased_code = 'N' AND (l_targ_time_phased_code = 'P' OR l_targ_time_phased_code = 'G'))) AND
                         l_call_rep_lines_api ='Y' THEN

                         -- Bug 5335211: Removing the check for null rbs_version_id
                         -- IF l_rbs_version_id IS NOT NULL AND -- end bug 5335211
                         IF l_res_assignment_id_tbl.COUNT>0 THEN

                            IF P_PA_DEBUG_MODE = 'Y' THEN
                               pa_debug.g_err_stage := 'Calling  pa_planning_transaction_utils.call_update_rep_lines_api';
                               pa_debug.write( l_module_name,pa_debug.g_err_stage,3);
                            END IF;
                            pa_planning_transaction_utils.call_update_rep_lines_api
                            (
                               p_source                     => 'PL-SQL'
                              ,p_budget_version_id          => p_budget_version_id
                              ,p_resource_assignment_id_tbl => l_res_assignment_id_tbl
                              ,p_period_name_tbl            => l_period_name_tbl
                              ,p_start_date_tbl             => l_prm_bl_start_date_tbl
                              ,p_end_date_tbl               => l_prm_bl_end_date_tbl
                              ,p_txn_currency_code_tbl      => l_currency_code_tbl
                              ,p_txn_raw_cost_tbl           => l_total_raw_cost_tbl
                              ,p_txn_burdened_cost_tbl      => l_total_burdened_cost_tbl
                              ,p_txn_revenue_tbl            => l_total_revenue_tbl
                              ,p_project_raw_cost_tbl       => l_pc_raw_cost_tbl
                              ,p_project_burdened_cost_tbl  => l_pc_burd_cost_tbl
                              ,p_project_revenue_tbl        => l_pc_revenue_tbl
                              ,p_raw_cost_tbl               => l_pfc_raw_cost_tbl
                              ,p_burdened_cost_tbl          => l_pfc_burd_cost_tbl
                              ,p_revenue_tbl                => l_pfc_revenue_tbl
                              ,p_cost_rejection_code_tbl    => l_cost_rejection_code
                              ,p_revenue_rejection_code_tbl => l_revenue_rejection_code
                              ,p_burden_rejection_code_tbl  => l_burden_rejection_code
                              ,p_other_rejection_code       => l_other_rejection_code
                              ,p_pc_cur_conv_rej_code_tbl   => l_pc_cur_conv_rejection_code
                              ,p_pfc_cur_conv_rej_code_tbl  => l_pfc_cur_conv_rejection_code
                              ,p_quantity_tbl               => l_total_quantity_tbl
                              ,p_rbs_element_id_tbl         => l_pji_prm_rbs_elem_id_tbl
                              ,p_task_id_tbl                => l_pji_prm_task_id_tbl
                              ,p_res_class_code_tbl         => l_pji_prm_res_cls_code_tbl
                              ,p_rate_based_flag_tbl        => l_pji_prm_rbf_tbl
                              ,x_return_status              => x_return_status
                              ,x_msg_count                  => x_msg_count
                              ,x_msg_data                   => x_msg_data);

                              IF x_return_Status <> FND_API.G_RET_STS_SUCCESS  THEN
                                IF P_PA_DEBUG_MODE = 'Y' THEN
                                   pa_debug.g_err_stage := 'pa_planning_transaction_utils.call_update_rep_lines_api errored .... ' || x_msg_data;
                                   pa_debug.write( l_module_name,pa_debug.g_err_stage,5);
                                END IF;
                                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                              END IF;

                         END IF;--IF l_rbs_version_id IS NOT NULL AND

                     END IF;--IF (NOT (l_src_time_phased_code = 'N' AND (l_targ_time_phased_code = 'P' OR l_targ_time_phased_code = 'G'))) AND
                     --dbms_output.put_line('I48');
                  END IF;

                 --dbms_output.put_line('I49');
                 IF  P_submit_version_flag = 'Y' THEN
                      IF l_targ_app_rev_flag = 'Y'    AND
                         l_impl_type_tbl(j) <> 'COST' AND
                         l_rev_impl_flag ='Y' THEN

                        --In this code to put the residual amount into the last budget line would have got executed and
                        --hence l_targ_pc/pfc_rev_after_merge and l_pc/pfc_revenue_delta would have got populated above
                        IF l_partial_factor <> 1 THEN

                            l_impl_pc_rev_amt  := l_targ_pc_rev_after_merge - l_targ_pc_rev_before_merge + l_pc_revenue_delta;
                            l_impl_pfc_rev_amt := l_targ_pfc_rev_after_merge - l_targ_pfc_rev_before_merge + l_pfc_revenue_delta;

                        ELSE
                            --Derive l_pc/pfc_revenue_delta. In this case  we have to go to pa_budget_lines since the amounts
                            --would not have got rolled up
                            SELECT sum(pbl.project_revenue) - l_targ_pc_rev_before_merge
                                  ,sum(pbl.revenue) - l_targ_pfc_rev_before_merge
                            INTO   l_impl_pc_rev_amt
                                  ,l_impl_pfc_rev_amt
                            FROM   pa_budget_lines pbl
                            WHERE  budget_version_id=p_budget_version_id;

                        END IF;

                        pa_fp_ci_implement_pkg.create_ci_impact_fund_lines
                        (p_project_id             => l_project_id,
                         p_ci_id                  => p_ci_id,
                         p_update_agr_amount_flag => P_update_agreement_amt_flag,
                         p_funding_category       => p_funding_category,
                         p_partial_factor         => l_partial_factor,
                         p_impl_txn_rev_amt       => l_partial_impl_rev_amt,
                         p_impl_pc_rev_amt        => l_impl_pc_rev_amt,
                         p_impl_pfc_rev_amt       => l_impl_pfc_rev_amt,
                         x_msg_data               => l_msg_data,
                         x_msg_count              => l_msg_count,
                         x_return_status          => l_return_status);

                         IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                              IF P_PA_debug_mode = 'Y' THEN
                                 pa_debug.g_err_stage:= 'Error in create_ci_impact_fund_lines';
                                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                              END IF;
                              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                         END IF;

                      END IF;

                      --If the version is approved revenue version and if the project is enabled for auto
                      --baseline then the version should be baselined
                      --Submit the version if the project is not enabled for baseline or if the version is not
                      --an approved revenue version.
                      --please NOTE that the its not required to check whether the target version is the current
                      --working version or not as
                      ----P_submit_version_flag can be Y only when this API is called IMplement Financial Impact
                      ----page and in that page impact will always be implemented into the current working version.
                      /*IF l_baseline_funding_flag ='Y' AND
                         l_targ_app_rev_flag = 'Y'    AND
                         l_impl_type_tbl(j) <> 'COST' AND
                         l_rev_impl_flag ='Y' THEN

                         IF P_PA_debug_mode = 'Y' THEN
                               pa_debug.g_err_stage:= 'Calling the change management baseline API';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                         END IF;

                         l_CI_ID_Tab.delete;
                         l_CI_ID_Tab(1):=p_ci_id;

                         pa_baseline_funding_pkg.change_management_baseline
                         (P_Project_ID   => l_project_id,
                          P_CI_ID_Tab    => l_CI_ID_Tab,
                          X_Err_Code     => X_Err_Code,
                          X_Status       => l_return_status);

                         IF X_Err_Code <>  0 THEN
                              IF P_PA_debug_mode = 'Y' THEN
                                 pa_debug.g_err_stage:= 'Error in change_management_baseline';
                                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                              END IF;
                              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                         END IF;

                      ELSE*/-- Commented as part of bug 3877815, would remove completely, once review is done.

                         SELECT record_version_number
                         INTO   l_record_version_number
                         FROM   pa_budget_versions
                         WHERE  budget_version_id=p_budget_version_id;

                         pa_fin_plan_pub.Submit_Current_Working
                            (p_project_id                   =>    l_project_id,
                             p_budget_version_id            =>    p_budget_version_id,
                             p_record_version_number        =>    l_record_version_number,
                             x_return_status                =>    l_return_status,
                             x_msg_count                    =>    l_msg_count,
                             x_msg_data                     =>    l_msg_data);

                         IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                             IF P_PA_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage:= 'Error in Submit_Current_Working';
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                             END IF;
                             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                         END IF;

                      /*END IF;*/

                   END IF;--IF  P_submit_version_flag = 'Y' THEN

            END IF;--IF l_partial_factor<>0

            END IF;--If l_targ_ra_id_tbl.COUNT>0
           --dbms_output.put_line('I50');
           -- Preparing input parameters for FP_CI_LINK_CONTROL_ITEMS

           /* Opening a cursor to get the project levee amounts. */

            OPEN c_proj_level_amounts;



              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.g_err_stage := 'fetching project level amounts';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
              END IF;



              FETCH c_proj_level_amounts INTO
                    l_targ_pc_rawc_after_merge
                   ,l_targ_pc_burdc_after_merge
                   ,l_targ_pc_rev_after_merge
                   ,l_targ_pfc_rawc_after_merge
                   ,l_targ_pfc_burdc_after_merge
                   ,l_targ_pfc_rev_after_merge
                   ,l_targ_lab_qty_after_merge
                   ,l_targ_eqp_qty_after_merge;

           CLOSE c_proj_level_amounts;


           l_cost_ppl_qty         := null;
           l_rev_ppl_qty          := null;
           l_cost_equip_qty       := null;
           l_rev_equip_qty        := null;
           l_impl_pfc_raw_cost    := null;
           l_impl_pfc_revenue     := null;
           l_impl_pfc_burd_cost   := null;
           l_impl_pc_raw_cost     := null;
           l_impl_pc_revenue      := null;
           l_impl_pc_burd_cost    := null;

           IF l_cost_impl_flag = 'Y' THEN
                l_cost_ppl_qty := l_targ_lab_qty_after_merge-l_targ_lab_qty_before_merge;
                l_cost_equip_qty := l_targ_eqp_qty_after_merge-l_targ_eqp_qty_before_merge;
                l_impl_pfc_raw_cost := l_targ_pfc_rawc_after_merge-l_targ_pfc_rawc_before_merge;
                l_impl_pfc_burd_cost := l_targ_pfc_burdc_after_merge-l_targ_pfc_burdc_before_merge;
                l_impl_pc_raw_cost := l_targ_pc_rawc_after_merge-l_targ_pc_rawc_before_merge;
                l_impl_pc_burd_cost := l_targ_pc_burdc_after_merge-l_targ_pc_burdc_before_merge;
           END IF;

           IF l_rev_impl_flag = 'Y' THEN
                 IF l_impl_qty_tbl(j) = 'Y' AND l_impl_type_tbl(j) <> 'ALL' THEN -- Bug 3947169
                      l_rev_ppl_qty := l_targ_lab_qty_after_merge-l_targ_lab_qty_before_merge;
                      l_rev_equip_qty := l_targ_eqp_qty_after_merge-l_targ_eqp_qty_before_merge;
                 END IF;

                l_impl_pfc_revenue := l_targ_pfc_rev_after_merge - l_targ_pfc_rev_before_merge;
                l_impl_pc_revenue  := l_targ_pc_rev_after_merge - l_targ_pc_rev_before_merge;
           END IF;

           IF l_impl_type_tbl(j) = 'ALL' THEN
                l_version_type := 'BOTH';
           ELSE
                l_version_type := l_impl_type_tbl(j);
           END IF;

           --dbms_output.put_line('I51');


            IF P_PA_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:= 'l_cost_ppl_qty '||l_cost_ppl_qty;
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                 pa_debug.g_err_stage:= 'l_rev_ppl_qty '||l_rev_ppl_qty;
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                 pa_debug.g_err_stage:= 'l_cost_equip_qty '||l_cost_equip_qty;
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                 pa_debug.g_err_stage:= 'l_rev_equip_qty '||l_rev_equip_qty;
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                 pa_debug.g_err_stage:= 'l_impl_pfc_raw_cost '||l_impl_pfc_raw_cost;
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                 pa_debug.g_err_stage:= 'l_impl_pfc_revenue '||l_impl_pfc_revenue;
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                 pa_debug.g_err_stage:= 'l_impl_pfc_burd_cost '||l_impl_pfc_burd_cost;
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                 pa_debug.g_err_stage:= 'l_impl_pc_raw_cost '||l_impl_pc_raw_cost;
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                 pa_debug.g_err_stage:= 'l_impl_pc_revenue '||l_impl_pc_revenue;
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                 pa_debug.g_err_stage:= 'l_impl_pc_burd_cost '||l_impl_pc_burd_cost;
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                 pa_debug.g_err_stage:= 'l_partial_impl_rev_amt '||l_partial_impl_rev_amt;
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

            END IF;

            IF l_impl_earlier='N' THEN

                pa_fp_ci_merge.FP_CI_LINK_CONTROL_ITEMS(
                            p_project_id           => l_project_id
                           ,p_s_fp_version_id      => l_src_ver_id_tbl(j)
                           ,p_t_fp_version_id      => p_budget_version_id
                           ,p_inclusion_method     => 'AUTOMATIC'
                           ,p_included_by          => NULL
                           ,p_version_type         => l_version_type
                           ,p_ci_id                => p_ci_id
                           ,p_cost_ppl_qty         => l_cost_ppl_qty
                           ,p_rev_ppl_qty          => l_rev_ppl_qty
                           ,p_cost_equip_qty       => l_cost_equip_qty
                           ,p_rev_equip_qty        => l_rev_equip_qty
                           ,p_impl_pfc_raw_cost    => l_impl_pfc_raw_cost
                           ,p_impl_pfc_revenue     => l_impl_pfc_revenue
                           ,p_impl_pfc_burd_cost   => l_impl_pfc_burd_cost
                           ,p_impl_pc_raw_cost     => l_impl_pc_raw_cost
                           ,p_impl_pc_revenue      => l_impl_pc_revenue
                           ,p_impl_pc_burd_cost    => l_impl_pc_burd_cost
                           ,p_impl_agr_revenue     => l_partial_impl_rev_amt
                           ,x_return_status        => l_return_status
                           ,x_msg_count            => l_msg_count
                           ,x_msg_data             => l_msg_data
                          )  ;

                IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                    IF P_PA_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:= 'Error in FP_CI_LINK_CONTROL_ITEMS';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                    END IF;
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

            ELSE--IF l_impl_earlier='Y'

               IF l_version_type IN ('REVENUE', 'BOTH') THEN

                    UPDATE pa_fp_merged_ctrl_items
                    SET    impl_proj_func_revenue       =nvl(impl_proj_func_revenue,0)+nvl(l_impl_pfc_revenue,0)
                          ,impl_proj_revenue            =nvl(impl_proj_revenue,0)+nvl(l_impl_pc_revenue,0)
                          ,impl_quantity                =nvl(impl_quantity,0)+nvl(l_rev_ppl_qty,0)
                          ,impl_equipment_quantity      =nvl(impl_equipment_quantity,0)+nvl(l_rev_equip_qty,0)
                          ,impl_agr_revenue             =nvl(impl_agr_revenue,0) + nvl(l_partial_impl_rev_amt,0)
                          ,record_version_number        =record_version_number+1
                          ,last_update_date             =sysdate
                          ,last_update_login            =fnd_global.login_id
                          ,last_updated_by              =fnd_global.user_id
                    WHERE  project_id=l_project_id
                    AND    plan_version_id=p_budget_version_id
                    AND    ci_id=p_ci_id
                    AND    ci_plan_version_id=l_src_ver_id_tbl(j)
                    AND    version_type='REVENUE';

                END IF;

            END IF;

            --rev_partially_impl_flag of pa_budget_Versions should be updated in case of partial implementation
            --It should be Y if the CO is implemented partially. It should be N if the CO has got fully implemented
            -- If the CO has earlier been partially implemented(l_impl_earlier = 'Y'), inclusion will make it fully implemented.
            -- So, rev_partially_impl_flag should be set to 'N'
            IF  p_context='PARTIAL_REV' OR l_impl_earlier = 'Y' THEN

                IF nvl(l_impl_amt,0) + l_partial_impl_rev_amt = l_total_amt THEN

                    UPDATE pa_budget_versions
                    SET    rev_partially_impl_flag ='N'
                          ,record_version_number   =record_version_number+1
                          ,last_update_date        =sysdate
                          ,last_update_login       =fnd_global.login_id
                          ,last_updated_by         =fnd_global.user_id
                    WHERE  budget_version_id = l_src_ver_id_tbl(j);

                ELSE

                    --Update pa_budget_versions only if rev_partially_impl_flag is not already Y
                    UPDATE pa_budget_versions
                    SET    rev_partially_impl_flag ='Y'
                          ,record_version_number   =record_version_number+1
                          ,last_update_date        =sysdate
                          ,last_update_login       =fnd_global.login_id
                          ,last_updated_by         =fnd_global.user_id
                    WHERE  budget_version_id = l_src_ver_id_tbl(j)
                    AND    nvl(rev_partially_impl_flag,'N')='N';

                END IF;

            END IF;

           --dbms_output.put_line('I52');
            IF (l_targ_app_cost_flag = 'Y' OR l_targ_app_rev_flag = 'Y') AND l_current_working_flag = 'Y' THEN
                 l_impact_type_code := 'FINPLAN_' || l_version_type;
                 pa_fp_ci_merge.FP_CI_UPDATE_IMPACT
                          (p_ci_id                 => p_ci_id
                          ,p_status_code           => 'CI_IMPACT_IMPLEMENTED'
                          ,p_implemented_by        => FND_GLOBAL.USER_ID
                          ,p_impact_type_code      => l_impact_type_code
                          ,p_commit_flag           => 'N'
                          ,p_init_msg_list         => 'N'
                          ,p_record_version_number => null
                          ,x_return_status         => l_return_status
                          ,x_msg_count             => l_msg_count
                          ,x_msg_data              => l_msg_data
                          );

                  IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                     IF P_PA_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:= 'Error in FP_CI_UPDATE_IMPACT';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                     END IF;
                     RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;


            END IF;
           --dbms_output.put_line('I53');
       END LOOP;

       --dbms_output.put_line('I54');
                  --updating reporting lines. Call is necessary only if calculate API has not been called

     IF P_PA_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting implement_ci_into_single_ver';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
     --dbms_output.put_line('I58');
     pa_debug.reset_curr_function;
   END IF;
EXCEPTION
      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
          l_msg_count := FND_MSG_PUB.count_msg;

          IF l_msg_count = 1 and x_msg_data IS NULL THEN
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

          ROLLBACK TO implement_ci_into_single_ver;
         IF p_pa_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;
    END IF;
          RETURN;

     WHEN Others THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'PA_FP_CI_MERGE'
                                  ,p_procedure_name  => 'implement_ci_into_single_ver');
          IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:='Unexpected Error ' || SQLERRM;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
          END IF;
          ROLLBACK TO implement_ci_into_single_ver;
     IF p_pa_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;
    END IF;
          RAISE;


END implement_ci_into_single_ver;

--This is a private API called from the implement change document API. This API will perform all the validationa
--required for deciding whether a CI document can be merged into a target version or not. Bug 3550073
PROCEDURE validate_ci_merge_input_data(
 p_context                      IN       VARCHAR2
,p_ci_id_tbl                    IN       SYSTEM.pa_num_tbl_type
,p_ci_cost_version_id_tbl       IN       SYSTEM.pa_num_tbl_type
,p_ci_rev_version_id_tbl        IN       SYSTEM.pa_num_tbl_type
,p_ci_all_version_id_tbl        IN       SYSTEM.pa_num_tbl_type
,p_budget_version_id_tbl        IN       SYSTEM.pa_num_tbl_type
,p_fin_plan_type_id_tbl         IN       SYSTEM.pa_num_tbl_type
,p_fin_plan_type_name_tbl       IN       SYSTEM.pa_varchar2_150_tbl_type
,p_impl_cost_flag_tbl           IN       SYSTEM.pa_varchar2_1_tbl_type
,p_impl_rev_flag_tbl            IN       SYSTEM.pa_varchar2_1_tbl_type
,p_submit_version_flag_tbl      IN       SYSTEM.pa_varchar2_1_tbl_type
,px_partial_impl_rev_amt        IN  OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
,p_agreement_id                 IN       pa_agreements_all.agreement_id%TYPE
,p_update_agreement_amt_flag    IN       VARCHAR2
,p_funding_category             IN       VARCHAR2
,x_ci_id_tbl                    OUT      NOCOPY SYSTEM.pa_num_tbl_type --File.Sql.39 bug 4440895
,x_ci_cost_version_id_tbl       OUT      NOCOPY SYSTEM.pa_num_tbl_type --File.Sql.39 bug 4440895
,x_ci_rev_version_id_tbl        OUT      NOCOPY SYSTEM.pa_num_tbl_type --File.Sql.39 bug 4440895
,x_ci_all_version_id_tbl        OUT      NOCOPY SYSTEM.pa_num_tbl_type --File.Sql.39 bug 4440895
,x_budget_version_id_tbl        OUT      NOCOPY SYSTEM.pa_num_tbl_type --File.Sql.39 bug 4440895
,x_fin_plan_type_id_tbl         OUT      NOCOPY SYSTEM.pa_num_tbl_type --File.Sql.39 bug 4440895
,x_fin_plan_type_name_tbl       OUT      NOCOPY SYSTEM.pa_varchar2_150_tbl_type --File.Sql.39 bug 4440895
,x_submit_version_flag_tbl      OUT      NOCOPY SYSTEM.pa_varchar2_1_tbl_type --File.Sql.39 bug 4440895
,x_ci_number                    OUT      NOCOPY SYSTEM.pa_varchar2_100_tbl_type --File.Sql.39 bug 4440895
,x_budget_ci_map_rec_tbl        OUT      NOCOPY budget_ci_map_rec_tbl_type --File.Sql.39 bug 4440895
,x_agreement_id                 OUT      NOCOPY pa_agreements_all.agreement_id%TYPE --File.Sql.39 bug 4440895
,x_funding_category             OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_return_status                OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count                    OUT      NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data                     OUT      NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
    --Start of variables used for debugging
    l_msg_count                 NUMBER :=0;
    l_data                      VARCHAR2(2000);
    l_msg_data                  VARCHAR2(2000);
    l_error_msg_code            VARCHAR2(30);
    l_msg_index_out             NUMBER;
    l_return_status             VARCHAR2(2000);
    l_debug_mode                VARCHAR2(30);
    l_module_name               VARCHAR2(100):='PAFPCIMB.validate_ci_merge_input_data';
    --End of variables used for debugging
    i                           NUMBER;
    l_ci_cost_version_id_tbl    pa_budget_versions.budget_version_id%TYPE;
    l_ci_rev_version_id_tbl     pa_budget_versions.budget_version_id%TYPE;
    l_ci_all_version_id_tbl     pa_budget_versions.budget_version_id%TYPE;
    l_out_index                 NUMBER;
    l_error_occurred_flag       VARCHAR2(1);
    l_budget_status_code        pa_budget_versions.budget_status_code%TYPE;
    l_ci_cost_version_id        pa_budget_versions.budget_version_id%TYPE;
    l_ci_rev_version_id         pa_budget_versions.budget_version_id%TYPE;
    l_ci_all_version_id         pa_budget_versions.budget_version_id%TYPE;
    l_project_id                pa_projects_all.project_id%TYPE;
    l_source_version_id_tbl     SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_calling_mode_for_chk_api  VARCHAR2(30);
    l_merge_possible_code_tbl   SYSTEM.pa_varchar2_1_tbl_type :=SYSTEM.pa_varchar2_1_tbl_type();
    l_copy_ci_ver_flag          VARCHAR2(1);
    l_record_version_number     pa_budget_versions.record_Version_number%TYPE;
    l_cost_ci_ver_index         NUMBER;
    l_rev_ci_ver_index          NUMBER;
    l_all_ci_ver_index          NUMBER;
    l_index                     NUMBER:=0;
    l_implementable_impact      VARCHAR2(10);
    l_dummy                     VARCHAR2(1);
    l_ci_number                 pa_control_items.ci_number%TYPE;

    l_cost_impl_flag            VARCHAR2(1);
    l_rev_impl_flag             VARCHAR2(1);
    l_cost_impact_impl_flag     VARCHAR2(1);
    l_rev_impact_impl_flag      VARCHAR2(1);
    l_partially_impl_flag       VARCHAR2(1);
    l_agreement_num             pa_agreements_all.agreement_num%TYPE;
    l_approved_fin_pt_id        pa_fin_plan_types_b.fin_plan_type_id%TYPE;
    l_impl_cost_flag_tbl        SYSTEM.pa_varchar2_1_tbl_type;
    l_impl_rev_flag_tbl         SYSTEM.pa_varchar2_1_tbl_type;
    l_fin_plan_type_id          pa_fin_plan_types_b.fin_plan_type_id%TYPE;
    l_fin_plan_type_name        pa_fin_plan_types_tl.name%TYPE;
    l_total_amount              NUMBER;
    l_implemented_amount        NUMBER;
    l_remaining_amount          NUMBER;
    l_agr_curr_code             pa_agreements_all.agreement_currency_code%TYPE;

    CURSOR c_chk_rej_codes (ci_ci_ver_id1 pa_budget_versions.budget_version_id%TYPE,
                            ci_ci_ver_id2 pa_budget_versions.budget_version_id%TYPE)
    IS
    SELECT 'Y'
    FROM    DUAL
    WHERE   EXISTS (SELECT 1
                    FROM   pa_budget_lines pbl
                    WHERE  pbl.budget_version_id IN (ci_ci_ver_id1, ci_ci_ver_id2)
                    AND(       pbl.cost_rejection_code         IS NOT NULL
                        OR     pbl.revenue_rejection_code      IS NOT NULL
                        OR     pbl.burden_rejection_code       IS NOT NULL
                        OR     pbl.other_rejection_code        IS NOT NULL
                        OR     pbl.pc_cur_conv_rejection_code  IS NOT NULL
                        OR     pbl.pfc_cur_conv_rejection_code IS NOT NULL));

--These two variables will be used for comparing the no. of error messages in the error message stack when the
--API called and when the API is done with the processing. If the no of messages in the two pl/sql tbls are
--different then the error status will be returned as E from the API. This will be done only when the p_context='CI_MERGE'
l_init_msg_count                NUMBER;
l_msg_count_at_end               NUMBER;

l_version_type              pa_budget_versions.version_type%TYPE;
l_version_type_tbl          SYSTEM.pa_varchar2_30_tbl_type :=SYSTEM.pa_varchar2_30_tbl_type();
l_fin_plan_type_name_tbl    SYSTEM.pa_varchar2_150_tbl_type :=SYSTEM.pa_varchar2_150_tbl_type();
-- Bug 5845142
l_app_cost_plan_type_flag_tbl  SYSTEM.pa_varchar2_1_tbl_type :=SYSTEM.pa_varchar2_1_tbl_type();
l_app_rev_plan_type_flag_tbl   SYSTEM.pa_varchar2_1_tbl_type :=SYSTEM.pa_varchar2_1_tbl_type();
l_app_cost_plan_type_flag      VARCHAR2(1);
l_app_rev_plan_type_flag       VARCHAR2(1);

l_part_impl_err             VARCHAR2(1);
l_ci_name                   VARCHAR2(300);

l_ci_type_class_code        pa_ci_types_b.ci_type_class_code%TYPE;

-- Bug 3986129: Added the following
l_targ_ver_plan_prc_code    pa_budget_versions.plan_processing_code%TYPE;

BEGIN
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_context='CI_MERGE' THEN
         l_init_msg_count:= FND_MSG_PUB.count_msg;
    END IF;
    IF p_pa_debug_mode = 'Y' THEN
    PA_DEBUG.Set_Curr_Function( p_function   => 'PAFPCIMB.validate_ci_merge_input_data',
                                p_debug_mode => l_debug_mode );
    END IF;
    IF l_debug_mode = 'Y' THEN

        pa_debug.g_err_stage:= 'Validating the input parameters';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

    END IF;
    --dbms_output.put_line('1');


    --p_context should be  valid
    IF p_context  NOT IN ('IMPL_FIN_IMPACT' , 'INCLUDE', 'PARTIAL_REV', 'CI_MERGE') THEN

        IF l_debug_mode = 'Y' THEN

            pa_debug.g_err_stage:= 'p_context passed is  '|| p_context;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                     p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                     p_token1         => 'PROCEDURENAME',
                     p_value1         => l_module_name);
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;


    END IF;


    --The no. of elements in ci_id tbl and the ci version id tbls should always be same
    IF ((p_ci_cost_version_id_tbl.COUNT <> 0 AND
        (p_ci_id_tbl.COUNT <> p_ci_cost_version_id_tbl.COUNT))OR
        (p_ci_rev_version_id_tbl.COUNT  <> 0 AND
        (p_ci_id_tbl.COUNT <> p_ci_rev_version_id_tbl.COUNT)) OR
        (p_ci_all_version_id_tbl.COUNT  <> 0 AND
        (p_ci_id_tbl.COUNT <> p_ci_all_version_id_tbl.COUNT ))) THEN

        IF l_debug_mode = 'Y' THEN

            pa_debug.g_err_stage:= 'p_ci_id_tbl.COUNT '|| p_ci_id_tbl.COUNT;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,5);

            pa_debug.g_err_stage:= 'p_ci_cost_version_id_tbl.COUNT '|| p_ci_cost_version_id_tbl.COUNT;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,5);

            pa_debug.g_err_stage:= 'p_ci_rev_version_id_tbl.COUNT '|| p_ci_rev_version_id_tbl.COUNT;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,5);

            pa_debug.g_err_stage:= 'p_ci_all_version_id_tbl.COUNT '|| p_ci_all_version_id_tbl.COUNT;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,5);

        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                             p_token1         => 'PROCEDURENAME',
                             p_value1         => l_module_name);
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;
        --dbms_output.put_line('2');

    --The no of elements in the p_fin_plan_type_id_tbl, p_fin_plan_type_name_tbl p_impl_cost_flag_tbl
    --p_impl_rev_flag_tbl,p_submit_version_flag_tbl
    IF (p_fin_plan_type_id_tbl.COUNT   <> 0 AND p_fin_plan_type_id_tbl.COUNT<>p_budget_version_id_tbl.COUNT) OR
       (p_fin_plan_type_name_tbl.COUNT <> 0 AND p_fin_plan_type_name_tbl.COUNT<>p_budget_version_id_tbl.COUNT) OR
       (p_impl_cost_flag_tbl.COUNT     <> 0 AND p_impl_cost_flag_tbl.COUNT     <> p_budget_version_id_tbl.COUNT) OR
       (p_impl_rev_flag_tbl.COUNT      <> 0 AND p_impl_rev_flag_tbl.COUNT      <> p_budget_version_id_tbl.COUNT) OR
       (p_submit_version_flag_tbl.COUNT<> 0 AND p_submit_version_flag_tbl.COUNT<> p_budget_version_id_tbl.COUNT) THEN

        IF l_debug_mode = 'Y' THEN

            pa_debug.g_err_stage:= 'p_fin_plan_type_id_tbl.COUNT '|| p_fin_plan_type_id_tbl.COUNT;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,5);

            pa_debug.g_err_stage:= 'p_fin_plan_type_name_tbl.COUNT '|| p_fin_plan_type_name_tbl.COUNT;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,5);

            pa_debug.g_err_stage:= 'p_impl_cost_flag_tbl.COUNT '|| p_impl_cost_flag_tbl.COUNT;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,5);

            pa_debug.g_err_stage:= 'p_impl_rev_flag_tbl.COUNT '|| p_impl_rev_flag_tbl.COUNT;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,5);

            pa_debug.g_err_stage:= 'p_submit_version_flag_tbl.COUNT '|| p_submit_version_flag_tbl.COUNT;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,5);

            pa_debug.g_err_stage:= 'p_budget_version_id_tbl.COUNT '|| p_budget_version_id_tbl.COUNT;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,5);

        END IF;

        PA_UTILS.ADD_MESSAGE
                    (p_app_short_name => 'PA',
                     p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                     p_token1         => 'PROCEDURENAME',
                     p_value1         => l_module_name);
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

        --dbms_output.put_line('3');
    --In case of partial implementation the ci id tbl and target budget version id tbls should have
    --only one record
    IF p_context='PARTIAL_REV' THEN
        IF (p_ci_id_tbl.COUNT <>1 OR
            p_budget_version_id_tbl.COUNT <>1) THEN

            IF l_debug_mode = 'Y' THEN

                pa_debug.g_err_stage:= 'p_ci_id_tbl.COUNT in partial implementation context '|| p_ci_id_tbl.COUNT;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,5);

                pa_debug.g_err_stage:= 'p_budget_version_id_tbl.COUNT in partial implementation context '|| p_budget_version_id_tbl.COUNT;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,5);

            END IF;

            PA_UTILS.ADD_MESSAGE
                        (p_app_short_name => 'PA',
                         p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                         p_token1         => 'PROCEDURENAME',
                         p_value1         => l_module_name);
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

        END IF;

        IF (p_impl_cost_flag_tbl(1) ='Y' OR
            p_impl_rev_flag_tbl(1) = 'N') THEN

            IF l_debug_mode = 'Y' THEN

                pa_debug.g_err_stage:= 'p_cost_impl_flag passed in partial implementation case is '|| p_impl_cost_flag_tbl(1);
                pa_debug.write(l_module_name,pa_debug.g_err_stage,5);

                pa_debug.g_err_stage:= 'p_rev_impl_flag passed in partial implementation case is '|| p_impl_rev_flag_tbl(1);
                pa_debug.write(l_module_name,pa_debug.g_err_stage,5);

            END IF;

            PA_UTILS.ADD_MESSAGE
                        (p_app_short_name => 'PA',
                         p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                         p_token1         => 'PROCEDURENAME',
                         p_value1         => l_module_name);
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

        END IF;

    END IF;
    --Initialise all the out put pl/sql tables
    x_ci_id_tbl                :=SYSTEM.pa_num_tbl_type();
    x_ci_cost_version_id_tbl   :=SYSTEM.pa_num_tbl_type();
    x_ci_rev_version_id_tbl    :=SYSTEM.pa_num_tbl_type();
    x_ci_all_version_id_tbl    :=SYSTEM.pa_num_tbl_type();
    x_budget_version_id_tbl    :=SYSTEM.pa_num_tbl_type();
    x_ci_number                :=SYSTEM.pa_varchar2_100_tbl_type();
    l_impl_cost_flag_tbl       :=SYSTEM.pa_varchar2_1_tbl_type();
    l_impl_rev_flag_tbl        :=SYSTEM.pa_varchar2_1_tbl_type();
    x_submit_version_flag_tbl  :=SYSTEM.pa_varchar2_1_tbl_type();
    x_fin_plan_type_id_tbl     :=SYSTEM.pa_num_tbl_type();
    x_fin_plan_type_name_tbl   :=SYSTEM.pa_varchar2_150_tbl_type();
    IF p_funding_category IS NULL THEN
        x_funding_category := 'ADDITIONAL';
    -- Bug 3749322- adding the else clause to pass the value of
    -- p_funding_category as it is passed
    ELSE
        x_funding_category := p_funding_category;
    END IF;
    x_agreement_id             :=p_agreement_id;

    --Derive the calling context that should be passed to the check merge possible API
    IF p_context='IMPL_FIN_IMPACT' OR
       p_context='PARTIAL_REV' THEN

        l_calling_mode_for_chk_api:='IMPLEMENT';

    ELSIF p_context='INCLUDE' THEN

        l_calling_mode_for_chk_api:='INCLUDE';

    ELSIF p_context='CI_MERGE' THEN
        l_calling_mode_for_chk_api:= 'INCLUDE_CR_TO_CO';

    END IF;

    IF l_debug_mode = 'Y' THEN

        pa_debug.g_err_stage:= 'Calling mode for the chk API derived is '||l_calling_mode_for_chk_api;
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage:= 'Validating the the CIs passed';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);


    END IF;

    IF p_ci_id_tbl.COUNT=0 OR
       p_budget_version_id_tbl.COUNT=0 THEN

        IF l_debug_mode = 'Y' THEN

            pa_debug.g_err_stage:= 'CI Ids/BV Ids are not passed for merge. Returning';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
         pa_debug.reset_curr_function;
    END IF;
       RETURN;

    END IF;
    --dbms_output.put_line('4');

    FOR i IN p_ci_id_tbl.FIRST..p_ci_id_tbl.LAST LOOP

        IF p_ci_id_tbl(i) IS NULL THEN

            IF l_debug_mode = 'Y' THEN

                pa_debug.g_err_stage:= 'p_ci_id_tbl('||i||') IS '|| p_ci_id_tbl(i);
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

            END IF;
            PA_UTILS.ADD_MESSAGE
            (p_app_short_name => 'PA',
             p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
             p_token1         => 'PROCEDURENAME',
             p_value1         => l_module_name);
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

        END IF;

        l_copy_ci_ver_flag:='Y';

        l_ci_cost_version_id:=NULL;
        l_ci_rev_version_id:=NULL;
        l_ci_all_version_id:=NULL;
        IF ((NOT p_ci_cost_version_id_tbl.EXISTS(i)) OR p_ci_cost_version_id_tbl(i) IS NULL) AND
           ((NOT p_ci_rev_version_id_tbl.EXISTS(i)) OR p_ci_rev_version_id_tbl(i) IS NULL) AND
           ((NOT p_ci_all_version_id_tbl.EXISTS(i)) OR p_ci_all_version_id_tbl(i) IS NULL)THEN

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'Calling Pa_Fp_Control_Items_Utils.get_ci_versions';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;

           Pa_Fp_Control_Items_Utils.get_ci_versions
           ( p_ci_id                    => p_ci_id_tbl(i)
            ,X_cost_budget_version_id   => l_ci_cost_version_id
            ,X_rev_budget_version_id    => l_ci_rev_version_id
            ,X_all_budget_version_id    => l_ci_all_version_id
            ,x_return_status            => x_return_status
            ,x_msg_count                => x_msg_count
            ,x_msg_data                 => x_msg_data);

            --ci id will be skipped. Processing will continue with other cis
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                l_copy_ci_ver_flag:='N';
            END IF;
        ELSE

            IF p_ci_cost_version_id_tbl.EXISTS(i) THEN
                l_ci_cost_version_id:= p_ci_cost_version_id_tbl(i);
            END IF;

            IF p_ci_rev_version_id_tbl.EXISTS(i) THEN
                l_ci_rev_version_id:=p_ci_rev_version_id_tbl(i);
            END IF;

            IF p_ci_all_version_id_tbl.EXISTS(i) THEN
                l_ci_all_version_id:=p_ci_all_version_id_tbl(i);
            END IF;


        END IF;

        --Check for the existence of rejection lines in the change order versions. If the rejection codes exist
        --then the change order is not eligible for merge.Derive ci number as it has to be passed as token to
        --error messages
        SELECT pci.ci_number,
               pct.ci_type_class_code
        INTO   l_ci_number,
               l_ci_type_class_code
        FROM   pa_control_items pci,
               pa_ci_types_b pct
        WHERE  pci.ci_id = p_ci_id_tbl(i)
        AND    pci.ci_type_id=pct.ci_type_id;

        IF l_copy_ci_ver_flag='Y' THEN

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'Checking for the existence of budget lines with rejection codes in ci version';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;

            OPEN c_chk_rej_codes(NVL(l_ci_cost_version_id,NVL(l_ci_all_version_id,l_ci_rev_version_id)),
                                 NVL(l_ci_rev_version_id,NVL(l_ci_all_version_id,l_ci_cost_version_id)));
            FETCH c_chk_rej_codes INTO l_dummy;
            IF c_chk_rej_codes%FOUND THEN

                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:= 'budget lines with rejection codes EXIST in ci version';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                END IF;

                IF l_ci_type_class_code='CHANGE_ORDER' THEN
                     PA_UTILS.ADD_MESSAGE
                     (p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_IMPL_CO_REJ_CODES_EXST',
                      p_token1         => 'CI_NUMBER',
                      p_value1         => l_ci_number);
                ELSE

                     PA_UTILS.ADD_MESSAGE
                     (p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_IMPL_CR_REJ_CODES_EXST',
                      p_token1         => 'CI_NUMBER',
                      p_value1         => l_ci_number);

                END IF;

                l_copy_ci_ver_flag:='N';

            END IF;

            CLOSE c_chk_rej_codes;

        END IF;

        -- For bug 3814932
        IF  l_copy_ci_ver_flag='Y' THEN

           IF p_context = 'PARTIAL_REV' Then

              IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:= 'In the context of PARTIAL_REV';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
              END IF;

              If px_partial_impl_rev_amt is null Then

                 PA_UTILS.ADD_MESSAGE
                             (p_app_short_name => 'PA',
                              p_msg_name       => 'PA_CI_PAR_REV_IMPL_AMT_NULL');

                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:= 'px_partial_impl_rev_amt is null.';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;

                 l_copy_ci_ver_flag:='N';

              End If;

              IF l_copy_ci_ver_flag <> 'N' THEN

                  -- Get the project id

                  SELECT project_id
                  INTO   l_project_id
                  FROM   pa_budget_versions
                  WHERE  budget_version_id=p_budget_version_id_tbl(i);


                  IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:= 'Project id is:' ||l_project_id;
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                  END IF;

                  --To get the total amount.
                  SELECT (sum(nvl(txn_revenue,0)) )
                  INTO l_total_amount
                  FROM  pa_budget_lines
                  WHERE budget_version_id = NVL(l_ci_all_version_id,l_ci_rev_version_id);

                  IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:= 'Total Planned Revenue amount is:' ||l_total_amount;
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                  END IF;

                  --To get implemented amount.
                  l_implemented_amount := Pa_Fp_Control_Items_Utils.get_impl_agr_revenue(
                                                                           p_project_id => l_project_id,
                                                                           p_ci_id      => p_ci_id_tbl(i) );

                  IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:= 'Implemented Amount is:' ||l_implemented_amount;
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                  END IF;

                  If l_total_amount = 0 Then

                      If(px_partial_impl_rev_amt<>0) Then
                           --Error
                         PA_UTILS.ADD_MESSAGE
                             (p_app_short_name => 'PA',
                              p_msg_name       => 'PA_CI_PAR_REV_AMT_NOT_ZERO');

                         IF l_debug_mode = 'Y' THEN
                            pa_debug.g_err_stage:= 'Partial implementation revenue cannot be anything other than 0';
                            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                         END IF;

                         l_copy_ci_ver_flag:='N';

                      End If;--If(px_partial_impl_rev_amt<>0) Then

                  End If; --End of l_total_amount = 0

              End If;--IF l_copy_ci_ver_flag <> 'N' THEN


              If l_copy_ci_ver_flag <> 'N' Then

                 If abs(l_implemented_amount)>abs(l_total_amount) Then

                    IF l_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage:= 'Implemented amount is greater than total amount.';
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                    END IF;

                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                 End If;

              End If;

              If l_copy_ci_ver_flag <> 'N' Then

                 If l_total_amount >0 Then

                    If px_partial_impl_rev_amt <0 Then
                         --Error;
                       PA_UTILS.ADD_MESSAGE
                             (p_app_short_name => 'PA',
                              p_msg_name       => 'PA_CI_PAR_REV_AMT_NOT_POS');

                       IF l_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:= 'Partial implementation revenue amount is negetive';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                       END IF;

                       l_copy_ci_ver_flag:='N';

                    End If;--End of px_partial_impl_rev_amt <0

                    If l_copy_ci_ver_flag<>'N' Then

                       l_remaining_amount:=l_total_amount-l_implemented_amount;

                       IF l_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:= 'Remaining amount to be implemented is:' || l_remaining_amount;
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                       END IF;

                       If px_partial_impl_rev_amt>l_remaining_amount Then
                          --Error;
                          PA_UTILS.ADD_MESSAGE
                             (p_app_short_name => 'PA',
                              p_msg_name       => 'PA_CI_PAR_REV_IMPL_AMT_GREATER');

                          IF l_debug_mode = 'Y' THEN
                             pa_debug.g_err_stage:= 'Partial impl rev is > Reamaining amount to be implemented';
                             pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                          END IF;

                          l_copy_ci_ver_flag:='N';

                       End If; --End of px_partial_impl_rev_amt>l_remaining_amount

                    End If; --End of l_copy_ci_ver_flag<>'N'

                 End If;   --End of l_total_amount>0

              End If;

              If l_copy_ci_ver_flag<>'N' Then

                 If l_total_amount<0 Then

                    If px_partial_impl_rev_amt>0 Then
                       --Error;
                       PA_UTILS.ADD_MESSAGE
                             (p_app_short_name => 'PA',
                              p_msg_name       => 'PA_CI_PAR_REV_AMT_NOT_NEG');

                       IF l_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:= 'Partial implementation revenue amount is positive';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                       END IF;

                       l_copy_ci_ver_flag:='N';

                    End If; --End of px_partial_impl_rev_amt>0

                    If l_copy_ci_ver_flag<>'N' Then

                       l_remaining_amount:=l_total_amount-l_implemented_amount;

                       IF l_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:= 'Remaining amount to be implemented is:' || l_remaining_amount;
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                       END IF;

                       If abs(px_partial_impl_rev_amt)>abs(l_remaining_amount) Then
                          --Error;
                          PA_UTILS.ADD_MESSAGE
                             (p_app_short_name => 'PA',
                              p_msg_name       => 'PA_CI_PAR_REV_IMPL_AMT_GREATER');

                          IF l_debug_mode = 'Y' THEN
                             pa_debug.g_err_stage:= 'Partial impl rev is > Reamaining amount to be implemented';
                             pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                          END IF;

                          l_copy_ci_ver_flag:='N';

                       End If;-- End of abs(px_partial_impl_rev_amt)>abs(l_remaining_amount)

                    End If; --End of l_copy_ci_ver_flag<>'N'

                 End If;  --l_total_amount<0

              End If;

           End If;  --end of p_context 'PARTIAL_REV'

        End If; --End of bug 3814932


        IF l_copy_ci_ver_flag='Y' THEN

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'l_copy_ci_ver_flag is Y Copying';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;

            x_ci_id_tbl.EXTEND(1);
            x_ci_cost_version_id_tbl.EXTEND(1);
            x_ci_rev_version_id_tbl.EXTEND(1);
            x_ci_all_version_id_tbl.EXTEND(1);
            x_ci_number.EXTEND(1);
            x_ci_id_tbl(x_ci_id_tbl.COUNT):=p_ci_id_tbl(i);
            x_ci_cost_version_id_tbl(x_ci_cost_version_id_tbl.COUNT):=l_ci_cost_version_id;
            x_ci_rev_version_id_tbl(x_ci_rev_version_id_tbl.COUNT):=l_ci_rev_version_id;
            x_ci_all_version_id_tbl(x_ci_all_version_id_tbl.COUNT):=l_ci_all_version_id;

            --Derive the ci number in case the API is called from the include change orders page
            IF (p_context = 'INCLUDE') THEN

                x_ci_number(x_ci_number.COUNT):=l_ci_number;

            ELSIF (p_context = 'IMPL_FIN_IMPACT' OR
                   p_context = 'PARTIAL_REV') THEN

                --In this context only one ci id will be passed always and hence we can fetch the agreement id
                --into the scalar variable
                IF x_agreement_id IS NULL  AND
                   nvl(l_ci_rev_version_id, l_ci_all_version_id) IS NOT NULL THEN

                    SELECT agreement_id
                    INTO   x_agreement_id
                    FROM   pa_budget_Versions
                    WHERE  budget_Version_id=nvl(l_ci_rev_version_id, l_ci_all_version_id);

                END IF;

            END IF;

        END IF;--IF l_copy_ci_ver_flag='Y' THEN

    END LOOP;

    --dbms_output.put_line('5');

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Proceeding with the budget version loopn with count '||p_budget_version_id_tbl.count;
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
    END IF;

    --dbms_output.put_line('6');

    --Validate the passed target budget version ids. The budget version ids should not be in a submitted status and
    --and the version should not be already locked by some other user.
    FOR i IN p_budget_version_id_tbl.FIRST..p_budget_version_id_tbl.LAST LOOP

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'p_budget_version_id_tbl ('||i||') is'||p_budget_version_id_tbl(i);
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;

        --Derive the fin plan type name and id if they are not passed
        IF ((NOT p_fin_plan_type_id_tbl.EXISTS(i)) OR  p_fin_plan_type_id_tbl(i)  IS NULL) OR
           ((NOT p_fin_plan_type_name_tbl.EXISTS(i)) OR  p_fin_plan_type_name_tbl(i)  IS NULL) THEN

            SELECT fin.name,
                   fin.fin_plan_type_id
            INTO   l_fin_plan_type_name,
                   l_fin_plan_type_id
            FROM   pa_fin_plan_types_vl fin,
                   pa_budget_versions pbv
            WHERE  fin.fin_plan_type_id=pbv.fin_plan_type_id
            AND    pbv.budget_version_id=p_budget_version_id_tbl(i);
        ELSE
            l_fin_plan_type_name  := p_fin_plan_type_name_tbl(i);
            l_fin_plan_type_id    := p_fin_plan_type_id_tbl(i);
        END IF;

        l_error_occurred_flag:='N';

        --dbms_output.put_line('6.1 '||p_budget_version_id_tbl(i));
        IF NVL(p_budget_version_id_tbl(i),-1)=-1 THEN
            --The current working version does not exist
            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'CWV doest not exist.adding msg to stack';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;

            PA_UTILS.ADD_MESSAGE
                        (p_app_short_name => 'PA',
                         p_msg_name       => 'PA_FP_CI_MRG_NO_CW_VER',
                         p_token1         => 'PLAN_TYPE',
                         p_value1         => l_fin_plan_type_name);

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'CWV doest not exist.added message to stack '|| l_fin_plan_type_name;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;

            l_error_occurred_flag:='Y';
        END IF;

        IF l_error_occurred_flag='N' THEN

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'Checking for S status';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;


            SELECT budget_status_code,
                   record_version_number,
                   project_id,
                   version_type,
                   plan_processing_code,
                   NVL(approved_cost_plan_type_flag,'N'),
                   NVL(approved_rev_plan_type_flag,'N')
            INTO   l_budget_status_code,
                   l_record_version_number,
                   l_project_id,
                   l_version_type,
                   l_targ_ver_plan_prc_code, -- for Bug 3986129
                   -- Bug 5845142
                   l_app_cost_plan_type_flag,
                   l_app_rev_plan_type_flag
            FROM   pa_budget_versions pbv
            WHERE  pbv.budget_version_id=p_budget_version_id_tbl(i);

            -- Bug 5845142. When the approved cost budget is setup to have "Cost and Revenue Together"
            -- plan it is not possible to include change orders. Change Orders can only be implemented.
            IF Pa_Fp_Control_Items_Utils.check_valid_combo
              ( p_project_id         => l_project_id
               ,p_targ_app_cost_flag => l_app_cost_plan_type_flag
               ,p_targ_app_rev_flag  => l_app_rev_plan_type_flag) = 'N' THEN

                  PA_UTILS.ADD_MESSAGE
                  (p_app_short_name => 'PA',
                   p_msg_name       => 'PA_FP_CANT_INCL_CO_UANPP_AMT');


                  l_error_occurred_flag:='Y';

            END IF;

            IF l_budget_status_code ='S' THEN

                IF p_context='IMPL_FIN_IMPACT' OR
                   p_context='PARTIAL_REV' THEN

                    PA_UTILS.ADD_MESSAGE
                                (p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_FP_MERGE_SUBMIT',
                                 p_token1         => 'PLAN_TYPE',
                                 p_value1         =>  l_fin_plan_type_name);

                ELSIF p_context ='INCLUDE' THEN

                    PA_UTILS.ADD_MESSAGE
                                (p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_FP_MERGE_ALL_SUBMIT');


                END IF;
                l_error_occurred_flag:='Y';

            END IF;

            -- Bug 3986129: Added the following check. If the target plan version is locked for concurrent
            -- processing or the concurrent processing for the version has failed, then merge should not be allowed.
            IF l_targ_ver_plan_prc_code = 'XLUP' THEN
                  IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:= 'Version is locked for conc processing';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                  END IF;

                  PA_UTILS.ADD_MESSAGE
                       (p_app_short_name => 'PA',
                        p_msg_name       => 'PA_FP_LOCKED_BY_PROCESSING');

                  l_error_occurred_flag := 'Y';

            ELSIF l_targ_ver_plan_prc_code = 'XLUE' THEN
                  IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:= 'Conc process for version has failed';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                  END IF;

                  PA_UTILS.ADD_MESSAGE
                       (p_app_short_name => 'PA',
                        p_msg_name       => 'PA_FP_WA_CONC_PRC_FAILURE_MSG');

                  l_error_occurred_flag := 'Y';
            END IF; -- Bug 3986129: end.

        END IF;

        IF l_error_occurred_flag='N' THEN
             -- Partial Implementation is not allowed into a target 'ALL' version
             IF p_context='PARTIAL_REV' AND l_version_type = 'ALL' THEN
                IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:= 'Partial Implementation is not allowed into a target ALL version';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                END IF;

                PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                 p_msg_name       => 'PA_FP_NO_PART_INTO_TRG_ALL_PT',
                 p_token1         => 'PLAN_TYPE',
                 p_value1         =>  l_fin_plan_type_name);

                 l_error_occurred_flag := 'Y';
              END IF;
        END IF;

        IF l_error_occurred_flag='N' THEN

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'calling  lock unlock versions';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;

            --Acquire a lock on the target budget version.
            pa_fin_plan_pvt.lock_unlock_version
            ( p_budget_version_id     => p_budget_version_id_tbl(i)
             ,p_record_version_number => l_record_version_number
             ,p_action                => 'L'
             ,p_user_id               => fnd_global.user_id
             ,p_person_id             => NULL
             ,x_return_status         => x_return_status
             ,x_msg_count             => x_msg_count
             ,x_msg_data              => x_msg_data );

            --plan type id will be skipped. Processing will continue with other plan types
            IF x_return_status <> 'S' THEN
                l_error_occurred_flag:='Y';
            END IF;

        END IF;

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'After lock unlock verson msg pub count'||FND_MSG_PUB.count_msg;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:= 'After lock unlock verson x_msg_data '||x_msg_data;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

        END IF;

        --Check if the settings of the source and target version allow merge or not
        IF l_error_occurred_flag='N' THEN

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'Valid BV. About to include in o/p';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;

            x_budget_version_id_tbl.extend(1);
            l_impl_cost_flag_tbl.extend(1);
            l_impl_rev_flag_tbl.extend(1);
            x_submit_version_flag_tbl.extend(1);
            x_fin_plan_type_id_tbl.extend(1);
            x_fin_plan_type_name_tbl.extend(1);
            x_budget_version_id_tbl(x_budget_version_id_tbl.COUNT)     := p_budget_version_id_tbl(i);
            l_version_type_tbl.extend(1);
            l_version_type_tbl(l_version_type_tbl.COUNT) := l_version_type;
            l_fin_plan_type_name_tbl.extend(1);
            l_fin_plan_type_name_tbl(l_fin_plan_type_name_tbl.COUNT) := l_fin_plan_type_name;

            -- Bug 5845142
            l_app_cost_plan_type_flag_tbl.extend(1);
            l_app_cost_plan_type_flag_tbl(l_app_cost_plan_type_flag_tbl.COUNT) := l_app_cost_plan_type_flag;
            l_app_rev_plan_type_flag_tbl.extend(1);
            l_app_rev_plan_type_flag_tbl(l_app_rev_plan_type_flag_tbl.COUNT) := l_app_rev_plan_type_flag;

            IF l_debug_mode = 'Y' THEN

                pa_debug.g_err_stage:= 'About to assign vars';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

            END IF;

            IF p_impl_cost_flag_tbl.EXISTS(i) THEN
                l_impl_cost_flag_tbl(l_impl_cost_flag_tbl.COUNT)           := p_impl_cost_flag_tbl(i);
            END IF;

            IF p_impl_rev_flag_tbl.EXISTS(i) THEN
                l_impl_rev_flag_tbl(l_impl_rev_flag_tbl.COUNT)             := p_impl_rev_flag_tbl(i);
            END IF;

            IF p_submit_version_flag_tbl.EXISTS(i) THEN
                x_submit_version_flag_tbl(x_submit_version_flag_tbl.COUNT) := p_submit_version_flag_tbl(i);
            END IF;

            x_fin_plan_type_name_tbl(x_fin_plan_type_name_tbl.COUNT):=l_fin_plan_type_name;
            x_fin_plan_type_id_tbl(x_fin_plan_type_id_tbl.COUNT):=l_fin_plan_type_id;

        END IF;

    END LOOP; --The loop for the budget versions

    --dbms_output.put_line('7');

    IF l_debug_mode = 'Y' THEN

        pa_debug.g_err_stage:= 'About to check for possibility of merge';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

    END IF;


    --Check if the merge of ci into the target versions is possible or not
    IF x_ci_id_tbl.COUNT>0 AND  x_budget_version_id_tbl.COUNT>0 THEN

        FOR i IN x_ci_id_tbl.FIRST..x_ci_id_tbl.LAST LOOP

            IF l_debug_mode = 'Y' THEN

                pa_debug.g_err_stage:= 'x_ci_cost_version_id_tbl('||i||') '||x_ci_cost_version_id_tbl(i);
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                pa_debug.g_err_stage:= 'x_ci_rev_version_id_tbl('||i||') '||x_ci_rev_version_id_tbl(i);
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                pa_debug.g_err_stage:= 'x_ci_all_version_id_tbl('||i||') '||x_ci_all_version_id_tbl(i);
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

            END IF;

            FOR j IN x_budget_version_id_tbl.FIRST..x_budget_version_id_tbl.LAST LOOP

                --Prepare pl/sql tbl so that it can be passed to check_mrg_possible API to check whether
                --the merge is possible between the source and target versions
                --The order is important here. The order will COST REVENUE and ALL.
                --The index in the source version id tbl for COST is 1, REVENUE will be
                l_source_version_id_tbl :=SYSTEM.pa_num_tbl_type();

                IF  l_impl_cost_flag_tbl(j) IS NULL AND
                    l_impl_rev_flag_tbl(j) IS NULL THEN

                    IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'calling  get_impl_details';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                    END IF;

                    pa_fp_control_items_utils.get_impl_details
                    ( P_fin_plan_type_id      => x_fin_plan_type_id_tbl(j)
                    ,P_project_id             => l_project_id
                    ,P_ci_id                  => x_ci_id_tbl(i)
                    ,P_ci_cost_version_id     => x_ci_cost_version_id_tbl(i)
                    ,P_ci_rev_version_id      => x_ci_rev_version_id_tbl(i)
                    ,P_ci_all_version_id      => x_ci_all_version_id_tbl(i)
                    ,p_targ_bv_id             => x_budget_version_id_tbl(j)
                    ,x_cost_impl_flag         => l_cost_impl_flag
                    ,x_rev_impl_flag          => l_rev_impl_flag
                    ,X_cost_impact_impl_flag  => l_cost_impact_impl_flag
                    ,x_rev_impact_impl_flag   => l_rev_impact_impl_flag
                    ,x_partially_impl_flag    => l_partially_impl_flag
                    ,x_agreement_num          => l_agreement_num
                    ,x_approved_fin_pt_id     => l_approved_fin_pt_id
                    ,x_return_status          => l_return_status
                    ,x_msg_data               => l_msg_data
                    ,x_msg_count              => l_msg_count);

                    --Return status check can be done in this case as the above should never return
                    --a return status of E.
                    IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                       IF P_PA_debug_mode = 'Y' THEN
                            pa_debug.g_err_stage:= 'pa_fp_control_items_utils.get_impl_details returned error';
                            pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
                       END IF;
                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;
                ELSE

                    l_cost_impl_flag:=nvl(l_impl_cost_flag_tbl(j),'N');
                    l_rev_impl_flag:=nvl(l_impl_rev_flag_tbl(j),'N');

                END IF;

                IF l_debug_mode = 'Y' THEN

                    pa_debug.g_err_stage:= 'l_cost_impl_flag '||l_cost_impl_flag;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:= 'l_rev_impl_flag '||l_rev_impl_flag;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                END IF;

                l_part_impl_err := 'N';

                --Bug 4351878. If the target version type is ALL then only cost and revenue together change orders
                --can be merged into those versions.
                IF l_version_type_tbl(j) = 'ALL' AND
                    (x_ci_all_version_id_tbl(i) IS NULL  OR
                     NVL(l_cost_impl_flag,'N') <> 'Y'    OR
                     (NVL(l_rev_impl_flag,'N') <> 'Y' AND
                      NVL(l_rev_impl_flag,'N') <> 'R')) THEN

                   --Bug 5845142. If the cost ci version is of TYPE ALL then the l_rev_impl_flag will be N.
                   --But in this case actually an ALL CI version is being implemented into ALL Cost Budget
                   --Version which is allowed. Eventhough l_rev_impl_flag is N implement_ci_into_single_ver
                   --internally takes care of setting it to Y and adding the revenue amounts too.
                   IF l_version_type_tbl(j) = 'ALL' AND
                      l_app_cost_plan_type_flag_tbl(j)='Y' AND
                      l_app_rev_plan_type_flag_tbl(j)='N' AND
                      x_ci_cost_version_id_tbl(i) IS NOT NULL THEN

                        NULL;

                   ELSE

                     IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Implementation of cost or revenue alone is not allowed into a target ALL version';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                     END IF;
                     IF p_context = 'IMPL_FIN_IMPACT' THEN

                          PA_UTILS.ADD_MESSAGE
                          (p_app_short_name => 'PA',
                           p_msg_name       => 'PA_FP_ALL_CO_REQ_FOR_ALL_PT',
                           p_token1         => 'PLAN_TYPE',
                           p_value1         =>  l_fin_plan_type_name_tbl(j));

                     ELSIF p_context = 'INCLUDE' THEN

                          PA_UTILS.ADD_MESSAGE
                          (p_app_short_name => 'PA',
                           p_msg_name       => 'PA_FP_ALL_CO_REQ_FOR_VER');

                          /*SELECT cit.name INTO l_ci_name
                          FROM  pa_control_items pci, pa_ci_types_tl cit
                          WHERE pci.ci_id= x_ci_id_tbl(i)
                          AND  pci.ci_type_id=cit.ci_type_id
                          AND cit.language=userenv('LANG');

                          l_ci_name := l_ci_name ||' ('|| x_ci_number(i) || ')';

                          IF l_cost_impl_flag <> 'Y' THEN

                              PA_UTILS.ADD_MESSAGE
                              (p_app_short_name => 'PA',
                               p_msg_name       => 'PA_FP_NO_REV_INTO_TRG_ALL_CO',
                               p_token1         => 'CHG_ORDER',
                               p_value1         =>  l_ci_name);

                          ELSE

                              PA_UTILS.ADD_MESSAGE
                              (p_app_short_name => 'PA',
                               p_msg_name       => 'PA_FP_NO_COST_INTO_TRG_ALL_CO',
                               p_token1         => 'CHG_ORDER',
                               p_value1         =>  l_ci_name);

                          END IF;*/

                     END IF;

                     l_part_impl_err := 'Y';

                END IF;

              END IF;

                IF l_part_impl_err = 'N' THEN
                     IF NVL(x_ci_cost_version_id_tbl(i),-1)<>-1  AND l_cost_impl_flag = 'Y' THEN

                         l_source_version_id_tbl.EXTEND(1);
                         l_cost_ci_ver_index:=l_source_version_id_tbl.COUNT;
                         l_source_version_id_tbl(l_source_version_id_tbl.COUNT):=x_ci_cost_version_id_tbl(i);

                     END IF;

                     IF NVL(x_ci_rev_version_id_tbl(i),-1)<>-1   AND l_rev_impl_flag IN ('Y','R') THEN -- Bug 3732446 : Need to consider l_rev_impl_flag = 'R' also

                         l_source_version_id_tbl.EXTEND(1);
                         l_rev_ci_ver_index:=l_source_version_id_tbl.COUNT;
                         l_source_version_id_tbl(l_source_version_id_tbl.COUNT):=x_ci_rev_version_id_tbl(i);

                     END IF;

                     IF NVL(x_ci_all_version_id_tbl(i),-1)<>-1  AND
                        (l_cost_impl_flag = 'Y' OR l_rev_impl_flag IN ('Y','R') )THEN -- Bug 3732446 : Need to consider l_rev_impl_flag = 'R' also

                         l_source_version_id_tbl.EXTEND(1);
                         l_all_ci_ver_index:=l_source_version_id_tbl.COUNT;
                         l_source_version_id_tbl(l_source_version_id_tbl.COUNT):=x_ci_all_version_id_tbl(i);

                     END IF;

                     IF l_debug_mode = 'Y' THEN

                         pa_debug.g_err_stage:= 'Calling fp_ci_check_merge_possible';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                     END IF;

                     IF l_source_version_id_tbl.COUNT>0 THEN

                         IF l_debug_mode = 'Y' THEN
                             pa_debug.g_err_stage:= 'calling  fp_ci_check_merge_possible';
                             pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                         END IF;

                         pa_fp_control_items_utils.fp_ci_check_merge_possible(
                                      p_project_id               => l_project_id
                                     ,p_source_fp_version_id_tbl => l_source_version_id_tbl
                                     ,p_target_fp_version_id     => x_budget_version_id_tbl(j)
                                     ,p_calling_mode             => l_calling_mode_for_chk_api
                                     ,x_merge_possible_code_tbl  => l_merge_possible_code_tbl
                                     ,x_return_status            => x_return_status
                                     ,x_msg_count                => x_msg_count
                                     ,x_msg_data                 => x_msg_data );
                     END IF;

                     -- Return status check is not/should not be done since it would be E if merge is not possble.!

                     --Populate the record type tbl x_budget_ci_map_rec_tbl with the impact of the ci_id that can be
                     --implemented into the target budget version id
                     l_implementable_impact := 'NONE';
                     IF NVL(x_ci_cost_version_id_tbl(i),-1)<>-1  AND l_cost_impl_flag = 'Y' THEN

                         IF l_merge_possible_code_tbl(l_cost_ci_ver_index)='Y' THEN
                             l_implementable_impact:='COST';
                         END IF;

                         --Bug 5845142. This code should never get executed.
                         IF NVL(x_ci_rev_version_id_tbl(i),-1)=-1 AND l_rev_impl_flag ='Y' THEN
                             l_implementable_impact:='BOTH';
                         END IF;

                     END IF;

                     IF NVL(x_ci_rev_version_id_tbl(i),-1)<>-1   AND l_rev_impl_flag IN ('Y','R') THEN -- Bug 3732446 : Need to consider l_rev_impl_flag = 'R' also

                         IF l_merge_possible_code_tbl(l_rev_ci_ver_index)='Y' THEN

                             IF l_implementable_impact='COST' THEN
                                 --The COST impact is implementable. Since REVENUE is also implementable now
                                 --the implementation code will be BOTH now
                                 l_implementable_impact:='BOTH';
                             ELSE
                                 l_implementable_impact:='REVENUE';
                             END IF;

                         END IF;

                     END IF;

                     IF NVL(x_ci_all_version_id_tbl(i),-1)<>-1  AND
                        (l_cost_impl_flag = 'Y' OR l_rev_impl_flag IN ('Y','R') )THEN -- Bug 3732446 : Need to consider l_rev_impl_flag = 'R' also

                         IF l_merge_possible_code_tbl(l_all_ci_ver_index)='Y' THEN
                             l_implementable_impact:='ALL';
                         END IF;

                     END IF;
                END IF;

                l_index:= l_index+1;
                -- Prevent the implementation of only cost or revenue into an all version
                IF l_part_impl_err = 'Y' THEN
                    l_implementable_impact := 'NONE';
                END IF;

                --Record this impact in the output plsql tbl used for mapping the budget version id and ci id
                IF l_debug_mode = 'Y' THEN

                    pa_debug.g_err_stage:= 'About to assign to the rec type';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                END IF;

                x_budget_ci_map_rec_tbl(l_index).budget_version_id:=x_budget_version_id_tbl(j);
                x_budget_ci_map_rec_tbl(l_index).ci_id:=x_ci_id_tbl(i);
                x_budget_ci_map_rec_tbl(l_index).impact_type_code:=l_implementable_impact;
                x_budget_ci_map_rec_tbl(l_index).impl_cost_flag:=l_cost_impl_flag;
                x_budget_ci_map_rec_tbl(l_index).impl_rev_flag:=l_rev_impl_flag;

            END LOOP;--Budget version loop

        END LOOP;--ci Loop

    END IF;--IF x_ci_id_tbl.COUNT>0 AND  x_budget_version_id_tbl.COUNT>0 THEN

    --dbms_output.put_line('8');
    IF l_debug_mode = 'Y' THEN

        pa_debug.g_err_stage:= 'Exiting validate_ci_merge_input_data';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

    END IF;

    --Round the Partial revenue amount based on the agreement currency.
    IF p_context='PARTIAL_REV' AND px_partial_impl_rev_amt <> 0 THEN

        SELECT agreement_currency_code
        INTO   l_agr_curr_code
        FROM   pa_agreements_all
        WHERE  agreement_id=x_agreement_id;

        px_partial_impl_rev_amt :=Pa_currency.round_trans_currency_amt1(px_partial_impl_rev_amt,
                                                                        l_agr_curr_code);

    END IF;

    -- For Bug 3855500
    IF p_context='CI_MERGE' THEN
         l_msg_count_at_end := fnd_msg_pub.count_msg;
         IF l_init_msg_count <> l_msg_count_at_end THEN

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

        ELSE

            x_return_status:='S';

        END IF;
    ELSE

         --This is required as the x_return_status can be reset by the APIs being called from this API. The return status
         --will be E when the Invalid_Args_Exception is thrown and in this case the processing will be stopped
         x_return_status := 'S' ;
    END IF;

 IF p_pa_debug_mode = 'Y' THEN
    pa_debug.reset_curr_function;
 END IF;
    --dbms_output.put_line('9');

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
 IF p_pa_debug_mode = 'Y' THEN
        pa_debug.reset_curr_function;
END IF;
    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FP_CI_MERGE'
                          ,p_procedure_name  => 'validate_ci_merge_input_data');

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
           pa_debug.reset_curr_function;
    END IF;
     RAISE;

END validate_ci_merge_input_data;


/*--------------------------------------------------------------------------------------------------------
 * Bug 3877815: New procedure introduced, to be called for merge of CIs for auto baseline enabled projects
 * This api does the followings:
 *   i. Copies the CI links of the current working version from the pa_fp_merged_ctrl_items(if there is any
 *      record present for that version) to temporary nested pl/sql tables.
 *  ii. Call is made to pa_fp_ci_implement_pkg.create_ci_impact_fund_lines and pa_baseline_funding_pkg.change_management_baseline.
 * iii. Insert 2 records into pa_fp_merged_ctrl_items for newly created current working version and the
 *      baselied version with all the attributes of the record stored in the nested tables except the
 *      inclusion_method_code, which would be 'COPIED' for the current working version and 'AUTOMATIC' for the baselined version.
 *  iv. Call is made to pa_fp_ci_merge.FP_CI_UPDATE_IMPACT.
 *--------------------------------------------------------------------------------------------------------*/

PROCEDURE impl_ci_into_autobaseline_proj( p_ci_id                     IN     Pa_control_items.ci_id%TYPE --  The Id of the chg doc that needs to be implemented
                                         ,p_ci_rev_version_id         IN     Pa_budget_versions.budget_version_id%TYPE  DEFAULT  NULL -- The rev budget version id corresponding to the p_ci_id passed. This will be derived internally if not passed
                                         ,p_budget_version_id         IN     Pa_budget_versions.budget_version_id%TYPE -- The Id of the  budget version into which the CO needs to be implemented
                                         ,p_fin_plan_type_id          IN     pa_fin_plan_types_b.fin_plan_type_id%TYPE
                                         ,p_partial_impl_rev_amt      IN     NUMBER    DEFAULT  NULL -- The revenue amount that should be implemented into the target. This will be passed only in the case of partial implementation
                                         ,p_agreement_id              IN     Pa_agreements_all.agreement_id%TYPE  DEFAULT  NULL -- The id of the agreement that is linked with the CO.
                                         ,p_update_agreement_amt_flag IN     VARCHAR2  DEFAULT  NULL -- Indicates whether to  update the agreement amt or not. Null is considered as N
                                         ,p_funding_category          IN     VARCHAR2  DEFAULT  NULL -- The funding category for the agreement
                                         ,x_return_status             OUT    NOCOPY VARCHAR2 -- Indicates the exit status of the API --File.Sql.39 bug 4440895
                                         ,x_msg_data                  OUT    NOCOPY VARCHAR2 -- Indicates the error occurred --File.Sql.39 bug 4440895
                                         ,x_msg_count                 OUT    NOCOPY NUMBER)  -- Indicates the number of error messages --File.Sql.39 bug 4440895
IS
      --Start of variables used for debugging
      l_msg_count                        NUMBER :=0;
      l_data                             VARCHAR2(2000);
      l_msg_data                         VARCHAR2(2000);
      l_error_msg_code                   VARCHAR2(30);
      l_msg_index_out                    NUMBER;
      l_return_status                    VARCHAR2(2000);
      l_debug_mode                       VARCHAR2(30);
      l_module_name                      VARCHAR2(100):='PAFPCIMB.impl_ci_into_autobaseline_proj';
      l_debug_level5                     NUMBER := 5;
      --End of variables used for debugging

      l_project_id_tbl                   SYSTEM.PA_NUM_TBL_TYPE  := SYSTEM.PA_NUM_TBL_TYPE();
      l_plan_version_id_tbl              SYSTEM.PA_NUM_TBL_TYPE  := SYSTEM.PA_NUM_TBL_TYPE();
      l_ci_id_tbl                        SYSTEM.PA_NUM_TBL_TYPE  := SYSTEM.PA_NUM_TBL_TYPE();
      l_ci_plan_ver_id_tbl               SYSTEM.PA_NUM_TBL_TYPE  := SYSTEM.PA_NUM_TBL_TYPE();
      l_record_ver_number_tbl            SYSTEM.PA_NUM_TBL_TYPE  := SYSTEM.PA_NUM_TBL_TYPE();
      l_creation_date_tbl                SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE();
      l_created_by_tbl                   SYSTEM.PA_NUM_TBL_TYPE  := SYSTEM.PA_NUM_TBL_TYPE();
      l_last_update_login_tbl            SYSTEM.PA_NUM_TBL_TYPE  := SYSTEM.PA_NUM_TBL_TYPE();
      l_last_updated_by_tbl              SYSTEM.PA_NUM_TBL_TYPE  := SYSTEM.PA_NUM_TBL_TYPE();
      l_last_update_date_tbl             SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE();
      l_incl_method_code_tbl             SYSTEM.PA_VARCHAR2_30_TBL_TYPE :=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_incl_by_person_id_tbl            SYSTEM.PA_NUM_TBL_TYPE  :=SYSTEM.PA_NUM_TBL_TYPE();
      l_version_type_tbl                 SYSTEM.PA_VARCHAR2_30_TBL_TYPE :=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_impl_proj_func_raw_cost_tbl      SYSTEM.PA_NUM_TBL_TYPE  := SYSTEM.PA_NUM_TBL_TYPE();
      l_impl_proj_func_burd_cost_tbl     SYSTEM.PA_NUM_TBL_TYPE  := SYSTEM.PA_NUM_TBL_TYPE();
      l_impl_proj_func_revenue_tbl       SYSTEM.PA_NUM_TBL_TYPE  := SYSTEM.PA_NUM_TBL_TYPE();
      l_impl_proj_raw_cost_tbl           SYSTEM.PA_NUM_TBL_TYPE  := SYSTEM.PA_NUM_TBL_TYPE();
      l_impl_proj_burd_cost_tbl          SYSTEM.PA_NUM_TBL_TYPE  := SYSTEM.PA_NUM_TBL_TYPE();
      l_impl_proj_revenue_tbl            SYSTEM.PA_NUM_TBL_TYPE  := SYSTEM.PA_NUM_TBL_TYPE();
      l_impl_quantity_tbl                SYSTEM.PA_NUM_TBL_TYPE  := SYSTEM.PA_NUM_TBL_TYPE();
      l_impl_equipment_quant_tbl         SYSTEM.PA_NUM_TBL_TYPE  := SYSTEM.PA_NUM_TBL_TYPE();
      l_impl_agr_revenue_tbl             SYSTEM.PA_NUM_TBL_TYPE  := SYSTEM.PA_NUM_TBL_TYPE();

      l_project_id                       pa_projects_all.project_id%TYPE;

      --Variable used for passing ci id to the change management baseline API.
      l_CI_ID_Tab                        PA_PLSQL_DATATYPES.IdTabTyp;
      X_Err_Code                         NUMBER;

      l_new_cw_version_id                pa_budget_versions.budget_version_id%TYPE;
      l_baseline_version_id              pa_budget_versions.budget_version_id%TYPE;
      l_fp_options_id                    pa_proj_fp_options.proj_fp_options_id%TYPE;
      -- Variable to be used for calling FP_CI_LINK_CONTROL_ITEMS
      l_rev_ppl_quantity                 NUMBER;
      l_rev_equip_quantity               NUMBER;
      l_impl_pfc_revenue                 NUMBER;
      l_impl_pc_revenue                  NUMBER;

      -- variables to hold the amounts before merge and after merge
      l_rev_ppl_quantity_bf_mg           NUMBER;
      l_rev_equip_quantity_bf_mg         NUMBER;
      l_impl_pfc_revenue_bf_mg           NUMBER;
      l_impl_pc_revenue_bf_mg            NUMBER;

      l_rev_ppl_quantity_af_mg           NUMBER;
      l_rev_equip_quantity_af_mg         NUMBER;
      l_impl_pfc_revenue_af_mg           NUMBER;
      l_impl_pc_revenue_af_mg            NUMBER;

      -- Variables used for partial revenue implementation
      l_partial_factor                   NUMBER;
      l_total_amount                     NUMBER;
      l_total_amount_in_pfc              NUMBER;
      l_total_amount_in_pc               NUMBER;
      l_impl_pc_rev_amt                  NUMBER;
      l_impl_pfc_rev_amt                 NUMBER;
      l_implemented_amt                  NUMBER := 0;
      l_implemented_pc_amt               NUMBER;
      l_implemented_pfc_amt              NUMBER;
      l_project_currency_code            pa_projects_all.project_currency_code%TYPE;
      l_projfunc_currency_code           pa_projects_all.project_currency_code%TYPE;
      l_ci_already_impl_flag             VARCHAR2(1) := 'N';

      l_final_rev_par_impl_flag          pa_budget_versions.rev_partially_impl_flag%TYPE;
      --Bug 4136238
      l_partial_impl_rev_amt             pa_budget_lines.txn_revenue%TYPE;

BEGIN
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_pa_debug_mode = 'Y' THEN
      PA_DEBUG.Set_Curr_Function( p_function   => l_module_name,
                                  p_debug_mode => l_debug_mode );

     END IF;
      FND_MSG_PUB.initialize;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Entering impl_ci_into_autobaseline_proj';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            pa_debug.g_err_stage:= 'Copying data from pa_fp_merged_ctrl_items';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      SELECT
      project_id,
      plan_version_id,
      ci_id,
      ci_plan_version_id,
      record_version_number,
      creation_date,
      created_by,
      last_update_login,
      last_updated_by,
      last_update_date,
      inclusion_method_code,
      included_by_person_id,
      version_type,
      impl_proj_func_raw_cost,
      impl_proj_func_burdened_cost,
      impl_proj_func_revenue,
      impl_proj_raw_cost,
      impl_proj_burdened_cost,
      impl_proj_revenue,
      impl_quantity,
      impl_equipment_quantity,
      impl_agr_revenue
      BULK COLLECT INTO
      l_project_id_tbl,
      l_plan_version_id_tbl,
      l_ci_id_tbl,
      l_ci_plan_ver_id_tbl,
      l_record_ver_number_tbl,
      l_creation_date_tbl,
      l_created_by_tbl,
      l_last_update_login_tbl,
      l_last_updated_by_tbl,
      l_last_update_date_tbl,
      l_incl_method_code_tbl,
      l_incl_by_person_id_tbl,
      l_version_type_tbl,
      l_impl_proj_func_raw_cost_tbl,
      l_impl_proj_func_burd_cost_tbl,
      l_impl_proj_func_revenue_tbl,
      l_impl_proj_raw_cost_tbl,
      l_impl_proj_burd_cost_tbl,
      l_impl_proj_revenue_tbl,
      l_impl_quantity_tbl,
      l_impl_equipment_quant_tbl,
      l_impl_agr_revenue_tbl
      FROM   pa_fp_merged_ctrl_items
      WHERE  plan_version_id = p_budget_version_id;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Copy from pa_fp_merged_ctrl_items done';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            pa_debug.g_err_stage:= 'No. of records copied: ' || l_plan_version_id_tbl.COUNT;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Checking if the CI has been implemented before';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      --Bug 4153570.
      l_implemented_pc_amt :=0;
      l_implemented_pfc_amt := 0;

      IF l_plan_version_id_tbl.COUNT > 0 THEN
             FOR i IN l_plan_version_id_tbl.FIRST .. l_plan_version_id_tbl.LAST
             LOOP
                  IF l_ci_id_tbl(i) = p_ci_id AND
                     l_version_type_tbl(i) = 'REVENUE' THEN
                          l_ci_already_impl_flag := 'Y';
                          l_implemented_amt := l_impl_agr_revenue_tbl(i);
                          l_implemented_pc_amt := l_impl_proj_revenue_tbl(i);
                          l_implemented_pfc_amt := l_impl_proj_func_revenue_tbl(i);
                          EXIT;
                  END IF;
             END LOOP;
      END IF;
      l_implemented_amt := nvl(l_implemented_amt,0);

      IF l_ci_already_impl_flag = 'Y'THEN
            IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:= 'The CI has been implemented before';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;
      ELSE
            IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:= 'The CI has NOT been implemented before';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;
      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Getting the amounts of budget version before merge';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;


      SELECT Nvl(pbv.labor_quantity, 0),
             Nvl(pbv.equipment_quantity, 0),
             Nvl(pbv.revenue, 0),
             Nvl(pbv.total_project_revenue, 0),
             pbv.project_id,
             p.project_currency_code,
             p.projfunc_currency_code
      INTO   l_rev_ppl_quantity_bf_mg,
             l_rev_equip_quantity_bf_mg,
             l_impl_pfc_revenue_bf_mg,
             l_impl_pc_revenue_bf_mg,
             l_project_id,
             l_project_currency_code,
             l_projfunc_currency_code
      FROM   pa_budget_versions pbv,
             pa_projects_all p
      WHERE  pbv.project_id = p.project_id
      AND    pbv.budget_version_id = p_budget_version_id;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Deriving l_partial_factor';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      --Bug 4136238. Find out the total amounts for CI in pc/pfc/txn amounts. This will be used in deriving the amounts
      --that will be finally implemented.
      SELECT nvl(sum(txn_revenue),0) total_amt
            ,nvl(sum(revenue),0)  total_amt_in_pfc
            ,nvl(sum(project_revenue),0) total_amt_in_pc
      INTO   l_total_amount,
             l_total_amount_in_pfc,
             l_total_amount_in_pc
      FROM   pa_budget_lines
      WHERE  budget_version_id = p_ci_rev_version_id;

      --Bug 4136238. p_partial_impl_rev_amt will be NULL or 0 only if the full impact is being implemented. In this
      --funding lines should be created for the whole amount in the CI version.
      IF p_partial_impl_rev_amt IS NULL OR
         p_partial_impl_rev_amt = 0 THEN
            l_partial_factor := 1;
            l_partial_impl_rev_amt := l_total_amount;
            l_impl_pc_rev_amt := l_total_amount_in_pc;
            l_impl_pfc_rev_amt := l_total_amount_in_pfc;

      ELSE
            --This means that the total revenue amount for implementation is also 0 . It could be that
            --BLs exist with +ve and -ve amounts with the total sum being 0.
            IF l_total_amount = 0 THEN
                 l_partial_factor := 1;
                 l_impl_pc_rev_amt := l_total_amount_in_pc;
                 l_impl_pfc_rev_amt := l_total_amount_in_pfc;
            ELSE
                 l_partial_factor := p_partial_impl_rev_amt/(l_total_amount);

                 --In case of last implementation i.e. all the amount that is left is being implemented, the pc/pfc amounts
                 --should be the <total amount> -<amount already implemented>
                 IF Nvl(l_implemented_amt, 0) + p_partial_impl_rev_amt = l_total_amount THEN

                     l_impl_pc_rev_amt := l_total_amount_in_pc - l_implemented_pc_amt;
                     l_impl_pfc_rev_amt := l_total_amount_in_pfc - l_implemented_pfc_amt;

                 ELSE

                     l_impl_pc_rev_amt := Pa_currency.round_trans_currency_amt1(l_total_amount_in_pc * l_partial_factor,
                                                                                l_project_currency_code);
                     l_impl_pfc_rev_amt :=Pa_currency.round_trans_currency_amt1(l_total_amount_in_pfc * l_partial_factor,
                                                                                l_projfunc_currency_code);
                 END IF;
            END IF;
            --Bug 4136238
            l_partial_impl_rev_amt := p_partial_impl_rev_amt;
      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'l_partial_factor derivation done and is: ' || l_partial_factor;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;


      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Got the amounts of budget version before merge';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            pa_debug.g_err_stage:= 'Calling pa_fp_ci_implement_pkg.create_ci_impact_fund_lines';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      pa_fp_ci_implement_pkg.create_ci_impact_fund_lines
                        (p_project_id             => l_project_id,
                         p_ci_id                  => p_ci_id,
                         p_update_agr_amount_flag => P_update_agreement_amt_flag,
                         p_funding_category       => p_funding_category,
                         p_partial_factor         => l_partial_factor,
                         p_impl_txn_rev_amt       => l_partial_impl_rev_amt,
                         p_impl_pc_rev_amt        => l_impl_pc_rev_amt,
                         p_impl_pfc_rev_amt       => l_impl_pfc_rev_amt,
                         x_msg_data               => l_msg_data,
                         x_msg_count              => l_msg_count,
                         x_return_status          => l_return_status);

                         IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                              IF P_PA_debug_mode = 'Y' THEN
                                 pa_debug.g_err_stage:= 'Error in create_ci_impact_fund_lines';
                                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                              END IF;
                              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                         END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Call to pa_fp_ci_implement_pkg.create_ci_impact_fund_lines done';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Calling pa_baseline_funding_pkg.change_management_baseline';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      l_CI_ID_Tab.delete;
      l_CI_ID_Tab(1):=p_ci_id;

      pa_baseline_funding_pkg.change_management_baseline
                         (P_Project_ID   => l_project_id,
                          P_CI_ID_Tab    => l_CI_ID_Tab,
                          X_Err_Code     => X_Err_Code,
                          X_Status       => l_return_status);

                         IF X_Err_Code <>  0 THEN
                              IF P_PA_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage:= 'Error in change_management_baseline';
                                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                              END IF;
                              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                         END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Call to pa_baseline_funding_pkg.change_management_baseline done';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Deriving new budget version ids';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      /* Calling the following apis with hard coded version_type as this api would be
       * only called for merge of revenue impacts into the revenue current working/baselined
       * versions of an autobaselined enabled project
       */
      pa_fin_plan_utils.Get_Curr_Working_Version_Info
                           (p_project_id          => l_project_id
                           ,p_fin_plan_type_id    => p_fin_plan_type_id
                           ,p_version_type        => 'REVENUE'
                           ,x_fp_options_id       => l_fp_options_id
                           ,x_fin_plan_version_id => l_new_cw_version_id
                           ,x_return_status       => l_return_status
                           ,x_msg_count           => l_msg_count
                           ,x_msg_data            => l_msg_data);

                           IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                              IF P_PA_debug_mode = 'Y' THEN
                                 pa_debug.g_err_stage:= 'Error in Get_Curr_Working_Version_Info';
                                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                              END IF;
                              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                         END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'New current working version id' || l_new_cw_version_id ;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      pa_fin_plan_utils.Get_Baselined_Version_Info
                           (p_project_id          => l_project_id
                           ,p_fin_plan_type_id    => p_fin_plan_type_id
                           ,p_version_type        => 'REVENUE'
                           ,x_fp_options_id       => l_fp_options_id
                           ,x_fin_plan_version_id => l_baseline_version_id
                           ,x_return_status       => l_return_status
                           ,x_msg_count           => l_msg_count
                           ,x_msg_data            => l_msg_data);

                           IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                              IF P_PA_debug_mode = 'Y' THEN
                                 pa_debug.g_err_stage:= 'Error in Get_Baselined_Version_Info';
                                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                              END IF;
                              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                           END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'New baseline version id' || l_baseline_version_id ;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      IF l_plan_version_id_tbl.COUNT > 0 THEN
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Inserting into pa_fp_merged_ctrl_items with old data';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;
            -- For the current working version
            FORALL i IN l_plan_version_id_tbl.FIRST .. l_plan_version_id_tbl.LAST
                  INSERT  INTO pa_fp_merged_ctrl_items
                          (project_id,
                          plan_version_id,
                          ci_id,
                          ci_plan_version_id,
                          record_version_number,
                          creation_date,
                          created_by,
                          last_update_login,
                          last_updated_by,
                          last_update_date,
                          inclusion_method_code,
                          included_by_person_id,
                          version_type,
                          impl_proj_func_raw_cost,
                          impl_proj_func_burdened_cost,
                          impl_proj_func_revenue,
                          impl_proj_raw_cost,
                          impl_proj_burdened_cost,
                          impl_proj_revenue,
                          impl_quantity,
                          impl_equipment_quantity,
                          impl_agr_revenue)
                  VALUES (l_project_id_tbl(i),
                          l_new_cw_version_id, -- The new current working version id
                          l_ci_id_tbl(i),
                          l_ci_plan_ver_id_tbl(i),
                          1, -- Bug 3877815: Review comment
                          l_creation_date_tbl(i),
                          l_created_by_tbl(i),
                          FND_GLOBAL.login_id,
                          FND_GLOBAL.user_id,
                          SYSDATE,
                          l_incl_method_code_tbl(i),
                          l_incl_by_person_id_tbl(i),
                          l_version_type_tbl(i),
                          l_impl_proj_func_raw_cost_tbl(i),
                          l_impl_proj_func_burd_cost_tbl(i),
                          l_impl_proj_func_revenue_tbl(i),
                          l_impl_proj_raw_cost_tbl(i),
                          l_impl_proj_burd_cost_tbl(i),
                          l_impl_proj_revenue_tbl(i),
                          l_impl_quantity_tbl(i),
                          l_impl_equipment_quant_tbl(i),
                          l_impl_agr_revenue_tbl(i));

            -- For the baseline version

            FORALL i IN l_plan_version_id_tbl.FIRST .. l_plan_version_id_tbl.LAST
                  INSERT  INTO pa_fp_merged_ctrl_items
                          (project_id,
                          plan_version_id,
                          ci_id,
                          ci_plan_version_id,
                          record_version_number,
                          creation_date,
                          created_by,
                          last_update_login,
                          last_updated_by,
                          last_update_date,
                          inclusion_method_code,
                          included_by_person_id,
                          version_type,
                          impl_proj_func_raw_cost,
                          impl_proj_func_burdened_cost,
                          impl_proj_func_revenue,
                          impl_proj_raw_cost,
                          impl_proj_burdened_cost,
                          impl_proj_revenue,
                          impl_quantity,
                          impl_equipment_quantity,
                          impl_agr_revenue)
                  VALUES (l_project_id_tbl(i),
                          l_baseline_version_id, -- The baseline version id
                          l_ci_id_tbl(i),
                          l_ci_plan_ver_id_tbl(i),
                          1,
                          SYSDATE,
                          FND_GLOBAL.user_id,
                          FND_GLOBAL.login_id,
                          FND_GLOBAL.user_id,
                          SYSDATE,
                          'AUTOMATIC', -- Bug 3877815: Review comment
                          l_incl_by_person_id_tbl(i),
                          l_version_type_tbl(i),
                          l_impl_proj_func_raw_cost_tbl(i),
                          l_impl_proj_func_burd_cost_tbl(i),
                          l_impl_proj_func_revenue_tbl(i),
                          l_impl_proj_raw_cost_tbl(i),
                          l_impl_proj_burd_cost_tbl(i),
                          l_impl_proj_revenue_tbl(i),
                          l_impl_quantity_tbl(i),
                          l_impl_equipment_quant_tbl(i),
                          l_impl_agr_revenue_tbl(i));
      ELSE
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'No Data stored in tmp tables';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;
      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Getting the amounts after merge for the budget version';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      SELECT Nvl(labor_quantity, 0),
             Nvl(equipment_quantity, 0),
             Nvl(revenue, 0),
             Nvl(total_project_revenue, 0),
             Nvl(rev_partially_impl_flag, 'N')
      INTO   l_rev_ppl_quantity_af_mg,
             l_rev_equip_quantity_af_mg,
             l_impl_pfc_revenue_af_mg,
             l_impl_pc_revenue_af_mg,
             l_final_rev_par_impl_flag
      FROM   pa_budget_versions
      WHERE  project_id = l_project_id
      AND    budget_version_id = l_new_cw_version_id;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Values obtained after merge for the budget version';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            pa_debug.g_err_stage:= 'Getting the diff of amounts before and after merge for the budget version';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      l_rev_ppl_quantity   := l_rev_ppl_quantity_af_mg - l_rev_ppl_quantity_bf_mg;
      l_rev_equip_quantity := l_rev_equip_quantity_af_mg - l_rev_equip_quantity_bf_mg;
      l_impl_pfc_revenue   := l_impl_pfc_revenue_af_mg - l_impl_pfc_revenue_bf_mg;
      l_impl_pc_revenue    := l_impl_pc_revenue_af_mg - l_impl_pc_revenue_bf_mg;

      IF l_ci_already_impl_flag = 'Y' THEN
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Updating record if there is a record for the CI';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;

            -- For Current working version
            UPDATE pa_fp_merged_ctrl_items
            SET    impl_proj_func_revenue  = (Nvl(impl_proj_func_revenue,0) + l_impl_pfc_revenue),
                   impl_proj_revenue       = (Nvl(impl_proj_revenue,0) + l_impl_pc_revenue),
                   impl_quantity           = (Nvl(impl_quantity,0) + l_rev_ppl_quantity),
                   impl_equipment_quantity = (Nvl(impl_equipment_quantity,0) + l_rev_equip_quantity),
                   impl_agr_revenue        = (Nvl(l_implemented_amt,0) + Nvl(l_partial_impl_rev_amt,0)),
                   record_version_number   = (Nvl(record_version_number, 0) + 1),
                   last_update_login       = FND_GLOBAL.login_id,
                   last_updated_by         = FND_GLOBAL.user_id,
                   last_update_date        = SYSDATE
            WHERE  project_id = l_project_id
            AND    ci_id = p_ci_id
            AND    plan_version_id = l_new_cw_version_id
            AND    version_type = 'REVENUE';

             -- For baselined version
            UPDATE pa_fp_merged_ctrl_items
            SET    impl_proj_func_revenue  = (Nvl(impl_proj_func_revenue,0) + l_impl_pfc_revenue),
                   impl_proj_revenue       = (Nvl(impl_proj_revenue,0) + l_impl_pc_revenue),
                   impl_quantity           = (Nvl(impl_quantity,0) + l_rev_ppl_quantity),
                   impl_equipment_quantity = (Nvl(impl_equipment_quantity,0) + l_rev_equip_quantity),
                   impl_agr_revenue        = (Nvl(l_implemented_amt,0) + Nvl(l_partial_impl_rev_amt,0)),
                   record_version_number   = (Nvl(record_version_number, 0) + 1),
                   last_update_login       = FND_GLOBAL.login_id,
                   last_updated_by         = FND_GLOBAL.user_id,
                   last_update_date        = SYSDATE
            WHERE  project_id = l_project_id
            AND    ci_id = p_ci_id
            AND    plan_version_id = l_baseline_version_id
            AND    version_type = 'REVENUE';

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Updation of record is done for the CI';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;

      ELSE -- There is no record present in pa_fp_merged_ctrl_items for the ci_id
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Calling FP_CI_LINK_CONTROL_ITEMS for the CI which has been merged';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;
            -- For the current working version
            FP_CI_LINK_CONTROL_ITEMS
              (
                p_project_id         => l_project_id
               ,p_s_fp_version_id    => p_ci_rev_version_id
               ,p_t_fp_version_id    => l_new_cw_version_id
               ,p_inclusion_method   => 'COPIED'
               ,p_included_by        => NULL
               ,p_version_type       => 'REVENUE'
               ,p_ci_id              => p_ci_id
               ,p_cost_ppl_qty       => NULL
               ,p_rev_ppl_qty        => l_rev_ppl_quantity
               ,p_cost_equip_qty     => NULL
               ,p_rev_equip_qty      => l_rev_equip_quantity
               ,p_impl_pfc_raw_cost  => NULL
               ,p_impl_pfc_revenue   => l_impl_pfc_revenue
               ,p_impl_pfc_burd_cost => NULL
               ,p_impl_pc_raw_cost   => NULL
               ,p_impl_pc_revenue    => l_impl_pc_revenue
               ,p_impl_pc_burd_cost  => NULL
               ,p_impl_agr_revenue   => Nvl(l_partial_impl_rev_amt,0) --Bug 3877815: Review comment
               ,x_return_status      => l_return_status
               ,x_msg_count          => l_msg_count
               ,x_msg_data           => l_msg_data);

              IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
                    IF l_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:= 'Error calling FP_CI_LINK_CONTROL_ITEMS';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                    END IF;
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
              END IF;

              -- For the baseline version
            FP_CI_LINK_CONTROL_ITEMS
              (
                p_project_id         => l_project_id
               ,p_s_fp_version_id    => p_ci_rev_version_id
               ,p_t_fp_version_id    => l_baseline_version_id
               ,p_inclusion_method   => 'AUTOMATIC'
               ,p_included_by        => NULL
               ,p_version_type       => 'REVENUE'
               ,p_ci_id              => p_ci_id
               ,p_cost_ppl_qty       => NULL
               ,p_rev_ppl_qty        => l_rev_ppl_quantity
               ,p_cost_equip_qty     => NULL
               ,p_rev_equip_qty      => l_rev_equip_quantity
               ,p_impl_pfc_raw_cost  => NULL
               ,p_impl_pfc_revenue   => l_impl_pfc_revenue
               ,p_impl_pfc_burd_cost => NULL
               ,p_impl_pc_raw_cost   => NULL
               ,p_impl_pc_revenue    => l_impl_pc_revenue
               ,p_impl_pc_burd_cost  => NULL
               ,p_impl_agr_revenue   => Nvl(l_partial_impl_rev_amt,0) --Bug 3877815: Review comment
               ,x_return_status      => l_return_status
               ,x_msg_count          => l_msg_count
               ,x_msg_data           => l_msg_data);

               IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
                     IF l_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage:= 'Error calling FP_CI_LINK_CONTROL_ITEMS';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                     END IF;
                     RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
               END IF;

               IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:= 'Call to FP_CI_LINK_CONTROL_ITEMS DONE';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
               END IF;
      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Calling pa_fp_ci_merge.FP_CI_UPDATE_IMPACT';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      pa_fp_ci_merge.FP_CI_UPDATE_IMPACT
                        (p_ci_id                 => p_ci_id
                        ,p_status_code           => 'CI_IMPACT_IMPLEMENTED'
                        ,p_implemented_by        => FND_GLOBAL.USER_ID
                        ,p_impact_type_code      => 'FINPLAN_REVENUE'
                        ,p_commit_flag           => 'N'
                        ,p_init_msg_list         => 'N'
                        ,p_record_version_number => null
                        ,x_return_status         => l_return_status
                        ,x_msg_count             => l_msg_count
                        ,x_msg_data              => l_msg_data);

                        IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                              IF P_PA_debug_mode = 'Y' THEN
                                 pa_debug.g_err_stage:= 'Error in FP_CI_UPDATE_IMPACT';
                                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                              END IF;
                              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                        END IF;
      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Call to pa_fp_ci_merge.FP_CI_UPDATE_IMPACT done';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;
      -- Bug 3877815: Review comment

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= '-------l_implemented_amt is: ' || l_implemented_amt;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            pa_debug.g_err_stage:= '-------l_partial_impl_rev_amt is: ' || l_partial_impl_rev_amt;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            pa_debug.g_err_stage:= '-------l_total_amount is: ' || l_total_amount;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;
      IF (Nvl(l_implemented_amt,0) + Nvl(l_partial_impl_rev_amt,0)) = l_total_amount THEN
      --setting rev impl flag to N.
           IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='Setting rev_impl_flag to N after autobaseline call';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
           END IF;
           UPDATE pa_budget_versions
           SET    rev_partially_impl_flag ='N'
                 ,record_version_number   = record_version_number+1
                 ,last_update_date        = sysdate
                 ,last_update_login       = fnd_global.login_id
                 ,last_updated_by         = fnd_global.user_id
           WHERE  budget_version_id       = p_ci_rev_version_id;

           IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='rev_impl_flag set to N ';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
           END IF;
      ELSE
           IF l_final_rev_par_impl_flag <> 'Y' THEN
               IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:='Setting rev_impl_flag to Y after autobaseline call';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
               END IF;
               UPDATE pa_budget_versions
               SET    rev_partially_impl_flag ='Y'
                     ,record_version_number   = record_version_number+1
                     ,last_update_date        = sysdate
                     ,last_update_login       = fnd_global.login_id
                     ,last_updated_by         = fnd_global.user_id
               WHERE  budget_version_id       = p_ci_rev_version_id;

               IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='rev_impl_flag set to Y ';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
               END IF;
           END IF;
      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Exiting impl_ci_into_autobaseline_proj';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      pa_debug.reset_curr_function;
    END IF;
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
     IF p_pa_debug_mode = 'Y' THEN
            pa_debug.reset_curr_function;
       END IF;
      WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count     := 1;
            x_msg_data      := SQLERRM;
            FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FP_CI_MERGE'
                                    ,p_procedure_name  => 'impl_ci_into_autobaseline_proj');

            IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
            pa_debug.reset_curr_function;
    END IF;
            RAISE;
END impl_ci_into_autobaseline_proj;

----------------------------------------------------------------------------------------------------------
--1.p_context can be PARTIAL_REV( When called from implement partial revenue page )
----IMPL_FIN_IMPACT(when called from implement financial impact page)
----INCLUDE(when called from the include change documents page)
----CI_MERGE(When called for mergind a CI into a CO/CR)
--2.p_ci_id_tbl, p_ci_cost_version_id_tbl, p_ci_rev_version_id_tbl and p_ci_all_version_id_tbl if passed should
----contain same number of records. p_ci_id_tbl is mandatory. The version ids for the ci_id will be derived if not
----passed. Either all the version ids for the CI should be passed or none of them should be passed
--3.p_fin_plan_type_id_tbl, p_fin_plan_type_name_tbl, p_impl_cost_flag_tbl, p_impl_rev_flag_tbl,
----p_submit_version_flag_tbl should contain same number of records.
----p_fin_plan_type_id_tbl,p_fin_plan_type_name_tbl contains the fin plan type id and name for the
----corresponding element in p_budget_version_id_tbl
----p_impl_cost_flag_tbl, p_impl_rev_flag_tbl can have values of Y or N. They indicate whether the cost/revenue
----impact can be implemented into the corresponding element in p_budget_version_id_tbl
----p_submit_version_flag_tbl can contain Y or N, if passed. It indicates whether the target budget version id
----should be baselined after implementation or not
--4.p_agreement_id, p_update_agreement_amt_flag, p_funding_category are related to the agreement chosen
--5.p_add_msg_to_stack lets the API know whether the error messages should be added to the fnd_msg_pub or not. If
----Y the messages will be added. They will not be added otherwise
--6.x_translated_msgs_tbl contains the translated error messages. x_translated_err_msg_count indicates the no. of
----elements in x_translated_err_msg_count. x_translated_err_msg_level indicates whether the level of the message is
----EXCEPTION, WARNING OR INFORMATION. They will be populated only if p_add_msg_to_stack is N
--7.p_commit_flag can be Y or N. This is defaulted to N. If passed as Y then the commit will be executed after
----every implementation/inclusion i.e. after one ci has got implemented into the target budget version.

--The processing goes like this
----Each ci_id will be implemented in every version id in p_budget_version_id_tbl. If p_impl_cost_flag_tbl is Y cost
----will be implemented. If p_impl_rev_flag_tbl is Y revenue will be implemented.

-- Bug 3934574 Oct 14 2004  Added a new parameter p_calling_context that would be populated when
-- called as part of budget/forecast generation

PROCEDURE implement_change_document
( p_context                         IN     VARCHAR2
 ,p_calling_context                 IN     VARCHAR2                           --DEFAULT NULL --bug 3934574
 ,p_commit_flag                     IN     VARCHAR2
 ,p_ci_id_tbl                       IN     SYSTEM.pa_num_tbl_type
 ,p_ci_cost_version_id_tbl          IN     SYSTEM.pa_num_tbl_type
 ,p_ci_rev_version_id_tbl           IN     SYSTEM.pa_num_tbl_type
 ,p_ci_all_version_id_tbl           IN     SYSTEM.pa_num_tbl_type
 ,p_fin_plan_type_id_tbl            IN     SYSTEM.pa_num_tbl_type
 ,p_fin_plan_type_name_tbl          IN     SYSTEM.pa_varchar2_150_tbl_type
 ,p_budget_version_id_tbl           IN     SYSTEM.pa_num_tbl_type
 ,p_impl_cost_flag_tbl              IN     SYSTEM.pa_varchar2_1_tbl_type
 ,p_impl_rev_flag_tbl               IN     SYSTEM.pa_varchar2_1_tbl_type
 ,p_submit_version_flag_tbl         IN     SYSTEM.pa_varchar2_1_tbl_type
 ,p_partial_impl_rev_amt            IN     NUMBER
 ,p_agreement_id                    IN     pa_agreements_all.agreement_id%TYPE
 ,p_update_agreement_amt_flag       IN     VARCHAR2
 ,p_funding_category                IN     VARCHAR2
 ,p_raTxn_rollup_api_call_flag      IN     VARCHAR2   --IPM Arch Enhancement Bug 4865563
 ,p_add_msg_to_stack                IN     VARCHAR2
 ,x_translated_msgs_tbl             OUT    NOCOPY SYSTEM.pa_varchar2_2000_tbl_type --File.Sql.39 bug 4440895
 ,x_translated_err_msg_count        OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_translated_err_msg_level_tbl    OUT    NOCOPY SYSTEM.pa_varchar2_30_tbl_type --File.Sql.39 bug 4440895
 ,x_return_status                   OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                       OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                        OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
    --Start of variables used for debugging
    l_msg_count                     NUMBER :=0;
    l_data                          VARCHAR2(2000);
    l_msg_data                      VARCHAR2(2000);
    l_error_msg_code                VARCHAR2(30);
    l_msg_index_out                 NUMBER;
    l_return_status                 VARCHAR2(2000);
    l_debug_mode                    VARCHAR2(30);
    l_module_name                   VARCHAR2(100):='PAFPCIMB.implement_change_document';
    --End of variables used for debugging

    --Variables used for getting the translated error messages
    l_msg_counter                   NUMBER;
    l_encoded_msg                   VARCHAR2(4000);
    l_decoded_msg                   VARCHAR2(4000);
    l_translated_msg                VARCHAR2(4000);

    i                               NUMBER;
    l_ci_id_tbl                     SYSTEM.pa_num_tbl_type          :=SYSTEM.pa_num_tbl_type();
    l_ci_cost_version_id_tbl        SYSTEM.pa_num_tbl_type          :=SYSTEM.pa_num_tbl_type();
    l_ci_rev_version_id_tbl         SYSTEM.pa_num_tbl_type          :=SYSTEM.pa_num_tbl_type();
    l_ci_all_version_id_tbl         SYSTEM.pa_num_tbl_type          :=SYSTEM.pa_num_tbl_type();
    l_budget_version_id_tbl         SYSTEM.pa_num_tbl_type          :=SYSTEM.pa_num_tbl_type();
    l_impl_cost_flag_tbl            SYSTEM.pa_varchar2_1_tbl_type   :=SYSTEM.pa_varchar2_1_tbl_type();
    l_impl_rev_flag_tbl             SYSTEM.pa_varchar2_1_tbl_type   :=SYSTEM.pa_varchar2_1_tbl_type();
    l_submit_version_flag_tbl       SYSTEM.pa_varchar2_1_tbl_type   :=SYSTEM.pa_varchar2_1_tbl_type();
    l_fin_plan_type_id_tbl          SYSTEM.pa_num_tbl_type          :=SYSTEM.pa_num_tbl_type();
    l_fin_plan_type_name_tbl        SYSTEM.pa_varchar2_150_tbl_type :=SYSTEM.pa_varchar2_150_tbl_type();
    l_succ_impl_plan_types          SYSTEM.pa_varchar2_150_tbl_type :=SYSTEM.pa_varchar2_150_tbl_type();
    l_succ_impl_cos                 SYSTEM.pa_varchar2_150_tbl_type :=SYSTEM.pa_varchar2_150_tbl_type();
    l_ci_number                     SYSTEM.pa_varchar2_100_tbl_type :=SYSTEM.pa_varchar2_100_tbl_type();
    l_plan_type_collection          VARCHAR2(2000);
    l_ci_number_collection          VARCHAR2(2000);
    l_partial_impl_succeeded        VARCHAR2(1);
    l_ci_bv_merge_possible_map_tbl  PA_PLSQL_DATATYPES.Char30TabTyp;
    l_index                         NUMBER;
    l_cost_ci_version_id            pa_budget_Versions.budget_version_id%TYPE;
    l_rev_ci_version_id             pa_budget_Versions.budget_version_id%TYPE;
    l_all_ci_version_id             pa_budget_Versions.budget_version_id%TYPE;
    l_budget_ci_map_rec_tbl         budget_ci_map_rec_tbl_type;
    l_impl_impact_type_code         VARCHAR2(10);
    l_agreement_id                  pa_agreements_all.agreement_id%TYPE;
    l_funding_category              VARCHAR2(30);
    l_partial_impl_rev_amt          pa_budget_lines.txn_revenue%TYPE;

    --These two variables will be used for comparing the no. of error messages in the error message stack when the
    --API called and when the API is done with the processing. If the no of messages in the two pl/sql tbls are
    --different then the error status will be returned as E from the API
    l_init_msg_count                NUMBER;
    l_msg_count_at_end              NUMBER;

    -- Bug 3877815: Additional local variables declared
    l_baseline_api_called           VARCHAR2(1);
    l_targ_app_cost_flag            VARCHAR2(1);
    l_targ_app_rev_flag             VARCHAR2(1);
    l_baseline_funding_flag         VARCHAR2(1);


BEGIN
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_init_msg_count:= FND_MSG_PUB.count_msg;
   IF p_pa_debug_mode = 'Y' THEN
    PA_DEBUG.Set_Curr_Function( p_function   => l_module_name,
                                p_debug_mode => l_debug_mode );
   END IF;
    -- For bug 3866629
    FND_MSG_PUB.initialize;

    --dbms_output.put_line('M1');

    --If p_commit_flag is N then all the changes done thru this API should be rolled back whenever an error occurs.
    --Otherwise only those changes that happened in the merge which failed will be rolled back and all other
    --successful merges will be committed.
    IF p_commit_flag ='N' THEN
        SAVEPOINT implement_change_document;
    END IF;

    IF l_debug_mode = 'Y' THEN

        pa_debug.g_err_stage:= 'Validating the input parameters';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

    END IF;

    IF p_ci_id_tbl.COUNT =0 OR
       p_budget_version_id_tbl.COUNT = 0 THEN

        IF l_debug_mode = 'Y' THEN

            pa_debug.g_err_stage:= 'p_ci_id_tbl.COUNT is '||p_ci_id_tbl.COUNT;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:= 'p_budget_version_id_tbl.COUNT is '||p_budget_version_id_tbl.COUNT;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:= 'Returning-->';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        pa_debug.reset_curr_function;
END IF;
        RETURN;

    END IF;

    IF l_debug_mode = 'Y' THEN

        pa_debug.g_err_stage:= 'Calling validate_ci_merge_input_data';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

    END IF;

    --dbms_output.put_line('M2');
     l_partial_impl_rev_amt := p_partial_impl_rev_amt;
     validate_ci_merge_input_data(
     p_context                       => p_context
    ,p_ci_id_tbl                     => p_ci_id_tbl
    ,p_ci_cost_version_id_tbl        => p_ci_cost_version_id_tbl
    ,p_ci_rev_version_id_tbl         => p_ci_rev_version_id_tbl
    ,p_ci_all_version_id_tbl         => p_ci_all_version_id_tbl
    ,p_budget_version_id_tbl         => p_budget_version_id_tbl
    ,p_fin_plan_type_id_tbl          => p_fin_plan_type_id_tbl
    ,p_fin_plan_type_name_tbl        => p_fin_plan_type_name_tbl
    ,p_impl_cost_flag_tbl            => p_impl_cost_flag_tbl
    ,p_impl_rev_flag_tbl             => p_impl_rev_flag_tbl
    ,p_submit_version_flag_tbl       => p_submit_version_flag_tbl
    ,px_partial_impl_rev_amt         => l_partial_impl_rev_amt
    ,p_agreement_id                  => p_agreement_id
    ,p_update_agreement_amt_flag     => p_update_agreement_amt_flag
    ,p_funding_category              => p_funding_category
    ,x_ci_id_tbl                     => l_ci_id_tbl
    ,x_ci_cost_version_id_tbl        => l_ci_cost_version_id_tbl
    ,x_ci_rev_version_id_tbl         => l_ci_rev_version_id_tbl
    ,x_ci_all_version_id_tbl         => l_ci_all_version_id_tbl
    ,x_ci_number                     => l_ci_number
    ,x_budget_version_id_tbl         => l_budget_version_id_tbl
    ,x_fin_plan_type_id_tbl          => l_fin_plan_type_id_tbl
    ,x_fin_plan_type_name_tbl        => l_fin_plan_type_name_tbl
    ,x_submit_version_flag_tbl       => l_submit_version_flag_tbl
    ,x_budget_ci_map_rec_tbl         => l_budget_ci_map_rec_tbl
    ,x_agreement_id                  => l_agreement_id
    ,x_funding_category              => l_funding_category
    ,x_return_status                 => x_return_status
    ,x_msg_count                     => x_msg_count
    ,x_msg_data                      => x_msg_data );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Called API validate_ci_merge_input_data returned error';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
        END IF;
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    --dbms_output.put_line('M3');
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='l_agreement_id derived is '||l_agreement_id||' l_funding_category is '||l_funding_category;
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage:='Looping for Calling the merge into single version API';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
    END IF;


    x_translated_msgs_tbl := SYSTEM.pa_varchar2_2000_tbl_type();
    x_translated_err_msg_level_tbl := SYSTEM.pa_varchar2_30_tbl_type();

    IF p_add_msg_to_stack='N' THEN

        --Add the messages from the error stack to the output translated error messages table. These error messages
        --will be displayed on the OA pages
        l_msg_count := fnd_msg_pub.count_msg;

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Inside Loop for l_msg_count : '||l_msg_count;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;

        FOR l_msg_counter IN REVERSE 1..l_msg_count LOOP

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Inside l_msg_counter IN REVERSE l_msg_counter : '||l_msg_counter;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;
            PA_UTILS.Get_Encoded_Msg(p_index    => l_msg_counter,
                                     p_msg_out  => l_encoded_msg);
            fnd_message.set_encoded(l_encoded_msg);
            l_decoded_msg := fnd_message.get;
            l_translated_msg :=  nvl(l_decoded_msg, l_encoded_msg);

            x_translated_msgs_tbl.EXTEND(1);
            x_translated_err_msg_level_tbl.EXTEND(1);
            x_translated_msgs_tbl(x_translated_msgs_tbl.COUNT):=l_translated_msg;
            x_translated_err_msg_level_tbl(x_translated_err_msg_level_tbl.COUNT):='ERROR';

        END LOOP;

        --Initialise the msg pub so that these errors will not get added again to the translated err msg table
        FND_MSG_PUB.initialize;

    END IF;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Looping for Calling the merge into single version API';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
    END IF;
    --Initialise the pl/sql tbls.
    l_succ_impl_plan_types := SYSTEM.pa_varchar2_150_tbl_type();
    l_succ_impl_cos        := SYSTEM.pa_varchar2_150_tbl_type();


    --dbms_output.put_line('M4');
    --Call the Merge API
    IF l_ci_id_tbl.COUNT>0 AND l_budget_version_id_tbl.COUNT>0 THEN

        FOR i IN l_ci_id_tbl.FIRST..l_ci_id_tbl.LAST LOOP

            FOR j IN l_budget_version_id_tbl.FIRST..l_budget_version_id_tbl.LAST LOOP

                l_index:= 1;

                --Loop thru the l_budget_ci_map_rec_tbl to find out the record containing the ci id and  the
                --budget version id combination for which the implementation is being considered
                LOOP
                    EXIT WHEN (l_budget_ci_map_rec_tbl(l_index).budget_version_id=l_budget_version_id_tbl(j) AND
                               l_budget_ci_map_rec_tbl(l_index).ci_id=l_ci_id_tbl(i));
                    l_index:=l_index+1;
                END LOOP;
                l_impl_impact_type_code:=l_budget_ci_map_rec_tbl(l_index).impact_type_code;

                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='l_impl_impact_type_code IS '||l_impl_impact_type_code;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                END IF;


                IF l_impl_impact_type_code <> 'NONE' THEN

                    l_cost_ci_version_id:=NULL;
                    l_rev_ci_version_id:=NULL;
                    l_all_ci_version_id:=NULL;

                    -- Bug 5845142.
                    IF l_impl_impact_type_code IN ('COST', 'BOTH') AND
                       NVL(l_ci_cost_version_id_tbl(i),-1)<>-1 THEN

                        l_cost_ci_version_id:=l_ci_cost_version_id_tbl(i);

                    END IF;

                    -- Bug 5845142.
                    IF l_impl_impact_type_code IN ('REVENUE', 'BOTH') AND
                       NVL(l_ci_rev_version_id_tbl(i),-1)<>-1 THEN

                        l_rev_ci_version_id:=l_ci_rev_version_id_tbl(i);

                    END IF;

                    IF l_impl_impact_type_code = 'ALL' THEN

                        l_all_ci_version_id:=l_ci_all_version_id_tbl(i);

                    END IF;

                    /* Bug 3731975: impl_cost_flag and impl_rev_flag returned by get_impl_details is relevant to a plan type
                       context. But this API is called in the context of a single version. For example, it could be that for the
                       plan type impl_cost_flag and impl_rev_flag are 'Y' (COST_AND_REV_SEP) ,
                       but for the version (either COST or REVENUE) one of them doesnt make sense. */

                    IF l_impl_impact_type_code = 'COST' THEN

                        l_budget_ci_map_rec_tbl(l_index).impl_rev_flag:='N';

                    END IF;

                    IF l_impl_impact_type_code = 'REVENUE' THEN

                        l_budget_ci_map_rec_tbl(l_index).impl_cost_flag:= 'N';

                    END IF;

            -- End of code for Bug 3731975

                    /* Bug 3877815: Checking if the project is autobaselined enabled, if yes
                     * a separate api would be called to take care of merge for autobaselined projects
                     */
                    IF l_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:='Bug Fixing started-------';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                    END IF;
                    BEGIN
                         SELECT Nvl(bv.approved_cost_plan_type_flag, 'N'),
                                Nvl(bv.approved_rev_plan_type_flag, 'N'),
                                Nvl(pj.baseline_funding_flag, 'N')
                         INTO   l_targ_app_cost_flag,
                                l_targ_app_rev_flag,
                                l_baseline_funding_flag
                         FROM   pa_projects_all pj,
                                pa_budget_versions bv
                         WHERE  bv.budget_version_id = l_budget_version_id_tbl(j)
                         AND    bv.project_id = pj.project_id;
                    EXCEPTION
                         WHEN OTHERS THEN
                              IF P_PA_debug_mode = 'Y' THEN
                                   pa_debug.g_err_stage:='Error while getting baseline_funding_flag';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
                              END IF;
                              RAISE;
                    END;

                    l_baseline_api_called := 'N';

                    --If the version is approved revenue version and if the project is enabled for auto
                    --baseline then the version should be baselined

                    IF l_baseline_funding_flag ='Y' AND
                       l_targ_app_rev_flag = 'Y'    AND
                       l_budget_ci_map_rec_tbl(l_index).impl_rev_flag = 'Y' AND -- Bug 3877815: Review comment
                       p_context IN ('IMPL_FIN_IMPACT','PARTIAL_REV') THEN

                            l_baseline_api_called := 'Y';
                            IF l_debug_mode = 'Y' THEN
                                 pa_debug.g_err_stage:='Calling impl_ci_into_autobaseline_proj for autobaselined projects';
                                 pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                            END IF;
                            impl_ci_into_autobaseline_proj( p_ci_id                     => l_ci_id_tbl(i)
                                                           ,p_ci_rev_version_id         => l_rev_ci_version_id
                                                           ,p_budget_version_id         => l_budget_version_id_tbl(j)
                                                           ,p_fin_plan_type_id          => l_fin_plan_type_id_tbl(j)
                                                           ,p_partial_impl_rev_amt      => l_partial_impl_rev_amt
                                                           ,p_agreement_id              => l_agreement_id
                                                           ,p_update_agreement_amt_flag => p_update_agreement_amt_flag
                                                           ,p_funding_category          => l_funding_category
                                                           ,x_return_status             => x_return_status
                                                           ,x_msg_data                  => x_msg_data
                                                           ,x_msg_count                 => x_msg_count);

                            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                 IF l_debug_mode = 'Y' THEN
                                       pa_debug.g_err_stage:='--Call to impl_ci_into_autobaseline_proj returned with ERROR';
                                       pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
                                 END IF;
                                 IF p_context ='PARTIAL_REV' THEN
                                       l_partial_impl_succeeded:='N';
                                  END IF;
                                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                            ELSE
                                  --Record that this implementation is successful
                                  IF p_context='IMPL_FIN_IMPACT' THEN
                                        l_succ_impl_plan_types.EXTEND(1);
                                        l_succ_impl_plan_types(l_succ_impl_plan_types.COUNT):=l_fin_plan_type_name_tbl(j);
                                  ELSIF p_context='PARTIAL_REV' THEN
                                        l_partial_impl_succeeded:='Y';
                                  END IF;
                            END IF;
                    END IF;

                    IF l_baseline_api_called ='N' OR
                       l_budget_ci_map_rec_tbl(l_index).impl_cost_flag = 'Y' THEN -- Bug 3877815: Review comment
                         --dbms_output.put_line('M5');
                         IF l_debug_mode = 'Y' THEN
                               pa_debug.g_err_stage:='Calling implement_ci_into_single_ver';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                         END IF;
                         implement_ci_into_single_ver
                              (p_context                      => p_context
                              ,p_calling_context              => p_calling_context -- bug 3934574
                              ,p_ci_id                        => l_ci_id_tbl(i)
                              ,p_ci_cost_version_id           => l_cost_ci_version_id
                              ,p_ci_rev_version_id            => l_rev_ci_version_id
                              ,p_ci_all_version_id            => l_all_ci_version_id
                              ,p_budget_version_id            => l_budget_version_id_tbl(j)
                              ,p_fin_plan_type_id             => l_fin_plan_type_id_tbl(j)
                              ,p_fin_plan_type_name           => l_fin_plan_type_name_tbl(j)
                              ,p_partial_impl_rev_amt         => l_partial_impl_rev_amt
                              ,p_cost_impl_flag               => l_budget_ci_map_rec_tbl(l_index).impl_cost_flag
                              ,p_rev_impl_flag                => l_budget_ci_map_rec_tbl(l_index).impl_rev_flag
                              ,p_submit_version_flag          => l_submit_version_flag_tbl(j)
                              ,p_agreement_id                 => l_agreement_id
                              ,p_update_agreement_amt_flag    => p_update_agreement_amt_flag
                              ,p_funding_category             => l_funding_category
                              ,p_raTxn_rollup_api_call_flag   => p_raTxn_rollup_api_call_flag  --IPM Arch Enhancement Bug 4865563
                              ,x_return_status                => x_return_status
                              ,x_msg_data                     => x_msg_data
                              ,x_msg_count                    => x_msg_count);

                         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                              IF l_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage:='Called API PAFPCIMB.implement_ci_into_single_ver error';
                                    pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
                              END IF;

                              IF p_context ='PARTIAL_REV' THEN
                                   l_partial_impl_succeeded:='N';
                              END IF;

                              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                         ELSE
                              --Record that this implementation is successful
                              IF p_context='IMPL_FIN_IMPACT' THEN
                                   l_succ_impl_plan_types.EXTEND(1);
                                   l_succ_impl_plan_types(l_succ_impl_plan_types.COUNT):=l_fin_plan_type_name_tbl(j);
                              ELSIF p_context='INCLUDE' THEN
                                   l_succ_impl_cos.EXTEND(1);
                                   l_succ_impl_cos(l_succ_impl_cos.COUNT):=l_ci_number(i);
                              ELSIF p_context='PARTIAL_REV' THEN
                                   l_partial_impl_succeeded:='Y';
                              END IF;
                         END IF;
                    END IF; -- Merge Done

                    IF p_commit_flag ='Y' THEN
                         IF l_debug_mode = 'Y' THEN
                               pa_debug.g_err_stage:='About to commit data';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
                         END IF;

                         COMMIT;
                    END IF;

                    --dbms_output.put_line('M6');
                    IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:='l_impl_impact_type_code IS '||l_impl_impact_type_code;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                    END IF;


                    IF p_add_msg_to_stack='N' THEN

                        --Add the messages from the error stack to the output translated error messages table. These error messages
                        --will be displayed on the OA pages
                        l_msg_count := fnd_msg_pub.count_msg;
                        FOR l_msg_counter IN REVERSE 1..l_msg_count LOOP

                            PA_UTILS.Get_Encoded_Msg(p_index    => l_msg_counter,
                                                     p_msg_out  => l_encoded_msg);
                            fnd_message.set_encoded(l_encoded_msg);
                            l_decoded_msg := fnd_message.get;
                            l_translated_msg :=  nvl(l_decoded_msg, l_encoded_msg);

                            x_translated_msgs_tbl.EXTEND(1);
                            x_translated_err_msg_level_tbl.EXTEND(1);
                            x_translated_msgs_tbl(x_translated_msgs_tbl.COUNT):=l_translated_msg;
                            x_translated_err_msg_level_tbl(x_translated_err_msg_level_tbl.COUNT):='ERROR';

                        END LOOP;

                        --Initialise the msg pub so that these errors will not get added again to the translated err msg table
                        FND_MSG_PUB.initialize;

                    END IF;

                END IF;--IF l_ci_bv_merge_possible_map_tbl(l_index) <> 'NONE' THEN

            END LOOP;--Budget version loop

        END LOOP;--Ci Loop

    END IF;--IF l_ci_id_tbl.COUNT>0 AND l_budget_version_id_tbl.COUNT>0 THEN

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='About to add success msg '||l_succ_impl_plan_types.COUNT;
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF p_context='IMPL_FIN_IMPACT' THEN

        IF l_succ_impl_plan_types.COUNT>0 THEN

            FOR i IN l_succ_impl_plan_types.FIRST..l_succ_impl_plan_types.LAST LOOP

                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='l_plan_type_collection '||l_plan_type_collection;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                END IF;


                IF l_plan_type_collection IS NOT NULL THEN

                    l_plan_type_collection:=l_plan_type_collection||', ';

                END IF;

                l_plan_type_collection := l_plan_type_collection || l_succ_impl_plan_types(i);
            END LOOP;

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='l_plan_type_collection a '||l_plan_type_collection;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;

            IF l_plan_type_collection IS NOT NULL THEN
                l_plan_type_collection:= '[' || l_plan_type_collection || ']';

				--iff only new supplier region is enabled
                 PA_UTILS.ADD_MESSAGE
                 (p_app_short_name => 'PA',
                  p_msg_name       => 'PA_COST_OR_REV_IMPACT_MISSING');

                PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                 --p_msg_name       => 'PA_FP_IMPL_SUCC_PLAN_TYPE',--For bug 3829002
                 p_msg_name       => 'PA_FP_IMPL_OPT_SUCC_IMPL',
                 p_token1         => 'SUCC_PTS',
                 p_value1         => l_plan_type_collection );
           END IF;

        END IF;--IF l_succ_impl_plan_types.COUNT>0 THEN


    ELSIF p_context='INCLUDE' THEN

        IF l_succ_impl_cos.COUNT>0 THEN
            FOR i IN l_succ_impl_cos.FIRST..l_succ_impl_cos.LAST LOOP

                IF l_ci_number_collection IS NOT NULL THEN

                    l_ci_number_collection:=l_ci_number_collection||', ';

                END IF;

                l_ci_number_collection := l_ci_number_collection || l_succ_impl_cos(i);

            END LOOP;

            IF l_ci_number_collection IS NOT NULL THEN
                l_ci_number_collection:= '[' || l_ci_number_collection || ']';


                PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                 p_msg_name       => 'PA_FP_INCL_SUCC_CHG_DOC',
                 p_token1         => 'SUCC_CIS',
                 p_value1         => l_ci_number_collection );
           END IF;

        END IF;--IF l_succ_impl_cos.COUNT>0 THEN

    ELSIF l_partial_impl_succeeded='Y' THEN

        --dbms_output.put_line('M7');
        PA_UTILS.ADD_MESSAGE
        (p_app_short_name => 'PA',
         p_msg_name       => 'PA_FP_PARTIAL_IMPL_SUCC');
    END IF;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Populating the error msgs at the end';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
    END IF;


    IF p_add_msg_to_stack='N' THEN

        --Add the messages from the error stack to the output translated error messages table. These error messages
        --will be displayed on the OA pages
        l_msg_count := fnd_msg_pub.count_msg;
        FOR l_msg_counter IN REVERSE 1..l_msg_count LOOP

            PA_UTILS.Get_Encoded_Msg(p_index    => l_msg_counter,
                                     p_msg_out  => l_encoded_msg);
            fnd_message.set_encoded(l_encoded_msg);
            l_decoded_msg := fnd_message.get;
            l_translated_msg :=  nvl(l_decoded_msg, l_encoded_msg);

            x_translated_msgs_tbl.EXTEND(1);
            x_translated_err_msg_level_tbl.EXTEND(1);
            x_translated_msgs_tbl(x_translated_msgs_tbl.COUNT):=l_translated_msg;
            x_translated_err_msg_level_tbl(x_translated_err_msg_level_tbl.COUNT):='INFORMATION';

        END LOOP;
        --Initialise the msg pub so that these errors will not get added again to the translated err msg table
        FND_MSG_PUB.initialize;

    END IF;

    --dbms_output.put_line('M8');
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Setting the return status';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
    END IF;

    --Set the return status depending upon the parameter p_add_msg_to_stack
    IF p_add_msg_to_stack='N' THEN

        --Set the return status always to S as the calling API should look into the transalted error messages tbl
        --for the errors
        --Also Initialize x_translated_err_msg_count and clear the out variables
        x_translated_err_msg_count:=x_translated_msgs_tbl.count;
        x_return_status:='S';
        x_msg_data:=null;
        x_msg_count:=0;



    ELSE
        l_msg_count_at_end := fnd_msg_pub.count_msg;

/* -- Commenting out this code for Setting the x_return_status as this would be taken
   -- care in the Calling Module. (This Else Part is primarily when this API is called
   -- from Generation Flow -- Bug 3749556
        IF l_init_msg_count <> l_msg_count_at_end THEN

            x_return_status :='E';

        ELSE

            x_return_status:='S';

        END IF;
*/
    END IF;


    IF l_debug_mode = 'Y' THEN

        pa_debug.g_err_stage:= 'Exiting implement_change_document count :' || fnd_msg_pub.count_msg;
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        pa_debug.reset_curr_function;
    END IF;
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

        IF p_commit_flag ='N' THEN
            ROLLBACK TO implement_change_document;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;
 IF p_pa_debug_mode = 'Y' THEN
        pa_debug.reset_curr_function;
  END IF;
    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name  => 'PA_FP_CI_MERGE'
                          ,p_procedure_name  => 'implement_change_document');

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
        END IF;

        IF p_commit_flag ='N' THEN
            ROLLBACK TO implement_change_document;
        END IF;

    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.reset_curr_function;
    END IF;
        RAISE;

END implement_change_document;

--Added for Enc to copy only new supplier cost region data
procedure copy_supplier_cost_data(
         p_ci_id_to               IN     NUMBER
        ,p_ci_id_from             IN      NUMBER
        ,x_return_status        OUT    NOCOPY VARCHAR2
        ,x_msg_count            OUT    NOCOPY NUMBER
		,x_msg_data             OUT    NOCOPY VARCHAR2
) IS
 x_error_msg_code       varchar2(100) := NULL;
 x_supp_rowid    varchar2(50) := null;
 x_supp_ci_transaction_id number := null;
 supp_cost_flag  VARCHAR2(1);
 l_debug_mode    VARCHAR2(30);
 l_ci_type_id number := null;
 l_ci_id_to number := null;
 l_ci_id_from number := null;
 G_EXCEPTION_ERROR		EXCEPTION;
G_EXCEPTION_UNEXPECTED_ERROR	EXCEPTION;

l_count  number;
l_rec_index number;

TYPE supp_rec is record(
CI_TRANSACTION_ID            PA_CI_SUPPLIER_DETAILS.CI_TRANSACTION_ID%type,
CI_ID                        PA_CI_SUPPLIER_DETAILS.CI_ID%type,
CI_TYPE_ID                   PA_CI_SUPPLIER_DETAILS.CI_TYPE_ID%type,
CI_IMPACT_ID                 PA_CI_SUPPLIER_DETAILS.CI_IMPACT_ID%TYPE,
VENDOR_ID                    PA_CI_SUPPLIER_DETAILS.VENDOR_ID%TYPE,
PO_HEADER_ID                 PA_CI_SUPPLIER_DETAILS.PO_HEADER_ID%TYPE,
PO_LINE_ID                   PA_CI_SUPPLIER_DETAILS.PO_LINE_ID%TYPE,
CHANGE_AMOUNT                PA_CI_SUPPLIER_DETAILS.CHANGE_AMOUNT%TYPE,
CURRENCY_CODE                PA_CI_SUPPLIER_DETAILS.CURRENCY_CODE%TYPE,
ADJUSTED_CI_TRANSACTION_ID   PA_CI_SUPPLIER_DETAILS.ADJUSTED_CI_TRANSACTION_ID%TYPE,
CHANGE_DESCRIPTION           PA_CI_SUPPLIER_DETAILS.CHANGE_DESCRIPTION%TYPE,
CHANGE_TYPE                  PA_CI_SUPPLIER_DETAILS.CHANGE_TYPE%TYPE,
CREATED_BY                   PA_CI_SUPPLIER_DETAILS.CREATED_BY%TYPE,
CREATION_DATE                PA_CI_SUPPLIER_DETAILS.CREATION_DATE%TYPE,
LAST_UPDATED_BY              PA_CI_SUPPLIER_DETAILS.LAST_UPDATED_BY%TYPE,
LAST_UPDATE_DATE             PA_CI_SUPPLIER_DETAILS.LAST_UPDATE_DATE%TYPE,
LAST_UPDATE_LOGIN            PA_CI_SUPPLIER_DETAILS.LAST_UPDATE_LOGIN%TYPE,
CHANGE_APPROVER              PA_CI_SUPPLIER_DETAILS.CHANGE_APPROVER%TYPE,
AUDIT_HISTORY_NUMBER         PA_CI_SUPPLIER_DETAILS.AUDIT_HISTORY_NUMBER%TYPE,
CURRENT_AUDIT_FLAG           PA_CI_SUPPLIER_DETAILS.CURRENT_AUDIT_FLAG%TYPE,
ORIGINAL_SUPP_TRANS_ID       PA_CI_SUPPLIER_DETAILS.ORIGINAL_SUPP_TRANS_ID%TYPE,
SOURCE_SUPP_TRANS_ID         PA_CI_SUPPLIER_DETAILS.SOURCE_SUPP_TRANS_ID%TYPE,
FROM_CHANGE_DATE             PA_CI_SUPPLIER_DETAILS.FROM_CHANGE_DATE%TYPE,
TO_CHANGE_DATE               PA_CI_SUPPLIER_DETAILS.TO_CHANGE_DATE%TYPE,
RAW_COST                     PA_CI_SUPPLIER_DETAILS.RAW_COST%TYPE,
BURDENED_COST                PA_CI_SUPPLIER_DETAILS.BURDENED_COST%TYPE,
REVENUE_RATE                 PA_CI_SUPPLIER_DETAILS.REVENUE_RATE%TYPE,
REVENUE_OVERRIDE_RATE        PA_CI_SUPPLIER_DETAILS.REVENUE_OVERRIDE_RATE%TYPE,
REVENUE                      PA_CI_SUPPLIER_DETAILS.REVENUE%TYPE,
TOTAL_REVENUE                PA_CI_SUPPLIER_DETAILS.TOTAL_REVENUE%TYPE,
SUP_QUOTE_REF_NO             PA_CI_SUPPLIER_DETAILS.SUP_QUOTE_REF_NO%TYPE,
TASK_ID                      PA_CI_SUPPLIER_DETAILS.TASK_ID%TYPE,
RESOURCE_LIST_MEMBER_ID      PA_CI_SUPPLIER_DETAILS.RESOURCE_LIST_MEMBER_ID%TYPE,
EXPENDITURE_TYPE_ID          PA_CI_SUPPLIER_DETAILS.EXPENDITURE_TYPE_ID%TYPE,
ESTIMATED_COST               PA_CI_SUPPLIER_DETAILS.ESTIMATED_COST%TYPE,
QUOTED_COST                  PA_CI_SUPPLIER_DETAILS.QUOTED_COST%TYPE,
NEGOTIATED_COST              PA_CI_SUPPLIER_DETAILS.NEGOTIATED_COST%TYPE,
FINAL_COST                   PA_CI_SUPPLIER_DETAILS.FINAL_COST%TYPE,
MARKUP_COST                  PA_CI_SUPPLIER_DETAILS.MARKUP_COST%TYPE,
STATUS                       PA_CI_SUPPLIER_DETAILS.STATUS%TYPE,
EXPENDITURE_ORG_ID           PA_CI_SUPPLIER_DETAILS.EXPENDITURE_ORG_ID%TYPE,
CHANGE_REASON_CODE           PA_CI_SUPPLIER_DETAILS.CHANGE_REASON_CODE%TYPE,
QUOTE_NEGOTIATION_REFERENCE  PA_CI_SUPPLIER_DETAILS.QUOTE_NEGOTIATION_REFERENCE%TYPE,
NEED_BY_DATE                 PA_CI_SUPPLIER_DETAILS.NEED_BY_DATE%TYPE,
EXPENDITURE_TYPE             PA_CI_SUPPLIER_DETAILS.EXPENDITURE_TYPE%TYPE,
RESOURCE_ASSIGNMENT_ID       PA_CI_SUPPLIER_DETAILS.RESOURCE_ASSIGNMENT_ID%TYPE);

TYPE supp_rec_tbl is table of supp_rec index by binary_integer;

supp_from_tbl supp_rec_tbl;
supp_to_tbl   supp_rec_tbl;
l_found       varchar2(1);
l_return_status varchar2(1);
l_error_msg_code varchar2(30);
l_budget_version_id number;

CURSOR get_supp_dtls(l_ci_id_f number)
	is
	   select * from  PA_CI_SUPPLIER_DETAILS
	   WHERE ci_id = l_ci_id_f;


CURSOR check_supp_cost_reg_flag (ci_id_t number,ci_id_f number)
	is
	   select 1 from pa_ci_types_b ci_id_to,
	    pa_ci_types_b ci_id_from
	    where ci_id_to.ci_type_id in(
		select ci_type_id
		from  pa_control_items where ci_id=ci_id_t)
		and ci_id_from.ci_type_id in (
		select ci_type_id
		from  pa_control_items where ci_id=ci_id_f )
		and ci_id_to.supp_cost_reg_flag='Y'
		and ci_id_from.supp_cost_reg_flag='Y' ;

begin

		IF p_pa_debug_mode = 'Y' THEN
		pa_debug.init_err_stack('PAFPCIMB.copy_supplier_cost_data');
		END IF;
		fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
		l_debug_mode := NVL(l_debug_mode, 'Y');
		IF p_pa_debug_mode = 'Y' THEN
		  pa_debug.set_process('PLSQL','LOG',l_debug_mode);
		END IF;
		x_return_status := FND_API.G_RET_STS_SUCCESS;
		x_msg_count := 0;
        l_ci_id_to :=p_ci_id_to;
        l_ci_id_from :=p_ci_id_from;

        savepoint copy_supp_det;


        open check_supp_cost_reg_flag(l_ci_id_to,l_ci_id_from);
	    fetch check_supp_cost_reg_flag into supp_cost_flag;
        close check_supp_cost_reg_flag;


        select ci_type_id
        into l_ci_type_id
        from pa_control_items
        where ci_id=p_ci_id_to ;

-- Check if new suppler cost region exists in both the control items

  if  supp_cost_flag is null then
     x_return_status :=FND_API.G_RET_STS_SUCCESS;
     x_msg_count :=0;
	 x_msg_data  :='There are no Supplier records to copy';

  else
   -- verify for each record from the source whether it exists in the target
   -- if it exists, do an update based on the criteria. else do an insert
     supp_from_tbl.delete;
     supp_to_tbl.delete;

     open get_supp_dtls(l_ci_id_from);
     fetch get_supp_dtls bulk collect into supp_from_tbl;
     close get_supp_dtls;

     open get_supp_dtls(p_ci_id_to);
     fetch get_supp_dtls bulk collect into supp_to_tbl;
     close get_supp_dtls;

     -- rules for determining existence of record in target:
     -- 1. for change type 'Create New', if task,exp type, resource, currency,
     -- supplier, exp org, need by date are the same, then update, else insert
     -- 2. for change type 'Update Existing', if task,exp type, resource, currency,
     -- supplier, po number, po line number are the same, then update, else insert
     if supp_from_tbl.count > 0 then
       for i in supp_from_tbl.first..supp_from_tbl.last loop
         l_found := 'N';
         l_rec_index := 0;
         if supp_to_tbl.count > 0 then
         if supp_from_tbl(i).change_type = 'CREATE' then
           for j in supp_to_tbl.first..supp_to_tbl.last loop
             if supp_from_tbl(i).task_id =  supp_to_tbl(j).task_id and
                nvl(supp_from_tbl(i).expenditure_type, 'X') = nvl(supp_to_tbl(j).expenditure_type, 'X') and
                supp_from_tbl(i).resource_list_member_id = supp_to_tbl(j).resource_list_member_id and
                supp_from_tbl(i).currency_code = supp_to_tbl(j).currency_code and
                supp_from_tbl(i).vendor_id = supp_to_tbl(j).vendor_id and
                nvl(supp_from_tbl(i).expenditure_org_id, -1) = nvl(supp_to_tbl(j).expenditure_org_id, -1) and
                nvl(supp_from_tbl(i).need_by_date, sysdate) = nvl(supp_to_tbl(j).need_by_date, sysdate) then
                  l_found := 'Y';
                  l_rec_index := j;
                  supp_to_tbl(j).change_amount := nvl(supp_to_tbl(j).change_amount, 0) + nvl(supp_from_tbl(i).change_amount, 0);
                  supp_to_tbl(j).raw_cost := nvl(supp_to_tbl(j).raw_cost, 0) + nvl(supp_from_tbl(i).raw_cost, 0);
                  supp_to_tbl(j).from_change_date := least(supp_to_tbl(j).from_change_date, supp_from_tbl(i).from_change_date);
                  supp_to_tbl(j).to_change_date := greatest(supp_to_tbl(j).to_change_date, supp_from_tbl(i).to_change_date);
                  supp_to_tbl(j).Estimated_Cost := nvl(supp_to_tbl(j).Estimated_Cost, 0) + nvl(supp_from_tbl(i).Estimated_Cost, 0);
                  supp_to_tbl(j).Quoted_Cost := nvl(supp_to_tbl(j).Quoted_Cost, 0) + nvl(supp_from_tbl(i).Quoted_Cost, 0);
                  supp_to_tbl(j).Negotiated_Cost := nvl(supp_to_tbl(j).Negotiated_Cost, 0) + nvl(supp_from_tbl(i).Negotiated_Cost, 0);
                  exit;
             end if;
           end loop;
         elsif supp_from_tbl(i).change_type = 'UPDATE' then
           for j in supp_to_tbl.first..supp_to_tbl.last loop
             if supp_from_tbl(i).task_id =  supp_to_tbl(j).task_id and
                nvl(supp_from_tbl(i).expenditure_type, 'X') = nvl(supp_to_tbl(j).expenditure_type, 'X') and
                supp_from_tbl(i).resource_list_member_id = supp_to_tbl(j).resource_list_member_id and
                supp_from_tbl(i).currency_code = supp_to_tbl(j).currency_code and
                supp_from_tbl(i).vendor_id = supp_to_tbl(j).vendor_id and
                nvl(supp_from_tbl(i).po_header_id, -1) = nvl(supp_to_tbl(j).po_header_id, -1) and
                nvl(supp_from_tbl(i).po_line_id, -1) = nvl(supp_to_tbl(j).po_line_id, -1) then
                  l_found := 'Y';
                  l_rec_index := j;
                  supp_to_tbl(j).change_amount := nvl(supp_to_tbl(j).change_amount, 0) + nvl(supp_from_tbl(i).change_amount, 0);
                  supp_to_tbl(j).raw_cost := nvl(supp_to_tbl(j).raw_cost, 0) + nvl(supp_from_tbl(i).raw_cost, 0);
                  supp_to_tbl(j).from_change_date := least(supp_to_tbl(j).from_change_date, supp_from_tbl(i).from_change_date);
                  supp_to_tbl(j).to_change_date := greatest(supp_to_tbl(j).to_change_date, supp_from_tbl(i).to_change_date);
                  supp_to_tbl(j).Estimated_Cost := nvl(supp_to_tbl(j).Estimated_Cost, 0) + nvl(supp_from_tbl(i).Estimated_Cost, 0);
                  supp_to_tbl(j).Quoted_Cost := nvl(supp_to_tbl(j).Quoted_Cost, 0) + nvl(supp_from_tbl(i).Quoted_Cost, 0);
                  supp_to_tbl(j).Negotiated_Cost := nvl(supp_to_tbl(j).Negotiated_Cost, 0) + nvl(supp_from_tbl(i).Negotiated_Cost, 0);
                  exit;
             end if;
           end loop;
         end if;
         end if; --> supp_to_tbl.count > 0

         if l_found = 'N' then
               x_supp_ci_transaction_id :=null;
               PA_CI_SUPPLIER_PKG.insert_row (
                        x_rowid                   => x_supp_rowid
                        ,x_ci_transaction_id      => x_supp_ci_transaction_id
                        ,p_CI_TYPE_ID             => l_ci_type_id
                        ,p_CI_ID           	      => l_ci_id_to
                        ,p_CI_IMPACT_ID           => supp_from_tbl(i).ci_impact_id
                        ,p_VENDOR_ID              => supp_from_tbl(i).vendor_id
                        ,p_PO_HEADER_ID           => supp_from_tbl(i).po_header_id
                        ,p_PO_LINE_ID             => supp_from_tbl(i).po_line_id
                        ,p_ADJUSTED_TRANSACTION_ID => supp_from_tbl(i).ADJUSTED_CI_TRANSACTION_ID
                        ,p_CURRENCY_CODE           => supp_from_tbl(i).CURRENCY_CODE
                        ,p_CHANGE_AMOUNT           => supp_from_tbl(i).CHANGE_AMOUNT
                        ,p_CHANGE_TYPE             => supp_from_tbl(i).CHANGE_TYPE
                        ,p_CHANGE_DESCRIPTION      => supp_from_tbl(i).CHANGE_DESCRIPTION
                        ,p_CREATED_BY              => FND_GLOBAL.login_id
                        ,p_CREATION_DATE           => trunc(sysdate)
                        ,p_LAST_UPDATED_BY         => FND_GLOBAL.login_id
                        ,p_LAST_UPDATE_DATE        => trunc(sysdate)
                        ,p_LAST_UPDATE_LOGIN       => FND_GLOBAL.login_id
                        ,p_Task_Id                 => supp_from_tbl(i).Task_Id
                        ,p_Resource_List_Mem_Id    => supp_from_tbl(i).Resource_List_Member_Id
                        ,p_From_Date               => supp_from_tbl(i).FROM_CHANGE_DATE
                        ,p_To_Date                 => supp_from_tbl(i).TO_CHANGE_DATE
                        ,p_Estimated_Cost          => supp_from_tbl(i).Estimated_Cost
                        ,p_Quoted_Cost             => supp_from_tbl(i).Quoted_Cost
                        ,p_Negotiated_Cost         => supp_from_tbl(i).Negotiated_Cost
                        ,p_Burdened_cost           => supp_from_tbl(i).Burdened_cost
                        ,p_revenue_override_rate   => supp_from_tbl(i).revenue_override_rate
                        ,p_audit_history_number    =>  1
                        ,p_current_audit_flag      =>  'Y'
                        ,p_Original_supp_trans_id  =>  0
                        ,p_Source_supp_trans_id    =>  0
                        ,p_Sup_ref_no              =>  supp_from_tbl(i).sup_quote_ref_no
                        ,p_version_type            =>  supp_from_tbl(i).status
                        ,p_ci_status               => 'COST'
                        /* Changes for 12.1.3 start */
                        ,p_expenditure_type        => supp_from_tbl(i).expenditure_type
                        ,p_expenditure_org_id      => supp_from_tbl(i).expenditure_org_id
                        ,p_change_reason_code      => supp_from_tbl(i).change_reason_code
                        ,p_quote_negotiation_reference  => supp_from_tbl(i).quote_negotiation_reference
                        ,p_need_by_date            => supp_from_tbl(i).need_by_date
                        /* Changes for 12.1.3 end */
                        ,x_return_status           => x_return_status
                        ,x_error_msg_code          => x_msg_data  );

                    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                        RAISE G_EXCEPTION_ERROR;
                    END IF;
         else -- l_found = 'Y'
               PA_CI_SUPPLIER_PKG.update_row (
                  p_rowid                    => x_supp_rowid
                  ,p_ci_transaction_id       => supp_to_tbl(l_rec_index).ci_transaction_id
                  ,p_CI_TYPE_ID              => supp_to_tbl(l_rec_index).ci_type_id
                  ,p_CI_ID           	     => supp_to_tbl(l_rec_index).ci_id
                  ,p_CI_IMPACT_ID            => supp_to_tbl(l_rec_index).ci_impact_id
                  ,p_VENDOR_ID               => supp_to_tbl(l_rec_index).vendor_id
                  ,p_PO_HEADER_ID            => supp_to_tbl(l_rec_index).po_header_id
                  ,p_PO_LINE_ID              => supp_to_tbl(l_rec_index).po_line_id
                  ,p_ADJUSTED_TRANSACTION_ID => supp_to_tbl(l_rec_index).adjusted_ci_transaction_id
                  ,p_CURRENCY_CODE           => supp_to_tbl(l_rec_index).currency_code
                  ,p_CHANGE_AMOUNT           => supp_to_tbl(l_rec_index).change_amount
                  ,p_CHANGE_TYPE             => supp_to_tbl(l_rec_index).change_type
                  ,p_CHANGE_DESCRIPTION      => supp_to_tbl(l_rec_index).change_description
                  ,p_LAST_UPDATED_BY         => FND_GLOBAL.login_id
                  ,p_LAST_UPDATE_DATE        => trunc(sysdate)
                  ,p_LAST_UPDATE_LOGIN       => FND_GLOBAL.login_id
                  ,p_Task_Id                 => supp_to_tbl(l_rec_index).task_id
                  ,p_Resource_List_Mem_Id    => supp_to_tbl(l_rec_index).resource_list_member_id
                  ,p_From_Date               => supp_to_tbl(l_rec_index).from_change_date
                  ,p_To_Date                 => supp_to_tbl(l_rec_index).to_change_date
                  ,p_Estimated_Cost          => supp_to_tbl(l_rec_index).estimated_cost
                  ,p_Quoted_Cost             => supp_to_tbl(l_rec_index).quoted_cost
                  ,p_Negotiated_Cost         => supp_to_tbl(l_rec_index).negotiated_cost
                  ,p_Burdened_cost           => supp_to_tbl(l_rec_index).burdened_cost
                  ,p_Revenue                 => supp_to_tbl(l_rec_index).revenue
                  ,p_revenue_override_rate   => supp_to_tbl(l_rec_index).revenue_override_rate
                  ,p_audit_history_number    => supp_to_tbl(l_rec_index).audit_history_number
                  ,p_current_audit_flag      => supp_to_tbl(l_rec_index).current_audit_flag
                  ,p_Original_supp_trans_id  => supp_to_tbl(l_rec_index).original_supp_trans_id
                  ,p_Source_supp_trans_id    => supp_to_tbl(l_rec_index).source_supp_trans_id
                  ,p_Sup_ref_no              => supp_to_tbl(l_rec_index).sup_quote_ref_no
                  ,p_version_type            => supp_to_tbl(l_rec_index).status
                  ,p_expenditure_type        => supp_to_tbl(l_rec_index).expenditure_type
                  ,p_expenditure_org_id      => supp_to_tbl(l_rec_index).expenditure_org_id
                  ,p_change_reason_code      => supp_to_tbl(l_rec_index).change_reason_code
                  ,p_quote_negotiation_reference => supp_to_tbl(l_rec_index).quote_negotiation_reference
                  ,p_need_by_date            => supp_to_tbl(l_rec_index).need_by_date
                  ,x_return_status           => l_return_status
                  ,x_error_msg_code          => l_error_msg_code );

                 IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
                   RAISE PA_API.G_EXCEPTION_ERROR;
                 END IF;

         end if;  -- l_found

         select budget_version_id
           into l_budget_version_id
           from pa_budget_versions
          where ci_id = l_ci_id_to
            and version_type in ('COST', 'ALL');

            update pa_ci_supplier_details a
               set (resource_assignment_id, from_change_date, to_change_date, burdened_cost) =
                   (select prc.resource_assignment_id,
                           nvl(a.from_change_date, pra.planning_start_date),
                           nvl(a.to_change_date, pra.planning_end_date),
                           a.raw_cost * prc.txn_average_burden_cost_rate
                      from pa_resource_asgn_curr prc, pa_resource_assignments pra
                     where prc.resource_assignment_id = pra.resource_assignment_id
                       and pra.budget_version_id = l_budget_version_id
                       and pra.task_id = a.task_id
                       and pra.resource_list_member_id = a.resource_list_member_id
                       and prc.txn_currency_code = a.currency_code)
             where a.ci_id = l_ci_id_to;

       end loop;
     end if; -- supp_from_tbl.count > 0 then
   -- end of bug 9674883 enh
  end if;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO copy_supp_det;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_FP_CI_MERGE',
                            p_procedure_name => 'copy_supplier_cost_data',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
    RAISE;
end  copy_supplier_cost_data;
/* Added for 12.1.3 for Enc to copy the direct cost data */


procedure copy_direct_cost_data(
         p_ci_id_to               IN      NUMBER
        ,p_ci_id_from             IN      NUMBER
        ,p_bv_id                  IN      pa_budget_versions.budget_version_id%TYPE
        ,p_project_id              IN      NUMBER
        ,x_return_status          OUT     NOCOPY VARCHAR2
        ,x_msg_count              OUT     NOCOPY NUMBER
		,x_msg_data               OUT     NOCOPY VARCHAR2
) IS
    l_project_id       NUMBER ;
    l_bv_id           pa_budget_versions.budget_version_id%TYPE ;
    l_task_id_tbl                   SYSTEM.PA_NUM_TBL_TYPE ;
    l_expenditure_type_tbl          SYSTEM.PA_VARCHAR2_30_TBL_TYPE ;
    l_rlmi_id_tbl                   SYSTEM.PA_NUM_TBL_TYPE;
    l_unit_of_measure_tbl           SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
    l_currency_code_tbl             SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
    l_planning_resource_rate_tbl    SYSTEM.PA_NUM_TBL_TYPE ;
    l_quantity_tbl                  SYSTEM.PA_NUM_TBL_TYPE ;
    l_raw_cost_tbl                  SYSTEM.PA_NUM_TBL_TYPE ;
    l_burdened_cost_tbl             SYSTEM.PA_NUM_TBL_TYPE ;
    l_raw_cost_rate_tbl             SYSTEM.PA_NUM_TBL_TYPE ;
    l_burden_cost_rate_tbl          SYSTEM.PA_NUM_TBL_TYPE ;
    l_resource_assignment_id_tbl    SYSTEM.PA_NUM_TBL_TYPE ;
    l_effective_from_tbl            SYSTEM.PA_DATE_TBL_TYPE;
    l_effective_to_tbl              SYSTEM.PA_DATE_TBL_TYPE;
    l_change_reason_code            SYSTEM.PA_VARCHAR2_30_TBL_TYPE ;
    l_change_description            SYSTEM.PA_VARCHAR2_2000_TBL_TYPE;
    -- target ci variables
    l_dc_line_id_to_tbl                SYSTEM.PA_NUM_TBL_TYPE ;
    l_task_id_to_tbl                   SYSTEM.PA_NUM_TBL_TYPE ;
    l_expenditure_type_to_tbl          SYSTEM.PA_VARCHAR2_30_TBL_TYPE ;
    l_rlmi_id_to_tbl                   SYSTEM.PA_NUM_TBL_TYPE;
    l_unit_of_measure_to_tbl           SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
    l_currency_code_to_tbl             SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
    l_resource_rate_to_tbl             SYSTEM.PA_NUM_TBL_TYPE ;
    l_quantity_to_tbl                  SYSTEM.PA_NUM_TBL_TYPE ;
    l_raw_cost_to_tbl                  SYSTEM.PA_NUM_TBL_TYPE ;
    l_burdened_cost_to_tbl             SYSTEM.PA_NUM_TBL_TYPE ;
    l_raw_cost_rate_to_tbl             SYSTEM.PA_NUM_TBL_TYPE ;
    l_burden_cost_rate_to_tbl          SYSTEM.PA_NUM_TBL_TYPE ;
    l_resource_asgn_id_to_tbl          SYSTEM.PA_NUM_TBL_TYPE ;
    l_effective_from_to_tbl            SYSTEM.PA_DATE_TBL_TYPE;
    l_effective_to_to_tbl              SYSTEM.PA_DATE_TBL_TYPE;
    -- for insert
    i_task_id_tbl                   SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    i_expenditure_type_tbl          SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
    i_rlmi_id_tbl                   SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    i_unit_of_measure_tbl           SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
    i_currency_code_tbl             SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
    i_quantity_tbl                  SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    i_raw_cost_tbl                  SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    i_effective_from_tbl            SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE();
    i_effective_to_tbl              SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE();
    -- for update
    u_dc_line_id_tbl                SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    u_task_id_tbl                   SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    u_expenditure_type_tbl          SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
    u_rlmi_id_tbl                   SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    u_unit_of_measure_tbl           SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
    u_currency_code_tbl             SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
    u_planning_resource_rate_tbl    SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    u_quantity_tbl                  SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    u_raw_cost_tbl                  SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    u_burdened_cost_tbl             SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    u_raw_cost_rate_tbl             SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    u_burden_cost_rate_tbl          SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    u_resource_assignment_id_tbl    SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    u_effective_from_tbl            SYSTEM.PA_DATE_TBL_TYPE:= SYSTEM.PA_DATE_TBL_TYPE();
    u_effective_to_tbl              SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE();
    u_change_reason_code            SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
    u_change_description            SYSTEM.PA_VARCHAR2_2000_TBL_TYPE  := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
    --
    l_api_version	     number := 1;
    l_api_name          CONSTANT VARCHAR2(60) := 'PA_FP_CI_MERGE.copy_direct_cost_data';
    l_return_status     VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
    l_msg_count	     number;
    l_msg_data          varchar2(2000);
    l_dir_cost_flag  VARCHAR2(1);
 	l_debug_mode    VARCHAR2(30);
 	subtype PaCiDirCostTblType is pa_ci_dir_cost_pvt.PaCiDirectCostDetailsTblType;
 	l_dc_line_id_tbl    SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    i_PaCiDirCostDetTbl PaCiDirCostTblType;
    u_PaCiDirCostDetTbl PaCiDirCostTblType;
    x_PaCiDirCostDetTbl PaCiDirCostTblType;

	l_found       SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
	l_rec_index   SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();

    ins_index     number;
    upd_index     number;
    seq_value     number;

 	l_ci_type_id number := null;
 	l_ci_id_to number := null;
 	l_ci_id_from number := null;
    l_count      number := null;
 	G_EXCEPTION_ERROR		EXCEPTION;
	G_EXCEPTION_UNEXPECTED_ERROR	EXCEPTION;

CURSOR check_dir_cost_reg_flag (ci_id_t number,ci_id_f number)
	is
	   select 1 from pa_ci_types_b ci_id_to,
	    pa_ci_types_b ci_id_from
	    where ci_id_to.ci_type_id in(
		select ci_type_id
		from  pa_control_items where ci_id=ci_id_t)
		and ci_id_from.ci_type_id in (
		select ci_type_id
		from  pa_control_items where ci_id=ci_id_f )
		and ci_id_to.dir_cost_reg_flag='Y'
		and ci_id_from.dir_cost_reg_flag='Y' ;

begin
       savepoint copy_dir_cost_det;
       l_project_id := p_project_id;
       l_ci_id_to    :=p_ci_id_to ;
       l_ci_id_from  :=p_ci_id_from ;
        open check_dir_cost_reg_flag(l_ci_id_to,l_ci_id_from);
	    fetch check_dir_cost_reg_flag into l_dir_cost_flag;
        close check_dir_cost_reg_flag;

-- Check if new direct cost region exists in both the control items

  if  l_dir_cost_flag is null then
     x_return_status :=FND_API.G_RET_STS_SUCCESS;
     x_msg_count :=0;
	 x_msg_data  :='Cannot copy direct cost records';
  else
     select task_id
           ,expenditure_type
           ,resource_list_member_id
           ,unit_of_measure
           ,currency_code
           ,quantity
           ,raw_cost
           ,change_reason_code
           ,change_description
           ,effective_from
           ,effective_to
       BULK COLLECT into
       	    l_task_id_tbl
		  	,l_expenditure_type_tbl
			,l_rlmi_id_tbl
			,l_unit_of_measure_tbl
			,l_currency_code_tbl
			,l_quantity_tbl
			,l_raw_cost_tbl
			,l_change_reason_code
			,l_change_description
            ,l_effective_from_tbl
            ,l_effective_to_tbl
	    From pa_ci_direct_cost_details
	   where ci_id = p_ci_id_from ;

    select dc_line_id
          ,task_id
          ,expenditure_type
          ,resource_list_member_id
          ,unit_of_measure
          ,currency_code
          ,quantity
          ,raw_cost
          ,planning_resource_rate
          ,burden_cost_rate
          ,effective_from
          ,effective_to
          ,resource_assignment_id
      bulk collect into
           l_dc_line_id_to_tbl
          ,l_task_id_to_tbl
		  ,l_expenditure_type_to_tbl
		  ,l_rlmi_id_to_tbl
          ,l_unit_of_measure_to_tbl
		  ,l_currency_code_to_tbl
		  ,l_quantity_to_tbl
          ,l_raw_cost_to_tbl
          ,l_resource_rate_to_tbl
          ,l_burden_cost_rate_to_tbl
          ,l_effective_from_to_tbl
          ,l_effective_to_to_tbl
          ,l_resource_asgn_id_to_tbl
      From pa_ci_direct_cost_details
	 where ci_id = l_ci_id_to ;

    ins_index := 0;
    upd_index := 0;

  if l_task_id_tbl.count > 0 then
        l_found.extend(l_task_id_tbl.count);
    if l_task_id_to_tbl.count > 0 then
      for i in l_task_id_tbl.first..l_task_id_tbl.last loop
        l_rec_index.extend(1);
        l_rec_index(i) := 0;
        for j in l_task_id_to_tbl.first..l_task_id_to_tbl.last loop
          if l_task_id_tbl(i) = l_task_id_to_tbl(j) and
             l_expenditure_type_tbl(i) = l_expenditure_type_to_tbl(j) and
             l_rlmi_id_tbl(i) = l_rlmi_id_to_tbl(j) and
             l_currency_code_tbl(i) = l_currency_code_to_tbl(j) then
               l_found(i) := 'Y';
               l_rec_index(i) := j;

             if l_quantity_tbl(i) is not null then
               l_quantity_tbl(i) := l_quantity_to_tbl(j) + l_quantity_tbl(i);
             end if;

             if l_raw_cost_tbl(i) is not null then
               l_raw_cost_tbl(i) := l_raw_cost_to_tbl(j) + l_raw_cost_tbl(i);
             end if;

             l_effective_from_tbl(i) := least(l_effective_from_to_tbl(j), l_effective_from_tbl(i));
             l_effective_to_tbl(i) := greatest(l_effective_to_to_tbl(j), l_effective_to_tbl(i));
             exit;
          end if;
        end loop;
      end loop;
    end if;

    for i in l_task_id_tbl.first..l_task_id_tbl.last loop
      if nvl(l_found(i), 'N') = 'Y' then
         upd_index := upd_index + 1;

         u_PaCiDirCostDetTbl(upd_index).dc_line_id              := l_dc_line_id_to_tbl(l_rec_index(i));
         u_PaCiDirCostDetTbl(upd_index).ci_id                   := l_ci_id_to;
         u_PaCiDirCostDetTbl(upd_index).project_id              := l_project_id;
         u_PaCiDirCostDetTbl(upd_index).task_id                 := l_task_id_tbl(i);
         u_PaCiDirCostDetTbl(upd_index).expenditure_type        := l_expenditure_type_tbl(i);
         u_PaCiDirCostDetTbl(upd_index).resource_list_member_id := l_rlmi_id_tbl(i);
         u_PaCiDirCostDetTbl(upd_index).unit_of_measure         := l_unit_of_measure_tbl(i);
         u_PaCiDirCostDetTbl(upd_index).currency_code           := l_currency_code_tbl(i);
         u_PaCiDirCostDetTbl(upd_index).quantity                := l_quantity_tbl(i);
         u_PaCiDirCostDetTbl(upd_index).planning_resource_rate  := FND_API.G_MISS_NUM;
	     u_PaCiDirCostDetTbl(upd_index).raw_cost                := l_raw_cost_tbl(i);
         u_PaCiDirCostDetTbl(upd_index).burdened_cost           := FND_API.G_MISS_NUM;
         u_PaCiDirCostDetTbl(upd_index).raw_cost_rate           := FND_API.G_MISS_NUM;
         u_PaCiDirCostDetTbl(upd_index).burden_cost_rate        := FND_API.G_MISS_NUM;
         u_PaCiDirCostDetTbl(upd_index).resource_assignment_id  := FND_API.G_MISS_NUM;
         u_PaCiDirCostDetTbl(upd_index).effective_from          := l_effective_from_tbl(i);
         u_PaCiDirCostDetTbl(upd_index).effective_to            := l_effective_to_tbl(i);
         u_PaCiDirCostDetTbl(upd_index).change_reason_code      := FND_API.G_MISS_CHAR;
         u_PaCiDirCostDetTbl(upd_index).change_description      := FND_API.G_MISS_CHAR;
      else
         ins_index := ins_index + 1;
	       select pa_ci_dir_cost_details_s.nextval
	         into seq_value
	         from dual;

         i_PaCiDirCostDetTbl(ins_index).dc_line_id              := seq_value;
         i_PaCiDirCostDetTbl(ins_index).ci_id                   := l_ci_id_to;
         i_PaCiDirCostDetTbl(ins_index).project_id              := l_project_id;
         i_PaCiDirCostDetTbl(ins_index).task_id                 := l_task_id_tbl(i);
         i_PaCiDirCostDetTbl(ins_index).expenditure_type        := l_expenditure_type_tbl(i);
         i_PaCiDirCostDetTbl(ins_index).resource_list_member_id := l_rlmi_id_tbl(i);
         i_PaCiDirCostDetTbl(ins_index).unit_of_measure         := l_unit_of_measure_tbl(i);
         i_PaCiDirCostDetTbl(ins_index).currency_code           := l_currency_code_tbl(i);

         if l_quantity_tbl.exists(i) then
            i_PaCiDirCostDetTbl(ins_index).quantity             := l_quantity_tbl(i);
         else
            i_PaCiDirCostDetTbl(ins_index).quantity             := NULL;
         end if;

	     if l_planning_resource_rate_tbl.exists(i) then
           i_PaCiDirCostDetTbl(ins_index).planning_resource_rate := l_planning_resource_rate_tbl(i);
	     else
           i_PaCiDirCostDetTbl(ins_index).planning_resource_rate := NULL;
	     end if;

         if l_raw_cost_tbl.exists(i) then
           i_PaCiDirCostDetTbl(ins_index).raw_cost              := l_raw_cost_tbl(i);
         else
           i_PaCiDirCostDetTbl(ins_index).raw_cost              := null;
         end if;

         i_PaCiDirCostDetTbl(ins_index).burdened_cost            := NULL;
         i_PaCiDirCostDetTbl(ins_index).raw_cost_rate            := NULL;
         i_PaCiDirCostDetTbl(ins_index).burden_cost_rate         := NULL;

         i_PaCiDirCostDetTbl(ins_index).resource_assignment_id   := NULL;

         i_PaCiDirCostDetTbl(ins_index).effective_from           := NULL;
         i_PaCiDirCostDetTbl(ins_index).effective_to             := NULL;

         if l_change_reason_code.exists(i) then
            i_PaCiDirCostDetTbl(ins_index).change_reason_code    := l_change_reason_code(i);
         else
            i_PaCiDirCostDetTbl(ins_index).change_reason_code    := NULL;
         end if;

         if l_change_description.exists(i)  then
            i_PaCiDirCostDetTbl(ins_index).change_description    := l_change_description(i);
         else
            i_PaCiDirCostDetTbl(ins_index).change_description    := NULL;
         end if;

         i_PaCiDirCostDetTbl(ins_index).creation_date            := sysdate;
         i_PaCiDirCostDetTbl(ins_index).created_by               := FND_GLOBAL.USER_ID;
         i_PaCiDirCostDetTbl(ins_index).last_update_date         := sysdate;
         i_PaCiDirCostDetTbl(ins_index).last_update_by           := FND_GLOBAL.USER_ID;
         i_PaCiDirCostDetTbl(ins_index).last_update_login        := FND_GLOBAL.LOGIN_ID;
        end if;
       end loop;

      if ins_index > 0 then
        pa_ci_dir_cost_pvt.insert_row(
          p_api_version                  => l_api_version,
          p_init_msg_list                => FND_API.G_FALSE,
          x_return_status                => l_return_status,
          x_msg_count                    => l_msg_count,
          x_msg_data                     => l_msg_data,
          PPaCiDirectCostDetailsTbl      => i_PaCiDirCostDetTbl,
          XPaCiDirectCostDetailsTbl      => x_PaCiDirCostDetTbl);

        IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
          RAISE PA_API.G_EXCEPTION_ERROR;
        END IF;

      end if;

      if upd_index > 0 then
         pa_ci_dir_cost_pvt.update_row(
      	       p_api_version                  => l_api_version,
     	       p_init_msg_list                => FND_API.G_FALSE,
    	       x_return_status                => l_return_status,
    	       x_msg_count                    => l_msg_count,
    	       x_msg_data                     => l_msg_data,
    	       PPaCiDirectCostDetailsTbl      => u_PaCiDirCostDetTbl,
    	       XPaCiDirectCostDetailsTbl      => x_PaCiDirCostDetTbl);

          IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
            RAISE PA_API.G_EXCEPTION_ERROR;
          END IF;
      end if;

       update pa_ci_direct_cost_details pcdc
          set (resource_assignment_id, effective_from, effective_to,
               planning_resource_rate, burden_cost_rate,
			         raw_cost, burdened_cost) =
                  (select prac.resource_assignment_id,
                          nvl(pcdc.effective_from, pra.planning_start_date),
                          nvl(pcdc.effective_to, pra.planning_end_date),
                          prac.txn_average_raw_cost_rate,
                          prac.txn_average_burden_cost_rate,
                          decode(pcdc.quantity, null, pcdc.raw_cost,
                                    pcdc.quantity * prac.txn_average_raw_cost_rate),
                          decode(pcdc.quantity, null,
                                    pcdc.raw_cost * prac.txn_average_burden_cost_rate,
                                    pcdc.quantity * prac.txn_average_burden_cost_rate)
                     from pa_resource_assignments pra, pa_resource_asgn_curr prac
                    where pra.budget_version_id = p_bv_id
                      and pra.task_id = pcdc.task_id
                      and pra.resource_list_member_id = pcdc.resource_list_member_id
					            and prac.txn_currency_code = pcdc.currency_code
                      and prac.resource_assignment_id = pra.resource_assignment_id
                      and ((prac.total_quantity is not null and
                           nvl(pa_planning_resource_utils.get_rate_based_flag(pcdc.resource_list_member_id), 'N') = 'Y')
                           OR
                           (prac.total_txn_raw_cost is not null and
                           nvl(pa_planning_resource_utils.get_rate_based_flag(pcdc.resource_list_member_id), 'N') = 'N')))
        where ci_id =l_ci_id_to
          and ((pcdc.quantity is not null and
                nvl(pa_planning_resource_utils.get_rate_based_flag(pcdc.resource_list_member_id), 'N') = 'Y')
                OR
                (pcdc.raw_cost is not null and
                nvl(pa_planning_resource_utils.get_rate_based_flag(pcdc.resource_list_member_id), 'N') = 'N'));
   end if; --> l_task_id_tbl.count > 0
 end if;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO copy_dir_cost_det;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_FP_CI_MERGE',
                            p_procedure_name => 'copy_direct_cost_data',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
    RAISE;
end copy_direct_cost_data;
--end of PACKAGE pa_fp_ci_merge
END PA_FP_CI_MERGE;

/
