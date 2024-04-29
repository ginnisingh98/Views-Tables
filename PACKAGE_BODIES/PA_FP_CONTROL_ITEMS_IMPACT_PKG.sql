--------------------------------------------------------
--  DDL for Package Body PA_FP_CONTROL_ITEMS_IMPACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_CONTROL_ITEMS_IMPACT_PKG" AS
/* $Header: PAFPCIIB.pls 120.4.12010000.5 2009/06/29 08:12:25 vgovvala ship $ */
P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
PROCEDURE Maintain_Ctrl_Item_Version(
                        p_project_id                IN   Pa_Projects_All.Project_Id%TYPE,
                        p_ci_id                     IN   NUMBER,
                        p_fp_pref_code              IN   VARCHAR2,
                        p_fin_plan_type_id_cost     IN   NUMBER,
                        p_fin_plan_type_id_rev      IN   NUMBER,
                        p_fin_plan_type_id_all      IN   NUMBER,
                        p_est_proj_raw_cost         IN   NUMBER,
                        p_est_proj_bd_cost          IN   NUMBER,
                        p_est_proj_revenue          IN   NUMBER,
                        p_est_qty                   IN   NUMBER,
                        p_est_equip_qty             IN   NUMBER,  -- FP.M
                        p_button_pressed_from_page  IN   VARCHAR2,
                        p_impacted_task_id          IN   NUMBER ,
                        p_agreement_id              IN   NUMBER   DEFAULT NULL,
                        p_agreement_number          IN   VARCHAR2 DEFAULT NULL,
                        x_return_status             OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_msg_count                 OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data                  OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_plan_version_id           OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) IS
   l_fin_plan_type_id NUMBER;
   l_count  NUMBER;
   l_bv_id      VARCHAR2(50);
   l_bv_id_cost NUMBER;
   l_bv_id_rev  NUMBER;
   l_bv_id_all  NUMBER;
   l_element_type pa_budget_versions.version_type%TYPE;
   l_plan_version_id NUMBER;
   l_proj_fp_option_id NUMBER;
   l_proj_curr_code pa_projects_all.project_currency_code%TYPE;
   l_projfunc_curr_code pa_projects_all.projfunc_currency_code%TYPE;
   l_est_projfunc_raw_cost pa_budget_versions.est_projfunc_raw_cost%TYPE;
   l_est_projfunc_bd_cost  pa_budget_versions.est_projfunc_burdened_cost%TYPE;
   l_est_projfunc_revenue  pa_budget_versions.est_projfunc_revenue%TYPE;
   l_no_of_app_plan_types NUMBER;
   l_message_name     fnd_new_messages.message_name%TYPE;
   l_msg_data         VARCHAR2(1000);
   l_data             VARCHAR2(1000);
   l_msg_index_out        NUMBER:=0;
   l_msg_count NUMBER;
   l_ci_impact_id NUMBER;
   l_baseline_funding_flag pa_projects_all.baseline_funding_flag%TYPE;
   l_agreement_id PA_AGREEMENTS_ALL.Agreement_Id%TYPE;
   l_impact_type_code pa_ci_impacts.impact_type_code%TYPE;
   l_est_proj_raw_cost     pa_budget_versions.est_project_raw_cost%TYPE;
   l_est_proj_bd_cost      pa_budget_versions.est_project_burdened_cost%TYPE;
   l_est_qty               pa_budget_versions.est_quantity%TYPE;
   l_est_equip_qty         pa_budget_versions.est_equipment_quantity%TYPE;
   l_est_proj_revenue      pa_budget_versions.est_project_revenue%TYPE;

   l_approved_cost_plan_type_flag          Pa_Proj_Fp_Options.APPROVED_COST_PLAN_TYPE_FLAG%TYPE;   -- Added for bug 4907408

   -- Bug 5845142. Selected app cost/rev flags too.
   CURSOR est_amt_csr
   IS
   SELECT est_project_raw_cost,
          est_project_burdened_cost,
          est_quantity,
          est_equipment_quantity,
          est_project_revenue,
          version_type,
          agreement_id,
          approved_cost_plan_type_flag,
          approved_rev_plan_type_flag
   FROM   pa_budget_versions
   WHERE  project_id=p_project_id
   AND    ci_id=p_ci_id;
   est_amt_rec      est_amt_csr%ROWTYPE;
   est_amt_rec_tmp  est_amt_csr%ROWTYPE;

   --Bug 7497389
   l_cost_ci_plan_version_id        pa_budget_versions.budget_version_id%TYPE;
   l_rev_ci_plan_version_id         pa_budget_versions.budget_version_id%TYPE;
