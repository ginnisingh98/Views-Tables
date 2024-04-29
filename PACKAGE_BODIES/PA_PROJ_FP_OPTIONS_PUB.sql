--------------------------------------------------------
--  DDL for Package Body PA_PROJ_FP_OPTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJ_FP_OPTIONS_PUB" as
/* $Header: PAFPOPPB.pls 120.10.12010000.2 2009/05/25 14:56:33 gboomina ship $ */

l_module_name VARCHAR2(100) := 'pa.plsql.pa_proj_fp_options_pub';
P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

/*==================================================================================================
  CREATE_FP_OPTION: This procedure inserts or updates records in 3 table depending
  on the Source and the Target FP Option Details passed to this procedure.
  -> If the Source and Target are passed, then the Target FP Option is updated with the Source
  details.
     this case if true in following cases
     1. edit plan type. In this case user might change the preference code of the option.
     2. copy from a existing version. All values except approved cost/revenue are to be overriden
     3. While adding plan type to a project.
     4. copy from an existing project.

  -> If the Source is passed and Target not passed, then a new Target FP Option is created based
  on other Source details.
  -> If the Source is not passed and the Target is passed, then Source details are got from the
  Parent (if exists) else Default option details are got using the Target Preference Code. A new
  Target FP Option is created based on the details got.
  -> If the Source and the Target are not passed, then the details of the Parent are got using the
  Option Level Code else Default Option details are got using the Target Preference code.

 BUG:- 2625872 As part of the Upgrade changes, create_fp_option api has been modified to set multi
 currency flag to 'Y' if the project currency isn't equal to project functional currency.

 Bug:- 2920954 calls to insert/update table handlers have been chnaged to include new columns.

--    26-JUN-2003 jwhite        - Plannable Task HQ Dev Effort:
--                                Make code changes to Create_FP_Option procedure to
--                                enable population of new parameters on
--                                PA_PROJ_FP_OPTIONS_PKG.Insert_Row table handler.

--
  r11.5 FP.M Developement ----------------------------------

  08-JAN-2004 jwhite     Bug 3362316  (HQ)
                         Rewrote Create_Fp_Option.
                           - FP_COL Record specifiation definition
                           - PA_PROJ_FP_OPTIONS_PKG.update_row parm list
                           - PA_PROJ_FP_OPTIONS_PKG.insert_row parm list

 3/30/2004 Raja FP M Dev Effort Copy Project Impact:
   When versions are being copied across projects genration source plan versions
   can not be copied as they are. So, all gen source version id columns would be null

 4/16/2004 Raja FP M Phase II Dev Effort Copy Plan:
   When user chooses 'copy version amounts' from one version to another version, do not copy
   "rate schedules" and "generation options" sub tabs related data.

==================================================================================================*/

PROCEDURE Create_FP_Option (
          px_target_proj_fp_option_id             IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,p_source_proj_fp_option_id             IN NUMBER
          ,p_target_fp_option_level_code          IN VARCHAR2
          ,p_target_fp_preference_code            IN VARCHAR2
          ,p_target_fin_plan_version_id           IN NUMBER
          ,p_target_project_id                    IN NUMBER
          ,p_target_plan_type_id                  IN NUMBER
          ,x_return_status                       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                            OUT NOCOPY VARCHAR2 ) is --File.Sql.39 bug 4440895

FP_Cols_Rec                 PA_PROJ_FP_OPTIONS_PUB.FP_COLS;
FP_Mc_Cols_Rec              PA_PROJ_FP_OPTIONS_PUB.FP_MC_COLS;
l_par_Proj_FP_Options_id    pa_proj_fp_options.PROJ_FP_OPTIONS_ID%TYPE;
l_source_project_id         pa_proj_fp_options.PROJECT_ID%TYPE;
l_plan_type_id              pa_proj_fp_options.FIN_PLAN_TYPE_ID%TYPE;
l_plan_version_id           pa_proj_fp_options.FIN_PLAN_VERSION_ID%TYPE;
l_target_option_level_code  pa_proj_fp_options.FIN_PLAN_OPTION_LEVEL_CODE%TYPE;
l_source_option_level_code  pa_proj_fp_options.FIN_PLAN_OPTION_LEVEL_CODE%TYPE;
l_fp_preference_code        pa_proj_fp_options.FIN_PLAN_PREFERENCE_CODE%TYPE;
l_copy_project_context      VARCHAR2(1);
/* Variables added for autobase line Bug#2619022*/
l_baseline_funding_flag         pa_projects_all.BASELINE_FUNDING_FLAG%TYPE;
l_approved_rev_plan_type_flag   pa_proj_fp_options.APPROVED_REV_PLAN_TYPE_FLAG%TYPE;
l_source_fp_preference_code     pa_proj_fp_options.FIN_PLAN_PREFERENCE_CODE%TYPE;

/* Bug # 2702000 */
FP_Cols_Rec_Rev_Def         PA_PROJ_FP_OPTIONS_PUB.FP_COLS;

l_debug_mode      VARCHAR2(30);
l_msg_count       NUMBER := 0;
l_data            VARCHAR2(2000);
l_msg_data        VARCHAR2(2000);
l_msg_index_out   NUMBER;
l_return_status   VARCHAR2(2000);
x_row_id          ROWID;
l_stage           NUMBER := 100;

     -- jwhite, 26-JUN-2003: Added for Plannable Task Dev Effort ------------------

     l_refresh_required_flag          VARCHAR2(1)  := NULL;
     l_request_id                     NUMBER(15)   := NULL;
     l_process_code                   VARCHAR2(30) := NULL;

     -- -------------------------------------------------------

-- FP M Dev Effort new variables

l_default_gen_options_rec    PA_PROJ_FP_OPTIONS_PUB.FP_COLS;
l_source_plan_class_code     pa_fin_plan_types_b.plan_class_code%TYPE;

-- 3/30/2004 FP M Phase II Dev Effort

l_gl_start_period            gl_periods.period_name%TYPE;
l_gl_end_period              gl_periods.period_name%TYPE;
l_gl_start_Date              VARCHAR2(100);
l_pa_start_period            pa_periods_all.period_name%TYPE;
l_pa_end_period              pa_periods_all.period_name%TYPE;
l_pa_start_date              VARCHAR2(100);
l_plan_version_exists_flag   VARCHAR2(1);
l_prj_start_date             VARCHAR2(100);
l_prj_end_date               VARCHAR2(100);

--Added for webAdi development
l_source_plan_type_id       pa_proj_fp_options.FIN_PLAN_TYPE_ID%TYPE;
-- begin: Bug 5941436: fnd_profile.value_specific('PA_FP_WEBADI_ENABLE'); has been changed with fnd_profile.value('PA_FP_WEBADI_ENABLE'); to perform less sqls and use caching and therefore to improve the performance
/* Bug 6413612 : Added substr to fetch only 1 character of profile value */
l_webadi_profile VARCHAR(1) := UPPER(SUBSTR(fnd_profile.value_specific('PA_FP_WEBADI_ENABLE'), 1, 1));
-- end Bug 5941436:
-- FP M Dev Effort new cursor defined to fetch plan type information

CURSOR plan_type_info_cur (c_fin_plan_type_id NUMBER) IS
SELECT  plan_class_code
       ,nvl(approved_cost_plan_type_flag,'N')    approved_cost_plan_type_flag
       ,nvl(approved_rev_plan_type_flag,'N')     approved_rev_plan_type_flag
       ,nvl(primary_cost_forecast_flag,'N')      primary_cost_forecast_flag
       ,nvl(primary_rev_forecast_flag,'N')       primary_rev_forecast_flag
       ,nvl(use_for_workplan_flag,'N')           use_for_workplan_flag
FROM   pa_fin_plan_types_b
WHERE  fin_plan_type_id  = c_fin_plan_type_id;


CURSOR opt_info_Cur (c_proj_fp_options_id NUMBER) IS
SELECT
      nvl(approved_rev_plan_type_flag,'N')     approved_rev_plan_type_flag
FROM  pa_proj_fp_options
where proj_fp_options_id = c_proj_fp_options_id;

opt_info_rec       opt_info_Cur%ROWTYPE;
plan_type_info_rec plan_type_info_cur%ROWTYPE;

CURSOR plan_version_info_cur (c_budget_version_id NUMBER) IS
SELECT ci_id
FROM   pa_budget_versions
WHERE  budget_version_id  = c_budget_version_id;

plan_version_info_rec plan_version_info_cur%ROWTYPE;


BEGIN
   FND_MSG_PUB.initialize;
   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.init_err_stack('PA_PROJ_FP_OPTIONS_PUB.Create_FP_Option');
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode :=  NVL(l_debug_mode, 'Y');
      pa_debug.set_process('PLSQL','LOG',l_debug_mode);
   END IF;

   x_msg_count := 0;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_stage := 200;
   IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage := TO_CHAR(l_Stage)||': entered create_fp_option';
           pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
   END IF;

  IF p_target_fp_preference_code IS NOT NULL THEN
     l_fp_preference_code := p_target_fp_preference_code;
  END IF;

   /* Validating for Input parameters to raise error if not passed to the procedure. */
  IF (px_target_proj_fp_option_id IS NULL) THEN
      IF (p_target_fp_option_level_code IS NULL) THEN
            /* Option Level Code should not be NULL when the Target is NULL */
            l_stage := 340;
            IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Err - Option Level Code should not be NULL';
                    pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                 p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      ELSIF (p_target_fp_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE) THEN
          l_stage := 300;
          IF (p_target_plan_type_id IS NULL) THEN
             /* Plan Type ID cannot be NULL when Target Proj FP Option is NULL and Option Level
                Code is PLAN_TYPE */
             IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Err- Plan Type ID cannot be NULL.';
                     pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
             END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
             PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                  p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;
      ELSIF (p_target_fp_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION) THEN
            /* Plan Type ID and Pland Version ID cannot be NULL when the Option Level Code is
               PLAN_VERSION. */
          l_stage := 320;
          IF (p_target_plan_type_id IS NULL) THEN

               IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Err- Plan Type ID cannot be NULL.';
                       pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
               END IF;
               x_return_status := FND_API.G_RET_STS_ERROR;
               PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                    p_msg_name            => 'PA_FP_INV_PARAM_PASSED' );
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          ELSIF (p_target_fin_plan_version_id IS NULL) THEN
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Err- Plan Version ID cannot be NULL.';
                          pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
                  END IF;
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                       p_msg_name            => 'PA_FP_INV_PARAM_PASSED' );
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;
      END IF;

      IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage := TO_CHAR(l_Stage)||': target option id is null. Populating from inputs';
              pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
      END IF;

      /* if target is null then these variables are validated for input values. Hence initialize these */
      l_target_option_level_code := p_target_fp_option_level_code;
      l_plan_type_id      := p_target_plan_type_id;
      l_plan_version_id   := p_target_fin_plan_version_id;
  ELSE /* M22-AUG: if target is not null get values from target */
       /* If the Target Project Option ID is not NULL, then get the Plan_Type_ID
          and other columns from the database for this Proj FP Option ID so that even if
          NULL values are passed in the parameters, the database values retrieved are passed
          to the Table Handlers PA_PROJ_FP_OPTIONS_PKG.update_row and insert_row.         */

       IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage := TO_CHAR(l_Stage)||': target option id is not null. Populating from target';
               pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
       END IF;

       SELECT fin_plan_type_id, fin_plan_version_id, fin_plan_option_level_code,
             nvl(l_fp_preference_code, fin_plan_preference_code) /* get only if l_fp_preference_code is not null */
        INTO l_plan_type_id, l_plan_version_id, l_target_option_level_code,
             l_fp_preference_code
        FROM pa_proj_fp_options
       WHERE proj_fp_options_id = px_target_proj_fp_option_id;

  END IF;

   /* validate and populate l_fp_preference_code */
  IF (p_source_proj_fp_option_id IS NULL) THEN
      /* The control would come to this point when the Source FP Option is NULL. Since the Source is NULL,
         a new record needs to be inserted into Proj FP Options based on the Target_FP_Pref_Code. Hence
         Target_FP_Pref_Code should be NOT NULL for this case. */
      l_stage := 360;

      IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage := TO_CHAR(l_Stage)||': source option id is null';
              pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
      END IF;
      IF (l_fp_preference_code is NULL) THEN   /* by this time if l_fp_preference_code is not null then its error */
            IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Err - FP Preference Code should not be NULL';
                    pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                 p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;
  ELSE
      /* get this from source option. As the validation is already done source cannot be null
         at this point */

         IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.g_err_stage := TO_CHAR(l_Stage)||': source option id is NOT null. Getting preference code';
                 pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
         END IF;
         /* Selected l_source_fp_preference_code for Bug 3149010 */

         SELECT nvl(l_fp_preference_code,fin_plan_preference_code),
                fin_plan_preference_code,
                fin_plan_option_level_code,
                project_id,
                pt.plan_class_code,
                pfo.fin_plan_type_id
           INTO l_fp_preference_code,
                l_source_fp_preference_code,
                l_source_option_level_code,
                l_source_project_id,
                l_source_plan_class_code,
                l_source_plan_type_id  -- Added this to get the source plan type id for copying the amount types
          FROM  pa_proj_fp_options pfo,
                pa_fin_plan_types_b pt
          WHERE pfo.proj_fp_options_id = p_source_proj_fp_option_id
            AND pfo.fin_plan_type_id = pt.fin_plan_type_id(+);

  END IF;

   l_stage := 400;
   IF (p_target_project_id IS NULL) THEN
            IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Err- Project ID cannot be NULL.';
                    pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                 p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
   END IF;

   IF (l_plan_type_id IS NOT NULL) THEN

       -- Open and fetch plan type info cur into rec
       OPEN  plan_type_info_cur(l_plan_type_id);
       FETCH plan_type_info_cur INTO plan_type_info_rec;
       CLOSE plan_type_info_cur;

   END IF;


   IF (p_source_proj_fp_option_id IS NOT NULL) THEN

      IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage := TO_CHAR(l_Stage)||': source option id is NOT null. Getting fp_cols from source';
              pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
      END IF;
      get_fp_options(p_proj_fp_options_id        => p_source_proj_fp_option_id
                     ,p_target_fp_options_id     => px_target_proj_fp_option_id /* Bug 3144283 */
                     ,p_fin_plan_preference_code => l_fp_preference_code
                     ,p_target_fp_option_level_code => l_target_option_level_code
                     ,x_fp_cols_rec              => fp_cols_rec
                     ,x_return_status            => x_return_status
                     ,x_msg_count                => x_msg_count
                     ,x_msg_data                 => x_msg_data);

     /* Added the following check for the NOCOPY changes. */

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;
   /* populate fp_cols_rec */
   ELSIF (p_target_fp_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE) AND
      (p_target_plan_type_id IS NOT NULL) AND
      (plan_type_info_rec.use_for_workplan_flag = 'Y')
   THEN
         -- Control comes here if workplan plan type is being added for the project
         -- Values should not be defaulted from project level option

         FP_Cols_Rec := get_default_fp_options(l_fp_preference_code,p_target_project_id,p_target_plan_type_id);

   ELSE
       IF px_target_proj_fp_option_id IS NOT NULL THEN
          IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.g_err_stage := TO_CHAR(l_Stage)||': target is not null and source is null. Get parent of target';
                  pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
          END IF;
          l_par_Proj_FP_Options_ID := get_parent_fp_option_id(px_target_proj_fp_option_id);
       ELSE
          IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Target is null so Get higher level option';
                  pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
          END IF;

          IF (l_target_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE) THEN

               IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.g_err_stage := TO_CHAR(l_Stage)||': getting project level option';
                       pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
               END IF;

               l_par_Proj_FP_Options_ID := get_fp_option_id(p_target_project_id, NULL,NULL);
          ELSIF (l_target_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION) THEN
               IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.g_err_stage := TO_CHAR(l_Stage)||': getting plan type level option';
                       pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
               END IF;

               l_par_Proj_FP_Options_ID := get_fp_option_id(p_target_project_id
                                                           ,l_plan_type_id
                                                           ,NULL);
          END IF;
       END IF;

       /* Bug# 2619022 changes done for autobaseline. Only at the plan type level option
          the defaulting of time phasing , resource list and time phasing needs to be
      done based upon autobaseline rules.
       */
       l_baseline_funding_flag := NULL;
       l_approved_rev_plan_type_flag := NULL;

       IF p_target_project_id IS NOT NULL AND p_target_plan_type_id IS NOT NULL
          AND p_target_fin_plan_version_id IS NULL
       THEN

              SELECT NVL(baseline_funding_flag,'N')
                    ,NVL(approved_rev_plan_type_flag,'N')
                INTO l_baseline_funding_flag
                    ,l_approved_rev_plan_type_flag
                FROM pa_projects_all ppa
                    ,pa_fin_plan_types_b ptb
               WHERE ppa.project_id = p_target_project_id
                 AND ptb.fin_plan_type_id = p_target_plan_type_id;

       END IF;

       IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage := 'Autobaseline flag : '||l_baseline_funding_flag||' Approved Rev flag '||l_approved_rev_plan_type_flag;
               pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

       /* Bug#2619022 changes done for autobaseline.
          In case autobaselining is enabled and approv reve plan type flag is 'Y' then
      get the default values as per the autobaseline business rules.
       */

       /* Bug 2702000 - This case is taken care in the condition when
          l_par_Proj_FP_Options_ID IS NOT NULL
       */
/*     IF l_baseline_funding_flag = 'Y' AND l_approved_rev_plan_type_flag = 'Y' THEN

        IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.g_err_stage := 'inside baseline funding flag and approv rev flag Y';
                        pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

               FP_Cols_Rec := get_default_fp_options(l_fp_preference_code,
                                           p_target_project_id,
                                           p_target_plan_type_id);

       ELSIF (l_par_Proj_FP_Options_ID IS NOT NULL) THEN*/
       IF (l_par_Proj_FP_Options_ID IS NOT NULL) THEN
           IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.g_err_stage := TO_CHAR(l_Stage)||': getting options for l_par_Proj_FP_Options_ID =  ' || l_par_Proj_FP_Options_ID;
                   pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
           END IF;

           get_fp_options(p_proj_fp_options_id        => l_par_Proj_FP_Options_ID
                          ,p_target_fp_options_id     => px_target_proj_fp_option_id /* Bug 3144283 */
                          ,p_fin_plan_preference_code => l_fp_preference_code
                          ,p_target_fp_option_level_code => l_target_option_level_code
                          ,x_fp_cols_rec              => fp_cols_rec
                          ,x_return_status            => x_return_status
                          ,x_msg_count                => x_msg_count
                          ,x_msg_data                 => x_msg_data);

           /* Added the following check for the NOCOPY changes. */

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;

           /* Bug # 2702000 */
           IF l_baseline_funding_flag = 'Y' AND l_approved_rev_plan_type_flag = 'Y' THEN

               IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.g_err_stage := 'inside baseline funding flag and approv rev flag Y';
                   pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,3);
               END IF;

               FP_Cols_Rec_Rev_Def := get_default_fp_options(l_fp_preference_code,
                                                             p_target_project_id,
                                                             p_target_plan_type_id);

               FP_Cols_Rec.Revenue_Fin_Plan_Level_Code := FP_Cols_Rec_Rev_Def.Revenue_Fin_Plan_Level_Code;
               FP_Cols_Rec.Revenue_Time_Phased_Code    := FP_Cols_Rec_Rev_Def.Revenue_Time_Phased_Code;
               FP_Cols_Rec.Revenue_Resource_List_ID    := FP_Cols_Rec_Rev_Def.Revenue_Resource_List_ID;

                -- Bug 2959307 , when auto baseline is enabled, auto resource selection property should be disabled

                FP_Cols_Rec.select_rev_res_auto_flag    := 'N';
                FP_Cols_Rec.revenue_res_planning_level  := null;

               -- Copy revenue options from FP_Cols_Rec_Rev_Def into FP_Cols_Rec.
        END IF;

       ELSE
           IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.g_err_stage := TO_CHAR(l_Stage)||': could not find parent hence getting default options ';
                   pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
                   pa_debug.g_err_stage := 'Preference Code is - '||l_fp_preference_code;
                   pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
           END IF;

           FP_Cols_Rec := get_default_fp_options(l_fp_preference_code,p_target_project_id,p_target_plan_type_id);
       END IF;

   END IF;

   -- FP M Dev effort amount generation columns should be handled based on source option and target option
   -- if source is project and target is plan type, generation columns should be initialized with default values
   -- if target is ci version and source is version, genearation columns should be nulled out
   -- if target is version and source is version, take care that gen src version id for target version is
   -- not same as the target version if so null out the column (this could happen through copy_plan api)

   IF (l_target_option_level_code <> PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PROJECT)  AND
       (nvl(plan_type_info_rec.use_for_workplan_flag,'N') <> 'Y')
   THEN

      -- Fetch source option level code if null using parent option

      IF l_source_option_level_code IS NULL THEN

         IF l_par_proj_fp_options_id IS NOT NULL THEN

             BEGIN
                 SELECT fin_plan_preference_code,
                        fin_plan_option_level_code,
                        pt.plan_class_code
                   INTO l_source_fp_preference_code,
                        l_source_option_level_code,
                        l_source_plan_class_code
                  FROM  pa_proj_fp_options  pfo,
                        pa_fin_plan_types_b pt
                  WHERE pfo.proj_fp_options_id = l_par_proj_fp_options_id
                    AND pfo.fin_plan_type_id = pt.fin_plan_type_id(+);
             EXCEPTION
             WHEN NO_DATA_FOUND THEN
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.g_err_stage := 'No data found for parent option in pa_proj_fp_optins when trying to get def gen vals';
                   pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
                END IF;
                RAISE;
             END;

         END IF;

      END IF;

      -- Target option plan type context
      IF l_target_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE THEN

          -- If source option is project
          IF l_source_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PROJECT THEN

               IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.g_err_stage := 'inside target plan type and source project case if';
                   pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
               END IF;

               -- Initialize amount generation columns with default values
               l_default_gen_options_rec := get_default_fp_options(l_fp_preference_code,p_target_project_id,p_target_plan_type_id);

               FP_Cols_Rec.gen_cost_src_code                 := l_default_gen_options_rec.gen_cost_src_code               ;
               FP_Cols_Rec.gen_cost_etc_src_code             := l_default_gen_options_rec.gen_cost_etc_src_code           ;
               FP_Cols_Rec.gen_cost_incl_change_doc_flag     := l_default_gen_options_rec.gen_cost_incl_change_doc_flag   ;
               FP_Cols_Rec.gen_cost_incl_open_comm_flag      := l_default_gen_options_rec.gen_cost_incl_open_comm_flag    ;
               FP_Cols_Rec.gen_cost_ret_manual_line_flag     := l_default_gen_options_rec.gen_cost_ret_manual_line_flag   ;
               FP_Cols_Rec.gen_cost_incl_unspent_amt_flag    := l_default_gen_options_rec.gen_cost_incl_unspent_amt_flag  ;
               FP_Cols_Rec.gen_rev_src_code                  := l_default_gen_options_rec.gen_rev_src_code                ;
               FP_Cols_Rec.gen_rev_etc_src_code              := l_default_gen_options_rec.gen_rev_etc_src_code            ;
               FP_Cols_Rec.gen_rev_incl_change_doc_flag      := l_default_gen_options_rec.gen_rev_incl_change_doc_flag    ;
               FP_Cols_Rec.gen_rev_incl_bill_event_flag      := l_default_gen_options_rec.gen_rev_incl_bill_event_flag    ;
               FP_Cols_Rec.gen_rev_ret_manual_line_flag      := l_default_gen_options_rec.gen_rev_ret_manual_line_flag    ;
               /*** Bug 3580727
               FP_Cols_Rec.gen_rev_incl_unspent_amt_flag     := l_default_gen_options_rec.gen_rev_incl_unspent_amt_flag   ;
               ***/
               FP_Cols_Rec.gen_src_cost_plan_type_id         := l_default_gen_options_rec.gen_src_cost_plan_type_id       ;
               FP_Cols_Rec.gen_src_cost_plan_version_id      := l_default_gen_options_rec.gen_src_cost_plan_version_id    ;
               FP_Cols_Rec.gen_src_cost_plan_ver_code        := l_default_gen_options_rec.gen_src_cost_plan_ver_code      ;
               FP_Cols_Rec.gen_src_rev_plan_type_id          := l_default_gen_options_rec.gen_src_rev_plan_type_id        ;
               FP_Cols_Rec.gen_src_rev_plan_version_id       := l_default_gen_options_rec.gen_src_rev_plan_version_id     ;
               FP_Cols_Rec.gen_src_rev_plan_ver_code         := l_default_gen_options_rec.gen_src_rev_plan_ver_code       ;
               FP_Cols_Rec.gen_src_all_plan_type_id          := l_default_gen_options_rec.gen_src_all_plan_type_id        ;
               FP_Cols_Rec.gen_src_all_plan_version_id       := l_default_gen_options_rec.gen_src_all_plan_version_id     ;
               FP_Cols_Rec.gen_src_all_plan_ver_code         := l_default_gen_options_rec.gen_src_all_plan_ver_code       ;
               FP_Cols_Rec.gen_all_src_code                  := l_default_gen_options_rec.gen_all_src_code                ;
               FP_Cols_Rec.gen_all_etc_src_code              := l_default_gen_options_rec.gen_all_etc_src_code            ;
               FP_Cols_Rec.gen_all_incl_change_doc_flag      := l_default_gen_options_rec.gen_all_incl_change_doc_flag    ;
               FP_Cols_Rec.gen_all_incl_open_comm_flag       := l_default_gen_options_rec.gen_all_incl_open_comm_flag     ;
               FP_Cols_Rec.gen_all_ret_manual_line_flag      := l_default_gen_options_rec.gen_all_ret_manual_line_flag    ;
               FP_Cols_Rec.gen_all_incl_bill_event_flag      := l_default_gen_options_rec.gen_all_incl_bill_event_flag    ;
               FP_Cols_Rec.gen_all_incl_unspent_amt_flag     := l_default_gen_options_rec.gen_all_incl_unspent_amt_flag   ;
               FP_Cols_Rec.gen_cost_actual_amts_thru_code    := l_default_gen_options_rec.gen_cost_actual_amts_thru_code  ;
               FP_Cols_Rec.gen_rev_actual_amts_thru_code     := l_default_gen_options_rec.gen_rev_actual_amts_thru_code   ;
               FP_Cols_Rec.gen_all_actual_amts_thru_code     := l_default_gen_options_rec.gen_all_actual_amts_thru_code   ;
               -- start of FP M Phase II Dev changes
               FP_Cols_Rec.gen_src_cost_wp_version_id        := l_default_gen_options_rec.gen_src_cost_wp_version_id      ;
               FP_Cols_Rec.gen_src_cost_wp_ver_code          := l_default_gen_options_rec.gen_src_cost_wp_ver_code        ;
               FP_Cols_Rec.gen_src_rev_wp_version_id         := l_default_gen_options_rec.gen_src_rev_wp_version_id       ;
               FP_Cols_Rec.gen_src_rev_wp_ver_code           := l_default_gen_options_rec.gen_src_rev_wp_ver_code         ;
               FP_Cols_Rec.gen_src_all_wp_version_id         := l_default_gen_options_rec.gen_src_all_wp_version_id       ;
               FP_Cols_Rec.gen_src_all_wp_ver_code           := l_default_gen_options_rec.gen_src_all_wp_ver_code         ;
               FP_Cols_Rec.revenue_derivation_method         := l_default_gen_options_rec.revenue_derivation_method       ; --Bug 5462471
               -- end of FP M Phase II Dev changes
               FP_Cols_Rec.copy_etc_from_plan_flag           := l_default_gen_options_rec.copy_etc_from_plan_flag         ; --bug# 8318932
               -- Added the three colums for ms-excel options tab in web Adi Changes

               IF NVL(l_webadi_profile,'N') = 'Y' THEN

                   IF (l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY OR
                        l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP ) THEN

                       IF P_PA_DEBUG_MODE = 'Y' THEN
                           pa_debug.g_err_stage := 'inside cost only preference code  FP_Cols_Rec.cost_time_phased_code :: '||FP_Cols_Rec.cost_time_phased_code;
                           pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
                       END IF;

                        IF FP_Cols_Rec.cost_time_phased_code in ('G','P') THEN

                               IF P_PA_DEBUG_MODE = 'Y' THEN
                                   pa_debug.g_err_stage := 'inside cost_time_phased_code is G or p , l_source_plan_class_code '|| plan_type_info_rec.plan_class_code;
                                   pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
                               END IF;

                            IF plan_type_info_rec.plan_class_code = 'BUDGET' THEN

                                FP_Cols_Rec.cost_layout_code := 'PE_BUDGET';
                            ELSIF  plan_type_info_rec.plan_class_code = 'FORECAST' THEN
                                FP_Cols_Rec.cost_layout_code := 'PE_FORECAST';
                            END IF;
                        ELSE
                           FP_Cols_Rec.cost_layout_code        := l_default_gen_options_rec.cost_layout_code;
                        END IF;
                   END IF;

                   IF (l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY OR
                        l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP ) THEN

                       IF FP_Cols_Rec.revenue_time_phased_code in ('G','P') THEN

                            IF plan_type_info_rec.plan_class_code = 'BUDGET' THEN
                                FP_Cols_Rec.revenue_layout_code := 'PE_BUDGET';
                            ELSIF plan_type_info_rec.plan_class_code = 'FORECAST' THEN
                                FP_Cols_Rec.revenue_layout_code := 'PE_FORECAST';
                            END IF;
                        ELSE
                            FP_Cols_Rec.revenue_layout_code    := l_default_gen_options_rec.revenue_layout_code ;
                        END IF;
                   END IF;

                   IF l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME THEN

                       IF FP_Cols_Rec.all_time_phased_code in ('G','P') THEN
                            IF plan_type_info_rec.plan_class_code = 'BUDGET' THEN
                                FP_Cols_Rec.all_layout_code := 'PE_BUDGET';
                            ELSIF plan_type_info_rec.plan_class_code = 'FORECAST' THEN
                                FP_Cols_Rec.all_layout_code := 'PE_FORECAST';
                            END IF;
                        ELSE
                            FP_Cols_Rec.all_layout_code        := l_default_gen_options_rec.all_layout_code ;
                        END IF;
                   END IF;

    --                  FP_Cols_Rec.cost_layout_code                  := l_default_gen_options_rec.cost_layout_code                ;
    --                  FP_Cols_Rec.revenue_layout_code               := l_default_gen_options_rec.revenue_layout_code                ;
    --                  FP_Cols_Rec.all_layout_code                   := l_default_gen_options_rec.all_layout_code                ;
               END IF;

          END IF;

      ELSIF l_target_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION
      THEN

          -- Check if target is a control document

          OPEN  plan_version_info_cur(l_plan_version_id);
          FETCH plan_version_info_cur INTO plan_version_info_rec;
            IF plan_version_info_cur%NOTFOUND THEN
               RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
            END IF;
          CLOSE plan_version_info_cur;

          IF (plan_version_info_rec.ci_id IS NOT NULL) THEN
               -- We are in the context of ci version

               -- Null out RBS version id
               FP_Cols_Rec.rbs_version_id        := null;

               -- Null out all the genration options and rate schedule columns

                /* Though rate schedules tab is not shown in change order, we
                 * need to copy them from current working version
                FP_Cols_Rec.use_planning_rates_flag           := null ;
                FP_Cols_Rec.res_class_raw_cost_sch_id         := null ;
                FP_Cols_Rec.res_class_bill_rate_sch_id        := null ;
                FP_Cols_Rec.cost_emp_rate_sch_id              := null ;
                FP_Cols_Rec.cost_job_rate_sch_id              := null ;
                FP_Cols_Rec.cost_non_labor_res_rate_sch_id    := null ;
                FP_Cols_Rec.cost_res_class_rate_sch_id        := null ;
                FP_Cols_Rec.cost_burden_rate_sch_id           := null ;
                FP_Cols_Rec.rev_emp_rate_sch_id               := null ;
                FP_Cols_Rec.rev_job_rate_sch_id               := null ;
                FP_Cols_Rec.rev_non_labor_res_rate_sch_id     := null ;
                FP_Cols_Rec.rev_res_class_rate_sch_id         := null ;
                */
                /** Bug 3580727
                FP_Cols_Rec.all_emp_rate_sch_id               := null ;
                FP_Cols_Rec.all_job_rate_sch_id               := null ;
                FP_Cols_Rec.all_non_labor_res_rate_sch_id     := null ;
                FP_Cols_Rec.all_res_class_rate_sch_id         := null ;
                FP_Cols_Rec.all_burden_rate_sch_id            := null ;
                **/

                FP_Cols_Rec.gen_cost_src_code                 := null ;
                FP_Cols_Rec.gen_cost_etc_src_code             := null ;
                FP_Cols_Rec.gen_cost_incl_change_doc_flag     := null ;
                FP_Cols_Rec.gen_cost_incl_open_comm_flag      := null ;
                FP_Cols_Rec.gen_cost_ret_manual_line_flag     := null ;
                FP_Cols_Rec.gen_cost_incl_unspent_amt_flag    := null ;
                FP_Cols_Rec.gen_rev_src_code                  := null ;
                FP_Cols_Rec.gen_rev_etc_src_code              := null ;
                FP_Cols_Rec.gen_rev_incl_change_doc_flag      := null ;
                FP_Cols_Rec.gen_rev_incl_bill_event_flag      := null ;
                FP_Cols_Rec.gen_rev_ret_manual_line_flag      := null ;
                /** Bug 3580727
                FP_Cols_Rec.gen_rev_incl_unspent_amt_flag     := null ;
                **/
                FP_Cols_Rec.gen_src_cost_plan_type_id         := null ;
                FP_Cols_Rec.gen_src_cost_plan_version_id      := null ;
                FP_Cols_Rec.gen_src_cost_plan_ver_code        := null ;
                FP_Cols_Rec.gen_src_rev_plan_type_id          := null ;
                FP_Cols_Rec.gen_src_rev_plan_version_id       := null ;
                FP_Cols_Rec.gen_src_rev_plan_ver_code         := null ;
                FP_Cols_Rec.gen_src_all_plan_type_id          := null ;
                FP_Cols_Rec.gen_src_all_plan_version_id       := null ;
                FP_Cols_Rec.gen_src_all_plan_ver_code         := null ;
                FP_Cols_Rec.gen_all_src_code                  := null ;
                FP_Cols_Rec.gen_all_etc_src_code              := null ;
                FP_Cols_Rec.gen_all_incl_change_doc_flag      := null ;
                FP_Cols_Rec.gen_all_incl_open_comm_flag       := null ;
                FP_Cols_Rec.gen_all_ret_manual_line_flag      := null ;
                FP_Cols_Rec.gen_all_incl_bill_event_flag      := null ;
                FP_Cols_Rec.gen_all_incl_unspent_amt_flag     := null ;
                FP_Cols_Rec.gen_cost_actual_amts_thru_code    := null ;
                FP_Cols_Rec.gen_rev_actual_amts_thru_code     := null ;
                FP_Cols_Rec.gen_all_actual_amts_thru_code     := null ;
                -- Start of FP M Phase II Dev changes
                FP_Cols_Rec.gen_src_cost_wp_version_id        := null ;
                FP_Cols_Rec.gen_src_cost_wp_ver_code          := null ;
                FP_Cols_Rec.gen_src_rev_wp_version_id         := null ;
                FP_Cols_Rec.gen_src_rev_wp_ver_code           := null ;
                FP_Cols_Rec.gen_src_all_wp_version_id         := null ;
                FP_Cols_Rec.gen_src_all_wp_ver_code           := null ;
                -- End of FP M Phase II Dev changes
                FP_Cols_Rec.copy_etc_from_plan_flag           := null ; --bug#8318932
          ELSE  -- target is not ci version

              -- If source option is plan type
              IF (l_source_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE  AND
                  nvl(plan_type_info_rec.use_for_workplan_flag,'N') <>'Y' )
              THEN

                  -- Gen Src Version Id should be initialized using Gen Src Version Code
                  IF (l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY) AND
                     (FP_Cols_Rec.gen_src_cost_plan_type_id IS NOT NULL ) AND
                     (FP_Cols_Rec.gen_src_cost_plan_ver_code IS NOT NULL)
                  THEN

                       -- Call private method fetch Gen_Src_Plan_Version_Id
                      FP_Cols_Rec.gen_src_cost_plan_version_id := Gen_Src_Plan_Version_Id (
                               p_target_project_id        =>  p_target_project_id
                              ,p_target_version_type      =>  'COST'
                              ,p_gen_src_plan_type_id     =>  FP_Cols_Rec.gen_src_cost_plan_type_id
                              ,p_gen_src_plan_ver_code    =>  FP_Cols_Rec.gen_src_cost_plan_ver_code );

                       -- Null out generation source plan version code
                       FP_Cols_Rec.gen_src_cost_plan_ver_code := NULL;

                  ELSIF (l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY) AND
                        (FP_Cols_Rec.gen_src_rev_plan_type_id IS NOT NULL ) AND
                        (FP_Cols_Rec.gen_src_rev_plan_ver_code IS NOT NULL)
                  THEN

                       -- Call private method fetch Gen_Src_Plan_Version_Id
                      FP_Cols_Rec.gen_src_rev_plan_version_id := Gen_Src_Plan_Version_Id (
                               p_target_project_id        =>  p_target_project_id
                              ,p_target_version_type      =>  'REVENUE'
                              ,p_gen_src_plan_type_id     =>  FP_Cols_Rec.gen_src_rev_plan_type_id
                              ,p_gen_src_plan_ver_code    =>  FP_Cols_Rec.gen_src_rev_plan_ver_code );

                       -- Null out generation source plan version code
                       FP_Cols_Rec.gen_src_rev_plan_ver_code := NULL;

                  ELSIF (l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME) AND
                        (FP_Cols_Rec.gen_src_all_plan_type_id IS NOT NULL ) AND
                        (FP_Cols_Rec.gen_src_all_plan_ver_code IS NOT NULL)
                  THEN

                       -- Call private method fetch Gen_Src_Plan_Version_Id
                      FP_Cols_Rec.gen_src_all_plan_version_id := Gen_Src_Plan_Version_Id (
                               p_target_project_id        =>  p_target_project_id
                              ,p_target_version_type      =>  'ALL'
                              ,p_gen_src_plan_type_id     =>  FP_Cols_Rec.gen_src_all_plan_type_id
                              ,p_gen_src_plan_ver_code    =>  FP_Cols_Rec.gen_src_all_plan_ver_code );

                       -- Null out generation source plan version code
                       FP_Cols_Rec.gen_src_all_plan_ver_code := NULL;
                  END IF;

                  -- Gen Src Workplan Version Id should be initialized using Gen Src Wp version code
                  IF (l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY) AND
                     (FP_Cols_Rec.gen_src_cost_wp_ver_code IS NOT NULL)
                  THEN

                       -- Call private method fetch Gen_Src_WP_Version_Id
                      FP_Cols_Rec.gen_src_cost_wp_version_id := Gen_Src_WP_Version_Id (
                               p_target_project_id        =>  p_target_project_id
                              ,p_gen_src_wp_ver_code      =>  FP_Cols_Rec.gen_src_cost_wp_ver_code );

                       -- Null out generation source workplan version code
                       FP_Cols_Rec.gen_src_cost_wp_ver_code := NULL;

                  ELSIF (l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY) AND
                        (FP_Cols_Rec.gen_src_rev_wp_ver_code IS NOT NULL)
                  THEN

                       -- Call private method fetch Gen_Src_WP_Version_Id
                      FP_Cols_Rec.gen_src_rev_wp_version_id := Gen_Src_WP_Version_Id (
                               p_target_project_id        =>  p_target_project_id
                              ,p_gen_src_wp_ver_code      =>  FP_Cols_Rec.gen_src_rev_wp_ver_code );

                       -- Null out generation source workplan version code
                       FP_Cols_Rec.gen_src_rev_wp_ver_code := NULL;

                  ELSIF (l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME) AND
                        (FP_Cols_Rec.gen_src_all_wp_ver_code IS NOT NULL)
                  THEN

                      -- Call private method fetch Gen_Src_WP_Version_Id
                      FP_Cols_Rec.gen_src_all_wp_version_id := Gen_Src_WP_Version_Id (
                               p_target_project_id        =>  p_target_project_id
                              ,p_gen_src_wp_ver_code      =>  FP_Cols_Rec.gen_src_all_wp_ver_code );

                       -- Null out generation source workplan version code
                       FP_Cols_Rec.gen_src_all_wp_ver_code := NULL;
                  END IF;
              ELSIF l_source_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION
              THEN

                  -- 3/28/2004 FP M Phase II Dev Effort Copy Project Impact
                  IF l_source_project_id <> p_target_project_id
                  THEN
                       -- Null out all gen source version id columns
                       FP_Cols_Rec.gen_src_cost_wp_version_id        := null ;
                       FP_Cols_Rec.gen_src_rev_wp_version_id         := null ;
                       FP_Cols_Rec.gen_src_all_wp_version_id         := null ;
                       FP_Cols_Rec.gen_src_cost_plan_version_id      := null ;
                       FP_Cols_Rec.gen_src_rev_plan_version_id       := null ;
                       FP_Cols_Rec.gen_src_all_plan_version_id       := null ;
                  END IF;

              END IF;   -- l_source_option_level_code

          END IF; -- target version is ci/other kind of version

      END IF;  -- l_target_option_level_code

   END IF; -- l_target_option_level_code <> PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PROJECT

