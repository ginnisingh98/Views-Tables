--------------------------------------------------------
--  DDL for Package Body PA_FP_CI_IMPLEMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_CI_IMPLEMENT_PKG" as
/* $Header: PAFPCOMB.pls 120.3.12010000.3 2008/09/10 21:11:27 snizam ship $ */
P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

--3 new parameters are added as part of rounding changes.
---->p_impl_txn_rev_amt : contain the amount in agreement currency for which funding lines should be created
---->p_impl_pc_rev_amt  : contain the amount in project currency for which funding lines should be created
---->p_impl_pfc_rev_amt : contain the amount in project functional currency for which funding lines should be created
--The calling API should round these parameters before calling the APi
PROCEDURE create_ci_impact_fund_lines(
                         p_project_id             IN  NUMBER,
                         p_ci_id                  IN  NUMBER,
                         x_msg_data               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                         x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                         x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                         p_update_agr_amount_flag IN  VARCHAR2,
                         p_funding_category       IN  VARCHAR2 ,
                         p_partial_factor         IN  NUMBER,
                         p_impl_txn_rev_amt       IN  NUMBER,
                         p_impl_pc_rev_amt        IN  NUMBER,
                         p_impl_pfc_rev_amt       IN  NUMBER) IS
   l_agreement_id pa_agreements_all.agreement_id%TYPE;
   l_budget_version_id pa_budget_versions.budget_version_id%TYPE;
   l_total_proj_revenue pa_budget_versions.total_project_revenue%TYPE;
   l_total_projfunc_revenue pa_budget_versions.revenue%TYPE;
   l_bv_id pa_budget_versions.budget_version_id%TYPE;

   l_ci_ver_planning_level pa_proj_fp_options.all_fin_plan_level_code%TYPE;
   l_funding_level    VARCHAR2(100);
   l_err_code NUMBER := null;
   l_err_stage varchar2(1000) := null;
   l_err_stack varchar2(1000) := null;
   l_msg_data         VARCHAR2(1000);
   l_msg_index_out        NUMBER:=0;
   l_upd_agr_allowed VARCHAR2(30);
   l_valid_funding_amt_flag VARCHAR2(30);
   l_add_funding_ok_flag VARCHAR2(30);

   l_customer_id pa_agreements_all.customer_id%TYPE;
   l_agreement_type pa_agreements_all.agreement_type%TYPE;
   l_term_id pa_agreements_all.term_id%TYPE;
   l_template_flag pa_agreements_all.template_Flag%TYPE;
   l_revenue_limit_flag pa_agreements_all.revenue_limit_flag%TYPE;
   l_owned_by_person_id pa_agreements_all.owned_by_person_id%TYPE;
   l_owning_org_id pa_agreements_all.owning_organization_id%TYPE;
   l_agr_curr_code pa_agreements_all.agreement_currency_Code%TYPE;
   l_invoice_limit_flag pa_agreements_all.invoice_limit_flag%TYPE;
   l_agreement_num pa_agreements_all.agreement_num%TYPE;
   l_expiration_Date pa_agreements_all.expiration_date%TYPE;
   l_Attribute_Category pa_agreements_all.Attribute_Category%TYPE;
   l_Attribute1 pa_agreements_all.Attribute1%TYPE;
   l_Attribute2 pa_agreements_all.Attribute2%TYPE;
   l_Attribute3 pa_agreements_all.Attribute3%TYPE;
   l_Attribute4 pa_agreements_all.Attribute4%TYPE;
   l_Attribute5 pa_agreements_all.Attribute5%TYPE;
   l_Attribute6 pa_agreements_all.Attribute6%TYPE;
   l_Attribute7 pa_agreements_all.Attribute7%TYPE;
   l_Attribute8 pa_agreements_all.Attribute8%TYPE;
   l_Attribute9 pa_agreements_all.Attribute9%TYPE;
   l_Attribute10 pa_agreements_all.Attribute10%TYPE;
   l_agr_amount pa_agreements_all.Amount%TYPE;

   l_new_agr_amount NUMBER;

   l_last_updated_by   NUMBER := FND_GLOBAL.USER_ID;
   l_last_update_login NUMBER := FND_GLOBAL.LOGIN_ID;
   l_sysdate DATE := TRUNC(SYSDATE);
   l_total_amount                NUMBER;
   l_rowid ROWID;
   l_project_funding_id NUMBER;

   l_amount_tab PA_PLSQL_DATATYPES.NumTabTyp;
   l_task_id_tab PA_PLSQL_DATATYPES.IdTabTyp;
   --These tbls will hold the change order amounts in PC and PFC.
   l_amount_tab_in_pc    PA_PLSQL_DATATYPES.NumTabTyp;
   l_amount_tab_in_pfc   PA_PLSQL_DATATYPES.NumTabTyp;
   l_proj_curr_code pa_projects_all.project_currency_code%TYPE;
   l_projfunc_curr_code pa_projects_all.projfunc_currency_code%TYPE;
   l_debug_mode VARCHAR2(30);
   l_tmp_amount NUMBER;
   l_rounded_agr_sum      NUMBER;
   l_rounded_pc_sum       NUMBER;
   l_rounded_pfc_sum      NUMBER;
   l_module_name        VARCHAR2(100):='pa_fp_ci_implement_pkg.create_ci_impact_fund_lines';

   l_budget_line_count    NUMBER; --Bug 5509687
   -- Bug 6772321
   l_project_exchange_rate	pa_project_fundings.project_exchange_rate%TYPE;
   l_projfunc_exchange_rate	pa_project_fundings.projfunc_exchange_rate%TYPE;
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
   l_debug_mode := NVL(l_debug_mode, 'Y');
   /* the above default  is set for testing purpose only
      need to set to 'N' after testing */
   IF l_debug_mode = 'Y' THEN
      IF P_PA_DEBUG_MODE = 'Y' THEN
         PA_DEBUG.init_err_stack('pa_fp_ci_implement_pkg.create_ci_impact_fund_lines');
      END IF;
   END IF;
   IF p_ci_id IS NULL OR
      p_partial_factor IS NULL OR
      p_project_id IS NULL THEN

       IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'p_ci_id IS '||p_ci_id;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,5);

            pa_debug.g_err_stage:= 'p_partial_factor IS '||p_partial_factor;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,5);

            pa_debug.g_err_stage:= 'p_project_id IS '||p_project_id;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
       END IF;
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                     p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                     p_token1         => 'PROCEDURENAME',
                     p_value1         => l_module_name);
       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
   END IF;



   l_amount_tab.DELETE;
   l_amount_tab_in_pc.DELETE;
   l_amount_tab_in_pfc.DELETE;
   l_task_id_tab.DELETE;

   SELECT project_currency_Code,
          projfunc_currency_code
   INTO
          l_proj_curr_code,
          l_projfunc_curr_code
   FROM pa_projects_all
   WHERE
         project_id = p_project_id;

   SELECT budget_version_id,
          agreement_id,
          DECODE(bv.version_type,'REVENUE',revenue_fin_plan_level_code,
                                'ALL',all_fin_plan_level_code,null)
   INTO
   l_budget_version_id,
   l_agreement_id,
   l_ci_ver_planning_level
   FROM PA_BUDGET_VERSIONS bv,
   pa_proj_fp_options po WHERE
   bv.project_id                  = p_project_id
   AND bv.approved_rev_plan_type_flag = 'Y'
   AND bv.version_type IN ('REVENUE','ALL')
   AND po.project_id                  = bv.project_id
   AND po.fin_plan_type_id            = bv.fin_plan_type_id
   AND po.fin_plan_version_id         = bv.budget_version_id
   AND po.fin_plan_option_level_code  = 'PLAN_VERSION'
   AND bv.ci_id                       = p_ci_id;

    Select count(*)
    into l_budget_line_count
    from pa_budget_lines pbl
    where pbl.budget_version_id = l_budget_version_id;  --Bug 5509687