BEGIN
   FND_MSG_PUB.initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_agreement_id  := p_agreement_id;
   IF p_pa_debug_mode = 'Y' THEN
      PA_DEBUG.init_err_stack('p_button_pressed_from_page '||p_button_pressed_from_page);
   END IF;

   IF p_pa_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Entering Maintain_Ctrl_Item_Version';
            pa_debug.write('Maintain_Ctrl_Item_Version',pa_debUg.g_err_stage,3);

      pa_debug.g_err_stage:= 'Project_id:'|| p_project_id;
            pa_debug.write('Maintain_Ctrl_Item_Version',pa_debug.g_err_stage,3);

      pa_debug.g_err_stage:= 'p_ci_id:'|| p_ci_id;
            pa_debug.write('Maintain_Ctrl_Item_Version',pa_debug.g_err_stage,3);
      pa_debug.g_err_stage:= 'p_agreement_id:' || p_agreement_id;
            pa_debug.write('Maintain_Ctrl_Item_Version',pa_debug.g_err_stage,3);
      pa_debug.g_err_stage:= 'p_agreement_number:'|| p_agreement_number;
            pa_debug.write('Maintain_Ctrl_Item_Version',pa_debug.g_err_stage,3);
   END IF;

   SELECT COUNT(*) INTO l_no_of_app_plan_types FROM Pa_Proj_Fp_Options
   WHERE
   Project_Id = p_project_id AND
   Fin_Plan_Option_Level_Code = 'PLAN_TYPE' AND
   ( NVL(Approved_Cost_Plan_Type_Flag ,'N') = 'Y' OR
     NVL(Approved_Rev_Plan_Type_Flag  ,'N') = 'Y' ) ;


   /* Added the if block for bug 4907408
      To get plan type attached to the project*/
   /* Bug 5210100: PQE 11i bug fix porting. Re-structuring the follwoing
    * query to get whether an approved cost plan type is attached.
    *
    *IF l_no_of_app_plan_types = 1 THEN
    *    SELECT approved_cost_plan_type_flag
    *    INTO   l_approved_cost_plan_type_flag
    *    FROM   pa_proj_fp_options
    *    WHERE  project_id = p_project_id
    *    AND    fin_plan_option_level_code = 'PLAN_TYPE'
    *    AND    ( NVL(approved_cost_plan_type_flag,'N') = 'Y'
    *             OR
    *             NVL(approved_rev_plan_type_flag,'N') = 'Y');
    *END IF; -- bug 4907408
    */
   BEGIN
       SELECT 'Y'
       INTO   l_approved_cost_plan_type_flag
       FROM   DUAL
       WHERE  EXISTS (SELECT 'X'
                      FROM   pa_proj_fp_options
                      WHERE  project_id = p_project_id
                      AND    fin_plan_option_level_code = 'PLAN_TYPE'
                      AND    approved_cost_plan_type_flag = 'Y');
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
           l_approved_cost_plan_type_flag := 'N';
   END;
   /* End of Addition for bug 5210100 */


   IF l_no_of_app_plan_types = 0 THEN
      IF p_pa_debug_mode = 'Y' THEN
         PA_DEBUG.write_log (x_module      =>
         'pa.plsql.Pa_Fp_Control_Items_Impact_Pkg.Maintain_Ctrl_Item_Version.approved_plan_types'
                       ,x_msg         => 'no of approved plan types is zero'
                       ,x_log_level   => 5);
       END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      IF p_button_pressed_from_page = 'COST_EDIT' THEN
         l_message_name := 'PA_FP_CI_NO_APP_COST_PLAN';
      END IF;
      IF p_button_pressed_from_page = 'REVENUE_EDIT' THEN
         l_message_name := 'PA_FP_CI_NO_APP_REV_PLAN';
      END IF;
      IF p_button_pressed_from_page = 'FROM_ACTION_LIST' OR
         p_button_pressed_from_page = 'ALL_EDIT' THEN
         l_message_name := 'PA_FP_CI_NO_APP_PLAN_TYPE';
      END IF;
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                            p_msg_name       => l_message_name );
      x_msg_count := fnd_msg_pub.count_msg;
      IF x_msg_count = 1 THEN
         PA_INTERFACE_UTILS_PUB.Get_Messages (
                                        p_encoded        => FND_API.G_TRUE,
                                        p_msg_index      => 1,
                                        p_msg_count      => 1 ,
                                        p_msg_data       => l_msg_data ,
                                        p_data           => x_msg_data,
                                        p_msg_index_out  => l_msg_index_out );
             -- x_msg_data := l_data;
      END IF;
       IF p_pa_debug_mode = 'Y' THEN
          PA_DEBUG.Reset_Err_stack;
       END IF;
       RETURN;
   END IF;

   SELECT Project_Currency_Code,
          Projfunc_Currency_Code,
          NVL(Baseline_Funding_Flag,'N') INTO
          l_proj_curr_code,
          l_projfunc_curr_code,
          l_baseline_Funding_flag
   FROM Pa_Projects_All
   WHERE
   Project_Id = p_project_id;

    /* Bug 3799500: rounding the quantities, if they are not null
     */
    IF p_est_qty IS NOT NULL THEN
        l_est_qty := ROUND(p_est_qty, 5);
    END IF;

    IF p_est_equip_qty IS NOT NULL THEN
       l_est_equip_qty := ROUND(p_est_equip_qty, 5);
    END IF;

    --Select the existing estimated amounts for the ci_id. If they are created/modified only then
    --the maintain_plan_version/create ci impact apis should be called
    OPEN est_amt_csr;
    LOOP
      FETCH est_amt_csr INTO est_amt_rec_tmp;
      EXIT WHEN est_amt_csr%NOTFOUND;
      -- Bug 5845142. The cost/rev impacts should be decided based on app cost/rev flags
      IF est_amt_rec_tmp.approved_cost_plan_type_flag='Y' THEN

         est_amt_rec.est_project_raw_cost:=est_amt_rec_tmp.est_project_raw_cost;
         est_amt_rec.est_project_burdened_cost:=est_amt_rec_tmp.est_project_burdened_cost;
         est_amt_rec.est_quantity:=est_amt_rec_tmp.est_quantity;
         est_amt_rec.est_equipment_quantity:=est_amt_rec_tmp.est_equipment_quantity;
      END IF;
      IF est_amt_rec_tmp.approved_rev_plan_type_flag='Y' THEN
         est_amt_rec.est_project_revenue:= est_amt_rec_tmp.est_project_revenue;
         est_amt_rec.agreement_id:= est_amt_rec_tmp.agreement_id;
      END IF;

    END LOOP;
    CLOSE est_amt_csr;

   IF p_button_pressed_from_page = 'COST_EDIT' OR
      p_button_pressed_from_page = 'REVENUE_EDIT' OR
      p_button_pressed_from_page = 'ALL_EDIT'  OR
      NVL(p_est_proj_raw_cost,0) <> NVL(est_amt_rec.est_project_raw_cost,0)        OR
      NVL(p_est_proj_bd_cost,0)  <> NVL(est_amt_rec.est_project_burdened_cost,0)   OR
      NVL(l_est_qty,0)           <> NVL(est_amt_rec.est_quantity,0)                OR
      NVL(l_est_equip_qty,0)     <> NVL(est_amt_rec.est_equipment_quantity,0)      OR
      NVL(p_agreement_id,0)      <> NVL(est_amt_rec.agreement_id,0)                OR --Impact should be created even when only agreement is entered and saved
      NVL(p_est_proj_revenue,0)  <> NVL(est_amt_rec.est_project_revenue,0)THEN
         IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.write_log (x_module      =>
         'pa.plsql.Pa_Fp_Control_Items_Impact_Pkg.Maintain_Ctrl_Item_Version.check_for_fp_impact'
                       ,x_msg         => 'inside edit buttons check'
                       ,x_log_level   => 5);
         END IF;
      /* FP.M -The following function call is used to get the impact information
       */
        l_impact_type_code := Pa_Fp_Control_Items_Utils.is_impact_exists(p_ci_id);
        IF p_pa_debug_mode = 'Y' THEN
           PA_DEBUG.write_log (x_module      => 'pa.plsql.Pa_Fp_Control_Items_Impact_Pkg.Maintain_Ctrl_Item_Version.calling_ci_impact_pkg'
                              ,x_msg         => 'calling create ci impact '
                              ,x_log_level   => 5);
        END IF;
         /* FP.M - Apart from the record with Impact_type_code of FINPLAN
          * one more record with Impact_type_code either finplan_cost or
          * finplan_revenue or two records with these two values would be created
          */

         IF l_impact_type_code NOT IN ('COST','BOTH') AND
            NVL(l_approved_cost_plan_type_flag,'N') = 'Y'  AND      -- Added for bug 5210100
            (p_button_pressed_from_page = 'COST_EDIT' OR
             p_button_pressed_from_page = 'ALL_EDIT'  OR
             NVL(p_est_proj_raw_cost,0) <> NVL(est_amt_rec.est_project_raw_cost,0)        OR
             NVL(p_est_proj_bd_cost,0)  <> NVL(est_amt_rec.est_project_burdened_cost,0)   OR
             NVL(l_est_qty,0)           <> NVL(est_amt_rec.est_quantity,0)                OR
            (NVL(p_agreement_id,0)      <> NVL(est_amt_rec.agreement_id,0) AND l_no_of_app_plan_types = 1  -- Modified for bug 5210100
	    AND p_fp_pref_code = 'COST_AND_REV_SAME')  OR   -- Modified for bug 6119004
             NVL(l_est_equip_qty,0)     <> NVL(est_amt_rec.est_equipment_quantity,0)
             )THEN
              PA_CI_IMPACTS_pub.create_ci_impact(
                       p_ci_id                  => p_ci_id,
                       p_impact_type_code       => 'FINPLAN_COST',
                       p_status_code            => 'CI_IMPACT_PENDING',
                       p_commit                 => 'F',
                       p_validate_only          => 'F',
                       p_description            => NULL,
                       p_implementation_comment => NULL,
                       x_ci_impact_id           => l_ci_impact_id,
                       x_return_status          => x_return_status,
                       x_msg_count              => x_msg_count,
                       x_msg_data               =>x_msg_data
                                                  );
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   x_msg_count := fnd_msg_pub.count_msg;
                   IF x_msg_count = 1 THEN
                         PA_INTERFACE_UTILS_PUB.Get_Messages (
                                p_encoded        => FND_API.G_TRUE,
                                p_msg_index      => 1,
                                p_msg_count      => 1 ,
                                p_msg_data       => l_msg_data ,
                                p_data           => x_msg_data,
                                p_msg_index_out  => l_msg_index_out );
                   END IF;
              IF p_pa_debug_mode = 'Y' THEN
                 PA_DEBUG.Reset_Err_stack;
              END IF;
              RETURN;
              END IF;
         END IF;
         IF l_impact_type_code NOT IN ('REVENUE','BOTH') AND
           (p_button_pressed_from_page = 'REVENUE_EDIT' OR
            p_button_pressed_from_page = 'ALL_EDIT'     OR
            NVL(p_agreement_id,0)      <> NVL(est_amt_rec.agreement_id,0) OR
            NVL(p_est_proj_revenue,0)  <> NVL(est_amt_rec.est_project_revenue,0))      THEN
              PA_CI_IMPACTS_pub.create_ci_impact(
                       p_ci_id                  => p_ci_id,
                       p_impact_type_code       => 'FINPLAN_REVENUE',
                       p_status_code            => 'CI_IMPACT_PENDING',
                       p_commit                 => 'F',
                       p_validate_only          => 'F',
                       p_description            => NULL,
                       p_implementation_comment => NULL,
                       x_ci_impact_id           => l_ci_impact_id,
                       x_return_status          => x_return_status,
                       x_msg_count              => x_msg_count,
                       x_msg_data               =>x_msg_data
                                                  );
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   x_msg_count := fnd_msg_pub.count_msg;
                   IF x_msg_count = 1 THEN
                         PA_INTERFACE_UTILS_PUB.Get_Messages (
                                p_encoded        => FND_API.G_TRUE,
                                p_msg_index      => 1,
                                p_msg_count      => 1 ,
                                p_msg_data       => l_msg_data ,
                                p_data           => x_msg_data,
                                p_msg_index_out  => l_msg_index_out );
                   END IF;
              IF p_pa_debug_mode = 'Y' THEN
                 PA_DEBUG.Reset_Err_stack;
              END IF;
              RETURN;
              END IF;
         END IF;
   END IF;

   IF l_no_of_app_plan_types = 1 AND
      (  p_fp_pref_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY OR
         p_fp_pref_code =  PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY OR
         p_fp_pref_code =  PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME ) AND
          (p_button_pressed_from_page = 'REVENUE_EDIT' OR
           p_button_pressed_from_page = 'ALL_EDIT'     OR
           p_button_pressed_from_page = 'COST_EDIT'     OR
           NVL(p_agreement_id,0)      <> NVL(est_amt_rec.agreement_id,0) OR
           NVL(p_est_proj_raw_cost,0) <> NVL(est_amt_rec.est_project_raw_cost,0)        OR
           NVL(p_est_proj_bd_cost,0)  <> NVL(est_amt_rec.est_project_burdened_cost,0)   OR
           NVL(l_est_qty,0)           <> NVL(est_amt_rec.est_quantity,0)                OR
           NVL(l_est_equip_qty,0)     <> NVL(est_amt_rec.est_equipment_quantity,0)      OR
           NVL(p_est_proj_revenue,0)  <> NVL(est_amt_rec.est_project_revenue,0))THEN


      IF p_fp_pref_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY THEN
         l_fin_plan_type_id := p_fin_plan_type_id_cost;
         l_element_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST;
      ELSIF p_fp_pref_code = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY  THEN
         l_fin_plan_type_id := p_fin_plan_type_id_rev;
         l_element_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE;
      ELSIF p_fp_pref_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME THEN
         l_fin_plan_type_id := p_fin_plan_type_id_all;
         l_element_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL;
      END IF;
      /* ELSIF p_fp_pref_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP THEN
         l_fin_plan_type_id := p_fin_plan_type_id_all;
         l_element_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL;   */

      IF l_element_type IN (PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL) AND
         p_agreement_id IS NULL THEN

         Pa_Fp_Control_Items_Utils.IsValidAgreement(
                          p_project_id => p_project_id,
                          p_agreement_number => p_agreement_number,
                          x_agreement_id => l_agreement_id,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data,
                          x_return_status => x_return_status );
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             x_msg_count := fnd_msg_pub.count_msg;
             IF x_msg_count = 1 THEN
                PA_INTERFACE_UTILS_PUB.Get_Messages (
                                            p_encoded        => FND_API.G_TRUE,
                                            p_msg_index      => 1,
                                            p_msg_count      => 1 ,
                                            p_msg_data       => l_msg_data ,
                                            p_data           => x_msg_data,
                                            p_msg_index_out  => l_msg_index_out );
             END IF;
             IF p_pa_debug_mode = 'Y' THEN
                PA_DEBUG.Reset_Err_stack;
             END IF;
             RETURN;
          END IF;
      END IF;

      Maintain_Plan_Version(
                        p_project_id            => p_project_id,
                        p_ci_id                 => p_ci_id,
                        p_fp_pref_code          => p_fp_pref_code,
                        p_fin_plan_type_id      => l_fin_plan_type_id,
                        p_est_proj_raw_cost     => p_est_proj_raw_cost,
                        p_est_proj_bd_cost      => p_est_proj_bd_cost,
                        p_est_proj_revenue      => p_est_proj_revenue,
                        p_est_qty               => l_est_qty,
                        p_est_equip_qty         => l_est_equip_qty,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        p_project_currency_Code => l_proj_curr_code,
                        p_projfunc_currency_code => l_projfunc_curr_code,
                        p_element_type           => l_element_type,
                        x_plan_version_id        => l_bv_id ,
                        p_impacted_task_id       => p_impacted_task_id,
                        p_agreement_id           => l_agreement_id,
                        p_agreement_number       => p_agreement_number,
                        p_baseline_funding_flag  => l_baseline_funding_flag);

         x_plan_version_id := ltrim(rtrim(l_bv_id));

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_msg_count := fnd_msg_pub.count_msg;
         IF x_msg_count = 1 THEN
            PA_INTERFACE_UTILS_PUB.Get_Messages (
                                        p_encoded        => FND_API.G_TRUE,
                                        p_msg_index      => 1,
                                        p_msg_count      => 1 ,
                                        p_msg_data       => l_msg_data ,
                                        p_data           => x_msg_data,
                                        p_msg_index_out  => l_msg_index_out );
                -- x_msg_data := l_data;
         END IF;
         IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Err_stack;
         END IF;
         RETURN;
      END IF;
   ELSIF l_no_of_app_plan_types = 2 OR
         p_fp_pref_code =  PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP THEN

      /* Calling the create api with the proper version type */
      IF p_button_pressed_from_page = 'COST_EDIT' OR
         NVL(p_est_proj_raw_cost,0) <> NVL(est_amt_rec.est_project_raw_cost,0)        OR
         NVL(p_est_proj_bd_cost,0)  <> NVL(est_amt_rec.est_project_burdened_cost,0)   OR
         NVL(l_est_qty,0)           <> NVL(est_amt_rec.est_quantity,0)                OR
         NVL(l_est_equip_qty,0)     <> NVL(est_amt_rec.est_equipment_quantity,0) THEN

              IF l_no_of_app_plan_types=2 THEN
                  l_fin_plan_type_id := p_fin_plan_type_id_cost;
              ELSE
                  l_fin_plan_type_id := p_fin_plan_type_id_all;
              END IF;
              --Bug 5845142. CI Cost impacts can be of type ALL too
              --l_element_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST;
              SELECT DECODE(fin_plan_preference_code,
                            PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL,
                            PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST)
              INTO   l_element_type
              FROM   pa_proj_fp_options
              WHERE  project_id=p_project_id
              AND    fin_plan_type_id=l_fin_plan_type_id
              AND    fin_plan_version_id IS NULL;

              Maintain_Plan_Version(
                        p_project_id             => p_project_id,
                        p_ci_id                  => p_ci_id,
                        p_fp_pref_code           => p_fp_pref_code,
                        p_fin_plan_type_id       => l_fin_plan_type_id,
                        p_est_proj_raw_cost      => p_est_proj_raw_cost,
                        p_est_proj_bd_cost       => p_est_proj_bd_cost,
                        p_est_proj_revenue       => NULL,
                        p_est_qty                => l_est_qty,
                        p_est_equip_qty          => l_est_equip_qty,
                        x_return_status          => x_return_status,
                        x_msg_count              => x_msg_count,
                        x_msg_data               => x_msg_data,
                        p_project_currency_Code  => l_proj_curr_code,
                        p_projfunc_currency_code => l_projfunc_curr_code,
                        p_element_type           => l_element_type,
                        x_plan_version_id        => l_bv_id ,
                        p_impacted_task_id       => p_impacted_task_id,
                        p_baseline_funding_flag  => l_baseline_funding_flag);

                   x_plan_version_id := ltrim(rtrim(l_bv_id));
                   --Bug 7497389
                   l_cost_ci_plan_version_id:=x_plan_version_id;
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   x_msg_count := fnd_msg_pub.count_msg;
                   IF x_msg_count = 1 THEN
                          PA_INTERFACE_UTILS_PUB.Get_Messages (
                                        p_encoded        => FND_API.G_TRUE,
                                        p_msg_index      => 1,
                                        p_msg_count      => 1 ,
                                        p_msg_data       => l_msg_data ,
                                        p_data           => x_msg_data,
                                        p_msg_index_out  => l_msg_index_out );
                          -- x_msg_data := l_data;
                   END IF;
                   IF p_pa_debug_mode = 'Y' THEN
                         PA_DEBUG.Reset_Err_stack;
                   END IF;
                   RETURN;
              END IF;

        END IF;

        IF p_button_pressed_from_page = 'REVENUE_EDIT' OR
           NVL(p_agreement_id,0)      <> NVL(est_amt_rec.agreement_id,0) OR
           NVL(p_est_proj_revenue,0)  <> NVL(est_amt_rec.est_project_revenue,0) THEN
                 IF l_no_of_app_plan_types=2 THEN
                      l_fin_plan_type_id := p_fin_plan_type_id_rev;
                 ELSE
                      l_fin_plan_type_id := p_fin_plan_type_id_all;
                 END IF;


                 /* bug 7584903  impacts can be of type ALL too */
                 --l_element_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE;

	      SELECT DECODE(fin_plan_preference_code,
                            PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL,
                            PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE)
              INTO   l_element_type
              FROM   pa_proj_fp_options
              WHERE  project_id=p_project_id
              AND    fin_plan_type_id=l_fin_plan_type_id
              AND    fin_plan_version_id IS NULL;


                 IF p_agreement_id IS NULL THEN

                      Pa_Fp_Control_Items_Utils.IsValidAgreement(
                            p_project_id => p_project_id,
                            p_agreement_number => p_agreement_number,
                            x_agreement_id => l_agreement_id,
                            x_msg_count => x_msg_count,
                            x_msg_data => x_msg_data,
                            x_return_status => x_return_status );
                      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                            x_msg_count := fnd_msg_pub.count_msg;
                            IF x_msg_count = 1 THEN
                                  PA_INTERFACE_UTILS_PUB.Get_Messages (
                                            p_encoded        => FND_API.G_TRUE,
                                            p_msg_index      => 1,
                                            p_msg_count      => 1 ,
                                            p_msg_data       => l_msg_data ,
                                            p_data           => x_msg_data,
                                            p_msg_index_out  => l_msg_index_out );
                            END IF;
                            IF p_pa_debug_mode = 'Y' THEN
                                  PA_DEBUG.Reset_Err_stack;
                            END IF;
                            RETURN;
                      END IF;
                 END IF;

                 Maintain_Plan_Version(
                        p_project_id            => p_project_id,
                        p_ci_id                 => p_ci_id,
                        p_fp_pref_code          => p_fp_pref_code,
                        p_fin_plan_type_id      => l_fin_plan_type_id,
                        p_est_proj_raw_cost     => NULL,
                        p_est_proj_bd_cost      => NULL,
                        p_est_proj_revenue      => p_est_proj_revenue,
                        p_est_qty               => NULL,
                        p_est_equip_qty          => NULL,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        p_project_currency_Code => l_proj_curr_code,
                        p_projfunc_currency_code => l_projfunc_curr_code,
                        p_element_type           => l_element_type,
                        x_plan_version_id        => l_bv_id ,
                        p_impacted_task_id       => p_impacted_task_id,
                        p_agreement_id           => l_agreement_id,
                        p_agreement_number       => p_agreement_number );

                       x_plan_version_id := ltrim(rtrim(l_bv_id));
                       --Bug 7497389
                       l_rev_ci_plan_version_id:=x_plan_version_id;
                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                       x_msg_count := fnd_msg_pub.count_msg;
                       IF x_msg_count = 1 THEN
                            PA_INTERFACE_UTILS_PUB.Get_Messages (
                                        p_encoded        => FND_API.G_TRUE,
                                        p_msg_index      => 1,
                                        p_msg_count      => 1 ,
                                        p_msg_data       => l_msg_data ,
                                        p_data           => x_msg_data,
                                        p_msg_index_out  => l_msg_index_out );
                            -- x_msg_data := l_data;
                       END IF;
                       IF p_pa_debug_mode = 'Y' THEN
                            PA_DEBUG.Reset_Err_stack;
                       END IF;
                       RETURN;
                 END IF;
      END IF;

      --Bug 7497389. This condition is put to take care of the case where the agreement info is
      --entered for a change order and "Edit Planned Cost" button is clicked.

      IF l_rev_ci_plan_version_id IS NOT NULL AND
         l_cost_ci_plan_version_id IS NOT NULL THEN

        IF p_button_pressed_from_page = 'REVENUE_EDIT' THEN

            x_plan_version_id := l_rev_ci_plan_version_id;

        ELSIF p_button_pressed_from_page = 'COST_EDIT' THEN

            x_plan_version_id := l_cost_ci_plan_version_id;

        END IF;

     END IF;
   END IF;