-- End of FP M Dev effort

   /* MC Options need to be copied only in the context of plan type or plan version.
      The logic of copying mc options is common and hence done outside all IFs. */

   IF l_target_option_level_code <> PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PROJECT THEN
       /* While copying project, the MC options should be inherited from the source option
          i.e., from the source project's plan type or plan version */
     IF p_source_proj_fp_option_id IS NOT NULL THEN
        IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage := TO_CHAR(l_Stage)||': getting mc options from source option';
                pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;

        fp_mc_cols_rec := get_fp_proj_mc_options(p_source_proj_fp_option_id);

        IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage := TO_CHAR(l_Stage)||'retruned from get_fp_proj_mc_options';
                pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

     ELSE
       /* MC Options are always inherited from the Plan Type MC options. In this case
          plan type id cannot be null (validation done) */
             IF l_target_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE THEN
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.g_err_stage := TO_CHAR(l_Stage)||': getting mc options from plan type';
                      pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
                 END IF;

                 fp_mc_cols_rec := get_fp_plan_type_mc_options(l_plan_type_id);

             ELSE
                 IF l_par_Proj_FP_Options_ID IS NOT NULL THEN
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.g_err_stage := TO_CHAR(l_Stage)||': getting mc options from parent';
                         pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
                    END IF;

                    /* #2598361: Modified the call from get_fp_plan_type_mc_options to
                       get_fp_proj_mc_options as the option level code is Plan Version. */
                    fp_mc_cols_rec := get_fp_proj_mc_options(l_par_Proj_FP_Options_ID);
                 ELSE
                    /* there is no default value for mc rec */
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.g_err_stage := TO_CHAR(l_Stage)||': mc options cannot be determined. these are nulls';
                         pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
                    END IF;
                    fp_mc_cols_rec := null;
                 END IF;
             END IF;
      END IF;
      /* Bug# 2637789 */
      /* Bug 2747255 - Set the Cost conv attributes null if pref cost is REVENUE_ONLY and vice versa */
      IF l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY THEN
        FP_Mc_Cols_Rec.approved_rev_plan_type_flag  := 'N';
        FP_Mc_Cols_Rec.primary_rev_forecast_flag    := 'N';
        FP_Mc_Cols_Rec.project_rev_rate_type        := Null;
        FP_Mc_Cols_Rec.project_rev_rate_date_type   := Null;
        FP_Mc_Cols_Rec.project_rev_rate_date        := Null;
        FP_Mc_Cols_Rec.projfunc_rev_rate_type       := Null;
        FP_Mc_Cols_Rec.projfunc_rev_rate_date_type  := Null;
        FP_Mc_Cols_Rec.projfunc_rev_rate_date       := Null;
      ELSIF l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY THEN
        FP_Mc_Cols_Rec.approved_cost_plan_type_flag := 'N';
        FP_Mc_Cols_Rec.primary_cost_forecast_flag   := 'N';
        FP_Mc_Cols_Rec.projfunc_cost_rate_type      := Null;
        FP_Mc_Cols_Rec.projfunc_cost_rate_date_type := Null;
        FP_Mc_Cols_Rec.projfunc_cost_rate_date      := Null;
        FP_Mc_Cols_Rec.project_cost_rate_type       := Null;
        FP_Mc_Cols_Rec.project_cost_rate_date_type  := Null;
        FP_Mc_Cols_Rec.project_cost_rate_date       := Null;
      END IF;
   END IF;
   IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage := TO_CHAR(l_Stage)||'Done with conv attr settings';
            pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,3);
   END IF;


   l_stage := 500;

   -- 3/30/2004 Raja FP M Phase II Dev Changes
   -- If source project and target project are different do not copy
   -- the current planning periods from souce option. They should be
   -- defaulted to PA/GL period inwhich nvl(project start date, sysdate)
   -- falls
   IF l_source_project_id <> p_target_project_id
   THEN
       IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage := TO_CHAR(l_Stage)||' About to call Pa_Prj_Period_Profile_Utils.Get_Prj_Defaults';
                pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

        Pa_Prj_Period_Profile_Utils.Get_Prj_Defaults(
             p_project_id                 => p_target_project_id
            ,p_info_flag                  => 'ALL'
            ,p_create_defaults            => 'N'
            ,x_gl_start_period            => l_gl_start_period
            ,x_gl_end_period              => l_gl_end_period
            ,x_gl_start_Date              => l_gl_start_Date
            ,x_pa_start_period            => l_pa_start_period
            ,x_pa_end_period              => l_pa_end_period
            ,x_pa_start_date              => l_pa_start_date
            ,x_plan_version_exists_flag   => l_plan_version_exists_flag
            ,x_prj_start_date             => l_prj_start_date
            ,x_prj_end_date               => l_prj_end_date             );

       IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage := TO_CHAR(l_Stage)||' After call to  Pa_Prj_Period_Profile_Utils.Get_Prj_Defaults';
                pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;


        IF FP_Cols_Rec.cost_current_planning_period IS NOT NULL THEN
            IF  FP_Cols_Rec.cost_time_phased_code = 'P' THEN
                FP_Cols_Rec.cost_current_planning_period := l_pa_start_period;
            ELSIF FP_Cols_Rec.cost_time_phased_code = 'G'  THEN
                FP_Cols_Rec.cost_current_planning_period := l_gl_start_period;
            END IF;
        END IF;

        IF FP_Cols_Rec.rev_current_planning_period IS NOT NULL THEN
            IF  FP_Cols_Rec.revenue_time_phased_code = 'P' THEN
                FP_Cols_Rec.rev_current_planning_period := l_pa_start_period;
            ELSIF FP_Cols_Rec.revenue_time_phased_code = 'G'  THEN
                FP_Cols_Rec.rev_current_planning_period := l_gl_start_period;
            END IF;
        END IF;

        IF FP_Cols_Rec.all_current_planning_period IS NOT NULL THEN
            IF  FP_Cols_Rec.all_time_phased_code = 'P' THEN
                FP_Cols_Rec.all_current_planning_period := l_pa_start_period;
            ELSIF FP_Cols_Rec.all_time_phased_code = 'G'  THEN
                FP_Cols_Rec.all_current_planning_period := l_gl_start_period;
            END IF;
        END IF;

   END IF;
   IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage := TO_CHAR(l_Stage)||'Done with Project defaults';
            pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,3);
   END IF;

   l_stage := 600;

      IF (px_target_proj_fp_option_id IS NOT NULL) THEN /* Source is not null and Target is not null */
          /* Control of the Program would come to this point when the Source FP Option ID
             is not null and Target FP Option ID is not null. This case would occur when
             'Copying from a Source FP Option to an exisiting Target FP Option' (Copy From page).
                     In this case the Target FP option details need to be updated with the
             details of the Source FP Option.  */

          IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Calling Table Handler to update row';
                  pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,3);
                  pa_debug.g_err_stage := 'plan in multi flag = ' || FP_Cols_Rec.plan_in_multi_curr_flag;
                  pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;

          /* Bug 3149010 - Logic of not overwritting attribs when the target is ALL */

          IF l_source_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY AND
             l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME THEN
             FP_Mc_Cols_Rec.projfunc_cost_rate_type := FND_API.G_MISS_CHAR;
             FP_Mc_Cols_Rec.projfunc_cost_rate_date_type := FND_API.G_MISS_CHAR;
             FP_Mc_Cols_Rec.projfunc_cost_rate_date := FND_API.G_MISS_DATE;
             FP_Mc_Cols_Rec.project_cost_rate_type := FND_API.G_MISS_CHAR;
             FP_Mc_Cols_Rec.project_cost_rate_date_type := FND_API.G_MISS_CHAR;
             FP_Mc_Cols_Rec.project_cost_rate_date := FND_API.G_MISS_DATE;
             FP_Mc_Cols_Rec.approved_cost_plan_type_flag := FND_API.G_MISS_CHAR;

             -- Bug 3580727 do not over write cost rate schedule columns
             FP_Cols_Rec.cost_emp_rate_sch_id              := FND_API.G_MISS_NUM ;
             FP_Cols_Rec.cost_job_rate_sch_id              := FND_API.G_MISS_NUM ;
             FP_Cols_Rec.cost_non_labor_res_rate_sch_id    := FND_API.G_MISS_NUM ;
             FP_Cols_Rec.cost_res_class_rate_sch_id        := FND_API.G_MISS_NUM ;
             FP_Cols_Rec.cost_burden_rate_sch_id           := FND_API.G_MISS_NUM ;

          ELSIF l_source_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY AND
             l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME THEN
             FP_Mc_Cols_Rec.projfunc_rev_rate_type := FND_API.G_MISS_CHAR;
             FP_Mc_Cols_Rec.projfunc_rev_rate_date_type := FND_API.G_MISS_CHAR;
             FP_Mc_Cols_Rec.projfunc_rev_rate_date := FND_API.G_MISS_DATE;
             FP_Mc_Cols_Rec.project_rev_rate_type := FND_API.G_MISS_CHAR;
             FP_Mc_Cols_Rec.project_rev_rate_date_type := FND_API.G_MISS_CHAR;
             FP_Mc_Cols_Rec.project_rev_rate_date := FND_API.G_MISS_DATE;
             FP_Mc_Cols_Rec.approved_rev_plan_type_flag := FND_API.G_MISS_CHAR;

             -- Bug 3580727 do not over write revenue rate schedule columns
             FP_Cols_Rec.rev_emp_rate_sch_id               := FND_API.G_MISS_NUM ;
             FP_Cols_Rec.rev_job_rate_sch_id               := FND_API.G_MISS_NUM ;
             FP_Cols_Rec.rev_non_labor_res_rate_sch_id     := FND_API.G_MISS_NUM ;
             FP_Cols_Rec.rev_res_class_rate_sch_id         := FND_API.G_MISS_NUM ;

          END IF;

          /* Bug 3149010 -  If source and target are versions we need not and should not
             overwrite the appr plan type flags

             FP M Phase II Development changes: While copying one version to another
             existing version do not over write primary forecast columns, rate schedule
             setup if target is AR version, generation options set up if plan class codes
             differ for source and target versions
           */
          IF l_source_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION AND
             l_target_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION THEN

             FP_Mc_Cols_Rec.approved_rev_plan_type_flag    :=  FND_API.G_MISS_CHAR;
             FP_Mc_Cols_Rec.approved_cost_plan_type_flag   :=  FND_API.G_MISS_CHAR;

             -- Start of FP M Phase II development changes
             FP_Mc_Cols_Rec.primary_cost_forecast_flag     :=  FND_API.G_MISS_CHAR;
             FP_Mc_Cols_Rec.primary_rev_forecast_flag      :=  FND_API.G_MISS_CHAR;

             -- Do not over write rate schedule data if target is AR version
             OPEN  opt_info_Cur(px_target_proj_fp_option_id);
         FETCH opt_info_Cur INTO opt_info_rec;
         CLOSE opt_info_Cur;

             IF opt_info_rec.approved_rev_plan_type_flag = 'Y' THEN

         FP_Cols_Rec.use_planning_rates_flag           := FND_API.G_MISS_CHAR ;
                 FP_Cols_Rec.res_class_raw_cost_sch_id         := FND_API.G_MISS_NUM ;
                 FP_Cols_Rec.res_class_bill_rate_sch_id        := FND_API.G_MISS_NUM ;
                 FP_Cols_Rec.cost_emp_rate_sch_id              := FND_API.G_MISS_NUM ;
                 FP_Cols_Rec.cost_job_rate_sch_id              := FND_API.G_MISS_NUM ;
                 FP_Cols_Rec.cost_non_labor_res_rate_sch_id    := FND_API.G_MISS_NUM ;
                 FP_Cols_Rec.cost_res_class_rate_sch_id        := FND_API.G_MISS_NUM ;
                 FP_Cols_Rec.cost_burden_rate_sch_id           := FND_API.G_MISS_NUM ;
                 FP_Cols_Rec.rev_emp_rate_sch_id               := FND_API.G_MISS_NUM ;
                 FP_Cols_Rec.rev_job_rate_sch_id               := FND_API.G_MISS_NUM ;
                 FP_Cols_Rec.rev_non_labor_res_rate_sch_id     := FND_API.G_MISS_NUM ;
                 FP_Cols_Rec.rev_res_class_rate_sch_id         := FND_API.G_MISS_NUM ;
                 /*** Bug 3580727
                 FP_Cols_Rec.all_emp_rate_sch_id               := FND_API.G_MISS_NUM ;
                 FP_Cols_Rec.all_job_rate_sch_id               := FND_API.G_MISS_NUM ;
                 FP_Cols_Rec.all_non_labor_res_rate_sch_id     := FND_API.G_MISS_NUM ;
                 FP_Cols_Rec.all_res_class_rate_sch_id         := FND_API.G_MISS_NUM ;
                 FP_Cols_Rec.all_burden_rate_sch_id            := FND_API.G_MISS_NUM ;
                 ***/
             END IF;

             -- Do not over write generation options data if target and source versions
             -- belong to different plan classes.
             IF plan_type_info_rec.plan_class_code <> nvl(l_source_plan_class_code, '-9999') THEN
                 FP_Cols_Rec.gen_cost_src_code                 :=  FND_API.G_MISS_CHAR;
                 FP_Cols_Rec.gen_cost_etc_src_code             :=  FND_API.G_MISS_CHAR;
                 FP_Cols_Rec.gen_src_cost_plan_type_id         :=  FND_API.G_MISS_NUM;
                 FP_Cols_Rec.gen_src_cost_plan_version_id      :=  FND_API.G_MISS_NUM;
                 FP_Cols_Rec.gen_src_cost_plan_ver_code        :=  FND_API.G_MISS_CHAR;
                 FP_Cols_Rec.gen_src_cost_wp_version_id        :=  FND_API.G_MISS_NUM;
                 FP_Cols_Rec.gen_src_cost_wp_ver_code          :=  FND_API.G_MISS_CHAR;
                 FP_Cols_Rec.gen_cost_actual_amts_thru_code    :=  FND_API.G_MISS_CHAR;
                 FP_Cols_Rec.gen_cost_incl_change_doc_flag     :=  FND_API.G_MISS_CHAR;
                 FP_Cols_Rec.gen_cost_incl_open_comm_flag      :=  FND_API.G_MISS_CHAR;
                 FP_Cols_Rec.gen_cost_ret_manual_line_flag     :=  FND_API.G_MISS_CHAR;
                 FP_Cols_Rec.gen_cost_incl_unspent_amt_flag    :=  FND_API.G_MISS_CHAR;

                 FP_Cols_Rec.gen_rev_src_code                  :=  FND_API.G_MISS_CHAR;
                 FP_Cols_Rec.gen_rev_etc_src_code              :=  FND_API.G_MISS_CHAR;
                 FP_Cols_Rec.gen_src_rev_wp_version_id         :=  FND_API.G_MISS_NUM;
                 FP_Cols_Rec.gen_src_rev_wp_ver_code           :=  FND_API.G_MISS_CHAR;
                 FP_Cols_Rec.gen_src_rev_plan_type_id          :=  FND_API.G_MISS_NUM;
                 FP_Cols_Rec.gen_src_rev_plan_version_id       :=  FND_API.G_MISS_NUM;
                 FP_Cols_Rec.gen_src_rev_plan_ver_code         :=  FND_API.G_MISS_CHAR;
                 FP_Cols_Rec.gen_rev_incl_change_doc_flag      :=  FND_API.G_MISS_CHAR;
                 FP_Cols_Rec.gen_rev_incl_bill_event_flag      :=  FND_API.G_MISS_CHAR;
                 FP_Cols_Rec.gen_rev_ret_manual_line_flag      :=  FND_API.G_MISS_CHAR;
                 /*** Bug 3580727
                 FP_Cols_Rec.gen_rev_incl_unspent_amt_flag     :=  FND_API.G_MISS_CHAR;
                 ***/
                 FP_Cols_Rec.gen_rev_actual_amts_thru_code     :=  FND_API.G_MISS_CHAR;

                 FP_Cols_Rec.gen_all_src_code                  :=  FND_API.G_MISS_CHAR;
                 FP_Cols_Rec.gen_all_etc_src_code              :=  FND_API.G_MISS_CHAR;
                 FP_Cols_Rec.gen_src_all_plan_type_id          :=  FND_API.G_MISS_NUM;
                 FP_Cols_Rec.gen_src_all_plan_version_id       :=  FND_API.G_MISS_NUM;
                 FP_Cols_Rec.gen_src_all_plan_ver_code         :=  FND_API.G_MISS_CHAR;
                 FP_Cols_Rec.gen_src_all_wp_version_id         :=  FND_API.G_MISS_NUM;
                 FP_Cols_Rec.gen_src_all_wp_ver_code           :=  FND_API.G_MISS_CHAR;
                 FP_Cols_Rec.gen_all_incl_change_doc_flag      :=  FND_API.G_MISS_CHAR;
                 FP_Cols_Rec.gen_all_incl_open_comm_flag       :=  FND_API.G_MISS_CHAR;
                 FP_Cols_Rec.gen_all_ret_manual_line_flag      :=  FND_API.G_MISS_CHAR;
                 FP_Cols_Rec.gen_all_incl_bill_event_flag      :=  FND_API.G_MISS_CHAR;
                 FP_Cols_Rec.gen_all_incl_unspent_amt_flag     :=  FND_API.G_MISS_CHAR;
                 FP_Cols_Rec.gen_all_actual_amts_thru_code     :=  FND_API.G_MISS_CHAR;
                 FP_Cols_Rec.copy_etc_from_plan_flag           :=  FND_API.G_MISS_CHAR; --bug#8318932
             END IF;
             -- End of FP M Phase II development changes

          END IF;

          -- Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------

          PA_PROJ_FP_OPTIONS_PKG.update_row
                     ( p_proj_fp_options_id           =>  px_target_proj_fp_option_id
                      ,p_record_version_number        =>  NULL
                      ,p_project_id                   =>  p_target_project_id
                      ,p_fin_plan_option_level_code   =>  l_target_option_level_code
                      ,p_fin_plan_type_id             =>  l_plan_type_id
                      ,p_fin_plan_start_date          =>  FP_Cols_Rec.fin_plan_start_date
                      ,p_fin_plan_end_date            =>  FP_Cols_Rec.fin_plan_end_date
                      ,p_fin_plan_preference_code     =>  l_fp_preference_code
                      ,p_cost_amount_set_id           =>  FP_Cols_Rec.cost_amount_set_iD
                      ,p_revenue_amount_set_id        =>  FP_Cols_Rec.revenue_amount_set_id
                      ,p_all_amount_set_id            =>  FP_Cols_Rec.all_amount_set_id
                      ,p_cost_fin_plan_level_code     =>  FP_Cols_Rec.cost_fin_plan_level_code
                      ,p_cost_time_phased_code        =>  FP_Cols_Rec.cost_time_phased_code
                      ,p_cost_resource_list_id        =>  FP_Cols_Rec.cost_resource_list_id
                      ,p_revenue_fin_plan_level_code  =>  FP_Cols_Rec.revenue_fin_plan_level_code
                      ,p_revenue_time_phased_code     =>  FP_Cols_Rec.revenue_time_phased_code
                      ,p_revenue_resource_list_id     =>  FP_Cols_Rec.revenue_resource_list_id
                      ,p_all_fin_plan_level_code      =>  FP_Cols_Rec.all_fin_plan_level_code
                      ,p_all_time_phased_code         =>  FP_Cols_Rec.all_time_phased_code
                      ,p_all_resource_list_id         =>  FP_Cols_Rec.all_resource_list_id
                      ,p_report_labor_hrs_from_code   =>  FP_Cols_Rec.report_labor_hrs_from_code
                      ,p_fin_plan_version_id          =>  l_plan_version_id
                      ,p_plan_in_multi_curr_flag      =>  FP_Cols_Rec.plan_in_multi_curr_flag
                      ,p_factor_by_code               =>  FP_Cols_Rec.factor_by_code
                      ,p_default_amount_type_code     =>  FP_Cols_Rec.default_amount_type_code
                      ,p_default_amount_subtype_code  =>  FP_Cols_Rec.default_amount_subtype_code
                      ,p_approved_cost_plan_type_flag =>  FP_Mc_Cols_Rec.approved_cost_plan_type_flag
                      ,p_approved_rev_plan_type_flag  =>  FP_Mc_Cols_Rec.approved_rev_plan_type_flag
                      ,p_projfunc_cost_rate_type      =>  FP_Mc_Cols_Rec.projfunc_cost_rate_type
                      ,p_projfunc_cost_rate_date_type =>  FP_Mc_Cols_Rec.projfunc_cost_rate_date_type
                      ,p_projfunc_cost_rate_date      =>  FP_Mc_Cols_Rec.projfunc_cost_rate_date
                      ,p_projfunc_rev_rate_type       =>  FP_Mc_Cols_Rec.projfunc_rev_rate_type
                      ,p_projfunc_rev_rate_date_type  =>  FP_Mc_Cols_Rec.projfunc_rev_rate_date_type
                      ,p_projfunc_rev_rate_date       =>  FP_Mc_Cols_Rec.projfunc_rev_rate_date
                      ,p_project_cost_rate_type       =>  FP_Mc_Cols_Rec.project_cost_rate_type
                      ,p_project_cost_rate_date_type  =>  FP_Mc_Cols_Rec.project_cost_rate_date_type
                      ,p_project_cost_rate_date       =>  FP_Mc_Cols_Rec.project_cost_rate_date
                      ,p_project_rev_rate_type        =>  FP_Mc_Cols_Rec.project_rev_rate_type
                      ,p_project_rev_rate_date_type   =>  FP_Mc_Cols_Rec.project_rev_rate_date_type
                      ,p_project_rev_rate_date        =>  FP_Mc_Cols_Rec.project_rev_rate_date
                      ,p_margin_derived_from_code     =>  FP_Cols_Rec.margin_derived_from_code
                      /* Bug 2920954 start of additional parameters added for post fp_k oneoff*/
                      ,p_select_cost_res_auto_flag    =>  FP_Cols_Rec.select_cost_res_auto_flag
                      ,p_cost_res_planning_level      =>  FP_Cols_Rec.cost_res_planning_level
                      ,p_select_rev_res_auto_flag     =>  FP_Cols_Rec.select_rev_res_auto_flag
                      ,p_revenue_res_planning_level   =>  FP_Cols_Rec.revenue_res_planning_level
                      ,p_select_all_res_auto_flag     =>  FP_Cols_Rec.select_all_res_auto_flag
                      ,p_all_res_planning_level       =>  FP_Cols_Rec.all_res_planning_level
                      /* Bug 2920954 end of additional parameters added for post fp_k oneoff*/
                      ,p_primary_cost_forecast_flag   =>  FP_Mc_Cols_Rec.primary_cost_forecast_flag
                      ,p_primary_rev_forecast_flag    =>  FP_Mc_Cols_Rec.primary_rev_forecast_flag
                      ,p_use_planning_rates_flag      =>  FP_Cols_Rec.use_planning_rates_flag
                      ,p_rbs_version_id               =>  FP_Cols_Rec.rbs_version_id
                      ,p_res_class_raw_cost_sch_id    =>  FP_Cols_Rec.res_class_raw_cost_sch_id
                      ,p_res_class_bill_rate_sch_id   =>  FP_Cols_Rec.res_class_bill_rate_sch_id
                      ,p_cost_emp_rate_sch_id         =>  FP_Cols_Rec.cost_emp_rate_sch_id
                      ,p_cost_job_rate_sch_id         =>  FP_Cols_Rec.cost_job_rate_sch_id
                      ,P_CST_NON_LABR_RES_RATE_SCH_ID =>  FP_Cols_Rec.cost_non_labor_res_rate_sch_id
                      ,p_cost_res_class_rate_sch_id   =>  FP_Cols_Rec.cost_res_class_rate_sch_id
                      ,p_cost_burden_rate_sch_id      =>  FP_Cols_Rec.cost_burden_rate_sch_id
                      ,p_cost_current_planning_period =>  FP_Cols_Rec.cost_current_planning_period
                      ,p_cost_period_mask_id          =>  FP_Cols_Rec.cost_period_mask_id
                      ,p_rev_emp_rate_sch_id          =>  FP_Cols_Rec.rev_emp_rate_sch_id
                      ,p_rev_job_rate_sch_id          =>  FP_Cols_Rec.rev_job_rate_sch_id
                      ,P_REV_NON_LABR_RES_RATE_SCH_ID =>  FP_Cols_Rec.rev_non_labor_res_rate_sch_id
                      ,p_rev_res_class_rate_sch_id    =>  FP_Cols_Rec.rev_res_class_rate_sch_id
                      ,p_rev_current_planning_period  =>  FP_Cols_Rec.rev_current_planning_period
                      ,p_rev_period_mask_id           =>  FP_Cols_Rec.rev_period_mask_id
                      /*** Bug 3580727
                      ,p_all_emp_rate_sch_id          =>  FP_Cols_Rec.all_emp_rate_sch_id
                      ,p_all_job_rate_sch_id          =>  FP_Cols_Rec.all_job_rate_sch_id
                      ,P_ALL_NON_LABR_RES_RATE_SCH_ID =>  FP_Cols_Rec.all_non_labor_res_rate_sch_id
                      ,p_all_res_class_rate_sch_id    =>  FP_Cols_Rec.all_res_class_rate_sch_id
                      ,p_all_burden_rate_sch_id       =>  FP_Cols_Rec.all_burden_rate_sch_id
                      ***/
                      ,p_all_current_planning_period  =>  FP_Cols_Rec.all_current_planning_period
                      ,p_all_period_mask_id           =>  FP_Cols_Rec.all_period_mask_id
                      ,p_gen_cost_src_code            =>  FP_Cols_Rec.gen_cost_src_code
                      ,p_gen_cost_etc_src_code        =>  FP_Cols_Rec.gen_cost_etc_src_code
                      ,P_GN_COST_INCL_CHANGE_DOC_FLAG =>  FP_Cols_Rec.gen_cost_incl_change_doc_flag
                      ,p_gen_cost_incl_open_comm_flag =>  FP_Cols_Rec.gen_cost_incl_open_comm_flag
                      ,P_GN_COST_RET_MANUAL_LINE_FLAG =>  FP_Cols_Rec.gen_cost_ret_manual_line_flag
                      ,P_GN_CST_INCL_UNSPENT_AMT_FLAG =>  FP_Cols_Rec.gen_cost_incl_unspent_amt_flag
                      ,p_gen_rev_src_code             =>  FP_Cols_Rec.gen_rev_src_code
                      ,p_gen_rev_etc_src_code         =>  FP_Cols_Rec.gen_rev_etc_src_code
                      ,p_gen_rev_incl_change_doc_flag =>  FP_Cols_Rec.gen_rev_incl_change_doc_flag
                      ,p_gen_rev_incl_bill_event_flag =>  FP_Cols_Rec.gen_rev_incl_bill_event_flag
                      ,p_gen_rev_ret_manual_line_flag =>  FP_Cols_Rec.gen_rev_ret_manual_line_flag
                      /*** Bug 3580727
                      ,P_GN_REV_INCL_UNSPENT_AMT_FLAG =>  FP_Cols_Rec.gen_rev_incl_unspent_amt_flag
                      ***/
                      ,p_gen_src_cost_plan_type_id    =>  FP_Cols_Rec.gen_src_cost_plan_type_id
                      ,p_gen_src_cost_plan_version_id =>  FP_Cols_Rec.gen_src_cost_plan_version_id
                      ,p_gen_src_cost_plan_ver_code   =>  FP_Cols_Rec.gen_src_cost_plan_ver_code
                      ,p_gen_src_rev_plan_type_id     =>  FP_Cols_Rec.gen_src_rev_plan_type_id
                      ,p_gen_src_rev_plan_version_id  =>  FP_Cols_Rec.gen_src_rev_plan_version_id
                      ,p_gen_src_rev_plan_ver_code    =>  FP_Cols_Rec.gen_src_rev_plan_ver_code
                      ,p_gen_src_all_plan_type_id     =>  FP_Cols_Rec.gen_src_all_plan_type_id
                      ,p_gen_src_all_plan_version_id  =>  FP_Cols_Rec.gen_src_all_plan_version_id
                      ,p_gen_src_all_plan_ver_code    =>  FP_Cols_Rec.gen_src_all_plan_ver_code
                      ,p_gen_all_src_code             =>  FP_Cols_Rec.gen_all_src_code
                      ,p_gen_all_etc_src_code         =>  FP_Cols_Rec.gen_all_etc_src_code
                      ,p_gen_all_incl_change_doc_flag =>  FP_Cols_Rec.gen_all_incl_change_doc_flag
                      ,p_gen_all_incl_open_comm_flag  =>  FP_Cols_Rec.gen_all_incl_open_comm_flag
                      ,p_gen_all_ret_manual_line_flag =>  FP_Cols_Rec.gen_all_ret_manual_line_flag
                      ,p_gen_all_incl_bill_event_flag =>  FP_Cols_Rec.gen_all_incl_bill_event_flag
                      ,P_GN_ALL_INCL_UNSPENT_AMT_FLAG =>  FP_Cols_Rec.gen_all_incl_unspent_amt_flag
                      ,P_GN_CST_ACTUAL_AMTS_THRU_CODE =>  FP_Cols_Rec.gen_cost_actual_amts_thru_code
                      ,P_GN_REV_ACTUAL_AMTS_THRU_CODE =>  FP_Cols_Rec.gen_rev_actual_amts_thru_code
                      ,P_GN_ALL_ACTUAL_AMTS_THRU_CODE =>  FP_Cols_Rec.gen_all_actual_amts_thru_code
                      ,p_track_workplan_costs_flag    =>  FP_Cols_Rec.track_workplan_costs_flag
                       -- Start of FP M phase II dev changes
                      ,p_gen_src_cost_wp_version_id   =>  FP_Cols_Rec.gen_src_cost_wp_version_id
                      ,p_gen_src_cost_wp_ver_code     =>  FP_Cols_Rec.gen_src_cost_wp_ver_code
                      ,p_gen_src_rev_wp_version_id    =>  FP_Cols_Rec.gen_src_rev_wp_version_id
                      ,p_gen_src_rev_wp_ver_code      =>  FP_Cols_Rec.gen_src_rev_wp_ver_code
                      ,p_gen_src_all_wp_version_id    =>  FP_Cols_Rec.gen_src_all_wp_version_id
                      ,p_gen_src_all_wp_ver_code      =>  FP_Cols_Rec.gen_src_all_wp_ver_code
                       -- End of FP M phase II dev changes
                       --Adding for webadi Changes
                      ,p_cost_layout_code             =>  FP_Cols_Rec.cost_layout_code
                      ,p_revenue_layout_code          =>  FP_Cols_Rec.revenue_layout_code
                      ,p_all_layout_code              =>  FP_Cols_Rec.all_layout_code
                      ,p_revenue_derivation_method    =>  FP_Cols_Rec.revenue_derivation_method -- bug 5462471
                      ,p_copy_etc_from_plan_flag      =>  FP_Cols_Rec.copy_etc_from_plan_flag --bug#8318932
                      ,p_row_id                       =>  NULL
                      ,x_return_status                =>  x_return_status);

          -- END, Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------

      ELSE /* px_target_proj_fp_option_id Target IS NULL */

         /* Since the Target FP Option is NULL, a new Proj FP Option has to be created
            from the Source FP Option. */
         l_stage := 600;

         IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Calling Table Handler to insert row';
                 pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,3);
         END IF;
         IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage := TO_CHAR(l_Stage)||'About to insert the row';
                pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,3);
         END IF;

         -- Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------

         PA_PROJ_FP_OPTIONS_PKG.Insert_Row
                    ( px_proj_fp_options_id          => px_target_proj_fp_option_id
                     ,p_project_id                   => p_target_project_id
                     ,p_fin_plan_option_level_code   => l_target_option_level_code
                     ,p_fin_plan_type_id             => l_plan_type_id
                     ,p_fin_plan_start_date          => FP_Cols_Rec.fin_plan_start_date /* Bug 2798794 */
                     ,p_fin_plan_end_date            => FP_Cols_Rec.fin_plan_end_date   /* Bug 2798794 */
                     ,p_fin_plan_preference_code     => l_fp_preference_code
                     ,p_cost_amount_set_id           => FP_Cols_Rec.cost_amount_set_id
                     ,p_revenue_amount_set_id        => FP_Cols_Rec.revenue_amount_set_id
                     ,p_all_amount_set_id            => FP_Cols_Rec.all_amount_set_id
                     ,p_cost_fin_plan_level_code     => FP_Cols_Rec.cost_fin_plan_level_code
                     ,p_cost_time_phased_code        => FP_Cols_Rec.cost_time_phased_code
                     ,p_cost_resource_list_id        => FP_Cols_Rec.cost_resource_list_id
                     ,p_revenue_fin_plan_level_code  => FP_Cols_Rec.revenue_fin_plan_level_code
                     ,p_revenue_time_phased_code     => FP_Cols_Rec.revenue_time_phased_code
                     ,p_revenue_resource_list_id     => FP_Cols_Rec.revenue_resource_list_id
                     ,p_all_fin_plan_level_code      => FP_Cols_Rec.all_fin_plan_level_code
                     ,p_all_time_phased_code         => FP_Cols_Rec.all_time_phased_code
                     ,p_all_resource_list_id         => FP_Cols_Rec.all_resource_list_id
                     ,p_report_labor_hrs_from_code   => FP_Cols_Rec.report_labor_hrs_from_code
                     ,p_fin_plan_version_id          => p_target_fin_plan_version_id
                     ,p_plan_in_multi_curr_flag      => FP_Cols_Rec.plan_in_multi_curr_flag
                     ,p_factor_by_code               => FP_Cols_Rec.factor_by_code
                     ,p_default_amount_type_code     => FP_Cols_Rec.default_amount_type_code
                     ,p_default_amount_subtype_code  => FP_Cols_Rec.default_amount_subtype_code
                     ,p_approved_cost_plan_type_flag => FP_Mc_Cols_Rec.approved_cost_plan_type_flag
                     ,p_approved_rev_plan_type_flag  => FP_Mc_Cols_Rec.approved_rev_plan_type_flag
                     ,p_projfunc_cost_rate_type      => FP_Mc_Cols_Rec.projfunc_cost_rate_type
                     ,p_projfunc_cost_rate_date_type => FP_Mc_Cols_Rec.projfunc_cost_rate_date_type
                     ,p_projfunc_cost_rate_date      => FP_Mc_Cols_Rec.projfunc_cost_rate_date
                     ,p_projfunc_rev_rate_type       => FP_Mc_Cols_Rec.projfunc_rev_rate_type
                     ,p_projfunc_rev_rate_date_type  => FP_Mc_Cols_Rec.projfunc_rev_rate_date_type
                     ,p_projfunc_rev_rate_date       => FP_Mc_Cols_Rec.projfunc_rev_rate_date
                     ,p_project_cost_rate_type       => FP_Mc_Cols_Rec.project_cost_rate_type
                     ,p_project_cost_rate_date_type  => FP_Mc_Cols_Rec.project_cost_rate_date_type
                     ,p_project_cost_rate_date       => FP_Mc_Cols_Rec.project_cost_rate_date
                     ,p_project_rev_rate_type        => FP_Mc_Cols_Rec.project_rev_rate_type
                     ,p_project_rev_rate_date_type   => FP_Mc_Cols_Rec.project_rev_rate_date_type
                     ,p_project_rev_rate_date        => FP_Mc_Cols_Rec.project_rev_rate_date
                     /* Bug 2920954 start of additional parameters added for post fp_k oneoff*/
                     ,p_margin_derived_from_code     => FP_Cols_Rec.margin_derived_from_code
                     ,p_select_cost_res_auto_flag    => FP_Cols_Rec.select_cost_res_auto_flag
                     ,p_cost_res_planning_level      => FP_Cols_Rec.cost_res_planning_level
                     ,p_select_rev_res_auto_flag     => FP_Cols_Rec.select_rev_res_auto_flag
                     ,p_revenue_res_planning_level   => FP_Cols_Rec.revenue_res_planning_level
                     ,p_select_all_res_auto_flag     => FP_Cols_Rec.select_all_res_auto_flag
                     ,p_all_res_planning_level       => FP_Cols_Rec.all_res_planning_level
                     ,p_refresh_required_flag        => l_refresh_required_flag
                     ,p_request_id                   => NULL -- Always passed in as null by design.
                     ,p_processing_code              => NULL -- Always passed in as null by design.
                     /* Bug 2920954 end of additional parameters added for post fp_k oneoff*/
                      ,p_primary_cost_forecast_flag  => FP_Mc_Cols_Rec.primary_cost_forecast_flag
                      ,p_primary_rev_forecast_flag   => FP_Mc_Cols_Rec.primary_rev_forecast_flag
                      ,p_use_planning_rates_flag     => FP_Cols_Rec.use_planning_rates_flag
                      ,p_rbs_version_id              => FP_Cols_Rec.rbs_version_id
                      ,p_res_class_raw_cost_sch_id   => FP_Cols_Rec.res_class_raw_cost_sch_id
                      ,p_res_class_bill_rate_sch_id  => FP_Cols_Rec.res_class_bill_rate_sch_id
                      ,p_cost_emp_rate_sch_id        => FP_Cols_Rec.cost_emp_rate_sch_id
                      ,p_cost_job_rate_sch_id        => FP_Cols_Rec.cost_job_rate_sch_id
                      ,P_CST_NON_LABR_RES_RATE_SCH_ID  => FP_Cols_Rec.cost_non_labor_res_rate_sch_id
                      ,p_cost_res_class_rate_sch_id    => FP_Cols_Rec.cost_res_class_rate_sch_id
                      ,p_cost_burden_rate_sch_id       => FP_Cols_Rec.cost_burden_rate_sch_id
                      ,p_cost_current_planning_period  => FP_Cols_Rec.cost_current_planning_period
                      ,p_cost_period_mask_id           => FP_Cols_Rec.cost_period_mask_id
                      ,p_rev_emp_rate_sch_id           => FP_Cols_Rec.rev_emp_rate_sch_id
                      ,p_rev_job_rate_sch_id           => FP_Cols_Rec.rev_job_rate_sch_id
                      ,P_REV_NON_LABR_RES_RATE_SCH_ID  => FP_Cols_Rec.rev_non_labor_res_rate_sch_id
                      ,p_rev_res_class_rate_sch_id     => FP_Cols_Rec.rev_res_class_rate_sch_id
                      ,p_rev_current_planning_period   => FP_Cols_Rec.rev_current_planning_period
                      ,p_rev_period_mask_id            => FP_Cols_Rec.rev_period_mask_id
                      /*** Bug 3580727
                      ,p_all_emp_rate_sch_id           => FP_Cols_Rec.all_emp_rate_sch_id
                      ,p_all_job_rate_sch_id           => FP_Cols_Rec.all_job_rate_sch_id
                      ,P_ALL_NON_LABR_RES_RATE_SCH_ID  => FP_Cols_Rec.all_non_labor_res_rate_sch_id
                      ,p_all_res_class_rate_sch_id     => FP_Cols_Rec.all_res_class_rate_sch_id
                      ,p_all_burden_rate_sch_id        => FP_Cols_Rec.all_burden_rate_sch_id
                      ***/
                      ,p_all_current_planning_period   => FP_Cols_Rec.all_current_planning_period
                      ,p_all_period_mask_id            => FP_Cols_Rec.all_period_mask_id
                      ,p_gen_cost_src_code             => FP_Cols_Rec.gen_cost_src_code
                      ,p_gen_cost_etc_src_code         => FP_Cols_Rec.gen_cost_etc_src_code
                      ,P_GN_COST_INCL_CHANGE_DOC_FLAG  => FP_Cols_Rec.gen_cost_incl_change_doc_flag
                      ,p_gen_cost_incl_open_comm_flag  => FP_Cols_Rec.gen_cost_incl_open_comm_flag
                      ,P_GN_COST_RET_MANUAL_LINE_FLAG  => FP_Cols_Rec.gen_cost_ret_manual_line_flag
                      ,P_GN_CST_INCL_UNSPENT_AMT_FLAG  => FP_Cols_Rec.gen_cost_incl_unspent_amt_flag
                      ,p_gen_rev_src_code              => FP_Cols_Rec.gen_rev_src_code
                      ,p_gen_rev_etc_src_code          => FP_Cols_Rec.gen_rev_etc_src_code
                      ,p_gen_rev_incl_change_doc_flag  => FP_Cols_Rec.gen_rev_incl_change_doc_flag
                      ,p_gen_rev_incl_bill_event_flag  => FP_Cols_Rec.gen_rev_incl_bill_event_flag
                      ,p_gen_rev_ret_manual_line_flag  => FP_Cols_Rec.gen_rev_ret_manual_line_flag
                      /*** Bug 3580727
                      ,P_GN_REV_INCL_UNSPENT_AMT_FLAG  => FP_Cols_Rec.gen_rev_incl_unspent_amt_flag
                      ***/
                      ,p_gen_src_cost_plan_type_id     => FP_Cols_Rec.gen_src_cost_plan_type_id
                      ,p_gen_src_cost_plan_version_id  => FP_Cols_Rec.gen_src_cost_plan_version_id
                      ,p_gen_src_cost_plan_ver_code    => FP_Cols_Rec.gen_src_cost_plan_ver_code
                      ,p_gen_src_rev_plan_type_id      => FP_Cols_Rec.gen_src_rev_plan_type_id
                      ,p_gen_src_rev_plan_version_id   => FP_Cols_Rec.gen_src_rev_plan_version_id
                      ,p_gen_src_rev_plan_ver_code     => FP_Cols_Rec.gen_src_rev_plan_ver_code
                      ,p_gen_src_all_plan_type_id      => FP_Cols_Rec.gen_src_all_plan_type_id
                      ,p_gen_src_all_plan_version_id   => FP_Cols_Rec.gen_src_all_plan_version_id
                      ,p_gen_src_all_plan_ver_code     => FP_Cols_Rec.gen_src_all_plan_ver_code
                      ,p_gen_all_src_code              => FP_Cols_Rec.gen_all_src_code
                      ,p_gen_all_etc_src_code          => FP_Cols_Rec.gen_all_etc_src_code
                      ,p_gen_all_incl_change_doc_flag  => FP_Cols_Rec.gen_all_incl_change_doc_flag
                      ,p_gen_all_incl_open_comm_flag   => FP_Cols_Rec.gen_all_incl_open_comm_flag
                      ,p_gen_all_ret_manual_line_flag  => FP_Cols_Rec.gen_all_ret_manual_line_flag
                      ,p_gen_all_incl_bill_event_flag  => FP_Cols_Rec.gen_all_incl_bill_event_flag
                      ,P_GN_ALL_INCL_UNSPENT_AMT_FLAG  => FP_Cols_Rec.gen_all_incl_unspent_amt_flag
                      ,P_GN_CST_ACTUAL_AMTS_THRU_CODE  => FP_Cols_Rec.gen_cost_actual_amts_thru_code
                      ,P_GN_REV_ACTUAL_AMTS_THRU_CODE  => FP_Cols_Rec.gen_rev_actual_amts_thru_code
                      ,P_GN_ALL_ACTUAL_AMTS_THRU_CODE  => FP_Cols_Rec.gen_all_actual_amts_thru_code
                      ,p_track_workplan_costs_flag     => FP_Cols_Rec.track_workplan_costs_flag
                       -- Start of FP M phase II dev changes
                      ,p_gen_src_cost_wp_version_id   =>  FP_Cols_Rec.gen_src_cost_wp_version_id
                      ,p_gen_src_cost_wp_ver_code     =>  FP_Cols_Rec.gen_src_cost_wp_ver_code
                      ,p_gen_src_rev_wp_version_id    =>  FP_Cols_Rec.gen_src_rev_wp_version_id
                      ,p_gen_src_rev_wp_ver_code      =>  FP_Cols_Rec.gen_src_rev_wp_ver_code
                      ,p_gen_src_all_wp_version_id    =>  FP_Cols_Rec.gen_src_all_wp_version_id
                      ,p_gen_src_all_wp_ver_code      =>  FP_Cols_Rec.gen_src_all_wp_ver_code
                       -- End of FP M phase II dev changes
                       --Adding for webadi Changes
                      ,p_cost_layout_code             =>  FP_Cols_Rec.cost_layout_code
                      ,p_revenue_layout_code          =>  FP_Cols_Rec.revenue_layout_code
                      ,p_all_layout_code              =>  FP_Cols_Rec.all_layout_code
                      ,p_revenue_derivation_method    =>  FP_Cols_Rec.revenue_derivation_method -- bug 5462471
                      ,p_copy_etc_from_plan_flag      =>  FP_Cols_Rec.copy_etc_from_plan_flag --bug#8318932
                      ,x_row_id                        => x_row_id
                      ,x_return_status                 => x_return_status);

            -- End, Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------

      END IF;

         -- End, jwhite, 26-JUN-2003: Plannable Task Effort --------------------------------

    --Adding the code for attaching the layout codes to the plan type if they are being attached from a project or from a plan type.
    --For the ms-excel options tab
    IF l_target_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE
    AND (nvl(plan_type_info_rec.use_for_workplan_flag,'N') <> 'Y') THEN

        IF NVL(l_webadi_profile,'N') = 'Y' THEN

            IF p_source_proj_fp_option_id IS NULL THEN
                create_amt_types(
                    p_project_id               =>    p_target_project_id
                    ,p_fin_plan_type_id        =>    l_plan_type_id
                    ,p_plan_preference_code    =>    l_fp_preference_code
                    ,p_cost_layout_code        =>    FP_Cols_Rec.cost_layout_code
                    ,p_revenue_layout_code     =>    FP_Cols_Rec.revenue_layout_code
                    ,p_all_layout_code         =>    FP_Cols_Rec.all_layout_code
                    ,x_return_status           =>    x_return_status
                    ,x_msg_count               =>    x_msg_count
                    ,x_msg_data                =>    x_msg_data);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

            ELSE
                copy_amt_types (
                    p_source_project_id          =>    l_source_project_id
                    ,p_source_fin_plan_type_id   =>    l_source_plan_type_id
                    ,p_target_project_id         =>    p_target_project_id
                    ,p_target_fin_plan_type_id   =>    l_plan_type_id
                    ,x_return_status             =>    x_return_status
                    ,x_msg_count                 =>    x_msg_count
                    ,x_msg_data                  =>    x_msg_data );


                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;
            END IF; -- source project is null
        END IF;   -- web adi profile
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage := TO_CHAR(l_stage)||': End of Create_FP_Option';
            pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,3);
            pa_debug.reset_err_stack;
    END IF;

