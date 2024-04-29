--------------------------------------------------------
--  DDL for Package Body PA_FP_CONTROL_ITEMS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_CONTROL_ITEMS_UTILS" AS
/* $Header: PAFPCIUB.pls 120.6.12010000.10 2010/04/16 10:14:52 rrambati ship $ */
P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
g_module_name   VARCHAR2(100) := 'pa.plsql.PA_CONTROL_ITEM_UTILS';

--Bug 5845142. These variables are only for internal usage of check_valid_combo(for cvc) function
--and should not be used in other procedures/functions
l_cvc_project_id             NUMBER;
l_cvc_app_cost_pt_rev_flag   pa_proj_fp_options.approved_cost_plan_type_flag%TYPE;
l_cvc_app_cost_pt_pref_code  pa_proj_fp_options.fin_plan_preference_code%TYPE;
--Bug 5845142

PROCEDURE Get_Fin_Plan_Dtls(p_project_id                    IN          Pa_Projects_All.Project_Id%TYPE,
                            p_ci_id                         IN          NUMBER,
                            x_fin_plan_type_id_cost         OUT         NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            x_fin_plan_type_id_rev          OUT         NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            x_fin_plan_type_id_all          OUT         NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            x_fp_type_id_margin_code        OUT         NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            x_margin_derived_from_code      OUT         NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_report_labor_hours_code       OUT         NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_fp_pref_code                  OUT         NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_project_currency_code         OUT         NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_baseline_funding_flag         OUT         NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_msg_data                      OUT         NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_msg_count                     OUT         NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            x_return_status                 OUT         NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_ci_type_class_code            OUT         NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_no_of_ci_plan_versions        OUT         NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            x_ci_est_qty                    OUT         NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            x_ci_planned_qty                OUT         NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            x_baselined_planned_qty         OUT         NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            x_ci_ver_plan_prc_code          OUT         NOCOPY pa_budget_versions.plan_processing_code%TYPE, --File.Sql.39 bug 4440895
                            x_request_id                    OUT         NOCOPY pa_budget_versions.request_id%TYPE) IS --File.Sql.39 bug 4440895

   l_no_of_app_plan_types NUMBER;
   l_tmp_fin_plan_type_id NUMBER;
   l_rev_budget_flag Pa_Project_Types_All.Allow_Rev_Budget_Entry_Flag%TYPE;
   l_cost_budget_flag Pa_Project_Types_All.Allow_Cost_Budget_Entry_Flag%TYPE;
   l_impact_type   VARCHAR2(30); -- Bug 3734840
BEGIN
   x_ci_est_qty := NULL;
   x_ci_planned_qty := NULL;
   x_baselined_planned_qty := NULL;

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
   x_msg_count := 0;
   x_no_of_ci_plan_versions := 0;
   x_margin_derived_from_code := 'B';
   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.init_err_stack('PA_FP_CONTROL_ITEMS_UTILS.Get_Fin_Plan_Dtls');
   END IF;
   FND_MSG_PUB.initialize;

   x_ci_est_qty := pa_fin_plan_utils.Get_Approved_Budget_Ver_Qty(
                   p_project_id  => p_project_id,
                   p_version_code => 'CTRL_ITEM_VERSION',
                   p_quantity_type =>  'ESTIMATED',
                   p_ci_id         => p_ci_id );

   x_ci_planned_qty := pa_fin_plan_utils.Get_Approved_Budget_Ver_Qty(
                   p_project_id  => p_project_id,
                   p_version_code => 'CTRL_ITEM_VERSION',
                   p_quantity_type =>  'PLANNED',
                   p_ci_id         => p_ci_id );

   x_baselined_planned_qty := pa_fin_plan_utils.Get_Approved_Budget_Ver_Qty(
                   p_project_id  => p_project_id,
                   p_version_code => 'CURRENT_BASELINED_VERSION',
                   p_quantity_type =>  'PLANNED',
                   p_ci_id         => NULL );

   BEGIN
       SELECT Project_Currency_Code, NVL(Baseline_Funding_Flag,'N')
       INTO
              x_project_currency_code,
              x_baseline_funding_flag
       FROM
       Pa_Projects_All WHERE Project_Id = p_project_id;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_baseline_funding_flag := 'N';
   END;

   x_ci_type_class_code := Pa_Control_Items_Utils.GetCiTypeClassCode(p_ci_id);

   SELECT COUNT(*) INTO x_no_of_ci_plan_versions FROM pa_budget_Versions
   WHERE project_id = p_project_id AND
         nvl(ci_id,-1) = p_ci_id;

   SELECT COUNT(*) INTO l_no_of_app_plan_types FROM Pa_Proj_Fp_Options
   WHERE
   Project_Id = p_project_id AND
   Fin_Plan_Option_Level_Code = 'PLAN_TYPE' AND
   ( NVL(Approved_Cost_Plan_Type_Flag ,'N') = 'Y' OR
     NVL(Approved_Rev_Plan_Type_Flag  ,'N') = 'Y' ) ;
   IF l_no_of_app_plan_types = 1 THEN
      SELECT Fin_Plan_Preference_Code,
             Report_Labor_Hrs_From_Code,
             Fin_Plan_Type_Id
      INTO
             x_fp_pref_code,
             x_report_labor_hours_code,
             l_tmp_fin_plan_type_id
      FROM   Pa_Proj_Fp_Options WHERE
             Project_Id = p_project_id AND
             Fin_Plan_Option_Level_Code = 'PLAN_TYPE' AND
             ( NVL(Approved_Cost_Plan_Type_Flag ,'N') = 'Y' OR
               NVL(Approved_Rev_Plan_Type_Flag  ,'N') = 'Y');

	/* EnC changes start  commented as it is returing wrong pref code
	 -- the following query is for rendering the direct cost region.bug#8395873
 	 select --typ.cost_col_flag,
 	        --typ.rev_col_flag,
 	        --typ.DIR_COST_REG_FLAG,
 	       -- typ.SUPP_COST_REG_FLAG,
 	        decode(typ.DIR_REG_REV_COL_FLAG,'N','COST_ONLY','COST_AND_REV_SAME')
 	       INTO
 	         x_fp_pref_code
 	 FROM  pa_ci_types_b typ,pa_control_items ci
 	 WHERE  ci.ci_type_id = typ.ci_type_id
 	 and    ci.Project_Id = p_project_id
 	 and    ci.ci_id = p_ci_id
 	 and    typ.impact_budget_type_code in('DIRECT_COST_ENTRY');

          EnC changes end */

      IF x_fp_pref_code =  'COST_ONLY' THEN
         x_fin_plan_type_id_cost := l_tmp_fin_plan_type_id;
         x_baseline_funding_flag := 'N';
      ELSIF x_fp_pref_code = 'REVENUE_ONLY' THEN
         x_fin_plan_type_id_rev := l_tmp_fin_plan_type_id;
      ELSIF x_fp_pref_code = 'COST_AND_REV_SAME' THEN
         x_fin_plan_type_id_all := l_tmp_fin_plan_type_id;
      ELSIF x_fp_pref_code = 'COST_AND_REV_SEP' THEN
         x_fin_plan_type_id_all := l_tmp_fin_plan_type_id;
      END IF;
      x_fp_type_id_margin_code := l_tmp_fin_plan_type_id;

      /* Bug 3734840- Getting the margin_derived from code from the cost CI version
       * if it is already created or getting it from the plan type
       */
      l_impact_type := is_impact_exists(p_ci_id);
      x_margin_derived_from_code := 'B'; /* Defaulting */

      IF l_impact_type IN ('COST','BOTH') THEN
            /* Bug 3755860- Handled np_data_found
           */
          BEGIN
                  SELECT    Nvl(fpo.margin_derived_from_code, 'B'),
                            bv.plan_processing_code,
                            bv.request_id
                  INTO      x_margin_derived_from_code,
                            x_ci_ver_plan_prc_code,
                            x_request_id
                  FROM      pa_proj_fp_options fpo,
                            pa_budget_versions bv
                  WHERE     bv.ci_id = p_ci_id
                  AND       bv.version_type in ('COST','ALL')
                  AND       fpo.fin_plan_version_id = bv.budget_version_id
                  AND       bv.project_id = p_project_id;

          EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                   x_margin_derived_from_code := 'B';
          END;

      -- putting the following select the plan_processing_code and request_id
      -- only for the CI version with revenue impact
      ELSIF l_impact_type = 'REVENUE' THEN
          SELECT    bv.plan_processing_code,
                    bv.request_id
          INTO      x_ci_ver_plan_prc_code,
                    x_request_id
          FROM      pa_budget_versions bv
          WHERE     bv.ci_id = p_ci_id
          AND       bv.version_type = 'REVENUE'
          AND       bv.project_id = p_project_id;
      ELSE
            BEGIN
                 SELECT    Nvl(fpo.margin_derived_from_code, 'B'),
                           bv.plan_processing_code,
                           bv.request_id
                 INTO      x_margin_derived_from_code,
                           x_ci_ver_plan_prc_code,
                           x_request_id
                 FROM      pa_proj_fp_options fpo,
                           pa_budget_versions bv
                 WHERE     fpo.project_id = p_project_id
                 AND       bv.current_working_flag = 'Y'
                 AND       fpo.fin_plan_version_id = bv.budget_version_id
                 AND       bv.approved_cost_plan_type_flag = 'Y';

          EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                   x_margin_derived_from_code := 'B';
          END;
      END IF;

   ELSIF l_no_of_app_plan_types = 2 THEN

      /* Bug 3734840- Getting the margin_derived from code from the cost CI version
       * if it is already created or getting it from the plan type
       */
      l_impact_type := is_impact_exists(p_ci_id);
      x_margin_derived_from_code := 'B'; /* Defaulting */

      IF l_impact_type IN ('COST','BOTH') THEN
            BEGIN
                  SELECT    Nvl(fpo.margin_derived_from_code, 'B'),
                            bv.plan_processing_code,
                            bv.request_id
                  INTO      x_margin_derived_from_code,
                            x_ci_ver_plan_prc_code,
                            x_request_id
                  FROM      pa_proj_fp_options fpo,
                            pa_budget_versions bv
                  WHERE     bv.ci_id = p_ci_id
                  AND       bv.version_type in ('COST','ALL')
                  AND       fpo.fin_plan_version_id = bv.budget_version_id
                  AND       bv.project_id = p_project_id;

          EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   x_margin_derived_from_code := 'B';
          END;

     -- putting the following select the plan_processing_code and request_id
      -- only for the CI version with revenue impact
      ELSIF l_impact_type = 'REVENUE' THEN
          SELECT    bv.plan_processing_code,
                    bv.request_id
          INTO      x_ci_ver_plan_prc_code,
                    x_request_id
          FROM      pa_budget_versions bv
          WHERE     bv.ci_id = p_ci_id
          AND       bv.version_type = 'REVENUE'
          AND       bv.project_id = p_project_id;

      ELSE
           BEGIN
                 SELECT    Nvl(fpo.margin_derived_from_code, 'B'),
                           bv.plan_processing_code,
                           bv.request_id
                 INTO      x_margin_derived_from_code,
                           x_ci_ver_plan_prc_code,
                           x_request_id
                 FROM      pa_proj_fp_options fpo,
                           pa_budget_versions bv
                 WHERE     fpo.project_id = p_project_id
                 AND       bv.current_working_flag = 'Y'
                 AND       fpo.fin_plan_version_id = bv.budget_version_id
                 AND       bv.approved_cost_plan_type_flag = 'Y';

         EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   x_margin_derived_from_code := 'B';
         END;
      END IF;

      SELECT Fin_Plan_Preference_Code,
             Report_Labor_Hrs_From_Code,
             Fin_Plan_Type_Id
      INTO
             x_fp_pref_code,
             x_report_labor_hours_code,
             x_fin_plan_type_id_cost
      FROM Pa_Proj_Fp_Options WHERE
           Project_Id = p_project_id AND
           Fin_Plan_Option_Level_Code = 'PLAN_TYPE' AND
           NVL(Approved_Cost_Plan_Type_Flag ,'N') = 'Y';

      /* if the no of approved plan types is 2, then the pref code  is
         assumed to be COST_AND_REV_SEP, because two edit button should be shown */

      x_fp_pref_code := 'COST_AND_REV_SEP';


      SELECT Fin_Plan_Type_Id INTO x_fin_plan_type_id_rev
      FROM Pa_Proj_Fp_Options WHERE
           Project_Id = p_project_id AND
           Fin_Plan_Option_Level_Code = 'PLAN_TYPE' AND
           NVL(Approved_Rev_Plan_Type_Flag ,'N') = 'Y';

      x_fp_type_id_margin_code := x_fin_plan_type_id_cost;
   ELSIF l_no_of_app_plan_types = 0 THEN
      SELECT NVL(Allow_Rev_Budget_Entry_Flag ,'N'),
             NVL(Allow_Cost_Budget_Entry_Flag,'N') INTO
             l_rev_budget_flag,
             l_cost_budget_flag FROM
      Pa_Projects_All p, Pa_Project_Types_All pt WHERE
      p.project_id = p_project_id AND
      p.project_type = pt.project_type AND
      -- MOAC changes
      -- removing the nvl from org_id.
      -- NVL(p.org_id,-99) = NVL(pt.org_id,-99);
      p.org_id  = pt.org_id;
      IF l_rev_budget_flag = 'Y' AND l_cost_budget_flag = 'N' THEN
         x_fp_pref_code := 'REVENUE_ONLY';
      ELSIF l_rev_budget_flag = 'N' AND l_cost_budget_flag = 'Y' THEN
         x_fp_pref_code := 'COST_ONLY';
      ELSIF l_rev_budget_flag = 'Y' AND l_cost_budget_flag = 'Y' THEN
         x_fp_pref_code := 'COST_AND_REV_SEP';
      END IF;
   END IF;
   Pa_Debug.Reset_Err_Stack;
EXCEPTION
     WHEN OTHERS THEN
          FND_MSG_PUB.Add_Exc_Msg(
              p_pkg_name => 'PA_FP_CONTROL_ITEMS_UTILS.Get_Fin_Plan_Dtls'
             ,p_procedure_name => PA_DEBUG.G_Err_Stack);
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('Get_Fin_Plan_Dtls: ' || SQLERRM);
              END IF;
              pa_debug.reset_err_stack;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   RAISE;
END Get_Fin_Plan_Dtls;


FUNCTION Is_Financial_Planning_Allowed(p_project_id NUMBER)
   RETURN VARCHAR2 IS
   l_fp_allowed_flag VARCHAR2(1) := 'N' ;
BEGIN
   BEGIN
       SELECT 'Y' INTO l_fp_allowed_flag FROM
               Pa_Projects_All p,
               Pa_Project_Types_All pt
       WHERE
           p.Project_Id = p_project_id AND
           p.Project_Type = pt.Project_Type AND
           -- MOAC changes
           -- removing the nvl from org_id.
           -- NVL(p.org_id,-99) = NVL(pt.org_id,-99) AND
           p.org_id = pt.org_id AND
           ( NVL(pt.ALLOW_COST_BUDGET_ENTRY_FLAG,'N') = 'Y' OR
             NVL(pt.ALLOW_REV_BUDGET_ENTRY_FLAG,'N') = 'Y'      );
       RETURN l_fp_allowed_flag;
   EXCEPTION
   WHEN OTHERS THEN
      l_fp_allowed_flag := 'N';
      RETURN l_fp_allowed_flag;
   END;
END Is_Financial_Planning_Allowed;

PROCEDURE GET_FINPLAN_CI_TYPE_NAME
(
     p_ci_id                  IN NUMBER,
     x_ci_type_name           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_data                    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_return_status               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

)
IS
    l_debug_mode VARCHAR2(30);

BEGIN

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.init_err_stack('PA_FP_CONTROL_ITEMS_UTILS.get_finplan_ci_type_name');
     END IF;

     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');

     pa_debug.set_process('PLSQL','LOG',l_debug_mode);

     SELECT
          pacitl.name into x_ci_type_name
          FROM pa_control_items paci, pa_ci_types_tl pacitl
     WHERE
          paci.ci_id = p_ci_id
          and paci.ci_type_id = pacitl.ci_type_id
          and pacitl.language = userenv('lang');

        IF x_ci_type_name IS NULL THEN
                 pa_debug.g_err_stage := 'x_ci_type_name         [ IS NULL ]';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('GET_FINPLAN_CI_TYPE_NAME: ' || pa_debug.g_err_stage);
                 END IF;
        END IF;
        pa_debug.reset_err_stack;
EXCEPTION
     WHEN NO_DATA_FOUND THEN
                null;
     WHEN OTHERS THEN
          FND_MSG_PUB.add_exc_msg(
              p_pkg_name => 'PA_FP_CONTROL_ITEMS_UTILS.get_finplan_ci_type_name'
             ,p_procedure_name => PA_DEBUG.G_Err_Stack);
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('GET_FINPLAN_CI_TYPE_NAME: ' || SQLERRM);
              END IF;
              pa_debug.reset_err_stack;
END get_finplan_ci_type_name;

PROCEDURE get_fp_ci_agreement_dtls
(
     p_project_id             IN NUMBER,
     p_ci_id                  IN NUMBER,
     x_agreement_num               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_agreement_amount       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_agreement_currency_code     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_data                    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_return_status               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
  l_debug_mode varchar2(30) := 'Y';

BEGIN
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.init_err_stack('get_fp_ci_agreement_dtls: ' || 'PA_FP_CONTROL_ITEMS_UTILS.get_fp_ci_agreement_dtls');
     END IF;

     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');
     SELECT    pg.agreement_num,
          pg.amount,
          pg.agreement_currency_code
     INTO      x_agreement_num,
          x_agreement_amount,
          x_agreement_currency_code
          FROM  pa_agreements_all pg, pa_budget_versions bv
     WHERE
          bv.project_id = p_project_id
          and bv.ci_id = p_ci_id
          and bv.agreement_id = pg.agreement_id
          and bv.version_type in ('REVENUE','ALL'); -- Raja FP M Change Bug 3619687
          --and rownum < 2;

     IF x_agreement_num IS NULL THEN
          pa_debug.g_err_stage := 'x_agreement_num         [ IS NULL ]';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write_file('get_fp_ci_agreement_dtls: ' || pa_debug.g_err_stage);
          END IF;
     END IF;
     IF x_agreement_amount IS NULL THEN
          pa_debug.g_err_stage := 'x_agreement_amount         [ IS NULL ]';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write_file('get_fp_ci_agreement_dtls: ' || pa_debug.g_err_stage);
          END IF;
     END IF;
     IF x_agreement_currency_code IS NULL THEN
          pa_debug.g_err_stage := 'x_agreement_currency_code         [ IS NULL ]';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write_file('get_fp_ci_agreement_dtls: ' || pa_debug.g_err_stage);
          END IF;
     END IF;
     pa_debug.reset_err_stack;
EXCEPTION
     WHEN NO_DATA_FOUND THEN
                null;
     WHEN OTHERS THEN
          FND_MSG_PUB.add_exc_msg(
              p_pkg_name => 'PA_FP_CONTROL_ITEMS_UTILS.get_fp_ci_agreement_dtls'
             ,p_procedure_name => PA_DEBUG.G_Err_Stack);
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('get_fp_ci_agreement_dtls: ' || SQLERRM);
              END IF;
              pa_debug.reset_err_stack;
END get_fp_ci_agreement_dtls;

/*********************************************************************
  This procedure is called while merging change requests into
  change orders or while merging change documents into
  plan versions. This gives details about a version when a version
  and project id is passed to it
  ********************************************************************/

PROCEDURE FP_CI_GET_VERSION_DETAILS
(
     p_project_id        IN NUMBER,
     p_budget_version_id IN pa_budget_versions.budget_version_id%TYPE,
     x_fin_plan_pref_code     OUT NOCOPY pa_proj_fp_options.fin_plan_preference_code%TYPE, --File.Sql.39 bug 4440895
     x_multi_curr_flag   OUT NOCOPY pa_proj_fp_options.plan_in_multi_curr_flag%TYPE, --File.Sql.39 bug 4440895
     x_fin_plan_level_code    OUT NOCOPY pa_proj_fp_options.all_fin_plan_level_code%TYPE, --File.Sql.39 bug 4440895
     x_resource_list_id  OUT NOCOPY pa_proj_fp_options.all_resource_list_id%TYPE, --File.Sql.39 bug 4440895
     x_time_phased_code  OUT NOCOPY pa_proj_fp_options.all_time_phased_code%TYPE, --File.Sql.39 bug 4440895
     x_uncategorized_flag     OUT NOCOPY pa_resource_lists_all_bg.uncategorized_flag%TYPE, --File.Sql.39 bug 4440895
     x_group_res_type_id OUT NOCOPY pa_resource_lists_all_bg.group_resource_type_id%TYPE, --File.Sql.39 bug 4440895
     x_version_type      OUT NOCOPY pa_budget_versions.version_type%TYPE, --File.Sql.39 bug 4440895
     x_ci_id             OUT NOCOPY pa_budget_versions.ci_id%TYPE, --File.Sql.39 bug 4440895
     x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
  IS

-- Local Variable Declaration
      l_debug_mode            VARCHAR2(30);

BEGIN
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.init_err_stack('PAFPCIUB.FP_CI_GET_VERSION_DETAILS');
     END IF;
     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');
     pa_debug.set_process('PLSQL','LOG',l_debug_mode);
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     x_msg_count := 0;
     ----DBMS_OUTPUT.PUT_LINE('FP_CI_GET_VERSION_DETAILS - 1');
      --Get the column values for this budget version id and project id combination
      BEGIN
     SELECT
          po.fin_plan_preference_code,
          po.plan_in_multi_curr_flag,
          DECODE
               (po.fin_plan_preference_code,
               'COST_ONLY',po.cost_fin_plan_level_code,
               'REVENUE_ONLY',po.revenue_fin_plan_level_code,
               'COST_AND_REV_SAME',po.all_fin_plan_level_code,
               'COST_AND_REV_SEP',
               DECODE
                    (bv.version_type,
                    'COST',po.cost_fin_plan_level_code,
                    'REVENUE',po.revenue_fin_plan_level_code
                    )
               ),
          DECODE
               (po.fin_plan_preference_code,
               'COST_ONLY',po.cost_resource_list_id,
               'REVENUE_ONLY',po.revenue_resource_list_id,
               'COST_AND_REV_SAME',po.all_resource_list_id,
               'COST_AND_REV_SEP',
               DECODE
                    (bv.version_type,
                    'COST',po.cost_resource_list_id,
                    'REVENUE',po.revenue_resource_list_id
                    )
               ),
          DECODE
               (po.fin_plan_preference_code,
               'COST_ONLY',po.cost_time_phased_code,
               'REVENUE_ONLY',po.revenue_time_phased_code,
               'COST_AND_REV_SAME',po.all_time_phased_code,
               'COST_AND_REV_SEP',
               DECODE
                    (bv.version_type,
                    'COST',po.cost_time_phased_code,
                    'REVENUE',po.revenue_time_phased_code
                    )
               ),
          bv.version_type,
          bv.ci_id
       INTO
          x_fin_plan_pref_code,
          x_multi_curr_flag,
          x_fin_plan_level_code,
          x_resource_list_id,
          x_time_phased_code,
          x_version_type,
          x_ci_id
       FROM pa_budget_versions bv, pa_proj_fp_options po
       WHERE
          bv.budget_version_id = p_budget_version_id
          AND po.fin_plan_version_id = bv.budget_version_id
          AND po.project_id = p_project_id;

     EXCEPTION
          WHEN NO_DATA_FOUND THEN
              PA_UTILS.ADD_MESSAGE
               ( p_app_short_name => 'PA',
                 p_msg_name       => 'PA_FP_CI_NO_VERSION_DATA_FOUND');
              ----DBMS_OUTPUT.PUT_LINE('FP_CI_GET_VERSION_DETAILS - 2***');
              x_return_status := FND_API.G_RET_STS_ERROR;
     END;
          -- Get the resource list name to check if the
          -- budget version is planned with resource or
          -- without resource

     SELECT
          NVL(pr.uncategorized_flag,'N'),
          NVL(pr.group_resource_type_id,0)
     INTO
          x_uncategorized_flag,
          x_group_res_type_id
     FROM pa_resource_lists_all_bg pr
     WHERE pr.resource_list_id = x_resource_list_id;

EXCEPTION
     WHEN OTHERS THEN
         FND_MSG_PUB.add_exc_msg
                  ( p_pkg_name       => 'Pa_Fp_Control_Items_Utils.' ||
                   'FP_CI_GET_VERSION_DETAILS'
                   ,p_procedure_name => PA_DEBUG.G_Err_Stack);
         ----DBMS_OUTPUT.PUT_LINE('FP_CI_GET_VERSION_DETAILS - 3');
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.g_err_stage := 'Unexpected error in FP_CI_GET_VERSION_DETAILS';
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
            END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         PA_DEBUG.Reset_Curr_Function;
         RAISE;
END FP_CI_GET_VERSION_DETAILS;
-- end of FP_CI_GET_VERSION_DETAILS

/*********************************************************************
  This API will be called when a change request or a change
  order has been created by the user and the user wants
  to implement or include the change requests into a change
  order or change orders into a plan version. The API is supposed
  to check different conditions and determine if the merge is
  possible between the two plan versions of not

--


  ********************************************************************/
PROCEDURE FP_CI_CHECK_MERGE_POSSIBLE
(
  p_project_id                IN  NUMBER,
  p_source_fp_version_id_tbl  IN  SYSTEM.pa_num_tbl_type,
  p_target_fp_version_id      IN  NUMBER,
  p_calling_mode              IN  VARCHAR2,
  x_merge_possible_code_tbl   OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type,
  x_return_status             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )
  IS
-- Local Variable Declaration
      l_budget_version_id     pa_budget_versions.budget_version_id%TYPE;

      --Defining Local variables for source version
      l_s_version_id          pa_budget_versions.budget_version_id%TYPE;
      l_s_fin_plan_pref_code  pa_proj_fp_options. fin_plan_preference_code%TYPE;
      l_s_multi_curr_flag     pa_proj_fp_options. plan_in_multi_curr_flag%TYPE;
      l_s_time_phased_code    pa_proj_fp_options. all_time_phased_code%TYPE;
      l_s_resource_list_id    pa_proj_fp_options.all_resource_list_id%TYPE;
      l_s_fin_plan_level_code pa_proj_fp_options.all_fin_plan_level_code%TYPE;
      l_s_uncategorized_flag  pa_resource_lists_all_bg.uncategorized_flag %TYPE;
      l_s_group_res_type_id   pa_resource_lists_all_bg.group_resource_type_id%TYPE;
      l_s_version_type        pa_budget_versions.version_type%TYPE;
      l_s_ci_id               pa_budget_versions.ci_id%TYPE;

      --Defining Local variables for target version
      l_t_version_id          pa_budget_versions.budget_version_id%TYPE;
      l_t_fin_plan_pref_code  pa_proj_fp_options. fin_plan_preference_code%TYPE;
      l_t_multi_curr_flag     pa_proj_fp_options. plan_in_multi_curr_flag%TYPE;
      l_t_time_phased_code    pa_proj_fp_options. all_time_phased_code%TYPE;
      l_t_resource_list_id    pa_proj_fp_options.all_resource_list_id%TYPE;
      l_t_fin_plan_level_code pa_proj_fp_options.all_fin_plan_level_code%TYPE;
      l_t_uncategorized_flag  pa_resource_lists_all_bg.uncategorized_flag %TYPE;
      l_t_group_res_type_id   pa_resource_lists_all_bg.group_resource_type_id%TYPE;
      l_t_version_type        pa_budget_versions.version_type%TYPE;
      l_t_ci_id               pa_budget_versions.ci_id%TYPE;

      --Defining Local PL/SQL variables for source version
      l_s_version_id_tbl          PA_PLSQL_DATATYPES.IdTabTyp;
      l_s_fin_plan_pref_code_tbl  PA_PLSQL_DATATYPES.Char30TabTyp;
      l_s_multi_curr_flag_tbl     PA_PLSQL_DATATYPES.Char1TabTyp;
      l_s_time_phased_code_tbl    PA_PLSQL_DATATYPES.Char30TabTyp;
      l_s_resource_list_id_tbl    PA_PLSQL_DATATYPES.IdTabTyp;
      l_s_fin_plan_level_code_tbl PA_PLSQL_DATATYPES.Char30TabTyp;
      l_s_uncategorized_flag_tbl  PA_PLSQL_DATATYPES.Char1TabTyp;
      l_s_group_res_type_id_tbl   PA_PLSQL_DATATYPES.IdTabTyp;
      l_s_version_type_tbl        PA_PLSQL_DATATYPES.Char30TabTyp;
      l_s_ci_id_tbl                 PA_PLSQL_DATATYPES.IdTabTyp;

      --Defining Local PL/SQL variables for target version
      l_t_version_id_tbl PA_PLSQL_DATATYPES.IdTabTyp;
      l_t_fin_plan_pref_code_tbl PA_PLSQL_DATATYPES.Char30TabTyp;
      l_t_multi_curr_flag_tbl PA_PLSQL_DATATYPES.Char1TabTyp;
      l_t_time_phased_code_tbl     PA_PLSQL_DATATYPES.Char30TabTyp;
      l_t_resource_list_id_tbl     PA_PLSQL_DATATYPES.IdTabTyp;
      l_t_fin_plan_level_code_tbl PA_PLSQL_DATATYPES.Char30TabTyp;
      l_t_uncategorized_flag_tbl PA_PLSQL_DATATYPES.Char1TabTyp;
      l_t_version_type_tbl    PA_PLSQL_DATATYPES.Char30TabTyp;
      l_t_group_res_type_id_tbl    PA_PLSQL_DATATYPES.IdTabTyp;
      l_t_ci_id_tbl PA_PLSQL_DATATYPES.IdTabTyp;
      l_s_agreement_id        pa_budget_versions.agreement_id%TYPE;
      l_t_agreement_id        pa_budget_versions.agreement_id%TYPE;
      --Other Local Variables
      l_merge_possible_code        VARCHAR2(1);
      l_raise_error_flag      VARCHAR2(1);
      l_debug_mode       VARCHAR2(30);
      l_token_v_type          VARCHAR2(30);
      l_res_resgr_mismatch_flag VARCHAR2(1) := 'N';
      l_chg_doc_token varchar2(250);
      l_ci_number pa_control_items.ci_number%type;
      l_ci_type_name pa_ci_types_tl.short_name%type;
      l_count number;
      l_token_ci_id pa_control_items.ci_id%type;
      l_tsk_plan_level_mismatch VARCHAR2(1) := 'N';
      l_s_task_id_tbl           PA_PLSQL_DATATYPES.IdTabTyp;
      l_t_task_id_tbl           PA_PLSQL_DATATYPES.IdTabTyp;
      l_s_fin_plan_level_tbl    PA_PLSQL_DATATYPES.Char30TabTyp;
      l_t_fin_plan_level_tbl    PA_PLSQL_DATATYPES.Char30TabTyp;
      l_targ_pt_name            pa_fin_plan_types_tl.name%TYPE;
      l_src_ci_number           pa_control_items.ci_number%TYPE;
      l_module_name             varchar2(30) := 'check is possible';

      -- Bug 5845142
      l_s_app_rev_flag          pa_budget_versions.approved_rev_plan_type_flag%TYPE;
      l_t_app_rev_flag          pa_budget_versions.approved_rev_plan_type_flag%TYPE;

BEGIN
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.init_err_stack('PAFPCIUB.FP_CI_CHECK_MERGE_POSSIBLE');
     END IF;
     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');
     pa_debug.set_process('PLSQL','LOG',l_debug_mode);
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     x_msg_count := 0;
     ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 1');
-- The API is sure to have ONE target version id for merge check

         IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='p_target_fp_version_id =  ' || p_target_fp_version_id;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

             pa_debug.g_err_stage:='p_calling_mode =  ' || p_calling_mode;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
         END IF;

         IF p_source_fp_version_id_tbl.COUNT > 0 THEN
             FOR i IN p_source_fp_version_id_tbl.FIRST .. p_source_fp_version_id_tbl.LAST LOOP
                 IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:='p_source_fp_version_id_tbl =  ' || p_source_fp_version_id_tbl(i);
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
             END LOOP;
         END IF;

l_t_version_id := p_target_fp_version_id;
-- Get all column values for target version id in a call to the get version details API
-- Get the parameters for the TARGET version id.
     ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 2');
     FP_CI_GET_VERSION_DETAILS
     (
     p_project_id        => p_project_id,
     p_budget_version_id => l_t_version_id,
     x_fin_plan_pref_code     => l_t_fin_plan_pref_code,
     x_multi_curr_flag   => l_t_multi_curr_flag,
     x_fin_plan_level_code    => l_t_fin_plan_level_code,
     x_resource_list_id  => l_t_resource_list_id,
     x_time_phased_code  => l_t_time_phased_code,
     x_uncategorized_flag     => l_t_uncategorized_flag,
     x_group_res_type_id => l_t_group_res_type_id,
     x_version_type      => l_t_version_type,
     x_ci_id             => l_t_ci_id,
     x_return_status          => x_return_status,
     x_msg_count              => x_msg_count,
     x_msg_data               => x_msg_data
     )  ;

     --Get the plan type name when the context is 'IMPLEMENT'
     IF p_calling_mode='IMPLEMENT' THEN

        SELECT name
        INTO   l_targ_pt_name
        FROM   pa_fin_plan_types_vl fin,
               pa_budget_versions pbv
        WHERE  fin.fin_plan_type_id = pbv.fin_plan_type_id
        AND    pbv.budget_version_id= l_t_version_id;

    END IF;

     x_merge_possible_code_tbl:=SYSTEM.pa_varchar2_1_tbl_type();
       ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 3');
FOR i in p_source_fp_version_id_tbl.FIRST.. p_source_fp_version_id_tbl.LAST
LOOP
          l_merge_possible_code   := 'Y';
          l_raise_error_flag  := 'N';
          ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 4');
          l_s_version_id := p_source_fp_version_id_tbl (i);
          ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 5');
          --Get the values for the SOURCE version
          FP_CI_GET_VERSION_DETAILS
          (
          p_project_id        => p_project_id,
          p_budget_version_id => l_s_version_id,
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
          ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 6');

          IF p_calling_mode='INCLUDE' THEN

              SELECT ci_number
              INTO   l_src_ci_number
              FROM   pa_control_items
              WHERE  ci_id=l_s_ci_id;

          END IF;


IF (p_calling_mode = 'INCLUDE_CR_TO_CO') THEN
     BEGIN
     IF(l_s_version_type = 'COST') THEN
               l_token_v_type := l_s_version_type;
     ELSIF (l_s_version_type = 'REVENUE') THEN
          l_token_v_type := l_s_version_type;
     ELSE
          l_token_v_type := '';
     END IF;
     -- Time phased code check
          IF(l_s_time_phased_code = 'P') THEN
               ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 7');
               --Check for the Target to be the same
               IF (l_t_time_phased_code = 'G') THEN                   ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - **8');
                    ----DBMS_OUTPUT.PUT_LINE('Time phased Code is Different');
                    --MERGE NOT POSSIBLE
                    l_merge_possible_code   := 'E';
                    -- Add message in PA_UTILS
                    PA_UTILS.ADD_MESSAGE
                    ( p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_CI_C_TIME_PHASE_DIFF'
                    );
                      /*p_token1         => 'CI_SOURCE',
                               p_value1         => l_s_ci_id,
                               p_token2         => 'CI_TARGET',
                               p_value2         => l_t_ci_id
                             );*/
                    -- RAISE EXCEPTION RAISE_MERGE_ERROR
                    --raise RAISE_MERGE_ERROR;
                    l_raise_error_flag  := 'Y';
                    -- PROCESS THE NEXT ELEMENT IN THE LOOP
               END IF;
          ELSIF (l_s_time_phased_code = 'G') THEN
               ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 9***');
               ----DBMS_OUTPUT.PUT_LINE('Time phased Code is Different');
               --Check for the Target to be the same
               IF (l_t_time_phased_code = 'P') THEN
                    -- MERGE NOT POSSIBLE
                    l_merge_possible_code   := 'E';
                    -- Add message in PA_UTILS
                    PA_UTILS.ADD_MESSAGE
                    ( p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_CI_C_TIME_PHASE_DIFF'
                    );
                      /*p_token1         => 'CI_SOURCE',
                         p_value1         => l_s_ci_id,
                         p_token2         => 'CI_TARGET',
                               p_value2         => l_t_ci_id
                    );*/
                    -- RAISE EXCEPTION RAISE_MERGE_ERROR
                    --raise RAISE_MERGE_ERROR;
                    l_raise_error_flag  := 'Y';
                    -- PROCESS THE NEXT ELEMENT IN THE LOOP
               END IF;

          END IF;

          --Check for the version type
          IF (
               (
                 (l_s_version_type = 'COST') AND
                 (l_t_version_type = 'REVENUE')
               )
               OR
               (
               (l_s_version_type = 'REVENUE') AND
               (l_t_version_type = 'COST')
               )
             ) THEN
               ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 25');
               -- MERGE NOT POSSIBLE
               l_merge_possible_code   := 'E';
               -- Add message in PA_UTILS
               PA_UTILS.ADD_MESSAGE
               ( p_app_short_name => 'PA',
                 p_msg_name       => 'PA_FP_CI_C_INV_VER_TYPE_MATCH'
               );
               /*p_token1         => 'CI_SOURCE',
                 p_value1         => l_s_ci_id,
                 p_token2         => 'CI_TARGET',
                 p_value2         => l_t_ci_id
               );*/
               -- RAISE EXCEPTION RAISE_MERGE_ERROR
               --raise RAISE_MERGE_ERROR;
               l_raise_error_flag  := 'Y';
               -- PROCESS THE NEXT ELEMENT IN THE LOOP
          END IF;

          --Check for the preference code and version type
          IF (l_s_fin_plan_pref_code = 'COST_ONLY') THEN
               ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 15');
               IF (l_t_fin_plan_pref_code = 'REVENUE_ONLY') THEN
                    ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 16****');
                    -- MERGE NOT POSSIBLE
                    l_merge_possible_code   := 'E';
                    -- Add message in PA_UTILS
                    PA_UTILS.ADD_MESSAGE
                    ( p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_CI_C_INV_PREF_CODE_MATCH'
                    );
                      /*p_token1         => 'CI_SOURCE',
                      p_value1         => l_s_ci_id,
                      p_token2         => 'CI_TARGET',
                               p_value2         => l_t_ci_id
                    );*/
                    -- RAISE EXCEPTION RAISE_MERGE_ERROR
                    --raise RAISE_MERGE_ERROR;
                    l_raise_error_flag  := 'Y';
                         -- PROCESS THE NEXT ELEMENT IN THE LOOP
               END IF;
          END IF;

          IF (l_s_fin_plan_pref_code = 'REVENUE_ONLY') THEN
               ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 17*****');
               IF (l_t_fin_plan_pref_code = 'COST_ONLY') THEN
                    ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 18');
                    -- MERGE NOT POSSIBLE
                    l_merge_possible_code   := 'E';
                    -- Add message in PA_UTILS
                    PA_UTILS.ADD_MESSAGE
                    ( p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_CI_C_INV_PREF_CODE_MATCH'
                    );
                      /*p_token1         => 'CI_SOURCE',
                      p_value1         => l_s_ci_id,
                      p_token2         => 'CI_TARGET',
                               p_value2         => l_t_ci_id
                    );*/
                    -- RAISE EXCEPTION RAISE_MERGE_ERROR
                    --raise RAISE_MERGE_ERROR;
                    l_raise_error_flag  := 'Y';
                         -- PROCESS THE NEXT ELEMENT IN THE LOOP
               END IF;
          END IF;

          -- Special Case Check for preference code when target is planned
          -- separately for cost and revenue
          IF (l_t_fin_plan_pref_code = 'COST_AND_REV_SEP') THEN
               ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 19');
               IF (l_s_fin_plan_pref_code = 'REVENUE_ONLY') THEN
                    ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 20');
                    IF (l_t_version_type = 'COST') THEN
                         ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 21***');
                         -- MERGE NOT POSSIBLE
                         l_merge_possible_code   := 'E';
                         -- Add message in PA_UTILS
                         PA_UTILS.ADD_MESSAGE
                         ( p_app_short_name => 'PA',
                           p_msg_name       => 'PA_FP_CI_C_INV_PREF_CODE_MATCH'
                         );
                           /*p_token1         => 'CI_SOURCE',
                           p_value1         => l_s_ci_id,
                           p_token2         => 'CI_TARGET',
                                     p_value2         => l_t_ci_id
                         );*/
                         -- RAISE EXCEPTION RAISE_MERGE_ERROR
                         --raise RAISE_MERGE_ERROR;
                         l_raise_error_flag  := 'Y';
                              -- PROCESS THE NEXT ELEMENT IN THE LOOP
                    END IF;
               ELSIF (l_s_fin_plan_pref_code = 'COST_ONLY') THEN
                    ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 22');
                    IF (l_t_version_type = 'REVENUE') THEN
                         ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 23***');
                         -- MERGE NOT POSSIBLE
                         l_merge_possible_code   := 'E';
                         -- Add message in PA_UTILS
                         PA_UTILS.ADD_MESSAGE
                         ( p_app_short_name => 'PA',
                           p_msg_name       => 'PA_FP_CI_C_INV_PREF_CODE_MATCH'
                         );
                           /*p_token1         => 'CI_SOURCE',
                           p_value1         => l_s_ci_id,
                           p_token2         => 'CI_TARGET',
                                     p_value2         => l_t_ci_id
                         );*/
                         -- RAISE EXCEPTION RAISE_MERGE_ERROR
                         --raise RAISE_MERGE_ERROR;
                         l_raise_error_flag  := 'Y';
                              -- PROCESS THE NEXT ELEMENT IN THE LOOP
                    END IF;
               ELSIF (l_s_fin_plan_pref_code = 'COST_AND_REV_SEP') THEN
                    ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 24****');
                    IF (
                         (
                           (l_s_version_type = 'COST') AND
                           (l_t_version_type = 'REVENUE')
                         )
                         OR
                         (
                            (l_s_version_type = 'REVENUE') AND
                            (l_t_version_type = 'COST')
                         )
                       ) THEN
                         ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 25');
                         -- MERGE NOT POSSIBLE
                         l_merge_possible_code   := 'E';
                         -- Add message in PA_UTILS
                         PA_UTILS.ADD_MESSAGE
                         ( p_app_short_name => 'PA',
                           p_msg_name       => 'PA_FP_CI_C_INV_VER_TYPE_MATCH'
                         );
                           /*p_token1         => 'CI_SOURCE',
                           p_value1         => l_s_ci_id,
                           p_token2         => 'CI_TARGET',
                                     p_value2         => l_t_ci_id
                         );*/
                         -- RAISE EXCEPTION RAISE_MERGE_ERROR
                         --raise RAISE_MERGE_ERROR;
                         l_raise_error_flag  := 'Y';
                              -- PROCESS THE NEXT ELEMENT IN THE LOOP
                       END IF;
               END IF;
          END IF;

          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Source version type: ' || l_s_version_type;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

             pa_debug.g_err_stage:='Target version type: ' || l_t_version_type;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
          END IF;

          --Added agreement check for P2 bug 2724156
          IF (l_s_version_type IN ('REVENUE','ALL') AND l_t_version_type IN ('REVENUE','ALL')) THEN
               --Bug 5845142
               SELECT NVL(agreement_id,-99), NVL(approved_rev_plan_type_flag,'N')
               INTO l_s_agreement_id,l_s_app_rev_flag
               FROM pa_budget_versions
               where budget_version_id = l_s_version_id;

               --Bug 5845142
               SELECT NVL(agreement_id,-100), NVL(approved_rev_plan_type_flag,'N')
               INTO l_t_agreement_id,l_t_app_rev_flag
               FROM pa_budget_versions
               where budget_version_id = l_t_version_id;

               IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:='Source Agr: ' || l_s_agreement_id;
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                     pa_debug.g_err_stage:='Target Agr:  ' || l_t_agreement_id;
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
               END IF;

               --Bug 5845142. Since its possible for the cost impact to be of ALL version type throw the
               --error only for revenue impacts
               IF (l_s_agreement_id <> l_t_agreement_id) AND
                  (l_s_app_rev_flag ='Y' AND l_t_app_rev_flag='Y') THEN
                    --MERGE NOT POSSIBLE
                    l_merge_possible_code   := 'E';
                    -- Add message in PA_UTILS
                    PA_UTILS.ADD_MESSAGE
                    ( p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_CI_C_INV_AGR_ID_MATCH'
                    );
                    -- RAISE EXCEPTION RAISE_MERGE_ERROR
                    --raise RAISE_MERGE_ERROR;
                    l_raise_error_flag  := 'Y';
                    -- PROCESS THE NEXT ELEMENT IN THE LOOP
               END IF;
          END IF;

          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Error: ' || l_raise_error_flag;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
          END IF;

          --end of agreement check for P2 bug 2724156
          IF (l_raise_error_flag   = 'Y') THEN
               raise RAISE_MERGE_ERROR;
          END IF;

          ----DBMS_OUTPUT.PUT_LINE('IN CHECK MERGEEEEEEEEEEEEEEEE');
          ----DBMS_OUTPUT.PUT_LINE('l_s_version_id :' || l_s_version_id);
          ----DBMS_OUTPUT.PUT_LINE('l_t_version_id :' || l_t_version_id);
          ----DBMS_OUTPUT.PUT_LINE('l_s_fin_plan_pref_code :' || l_s_fin_plan_pref_code);
          ----DBMS_OUTPUT.PUT_LINE('l_t_fin_plan_pref_code :' || l_t_fin_plan_pref_code);
          ----DBMS_OUTPUT.PUT_LINE('l_s_multi_curr_flag :' || l_s_multi_curr_flag);
          ----DBMS_OUTPUT.PUT_LINE('l_t_multi_curr_flag :' || l_t_multi_curr_flag);
          ----DBMS_OUTPUT.PUT_LINE('l_s_fin_plan_level_code :' || l_s_fin_plan_level_code);
          ----DBMS_OUTPUT.PUT_LINE('l_t_fin_plan_level_code :' || l_t_fin_plan_level_code);
          ----DBMS_OUTPUT.PUT_LINE('l_s_uncategorized_flag :' || l_s_uncategorized_flag);
          ----DBMS_OUTPUT.PUT_LINE('l_t_uncategorized_flag :' || l_t_uncategorized_flag);
          ----DBMS_OUTPUT.PUT_LINE('l_s_version_type :' || l_s_version_type);
          ----DBMS_OUTPUT.PUT_LINE('l_t_version_type :' || l_t_version_type);
          x_merge_possible_code_tbl.extend(1);
          x_merge_possible_code_tbl (i) := l_merge_possible_code;
          ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 34');
          EXCEPTION
          WHEN RAISE_MERGE_ERROR THEN
               ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 35');
               x_merge_possible_code_tbl.extend(1);
               x_merge_possible_code_tbl (i) := l_merge_possible_code;
               x_return_status               := FND_API.G_RET_STS_ERROR;
               ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 36****');
        select ci_id into l_token_ci_id from
        pa_budget_versions where
        budget_version_id = l_s_version_id;

        l_chg_doc_token := null;
        begin
           select ci.ci_number,cit.short_name into
           l_ci_number,l_ci_type_name from
           pa_control_items ci,
           pa_ci_types_tl cit
           where ci.ci_id = l_token_ci_id and
                 cit.ci_type_id = ci.ci_type_id and
                 cit.language = userenv('LANG');
        l_chg_doc_token := l_ci_type_name;
           if l_ci_number is not null then
              l_chg_doc_token := l_chg_doc_token ||'('||l_ci_number ||')';
           end if;
        IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Token: ' || l_chg_doc_token;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;
        exception
        when no_data_found then
           l_count := 0;
           /* dummy stmt */
        end;

               PA_UTILS.ADD_MESSAGE
               ( p_app_short_name => 'PA',
                 p_msg_name       => 'PA_FP_CI_NO_COPY',
                 p_token1         => 'CI_ID',
                 p_value1         => l_chg_doc_token,
                 p_token2         => 'CI_VERSION',
                 p_value2         => l_token_v_type
               );
        END;

ELSE
     BEGIN
        -- Time phased code check
     IF(l_s_time_phased_code = 'P') THEN
          ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 7');
          --Check for the Target to be the same
          IF (l_t_time_phased_code = 'G') THEN
               ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - **8');
               ----DBMS_OUTPUT.PUT_LINE('Time phased Code is Different');
               --MERGE NOT POSSIBLE
               l_merge_possible_code   := 'E';
               -- Add message in PA_UTILS
               IF (p_calling_mode = 'INCLUDE') THEN
                    PA_UTILS.ADD_MESSAGE
                    ( p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_CI_TIME_PHASE_DIFF',
                      p_token1         => 'CHG_DOC',
                      p_value1         => l_src_ci_number
                    );
               ELSIF (p_calling_mode = 'IMPLEMENT') THEN
                    PA_UTILS.ADD_MESSAGE
                    ( p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_CIM_TIME_PHASE_DIFF',
                      p_token1         => 'PLAN_TYPE',
                      p_value1         => l_targ_pt_name

                    );
                        ELSIF (p_calling_mode = 'SUBMIT') THEN
                                PA_UTILS.ADD_MESSAGE
                                ( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_FP_CIS_TIME_PHASE_DIFF'
                                );

               END IF;
                 /*p_token1         => 'CI_SOURCE',
                          p_value1         => l_s_ci_id,
                          p_token2         => 'CI_TARGET',
                          p_value2         => l_t_ci_id
                        );*/
               -- RAISE EXCEPTION RAISE_MERGE_ERROR
               --raise RAISE_MERGE_ERROR;
               l_raise_error_flag  := 'Y';
               -- PROCESS THE NEXT ELEMENT IN THE LOOP
          END IF;
     ELSIF (l_s_time_phased_code = 'G') THEN
          ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 9***');
          ----DBMS_OUTPUT.PUT_LINE('Time phased Code is Different');
          --Check for the Target to be the same
          IF (l_t_time_phased_code = 'P') THEN
               -- MERGE NOT POSSIBLE
               l_merge_possible_code   := 'E';
               -- Add message in PA_UTILS
               IF (p_calling_mode = 'INCLUDE') THEN
                    PA_UTILS.ADD_MESSAGE
                    ( p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_CI_TIME_PHASE_DIFF',
                      p_token1         => 'CHG_DOC',
                      p_value1         => l_src_ci_number
                   );
               ELSIF (p_calling_mode = 'IMPLEMENT') THEN
                    PA_UTILS.ADD_MESSAGE
                    ( p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_CIM_TIME_PHASE_DIFF',
                      p_token1         => 'PLAN_TYPE',
                      p_value1         => l_targ_pt_name

                    );
               ELSIF (p_calling_mode = 'SUBMIT') THEN
                                PA_UTILS.ADD_MESSAGE
                                ( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_FP_CIS_TIME_PHASE_DIFF'
                                );

               END IF;
                 /*p_token1         => 'CI_SOURCE',
                    p_value1         => l_s_ci_id,
                    p_token2         => 'CI_TARGET',
                          p_value2         => l_t_ci_id
               );*/
               -- RAISE EXCEPTION RAISE_MERGE_ERROR
               --raise RAISE_MERGE_ERROR;
               l_raise_error_flag  := 'Y';
               -- PROCESS THE NEXT ELEMENT IN THE LOOP
          END IF;

     END IF;


     --Check for the version type
     IF (
          (
            (l_s_version_type = 'COST') AND
            (l_t_version_type = 'REVENUE')
          )
          OR
          (
          (l_s_version_type = 'REVENUE') AND
          (l_t_version_type = 'COST')
          )
        ) THEN
          ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 25');
          -- MERGE NOT POSSIBLE
          l_merge_possible_code   := 'E';
          -- Add message in PA_UTILS
          IF (p_calling_mode = 'INCLUDE') THEN
               PA_UTILS.ADD_MESSAGE
               ( p_app_short_name => 'PA',
                 p_msg_name       => 'PA_FP_CI_INV_VER_TYPE_MATCH',
                 p_token1         => 'CHG_DOC',
                 p_value1         => l_src_ci_number
               );
          ELSIF (p_calling_mode = 'IMPLEMENT') THEN
               PA_UTILS.ADD_MESSAGE
               ( p_app_short_name => 'PA',
                 p_msg_name       => 'PA_FP_CIM_INV_VER_TYPE_MATCH',
                 p_token1         => 'PLAN_TYPE',
                 p_value1         => l_targ_pt_name

               );
                ELSIF (p_calling_mode = 'SUBMIT') THEN
                        PA_UTILS.ADD_MESSAGE
                        ( p_app_short_name => 'PA',
                          p_msg_name       => 'PA_FP_CIS_INV_VER_TYPE_MATCH'
                        );

          END IF;
          /*p_token1         => 'CI_SOURCE',
            p_value1         => l_s_ci_id,
            p_token2         => 'CI_TARGET',
            p_value2         => l_t_ci_id
          );*/
          -- RAISE EXCEPTION RAISE_MERGE_ERROR
          --raise RAISE_MERGE_ERROR;
          l_raise_error_flag  := 'Y';
          -- PROCESS THE NEXT ELEMENT IN THE LOOP
        END IF;

     --Check for the preference code and version type
     IF (l_s_fin_plan_pref_code = 'COST_ONLY') THEN
          ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 15');
          IF (l_t_fin_plan_pref_code = 'REVENUE_ONLY') THEN
               ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 16****');
               -- MERGE NOT POSSIBLE
               l_merge_possible_code   := 'E';
               -- Add message in PA_UTILS
               IF (p_calling_mode = 'INCLUDE') THEN
                    PA_UTILS.ADD_MESSAGE
                    ( p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_CI_INV_PREF_CODE_MATCH',
                      p_token1         => 'CHG_DOC',
                      p_value1         => l_src_ci_number
                    );
               ELSIF (p_calling_mode = 'IMPLEMENT') THEN
                    PA_UTILS.ADD_MESSAGE
                    ( p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_CIM_INV_PREF_CODE_MATCH',
                      p_token1         => 'PLAN_TYPE',
                      p_value1         => l_targ_pt_name

                    );
                        ELSIF (p_calling_mode = 'SUBMIT') THEN
                                PA_UTILS.ADD_MESSAGE
                                ( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_FP_CIS_INV_PREF_CODE_MATCH'
                                );

               END IF;
                /*p_token1         => 'CI_SOURCE',
                 p_value1         => l_s_ci_id,
                 p_token2         => 'CI_TARGET',
                          p_value2         => l_t_ci_id
               );*/
               -- RAISE EXCEPTION RAISE_MERGE_ERROR
               --raise RAISE_MERGE_ERROR;
               l_raise_error_flag  := 'Y';
                    -- PROCESS THE NEXT ELEMENT IN THE LOOP
          END IF;
     END IF;

     IF (l_s_fin_plan_pref_code = 'REVENUE_ONLY') THEN
          ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 17*****');
          IF (l_t_fin_plan_pref_code = 'COST_ONLY') THEN
               ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 18');
               -- MERGE NOT POSSIBLE
               l_merge_possible_code   := 'E';
               -- Add message in PA_UTILS
               IF (p_calling_mode = 'INCLUDE') THEN
                    PA_UTILS.ADD_MESSAGE
                    ( p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_CI_INV_PREF_CODE_MATCH',
                      p_token1         => 'CHG_DOC',
                      p_value1         => l_src_ci_number

                    );
               ELSIF (p_calling_mode = 'IMPLEMENT') THEN
                    PA_UTILS.ADD_MESSAGE
                    ( p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_CIM_INV_PREF_CODE_MATCH',
                      p_token1         => 'PLAN_TYPE',
                      p_value1         => l_targ_pt_name
                    );
                        ELSIF (p_calling_mode = 'SUBMIT') THEN
                                PA_UTILS.ADD_MESSAGE
                                ( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_FP_CIS_INV_PREF_CODE_MATCH'
                                );

               END IF;
                 /*p_token1         => 'CI_SOURCE',
                 p_value1         => l_s_ci_id,
                 p_token2         => 'CI_TARGET',
                          p_value2         => l_t_ci_id
               );*/
               -- RAISE EXCEPTION RAISE_MERGE_ERROR
               --raise RAISE_MERGE_ERROR;
               l_raise_error_flag  := 'Y';
                    -- PROCESS THE NEXT ELEMENT IN THE LOOP
          END IF;
     END IF;

     -- Special Case Check for preference code when target is planned
     -- separately for cost and revenue
     IF (l_t_fin_plan_pref_code = 'COST_AND_REV_SEP') THEN
          ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 19');
          IF (l_s_fin_plan_pref_code = 'REVENUE_ONLY') THEN
               ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 20');
               IF (l_t_version_type = 'COST') THEN
                    ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 21***');
                    -- MERGE NOT POSSIBLE
                    l_merge_possible_code   := 'E';
                    -- Add message in PA_UTILS
                    IF (p_calling_mode = 'INCLUDE') THEN
                         PA_UTILS.ADD_MESSAGE
                         ( p_app_short_name => 'PA',
                           p_msg_name       => 'PA_FP_CI_INV_PREF_CODE_MATCH',
                           p_token1         => 'CHG_DOC',
                           p_value1         => l_src_ci_number

                         );
                    ELSIF (p_calling_mode = 'IMPLEMENT') THEN
                         PA_UTILS.ADD_MESSAGE
                         ( p_app_short_name => 'PA',
                           p_msg_name       => 'PA_FP_CIM_INV_PREF_CODE_MATCH',
                           p_token1         => 'PLAN_TYPE',
                           p_value1         => l_targ_pt_name

                         );
                             ELSIF (p_calling_mode = 'SUBMIT') THEN
                                     PA_UTILS.ADD_MESSAGE
                                     ( p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_FP_CIS_INV_PREF_CODE_MATCH'
                                     );

                    END IF;
                      /*p_token1         => 'CI_SOURCE',
                      p_value1         => l_s_ci_id,
                      p_token2         => 'CI_TARGET',
                                p_value2         => l_t_ci_id
                    );*/
                    -- RAISE EXCEPTION RAISE_MERGE_ERROR
                    --raise RAISE_MERGE_ERROR;
                    l_raise_error_flag  := 'Y';
                         -- PROCESS THE NEXT ELEMENT IN THE LOOP
               END IF;
          ELSIF (l_s_fin_plan_pref_code = 'COST_ONLY') THEN
               ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 22');
               IF (l_t_version_type = 'REVENUE') THEN
                    ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 23***');
                    -- MERGE NOT POSSIBLE
                    l_merge_possible_code   := 'E';
                    -- Add message in PA_UTILS
                    IF (p_calling_mode = 'INCLUDE') THEN
                         PA_UTILS.ADD_MESSAGE
                         ( p_app_short_name => 'PA',
                           p_msg_name       => 'PA_FP_CI_INV_PREF_CODE_MATCH',
                           p_token1         => 'CHG_DOC',
                           p_value1         => l_src_ci_number

                         );
                    ELSIF (p_calling_mode = 'IMPLEMENT') THEN
                         PA_UTILS.ADD_MESSAGE
                         ( p_app_short_name => 'PA',
                           p_msg_name       => 'PA_FP_CIM_INV_PREF_CODE_MATCH',
                           p_token1         => 'PLAN_TYPE',
                           p_value1         => l_targ_pt_name

                         );
                             ELSIF (p_calling_mode = 'SUBMIT') THEN
                                     PA_UTILS.ADD_MESSAGE
                                  ( p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_FP_CIS_INV_PREF_CODE_MATCH'
                                 );

                    END IF;
                      /*p_token1         => 'CI_SOURCE',
                      p_value1         => l_s_ci_id,
                      p_token2         => 'CI_TARGET',
                                p_value2         => l_t_ci_id
                    );*/
                    -- RAISE EXCEPTION RAISE_MERGE_ERROR
                    --raise RAISE_MERGE_ERROR;
                    l_raise_error_flag  := 'Y';
                         -- PROCESS THE NEXT ELEMENT IN THE LOOP
               END IF;
          ELSIF (l_s_fin_plan_pref_code = 'COST_AND_REV_SEP') THEN
               ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 24****');
               IF (
                    (
                      (l_s_version_type = 'COST') AND
                      (l_t_version_type = 'REVENUE')
                    )
                    OR
                    (
                       (l_s_version_type = 'REVENUE') AND
                       (l_t_version_type = 'COST')
                    )
                  ) THEN
                    ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 25');
                    -- MERGE NOT POSSIBLE
                    l_merge_possible_code   := 'E';
                    -- Add message in PA_UTILS
                    IF (p_calling_mode = 'INCLUDE') THEN
                         PA_UTILS.ADD_MESSAGE
                         ( p_app_short_name => 'PA',
                           p_msg_name       => 'PA_FP_CI_INV_VER_TYPE_MATCH',
                           p_token1         => 'CHG_DOC',
                           p_value1         => l_src_ci_number

                         );
                    ELSIF (p_calling_mode = 'IMPLEMENT') THEN
                         PA_UTILS.ADD_MESSAGE
                         ( p_app_short_name => 'PA',
                           p_msg_name       => 'PA_FP_CIM_INV_VER_TYPE_MATCH',
                           p_token1         => 'PLAN_TYPE',
                           p_value1         => l_targ_pt_name

                         );
                                ELSIF (p_calling_mode = 'SUBMIT') THEN
                                        PA_UTILS.ADD_MESSAGE
                                        ( p_app_short_name => 'PA',
                                          p_msg_name       => 'PA_FP_CIS_INV_VER_TYPE_MATCH'
                                        );

                    END IF;
                    /*p_token1         => 'CI_SOURCE',
                      p_value1         => l_s_ci_id,
                      p_token2         => 'CI_TARGET',
                                p_value2         => l_t_ci_id
                    );*/
                    -- RAISE EXCEPTION RAISE_MERGE_ERROR
                    --raise RAISE_MERGE_ERROR;
                    l_raise_error_flag  := 'Y';
                         -- PROCESS THE NEXT ELEMENT IN THE LOOP
                  END IF;
          END IF;
     END IF;

     IF (l_raise_error_flag   = 'Y') THEN
          raise RAISE_MERGE_ERROR;
     END IF;

     ----DBMS_OUTPUT.PUT_LINE('IN CHECK MERGEEEEEEEEEEEEEEEE');
     ----DBMS_OUTPUT.PUT_LINE('l_s_version_id :' || l_s_version_id);
     ----DBMS_OUTPUT.PUT_LINE('l_t_version_id :' || l_t_version_id);
     ----DBMS_OUTPUT.PUT_LINE('l_s_fin_plan_pref_code :' || l_s_fin_plan_pref_code);
     ----DBMS_OUTPUT.PUT_LINE('l_t_fin_plan_pref_code :' || l_t_fin_plan_pref_code);
     ----DBMS_OUTPUT.PUT_LINE('l_s_multi_curr_flag :' || l_s_multi_curr_flag);
     ----DBMS_OUTPUT.PUT_LINE('l_t_multi_curr_flag :' || l_t_multi_curr_flag);
     ----DBMS_OUTPUT.PUT_LINE('l_s_fin_plan_level_code :' || l_s_fin_plan_level_code);
     ----DBMS_OUTPUT.PUT_LINE('l_t_fin_plan_level_code :' || l_t_fin_plan_level_code);
     ----DBMS_OUTPUT.PUT_LINE('l_s_uncategorized_flag :' || l_s_uncategorized_flag);
     ----DBMS_OUTPUT.PUT_LINE('l_t_uncategorized_flag :' || l_t_uncategorized_flag);
     ----DBMS_OUTPUT.PUT_LINE('l_s_version_type :' || l_s_version_type);
     ----DBMS_OUTPUT.PUT_LINE('l_t_version_type :' || l_t_version_type);
     x_merge_possible_code_tbl.extend(1);
     x_merge_possible_code_tbl (i) := l_merge_possible_code;
     ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 34');
     EXCEPTION
     WHEN RAISE_MERGE_ERROR THEN
          ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 35');
          x_merge_possible_code_tbl.extend(1);
          x_merge_possible_code_tbl (i) := l_merge_possible_code;
          x_return_status               := FND_API.G_RET_STS_ERROR;
          ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 36****');
        END;
END IF;
END LOOP;
-- For the Source Version Id

EXCEPTION
     WHEN OTHERS THEN
         FND_MSG_PUB.add_exc_msg
                  ( p_pkg_name       => 'Pa_Fp_Control_Items_Utils.' ||
                   'FP_CI_CHECK_MERGE_POSSIBLE'
                   ,p_procedure_name => PA_DEBUG.G_Err_Stack);
            IF P_PA_DEBUG_MODE = 'Y' THEN
                    PA_DEBUG.g_err_stage := 'Unexpected error in FP_CI_CHECK_MERGE_POSSIBLE';
                    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
            END IF;
         ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_MERGE_POSSIBLE - 37');
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         PA_DEBUG.Reset_Curr_Function;
         RAISE;

END FP_CI_CHECK_MERGE_POSSIBLE;
-- end of FP_CI_CHECK_MERGE_POSSIBLE
-- end of FP_CI_CHECK_MERGE_POSSIBLE

/* isFundingLevelChangeAllowed requires 2 input parameters:
   p_project_id -- the project_id context
   p_proposed_fund_level -- The proposed funding level which is defaulted to null

   The API adds a message and returns x_return_status as FND_API.G_RET_STS_ERROR
   when the proposed funding level cannot be changed. */

PROCEDURE isFundingLevelChangeAllowed
(
  p_project_id                  IN  NUMBER,
  p_proposed_fund_level         IN  VARCHAR2,
  x_return_status               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895


  x_err_code         VARCHAR2(2000);
  x_err_stage        VARCHAR2(2000);
  x_err_stack        VARCHAR2(2000);
  l_msg_index_out    NUMBER;
  l_ci_funding_level VARCHAR2(1);
  l_funding_level    VARCHAR2(1);

  cursor check_ci_funding_level is
  select DECODE(bv.version_type,'REVENUE',revenue_fin_plan_level_code,
                                'ALL',all_fin_plan_level_code,null)
    from pa_budget_versions bv,
         pa_proj_fp_options po,
         pa_ci_impacts      pci,
         pa_projects_all    ppa
   where bv.project_id                  = p_project_id
     and bv.approved_rev_plan_type_flag = 'Y'
     and po.project_id                  = bv.project_id
     and po.fin_plan_type_id            = bv.fin_plan_type_id
     and po.fin_plan_version_id         = bv.budget_version_id
     and po.fin_plan_option_level_code  = 'PLAN_VERSION'
     and pci.ci_id                      = bv.ci_id
     and pci.impact_type_code           = 'FINPLAN_REVENUE'
     and pci.status_code                = 'CI_IMPACT_PENDING'
     and ppa.project_id                 = bv.project_id
     and ppa.baseline_funding_flag      = 'Y';

BEGIN

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     open check_ci_funding_level;
     fetch check_ci_funding_level into l_ci_funding_level;
     IF check_ci_funding_level%NOTFOUND THEN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_count := FND_MSG_PUB.Count_Msg;
        close check_ci_funding_level;
        return;
     END IF;
     close check_ci_funding_level;

     IF p_proposed_fund_level IS NOT NULL THEN
        IF p_proposed_fund_level = 'T' and l_ci_funding_level = 'P' THEN
           /* Project funding level being modified to Top Task level
              where as Budget planning level is at project level
              throw an error as this mismatch cannot be handled in auto-baseline */

           x_return_status := FND_API.G_RET_STS_ERROR;

           PA_UTILS.ADD_MESSAGE(p_app_short_name   => 'PA',
                             p_msg_name            => 'PA_FP_CHK_FUNDING_LVL');
        END IF;
     ELSE -- p_proposed_fund_level IS NULL
             pa_billing_core.check_funding_level (p_project_id,
                                                  l_funding_level,
                                                  x_err_code,
                                                  x_err_stage,
                                                  x_err_stack);

             if (x_err_code <> 0) then
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 x_msg_count := FND_MSG_PUB.Count_Msg;
                   if x_msg_count = 1 then
                      PA_INTERFACE_UTILS_PUB.get_messages
                         (p_encoded        => FND_API.G_TRUE,
                          p_msg_index      => 1,
                          p_data           => x_msg_data,
                          p_msg_index_out  => l_msg_index_out);
                   end if;
                   return;
             end if;
         IF l_funding_level = 'P' AND l_ci_funding_level = 'P' then

                /* Project funding level being modified to Top Task level
                   where as Budget planning level is at project level
                   throw an error as this mismatch cannot be handled in auto-baseline */

            x_return_status := FND_API.G_RET_STS_ERROR;
            PA_UTILS.ADD_MESSAGE(p_app_short_name   => 'PA',
                                 p_msg_name         => 'PA_FP_CHK_FUNDING_LVL');
         END IF;
     END IF;

     x_msg_count := FND_MSG_PUB.Count_Msg;

     IF x_msg_count = 1 then
        PA_INTERFACE_UTILS_PUB.get_messages
           (p_encoded        => FND_API.G_TRUE,
            p_msg_index      => 1,
            p_data           => x_msg_data,
            p_msg_index_out  => l_msg_index_out);
     END IF;

EXCEPTION
     WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_CONTROL_ITEMS_UTILS'
              ,p_procedure_name => 'isFundingLevelChangeAllowed' );


END isFundingLevelChangeAllowed;

/* isAgreementDeletionAllowed API needs to be called before deleting an Agreement.
   If x_return_status is FND_API.G_RET_STS_ERROR then do not allow deletion of agreement.
   Display the error message from the stack or x_msg_data (when x_msg_count=1).
*/

PROCEDURE isAgreementDeletionAllowed
(
  p_agreement_id                IN  NUMBER,
  x_return_status               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895


  l_msg_index_out    NUMBER;
  l_found            varchar2(1);

  cursor c1 is
         select 'Y' from dual
          where exists (
                         select 'x'
                           from pa_summary_project_fundings fu,
                                pa_budget_versions bv
                          where fu.agreement_id = p_agreement_id
                            and bv.project_id   = fu.project_id
                            and bv.agreement_id = p_agreement_id);
BEGIN

         x_return_status := FND_API.G_RET_STS_SUCCESS;
         l_found := 'N';

         open c1;
         fetch c1 into l_found;
         close c1;

         IF l_found = 'Y' then
            x_return_status := FND_API.G_RET_STS_ERROR;
            PA_UTILS.ADD_MESSAGE(p_app_short_name   => 'PA',
                                 p_msg_name         => 'PA_FP_AGR_CI_NO_DELETE');
         END IF;


     x_msg_count := FND_MSG_PUB.Count_Msg;
           IF x_msg_count = 1 then
              PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_data           => x_msg_data,
                  p_msg_index_out  => l_msg_index_out);
           END IF;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_SUCCESS;
          x_msg_count := FND_MSG_PUB.Count_Msg;
          IF x_msg_count = 1 then
              PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_data           => x_msg_data,
                  p_msg_index_out  => l_msg_index_out);
           END IF;
     WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_CONTROL_ITEMS_UTILS'
              ,p_procedure_name => 'isAgreementDeletionAllowed' );


END isAgreementDeletionAllowed;


/* isAgrCurrencyChangeAllowed API needs to be called before changing Agreement/Funding Currency.
   If x_return_status is FND_API.G_RET_STS_ERROR then do not allow change in currency.
   Display the error message from the stack or x_msg_data (when x_msg_count=1).
*/

PROCEDURE isAgrCurrencyChangeAllowed
(
  p_agreement_id                IN  NUMBER,
  x_return_status               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

  l_msg_index_out    NUMBER;
  l_found            varchar2(1);

  cursor c1 is
         select 'Y' from dual
          where exists (
                         select 'x'
                           from pa_summary_project_fundings fu,
                                pa_budget_versions bv
                          where fu.agreement_id = p_agreement_id
                            and bv.project_id   = fu.project_id
                            and bv.agreement_id = p_agreement_id);
BEGIN

         x_return_status := FND_API.G_RET_STS_SUCCESS;
         l_found := 'N';

         open c1;
         fetch c1 into l_found;
         close c1;

         IF l_found = 'Y' then
            x_return_status := FND_API.G_RET_STS_ERROR;
            PA_UTILS.ADD_MESSAGE(p_app_short_name   => 'PA',
                                 p_msg_name         => 'PA_FP_AGR_CUR_NO_CHANGE');
         END IF;


     x_msg_count := FND_MSG_PUB.Count_Msg;
           IF x_msg_count = 1 then
              PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_data           => x_msg_data,
                  p_msg_index_out  => l_msg_index_out);
           END IF;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_SUCCESS;
          x_msg_count := FND_MSG_PUB.Count_Msg;
          IF x_msg_count = 1 then
              PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_data           => x_msg_data,
                  p_msg_index_out  => l_msg_index_out);
           END IF;
     WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_CONTROL_ITEMS_UTILS'
              ,p_procedure_name => 'isAgrCurrencyChangeAllowed' );

END isAgrCurrencyChangeAllowed;

/*==============================================================================
  This api is called to check if a CI version can be created for the impacted
  task id,plan type_id and project_id  combination.

-- 01-JUL-2003 jwhite        - Bug 2989874
--                             For Is_Create_CI_Version_Allowed procedure,
--                             default ci from the  current working version.
 ===============================================================================*/

PROCEDURE Is_Create_CI_Version_Allowed
   (  p_project_id              IN      pa_budget_versions.project_id%TYPE
     ,p_fin_plan_type_id        IN      pa_proj_fp_options.fin_plan_type_id%TYPE
     ,p_version_type            IN      pa_budget_versions.version_type%TYPE
     ,p_impacted_task_id        IN      pa_tasks.task_id%TYPE
     ,x_version_allowed_flag    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_return_status           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count               OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_error_msg_code                VARCHAR2(30);
l_msg_index_out                 NUMBER;
l_return_status                 VARCHAR2(2000);
l_debug_mode                    VARCHAR2(30);
l_module_name                   VARCHAR2(100) := 'pa.plsql.Pa_Fp_Control_Items_Utils';

l_uncategorized_flag            pa_resource_lists.uncategorized_flag%TYPE;
l_group_resource_type_id        pa_resource_lists.group_resource_type_id%TYPE;
l_resource_list_id              pa_resource_lists.resource_list_id%TYPE;
l_grouped_flag                  VARCHAR2(1);  --indicates if resource_list is grouped

l_proj_fp_options_id            pa_proj_fp_options.proj_fp_options_id%TYPE;

l_count                         NUMBER;
l_impacted_task_level           VARCHAR2(1);
l_plan_type_planning_level      pa_proj_fp_options.all_fin_plan_level_code%TYPE;

     -- jwhite: Added for Plannable Task Dev Effort ------------------
     -- 01-JUL-2003 Default ci from current working version
     l_ci_apprv_bv_option_id          pa_proj_fp_options.proj_fp_options_id%TYPE :=NULL;
     l_ci_apprv_cw_bv_id              pa_budget_versions.budget_version_id%TYPE  :=NULL;

        -- ---------------------------------------------------------------------------


CURSOR impacted_task_cur(c_impacted_task_id  pa_tasks.task_id%TYPE) IS
SELECT parent_task_id,
       top_task_id
FROM   pa_tasks
WHERE  task_id = c_impacted_task_id;

impacted_task_rec        impacted_task_cur%ROWTYPE;

/*CURSOR cur_impact_task_level_M_top (c_task_id   pa_tasks.task_id%TYPE) IS
SELECT COUNT(1)
FROM   DUAL
WHERE  EXISTS
     (SELECT 'X'
      FROM   pa_resource_assignments pra
      WHERE  pra.budget_version_id = l_ci_apprv_cw_bv_id
      AND    pra.project_id = p_project_id
      AND    pra.project_assignment_id  = -1
      AND    (pra.task_id=c_task_id OR pra.task_id=p_impacted_task_id));*/

CURSOR  cur_impact_task_level_M_child IS
SELECT COUNT(1)
FROM   DUAL
WHERE EXISTS
    (SELECT 'X'
     FROM   pa_resource_assignments pra
     WHERE  pra.budget_version_id = l_ci_apprv_cw_bv_id
     AND    pra.project_id = p_project_id
     AND    pra.project_assignment_id  = -1
     AND    EXISTS ( SELECT 1
                     FROM   pa_tasks t
                     WHERE      t.parent_task_id = p_impacted_task_id
                     START WITH t.task_id = pra.task_id
                     CONNECT BY PRIOR t.parent_task_id = t.task_id));

CURSOR cur_impact_task_level_L (c_top_task_id  pa_tasks.task_id%TYPE) IS
SELECT COUNT(1)
FROM   DUAL
WHERE EXISTS
    (SELECT 'X'
     FROM   pa_resource_assignments pra
     WHERE  pra.budget_version_id = l_ci_apprv_cw_bv_id
     AND    pra.project_id = p_project_id
     AND    pra.project_assignment_id  = -1
     AND    (pra.task_id  = p_impacted_task_id or pra.task_id = c_top_task_id));-- /*UT*/fe.top_task_id = c_top_task_id)


CURSOR cur_impact_task_level_T IS
SELECT COUNT(1)
FROM   DUAL
WHERE EXISTS
    (SELECT 'X'
     FROM   pa_resource_assignments pra,
          pa_tasks t
     WHERE  pra.budget_version_id = l_ci_apprv_cw_bv_id
     AND    pra.project_id = p_project_id
     AND    pra.project_assignment_id  = -1
     AND    t.task_id=pra.task_id
     AND    t.top_task_id  =  p_impacted_task_id);

CURSOR cur_impacted_task_null IS
SELECT  count(1)
FROM    DUAL
WHERE   EXISTS
    (SELECT 'X'
     FROM   pa_resource_assignments pra
     WHERE  pra.budget_version_id = l_ci_apprv_cw_bv_id
     AND    pra.project_id = p_project_id
     AND    pra.project_assignment_id  = -1);
BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      pa_debug.set_err_stack('PA_FP_CONTROL_ITEMS_UTILS.Is_Create_CI_Version_Allowed');
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
      pa_debug.set_process('PLSQL','LOG',l_debug_mode);

      -- Check for business rules violations

      pa_debug.g_err_stage:= 'Validating input parameters';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('Is_Create_CI_Version_Allowed: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      --Check if plan version id is null

      IF (p_project_id       IS NULL) OR
         (p_fin_plan_type_id IS NULL) OR
         (p_version_type     IS NULL)
      THEN
                   pa_debug.g_err_stage:= 'p_project_id = '||p_project_id;
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('Is_Create_CI_Version_Allowed: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                   END IF;
                   pa_debug.g_err_stage:= 'p_fin_plan_type_id = '||p_fin_plan_type_id;
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('Is_Create_CI_Version_Allowed: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                   END IF;
                   pa_debug.g_err_stage:= 'p_version_type = '||p_version_type;
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('Is_Create_CI_Version_Allowed: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                   END IF;

                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                          p_msg_name     => 'PA_FP_INV_PARAM_PASSED');

                   pa_debug.g_err_stage:= 'Invalid Arguments Passed';
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('Is_Create_CI_Version_Allowed: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                   END IF;

                   RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      -- Fetch the plan type fp options id and resource list attached
      -- Bug# 2682955-Fetching plan type planning level

     -- Begin; jwhite: Added for Plannable Task Dev Effort ------------------
     -- 01-JUL-2003 Default ci from current working version


      -- Fetch current working approved budget version id
      Pa_Fp_Control_Items_Utils.CHK_APRV_CUR_WORKING_BV_EXISTS(
                                          p_project_id       => p_project_id,
                                          p_fin_plan_type_id => p_fin_plan_type_id,
                                          p_version_type     => p_version_type,
                                          x_cur_work_bv_id   => l_ci_apprv_cw_bv_id,
                                          x_return_status    => l_return_status,
                                          x_msg_count        => l_msg_count,
                                          x_msg_data         => l_msg_data );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;


      BEGIN
              SELECT proj_fp_options_id,
                     DECODE(p_version_type,
                            PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL,      all_resource_list_id,
                            PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST,     cost_resource_list_id,
                            PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE,  revenue_resource_list_id) resource_list_id,
                     DECODE(p_version_type,
                            PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL,      all_fin_plan_level_code,
                            PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST,     cost_fin_plan_level_code,
                            PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE,  revenue_fin_plan_level_code) plan_type_planning_level
              INTO   l_proj_fp_options_id,
                     l_resource_list_id,
                     l_plan_type_planning_level
              FROM   pa_proj_fp_options
              WHERE  project_id = p_project_id
              AND    fin_plan_type_id = p_fin_plan_type_id
              AND  fin_plan_version_id = l_ci_apprv_cw_bv_id;

  -- End; jwhite: Added for Plannable Task Dev Effort ------------------

      EXCEPTION
             WHEN OTHERS THEN
                      pa_debug.g_err_stage:= 'Failed to fetch the fp options id for given combination'||SQLERRM;
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.write('Is_Create_CI_Version_Allowed: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                      END IF;
                      raise;
      END;

      pa_debug.g_err_stage:= 'Impacted task  = '|| p_impacted_task_id;
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('Is_Create_CI_Version_Allowed: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      pa_debug.g_err_stage := 'Plan Type Planning Level =' || l_plan_type_planning_level;
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('Is_Create_CI_Version_Allowed: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      -- Fetch resource list info

      pa_debug.g_err_stage:= 'Calling get_resource_list_info' ;
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('Is_Create_CI_Version_Allowed: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      pa_fin_plan_utils.get_resource_list_info(
                  p_resource_list_id              =>    l_resource_list_id
                 ,x_res_list_is_uncategorized     =>    l_uncategorized_flag
                 ,x_is_resource_list_grouped      =>    l_grouped_flag
                 ,x_group_resource_type_id        =>    l_group_resource_type_id
                 ,x_return_status                 =>    l_return_status
                 ,x_msg_count                     =>    l_msg_count
                 ,x_msg_data                      =>    l_msg_data);

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;

      /* Bug# 2682955 - Creating plannable elements based on the impacted task is ONLY applicable
         if the plan type level planning level is Task level.

         If the planning level for the plan type is Project and resource list is categorized, then ,
         regardless of the impacted tasks, only the existenc of project level planning elements
         should be checked.

         If the planning level for the plan type is Project and resource list is uncategorized,
         no check needs to be done. */

      IF l_plan_type_planning_level = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT AND
         l_uncategorized_flag = 'Y' THEN

        RETURN;

      END IF;

      IF l_plan_type_planning_level <> PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT THEN

        -- If impacted task id is not null then fetch it's  top task id and parent task id
        -- and derive the task level of it

        IF p_impacted_task_id IS NOT NULL THEN

              pa_debug.g_err_stage:= 'Fetching impacted task details';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('Is_Create_CI_Version_Allowed: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
              END IF;

              -- Fetching top task id and parent task id of impacted task id

              OPEN  impacted_task_cur(p_impacted_task_id);
              FETCH impacted_task_cur INTO impacted_task_rec;
              CLOSE impacted_task_cur;

              -- Fetching impacted task level

              IF   impacted_task_rec.top_task_id = p_impacted_task_id
              THEN
                   l_impacted_task_level := PA_FP_CONSTANTS_PKG.G_IMPACTED_TASK_LEVEL_T;
              ELSE
                    BEGIN
                           SELECT count(task_id)
                           INTO   l_count
                           FROM   pa_tasks
                           WHERE  parent_task_id = p_impacted_task_id;

                           IF l_count = 0
                           THEN
                                 l_impacted_task_level := PA_FP_CONSTANTS_PKG.G_IMPACTED_TASK_LEVEL_L;
                           ELSE
                                 l_impacted_task_level := PA_FP_CONSTANTS_PKG.G_IMPACTED_TASK_LEVEL_M;
                           END IF;
                    EXCEPTION
                         WHEN Others THEN
                              pa_debug.g_err_stage:= 'Error during fetching impacted task details';
                              IF P_PA_DEBUG_MODE = 'Y' THEN
                                 pa_debug.write('Is_Create_CI_Version_Allowed: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                              END IF;
                              RAISE;
                    END;
              END IF;

              pa_debug.g_err_stage:= 'Impacted task level = '|| l_impacted_task_level;
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('Is_Create_CI_Version_Allowed: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
              END IF;

        END IF;

      END IF; /*  l_plan_type_planning_level <> PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT */

      -- Initialising l_count to 0

      l_count := 0;

      /* Bug# 2682955 - If plan_type planning level is Project with a categorized resource list,
         we just need check for the existence of planning elements */

      IF  p_impacted_task_id IS NULL OR l_plan_type_planning_level = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT
          THEN

              -- Check if plan type has any plannable elements

              pa_debug.g_err_stage:= 'Opening cur_impacted_task_null' ;
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('Is_Create_CI_Version_Allowed: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
              END IF;

              OPEN cur_impacted_task_null;
              FETCH cur_impacted_task_null INTO l_count;
              CLOSE cur_impacted_task_null;
      ELSE
              IF   l_impacted_task_level = PA_FP_CONSTANTS_PKG.G_IMPACTED_TASK_LEVEL_M THEN

                      -- Check if top task id of impacted task is plannable
                      pa_debug.g_err_stage:= 'Opening cur_impact_task_level_M_child' ;
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.write('Is_Create_CI_Version_Allowed: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                      END IF;

                      OPEN  cur_impact_task_level_M_child;
                      FETCH cur_impact_task_level_M_child INTO l_count;
                      CLOSE cur_impact_task_level_M_child;

              ELSIF   l_impacted_task_level = PA_FP_CONSTANTS_PKG.G_IMPACTED_TASK_LEVEL_L THEN

                      -- Check if the impacted task or its top task is plannable

                      pa_debug.g_err_stage:= 'Opening cur_impact_task_level_L' ;
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.write('Is_Create_CI_Version_Allowed: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                      END IF;

                      OPEN  cur_impact_task_level_L(impacted_task_rec.top_task_id);
                      FETCH cur_impact_task_level_L  INTO l_count;
                      CLOSE cur_impact_task_level_L;

              ELSIF   l_impacted_task_level = PA_FP_CONSTANTS_PKG.G_IMPACTED_TASK_LEVEL_T THEN

                      -- Check if there are any plannable elements with top task id as impacted task id.

                      pa_debug.g_err_stage:= 'Opening cur_impact_task_level_T' ;
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.write('Is_Create_CI_Version_Allowed: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                      END IF;

                      OPEN  cur_impact_task_level_T;
                      FETCH cur_impact_task_level_T  INTO l_count;
                      CLOSE cur_impact_task_level_T;
              END IF;
      END IF;

      IF l_count = 0
      THEN
          x_version_allowed_flag := 'N';

          pa_debug.g_err_stage:= 'Ci_version cant be created';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('Is_Create_CI_Version_Allowed: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          END IF;

          -- raise error if the ci version cant be created
          x_return_status := FND_API.G_RET_STS_ERROR;

          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_FP_CI_VERSION_NOT_ALLOWED');
          RETURN;
      ELSE
          x_version_allowed_flag := 'Y';
      END IF;

      pa_debug.g_err_stage:= 'Exiting Is_Create_CI_Version_Allowed';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('Is_Create_CI_Version_Allowed: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;
      pa_debug.reset_err_stack;

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

--           pa_debug.g_err_stage:= 'Invalid Arguments Passed';
--           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
           pa_debug.reset_err_stack;
           RAISE;

   WHEN others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FP_CONTROL_ITEMS_UTILS'
                                  ,p_procedure_name  => 'Is_Create_CI_Version_Allowed');
          pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('Is_Create_CI_Version_Allowed: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          END IF;
          pa_debug.reset_err_stack;
          RAISE;

END Is_Create_CI_Version_Allowed;

PROCEDURE  IsValidAgreement(
                          p_project_id IN NUMBER,
                          p_agreement_number IN VARCHAR2,
                          x_agreement_id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_msg_count OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_msg_data OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_return_status OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895
   l_count NUMBER := 0;

BEGIN
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.init_err_stack('IsValidAgreement: ' || 'PA_FP_CONTROL_ITEMS_UTILS.Get_Fin_Plan_Dtls');
   END IF;

   IF p_agreement_number IS NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FP_AGR_NUM_REQ' );
      pa_debug.reset_err_stack;
      RETURN;
   END IF;

   SELECT a.Agreement_Id INTO x_agreement_id FROM
   Pa_Agreements_All a,
   Pa_Summary_Project_Fundings spf
   WHERE
   a.agreement_num = p_agreement_number AND
   a.agreement_id  = spf.agreement_id AND
   spf.project_id = p_project_id AND
   NVL(spf.total_unbaselined_amount,0) > 0 AND
   ROWNUM < 2;
   pa_debug.reset_err_stack;
   RETURN;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FP_AGR_INVALID',
                            p_token1         => 'AGREEMENT_NUMBER',
                            p_value1         => p_agreement_number);
      pa_debug.reset_err_stack;
      RETURN;

   WHEN OTHERS THEN
          FND_MSG_PUB.Add_Exc_Msg(
              p_pkg_name => 'PA_FP_CONTROL_ITEMS_UTILS.IsValidAgreement'
             ,p_procedure_name => PA_DEBUG.G_Err_Stack);
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('IsValidAgreement: ' || SQLERRM);
              END IF;
              pa_debug.reset_err_stack;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   RAISE;
END IsValidAgreement;

FUNCTION IsFpAutoBaselineEnabled(p_project_id IN NUMBER)
   RETURN VARCHAR2 IS
   l_baseline_funding_flag pa_projects_all.baseline_funding_flag%TYPE;
   l_no_of_app_plan_types NUMBER;
   l_fp_pref_code pa_proj_fp_options.fin_plan_preference_code%TYPE;

BEGIN
   SELECT NVL(Baseline_Funding_Flag,'N') INTO
          l_baseline_Funding_flag
   FROM Pa_Projects_All
   WHERE
   Project_Id = p_project_id;
   IF l_baseline_funding_flag = 'N' THEN
      RETURN l_baseline_funding_flag;
   END IF;

   SELECT COUNT(*) INTO l_no_of_app_plan_types FROM Pa_Proj_Fp_Options
   WHERE
   Project_Id = p_project_id AND
   Fin_Plan_Option_Level_Code = 'PLAN_TYPE' AND
   ( NVL(Approved_Cost_Plan_Type_Flag ,'N') = 'Y' OR
     NVL(Approved_Rev_Plan_Type_Flag  ,'N') = 'Y' ) ;

   IF l_no_of_app_plan_types = 0 THEN
      l_baseline_funding_flag := 'N';
      RETURN l_baseline_funding_flag;
   END IF;

   IF l_no_of_app_plan_types = 1 THEN
      SELECT fin_plan_preference_code INTO
            l_fp_pref_code
      FROM pa_proj_fp_options
      WHERE
      project_id = p_project_id AND
      Fin_Plan_Option_Level_Code = 'PLAN_TYPE' AND
      ( NVL(Approved_Cost_Plan_Type_Flag ,'N') = 'Y' OR
        NVL(Approved_Rev_Plan_Type_Flag  ,'N') = 'Y' ) ;

      IF l_fp_pref_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY THEN
         l_baseline_funding_flag := 'N';
         RETURN l_baseline_funding_flag;
      END IF;
   END IF;
   /* if the no of approved plan types is 2, then
      it is planned for revenue */
   RETURN l_baseline_funding_flag;
EXCEPTION
WHEN OTHERS THEN
   RETURN 'N';
END IsFpAutoBaselineEnabled;

/*
   This API returns budget version information
   from the pa budget versions table and
   also returns information regarding project
   currency to show on the OA Page
   */
PROCEDURE GET_BUDGET_VERSION_INFO
(
     p_project_id        IN NUMBER,
     p_budget_version_id IN NUMBER,
     x_version_number    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_version_name      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_version_type      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_project_currency_code OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_approved_cost_flag     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_approved_rev_flag OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_fin_plan_type_id  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_plan_type_name    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_plan_class_code    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
  IS

-- Local Variable Declaration
      l_debug_mode            VARCHAR2(30);

BEGIN
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.init_err_stack('PAFPCIUB.GET_BUDGET_VERSION_INFO');
     END IF;
     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');
     pa_debug.set_process('PLSQL','LOG',l_debug_mode);
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     x_msg_count := 0;
     ----DBMS_OUTPUT.PUT_LINE('GET_BUDGET_VERSION_INFO - 1');
      --Get the column values for this budget version id and project id combination
      -- Added x_plan_class_code below
      BEGIN
        SELECT
            bv.version_number,
            bv.version_name,
            bv.version_type,
            NVL(bv.approved_cost_plan_type_flag,'N'),
            NVL(bv.approved_rev_plan_type_flag,'N'),
            bv.fin_plan_type_id,
            patl.name,
            pftb.plan_class_code plan_class_code
        INTO
            x_version_number,
            x_version_name,
            x_version_type,
            x_approved_cost_flag,
            x_approved_rev_flag,
            x_fin_plan_type_id,
            x_plan_type_name,
            x_plan_class_code
        FROM pa_budget_versions bv, pa_fin_plan_types_tl patl,pa_fin_plan_types_b pftb
        WHERE bv.budget_version_id = p_budget_version_id
            and bv.project_id = p_project_id
            and bv.fin_plan_type_id = patl.fin_plan_type_id
            and patl.fin_plan_type_id = pftb.fin_plan_type_id
            and patl.language = userenv('LANG');

     EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   PA_UTILS.ADD_MESSAGE
                    ( p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_CI_NO_VERSION_DATA_FOUND');
                   ----DBMS_OUTPUT.PUT_LINE('FP_CI_GET_VERSION_DETAILS - 2***');
                   x_return_status := FND_API.G_RET_STS_ERROR;
     END;

     BEGIN
          SELECT   project_currency_code
          INTO
               x_project_currency_code
          FROM
               Pa_Projects_All
          WHERE
               project_Id = p_project_id;
     EXCEPTION
          WHEN NO_DATA_FOUND THEN
                NULL;
     END;

EXCEPTION
     WHEN OTHERS THEN
         FND_MSG_PUB.add_exc_msg
                  ( p_pkg_name       => 'Pa_Fp_Control_Items_Utils.' ||
                   'GET_BUDGET_VERSION_INFO'
                   ,p_procedure_name => PA_DEBUG.G_Err_Stack);
         ----DBMS_OUTPUT.PUT_LINE('GET_BUDGET_VERSION_INFO - 3');
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.g_err_stage := 'Unexpected error in GET_BUDGET_VERSION_INFO';
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
            END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         PA_DEBUG.Reset_Curr_Function;
         RAISE;
END GET_BUDGET_VERSION_INFO;
-- end of GET_BUDGET_VERSION_INFO

/* the following function is used in the
   Impact Implementation page */

FUNCTION Get_Funindg_Amount(
           p_project_id IN pa_projects_all.project_id%TYPE,
           p_agreement_id IN pa_agreements_all.agreement_id%TYPE)
RETURN NUMBER IS
   l_funding_amount NUMBER := 0;
BEGIN
   SELECT SUM(NVL(total_baselined_amount,0)) INTO
   l_funding_amount
   FROM
   pa_summary_project_fundings
   WHERE
   project_id = p_project_id AND
   agreement_id = p_agreement_id;
   RETURN l_funding_amount;
EXCEPTION
WHEN OTHERS THEN
     RETURN l_funding_amount;
END GET_FUNINDG_AMOUNT;

/* CHK_APRV_CUR_WORKING_BV_EXISTS checks to see if for an approved budget version
   which is a current working version of the version type the user is
   trying to create a financial impact. It returns an error status when such a
   working version is not available.
*/
--Bug 4283579: The fix done to this API thru bug 4089203 is reverted as that is only partial fix.
--Please refer to the bug 4283579 for the expected/correct behavior. Code changes for enforcing that
--behavior are targeted for track1 post FP.M

PROCEDURE CHK_APRV_CUR_WORKING_BV_EXISTS
          ( p_project_id              IN  pa_projects_all.project_id%TYPE
           ,p_fin_plan_type_id        IN  pa_proj_fp_options.fin_plan_type_id%TYPE
           ,p_version_type            IN  pa_budget_versions.version_type%TYPE
           ,x_cur_work_bv_id          OUT NOCOPY pa_budget_versions.budget_version_id%TYPE --File.Sql.39 bug 4440895
           ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count               OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data                OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

l_msg_index_out number;
l_exists varchar2(1) := 'N';
l_project_name pa_projects_all.name%TYPE;
l_plan_name    pa_fin_plan_types_tl.name%TYPE;
l_version_type pa_lookups.meaning%TYPE;
l_stage        number;
l_baseline_funding_flag pa_projects_all.baseline_funding_flag%TYPE;
l_msg_name fnd_new_messages.message_name%TYPE;
--Bug 5845142. Exclude COST impacts with cost and revenue together setup.
cursor c1 is
       Select budget_version_id
         from pa_budget_versions bv,
              pa_proj_fp_options pfo
        where bv.project_id       = p_project_id
          and bv.fin_plan_type_id = p_fin_plan_type_id
          and bv.version_type     = p_version_type
          and bv.current_working_flag = 'Y'
          and bv.ci_id            IS NULL
          and pfo.project_id      = p_project_id
          and pfo.fin_plan_type_id= p_fin_plan_type_id
          and pfo.fin_plan_version_id IS NULL
          and ((DECODE(p_version_type,'COST',bv.approved_cost_plan_type_flag,
                                    'REVENUE',bv.approved_rev_plan_type_flag,
                                    'N') = 'Y')
              OR
              (p_version_type='ALL' and
               pfo.approved_cost_plan_type_flag ='Y' and
               pfo.approved_rev_plan_type_flag ='N' and
               pfo.fin_plan_preference_code='COST_AND_REV_SAME')
              OR
               (p_version_type='ALL' and
                pfo.approved_cost_plan_type_flag ='N' and
                pfo.approved_rev_plan_type_flag ='Y' and
                pfo.fin_plan_preference_code='COST_AND_REV_SAME')    /* bug 7584903 */
              OR
             (bv.approved_cost_plan_type_flag = 'Y' and
              bv.approved_rev_plan_type_flag  = 'Y')) ;

BEGIN

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_stage := 100;

     select name,
            NVL(Baseline_Funding_Flag,'N')
       into l_project_name,
            l_baseline_Funding_flag
       from pa_projects_all
      where project_id = p_project_id;

     l_stage := 200;

     select name
       into l_plan_name
       from pa_fin_plan_types_tl
      where fin_plan_type_id = p_fin_plan_type_id
        and language = userenv('LANG');

     l_stage := 300;

     select meaning
       into l_version_type
       from pa_lookups
      where lookup_type = 'FIN_PLAN_VER_TYPE'
        and lookup_code = p_version_type;

     l_stage := 400;

     open c1;
     l_stage := 500;
     fetch c1 into x_cur_work_bv_id;
     IF C1%NOTFOUND then
           x_cur_work_bv_id := -9999;
           IF  l_baseline_Funding_flag = 'Y' AND
               p_version_type = 'REVENUE'         THEN
               l_msg_name := 'PA_FP_CI_AB_NO_CW';
           ELSE
               l_msg_name := 'PA_FP_APRV_CUR_WORK_NOT_EXISTS';
           END IF;
           pa_utils.add_message
                        ( p_app_short_name => 'PA',
                          p_msg_name       => l_msg_name,
                          p_token1         => 'PROJECT',
                          p_value1         => l_project_name,
                          p_token2         => 'PLAN',
                          p_value2         => l_plan_name,
                          p_token3         => 'VERSION_TYPE',
                          p_value3         => l_version_type);

                   fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                              p_data  => x_msg_data);
                   x_msg_count := fnd_msg_pub.count_msg;
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   close c1;

                   return;
      END IF;

     l_stage := 600;
     close c1;

     x_msg_count := FND_MSG_PUB.Count_Msg;

     IF x_msg_count = 1 then
        PA_INTERFACE_UTILS_PUB.get_messages
           (p_encoded        => FND_API.G_TRUE,
            p_msg_index      => 1,
            p_data           => x_msg_data,
            p_msg_index_out  => l_msg_index_out);
     END IF;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
          WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := to_char(l_stage)||'-'||SQLERRM;
          FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_CONTROL_ITEMS_UTILS'
              ,p_procedure_name => 'Chk_Aprv_Cur_Working_BV_Exists' );

END CHK_APRV_CUR_WORKING_BV_EXISTS;

--In FP M merge is not possible only when the source time phasing is PA and target time phasing is GL or vice-versa
--IN other cases merge will be possible. Modified the API for this change
PROCEDURE COMPARE_SOURCE_TARGET_VER_ATTR
          ( p_source_bv_id            IN  pa_budget_versions.budget_version_id%TYPE
           ,p_target_bv_id            IN  pa_budget_versions.budget_version_id%TYPE
           ,x_attributes_same_flag    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count               OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data                OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

l_stage number ;
l_source_time_phased_code pa_proj_fp_options.all_time_phased_code%TYPE;
l_target_time_phased_code pa_proj_fp_options.all_time_phased_code%TYPE;

cursor c1 is
             select DECODE(pos.fin_plan_preference_code,'COST_ONLY',   pos.cost_time_phased_code,
                                                        'REVENUE_ONLY',pos.revenue_time_phased_code,
                                                                  pos.all_time_phased_code) source_time_phased_code,
                    DECODE(pot.fin_plan_preference_code,'COST_ONLY',   pot.cost_time_phased_code,
                                                        'REVENUE_ONLY',pot.revenue_time_phased_code,
                                                                  pot.all_time_phased_code) target_time_phased_code
               from pa_proj_fp_options pos
                   ,pa_proj_fp_options pot
              where pos.fin_plan_version_id       = p_source_bv_id
                and pot.fin_plan_version_id        = p_target_bv_id;
BEGIN
          x_return_status := FND_API.G_RET_STS_SUCCESS;

          open c1;
          l_stage := 100;
          fetch c1 into l_source_time_phased_code
                       ,l_target_time_phased_code;

          l_stage := 200;
           close c1;

           IF l_source_time_phased_code <> l_target_time_phased_code AND
              l_source_time_phased_code IN ('P','G') AND
              l_target_time_phased_code IN ('P','G') THEN

          l_stage := 400;
              --For Bug 3642884
              x_attributes_same_flag := 'N';
              x_return_status := FND_API.G_RET_STS_SUCCESS;
              x_msg_count := FND_MSG_PUB.Count_Msg;
              x_msg_data  := NULL;

           ELSE
          l_stage := 500;
              --For Bug 3642884
              x_attributes_same_flag := 'Y';
              x_return_status := FND_API.G_RET_STS_SUCCESS;
              x_msg_count := FND_MSG_PUB.Count_Msg;
              x_msg_data  := NULL;
           END IF;

EXCEPTION
          WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := to_char(l_stage)||'-'||SQLERRM;
          FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_CONTROL_ITEMS_UTILS'
              ,p_procedure_name => 'Compare_Source_Target_Ver_Attr' );

END COMPARE_SOURCE_TARGET_VER_ATTR;

/*
   This API returns budget version id OR
   number of budget version ids for a project id,
   fin plan type id and version name if there
   are more than one budget version ids.The API
   is used to validate the LOV selection in
   the Advanced Display Options Page
   */
PROCEDURE CHECK_PLAN_VERSION_NAME_OR_ID
(
     p_project_id        IN NUMBER,
     p_budget_version_name    IN VARCHAR2,
     p_fin_plan_type_id  IN NUMBER,
     p_version_type      IN VARCHAR2,
     x_no_of_bv_versions OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_budget_version_id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
  IS

-- Local Variable Declaration
      l_debug_mode            VARCHAR2(30);

BEGIN
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.init_err_stack('PAFPCIUB.CHECK_PLAN_VERSION_NAME_OR_ID');
     END IF;
     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');
     pa_debug.set_process('PLSQL','LOG',l_debug_mode);
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     x_msg_count := 0;
     ----DBMS_OUTPUT.PUT_LINE('CHECK_PLAN_VERSION_NAME_OR_ID - 1');
      --Get the number of versions for this budget version name
      -- fin plan type id and project id combination
     SELECT
          count(*)
     INTO
          x_no_of_bv_versions
     FROM pa_budget_versions bv
     WHERE bv.version_name = p_budget_version_name
          and bv.project_id = p_project_id
          and bv.fin_plan_type_id = p_fin_plan_type_id
          and bv.version_type = p_version_type;

     IF (x_no_of_bv_versions = 1) THEN
          SELECT
               bv.budget_version_id
          INTO
               x_budget_version_id
          FROM pa_budget_versions bv
          WHERE bv.version_name = p_budget_version_name
          and bv.project_id = p_project_id
          and bv.fin_plan_type_id = p_fin_plan_type_id
          and bv.version_type = p_version_type;

          RETURN;
     ELSE
          RETURN;
     END IF;
EXCEPTION
     WHEN OTHERS THEN
         FND_MSG_PUB.add_exc_msg
                  ( p_pkg_name       => 'Pa_Fp_Control_Items_Utils.' ||
                   'CHECK_PLAN_VERSION_NAME_OR_ID'
                   ,p_procedure_name => PA_DEBUG.G_Err_Stack);
         ----DBMS_OUTPUT.PUT_LINE('CHECK_PLAN_VERSION_NAME_OR_ID - 3');
            IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.g_err_stage := 'Unexpected error in CHECK_PLAN_VERSION_NAME_OR_ID';
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
            END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         PA_DEBUG.Reset_Curr_Function;
         RAISE;
END CHECK_PLAN_VERSION_NAME_OR_ID;
-- end of CHECK_PLAN_VERSION_NAME_OR_ID


--

--    01-JUL-2003 jwhite      - Bug 2989874
--                            For  procedure, FP_CI_CHECK_COPY_POSSIBLE
--                            default ci from the  current working version.

PROCEDURE FP_CI_CHECK_COPY_POSSIBLE
          ( p_source_plan_level_code    IN  pa_proj_fp_options.all_fin_plan_level_code%TYPE
           ,p_source_time_phased_code   IN  pa_proj_fp_options.all_time_phased_code%TYPE
           ,p_source_resource_list_id   IN  pa_proj_fp_options.all_resource_list_id%TYPE
           ,p_source_version_type       IN  pa_budget_versions.version_type%TYPE
           ,p_project_id                IN  pa_budget_versions.project_id%TYPE
           ,p_s_ci_id                   IN  pa_budget_versions.ci_id%TYPE
           ,p_multiple_plan_types_flag  IN  VARCHAR2
           ,x_copy_possible_flag        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data                  OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

l_debug_mode            VARCHAR2(30);
l_target_plan_level_code  pa_proj_fp_options.all_fin_plan_level_code%TYPE;
l_target_time_phased_code pa_proj_fp_options.all_time_phased_code%TYPE;
l_target_resource_list_id pa_proj_fp_options.all_resource_list_id%TYPE;

l_token_ci_id varchar2(150);
l_token_v_type VARCHAR2(30);
l_time_phase_code_flag VARCHAR2(1);
l_baseline_funding_Flag pa_projects_All.baseline_funding_flag%type;
l_s_rev_bv_id pa_budget_versions.budget_version_id%type;
l_count number;
l_s_bv_fp_level_code pa_proj_fp_options.all_fin_plan_level_code%TYPE;
l_ci_number pa_control_items.ci_number%type;
l_ci_type_name pa_ci_types_tl.short_name%type;
l_s_bv_time_phased_code pa_proj_fp_options.revenue_time_phased_code%type;
l_s_bv_resource_list_id pa_proj_fp_options.revenue_resource_list_id%type;

l_ci_aprv_bv_option_id pa_proj_fp_options.proj_fp_options_id%TYPE;
l_ci_aprv_cw_bv_id     pa_budget_versions.budget_version_id%TYPE;
l_ci_aprv_plan_type_id pa_proj_fp_options.fin_plan_type_id%TYPE;
l_return_status        VARCHAR2(1)    := NULL;
l_msg_count            NUMBER         := NULL;
l_msg_data             VARCHAR2(2000) := NULL;
l_data                 VARCHAR2(2000) := NULL;
l_msg_index_out        NUMBER         := NULL;


BEGIN
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.init_err_stack('PAFPCIUB.FP_CI_CHECK_COPY_POSSIBLE');
    END IF;
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    pa_debug.set_process('PLSQL','LOG',l_debug_mode);
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;
    ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_COPY_POSSIBLE - 1');

    IF(p_source_version_type = 'COST') THEN
        l_token_v_type := p_source_version_type;
    ELSIF (p_source_version_type = 'REVENUE') THEN
        l_token_v_type := p_source_version_type;
    ELSE
        l_token_v_type := '';
    END IF;

    IF(p_source_time_phased_code = 'P') THEN
        l_time_phase_code_flag := 'Y';
    ELSIF(p_source_time_phased_code = 'G') then

        l_time_phase_code_flag := 'Y';
    ELSIF(p_source_time_phased_code = 'N') THEN
        l_time_phase_code_flag := 'Y';
    ELSE
        l_time_phase_code_flag := 'N';
    END IF;

        select nvl(baseline_funding_flag ,'N') into
               l_baseline_funding_flag from
        pa_projects_all where
        project_id = p_project_id;

    l_token_ci_id := null;

        begin
           select ci.ci_number,cit.short_name into
           l_ci_number,l_ci_type_name from
           pa_control_items ci,
           pa_ci_types_tl cit
           where ci.ci_id = p_s_ci_id and
                 cit.ci_type_id = ci.ci_type_id and
                 cit.language = userenv('LANG');
       l_token_ci_id := l_ci_type_name;
           if l_ci_number is not null then
              l_token_ci_id := l_token_ci_id ||'('||l_ci_number ||')';
           end if;
        exception
        when no_data_found then
           l_count := 0;
           /* dummy stmt */
        end;

        --Get the column values for the approved plan type and
        --project id combination

        IF (p_multiple_plan_types_flag = 'Y') THEN
        BEGIN

                  -- Get plan_type_id of approved budget plan type

                  SELECT fin_plan_type_id
                  INTO l_ci_aprv_plan_type_id
                  FROM pa_proj_fp_options po
                  WHERE
                        po.project_id = p_project_id
                        AND fin_plan_option_level_code = 'PLAN_TYPE'
                        AND DECODE
                                (p_source_version_type,
                                'COST',po.approved_cost_plan_type_flag,
                                'REVENUE',po.approved_rev_plan_type_flag
                                ) = 'Y';

                 -- Fetch current working approved budget version id
                    Pa_Fp_Control_Items_Utils.CHK_APRV_CUR_WORKING_BV_EXISTS(
                                          p_project_id       => p_project_id,
                                          p_fin_plan_type_id => l_ci_aprv_plan_type_id,
                                          p_version_type     => p_source_version_type,
                                          x_cur_work_bv_id   => l_ci_aprv_cw_bv_id,
                                          x_return_status    => l_return_status,
                                          x_msg_count        => l_msg_count,
                                          x_msg_data         => l_msg_data );

                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;

          SELECT
            DECODE
                (p_source_version_type,
                'COST',po.cost_fin_plan_level_code,
                'REVENUE',po.revenue_fin_plan_level_code,
                'ALL',po.all_fin_plan_level_code
                ),
            DECODE
                (p_source_version_type,
                'COST',po.cost_resource_list_id,
                'REVENUE',po.revenue_resource_list_id,
                'ALL',po.all_resource_list_id
                ),
            DECODE
                (p_source_version_type,
                'COST',po.cost_time_phased_code,
                'REVENUE',po.revenue_time_phased_code,
                'ALL',po.all_time_phased_code
                )
          INTO
            l_target_plan_level_code,
            l_target_resource_list_id,
            l_target_time_phased_code
          FROM pa_proj_fp_options po
          WHERE
            po.project_id           = p_project_id
            AND fin_plan_type_id    = l_ci_aprv_plan_type_id
                        AND fin_plan_version_id = l_ci_aprv_cw_bv_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                PA_UTILS.ADD_MESSAGE
                ( p_app_short_name => 'PA',
                  p_msg_name       => 'PA_FP_CI_NO_PLAN_LVL_DATA_FND');
                x_return_status := FND_API.G_RET_STS_ERROR;
        END;
    ELSE
        BEGIN

                  -- Get plan_type_id of approved budget plan type

                  SELECT fin_plan_type_id
                  INTO l_ci_aprv_plan_type_id
                  FROM pa_proj_fp_options po
                  WHERE
                        po.project_id = p_project_id
                        AND fin_plan_option_level_code = 'PLAN_TYPE'
                        AND ( NVL(po.approved_rev_plan_type_flag,'N') = 'Y'
                                OR NVL(po.approved_cost_plan_type_flag,'N') = 'Y' );

                 /* WHERE clause modified for bug 3043178. if there is only one
                    approved budget plan type the WHERE clause should check for
                    Cost or Revenue approved budget plan type. The Where clasue in
                    the p_multiple_plan_types_flag='Y' will not work for this case. */

                 -- Fetch current working approved budget version id
                    Pa_Fp_Control_Items_Utils.CHK_APRV_CUR_WORKING_BV_EXISTS(
                                          p_project_id       => p_project_id,
                                          p_fin_plan_type_id => l_ci_aprv_plan_type_id,
                                          p_version_type     => p_source_version_type,
                                          x_cur_work_bv_id   => l_ci_aprv_cw_bv_id,
                                          x_return_status    => l_return_status,
                                          x_msg_count        => l_msg_count,
                                          x_msg_data         => l_msg_data );

                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;

          SELECT
            DECODE
                (p_source_version_type,
                'COST',po.cost_fin_plan_level_code,
                'REVENUE',po.revenue_fin_plan_level_code,
                'ALL',po.all_fin_plan_level_code
                ),
            DECODE
                (p_source_version_type,
                'COST',po.cost_resource_list_id,
                'REVENUE',po.revenue_resource_list_id,
                'ALL',po.all_resource_list_id
                ),
            DECODE
                (p_source_version_type,
                'COST',po.cost_time_phased_code,
                'REVENUE',po.revenue_time_phased_code,
                'ALL',po.all_time_phased_code
                )
          INTO
            l_target_plan_level_code,
            l_target_resource_list_id,
            l_target_time_phased_code
          FROM pa_proj_fp_options po
          WHERE
            po.project_id       = p_project_id
            AND fin_plan_type_id    = l_ci_aprv_plan_type_id
                    AND fin_plan_version_id = l_ci_aprv_cw_bv_id;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                PA_UTILS.ADD_MESSAGE
                ( p_app_short_name => 'PA',
                  p_msg_name       => 'PA_FP_CI_NO_PLAN_LVL_DATA_FND');
                ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_COPY_POSSIBLE - 2***');
                x_return_status := FND_API.G_RET_STS_ERROR;
        END;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('l_target_plan_level_code : ' || l_target_plan_level_code);
    --DBMS_OUTPUT.PUT_LINE('p_source_plan_level_code : ' || p_source_plan_level_code);
    --DBMS_OUTPUT.PUT_LINE('p_source_time_phased_code : ' || p_source_time_phased_code);
    --DBMS_OUTPUT.PUT_LINE('l_target_time_phased_code : ' || l_target_time_phased_code);
    --DBMS_OUTPUT.PUT_LINE('p_source_resource_list_id : ' || p_source_resource_list_id);
    --DBMS_OUTPUT.PUT_LINE('l_target_resource_list_id : ' || l_target_resource_list_id);
    --DBMS_OUTPUT.PUT_LINE('l_time_phase_code_flag : ' || l_time_phase_code_flag);
    --DBMS_OUTPUT.PUT_LINE('l_token_v_type : ' || l_token_v_type);
        /* added for bug 2762024  */
         if l_baseline_funding_flag = 'Y' and
           p_source_version_type = 'REVENUE' then
           begin
           /* select po.revenue_fin_plan_level_code,
                  po.revenue_time_phased_code,
                  po.revenue_resource_list_id into
           l_s_bv_fp_level_code,
           l_s_bv_time_phased_code,
           l_s_bv_resource_list_id
           FROM pa_proj_fp_options po,
                pa_budget_versions bv
                  WHERE
                        bv.project_id = p_project_id and
                        bv.ci_id      = p_s_ci_id and
                        bv.version_type = 'REVENUE' and
                        po.project_id = p_project_id and
                        po.fin_plan_option_level_code = 'PLAN_VERSION' and
                        po.fin_plan_version_id = bv.budget_version_id and
                        po.fin_plan_type_id = bv.fin_plan_type_id;
                 the above select is not required as the target values
                 can be directly copied from the source version. */

                l_target_plan_level_code := p_source_plan_level_code;
                l_target_time_phased_code := p_source_time_phased_code;
                l_target_resource_list_id := p_source_resource_list_id;
          exception
          when no_Data_found then
               l_count := 0;
               /* dummy stmt */
          end;
        end if;
        /* added for bug 2762024  */

    IF (
            (p_source_plan_level_code = l_target_plan_level_code AND
             p_source_time_phased_code = l_target_time_phased_code AND
             p_source_resource_list_id = l_target_resource_list_id
            )
                AND
                (l_time_phase_code_flag = 'Y')
        )THEN

            x_copy_possible_flag := 'Y';
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            x_msg_count := FND_MSG_PUB.Count_Msg;
            x_msg_data  := NULL;

    ELSE
        IF (l_time_phase_code_flag = 'N') THEN
            PA_UTILS.ADD_MESSAGE
            ( p_app_short_name => 'PA',
              p_msg_name       => 'PA_FP_CI_C_NO_SP_TIME_PHASE'
            );
        END IF;

        IF (p_source_plan_level_code <> l_target_plan_level_code) THEN
            PA_UTILS.ADD_MESSAGE
            ( p_app_short_name => 'PA',
              p_msg_name       => 'PA_FP_CI_C_INV_PLAN_LVL_MATCH'
            );
        END IF;
        IF (p_source_time_phased_code <> l_target_time_phased_code) THEN
            PA_UTILS.ADD_MESSAGE
            ( p_app_short_name => 'PA',
              p_msg_name       => 'PA_FP_CI_C_TIME_PHASE_DIFF'
            );
        END IF;
        IF (p_source_resource_list_id <> l_target_resource_list_id) THEN
            PA_UTILS.ADD_MESSAGE
            ( p_app_short_name => 'PA',
              p_msg_name       => 'PA_FP_CI_C_RES_LIST_DIFF'
            );
        END IF;
        PA_UTILS.ADD_MESSAGE
            ( p_app_short_name => 'PA',
              p_msg_name       => 'PA_FP_CI_NO_COPY',
              p_token1         => 'CI_ID',
              p_value1         => l_token_ci_id,
              p_token2         => 'CI_VERSION',
              p_value2         => l_token_v_type
            );

            x_copy_possible_flag := 'N';
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            x_msg_count := FND_MSG_PUB.Count_Msg;
            x_msg_data  := NULL;
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
           pa_debug.reset_err_stack;
           RAISE;
    WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg
               ( p_pkg_name       => 'Pa_Fp_Control_Items_Utils.' ||
                'FP_CI_CHECK_COPY_POSSIBLE'
                ,p_procedure_name => PA_DEBUG.G_Err_Stack);
        ----DBMS_OUTPUT.PUT_LINE('FP_CI_CHECK_COPY_POSSIBLE - 3');
            IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.g_err_stage := 'Unexpected error in FP_CI_CHECK_COPY_POSSIBLE';
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
            END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        PA_DEBUG.Reset_Curr_Function;

END FP_CI_CHECK_COPY_POSSIBLE;


/*
   This API returns 'Y' if the financial plan
   copy control item api should be called otherwise
   returns 'N'
   */
PROCEDURE CHECK_FP_PLAN_VERSION_EXISTS
(
     p_project_id        IN NUMBER,
     p_ci_id             IN VARCHAR2,
     x_call_fp_api_flag  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
  IS

-- Local Variable Declaration
      l_debug_mode            VARCHAR2(30);
      l_no_of_bv_versions               NUMBER := 0;

BEGIN
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.init_err_stack('PAFPCIUB.CHECK_FP_PLAN_VERSION_EXISTS');
     END IF;
     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');
     pa_debug.set_process('PLSQL','LOG',l_debug_mode);
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     x_msg_count := 0;

     x_call_fp_api_flag := 'N';
     ----DBMS_OUTPUT.PUT_LINE('CHECK_FP_PLAN_VERSION_EXISTS - 1');
      --Get the number of versions for this control item id
      --and project id

     SELECT
          count(*)
     INTO
          l_no_of_bv_versions
     FROM pa_budget_versions bv
     WHERE bv.project_id = p_project_id
          and bv.ci_id = p_ci_id;

     IF (l_no_of_bv_versions = 0) THEN
          x_call_fp_api_flag := 'N';
          RETURN;
     ELSE
          x_call_fp_api_flag := 'Y';
          RETURN;
     END IF;
EXCEPTION
     WHEN OTHERS THEN
         FND_MSG_PUB.add_exc_msg
                  ( p_pkg_name       => 'Pa_Fp_Control_Items_Utils.' ||
                   'CHECK_FP_PLAN_VERSION_EXISTS'
                   ,p_procedure_name => PA_DEBUG.G_Err_Stack);
         ----DBMS_OUTPUT.PUT_LINE('CHECK_FP_PLAN_VERSION_EXISTS - 3');
            IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.g_err_stage := 'Unexpected error in CHECK_FP_PLAN_VERSION_EXISTS';
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
            END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         PA_DEBUG.Reset_Curr_Function;
         RAISE;
END CHECK_FP_PLAN_VERSION_EXISTS;
-- end of CHECK_FP_PLAN_VERSION_EXISTS

/* Added the following API for bug #2651851. This API is used for Review
   and Submit of Control Items. It takes as input Project Id and Control Item ID.
   While submitting the Change Order this API checks if the Financial Impact
   Plan version has the same Plan Settings as the Current Working Approved Budget.
   If the Plan settings are different, then appropriate error messages are raised. */

PROCEDURE Fp_Ci_Impact_Submit_Chk
          ( p_project_id               IN pa_budget_versions.project_id%TYPE
           ,p_ci_id                    IN pa_budget_versions.ci_id%TYPE
           ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count               OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data                OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

CURSOR cur_ci_version_dtl IS
   SELECT budget_version_id
         ,version_type
         ,fin_plan_type_id
     FROM pa_budget_versions
    WHERE project_id = p_project_id AND
          nvl(ci_id,-1) = p_ci_id;

l_ci_version_id_tbl     PA_PLSQL_DATATYPES.IdTabTyp;
l_version_type_tbl      PA_PLSQL_DATATYPES.Char30TabTyp;
l_fin_plan_type_id_tbl  PA_PLSQL_DATATYPES.IdTabTyp;
l_fp_options_id         pa_proj_fp_options.proj_fp_options_id%TYPE;
l_curr_work_version_id  pa_proj_fp_options.fin_plan_version_id%TYPE;
l_attr_same_flag        VARCHAR2(1);

--Added by Xin Liu. For enhancement.
      l_source_id_tbl  SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();

      l_target_version_id       pa_budget_versions.budget_version_id%TYPE;
      l_source_version_id       pa_budget_versions.budget_version_id%TYPE;
--Done by Xin Liu for enhancement

l_msg_count               NUMBER := 0;
l_data                    VARCHAR2(2000);
l_msg_data                VARCHAR2(2000);
l_msg_index_out           NUMBER;
l_return_status           VARCHAR2(2000);
l_no_of_ci_plan_versions  NUMBER;
l_module_name             VARCHAR2(100) := 'pa.plsql.Pa_Fp_Control_Items_Utils';
l_merge_possible_code_tbl SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();

BEGIN
      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF p_pa_debug_mode = 'Y' THEN
              pa_debug.set_err_stack('Pa_Fp_Control_Items_Utils.Fp_Ci_Impact_Submit_Chk');
              pa_debug.set_process('PLSQL','LOG',p_pa_debug_mode);
      END IF;

      /* Get the details of the CI Budget Versions. */
      OPEN cur_ci_version_dtl;
      FETCH cur_ci_version_dtl BULK COLLECT INTO
             l_ci_version_id_tbl
            ,l_version_type_tbl
            ,l_fin_plan_type_id_tbl;
      CLOSE cur_ci_version_dtl;

      IF nvl(l_ci_version_id_tbl.last,0) < 1 THEN
         /* If there are no budget versions for the CI, throw an error to the user. */

         IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage := 'No Budget Version for the CI';
             pa_debug.write('Fp_Ci_Impact_Submit_Chk: ' || l_module_name,
                               pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
         END IF;
         PA_UTILS.ADD_MESSAGE(p_app_short_name   => 'PA',
                              p_msg_name         => 'PA_FP_CI_VERSION_NOT_FOUND');
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      ELSE

        FOR i in l_ci_version_id_tbl.first..l_ci_version_id_tbl.last
        LOOP

          IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage := 'Fetching the Current Working Version';
              pa_debug.write('Fp_Ci_Impact_Submit_Chk: ' || l_module_name,
                                pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
          END IF;

          -- Bug 3809665 Check if change order versions have any budget lines with
          -- rejection code

          IF 'Y' = pa_fin_plan_utils.does_bv_have_rej_lines
                       (p_budget_version_id => l_ci_version_id_tbl(i))
          THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                  p_msg_name         => 'PA_FP_CI_REJ_LINES_EXST_TO_SUB');
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;


          /* For the Project, Plan Type and Version Type, get the Current Working Version. */
          pa_fin_plan_utils.Get_Curr_Working_Version_Info(
                      p_project_id          => p_project_id
                     ,p_fin_plan_type_id    => l_fin_plan_type_id_tbl(i)
                     ,p_version_type        => l_version_type_tbl(i)
                     ,x_fp_options_id       => l_fp_options_id
                     ,x_fin_plan_version_id => l_curr_work_version_id
                     ,x_return_status       => l_return_status
                     ,x_msg_count           => l_msg_count
                     ,x_msg_data            => l_msg_data);

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.g_err_stage := 'No working version found.';
                   pa_debug.write('Fp_Ci_Impact_Submit_Chk: ' || l_module_name,
                                      pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
               END IF;
               raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;

          /* Compare the Plan settings of the Financial Impact and the plan settings of the
             current working apporved budget plan version. */

          IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage := 'Comparing the Plan Settings of Versions';
              pa_debug.write('Fp_Ci_Impact_Submit_Chk: ' || l_module_name,
                                 pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
          END IF;

          --Added by Xin Liu. For enhancement.

          l_source_version_id := l_ci_version_id_tbl(i);
          l_source_id_tbl.DELETE;
          l_source_id_tbl:= SYSTEM.pa_num_tbl_type();
          l_source_id_tbl.extend(1);
          l_source_id_tbl(1) := l_source_version_id;
          l_target_version_id := l_curr_work_version_id;

          Pa_Fp_Control_Items_Utils.FP_CI_CHECK_MERGE_POSSIBLE(
                    p_project_id                  => p_project_id,
                    p_source_fp_version_id_tbl    => l_source_id_tbl,
                    p_target_fp_version_id        => l_target_version_id,
                    p_calling_mode                => 'SUBMIT',
                    x_merge_possible_code_tbl     => l_merge_possible_code_tbl,
                    x_return_status               => l_return_status,
                    x_msg_count                   => x_msg_count,
                    x_msg_data                    => x_msg_data
          );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               x_return_status := l_return_status ;
          END IF; -- l_return_status <> FND_API.G_RET_STS_SUCCESS

       END LOOP;

      END IF; -- nvl(l_ci_version_id_tbl.last,0) < 1

      IF p_pa_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Exiting Fp_Ci_Impact_Submit_Chk';
           pa_debug.write('Fp_Ci_Impact_Submit_Chk: ' ||l_module_name,pa_debug.g_err_stage,
                                         PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
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
        /* #2723909: Returning to the calling procedure instead of raising it,
           so that the calling procedure checks for the return status of this procedure
           and handles it appropriately. */
           RETURN;
    WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg
                          ( p_pkg_name        => 'Pa_Fp_Control_Items_Utils'
                           ,p_procedure_name  => 'Fp_Ci_Impact_Submit_Chk'
                           ,p_error_text      => x_msg_data);

          IF p_pa_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
              pa_debug.write('Fp_Ci_Impact_Submit_Chk: ' ||l_module_name,pa_debug.g_err_stage,
                                     PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
              pa_debug.reset_err_stack;
          END IF;
          RAISE;
END Fp_Ci_Impact_Submit_Chk;

/*==================================================================
   This api Identifies whether the impact can be updated to implemented
   or not. Included for bug 2681589.
 ==================================================================*/
--Bug 3550073. Included x_upd_cost_impact_allowed and x_upd_rev_impact_allowed
PROCEDURE FP_CI_VALIDATE_UPDATE_IMPACT
  (
       p_project_id                  IN  pa_budget_versions.project_id%TYPE,
       p_ci_id                       IN  pa_control_items.ci_id%TYPE,
       p_source_version_id           IN  pa_budget_versions.budget_version_id%TYPE,
       p_target_version_id           IN  pa_budget_versions.budget_version_id%TYPE,
       x_upd_cost_impact_allowed     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_upd_rev_impact_allowed      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_msg_data                    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_msg_count                   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_return_status               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
AS

l_msg_count             NUMBER := 0;
l_data                  VARCHAR2(2000);
l_msg_data              VARCHAR2(2000);
l_msg_index_out         NUMBER;
l_debug_mode            VARCHAR2(1);

l_approved_cost_flag    pa_budget_versions.approved_cost_plan_type_flag%TYPE;
l_approved_rev_flag     pa_budget_versions.approved_rev_plan_type_flag%TYPE;
l_ci_id                 pa_budget_versions.ci_id%TYPE;
l_second_bv_id          pa_budget_versions.budget_version_id%TYPE;

l_count                 NUMBER := 0;
l_merged_count          NUMBER := 0;
l_module_name           VARCHAR2(100) := 'pa.plsql.Pa_Fp_Control_Items_Utils';

CURSOR c_upd_impact_val_csr
     (c_ci_id        pa_control_items.ci_id%TYPE,
      c_version_type pa_fp_merged_ctrl_items.version_type%TYPE)
IS
    SELECT 'Y'
    FROM   pa_fp_merged_ctrl_items
    WHERE  ci_id =c_ci_id
    AND    project_id=p_project_id
    AND    plan_version_id=p_target_version_id
    AND    ci_plan_version_id=NVL(p_source_version_id,ci_plan_version_id)
    AND    version_type=c_version_type;

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_debug_mode := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
      IF l_debug_mode = 'Y' THEN
              pa_debug.set_err_stack('Pa_Fp_Control_Items_Utils.FP_CI_VALIDATE_UPDATE_IMPACT');
              pa_debug.set_process('PLSQL','LOG',l_debug_mode);
      END IF;

      -- Check for business rules violations

      IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Validating input parameters';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                         PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      IF (p_project_id IS NULL) OR (p_ci_id IS NULL AND p_source_version_id IS NULL)
         OR (p_target_version_id is NULL)
      THEN
              IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'p_project_id = '|| to_char(p_project_id);
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                                 PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        pa_debug.g_err_stage:= 'p_source_version_id = '|| to_char(p_source_version_id);
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                                 PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        pa_debug.g_err_stage:= 'p_target_version_id = '|| to_char(p_target_version_id);
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                                 PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        pa_debug.g_err_stage:= 'p_ci_id = '|| to_char(p_ci_id);
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
              END IF;
              PA_UTILS.ADD_MESSAGE
                      (p_app_short_name => 'PA',
                        p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

     SELECT  NVL(approved_cost_plan_type_flag,'N'),
          NVL(approved_rev_plan_type_flag,'N')
     INTO
           l_approved_cost_flag,
           l_approved_rev_flag
     FROM  pa_budget_versions
     WHERE budget_version_id = p_target_version_id
     AND   project_id = p_project_id;

     x_upd_cost_impact_allowed:='N';
     x_upd_rev_impact_allowed:='N';

     IF(l_approved_cost_flag = 'Y' OR l_approved_rev_flag = 'Y') THEN
          IF p_ci_id IS NULL THEN
            SELECT ci_id
            INTO   l_ci_id
            FROM   pa_budget_versions
            WHERE  budget_version_id = p_source_version_id
            AND    project_id = p_project_id;
          ELSE
                  l_ci_id:=p_ci_id;
          END IF;

          IF l_approved_cost_flag = 'Y' THEN

                OPEN c_upd_impact_val_csr(l_ci_id,'COST');
                FETCH c_upd_impact_val_csr INTO x_upd_cost_impact_allowed;
                IF c_upd_impact_val_csr%NOTFOUND THEN

                    x_upd_cost_impact_allowed:='N';

                END IF;
                CLOSE c_upd_impact_val_csr;

          END IF;

           IF l_approved_rev_flag = 'Y' THEN

                OPEN c_upd_impact_val_csr(l_ci_id,'REVENUE');
                FETCH c_upd_impact_val_csr INTO x_upd_rev_impact_allowed;
                IF c_upd_impact_val_csr%NOTFOUND THEN

                    x_upd_rev_impact_allowed:='N';

                END IF;
                CLOSE c_upd_impact_val_csr;

          END IF;

     END IF; --end if for approved revenue and cost flag check


     IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'x_upd_cost_impact_allowed is '||x_upd_cost_impact_allowed
                         ||'x_upd_rev_impact_allowed    is '||x_upd_rev_impact_allowed;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                          PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
               pa_debug.g_err_stage:= 'Exiting FP_CI_VALIDATE_UPDATE_IMPACT';
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
           RAISE;

   WHEN others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          FND_MSG_PUB.add_exc_msg
                          ( p_pkg_name        => 'Pa_Fp_Control_Items_Utils'
                           ,p_procedure_name  => 'FP_CI_VALIDATE_UPDATE_IMPACT'
                           ,p_error_text      => x_msg_data);

          IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
              pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                     PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
              pa_debug.reset_err_stack;

          END IF;
          RAISE;

END FP_CI_VALIDATE_UPDATE_IMPACT;

procedure chk_res_resgrp_mismatch(
            p_project_id in number,
            p_s_budget_version_id           IN pa_budget_versions.budget_version_id%TYPE,
            p_s_fin_plan_level_code         IN pa_proj_fp_options.all_fin_plan_level_code%TYPE,
            p_t_budget_version_id           IN pa_budget_versions.budget_version_id%TYPE,
            p_t_fin_plan_level_code         IN pa_proj_fp_options.all_fin_plan_level_code%TYPE,
            p_calling_mode                  in varchar2,
            x_res_resgr_mismatch_flag       OUT NOCOPY varchar2, --File.Sql.39 bug 4440895
          x_msg_data                    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count                   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_return_status               OUT NOCOPY VARCHAR2  ) IS --File.Sql.39 bug 4440895
   l_count number;
   cursor c1(c_fp_opt_id number,
             c_ver_type varchar2) is
             select fpe.task_id,
                    fpe.top_task_id,
                    t.task_name task_name,
                    t.task_number task_number,
                    fpe.resource_planning_level,
             PA_PROJ_ELEMENTS_UTILS.GET_DISPLAY_SEQUENCE(fpe.task_id)
                                       seq_no,
                    nvl(fpe.top_task_planning_level,'LOWEST')
                       top_task_planning_level
             from
                 pa_fp_elements fpe,
                 pa_tasks t where
                 fpe.proj_fp_options_id = c_fp_opt_id and
                 fpe.element_type = c_ver_type and
                 fpe.task_id = t.task_id and
                 fpe.resource_list_member_id = 0 and
                 fpe.plannable_flag = 'Y'
                 order by seq_no;
                 /* nvl(fpe.plan_amount_exists_flag,'N') = 'Y'
                 the merge api does not support this check right now */

   l_source_plan_level varchar2(1);
   l_target_plan_level varchar2(1);
   l_error_msg_header_flag varchar2(1);
   l_message_code varchar2(100);
   l_target_task_id number;
   l_target_task_name pa_tasks.TASK_NAME%type;
   l_target_task_number pa_tasks.TASK_NUMBER%type;
   l_prj_rlm_id NUMBER;
   l_prj_rlm_id_target NUMBER;
   l_target_prj_plan_level varchar2(1);
   l_source_fp_opt_id NUMBER;
   l_target_fp_opt_id NUMBER;
   l_source_ver_type pa_budget_versions.version_type%type;
   l_target_ver_type pa_budget_versions.version_type%type;
   l_top_task_plan_level pa_fp_elements.top_task_planning_level%type;
BEGIN
  l_count := 0;
  x_msg_count := 0;
  l_error_msg_header_flag   := 'N';
  x_res_resgr_mismatch_flag := 'N';
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  select o.proj_fp_options_id,
         bv.version_type  into
         l_source_fp_opt_id,
         l_source_ver_type
  from pa_proj_fp_options o,
       pa_budget_versions bv
  where
       bv.budget_version_id = p_s_budget_version_id and
       bv.fin_plan_type_id  = o.fin_plan_type_id  and
       o.project_id         = p_project_id and
       o.fin_plan_version_id = bv.budget_version_id;


  select o.proj_fp_options_id ,
         bv.version_type  into
         l_target_fp_opt_id,
         l_target_ver_type
  from pa_proj_fp_options o,
       pa_budget_versions bv
  where
       bv.budget_version_id = p_t_budget_version_id and
       bv.fin_plan_type_id  = o.fin_plan_type_id  and
       o.project_id         = p_project_id and
       o.fin_plan_version_id = bv.budget_version_id;

  /*
  Resource planning level source    Resource planning level target  Merge
                                                                    Possible
  ==========================================================================
  Resource                          Resource                        Yes
  Resource Group                    Resource Group                  Yes
  Resource                          Resource Group                  Yes
  Resource Group                    Resource                        No
  ==========================================================================
  */
  /* checking for if source and target versions are planning at the
         project level */

  if  p_s_fin_plan_level_code = 'P' and
      p_t_fin_plan_level_code = 'P' then
      l_source_plan_level := 'R';
      l_target_plan_level := 'R';
          l_prj_rlm_id := null;
          begin
             select ra.resource_list_member_id into l_prj_rlm_id from
             pa_resource_assignments ra
             where
             ra.budget_version_id = p_s_budget_version_id and
             nvl(ra.resource_assignment_type,'USER_ENTERED') =
              'USER_ENTERED' and
             rownum < 2;
          exception
          when no_data_found then
             l_prj_rlm_id := null;
          end;
          if nvl(l_prj_rlm_id,0) > 0 then
             select decode(parent_member_id,null,'G','R') into
             l_source_plan_level  from pa_resource_list_members
             where resource_list_member_id = l_prj_rlm_id;
          end if;
          /* checking for target */
          l_prj_rlm_id := null;
          begin
             select ra.resource_list_member_id into l_prj_rlm_id from
             pa_resource_assignments ra
             where
             ra.budget_version_id = p_t_budget_version_id and
             nvl(ra.resource_assignment_type,'USER_ENTERED') =
              'USER_ENTERED' and
             rownum < 2;
          exception
          when no_data_found then
             l_prj_rlm_id := null;
          end;
          if nvl(l_prj_rlm_id,0) > 0 then
             select decode(parent_member_id,null,'G','R') into
             l_target_plan_level  from pa_resource_list_members
             where resource_list_member_id = l_prj_rlm_id;
          end if;
          if l_source_plan_level = 'G' and
             l_target_plan_level = 'R' then
             x_return_status := FND_API.G_RET_STS_ERROR;

            if p_calling_mode = 'INCLUDE_CR_TO_CO' then
               l_message_code := 'PA_FP_CI_C_INVP_RES_TO_RES_GRP';
            elsif p_calling_mode = 'INCLUDE' then
               l_message_code := 'PA_FP_CI_INVP_RES_TO_RES_GRP';
            elsif p_calling_mode = 'IMPLEMENT' then
               l_message_code := 'PA_FP_CIM_INVP_RES_TO_RES_GRP';
            elsif p_calling_mode = 'SUBMIT' then
               l_message_code := 'PA_FP_CIS_INVP_RES_TO_RES_GRP';
             end if;
             PA_UTILS.ADD_MESSAGE
                      ( p_app_short_name => 'PA',
                        p_msg_name       => l_message_code );

          elsif l_source_plan_level = 'R' AND
                l_target_plan_level = 'G' THEN
             x_res_resgr_mismatch_flag := 'Y';
          end if;
      RETURN;
  end if;

  /* the following logic takes care of the check source version is
     any planning level other than project and target is any
     planning level. */
  l_target_prj_plan_level := NULL;

  if p_t_fin_plan_level_code = 'P' then
          l_prj_rlm_id := null;
          begin
             select ra.resource_list_member_id into l_prj_rlm_id from
             pa_resource_assignments ra
             where
             ra.budget_version_id = p_t_budget_version_id and
             nvl(ra.resource_assignment_type,'USER_ENTERED') =
              'USER_ENTERED' and
             rownum < 2;
          exception
          when no_data_found then
             l_prj_rlm_id := null;
          end;
          if nvl(l_prj_rlm_id,0) > 0 then
             select decode(parent_member_id,null,'G','R') into
             l_target_prj_plan_level  from pa_resource_list_members
             where resource_list_member_id = l_prj_rlm_id;
          end if;
  end if;

  for c1_rec in c1(l_source_fp_opt_id,
                   l_source_ver_type )  loop
      l_target_task_id := 0;
      if p_t_fin_plan_level_code = 'L' THEN
         l_target_task_id := c1_rec.task_id; /* Bug 2757823 - For this case the p_t_fin_plan_level_code can only be L */
      elsif p_t_fin_plan_level_code = 'T' THEN
         l_target_task_id := c1_rec.top_task_id;
      elsif p_t_fin_plan_level_code = 'P' THEN
         l_target_task_id := 0;
      /* bug 2672708  fix starts */
      elsif p_t_fin_plan_level_code = 'M' THEN
          if c1_rec.top_task_planning_level = 'TOP' then
             l_target_task_id := c1_rec.top_task_id;
          elsif c1_rec.top_task_planning_level = 'LOWEST' and
                c1_rec.task_id = c1_rec.top_task_id then
                /* this case occurs if the node is a top task and it
                   does not have any child tasks */
             l_target_task_id := c1_rec.top_task_id;
          elsif c1_rec.top_task_planning_level = 'LOWEST' and
                c1_rec.task_id <> c1_rec.top_task_id then
                 begin
                   select nvl(fpe.top_task_planning_level,'LOWEST')
                          into l_top_task_plan_level
                   from pa_fp_elements fpe
                   where
                           fpe.proj_fp_options_id = l_target_fp_opt_id and
                           fpe.element_type = l_target_ver_type and
                           fpe.task_id = c1_rec.task_id and
                           fpe.resource_list_member_id = 0 and
                           fpe.plannable_flag = 'Y';
                   l_target_task_id := c1_rec.task_id;
                 exception
                 when no_data_found then
                    /* checking for whether the top task is planned in the
                       target */
                    begin
                        select nvl(fpe.top_task_planning_level,'LOWEST')
                               into l_top_task_plan_level
                        from pa_fp_elements fpe
                        where
                                fpe.proj_fp_options_id = l_target_fp_opt_id and
                                fpe.element_type = l_target_ver_type and
                                fpe.task_id = c1_rec.top_task_id and
                                fpe.resource_list_member_id = 0 and
                                fpe.plannable_flag = 'Y';
                          l_target_task_id := c1_rec.top_task_id;
                    exception
                    when no_data_found then
                         l_target_task_id := c1_rec.task_id;
                    end;
                 end;
                 /* bug 2672708  fix starts */
          end if;
      end if;
      l_source_plan_level := 'R';
      l_target_plan_level := 'R';

      l_target_task_name := NULL;
      l_target_task_number := NULL;

      if l_target_task_id > 0  then
         begin
            select task_name,task_number into
                l_target_task_name,
                l_target_task_number
            from pa_Tasks where task_id = l_target_task_id;
         exception
         when no_data_found then
            l_target_task_name := NULL;
            l_target_task_number := NULL;
         end;

      end if;

      l_source_plan_level := c1_rec.resource_planning_level;


     /* Bug 2757823 - Res grp mismatch should be done for the following cases also
           1. when source plan level is L and target plan level is L
           1. when source plan level is T and target plan level is T  */
                 /* bug 2672708  source M and target M check added */

     if (  p_s_fin_plan_level_code = 'L' and p_t_fin_plan_level_code = 'T' ) OR
        (  p_s_fin_plan_level_code = 'M' and p_t_fin_plan_level_code = 'T' ) OR
        (  p_s_fin_plan_level_code = 'M' and p_t_fin_plan_level_code = 'L' ) OR
        (  p_s_fin_plan_level_code = 'L' and p_t_fin_plan_level_code = 'L' ) OR
        (  p_s_fin_plan_level_code = 'M' and p_t_fin_plan_level_code = 'M' ) OR
        (  p_s_fin_plan_level_code = 'L' and p_t_fin_plan_level_code = 'M' ) OR
        (  p_s_fin_plan_level_code = 'T' and p_t_fin_plan_level_code = 'M' ) OR
        (  p_s_fin_plan_level_code = 'T' and p_t_fin_plan_level_code = 'T' ) then
        begin
             select resource_planning_level into l_target_plan_level
             from   pa_fp_elements
             where  proj_fp_options_id = l_target_fp_opt_id
             and    element_type = l_target_ver_type
             and    resource_list_member_id = 0
             and    plannable_flag = 'Y'
             and    task_id = l_target_task_id;
             exception
             when no_Data_found then
                l_target_plan_level := l_source_plan_level;
             end;
     elsif p_t_fin_plan_level_code = 'P' then
             l_target_plan_level := l_target_prj_plan_level;
     end if;
  if l_target_plan_level is null then
     l_target_plan_level := l_source_plan_level;
  end if;

  if l_source_plan_level = 'G' AND
     l_target_plan_level = 'R' THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     if l_error_msg_header_flag  = 'N' then
        x_res_resgr_mismatch_flag := 'Y';
        l_error_msg_header_flag  := 'Y';
        if
            (  p_s_fin_plan_level_code = 'L' and p_t_fin_plan_level_code = 'L' ) OR
            (  p_s_fin_plan_level_code = 'T' and p_t_fin_plan_level_code = 'T' ) OR
            (  p_s_fin_plan_level_code = 'M' and p_t_fin_plan_level_code = 'M' ) OR
            (  p_s_fin_plan_level_code = 'L' and p_t_fin_plan_level_code = 'M' ) OR
            (  p_s_fin_plan_level_code = 'T' and p_t_fin_plan_level_code = 'M' ) OR
            (  p_s_fin_plan_level_code = 'M' and p_t_fin_plan_level_code = 'L' ) OR
            (  p_s_fin_plan_level_code = 'M' and p_t_fin_plan_level_code = 'T' ) OR
            (  p_s_fin_plan_level_code in ( 'T','L','M') and p_t_fin_plan_level_code = 'P' ) THEN
            if p_calling_mode = 'INCLUDE_CR_TO_CO' then
               l_message_code := 'PA_FP_CI_C_INV_RES_TO_RES_GRP';
            elsif p_calling_mode = 'INCLUDE' then
               l_message_code := 'PA_FP_CI_INV_RES_TO_RES_GRP';
            elsif p_calling_mode = 'IMPLEMENT' then
               l_message_code := 'PA_FP_CIM_INV_RES_TO_RES_GRP';
            elsif p_calling_mode = 'SUBMIT' then
               l_message_code := 'PA_FP_CIS_INV_RES_TO_RES_GRP';
             end if;
             PA_UTILS.ADD_MESSAGE
                      ( p_app_short_name => 'PA',
                        p_msg_name       => l_message_code );

        elsif p_s_fin_plan_level_code <> 'P' and p_t_fin_plan_level_code <> 'P' then
            /* same as above, copied just for readability */
            if p_calling_mode = 'INCLUDE_CR_TO_CO' then
               l_message_code := 'PA_FP_CI_C_INV_RES_TO_RES_GRP';
            elsif p_calling_mode = 'INCLUDE' then
               l_message_code := 'PA_FP_CI_INV_RES_TO_RES_GRP';
            elsif p_calling_mode = 'IMPLEMENT' then
               l_message_code := 'PA_FP_CIM_INV_RES_TO_RES_GRP';
             end if;
             PA_UTILS.ADD_MESSAGE
                      ( p_app_short_name => 'PA',
                        p_msg_name     => l_message_code );
        end if;
     end if;
     /* end if error msg header */
     if
       (  p_s_fin_plan_level_code = 'L' and p_t_fin_plan_level_code = 'L' ) OR
       (  p_s_fin_plan_level_code = 'T' and p_t_fin_plan_level_code = 'T' ) OR
       (  p_s_fin_plan_level_code in ( 'T','L','M') and p_t_fin_plan_level_code = 'P' ) THEN
             PA_UTILS.ADD_MESSAGE
                        ( p_app_short_name => 'PA',
                        p_msg_name     => 'PA_FP_CI_INV_S_TASK_DATA',
                        p_token1       => 'TASK_NAME',
                        p_value1       => c1_rec.task_name,
                        p_token2       => 'TASK_NO',
                        p_value2       => c1_rec.task_number );

     elsif p_s_fin_plan_level_code <> 'P' and p_t_fin_plan_level_code <> 'P' then
          IF   c1_rec.task_id = l_target_task_id THEN
             PA_UTILS.ADD_MESSAGE
                        ( p_app_short_name => 'PA',
                        p_msg_name     => 'PA_FP_CI_INV_S_TASK_DATA',
                        p_token1       => 'TASK_NAME',
                        p_value1       => c1_rec.task_name,
                        p_token2       => 'TASK_NO',
                        p_value2       => c1_rec.task_number );
          ELSE
               PA_UTILS.ADD_MESSAGE
                        ( p_app_short_name => 'PA',
                        p_msg_name     => 'PA_FP_CI_INV_ST_TASK_DATA',
                        p_token1       => 'S_TASK_NAME',
                        p_value1       => c1_rec.task_name,
                        p_token2       => 'S_TASK_NO',
                        p_value2       => c1_rec.task_number,
                        p_token3       => 'T_TASK_NAME',
                        p_value3       => l_target_task_name,
                        p_token4       => 'T_TASK_NO',
                        p_value4       => l_target_task_number );
         END IF;
     end if;
     /* end if for populating the acutal error msg  */
     elsif l_source_plan_level = 'R' AND
           l_target_plan_level = 'G' THEN
        x_res_resgr_mismatch_flag := 'Y';
     END IF;

  end loop;

EXCEPTION
  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'Pa_Fp_Control_Items_Utils',
                            p_procedure_name => 'chk_res_resgrp_mismatch',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

END chk_res_resgrp_mismatch;

procedure chk_tsk_plan_level_mismatch(
            p_project_id in number,
            p_s_budget_version_id           IN pa_budget_versions.budget_version_id%TYPE,
            p_t_budget_version_id           IN pa_budget_versions.budget_version_id%TYPE,
            p_calling_mode                  in varchar2,
            x_tsk_plan_level_mismatch      OUT NOCOPY varchar2, --File.Sql.39 bug 4440895
            x_s_task_id_tbl        OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
            x_t_task_id_tbl        OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
            x_s_fin_plan_level_tbl OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
            x_t_fin_plan_level_tbl OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
          x_msg_data                    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count                   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_return_status               OUT NOCOPY VARCHAR2  ) IS --File.Sql.39 bug 4440895
   l_count number;
   l_error_msg_header_flag VARCHAR2(1);
   cursor c1(c_fp_opt_id number,
             c_ver_type varchar2) is
             select fpe.task_id task_id,
                    fpe.top_task_id top_task_id,
                    t.task_name task_name,
                    t.task_number task_number,
                    fpe.resource_planning_level resource_planning_level,
             PA_PROJ_ELEMENTS_UTILS.GET_DISPLAY_SEQUENCE(fpe.task_id)
                                       seq_no,
                    NVL(fpe.top_task_planning_level,'LOWEST')
                            top_task_planning_level
             from
                 pa_fp_elements fpe,
                 pa_tasks t where
                 fpe.proj_fp_options_id = c_fp_opt_id and
                 fpe.element_type = c_ver_type and
                 fpe.task_id = t.task_id and
                 fpe.resource_list_member_id = 0 and
                 fpe.plannable_flag = 'Y'
                 order by seq_no;
                 /*  the merge api does not support this check right now.
                    nvl(fpe.plan_amount_exists_flag,'N') = 'Y'  */
                 /* the merge api needs all the distinct task
                 combination to be processed,so the following check
                 has been removed from the cursor
                 NVL(fpe.top_task_planning_level,'LOWEST') = 'TOP'   */
   l_message_code varchar2(100);
   l_target_task_id number;
   l_target_task_name pa_tasks.TASK_NAME%type;
   l_target_task_number pa_tasks.TASK_NUMBER%type;
   l_prj_rlm_id NUMBER;
   l_prj_rlm_id_target NUMBER;
   l_target_prj_plan_level varchar2(1);
   l_source_fp_opt_id NUMBER;
   l_target_fp_opt_id NUMBER;
   l_source_ver_type pa_budget_versions.version_type%type;
   l_target_ver_type pa_budget_versions.version_type%type;
   l_top_task_plan_level pa_fp_elements.top_task_planning_level%type;
   l_source_task_id number;
   l_source_plan_level varchar2(30);
   l_target_plan_level varchar2(30);
   l_index number;
   l_task_exists_Flag varchar2(1);
BEGIN
   l_count := 0;
   x_msg_count := 0;
   l_error_msg_header_flag   := 'N';
   x_tsk_plan_level_mismatch := 'N';
   l_index := 1;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF P_PA_DEBUG_MODE = 'Y' THEN
      PA_DEBUG.init_err_stack('PA_FP_CI_IMPLEMENT_PKG.implement_change_order');
   END IF;

   IF p_pa_debug_mode = 'Y' THEN
         PA_DEBUG.write_log (x_module      =>
                           'pa.plsql.Pa_Fp_Control_Items_Utils.chk_tsk_plan_level_mismatch'
                     ,x_msg         => 'selecting source version fp option details'
                     ,x_log_level   => 5);
   END IF;

   select o.proj_fp_options_id,
         bv.version_type  into
         l_source_fp_opt_id,
         l_source_ver_type
   from pa_proj_fp_options o,
       pa_budget_versions bv
   where
       bv.budget_version_id = p_s_budget_version_id and
       bv.fin_plan_type_id  = o.fin_plan_type_id  and
       o.project_id         = p_project_id and
       o.fin_plan_version_id = bv.budget_version_id;

   IF p_pa_debug_mode = 'Y' THEN
         PA_DEBUG.write_log (x_module      =>
                           'pa.plsql.Pa_Fp_Control_Items_Utils.chk_tsk_plan_level_mismatch'
                     ,x_msg         => 'selecting target version fp option details'
                     ,x_log_level   => 5);
   END IF;

  select o.proj_fp_options_id ,
         bv.version_type  into
         l_target_fp_opt_id,
         l_target_ver_type
  from pa_proj_fp_options o,
       pa_budget_versions bv
  where
       bv.budget_version_id = p_t_budget_version_id and
       bv.fin_plan_type_id  = o.fin_plan_type_id  and
       o.project_id         = p_project_id and
       o.fin_plan_version_id = bv.budget_version_id;

   FOR tsk_rec IN  c1(l_source_fp_opt_id,
                      l_source_ver_type) LOOP
       /* checking for the same task is planned in the
          target */
       l_source_task_id := tsk_rec.task_id;
       l_source_plan_level := tsk_rec.top_task_planning_level;

       begin
         IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.write_log (x_module      =>
                           'pa.plsql.Pa_Fp_Control_Items_Utils.chk_tsk_plan_level_mismatch'
             ,x_msg         => 'checking for the same task is planned in the target'
                     ,x_log_level   => 5);
         END IF;
         select nvl(fpe.top_task_planning_level,'LOWEST')
                into l_top_task_plan_level
         from pa_fp_elements fpe
         where
                 fpe.proj_fp_options_id = l_target_fp_opt_id and
                 fpe.element_type = l_target_ver_type and
                 fpe.task_id = tsk_rec.task_id and
                 fpe.resource_list_member_id = 0 and
                 fpe.plannable_flag = 'Y';
         l_target_task_id := tsk_rec.task_id;
         l_target_plan_level := l_top_task_plan_level;
       exception
       when no_data_found then
          /* checking for whether the top task is planned in the
             target */
          begin
              IF p_pa_debug_mode = 'Y' THEN
                 PA_DEBUG.write_log (x_module      =>
                           'pa.plsql.Pa_Fp_Control_Items_Utils.chk_tsk_plan_level_mismatch'
             ,x_msg => 'checking for whether the top task is planned in the target'
                     ,x_log_level   => 5);
              END IF;
              select nvl(fpe.top_task_planning_level,'LOWEST')
                     into l_top_task_plan_level
              from pa_fp_elements fpe
              where
                      fpe.proj_fp_options_id = l_target_fp_opt_id and
                      fpe.element_type = l_target_ver_type and
                      fpe.task_id = tsk_rec.top_task_id and
                      fpe.resource_list_member_id = 0 and
                      fpe.plannable_flag = 'Y';
                l_target_task_id := tsk_rec.top_task_id;
                l_target_plan_level := l_top_task_plan_level;
          exception
          when no_data_found then
               if l_source_plan_level = 'TOP' then
                  /* checking for whether the top task in the source version
                     is planned at the lowest task level in   target version */
                  begin
                      IF p_pa_debug_mode = 'Y' THEN
                         PA_DEBUG.write_log (x_module      =>
                         'pa.plsql.Pa_Fp_Control_Items_Utils.chk_tsk_plan_level_mismatch'
                        ,x_msg => 'checking for source - top task and target - lowest task'
                        ,x_log_level   => 5);
                      END IF;
                      select nvl(fpe.top_task_planning_level,'LOWEST')
                      into l_top_task_plan_level
                      from pa_fp_elements fpe
                      where
                      fpe.proj_fp_options_id = l_target_fp_opt_id and
                      fpe.element_type = l_target_ver_type and
                      fpe.task_id = tsk_rec.top_task_id and
                      fpe.resource_list_member_id = 0;
                      l_target_plan_level := l_top_task_plan_level;
                      l_target_task_id := 0;
                      /* the above target task id is a dummy assignment stmt and
                         not being used anywhere in the processing. Because,
                         the API will raise the error */
                  exception
                  when no_data_found then
                     l_target_task_id := tsk_rec.task_id;
                     l_target_plan_level :=  tsk_rec.top_task_planning_level;
                  end;
               else
                  l_target_task_id := tsk_rec.task_id;
                  l_target_plan_level :=  tsk_rec.top_task_planning_level;
               end if;
          end;
       end;

       if l_source_plan_level = 'TOP' and
          l_target_plan_level = 'LOWEST' then
          IF p_pa_debug_mode = 'Y' THEN
              PA_DEBUG.write_log (x_module      =>
               'pa.plsql.Pa_Fp_Control_Items_Utils.chk_tsk_plan_level_mismatch'
               ,x_msg => 'getting the task info from pa_tasks table'
               ,x_log_level   => 5);
          END IF;
          begin
            select task_name,task_number into
                l_target_task_name,
                l_target_task_number
            from pa_Tasks where task_id = tsk_rec.task_id;
         exception
         when no_data_found then
            l_target_task_name := NULL;
            l_target_task_number := NULL;
         end;

          if l_error_msg_header_flag = 'N' then
             x_return_status := FND_API.G_RET_STS_ERROR;
             l_error_msg_header_flag  := 'Y';
             if p_calling_mode = 'INCLUDE_CR_TO_CO' then
                l_message_code := 'PA_FP_CI_C_INV_TSK_LVL';
             elsif p_calling_mode = 'INCLUDE' then
                l_message_code := 'PA_FP_CI_INV_TSK_LVL';
             elsif p_calling_mode = 'IMPLEMENT' then
                l_message_code := 'PA_FP_CIM_INV_TSK_LVL';
             elsif p_calling_mode = 'SUBMIT' then
                l_message_code := 'PA_FP_CIS_INV_TSK_LVL';

             end if;
             PA_UTILS.ADD_MESSAGE
                      ( p_app_short_name => 'PA',
                        p_msg_name       => l_message_code );

          end if;    /* error msg header flag check */
             PA_UTILS.ADD_MESSAGE
                      ( p_app_short_name => 'PA',
                        p_msg_name     => 'PA_FP_CI_INV_S_TASK_DATA',
                        p_token1       => 'TASK_NAME',
                        p_value1       => l_target_task_name,
                        p_token2       => 'TASK_NO',
                        p_value2       => l_target_task_number );
       else
               /* merge possible for the following task planning level
                  Source           Target
                  =======          ======
                  Lowest           Lowest
                  Top              Top
                  Lowest           Top
               */
               IF p_pa_debug_mode = 'Y' THEN
                  PA_DEBUG.write_log (x_module      =>
                 'pa.plsql.Pa_Fp_Control_Items_Utils.chk_tsk_plan_level_mismatch'
                  ,x_msg => 'populating the pl sql table for source and target task'
                 ,x_log_level   => 5);
               END IF;
               l_task_exists_Flag := 'N';
               for  chk in 1 .. x_s_task_id_tbl.count loop
                   if x_s_task_id_tbl(chk) = l_source_task_id AND
                      x_t_task_id_tbl(chk) = l_target_task_id then
                      l_task_exists_Flag := 'Y';
                      exit;
                   end if;
               end loop;
               if l_task_exists_Flag = 'N' then
                  x_s_task_id_tbl(l_index)  := l_source_task_id;
                  x_t_task_id_tbl(l_index)  := l_target_task_id;
                  x_s_fin_plan_level_tbl(l_index) := l_source_plan_level;
                  x_t_fin_plan_level_tbl(l_index) := l_target_plan_level;
                  l_index := l_index + 1;
               end if;
       end if;    /* end if for top and lowest check */
   END LOOP;
   IF p_pa_debug_mode = 'Y' THEN
      PA_DEBUG.Reset_Err_Stack;
   END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF p_pa_debug_mode = 'Y' THEN
      PA_DEBUG.Reset_Err_Stack;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'Pa_Fp_Control_Items_Utils',
                            p_procedure_name => 'chk_tsk_plan_level_mismatch',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END chk_tsk_plan_level_mismatch;

/* dbora - FP M - New function to check for valid status
   smullapp-Changed NON_APP_STATUSES_EXIST to add p_fin_plan_type_id as input parameter(bug 3899756)
*/
FUNCTION NON_APP_STATUSES_EXIST (
      p_ci_type_id                   IN       pa_pt_co_impl_statuses.ci_type_id%TYPE,
      p_version_type                 IN       pa_pt_co_impl_statuses.version_type%TYPE,
      p_fin_plan_type_id             IN       pa_pt_co_impl_statuses.fin_plan_type_id%TYPE)
      RETURN  VARCHAR2
IS
      l_return                      VARCHAR2(1);

      l_debug_mode                  VARCHAR2(1);
      l_debug_level3                CONSTANT NUMBER := 3;
      l_module_name                 VARCHAR2(100) := 'NON_APP_STATUSES_EXIST' ;

BEGIN

      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

      IF l_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function   => 'NON_APP_STATUSES_EXIST',
                                        p_debug_mode => l_debug_mode );
      END IF;

      BEGIN
            SELECT  'Y'
            INTO    l_return
            FROM    dual
            WHERE
            EXISTS  (SELECT  'X'
                     FROM     pa_pt_co_impl_statuses ptco,
                              pa_ci_statuses_v pcs
                     WHERE    ptco.ci_type_id = p_ci_type_id
                     AND      ptco.version_type = p_version_type
                     AND      ptco.ci_type_id = pcs.ci_type_id
                     AND      ptco.status_code=pcs.project_status_code
                     AND      pcs.project_system_status_code <> PA_FP_CONSTANTS_PKG.G_SYS_STATUS_APPROVED
                     AND      ptco.fin_plan_type_id=p_fin_plan_type_id);

      EXCEPTION
            WHEN NO_DATA_FOUND THEN
                  l_return := 'N';
      END;

      IF l_debug_mode = 'Y' THEN
            pa_debug.reset_curr_function;
      END IF;

      RETURN l_return;
END NON_APP_STATUSES_EXIST;

/* FP M - dbora - To return the CI type
*/
FUNCTION GET_CI_ALLOWED_IMPACTS(
      p_ci_type_id                 IN                pa_pt_co_impl_statuses.ci_type_id%TYPE)
      RETURN VARCHAR2

IS
      l_cost_impact_flag           VARCHAR2(30);
      l_rev_impact_flag            VARCHAR2(30);

      l_debug_mode                 VARCHAR2(1);
      l_debug_level3               CONSTANT NUMBER := 3;
      l_module_name                VARCHAR2(100) := 'GET_CI_ALLOWED_IMPACTS' ;

BEGIN

      IF l_debug_mode = 'Y' THEN
             pa_debug.set_curr_function( p_function   => 'GET_CI_ALLOWED_IMPACTS',
                                         p_debug_mode => l_debug_mode );
      END IF;

      BEGIN

         BEGIN
             SELECT  cost_impact_flag, revenue_impact_flag
             INTO    l_cost_impact_flag, l_rev_impact_flag
             FROM    PA_CI_TYPES_W_FINPLAN_V
             WHERE   ci_type_id = p_ci_type_id;
          EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                       IF l_debug_mode = 'Y' THEN
                              pa_debug.reset_curr_function;
                       END IF;
          END;
          IF (l_cost_impact_flag = 'Y' AND l_rev_impact_flag = 'Y') THEN

                 IF l_debug_mode = 'Y' THEN
                       pa_debug.reset_curr_function;
                 END IF ;

                 RETURN PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH;

          ELSIF l_cost_impact_flag = 'Y' THEN

                 IF l_debug_mode = 'Y' THEN
                       pa_debug.reset_curr_function;
                 END IF ;

                 RETURN PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST;

          ELSIF l_rev_impact_flag = 'Y' THEN

                IF l_debug_mode = 'Y' THEN
                      pa_debug.reset_curr_function;
                END IF ;

                RETURN PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE;

          ELSE

                IF l_debug_mode = 'Y' THEN
                     pa_debug.reset_curr_function;
                END IF ;

                RETURN NULL;
          END IF;
      END;

END GET_CI_ALLOWED_IMPACTS;



PROCEDURE get_summary_data
(      p_project_id                  IN       NUMBER
      ,p_cost_version_id             IN       pa_budget_versions.budget_version_id%TYPE
      ,p_revenue_version_id          IN       pa_budget_versions.budget_version_id%TYPE
      ,p_page_context                IN       VARCHAR2
      ,p_calling_mode                IN       VARCHAR2 DEFAULT 'APPROVED' --Bug 5278200 kchaitan
      ,x_context                     OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_summary_tbl                 OUT      NOCOPY SYSTEM.PA_VARCHAR2_150_TBL_TYPE --File.Sql.39 bug 4440895
      ,x_url_tbl                     OUT      NOCOPY SYSTEM.PA_VARCHAR2_240_TBL_TYPE --File.Sql.39 bug 4440895
      ,x_reference_tbl               OUT      NOCOPY SYSTEM.PA_VARCHAR2_30_TBL_TYPE --File.Sql.39 bug 4440895
      ,x_equipment_hours_tbl         OUT      NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
      ,x_labor_hours_tbl             OUT      NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
      ,x_cost_tbl                    OUT      NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
      ,x_revenue_tbl                 OUT      NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
      ,x_margin_tbl                  OUT      NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
      ,x_margin_percent_tbl          OUT      NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
      ,x_project_currency_code       OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_report_labor_hrs_code       OUT      NOCOPY VARCHAR2 /* Bug 4038253 */ --File.Sql.39 bug 4440895
      ,x_return_status               OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_msg_count                   OUT      NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,x_msg_data                    OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

  --Start of variables used for debugging
      l_msg_count          NUMBER :=0;
      l_data               VARCHAR2(2000);
      l_msg_data           VARCHAR2(2000);
      l_error_msg_code     VARCHAR2(30);
      l_msg_index_out      NUMBER;
      l_return_status      VARCHAR2(2000);
      l_debug_mode         VARCHAR2(30);
  --End of variables used for debugging


l_assigned_flag             VARCHAR2(1) := 'N';
l_continue_flag             VARCHAR2(1) := 'Y';
l_row_count                 NUMBER := 0;
l_margin_derived_from_code  PA_PROJ_FP_OPTIONS.margin_derived_from_code%TYPE;
l_module_name               VARCHAR2(30) := 'ctrl_itm_utls.plan_summ_data';
l_version_type              PA_BUDGET_VERSIONS.version_type%TYPE;
l_ar_fin_plan_type_id       PA_PROJ_FP_OPTIONS.FIN_PLAN_TYPE_ID%TYPE;
l_ac_fin_plan_type_id       PA_PROJ_FP_OPTIONS.FIN_PLAN_TYPE_ID%TYPE;
l_report_version_type       PA_BUDGET_VERSIONS.version_type%TYPE;
l_labor_quantity            PA_BUDGET_VERSIONS.LABOR_QUANTITY%TYPE;
l_equipment_quantity        PA_BUDGET_VERSIONS.EQUIPMENT_QUANTITY%TYPE;
l_cost                      PA_BUDGET_VERSIONS.RAW_COST%TYPE;
l_revenue                   PA_BUDGET_VERSIONS.REVENUE%TYPE;

l_cb_labor_quantity         PA_BUDGET_VERSIONS.LABOR_QUANTITY%TYPE;
l_cb_equipment_quantity     PA_BUDGET_VERSIONS.EQUIPMENT_QUANTITY%TYPE;
l_cb_cost                   PA_BUDGET_VERSIONS.RAW_COST%TYPE;
l_cb_revenue                PA_BUDGET_VERSIONS.REVENUE%TYPE;

l_cw_labor_quantity         PA_BUDGET_VERSIONS.LABOR_QUANTITY%TYPE;
l_cw_equipment_quantity     PA_BUDGET_VERSIONS.EQUIPMENT_QUANTITY%TYPE;
l_cw_cost                   PA_BUDGET_VERSIONS.RAW_COST%TYPE;
l_cw_revenue                PA_BUDGET_VERSIONS.REVENUE%TYPE;

l_lookup_code_tbl                 SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_fin_plan_type_id_tbl            SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_fin_plan_preference_code_tbl    SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_rep_lab_from_code_tbl           SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_appr_cost_plan_type_flag_tbl    SYSTEM.PA_VARCHAR2_1_TBL_TYPE    := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_appr_rev_plan_type_flag_tbl     SYSTEM.PA_VARCHAR2_1_TBL_TYPE    := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();

l_set_cw_url_flag                      VARCHAR2(1) := 'Y';
l_set_ob_url_flag                      VARCHAR2(1) := 'Y';
l_set_cb_url_flag                      VARCHAR2(1) := 'Y';
l_set_cpb_url_flag                     VARCHAR2(1) := 'Y';
l_set_ccw_url_flag                     VARCHAR2(1) := 'Y';
l_fin_plan_type_id                     PA_PROJ_FP_OPTIONS.FIN_PLAN_TYPE_ID%TYPE;
l_pa_cw_cost_bv_id                     PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE;
l_pa_cw_revenue_bv_id                  PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE;
l_pa_ob_cost_bv_id                     PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE;
l_pa_ob_revenue_bv_id                  PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE;
l_pa_cb_cost_bv_id                     PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE;
l_pa_cb_revenue_bv_id                  PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE;
l_bv_id                                PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE;
l_version_type_tbl                     SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_budget_version_id_tbl                SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_next                                 VARCHAR2(30);
l_context                              VARCHAR2(30);

l_appr_rev_cw_version_id               PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE;

l_report_labor_hrs_code                pa_proj_fp_options.report_labor_hrs_from_code%TYPE; /* Bug 4038253 */
l_pref_code_for_pt_of_ver              pa_proj_fp_options.fin_plan_preference_code%TYPE; /* Bug 4038253 */

 CURSOR c_lookup_summary IS
        SELECT MEANING,to_number(LOOKUP_CODE)
          FROM PA_LOOKUPS
         WHERE LOOKUP_TYPE = 'PA_FP_CI_PLAN_SUMMARY'
        ORDER BY to_number(LOOKUP_CODE);

 CURSOR c_lookup_reference IS
        SELECT MEANING
          FROM PA_LOOKUPS
         WHERE LOOKUP_TYPE = 'PA_FP_CI_PLAN_REFERENCE'
        ORDER BY to_number(LOOKUP_CODE);

 CURSOR c_get_approved_details
        (c_project_id PA_PROJECTS_ALL.PROJECT_ID%TYPE) IS
        SELECT  fin_plan_type_id,
                fin_plan_preference_code,
                report_labor_hrs_from_code,
                approved_cost_plan_type_flag,
                approved_rev_plan_type_flag
          FROM pa_proj_fp_options
         WHERE project_id = c_project_id
           AND (approved_cost_plan_type_flag = 'Y' or approved_rev_plan_type_flag = 'Y')
           AND fin_plan_option_level_code = 'PLAN_TYPE';

 CURSOR c_original_baselined
       (c_project_id PA_PROJECTS_ALL.PROJECT_ID%TYPE,
        c_ac_fin_plan_type_id PA_PROJ_FP_OPTIONS.FIN_PLAN_TYPE_ID%TYPE,
        c_ar_fin_plan_type_id PA_PROJ_FP_OPTIONS.FIN_PLAN_TYPE_ID%TYPE,
        c_margin_derived_from_code PA_PROJ_FP_OPTIONS.margin_derived_from_code%TYPE,
        c_report_version_type PA_BUDGET_VERSIONS.VERSION_TYPE%TYPE) IS
     SELECT nvl(sum(decode(pbv.version_type,
                           c_report_version_type,
                           nvl(pbv.labor_quantity,0),0)),0),
            nvl(sum(decode(pbv.version_type,
                           c_report_version_type,
                           nvl(pbv.equipment_quantity,0),0)),0),
            nvl(sum(decode(pbv.fin_plan_type_id,
                           c_ac_fin_plan_type_id,
                           decode(c_margin_derived_from_code,
                                 'B',nvl(pbv.total_project_burdened_cost,0),
                                  nvl(pbv.total_project_raw_cost,0))
                    ,0)),0) as cost,
            nvl(sum(decode(pbv.fin_plan_type_id,
                           c_ar_fin_plan_type_id,nvl(pbv.total_project_revenue,0),0)),0)
      FROM pa_budget_versions pbv
     WHERE pbv.project_id = c_project_id
       AND pbv.ci_id is null
       AND nvl(pbv.current_original_flag,'N') = 'Y'
       --Below 2 lines commented for bug 5278200
       AND pbv.fin_plan_type_id in (c_ac_fin_plan_type_id,c_ar_fin_plan_type_id)
       --AND pbv.fin_plan_type_id is not null
       --AND (pbv.approved_cost_plan_type_flag = 'Y' or pbv.approved_rev_plan_type_flag = 'Y')
       AND pbv.budget_status_code = 'B';

 CURSOR c_current_baselined
        (c_project_id PA_PROJECTS_ALL.PROJECT_ID%TYPE,
         c_ac_fin_plan_type_id PA_PROJ_FP_OPTIONS.FIN_PLAN_TYPE_ID%TYPE,
         c_ar_fin_plan_type_id PA_PROJ_FP_OPTIONS.FIN_PLAN_TYPE_ID%TYPE,
         c_margin_derived_from_code PA_PROJ_FP_OPTIONS.margin_derived_from_code%TYPE,
         c_report_version_type PA_BUDGET_VERSIONS.VERSION_TYPE%TYPE) IS
     SELECT nvl(sum(decode(pbv.version_type,
                           c_report_version_type,
                           nvl(pbv.labor_quantity,0),0)),0),
            nvl(sum(decode(pbv.version_type,
                           c_report_version_type,
                           nvl(pbv.equipment_quantity,0),0)),0),
            nvl(sum(decode(pbv.fin_plan_type_id,
                           c_ac_fin_plan_type_id,
                           decode(c_margin_derived_from_code,
                                  'B',nvl(pbv.total_project_burdened_cost,0),
                                  nvl(pbv.total_project_raw_cost,0))
                    ,0)),0) as cost,
            nvl(sum(decode(pbv.fin_plan_type_id,
                           c_ar_fin_plan_type_id,
                           nvl(pbv.total_project_revenue,0),0)),0)
      FROM pa_budget_versions pbv
     WHERE pbv.project_id = c_project_id
       AND pbv.ci_id is null
       AND nvl(pbv.current_flag,'N') = 'Y'
       --Below 2 lines commented for bug 5278200
       AND pbv.fin_plan_type_id in (c_ac_fin_plan_type_id,c_ar_fin_plan_type_id)
       --AND pbv.fin_plan_type_id is not null
       --AND (pbv.approved_cost_plan_type_flag = 'Y' or pbv.approved_rev_plan_type_flag = 'Y')
       AND pbv.budget_status_code = 'B';

 CURSOR c_current_working
        (c_project_id PA_PROJECTS_ALL.PROJECT_ID%TYPE,
         c_ac_fin_plan_type_id PA_PROJ_FP_OPTIONS.FIN_PLAN_TYPE_ID%TYPE,
         c_ar_fin_plan_type_id PA_PROJ_FP_OPTIONS.FIN_PLAN_TYPE_ID%TYPE,
         c_margin_derived_from_code PA_PROJ_FP_OPTIONS.margin_derived_from_code%TYPE,
         c_report_version_type PA_BUDGET_VERSIONS.VERSION_TYPE%TYPE) IS
     SELECT nvl(sum(decode(pbv.version_type,
                           c_report_version_type,
                           nvl(pbv.labor_quantity,0),0)),0),
            nvl(sum(decode(pbv.version_type,
                           c_report_version_type,
                           nvl(pbv.equipment_quantity,0),0)),0),
            nvl(sum(decode(pbv.fin_plan_type_id,
                           c_ac_fin_plan_type_id,
                           decode(c_margin_derived_from_code,
                                  'B',nvl(pbv.total_project_burdened_cost,0),
                                  nvl(pbv.total_project_raw_cost,0)),0)),0) as cost,
            nvl(sum(decode(pbv.fin_plan_type_id,
                           c_ar_fin_plan_type_id,
                           nvl(pbv.total_project_revenue,0),0)),0)
      FROM pa_budget_versions pbv
     WHERE pbv.project_id = c_project_id
       AND pbv.ci_id is null
       AND nvl(pbv.current_working_flag,'N') = 'Y'
       --Below 2 lines commented for bug 5278200
       AND pbv.fin_plan_type_id in (c_ac_fin_plan_type_id,c_ar_fin_plan_type_id);
       --AND pbv.fin_plan_type_id is not null
       --AND (pbv.approved_cost_plan_type_flag = 'Y' or pbv.approved_rev_plan_type_flag = 'Y')
--       AND pbv.budget_status_code in ('S','W'); -- Bug#3815378

/* Bug - 3882985.
   Cursor c_change_documents_current is commented out below and re-written.
   c_change_documents_current should rely on inclusion_method_code in pa_fp_merged_ctrl_items.
   Basically All records having inclusion_method_code as (MANUAL,AUTOMATIC) should
   be considered while deriving Amounts/Quantities for the Current Working Version.
   We should NOT use a 'not exists' clause on change documents that have been already
   included in the current baseline version(as it was done earlier).
*/
/* CURSOR c_change_documents_current
        (c_project_id PA_PROJECTS_ALL.PROJECT_ID%TYPE,
         c_ac_fin_plan_type_id PA_PROJ_FP_OPTIONS.FIN_PLAN_TYPE_ID%TYPE,
         c_ar_fin_plan_type_id PA_PROJ_FP_OPTIONS.FIN_PLAN_TYPE_ID%TYPE,
         c_margin_derived_from_code PA_PROJ_FP_OPTIONS.margin_derived_from_code%TYPE,
         c_report_version_type PA_BUDGET_VERSIONS.VERSION_TYPE%TYPE) IS -- Raja review
   Select nvl(sum(decode(c_report_version_type,
                         'COST', decode(merge.version_type, 'COST',nvl(merge.impl_quantity,0),0),
                         'REVENUE', decode(merge.version_type, 'REVENUE',nvl(merge.impl_quantity,0),0),
                         'ALL', decode(merge.version_type, 'COST',nvl(merge.impl_quantity,0),0)
                         ,0)),0),
          nvl(sum(decode(c_report_version_type,
                         'COST', decode(merge.version_type, 'COST',nvl(merge.impl_equipment_quantity,0),0),
                         'REVENUE', decode(merge.version_type, 'REVENUE',nvl(merge.impl_equipment_quantity,0),0),
                         'ALL', decode(merge.version_type, 'COST',nvl(merge.impl_equipment_quantity,0),0)
                         ,0)),0),

-- Raja report_version_type should be taken into consideration
--          nvl(sum(nvl(merge.impl_quantity,0)),0),
--          nvl(sum(nvl(merge.impl_equipment_quantity,0)),0),

          nvl(sum(decode(c_margin_derived_from_code,
                        'B',nvl(merge.impl_proj_burdened_cost,0),
                        nvl(merge.impl_proj_raw_cost,0))),0) as cost,
          nvl(sum(nvl(merge.impl_proj_revenue,0)),0)
     from pa_fp_merged_ctrl_items merge,
          pa_budget_versions pbv
    where pbv.project_id = c_project_id
      and pbv.fin_plan_type_id in (c_ac_fin_plan_type_id, c_ar_fin_plan_type_id)
      and pbv.current_working_flag = 'Y'
      and merge.project_id = c_project_id
      and merge.plan_version_id = pbv.budget_version_id
      and pbv.ci_id is null
--      and pbv.budget_status_code in ('S','W') -- Bug#3815378
--      Added by Raja, filter all the ci versions included/copied in current baseline version
      and not exists(select 1
                       from pa_fp_merged_ctrl_items merge1, pa_budget_versions pbv1
                      where pbv1.project_id = c_project_id
                        and pbv1.fin_plan_type_id in (c_ac_fin_plan_type_id,
                                                      c_ar_fin_plan_type_id)
                        and pbv1.budget_status_code = 'B'
                        and pbv1.current_flag = 'Y'
                        and pbv1.ci_id is null
                        and merge1.project_id = c_project_id
                        and merge1.plan_version_id = pbv1.budget_version_id
                        and merge1.ci_plan_version_id = merge.ci_plan_version_id);
*/

-- Bug 5845142. Take the revenue amounts only from revenue impact.Note that cost impacts
-- with ALL version type can have revenue amounts.
CURSOR c_change_documents_current
        (c_project_id PA_PROJECTS_ALL.PROJECT_ID%TYPE,
         c_ac_fin_plan_type_id PA_PROJ_FP_OPTIONS.FIN_PLAN_TYPE_ID%TYPE,
         c_ar_fin_plan_type_id PA_PROJ_FP_OPTIONS.FIN_PLAN_TYPE_ID%TYPE,
         c_margin_derived_from_code PA_PROJ_FP_OPTIONS.margin_derived_from_code%TYPE,
         c_report_version_type PA_BUDGET_VERSIONS.VERSION_TYPE%TYPE) IS -- Raja review
   Select nvl(sum(decode(c_report_version_type,
                         'COST', decode(merge.version_type, 'COST',nvl(merge.impl_quantity,0),0),
                         'REVENUE', decode(merge.version_type, 'REVENUE',nvl(merge.impl_quantity,0),0),
                         'ALL', decode(merge.version_type, 'COST',nvl(merge.impl_quantity,0),0)
                         ,0)),0),
          nvl(sum(decode(c_report_version_type,
                         'COST', decode(merge.version_type, 'COST',nvl(merge.impl_equipment_quantity,0),0),
                         'REVENUE', decode(merge.version_type, 'REVENUE',nvl(merge.impl_equipment_quantity,0),0),
                         'ALL', decode(merge.version_type, 'COST',nvl(merge.impl_equipment_quantity,0),0)
                         ,0)),0),
          nvl(sum(decode(c_margin_derived_from_code,
                        'B',nvl(merge.impl_proj_burdened_cost,0),
                        nvl(merge.impl_proj_raw_cost,0))),0) as cost,
          nvl(sum(decode(pbv.fin_plan_type_id,
                        c_ar_fin_plan_type_id,nvl(merge.impl_proj_revenue,0),
                        0)),0)
     from pa_fp_merged_ctrl_items merge,
          pa_budget_versions pbv
    where pbv.project_id = c_project_id
      and pbv.fin_plan_type_id in (c_ac_fin_plan_type_id, c_ar_fin_plan_type_id)
      and pbv.current_working_flag = 'Y'
      and merge.project_id = c_project_id
      and merge.plan_version_id = pbv.budget_version_id
      and pbv.ci_id is null
      and merge.inclusion_method_code in ('MANUAL','AUTOMATIC');



/* Bug - 3882985.
   Cursor c_change_documents_prior is modified below.
   c_change_documents_prior should rely on inclusion_method_code in pa_fp_merged_ctrl_items.
   Basically All records having inclusion_method_code as (COPIED - for Current Baseline) should
   be considered while deriving Amounts/Quantities for the Prior Baselined Versions
*/
-- Bug 5845142. Take the revenue amounts only from revenue impact.Note that cost impacts
-- with ALL version type can have revenue amounts.
CURSOR c_change_documents_prior
       (c_project_id PA_PROJECTS_ALL.PROJECT_ID%TYPE,
        c_ac_fin_plan_type_id PA_PROJ_FP_OPTIONS.FIN_PLAN_TYPE_ID%TYPE,
        c_ar_fin_plan_type_id PA_PROJ_FP_OPTIONS.FIN_PLAN_TYPE_ID%TYPE,
        c_margin_derived_from_code PA_PROJ_FP_OPTIONS.margin_derived_from_code%TYPE,
        c_report_version_type PA_BUDGET_VERSIONS.VERSION_TYPE%TYPE) IS -- Raja review
    Select nvl(sum(decode(c_report_version_type,
                         'COST', decode(merge.version_type, 'COST',nvl(merge.impl_quantity,0),0),
                         'REVENUE', decode(merge.version_type, 'REVENUE',nvl(merge.impl_quantity,0),0),
                         'ALL', decode(merge.version_type, 'COST',nvl(merge.impl_quantity,0),0)
                         ,0)),0),
           nvl(sum(decode(c_report_version_type,
                         'COST', decode(merge.version_type, 'COST',nvl(merge.impl_equipment_quantity,0),0),
                         'REVENUE', decode(merge.version_type, 'REVENUE',nvl(merge.impl_equipment_quantity,0),0),
                         'ALL', decode(merge.version_type, 'COST',nvl(merge.impl_equipment_quantity,0),0)
                         ,0)),0),
/** Raja report_version_type should be taken into consideration
          nvl(sum(nvl(merge.impl_quantity,0)),0),
          nvl(sum(nvl(merge.impl_equipment_quantity,0)),0),
 **/
           nvl(sum(decode(c_margin_derived_from_code,'B'
                          ,nvl(merge.impl_proj_burdened_cost,0)
                          ,nvl(merge.impl_proj_raw_cost,0))),0) as cost,
           nvl(sum(decode(pbv.fin_plan_type_id,
                          c_ar_fin_plan_type_id,nvl(merge.impl_proj_revenue,0),
                          0)),0)
      from pa_fp_merged_ctrl_items merge,
           pa_budget_versions pbv
     where merge.plan_version_id = pbv.budget_version_id
       and pbv.fin_plan_type_id in (c_ac_fin_plan_type_id, c_ar_fin_plan_type_id)
       and pbv.current_flag = 'Y'
       and pbv.project_id = c_project_id
       and merge.project_id = c_project_id
       and pbv.ci_id is null
       and pbv.budget_status_code = 'B'
       and merge.inclusion_method_code = 'COPIED' -- Bug 3882985
  /* Raja filter all the change orders that have been included/copied in the original baseline version */
       and not exists(select 1
                        from pa_fp_merged_ctrl_items merge1, pa_budget_versions pbv1
                       where pbv1.project_id = c_project_id
                         and pbv1.fin_plan_type_id in (c_ac_fin_plan_type_id,
                                                       c_ar_fin_plan_type_id)
                         and pbv1.current_original_flag = 'Y'
                         and pbv1.ci_id is null
                         and pbv1.budget_status_code = 'B'
                         and merge1.project_id = c_project_id
                         and merge1.plan_version_id = pbv1.budget_version_id
                         -- Raja review and pbv.budget_version_id = pbv1.budget_version_id);
                         and merge1.ci_plan_version_id = merge.ci_plan_version_id);


 /* Bug 3572880 Only those change orders that have not been already merged into the current
    working version should be considered. */
 /* commented by Raja rewritten the cursor below
 CURSOR c_change_documents_status
        (c_project_id pa_projects_all.project_id%TYPE,
         c_system_status_code pa_ci_statuses_v.project_system_status_code%TYPE,
         c_margin_derived_from_code PA_PROJ_FP_OPTIONS.margin_derived_from_code%TYPE) IS
     SELECT nvl(sum(pfca.people_effort),0),
            nvl(sum(pfca.equipment_effort),0),
            nvl(sum(decode(c_margin_derived_from_code,'B',
                           nvl(pfca.burdened_cost,0),
                           nvl(pfca.raw_cost,0))),0) as cost,
            nvl(sum(nvl(pfca.revenue,0)),0)
      from  PA_FP_ELIGIBLE_CI_V pfca
     where  pfca.project_id = c_project_id
       and  pfca.PROJECT_SYSTEM_STATUS_CODE = c_system_status_code;
*/
 -- For ALL change order versions (meaning same plan type is designated as
 -- both AC and AR, plan setup is COST_AND_REV_SAME), quantity is implemented
 -- when cost is implemented. To avoid double count, in the second select
 -- quantity is never computed for ALL CO versions
-- Changed for Bug 3744910
-- Bug 3947153. Modified the inner select for revenue data to show the correct quantity. Please see
-- the bug for details
 CURSOR c_change_documents_status
        (c_project_id pa_projects_all.project_id%TYPE,
         c_system_status_code pa_ci_statuses_v.project_system_status_code%TYPE,
         c_margin_derived_from_code PA_PROJ_FP_OPTIONS.margin_derived_from_code%TYPE,
         c_report_version_type PA_BUDGET_VERSIONS.VERSION_TYPE%TYPE,
         c_appr_rev_cw_version_id PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE) IS -- Raja review
     SELECT (cost_query.people_effort + revenue_query.people_effort),
            (cost_query.equipment_effort + revenue_query.equipment_effort),
            (cost_query.cost + revenue_query.cost),
            (cost_query.revenue + revenue_query.revenue)
       from
         (SELECT nvl(sum(decode(pfca.ci_version_type,
                                c_report_version_type, pfca.people_effort,
                                0)),0) as people_effort,
                nvl(sum(decode(pfca.ci_version_type,
                                c_report_version_type, pfca.equipment_effort,
                                0)),0) as equipment_effort,
                nvl(sum(decode(c_margin_derived_from_code,'B',
                               nvl(pfca.burdened_cost,0),
                               nvl(pfca.raw_cost,0))),0) as cost,
                0 as revenue
          from  (SELECT PBV.PROJECT_ID AS PROJECT_ID
                       ,PBV.BUDGET_VERSION_ID AS CI_VERSION_ID
                       ,PBV.VERSION_TYPE AS CI_VERSION_TYPE
                       ,PCI.CI_ID AS CI_ID
                       ,PCI.SUMMARY AS SUMMARY
                       ,PCS.PROJECT_SYSTEM_STATUS_CODE AS PROJECT_SYSTEM_STATUS_CODE
                       ,PBV.LABOR_QUANTITY AS PEOPLE_EFFORT
                       ,PBV.EQUIPMENT_QUANTITY AS EQUIPMENT_EFFORT
                       ,PBV.TOTAL_PROJECT_RAW_COST AS RAW_COST
                       ,PBV.TOTAL_PROJECT_BURDENED_COST AS BURDENED_COST
                  FROM pa_budget_versions pbv
                      ,pa_control_items pci
                      ,pa_project_statuses pcs
                      ,pa_ci_types_vl pct
                 WHERE PBV.CI_ID = PCI.CI_ID
                   AND PBV.PROJECT_ID = PCI.PROJECT_ID
                   AND PCI.STATUS_CODE = PCS.PROJECT_STATUS_CODE
                   AND pct.ci_type_id = pci.ci_type_id
                   AND pct.ci_type_class_code = 'CHANGE_ORDER') pfca
         where  pfca.project_id = c_project_id
           and  pfca.project_system_status_code = c_system_status_code
           and  pfca.ci_version_type in ('COST', 'ALL')
           and  not exists(select 1
                            from pa_fp_merged_ctrl_items merge1, pa_budget_versions pbv1
                           where merge1.project_id = c_project_id
                             and merge1.ci_id =  pfca.ci_id
                             and merge1.ci_plan_version_id = pfca.ci_version_id
                             and merge1.version_type = 'COST'
--                             and pbv1.budget_status_code in ('S','W') -- Bug#3815378
                             and pbv1.current_working_flag = 'Y'
                             and pbv1.budget_version_id = merge1.plan_version_id
                             and pbv1.ci_id is null
                             and pbv1.approved_cost_plan_type_flag = 'Y'))  cost_query,
          -- Modified revenue Query 3902490 to add calls to get_labor_qty_partial and get_equip_qty_partial
          -- for deriving quantity when rev_partially_impl_flag is passed as Y.
         (SELECT nvl(sum(nvl(decode(c_report_version_type,'REVENUE',
                                    decode(pfca.REV_PARTIALLY_IMPL_FLAG,'Y',PA_FP_CONTROL_ITEMS_UTILS.get_labor_qty_partial
                                                                                 (pfca.CI_VERSION_TYPE
                                                                                 ,c_appr_rev_cw_version_id
                                                                                 ,pfca.CI_VERSION_ID
                                                                                 ,pfca.people_effort
                                                                                 ,'REVENUE')
                                                                           ,pfca.people_effort),
                                    0),
                            0)
                        ),0) as people_effort,
                 nvl(sum(nvl(decode(c_report_version_type,'REVENUE',
                                    decode(pfca.REV_PARTIALLY_IMPL_FLAG,'Y',PA_FP_CONTROL_ITEMS_UTILS.get_equip_qty_partial
                                                                                 (pfca.CI_VERSION_TYPE
                                                                                 ,c_appr_rev_cw_version_id
                                                                                 ,pfca.CI_VERSION_ID
                                                                                 ,pfca.equipment_effort
                                                                                 ,'REVENUE')
                                                                       ,pfca.equipment_effort),
                                    0),
                            0)
                        ),0)    as equipment_effort,
                 0 as cost,
                 nvl(sum(nvl(decode(pfca.REV_PARTIALLY_IMPL_FLAG,'Y',PA_FP_CONTROL_ITEMS_UTILS.get_pc_revenue_partial
                                                                                         (pfca.CI_VERSION_TYPE
                                                                                          ,c_appr_rev_cw_version_id
                                                                                          ,pfca.CI_VERSION_ID
                                                                                          ,pfca.revenue
                                                                                          ,'REVENUE')
                                                                    ,pfca.revenue),0)),0) as revenue
          from  (SELECT PBV.PROJECT_ID AS PROJECT_ID
                       ,PBV.BUDGET_VERSION_ID AS CI_VERSION_ID
                       ,PBV.VERSION_TYPE AS CI_VERSION_TYPE
                       ,PCI.CI_ID AS CI_ID
                       ,PCS.PROJECT_SYSTEM_STATUS_CODE AS PROJECT_SYSTEM_STATUS_CODE
                       ,PBV.LABOR_QUANTITY AS PEOPLE_EFFORT
                       ,PBV.EQUIPMENT_QUANTITY AS EQUIPMENT_EFFORT
                       ,PBV.TOTAL_PROJECT_REVENUE AS REVENUE
                       ,nvl(PBV.REV_PARTIALLY_IMPL_FLAG,'N') AS REV_PARTIALLY_IMPL_FLAG
                  FROM pa_budget_versions pbv
                      ,pa_control_items pci
                      ,pa_project_statuses pcs
                      ,pa_ci_types_vl pct
                 WHERE PBV.CI_ID = PCI.CI_ID
                   AND PBV.PROJECT_ID = PCI.PROJECT_ID
                   AND PCI.STATUS_CODE = PCS.PROJECT_STATUS_CODE
                   AND pct.ci_type_id = pci.ci_type_id
                   AND pct.ci_type_class_code = 'CHANGE_ORDER') pfca
         where  pfca.project_id = c_project_id
           and  pfca.project_system_status_code = c_system_status_code
           and  pfca.ci_version_type in ('REVENUE', 'ALL')
           and (pfca.REV_PARTIALLY_IMPL_FLAG = 'Y' OR
                not exists(select 1
                            from pa_fp_merged_ctrl_items merge1, pa_budget_versions pbv1
                           where merge1.project_id = c_project_id
                             and merge1.ci_id =  pfca.ci_id
                             and merge1.ci_plan_version_id = pfca.ci_version_id
                             and merge1.version_type = 'REVENUE'
--                             and pbv1.budget_status_code in ('S','W') -- Bug#3815378
                             and pbv1.current_working_flag = 'Y'
                             and pbv1.budget_version_id = merge1.plan_version_id
                             and pbv1.ci_id is null
                             and pbv1.approved_rev_plan_type_flag = 'Y')))  revenue_query;

--Bug 5278200Added extra parameter
 cursor c_url_original_baseline(c_project_id PA_PROJECTS_ALL.PROJECT_ID%TYPE,
                                c_fin_plan_type_id pa_budget_versions.fin_plan_type_id%TYPE,
                                c_version_type pa_budget_versions.version_type%TYPE) IS
        SELECT BUDGET_VERSION_ID,VERSION_TYPE
          FROM PA_BUDGET_VERSIONS
         WHERE BUDGET_STATUS_CODE = 'B'
           AND PROJECT_ID = c_project_id
           AND CI_ID IS NULL
           AND NVL(CURRENT_ORIGINAL_FLAG,'N') = 'Y'
           AND FIN_PLAN_TYPE_ID = C_FIN_PLAN_TYPE_ID
           AND version_type = c_version_type;
           --Bug 4089203
           --AND (approved_cost_plan_type_flag='Y' or approved_rev_plan_type_flag='Y');

--Bug 5278200Added extra parameter
 cursor c_url_current_baseline(c_project_id PA_PROJECTS_ALL.PROJECT_ID%TYPE,
                               c_fin_plan_type_id pa_budget_versions.fin_plan_type_id%TYPE,
                               c_version_type pa_budget_versions.version_type%TYPE) IS
        SELECT BUDGET_VERSION_ID,VERSION_TYPE
          FROM PA_BUDGET_VERSIONS
         WHERE BUDGET_STATUS_CODE = 'B'
           AND PROJECT_ID = c_project_id
           AND CI_ID IS NULL
           AND NVL(CURRENT_FLAG,'N') = 'Y'
           AND FIN_PLAN_TYPE_ID = C_FIN_PLAN_TYPE_ID
           AND version_type = c_version_type;
           --Bug 4089203
           --AND (approved_cost_plan_type_flag='Y' or approved_rev_plan_type_flag='Y');

--Bug 5278200Added extra parameter
 cursor c_url_current_working(c_project_id PA_PROJECTS_ALL.PROJECT_ID%TYPE,
                              c_fin_plan_type_id pa_budget_versions.fin_plan_type_id%TYPE,
                              c_version_type pa_budget_versions.version_type%TYPE) IS
        SELECT BUDGET_VERSION_ID,VERSION_TYPE
          FROM PA_BUDGET_VERSIONS
         WHERE PROJECT_ID = c_project_id
           AND CI_ID IS NULL
           AND NVL(CURRENT_WORKING_FLAG,'N') = 'Y'
--           AND BUDGET_STATUS_CODE in ('S','W') -- Bug#3815378
           AND FIN_PLAN_TYPE_ID = C_FIN_PLAN_TYPE_ID
           AND version_type = c_version_type;
           --Bug 4089203
           --AND (approved_cost_plan_type_flag='Y' or approved_rev_plan_type_flag='Y');


BEGIN

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    PA_DEBUG.Set_Curr_Function( p_function   => l_module_name,
                                p_debug_mode => l_debug_mode );


    -----------------------------------------------------------------------------
    -- Validate Input Params, p_project_id and (p_cost_version_id and p_revenue_version_id
    -- both) cannot be null or =-99
    -----------------------------------------------------------------------------
   IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:='Validating input parameters - project id : ' || p_project_id;
      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
   END IF;

   IF (p_project_id IS NULL) THEN
       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='p_project_id is null';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
       END IF;
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
   END IF;

   IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:='Validating input parameters - p_cost_version_id : '||p_cost_version_id;
      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

      pa_debug.g_err_stage:='Validating input parameters - p_revenue_version_id : '||p_revenue_version_id;
      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
   END IF;

   IF ((nvl(p_cost_version_id,-99) = -99) AND (nvl(p_revenue_version_id,-99) = -99)) THEN
       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Validating p_cost_version_id :'||p_cost_version_id;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
       END IF;
       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Validating p_revenue_version_id :'||p_revenue_version_id;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
       END IF;
       RAISE PA_FP_CONSTANTS_PKG.Just_Ret_Exc;
   END IF;


   -------------------------------------------
   -- Initialising all tables to empty tables.
   -------------------------------------------
    IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:='Initialising all tables to empty tables.';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
    END IF;
    x_summary_tbl         := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
    x_url_tbl             := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
    x_reference_tbl       := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
    x_equipment_hours_tbl := SYSTEM.pa_num_tbl_type();
    x_labor_hours_tbl     := SYSTEM.pa_num_tbl_type();
    x_cost_tbl            := SYSTEM.pa_num_tbl_type();
    x_revenue_tbl         := SYSTEM.pa_num_tbl_type();
    x_margin_tbl          := SYSTEM.pa_num_tbl_type();
    x_margin_percent_tbl  := SYSTEM.pa_num_tbl_type();

   ----------------------------------------------------
   -- Derive Value of x_context
   ----------------------------------------------------
    IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:='Derive Value of x_context';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF ((nvl(p_cost_version_id,-99) <> -99) AND (nvl(p_revenue_version_id,-99) <> -99)) THEN
        l_context := 'ALL';
    ELSIF ((nvl(p_cost_version_id,-99) <> -99) AND (nvl(p_revenue_version_id,-99) = -99)) THEN
        l_context := 'COST';
    ELSIF ((nvl(p_cost_version_id,-99) = -99) AND (nvl(p_revenue_version_id,-99) <> -99)) THEN
        l_context := 'REVENUE';
    END IF;

    x_context := l_context;

   --------------------------------------------------
   -- Fetching the project currency code
   --------------------------------------------------
    IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:='Derived x_context : '||x_context;
         pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

         pa_debug.g_err_stage:='Fetching the project currency code';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
    END IF;

       BEGIN
           SELECT project_currency_code
           INTO x_project_currency_code
           FROM Pa_Projects_All
           WHERE project_Id = p_project_id;

         IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='x_project_currency_code =  ' || x_project_currency_code;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
         END IF;

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
                IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='NO_DATA_FOUND for fetching project_currency_code';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END;

   -----------------------------------------
   -- Fetching the margin dervied from code.
   -----------------------------------------
    IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:='Fetching the margin dervied from code';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
    END IF;

       BEGIN
            SELECT nvl(MARGIN_DERIVED_FROM_CODE,'B')
              INTO l_margin_derived_from_code
              FROM PA_PROJ_FP_OPTIONS
             WHERE project_id = p_project_id
               AND fin_plan_option_level_code = 'PLAN_TYPE'
               AND approved_cost_plan_type_flag = 'Y';

                IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:='margin dervied from code :'||l_margin_derived_from_code;
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                END IF;

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
                IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:='NO_DATA_FOUND for margin dervied from code,default to burdened cost';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                END IF;
                l_margin_derived_from_code := 'B';
       END;


   ----------------------------------------------------
   -- Fetch Lookup_code ,summary and reference details.
   ----------------------------------------------------
    IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Fetching lookup data';
       pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
    END IF;

   OPEN c_lookup_summary;
        FETCH c_lookup_summary BULK COLLECT INTO x_summary_tbl,l_lookup_code_tbl;
   CLOSE c_lookup_summary;

   OPEN c_lookup_reference;
        FETCH c_lookup_reference BULK COLLECT INTO x_reference_tbl;
   CLOSE c_lookup_reference;

    --Bug 5278200 Changed below code as if else condition
    IF nvl(p_calling_mode,'APPROVED') = 'APPROVED' THEN
    ----------------------------------------------------------------
    -- Fetching the approved revenue budget currenct working version
    ----------------------------------------------------------------
    -- Bug 3744910 -- This is being passed to get_pc_revenue_partial
    -- in c_change_documents_status cursor
        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='fetching the approved revenue current working version';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;
        BEGIN
        SELECT A.BUDGET_VERSION_ID
          INTO l_appr_rev_cw_version_id
          FROM PA_BUDGET_VERSIONS A
         WHERE A.PROJECT_ID = p_project_id
           AND A.VERSION_TYPE IN('ALL', 'REVENUE')
           AND A.APPROVED_REV_PLAN_TYPE_FLAG = 'Y'
           AND A.CURRENT_WORKING_FLAG = 'Y'
           AND A.CI_ID IS NULL;
    --       AND A.BUDGET_STATUS_CODE in ('S','W'); -- Bug#3815378

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='---l_appr_rev_cw_version_id----'||l_appr_rev_cw_version_id;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;


        EXCEPTION
          WHEN NO_DATA_FOUND THEN
               l_appr_rev_cw_version_id := null;
        END;

       -----------------------------------------------------
       -- Get Approved Fin plan Type Details for the project
       -----------------------------------------------------

       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Get Approved Fin plan Type Details for the project';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
       END IF;

       OPEN c_get_approved_details(p_project_id);
       FETCH c_get_approved_details BULK COLLECT INTO l_fin_plan_type_id_tbl,
                                                      l_fin_plan_preference_code_tbl,
                                                      l_rep_lab_from_code_tbl,
                                                      l_appr_cost_plan_type_flag_tbl,
                                                      l_appr_rev_plan_type_flag_tbl;
       CLOSE c_get_approved_details;

    ELSIF nvl(p_calling_mode,'APPROVED') = 'CURRENT' THEN
       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='fetching the revenue current working version of current plan type';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
       END IF;

       BEGIN
           SELECT A.BUDGET_VERSION_ID
           INTO l_appr_rev_cw_version_id
           FROM PA_BUDGET_VERSIONS A
           WHERE A.PROJECT_ID = p_project_id
           AND A.VERSION_TYPE IN('ALL', 'REVENUE')
           --AND A.APPROVED_REV_PLAN_TYPE_FLAG = 'Y'
           AND A.FIN_PLAN_TYPE_ID IN(select FIN_PLAN_TYPE_ID from
                                     PA_BUDGET_VERSIONS where
                                     budget_version_id in
                                     (p_cost_version_id,p_revenue_version_id))
           AND A.CURRENT_WORKING_FLAG = 'Y'
           AND A.CI_ID IS NULL;
           --AND A.BUDGET_STATUS_CODE in ('S','W'); -- Bug#3815378

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='---l_appr_rev_cw_version_id----'||l_appr_rev_cw_version_id;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
       END IF;


       EXCEPTION
        WHEN NO_DATA_FOUND THEN
              l_appr_rev_cw_version_id := null;
        END;

       l_fin_plan_type_id_tbl.extend(1);
       l_fin_plan_preference_code_tbl.extend(1);
       l_rep_lab_from_code_tbl.extend(1);
       l_appr_cost_plan_type_flag_tbl.extend(1);
       l_appr_rev_plan_type_flag_tbl.extend(1);

       SELECT  fin_plan_type_id,
               fin_plan_preference_code,
               report_labor_hrs_from_code
       INTO
                l_fin_plan_type_id_tbl(1),
                l_fin_plan_preference_code_tbl(1),
                l_rep_lab_from_code_tbl(1)
       FROM pa_proj_fp_options
       WHERE project_id = p_project_id
       AND fin_plan_option_level_code = 'PLAN_TYPE'
       AND fin_plan_type_id in(select FIN_PLAN_TYPE_ID from
                                      PA_BUDGET_VERSIONS where
                                      budget_version_id in (p_cost_version_id,p_revenue_version_id));
       l_appr_cost_plan_type_flag_tbl(1):='Y';
       l_appr_rev_plan_type_flag_tbl(1):='Y';

    END IF;
              IF l_fin_plan_type_id_tbl.COUNT = 0 THEN
                    --------------------------------------------------------------------------
                    --  Insert data as 0 in all pl sql tables.
                    --------------------------------------------------------------------------
                    IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:='No Approved Plan type in in the system for this project';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                    END IF;
                    l_row_count := x_summary_tbl.COUNT;
                    x_margin_tbl.extend(l_row_count);
                    x_margin_percent_tbl.extend(l_row_count);
                    x_equipment_hours_tbl.extend(l_row_count);
                    x_labor_hours_tbl.extend(l_row_count);
                    x_revenue_tbl.extend(l_row_count);
                    x_cost_tbl.extend(l_row_count);
                    x_url_tbl.extend(l_row_count);
                    FOR i IN x_summary_tbl.FIRST .. x_summary_tbl.LAST LOOP
                         x_equipment_hours_tbl(i) := 0;
                         x_labor_hours_tbl(i) := 0;
                         x_cost_tbl(i) := 0;
                         x_revenue_tbl(i) := 0;
                         x_margin_tbl(i) := 0;
                         x_margin_percent_tbl(i) := 0;
                         x_url_tbl(i) := '';
                    END LOOP;
                    l_continue_flag := 'N' ;
              ELSE
                    FOR i IN l_fin_plan_type_id_tbl.FIRST .. l_fin_plan_type_id_tbl.LAST LOOP
                            IF l_fin_plan_preference_code_tbl(i) = 'COST_ONLY' THEN
                               l_ac_fin_plan_type_id := l_fin_plan_type_id_tbl(i);
                            ELSIF l_fin_plan_preference_code_tbl(i) = 'REVENUE_ONLY' THEN
                               l_ar_fin_plan_type_id := l_fin_plan_type_id_tbl(i);
                            ELSIF l_fin_plan_preference_code_tbl(i) = 'COST_AND_REV_SAME' THEN
                               IF l_appr_cost_plan_type_flag_tbl(i) = 'Y' THEN
                                  l_ac_fin_plan_type_id := l_fin_plan_type_id_tbl(i);
                               END IF;
                               IF l_appr_rev_plan_type_flag_tbl(i) = 'Y' THEN
                                  l_ar_fin_plan_type_id := l_fin_plan_type_id_tbl(i);
                               END IF;
                            ELSIF l_fin_plan_preference_code_tbl(i) = 'COST_AND_REV_SEP' THEN
                               IF l_appr_cost_plan_type_flag_tbl(i) = 'Y' THEN
                                  l_ac_fin_plan_type_id := l_fin_plan_type_id_tbl(i);
                               END IF;
                               IF l_appr_rev_plan_type_flag_tbl(i) = 'Y' THEN
                                  l_ar_fin_plan_type_id := l_fin_plan_type_id_tbl(i);
                               END IF;
                            END IF;

                           IF l_fin_plan_type_id_tbl.COUNT = 1 THEN
                               IF l_fin_plan_preference_code_tbl(i) = 'COST_ONLY' THEN
                                  l_report_version_type := 'COST';
                               ELSIF l_fin_plan_preference_code_tbl(i) = 'REVENUE_ONLY' THEN
                                  l_report_version_type := 'REVENUE';
                               ELSIF l_fin_plan_preference_code_tbl(i) = 'COST_AND_REV_SAME' THEN
                                  l_report_version_type := 'ALL';
                               ELSIF l_fin_plan_preference_code_tbl(i) = 'COST_AND_REV_SEP' THEN
                                  l_report_version_type := l_rep_lab_from_code_tbl(i);
                               END IF;
                           ELSE
                               l_report_version_type := 'COST';
                           END IF;
                    END LOOP;
             END IF;
   --CLOSE c_get_approved_details;

   IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:='l_ac_fin_plan_type_id; '||l_ac_fin_plan_type_id;
      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

      pa_debug.g_err_stage:='l_ar_fin_plan_type_id; '||l_ar_fin_plan_type_id;
      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

      pa_debug.g_err_stage:='l_report_version_type :'||l_report_version_type;
      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
   END IF;

---------------------------------------------------------
-- Deriving plan type id for links in plan summary region
---------------------------------------------------------
   IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:='Deriving plan type id for links in plan summary region';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
   END IF;

   IF l_context = 'ALL' THEN
      IF l_ac_fin_plan_type_id IS NOT NULL THEN
         l_fin_plan_type_id := l_ac_fin_plan_type_id;
         IF l_ac_fin_plan_type_id = l_ar_fin_plan_type_id THEN
            l_next := 'ALL'; -- All here means cost and rev both
         ELSE
            l_next := 'COST';
         END IF;
      ELSE
         IF l_ar_fin_plan_type_id IS NOT NULL THEN
            l_fin_plan_type_id := l_ar_fin_plan_type_id;
            l_next := 'REVENUE';
         END IF;
      END IF;
   ELSIF l_context = 'COST' THEN
         IF l_ac_fin_plan_type_id IS NOT NULL THEN
            l_fin_plan_type_id := l_ac_fin_plan_type_id;
            l_next := 'COST';
         END IF;
   ELSIF l_context = 'REVENUE' THEN
         IF l_ar_fin_plan_type_id IS NOT NULL THEN
            l_fin_plan_type_id := l_ar_fin_plan_type_id;
            l_next := 'REVENUE';
         END IF;
   END IF;


   IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:='Derived l_fin_plan_type_id --- '||l_fin_plan_type_id;
      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

      pa_debug.g_err_stage:='Derived l_next --- '||l_next;
      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
   END IF;



   IF l_fin_plan_type_id IS NOT NULL THEN
       OPEN c_url_original_baseline(p_project_id,l_fin_plan_type_id,l_next); --bug 5278200
            FETCH c_url_original_baseline BULK COLLECT INTO l_budget_version_id_tbl,l_version_type_tbl;
                  IF l_budget_version_id_tbl.COUNT = 0 THEN
                     l_set_ob_url_flag := 'N';
                  ELSE
                     FOR j IN l_budget_version_id_tbl.FIRST .. l_budget_version_id_tbl.LAST LOOP
                         IF l_version_type_tbl(j) = 'COST' THEN
                            l_pa_ob_cost_bv_id := l_budget_version_id_tbl(j);
                            IF l_budget_version_id_tbl.COUNT = 1 THEN
                               l_pa_ob_revenue_bv_id := -99;
                            END IF;
                         ELSIF l_version_type_tbl(j) = 'REVENUE' THEN
                               l_pa_ob_revenue_bv_id := l_budget_version_id_tbl(j);
                               IF l_budget_version_id_tbl.COUNT = 1 THEN
                                  l_pa_ob_cost_bv_id := -99;
                               END IF;
                         ELSIF l_version_type_tbl(j) = 'ALL' THEN
                               l_pa_ob_cost_bv_id := l_budget_version_id_tbl(j);
                               l_pa_ob_revenue_bv_id := l_budget_version_id_tbl(j);
                         END IF;
                     END LOOP;
                  END IF;
       CLOSE c_url_original_baseline;

       OPEN c_url_current_baseline(p_project_id,l_fin_plan_type_id,l_next);--bug 5278200
            FETCH c_url_current_baseline BULK COLLECT INTO l_budget_version_id_tbl,l_version_type_tbl;
                  IF l_budget_version_id_tbl.COUNT = 0 THEN
                     l_set_cb_url_flag := 'N';
                  ELSE
                     FOR j IN l_budget_version_id_tbl.FIRST .. l_budget_version_id_tbl.LAST LOOP
                         IF l_version_type_tbl(j) = 'COST' THEN
                            l_pa_cb_cost_bv_id := l_budget_version_id_tbl(j);
                            IF l_budget_version_id_tbl.COUNT = 1 THEN
                               l_pa_cb_revenue_bv_id := -99;
                            END IF;
                         ELSIF l_version_type_tbl(j) = 'REVENUE' THEN
                               l_pa_cb_revenue_bv_id := l_budget_version_id_tbl(j);
                               IF l_budget_version_id_tbl.COUNT = 1 THEN
                                  l_pa_cb_cost_bv_id := -99;
                               END IF;
                         ELSIF l_version_type_tbl(j) = 'ALL' THEN
                               l_pa_cb_cost_bv_id := l_budget_version_id_tbl(j);
                               l_pa_cb_revenue_bv_id := l_budget_version_id_tbl(j);
                         END IF;
                     END LOOP;
                  END IF;
       CLOSE c_url_current_baseline;

       OPEN c_url_current_working(p_project_id,l_fin_plan_type_id,l_next);--bug 5278200
            FETCH c_url_current_working BULK COLLECT INTO l_budget_version_id_tbl,l_version_type_tbl;
                  IF l_budget_version_id_tbl.COUNT = 0 THEN
                     l_set_cw_url_flag := 'N';
                  ELSE
                     FOR j IN l_budget_version_id_tbl.FIRST .. l_budget_version_id_tbl.LAST LOOP
                         IF l_version_type_tbl(j) = 'COST' THEN
                            l_pa_cw_cost_bv_id := l_budget_version_id_tbl(j);
                            IF l_budget_version_id_tbl.COUNT = 1 THEN
                               l_pa_cw_revenue_bv_id := -99;
                            END IF;
                         ELSIF l_version_type_tbl(j) = 'REVENUE' THEN
                               l_pa_cw_revenue_bv_id := l_budget_version_id_tbl(j);
                               IF l_budget_version_id_tbl.COUNT = 1 THEN
                                  l_pa_cw_cost_bv_id := -99;
                               END IF;
                         ELSIF l_version_type_tbl(j) = 'ALL' THEN
                               l_pa_cw_cost_bv_id := l_budget_version_id_tbl(j);
                               l_pa_cw_revenue_bv_id := l_budget_version_id_tbl(j);
                         END IF;
                     END LOOP;
                  END IF;
       CLOSE c_url_current_working;
   END IF;

/*   The following logic is based on the following assumptions:
The lookup code signifies the data this is being shown in the region as follows:
As of now:
10 Original Baselined Version
20 Change Documents from Prior Baselined Versions
30 Adjustments from Prior Baselined Versions
40 Current Baseline
50 Change Documents Included in this Version
60 Adjustments
70 Total Current Working
80 Approved Change Documents
90 Working Change Documents
100 Submitted Change Documents
110 Projected Total

Disclaimer: Please note that the actual and latest mapping of the above can be got from
pa_lookups as follows:
select lookup_code, meaning
from  pa_lookupus
where lookup_type = 'PA_FP_CI_PLAN_SUMMARY'
order by to_number(lookup_code);

Description for the lookup type has been updated as well saying that sayijng the code is
used as number internally.*/
   IF l_continue_flag = 'Y' THEN

       FOR i IN l_lookup_code_tbl.FIRST .. l_lookup_code_tbl.LAST LOOP

            x_url_tbl.extend(1);
            x_equipment_hours_tbl.extend(1);
            x_labor_hours_tbl.extend(1);
            x_cost_tbl.extend(1);
            x_revenue_tbl.extend(1);
            x_url_tbl.extend(1);

           IF l_lookup_code_tbl(i) = 10 THEN
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Fetching Data for Original Baselined Version';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 OPEN c_original_baselined(p_project_id,
                                           l_ac_fin_plan_type_id,
                                           l_ar_fin_plan_type_id,
                                           l_margin_derived_from_code ,
                                           l_report_version_type);
                        FETCH c_original_baselined INTO l_labor_quantity,
                                                        l_equipment_quantity,
                                                        l_cost,
                                                        l_revenue;
                 CLOSE c_original_baselined;
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='l_labor_quantity:'||l_labor_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_equipment_quantity:'||l_equipment_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_cost:'||l_cost;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_revenue:'||l_revenue;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;

                 IF l_fin_plan_type_id IS NOT NULL THEN
                     -- Bug 3883406
                     -- URL to be built for view plan page, depending if the current context is task_summary or resource_summary.
                     IF (p_page_context = 'VIEWPLAN_TASK' OR p_page_context = 'VIEWPLAN_RESOURCE') THEN
                         IF ((l_next = 'COST') AND (p_cost_version_id = l_pa_ob_cost_bv_id)) OR
                            ((l_next = 'REVENUE') AND (p_revenue_version_id = l_pa_ob_revenue_bv_id)) OR
                            ((l_next = 'ALL') AND ((p_cost_version_id = l_pa_ob_cost_bv_id) AND
                                                   (p_revenue_version_id = l_pa_ob_revenue_bv_id))) THEN
                             l_set_ob_url_flag := 'N';
                         END IF;
                     END IF;
                 ELSE
                     l_set_ob_url_flag := 'N';
                 END IF;

                 IF l_set_ob_url_flag = 'Y' THEN
                     -- Bug 3883406
                     -- URL to be built for view plan page, depending if the current context is task_summary or resource_summary.
                    IF p_page_context = 'VIEWPLAN_TASK' THEN
                       x_url_tbl(i) := 'OA.jsp?page=/oracle/apps/pji/viewplan/reporting/webui/VPBudgetTaskSumPG&paProjectId='||p_project_id
                       ||'&paFinTypeId='||l_fin_plan_type_id
                       ||'&paCstContextVersionId='||l_pa_ob_cost_bv_id
                       ||'&paRevContextVersionId='||l_pa_ob_revenue_bv_id
                       ||'&addBreadCrumb=Y&retainAM=N';
                    ELSIF p_page_context = 'VIEWPLAN_RESOURCE' THEN
                       x_url_tbl(i) := 'OA.jsp?page=/oracle/apps/pji/viewplan/reporting/webui/VPBudgetResSumPG&paProjectId='||p_project_id
                       ||'&paFinTypeId='||l_fin_plan_type_id
                       ||'&paCstContextVersionId='||l_pa_ob_cost_bv_id
                       ||'&paRevContextVersionId='||l_pa_ob_revenue_bv_id
                       ||'&addBreadCrumb=Y&retainAM=N';
                    END IF;
                 END IF;

           ELSIF l_lookup_code_tbl(i) = 20 THEN
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Fetching Data for Change Docs fom Prior Baselined Versions';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 OPEN c_change_documents_prior(p_project_id,
                                               l_ac_fin_plan_type_id,
                                               l_ar_fin_plan_type_id,
                                               l_margin_derived_from_code,
                                               l_report_version_type); -- Raja review
                        FETCH c_change_documents_prior INTO l_labor_quantity,
                                                            l_equipment_quantity,
                                                            l_cost,
                                                            l_revenue;
                 CLOSE c_change_documents_prior;
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='l_labor_quantity:'||l_labor_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_equipment_quantity:'||l_equipment_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_cost:'||l_cost;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_revenue:'||l_revenue;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;

                 IF l_fin_plan_type_id IS NOT NULL THEN
                    IF (l_next = 'COST' OR l_next = 'ALL') THEN
                       l_bv_id := l_pa_cb_cost_bv_id;
                    ELSE
                       l_bv_id := l_pa_cb_revenue_bv_id;
                    END IF;

                    IF (p_page_context = 'VIEWCD' AND ((l_bv_id = p_cost_version_id) OR (l_bv_id = p_revenue_version_id))) THEN
                        l_set_cpb_url_flag := 'N';
                    END IF;

                 ELSE
                    l_set_cpb_url_flag := 'N';
                 END IF;

                 IF l_set_cpb_url_flag = 'Y' AND l_set_cb_url_flag = 'Y' THEN
                    x_url_tbl(i) := 'OA.jsp?page=/oracle/apps/pa/finplan/webui/FpCiIncldedPG&paProjectId='||p_project_id
                                    ||'&paPageContext=VIEWCD'
                                    ||'&paBudgetVersionId='||l_bv_id||'&addBreadCrumb=Y&retainAM=N';
                 END IF;

           ELSIF l_lookup_code_tbl(i) = 30 THEN   /* fetching data for Adjustments from Prior Baseline Versions */
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Fetching Data for Current Baselined';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 OPEN c_current_baselined(p_project_id,
                                          l_ac_fin_plan_type_id,
                                          l_ar_fin_plan_type_id,
                                          l_margin_derived_from_code ,
                                          l_report_version_type);
                        FETCH c_current_baselined INTO l_cb_labor_quantity,
                                                       l_cb_equipment_quantity,
                                                       l_cb_cost,
                                                       l_cb_revenue;
                 CLOSE c_current_baselined;
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='l_cb_labor_quantity:'||l_cb_labor_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_cb_equipment_quantity:'||l_cb_equipment_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_cb_cost:'||l_cb_cost;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_cb_revenue:'||l_cb_revenue;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;

                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Inserting Data for Adjustments from Prior versions';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 x_equipment_hours_tbl(i) := l_cb_equipment_quantity -
                                             x_equipment_hours_tbl(i-1) -
                                             x_equipment_hours_tbl(i-2);
                 x_labor_hours_tbl(i) := l_cb_labor_quantity -
                                         x_labor_hours_tbl(i-1) -
                                         x_labor_hours_tbl(i-2);
                 x_cost_tbl(i) := l_cb_cost -
                                  x_cost_tbl(i-1) -
                                  x_cost_tbl(i-2);
                 x_revenue_tbl(i) := l_cb_revenue -
                                     x_revenue_tbl(i-1) -
                                     x_revenue_tbl(i-2);
                 l_assigned_flag := 'Y';

           ELSIF l_lookup_code_tbl(i) = 40 THEN

                 IF l_fin_plan_type_id IS NOT NULL THEN
                     -- Bug 3883406
                     -- URL to be built for view plan page, depending if the current context is task_summary or resource_summary.
                    IF (p_page_context = 'VIEWPLAN_TASK' OR p_page_context = 'VIEWPLAN_RESOURCE') THEN
                         IF ((l_next = 'COST') AND (p_cost_version_id = l_pa_cb_cost_bv_id)) OR
                            ((l_next = 'REVENUE') AND (p_revenue_version_id = l_pa_cb_revenue_bv_id)) OR
                            ((l_next = 'ALL') AND ((p_cost_version_id = l_pa_cb_cost_bv_id) AND
                                                   (p_revenue_version_id = l_pa_cb_revenue_bv_id))) THEN
                             l_set_cb_url_flag := 'N';
                         END IF;
                     END IF;

                 ELSE
                     l_set_cb_url_flag := 'N';
                 END IF;

                 IF l_set_cb_url_flag = 'Y' THEN
                     -- Bug 3883406
                     -- URL to be built for view plan page, depending if the current context is task_summary or resource_summary.
                    IF p_page_context = 'VIEWPLAN_TASK' THEN
                       x_url_tbl(i) := 'OA.jsp?page=/oracle/apps/pji/viewplan/reporting/webui/VPBudgetTaskSumPG&paProjectId='||p_project_id
                       ||'&paFinTypeId='||l_fin_plan_type_id
                       ||'&paCstContextVersionId='||l_pa_cb_cost_bv_id
                       ||'&paRevContextVersionId='||l_pa_cb_revenue_bv_id
                       ||'&addBreadCrumb=Y&retainAM=N';
                    ELSIF p_page_context = 'VIEWPLAN_RESOURCE' THEN
                       x_url_tbl(i) := 'OA.jsp?page=/oracle/apps/pji/viewplan/reporting/webui/VPBudgetResSumPG&paProjectId='||p_project_id
                       ||'&paFinTypeId='||l_fin_plan_type_id
                       ||'&paCstContextVersionId='||l_pa_cb_cost_bv_id
                       ||'&paRevContextVersionId='||l_pa_cb_revenue_bv_id
                       ||'&addBreadCrumb=Y&retainAM=N';
                    END IF;
                 END IF;

                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='l_cb_labor_quantity:'||l_cb_labor_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_cb_equipment_quantity:'||l_cb_equipment_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_cb_cost:'||l_cb_cost;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_cb_revenue:'||l_cb_revenue;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;

                 x_equipment_hours_tbl(i) := l_cb_equipment_quantity;
                 x_labor_hours_tbl(i) := l_cb_labor_quantity;
                 x_cost_tbl(i) := l_cb_cost;
                 x_revenue_tbl(i) := l_cb_revenue;
                 l_assigned_flag := 'Y';

           ELSIF l_lookup_code_tbl(i) = 50 THEN
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Fetching Data for Change Docs fom Current Versions';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 OPEN c_change_documents_current(p_project_id,
                                                 l_ac_fin_plan_type_id,
                                                 l_ar_fin_plan_type_id,
                                                 l_margin_derived_from_code,
                                                  l_report_version_type); -- Raja review
                        FETCH c_change_documents_current INTO l_labor_quantity,
                                                              l_equipment_quantity,
                                                              l_cost,
                                                              l_revenue;
                 CLOSE c_change_documents_current;
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='l_labor_quantity:'||l_labor_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_equipment_quantity:'||l_equipment_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_cost:'||l_cost;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_revenue:'||l_revenue;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;

                 IF l_fin_plan_type_id IS NOT NULL THEN
                    IF (l_next = 'COST' OR l_next = 'ALL') THEN
                       l_bv_id := l_pa_cw_cost_bv_id;
                    ELSE
                       l_bv_id := l_pa_cw_revenue_bv_id;
                    END IF;

                    IF (p_page_context = 'VIEWCD' AND ((l_bv_id = p_cost_version_id) OR (l_bv_id = p_revenue_version_id))) THEN
                        l_set_ccw_url_flag := 'N';
                    END IF;

                 ELSE
                    l_set_ccw_url_flag := 'N';
                 END IF;

                 IF l_set_ccw_url_flag = 'Y' AND l_set_cw_url_flag = 'Y' THEN
                    x_url_tbl(i) := 'OA.jsp?page=/oracle/apps/pa/finplan/webui/FpCiIncldedPG&paProjectId='||p_project_id
                                    ||'&paPageContext=VIEWCD'
                                    ||'&paBudgetVersionId='||l_bv_id||'&addBreadCrumb=Y&retainAM=N';
                 END IF;


           ELSIF l_lookup_code_tbl(i) = 60 THEN
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Fetching Data for Current Working';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 OPEN c_current_working(p_project_id,
                                        l_ac_fin_plan_type_id,
                                        l_ar_fin_plan_type_id,
                                        l_margin_derived_from_code ,
                                        l_report_version_type);
                        FETCH c_current_working INTO l_cw_labor_quantity,
                                                     l_cw_equipment_quantity,
                                                     l_cw_cost,
                                                     l_cw_revenue;
                 CLOSE c_current_working;
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='l_cw_labor_quantity:'||l_cw_labor_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_cw_equipment_quantity:'||l_cw_equipment_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_cw_cost:'||l_cw_cost;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_cw_revenue:'||l_cw_revenue;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;

                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Inserting Data for Adjustments';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 x_equipment_hours_tbl(i) := l_cw_equipment_quantity -
                                             x_equipment_hours_tbl(i-1) -
                                             x_equipment_hours_tbl(i-2);
                 x_labor_hours_tbl(i) := l_cw_labor_quantity -
                                         x_labor_hours_tbl(i-1) -
                                         x_labor_hours_tbl(i-2);
                 x_cost_tbl(i) := l_cw_cost -
                                  x_cost_tbl(i-1) -
                                  x_cost_tbl(i-2);
                 x_revenue_tbl(i) := l_cw_revenue -
                                     x_revenue_tbl(i-1) -
                                     x_revenue_tbl(i-2);

                 l_assigned_flag := 'Y';

           ELSIF l_lookup_code_tbl(i) = 70 THEN

                 IF l_fin_plan_type_id IS NOT NULL THEN
                     -- Bug 3883406
                     -- URL to be built for view plan page, depending if the current context is task_summary or resource_summary.
                     IF (p_page_context = 'VIEWPLAN_TASK' OR p_page_context = 'VIEWPLAN_RESOURCE') THEN
                         IF ((l_next = 'COST') AND (p_cost_version_id = l_pa_cw_cost_bv_id)) OR
                            ((l_next = 'REVENUE') AND (p_revenue_version_id = l_pa_cw_revenue_bv_id)) OR
                            ((l_next = 'ALL') AND ((p_cost_version_id = l_pa_cw_cost_bv_id) AND
                                                   (p_revenue_version_id = l_pa_cw_revenue_bv_id))) THEN
                             l_set_cw_url_flag := 'N';
                         END IF;
                     END IF;
                 ELSE
                     l_set_cw_url_flag := 'N';
                 END IF;

                 IF l_set_cw_url_flag = 'Y' THEN
                     -- Bug 3883406
                     -- URL to be built for view plan page, depending if the current context is task_summary or resource_summary.
                    IF p_page_context = 'VIEWPLAN_TASK' THEN
                       x_url_tbl(i) := 'OA.jsp?page=/oracle/apps/pji/viewplan/reporting/webui/VPBudgetTaskSumPG&paProjectId='||p_project_id
                       ||'&paFinTypeId='||l_fin_plan_type_id
                       ||'&paCstContextVersionId='||l_pa_cw_cost_bv_id
                       ||'&paRevContextVersionId='||l_pa_cw_revenue_bv_id
                       ||'&addBreadCrumb=Y&retainAM=N';
                    ELSIF p_page_context = 'VIEWPLAN_RESOURCE' THEN
                       x_url_tbl(i) := 'OA.jsp?page=/oracle/apps/pji/viewplan/reporting/webui/VPBudgetResSumPG&paProjectId='||p_project_id
                       ||'&paFinTypeId='||l_fin_plan_type_id
                       ||'&paCstContextVersionId='||l_pa_cw_cost_bv_id
                       ||'&paRevContextVersionId='||l_pa_cw_revenue_bv_id
                       ||'&addBreadCrumb=Y&retainAM=N';
                    END IF;
                 END IF;

                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='l_cw_labor_quantity:'||l_cw_labor_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_cw_equipment_quantity:'||l_cw_equipment_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_cw_cost:'||l_cw_cost;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_cw_revenue:'||l_cw_revenue;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;


                 x_equipment_hours_tbl(i) := l_cw_equipment_quantity;
                 x_labor_hours_tbl(i) := l_cw_labor_quantity;
                 x_cost_tbl(i) := l_cw_cost;
                 x_revenue_tbl(i) := l_cw_revenue;
                 l_assigned_flag := 'Y';

           ELSIF l_lookup_code_tbl(i) = 80 THEN
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Fetching Data for Change Docs of System Status Approved';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 OPEN c_change_documents_status(p_project_id,
                                                'CI_APPROVED',
                                                l_margin_derived_from_code,
                                                l_report_version_type,
                                                l_appr_rev_cw_version_id); -- Raja review
                        FETCH c_change_documents_status INTO l_labor_quantity,
                                                             l_equipment_quantity,
                                                             l_cost,
                                                             l_revenue;
                 CLOSE c_change_documents_status;
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='l_labor_quantity:'||l_labor_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_equipment_quantity:'||l_equipment_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_cost:'||l_cost;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_revenue:'||l_revenue;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;

           ELSIF l_lookup_code_tbl(i) = 90 THEN
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Fetching Data for Change Docs of System Status Working';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 OPEN c_change_documents_status(p_project_id,
                                                'CI_WORKING',
                                                l_margin_derived_from_code,
                                                l_report_version_type,
                                                l_appr_rev_cw_version_id); -- Raja review
                        FETCH c_change_documents_status INTO l_labor_quantity,
                                                             l_equipment_quantity,
                                                             l_cost,
                                                             l_revenue;
                 CLOSE c_change_documents_status;
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='l_labor_quantity:'||l_labor_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_equipment_quantity:'||l_equipment_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_cost:'||l_cost;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_revenue:'||l_revenue;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;

           ELSIF l_lookup_code_tbl(i) = 100 THEN
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Fetching Data for Change Docs of System Status Submitted';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 OPEN c_change_documents_status(p_project_id,
                                                'CI_SUBMITTED',
                                                l_margin_derived_from_code,
                                                l_report_version_type,
                                                l_appr_rev_cw_version_id); -- Raja review
                        FETCH c_change_documents_status INTO l_labor_quantity,
                                                             l_equipment_quantity,
                                                             l_cost,
                                                             l_revenue;
                 CLOSE c_change_documents_status;
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='l_labor_quantity:'||l_labor_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_equipment_quantity:'||l_equipment_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_cost:'||l_cost;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_revenue:'||l_revenue;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;

           ELSIF l_lookup_code_tbl(i) = 110 THEN
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Fetching Data for Projected Total';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                x_equipment_hours_tbl(i) := x_equipment_hours_tbl(i-4) +
                                            x_equipment_hours_tbl(i-3) +
                                            x_equipment_hours_tbl(i-2) +
                                            x_equipment_hours_tbl(i-1);
                x_labor_hours_tbl(i) := x_labor_hours_tbl(i-4) +
                                        x_labor_hours_tbl(i-3) +
                                        x_labor_hours_tbl(i-2) +
                                        x_labor_hours_tbl(i-1);
                x_cost_tbl(i) := x_cost_tbl(i-4) +
                                 x_cost_tbl(i-3) +
                                 x_cost_tbl(i-2) +
                                 x_cost_tbl(i-1);
                x_revenue_tbl(i) := x_revenue_tbl(i-4) +
                                    x_revenue_tbl(i-3) +
                                    x_revenue_tbl(i-2) +
                                    x_revenue_tbl(i-1);
                l_assigned_flag := 'Y';
           END IF;

           IF l_assigned_flag = 'N' THEN
                x_equipment_hours_tbl(i) := l_equipment_quantity;
                x_labor_hours_tbl(i) := l_labor_quantity;
                x_cost_tbl(i) := l_cost;
                x_revenue_tbl(i) := l_revenue;
           END IF;

           l_assigned_flag := 'N';

       END LOOP;
   END IF;

   IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:='Deriving Margin and Margin Percent';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
   END IF;

   l_row_count := x_summary_tbl.COUNT;
   IF l_row_count > 0 THEN
       x_margin_tbl.extend(l_row_count);
       x_margin_percent_tbl.extend(l_row_count);
       FOR i IN x_cost_tbl.FIRST .. x_cost_tbl.LAST LOOP
           x_margin_tbl(i) := x_revenue_tbl(i) - x_cost_tbl(i);
           IF x_revenue_tbl(i) <> 0 THEN
              x_margin_percent_tbl(i) := (x_margin_tbl(i)/x_revenue_tbl(i))*100;
           ELSE
              x_margin_percent_tbl(i) := 0;
           END IF;
       END LOOP;
   END IF;

  /* Bug 4038253 : returning the report_labor_hrs_from_code attribute for the version
     if the preference code of the plan type is COST_AND_REVENUE_SEP, otherwise returning null*/
  IF l_context = 'COST' OR l_context = 'REVENUE' THEN

      l_report_labor_hrs_code := null;
      BEGIN
            -- getting the preference code of the plan type for the budget version
            SELECT fin_plan_preference_code,
                   report_labor_hrs_from_code
            INTO   l_pref_code_for_pt_of_ver,
                   l_report_labor_hrs_code
            FROM   pa_proj_fp_options
            WHERE  project_id = p_project_id
            AND    fin_plan_type_id = l_fin_plan_type_id
            AND    fin_plan_option_level_code = 'PLAN_TYPE';
      EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 null;
      END;

      IF l_pref_code_for_pt_of_ver = 'COST_AND_REV_SEP' THEN
           x_report_labor_hrs_code := l_report_labor_hrs_code;
      ELSE
           x_report_labor_hrs_code := null;
      END IF;
  END IF; /* COST or REVENUE version */
   /* Bug 4038253 :ends */

   pa_debug.reset_curr_function;

   EXCEPTION
     WHEN PA_FP_CONSTANTS_PKG.Just_Ret_Exc THEN
      IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Exiting out as there are insufficient Parameters..'||SQLERRM;
             pa_debug.write('get_summary_data: ' || g_module_name,pa_debug.g_err_stage,5);
           END IF;
     pa_debug.reset_curr_function;
     RETURN;

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
           pa_debug.reset_curr_function;
           RETURN;

     WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FP_CONTROL_ITEMS_UTILS'
                                  ,p_procedure_name  => 'get_summary_data');

           IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write('get_summary_data: ' || g_module_name,pa_debug.g_err_stage,5);
           END IF;
          pa_debug.reset_curr_function;
          RAISE;

END get_summary_data;




--------------------------------------------------------------------------------
-- Please note that this function is called for Include Change Doc Page PLSql Apis
-- View included Change Doc PlSql APIs, VO Queries, Change Doc Merge Apis

-- 07-Jun-2004 Raja Added new input parameter p_pt_ct_version_type b/c for 'ALL'
-- change order versions, there would be two records in pa_pt_co_impl_statuses
-- table and so the view returns PA_FP_ELIGIBLE_CI_V two records.
-- How to avoid double count here? If ci_version is 'ALL' and target version is
-- also 'ALL', then compute quantity only if p_pt_ct_version_type is 'COST' as
-- in this case Quantity gets merged along with cost amounts

-- Note: In some cases, p_pt_ct_version_type is passed as null in this case
-- values are returned without bothering about double count.
--------------------------------------------------------------------------------
FUNCTION get_labor_qty_partial(
         p_version_type        IN   pa_budget_versions.version_type%TYPE, -- This is the CI version type
         p_budget_version_id   IN   pa_budget_versions.budget_version_id%TYPE,
         p_ci_version_id       IN   pa_budget_versions.budget_version_id%TYPE,
         p_labor_qty           IN   pa_budget_versions.labor_quantity%TYPE DEFAULT NULL, -- CI qty
         p_pt_ct_version_type  IN   pa_pt_co_impl_statuses.version_type%TYPE DEFAULT NULL
         )
RETURN NUMBER
IS
 l_debug_mode VARCHAR2(30);
 l_module_name VARCHAR2(30) := 'ctrl_utils.lab_qty_prtial';
 l_source_version_type pa_budget_versions.version_type%TYPE;
 l_target_version_type pa_budget_versions.version_type%TYPE;
 l_impl_qty_exists VARCHAR2(1) := 'N';
 l_revenue_partial_flag varchar2(1) := 'N';
 l_return_quantity PA_BUDGET_VERSIONS.LABOR_QUANTITY%TYPE;
 l_partial_quantity PA_BUDGET_VERSIONS.LABOR_QUANTITY%TYPE;
 l_labor_quantity PA_BUDGET_VERSIONS.LABOR_QUANTITY%TYPE;
 l_appr_rev_cw_version_id PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE;
BEGIN
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='In get_labor_qty_partial - pa_fp_control_items_utils ';
       pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
    END IF;

-------------------------------
-- Fetching source version type
-------------------------------
    IF p_version_type IS NULL THEN
        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='fetching source version type';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;
        BEGIN
            SELECT VERSION_TYPE
              INTO l_source_version_type
              FROM PA_BUDGET_VERSIONS
             WHERE BUDGET_VERSION_ID = p_ci_version_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF l_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage:='source version does not exist';
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 RAISE;
        END;
    ELSE
        l_source_version_type := p_version_type;
    END IF;

-------------------------------
-- Fetching target version type
-------------------------------
    IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='fetching target version type';
       pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
    END IF;
    BEGIN
        SELECT VERSION_TYPE
          INTO l_target_version_type
          FROM PA_BUDGET_VERSIONS
         WHERE BUDGET_VERSION_ID = p_budget_version_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='target version does not exist';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
             END IF;
             RAISE;
    END;

-----------------------------------
-- Fetching labor quantity
-----------------------------------
    IF p_labor_qty IS NULL THEN
        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Fetching labor quantity';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;
        BEGIN
            SELECT labor_quantity
              INTO l_labor_quantity
              FROM PA_BUDGET_VERSIONS
             WHERE BUDGET_VERSION_ID = p_ci_version_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF l_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage:='source version does not exist';
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 RAISE;
        END;
    ELSE
        l_labor_quantity := p_labor_qty;
    END IF;

----------------------------------------
-- Deriving qty based on source version
----------------------------------------
    IF l_source_version_type = 'COST' THEN
        IF l_target_version_type = 'COST' OR l_target_version_type = 'ALL' THEN
            BEGIN
                SELECT 'Y'
                  INTO l_impl_qty_exists
                  FROM DUAL
                 WHERE EXISTS (SELECT 1
                                 FROM PA_FP_MERGED_CTRL_ITEMS
                                WHERE CI_PLAN_VERSION_ID = p_ci_version_id
                                  AND PLAN_VERSION_ID = p_budget_version_id
                                  AND VERSION_TYPE = 'COST');
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_impl_qty_exists := 'N';
            END;

            IF l_impl_qty_exists = 'Y' THEN
                RETURN 0;
            ELSE
                RETURN l_labor_quantity;
            END IF;
        ELSE
            RETURN 0;
        END IF;

    ELSIF l_source_version_type = 'REVENUE' THEN
        IF l_target_version_type = 'COST'
           OR l_target_version_type = 'ALL'  -- Raja review
           -- For ALL versions Quantity is computed from Cost Versions only
        THEN
            RETURN 0;
        ELSIF l_target_version_type = 'REVENUE' -- Raja review OR l_target_version_type = 'ALL'
        THEN
              BEGIN
                IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Check if record exits in pa_fp_merged_ctl_items';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                END IF;
                SELECT 'Y'
                  INTO l_impl_qty_exists
                  FROM DUAL
                  WHERE EXISTS (SELECT 1
                                  FROM PA_FP_MERGED_CTRL_ITEMS A
                                 WHERE A.CI_PLAN_VERSION_ID = P_CI_VERSION_ID
                                   AND A.PLAN_VERSION_ID = P_BUDGET_VERSION_ID
                                   AND A.VERSION_TYPE = 'REVENUE');
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                RETURN l_labor_quantity;
              END;
              ------------------------------------------------
              -- If record exists then check for partial flag
              ------------------------------------------------
               IF l_impl_qty_exists = 'Y' THEN
                   BEGIN
                       SELECT NVL(B.REV_PARTIALLY_IMPL_FLAG,'N') , A.IMPL_QUANTITY
                         INTO l_revenue_partial_flag, l_partial_quantity
                         FROM PA_FP_MERGED_CTRL_ITEMS A , PA_BUDGET_VERSIONS B
                        WHERE A.CI_PLAN_VERSION_ID = p_ci_version_id
                          AND A.PLAN_VERSION_ID = p_budget_version_id
                          AND A.VERSION_TYPE = 'REVENUE'
                          AND B.BUDGET_VERSION_ID = A.CI_PLAN_VERSION_ID;

                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                          NULL;
                  END;

                  IF l_revenue_partial_flag = 'Y' THEN

                     --Moved the code here to fetch the aprroved revenue current working budget
                     --version when source and target version type is 'REVENUE' and
                     --when l_impl_qty_exists = 'Y'
                     --For bug 3902176
                     ----------------------------------------------------------------
                     -- Fetching the approved revenue current working budget version
                     ----------------------------------------------------------------
                     IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:='fetching the approved revenue current working version';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                     END IF;
                     BEGIN
                        SELECT A.BUDGET_VERSION_ID
                        INTO l_appr_rev_cw_version_id
                        FROM PA_BUDGET_VERSIONS A
                        WHERE A.PROJECT_ID = (SELECT B.PROJECT_ID FROM PA_BUDGET_VERSIONS B
                                              WHERE B.BUDGET_VERSION_ID = p_budget_version_id)
                        AND A.VERSION_TYPE IN ('REVENUE', 'ALL')
                        -- Raja review A.VERSION_TYPE = 'REVENUE'
                        AND A.APPROVED_REV_PLAN_TYPE_FLAG = 'Y'
                        AND CURRENT_WORKING_FLAG = 'Y'
                        AND A.CI_ID IS NULL;
                        --  AND A.BUDGET_STATUS_CODE in ('S','W'); -- Bug#3815378

                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            NULL;
                     END;

                     IF p_budget_version_id = l_appr_rev_cw_version_id THEN
                         l_return_quantity := l_labor_quantity - l_partial_quantity;
                     ELSE
                         l_return_quantity := 0;
                     END IF;
                     RETURN l_return_quantity;
                  ELSIF l_revenue_partial_flag ='N' THEN
                     l_return_quantity := 0;
                     RETURN l_return_quantity;
                  END IF;
               END IF;
        END IF;

    ELSIF l_source_version_type = 'ALL' THEN
          IF l_target_version_type = 'COST' OR
             (l_target_version_type = 'ALL' AND nvl(p_pt_ct_version_type,'COST') = 'COST') THEN
              -- To avoid double count check for pt_ct_version_type
            BEGIN
                SELECT 'Y'
                  INTO l_impl_qty_exists
                  FROM DUAL
                 WHERE EXISTS (SELECT 1
                                 FROM PA_FP_MERGED_CTRL_ITEMS
                                WHERE CI_PLAN_VERSION_ID = p_ci_version_id
                                  AND PLAN_VERSION_ID = p_budget_version_id
                                  AND VERSION_TYPE = 'COST');
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_impl_qty_exists := 'N';
            END;

            IF l_impl_qty_exists = 'Y' THEN
                RETURN 0;
            ELSE
                RETURN l_labor_quantity;
            END IF;
          -- Bug 3678063 this case is missing
          ELSIF l_target_version_type = 'ALL' AND nvl(p_pt_ct_version_type,'COST') <> 'COST' THEN
                RETURN 0;
          ELSIF l_target_version_type = 'REVENUE' THEN
                  -- For bug 3902176
                  -- Commented out the code to
                  -- Return 0 if Source Version = 'ALL' and Target Version 'REVENUE'
                  RETURN 0;

                  /*
                  BEGIN
                    IF l_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage:='Check if record exits in pa_fp_merged_ctl_items';
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                    END IF;
                    SELECT 'Y'
                      INTO l_impl_qty_exists
                      FROM DUAL
                      WHERE EXISTS (SELECT 1
                                      FROM PA_FP_MERGED_CTRL_ITEMS A
                                     WHERE A.CI_PLAN_VERSION_ID = P_CI_VERSION_ID
                                       AND A.PLAN_VERSION_ID = P_BUDGET_VERSION_ID
                                       AND A.VERSION_TYPE = 'REVENUE');
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    RETURN l_labor_quantity;
                  END;
              ------------------------------------------------
              -- If record exists then check for partial flag
              ------------------------------------------------
                  IF l_impl_qty_exists = 'Y' THEN
                      BEGIN
                          SELECT NVL(B.REV_PARTIALLY_IMPL_FLAG,'N') , A.IMPL_QUANTITY
                            INTO l_revenue_partial_flag, l_partial_quantity
                            FROM PA_FP_MERGED_CTRL_ITEMS A , PA_BUDGET_VERSIONS B
                           WHERE A.CI_PLAN_VERSION_ID = p_ci_version_id
                             AND A.PLAN_VERSION_ID = p_budget_version_id
                             AND A.VERSION_TYPE = 'REVENUE'
                             AND B.BUDGET_VERSION_ID = A.CI_PLAN_VERSION_ID;
                      EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                 NULL;
                      END;
                      IF l_revenue_partial_flag = 'Y' THEN
                        IF p_budget_version_id = l_appr_rev_cw_version_id THEN
                            l_return_quantity := l_labor_quantity - l_partial_quantity;
                        ELSE
                            l_return_quantity := 0;
                        END IF;
                        RETURN l_return_quantity;
                     ELSIF l_revenue_partial_flag ='N' THEN
                        l_return_quantity := 0;
                        RETURN l_return_quantity;
                     END IF;
                  END IF; */
          END IF;
    END IF;
END get_labor_qty_partial;

--------------------------------------------------------------------------------
-- Please note that this function is called for Include Change Doc Page PLSql Apis
-- View included Change Doc PlSql APIs, VO Queries, Change Doc Merge Apis

-- 07-Jun-2004 Raja Added new input parameter p_pt_ct_version_type b/c for 'ALL'
-- change order versions, there would be two records in pa_pt_co_impl_statuses
-- table and so the view returns PA_FP_ELIGIBLE_CI_V two records.
-- How to avoid double count here?  If ci_version is 'ALL' and target version is
-- also 'ALL', then compute quantity only if p_pt_ct_version_type is 'COST' as
-- in this case Quantity gets merged along with cost amounts

-- Note: In some cases, p_pt_ct_version_type is passed as null in this case
-- values are returned without bothering about double count.

--------------------------------------------------------------------------------

FUNCTION get_equip_qty_partial(
         p_version_type        IN   pa_budget_versions.version_type%TYPE, -- This is the CI version type
         p_budget_version_id   IN   pa_budget_versions.budget_version_id%TYPE,
         p_ci_version_id       IN   pa_budget_versions.budget_version_id%TYPE,
         p_equip_qty           IN   pa_budget_versions.equipment_quantity%TYPE DEFAULT NULL, -- CI qty
         p_pt_ct_version_type  IN   pa_pt_co_impl_statuses.version_type%TYPE DEFAULT NULL
         )
RETURN NUMBER
IS
 l_debug_mode VARCHAR2(30);
 l_module_name VARCHAR2(30) := 'ctrl_utils.equip_qty_prtial';
 l_source_version_type pa_budget_versions.version_type%TYPE;
 l_target_version_type pa_budget_versions.version_type%TYPE;
 l_impl_qty_exists VARCHAR2(1) := 'N';
 l_revenue_partial_flag varchar2(1) := 'N';
 l_return_quantity PA_BUDGET_VERSIONS.EQUIPMENT_QUANTITY%TYPE;
 l_partial_quantity PA_BUDGET_VERSIONS.EQUIPMENT_QUANTITY%TYPE;
 l_equip_quantity PA_BUDGET_VERSIONS.EQUIPMENT_QUANTITY%TYPE;
 l_appr_rev_cw_version_id PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE;
BEGIN
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='In get_equip_qty_partial - pa_fp_control_items_utils ';
       pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
    END IF;

-------------------------------
-- Fetching source version type
-------------------------------
    IF p_version_type IS NULL THEN
        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='fetching source version type';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;
        BEGIN
            SELECT VERSION_TYPE
              INTO l_source_version_type
              FROM PA_BUDGET_VERSIONS
             WHERE BUDGET_VERSION_ID = p_ci_version_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF l_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage:='source version does not exist';
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 RAISE;
        END;
    ELSE
        l_source_version_type := p_version_type;
    END IF;

-------------------------------
-- Fetching target version type
-------------------------------
    IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='fetching target version type';
       pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
    END IF;
    BEGIN
        SELECT VERSION_TYPE
          INTO l_target_version_type
          FROM PA_BUDGET_VERSIONS
         WHERE BUDGET_VERSION_ID = p_budget_version_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='target version does not exist';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
             END IF;
             RAISE;
    END;

-----------------------------------
-- Fetching equipment quantity
-----------------------------------
    IF p_equip_qty IS NULL THEN
        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Fetching equipment quantity';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;
        BEGIN
            SELECT EQUIPMENT_QUANTITY
              INTO l_equip_quantity
              FROM PA_BUDGET_VERSIONS
             WHERE BUDGET_VERSION_ID = p_ci_version_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF l_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage:='source version does not exist';
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 RAISE;
        END;
    ELSE
        l_equip_quantity := p_equip_qty;
    END IF;

----------------------------------------
-- Deriving qty based on source version
----------------------------------------
    IF l_source_version_type = 'COST' THEN
        IF l_target_version_type = 'COST' OR l_target_version_type = 'ALL' THEN
            BEGIN
                SELECT 'Y'
                  INTO l_impl_qty_exists
                  FROM DUAL
                 WHERE EXISTS (SELECT 1
                                 FROM PA_FP_MERGED_CTRL_ITEMS
                                WHERE CI_PLAN_VERSION_ID = p_ci_version_id
                                  AND PLAN_VERSION_ID = p_budget_version_id
                                  AND VERSION_TYPE = 'COST');
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_impl_qty_exists := 'N';
            END;

            IF l_impl_qty_exists = 'Y' THEN
                RETURN 0;
            ELSE
                RETURN l_equip_quantity;
            END IF;
        ELSE
            RETURN 0;
        END IF;

    ELSIF l_source_version_type = 'REVENUE' THEN
        IF l_target_version_type = 'COST'
           OR l_target_version_type = 'ALL' THEN -- Raja review
           -- For ALL versions Quantity is computed from Cost Versions only
            RETURN 0;
        ELSIF l_target_version_type = 'REVENUE' -- Raja review OR l_target_version_type = 'ALL'
        THEN
              BEGIN
                IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Check if record exits in pa_fp_merged_ctl_items';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                END IF;
                SELECT 'Y'
                  INTO l_impl_qty_exists
                  FROM DUAL
                  WHERE EXISTS (SELECT 1
                                  FROM PA_FP_MERGED_CTRL_ITEMS A
                                 WHERE A.CI_PLAN_VERSION_ID = P_CI_VERSION_ID
                                   AND A.PLAN_VERSION_ID = P_BUDGET_VERSION_ID
                                   AND A.VERSION_TYPE = 'REVENUE');
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                RETURN l_equip_quantity;
              END;
              ------------------------------------------------
              -- If record exists then check for partial flag
              ------------------------------------------------
               IF l_impl_qty_exists = 'Y' THEN
                   BEGIN
                       SELECT NVL(B.REV_PARTIALLY_IMPL_FLAG,'N') , A.IMPL_EQUIPMENT_QUANTITY
                         INTO l_revenue_partial_flag, l_partial_quantity
                         FROM PA_FP_MERGED_CTRL_ITEMS A , PA_BUDGET_VERSIONS B
                        WHERE A.CI_PLAN_VERSION_ID = p_ci_version_id
                          AND A.PLAN_VERSION_ID = p_budget_version_id
                          AND A.VERSION_TYPE = 'REVENUE'
                          AND B.BUDGET_VERSION_ID = A.CI_PLAN_VERSION_ID;

                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                          NULL;
                  END;

                  IF l_revenue_partial_flag = 'Y' THEN

                     --For bug 3902176
                     --Moved the code here to fect aprroved rev CW version when
                     --source and target version both are 'REVENUE'
                     --and l_impl_quantity = 'Y'
                     ----------------------------------------------------------------
                     -- Fetching the approved revenue currenct working budget version
                     ----------------------------------------------------------------
                     IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:='fetching the approved revenue current working version';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                     END IF;

                     BEGIN
                        SELECT A.BUDGET_VERSION_ID
                        INTO l_appr_rev_cw_version_id
                        FROM PA_BUDGET_VERSIONS A
                        WHERE A.PROJECT_ID = (SELECT B.PROJECT_ID FROM PA_BUDGET_VERSIONS B
                                              WHERE B.BUDGET_VERSION_ID = p_budget_version_id)
                        AND A.VERSION_TYPE = 'REVENUE'
                        AND A.APPROVED_REV_PLAN_TYPE_FLAG = 'Y'
                        AND CURRENT_WORKING_FLAG = 'Y'
                        AND A.CI_ID IS NULL;
                        -- AND A.BUDGET_STATUS_CODE in ('S','W'); -- Bug#3815378

                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            NULL;
                     END;

                     IF p_budget_version_id = l_appr_rev_cw_version_id THEN
                         l_return_quantity := l_equip_quantity - l_partial_quantity;
                     ELSE
                         l_return_quantity := 0;
                     END IF;
                     RETURN l_return_quantity;
                  ELSIF l_revenue_partial_flag ='N' THEN
                     l_return_quantity := 0;
                     RETURN l_return_quantity;
                  END IF;
               END IF;
        END IF;

    ELSIF l_source_version_type = 'ALL' THEN
          IF l_target_version_type = 'COST' OR
             (l_target_version_type = 'ALL' AND nvl(p_pt_ct_version_type,'COST') = 'COST') THEN
             -- To avoid double count check for pt_ct_version_type
            BEGIN
                SELECT 'Y'
                  INTO l_impl_qty_exists
                  FROM DUAL
                 WHERE EXISTS (SELECT 1
                                 FROM PA_FP_MERGED_CTRL_ITEMS
                                WHERE CI_PLAN_VERSION_ID = p_ci_version_id
                                  AND PLAN_VERSION_ID = p_budget_version_id
                                  AND VERSION_TYPE = 'COST');
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_impl_qty_exists := 'N';
            END;

            IF l_impl_qty_exists = 'Y' THEN
                RETURN 0;
            ELSE
                RETURN l_equip_quantity;
            END IF;
          -- Bug 3678063 this case is missing
          ELSIF l_target_version_type = 'ALL' AND nvl(p_pt_ct_version_type,'COST') <> 'COST' THEN
                RETURN 0;
          ELSIF l_target_version_type = 'REVENUE' THEN
                  RETURN 0;
                  --Commented out the below part for bug 3902176
                  --And returning 0 instead when Source Version ='ALL'
                  --And Target Version = 'REVENUE'.

                  /*
                  BEGIN
                    IF l_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage:='Check if record exits in pa_fp_merged_ctl_items';
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                    END IF;
                    SELECT 'Y'
                      INTO l_impl_qty_exists
                      FROM DUAL
                      WHERE EXISTS (SELECT 1
                                      FROM PA_FP_MERGED_CTRL_ITEMS A
                                     WHERE A.CI_PLAN_VERSION_ID = P_CI_VERSION_ID
                                       AND A.PLAN_VERSION_ID = P_BUDGET_VERSION_ID
                                       AND A.VERSION_TYPE = 'REVENUE');
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    RETURN l_equip_quantity;
                  END;
              ------------------------------------------------
              -- If record exists then check for partial flag
              ------------------------------------------------
                  IF l_impl_qty_exists = 'Y' THEN
                      BEGIN
                          SELECT NVL(B.REV_PARTIALLY_IMPL_FLAG,'N') , A.IMPL_EQUIPMENT_QUANTITY
                            INTO l_revenue_partial_flag, l_partial_quantity
                            FROM PA_FP_MERGED_CTRL_ITEMS A , PA_BUDGET_VERSIONS B
                           WHERE A.CI_PLAN_VERSION_ID = p_ci_version_id
                             AND A.PLAN_VERSION_ID = p_budget_version_id
                             AND A.VERSION_TYPE = 'REVENUE'
                             AND B.BUDGET_VERSION_ID = A.CI_PLAN_VERSION_ID;
                      EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                 NULL;
                      END;
                      IF l_revenue_partial_flag = 'Y' THEN
                        IF p_budget_version_id = l_appr_rev_cw_version_id THEN
                            l_return_quantity := l_equip_quantity - l_partial_quantity;
                        ELSE
                            l_return_quantity := 0;
                        END IF;
                        RETURN l_return_quantity;
                     ELSIF l_revenue_partial_flag ='N' THEN
                        l_return_quantity := 0;
                        RETURN l_return_quantity;
                     END IF;
                  END IF;
                  */
          END IF;
    END IF;
END get_equip_qty_partial;

----------------------------------------------------------------------------------
-- Please note that this function is called for Include Change Doc Page PLSql Apis
-- View included Change Doc PlSql APIs, VO Queries, Change Doc Merge Apis

-- 07-Jun-2004 Raja Added new input parameter p_pt_ct_version_type b/c for 'ALL'
-- change order versions, there would be two records in pa_pt_co_impl_statuses
-- table and so the view returns PA_FP_ELIGIBLE_CI_V two records. To avoid double
-- count revenue amount would be returned only if p_pt_ct_version_type is 'REVENUE'

-- Note: In some cases, p_pt_ct_version_type is passed as null in this case
-- values are returned without bothering about double count.
-----------------------------------------------------------------------------------

 FUNCTION get_pc_revenue_partial (
          p_version_type       IN   pa_budget_versions.version_type%TYPE, -- version type of CI
          p_budget_version_id  IN   pa_budget_versions.budget_version_id%TYPE,
          p_ci_version_id      IN   pa_budget_versions.budget_version_id%TYPE,
          p_revenue            IN   pa_budget_versions.total_project_revenue%TYPE DEFAULT NULL,
          p_pt_ct_version_type IN   pa_pt_co_impl_statuses.version_type%TYPE DEFAULT NULL
          )
 RETURN  NUMBER
 IS
 l_return_revenue NUMBER :=0;
 l_partial_revenue NUMBER :=0;
 l_revenue NUMBER := 0;
 l_revenue_partial_flag VARCHAR2(1);
 l_debug_mode VARCHAR2(30);
 l_module_name VARCHAR2(30) := 'ctrl_utils.rev_prtial';
 l_exists VARCHAR2(1) := 'N';
 l_appr_rev_cw_version_id PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE;
 l_budget_version_type pa_budget_versions.version_type%TYPE;
 l_version_type pa_budget_versions.version_type%TYPE;
 -- Bug 5845142
 l_ci_app_rev_flag       pa_budget_versions.approved_rev_plan_type_flag%TYPE;
 BEGIN

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

    IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='In get_pc_revenue_partial - pa_fp_control_items_utils ';
       pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
    END IF;

----------------------------------------------------------------
-- Return 0 if p_pt_ct_version_type is 'COST'
----------------------------------------------------------------
    IF p_pt_ct_version_type IS NOT NULL  AND p_pt_ct_version_type = 'COST' THEN
       return 0;
    END IF;

    --Bug 5845142
    SELECT NVL(approved_rev_plan_type_flag,'N')
    INTO   l_ci_app_rev_flag
    FROM   pa_budget_versions
    WHERE  BUDGET_VERSION_ID = p_ci_version_id;

    --Bug 5845142
    IF l_ci_app_rev_flag = 'N' THEN
      RETURN 0;
    END IF;

    IF p_revenue IS NULL THEN
        BEGIN
            SELECT TOTAL_PROJECT_REVENUE
              INTO l_revenue
              FROM PA_BUDGET_VERSIONS
             WHERE BUDGET_VERSION_ID = p_ci_version_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='In get_pc_revenue_partial - no budget version';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 RAISE;
        END;
    ELSE
        l_revenue := p_revenue;
    END IF;

    BEGIN
        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Check if record exits in pa_fp_merged_ctl_items';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;
        SELECT 'Y'
          INTO l_exists
          FROM DUAL
          WHERE EXISTS (SELECT 1
                          FROM PA_FP_MERGED_CTRL_ITEMS A
                         WHERE A.CI_PLAN_VERSION_ID = P_CI_VERSION_ID
                           AND A.PLAN_VERSION_ID = P_BUDGET_VERSION_ID
                           AND A.VERSION_TYPE = 'REVENUE');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        RETURN l_revenue;
    END;

    ----------------------------------------------------------------
    -- Fetching the version type of the source(CI) if not passed.
    ----------------------------------------------------------------
    If p_version_type is NULL THEN
        BEGIN
            SELECT VERSION_TYPE
              INTO l_version_type
              FROM PA_BUDGET_VERSIONS
             WHERE BUDGET_VERSION_ID = p_ci_version_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='In get_pc_revenue_partial - no version type of source';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 RAISE;
        END;
    ELSE
        l_version_type := p_version_type;
    END IF;

    ----------------------------------------------------------------
    -- Fetching the version type of the target(budget version)
    ----------------------------------------------------------------
    BEGIN
       SELECT VERSION_TYPE
       INTO l_budget_version_type
       FROM PA_BUDGET_VERSIONS
       WHERE BUDGET_VERSION_ID = p_budget_version_id;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
            IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='In get_pc_revenue_partial - no version type of target';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;
            RAISE;
       END;

    --For bug 3902176
    --Return 0 if either the source or target version type is 'COST'
    IF l_version_type ='COST' OR l_budget_version_type = 'COST' THEN
       return 0;
    END IF;



    IF l_version_type = 'ALL' OR l_version_type = 'REVENUE' THEN
       IF l_exists = 'Y' THEN
           BEGIN
               SELECT NVL(B.REV_PARTIALLY_IMPL_FLAG,'N') , A.IMPL_PROJ_REVENUE
                 INTO l_revenue_partial_flag, l_partial_revenue
                 FROM PA_FP_MERGED_CTRL_ITEMS A , PA_BUDGET_VERSIONS B
                WHERE A.CI_PLAN_VERSION_ID = p_ci_version_id
                  AND A.PLAN_VERSION_ID = p_budget_version_id
                  AND A.VERSION_TYPE = 'REVENUE'
                  AND B.BUDGET_VERSION_ID = A.CI_PLAN_VERSION_ID;

          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  NULL;
          END;



          IF l_revenue_partial_flag = 'Y' THEN

             --For bug 3902176
             --Moved the code to fetch approved revenue CW budget version
             --when p_version_type = 'ALL' OR p_version_type = 'REVENUE' along
             --with l_exists = 'Y'

             ----------------------------------------------------------------
             -- Fetching the approved revenue budget currenct working version
             ----------------------------------------------------------------
             IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='fetching the approved revenue current working version';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
             END IF;

             BEGIN
                 SELECT A.BUDGET_VERSION_ID
                 INTO l_appr_rev_cw_version_id
                 FROM PA_BUDGET_VERSIONS A
                 WHERE A.PROJECT_ID = (SELECT B.PROJECT_ID FROM PA_BUDGET_VERSIONS B
                                       WHERE B.BUDGET_VERSION_ID = p_budget_version_id)
                 AND A.VERSION_TYPE IN('ALL', 'REVENUE')
                 -- Raja review AND A.VERSION_TYPE IN('REVENUE')
                 AND A.APPROVED_REV_PLAN_TYPE_FLAG = 'Y'
                 AND CURRENT_WORKING_FLAG = 'Y'
                 AND A.CI_ID IS NULL;
                 --       AND A.BUDGET_STATUS_CODE in ('S','W'); -- Bug#3815378

              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    NULL;
             END;

             IF p_budget_version_id = l_appr_rev_cw_version_id THEN
                 l_return_revenue := l_revenue - l_partial_revenue;
             ELSE
                 l_return_revenue := 0;
             END IF;
          ELSIF l_revenue_partial_flag ='N' THEN
             l_return_revenue := 0;
          END IF;

       ELSIF l_exists = 'N' THEN
             RETURN l_revenue;
       END IF;

    END IF;

    RETURN l_return_revenue;

 END get_pc_revenue_partial;

--------------------------------------------------------------------------------
-- Please note that this function is called for Include Change Doc Page PLSql Apis
-- View included Change Doc PlSql APIs, VO Queries, Change Doc Merge Apis

-- 07-Jun-2004 Raja Added new input parameter p_pt_ct_version_type b/c for 'ALL'
-- change order versions, there would be two records in pa_pt_co_impl_statuses
-- table and so the view returns PA_FP_ELIGIBLE_CI_V two records. To avoid double
-- count cost amount would be returned only if p_pt_ct_version_type is 'COST'

-- Note: In some cases, p_pt_ct_version_type is passed as null in this case
-- values are returned without bothering about double count.
--------------------------------------------------------------------------------
 FUNCTION get_pc_cost (
          p_version_type       IN   pa_budget_versions.version_type%TYPE, -- this is the ci version type
          p_budget_version_id  IN   pa_budget_versions.budget_version_id%TYPE,
          p_ci_version_id      IN   pa_budget_versions.budget_version_id%TYPE,
          p_raw_cost           IN   pa_budget_versions.total_project_raw_cost%TYPE DEFAULT NULL,
          p_burdened_cost      IN   pa_budget_versions.total_project_burdened_cost%TYPE DEFAULT NULL,
          p_pt_ct_version_type IN   pa_pt_co_impl_statuses.version_type%TYPE DEFAULT NULL
          )
 RETURN  NUMBER
 IS
 l_return_cost NUMBER :=0;
 l_margin_derived_from_code pa_proj_fp_options.margin_derived_from_code%TYPE;
 l_debug_mode VARCHAR2(30);
 l_module_name VARCHAR2(30) := 'ctrl_utils.get_pc_cost';
 l_budget_version_type pa_budget_versions.version_type%TYPE;
 l_version_type pa_budget_versions.version_type%TYPE;
 l_cost pa_budget_versions.total_project_raw_cost%TYPE;

 BEGIN

   fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

   IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:='In get_pc_cost - pa_fp_control_items_utils ';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
   END IF;

   ----------------------------------------------------------------
   -- Return 0 if p_pt_ct_version_type is 'REVENUE'
   ----------------------------------------------------------------
   IF p_pt_ct_version_type IS NOT NULL AND p_pt_ct_version_type = 'REVENUE' THEN
      return 0;
   END IF;

   -----------------------------------------
   -- Fetching the margin dervied from code.
   -- Changed the select stmt for bug 3902176
   -- to fetch l_margin_derived_from_code with
   -- respect to ci_version_id
   -----------------------------------------

   SELECT nvl(MARGIN_DERIVED_FROM_CODE,'B')
   INTO l_margin_derived_from_code
   FROM PA_PROJ_FP_OPTIONS a
   WHERE a.FIN_PLAN_VERSION_ID = p_ci_version_id
   AND a.fin_plan_option_level_code = 'PLAN_VERSION';

   ----------------------------------------------------------------
    -- Fetching the version type of the source(CI) if not passed.
    ----------------------------------------------------------------
    If p_version_type is NULL THEN
        BEGIN
            SELECT VERSION_TYPE
              INTO l_version_type
              FROM PA_BUDGET_VERSIONS
             WHERE BUDGET_VERSION_ID = p_ci_version_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='In get_pc_cost - no version type of source';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 RAISE;
        END;
    ELSE
        l_version_type := p_version_type;
    END IF;

    ----------------------------------------------------------------
    -- Fetching the version type of the target(budget version)
    ----------------------------------------------------------------
    BEGIN
       SELECT VERSION_TYPE
       INTO l_budget_version_type
       FROM PA_BUDGET_VERSIONS
       WHERE BUDGET_VERSION_ID = p_budget_version_id;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
            IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='In get_pc_cost - no version type of target';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;
            RAISE;
       END;


   -- For bug 3902176
   --Return 0 if the version type of either source or target is revenue.
   IF l_version_type ='REVENUE' OR l_budget_version_type = 'REVENUE' THEN
       return 0;
   END IF;

    --For bug 3902176
    --Assigning l_cost to either p_raw_cost or p_burdened_cost based on the
    --fetched margin_derived_from_code
   IF l_margin_derived_from_code = 'R' Then
       l_cost:= p_raw_cost;
   ELSIF
      l_margin_derived_from_code = 'B' Then
       l_cost:= p_burdened_cost;
   END IF;

    ----------------------------------------------------------------
    -- Fetching the raw cost or burdened cost if not passed
    -- depending on margin derived from code value(For bug 3902176)
    ----------------------------------------------------------------
/* Begin changes for bug 8507605 - commented code as there is no reason to
 * get the cost of the budget when CO's cost is NULL
   IF l_cost is NULL THEN
       BEGIN
           Select decode(l_margin_derived_from_code,
                                                'R',total_project_raw_cost
                                                   ,total_project_burdened_cost)
           INTO l_cost
           FROM PA_BUDGET_VERSIONS
           WHERE BUDGET_VERSION_ID = p_budget_version_id;

       EXCEPTION
       WHEN NO_DATA_FOUND THEN
            IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='In get_pc_cost - couldnt get raw or burdened cost';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;
            RAISE;
       END;
   END IF;
* End changes for bug 8507605 */


   IF l_version_type = 'ALL' or l_version_type = 'COST' THEN
      BEGIN
          Select l_cost
            into l_return_cost
            from dual
            where not exists (Select 1
                                 from pa_fp_merged_ctrl_items
                                where plan_version_id = p_budget_version_id
                                  and version_type = 'COST'
                                  and ci_plan_version_id = p_ci_version_id);

      EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_return_cost := 0;
            IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='In get_pc_cost - NO_DATA_FOUND ';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;
      END;

   ELSIF l_version_type = 'REVENUE' THEN
      l_return_cost := 0;
   END IF;

   IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:='In get_pc_cost - l_return_cost ' || l_return_cost;
      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
   END IF;

   return l_return_cost;
 END get_pc_cost;

 PROCEDURE get_not_included
 (      p_project_id                  IN       NUMBER
       ,p_budget_version_id           IN       pa_budget_versions.budget_version_id%TYPE
       ,p_fin_plan_type_id            IN       pa_budget_versions.fin_plan_type_id%TYPE
       ,p_version_type                IN       pa_budget_versions.version_type%TYPE
       ,x_summary_tbl                 OUT      NOCOPY SYSTEM.PA_VARCHAR2_150_TBL_TYPE --File.Sql.39 bug 4440895
       ,x_equipment_hours_tbl         OUT      NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
       ,x_labor_hours_tbl             OUT      NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
       ,x_cost_tbl                    OUT      NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
       ,x_revenue_tbl                 OUT      NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
       ,x_margin_tbl                  OUT      NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
       ,x_margin_percent_tbl          OUT      NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
       ,x_return_status               OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       ,x_msg_count                   OUT      NOCOPY NUMBER --File.Sql.39 bug 4440895
       ,x_msg_data                    OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) IS

  --Start of variables used for debugging
      l_msg_count          NUMBER :=0;
      l_data               VARCHAR2(2000);
      l_msg_data           VARCHAR2(2000);
      l_error_msg_code     VARCHAR2(30);
      l_msg_index_out      NUMBER;
      l_return_status      VARCHAR2(2000);
      l_debug_mode         VARCHAR2(30);
  --End of variables used for debugging

l_row_count                         NUMBER := 0;
l_version_type                      PA_BUDGET_VERSIONS.VERSION_TYPE%TYPE;
l_fin_plan_type_id                  PA_PROJ_FP_OPTIONS.FIN_PLAN_TYPE_ID%TYPE;
l_labor_quantity                    PA_BUDGET_VERSIONS.LABOR_QUANTITY%TYPE;
l_equipment_quantity                PA_BUDGET_VERSIONS.EQUIPMENT_QUANTITY%TYPE;
l_cost                              PA_BUDGET_VERSIONS.RAW_COST%TYPE;
l_revenue                           PA_BUDGET_VERSIONS.REVENUE%TYPE;
l_lookup_code_tbl                   SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
l_assigned_flag                     VARCHAR2(1) := 'N';
l_module_name                       VARCHAR2(30) := 'ctrl_itm_utls.get_not_incl';


 CURSOR c_lookup_summary IS
        SELECT MEANING,to_number(LOOKUP_CODE)
          FROM PA_LOOKUPS
         WHERE LOOKUP_TYPE = 'PA_FP_CI_NOT_INCLUDED'
        ORDER BY to_number(LOOKUP_CODE);

-- In the cursor c_change_documents_status, all the select column sums have been wrapped up
-- with nvl beacuse, the select is not reporting a %NOTFOUND because of use of group funcs
-- here, and we wish to return 0 values for all amounts/quantity for null cases

--Any cursor change may be required to be incorporated in PaFpCiIncludeChangeOrderVO.xml as well.
--Changed this cursor for bug 3902176

CURSOR c_change_documents_status(
     c_system_status_code PA_CI_STATUSES_V.PROJECT_SYSTEM_STATUS_CODE%TYPE,
     c_budget_version_id  PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
     c_project_id         PA_PROJECTS_ALL.PROJECT_ID%TYPE,
     c_fin_plan_type_id   PA_BUDGET_VERSIONS.FIN_PLAN_TYPE_ID%TYPE,
     c_version_type       PA_BUDGET_VERSIONS.VERSION_TYPE%TYPE) IS
 select  nvl(sum(nvl(PA_FP_CONTROL_ITEMS_UTILS.get_labor_qty_partial(
                                      pfca.CI_VERSION_TYPE,
                                      c_budget_version_id,
                                      pfca.CI_VERSION_ID,
                                      pfca.people_effort,
                                      pfca.PT_CT_VERSION_TYPE),0)),0) as people_effort
       ,nvl(sum(nvl(PA_FP_CONTROL_ITEMS_UTILS.get_equip_qty_partial(
                                      pfca.CI_VERSION_TYPE,
                                      c_budget_version_id,
                                      pfca.CI_VERSION_ID,
                                      pfca.equipment_effort,
                                      pfca.PT_CT_VERSION_TYPE),0)),0) as equipment_effort
       ,nvl(sum(nvl(PA_FP_CONTROL_ITEMS_UTILS.get_pc_cost(
                                      pfca.CI_VERSION_TYPE,
                                      c_budget_version_id,
                                      pfca.CI_VERSION_ID,
                                      pfca.RAW_COST,
                                      pfca.BURDENED_COST,
                                      pfca.PT_CT_VERSION_TYPE),0)),0) as cost
       ,nvl(sum(nvl(PA_FP_CONTROL_ITEMS_UTILS.get_pc_revenue_partial(
                                       pfca.CI_VERSION_TYPE,
                                       c_budget_version_id,
                                       pfca.CI_VERSION_ID,
                                       pfca.REVENUE,
                                       pfca.PT_CT_VERSION_TYPE),0)),0) as revenue
  from PA_FP_ELIGIBLE_CI_V pfca
 where pfca.project_id = c_project_id
   and pfca.fin_plan_type_id = c_fin_plan_type_id
   and pfca.CI_VERSION_TYPE <>
                       decode(c_version_type,'COST','REVENUE','REVENUE','COST','ALL','-99')
   and decode (pfca.CI_VERSION_TYPE,'ALL',
               pfca.PT_CT_VERSION_TYPE,pfca.CI_VERSION_TYPE) = pfca.PT_CT_VERSION_TYPE
  -- 3572880 below join necessary when target version type is COST/REV and ci version type
  -- is ALL to avoid REV/COST impacts
   and pfca.PT_CT_VERSION_TYPE
            = decode (c_version_type, 'ALL', pfca.PT_CT_VERSION_TYPE, c_version_type)
   and pfca.PROJECT_SYSTEM_STATUS_CODE = c_system_status_code
   and (    pfca.REV_PARTIALLY_IMPL_FLAG='Y'
        or (pfca.ci_version_type='ALL'
            AND DECODE(c_version_type,'ALL',2,1) > (SELECT  COUNT(*)
                      FROM  pa_fp_merged_ctrl_items merge1
                     where  merge1.ci_plan_version_id = pfca.ci_version_id
                       and  merge1.plan_version_id = c_budget_version_id
                       and  merge1.project_id = c_project_id))
        or (pfca.ci_version_type <> 'ALL'
            AND not exists (Select 'X'
                              from pa_fp_merged_ctrl_items merge2
                             where merge2.ci_plan_version_id = pfca.ci_version_id
                               and merge2.plan_version_id = c_budget_version_id
                               and merge2.version_type = pfca.ci_version_type
                               and merge2.project_id = c_project_id)));

BEGIN

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    PA_DEBUG.Set_Curr_Function( p_function   => l_module_name,
                                p_debug_mode => l_debug_mode );


    -----------------------------------------------------------------------------
    -- Validate Input Params, p_project_id and p_budget_version_id cannot be null
    -----------------------------------------------------------------------------

   IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:='Validating input parameters - project id and budget version id: ' || p_project_id;
      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
   END IF;

   IF (p_project_id IS NULL) THEN
       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='p_project_id is null';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
       END IF;
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
   END IF;

   IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:='p_project_id; '||p_project_id;
      pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
   END IF;

   IF (p_budget_version_id IS NULL) THEN
       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='p_budget_version_id is null';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
       END IF;
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
   END IF;

   IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:='p_budget_version_id; '||p_budget_version_id;
      pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
   END IF;

   ---------------------------------------------------------
   -- Derive version type and fin_plan_type_id if not passed
   ---------------------------------------------------------
   IF p_version_type is NULL THEN

       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='fetching version type';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
       END IF;

       BEGIN
       Select version_type
         into l_version_type
         from pa_budget_versions
        where budget_version_id = p_budget_version_id;

       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='l_version_type; '||l_version_type;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
       END IF;

        EXCEPTION
         WHEN NO_DATA_FOUND THEN
           IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='p_budget_version_id is invalid - fetching version type';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
           END IF;
           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END;
   ELSE
      l_version_type := p_version_type;
   END IF;


   IF p_fin_plan_type_id is NULL THEN

       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='fetching fin plan type id';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
       END IF;

       BEGIN
       Select fin_plan_type_id
         into l_fin_plan_type_id
         from pa_budget_versions
        where budget_version_id = p_budget_version_id;

       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='l_fin_plan_type_id; '||l_fin_plan_type_id;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
       END IF;

        EXCEPTION
         WHEN NO_DATA_FOUND THEN
           IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='p_budget_version_id is invalid - fetching fin plan type id';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
           END IF;
           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END;
   ELSE
      l_fin_plan_type_id := p_fin_plan_type_id;
   END IF;



   -------------------------------------------
   -- Initialising all tables to empty tables.
   -------------------------------------------
    IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:='Initialising all tables to empty tables.';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
    END IF;
    x_summary_tbl         := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
    x_equipment_hours_tbl := SYSTEM.pa_num_tbl_type();
    x_labor_hours_tbl     := SYSTEM.pa_num_tbl_type();
    x_cost_tbl            := SYSTEM.pa_num_tbl_type();
    x_revenue_tbl         := SYSTEM.pa_num_tbl_type();
    x_margin_tbl          := SYSTEM.pa_num_tbl_type();
    x_margin_percent_tbl  := SYSTEM.pa_num_tbl_type();


   ----------------------------------------------------
   -- Fetch Lookup_code ,summary and reference details.
   ----------------------------------------------------
   IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:='Fetching lookup data' || p_project_id;
      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
   END IF;

   OPEN c_lookup_summary;
        FETCH c_lookup_summary BULK COLLECT INTO x_summary_tbl,l_lookup_code_tbl;
   CLOSE c_lookup_summary;



/*   The following logic is based on the following assumptions:
The lookup code signifies the data this is being shown in the region as follows:
As of now:
10 Approved Change Documents
20 Working Change Documents
30 Submitted Change Documents
40 Rejected Change Documents
50 Total Change Documents

Disclaimer: Please note that the actual and latest mapping of the above
can be got from pa_lookups as follows:
select lookup_code, meaning
from  pa_lookupus
where lookup_type = 'PA_FP_CI_NOT_INCLUDED'
order by to_number(lookup_code);

Description for the lookup type has been updated as well saying that
the code is used as number internally.*/

       FOR i IN l_lookup_code_tbl.FIRST .. l_lookup_code_tbl.LAST LOOP



            x_equipment_hours_tbl.extend(1);
            x_labor_hours_tbl.extend(1);
            x_cost_tbl.extend(1);
            x_revenue_tbl.extend(1);

           IF l_lookup_code_tbl(i) = 10 THEN
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Fetching Data for Approved Change Documents';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 OPEN c_change_documents_status('CI_APPROVED',
                                                p_budget_version_id,
                                                p_project_id ,
                                                l_fin_plan_type_id ,
                                                l_version_type );
                        FETCH c_change_documents_status INTO l_labor_quantity,
                                                             l_equipment_quantity,
                                                             l_cost,
                                                             l_revenue;
                 CLOSE c_change_documents_status;
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='l_labor_quantity:'||l_labor_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_equipment_quantity:'||l_equipment_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_cost:'||l_cost;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_revenue:'||l_revenue;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;

           ELSIF l_lookup_code_tbl(i) = 20 THEN
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Fetching Data for Working Change Documents';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 OPEN c_change_documents_status('CI_WORKING',
                                                p_budget_version_id,
                                                p_project_id ,
                                                l_fin_plan_type_id ,
                                                l_version_type );
                        FETCH c_change_documents_status INTO l_labor_quantity,
                                                             l_equipment_quantity,
                                                             l_cost,
                                                             l_revenue;
                 CLOSE c_change_documents_status;
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='l_labor_quantity:'||l_labor_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_equipment_quantity:'||l_equipment_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_cost:'||l_cost;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_revenue:'||l_revenue;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;

           ELSIF l_lookup_code_tbl(i) = 30 THEN   /* fetching data for COs included into asdfsd prior versions */
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Fetching Data for Submitted Change Documents';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 OPEN c_change_documents_status('CI_SUBMITTED',
                                                p_budget_version_id,
                                                p_project_id ,
                                                l_fin_plan_type_id ,
                                                l_version_type );
                        FETCH c_change_documents_status INTO l_labor_quantity,
                                                             l_equipment_quantity,
                                                             l_cost,
                                                             l_revenue;
                 CLOSE c_change_documents_status;
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='l_labor_quantity:'||l_labor_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_equipment_quantity:'||l_equipment_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_cost:'||l_cost;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_revenue:'||l_revenue;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;

           ELSIF l_lookup_code_tbl(i) = 40 THEN
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Fetching Data for Rejected Change Documents';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 OPEN c_change_documents_status('CI_REJECTED',
                                                p_budget_version_id,
                                                p_project_id ,
                                                l_fin_plan_type_id ,
                                                l_version_type );
                        FETCH c_change_documents_status INTO l_labor_quantity,
                                                             l_equipment_quantity,
                                                             l_cost,
                                                             l_revenue;
                 CLOSE c_change_documents_status;
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='l_labor_quantity:'||l_labor_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_equipment_quantity:'||l_equipment_quantity;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_cost:'||l_cost;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:='l_revenue:'||l_revenue;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;

           ELSIF l_lookup_code_tbl(i) = 50 THEN
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Deriving Data for Total Change Documents';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 x_equipment_hours_tbl(i) := x_equipment_hours_tbl(i-1) +
                                             x_equipment_hours_tbl(i-2) +
                                             x_equipment_hours_tbl(i-3) +
                                             x_equipment_hours_tbl(i-4);
                 x_labor_hours_tbl(i) := x_labor_hours_tbl(i-1) +
                                         x_labor_hours_tbl(i-2) +
                                         x_labor_hours_tbl(i-3) +
                                         x_labor_hours_tbl(i-4);
                 x_cost_tbl(i) := x_cost_tbl(i-1) +
                                  x_cost_tbl(i-2) +
                                  x_cost_tbl(i-3) +
                                  x_cost_tbl(i-4);
                 x_revenue_tbl(i) := x_revenue_tbl(i-1) +
                                     x_revenue_tbl(i-2) +
                                     x_revenue_tbl(i-3) +
                                     x_revenue_tbl(i-4);
                 l_assigned_flag := 'Y';
           END IF;

           IF l_assigned_flag = 'N' THEN
                x_equipment_hours_tbl(i) := l_equipment_quantity;
                x_labor_hours_tbl(i)     := l_labor_quantity;
                x_cost_tbl(i)            := l_cost;
                x_revenue_tbl(i)         := l_revenue;
           END IF;

           l_assigned_flag := 'N';

       END LOOP;

   IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:='Deriving Margin and Margin Percent';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
   END IF;

   l_row_count := x_summary_tbl.COUNT;
   IF l_row_count > 0 THEN
       x_margin_tbl.extend(l_row_count);
       x_margin_percent_tbl.extend(l_row_count);
       FOR i IN x_cost_tbl.FIRST .. x_cost_tbl.LAST LOOP
           x_margin_tbl(i) := x_revenue_tbl(i) - x_cost_tbl(i);
           IF x_revenue_tbl(i) <> 0 THEN
              x_margin_percent_tbl(i) := (x_margin_tbl(i)/x_revenue_tbl(i))*100;
           ELSE
              x_margin_percent_tbl(i) := 0;
           END IF;
       END LOOP;
   END IF;

   pa_debug.reset_curr_function;

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
           pa_debug.reset_curr_function;
           RETURN;

     WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FP_CONTROL_ITEMS_UTILS'
                                  ,p_procedure_name  => 'get_not_included');

           IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write('get_not_included: ' || g_module_name,pa_debug.g_err_stage,5);
           END IF;
          pa_debug.reset_curr_function;
          RAISE;

 END get_not_included;


/* FP.M -This function checks if any record exists in pa_ci_impacts and if yes then
 * returns the impact type code
 */
FUNCTION is_impact_exists(p_ci_id     IN       pa_ci_impacts.ci_id%TYPE)
RETURN   VARCHAR2
IS
      l_record_count         NUMBER;
      l_impact_type_code     VARCHAR2(30);
      l_debug_mode           VARCHAR2(30);
      l_module_name          VARCHAR2(30) := 'is_impact_exists';

      l_msg_count            NUMBER :=0;
      l_data                 VARCHAR2(2000);
      l_msg_data             VARCHAR2(2000);
      l_msg_index_out        NUMBER;

      -- Bug 3787977: Introduced the following cursor to get the impact_type_code
      CURSOR get_impact_type_csr
      IS
      SELECT   impact_type_code
      FROM     pa_ci_impacts
      WHERE    ci_id = p_ci_id
      AND      impact_type_code IN ('FINPLAN',
                                   'FINPLAN_COST',
                                   'FINPLAN_REVENUE')
      ORDER BY impact_type_code;

      l_impact_type_tbl    PA_PLSQL_DATATYPES.Char30TabTyp;

BEGIN
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

      IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='In is_impact_exists - pa_fp_control_items_utils ';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;
      PA_DEBUG.Set_Curr_Function( p_function   => l_module_name,
                                  p_debug_mode => l_debug_mode );
      OPEN get_impact_type_csr;

      FETCH get_impact_type_csr
      BULK COLLECT INTO  l_impact_type_tbl;

      CLOSE get_impact_type_csr;

      l_record_count := l_impact_type_tbl.COUNT;

      IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='l_record_count is:' || l_record_count;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      IF l_record_count = 0 THEN
           IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='No Impact Exists';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
           END IF;

           l_impact_type_code := 'NONE';

           pa_debug.reset_curr_function;
           RETURN l_impact_type_code;
      END IF;

      IF l_record_count > 0 THEN
            IF l_record_count = 1 THEN
                  IF NOT l_impact_type_tbl(l_impact_type_tbl.FIRST) = 'FINPLAN' THEN
                       IF P_PA_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage:='Impact Wrongly Created';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
                       END IF;
                       pa_debug.reset_curr_function;
                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  ELSE
                       l_impact_type_code := 'FINPLAN';
                  END IF;
            ELSIF l_record_count = 2 THEN
                  IF l_impact_type_tbl(l_impact_type_tbl.FIRST) = 'FINPLAN' AND
                     l_impact_type_tbl(l_impact_type_tbl.LAST) = 'FINPLAN_COST' THEN
                       l_impact_type_code := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST;
                  ELSIF l_impact_type_tbl(l_impact_type_tbl.FIRST) = 'FINPLAN' AND
                        l_impact_type_tbl(l_impact_type_tbl.LAST) = 'FINPLAN_REVENUE' THEN
                       l_impact_type_code := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE;
                  END IF;
            ELSE
                 l_impact_type_code := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH;
            END IF;
      END IF;
      IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='l_impact_type_code is:' || l_impact_type_code;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      pa_debug.reset_curr_function;
      RETURN l_impact_type_code;
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
          END IF;
          pa_debug.reset_curr_function;
          RAISE;
      WHEN OTHERS THEN
           IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
                 pa_debug.write(l_module_name || g_module_name,pa_debug.g_err_stage,5);
           END IF;
          pa_debug.reset_curr_function;
          RAISE;
END is_impact_exists;

/* FP.M- This function checks for the particular ci type, the Cost Impact or
 * Revenue Impact has been enabled for Financial implementation
 */
FUNCTION is_fin_impact_enabled(p_ci_id        IN       pa_control_items.ci_id%TYPE,
                               p_project_id   IN       pa_projects_all.project_id%TYPE)
RETURN   VARCHAR2
IS

      l_ci_type_id           NUMBER;
      l_fin_impl_flag        VARCHAR2(30);
      l_cost_impact_flag     VARCHAR2(30);
      l_rev_impact_flag      VARCHAR2(30);
      l_debug_mode           VARCHAR2(30);
      l_module_name          VARCHAR2(30) := 'is_fin_impact_enabled';

BEGIN
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

      IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='is_fin_impact_enabled - pa_fp_control_items_utils ';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;
      PA_DEBUG.Set_Curr_Function( p_function   => l_module_name,
                                  p_debug_mode => l_debug_mode );

      BEGIN
           SELECT     ci_type_id
           INTO       l_ci_type_id
           FROM       pa_control_items
           WHERE      ci_id = p_ci_id
           AND        project_id = p_project_id;

           SELECT     cost_impact_flag, revenue_impact_flag
           INTO       l_cost_impact_flag, l_rev_impact_flag
           FROM       pa_ci_types_w_finplan_v
           WHERE      ci_type_id = l_ci_type_id;

      EXCEPTION
           WHEN NO_DATA_FOUND THEN
                 IF l_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage:='No Fin Impact Exists';
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;

                 l_fin_impl_flag := 'NONE';

                 pa_debug.reset_curr_function;
                 RETURN l_fin_impl_flag;
      END;
      IF l_cost_impact_flag = 'Y' and l_rev_impact_flag = 'N' THEN
            l_fin_impl_flag := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST;
      ELSIF l_cost_impact_flag = 'N' and l_rev_impact_flag = 'Y' THEN
            l_fin_impl_flag := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE;
      ELSIF l_cost_impact_flag = 'Y' and l_rev_impact_flag = 'Y' THEN
            l_fin_impl_flag := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH;
      END IF;

      IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='l_fin_impl_flag is:' || l_fin_impl_flag;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      pa_debug.reset_curr_function;
      RETURN l_fin_impl_flag;
EXCEPTION
      WHEN OTHERS THEN
           IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
                 pa_debug.write(l_module_name || g_module_name,pa_debug.g_err_stage,5);
           END IF;
           pa_debug.reset_curr_function;
           RAISE;
END is_fin_impact_enabled;

/* Returns the Ids of the versions created for this Change Document(p_ci_id).
   The ID will be NULL if the version can never be there */

--Bug 5845142
PROCEDURE GET_CI_VERSIONS(P_ci_id                   IN   Pa_budget_versions.ci_id%TYPE                  -- Controm item id of the change document
                         ,X_cost_budget_version_id  OUT  NOCOPY Pa_budget_versions.budget_version_id%TYPE      -- ID of the cost version associated with the CI --File.Sql.39 bug 4440895
                         ,X_rev_budget_version_id   OUT  NOCOPY Pa_budget_versions.budget_version_id%TYPE      -- ID of the revenue version associated with the CI --File.Sql.39 bug 4440895
                         ,X_all_budget_version_id   OUT  NOCOPY Pa_budget_versions.budget_version_id%TYPE      -- ID of the all version associated with the CI --File.Sql.39 bug 4440895
                         ,x_return_status           OUT  NOCOPY VARCHAR2                                       -- Indicates the exit status of the API --File.Sql.39 bug 4440895
                         ,x_msg_data                OUT  NOCOPY VARCHAR2                                       -- Indicates the error occurred --File.Sql.39 bug 4440895
                         ,X_msg_count               OUT  NOCOPY NUMBER)                                        -- Indicates the number of error messages --File.Sql.39 bug 4440895
IS
     CURSOR c_vers_for_ci IS
                SELECT    budget_version_id,
                          Version_type,
                          approved_cost_plan_type_flag,
                          approved_rev_plan_type_flag
                FROM      pa_budget_versions
                WHERE     ci_id =p_ci_id;

      -- Start of variables used for debugging purpose

      l_msg_count          NUMBER :=0;
      l_data               VARCHAR2(2000);
      l_msg_data           VARCHAR2(2000);
      l_msg_index_out      NUMBER;
      l_return_status      VARCHAR2(2000);
      l_debug_mode         VARCHAR2(1);
      l_debug_level3       CONSTANT NUMBER := 3;
      l_debug_level5       CONSTANT NUMBER := 5;
      l_mod_name           VARCHAR2(100) := g_module_name || '.GET_CI_VERSIONS' ;
      l_token_name         VARCHAR2(30) :='PROCEDURENAME';

      -- End of variables used for debugging purpose

      c_vers_for_ci_rec  c_vers_for_ci%ROWTYPE;

BEGIN

      pa_debug.set_curr_function( p_function   => 'GET_CI_VERSIONS',
                                  p_debug_mode => P_PA_debug_mode );


      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_ci_id IS NULL)
      THEN

           IF P_PA_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Ci_id = '||p_ci_id;
               pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
           END IF;


           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name      => 'PA_FP_INV_PARAM_PASSED',
                                p_token1 => l_token_name,
                                p_value1 => l_mod_name);


           IF P_PA_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Invalid Arguments Passed';
               pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
           END IF;
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      IF P_PA_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Entering GET_CI_VERSIONS';
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      X_cost_budget_version_id := NULL;
      X_rev_budget_version_id := NULL;
      X_all_budget_version_id := NULL;

      FOR c_vers_for_ci_rec IN c_vers_for_ci LOOP
           IF c_vers_for_ci_rec.version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST THEN
                X_cost_budget_version_id := c_vers_for_ci_rec.budget_version_id;
           ELSIF c_vers_for_ci_rec.version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE THEN
                X_rev_budget_version_id := c_vers_for_ci_rec.budget_version_id;
           ELSIF c_vers_for_ci_rec.version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL THEN

             --Bug 5845142. COST impact can be of ALL version type.
             IF c_vers_for_ci_rec.approved_cost_plan_type_flag='Y' AND
             c_vers_for_ci_rec.approved_rev_plan_type_flag='Y' THEN

                X_all_budget_version_id := c_vers_for_ci_rec.budget_version_id;

             ELSIF c_vers_for_ci_rec.approved_cost_plan_type_flag='Y' THEN

                X_cost_budget_version_id := c_vers_for_ci_rec.budget_version_id;

             ELSIF c_vers_for_ci_rec.approved_rev_plan_type_flag='Y' THEN

                X_rev_budget_version_id := c_vers_for_ci_rec.budget_version_id;

             END IF;
           END IF;
      END LOOP;

      IF P_PA_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Exiting GET_CI_VERSIONS';
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      pa_debug.reset_curr_function;

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

      pa_debug.reset_curr_function;

      RETURN;

     WHEN Others THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          IF c_vers_for_ci%ISOPEN THEN
               CLOSE c_vers_for_ci;
          END IF;

          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'Pa_Fp_Control_Items_Utils'
                                  ,p_procedure_name  => 'GET_CI_VERSIONS');
          IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:='Unexpected Error ' || SQLERRM;
               pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
          END IF;
          pa_debug.reset_curr_function;
          RAISE;

END GET_CI_VERSIONS;

/* Returns all the plan types attached to a project(excluding work plan and org forecast plan types)
   and other information including whether a change order can be implemented into it  */
-- Added New Params for Quantity in GET_PLAN_TYPES_FOR_IMPL - Bug 3902176
PROCEDURE GET_PLAN_TYPES_FOR_IMPL
       (P_ci_id                 IN      Pa_fin_plan_types_b.fin_plan_type_id%TYPE,      --      Id of the Change Document
        P_project_id            IN      Pa_budget_versions.project_id%TYPE,             --      Id of the Project
        X_pt_id_tbl             OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql table for fin plan type ids --File.Sql.39 bug 4440895
        X_pt_name_tbl           OUT     NOCOPY SYSTEM.pa_varchar2_150_tbl_type,                 --      Plsql table for fin plan type names --File.Sql.39 bug 4440895
        x_cost_impact_impl_tbl  OUT     NOCOPY SYSTEM.pa_varchar2_1_tbl_type, --File.Sql.39 bug 4440895
        x_rev_impact_impl_tbl   OUT     NOCOPY SYSTEM.pa_varchar2_1_tbl_type, --File.Sql.39 bug 4440895
        X_cost_impl_tbl         OUT     NOCOPY SYSTEM.pa_varchar2_1_tbl_type,                   --      Plsql table for Implement Cost Flag --File.Sql.39 bug 4440895
        x_rev_impl_tbl          OUT     NOCOPY SYSTEM.pa_varchar2_1_tbl_type,                   --      Plsql table for Implement Rev Flag --File.Sql.39 bug 4440895
        X_raw_cost_tbl          OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql table for raw cost --File.Sql.39 bug 4440895
        X_burd_cost_tbl         OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql table for burdened cost --File.Sql.39 bug 4440895
        X_revenue_tbl           OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql table for revenue --File.Sql.39 bug 4440895
        X_labor_hrs_c_tbl       OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql table for labor hrs -Cost --File.Sql.39 bug 4440895
        X_equipment_hrs_c_tbl   OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql tabe for equipment hrs -Cost --File.Sql.39 bug 4440895
        X_labor_hrs_r_tbl       OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql table for labor hrs -Rev --File.Sql.39 bug 4440895
        X_equipment_hrs_r_tbl   OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql tabe for equipment hrs -Rev --File.Sql.39 bug 4440895
        X_margin_tbl            OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql table for margin --File.Sql.39 bug 4440895
        X_margin_percent_tbl    OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql table for margin percent --File.Sql.39 bug 4440895
        X_margin_derived_code_tbl OUT   NOCOPY SYSTEM.pa_varchar2_30_tbl_type,                  --      Plsql table for Margin Derived From Code - Bug 3734840 --File.Sql.39 bug 4440895
        x_approved_fin_pt_id    OUT     NOCOPY Pa_fin_plan_types_b.fin_plan_type_id%TYPE,       --      Contains the ID of the approved plan type --File.Sql.39 bug 4440895
        X_cost_bv_id_tbl        OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql table for cost bv id --File.Sql.39 bug 4440895
        X_rev_bv_id_tbl         OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql table for revenue bv id --File.Sql.39 bug 4440895
        X_all_bv_id_tbl         OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql table for all bv id --File.Sql.39 bug 4440895
        X_select_flag_tbl       OUT     NOCOPY SYSTEM.pa_varchar2_1_tbl_type,                   --      The flag which indicates whether the select flag can be checked by default or not --File.Sql.39 bug 4440895
        X_agreement_num         OUT     NOCOPY Pa_agreements_all.agreement_num%TYPE,           --      Agreement number of the agreement --File.Sql.39 bug 4440895
        X_partially_impl_flag   OUT     NOCOPY VARCHAR2,                                       --      A flag that indicates whether a partially implemented CO exists for the plan type or not. Possible values are Y/N --File.Sql.39 bug 4440895
        X_cost_ci_version_id    OUT     NOCOPY Pa_budget_versions.budget_version_id%TYPE,      --      Ci cost Budget version  id --File.Sql.39 bug 4440895
        X_rev_ci_version_id     OUT     NOCOPY Pa_budget_versions.budget_version_id%TYPE,      --      Ci rev Budget version  id --File.Sql.39 bug 4440895
        X_all_ci_version_id     OUT     NOCOPY Pa_budget_versions.budget_version_id%TYPE,      --      Ci all Budget version  id --File.Sql.39 bug 4440895
        x_rem_proj_revenue      OUT     NOCOPY Pa_budget_versions.total_project_revenue%TYPE,  --      Remaining revenue amount to be implemented --File.Sql.39 bug 4440895
        x_rem_labor_qty         OUT     NOCOPY Pa_budget_versions.labor_quantity%TYPE, --File.Sql.39 bug 4440895
        x_rem_equip_qty         OUT     NOCOPY pa_budget_versions.equipment_quantity%TYPE, --File.Sql.39 bug 4440895
        X_autobaseline_project  OUT     NOCOPY VARCHAR2,                                       --      This flag will be set to Y if the project is enabled for autobaseline --File.Sql.39 bug 4440895
        x_disable_baseline_flag_tbl OUT     NOCOPY SYSTEM.pa_varchar2_1_tbl_type,                   --      Plsql table for Disable Baseline Checkbox Flag -- 3735309 --File.Sql.39 bug 4440895
        x_return_status         OUT     NOCOPY VARCHAR2,                                       --      Indicates the exit status of the API --File.Sql.39 bug 4440895
        x_msg_data              OUT     NOCOPY VARCHAR2,                                       --      Indicates the error occurred --File.Sql.39 bug 4440895
        X_msg_count             OUT     NOCOPY NUMBER)                                         --      Indicates the number of error messages --File.Sql.39 bug 4440895
IS

      -- All plan types attached to the project(excluding work plan and org forecast plan types)
      CURSOR c_plan_types_attached IS
          SELECT  fin.name
                 ,pfo.fin_plan_type_id
                 ,NVL(pfo.approved_cost_plan_type_flag,'N') approved_cost_plan_type_flag
                 ,NVL(pfo.approved_rev_plan_type_flag,'N') approved_rev_plan_type_flag
                 ,fin.plan_class_code
                 ,pfo.fin_plan_preference_code
          FROM    pa_fin_plan_types_vl fin,
                  pa_proj_fp_options pfo
          WHERE   pfo.project_id = p_project_id
          AND     pfo.fin_plan_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE
          AND     pfo.fin_plan_type_id = fin.fin_plan_type_id
          AND     nvl(fin.use_for_workplan_flag,'N') <> 'Y'
          And     nvl(fin.fin_plan_type_code,'NON-ORG') <> 'ORG_FORECAST'
          ORDER BY fin.name;

      -- Start of variables used for debugging purpose

      l_msg_count          NUMBER :=0;
      l_data               VARCHAR2(2000);
      l_msg_data           VARCHAR2(2000);
      l_msg_index_out      NUMBER;
      l_return_status      VARCHAR2(2000);
      l_debug_mode         VARCHAR2(1);
      l_debug_level3       CONSTANT NUMBER := 3;
      l_debug_level5       CONSTANT NUMBER := 5;
      l_mod_name        VARCHAR2(100) := g_module_name || '.GET_PLAN_TYPES_FOR_IMPL' ;
      l_token_name         VARCHAR2(30) :='PROCEDURENAME';

      -- End of variables used for debugging purpose

      i NUMBER; -- The index for the out plsql tbls

      c_plan_type_rec  c_plan_types_attached%ROWTYPE;

      l_cost_impl_flag        VARCHAR2(1);
      l_rev_impl_flag         VARCHAR2(1);
      l_impl_full_flag        VARCHAR2(1);
      l_cost_impact_impl_flag VARCHAR2(1);
      l_rev_impact_impl_flag  VARCHAR2(1);
      l_partially_impl_flag   VARCHAR2(1);

      l_status_code  pa_control_items.status_code%TYPE;
      l_ci_type_id   pa_control_items.ci_type_id%TYPE;

      l_ci_version_type pa_budget_versions.version_type%TYPE;

      l_budget_version_id       Pa_budget_versions.budget_version_id%TYPE;

      l_approved_fin_pt_id      Pa_fin_plan_types_b.fin_plan_type_id%TYPE;

-- Version Type ref is not longer required as both Cost and Revenue Quantity Figures are Retrieved and used now -- 3902176
--      l_version_type            pa_budget_versions.version_type%TYPE;--Bug 3662077

      -- Added for Bug 3735309 - Function Security Check
      l_submit_cost                 VARCHAR2(1);
      l_submit_revenue              VARCHAR2(1);
      l_submit_cost_appr            VARCHAR2(1);
      l_submit_revenue_appr         VARCHAR2(1);
      l_submit_cost_forecast        VARCHAR2(1);
      l_submit_revenue_forecast     VARCHAR2(1);
      l_render_impl_cost_tbl        SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();
      l_render_impl_revenue_tbl     SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();
      l_disable_impl_cost_tbl       SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();
      l_disable_impl_revenue_tbl    SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();
      l_submit_cost_check           VARCHAR2(1);
      l_submit_revenue_check        VARCHAR2(1);

BEGIN

     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'N');


     pa_debug.set_curr_function( p_function   => 'GET_PLAN_TYPES_FOR_IMPL',
                                     p_debug_mode => l_debug_mode );


     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- initialising all the output tables
     X_pt_id_tbl             :=     SYSTEM.pa_num_tbl_type();
     X_pt_name_tbl           :=     SYSTEM.pa_varchar2_150_tbl_type();
     x_cost_impact_impl_tbl  :=     SYSTEM.pa_varchar2_1_tbl_type();
     x_rev_impact_impl_tbl   :=     SYSTEM.pa_varchar2_1_tbl_type();
     X_cost_impl_tbl         :=     SYSTEM.pa_varchar2_1_tbl_type();
     x_rev_impl_tbl          :=     SYSTEM.pa_varchar2_1_tbl_type();
     X_raw_cost_tbl          :=     SYSTEM.pa_num_tbl_type();
     X_burd_cost_tbl         :=     SYSTEM.pa_num_tbl_type();
     X_revenue_tbl           :=     SYSTEM.pa_num_tbl_type();
     X_labor_hrs_c_tbl       :=     SYSTEM.pa_num_tbl_type();
     X_equipment_hrs_c_tbl   :=     SYSTEM.pa_num_tbl_type();
     X_labor_hrs_r_tbl       :=     SYSTEM.pa_num_tbl_type();
     X_equipment_hrs_r_tbl   :=     SYSTEM.pa_num_tbl_type();
     X_margin_tbl            :=     SYSTEM.pa_num_tbl_type();
     X_margin_percent_tbl    :=     SYSTEM.pa_num_tbl_type();
     X_cost_bv_id_tbl        :=     SYSTEM.pa_num_tbl_type();
     X_rev_bv_id_tbl         :=     SYSTEM.pa_num_tbl_type();
     X_all_bv_id_tbl         :=     SYSTEM.pa_num_tbl_type();
     X_select_flag_tbl       :=     SYSTEM.pa_varchar2_1_tbl_type();
     X_margin_derived_code_tbl :=   SYSTEM.pa_varchar2_30_tbl_type(); -- Bug 3734840
     x_disable_baseline_flag_tbl :=     SYSTEM.pa_varchar2_1_tbl_type(); -- Bug 3735309
     -- Check for business rules violations

     IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:='Validating input parameters';
         pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
     END IF;

     -- Check if project id and ci id are null

     IF (p_project_id       IS NULL) OR
        (p_ci_id IS NULL)
     THEN


         IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Project_id = '||p_project_id;
             pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);

             pa_debug.g_err_stage:='Ci_id = '||p_ci_id;
             pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
         END IF;


         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED',
                              p_token1 => l_token_name,
                              p_value1 => l_mod_name);


         IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Invalid Arguments Passed';
             pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
         END IF;
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;


      IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:='Fetching Function Security return codes';
         pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
      END IF;
      -- Fetching Function Security User Privelege for submit for baseline flag
      -- "Financials: Project: Budget: Submit Cost"
      pa_security_pvt.check_user_privilege(x_ret_code      => l_submit_cost,
                                           x_return_status  => l_return_status,
                                           x_msg_count      => l_msg_count,
                                           x_msg_data       => l_msg_data,
                                           p_privilege      => 'PA_FP_BDGT_SUB_COST_PLAN',
                                           p_object_name    => 'PA_PROJECTS',
                                           p_object_key     => P_project_id);

      IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
         IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Error fetching function security - Submit Cost';
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
         END IF;
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      -- "Financials: Project: Budget: Submit Revenue"
      pa_security_pvt.check_user_privilege(x_ret_code      => l_submit_revenue,
                                           x_return_status  => l_return_status,
                                           x_msg_count      => l_msg_count,
                                           x_msg_data       => l_msg_data,
                                           p_privilege      => 'PA_FP_BDGT_SUB_REV_PLAN',
                                           p_object_name    => 'PA_PROJECTS',
                                           p_object_key     => P_project_id);
      IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
         IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Error fetching function security - Submit Revenue';
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
         END IF;
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      -- "Financials: Project: Approved Budget: Submit Cost"
      pa_security_pvt.check_user_privilege(x_ret_code      => l_submit_cost_appr,
                                           x_return_status  => l_return_status,
                                           x_msg_count      => l_msg_count,
                                           x_msg_data       => l_msg_data,
                                           p_privilege      => 'PA_FP_APP_BDGT_SUB_COST_PLAN',
                                           p_object_name    => 'PA_PROJECTS',
                                           p_object_key     => P_project_id);
      IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
         IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Error fetching function security - Submit Cost Approved';
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
         END IF;
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      -- "Financials: Project: Approved Budget: Submit Revenue"
      pa_security_pvt.check_user_privilege(x_ret_code      => l_submit_revenue_appr,
                                           x_return_status  => l_return_status,
                                           x_msg_count      => l_msg_count,
                                           x_msg_data       => l_msg_data,
                                           p_privilege      => 'PA_FP_APP_BDGT_SUB_REV_PLAN',
                                           p_object_name    => 'PA_PROJECTS',
                                           p_object_key     => P_project_id);
      IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
         IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Error fetching function security - Submit Revenue Approved';
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
         END IF;
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      -- "Financials: Project: Forecast: Submit Cost"
      pa_security_pvt.check_user_privilege(x_ret_code      => l_submit_cost_forecast,
                                           x_return_status  => l_return_status,
                                           x_msg_count      => l_msg_count,
                                           x_msg_data       => l_msg_data,
                                           p_privilege      => 'PA_FP_FCST_SUB_COST_PLAN',
                                           p_object_name    => 'PA_PROJECTS',
                                           p_object_key     => P_project_id);
      IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
         IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Error fetching function security - Submit Cost Forecast';
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
         END IF;
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      -- "Financials: Project: Forecast: Submit Revenue"
      pa_security_pvt.check_user_privilege(x_ret_code      => l_submit_revenue_forecast,
                                           x_return_status  => l_return_status,
                                           x_msg_count      => l_msg_count,
                                           x_msg_data       => l_msg_data,
                                           p_privilege      => 'PA_FP_FCST_SUB_REV_PLAN',
                                           p_object_name    => 'PA_PROJECTS',
                                           p_object_key     => P_project_id);
      IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
         IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Error fetching function security - Submit Revenue Forecast';
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
         END IF;
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:='After Fetching Function Security return codes';
         pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);

         pa_debug.g_err_stage:='l_submit_cost: '||l_submit_cost;
         pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);

         pa_debug.g_err_stage:='l_submit_revenue: '||l_submit_revenue;
         pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);

         pa_debug.g_err_stage:='l_submit_cost_appr: '||l_submit_cost_appr;
         pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);

         pa_debug.g_err_stage:='l_submit_revenue_appr: '||l_submit_revenue_appr;
         pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);

         pa_debug.g_err_stage:='l_submit_cost_forecast: '||l_submit_cost_forecast;
         pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);

         pa_debug.g_err_stage:='l_submit_revenue_forecast: '||l_submit_revenue_forecast;
         pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;


      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Entering GET_PLAN_TYPES_FOR_IMPL';
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      BEGIN

            SELECT ci_type_id,status_code
            INTO   l_ci_type_id,l_status_code
            FROM   pa_control_items
            WHERE  ci_id=p_ci_id;

      EXCEPTION
            WHEN NO_DATA_FOUND THEN

                   IF l_DEBUG_MODE = 'Y' THEN
                       pa_debug.g_err_stage:='Error while fetching status of the CI';
                       pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
                   END IF;
                   RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END;

      X_partially_impl_flag := 'N';
      i := 1;

      Pa_Fp_Control_Items_Utils.get_ci_versions(
                        P_ci_id => p_ci_id,
                        X_cost_budget_version_id => x_cost_ci_version_id,
                        X_rev_budget_version_id =>  x_rev_ci_version_id,
                        X_all_budget_version_id =>  x_all_ci_version_id,
                        x_return_status => l_return_status,
                        x_msg_data => l_msg_data,
                        X_msg_count => l_msg_count);


      IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
           IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'Error in GET_CI_VERSIONS';
                pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
           END IF;
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

-- Version Type ref is not longer required as both Cost and Revenue Quantity Figures are Retrieved and used now -- 3902176
/*
      --Derive the version type from the labor/equipement hours are being shown. Based on this, either cost/revenue
      --labor/equipement hours of the plan type will be retrieved. Bug 3662077
      IF NVL(x_all_ci_version_id,-1)<>-1 THEN
          l_version_type:='ALL';
      ELSIF NVL(x_cost_ci_version_id,-1)<>-1 THEN
          l_version_type:='COST';
      ELSIF NVL(x_rev_ci_version_id,-1)<>-1 THEN
          l_version_type:='REVENUE';
      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'l_version_type derived is '||l_version_type;
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;
*/

      x_autobaseline_project := Pa_Fp_Control_Items_Utils.IsFpAutoBaselineEnabled(p_project_id => p_project_id);

      -- Loop for each plan type attached to the project(excluding work plan and org forecast plan types)
      FOR c_plan_type_rec  IN c_plan_types_attached LOOP
           l_rev_impl_flag:=null;
           Pa_Fp_Control_Items_Utils.get_impl_details(
                        P_fin_plan_type_id       => c_plan_type_rec.fin_plan_type_id,
                        P_project_id             => p_project_id,
                        P_app_rev_plan_type_flag => c_plan_type_rec.approved_rev_plan_type_flag,
                        P_ci_id                  => p_ci_id,
                        p_ci_type_id             => l_ci_type_id,
                        P_ci_status              => l_status_code,
                        P_ci_cost_version_id     => x_cost_ci_version_id,
                        P_ci_rev_version_id      => x_rev_ci_version_id,
                        P_ci_all_version_id      => x_all_ci_version_id,
                        x_cost_impl_flag         => l_cost_impl_flag,
                        x_rev_impl_flag          => l_rev_impl_flag,
                        X_cost_impact_impl_flag  => l_cost_impact_impl_flag,
                        x_rev_impact_impl_flag   => l_rev_impact_impl_flag,
                        X_partially_impl_flag    => l_partially_impl_flag,
                        x_agreement_num          => x_agreement_num,
                        x_approved_fin_pt_id     => l_approved_fin_pt_id,
                        x_return_status          => l_return_status,
                        x_msg_data               => l_msg_data,
                        X_msg_count              => l_msg_count);

            IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                 IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:= 'Error in get_impl_details';
                     pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
                 END IF;
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            IF l_approved_fin_pt_id IS NOT NULL THEN
               x_approved_fin_pt_id := l_approved_fin_pt_id;
            END IF;

            X_pt_id_tbl.extend;
            X_pt_name_tbl.extend;
            x_cost_impact_impl_tbl.extend;
            x_rev_impact_impl_tbl.extend;
            X_cost_impl_tbl.extend;
            x_rev_impl_tbl.extend;
            X_raw_cost_tbl.extend;
            X_burd_cost_tbl.extend;
            X_revenue_tbl.extend;
            X_labor_hrs_c_tbl.extend;
            X_equipment_hrs_c_tbl.extend;
            X_labor_hrs_r_tbl.extend;
            X_equipment_hrs_r_tbl.extend;
            X_margin_tbl.extend;
            X_margin_percent_tbl.extend;
            X_cost_bv_id_tbl.extend;
            X_rev_bv_id_tbl.extend;
            X_all_bv_id_tbl.extend;
            X_select_flag_tbl.extend;
            x_margin_derived_code_tbl.extend; -- Bug 3734840

            -- Bug 3735309 for function Security of Submit for Baseline
            x_disable_baseline_flag_tbl.extend;
            l_render_impl_cost_tbl.extend;
            l_render_impl_revenue_tbl.extend;
            l_disable_impl_cost_tbl.extend;
            l_disable_impl_revenue_tbl.extend;

            BEGIN
                 select impl_default_flag
                 INTO x_select_flag_tbl(i)
                 from pa_pt_co_impl_statuses
                 WHERE fin_plan_type_id = c_plan_type_rec.fin_plan_type_id
                 AND ci_type_id = l_ci_type_id
                 AND ROWNUM = 1 ;

            EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                       x_select_flag_tbl(i) := 'N';
            END;

            x_pt_id_tbl(i) := c_plan_type_rec.fin_plan_type_id;
            x_pt_name_tbl(i) := c_plan_type_rec.name;
            x_cost_impact_impl_tbl(i) := l_cost_impact_impl_flag;
            x_rev_impact_impl_tbl(i) :=  l_rev_impact_impl_flag;
            x_cost_impl_tbl(i) := l_cost_impl_flag;
            x_rev_impl_tbl(i) := l_rev_impl_flag;

-- Version Type ref is not longer required as both Cost and Revenue Quantity Figures are Retrieved and used now -- 3902176
            PA_FIN_PLAN_UTILS.get_summary_amounts(
                     p_context                          => PA_FP_CONSTANTS_PKG.G_PLAN_TYPE_CWV_AMOUNTS,
                     P_project_id                       => p_project_id,
                     P_ci_id                            => p_ci_id,
                     P_fin_plan_type_id                 => c_plan_type_rec.fin_plan_type_id,
--                     p_version_type                     => l_version_type, --Bug 3662077
                     X_proj_raw_cost                    => x_raw_cost_tbl(i),
                     X_proj_burdened_cost               => x_burd_cost_tbl(i),
                     X_proj_revenue                     => x_revenue_tbl(i),
                     X_margin                           => x_margin_tbl(i),
                     X_margin_percent                   => X_margin_percent_tbl(i),
                     x_margin_derived_from_code         => x_margin_derived_code_tbl(i),   -- Bug 3734840
                     X_labor_hrs_cost                   => x_labor_hrs_c_tbl(i),
                     X_equipment_hrs_cost               => x_equipment_hrs_c_tbl(i),
                     X_labor_hrs_rev                    => x_labor_hrs_r_tbl(i),
                     X_equipment_hrs_rev                => x_equipment_hrs_r_tbl(i),
                     X_cost_budget_version_id           => x_cost_bv_id_tbl(i),
                     X_rev_budget_version_id            => x_rev_bv_id_tbl(i),
                     X_all_budget_version_id            => x_all_bv_id_tbl(i),
                     x_return_status                    => l_return_status,
                     x_msg_data                         => l_msg_data,
                     X_msg_count                        => l_msg_count);

            IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                 IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:= 'Error in get_summary_amounts';
                     pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
                 END IF;
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            --Bug 5845142. A CI version of type ALL with only approved cost plan type flag as Y should be
            --considered as having cost impact alone. Revenue amounts , though availble , can not be
            --displayed as an impact to approved budget.
            IF c_plan_type_rec.approved_cost_plan_type_flag='Y' AND
               c_plan_type_rec.approved_rev_plan_type_flag='N'  AND
               c_plan_type_rec.fin_plan_preference_code='COST_AND_REV_SAME'  THEN

                 x_revenue_tbl(i)             := NULL;
                 x_margin_tbl(i)              := NULL;
                 X_margin_percent_tbl(i)      := NULL;
                 x_margin_derived_code_tbl(i) := NULL;
                 x_labor_hrs_r_tbl(i)         := NULL;
                 x_equipment_hrs_r_tbl(i)     := NULL;
                 x_cost_bv_id_tbl(i)          := x_all_bv_id_tbl(i);
                 x_rev_bv_id_tbl(i)           := -1;
                 x_all_bv_id_tbl(i)           := -1;

            END IF;

            IF l_partially_impl_flag = 'Y' THEN
                 x_partially_impl_flag := l_partially_impl_flag;


                 IF nvl(x_rev_bv_id_tbl(i),-1) <> -1 THEN
                      l_budget_version_id   := x_rev_bv_id_tbl(i);
                 ELSE
                      l_budget_version_id   := x_all_bv_id_tbl(i);
                 END IF;

                 -- Bug 3962249.
                 -- Derive ci version type for calling get_xxxx funtions below.
                 IF x_rev_ci_version_id IS NOT NULL THEN
                    l_ci_version_type := 'REVENUE';
                 ELSE
                    l_ci_version_type := 'ALL';
                 END IF;

                 x_rem_proj_revenue :=
                        Pa_Fp_Control_Items_Utils.get_pc_revenue_partial(
                               p_version_type       => l_ci_version_type,
                               p_budget_version_id  =>   l_budget_version_id,
                               p_ci_version_id      =>   nvl(x_rev_ci_version_id,x_all_ci_version_id));

                 x_rem_labor_qty :=
                        Pa_Fp_Control_Items_Utils.get_labor_qty_partial(
                               p_version_type       => l_ci_version_type,
                               p_budget_version_id  =>   l_budget_version_id,
                               p_ci_version_id      =>   nvl(x_rev_ci_version_id,x_all_ci_version_id));

                 x_rem_equip_qty :=
                        Pa_Fp_Control_Items_Utils.get_equip_qty_partial(
                               p_version_type       => l_ci_version_type,
                               p_budget_version_id  =>   l_budget_version_id,
                               p_ci_version_id      =>   nvl(x_rev_ci_version_id,x_all_ci_version_id));

            END IF;

            -- Bug 3735309 This data will be used to derive x_disable_baseline_flag_tbl
            IF (l_cost_impl_flag = 'H') THEN
                l_render_impl_cost_tbl(i) := 'N';
            ELSE
                l_render_impl_cost_tbl(i) := 'Y';
            END IF;

            IF (l_rev_impl_flag = 'H') THEN
                l_render_impl_revenue_tbl(i) := 'N';
            ELSE
                l_render_impl_revenue_tbl(i) := 'Y';
            END IF;

            IF (l_cost_impl_flag = 'D') THEN
                l_disable_impl_cost_tbl(i) := 'Y';
            ELSE
                l_disable_impl_cost_tbl(i) := 'N';
            END IF;

            IF (l_rev_impl_flag = 'D') THEN
                l_disable_impl_revenue_tbl(i) := 'Y';
            ELSE
                l_disable_impl_revenue_tbl(i) := 'N';
            END IF;

            /* Deriving function Security to be used
               FOR Forecast use PA_FP_FCST_SUB_COST_PLAN for Cost and PA_FP_FCST_SUB_REV_PLAN for Revenue
               FOR BUDGET
                   FOR APPROVED Cost Use PA_FP_APP_BDGT_SUB_COST_PLAN
                   FOR Cost Use PA_FP_BDGT_SUB_COST_PLAN
                   FOR APPROVED Revenue Use PA_FP_APP_BDGT_SUB_REV_PLAN
                   FOR Revenue Use PA_FP_BDGT_SUB_REV_PLAN
            */
            IF c_plan_type_rec.plan_class_code = 'FORECAST' THEN
               l_submit_cost_check := l_submit_cost_forecast;
               l_submit_revenue_check := l_submit_revenue_forecast;
            ELSE -- For Budget
               IF c_plan_type_rec.approved_cost_plan_type_flag = 'Y' THEN
                  l_submit_cost_check := l_submit_cost_appr;
               ELSE -- For Non Approved Cost
                  l_submit_cost_check := l_submit_cost;
               END IF;

               IF c_plan_type_rec.approved_rev_plan_type_flag = 'Y' THEN
                  l_submit_revenue_check := l_submit_revenue_appr;
               ELSE -- For Non Approved Revenue
                  l_submit_revenue_check := l_submit_revenue;
               END IF;
            END IF;


            IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Deriving x_disable Submit for Baseline';
               pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);

               pa_debug.g_err_stage:= 'l_render_impl_cost :'||l_render_impl_cost_tbl(i);
               pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);

               pa_debug.g_err_stage:= 'l_render_impl_revenue :'||l_render_impl_revenue_tbl(i);
               pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);

               pa_debug.g_err_stage:= 'l_disable_impl_cost :'||l_disable_impl_cost_tbl(i);
               pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);

               pa_debug.g_err_stage:= 'l_disable_impl_revenue :'||l_disable_impl_revenue_tbl(i);
               pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;

            /*
               Submit For Baseline Disable Logic
               a. If Cost and Revenue have been implmented in full then disable Checkbox.
               b1. If Only Cost Check Box is Enabled check for Submit function security for Cost
               b2. If Only Revenue Check Box is Enabled check for Submit function security for Revenue
               b3. If both Cost and Revenue CheckBoxes are enabled, check for availability for either of
                  Submit Revenue or Submit Cost for User
               c. If project is enabled for auto baseline then disable checkbox.
            */

            IF (    (l_cost_impact_impl_flag <> 'Y' OR l_rev_impact_impl_flag <> 'Y')
                AND (     (     (l_render_impl_cost_tbl(i) = 'Y' AND l_disable_impl_cost_tbl(i) = 'N')
                            AND (l_render_impl_revenue_tbl(i) = 'N' OR l_disable_impl_revenue_tbl(i) = 'Y')
                            AND (l_submit_cost_check = 'T'))
                       OR (     (l_render_impl_revenue_tbl(i) = 'Y' AND l_disable_impl_revenue_tbl(i) = 'N')
                            AND (l_render_impl_cost_tbl(i) = 'N' OR l_disable_impl_cost_tbl(i) = 'Y')
                            AND (l_submit_revenue_check = 'T'))
                       OR (     (l_render_impl_cost_tbl(i) = 'Y' AND l_disable_impl_cost_tbl(i) = 'N')
                            AND (l_render_impl_revenue_tbl(i) = 'Y' AND l_disable_impl_revenue_tbl(i) = 'N')
                            AND (l_submit_cost_check = 'T' OR l_submit_revenue_check = 'T')))
                AND (NOT(x_autobaseline_project = 'Y' AND x_pt_id_tbl(i) = l_approved_fin_pt_id
                         AND l_render_impl_revenue_tbl(i) = 'Y' AND l_disable_impl_revenue_tbl(i) = 'N'))) THEN

                 x_disable_baseline_flag_tbl(i) := 'N';
            ELSE
                 x_disable_baseline_flag_tbl(i) := 'Y';
            END IF;

            IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'x_disable_baseline_flag_tbl : '||x_disable_baseline_flag_tbl(i);
               pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;
            -- Bug 3735309 End of changes.

            i := i + 1;
      END LOOP;


      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Exiting GET_PLAN_TYPES_FOR_IMPL';
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;
      pa_debug.reset_curr_function;

EXCEPTION
      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
          l_msg_count := FND_MSG_PUB.count_msg;

          IF c_plan_types_attached%ISOPEN THEN
               CLOSE c_plan_types_attached;
          END IF;
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

          pa_debug.reset_curr_function;
          RETURN;

     WHEN Others THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          IF c_plan_types_attached%ISOPEN THEN
               CLOSE c_plan_types_attached;
          END IF;

          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'Pa_Fp_Control_Items_Utils'
                                  ,p_procedure_name  => 'GET_PLAN_TYPES_FOR_IMPL');
          IF l_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:='Unexpected Error ' || SQLERRM;
               pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
          END IF;
          pa_debug.reset_curr_function;
          RAISE;


END GET_PLAN_TYPES_FOR_IMPL;


/* For each plan type, returns information including whether a change order can be implemented into it.

   OUT paramters X_cost_impl_flag, x_rev_impl_flag can have following values:
   'D' - The cost/rev impact is implemented. This indicates that the checkbox should be checked and disabled in the page
   'H' - The impact can not be implemented. The checkbox should be hidden in the page
   'X' - The impact has not been implemented. The  working version does not exist for the plan type. The checkbox should be displayed on the page
   'Y' - The impact has not been implemented. The working version exists for the plan type. The checkbox should be displayed on the page.

   'R' - Partial implementation has happened. This is applicable only for x_rev_impl_flag.

   The OUT parameters X_partially_impl_flag, x_agreement_num and x_approved_fin_pt_id will be passed back only in the context of
   current working version of approved revenue plan type

   See comments for other OUT parameters to know what they indicate */

PROCEDURE GET_IMPL_DETAILS(P_fin_plan_type_id        IN   Pa_fin_plan_types_b.fin_plan_type_id%TYPE                  --  Id of the plan type
                          ,P_project_id              IN   Pa_budget_versions.project_id%TYPE                         --  Id of the Project
                          ,P_app_rev_plan_type_flag  IN   pa_budget_versions.approved_rev_plan_type_flag%TYPE   DEFAULT  NULL   --  Indicates whether the plan type passed is approved rev_plan_type or not. If the value is NULL the value will be derived
                          ,P_ci_id                   IN   Pa_budget_versions.ci_id%TYPE                              --  Id of the Change Order
                          ,p_ci_type_id              IN   pa_control_items.ci_type_id%TYPE           DEFAULT  NULL
                          ,P_ci_status               IN   Pa_control_items.status_code%TYPE          DEFAULT  NULL   --  Status of the Change Order
                          ,P_ci_cost_version_id      IN   Pa_budget_versions.budget_version_id%TYPE  DEFAULT  NULL   --  Id of the Cost ci version
                          ,P_ci_rev_version_id       IN   Pa_budget_versions.budget_version_id%TYPE  DEFAULT  NULL   --  Id of the Revenue ci version
                          ,P_ci_all_version_id       IN   Pa_budget_versions.budget_version_id%TYPE  DEFAULT  NULL   --  Id of the All ci version
                             ,p_targ_bv_id              IN   Pa_budget_versions.budget_version_id%TYPE  DEFAULT  NULL   --  Id of the target budget version. Bug 3745163
                          ,x_cost_impl_flag          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                          ,x_rev_impl_flag           OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                          ,X_cost_impact_impl_flag   OUT  NOCOPY VARCHAR2      --             Contains 'Y' if the cost impact is completely implemented --File.Sql.39 bug 4440895
                          ,x_rev_impact_impl_flag    OUT  NOCOPY VARCHAR2      --             Contains 'Y' if the revenue impact is completely implemented --File.Sql.39 bug 4440895
                          ,X_partially_impl_flag     OUT  NOCOPY VARCHAR2      --             Can be Y or N. Indicates whether a CI is partially implemented . --File.Sql.39 bug 4440895
                          ,x_agreement_num           OUT  NOCOPY pa_agreements_all.agreement_num%TYPE  -- Agreement Number. Has meaning only in the context of an approved revenue plan type. --File.Sql.39 bug 4440895
                          ,x_approved_fin_pt_id      OUT  NOCOPY Pa_fin_plan_types_b.fin_plan_type_id%TYPE -- If p_fin_plan_type_id is an approved revenue plan type, this is equal to p_fin_plan_type_id --File.Sql.39 bug 4440895
                          ,x_return_status           OUT  NOCOPY VARCHAR2         --             Indicates the exit status of the API --File.Sql.39 bug 4440895
                          ,x_msg_data                OUT  NOCOPY VARCHAR2         --             Indicates the error occurred --File.Sql.39 bug 4440895
                          ,X_msg_count               OUT  NOCOPY NUMBER)          --             Indicates the number of error messages --File.Sql.39 bug 4440895
IS

     CURSOR c_implementable_status(c_status_code IN pa_pt_co_impl_statuses.status_code%TYPE,
                                  c_impact_type_code IN pa_pt_co_impl_statuses.version_type%TYPE,
                                  c_ci_type_id IN pa_pt_co_impl_statuses.ci_type_id%TYPE) IS
       SELECT 'Y'
       FROM   dual
       WHERE
       EXISTS  (SELECT 'X'
                FROM   pa_pt_co_impl_statuses popt
                WHERE  popt.status_code =c_status_code
                AND    popt.version_type = c_impact_type_code
                AND    popt.fin_plan_type_id = p_fin_plan_type_id
                AND    popt.ci_type_id = c_ci_type_id);

     CURSOR c_impact_impl_csr(c_version_id IN pa_fp_merged_Ctrl_items.plan_version_id%TYPE,
                              c_ci_version_id IN pa_fp_merged_Ctrl_items.ci_plan_version_id%TYPE,
                              c_version_type IN pa_fp_merged_Ctrl_items.version_type%TYPE) IS
       SELECT 'X'
       FROM   pa_fp_merged_Ctrl_items
       WHERE  ci_id=p_ci_id
       AND    plan_version_id = c_version_id
       AND    ci_plan_version_id = c_ci_version_id
       AND    project_id = p_project_id
       AND    version_type=c_version_type;

     -- Start of variables used for debugging purpose

      l_msg_count          NUMBER :=0;
      l_data               VARCHAR2(2000);
      l_msg_data           VARCHAR2(2000);
      l_msg_index_out      NUMBER;
      l_return_status      VARCHAR2(2000);
      l_debug_mode         VARCHAR2(1);
      l_debug_level3       CONSTANT NUMBER := 3;
      l_debug_level5       CONSTANT NUMBER := 5;
      l_mod_name           VARCHAR2(100) := 'GET_IMPL_DETAILS' || g_module_name;
      l_token_name         VARCHAR2(30) :='PROCEDURENAME';

      -- End of variables used for debugging purpose

      l_is_impl             VARCHAR2(1);
      l_ci_version_id           Pa_budget_versions.budget_version_id%TYPE;
      l_budget_version_id       Pa_budget_versions.budget_version_id%TYPE;

      l_cost_budget_version_id  Pa_budget_versions.budget_version_id%TYPE;
      l_rev_budget_version_id   Pa_budget_versions.budget_version_id%TYPE;
      l_all_budget_version_id   Pa_budget_versions.budget_version_id%TYPE;

      l_ci_type_id              pa_control_items.ci_type_id%TYPE;

      l_status_allows_cost_impl  VARCHAR2(1);
      l_status_allows_rev_impl   VARCHAR2(1);

      l_app_rev_plan_type_flag   pa_proj_fp_options.approved_rev_plan_type_flag%TYPE;

      l_agreement_amount         NUMBER;
      l_agreement_currency_code  pa_agreements_all.agreement_currency_code%TYPE;

      l_ci_cost_version_id       Pa_budget_versions.budget_version_id%TYPE;
      l_ci_rev_version_id        Pa_budget_versions.budget_version_id%TYPE;
      l_ci_all_version_id        Pa_budget_versions.budget_version_id%TYPE;

      l_status_code  pa_control_items.status_code%TYPE;
      l_target_version_id pa_budget_versions.budget_version_id%TYPE;

      l_rev_impl_full            VARCHAR2(1); -- Will indicate if revenue has been implemented in full or not

      l_version_type             Pa_budget_versions.version_type%TYPE; -- Bug 3745163

      l_current_working_flag     Pa_budget_versions.current_working_flag%TYPE; -- Bug 3732446

      --Bug 5845142
      l_t_app_cost_flag          pa_budget_versions.approved_cost_plan_type_flag%TYPE;
      l_t_app_rev_flag           pa_budget_versions.approved_rev_plan_type_flag%TYPE;
      l_t_pt_pref_code           pa_proj_fp_options.fin_plan_preference_code%TYPE;

BEGIN

     pa_debug.set_curr_function( p_function   => 'GET_IMPL_DETAILS',
                                 p_debug_mode => P_PA_debug_mode );


     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;


     -- Check if project id and ci id are null

     IF (p_project_id       IS NULL) OR (p_ci_id IS NULL) OR (p_fin_plan_type_id IS NULL)
     THEN


         IF P_PA_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Project_id = '||p_project_id;
             pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);

             pa_debug.g_err_stage:='Ci_id = '||p_ci_id;
             pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);

             pa_debug.g_err_stage:='p_fin_plan_type_id = '||p_fin_plan_type_id;
             pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);

         END IF;


         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED',
                              p_token1 => l_token_name,
                              p_value1 => l_mod_name);


         IF P_PA_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Invalid Arguments Passed';
             pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
         END IF;
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

     END IF;


     IF P_PA_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Entering GET_IMPL_DETAILS';
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
     END IF;

     IF p_ci_status IS NULL OR p_ci_type_id IS NULL THEN
          BEGIN
               SELECT status_code, ci_type_id
               INTO   l_status_code, l_ci_type_id
               FROM   pa_control_items
               WHERE  ci_id=p_ci_id;
          EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    RAISE ;
          END;
     ELSE
          l_status_code := p_ci_status;
          l_ci_type_id := p_ci_type_id;
     END IF;

     -- Check to see if the status of the control iitem is defined to be implementable

     OPEN c_implementable_status(l_status_code,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST,l_ci_type_id);
     FETCH c_implementable_status INTO l_is_impl;
     IF c_implementable_status%FOUND THEN
          l_status_allows_cost_impl := 'Y';
     ELSE
          l_status_allows_cost_impl := 'N';
     END IF;
     CLOSE c_implementable_status;

     OPEN c_implementable_status(l_status_code,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE,l_ci_type_id);
     FETCH c_implementable_status INTO l_is_impl;
     IF c_implementable_status%FOUND THEN
          l_status_allows_rev_impl := 'Y';
     ELSE
          l_status_allows_rev_impl := 'N';
     END IF;
     CLOSE c_implementable_status;


     x_cost_impl_flag := 'H';
     x_rev_impl_flag := 'H';
     x_cost_impact_impl_flag :='Y';
     x_rev_impact_impl_flag := 'Y';

     IF p_ci_cost_version_id IS NULL AND p_ci_rev_version_id IS NULL AND p_ci_all_version_id IS NULL THEN
          Pa_Fp_Control_Items_Utils.GET_CI_VERSIONS(P_ci_id          => p_ci_id,
                                            X_cost_budget_version_id => l_ci_cost_version_id,
                                            X_rev_budget_version_id  => l_ci_rev_version_id,
                                            X_all_budget_version_id  => l_ci_all_version_id,
                                            x_return_status          => l_return_status,
                                            x_msg_data               => l_msg_data,
                                            X_msg_count              => l_msg_count);

           IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                IF P_PA_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:= 'Error in GET_CI_VERSIONS';
                     pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;
     ELSE
          l_ci_cost_version_id := p_ci_cost_version_id;
          l_ci_rev_version_id  := p_ci_rev_version_id;
          l_ci_all_version_id  := p_ci_all_version_id;
     END IF;

     --Bug 5845142.
     SELECT NVL(approved_cost_plan_type_flag,'N'),
            NVL(approved_rev_plan_type_flag,'N'),
            fin_plan_preference_code
     INTO   l_t_app_cost_flag,
            l_t_app_rev_flag,
            l_t_pt_pref_code
     FROM   pa_proj_fp_options
     WHERE  project_id=p_project_id
     AND    fin_plan_type_id=p_fin_plan_type_id
     AND    fin_plan_version_id IS NULL;

     --Bug 5845142. If the plan type is approved for only cost but contains revenue amounts then
     --the revenue impact of the change order should not be considered
     IF l_t_app_cost_flag='Y' AND
        l_t_app_rev_flag ='N' AND
        l_t_pt_pref_code='COST_AND_REV_SAME' THEN

          l_ci_rev_version_id:=NULL;

     END IF;

     -- Bug 3745163

     /* -1 indicates that the variable will not have meaning in the context. The code down the line will
        assign values to the relevant bv id variable */

     l_cost_budget_version_id := -1;
     l_rev_budget_version_id := -1;
     l_all_budget_version_id := -1;

     l_current_working_flag := 'Y';

     IF p_targ_bv_id IS NOT NULL THEN
          SELECT version_type,current_working_flag
          INTO   l_version_type,l_current_working_flag
          FROM   pa_budget_versions
          WHERE  budget_version_id=p_targ_bv_id;

          IF l_version_type=PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST THEN
               l_ci_rev_version_id  := NULL;
               l_cost_budget_version_id := p_targ_bv_id;
          ELSIF l_version_type=PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE THEN
               l_ci_cost_version_id  := NULL;
               l_rev_budget_version_id := p_targ_bv_id;
          ELSIF l_version_type=PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL THEN
               l_all_budget_version_id := p_targ_bv_id;
          END IF;

     ELSE

          IF P_PA_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:= 'Calling GET_CURR_WORKING_VERSION_IDS';
                   pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
          END IF;

          pa_fin_plan_utils.GET_CURR_WORKING_VERSION_IDS(P_fin_plan_type_id          => P_fin_plan_type_id
                                                         ,P_project_id               => p_project_id
                                                         ,X_cost_budget_version_id   => l_cost_budget_version_id
                                                         ,X_rev_budget_version_id    => l_rev_budget_version_id
                                                         ,X_all_budget_version_id    => l_all_budget_version_id
                                                         ,x_return_status            => l_return_status
                                                         ,x_msg_data                 => l_msg_data
                                                         ,X_msg_count                => l_msg_count);


          IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
              IF P_PA_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:= 'Error in GET_CURR_WORKING_VERSION_IDS';
                   pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
              END IF;
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;
     END IF;


     --Bug 3663513. The IF ELSIF is changed to IF END IF .. since a ci can have more than one version.
     IF l_ci_cost_version_id IS NOT NULL THEN
     -- There is cost impact
          IF l_cost_budget_version_id = -1 THEN
          -- -1 indicates a "COST" budget version cannot exist for this plan type
               l_target_version_id := l_all_budget_version_id;
          ELSE
               l_target_version_id := l_cost_budget_version_id;
          END IF;

          IF nvl(l_target_version_id,-1) <> -1 THEN
          -- If the current working version exists, check to see if cost has been implemented
               OPEN c_impact_impl_csr(l_target_version_id , l_ci_cost_version_id, 'COST');
               FETCH c_impact_impl_csr INTO l_is_impl;
               IF c_impact_impl_csr%FOUND THEN
               -- Cost has already been implemented
                    x_cost_impl_flag := 'D';
               ELSE
               -- Cost has not been implemented
                    x_cost_impl_flag := 'Y';
               END IF;
               CLOSE c_impact_impl_csr;

          ELSIF l_target_version_id IS NULL THEN
          -- NULL indicates no current working version exists for this plan type
                x_cost_impl_flag := 'X';
          END IF;

      END IF;

      IF l_ci_rev_version_id IS NOT NULL THEN
      -- There is revenue impact
          IF l_rev_budget_version_id = -1 THEN
          -- -1 indicates a "REVENUE" budget version cannot exist for this plan type
               l_target_version_id := l_all_budget_version_id;
          ELSE
               l_target_version_id := l_rev_budget_version_id;
          END IF;

          IF nvl(l_target_version_id,-1) <> -1 THEN
          -- If the current working version exists, check to see if revenue has been implemented
               OPEN c_impact_impl_csr(l_target_version_id , l_ci_rev_version_id, 'REVENUE');
               FETCH c_impact_impl_csr INTO l_is_impl;
               IF c_impact_impl_csr%FOUND THEN
               -- Revenue has already been implemented either fully or partially
                    x_rev_impl_flag := 'D';
               ELSE
                    x_rev_impl_flag := 'Y';
               END IF;
               CLOSE c_impact_impl_csr;

          ELSIF l_target_version_id IS NULL THEN
          -- NULL indicates no current working version exists for this plan type
                x_rev_impl_flag := 'X';
          END IF;

      END IF;

      IF l_ci_all_version_id IS NOT NULL THEN
      -- There is both cost and revenue impact
          IF l_all_budget_version_id = -1 THEN
          /* -1 indicates an "ALL" budget version cannot exist for this plan type
             In this case, see if cost/revenue budget versions exist */

               IF NVL(l_version_type,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST) = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST THEN
               --This chunk of code needs to be executed only when version type is COST or targ bv id is not passed
                    IF nvl(l_cost_budget_version_id,-1) <> -1 THEN
                         OPEN c_impact_impl_csr(l_cost_budget_version_id , l_ci_all_version_id, 'COST');
                         FETCH c_impact_impl_csr INTO l_is_impl;
                         IF c_impact_impl_csr%FOUND THEN
                              x_cost_impl_flag := 'D';
                         ELSE
                              x_cost_impl_flag := 'Y';
                         END IF;
                         CLOSE c_impact_impl_csr;
                    ELSIF l_cost_budget_version_id IS NULL THEN
                         x_cost_impl_flag := 'X';
                    END IF;
               END IF;

               IF NVL(l_version_type,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE) = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE THEN
               --This chunk of code needs to be executed only when version type is REVENUE or targ bv id is not passed
                    IF nvl(l_rev_budget_version_id,-1) <> -1 THEN
                         OPEN c_impact_impl_csr(l_rev_budget_version_id , l_ci_all_version_id, 'REVENUE');
                         FETCH c_impact_impl_csr INTO l_is_impl;
                         IF c_impact_impl_csr%FOUND THEN
                              x_rev_impl_flag := 'D';
                         ELSE
                              x_rev_impl_flag := 'Y';
                         END IF;
                         CLOSE c_impact_impl_csr;
                    ELSIF l_rev_budget_version_id IS NULL THEN
                         x_rev_impl_flag := 'X';
                    END IF;
               END IF;

          ELSIF l_all_budget_version_id IS NOT NULL THEN
               OPEN c_impact_impl_csr(l_all_budget_version_id , l_ci_all_version_id, 'COST');
               FETCH c_impact_impl_csr INTO l_is_impl;
               IF c_impact_impl_csr%FOUND THEN
                    x_cost_impl_flag := 'D';
               ELSE
                    x_cost_impl_flag := 'Y';
               END IF;
               CLOSE c_impact_impl_csr;

               OPEN c_impact_impl_csr(l_all_budget_version_id , l_ci_all_version_id, 'REVENUE');
               FETCH c_impact_impl_csr INTO l_is_impl;
               IF c_impact_impl_csr%FOUND THEN
                    x_rev_impl_flag := 'D';
               ELSE
                    x_rev_impl_flag := 'Y';
               END IF;
               CLOSE c_impact_impl_csr;
          ELSE
          -- NULL indicates no current working version exists for this plan type
               x_cost_impl_flag := 'X';
               x_rev_impl_flag := 'X';
          END IF;
     END IF;

     -- Derive the approved_rev_plan_type_flag if not passed
     IF l_current_working_flag = 'Y' THEN
          IF p_app_rev_plan_type_flag IS NULL THEN
               BEGIN
                    SELECT approved_rev_plan_type_flag
                    INTO   l_app_rev_plan_type_flag
                    FROM   pa_proj_fp_options
                    WHERE  project_id = p_project_id
                    AND  fin_plan_option_level_code = 'PLAN_TYPE'
                    AND  fin_plan_type_id = p_fin_plan_type_id;

               EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                         IF P_PA_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:='No data found while getting approved_rev_plan_type_flag ';
                              pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
                         END IF;
                         RAISE ;
               END;
          ELSE
               l_app_rev_plan_type_flag := p_app_rev_plan_type_flag;

          END IF;


          IF l_app_rev_plan_type_flag = 'Y' THEN
               Pa_Fp_Control_Items_Utils.get_fp_ci_agreement_dtls(p_project_id              =>  p_project_id,
                                                                  p_ci_id                   =>  p_ci_id,
                                                                  x_agreement_num           =>  x_agreement_num,
                                                                  x_agreement_amount        =>  l_agreement_amount,
                                                                  x_agreement_currency_code =>  l_agreement_currency_code,
                                                                  x_msg_data                =>  l_msg_data,
                                                                  x_msg_count               =>  l_msg_count,
                                                                  x_return_status           =>  l_return_status);

               IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                     IF P_PA_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:= 'Error in get_fp_ci_agreement_dtls';
                          pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
                     END IF;
                     RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

               -- Modified if clause below for Bug 3668169
               --Changed the select for bug 3663513. This should get executed only if the revenue version exists
               IF  ((nvl(l_rev_budget_version_id,-1) <> -1 OR nvl(l_all_budget_version_id,-1) <> -1))
                    AND ((l_ci_rev_version_id IS NOT NULL) OR (l_ci_all_version_id IS NOT NULL)) THEN

     /* Scheme Used to Derive Partial Impl Flag Below(this might change)
        ---------------------------------------------
        Fetch partial impl flag from pa_budget_versions
        for the ci_version
          If Flag is Y then
              Return Y
          If Flag is not Y then
              Check if revenue record exists for ci version and plan version
              in pa_fp_merged_ctrl_items.
              If Record Exists - Fuull Impl has taken place return N
              Else Check Partial Rev Enable FLag for plan type
                   If Y then
                      return Y
                   else
                      return N */

                   BEGIN
                        -- Changed Select below for Bug 3668169
                         SELECT nvl(rev_partially_impl_flag,'N')
                           INTO x_partially_impl_flag
                           FROM pa_budget_versions pbv
                          WHERE pbv.budget_Version_id = nvl(l_ci_rev_version_id,l_ci_all_version_id);

     /*                  SELECT nvl(rev_partially_impl_flag,'N')
                         INTO   x_partially_impl_flag
                         FROM   pa_budget_versions pbv
                         WHERE  pbv.budget_Version_id =  decode( nvl(l_rev_budget_version_id,-1),
                                                                 -1,l_all_budget_version_id,
                                                                 l_rev_budget_version_id); */

                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                             IF P_PA_debug_mode = 'Y' THEN
                                  pa_debug.g_err_stage:='get rev_partially_impl_flag - NO_DATA_FOUND ';
                                  pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
                             END IF;
                             RAISE ;
                    END;

                    -- Added Code below for Bug 3668169 -- Starts
                    IF x_partially_impl_flag = 'N' THEN
                       BEGIN
                             SELECT 'Y'
                               INTO l_rev_impl_full
                               FROM DUAL
                              WHERE EXISTS (SELECT 1
                                               FROM PA_FP_MERGED_CTRL_ITEMS
                                              WHERE CI_PLAN_VERSION_ID =  nvl(l_ci_rev_version_id,l_ci_all_version_id)
                                                AND version_type = 'REVENUE'
                                                AND PLAN_VERSION_ID = decode(nvl(l_rev_budget_version_id,-1),-1,l_all_budget_version_id
                                                                                                               ,l_rev_budget_version_id));
                       EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                 IF P_PA_debug_mode = 'Y' THEN
                                      pa_debug.g_err_stage:='Deriving rev partial flag - Rev not yet implemented';
                                      pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
                                 END IF;
                                 l_rev_impl_full := 'N';
                       END;

                       IF l_rev_impl_full = 'Y' THEN
                          x_partially_impl_flag := 'N';
                       ELSIF l_rev_impl_full = 'N' THEN
                           BEGIN
                               SELECT nvl(enable_partial_impl_flag,'N')
                                 INTO x_partially_impl_flag
                                 FROM PA_FIN_PLAN_TYPES_B
                                WHERE fin_plan_type_id = p_fin_plan_type_id;
                           EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                     IF P_PA_debug_mode = 'Y' THEN
                                        pa_debug.g_err_stage:='Deriving rev partial flag : Record not found for plan type';
                                        pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
                                     END IF;
                                     RAISE;
                           END;
                       END IF;
                    END IF;
                    -- Code for Bug 3668169 -- Ends

                ELSE
                    x_partially_impl_flag := 'N';
                END IF;

                IF x_partially_impl_flag = 'Y' THEN
                    x_rev_impl_flag := 'R';
                END IF;

                x_approved_fin_pt_id := p_fin_plan_type_id;
          END IF;
     END IF; -- IF l_current_working_flag = 'Y'

     IF x_cost_impl_flag = 'D' THEN
     -- Cost is implemented
          X_cost_impact_impl_flag := 'Y';
     ELSE
          IF x_cost_impl_flag ='H' AND x_rev_impl_flag ='D' THEN
          /* This is the case where there can be no cost version for the plan type and revenue has been completely implemented.
             So X_cost_impact_impl_flag is set to 'Y' to have the 'Implemented in Full' icon enabled. NOTE: It doesnt mean that cost
             has been implemented into this plan type*/
               X_cost_impact_impl_flag := 'Y';
          ELSE
               X_cost_impact_impl_flag := 'N';
          END IF;
     END IF;

     IF x_rev_impl_flag = 'D' THEN
     -- Revenue is completely implemented
          X_rev_impact_impl_flag := 'Y';
     ELSE
          IF x_rev_impl_flag = 'H' AND x_cost_impl_flag = 'D' THEN
          /* This is the case where there can be no revenue version for the plan type and cost has been implemented.
             So X_rev_impact_impl_flag is set to 'Y' to have the 'Implemented in Full' icon enabled. NOTE: It doesnt mean that revenue
             has been implemented into this plan type*/
               X_rev_impact_impl_flag := 'Y';
          ELSE
               X_rev_impact_impl_flag := 'N';
          END IF;
     END IF;


     IF l_status_allows_cost_impl = 'N' THEN
     -- Status does not allow cost implementation
          X_cost_impl_flag := 'H';
     END IF;

     IF l_status_allows_rev_impl = 'N' THEN
     -- Status does not allow revenue implementation
          X_rev_impl_flag := 'H';
     END IF;

     IF P_PA_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Exiting GET_IMPL_DETAILS';
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
     END IF;

     pa_debug.reset_curr_function;

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

          pa_debug.reset_curr_function;
          RETURN;

     WHEN Others THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'Pa_Fp_Control_Items_Utils'
                                  ,p_procedure_name  => 'GET_IMPL_DETAILS');
          IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:='Unexpected Error ' || SQLERRM;
               pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
          END IF;
          pa_debug.reset_curr_function;
          RAISE;

END GET_IMPL_DETAILS;

-- This function returns either Y or N. If the user status code passed exists in
-- pa_pt_co_impl_statuses, meaning that there exists a ci type whose change
-- documents can be implemented/included into the working versions of a
-- plan type, then Y is returned. N is returned otherwise
FUNCTION  is_user_status_implementable(p_status_code IN pa_control_items.status_code%TYPE)
RETURN VARCHAR2
IS
l_status_implementable     VARCHAR2(1);
BEGIN

    BEGIN
        SELECT 'Y'
        INTO   l_status_implementable
        FROM   DUAL
        WHERE  EXISTS (SELECT 'X'
                       FROM   pa_pt_co_impl_statuses
                       WHERE  status_code=p_status_code);
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        l_status_implementable:='N';
    END;

    RETURN l_status_implementable;

END;

--This API will be called from the View Financial Impact page. This API will return the details required for
--that page
--p_budget_version_id is the target version id with which comparision happens in the view fin impact page. If this
--is available its not required to fetch the approved cost/rev current working ids.
PROCEDURE get_dtls_for_view_fin_imp_pg
(p_project_id                  IN     pa_projects_all.project_id%TYPE,
p_ci_id                        IN     pa_control_items.ci_id%TYPE,
p_ci_cost_version_id           IN     pa_budget_versions.budget_version_id%TYPE,
p_ci_rev_version_id            IN     pa_budget_versions.budget_version_id%TYPE,
p_ci_all_version_id            IN     pa_budget_versions.budget_version_id%TYPE,
p_budget_version_id            IN     pa_budget_versions.budget_version_id%TYPE,
x_app_cost_cw_ver_id           OUT    NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
x_app_rev_cw_ver_id            OUT    NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
x_ci_status_code               OUT    NOCOPY pa_control_items.status_code%TYPE, --File.Sql.39 bug 4440895
x_project_currency_code        OUT    NOCOPY pa_projects_all.project_currency_code%TYPE, --File.Sql.39 bug 4440895
x_impact_in_mc_flag            OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
x_targ_version_type            OUT    NOCOPY pa_budget_Versions.version_type%TYPE, --File.Sql.39 bug 4440895
x_show_resources_flag          OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
x_plan_class_code              OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
x_report_cost_using            OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
x_cost_impl_into_app_cw_ver    OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
x_rev_impl_into_app_cw_ver     OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
x_ci_type                      OUT    NOCOPY pa_ci_types_vl.name%TYPE, --File.Sql.39 bug 4440895
x_ci_number                    OUT    NOCOPY pa_control_items.ci_number%TYPE, --File.Sql.39 bug 4440895
x_msg_data                     OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
x_msg_count                    OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
x_return_status                OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
  --Start of variables used for debugging
  l_msg_count          NUMBER :=0;
  l_data               VARCHAR2(2000);
  l_msg_data           VARCHAR2(2000);
  l_error_msg_code     VARCHAR2(30);
  l_msg_index_out      NUMBER;
  l_return_status      VARCHAR2(2000);
  l_debug_mode         VARCHAR2(30);
  l_module_name        VARCHAR2(100) := 'PAFPCIUB.get_dtls_for_view_fin_imp_pg' ;
  --End of variables used for debugging
  l_cost_ci_version_id        pa_budget_versions.budget_version_id%TYPE;
  l_rev_ci_version_id         pa_budget_versions.budget_version_id%TYPE;
  l_all_ci_version_id         pa_budget_versions.budget_version_id%TYPE;
  l_ci_resource_list_id1      pa_resource_lists_all_bg.resource_list_id%TYPE;
  l_ci_resource_list_id2      pa_resource_lists_all_bg.resource_list_id%TYPE;
  l_targ_resource_list_id1    pa_resource_lists_all_bg.resource_list_id%TYPE;
  l_targ_resource_list_id2    pa_resource_lists_all_bg.resource_list_id%TYPE;
  l_dummy                     VARCHAR2(1);

  CURSOR c_ci_merge_csr(c_version_type  pa_budget_Versions.version_type%TYPE,
                        c_ci_version_id pa_budget_Versions.budget_Version_id%TYPE,
                        c_app_cw_ver_id pa_budget_Versions.budget_Version_id%TYPE)
  IS
  SELECT 'x'
  FROM   DUAL
  WHERE  EXISTS (SELECT 'x'
                 FROM   pa_fp_merged_ctrl_items
                 WHERE  ci_id=p_ci_id
                 AND    plan_version_id=c_app_cw_ver_id
                 AND    ci_plan_version_id=c_ci_version_id
                 AND    version_type=c_version_type);
BEGIN
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
  l_debug_mode := NVL(l_debug_mode, 'Y');
  x_msg_count := 0;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  PA_DEBUG.Set_Curr_Function( p_function   => l_module_name,
                              p_debug_mode => l_debug_mode );

  IF p_ci_id IS NULL OR
     p_project_id IS NULL  THEN

      IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:= 'Passed project id is '||p_project_id;
         pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

         pa_debug.g_err_stage:= 'Passed p_ci_id is '||p_ci_id;
         pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

      END IF;

      PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                          p_msg_name        => 'PA_FP_INV_PARAM_PASSED',
                          p_token1          => 'PROCEDURENAME',
                          p_value1          => l_module_name);

      RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

  END IF;

  --Get the ci versions if not passed
  IF p_ci_cost_version_id IS NULL AND
     p_ci_rev_version_id IS NULL  AND
     p_ci_all_version_id IS NULL THEN

      Pa_Fp_Control_Items_Utils.get_ci_versions
                  (p_ci_id                    => p_ci_id,
                   x_cost_budget_version_id   => l_cost_ci_version_id,
                   x_rev_budget_version_id    => l_rev_ci_version_id,
                   x_all_budget_version_id    => l_all_ci_version_id,
                   x_return_status            => x_return_status,
                   x_msg_data                 => x_msg_data,
                   X_msg_count                => x_msg_count);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

          IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Called API Pa_Fp_Control_Items_Utils.get_ci_versions  returned error';
              pa_debug.write( l_module_name,pa_debug.g_err_stage,5);
          END IF;

          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;
  ELSE

      l_cost_ci_version_id:=p_ci_cost_version_id;
      l_rev_ci_version_id:=p_ci_rev_version_id;
      l_all_ci_version_id:=p_ci_all_version_id;

  END IF;

  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:='Getting project currency code';
      pa_debug.write( l_module_name,pa_debug.g_err_stage,5);
  END IF;


  --Get the project currency code
  SELECT project_currency_code
  INTO   x_project_currency_code
  FROM   pa_projects_all
  WHERE  project_id=p_project_id;

  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:='Getting ci status code';
      pa_debug.write( l_module_name,pa_debug.g_err_stage,3);
  END IF;

  --Get the CI status code
  SELECT pps.project_system_status_code
  INTO   x_ci_status_code
  FROM   pa_control_items pci,
         pa_project_statuses pps
  WHERE  pci.ci_id=p_ci_id
  AND    pps.project_status_code=pci.status_code;

  --Derive the value for x_impact_in_mc_flag. This should be 'Y' if either COST or REVENUE impact is
  --defined in multiple currencies
  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:='Getting impact is mc flag';
      pa_debug.write( l_module_name,pa_debug.g_err_stage,3);
  END IF;

  IF NVL(l_cost_ci_version_id,NVL(l_all_ci_version_id,l_rev_ci_version_id)) <>
     NVL(l_rev_ci_version_id,NVL(l_all_ci_version_id,l_cost_ci_version_id)) THEN

      SELECT NVL(pfoc.margin_derived_from_code,'B'),
             DECODE(nvl(pfoc.plan_in_multi_curr_flag,'N'),
                    'N',DECODE(nvl(pfor.plan_in_multi_curr_flag,'N'),
                               'N','N',
                               'Y'),
                    'Y'),
             NVL(pfoc.cost_resource_list_id,NVL(pfoc.all_resource_list_id,pfoc.revenue_resource_list_id)),
             NVL(pfoc.revenue_resource_list_id,NVL(pfoc.all_resource_list_id,pfoc.cost_resource_list_id))
      INTO   x_report_cost_using,
             x_impact_in_mc_flag,
             l_ci_resource_list_id1,
             l_ci_resource_list_id2
      FROM   pa_proj_fp_options pfoc,
             pa_proj_fp_options pfor
      WHERE  pfoc.fin_plan_version_id = NVL(l_cost_ci_version_id,NVL(l_all_ci_version_id,l_rev_ci_version_id))
      AND    pfor.fin_plan_version_id = NVL(l_rev_ci_version_id,NVL(l_all_ci_version_id,l_cost_ci_version_id));

  ELSE

      SELECT DECODE(pfo.fin_plan_preference_code,
                    'REVENUE_ONLY',NULL,
                    NVL(pfo.margin_derived_from_code,'B')),
             NVL(pfo.plan_in_multi_curr_flag,'N'),
             NVL(pfo.cost_resource_list_id,NVL(pfo.all_resource_list_id,pfo.revenue_resource_list_id)),
             NVL(pfo.cost_resource_list_id,NVL(pfo.all_resource_list_id,pfo.revenue_resource_list_id))
      INTO   x_report_cost_using,
             x_impact_in_mc_flag,
             l_ci_resource_list_id1,
             l_ci_resource_list_id2
      FROM   pa_proj_fp_options pfo
      WHERE  pfo.fin_plan_version_id=NVL(l_rev_ci_version_id,NVL(l_all_ci_version_id,l_cost_ci_version_id)) ;

  END IF;

  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:='Getting app cost/rev current working version ids';
      pa_debug.write( l_module_name,pa_debug.g_err_stage,3);
  END IF;

  --Call the API that will return the approved cost/rev current working version ids for the project
  IF p_budget_version_id IS NULL THEN

      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Getting app cost/rev current working version ids';
          pa_debug.write( l_module_name,pa_debug.g_err_stage,3);
      END IF;


      pa_fp_control_items_utils.get_app_cw_ver_ids_for_proj
      (p_project_id           => p_project_id,
       x_app_cost_cw_ver_id   => x_app_cost_cw_ver_id,
       x_app_rev_cw_ver_id    => x_app_rev_cw_ver_id,
       x_msg_data             => x_msg_data,
       x_msg_count            => x_msg_count,
       x_return_status        => x_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

          IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Called API pa_fp_control_items_utils.get_app_cw_ver_ids_for_proj  returned error';
              pa_debug.write( l_module_name,pa_debug.g_err_stage,5);
          END IF;

          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      --Get the resource list ids for the approved current working versions
      SELECT pbvc.resource_list_id,
             pbvr.resource_list_id
      INTO   l_targ_resource_list_id1 ,
             l_targ_resource_list_id2
      FROM   pa_budget_versions pbvc,
             pa_budget_versions pbvr
      WHERE  pbvc.budget_version_id=nvl(x_app_cost_cw_ver_id,x_app_rev_cw_ver_id)
      AND    pbvr.budget_version_id=nvl(x_app_rev_cw_ver_id,x_app_cost_cw_ver_id) ;

      --The approved cost/rev current working versions will always be from plan type of plan class code BUDGET
      x_plan_class_code:='BUDGET';

  ELSE

      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Getting the version type for the budget version id passed';
          pa_debug.write( l_module_name,pa_debug.g_err_stage,3);
      END IF;

      --Select the version details of the budget version id passed
      SELECT pbv.version_type,
             pbv.resource_list_id,
             pbv.resource_list_id,
             fin.plan_class_code
      INTO   x_targ_version_type,
             l_targ_resource_list_id1 ,
             l_targ_resource_list_id2,
             x_plan_class_code
      FROM   pa_budget_versions pbv,
             pa_fin_plan_types_b fin
      WHERE  budget_version_id=p_budget_version_id
      AND    fin.fin_plan_type_id=pbv.fin_plan_type_id;


  END IF;

  --Check whether the resource list ids of the CI version and target version are same or not
  --Bug 3977032. Changed the logic for deriving x_show_resources_flag. Please see comments below
  --The name "x_show_resources_flag" is misleading. Based on this "%change to budget" will either be shown or
  --hidden. The name has to be changed
  x_show_resources_flag:='Y';
  IF  p_budget_version_id IS NULL THEN
  --Impact should be compared with Approved Current Working versions of project

      --The below IF checks for the existence of impact and then it compares the resource list of the CI version
      --with the corresponding approved CW version.
      IF (l_cost_ci_version_id IS NOT NULL AND l_targ_resource_list_id1 <> l_ci_resource_list_id1) OR
         (l_rev_ci_version_id  IS NOT NULL AND l_targ_resource_list_id2 <> l_ci_resource_list_id2) OR
         (l_all_ci_version_id  IS NOT NULL AND l_targ_resource_list_id1 <> l_ci_resource_list_id1) THEN

          x_show_resources_flag:='N';

      END IF;

  ELSIF   p_budget_version_id IS NOT NULL THEN

      --The below IF checks for the version type of the budget version in the context of which View financial
      --impact page is rendered and then based on the version type it compares the resource list of the buget version
      --and the correspondig impact
      --In the case of an ALL version, details from both cost /revenue impacts have to be shown. Hence its
      --resource list should be equal to the resource lists in both cost/rev ci versions. Note:This is not
      --required in the above If block since if the ci is of type ALL then the approved CW version should also
      --be of type ALL
      IF (x_targ_version_type = 'COST'    AND l_targ_resource_list_id1  <> l_ci_resource_list_id1)   OR
         (x_targ_version_type = 'REVENUE' AND l_targ_resource_list_id2  <> l_ci_resource_list_id2)   OR
         (x_targ_version_type = 'ALL'     AND (l_targ_resource_list_id1 <> l_ci_resource_list_id1    OR
                                               l_targ_resource_list_id2 <> l_ci_resource_list_id2)) THEN

          x_show_resources_flag:='N';

      END IF;

  END IF;

  --x_cost_impl_into_app_cw_ver should be Y if the change doc has got implemented into app_cw_ver
  --x_rev_impl_into_app_cw_ver should be Y if the change doc has got implemented into app_cw_ver
  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:='Deriving x_cost_impl_into_app_cw_ver and x_rev_impl_into_app_cw_ver';
      pa_debug.write( l_module_name,pa_debug.g_err_stage,3);
  END IF;

  IF  NVL(l_cost_ci_version_id,l_all_ci_version_id) IS NOT NULL THEN

      OPEN c_ci_merge_csr('COST',NVL(l_cost_ci_version_id,l_all_ci_version_id),nvl(p_budget_version_id,x_app_cost_cw_ver_id));
      FETCH c_ci_merge_csr INTO l_dummy;

      IF c_ci_merge_csr%NOTFOUND THEN

          x_cost_impl_into_app_cw_ver:='N';

      ELSE

          x_cost_impl_into_app_cw_ver:='Y';

      END IF;

      CLOSE c_ci_merge_csr;

  END IF;

  IF  NVL(l_rev_ci_version_id,l_all_ci_version_id) IS NOT NULL THEN

      OPEN c_ci_merge_csr('REVENUE',NVL(l_rev_ci_version_id,l_all_ci_version_id),nvl(p_budget_version_id,x_app_rev_cw_ver_id));
      FETCH c_ci_merge_csr INTO l_dummy;

      IF c_ci_merge_csr%NOTFOUND THEN

          x_rev_impl_into_app_cw_ver:='N';

      ELSE

          x_rev_impl_into_app_cw_ver:='Y';

      END IF;

      CLOSE c_ci_merge_csr;

  END IF;

  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:='x_cost_impl_into_app_cw_ver is '||x_cost_impl_into_app_cw_ver;
      pa_debug.write( l_module_name,pa_debug.g_err_stage,3);

      pa_debug.g_err_stage:='x_rev_impl_into_app_cw_ver is '||x_rev_impl_into_app_cw_ver;
      pa_debug.write( l_module_name,pa_debug.g_err_stage,3);

  END IF;

  --For bug 3957561

  SELECT ci.ci_number,ct.name
  INTO x_ci_number,x_ci_type
  FROM pa_control_items ci,pa_ci_types_vl ct
  WHERE ci_id=p_ci_id
  AND ci.ci_type_id=ct.ci_type_id;

  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:='x_ci_number is '||x_ci_number;
      pa_debug.write( l_module_name,pa_debug.g_err_stage,3);

      pa_debug.g_err_stage:='x_ci_type is '||x_ci_type;
      pa_debug.write( l_module_name,pa_debug.g_err_stage,3);

  END IF;

  --End of bug 3957561

  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:='Exiting get_dtls_for_view_fin_imp_pg';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
  END IF;

  pa_debug.reset_curr_function;

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
         pa_debug.reset_curr_function;

  WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'PAFPCIUB'
                            ,p_procedure_name  => 'get_dtls_for_view_fin_imp_pg');

      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
      END IF;

      pa_debug.reset_curr_function;
      RAISE;

END get_dtls_for_view_fin_imp_pg;

--This procedure will return the approved cost/rev current working version ids for a project.
--If there is only one version which is approved for both cost and revenue and then same version id will be
--populated in both x_app_cost_cw_ver_id and x_app_rev_cw_ver_id
--If the current working versions do not exist then null will be returned
PROCEDURE get_app_cw_ver_ids_for_proj
(p_project_id                   IN     pa_projects_all.project_id%TYPE,
x_app_cost_cw_ver_id           OUT    NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
x_app_rev_cw_ver_id            OUT    NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
x_msg_data                     OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
x_msg_count                    OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
x_return_status                OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
  --Start of variables used for debugging
  l_msg_count          NUMBER :=0;
  l_data               VARCHAR2(2000);
  l_msg_data           VARCHAR2(2000);
  l_error_msg_code     VARCHAR2(30);
  l_msg_index_out      NUMBER;
  l_return_status      VARCHAR2(2000);
  l_debug_mode         VARCHAR2(30);
  l_module_name        VARCHAR2(100) := 'PAFPCIUB.get_app_cw_ver_ids_for_proj' ;
  --End of variables used for debugging

  CURSOR c_app_cw_ver_csr
  IS
  SELECT budget_version_id,
         approved_cost_plan_type_flag,
         approved_rev_plan_type_flag
  FROM   pa_budget_versions pbv
  WHERE  pbv.project_id=p_project_id
  AND    pbv.ci_id IS NULL
  AND    pbv.fin_plan_type_id IS NOT NULL
  AND    nvl(pbv.wp_version_flag,'N')='N'
  AND    (pbv.approved_cost_plan_type_flag = 'Y' OR
          pbv.approved_rev_plan_type_flag = 'Y' )
  AND    pbv.current_working_flag = 'Y';

  l_app_cw_ver_rec       c_app_cw_ver_csr%ROWTYPE;

BEGIN
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
  l_debug_mode := NVL(l_debug_mode, 'Y');
  x_msg_count := 0;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  PA_DEBUG.Set_Curr_Function( p_function   => l_module_name,
                              p_debug_mode => l_debug_mode );

  IF p_project_id IS NULL THEN

      IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:= 'Passed project id is '||p_project_id;
         pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

      END IF;

      PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                          p_msg_name        => 'PA_FP_INV_PARAM_PASSED',
                          p_token1          => 'PROCEDURENAME',
                          p_value1          => l_module_name);

      RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

  END IF;

  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:='About to derive the CW ver ids';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
  END IF;

  x_app_cost_cw_ver_id:=NULL;
  x_app_cost_cw_ver_id:=NULL;
  OPEN c_app_cw_ver_csr;
  LOOP
      FETCH c_app_cw_ver_csr INTO l_app_cw_ver_rec;
      EXIT WHEN c_app_cw_ver_csr%NOTFOUND;
      IF l_app_cw_ver_rec.approved_cost_plan_type_flag ='Y' THEN

          x_app_cost_cw_ver_id:=l_app_cw_ver_rec.budget_version_id;

      END IF;

      IF l_app_cw_ver_rec.approved_rev_plan_type_flag ='Y' THEN

          x_app_rev_cw_ver_id:=l_app_cw_ver_rec.budget_version_id;

      END IF;

  END LOOP;

  CLOSE c_app_cw_ver_csr; -- Added for bug#6405905


  IF l_debug_mode = 'Y' THEN

      pa_debug.g_err_stage:='Derived x_app_cost_cw_ver_id is '||x_app_cost_cw_ver_id ||' x_app_rev_cw_ver_id  is '||x_app_rev_cw_ver_id;
      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

      pa_debug.g_err_stage:='Exiting get_app_cw_ver_ids_for_proj';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
  END IF;

  pa_debug.reset_curr_function;

EXCEPTION

   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

CLOSE c_app_cw_ver_csr; -- Added for bug#6405905

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
         pa_debug.reset_curr_function;

   WHEN OTHERS THEN

   CLOSE c_app_cw_ver_csr; -- Added for bug#6405905 by vvjoshi

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PAFPCIUB'
                                ,p_procedure_name  => 'get_app_cw_ver_ids_for_proj');

         IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
         END IF;
        pa_debug.reset_curr_function;
        RAISE;

END get_app_cw_ver_ids_for_proj;

/* Bug 3731948- New Function to return the CO amount already implemented
 * for REVENUE implementation in agreement currency
 */
FUNCTION get_impl_agr_revenue (p_project_id   IN     pa_projects_all.project_id%TYPE,
                               p_ci_id        IN     pa_fp_merged_ctrl_items.ci_id%TYPE)
RETURN NUMBER
IS
      l_impl_agr_rev_amt     NUMBER := 0;
      l_cw_bv_id             NUMBER;
      l_ci_rev_version_id    NUMBER;
      l_debug_mode           VARCHAR2(30);
      l_module_name          VARCHAR2(30) := 'get_impl_agr_revenue';

      l_msg_count            NUMBER := 0;
      l_data                 VARCHAR2(2000);
      l_msg_data             VARCHAR2(2000);
      l_msg_index_out        NUMBER;



BEGIN
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

      IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='get_impl_agr_revenue - pa_fp_control_items_utils ';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;
      PA_DEBUG.Set_Curr_Function( p_function   => l_module_name,
                                  p_debug_mode => l_debug_mode );

      -- Throwing error if the inputs are Null
      IF p_project_id IS NULL OR
         p_ci_id      IS NULL THEN
            IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='Input p_project_id/p_ci_id is NULL';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;
            pa_debug.reset_curr_function;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      BEGIN
           -- Selecting budget_version_id for the Rev CI version
           SELECT    budget_version_id
           INTO      l_ci_rev_version_id
           FROM      pa_budget_versions
           WHERE     project_id = p_project_id
           AND       ci_id = p_ci_id
           AND       Nvl(approved_rev_plan_type_flag, 'N')= 'Y'
           AND       version_type IN ('REVENUE','ALL');

           -- Selecting the budget_version_id of the target current working version
           SELECT    budget_version_id
           INTO      l_cw_bv_id
           FROM      pa_budget_versions
           WHERE     project_id = p_project_id
           AND       Nvl(approved_rev_plan_type_flag, 'N')= 'Y'
           AND       Nvl(current_working_flag, 'N') = 'Y';

      EXCEPTION
           WHEN NO_DATA_FOUND THEN
                IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:='No Rev Current Working Version Exists';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                END IF;
                pa_debug.reset_curr_function;

                RETURN l_impl_agr_rev_amt;

           WHEN OTHERS THEN
                IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
                     pa_debug.write(l_module_name || g_module_name,pa_debug.g_err_stage,5);
                END IF;
                pa_debug.reset_curr_function;
                RAISE;
      END;
      IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Rev Current Working version id: ' || l_cw_bv_id;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      BEGIN
           -- Selecting the revenue amount implemeted in agreement currency
           SELECT    Nvl(impl_agr_revenue,0)
           INTO      l_impl_agr_rev_amt
           FROM      pa_fp_merged_ctrl_items
           WHERE     project_id = p_project_id
           AND       ci_id = p_ci_id
           AND       plan_version_id = l_cw_bv_id
           AND       ci_plan_version_id = l_ci_rev_version_id
           AND       version_type = 'REVENUE';

      EXCEPTION
           WHEN NO_DATA_FOUND THEN
                IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:='No Rev Current Working Version Exists';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                END IF;
                pa_debug.reset_curr_function;

                RETURN l_impl_agr_rev_amt;
           WHEN OTHERS THEN
                IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
                     pa_debug.write(l_module_name || g_module_name,pa_debug.g_err_stage,5);
                END IF;
                pa_debug.reset_curr_function;
                RAISE;
      END;

      IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Agr Revenue Amount: ' || l_impl_agr_rev_amt;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      pa_debug.reset_curr_function;

      RETURN l_impl_agr_rev_amt;

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
           END IF;
           pa_debug.reset_curr_function;

   WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PAFPCIUB'
                                ,p_procedure_name  => 'get_app_cw_ver_ids_for_proj');

         IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
         END IF;
        pa_debug.reset_curr_function;
        RAISE;
END get_impl_agr_revenue;

/*Function added for EnC */

	 FUNCTION is_edit_plan_enabled(p_ci_id     IN       pa_ci_impacts.ci_id%TYPE)
 	 RETURN   VARCHAR2
 	 IS
 	      l_is_editplanned_enabled varchar2(1) := 'N';
 	 BEGIN
 	      SELECT 'Y'
 	      INTO l_is_editplanned_enabled
 	      FROM DUAL
 	      WHERE EXISTS (SELECT 1
 	                    FROM PA_CI_TYPES_V
 	                    WHERE CI_TYPE_ID = (SELECT CI_TYPE_ID FROM PA_CONTROL_ITEMS WHERE CI_ID = p_ci_id)
 	                                    AND IMPACT_BUDGET_TYPE_CODE = 'EDIT_PLANNED_AMOUNTS'
 	                      );/* Changed the Query for E&C 12.1.3 */

 	      RETURN l_is_editplanned_enabled;

 	 EXCEPTION
 	      WHEN NO_DATA_FOUND THEN
 	           RETURN 'N';

 	 END is_edit_plan_enabled;

/* Function returns 'Y' if the change order has been implemented/included into ANY budget version. */
FUNCTION has_co_been_merged(p_ci_id     IN       pa_ci_impacts.ci_id%TYPE)
RETURN   VARCHAR2
IS
     l_is_merged varchar2(1) := 'N';
BEGIN
     SELECT 'Y'
     INTO l_is_merged
     FROM DUAL
     WHERE EXISTS (SELECT 1
                   FROM PA_FP_MERGED_CTRL_ITEMS
                   WHERE CI_ID = p_ci_id);

     RETURN l_is_merged;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RETURN 'N';

END has_co_been_merged;

/* This API returns the txn_currency_code and the ci version id of the budget lines of a REVENUE or ALL ci version, if lines exist. Else it returns NULL
   All the lines of a revenue change order version will be in a single currency
*/
PROCEDURE get_txn_curr_code_of_ci_ver(
           p_project_id           IN   pa_projects_all.project_id%TYPE
           ,p_ci_id               IN   pa_budget_versions.ci_id%TYPE
           ,x_txn_currency_code   OUT  NOCOPY pa_budget_lines.txn_currency_code%TYPE --File.Sql.39 bug 4440895
           ,x_budget_version_id   OUT  NOCOPY pa_budget_versions.budget_version_id%TYPE --File.Sql.39 bug 4440895
           ,x_msg_data            OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count           OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_return_status       OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

l_msg_count            NUMBER := 0;
l_data                 VARCHAR2(2000);
l_msg_data             VARCHAR2(2000);
l_msg_index_out        NUMBER;

BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Set curr function
    pa_debug.set_curr_function(
           p_function   =>'PAFPCIUB.get_txn_curr_code_of_ci_ver'
          ,p_debug_mode => P_PA_DEBUG_MODE );

    -- Validate input parameters
    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='Validating input parameters';
        pa_debug.write('get_txn_curr_code_of_ci_ver: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;


    IF (p_project_id IS NULL) OR (p_ci_id IS NULL)
    THEN

        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='p_project_id = '||p_project_id;
           pa_debug.write('get_txn_curr_code_of_ci_ver: ' || g_module_name,pa_debug.g_err_stage,5);

           pa_debug.g_err_stage:='p_ci_id = '||p_ci_id;
           pa_debug.write('get_txn_curr_code_of_ci_ver: ' || g_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                              p_token1         => 'PROCEDURENAME',
                              p_value1         => 'PAFPCIUB.get_txn_curr_code_of_ci_ver');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;


    -- Check if budget line exists for any of the budget versions of the project-plan type
      Begin

             SELECT rac.txn_currency_code,
                    rac.budget_version_id
             INTO x_txn_currency_code,
                  x_budget_version_id
             FROM   pa_resource_asgn_curr rac,
                    pa_budget_versions bv
             WHERE  bv.project_id = p_project_id
             AND    bv.ci_id = p_ci_id
             AND    bv.version_type IN ('REVENUE','ALL')
             AND    rac.budget_version_id = bv.budget_version_id
             AND    rownum=1;

              -- reset curr function
             pa_debug.reset_curr_function();

    Exception
       When no_data_found Then
           -- reset curr function
           pa_debug.reset_curr_function();
    End;

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
         pa_debug.reset_curr_function;
   WHEN Others THEN

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'Pa_Fp_Control_Items_Utils'
                               ,p_procedure_name  => 'get_txn_curr_code_of_ci_ver');

       IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write('get_txn_curr_code_of_ci_ver: ' || g_module_name,pa_debug.g_err_stage,5);
       END IF;

       -- reset curr function
       pa_debug.Reset_Curr_Function();

       RAISE;

END get_txn_curr_code_of_ci_ver;

/* Bug 3927208: DBORA- The following function is to be used by Control Item team, before
 * deleting any CI type from the system, to check if the ci type is being used
 * in any financial plan type context to define implementation/inclusion statuses
 * for financial impact implementation
 */
 FUNCTION validate_fp_ci_type_delete (p_ci_type_id    IN       pa_ci_types_b.ci_type_id%TYPE)
 RETURN VARCHAR2
 IS
      l_debug_mode           VARCHAR2(30);
      l_module_name          VARCHAR2(30) := 'validate_fp_ci_type_delete';
      l_msg_count            NUMBER := 0;
      l_data                 VARCHAR2(2000);
      l_msg_data             VARCHAR2(2000);
      l_msg_index_out        NUMBER;

      is_delete_allowed      VARCHAR2(1) := 'Y';

 BEGIN
       fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

       IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='validate_fp_ci_type_delete - pa_fp_control_items_utils ';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
       END IF;
       PA_DEBUG.Set_Curr_Function( p_function   => l_module_name,
                                  p_debug_mode => l_debug_mode );

       IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Entering validate_fp_ci_type_delete';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
       END IF;

       IF p_ci_type_id IS NULL THEN
            IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='Input p_ci_type_id is NULL';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;
            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                                  p_token1         => 'PROCEDURENAME',
                                  p_value1         => 'PAFPCIUB.validate_fp_ci_type_delete');
            pa_debug.reset_curr_function;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Checkin if delete allowed';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      BEGIN
            SELECT 'N'
            INTO   is_delete_allowed
            FROM DUAL
            WHERE EXISTS (SELECT 'X'
                          FROM   pa_pt_co_impl_statuses
                          WHERE  ci_type_id = p_ci_type_id);
      EXCEPTION
           WHEN NO_DATA_FOUND THEN
                 RETURN is_delete_allowed;
      END;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Check completed';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            pa_debug.g_err_stage:='Value returned: ' || is_delete_allowed;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            pa_debug.g_err_stage:='Leaving validate_fp_ci_type_delete';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      pa_debug.reset_curr_function;

      RETURN is_delete_allowed;

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
             END IF;
             pa_debug.reset_curr_function;
      WHEN OTHERS THEN
           FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PAFPCIUB'
                                   ,p_procedure_name  => 'validate_fp_ci_type_delete');

           IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
           END IF;
           pa_debug.reset_curr_function;
           RAISE;
 END validate_fp_ci_type_delete;

-- Bug 5845142. This function will be used to check if inclusion of change orders is possible into
-- unapproved budgets. It will return N only when the approved cost plan type (approved only for cost
-- but not for revenue) is setup as "Cost and Revenue" Together. In other cases it will return Y
-- indicating that the change orders can be included into unapproved budgets
FUNCTION check_valid_combo
(p_project_id                 IN  NUMBER,
 p_targ_app_cost_flag         IN  VARCHAR2,
 p_targ_app_rev_flag          IN  VARCHAR2)
RETURN VARCHAR2 IS
  --Bug 5845142
  l_app_cost_pt_rev_flag             pa_proj_fp_options.approved_cost_plan_type_flag%TYPE;
  l_app_cost_pt_pref_code            pa_proj_fp_options.fin_plan_preference_code%TYPE;
BEGIN

   IF l_cvc_project_id=p_project_id THEN

     l_app_cost_pt_rev_flag  := l_cvc_app_cost_pt_rev_flag;
     l_app_cost_pt_pref_code := l_cvc_app_cost_pt_pref_code;

   ELSE

     BEGIN

       SELECT nvl(pfo.approved_rev_plan_type_flag,'N'),
              nvl(pfo.fin_plan_preference_code,'N')
       INTO   l_app_cost_pt_rev_flag,
              l_app_cost_pt_pref_code
       FROM   pa_proj_fp_options pfo
       WHERE  pfo.project_id = p_project_id
       AND    pfo.fin_plan_version_id IS NULL
       AND    pfo.approved_cost_plan_type_flag ='Y';

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
          l_app_cost_pt_rev_flag := NULL;
          l_app_cost_pt_pref_code := NULL;
     END;

     l_cvc_project_id             :=  p_project_id;
     l_cvc_app_cost_pt_rev_flag   :=  l_app_cost_pt_rev_flag;
     l_cvc_app_cost_pt_pref_code  :=  l_app_cost_pt_pref_code;

   END IF;

   IF l_app_cost_pt_rev_flag='N' AND
      l_app_cost_pt_pref_code='COST_AND_REV_SAME' THEN

     IF p_targ_app_cost_flag  <> 'Y' AND
        p_targ_app_rev_flag <> 'Y' THEN

          RETURN 'N';

     END IF;

   END IF;

   RETURN 'Y';

END check_valid_combo;

END Pa_Fp_Control_Items_Utils;

/