EXCEPTION
  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_FP_CONTROL_ITEMS_IMPACT_PKG',
                            p_procedure_name => 'MAINTAIN_CTRL_ITEM_VERSION',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END Maintain_Ctrl_Item_Version;

PROCEDURE Maintain_Plan_Version(
                        p_project_id             IN   Pa_Projects_All.Project_Id%TYPE,
                        p_ci_id                  IN   NUMBER,
                        p_fp_pref_code           IN   VARCHAR2,
                        p_fin_plan_type_id       IN   NUMBER,
                        p_est_proj_raw_cost      IN   NUMBER,
                        p_est_proj_bd_cost       IN   NUMBER,
                        p_est_proj_revenue       IN   NUMBER,
                        p_est_qty                IN   NUMBER,
                        p_est_equip_qty          IN   NUMBER,  -- FP.M
                        p_project_currency_Code  IN   VARCHAR2,
                        p_projfunc_currency_code IN   VARCHAR2,
                        p_element_type           IN   VARCHAR2 ,
                        p_impacted_task_id       IN   NUMBER ,
                        p_agreement_id           IN   NUMBER   DEFAULT NULL,
                        p_agreement_number       IN   VARCHAR2 DEFAULT NULL,
                        p_baseline_funding_flag  IN   VARCHAR2 DEFAULT NULL,
                        x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data               OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_plan_version_id        OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
    ) IS
   l_est_projfunc_raw_cost pa_budget_versions.est_projfunc_raw_cost%TYPE;
   l_est_projfunc_bd_cost  pa_budget_versions.est_projfunc_burdened_cost%TYPE;
   l_est_projfunc_revenue  pa_budget_versions.est_projfunc_revenue%TYPE;
   l_bv_id      NUMBER;
   l_plan_version_id NUMBER;
   l_proj_fp_option_id NUMBER;
   l_agreement_id PA_AGREEMENTS_ALL.Agreement_Id%TYPE;
   l_create_ver_called_flag VARCHAR2(1);
   l_last_updated_by NUMBER := FND_GLOBAL.user_id;
   l_last_update_login NUMBER := FND_GLOBAL.login_id;
   l_sysdate DATE := SYSDATE;
   l_version_allowed_flag VARCHAR2(30);
   l_funding_bl_tab pa_fp_auto_baseline_pkg.funding_bl_tab;
   l_funding_level_code    VARCHAR2(100);
   l_err_code NUMBER := null;
   l_err_stage varchar2(1000) := null;
   l_err_stack varchar2(1000) := null;
   lx_cur_work_bv_id NUMBER;

   -- Bug 5845142
   l_approved_rev_plan_type_flag                 pa_proj_fp_options.approved_rev_plan_type_flag%TYPE;
   l_approved_cost_plan_type_flag                pa_proj_fp_options.approved_cost_plan_type_flag%TYPE;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_pa_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:= 'Entering Maintain_Plan_Version';
          pa_debug.write('Maintain_Plan_Version',pa_debUg.g_err_stage,3);

      pa_debug.g_err_stage:= 'Project_id:'|| p_project_id;
          pa_debug.write('Maintain_Plan_Version',pa_debug.g_err_stage,3);

      pa_debug.g_err_stage:= 'p_ci_id:'|| p_ci_id;
          pa_debug.write('Maintain_Plan_Version',pa_debug.g_err_stage,3);

     pa_debug.g_err_stage:= 'p_agreement_id:' || p_agreement_id;
          pa_debug.write('Maintain_Plan_Version',pa_debug.g_err_stage,3);

     pa_debug.g_err_stage:= 'p_agreement_number:'|| p_agreement_number;
          pa_debug.write('Maintain_Plan_Version',pa_debug.g_err_stage,3);

     pa_debug.g_err_stage:= 'p_element_type' || p_element_type;
         pa_debug.write('Maintain_Plan_Version',pa_debUg.g_err_stage,3); /* bug 7584903 */

   END IF;
   l_create_ver_called_flag := 'N';

      --Bug 5845142
      SELECT approved_rev_plan_type_flag,
             approved_cost_plan_type_flag
      INTO   l_approved_rev_plan_type_flag,
             l_approved_cost_plan_type_flag
      FROM   pa_proj_fp_options
      WHERE  project_id=p_project_id
      AND    fin_plan_type_id=p_fin_plan_type_id
      AND    fin_plan_version_id IS NULL;

      --Bug 5845142
      IF (p_element_type = 'REVENUE' OR p_element_type = 'ALL') AND
         l_approved_rev_plan_type_flag = 'Y'
      THEN
         l_agreement_id := p_agreement_id;
      ELSE
         l_agreement_id := NULL;
      END IF;
      BEGIN
          SELECT Budget_Version_Id INTO l_bv_id FROM Pa_Budget_Versions bv
          WHERE
               bv.Project_Id = p_project_id AND
               NVL(bv.Fin_Plan_Type_id,-1)  = p_fin_plan_type_id AND
               NVL(bv.ci_id,-1) = p_ci_id AND
                bv.Version_Type = p_element_type;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN

          /* Before creating CI version, there must be a current
             working version for the approved budget plan type */

          Pa_Fp_Control_Items_Utils.CHK_APRV_CUR_WORKING_BV_EXISTS
          ( p_project_id              => p_project_id
           ,p_fin_plan_type_id        => p_fin_plan_type_id
           ,p_version_type            => p_element_type
           ,x_cur_work_bv_id          => lx_cur_work_bv_id
           ,x_return_status           => x_return_status
           ,x_msg_count               => x_msg_count
           ,x_msg_data                => x_msg_data           );

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RETURN;
           END IF;

             /* the version name and description is not shown in the pages
                for control item versions, so storing dummy value as CI  */
             /* version type and element type value is same here */

             l_create_ver_called_flag := 'Y';
             --For bug 3823016
             --IF p_baseline_funding_flag = 'Y' THEN
               --Bug 5845142. Only if the approved rev plan type flag is Y the revenue impact
               --should be created.
               IF ((p_baseline_funding_flag = 'Y') and (p_element_type<> 'COST' AND
               l_approved_rev_plan_type_flag='Y')) THEN
                /* the following API only creates the version for
                     the control item */

                pa_billing_core.check_funding_level(
                                 x_project_id => p_project_id,
                                 x_funding_level => l_funding_level_code,
                                 x_err_code => l_err_code,
                                 x_err_stage => l_err_stage,
                                 x_err_stack => l_err_stack );

                 IF (l_err_code <> 0) THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    RETURN;
                 END IF;

                PA_FP_AUTO_BASELINE_PKG.CREATE_BASELINED_VERSION(
                   p_project_id              => p_project_id
                  ,p_fin_plan_type_id        => p_fin_plan_type_id
                  ,p_funding_level_code      => l_funding_level_code
                  ,p_version_name            => 'CI'
                  ,p_description             => 'CI'
                  ,p_funding_bl_tab          => l_funding_bl_tab
                  ,p_ci_id                   => p_ci_id
                  ,p_est_proj_raw_cost       => p_est_proj_raw_cost
                  ,p_est_proj_bd_cost        => p_est_proj_bd_cost
                  ,p_est_proj_revenue        => p_est_proj_revenue
                  ,p_est_qty                 => p_est_qty
                  ,p_est_equip_qty           => p_est_equip_qty
                  ,p_impacted_task_id        => p_impacted_task_id
                  ,p_agreement_id            => l_agreement_id
                  ,x_budget_version_id       => l_plan_version_id
                  ,x_return_status           => x_return_status
                  ,x_msg_count               => x_msg_count
                  ,x_msg_data                => x_msg_data
                );
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RETURN;
                END IF;

                l_bv_id := l_plan_version_id;
             ELSE
                  Pa_Fp_Control_Items_Utils.Is_Create_CI_Version_Allowed
                  (  p_project_id              => p_project_id
                    ,p_fin_plan_type_id        => p_fin_plan_type_id
                    ,p_version_type            => p_element_type
                    ,p_impacted_task_id        => p_impacted_task_id
                    ,x_version_allowed_flag    => l_version_allowed_flag
                    ,x_return_status           => x_return_status
                    ,x_msg_count               => x_msg_count
                    ,x_msg_data                => x_msg_data   );

                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     RETURN;
                  END IF;


                  pa_fin_plan_pub.Create_Version(
                  p_project_id           => p_project_id
                 ,p_fin_plan_type_id     => p_fin_plan_type_id
                 ,p_element_type         => p_element_type
                 ,p_version_name         => 'CI'
                 ,p_description          => 'CI'
                 ,px_budget_version_id   => l_plan_version_id
                 ,x_proj_fp_option_id    => l_proj_fp_option_id
                 ,x_return_status        => x_return_status
                 ,x_msg_count            => x_msg_count
                 ,x_msg_data             => x_msg_data
                 ,p_ci_id                => p_ci_id
                 ,p_est_proj_raw_cost    => p_est_proj_raw_cost
                 ,p_est_proj_bd_cost     => p_est_proj_bd_cost
                 ,p_est_proj_revenue     => p_est_proj_revenue
                 ,p_est_qty              => p_est_qty
                 ,p_est_equip_qty        => p_est_equip_qty
                 ,p_impacted_task_id     => p_impacted_task_id
           ,p_agreement_id         => l_agreement_id);

                 l_bv_id := l_plan_version_id;
               IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RETURN;
               END IF;
          END IF;
       END;

       IF l_create_ver_called_flag = 'N' THEN
            IF p_project_currency_Code = p_projfunc_currency_Code THEN
               l_est_projfunc_raw_cost := p_est_proj_raw_cost;
               l_est_projfunc_bd_cost  := p_est_proj_bd_cost;
               l_est_projfunc_revenue  := p_est_proj_revenue;
            ELSE
               delete from pa_fp_rollup_tmp;
               insert into pa_fp_rollup_tmp(
                      RESOURCE_ASSIGNMENT_ID,
                      START_DATE,
                      END_DATE,
                      TXN_CURRENCY_CODE,
                      PROJECT_CURRENCY_CODE,
                      PROJFUNC_CURRENCY_CODE,
                      TXN_RAW_COST,
                      TXN_BURDENED_COST,
                      TXN_REVENUE            )
               VALUES(
                       -1,
                       TRUNC(l_sysdate),
                       TRUNC(l_sysdate),
                       p_project_currency_Code,
                       p_project_currency_Code,
                       p_projfunc_currency_Code,
                       p_est_proj_raw_cost,
                       p_est_proj_bd_cost,
                       p_est_proj_revenue      );

               PA_FP_MULTI_CURRENCY_PKG.convert_txn_currency
                 ( p_budget_version_id  => l_bv_id
                  ,p_entire_version     => 'N'
                  ,x_return_status      => x_return_status
                  ,x_msg_count          => x_msg_count
                  ,x_msg_data           => x_msg_data );
               IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RETURN;
               END IF;
               SELECT PROJFUNC_RAW_COST,
                      PROJFUNC_BURDENED_COST,
                      PROJFUNC_REVENUE
               INTO
                  l_est_projfunc_raw_cost ,
                  l_est_projfunc_bd_cost  ,
                  l_est_projfunc_revenue
               FROM Pa_Fp_Rollup_Tmp
               WHERE RESOURCE_ASSIGNMENT_ID = -1;

            END IF;
            /* for proj curr code equal to projfunc curr code chk */
            UPDATE Pa_Budget_Versions SET
                 est_project_raw_cost       =  p_est_proj_raw_cost,
                 est_project_burdened_cost  =  p_est_proj_bd_cost,
                 est_project_revenue        =  p_est_proj_revenue,
                 est_quantity               =  p_est_qty,
                 est_equipment_quantity     =  p_est_equip_qty,
                 agreement_id               =  l_agreement_id, -- Bug 3752125
                 est_projfunc_raw_cost      =  l_est_projfunc_raw_cost,
                 est_projfunc_burdened_cost =  l_est_projfunc_bd_cost,
                 est_projfunc_revenue       =  l_est_projfunc_revenue,
                 last_update_date           =  l_sysdate,
                 last_updated_by            = l_last_updated_by,
                 last_update_login          = l_last_update_login
            WHERE  Budget_Version_Id          = l_bv_id;
      END IF;
      /* for create ver called flag check */

      x_plan_version_id := l_bv_id ;
