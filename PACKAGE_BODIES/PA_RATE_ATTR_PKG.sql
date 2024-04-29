--------------------------------------------------------
--  DDL for Package Body PA_RATE_ATTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RATE_ATTR_PKG" AS
/* $Header: PARATTRB.pls 120.4 2007/02/06 09:46:22 dthakker noship $ */
procedure RATE_ATTR_UPGRD(
  P_BUDGET_VER_TBL            IN   SYSTEM.PA_NUM_TBL_TYPE,
  X_RETURN_STATUS             OUT  NOCOPY VARCHAR2,
  X_MSG_COUNT                 OUT  NOCOPY NUMBER,
  X_MSG_DATA                  OUT  NOCOPY VARCHAR2) IS


    -- Bug 3787658, 06-AUG-2004, jwhite -------------------------------------------------
    -- Added column project_structure_version_id  to select cluase
    -- Bug 3799921, 26-AUG-2004, jwhite -------------------------------------------------
    -- Removed columns project_structure_version_id and wp_version_flag

    cursor get_budget_ver_csr(c_budget_version_id pa_budget_versions.budget_version_id%type) is
    select bv.budget_version_id,bv.project_id,bv.resource_list_id
    from pa_budget_versions bv
    where bv.fin_plan_type_id is not null
    and bv.budget_version_id = c_budget_version_id
    and exists (select 'X' from pa_resource_assignments ra
    where bv.budget_version_id = ra.budget_version_id);

    -- End Bug 3787658, 06-AUG-2004, jwhite ----------------------------------------------


    cursor get_res_assign_id_csr(c_budget_version_id pa_budget_versions.budget_version_id%type, c_project_id pa_projects_all.project_id%type) is
    select ra.resource_assignment_id,ra.resource_list_member_id,
    rlm.migrated_rbs_element_id,
    min(bl.start_date) min_date,max(bl.end_date) max_date
    from pa_resource_assignments ra,pa_resource_list_members rlm,pa_budget_lines bl
    where ra.budget_version_id = c_budget_version_id and
    ra.project_id = c_project_id
    AND ra.resource_list_member_id = rlm.resource_list_member_id
    AND rlm.res_format_id is not null  -- Added for bug#4765774
    and ra.budget_version_id = bl.budget_version_id
    group by ra.resource_assignment_id,ra.resource_list_member_id,rlm.migrated_rbs_element_id
    order by  ra.resource_assignment_id,ra.resource_list_member_id;


    -- End Bug 3787658, 06-AUG-2004, jwhite -------------------------------------------------


    TYPE res_assign_id_tbl is table of pa_resource_assignments.resource_assignment_id%type
    index by binary_integer;
    l_res_assign_id_tbl res_assign_id_tbl;

    TYPE rbs_element_id_tbl is table of pa_resource_list_members.migrated_rbs_element_id%type
    index by binary_integer;
    l_rbs_element_id_tbl rbs_element_id_tbl;

    TYPE max_date_tbl is table of pa_proj_period_profiles.period1_start_date%TYPE
    index by binary_integer;
    l_max_date_tbl max_date_tbl;

    TYPE min_date_tbl is table of pa_proj_period_profiles.period1_start_date%TYPE
    index by binary_integer;
    l_min_date_tbl min_date_tbl;


    l_resource_class_flag_tbl       SYSTEM.PA_VARCHAR2_1_TBL_TYPE;
    l_resource_class_code_tbl       SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
    l_resource_class_id_tbl     SYSTEM.PA_NUM_TBL_TYPE;
    l_res_type_code_tbl         SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
    l_incur_by_res_type_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
    l_person_id_tbl         SYSTEM.PA_NUM_TBL_TYPE;
    l_job_id_tbl            SYSTEM.PA_NUM_TBL_TYPE;
    l_person_type_code_tbl      SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
    l_named_role_tbl            SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
    l_bom_resource_id_tbl       SYSTEM.PA_NUM_TBL_TYPE;
    l_non_labor_resource_tbl        SYSTEM.PA_VARCHAR2_20_TBL_TYPE;
    l_inventory_item_id_tbl     SYSTEM.PA_NUM_TBL_TYPE;
    l_item_category_id_tbl      SYSTEM.PA_NUM_TBL_TYPE;
    l_project_role_id_tbl       SYSTEM.PA_NUM_TBL_TYPE;
    l_organization_id_tbl       SYSTEM.PA_NUM_TBL_TYPE;
    l_fc_res_type_code_tbl      SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
    l_expenditure_type_tbl      SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
    l_expenditure_category_tbl      SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
    l_event_type_tbl            SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
    l_revenue_category_code_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
    l_supplier_id_tbl           SYSTEM.PA_NUM_TBL_TYPE;
    l_spread_curve_id_tbl       SYSTEM.PA_NUM_TBL_TYPE;
    l_etc_method_code_tbl       SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
    l_mfc_cost_type_id_tbl      SYSTEM.PA_NUM_TBL_TYPE;
    l_incurred_by_res_flag_tbl      SYSTEM.PA_VARCHAR2_1_TBL_TYPE;
    l_incur_by_res_class_code_tbl   SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
    l_incur_by_role_id_tbl      SYSTEM.PA_NUM_TBL_TYPE;
    l_unit_of_measure_tbl       SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
    l_org_id_tbl            SYSTEM.PA_NUM_TBL_TYPE;
    l_rate_based_flag_tbl       SYSTEM.PA_VARCHAR2_1_TBL_TYPE;
    l_rate_expenditure_type_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
    l_rate_exp_func_curr_code_tbl   SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
    l_sys_rlm_ids_tbl                   SYSTEM.PA_NUM_TBL_TYPE;
    l_msg_data              VARCHAR2(2000);
    l_msg_count             NUMBER;
    l_return_status         VARCHAR2(1):= NULL;

    l_budget_version_id                  pa_budget_versions.budget_version_id%type;


    l_debug_mode varchar2(30);
    l_module_name VARCHAR2(100):= 'pa.plsql.PA_RATE_ATTR_PKG';
    l_msg_index_out                 NUMBER;
    l_data                          VARCHAR2(2000);

    l_spread_curve_id         pa_spread_curves_b.spread_curve_id%TYPE; -- Bug 3988345


    BEGIN

       -- FND_MSG_PUB.initialize; /* bug 3800485 */

       x_msg_count := 0;
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       pa_debug.init_err_stack('PA_RATE_ATTR_PKG.Rate_Attr_Upgrd');
       fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
       l_debug_mode := NVL(l_debug_mode, 'Y');
       pa_debug.set_process('PLSQL','LOG',l_debug_mode);
       IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'Entered Budget Attribute Upgrade';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

         pa_debug.g_err_stage := 'Checking for valid parameters';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;

    if (p_budget_ver_tbl.count <= 0 ) then
        IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'Budget Version='||to_char(l_budget_version_id);
               pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          END IF;
          PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                               p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    end if;

    l_sys_rlm_ids_tbl := SYSTEM.PA_NUM_TBL_TYPE();
    l_resource_class_flag_tbl    :=         SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
    l_resource_class_code_tbl    :=         SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
    l_resource_class_id_tbl    :=       SYSTEM.PA_NUM_TBL_TYPE();
    l_res_type_code_tbl    :=           SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
    l_incur_by_res_type_tbl    :=       SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
    l_person_id_tbl    :=           SYSTEM.PA_NUM_TBL_TYPE();
    l_job_id_tbl    :=              SYSTEM.PA_NUM_TBL_TYPE();
    l_person_type_code_tbl    :=        SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
    l_named_role_tbl    :=              SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
    l_bom_resource_id_tbl    :=         SYSTEM.PA_NUM_TBL_TYPE();
    l_non_labor_resource_tbl    :=          SYSTEM.PA_VARCHAR2_20_TBL_TYPE();
    l_inventory_item_id_tbl    :=       SYSTEM.PA_NUM_TBL_TYPE();
    l_item_category_id_tbl    :=        SYSTEM.PA_NUM_TBL_TYPE();
    l_project_role_id_tbl    :=         SYSTEM.PA_NUM_TBL_TYPE();
    l_organization_id_tbl    :=         SYSTEM.PA_NUM_TBL_TYPE();
    l_fc_res_type_code_tbl    :=        SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
    l_expenditure_type_tbl    :=        SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
    l_expenditure_category_tbl    :=        SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
    l_event_type_tbl    :=              SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
    l_revenue_category_code_tbl    :=       SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
    l_supplier_id_tbl    :=             SYSTEM.PA_NUM_TBL_TYPE();
    l_spread_curve_id_tbl    :=         SYSTEM.PA_NUM_TBL_TYPE();
    l_etc_method_code_tbl    :=         SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
    l_mfc_cost_type_id_tbl    :=        SYSTEM.PA_NUM_TBL_TYPE();
    l_incurred_by_res_flag_tbl    :=        SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
    l_incur_by_res_class_code_tbl    :=     SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
    l_incur_by_role_id_tbl    :=        SYSTEM.PA_NUM_TBL_TYPE();
    l_unit_of_measure_tbl    :=         SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
    l_org_id_tbl    :=              SYSTEM.PA_NUM_TBL_TYPE();
    l_rate_based_flag_tbl    :=         SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
    l_rate_expenditure_type_tbl    :=       SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
    l_rate_exp_func_curr_code_tbl    :=     SYSTEM.PA_VARCHAR2_30_TBL_TYPE();

    select spread_curve_id
    INTO   l_spread_curve_id
    from   pa_spread_curves_b
    where  spread_curve_code='FIXED_DATE';

    for j in p_budget_ver_tbl.first .. p_budget_ver_tbl.last
    loop
         l_budget_version_id := p_budget_ver_tbl(j);

         -- Budget Version Cursor Loop starts here
         for l_get_budget_ver_csr in get_budget_ver_csr(p_budget_ver_tbl(j))
         loop

            -- Resource List Assignment Cursor Loop starts here
            OPEN get_res_assign_id_csr(l_get_budget_ver_csr.budget_version_id, l_get_budget_ver_csr.project_id);
            LOOP
                 l_res_assign_id_tbl.delete;
                 l_max_date_tbl.delete;
                 l_min_date_tbl.delete;
                 l_rbs_element_id_tbl.delete;
                 l_sys_rlm_ids_tbl.delete;
                 l_resource_class_flag_tbl.delete;
                 l_resource_class_code_tbl.delete;
                 l_resource_class_id_tbl.delete;
                 l_res_type_code_tbl.delete;
                 l_person_id_tbl.delete;
                 l_job_id_tbl.delete;
                 l_person_type_code_tbl.delete;
                 l_named_role_tbl.delete;
                 l_bom_resource_id_tbl.delete;
                 l_non_labor_resource_tbl.delete;
                 l_inventory_item_id_tbl.delete;
                 l_item_category_id_tbl.delete;
                 l_project_role_id_tbl.delete;
                 l_organization_id_tbl.delete;
                 l_fc_res_type_code_tbl.delete;
                 l_expenditure_type_tbl.delete;
                 l_expenditure_category_tbl.delete;
                 l_event_type_tbl.delete;
                 l_revenue_category_code_tbl.delete;
                 l_supplier_id_tbl.delete;
                 l_unit_of_measure_tbl.delete;
                 l_spread_curve_id_tbl.delete;
                 l_etc_method_code_tbl.delete;
                 l_mfc_cost_type_id_tbl.delete;
                 l_incurred_by_res_flag_tbl.delete;
                 l_incur_by_res_class_code_tbl.delete;
                 l_Incur_by_role_id_tbl.delete;
                 l_org_id_tbl.delete;
                 l_rate_based_flag_tbl.delete;
                 l_rate_expenditure_type_tbl.delete;
                 l_rate_exp_func_curr_code_tbl.delete;
                 l_incur_by_res_type_tbl.delete;

                 FETCH get_res_assign_id_csr
                 BULK COLLECT INTO
                      l_res_assign_id_tbl,
                      l_sys_rlm_ids_tbl,
                      l_rbs_element_id_tbl,
                      l_min_date_tbl,
                      l_max_date_tbl
                 LIMIT 1000;
                 EXIT WHEN l_sys_rlm_ids_tbl.count=0;

                 -- Call the following API for getting resource attributes. The first two paramteers are IN and the remaining are OUT parameters.
                 IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage := 'Entering GET_RESOURCE_DEFAULTS API';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                 end if;

                 if (l_sys_rlm_ids_tbl.count > 0) then
                      PA_PLANNING_RESOURCE_UTILS.get_resource_defaults (
                      p_resource_list_members        =>  l_sys_rlm_ids_tbl,
                      p_project_id                   =>  l_get_budget_ver_csr.project_id,
                      x_resource_class_flag          =>  l_resource_class_flag_tbl,
                      x_resource_class_code          =>  l_resource_class_code_tbl,
                      x_resource_class_id            =>  l_resource_class_id_tbl,
                      x_res_type_code                =>  l_res_type_code_tbl,
                      x_incur_by_res_type            =>  l_incur_by_res_type_tbl,
                      x_person_id                    =>  l_person_id_tbl,
                      x_job_id                       =>  l_job_id_tbl,
                      x_person_type_code             =>  l_person_type_code_tbl,
                      x_named_role                   =>  l_named_role_tbl,
                      x_bom_resource_id              =>  l_bom_resource_id_tbl,
                      x_non_labor_resource           =>  l_non_labor_resource_tbl,
                      x_inventory_item_id            =>  l_inventory_item_id_tbl,
                      x_item_category_id             =>  l_item_category_id_tbl,
                      x_project_role_id              =>  l_project_role_id_tbl,
                      x_organization_id              =>  l_organization_id_tbl,
                      x_fc_res_type_code             =>  l_fc_res_type_code_tbl,
                      x_expenditure_type             =>  l_expenditure_type_tbl,
                      x_expenditure_category         =>  l_expenditure_category_tbl,
                      x_event_type                   =>  l_event_type_tbl,
                      x_revenue_category_code        =>  l_revenue_category_code_tbl,
                      x_supplier_id                  =>  l_supplier_id_tbl,
                      x_unit_of_measure              =>  l_unit_of_measure_tbl,
                      x_spread_curve_id              =>  l_spread_curve_id_tbl,
                      x_etc_method_code              =>  l_etc_method_code_tbl,
                      x_mfc_cost_type_id             =>  l_mfc_cost_type_id_tbl,
                      x_incurred_by_res_flag         =>  l_incurred_by_res_flag_tbl,
                      x_incur_by_res_class_code      =>  l_incur_by_res_class_code_tbl,
                      x_Incur_by_role_id             =>  l_Incur_by_role_id_tbl,
                      x_org_id                       =>  l_org_id_tbl,
                      x_rate_based_flag              =>  l_rate_based_flag_tbl,
                      x_rate_expenditure_type        =>  l_rate_expenditure_type_tbl,
                      x_rate_func_curr_code          =>  l_rate_exp_func_curr_code_tbl,
                      x_msg_data                     =>  l_msg_data,
                      x_msg_count                    =>  l_msg_count,
                      x_return_status                =>  l_return_status);

                      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                      END IF;

                 end if;


                 IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage := 'Exited GET_RESOURCE_DEFAULTS API';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                 END IF;

                 -- Check if the called API returns succes
                 if (l_return_status =  'S') then

                     IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Updating pa_resource_assignments table';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                     END IF;


                     FORALL j IN l_res_assign_id_tbl.FIRST..l_res_assign_id_tbl.LAST
                         update pa_resource_assignments
                         set
                         record_version_number             = record_version_number + 1,
                         rbs_element_id                    = l_rbs_element_id_tbl(j),
                         resource_class_code               = l_resource_class_code_tbl(j) ,
                         spread_curve_id                   = decode(l_spread_curve_id,l_spread_curve_id_tbl(j),NULL,l_spread_curve_id_tbl(j)),
                         sp_fixed_date                     = NULL,
                         etc_method_code                   = l_etc_method_code_tbl(j),
                         res_type_code                     = l_res_type_code_tbl(j),
                         organization_id                   = l_organization_id_tbl(j),
                         job_id                            = l_job_id_tbl(j),
                         person_id                         = l_person_id_tbl(j),
                         expenditure_type                  = l_expenditure_type_tbl(j),
                         expenditure_category              = l_expenditure_category_tbl(j),
                         revenue_category_code             = l_revenue_category_code_tbl(j),
                         event_type                        = l_event_type_tbl(j),
                         supplier_id                       = l_supplier_id_tbl(j),
                         project_role_id                   = l_project_role_id_tbl(j),
                         person_type_code                  = l_person_type_code_tbl(j),
                         non_labor_resource                = l_non_labor_resource_tbl(j),
                         bom_resource_id                   = l_bom_resource_id_tbl(j),
                         inventory_item_id                 = l_inventory_item_id_tbl(j),
                         item_category_id                  = l_item_category_id_tbl(j),
                         transaction_source_code           = null,
                         mfc_cost_type_id                  = l_mfc_cost_type_id_tbl(j),
                         procure_resource_flag             = null,
                         incurred_by_res_flag              = l_incurred_by_res_flag_tbl(j),
                         rate_job_id                       = null,
                         rate_expenditure_type             = l_rate_expenditure_type_tbl(j),
                         rate_based_flag                   = l_rate_based_flag_tbl(j),
                         use_task_schedule_flag            = null,
                         rate_exp_func_curr_code           = l_rate_exp_func_curr_code_tbl(j),
                         rate_expenditure_org_id           = l_org_id_tbl(j),    /* bug: 3799921: assigned local var */
                         incur_by_res_class_code           = l_incur_by_res_class_code_tbl(j),
                         incur_by_role_id                  = l_incur_by_role_id_tbl(j),
                         resource_class_flag               = l_resource_class_flag_tbl(j),
                         named_role                        = l_named_role_tbl(j),
                         planning_start_date               = l_min_date_tbl(j),
                         planning_end_date                 = l_max_date_tbl(j),
                         fc_res_type_code                  = l_fc_res_type_code_tbl(j),          /* Bug 3799921 */
                         unit_of_measure                   = l_unit_of_measure_tbl(j),           /* Bug 3799921 */
                         resource_rate_based_flag          = l_rate_based_flag_tbl(j)            /* Bug 5144013: IPM Changes */
                         where resource_assignment_id = l_res_assign_id_tbl(j);
                 end if;

            end loop; -- Resource List Assignment Cursor Loop ends here
            CLOSE get_res_assign_id_csr;

            IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage := 'Updating pa_resource_list_assignments table';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            END IF;


         end loop;
         -- Budget Version Cursor loop ends here.
    end loop;  -- parameter table loop
