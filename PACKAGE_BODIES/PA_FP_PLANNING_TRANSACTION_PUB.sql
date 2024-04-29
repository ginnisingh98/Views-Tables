--------------------------------------------------------
--  DDL for Package Body PA_FP_PLANNING_TRANSACTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_PLANNING_TRANSACTION_PUB" AS
/* $Header: PAFPPTPB.pls 120.33.12010000.17 2010/06/01 20:28:49 rbruno ship $ */
 g_module_name   VARCHAR2(100) := 'pa.plsql.PA_FP_PLANNING_TRANSACTION_PUB';

--This pl/sql table will be used by the method get_rbs_element_id. This should not be used in other procedures
-- l_ra_id_rbs_element_id_map_tbl PA_PLSQL_DATATYPES.IdTabTyp;

--This pl/sql table will be used by DUP_EXISTS. This should not be used in other APIs
l_task_id_rlm_id_dup_tbl  PA_PLSQL_DATATYPES.IdTabTyp;

PROCEDURE print_msg(p_msg  varchar2
		,p_module_name  Varchar2 Default NULL) IS

	--pragma autonomous_transaction ;
	l_module_name Varchar2(100) := p_module_name;
BEGIN
	If l_module_name is NULL Then
		l_module_name := g_module_name;
	End If;
	pa_debug.write( l_module_name,p_msg,3);
	/*
	--dbms_output.put_line(p_msg);
	INSERT INTO PA_FP_CALCULATE_LOG
	(SESSIONID
	,SEQ_NUMBER
	,LOG_MESSAGE)
	VALUES
	(userenv('sessionid')
	,HR.PAY_US_GARN_FEE_RULES_S.nextval
	,substr(P_MSG,1,240)
	);
	COMMIT;
	*/
END print_msg;
 --------------------------------
 --User Defined Exceptions if any
 --------------------------------
 --Bug 4152749. The API is changed for the calculate API enhancements. Replaced the existing logic with the new logic to
 --pass the old/new values for required resource attribs to calcualte API so that it takes care of manipulating the
 --budget lines based on the changes.
 --This is private procedure. This replaces the derive_parameters_for_calc_api in the previous API
 --This API
 ------1.Will detect the changes in the rbs_element_id and call the reporting lines API to negate the amounts
 --------for the old rbs_element_id
 ------2.Prepare pl/sql tbls containing Old/New Values for MFC Cost Type Id, Spread Curve Id, SP Fixed Date,
 ------- Planning Start/End Dates and another pl/sql tbl which indicates whether a change in RLM has occurred or not.
 ------3.Gives the new rbs_element_id for each input RA ID as output.
 --The values for p_context are 'BUDGET', 'FORECAST', 'WORKPLAN' and 'TASK_ASSIGNMENT'
PROCEDURE Process_res_chg_Derv_calc_prms
(
     p_context                          IN      VARCHAR2
    ,p_calling_context                  IN      VARCHAR2 DEFAULT NULL  -- Added for Bug 6856934
    ,p_budget_version_id                IN      Pa_budget_versions.budget_version_id%TYPE
    ,p_resource_assignment_id_tbl       IN      SYSTEM.PA_NUM_TBL_TYPE
    ,p_resource_list_member_id_tbl      IN      SYSTEM.PA_NUM_TBL_TYPE
    ,p_planning_start_date_tbl          IN      SYSTEM.PA_DATE_TBL_TYPE
    ,p_planning_end_date_tbl            IN      SYSTEM.PA_DATE_TBL_TYPE
    ,p_spread_curve_id_tbl              IN      SYSTEM.PA_NUM_TBL_TYPE
    ,p_sp_fixed_date_tbl                IN      SYSTEM.PA_DATE_TBL_TYPE
    ,p_txn_currency_code_tbl            IN      SYSTEM.PA_VARCHAR2_15_TBL_TYPE
    ,p_inventory_item_id_tbl            IN      SYSTEM.PA_NUM_TBL_TYPE
    ,p_expenditure_type_tbl             IN      SYSTEM.pa_varchar2_30_tbl_type
    ,p_person_id_tbl                    IN      SYSTEM.PA_NUM_TBL_TYPE
    ,p_job_id_tbl                       IN      SYSTEM.PA_NUM_TBL_TYPE
    ,p_organization_id_tbl              IN      SYSTEM.PA_NUM_TBL_TYPE
    ,p_event_type_tbl                   IN      SYSTEM.pa_varchar2_30_tbl_type
    ,p_expenditure_category_tbl         IN      SYSTEM.pa_varchar2_30_tbl_type
    ,p_revenue_category_code_tbl        IN      SYSTEM.pa_varchar2_30_tbl_type
    ,p_item_category_id_tbl             IN      SYSTEM.PA_NUM_TBL_TYPE
    ,p_bom_resource_id_tbl              IN      SYSTEM.PA_NUM_TBL_TYPE
    ,p_project_role_id_tbl              IN      SYSTEM.PA_NUM_TBL_TYPE
    ,p_person_type_code_tbl             IN      SYSTEM.pa_varchar2_30_tbl_type
    ,p_supplier_id_tbl                  IN      SYSTEM.PA_NUM_TBL_TYPE
    ,p_named_role_tbl                   IN      SYSTEM.pa_varchar2_80_tbl_type
    ,p_mfc_cost_type_id_tbl             IN      SYSTEM.PA_NUM_TBL_TYPE
    ,p_fixed_date_sp_id                 IN      pa_spread_curves_b.spread_curve_id%TYPE -- Added for Bug 3607061
    ,px_total_qty_tbl                   IN OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
    ,px_total_raw_cost_tbl              IN OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
    ,px_total_burdened_cost_tbl         IN OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
    ,px_total_revenue_tbl               IN OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
    ,px_raw_cost_rate_tbl               IN OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
    ,px_b_cost_rate_tbl                 IN OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
    ,px_bill_rate_tbl                   IN OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
    ,px_raw_cost_override_rate_tbl      IN OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
    ,px_b_cost_rate_override_tbl        IN OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
    ,px_bill_rate_override_tbl          IN OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
    ,x_rbs_element_id_tbl                  OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
    ,x_txn_accum_header_id_tbl             OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
    ,x_mfc_cost_type_id_old_tbl            OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
    ,x_mfc_cost_type_id_new_tbl            OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
    ,x_spread_curve_id_old_tbl             OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
    ,x_spread_curve_id_new_tbl             OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
    ,x_sp_fixed_date_old_tbl               OUT  NOCOPY SYSTEM.PA_DATE_TBL_TYPE --File.Sql.39 bug 4440895
    ,x_sp_fixed_date_new_tbl               OUT  NOCOPY SYSTEM.PA_DATE_TBL_TYPE --File.Sql.39 bug 4440895
    ,x_plan_start_date_old_tbl             OUT  NOCOPY SYSTEM.PA_DATE_TBL_TYPE --File.Sql.39 bug 4440895
    ,x_plan_start_date_new_tbl             OUT  NOCOPY SYSTEM.PA_DATE_TBL_TYPE --File.Sql.39 bug 4440895
    ,x_plan_end_date_old_tbl               OUT  NOCOPY SYSTEM.PA_DATE_TBL_TYPE --File.Sql.39 bug 4440895
    ,x_plan_end_date_new_tbl               OUT  NOCOPY SYSTEM.PA_DATE_TBL_TYPE --File.Sql.39 bug 4440895
    ,x_rlm_id_change_flag_tbl              OUT  NOCOPY SYSTEM.PA_VARCHAR2_1_TBL_TYPE --File.Sql.39 bug 4440895
    ,x_return_status                       OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_data                            OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count                           OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
) IS

      CURSOR c_plan_ver_settings_csr
      IS
      SELECT nvl(pfo.cost_resource_list_id, nvl(pfo.revenue_resource_list_id, pfo.all_resource_list_id)) resource_list_id
            ,pfo.rbs_version_id rbs_version_id
            ,pbv.ci_id ci_id
            ,pbv.etc_start_date etc_start_date
            ,pbv.wp_version_flag wp_version_flag
      FROM   pa_proj_fp_options pfo
            ,pa_budget_versions pbv
      WHERE  pfo.fin_plan_version_id=p_budget_version_id
      AND    pbv.budget_version_id=p_budget_version_id;


      CURSOR c_data_in_db_csr(c_resource_asg_id pa_resource_assignments.resource_assignment_id%TYPE)
      IS
      SELECT sum(quantity) quantity
       FROM  pa_budget_lines
      WHERE resource_assignment_id = c_resource_asg_id;
--  ORDER BY resource_assignment_id,txn_currency_code;

      l_data_in_db_rec    c_data_in_db_csr%ROWTYPE;

      l_plan_ver_settings_rec c_plan_ver_settings_csr%ROWTYPE;

  --Start of variables used for debugging
      l_msg_count                    NUMBER :=0;
      l_data                         VARCHAR2(2000);
      l_msg_data                     VARCHAR2(2000);
      l_error_msg_code               VARCHAR2(30);
      l_msg_index_out                NUMBER;
      l_return_status                VARCHAR2(2000);
      l_debug_mode                   VARCHAR2(30);
      l_module_name                  VARCHAR2(100):='PAFPPTPB.Process_res_chg_Derv_calc_prms';
  --End of variables used for debugging

      l_ra_id_count                  NUMBER := 0;
      l_rbs_map_index                NUMBER:=0;

      l_resource_class_code_tbl      SYSTEM.pa_varchar2_30_tbl_type :=SYSTEM.pa_varchar2_30_tbl_type();
      l_rate_based_flag_tbl          SYSTEM.pa_varchar2_1_tbl_type  :=SYSTEM.pa_varchar2_1_tbl_type();
      l_ra_id_rbs_prm_tbl            SYSTEM.pa_num_tbl_type         :=SYSTEM.pa_num_tbl_type();
      l_person_id_rbs_prm_tbl        SYSTEM.pa_num_tbl_type         :=SYSTEM.pa_num_tbl_type();
      l_job_id_rbs_prm_tbl           SYSTEM.pa_num_tbl_type         :=SYSTEM.pa_num_tbl_type();
      l_organization_id_rbs_prm_tbl  SYSTEM.pa_num_tbl_type         :=SYSTEM.pa_num_tbl_type();
      l_event_type_rbs_prm_tbl       SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_exp_category_rbs_prm_tbl     SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_rev_cat_code_rbs_prm_tbl     SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_inv_item_id_rbs_prm_tbl      SYSTEM.pa_num_tbl_type         :=SYSTEM.pa_num_tbl_type();
      l_item_cat_id_rbs_prm_tbl      SYSTEM.pa_num_tbl_type         :=SYSTEM.pa_num_tbl_type();
      l_bom_res_id_rbs_prm_tbl       SYSTEM.pa_num_tbl_type         :=SYSTEM.pa_num_tbl_type();
      l_per_type_code_rbs_prm_tbl    SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_supplier_id_rbs_prm_tbl      SYSTEM.pa_num_tbl_type         :=SYSTEM.pa_num_tbl_type();
      l_rbs_element_id_prm_tbl       SYSTEM.pa_num_tbl_type         :=SYSTEM.pa_num_tbl_type();
      l_inventory_item_id_tbl        SYSTEM.pa_num_tbl_type         :=SYSTEM.pa_num_tbl_type();
      l_expenditure_type_tbl         SYSTEM.pa_varchar2_30_tbl_type :=SYSTEM.pa_varchar2_30_tbl_type();
      l_person_id_tbl                SYSTEM.pa_num_tbl_type         :=SYSTEM.pa_num_tbl_type();
      l_job_id_tbl                   SYSTEM.pa_num_tbl_type         :=SYSTEM.pa_num_tbl_type();
      l_organization_id_tbl          SYSTEM.pa_num_tbl_type         :=SYSTEM.pa_num_tbl_type();
      l_event_type_tbl               SYSTEM.pa_varchar2_30_tbl_type :=SYSTEM.pa_varchar2_30_tbl_type();
      l_expenditure_category_tbl     SYSTEM.pa_varchar2_30_tbl_type :=SYSTEM.pa_varchar2_30_tbl_type();
      l_revenue_category_code_tbl    SYSTEM.pa_varchar2_30_tbl_type :=SYSTEM.pa_varchar2_30_tbl_type();
      l_item_category_id_tbl         SYSTEM.pa_num_tbl_type         :=SYSTEM.pa_num_tbl_type();
      l_bom_resource_id_tbl          SYSTEM.pa_num_tbl_type         :=SYSTEM.pa_num_tbl_type();
      l_project_role_id_tbl          SYSTEM.pa_num_tbl_type         :=SYSTEM.pa_num_tbl_type();
      l_person_type_code_tbl         SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_supplier_id_tbl              SYSTEM.pa_num_tbl_type         :=SYSTEM.pa_num_tbl_type();
      l_txn_src_typ_code_rbs_prm_tbl SYSTEM.pa_varchar2_30_tbl_type :=SYSTEM.pa_varchar2_30_tbl_type();
      l_exp_type_rbs_prm_tbl         SYSTEM.pa_varchar2_30_tbl_type :=SYSTEM.pa_varchar2_30_tbl_type();
      l_non_labor_resource_tbl       SYSTEM.pa_varchar2_20_tbl_type :=SYSTEM.pa_varchar2_20_tbl_type();
      l_non_labor_res_rbs_prm_tbl    SYSTEM.pa_varchar2_20_tbl_type :=SYSTEM.pa_varchar2_20_tbl_type();
      l_named_role_tbl               SYSTEM.pa_varchar2_80_tbl_type :=SYSTEM.pa_varchar2_80_tbl_type();
      l_project_role_id_rbs_prm_tbl  SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
      l_named_role_rbs_prm_tbl       SYSTEM.pa_varchar2_80_tbl_type := SYSTEM.pa_varchar2_80_tbl_type();
      l_txn_source_id_tbl            SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
      l_res_list_member_id_tbl       SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
      l_txn_accum_header_id_prm_tbl  SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
      l_task_id_tbl                  SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
      -- Added for Bug 3762278
      l_project_name                 pa_projects_all.name%TYPE;
      l_task_name                    pa_proj_elements.name%TYPE;
      l_resource_name                pa_resource_list_members.alias%TYPE;

      l_task_id_rbs_prm_tbl          SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
      l_rbs_elem_id_rbs_prm_tbl      SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
      l_rbf_rbs_prm_tbl              SYSTEM.pa_varchar2_1_tbl_type  := SYSTEM.pa_varchar2_1_tbl_type();
      l_res_class_code_rbs_prm_tbl   SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();

      l_txn_currency_code_tbl        SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();

      --Bug 4083605
      l_actuals_start_date           pa_budget_lines.start_date%TYPE;
      l_actuals_end_date             pa_budget_lines.start_date%TYPE;

	/*Bug fix: 5752337 */
	CURSOR get_line_info (p_resource_assignment_id IN NUMBER) IS
        SELECT ppa.name project_name
               ,pt.name task_name
               ,prl.alias resource_name
        FROM pa_projects_all ppa
               ,pa_proj_elements pt
               ,pa_resource_list_members prl
               ,pa_resource_assignments pra
        WHERE pra.resource_assignment_id = p_resource_assignment_id
        AND ppa.project_id = pra.project_id
        AND pt.proj_element_id(+) = pra.task_id
        AND prl.resource_list_member_id = pra.resource_list_member_id;

	/* Bug fix:5759413 */
	CURSOR get_rateOvrds ( p_resource_assignment_id IN NUMBER) IS
	SELECT rtx.txn_raw_cost_rate_override
		,rtx.txn_burden_cost_rate_override
		,rtx.txn_bill_rate_override
	FROM pa_resource_asgn_curr rtx
	WHERE rtx.resource_assignment_id = p_resource_assignment_id;

	l_rtx_rateOvrds_rec  get_rateOvrds%ROWTYPE;

  BEGIN

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'N');
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
IF l_debug_mode = 'Y' THEN
    PA_DEBUG.Set_Curr_Function( p_function   => 'plan_txn_pub.drv_prms_for_calc',
                                p_debug_mode => l_debug_mode );
END IF;
-----------------------------------------------------------------------------
-- Validating input paramters p_context and p_budget_version_id vannot be null
-----------------------------------------------------------------------------
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Validating input parameters';
        print_msg(pa_debug.g_err_stage,l_module_name);
    END IF;

    IF ((p_context IS NULL) OR (p_budget_version_id IS NULL))  THEN
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Required parameter is null - p_context : ' || p_context;
            pa_debug.write(l_module_name ,pa_debug.g_err_stage,5);

            pa_debug.g_err_stage:='Required parameter is null - p_budget_version_id : ' || p_budget_version_id;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                             p_token1         => 'PROCEDURENAME',
                             p_value1         => l_module_name);
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    l_ra_id_count := p_resource_assignment_id_tbl.COUNT;

    IF l_ra_id_count = 0 THEN
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Validating input parameters - No resource assignment id is passed -raising excp.';
            print_msg(pa_debug.g_err_stage,l_module_name);
        END IF;
	IF l_debug_mode = 'Y' THEN
	        pa_debug.reset_curr_function;
	END IF;
        RETURN;
    END IF;
--dbms_output.put_line('d2');
    --Extending the output pl/sql tables
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Extending input params';
        print_msg(pa_debug.g_err_stage,l_module_name);
    END IF;
    x_rbs_element_id_tbl       := SYSTEM.PA_NUM_TBL_TYPE();
    x_txn_accum_header_id_tbl  := SYSTEM.PA_NUM_TBL_TYPE();
    x_mfc_cost_type_id_old_tbl := SYSTEM.PA_NUM_TBL_TYPE();
    x_mfc_cost_type_id_new_tbl := SYSTEM.PA_NUM_TBL_TYPE();
    x_spread_curve_id_old_tbl  := SYSTEM.PA_NUM_TBL_TYPE();
    x_spread_curve_id_new_tbl  := SYSTEM.PA_NUM_TBL_TYPE();
    x_sp_fixed_date_old_tbl    := SYSTEM.PA_DATE_TBL_TYPE();
    x_sp_fixed_date_new_tbl    := SYSTEM.PA_DATE_TBL_TYPE();
    x_plan_start_date_old_tbl  := SYSTEM.PA_DATE_TBL_TYPE();
    x_plan_start_date_new_tbl  := SYSTEM.PA_DATE_TBL_TYPE();
    x_plan_end_date_old_tbl    := SYSTEM.PA_DATE_TBL_TYPE();
    x_plan_end_date_new_tbl    := SYSTEM.PA_DATE_TBL_TYPE();
    x_rlm_id_change_flag_tbl   := SYSTEM.pa_varchar2_1_tbl_type();

    x_rbs_element_id_tbl.extend(p_resource_assignment_id_tbl.last);
    x_txn_accum_header_id_tbl.extend(p_resource_assignment_id_tbl.last);
    x_mfc_cost_type_id_old_tbl.extend(p_resource_assignment_id_tbl.last);
    x_mfc_cost_type_id_new_tbl.extend(p_resource_assignment_id_tbl.last);
    x_spread_curve_id_old_tbl.extend(p_resource_assignment_id_tbl.last);
    x_spread_curve_id_new_tbl.extend(p_resource_assignment_id_tbl.last);
    x_sp_fixed_date_old_tbl.extend(p_resource_assignment_id_tbl.last);
    x_sp_fixed_date_new_tbl.extend(p_resource_assignment_id_tbl.last);
    x_plan_start_date_old_tbl.extend(p_resource_assignment_id_tbl.last);
    x_plan_start_date_new_tbl.extend(p_resource_assignment_id_tbl.last);
    x_plan_end_date_old_tbl.extend(p_resource_assignment_id_tbl.last);
    x_plan_end_date_new_tbl.extend(p_resource_assignment_id_tbl.last);
    x_rlm_id_change_flag_tbl.extend(p_resource_assignment_id_tbl.last);

    --Open the plan version cursor to get the plan version settings. This will be used in the later part
    --of the code
    OPEN c_plan_ver_settings_csr;
    FETCH c_plan_ver_settings_csr INTO l_plan_ver_settings_rec;
    IF c_plan_ver_settings_csr%NOTFOUND THEN

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='0 rows returned by c_plan_ver_settings_csr';
           pa_debug.write(l_module_name,pa_debug.g_err_stage, 5);
        END IF;
        CLOSE c_plan_ver_settings_csr;
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;
    CLOSE c_plan_ver_settings_csr;
    --dbms_output.put_line('6.1');

    ----------------------------------------------------------------------------------------------------------
    --The logic below is placed to pass the data required by the calculate API. The tbls containing Old/New
    --values for mfc cost type id, plan start/end dates, spread curve and sp fixed dates are prepared. A tbl
    --to indicate a changed in rbs mapping is also prepared
    ---------------------------------------------------------------------------------------------------------
    l_txn_currency_code_tbl.extend(p_resource_assignment_id_tbl.COUNT);

    l_inventory_item_id_tbl.extend(p_resource_assignment_id_tbl.COUNT);
    l_expenditure_type_tbl.extend(p_resource_assignment_id_tbl.COUNT);
    l_person_id_tbl.extend(p_resource_assignment_id_tbl.COUNT);
    l_job_id_tbl.extend(p_resource_assignment_id_tbl.COUNT);
    l_organization_id_tbl.extend(p_resource_assignment_id_tbl.COUNT);
    l_event_type_tbl.extend(p_resource_assignment_id_tbl.COUNT);
    l_expenditure_category_tbl.extend(p_resource_assignment_id_tbl.COUNT);
    l_revenue_category_code_tbl.extend(p_resource_assignment_id_tbl.COUNT);
    l_item_category_id_tbl.extend(p_resource_assignment_id_tbl.COUNT);
    l_bom_resource_id_tbl.extend(p_resource_assignment_id_tbl.COUNT);
    l_project_role_id_tbl.extend(p_resource_assignment_id_tbl.COUNT);
    l_person_type_code_tbl.extend(p_resource_assignment_id_tbl.COUNT);
    l_supplier_id_tbl.extend(p_resource_assignment_id_tbl.COUNT);
    l_named_role_tbl.extend(p_resource_assignment_id_tbl.COUNT);
    --              l_rate_func_curr_code_tbl
    l_resource_class_code_tbl.extend(p_resource_assignment_id_tbl.COUNT);
    l_rate_based_flag_tbl.extend(p_resource_assignment_id_tbl.COUNT);
    l_non_labor_resource_tbl.extend(p_resource_assignment_id_tbl.COUNT);
    l_task_id_tbl.extend(p_resource_assignment_id_tbl.COUNT);

    --Added the check for FND_API.G_MISS_XXX  in the below decodes as the UI can pass input parameters
    --as FND_API.G_MISS_XXX even if the existing value of the attribute is NULL. NOTE: The input parameter
    --to update_planning_transactions should be NULL if the corresponding column in pa_resource_assignments
    --should not be changed and the input parameter should be FND_API.G_MISS_XXX if thhe corresponding column
    --in pa_resource_assignments should be nulled out.
    FOR i IN p_resource_assignment_id_tbl.FIRST .. p_resource_assignment_id_tbl.LAST  LOOP

                   --dbms_output.put_line('6.2 '||p_resource_assignment_id_tbl(i) );

        IF l_debug_mode = 'Y' THEN

           pa_debug.g_err_stage:='p_project_role_id_tbl('||i||') is '||p_project_role_id_tbl(i);
           print_msg(pa_debug.g_err_stage,l_module_name);
           pa_debug.g_err_stage:='p_resource_list_member_id_tbl('||i||') is '||p_resource_list_member_id_tbl(i);
           print_msg(pa_debug.g_err_stage,l_module_name);
           pa_debug.g_err_stage:='p_planning_start_date_tbl('||i||') is '||p_planning_start_date_tbl(i);
           print_msg(pa_debug.g_err_stage,l_module_name);
           pa_debug.g_err_stage:='p_planning_end_date_tbl('||i||') is '||p_planning_end_date_tbl(i);
           print_msg(pa_debug.g_err_stage,l_module_name);
           pa_debug.g_err_stage:='p_spread_curve_id_tbl('||i||') is '||p_spread_curve_id_tbl(i);
           print_msg(pa_debug.g_err_stage,l_module_name);
           pa_debug.g_err_stage:='p_sp_fixed_date_tbl('||i||') is '||p_sp_fixed_date_tbl(i);
           print_msg(pa_debug.g_err_stage,l_module_name);
           pa_debug.g_err_stage:='p_mfc_cost_type_id_tbl('||i||') is '||p_mfc_cost_type_id_tbl(i);
           print_msg(pa_debug.g_err_stage,l_module_name);


        END IF;

        --IF NULLs are passed for all the resource attributes, based on which the re-spread/re-derivation of amts will happen, then
        --NULLs can be passed for both OLD/NEW resource attr parameters of calculate API to indicate that none of the resource
        --attrs have changed.
        IF p_project_role_id_tbl(i)         IS NULL AND
           p_resource_list_member_id_tbl(i) IS NULL AND
           p_planning_start_date_tbl(i)     IS NULL AND
           p_planning_end_date_tbl(i)       IS NULL AND
           p_spread_curve_id_tbl(i)         IS NULL AND
           p_sp_fixed_date_tbl(i)           IS NULL AND
           p_mfc_cost_type_id_tbl(i)        IS NULL THEN

            IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='All the resource attrs passed are NULL and hence No change. Not firing the Select';
               print_msg(pa_debug.g_err_stage,l_module_name);
            END IF;

            x_mfc_cost_type_id_old_tbl(i)  := NULL;
            x_mfc_cost_type_id_new_tbl(i)  := NULL;
            x_spread_curve_id_old_tbl(i)   := NULL;
            x_spread_curve_id_new_tbl(i)   := NULL;
            x_sp_fixed_date_old_tbl(i)     := NULL;
            x_sp_fixed_date_new_tbl(i)     := NULL;
            x_plan_start_date_old_tbl(i)   := NULL;
            x_plan_start_date_new_tbl(i)   := NULL;
            x_plan_end_date_old_tbl(i)     := NULL;
            x_plan_end_date_new_tbl(i)     := NULL;
            x_rlm_id_change_flag_tbl(i)    := 'N';
            --select the rbs_element_id and txn accum header id so as to pass them to update_planning_transactions API
            SELECT rbs_element_id,
                   txn_accum_header_id
            INTO   x_rbs_element_id_tbl(i),
                   x_txn_accum_header_id_tbl(i)
            FROM   pa_resource_assignments
            WHERE  resource_assignment_id = p_resource_assignment_id_tbl(i);

        --If Non Null values are passed then the existing values should be compared with the passed values to find out
        --the changes. The Old Values should be passed in _old_.._tab parameters of calculate API and new values should
        --be passed in _new_.._tabl parameters of calculate API.
        ELSE

            SELECT
               DECODE(DECODE(NVL(p_project_role_id_tbl(i),project_role_id),
                              FND_API.G_MISS_NUM, decode(project_role_id,null,0,1),
                             project_role_id,0,
                             1)+
                      DECODE(NVL(p_resource_list_member_id_tbl(i),resource_list_member_id),
                              FND_API.G_MISS_NUM, decode(resource_list_member_id,null,0,1),
                              resource_list_member_id, 0,
                              1),
                      0, 'N',
                      'Y'),--Indicates whether the rbs mapping api should be called or not
               mfc_cost_type_id,
               NVL(p_mfc_cost_type_id_tbl(i),mfc_cost_type_id),
               spread_curve_id,
               NVL(p_spread_curve_id_tbl(i),spread_curve_id),
               sp_fixed_date,
               DECODE(nvl(p_spread_curve_id_tbl(i),spread_curve_id),
                      p_fixed_date_sp_id,DECODE(DECODE(p_sp_fixed_date_tbl(i),
                                                       FND_API.G_MISS_DATE,to_date(null),
                                                       nvl(p_sp_fixed_date_tbl(i),sp_fixed_date))
                                               ,to_date(null),DECODE (p_planning_start_date_tbl(i),
                                                                      FND_API.G_MISS_DATE,to_date(null),
                                                                      nvl(p_planning_start_date_tbl(i),planning_start_date))
                                               ,nvl(p_sp_fixed_date_tbl(i),sp_fixed_date))
                      ,to_date(null)),
               planning_start_date,
               NVL(p_planning_start_date_tbl(i),planning_start_date),
               planning_end_date,
               NVL(p_planning_end_date_tbl(i),planning_end_date),
               DECODE (p_txn_currency_code_tbl(i), FND_API.G_MISS_CHAR,null,nvl(p_txn_currency_code_tbl(i),pbl.txn_currency_code)),
               DECODE (p_inventory_item_id_tbl(i), FND_API.G_MISS_NUM,null,nvl(p_inventory_item_id_tbl(i),inventory_item_id)) ,
               DECODE (p_expenditure_type_tbl(i), FND_API.G_MISS_CHAR,null,nvl(p_expenditure_type_tbl(i),expenditure_type)),
               DECODE (p_person_id_tbl(i), FND_API.G_MISS_NUM,null,nvl(p_person_id_tbl(i),person_id)) ,
               DECODE (p_job_id_tbl(i), FND_API.G_MISS_NUM,null,nvl(p_job_id_tbl(i),job_id)) ,
               DECODE (p_organization_id_tbl(i), FND_API.G_MISS_NUM,null,nvl(p_organization_id_tbl(i),organization_id)) ,
               DECODE (p_event_type_tbl(i), FND_API.G_MISS_CHAR,null,nvl(p_event_type_tbl(i),event_type)) ,
               DECODE (p_expenditure_category_tbl(i), FND_API.G_MISS_CHAR,null,nvl(p_expenditure_category_tbl(i),expenditure_category)) ,
               DECODE (p_revenue_category_code_tbl(i), FND_API.G_MISS_CHAR,null,nvl(p_revenue_category_code_tbl(i),revenue_category_code)) ,
               DECODE (p_item_category_id_tbl(i), FND_API.G_MISS_NUM,null,nvl(p_item_category_id_tbl(i),item_category_id)) ,
               DECODE (p_bom_resource_id_tbl(i), FND_API.G_MISS_NUM,null,nvl(p_bom_resource_id_tbl(i),bom_resource_id)) ,
               DECODE (p_project_role_id_tbl(i), FND_API.G_MISS_NUM,null,nvl(p_project_role_id_tbl(i),project_role_id)) ,
               DECODE (p_person_type_code_tbl(i), FND_API.G_MISS_CHAR,null,nvl(p_person_type_code_tbl(i),person_type_code)) ,
               DECODE (p_supplier_id_tbl(i), FND_API.G_MISS_NUM,null,nvl(p_supplier_id_tbl(i),supplier_id)),
               DECODE (p_named_role_tbl(i), FND_API.G_MISS_CHAR,null,nvl(p_named_role_tbl(i),named_role )),
               resource_class_code,
               rate_based_flag,
               rbs_element_id,
               non_labor_resource,
               txn_accum_header_id,
               task_id
            INTO
               x_rlm_id_change_flag_tbl(i),
               x_mfc_cost_type_id_old_tbl(i),
               x_mfc_cost_type_id_new_tbl(i),
               x_spread_curve_id_old_tbl(i),
               x_spread_curve_id_new_tbl(i),
               x_sp_fixed_date_old_tbl(i),
               x_sp_fixed_date_new_tbl(i),
               x_plan_start_date_old_tbl(i),
               x_plan_start_date_new_tbl(i),
               x_plan_end_date_old_tbl(i),
               x_plan_end_date_new_tbl(i),
               l_txn_currency_code_tbl(i),
               l_inventory_item_id_tbl(i),
               l_expenditure_type_tbl(i),
               l_person_id_tbl(i),
               l_job_id_tbl(i),
               l_organization_id_tbl(i),
               l_event_type_tbl(i),
               l_expenditure_category_tbl(i),
               l_revenue_category_code_tbl(i),
               l_item_category_id_tbl(i),
               l_bom_resource_id_tbl(i),
               l_project_role_id_tbl(i),
               l_person_type_code_tbl(i),
               l_supplier_id_tbl(i),
               l_named_role_tbl(i),
               l_resource_class_code_tbl(i),
               l_rate_based_flag_tbl(i),
               x_rbs_element_id_tbl(i),
               l_non_labor_resource_tbl(i),
               x_txn_accum_header_id_tbl(i),
               l_task_id_tbl(i)
            FROM  pa_resource_assignments pra,
               (SELECT pra.resource_assignment_id
                      ,pbl.txn_currency_code
                FROM   pa_budget_lines pbl,
                       pa_resource_assignments pra
                WHERE  pbl.resource_assignment_id(+)=pra.resource_assignment_id
                AND    pra.resource_assignment_id=p_resource_assignment_id_tbl(i)
                AND    ROWNUM=1) pbl
            WHERE pra.resource_assignment_id=p_resource_assignment_id_tbl(i);

            IF l_debug_mode = 'Y' THEN

               pa_debug.g_err_stage:='x_rlm_id_change_flag_tbl('||i||') is '||x_rlm_id_change_flag_tbl(i);
               print_msg(pa_debug.g_err_stage,l_module_name);
               pa_debug.g_err_stage:='x_mfc_cost_type_id_old_tbl('||i||') is '||x_mfc_cost_type_id_old_tbl(i);
               print_msg(pa_debug.g_err_stage,l_module_name);
               pa_debug.g_err_stage:='x_mfc_cost_type_id_new_tbl('||i||') is '||x_mfc_cost_type_id_new_tbl(i);
               print_msg(pa_debug.g_err_stage,l_module_name);
               pa_debug.g_err_stage:='x_spread_curve_id_old_tbl('||i||') is '||x_spread_curve_id_old_tbl(i);
               print_msg(pa_debug.g_err_stage,l_module_name);
               pa_debug.g_err_stage:='x_spread_curve_id_new_tbl('||i||') is '||x_spread_curve_id_new_tbl(i);
               print_msg(pa_debug.g_err_stage,l_module_name);
               pa_debug.g_err_stage:='x_sp_fixed_date_old_tbl('||i||') is '||x_sp_fixed_date_old_tbl(i);
               print_msg(pa_debug.g_err_stage,l_module_name);
               pa_debug.g_err_stage:='x_sp_fixed_date_new_tbl('||i||') is '||x_sp_fixed_date_new_tbl(i);
               print_msg(pa_debug.g_err_stage,l_module_name);
               pa_debug.g_err_stage:='x_plan_start_date_old_tbl('||i||') is '||x_plan_start_date_old_tbl(i);
               print_msg(pa_debug.g_err_stage,l_module_name);
               pa_debug.g_err_stage:='x_plan_start_date_new_tbl('||i||') is '||x_plan_start_date_new_tbl(i);
               print_msg(pa_debug.g_err_stage,l_module_name);
               pa_debug.g_err_stage:='x_plan_end_date_old_tbl('||i||') is '||x_plan_end_date_old_tbl(i);
               print_msg(pa_debug.g_err_stage,l_module_name);
               pa_debug.g_err_stage:='x_plan_end_date_new_tbl('||i||') is '||x_plan_end_date_new_tbl(i);
               print_msg(pa_debug.g_err_stage,l_module_name);


            END IF;--IF l_debug_mode = 'Y' THEN

            --Added Validation for planning_start_date and planning end date
            IF ((x_plan_start_date_new_tbl(i)=FND_API.G_MISS_DATE) OR
                (x_plan_end_date_new_tbl(i) =FND_API.G_MISS_DATE)  OR
                (NVL(x_plan_start_date_new_tbl(i),trunc(sysdate))>NVL(x_plan_end_date_new_tbl(i),trunc(sysdate)))) THEN

                IF l_debug_mode = 'Y' THEN

                   pa_debug.g_err_stage:='Invalid Planning Start/End Dates';
                   pa_debug.write(l_module_name ,pa_debug.g_err_stage,3);

                   pa_debug.g_err_stage:='x_plan_start_date_new_tbl('||i||') is '|| x_plan_start_date_new_tbl(i);
                   pa_debug.write(l_module_name ,pa_debug.g_err_stage,3);

                   pa_debug.g_err_stage:='x_plan_end_date_new_tbl('||i||') is '|| x_plan_end_date_new_tbl(i);
                   pa_debug.write(l_module_name ,pa_debug.g_err_stage,3);

                END IF;
		/*Bug Fix:5752337: The meaningful message should be shown when dates are not entered properly
		* made use of exisisting message PA_FP_PLAN_START_END_DATE_ERR which is used in the spread api
                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
		*/
		OPEN get_line_info(p_resource_assignment_id_tbl(i));
                FETCH get_line_info
                INTO l_project_name
                     , l_task_name
                     , l_resource_name;
                CLOSE get_line_info;
		PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA'
                                ,p_msg_name      => 'PA_FP_PLAN_START_END_DATE_ERR'
                                ,p_token1         => 'L_PROJECT_NAME'
                                ,p_value1         => l_project_name
                                ,p_token2         => 'L_TASK_NAME'
                                ,p_value2         => l_task_name
                                ,p_token3         => 'L_RESOURCE_NAME'
                                ,p_value3         => l_resource_name
                                ,p_token4         => 'L_LINE_START_DATE'
                                ,p_value4         => x_plan_start_date_new_tbl(i)
                                ,p_token5        => 'L_LINE_END_DATE'
                                ,p_value5        => x_plan_end_date_new_tbl(i)
				);
		/* end of bug fix: 5752337 */


                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;--IF ((x_plan_start_date_new_tbl(i)=FND_API.G_MISS_DATE) OR

            --Bug 4083605. This block of code makes sure that the planning start date is not changed to a date
            --which falls after the date where actuals exist. Similar validations are done for planning end date too

            --Bug 4448581
            IF NVL(l_plan_ver_settings_rec.wp_version_flag,'N') <> 'Y' THEN

                IF l_plan_ver_settings_rec.etc_start_date IS NOT NULL AND
                   (x_plan_start_date_new_tbl(i) <> x_plan_start_date_old_tbl(i) OR
                     x_plan_end_date_new_tbl(i) <> x_plan_end_date_old_tbl(i)) THEN

                    IF l_debug_mode = 'Y' THEN

                       pa_debug.g_err_stage:='Planning Start/End dates have changed. Validating with Etc Start date';
                       pa_debug.write(l_module_name ,pa_debug.g_err_stage,3);

                    END IF;

                    SELECT min(start_date), max(end_date)
                    INTO   l_actuals_start_date, l_actuals_end_date
                    FROM   pa_budget_lines
                    WHERE  budget_version_id = p_budget_version_id
                    AND    resource_assignment_id = p_resource_assignment_id_tbl(i)
                    AND    end_date < l_plan_ver_settings_rec.etc_start_date;

                    IF l_debug_mode = 'Y' THEN

                       pa_debug.g_err_stage:='x_plan_start_date_new_tbl('||i||') is '||x_plan_start_date_new_tbl(i);
                       pa_debug.write(l_module_name ,pa_debug.g_err_stage,3);
                       pa_debug.g_err_stage:='x_plan_start_date_old_tbl('||i||') is '||x_plan_start_date_old_tbl(i);
                       pa_debug.write(l_module_name ,pa_debug.g_err_stage,3);
                       pa_debug.g_err_stage:='l_actuals_start_date is '||l_actuals_start_date;
                       pa_debug.write(l_module_name ,pa_debug.g_err_stage,3);
                       pa_debug.g_err_stage:='x_plan_end_date_new_tbl('||i||') is '||x_plan_end_date_new_tbl(i);
                       pa_debug.write(l_module_name ,pa_debug.g_err_stage,3);
                       pa_debug.g_err_stage:='x_plan_end_date_old_tbl('||i||') is '||x_plan_end_date_old_tbl(i);
                       pa_debug.write(l_module_name ,pa_debug.g_err_stage,3);
                       pa_debug.g_err_stage:='l_actuals_end_date is '||l_actuals_end_date;
                       pa_debug.write(l_module_name ,pa_debug.g_err_stage,3);

                    END IF;

                    --If either x_plan_start_date_new_tbl or x_plan_end_date_start_tbl is not null then all
                    --x_plan_start.end_date_new/old_tbls will be not null
                    IF ( x_plan_start_date_new_tbl(i) <> x_plan_start_date_old_tbl(i) AND
                         x_plan_start_date_new_tbl(i) > LEAST(NVL(l_actuals_start_date,x_plan_start_date_new_tbl(i) + 1),l_plan_ver_settings_rec.etc_start_date) ) OR
                       ( x_plan_end_date_new_tbl(i) <> x_plan_end_date_old_tbl(i) AND
                         x_plan_end_date_new_tbl(i) < GREATEST(NVL(l_actuals_end_date,x_plan_end_date_new_tbl(i) - 1),l_plan_ver_settings_rec.etc_start_date) ) THEN

                        IF ( x_plan_start_date_new_tbl(i) <> x_plan_start_date_old_tbl(i) AND
                             x_plan_start_date_new_tbl(i) > LEAST(NVL(l_actuals_start_date,x_plan_start_date_new_tbl(i) + 1),l_plan_ver_settings_rec.etc_start_date) ) THEN

                            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                 p_msg_name       => 'PA_FP_PLAN_ST_DT_CHG_ACTL_EXST');
                        END IF;

                        IF ( x_plan_end_date_new_tbl(i) <> x_plan_end_date_old_tbl(i) AND
                             x_plan_end_date_new_tbl(i) < GREATEST(NVL(l_actuals_end_date,x_plan_end_date_new_tbl(i) - 1),l_plan_ver_settings_rec.etc_start_date) ) THEN

                            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                 p_msg_name       => 'PA_FP_PLAN_DT_CHG_ACTL_EXST');
                        END IF;

                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                    END IF;


                END IF;--IF l_plan_ver_settings_rec.etc_start_date IS NOT NULL AND

            END IF;  -- If not a workplan version

            --Added Validation for sp_fixed_date cannot be null and to be between planning_start_date and
            --planning end date for fixed date spread curve. -- Added for Bug 3607061
            --Modified Logic below for Bug 3762278 -- l_spread_curve_id_tbl is the final value of
            --spread curve id that will be existing in db
            IF (x_spread_curve_id_new_tbl(i) = p_fixed_date_sp_id) THEN

               IF p_sp_fixed_date_tbl(i) = FND_API.G_MISS_DATE THEN

                  IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:='Error - cannot nullify sp_fixed_date for Fixed Date Spread curve';
                     print_msg(pa_debug.g_err_stage,l_module_name);
                  END IF;

                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_FP_SP_FIXED_DATE_NULL');
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

               -- Added for bug 4247427. Fixed Date cannot be less than the etc_start_date
               ELSIF (l_plan_ver_settings_rec.etc_start_date IS NOT NULL AND (x_sp_fixed_date_new_tbl(i) BETWEEN                                 x_plan_start_date_new_tbl(i) AND x_plan_end_date_new_tbl(i))) THEN
                    IF (x_sp_fixed_date_new_tbl(i) < l_plan_ver_settings_rec.etc_start_date) THEN
                      IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage :='Sp Fixed Date less than ETC Start date';
                         print_msg(pa_debug.g_err_stage,l_module_name);
                      END IF;
                      PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_FP_SP_FIXED_DATE_LESS');
                      RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;  -- x_sp_fixed_date_new_tbl(i) < l_plan_ver_settings_rec.etc_start_date

               ELSIF (x_sp_fixed_date_new_tbl(i) NOT BETWEEN x_plan_start_date_new_tbl(i) AND x_plan_end_date_new_tbl(i)) THEN

                  IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage :='Sp Fixed Date not between planning start date and End Date';
                     print_msg(pa_debug.g_err_stage,l_module_name);
                  END IF;

                  -- Added for Bug 3762278
                  -- fetching details for message tokens
                  BEGIN
                         SELECT ppa.name project_name
                               ,pt.name task_name
                               ,prl.alias resource_name
                          INTO l_project_name
                              ,l_task_name
                              ,l_resource_name
                          FROM pa_projects_all ppa
                              ,pa_proj_elements pt
                              ,pa_resource_list_members prl
                              ,pa_resource_assignments pra
                         WHERE pra.resource_assignment_id = p_resource_assignment_id_tbl(i)
                           AND ppa.project_id = pra.project_id
                           AND pt.proj_element_id(+) = pra.task_id
                           /* Bug fix:4200168 AND prl.resource_list_member_id(+) = pra.resource_list_member_id;*/
                           AND prl.resource_list_member_id = pra.resource_list_member_id;
                  EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                              IF l_debug_mode = 'Y' THEN
                                 pa_debug.g_err_stage :='Invalid Data PA_FP_FIXED_DATE_NOT_MATCH will have no tokens';
                                 print_msg(pa_debug.g_err_stage,l_module_name);
                              END IF;
                              NULL;
                  END;

                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_FP_FIXED_DATE_NOT_MATCH',
                                       p_token1         => 'L_PROJECT_NAME' ,
                                       p_value1         => l_project_name,
                                       p_token2         => 'L_TASK_NAME',
                                       p_value2         => l_task_name,
                                       p_token3         => 'L_RESOURCE_NAME',
                                       p_value3         => l_resource_name,
                                       p_token4         => 'L_LINE_START_DATE',
                                       p_value4         => x_plan_start_date_new_tbl(i),
                                       p_token5         => 'L_LINE_END_DATE',
                                       p_value5         => x_plan_start_date_old_tbl(i));
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

               END IF;--IF x_sp_fixed_date_new_tbl(i) = FND_API.G_MISS_DATE THEN

            ELSE
                -- if the Final Value of spread curve id is either null or not equal to fixed date
                -- spread curve then the sp fixed date should be nulled out if it is not already null.
                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Spread curve id not chosen to be updated and value in db for..';
                    print_msg(pa_debug.g_err_stage,l_module_name);
                    pa_debug.g_err_stage:='..spread curve id is either null or <> to fixed date spread curve id';
                    print_msg(pa_debug.g_err_stage,l_module_name);
                END IF;

                IF x_sp_fixed_date_old_tbl(i) IS NOT NULL THEN

                   x_sp_fixed_date_new_tbl(i) := FND_API.G_MISS_DATE;

                ELSE

                   x_sp_fixed_date_new_tbl(i) := NULL;

                END IF;

            END IF;--IF (x_spread_curve_id_new_tbl(i) = p_fixed_date_sp_id) THEN


            --RBS element Id should be re-derived if the rlm id/Project Role Id have changed.
            --dbms_output.put_line('7');
            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Finding out whether the RBS re-derivation is required or NOT';
                print_msg(pa_debug.g_err_stage,l_module_name);
            END IF;

            IF x_rlm_id_change_flag_tbl(i)='Y' THEN

                -- An rbs element id can change for a planning transaction only in Task Assignments Flow.
                IF p_context <> PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK THEN

                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                        p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                                        p_token1         => 'PROCEDURENAME',
                                        p_value1         => 'PROCESS_RES_CHG_DERV_CALC_PRMS',
                                        p_token2         => 'STAGE',
                                        p_value2         => 'RBS Elem Id change in NON TA context');
                   RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                END IF;
                --dbms_output.put_line('7.1');

                l_rbs_map_index:=l_rbs_map_index+1;

                l_ra_id_rbs_prm_tbl.extend(1);
                l_person_id_rbs_prm_tbl.extend(1);
                l_job_id_rbs_prm_tbl.extend(1);
                l_organization_id_rbs_prm_tbl.extend(1);
                l_event_type_rbs_prm_tbl.extend(1);
                l_exp_category_rbs_prm_tbl.extend(1);
                l_rev_cat_code_rbs_prm_tbl.extend(1);
                l_inv_item_id_rbs_prm_tbl.extend(1);
                l_item_cat_id_rbs_prm_tbl.extend(1);
                l_bom_res_id_rbs_prm_tbl.extend(1);
                l_per_type_code_rbs_prm_tbl.extend(1);
                l_supplier_id_rbs_prm_tbl.extend(1);
                l_txn_src_typ_code_rbs_prm_tbl.extend(1);
                l_exp_type_rbs_prm_tbl.extend(1);
                l_project_role_id_rbs_prm_tbl.extend(1);
                l_named_role_rbs_prm_tbl.extend(1);
                l_non_labor_res_rbs_prm_tbl.extend(1);

                --These pl/sql tbls are required as they have to be passed to the delete_planning_transactions API for
                --deleting the PJI data for the planning transactions for which the rbs element id has changed
                l_task_id_rbs_prm_tbl.extend(1);
                l_rbs_elem_id_rbs_prm_tbl.extend(1);
                l_rbf_rbs_prm_tbl.extend(1);
                l_res_class_code_rbs_prm_tbl.extend(1);
                --dbms_output.put_line('7.2');

                l_ra_id_rbs_prm_tbl(l_rbs_map_index)            :=  p_resource_assignment_id_tbl(i);
                l_person_id_rbs_prm_tbl(l_rbs_map_index)        :=  l_person_id_tbl(i);
                l_job_id_rbs_prm_tbl(l_rbs_map_index)           :=  l_job_id_tbl(i);
                l_organization_id_rbs_prm_tbl(l_rbs_map_index)  :=  l_organization_id_tbl(i);
                l_event_type_rbs_prm_tbl(l_rbs_map_index)       :=  l_event_type_tbl(i);
                l_exp_category_rbs_prm_tbl(l_rbs_map_index)     :=  l_expenditure_category_tbl(i);
                l_rev_cat_code_rbs_prm_tbl(l_rbs_map_index)     :=  l_revenue_category_code_tbl(i);
                l_inv_item_id_rbs_prm_tbl(l_rbs_map_index)      :=  l_inventory_item_id_tbl(i);
                l_item_cat_id_rbs_prm_tbl(l_rbs_map_index)      :=  l_item_category_id_tbl(i);
                l_bom_res_id_rbs_prm_tbl(l_rbs_map_index)       :=  l_bom_resource_id_tbl(i);
                l_per_type_code_rbs_prm_tbl(l_rbs_map_index)    :=  l_person_type_code_tbl(i);
                l_supplier_id_rbs_prm_tbl(l_rbs_map_index)      :=  l_supplier_id_tbl(i);
                l_txn_src_typ_code_rbs_prm_tbl(l_rbs_map_index) :=  'RES_ASSIGNMENT';
                l_exp_type_rbs_prm_tbl(l_rbs_map_index)         :=  l_expenditure_type_tbl(i);
                l_project_role_id_rbs_prm_tbl(l_rbs_map_index)  :=  l_project_role_id_tbl(i);
                l_named_role_rbs_prm_tbl(l_rbs_map_index)       :=  l_named_role_tbl(i);
                l_non_labor_res_rbs_prm_tbl(l_rbs_map_index)    :=  l_non_labor_resource_tbl(i);

                l_task_id_rbs_prm_tbl(l_rbs_map_index)          :=  l_task_id_tbl(i);
                l_res_class_code_rbs_prm_tbl(l_rbs_map_index)   :=  l_resource_class_code_tbl(i);
                --Please note that here rbs element id for which the pji data has to deleted should be passed.
                --x_rbs_element_id_tbl contains the old rbs element id and the new rbs element id will be derived only in the
                --later part of the code
                l_rbs_elem_id_rbs_prm_tbl(l_rbs_map_index)      :=  x_rbs_element_id_tbl(i);
                l_rbf_rbs_prm_tbl(l_rbs_map_index)              :=  l_rate_based_flag_tbl(i);
                --dbms_output.put_line('7.3');

		/* Bug fix: 5759413 */
		IF p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK THEN
			l_rtx_rateOvrds_rec := NULL;
		 	OPEN get_rateOvrds (p_resource_assignment_id_tbl(i));
			FETCH get_rateOvrds INTO l_rtx_rateOvrds_rec;
			CLOSE get_rateOvrds;
		END IF;

                -- An rbs element id can change for a planning transaction only in Task Assignments Flow.
                -- Resource list member id and project role id are the only two attributes of a planning
                -- transaction, which on undergoing a change from the UI, can change the rbs element id
                -- of the planning transaction. Quantities and amounts to be passed to calculate api
                -- is derved as per the logic below
                -- Details - /padev/pa/11.5/docs/CalcAPI_Behavior_Document2.doc
                IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Deriving Amts/Qty for rbs element id change';
                   print_msg(pa_debug.g_err_stage,l_module_name);
                END IF;

                IF px_total_qty_tbl(i) IS NOT NULL AND px_total_qty_tbl(i) <> FND_API.G_MISS_NUM THEN

                    IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:='RBS Input Quantity Exists Set Amts to NULL';
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    END IF;

                    px_total_raw_cost_tbl(i)         := NULL;
                    px_total_burdened_cost_tbl(i)    := NULL;
                    px_total_revenue_tbl(i)          := NULL;
                    px_raw_cost_rate_tbl(i)          := NULL;
                    px_b_cost_rate_tbl(i)            := NULL;
                    px_bill_rate_tbl(i)              := NULL;

		    /* Bug fix: 5759413: Check if the rate override is changed or not: if changed retain
		     * the new rate overrides entered by user, if not changed then set it to null
		     * so that, rate api derives the new rates for new planning resource
		     */
		    IF px_raw_cost_override_rate_tbl(i) is NOT NULL AND
			px_raw_cost_override_rate_tbl(i) <> FND_API.G_MISS_NUM  Then
			IF px_raw_cost_override_rate_tbl(i) = nvl(l_rtx_rateOvrds_rec.txn_raw_cost_rate_override,0) Then
		    		px_raw_cost_override_rate_tbl(i) := NULL;
			END IF;
		    End IF;

		    IF px_b_cost_rate_override_tbl(i) is NOT NULL AND
			px_b_cost_rate_override_tbl(i) <> FND_API.G_MISS_NUM  Then
			IF px_b_cost_rate_override_tbl(i) = nvl(l_rtx_rateOvrds_rec.txn_burden_cost_rate_override,0) Then
    		    		px_b_cost_rate_override_tbl(i) := NULL;
			END IF;
		    END IF;

                ELSIF px_total_qty_tbl(i) = FND_API.G_MISS_NUM THEN

                    IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:='RBS Input Quantity IS G_MISS_NUM Set Amts to G_MISS_NUM';
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    END IF;

                    px_total_raw_cost_tbl(i)         := FND_API.G_MISS_NUM;
                    px_total_burdened_cost_tbl(i)    := FND_API.G_MISS_NUM;
                    px_total_revenue_tbl(i)          := FND_API.G_MISS_NUM;
                    px_raw_cost_rate_tbl(i)          := FND_API.G_MISS_NUM;
                    px_b_cost_rate_tbl(i)            := FND_API.G_MISS_NUM;
                    px_bill_rate_tbl(i)              := FND_API.G_MISS_NUM;

		    /* Bug fix: 5759413 */
                    IF px_raw_cost_override_rate_tbl(i) is NOT NULL AND
                        px_raw_cost_override_rate_tbl(i) <> FND_API.G_MISS_NUM  Then
                        IF px_raw_cost_override_rate_tbl(i) = nvl(l_rtx_rateOvrds_rec.txn_raw_cost_rate_override,0) Then
                                px_raw_cost_override_rate_tbl(i) := NULL;
                        END IF;
                    End IF;

                    IF px_b_cost_rate_override_tbl(i) is NOT NULL AND
                        px_b_cost_rate_override_tbl(i) <> FND_API.G_MISS_NUM  Then
                        IF px_b_cost_rate_override_tbl(i) = nvl(l_rtx_rateOvrds_rec.txn_burden_cost_rate_override,0) Then                                    px_b_cost_rate_override_tbl(i) := NULL;
                        END IF;
                    END IF;


                ELSE -- px_total_qty_tbl IS NULL

                    IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:='RBS Input Quantity IS NULL See in DB';
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    END IF;
                    --dbms_output.put_line('7.3.1');

                    OPEN c_data_in_db_csr(p_resource_assignment_id_tbl(i));

                    FETCH c_data_in_db_csr INTO l_data_in_db_rec;

                    IF c_data_in_db_csr%FOUND THEN

                        IF l_debug_mode = 'Y' THEN
                            pa_debug.g_err_stage:='RBS Quantity found in DB, Set Amounts to NULL';
                            print_msg(pa_debug.g_err_stage,l_module_name);
                        END IF;
                        px_total_qty_tbl(i)              := l_data_in_db_rec.quantity;
                        px_total_raw_cost_tbl(i)         := NULL;
                        px_total_burdened_cost_tbl(i)    := NULL;
                        px_total_revenue_tbl(i)          := NULL;
                        px_raw_cost_rate_tbl(i)          := NULL;
                        px_b_cost_rate_tbl(i)            := NULL;
                        px_bill_rate_tbl(i)              := NULL;
			/* Bug fix: 5759413 */
                        IF px_raw_cost_override_rate_tbl(i) is NOT NULL AND
                          px_raw_cost_override_rate_tbl(i) <> FND_API.G_MISS_NUM  Then
                          IF px_raw_cost_override_rate_tbl(i) = nvl(l_rtx_rateOvrds_rec.txn_raw_cost_rate_override,0) Then
                                px_raw_cost_override_rate_tbl(i) := NULL;
                          END IF;
                        End IF;

                        IF px_b_cost_rate_override_tbl(i) is NOT NULL AND
                          px_b_cost_rate_override_tbl(i) <> FND_API.G_MISS_NUM  Then
                          IF px_b_cost_rate_override_tbl(i) = nvl(l_rtx_rateOvrds_rec.txn_burden_cost_rate_override,0) Then                                    px_b_cost_rate_override_tbl(i) := NULL;
                          END IF;
                        END IF;

                    ELSE -- If c_data_in_db_csr is not FOUND

                        IF l_debug_mode = 'Y' THEN
                            pa_debug.g_err_stage:='RBS NO Record in DB';
                            print_msg(pa_debug.g_err_stage,l_module_name);
                        END IF;

                        px_total_qty_tbl(i)              := NULL;
                        px_total_raw_cost_tbl(i)         := NULL;
                        px_total_burdened_cost_tbl(i)    := NULL;
                        px_total_revenue_tbl(i)          := NULL;
                        px_raw_cost_rate_tbl(i)          := NULL;
                        px_b_cost_rate_tbl(i)            := NULL;
                        px_bill_rate_tbl(i)              := NULL;

			/* Bug fix: 5759413 */
                        IF px_raw_cost_override_rate_tbl(i) is NOT NULL AND
                          px_raw_cost_override_rate_tbl(i) <> FND_API.G_MISS_NUM  Then
                          IF px_raw_cost_override_rate_tbl(i) = nvl(l_rtx_rateOvrds_rec.txn_raw_cost_rate_override,0) Then
                                px_raw_cost_override_rate_tbl(i) := NULL;
                          END IF;
                        End IF;

                        IF px_b_cost_rate_override_tbl(i) is NOT NULL AND
                          px_b_cost_rate_override_tbl(i) <> FND_API.G_MISS_NUM  Then
                          IF px_b_cost_rate_override_tbl(i) = nvl(l_rtx_rateOvrds_rec.txn_burden_cost_rate_override,0) Then                                    px_b_cost_rate_override_tbl(i) := NULL;
                          END IF;
                        END IF;

                    END IF;

                    CLOSE c_data_in_db_csr;
                    --dbms_output.put_line('7.4');

                END IF;--IF px_total_qty_tbl(i) IS NOT NULL AND px_total_qty_tbl(i) <> FND_API.G_MISS_NUM THEN

            END IF;--IF x_rlm_id_change_flag_tbl(i)='Y' THEN

        END IF;--IF p_project_role_id_tbl(i)         IS NULL AND

    END LOOP;--FOR i IN p_resource_assignment_id_tbl.FIRST

    IF l_ra_id_rbs_prm_tbl.count > 0 THEN

        /* Bug 3767322 - If resource list member changes, handling calculate
         * api call as per Sanjay:
           If planning resource is changed (resource_list_member_id is changed) then
           calculate API assumes that the calling API has cleaned up the data by deleting
           the entries in reporting data and then also deleted all the budget lines. This
           is important as this is one reason of data corruption happening in the reporting
           integration. Calculate cannot handle this case as the data seen by calculate is
           the changed data and not the old one.
                Pass the following to calculate API: Total QTY, ETC AMT (Plan-Actual)/ ETC
           QTY (Plan-actual) as ETC Rate (if qty and amounts are both present), Total
           Amount (Raw Cost, Burdened Cost and or Revenue) (These may ( if qty is null) or
           may not be passed) . No delete flag is required as all the lines have already
           been removed. */

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Calling API delete_planning_transactions ';
            pa_debug.write(l_module_name,pa_debug.g_err_stage, 5);
        END IF;
        --dbms_output.put_line('7.5');

        pa_fp_planning_transaction_pub.delete_planning_transactions
        (
              p_context                   => p_context
             ,p_calling_context           => p_calling_context   -- Added for Bug 6856934
             ,p_task_or_res               => 'ASSIGNMENT'
             ,p_resource_assignment_tbl   => l_ra_id_rbs_prm_tbl
             ,p_validate_delete_flag      => 'N'
             ,p_calling_module            => 'PROCESS_RES_CHG_DERV_CALC_PRMS'
             ,p_task_id_tbl               => l_task_id_rbs_prm_tbl
             ,p_rbs_element_id_tbl        => l_rbs_elem_id_rbs_prm_tbl
             ,p_rate_based_flag_tbl       => l_rbf_rbs_prm_tbl
             ,p_resource_class_code_tbl   => l_res_class_code_rbs_prm_tbl
             ,x_return_status             => x_return_status
             ,x_msg_count                 => x_msg_count
             ,x_msg_data                  => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

           IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='Called API delete_planning_transactions returned error';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage, 5);
           END IF;
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

        END IF;
        --dbms_output.put_line('7.6');

    END IF;

    --dbms_output.put_line('8');
    --Call the rbs mapping api only if there are some resource assignments for which the rbs_element_id can change
    IF l_rbs_map_index>0 THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Calling PA_RLMI_RBS_MAP_PUB.Map_Rlmi_Rbs';
            print_msg(pa_debug.g_err_stage,l_module_name);
        END IF;

        --Extend the output pl/sql tbls l_rbs_element_id_tbl and l_txn_accum_header_id_tbl so that they contatin
        --the same no of records as l_eligible_rlm_ids_tbl
        l_rbs_element_id_prm_tbl.EXTEND(l_ra_id_rbs_prm_tbl.COUNT);
        l_txn_accum_header_id_prm_tbl.EXTEND(l_ra_id_rbs_prm_tbl.COUNT);

        --Call the RBS Mapping API only if the rbs version id is not null
        IF l_plan_ver_settings_rec.rbs_version_id IS NOT NULL THEN

            --dbms_output.put_line('7.7');
            PA_RLMI_RBS_MAP_PUB.Map_Rlmi_Rbs(
             p_budget_version_id           => p_budget_version_id
            ,p_resource_list_id            => l_plan_ver_settings_rec.resource_list_id
            ,p_rbs_version_id              => l_plan_ver_settings_rec.rbs_version_id
            ,p_calling_process             => 'RBS_REFRESH'
            ,p_calling_context             => 'PLSQL'
            ,p_process_code                => 'RBS_MAP'
            ,p_calling_mode                => 'PLSQL_TABLE'
            ,p_init_msg_list_flag          => 'N'
            ,p_commit_flag                 => 'N'
            ,p_TXN_SOURCE_ID_tab           => l_ra_id_rbs_prm_tbl
            ,p_TXN_SOURCE_TYPE_CODE_tab    => l_txn_src_typ_code_rbs_prm_tbl
            ,p_PERSON_ID_tab               => l_person_id_rbs_prm_tbl
            ,p_JOB_ID_tab                  => l_job_id_rbs_prm_tbl
            ,p_ORGANIZATION_ID_tab         => l_organization_id_rbs_prm_tbl
            ,p_VENDOR_ID_tab               => l_supplier_id_rbs_prm_tbl
            ,p_EXPENDITURE_TYPE_tab        => l_exp_type_rbs_prm_tbl
            ,p_EVENT_TYPE_tab              => l_event_type_rbs_prm_tbl
            ,p_NON_LABOR_RESOURCE_tab      => l_non_labor_res_rbs_prm_tbl
            ,p_EXPENDITURE_CATEGORY_tab    => l_exp_category_rbs_prm_tbl
            ,p_REVENUE_CATEGORY_CODE_tab   => l_rev_cat_code_rbs_prm_tbl
            ,p_PROJECT_ROLE_ID_tab         => l_project_role_id_rbs_prm_tbl
            ,p_RESOURCE_CLASS_CODE_tab     => l_res_class_code_rbs_prm_tbl
            ,p_ITEM_CATEGORY_ID_tab        => l_item_cat_id_rbs_prm_tbl
            ,p_PERSON_TYPE_CODE_tab        => l_per_type_code_rbs_prm_tbl
            ,p_BOM_RESOURCE_ID_tab         => l_bom_res_id_rbs_prm_tbl
            ,p_INVENTORY_ITEM_ID_tab       => l_inv_item_id_rbs_prm_tbl -- Bug 3698596
            ,x_txn_source_id_tab           => l_txn_source_id_tbl
            ,x_res_list_member_id_tab      => l_res_list_member_id_tbl
            ,x_rbs_element_id_tab          => l_rbs_element_id_prm_tbl
            ,x_txn_accum_header_id_tab     => l_txn_accum_header_id_prm_tbl
            ,x_return_status               => x_return_status
            ,x_msg_count                   => x_msg_count
            ,x_msg_data                    => x_msg_data);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                 IF l_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage:='Called API PA_RLMI_RBS_MAP_PUB.Map_Rlmi_Rbs returned error';
                       pa_debug.write(l_module_name,pa_debug.g_err_stage, 5);
                 END IF;
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;
            --dbms_output.put_line('7.8');

        END IF;--IF l_plan_ver_settings_rec.rbs_version_id IS NOT NULL THEN


    END IF;--IF l_rbs_map_index>0 THEN

    IF l_rbs_map_index>0 THEN

        --dbms_output.put_line('7.9');
        --Initialise the indexes so that they can be re-used in the loop below
        l_rbs_map_index:=1;
        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='About to loop thru to create the pl/sql tables for rbs element id ';
           print_msg(pa_debug.g_err_stage,l_module_name);
        END IF;
        -- Loop thru the input ra id tbl and change the value of rbs_element_id
        -- depending on the value returned by the above apis. Here it is assumed that the called APIs
        -- returns the output in the order in which the inputs are passed.

        --Null out quantity if the UOM or Rate Based Flag have changed.
        FOR i IN p_resource_assignment_id_tbl.FIRST .. p_resource_assignment_id_tbl.LAST LOOP

                IF p_resource_assignment_id_tbl(i) = l_ra_id_rbs_prm_tbl(l_rbs_map_index) THEN

                    x_rbs_element_id_tbl(i):=l_rbs_element_id_prm_tbl(l_rbs_map_index);
                    x_txn_accum_header_id_tbl(i):=l_txn_accum_header_id_prm_tbl(l_rbs_map_index);

                    IF l_ra_id_rbs_prm_tbl.EXISTS(l_rbs_map_index+1) THEN
                        l_rbs_map_index:=l_rbs_map_index+1;
                    END IF;

                END IF;

        END LOOP;
        --dbms_output.put_line('8.0');
    END IF;--IF l_rbs_map_index>0 OR
           --dbms_output.put_line('10');

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Leaving Process_res_chg_Derv_calc_prms API';
        print_msg(pa_debug.g_err_stage,l_module_name);
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
	IF l_debug_mode = 'Y' THEN
           pa_debug.reset_curr_function;
	END IF;
     WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FP_PLANNING_TRANSACTION_PUB'
                                  ,p_procedure_name  => 'Process_res_chg_Derv_calc_prms');

           IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write( l_module_name,pa_debug.g_err_stage,5);
             pa_debug.reset_curr_function;
	END IF;
          RAISE;

  END Process_res_chg_Derv_calc_prms;


/*=====================================================================
Procedure Name:      add_planning_transactions
Purpose:             This procedure should be called to create planning
                     transactions valid values for p_context are 'BUDGET'
                     ,'FORECAST', 'WORKPLAN' and 'TASK_ASSIGNMENT'.The
                     api will honor only resource list member
                     id, resource name and resource class flag in the
                     resource rec type and default all the other values
                     by calling the get resurce defaults api of resource
                     foundation.

                     Creates resource assignments and budget lines for
                     workplan/budget/forecast. It is assumed that the
                     duplicate rlm ids are not passed . If this API finds
                     that there is no corresponding budget version then
                     this API goes and creates a budget version for the
                     work plan version.
=======================================================================*/
/*******************************************************************************************************
As part of Bug 3749516 All References to Equipment Effort or Equip Resource Class has been removed in
PROCEDURE add_planning_transactions.
p_planned_equip_effort_tbl IN parameter has also been removed as they were not being  used/referred.
********************************************************************************************************/

PROCEDURE add_planning_transactions
(
       p_context                     IN       VARCHAR2
      ,p_calling_context             IN       VARCHAR2 DEFAULT NULL   -- Added for Bug 6856934
      ,p_one_to_one_mapping_flag     IN       VARCHAR2 DEFAULT 'N'
      ,p_calling_module              IN       VARCHAR2 DEFAULT NULL
      ,p_project_id                  IN       Pa_projects_all.project_id%TYPE
      ,p_struct_elem_version_id      IN       Pa_proj_element_versions.element_version_id%TYPE   DEFAULT NULL
      ,p_budget_version_id           IN       Pa_budget_versions.budget_version_id%TYPE          DEFAULT NULL
      ,p_task_elem_version_id_tbl    IN       SYSTEM.pa_num_tbl_type                             DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_task_name_tbl               IN       SYSTEM.PA_VARCHAR2_240_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
      ,p_task_number_tbl             IN       SYSTEM.PA_VARCHAR2_100_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_100_TBL_TYPE()
      ,p_start_date_tbl              IN       SYSTEM.pa_date_tbl_type                            DEFAULT SYSTEM.PA_DATE_TBL_TYPE()
      ,p_end_date_tbl                IN       SYSTEM.pa_date_tbl_type                            DEFAULT SYSTEM.PA_DATE_TBL_TYPE()
       -- Bug 3793623 New params p_planning_start_date_tbl and p_planning_end_date_tbl added
      ,p_planning_start_date_tbl     IN       SYSTEM.pa_date_tbl_type                            DEFAULT SYSTEM.PA_DATE_TBL_TYPE()
      ,p_planning_end_date_tbl       IN       SYSTEM.pa_date_tbl_type                            DEFAULT SYSTEM.PA_DATE_TBL_TYPE()
      ,p_planned_people_effort_tbl   IN       SYSTEM.pa_num_tbl_type                             DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_latest_eff_pub_flag_tbl     IN       SYSTEM.PA_VARCHAR2_1_TBL_TYPE                      DEFAULT SYSTEM.PA_VARCHAR2_1_TBL_TYPE()
      --One record in the above pl/sql tables correspond to all the records in the below pl/sql tables
      ,p_resource_list_member_id_tbl IN       SYSTEM.pa_num_tbl_type                             DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_project_assignment_id_tbl   IN       SYSTEM.pa_num_tbl_type                             DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      /* The following columns are not (to be) passed by TA/WP. They are based by Edit Plan page BF case */
      ,p_quantity_tbl                IN       SYSTEM.pa_num_tbl_type                             DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_currency_code_tbl           IN       SYSTEM.PA_VARCHAR2_15_TBL_TYPE                     DEFAULT SYSTEM.PA_VARCHAR2_15_TBL_TYPE()
      ,p_raw_cost_tbl                IN       SYSTEM.pa_num_tbl_type                             DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_burdened_cost_tbl           IN       SYSTEM.pa_num_tbl_type                             DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_revenue_tbl                 IN       SYSTEM.pa_num_tbl_type                             DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_cost_rate_tbl               IN       SYSTEM.pa_num_tbl_type                             DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_bill_rate_tbl               IN       SYSTEM.pa_num_tbl_type                             DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_burdened_rate_tbl           IN       SYSTEM.pa_num_tbl_type                             DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_skip_duplicates_flag        IN       VARCHAR2                                           DEFAULT 'N'
      ,p_unplanned_flag_tbl          IN       SYSTEM.PA_VARCHAR2_1_TBL_TYPE                      DEFAULT SYSTEM.PA_VARCHAR2_1_TBL_TYPE()
      ,p_expenditure_type_tbl               IN  SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE() --added for Enc
      ,p_pm_product_code             IN       SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      ,p_pm_res_asgmt_ref            IN       SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      ,p_attribute_category_tbl      IN       SYSTEM.PA_VARCHAR2_30_TBL_TYPE  DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      ,p_attribute1                  IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute2                  IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute3                  IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute4                  IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute5                  IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute6                  IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute7                  IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute8                  IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute9                  IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute10                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute11                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute12                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute13                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute14                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute15                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute16                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute17                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute18                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute19                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute20                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute21                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute22                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute23                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute24                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute25                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute26                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute27                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute28                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute29                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute30                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_apply_progress_flag         IN       VARCHAR2                        DEFAULT 'N' /* Bug# 3720357 */
      ,p_scheduled_delay             IN       SYSTEM.pa_num_tbl_type          DEFAULT SYSTEM.PA_NUM_TBL_TYPE() --For bug 3948128
      ,p_pji_rollup_required         IN       VARCHAR2                                           DEFAULT 'Y' /* Bug# 4200168 */
      ,x_return_status               OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_msg_count                   OUT      NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,x_msg_data                    OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

   l_trace_stage number;

  --Start of variables used for debugging
      l_msg_count          NUMBER :=0;
      l_data               VARCHAR2(2000);
      l_msg_data           VARCHAR2(2000);
      l_error_msg_code     VARCHAR2(30);
      l_msg_index_out      NUMBER;
      l_return_status      VARCHAR2(2000);
      l_debug_mode         VARCHAR2(30);
  --End of variables used for debugging

      l_budget_version_id               pa_budget_versions.budget_version_id%TYPE;
      l_proj_fp_options_id              pa_proj_fp_options.proj_fp_options_id%TYPE;
      l_fin_plan_type_id                pa_fin_plan_types_b.fin_plan_type_id%TYPE;
      l_rlm_id_tbl_count                NUMBER := 0;
      l_elem_version_id_count           NUMBER := 0;
      l_resource_list_id                pa_proj_fp_options.all_resource_list_id%TYPE;
      l_people_res_class_rlm_id         pa_resource_list_members.resource_list_member_id%TYPE;
      l_equip_res_class_rlm_id          pa_resource_list_members.resource_list_member_id%TYPE; -- Bug 3749516 dummy Variable
      l_fin_res_class_rlm_id            pa_resource_list_members.resource_list_member_id%TYPE;
      l_mat_res_class_rlm_id            pa_resource_list_members.resource_list_member_id%TYPE;
      l_eligible_rlm_ids_tbl            SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
      l_proj_element_id_tbl             SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
      l_proj_element_id                 pa_proj_element_versions.proj_element_id%TYPE;
      l_fixed_date_sp_id                pa_spread_curves_b.spread_curve_id%TYPE; -- bug 3607061

   -- Added for Bug 3719918 -- USED FOR INSERT WHEN p-one-t-one-mapping-flag is Y
      l_task_elem_rlm_tbl               SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_proj_elem_rlm_tbl               SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();

   -- Bug 3719918, these tables will only be used for insert in B/F context
      l_bf_start_date_tbl                 SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
      l_bf_compl_date_tbl                 SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
      l_bf_proj_elem_tbl                  SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_bf_quantity_tbl                   SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
      l_bf_raw_cost_tbl                   SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
      l_bf_burdened_cost_tbl              SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
      l_bf_revenue_tbl                    SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
      l_bf_currency_code_tbl              SYSTEM.PA_VARCHAR2_15_TBL_TYPE    := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
      l_bf_cost_rate_tbl                  SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
      l_bf_bill_rate_tbl                  SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
      l_bf_burdened_rate_tbl              SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
      l_dup_flag                          varchar2(1) :='N';
      --Bug 4207150. These pl/sql tbls will be used to store the task/rlms that are inserted in B/F Flow
      l_bf_ra_id_tbl                      SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
      l_bf_task_id_tbl                    SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
      l_bf_rlm_id_tbl                     SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
      l_bf_ins_quantity_tbl               SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
      l_bf_ins_raw_cost_tbl               SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
      l_bf_ins_burdened_cost_tbl          SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
      l_bf_ins_revenue_tbl                SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
      l_bf_ins_currency_code_tbl          SYSTEM.PA_VARCHAR2_15_TBL_TYPE    := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
      l_bf_ins_cost_rate_tbl              SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
      l_bf_ins_bill_rate_tbl              SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
      l_bf_ins_burdened_rate_tbl          SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
      l_temp                              NUMBER;
      dml_errors                          EXCEPTION;
      PRAGMA exception_init(dml_errors, -24381);

  --Start of variables for Variable for Resource Attributes
      l_resource_class_flag_tbl         SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
      l_resource_class_code_tbl         SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_resource_class_id_tbl           SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_res_type_code_tbl               SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_person_id_tbl                   SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_job_id_tbl                      SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_person_type_code_tbl            SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_named_role_tbl                  SYSTEM.PA_VARCHAR2_80_TBL_TYPE    := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
      l_bom_resource_id_tbl             SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_non_labor_resource_tbl          SYSTEM.PA_VARCHAR2_20_TBL_TYPE    := SYSTEM.PA_VARCHAR2_20_TBL_TYPE();
      l_inventory_item_id_tbl           SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_item_category_id_tbl            SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_project_role_id_tbl             SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_organization_id_tbl             SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_fc_res_type_code_tbl            SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_direct_expenditure_type_tbl            SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE(); --EnC
      l_expenditure_category_tbl        SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_event_type_tbl                  SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_revenue_category_code_tbl       SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_supplier_id_tbl                 SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_unit_of_measure_tbl             SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_spread_curve_id_tbl             SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_etc_method_code_tbl             SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_mfc_cost_type_id_tbl            SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_procure_resource_flag_tbl       SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
      l_incurred_by_res_flag_tbl        SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
      l_Incur_by_res_class_code_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_Incur_by_role_id_tbl            SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_org_id_tbl                      SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_rate_based_flag_tbl             SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
      l_rate_expenditure_type_tbl       SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_rate_func_curr_code_tbl         SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_incur_by_res_type               SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_resource_assignment_id_tbl      SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_assignment_description_tbl      SYSTEM.PA_VARCHAR2_240_TBL_TYPE   := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
      l_planning_resource_alias_tbl     SYSTEM.PA_VARCHAR2_80_TBL_TYPE    := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
      l_resource_name_tbl               SYSTEM.PA_VARCHAR2_240_TBL_TYPE    := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
      l_project_role_name_tbl           SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_organization_name_tbl           SYSTEM.PA_VARCHAR2_240_TBL_TYPE   := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
      l_financial_category_code_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_project_assignment_id_tbl       SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_use_task_schedule_flag_tbl      SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
      l_planning_start_date_tbl         SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
      l_planning_end_date_tbl           SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
      l_schedule_start_date_tbl         SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
      l_schedule_end_date_tbl           SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
      l_total_quantity_tbl              SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_override_currency_code_tbl      SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_billable_percent_tbl            SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_cost_rate_override_tbl          SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_burdened_rate_override_tbl      SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_unplanned_flag_tbl              SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
      l_sp_fixed_date_tbl               SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
      l_financial_category_name_tbl     SYSTEM.PA_VARCHAR2_80_TBL_TYPE    := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
      l_supplier_name_tbl               SYSTEM.PA_VARCHAR2_240_TBL_TYPE   := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
      l_pm_product_code_tbl             SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_pm_res_asgmt_ref_tbl            SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_ATTRIBUTE_CATEGORY_tbl          SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_ATTRIBUTE1_tbl                  SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE2_tbl                  SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE3_tbl                  SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE4_tbl                  SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE5_tbl                  SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE6_tbl                  SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE7_tbl                  SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE8_tbl                  SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE9_tbl                  SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE10_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE11_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE12_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE13_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE14_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE15_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE16_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE17_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE18_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE19_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE20_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE21_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE22_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE23_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE24_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE25_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE26_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE27_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE28_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE29_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_ATTRIBUTE30_tbl                 SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      --For bug 3948128
      l_scheduled_delay                 SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
  --End of variables for Variable for Resource Attributes

  --Start of variables for Variable for TA Validations for p_context = TASK_ASSIGNMENTS
     l_task_rec_tbl                    pa_task_assignment_utils.l_task_rec_tbl_type;
     l_resource_rec_tbl                pa_task_assignment_utils.l_resource_rec_tbl_type;
     l_del_task_level_rec_code_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE     := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_ra_id_del_tbl                   SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
     l_ra_id_del_count                 NUMBER;
  --End of variables for Variable for TA Validations for p_context = TASK_ASSIGNMENTS

     l_time_phased_code                pa_proj_fp_options.all_time_phased_code%TYPE;
     l_spread_amounts_for_ver          VARCHAR2(1);
     l_index                           NUMBER := 1;
     l_spread_amount_flags_tbl         SYSTEM.PA_VARCHAR2_1_TBL_TYPE      := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
     l_delete_budget_lines_tbl         SYSTEM.PA_VARCHAR2_1_TBL_TYPE      := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
     l_res_assignment_id_tbl           SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
     -- IPM Tables
     l_orig_count                      NUMBER; -- bug 5003827 issue 22
--     l_count_index                     NUMBER;
     l_ra_id_temp_tbl                  SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
     l_curr_code_temp_tbl              SYSTEM.PA_VARCHAR2_15_TBL_TYPE:= SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
     --
     l_res_assignment_id_temp_tbl      SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
     l_res_assignment_id               pa_resource_assignments.resource_assignment_id%TYPE;
     l_call_calc_api                   VARCHAR2(1);

  -- Start of variable to be used in Calculate API Call
     l_line_start_date_tbl             SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
     l_line_end_date_tbl               SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();

     l_currency_code_tbl               SYSTEM.PA_VARCHAR2_15_TBL_TYPE:= SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
     l_quantity_tbl                    SYSTEM.PA_NUM_TBL_TYPE        := SYSTEM.PA_NUM_TBL_TYPE();
     l_raw_cost_tbl                    SYSTEM.PA_NUM_TBL_TYPE        := SYSTEM.PA_NUM_TBL_TYPE();
     l_burdened_cost_tbl               SYSTEM.PA_NUM_TBL_TYPE        := SYSTEM.PA_NUM_TBL_TYPE();
     l_revenue_tbl                     SYSTEM.PA_NUM_TBL_TYPE        := SYSTEM.PA_NUM_TBL_TYPE();
     l_cost_rate_tbl                   SYSTEM.PA_NUM_TBL_TYPE        := SYSTEM.PA_NUM_TBL_TYPE();
     l_burden_multiplier_tbl           SYSTEM.PA_NUM_TBL_TYPE        := SYSTEM.PA_NUM_TBL_TYPE();
     l_bill_rate_tbl                   SYSTEM.PA_NUM_TBL_TYPE        := SYSTEM.PA_NUM_TBL_TYPE();
     l_expenditure_type_tbl            SYSTEM.PA_VARCHAR2_30_TBL_TYPE:= SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
     l_txn_src_typ_code_rbs_prm_tbl    SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
     l_txn_source_id_tbl               SYSTEM.pa_num_tbl_type        := SYSTEM.pa_num_tbl_type();
     l_res_list_member_id_tbl          SYSTEM.pa_num_tbl_type        := SYSTEM.pa_num_tbl_type();
     l_rbs_element_id_tbl              SYSTEM.pa_num_tbl_type        := SYSTEM.pa_num_tbl_type();
     l_txn_accum_header_id_tbl         SYSTEM.pa_num_tbl_type        := SYSTEM.pa_num_tbl_type();

  -- End of variable to be used in Calculate API Call

  -- Bug 3749516 Added for insert in Workplan Context
     l_ins_proj_element_id_tbl          SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
     l_ins_task_elem_version_id_tbl     SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
     l_ins_start_date_tbl               SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
     l_ins_end_date_tbl                 SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
     l_ins_cal_people_effort_tbl        SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
     l_ins_cal_burdened_cost_tbl        SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
     l_ins_cal_raw_cost_tbl             SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
     l_ins_index                        NUMBER := 1;

     l_start_date                      pa_resource_assignments.planning_start_date%TYPE    := NULL;
     l_compl_date                      pa_resource_assignments.planning_start_date%TYPE    := NULL;
     l_start_date_tbl                  SYSTEM.PA_DATE_TBL_TYPE                             := SYSTEM.PA_DATE_TBL_TYPE();
     l_compl_date_tbl                  SYSTEM.PA_DATE_TBL_TYPE                             := SYSTEM.PA_DATE_TBL_TYPE();

     l_rlm_id_no_of_rows               NUMBER;
     l_elem_ver_id_no_of_rows          NUMBER;
     l_ppl_index                       NUMBER;
     l_amount_exists                   VARCHAR2(1);
     l_rbs_version_id                  pa_proj_fp_options.rbs_version_id%TYPE;

     l_proj_curr_code                  pa_projects_all.project_currency_code%TYPE;
     l_proj_func_curr_code             pa_projects_all.projfunc_currency_code%TYPE;

   -- Bug 3836358 -- ADDED for usage when p_skip_duplicates_flag is passed as Y
     l_task_id_temp                    PA_RESOURCE_ASSIGNMENTS.TASK_ID%TYPE;
     l_pji_rollup_required            VARCHAR2(1);

     l_fp_cols_rec   pa_fp_gen_amount_utils.fp_cols; -- IPM
     l_rm_temp_count number;

     -- Bug 8370812
     l_ra_id_rollup_tbl                SYSTEM.PA_NUM_TBL_TYPE             := SYSTEM.PA_NUM_TBL_TYPE();
     l_curr_code_rollup_tbl            SYSTEM.PA_VARCHAR2_15_TBL_TYPE     := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
     l_rollup_index                    NUMBER;
     l_add_flag                        BOOLEAN;

    CURSOR get_pc_code IS
    SELECT project_currency_code, projfunc_currency_code
    FROM   pa_projects_all
    WHERE  project_id = p_project_id;

--------------------------------------------------------------------------
-- This cursor is to be used to retrieve the proj_element_id based on the
-- element_version_id.
-- This might be removed.
--------------------------------------------------------------------------
    CURSOR  c_proj_element_id(c_elem_version_id pa_proj_element_versions.element_version_id%TYPE) IS
    SELECT  proj_element_id
      FROM  pa_proj_element_versions
     WHERE  element_version_id = c_elem_version_id;

      -- gboomina added for bug 8586393 - start
    --Mcloseout
       -- rbruno bug 9468665 modified FROM clause so that correct workplan information is taken.
    CURSOR c2(p_project_id IN NUMBER) IS
    SELECT use_task_schedule_flag
    FROM  pa_workplan_options_v
    WHERE project_id = p_project_id;

    l_use_task_schedule_flag      VARCHAR2(1);
    -- gboomina added for bug 8586393 - end


BEGIN
    l_trace_stage := 10;
--    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

    SAVEPOINT ADD_PLANNING_TRANS_SP;
    l_direct_expenditure_type_tbl :=p_expenditure_type_tbl;
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

    IF p_pji_rollup_required = 'Y' THEN
        l_pji_rollup_required := 'Y';
    ELSE
        l_pji_rollup_required := 'N';
    END IF;

    pa_task_assignment_utils.g_require_progress_rollup := 'N';



    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
IF l_debug_mode = 'Y' THEN
    PA_DEBUG.Set_Curr_Function( p_function   => 'PA_FP_PLAN_TXN_PUB.add_planning_transactions',
                                p_debug_mode => l_debug_mode );
END IF;

    --p_context should never be null
    IF p_context IS NULL OR
       p_context NOT IN ( PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FORECAST
                         ,PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN
                         ,PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK
                         ,PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET ) THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='p_context passed is '||p_context;
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    -- Added for Bug 3719918 -- ONE-TO-ONE MAPPING BETWEEN ELEM_VER-RLM IDS PASSED
    -- Validation for p_one_to_one_mapping_flag passed as Y only for Budget/Forecast context
    -- Modified Validation Below for Only WORKPLAN Context - Changes for Bug 3665097
    IF (p_one_to_one_mapping_flag = 'Y'
        AND p_context  = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN) THEN
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='p_one_to_one_mapping_flag passed as Y for WORKPLAN context :'||p_context;
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;


    -- Added for Bug 3719918 and Bug 3665097
    -- Validation that when p_one_to_one_mapping_flag is passed as Y p_task_elem_version_id_tbl
    -- and p_resource_list_member_id_tbl should have same table count.
    IF (p_one_to_one_mapping_flag = 'Y' AND
        p_task_elem_version_id_tbl.COUNT <> p_resource_list_member_id_tbl.COUNT) THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Table Count Mismatch for p_one_to_one_mapping_flag Y in : '||p_context;
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;


    -- Bug 3793623 Planning Start Date and Planning End Date can only be passed when
    -- p_one_to_one_mapping_flag IS Y
    IF (p_one_to_one_mapping_flag = 'N' AND
        (p_planning_start_date_tbl.COUNT <> 0 OR p_planning_end_date_tbl.COUNT <> 0)) THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Planning Date Passed when one to one mapping is N';
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                             p_token1         => 'PROCEDURENAME',
                             p_value1         => 'PAFPPTPB.add_planning_transactions',
                             p_token2         => 'STAGE',
                             p_value2         => 'Planning Date Passed when one to one mapping is N');
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    -- Bug 3793623 Planning Start Date and Planning End Date Should have the same
    -- number of records
    IF (p_planning_start_date_tbl.COUNT <> p_planning_end_date_tbl.COUNT) THEN
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Planning Start Date - End Date MISMATCH p_context :'||p_context;
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                             p_token1         => 'PROCEDURENAME',
                             p_value1         => 'PAFPPTPB.add_planning_transactions',
                             p_token2         => 'STAGE',
                             p_value2         => 'Planning Start Date - End Date MISMATCH');
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    -- Bug 3793623 If Planning Start/End Date is passed its should be same as
    -- task_elem_version_id COUNT
    IF (p_planning_start_date_tbl.COUNT >0) THEN
        IF (p_planning_start_date_tbl.COUNT <> p_task_elem_version_id_tbl.COUNT) THEN
            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Planning Start Date - Task Elem Mismatch :'||p_context;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                                 p_token1         => 'PROCEDURENAME',
                                 p_value1         => 'PAFPPTPB.add_planning_transactions',
                                 p_token2         => 'STAGE',
                                 p_value2         => 'Planning Start Date - Task Elem Mismatch');
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    END IF;


    -- Added for Bug 3719918 -- when p one to one mapping flag is N
    -- duplicate rlm/elem_ver ids cannot be passed
    IF p_one_to_one_mapping_flag = 'N' THEN
       IF p_skip_duplicates_flag = 'N' THEN
          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Checking for duplicate rlm ids passed';
             pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
          END IF;
          IF p_resource_list_member_id_tbl.COUNT > 0 THEN
             FOR i IN p_resource_list_member_id_tbl.FIRST .. (p_resource_list_member_id_tbl.LAST-1) LOOP
                 FOR j in (i+1) .. p_resource_list_member_id_tbl.LAST LOOP
                     IF p_resource_list_member_id_tbl(j) = p_resource_list_member_id_tbl(i) THEN
                        IF l_debug_mode = 'Y' THEN
                            pa_debug.g_err_stage:='Dup RLM ID Passed';
                            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                        END IF;
                        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                             p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                                             p_token1         => 'PROCEDURENAME',
                                             p_value1         => 'PAFPPTPB.add_planning_transactions',
                                             p_token2         => 'STAGE',
                                             p_value2         => 'Duplicate RLM Id Passed');
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                     END IF;
                 END LOOP;
             END LOOP;
          END IF;
          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Checking for duplicate elem ver ids passed';
             pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
          END IF;
          IF p_task_elem_version_id_tbl.COUNT > 0 THEN
             FOR i IN p_task_elem_version_id_tbl.FIRST .. (p_task_elem_version_id_tbl.LAST-1) LOOP
                 FOR j in (i+1) .. p_task_elem_version_id_tbl.LAST LOOP
                     IF p_task_elem_version_id_tbl(j) = p_task_elem_version_id_tbl(i) THEN
                        IF l_debug_mode = 'Y' THEN
                            pa_debug.g_err_stage:='Dup ELEM VER ID Passed';
                            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                        END IF;
                        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                             p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                                             p_token1         => 'PROCEDURENAME',
                                             p_value1         => 'PAFPPTPB.add_planning_transactions',
                                             p_token2         => 'STAGE',
                                             p_value2         => 'Duplicate Task Elem Version Id Passed');
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                     END IF;
                 END LOOP;
             END LOOP;
          END IF;
       END IF; -- p_skip_duplicate_flag = N
    ELSE
    -- when p one to one mapping flag is Y
    -- FOR B/F Context dup rlm/task elem combination cannot be passed until
    -- and unless the currecy code is diff
    -- for TA WOKRPLAN dup rlm/task elem combination cannot be passed
        IF ((p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET) OR
            (p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FORECAST)) THEN
            IF p_task_elem_version_id_tbl.COUNT > 1 THEN
               FOR i IN p_task_elem_version_id_tbl.FIRST .. (p_task_elem_version_id_tbl.LAST-1) LOOP
                   FOR j in (i+1) .. p_task_elem_version_id_tbl.LAST LOOP
                       IF ( (p_task_elem_version_id_tbl(i) = p_task_elem_version_id_tbl(j)) AND
                            (p_resource_list_member_id_tbl(i) = p_resource_list_member_id_tbl(j)) AND
                            (p_currency_code_tbl(i) = p_currency_code_tbl(j))) THEN

                            IF l_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage:='Dup Rec passed - Curr Code (B/F) - will error out in Ins Stat';
                                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                            END IF;
                            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                 p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                                                 p_token1         => 'PROCEDURENAME',
                                                 p_value1         => 'PAFPPTPB.add_planning_transactions',
                                                 p_token2         => 'STAGE',
                                                 p_value2         => 'Duplicate CurrCode/RlmId/TaskId Passed');
                            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                       END IF;
                   END LOOP;
               END LOOP;
            END IF;
        ELSE -- for TA/WOKRPLAN check for currency code is not there planning elements cannot be added using
             -- different currencies for Ta/Workplan FLow
            IF p_task_elem_version_id_tbl.COUNT > 1 THEN
               FOR i IN p_task_elem_version_id_tbl.FIRST .. (p_task_elem_version_id_tbl.LAST-1) LOOP
                   FOR j in (i+1) .. p_task_elem_version_id_tbl.LAST LOOP
                       IF ( (p_task_elem_version_id_tbl(i) = p_task_elem_version_id_tbl(j)) AND
                            (p_resource_list_member_id_tbl(i) = p_resource_list_member_id_tbl(j))) THEN

                            IF l_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage:='Dup Rec passed - will error out in Ins Stat p_context :'||p_context;
                                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                            END IF;
                            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                 p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                                                 p_token1         => 'PROCEDURENAME',
                                                 p_value1         => 'PAFPPTPB.add_planning_transactions',
                                                 p_token2         => 'STAGE',
                                                 p_value2         => 'Duplicate RlmId/TaskId Passed');
                            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                       END IF;
                   END LOOP;
               END LOOP;
            END IF;
        END IF;
    END IF;


    IF l_debug_mode = 'Y' THEN
        IF p_task_elem_version_id_tbl.COUNT > 0 THEN
           FOR i in p_task_elem_version_id_tbl.FIRST .. p_task_elem_version_id_tbl.LAST LOOP
                pa_debug.g_err_stage:='p_task_elem_version_id_tbl :'||p_task_elem_version_id_tbl(i);
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
           END LOOP;
        END IF;

        IF p_resource_list_member_id_tbl.COUNT > 0 THEN
           FOR i in p_resource_list_member_id_tbl.FIRST .. p_resource_list_member_id_tbl.LAST LOOP
                pa_debug.g_err_stage:='p_resource_list_member_id_tbl :'||p_resource_list_member_id_tbl(i);
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
           END LOOP;
        END IF;

        IF p_currency_code_tbl.COUNT > 0 THEN
           FOR i in p_currency_code_tbl.FIRST .. p_currency_code_tbl.LAST LOOP
                pa_debug.g_err_stage:='p_currency_code_tbl :'||p_currency_code_tbl(i);
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
           END LOOP;
        END IF;
    END IF;

   -------------------------------------------------------------------------------------------
   -- Extending all table lengths to the permissible values they would take.
   -------------------------------------------------------------------------------------------

     IF p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN THEN
        -- Bug 3749516 only for PEOPLE
        l_rlm_id_no_of_rows       := 1;
     ELSE
        l_rlm_id_no_of_rows       := p_resource_list_member_id_tbl.LAST;
     END IF;
     l_elem_ver_id_no_of_rows  := p_task_elem_version_id_tbl.LAST;

    l_trace_stage := 20;
--    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

     IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:='Extending all table lengths to the permissible values they would take - p_context = '||p_context;
         pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

    l_task_elem_rlm_tbl.extend(l_rlm_id_no_of_rows);
    l_proj_elem_rlm_tbl.extend(l_rlm_id_no_of_rows);

    -- Bug 3719918 -- For Insert in BF Context.
    l_bf_start_date_tbl.extend(l_rlm_id_no_of_rows);
    l_bf_compl_date_tbl.extend(l_rlm_id_no_of_rows);
    l_bf_proj_elem_tbl.extend(l_rlm_id_no_of_rows);
    l_bf_quantity_tbl.extend((l_rlm_id_no_of_rows));
    l_bf_raw_cost_tbl.extend((l_rlm_id_no_of_rows));
    l_bf_burdened_cost_tbl.extend((l_rlm_id_no_of_rows));
    l_bf_revenue_tbl.extend((l_rlm_id_no_of_rows));
    l_bf_currency_code_tbl.extend((l_rlm_id_no_of_rows));
    l_bf_cost_rate_tbl.extend((l_rlm_id_no_of_rows));
    l_bf_bill_rate_tbl.extend((l_rlm_id_no_of_rows));
    l_bf_burdened_rate_tbl.extend((l_rlm_id_no_of_rows));

    -- End for Bug 3719918

    l_resource_class_flag_tbl.extend(l_rlm_id_no_of_rows);
    l_resource_class_code_tbl.extend(l_rlm_id_no_of_rows);
    l_resource_class_id_tbl.extend(l_rlm_id_no_of_rows);
    l_res_type_code_tbl.extend(l_rlm_id_no_of_rows);
    l_person_id_tbl.extend(l_rlm_id_no_of_rows);
    l_job_id_tbl.extend(l_rlm_id_no_of_rows);
    l_person_type_code_tbl.extend(l_rlm_id_no_of_rows);
    l_named_role_tbl.extend(l_rlm_id_no_of_rows);
    l_bom_resource_id_tbl.extend(l_rlm_id_no_of_rows);
    l_non_labor_resource_tbl.extend(l_rlm_id_no_of_rows);
    l_inventory_item_id_tbl.extend(l_rlm_id_no_of_rows);
    l_item_category_id_tbl.extend(l_rlm_id_no_of_rows);
    l_project_role_id_tbl.extend(l_rlm_id_no_of_rows);
    l_organization_id_tbl.extend(l_rlm_id_no_of_rows);
    l_fc_res_type_code_tbl.extend(l_rlm_id_no_of_rows);
    l_expenditure_type_tbl.extend(l_rlm_id_no_of_rows);
    l_expenditure_category_tbl.extend(l_rlm_id_no_of_rows);
    l_event_type_tbl.extend(l_rlm_id_no_of_rows);
    l_revenue_category_code_tbl.extend(l_rlm_id_no_of_rows);
    l_supplier_id_tbl.extend(l_rlm_id_no_of_rows);
    l_unit_of_measure_tbl.extend(l_rlm_id_no_of_rows);
    l_spread_curve_id_tbl.extend(l_rlm_id_no_of_rows);
    l_etc_method_code_tbl.extend(l_rlm_id_no_of_rows);
    l_mfc_cost_type_id_tbl.extend(l_rlm_id_no_of_rows);
    l_procure_resource_flag_tbl.extend(l_rlm_id_no_of_rows);
    l_incurred_by_res_flag_tbl.extend(l_rlm_id_no_of_rows);
    l_Incur_by_res_class_code_tbl.extend(l_rlm_id_no_of_rows);
    l_Incur_by_role_id_tbl.extend(l_rlm_id_no_of_rows);
    l_eligible_rlm_ids_tbl.extend(l_rlm_id_no_of_rows);
    l_txn_src_typ_code_rbs_prm_tbl.extend(l_rlm_id_no_of_rows);
    l_org_id_tbl.extend(l_rlm_id_no_of_rows);
    l_rate_based_flag_tbl.extend(l_rlm_id_no_of_rows);
    l_rate_expenditure_type_tbl.extend(l_rlm_id_no_of_rows);
    l_rate_func_curr_code_tbl.extend(l_rlm_id_no_of_rows);
    l_resource_assignment_id_tbl.extend(l_rlm_id_no_of_rows);
    l_assignment_description_tbl.extend(l_rlm_id_no_of_rows);
    l_planning_resource_alias_tbl.extend(l_rlm_id_no_of_rows);
    l_resource_name_tbl.extend(l_rlm_id_no_of_rows);
    l_project_role_name_tbl.extend(l_rlm_id_no_of_rows);
    l_organization_name_tbl.extend(l_rlm_id_no_of_rows);
    l_financial_category_code_tbl.extend(l_rlm_id_no_of_rows);
    l_project_assignment_id_tbl.extend(l_rlm_id_no_of_rows);
    l_use_task_schedule_flag_tbl.extend(l_rlm_id_no_of_rows);
    l_planning_start_date_tbl.extend(l_rlm_id_no_of_rows);
    l_planning_end_date_tbl.extend(l_rlm_id_no_of_rows);
    l_schedule_start_date_tbl.extend(l_rlm_id_no_of_rows);
    l_schedule_end_date_tbl.extend(l_rlm_id_no_of_rows);
    l_total_quantity_tbl.extend(l_rlm_id_no_of_rows);
    l_override_currency_code_tbl.extend(l_rlm_id_no_of_rows);
    l_billable_percent_tbl.extend(l_rlm_id_no_of_rows);
    l_cost_rate_override_tbl.extend(l_rlm_id_no_of_rows);
    l_burdened_rate_override_tbl.extend(l_rlm_id_no_of_rows);
    IF p_unplanned_flag_tbl.count = 0 THEN
         l_unplanned_flag_tbl.extend(l_rlm_id_no_of_rows);
    ELSE
         l_unplanned_flag_tbl := p_unplanned_flag_tbl;
    END IF;
    l_sp_fixed_date_tbl.extend(l_rlm_id_no_of_rows);
    l_financial_category_name_tbl.extend(l_rlm_id_no_of_rows);
    l_supplier_name_tbl.extend(l_rlm_id_no_of_rows);
    l_pm_product_code_tbl.extend(l_rlm_id_no_of_rows);
    l_pm_res_asgmt_ref_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE_CATEGORY_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE1_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE2_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE3_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE4_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE5_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE6_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE7_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE8_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE9_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE10_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE11_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE12_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE13_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE14_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE15_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE16_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE17_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE18_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE19_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE20_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE21_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE22_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE23_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE24_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE25_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE26_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE27_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE28_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE29_tbl.extend(l_rlm_id_no_of_rows);
    l_ATTRIBUTE30_tbl.extend(l_rlm_id_no_of_rows);
    --For bug 3948128
    l_scheduled_delay.extend(l_rlm_id_no_of_rows);

    l_del_task_level_rec_code_tbl.extend(l_elem_ver_id_no_of_rows);
    l_proj_element_id_tbl.extend(l_elem_ver_id_no_of_rows);
    l_start_date_tbl.extend(l_elem_ver_id_no_of_rows);
    l_compl_date_tbl.extend(l_elem_ver_id_no_of_rows);

    l_ins_proj_element_id_tbl.extend(l_elem_ver_id_no_of_rows);
    l_ins_task_elem_version_id_tbl.extend(l_elem_ver_id_no_of_rows);
    l_ins_start_date_tbl.extend(l_elem_ver_id_no_of_rows);
    l_ins_end_date_tbl.extend(l_elem_ver_id_no_of_rows);
    l_ins_cal_people_effort_tbl.extend(l_elem_ver_id_no_of_rows);
    l_ins_cal_burdened_cost_tbl.extend(l_elem_ver_id_no_of_rows);
    l_ins_cal_raw_cost_tbl.extend(l_elem_ver_id_no_of_rows);
    l_use_task_schedule_flag_tbl.extend(l_elem_ver_id_no_of_rows); -- rbruno modified for bug 9724219

     -- Bug 8829159 - Fix to reduce PGA memory usage and avoid ORA-4030
     IF ((p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK) AND (p_one_to_one_mapping_flag = 'Y')) THEN
	 l_ra_id_del_tbl.extend(l_elem_ver_id_no_of_rows);
	 l_spread_amount_flags_tbl.extend(l_elem_ver_id_no_of_rows);
	 l_delete_budget_lines_tbl.extend(l_elem_ver_id_no_of_rows);
	 l_res_assignment_id_tbl.extend(l_elem_ver_id_no_of_rows);
	 l_res_assignment_id_temp_tbl.extend(l_elem_ver_id_no_of_rows);
	 l_currency_code_tbl.extend(l_elem_ver_id_no_of_rows);
	 l_quantity_tbl.extend(l_elem_ver_id_no_of_rows);
	 l_raw_cost_tbl.extend(l_elem_ver_id_no_of_rows);
	 l_burdened_cost_tbl.extend(l_elem_ver_id_no_of_rows);
	 l_revenue_tbl.extend(l_elem_ver_id_no_of_rows);
	 l_cost_rate_tbl.extend(l_elem_ver_id_no_of_rows);
	 l_burden_multiplier_tbl.extend(l_elem_ver_id_no_of_rows);
	 l_bill_rate_tbl.extend(l_elem_ver_id_no_of_rows);
     ELSE

    l_ra_id_del_tbl.extend((l_rlm_id_no_of_rows)*(l_elem_ver_id_no_of_rows));
    l_spread_amount_flags_tbl.extend((l_rlm_id_no_of_rows)*(l_elem_ver_id_no_of_rows));
    l_delete_budget_lines_tbl.extend((l_rlm_id_no_of_rows)*(l_elem_ver_id_no_of_rows));
    l_res_assignment_id_tbl.extend((l_rlm_id_no_of_rows)*(l_elem_ver_id_no_of_rows));
    l_res_assignment_id_temp_tbl.extend((l_rlm_id_no_of_rows)*(l_elem_ver_id_no_of_rows));
    l_currency_code_tbl.extend((l_rlm_id_no_of_rows)*(l_elem_ver_id_no_of_rows));
    l_quantity_tbl.extend((l_rlm_id_no_of_rows)*(l_elem_ver_id_no_of_rows));
    l_raw_cost_tbl.extend((l_rlm_id_no_of_rows)*(l_elem_ver_id_no_of_rows));
    l_burdened_cost_tbl.extend((l_rlm_id_no_of_rows)*(l_elem_ver_id_no_of_rows));
    l_revenue_tbl.extend((l_rlm_id_no_of_rows)*(l_elem_ver_id_no_of_rows));
    l_cost_rate_tbl.extend((l_rlm_id_no_of_rows)*(l_elem_ver_id_no_of_rows));
    l_burden_multiplier_tbl.extend((l_rlm_id_no_of_rows)*(l_elem_ver_id_no_of_rows));
    l_bill_rate_tbl.extend((l_rlm_id_no_of_rows)*(l_elem_ver_id_no_of_rows));
--    l_expenditure_type_tbl.extend((l_rlm_id_no_of_rows)*(l_elem_ver_id_no_of_rows));
    END IF;
    l_trace_stage := 30;
--dbms_output.put_line('done with extending');
--    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

   -------------------------------------------------------------------------------------------
   -- validating input parameters
   -- 1. , p_task_elem_version_id_tbl table cannot be empty
   -------------------------------------------------------------------------------------------

    --If the input tasks table is empty in the context of budget or forecast then return
    IF (p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET OR
        p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FORECAST) THEN
        l_elem_version_id_count := p_task_elem_version_id_tbl.COUNT;
        l_trace_stage := 140;
        --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Validating input parameters - count of  p_task_elem_version_id_tbl = '||l_elem_version_id_count;
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;

        IF l_elem_version_id_count = 0 THEN
            l_trace_stage := 150;
            --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Validating input parameters - elem_version_id table is empty - p_context = '||p_context;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
            --dbms_output.put_line('Tasks tbl is empty for BF -- returning');
            pa_debug.reset_curr_function;
            END IF;
            RETURN;
        END IF;
    END IF;


    --In the context of workplan the start date and end date tbl count should always be equal to the input
    --task tbl count
    IF p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN THEN
        IF (p_end_date_tbl.COUNT <> p_start_date_tbl.COUNT) OR
           (p_start_date_tbl.COUNT <> p_task_elem_version_id_tbl.COUNT) THEN

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Invalid pl/sql tables for start and end dates';
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;
            --dbms_output.put_line('$$$$%%%');
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                  p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    END IF;


    -------------------------------------------------------------------------------------------
    -- Validation - p_resource_list_member_id_tbl can be empty only for p_context = 'WORKPLAN'
    -- Otherwise return NULL
    -------------------------------------------------------------------------------------------
    IF NOT(p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN) THEN
        l_rlm_id_tbl_count := p_resource_list_member_id_tbl.COUNT;

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Validating input parameters - count of  p_resource_list_member_id_tbl = '||l_rlm_id_tbl_count;
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;

        IF l_rlm_id_tbl_count = 0 THEN

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Validating input parameters - Resource List Member Id table is empty - p_context = '||p_context;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
            --dbms_output.put_line('Rlm tbl is empty for BF -- returning');
            pa_debug.reset_curr_function;
           END IF;
            RETURN;
        END IF;

    END IF;



    l_trace_stage := 40;
--    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

    IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Validating input parameters - checking for project id : ' || p_project_id;
       pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    l_trace_stage := 50;
--    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
   -------------------------------------------------------------------------------------------
   -- validating input parameters
   -- 1. p_project_id cannot be null
   -------------------------------------------------------------------------------------------
    IF (p_project_id IS NULL) THEN
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='p_project_id is null';
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

--dbms_output.put_line('2');

    l_trace_stage := 60;
--    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
   -------------------------------------------------------------------------------------------
   -- validating input parameters
   -- 1. for p_context ('WORKPLAN','TASK_ASSIGNMENT')- p_struct_elem_version_id cannot be null
   -- 2. , p_task_elem_version_id_tbl table cannot be empty
   -------------------------------------------------------------------------------------------

    IF ((p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN) OR (p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK)) THEN

        l_trace_stage := 70;
--    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
        IF p_struct_elem_version_id IS NULL THEN

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='p_struct_elem_version_id is NULL and p_context = ' || p_context;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

        ELSE

            l_trace_stage := 80;
            --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='calling pa_planning_transaction_utils.get_wp_budget_version_id    p_struct_elem_version_id = ' || p_struct_elem_version_id;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='calling pa_planning_transaction_utils.get_wp_budget_version_id for deriving budget_version_id = ' || p_context;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;

            l_budget_version_id := pa_planning_transaction_utils.get_wp_budget_version_id(p_struct_elem_version_id);

            l_trace_stage := 90;
            --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
            pa_fp_planning_transaction_pub.add_wp_plan_type
            (p_src_project_id              => p_project_id
            ,p_targ_project_id              => p_project_id
            ,x_return_status                => x_return_status
            ,x_msg_count                    => x_msg_count
            ,x_msg_data                     => x_msg_data);
            l_trace_stage := 100;
            --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

            -- 4504452.Added this if codition to get the return status.
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF l_debug_mode = 'Y' THEN
	             pa_debug.g_err_stage:='Called API pa_fp_planning_transaction_pub.add_wp_plan_type api returned error';
                 pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
               END IF;
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;
            -----------------------------------------------------
            -- If l_budget_version_id IS NULL then create version
            -----------------------------------------------------
            IF l_budget_version_id IS NULL THEN
                l_trace_stage := 110;
                --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='calling pa_fin_plan_pub.create_version api = ' || p_context;
                    pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                END IF;

                SELECT fin_plan_type_id
                INTO   l_fin_plan_type_id
                FROM   pa_fin_plan_types_b
                WHERE  use_for_workplan_flag ='Y';

                pa_fin_plan_pub.Create_Version (
                 p_project_id               => p_project_id
                ,p_fin_plan_type_id         => l_fin_plan_type_id
                ,p_element_type             => PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST
                ,p_version_name             => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN
                ,p_description              => null
                ,p_ci_id                    => null
                ,p_est_proj_raw_cost        => null
                ,p_est_proj_bd_cost         => null
                ,p_est_proj_revenue         => null
                ,p_est_qty                  => null
                ,p_impacted_task_id         => null
                ,p_agreement_id             => null
                ,p_calling_context          => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN
                ,p_resource_list_id         => null
                ,p_time_phased_code         => null
                ,p_fin_plan_level_code      => null
                ,p_plan_in_multi_curr_flag  => null
                ,p_amount_set_id            => null
                ,p_attribute_category       => null
                ,p_attribute1               => null
                ,p_attribute2               => null
                ,p_attribute3               => null
                ,p_attribute4               => null
                ,p_attribute5               => null
                ,p_attribute6               => null
                ,p_attribute7               => null
                ,p_attribute8               => null
                ,p_attribute9               => null
                ,p_attribute10              => null
                ,p_attribute11              => null
                ,p_attribute12              => null
                ,p_attribute13              => null
                ,p_attribute14              => null
                ,p_attribute15              => null
                ,p_pji_rollup_required     => l_pji_rollup_required
                ,px_budget_version_id       => l_budget_version_id
                ,p_struct_elem_version_id   => p_struct_elem_version_id
                ,x_proj_fp_option_id        => l_proj_fp_options_id
                ,x_return_status            => l_return_status
                ,x_msg_count                => l_msg_count
                ,x_msg_data                 => l_msg_data );

                l_trace_stage := 120;
                --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:=' API pa_fin_plan_pub.create_version api return Status : '||l_return_status;
                    pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                    pa_debug.g_err_stage:=' API pa_fin_plan_pub.create_version api l_budget_version_id : '||l_budget_version_id;
                    pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                    pa_debug.g_err_stage:=' API pa_fin_plan_pub.create_version api l_proj_fp_options_id : '||l_proj_fp_options_id;
                    pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                END IF;

                l_trace_stage := 130;
                --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Called API pa_fin_plan_pub.create_version api returned error';
                    pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                    END IF;
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

            END IF;

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='l_budget_version_id, l_fin_plan_type_id = '||l_budget_version_id||','|| l_fin_plan_type_id;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;

        END IF;

        --Get the no of tasks passed . If none are passed then return
        l_elem_version_id_count := p_task_elem_version_id_tbl.COUNT;
        l_trace_stage := 140;
--    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Validating input parameters - count of  p_task_elem_version_id_tbl = '||l_elem_version_id_count;
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;

        IF l_elem_version_id_count = 0 THEN
            l_trace_stage := 150;
            --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Validating input parameters - elem_version_id table is empty - p_context = '||p_context;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.reset_curr_function;
	    END IF;
            RETURN;
        END IF;

        l_trace_stage := 160;
        --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
    ELSIF ((p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET) OR (p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FORECAST)) THEN

        l_trace_stage := 170;
        --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
        IF p_budget_version_id IS NULL THEN

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:='p_budget_version_id is null for p_context :' || p_context;
                  pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
            --dbms_output.put_line('bv id is null for BF');
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        ELSE
            l_trace_stage := 180;
            --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
            l_budget_version_id := p_budget_version_id;
        END IF;

        l_trace_stage := 190;
        --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
    END IF;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Fetching resource List id - l_resource_list_id : ';
        pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;
    l_trace_stage := 200;
    --  hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
    --dbms_output.put_line('2.3 '||l_budget_version_id);

    --Get the required details for the budget version id
    SELECT nvl(cost_resource_list_id, nvl(revenue_resource_list_id, all_resource_list_id))
          ,rbs_version_id
    INTO   l_resource_list_id
          ,l_rbs_version_id
    FROM   pa_proj_fp_options
    WHERE  fin_plan_version_id=l_budget_version_id;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Fetching resource List id - l_resource_list_id : '|| l_resource_list_id;
        pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

-- Fetching spread curve id for fixed date spread curve : Bug 3607061 - Starts
    BEGIN
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Fetching spread curve id for fixed date spread curve';
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;
        Select spread_curve_id
          into l_fixed_date_sp_id
          from pa_spread_curves_b
         where spread_curve_code = 'FIXED_DATE';

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Fetching spread curve id l_fixed_date_sp_id:'||l_fixed_date_sp_id;
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Fixed date spread curve not found in system';
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,5);
             END IF;
             RAISE;
    END;
-- Fetching spread curve id for fixed date spread curve : Bug 3607061 - Ends


    l_trace_stage := 210;
    --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

    --dbms_output.put_line('2.2');
    -----------------------------------------------------------------------------------------------------------------------
    -- Fetching the resource class member ids for Class Codes in ('FINANCIAL_ELEMENTS','PEOPLE','EQUIPMENT','MATERIAL')
    -- and setting all Cost PLsql tables that will be needed for calling Calculate API as Empty tabs
    -- Bug 3749516 Removing rlm id for EQUIPMENT below
    -----------------------------------------------------------------------------------------------------------------------

    IF (p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN) THEN
        l_trace_stage := 220;
        --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Calling API pa_planning_transaction_utils.Get_Res_Class_Rlm_Ids';
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;

         pa_planning_transaction_utils.Get_Res_Class_Rlm_Ids
        (p_project_id                   =>    p_project_id,
         p_resource_list_id             =>    l_resource_list_id,
         x_people_res_class_rlm_id      =>    l_people_res_class_rlm_id,
         x_equip_res_class_rlm_id       =>    l_equip_res_class_rlm_id,
         x_fin_res_class_rlm_id         =>    l_fin_res_class_rlm_id,
         x_mat_res_class_rlm_id         =>    l_mat_res_class_rlm_id,
         x_return_status                =>    l_return_status,
         x_msg_count                    =>    l_msg_count,
         x_msg_data                     =>    l_msg_data);
        l_trace_stage := 230;
        --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Called API pa_planning_transaction_utils.Get_Res_Class_Rlm_Ids api returned error';
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        l_trace_stage := 240;
        --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='l_people_res_class_rlm_id : '||l_people_res_class_rlm_id;
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;

        l_eligible_rlm_ids_tbl(1) := l_people_res_class_rlm_id;

        l_trace_stage := 250;
        --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
    ELSE
        --dbms_output.put_line('2.1');
        l_trace_stage := 260;
        --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
        l_eligible_rlm_ids_tbl := p_resource_list_member_id_tbl;

    END IF;

    /**************** initializing pm product code ************/
    IF l_eligible_rlm_ids_tbl.count > 0 Then
            FOR i IN l_eligible_rlm_ids_tbl.FIRST .. l_eligible_rlm_ids_tbl.LAST LOOP
                            If (NOT p_pm_product_code.EXISTS(i))
                            then
                                    l_pm_product_code_tbl(i) := null;
                            elsif ( p_pm_product_code(i) = fnd_api.g_miss_char)
                            Then
                                    l_pm_product_code_tbl(i) := null;
                            Else
                                    l_pm_product_code_tbl(i) := p_pm_product_code(i);
                            End If;

                            If (NOT p_pm_res_asgmt_ref.EXISTS(i))
                            then
                                    l_pm_res_asgmt_ref_tbl(i) := null;
                            elsif (p_pm_res_asgmt_ref(i) = fnd_api.g_miss_char)
                            Then
                                    l_pm_res_asgmt_ref_tbl(i) := null;
                            Else
                                    l_pm_res_asgmt_ref_tbl(i) := p_pm_res_asgmt_ref(i);
                            End If;
            END loop;
    End IF;

    /**************** end ------------------- initializing pm product code ************/


    l_trace_stage := 290;
    --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

    --------------------------------------------------------------------
    -- Calling procedure PA_PLANNING_RESOURCE_UTILS.get_resource_defaults
    --  to get the resource defaults for the rlm ids passed
    -- Please note that this API call will be modified, once the API is
    -- finalised.
    --                                    - STARTS
    --------------------------------------------------------------------

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Calling API PA_PLANNING_RESOURCE_UTILS.get_resource_defaults';
        pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    l_trace_stage := 300;
    --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
    PA_PLANNING_RESOURCE_UTILS.get_resource_defaults(
    p_resource_list_members        =>  l_eligible_rlm_ids_tbl,
    p_project_id                   =>  p_project_id,
    x_resource_class_flag          =>  l_resource_class_flag_tbl,
    x_resource_class_code          =>  l_resource_class_code_tbl,
    x_resource_class_id            =>  l_resource_class_id_tbl,
    x_res_type_code                =>  l_res_type_code_tbl,
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
    X_rate_based_flag              =>  l_rate_based_flag_tbl,
    x_rate_expenditure_type        =>  l_rate_expenditure_type_tbl,
    x_rate_func_curr_code          =>  l_rate_func_curr_code_tbl,
    x_incur_by_res_type            =>  l_incur_by_res_type ,
    x_msg_data                     =>  l_msg_data,
    x_msg_count                    =>  l_msg_count,
    x_return_status                =>  l_return_status);
    l_trace_stage := 310;
--    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Called APIPA_PLANNING_RESOURCE_UTILS.get_resource_defaults api returned error';
           pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    IF l_debug_mode = 'Y' THEN

        IF l_eligible_rlm_ids_tbl.COUNT >0 THEN
            pa_debug.g_err_stage:='Parameters to PA_RLMI_RBS_MAP_PUB.Map_Rlmi_Rbs';
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);


            pa_debug.g_err_stage:='p_budget_version_id '||l_budget_version_id;
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='l_resource_list_id '||l_resource_list_id;
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='l_rbs_version_id '||l_rbs_version_id;
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='l_eligible_rlm_ids_tbl(1) '||l_eligible_rlm_ids_tbl(1);
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='l_txn_src_typ_code_rbs_prm_tbl(1) '||l_txn_src_typ_code_rbs_prm_tbl(1);
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='l_person_id_tbl(1) '||l_person_id_tbl(1);
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='l_job_id_tbl(1) '||l_job_id_tbl(1);
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='l_organization_id_tbl(1) '||l_organization_id_tbl(1);
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='l_supplier_id_tbl(1) '||l_supplier_id_tbl(1);
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='l_expenditure_type_tbl(1) '||l_expenditure_type_tbl(1);
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='l_event_type_tbl(1) '||l_event_type_tbl(1);
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='l_expenditure_category_tbl(1) '||l_expenditure_category_tbl(1);
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='l_revenue_category_code_tbl(1) '||l_revenue_category_code_tbl(1);
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='l_project_role_id_tbl(1) '||l_project_role_id_tbl(1);
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='l_resource_class_code_tbl(1) '||l_resource_class_code_tbl(1);
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='l_item_category_id_tbl(1) '||l_item_category_id_tbl(1);
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='l_person_type_code_tbl(1) '||l_person_type_code_tbl(1);
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='l_bom_resource_id_tbl(1) '||l_bom_resource_id_tbl(1);
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

        END IF;


    END IF;


    --Loop thru the passed rlm id table to prepare the l_txn_src_typ_code_rbs_prm_tbl pl/sql table.
    --All the elements in this table should be set to 'RES_ASSIGNMENT'

    --NOTE : This loop is also used to transfer the l_incur_by_res_type(i) to  l_res_type_code_tbl(i) if
    --l_incurred_by_res_flag_tbl(i) is Y. Ultimately l_res_type_code_tbl will be used in populationg
    --res type code in pa_resource_assignments
    l_res_type_code_tbl.EXTEND(l_eligible_rlm_ids_tbl.COUNT-l_res_type_code_tbl.COUNT);
    FOR i IN l_eligible_rlm_ids_tbl.FIRST..l_eligible_rlm_ids_tbl.LAST LOOP

       l_txn_src_typ_code_rbs_prm_tbl(i):='RES_ASSIGNMENT';

       IF  l_incurred_by_res_flag_tbl.EXISTS(i) AND nvl(l_incurred_by_res_flag_tbl(i),'N') = 'Y' THEN
           IF l_incur_by_res_type.EXISTS(i) THEN
              l_res_type_code_tbl(i) := l_incur_by_res_type(i);
           ELSE
              l_res_type_code_tbl(i) := NULL;
           END IF;
       END IF;

    END LOOP;

    --Extend the output pl/sql tbls l_rbs_element_id_tbl and l_txn_accum_header_id_tbl so that they contatin
    --the same no of records as l_eligible_rlm_ids_tbl
    l_rbs_element_id_tbl.EXTEND(l_eligible_rlm_ids_tbl.COUNT);
    l_txn_accum_header_id_tbl.EXTEND(l_eligible_rlm_ids_tbl.COUNT);

    --Call the RBS Mapping API only if the rbs version id is not null
    IF l_rbs_version_id IS NOT NULL THEN

            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,'before PA_RLMI_RBS_MAP_PUB.Map_Rlmi_Rbs',3);

        PA_RLMI_RBS_MAP_PUB.Map_Rlmi_Rbs(
         p_budget_version_id           => l_budget_version_id
        ,p_resource_list_id            => l_resource_list_id
        ,p_rbs_version_id              => l_rbs_version_id
        ,p_calling_process             => 'RBS_REFRESH'
        ,p_calling_context             => 'PLSQL'
        ,p_process_code                => 'RBS_MAP'
        ,p_calling_mode                => 'PLSQL_TABLE'
        ,p_init_msg_list_flag          => 'N'
        ,p_commit_flag                 => 'N'
        ,p_TXN_SOURCE_ID_tab           => l_eligible_rlm_ids_tbl
        ,p_TXN_SOURCE_TYPE_CODE_tab    => l_txn_src_typ_code_rbs_prm_tbl
        ,p_PERSON_ID_tab               => l_person_id_tbl
        ,p_JOB_ID_tab                  => l_job_id_tbl
        ,p_ORGANIZATION_ID_tab         => l_organization_id_tbl
        ,p_VENDOR_ID_tab               => l_supplier_id_tbl
        ,p_EXPENDITURE_TYPE_tab        => l_expenditure_type_tbl
        ,p_EVENT_TYPE_tab              => l_event_type_tbl
        ,p_EXPENDITURE_CATEGORY_tab    => l_expenditure_category_tbl
        ,p_REVENUE_CATEGORY_CODE_tab   => l_revenue_category_code_tbl
        ,p_PROJECT_ROLE_ID_tab         => l_project_role_id_tbl
        ,p_RESOURCE_CLASS_CODE_tab     => l_resource_class_code_tbl
        ,p_ITEM_CATEGORY_ID_tab        => l_item_category_id_tbl
        ,p_PERSON_TYPE_CODE_tab        => l_person_type_code_tbl
        ,p_BOM_RESOURCE_ID_tab         => l_bom_resource_id_tbl
        ,p_NON_LABOR_RESOURCE_tab      => l_non_labor_resource_tbl -- Bug 3711741
        ,p_INVENTORY_ITEM_ID_tab       => l_inventory_item_id_tbl -- Bug 3698596
        ,x_txn_source_id_tab           => l_txn_source_id_tbl
        ,x_res_list_member_id_tab      => l_res_list_member_id_tbl
        ,x_rbs_element_id_tab          => l_rbs_element_id_tbl
        ,x_txn_accum_header_id_tab     => l_txn_accum_header_id_tbl
        ,x_return_status               => x_return_status
        ,x_msg_count                   => x_msg_count
        ,x_msg_data                    => x_msg_data);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Called API PA_RLMI_RBS_MAP_PUB.Map_Rlmi_Rbs returned error';
               pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

        END IF;

    END IF; --IF l_rbs_version_id IS NOT NULL THEN


    --Call the rbs mapping API for the rlm ids obtained above

    l_trace_stage := 320;
    --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
    --------------------------------------------------------------------
    -- Calling procedure abcd.get_multiple_resource_defaults to get the
    -- resource defaults for the rlm ids passed
    -- Please note that this API call will be modified, once the API is
    -- finalised.
    --                                      - ENDS
    --------------------------------------------------------------------


    -------------------------------------------------------------------------
    -- For p_context = TASK_ASSIGNMENTS  - Processing Starts Here
    -------------------------------------------------------------------------
    l_trace_stage := 330;
--    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
    IF p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK THEN
    l_trace_stage := 340;
--    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Doing processing for TASK ASSIGNMENTS : p_context is'|| p_context;
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;
        -------------------------------------------------------------------------
        -- To call Task Validation API we populate the PLSql tables with task
        -- and resource data.
        -------------------------------------------------------------------------

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Populating PlSql table with Task Data';
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;

        -----------------------------------------------------------------
        -- Populating Table of task_rec_type
        -----------------------------------------------------------------
        FOR i IN p_task_elem_version_id_tbl.FIRST .. p_task_elem_version_id_tbl.LAST LOOP
            l_trace_stage := 350;
            --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

            l_task_rec_tbl(i).project_id := p_project_id;
            l_task_rec_tbl(i).struct_elem_version_id := p_struct_elem_version_id;
            l_task_rec_tbl(i).task_elem_version_id := p_task_elem_version_id_tbl(i);
            IF p_task_name_tbl.EXISTS(i) THEN
                l_task_rec_tbl(i).task_name := p_task_name_tbl(i);
            END IF;

            IF p_task_number_tbl.EXISTS(i) THEN
                l_task_rec_tbl(i).task_number := p_task_number_tbl(i);
            END IF;

            IF p_start_date_tbl.EXISTS(i) THEN
                l_task_rec_tbl(i).start_date := p_start_date_tbl(i);
            END IF;

            IF p_end_date_tbl.EXISTS(i) THEN
                l_task_rec_tbl(i).end_date  := p_end_date_tbl(i);
            END IF;

            IF p_planned_people_effort_tbl.EXISTS(i) THEN
                l_task_rec_tbl(i).planned_people_effort := p_planned_people_effort_tbl(i);
            END IF;

            IF p_latest_eff_pub_flag_tbl.EXISTS(i) THEN
                l_task_rec_tbl(i).latest_eff_pub_flag  := p_latest_eff_pub_flag_tbl(i);
            END IF;
            l_trace_stage := 360;
            --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
        END LOOP;
        l_trace_stage := 370;
        --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));


        -----------------------------------------------------------------
        -- Populating Table of resource_rec_type
        -----------------------------------------------------------------

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Populating PlSql table with Resource Data';
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;

        l_trace_stage := 380;
        --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
        FOR i IN l_eligible_rlm_ids_tbl.FIRST .. l_eligible_rlm_ids_tbl.LAST LOOP
            l_trace_stage := 390;
            --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

            l_resource_rec_tbl(i).resource_list_member_id := l_eligible_rlm_ids_tbl(i);

            IF p_project_assignment_id_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).project_assignment_id := p_project_assignment_id_tbl(i);
            END IF;

            IF l_resource_class_flag_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).resource_class_flag := l_resource_class_flag_tbl(i);
            END IF;

            IF l_resource_class_code_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).resource_class_code := l_resource_class_code_tbl(i);
            END IF;

            IF l_resource_class_id_tbl.EXISTS(i) THEN
               l_resource_rec_tbl(i).resource_class_id := l_resource_class_id_tbl(i);
            END IF;

            IF l_res_type_code_tbl.EXISTS(i) THEN
               l_resource_rec_tbl(i).res_type_code := l_res_type_code_tbl(i);
            END IF;

            IF l_person_id_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).person_id := l_person_id_tbl(i);
            END IF;

            IF l_job_id_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).job_id := l_job_id_tbl(i);
            END IF;

            IF l_person_type_code_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).person_type_code := l_person_type_code_tbl(i);
            END IF;

            IF l_bom_resource_id_tbl.EXISTS(i) THEN
               l_resource_rec_tbl(i).bom_resource_id := l_bom_resource_id_tbl(i);
            END IF;

            IF l_inventory_item_id_tbl.EXISTS(i) THEN
               l_resource_rec_tbl(i).inventory_item_id := l_inventory_item_id_tbl(i);
            END IF;

            IF l_item_category_id_tbl.EXISTS(i) THEN
               l_resource_rec_tbl(i).item_category_id := l_item_category_id_tbl(i);
            END IF;

            IF l_project_role_id_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).project_role_id := l_project_role_id_tbl(i);
            END IF;

            IF l_organization_id_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).organization_id := l_organization_id_tbl(i);
            END IF;

            IF l_fc_res_type_code_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).fc_res_type_code := l_fc_res_type_code_tbl(i);
            END IF;

            IF l_expenditure_type_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).expenditure_type := l_expenditure_type_tbl(i);
            END IF;

            IF l_expenditure_category_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).expenditure_category := l_expenditure_category_tbl(i);
            END IF;

            IF l_event_type_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).event_type := l_event_type_tbl(i);
            END IF;

            IF l_revenue_category_code_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).revenue_category_code := l_revenue_category_code_tbl(i);
            END IF;

            IF l_supplier_id_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).supplier_id := l_supplier_id_tbl(i);
            END IF;

            IF l_unit_of_measure_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).unit_of_measure := l_unit_of_measure_tbl(i);
            END IF;

            IF l_spread_curve_id_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).spread_curve_id := l_spread_curve_id_tbl(i);
            END IF;

            IF l_etc_method_code_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).etc_method_code := l_etc_method_code_tbl(i);
            END IF;

            IF l_mfc_cost_type_id_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).mfc_cost_type_id := l_mfc_cost_type_id_tbl(i);
            END IF;

            IF l_incurred_by_res_flag_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).incurred_by_res_flag := l_incurred_by_res_flag_tbl(i);
            END IF;

            IF l_Incur_by_res_class_code_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).Incur_by_res_class_code := l_Incur_by_res_class_code_tbl(i);
            END IF;

            IF l_Incur_by_role_id_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).Incur_by_role_id := l_Incur_by_role_id_tbl(i);
            END IF;

            IF l_named_role_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).named_role := l_named_role_tbl(i);
            END IF;

            IF l_non_labor_resource_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).non_labor_resource := l_non_labor_resource_tbl(i);
            END IF;

            IF p_quantity_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).total_quantity := p_quantity_tbl(i);
            END IF;

            IF l_unplanned_flag_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).unplanned_flag := l_unplanned_flag_tbl(i);
            END IF;

            -- Bug 3793623
            IF p_planning_start_date_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).planning_start_date := p_planning_start_date_tbl(i);
            END IF;

            IF p_planning_end_date_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).planning_end_date := p_planning_end_date_tbl(i);
            END IF;

            --For Bug 3877875
            IF p_ATTRIBUTE_CATEGORY_tbl.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE_CATEGORY := p_ATTRIBUTE_CATEGORY_tbl(i);
            END IF;

            IF p_ATTRIBUTE1.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE1 := p_ATTRIBUTE1(i);
            END IF;

            IF p_ATTRIBUTE2.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE2 := p_ATTRIBUTE2(i);
            END IF;

            IF p_ATTRIBUTE3.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE3 := p_ATTRIBUTE3(i);
            END IF;

            IF p_ATTRIBUTE4.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE4 := p_ATTRIBUTE4(i);
            END IF;

            IF p_ATTRIBUTE5.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE5 := p_ATTRIBUTE5(i);
            END IF;

            IF p_ATTRIBUTE6.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE6 := p_ATTRIBUTE6(i);
            END IF;

            IF p_ATTRIBUTE7.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE7 := p_ATTRIBUTE7(i);
            END IF;

            IF p_ATTRIBUTE8.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE8 := p_ATTRIBUTE8(i);
            END IF;

            IF p_ATTRIBUTE9.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE9 := p_ATTRIBUTE9(i);
            END IF;

            IF p_ATTRIBUTE10.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE10 := p_ATTRIBUTE10(i);
            END IF;

            IF p_ATTRIBUTE11.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE11 := p_ATTRIBUTE11(i);
            END IF;

            IF p_ATTRIBUTE12.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE12 := p_ATTRIBUTE12(i);
            END IF;

            IF p_ATTRIBUTE13.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE13 := p_ATTRIBUTE13(i);
            END IF;

            IF p_ATTRIBUTE14.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE14 := p_ATTRIBUTE14(i);
            END IF;

            IF p_ATTRIBUTE15.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE15 := p_ATTRIBUTE15(i);
            END IF;

            IF p_ATTRIBUTE16.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE16 := p_ATTRIBUTE16(i);
            END IF;

            IF p_ATTRIBUTE17.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE17 := p_ATTRIBUTE17(i);
            END IF;

            IF p_ATTRIBUTE18.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE18 := p_ATTRIBUTE18(i);
            END IF;

            IF p_ATTRIBUTE19.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE19 := p_ATTRIBUTE19(i);
            END IF;

            IF p_ATTRIBUTE20.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE20 := p_ATTRIBUTE20(i);
            END IF;

            IF p_ATTRIBUTE21.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE21 := p_ATTRIBUTE21(i);
            END IF;

            IF p_ATTRIBUTE22.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE22 := p_ATTRIBUTE22(i);
            END IF;

            IF p_ATTRIBUTE23.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE23 := p_ATTRIBUTE23(i);
            END IF;

            IF p_ATTRIBUTE24.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE24 := p_ATTRIBUTE24(i);
            END IF;

            IF p_ATTRIBUTE25.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE25 := p_ATTRIBUTE25(i);
            END IF;

            IF p_ATTRIBUTE26.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE26 := p_ATTRIBUTE26(i);
            END IF;

            IF p_ATTRIBUTE27.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE27 := p_ATTRIBUTE27(i);
            END IF;

            IF p_ATTRIBUTE28.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE28 := p_ATTRIBUTE28(i);
            END IF;

            IF p_ATTRIBUTE29.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE29 := p_ATTRIBUTE29(i);
            END IF;

            IF p_ATTRIBUTE30.EXISTS(i) THEN
                l_resource_rec_tbl(i).ATTRIBUTE30 := p_ATTRIBUTE30(i);
            END IF;
            --For bug 3877875

            --For bug 3948128
            IF p_scheduled_delay.EXISTS(i) THEN
                l_resource_rec_tbl(i).scheduled_delay := p_scheduled_delay(i);
            END IF;


    l_trace_stage := 400;
--    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

        END LOOP;
    l_trace_stage := 410;
--    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));


        -------------------------------------------------
        -- Calling Task validation API
        -------------------------------------------------
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Calling API pa_task_assignment_utils.Validate_Create_Assignment';
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;

        l_trace_stage := 420;
        --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
        --dbms_output.put_line('qty bef is '||l_resource_rec_tbl(1).planning_start_Date);
        --dbms_output.put_line('qty aft is '||l_resource_rec_tbl(1).planning_end_date);
        -- For Bug 3665097 : New param p_one_to_one_mapping_flag added below.
        -- This will be synced up with Validate_Create_Assignment changes.
        pa_task_assignment_utils.Validate_Create_Assignment(
        p_calling_context              => p_calling_context,     -- Added for Bug 6856934
        p_one_to_one_mapping_flag      => p_one_to_one_mapping_flag,
        p_task_rec_tbl                 => l_task_rec_tbl,
        p_task_assignment_tbl          => l_resource_rec_tbl,
        x_del_task_level_rec_code_tbl  => l_del_task_level_rec_code_tbl,  --Paramater obsoletted , not in use any more
        x_return_status                => l_return_status);
        --dbms_output.put_line('qty aft is '||l_resource_rec_tbl(1).planning_start_date);
        --dbms_output.put_line('qty aft is '||l_resource_rec_tbl(1).planning_end_date);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Called API pa_task_assignment_utils.Validate_Create_Assignment returned error';
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Returned from pa_task_assignment_utils.Validate_Create_Assignment';
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;

        l_trace_stage := 430;
        --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

        -----------------------------------------------------------------------
        -- Check if the name of records in l_del_task_level_rec_code_tbl is same
        -- as the number of records in   p_task_elem_version_id_tbl - Starts
        -----------------------------------------------------------------------

        l_trace_stage := 460;
        --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
        -----------------------------------------------------------------------
        -- The resource data tables shall be re-populated by the in out parameter
        -- parameter l_resource_rec_tbl, in the API call pa_task_assignment_utils.
        -- Validate_Create_Assignment above. So deleting alll existing data from
        -- the resource data tables.
        -----------------------------------------------------------------------

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Deleting Data from all resource PLSql tables';
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;

        l_trace_stage := 450;
--    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

        -----------------------------------------------------------------------
        -- Repopulating all the resource data tables from the output parameter
        -- table l_resource_rec_tbl of the above API call pa_task_assignment_utils.
        -- Validate_Create_Assignment
        -----------------------------------------------------------------------

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Populating resource data tables from the output parameter table l_resource_rec_tbl';
           pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;

        FOR i IN l_resource_rec_tbl.FIRST .. l_resource_rec_tbl.LAST LOOP
            l_trace_stage := 460;
            --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

            IF l_resource_rec_tbl.EXISTS(i) THEN

                IF l_resource_rec_tbl(i).resource_list_member_id = FND_API.G_MISS_NUM THEN
                    l_eligible_rlm_ids_tbl(i) := NULL;
                ELSE
                    l_eligible_rlm_ids_tbl(i) := l_resource_rec_tbl(i).resource_list_member_id;
                END IF;

                IF l_resource_rec_tbl(i).resource_class_flag = FND_API.G_MISS_CHAR THEN
                    l_resource_class_flag_tbl(i) := NULL;
                ELSE
                    l_resource_class_flag_tbl(i) := l_resource_rec_tbl(i).resource_class_flag;
                END IF;

                IF l_resource_rec_tbl(i).resource_class_code = FND_API.G_MISS_CHAR THEN
                    l_resource_class_code_tbl(i) := NULL;
                ELSE
                    l_resource_class_code_tbl(i) := l_resource_rec_tbl(i).resource_class_code;
                END IF;

                IF l_resource_rec_tbl(i).resource_class_id = FND_API.G_MISS_NUM THEN
                    l_resource_class_id_tbl(i) := NULL;
                ELSE
                    l_resource_class_id_tbl(i) := l_resource_rec_tbl(i).resource_class_id;
                END IF;

                IF l_resource_rec_tbl(i).res_type_code = FND_API.G_MISS_CHAR THEN
                    l_res_type_code_tbl(i) := NULL;
                ELSE
                    l_res_type_code_tbl(i) := l_resource_rec_tbl(i).res_type_code;
                END IF;

                IF l_resource_rec_tbl(i).person_id = FND_API.G_MISS_NUM THEN
                    l_person_id_tbl(i) := NULL;
                ELSE
                    l_person_id_tbl(i) := l_resource_rec_tbl(i).person_id;
                END IF;

                IF l_resource_rec_tbl(i).job_id = FND_API.G_MISS_NUM THEN
                    l_job_id_tbl(i) := NULL;
                ELSE
                    l_job_id_tbl(i) := l_resource_rec_tbl(i).job_id;
                END IF;

                IF l_resource_rec_tbl(i).person_type_code = FND_API.G_MISS_CHAR THEN
                    l_person_type_code_tbl(i) := NULL;
                ELSE
                    l_person_type_code_tbl(i) := l_resource_rec_tbl(i).person_type_code;
                END IF;

                IF l_resource_rec_tbl(i).bom_resource_id = FND_API.G_MISS_NUM THEN
                    l_bom_resource_id_tbl(i) := NULL;
                ELSE
                    l_bom_resource_id_tbl(i) := l_resource_rec_tbl(i).bom_resource_id;
                END IF;

                IF l_resource_rec_tbl(i).inventory_item_id = FND_API.G_MISS_NUM THEN
                    l_inventory_item_id_tbl(i) := NULL;
                ELSE
                    l_inventory_item_id_tbl(i) := l_resource_rec_tbl(i).inventory_item_id;
                END IF;

                IF l_resource_rec_tbl(i).item_category_id = FND_API.G_MISS_NUM THEN
                    l_item_category_id_tbl(i) := NULL;
                ELSE
                    l_item_category_id_tbl(i) := l_resource_rec_tbl(i).item_category_id;
                END IF;

                IF l_resource_rec_tbl(i).project_role_id = FND_API.G_MISS_NUM THEN
                    l_project_role_id_tbl(i) := NULL;
                ELSE
                    l_project_role_id_tbl(i) := l_resource_rec_tbl(i).project_role_id;
                END IF;

                IF l_resource_rec_tbl(i).organization_id = FND_API.G_MISS_NUM THEN
                    l_organization_id_tbl(i) := NULL;
                ELSE
                    l_organization_id_tbl(i) := l_resource_rec_tbl(i).organization_id;
                END IF;

                IF l_resource_rec_tbl(i).fc_res_type_code = FND_API.G_MISS_CHAR THEN
                    l_fc_res_type_code_tbl(i) := NULL;
                ELSE
                    l_fc_res_type_code_tbl(i) := l_resource_rec_tbl(i).fc_res_type_code;
                END IF;

                IF l_resource_rec_tbl(i).expenditure_type = FND_API.G_MISS_CHAR THEN
                    l_expenditure_type_tbl(i) := NULL;
                ELSE
                    l_expenditure_type_tbl(i) := l_resource_rec_tbl(i).expenditure_type;
                END IF;

                IF l_resource_rec_tbl(i).expenditure_category = FND_API.G_MISS_CHAR THEN
                    l_expenditure_category_tbl(i) := NULL;
                ELSE
                    l_expenditure_category_tbl(i) := l_resource_rec_tbl(i).expenditure_category;
                END IF;

                IF l_resource_rec_tbl(i).event_type = FND_API.G_MISS_CHAR THEN
                    l_event_type_tbl(i) := NULL;
                ELSE
                    l_event_type_tbl(i) := l_resource_rec_tbl(i).event_type;
                END IF;

                IF l_resource_rec_tbl(i).revenue_category_code = FND_API.G_MISS_CHAR THEN
                    l_revenue_category_code_tbl(i) := NULL;
                ELSE
                    l_revenue_category_code_tbl(i) := l_resource_rec_tbl(i).revenue_category_code;
                END IF;

                IF l_resource_rec_tbl(i).supplier_id = FND_API.G_MISS_NUM THEN
                    l_supplier_id_tbl(i) := NULL;
                ELSE
                    l_supplier_id_tbl(i) := l_resource_rec_tbl(i).supplier_id;
                END IF;

                IF l_resource_rec_tbl(i).unit_of_measure = FND_API.G_MISS_CHAR THEN
                    l_unit_of_measure_tbl(i) := NULL;
                ELSE
                    l_unit_of_measure_tbl(i) := l_resource_rec_tbl(i).unit_of_measure;
                END IF;

                IF l_resource_rec_tbl(i).spread_curve_id = FND_API.G_MISS_NUM THEN
                    l_spread_curve_id_tbl(i) := NULL;
                ELSE
                    l_spread_curve_id_tbl(i) := l_resource_rec_tbl(i).spread_curve_id;
                END IF;

                IF l_resource_rec_tbl(i).etc_method_code = FND_API.G_MISS_CHAR THEN
                    l_etc_method_code_tbl(i) := NULL;
                ELSE
                    l_etc_method_code_tbl(i) := l_resource_rec_tbl(i).etc_method_code;
                END IF;

                IF l_resource_rec_tbl(i).mfc_cost_type_id = FND_API.G_MISS_NUM THEN
                    l_mfc_cost_type_id_tbl(i) := NULL;
                ELSE
                    l_mfc_cost_type_id_tbl(i) := l_resource_rec_tbl(i).mfc_cost_type_id;
                END IF;

                IF l_resource_rec_tbl(i).procure_resource_flag = FND_API.G_MISS_CHAR THEN
                    l_procure_resource_flag_tbl(i) := NULL;
                ELSE
                    l_procure_resource_flag_tbl(i) := l_resource_rec_tbl(i).procure_resource_flag;
                END IF;

                IF l_resource_rec_tbl(i).incurred_by_res_flag = FND_API.G_MISS_CHAR THEN
                    l_incurred_by_res_flag_tbl(i) := NULL;
                ELSE
                    l_incurred_by_res_flag_tbl(i) := l_resource_rec_tbl(i).incurred_by_res_flag;
                END IF;

                IF l_resource_rec_tbl(i).Incur_by_res_class_code = FND_API.G_MISS_CHAR THEN
                    l_Incur_by_res_class_code_tbl(i) := NULL;
                ELSE
                    l_Incur_by_res_class_code_tbl(i) := l_resource_rec_tbl(i).Incur_by_res_class_code;
                END IF;

                IF l_resource_rec_tbl(i).Incur_by_role_id = FND_API.G_MISS_NUM THEN
                    l_Incur_by_role_id_tbl(i) := NULL;
                ELSE
                    l_Incur_by_role_id_tbl(i) := l_resource_rec_tbl(i).Incur_by_role_id;
                END IF;

                IF l_resource_rec_tbl(i).named_role = FND_API.G_MISS_CHAR THEN
                    l_named_role_tbl(i) := NULL;
                ELSE
                    l_named_role_tbl(i) := l_resource_rec_tbl(i).named_role;
                END IF;

                IF l_resource_rec_tbl(i).non_labor_resource = FND_API.G_MISS_CHAR THEN
                    l_non_labor_resource_tbl(i) := NULL;
                ELSE
                    l_non_labor_resource_tbl(i) := l_resource_rec_tbl(i).non_labor_resource;
                END IF;

                IF l_resource_rec_tbl(i).resource_assignment_id = FND_API.G_MISS_NUM THEN
                    l_resource_assignment_id_tbl(i) := NULL;
                ELSE
                    l_resource_assignment_id_tbl(i) := l_resource_rec_tbl(i).resource_assignment_id;
                END IF;

                IF l_resource_rec_tbl(i).assignment_description = FND_API.G_MISS_CHAR THEN
                    l_assignment_description_tbl(i) := NULL;
                ELSE
                    l_assignment_description_tbl(i) := l_resource_rec_tbl(i).assignment_description;
                END IF;

                IF l_resource_rec_tbl(i).planning_resource_alias = FND_API.G_MISS_CHAR THEN
                    l_planning_resource_alias_tbl(i) := NULL;
                ELSE
                    l_planning_resource_alias_tbl(i) := l_resource_rec_tbl(i).planning_resource_alias;
                END IF;

                IF l_resource_rec_tbl(i).resource_name = FND_API.G_MISS_CHAR THEN
                    l_resource_name_tbl(i) := NULL;
                ELSE
                    l_resource_name_tbl(i) := l_resource_rec_tbl(i).resource_name;
                END IF;

                IF l_resource_rec_tbl(i).project_role_name = FND_API.G_MISS_CHAR THEN
                    l_project_role_name_tbl(i) := NULL;
                ELSE
                    l_project_role_name_tbl(i) := l_resource_rec_tbl(i).project_role_name;
                END IF;

                IF l_resource_rec_tbl(i).organization_name = FND_API.G_MISS_CHAR THEN
                    l_organization_name_tbl(i) := NULL;
                ELSE
                    l_organization_name_tbl(i) := l_resource_rec_tbl(i).organization_name;
                END IF;

                IF l_resource_rec_tbl(i).financial_category_code = FND_API.G_MISS_CHAR THEN
                    l_financial_category_code_tbl(i) := NULL;
                ELSE
                    l_financial_category_code_tbl(i) := l_resource_rec_tbl(i).financial_category_code;
                END IF;

                IF l_resource_rec_tbl(i).project_assignment_id = FND_API.G_MISS_NUM THEN
                    l_project_assignment_id_tbl(i) := NULL;
                ELSE
                    l_project_assignment_id_tbl(i) := l_resource_rec_tbl(i).project_assignment_id;
                END IF;

              -- gboomina modified for bug 8586393 - start
                /*IF l_resource_rec_tbl(i).use_task_schedule_flag = FND_API.G_MISS_CHAR THEN
                    l_use_task_schedule_flag_tbl(i) := NULL;
                ELSE
                    l_use_task_schedule_flag_tbl(i) := l_resource_rec_tbl(i).use_task_schedule_flag;
                END IF; */
                --OPEN C2(p_project_id);
                --FETCH C2 INTO l_use_task_schedule_flag;
                --CLOSE C2;
                --l_use_task_schedule_flag_tbl(i) := l_use_task_schedule_flag;
                -- gboomina modified for bug 8586393 - end

                -- rbruno bug 9468665  - start
                -- set the default value only if use_task_schedule_flag value is G_MISS_CHAR
                IF l_resource_rec_tbl(i).use_task_schedule_flag = FND_API.G_MISS_CHAR THEN
                    OPEN C2(p_project_id);
                    FETCH C2 INTO l_use_task_schedule_flag;
                    CLOSE C2;
                    l_use_task_schedule_flag_tbl(i) := l_use_task_schedule_flag;
                ELSE
                    l_use_task_schedule_flag_tbl(i) := l_resource_rec_tbl(i).use_task_schedule_flag;
                END IF;
                -- rbruno bug 9468665  - end

                IF l_resource_rec_tbl(i).planning_start_date = FND_API.G_MISS_DATE THEN
                    l_planning_start_date_tbl(i) := NULL;
                ELSE
                    l_planning_start_date_tbl(i) := l_resource_rec_tbl(i).planning_start_date;
                END IF;

                IF l_resource_rec_tbl(i).planning_end_date = FND_API.G_MISS_DATE THEN
                    l_planning_end_date_tbl(i) := NULL;
                ELSE
                    l_planning_end_date_tbl(i) := l_resource_rec_tbl(i).planning_end_date;
                END IF;

                IF l_resource_rec_tbl(i).schedule_start_date = FND_API.G_MISS_DATE THEN
                    l_schedule_start_date_tbl(i) := NULL;
                ELSE
                    l_schedule_start_date_tbl(i) := l_resource_rec_tbl(i).schedule_start_date;
                END IF;

                IF l_resource_rec_tbl(i).schedule_end_date = FND_API.G_MISS_DATE THEN
                    l_schedule_end_date_tbl(i) := NULL;
                ELSE
                    l_schedule_end_date_tbl(i) := l_resource_rec_tbl(i).schedule_end_date;
                END IF;

                IF l_resource_rec_tbl(i).supplier_name = FND_API.G_MISS_CHAR THEN
                    l_supplier_name_tbl(i) := NULL;
                ELSE
                    l_supplier_name_tbl(i) := l_resource_rec_tbl(i).supplier_name;
                END IF;

                IF l_resource_rec_tbl(i).financial_category_name = FND_API.G_MISS_CHAR THEN
                    l_financial_category_name_tbl(i) := NULL;
                ELSE
                    l_financial_category_name_tbl(i) := l_resource_rec_tbl(i).financial_category_name;
                END IF;

                IF l_resource_rec_tbl(i).sp_fixed_date = FND_API.G_MISS_DATE THEN
                    l_sp_fixed_date_tbl(i) := NULL;
                ELSE
                    l_sp_fixed_date_tbl(i) := l_resource_rec_tbl(i).sp_fixed_date;
-- Added validation rule for sp_fixed_date to lie between planning start date and planning end date for
-- fixed curve spread curve id. - Bug 3607061 Starts. Please NOTE that fixed date spread curve id is
-- SEEDED as 6, so we are able to hard code it below

                    IF l_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage :='l_spread_curve_id_tbl - '||l_spread_curve_id_tbl(i);
                       pa_debug.write(g_module_name,pa_debug.g_err_stage,3);

                       pa_debug.g_err_stage :='l_sp_fixed_date_tbl'||l_sp_fixed_date_tbl(i);
                       pa_debug.write(g_module_name,pa_debug.g_err_stage,3);

                       pa_debug.g_err_stage :='l_planning_start_date_tbl'||l_planning_start_date_tbl(i);
                       pa_debug.write(g_module_name,pa_debug.g_err_stage,3);

                       pa_debug.g_err_stage :='l_planning_end_date_tbl'||l_planning_end_date_tbl(i);
                       pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
                    END IF;

                    IF ((l_spread_curve_id_tbl(i) = l_fixed_date_sp_id) AND
                        (l_sp_fixed_date_tbl(i) IS NOT NULL) AND
                        (l_sp_fixed_date_tbl(i) NOT BETWEEN l_planning_start_date_tbl(i) AND l_planning_end_date_tbl(i)))THEN
                           IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage :='Sp Fixed Date not between planning start date and End Date';
                              pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
                           END IF;
                       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                            p_msg_name       => 'PA_FP_SP_FIXED_DATE_OUT');
                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;
-- Bug 3607061 Ends
                END IF;

                IF l_resource_rec_tbl(i).burdened_rate_override = FND_API.G_MISS_NUM THEN
                    l_burdened_rate_override_tbl(i) := NULL;
                ELSE
                    l_burdened_rate_override_tbl(i) := l_resource_rec_tbl(i).burdened_rate_override;
                END IF;

                IF l_resource_rec_tbl(i).cost_rate_override = FND_API.G_MISS_NUM THEN
                    l_cost_rate_override_tbl(i) := NULL;
                ELSE
                    l_cost_rate_override_tbl(i) := l_resource_rec_tbl(i).cost_rate_override;
                END IF;

                IF l_resource_rec_tbl(i).billable_percent = FND_API.G_MISS_NUM THEN
                    l_billable_percent_tbl(i) := NULL;
                ELSE
                    l_billable_percent_tbl(i) := l_resource_rec_tbl(i).billable_percent;
                END IF;

                IF l_resource_rec_tbl(i).override_currency_code = FND_API.G_MISS_CHAR THEN
                    l_override_currency_code_tbl(i) := NULL;
                ELSE
                    l_override_currency_code_tbl(i) := l_resource_rec_tbl(i).override_currency_code;
                END IF;

                IF l_resource_rec_tbl(i).total_quantity = FND_API.G_MISS_NUM THEN
                    l_total_quantity_tbl(i) := NULL;
                ELSE
                    l_total_quantity_tbl(i) := l_resource_rec_tbl(i).total_quantity;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE_CATEGORY = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE_CATEGORY_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE_CATEGORY_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE_CATEGORY;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE1 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE1_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE1_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE1;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE2 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE2_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE2_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE2;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE3 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE3_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE3_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE3;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE4 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE4_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE4_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE4;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE5 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE5_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE5_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE5;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE6 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE6_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE6_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE6;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE7 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE7_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE7_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE7;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE8 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE8_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE8_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE8;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE9 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE9_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE9_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE9;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE10 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE10_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE10_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE10;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE11 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE11_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE11_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE11;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE12 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE12_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE12_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE12;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE13 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE13_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE13_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE13;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE14 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE14_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE14_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE14;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE15 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE15_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE15_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE15;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE16 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE16_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE16_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE16;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE17 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE17_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE17_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE17;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE18 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE18_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE18_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE18;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE19 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE19_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE19_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE19;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE20 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE20_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE20_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE20;
                END IF;
                IF l_resource_rec_tbl(i).ATTRIBUTE21 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE21_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE21_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE21;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE22 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE22_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE22_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE22;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE23 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE23_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE23_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE23;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE24 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE24_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE24_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE24;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE25 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE25_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE25_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE25;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE26 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE26_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE26_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE26;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE27 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE27_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE27_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE27;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE28 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE28_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE28_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE28;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE29 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE29_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE29_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE29;
                END IF;

                IF l_resource_rec_tbl(i).ATTRIBUTE30 = FND_API.G_MISS_CHAR THEN
                    l_ATTRIBUTE30_tbl(i) := NULL;
                ELSE
                    l_ATTRIBUTE30_tbl(i) := l_resource_rec_tbl(i).ATTRIBUTE30;
                END IF;

                IF l_resource_rec_tbl(i).UNPLANNED_FLAG = FND_API.G_MISS_CHAR THEN
                    l_UNPLANNED_FLAG_TBL(i) := NULL;
                ELSE
                    l_UNPLANNED_FLAG_TBL(i) := l_resource_rec_tbl(i).UNPLANNED_FLAG;
                END IF;

                IF l_resource_rec_tbl(i).scheduled_delay = FND_API.G_MISS_NUM THEN
                    l_scheduled_delay(i) := NULL;
                ELSE
                    l_scheduled_delay(i) := l_resource_rec_tbl(i).scheduled_delay;
                END IF;


            END IF;
            l_trace_stage := 470;
        --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
        END LOOP;
        l_trace_stage := 480;
        --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

        ----------------------------------------------------------------------------
        -- Now derive the resource_assignment id for all the task_element_version_id
        -- based on the resource_class_code(l_del_task_level_rec_code_tbl)  to be
        -- 'PEOPLE'.
        -- The resource_assignment_id is bulk collected into a PLSql table and then
        -- All data is deleted in bulk from pa_budget_lines and pa_resource_assignment
        -- based on the resource_assignment_id

        --***************************************************************************************
        -- Bug 3749516 resource_class_code(l_del_task_level_rec_code_tbl) will not be 'EQUIPMENT'
        -- REMOVING CODE BELOW FOR SAME
        --***************************************************************************************
        ------------------------------------------------------------------------------

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='data is deleted in bulk from pa_budget_lines and pa_resource_assignment  based on the resource_assignment_id ';
           pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;

    END IF;
    --------------------------------------------------------------------------
    -- Processing for p_context = TASK_ASSIGNMENTS End Here
    --------------------------------------------------------------------------

    ------------------------------------------------------------------------------------------------
    -- Deriving Time Phased Code based on the budget version id and setting the spread amount flad
    -------------------------------------------------------------------------------------------------
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Deriving time phased code ';
        pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    l_time_phased_code := pa_fin_plan_utils.get_time_phased_code(p_budget_version_id);

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Deriving time phased code l_time_phased_code: '||l_time_phased_code;
        pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;
    l_trace_stage := 550;
    --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

    IF ((l_time_phased_code = PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_PA) OR (l_time_phased_code = PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_GL)) THEN
        l_spread_amounts_for_ver := 'Y';
    ELSE
        l_spread_amounts_for_ver := 'N';
    END IF;

    l_trace_stage := 560;
    --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

    ------------------------------------------------------------------------------------------------
    -- Deriving Proj Element Id based on element version id
    -------------------------------------------------------------------------------------------------
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Deriving Proj Element Id based on element version id';
        pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    FOR i IN p_task_elem_version_id_tbl.FIRST .. p_task_elem_version_id_tbl.LAST LOOP
        l_trace_stage := 570;
        --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
        IF p_task_elem_version_id_tbl(i) <> 0 THEN
            OPEN c_proj_element_id(p_task_elem_version_id_tbl(i));
            l_trace_stage := 580;
            --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
            FETCH c_proj_element_id INTO l_proj_element_id;
            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Deriving Proj Element Id based on element version id l_proj_element_id : '|| l_proj_element_id;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;
            l_proj_element_id_tbl(i) := l_proj_element_id;
            CLOSE c_proj_element_id;
        ELSE
            l_proj_element_id_tbl(i):=0;
        END IF;
        l_trace_stage := 590;
        --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
    END LOOP;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Deriving Proj Element Id based on element version id l_proj_element_id_tbl cnt : '|| l_proj_element_id_tbl.COUNT;
        pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;
    l_trace_stage := 600;
    --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

    ---------------------------------------------------------------
    -- For p_context = BUDGET or FORECAST
    -- Deriving start date and end date for task_element_version_id
    ---------------------------------------------------------------
    IF ((p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET) OR (p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FORECAST))  THEN
        l_trace_stage := 610;
        --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Deriving start date for task_element_version_ids';
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;

        -- Bug 3793623 - Added new params p_planning_start_date_tbl and p_planning_end_date_tbl
        PA_PLANNING_TRANSACTION_UTILS.get_default_planning_dates
        ( p_project_id                      => p_project_id
         ,p_element_version_id_tbl          => p_task_elem_version_id_tbl
         ,p_project_structure_version_id    => PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(p_project_id => p_project_id )
         ,p_planning_start_date_tbl         => p_planning_start_date_tbl
         ,p_planning_end_date_tbl           => p_planning_end_date_tbl
         ,x_planning_start_date_tbl         => l_start_date_tbl
         ,x_planning_end_date_tbl           => l_compl_date_tbl
         ,x_msg_data                        => x_msg_data
         ,x_msg_count                       => x_msg_count
         ,x_return_status                   => x_return_status  );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

             IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Called API pafpptub.get_default_planning_dates returned error';
                   pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ',pa_debug.g_err_stage, 3);
             END IF;
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        l_trace_stage := 710;
        --      hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
    END IF;
    l_trace_stage := 720;
--      hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));

    -----------------------------------------------------------------------------------------------------
    -- BULK INSERTING DATA INTO PA_RESOURCE_ASSIGNMENTS--------------------------------------------------
    -----------------------------------------------------------------------------------------------------
    -- Loop throught the task element version id table and do a bulk insert in to pa_resource_assignments
    -- 1. In the context of WORKPLAN, Loop for p_task_element_version_id_tbl, and insert into pa_resource
    --    assignment. l_elligble_rlm_ids will only have rlm id for 'PEOPLE' resource class. so a local
    --    index l_ppl_index(=1) is used for resource data. Data is inserted in pa_resource_assignments
    --    only if quanity dat ais present. this check is done and eligible data to be inserted is fetched
    --    in local plsql tables.
    --    -- Bug 3749516 removing equipment_quantity reference - refer prev. code in source control for
    --    -- reference
    -- 2. Else if the context is not workplan then,records is inserted
    --    irrespective of the value of quantity.The bulk insert procedure in pa_fp_elements_pub is used
    --    for this. If l_spread_amts_for_ver = 'Y'For each record inserted prepare a pl/sql table containing
    --   'Y' if the record is inserted and the amount exists(note that this amount can be raw cost, burdened
    --   cost, quantity in the case of Budget/Forecast and quantity in the case of Task Assignment).If the
    --   amount does not exist then the pl/sql table should contain 'N'. This will be used as the paramter
    --   for p_spread_amt_flags parameter in the calculate API (A separate loop may be required for this)
    --   Please note that in the context of TASK ASSIGNMENT, if some value is being returned by the TA
    --   validation API then that value should be used.
    -----------------------------------------------------------------------------------------------------

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='BULK INSERTING DATA INTO PA_RESOURCE_ASSIGNMENTS ';
        pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    l_call_calc_api := 'N';

    OPEN  get_pc_code;
    FETCH get_pc_code
    INTO  l_proj_curr_code, l_proj_func_curr_code;
    CLOSE get_pc_code;

    ---------------------------------------------------------------------
    -- These _rlm tables have been extented to the length of rlm_id table
    -- and they will be used for insert in Budget/Forecast context when
    -- One to One Mapping Flag is passed as Y
    -- Bug 3719918 and Bug 3665097
    ----------------------------------------------------------------------
    IF (p_one_to_one_mapping_flag = 'Y' AND
       (p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK OR
        p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET OR
        p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FORECAST))THEN
        l_task_elem_rlm_tbl := p_task_elem_version_id_tbl;
        l_proj_elem_rlm_tbl := l_proj_element_id_tbl;
    END IF;

    -- Bug 3719918
    -- If One ONe to One Mapping Flag is Y in Bugdet and Forecast Context then ..
    -- there might be duplicate decords for resource assignments present in the
    -- IN tables correspoinging to different currency code.
    -- Eg. p_one_to_one_mapping_flag - 'Y'
    --     Task elem ver id - t1,t1,t2
    --     RLM              - r1,r1,r2
    --     Currency Code    - c1,c2,c2
    -- in this case ..2 resource assignments are created - t1r1 and t2r2
    -- calculate is called for three lines .. t1r1c1,t1r1c2,t2r2c2
    -- the below logic is used in BF context and will reduce the input data to the
    -- following form --   Task elem ver id : t1,t2 and RLM : r1,r2
    -- This will be used in the insert statment for B/F

    IF (p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET OR
        p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FORECAST ) THEN

        IF (p_one_to_one_mapping_flag = 'Y') THEN

            l_bf_start_date_tbl        := l_start_date_tbl;
            l_bf_compl_date_tbl        := l_compl_date_tbl;
            l_bf_proj_elem_tbl         := l_proj_element_id_tbl;
            l_bf_quantity_tbl          :=  p_quantity_tbl;
            l_bf_currency_code_tbl     :=  p_currency_code_tbl;
            l_bf_raw_cost_tbl          :=  p_raw_cost_tbl;
            l_bf_burdened_cost_tbl     :=  p_burdened_cost_tbl;
            l_bf_revenue_tbl           :=  p_revenue_tbl;
            l_bf_cost_rate_tbl         :=  p_cost_rate_tbl;
            l_bf_bill_rate_tbl         :=  p_bill_rate_tbl ;
            l_bf_burdened_rate_tbl     :=  p_burdened_rate_tbl;


        END IF;--IF (p_one_to_one_mapping_flag = 'Y') THEN

        --The l_bf<amounts> tbls should have elements equal in no to l_rlm_id_no_of_rows as these tbls will be used
        --in the FORALL insert which will loop thru the rlm id pl/sql tbl. Note that they are used only when
        --p_one_to_one_mapping_flag is Y

        l_bf_quantity_tbl.extend(l_rlm_id_no_of_rows-l_bf_quantity_tbl.count);
        l_bf_currency_code_tbl.extend(l_rlm_id_no_of_rows-l_bf_currency_code_tbl.count);
        l_bf_raw_cost_tbl.extend(l_rlm_id_no_of_rows-l_bf_raw_cost_tbl.count);
        l_bf_burdened_cost_tbl.extend(l_rlm_id_no_of_rows-l_bf_burdened_cost_tbl.count);
        l_bf_revenue_tbl.extend(l_rlm_id_no_of_rows-l_bf_revenue_tbl.count);
        l_bf_cost_rate_tbl.extend(l_rlm_id_no_of_rows-l_bf_cost_rate_tbl.count);
        l_bf_bill_rate_tbl.extend(l_rlm_id_no_of_rows-l_bf_bill_rate_tbl.count);
        l_bf_burdened_rate_tbl.extend(l_rlm_id_no_of_rows-l_bf_burdened_rate_tbl.count);

    END IF; -- IF (p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET OR

    ----------------------------------------------------
    -- THESE DEBUG MESSAGES ARE BEING PLACED HERE ONLY FOR
    -- REFERENCE SO THAT THEY CAN BE USED WHEN AND WHERE
    -- NEEDED FOR DEBUGGIND ISSUE WITH BULK DTA INSERTION.
    -----------------------------------------------------
                /*
                pa_debug.g_err_stage:='l_proj_element_id_tbl :'||l_proj_element_id_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_unit_of_measure_tbl :'||l_unit_of_measure_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='p_task_elem_version_id_tbl :'||p_task_elem_version_id_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_start_date_tbl :'||p_start_date_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_end_date_tbl :'||p_end_date_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_etc_method_code_tbl :'||l_etc_method_code_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_res_type_code_tbl :'||l_res_type_code_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_fc_res_type_code_tbl :'||l_fc_res_type_code_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_resource_class_code_tbl :'||l_resource_class_code_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_organization_id_tbl :'||l_organization_id_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_job_id_tbl :'||l_job_id_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_person_id_tbl :'||l_person_id_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_revenue_category_code_tbl :'||l_revenue_category_code_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_expenditure_type_tbl :'||l_expenditure_type_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_expenditure_category_tbl :'||l_expenditure_category_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_non_labor_resource_tbl :'||l_non_labor_resource_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_event_type_tbl :'||l_event_type_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_supplier_id_tbl :'||l_supplier_id_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_inventory_item_id_tbl :'||l_inventory_item_id_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_bom_resource_id_tbl :'||l_bom_resource_id_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_inventory_item_id_tbl :'||l_inventory_item_id_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_item_category_id_tbl :'||l_item_category_id_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_mfc_cost_type_id_tbl :'||l_mfc_cost_type_id_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_rate_expenditure_type_tbl :'||l_rate_expenditure_type_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_rate_func_curr_code_tbl :'||l_rate_func_curr_code_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_rate_based_flag_tbl :'||l_rate_based_flag_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_resource_class_flag_tbl :'||l_resource_class_flag_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_named_role_tbl :'||l_named_role_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_incur_by_res_class_code_tbl :'||l_incur_by_res_class_code_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='l_budget_version_id :'||l_budget_version_id;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='p_project_id :'||p_project_id;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='task_id :'||l_proj_element_id_tbl(i);
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='project_assignment_id : -1';
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage:='RESOURCE_LIST_MEMBER_ID :'||l_people_res_class_rlm_id;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);*/

                /*    l_trace_stage := 761;
                hr_utility.trace('l_proj_element_id_tbl(i) => '||to_char(l_proj_element_id_tbl(i)));
                hr_utility.trace('l_unit_of_measure_tbl(l_ppl_index) => '||to_char(l_unit_of_measure_tbl(l_ppl_index)));
                hr_utility.trace('p_task_elem_version_id_tbl(i) => '||to_char(p_task_elem_version_id_tbl(i)));
                hr_utility.trace('p_start_date_tbl(i) => '||to_char(p_start_date_tbl(i)));
                hr_utility.trace('p_end_date_tbl(i) => '||to_char(p_end_date_tbl(i)));
                hr_utility.trace(' l_spread_curve_id_tbl(l_ppl_index) => '||to_char(l_spread_curve_id_tbl(l_ppl_index)));
                hr_utility.trace('l_etc_method_code_tbl(l_ppl_index) => '||to_char(l_etc_method_code_tbl(l_ppl_index)));
                hr_utility.trace('l_res_type_code_tbl(l_ppl_index) => '||to_char(l_res_type_code_tbl(l_ppl_index)));
                hr_utility.trace('l_fc_res_type_code_tbl(l_ppl_index) => '||to_char(l_fc_res_type_code_tbl(l_ppl_index)));
                hr_utility.trace('l_resource_class_code_tbl(l_ppl_index) => '||to_char(l_resource_class_code_tbl(l_ppl_index)));
                hr_utility.trace('l_organization_id_tbl(l_ppl_index) => '||to_char(l_organization_id_tbl(l_ppl_index)));
                hr_utility.trace('l_job_id_tbl(l_ppl_index) => '||to_char(l_job_id_tbl(l_ppl_index)));
                hr_utility.trace('l_person_id_tbl(l_ppl_index) => '||to_char(l_person_id_tbl(l_ppl_index)));
                hr_utility.trace('l_expenditure_type_tbl(l_ppl_index) => '||to_char(l_expenditure_type_tbl(l_ppl_index)));
                hr_utility.trace('l_expenditure_category_tbl(l_ppl_index) => '||to_char(l_expenditure_category_tbl(l_ppl_index)));
                hr_utility.trace('l_revenue_category_code_tbl(l_ppl_index) => '||to_char(l_revenue_category_code_tbl(l_ppl_index)));
                hr_utility.trace('l_event_type_tbl(l_ppl_index) => '||to_char(l_event_type_tbl(l_ppl_index)));
                hr_utility.trace('l_supplier_id_tbl(l_ppl_index) => '||to_char(l_supplier_id_tbl(l_ppl_index)));
                hr_utility.trace('l_non_labor_resource_tbl(l_ppl_index) => '||to_char(l_non_labor_resource_tbl(l_ppl_index)));
                hr_utility.trace('l_bom_resource_id_tbl(l_ppl_index) => '||to_char(l_bom_resource_id_tbl(l_ppl_index)));
                hr_utility.trace('l_inventory_item_id_tbl(l_ppl_index) => '||to_char(l_inventory_item_id_tbl(l_ppl_index)));
                hr_utility.trace('l_mfc_cost_type_id_tbl(l_ppl_indexj) => '||to_char(l_mfc_cost_type_id_tbl(l_ppl_indexj)));
                hr_utility.trace('l_rate_expenditure_type_tbl(l_ppl_indexj) => '||to_char(l_rate_expenditure_type_tbl(l_ppl_index)));
                hr_utility.trace('l_rate_based_flag_tbl(l_ppl_index) => '||to_char(l_rate_based_flag_tbl(l_ppl_index)));
                hr_utility.trace('l_rate_func_curr_code_tbl(l_ppl_index) => '||to_char(l_rate_func_curr_code_tbl(l_ppl_index)));
                hr_utility.trace('l_incur_by_res_class_code_tbl(l_ppl_index) => '||to_char(l_incur_by_res_class_code_tbl(l_ppl_index)));
                hr_utility.trace('l_resource_class_flag_tbl(l_ppl_index) => '||to_char(l_resource_class_flag_tbl(l_ppl_index)));
                hr_utility.trace('l_named_role_tbl(l_ppl_index) => '||to_char(l_named_role_tbl(l_ppl_index)));*/

    --------------------------------------------
    -- for p_context - WORKPLAN
    --------------------------------------------
    IF p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN THEN

        -- Bug 3749516 Changing All reference of l_ppl_equip_index to l_ppl_index below
        l_ppl_index:=1; --This will be used in the bulk insert for people -- -- Bug 3749516

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='BULK INSERTING DATA - p_context - Workplan :'||p_context ;
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='BULK INSERTING Workplan DATA - rlm id :'||l_eligible_rlm_ids_tbl(l_ppl_index) ;
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,6);
        END IF;
        -- gboomina Bug 8586393 - start
        -- Get 'Assignment same as Task Duration' flag from workplan attribute
        -- and default it for hidden task assignments
        OPEN C2(p_project_id);
        FETCH C2 INTO l_use_task_schedule_flag;
        CLOSE C2;
        -- gboomina Bug 8586393 - end

        FOR i IN p_task_elem_version_id_tbl.FIRST .. p_task_elem_version_id_tbl.LAST LOOP
            IF ((p_planned_people_effort_tbl.EXISTS(i)) AND
                (nvl(p_planned_people_effort_tbl(i),FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM) AND
                /* bug fix:5726773 (p_planned_people_effort_tbl(i) > 0)) THEN*/
 	        (p_planned_people_effort_tbl(i) is NOT NULL)) THEN
                 l_ins_proj_element_id_tbl(l_ins_index)          :=  l_proj_element_id_tbl(i);
                 l_ins_task_elem_version_id_tbl(l_ins_index)     :=  p_task_elem_version_id_tbl(i);
                 l_ins_start_date_tbl(l_ins_index)               :=  p_start_date_tbl(i);
                 l_ins_end_date_tbl(l_ins_index)                 :=  p_end_date_tbl(i);
                 l_ins_cal_people_effort_tbl(l_ins_index)        :=  p_planned_people_effort_tbl(i);
                  -- gboomina Bug 8586393 - start
                 l_use_task_schedule_flag_tbl(l_ins_index) := l_use_task_schedule_flag;
                 -- gboomina Bug 8586393 - end

                 IF p_burdened_cost_tbl.EXISTS(i) THEN
                    l_ins_cal_burdened_cost_tbl(l_ins_index)        :=  p_burdened_cost_tbl(i);
                 END IF;
                 IF p_raw_cost_tbl.EXISTS(i) THEN
                    l_ins_cal_raw_cost_tbl(l_ins_index)             :=  p_raw_cost_tbl(i);
                 END IF;
                 l_ins_index := l_ins_index + 1;
            END IF;
        END LOOP;


        l_ins_proj_element_id_tbl.delete(l_ins_index,l_ins_proj_element_id_tbl.count);
        l_ins_task_elem_version_id_tbl.delete(l_ins_index,l_ins_task_elem_version_id_tbl.count);
        l_ins_start_date_tbl.delete(l_ins_index,l_ins_start_date_tbl.count);
        l_ins_end_date_tbl.delete(l_ins_index,l_ins_end_date_tbl.count);
        l_ins_cal_people_effort_tbl.delete(l_ins_index,l_ins_cal_people_effort_tbl.count);
        l_ins_cal_burdened_cost_tbl.delete(l_ins_index,l_ins_cal_burdened_cost_tbl.count);
        l_ins_cal_raw_cost_tbl.delete(l_ins_index,l_ins_cal_raw_cost_tbl.count);
         -- gboomina Bug 8586393 - start
        l_use_task_schedule_flag_tbl.delete(l_ins_index,l_use_task_schedule_flag_tbl.count);
        -- gboomina Bug 8586393 - end


        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='AFTER PREPARING INS DATA :'||p_context ;
            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

            IF l_ins_task_elem_version_id_tbl.COUNT >0 THEN
               FOR i in l_ins_task_elem_version_id_tbl.FIRST .. l_ins_task_elem_version_id_tbl.LAST LOOP
                pa_debug.g_err_stage:='l_ins_proj_element_id_tbl :'||l_ins_proj_element_id_tbl(i) ;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

                pa_debug.g_err_stage:='l_ins_task_elem_version_id_tbl :'||l_ins_task_elem_version_id_tbl(i) ;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

                pa_debug.g_err_stage:='l_ins_start_date_tbl :'||l_ins_start_date_tbl(i) ;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

                pa_debug.g_err_stage:='l_ins_end_date_tbl :'||l_ins_end_date_tbl(i) ;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
               END LOOP;
            END IF;
        END IF;

        IF l_ins_task_elem_version_id_tbl.COUNT > 0 THEN
                FORALL i IN l_ins_task_elem_version_id_tbl.FIRST .. l_ins_task_elem_version_id_tbl.LAST
                INSERT INTO PA_RESOURCE_ASSIGNMENTS (
                    RESOURCE_ASSIGNMENT_ID,BUDGET_VERSION_ID,PROJECT_ID,TASK_ID,RESOURCE_LIST_MEMBER_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY
                    ,LAST_UPDATE_LOGIN,UNIT_OF_MEASURE,TRACK_AS_LABOR_FLAG,STANDARD_BILL_RATE,AVERAGE_BILL_RATE,AVERAGE_COST_RATE
                    ,PROJECT_ASSIGNMENT_ID,PLAN_ERROR_CODE,TOTAL_PLAN_REVENUE,TOTAL_PLAN_RAW_COST,TOTAL_PLAN_BURDENED_COST,TOTAL_PLAN_QUANTITY
                    ,AVERAGE_DISCOUNT_PERCENTAGE,TOTAL_BORROWED_REVENUE,TOTAL_TP_REVENUE_IN,TOTAL_TP_REVENUE_OUT,TOTAL_REVENUE_ADJ
                    ,TOTAL_LENT_RESOURCE_COST,TOTAL_TP_COST_IN,TOTAL_TP_COST_OUT,TOTAL_COST_ADJ,TOTAL_UNASSIGNED_TIME_COST
                    ,TOTAL_UTILIZATION_PERCENT,TOTAL_UTILIZATION_HOURS,TOTAL_UTILIZATION_ADJ,TOTAL_CAPACITY,TOTAL_HEAD_COUNT
                    ,TOTAL_HEAD_COUNT_ADJ,RESOURCE_ASSIGNMENT_TYPE,TOTAL_PROJECT_RAW_COST,TOTAL_PROJECT_BURDENED_COST,TOTAL_PROJECT_REVENUE
                    ,PARENT_ASSIGNMENT_ID,WBS_ELEMENT_VERSION_ID,RBS_ELEMENT_ID,PLANNING_START_DATE,PLANNING_END_DATE,SCHEDULE_START_DATE,SCHEDULE_END_DATE
                    ,SPREAD_CURVE_ID,ETC_METHOD_CODE,RES_TYPE_CODE,ATTRIBUTE_CATEGORY,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5
                    ,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15
                    ,ATTRIBUTE16,ATTRIBUTE17,ATTRIBUTE18,ATTRIBUTE19,ATTRIBUTE20,ATTRIBUTE21,ATTRIBUTE22,ATTRIBUTE23,ATTRIBUTE24,ATTRIBUTE25
                    ,ATTRIBUTE26,ATTRIBUTE27,ATTRIBUTE28,ATTRIBUTE29,ATTRIBUTE30,FC_RES_TYPE_CODE,RESOURCE_CLASS_CODE,ORGANIZATION_ID,JOB_ID
                    ,PERSON_ID,EXPENDITURE_TYPE,EXPENDITURE_CATEGORY,REVENUE_CATEGORY_CODE,EVENT_TYPE,SUPPLIER_ID,NON_LABOR_RESOURCE
                    ,BOM_RESOURCE_ID,INVENTORY_ITEM_ID,ITEM_CATEGORY_ID,RECORD_VERSION_NUMBER,BILLABLE_PERCENT
                    ,TRANSACTION_SOURCE_CODE,MFC_COST_TYPE_ID,PROCURE_RESOURCE_FLAG,ASSIGNMENT_DESCRIPTION
                    ,INCURRED_BY_RES_FLAG,RATE_JOB_ID,RATE_EXPENDITURE_TYPE,TA_DISPLAY_FLAG
                    ,SP_FIXED_DATE,PERSON_TYPE_CODE,RATE_BASED_FLAG,USE_TASK_SCHEDULE_FLAG,RATE_EXP_FUNC_CURR_CODE
                    ,RATE_EXPENDITURE_ORG_ID,INCUR_BY_RES_CLASS_CODE,INCUR_BY_ROLE_ID
                    ,PROJECT_ROLE_ID,RESOURCE_CLASS_FLAG,NAMED_ROLE,TXN_ACCUM_HEADER_ID
                    ,PM_PRODUCT_CODE, PM_RES_ASSIGNMENT_REFERENCE, resource_rate_based_flag)
                   VALUES (
                         PA_RESOURCE_ASSIGNMENTS_S.NEXTVAL                                -- RESOURCE_ASSIGNMENT_ID
                        ,l_budget_version_id                                              -- BUDGET_VERSION_ID
                        ,p_project_id                                                     -- PROJECT_ID
                        ,l_ins_proj_element_id_tbl(i)                                     -- TASK_ID
                        ,l_people_res_class_rlm_id                                        -- RESOURCE_LIST_MEMBER_ID
                        ,sysdate                                                          -- LAST_UPDATE_DATE
                        ,fnd_global.user_id                                               -- LAST_UPDATED_BY
                        ,sysdate                                                          -- CREATION_DATE
                        ,fnd_global.user_id                                               -- CREATED_BY
                        ,fnd_global.login_id                                              -- LAST_UPDATE_LOGIN
                        ,l_unit_of_measure_tbl(l_ppl_index)                               -- UNIT_OF_MEASURE
                        ,NULL                                                             -- TRACK_AS_LABOR_FLAG
                        ,NULL                                                             -- STANDARD_BILL_RATE
                        ,NULL                                                             -- AVERAGE_BILL_RATE
                        ,NULL                                                             -- AVERAGE_COST_RATE
                        ,-1                                                               -- PROJECT_ASSIGNMENT_ID
                        ,NULL                                                             -- PLAN_ERROR_CODE
                        ,NULL                                                             -- TOTAL_PLAN_REVENUE
                        ,NULL                                                             -- TOTAL_PLAN_RAW_COST
                        ,NULL                                                             -- TOTAL_PLAN_BURDENED_COST
                        ,NULL                                                             -- TOTAL_PLAN_QUANTITY
                        ,NULL                                                             -- AVERAGE_DISCOUNT_PERCENTAGE
                        ,NULL                                                             -- TOTAL_BORROWED_REVENUE
                        ,NULL                                                             -- TOTAL_TP_REVENUE_IN
                        ,NULL                                                             -- TOTAL_TP_REVENUE_OUT
                        ,NULL                                                             -- TOTAL_REVENUE_ADJ
                        ,NULL                                                             -- TOTAL_LENT_RESOURCE_COST
                        ,NULL                                                             -- TOTAL_TP_COST_IN
                        ,NULL                                                             -- TOTAL_TP_COST_OUT
                        ,NULL                                                             -- TOTAL_COST_ADJ
                        ,NULL                                                             -- TOTAL_UNASSIGNED_TIME_COST
                        ,NULL                                                             -- TOTAL_UTILIZATION_PERCENT
                        ,NULL                                                             -- TOTAL_UTILIZATION_HOURS
                        ,NULL                                                             -- TOTAL_UTILIZATION_ADJ
                        ,NULL                                                             -- TOTAL_CAPACITY
                        ,NULL                                                             -- TOTAL_HEAD_COUNT
                        ,NULL                                                             -- TOTAL_HEAD_COUNT_ADJ
                        ,'USER_ENTERED'                                                   -- RESOURCE_ASSIGNMENT_TYPE
                        ,NULL                                                             -- TOTAL_PROJECT_RAW_COST
                        ,NULL                                                             -- TOTAL_PROJECT_BURDENED_COST
                        ,NULL                                                             -- TOTAL_PROJECT_REVENUE
                        ,NULL                                                             -- PARENT_ASSIGNMENT_ID
                        ,l_ins_task_elem_version_id_tbl(i)                                -- WBS_ELEMENT_VERSION_ID
                        ,l_rbs_element_id_tbl(l_ppl_index)                                -- RBS_ELEMENT_ID
                        ,l_ins_start_date_tbl(i)                                          -- PLANNING_START_DATE
                        ,l_ins_end_date_tbl(i)                                            -- PLANNING_END_DATE
                        ,l_ins_start_date_tbl(i)                                          -- SCHEDULE_START_DATE
                        ,l_ins_end_date_tbl(i)                                            -- SCHEDULE_END_DATE
                        ,l_spread_curve_id_tbl(l_ppl_index)                               -- SPREAD_CURVE_ID
                        ,l_etc_method_code_tbl(l_ppl_index)                               -- ETC_METHOD_CODE
                        ,l_res_type_code_tbl(l_ppl_index)                                 -- RES_TYPE_CODE
                        ,NULL                                                             -- ATTRIBUTE_CATEGORY
                        ,NULL                                                             -- ATTRIBUTE1
                        ,NULL                                                             -- ATTRIBUTE2
                        ,NULL                                                             -- ATTRIBUTE3
                        ,NULL                                                             -- ATTRIBUTE4
                        ,NULL                                                             -- ATTRIBUTE5
                        ,NULL                                                             -- ATTRIBUTE6
                        ,NULL                                                             -- ATTRIBUTE7
                        ,NULL                                                             -- ATTRIBUTE8
                        ,NULL                                                             -- ATTRIBUTE9
                        ,NULL                                                             -- ATTRIBUTE10
                        ,NULL                                                             -- ATTRIBUTE11
                        ,NULL                                                             -- ATTRIBUTE12
                        ,NULL                                                             -- ATTRIBUTE13
                        ,NULL                                                             -- ATTRIBUTE14
                        ,NULL                                                             -- ATTRIBUTE15
                        ,NULL                                                             -- ATTRIBUTE16
                        ,NULL                                                             -- ATTRIBUTE17
                        ,NULL                                                             -- ATTRIBUTE18
                        ,NULL                                                             -- ATTRIBUTE19
                        ,NULL                                                             -- ATTRIBUTE20
                        ,NULL                                                             -- ATTRIBUTE21
                        ,NULL                                                             -- ATTRIBUTE22
                        ,NULL                                                             -- ATTRIBUTE23
                        ,NULL                                                             -- ATTRIBUTE24
                        ,NULL                                                             -- ATTRIBUTE25
                        ,NULL                                                             -- ATTRIBUTE26
                        ,NULL                                                             -- ATTRIBUTE27
                        ,NULL                                                             -- ATTRIBUTE28
                        ,NULL                                                             -- ATTRIBUTE29
                        ,NULL                                                             -- ATTRIBUTE30
                        ,l_fc_res_type_code_tbl(l_ppl_index)                              -- FC_RES_TYPE_CODE
                        ,l_resource_class_code_tbl(l_ppl_index)                           -- RESOURCE_CLASS_CODE
                        ,l_organization_id_tbl(l_ppl_index)                               -- ORGANIZATION_ID
                        ,l_job_id_tbl(l_ppl_index)                                        -- JOB_ID
                        ,l_person_id_tbl(l_ppl_index)                                     -- PERSON_ID
                        ,l_expenditure_type_tbl(l_ppl_index)                              -- EXPENDITURE_TYPE
                        ,l_expenditure_category_tbl(l_ppl_index)                          -- EXPENDITURE_CATEGORY
                        ,l_revenue_category_code_tbl(l_ppl_index)                         -- REVENUE_CATEGORY_CODE
                        ,l_event_type_tbl(l_ppl_index)                                    -- EVENT_TYPE
                        ,l_supplier_id_tbl(l_ppl_index)                                   -- SUPPLIER_ID
                        ,l_non_labor_resource_tbl(l_ppl_index)                            -- NON_LABOR_RESOURCE
                        ,l_bom_resource_id_tbl(l_ppl_index)                               -- BOM_RESOURCE_ID
                        ,l_inventory_item_id_tbl(l_ppl_index)                             -- INVENTORY_ITEM_ID
                        ,l_item_category_id_tbl(l_ppl_index)                              -- ITEM_CATEGORY_ID
                        ,1                                                                -- RECORD_VERSION_NUMBER
                        ,NULL                                                             -- BILLABLE_PERCENT
                        ,NULL                                                             -- TRANSACTION_SOURCE_CODE
                        ,l_mfc_cost_type_id_tbl(l_ppl_index)                              -- MFC_COST_TYPE_ID
                        ,NULL                                                             -- PROCURE_RESOURCE_FLAG
                        ,NULL                                                             -- ASSIGNMENT_DESCRIPTION
                        ,l_incurred_by_res_flag_tbl(l_ppl_index)                          -- INCURRED_BY_RES_FLAG
                        ,NULL                                                             -- RATE_JOB_ID
                        ,l_rate_expenditure_type_tbl(l_ppl_index)                         -- RATE_EXPENDITURE_TYPE
                        ,'N'                                                              -- TA_DISPLAY_FLAG
                        ,decode(l_spread_curve_id_tbl(l_ppl_index),l_fixed_date_sp_id,l_ins_start_date_tbl(i),null)-- SP_FIXED_DATE -- Bug 3607061
                        ,l_person_type_code_tbl(l_ppl_index)                              -- PERSON_TYPE_CODE
                        ,l_rate_based_flag_tbl(l_ppl_index)                               -- RATE_BASED_FLAG
                        -- gboomina bug 8586393 - start
                        ,l_use_task_schedule_flag_tbl(i)                                  -- USE_TASK_SCHEDULE_FLAG
                        -- gboomina bug 8586393 - end                                                        -- USE_TASK_SCHEDULE_FLAG
                        ,l_rate_func_curr_code_tbl(l_ppl_index)                           -- RATE_EXP_FUNC_CURR_CODE
                        ,l_org_id_tbl(l_ppl_index)                                        -- RATE_EXPENDITURE_ORG_ID
                        ,l_incur_by_res_class_code_tbl(l_ppl_index)                       -- INCUR_BY_RES_CLASS_CODE
                        ,l_incur_by_role_id_tbl(l_ppl_index)                              -- INCUR_BY_ROLE_ID
                        ,l_project_role_id_tbl(l_ppl_index)                               -- PROJECT_ROLE_ID
                        ,l_resource_class_flag_tbl(l_ppl_index)                           -- RESOURCE_CLASS_FLAG
                        ,l_named_role_tbl(l_ppl_index)                                    -- NAMED_ROLE
                        ,l_txn_accum_header_id_tbl(l_ppl_index)                           -- TXN ACCUM HEADER ID
                        ,l_pm_product_code_tbl(l_ppl_index)                               -- PM_PRODUCT_CODE
                        ,l_pm_res_asgmt_ref_tbl(l_ppl_index)                              -- PM_RES_ASSIGNMENT_REFERENCE
                        ,l_rate_based_flag_tbl(l_ppl_index)                               -- RESOURCE_RATE_BASED_FLAG IPM
			)
                        RETURNING resource_assignment_id BULK COLLECT INTO l_res_assignment_id_temp_tbl ;
    -- IPM changes - copy the RA ID's created so that the new entity
    -- can be populated.
    l_orig_count :=  l_ra_id_temp_tbl.COUNT; -- bug 5003827 issue 22
    l_ra_id_temp_tbl.extend(l_res_assignment_id_temp_tbl.COUNT);
    FOR i IN l_orig_count+1 .. l_orig_count+l_res_assignment_id_temp_tbl.COUNT LOOP -- bug 5003827 issue 22
      l_ra_id_temp_tbl(i) := l_res_assignment_id_temp_tbl(i-l_orig_count); -- bug 5003827 issue 22
    END LOOP; -- bug 5003827 issue 22
    -- hr_utility.trace('RMcopy1');
    -- hr_utility.trace('l_ra_id_temp_tbl.COUNT IS : ' || l_ra_id_temp_tbl.COUNT);
    -- hr_utility.trace('l_res_assignment_id_temp_tbl.COUNT IS : ' || l_res_assignment_id_temp_tbl.COUNT);
    -- hr_utility.trace('*****');

            -----------------------------------------------------------------------
            -- Populating resource assignments and corresponding spread amount flags
            -- in PLSql tables. for IN parameters of Calculate API
            -- If Quantity exists in the IN parameter then set it to 'Y'
            -- or else set it to 'N'
            -----------------------------------------------------------------------
             l_index := 1; -- Initialise to avoid incorrect values that might come in
                           -- due to any usage of this.

             IF (l_res_assignment_id_temp_tbl.COUNT >0) THEN
                FOR k IN l_res_assignment_id_temp_tbl.FIRST .. l_res_assignment_id_temp_tbl.LAST LOOP
                -----------------------------------------------------------------------
                -- Populating resource assignments and corresponding spread amount flags
                -- in PLSql tables.for IN parameters of Calculate API
                -- If Record is inserted then spread amount flag is set to Y or else it
                -- is set to N
                -----------------------------------------------------------------------
                    IF l_res_assignment_id_temp_tbl(k) IS NOT NULL THEN
                        l_trace_stage := 780;
                        --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
                        IF l_debug_mode = 'Y' THEN
                            pa_debug.g_err_stage:='BULK INSERTING DATA - WORPLAN - PEOPLE '||l_res_assignment_id_temp_tbl(k);
                            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                        END IF;
                        l_quantity_tbl(l_index)          := l_ins_cal_people_effort_tbl(k);
                        l_res_assignment_id_tbl(l_index) := l_res_assignment_id_temp_tbl(k);
                        --                                  IF l_spread_amounts_for_ver = 'Y' THEN
                        l_spread_amount_flags_tbl(l_index) := 'Y';
                        l_currency_code_tbl(l_index) :=  l_proj_curr_code;
                        --                                  END IF;
                        IF l_ins_cal_raw_cost_tbl.EXISTS(k) AND
                           NVL(l_ins_cal_raw_cost_tbl(k),FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM AND
                           /* bug fix:Bug fix:5726773 l_ins_cal_raw_cost_tbl(k) <> 0 THEN */
 	                    l_ins_cal_raw_cost_tbl(k) is NOT NULL THEN
                            l_raw_cost_tbl(l_index)     := l_ins_cal_raw_cost_tbl(k);
                        END IF;
                        IF l_ins_cal_burdened_cost_tbl.EXISTS(k) AND
                           NVL(l_ins_cal_burdened_cost_tbl(k),FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM AND
                           /* bug fix:Bug fix:5726773 l_ins_cal_burdened_cost_tbl(k) <> 0 THEN */
 	                    l_ins_cal_burdened_cost_tbl(k) is NOT NULL THEN
                            l_burdened_cost_tbl(l_index)     := l_ins_cal_burdened_cost_tbl(k);
                        END IF;
                        l_call_calc_api := 'Y';
                        l_index := l_index + 1;
                    END IF;
                    l_trace_stage := 790;
                    --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
                END LOOP;
             END IF;
        END IF;
/*  -- Bug 3749516 Removed code below for Equipment resource class Starts refer source control for reference  */
    -- Bug 3749516 BULK INSERT FOR WORKPLAN ENDS HERE

    ----------------------------------------------------------------------------------
    -- Bug 3749516 BULK INSERT FOR B/F and TA starts here
    -----------------------------------------------------------------------------------
    -- Please note that the below FOR Loop has a EXIT condition with respect to the
    -- BUDGET / FORECAST context. When p_one_to_one_mapping_flag is Passed as Y
    -- for BUDGET / FORECAST context we do not have to insert the cartesan product
    -- of element_ver_ids and rlm_ids passed to the ADD_PLANNING_TXNS api.
    -- In this case there is one-to-one correspondance in the records passed for rlm_ids
    -- and elem_ver_ids passed, and we use this data directly for insertion.
    -----------------------------------------------------------------------------------
    ----------------------------------------------------
    -- Loop for all the task_elem_version_id  --- Starts
    ----------------------------------------------------
    ELSIF ((p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK)
        OR (p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET)
        OR (p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FORECAST))  THEN

      -- Resetting value of l_index
      l_index := 1;
      FOR i IN p_task_elem_version_id_tbl.FIRST .. p_task_elem_version_id_tbl.LAST LOOP
        l_trace_stage := 730;
        --    hr_utility.trace('PA_FP_PLAN_TXN_PUB.add_planning_transactions: '||to_char(l_trace_stage));
        --------------------------------------------
        -- for p_context - TASK_ASSIGNMENTS
        --------------------------------------------
        IF p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK THEN
            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='BULK INSERTING DATA - Context TASK p_context : '||p_context;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;
            --dbms_output.put_line('Inserting for TA');
            ---------------------------------------------------------
            -- BULK Inserting records into pa_resource_assignments
            -- by iterating throught elligle resource list member ids
            ---------------------------------------------------------
            -----------------------------------------------------------------
            -- The Insert Statement below has been modified for changes due to
            -- Bug 3665097. When p_one_to_one_mapping_flag is passed as Y for
            -- TA context. The Bulk insert is run once once for the same index as of rlm_ids.
            -- The Exit Condition below takes care of the insert running only once.
            -------------------------------------------------------------------
            FORALL j IN l_eligible_rlm_ids_tbl.FIRST .. l_eligible_rlm_ids_tbl.LAST
                INSERT INTO PA_RESOURCE_ASSIGNMENTS (
                   RESOURCE_ASSIGNMENT_ID,BUDGET_VERSION_ID,PROJECT_ID,TASK_ID,RESOURCE_LIST_MEMBER_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY
                  ,LAST_UPDATE_LOGIN,UNIT_OF_MEASURE,TRACK_AS_LABOR_FLAG,STANDARD_BILL_RATE,AVERAGE_BILL_RATE,AVERAGE_COST_RATE
                  ,PROJECT_ASSIGNMENT_ID,PLAN_ERROR_CODE,TOTAL_PLAN_REVENUE,TOTAL_PLAN_RAW_COST,TOTAL_PLAN_BURDENED_COST,TOTAL_PLAN_QUANTITY
                  ,AVERAGE_DISCOUNT_PERCENTAGE,TOTAL_BORROWED_REVENUE,TOTAL_TP_REVENUE_IN,TOTAL_TP_REVENUE_OUT,TOTAL_REVENUE_ADJ
                  ,TOTAL_LENT_RESOURCE_COST,TOTAL_TP_COST_IN,TOTAL_TP_COST_OUT,TOTAL_COST_ADJ,TOTAL_UNASSIGNED_TIME_COST
                  ,TOTAL_UTILIZATION_PERCENT,TOTAL_UTILIZATION_HOURS,TOTAL_UTILIZATION_ADJ,TOTAL_CAPACITY,TOTAL_HEAD_COUNT
                  ,TOTAL_HEAD_COUNT_ADJ,RESOURCE_ASSIGNMENT_TYPE,TOTAL_PROJECT_RAW_COST,TOTAL_PROJECT_BURDENED_COST,TOTAL_PROJECT_REVENUE
                  ,PARENT_ASSIGNMENT_ID,WBS_ELEMENT_VERSION_ID,RBS_ELEMENT_ID,PLANNING_START_DATE,PLANNING_END_DATE,SCHEDULE_START_DATE,SCHEDULE_END_DATE
                  ,SPREAD_CURVE_ID,ETC_METHOD_CODE,RES_TYPE_CODE,ATTRIBUTE_CATEGORY,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5
                  ,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15
                  ,ATTRIBUTE16,ATTRIBUTE17,ATTRIBUTE18,ATTRIBUTE19,ATTRIBUTE20,ATTRIBUTE21,ATTRIBUTE22,ATTRIBUTE23,ATTRIBUTE24,ATTRIBUTE25
                  ,ATTRIBUTE26,ATTRIBUTE27,ATTRIBUTE28,ATTRIBUTE29,ATTRIBUTE30,FC_RES_TYPE_CODE,RESOURCE_CLASS_CODE,ORGANIZATION_ID,JOB_ID
                  ,PERSON_ID,EXPENDITURE_TYPE,EXPENDITURE_CATEGORY,REVENUE_CATEGORY_CODE,EVENT_TYPE,SUPPLIER_ID,NON_LABOR_RESOURCE
                  ,BOM_RESOURCE_ID,INVENTORY_ITEM_ID,ITEM_CATEGORY_ID,RECORD_VERSION_NUMBER,BILLABLE_PERCENT
                  ,TRANSACTION_SOURCE_CODE,MFC_COST_TYPE_ID,PROCURE_RESOURCE_FLAG,ASSIGNMENT_DESCRIPTION
                  ,INCURRED_BY_RES_FLAG,RATE_JOB_ID,RATE_EXPENDITURE_TYPE,TA_DISPLAY_FLAG
                  ,SP_FIXED_DATE,PERSON_TYPE_CODE,RATE_BASED_FLAG,USE_TASK_SCHEDULE_FLAG,RATE_EXP_FUNC_CURR_CODE
                  ,RATE_EXPENDITURE_ORG_ID,INCUR_BY_RES_CLASS_CODE,INCUR_BY_ROLE_ID
                  ,PROJECT_ROLE_ID,RESOURCE_CLASS_FLAG,NAMED_ROLE,TXN_ACCUM_HEADER_ID,UNPLANNED_FLAG
                  ,PM_PRODUCT_CODE, PM_RES_ASSIGNMENT_REFERENCE,SCHEDULED_DELAY, resource_rate_based_flag)
           VALUES(PA_RESOURCE_ASSIGNMENTS_S.NEXTVAL                        -- RESOURCE_ASSIGNMENT_ID
                  ,l_budget_version_id                                     -- BUDGET_VERSION_ID
                  ,p_project_id                                            -- PROJECT_ID
                  ,decode(p_one_to_one_mapping_flag,'Y',l_proj_elem_rlm_tbl(j)
                                                       ,l_proj_element_id_tbl(i))           -- TASK_ID
                  ,l_eligible_rlm_ids_tbl(j)                               -- RESOURCE_LIST_MEMBER_ID
                  ,sysdate                                                 -- LAST_UPDATE_DATE
                  ,fnd_global.user_id                                      -- LAST_UPDATED_BY
                  ,sysdate                                                 -- CREATION_DATE
                  ,fnd_global.user_id                                      -- CREATED_BY
                  ,fnd_global.login_id                                     -- LAST_UPDATE_LOGIN
                  ,l_unit_of_measure_tbl(j)                                -- UNIT_OF_MEASURE
                  ,NULL                                                    -- TRACK_AS_LABOR_FLAG
                  ,NULL                                                    -- STANDARD_BILL_RATE
                  ,NULL                                                    -- AVERAGE_BILL_RATE
                  ,NULL                                                    -- AVERAGE_COST_RATE
                  ,nvl(l_project_assignment_id_tbl(j),-1)                  -- PROJECT_ASSIGNMENT_ID
                  ,NULL                                          -- PLAN_ERROR_CODE
                  ,NULL                                          -- TOTAL_PLAN_REVENUE
                  ,NULL                                          -- TOTAL_PLAN_RAW_COST
                  ,NULL                                          -- TOTAL_PLAN_BURDENED_COST
                  ,NULL                                          -- TOTAL_PLAN_QUANTITY
                  ,NULL                                          -- AVERAGE_DISCOUNT_PERCENTAGE
                  ,NULL                                          -- TOTAL_BORROWED_REVENUE
                  ,NULL                                          -- TOTAL_TP_REVENUE_IN
                  ,NULL                                          -- TOTAL_TP_REVENUE_OUT
                  ,NULL                                          -- TOTAL_REVENUE_ADJ
                  ,NULL                                          -- TOTAL_LENT_RESOURCE_COST
                  ,NULL                                          -- TOTAL_TP_COST_IN
                  ,NULL                                          -- TOTAL_TP_COST_OUT
                  ,NULL                                          -- TOTAL_COST_ADJ
                  ,NULL                                          -- TOTAL_UNASSIGNED_TIME_COST
                  ,NULL                                          -- TOTAL_UTILIZATION_PERCENT
                  ,NULL                                          -- TOTAL_UTILIZATION_HOURS
                  ,NULL                                          -- TOTAL_UTILIZATION_ADJ
                  ,NULL                                          -- TOTAL_CAPACITY
                  ,NULL                                          -- TOTAL_HEAD_COUNT
                  ,NULL                                          -- TOTAL_HEAD_COUNT_ADJ
                  ,'USER_ENTERED'                                -- RESOURCE_ASSIGNMENT_TYPE
                  ,NULL                                          -- TOTAL_PROJECT_RAW_COST
                  ,NULL                                          -- TOTAL_PROJECT_BURDENED_COST
                  ,NULL                                          -- TOTAL_PROJECT_REVENUE
                  ,NULL                                          -- PARENT_ASSIGNMENT_ID
                  ,decode(p_one_to_one_mapping_flag,'Y',l_task_elem_rlm_tbl(j)
                                                       ,p_task_elem_version_id_tbl(i))      -- WBS_ELEMENT_VERSION_ID
                  ,l_rbs_element_id_tbl(j)                       -- RBS_ELEMENT_ID
                  ,l_planning_start_date_tbl(j)                  -- PLANNING_START_DATE
                  ,l_planning_end_date_tbl(j)                    -- PLANNING_END_DATE
                  ,l_schedule_start_date_tbl(j)                  -- SCHEDULE_START_DATE
                  ,l_schedule_end_date_tbl(j)                    -- SCHEDULE_END_DATE
                  ,l_spread_curve_id_tbl(j)                      -- SPREAD_CURVE_ID
                  ,l_etc_method_code_tbl(j)                      -- ETC_METHOD_CODE
                  ,l_res_type_code_tbl(j)                        -- RES_TYPE_CODE
                  ,l_attribute_category_tbl(j)                   -- ATTRIBUTE_CATEGORY
                  ,l_ATTRIBUTE1_tbl(j)                           -- ATTRIBUTE1
                  ,l_ATTRIBUTE2_tbl(j)                           -- ATTRIBUTE2
                  ,l_ATTRIBUTE3_tbl(j)                           -- ATTRIBUTE3
                  ,l_ATTRIBUTE4_tbl(j)                           -- ATTRIBUTE4
                  ,l_ATTRIBUTE5_tbl(j)                           -- ATTRIBUTE5
                  ,l_ATTRIBUTE6_tbl(j)                           -- ATTRIBUTE6
                  ,l_ATTRIBUTE7_tbl(j)                           -- ATTRIBUTE7
                  ,l_ATTRIBUTE8_tbl(j)                           -- ATTRIBUTE8
                  ,l_ATTRIBUTE9_tbl(j)                           -- ATTRIBUTE9
                  ,l_ATTRIBUTE10_tbl(j)                          -- ATTRIBUTE10
                  ,l_ATTRIBUTE11_tbl(j)                          -- ATTRIBUTE11
                  ,l_ATTRIBUTE12_tbl(j)                          -- ATTRIBUTE12
                  ,l_ATTRIBUTE13_tbl(j)                          -- ATTRIBUTE13
                  ,l_ATTRIBUTE14_tbl(j)                          -- ATTRIBUTE14
                  ,l_ATTRIBUTE15_tbl(j)                          -- ATTRIBUTE15
                  ,l_ATTRIBUTE16_tbl(j)                          -- ATTRIBUTE16
                  ,l_ATTRIBUTE17_tbl(j)                          -- ATTRIBUTE17
                  ,l_ATTRIBUTE18_tbl(j)                          -- ATTRIBUTE18
                  ,l_ATTRIBUTE19_tbl(j)                          -- ATTRIBUTE19
                  ,l_ATTRIBUTE20_tbl(j)                          -- ATTRIBUTE20
                  ,l_ATTRIBUTE21_tbl(j)                          -- ATTRIBUTE21
                  ,l_ATTRIBUTE22_tbl(j)                          -- ATTRIBUTE22
                  ,l_ATTRIBUTE23_tbl(j)                          -- ATTRIBUTE23
                  ,l_ATTRIBUTE24_tbl(j)                          -- ATTRIBUTE24
                  ,l_ATTRIBUTE25_tbl(j)                          -- ATTRIBUTE25
                  ,l_ATTRIBUTE26_tbl(j)                          -- ATTRIBUTE26
                  ,l_ATTRIBUTE27_tbl(j)                          -- ATTRIBUTE27
                  ,l_ATTRIBUTE28_tbl(j)                          -- ATTRIBUTE28
                  ,l_ATTRIBUTE29_tbl(j)                          -- ATTRIBUTE29
                  ,l_ATTRIBUTE30_tbl(j)                          -- ATTRIBUTE30
                  ,l_fc_res_type_code_tbl(j)                     -- FC_RES_TYPE_CODE
                  ,l_resource_class_code_tbl(j)                  -- RESOURCE_CLASS_CODE
                  ,l_organization_id_tbl(j)                      -- ORGANIZATION_ID
                  ,l_job_id_tbl(j)                               -- JOB_ID
                  ,l_person_id_tbl(j)                            -- PERSON_ID
                  ,l_expenditure_type_tbl(j)                     -- EXPENDITURE_TYPE
                  ,l_expenditure_category_tbl(j)                 -- EXPENDITURE_CATEGORY
                  ,l_revenue_category_code_tbl(j)                -- REVENUE_CATEGORY_CODE
                  ,l_event_type_tbl(j)                           -- EVENT_TYPE
                  ,l_supplier_id_tbl(j)                          -- SUPPLIER_ID
                  ,l_non_labor_resource_tbl(j)                   -- NON_LABOR_RESOURCE
                  ,l_bom_resource_id_tbl(j)                      -- BOM_RESOURCE_ID
                  ,l_inventory_item_id_tbl(j)                    -- INVENTORY_ITEM_ID
                  ,l_item_category_id_tbl(j)                     -- ITEM_CATEGORY_ID
                  ,1                                             -- RECORD_VERSION_NUMBER
                  ,l_billable_percent_tbl(j)                     -- BILLABLE_PERCENT
                  ,NULL                                          -- TRANSACTION_SOURCE_CODE
                  ,l_mfc_cost_type_id_tbl(j)                     -- MFC_COST_TYPE_ID
                  ,l_procure_resource_flag_tbl(j)                -- PROCURE_RESOURCE_FLAG
                  ,l_assignment_description_tbl(j)               -- ASSIGNMENT_DESCRIPTION
                  ,l_incurred_by_res_flag_tbl(j)                 -- INCURRED_BY_RES_FLAG
                  ,NULL                                          -- RATE_JOB_ID
                  ,l_rate_expenditure_type_tbl(j)                -- RATE_EXPENDITURE_TYPE
                  ,'Y'                                           -- TA_DISPLAY_FLAG
                  ,decode(l_spread_curve_id_tbl(j),l_fixed_date_sp_id,nvl(l_sp_fixed_date_tbl(j),l_planning_start_date_tbl(j)),null) -- SP_FIXED_DATE -- Bug 3607061
                  ,l_person_type_code_tbl(j)                     -- PERSON_TYPE_CODE
                  ,l_rate_based_flag_tbl(j)                      -- RATE_BASED_FLAG
                  ,l_use_task_schedule_flag_tbl(j)               -- USE_TASK_SCHEDULE_FLAG
                  ,l_rate_func_curr_code_tbl(j)                  -- RATE_EXP_FUNC_CURR_CODE
                  ,l_org_id_tbl(j)                               -- RATE_EXPENDITURE_ORG_ID
                  ,l_incur_by_res_class_code_tbl(j)              -- INCUR_BY_RES_CLASS_CODE
                  ,l_incur_by_role_id_tbl(j)                     -- INCUR_BY_ROLE_ID
                  ,l_project_role_id_tbl(j)                      -- PROJECT_ROLE_ID
                  ,l_resource_class_flag_tbl(j)                  -- RESOURCE_CLASS_FLAG
                  ,l_named_role_tbl(j)                           -- NAMED_ROLE
                  ,l_txn_accum_header_id_tbl(j)                  -- TXN ACCUM HEADER ID
                  ,l_unplanned_flag_tbl(j)                       -- UNPLANNED_FLAG
                  ,l_pm_product_code_tbl(j)                      -- PM_PRODUCT_CODE
                  ,l_pm_res_asgmt_ref_tbl(j)                     -- PM_RES_ASSIGNMENT_REFERENCE
                  ,l_scheduled_delay(j)                          -- SCHEDULED_DELAY. For bug 3948128
		  ,l_rate_based_flag_tbl(j)                      -- resource_RATE_BASED_FLAG
                  )
                   RETURNING resource_assignment_id
		   BULK COLLECT INTO l_res_assignment_id_temp_tbl ;

            -- IPM changes - copy the RA ID's created so that the new entity
            -- can be populated.
            l_orig_count :=  l_ra_id_temp_tbl.COUNT; -- bug 5003827 issue 22
            l_ra_id_temp_tbl.extend(l_res_assignment_id_temp_tbl.COUNT);
            l_curr_code_temp_tbl.extend(l_res_assignment_id_temp_tbl.COUNT);
            FOR i IN l_orig_count+1 .. l_orig_count+l_res_assignment_id_temp_tbl.COUNT LOOP -- bug 5003827 issue 22
              l_ra_id_temp_tbl(i) := l_res_assignment_id_temp_tbl(i-l_orig_count); -- bug 5003827 issue 22
              -- Bug 5003827 issue 1
              IF  p_currency_code_tbl.EXISTS(i-l_orig_count) AND
                   NVL(p_currency_code_tbl(i-l_orig_count),FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
                 l_curr_code_temp_tbl(i) := p_currency_code_tbl(i-l_orig_count);
              ELSE
                 l_curr_code_temp_tbl(i) := l_proj_curr_code;
              END IF;
            END LOOP; -- bug 5003827 issue 22

            -------------------------------------------------------------------------------
            --No of records in rlm id tbl should be equal to the no of records in ra id tb;
            -------------------------------------------------------------------------------

            IF l_res_assignment_id_temp_tbl.COUNT <> l_eligible_rlm_ids_tbl.COUNT THEN
                   IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:='For Budget and Forcast p_context - data mismatch';
                      pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                   END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
            -----------------------------------------------------------------------
            -- Populating resource assignments and corresponding spread amount flags
            -- in PLSql tables. for IN parameters of Calculate API
            -- If Quantity exists in the IN parameter then set it to 'Y'
            -- or else set it to 'N'
            -----------------------------------------------------------------------

            IF ( l_res_assignment_id_temp_tbl.COUNT >0) THEN

                -- Bug 8370812 - Initialize the index l_rollup_index used for l_ra_id_rollup_tbl
                l_rollup_index := 1;

                FOR k IN l_res_assignment_id_temp_tbl.FIRST .. l_res_assignment_id_temp_tbl.LAST LOOP

                    IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:='BULK INSERTING DATA - TASK Setting DATA - raid count : '||l_res_assignment_id_temp_tbl.COUNT;
                        pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                    END IF;

                    -- Bug 8370812 - Moved inside the IF loop
                    -- l_res_assignment_id_tbl(l_index) := l_res_assignment_id_temp_tbl(k);

                    IF (((l_total_quantity_tbl.EXISTS(k)) AND (l_total_quantity_tbl.COUNT > 0))
                       AND ((nvl(l_total_quantity_tbl(k),FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM)
 	                         /* bug fix:Bug fix:5726773 AND (l_total_quantity_tbl(k) <> 0))) OR */
 	                         AND (l_total_quantity_tbl(k) is NOT NULL ))) OR
                       (((p_raw_cost_tbl.EXISTS(k)) AND (p_raw_cost_tbl.COUNT > 0))
                       AND ((nvl(p_raw_cost_tbl(k),FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM)
 	                         /* bug fix:Bug fix:5726773 AND (p_raw_cost_tbl(k) <> 0))) OR */
 	                         AND (p_raw_cost_tbl(k) is NOT NULL))) OR
                       (((p_burdened_cost_tbl.EXISTS(k)) AND (p_burdened_cost_tbl.COUNT > 0))
                       AND ((nvl(p_burdened_cost_tbl(k),FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM)
 	                         /* bug fix:Bug fix:5726773 AND (p_burdened_cost_tbl(k) <> 0))) THEN */
 	                         AND (p_burdened_cost_tbl(k) is NOT NULL))) THEN

                        IF l_debug_mode = 'Y' THEN
                            pa_debug.g_err_stage:='BULK INSERTING DATA - TASK spread amount flag';
                            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                        END IF;

                        -- Bug 8370812
                        l_res_assignment_id_tbl(l_index) := l_res_assignment_id_temp_tbl(k);

                        l_spread_amount_flags_tbl(l_index) := 'Y';
                        l_call_calc_api := 'Y';

                        -- Bug 3861653
                        IF p_currency_code_tbl.EXISTS(k) AND
                           NVL(p_currency_code_tbl(k),FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN

                           l_currency_code_tbl(l_index)     := p_currency_code_tbl(k);
                        ELSE
                           l_currency_code_tbl(l_index)     := l_proj_curr_code;
                        END IF;

                        IF l_total_quantity_tbl.EXISTS(k) AND
                           NVL(l_total_quantity_tbl(k),FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM AND
                           /* bug fix:Bug fix:5726773 l_total_quantity_tbl(k) <> 0 THEN */
 	                   l_total_quantity_tbl(k) is NOT NULL THEN

                           l_quantity_tbl(l_index)     := l_total_quantity_tbl(k);
                        END IF;

                        l_cost_rate_tbl(l_index)         := l_cost_rate_override_tbl(k);
                        l_burden_multiplier_tbl(l_index) := l_burdened_rate_override_tbl(k);

                        IF p_raw_cost_tbl.EXISTS(k) AND
                           NVL(p_raw_cost_tbl(k),FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM AND
                           /* bug fix:Bug fix:5726773 p_raw_cost_tbl(k) <> 0 THEN */
 	                   p_raw_cost_tbl(k) is NOT NULL THEN

                           l_raw_cost_tbl(l_index)     := p_raw_cost_tbl(k);
                        END IF;

                        IF p_burdened_cost_tbl.EXISTS(k) AND
                           NVL(p_burdened_cost_tbl(k),FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM AND
                           /* bug fix:Bug fix:5726773 P_burdened_cost_tbl(k) <> 0 THEN */
 	                   P_burdened_cost_tbl(k) is NOT NULL THEN

                           l_burdened_cost_tbl(l_index)     := p_burdened_cost_tbl(k);
                        END IF;

                        l_index := l_index + 1;
                    -- Bug 8370812 - TAs for which quantity/raw cost/burdened cost is not passed.
                    ELSE
                        l_ra_id_rollup_tbl.extend;
                        l_curr_code_rollup_tbl.extend;
                        l_ra_id_rollup_tbl(l_rollup_index) := l_res_assignment_id_temp_tbl(k);

                        IF p_currency_code_tbl.EXISTS(k) AND
                           NVL(p_currency_code_tbl(k),FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN

                            l_curr_code_rollup_tbl(l_rollup_index)     := p_currency_code_tbl(k);
                        ELSE
                            l_curr_code_rollup_tbl(l_rollup_index)     := l_proj_curr_code;
                        END IF;

                        l_rollup_index := l_rollup_index + 1;
                    END IF;
                END LOOP;
            END IF;
            -- Bug 3665097
            EXIT WHEN p_one_to_one_mapping_flag = 'Y';

        -----------------------------------------------------------
        -- For p_context = BUDGET or FORECAST
        -----------------------------------------------------------
        ELSIF ((p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET) OR
               (p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FORECAST))  THEN

            ---------------------------------------------------------
            -- BULK Inserting records into pa_resource_assignments
            -- by iterating throught elligle resource list member ids
            ---------------------------------------------------------

            ----------------------------------------------------------------
            /* Notes to Dev - These changes are only done for B/F Context.
               If Skip Duplicate Flag is Passed as Y to Add Planning Transaction API then
               if a record already exists in PA_RESOURCE_ASSIGNMENTS for a given Planning
               Element passed then the particular record is to be skipped whcile doing a
               bulk insert into PA_RESOURCE_ASSIGNMENT.
               However If quantity/amounts are passed for the planning elment which has
               been skipped for Insert. Calculate API would still be called for it.

               As of Now Version - 115.122, the usage of p_skip_duplicate_flags is from
               1) Add task and resource page. When Resources are selected to be added as
                  planning elements for multiple tasks. One or Resource Assignments would
                  already exists and Insert in RA table would have to be skipped.
                  But in this case Quantities/Amounts are not passed so Calculate API is
                  not getting called.
               2) Edit Plan Page "Add Another Row" feature.
                  Consider the following input data.
                  1) t1 r1 c1
                  2) t1 r1 c2
                  3) t2 r2 c2
                  4) t3 r3 c2
                  5) t4 r4 c4

                  System State is such that RA Already Exists for
                  1) t1 r1
                  2) t3 r3

                  In this case Only the following RAs will be inserted.
                  1)t2 r2 and
                  3)t4 r4

                  Basically records 1)2) and 4) have to be skipped.
                  However calculate API still Will be called for All the 5 records.
                  This will be taken care by using save exceptions clause in the FORALL Insert below
            */
            ----------------------------------------------------------------

            -----------------------------------------------------------------
            -- The Insert Statement below has been modified for changes due to
            -- Bug 3719918. When p_one_to_one_mapping_flag is passed as Y for
            -- Bugdet/Forecast context. The Bulk insert is run once once for
            -- the same index as of rlm_ids.
            -- The Exit Condition below takes care of the insert running only once.
            -------------------------------------------------------------------

            BEGIN
                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='BULK INSERTING DATA - Context TASK p_context : '||p_context;
                    pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_eligible_rlm_ids_tbl.count  '||l_eligible_rlm_ids_tbl.count;
                    pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_bf_quantity_tbl.count  '||l_bf_quantity_tbl.count;
                    pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_bf_raw_cost_tbl.count  '||l_bf_raw_cost_tbl.count;
                    pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_bf_burdened_cost_tbl.count  '||l_bf_burdened_cost_tbl.count;
                    pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_bf_revenue_tbl.count  '||l_bf_revenue_tbl.count;
                    pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_bf_currency_code_tbl.count  '||l_bf_currency_code_tbl.count;
                    pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_bf_cost_rate_tbl.count  '||l_bf_cost_rate_tbl.count;
                    pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_bf_bill_rate_tbl.count  '||l_bf_bill_rate_tbl.count;
                    pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_bf_burdened_rate_tbl.count  '||l_bf_burdened_rate_tbl.count;
                    pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);


                END IF;


                FORALL j IN l_eligible_rlm_ids_tbl.FIRST .. l_eligible_rlm_ids_tbl.LAST SAVE EXCEPTIONS
                    INSERT INTO PA_RESOURCE_ASSIGNMENTS (
                       RESOURCE_ASSIGNMENT_ID,BUDGET_VERSION_ID,PROJECT_ID,TASK_ID,RESOURCE_LIST_MEMBER_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY
                      ,LAST_UPDATE_LOGIN,UNIT_OF_MEASURE,TRACK_AS_LABOR_FLAG,STANDARD_BILL_RATE,AVERAGE_BILL_RATE,AVERAGE_COST_RATE
                      ,PROJECT_ASSIGNMENT_ID,PLAN_ERROR_CODE,TOTAL_PLAN_REVENUE,TOTAL_PLAN_RAW_COST,TOTAL_PLAN_BURDENED_COST,TOTAL_PLAN_QUANTITY
                      ,AVERAGE_DISCOUNT_PERCENTAGE,TOTAL_BORROWED_REVENUE,TOTAL_TP_REVENUE_IN,TOTAL_TP_REVENUE_OUT,TOTAL_REVENUE_ADJ
                      ,TOTAL_LENT_RESOURCE_COST,TOTAL_TP_COST_IN,TOTAL_TP_COST_OUT,TOTAL_COST_ADJ,TOTAL_UNASSIGNED_TIME_COST
                      ,TOTAL_UTILIZATION_PERCENT,TOTAL_UTILIZATION_HOURS,TOTAL_UTILIZATION_ADJ,TOTAL_CAPACITY,TOTAL_HEAD_COUNT
                      ,TOTAL_HEAD_COUNT_ADJ,RESOURCE_ASSIGNMENT_TYPE,TOTAL_PROJECT_RAW_COST,TOTAL_PROJECT_BURDENED_COST,TOTAL_PROJECT_REVENUE
                      ,PARENT_ASSIGNMENT_ID,WBS_ELEMENT_VERSION_ID,RBS_ELEMENT_ID,PLANNING_START_DATE,PLANNING_END_DATE,SCHEDULE_START_DATE,SCHEDULE_END_DATE
                      ,SPREAD_CURVE_ID,ETC_METHOD_CODE,RES_TYPE_CODE,ATTRIBUTE_CATEGORY,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5
                      ,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15
                      ,ATTRIBUTE16,ATTRIBUTE17,ATTRIBUTE18,ATTRIBUTE19,ATTRIBUTE20,ATTRIBUTE21,ATTRIBUTE22,ATTRIBUTE23,ATTRIBUTE24,ATTRIBUTE25
                      ,ATTRIBUTE26,ATTRIBUTE27,ATTRIBUTE28,ATTRIBUTE29,ATTRIBUTE30,FC_RES_TYPE_CODE,RESOURCE_CLASS_CODE,ORGANIZATION_ID,JOB_ID
                      ,PERSON_ID,EXPENDITURE_TYPE,EXPENDITURE_CATEGORY,REVENUE_CATEGORY_CODE,EVENT_TYPE,SUPPLIER_ID,NON_LABOR_RESOURCE
                      ,BOM_RESOURCE_ID,INVENTORY_ITEM_ID,ITEM_CATEGORY_ID,RECORD_VERSION_NUMBER,BILLABLE_PERCENT
                      ,TRANSACTION_SOURCE_CODE,MFC_COST_TYPE_ID,PROCURE_RESOURCE_FLAG,ASSIGNMENT_DESCRIPTION
                      ,INCURRED_BY_RES_FLAG,RATE_JOB_ID,RATE_EXPENDITURE_TYPE,TA_DISPLAY_FLAG
                      ,SP_FIXED_DATE,PERSON_TYPE_CODE,RATE_BASED_FLAG,USE_TASK_SCHEDULE_FLAG,RATE_EXP_FUNC_CURR_CODE
                      ,RATE_EXPENDITURE_ORG_ID,INCUR_BY_RES_CLASS_CODE,INCUR_BY_ROLE_ID
                      ,PROJECT_ROLE_ID,RESOURCE_CLASS_FLAG,NAMED_ROLE,TXN_ACCUM_HEADER_ID
                      ,PM_PRODUCT_CODE, PM_RES_ASSIGNMENT_REFERENCE, resource_rate_based_flag)
                      VALUES
                    (  pa_resource_assignments_s.nextval  -- RESOURCE_ASSIGNMENT_ID
                      ,l_budget_version_id                -- BUDGET_VERSION_ID
                      ,p_project_id                       -- PROJECT_ID
                      ,decode(p_one_to_one_mapping_flag,'Y',l_bf_proj_elem_tbl(j)
                                                           ,l_proj_element_id_tbl(i))           -- TASK_ID
                      ,l_eligible_rlm_ids_tbl(j)          -- RESOURCE_LIST_MEMBER_ID
                      ,sysdate                            -- LAST_UPDATE_DATE
                      ,fnd_global.user_id                 -- LAST_UPDATED_BY
                      ,sysdate                            -- CREATION_DATE
                      ,fnd_global.user_id                 -- CREATED_BY
                      ,fnd_global.login_id                -- LAST_UPDATE_LOGIN
                      ,l_unit_of_measure_tbl(j)           -- UNIT_OF_MEASURE
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
                      ,NULL                               -- WBS_ELEMENT_VERSION_ID --Bug 3546208
                      ,l_rbs_element_id_tbl(j)            -- RBS_ELEMENT_ID
                      ,decode(p_one_to_one_mapping_flag,'Y',l_bf_start_date_tbl(j)
                                                           ,l_start_date_tbl(i))                -- PLANNING_START_DATE
                      ,decode(p_one_to_one_mapping_flag,'Y',l_bf_compl_date_tbl(j)
                                                           ,l_compl_date_tbl(i))                -- PLANNING_END_DATE
                      ,decode(p_one_to_one_mapping_flag,'Y',l_bf_start_date_tbl(j)
                                                           ,l_start_date_tbl(i))                -- SCHEDULE_START_DATE
                      ,decode(p_one_to_one_mapping_flag,'Y',l_bf_compl_date_tbl(j)
                                                           ,l_compl_date_tbl(i))                -- SCHEDULE_END_DATE
                      ,l_spread_curve_id_tbl(j)           -- SPREAD_CURVE_ID
                      ,l_etc_method_code_tbl(j)           -- ETC_METHOD_CODE
                      ,l_res_type_code_tbl(j)             -- RES_TYPE_CODE
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
                      ,l_fc_res_type_code_tbl(j)          -- FC_RES_TYPE_CODE
                      ,l_resource_class_code_tbl(j)       -- RESOURCE_CLASS_CODE
                      ,l_organization_id_tbl(j)           -- ORGANIZATION_ID
                      ,l_job_id_tbl(j)                    -- JOB_ID
                      ,l_person_id_tbl(j)                 -- PERSON_ID
                      ,l_expenditure_type_tbl(j)          -- EXPENDITURE_TYPE
                      ,l_expenditure_category_tbl(j)      -- EXPENDITURE_CATEGORY
                      ,l_revenue_category_code_tbl(j)     -- REVENUE_CATEGORY_CODE
                      ,l_event_type_tbl(j)                -- EVENT_TYPE
                      ,l_supplier_id_tbl(j)               -- SUPPLIER_ID
                      ,l_non_labor_resource_tbl(j)        -- NON_LABOR_RESOURCE
                      ,l_bom_resource_id_tbl(j)           -- BOM_RESOURCE_ID
                      ,l_inventory_item_id_tbl(j)         -- INVENTORY_ITEM_ID
                      ,l_item_category_id_tbl(j)          -- ITEM_CATEGORY_ID
                      ,1                                  -- RECORD_VERSION_NUMBER
                      ,NULL                               -- BILLABLE_PERCENT
                      ,NULL                               -- TRANSACTION_SOURCE_CODE
                      ,l_mfc_cost_type_id_tbl(j)          -- MFC_COST_TYPE_ID
                      ,NULL                               -- PROCURE_RESOURCE_FLAG
                      ,NULL                               -- ASSIGNMENT_DESCRIPTION
                      ,l_incurred_by_res_flag_tbl(j)      -- INCURRED_BY_RES_FLAG
                      ,NULL                               -- RATE_JOB_ID
                      ,l_rate_expenditure_type_tbl(j)     -- RATE_EXPENDITURE_TYPE
                      ,NULL                               -- TA_DISPLAY_FLAG
                      ,decode(p_one_to_one_mapping_flag,'Y',decode(l_spread_curve_id_tbl(j),l_fixed_date_sp_id,l_bf_start_date_tbl(j),null)
                                                           ,decode(l_spread_curve_id_tbl(j),l_fixed_date_sp_id,l_start_date_tbl(i),null))  -- SP_FIXED_DATE -- Bug 3607061
                      ,l_person_type_code_tbl(j)          -- PERSON_TYPE_CODE
                      ,l_rate_based_flag_tbl(j)           -- RATE_BASED_FLAG
                      ,l_use_task_schedule_flag_tbl(j)    -- USE_TASK_SCHEDULE_FLAG
                      ,l_rate_func_curr_code_tbl(j)       -- RATE_EXP_FUNC_CURR_CODE
                      ,l_org_id_tbl(j)                    -- RATE_EXPENDITURE_ORG_ID
                      ,l_incur_by_res_class_code_tbl(j)   -- INCUR_BY_RES_CLASS_CODE
                      ,l_incur_by_role_id_tbl(j)          -- INCUR_BY_ROLE_ID
                      ,l_project_role_id_tbl(j)           -- PROJECT_ROLE_ID
                      ,l_resource_class_flag_tbl(j)       -- RESOURCE_CLASS_FLAG
                      ,l_named_role_tbl(j)                -- NAMED_ROLE
                      ,l_txn_accum_header_id_tbl(j)       -- TXN ACCUM HEADER ID
                      ,l_pm_product_code_tbl(j)               -- PM_PRODUCT_CODE
                      ,l_pm_res_asgmt_ref_tbl(j)              -- PM_RES_ASSIGNMENT_REFERENCE
		      ,l_rate_based_flag_tbl(j)           -- resource_RATE_BASED_FLAG
                      )
                      RETURNING
                      task_id,
                      resource_list_member_id,
                      resource_assignment_id,
                      l_bf_quantity_tbl(j),
                      l_bf_raw_cost_tbl(j),
                      l_bf_burdened_cost_tbl(j),
                      l_bf_revenue_tbl(j),
                      l_bf_currency_code_tbl(j),
                      l_bf_cost_rate_tbl(j),
                      l_bf_bill_rate_tbl(j),
                      l_bf_burdened_rate_tbl(j)
                      BULK COLLECT INTO
                      l_bf_task_id_tbl,
                      l_bf_rlm_id_tbl,
                      l_bf_ra_id_tbl,
                      l_bf_ins_quantity_tbl,
                      l_bf_ins_raw_cost_tbl,
                      l_bf_ins_burdened_cost_tbl,
                      l_bf_ins_revenue_tbl,
                      l_bf_ins_currency_code_tbl,
                      l_bf_ins_cost_rate_tbl,
                      l_bf_ins_bill_rate_tbl,
                      l_bf_ins_burdened_rate_tbl;

    -- IPM changes - copy the RA ID's created so that the new entity
    -- can be populated.
    l_orig_count :=  l_ra_id_temp_tbl.COUNT; -- bug 5003827 issue 22
    l_ra_id_temp_tbl.extend(l_bf_ra_id_tbl.COUNT);
    l_curr_code_temp_tbl.extend(l_bf_ins_currency_code_tbl.COUNT);
    FOR i IN l_orig_count+1 .. l_orig_count+l_bf_ra_id_tbl.COUNT LOOP -- bug 5003827 issue 22
      l_ra_id_temp_tbl(i) := l_bf_ra_id_tbl(i-l_orig_count); -- bug 5003827 issue 22
      l_curr_code_temp_tbl(i) := l_bf_ins_currency_code_tbl(i-l_orig_count); -- bug 5003827 issue 22
    END LOOP; -- bug 5003827 issue 22

-- hr_utility.trace('after copy 1');
-- hr_utility.trace('l_ra_id_temp_tbl.COUNT IS : ' || l_ra_id_temp_tbl.COUNT);
-- hr_utility.trace('l_bf_ra_id_tbl.COUNT IS : ' || l_bf_ra_id_tbl.COUNT);
-- hr_utility.trace('l_bf_ins_currency_code_tbl(1) IS : ' || l_bf_ins_currency_code_tbl(1));
-- hr_utility.trace('*****');
            EXCEPTION
            WHEN dml_errors THEN

                IF p_skip_duplicates_flag='Y' THEN

                    --If p_one_to_one_mapping_flag is not Y then the amounts will never be passed to this API
                    --Hence we can ignore the pl/sql tbls bulk collected above
                    IF p_one_to_one_mapping_flag='Y' THEN

                        l_index := l_bf_task_id_tbl.count;



                        IF (l_index + SQL%BULK_EXCEPTIONS.COUNT ) <> l_eligible_rlm_ids_tbl.COUNT THEN

                            pa_debug.g_err_stage:='No of inserted records + No. of errored records is not equal to total no. of input records';
                            pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

                            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                                                p_token1         => 'PROCEDURENAME',
                                                p_value1         => 'ADD_PLANNING_TRANSACTIONS',
                                                p_token2         => 'STAGE',
                                                p_value2         => 'Ins Recs + Err Recs <> Total Recs ['||l_index||' , '||SQL%BULK_EXCEPTIONS.COUNT ||' , '||l_eligible_rlm_ids_tbl.COUNT );

                            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                        END IF;

                        l_bf_task_id_tbl.extend(l_rlm_id_no_of_rows-l_bf_task_id_tbl.count);
                        l_bf_rlm_id_tbl.extend(l_rlm_id_no_of_rows-l_bf_rlm_id_tbl.count);
                        l_bf_ra_id_tbl.extend(l_rlm_id_no_of_rows-l_bf_ra_id_tbl.count);
                        l_bf_ins_quantity_tbl.extend(l_rlm_id_no_of_rows-l_bf_ins_quantity_tbl.count);
                        l_bf_ins_currency_code_tbl.extend(l_rlm_id_no_of_rows-l_bf_ins_currency_code_tbl.count);
                        l_bf_ins_raw_cost_tbl.extend(l_rlm_id_no_of_rows-l_bf_ins_raw_cost_tbl.count);
                        l_bf_ins_burdened_cost_tbl.extend(l_rlm_id_no_of_rows-l_bf_ins_burdened_cost_tbl.count);
                        l_bf_ins_revenue_tbl.extend(l_rlm_id_no_of_rows-l_bf_ins_revenue_tbl.count);
                        l_bf_ins_cost_rate_tbl.extend(l_rlm_id_no_of_rows-l_bf_ins_cost_rate_tbl.count);
                        l_bf_ins_bill_rate_tbl.extend(l_rlm_id_no_of_rows-l_bf_ins_bill_rate_tbl.count);
                        l_bf_ins_burdened_rate_tbl.extend(l_rlm_id_no_of_rows-l_bf_ins_burdened_rate_tbl.count);


                        --Even though the above INSERT statement fails for duplicated records, those records should also be
                        --prepared since the calculate API has to be called for those records. This can be done by using
                        --SQL%BULK_EXCEPTIONS through which it is possible to identify the iteration in which the dml has
                        --failed
                        FOR kk IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP


                            l_temp:=SQL%BULK_EXCEPTIONS(kk).ERROR_INDEX;
                            SELECT task_id,
                                   resource_list_member_id,
                                   resource_assignment_id,
                                   l_bf_quantity_tbl(l_temp),
                                   l_bf_raw_cost_tbl(l_temp),
                                   l_bf_burdened_cost_tbl(l_temp),
                                   l_bf_revenue_tbl(l_temp),
                                   l_bf_currency_code_tbl(l_temp),
                                   l_bf_cost_rate_tbl(l_temp),
                                   l_bf_bill_rate_tbl(l_temp),
                                   l_bf_burdened_rate_tbl(l_temp)
                            INTO   l_bf_task_id_tbl(l_index+kk),
                                   l_bf_rlm_id_tbl(l_index+kk),
                                   l_bf_ra_id_tbl(l_index+kk),
                                   l_bf_ins_quantity_tbl(l_index+kk),
                                   l_bf_ins_raw_cost_tbl(l_index+kk),
                                   l_bf_ins_burdened_cost_tbl(l_index+kk),
                                   l_bf_ins_revenue_tbl(l_index+kk),
                                   l_bf_ins_currency_code_tbl(l_index+kk),
                                   l_bf_ins_cost_rate_tbl(l_index+kk),
                                   l_bf_ins_bill_rate_tbl(l_index+kk),
                                   l_bf_ins_burdened_rate_tbl(l_index+kk)
                            FROM   pa_resource_assignments
                            WHERE  project_id=p_project_id
                            AND    budget_version_id=l_budget_version_id
                            AND    task_id =l_bf_proj_elem_tbl(l_temp)
                            AND    resource_list_member_id=l_eligible_rlm_ids_tbl(l_temp)
                            AND    project_assignment_id=-1;


                        END LOOP;

                        --_ins_ tbls are used only for the FORALL Insert above. Copy them back to _bf_ tbls
                        --which are used in processing below
                        l_bf_quantity_tbl       :=    l_bf_ins_quantity_tbl;
                        l_bf_raw_cost_tbl       :=    l_bf_ins_raw_cost_tbl ;
                        l_bf_burdened_cost_tbl  :=    l_bf_ins_burdened_cost_tbl;
                        l_bf_revenue_tbl        :=    l_bf_ins_revenue_tbl ;
                        l_bf_currency_code_tbl  :=    l_bf_ins_currency_code_tbl;
                        l_bf_cost_rate_tbl      :=    l_bf_ins_cost_rate_tbl;
                        l_bf_bill_rate_tbl      :=    l_bf_ins_bill_rate_tbl;
                        l_bf_burdened_rate_tbl  :=    l_bf_ins_burdened_rate_tbl;

    -- IPM changes - copy the RA ID's created so that the new entity
    -- can be populated.
    l_orig_count :=  l_ra_id_temp_tbl.COUNT; -- bug 5003827 issue 22
    l_ra_id_temp_tbl.extend(l_bf_ra_id_tbl.COUNT);
    l_curr_code_temp_tbl.extend(l_bf_ins_currency_code_tbl.COUNT);
    FOR i IN l_orig_count+1 .. l_orig_count+l_bf_ra_id_tbl.COUNT LOOP -- bug 5003827 issue 22
      l_ra_id_temp_tbl(i) := l_bf_ra_id_tbl(i-l_orig_count); -- bug 5003827 issue 22
      l_curr_code_temp_tbl(i) := l_bf_ins_currency_code_tbl(i-l_orig_count); -- bug 5003827 issue 22
    END LOOP; -- bug 5003827 issue 22

-- hr_utility.trace('after copy 2');
-- hr_utility.trace('l_ra_id_temp_tbl.COUNT IS : ' || l_ra_id_temp_tbl.COUNT);
-- hr_utility.trace('l_bf_ra_id_tbl.COUNT IS : ' || l_bf_ra_id_tbl.COUNT);
-- hr_utility.trace('*****');
                    END IF;--IF p_one_to_one_mapping_flag='Y' THEN

                ELSE

                    pa_debug.g_err_stage:='No of duplicates found '||SQL%BULK_EXCEPTIONS.COUNT;
                    pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

                    RAISE;

                END IF;

            END;

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='FLAG 2 '||l_bf_ra_id_tbl.COUNT;
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;

            -------------------------------------------------------------------------------
            --No of records in rlm id tbl should be equal to the no of records in ra id tb;
            -------------------------------------------------------------------------------
            IF l_bf_ra_id_tbl.COUNT <> l_eligible_rlm_ids_tbl.COUNT AND
               (p_skip_duplicates_flag = 'N') THEN

                IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:='INSIDE Bulk Data insert for budget/forecast';
                  pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

                  pa_debug.g_err_stage:='For Budget and Forcast p_context - data mismatch';
                  pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;

            l_index := 1;

            -----------------------------------------------------------------------
            -- Populating resource assignments and corresponding spread amount flags
            -- in PLSql tables. for IN parameters of Calculate API
            -- If Quantity/Raw_Cost/Burdened_Cost exists in the IN parameter then
            -- set it to 'Y'or else set it to 'N'.
            --Calculate API will be called only when p_one_to_one_mapping_flag is Y
            -----------------------------------------------------------------------
            --IF nvl(p_skip_duplicates_flag,'N') = 'N' THEN -- Bug 3836358
            IF p_one_to_one_mapping_flag='Y' THEN

                IF l_bf_ra_id_tbl.COUNT >0 THEN

                    FOR k IN l_bf_ra_id_tbl.FIRST .. l_bf_ra_id_tbl.LAST LOOP

                        l_res_assignment_id_tbl(l_index) := l_bf_ra_id_tbl(k);
                        l_amount_exists :='N';

                        IF l_bf_quantity_tbl.EXISTS(k) AND
                           NVL(l_bf_quantity_tbl(k),FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM  AND
                           /* bug fix:Bug fix:5726773 l_bf_quantity_tbl(k) <> 0 THEN */
 	                   l_bf_quantity_tbl(k) is NOT NULL THEN
                          l_quantity_tbl(l_index)     := l_bf_quantity_tbl(k);
                          l_amount_exists := 'Y';
                        END IF;

                        IF l_bf_raw_cost_tbl.EXISTS(k) AND
                           NVL(l_bf_raw_cost_tbl(k),FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM AND
                           /* bug fix:Bug fix:5726773 l_bf_raw_cost_tbl(k) <> 0 THEN */
 	                   l_bf_raw_cost_tbl(k) is NOT NULL THEN
                          l_raw_cost_tbl(l_index)     := l_bf_raw_cost_tbl(k);
                          l_amount_exists := 'Y';
                        END IF;

                        IF l_bf_burdened_cost_tbl.EXISTS(k) AND
                           NVL(l_bf_burdened_cost_tbl(k),FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM AND
                           /* bug fix:Bug fix:5726773 l_bf_burdened_cost_tbl(k) <> 0 THEN */
 	                   l_bf_burdened_cost_tbl(k) is NOT NULL THEN
                          l_burdened_cost_tbl(l_index)     := l_bf_burdened_cost_tbl(k);
                          l_amount_exists := 'Y';
                        END IF;

                        IF l_bf_revenue_tbl.EXISTS(k) AND
                           NVL(l_bf_revenue_tbl(k),FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM AND
                           /* bug fix:Bug fix:5726773 l_bf_revenue_tbl(k) <> 0 THEN */
 	                   l_bf_revenue_tbl(k) is NOT NULL THEN
                          l_revenue_tbl(l_index)     := l_bf_revenue_tbl(k);
                          l_amount_exists := 'Y';
                        END IF;

                        IF l_amount_exists ='Y' THEN
                            IF l_debug_mode = 'Y' THEN
                               pa_debug.g_err_stage:='Amount exists and preparing the tbls for calc API';
                               pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                            END IF;

                            IF l_bf_currency_code_tbl.EXISTS(k) AND
                               NVL(l_bf_currency_code_tbl(k),FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
                               l_currency_code_tbl(l_index)     := l_bf_currency_code_tbl(k);
                            ELSE

                                IF l_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage:='Currency code not passed when amounts are passed';
                                    pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
                                END IF;
                                --dbms_output.put_line('curr code not passed');
                                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                      p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

                                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                            END IF;


                            IF l_bf_cost_rate_tbl.EXISTS(k) THEN
                              l_cost_rate_tbl(l_index)     := l_bf_cost_rate_tbl(k);
                            END IF;

                            IF l_bf_bill_rate_tbl.EXISTS(k) THEN
                              l_bill_rate_tbl(l_index)     := l_bf_bill_rate_tbl(k);
                            END IF;

                            IF l_bf_burdened_rate_tbl.EXISTS(k) THEN
                              l_burden_multiplier_tbl(l_index)     := l_bf_burdened_rate_tbl(k);
                            END IF;

                            l_call_calc_api := 'Y';
                            l_spread_amount_flags_tbl(l_index) := 'Y';
                            l_index := l_index + 1;

                        END IF;

                    END LOOP;

                END IF;--IF l_bf_ra_id_tbl.COUNT >0 THEN

            END IF;--IF p_one_to_one_mapping_flag='Y' THEN
            -- END IF; -- Bug 3836358

            EXIT WHEN p_one_to_one_mapping_flag = 'Y';
        END IF; -- if condition for p_context
      END LOOP; -- loop for task_element_version_id
    END IF; -- p_context in TA/BF
    ----------------------------------------------------
    -- Loop for all the task_elem_version_id  --- Ends
    ----------------------------------------------------

    /* In create version calculate need not and should not be called... */
    IF NVL(p_calling_module,'-99') <> 'CREATE_VERSION' AND l_index > 1 THEN
        -- Remove the extra records from the input pl/sql tables
        l_res_assignment_id_tbl.delete(l_index,l_res_assignment_id_tbl.count);
        l_delete_budget_lines_tbl.delete(l_index,l_delete_budget_lines_tbl.count);
        l_spread_amount_flags_tbl.delete(l_index,l_spread_amount_flags_tbl.count);
        l_currency_code_tbl.delete(l_index,l_currency_code_tbl.count);
        l_quantity_tbl.delete(l_index,l_quantity_tbl.count);
        l_raw_cost_tbl.delete(l_index,l_raw_cost_tbl.count);
        l_burdened_cost_tbl.delete(l_index,l_burdened_cost_tbl.count);
        l_revenue_tbl.delete(l_index,l_revenue_tbl.count);
        l_cost_rate_tbl.delete(l_index,l_cost_rate_tbl.count);
        l_burden_multiplier_tbl.delete(l_index,l_burden_multiplier_tbl.count);
        l_bill_rate_tbl.delete(l_index,l_bill_rate_tbl.count);
        l_line_start_date_tbl.delete(l_index,l_line_start_date_tbl.count);
        l_line_end_date_tbl.delete(l_index,l_line_end_date_tbl.count);

        IF l_debug_mode = 'Y' THEN
           IF l_res_assignment_id_tbl.COUNT > 0 THEN
              FOR i in l_res_assignment_id_tbl.FIRST .. l_res_assignment_id_tbl.LAST LOOP
                   pa_debug.g_err_stage:='CALCULATE PARAM l_res_assignment_id_tbl :'||l_res_assignment_id_tbl(i);
                   pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

                   pa_debug.g_err_stage:='CALCULATE PARAM l_quantity_tbl :'||l_quantity_tbl(i);
                   pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

                   pa_debug.g_err_stage:='CALCULATE PARAM l_raw_cost_tbl :'||l_raw_cost_tbl(i);
                   pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

                   pa_debug.g_err_stage:='CALCULATE PARAM l_burdened_cost_tbl :'||l_burdened_cost_tbl(i);
                   pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

                   pa_debug.g_err_stage:='CALCULATE PARAM l_revenue_tbl :'||l_revenue_tbl(i);
                   pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

                   pa_debug.g_err_stage:='CALCULATE PARAM l_currency_code_tbl :'||l_currency_code_tbl(i);
                   pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

                   pa_debug.g_err_stage:='CALCULATE PARAM l_cost_rate_tbl :'||l_cost_rate_tbl(i);
                   pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

                   pa_debug.g_err_stage:='CALCULATE PARAM l_burden_multiplier_tbl :'||l_burden_multiplier_tbl(i);
                   pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);

                   pa_debug.g_err_stage:='CALCULATE PARAM l_bill_rate_tbl :'||l_bill_rate_tbl(i);
                   pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
              END LOOP;
           END IF;
        END IF;

        PA_FP_CALC_PLAN_PKG.calculate(
          p_project_id                 =>   p_project_id
         ,p_budget_version_id          =>   l_budget_version_id
         ,p_source_context             =>   PA_FP_CONSTANTS_PKG.G_CALC_API_RESOURCE_CONTEXT
         ,p_resource_assignment_tab    =>   l_res_assignment_id_tbl
         ,p_delete_budget_lines_tab    =>   l_delete_budget_lines_tbl
         -- bug fix:5726773,p_spread_amts_flag_tab       =>   l_spread_amount_flags_tbl
         ,p_txn_currency_code_tab      =>   l_currency_code_tbl -- derive
         -- as told by sanjay ,p_txn_currency_override_tab  =>   l_currency_code_tbl
         ,p_total_qty_tab              =>   l_quantity_tbl -- derive
         ,p_total_raw_cost_tab         =>   l_raw_cost_tbl -- dervie
         ,p_total_burdened_cost_tab    =>   l_burdened_cost_tbl -- dervie
         ,p_total_revenue_tab          =>   l_revenue_tbl -- derive
         ,p_raw_cost_rate_tab          =>   l_cost_rate_tbl -- derive
         ,p_rw_cost_rate_override_tab  =>   l_cost_rate_tbl
         ,p_b_cost_rate_tab            =>   l_burden_multiplier_tbl -- derive
         ,p_b_cost_rate_override_tab   =>   l_burden_multiplier_tbl
         ,p_bill_rate_tab              =>   l_bill_rate_tbl -- derive
         ,p_bill_rate_override_tab     =>   l_bill_rate_tbl
         ,p_line_start_date_tab        =>   l_line_start_date_tbl --PA_PLSQL_DATATYPES.EmptyDateTab
         ,p_line_end_date_tab          =>   l_line_end_date_tbl   --PA_PLSQL_DATATYPES.EmptyDateTab
         ,p_apply_progress_flag        =>   p_apply_progress_flag
         ,p_rollup_required_flag      =>    l_pji_rollup_required --Bug 4200168
         ,x_return_status              =>   l_return_status
         ,x_msg_count                  =>   l_msg_count
         ,x_msg_data                   =>   l_msg_data);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Called API PA_FP_CALC_PLAN_PKG.calculate api returned error';
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

-- Added for bug 4492493, 4548240
        IF (p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN
            AND PA_TASK_ASSIGNMENT_UTILS.Is_Progress_Rollup_Required(p_project_id) = 'Y') OR
           (p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK
            AND pa_task_assignment_utils.g_require_progress_rollup = 'Y') THEN

             PA_PROJ_TASK_STRUC_PUB.PROCESS_WBS_UPDATES_WRP
                ( p_calling_context       => 'ASGMT_PLAN_CHANGE'
                 ,p_project_id              => p_project_id
                 ,p_structure_version_id   => pa_project_structure_utils.get_latest_wp_version(p_project_id)
                 ,p_pub_struc_ver_id      => pa_project_structure_utils.get_latest_wp_version(p_project_id)
                 ,x_return_status              =>   l_return_status
                 ,x_msg_count                  =>   l_msg_count
                 ,x_msg_data                   =>   l_msg_data);

                 pa_task_assignment_utils.g_require_progress_rollup := 'N';


        END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Called API PA_PROJ_TASK_STRUC_PUB.process_wbs_updates_wrp';
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
--End bug 4492493

    END IF;


    -- Bug 8370812 - Fix is done for the TASK_ASSIGNMENTS context.
    IF p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK THEN

        PA_FIN_PLAN_PUB.create_default_plan_txn_rec
            (p_budget_version_id => l_budget_version_id,
             p_calling_module    => 'UPDATE_PLAN_TRANSACTION',
             p_ra_id_tbl         => l_ra_id_rollup_tbl,
             p_curr_code_tbl     => l_curr_code_rollup_tbl,
             x_return_status     => x_return_status,
             x_msg_count         => x_msg_count,
             x_msg_data          => x_msg_data
            );
    ELSE
        -- IPM changes - rollup amounts in new entity
        /* Start of Addition for bug 7161809 */

        PA_FIN_PLAN_PUB.create_default_plan_txn_rec
            (p_budget_version_id => l_budget_version_id,
             p_calling_module    => 'UPDATE_PLAN_TRANSACTION',
             p_ra_id_tbl         => l_ra_id_temp_tbl,
             p_curr_code_tbl     => l_curr_code_temp_tbl,
             p_expenditure_type_tbl => l_direct_expenditure_type_tbl,
             x_return_status     => x_return_status,
             x_msg_count         => x_msg_count,
             x_msg_data          => x_msg_data
            );
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Called API PA_FIN_PLAN_PUB.create_default_plan_txn_rec returned error';
                   pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage, 3);
             END IF;
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;      /* 7161809 */

    -- Call the UTIL API to get the financial plan info l_fp_cols_rec

/*   Commented for bug 7161809
-- hr_utility.trace('p_project_id IS : ' || p_project_id);
-- hr_utility.trace('l_budget_version_id IS : ' || l_budget_version_id);
    pa_fp_gen_amount_utils.get_plan_version_dtls
        (p_project_id         => p_project_id,
         p_budget_version_id  => l_budget_version_id,
         x_fp_cols_rec        => l_fp_cols_rec,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data);

-- hr_utility.trace('x_return_status IS : ' || x_return_status);
-- hr_utility.trace('x_msg_count IS : ' || x_msg_count);
-- hr_utility.trace('x_msg_data IS : ' || x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Called API pa_fp_gen_amount_utils.get_plan_version_dtls returned error';
          pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage, 3);
       END IF;
       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    -- IPM changes - populate tmp table to use for rollup
    delete pa_resource_asgn_curr_tmp;

    IF l_ra_id_temp_tbl.COUNT > 0 THEN
       -- IPM - populate the currency code
       l_curr_code_temp_tbl.extend(l_ra_id_temp_tbl.COUNT);
       FOR j IN l_ra_id_temp_tbl.first .. l_ra_id_temp_tbl.last LOOP
          IF p_context in (PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN,
                           PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK) THEN
             -- Use project currency for workplan
             -- Bug 5003827 Issue 1
             l_curr_code_temp_tbl(j) := nvl(l_curr_code_temp_tbl(j),
                                            l_proj_curr_code);
          ELSE
             l_curr_code_temp_tbl(j) := nvl(l_curr_code_temp_tbl(j),
                                            l_proj_func_curr_code);

          END IF;
       END LOOP;

       FORALL i IN l_ra_id_temp_tbl.first .. l_ra_id_temp_tbl.last
          INSERT INTO pa_resource_asgn_curr_tmp
             (RA_TXN_ID
             ,RESOURCE_ASSIGNMENT_ID
             ,TXN_CURRENCY_CODE
             ,DELETE_FLAG
	     ,TXN_RAW_COST_RATE_OVERRIDE  -- 6839167
	     ,TXN_BURDEN_COST_RATE_OVERRIDE
	     ,TXN_BILL_RATE_OVERRIDE
	     ,expenditure_type --added for EnC
             )
          SELECT pa_resource_asgn_curr_s.nextval
                ,l_ra_id_temp_tbl(i)
                ,l_curr_code_temp_tbl(i)
                ,NULL
                ,prac.TXN_RAW_COST_RATE_OVERRIDE --6839167
                ,prac.TXN_BURDEN_COST_RATE_OVERRIDE
		,prac.TXN_BILL_RATE_OVERRIDE
		,l_direct_expenditure_type_tbl(i)
		 from pa_resource_asgn_curr prac
		 where prac.RESOURCE_ASSIGNMENT_ID=l_ra_id_temp_tbl(i);
    END IF;

    pa_res_asg_currency_pub.maintain_data(
         p_fp_cols_rec                  => l_fp_cols_rec,
         p_calling_module               => 'UPDATE_PLAN_TRANSACTION',
         p_delete_flag                  => 'N',
         p_copy_flag                    => 'N',
         p_src_version_id               => NULL,
         p_copy_mode                    => NULL,
         p_rollup_flag                  => 'Y',
         p_version_level_flag           => 'N',
         p_called_mode                  => 'SELF_SERVICE',
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data
         );

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

             IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Called API pa_res_asg_currency_pub.maintain_data returned error';
                   pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage, 3);
             END IF;
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;   */

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='CALLED THE PA_FP_CALC_PLAN_PKG.CALCULATE API';
        pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
       pa_debug.reset_curr_function;
    END IF;
EXCEPTION

     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
           ROLLBACK TO SAVEPOINT ADD_PLANNING_TRANS_SP;
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
           pa_debug.reset_curr_function;
	END IF;
     WHEN OTHERS THEN

           ROLLBACK TO SAVEPOINT ADD_PLANNING_TRANS_SP;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FP_PLANNING_TRANSACTION_PUB'
                                  ,p_procedure_name  => 'add_planning_transactions');

           IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write('add_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,5);
             pa_debug.reset_curr_function;
	   END IF;
          RAISE;

END add_planning_transactions;


/*This procedure should be called to update planning transactions
  valid values for p_context are 'BUDGET' , 'FORECAST', 'WORKPLAN' and 'TASK_ASSIGNMENT'
*/
/*******************************************************************************************************
As part of Bug 3749516 All References to Equipment Effort or Equip Resource Class has been removed in
PROCEDURE update_planning_transactions.
All _addl_ and p_equip_people_effort_tbl IN parameters have also been removed as they were not being
 used/referred.
********************************************************************************************************/
PROCEDURE update_planning_transactions
(
       p_context                      IN          VARCHAR2
      ,p_calling_context              IN          VARCHAR2 DEFAULT NULL  -- Added for Bug 6856934
      ,p_struct_elem_version_id       IN          Pa_proj_element_versions.element_version_id%TYPE
      ,p_budget_version_id            IN          Pa_budget_versions.budget_version_id%TYPE
      ,p_task_elem_version_id_tbl     IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_task_name_tbl                IN          SYSTEM.PA_VARCHAR2_240_TBL_TYPE
      ,p_task_number_tbl              IN          SYSTEM.PA_VARCHAR2_100_TBL_TYPE
      ,p_start_date_tbl               IN          SYSTEM.PA_DATE_TBL_TYPE
      ,p_end_date_tbl                 IN          SYSTEM.PA_DATE_TBL_TYPE
      ,p_planned_people_effort_tbl    IN          SYSTEM.PA_NUM_TBL_TYPE
--    One pl/sql record in          The         Above tables
      ,p_resource_assignment_id_tbl   IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_resource_list_member_id_tbl  IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_assignment_description_tbl   IN          SYSTEM.PA_VARCHAR2_240_TBL_TYPE
      ,p_project_assignment_id_tbl    IN          SYSTEM.pa_num_tbl_type
      ,p_resource_alias_tbl           IN          SYSTEM.PA_VARCHAR2_80_TBL_TYPE
      ,p_resource_class_flag_tbl      IN          SYSTEM.PA_VARCHAR2_1_TBL_TYPE
      ,p_resource_class_code_tbl      IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE
      ,p_resource_class_id_tbl        IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_res_type_code_tbl            IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE
      ,p_resource_code_tbl            IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE
      ,p_resource_name                IN          SYSTEM.PA_VARCHAR2_240_TBL_TYPE -- bug fix 3461537
      ,p_person_id_tbl                IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_job_id_tbl                   IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_person_type_code             IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE
      ,p_bom_resource_id_tbl          IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_non_labor_resource_tbl       IN          SYSTEM.PA_VARCHAR2_20_TBL_TYPE
      ,p_inventory_item_id_tbl        IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_item_category_id_tbl         IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_project_role_id_tbl          IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_project_role_name_tbl        IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_organization_id_tbl          IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_organization_name_tbl        IN          SYSTEM.PA_VARCHAR2_240_TBL_TYPE
      ,p_fc_res_type_code_tbl         IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE
      ,p_financial_category_code_tbl  IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE
      ,p_expenditure_type_tbl         IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE
      ,p_expenditure_category_tbl     IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE
      ,p_event_type_tbl               IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE
      ,p_revenue_category_code_tbl    IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE
      ,p_supplier_id_tbl              IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_unit_of_measure_tbl          IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE
      ,p_spread_curve_id_tbl          IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_etc_method_code_tbl          IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE
      ,p_mfc_cost_type_id_tbl         IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_procure_resource_flag_tbl    IN          SYSTEM.PA_VARCHAR2_1_TBL_TYPE
      ,p_incurred_by_res_flag_tbl     IN          SYSTEM.PA_VARCHAR2_1_TBL_TYPE
      ,p_incur_by_resource_code_tbl   IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE
      ,p_incur_by_resource_name_tbl   IN          SYSTEM.PA_VARCHAR2_240_TBL_TYPE
      ,p_incur_by_res_class_code_tbl  IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE
      ,p_incur_by_role_id_tbl         IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_use_task_schedule_flag_tbl   IN          SYSTEM.PA_VARCHAR2_1_TBL_TYPE
      ,p_planning_start_date_tbl      IN          SYSTEM.PA_DATE_TBL_TYPE
      ,p_planning_end_date_tbl        IN          SYSTEM.PA_DATE_TBL_TYPE
      ,p_schedule_start_date_tbl      IN          SYSTEM.PA_DATE_TBL_TYPE
      ,p_schedule_end_date_tbl        IN          SYSTEM.PA_DATE_TBL_TYPE
      ,p_quantity_tbl                 IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_currency_code_tbl            IN          SYSTEM.PA_VARCHAR2_15_TBL_TYPE
      ,p_txn_currency_override_tbl    IN          SYSTEM.PA_VARCHAR2_15_TBL_TYPE
      ,p_raw_cost_tbl                 IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_burdened_cost_tbl            IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_revenue_tbl                  IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_cost_rate_tbl                IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_cost_rate_override_tbl       IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_burdened_rate_tbl            IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_burdened_rate_override_tbl   IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_bill_rate_tbl                IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_bill_rate_override_tbl       IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_billable_percent_tbl         IN          SYSTEM.PA_NUM_TBL_TYPE
      ,p_sp_fixed_date_tbl            IN          SYSTEM.PA_DATE_TBL_TYPE
      ,p_named_role_tbl               IN          SYSTEM.PA_VARCHAR2_80_TBL_TYPE
      ,p_financial_category_name_tbl  IN          SYSTEM.PA_VARCHAR2_80_TBL_TYPE
      ,p_supplier_name_tbl            IN          SYSTEM.PA_VARCHAR2_240_TBL_TYPE
      ,p_attribute_category_tbl       IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE
      ,p_attribute1_tbl               IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute2_tbl               IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute3_tbl               IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute4_tbl               IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute5_tbl               IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute6_tbl               IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute7_tbl               IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute8_tbl               IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute9_tbl               IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute10_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute11_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute12_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute13_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute14_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute15_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute16_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute17_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute18_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute19_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute20_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute21_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute22_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute23_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute24_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute25_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute26_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute27_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute28_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute29_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_attribute30_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE
      ,p_apply_progress_flag          IN          VARCHAR2 /* Passed from apply_progress api (sakthi's team) */
      ,p_scheduled_delay              IN          SYSTEM.pa_num_tbl_type --For bug 3948128
      ,p_pji_rollup_required         IN          VARCHAR2  DEFAULT 'Y' /* Bug# 4200168 */
      ,p_upd_cost_amts_too_for_ta_flg IN VARCHAR2 DEFAULT 'N' --Added for bug #4538286
      ,p_distrib_amts                 IN          VARCHAR2  DEFAULT 'Y' -- Bug 5684639.
      ,p_direct_expenditure_type_tbl               IN  SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE() --added for Enc
      ,x_return_status                OUT         NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_msg_data                     OUT         NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_msg_count                    OUT         NOCOPY NUMBER --File.Sql.39 bug 4440895
) IS
      l_return_status                VARCHAR2(2000);
      l_msg_count                    NUMBER := 0;
      l_data                         VARCHAR2(2000);
      l_msg_data                     VARCHAR2(2000);

      l_msg_index_out                NUMBER;
      l_debug_mode                   VARCHAR2(1);
      l_debug_level3                 CONSTANT NUMBER := 3;
      l_debug_level5                 CONSTANT NUMBER := 5;
      l_module_name                  VARCHAR2(100) := 'Update_Planning_Transactions' || 'pa.plsql.pa_fp_planning_transaction_pub';
      l_loop_start                   NUMBER;
      l_loop_end                     NUMBER;

      l_budget_version_id            pa_budget_versions.budget_version_id%TYPE;
      l_project_id                   pa_projects_all.project_id%TYPE;
      l_fixed_date_sp_id             pa_spread_curves_b.spread_curve_id%TYPE; -- bug 3607061
      l_pji_rollup_required         VARCHAR2(1); --Bug 4200168


      /* Start of variables for Variable for TA Validations for p_context = TASK_ASSIGNMENTS
       */
      l_task_rec_tbl                 PA_TASK_ASSIGNMENT_UTILS.l_task_rec_tbl_type;
      l_resource_rec_tbl             PA_TASK_ASSIGNMENT_UTILS.l_resource_rec_tbl_type;
      /* End of variables for Variable for TA Validations for p_context = TASK_ASSIGNMENTS
       */

      /* Start of variables for Variable for Resource Attributes
       */
      l_resource_assignment_id_tbl   SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_resource_list_member_id_tbl  SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_assignment_description_tbl   SYSTEM.PA_VARCHAR2_240_TBL_TYPE   := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
      l_planning_resource_alias_tbl  SYSTEM.PA_VARCHAR2_80_TBL_TYPE    := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
      l_resource_class_flag_tbl      SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
      l_resource_class_code_tbl      SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_resource_class_id_tbl        SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_res_type_code_tbl            SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_resource_code_tbl            SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_person_id_tbl                SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_job_id_tbl                   SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_person_type_code_tbl         SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_bom_resource_id_tbl          SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_non_labor_resource_tbl       SYSTEM.PA_VARCHAR2_20_TBL_TYPE    := SYSTEM.PA_VARCHAR2_20_TBL_TYPE();
      l_inventory_item_id_tbl        SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_item_category_id_tbl         SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_project_role_id_tbl          SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_project_role_name_tbl        SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_organization_id_tbl          SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
   -- bug 3455288, 19-FEB-04, jwhite: Changed varchar2 length to 240 from 30 --------------------------------
   --  l_organization_name_tbl        SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();

       l_organization_name_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE    := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();

   -- End, bug 3455288, 19-FEB-04, jwhite:  ------------------------------------------------------------------
      l_direct_expenditure_type_tbl         SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE(); /*EnC*/
      l_fc_res_type_code_tbl         SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_financial_category_code_tbl  SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_expenditure_type_tbl         SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_expenditure_category_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_event_type_tbl               SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_revenue_category_code_tbl    SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_supplier_id_tbl              SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_unit_of_measure_tbl          SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_spread_curve_id_tbl          SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_etc_method_code_tbl          SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_mfc_cost_type_id_tbl         SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_procure_resource_flag_tbl    SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
      l_incurred_by_res_flag_tbl     SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
      l_incur_by_resource_name_tbl   SYSTEM.PA_VARCHAR2_240_TBL_TYPE   := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
      l_Incur_by_resource_code_tbl   SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_Incur_by_res_class_code_tbl  SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_Incur_by_role_id_tbl         SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_use_task_schedule_flag_tbl   SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
      l_planning_start_date_tbl      SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
      l_planning_end_date_tbl        SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
      l_schedule_start_date_tbl      SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
      l_schedule_end_date_tbl        SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
      l_total_quantity_tbl           SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_override_currency_code_tbl   SYSTEM.PA_VARCHAR2_15_TBL_TYPE    := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
      l_billable_percent_tbl         SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_cost_rate_override_tbl       SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_burdened_rate_override_tbl   SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_sp_fixed_date_tbl            SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
      l_named_role_tbl               SYSTEM.PA_VARCHAR2_80_TBL_TYPE    := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
      l_financial_category_name_tbl  SYSTEM.PA_VARCHAR2_80_TBL_TYPE    := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
      l_supplier_name_tbl            SYSTEM.PA_VARCHAR2_240_TBL_TYPE   := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
      l_wbs_element_version_id_tbl   SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_project_assignment_id_tbl    SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_attribute_category_tbl       SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_attribute1_tbl               SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute2_tbl               SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute3_tbl               SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute4_tbl               SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute5_tbl               SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute6_tbl               SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute7_tbl               SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute8_tbl               SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute9_tbl               SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute10_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute11_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute12_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute13_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute14_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute15_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute16_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute17_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute18_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute19_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute20_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute21_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute22_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute23_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute24_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute25_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute26_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute27_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute28_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute29_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_attribute30_tbl              SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
      l_bill_rate_override_tbl       SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_bill_rate_tbl                SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_b_multiplier_tbl             SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_raw_cost_rate_tbl            SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_revenue_tbl                  SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_burdened_cost_tbl            SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_total_raw_cost_tbl           SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_currency_code_tbl            SYSTEM.PA_VARCHAR2_15_TBL_TYPE    := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
      --For bug 3948128
      l_scheduled_delay              SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();

      -- Added for bug 3698458
      l_rate_exp_org_id_tbl          SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_rate_exp_type_tbl            SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_rate_func_curr_code_tbl      SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_incur_by_res_type_tbl        SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();

      /* End of variables for Variable for Resource Attributes
       */
      l_spread_amt_flag_tbl          SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
      l_delete_budget_lines_tbl      SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
      l_currency_code_tmp_tbl        SYSTEM.PA_VARCHAR2_15_TBL_TYPE    := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
      l_existing_curr_code           pa_budget_lines.txn_currency_code%TYPE;
      l_projfunc_currency_code       pa_budget_lines.txn_currency_code%TYPE;
      l_projfunc_currency_code_out   pa_budget_lines.txn_currency_code%TYPE;
      l_rbs_element_id_tbl           SYSTEM.pa_num_tbl_type;
      l_txn_accum_header_id_tbl      SYSTEM.pa_num_tbl_type :=SYSTEM.pa_num_tbl_type();

      /* added for bug 3678814 */
      l_rate_based_flag_tbl          SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();

      l_trace_stage NUMBER;

      -- Added for bug 3817356
      l_in_start_date_tbl            SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
      l_in_end_date_tbl              SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
      l_in_planning_start_date_tbl   SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
      l_in_planning_end_date_tbl     SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
      l_in_schedule_start_date_tbl   SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
      l_in_schedule_end_date_tbl     SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
      l_in_sp_fixed_date_tbl         SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
      l_temp_gmiss_date              date := to_date('01-01-4712','DD-MM-YYYY');

      --These parameters are introduced for calculate API enhancements tracked thru bug 4152749
      l_mfc_cost_type_id_old_tbl     SYSTEM.PA_NUM_TBL_TYPE            :=  SYSTEM.PA_NUM_TBL_TYPE();
      l_mfc_cost_type_id_new_tbl     SYSTEM.PA_NUM_TBL_TYPE            :=  SYSTEM.PA_NUM_TBL_TYPE();
      l_spread_curve_id_old_tbl      SYSTEM.PA_NUM_TBL_TYPE            :=  SYSTEM.PA_NUM_TBL_TYPE();
      l_spread_curve_id_new_tbl      SYSTEM.PA_NUM_TBL_TYPE            :=  SYSTEM.PA_NUM_TBL_TYPE();
      l_sp_fixed_date_old_tbl        SYSTEM.PA_DATE_TBL_TYPE           :=  SYSTEM.PA_DATE_TBL_TYPE();
      l_sp_fixed_date_new_tbl        SYSTEM.PA_DATE_TBL_TYPE           :=  SYSTEM.PA_DATE_TBL_TYPE();
      l_plan_start_date_old_tbl      SYSTEM.PA_DATE_TBL_TYPE           :=  SYSTEM.PA_DATE_TBL_TYPE();
      l_plan_start_date_new_tbl      SYSTEM.PA_DATE_TBL_TYPE           :=  SYSTEM.PA_DATE_TBL_TYPE();
      l_plan_end_date_old_tbl        SYSTEM.PA_DATE_TBL_TYPE           :=  SYSTEM.PA_DATE_TBL_TYPE();
      l_plan_end_date_new_tbl        SYSTEM.PA_DATE_TBL_TYPE           :=  SYSTEM.PA_DATE_TBL_TYPE();
      l_rlm_id_change_flag_tbl       SYSTEM.PA_VARCHAR2_1_TBL_TYPE     :=  SYSTEM.PA_VARCHAR2_1_TBL_TYPE();

      --Added for Bug 4200168
      l_g_miss_char   CONSTANT      VARCHAR(1)  := FND_API.G_MISS_CHAR;
      l_g_miss_num    CONSTANT      NUMBER      := FND_API.G_MISS_NUM;
      l_g_miss_date   CONSTANT      DATE        := FND_API.G_MISS_DATE;

      l_fp_cols_rec   pa_fp_gen_amount_utils.fp_cols; -- IPM

      -- Bug 5906826
      l_ra_id_tbl                    SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_line_start_date_tbl          SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
      l_line_end_date_tbl            SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
      l_txn_currency_code_tbl        SYSTEM.PA_VARCHAR2_15_TBL_TYPE    := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
      l_tot_qty_tbl                  SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_txn_raw_cost_tbl             SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_txn_burdened_cost_tbl        SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
      l_cal_api_called_flg           VARCHAR2(1)                       := 'N';

BEGIN

l_trace_stage := 10;
--hr_utility.trace('PA_FP_PLAN_TXN_PUB.update_planning_transactions: '||to_char(l_trace_stage));


      x_msg_count     := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_debug_mode    := 'Y'; --NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

--Added for Bug 4200168
      IF p_pji_rollup_required = 'Y' THEN
          l_pji_rollup_required := 'Y';
      ELSE
          l_pji_rollup_required := 'N';
      END IF;

      pa_task_assignment_utils.g_require_progress_rollup := 'N';

      IF l_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function   => 'Update_Planning_Transactions',
                                        p_debug_mode => l_debug_mode );
      END IF;
      --dbms_output.put_line('In upd planning txn');


      /* A savepoint is set
       */
       SAVEPOINT   Update_Planning_Transactions;

       IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := 'Checking for required parameters';
             print_msg(pa_debug.g_err_stage,l_module_name);
       END IF;

      /* Check for required parameters
       */

       IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := 'Extending the local pl/sql tables: p_context =>' ||p_context;
             print_msg(pa_debug.g_err_stage,l_module_name);
       END IF;



       IF p_context IS NULL OR
          p_context NOT IN ( PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FORECAST
                            ,PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN
                            ,PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK
                            ,PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET ) THEN

            pa_debug.g_err_stage := 'The Context IN parameter is NULL';
            pa_debug.write(l_module_name, pa_debug.g_err_stage,l_debug_level5);
            --dbms_output.put_line('p_context is null');

            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;
       --dbms_output.put_line('U01');

       IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Checking for required parameters';
            print_msg(pa_debug.g_err_stage,l_module_name);
       END IF;


      /* Check for business rules violations
       */
       IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Validating input parameters';
            print_msg(pa_debug.g_err_stage,l_module_name);
       END IF;

l_trace_stage := 50;
--hr_utility.trace('PA_FP_PLAN_TXN_PUB.update_planning_transactions: '||to_char(l_trace_stage));


       /* If the calling Context is Workplan or Task Assignment, the element version Id can't be null
        */
       IF p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN OR p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK THEN
            IF p_struct_elem_version_id IS NULL THEN
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'p_struct_elem_version_id is null';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  --dbms_output.put_line('p_struct_elem_version_id is null');

                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            ELSE
                  l_budget_version_id := PA_PLANNING_TRANSACTION_UTILS.Get_wp_budget_version_id(p_struct_elem_version_id);
                  IF l_budget_version_id IS NULL THEN
                      IF l_debug_mode = 'Y' THEN
                             pa_debug.g_err_stage:='Calling add plan txn to create the version';
                             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                      END IF;

                      BEGIN
                          SELECT project_id
                          INTO   l_project_id
                          FROM   pa_struct_task_wbs_v
                          WHERE  parent_Structure_version_id=p_struct_elem_version_id
                          AND    ROWNUM=1;
                      EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                          IF l_debug_mode = 'Y' THEN
                                 pa_debug.g_err_stage:='Invalid value for p_struct_elem_version_id';
                                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                          END IF;
                          --dbms_output.put_line('Invalid value for p_struct_elem_version_id');
                          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                               p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
                          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                      END;



                      pa_fp_planning_transaction_pub.add_planning_transactions
                      (p_context                =>'WORKPLAN'
                      ,p_calling_context        => p_calling_context   -- Added for Bug 6856934
                      ,p_project_id             => l_project_id
                      ,p_struct_elem_version_id => p_struct_elem_version_id
                      ,x_return_status          => l_return_status
                      ,x_msg_data               => l_msg_data
                      ,x_msg_count              => l_msg_count);
                      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                               IF l_debug_mode = 'Y' THEN
                                     pa_debug.g_err_stage:='Called API pa_fp_planning_transaction_pub.add_planning_transaction api returned error';
                                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                               END IF;
                               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                      END IF;
                      l_budget_version_id := PA_PLANNING_TRANSACTION_UTILS.Get_wp_budget_version_id(p_struct_elem_version_id);
                  END IF;

            END IF;
       /* If the calling Context is BUDGET or FORECAST, the budget version Id can't be null
        */
       ELSIF p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET OR p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FORECAST THEN
            IF p_budget_version_id IS NULL THEN
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'p_budget_version_id is null';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  --dbms_output.put_line('p_budget_version_id is null');
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            ELSE
                  l_budget_version_id := p_budget_version_id;
            END IF;
       END IF;
       --dbms_output.put_line('U1');
l_trace_stage := 100;
--hr_utility.trace('PA_FP_PLAN_TXN_PUB.update_planning_transactions: '||to_char(l_trace_stage));


       /* Validation Done
        */
       /* Getting the project id for the corresponding budget version
        */
       BEGIN
             SELECT    project_id
             INTO      l_project_id
             FROM      pa_budget_versions
             WHERE     budget_version_id = l_budget_version_id;
       EXCEPTION
             WHEN OTHERS THEN
                  IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:='Select failed on pa_budget_versions.';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  RAISE;
       END;

       /* Bug 3817356 - We to cannot pass negative date from Java to PLSql hence we are not
          able to pass FND_API.G_MISS_DATE ('01-Jan--4712') to this API when called from Java.
          Instead when this API is called from Java instead of G_MISS_DATE '01-Jan-4712' is passed.
          Added code below to Replace '01-Jan-4712' by FND_API.G_MISS_DATE
       */
       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Processing IN Date Tables for G_MISS_DATE';
           pa_debug.write('PA_FP_PLANNING_TXN_PUB.update_planning_transactions:'||l_module_name,pa_debug.g_err_stage,3);
       END IF;

       l_in_start_date_tbl          := p_start_date_tbl;
       l_in_end_date_tbl            := p_end_date_tbl;
       l_in_planning_start_date_tbl := p_planning_start_date_tbl;
       l_in_planning_end_date_tbl   := p_planning_end_date_tbl;
       l_in_schedule_start_date_tbl := p_schedule_start_date_tbl;
       l_in_schedule_end_date_tbl   := p_schedule_end_date_tbl;
       l_in_sp_fixed_date_tbl       := p_sp_fixed_date_tbl;
       l_direct_expenditure_type_tbl :=p_direct_expenditure_type_tbl;
       -- Please note that the l_in_ tables will be reference instead of p_ tables in Code Flow
       IF p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN THEN
         IF p_task_elem_version_id_tbl.COUNT > 0 THEN
           FOR i IN p_task_elem_version_id_tbl.FIRST .. p_task_elem_version_id_tbl.LAST LOOP
                 IF p_start_date_tbl.EXISTS(i)
                    AND p_start_date_tbl(i) = l_temp_gmiss_date THEN
                    l_in_start_date_tbl(i) := FND_API.G_MISS_DATE;
                 END IF;
                 IF p_end_date_tbl.EXISTS(i)
                    AND p_end_date_tbl(i) = l_temp_gmiss_date THEN
                    l_in_end_date_tbl(i) := FND_API.G_MISS_DATE;
                 END IF;
                 IF p_planning_start_date_tbl.EXISTS(i)
                    AND p_planning_start_date_tbl(i) = l_temp_gmiss_date THEN
                    l_in_planning_start_date_tbl(i) := FND_API.G_MISS_DATE;
                 END IF;
                 IF p_planning_end_date_tbl.EXISTS(i)
                    AND p_planning_end_date_tbl(i) = l_temp_gmiss_date THEN
                    l_in_planning_end_date_tbl(i) := FND_API.G_MISS_DATE;
                 END IF;
                 IF p_schedule_start_date_tbl.EXISTS(i)
                    AND p_schedule_start_date_tbl(i) = l_temp_gmiss_date THEN
                    l_in_schedule_start_date_tbl(i) := FND_API.G_MISS_DATE;
                 END IF;
                 IF p_schedule_end_date_tbl.EXISTS(i)
                    AND p_schedule_end_date_tbl(i) = l_temp_gmiss_date THEN
                    l_in_schedule_end_date_tbl(i) := FND_API.G_MISS_DATE;
                 END IF;
                 IF p_sp_fixed_date_tbl.EXISTS(i)
                    AND p_sp_fixed_date_tbl(i) = l_temp_gmiss_date THEN
                    l_in_sp_fixed_date_tbl(i) := FND_API.G_MISS_DATE;
                 END IF;
           END LOOP;
         END IF;
       ELSE
         IF p_resource_assignment_id_tbl.COUNT > 0 THEN
           FOR i IN p_resource_assignment_id_tbl.FIRST .. p_resource_assignment_id_tbl.LAST LOOP
                 IF p_start_date_tbl.EXISTS(i)
                    AND p_start_date_tbl(i) = l_temp_gmiss_date THEN
                    l_in_start_date_tbl(i) := FND_API.G_MISS_DATE;
                 END IF;
                 IF p_end_date_tbl.EXISTS(i)
                    AND p_end_date_tbl(i) = l_temp_gmiss_date THEN
                    l_in_end_date_tbl(i) := FND_API.G_MISS_DATE;
                 END IF;
                 IF p_planning_start_date_tbl.EXISTS(i)
                    AND p_planning_start_date_tbl(i) = l_temp_gmiss_date THEN
                    l_in_planning_start_date_tbl(i) := FND_API.G_MISS_DATE;
                 END IF;
                 IF p_planning_end_date_tbl.EXISTS(i)
                    AND p_planning_end_date_tbl(i) = l_temp_gmiss_date THEN
                    l_in_planning_end_date_tbl(i) := FND_API.G_MISS_DATE;
                 END IF;
                 IF p_schedule_start_date_tbl.EXISTS(i)
                    AND p_schedule_start_date_tbl(i) = l_temp_gmiss_date THEN
                    l_in_schedule_start_date_tbl(i) := FND_API.G_MISS_DATE;
                 END IF;
                 IF p_schedule_end_date_tbl.EXISTS(i)
                    AND p_schedule_end_date_tbl(i) = l_temp_gmiss_date THEN
                    l_in_schedule_end_date_tbl(i) := FND_API.G_MISS_DATE;
                 END IF;
                 IF p_sp_fixed_date_tbl.EXISTS(i)
                    AND p_sp_fixed_date_tbl(i) = l_temp_gmiss_date THEN
                    l_in_sp_fixed_date_tbl(i) := FND_API.G_MISS_DATE;
                 END IF;
           END LOOP;
         END IF;
       END IF;


       /* If the calling context is workplan, then checking, if the passed task info is present or not
        * If not present, the called procedure would insert it.
        */
       --dbms_output.put_line ('pq1 is '||p_planned_people_effort_tbl(1));
       IF p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN THEN
             check_and_create_task_rec_info
             ( p_project_id                 => l_project_id
              ,p_struct_elem_version_id     => p_struct_elem_version_id
              ,p_element_version_id_tbl     => p_task_elem_version_id_tbl
              ,p_planning_start_date_tbl    => l_in_start_date_tbl -- 3817356
              ,p_planning_end_date_tbl      => l_in_end_date_tbl -- 3817356
              ,p_planned_people_effort_tbl  => p_planned_people_effort_tbl
              ,p_raw_cost_tbl               => p_raw_cost_tbl
              ,p_burdened_cost_tbl          => p_burdened_cost_tbl
              ,p_apply_progress_flag        => p_apply_progress_flag
              ,x_element_version_id_tbl     => l_wbs_element_version_id_tbl
              ,x_planning_start_date_tbl    => l_planning_start_date_tbl
              ,x_planning_end_date_tbl      => l_planning_end_date_tbl
              ,x_planned_effort_tbl         => l_total_quantity_tbl
              ,x_resource_assignment_id_tbl => l_resource_assignment_id_tbl
              ,x_raw_cost_tbl               => l_total_raw_cost_tbl
              ,x_burdened_cost_tbl          => l_burdened_cost_tbl
              ,x_return_status              => l_return_status
              ,x_msg_data                   => l_msg_data
              ,x_msg_count                  => l_msg_count);

             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:='Called API pa_planning_transaction_pub.check_and_create_task_rec_info api returned error';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                   END IF;
                   RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
             END IF;
             --dbms_output.put_line ('pq1 is '||l_total_quantity_tbl(1));
l_trace_stage := 150;
--hr_utility.trace('PA_FP_PLAN_TXN_PUB.update_planning_transactions: '||to_char(l_trace_stage));


             /* If l ra id tbl count is zero, it means, the check_and_create_task_rec_info
                has called add plan tran api with effort and hence no more prorcessing is required.
              */
             IF l_resource_assignment_id_tbl.COUNT = 0 THEN
                   IF l_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:='No Data Returned from the api-----Returning';
                          print_msg(pa_debug.g_err_stage,l_module_name);
                   END IF;
                   --dbms_output.put_line('No Data Returned from the api-----Returning');
                   IF l_debug_mode = 'Y' THEN
                          pa_debug.reset_curr_function;
                   END IF;
                   RETURN;
             END IF;

             /* For WP, the sch dates and planning dates are always in synch */

             l_schedule_start_date_tbl := l_planning_start_Date_tbl;
             l_schedule_end_date_tbl   := l_planning_end_Date_tbl;

       ELSE
             /* The context is of not work plan type
              */
             --dbms_output.put_line('U3');
             IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Non Workplan type context';
                   print_msg(pa_debug.g_err_stage,l_module_name);
             END IF;
             IF p_resource_assignment_id_tbl.COUNT =0 THEN
                   IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:='Resource Assignment Id table is empty---- Returning';
                        print_msg(pa_debug.g_err_stage,l_module_name);
                   END IF;
                   IF l_debug_mode = 'Y' THEN
                        pa_debug.reset_curr_function;
                   END IF;
                   --dbms_output.put_line('Empty ra id tbl returning');
                   RETURN;
             ELSE
                  -- 3817356 Replacing p_xxxx_date_tbls by l_in_xxxx_date_tbls
                  l_resource_assignment_id_tbl := p_resource_assignment_id_tbl;
                  IF p_context in (PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET,PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FORECAST) THEN
                       /* Budgets and forecasts case schedule start/end dates,
                        * though not relevant are always kept in synch with planning start and end
                        * dates */
                       l_schedule_start_date_tbl    := l_in_planning_start_date_tbl;
                       l_schedule_end_date_tbl      := l_in_planning_end_date_tbl;
                       l_planning_start_date_tbl    := l_in_planning_start_date_tbl;
                       l_planning_end_date_tbl      := l_in_planning_end_date_tbl;
                  ELSE /* Context is TA */
                       l_planning_start_date_tbl    := l_in_planning_start_date_tbl;
                       l_planning_end_date_tbl      := l_in_planning_end_date_tbl;
                       l_schedule_start_date_tbl    := l_in_schedule_start_date_tbl;
                       l_schedule_end_date_tbl      := l_in_schedule_end_date_tbl;
                  END IF;
                  l_total_quantity_tbl         := p_quantity_tbl;
                  --In the context of BUDGET or FORECAST throw an error if the p_currency_code_tbl does not
                  --have same no of elements as that p_resource_assignment_id_tbl
                  IF p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET OR p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FORECAST THEN
                      IF p_resource_assignment_id_tbl.COUNT <> p_currency_code_tbl.COUNT THEN
                            IF l_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage:='the contents of p_currency_code_tbl not equal in number to contents in res assmt tbl';
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                            END IF;
                            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                 p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
                            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                      END IF;
                  END IF;
             END IF;
       END IF;
       -- End for calling Context of workplan

-- Fetching spread curve id for fixed date spread curve : Bug 3607061 - Starts
    BEGIN
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Fetching spread curve id for fixed date spread curve';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
        END IF;
        Select spread_curve_id
          into l_fixed_date_sp_id
          from pa_spread_curves_b
         where spread_curve_code = 'FIXED_DATE';

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Fetching spread curve id l_fixed_date_sp_id:'||l_fixed_date_sp_id;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Fixed date spread curve not found in system';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
             END IF;
             RAISE;
    END;
-- Fetching spread curve id for fixed date spread curve : Bug 3607061 - Ends

       --Extend all the local pl/sql tables.
       IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := 'Extending the local pl/sql tables';
             print_msg(pa_debug.g_err_stage,l_module_name);
       END IF;

       l_trace_stage := 200;
       --hr_utility.trace('PA_FP_PLAN_TXN_PUB.update_planning_transactions: '||to_char(l_trace_stage));

       l_resource_list_member_id_tbl.extend(l_resource_assignment_id_tbl.last);

       l_trace_stage := 201;
       --hr_uility.trace('PA_FP_PLAN_TXN_PUB.update_planning_transactions: '||to_char(l_trace_stage));

       --dbms_output.put_line('2');
       l_assignment_description_tbl.extend(l_resource_assignment_id_tbl.last);
       l_planning_resource_alias_tbl.extend(l_resource_assignment_id_tbl.last);
       l_resource_class_flag_tbl.extend(l_resource_assignment_id_tbl.last);
       l_resource_class_code_tbl.extend(l_resource_assignment_id_tbl.last);
       l_resource_class_id_tbl.extend(l_resource_assignment_id_tbl.last);
       l_res_type_code_tbl.extend(l_resource_assignment_id_tbl.last);
       l_resource_code_tbl.extend(l_resource_assignment_id_tbl.last);
       l_person_id_tbl.extend(l_resource_assignment_id_tbl.last);
       l_job_id_tbl.extend(l_resource_assignment_id_tbl.last);

       l_person_type_code_tbl.extend(l_resource_assignment_id_tbl.last);
       l_bom_resource_id_tbl.extend(l_resource_assignment_id_tbl.last);
       l_non_labor_resource_tbl.extend(l_resource_assignment_id_tbl.last);
       l_inventory_item_id_tbl.extend(l_resource_assignment_id_tbl.last);
       l_item_category_id_tbl.extend(l_resource_assignment_id_tbl.last);
       l_project_role_id_tbl.extend(l_resource_assignment_id_tbl.last);
       l_project_role_name_tbl.extend(l_resource_assignment_id_tbl.last);
       l_organization_id_tbl.extend(l_resource_assignment_id_tbl.last);
       l_organization_name_tbl.extend(l_resource_assignment_id_tbl.last);
       l_fc_res_type_code_tbl.extend(l_resource_assignment_id_tbl.last);
       l_financial_category_code_tbl.extend(l_resource_assignment_id_tbl.last);
       l_expenditure_type_tbl.extend(l_resource_assignment_id_tbl.last);
       l_expenditure_category_tbl.extend(l_resource_assignment_id_tbl.last);

       -- Added for bug 3698458
       l_rate_exp_org_id_tbl.extend(l_resource_assignment_id_tbl.last);
       l_rate_exp_type_tbl.extend(l_resource_assignment_id_tbl.last);
       l_rate_func_curr_code_tbl.extend(l_resource_assignment_id_tbl.last);
       l_incur_by_res_type_tbl.extend(l_resource_assignment_id_tbl.last);

       -- Added for bug 3678814
       l_rate_based_flag_tbl.extend(l_resource_assignment_id_tbl.last);

       l_trace_stage := 210;
       --hr_utility.trace('PA_FP_PLAN_TXN_PUB.update_planning_transactions: '||to_char(l_trace_stage));

       l_event_type_tbl.extend(l_resource_assignment_id_tbl.last);
       l_revenue_category_code_tbl.extend(l_resource_assignment_id_tbl.last);
       l_supplier_id_tbl.extend(l_resource_assignment_id_tbl.last);
       l_unit_of_measure_tbl.extend(l_resource_assignment_id_tbl.last);
       l_spread_curve_id_tbl.extend(l_resource_assignment_id_tbl.last);
       l_etc_method_code_tbl.extend(l_resource_assignment_id_tbl.last);
       l_mfc_cost_type_id_tbl.extend(l_resource_assignment_id_tbl.last);
       l_procure_resource_flag_tbl.extend(l_resource_assignment_id_tbl.last);
       l_incurred_by_res_flag_tbl.extend(l_resource_assignment_id_tbl.last);
       l_incur_by_resource_name_tbl.extend(l_resource_assignment_id_tbl.last);
       l_Incur_by_resource_code_tbl.extend(l_resource_assignment_id_tbl.last);
       l_Incur_by_res_class_code_tbl.extend(l_resource_assignment_id_tbl.last);
       l_Incur_by_role_id_tbl.extend(l_resource_assignment_id_tbl.last);
       l_use_task_schedule_flag_tbl.extend(l_resource_assignment_id_tbl.last);
       IF l_planning_start_date_tbl.COUNT <> l_resource_assignment_id_tbl.COUNT THEN
           l_planning_start_date_tbl.extend(l_resource_assignment_id_tbl.last-l_planning_start_date_tbl.COUNT);
       END IF;
       IF l_planning_end_date_tbl.COUNT<> l_resource_assignment_id_tbl.COUNT THEN
           l_planning_end_date_tbl.extend(l_resource_assignment_id_tbl.last-l_planning_end_date_tbl.COUNT);
       END IF;
       IF l_schedule_start_date_tbl.COUNT <> l_resource_assignment_id_tbl.COUNT THEN
           l_schedule_start_date_tbl.extend(l_resource_assignment_id_tbl.last-l_schedule_start_date_tbl.COUNT);
       END IF;
       IF l_schedule_end_date_tbl.COUNT<> l_resource_assignment_id_tbl.COUNT THEN
           l_schedule_end_date_tbl.extend(l_resource_assignment_id_tbl.last-l_schedule_end_date_tbl.COUNT);
       END IF;
       IF l_total_quantity_tbl.COUNT<>l_resource_assignment_id_tbl.COUNT THEN
           l_total_quantity_tbl.extend(l_resource_assignment_id_tbl.last-l_total_quantity_tbl.COUNT);
       END IF;
       IF l_burdened_cost_tbl.COUNT<>l_resource_assignment_id_tbl.COUNT THEN
          l_burdened_cost_tbl.extend(l_resource_assignment_id_tbl.last);
       END IF;
       IF l_total_raw_cost_tbl.COUNT<>l_resource_assignment_id_tbl.COUNT THEN
          l_total_raw_cost_tbl.extend(l_resource_assignment_id_tbl.last);
       END IF;
--dbms_output.put_line('l_total_quantity_tbl.last '||l_total_quantity_tbl.last||' l_total_quantity_tbl(1) '||l_total_quantity_tbl(1));
       l_override_currency_code_tbl.extend(l_resource_assignment_id_tbl.last);

l_trace_stage := 220;
--hr_utility.trace('PA_FP_PLAN_TXN_PUB.update_planning_transactions: '||to_char(l_trace_stage));

       l_billable_percent_tbl.extend(l_resource_assignment_id_tbl.last);
       l_cost_rate_override_tbl.extend(l_resource_assignment_id_tbl.last);
       l_burdened_rate_override_tbl.extend(l_resource_assignment_id_tbl.last);
       l_sp_fixed_date_tbl.extend(l_resource_assignment_id_tbl.last);
       l_named_role_tbl.extend(l_resource_assignment_id_tbl.last);
       l_financial_category_name_tbl.extend(l_resource_assignment_id_tbl.last);
       l_supplier_name_tbl.extend(l_resource_assignment_id_tbl.last);
       l_wbs_element_version_id_tbl.extend(l_resource_assignment_id_tbl.last);
       l_project_assignment_id_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute_category_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute1_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute2_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute3_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute4_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute5_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute6_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute7_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute8_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute9_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute10_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute11_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute12_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute13_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute14_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute15_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute16_tbl.extend(l_resource_assignment_id_tbl.last);
l_trace_stage := 230;
--hr_utility.trace('PA_FP_PLAN_TXN_PUB.update_planning_transactions: '||to_char(l_trace_stage));


       l_attribute17_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute18_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute19_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute20_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute21_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute22_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute23_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute24_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute25_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute26_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute27_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute28_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute29_tbl.extend(l_resource_assignment_id_tbl.last);
       l_attribute30_tbl.extend(l_resource_assignment_id_tbl.last);
       l_bill_rate_override_tbl.extend(l_resource_assignment_id_tbl.last);
       l_bill_rate_tbl.extend(l_resource_assignment_id_tbl.last);
       l_b_multiplier_tbl.extend(l_resource_assignment_id_tbl.last);
       l_raw_cost_rate_tbl.extend(l_resource_assignment_id_tbl.last);
       l_revenue_tbl.extend(l_resource_assignment_id_tbl.last);

       l_currency_code_tbl.extend(l_resource_assignment_id_tbl.last);

       --For Bug 3948128.
       l_scheduled_delay.extend(l_resource_assignment_id_tbl.last);
l_trace_stage := 240;
--hr_utility.trace('PA_FP_PLAN_TXN_PUB.update_planning_transactions: '||to_char(l_trace_stage));


       -- Assiging all the passed tbls to  record type . This is done because
       --        1. TA validation API expects a pl/sql table of records
       --        2. BULK update will possible since the values that are not passed will be defaulted to FND_API.G_MISS_XXX


        IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='About to loop thru for assigning to rec types';
              print_msg(pa_debug.g_err_stage,l_module_name);
        END IF;


        FOR i IN l_resource_assignment_id_tbl.FIRST .. l_resource_assignment_id_tbl.LAST LOOP


              IF l_resource_assignment_id_tbl.EXISTS(i) THEN
                    l_resource_rec_tbl(i).resource_assignment_id := l_resource_assignment_id_tbl(i);
              END IF;

              IF p_assignment_description_tbl.EXISTS(i) THEN
                    l_resource_rec_tbl(i).assignment_description := p_assignment_description_tbl(i);
              END IF;
              IF p_resource_list_member_id_tbl.EXISTS(i) THEN
                  l_resource_rec_tbl(i).resource_list_member_id := p_resource_list_member_id_tbl(i);
              END IF;
              IF p_project_assignment_id_tbl.EXISTS(i) THEN
                  l_resource_rec_tbl(i).project_assignment_id := p_project_assignment_id_tbl(i);
              END IF;
              IF p_resource_alias_tbl.EXISTS(i) THEN
                    l_resource_rec_tbl(i).planning_resource_alias := p_resource_alias_tbl(i);
              END IF;
              IF p_resource_class_flag_tbl.EXISTS(i) THEN
                    l_resource_rec_tbl(i).resource_class_flag := p_resource_class_flag_tbl(i);
              END IF;
              IF p_resource_class_code_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).resource_class_code := p_resource_class_code_tbl(i);
              END IF;
              IF p_resource_class_id_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).resource_class_id := p_resource_class_id_tbl(i);
              END IF;
              IF p_res_type_code_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).res_type_code := p_res_type_code_tbl(i);
              END IF;
              IF p_resource_code_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).resource_code := p_resource_code_tbl(i);
              END IF;
              IF p_resource_name.EXISTS(i) THEN
                    l_resource_rec_tbl(i).resource_name := p_resource_name(i);
              END IF;

l_trace_stage := 250;
--hr_utility.trace('PA_FP_PLAN_TXN_PUB.update_planning_transactions: '||to_char(l_trace_stage));

              IF p_person_id_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).person_id := p_person_id_tbl(i);
              END IF;
              IF p_job_id_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).job_id := p_job_id_tbl(i);
              END IF;
              IF p_person_type_code.EXISTS(i) THEN
                   l_resource_rec_tbl(i).person_type_code := p_person_type_code(i);
              END IF;
              IF p_bom_resource_id_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).bom_resource_id := p_bom_resource_id_tbl(i);
              END IF;
              IF p_non_labor_resource_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).non_labor_resource := p_non_labor_resource_tbl(i);
              END IF;
              IF p_inventory_item_id_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).inventory_item_id := p_inventory_item_id_tbl(i);
              END IF;
              IF p_item_category_id_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).item_category_id := p_item_category_id_tbl(i);
              END IF;
              IF p_project_role_id_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).project_role_id := p_project_role_id_tbl(i);
              END IF;
              IF p_project_role_name_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).project_role_name := p_project_role_name_tbl(i);
              END IF;
              IF p_organization_id_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).organization_id := p_organization_id_tbl(i);
              END IF;
l_trace_stage := 251;
--hr_utility.trace('PA_FP_PLAN_TXN_PUB.update_planning_transactions: '||to_char(l_trace_stage));


              IF p_organization_name_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).organization_name := p_organization_name_tbl(i);
              END IF;
              IF p_fc_res_type_code_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).fc_res_type_code := p_fc_res_type_code_tbl(i);
              END IF;

l_trace_stage := 2511;
--hr_utility.trace('PA_FP_PLAN_TXN_PUB.update_planning_transactions: '||to_char(l_trace_stage));

              IF p_financial_category_code_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).financial_category_code := p_financial_category_code_tbl(i);
              END IF;

l_trace_stage := 2512;
--hr_utility.trace('PA_FP_PLAN_TXN_PUB.update_planning_transactions: '||to_char(l_trace_stage));

              IF p_expenditure_type_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).expenditure_type := p_expenditure_type_tbl(i);
              END IF;
l_trace_stage := 2513;
--hr_utility.trace('PA_FP_PLAN_TXN_PUB.update_planning_transactions: '||to_char(l_trace_stage));

              IF p_expenditure_category_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).expenditure_category := p_expenditure_category_tbl(i);
              END IF;
l_trace_stage := 2514;
--hr_utility.trace('PA_FP_PLAN_TXN_PUB.update_planning_transactions: '||to_char(l_trace_stage));

              IF p_event_type_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).event_type := p_event_type_tbl(i);
              END IF;
l_trace_stage := 2515;
--hr_utility.trace('PA_FP_PLAN_TXN_PUB.update_planning_transactions: '||to_char(l_trace_stage));

              IF p_revenue_category_code_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).revenue_category_code := p_revenue_category_code_tbl(i);
              END IF;
l_trace_stage := 252;
--hr_utility.trace('PA_FP_PLAN_TXN_PUB.update_planning_transactions: '||to_char(l_trace_stage));

              IF p_supplier_id_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).supplier_id := p_supplier_id_tbl(i);
              END IF;
              IF p_unit_of_measure_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).unit_of_measure := p_unit_of_measure_tbl(i);
              END IF;
              IF p_spread_curve_id_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).spread_curve_id := p_spread_curve_id_tbl(i);
              END IF;
              IF p_etc_method_code_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).etc_method_code := p_etc_method_code_tbl(i);
              END IF;
              IF p_mfc_cost_type_id_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).mfc_cost_type_id := p_mfc_cost_type_id_tbl(i);
              END IF;
l_trace_stage := 253;
--hr_utility.trace('PA_FP_PLAN_TXN_PUB.update_planning_transactions: '||to_char(l_trace_stage));


              IF p_procure_resource_flag_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).procure_resource_flag := p_procure_resource_flag_tbl(i);
              END IF;
              IF p_incurred_by_res_flag_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).incurred_by_res_flag := p_incurred_by_res_flag_tbl(i);
              END IF;
              IF p_incur_by_resource_code_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).incur_by_resource_code := p_incur_by_resource_code_tbl(i);
              END IF;
              IF p_incur_by_resource_name_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).incur_by_resource_name := p_incur_by_resource_name_tbl(i);
              END IF;
              IF p_Incur_by_res_class_code_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).Incur_by_res_class_code := p_Incur_by_res_class_code_tbl(i);
              END IF;
              IF p_Incur_by_role_id_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).Incur_by_role_id := p_Incur_by_role_id_tbl(i);
              END IF;
              IF p_use_task_schedule_flag_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).use_task_schedule_flag := p_use_task_schedule_flag_tbl(i);
              END IF;
              IF l_planning_start_date_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).planning_start_date := l_planning_start_date_tbl(i);
              END IF;
              IF l_planning_end_date_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).planning_end_date := l_planning_end_date_tbl(i);
              END IF;
              IF l_schedule_start_date_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).schedule_start_date := l_schedule_start_date_tbl(i);
              END IF;
              IF l_schedule_end_date_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).schedule_end_date := l_schedule_end_date_tbl(i);
              END IF;

              l_trace_stage := 254;
              --hr_utility.trace('PA_FP_PLAN_TXN_PUB.update_planning_transactions: '||to_char(l_trace_stage));

              IF l_total_quantity_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).total_quantity := l_total_quantity_tbl(i);
              END IF;
              IF p_txn_currency_override_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).override_currency_code := p_txn_currency_override_tbl(i);
              END IF;
              IF p_billable_percent_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).billable_percent := p_billable_percent_tbl(i);
              END IF;
              IF p_cost_rate_override_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).cost_rate_override := p_cost_rate_override_tbl(i);
              END IF;
              IF p_burdened_rate_override_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).burdened_rate_override := p_burdened_rate_override_tbl(i);
              END IF;
              -- 3817356 Replacing p_xxxx_date_tbls by l_in_xxxx_date_tbls
              IF l_in_sp_fixed_date_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).sp_fixed_date := l_in_sp_fixed_date_tbl(i);
              END IF;
              IF p_financial_category_name_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).financial_category_name := p_financial_category_name_tbl(i);
              END IF;
              IF p_named_role_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).named_role := p_named_role_tbl(i);
              END IF;
              IF p_supplier_name_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).supplier_name := p_supplier_name_tbl(i);
              END IF;
l_trace_stage := 260;
--hr_utility.trace('PA_FP_PLAN_TXN_PUB.update_planning_transactions: '||to_char(l_trace_stage));


              --Select the element version id for each ra id
              SELECT wbs_element_version_id
              INTO   l_resource_rec_tbl(i).wbs_element_version_id
              FROM   pa_resource_assignments
              WHERE  resource_assignment_id = l_resource_assignment_id_tbl(i);

              IF p_attribute_category_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute_category := p_attribute_category_tbl(i);
              END IF;
              IF p_attribute1_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute1 := p_attribute1_tbl(i);
              END IF;
              IF p_attribute2_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute2 := p_attribute2_tbl(i);
              END IF;
              IF p_attribute3_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute3 := p_attribute3_tbl(i);
              END IF;
              IF p_attribute4_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute4 := p_attribute4_tbl(i);
              END IF;
              IF p_attribute5_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute5 := p_attribute5_tbl(i);
              END IF;
              IF p_attribute6_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute6 := p_attribute6_tbl(i);
              END IF;
              IF p_attribute7_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute7 := p_attribute7_tbl(i);
              END IF;

              IF p_attribute8_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute8 := p_attribute8_tbl(i);
              END IF;
              IF p_attribute9_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute9 := p_attribute9_tbl(i);
              END IF;
              IF p_attribute10_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute10 := p_attribute10_tbl(i);
              END IF;
              IF p_attribute11_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute11 := p_attribute11_tbl(i);
              END IF;
              IF p_attribute12_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute12 := p_attribute12_tbl(i);
              END IF;
              IF p_attribute13_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute13 := p_attribute13_tbl(i);
              END IF;
              IF p_attribute14_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute14 := p_attribute14_tbl(i);
              END IF;
              IF p_attribute15_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute15 := p_attribute15_tbl(i);
              END IF;
              IF p_attribute16_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute16 := p_attribute16_tbl(i);
              END IF;
              IF p_attribute17_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute17 := p_attribute17_tbl(i);
              END IF;
              IF p_attribute18_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute18 := p_attribute18_tbl(i);
              END IF;
              IF p_attribute19_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute19 := p_attribute19_tbl(i);
              END IF;
              IF p_attribute20_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute20 := p_attribute20_tbl(i);
              END IF;
              IF p_attribute21_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute21 := p_attribute21_tbl(i);
              END IF;
              IF p_attribute22_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute22 := p_attribute22_tbl(i);
              END IF;
              IF p_attribute23_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute23 := p_attribute23_tbl(i);
              END IF;
              IF p_attribute24_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute24 := p_attribute24_tbl(i);
              END IF;
              IF p_attribute25_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute25 := p_attribute25_tbl(i);
              END IF;
              IF p_attribute26_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute26 := p_attribute26_tbl(i);
              END IF;
              IF p_attribute27_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute27 := p_attribute27_tbl(i);
              END IF;
              IF p_attribute28_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute28 := p_attribute28_tbl(i);
              END IF;
              IF p_attribute29_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute29 := p_attribute29_tbl(i);
              END IF;
              IF p_attribute30_tbl.EXISTS(i) THEN
                   l_resource_rec_tbl(i).attribute30 := p_attribute30_tbl(i);
              END IF;

              --For bug 3948128
              IF p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK AND p_scheduled_delay.EXISTS(i) THEN
                  l_resource_rec_tbl(i).scheduled_delay := p_scheduled_delay(i);
              END IF;
        END LOOP;

l_trace_stage := 2500;
--hr_utility.trace('PA_FP_PLAN_TXN_PUB.update_planning_transactions: '||to_char(l_trace_stage));

       --dbms_output.put_line('3');
        IF p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK THEN
             /*-------------------------------------------------
               Calling Task validation API
               -------------------------------------------------*/
             IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Calling API pa_task_assignment_utils.Validate_Update_Assignment';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                  l_debug_level3);
             END IF;

--hr_utility.trace('PA_FP_PLAN_TXN_PUB.update_planning_transactions: before calling validate_update_assignment');

--dbms_output.put_line(' l_resource_rec_tbl(i).cost_rate_override is '|| l_resource_rec_tbl(1).cost_rate_override);
             PA_TASK_ASSIGNMENT_UTILS.Validate_Update_Assignment(
               p_calling_context              => p_calling_context,   -- Added for Bug 6856934
               p_task_assignment_tbl          => l_resource_rec_tbl,
               x_return_status                => l_return_status);
--dbms_output.put_line(' l_resource_rec_tbl(i).cost_rate_override is '|| l_resource_rec_tbl(1).cost_rate_override);

--hr_utility.trace('PA_FP_PLAN_TXN_PUB.update_planning_transactions: after calling validate_update_assignment');

             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:='Called API PA_TASK_ASSIGNMENT_UTILS.Validate_Update_Assignment returned error';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                   END IF;
                   RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
             END IF;

             --If the rec tbl returned by validate API does not contain records then return
             IF l_resource_rec_tbl.COUNT=0 THEN
                   IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:='Validate API returned 0 records';
                         print_msg(pa_debug.g_err_stage,l_module_name);
                         pa_debug.reset_curr_function;
		   END IF;
                   RETURN;
             END IF;



        END IF;


        /*------------------------------------------------------------------------
        -- Repopulating all the resource data tables from the table l_resource_rec_tbl
        -- Now all the parameters not passed will be initialized to FND_API.G_MISS_XXX
        ------------------------------------------------------------------------ */
        FOR i IN l_resource_rec_tbl.FIRST .. l_resource_rec_tbl.LAST LOOP

             IF l_resource_rec_tbl.EXISTS(i) THEN
                  --dbms_output.put_line('E1');

                    l_resource_assignment_id_tbl(i) := l_resource_rec_tbl(i).resource_assignment_id;
                    l_resource_list_member_id_tbl(i):= l_resource_rec_tbl(i).resource_list_member_id;
                    l_assignment_description_tbl(i) := l_resource_rec_tbl(i).assignment_description;
                    l_planning_resource_alias_tbl(i):= l_resource_rec_tbl(i).planning_resource_alias;
                    l_resource_class_flag_tbl(i)    := l_resource_rec_tbl(i).resource_class_flag;
                    l_resource_class_code_tbl(i)    := l_resource_rec_tbl(i).resource_class_code;
                    l_resource_class_id_tbl(i)      := l_resource_rec_tbl(i).resource_class_id;
                    -- Added for bug 3698458
                    l_rate_exp_org_id_tbl(i)        := l_resource_rec_tbl(i).org_id;
                    l_rate_exp_type_tbl(i)          := l_resource_rec_tbl(i).rate_expenditure_type;
                    l_rate_func_curr_code_tbl(i)    := l_resource_rec_tbl(i).rate_func_curr_code;
                    l_incur_by_res_type_tbl(i)      := l_resource_rec_tbl(i).incur_by_res_type;
                    l_incurred_by_res_flag_tbl(i)   := l_resource_rec_tbl(i).incurred_by_res_flag;
                    l_res_type_code_tbl(i)          := l_resource_rec_tbl(i).res_type_code;

                    IF  l_incurred_by_res_flag_tbl.EXISTS(i) AND nvl(l_incurred_by_res_flag_tbl(i),'N') = 'Y' THEN
                        IF l_incur_by_res_type_tbl.EXISTS(i) THEN
                           l_res_type_code_tbl(i) := l_incur_by_res_type_tbl(i);
                        ELSE
                           l_res_type_code_tbl(i) := NULL;
                        END IF;
                    END IF;

                    -- The following if-else clause has been added for bug 3678814
                    IF  p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK THEN
                        l_rate_based_flag_tbl(i)    :=  l_resource_rec_tbl(i).rate_based_flag;
                    ELSE
                        l_rate_based_flag_tbl(i)    :=  null;
                    END If;

                    l_resource_code_tbl(i)          := l_resource_rec_tbl(i).resource_code;
                    l_person_id_tbl(i)              := l_resource_rec_tbl(i).person_id;
                    l_job_id_tbl(i)                 := l_resource_rec_tbl(i).job_id;
                    l_person_type_code_tbl(i)       := l_resource_rec_tbl(i).person_type_code;
                    l_bom_resource_id_tbl(i)        := l_resource_rec_tbl(i).bom_resource_id;
                    l_non_labor_resource_tbl(i)     := l_resource_rec_tbl(i).non_labor_resource;
                    l_inventory_item_id_tbl(i)      := l_resource_rec_tbl(i).inventory_item_id;

                    l_item_category_id_tbl(i)       := l_resource_rec_tbl(i).item_category_id;
                    l_project_role_id_tbl(i)        := l_resource_rec_tbl(i).project_role_id;
                    l_project_role_name_tbl(i)      := l_resource_rec_tbl(i).project_role_name;
                    l_organization_id_tbl(i)        := l_resource_rec_tbl(i).organization_id;
                    l_organization_name_tbl(i)      := l_resource_rec_tbl(i).organization_name;
                    l_fc_res_type_code_tbl(i)       := l_resource_rec_tbl(i).fc_res_type_code;
                    l_financial_category_code_tbl(i):= l_resource_rec_tbl(i).financial_category_code;
                    l_expenditure_type_tbl(i)       := l_resource_rec_tbl(i).expenditure_type;
                    l_expenditure_category_tbl(i)   := l_resource_rec_tbl(i).expenditure_category;
                    l_event_type_tbl(i)             := l_resource_rec_tbl(i).event_type;
                    l_revenue_category_code_tbl(i)  := l_resource_rec_tbl(i).revenue_category_code;
                    l_supplier_id_tbl(i)            := l_resource_rec_tbl(i).supplier_id;
                    l_unit_of_measure_tbl(i)        := l_resource_rec_tbl(i).unit_of_measure;
                    l_spread_curve_id_tbl(i)        := l_resource_rec_tbl(i).spread_curve_id;
                    l_etc_method_code_tbl(i)        := l_resource_rec_tbl(i).etc_method_code;
                    l_mfc_cost_type_id_tbl(i)       := l_resource_rec_tbl(i).mfc_cost_type_id;
                    l_procure_resource_flag_tbl(i)  := l_resource_rec_tbl(i).procure_resource_flag;
                    l_incur_by_resource_code_tbl(i) := l_resource_rec_tbl(i).incur_by_resource_code;
                    l_incur_by_resource_name_tbl(i) := l_resource_rec_tbl(i).incur_by_resource_name;
                    l_Incur_by_res_class_code_tbl(i):= l_resource_rec_tbl(i).Incur_by_res_class_code;
                    l_Incur_by_role_id_tbl(i)       := l_resource_rec_tbl(i).Incur_by_role_id;
                    l_use_task_schedule_flag_tbl(i) := l_resource_rec_tbl(i).use_task_schedule_flag;
                    l_planning_start_date_tbl(i)    := l_resource_rec_tbl(i).planning_start_date;
                    l_planning_end_date_tbl(i)      := l_resource_rec_tbl(i).planning_end_date;
                    l_schedule_start_date_tbl(i)    := l_resource_rec_tbl(i).schedule_start_date;
                    l_schedule_end_date_tbl(i)      := l_resource_rec_tbl(i).schedule_end_date;
                    l_total_quantity_tbl(i)         := l_resource_rec_tbl(i).total_quantity;
                    l_override_currency_code_tbl(i) := l_resource_rec_tbl(i).override_currency_code;
                    l_billable_percent_tbl(i)       := l_resource_rec_tbl(i).billable_percent;
                    l_cost_rate_override_tbl(i)     := l_resource_rec_tbl(i).cost_rate_override;
                    l_burdened_rate_override_tbl(i) := l_resource_rec_tbl(i).burdened_rate_override;
                    l_sp_fixed_date_tbl(i)          := l_resource_rec_tbl(i).sp_fixed_date;
                    l_named_role_tbl(i)             := l_resource_rec_tbl(i).named_role;
                    l_financial_category_name_tbl(i):= l_resource_rec_tbl(i).financial_category_name;
                    l_supplier_name_tbl(i)          := l_resource_rec_tbl(i).supplier_name;
                    l_wbs_element_version_id_tbl(i) := l_resource_rec_tbl(i).wbs_element_version_id;
                    l_project_assignment_id_tbl(i)  := l_resource_rec_tbl(i).project_assignment_id;
                    l_attribute_category_tbl(i)     := l_resource_rec_tbl(i).ATTRIBUTE_CATEGORY;
                    l_attribute1_tbl(i)             := l_resource_rec_tbl(i).ATTRIBUTE1;
                    l_attribute2_tbl(i)             := l_resource_rec_tbl(i).ATTRIBUTE2;
                    l_attribute3_tbl(i)             := l_resource_rec_tbl(i).ATTRIBUTE3;
                    l_attribute4_tbl(i)             := l_resource_rec_tbl(i).ATTRIBUTE4;
                    l_attribute5_tbl(i)             := l_resource_rec_tbl(i).ATTRIBUTE5;
                    l_attribute6_tbl(i)             := l_resource_rec_tbl(i).ATTRIBUTE6;

                    l_attribute7_tbl(i)             := l_resource_rec_tbl(i).ATTRIBUTE7;
                    l_attribute8_tbl(i)             := l_resource_rec_tbl(i).ATTRIBUTE8;
                    l_attribute9_tbl(i)             := l_resource_rec_tbl(i).ATTRIBUTE9;
                    l_attribute10_tbl(i)            := l_resource_rec_tbl(i).ATTRIBUTE10;
                    l_attribute11_tbl(i)            := l_resource_rec_tbl(i).ATTRIBUTE11;
                    l_attribute12_tbl(i)            := l_resource_rec_tbl(i).ATTRIBUTE12;
                    l_attribute13_tbl(i)            := l_resource_rec_tbl(i).ATTRIBUTE13;
                    l_attribute14_tbl(i)            := l_resource_rec_tbl(i).ATTRIBUTE14;
                    l_attribute15_tbl(i)            := l_resource_rec_tbl(i).ATTRIBUTE15;
                    l_attribute16_tbl(i)            := l_resource_rec_tbl(i).ATTRIBUTE16;
                    l_attribute17_tbl(i)            := l_resource_rec_tbl(i).ATTRIBUTE17;
                    l_attribute18_tbl(i)            := l_resource_rec_tbl(i).ATTRIBUTE18;
                    l_attribute19_tbl(i)            := l_resource_rec_tbl(i).ATTRIBUTE19;
                    l_attribute20_tbl(i)            := l_resource_rec_tbl(i).ATTRIBUTE20;
                    l_attribute21_tbl(i)            := l_resource_rec_tbl(i).ATTRIBUTE21;
                    l_attribute22_tbl(i)            := l_resource_rec_tbl(i).ATTRIBUTE22;

                    l_attribute23_tbl(i)            := l_resource_rec_tbl(i).ATTRIBUTE23;
                    l_attribute24_tbl(i)            := l_resource_rec_tbl(i).ATTRIBUTE24;
                    l_attribute25_tbl(i)            := l_resource_rec_tbl(i).ATTRIBUTE25;
                    l_attribute26_tbl(i)            := l_resource_rec_tbl(i).ATTRIBUTE26;
                    l_attribute27_tbl(i)            := l_resource_rec_tbl(i).ATTRIBUTE27;
                    l_attribute28_tbl(i)            := l_resource_rec_tbl(i).ATTRIBUTE28;
                    l_attribute29_tbl(i)            := l_resource_rec_tbl(i).ATTRIBUTE29;
                    l_attribute30_tbl(i)            := l_resource_rec_tbl(i).ATTRIBUTE30;

                    --For bug 3948128
                    IF p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK THEN
                        l_scheduled_delay(i)            := l_resource_rec_tbl(i).scheduled_delay;
                    END IF;
             END IF;
/* Commenting out this code for check for spread curve date to be null
   since this check will be done in Process_res_chg_Derv_calc_prms 3762278
-- Added for Bug 3607061 - Starts
-- Please not that FIXED DATE SPREAD CURVE ID is SEEDED as 6, so we are able to hard code it below
             IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Deriving SP Fixed Date';
                    print_msg(pa_debug.g_err_stage,l_module_name);
             END IF;
             IF l_spread_curve_id_tbl(i) = l_fixed_date_sp_id THEN
                IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Spread Curve Id is of FIXED_DATE';
                   print_msg(pa_debug.g_err_stage,l_module_name);
                END IF;
                IF l_sp_fixed_date_tbl(i) = FND_API.G_MISS_DATE THEN
                   IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:='Error - cannot nullify sp_fixed_date for Fixed Date Spread curve';
                      print_msg(pa_debug.g_err_stage,l_module_name);
                   END IF;
                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                        p_msg_name       => 'PA_FP_SP_FIXED_DATE_NULL');
                   RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;
             END IF;
-- Added for Bug 3607061 - Ends
*/
                               --dbms_output.put_line('E2');

        END LOOP;

--dbms_output.put_line('l_total_quantity_tbl.last '||l_total_quantity_tbl.last||' l_total_quantity_tbl(1) '||l_total_quantity_tbl(1));

       --Get the project currency so that it can be used in preparing pl/sql tables for calculate api
       pa_budget_utils.Get_Project_Currency_Info
       (  p_project_id             => l_project_id
        , x_projfunc_currency_code => l_projfunc_currency_code_out
        , x_project_currency_code  => l_existing_curr_code
        , x_txn_currency_code      => l_projfunc_currency_code
        , x_msg_count              => x_msg_count
        , x_msg_data               => x_msg_data
        , x_return_status          => x_return_status);
       --dbms_output.put_line('4');
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Cpa_budget_utils.Get_Project_Currency_Info returned error';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;

       --Derive the tables that are required for Calculate API
       IF p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET OR p_context = PA_FP_CONSTANTS_PKG.G_PLAN_CLASS_FORECAST THEN

            IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Preparing the pl/sql tables for calling calc api for BF';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;


            l_override_currency_code_tbl := p_txn_currency_override_tbl;
            l_bill_rate_override_tbl     := p_bill_rate_override_tbl;
            l_bill_rate_tbl              := p_bill_rate_tbl;
            l_burdened_rate_override_tbl := p_burdened_rate_override_tbl;
            l_b_multiplier_tbl           := p_burdened_rate_tbl;
            l_cost_rate_override_tbl     := p_cost_rate_override_tbl;
            l_raw_cost_rate_tbl          := p_cost_rate_tbl;
            l_revenue_tbl                := p_revenue_tbl;
            l_burdened_cost_tbl          := p_burdened_cost_tbl;
            l_total_raw_cost_tbl         := p_raw_cost_tbl;
            --Added by Xin. Fix Bug 3430136
            --Feb-09-2004 Doosan iteration 1
            l_currency_code_tbl          := p_currency_code_tbl;

            l_override_currency_code_tbl.EXTEND(l_resource_assignment_id_tbl.COUNT-l_override_currency_code_tbl.COUNT );
            l_bill_rate_override_tbl.EXTEND(l_resource_assignment_id_tbl.COUNT-l_bill_rate_override_tbl.COUNT);
            l_bill_rate_tbl.EXTEND(l_resource_assignment_id_tbl.COUNT-l_bill_rate_tbl.COUNT);
            l_burdened_rate_override_tbl.EXTEND(l_resource_assignment_id_tbl.COUNT-l_burdened_rate_override_tbl.COUNT);
            l_b_multiplier_tbl.EXTEND(l_resource_assignment_id_tbl.COUNT-l_b_multiplier_tbl.COUNT);
            --dbms_output.put_line('l_cost_rate_override_tbl count is '||l_cost_rate_override_tbl.count);
            l_cost_rate_override_tbl.EXTEND(l_resource_assignment_id_tbl.COUNT-l_cost_rate_override_tbl.COUNT);
            --dbms_output.put_line('A l_cost_rate_override_tbl count is '||l_cost_rate_override_tbl.count);
            l_raw_cost_rate_tbl.EXTEND(l_resource_assignment_id_tbl.COUNT-l_raw_cost_rate_tbl.COUNT);
            l_revenue_tbl.EXTEND(l_resource_assignment_id_tbl.COUNT-l_revenue_tbl.COUNT);
            l_burdened_cost_tbl.EXTEND(l_resource_assignment_id_tbl.COUNT-l_burdened_cost_tbl.COUNT);
            l_total_raw_cost_tbl.EXTEND(l_resource_assignment_id_tbl.COUNT-l_total_raw_cost_tbl.COUNT);
            l_currency_code_tbl.EXTEND(l_resource_assignment_id_tbl.COUNT-l_currency_code_tbl.COUNT);



       -- In the context of Task Assignment and Workplan, the block below will calculate the additional quantity
       -- i.e. the difference between the existing quantity and the quantity passed.
       ELSIF p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK OR p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN THEN

            IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='About to bulk collect into pl/sql tables req for calc api '||l_override_currency_code_tbl.last;
               print_msg(pa_debug.g_err_stage,l_module_name);
            END IF;

            /* Preparing PLSql Tables for Rates for Calling Calculate API*/
            -- Bug 3760166
            l_bill_rate_tbl              := p_bill_rate_tbl;
            l_b_multiplier_tbl           := p_burdened_rate_tbl;
            l_raw_cost_rate_tbl          := p_cost_rate_tbl;

            l_bill_rate_tbl.EXTEND(l_resource_assignment_id_tbl.COUNT-l_bill_rate_tbl.COUNT);
            l_b_multiplier_tbl.EXTEND(l_resource_assignment_id_tbl.COUNT-l_b_multiplier_tbl.COUNT);
            l_raw_cost_rate_tbl.EXTEND(l_resource_assignment_id_tbl.COUNT-l_raw_cost_rate_tbl.COUNT);

            /** added for progress upload  **/
            -- Bug 3807763. For Workplan Context, check_and_create_task_rec info has already been called.
            -- This takes care of populating l_burdened_cost_tbl and l_total_raw_cost_tbl as per the I/P Data.
            If ((p_apply_progress_flag = 'Y' AND p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK) OR
                        p_upd_cost_amts_too_for_ta_flg = 'Y' ) THEN --Added for bug#4538286.
                --l_revenue_tbl                := p_revenue_tbl;
                l_burdened_cost_tbl          := p_burdened_cost_tbl;
                l_total_raw_cost_tbl         := p_raw_cost_tbl;

                l_total_raw_cost_tbl.EXTEND(l_resource_assignment_id_tbl.COUNT-l_total_raw_cost_tbl.COUNT);
                l_burdened_cost_tbl.EXTEND(l_resource_assignment_id_tbl.COUNT-l_burdened_cost_tbl.COUNT);
            End If;

           --The below LOOP will be used to derive the txn currency code for each task assignment
           FOR  i IN l_resource_assignment_id_tbl.FIRST .. l_resource_assignment_id_tbl.LAST LOOP

		           --Bug 6397725. From FP M RUP3 onwards check should be made against pa_resource_asgn_curr
		           --table
		           /*
               SELECT NVL(pbl.txn_currency_code,l_existing_curr_code)
               INTO   l_currency_code_tbl(i)
               FROM   pa_resource_assignments b,
                      (SELECT pbl.txn_currency_code,
                              pra.resource_assignment_id
                       FROM   pa_budget_lines pbl,
                              pa_resource_assignments pra
                       WHERE  pbl.resource_assignment_id(+)=pra.resource_assignment_id
                       AND    pra.resource_assignment_id=l_resource_assignment_id_tbl(i)
                       AND    ROWNUM=1) pbl
               WHERE  b.resource_assignment_id=l_resource_assignment_id_tbl(i);*/

               SELECT NVL(rac.txn_currency_code,l_existing_curr_code)
 	                INTO   l_currency_code_tbl(i)
 	                FROM   pa_resource_asgn_curr rac,
 	                       pa_resource_assignments pra
 	                WHERE  rac.resource_assignment_id(+)=pra.resource_assignment_id
 	                AND    pra.resource_assignment_id=l_resource_assignment_id_tbl(i);

           END LOOP;
           /* Note that l_override_currency_code_tbl would be null in case of
             * WP which is correct. This can never be edited in WP flow. For TA,
             * l_override_curr_code_tbl would be having override curr code that
             * got passed from the UI and ultimately returned back by the
             * validate TA api */

            IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Done with preparing the tables';
               print_msg(pa_debug.g_err_stage,l_module_name);
            END IF;

       END IF;

       /* Calling the api Derive_Parameters_For_Calc_Api
        */
       IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Calling API Derive_Parameters_For_Calc_Api';
              print_msg(pa_debug.g_err_stage,l_module_name);
       END IF;
--dbms_output.put_line('l_b_multiplier_tbl cnt is '||l_burdened_rate_override_tbl.count);
       --dbms_output.put_line('5');
       Process_res_chg_Derv_calc_prms
        (
         p_context                         => p_context
        ,p_calling_context                 => p_calling_context   -- Added for Bug 6856934
        ,p_budget_version_id               => l_budget_version_id
        ,p_resource_assignment_id_tbl      => l_resource_assignment_id_tbl
        ,p_resource_list_member_id_tbl     => l_resource_list_member_id_tbl
        ,p_planning_start_date_tbl         => l_planning_start_date_tbl
        ,p_planning_end_date_tbl           => l_planning_end_date_tbl
        ,p_spread_curve_id_tbl             => l_spread_curve_id_tbl
        ,p_sp_fixed_date_tbl               => l_sp_fixed_date_tbl
        ,p_txn_currency_code_tbl           => l_currency_code_tbl
        ,p_inventory_item_id_tbl           => l_inventory_item_id_tbl
        ,p_expenditure_type_tbl            => l_expenditure_type_tbl
        ,p_person_id_tbl                   => l_person_id_tbl
        ,p_job_id_tbl                      => l_job_id_tbl
        ,p_organization_id_tbl             => l_organization_id_tbl
        ,p_event_type_tbl                  => l_event_type_tbl
        ,p_expenditure_category_tbl        => l_expenditure_category_tbl
        ,p_revenue_category_code_tbl       => l_revenue_category_code_tbl
        ,p_item_category_id_tbl            => l_item_category_id_tbl
        ,p_bom_resource_id_tbl             => l_bom_resource_id_tbl
        ,p_project_role_id_tbl             => l_project_role_id_tbl
        ,p_person_type_code_tbl            => l_person_type_code_tbl
        ,p_supplier_id_tbl                 => l_supplier_id_tbl
        ,p_named_role_tbl                  => l_named_role_tbl
        ,p_mfc_cost_type_id_tbl            => l_mfc_cost_type_id_tbl
        ,p_fixed_date_sp_id                => l_fixed_date_sp_id
        ,px_total_qty_tbl                  => l_total_quantity_tbl
        ,px_total_raw_cost_tbl             => l_total_raw_cost_tbl
        ,px_total_burdened_cost_tbl        => l_burdened_cost_tbl
        ,px_total_revenue_tbl              => l_revenue_tbl
        ,px_raw_cost_rate_tbl              => l_raw_cost_rate_tbl
        ,px_raw_cost_override_rate_tbl     => l_cost_rate_override_tbl
        ,px_b_cost_rate_tbl                => l_b_multiplier_tbl
        ,px_b_cost_rate_override_tbl       => l_burdened_rate_override_tbl
        ,px_bill_rate_tbl                  => l_bill_rate_tbl
        ,px_bill_rate_override_tbl         => l_bill_rate_override_tbl
        ,x_rbs_element_id_tbl              => l_rbs_element_id_tbl
        ,x_txn_accum_header_id_tbl         => l_txn_accum_header_id_tbl
        ,x_mfc_cost_type_id_old_tbl        => l_mfc_cost_type_id_old_tbl
        ,x_mfc_cost_type_id_new_tbl        => l_mfc_cost_type_id_new_tbl
        ,x_spread_curve_id_old_tbl         => l_spread_curve_id_old_tbl
        ,x_spread_curve_id_new_tbl         => l_spread_curve_id_new_tbl
        ,x_sp_fixed_date_old_tbl           => l_sp_fixed_date_old_tbl
        ,x_sp_fixed_date_new_tbl           => l_sp_fixed_date_new_tbl
        ,x_plan_start_date_old_tbl         => l_plan_start_date_old_tbl
        ,x_plan_start_date_new_tbl         => l_plan_start_date_new_tbl
        ,x_plan_end_date_old_tbl           => l_plan_end_date_old_tbl
        ,x_plan_end_date_new_tbl           => l_plan_end_date_new_tbl
        ,x_rlm_id_change_flag_tbl          => l_rlm_id_change_flag_tbl
        ,x_return_status                   => x_return_status
        ,x_msg_data                        => x_msg_data
        ,x_msg_count                       => x_msg_count );

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Derive_Parameters_For_Calc_Api returned error';
                   print_msg(pa_debug.g_err_stage,l_module_name);
             END IF;
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;

       --The Sp Fixed Date will be defaulted in Process_res_chg_Derv_calc_prms to planning start date if not passed
       --for a resource assignment with fixed spread curve. Hence the value returned should be considered
       l_sp_fixed_date_tbl := l_sp_fixed_date_new_tbl;
--dbms_output.put_line(' cccc l_burdened_rate_override_tbl cnt is '||l_burdened_rate_override_tbl.count);
       IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Bulk updating pa_resource_assignments. start '||l_resource_assignment_id_tbl.FIRST ||' end '||l_resource_assignment_id_tbl.LAST;
              print_msg(pa_debug.g_err_stage,l_module_name);
       END IF;

       --dbms_output.put_line('6');
       --Prepare the pl/sql tables for the all columns in pa_resource_assignments to make use of bulk update
       FORALL i IN l_resource_assignment_id_tbl.FIRST .. l_resource_assignment_id_tbl.LAST

             UPDATE  PA_RESOURCE_ASSIGNMENTS
             SET     resource_list_member_id      = DECODE (l_resource_list_member_id_tbl(i),l_g_miss_num,null,nvl(l_resource_list_member_id_tbl(i),resource_list_member_id))
                    ,last_update_date             = sysdate
                    ,last_updated_by              = FND_GLOBAL.user_id
                    ,last_update_login            = FND_GLOBAL.login_id
                    ,unit_of_measure              = DECODE (l_unit_of_measure_tbl(i), l_g_miss_char,null,nvl( l_unit_of_measure_tbl(i),unit_of_measure))
                    ,project_assignment_id        = DECODE (l_project_assignment_id_tbl(i), l_g_miss_num,null,nvl(l_project_assignment_id_tbl(i),project_assignment_id))
                    ,planning_start_date          = DECODE (l_planning_start_date_tbl(i), l_g_miss_date,null,nvl(l_planning_start_date_tbl(i),planning_start_date))
                    ,planning_end_date            = DECODE (l_planning_end_date_tbl(i), l_g_miss_date,null,nvl(l_planning_end_date_tbl(i),planning_end_date))
                    ,schedule_start_date          = DECODE (l_schedule_start_date_tbl(i), l_g_miss_date,null,nvl(l_schedule_start_date_tbl(i),schedule_start_date))
                    ,schedule_end_date            = DECODE (l_schedule_end_date_tbl(i), l_g_miss_date,null,nvl(l_schedule_end_date_tbl(i),schedule_end_date))
                    ,spread_curve_id              = DECODE (l_spread_curve_id_tbl(i), l_g_miss_num,null,nvl(l_spread_curve_id_tbl(i),spread_curve_id ))
                    ,etc_method_code              = DECODE (l_etc_method_code_tbl(i), l_g_miss_char,null,nvl(l_etc_method_code_tbl(i),etc_method_code))
                    ,res_type_code                = DECODE (l_res_type_code_tbl(i), l_g_miss_char,null,nvl(l_res_type_code_tbl(i),res_type_code))
                    ,attribute_category           = DECODE (l_attribute_category_tbl(i), l_g_miss_char,null,nvl(l_attribute_category_tbl(i),attribute_category))
                    ,attribute1                   = DECODE (l_attribute1_tbl(i), l_g_miss_char,null,nvl(l_attribute1_tbl(i),attribute1))
                    ,attribute2                   = DECODE (l_attribute2_tbl(i), l_g_miss_char,null,nvl(l_attribute2_tbl(i),attribute2))
                    ,attribute3                   = DECODE (l_attribute3_tbl(i), l_g_miss_char,null,nvl(l_attribute3_tbl(i),attribute3 ))
                    ,attribute4                   = DECODE (l_attribute4_tbl(i), l_g_miss_char,null,nvl(l_attribute4_tbl(i),attribute4))
                    ,attribute5                   = DECODE (l_attribute5_tbl(i), l_g_miss_char,null,nvl(l_attribute5_tbl(i),attribute5 ))
                    ,attribute6                   = DECODE (l_attribute6_tbl(i), l_g_miss_char,null,nvl(l_attribute6_tbl(i),attribute6 ))
                    ,attribute7                   = DECODE (l_attribute7_tbl(i), l_g_miss_char,null,nvl(l_attribute7_tbl(i),attribute7))
                    ,attribute8                   = DECODE (l_attribute8_tbl(i), l_g_miss_char,null,nvl(l_attribute8_tbl(i),attribute8))
                    ,attribute9                   = DECODE (l_attribute9_tbl(i), l_g_miss_char,null,nvl(l_attribute9_tbl(i),attribute9))
                    ,attribute10                  = DECODE (l_attribute10_tbl(i), l_g_miss_char,null, nvl(l_attribute10_tbl(i),attribute10))
                    ,attribute11                  = DECODE (l_attribute11_tbl(i), l_g_miss_char,null,nvl(l_attribute11_tbl(i),attribute11))
                    ,attribute12                  = DECODE (l_attribute12_tbl(i), l_g_miss_char,null,nvl(l_attribute12_tbl(i),attribute12))
                    ,attribute13                  = DECODE (l_attribute13_tbl(i), l_g_miss_char,null,nvl(l_attribute13_tbl(i),attribute13))
                    ,attribute14                  = DECODE (l_attribute14_tbl(i), l_g_miss_char,null,nvl(l_attribute14_tbl(i),attribute14))  -- for bug 6944671
                    ,attribute15                  = DECODE (l_attribute15_tbl(i), l_g_miss_char,null,nvl(l_attribute15_tbl(i),attribute15))
                    ,attribute16                  = DECODE (l_attribute16_tbl(i), l_g_miss_char,null,nvl(l_attribute16_tbl(i),attribute16))
                    ,attribute17                  = DECODE (l_attribute17_tbl(i), l_g_miss_char,null,nvl(l_attribute17_tbl(i),attribute17))
                    ,attribute18                  = DECODE (l_attribute18_tbl(i), l_g_miss_char,null,nvl(l_attribute18_tbl(i),attribute18))
                    ,attribute19                  = DECODE (l_attribute19_tbl(i), l_g_miss_char,null,nvl(l_attribute19_tbl(i),attribute19))
                    ,attribute20                  = DECODE (l_attribute20_tbl(i), l_g_miss_char,null,nvl(l_attribute20_tbl(i),attribute20))
                    ,attribute21                  = DECODE (l_attribute21_tbl(i), l_g_miss_char,null,nvl(l_attribute21_tbl(i),attribute21))
                    ,attribute22                  = DECODE (l_attribute22_tbl(i), l_g_miss_char,null,nvl(l_attribute22_tbl(i),attribute22))
                    ,attribute23                  = DECODE (l_attribute23_tbl(i), l_g_miss_char,null,nvl(l_attribute23_tbl(i),attribute23))
                    ,attribute24                  = DECODE (l_attribute24_tbl(i), l_g_miss_char,null,nvl(l_attribute24_tbl(i),attribute24))
                    ,attribute25                  = DECODE (l_attribute25_tbl(i), l_g_miss_char,null,nvl(l_attribute25_tbl(i),attribute25))
                    ,attribute26                  = DECODE (l_attribute26_tbl(i), l_g_miss_char,null,nvl(l_attribute26_tbl(i),attribute26))
                    ,attribute27                  = DECODE (l_attribute27_tbl(i), l_g_miss_char,null,nvl(l_attribute27_tbl(i),attribute27))
                    ,attribute28                  = DECODE (l_attribute28_tbl(i), l_g_miss_char,null,nvl(l_attribute28_tbl(i),attribute28))
                    ,attribute29                  = DECODE (l_attribute29_tbl(i), l_g_miss_char,null,nvl(l_attribute29_tbl(i),attribute29))
                    ,attribute30                  = DECODE (l_attribute30_tbl(i), l_g_miss_char,null,nvl(l_attribute30_tbl(i),attribute30))
                    ,fc_res_type_code             = DECODE (l_fc_res_type_code_tbl(i), l_g_miss_char,null,nvl(l_fc_res_type_code_tbl(i),fc_res_type_code))
                    ,resource_class_code          = DECODE (l_resource_class_code_tbl(i), l_g_miss_char,null,nvl(l_resource_class_code_tbl(i),resource_class_code))
                    ,organization_id              = DECODE (l_organization_id_tbl(i), l_g_miss_num,null,nvl(l_organization_id_tbl(i),organization_id))
                    ,job_id                       = DECODE (l_job_id_tbl(i), l_g_miss_num,null,nvl(l_job_id_tbl(i),job_id))
                    ,person_id                    = DECODE (l_person_id_tbl(i), l_g_miss_num,null,nvl(l_person_id_tbl(i),person_id))
                    ,expenditure_type             = DECODE (l_expenditure_type_tbl(i), l_g_miss_char,null,nvl(l_expenditure_type_tbl(i),expenditure_type))
                    ,expenditure_category         = DECODE (l_expenditure_category_tbl(i), l_g_miss_char,null,nvl(l_expenditure_category_tbl(i),expenditure_category))
                    ,revenue_category_code        = DECODE (l_revenue_category_code_tbl(i), l_g_miss_char,null,nvl(l_revenue_category_code_tbl(i),revenue_category_code))
                    ,event_type                   = DECODE (l_event_type_tbl(i), l_g_miss_char,null,nvl(l_event_type_tbl(i),event_type))
                    ,supplier_id                  = DECODE (l_supplier_id_tbl(i), l_g_miss_num,null,nvl(l_supplier_id_tbl(i),supplier_id))
                    ,non_labor_resource           = DECODE (l_non_labor_resource_tbl(i), l_g_miss_char,null,nvl(l_non_labor_resource_tbl(i),non_labor_resource))
                    ,bom_resource_id              = DECODE (l_bom_resource_id_tbl(i), l_g_miss_num,null,nvl(l_bom_resource_id_tbl(i),bom_resource_id))
                    ,inventory_item_id            = DECODE (l_inventory_item_id_tbl(i), l_g_miss_num,null,nvl(l_inventory_item_id_tbl(i),inventory_item_id))
                    ,item_category_id             = DECODE (l_item_category_id_tbl(i), l_g_miss_num,null,nvl(l_item_category_id_tbl(i),item_category_id))
                    ,record_version_number        = nvl(record_version_number,0)+1
                    ,billable_percent             = DECODE (l_billable_percent_tbl(i), l_g_miss_num,null,nvl(l_billable_percent_tbl(i),billable_percent))
                    ,mfc_cost_type_id             = DECODE (l_mfc_cost_type_id_tbl(i), l_g_miss_num,null,nvl(l_mfc_cost_type_id_tbl(i),mfc_cost_type_id ))
                    ,procure_resource_flag        = DECODE (l_procure_resource_flag_tbl(i), l_g_miss_char,null,nvl(l_procure_resource_flag_tbl(i),procure_resource_flag))
                    ,assignment_description       = DECODE (l_assignment_description_tbl(i), l_g_miss_char,null,nvl(l_assignment_description_tbl(i),assignment_description))
                    ,incurred_by_res_flag         = DECODE (l_incurred_by_res_flag_tbl(i), l_g_miss_char,null,nvl(l_incurred_by_res_flag_tbl(i),incurred_by_res_flag))
                    ,sp_fixed_date                = DECODE (l_sp_fixed_date_tbl(i), l_g_miss_date,null,nvl(l_sp_fixed_date_tbl(i),sp_fixed_date))
                    ,person_type_code             = DECODE (l_person_type_code_tbl(i), l_g_miss_char,null,nvl(l_person_type_code_tbl(i),person_type_code))
                    ,use_task_schedule_flag       = DECODE (l_use_task_schedule_flag_tbl(i), l_g_miss_char,null,nvl(l_use_task_schedule_flag_tbl(i),use_task_schedule_flag))
                    ,incur_by_res_class_code      = DECODE (l_Incur_by_res_class_code_tbl(i), l_g_miss_char,null,nvl(l_Incur_by_res_class_code_tbl(i),incur_by_res_class_code ))
                    ,incur_by_role_id             = DECODE (l_Incur_by_role_id_tbl(i), l_g_miss_num,null,nvl(l_Incur_by_role_id_tbl(i),incur_by_role_id))
                    ,project_role_id              = DECODE (l_project_role_id_tbl(i), l_g_miss_num,null,nvl(l_project_role_id_tbl(i),project_role_id))
                    ,resource_class_flag          = DECODE (l_resource_class_flag_tbl(i), l_g_miss_char,null,nvl(l_resource_class_flag_tbl(i),resource_class_flag ))
                    ,named_role                   = DECODE (l_named_role_tbl(i), l_g_miss_char,null,nvl(l_named_role_tbl(i),named_role ))
                    ,rbs_element_id               = l_rbs_element_id_tbl(i)
                    ,txn_accum_header_id          = l_txn_accum_header_id_tbl(i)
                    ,rate_expenditure_org_id      = DECODE (p_context
                                                           ,PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK
                                                           ,DECODE(l_rate_exp_org_id_tbl(i)
                                                                  ,l_g_miss_num
                                                                  ,null
                                                                  ,nvl(l_rate_exp_org_id_tbl(i),rate_expenditure_org_id))
                                                           ,rate_expenditure_org_id)
                    ,rate_expenditure_type        = DECODE (p_context
                                                           ,PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK
                                                           ,DECODE(l_rate_exp_type_tbl(i)
                                                                  ,l_g_miss_char
                                                                  ,null
                                                                  ,nvl(l_rate_exp_type_tbl(i),rate_expenditure_type))
                                                           ,rate_expenditure_type)
                    ,rate_exp_func_curr_code      = DECODE (p_context
                                                           ,PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK
                                                           ,DECODE(l_rate_func_curr_code_tbl(i)
                                                                  ,l_g_miss_char
                                                                  ,null
                                                                  ,nvl(l_rate_func_curr_code_tbl(i),rate_exp_func_curr_code))
                                                           ,rate_exp_func_curr_code)
                    ,rate_based_flag              = DECODE (p_context  /* Bug 3678814 */
                                                           ,PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK
                                                           ,DECODE(l_rate_based_flag_tbl(i),
                                                                   l_g_miss_char,'N',
                                                                   nvl(l_rate_based_flag_tbl(i),rate_based_flag))
                                                           ,rate_based_flag)
		    /* Bug fix:5759413 */
		    ,resource_rate_based_flag     = DECODE (p_context,PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK
							,DECODE(nvl(l_rlm_id_change_flag_tbl(i),'N'), 'N'
							  ,resource_rate_based_flag
							  ,DECODE(l_rate_based_flag_tbl(i),
                                                                   l_g_miss_char,'N',
                                                                   nvl(l_rate_based_flag_tbl(i),resource_rate_based_flag)))
							 ,resource_rate_based_flag)
                    ,scheduled_delay              = DECODE (p_context  /* Bug 3678814 */
                                                           ,PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK
                                                           ,DECODE(l_scheduled_delay(i),
                                                                   l_g_miss_num,null,
                                                                   nvl(l_scheduled_delay(i),scheduled_delay))
                                                           ,scheduled_delay)
                    WHERE  resource_assignment_id= l_resource_assignment_id_tbl(i);
       /*-------------------------------------------------------------------------------
         The following block of code to call the api PA_FP_CALC_PLAN_PKG.calculate
         is commented as it has to be modified
         Calling the api PA_FP_CALC_PLAN_PKG.calculate*/

       /* Start of coding done for Bug 5684639:
          If the user has selected not to distribute the amounts, then
          pass the l_plan_end_date_old_tbl as l_plan_end_date_new_tbl AND
          l_plan_start_date_old_tbl as l_plan_start_date_new_tbl so that there is
          no distribution of amounts as the old and the new dates are the same.
       */
          IF l_debug_mode = 'Y'  THEN
             pa_debug.g_err_stage:='p_distrib_amts - '||p_distrib_amts;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
          END IF;
          IF (nvl(p_distrib_amts,'Y') = 'N') THEN

            -- Start Bug 5906826
            /* Commented for Bug 9610380
            IF (l_resource_assignment_id_tbl.count > 1) THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'p_distrib_amts is N and resource assignment > 1';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;
            */

            FOR  i IN l_resource_assignment_id_tbl.FIRST .. l_resource_assignment_id_tbl.LAST LOOP

                l_ra_id_tbl                := SYSTEM.PA_NUM_TBL_TYPE();
                l_line_start_date_tbl      := SYSTEM.PA_DATE_TBL_TYPE();
                l_line_end_date_tbl        := SYSTEM.PA_DATE_TBL_TYPE();
                l_txn_currency_code_tbl    := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
                l_tot_qty_tbl              := SYSTEM.PA_NUM_TBL_TYPE();
                l_txn_raw_cost_tbl         := SYSTEM.PA_NUM_TBL_TYPE();
                l_txn_burdened_cost_tbl    := SYSTEM.PA_NUM_TBL_TYPE();
                l_delete_budget_lines_tbl  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();

                -- If condition to delete budget lines, when dates are trucated and spread curve is not changed
                -- and spread curve is other than fixed date when p_distrib_amts flag is checked.
                IF ((l_plan_start_date_old_tbl(i) < l_plan_start_date_new_tbl(i)) OR
                (l_plan_end_date_old_tbl(i) > l_plan_end_date_new_tbl(i))) AND
                (l_spread_curve_id_old_tbl(i) = l_spread_curve_id_new_tbl(i)) AND
                 (l_spread_curve_id_old_tbl(i) <> 6)THEN

                   SELECT pbl.resource_assignment_id,
                           pbl.start_date,
                           pbl.end_date,
                           pbl.txn_currency_code,
                           pbl.quantity,
                           pbl.txn_raw_cost,
                           pbl.txn_burdened_cost,
                           'Y'
                    BULK COLLECT INTO
                           l_ra_id_tbl,
                           l_line_start_date_tbl,
                           l_line_end_date_tbl,
                           l_txn_currency_code_tbl,
                           l_tot_qty_tbl,
                           l_txn_raw_cost_tbl,
                           l_txn_burdened_cost_tbl,
                           l_delete_budget_lines_tbl
                    FROM   pa_budget_lines pbl,
                           pa_budget_versions pbv
                    WHERE  pbl.budget_version_id=l_budget_version_id
                    AND    pbl.resource_assignment_id=l_resource_assignment_id_tbl(i)
                    AND    pbl.txn_currency_code=l_currency_code_tbl(i)
                    AND    pbv.budget_version_id=pbl.budget_version_id
                    AND    pbl.start_date>=nvl(pbv.etc_start_date,pbl.start_date)
                    AND    (
                             (pbl.start_date>l_plan_end_date_new_tbl(i))
                             OR
                             (pbl.end_date<l_plan_start_date_new_tbl(i))
                            );

                    -- This is set to  'Y' so that calculate api is called only once.
                    l_cal_api_called_flg := 'Y';

                    -- Used to delete the budget lines which are falling out of planning start/end date
                    -- range when p_distrib_amts flag is checked.
                    PA_FP_CALC_PLAN_PKG.calculate(
                        p_project_id                   => l_project_id,
                        p_budget_version_id            => l_budget_version_id,
                        p_refresh_rates_flag           => 'N',
                        p_refresh_conv_rates_flag      => 'N',
                        p_spread_required_flag         => 'Y',
                        p_conv_rates_required_flag     => 'Y',
                        p_rollup_required_flag         => 'Y',
                        p_mass_adjust_flag             => 'N',
                        p_quantity_adj_pct             => NULL,
                        p_cost_rate_adj_pct            => NULL,
                        p_burdened_rate_adj_pct        => NULL,
                        p_bill_rate_adj_pct            => NULL,
                        p_source_context               => 'BUDGET_LINE',
                        p_resource_assignment_tab      => l_ra_id_tbl,
                        p_delete_budget_lines_tab      => l_delete_budget_lines_tbl,
                        p_txn_currency_code_tab        => l_txn_currency_code_tbl,
                        p_total_qty_tab                => l_tot_qty_tbl,
                        p_total_raw_cost_tab           => l_txn_raw_cost_tbl,
                        p_total_burdened_cost_tab      => l_txn_burdened_cost_tbl,
                        p_line_start_date_tab          => l_line_start_date_tbl,
                        p_line_end_date_tab            => l_line_end_date_tbl,
                        x_return_status                => l_return_status,
                        x_msg_count                    => l_msg_count,
                        x_msg_data                     => l_msg_data);

                END IF;
            END LOOP;
            -- End Bug 5906826

             l_plan_start_date_old_tbl := l_plan_start_date_new_tbl ;
             l_plan_end_date_old_tbl := l_plan_end_date_new_tbl ;
          END IF;

        /* End of coding done for Bug 5684639.*/

       IF l_debug_mode = 'Y'  THEN
            pa_debug.g_err_stage:='Calling API PA_FP_CALC_PLAN_PKG.calculate';
            print_msg(pa_debug.g_err_stage,l_module_name);
            pa_debug.g_err_stage:='Parameters to PA_FP_CALC_PLAN_PKG.calculate';
            print_msg(pa_debug.g_err_stage,l_module_name);

            IF l_resource_assignment_id_tbl.COUNT>0 THEN

                FOR i in l_resource_assignment_id_tbl.FIRST .. l_resource_assignment_id_tbl.LAST LOOP

                    pa_debug.g_err_stage:='l_resource_assignment_id_tbl('||i||') is '||l_resource_assignment_id_tbl(i);
                    print_msg(pa_debug.g_err_stage,l_module_name);
                    --dbms_output.put_line( pa_debug.g_err_stage);

                    pa_debug.g_err_stage:='l_currency_code_tbl('||i||') is '||l_currency_code_tbl(i);
                    print_msg(pa_debug.g_err_stage,l_module_name);
                    --dbms_output.put_line( pa_debug.g_err_stage);

                    IF p_currency_code_tbl.EXISTS(i) THEN
                        pa_debug.g_err_stage:='p_currency_code_tbl('||i||') is '||p_currency_code_tbl(i);
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    ELSE
                        pa_debug.g_err_stage:='p_currency_code_tbl('||i||') does not exist ';
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    END IF;
                    --dbms_output.put_line( pa_debug.g_err_stage);

                    pa_debug.g_err_stage:='l_override_currency_code_tbl('||i||') is '||l_override_currency_code_tbl(i);
                    print_msg(pa_debug.g_err_stage,l_module_name);
                    --dbms_output.put_line( pa_debug.g_err_stage);

                    IF p_txn_currency_override_tbl.EXISTS(i) THEN
                        pa_debug.g_err_stage:='p_txn_currency_override_tbl('||i||') is '||p_txn_currency_override_tbl(i);
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    ELSE
                        pa_debug.g_err_stage:='p_txn_currency_override_tbl('||i||') does not exist ';
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    END IF;
                    --dbms_output.put_line( pa_debug.g_err_stage);

                    pa_debug.g_err_stage:='l_total_quantity_tbl('||i||') is '||l_total_quantity_tbl(i);
                    print_msg(pa_debug.g_err_stage,l_module_name);
                    --dbms_output.put_line( pa_debug.g_err_stage);

                    IF p_quantity_tbl.EXISTS(i) THEN
                        pa_debug.g_err_stage:='p_quantity_tbl('||i||') is '||p_quantity_tbl(i);
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    ELSE
                        pa_debug.g_err_stage:='p_quantity_tbl('||i||') does not exist ';
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    END IF;
                    --dbms_output.put_line( pa_debug.g_err_stage);

                    pa_debug.g_err_stage:='l_total_raw_cost_tbl('||i||') is '||l_total_raw_cost_tbl(i);
                    print_msg(pa_debug.g_err_stage,l_module_name);
                    --dbms_output.put_line( pa_debug.g_err_stage);

                    IF p_raw_cost_tbl.EXISTS(i) THEN
                        pa_debug.g_err_stage:='p_raw_cost_tbl('||i||') is '||p_raw_cost_tbl(i);
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    ELSE
                        pa_debug.g_err_stage:='p_raw_cost_tbl('||i||') does not exist ';
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    END IF;
                    --dbms_output.put_line( pa_debug.g_err_stage);

                    pa_debug.g_err_stage:='l_burdened_cost_tbl('||i||') is '||l_burdened_cost_tbl(i);
                    print_msg(pa_debug.g_err_stage,l_module_name);
                    --dbms_output.put_line( pa_debug.g_err_stage);

                    IF p_burdened_cost_tbl.EXISTS(i) THEN
                        pa_debug.g_err_stage:='p_burdened_cost_tbl('||i||') is '||p_burdened_cost_tbl(i);
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    ELSE
                        pa_debug.g_err_stage:='p_burdened_cost_tbl('||i||') does not exist ';
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    END IF;
                    --dbms_output.put_line( pa_debug.g_err_stage);

                    pa_debug.g_err_stage:='l_revenue_tbl('||i||') is '||l_revenue_tbl(i);
                    print_msg(pa_debug.g_err_stage,l_module_name);
                    --dbms_output.put_line( pa_debug.g_err_stage);

                    IF p_revenue_tbl.EXISTS(i) THEN
                        pa_debug.g_err_stage:='p_revenue_tbl('||i||') is '||p_revenue_tbl(i);
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    ELSE
                        pa_debug.g_err_stage:='p_revenue_tbl('||i||') does not exist ';
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    END IF;
                    --dbms_output.put_line( pa_debug.g_err_stage);

                    pa_debug.g_err_stage:='l_raw_cost_rate_tbl('||i||') is '||l_raw_cost_rate_tbl(i);
                    print_msg(pa_debug.g_err_stage,l_module_name);
                    --dbms_output.put_line( pa_debug.g_err_stage);

                    IF p_cost_rate_tbl.EXISTS(i) THEN
                        pa_debug.g_err_stage:='p_cost_rate_tbl('||i||') is '||p_cost_rate_tbl(i);
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    ELSE
                        pa_debug.g_err_stage:='p_cost_rate_tbl('||i||') does not exist ';
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    END IF;
                    --dbms_output.put_line( pa_debug.g_err_stage);

                    pa_debug.g_err_stage:='l_cost_rate_override_tbl('||i||') is '||l_cost_rate_override_tbl(i);
                    print_msg(pa_debug.g_err_stage,l_module_name);
                    --dbms_output.put_line( pa_debug.g_err_stage);

                    IF p_cost_rate_override_tbl.EXISTS(i) THEN
                        pa_debug.g_err_stage:='p_cost_rate_override_tbl('||i||') is '||p_cost_rate_override_tbl(i);
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    ELSE
                        pa_debug.g_err_stage:='p_cost_rate_override_tbl('||i||') does not exist ';
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    END IF;
                    --dbms_output.put_line( pa_debug.g_err_stage);

                    pa_debug.g_err_stage:='l_b_multiplier_tbl('||i||') is '||l_b_multiplier_tbl(i);
                    print_msg(pa_debug.g_err_stage,l_module_name);
                    --dbms_output.put_line( pa_debug.g_err_stage);

                    IF p_burdened_rate_tbl.EXISTS(i) THEN
                        pa_debug.g_err_stage:='p_burdened_rate_tbl('||i||') is '||p_burdened_rate_tbl(i);
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    ELSE
                        pa_debug.g_err_stage:='p_burdened_rate_tbl('||i||') does not exist ';
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    END IF;
                    --dbms_output.put_line( pa_debug.g_err_stage);

                    pa_debug.g_err_stage:='l_burdened_rate_override_tbl('||i||') is '||l_burdened_rate_override_tbl(i);
                    print_msg(pa_debug.g_err_stage,l_module_name);
                    --dbms_output.put_line( pa_debug.g_err_stage);

                    IF p_burdened_rate_override_tbl.EXISTS(i) THEN
                        pa_debug.g_err_stage:='p_burdened_rate_override_tbl('||i||') is '||p_burdened_rate_override_tbl(i);
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    ELSE
                        pa_debug.g_err_stage:='p_burdened_rate_override_tbl('||i||') does not exist ';
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    END IF;
                    --dbms_output.put_line( pa_debug.g_err_stage);

                    pa_debug.g_err_stage:='l_bill_rate_tbl('||i||') is '||l_bill_rate_tbl(i);
                    print_msg(pa_debug.g_err_stage,l_module_name);
                    --dbms_output.put_line( pa_debug.g_err_stage);

                    IF p_bill_rate_tbl.EXISTS(i) THEN
                        pa_debug.g_err_stage:='p_bill_rate_tbl('||i||') is '||p_bill_rate_tbl(i);
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    ELSE
                        pa_debug.g_err_stage:='p_bill_rate_tbl('||i||') does not exist ';
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    END IF;
                    --dbms_output.put_line( pa_debug.g_err_stage);

                    pa_debug.g_err_stage:='l_bill_rate_override_tbl('||i||') is '||l_bill_rate_override_tbl(i);
                    print_msg(pa_debug.g_err_stage,l_module_name);
                    --dbms_output.put_line( pa_debug.g_err_stage);

                    IF p_bill_rate_override_tbl.EXISTS(i) THEN
                        pa_debug.g_err_stage:='p_bill_rate_override_tbl('||i||') is '||p_bill_rate_override_tbl(i);
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    ELSE
                        pa_debug.g_err_stage:='p_bill_rate_override_tbl('||i||') does not exist ';
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    END IF;
                    --dbms_output.put_line( pa_debug.g_err_stage);

                    pa_debug.g_err_stage:='l_rlm_id_change_flag_tbl('||i||') is '||l_rlm_id_change_flag_tbl(i);
                    print_msg(pa_debug.g_err_stage,l_module_name);
                    --dbms_output.put_line( pa_debug.g_err_stage);
                    pa_debug.g_err_stage:='l_mfc_cost_type_id_old_tbl('||i||') is '||l_mfc_cost_type_id_old_tbl(i);
                    print_msg(pa_debug.g_err_stage,l_module_name);
                    --dbms_output.put_line( pa_debug.g_err_stage);
                    pa_debug.g_err_stage:='l_mfc_cost_type_id_new_tbl('||i||') is '||l_mfc_cost_type_id_new_tbl(i);
                    print_msg(pa_debug.g_err_stage,l_module_name);
                    --dbms_output.put_line( pa_debug.g_err_stage);
                    pa_debug.g_err_stage:='l_spread_curve_id_old_tbl('||i||') is '||l_spread_curve_id_old_tbl(i);
                    print_msg(pa_debug.g_err_stage,l_module_name);
                    --dbms_output.put_line( pa_debug.g_err_stage);
                    pa_debug.g_err_stage:='l_spread_curve_id_new_tbl('||i||') is '||l_spread_curve_id_new_tbl(i);
                    print_msg(pa_debug.g_err_stage,l_module_name);
                    --dbms_output.put_line( pa_debug.g_err_stage);
                    pa_debug.g_err_stage:='l_sp_fixed_date_old_tbl('||i||') is '||l_sp_fixed_date_old_tbl(i);
                    print_msg(pa_debug.g_err_stage,l_module_name);
                    --dbms_output.put_line( pa_debug.g_err_stage);
                    if l_sp_fixed_date_new_tbl(i) = fnd_api.g_miss_date then
                        pa_debug.g_err_stage:='l_sp_fixed_date_new_tbl('||i||') is g miss date';
                    else
                        pa_debug.g_err_stage:='l_sp_fixed_date_new_tbl('||i||') is '||l_sp_fixed_date_new_tbl(i);
                    end if;
                    print_msg(pa_debug.g_err_stage,l_module_name);
                    --dbms_output.put_line( pa_debug.g_err_stage);
                    pa_debug.g_err_stage:='l_plan_start_date_old_tbl('||i||') is '||l_plan_start_date_old_tbl(i);
                    print_msg(pa_debug.g_err_stage,l_module_name);
                    --dbms_output.put_line( pa_debug.g_err_stage);
                    if l_plan_start_date_new_tbl(i) = fnd_api.g_miss_date then
                        pa_debug.g_err_stage:='l_plan_start_date_new_tbl('||i||') is g miss date';
                    else
                        pa_debug.g_err_stage:='l_plan_start_date_new_tbl('||i||') is '||l_plan_start_date_new_tbl(i);
                    end if;
                    print_msg(pa_debug.g_err_stage,l_module_name);
                    --dbms_output.put_line( pa_debug.g_err_stage);
                    pa_debug.g_err_stage:='l_plan_end_date_old_tbl('||i||') is '||l_plan_end_date_old_tbl(i);
                    print_msg(pa_debug.g_err_stage,l_module_name);
                    --dbms_output.put_line( pa_debug.g_err_stage);
                    if l_plan_end_date_new_tbl(i) = fnd_api.g_miss_date then
                        pa_debug.g_err_stage:='l_plan_end_date_new_tbl('||i||') is g miss date';
                    else
                        pa_debug.g_err_stage:='l_plan_end_date_new_tbl('||i||') is '||l_plan_end_date_new_tbl(i);
                    end if;
                    print_msg(pa_debug.g_err_stage,l_module_name);
                    --dbms_output.put_line( pa_debug.g_err_stage);

                END LOOP;
            END IF;
       END IF;

--dbms_output.put_line('l_resource_assignment_id_tbl(1) is '||l_resource_assignment_id_tbl(1));
--dbms_output.put_line('l_currency_code_tbl(1) is '||l_currency_code_tbl(1));
--dbms_output.put_line('l_override_currency_code_tbl(1) is '||l_override_currency_code_tbl(1));
--dbms_output.put_line('l_total_quantity_tbl(1) is '||l_total_quantity_tbl(1));
--dbms_output.put_line('l_total_raw_cost_tbl(1) is '||l_total_raw_cost_tbl(1));
--dbms_output.put_line('l_burdened_cost_tbl(1) is '||l_burdened_cost_tbl(1));
--dbms_output.put_line('l_revenue_tbl(1) is '||l_revenue_tbl(1));
--dbms_output.put_line('l_raw_cost_rate_tbl(1) is '||l_raw_cost_rate_tbl(1));
--dbms_output.put_line('l_cost_rate_override_tbl(1) is '||l_cost_rate_override_tbl(1));
--dbms_output.put_line('l_b_multiplier_tbl cnt is '||l_b_multiplier_tbl.count);
--dbms_output.put_line('l_b_multiplier_tbl(1) is '||l_b_multiplier_tbl(1));
--dbms_output.put_line('l_burdened_rate_override_tbl cnt is '||l_burdened_rate_override_tbl.count);
--dbms_output.put_line('l_burdened_rate_override_tbl(1) is '||l_burdened_rate_override_tbl(1));
--dbms_output.put_line('l_bill_rate_tbl(1) is '||l_bill_rate_tbl(1));
--dbms_output.put_line('l_bill_rate_override_tbl(1) is '||l_bill_rate_override_tbl(1));

--dbms_output.put_line('quantity passed to calc is'||l_total_quantity_tbl(1));
--dbms_output.put_line('Calling calc api');

      -- If condition added for Bug 5906826
      IF l_cal_api_called_flg = 'N' THEN

        PA_FP_CALC_PLAN_PKG.calculate(
          p_project_id                 =>   l_project_id
         ,p_budget_version_id          =>   l_budget_version_id
         --,p_refresh_rates_flag         =>   'N' --need to pass any variables that are passed from calling API
         --,p_refresh_conv_rates_flag    =>   'N' --need to pass any variables that are passed from calling API
         --,p_spread_required_flag       =>   'N'
         --,p_conv_rates_required_flag   =>   'N'
         ,p_source_context             =>   PA_FP_CONSTANTS_PKG.G_CALC_API_RESOURCE_CONTEXT
         ,p_resource_assignment_tab    =>   l_resource_assignment_id_tbl
         ,p_txn_currency_code_tab      =>   l_currency_code_tbl
         ,p_txn_currency_override_tab  =>   l_override_currency_code_tbl
         ,p_total_qty_tab              =>   l_total_quantity_tbl
         ,p_total_raw_cost_tab         =>   l_total_raw_cost_tbl
         ,p_total_burdened_cost_tab    =>   l_burdened_cost_tbl
         ,p_total_revenue_tab          =>   l_revenue_tbl
         ,p_raw_cost_rate_tab          =>   l_raw_cost_rate_tbl
         ,p_rw_cost_rate_override_tab  =>   l_cost_rate_override_tbl
         ,p_b_cost_rate_tab            =>   l_b_multiplier_tbl
         ,p_b_cost_rate_override_tab   =>   l_burdened_rate_override_tbl
         ,p_bill_rate_tab              =>   l_bill_rate_tbl
         ,p_bill_rate_override_tab     =>   l_bill_rate_override_tbl
         ,p_line_start_date_tab        =>   SYSTEM.PA_DATE_TBL_TYPE()
         ,p_line_end_date_tab          =>   SYSTEM.PA_DATE_TBL_TYPE()
         ,p_apply_progress_flag        =>   p_apply_progress_flag /* Passed by apply_progress api (sakthi's team) */
         --Added for Bug 4152749
         ,p_mfc_cost_type_id_old_tab   =>   l_mfc_cost_type_id_old_tbl
         ,p_mfc_cost_type_id_new_tab   =>   l_mfc_cost_type_id_new_tbl
         ,p_spread_curve_id_old_tab    =>   l_spread_curve_id_old_tbl
         ,p_spread_curve_id_new_tab    =>   l_spread_curve_id_new_tbl
         ,p_sp_fixed_date_old_tab      =>   l_sp_fixed_date_old_tbl
         ,p_sp_fixed_date_new_tab      =>   l_sp_fixed_date_new_tbl
         ,p_plan_start_date_old_tab    =>   l_plan_start_date_old_tbl
         ,p_plan_start_date_new_tab    =>   l_plan_start_date_new_tbl
         ,p_plan_end_date_old_tab      =>   l_plan_end_date_old_tbl
         ,p_plan_end_date_new_tab      =>   l_plan_end_date_new_tbl
         ,p_rlm_id_change_flag_tab     =>   l_rlm_id_change_flag_tbl
         ,p_rollup_required_flag       =>   l_pji_rollup_required   --Bug 4200168
         --End of parameters for Bug 4152749
         ,x_return_status              =>   x_return_status
         ,x_msg_count                  =>   x_msg_count
         ,x_msg_data                   =>   x_msg_data);

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

             IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Called API PA_FP_CALC_PLAN_PKG.calculate returned error';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
             END IF;
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;

      END IF; -- If condition added for Bug 5906826

    -- IPM changes - rollup amounts in new entity

    -- Call the UTIL API to get the financial plan info l_fp_cols_rec

    pa_fp_gen_amount_utils.get_plan_version_dtls
        (p_project_id         => l_project_id,
         p_budget_version_id  => l_budget_version_id,
         x_fp_cols_rec        => l_fp_cols_rec,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Called API pa_fp_gen_amount_utils.get_plan_version_dtls returned error';
          pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
       END IF;
       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;


    --Enc changes
     l_direct_expenditure_type_tbl.extend(l_resource_assignment_id_tbl.count);

    /*Update exp type for the transaction in pa_resource_asgn_curr */

           IF l_resource_assignment_id_tbl.COUNT > 0 THEN
            FORALL i IN 1 .. l_resource_assignment_id_tbl.COUNT
              update pa_resource_asgn_curr
              set expenditure_type=l_direct_expenditure_type_tbl(i)
              where resource_assignment_id= l_resource_assignment_id_tbl(i)
              and  txn_currency_code=l_currency_code_tbl(i);
        END IF;
        /*end Enc */
    -- IPM changes - populate tmp table to use for update later
    /*
    IF l_resource_assignment_id_tbl.COUNT > 0 THEN
       FORALL i IN l_resource_assignment_id_tbl.first ..
                   l_resource_assignment_id_tbl.last
          INSERT INTO pa_resource_asgn_curr_tmp
             (RA_TXN_ID
             ,RESOURCE_ASSIGNMENT_ID
             ,TXN_CURRENCY_CODE
             ,DELETE_FLAG
             )
          SELECT pa_resource_asgn_curr_s.nextval
                ,l_resource_assignment_id_tbl(i)
                ,l_currency_code_tbl(i)
                ,NULL
            FROM DUAL;
    END IF;

    pa_res_asg_currency_pub.maintain_data(
         p_fp_cols_rec                  => l_fp_cols_rec,
         p_calling_module               => 'UPDATE_PLAN_TRANSACTION',
         p_delete_flag                  => 'N',
         p_copy_flag                    => 'N',
         p_src_version_id               => NULL,
         p_copy_mode                    => NULL,
         p_rollup_flag                  => 'Y',
         p_version_level_flag           => 'N',
         p_called_mode                  => 'SELF_SERVICE',
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data
         );

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

             IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Called API pa_res_asg_currency_pub.maintain_data returned error';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
             END IF;
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;
	*/

-- Added for bug 4492493

        IF (p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN
           AND PA_TASK_ASSIGNMENT_UTILS.Is_Progress_Rollup_Required(l_project_id) = 'Y') OR
           (p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK
            AND pa_task_assignment_utils.g_require_progress_rollup = 'Y') THEN

             PA_PROJ_TASK_STRUC_PUB.PROCESS_WBS_UPDATES_WRP
                ( p_calling_context       =>   'ASGMT_PLAN_CHANGE'
                 ,p_project_id            =>   l_project_id
                 ,p_structure_version_id   =>  p_struct_elem_version_id
                 ,p_pub_struc_ver_id      =>   p_struct_elem_version_id
                 ,x_return_status         =>   x_return_status
                 ,x_msg_count             =>   x_msg_count
                 ,x_msg_data              =>   x_msg_data);

             pa_task_assignment_utils.g_require_progress_rollup := 'N';
        END IF;


        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Called API PA_PROJ_TASK_STRUC_PUB.process_wbs_updates_wrp';
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.update_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
--End bug 4492493

       IF l_debug_mode = 'Y' THEN
             pa_debug.reset_curr_function;
       END IF;

EXCEPTION
     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
           IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:='In invalid args exception';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
           END IF;

           l_msg_count := FND_MSG_PUB.count_msg;
             IF l_msg_count = 1 THEN

                 IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:='In invalid args exception 1';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                 END IF;

                PA_INTERFACE_UTILS_PUB.get_messages
                     ( p_encoded        => FND_API.G_TRUE
                      ,p_msg_index      => 1
                      ,p_msg_count      => l_msg_count
                      ,p_msg_data       => l_msg_data
                      ,p_data           => l_data
                      ,p_msg_index_out  => l_msg_index_out);
                x_msg_data  := l_data;
                x_msg_count := l_msg_count;
             ELSE
                 IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:='In invalid args exception 2';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                 END IF;

                x_msg_count := l_msg_count;

             END IF;
           ROLLBACK TO Update_Planning_Transactions;
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='In invalid args exception 3';
               pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
               pa_debug.reset_curr_function;
           END IF;
           IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:='In invalid args exception 4    ';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
           END IF;


     WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FP_PLANNING_TRANSACTION_PUB'
                                  ,p_procedure_name  => 'Update_Planning_Transactions');

          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Unexpected Error' || SQLERRM;
               pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
               pa_debug.reset_curr_function;
          END IF;
          ROLLBACK TO Update_Planning_Transactions;

          RAISE;
END Update_Planning_Transactions;


/*This procedure should be called to copy planning transactions
  valid values for p_context are  'WORKPLAN' and 'TASK_ASSIGNMENT'
  valid values for p_copy_amt_qty are 'Y' and 'N'

  The parameters
      p_copy_people_flag
      p_copy_equip_flag
      p_copy_mat_item_flag
      p_copy_fin_elem_flag
  will be used only when the p_context is TASK_ASSIGNMENT.
  Irrespective of the context in which the API is called,
  the p_src_targ_version_id_tbl should never be empty.
  The other parameters can be derived based on the values
  in p_src_targ_version_id_tbl table.

  Bug 3615617 Copy External Tasks development changes
      validate_copy_assignment api returns target rlm id for target
      resource assignment id as part of the output record table. This
      should be passed to create_res_task_maps api as input.
*/
PROCEDURE copy_planning_transactions
(
       p_context                   IN   VARCHAR2
      ,p_copy_external_flag        IN   VARCHAR2
      ,p_src_project_id            IN   pa_projects_all.project_id%TYPE
      ,p_target_project_id         IN   pa_projects_all.project_id%TYPE
      ,p_src_budget_version_id     IN   pa_budget_versions.budget_version_id%TYPE DEFAULT NULL
      ,p_targ_budget_version_id    IN   pa_budget_versions.budget_version_id%TYPE DEFAULT NULL
      ,p_src_version_id_tbl        IN   SYSTEM.PA_NUM_TBL_TYPE
      ,p_targ_version_id_tbl       IN   SYSTEM.PA_NUM_TBL_TYPE
      ,p_copy_people_flag          IN   VARCHAR2                        := NULL
      ,p_copy_equip_flag           IN   VARCHAR2                        := NULL
      ,p_copy_mat_item_flag        IN   VARCHAR2                        := NULL
      ,p_copy_fin_elem_flag        IN   VARCHAR2                        := NULL
--     Added this field p_pji_rollup_required for the 4200168
      ,p_pji_rollup_required      IN   VARCHAR2                     DEFAULT 'Y'
      ,x_return_status             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_msg_count                 OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,x_msg_data                  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

) IS
    --Start of variables used for debugging
    l_return_status                            VARCHAR2(1);
    l_msg_count                                NUMBER := 0;
    l_msg_data                                 VARCHAR2(2000);
    l_data                                     VARCHAR2(2000);
    l_msg_index_out                            NUMBER;
    l_debug_mode                               VARCHAR2(30);
    l_debug_level3                    CONSTANT NUMBER :=3;
    l_debug_level5                    CONSTANT NUMBER :=5;
    --End of variables used for debugging
    l_adj_percent                              NUMBER;
    i                                          NUMBER;
    j                                          NUMBER;
    l_row_count                                NUMBER;
    l_src_budget_version_id                    pa_budget_versions.budget_version_id%TYPE;
    l_targ_budget_version_id                   pa_budget_versions.budget_version_id%TYPE;
    l_ra_id_tbl                                SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    l_project_assignment_id_tbl                SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    l_temp_ra_id_tbl                           SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    l_calc_ra_id_tbl                           SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    l_temp_proj_assmt_id_tbl                   SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    l_temp_planning_start_date_tbl             SYSTEM.PA_DATE_TBL_TYPE:= SYSTEM.PA_DATE_TBL_TYPE();
    l_temp_planning_end_date_tbl               SYSTEM.PA_DATE_TBL_TYPE:= SYSTEM.PA_DATE_TBL_TYPE() ;
    l_quantity_tbl                             SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    l_currency_code_tbl                        SYSTEM.PA_VARCHAR2_15_TBL_TYPE := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
    l_module_name                              VARCHAR2(100):='pa.fp_planning_txn_pub.copy_planning_transactions';
    l_resource_rec_tbl                         PA_TASK_ASSIGNMENT_UTILS.l_resource_rec_tbl_type;
    l_planning_start_date_tbl                  SYSTEM.PA_DATE_TBL_TYPE:= SYSTEM.PA_DATE_TBL_TYPE();
    l_planning_end_date_tbl                    SYSTEM.PA_DATE_TBL_TYPE:= SYSTEM.PA_DATE_TBL_TYPE();
    l_schedule_start_date_tbl                  SYSTEM.PA_DATE_TBL_TYPE:= SYSTEM.PA_DATE_TBL_TYPE();
    l_schedule_end_date_tbl                    SYSTEM.PA_DATE_TBL_TYPE:= SYSTEM.PA_DATE_TBL_TYPE();
    l_calculate_flag                           VARCHAR2(1);
    l_projfunc_currency_code                   pa_projects_all.project_currency_code%TYPE;
    l_proj_curr_code                           pa_projects_all.projfunc_currency_code%TYPE;
    l_spread_amt_flag_tbl                      SYSTEM.PA_VARCHAR2_1_TBL_TYPE:= SYSTEM.PA_VARCHAR2_1_TBL_TYPE();

    -- Declared for Bug  3615617
    l_resource_list_member_id_tbl              SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();

    l_tot_rc_tbl                               SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    l_pji_rollup_required                     VARCHAR2(1);

    --Code addition   for bug#4200168 starts here.
    TYPE l_txn_curr_code_table IS TABLE OF PA_BUDGET_LINES.TXN_CURRENCY_CODE%type
    INDEX BY BINARY_INTEGER;

    l_txn_curr_code_tbl  l_txn_curr_code_table;

    l_proj_fp_options_id   pa_proj_fp_options.proj_fp_options_id%type;
    l_project_id           pa_proj_fp_options.project_id%type;
    l_fin_plan_type_id     pa_proj_fp_options.fin_plan_type_id%type;
    l_pc                   pa_projects_all.project_currency_code%type;
    l_pfc                  pa_projects_all.projfunc_currency_code%type;
    --Code addition   for bug#4200168 ends here.

    l_fp_cols_rec   pa_fp_gen_amount_utils.fp_cols; -- IPM
    l_resource_class_code        VARCHAR2(30);
    l_exp_type                   VARCHAR2(30);
    l_inv_item_id                NUMBER;
    l_res_rate_based_flag_tbl    SYSTEM.PA_VARCHAR2_1_TBL_TYPE:=SYSTEM.PA_VARCHAR2_1_TBL_TYPE();

    CURSOR c_calc_api_param_csr
    IS
    SELECT pfrmt.source_res_assignment_id
          ,pfrmt.target_res_assignment_id
    FROM   pa_fp_ra_map_tmp pfrmt;

    c_calc_api_param_rec                        c_calc_api_param_csr%ROWTYPE;

    l_rbs_diff_flag                             VARCHAR2(1);
    --Bug 4097749
    l_named_role_tbl                            SYSTEM.pa_varchar2_80_tbl_type:=SYSTEM.pa_varchar2_80_tbl_type();

BEGIN
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='In copy planning txn';
        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
    END IF;
--dbms_output.put_line('in copy plan txn1');
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SAVEPOINT copy_plan_txn;

--Added this if for the bug 4200168
    IF p_pji_rollup_required = 'Y' THEN
        l_pji_rollup_required := 'Y';
    ELSE
        l_pji_rollup_required := 'N';
    END IF;

    pa_task_assignment_utils.g_require_progress_rollup := 'N';


    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

    -- Set curr function
IF l_debug_mode = 'Y' THEN
    pa_debug.set_curr_function(
                p_function   =>'plan_txn_pub.copy_plan_txn'
               ,p_debug_mode => l_debug_mode );

        pa_debug.g_err_stage:='Validating input parameters';
        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
    END IF;

    IF p_src_version_id_tbl.count <> p_targ_version_id_tbl.count THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='No of elements in p_src_version_id_tbl is not same as p_targ_version_id_tbl';
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    --If the tables are empty then return
    IF p_src_version_id_tbl.count=0 THEN

        IF l_debug_mode = 'Y' THEN

            pa_debug.g_err_stage:='The input tables are empty' ;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
        pa_debug.reset_curr_function;
	END IF;
        RETURN;

    END IF;

    --Validate the input parameters
    IF p_context IS NULL OR
       p_src_project_id IS NULL OR
       p_target_project_id IS NULL THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='p_context is '||p_context;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
        END IF;

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='p_src_project_id is '||p_src_project_id;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
        END IF;

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='p_target_project_id is '||p_target_project_id;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;


    --Initialise the variables the should be passed as parameters in other APIs
    IF p_src_project_id<>p_target_project_id THEN
        l_adj_percent := 0.9999;
        l_targ_budget_version_id:=l_src_budget_version_id;
    ELSE
        l_adj_percent := 0;
    END IF;

    --If context is WORKPLAN call the TA Validation API with the required parameters
    IF p_context=PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN OR
       p_context=PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK    THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='The calling context is workplan / task assignment p_src_version_id_tbl(1) '||p_src_version_id_tbl(1);
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;
--dbms_output.put_line('in copy plan txn2');
        --Derive the plan version id for the source and target element version ids
        SELECT pbv.budget_version_id
        INTO   l_src_budget_version_id
        FROM   pa_struct_task_wbs_v pt,
               pa_budget_versions pbv
        WHERE  pbv.project_structure_version_id= pt.parent_structure_version_id
        AND    pt.element_version_id=p_src_version_id_tbl(1)
        AND    pbv.wp_version_flag='Y';

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='The calling context is workplan / task assignment p_targ_version_id_tbl(1) '||p_targ_version_id_tbl(1);
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;


   --dbms_output.put_line('in copy plan txn2.5');
        SELECT pbv.budget_version_id
        INTO   l_targ_budget_version_id
        FROM   pa_budget_versions pbv
              ,pa_struct_task_wbs_v pt
        WHERE  pt.element_version_id=p_targ_version_id_tbl(1)
        AND    pbv.project_structure_version_id=pt.parent_structure_version_id
        AND    pbv.wp_version_flag='Y';

        --CALL THE TA VALIDATION API
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='The calling context is workplan / task assignment';
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;
        --dbms_output.put_line('p_targ_version_id_tbl.count is '||p_targ_version_id_tbl.count);

        --This value will be used only when the x_calculate_flag of the below validate api is
        --returned as 'N'
        l_adj_percent := 0;

        --Added x_rbs_diff_flag for bug 3974569. This flag indicates that the the source/target resource assignments
        --being copied might not map to the same rbs_element_id. If this is passed as Y it means that
        ----> validate_copy_assignment has called RBS mapping API and
        ----> While copying the resource assignments rbs_element_id should be taken from pa_rbs_plans_out_tmp
         pa_task_assignment_utils.validate_copy_assignment
        (  p_copy_external_flag          => p_copy_external_flag --Included this parameter for bug 3841130
          ,p_src_project_id              => p_src_project_id
          ,p_target_project_id           => p_target_project_id
          ,p_src_elem_ver_id_tbl         => p_src_version_id_tbl
          ,p_targ_elem_ver_id_tbl        => p_targ_version_id_tbl
          ,p_copy_people_flag            => p_copy_people_flag
          ,p_copy_equip_flag             => p_copy_equip_flag
          ,p_copy_mat_item_flag          => p_copy_mat_item_flag
          ,p_copy_fin_elem_flag          => p_copy_fin_elem_flag
          ,x_resource_rec_tbl            => l_resource_rec_tbl
          ,x_calculate_flag              => l_calculate_flag
          ,x_rbs_diff_flag               => l_rbs_diff_flag
          ,x_return_status               => x_return_status);

        --dbms_output.put_line('l_resource_rec_tbl.count is '||l_resource_rec_tbl.count);
        --dbms_output.put_line('l_resource_rec_tbl.count is '||l_resource_rec_tbl(1).planning_start_date);
        --dbms_output.put_line('l_resource_rec_tbl.count is '||l_resource_rec_tbl(1).planning_end_date);
        --dbms_output.put_line('l_calculate_flag is '||l_calculate_flag);
        --This code is for debugging only. Should be removed later
        IF l_debug_mode = 'Y' THEN

            pa_debug.g_err_stage:='validate_copy_assignment returned error '||x_return_status;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

        END IF;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            IF l_debug_mode = 'Y' THEN

                pa_debug.g_err_stage:='validate_copy_assignment returned error';
                pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

            END IF;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

        END IF;

        IF  l_resource_rec_tbl.COUNT =0 THEN
            IF l_debug_mode = 'Y' THEN

                pa_debug.g_err_stage:='Validate API returned 0 records in the res rec table-- returning';
                pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
            pa_debug.reset_curr_function;
	END IF;
            RETURN;
        END IF;

        --Extend the pl/sql tables
        l_ra_id_tbl.extend(l_resource_rec_tbl.last);
        l_planning_start_date_tbl.extend(l_resource_rec_tbl.last);
        l_planning_end_date_tbl.extend(l_resource_rec_tbl.last);
        l_schedule_start_date_tbl.extend(l_resource_rec_tbl.last);
        l_schedule_end_date_tbl.extend(l_resource_rec_tbl.last);
        l_project_assignment_id_tbl.extend(l_resource_rec_tbl.last);
        l_resource_list_member_id_tbl.extend(l_resource_rec_tbl.last);     -- Bug  3615617
        --Bug 4097749
        l_named_role_tbl.extend(l_resource_rec_tbl.last);

        --Copy the records from pl/sql table to local pl/sql tbls
        FOR i IN l_resource_rec_tbl.first..l_resource_rec_tbl.last LOOP

            l_ra_id_tbl(i):=l_resource_rec_tbl(i).resource_assignment_id;
            l_planning_start_date_tbl(i):=l_resource_rec_tbl(i).planning_start_date;
            l_planning_end_date_tbl(i):=l_resource_rec_tbl(i).planning_end_date;
            l_schedule_start_date_tbl(i):=l_resource_rec_tbl(i).schedule_start_date;
            l_schedule_end_date_tbl(i):=l_resource_rec_tbl(i).schedule_end_date;
            l_project_assignment_id_tbl(i):=l_resource_rec_tbl(i).project_assignment_id;
            l_resource_list_member_id_tbl(i):=l_resource_rec_tbl(i).resource_list_member_id; -- Bug  3615617
            --Bug 4097749
            l_named_role_tbl(i):=l_resource_rec_tbl(i).named_role;

        END LOOP;

    END IF;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Calling pa_fp_copy_from_pkg.create_res_task_maps '||l_ra_id_tbl.last;
        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
    END IF;
--dbms_output.put_line('calling create res task maps');

    --Call the API to create the mapping between source and target version ids.
      pa_fp_copy_from_pkg.create_res_task_maps(
      p_context                => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN
     ,p_src_ra_id_tbl          => l_ra_id_tbl
     ,p_src_elem_ver_id_tbl    => p_src_version_id_tbl
     ,p_targ_elem_ver_id_tbl   => p_targ_version_id_tbl
     ,p_targ_proj_assmt_id_tbl => l_project_assignment_id_tbl
     ,p_targ_rlm_id_tbl        => l_resource_list_member_id_tbl -- Bug 3615617
     ,p_planning_start_date_tbl=> l_planning_start_date_tbl
     ,p_planning_end_date_tbl  => l_planning_end_date_tbl
     ,p_schedule_start_date_tbl=> l_schedule_start_date_tbl
     ,p_schedule_end_date_tbl  => l_schedule_end_date_tbl
     ,x_return_status          => x_return_status
     ,x_msg_count              => x_msg_count
     ,x_msg_data               => x_msg_data);



    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

        IF l_debug_mode = 'Y' THEN

            pa_debug.g_err_stage:='create_res_task_maps returned error';
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

        END IF;
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;


    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Calling PA_FP_COPY_FROM_PKG.Copy_Resource_Assignments';
        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
    END IF;

--dbms_output.put_line('calling copy res assmts S '||l_src_budget_version_id ||' T '||l_targ_budget_version_id );
    --Call the API to copy the resource assignments for the target version
    PA_FP_COPY_FROM_PKG.Copy_Resource_Assignments(
        p_source_plan_version_id  => l_src_budget_version_id
        ,p_target_plan_version_id => l_targ_budget_version_id
        ,p_adj_percentage         => l_adj_percent
        ,p_rbs_map_diff_flag      => l_rbs_diff_flag --For Bug 3974569
        --Bug 4200168
        ,p_calling_context         => 'WORKPLAN'
        ,x_return_status          => x_return_status
        ,x_msg_count              => x_msg_count
        ,x_msg_data               => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

        IF l_debug_mode = 'Y' THEN

            pa_debug.g_err_stage:='Copy_Resource_Assignments returned error';
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

        END IF;
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    -- IPM changes - rollup amounts in new entity
    -- Call the UTIL API to get the financial plan info l_fp_cols_rec
    -- Bug 5070740 - moved this to rollup into entity BEFORE calling calculate

    pa_fp_gen_amount_utils.get_plan_version_dtls
        (p_project_id         => p_target_project_id,
         p_budget_version_id  => l_targ_budget_version_id,
         x_fp_cols_rec        => l_fp_cols_rec,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Called API pa_fp_gen_amount_utils.get_plan_version_dtls returned error';
          print_msg(pa_debug.g_err_stage,l_module_name);
       END IF;
       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF l_calculate_flag = 'Y' then

      -- IPM changes - populate tmp table to use for rollup
      -- Bug 5034507: Delete temp table before inserting new records
      DELETE pa_resource_asgn_curr_tmp;

      -- For bug 5017855, ensure that the combinations of
      -- (resource_assignment_id, txn_currency_code) are distinct.
      -- Bug 5042399: Copy Source override rates to the temp table for Target resources.
      -- Bug 5070740: Need to copy override rates before calculate is called
      INSERT INTO pa_resource_asgn_curr_tmp (
        RESOURCE_ASSIGNMENT_ID,
        TXN_CURRENCY_CODE,
        TXN_RAW_COST_RATE_OVERRIDE,
        TXN_BURDEN_COST_RATE_OVERRIDE,
        TXN_BILL_RATE_OVERRIDE )
      SELECT DISTINCT
           ra.RESOURCE_ASSIGNMENT_ID,
           src_rbc.txn_currency_code,
           src_rbc.TXN_RAW_COST_RATE_OVERRIDE,
           src_rbc.TXN_BURDEN_COST_RATE_OVERRIDE,
           src_rbc.TXN_BILL_RATE_OVERRIDE
      FROM   pa_resource_asgn_curr src_rbc,
           pa_fp_ra_map_tmp map,
           --pa_budget_lines bl
           pa_resource_assignments ra
      WHERE  ra.budget_version_id =l_targ_budget_version_id
--      AND    src_rbc.budget_version_id = l_src_budget_version_id
      AND    map.target_res_assignment_id = ra.resource_assignment_id
      AND    src_rbc.resource_assignment_id = map.source_res_assignment_id;
--      AND    src_rbc.txn_currency_code = bl.txn_currency_code;

      -- Call maintain_data to copy override rates before calling calculate
      pa_res_asg_currency_pub.maintain_data(
         p_fp_cols_rec                  => l_fp_cols_rec,
         p_calling_module               => 'UPDATE_PLAN_TRANSACTION',
         p_rollup_flag                  => 'N',
         p_version_level_flag           => 'N',
         p_called_mode                  => 'SELF_SERVICE',
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data
         );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

             IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Called API pa_res_asg_currency_pub.maintain_data returned error';
                   print_msg(pa_debug.g_err_stage,l_module_name);
             END IF;
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;
      -- END Bug  5070740

        --Bug 4097749. Update the resource assigments created above with the named_role attribute returned by
        --the TA validate API
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='About to update named role/parent assignment id in pa_resource_assignments';
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;

        --Bug 4215676 . Modified the  update sql for performance issues.
        --The parent assignment id should  be NULLED out.Please see the comment on exaclty similar DML UPDATE below

        -- IPM - get resource rate based flag
        l_res_rate_based_flag_tbl.extend(l_ra_id_tbl.last);
        FOR i IN 1..l_ra_id_tbl.COUNT LOOP
              SELECT rlm.resource_class_code, rlm.inventory_item_id,
                     rlm.expenditure_type
                INTO l_resource_class_code, l_inv_item_id, l_exp_type
                FROM pa_resource_list_members rlm,
                     pa_resource_assignments ra
               WHERE ra.resource_assignment_id = l_ra_id_tbl(i)
                 AND ra.resource_list_member_id = rlm.resource_list_member_id;

              IF l_resource_class_code IN ('PEOPLE', 'EQUIPMENT') THEN
                 l_res_rate_based_flag_tbl(i) := 'Y';
              ELSIF l_resource_class_code = 'MATERIAL_ITEMS' AND
                    l_inv_item_id IS NOT NULL THEN
                    BEGIN
                    SELECT 'Y'
                      INTO l_res_rate_based_flag_tbl(i)
                      FROM DUAL
                      WHERE NOT EXISTS (select 'Y'
                         from mtl_system_items_b item,
                              mtl_units_of_measure meas
                        where item.inventory_item_id = l_inv_item_id
                          and item.primary_uom_code = meas.uom_code
                          and meas.uom_class = 'Currency');
                    EXCEPTION WHEN OTHERS THEN
                       l_res_rate_based_flag_tbl(i) := 'N';
                    END;
              ELSIF l_resource_class_code in ('MATERIAL_ITEMS',
                                              'FINANCIAL_ELEMENTS') AND
                    l_inv_item_id IS NULL AND l_exp_type IS NOT NULL THEN
                    BEGIN
                    SELECT c.cost_rate_flag
                      INTO l_res_rate_based_flag_tbl(i)
                      FROM pa_expenditure_types c
                     WHERE c.expenditure_type = l_exp_type;
                    EXCEPTION WHEN OTHERS THEN
                       l_res_rate_based_flag_tbl(i) := 'N';
                    END;
              END IF;
        END LOOP;
        FORALL i IN 1..l_ra_id_tbl.COUNT
              UPDATE pa_resource_assignments
              SET    named_role = l_named_role_tbl(i),
                     parent_assignment_id=NULL,
		     /* bug fix:5135927 : Added nvl for l_res_rate_base_flag */
                     resource_rate_based_flag =NVL(l_res_rate_based_flag_tbl(i),'N')--IPM
              WHERE  parent_assignment_id = l_ra_id_tbl(i)
              AND    budget_version_id = l_targ_budget_version_id;

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Done with updating named role/parent assignment id in pa_resource_assignments';
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;


        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Calling Calculate API';
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;
        --dbms_output.put_line('in cal=y');

        pa_budget_utils.Get_Project_Currency_Info
        (  p_project_id            => p_target_project_id
         , x_projfunc_currency_code => l_projfunc_currency_code
         , x_project_currency_code  => l_proj_curr_code
         , x_txn_currency_code     => l_projfunc_currency_code
         , x_msg_count             => x_msg_count
         , x_msg_data              => x_msg_data
         , x_return_status          => x_return_status);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Cpa_budget_utils.Get_Project_Currency_Info returned error';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        i:=1;
        FOR c_calc_api_param_rec IN c_calc_api_param_csr LOOP

            --dbms_output.put_line (' i is '||i);
            IF NOT l_calc_ra_id_tbl.EXISTS(i) THEN
                l_quantity_tbl.extend(1);
                l_tot_rc_tbl.extend(1);
                l_currency_code_tbl.extend(1);
                l_calc_ra_id_tbl.extend(1);
                l_spread_amt_flag_tbl.extend(1);
            END IF;
            -- Select the quantity for the resource assignment and the txn currency code. Note that
            -- for task assignments there will be only one currency code across all the budget lines
            -- in the ra id
            -- Changed the logic of populating quantity and raw cost to loop thru l_resource_rec_tbl
            -- instead of using tbls cached by ra id for bug 3678314
            FOR kk IN 1..l_resource_rec_tbl.COUNT LOOP

                IF c_calc_api_param_rec.source_res_assignment_id = l_resource_rec_tbl(kk).resource_assignment_id THEN

                    l_quantity_tbl(i):=l_resource_rec_tbl(kk).total_quantity;
                    l_tot_rc_tbl(i):=l_resource_rec_tbl(kk).total_raw_cost;
                    EXIT;

                END IF;

            END LOOP;

            l_calc_ra_id_tbl(i):=c_calc_api_param_rec.target_res_assignment_id;
            l_spread_amt_flag_tbl(i):='Y';

            BEGIN
                SELECT nvl(txn_currency_code,l_proj_curr_code)--For workplan txn curr code can be null
                INTO   l_currency_code_tbl(i)
                FROM   pa_budget_lines
                WHERE  resource_assignment_id=
                          c_calc_api_param_rec.source_res_assignment_id -- bug 3781932 l_calc_ra_id_tbl(i)
                AND    ROWNUM=1;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_currency_code_tbl(i):=l_proj_curr_code;
            END;
            i:=i+1;
         END LOOP;
         l_quantity_tbl.DELETE(i,l_quantity_tbl.count);
         l_tot_rc_tbl.DELETE(i,l_tot_rc_tbl.count);
         l_currency_code_tbl.DELETE(i,l_currency_code_tbl.count);
         l_calc_ra_id_tbl.DELETE(i,l_calc_ra_id_tbl.count);
         l_spread_amt_flag_tbl.DELETE(i,l_spread_amt_flag_tbl.count);
         --dbms_output.put_line('Calling the calculate api'||l_calc_ra_id_tbl.count);
                  --dbms_output.put_line('Calling the calculate api'||l_calc_ra_id_tbl(1));
                  --dbms_output.put_line('Calling the calculate api'||l_calc_ra_id_tbl(2));

         PA_FP_CALC_PLAN_PKG.calculate(
          p_project_id                 =>   p_target_project_id
         ,p_budget_version_id          =>   l_targ_budget_version_id
         --,p_refresh_rates_flag         =>   'N' --need to pass any variables that are passed from calling API
         --,p_refresh_conv_rates_flag    =>   'N' --need to pass any variables that are passed from calling API
         --,p_spread_required_flag       =>   'N'
         --,p_conv_rates_required_flag   =>   'N'
         ,p_source_context             =>   'RESOURCE_ASSIGNMENT'
         ,p_resource_assignment_tab    =>   l_calc_ra_id_tbl
         ,p_delete_budget_lines_tab    =>   SYSTEM.PA_VARCHAR2_1_TBL_TYPE()
         -- bug fix:5726773 ,p_spread_amts_flag_tab       =>   l_spread_amt_flag_tbl
         ,p_txn_currency_code_tab      =>   l_currency_code_tbl
         ,p_txn_currency_override_tab  =>   SYSTEM.PA_VARCHAR2_15_TBL_TYPE()
         ,p_total_qty_tab              =>   l_quantity_tbl
         ,p_total_raw_cost_tab         =>   l_tot_rc_tbl
         ,p_total_burdened_cost_tab    =>   SYSTEM.PA_NUM_TBL_TYPE()
         ,p_total_revenue_tab          =>   SYSTEM.PA_NUM_TBL_TYPE()
         ,p_raw_cost_rate_tab          =>   SYSTEM.PA_NUM_TBL_TYPE()
         ,p_rw_cost_rate_override_tab  =>   SYSTEM.PA_NUM_TBL_TYPE()
         ,p_b_cost_rate_tab            =>   SYSTEM.PA_NUM_TBL_TYPE()
         ,p_b_cost_rate_override_tab   =>   SYSTEM.PA_NUM_TBL_TYPE()
         ,p_bill_rate_tab              =>   SYSTEM.PA_NUM_TBL_TYPE()
         ,p_bill_rate_override_tab     =>   SYSTEM.PA_NUM_TBL_TYPE()
         ,p_line_start_date_tab        =>   SYSTEM.PA_DATE_TBL_TYPE()
         ,p_line_end_date_tab          =>   SYSTEM.PA_DATE_TBL_TYPE()
         ,p_rollup_required_flag       =>   l_pji_rollup_required
	 ,p_raTxn_rollup_api_call_flag =>   'N' -- Added for bug 5017855
         ,x_return_status              =>   x_return_status
         ,x_msg_count                  =>   x_msg_count
         ,x_msg_data                   =>   x_msg_data);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            IF l_debug_mode = 'Y' THEN

                pa_debug.g_err_stage:='PA_FP_CALC_PLAN_PKG.calculate returned error';
                pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

            END IF;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

        END IF;


    ELSE--Calculate Flag is N

        --dbms_output.put_line('in cal<>y');
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Calling PA_FP_COPY_FROM_PKG.Copy_Budget_Lines';
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;

        PA_FP_COPY_FROM_PKG.Copy_Budget_Lines(
         p_source_plan_version_id   => l_src_budget_version_id
        ,p_target_plan_version_id   => l_targ_budget_version_id
        ,p_adj_percentage           => l_adj_percent
        ,x_return_status            => x_return_status
        ,x_msg_count                => x_msg_count
        ,x_msg_data                 => x_msg_data);



        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            IF l_debug_mode = 'Y' THEN

                pa_debug.g_err_stage:='Copy_Budget_Lines returned error';
                pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

            END IF;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

        END IF;

        --Bug 4097749. Update the resource assigments created above with the named_role attribute returned by
        --the TA validate API
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='About to update named role/parent assignment id in pa_resource_assignments';
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;

        --Bug 4215676 . Modified the  update sql for performance issues.
        --The parent assignment id should  be NULLED out since (copy resource assignments copies the source
        --resource assignment to parent assignment id while copying the source to target)
        ---->Copy_Budget_Lines which is called above will consider all the resource assignments with Non Null
        ---->parent assignment id as candidates for copy. If parent_assignemt_id is not nulled out
        ---->then in future copy task flows the resource assignments which were are copied now will also be considered
        ---->as NEW and copy_budget_lines will try to insert them which will violate the unique constraint
        ---->on pa_budget_lines
        FORALL i IN 1..l_ra_id_tbl.COUNT
              UPDATE pa_resource_assignments
              SET    named_role = l_named_role_tbl(i),
                     parent_assignment_id=NULL
              WHERE  parent_assignment_id = l_ra_id_tbl(i)
              AND    budget_version_id = l_targ_budget_version_id;

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Done with updating named role/parent assignment id in pa_resource_assignments';
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;


         --Code changes for bug#4200168 starts here.
         --for the budget lines that get copied as a result of tasks copying,
         -- we need to ensure all the txn currencies are available in pa fp txn ccurrencies.
         IF p_src_project_id<>p_target_project_id THEN

            -- Bug 4872216 changes - performance fix to remove full table
            -- scan on PA_FP_TXN_CURRENCIES
		   SELECT DISTINCT BL.TXN_CURRENCY_CODE
		   BULK   COLLECT
		   INTO   l_txn_curr_code_tbl
		   FROM   PA_BUDGET_LINES BL
		   WHERE  BL.BUDGET_VERSION_ID = l_targ_budget_version_id
		   AND    NOT EXISTS
    			  (SELECT 1
	         	   FROM   PA_FP_TXN_CURRENCIES TC
                                 ,PA_PROJ_FP_OPTIONS pfo -- Bug 4872216
			   WHERE  tc.fin_plan_version_id =
                                           l_targ_budget_version_id
                           AND    pfo.project_id = p_target_project_id --4872216
                           AND    pfo.fin_plan_version_id =
                                            tc.fin_plan_version_id  --4872216
                           AND    pfo.proj_fp_options_id =
                                              tc.proj_fp_options_id --4872216
                           AND    TC.txn_currency_code = BL.txn_currency_code);

          select proj_fp_options_id, project_id, fin_plan_type_id
          INTO l_proj_fp_options_id, l_project_id, l_fin_plan_type_id
          from pa_proj_fp_options
          WHERE fin_plan_version_id = l_targ_budget_version_id;

          select project_currency_code, projfunc_currency_code
          INTO l_pc, l_pfc
          from pa_projects_all
          WHERE project_id = l_project_id;

          FORALL j IN 1..l_txn_curr_code_tbl.count
             INSERT INTO PA_FP_TXN_CURRENCIES
                  (
                      FP_TXN_CURRENCY_ID,
                      PROJ_FP_OPTIONS_ID,
                      PROJECT_ID,
                      FIN_PLAN_TYPE_ID,
                      FIN_PLAN_VERSION_ID,
                      TXN_CURRENCY_CODE,
                      DEFAULT_REV_CURR_FLAG,
                      DEFAULT_COST_CURR_FLAG,
                      DEFAULT_ALL_CURR_FLAG,
                      PROJECT_CURRENCY_FLAG,
                      PROJFUNC_CURRENCY_FLAG,
                      CREATION_DATE ,
                      CREATED_BY ,
                      LAST_UPDATE_LOGIN ,
                      LAST_UPDATED_BY ,
                      LAST_UPDATE_DATE
                  )
                  VALUES
                  (
                      PA_FP_TXN_CURRENCIES_S.NEXTVAL,
                      l_proj_fp_options_id ,
                      l_project_id,
                      l_fin_plan_type_id,
                      l_targ_budget_version_id,
                      l_txn_curr_code_tbl(j),
                      'N',
                      'N',
                      'N',
                      Decode(l_txn_curr_code_tbl(j),l_pc,'Y','N'),
                      Decode(l_txn_curr_code_tbl(j),l_pfc,'Y','N'),
                      sysdate,
                      fnd_global.user_id,
                      fnd_global.login_id,
                      fnd_global.user_id,
                      sysdate);

       END IF; -- End of if p_src_project_id<>p_target_project_id
       --Code changes for bug#4200168 ends here.

        --Call the multi currency conversion PKG if required i.e. if pc and pfc should be recalculated
        IF l_adj_percent <> 0 THEN
            PA_FP_MULTI_CURRENCY_PKG.convert_txn_currency (
                      p_budget_version_id   => l_targ_budget_version_id
                      ,p_entire_version     => 'Y'
                      ,x_return_status      => x_return_status
                      ,x_msg_count          => x_msg_count
                      ,x_msg_data           => x_msg_data );

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                IF l_debug_mode = 'Y' THEN

                    pa_debug.g_err_stage:='convert_txn_currency returned error';
                    pa_debug.write( l_module_name,pa_debug.g_err_stage,5);

                END IF;

                RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
            END IF;

        END IF;

        --Call the reportiong lines API. This can called unconditionally as the reporting lines should always be
        --created for Workplan and Task Assignments versions.

         --Added the if condition for the bug 4200168
      IF l_pji_rollup_required = 'Y' THEN

            PA_PLANNING_TRANSACTION_UTILS.call_update_rep_lines_api
            ( p_source                  => 'PA_FP_RA_MAP_TMP'
             ,p_budget_version_id       => l_targ_budget_version_id
             ,x_return_status           => x_return_status
             ,x_msg_data                => x_msg_data
             ,x_msg_count               => x_msg_count);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

              IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:='PA_PLANNING_TRANSACTION_UTILS.call_update_rep_lines_api returned error';
                  pa_debug.write( l_module_name,pa_debug.g_err_stage,5);
              END IF;
              RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
          END IF;

      END IF;

-- Added for bug 4492493, Updated for bug 5198662
        IF (p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN
            AND PA_TASK_ASSIGNMENT_UTILS.Is_Progress_Rollup_Required(p_target_project_id) = 'Y') OR
           (p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK
            AND pa_task_assignment_utils.g_require_progress_rollup = 'Y') THEN

             PA_PROJ_TASK_STRUC_PUB.PROCESS_WBS_UPDATES_WRP
                ( p_calling_context       => 'ASGMT_PLAN_CHANGE'
                 ,p_project_id              => p_target_project_id
                 ,p_structure_version_id   =>  pa_project_structure_utils.get_latest_wp_version(p_target_project_id)
                 ,p_pub_struc_ver_id      => pa_project_structure_utils.get_latest_wp_version(p_target_project_id)
                 ,x_return_status                =>     x_return_status
                 ,x_msg_data                     =>     x_msg_data
                 ,x_msg_count                    =>     x_msg_count    );

              pa_task_assignment_utils.g_require_progress_rollup := 'N';

        END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Called API PA_PROJ_TASK_STRUC_PUB.process_wbs_updates_wrp';
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.copy_planning_transactions: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
--End bug 4492493

    END IF;

    -- IPM changes - populate tmp table to use for rollup
    -- Bug 5034507: Delete temp table before inserting new records
    DELETE pa_resource_asgn_curr_tmp;

    -- For bug 5017855, ensure that the combinations of
    -- (resource_assignment_id, txn_currency_code) are distinct.
    -- Bug 5042399: Copy Source override rates to the temp table for Target resources.
    INSERT INTO pa_resource_asgn_curr_tmp (
        RESOURCE_ASSIGNMENT_ID,
        TXN_CURRENCY_CODE,
        TXN_RAW_COST_RATE_OVERRIDE,
        TXN_BURDEN_COST_RATE_OVERRIDE,
        TXN_BILL_RATE_OVERRIDE )
    SELECT DISTINCT
           ra.RESOURCE_ASSIGNMENT_ID,
           src_rbc.txn_currency_code,
           src_rbc.TXN_RAW_COST_RATE_OVERRIDE,
           src_rbc.TXN_BURDEN_COST_RATE_OVERRIDE,
           src_rbc.TXN_BILL_RATE_OVERRIDE
    FROM   pa_resource_asgn_curr src_rbc,
           pa_fp_ra_map_tmp map,
           --pa_budget_lines bl
           pa_resource_assignments ra
    WHERE  ra.budget_version_id =l_targ_budget_version_id
--    AND    src_rbc.budget_version_id = l_src_budget_version_id
    AND    map.target_res_assignment_id = ra.resource_assignment_id
    AND    src_rbc.resource_assignment_id = map.source_res_assignment_id;
--    AND    src_rbc.txn_currency_code = bl.txn_currency_code;

    -- Bug 5070740: In case Calculate is called, need to call maintain_data
    --    API again to rollup amounts; in case Calculate is not called, calling
    --    maintain data once in this flow to copy overrides and rollup amounts.
    pa_res_asg_currency_pub.maintain_data(
         p_fp_cols_rec                  => l_fp_cols_rec,
         p_calling_module               => 'UPDATE_PLAN_TRANSACTION',
         p_rollup_flag                  => 'Y',
         p_version_level_flag           => 'N',
         p_called_mode                  => 'SELF_SERVICE',
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data
         );

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

             IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Called API pa_res_asg_currency_pub.maintain_data returned error';
                   print_msg(pa_debug.g_err_stage,l_module_name);
             END IF;
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Exiting copy_planning_transactions';
        print_msg(pa_debug.g_err_stage,l_module_name);
    -- reset curr function
       pa_debug.reset_curr_function;
    END IF;
EXCEPTION

   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
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
       END IF;

       x_return_status := FND_API.G_RET_STS_ERROR;
       ROLLBACK TO copy_plan_txn;

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Invalid Arguments Passed Or called api raised an error';
           pa_debug.write( l_module_name,pa_debug.g_err_stage,5);
       -- reset curr function
          pa_debug.reset_curr_function;
       END IF;
       RETURN;
   WHEN Others THEN
       ROLLBACK TO copy_plan_txn;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'pa_fp_planning_transaction_pub'
                               ,p_procedure_name  => 'copy_planning_transactions');

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write( l_module_name,pa_debug.g_err_stage,5);
           pa_debug.Reset_Curr_Function();
       END IF;
       RAISE;
END copy_planning_transactions;



/*=====================================================================
Procedure Name:      delete_planning_transactions
Purpose:             This procedure should be called to delete planning
                     transactions
                     Valid values for p_context are 'BUDGET','FORECAST',
                     'WORKPLAN' and 'TASK_ASSIGNMENT'

                     Valid values for p_task_or_res are 'TASKS' and
                     'ASSIGNMENT'

                     In the context of 'TASK_ASSIGNMENT' the fields
                     task_number and task_name are required in
                     p_task_rec_tbl

                     If p_task_or_res is TASKS,
                     p_element_version_id_tbl,p_task_number_tbl,
                     p_task_name_tbl are used.

                     If p_task_or_res is ASSIGNMENT,
                     p_resource_assignment_tbl is used

               p_calling_module can be NULL or PROCESS_RES_CHG_DERV_CALC_PRMS. If passed as Y
               resource assignments will be  deleted otherwise they
                     will not be deleted.(Please note that budget lines will be deleted
                     always irrespective of the value for this parameter).
                     Please note that this parameter cannot be PROCESS_RES_CHG_DERV_CALC_PRMS
               when p_task_or_res is passed as TASKS
                 Whenever p_calling_module is passed as PROCESS_RES_CHG_DERV_CALC_PRMS,
               the parameters p_task_id_tbl,p_resource_class_code_tbl
               p_rbs_element_id_tbl and     p_rate_based_flag_tbl should ALSO be
               passed. These tbls must be equal in length to p_resource_assignment_tbl
                     and should contain the task id, rbs element id and rate based flag
                     for the resource assignment

  Bug - 3719918. New param p_currency_code_tbl is added below
  When p_context - Budget/Forecast and p_task_or_res is Assignment then only the bugdet lines
  Corresponding to currency code passed will be deleted. After deleting of the budget lines
  the corresponding RA will only we deleted if the budget line count is 0 from the RA.
  p_calling_module will be'EDIT_PLAN' when called from edit plan pages.

=======================================================================*/

PROCEDURE delete_planning_transactions
(
       p_context                      IN       VARCHAR2
      ,p_calling_context              IN       VARCHAR2 DEFAULT NULL    -- Added for Bug 6856934
      ,p_task_or_res                  IN       VARCHAR2 DEFAULT 'TASKS'
      ,p_element_version_id_tbl       IN       SYSTEM.PA_NUM_TBL_TYPE          DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_task_number_tbl              IN       SYSTEM.PA_VARCHAR2_240_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
      ,p_task_name_tbl                IN       SYSTEM.PA_VARCHAR2_240_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
      ,p_resource_assignment_tbl      IN       SYSTEM.PA_NUM_TBL_TYPE          DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      --Introduced for bug 3589130. If this parameter is passed as Y then an error will be thrown
      --When its required to delete a resource assignment containing budget lines. This parameter
      --will be considered only for BUDGET and FORECAST context
      ,p_validate_delete_flag         IN       VARCHAR2                        DEFAULT 'N'
      -- This param will be used for B/F Context. Bug - 3719918
      ,p_currency_code_tbl            IN       SYSTEM.PA_VARCHAR2_15_TBL_TYPE  DEFAULT SYSTEM.PA_VARCHAR2_15_TBL_TYPE()
      ,p_calling_module               IN       VARCHAR2                        DEFAULT NULL
      ,p_task_id_tbl                  IN       SYSTEM.PA_NUM_TBL_TYPE          DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_rbs_element_id_tbl           IN       SYSTEM.PA_NUM_TBL_TYPE          DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_rate_based_flag_tbl          IN       SYSTEM.PA_VARCHAR2_1_TBL_TYPE   DEFAULT SYSTEM.PA_VARCHAR2_1_TBL_TYPE()
      ,p_resource_class_code_tbl      IN       SYSTEM.PA_VARCHAR2_30_TBL_TYPE  DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      --For Bug 3937716. Calls to PJI and budget version rollup APIs will be skipped if p_rollup_required_flag is N.
      ,p_rollup_required_flag         IN       VARCHAR2                        DEFAULT 'Y'
      ,p_pji_rollup_required          IN       VARCHAR2                        DEFAULT 'Y' /* Bug 4200168 */
      ,x_return_status                OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_msg_count                    OUT      NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,x_msg_data                     OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
    --Start of variables used for debugging
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER := 0;
    l_msg_data                      VARCHAR2(2000);
    l_data                          VARCHAR2(2000);
    l_msg_index_out                 NUMBER;
    l_debug_mode                    VARCHAR2(30);
    --End of variables used for debugging

    l_module_name                   VARCHAR2(100):='PAFPPTPB.delete_planning_transactions';
    l_delete_task_flag_tbl          SYSTEM.PA_VARCHAR2_1_TBL_TYPE      := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
    l_delete_assmt_flag_tbl         SYSTEM.PA_VARCHAR2_1_TBL_TYPE      := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
    l_wp_version_flag               VARCHAR2(1);
    l_ta_display_flag               VARCHAR2(1);

    l_period_name_tbl               SYSTEM.pa_varchar2_30_tbl_type;
    l_start_date_tbl                SYSTEM.pa_date_tbl_type;
    l_end_date_tbl                  SYSTEM.pa_date_tbl_type;
    l_txn_currency_code_tbl         SYSTEM.pa_varchar2_15_tbl_type;
    l_txn_raw_cost_tbl              SYSTEM.pa_num_tbl_type;
    l_txn_burdened_cost_tbl         SYSTEM.pa_num_tbl_type;
    l_txn_revenue_tbl               SYSTEM.pa_num_tbl_type;
    l_project_raw_cost_tbl          SYSTEM.pa_num_tbl_type;
    l_project_burdened_cost_tbl     SYSTEM.pa_num_tbl_type;
    l_project_revenue_tbl           SYSTEM.pa_num_tbl_type;
    l_raw_cost_tbl                  SYSTEM.pa_num_tbl_type;
    l_burdened_cost_tbl             SYSTEM.pa_num_tbl_type;
    l_revenue_tbl                   SYSTEM.pa_num_tbl_type;
    l_cost_rejection_code_tbl       SYSTEM.pa_varchar2_30_tbl_type;
    l_revenue_rejection_code_tbl    SYSTEM.pa_varchar2_30_tbl_type;
    l_burden_rejection_code_tbl     SYSTEM.pa_varchar2_30_tbl_type;
    l_other_rejection_code          SYSTEM.pa_varchar2_30_tbl_type;
    l_pc_cur_conv_rej_code_tbl      SYSTEM.pa_varchar2_30_tbl_type;
    l_pfc_cur_conv_rej_code_tbl     SYSTEM.pa_varchar2_30_tbl_type;
    l_resource_assignment_id_tbl    SYSTEM.pa_num_tbl_type;
    l_quantity_tbl                  SYSTEM.pa_num_tbl_type;
    l_task_id_tbl                   SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_rbs_element_id_tbl            SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_res_class_code_tbl            SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
    l_rate_based_flag_tbl           SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
    l_task_id_in_pra_tbl            SYSTEM.pa_num_tbl_type;
    l_rbs_element_id_in_pra_tbl     SYSTEM.pa_num_tbl_type;
    l_res_class_code_in_pra_tbl     SYSTEM.pa_varchar2_30_tbl_type;
    l_rate_based_flag_in_pra_tbl    SYSTEM.pa_varchar2_1_tbl_type;
    l_ra_id_in_pra_tbl              SYSTEM.pa_num_tbl_type;
    --Bug 4951422
    l_task_assmt_ids_tbl            SYSTEM.pa_num_tbl_type;

    l_counter                       NUMBER;
    l_ra_index                      NUMBER;
    l_budget_version_id             pa_budget_versions.budget_version_id%TYPE;
    l_ci_id                         pa_budget_versions.ci_id%TYPE;
    l_exists                        VARCHAR2(1);
    SKIP_LOOP                       EXCEPTION;
    i                               NUMBER;
    l_cntr                          NUMBER;

    l_currency_code_tbl             SYSTEM.PA_VARCHAR2_15_TBL_TYPE      := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
    l_task_id                       PA_RESOURCE_ASSIGNMENTS.TASK_ID%TYPE;
    l_rbs_element_id                PA_RESOURCE_ASSIGNMENTS.RBS_ELEMENT_ID%TYPE;
    l_res_class_code                PA_RESOURCE_ASSIGNMENTS.RESOURCE_CLASS_CODE%TYPE;
    l_rate_based_flag               PA_RESOURCE_ASSIGNMENTS.RATE_BASED_FLAG%TYPE;
    l_mode                          varchar2(12) := null;   --Bug 4160258


    l_project_id                    pa_projects_all.project_id%TYPE;  --Bug 4218331
    l_project_currency_code         VARCHAR2(30);
    l_fp_cols_rec                   pa_fp_gen_amount_utils.fp_cols; -- IPM

BEGIN

    delete pa_resource_asgn_curr_tmp;
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    pa_task_assignment_utils.g_require_progress_rollup := 'N';

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'N');

    -- Set curr function
    IF l_debug_mode = 'Y' THEN
    	pa_debug.set_curr_function(
                p_function   =>'PA_FP_PLAN_TXN_PUB.delete_planning_transactions'
               ,p_debug_mode => l_debug_mode );
   END IF;

   IF l_debug_mode = 'Y' THEN
        /** printing all in params */
        pa_debug.g_err_stage := 'p_context=>'|| p_context||']p_task_or_res =>'||p_task_or_res||']';
        pa_debug.g_err_stage := pa_debug.g_err_stage||'p_validate_delete_flag=>'||p_validate_delete_flag||']';
        pa_debug.g_err_stage := pa_debug.g_err_stage||'p_calling_module=>'||p_calling_module||']';
        pa_debug.g_err_stage := pa_debug.g_err_stage||'RollupReqFlg=>'||p_rollup_required_flag||']';
        pa_debug.g_err_stage := pa_debug.g_err_stage||'PJiRollupFlg=>'||p_pji_rollup_required||']';
        pa_debug.g_err_stage := pa_debug.g_err_stage||'ElemVerTbCt['||p_element_version_id_tbl.count||']';
        pa_debug.g_err_stage := pa_debug.g_err_stage||'RaIdCt['||p_resource_assignment_tbl.count||']';
        pa_debug.g_err_stage := pa_debug.g_err_stage||'TaskIdCt['||p_task_id_tbl.count||']';
        pa_debug.g_err_stage := pa_debug.g_err_stage||'rbsElmCt['||p_rbs_element_id_tbl.count||']';
        print_msg(pa_debug.g_err_stage,l_module_name);
   End If;
   -------------------------------------------------------------------------------------------
   -- Extending all table lengths to the permissible values they would take.
   -------------------------------------------------------------------------------------------
     IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:='Extending all table lengths to the permissible values they would take';
	 print_msg(pa_debug.g_err_stage,l_module_name);
     END IF;

     IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:='Extending all table lengths to the permissible values they would take';
         print_msg(pa_debug.g_err_stage,l_module_name);
     END IF;

     IF p_element_version_id_tbl.COUNT > 0 THEN
         l_delete_task_flag_tbl.extend(p_element_version_id_tbl.LAST);
     END IF;

     IF p_resource_assignment_tbl.COUNT > 0 THEN
         l_delete_assmt_flag_tbl.extend(p_resource_assignment_tbl.LAST);
     END IF;

    ----------------------------------------------------
    -- Validating input parameters
    ----------------------------------------------------
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Validating input parameters';
	print_msg(pa_debug.g_err_stage,l_module_name);
    END IF;

    --Check for mandatory parameters
    IF p_context IS NULL OR
       p_task_or_res IS NULL THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='p_context Is'||p_context;
            pa_debug.g_err_stage:=pa_debug.g_err_stage||': p_task_or_res Is'||p_task_or_res;
	    print_msg(pa_debug.g_err_stage,l_module_name);
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF  p_task_or_res = 'TASKS' AND p_calling_module='PROCESS_RES_CHG_DERV_CALC_PRMS' THEN
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='calling module  is PROCESS_RES_CHG_DERV_CALC_PRMS when p_task_or_res  is TASKS';
	    print_msg(pa_debug.g_err_stage,l_module_name);
        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED',
                    p_token1        => 'PROCEDURENAME',
                    p_value1        => 'PAFPPTPB.Delete_planning_transactions');
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;
    -- Bug 3546208
    IF   ( p_task_or_res = 'TASKS'
       AND p_context in (PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET,
                         PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FORECAST)) THEN
       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='P_task_or_res is Task for B/F Context';
	  print_msg(pa_debug.g_err_stage,l_module_name);
       END IF;
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                            p_token1         => 'PROCEDURENAME',
                            p_value1         => 'PAFPPTPB.Delete_planning_transactions',
                            p_token2         => 'STAGE',
                            p_value2         => 'Invalid Data : B/F - TASK');
       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF p_calling_module='PROCESS_RES_CHG_DERV_CALC_PRMS' AND
     (p_task_id_tbl.COUNT <> p_resource_assignment_tbl.COUNT OR
      p_rbs_element_id_tbl.COUNT <> p_resource_assignment_tbl.COUNT OR
      p_rate_based_flag_tbl.COUNT <> p_resource_assignment_tbl.COUNT OR
        p_resource_class_code_tbl.COUNT <> p_resource_assignment_tbl.COUNT  ) THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='p_resource_assignment_tbl.COUNT  IS '||p_resource_assignment_tbl.COUNT ;
            print_msg(pa_debug.g_err_stage,l_module_name);

            pa_debug.g_err_stage:='p_task_id_tbl.COUNT IS '||p_task_id_tbl.COUNT ;
            print_msg(pa_debug.g_err_stage,l_module_name);

            pa_debug.g_err_stage:='p_rbs_element_id_tbl.COUNT IS '||p_rbs_element_id_tbl.COUNT ;
            print_msg(pa_debug.g_err_stage,l_module_name);

            pa_debug.g_err_stage:='p_rate_based_flag_tbl.COUNT IS '||p_rate_based_flag_tbl.COUNT ;
            print_msg(pa_debug.g_err_stage,l_module_name);

            pa_debug.g_err_stage:='p_resource_class_code_tbl.COUNT IS '||p_resource_class_code_tbl.COUNT ;
            print_msg(pa_debug.g_err_stage,l_module_name);

            pa_debug.g_err_stage:='p_resource_assignment_tbl.COUNT IS '||p_resource_assignment_tbl.COUNT ;
            print_msg(pa_debug.g_err_stage,l_module_name);

        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED',
                    p_token1        => 'PROCEDURENAME',
                    p_value1        => 'PAFPPTPB.Delete_planning_transactions');
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;


    --Throw an error if the input tables do not have same no of elements
    IF  (p_task_or_res = 'TASKS' AND
         p_element_version_id_tbl.count =0) OR
        (p_task_or_res = 'ASSIGNMENT' AND
         p_resource_assignment_tbl.count =0) THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='The input table is empty. returning';
            print_msg(pa_debug.g_err_stage,l_module_name);
            pa_debug.reset_curr_function;
	END IF;
        RETURN;
    END IF;

    IF p_calling_module='PROCESS_RES_CHG_DERV_CALC_PRMS' THEN
     l_ra_id_in_pra_tbl     :=p_resource_assignment_tbl;
       l_task_id_in_pra_tbl     :=p_task_id_tbl;
         l_rbs_element_id_in_pra_tbl    :=p_rbs_element_id_tbl;
       l_res_class_code_in_pra_tbl  :=p_resource_class_code_tbl;
       l_rate_based_flag_in_pra_tbl :=p_rate_based_flag_tbl;
    END IF;

    --Bug 4951422. Initialize these tbls to avoid "ORA-06531: Reference to uninitialized collection" error
    --when the element version id tbl passed do not have corresponding resource assignment ids
    l_resource_assignment_id_tbl := SYSTEM.pa_num_tbl_type();
    l_ra_id_in_pra_tbl := SYSTEM.pa_num_tbl_type();

    /** when the context is Task assignment Call the Validation API
    * Modified Delete logic for Bug 3808720. Since Validate Delete Assignments API
    * needs to be called for WORKPLAN context as well. Merginng Delete Logic for
    * G_CALLING_MODULE_TASK and G_CALLING_MODULE_WORKPLAN below.
    */
    IF p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK OR
        p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN THEN --{

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='The calling context is task assignment. Calling the validation API';
                print_msg(pa_debug.g_err_stage,l_module_name);
            END IF;

          PA_TASK_ASSIGNMENT_UTILS.VALIDATE_DELETE_ASSIGNMENT
             ( p_context                      => p_context
              ,p_calling_context              => p_calling_context    -- Added for Bug 6856934
              ,p_task_or_res                  => p_task_or_res
              ,p_elem_ver_id_tbl              => p_element_version_id_tbl
              ,p_task_name_tbl                => p_task_name_tbl
              ,p_task_number_tbl              => p_task_number_tbl
              ,p_resource_assignment_id_tbl   => p_resource_assignment_tbl
              ,x_delete_task_flag_tbl         => l_delete_task_flag_tbl
              ,x_delete_asgmt_flag_tbl        => l_delete_assmt_flag_tbl
              ,x_task_assmt_ids_tbl           => l_task_assmt_ids_tbl --Bug 4951422
              ,x_return_status                => x_return_status);

             IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'After calling Validate OutParms: l_delete_task_flag_tblCount[';
                pa_debug.g_err_stage:= pa_debug.g_err_stage||l_delete_task_flag_tbl.count||']';
                pa_debug.g_err_stage:= pa_debug.g_err_stage||'l_delete_assmt_flag_tblcount[';
                pa_debug.g_err_stage:= pa_debug.g_err_stage||l_delete_assmt_flag_tbl.count||']';
                pa_debug.g_err_stage:= pa_debug.g_err_stage||'l_task_assmt_ids_tblCount[';
                pa_debug.g_err_stage:= pa_debug.g_err_stage||l_task_assmt_ids_tbl.count||']';
                pa_debug.g_err_stage:= pa_debug.g_err_stage||'RetSts['||x_return_status||']';
                print_msg(pa_debug.g_err_stage,l_module_name);
            End If;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='The calling context is task assignment. Calling the validation API';
                    print_msg(pa_debug.g_err_stage,l_module_name);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
	    End If;
	END IF; --}

    /* Bug fix:5349668: Get project,budget,ciid details upfront based on
     * in put params, If budget version is null then just return as there
     * nothing to delete any budget lines or resource assignments.
     * Note: executing this sql at many places to get budget version is failing with
     * ORA-No data found error
     */ --{
    IF (p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK OR
       p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN) THEN --{

      If p_task_or_res = 'TASKS'   --- bug 6076066: added the checking of p_task_res to the existing IF loop
        and p_element_version_id_tbl.count > 0
	and NVL(p_element_version_id_tbl(1),0) <> 0
	and p_element_version_id_tbl(1) <> fnd_api.g_miss_num then

	/* Bug fix: LOOP is required to get the budget version id. when multiple tasks are deleted
	* some of the task may not have assignments, but some may have assignments
	* without loop, the process skips all the records
	*/

	FOR i IN p_element_version_id_tbl.FIRST .. p_element_version_id_tbl.LAST LOOP
	    l_cntr := i;
     	    BEGIN
		IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:=l_cntr||'..Getting budget version id from p_element_version_id_tbl';
		    pa_debug.g_err_stage:=pa_debug.g_err_stage||'['||p_element_version_id_tbl(l_cntr)||']';
                    print_msg(pa_debug.g_err_stage,l_module_name);
                END IF;
		SELECT pbv.project_id
			,pbv.budget_version_id
			,pbv.ci_id
		INTO   l_project_id
			,l_budget_version_id
			,l_ci_id
		FROM   pa_resource_assignments pra
			,pa_budget_Versions pbv
		WHERE  pbv.budget_version_id=pra.budget_version_id
		AND    pbv.wp_version_flag='Y'
		AND    pra.wbs_element_version_id=p_element_version_id_tbl(l_cntr)
		AND    rownum < 2 ;

		EXIT;
	    EXCEPTION
		WHEN NO_DATA_FOUND THEN
		IF l_debug_mode = 'Y' THEN
		    pa_debug.g_err_stage:='No Data Found: No budget Exists for this Task Element Version Ids';
		    print_msg(pa_debug.g_err_stage,l_module_name);
		END IF;
		NULL;
	    END;
	END LOOP;

	/* check if any planning resource exists for l_task_assmt_ids_tbl passed from
         * validate_delete_assignment api.
	 */
	IF l_budget_version_id is NULL and
           l_task_assmt_ids_tbl is NOT NULL and -- Bug 5408333 fix - ORA-06531: Reference to uninitialized collection
           l_task_assmt_ids_tbl.COUNT > 0 Then
            BEGIN
                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='2..Getting budget version id from l_task_assmt_ids_tbl';
                    pa_debug.g_err_stage:=pa_debug.g_err_stage||'['||l_task_assmt_ids_tbl(1)||']';
                    print_msg(pa_debug.g_err_stage,l_module_name);
                END IF;
                SELECT pbv.project_id
                        ,pbv.budget_version_id
                        ,pbv.ci_id
                INTO   l_project_id
                        ,l_budget_version_id
                        ,l_ci_id
                FROM   pa_resource_assignments pra
                        ,pa_budget_Versions pbv
                WHERE  pbv.budget_version_id=pra.budget_version_id
                AND    pra.resource_assignment_id =l_task_assmt_ids_tbl(1);
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='No Data Found: No budget Exists for this Task Assignment Ids';
                    print_msg(pa_debug.g_err_stage,l_module_name);
                END IF;
                NULL;
            END;

	End If;
     END IF; --}
    END IF; -- Bug 5408333 fix - To handle FINPLAN case in which the above
            --                   2 SQL statements will not populate l_budget_version_id

    IF  l_budget_version_id is  NULL -- Bug 5408333
        and p_resource_assignment_tbl.COUNT > 0
	and NVL(p_resource_assignment_tbl(1),0) <> 0
	and p_resource_assignment_tbl(1) <> fnd_api.g_miss_num Then

        BEGIN

		IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='2..Getting budget version id from p_resource_assignment_tbl';
                    pa_debug.g_err_stage:=pa_debug.g_err_stage||'['||p_resource_assignment_tbl(1)||']';
                    print_msg(pa_debug.g_err_stage,l_module_name);
                END IF;
                SELECT pbv.project_id
                        ,pbv.budget_version_id
                        ,pbv.ci_id
                INTO   l_project_id
                        ,l_budget_version_id
                        ,l_ci_id
                FROM   pa_resource_assignments pra
                        ,pa_budget_Versions pbv
                WHERE  pbv.budget_version_id=pra.budget_version_id
                AND    pra.resource_assignment_id =p_resource_assignment_tbl(1);
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='No Data Found: No budget Exists for this resource Assignment Ids';
                    print_msg(pa_debug.g_err_stage,l_module_name);
                END IF;
                NULL;
        END;

    END IF; --}

    IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='ProjId['||l_project_id||']BudgetVers['||l_budget_version_id||']Ciid['||l_ci_id||']';
            print_msg(pa_debug.g_err_stage,l_module_name);
    END IF;

    If l_budget_version_id is NULL Then
    		IF l_debug_mode = 'Y' THEN
        		pa_debug.g_err_stage:='Exiting delete_planning_transactions as No budget version exists';
        		print_msg(pa_debug.g_err_stage,l_module_name);
        		pa_debug.reset_curr_function;
    		END IF;
		RETURN;
    End If;
    /* End of Bug fix:5349668: */

    IF p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK OR
	p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN THEN

            IF p_task_or_res = 'TASKS' THEN

                IF l_delete_task_flag_tbl.count=0 THEN
                    IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:='No elements in the l_delete_task_flag_tbl';
                        print_msg(pa_debug.g_err_stage,l_module_name);
                        pa_debug.reset_curr_function;
		    END IF;
                    RETURN;
                END IF;

                IF l_delete_task_flag_tbl.count<>p_element_version_id_tbl.count THEN
                    IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:='Num elements in l_delete_task_flag_tbl, p_element_version_id_tbl dont match';
                       print_msg(pa_debug.g_err_stage,l_module_name);
                    END IF;
                    PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                          p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

                --Bug 4951422. Validate_Delete_Assignment returns the correct resource assignments that should be deleted.
		--Note:
                --that wbs_elememnt_version_id will be populated only for Workplan versions and hence all the checks done in
                --the commented SQL are already done in that API
		  IF l_task_assmt_ids_tbl.COUNT > 0 Then --{
		  IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:='Deleting all budget lines based on l_task_assmt_ids_tbl';
                     print_msg(pa_debug.g_err_stage,l_module_name);
                  END IF;
		  FORALL i IN 1..l_task_assmt_ids_tbl.COUNT
                  DELETE
                  FROM   pa_budget_lines pbl
                  WHERE  pbl.resource_assignment_id=l_task_assmt_ids_tbl(i)
                    RETURNING
                    pbl.period_name,
                    pbl.start_date,
                    pbl.end_date,
                    pbl.txn_currency_code,
                    -pbl.txn_raw_cost,
                    -pbl.txn_burdened_cost,
                    -pbl.txn_revenue,
                    -pbl.project_raw_cost,
                    -pbl.project_burdened_cost,
                    -pbl.project_revenue,
                    -pbl.raw_cost,
                    -pbl.burdened_cost,
                    -pbl.revenue,
                    -pbl.quantity,
                    pbl.cost_rejection_code    ,
                    pbl.revenue_rejection_code ,
                    pbl.burden_rejection_code  ,
                    pbl.other_rejection_code   ,
                    pbl.pc_cur_conv_rejection_code,
                    pbl.pfc_cur_conv_rejection_code,
                    pbl.resource_assignment_id
                    BULK COLLECT INTO
                    l_period_name_tbl,
                    l_start_date_tbl,
                    l_end_date_tbl,
                    l_txn_currency_code_tbl,
                    l_txn_raw_cost_tbl,
                    l_txn_burdened_cost_tbl,
                    l_txn_revenue_tbl,
                    l_project_raw_cost_tbl,
                    l_project_burdened_cost_tbl,
                    l_project_revenue_tbl,
                    l_raw_cost_tbl,
                    l_burdened_cost_tbl,
                    l_revenue_tbl,
                    l_quantity_tbl,
                    l_cost_rejection_code_tbl,
                    l_revenue_rejection_code_tbl,
                    l_burden_rejection_code_tbl,
                    l_other_rejection_code,
                    l_pc_cur_conv_rej_code_tbl,
                    l_pfc_cur_conv_rej_code_tbl,
                    l_resource_assignment_id_tbl;

                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Deleting all resource assignments for the tasks for which the fla is passed as Y';
                    print_msg(pa_debug.g_err_stage,l_module_name);
                END IF;

                -- IPM changes - populate tmp table to use for deletion later
                IF l_resource_assignment_id_tbl.COUNT > 0 THEN
                   FORALL i IN l_resource_assignment_id_tbl.first ..
                               l_resource_assignment_id_tbl.last
                      INSERT INTO pa_resource_asgn_curr_tmp
                        (RA_TXN_ID
                        ,RESOURCE_ASSIGNMENT_ID
                        ,TXN_CURRENCY_CODE
                        ,DELETE_FLAG
                        )
                        SELECT pa_resource_asgn_curr_s.nextval
                              ,l_resource_assignment_id_tbl(i)
                              ,l_txn_currency_code_tbl(i)
                              ,'Y'
                          FROM DUAL;
                END IF;

                --Bug 4951422. Validate_Delete_Assignment returns the correct resource assignments that should be deleted.
		--Note:
                --that wbs_elememnt_version_id will be populated only for Workplan versions and hence all the checks done in
                --the commented SQL are already done in that API
		FORALL i IN 1..l_task_assmt_ids_tbl.COUNT
                  DELETE
                  FROM   pa_resource_assignments pra
                  WHERE  resource_assignment_id=l_task_assmt_ids_tbl(i)
                    RETURNING
                      pra.resource_assignment_id,
                      pra.task_id,
                      pra.rbs_element_id,
                      pra.resource_class_code,
                      pra.rate_based_flag
                    BULK COLLECT INTO
                      l_ra_id_in_pra_tbl,
                      l_task_id_in_pra_tbl,
                      l_rbs_element_id_in_pra_tbl,
                      l_res_class_code_in_pra_tbl,
                      l_rate_based_flag_in_pra_tbl;

                 -- IPM changes - populate tmp table to use for deletion later
                 -- hr_utility.trace('RM DEL4');
                 IF l_ra_id_in_pra_tbl.COUNT > 0 THEN
                    FORALL i IN l_ra_id_in_pra_tbl.first ..
                                l_ra_id_in_pra_tbl.last
                       INSERT INTO pa_resource_asgn_curr_tmp
                         (RA_TXN_ID
                         ,RESOURCE_ASSIGNMENT_ID
                         -- ,TXN_CURRENCY_CODE
                         ,DELETE_FLAG
                         )
                         SELECT pa_resource_asgn_curr_s.nextval
                               ,l_ra_id_in_pra_tbl(i)
                               -- ,l_txn_currency_code_tbl(i)
                               ,'Y'
                           FROM DUAL;
                 END IF;
		End if; --}

            ELSIF p_task_or_res = 'ASSIGNMENT' THEN

                  IF l_delete_assmt_flag_tbl.count=0 THEN
                      IF l_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:='No elements in the l_delete_assmt_flag_tbl';
                          print_msg(pa_debug.g_err_stage,l_module_name);
                          pa_debug.reset_curr_function;
		      END IF;
                      RETURN;
                  END IF;

                  IF l_delete_assmt_flag_tbl.count<>p_resource_assignment_tbl.count THEN
                        IF l_debug_mode = 'Y' THEN
                            pa_debug.g_err_stage:='No of elements in l_delete_task_flag_tbl ';
			    pa_debug.g_err_stage:=pa_debug.g_err_stage||'and p_resource_assignment_tbl dont match';
                            print_msg(pa_debug.g_err_stage,l_module_name);
                        END IF;
                        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                             p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;

                  IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:='Deleting all budget lines for the res assmts for Assignment Context';
                     print_msg(pa_debug.g_err_stage,l_module_name);
                  END IF;

                 FORALL i IN l_delete_assmt_flag_tbl.first..l_delete_assmt_flag_tbl.last
                        DELETE
                          FROM  pa_budget_lines pbl
                         WHERE  resource_assignment_id=p_resource_assignment_tbl(i)
                           AND  l_delete_assmt_flag_tbl(i)='Y'
                   AND  ( nvl(p_calling_module,'-99') <> 'PROCESS_RES_CHG_DERV_CALC_PRMS' OR
                         (init_quantity is  NULL AND
                          txn_init_raw_cost is NULL AND
                          txn_init_burdened_cost is NULL AND
                          txn_init_revenue is NULL)
                        )
                 RETURNING
                    pbl.period_name,
                    pbl.start_date,
                    pbl.end_date,
                    pbl.txn_currency_code,
                    -pbl.txn_raw_cost,
                    -pbl.txn_burdened_cost,
                    -pbl.txn_revenue,
                    -pbl.project_raw_cost,
                    -pbl.project_burdened_cost,
                    -pbl.project_revenue,
                    -pbl.raw_cost,
                    -pbl.burdened_cost,
                    -pbl.revenue,
                    -pbl.quantity,
                    pbl.cost_rejection_code    ,
                    pbl.revenue_rejection_code ,
                    pbl.burden_rejection_code  ,
                    pbl.other_rejection_code   ,
                    pbl.pc_cur_conv_rejection_code,
                    pbl.pfc_cur_conv_rejection_code,
                    pbl.resource_assignment_id
                    BULK COLLECT INTO
                    l_period_name_tbl,
                    l_start_date_tbl,
                    l_end_date_tbl,
                    l_txn_currency_code_tbl,
                    l_txn_raw_cost_tbl,
                    l_txn_burdened_cost_tbl,
                    l_txn_revenue_tbl,
                    l_project_raw_cost_tbl,
                    l_project_burdened_cost_tbl,
                    l_project_revenue_tbl,
                    l_raw_cost_tbl,
                    l_burdened_cost_tbl,
                    l_revenue_tbl,
                    l_quantity_tbl,
                    l_cost_rejection_code_tbl,
                    l_revenue_rejection_code_tbl,
                    l_burden_rejection_code_tbl,
                    l_other_rejection_code,
                    l_pc_cur_conv_rej_code_tbl,
                    l_pfc_cur_conv_rej_code_tbl,
                    l_resource_assignment_id_tbl;

                 IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:='Deleting all resource assignments for the tasks for which the fla is passed as Y';
                     print_msg(pa_debug.g_err_stage,l_module_name);
                 END IF;

                 -- IPM changes - populate tmp table to use for deletion later
                 -- hr_utility.trace('RM DEL6');
                 IF l_resource_assignment_id_tbl.COUNT > 0 THEN
                    FORALL i IN l_resource_assignment_id_tbl.first ..
                                l_resource_assignment_id_tbl.last
                       INSERT INTO pa_resource_asgn_curr_tmp
                         (RA_TXN_ID
                         ,RESOURCE_ASSIGNMENT_ID
                         -- ,TXN_CURRENCY_CODE
                         ,DELETE_FLAG
                         )
                         SELECT pa_resource_asgn_curr_s.nextval
                               ,l_resource_assignment_id_tbl(i)
                               -- ,l_txn_currency_code_tbl(i)
                               ,'Y'
                           FROM DUAL;
                 END IF;

                 IF nvl(p_calling_module,'-99') <> 'PROCESS_RES_CHG_DERV_CALC_PRMS' THEN

                    FORALL i IN l_delete_assmt_flag_tbl.first..l_delete_assmt_flag_tbl.last
                      DELETE
                        FROM  pa_resource_assignments pra
                       WHERE  resource_assignment_id=p_resource_assignment_tbl(i)
                         AND  l_delete_assmt_flag_tbl(i)='Y'
                   RETURNING
                      pra.resource_assignment_id,
                      pra.task_id,
                      pra.rbs_element_id,
                      pra.resource_class_code,
                      pra.rate_based_flag
                   BULK COLLECT INTO
                      l_ra_id_in_pra_tbl,
                      l_task_id_in_pra_tbl,
                      l_rbs_element_id_in_pra_tbl,
                      l_res_class_code_in_pra_tbl,
                      l_rate_based_flag_in_pra_tbl;

                 -- IPM changes - populate tmp table to use for deletion later
                 -- hr_utility.trace('RM DEL3');
                 IF l_ra_id_in_pra_tbl.COUNT > 0 THEN
                    FORALL i IN l_ra_id_in_pra_tbl.first ..
                                l_ra_id_in_pra_tbl.last
                       INSERT INTO pa_resource_asgn_curr_tmp
                         (RA_TXN_ID
                         ,RESOURCE_ASSIGNMENT_ID
                         -- ,TXN_CURRENCY_CODE
                         ,DELETE_FLAG
                         )
                         SELECT pa_resource_asgn_curr_s.nextval
                               ,l_ra_id_in_pra_tbl(i)
                               -- ,l_project_currency_code
                               ,'Y'
                           FROM DUAL;
                 END IF;
             END IF;    -- IF nvl(p_calling_module,'-99') <> 'PROCESS_RES_CHG_DERV_CALC_PRMS' THEN

            END IF;

    ELSE --The context is not Task Assignment
         -- or Workplan -- Bug 3808720

        IF p_task_or_res = 'TASKS' THEN

            IF p_element_version_id_tbl.count=0 THEN
              IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:='No elements in the p_element_version_id_tbl';
                  print_msg(pa_debug.g_err_stage,l_module_name);
                  pa_debug.reset_curr_function;
	    END IF;
              RETURN;
            END IF;


            IF p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET OR
               p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FORECAST THEN
                l_wp_version_flag:='N';
                l_ta_display_flag:=null;
/*          ELSIF p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN THEN
                l_wp_version_flag:='Y';
                l_ta_display_flag:='N'; */ --Bug 3808720
            END IF;

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='l_wp_version_flag IS '||l_wp_version_flag;
                print_msg(pa_debug.g_err_stage,l_module_name);
            END IF;


            IF p_context in (PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET,
                             PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FORECAST) THEN

                -- Bug Fix: 4569365. Removed MRC code.
		null;
            END IF;


	    If l_budget_version_id is NOT NULL Then --Bug fix:5349668 --{
		IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='2..Deleting budget lines based on Task element Version Ids';
                   print_msg(pa_debug.g_err_stage,l_module_name);
                END IF;
            FORALL i IN p_element_version_id_tbl.first..p_element_version_id_tbl.last
                DELETE
                FROM   pa_budget_lines pbl
                WHERE  pbl.resource_assignment_id IN (SELECT pra.resource_assignment_id
                                                      FROM   pa_resource_assignments pra,
                                                             pa_budget_versions pbv
                                                      WHERE  pra.budget_Version_id=pbv.budget_Version_id
                                                      AND    nvl(pbv.wp_version_flag,'N')=l_wp_version_flag
                                                      AND    pra.budget_Version_id = l_budget_version_id--Bug#4548675--Bug 4218331
                                                      AND    pbv.budget_Version_id = l_budget_version_id--Bug#4548675--Bug 4218331
                                                      AND    pra.wbs_element_version_id=p_element_version_id_tbl(i)
                                                      AND    nvl(l_ta_display_flag , '-99')=nvl(ta_display_flag,'-99'))
               AND pbl.budget_Version_id = l_budget_version_id--Bug#4548675--Bug 4218331
                 RETURNING
                    pbl.period_name,
                    pbl.start_date,
                    pbl.end_date,
                    pbl.txn_currency_code,
                    -pbl.txn_raw_cost,
                    -pbl.txn_burdened_cost,
                    -pbl.txn_revenue,
                    -pbl.project_raw_cost,
                    -pbl.project_burdened_cost,
                    -pbl.project_revenue,
                    -pbl.raw_cost,
                    -pbl.burdened_cost,
                    -pbl.revenue,
                    -pbl.quantity,
                    pbl.cost_rejection_code    ,
                    pbl.revenue_rejection_code ,
                    pbl.burden_rejection_code  ,
                    pbl.other_rejection_code   ,
                    pbl.pc_cur_conv_rejection_code,
                    pbl.pfc_cur_conv_rejection_code,
                    pbl.resource_assignment_id
                    BULK COLLECT INTO
                    l_period_name_tbl,
                    l_start_date_tbl,
                    l_end_date_tbl,
                    l_txn_currency_code_tbl,
                    l_txn_raw_cost_tbl,
                    l_txn_burdened_cost_tbl,
                    l_txn_revenue_tbl,
                    l_project_raw_cost_tbl,
                    l_project_burdened_cost_tbl,
                    l_project_revenue_tbl,
                    l_raw_cost_tbl,
                    l_burdened_cost_tbl,
                    l_revenue_tbl,
                    l_quantity_tbl,
                    l_cost_rejection_code_tbl,
                    l_revenue_rejection_code_tbl,
                    l_burden_rejection_code_tbl,
                    l_other_rejection_code,
                    l_pc_cur_conv_rej_code_tbl,
                    l_pfc_cur_conv_rej_code_tbl,
                    l_resource_assignment_id_tbl;

                 -- IPM changes - populate tmp table to use for deletion later
                 -- hr_utility.trace('RM DEL5');
                 IF l_resource_assignment_id_tbl.COUNT > 0 THEN
                    FORALL i IN l_resource_assignment_id_tbl.first ..
                                l_resource_assignment_id_tbl.last
                       INSERT INTO pa_resource_asgn_curr_tmp
                         (RA_TXN_ID
                         ,RESOURCE_ASSIGNMENT_ID
                         -- ,TXN_CURRENCY_CODE
                         ,DELETE_FLAG
                         )
                         SELECT pa_resource_asgn_curr_s.nextval
                               ,l_resource_assignment_id_tbl(i)
                               -- ,l_txn_currency_code_tbl(i)
                               ,'Y'
                           FROM DUAL;
                 END IF;
	    End If; --}

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Deleting all   res assmts for which the flag is passed as Y';
		print_msg(pa_debug.g_err_stage,l_module_name);
            END IF;

	    If p_element_version_id_tbl.COUNT > 0 AND l_budget_version_id is NOT NULL Then --Bug fix:5349668 --{
            	FORALL i IN p_element_version_id_tbl.first..p_element_version_id_tbl.last
                DELETE
                FROM   pa_resource_assignments pra
                WHERE pra.wbs_element_version_id=p_element_version_id_tbl(i)
                AND   EXISTS (SELECT 'X'
                              FROM   pa_budget_Versions pbv
                              WHERE  pbv.budget_version_id=pra.budget_Version_id
                              AND    pbv.budget_Version_id = l_budget_version_id--Bug#4548675--Bug 4218331
                              AND    nvl(pbv.wp_version_flag,'N')=l_wp_version_flag
                              AND    nvl(l_ta_display_flag , '-99')=nvl(ta_display_flag,'-99'))
                AND pra.budget_Version_id = l_budget_version_id--Bug#4548675--Bug 4218331
                RETURNING
                pra.resource_assignment_id,
                pra.task_id,
                pra.rbs_element_id,
                pra.resource_class_code,
                pra.rate_based_flag
                BULK COLLECT INTO
                l_ra_id_in_pra_tbl,
                l_task_id_in_pra_tbl,
                l_rbs_element_id_in_pra_tbl,
                l_res_class_code_in_pra_tbl,
                l_rate_based_flag_in_pra_tbl;

                -- IPM changes - populate tmp table to use for deletion later
                -- hr_utility.trace('RM DEL8');
                IF l_ra_id_in_pra_tbl.COUNT > 0 THEN
                   FORALL i IN l_ra_id_in_pra_tbl.first ..
                               l_ra_id_in_pra_tbl.last
                      INSERT INTO pa_resource_asgn_curr_tmp
                        (RA_TXN_ID
                        ,RESOURCE_ASSIGNMENT_ID
                        -- ,TXN_CURRENCY_CODE
                        ,DELETE_FLAG
                        )
                        SELECT pa_resource_asgn_curr_s.nextval
                              ,l_ra_id_in_pra_tbl(i)
                              -- ,l_project_currency_code
                              ,'Y'
                          FROM DUAL;
                 END IF;
	    End If; --}


        ELSIF p_task_or_res = 'ASSIGNMENT' THEN

            IF p_resource_assignment_tbl.count=0 THEN
              IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:='No elements in the p_resource_assignment_tbl';
                  print_msg(pa_debug.g_err_stage,l_module_name);
                  pa_debug.reset_curr_function;
	      END IF;
              RETURN;
            END IF;

            l_currency_code_tbl.extend(p_resource_assignment_tbl.COUNT);

            IF p_currency_code_tbl.COUNT > 0 THEN --If Currnecy Code is Passed.
                IF p_resource_assignment_tbl.count <> p_currency_code_tbl.COUNT THEN --Count Should be equal to ra id count
                   IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:='Count Mismatch for currency code and Reource Assignment';
                      print_msg(pa_debug.g_err_stage,l_module_name);
                   END IF;
                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                        p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                                        p_token1         => 'PROCEDURENAME',
                                        p_value1         => 'PAFPPTPB.Delete_planning_transactions',
                                        p_token2         => 'STAGE',
                                        p_value2         => 'Curr Code - RA Mismatch');
                   RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

                l_currency_code_tbl := p_currency_code_tbl;

            END IF;

            --Checking for the existence of budget lines for the element version ids passed. Bug 3589130
            IF p_validate_delete_flag='Y' THEN

                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Checking for the existence of budget lines';
                    print_msg(pa_debug.g_err_stage,l_module_name);
                END IF;

                BEGIN
                    FOR i IN p_resource_assignment_tbl.first..p_resource_assignment_tbl.last LOOP

                        l_exists:='N';

                        BEGIN
                            SELECT 'Y'
                            INTO   l_exists
                            FROM   DUAL
                            WHERE  EXISTS (SELECT 'X'
                                           FROM   pa_budget_lines pbl,
                                                  pa_resource_assignments pra
                                           WHERE  pra.resource_assignment_id=p_resource_assignment_tbl(i)
                                           AND    pbl.budget_Version_id=pra.budget_version_id
                                           AND    pbl.resource_assignment_id=pra.resource_assignment_id);
                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            l_exists:='N';
                        END;

                        IF l_exists='Y' THEN

                            RAISE SKIP_LOOP;

                        END IF;

                    END LOOP;

                EXCEPTION
                WHEN SKIP_LOOP THEN
                    IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:='Budget lines exist for the resource assignment id passed '||p_resource_assignment_tbl(i);
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    END IF;
                    PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                         p_msg_name       => 'PA_FP_AMT_EXISTS_FOR_PLAN_ELEM');
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END;

            END IF ; --IF p_validate_delete_flag='Y' THEN

            IF p_context in (PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET,
                             PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FORECAST) THEN
              NULL;
                -- Bug Fix: 4569365. Removed MRC code.
            END IF;

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Deleting all  budget lines ';
                print_msg(pa_debug.g_err_stage,l_module_name);
            END IF;

            FORALL i IN p_resource_assignment_tbl.first..p_resource_assignment_tbl.last
                DELETE
                FROM   pa_budget_lines pbl
                WHERE  pbl.resource_assignment_id=p_resource_assignment_tbl(i)
                  AND  ( nvl(p_calling_module,'-99') <> 'PROCESS_RES_CHG_DERV_CALC_PRMS' OR
                        (init_quantity is  NULL AND
                         txn_init_raw_cost is NULL AND
                         txn_init_burdened_cost is NULL AND
                         txn_init_revenue is NULL)
                       )
                  AND nvl(l_currency_code_tbl(i),pbl.txn_currency_code) = pbl.txn_currency_code -- 3719918
                RETURNING
                    pbl.period_name,
                    pbl.start_date,
                    pbl.end_date,
                    pbl.txn_currency_code,
                    -pbl.txn_raw_cost,
                    -pbl.txn_burdened_cost,
                    -pbl.txn_revenue,
                    -pbl.project_raw_cost,
                    -pbl.project_burdened_cost,
                    -pbl.project_revenue,
                    -pbl.raw_cost,
                    -pbl.burdened_cost,
                    -pbl.revenue,
                    -pbl.quantity,
                    pbl.cost_rejection_code    ,
                    pbl.revenue_rejection_code ,
                    pbl.burden_rejection_code  ,
                    pbl.other_rejection_code   ,
                    pbl.pc_cur_conv_rejection_code,
                    pbl.pfc_cur_conv_rejection_code,
                    pbl.resource_assignment_id
                    BULK COLLECT INTO
                    l_period_name_tbl,
                    l_start_date_tbl,
                    l_end_date_tbl,
                    l_txn_currency_code_tbl,
                    l_txn_raw_cost_tbl,
                    l_txn_burdened_cost_tbl,
                    l_txn_revenue_tbl,
                    l_project_raw_cost_tbl,
                    l_project_burdened_cost_tbl,
                    l_project_revenue_tbl,
                    l_raw_cost_tbl,
                    l_burdened_cost_tbl,
                    l_revenue_tbl,
                    l_quantity_tbl,
                    l_cost_rejection_code_tbl,
                    l_revenue_rejection_code_tbl,
                    l_burden_rejection_code_tbl,
                    l_other_rejection_code,
                    l_pc_cur_conv_rej_code_tbl,
                    l_pfc_cur_conv_rej_code_tbl,
                    l_resource_assignment_id_tbl;

                    -- IPM changes populate tmp table to use for deletion later
                    -- hr_utility.trace('RM DEL1');
                    IF l_resource_assignment_id_tbl.COUNT > 0 THEN
                       FORALL i IN l_resource_assignment_id_tbl.first ..
                                   l_resource_assignment_id_tbl.last
                          INSERT INTO pa_resource_asgn_curr_tmp
                            (RA_TXN_ID
                            ,RESOURCE_ASSIGNMENT_ID
                            ,TXN_CURRENCY_CODE -- Bug 5057010
                            ,DELETE_FLAG
                            )
                            SELECT pa_resource_asgn_curr_s.nextval
                                  ,l_resource_assignment_id_tbl(i)
                                  ,l_txn_currency_code_tbl(i) -- Bug 5057010
                                  ,'Y'
                              FROM DUAL;
                    END IF;

            IF nvl(p_calling_module,'-99') <> 'PROCESS_RES_CHG_DERV_CALC_PRMS' THEN

                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Deleting all   res assmts for which the flag is passed as Y';
                    print_msg(pa_debug.g_err_stage,l_module_name);
                END IF;

              FORALL i IN p_resource_assignment_tbl.first..p_resource_assignment_tbl.last
                    DELETE
                    FROM   pa_resource_assignments pra
                    WHERE  pra.resource_assignment_id=p_resource_assignment_tbl(i)
                      AND  (l_currency_code_tbl(i) IS NULL
                            OR
                            NOT EXISTS ( SELECT 'EXISTS'
                                           FROM PA_BUDGET_LINES PBL
                                          WHERE PBL.RESOURCE_ASSIGNMENT_ID = pra.resource_assignment_id))
                    RETURNING
                    pra.resource_assignment_id,
                    pra.task_id,
                    pra.rbs_element_id,
                    pra.resource_class_code,
                    pra.rate_based_flag
                    BULK COLLECT INTO
                    l_ra_id_in_pra_tbl,
                    l_task_id_in_pra_tbl,
                    l_rbs_element_id_in_pra_tbl,
                    l_res_class_code_in_pra_tbl,
                    l_rate_based_flag_in_pra_tbl;

                 -- hr_utility.trace('RM DEL2');
                 -- IPM changes - populate temp table for deletion
                 IF l_ra_id_in_pra_tbl.COUNT > 0 THEN
                    FORALL i IN l_ra_id_in_pra_tbl.first ..
                                l_ra_id_in_pra_tbl.last
                       INSERT INTO pa_resource_asgn_curr_tmp
                         (RA_TXN_ID
                         ,RESOURCE_ASSIGNMENT_ID
                         -- ,TXN_CURRENCY_CODE
                         ,DELETE_FLAG
                         )
                         SELECT pa_resource_asgn_curr_s.nextval
                               ,l_ra_id_in_pra_tbl(i)
                               -- ,l_project_currency_code
                               ,'Y'
                           FROM DUAL;
                 END IF;

        END IF;-- IF nvl(p_calling_module,'-99') <> 'PROCESS_RES_CHG_DERV_CALC_PRMS' THEN

        END IF;-- IF p_task_or_res = 'TASKS' THEN

    END IF;--IF p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK

    --Rollup the amounts to budget versions as some of the budget lines with amounts might have got
    --deleted
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='No of Rec Deleted from RA : ' || l_ra_id_in_pra_tbl.COUNT;
        print_msg(pa_debug.g_err_stage,l_module_name);
        IF l_ra_id_in_pra_tbl.COUNT > 0 THEN
           FOR i in l_ra_id_in_pra_tbl.FIRST .. l_ra_id_in_pra_tbl.LAST LOOP
               pa_debug.g_err_stage:='Deleted RA Id : ' || l_ra_id_in_pra_tbl(i);
               print_msg(pa_debug.g_err_stage,l_module_name);
           END LOOP;
        END IF;
    END IF;

    -- IPM changes - delete from new entity  --{
    -- new entity maintenance api to be called before call to pa_fp_rollup_pkg.rollup_budget_version.
    -- Call new entity maintenance api for the budget version id (which has to be derived),
    -- if records have been inserted in pa_Resource_asgn_curr_tmp, in the delete flow.
    -- Note: Deriving l_budget_version_id may not be the right approach as we avoid calling BV/RA
    --   rollup api and pji api when l_budget_version_id is null (No BLs deleted)
    IF l_budget_version_id IS NOT NULL THEN
        pa_debug.g_err_stage:='Calling pa_fp_gen_amount_utils.get_plan_version_dtls:bv_id ' || l_budget_version_id;
        print_msg(pa_debug.g_err_stage,l_module_name);

     pa_fp_gen_amount_utils.get_plan_version_dtls
        (p_project_id         => l_project_id,
         p_budget_version_id  => l_budget_version_id,
         x_fp_cols_rec        => l_fp_cols_rec,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data);

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Called API pa_fp_gen_amount_utils.get_plan_version_dtls returned error';
          print_msg(pa_debug.g_err_stage,l_module_name);
       END IF;
       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;

        pa_debug.g_err_stage:='Calling pa_res_asg_currency_pub.maintain_data:bv_id ' || l_budget_version_id;
        print_msg(pa_debug.g_err_stage,l_module_name);

     pa_res_asg_currency_pub.maintain_data(
         p_fp_cols_rec                  => l_fp_cols_rec,
         p_calling_module               => 'UPDATE_PLAN_TRANSACTION',
         p_delete_flag                  => 'Y',
         p_copy_flag                    => 'N',
         p_src_version_id               => NULL,
         p_copy_mode                    => NULL,
         p_rollup_flag                  => 'N',
         p_version_level_flag           => 'N',
         p_called_mode                  => 'SELF_SERVICE',
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data
         );

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Called API pa_res_asg_currency_pub.maintain_data returned error';
          print_msg(pa_debug.g_err_stage,l_module_name);
       END IF;
       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;

    END IF; --} IPM

    --The code below will call budget version rollup and PJI APIs. These APIs should not be called if the input
    --parameter p_rollup_required_flag is N. For bug 3937716
    IF p_rollup_required_flag = 'Y' THEN

        /* If there was nothing to delete, l_budget_version_id would be null and rollup need not be done for that case */

       --Added for bug 4160258
       IF (p_calling_module = 'PROCESS_RES_CHG_DERV_CALC_PRMS') THEN
         l_mode := null;
       ELSIF (p_currency_code_tbl.COUNT = 0) THEN
         l_mode := 'DELETE_RA';
       ELSE
        l_mode := null;
       END IF;

        IF l_budget_version_id IS NOT NULL THEN
        pa_debug.g_err_stage:='Calling PA_FP_ROLLUP_PKG.ROLLUP_BUDGET_VERSION:l_budget_version_id '||l_budget_version_id;
        print_msg(pa_debug.g_err_stage,l_module_name);

             PA_FP_ROLLUP_PKG.ROLLUP_BUDGET_VERSION
             ( p_budget_version_id     => l_budget_version_id
              ,p_entire_version        => 'Y'
              ,p_context               => l_mode             -- Bug 4160258
              ,x_return_status         => x_return_status
              ,x_msg_count             => l_msg_count
              ,x_msg_data              => l_msg_data);

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:='The API PA_FP_ROLLUP_PKG.ROLLUP_BUDGET_VERSION returned error';
                     print_msg(pa_debug.g_err_stage,l_module_name);
                 END IF;
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
             END IF;

        END IF;
    END IF; /* p_rollup_required_flag = Y */


    /* Bug 4200168: Reporting lines rollup api would only be called if p_pji_rollup_required is
     * passed as Y */
    IF p_pji_rollup_required = 'Y'
	AND l_budget_version_id is NOT NULL THEN -- Bug 5381920

        --Call the Reporting Lines API only if the version is not a CI version
        IF l_ci_id IS NULL THEN

            IF l_resource_assignment_id_tbl.count >0 THEN

                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Prepare pl/sql tables for rbs element id and task id';
                   print_msg(pa_debug.g_err_stage,l_module_name);
                END IF;

                --Prepare the pl/sql tables for task id, rbs element id , resource class code and rate based flag.
                --These pl/sql tables should be same in length to the pl/sql tables prepared while deleting the budget
                --lines. This can be done by looping thru the l_resource_assignment_id_tbl and looking for a matching
                --ra id in l_ra_id_in_pra_tbl If a matching ra id is not found in l_ra_id_in_pra_tbl then data
                -- is fetched directly from pa_resource_assignments for ra id in l_resource_assignment_id_tbl.
                l_ra_index:=1;
                l_counter:=0;--This is used just to keep track of the length of the pl/sql tables being prepared

                l_task_id_tbl.EXTEND(l_resource_assignment_id_tbl.last);
                l_rbs_element_id_tbl.EXTEND(l_resource_assignment_id_tbl.last);
                l_res_class_code_tbl.EXTEND(l_resource_assignment_id_tbl.last);
                l_rate_based_flag_tbl.EXTEND(l_resource_assignment_id_tbl.last);

                FOR i IN l_resource_assignment_id_tbl.FIRST..l_resource_assignment_id_tbl.LAST LOOP
                   --For bug 3840150
                    l_ra_index:=1;
                    LOOP
                        IF l_ra_id_in_pra_tbl.EXISTS(l_ra_index) THEN
                           IF l_ra_id_in_pra_tbl(l_ra_index) = l_resource_assignment_id_tbl(i) THEN
                              IF l_debug_mode = 'Y' THEN
                                  pa_debug.g_err_stage:='Stepping In - l_ra_index : '||l_ra_index;
                                  print_msg(pa_debug.g_err_stage,l_module_name);
                              END IF;
                              l_task_id                    := l_task_id_in_pra_tbl(l_ra_index);
                              l_rbs_element_id             := l_rbs_element_id_in_pra_tbl(l_ra_index);
                              l_res_class_code             := l_res_class_code_in_pra_tbl(l_ra_index);
                              l_rate_based_flag            := l_rate_based_flag_in_pra_tbl(l_ra_index);
                              EXIT; --Exit LOOP
                           ELSE
                                IF l_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage:='Stepping Over - l_ra_index : '||l_ra_index;
                                    print_msg(pa_debug.g_err_stage,l_module_name);
                                END IF;
                                l_ra_index:=l_ra_index+1;
                           END IF;
                        ELSE
                              BEGIN
                                   IF l_debug_mode = 'Y' THEN
                                       pa_debug.g_err_stage:='Fetching Data from PA Res Assignment';
                                       print_msg(pa_debug.g_err_stage,l_module_name);
                                   END IF;
                                   SELECT TASK_ID,
                                          RBS_ELEMENT_ID,
                                          RESOURCE_CLASS_CODE,
                                          RATE_BASED_FLAG
                                     INTO l_task_id,
                                          l_rbs_element_id,
                                          l_res_class_code,
                                          l_rate_based_flag
                                     FROM PA_RESOURCE_ASSIGNMENTS
                                    WHERE RESOURCE_ASSIGNMENT_ID = l_resource_assignment_id_tbl(i);

                                    EXIT; --Exit LOOP

                              EXCEPTION
                                  WHEN NO_DATA_FOUND THEN
                                       IF l_debug_mode = 'Y' THEN
                                           pa_debug.g_err_stage:='No Data Found in RA Table for Bl deleted.';
                                           print_msg(pa_debug.g_err_stage,l_module_name);
                                       END IF;
                                       RAISE;
                              END;
                        END IF;
                    END LOOP;

                    IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:='Data for Update Rep Lines';
                        print_msg(pa_debug.g_err_stage,l_module_name);

                        pa_debug.g_err_stage:='l_task_id '||l_task_id;
                        print_msg(pa_debug.g_err_stage,l_module_name);

                        pa_debug.g_err_stage:='l_rbs_element_id '||l_rbs_element_id;
                        print_msg(pa_debug.g_err_stage,l_module_name);

                        pa_debug.g_err_stage:='l_res_class_code '||l_res_class_code;
                        print_msg(pa_debug.g_err_stage,l_module_name);

                        pa_debug.g_err_stage:='l_rate_based_flag '||l_rate_based_flag;
                        print_msg(pa_debug.g_err_stage,l_module_name);
                    END IF;

                    l_task_id_tbl(i)         :=l_task_id;
                    l_rbs_element_id_tbl(i)  :=l_rbs_element_id;
                    l_res_class_code_tbl(i)  :=l_res_class_code;
                    l_rate_based_flag_tbl(i) :=l_rate_based_flag;
                    l_counter:=l_counter+1;

                END LOOP;

                IF l_counter <> l_resource_assignment_id_tbl.COUNT THEN

                    IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:='Error in preparing pl/sql tables for rbs element id and task id ';
			print_msg(pa_debug.g_err_stage,l_module_name);
                    END IF;

                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                END IF;

                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='No of rows deleted from pa_budget_lines= '||l_resource_assignment_id_tbl.count;
		    print_msg(pa_debug.g_err_stage,l_module_name);
                END IF;

                pa_planning_transaction_utils.call_update_rep_lines_api
                ( p_source                       =>    'PL-SQL'
                 ,p_budget_Version_id            =>     l_budget_version_id
                 ,p_resource_assignment_id_tbl   =>     l_resource_assignment_id_tbl
                 ,p_period_name_tbl              =>     l_period_name_tbl
                 ,p_start_date_tbl               =>     l_start_date_tbl
                 ,p_end_date_tbl                 =>     l_end_date_tbl
                 ,p_txn_currency_code_tbl        =>     l_txn_currency_code_tbl
                 ,p_txn_raw_cost_tbl             =>     l_txn_raw_cost_tbl
                 ,p_txn_burdened_cost_tbl        =>     l_txn_burdened_cost_tbl
                 ,p_txn_revenue_tbl              =>     l_txn_revenue_tbl
                 ,p_project_raw_cost_tbl         =>     l_project_raw_cost_tbl
                 ,p_project_burdened_cost_tbl    =>     l_project_burdened_cost_tbl
                 ,p_project_revenue_tbl          =>     l_project_revenue_tbl
                 ,p_raw_cost_tbl                 =>     l_raw_cost_tbl
                 ,p_burdened_cost_tbl            =>     l_burdened_cost_tbl
                 ,p_revenue_tbl                  =>     l_revenue_tbl
                 ,p_cost_rejection_code_tbl      =>     l_cost_rejection_code_tbl
                 ,p_revenue_rejection_code_tbl   =>     l_revenue_rejection_code_tbl
                 ,p_burden_rejection_code_tbl    =>     l_burden_rejection_code_tbl
                 ,p_other_rejection_code         =>     l_other_rejection_code
                 ,p_pc_cur_conv_rej_code_tbl     =>     l_pc_cur_conv_rej_code_tbl
                 ,p_pfc_cur_conv_rej_code_tbl    =>     l_pfc_cur_conv_rej_code_tbl
                 ,p_quantity_tbl                 =>     l_quantity_tbl
                 ,p_rbs_element_id_tbl           =>     l_rbs_element_id_tbl
                 ,p_task_id_tbl                  =>     l_task_id_tbl
                 ,p_res_class_code_tbl           =>     l_res_class_code_tbl
                 ,p_rate_based_flag_tbl          =>     l_rate_based_flag_tbl
                 ,x_return_status                =>     x_return_status
                 ,x_msg_data                     =>     x_msg_data
                 ,x_msg_count                    =>     x_msg_count    );

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:='The API pa_planning_transaction_utils.call_update_rep_lines_api returned error';
			print_msg(pa_debug.g_err_stage,l_module_name);
                    END IF;
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

            END IF;-- IF l_resource_assignment_id_tbl.count >0 THEN

        END IF;--IF l_ci_id IS NULL THEN

    END IF;--IF p_pji_rollup_required = 'Y' THEN /* Bug 4200168 */

-- Bug Fix 4635951
-- Commenting out the below select as it has been moved into the below IF condition
-- and it was a left out and this stranded select is causing this bug.

        IF ((p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN
            AND PA_TASK_ASSIGNMENT_UTILS.Is_Progress_Rollup_Required(l_project_id) = 'Y') OR -- 5198662
           (p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_TASK
            AND pa_task_assignment_utils.g_require_progress_rollup = 'Y')) AND
           l_budget_version_id IS NOT NULL THEN -- Bug 5381920

	    IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Calling PA_PROJ_TASK_STRUC_PUB.process_wbs_updates_wrp API';
                print_msg(pa_debug.g_err_stage,l_module_name);
            END IF;

             PA_PROJ_TASK_STRUC_PUB.PROCESS_WBS_UPDATES_WRP
                ( p_calling_context       => 'ASGMT_PLAN_CHANGE'
                 ,p_project_id              => l_project_id
                 ,p_structure_version_id   => pa_project_structure_utils.get_latest_wp_version(l_project_id)
                 ,p_pub_struc_ver_id      => pa_project_structure_utils.get_latest_wp_version(l_project_id)
                 ,x_return_status                =>     x_return_status
                 ,x_msg_data                     =>     x_msg_data
                 ,x_msg_count                    =>     x_msg_count    );

             pa_task_assignment_utils.g_require_progress_rollup := 'N';

        END IF;
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='After Called process_wbs_updates_wrp:retSts['||x_return_status||']';
		print_msg(pa_debug.g_err_stage,l_module_name);
            END IF;

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
--End bug 4492493

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Exiting delete_planning_transactions';
	print_msg(pa_debug.g_err_stage,l_module_name);
    -- reset curr function
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

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Invalid Arguments Passed Or called api raised an error';
	   print_msg(pa_debug.g_err_stage,l_module_name);
        -- reset curr function
          pa_debug.reset_curr_function;
       END IF;
       RETURN;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;

        FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'pa_fp_planning_transaction_pub'
                                ,p_procedure_name  => 'delete_planning_transactions');

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           print_msg(pa_debug.g_err_stage,l_module_name);
        -- reset curr function
        pa_debug.Reset_Curr_Function();
        END IF;
        RAISE;
END delete_planning_transactions;


/*=====================================================================
Procedure Name:      ADD_WP_PLAN_TYPE
Purpose:             This API checks if a Work Plan type is present in
                     the system.If is it not then it throws a error.
                     If WorkPlan Type is not attached to the project
                     then it attaches it.
                     This would be called when workplan is enabled for
                     a project or template.
Parameters:(Note that all the input parameters are mandatory)
IN                   1)p_src_project_id   IN pa_projects_all.project_id%TYPE
IN                   2)p_targ_project_id  IN pa_projects_all.project_id%TYPE
=======================================================================*/
PROCEDURE  Add_wp_plan_type
  (
       p_src_project_id               IN       pa_projects_all.project_id%TYPE
      ,p_targ_project_id              IN       pa_projects_all.project_id%TYPE
      ,x_return_status                OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_msg_count                    OUT      NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,x_msg_data                     OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) AS

  --Start of variables used for debugging
      l_msg_count          NUMBER :=0;
      l_data               VARCHAR2(2000);
      l_msg_data           VARCHAR2(2000);
      l_error_msg_code     VARCHAR2(30);
      l_msg_index_out      NUMBER;
      l_return_status      VARCHAR2(2000);
      l_debug_mode         VARCHAR2(30);
  --End of variables used for debugging

      l_wp_type_id              NUMBER :=0;
      l_proj_wp_type_exists     NUMBER :=0;
      l_proj_fp_options_id      pa_proj_fp_options.proj_fp_options_id%TYPE;
      l_projfunc_currency_code  pa_projects_all.projfunc_currency_code%type;
      l_proj_currency_code      pa_projects_all.project_currency_code%type;
      l_appr_rev_plan_type_flag pa_fin_plan_types_b.approved_rev_plan_type_flag %TYPE;

      l_plan_in_multi_curr_flag pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;
      l_src_fp_option_id        pa_proj_fp_options.proj_fp_options_id%TYPE;
BEGIN

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'N');
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
IF l_debug_mode = 'Y' THEN
    PA_DEBUG.Set_Curr_Function( p_function   => 'PA_FP_PLANNING_TRANSACTION_PUB.Add_wp_plan_type',
                                p_debug_mode => l_debug_mode );
END IF;
 ---------------------------------------------------------------
-- validating input parameter p_project_id.
-- p_project_id cannot be passed as null.
---------------------------------------------------------------
    IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Validating input parameters';
       pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.Add_wp_plan_type: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_src_project_id IS NULL) OR
       (p_targ_project_id IS NULL) THEN
        IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Invalid Arguments Passed - src and targ Project Ids are null';
              pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.Add_wp_plan_type: ' || g_module_name,pa_debug.g_err_stage,5);
        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

 ---------------------------------------------------------------
 -- checking if a workplan type is present in the system with
 -- enable_wp_flag = 'Y'
 ---------------------------------------------------------------

      IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='checking availability of a wp type';
        pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.Add_wp_plan_type: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;

     ---------------------------------------------------------
     -- In case of no data found, the exception handling block
     -- shall throw PA_FP_NO_WP_PLAN_TYPE.
     ---------------------------------------------------------
     BEGIN -- BLOCK to check if workplan_type is is present in the system- Starts

     SELECT fin_plan_type_id,approved_rev_plan_type_flag
       INTO l_wp_type_id,l_appr_rev_plan_type_flag
       FROM pa_fin_plan_types_b
      WHERE nvl(use_for_workplan_flag,'N') = 'Y';

     EXCEPTION

          WHEN NO_DATA_FOUND THEN
               IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage :='No WORK PLAN TYPE present in the system';
                  pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.Add_wp_plan_type: ' || g_module_name,pa_debug.g_err_stage,1);
               END IF;

               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name => 'PA_FP_NO_WP_PLAN_TYPE' );
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END; -- BLOCK to check if workplan_type is is present in the system - Ends


---------------------------------------------------------
-- Checking if workplan_type is already attched for the
-- passed project_id
---------------------------------------------------------
      IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='checking if wp type is already attched for project id';
        pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.Add_wp_plan_type: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;

     BEGIN -- BLOCK to check if workplan_type is already attched for the passed project_id - Starts

        SELECT 1
          INTO l_proj_wp_type_exists
          FROM DUAL
         WHERE EXISTS(
                     SELECT 1
                       FROM pa_proj_fp_options
                      WHERE fin_plan_type_id = l_wp_type_id
                        AND project_id = p_targ_project_id
                        AND fin_plan_option_level_code = 'PLAN_TYPE');

     EXCEPTION
         WHEN NO_DATA_FOUND THEN
           null;
     END; -- BLOCK to check if workplan_type is already attched for the passed project_id - Ends

---------------------------------------------------------
-- If workplan_type is not already attched for the
-- passed project_id then a record is created in
-- pa_proj_fp_options and the default fp txn currencies
-- are created.
---------------------------------------------------------

     IF l_proj_wp_type_exists = 0 THEN

          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Getting the fp option id for the wp plan type of the source project ';
             pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.Add_wp_plan_type: ' || g_module_name,pa_debug.g_err_stage,3);
          END IF;

          IF p_src_project_id <> p_targ_project_id THEN

                BEGIN
                    SELECT proj_fp_options_id
                    INTO   l_src_fp_option_id
                    FROM   pa_proj_fp_options
                    WHERE  project_id=p_src_project_id
                    AND    fin_plan_type_id=l_wp_type_id
                    AND    fin_plan_option_level_code = 'PLAN_TYPE';
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_src_fp_option_id:=NULL;
                END;
          ELSE
             l_src_fp_option_id:=NULL;
          END IF;


          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Calling API pa_proj_fp_options_pub.create_fp_option';
             pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.Add_wp_plan_type: ' || g_module_name,pa_debug.g_err_stage,3);
          END IF;

          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='The source fp option id is '||l_src_fp_option_id;
             pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.Add_wp_plan_type: ' || g_module_name,pa_debug.g_err_stage,3);
          END IF;


         pa_proj_fp_options_pub.Create_FP_Option (
           px_target_proj_fp_option_id          =>  l_proj_fp_options_id
          ,p_source_proj_fp_option_id           =>  l_src_fp_option_id
          ,p_target_fp_option_level_code        =>  PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE
          ,p_target_fp_preference_code          =>  PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY
          ,p_target_fin_plan_version_id         =>  null
          ,p_target_project_id                  =>  p_targ_project_id
          ,p_target_plan_type_id                =>  l_wp_type_id
          ,x_return_status                      =>  l_return_status
          ,x_msg_count                          =>  l_msg_count
          ,x_msg_data                           =>  l_msg_data);

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Called API pa_proj_fp_options_pub.Create_FP_Option returned error';
                   pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.Add_wp_plan_type: ' || g_module_name,pa_debug.g_err_stage,5);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;

           SELECT plan_in_multi_curr_flag
           INTO   l_plan_in_multi_curr_flag
           FROM   pa_proj_fp_options
           WHERE  proj_fp_options_id = l_proj_fp_options_id;

          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Calling API pa_fp_txn_currencies_pub.Copy_Fp_Txn_Currencies';
             pa_debug.write('Add_wp_plan_type: ' || g_module_name,pa_debug.g_err_stage,3);
          END IF;

          PA_FP_TXN_CURRENCIES_PUB.COPY_FP_TXN_CURRENCIES (
             p_source_fp_option_id              =>      l_src_fp_option_id
             ,p_target_fp_option_id             =>      l_proj_fp_options_id
             ,p_target_fp_preference_code       =>      null
             ,p_plan_in_multi_curr_flag         =>      l_plan_in_multi_curr_flag
             ,x_return_status                   =>      l_return_status
             ,x_msg_count                       =>      l_msg_count
             ,x_msg_data                        =>      l_msg_data );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Called API  PA_FP_TXN_CURRENCIES_PUB.COPY_FP_TXN_CURRENCIES returned error';
                   pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.Add_wp_plan_type: ' || g_module_name,pa_debug.g_err_stage,5);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;

     END IF;
	IF l_debug_mode = 'Y' THEN
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
	IF l_debug_mode = 'Y' THEN
           pa_debug.reset_curr_function;
	END IF;
     WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FP_PLANNING_TRANSACTION_PUB'
                                  ,p_procedure_name  => 'PA_FP_PLANNING_TRANSACTION_PUB.Add_wp_plan_type');

           IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.Add_wp_plan_type: ' || g_module_name,pa_debug.g_err_stage,5);
             pa_debug.reset_curr_function;
	  END IF;
          RAISE;

END add_wp_plan_type;

/*=====================================================================
Procedure Name:      check_and_create_task_rec_info
Purpose:             This is a private api in the package. This API will
                      validate the task data passed to the
                      update_planning_transactions api This API checks
                      for the existence of the element version id passed
                      in pa_resource_assignments. If some of the element
                      version Ids are not there then it call
                      add_planning_transactions API to create records in
                      pa_resource_assignments. This API will be called
                      only when the context is WORKPLAN
=======================================================================*/
/*******************************************************************************************************
As part of Bug 3749516 All References to Equipment Effort or Equip Resource Class has been removed in
PROCEDURE check_and_create_task_rec_info.
p_planned_equip_effort_tbl IN parameter has also been removed as they were not being  used/referred.
********************************************************************************************************/
 PROCEDURE check_and_create_task_rec_info
 (
    p_project_id                 IN   Pa_projects_all.project_id%TYPE
   ,p_struct_elem_version_id     IN   Pa_proj_element_versions.element_version_id%TYPE
   ,p_element_version_id_tbl     IN   SYSTEM.PA_NUM_TBL_TYPE
   ,p_planning_start_date_tbl    IN   SYSTEM.PA_DATE_TBL_TYPE
   ,p_planning_end_date_tbl      IN   SYSTEM.PA_DATE_TBL_TYPE
   ,p_planned_people_effort_tbl  IN   SYSTEM.PA_NUM_TBL_TYPE
   ,p_raw_cost_tbl               IN   SYSTEM.PA_NUM_TBL_TYPE      /* Bug 3720357 */
   ,p_burdened_cost_tbl          IN   SYSTEM.PA_NUM_TBL_TYPE      /* Bug 3720357 */
   ,p_apply_progress_flag        IN   VARCHAR2                    /* Bug 3720357 */
   ,x_element_version_id_tbl     OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
   ,x_planning_start_date_tbl    OUT  NOCOPY SYSTEM.PA_DATE_TBL_TYPE --File.Sql.39 bug 4440895
   ,x_planning_end_date_tbl      OUT  NOCOPY SYSTEM.PA_DATE_TBL_TYPE --File.Sql.39 bug 4440895
   ,x_planned_effort_tbl         OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
   ,x_resource_assignment_id_tbl OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
   ,x_raw_cost_tbl               OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE      /* Bug 3720357 */ --File.Sql.39 bug 4440895
   ,x_burdened_cost_tbl          OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE      /* Bug 3720357 */ --File.Sql.39 bug 4440895
   ,x_return_status              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_data                   OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                  OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
) AS
  --Start of variables used for debugging
      l_msg_count          NUMBER :=0;
      l_data               VARCHAR2(2000);
      l_msg_data           VARCHAR2(2000);
      l_error_msg_code     VARCHAR2(30);
      l_msg_index_out      NUMBER;
      l_return_status      VARCHAR2(2000);
      l_debug_mode         VARCHAR2(30);
      l_module_name        VARCHAR2(100):='pa.plsql.pa_fp_planning_transaction_pub.check_and_create_task_rec_info' ;
      l_rec_exsists        VARCHAR2(1);
  --End of variables used for debugging


      l_elem_ver_id_cnt             NUMBER := 0;
      l_ra_id_cnt                   NUMBER := 0;
      l_out_tbl_index               NUMBER := 1;
      l_add_tbl_index               NUMBER := 1;
      l_res_class_code_tbl          SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
      l_ra_id_tbl                   SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
      l_element_version_id_tbl      SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
      l_planning_start_date_tbl     SYSTEM.PA_DATE_TBL_TYPE        := SYSTEM.PA_DATE_TBL_TYPE();
      l_planning_end_date_tbl       SYSTEM.PA_DATE_TBL_TYPE        := SYSTEM.PA_DATE_TBL_TYPE();
      l_planned_people_effort_tbl   SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
      l_raw_cost_tbl                SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
      l_burdened_cost_tbl           SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
      l_index                       NUMBER;
      l_element_version_id_tbl_tmp  SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
      l_planning_start_date_tbl_tmp SYSTEM.PA_DATE_TBL_TYPE        := SYSTEM.PA_DATE_TBL_TYPE();
      l_planning_end_date_tbl_tmp   SYSTEM.PA_DATE_TBL_TYPE        := SYSTEM.PA_DATE_TBL_TYPE();
      l_planned_effort_tbl_tmp      SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
      l_res_assignment_id_tbl_tmp   SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
      l_planned_ppl_effort_tbl_tmp  SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
      l_raw_cost_tbl_tmp            SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
      l_burdened_cost_tbl_tmp       SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();


      cursor c_res_assignment_id(c_wbs_element_version_id pa_resource_assignments.wbs_element_version_id%TYPE) IS
      SELECT resource_assignment_id,resource_class_code
      FROM pa_resource_assignments
      WHERE wbs_element_version_id = c_wbs_element_version_id
      AND ta_display_flag = 'N' -- Bug 3749516
      AND resource_class_code in (PA_FP_CONSTANTS_PKG.G_RESOURCE_CLASS_CODE_PPL);

  BEGIN

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'N');
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
IF l_debug_mode = 'Y' THEN
    PA_DEBUG.Set_Curr_Function( p_function   => 'fp_planning_txn_pub.chk_and_create_task',
                                p_debug_mode => l_debug_mode );
END IF;
-----------------------------------------------------------------------
-- Input Parameter Validation. If no element version id is passed then
-- return.
-----------------------------------------------------------------------
    l_elem_ver_id_cnt := p_element_version_id_tbl.COUNT;

    --Extending the local pl/sql tables. The length of the local tables should be element version id count
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Extending the local pl/sql tbls';
        print_msg(pa_debug.g_err_stage,l_module_name);
    END IF;
    x_element_version_id_tbl     := SYSTEM.PA_NUM_TBL_TYPE();
    x_planning_start_date_tbl    := SYSTEM.PA_DATE_TBL_TYPE();
    x_planning_end_date_tbl      := SYSTEM.PA_DATE_TBL_TYPE();
    x_planned_effort_tbl         := SYSTEM.PA_NUM_TBL_TYPE();
    x_resource_assignment_id_tbl := SYSTEM.PA_NUM_TBL_TYPE();
    x_raw_cost_tbl               := SYSTEM.PA_NUM_TBL_TYPE();
    x_burdened_cost_tbl          := SYSTEM.PA_NUM_TBL_TYPE();
    l_element_version_id_tbl.extend(l_elem_ver_id_cnt);
    l_planning_start_date_tbl.extend(l_elem_ver_id_cnt);
    l_planning_end_date_tbl.extend(l_elem_ver_id_cnt);
    l_planned_people_effort_tbl.extend(l_elem_ver_id_cnt);
    l_raw_cost_tbl.extend(l_elem_ver_id_cnt);
    l_burdened_cost_tbl.extend(l_elem_ver_id_cnt);
    x_element_version_id_tbl.extend(l_elem_ver_id_cnt);
    x_planning_start_date_tbl.extend(l_elem_ver_id_cnt);
    x_planning_end_date_tbl.extend(l_elem_ver_id_cnt);
    x_planned_effort_tbl.extend(l_elem_ver_id_cnt);
    x_resource_assignment_id_tbl.extend(l_elem_ver_id_cnt);
    x_raw_cost_tbl.extend(l_elem_ver_id_cnt);
    x_burdened_cost_tbl.extend(l_elem_ver_id_cnt);

    IF l_elem_ver_id_cnt = 0 THEN
        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Validating input parameters - No element version id is passed - return to calling entity';
           print_msg(pa_debug.g_err_stage,l_module_name);
           pa_debug.reset_curr_function;
	END IF;
       RETURN;
    END IF;

--------------------------------------------------------------------------
-- Logic manifested below ------------------------------------------------
-- -----------------------------------------------------------------------
-- For each record of element version id in input parameter
-- p_element_version_id_tbl, we scan through pa_resource_assignments table
-- and bulk fetch the resource_class_code and resource_assignment_id into
-- local PLSql tables. Now we have a inner loop which we run for each of
-- the resouce_assignment_id fetched corresponding to the elem_ver_id of
-- the parent loop. In the inner loop we populate the corresponding out
-- param tables - x_resource_assignment_id_tbl,x_element_version_id_tbl
-- ,x_planning_end_date_tbl, x_planning_start_date_tbl and
-- x_planned_effort_tbl.
--
-- In case if there no records are retrieved in pa_resource_assignments
-- for any element version id then we populate a separate set of tables
-- from the corresponding IN parameters as l_element_version_id_tbl,
-- l_planning_start_date_tbl,l_planning_end_date_tbl,
-- l_planned_people_effort_tbl.
-- Bug 3720357 - l_raw_cost_tbl and l_burdened_cost_tbl also added.
-- This set of local parameters form the IN parameters for Calling API
-- add_planning_transactions.
--------------------------------------------------------------------------


   IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Iterating through the IN Parameters and Populating the Out parameters.';
           print_msg(pa_debug.g_err_stage,l_module_name);
   END IF;

/* Loop through all element version ids and retrieve ra_id and res_class_code */
       FOR i IN p_element_version_id_tbl.FIRST .. p_element_version_id_tbl.LAST LOOP
           OPEN c_res_assignment_id(p_element_version_id_tbl(i));
                FETCH c_res_assignment_id BULK COLLECT INTO l_ra_id_tbl,l_res_class_code_tbl;
                      l_ra_id_cnt := l_ra_id_tbl.COUNT;
                      IF l_ra_id_cnt>0 THEN
                          l_rec_exsists := 'Y';
                      ELSE
                          l_rec_exsists := 'N';
                      END IF;


/* If there is 1 records in resource_assignments for people then we do not need to call add_planning transaction */
                      IF l_ra_id_cnt = 1 THEN

                         FOR j IN l_ra_id_tbl.FIRST .. l_ra_id_tbl.LAST LOOP
                             x_resource_assignment_id_tbl(l_out_tbl_index) := l_ra_id_tbl(j);
                             IF p_planning_start_date_tbl.EXISTS(i) THEN
                                x_planning_start_date_tbl(l_out_tbl_index) := p_planning_start_date_tbl(i);
                             END IF;

                             IF p_planning_end_date_tbl.EXISTS(i) THEN
                                x_planning_end_date_tbl(l_out_tbl_index) := p_planning_end_date_tbl(i);
                             END IF;
/* In Update Flow for Workplan Context FND_API.G_MISS_XXXX will be considered
   as a valid value for effort/Quantity -- Bug 3640498*/
                             IF (p_raw_cost_tbl.EXISTS(i)) THEN --AND
--                                NVL(p_raw_cost_tbl(i),FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM AND
--                                p_raw_cost_tbl(i) <> 0) THEN
                                x_raw_cost_tbl(l_out_tbl_index) := p_raw_cost_tbl(i);
                             END IF;

                             IF (p_burdened_cost_tbl.EXISTS(i)) THEN -- AND
--                                NVL(p_burdened_cost_tbl(i),FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM AND
--                                p_burdened_cost_tbl(i) <> 0) THEN
                                x_burdened_cost_tbl(l_out_tbl_index) := p_burdened_cost_tbl(i);
                             END IF;

                             x_element_version_id_tbl(l_out_tbl_index) := p_element_version_id_tbl(i);
                             IF l_res_class_code_tbl(j) = PA_FP_CONSTANTS_PKG.G_RESOURCE_CLASS_CODE_PPL THEN
                                IF (p_planned_people_effort_tbl.EXISTS(i)) THEN --AND
--                                   (nvl(p_planned_people_effort_tbl(i),FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM) AND
--                                   (p_planned_people_effort_tbl(i) > 0)) THEN
                                    x_planned_effort_tbl(l_out_tbl_index) := p_planned_people_effort_tbl(i);
                                END IF;
                             END IF;

                             l_out_tbl_index := l_out_tbl_index + 1;
                         END LOOP;
                      END IF;

/* If there are no records in resource_assignments we have to populate the local PLSql tables to call
   add_planning_transactions */
                IF l_rec_exsists = 'N' THEN

                   --Add the record only if either people or equipment effort exists
                   IF ((p_planned_people_effort_tbl.EXISTS(i)) AND
                      (nvl(p_planned_people_effort_tbl(i),FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM) AND
                      /*Bug fix:5726773 (p_planned_people_effort_tbl(i) > 0))*/
 	              (p_planned_people_effort_tbl(i) is NOT NULL))
                      OR
                      (p_raw_cost_tbl.EXISTS(i) AND
                           NVL(p_raw_cost_tbl(i),FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM AND
                           /* bug fix:Bug fix:5726773 p_raw_cost_tbl(i) <> 0) */
 	                   p_raw_cost_tbl(i) is NOT NULL )
                      OR
                      (p_burdened_cost_tbl.EXISTS(i) AND
                           NVL(p_burdened_cost_tbl(i),FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM AND
                           /* bug fix:Bug fix:5726773 P_burdened_cost_tbl(i) <> 0) THEN */
 	                   P_burdened_cost_tbl(i) is NOT NULL) THEN

                       l_element_version_id_tbl(l_add_tbl_index)    := p_element_version_id_tbl(i);
                       IF p_planning_start_date_tbl.EXISTS(i) THEN
                           l_planning_start_date_tbl(l_add_tbl_index) := p_planning_start_date_tbl(i);
                       END IF;

                       IF p_planning_end_date_tbl.EXISTS(i) THEN
                           l_planning_end_date_tbl(l_add_tbl_index) := p_planning_end_date_tbl(i);
                       END IF;

                       IF ((p_planned_people_effort_tbl.EXISTS(i)) AND
                          (nvl(p_planned_people_effort_tbl(i),FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM) AND
                          /* bug fix:5726773 (p_planned_people_effort_tbl(i) > 0)) THEN */
 	                  (p_planned_people_effort_tbl(i) is NOT NULL )) THEN
                       l_planned_people_effort_tbl(l_add_tbl_index) := p_planned_people_effort_tbl(i);
                       END IF;

                       IF (p_raw_cost_tbl.EXISTS(i) AND
                           NVL(p_raw_cost_tbl(i),FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM AND
                           /* bug fix:Bug fix:5726773 p_raw_cost_tbl(i) <> 0) THEN */
 	                   p_raw_cost_tbl(i) is NOT NULL ) THEN
                           l_raw_cost_tbl(l_add_tbl_index) := p_raw_cost_tbl(i);
                       END IF;

                       IF (p_burdened_cost_tbl.EXISTS(i) AND
                           NVL(p_burdened_cost_tbl(i),FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM AND
                           /* bug fix:Bug fix:572677312/29/2006 P_burdened_cost_tbl(i) <> 0) THEN */
 	                   P_burdened_cost_tbl(i) is NOT NULL) THEN
                           l_burdened_cost_tbl(l_add_tbl_index) := p_burdened_cost_tbl(i);
                       END IF;
                      l_add_tbl_index := l_add_tbl_index + 1;

                   END IF;
                END IF;

           CLOSE c_res_assignment_id;
       END LOOP;

   --Prepare the pl/sql tbls that should be returned from the API
    IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Making a copy of the pl/sql tables which should be returned by this API';
           print_msg(pa_debug.g_err_stage,l_module_name);
    END IF;


    l_element_version_id_tbl_tmp.extend(l_out_tbl_index-1);
    l_planning_start_date_tbl_tmp.extend(l_out_tbl_index-1);
    l_planning_end_date_tbl_tmp.extend(l_out_tbl_index-1);
    l_planned_effort_tbl_tmp.extend(l_out_tbl_index-1);
    l_res_assignment_id_tbl_tmp.extend(l_out_tbl_index-1);
    l_raw_cost_tbl_tmp.extend(l_out_tbl_index-1);
    l_burdened_cost_tbl_tmp.extend(l_out_tbl_index-1);

   FOR i in 1..l_out_tbl_index-1 LOOP

        l_element_version_id_tbl_tmp (i):=  x_element_version_id_tbl    (i);
        l_planning_start_date_tbl_tmp(i):=  x_planning_start_date_tbl   (i);
        l_planning_end_date_tbl_tmp  (i):=  x_planning_end_date_tbl     (i);
        l_planned_effort_tbl_tmp     (i):=  x_planned_effort_tbl        (i);
        l_res_assignment_id_tbl_tmp  (i):=  x_resource_assignment_id_tbl(i);
        l_raw_cost_tbl_tmp           (i):=  x_raw_cost_tbl              (i);
        l_burdened_cost_tbl_tmp      (i):=  x_burdened_cost_tbl         (i);

   END LOOP;

   x_element_version_id_tbl    :=l_element_version_id_tbl_tmp ;
   x_planning_start_date_tbl   :=l_planning_start_date_tbl_tmp;
   x_planning_end_date_tbl     :=l_planning_end_date_tbl_tmp  ;
   x_planned_effort_tbl        :=l_planned_effort_tbl_tmp     ;
   x_resource_assignment_id_tbl:=l_res_assignment_id_tbl_tmp  ;
   x_raw_cost_tbl              :=l_raw_cost_tbl_tmp           ;
   x_burdened_cost_tbl         :=l_burdened_cost_tbl_tmp      ;

   --Prepare the pl/sql tbls that should be passed to add planning txn APIs
   IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Making a copy of the pl/sql tables which should be used in calling add plan txn api';
           print_msg(pa_debug.g_err_stage,l_module_name);
    END IF;

    l_element_version_id_tbl_tmp.DELETE;
    l_planning_start_date_tbl_tmp.DELETE;
    l_planning_end_date_tbl_tmp.DELETE;
    l_raw_cost_tbl_tmp.DELETE;
    l_burdened_cost_tbl_tmp.DELETE;
    l_element_version_id_tbl_tmp.extend(l_add_tbl_index-1);
    l_planning_start_date_tbl_tmp.extend(l_add_tbl_index-1);
    l_planning_end_date_tbl_tmp.extend(l_add_tbl_index-1);
    l_planned_ppl_effort_tbl_tmp.extend(l_add_tbl_index-1);
    l_raw_cost_tbl_tmp.extend(l_add_tbl_index-1);
    l_burdened_cost_tbl_tmp.extend(l_add_tbl_index-1);

   FOR i in 1..l_add_tbl_index-1 LOOP

        l_element_version_id_tbl_tmp (i):=  l_element_version_id_tbl    (i);

        l_planning_start_date_tbl_tmp(i):=  l_planning_start_date_tbl   (i);

        l_planning_end_date_tbl_tmp  (i):=  l_planning_end_date_tbl     (i);

        l_planned_ppl_effort_tbl_tmp (i):=  l_planned_people_effort_tbl (i) ;

        l_raw_cost_tbl_tmp (i)          :=  l_raw_cost_tbl (i) ;

        l_burdened_cost_tbl_tmp (i)     :=  l_burdened_cost_tbl (i)  ;

   END LOOP;
    l_element_version_id_tbl   :=l_element_version_id_tbl_tmp ;
    l_planning_start_date_tbl  :=l_planning_start_date_tbl_tmp;
    l_planning_end_date_tbl    :=l_planning_end_date_tbl_tmp  ;
    l_planned_people_effort_tbl:=l_planned_ppl_effort_tbl_tmp ;
    l_raw_cost_tbl             :=l_raw_cost_tbl_tmp ;
    l_burdened_cost_tbl        :=l_burdened_cost_tbl_tmp ;
   IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Calling add_planning_transactions API if index of param tables if greater than 1, l_add_tbl_index:.' || l_add_tbl_index;
           print_msg(pa_debug.g_err_stage,l_module_name);
   END IF;


   IF l_add_tbl_index > 1 THEN

     add_planning_transactions
   (
       p_context                     => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN
      ,p_project_id                  => p_project_id
      ,p_struct_elem_version_id      => p_struct_elem_version_id
      ,p_budget_version_id           => NULL
      ,p_task_elem_version_id_tbl    => l_element_version_id_tbl
      ,p_task_name_tbl               => SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
      ,p_task_number_tbl             => SYSTEM.PA_VARCHAR2_100_TBL_TYPE()
      ,p_start_date_tbl              => l_planning_start_date_tbl
      ,p_end_date_tbl                => l_planning_end_date_tbl
      ,p_planned_people_effort_tbl   => l_planned_people_effort_tbl
      ,p_latest_eff_pub_flag_tbl     => SYSTEM.PA_VARCHAR2_1_TBL_TYPE()
      ,p_resource_list_member_id_tbl => SYSTEM.PA_NUM_TBL_TYPE()
      ,p_quantity_tbl                => SYSTEM.PA_NUM_TBL_TYPE()
      ,p_currency_code_tbl           => SYSTEM.PA_VARCHAR2_15_TBL_TYPE()
      ,p_raw_cost_tbl                => l_raw_cost_tbl
      ,p_burdened_cost_tbl           => l_burdened_cost_tbl
      ,p_revenue_tbl                 => SYSTEM.PA_NUM_TBL_TYPE()
      ,p_cost_rate_tbl               => SYSTEM.PA_NUM_TBL_TYPE()
      ,p_bill_rate_tbl               => SYSTEM.PA_NUM_TBL_TYPE()
      ,p_burdened_rate_tbl           => SYSTEM.PA_NUM_TBL_TYPE()
      ,p_apply_progress_flag         => p_apply_progress_flag
      ,x_return_status               => l_return_status
      ,x_msg_count                   => l_msg_count
      ,x_msg_data                    => l_msg_data
   );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Called API PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions ,api returned error';
          pa_debug.write( l_module_name,pa_debug.g_err_stage,5);
       END IF;
       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    END IF;

	IF l_debug_mode = 'Y' THEN
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
	IF l_debug_mode = 'Y' THEN
           pa_debug.reset_curr_function;
	END IF;
     WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FP_PLANNING_TRANSACTION_PUB'
                                  ,p_procedure_name  => 'check_and_create_task_rec_info');

           IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write( l_module_name,pa_debug.g_err_stage,5);
             pa_debug.reset_curr_function;
	  END IF;
          RAISE;

  END check_and_create_task_rec_info;

/*=============================================================================
 This api would be called for a finplan version, whenever there is a change
 either in planning level or resource list or time phase or rbs version.

 Logic: If no change in any of the parameters, simply return
        If planning level changes
          all the resource assignments would be deleted
          default planning resources are created
        If resource list changes
          all the task, resource mappings are deleted
          for task, financial element planning resources are updated with
          new rlm id and rbs id
        If RBS changes
          all the res assignments are updated with new rbs mapping

 Bug 3867302  Sep 21 2004 For ci versions reporting data is not maintained

 -- Note : This api is also called from PaFinPlanControlItemImpactAMImpl.java with p_time_phase_change_flag as 'Y' to
 --        delete the budget lines.

-- Bug 4724017: CDM Enhancement: Changes in behavior:
              Whenever the planning level is changed for an existing version,
              default planning transaction would be created only for the vesions
              which uses an uncategorized resource list.
-- Bug 5754758: Modified to delete lines from pa_resource_asgn_curr before going to
               create_default_plan_txn api.

==============================================================================*/

PROCEDURE Refresh_Plan_Txns(
           p_budget_version_id         IN   pa_budget_versions.budget_version_id%TYPE
          ,p_plan_level_change         IN   VARCHAR2
          ,p_resource_list_change      IN   VARCHAR2
          ,p_rbs_version_change        IN   VARCHAR2
          ,p_time_phase_change_flag    IN   VARCHAR2
	  ,p_ci_ver_agr_change_flag    IN   VARCHAR2 DEFAULT 'N' --IPM Arch Enhancement Bug 4865563
          ,p_rev_der_method_change     IN   VARCHAR2 DEFAULT 'N' --bug 5152892
          ,x_return_status             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                 OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                  OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS
    --Start of variables used for debugging
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER := 0;
    l_msg_data           VARCHAR2(2000);
    l_data               VARCHAR2(2000);
    l_msg_index_out      NUMBER;
    l_debug_mode         VARCHAR2(30);
    l_error_msg_code     VARCHAR2(30);

    l_people_res_class_rlm_id    pa_resource_list_members.resource_list_member_id%TYPE;
    l_equip_res_class_rlm_id     pa_resource_list_members.resource_list_member_id%TYPE;
    l_fin_res_class_rlm_id       pa_resource_list_members.resource_list_member_id%TYPE;
    l_mat_res_class_rlm_id       pa_resource_list_members.resource_list_member_id%TYPE;

    l_txn_source_id_tbl          SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    l_res_list_member_id_tbl     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    l_rbs_element_id_tbl         SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    l_txn_accum_header_id_tbl    SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

    l_budget_version_id_tbl      SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

    -- IPM changes Bug 5003827 Issue 22
    l_fp_cols_rec                   pa_fp_gen_amount_utils.fp_cols;
    l_delete_ra_id_tbl           SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    l_delete_flag VARCHAR2(1); -- Bug 5003827 Issue 28
    l_rollup_flag  VARCHAR2(1); -- Bug 5003827 Issue 28
    -- END of IPM changes Bug 5003827 Issue 22

    CURSOR  budget_version_info_cur IS
    SELECT  bv.project_id project_id
           ,bv.resource_list_id
           ,Decode(bv.version_type
                    ,'COST',    cost_fin_plan_level_code
                    ,'REVENUE', revenue_fin_plan_level_code
                    ,'ALL',     all_fin_plan_level_code) fin_plan_level_code
           ,pfo.rbs_version_id         rbs_version_id
           ,pfo.fin_plan_type_id       fin_plan_type_id
           ,bv.ci_id                   ci_id
      FROM  pa_proj_fp_options pfo, pa_budget_versions bv
     WHERE  bv.project_id           = pfo.project_id
       AND  pfo.fin_plan_version_id = bv.budget_version_id
       AND  bv.budget_version_id    = p_budget_version_id;

   budget_version_info_rec budget_version_info_cur%ROWTYPE;

   -- added for bug 4724017:
   l_res_list_uncategorized_flag   pa_resource_lists_all_bg.uncategorized_flag%TYPE;

BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

    -- Set curr function
IF l_debug_mode = 'Y' THEN
    PA_DEBUG.set_curr_function(
                p_function   =>'PA_FP_PLANNING_TRANSACTION_PUB.Refresh_Plan_Txns'
               ,p_debug_mode => l_debug_mode );
END IF;
    -- Check for business rules violations

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Validating input parameters';
        pa_debug.write('Refresh_Plan_Txns: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_budget_version_id   IS  NULL)
    THEN

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='p_budget_version_id = '|| p_budget_version_id;
           pa_debug.write('Refresh_Plan_Txns: ' ||g_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_FP_INV_PARAM_PASSED');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    -- If there is no change in planning level or res list or RBS return

    IF  nvl(p_plan_level_change, 'N')      = 'N' AND
        nvl(p_resource_list_change, 'N')   = 'N' AND
        nvl(p_rbs_version_change, 'N')     = 'N' AND
        nvl(p_time_phase_change_flag, 'N') = 'N' AND
        nvl(p_rev_der_method_change,'N')   = 'N' --Bug 5462471
    THEN
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='No change required, Exiting Refresh_Plan_Txns';
            pa_debug.write('Refresh_Plan_Txns: ' || g_module_name,pa_debug.g_err_stage,3);
           -- reset curr function
          pa_debug.Reset_Curr_Function();
	END IF;
        RETURN;
    END IF;

    OPEN budget_version_info_cur;
    FETCH budget_version_info_cur INTO budget_version_info_rec;
    CLOSE budget_version_info_cur;

    IF  nvl(p_plan_level_change, 'N')      = 'Y' OR
        nvl(p_resource_list_change, 'N')   = 'Y' OR
        nvl(p_time_phase_change_flag, 'N') = 'Y' OR
        nvl(p_rev_der_method_change,'N')   = 'Y' --Bug 5462471

    THEN
          -- Delete all the budget lines for the budget version

          -- Bug Fix: 4569365. Removed MRC code.
          /*
          DELETE
          FROM    pa_mc_budget_lines
          WHERE   budget_version_id = p_budget_version_id;
          */

          DELETE
          FROM    pa_budget_lines
          WHERE   budget_version_id = p_budget_version_id;

          -- --IPM Arch Enhancement Bug 4865563, Bug 5003827 Issue 28
          IF (nvl(p_ci_ver_agr_change_flag,'N') = 'Y'
              OR nvl(p_time_phase_change_flag, 'N') = 'Y') THEN

            pa_fp_gen_amount_utils.get_plan_version_dtls
             (p_budget_version_id  => p_budget_version_id,
              x_fp_cols_rec        => l_fp_cols_rec,
              x_return_status      => x_return_status,
              x_msg_count          => x_msg_count,
              x_msg_data           => x_msg_data);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

              IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Called API pa_fp_gen_amount_utils.get_plan_version_dtls returned error';
                pa_debug.WRITE('pa_fp_planning_transaction_pub.Refresh_Plan_Txns',pa_debug.g_err_stage, 3);
              END IF;
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            -- Bug 5003827 Issue 28
            IF nvl(p_ci_ver_agr_change_flag,'N') = 'Y' THEN
              l_delete_flag := 'Y';
              l_rollup_flag := 'N';
            ELSE -- nvl(p_time_phase_change_flag, 'N') = 'Y'

              l_delete_flag := 'N';
              l_rollup_flag := 'Y';
            END IF;
            -- END Bug 5003827 Issue 28

            pa_res_asg_currency_pub.maintain_data(
              p_fp_cols_rec                  => l_fp_cols_rec,
              p_calling_module               => 'UPDATE_PLAN_TRANSACTION',
              p_delete_flag                  =>  l_delete_flag, -- Bug 5003827 Issue 28
              p_copy_flag                    => 'N',
              p_src_version_id               => NULL,
              p_copy_mode                    => NULL,
              p_rollup_flag                  => l_rollup_flag, -- Bug 5003827 Issue 28
              p_version_level_flag           => 'Y',
              p_called_mode                  => 'SELF_SERVICE',
              x_return_status                => x_return_status,
              x_msg_count                    => x_msg_count,
              x_msg_data                     => x_msg_data
            );

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

              IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Called API pa_res_asg_currency_pub.maintain_data returned error';
                pa_debug.WRITE('pa_fp_planning_transaction_pub.Refresh_Plan_Txns',pa_debug.g_err_stage, 3);
              END IF;
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

          END IF;
          ----IPM Arch Enhancement Bug 4865563


          IF  nvl(p_plan_level_change, 'N')      = 'Y' OR
          nvl(p_rev_der_method_change,'N')   = 'Y' THEN --Bug 5462471
              -- Delete all the planning transactions for the version.

              IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Deleting all the resource assignment records for the version';
                   pa_debug.write('Refresh_Plan_Txns: ' || g_module_name,pa_debug.g_err_stage,3);
              END IF;

              DELETE
              FROM   pa_resource_assignments
              WHERE  budget_version_id = p_budget_version_id
              -- IPM changes Bug 5003827 Issue 22
              RETURNING resource_assignment_id  BULK COLLECT INTO l_delete_ra_id_tbl;
              /* Bug 5754758 - Commenting the code, as the maintain_data is now called in version level mode to delete the RACs.
              IF l_delete_ra_id_tbl.COUNT > 0 THEN
                 FORALL i IN l_delete_ra_id_tbl.first .. l_delete_ra_id_tbl.last
                   INSERT INTO pa_resource_asgn_curr_tmp
                        (RA_TXN_ID
                        ,RESOURCE_ASSIGNMENT_ID
                        ,DELETE_FLAG
                        )
                        SELECT pa_resource_asgn_curr_s.NEXTVAL
                              ,l_delete_ra_id_tbl(i)
                              ,'Y'
                        FROM DUAL;
              END IF;
              -- END of IPM changes Bug 5003827 Issue 22
               */
         ----IPM Arch Enhancement Bug 5754758/4865563
          IF l_delete_ra_id_tbl.COUNT > 0 THEN --{
             pa_fp_gen_amount_utils.get_plan_version_dtls
             (p_budget_version_id  => p_budget_version_id,
              x_fp_cols_rec        => l_fp_cols_rec,
              x_return_status      => x_return_status,
              x_msg_count          => x_msg_count,
              x_msg_data           => x_msg_data);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

              IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Called API pa_fp_gen_amount_utils.get_plan_version_dtls returned error';
                pa_debug.WRITE('pa_fp_planning_transaction_pub.Refresh_Plan_Txns',pa_debug.g_err_stage, 3);
              END IF;
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            pa_res_asg_currency_pub.maintain_data(
              p_fp_cols_rec                  => l_fp_cols_rec,
              p_calling_module               => 'UPDATE_PLAN_TRANSACTION',
              p_delete_flag                  =>  'Y',
              p_copy_flag                    => 'N',
              p_src_version_id               => NULL,
              p_copy_mode                    => NULL,
              p_rollup_flag                  => 'N',
              p_version_level_flag           => 'Y',
              p_called_mode                  => 'SELF_SERVICE',
              x_return_status                => x_return_status,
              x_msg_count                    => x_msg_count,
              x_msg_data                     => x_msg_data
            );

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

              IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Called API pa_res_asg_currency_pub.maintain_data returned error';
                pa_debug.WRITE('pa_fp_planning_transaction_pub.Refresh_Plan_Txns',pa_debug.g_err_stage, 3);
              END IF;
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

          END IF;
          ----IPM Arch Enhancement Bug 5754758/4865563

              -- bug 4724017: Checking for categorized resource list to avoid
              -- calling create_default_task_plan_txns, not to create default
              -- planning txns for categorized RLs, when planning level changes.
              IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='Fetching uncategorized flag when planning level changes';
                 pa_debug.write('Refresh_Plan_Txns: ' || g_module_name,pa_debug.g_err_stage,3);
              END IF;
              BEGIN
                SELECT nvl(uncategorized_flag,'N')
                INTO   l_res_list_uncategorized_flag
                FROM   pa_resource_lists_all_bg
                WHERE  resource_list_id = budget_version_info_rec.resource_list_id;

                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='l_res_list_uncategorized_flag: ' || l_res_list_uncategorized_flag;
                    pa_debug.write('Refresh_Plan_Txns: ' || g_module_name,pa_debug.g_err_stage,3);
                END IF;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:='No uncategorized flag found for the resource list id passed';
                        pa_debug.write('Refresh_Plan_Txns: ' || g_module_name,pa_debug.g_err_stage,3);
                    END IF;
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
              END;

              -- added for bug 4724017:
              -- Creation of default planning transaction is not done for versions
              -- being created with categorized resource list.
              IF l_res_list_uncategorized_flag = 'Y' THEN
                  -- Insert default task planning trasaction for the version

                  IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:='Calling pa_fp_planning_transaction_pub.create_default_task_plan_txns';
                      pa_debug.write('Refresh_Plan_Txns: ' || g_module_name,pa_debug.g_err_stage,3);
                  END IF;

                  pa_fp_planning_transaction_pub.create_default_task_plan_txns (
                               p_budget_version_id        =>   p_budget_version_id
                              ,p_version_plan_level_code  =>   budget_version_info_rec.fin_plan_level_code
                              ,x_return_status            =>   x_return_status
                              ,x_msg_count                =>   x_msg_count
                              ,x_msg_data                 =>   x_msg_data );

                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;

              END IF; -- end bug 4724017
          END IF;

          IF  nvl(p_resource_list_change, 'N') = 'Y'  THEN

              -- Delete all the planning resources where neither rlmID is 0
              -- Or resource is 'FINANCIAL_ELEMENTS'
              -- Bug 3658232 added null handling for resource class flag

              DELETE FROM pa_resource_assignments
              WHERE  budget_version_id = p_budget_version_id
              AND
                NOT (resource_class_code = 'FINANCIAL_ELEMENTS' AND nvl(resource_class_flag,'N') = 'Y')
              -- IPM changes Bug 5003827 Issue 22
              RETURNING resource_assignment_id BULK COLLECT INTO l_delete_ra_id_tbl;

              IF l_delete_ra_id_tbl.COUNT > 0 THEN
                 FORALL i IN l_delete_ra_id_tbl.first .. l_delete_ra_id_tbl.last
                   INSERT INTO pa_resource_asgn_curr_tmp
                        (RA_TXN_ID
                        ,RESOURCE_ASSIGNMENT_ID
                        ,DELETE_FLAG
                        )
                        SELECT pa_resource_asgn_curr_s.NEXTVAL
                              ,l_delete_ra_id_tbl(i)
                              ,'Y'
                        FROM DUAL;
              END IF;
              -- END of IPM changes Bug 5003827 Issue 22


              -- Fetch rlm id of FINANCIAL ELEMENT resource class for new resource list id

              PA_PLANNING_TRANSACTION_UTILS.Get_Res_Class_Rlm_Ids
                   ( p_project_id                   =>    budget_version_info_rec.project_id
                    ,p_resource_list_id             =>    budget_version_info_rec.resource_list_id
                    ,x_people_res_class_rlm_id      =>    l_people_res_class_rlm_id
                    ,x_equip_res_class_rlm_id       =>    l_equip_res_class_rlm_id
                    ,x_fin_res_class_rlm_id         =>    l_fin_res_class_rlm_id
                    ,x_mat_res_class_rlm_id         =>    l_mat_res_class_rlm_id
                    ,x_return_status                =>    l_return_status
                    ,x_msg_count                    =>    l_msg_count
                    ,x_msg_data                     =>    l_msg_data);

              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:='Called API PA_PLANNING_TRANSACTION_UTILS.Get_Res_Class_Rlm_Ids api returned error';
                     pa_debug.write('Refresh_Plan_Txns:  ' || g_module_name,pa_debug.g_err_stage,5);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
              END IF;

              -- Update all the task planning elements with new FINACIAL ELEMENT rlmid
              IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:='Updaing res assignments with new FINANCIAL ELEMENTS rlmid : ' || l_fin_res_class_rlm_id;
                  pa_debug.write('Refresh_Plan_Txns: ' || g_module_name,pa_debug.g_err_stage,3);
              END IF;

              UPDATE pa_resource_assignments
              SET    resource_list_member_id  = l_fin_res_class_rlm_id
              WHERE  budget_version_id = p_budget_version_id;
              --AND    resource_class_code = 'FINANCIAL_ELEMENTS'  --Bug 4200168. RL/PL change both can not happen at the same time.
              --AND    resource_class_flag = 'Y';

          END IF;

          -- IPM changes Bug 5003827 Issue 22
          IF l_delete_ra_id_tbl.COUNT > 0 THEN --{
            pa_fp_gen_amount_utils.get_plan_version_dtls
             (p_project_id         => budget_version_info_rec.project_id,
              p_budget_version_id  => p_budget_version_id,
              x_fp_cols_rec        => l_fp_cols_rec,
              x_return_status      => x_return_status,
              x_msg_count          => x_msg_count,
              x_msg_data           => x_msg_data);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

              IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Called API pa_fp_gen_amount_utils.get_plan_version_dtls returned error';
                pa_debug.WRITE('pa_fp_planning_transaction_pub.Refresh_Plan_Txns',pa_debug.g_err_stage, 3);
              END IF;
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            pa_res_asg_currency_pub.maintain_data(
              p_fp_cols_rec                  => l_fp_cols_rec,
              p_calling_module               => 'UPDATE_PLAN_TRANSACTION',
              p_delete_flag                  => 'Y',
              p_copy_flag                    => 'N',
              p_src_version_id               => NULL,
              p_copy_mode                    => NULL,
              p_rollup_flag                  => 'N',
              p_version_level_flag           => 'N',
              p_called_mode                  => 'SELF_SERVICE',
              x_return_status                => x_return_status,
              x_msg_count                    => x_msg_count,
              x_msg_data                     => x_msg_data
            );

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

              IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Called API pa_res_asg_currency_pub.maintain_data returned error';
                pa_debug.WRITE('pa_fp_planning_transaction_pub.Refresh_Plan_Txns',pa_debug.g_err_stage, 3);
              END IF;
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
          END IF; --} IF l_delete_ra_id_tbl.COUNT > 0 THEN
          -- END of IPM changes Bug 5003827 Issue 22


          -- Calling the rollup api to correct the amounts related data in
          -- pa_budget_versions and pa_resource_assignments for the entire version
          PA_FP_ROLLUP_PKG.rollup_budget_version
                      (p_budget_version_id   => p_budget_version_id
                      ,p_entire_version     => 'Y'
                      ,x_return_status      => l_return_status
                      ,x_msg_count          => l_msg_count
                      ,x_msg_data           => l_msg_data);

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:='Called API PA_FP_ROLLUP_PKG.rollup_budget_version returned error';
                     pa_debug.write('Refresh_Plan_Txns:  ' || g_module_name,pa_debug.g_err_stage,5);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;
    END IF;

    -- Note: As of now rbs can not be changed at version level.
    -- It can only be changed at plan type level. This has been
    -- the initial design and not changed
    IF nvl(p_rbs_version_change, 'N') = 'Y' AND
       (budget_version_info_rec.ci_id IS NULL) -- bug 3867302
    THEN

        Refresh_rbs_for_versions(
           p_project_id           => budget_version_info_rec.project_id
          ,p_fin_plan_type_id     => budget_version_info_rec.fin_plan_type_id
          ,p_calling_context      => 'SINGLE_VERSION'
          ,p_budget_version_id    => p_budget_version_id
          ,x_return_status        => l_return_status
          ,x_msg_count            => l_msg_count
          ,x_msg_data             => l_msg_data);

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:='Called API Refresh_rbs_for_versions returned error';
                     pa_debug.write('Refresh_Plan_Txns:  ' || g_module_name,pa_debug.g_err_stage,5);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;
    END IF;

    -- If Planning Level, Resource list or Time phasing is changed, calling PJI apis for
    -- correct summarization data
    IF  (budget_version_info_rec.ci_id IS NULL) AND -- bug 3867302
        (nvl(p_rbs_version_change, 'N') = 'N') AND -- put for clarity
        (nvl(p_plan_level_change, 'N') = 'Y' OR
          nvl(p_resource_list_change, 'N') = 'Y' OR
          nvl(p_time_phase_change_flag, 'N') = 'Y' OR
          nvl(p_rev_der_method_change,'N') ='Y' )--Bug 5462471
    THEN
          -- populating the l_budget_version_id_tbl with p_budget_version_id
          l_budget_version_id_tbl := SYSTEM.pa_num_tbl_type(p_budget_version_id);

          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Calling PJI_FM_XBS_ACCUM_MAINT.PLAN_DELETE';
               pa_debug.write('Refresh_Plan_Txns: ' || g_module_name,pa_debug.g_err_stage,3);
          END IF;

          -- Call PJI delete api first to delete existing summarization data
          PJI_FM_XBS_ACCUM_MAINT.PLAN_DELETE (
                  p_fp_version_ids   => l_budget_version_id_tbl,
                  x_return_status    => l_return_status,
                  x_msg_code         => l_error_msg_code);

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                     p_msg_name            => l_error_msg_code);
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;

          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Call complete to PJI_FM_XBS_ACCUM_MAINT.PLAN_DELETE';
               pa_debug.write('Refresh_Plan_Txns: ' || g_module_name,pa_debug.g_err_stage,3);
          END IF;

          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Calling PJI_FM_XBS_ACCUM_MAINT.PLAN_CREATE';
               pa_debug.write('Refresh_Plan_Txns: ' || g_module_name,pa_debug.g_err_stage,3);
          END IF;

          -- Call PLAN_CREATE to create summarization data as per the new RBS
          PJI_FM_XBS_ACCUM_MAINT.PLAN_CREATE (
                p_fp_version_ids   => l_budget_version_id_tbl,
                x_return_status    => l_return_status,
                x_msg_code         => l_error_msg_code);

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                     p_msg_name            => l_error_msg_code);
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;

          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Call complete to PJI_FM_XBS_ACCUM_MAINT.PLAN_CREATE';
               pa_debug.write('Refresh_Plan_Txns: ' || g_module_name,pa_debug.g_err_stage,3);
          END IF;

    END IF;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Exiting Refresh_Plan_Txns';
        pa_debug.write('Refresh_Plan_Txns: ' || g_module_name,pa_debug.g_err_stage,3);
    -- reset curr function
    pa_debug.Reset_Curr_Function();
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

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Invalid Arguments Passed Or called api raised an error';
           pa_debug.write('Refresh_Plan_Txns: ' || g_module_name,pa_debug.g_err_stage,5);
       -- reset curr function
          pa_debug.Reset_Curr_Function();
	END IF;

       RETURN;
   WHEN Others THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FP_PLANNING_TRANSACTION_PUB'
                               ,p_procedure_name  => 'Refresh_Plan_Txns');

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write('Refresh_Plan_Txns: ' || g_module_name,pa_debug.g_err_stage,5);
       -- reset curr function
          pa_debug.Reset_Curr_Function();
       END IF;
       RAISE;
END Refresh_Plan_Txns;


/* This api will call add_planning_transaction in such a way that calculate api would
   never be called . For IPM development added two parameters p_calling_context .
   This will be passed as SELECT_TASKS from the select tasks page. The add planning
   transactions will be called from here passing the context as create_version. This
   is because this flow is also used from the add tasks and resources page to add the
   tasks and resources as planning elements depending on the choice.*/
PROCEDURE Create_Default_Task_Plan_Txns (
        P_budget_version_id              IN              Number
       ,P_version_plan_level_code        IN              VARCHAR2
       ,p_calling_context                IN              VARCHAR2
       ,p_add_all_resources_flag         IN              VARCHAR2
       ,X_return_status                  OUT             NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       ,X_msg_count                      OUT             NOCOPY NUMBER --File.Sql.39 bug 4440895
       ,X_msg_data                       OUT             NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
AS


     l_module_name varchar2(100):= 'pa.plsql.pa_fp_planning_transaction_pub';

 -- Start of variables used for debugging purpose
     l_msg_count          NUMBER :=0;
     l_data               VARCHAR2(2000);
     l_msg_data           VARCHAR2(2000);
     l_error_msg_code     VARCHAR2(30);
     l_msg_index_out      NUMBER;
     l_return_status      VARCHAR2(2000);
     l_debug_mode         VARCHAR2(30);
 -- End of variables used for debugging purpose

CURSOR version_info_cur (c_budget_version_id number) is
select  bv.project_id
       ,PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) STRUCTURE_VERSION_ID --Bug 3546208
       ,bv.fin_plan_type_id
       ,Decode(bv.version_type,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST,pfo.cost_fin_plan_level_code
                              ,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE,pfo.revenue_fin_plan_level_code
                              ,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL,pfo.all_fin_plan_level_code) plan_level_code
       ,DECODE(fin_plan_preference_code,
                 PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME, pfo.all_resource_list_id,
                 PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY,         pfo.cost_resource_list_id,
                 PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY,      pfo.revenue_resource_list_id) resource_list_id
 from  pa_budget_versions bv,
       pa_proj_fp_options pfo
where  bv.budget_version_id = c_budget_version_id
  and  pfo.project_id = bv.project_id
  and  pfo.fin_plan_type_id = bv.fin_plan_type_id
  and  pfo.fin_plan_version_id = bv.budget_version_id;

version_info_rec version_info_cur%ROWTYPE;

CURSOR lowest_tasks_cur (c_parent_structure_version_id number) is
select v.element_version_id
from   pa_struct_task_wbs_v v
where  v.parent_structure_version_id = c_parent_structure_version_id
and    v.financial_task_flag = 'Y'  -- raja bug 3690418
and    v.task_level = 'L'
and    not exists (select 'x'
                   from   pa_resource_assignments pra
                   where  pra.budget_version_id = P_budget_version_id
                   and    pra.task_id = v.task_id
                   and    p_calling_context = 'SELECT_TASKS');

CURSOR top_tasks_cur (c_project_id number, c_parent_structure_version_id number) is
select b.element_version_id
from   pa_tasks a, pa_proj_element_versions b
/* Replaced pa_struct_task_wbs_v with base tables for performance reasons.
 * Note that financial_task_flag of pa_proj_element_versions cannot be used
 * since it is set to Y even for tasks that are part of fin struct ver but not
 * yet published. (I.e., It could be Y for tasks not present in pa_tasks too). This
 * required a join with pa_tasks to identify true fin tasks which can be
 * budgeted for */
where  b.parent_structure_version_id = c_parent_structure_version_id
and    b.object_type = 'PA_TASKS'
and    a.project_id = c_project_id
and    a.project_id = b.project_id
and    a.task_id = b.proj_element_id
and    a.task_id = a.top_task_id
and    not exists (select 'x'
                   from   pa_resource_assignments pra
                   where  pra.budget_version_id = P_budget_version_id
                   and    pra.task_id = a.task_id
                   and    p_calling_context = 'SELECT_TASKS');

l_max_fetch_size                  NUMBER := 200;

l_element_version_id_tbl SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();

--l_proj_element_id_tbl element_versions_tbl1_type;
--l_element_version_id_tbl  element_versions_tbl2_type;
l_resource_list_member_id_tbl SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();

l_start_date pa_projects_all.start_date%TYPE;
l_completion_date pa_projects_all.completion_date%TYPE;

l_res_list_is_uncategorized   VARCHAR2(1);
l_is_resource_list_grouped    VARCHAR2(1);
l_group_resource_type_id      NUMBER;

l_people_res_class_rlm_id    pa_resource_list_members.resource_list_member_id%TYPE;
l_equip_res_class_rlm_id     pa_resource_list_members.resource_list_member_id%TYPE;
l_fin_res_class_rlm_id       pa_resource_list_members.resource_list_member_id%TYPE :=0;
l_mat_res_class_rlm_id       pa_resource_list_members.resource_list_member_id%TYPE;

l_plan_class_code pa_fin_plan_types_b.plan_class_code%TYPE;

BEGIN
     FND_MSG_PUB.initialize;
     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');
IF l_debug_mode = 'Y' THEN
     pa_debug.set_curr_function( p_function => 'Create_Default_Task_Plan_Txns',
                                 p_debug_mode => l_debug_mode );
END IF;
     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;


     -- Check for business rules violations

     IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:='Validating input parameters';
         pa_debug.write('Create_Default_Task_Plan_Txns: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

     -- Check if budget version id is null

     IF (P_budget_version_id  IS NULL) OR
        (nvl(p_calling_context,'-1') NOT IN ('CREATE_VERSION','SELECT_TASKS')) OR
        (nvl(p_add_all_resources_flag,'x') NOT IN ('Y','N'))
     THEN

         IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='P_budget_version_id = '||P_budget_version_id;
             pa_debug.write('Create_Default_Task_Plan_Txns: ' || l_module_name,pa_debug.g_err_stage,5);
         END IF;

         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

         IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Invalid Arguments Passed';
             pa_debug.write('Create_Default_Task_Plan_Txns: ' || l_module_name,pa_debug.g_err_stage,5);
         END IF;
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

     END IF;

 --Fetch budget version values

     IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:='Fetching budget version properties';
         pa_debug.write('Create_Default_Task_Plan_Txns: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

     OPEN version_info_cur(P_budget_version_id);
     FETCH version_info_cur INTO version_info_rec;
     CLOSE version_info_cur;

          --hr_utility.trace('G_BUDGET_ENTRY_LEVEL_LOWEST -> valueof input '|| P_version_plan_level_code);
     IF P_version_plan_level_code IS NOT NULL THEN
         version_info_rec.plan_level_code := P_version_plan_level_code;
     END IF;
          --hr_utility.trace('G_BUDGET_ENTRY_LEVEL_LOWEST -> valueof version_info_rec '|| version_info_rec.plan_level_code);

 --Fetch Start Date and Completion Date

     BEGIN
         SELECT start_date,completion_date
         INTO l_start_date,l_completion_date
         FROM pa_projects_all
         WHERE project_id = version_info_rec.project_id;
     EXCEPTION
         WHEN OTHERS THEN
              IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='Error while fetching start and completion dates for the project';
                 pa_debug.write('Create_Default_Task_Plan_Txns: ' || l_module_name,pa_debug.g_err_stage,3);
              END IF;
              RAISE;
     END;


         PA_PLANNING_TRANSACTION_UTILS.Get_Res_Class_Rlm_Ids
         (p_project_id                   =>    version_info_rec.project_id,
          p_resource_list_id             =>    version_info_rec.resource_list_id,
          x_people_res_class_rlm_id      =>    l_people_res_class_rlm_id,
          x_equip_res_class_rlm_id       =>    l_equip_res_class_rlm_id ,
          x_fin_res_class_rlm_id         =>    l_fin_res_class_rlm_id   ,
          x_mat_res_class_rlm_id         =>    l_mat_res_class_rlm_id   ,
          x_return_status                =>    l_return_status,
          x_msg_count                    =>    l_msg_count,
          x_msg_data                     =>    l_msg_data);
          --hr_utility.trace('G_BUDGET_ENTRY_LEVEL_LOWEST -> rlmids'|| l_people_res_class_rlm_id || 'x' || l_equip_res_class_rlm_id || 'x' || l_fin_res_class_rlm_id || 'x' || l_mat_res_class_rlm_id);

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Called API PA_PLANNING_TRANSACTION_UTILS.Get_Res_Class_Rlm_Ids api returned error';
                pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.Create_Default_Task_Plan_Txns:  ' || l_module_name,pa_debug.g_err_stage,5);
             END IF;
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;

     BEGIN
        SELECT plan_class_code
        INTO l_plan_class_code
        FROM pa_fin_plan_types_b
        where fin_plan_type_id = version_info_rec.fin_plan_type_id;

     EXCEPTION
         WHEN OTHERS THEN
              IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:='Error while fetching plan_class_code for the budget_version_id';
                  pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.Create_Default_Task_Plan_Txns: ' || l_module_name,pa_debug.g_err_stage,5);
               END IF;
              RAISE;
     END;

          --hr_utility.trace('G_BUDGET_ENTRY_LEVEL_LOWEST -> plan_class_code '|| l_plan_class_code);

     IF p_add_all_resources_flag <> 'Y' THEN
         l_resource_list_member_id_tbl.extend(1);
         l_resource_list_member_id_tbl(1):= l_fin_res_class_rlm_id;
     ELSE
         SELECT resource_list_member_id BULK COLLECT
         INTO l_resource_list_member_id_tbl
         FROM   pa_resource_list_members prl,
                PA_PLAN_RES_DEFAULTS pr, /*7291493*/
               (SELECT  control_flag
                FROM    pa_resource_lists_all_bg
                WHERE   resource_list_id = version_info_rec.resource_list_id) rl_control_flag
         WHERE resource_list_id = version_info_rec.resource_list_id
         AND   ((rl_control_flag.control_flag = 'N' AND
                 prl.object_type = 'PROJECT' AND
                 prl.object_id = version_info_rec.project_id)
                 OR
                (rl_control_flag.control_flag = 'Y' AND
                 prl.object_type = 'RESOURCE_LIST' AND
                 prl.object_id = version_info_rec.resource_list_id)) AND
                 prl.resource_class_id = pr.resource_class_id AND
                 pr.enabled_flag = 'Y';
     END IF;


     IF version_info_rec.plan_level_code = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT THEN
            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'Planning at project level: Inserting a record';
                pa_debug.write('Create_Default_Task_Plan_Txns: ' || l_module_name,pa_debug.g_err_stage,3);
            END IF;

        l_element_version_id_tbl.extend(1);
            l_element_version_id_tbl(1):= 0;

            pa_fp_planning_transaction_pub.add_planning_transactions (
            p_context                     =>      l_plan_class_code
            /* Passing calling module as creation version, since we dont want calculate api to be called */
           ,p_calling_module              =>      'CREATE_VERSION'
           ,p_project_id                  =>      version_info_rec.project_id
           ,p_budget_version_id           =>      p_budget_version_id
           ,p_task_elem_version_id_tbl    =>      l_element_version_id_tbl
           ,p_resource_list_member_id_tbl =>      l_resource_list_member_id_tbl
           ,x_return_status               =>      l_return_status
           ,x_msg_count                   =>      l_msg_count
           ,x_msg_data                    =>      l_msg_data     );

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='Called API PA_PLANNING_TRANSACTION_UTILS.Get_Res_Class_Rlm_Ids api returned error';
                     pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.Create_Default_Task_Plan_Txns:  ' || l_module_name,pa_debug.g_err_stage,5);
              END IF;
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;


    ELSIF version_info_rec.plan_level_code = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_TOP THEN
            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'Planning at top task level: Opening cursor top_tasks_cur';
                pa_debug.write('Create_Default_Task_Plan_Txns: ' || l_module_name,pa_debug.g_err_stage,3);
            END IF;

            OPEN top_tasks_cur( version_info_rec.project_id, version_info_rec.structure_version_id);

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'Fetching cursor values for top tasks and doing bulk insert';
                pa_debug.write('Create_Default_Task_Plan_Txns: ' || l_module_name,pa_debug.g_err_stage,3);
            END IF;

        LOOP
            FETCH top_tasks_cur BULK COLLECT INTO l_element_version_id_tbl LIMIT l_max_fetch_size;

            IF nvl(l_element_version_id_tbl.last,0) >= 1 THEN
                pa_fp_planning_transaction_pub.add_planning_transactions (
                p_context                     =>      l_plan_class_code
                /* Passing calling module as creation version, since we dont want calculate api to be called */
               ,p_calling_module              =>      'CREATE_VERSION'
               ,p_project_id                  =>      version_info_rec.project_id
               ,p_budget_version_id           =>      p_budget_version_id
               ,p_task_elem_version_id_tbl    =>      l_element_version_id_tbl
               ,p_resource_list_member_id_tbl =>      l_resource_list_member_id_tbl
               ,x_return_status               =>      l_return_status
               ,x_msg_count                   =>      l_msg_count
               ,x_msg_data                    =>      l_msg_data     );
            END IF;

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Called API PA_PLANNING_TRANSACTION_UTILS.Get_Res_Class_Rlm_Ids api returned error';
                    pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.Create_Default_Task_Plan_Txns:  ' || l_module_name,pa_debug.g_err_stage,5);
                 END IF;
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
       -- Exit if fetch size is less than 200
            EXIT WHEN NVL(l_element_version_id_tbl.last,0) < l_max_fetch_size;
        END LOOP;

        CLOSE top_tasks_cur;

    ELSIF version_info_rec.plan_level_code = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_LOWEST THEN
          --hr_utility.trace('G_BUDGET_ENTRY_LEVEL_LOWEST -> '||PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_LOWEST);

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Planning at lowest task level: Opening cursor lowest_tasks_cur';
            pa_debug.write('Create_Default_Task_Plan_Txns: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        OPEN lowest_tasks_cur( version_info_rec.structure_version_id);

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Fetching cursor values for lowest tasks and doing bulk insert';
            pa_debug.write('Create_Default_Task_Plan_Txns: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;



        LOOP
            FETCH lowest_tasks_cur BULK COLLECT INTO l_element_version_id_tbl LIMIT l_max_fetch_size;

               IF nvl(l_element_version_id_tbl.last,0) >= 1 THEN
                    pa_fp_planning_transaction_pub.add_planning_transactions (
                    p_context                     =>      l_plan_class_code
                    /* Passing calling module as creation version, since we dont want calculate api to be called */
                   ,p_calling_module              =>      'CREATE_VERSION'
                   ,p_project_id                  =>      version_info_rec.project_id
                   ,p_budget_version_id           =>      p_budget_version_id
                   ,p_task_elem_version_id_tbl    =>      l_element_version_id_tbl
                   ,p_resource_list_member_id_tbl =>      l_resource_list_member_id_tbl
                   ,x_return_status               =>      l_return_status
                   ,x_msg_count                   =>      l_msg_count
                   ,x_msg_data                    =>      l_msg_data     );

                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:='Called API PA_PLANNING_TRANSACTION_UTILS.Get_Res_Class_Rlm_Ids api returned error';
                         pa_debug.write('PA_FP_PLANNING_TRANSACTION_PUB.Create_Default_Task_Plan_Txns:  ' || l_module_name,pa_debug.g_err_stage,5);
                      END IF;
                      RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;
               END IF;
         -- Exit if fetch size is less than 200
            EXIT WHEN NVL(l_element_version_id_tbl.last,0) < l_max_fetch_size;
        END LOOP;

       CLOSE lowest_tasks_cur;
    END IF;

    IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Exiting Create_Default_Task_Plan_Txns:';
       pa_debug.write('Create_Default_Task_Plan_Txns: ' || l_module_name,pa_debug.g_err_stage,3);
      --Reset the error stack
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
--           pa_debug.g_err_stage:='Invalid Arguments Passed';
--           pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
	IF l_debug_mode = 'Y' THEN
           pa_debug.reset_curr_function;
	END IF;
           RETURN;

     WHEN Others THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'PA_FP_PLANNING_TRANSACTION_PUB'
                                  ,p_procedure_name  => 'CREATE_DEFAULT_TASK_PLAN_TXNS');
          IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Unexpected Error ' || SQLERRM;
              pa_debug.write('Create_Default_Task_Plan_Txns: ' || l_module_name,pa_debug.g_err_stage,5);
              pa_debug.reset_curr_function;
	  END IF;
          RAISE;

END Create_Default_Task_Plan_Txns;

/*=============================================================================
 This api is called upon save from Additional Workplan Options page.
 For versioning disabled case working version should be updated with values
 that of parent plan type record. The changes include deleting all the
 existing budget lines, resource assignments. Pa_proj_fp_options and
 pa_budget_versions should be updated with changed values.

 Bug 3595063 For a shared structure, update current working version with the
             new settings.

 Bug 3619687 **** Completely changed as per the new business rules ********
             Whenever there is a change in the Additional Workplan setting page,
             all the chages should be propagated to all the underlying workplan
             versions immediately upon save. If there is a change in RBS header,
             effort data for all the versions including published versions
             should be re-mapped and re-summarized

 Bug 3619687 **** 15-Jun-2004 Additional Change Request for RBS change ****
             Whenever there is a change for RBS if versioning is disabled for
             the workplan structure, the change should be propagated to the
             workplan version immediately. If versioning is enabled, the change
             is applicable for all the future versions.

Bug 3619687 **** 25-Jun-2004 Additional Change Request  ****
            Whenever there is a change to track workplan costs flag, calculate
            should be called for the costs to be calculted or nulled out as per
            the change.
Bug 3725414 **** 28-Jun-2004  rbs_version_change should be propagated to working
            workplan version(s) of shared + versioning enabled structure

Bug 3937716 **** 07-Oct-2004 When time phasing has changed, pji data is not
            correct at the end of the process. Reason: delete_planning_transactions
            and calculate() do not have the old time phased code to pass it to
            the PJI update api for negating existing data. So, its decided that we
            change the above two apis not to call PJI apis in this flow and call
            plan_delete(), plan_create() at the end.
===============================================================================*/

PROCEDURE REFRESH_WP_SETTINGS(
           p_project_id                 IN      pa_budget_versions.project_id%TYPE
          ,p_resource_list_change       IN      VARCHAR2    DEFAULT 'N'    -- Bug 3619687
          ,p_time_phase_change          IN      VARCHAR2    DEFAULT 'N'    -- Bug 3619687
          ,p_rbs_version_change         IN      VARCHAR2    DEFAULT 'N'    -- Bug 3619687
          ,p_track_costs_flag_change    IN      VARCHAR2    DEFAULT 'N'    -- Bug 3619687
          ,x_return_status              OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                  OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                   OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

    --Start of variables used for debugging

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER := 0;
    l_msg_data           VARCHAR2(2000);
    l_data               VARCHAR2(2000);
    l_msg_index_out      NUMBER;
    l_debug_mode         VARCHAR2(30);
    l_error_msg_code     VARCHAR2(30);

    --End of variables used for debugging

    l_budget_version_id_tbl          SYSTEM.PA_NUM_TBL_TYPE :=SYSTEM.pa_num_tbl_type();
    l_proj_fp_options_id_tbl         SYSTEM.PA_NUM_TBL_TYPE :=SYSTEM.pa_num_tbl_type();
    l_task_version_id_tbl            SYSTEM.PA_NUM_TBL_TYPE :=SYSTEM.pa_num_tbl_type();
    l_task_name_tbl                  SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
    l_task_number_tbl                SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
    l_res_assignment_id_tbl          SYSTEM.PA_NUM_TBL_TYPE :=SYSTEM.pa_num_tbl_type();

    l_people_res_class_rlm_id    pa_resource_list_members.resource_list_member_id%TYPE;
    l_equip_res_class_rlm_id     pa_resource_list_members.resource_list_member_id%TYPE;
    l_fin_res_class_rlm_id       pa_resource_list_members.resource_list_member_id%TYPE;
    l_mat_res_class_rlm_id       pa_resource_list_members.resource_list_member_id%TYPE;

    l_txn_source_id_tbl          SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    l_res_list_member_id_tbl     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    l_rbs_element_id_tbl         SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    l_txn_accum_header_id_tbl    SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

    l_res_assignment_count       NUMBER;
    l_wp_versioning_enabled_flag VARCHAR2(1);
    l_pub_budget_version_id_tbl          SYSTEM.PA_NUM_TBL_TYPE :=SYSTEM.pa_num_tbl_type();
    l_pub_proj_fp_options_id_tbl         SYSTEM.PA_NUM_TBL_TYPE :=SYSTEM.pa_num_tbl_type();
    l_proj_struct_ver_id_tbl             SYSTEM.PA_NUM_TBL_TYPE :=SYSTEM.pa_num_tbl_type();


    CURSOR parent_plan_type_cur IS
      SELECT  pfo.proj_fp_options_id
             ,pfo.track_workplan_costs_flag
             ,pfo.plan_in_multi_curr_flag
             ,pfo.rbs_version_id
             ,pfo.margin_derived_from_code
             ,pfo.factor_by_code
             ,pfo.cost_resource_list_id
             ,pfo.select_cost_res_auto_flag
             ,pfo.cost_time_phased_code
             ,pfo.cost_current_planning_period
             ,pfo.cost_period_mask_id
             ,pfo.projfunc_cost_rate_type
             ,pfo.projfunc_cost_rate_date_type
             ,pfo.projfunc_cost_rate_date
             ,pfo.project_cost_rate_type
             ,pfo.project_cost_rate_date_type
             ,pfo.project_cost_rate_date
             ,pfo.use_planning_rates_flag
             ,pfo.res_class_raw_cost_sch_id
             ,pfo.cost_emp_rate_sch_id
             ,pfo.cost_job_rate_sch_id
             ,pfo.cost_non_labor_res_rate_sch_id
             ,pfo.cost_res_class_rate_sch_id
             ,pfo.cost_burden_rate_sch_id
      FROM   pa_proj_fp_options pfo
             ,pa_fin_plan_types_b fpt
      WHERE  pfo.project_id = p_project_id
      AND    pfo.fin_plan_type_id = fpt.fin_plan_type_id
      AND    fpt.use_for_workplan_flag = 'Y'
      AND    pfo.fin_plan_option_level_code = 'PLAN_TYPE';

    parent_plan_type_rec    parent_plan_type_cur%ROWTYPE;

    -- Cursor to fetch all the working version including submitted version
    -- if any to update the versions with the changes in workplan setting
    -- page. Change in resoruce list and time phasing is restricted if there
    -- is a baselined or submitted version.
    CURSOR working_workplan_versions_cur  IS
      SELECT bv.budget_version_id
             ,pfo.proj_fp_options_id
             ,bv.project_structure_version_id
        FROM pa_budget_versions bv,
             pa_proj_elem_ver_structure ver,
             pa_proj_fp_options pfo
       WHERE bv.project_id = p_project_id
         AND bv.wp_version_flag = 'Y'
         AND bv.project_id = ver.project_id
         AND bv.project_structure_version_id = ver.element_version_id
         AND (l_wp_versioning_enabled_flag = 'N' OR  -- UT
               ver.status_code IN('STRUCTURE_WORKING','STRUCTURE_SUBMITTED'))
         AND pfo.project_id = p_project_id
         AND pfo.fin_plan_version_id = bv.budget_version_id;

    CURSOR published_versions_cur  IS
      SELECT bv.budget_version_id
             ,pfo.proj_fp_options_id
        FROM pa_budget_versions bv,
             pa_proj_elem_ver_structure ver,
             pa_proj_fp_options pfo
       WHERE bv.project_id = p_project_id
         AND bv.wp_version_flag = 'Y'
         AND bv.project_id = ver.project_id
         AND bv.project_structure_version_id = ver.element_version_id
         AND ver.status_code IN ('STRUCTURE_PUBLISHED')
         AND pfo.project_id = p_project_id
         AND pfo.fin_plan_version_id = bv.budget_version_id;


    -- Cursor to fetch required input data to delete task assignments
    -- for a workplan version. Using this data delete_planning_transactions
    -- api is called
    CURSOR data_for_delete_plan_txns_cur (c_budget_version_id NUMBER) IS
      SELECT wbs_element_version_id
             ,name
             ,element_number
             ,resource_assignment_id
      FROM   pa_resource_assignments pra
             ,pa_proj_elements ppe
      WHERE  pra.project_id = p_project_id
      AND    pra.budget_version_id = c_budget_version_id
      AND    pra.ta_display_flag = 'Y'
      AND    pra.task_id = ppe.proj_element_id;

    -- Cursor to fetch all the workplan versions for the project
    -- including the publsihed versions for RBS refresh
    CURSOR all_workplan_versions_cur IS
      SELECT bv.budget_version_id
             ,pfo.proj_fp_options_id
        FROM pa_budget_versions bv
             ,pa_proj_fp_options pfo
       WHERE bv.project_id = p_project_id
         AND bv.wp_version_flag = 'Y'
         AND pfo.fin_plan_version_id = bv.budget_version_id
         AND pfo.project_id = bv.project_id;

BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

    -- Set curr function
IF l_debug_mode = 'Y' THEN
    pa_debug.set_curr_function(
                p_function   =>'PA_FP_PLANNING_TRANSACTION_PUB.REFRESH_WP_SETTINGS'
               ,p_debug_mode => l_debug_mode );
END IF;
    -- Check for business rules violations
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Validating input parameters';
        pa_debug.write('REFRESH_WP_SETTINGS: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_project_id IS NULL)
    THEN

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Project_id = '||p_project_id;
           pa_debug.write('REFRESH_WP_SETTINGS: ' || g_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    -- Fetch all the plan type values that could have changed
    OPEN  parent_plan_type_cur;
    FETCH parent_plan_type_cur INTO parent_plan_type_rec;
    CLOSE parent_plan_type_cur;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='getting plan type info';
        pa_debug.write('REFRESH_WP_SETTINGS: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;


    -- Check if versioning is enabled for wp structure
    l_wp_versioning_enabled_flag := PA_WORKPLAN_ATTR_UTILS.Check_Wp_Versioning_Enabled(p_project_id);

    -- Fetch all the working plan versions in a table
    OPEN working_workplan_versions_cur;
    FETCH working_workplan_versions_cur
      BULK COLLECT INTO l_budget_version_id_tbl,l_proj_fp_options_id_tbl , l_proj_struct_ver_id_tbl;
    CLOSE working_workplan_versions_cur;


    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='getting woking versions';
        pa_debug.write('REFRESH_WP_SETTINGS: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;


    --  Adding for bug 4543744
    /*   Collecting all the working version records and inserting into the pji table
         with negative values of budget lines                                     */
        IF nvl(p_resource_list_change, 'N') = 'Y' OR nvl(p_time_phase_change, 'N') = 'Y'
           OR nvl(p_track_costs_flag_change, 'N') = 'Y' OR (nvl(p_rbs_version_change, 'N') = 'Y' AND
               (nvl(PA_WORKPLAN_ATTR_UTILS.Check_Wp_Versioning_Enabled(p_project_id),'N') = 'N'
                OR nvl(PA_PROJECT_STRUCTURE_UTILS.check_sharing_enabled(p_project_id),'N') = 'Y')) THEN

                IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='About to insert negative lines';
                   pa_debug.write('REFRESH_WP_SETTINGS: ' || g_module_name,pa_debug.g_err_stage,5);
                   pa_debug.g_err_stage:='l_budget_version_id_tbl' || l_budget_version_id_tbl.count;
                   pa_debug.write('REFRESH_WP_SETTINGS: ' || g_module_name,pa_debug.g_err_stage,5);

                END IF;


                FOR i IN l_budget_version_id_tbl.FIRST .. l_budget_version_id_tbl.LAST
                LOOP

                    IF l_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage:='Calling call_update_rep_lines' || l_budget_version_id_tbl(i);
                       pa_debug.write('REFRESH_WP_SETTINGS: ' || g_module_name,pa_debug.g_err_stage,5);
                    END IF;

                    PA_PLANNING_TRANSACTION_UTILS.call_update_rep_lines_api
                    --( p_source                  => 'POPULATE_PJI_TABLE'    --Commented for bug 5073350.
                    ( p_source                  => 'REFRESH_WP_SETTINGS'
                     ,p_budget_version_id       => l_budget_version_id_tbl(i)
                     ,p_qty_sign                => -1
                     ,x_return_status           => x_return_status
                     ,x_msg_data                => x_msg_data
                     ,x_msg_count               => x_msg_count);

                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                      IF l_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:='PA_PLANNING_TRANSACTION_UTILS.call_update_rep_lines_api returned error';
                          pa_debug.write( g_module_name,pa_debug.g_err_stage,5);
                      END IF;
                      RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
                  END IF;

                END LOOP;

        END IF; -- inserting negative rows

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='inserted -ve lines';
        pa_debug.write('REFRESH_WP_SETTINGS: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;


     IF nvl(p_resource_list_change, 'N') = 'Y' THEN

        OPEN published_versions_cur;
        FETCH published_versions_cur
          BULK COLLECT INTO l_pub_budget_version_id_tbl,l_pub_proj_fp_options_id_tbl ;
        CLOSE published_versions_cur;

        IF l_pub_budget_version_id_tbl.COUNT > 0 THEN

            PA_PLANNING_TRANSACTION_UTILS.Get_Res_Class_Rlm_Ids
                 ( p_project_id                   =>    p_project_id
                  ,p_resource_list_id             =>    parent_plan_type_rec.cost_resource_list_id
                  ,x_people_res_class_rlm_id      =>    l_people_res_class_rlm_id
                  ,x_equip_res_class_rlm_id       =>    l_equip_res_class_rlm_id
                  ,x_fin_res_class_rlm_id         =>    l_fin_res_class_rlm_id
                  ,x_mat_res_class_rlm_id         =>    l_mat_res_class_rlm_id
                  ,x_return_status                =>    x_return_status
                  ,x_msg_count                    =>    x_msg_count
                  ,x_msg_data                     =>    x_msg_data);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Called API PA_PLANNING_TRANSACTION_UTILS.Get_Res_Class_Rlm_Ids api returned error';
                   pa_debug.write('REFRESH_WP_SETTINGS:  ' || g_module_name,pa_debug.g_err_stage,5);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            FORALL i IN l_pub_budget_version_id_tbl.first .. l_pub_budget_version_id_tbl.last
                  --Fix for bug#7279771, uncommented the code comment done earlier for resource_class_code,
                  --resource_class_flag,ta_display_flag
                    UPDATE pa_resource_assignments
                    SET    resource_list_member_id  = l_people_res_class_rlm_id
                    WHERE  budget_version_id = l_pub_budget_version_id_tbl(i)
                    /* The only records present in pa_resource_assignments for published versions with resource
                       list NONE would fall under the below cateogry. Not including them as part of select as they
                       dont add any value to performance interms of better index usage. Retaining them in the comment
                       for understanding purpose */
                    AND    resource_class_code = 'PEOPLE'
                    AND    resource_class_flag = 'Y'
                    AND    ta_display_flag = 'N';
            /* Assumptions: When resource list changes for published version, pa_progress_rollup would have only task level PEOPLE assignments.
               Hence we are updating all records in pa_progress_rollup with the new rlmid petaining to people class rlm for published versions. */
            UPDATE pa_progress_rollup
            SET  object_id = l_people_res_class_rlm_id
            WHERE project_id = p_project_id AND
            object_type = 'PA_ASSIGNMENTS' AND
            structure_type = 'WORKPLAN' AND
            structure_Version_id is NULL; /* Only published versions */
            /* Note that we are not updating working wp versions pa_progress_rollup since there is some
              processing done for working wp versions in the loop below (delete planning transactions etc
             and we want to ensure this update is done after the processing */

          /* We also need to update the resource list id in the pa_budget_versions table as well as the
             pa_proj_fp_options table .*/
            FORALL i IN l_pub_proj_fp_options_id_tbl.first .. l_pub_proj_fp_options_id_tbl.last
            UPDATE pa_proj_fp_options
            SET cost_resource_list_id             =  parent_plan_type_rec.cost_resource_list_id
             ,record_version_number               =  record_version_number + 1
             ,last_update_date                    =  SYSDATE
             ,last_updated_by                     =  FND_GLOBAL.user_id
             ,last_update_login                   =  FND_GLOBAL.login_id
            where proj_fp_options_id  = l_pub_proj_fp_options_id_tbl(i);

            FORALL i IN l_pub_budget_version_id_tbl.first .. l_pub_budget_version_id_tbl.last
            UPDATE pa_budget_versions
            SET   resource_list_id                = parent_plan_type_rec.cost_resource_list_id
             ,record_version_number               =  record_version_number + 1
             ,last_update_date                    =  SYSDATE
             ,last_updated_by                     =  FND_GLOBAL.user_id
             ,last_update_login                   =  FND_GLOBAL.login_id
            where budget_version_id  = l_pub_budget_version_id_tbl(i);

        END IF;
     END IF;



    IF  nvl(l_budget_version_id_tbl.count, 0) > 0 THEN

        -- Update proj_fp_options data for all the working versions in bulk
        FORALL i IN l_proj_fp_options_id_tbl.first .. l_proj_fp_options_id_tbl.last
        UPDATE pa_proj_fp_options
        SET   track_workplan_costs_flag           =  parent_plan_type_rec.track_workplan_costs_flag
             ,plan_in_multi_curr_flag             =  parent_plan_type_rec.plan_in_multi_curr_flag
            -- Raja ,rbs_version_id                      =  parent_plan_type_rec.rbs_version_id
             ,margin_derived_from_code            =  parent_plan_type_rec.margin_derived_from_code
             ,factor_by_code                      =  parent_plan_type_rec.factor_by_code
             ,cost_resource_list_id               =  parent_plan_type_rec.cost_resource_list_id
             ,select_cost_res_auto_flag           =  parent_plan_type_rec.select_cost_res_auto_flag
             ,cost_time_phased_code               =  parent_plan_type_rec.cost_time_phased_code
             ,cost_current_planning_period        =  parent_plan_type_rec.cost_current_planning_period
             ,cost_period_mask_id                 =  parent_plan_type_rec.cost_period_mask_id
             ,projfunc_cost_rate_type             =  parent_plan_type_rec.projfunc_cost_rate_type
             ,projfunc_cost_rate_date_type        =  parent_plan_type_rec.projfunc_cost_rate_date_type
             ,projfunc_cost_rate_date             =  parent_plan_type_rec.projfunc_cost_rate_date
             ,project_cost_rate_type              =  parent_plan_type_rec.project_cost_rate_type
             ,project_cost_rate_date_type         =  parent_plan_type_rec.project_cost_rate_date_type
             ,project_cost_rate_date              =  parent_plan_type_rec.project_cost_rate_date
             ,use_planning_rates_flag             =  parent_plan_type_rec.use_planning_rates_flag
             ,res_class_raw_cost_sch_id           =  parent_plan_type_rec.res_class_raw_cost_sch_id
             ,cost_emp_rate_sch_id                =  parent_plan_type_rec.cost_emp_rate_sch_id
             ,cost_job_rate_sch_id                =  parent_plan_type_rec.cost_job_rate_sch_id
             ,cost_non_labor_res_rate_sch_id      =  parent_plan_type_rec.cost_non_labor_res_rate_sch_id
             ,cost_res_class_rate_sch_id          =  parent_plan_type_rec.cost_res_class_rate_sch_id
             ,cost_burden_rate_sch_id             =  parent_plan_type_rec.cost_burden_rate_sch_id
             ,record_version_number               =  record_version_number + 1
             ,last_update_date                    =  SYSDATE
             ,last_updated_by                     =  FND_GLOBAL.user_id
             ,last_update_login                   =  FND_GLOBAL.login_id
        WHERE proj_fp_options_id  = l_proj_fp_options_id_tbl(i);

        -- Update budget_versions data for all the working versions in bulk

        FORALL i IN l_budget_version_id_tbl.first .. l_budget_version_id_tbl.last
        UPDATE pa_budget_versions
        SET   resource_list_id            = parent_plan_type_rec.cost_resource_list_id
             ,current_planning_period     = parent_plan_type_rec.cost_current_planning_period
             ,period_mask_id              = parent_plan_type_rec.cost_period_mask_id
             -- Bug 3630069 Amounts should not be updated with 0. These columns are taken care of
             -- by delete planning transactions api if there is any change to this amount
             /***
                 ,raw_cost                    = 0
                 ,burdened_cost               = 0
                 ,total_project_raw_cost      = 0
                 ,total_project_burdened_cost = 0
                 ,labor_quantity              = 0
                 ,equipment_quantity          = 0
             ***/
             ,last_update_date            = SYSDATE
             ,last_updated_by             = FND_GLOBAL.user_id
             ,last_update_login           = FND_GLOBAL.login_id
             ,record_version_number       = record_version_number + 1
        WHERE budget_version_id =  l_budget_version_id_tbl(i);

        /* Bug 4200168: FP.M:B12: Pref Changes: Called the following api outside the BV loop
         */
        -- If resource list has changed task level resource assignments
        -- should be re-mapped with new People resource class rlmid
        -- Fetching the resource class rlm only if not fetched already during published version processing
        IF nvl(p_resource_list_change, 'N') = 'Y' AND l_people_res_class_rlm_id IS NULL THEN
            PA_PLANNING_TRANSACTION_UTILS.Get_Res_Class_Rlm_Ids
                 ( p_project_id                   =>    p_project_id
                  ,p_resource_list_id             =>    parent_plan_type_rec.cost_resource_list_id
                  ,x_people_res_class_rlm_id      =>    l_people_res_class_rlm_id
                  ,x_equip_res_class_rlm_id       =>    l_equip_res_class_rlm_id
                  ,x_fin_res_class_rlm_id         =>    l_fin_res_class_rlm_id
                  ,x_mat_res_class_rlm_id         =>    l_mat_res_class_rlm_id
                  ,x_return_status                =>    x_return_status
                  ,x_msg_count                    =>    x_msg_count
                  ,x_msg_data                     =>    x_msg_data);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Called API PA_PLANNING_TRANSACTION_UTILS.Get_Res_Class_Rlm_Ids api returned error';
                   pa_debug.write('REFRESH_WP_SETTINGS:  ' || g_module_name,pa_debug.g_err_stage,5);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
        END IF;
        /* Bug 4200168: FP.M:B12: Pref Changes:-----*/

        FOR i IN l_budget_version_id_tbl.first .. l_budget_version_id_tbl.last
        LOOP
            -- For each of the workplan versions, MC currencies should also be copied
            -- from plan type

            PA_FP_TXN_CURRENCIES_PUB.copy_fp_txn_currencies (
                     p_source_fp_option_id        => parent_plan_type_rec.proj_fp_options_id
                     ,p_target_fp_option_id       => l_proj_fp_options_id_tbl(i)
                     ,p_target_fp_preference_code => NULL
                     ,p_plan_in_multi_curr_flag   => parent_plan_type_rec.plan_in_multi_curr_flag
                     ,x_return_status             => x_return_status
                     ,x_msg_count                 => x_msg_count
                     ,x_msg_data                  => x_msg_data );

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Called API PA_FP_TXN_CURRENCIES_PUB.copy_fp_txn_currencies api returned error';
                   pa_debug.write('REFRESH_WP_SETTINGS:  ' || g_module_name,pa_debug.g_err_stage,5);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            -- If resource list or time phasing has changed all the Task Assignments
            -- related data should be deleted
            IF nvl(p_resource_list_change, 'N') = 'Y' OR nvl(p_time_phase_change, 'N') = 'Y'
               OR nvl(p_track_costs_flag_change, 'N') = 'Y' -- bug 3797057
            THEN
                OPEN data_for_delete_plan_txns_cur(l_budget_version_id_tbl(i));
                FETCH data_for_delete_plan_txns_cur
                  BULK COLLECT INTO  l_task_version_id_tbl
                                    ,l_task_name_tbl
                                    ,l_task_number_tbl
                                    ,l_res_assignment_id_tbl    ;
                CLOSE data_for_delete_plan_txns_cur;

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='about to call delete palnning trans';
                pa_debug.write('REFRESH_WP_SETTINGS: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;

                IF nvl(l_res_assignment_id_tbl.count,0) > 0 THEN
                    -- If there is any data to be deleted call delete_planning_txns api
                    PA_FP_PLANNING_TRANSACTION_PUB.delete_planning_transactions (
                           p_context                      => 'TASK_ASSIGNMENT'
                          ,p_task_or_res                  => 'ASSIGNMENT'
                          ,p_element_version_id_tbl       => l_task_version_id_tbl
                          ,p_task_number_tbl              => l_task_number_tbl
                          ,p_task_name_tbl                => l_task_name_tbl
                          ,p_resource_assignment_tbl      => l_res_assignment_id_tbl
                          ,p_rollup_required_flag         => 'N' --For Bug 3937716
                          ,p_pji_rollup_required          => 'N' /* Bug 4200168 */
                          ,x_return_status                => x_return_status
                          ,x_msg_count                    => x_msg_count
                          ,x_msg_data                     => x_msg_data );

                    IF   x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;
                END IF;

                /* Bug 4200168: FP.M:B12: Pref Changes: Clearing the pl/sql tables*/
                l_task_version_id_tbl.delete;
                l_task_name_tbl.delete;
                l_task_number_tbl.delete;
                l_res_assignment_id_tbl.delete;

            END IF; -- res list or time phase change

            IF nvl(p_resource_list_change, 'N') = 'Y' THEN
                            -- Update all the task planning elements with new FINACIAL ELEMENT rlmid
                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Updaing res assignments with new FINANCIAL ELEMENTS rlmid : ' || l_fin_res_class_rlm_id;
                    pa_debug.write('REFRESH_WP_SETTINGS: ' || g_module_name,pa_debug.g_err_stage,3);
                END IF;

                UPDATE pa_resource_assignments
                SET    resource_list_member_id  = l_people_res_class_rlm_id
                WHERE  budget_version_id = l_budget_version_id_tbl(i)
                AND    resource_class_code = 'PEOPLE'
                AND    resource_class_flag = 'Y';

                /* Assumptions: When resource list changes for working version, pa_progress_rollup would have
                   only task level PEOPLE assignments at this point as ta_display_flag = Y records
                   would have got deleted above.Hence we are updating all records in pa_progress_rollup
                   with the new rlmid petaining to people class rlm for working versions. */
                UPDATE pa_progress_rollup
                SET  object_id = l_people_res_class_rlm_id
                WHERE project_id = p_project_id AND
                object_type = 'PA_ASSIGNMENTS' AND
                structure_type = 'WORKPLAN' AND
                structure_Version_id = l_proj_struct_ver_id_tbl(i); /* for Working versions */

            END IF;

            -- If time phasing has changed call spread api to respread the
            -- task level effort data as per the new time phasing

            -- If track workplan costs flag has changed call calculate to
            -- calculate the costs or null them out as per the changed value
            IF nvl(p_time_phase_change, 'N') = 'Y'  OR
               nvl(p_track_costs_flag_change, 'N') = 'Y'
            THEN

                -- Call calculate only if there are some planning transactions to be processed
                SELECT count(*)
                INTO   l_res_assignment_count
                FROM   pa_resource_assignments
                WHERE  budget_version_id = l_budget_version_id_tbl(i);

                IF  l_res_assignment_count > 0 THEN
                    PA_FP_CALC_PLAN_PKG.calculate(
                          p_project_id                 =>   p_project_id
                         ,p_budget_version_id          =>   l_budget_version_id_tbl(i)
                         ,p_spread_required_flag       =>   'Y'
                         ,p_rollup_required_flag       =>   'N' -- bug 3937716
                         ,p_source_context             =>   'RESOURCE_ASSIGNMENT'
                         ,p_wp_cost_changed_flag       =>   nvl(p_track_costs_flag_change,'N') -- bug 3699558
                         ,p_time_phase_changed_flag    =>   nvl(p_time_phase_change,'N') -- bug 3699558
                         ,x_return_status              =>   x_return_status
                         ,x_msg_count                  =>   x_msg_count
                         ,x_msg_data                   =>   x_msg_data);

                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF l_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage:='Called API PA_FP_CALC_PLAN_PKG.calculate api returned error';
                           pa_debug.write('REFRESH_WP_SETTINGS:  ' || g_module_name,pa_debug.g_err_stage,5);
                        END IF;
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;
                END IF;
            END IF;

            -- Bug 3937716 If there is any change to amounts call rollup api
            IF nvl(p_resource_list_change, 'N') = 'Y' OR nvl(p_time_phase_change, 'N') = 'Y'
               OR nvl(p_track_costs_flag_change, 'N') = 'Y'
            THEN
                 PA_FP_ROLLUP_PKG.ROLLUP_BUDGET_VERSION
                     ( p_budget_version_id     => l_budget_version_id_tbl(i)
                      ,p_entire_version        => 'Y'
                      ,x_return_status         => x_return_status
                      ,x_msg_count             => x_msg_count
                      ,x_msg_data              => x_msg_data);

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:='Called API PA_FP_ROLLUP_PKG.rollup_budget_version api returned error';
                        pa_debug.write('REFRESH_WP_SETTINGS:  ' || g_module_name,pa_debug.g_err_stage,5);
                     END IF;
                     RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                 END IF;
            END IF;
        END LOOP;


    END IF;  -- workplan budget versions exist

    -- If RBS header has been changed all the workplan versions including published
    -- versions should be re-mapped and re-summarized
    -- Jun-15-2004 Bug 3619687 rbs_version_change should be propagated to workplan
    -- versions only if versioning is disabled for the workplan structure
    -- Jun-28-2004 Bug 3725414 rbs_version_change should be propagated to working
    -- workplan versions even though versioning is enbled but shared structure

    IF nvl(p_rbs_version_change, 'N') = 'Y' AND
       (nvl(PA_WORKPLAN_ATTR_UTILS.Check_Wp_Versioning_Enabled(p_project_id),'N') = 'N' -- Jun-15-2004 Bug 3619687
        OR nvl(PA_PROJECT_STRUCTURE_UTILS.check_sharing_enabled(p_project_id),'N') = 'Y') -- Jun-28-2004 Bug 3725414
    THEN
        /** Bug 3725414
        -- Fetch all the workplan versions
        OPEN all_workplan_versions_cur;
        FETCH all_workplan_versions_cur
           BULK COLLECT INTO  l_budget_version_id_tbl,l_proj_fp_options_id_tbl ;
        CLOSE all_workplan_versions_cur;
        **/

        -- Fetch all the working plan versions in a table

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='rbs change Yes';
            pa_debug.write('REFRESH_WP_SETTINGS: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;


        OPEN working_workplan_versions_cur;
        FETCH working_workplan_versions_cur
          BULK COLLECT INTO l_budget_version_id_tbl,l_proj_fp_options_id_tbl,l_proj_struct_ver_id_tbl ;
        CLOSE working_workplan_versions_cur;

        IF nvl(l_budget_version_id_tbl.count,0) > 0 THEN

            -- Bulk update all the versions with the new RBS header
            FORALL i IN l_budget_version_id_tbl.first .. l_budget_version_id_tbl.last
              UPDATE pa_proj_fp_options
              SET    rbs_version_id             =  parent_plan_type_rec.rbs_version_id
                     ,record_version_number     =  record_version_number + 1
                     ,last_update_date          =  SYSDATE
                     ,last_updated_by           =  FND_GLOBAL.user_id
                     ,last_update_login         =  FND_GLOBAL.login_id
              WHERE  proj_fp_options_id = l_proj_fp_options_id_tbl(i);

            -- For each of the versions, RBS re-mapping and re-summarization needs to be done
            FOR i IN  l_budget_version_id_tbl.first ..  l_budget_version_id_tbl.last LOOP
                IF  parent_plan_type_rec.rbs_version_id IS NOT NULL THEN
                  -- Call RBS mapping api for the entire version
                  -- The api returns rbs element id, txn accum header id for each
                  -- resource assignment id in the form of plsql tables
                  PA_RLMI_RBS_MAP_PUB.Map_Rlmi_Rbs(
                       p_budget_version_id         =>   l_budget_version_id_tbl(i)
                      ,p_resource_list_id          =>   parent_plan_type_rec.cost_resource_list_id
                      ,p_rbs_version_id            =>   parent_plan_type_rec.rbs_version_id
                      ,p_calling_process           =>   'RBS_REFRESH'
                      ,p_calling_context           =>   'PLSQL'
                      ,p_process_code              =>   'RBS_MAP'
                      ,p_calling_mode              =>   'BUDGET_VERSION'
                      ,p_init_msg_list_flag        =>   'N'
                      ,p_commit_flag               =>   'N'
                      ,x_txn_source_id_tab         =>   l_txn_source_id_tbl
                      ,x_res_list_member_id_tab    =>   l_res_list_member_id_tbl
                      ,x_rbs_element_id_tab        =>   l_rbs_element_id_tbl
                      ,x_txn_accum_header_id_tab   =>   l_txn_accum_header_id_tbl
                      ,x_return_status             =>   x_return_status
                      ,x_msg_count                 =>   x_msg_count
                      ,x_msg_data                  =>   x_msg_data);

                  -- Check return status
                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:='Called API PA_PLANNING_TRANSACTION_UTILS.Map_Rlmi_Rbs api returned error';
                         pa_debug.write('REFRESH_WP_SETTINGS:  ' || g_module_name,pa_debug.g_err_stage,5);
                      END IF;
                      RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  ELSE
                      -- Check count of the required out tables to be the same
                      IF l_txn_source_id_tbl.count <> l_rbs_element_id_tbl.count OR
                         l_txn_source_id_tbl.count <> l_txn_accum_header_id_tbl.count
                      THEN
                          IF l_debug_mode = 'Y' THEN
                             pa_debug.g_err_stage:='Called API PA_PLANNING_TRANSACTION_UTILS.Map_Rlmi_Rbs api
                                                    returned out tables with different count';
                             pa_debug.write('Refresh_Plan_Txns:  ' || g_module_name,pa_debug.g_err_stage,5);
                             pa_debug.g_err_stage:='l_txn_source_id_tbl.count = ' || l_txn_source_id_tbl.count;
                             pa_debug.write('Refresh_Plan_Txns:  ' || g_module_name,pa_debug.g_err_stage,5);
                             pa_debug.g_err_stage:='l_rbs_element_id_tbl.count = ' || l_rbs_element_id_tbl.count;
                             pa_debug.write('Refresh_Plan_Txns:  ' || g_module_name,pa_debug.g_err_stage,5);
                             pa_debug.g_err_stage:=
                                  'l_txn_accum_header_id_tbl.count = ' || l_txn_accum_header_id_tbl.count;
                             pa_debug.write('Refresh_Plan_Txns:  ' || g_module_name,pa_debug.g_err_stage,5);
                          END IF;
                          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                      END IF;
                  END IF;

                  -- Check if out table has any records first
                  IF nvl(l_txn_source_id_tbl.last,0) >= 1 THEN
                      -- Update resource assignments data for the version
                      -- Bug 3641252 changed the index from i to j
                      FORALL j IN l_txn_source_id_tbl.first .. l_txn_source_id_tbl.last
                          UPDATE pa_resource_assignments
                          SET     rbs_element_id          =  l_rbs_element_id_tbl(j)
                                 ,txn_accum_header_id     =  l_txn_accum_header_id_tbl(j)
                                 ,record_version_number   =  record_version_number + 1
                                 ,last_update_date        =  SYSDATE
                                 ,last_updated_by         =  FND_GLOBAL.user_id
                                 ,last_update_login       =  FND_GLOBAL.login_id
                          WHERE  budget_version_id = l_budget_version_id_tbl(i)
                          AND    resource_assignment_id = l_txn_source_id_tbl(j);
                  END IF;
                ELSE -- rbs version id is null

                    -- Update all the resource assigments with null for rbs _element_id
                    UPDATE pa_resource_assignments
                    SET     rbs_element_id          =  null
                           ,txn_accum_header_id     =  null
                           ,record_version_number   =  record_version_number + 1
                           ,last_update_date        =  SYSDATE
                           ,last_updated_by         =  FND_GLOBAL.user_id
                           ,last_update_login       =  FND_GLOBAL.login_id
                    WHERE  budget_version_id = l_budget_version_id_tbl(i);

                    IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:='Done with mapping';
                        pa_debug.write('REFRESH_WP_SETTINGS: ' || g_module_name,pa_debug.g_err_stage,3);
                    END IF;


                END IF;

                /* Bug 4200168: FP.M:B12: Pref Changes: Clearing the pl/sql tables*/
                l_txn_source_id_tbl.delete;
                l_res_list_member_id_tbl.delete;
                l_rbs_element_id_tbl.delete;
                l_txn_accum_header_id_tbl.delete;
            END LOOP;
        END IF;  -- if versions exist
    END IF;   -- if RBS has changed

    --  Adding for bug 4543744
    /*   Collecting all the working version records and inserting into the pji table
         with positive values of budget lines                                     */
    IF nvl(p_resource_list_change, 'N') = 'Y' OR nvl(p_time_phase_change, 'N') = 'Y'
           OR nvl(p_track_costs_flag_change, 'N') = 'Y' OR ( nvl(p_rbs_version_change, 'N') = 'Y' AND
               (nvl(PA_WORKPLAN_ATTR_UTILS.Check_Wp_Versioning_Enabled(p_project_id),'N') = 'N'
                OR nvl(PA_PROJECT_STRUCTURE_UTILS.check_sharing_enabled(p_project_id),'N') = 'Y')) THEN
                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='About to insert positive values with new rbs element ids';
                    pa_debug.write( g_module_name,pa_debug.g_err_stage,5);
                END IF;


                FOR i IN l_budget_version_id_tbl.FIRST .. l_budget_version_id_tbl.LAST
                LOOP
                    PA_PLANNING_TRANSACTION_UTILS.call_update_rep_lines_api
                    --( p_source                  => 'POPULATE_PJI_TABLE'   --Commented for bug 5073350.
                    ( p_source                  => 'REFRESH_WP_SETTINGS'
                     ,p_budget_version_id       => l_budget_version_id_tbl(i)
                     ,p_qty_sign                => 1
                     ,x_return_status           => x_return_status
                     ,x_msg_data                => x_msg_data
                     ,x_msg_count               => x_msg_count);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      IF l_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:='PA_PLANNING_TRANSACTION_UTILS.call_update_rep_lines_api returned error';
                          pa_debug.write( g_module_name,pa_debug.g_err_stage,5);
                      END IF;                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
                END LOOP;

              /* Start of commented code for bug 5073350.
                This call will update all the plan versions of a project which are affected due to the
                workplan paln settings change.If any of those versions is in pending processing status,
                as per the PJI design error will be thrown.So, commenting out this code.
                The PJI_FM_XBS_ACCUM_MAINT.PLAN_UPDATE api will be called seperately for each plan version
                in PA_PLANNING_TRANSACTION_UTILS.call_update_rep_lines_api.

                PJI_FM_XBS_ACCUM_MAINT.PLAN_UPDATE (
                  x_return_status    => x_return_status,
                  x_msg_code         => l_error_msg_code);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                     p_msg_name            => l_error_msg_code);
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            End of commented code for bug 5073350*/
    END IF; -- inserting positive rows

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Exiting REFRESH_WP_SETTINGS';
        pa_debug.write('REFRESH_WP_SETTINGS: ' || g_module_name,pa_debug.g_err_stage,3);
    -- reset curr function
       pa_debug.reset_curr_function();
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

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Invalid Arguments Passed Or called api raised an error';
           pa_debug.write('REFRESH_WP_SETTINGS: ' || g_module_name,pa_debug.g_err_stage,5);
       -- reset curr function
          pa_debug.reset_curr_function();
       END IF;

       RETURN;
   WHEN Others THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FP_PLANNING_TRANSACTION_PUB'
                               ,p_procedure_name  => 'REFRESH_WP_SETTINGS');

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write('REFRESH_WP_SETTINGS: ' || g_module_name,pa_debug.g_err_stage,5);
       -- reset curr function
          pa_debug.Reset_Curr_Function();
       END IF;
       RAISE;
END REFRESH_WP_SETTINGS;

/*=============================================================================
 This api is called when ever RBS should be changed for budget versions.

 Usage:
 p_calling_context    --> 'ALL_CHILD_VERSIONS'
 p_budget_version_id  -->  null
                        If there is a change in RBS for a financial plan type
                        to push the change to the underlying budget version.
                        p_budget_version_id  would be null

 p_calling_context    --> 'SINGLE_VERSION'
 p_budget_version_id  --> not null, version id should be passed
                      --> This mode is useful for creation of working versions
                          out of published versions, or copy amounts case from
                          a different version

 Bug 3867302  Sep 21 2004 For ci versions reporting data is not maintained
==============================================================================*/

PROCEDURE Refresh_rbs_for_versions(
          p_project_id            IN   pa_projects_all.project_id%TYPE
          ,p_fin_plan_type_id     IN   pa_budget_versions.fin_plan_type_id%TYPE
          ,p_calling_context      IN   VARCHAR2  -- Default 'ALL_CHILD_VERSIONS'
          ,p_budget_version_id    IN   pa_budget_versions.budget_version_id%TYPE  -- Default null
          ,x_return_status        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count            OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data             OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

    --Start of variables used for debugging

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER := 0;
    l_msg_data           VARCHAR2(2000);
    l_data               VARCHAR2(2000);
    l_msg_index_out      NUMBER;
    l_debug_mode         VARCHAR2(30);
    l_error_msg_code     VARCHAR2(30);

    --End of variables used for debugging

    l_rbs_version_id     NUMBER;

    CURSOR working_budget_Versions_cur IS
    SELECT o.proj_fp_options_id,
           o.fin_plan_version_id,
           bv.resource_list_id
    FROM   pa_proj_fp_options o,
           pa_budget_versions bv
    WHERE  o.project_id = p_project_id
    AND    o.fin_plan_type_id = p_fin_plan_type_id
    AND    o.fin_plan_version_id = bv.budget_version_id
    AND    bv.ci_id IS NULL -- bug 3867302
    AND    bv.budget_status_code IN ('W', 'S');

    CURSOR input_budget_version_cur IS
    SELECT o.proj_fp_options_id
           ,o.fin_plan_version_id
           ,bv.resource_list_id
           ,o.fin_plan_type_id
           ,bv.ci_id
    FROM   pa_budget_versions bv,
           pa_proj_fp_options o
    WHERE  bv.project_id = o.project_id
    AND    bv.fin_plan_type_id = o.fin_plan_type_id
    AND    bv.budget_version_id = o.fin_plan_version_id
    AND    bv.budget_version_id = p_budget_version_id;

    input_budget_version_rec  input_budget_version_cur%ROWTYPE;


    l_budget_version_id_tbl      SYSTEM.PA_NUM_TBL_TYPE :=SYSTEM.pa_num_tbl_type();
    l_proj_fp_options_id_tbl     SYSTEM.PA_NUM_TBL_TYPE :=SYSTEM.pa_num_tbl_type();
    l_resource_list_id_tbl       SYSTEM.PA_NUM_TBL_TYPE :=SYSTEM.pa_num_tbl_type();

    l_txn_source_id_tbl          SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    l_res_list_member_id_tbl     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    l_rbs_element_id_tbl         SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    l_txn_accum_header_id_tbl    SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

    -- Set curr function
IF l_debug_mode = 'Y' THEN
    pa_debug.set_curr_function(
                p_function   =>'PAFPPTPB.Refresh_rbs_for_versions'
               ,p_debug_mode => l_debug_mode );
END IF;
    -- Check for business rules violations
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Validating input parameters';
        pa_debug.write('Refresh_rbs_for_versions: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_project_id IS NULL) OR
       (p_fin_plan_type_id IS NULL) OR
       (p_calling_context = 'SINGLE_VERSION' AND p_budget_version_id IS NULL )
    THEN

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Project_id = '||p_project_id;
           pa_debug.write('Refresh_rbs_for_versions: ' || g_module_name,pa_debug.g_err_stage,5);

           pa_debug.g_err_stage:='Fin_plan_type_id = '||p_fin_plan_type_id;
           pa_debug.write('Refresh_rbs_for_versions: ' || g_module_name,pa_debug.g_err_stage,5);

           pa_debug.g_err_stage:='p_calling_context = '||p_calling_context;
           pa_debug.write('Refresh_rbs_for_versions: ' || g_module_name,pa_debug.g_err_stage,5);

           pa_debug.g_err_stage:='p_budget_version_id = '||p_budget_version_id;
           pa_debug.write('Refresh_rbs_for_versions: ' || g_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                              p_token1         => 'PROCEDURENAME',
                              p_value1         => 'pa_fp_planning_transaction_pub.Refresh_rbs_for_versions');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    -- fetch plan type level rbs version id
    Select rbs_version_id
    into   l_rbs_version_id
    from   pa_proj_fp_options
    where  project_id = p_project_id
    and    fin_plan_type_id = p_fin_plan_type_id
    and    fin_plan_option_level_code = 'PLAN_TYPE';

    -- if context is 'SINGLE_VERSION' fetch required info about budget version id is passed
    IF p_calling_context = 'SINGLE_VERSION' THEN

        OPEN input_budget_version_cur;
        FETCH input_budget_version_cur
            INTO input_budget_version_rec;
        CLOSE input_budget_version_cur;

        -- Bug 3867302 If i/p version is a ci version just return
        -- Added NOT for bug 4094762
        IF input_budget_version_rec.ci_id IS NOT NULL THEN

             IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:=' PJI data not required for CI versions. Returning';
               pa_debug.write('Refresh_rbs_for_versions: ' || g_module_name,pa_debug.g_err_stage,3);
             pa_debug.reset_curr_function();
	     END IF;
             RETURN;

        END IF;

        l_proj_fp_options_id_tbl :=
             SYSTEM.pa_num_tbl_type(input_budget_version_rec.proj_fp_options_id);
        l_budget_version_id_tbl  :=
             SYSTEM.pa_num_tbl_type(input_budget_version_rec.fin_plan_version_id);
        l_resource_list_id_tbl   :=
             SYSTEM.pa_num_tbl_type(input_budget_version_rec.resource_list_id);

    ELSE

        OPEN working_budget_Versions_cur;
        FETCH working_budget_Versions_cur
            BULK COLLECT INTO l_proj_fp_options_id_tbl,
                              l_budget_version_id_tbl,
                              l_resource_list_id_tbl;
        CLOSE working_budget_Versions_cur;

        -- if there are no budget versions for the plan type return
        IF l_budget_version_id_tbl.count = 0 THEN
            IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Working Versions do not exist for the plan type. Returning';
               pa_debug.write('Refresh_rbs_for_versions: ' || g_module_name,pa_debug.g_err_stage,3);
               pa_debug.reset_curr_function();
 	END IF;
            RETURN;
        END IF;

    END IF;

    -- bulk update all the budget versions with the rbs version id
    forall i in l_proj_fp_options_id_tbl.first .. l_proj_fp_options_id_tbl.last
       update pa_proj_fp_options
       set    rbs_version_id               = l_rbs_version_id
             ,record_version_number        =  record_version_number + 1
             ,last_update_date             =  SYSDATE
             ,last_updated_by              =  FND_GLOBAL.user_id
             ,last_update_login            =  FND_GLOBAL.login_id
       WHERE proj_fp_options_id  = l_proj_fp_options_id_tbl(i);

    -- for each of the versions, RBS re-mapping and re-summarization needs to be done
    FOR i IN  l_budget_version_id_tbl.first ..  l_budget_version_id_tbl.last LOOP
        IF  l_rbs_version_id IS NOT NULL THEN
          -- Call RBS mapping api for the entire version
          -- The api returns rbs element id, txn accum header id for each
          -- resource assignment id in the form of plsql tables
          PA_RLMI_RBS_MAP_PUB.Map_Rlmi_Rbs(
               p_budget_version_id         =>   l_budget_version_id_tbl(i)
              ,p_resource_list_id          =>   l_resource_list_id_tbl(i)
              ,p_rbs_version_id            =>   l_rbs_version_id
              ,p_calling_process           =>   'RBS_REFRESH'
              ,p_calling_context           =>   'PLSQL'
              ,p_process_code              =>   'RBS_MAP'
              ,p_calling_mode              =>   'BUDGET_VERSION'
              ,p_init_msg_list_flag        =>   'N'
              ,p_commit_flag               =>   'N'
              ,x_txn_source_id_tab         =>   l_txn_source_id_tbl
              ,x_res_list_member_id_tab    =>   l_res_list_member_id_tbl
              ,x_rbs_element_id_tab        =>   l_rbs_element_id_tbl
              ,x_txn_accum_header_id_tab   =>   l_txn_accum_header_id_tbl
              ,x_return_status             =>   x_return_status
              ,x_msg_count                 =>   x_msg_count
              ,x_msg_data                  =>   x_msg_data);

          -- Check return status
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='Called API PA_PLANNING_TRANSACTION_UTILS.Map_Rlmi_Rbs api returned error';
                 pa_debug.write('REFRESH_WP_SETTINGS:  ' || g_module_name,pa_debug.g_err_stage,5);
              END IF;
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          ELSE
              -- Check count of the required out tables to be the same
              IF l_txn_source_id_tbl.count <> l_rbs_element_id_tbl.count OR
                 l_txn_source_id_tbl.count <> l_txn_accum_header_id_tbl.count
              THEN
                  IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:='Called API PA_PLANNING_TRANSACTION_UTILS.Map_Rlmi_Rbs api
                                            returned out tables with different count';
                     pa_debug.write('Refresh_Plan_Txns:  ' || g_module_name,pa_debug.g_err_stage,5);
                     pa_debug.g_err_stage:='l_txn_source_id_tbl.count = ' || l_txn_source_id_tbl.count;
                     pa_debug.write('Refresh_Plan_Txns:  ' || g_module_name,pa_debug.g_err_stage,5);
                     pa_debug.g_err_stage:='l_rbs_element_id_tbl.count = ' || l_rbs_element_id_tbl.count;
                     pa_debug.write('Refresh_Plan_Txns:  ' || g_module_name,pa_debug.g_err_stage,5);
                     pa_debug.g_err_stage:=
                          'l_txn_accum_header_id_tbl.count = ' || l_txn_accum_header_id_tbl.count;
                     pa_debug.write('Refresh_Plan_Txns:  ' || g_module_name,pa_debug.g_err_stage,5);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
              END IF;
          END IF;

          -- Check if out table has any records first
          IF nvl(l_txn_source_id_tbl.last,0) >= 1 THEN
              -- Update resource assignments data for the version
              -- Bug 3641252 changed the index from i to j
              FORALL j IN l_txn_source_id_tbl.first .. l_txn_source_id_tbl.last
                  UPDATE pa_resource_assignments
                  SET     rbs_element_id          =  l_rbs_element_id_tbl(j)
                         ,txn_accum_header_id     =  l_txn_accum_header_id_tbl(j)
                         ,record_version_number   =  record_version_number + 1
                         ,last_update_date        =  SYSDATE
                         ,last_updated_by         =  FND_GLOBAL.user_id
                         ,last_update_login       =  FND_GLOBAL.login_id
                  WHERE  budget_version_id = l_budget_version_id_tbl(i)
                  AND    resource_assignment_id = l_txn_source_id_tbl(j);
          END IF;
        ELSE -- rbs version id is null

            -- Update all the resource assigments with null for rbs _element_id
            UPDATE pa_resource_assignments
            SET     rbs_element_id          =  null
                   ,txn_accum_header_id     =  null
                   ,record_version_number   =  record_version_number + 1
                   ,last_update_date        =  SYSDATE
                   ,last_updated_by         =  FND_GLOBAL.user_id
                   ,last_update_login       =  FND_GLOBAL.login_id
            WHERE  budget_version_id = l_budget_version_id_tbl(i);

        END IF;
    END LOOP;

    -- Call PJI delete api first to delete existing summarization data
    PJI_FM_XBS_ACCUM_MAINT.PLAN_DELETE (
          p_fp_version_ids   => l_budget_version_id_tbl,
          x_return_status    => x_return_status,
          x_msg_code         => l_error_msg_code);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => l_error_msg_code);
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    -- Call PLAN_CREATE to create summarization data as per the new RBS
    PJI_FM_XBS_ACCUM_MAINT.PLAN_CREATE (
          p_fp_version_ids   => l_budget_version_id_tbl,
          x_return_status    => x_return_status,
          x_msg_code         => l_error_msg_code);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => l_error_msg_code);
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Exiting Refresh_rbs_for_versions';
        pa_debug.write('Refresh_rbs_for_versions: ' || g_module_name,pa_debug.g_err_stage,3);
    -- reset curr function
        pa_debug.reset_curr_function();
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

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Invalid Arguments Passed Or called api raised an error';
           pa_debug.write('Refresh_rbs_for_versions: ' || g_module_name,pa_debug.g_err_stage,5);
       -- reset curr function
          pa_debug.reset_curr_function();
       END IF;
       RETURN;
   WHEN Others THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'pa_fp_planning_transaction_pub'
                               ,p_procedure_name  => 'Refresh_rbs_for_versions');

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write('Refresh_rbs_for_versions: ' || g_module_name,pa_debug.g_err_stage,5);
       -- reset curr function
       pa_debug.Reset_Curr_Function();
       END IF;
       RAISE;
END Refresh_rbs_for_versions;

--This function returns 'N' if a record already exists in pa_resource_assignments
--for a given budget version id, task id and resource list member id
--Returns 'Y' if the record is not already there
FUNCTION DUP_EXISTS
( p_budget_version_id       IN pa_budget_versions.budget_version_id%TYPE
 ,p_task_id                 IN pa_tasks.task_id%TYPE
 ,p_resource_list_member_id IN pa_resource_list_members.resource_list_member_id%TYPE
 ,p_project_id              IN pa_projects_all.project_id%TYPE)
RETURN VARCHAR2
IS
l_dup_exists     VARCHAR2(1);
BEGIN

        BEGIN
            SELECT 'Y'
            INTO   l_dup_exists
            FROM   pa_resource_assignments
            WHERE  task_id=p_task_id
            AND    resource_list_member_id=p_resource_list_member_id
            AND    budget_version_id=p_budget_version_id
            AND    project_assignment_id=-1
            AND    project_id=p_project_id;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_dup_exists:='N';
        END;
        RETURN l_dup_exists;

END DUP_EXISTS;

END PA_FP_PLANNING_TRANSACTION_PUB;


/