EXCEPTION
  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_FP_CONTROL_ITEMS_IMPACT_PKG',
                            p_procedure_name => 'Maintain_Plan_Version',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END Maintain_Plan_Version;

PROCEDURE delete_ci_plan_versions
(
     p_project_id IN NUMBER,
     p_ci_id IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     p_commit_flag IN VARCHAR2,
     x_return_status                    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                         OUT NOCOPY VARCHAR2  ) --File.Sql.39 bug 4440895
IS
     l_bv_id_tab PA_PLSQL_DATATYPES.IdTabTyp;
     l_chk NUMBER := 0;
     l_rv_number_tab PA_PLSQL_DATATYPES.NumTabTyp;
     l_msg_data         VARCHAR2(1000);
     l_data             VARCHAR2(1000);
     l_msg_index_out        NUMBER:=0;
     l_msg_count NUMBER;
     l_module VARCHAR2(255);
BEGIN
   l_module := 'pa.plsql.Pa_Fp_Control_Items_Impact_Pkg.delete_ci_plan_versions';

   IF p_pa_debug_mode = 'Y' THEN
      PA_DEBUG.init_err_stack('Pa_Fp_Control_Items_Impact_Pkg.delete_ci_plan_versions');
      PA_DEBUG.write_log (x_module      => l_module
                     ,x_msg         => 'inside del API call'
                     ,x_log_level   => 5);
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_init_msg_list = 'Y' THEN
      FND_MSG_PUB.initialize;
   END IF;

   l_bv_id_tab.delete;
   l_rv_number_tab.delete;

   BEGIN
      SELECT budget_version_id ,
      record_version_number
      BULK COLLECT INTO
      l_bv_id_tab,
      l_rv_number_tab
      FROM pa_budget_versions
      WHERE
      project_id = p_project_id AND
      ci_id = p_ci_id;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      l_chk := 1;
   END;

   FOR I IN  1 .. l_bv_id_tab.COUNT LOOP
      IF p_pa_debug_mode = 'Y' THEN
         PA_DEBUG.write_log (x_module      => l_module
                     ,x_msg         => 'before calling  dele version in finplan pub'
                     ,x_log_level   => 5);
      END IF;
      pa_fin_plan_pub.Delete_Version(
                         p_project_id  => p_project_id,
                         p_budget_version_id => l_bv_id_tab(i),
                         p_record_version_number => l_rv_number_tab(i),
                         x_return_status => x_return_status,
                         x_msg_count    => x_msg_count,
                         x_msg_data     => x_msg_data   );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         ROLLBACK;
         x_msg_count := fnd_msg_pub.count_msg;
         IF x_msg_count = 1 THEN
            PA_INTERFACE_UTILS_PUB.Get_Messages (
                                        p_encoded        => FND_API.G_TRUE,
                                        p_msg_index      => 1,
                                        p_msg_count      => 1 ,
                                        p_msg_data       => l_msg_data ,
                                        p_data           => x_msg_data,
                                        p_msg_index_out  => l_msg_index_out );
         END IF;
         IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Err_stack;
         END IF;
         RETURN;
      END IF;

   END LOOP;
   /* the finplan impact record also should be deleted from
      ci table */
   DELETE FROM pa_ci_impacts
   WHERE
   ci_id = p_ci_id AND
   impact_type_code IN ('FINPLAN','FINPLAN_COST','FINPLAN_REVENUE');

   IF p_commit_flag = 'Y' THEN
      COMMIT;
   END IF;
   IF p_pa_debug_mode = 'Y' THEN
      PA_DEBUG.Reset_Err_stack;
   END IF;
   RETURN;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF p_pa_debug_mode = 'Y' THEN
       PA_DEBUG.Reset_Err_stack;
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_FP_CONTROL_ITEMS_IMPACT_PKG',
                            p_procedure_name => 'DELETE_CI_PLAN_VERSIONS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);



END delete_ci_plan_versions;

END Pa_Fp_Control_Items_Impact_Pkg;

/