EXCEPTION
  WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
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
    IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.reset_err_stack;
    END IF;
    RAISE;
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_PROJ_FP_OPTIONS_PUB.Create_FP_Option'
            ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Create_FP_Option: ' || l_module_name,SQLERRM,5);
           pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.G_Err_Stack,5);
           pa_debug.reset_err_stack;
        END IF;
        RAISE ;
END Create_FP_Option;

/*===========================================================================================
  GET_FP_OPTIONS: This procedure returns the details of FP Option ID passed to this procedure
  based on the Fin_Plan_Preference_Code passed. p_proj_fp_options_id is the Source FP Option
  ID and p_fin_plan_preference_code is the Target Preference code. Hence the details of the
  Source FP Option are passed based on the Target and the Source Preference Codes. There are
  certain combinations which are invalid and exceptions are raised in these cases. For all
  other cases, details are passed based on the combination.

  10-AUG-2002 - added logic to derive values in mc attributes and approved cost/revenue plan
                types flags.
  24-AUG-2002 - it needs to be taken care that while copying from a cost and revenue sep
                to another option appropriate values should be copied.
                Also amount_set_id derivation needs to be changed.
  23-Apr-2003 - Bug 2920954 Modified to set the values of the new columns in the ouput
                plsql record type parameter x_fp_cols_rec


 r11.5 FP.M Developement ----------------------------------

  08-JAN-2004 jwhite     Bug 3362316  (HQ)
                         Extensively rewrote Get_Fp_Options
                         - All SELECTS from pa_proj_fp_options

  23-JAN-2004 rravipat   Bug 3354518 (IDC)
===========================================================================================*/
PROCEDURE Get_FP_Options (
             p_proj_fp_options_id             IN NUMBER
            ,p_target_fp_options_id           IN NUMBER
            ,p_fin_plan_preference_code       IN VARCHAR2
            ,p_target_fp_option_level_code    IN VARCHAR2  -- Adding this new parameter as a part of the ms-excel options
            ,x_fp_cols_rec                   OUT NOCOPY FP_COLS
            ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
            ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
            ,x_msg_data                      OUT NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895

l_debug_mode           VARCHAR2(30);
l_msg_count            NUMBER := 0;
l_data                 VARCHAR2(2000);
l_msg_data             VARCHAR2(2000);
l_msg_index_out        NUMBER;

l_source_fin_plan_pref         pa_proj_fp_options.FIN_PLAN_PREFERENCE_CODE%TYPE;
l_target_fin_plan_pref         pa_proj_fp_options.FIN_PLAN_PREFERENCE_CODE%TYPE;

l_fin_plan_option_level_code   pa_proj_fp_options.FIN_PLAN_OPTION_LEVEL_CODE%TYPE;
l_project_id                   pa_proj_fp_options.PROJECT_ID%TYPE;

l_cost_amount_set_id           pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE;
l_revenue_amount_set_id        pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE;
l_all_amount_set_id            pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE;

l_target_all_amount_set_id     pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE;

l_raw_cost_flag                pa_fin_plan_amount_sets.raw_cost_flag%TYPE     ;
l_burdened_cost_flag           pa_fin_plan_amount_sets.burdened_cost_flag%TYPE;
l_revenue_flag                 pa_fin_plan_amount_sets.revenue_flag%TYPE      ;
l_cost_qty_flag                pa_fin_plan_amount_sets.cost_qty_flag%TYPE     ;
l_revenue_qty_flag             pa_fin_plan_amount_sets.revenue_qty_flag%TYPE  ;
l_all_qty_flag                 pa_fin_plan_amount_sets.all_qty_flag%TYPE      ;

l_target_raw_cost_flag         pa_fin_plan_amount_sets.raw_cost_flag%TYPE     ;
l_target_burdened_cost_flag    pa_fin_plan_amount_sets.burdened_cost_flag%TYPE;
l_target_revenue_flag          pa_fin_plan_amount_sets.revenue_flag%TYPE      ;

-- FP M dev effort Defined new variables
l_bill_rate_flag               pa_fin_plan_amount_sets.bill_rate_flag%TYPE  ;
l_cost_rate_flag               pa_fin_plan_amount_sets.cost_rate_flag%TYPE;
l_burden_rate_flag             pa_fin_plan_amount_sets.burden_rate_flag%TYPE;
l_target_bill_rate_flag        pa_fin_plan_amount_sets.bill_rate_flag%TYPE  ;
l_target_cost_rate_flag        pa_fin_plan_amount_sets.cost_rate_flag%TYPE;
l_target_burd_rate_flag        pa_fin_plan_amount_sets.burden_rate_flag%TYPE;

BEGIN
    IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.set_err_stack('PA_PROJ_FP_OPTIONS_PUB.Get_FP_Options');
            fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
            l_debug_mode := NVL(l_debug_mode, 'Y');
            pa_debug.set_process('PLSQL','LOG',l_debug_mode);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT fin_plan_preference_code,
           fin_plan_option_level_code,
           project_id
      INTO l_source_fin_plan_pref,
           l_fin_plan_option_level_code,
           l_project_id
      FROM pa_proj_fp_options
     WHERE proj_fp_options_id = p_proj_fp_options_id;

    l_target_fin_plan_pref := Nvl(p_fin_plan_preference_code, l_source_fin_plan_pref);

  /* For Invalid Combinations of the Source and Target Fin_Plan_Preference_Code,
     raise the invalid parameters exception.
     The Invalid Combinations are:
     =======================================
     Source                Target
     =======================================
     COST_AND_REV_SAME     COST_AND_REV_SEP
     COST_ONLY             REVENUE_ONLY
     REVENUE_ONLY          COST_ONLY
  */

/*     M22-AUG: these validations are not required. These are not invalid combinations.
       IF ((l_source_fin_plan_pref = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME  AND
            l_target_fin_plan_pref = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP) OR

        (l_source_fin_plan_pref = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP  AND
            l_target_fin_plan_pref IN (PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY,
                                       PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY,
                                       PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME))
                                                             OR
*/
    IF (l_source_fin_plan_pref = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY  AND
         l_target_fin_plan_pref = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY)        OR
       (l_source_fin_plan_pref = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY  AND
         l_target_fin_plan_pref = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY) THEN

                IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.g_err_stage := 'Err- Invalid Combination of Source and Target Preference code';
                        pa_debug.write('Get_FP_Options: ' || l_module_name,pa_debug.g_err_stage,5);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                     p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

  -- Initializing all the cost/quantity flags to 'N'
  -- for bug#2708782 .This values will be reset to
  -- proper values in the below mentioned sqls

    l_raw_cost_flag            := 'N' ;
    l_burdened_cost_flag       := 'N' ;
    l_revenue_flag             := 'N' ;

/*  Bug # 2717297 - These variables should not be initialized to N as this
    is breaking the nvl chain logic to derive the all amount set id in the case of
    cost and revenue together to cost and revenue together option.

    l_cost_qty_flag            := 'N' ;
    l_revenue_qty_flag         := 'N' ;
    l_all_qty_flag             := 'N' ;
 */
    /* Included p_target_fp_options_id and target amount set ids for bug 3144283.
       This was done basically for the case when COST or REVENUE version is copied on to a
       COST_AND_REV_SAME version. In this case, we should not overwrite the REVENUE or COST
       amount set flags as the case may be for the target option which is having the pref
       code as Null  */

    IF p_target_fp_options_id IS NOT NULL AND
       l_target_fin_plan_pref = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME THEN

         IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.g_err_stage := 'Inside target opt id not null ' || p_target_fp_options_id ||
                                         ' and target pref code is ALL';
                 pa_debug.write('Get_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
         END IF;

         SELECT all_amount_set_id
          INTO  l_target_all_amount_set_id
          FROM  pa_proj_fp_options
         WHERE  proj_fp_options_id = p_target_fp_options_id;

         /* We need to use the ALL amount set id only if the target preference code is ALL.
            l_target_fin_plan_pref doesnt indicate the preference code of the target option,
            but the preference code that the target option should be updated with. So,
            the target flags which are intialized as Null are reset only if the target option
            before updation is having ALL preference code. We are checking the prefrence code
            of the target option as it is before updation by checking the nullablility of the
            all_amount_set_id column */

         IF l_target_all_amount_set_id IS NOT NULL THEN

                 SELECT raw_cost_flag
                      , burdened_cost_flag
                      , revenue_flag
                      , bill_rate_flag
                      , cost_rate_flag
                      , burden_rate_flag
                  INTO  l_target_raw_cost_flag
                      , l_target_burdened_cost_flag
                      , l_target_revenue_flag
                      , l_target_bill_rate_flag
                      , l_target_cost_rate_flag
                      , l_target_burd_rate_flag
                  FROM  pa_fin_plan_amount_sets
                 WHERE fin_plan_amount_set_id = l_target_all_amount_set_id ;
         END IF;

    END IF;

    SELECT cost_amount_set_id
          ,revenue_amount_set_id
          ,all_amount_set_id
     INTO  l_cost_amount_set_id
          ,l_revenue_amount_set_id
          ,l_all_amount_set_id
     FROM  pa_proj_fp_options
    WHERE  proj_fp_options_id = p_proj_fp_options_id;


    IF l_cost_amount_set_id IS NOT NULL THEN
           SELECT raw_cost_flag
                , burdened_cost_flag
                , cost_qty_flag
                , nvl(l_target_revenue_flag,l_revenue_flag) /* Bug 3144283 */
       -- bug 3505736        , nvl(l_target_bill_rate_flag,bill_rate_flag) -- FP M Dev effort
       -- bug 3505736        , nvl(l_target_cost_rate_flag,cost_rate_flag) -- FP M Dev effort
       -- bug 3505736        , nvl(l_target_burd_rate_flag,burden_rate_flag) -- FP M Dev effort
                , nvl(l_target_bill_rate_flag,l_bill_rate_flag)  -- bug 3505736
                , cost_rate_flag                                 -- bug 3505736
                , burden_rate_flag                               -- bug 3505736
             INTO l_raw_cost_flag
                , l_burdened_cost_flag
                , l_cost_qty_flag
                , l_revenue_flag
                , l_bill_rate_flag      -- FP M Dev effort
                , l_cost_rate_flag      -- FP M Dev effort
                , l_burden_rate_flag    -- FP M Dev effort
            FROM  pa_fin_plan_amount_sets
           WHERE  fin_plan_amount_set_id = l_cost_amount_set_id ;
    END IF;

    IF l_revenue_amount_set_id IS NOT NULL THEN
            SELECT revenue_flag
                 , revenue_qty_flag
                 , nvl(l_target_raw_cost_flag,l_raw_cost_flag) /* Bug 3144283 */
                 , nvl(l_target_burdened_cost_flag,l_burdened_cost_flag) /* Bug 3144283 */
        -- bug 3505736  , nvl(l_target_bill_rate_flag,bill_rate_flag) -- FP M Dev effort
        -- bug 3505736  , nvl(l_target_cost_rate_flag,cost_rate_flag) -- FP M Dev effort
        -- bug 3505736  , nvl(l_target_burd_rate_flag,burden_rate_flag) -- FP M Dev effort
                 , bill_rate_flag                                  -- bug 3505736
                 , nvl(l_target_cost_rate_flag,l_cost_rate_flag)   -- bug 3505736
                 , nvl(l_target_burd_rate_flag,l_burden_rate_flag) -- bug 3505736
             INTO  l_revenue_flag
                 , l_revenue_qty_flag
                 , l_raw_cost_flag
                 , l_burdened_cost_flag
                 , l_bill_rate_flag      -- FP M Dev effort
                 , l_cost_rate_flag      -- FP M Dev effort
                 , l_burden_rate_flag    -- FP M Dev effort
             FROM pa_fin_plan_amount_sets
            WHERE fin_plan_amount_set_id = l_revenue_amount_set_id ;
    END IF;

    IF l_all_amount_set_id IS NOT NULL THEN
            SELECT raw_cost_flag
                 , burdened_cost_flag
                 , all_qty_flag
                 , revenue_flag
           -- bug 3505736    , nvl(l_target_bill_rate_flag,bill_rate_flag) -- FP M Dev effort
           -- bug 3505736    , nvl(l_target_cost_rate_flag,cost_rate_flag) -- FP M Dev effort
           -- bug 3505736    , nvl(l_target_burd_rate_flag,burden_rate_flag) -- FP M Dev effort
                 ,bill_rate_flag        -- bug 3505736
                 ,cost_rate_flag        -- bug 3505736
                 ,burden_rate_flag      -- bug 3505736
             INTO  l_raw_cost_flag
                 , l_burdened_cost_flag
                 , l_all_qty_flag
                 , l_revenue_flag
                 , l_bill_rate_flag      -- FP M Dev effort
                 , l_cost_rate_flag      -- FP M Dev effort
                 , l_burden_rate_flag    -- FP M Dev effort
             FROM  pa_fin_plan_amount_sets
            WHERE fin_plan_amount_set_id = l_all_amount_set_id ;
    END IF;

 /* reset all the amount set ids as their role is over */
 l_cost_amount_set_id := null;
 l_revenue_amount_set_id  := null;
 l_all_amount_set_id  := null;

  IF ( l_target_fin_plan_pref = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP) THEN

     /* If the FP Preference Code is Cost and Revenue Separately, then the
        COST and REVENUE columns have to be returned for all the valid combinations
        of Source and Target Fin_Plan_Preference_Code.
        manokuma: This can happen only in case of copy project when source and
                  target both will be sep. Hence no change  required here
     */

     IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage := 'Target Fin Plan Pref Code is Cost and Revenue separately.';
             pa_debug.write('Get_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

   -- Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------

     SELECT fin_plan_start_date
           ,fin_plan_end_date
           ,cost_amount_set_id
           ,revenue_amount_set_id
           ,NULL                        all_amount_set_id
           ,cost_fin_plan_level_code
           ,cost_time_phased_code
           ,cost_resource_list_id
           ,revenue_fin_plan_level_code
           ,revenue_time_phased_code
           ,revenue_resource_list_id
           ,NULL                        all_fin_plan_level_code
           ,NULL                        all_time_phased_code
           ,NULL                        all_resource_list_id
           ,nvl(report_labor_hrs_from_code,PA_FP_CONSTANTS_PKG.G_MARGIN_DERIVED_FROM_CODE_B) report_labor_hrs_from_code
           ,plan_in_multi_curr_flag
           ,factor_by_code
           ,default_amount_type_code
           ,default_amount_subtype_code
           ,margin_derived_from_code
           /* Bug 2920954 start of new record parameters for post fp-k oneoff patch */
           ,select_cost_res_auto_flag
           ,NULL                        cost_res_planning_level
           ,select_rev_res_auto_flag
           ,NULL                        revenue_res_planning_level
           ,NULL                        select_all_res_auto_flag
           ,NULL                        all_res_planning_level
           /* Bug 2920954 end of new record parameters for post fp-k oneoff patch */
           ,use_planning_rates_flag
           ,rbs_version_id
           ,res_class_raw_cost_sch_id
           ,res_class_bill_rate_sch_id
           ,cost_emp_rate_sch_id
           ,cost_job_rate_sch_id
           ,cost_non_labor_res_rate_sch_id
           ,cost_res_class_rate_sch_id
           ,cost_burden_rate_sch_id
           ,cost_current_planning_period
           ,cost_period_mask_id
           ,rev_emp_rate_sch_id
           ,rev_job_rate_sch_id
           ,rev_non_labor_res_rate_sch_id
           ,rev_res_class_rate_sch_id
           ,rev_current_planning_period
           ,rev_period_mask_id
           /*** Bug 3580727
           ,NULL                        all_emp_rate_sch_id
           ,NULL                        all_job_rate_sch_id
           ,NULL                        all_non_labor_res_rate_sch_id
           ,NULL                        all_res_class_rate_sch_id
           ,NULL                        all_burden_rate_sch_id
           ***/
           ,NULL                        all_current_planning_period
           ,NULL                        all_period_mask_id
           ,gen_cost_src_code
           ,gen_cost_etc_src_code
           ,gen_cost_incl_change_doc_flag
           ,gen_cost_incl_open_comm_flag
           ,gen_cost_ret_manual_line_flag
           ,gen_cost_incl_unspent_amt_flag
           ,gen_rev_src_code
           ,gen_rev_etc_src_code
           ,gen_rev_incl_change_doc_flag
           ,gen_rev_incl_bill_event_flag
           ,gen_rev_ret_manual_line_flag
           /*** Bug 3580727
           ,gen_rev_incl_unspent_amt_flag
           ***/
           ,gen_src_cost_plan_type_id
           ,gen_src_cost_plan_version_id
           ,gen_src_cost_plan_ver_code
           ,gen_src_rev_plan_type_id
           ,gen_src_rev_plan_version_id
           ,gen_src_rev_plan_ver_code
           ,NULL                        gen_src_all_plan_type_id
           ,NULL                        gen_src_all_plan_version_id
           ,NULL                        gen_src_all_plan_ver_code
           ,NULL                        gen_all_src_code
           ,NULL                        gen_all_etc_src_code
           ,NULL                        gen_all_incl_change_doc_flag
           ,NULL                        gen_all_incl_open_comm_flag
           ,NULL                        gen_all_ret_manual_line_flag
           ,NULL                        gen_all_incl_bill_event_flag
           ,NULL                        gen_all_incl_unspent_amt_flag
           ,gen_cost_actual_amts_thru_code
           ,gen_rev_actual_amts_thru_code
           ,NULL                        gen_all_actual_amts_thru_code
           ,track_workplan_costs_flag
           -- start of FP M dev phase II changes
           ,gen_src_cost_wp_version_id
           ,gen_src_cost_wp_ver_code
           ,gen_src_rev_wp_version_id
           ,gen_src_rev_wp_ver_code
           ,NULL                        gen_src_all_wp_version_id
           ,NULL                        gen_src_all_wp_ver_code
           -- end of FP M dev phase II changes
           -- Added for ms-excel options in webadi
           ,decode(p_target_fp_option_level_code,PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE,cost_layout_code,null)
           ,decode(p_target_fp_option_level_code,PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE,revenue_layout_code,null)
           ,NULL                        all_layout_code
           ,revenue_derivation_method  -- Bug 5462471
           ,copy_etc_from_plan_flag -- bug#8318932
      INTO x_fp_cols_rec
      FROM pa_proj_fp_options
     WHERE proj_fp_options_id = p_proj_fp_options_id;

   -- END: Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------

  ELSIF (l_target_fin_plan_pref = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY) THEN

     /* If the FP Preference Code is COST_ONLY, only the Cost Columns have to be sent
        and the other columns have to be returned as NULL. */

     /* Source                Target        Action
        ---------------------------------------------------------------------------
        COST_AND_REV_SAME     COST_ONLY     Copy "all" columns into "cost" columns.
        COST_ONLY             COST_ONLY     Copy "cost" to "cost"
        COST_AND_REV_SEP      COST_ONLY     Copy "cost" to "cost"
     */

     IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage := 'calling PA_FIN_PLAN_UTILS.GET_OR_CREATE_AMOUNT_SET_ID.';
             pa_debug.write('Get_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

     PA_FIN_PLAN_UTILS.GET_OR_CREATE_AMOUNT_SET_ID
     (
              p_raw_cost_flag           =>  l_raw_cost_flag
             ,p_burdened_cost_flag      =>  l_burdened_cost_flag
             ,p_revenue_flag            =>  'N'
             ,p_cost_qty_flag           =>  nvl(l_cost_qty_flag,l_all_qty_flag)
             ,p_revenue_qty_flag        =>  'N'
             ,p_all_qty_flag            =>  'N'
             ,p_bill_rate_flag          =>  'N'
             ,p_cost_rate_flag          =>  l_cost_rate_flag
             ,p_burden_rate_flag        =>  l_burden_rate_flag
             ,p_plan_pref_code          =>  l_target_fin_plan_pref
             ,x_cost_amount_set_id      =>  l_cost_amount_set_id
             ,x_revenue_amount_set_id   =>  l_revenue_amount_set_id
             ,x_all_amount_set_id       =>  l_all_amount_set_id
             ,x_message_count           =>  l_msg_count
             ,x_return_status           =>  x_return_status
             ,x_message_data            =>  l_msg_data);

     --added for bug 2708782
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;

     IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage := 'Target Fin Plan Pref Code is Cost Only.';
             pa_debug.write('Get_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;


   -- Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------

     SELECT fin_plan_start_date         fin_plan_start_date
           ,fin_plan_end_date           fin_plan_end_date
           ,l_cost_amount_set_id        cost_amount_set_id
           ,NULL                        revenue_amount_set_id
           ,NULL                        all_amount_set_id
           ,nvl(cost_fin_plan_level_code, all_fin_plan_level_code) cost_fin_plan_level_code
           ,nvl(cost_time_phased_code,    all_time_phased_code)    cost_time_phased_code
           ,nvl(cost_resource_list_id,    all_resource_list_id)    cost_resource_list_id
           ,NULL                        revenue_fin_plan_level_code
           ,NULL                        revenue_time_phased_code
           ,NULL                        revenue_resource_list_id
           ,NULL                        all_fin_plan_level_code
           ,NULL                        all_time_phased_code
           ,NULL                        all_resource_list_id
           ,NULL                        report_labor_hrs_from_code
           ,plan_in_multi_curr_flag     plan_in_multi_curr_flag
           ,factor_by_code              factor_by_code
           ,default_amount_type_code    default_amount_type_code
           ,default_amount_subtype_code default_amount_subtype_code
           ,nvl(margin_derived_from_code,PA_FP_CONSTANTS_PKG.G_MARGIN_DERIVED_FROM_CODE_B) margin_derived_from_code
           /* Bug 2920954 start of new record parameters for post fp-k oneoff patch */
           ,nvl(select_cost_res_auto_flag,  select_all_res_auto_flag)    select_cost_res_auto_flag
           ,NULL                        cost_res_planning_level
           ,NULL                        select_rev_res_auto_flag
           ,NULL                        revenue_res_planning_level
           ,NULL                        select_all_res_auto_flag
           ,NULL                        all_res_planning_level
           /* Bug 2920954 end of new record parameters for post fp-k oneoff patch */
           ,use_planning_rates_flag
           ,rbs_version_id
           ,res_class_raw_cost_sch_id
           ,res_class_bill_rate_sch_id
           /*** Bug 3580727
           ,nvl(cost_emp_rate_sch_id,          all_emp_rate_sch_id)            cost_emp_rate_sch_id
           ,nvl(cost_job_rate_sch_id,          all_job_rate_sch_id)            cost_job_rate_sch_id
           ,nvl(cost_non_labor_res_rate_sch_id,all_non_labor_res_rate_sch_id)  cost_non_labor_res_rate_sch_id
           ,nvl(cost_res_class_rate_sch_id,    all_res_class_rate_sch_id)      cost_res_class_rate_sch_id
           ,nvl(cost_burden_rate_sch_id,       all_burden_rate_sch_id)         cost_burden_rate_sch_id
           ***/
           ,cost_emp_rate_sch_id
           ,cost_job_rate_sch_id
           ,cost_non_labor_res_rate_sch_id
           ,cost_res_class_rate_sch_id
           ,cost_burden_rate_sch_id
           ,nvl(cost_current_planning_period,  all_current_planning_period)    cost_current_planning_period
           ,nvl(cost_period_mask_id,           all_period_mask_id)             cost_period_mask_id
           ,NULL                        rev_emp_rate_sch_id
           ,NULL                        rev_job_rate_sch_id
           ,NULL                        rev_non_labor_res_rate_sch_id
           ,NULL                        rev_res_class_rate_sch_id
           ,NULL                        rev_current_planning_period
           ,NULL                        rev_period_mask_id
           /*** Bug 3580727
           ,NULL                        all_emp_rate_sch_id
           ,NULL                        all_job_rate_sch_id
           ,NULL                        all_non_labor_res_rate_sch_id
           ,NULL                        all_res_class_rate_sch_id
           ,NULL                        all_burden_rate_sch_id
           ***/
           ,NULL                        all_current_planning_period
           ,NULL                        all_period_mask_id
           ,nvl(gen_cost_src_code,             gen_all_src_code)              gen_cost_src_code
           ,nvl(gen_cost_etc_src_code,         gen_all_etc_src_code)          gen_cost_etc_src_code
           ,nvl(gen_cost_incl_change_doc_flag, gen_all_incl_change_doc_flag)  gen_cost_incl_change_doc_flag
           ,nvl(gen_cost_incl_open_comm_flag,  gen_all_incl_open_comm_flag)   gen_cost_incl_open_comm_flag
           ,nvl(gen_cost_ret_manual_line_flag, gen_all_ret_manual_line_flag)  gen_cost_ret_manual_line_flag
           ,nvl(gen_cost_incl_unspent_amt_flag,gen_all_incl_unspent_amt_flag) gen_cost_incl_unspent_amt_flag
           ,NULL                        gen_rev_src_code
           ,NULL                        gen_rev_etc_src_code
           ,NULL                        gen_rev_incl_change_doc_flag
           ,NULL                        gen_rev_incl_bill_event_flag
           ,NULL                        gen_rev_ret_manual_line_flag
           /*** Bug 3580727
           ,NULL                        gen_rev_incl_unspent_amt_flag
           ***/
           ,nvl(gen_src_cost_plan_type_id,     gen_src_all_plan_type_id)      gen_src_cost_plan_type_id
           ,nvl(gen_src_cost_plan_version_id,  gen_src_all_plan_version_id)   gen_src_cost_plan_version_id
           ,nvl(gen_src_cost_plan_ver_code,    gen_src_all_plan_ver_code)     gen_src_cost_plan_ver_code
           ,NULL                        gen_src_rev_plan_type_id
           ,NULL                        gen_src_rev_plan_version_id
           ,NULL                        gen_src_rev_plan_ver_code
           ,NULL                        gen_src_all_plan_type_id
           ,NULL                        gen_src_all_plan_version_id
           ,NULL                        gen_src_all_plan_ver_code
           ,NULL                        gen_all_src_code
           ,NULL                        gen_all_etc_src_code
           ,NULL                        gen_all_incl_change_doc_flag
           ,NULL                        gen_all_incl_open_comm_flag
           ,NULL                        gen_all_ret_manual_line_flag
           ,NULL                        gen_all_incl_bill_event_flag
           ,NULL                        gen_all_incl_unspent_amt_flag
           ,nvl(gen_cost_actual_amts_thru_code, gen_all_actual_amts_thru_code) gen_cost_actual_amts_thru_code
           ,NULL                        gen_rev_actual_amts_thru_code
           ,NULL                        gen_all_actual_amts_thru_code
           ,track_workplan_costs_flag
           -- start of FP M dev phase II changes
           ,nvl(gen_src_cost_wp_version_id,  gen_src_all_wp_version_id)   gen_src_cost_wp_version_id
           ,nvl(gen_src_cost_wp_ver_code,    gen_src_all_wp_ver_code)     gen_src_cost_wp_ver_code
           ,NULL                        gen_src_rev_wp_version_id
           ,NULL                        gen_src_rev_wp_ver_code
           ,NULL                        gen_src_all_wp_version_id
           ,NULL                        gen_src_all_wp_ver_code
           -- end of FP M dev phase II changes
           -- Added for ms-excel options in webadi
           ,decode(p_target_fp_option_level_code,PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE,nvl(cost_layout_code, all_layout_code ),null) cost_layout_code
           ,NULL                revenue_layout_code
           ,NULL                all_layout_code
           ,NULL  -- Bug 5462471 For cost only version revenue_derivation_method should be null always
           ,copy_etc_from_plan_flag --bug#8318932
      INTO x_fp_cols_rec
      FROM pa_proj_fp_options
     WHERE proj_fp_options_id = p_proj_fp_options_id;




   -- END: Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------

  ELSIF (l_target_fin_plan_pref = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY) THEN

     /* If the FP Preference Code is REVENUE_ONLY, only the Revenue Columns have to be sent
        and the other columns have to be returned as NULL. */

     /* Source                Target           Action
        ---------------------------------------------------------------------------------
        COST_AND_REV_SAME     REVENUE_ONLY     Copy "all" columns into "revenue" columns.
        REVENUE_ONLY          REVENUE_ONLY     Copy "revenue" to "revenue"
        COST_AND_REV_SEP      REVENUE_ONLY     Copy "revenue" to "revenue"
     */

     IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage := 'calling PA_FIN_PLAN_UTILS.GET_OR_CREATE_AMOUNT_SET_ID.';
              pa_debug.write('Get_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;


     PA_FIN_PLAN_UTILS.GET_OR_CREATE_AMOUNT_SET_ID
     (
              p_raw_cost_flag          => 'N'
             ,p_burdened_cost_flag     => 'N'
             ,p_revenue_flag           => l_revenue_flag
             ,p_cost_qty_flag          => 'N'
             ,p_revenue_qty_flag       => nvl(l_revenue_qty_flag,l_all_qty_flag)
             ,p_all_qty_flag           => 'N'
             ,p_bill_rate_flag         => l_bill_rate_flag
             ,p_cost_rate_flag         => 'N'
             ,p_burden_rate_flag       => 'N'
             ,p_plan_pref_code         => l_target_fin_plan_pref
             ,x_cost_amount_set_id     => l_cost_amount_set_id
             ,x_revenue_amount_set_id  => l_revenue_amount_set_id
             ,x_all_amount_set_id      => l_all_amount_set_id
             ,x_message_count          => l_msg_count
             ,x_return_status          => x_return_status
             ,x_message_data           => l_msg_data);

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;

  -- Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------

     SELECT fin_plan_start_date         fin_plan_start_date
           ,fin_plan_end_date           fin_plan_end_date
           ,NULL                        cost_amount_set_id
           ,l_revenue_amount_set_id     revenue_amount_set_id
           ,NULL                        all_amount_set_id
           ,NULL                        cost_fin_plan_level_code
           ,NULL                        cost_time_phased_code
           ,NULL                        cost_resource_list_id
           ,nvl(revenue_fin_plan_level_code, all_fin_plan_level_code) revenue_fin_plan_level_code
           ,nvl(revenue_time_phased_code,    all_time_phased_code)    revenue_time_phased_code
           ,nvl(revenue_resource_list_id,    all_resource_list_id)    revenue_resource_list_id
           ,NULL                        all_fin_plan_level_code
           ,NULL                        all_time_phased_code
           ,NULL                        all_resource_list_id
           ,NULL                        report_labor_hrs_from_code
           ,plan_in_multi_curr_flag     plan_in_multi_curr_flag
           ,factor_by_code              factor_by_code
           ,default_amount_type_code    default_amount_type_code
           ,default_amount_subtype_code default_amount_subtype_code
           ,null                        margin_derived_from_code
           /* Bug 2920954 start of new record parameters for post fp-k oneoff patch */
           ,NULL                        select_cost_res_auto_flag
           ,NULL                        cost_res_planning_level
           ,nvl(select_rev_res_auto_flag,     select_all_res_auto_flag) select_rev_res_auto_flag
           ,NULL                        revenue_res_planning_level
           ,NULL                        select_all_res_auto_flag
           ,NULL                        all_res_planning_level
           /* Bug 2920954 end of new record parameters for post fp-k oneoff patch */
             ,use_planning_rates_flag
             ,rbs_version_id
             ,res_class_raw_cost_sch_id
             ,res_class_bill_rate_sch_id
             ,NULL                        cost_emp_rate_sch_id
             ,NULL                        cost_job_rate_sch_id
             ,NULL                        cost_non_labor_res_rate_sch_id
             ,NULL                        cost_res_class_rate_sch_id
             ,NULL                        cost_burden_rate_sch_id
             ,NULL                        cost_current_planning_period
             ,NULL                        cost_period_mask_id
             /*** Bug 3580727
             ,nvl(rev_emp_rate_sch_id,            all_emp_rate_sch_id)           rev_emp_rate_sch_id
             ,nvl(rev_job_rate_sch_id,            all_job_rate_sch_id)           rev_job_rate_sch_id
             ,nvl(rev_non_labor_res_rate_sch_id,  all_non_labor_res_rate_sch_id) rev_non_labor_res_rate_sch_id
             ,nvl(rev_res_class_rate_sch_id,      all_res_class_rate_sch_id)     rev_res_class_rate_sch_id
             ***/
             ,rev_emp_rate_sch_id
             ,rev_job_rate_sch_id
             ,rev_non_labor_res_rate_sch_id
             ,rev_res_class_rate_sch_id
             ,nvl(rev_current_planning_period,    all_current_planning_period)   rev_current_planning_period
             ,nvl(rev_period_mask_id,             all_period_mask_id)            rev_period_mask_id
             /*** Bug 3580727
             ,NULL                        all_emp_rate_sch_id
             ,NULL                        all_job_rate_sch_id
             ,NULL                        all_non_labor_res_rate_sch_id
             ,NULL                        all_res_class_rate_sch_id
             ,NULL                        all_burden_rate_sch_id
             ***/
             ,NULL                        all_current_planning_period
             ,NULL                        all_period_mask_id
             ,NULL                        gen_cost_src_code
             ,NULL                        gen_cost_etc_src_code
             ,NULL                        gen_cost_incl_change_doc_flag
             ,NULL                        gen_cost_incl_open_comm_flag
             ,NULL                        gen_cost_ret_manual_line_flag
             ,NULL                        gen_cost_incl_unspent_amt_flag
             ,nvl(gen_rev_src_code,              gen_all_src_code)                gen_rev_src_code
             ,nvl(gen_rev_etc_src_code,          gen_all_etc_src_code)            gen_rev_etc_src_code
             ,nvl(gen_rev_incl_change_doc_flag,  gen_all_incl_change_doc_flag)    gen_rev_incl_change_doc_flag
             ,nvl(gen_rev_incl_bill_event_flag,  gen_all_incl_bill_event_flag)    gen_rev_incl_bill_event_flag
             ,nvl(gen_rev_ret_manual_line_flag,  gen_all_ret_manual_line_flag)    gen_rev_ret_manual_line_flag
             /*** Bug 3580727
             ,nvl(gen_rev_incl_unspent_amt_flag, gen_all_incl_unspent_amt_flag)   gen_rev_incl_unspent_amt_flag
             ***/
             ,NULL                        gen_src_cost_plan_type_id
             ,NULL                        gen_src_cost_plan_version_id
             ,NULL                        gen_src_cost_plan_ver_code
             ,nvl(gen_src_rev_plan_type_id,    gen_src_all_plan_type_id)          gen_src_rev_plan_type_id
             ,nvl(gen_src_rev_plan_version_id, gen_src_all_plan_version_id)       gen_src_rev_plan_version_id
             ,nvl(gen_src_rev_plan_ver_code,   gen_src_all_plan_ver_code)         gen_src_rev_plan_ver_code
             ,NULL                        gen_src_all_plan_type_id
             ,NULL                        gen_src_all_plan_version_id
             ,NULL                        gen_src_all_plan_ver_code
             ,NULL                        gen_all_src_code
             ,NULL                        gen_all_etc_src_code
             ,NULL                        gen_all_incl_change_doc_flag
             ,NULL                        gen_all_incl_open_comm_flag
             ,NULL                        gen_all_ret_manual_line_flag
             ,NULL                        gen_all_incl_bill_event_flag
             ,NULL                        gen_all_incl_unspent_amt_flag
             ,NULL                        gen_cost_actual_amts_thru_code
             ,nvl(gen_rev_actual_amts_thru_code, gen_all_actual_amts_thru_code)    gen_rev_actual_amts_thru_code
             ,NULL                        gen_all_actual_amts_thru_code
             ,track_workplan_costs_flag
             -- start of FP M dev phase II changes
             ,NULL                         gen_src_cost_wp_version_id
             ,NULL                         gen_src_cost_wp_ver_code
             ,nvl(gen_src_rev_wp_version_id,  gen_src_all_wp_version_id)     gen_src_rev_wp_version_id
             ,nvl(gen_src_rev_wp_ver_code,    gen_src_all_wp_ver_code)       gen_src_rev_wp_ver_code
             ,NULL                        gen_src_all_wp_version_id
             ,NULL                        gen_src_all_wp_ver_code
             -- end of FP M dev phase II changes
           -- Added for ms-excel options in webadi
           ,NULL                cost_layout_code
           ,decode(p_target_fp_option_level_code,PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE,nvl(revenue_layout_code, all_layout_code ) ,null) revenue_layout_code
           ,NULL                all_layout_code
           ,revenue_derivation_method  -- Bug 5462471
           ,NULL                copy_etc_from_plan_flag -- bug 8318932
      INTO x_fp_cols_rec
      FROM pa_proj_fp_options
     WHERE proj_fp_options_id = p_proj_fp_options_id;

  -- END: Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------

  ELSIF (l_target_fin_plan_pref = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME) THEN

     /* If the FP Preference Code is COST_AND_REV_SAME, only the "all" Columns have to be sent
        and the other columns have to be returned as NULL. */

     /* Source               Target              Action
        ---------------------------------------------------------------------------
        COST_ONLY            COST_AND_REV_SAME   Copy "cost" columns into "all" columns.
        REVENUE_ONLY         COST_AND_REV_SAME   Copy "revenue" to "all"
        COST_AND_REV_SAME    COST_AND_REV_SAME   Copy "all" to "all"
        COST_AND_REV_SEP     COST_AND_REV_SAME   Copy "cost" to "all"
     */

     IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage := 'calling PA_FIN_PLAN_UTILS.GET_OR_CREATE_AMOUNT_SET_ID.';
             pa_debug.write('Get_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

     PA_FIN_PLAN_UTILS.GET_OR_CREATE_AMOUNT_SET_ID
     (
              p_raw_cost_flag          => l_raw_cost_flag
             ,p_burdened_cost_flag     => l_burdened_cost_flag
             ,p_revenue_flag           => l_revenue_flag
             ,p_cost_qty_flag          => 'N'
             ,p_revenue_qty_flag       => 'N'
             ,p_all_qty_flag           => nvl(l_cost_qty_flag,nvl(l_revenue_qty_flag,l_all_qty_flag))
             ,p_bill_rate_flag         => l_bill_rate_flag
             ,p_cost_rate_flag         => l_cost_rate_flag
             ,p_burden_rate_flag       => l_burden_rate_flag
             ,p_plan_pref_code         => l_target_fin_plan_pref
             ,x_cost_amount_set_id     => l_cost_amount_set_id
             ,x_revenue_amount_set_id  => l_revenue_amount_set_id
             ,x_all_amount_set_id      => l_all_amount_set_id
             ,x_message_count          => l_msg_count
             ,x_return_status          => x_return_status
             ,x_message_data           => l_msg_data);

      --added for bug 2708782
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;

     IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage := 'Target Fin Plan Pref Code is Cost and Revenue together.';
             pa_debug.write('Get_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

     SELECT fin_plan_start_date         fin_plan_start_date
           ,fin_plan_end_date           fin_plan_end_date
           ,NULL                        cost_amount_set_id
           ,NULL                        revenue_amount_set_id
           ,l_all_amount_set_id         all_amount_set_id
           ,NULL                        cost_fin_plan_level_code
           ,NULL                        cost_time_phased_code
           ,NULL                        cost_resource_list_id
           ,NULL                        revenue_fin_plan_level_code
           ,NULL                        revenue_time_phased_code
           ,NULL                        revenue_resource_list_id
           ,nvl(cost_fin_plan_level_code,nvl(revenue_fin_plan_level_code,all_fin_plan_level_code)) all_fin_plan_level_code
           ,nvl(cost_time_phased_code,nvl(revenue_time_phased_code,all_time_phased_code)) all_time_phased_code
           ,nvl(cost_resource_list_id,nvl(revenue_resource_list_id,all_resource_list_id)) all_resource_list_id
           ,NULL                        report_labor_hrs_from_code
           ,plan_in_multi_curr_flag     plan_in_multi_curr_flag
           ,factor_by_code              factor_by_code
           ,default_amount_type_code    default_amount_type_code
           ,default_amount_subtype_code default_amount_subtype_code /* manoj */
           ,nvl(margin_derived_from_code,PA_FP_CONSTANTS_PKG.G_MARGIN_DERIVED_FROM_CODE_B) margin_derived_from_code
           /* Bug 2920954 start of new record parameters for post fp-k oneoff patch */
           ,NULL                        select_cost_res_auto_flag
           ,NULL                        cost_res_planning_level
           ,NULL                        select_rev_res_auto_flag
           ,NULL                        revenue_res_planning_level
           ,nvl(select_cost_res_auto_flag,nvl(select_rev_res_auto_flag  ,select_all_res_auto_flag)) select_all_res_auto_flag
           ,NULL                        all_res_planning_level
           /* Bug 2920954 end of new record parameters for post fp-k oneoff patch */
             ,use_planning_rates_flag
             ,rbs_version_id
             ,res_class_raw_cost_sch_id
             ,res_class_bill_rate_sch_id
             /*** Bug 3580727
             ,NULL                        cost_emp_rate_sch_id
             ,NULL                        cost_job_rate_sch_id
             ,NULL                        cost_non_labor_res_rate_sch_id
             ,NULL                        cost_res_class_rate_sch_id
             ,NULL                        cost_burden_rate_sch_id
             ***/
             ,cost_emp_rate_sch_id
             ,cost_job_rate_sch_id
             ,cost_non_labor_res_rate_sch_id
             ,cost_res_class_rate_sch_id
             ,cost_burden_rate_sch_id
             ,NULL                        cost_current_planning_period
             ,NULL                        cost_period_mask_id
             /*** Bug 3580727
             ,NULL                        rev_emp_rate_sch_id
             ,NULL                        rev_job_rate_sch_id
             ,NULL                        rev_non_labor_res_rate_sch_id
             ,NULL                        rev_res_class_rate_sch_id
             ***/
             ,rev_emp_rate_sch_id
             ,rev_job_rate_sch_id
             ,rev_non_labor_res_rate_sch_id
             ,rev_res_class_rate_sch_id
             ,NULL                        rev_current_planning_period
             ,NULL                        rev_period_mask_id
             /*** Bug 3580727
             ,nvl(cost_emp_rate_sch_id,nvl(rev_emp_rate_sch_id,                      all_emp_rate_sch_id))            all_emp_rate_sch_id
             ,nvl(cost_job_rate_sch_id,nvl(rev_job_rate_sch_id,                      all_job_rate_sch_id))            all_job_rate_sch_id
             ,nvl(cost_non_labor_res_rate_sch_id, nvl(rev_non_labor_res_rate_sch_id, all_non_labor_res_rate_sch_id))  all_non_labor_res_rate_sch_id
             ,nvl(cost_res_class_rate_sch_id,     nvl(rev_res_class_rate_sch_id,         all_res_class_rate_sch_id))  all_res_class_rate_sch_id
             ,nvl(cost_burden_rate_sch_id,  all_burden_rate_sch_id)   all_burden_rate_sch_id
             ***/
             ,nvl(cost_current_planning_period,   nvl(rev_current_planning_period,   all_current_planning_period))    all_current_planning_period
             ,nvl(cost_period_mask_id,            nvl(rev_period_mask_id,            all_period_mask_id))             all_period_mask_id
             ,NULL                        gen_cost_src_code
             ,NULL                        gen_cost_etc_src_code
             ,NULL                        gen_cost_incl_change_doc_flag
             ,NULL                        gen_cost_incl_open_comm_flag
             ,NULL                        gen_cost_ret_manual_line_flag
             ,NULL                        gen_cost_incl_unspent_amt_flag
             ,NULL                        gen_rev_src_code
             ,NULL                        gen_rev_etc_src_code
             ,NULL                        gen_rev_incl_change_doc_flag
             ,NULL                        gen_rev_incl_bill_event_flag
             ,NULL                        gen_rev_ret_manual_line_flag
             /*** Bug 3580727
             ,NULL                        gen_rev_incl_unspent_amt_flag
             ***/
             ,NULL                        gen_src_cost_plan_type_id
             ,NULL                        gen_src_cost_plan_version_id
             ,NULL                        gen_src_cost_plan_ver_code
             ,NULL                        gen_src_rev_plan_type_id
             ,NULL                        gen_src_rev_plan_version_id
             ,NULL                        gen_src_rev_plan_ver_code
             ,nvl(gen_src_cost_plan_type_id,nvl(gen_src_rev_plan_type_id,gen_src_all_plan_type_id))                   gen_src_all_plan_type_id
             ,nvl(gen_src_cost_plan_version_id,nvl(gen_src_rev_plan_version_id,gen_src_all_plan_version_id))          gen_src_all_plan_version_id
             ,nvl(gen_src_cost_plan_ver_code,nvl(gen_src_rev_plan_ver_code,gen_src_all_plan_ver_code))                gen_src_all_plan_ver_code
             ,nvl(gen_cost_src_code, nvl(gen_rev_src_code,gen_all_src_code))                                          gen_all_src_code
             ,nvl(gen_cost_etc_src_code, nvl(gen_rev_etc_src_code, gen_all_etc_src_code))                             gen_all_etc_src_code
             ,nvl(gen_cost_incl_change_doc_flag, nvl(gen_rev_incl_change_doc_flag, gen_all_incl_change_doc_flag))     gen_all_incl_change_doc_flag
             ,nvl(gen_cost_incl_open_comm_flag, gen_all_incl_open_comm_flag)    gen_all_incl_open_comm_flag
             ,nvl(gen_cost_ret_manual_line_flag,  nvl(gen_rev_ret_manual_line_flag, gen_all_ret_manual_line_flag))    gen_all_ret_manual_line_flag
             ,nvl(gen_rev_incl_bill_event_flag, gen_all_incl_bill_event_flag)   gen_all_incl_bill_event_flag
             /*** Bug 3580727
             ,nvl(gen_cost_incl_unspent_amt_flag, nvl(gen_rev_incl_unspent_amt_flag, gen_all_incl_unspent_amt_flag))  gen_all_incl_unspent_amt_flag
             ***/
             ,nvl(gen_cost_incl_unspent_amt_flag, gen_all_incl_unspent_amt_flag)  gen_all_incl_unspent_amt_flag
             ,NULL                        gen_cost_actual_amts_thru_code
             ,NULL                        gen_rev_actual_amts_thru_code
             ,nvl(gen_cost_actual_amts_thru_code, nvl(gen_rev_actual_amts_thru_code, gen_all_actual_amts_thru_code))  gen_all_actual_amts_thru_code
             ,track_workplan_costs_flag
             -- start of FP M dev phase II changes
             ,NULL                         gen_src_cost_wp_version_id
             ,NULL                         gen_src_cost_wp_ver_code
             ,NULL                         gen_src_rev_wp_version_id
             ,NULL                         gen_src_rev_wp_ver_code
             ,nvl(gen_src_cost_wp_version_id,nvl(gen_src_rev_wp_version_id,gen_src_all_wp_version_id)) gen_src_all_wp_version_id
             ,nvl(gen_src_cost_wp_ver_code,nvl(gen_src_rev_wp_ver_code,gen_src_all_wp_ver_code))       gen_src_all_wp_ver_code
             -- end of FP M dev phase II changes
           -- Added for ms-excel options in webadi
             ,NULL                cost_layout_code
             ,NULL                 revenue_layout_code
             ,decode(p_target_fp_option_level_code,PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE,nvl(cost_layout_code, nvl(revenue_layout_code ,all_layout_code)) ,null) all_layout_code
             ,revenue_derivation_method  -- Bug 5462471
             ,NULL                  copy_etc_from_plan_flag--bug#8318932
          INTO x_fp_cols_rec
          FROM pa_proj_fp_options
        WHERE proj_fp_options_id = p_proj_fp_options_id;

  END IF;

  IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage := 'End of Get_FP_Options';
          pa_debug.write('Get_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
          pa_debug.reset_err_stack;
  END IF;

EXCEPTION
  WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
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
      IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.reset_err_stack;
      END IF;
    RAISE;
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_PROJ_FP_OPTIONS_PUB.Get_FP_Options'
            ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('Get_FP_Options: ' || l_module_name,SQLERRM,5);
              pa_debug.write('Get_FP_Options: ' || l_module_name,pa_debug.G_Err_Stack,5);
              pa_debug.reset_err_stack;
        END IF;

        RAISE;
END Get_FP_Options;

/*============================================================================================
GET_PARENT_FP_OPTION_ID: This procedure returns the Parent FP Option ID for the parameter
p_proj_fp_options_id that is passed to this procedure.
-> If the option_level_code of the input proj_fp_option_id is PLAN_VERSION, then the proj fp
option id of it's parent (i.e FP Option ID of the Option Level Code PLAN_TYPE is returned for
the project_id and the plan_type_id of the input).
-> If the option_level_code of the input proj_fp_option_id is PLAN_TYPE, then the proj fp
option id of it's parent (i.e FP Option ID of the Option Level Code PROJECT is returned for
the project_id of the input).
============================================================================================*/
FUNCTION Get_Parent_FP_Option_ID(
         p_proj_fp_options_id  IN NUMBER ) RETURN PA_PROJ_FP_OPTIONS.PROJ_FP_OPTIONS_ID%TYPE is

l_fp_option_level_code   pa_proj_fp_options.FIN_PLAN_OPTION_LEVEL_CODE%TYPE;
l_proj_id                pa_proj_fp_options.PROJECT_ID%TYPE;
l_fp_type_id             pa_proj_fp_options.FIN_PLAN_TYPE_ID%TYPE;
x_proj_fp_options_id     pa_proj_fp_options.PROJ_FP_OPTIONS_ID%TYPE;
l_debug_mode             VARCHAR2(30);

BEGIN
    IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.set_err_stack('PA_PROJ_FP_OPTIONS_PUB.Get_Parent_FP_Option_ID');
            fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
            l_debug_mode := NVL(l_debug_mode, 'Y');
            pa_debug.set_process('PLSQL','LOG',l_debug_mode);
    END IF;

   SELECT fin_plan_option_level_code, project_id, fin_plan_type_id
     INTO l_fp_option_level_code, l_proj_id, l_fp_type_id
     FROM pa_proj_fp_options
    WHERE proj_fp_options_id = p_proj_fp_options_id;

    /* To get the Parent Option of a PLAN_VERSION, PLAN_TYPE option for the
       Project and Plan Type has to be selected.  */

    IF (l_fp_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION) THEN

     IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage := 'Option Level Code is PLAN_VERSION.';
             pa_debug.write('Get_Parent_FP_Option_ID: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

       SELECT proj_fp_options_id
         INTO x_proj_fp_options_id
         FROM pa_proj_fp_options
        WHERE fin_plan_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE
          AND project_id = l_proj_id
          AND fin_plan_type_id = l_fp_type_id;

    /* To get the Parent Option of a PLAN_TYPE, PROJECT option for the
       Project has to be selected.  */

     IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage := 'Option Level Code is PLAN_TYPE.';
             pa_debug.write('Get_Parent_FP_Option_ID: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

    ELSIF (l_fp_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE) THEN
       SELECT proj_fp_options_id
         INTO x_proj_fp_options_id
         FROM pa_proj_fp_options
        WHERE fin_plan_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PROJECT
          AND project_id = l_proj_id;

    END IF;

  IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'End of Get_Parent_FP_Option_ID';
        pa_debug.write('Get_Parent_FP_Option_ID: ' || l_module_name,pa_debug.g_err_stage,3);
        pa_debug.reset_err_stack;
  END IF;

  RETURN  x_proj_fp_options_id;

EXCEPTION

  /* If there is no parent found, then return the FP_Option_ID as NULL so that default
     values are created. */
  WHEN NO_DATA_FOUND THEN
        IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage := 'Parent not found, hence returning NULL proj_fp_option_id';
                pa_debug.write('Get_Parent_FP_Option_ID: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;
        RETURN NULL;

  WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_PROJ_FP_OPTIONS_PUB.Get_Parent_FP_Option_ID'
            ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Get_Parent_FP_Option_ID: ' || l_module_name,SQLERRM,5);
           pa_debug.write('Get_Parent_FP_Option_ID: ' || l_module_name,pa_debug.G_Err_Stack,5);
           pa_debug.reset_err_stack;
        END IF;
        RAISE;
END Get_Parent_FP_Option_ID;

/*============================================================================================
GET_FP_OPTION_ID: This procedure returns the Proj FP Option ID based on the input Project_ID,
Plan_Type_ID and the Plan_Version_ID.
The Option_Level_Code is determined using the input parameters. The Proj FP Option ID is then
got from the table PA_Proj_FP_Options by using the appropriate conditions based on the Option
Level Code. (i.e. if the Option Level Code is PROJECT, only the Project_ID is checked for
in the table etc.)
============================================================================================*/
FUNCTION Get_FP_Option_ID(
         p_project_id     IN NUMBER
         ,p_plan_type_id  IN NUMBER
         ,p_plan_version_id IN NUMBER) RETURN PA_PROJ_FP_OPTIONS.PROJ_FP_OPTIONS_ID%TYPE is

l_fp_option_level_code   pa_proj_fp_options.FIN_PLAN_OPTION_LEVEL_CODE%TYPE;
x_proj_fp_options_id     pa_proj_fp_options.PROJ_FP_OPTIONS_ID%TYPE;
l_debug_mode             VARCHAR2(30);

BEGIN

   IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.set_err_stack('PA_PROJ_FP_OPTIONS_PUB.Get_FP_Option_ID');
            fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
            l_debug_mode := NVL(l_debug_mode, 'Y');
            pa_debug.set_process('PLSQL','LOG',l_debug_mode);
   END IF;

   /* Depending on the input parameters, we get the Option_Level_Code of the FP Option. */

   IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage := 'Getting the value of Option Level code.';
           pa_debug.write('Get_FP_Option_ID: ' || l_module_name,pa_debug.g_err_stage,3);
   END IF;

   IF p_project_id IS NOT NULL  THEN
      IF p_plan_type_id IS NOT NULL THEN
         IF p_plan_version_id IS NOT NULL THEN
            l_fp_option_level_code := PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION;
         ELSE
            l_fp_option_level_code := PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE;
         END IF;
      ELSE
         l_fp_option_level_code := PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PROJECT;
      END IF;
   END IF;

   /* Following are the Select statements to get the Proj_FP_Options_ID depending on the Option Level
      Code. If the Option_Level_Code is Project, then only Project_ID has to be checked for. For
      'Plan_Type', both Project_ID and Plan_Type_ID have to be checked and for PLAN_VERSION, all the
      three - Project_ID,Plan_Type_ID,Plan_Version_ID have to be checked for. */

   IF (l_fp_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PROJECT) THEN

      SELECT proj_fp_options_id
        INTO x_proj_fp_options_id
        FROM pa_proj_fp_options
       WHERE project_id = p_project_id
         AND fin_plan_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PROJECT;

   ELSIF (l_fp_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE) THEN

         SELECT proj_fp_options_id
           INTO x_proj_fp_options_id
           FROM pa_proj_fp_options
          WHERE project_id = p_project_id
            AND fin_plan_type_id = p_plan_type_id
            AND fin_plan_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE;

   ELSIF (l_fp_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION) THEN

         SELECT proj_fp_options_id
           INTO x_proj_fp_options_id
           FROM pa_proj_fp_options
          WHERE project_id = p_project_id
            AND fin_plan_type_id = p_plan_type_id
            AND fin_plan_version_id = p_plan_version_id
            AND fin_plan_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION;

   END IF;

   IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage := 'End of Get_FP_Option_ID';
           pa_debug.write('Get_FP_Option_ID: ' || l_module_name,pa_debug.g_err_stage,3);
           pa_debug.reset_err_stack;
   END IF;
   RETURN  x_proj_fp_options_id;

EXCEPTION

  /* If there is no parent found, then return the FP_Option_ID as NULL so that default
     values are created. */
  WHEN NO_DATA_FOUND THEN
        IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage := 'Parent not found, hence returning NULL proj_fp_option_id';
                pa_debug.write('Get_FP_Option_ID: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;
        RETURN NULL;

  WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_PROJ_FP_OPTIONS_PUB.Get_FP_Option_ID'
            ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Get_FP_Option_ID: ' || l_module_name,SQLERRM,5);
           pa_debug.write('Get_FP_Option_ID: ' || l_module_name,pa_debug.G_Err_Stack,5);
           pa_debug.reset_err_stack;
        END IF;
        RAISE;
END Get_FP_Option_ID;

/*=====================================================================================
GET_DEFAULT_FP_OPTIONS: This procedure returns Default FP Option values based on the
input parameter which is the Target FinPlan Preference Code.
The values passed in the FP Options Columns depend on the Preference Code. Constants
are being used for the default values so that it becomes so that if the default values
have to be modified because of the business logic, then the change can be made at one
point.
Bug:- 2625872, If Project_Currency(PC) <>  Projfunc Currency (PFC), then multi_curr_flag
should be set to 'Y'.
Bug 2920954 :- Modified the function to return Null as the value for new columns in the
ouput record l_fp_cols_rec.



 r11.5 FP.M Developement ----------------------------------

  08-JAN-2004 jwhite     Bug 3362316  (HQ)
                         Extensively rewrote Get_Default_Fp_Options
                         - All FP_COLS selects from dual.
  23-JAN-2004 rravipat   FP M Dev effort Bug 3354518 (IDC)
                         The api has been modified to default values for new set of
                         columns introduced during FP M.
  05-MAY-2004 rravipat   Bug 3572548
                         generation source version code should be set based on the
                         source plan type's plan class code. If BUDGET, CURRENT_BASELINED
                         should be used else CURRENT_APPROVED should be used

  15-OCT-2004 rravipat   Bug 3934574 Oct 31st DHI enhancements
                         1) Include Commitments checkbox should always be checked by default
                         2) Default etc generation source for revenue options is
                            'Financial Plan'
  19-Sep-2004 dbora      Bug 4599508: R12 Changes. Refered pa_implemenations_all
                         instead of pa_implementations as a part of MOAC uptake.
=====================================================================================*/
FUNCTION Get_Default_FP_Options(
         p_fin_plan_preference_code  IN   VARCHAR2 ,
         p_target_project_id         IN   pa_projects_all.project_id%TYPE,
         p_plan_type_id              IN   pa_proj_fp_options.fin_plan_type_id%TYPE) RETURN FP_COLS is

/* Declaring Constants */
l_fin_plan_level_code      CONSTANT pa_proj_fp_options.ALL_FIN_PLAN_LEVEL_CODE%TYPE := 'L';
l_time_phased_code         CONSTANT pa_proj_fp_options.ALL_TIME_PHASED_CODE%TYPE := 'N';
l_factor_by_code           CONSTANT pa_proj_fp_options.FACTOR_BY_CODE%TYPE := '1';

l_fp_cols_rec              PA_PROJ_FP_OPTIONS_PUB.FP_COLS;

l_return_status   VARCHAR2(2000);
l_msg_count       NUMBER := 0;
l_msg_data        VARCHAR2(2000);
l_err_code        NUMBER := 0;
l_err_stack       VARCHAR2(2000);
l_err_stage       VARCHAR2(2000);
l_msg_index_out   NUMBER := 0;
l_data            VARCHAR2(2000);
l_debug_mode      VARCHAR2(30);

l_cost_amount_set_id       pa_proj_fp_options.COST_AMOUNT_SET_ID%TYPE;
l_revenue_amount_set_id    pa_proj_fp_options.REVENUE_AMOUNT_SET_ID%TYPE;
l_all_amount_set_id        pa_proj_fp_options.ALL_AMOUNT_SET_ID%TYPE;
l_uncategorized_res_id     pa_resource_lists_all_bg.RESOURCE_LIST_ID%TYPE;

--  Bug :- 2625872, changed l_multi_curr_flag from constant to variable
--l_multi_curr_flag          CONSTANT pa_proj_fp_options.PLAN_IN_MULTI_CURR_FLAG%TYPE  := 'N';
l_multi_curr_flag          pa_proj_fp_options.PLAN_IN_MULTI_CURR_FLAG%TYPE  := 'N';
l_projfunc_currency_code   pa_projects_all.projfunc_currency_code%TYPE;
l_project_currency_code    pa_projects_all.project_currency_code%TYPE;
l_dummy_currency_code      pa_projects_all.project_currency_code%TYPE;

/* added following local variables as part of changes due to autobaseline */
l_rev_fin_plan_level_code  pa_proj_fp_options.REVENUE_FIN_PLAN_LEVEL_CODE%TYPE := 'L';
l_autobaseline_flag        pa_projects_all.BASELINE_FUNDING_FLAG%TYPE := 'N';
l_proj_level_funding       pa_projects_all.PROJECT_LEVEL_FUNDING_FLAG%TYPE := 'N';
l_app_rev_plan_type_flag   pa_proj_fp_options.APPROVED_REV_PLAN_TYPE_FLAG%TYPE := 'N';

-- FP M Dev Effort Variables used for calling rate schedules util api
l_emp_sch_id             pa_proj_fp_options.cost_emp_rate_sch_id%TYPE;
l_cost_job_sch_id        pa_proj_fp_options.cost_job_rate_sch_id%TYPE;   -- Bug 3619687
l_revenue_job_sch_id     pa_proj_fp_options.rev_job_rate_sch_id%TYPE;    -- Bug 3619687
l_non_labor_sch_id       pa_proj_fp_options.cost_non_labor_res_rate_sch_id%TYPE;
l_burd_sch_id            pa_proj_fp_options.cost_burden_rate_sch_id%TYPE;
l_res_class_sch_id       pa_proj_fp_options.cost_res_class_rate_sch_id%TYPE;

--Adding the variables to get the default vaules for the seeded webadi layouts
l_non_periodic_budget_layout        VARCHAR2(30)    := 'NPE_BUDGET';
l_non_periodic_forecast_layout      VARCHAR2(30)    := 'NPE_FORECAST';
l_webadi_profile                    VARCHAR(1);

l_revenue_derivation_method     pa_proj_fp_options.revenue_derivation_method%TYPE; --Bug 5462471

CURSOR plan_type_info_cur (c_plan_type_id NUMBER) IS
SELECT  plan_class_code
       ,nvl(approved_cost_plan_type_flag,'N')  approved_cost_plan_type_flag
       ,nvl(approved_rev_plan_type_flag,'N')   approved_rev_plan_type_flag
       ,nvl(primary_cost_forecast_flag,'N')    primary_cost_forecast_flag
       ,nvl(primary_rev_forecast_flag,'N')     primary_rev_forecast_flag
       ,nvl(use_for_workplan_flag,'N')         use_for_workplan_flag
FROM   pa_fin_plan_types_b
WHERE  fin_plan_type_id  = c_plan_type_id;

plan_type_info_rec plan_type_info_cur%ROWTYPE;

CURSOR rbs_version_cur IS
    SELECT   hdrtl.name as name,
             ver1.rbs_version_id as rbs_version_id,
             ver1.rbs_header_id  as rbs_header_id
      FROM   pa_rbs_headers_b  hdrb,
             pa_rbs_headers_tl hdrtl,
             pa_rbs_versions_b ver1
      WHERE  sysdate between hdrb.effective_from_date and nvl(hdrb.effective_to_date,sysdate)
        AND  hdrtl.rbs_header_id = hdrb.rbs_header_id
        AND  hdrtl.language = USERENV('LANG')
        AND  ver1.rbs_header_id = hdrtl.rbs_header_id
 /*** 3711762
        AND  ver1.version_number = (select max(version_number)
                                      from pa_rbs_versions_b ver2
                                     where ver1.rbs_header_id =
                                                      ver2.rbs_header_id
                                       and ver2.status_code = 'FROZEN')
     3711762 ***/
        AND  ver1.current_reporting_flag = 'Y'  /*bug 3711762*/
    ORDER BY name asc;
rbs_version_rec  rbs_version_cur%ROWTYPE;

BEGIN

    IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.set_err_stack('PA_PROJ_FP_OPTIONS_PUB.Get_Default_FP_Options');
            fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
            l_debug_mode := NVL(l_debug_mode, 'Y');
            pa_debug.set_process('PLSQL','LOG',l_debug_mode);
    END IF;
    l_return_status := FND_API.G_RET_STS_SUCCESS;
-- begin: Bug 5941436: fnd_profile.value_specific('PA_FP_WEBADI_ENABLE'); has been changed with fnd_profile.value('PA_FP_WEBADI_ENABLE'); to perform less sqls and use caching and therefore to improve the performance
    -- Bug 6413612 : Added substr to fetch only 1 character of profile value
    l_webadi_profile := UPPER(SUBSTR(fnd_profile.value_specific('PA_FP_WEBADI_ENABLE'),1,1));
-- end: Bug 5941436
    IF  NVL(l_webadi_profile , 'N') <> 'Y' THEN
        l_non_periodic_budget_layout     := NULL;
        l_non_periodic_forecast_layout   := NULL;
    END IF;

    -- FP M Dev Effort open and fetch plan type info cur into a record
    IF p_plan_type_id IS NOT NULL THEN
        OPEN  plan_type_info_cur (p_plan_type_id);
        FETCH plan_type_info_cur INTO  plan_type_info_rec;
         IF plan_type_info_cur%NOTFOUND THEN
            Raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;
        CLOSE plan_type_info_cur;
    END IF;

   /* Bug 3106741 pa_implementations has been moved to subquery */

   /* Bug 4599508: R12- Getting the business group id into a local
    * variable corresponding to the org_id of the target project
    * as we need to replace pa_implementations with pa_implementaions_all
    * for MOAC uptake.
    */

    BEGIN
        SELECT R1.resource_list_id
        INTO   l_uncategorized_res_id
        FROM   pa_resource_lists_all_bg R1,
               pa_implementations_all pim,
               pa_projects_all prj
        WHERE  prj.project_id = p_target_project_id
        AND    pim.org_id = prj.org_id
        AND    R1.uncategorized_flag = 'Y'
        AND    R1.business_group_id = pim.business_group_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.g_err_stage := 'No uncat resource list found corresponding to the org_id';
                    pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
    END;

    PA_FIN_PLAN_UTILS.GET_OR_CREATE_AMOUNT_SET_ID(
        P_RAW_COST_FLAG                => 'Y',
        P_BURDENED_COST_FLAG           => 'Y',
        P_REVENUE_FLAG                 => 'Y',
        P_COST_QTY_FLAG                => 'Y',
        P_REVENUE_QTY_FLAG             => 'Y',
        P_ALL_QTY_FLAG                 => 'Y',
        P_BILL_RATE_FLAG               => 'Y',
        P_COST_RATE_FLAG               => 'Y',
        P_BURDEN_RATE_FLAG             => 'Y',
        P_PLAN_PREF_CODE               => p_fin_plan_preference_code,
        X_COST_AMOUNT_SET_ID           => l_cost_amount_set_id,
        X_REVENUE_AMOUNT_SET_ID        => l_revenue_amount_set_id,
        X_ALL_AMOUNT_SET_ID            => l_all_amount_set_id,
        X_MESSAGE_COUNT                => l_msg_count,
        X_RETURN_STATUS                => l_return_status,
        X_MESSAGE_DATA                 => l_msg_data);

    --added for bug 2708782
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

     /*  Following code is added in context of autobaseline */
        /*  Bug#2619022 */

    IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage := 'P-target_project_id : '||TO_CHAR(p_target_project_id)||' p_plan_type_id : '||TO_CHAR(p_plan_type_id);
            pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF p_target_project_id IS NOT NULL AND p_plan_type_id IS NOT NULL THEN

           IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.g_err_stage := 'Fetching funding level for project ';
                   pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
           END IF;

           SELECT NVL(baseline_funding_flag,'N')
                 ,NVL(approved_rev_plan_type_flag,'N')
             INTO l_autobaseline_flag
                 ,l_app_rev_plan_type_flag
             FROM pa_projects_all ppa
                 ,pa_fin_plan_types_b ptb
            WHERE ppa.project_id = p_target_project_id
              AND ptb.fin_plan_type_id = p_plan_type_id;

           IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.g_err_stage := 'Autobaseline flag : '||l_autobaseline_flag||
                                     ' Project level funding : '||l_proj_level_funding;
                   pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
           END IF;

    END IF;

    IF p_target_project_id IS NOT NULL AND p_plan_type_id IS NOT NULL AND
       l_autobaseline_flag = 'Y'  AND l_app_rev_plan_type_flag = 'Y' THEN
      -- Bug 2702000.
      -- Moved this piece of code from the previous if to this if so that the API check_funding_level
      -- is called only if the project is AB enabled and the PT is AR.
      --Bug#2675335
          --Code added to get the project level funding.
           pa_billing_core.check_funding_level(x_project_id       => p_target_project_id,
                                               x_funding_level    => l_proj_level_funding,
                                               x_err_code         => l_err_code,
                                               x_err_stage        => l_err_stage,
                                               x_err_stack        => l_err_stack);


           /* #2681045: Exception will be raised only if the error code that is being returned by
              the above call is SQL error and not a pre-defined one in the check_funding_level
              procedure. */
           IF (l_err_code < 0 OR l_err_code = 100) THEN
             IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.g_err_stage := 'Error returned by pa_billing_core.check_funding_level:Err_code:'
                                              || to_char(l_err_code) || ':Err_stage:' || l_err_stage
                                              || ':Err_stack' || l_err_stack;
                     pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.g_err_stage,5);
             END IF;
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;

           IF l_proj_level_funding = 'P' THEN
                l_rev_fin_plan_level_code := 'P';
           ELSE
                l_rev_fin_plan_level_code := 'T';
           END IF;
    ELSE
       l_rev_fin_plan_level_code := 'L'; /* default value */
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage := ' l_rev_fin_plan_level_code : '||l_rev_fin_plan_level_code
                                   ||' p_fin_plan_pref_code : '||p_fin_plan_preference_code;
            pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

   --+++   Start of changes for Bug :- 2625872   +++--
    -- Fetch the project and project functional currency codes of the project

    pa_budget_utils.Get_Project_Currency_Info(
                p_project_id                    => p_target_project_id
              , x_projfunc_currency_code        => l_projfunc_currency_code
              , x_project_currency_code         => l_project_currency_code
              , x_txn_currency_code             => l_dummy_currency_code
              , x_msg_count                     => l_msg_count
              , x_msg_data                      => l_msg_data
              , x_return_status                 => l_return_status);

    IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
            pa_debug.g_err_stage:= 'Could not obtain currency info for the project';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    -- If the project and project func currencies aren't equal
    -- set the multi currency flag to 'Y'

    IF  l_projfunc_currency_code <> l_project_currency_code THEN
            l_multi_curr_flag := 'Y';
    ELSE
            l_multi_curr_flag := 'N';
    END IF;
   --+++  End   of changes for Bug :- 2625872 +++--

    -- Initialize all the attributes that are not preference code dependent
    -- Commom for both project and plan type level records

    l_fp_cols_rec.fin_plan_start_date         :=  null;
    l_fp_cols_rec.fin_plan_end_date           :=  null;
    l_fp_cols_rec.plan_in_multi_curr_flag     :=  l_multi_curr_flag; -- MC flag as derived above
    l_fp_cols_rec.factor_by_code              :=  l_factor_by_code; -- value '1'

    /*** Bug 3731925
        -- FP M Phase II dev changes, rbs_version_id should be defaulted to the latest frozen
        -- version of first rbs header when available and effective rbs headers are ordered
        -- by header name in ascending order

        OPEN  rbs_version_cur;
            FETCH rbs_version_cur INTO rbs_version_rec;
            IF rbs_version_cur%NOTFOUND THEN
                l_fp_cols_rec.rbs_version_id        :=  null;  -- as no RBS have been defined yet
            ELSE
                l_fp_cols_rec.rbs_version_id        :=  rbs_version_rec.rbs_version_id;
            END IF;
        CLOSE rbs_version_cur;
    ***/

    -- Bug 3731925 FP M IB3 changes, default value for RBS would be null
    l_fp_cols_rec.rbs_version_id        :=  null;

    -- Initialize plan settings tab related values that are preferene code
    -- dependent

    IF (p_fin_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY) THEN

       IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage := 'Fin Plan Preference code is Cost Only.';
               pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

       l_fp_cols_rec.cost_amount_set_id            :=  l_cost_amount_set_id;
       l_fp_cols_rec.cost_fin_plan_level_code      :=  l_fin_plan_level_code;
       l_fp_cols_rec.cost_time_phased_code         :=  l_time_phased_code;
       l_fp_cols_rec.cost_resource_list_id         :=  l_uncategorized_res_id;

       l_fp_cols_rec.default_amount_type_code      :=  PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_COST;
       l_fp_cols_rec.default_amount_subtype_code   :=  PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_BURD_COST;
       l_fp_cols_rec.report_labor_hrs_from_code    :=  PA_FP_CONSTANTS_PKG.G_LABOR_HRS_FROM_CODE_COST;

       IF p_plan_type_id IS NOT NULL THEN
          l_fp_cols_rec.margin_derived_from_code   :=  PA_FP_CONSTANTS_PKG.G_MARGIN_DERIVED_FROM_CODE_B;
       END IF;

    ELSIF (p_fin_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY) THEN

       IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage := 'Fin Plan Preference code is Revenue Only.';
               pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

       l_fp_cols_rec.revenue_amount_set_id         :=  l_revenue_amount_set_id;
       l_fp_cols_rec.revenue_fin_plan_level_code   :=  l_rev_fin_plan_level_code;
       l_fp_cols_rec.revenue_time_phased_code      :=  l_time_phased_code;
       l_fp_cols_rec.revenue_resource_list_id      :=  l_uncategorized_res_id;

       l_fp_cols_rec.default_amount_type_code      :=  PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_REVENUE;
       l_fp_cols_rec.default_amount_subtype_code   :=  PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_REVENUE;
       l_fp_cols_rec.report_labor_hrs_from_code    :=  PA_FP_CONSTANTS_PKG.G_LABOR_HRS_FROM_CODE_REVENUE;

        --Bug 5462471
          l_revenue_derivation_method                 :=  PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(p_target_project_id);

          if l_revenue_derivation_method = 'C' then
                   l_fp_cols_rec.revenue_derivation_method     :=  'COST';
          elsif l_revenue_derivation_method = 'T' then
                   l_fp_cols_rec.revenue_derivation_method     :=  'WORK';
          elsif l_revenue_derivation_method = 'E' then
                   l_fp_cols_rec.revenue_derivation_method     :=  'EVENT';
           else
                   l_fp_cols_rec.revenue_derivation_method     :=   null;
           end if;



       IF p_plan_type_id IS NOT NULL THEN
          l_fp_cols_rec.margin_derived_from_code   :=  null; -- not applicable in this case
       END IF;

    ELSIF (p_fin_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME) THEN

       IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage := 'Fin Plan Preference code is Cost and Revenue together.';
               pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

       l_fp_cols_rec.all_amount_set_id             :=  l_all_amount_set_id;
       l_fp_cols_rec.all_fin_plan_level_code       :=  l_fin_plan_level_code;
       l_fp_cols_rec.all_time_phased_code          :=  l_time_phased_code;
       l_fp_cols_rec.all_resource_list_id          :=  l_uncategorized_res_id;

       l_fp_cols_rec.default_amount_type_code      :=  PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_COST;
       l_fp_cols_rec.default_amount_subtype_code   :=  PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_BURD_COST;
       l_fp_cols_rec.report_labor_hrs_from_code    :=  PA_FP_CONSTANTS_PKG.G_LABOR_HRS_FROM_CODE_COST;

          --Bug 5462471
          l_revenue_derivation_method                 :=  PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(p_target_project_id);

          if l_revenue_derivation_method = 'C' then
                   l_fp_cols_rec.revenue_derivation_method     :=  'COST';
          elsif l_revenue_derivation_method = 'T' then
                   l_fp_cols_rec.revenue_derivation_method     :=  'WORK';
          elsif l_revenue_derivation_method = 'E' then
                   l_fp_cols_rec.revenue_derivation_method     :=  'EVENT';
           else
                   l_fp_cols_rec.revenue_derivation_method     :=   null;
           end if;



       IF p_plan_type_id IS NOT NULL THEN
          l_fp_cols_rec.margin_derived_from_code   :=  PA_FP_CONSTANTS_PKG.G_MARGIN_DERIVED_FROM_CODE_B;
       END IF;

    ELSIF ( p_fin_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP) THEN

       IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage := 'Fin Plan Preference code is Cost and Revenue separately.';
               pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

       l_fp_cols_rec.cost_amount_set_id            :=  l_cost_amount_set_id;
       l_fp_cols_rec.cost_fin_plan_level_code      :=  l_fin_plan_level_code;
       l_fp_cols_rec.cost_time_phased_code         :=  l_time_phased_code;
       l_fp_cols_rec.cost_resource_list_id         :=  l_uncategorized_res_id;

       l_fp_cols_rec.revenue_amount_set_id         :=  l_revenue_amount_set_id;
       l_fp_cols_rec.revenue_fin_plan_level_code   :=  l_rev_fin_plan_level_code;
       l_fp_cols_rec.revenue_time_phased_code      :=  l_time_phased_code;
       l_fp_cols_rec.revenue_resource_list_id      :=  l_uncategorized_res_id;

       l_fp_cols_rec.report_labor_hrs_from_code    :=  PA_FP_CONSTANTS_PKG.G_LABOR_HRS_FROM_CODE_COST;
       l_fp_cols_rec.default_amount_type_code      :=  null;    /* Open Issue */
       l_fp_cols_rec.default_amount_subtype_code   :=  null;    /* Open Issue */

          --Bug 5462471
          l_revenue_derivation_method                 :=  PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(p_target_project_id);

          if l_revenue_derivation_method = 'C' then
                   l_fp_cols_rec.revenue_derivation_method     :=  'COST';
          elsif l_revenue_derivation_method = 'T' then
                   l_fp_cols_rec.revenue_derivation_method     :=  'WORK';
          elsif l_revenue_derivation_method = 'E' then
                   l_fp_cols_rec.revenue_derivation_method     :=  'EVENT';
           else
                   l_fp_cols_rec.revenue_derivation_method     :=   null;
           end if;


       IF p_plan_type_id IS NOT NULL THEN
          l_fp_cols_rec.margin_derived_from_code   :=  PA_FP_CONSTANTS_PKG.G_MARGIN_DERIVED_FROM_CODE_B;
       END IF;

    END IF;

    -- FP M Dev effort for workplan plan type case track_workplan_costs_flag should be set to 'N'
    -- In all other cases its null

    IF (p_plan_type_id IS NOT NULL) AND (plan_type_info_rec.use_for_workplan_flag = 'Y' ) THEN
        l_fp_cols_rec.track_workplan_costs_flag := 'N';
    ELSE
        l_fp_cols_rec.track_workplan_costs_flag := null;
    END IF;

    -- FP M Dev effort the following code takes care of populating default values for
    -- rate schedule related columns for plan type level option

    -- Default use_planning_rates_flag to 'N'
    l_fp_cols_rec.use_planning_rates_flag  := 'N';

    -- FP M Dev effort the following code takes care of populating default values for
    -- amount generation amounts related columns for plan type level option
    -- Note: In project level case, they are not applicable and thus populate as null

    IF (p_plan_type_id IS NOT NULL) AND (plan_type_info_rec.use_for_workplan_flag <> 'Y' ) THEN

         -- For both cost and cost and rev sep cases, cost generation options should be defaulted

         IF ((p_fin_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY)  OR
             (p_fin_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP) )
         THEN

              -- Separate processing based on plan class code
              IF (plan_type_info_rec.plan_class_code = PA_FP_CONSTANTS_PKG.G_PLAN_CLASS_BUDGET)
              THEN

                   IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.g_err_stage := 'fetching generation columns for cost';
                          pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
                   END IF;

                   -- Estimate to completion source code should be null

                   l_fp_cols_rec.gen_cost_etc_src_code           :=  null;
                   l_fp_cols_rec.gen_cost_incl_unspent_amt_flag  :=  null;
                   l_fp_cols_rec.gen_cost_actual_amts_thru_code  :=  null;

                   l_fp_cols_rec.gen_cost_incl_change_doc_flag   :=  'N';
                   l_fp_cols_rec.gen_cost_incl_open_comm_flag    :=  'Y'; -- Bug 3934574 (N -> Y)
                   l_fp_cols_rec.gen_cost_ret_manual_line_flag   :=  'N';

                   -- Source code should be defaulted to 'FINANCIAL_PLAN'
                   -- Plan version code should be set to  'CURRENT_BASELINED'

                   l_fp_cols_rec.gen_cost_src_code               :=   'FINANCIAL_PLAN';
                   -- Bug 3572548 l_fp_cols_rec.gen_src_cost_plan_ver_code      :=   'CURRENT_BASELINED';
                   l_fp_cols_rec.gen_src_cost_plan_version_id    :=   null;
                   l_fp_cols_rec.gen_src_cost_wp_ver_code        :=   null; -- FP M Phase II Dev effort
                   l_fp_cols_rec.gen_src_cost_wp_version_id      :=   null; -- FP M Phase II Dev effort

                   -- Population the two fields cost_layout_code in the l_fp_cols_rec for a budget.
                   l_fp_cols_rec.cost_layout_code := l_non_periodic_budget_layout;

                   -- plan type defaulting is as follows
                   -- 1) if approved cost plan type is added for project use it here
                   -- 2) else
                   --        the first plan type with pref code involving 'cost'
                   Begin
                     SELECT pt.fin_plan_type_id
                            ,DECODE(pt.plan_class_code,
                                        'BUDGET','CURRENT_BASELINED',
                                        'FORECAST','CURRENT_APPROVED')   -- Bug 3572548
                     INTO   l_fp_cols_rec.gen_src_cost_plan_type_id
                            ,l_fp_cols_rec.gen_src_cost_plan_ver_code   -- Bug 3572548
                     FROM   pa_proj_fp_options o
                            ,pa_fin_plan_types_b pt
                     WHERE  o.project_id = p_target_project_id
                     AND    o.fin_plan_option_level_code = 'PLAN_TYPE'
                     AND    o.fin_plan_type_id = pt.fin_plan_type_id
                     AND    nvl(pt.use_for_workplan_flag,'N') = 'N' -- bug 3429026
                     AND    o.approved_cost_plan_type_flag = 'Y'; --bug 5107742
                   Exception
                     When NO_DATA_FOUND Then
                        Begin
                            SELECT *
                            INTO   l_fp_cols_rec.gen_src_cost_plan_type_id
                                  ,l_fp_cols_rec.gen_src_cost_plan_ver_code  -- Bug 3572548
                            FROM
                                (SELECT pt.fin_plan_type_id
                                      ,DECODE(pt.plan_class_code,
                                              'BUDGET','CURRENT_BASELINED',
                                              'FORECAST','CURRENT_APPROVED')   -- Bug 3572548
                                FROM   pa_proj_fp_options o
                                       ,pa_fin_plan_types_vl pt
                                WHERE  o.project_id = p_target_project_id
                                AND    o.fin_plan_option_level_code = 'PLAN_TYPE'
                                AND    o.fin_plan_preference_code <> 'REVENUE_ONLY'
                                AND    nvl(pt.use_for_workplan_flag,'N') = 'N' -- bug 3429026
                                AND    o.fin_plan_type_id = pt.fin_plan_type_id
                                order by pt.name) a
                            WHERE ROWNUM = 1;
                        Exception
                          When NO_DATA_FOUND then
                             -- When there is no other plan type set plan type id to the same plan type
                             l_fp_cols_rec.gen_src_cost_plan_type_id := p_plan_type_id;     --UT
                             l_fp_cols_rec.gen_src_cost_plan_ver_code := 'CURRENT_BASELINED';  -- Bug 3572548
                          When others then
                            IF P_PA_DEBUG_MODE = 'Y' THEN
                               pa_debug.g_err_stage := 'execption while fetching default source cost plan type id when approved plan type is not available ';
                               pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
                            END IF;
                        End;
                     When others then
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                           pa_debug.g_err_stage := 'execption while fetching approved default source cost plan type id ';
                           pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
                        END IF;
                        Raise;
                   End;

              ELSE -- Forecast plan type

                   -- Estimate to completion source code should be 'RESOURCE_SCHEDULE'

                   l_fp_cols_rec.gen_cost_etc_src_code           :=  'RESOURCE_SCHEDULE';
                   l_fp_cols_rec.gen_cost_incl_unspent_amt_flag  :=  'N';
                   /*** Bug 3580542 Default value should be Current Period'
                   --l_fp_cols_rec.gen_cost_actual_amts_thru_code  :=  'PRIOR_PERIOD';
                   ***/
                   l_fp_cols_rec.gen_cost_actual_amts_thru_code  :=  'CURRENT_PERIOD';

                   l_fp_cols_rec.gen_cost_incl_change_doc_flag   :=  'N';
                   l_fp_cols_rec.gen_cost_incl_open_comm_flag    :=  'Y'; -- Bug 3934574 (N -> Y)
                   l_fp_cols_rec.gen_cost_ret_manual_line_flag   :=  'N';

                   -- Source related parameters would be null

                   l_fp_cols_rec.gen_cost_src_code               :=   null;
                   l_fp_cols_rec.gen_src_cost_plan_type_id       :=   null;
                   l_fp_cols_rec.gen_src_cost_plan_ver_code      :=   null;
                   l_fp_cols_rec.gen_src_cost_plan_version_id    :=   null;
                   l_fp_cols_rec.gen_src_cost_wp_ver_code        :=   null; -- FP M Phase II Dev effort
                   l_fp_cols_rec.gen_src_cost_wp_version_id      :=   null; -- FP M Phase II Dev effort

                   -- Population the two fields cost_layout_code in the l_fp_cols_rec for a forecast.
                   l_fp_cols_rec.cost_layout_code := l_non_periodic_forecast_layout;

              END IF; --  End of BUDGET/FORECAST
         END IF; -- cost or cost and rev sep case

         IF ((p_fin_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY)  OR
             (p_fin_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP) )
         THEN

              -- Separate processing based on plan class code
              IF (plan_type_info_rec.plan_class_code = PA_FP_CONSTANTS_PKG.G_PLAN_CLASS_BUDGET)
              THEN

                   -- Estimate to completion source code should be null

                   l_fp_cols_rec.gen_rev_etc_src_code           :=  null;
                   l_fp_cols_rec.gen_rev_actual_amts_thru_code  :=  null;

                   l_fp_cols_rec.gen_rev_incl_change_doc_flag   :=  'N';
                   l_fp_cols_rec.gen_rev_incl_bill_event_flag   :=  'N';
                   l_fp_cols_rec.gen_rev_ret_manual_line_flag   :=  'N';

                   -- Source code should be defaulted to 'FINANCIAL_PLAN'
                   l_fp_cols_rec.gen_rev_src_code               :=   'FINANCIAL_PLAN';
                   l_fp_cols_rec.gen_src_rev_plan_version_id    :=   null;
                   l_fp_cols_rec.gen_src_rev_wp_ver_code        :=   null; -- FP M Phase II Dev effort
                   l_fp_cols_rec.gen_src_rev_wp_version_id      :=   null; -- FP M Phase II Dev effort

                   -- Population the two fields revenue_layout_code in the l_fp_cols_rec for a budget.
                   l_fp_cols_rec.revenue_layout_code := l_non_periodic_budget_layout;

              ELSE -- Forecast plan type

                   -- Estimate to completion source code should be 'FINANCIAL_PLAN'

                   l_fp_cols_rec.gen_rev_etc_src_code           :=  'FINANCIAL_PLAN';
                   /*** Bug 3580542 Default value should be Current Period'
                   l_fp_cols_rec.gen_rev_actual_amts_thru_code  :=  'PRIOR_PERIOD';
                   ***/
                   l_fp_cols_rec.gen_rev_actual_amts_thru_code  :=  'CURRENT_PERIOD';

                   l_fp_cols_rec.gen_rev_incl_change_doc_flag   :=  'N';
                   l_fp_cols_rec.gen_rev_incl_bill_event_flag   :=  'N';
                   l_fp_cols_rec.gen_rev_ret_manual_line_flag   :=  'N';

                   -- Source related parameters would be null

                   l_fp_cols_rec.gen_rev_src_code               :=   null;
                   l_fp_cols_rec.gen_src_rev_plan_version_id    :=   null;
                   l_fp_cols_rec.gen_src_rev_wp_ver_code        :=   null; -- FP M Phase II Dev effort
                   l_fp_cols_rec.gen_src_rev_wp_version_id      :=   null; -- FP M Phase II Dev effort

                   -- Population the two fields revenue_layout_code in the l_fp_cols_rec for a forecast.
                   l_fp_cols_rec.revenue_layout_code := l_non_periodic_forecast_layout;

              END IF; --  End of BUDGET/FORECAST

              -- plan type defaulting is as follows
              -- 1) if approved cost plan type is added for project use it here
              -- 2) else
              --        the first plan type with pref code involving 'cost'
              Begin
                SELECT pt.fin_plan_type_id
                       ,DECODE(pt.plan_class_code,
                                   'BUDGET','CURRENT_BASELINED',
                                   'FORECAST','CURRENT_APPROVED')  -- Bug 3572548
                INTO   l_fp_cols_rec.gen_src_rev_plan_type_id
                       ,l_fp_cols_rec.gen_src_rev_plan_ver_code    -- Bug 3572548
                FROM   pa_proj_fp_options o
                       ,pa_fin_plan_types_b pt
                WHERE  o.project_id = p_target_project_id
                AND    o.fin_plan_option_level_code = 'PLAN_TYPE'
                AND    o.fin_plan_type_id = pt.fin_plan_type_id
                AND    nvl(pt.use_for_workplan_flag,'N') = 'N' -- bug 3429026
                AND    pt.approved_cost_plan_type_flag = 'Y';
                --Bug 3724132 AND    pt.approved_rev_plan_type_flag = 'Y';
              Exception
                When NO_DATA_FOUND Then
                   Begin
                       SELECT *
                       INTO   l_fp_cols_rec.gen_src_rev_plan_type_id
                             ,l_fp_cols_rec.gen_src_rev_plan_ver_code  -- Bug 3572548
                       FROM (
                           SELECT pt.fin_plan_type_id
                                 ,DECODE(pt.plan_class_code,
                                           'BUDGET','CURRENT_BASELINED',
                                           'FORECAST','CURRENT_APPROVED') -- Bug 3572548
                           FROM   pa_proj_fp_options o
                                  ,pa_fin_plan_types_vl pt
                           WHERE  o.project_id = p_target_project_id
                           AND    o.fin_plan_option_level_code = 'PLAN_TYPE'
                           AND    nvl(pt.use_for_workplan_flag,'N') = 'N' -- bug 3429026
                           AND    o.fin_plan_preference_code <> 'REVENUE_ONLY' -- bug 3666398 'COST_ONLY'
                           AND    o.fin_plan_type_id = pt.fin_plan_type_id
                           order by pt.name ) a
                       WHERE ROWNUM = 1;
                   Exception
                     When NO_DATA_FOUND then
                        -- Bug 3666398 revenue-only plan type can not be generation source
                        IF p_fin_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP THEN
                            -- When there is no other plan type set to the same plan type id being created
                            l_fp_cols_rec.gen_src_rev_plan_type_id := p_plan_type_id;
                            l_fp_cols_rec.gen_src_rev_plan_ver_code :=  'CURRENT_BASELINED';  -- Bug 3572548
                        END IF;
                     When others then
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.g_err_stage := 'execption while fetching default source
                               revenue plan type id when approved plan type is not available ';
                          pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
                       END IF;

                   End;
                When others then
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.g_err_stage := 'execption while fetching approved default source
                                        revenue plan type id ';
                      pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
                   END IF;
                   Raise;
              End;
         END IF; -- revenue or cost and rev sep

         IF (p_fin_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME)
         THEN

              -- Separate processing based on plan class code
              IF (plan_type_info_rec.plan_class_code = PA_FP_CONSTANTS_PKG.G_PLAN_CLASS_BUDGET)
              THEN

                   -- Estimate to completion source code should be null

                   l_fp_cols_rec.gen_all_etc_src_code           :=  null;
                   l_fp_cols_rec.gen_all_incl_unspent_amt_flag  :=  null;
                   l_fp_cols_rec.gen_all_actual_amts_thru_code  :=  null;

                   l_fp_cols_rec.gen_all_incl_change_doc_flag   :=  'N';
                   l_fp_cols_rec.gen_all_incl_open_comm_flag    :=  'Y'; -- Bug 3934574 (N -> Y)
                   l_fp_cols_rec.gen_all_incl_bill_event_flag   :=  'N';
                   l_fp_cols_rec.gen_all_ret_manual_line_flag   :=  'N';

                   -- Source code should be defaulted to 'FINANCIAL_PLAN'
                   -- Plan version code should be set to  'CURRENT_BASELINED'

                   l_fp_cols_rec.gen_all_src_code               :=   'FINANCIAL_PLAN';
                   -- Bug 3572548  l_fp_cols_rec.gen_src_all_plan_ver_code      :=   'CURRENT_BASELINED';
                   l_fp_cols_rec.gen_src_all_plan_version_id    :=   null;
                   l_fp_cols_rec.gen_src_all_wp_ver_code        :=   null; -- FP M Phase II Dev effort
                   l_fp_cols_rec.gen_src_all_wp_version_id      :=   null; -- FP M Phase II Dev effort

                   -- Population the two fields all_layout_code in the l_fp_cols_rec for a budget.
                   l_fp_cols_rec.all_layout_code := l_non_periodic_budget_layout;

                   -- plan type defaulting is as follows
                   -- 1) if approved cost plan type is added for project use it here
                   -- 2) else
                   --        the first plan type with pref code involving 'cost'
                   Begin
                     SELECT pt.fin_plan_type_id
                            ,DECODE(pt.plan_class_code,
                                        'BUDGET','CURRENT_BASELINED',
                                        'FORECAST','CURRENT_APPROVED') -- Bug 3572548
                     INTO   l_fp_cols_rec.gen_src_all_plan_type_id
                            ,l_fp_cols_rec.gen_src_all_plan_ver_code   -- Bug 3572548
                     FROM   pa_proj_fp_options o
                            ,pa_fin_plan_types_b pt
                     WHERE  o.project_id = p_target_project_id
                     AND    o.fin_plan_option_level_code = 'PLAN_TYPE'
                     AND    o.fin_plan_type_id = pt.fin_plan_type_id
                     AND    nvl(pt.use_for_workplan_flag,'N') = 'N' -- bug 3429026
                     --bug 3724132 AND    pt.approved_rev_plan_type_flag = 'Y'
                     AND    pt.approved_cost_plan_type_flag = 'Y';
                   Exception
                     When NO_DATA_FOUND Then
                        Begin
                             SELECT *
                             INTO   l_fp_cols_rec.gen_src_all_plan_type_id
                                   ,l_fp_cols_rec.gen_src_all_plan_ver_code   -- Bug 3572548
                             FROM
                                (SELECT pt.fin_plan_type_id
                                      ,DECODE(pt.plan_class_code,
                                                'BUDGET','CURRENT_BASELINED',
                                                'FORECAST','CURRENT_APPROVED')  -- Bug 3572548
                                FROM   pa_proj_fp_options o
                                       ,pa_fin_plan_types_vl pt
                                WHERE  o.project_id = p_target_project_id
                                AND    o.fin_plan_option_level_code = 'PLAN_TYPE'
                                AND    o.fin_plan_type_id = pt.fin_plan_type_id
                                AND    nvl(pt.use_for_workplan_flag,'N') = 'N' -- bug 3429026
                                AND    o.fin_plan_preference_code <> 'REVENUE_ONLY' -- bug 3666398
                                ORDER BY pt.name ) a
                             WHERE ROWNUM = 1;
                        Exception
                          When NO_DATA_FOUND then
                             -- When there is no other plan type set to the same plan type id being created
                             l_fp_cols_rec.gen_src_all_plan_type_id := p_plan_type_id;
                             l_fp_cols_rec.gen_src_all_plan_ver_code := 'CURRENT_BASELINED';  -- Bug 3572548
                          When others then
                            IF P_PA_DEBUG_MODE = 'Y' THEN
                               pa_debug.g_err_stage := 'execption while fetching default source
                                    all plan type id when approved plan type is not available ';
                               pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
                            END IF;

                        End;
                     When others then
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                           pa_debug.g_err_stage := 'execption while fetching approved default source
                                             all plan type id ';
                           pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
                        END IF;
                        Raise;
                   End;
              ELSE -- Forecast plan type

                   -- Estimate to completion source code should be 'RESOURCE_SCHEDULE'

                   l_fp_cols_rec.gen_all_etc_src_code           :=  'RESOURCE_SCHEDULE';
                   l_fp_cols_rec.gen_all_incl_unspent_amt_flag  :=  'N';
                   /*** Bug 3580542 Default value should be Current Period'
                   l_fp_cols_rec.gen_all_actual_amts_thru_code  :=  'PRIOR_PERIOD';
                   ***/
                   l_fp_cols_rec.gen_all_actual_amts_thru_code  :=  'CURRENT_PERIOD';

                   l_fp_cols_rec.gen_all_incl_change_doc_flag   :=  'N';
                   l_fp_cols_rec.gen_all_incl_open_comm_flag    :=  'Y'; -- Bug 3934574 (N -> Y)
                   l_fp_cols_rec.gen_all_incl_bill_event_flag   :=  'N';
                   l_fp_cols_rec.gen_all_ret_manual_line_flag   :=  'N';

                   -- Source related parameters would be null

                   l_fp_cols_rec.gen_all_src_code               :=   null;
                   l_fp_cols_rec.gen_src_all_plan_type_id       :=   null;
                   l_fp_cols_rec.gen_src_all_plan_ver_code      :=   null;
                   l_fp_cols_rec.gen_src_all_plan_version_id    :=   null;
                   l_fp_cols_rec.gen_src_all_wp_ver_code        :=   null; -- FP M Phase II Dev effort
                   l_fp_cols_rec.gen_src_all_wp_version_id      :=   null; -- FP M Phase II Dev effort

                   -- Population the two fields all_layout_code in the l_fp_cols_rec for a forecast.
                   l_fp_cols_rec.all_layout_code := l_non_periodic_forecast_layout;

              END IF; --  End of BUDGET/FORECAST

         END IF; -- ALL case
    ELSE -- workplan plan type

        -- generate columns do not have any significance for project level and workplan
        -- plan type records
        null;

    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage := 'End of Get_Default_FP_Options';
            pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
            pa_debug.reset_err_stack;
    END IF;

    RETURN l_fp_cols_rec;

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
            pa_debug.g_err_stage := l_data;
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.g_err_stage,5);
            END IF;
          END IF;
          pa_debug.g_err_stage:='Invalid Arguments Passed';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.g_err_stage,5);
             pa_debug.reset_err_stack;
          END IF;
          RAISE;
  WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_PROJ_FP_OPTIONS_PUB.Get_Default_FP_Options'
            ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Get_Default_FP_Options: ' || l_module_name,SQLERRM,5);
           pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.G_Err_Stack,5);
           pa_debug.reset_err_stack;
        END IF;
        RAISE;
END Get_Default_FP_Options;


/*===========================================================================================
  GET_FP_PROJ_MC_OPTIONS: This procedure returns Multi curr option details for FP Option ID
  passed along with the approved_cost_plan_type_flag and approved_rev_plan_type_flag
===========================================================================================*/
FUNCTION Get_FP_Proj_Mc_Options (p_proj_fp_options_id IN  NUMBER) Return FP_MC_COLS
   IS
  l_fp_mc_cols_rec              PA_PROJ_FP_OPTIONS_PUB.FP_MC_COLS;
BEGIN

     SELECT approved_cost_plan_type_flag
           ,approved_rev_plan_type_flag
           ,primary_cost_forecast_flag
           ,primary_rev_forecast_flag
           ,projfunc_cost_rate_type
           ,projfunc_cost_rate_date_type
           ,projfunc_cost_rate_date
           ,projfunc_rev_rate_type
           ,projfunc_rev_rate_date_type
           ,projfunc_rev_rate_date
           ,project_cost_rate_type
           ,project_cost_rate_date_type
           ,project_cost_rate_date
           ,project_rev_rate_type
           ,project_rev_rate_date_type
           ,project_rev_rate_date
      INTO l_fp_mc_cols_rec
      FROM pa_proj_fp_options
     WHERE proj_fp_options_id = p_proj_fp_options_id;

     RETURN l_fp_mc_cols_rec;
EXCEPTION
  WHEN OTHERS THEN
     RETURN Null;
END Get_Fp_Proj_Mc_Options;

/*===========================================================================================
  GET_FP_PLAN_TYPE_MC_OPTIONS: This procedure returns Multi currency option details for
  FP Option ID passed along with approved_cost_plan_type_flag and approved_rev_plan_type_flag
===========================================================================================*/
FUNCTION Get_FP_Plan_Type_Mc_Options (p_fin_plan_type_id IN  NUMBER) Return FP_MC_COLS
   IS
  l_fp_mc_cols_rec              PA_PROJ_FP_OPTIONS_PUB.FP_MC_COLS;
BEGIN
     SELECT approved_cost_plan_type_flag
           ,approved_rev_plan_type_flag
           ,primary_cost_forecast_flag
           ,primary_rev_forecast_flag
           ,projfunc_cost_rate_type
           ,projfunc_cost_rate_date_type
           ,projfunc_cost_rate_date
           ,projfunc_rev_rate_type
           ,projfunc_rev_rate_date_type
           ,projfunc_rev_rate_date
           ,project_cost_rate_type
           ,project_cost_rate_date_type
           ,project_cost_rate_date
           ,project_rev_rate_type
           ,project_rev_rate_date_type
           ,project_rev_rate_date
      INTO l_fp_mc_cols_rec
      FROM pa_fin_plan_types_b
     WHERE fin_plan_type_id = p_fin_plan_type_id;
     RETURN l_fp_mc_cols_rec;
EXCEPTION
  WHEN OTHERS THEN
     RETURN Null;
END Get_Fp_Plan_Type_Mc_Options;

/*
    Bug # 2618119.  This procedure is called in the context of a plan version.
    When the resource list and the time phasing of a plan version
    is changed in the Edit planning options page, it is updated in
    the fp options table for the version. More over the resource
    list id and the period profile id(if the time phasing is PA/GL)
    should be updated in the budget versions table. This procedure
    doesnot do anything if amounts exist for the version.

    Bug 3425122: From plan settings page the api would be called to synchronise
    the columns that are part of both pa_budget_versions and also pa_proj_fp_otions.
    They are resource_list_id, period_mask_id and current_planning_period.
    actual_amts_thru_period is a column present only in budget versions table. So,
    only this column is passed and rest of the values should be read from
    pa_proj_fp_options table

    Note: In FP M, period profile concept has been changed to period masks. Commenting
    all the related existing code
*/
procedure SYNCHRONIZE_BUDGET_VERSION
    (
         p_budget_version_id                IN     pa_budget_versions.budget_version_id%TYPE,
         x_return_status                    OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
         x_msg_count                        OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
         x_msg_data                         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    )
IS

    l_project_id                pa_budget_versions.project_id%TYPE;
    l_time_phased_code          pa_proj_fp_options.cost_time_phased_code%TYPE;
    l_resource_list_id          pa_proj_fp_options.all_resource_list_id%TYPE;
/*
    l_period_profile_id         pa_budget_versions.period_profile_id%TYPE;
    l_curr_period_profile_id    pa_budget_versions.period_profile_id%TYPE;
    l_period_type               pa_proj_period_profiles.plan_period_type%TYPE;
    l_curr_period_type          pa_proj_period_profiles.plan_period_type%TYPE;
    l_start_period              pa_proj_period_profiles.period_name1%TYPE;
    l_end_period                pa_proj_period_profiles.period_name1%TYPE;
    l_period_profile_type       pa_proj_period_profiles.period_profile_type%TYPE;
    l_period_set_name           pa_proj_period_profiles.period_set_name%TYPE;
    l_gl_period_type            pa_proj_period_profiles.gl_period_type%TYPE;
    l_plan_start_date           pa_proj_period_profiles.period1_start_date%TYPE;
    l_plan_end_date             pa_proj_period_profiles.period1_start_date%TYPE;
    l_number_of_periods         pa_proj_period_profiles.number_of_periods%TYPE;
*/
    l_update_flag           varchar2(1);

    l_msg_count       NUMBER := 0;
    l_data            VARCHAR2(2000);
    l_msg_data        VARCHAR2(2000);
    l_error_msg_code  VARCHAR2(30);
    l_msg_index_out   NUMBER;
    l_return_status   VARCHAR2(2000);
    l_debug_mode      VARCHAR2(30);

    CURSOR version_option_info_cur IS
    SELECT cost_period_mask_id,
           rev_period_mask_id,
           all_period_mask_id,
           cost_current_planning_period,
           rev_current_planning_period,
           all_current_planning_period,
           fin_plan_preference_code,
           cost_resource_list_id,
           revenue_resource_list_id,
           all_resource_list_id
    FROM   pa_proj_fp_options
    WHERE  fin_plan_version_id = p_budget_version_id;

    version_option_info_rec    version_option_info_cur%ROWTYPE;

BEGIN

    FND_MSG_PUB.initialize;
    IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.init_err_stack('PA_PROJ_FP_OPTIONS_PUB.SYNCHRONIZE_BUDGET_VERSION');
         fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
         l_debug_mode := NVL(l_debug_mode, 'Y');
         pa_debug.set_process('PLSQL','LOG',l_debug_mode);
    END IF;
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check if budget version id is null. if yes
    -- throw an error.

    IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage := 'Parameter Validation';
         pa_debug.write('SYNCHRONIZE_BUDGET_VERSION: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_budget_version_id IS NULL) THEN

         IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.g_err_stage := 'budget version id='||p_budget_version_id;
                 pa_debug.write('SYNCHRONIZE_BUDGET_VERSION: ' || l_module_name,pa_debug.g_err_stage,5);
         END IF;

         PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage := 'Parameter validation complete';
         pa_debug.write('SYNCHRONIZE_BUDGET_VERSION: ' || l_module_name,pa_debug.g_err_stage,3);
         pa_debug.g_err_stage := 'Check if amounts exist for this version';
         pa_debug.write('SYNCHRONIZE_BUDGET_VERSION: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    -- Open and fetch fin plan version info cur

    OPEN  version_option_info_cur;
    FETCH version_option_info_cur INTO version_option_info_rec;
    IF    version_option_info_cur%NOTFOUND THEN
         RAISE  PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;
    CLOSE version_option_info_cur;


/*
    IF(l_amount_exists = 'Y') THEN
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage := 'Amounts exist for this version - returning';
            pa_debug.write('SYNCHRONIZE_BUDGET_VERSION: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;
        return;
    END IF;
*/

    -- Updation of current planning period,period mask id and actuals thru period and resource list id is possible always
    -- for a working version

    IF (version_option_info_rec.fin_plan_preference_code = 'COST_ONLY') THEN
        UPDATE pa_budget_versions
        SET    current_planning_period =  version_option_info_rec.cost_current_planning_period
              ,period_mask_id  =  version_option_info_rec.cost_period_mask_id
---              ,actual_amts_thru_period = p_actual_amts_thru_period
              ,resource_list_id = version_option_info_rec.cost_resource_list_id
              ,record_version_number = record_version_number + 1
        WHERE budget_version_id = p_budget_version_id;
    ELSIF (version_option_info_rec.fin_plan_preference_code = 'REVENUE_ONLY') THEN
        UPDATE pa_budget_versions
        SET    current_planning_period = version_option_info_rec.rev_current_planning_period
              ,period_mask_id  = version_option_info_rec.rev_period_mask_id
---              ,actual_amts_thru_period = p_actual_amts_thru_period
              ,resource_list_id = version_option_info_rec.revenue_resource_list_id
              ,record_version_number = record_version_number + 1
        WHERE budget_version_id = p_budget_version_id;
    ELSIF (version_option_info_rec.fin_plan_preference_code = 'COST_AND_REV_SAME') THEN
        UPDATE pa_budget_versions
        SET    current_planning_period =  version_option_info_rec.all_current_planning_period
              ,period_mask_id  = version_option_info_rec.all_period_mask_id
---              ,actual_amts_thru_period = p_actual_amts_thru_period
              ,resource_list_id = version_option_info_rec.all_resource_list_id
              ,record_version_number = record_version_number + 1
        WHERE budget_version_id = p_budget_version_id;
    END IF;

/* Commented for Bug 3425122 changes
    -- Get the updated time phased code for the version.
    l_time_phased_code := pa_fin_plan_utils.Get_Time_Phased_code(p_fin_plan_version_id=>
                                p_budget_version_id);


    -- obtain the period type corresponding to the time phased code
    select decode(l_time_phased_code,
         PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_P,PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_PA,
                 PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_G,PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_GL,l_time_phased_code)
    into l_curr_period_type
    from dual;

    --Select the period profile for this version. Get the period profile period type
    --   of this period profile. If the time_phased_code(curr period type) and the period profile period type
    --   are different, then obtain the current period profile corresponding to the time
    --   phased code and stamp it on the budget versions table.


     BEGIN

    select period_profile_id,project_id
    into l_period_profile_id,l_project_id
    from pa_budget_versions
    where budget_version_id = p_budget_version_id;

     EXCEPTION

    WHEN NO_DATA_FOUND THEN
             IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.g_err_stage := 'Invalid budget version id='||p_budget_version_id;
                         pa_debug.write('SYNCHRONIZE_BUDGET_VERSION: ' || l_module_name,pa_debug.g_err_stage,5);
             END IF;

             PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                                  p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END;

      IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage := 'Determine if period profile to be updated.If yes get the id';
              pa_debug.write('SYNCHRONIZE_BUDGET_VERSION: ' || l_module_name,pa_debug.g_err_stage,3);
      END IF;

    IF (l_period_profile_id is NULL) THEN
        IF (l_curr_period_type in (PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_PA,
                       PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_GL)) THEN

             pa_prj_period_profile_utils.get_curr_period_profile_info(
                                   p_project_id         => l_project_id
                                  ,p_period_type        => l_curr_period_type
                                  ,p_period_profile_type=> PA_FP_CONSTANTS_PKG.G_PD_PROFILE_FIN_PLANNING
                                  ,x_period_profile_id  => l_curr_period_profile_id
                                  ,x_start_period       => l_start_period
                                  ,x_end_period         => l_end_period
                                  ,x_return_status      => l_return_status
                                  ,x_msg_count          => l_msg_count
                                  ,x_msg_data           => l_msg_data);

            l_update_flag := 'Y';

        ELSE -- period type is date range or none.

            l_curr_period_profile_id := NULL;
            l_update_flag := 'N';

        END IF; -- check for period type.

    ELSE -- period profile id is not null

        IF (l_curr_period_type not in (PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_PA,
                                               PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_GL)) THEN

            l_curr_period_profile_id := NULL;
                        l_update_flag := 'Y';

        ELSE    -- period type in PA/GL

            pa_prj_period_profile_utils.Get_Prj_Period_Profile_Dtls(
                          p_period_profile_id  => l_period_profile_id,
                          p_debug_mode         => 'N',
                          p_add_msg_in_stack   => 'Y',
                          x_period_profile_type=>l_period_profile_type,
                          x_plan_period_type   =>l_period_type,
                          x_period_set_name    =>l_period_set_name,
                          x_gl_period_type     =>l_gl_period_type ,
                          x_plan_start_date    =>l_plan_start_date,
                          x_plan_end_date      =>l_plan_end_date,
                          x_number_of_periods  =>l_number_of_periods,
              x_return_status      =>l_return_status,
                          x_msg_data           =>l_msg_data);

            IF ( l_period_type = l_curr_period_type ) THEN

                l_update_flag := 'N';

            ELSE -- time phasing has changed.

                 pa_prj_period_profile_utils.get_curr_period_profile_info(
                                   p_project_id         => l_project_id
                                  ,p_period_type        => l_curr_period_type
                                  ,p_period_profile_type=> PA_FP_CONSTANTS_PKG.G_PD_PROFILE_FIN_PLANNING
                                  ,x_period_profile_id  => l_curr_period_profile_id
                                  ,x_start_period       => l_start_period
                                  ,x_end_period         => l_end_period
                                  ,x_return_status      => l_return_status
                                  ,x_msg_count          => l_msg_count
                                  ,x_msg_data           => l_msg_data);

                             l_update_flag := 'Y';

            END IF; -- check for equality of period type.
        END IF;  -- check for period type not in PA/GL.

    END IF;   -- check for period profile id being null.

    IF l_update_flag = 'Y' THEN
        update pa_budget_versions
        set period_profile_id = l_curr_period_profile_id
        where budget_version_id = p_budget_version_id;

            IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.g_err_stage := 'period profile id updated : updated id -> '||to_char(l_curr_period_profile_id);
                        pa_debug.write('SYNCHRONIZE_BUDGET_VERSION: ' || l_module_name,pa_debug.g_err_stage,3);
            END IF;
    END IF;
*/
    IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage := 'Exit Synchronize_Budget_version';
            pa_debug.write('SYNCHRONIZE_BUDGET_VERSION: ' || l_module_name,pa_debug.g_err_stage,2);
            pa_debug.reset_err_stack;
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
           IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.g_err_stage:='Invalid Arguments Passed';
                   pa_debug.write('SYNCHRONIZE_BUDGET_VERSION: ' || l_module_name,pa_debug.g_err_stage,5);
                   pa_debug.reset_err_stack;
           END IF;
           RETURN;

     WHEN Others THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'PA_PROJ_FP_OPTIONS_PUB'
                                  ,p_procedure_name  => 'SYNCHRONIZE_BUDGET_VERSION');
          IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
                  pa_debug.write('SYNCHRONIZE_BUDGET_VERSION: ' || l_module_name,pa_debug.g_err_stage,5);
                  pa_debug.reset_err_stack;
          END IF;
          RAISE;
END SYNCHRONIZE_BUDGET_VERSION;

/*=====================================================================================
  This is a private api that would return gen src plan version id for a given option
  based on project id, target version type, gen src plan type id and gen src plan
  version code inputs

  23-JAN-2004 rravipat   FP M Dev effort Bug 3354518 (IDC)
                         Initial Creation
=====================================================================================*/
FUNCTION Gen_Src_Plan_Version_Id(
         p_target_project_id         IN   pa_projects_all.project_id%TYPE,
         p_target_version_type       IN   pa_budget_versions.version_type%TYPE,
         p_gen_src_plan_type_id      IN   pa_proj_fp_options.gen_src_cost_plan_type_id%TYPE,
         p_gen_src_plan_ver_code     IN   pa_proj_fp_options.gen_src_cost_plan_ver_code%TYPE)
RETURN pa_budget_versions.budget_version_id%TYPE is

l_return_status   VARCHAR2(2000);
l_msg_count       NUMBER := 0;
l_msg_data        VARCHAR2(2000);
l_err_code        NUMBER := 0;
l_err_stack       VARCHAR2(2000);
l_err_stage       VARCHAR2(2000);
l_msg_index_out   NUMBER := 0;
l_data            VARCHAR2(2000);
l_debug_mode      VARCHAR2(30);

l_dummy_options_id            pa_proj_fp_options.proj_fp_options_id%TYPE;
l_gen_src_plan_version_id     pa_budget_versions.budget_version_id%TYPE;

CURSOR src_plan_type_info_cur (c_fin_plan_type_id NUMBER, c_project_id NUMBER) IS
SELECT  fin_plan_preference_code
FROM    pa_proj_fp_options
WHERE   project_id = c_project_id
AND     fin_plan_type_id = c_fin_plan_type_id
AND     fin_plan_option_level_code = 'PLAN_TYPE';

src_plan_type_info_rec src_plan_type_info_cur%ROWTYPE;

BEGIN

    IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.set_err_stack('PA_PROJ_FP_OPTIONS_PUB.Gen_Src_Plan_Version_Id');
            fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
            l_debug_mode := NVL(l_debug_mode, 'Y');
            pa_debug.set_process('PLSQL','LOG',l_debug_mode);
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='Opening src_plan_type_info_cur';
        pa_debug.write('Gen_Src_Plan_Version_Id: ' || l_module_name,pa_debug.g_err_stage,5);
        pa_debug.g_err_stage:='p_target_project_id = '||p_target_project_id;
        pa_debug.write('Gen_Src_Plan_Version_Id: ' || l_module_name,pa_debug.g_err_stage,5);
        pa_debug.g_err_stage:='p_target_version_type = '|| p_target_version_type;
        pa_debug.write('Gen_Src_Plan_Version_Id: ' || l_module_name,pa_debug.g_err_stage,5);
        pa_debug.g_err_stage:='p_gen_src_plan_type_id = '|| p_gen_src_plan_type_id;
        pa_debug.write('Gen_Src_Plan_Version_Id: ' || l_module_name,pa_debug.g_err_stage,5);
        pa_debug.g_err_stage:='p_gen_src_plan_ver_code = '||p_gen_src_plan_ver_code;
        pa_debug.write('Gen_Src_Plan_Version_Id: ' || l_module_name,pa_debug.g_err_stage,5);
    END IF;

    OPEN  src_plan_type_info_cur(p_gen_src_plan_type_id, p_target_project_id);
    FETCH src_plan_type_info_cur INTO src_plan_type_info_rec;
     IF src_plan_type_info_cur%NOTFOUND THEN
       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;
    CLOSE src_plan_type_info_cur;

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='After Closing src_plan_type_info_cur';
        pa_debug.write('Gen_Src_Plan_Version_Id: ' || l_module_name,pa_debug.g_err_stage,5);
        pa_debug.g_err_stage:='src_plan_type_info_rec.fin_plan_preference_code = = '||src_plan_type_info_rec.fin_plan_preference_code;
        pa_debug.write('Gen_Src_Plan_Version_Id: ' || l_module_name,pa_debug.g_err_stage,5);
    END IF;

    IF (src_plan_type_info_rec.fin_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY ) OR
--       (src_plan_type_info_rec.fin_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY ) OR
--Commented the above condition for bug 4052619. The source plan type can never be REVENUE_ONLY
       (src_plan_type_info_rec.fin_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME )
    THEN
         -- For all these cases, preference code need not be passed as they
         -- can be derived in the called util apis

         IF p_gen_src_plan_ver_code IN ('CURRENT_BASELINED','CURRENT_APPROVED') THEN

               -- call util api to fetch current baselined version
               pa_fin_plan_utils.Get_Baselined_Version_Info(
                                p_project_id          =>    p_target_project_id
                               ,p_fin_plan_type_id    =>    p_gen_src_plan_type_id
                               ,p_version_type        =>    null
                               ,x_fp_options_id       =>    l_dummy_options_id
                               ,x_fin_plan_version_id =>    l_gen_src_plan_version_id
                               ,x_return_status       =>    l_return_status
                               ,x_msg_count           =>    l_msg_count
                               ,x_msg_data            =>    l_msg_data );
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
               END IF;

         ELSIF p_gen_src_plan_ver_code = 'CURRENT_WORKING' THEN

               -- call util api to fetch current working version
               pa_fin_plan_utils.Get_Curr_Working_Version_Info(
                                p_project_id          =>    p_target_project_id
                               ,p_fin_plan_type_id    =>    p_gen_src_plan_type_id
                               ,p_version_type        =>    null
                               ,x_fp_options_id       =>    l_dummy_options_id
                               ,x_fin_plan_version_id =>    l_gen_src_plan_version_id
                               ,x_return_status       =>    l_return_status
                               ,x_msg_count           =>    l_msg_count
                               ,x_msg_data            =>    l_msg_data );
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
               END IF;

         ELSIF p_gen_src_plan_ver_code IN ('ORIGINAL_APPROVED','ORIGINAL_BASELINED') THEN

               -- call util api to fetch current original version
               pa_fin_plan_utils.Get_Curr_Original_Version_Info(
                                p_project_id          =>    p_target_project_id
                               ,p_fin_plan_type_id    =>    p_gen_src_plan_type_id
                               ,p_version_type        =>    null
                               ,x_fp_options_id       =>    l_dummy_options_id
                               ,x_fin_plan_version_id =>    l_gen_src_plan_version_id
                               ,x_return_status       =>    l_return_status
                               ,x_msg_count           =>    l_msg_count
                               ,x_msg_data            =>    l_msg_data );
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
               END IF;

         END IF; -- p_gen_src_plan_ver_code

         IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage := 'End of Gen_Src_Plan_Version_Id';
              pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
              pa_debug.reset_err_stack;
         END IF;

         RETURN l_gen_src_plan_version_id;

    ELSE  -- src plan type is cost and rev sep case


        --Bug 4052619. If the source is COST_AND_REV_SEP then irrespective of the target version type, only the cost
        --source version should be found out since a version of type REVENUE can never be a generation source.

        IF p_gen_src_plan_ver_code IN ('CURRENT_BASELINED','CURRENT_APPROVED') THEN

              -- call util api to fetch current baselined version
              pa_fin_plan_utils.Get_Baselined_Version_Info(
                               p_project_id          =>    p_target_project_id
                              ,p_fin_plan_type_id    =>    p_gen_src_plan_type_id
                              ,p_version_type        =>    'COST'
                              ,x_fp_options_id       =>    l_dummy_options_id
                              ,x_fin_plan_version_id =>    l_gen_src_plan_version_id
                              ,x_return_status       =>    l_return_status
                              ,x_msg_count           =>    l_msg_count
                              ,x_msg_data            =>    l_msg_data );
              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
              END IF;

        ELSIF p_gen_src_plan_ver_code = 'CURRENT_WORKING' THEN

              -- call util api to fetch current working version
              pa_fin_plan_utils.Get_Curr_Working_Version_Info(
                               p_project_id          =>    p_target_project_id
                              ,p_fin_plan_type_id    =>    p_gen_src_plan_type_id
                              ,p_version_type        =>    'COST'
                              ,x_fp_options_id       =>    l_dummy_options_id
                              ,x_fin_plan_version_id =>    l_gen_src_plan_version_id
                              ,x_return_status       =>    l_return_status
                              ,x_msg_count           =>    l_msg_count
                              ,x_msg_data            =>    l_msg_data );
              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
              END IF;

        ELSIF p_gen_src_plan_ver_code  IN ('ORIGINAL_APPROVED','ORIGINAL_BASELINED') THEN

              -- call util api to fetch current original version
              pa_fin_plan_utils.Get_Curr_Original_Version_Info(
                               p_project_id          =>    p_target_project_id
                              ,p_fin_plan_type_id    =>    p_gen_src_plan_type_id
                              ,p_version_type        =>    'COST'
                              ,x_fp_options_id       =>    l_dummy_options_id
                              ,x_fin_plan_version_id =>    l_gen_src_plan_version_id
                              ,x_return_status       =>    l_return_status
                              ,x_msg_count           =>    l_msg_count
                              ,x_msg_data            =>    l_msg_data );
              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
              END IF;

        END IF; -- p_gen_src_plan_ver_code


        RETURN l_gen_src_plan_version_id;


        IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage := 'End of Gen_Src_Plan_Version_Id';
              pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
              pa_debug.reset_err_stack;
        END IF;


    END IF; -- src plan type preference code

    IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage := 'End of Gen_Src_Plan_Version_Id';
          pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
          pa_debug.reset_err_stack;
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
            pa_debug.g_err_stage := l_data;
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('Gen_Src_Plan_Version_Id: ' || l_module_name,pa_debug.g_err_stage,5);
            END IF;
          END IF;
          pa_debug.g_err_stage:='Invalid Arguments Passed';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('Gen_Src_Plan_Version_Id: ' || l_module_name,pa_debug.g_err_stage,5);
             pa_debug.reset_err_stack;
          END IF;
          RAISE;
  WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_PROJ_FP_OPTIONS_PUB.Gen_Src_Plan_Version_Id'
            ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Gen_Src_Plan_Version_Id: ' || l_module_name,SQLERRM,5);
           pa_debug.write('Gen_Src_Plan_Version_Id: ' || l_module_name,pa_debug.G_Err_Stack,5);
           pa_debug.reset_err_stack;
        END IF;
        RAISE;
END Gen_Src_Plan_Version_Id;

/*=====================================================================================
  This is a private api that would return gen src wokplan budget version id for a given
  option based on project id and gen src workplan version code inputs

  20-MAR-2004 rravipat   FP M Dev effort Phase II changes
                         Initial Creation
=====================================================================================*/
FUNCTION Gen_Src_WP_Version_Id(
         p_target_project_id         IN   pa_projects_all.project_id%TYPE,
         p_gen_src_wp_ver_code     IN   pa_proj_fp_options.gen_src_cost_wp_ver_code%TYPE)
RETURN pa_budget_versions.budget_version_id%TYPE is

l_return_status   VARCHAR2(2000);
l_msg_count       NUMBER := 0;
l_msg_data        VARCHAR2(2000);
l_err_code        NUMBER := 0;
l_err_stack       VARCHAR2(2000);
l_err_stage       VARCHAR2(2000);
l_msg_index_out   NUMBER := 0;
l_data            VARCHAR2(2000);
l_debug_mode      VARCHAR2(30);

l_gen_src_wp_ver_id  pa_budget_versions.budget_version_id%TYPE;

CURSOR last_published_wp_version_cur IS
  select bv.budget_version_id
    from pa_budget_versions bv,
         pa_proj_elem_ver_structure ver
   where bv.project_id = p_target_project_id
     and bv.wp_version_flag = 'Y'
     and bv.project_id = ver.project_id
     and bv.project_structure_version_id = ver.element_version_id
     and ver.LATEST_EFF_PUBLISHED_FLAG = 'Y';

CURSOR baselined_wp_version_cur IS
  select bv.budget_version_id
    from pa_budget_versions bv,
         pa_proj_elem_ver_structure ver
   where bv.project_id = p_target_project_id
     and bv.wp_version_flag = 'Y'
     and bv.project_id = ver.project_id
     and bv.project_structure_version_id = ver.element_version_id
    and ver.current_baseline_date is not null ;

CURSOR current_working_wp_version_cur IS
  select bv.budget_version_id
    from pa_budget_versions bv,
         pa_proj_elem_ver_structure ver
   where bv.project_id = p_target_project_id
     and bv.wp_version_flag = 'Y'
     and bv.project_id = ver.project_id
     and bv.project_structure_version_id = ver.element_version_id
     and ver.current_working_flag = 'Y';

BEGIN
    pa_debug.set_curr_function(
                p_function   =>'XX.XXXX'
               ,p_debug_mode => l_debug_mode );

    IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage := 'Start of Gen_Src_WP_Version_Id';
          pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF  p_gen_src_wp_ver_code = 'LAST_PUBLISHED' THEN

        OPEN  last_published_wp_version_cur;
        FETCH last_published_wp_version_cur INTO  l_gen_src_wp_ver_id;
        CLOSE last_published_wp_version_cur;

    ELSIF p_gen_src_wp_ver_code = 'BASELINED' THEN

        OPEN  baselined_wp_version_cur;
        FETCH baselined_wp_version_cur INTO  l_gen_src_wp_ver_id;
        CLOSE baselined_wp_version_cur;

    ELSIF p_gen_src_wp_ver_code = 'CURRENT_WORKING' THEN

        OPEN  current_working_wp_version_cur;
        FETCH current_working_wp_version_cur INTO  l_gen_src_wp_ver_id;
        CLOSE current_working_wp_version_cur;

    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage := 'End of Gen_Src_WP_Version_Id';
          pa_debug.write('Get_Default_FP_Options: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;
    pa_debug.reset_curr_function();

    RETURN  l_gen_src_wp_ver_id;

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
            pa_debug.g_err_stage := l_data;
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('Gen_Src_WP_Version_Id: ' || l_module_name,pa_debug.g_err_stage,5);
            END IF;
          END IF;
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:='Invalid Arguments Passed';
             pa_debug.write('Gen_Src_WP_Version_Id: ' || l_module_name,pa_debug.g_err_stage,5);
          END IF;
          pa_debug.reset_curr_function;
          RAISE;
  WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_PROJ_FP_OPTIONS_PUB.Gen_Src_WP_Version_Id'
            ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Gen_Src_WP_Version_Id: ' || l_module_name,SQLERRM,5);
           pa_debug.write('Gen_Src_WP_Version_Id: ' || l_module_name,pa_debug.G_Err_Stack,5);
        END IF;
        pa_debug.reset_curr_function;
        RAISE;
END Gen_Src_WP_Version_Id;


/*==================================================================================
This procedure is used to create the seeded view for the periodic budget or forcasts
 The  selected amount types for the layout will be stored using this method.This will
 also be used to store the seeded amount types for the layouts.

  06-Apr-2005 prachand   Created as a part of WebAdi changes.
                            Initial Creation
 ===================================================================================*/

PROCEDURE Create_amt_types (
           p_project_id             IN       pa_projects_all.project_id%TYPE
          ,p_fin_plan_type_id       IN       pa_fin_plan_types_b.fin_plan_type_id%TYPE
          ,p_plan_preference_code   IN       pa_proj_fp_options.fin_plan_preference_code%TYPE
          ,p_cost_layout_code       IN       pa_proj_fp_options.cost_layout_code%TYPE
          ,p_revenue_layout_code    IN       pa_proj_fp_options.revenue_layout_code%TYPE
          ,p_all_layout_code        IN       pa_proj_fp_options.all_layout_code%TYPE
          ,x_return_status          OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count              OUT      NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data               OUT      NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
          ) IS

    l_plan_class_code               pa_fin_plan_types_b.plan_class_code%TYPE;
    l_cost_amount_types_tbl         SYSTEM.pa_varchar2_30_tbl_type  :=SYSTEM.pa_varchar2_30_tbl_type();
    l_rev_amount_types_tbl          SYSTEM.pa_varchar2_30_tbl_type  :=SYSTEM.pa_varchar2_30_tbl_type();
    l_all_amount_types_tbl          SYSTEM.pa_varchar2_30_tbl_type  :=SYSTEM.pa_varchar2_30_tbl_type();
    l_cost_layout_type_code         VARCHAR2(30);
    l_revenue_layout_type_code      VARCHAR2(30);
    l_all_layout_type_code          VARCHAR2(30);
    l_debug_mode                    VARCHAR2(30);
    l_stage                         NUMBER        := 100;
    l_module_name                   VARCHAR2(100) := 'pa.plsql.pa_proj_fp_options_pub';
    P_PA_DEBUG_MODE                 VARCHAR2(1)   := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
    l_msg_count                     NUMBER :=0;
    l_msg_data                      VARCHAR2(2000);
    l_data                          VARCHAR2(2000);
    l_msg_index_out                 NUMBER;
    l_layout_name                   VARCHAR2(2000);
    l_return_status                 VARCHAR2(2000);

    TYPE Dynamic_cur is REF CURSOR;
    layout_details_cur              Dynamic_cur;
    l_sql                           VARCHAR(3000) :=   'SELECT  '||
                                                       '      integrator_code ' ||
                                                        ' FROM   bne_layouts_b '||
                                                        ' WHERE  layout_code =  :1  ' ||
                                                        ' AND application_id =  (SELECT application_id ' ||
                                                        ' FROM FND_APPLICATION ' ||
                                                        ' WHERE APPLICATION_SHORT_NAME = ''PA'') ' ; -- removed user_name as it not being used.
    l_integrator_code                          VARCHAR2(30);



BEGIN

    PA_DEBUG.Set_Curr_Function( p_function   => l_module_name,
                                p_debug_mode => l_debug_mode );

    IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.set_err_stack('PA_PROJ_FP_OPTIONS_PUB.Create_amt_types');
            fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
            l_debug_mode := NVL(l_debug_mode, 'Y');
            pa_debug.set_process('PLSQL','LOG',l_debug_mode);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_project_id IS NULL OR p_fin_plan_type_id IS NULL OR p_plan_preference_code IS NULL THEN

        l_stage := 340;
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Err - projectid or plan types id or pref code id is NULL';
            pa_debug.write('Create_FP_Option: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
        p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
        PA_DEBUG.Reset_Curr_Function;
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    --Delete the existing amount types for the project/plan types from pa_fp_proj_xl_amt_types
    DELETE FROM PA_FP_PROJ_XL_AMT_TYPES
    WHERE project_id = p_project_id
    AND fin_plan_type_id = p_fin_plan_type_id;
    --getting the plan class code

    SELECT plan_class_code
    INTO l_plan_class_code
    FROM pa_fin_plan_types_b
    WHERE fin_plan_type_id = p_fin_plan_type_id;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'p_cost_layout_code:: ' || p_cost_layout_code || '::p_revenue_layout_code::' || p_revenue_layout_code || '::p_all_layout_code::' || p_all_layout_code;
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
    END IF;


    --populating the seeded views

        IF (p_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY OR
           p_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP) THEN

        BEGIN
            IF p_cost_layout_code IS NULL THEN

                x_return_status := FND_API.G_RET_STS_ERROR;
                PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
                PA_DEBUG.Reset_Curr_Function;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            ELSE
                OPEN layout_details_cur FOR l_sql USING p_cost_layout_code;
                FETCH layout_details_cur INTO  l_integrator_code;

                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:= 'l_integrator_code' || l_integrator_code || '::l_layout_name::'|| l_layout_name;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                END IF;


                   IF l_integrator_code = 'FINPLAN_BUDGET_PERIODIC' THEN
                        l_cost_layout_type_code := 'PERIODIC_BUDGET';
                    ELSIF l_integrator_code = 'FINPLAN_BUDGET_NON_PERIODIC' THEN
                        l_cost_layout_type_code := 'NON_PERIODIC_BUDGET';
                    ELSIF l_integrator_code = 'FINPLAN_FORECAST_PERIODIC' THEN
                        l_cost_layout_type_code  := 'PERIODIC_FORECAST';
                    ELSIF l_integrator_code = 'FINPLAN_FORECAST_NON_PERIODIC' THEN
                        l_cost_layout_type_code  := 'NON_PERIODIC_FORECAST';
                    END IF;


--                 pa_fp_webadi_utils.get_layout_details
--                       (p_layout_code          =>    p_cost_layout_code
--                        ,p_integrator_code     =>    NULL
--                        ,x_layout_name         =>    l_layout_name
--                        ,x_layout_type_code    =>    l_cost_layout_type_code
--                        ,x_return_status       =>    l_return_status
--                        ,x_msg_count           =>    l_msg_count
--                        ,x_msg_data            =>    l_msg_data );
--
--
--                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
--                  raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
--                END IF;
            END IF;
            IF l_cost_layout_type_code = 'PERIODIC_BUDGET' THEN

                l_cost_amount_types_tbl.extend(3);
                l_cost_amount_types_tbl(1) := 'TOTAL_QTY';
                l_cost_amount_types_tbl(2) := 'TOTAL_RAW_COST';
                l_cost_amount_types_tbl(3) := 'TOTAL_BURDENED_COST';

            ELSIF l_cost_layout_type_code = 'PERIODIC_FORECAST' THEN

                l_cost_amount_types_tbl.extend(6);
                l_cost_amount_types_tbl(1) := 'ETC_QTY';
                l_cost_amount_types_tbl(2) := 'FCST_QTY';
                l_cost_amount_types_tbl(3) := 'ETC_RAW_COST';
                l_cost_amount_types_tbl(4) := 'FCST_RAW_COST';
                l_cost_amount_types_tbl(5) := 'ETC_BURDENED_COST';
                l_cost_amount_types_tbl(6) := 'FCST_BURDENED_COST';

            END IF;
        END;
    END IF;

        IF (p_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY OR
           p_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP) THEN

        BEGIN
            IF p_revenue_layout_code IS NULL THEN

                x_return_status := FND_API.G_RET_STS_ERROR;
                PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
                PA_DEBUG.Reset_Curr_Function;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            ELSE
                OPEN layout_details_cur FOR l_sql USING p_revenue_layout_code;
                FETCH layout_details_cur INTO  l_integrator_code;

                   IF l_integrator_code = 'FINPLAN_BUDGET_PERIODIC' THEN
                        l_revenue_layout_type_code := 'PERIODIC_BUDGET';
                    ELSIF l_integrator_code = 'FINPLAN_BUDGET_NON_PERIODIC' THEN
                        l_revenue_layout_type_code := 'NON_PERIODIC_BUDGET';
                    ELSIF l_integrator_code = 'FINPLAN_FORECAST_PERIODIC' THEN
                        l_revenue_layout_type_code  := 'PERIODIC_FORECAST';
                    ELSIF l_integrator_code = 'FINPLAN_FORECAST_NON_PERIODIC' THEN
                        l_revenue_layout_type_code  := 'NON_PERIODIC_FORECAST';
                    END IF;

--                 pa_fp_webadi_utils.get_layout_details
--                       (p_layout_code          =>    p_revenue_layout_code
--                        ,p_integrator_code     =>    NULL
--                        ,x_layout_name         =>    l_layout_name
--                        ,x_layout_type_code    =>    l_cost_layout_type_code
--                        ,x_return_status       =>    l_return_status
--                        ,x_msg_count           =>    l_msg_count
--                        ,x_msg_data            =>    l_msg_data );
--
--                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
--                  raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
--                END IF;
            END IF;
            IF l_revenue_layout_type_code = 'PERIODIC_BUDGET' THEN

                l_rev_amount_types_tbl.extend(2);
                l_rev_amount_types_tbl(1) := 'TOTAL_QTY';
                l_rev_amount_types_tbl(2) := 'TOTAL_REV';

            ELSIF l_cost_layout_type_code = 'PERIODIC_FORECAST' THEN

                l_rev_amount_types_tbl.extend(4);
                l_rev_amount_types_tbl(1) := 'ETC_QTY';
                l_rev_amount_types_tbl(2) := 'FCST_QTY';
                l_rev_amount_types_tbl(3) := 'ETC_REVENUE';
                l_rev_amount_types_tbl(4) := 'FCST_REVENUE';

            END IF;
        END;
    END IF;

        IF p_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME THEN

        BEGIN
            IF p_all_layout_code IS NULL THEN


                x_return_status := FND_API.G_RET_STS_ERROR;
                PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
                PA_DEBUG.Reset_Curr_Function;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            ELSE

                OPEN layout_details_cur FOR l_sql USING p_all_layout_code;
                FETCH layout_details_cur INTO  l_integrator_code;

                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:= 'p_all_layout_code ::::::  ' || p_all_layout_code ;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                    pa_debug.g_err_stage:= 'l_layout_name ::::::  ' || l_layout_name;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                    pa_debug.g_err_stage:= 'l_integrator_code ::::::  ' || l_integrator_code;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                END IF;


                   IF l_integrator_code = 'FINPLAN_BUDGET_PERIODIC' THEN
                        l_all_layout_type_code := 'PERIODIC_BUDGET';
                    ELSIF l_integrator_code = 'FINPLAN_BUDGET_NON_PERIODIC' THEN
                        l_all_layout_type_code := 'NON_PERIODIC_BUDGET';
                    ELSIF l_integrator_code = 'FINPLAN_FORECAST_PERIODIC' THEN
                        l_all_layout_type_code  := 'PERIODIC_FORECAST';
                    ELSIF l_integrator_code = 'FINPLAN_FORECAST_NON_PERIODIC' THEN
                        l_all_layout_type_code := 'NON_PERIODIC_FORECAST';
                    END IF;


--                 pa_fp_webadi_utils.get_layout_details
--                       (p_layout_code          =>    p_all_layout_code
--                        ,p_integrator_code     =>    NULL
--                        ,x_layout_name         =>    l_layout_name
--                        ,x_layout_type_code    =>    l_cost_layout_type_code
--                        ,x_return_status       =>    l_return_status
--                        ,x_msg_count           =>    l_msg_count
--                        ,x_msg_data            =>    l_msg_data );
--
--                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
--                  raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
--                END IF;
            END IF;
            IF l_all_layout_type_code = 'PERIODIC_BUDGET' THEN

                l_all_amount_types_tbl.extend(4);
                l_all_amount_types_tbl(1) := 'TOTAL_QTY';
                l_all_amount_types_tbl(2) := 'TOTAL_RAW_COST';
                l_all_amount_types_tbl(3) := 'TOTAL_BURDENED_COST';
                l_all_amount_types_tbl(4) := 'TOTAL_REV';

            ELSIF l_all_layout_type_code = 'PERIODIC_FORECAST' THEN

                l_all_amount_types_tbl.extend(8);
                l_all_amount_types_tbl(1) := 'ETC_QTY';
                l_all_amount_types_tbl(2) := 'FCST_QTY';
                l_all_amount_types_tbl(3) := 'ETC_RAW_COST';
                l_all_amount_types_tbl(4) := 'FCST_RAW_COST';
                l_all_amount_types_tbl(5) := 'ETC_BURDENED_COST';
                l_all_amount_types_tbl(6) := 'FCST_BURDENED_COST';
                l_all_amount_types_tbl(7) := 'ETC_REVENUE';
                l_all_amount_types_tbl(8) := 'FCST_REVENUE';

            END IF;
        END;
    END IF;



    IF l_cost_amount_types_tbl.COUNT > 0 THEN

        IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Inserting cost seed values into pa_proj_fp_xl_amounts ';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;
        FORALL j IN l_cost_amount_types_tbl.FIRST..l_cost_amount_types_tbl.LAST
            INSERT INTO pa_fp_proj_xl_amt_types (
               project_id
               ,fin_plan_type_id
               ,option_type
               ,amount_type_code
               ,record_version_number
               ,last_update_date
               ,last_updated_by
               ,creation_date
               ,created_by
               ,last_update_login
               )
               VALUES
              ( p_project_id
              , p_fin_plan_type_id
              , PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST
              , l_cost_amount_types_tbl(j)
              , 1
              , sysdate
              , fnd_global.user_id
              , sysdate
              , fnd_global.user_id
              , fnd_global.login_id );
    ELSE

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Not a cost plan type';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;
    END IF;

    IF l_rev_amount_types_tbl.COUNT > 0 THEN

        IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Inserting rev seed values into pa_proj_fp_xl_amounts ';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;
        FORALL j IN l_rev_amount_types_tbl.FIRST..l_rev_amount_types_tbl.LAST
            INSERT INTO pa_fp_proj_xl_amt_types (
               project_id
               ,fin_plan_type_id
               ,option_type
               ,amount_type_code
               ,record_version_number
               ,last_update_date
               ,last_updated_by
               ,creation_date
               ,created_by
               ,last_update_login
               )
               VALUES
              ( p_project_id
              , p_fin_plan_type_id
              , PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE
              , l_rev_amount_types_tbl(j)
              , 1
              , sysdate
              , fnd_global.user_id
              , sysdate
              , fnd_global.user_id
              , fnd_global.login_id );
    ELSE

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Not a rev plan type';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;
    END IF;

    IF l_all_amount_types_tbl.COUNT > 0 THEN

        IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Inserting all seed values into pa_proj_fp_xl_amounts ';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;

        FORALL j IN l_all_amount_types_tbl.FIRST..l_all_amount_types_tbl.LAST

            INSERT INTO pa_fp_proj_xl_amt_types (
               project_id
               ,fin_plan_type_id
               ,option_type
               ,amount_type_code
               ,record_version_number
               ,last_update_date
               ,last_updated_by
               ,creation_date
               ,created_by
               ,last_update_login
               )
               VALUES
              ( p_project_id
              , p_fin_plan_type_id
              , PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL
              , l_all_amount_types_tbl(j)
              , 1
              , sysdate
              , fnd_global.user_id
              , sysdate
              , fnd_global.user_id
              , fnd_global.login_id );

                IF l_debug_mode = 'Y' THEN
                    FOR j IN l_all_amount_types_tbl.FIRST..l_all_amount_types_tbl.LAST LOOP
                        pa_debug.g_err_stage:= 'Inserting all seed values ' || l_all_amount_types_tbl(j);
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                    END LOOP;
                END IF;


    ELSE

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Not a cost and rev same plan type';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;
    END IF;
    pa_debug.Reset_Curr_Function;

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
            pa_debug.g_err_stage := l_data;
            x_msg_data := l_data;
            x_msg_count := l_msg_count;
        ELSE
            x_msg_count := l_msg_count;
        END IF;
        IF p_pa_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Invalid Arguments Passed';
            pa_debug.write('Create_amt_types: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        pa_debug.reset_curr_function;
        RAISE;

     WHEN OTHERS THEN
         FND_MSG_PUB.add_exc_msg
                  ( p_pkg_name       => 'PA_PROJ_FP_OPTIONS_PUB' ||
                   'Create_amt_types'
                   ,p_procedure_name => PA_DEBUG.G_Err_Stack);
         pa_debug.g_err_stage := 'Unexpected error in Create_amt_types:';
         pa_debug.write('Create_amt_types: ' || l_module_name,pa_debug.g_err_stage,5);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         pa_debug.Reset_Curr_Function;
         RAISE;

END Create_amt_types;

/*==================================================================================
This procedure is used to copy the amount types for the periodic budget or forcasts
from an existing plan type The existing plan types amount types will be copied to the
new project or plan type when a copy is done.

  06-Apr-2005 prachand   Created as a part of WebAdi changes.
                            Initial Creation
 ===================================================================================*/

PROCEDURE  copy_amt_types (
           p_source_project_id             IN       pa_projects_all.project_id%TYPE
          ,p_source_fin_plan_type_id       IN       pa_fin_plan_types_b.fin_plan_type_id%TYPE
          ,p_target_project_id             IN       pa_projects_all.project_id%TYPE
          ,p_target_fin_plan_type_id       IN       pa_fin_plan_types_b.fin_plan_type_id%TYPE
          ,x_return_status                 OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                     OUT      NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                      OUT      NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
          ) IS

    l_stage                                     NUMBER          := 100;
    l_module_name                               VARCHAR2(100)   := 'pa.plsql.pa_proj_fp_options_pub.copy_amt_types';
    P_PA_DEBUG_MODE                             VARCHAR2(1)     := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
    --Start of variables used for debugging
    l_return_status                             VARCHAR2(1);
    l_msg_count                                 NUMBER := 0;
    l_msg_data                                  VARCHAR2(2000);
    l_data                                      VARCHAR2(2000);
    l_msg_index_out                             NUMBER;
    l_debug_mode                                VARCHAR2(30);
    l_debug_level3                    CONSTANT  NUMBER :=3;
    l_debug_level5                    CONSTANT  NUMBER :=5;


BEGIN
    PA_DEBUG.Set_Curr_Function( p_function   => l_module_name,
                                p_debug_mode => l_debug_mode );

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Validating input parameters';
        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
    END IF;


    IF p_source_project_id IS NULL OR
       p_source_fin_plan_type_id IS NULL OR
       p_target_project_id IS NULL OR
       p_target_fin_plan_type_id IS NULL THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='p_source_project_id is '||p_source_project_id;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
            pa_debug.g_err_stage:='p_source_fin_plan_type_id is '||p_source_fin_plan_type_id;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
            pa_debug.g_err_stage:='p_target_project_id is '||p_target_project_id;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
            pa_debug.g_err_stage:='p_target_fin_plan_type_id is '||p_target_fin_plan_type_id;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    INSERT INTO PA_FP_PROJ_XL_AMT_TYPES(
    project_id
    ,fin_plan_type_id
    ,option_type
    ,amount_type_code
    ,record_version_number
    ,last_update_date
    ,last_updated_by
    ,creation_date
    ,created_by
    ,last_update_login)
    SELECT p_target_project_id
    ,p_target_fin_plan_type_id
    ,option_type
    ,amount_type_code
    ,1
    ,sysdate
    ,fnd_global.user_id
    ,sysdate
    ,fnd_global.user_id
    ,fnd_global.user_id
    FROM PA_FP_PROJ_XL_AMT_TYPES WHERE
    project_id = p_source_project_id AND
    fin_plan_type_id = p_source_fin_plan_type_id ;

    PA_DEBUG.Reset_Curr_Function;

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
       pa_debug.reset_curr_function();

     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'pa_proj_fp_options_pub'
                               ,p_procedure_name  => 'copy_amt_types');

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
       END IF;
       -- reset curr function
       pa_debug.Reset_Curr_Function();
       RAISE;
END copy_amt_types;

-- This procedure is used to update the amount types for the periodic budget or forcasts of an existing plan type
PROCEDURE  update_amt_types (
           p_project_id                IN       pa_projects_all.project_id%TYPE
          ,p_fin_plan_type_id          IN       pa_fin_plan_types_b.fin_plan_type_id%TYPE
          ,p_add_cost_amt_types_tbl    IN       SYSTEM.pa_varchar2_30_tbl_type
          ,p_del_cost_amt_types_tbl    IN       SYSTEM.pa_varchar2_30_tbl_type
          ,p_add_rev_amt_types_tbl     IN       SYSTEM.pa_varchar2_30_tbl_type
          ,p_del_rev_amt_types_tbl     IN       SYSTEM.pa_varchar2_30_tbl_type
          ,p_add_all_amt_types_tbl     IN       SYSTEM.pa_varchar2_30_tbl_type
          ,p_del_all_amt_types_tbl     IN       SYSTEM.pa_varchar2_30_tbl_type
          ,x_return_status             OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                 OUT      NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                  OUT      NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
          ) IS

    l_stage             NUMBER := 100;
    l_module_name       VARCHAR2(100) := 'pa.plsql.pa_proj_fp_options_pub';
    P_PA_DEBUG_MODE     VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
    --Start of variables used for debugging
    l_return_status                             VARCHAR2(1);
    l_msg_count                                 NUMBER := 0;
    l_msg_data                                  VARCHAR2(2000);
    l_data                                      VARCHAR2(2000);
    l_msg_index_out                             NUMBER;
    l_debug_mode                                VARCHAR2(30);
    l_debug_level3                    CONSTANT  NUMBER :=3;
    l_debug_level5                    CONSTANT  NUMBER :=5;




BEGIN
    PA_DEBUG.Set_Curr_Function( p_function   => l_module_name,
                                p_debug_mode => l_debug_mode );

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Validating input parameters';
        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
    END IF;


    IF p_project_id IS NULL OR
       p_fin_plan_type_id IS NULL THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='p_project_id is '||p_project_id;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
            pa_debug.g_err_stage:='p_fin_plan_type_id is '||p_fin_plan_type_id;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    IF p_add_cost_amt_types_tbl.COUNT > 0 THEN

        IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Inserting cost amount types into pa_proj_fp_xl_amounts ';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;
        FORALL j in p_add_cost_amt_types_tbl.FIRST..p_add_cost_amt_types_tbl.LAST

            INSERT into pa_fp_proj_xl_amt_types (
            project_id
            ,fin_plan_type_id
            ,option_type
            ,amount_type_code
            ,record_version_number
            ,last_update_date
            ,last_updated_by
            ,creation_date
            ,created_by
            ,last_update_login )
           VALUES
          ( p_project_id
           ,p_fin_plan_type_id
           ,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST
           ,p_add_cost_amt_types_tbl(j)
           ,1
           ,sysdate
           ,fnd_global.user_id
           ,sysdate
           ,fnd_global.user_id
           ,fnd_global.user_id );
    END IF;

    IF p_del_cost_amt_types_tbl.COUNT > 0 THEN

        IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Deleting cost amount types from pa_proj_fp_xl_amounts ';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;
        FORALL j in p_del_cost_amt_types_tbl.FIRST..p_del_cost_amt_types_tbl.LAST

            DELETE FROM pa_fp_proj_xl_amt_types WHERE
            project_id = p_project_id AND
            fin_plan_type_id = p_fin_plan_type_id AND
            option_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST AND
            amount_type_code = p_del_cost_amt_types_tbl(j) ;
    END IF;

    IF p_add_rev_amt_types_tbl.COUNT > 0 THEN

        IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Inserting rev amount types into pa_proj_fp_xl_amounts ';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;
        FORALL j in p_add_rev_amt_types_tbl.FIRST..p_add_rev_amt_types_tbl.LAST

            INSERT into pa_fp_proj_xl_amt_types (
            project_id
            ,fin_plan_type_id
            ,option_type
            ,amount_type_code
            ,record_version_number
            ,last_update_date
            ,last_updated_by
            ,creation_date
            ,created_by
            ,last_update_login )
           VALUES
          ( p_project_id
           ,p_fin_plan_type_id
           ,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE
           ,p_add_rev_amt_types_tbl(j)
           ,1
           ,sysdate
           ,fnd_global.user_id
           ,sysdate
           ,fnd_global.user_id
           ,fnd_global.user_id );
    END IF;

    IF p_del_rev_amt_types_tbl.COUNT > 0 THEN
        IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Deleting rev amount types from pa_proj_fp_xl_amounts ';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;
        FORALL j in p_del_rev_amt_types_tbl.FIRST..p_del_rev_amt_types_tbl.LAST

            DELETE FROM pa_fp_proj_xl_amt_types WHERE
            project_id = p_project_id AND
            fin_plan_type_id = p_fin_plan_type_id AND
            option_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE AND
            amount_type_code = p_del_rev_amt_types_tbl(j) ;
    END IF;

    IF p_add_all_amt_types_tbl.COUNT > 0 THEN
        IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Inserting all amount types into pa_proj_fp_xl_amounts ';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;
        IF l_debug_mode = 'Y' THEN
            FOR j in p_add_all_amt_types_tbl.FIRST..p_add_all_amt_types_tbl.LAST LOOP
                pa_debug.g_err_stage:= 'Inserting value:::: ' || p_add_all_amt_types_tbl(j) ;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END LOOP;
        END IF;

        FORALL j in p_add_all_amt_types_tbl.FIRST..p_add_all_amt_types_tbl.LAST

            INSERT into pa_fp_proj_xl_amt_types (
            project_id
            ,fin_plan_type_id
            ,option_type
            ,amount_type_code
            ,record_version_number
            ,last_update_date
            ,last_updated_by
            ,creation_date
            ,created_by
            ,last_update_login )
           VALUES
          ( p_project_id
           ,p_fin_plan_type_id
           ,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL
           ,p_add_all_amt_types_tbl(j)
           ,1
           ,sysdate
           ,fnd_global.user_id
           ,sysdate
           ,fnd_global.user_id
           ,fnd_global.user_id );


    END IF;

    IF p_del_all_amt_types_tbl.COUNT > 0 THEN
        IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Deleting all amount from pa_proj_fp_xl_amounts ';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;
        FORALL j in p_del_all_amt_types_tbl.FIRST..p_del_all_amt_types_tbl.LAST

            DELETE FROM pa_fp_proj_xl_amt_types WHERE
            project_id = p_project_id AND
            fin_plan_type_id = p_fin_plan_type_id AND
            option_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL AND
            amount_type_code = p_del_all_amt_types_tbl(j) ;
    END IF;
    PA_DEBUG.Reset_Curr_Function;
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
       pa_debug.reset_curr_function();

     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'pa_proj_fp_options_pub'
                               ,p_procedure_name  => 'update_amt_types');

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
       END IF;
       -- reset curr function
       pa_debug.Reset_Curr_Function();
       RAISE;

END update_amt_types;

END PA_PROJ_FP_OPTIONS_PUB;

/