EXCEPTION
      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc then
      l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                   (p_encoded         => FND_API.G_TRUE
                    ,p_msg_index      => 1
                    ,p_msg_count      => l_msg_count
                    ,p_msg_data       => l_msg_data
                    ,p_data           => l_data
                    ,p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
        ELSE
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
        END IF;

        IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Invalid Arguments Passed';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
        END IF;
         x_return_status:= FND_API.G_RET_STS_ERROR;
        pa_debug.write_file('RATE_ATTR_UPGRD: Upgrade has failed for the budget_version: '||l_budget_version_id,5);
        pa_debug.write_file('RATE_ATTR_UPGRD: Failure Reason:'||x_msg_data,5);
        pa_debug.reset_err_stack;
        -- ROLLBACK;  /* Commented-out rollback to avoid issues the the UPG savepoint */
        RAISE;
      WHEN OTHERS THEN
        if get_budget_ver_csr%ISOPEN then
           close get_budget_ver_csr;
        end if;
        if get_res_assign_id_csr%ISOPEN then
           close get_res_assign_id_csr;
        end if;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;

        FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_RATE_ATTR_PKG',p_procedure_name  => 'RATE_ATTR_UPGRD');
        IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
        END IF;

        pa_debug.write_file('RATE_ATTR_UPGRD : Upgrade has failed for the budget version '||l_budget_version_id,5);
        pa_debug.write_file('RATE_ATTR_UPGRD: Failure Reason:'||pa_debug.G_Err_Stack,5);
        pa_debug.reset_err_stack;
        -- ROLLBACK; /* Commented-out rollback to avoid issues the the UPG savepoint */
        RAISE;
end RATE_ATTR_UPGRD;
end PA_RATE_ATTR_PKG;

/