IF l_budget_line_count > 0 THEN --Bug 5509687: Prevent from creating funding lines if there are no impact lines

   IF l_debug_mode = 'Y' THEN
          PA_DEBUG.write_log (x_module      =>
                           'pa.plsql.pa_fp_ci_implement_pkg.create_ci_impact_fund_lines'
                     ,x_msg         => 'before getting CW REVENUE budget version id '
                     ,x_log_level   => 5);
   END IF;

   BEGIN
       SELECT budget_version_id INTO l_bv_id
       FROM pa_budget_versions
       WHERE
       project_id = p_project_id AND
       version_type IN ('REVENUE','ALL') AND
       NVL(current_working_flag,'N' ) = 'Y' AND
       NVL(Approved_Rev_Plan_Type_Flag,'N') = 'Y' AND
       CI_ID IS NULL;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FP_CI_NO_CURR_WK_VERSION');
      IF l_debug_mode = 'Y' THEN
         PA_DEBUG.Reset_Err_Stack;
      END IF;
      RETURN;
   END;

   IF l_debug_mode = 'Y' THEN
          PA_DEBUG.write_log (x_module      =>
                           'pa.plsql.pa_fp_ci_implement_pkg.create_ci_impact_fund_lines'
                     ,x_msg         => 'after getting CW REVENUE budget version id '||
                                   TO_CHAR(l_bv_id)
                     ,x_log_level   => 5);
   END IF;

   SELECT customer_id,
          agreement_type,
          term_id,
          template_Flag,
          revenue_limit_flag,
          owned_by_person_id,
          owning_organization_id,
          agreement_currency_code,
          invoice_limit_flag,
          agreement_num,
          expiration_Date,
          Attribute_Category,
          Attribute1,
          Attribute2,
          Attribute3,
          Attribute4,
          Attribute5,
          Attribute6,
          Attribute7,
          Attribute8,
          Attribute9,
          Attribute10,
          Amount
   INTO
          l_customer_id,
          l_agreement_type,
          l_term_id,
          l_template_flag,
          l_revenue_limit_flag,
          l_owned_by_person_id,
          l_owning_org_id,
          l_agr_curr_code,
          l_invoice_limit_flag,
          l_agreement_num,
          l_expiration_date,
          l_Attribute_Category,
          l_Attribute1,
          l_Attribute2,
          l_Attribute3,
          l_Attribute4,
          l_Attribute5,
          l_Attribute6,
          l_Attribute7,
          l_Attribute8,
          l_Attribute9,
          l_Attribute10,
          l_agr_amount
   FROM pa_agreements_all WHERE
   agreement_id = l_agreement_id;

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.write_log (x_module      =>
                           'pa.plsql.pa_fp_ci_implement_pkg.create_ci_impact_fund_lines'
                     ,x_msg         => 'fund level chk begin '||
                                       'upd agr amt flag from page '||p_update_agr_amount_flag
                                ||' fund cate fr page '||p_funding_category
                     ,x_log_level   => 5);
          PA_DEBUG.write_log (x_module
                       => 'pa.plsql.pa_fp_ci_implement_pkg.create_ci_impact_fund_lines'
                     ,x_msg         => 'prj id '||to_char(p_project_id) ||
                                       'ci id '||to_char(p_ci_id)
                     ,x_log_level   => 5);
     END IF;

     pa_billing_core.check_funding_level(   x_project_id => p_project_id,
                                          x_funding_level => l_funding_level,
                                          x_err_code => l_err_code,
                                          x_err_stage => l_err_stage,
                                          x_err_stack => l_err_stack );

     IF (l_err_code <> 0) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         /* x_msg_count := FND_MSG_PUB.Count_Msg;
           IF x_msg_count = 1 THEN
              PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => 1,
                  p_msg_data       => l_msg_data ,
                  p_data           => x_msg_data,
                  p_msg_index_out  => l_msg_index_out);
           END IF;  */
         IF l_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Err_Stack;
         END IF;

         RETURN;
     END IF;
     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.write_log (x_module      =>
                     'pa.plsql.pa_fp_ci_implement_pkg.create_ci_impact_fund_lines'
                     ,x_msg         => 'funding level '||l_funding_level
                     ,x_log_level   => 5);
     END IF;

    l_total_amount           := p_impl_txn_rev_amt;
    l_total_projfunc_revenue := p_impl_pfc_rev_amt;
    l_total_proj_revenue     := p_impl_pc_rev_amt;

     /* check for agreement amount update allowed */
     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.write_log (x_module      =>
                  'pa.plsql.pa_fp_ci_implement_pkg.create_ci_impact_fund_lines'
                     ,x_msg         => 'total fund amt '||ltrim(to_char(l_total_amount))
                     ,x_log_level   => 5);
     END IF;

     IF p_update_agr_amount_flag = 'Y' THEN
        l_upd_agr_allowed := pa_agreement_pvt.check_update_agreement_ok
        (p_pm_agreement_reference       => NULL
        ,p_agreement_id                 => l_agreement_id
        ,p_funding_id                   => NULL
        ,p_customer_id                  => l_customer_id
        ,p_agreement_type               => l_agreement_type
        ,p_term_id                      => l_term_id
        ,p_template_flag                => l_template_flag
        ,p_revenue_limit_flag           => l_revenue_limit_flag
        ,p_owned_by_person_id           => l_owned_by_person_id
        ,p_owning_organization_id       => l_owning_org_id
        ,p_agreement_currency_code      => l_agr_curr_code
        ,p_invoice_limit_flag           => l_invoice_limit_flag
        ,p_start_date                   => PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE  -- Bug 5522880
        ,p_end_date                     => PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE  -- Bug 5522880
        ,p_advance_required             => PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  -- Bug 5522880
        ,p_billing_sequence             => PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM   -- Bug 5522880
        ,p_amount                       => PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM); -- Bug 5522880

        IF l_debug_mode = 'Y' THEN
           PA_DEBUG.write_log (x_module      =>
                     'pa.plsql.pa_fp_ci_implement_pkg.create_ci_impact_fund_lines'
                     ,x_msg         => 'upd agr allowed flag '||l_upd_agr_allowed
                     ,x_log_level   => 5);
        END IF;
        IF l_upd_agr_allowed = 'N' THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           /* x_msg_count := FND_MSG_PUB.Count_Msg;
           IF x_msg_count = 1 THEN
              PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => 1,
                  p_msg_data       => l_msg_data ,
                  p_data           => x_msg_data,
                  p_msg_index_out  => l_msg_index_out);
           END IF;  */
           IF l_debug_mode = 'Y' THEN
              PA_DEBUG.Reset_Err_Stack;
           END IF;
           RETURN;
        END IF;
        /* calling update agreement API */
        /* the update agreement API expects the existing amount plus
           the new amount for the update bug 2671305   */

        l_new_agr_amount := NVL(l_total_amount,0) + l_agr_amount;

        IF l_debug_mode = 'Y' THEN
           PA_DEBUG.write_log (x_module      =>
                        'pa.plsql.pa_fp_ci_implement_pkg.create_ci_impact_fund_lines'
                     ,x_msg         => 'new agr amt '||ltrim(to_char(l_new_agr_amount))
                                              ||' Agr ID '||ltrim(to_char(l_agreement_id))
                     ,x_log_level   => 5);
        END IF;

        pa_agreement_core.update_agreement(
           p_Agreement_Id                    => l_agreement_id,
           p_Customer_Id                     => l_customer_id,
           p_Agreement_Num                   => l_agreement_num,
           p_Agreement_Type                  => l_agreement_type,
           p_Last_Update_Date                => TRUNC(SYSDATE),
           p_Last_Updated_By                 => l_last_updated_by,
           p_Last_Update_Login               => l_last_update_login,
           p_Owned_By_Person_Id              => l_owned_by_person_id,
           p_Term_Id                         => l_term_id,
           p_Revenue_Limit_Flag              => l_revenue_limit_flag,
           p_Amount                          => l_new_agr_amount,
           p_Description                     => NULL,
           p_Expiration_Date                 => l_expiration_date,
           p_Attribute_Category              => l_attribute_category,
           p_Attribute1                      => l_attribute1,
           p_Attribute2                      => l_attribute2,
           p_Attribute3                      => l_attribute3,
           p_Attribute4                      => l_attribute4,
           p_Attribute5                      => l_attribute5,
           p_Attribute6                      => l_attribute6,
           p_Attribute7                      => l_attribute7,
           p_Attribute8                      => l_attribute8,
           p_Attribute9                      => l_attribute9,
           p_Attribute10                     => l_attribute10,
           p_Template_Flag                   => l_template_flag,
           p_pm_agreement_reference          => NULL,
           p_pm_product_code                 => NULL,
           p_agreement_currency_code         => l_agr_curr_code,
           p_owning_organization_id          => l_owning_org_id,
           p_invoice_limit_flag              => l_invoice_limit_flag,
           p_customer_order_number    =>      PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,  -- Bug 5522880
           p_advance_required         =>      PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
           p_start_date               =>      PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
           p_billing_sequence         =>      PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
           p_line_of_account          =>      PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
           p_Attribute11              =>      PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
           p_Attribute12              =>      PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
           p_Attribute13              =>      PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
           p_Attribute14              =>      PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
           p_Attribute15              =>      PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
           p_Attribute16              =>      PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
           p_Attribute17              =>      PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
           p_Attribute18              =>      PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
           p_Attribute19              =>      PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
           p_Attribute20              =>      PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
           p_Attribute21              =>      PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
           p_Attribute22              =>      PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
           p_Attribute23              =>      PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
           p_Attribute24              =>      PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
           p_Attribute25              =>      PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR);  -- Bug 5522880


     END IF;

           /* the following is only for testing a bug */
           BEGIN
              SELECT amount into l_tmp_amount
              FROM pa_agreements_all WHERE
              agreement_id = l_agreement_id;
           EXCEPTION
           WHEN OTHERS THEN
               l_tmp_amount := 0;
           END;
           IF l_debug_mode = 'Y' THEN
              PA_DEBUG.write_log (x_module      =>
                      'pa.plsql.pa_fp_ci_implement_pkg.create_ci_impact_fund_lines'
                     ,x_msg         => 'aft upd agr api'||ltrim(to_char(l_tmp_amount))
                     ,x_log_level   => 5);
           END IF;

           /* the following is only for testing a bug */

     /* check and call for agreement amount update */

     /* check for validate funding amount */

     l_valid_funding_amt_flag := Pa_agreement_pvt.validate_funding_amt(
                 p_funding_amt            => l_total_amount,
                 p_agreement_id         => l_agreement_id,
                 p_operation_flag       => 'A',
                 p_funding_id           => NULL,
                 p_pm_funding_reference => NULL );

     IF l_debug_mode = 'Y' THEN
         PA_DEBUG.write_log (x_module      =>
                  'pa.plsql.pa_fp_ci_implement_pkg.create_ci_impact_fund_lines'
                  ,x_msg         => 'aft valid fund amt api call '||l_valid_funding_amt_flag
                  ,x_log_level   => 5);
     END IF;

     IF l_valid_funding_amt_flag <> 'Y' THEN
        PA_UTILS.ADD_MESSAGE(
                       p_app_short_name      => 'PA',
                       p_msg_name            => 'PA_INVD_FUND_ALLOC_AMG' );

        x_return_status := FND_API.G_RET_STS_ERROR;
        /* x_msg_count := FND_MSG_PUB.Count_Msg;
        IF x_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
              (p_encoded        => FND_API.G_TRUE,
               p_msg_index      => 1,
               p_msg_count      => 1,
               p_msg_data       => l_msg_data ,
               p_data           => x_msg_data,
               p_msg_index_out  => l_msg_index_out);
        END IF;  */
        IF l_debug_mode = 'Y' THEN
           PA_DEBUG.Reset_Err_Stack;
        END IF;
        RETURN;
     END IF;

     /* checking for project level funding */

     IF ( l_ci_ver_planning_level = 'P' AND
          l_funding_level         = 'P'      ) OR
        ( l_ci_ver_planning_level = 'T' AND
          l_funding_level         = 'P'      ) OR
        ( l_ci_ver_planning_level = 'L' AND         -- Bug 3755783: CI version Lowest level funding
          l_funding_level         = 'P'      )THEN

        l_amount_tab(1) := l_total_amount;
        l_amount_tab_in_pfc(1) := l_total_projfunc_revenue;
        l_amount_tab_in_pc(1)  := l_total_proj_revenue;
        l_task_id_tab(1)       := NULL;
        IF l_debug_mode = 'Y' THEN
           PA_DEBUG.write_log (x_module      =>
                  'pa.plsql.pa_fp_ci_implement_pkg.create_ci_impact_fund_lines'
                  ,x_msg         => 'inside fund : ci level PP PT'
                  ,x_log_level   => 5);
        END IF;


     ELSIF l_ci_ver_planning_level = 'T' AND
           l_funding_level         = 'T' THEN
        IF l_debug_mode = 'Y' THEN
           PA_DEBUG.write_log (x_module      =>
                  'pa.plsql.pa_fp_ci_implement_pkg.create_ci_impact_fund_lines'
                  ,x_msg         => 'inside fund : ci level TT'
                  ,x_log_level   => 5);
        END IF;
        BEGIN
            SELECT NVL( SUM(nvl(bl.txn_revenue,0)) , 0)*p_partial_factor,
            NVL( SUM(nvl(bl.project_revenue,0)) , 0)*p_partial_factor,
            NVL( SUM(nvl(bl.revenue,0)) , 0)*p_partial_factor,
            ra.Task_id
            BULK COLLECT INTO
                   l_amount_tab,
                   l_amount_tab_in_pc,
                   l_amount_tab_in_pfc,
                   l_task_id_tab
            FROM pa_budget_lines bl,
               pa_resource_assignments ra
            WHERE
               ra.project_id = p_project_id AND
               ra.budget_version_id = l_budget_version_id AND
               NVL(ra.resource_assignment_type,'USER_ENTERED') = 'USER_ENTERED' AND
               ra.resource_assignment_id = bl.resource_Assignment_id AND
               bl.budget_version_id = ra.budget_version_id  AND
               bl.cost_rejection_code IS NULL           AND
               bl.revenue_rejection_code IS NULL        AND
               bl.burden_rejection_code IS NULL         AND
               bl.other_rejection_code IS NULL          AND
               bl.pc_cur_conv_rejection_code IS NULL    AND
               bl.pfc_cur_conv_rejection_code IS NULL
            GROUP BY ra.task_id HAVING NVL( SUM(nvl(bl.txn_revenue,0)) , 0) <> 0
            ORDER BY PA_PROJ_ELEMENTS_UTILS.GET_DISPLAY_SEQUENCE(ra.task_id);
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
        END;
     ELSIF l_ci_ver_planning_level = 'P' AND
           l_funding_level = 'T' THEN
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_CI_FUNDING_LEVEL' );
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF l_debug_mode = 'Y' THEN
           PA_DEBUG.Reset_Err_Stack;
        END IF;
        RETURN;
     ELSIF l_ci_ver_planning_level = 'L' AND  -- Bug 3755783: FP.M change
           l_funding_level = 'T' THEN
           -- Rollup ci budget lines to appropriate top node and create funding lines
           BEGIN
                SELECT NVL( SUM(nvl(bl.txn_revenue,0)) , 0)*p_partial_factor,
                       NVL( SUM(nvl(bl.project_revenue,0)) , 0)*p_partial_factor,
                       NVL( SUM(nvl(bl.revenue,0)) , 0)*p_partial_factor,
                       pt.top_task_id
                BULK COLLECT INTO
                       l_amount_tab,
                       l_amount_tab_in_pc,
                       l_amount_tab_in_pfc,
                       l_task_id_tab
                FROM   pa_budget_lines bl,
                       pa_resource_assignments ra,
                       pa_tasks pt
                WHERE  ra.project_id = p_project_id
                AND    ra.budget_version_id = l_budget_version_id
                AND    NVL(ra.resource_assignment_type,'USER_ENTERED') = 'USER_ENTERED'
                AND    ra.task_id = pt.task_id
                AND    ra.resource_assignment_id = bl.resource_Assignment_id
                AND    bl.budget_version_id = ra.budget_version_id
                AND    bl.cost_rejection_code IS NULL
                AND    bl.revenue_rejection_code IS NULL
                AND    bl.burden_rejection_code IS NULL
                AND    bl.other_rejection_code IS NULL
                AND    bl.pc_cur_conv_rejection_code IS NULL
                AND    bl.pfc_cur_conv_rejection_code IS NULL
                GROUP BY pt.top_task_id HAVING NVL( SUM(nvl(bl.txn_revenue,0)) , 0) <> 0
                ORDER BY PA_PROJ_ELEMENTS_UTILS.GET_DISPLAY_SEQUENCE(pt.top_task_id);
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     NULL;
        END;
     END IF;

     --In 3 for loops written below all the txn/pc/pfc amounts will be rounded. 3 For loops are written to take advantage
     --of caching logic in Pa_currency.round_trans_currency_amt1
     l_rounded_agr_sum :=0;
     l_rounded_pc_sum  :=0;
     l_rounded_pfc_sum :=0;
     -- Call the rounding api for all the agreement currency amounts
     FOR i IN  1..l_task_id_tab.COUNT
     LOOP
         IF l_amount_tab(i) <> 0 THEN
             l_amount_tab(i) :=
                    Pa_currency.round_trans_currency_amt1(l_amount_tab(i),
                                                          l_agr_curr_code);
         END IF;
         l_rounded_agr_sum := l_rounded_agr_sum + l_amount_tab(i);
     END LOOP;

     --Round PFC amounts
     IF l_agr_curr_code = l_projfunc_curr_code THEN

         l_amount_tab_in_pfc:=l_amount_tab;
         l_rounded_pfc_sum   := l_rounded_agr_sum;

     ELSE

         FOR i IN 1 .. l_task_id_tab.COUNT
         LOOP
             IF l_amount_tab_in_pfc(i) <> 0 THEN
                 l_amount_tab_in_pfc(i) :=
                        Pa_currency.round_trans_currency_amt1(l_amount_tab_in_pfc(i),
                                                              l_projfunc_curr_code);
                 l_rounded_pfc_sum := l_rounded_pfc_sum + l_amount_tab_in_pfc(i);
             END IF;
         END LOOP;

     END IF;

     --Round PC amounts
     IF l_agr_curr_code = l_proj_curr_code THEN

         l_amount_tab_in_pc:=l_amount_tab;
         l_rounded_pc_sum:=l_rounded_agr_sum;

     ELSIF l_projfunc_curr_code = l_proj_curr_code THEN

         l_amount_tab_in_pc := l_amount_tab_in_pfc;
         l_rounded_pc_sum:=l_rounded_pfc_sum;

     ELSE

         FOR i IN 1 .. l_task_id_tab.COUNT
         LOOP
             IF l_amount_tab_in_pc(i) <> 0 THEN
                 l_amount_tab_in_pc(i) :=
                        Pa_currency.round_trans_currency_amt1(l_amount_tab_in_pc(i),
                                                              l_proj_curr_code);
                 l_rounded_pc_sum:= l_rounded_pc_sum + l_amount_tab_in_pc(i);
             END IF;
         END LOOP;

     END IF;

     --Adjust the residual amount, if any, because of rounding into the last funding line
     IF l_task_id_tab.COUNT >0 THEN

        l_amount_tab(l_amount_tab.COUNT) :=  l_amount_tab(l_amount_tab.COUNT) + (l_total_amount-l_rounded_agr_sum);
        l_amount_tab_in_pfc(l_amount_tab_in_pfc.COUNT) :=  l_amount_tab_in_pfc(l_amount_tab_in_pfc.COUNT)
                                                          +(l_total_projfunc_revenue-l_rounded_pfc_sum);
        l_amount_tab_in_pc(l_amount_tab_in_pc.COUNT) :=  l_amount_tab_in_pc(l_amount_tab_in_pc.COUNT)
                                                          +(l_total_proj_revenue-l_rounded_pc_sum);

     END IF;

     FOR i IN 1 .. l_task_id_tab.COUNT LOOP
        --Bug 6600563. Added the parameter p_calling_context to the below API call.
        l_add_funding_ok_flag := pa_agreement_pvt.Check_add_funding_ok(
        p_project_id                => p_project_id,
        p_task_id                   => l_task_id_tab(i),
        p_agreement_id              => l_agreement_id,
        p_pm_funding_reference      => NULL,
        p_funding_amt               => l_amount_tab(i),
        p_customer_id               => l_customer_id  ,
        p_calling_context           => 'CI');

        IF l_debug_mode = 'Y' THEN
           PA_DEBUG.write_log (x_module      =>
                  'pa.plsql.pa_fp_ci_implement_pkg.create_ci_impact_fund_lines'
                  ,x_msg         => 'chk for add fund ok '||
                                              ltrim(to_char(nvl(l_task_id_tab(i),-1)))
                                       || ' amt '||to_char(l_amount_tab(i)) ||
                                        ' flag '|| l_add_funding_ok_flag
                  ,x_log_level   => 5);
        END IF;

        IF l_add_funding_ok_flag <> 'Y' THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           /* x_msg_count := FND_MSG_PUB.Count_Msg;
           IF x_msg_count = 1 THEN
              PA_INTERFACE_UTILS_PUB.get_messages
                  (p_encoded        => FND_API.G_TRUE,
                   p_msg_index      => 1,
                   p_msg_count      => 1,
                   p_msg_data       => l_msg_data ,
                   p_data           => x_msg_data,
                   p_msg_index_out  => l_msg_index_out);
           END IF;  */
           IF l_debug_mode = 'Y' THEN
              PA_DEBUG.Reset_Err_Stack;
           END IF;
           RETURN;
        END IF;

        IF l_debug_mode = 'Y' THEN
           PA_DEBUG.write_log (x_module      =>
                  'pa.plsql.pa_fp_ci_implement_pkg.create_ci_impact_fund_lines'
                  ,x_msg         => 'bef create_funding api call'
                  ,x_log_level   => 5);
        END IF;

        l_err_stage := NULL;
        /* added for bug 2782095 */
        l_rowid := NULL;
        l_project_funding_id := NULL;
        /* added for bug 2782095 */

        -- Bug 6772321
		IF l_amount_tab(i) <> 0 THEN
			l_project_exchange_rate := l_amount_tab_in_pc(i)/l_amount_tab(i);
			l_projfunc_exchange_rate := l_amount_tab_in_pfc(i)/l_amount_tab(i);
		ELSE
			l_project_exchange_rate := NULL;
			l_projfunc_exchange_rate := NULL;
		END IF;

         pa_funding_core.create_funding_CO(
            p_Rowid                       => l_rowid,
            p_Project_Funding_Id          => l_project_funding_id,
            p_Last_Update_Date            => l_sysdate,
            p_Last_Updated_By             => l_last_updated_by,
            p_Creation_Date               => l_sysdate,
            p_Created_By                  => l_last_updated_by,
            p_Last_Update_Login           => l_last_update_login,
            p_Agreement_Id                => l_agreement_id,
            p_Project_Id                  => p_project_id,
            p_Task_id                     => l_task_id_tab(i),
            p_Budget_Type_Code            => 'DRAFT',
            p_Allocated_Amount            => l_amount_tab(i),
            p_Date_Allocated              => l_sysdate,
            P_Funding_Currency_Code       => l_agr_curr_code,
            p_Control_Item_ID             => p_ci_id,
            p_Attribute_Category          => NULL,
            p_Attribute1                  => NULL,
            p_Attribute2                  => NULL,
            p_Attribute3                  => NULL,
            p_Attribute4                  => NULL,
            p_Attribute5                  => NULL,
            p_Attribute6                  => NULL,
            p_Attribute7                  => NULL,
            p_Attribute8                  => NULL,
            p_Attribute9                  => NULL,
            p_Attribute10                 => NULL,
            p_pm_funding_reference        => NULL,
            p_pm_product_code             => NULL,
            p_Project_Allocated_Amount    => l_amount_tab_in_pc(i),
            p_project_rate_type           => 'User',
            p_project_rate_date           => NULL,
            --p_project_exchange_rate       => l_amount_tab_in_pc(i)/l_amount_tab(i),
            p_project_exchange_rate       => l_project_exchange_rate,   --Bug 6772321
            p_Projfunc_Allocated_Amount   => l_amount_tab_in_pfc(i),
            p_projfunc_rate_type          => 'User',
            p_projfunc_rate_date          => NULL,
            --p_projfunc_exchange_rate      => l_amount_tab_in_pfc(i)/l_amount_tab(i),
            p_projfunc_exchange_rate      => l_projfunc_exchange_rate,   --Bug 6772321
            x_err_code                    => l_err_code,
            x_err_msg                     => l_err_stage,
            p_funding_category            => p_funding_category  );

         IF l_debug_mode = 'Y' THEN
            PA_DEBUG.write_log (x_module      =>
                  'pa.plsql.pa_fp_ci_implement_pkg.create_ci_impact_fund_lines'
                  ,x_msg         => 'aft create_funding api call ret code '||
                                   to_char(l_err_code)
                  ,x_log_level   => 5);
         END IF;

         IF (l_err_code <> 0) THEN
             PA_UTILS.ADD_MESSAGE(
                       p_app_short_name      => 'PA',
                       p_msg_name            => l_err_stage );
             x_return_status := FND_API.G_RET_STS_ERROR;
              /* x_msg_count := FND_MSG_PUB.Count_Msg;
               IF x_msg_count = 1 THEN
                  PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE,
                      p_msg_index      => 1,
                      p_msg_count      => 1,
                      p_msg_data       => l_msg_data ,
                      p_data           => x_msg_data,
                      p_msg_index_out  => l_msg_index_out);
               END IF;  */
             IF l_debug_mode = 'Y' THEN
                PA_DEBUG.Reset_Err_Stack;
             END IF;
             RETURN;
         END IF;

         pa_agreement_utils.summary_funding_insert_row(
                p_agreement_id         => l_agreement_id,
                p_project_id           => p_project_id,
                p_task_id              => l_task_id_tab(i),
                p_login_id             => LTRIM(RTRIM(TO_CHAR(l_last_update_login))),
                p_user_id              => LTRIM(RTRIM(TO_CHAR(l_last_updated_by)))
                      );
            IF l_debug_mode = 'Y' THEN
               PA_DEBUG.write_log (x_module      =>
                         'pa.plsql.pa_fp_ci_implement_pkg.create_ci_impact_fund_lines'
                         ,x_msg         => 'aft calling summary fund ins API '
                  ,x_log_level   => 5);
            END IF;
        END LOOP;
        /* FP.M- The following call to the api has been commented as this
         * api spec has undergone changes and the calling api would not be
         * called at all
         */
        /*PA_FP_CI_MERGE.FP_CI_LINK_CONTROL_ITEMS(
                       p_project_id       => p_project_id,
                       p_s_fp_version_id  => l_budget_version_id,
                       p_t_fp_version_id  => l_bv_id,
                       p_inclusion_method => 'AUTOMATIC',
                       p_included_by      => NULL,
                       x_return_status    => x_return_status,
                       x_msg_count        => x_msg_count,
                       x_msg_data         => x_msg_data
                                      );

         IF l_debug_mode = 'Y' THEN
               PA_DEBUG.write_log (x_module      =>
                         'pa.plsql.pa_fp_ci_implement_pkg.create_ci_impact_fund_lines'
                         ,x_msg         => 'aft calling link api : ret status '||
                                          x_return_status
                  ,x_log_level   => 5);
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF l_debug_mode = 'Y' THEN
               PA_DEBUG.Reset_Err_Stack;
           END IF;
           RETURN;
        END IF;
     /* checking for project level funding */
 END IF; --Bug 5509687
     /* PA_DEBUG.Reset_Err_Stack;  */
     IF l_debug_mode = 'Y' THEN
        PA_DEBUG.Reset_Err_Stack;
     END IF;
     RETURN;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    IF l_debug_mode = 'Y' THEN
       PA_DEBUG.Reset_Err_Stack;
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_FP_CI_IMPLEMENT_PKG',
                            p_procedure_name => 'CREATE_CI_IMPACT_FUND_LINES',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);


END create_ci_impact_fund_lines;



/* bug 2735741 this API returns the appropriate error msg when the
   budget version passed is in Submitted status or
   locked by a different user. If the lock is held by
   the current login user and the version is not in Submitted status,
   then the implementation of the  change order is allowed .  */


PROCEDURE chk_plan_ver_for_merge
       (
            p_project_id                 IN NUMBER,
            p_target_fp_version_id_tbl   IN PA_PLSQL_DATATYPES.IdTabTyp,
               x_msg_data   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
               x_msg_count  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
               x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ) IS
   l_budget_status_code pa_budget_versions.budget_status_code%TYPE;
   l_locked_by_person_id pa_budget_versions.locked_by_person_id%TYPE;
   l_version_type pa_budget_versions.version_type%TYPE;
   l_meaning pa_lookups.meaning%TYPE;
   l_person_id                 NUMBER;
   l_resource_id               NUMBER;
   l_resource_name             VARCHAR2(200);
   l_user_id NUMBER;
   l_chk_flag VARCHAR2(1);
   /* l_chk_flag is used to display only one error for the
      target version.either version in Submitted status or version locked by
      another user. In this case, error for Submit status takes precedence
      over the lock error. */
   l_locked_by_name per_people_x.full_name%TYPE;
   l_request_id NUMBER;
   l_plan_proc_code pa_budget_versions.plan_processing_code%TYPE;
   l_refresh_required_flag VARCHAR2(1);
   l_request_id_v VARCHAR2(100);
   l_url_text VARCHAR2(500);
   l_return_status VARCHAR2(30);
   l_wbs_update_flag VARCHAR2(1);
   /* l_wbs_update_flag is used to display the error only one time,
      if the Cost and Revenue amounts are planned separately and
      both the target versions are undergoing WBS process update
      changes.   */
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_user_id := FND_GLOBAL.USER_ID;
   l_wbs_update_flag := 'Y';

   PA_COMP_PROFILE_PUB.GET_USER_INFO
          (p_user_id         => l_user_id,
           x_person_id       => l_person_id,
           x_resource_id     => l_resource_id,
           x_resource_name   => l_resource_name);

   FOR i IN 1 .. p_target_fp_version_id_tbl.COUNT LOOP
      l_chk_flag := 'Y';
      SELECT budget_status_code,
            locked_by_person_id,
            version_type,
            NVL(request_id,0),
            NVL(plan_processing_code,'ABC'),
            NVL(process_update_wbs_flag,'N')
      INTO
            l_budget_status_code,
            l_locked_by_person_id,
            l_version_type,
            l_request_id,
            l_plan_proc_code,
            l_refresh_required_flag
      FROM pa_budget_versions WHERE
           budget_version_id = p_target_fp_version_id_tbl(i);

      /* code added for Patchset L */
      /* We are not calling the API pa_fp_refresh_elements_pub.get_refresh_plan_ele_dtls
         for getting the status details as we are already
         getting information from pa_budget_versions table. */

       IF l_plan_proc_code = 'WUP' AND l_wbs_update_flag = 'Y' THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          l_chk_flag := 'N';
          l_wbs_update_flag := 'N';
          IF l_request_id IS NOT NULL THEN
             l_request_id_v := LTRIM(RTRIM(TO_CHAR(l_request_id)));
          END IF;
          l_url_text := 'OA.jsp?akRegionCode=FNDCPREQUESTVIEWREGION';
          l_url_text := l_url_text || '&akRegionApplicationId=0';
          l_url_text := l_url_text || '&progApplShortName=PA&progShortName=PAWPUWBS';
          l_url_text := l_url_text || '&requestId=' || l_request_id_v;

          PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                p_msg_name       => 'PA_FP_MERGE_WBS_UPD',
                                p_token1         => 'URLTXT',
                                p_value1         => l_url_text );
       END IF;
      /* code added for Patchset L */

      /* checking for Submitted status */

      IF l_budget_status_code = 'S' AND l_chk_flag = 'Y' THEN
         l_chk_flag := 'N';
         x_return_status := FND_API.G_RET_STS_ERROR;
         IF l_version_type = 'ALL' THEN
            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_FP_MERGE_ALL_SUBMIT');
         ELSE
            BEGIN
               SELECT meaning
               INTO l_meaning
               FROM pa_lookups
               WHERE lookup_type = 'FIN_PLAN_VER_TYPE'
               AND lookup_code = l_version_type;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_meaning := NULL;
            END;

            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_FP_MERGE_SUBMIT',
                                  p_token1         => 'VERTYPE',
                                  p_value1         => l_meaning );
         END IF;
      END IF;

      /* checking for lock. If the version is in Submitted status, the msg for
         the Lock should not be displayed, even though the locked user id is
         different. l_chk_flag is used to avoid the lock err msg in this case. */

      l_locked_by_name := NULL;

      IF l_locked_by_person_id IS NOT NULL AND
         l_locked_by_person_id <> l_person_id AND
         l_chk_flag = 'Y' THEN
         l_locked_by_name := pa_fin_plan_utils.get_person_name(l_locked_by_person_id );
         x_return_status := FND_API.G_RET_STS_ERROR;
         IF l_version_type = 'ALL' THEN
            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_FP_MERGE_ALL_LCK',
                                  p_token1         => 'LOCKBY',
                                  p_value1         => l_locked_by_name );
         ELSE
            BEGIN
               SELECT meaning
               INTO l_meaning
               FROM pa_lookups
               WHERE lookup_type = 'FIN_PLAN_VER_TYPE'
               AND lookup_code = l_version_type;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_meaning := NULL;
            END;

            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_FP_MERGE_LCK',
                                  p_token1         => 'VERTYPE',
                                  p_value1         => l_meaning,
                                  p_token2         => 'LOCKBY',
                                  p_value2         => l_locked_by_name );
         END IF;
      END IF;
   END LOOP;


EXCEPTION
  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_FP_CI_IMPLEMENT_PKG',
                            p_procedure_name => 'CHK_PLAN_VER_FOR_MERGE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

END chk_plan_ver_for_merge;

END pa_fp_ci_implement_pkg;

/
