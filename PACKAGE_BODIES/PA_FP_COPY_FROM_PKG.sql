--------------------------------------------------------
--  DDL for Package Body PA_FP_COPY_FROM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_COPY_FROM_PKG" AS
/* $Header: PAFPCPFB.pls 120.20.12010000.5 2009/10/28 12:59:11 kmaddi ship $*/

g_plsql_max_array_size NUMBER := 200;
g_module_name VARCHAR2(100) := 'pa.plsql.pa_fp_copy_from_pkg';

-- Bug Fix: 4569365. Removed MRC code.
-- g_mrc_exception  EXCEPTION;

TYPE g_period_profile_tbl_typ IS TABLE OF
pa_budget_versions.period_profile_id%TYPE INDEX BY BINARY_INTEGER;

g_source_period_profile_tbl  g_period_profile_tbl_typ;
g_target_period_profile_tbl  g_period_profile_tbl_typ;


--Constants used for mapping (bug 3354518)
ELEMENT_TASK_MAP             CONSTANT VARCHAR2(30):='Element_Task_Map';
ELEMENT_ELEMENT_MAP          CONSTANT VARCHAR2(30):='Element_Element_Map';


/*========================================================================
  This procedure is used to acquie required locks for copy_plan
 =======================================================================*/

 P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE Acquire_Locks_For_Copy_Plan(
             p_source_plan_version_id    IN     NUMBER
             ,p_target_plan_version_id   IN     NUMBER
             ,x_return_status            OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_msg_count                OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
             ,x_msg_data                 OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 AS

       l_msg_count          NUMBER :=0;
       l_data               VARCHAR2(2000);
       l_msg_data           VARCHAR2(2000);
       l_msg_index_out      NUMBER;
       l_debug_mode         VARCHAR2(30);

       --rel_lock             NUMBER;
       --l_locked_by_person_id     pa_budget_versions.locked_by_person_id%TYPE;
       Resource_Busy             EXCEPTION;
       PRAGMA exception_init(Resource_Busy,-00054);

       CURSOR source_fp_opt_cur IS
            SELECT record_version_number
            FROM  PA_PROJ_FP_OPTIONS
            WHERE fin_plan_version_id = p_source_plan_version_id
            FOR UPDATE NOWAIT;

       CURSOR source_bdgt_vers_cur IS
            SELECT record_version_number
            FROM   PA_BUDGET_VERSIONS
            WHERE  budget_version_id = p_source_plan_version_id
            FOR UPDATE NOWAIT;

       CURSOR target_fp_opt_cur IS
            SELECT record_version_number
            FROM  PA_PROJ_FP_OPTIONS
            WHERE fin_plan_version_id = p_target_plan_version_id
            FOR UPDATE NOWAIT;

       CURSOR target_bdgt_vers_cur IS
            SELECT record_version_number
            FROM   PA_BUDGET_VERSIONS
            WHERE  budget_version_id = p_target_plan_version_id
            FOR UPDATE NOWAIT;
 BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.set_err_stack('Acquire_Locks_For_Copy_Plan');
END IF;
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
	IF P_PA_DEBUG_MODE = 'Y' THEN
	      pa_debug.set_process('PLSQL','LOG',l_debug_mode);
	END IF;
     /*
      * Acquire lock on pa_proj_fp_options and pa_budget_versions so that
      * no other process would be able to modify these tables and all
      * underlying child tables
      */

       IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:='Acquiring lock on pa_proj_fp_options';
            pa_debug.write('Acquire_Locks_For_Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,3);
       END IF;

       OPEN source_fp_opt_cur;

       OPEN target_fp_opt_cur;

       IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:='Acquiring lock on pa_budget_versions';
            pa_debug.write('Acquire_Locks_For_Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,3);
       END IF;

       OPEN source_bdgt_vers_cur;

       OPEN target_bdgt_vers_cur;

   /*
    * Increment the record_version_number of target version in
    * pa_budget_versions and pa_proj_fp_options
    */

   IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='Incrementing record version number of target version in pa_proj_fp_options';
        pa_debug.write('Acquire_Locks_For_Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,3);
   END IF;

   UPDATE PA_PROJ_FP_OPTIONS
   SET    record_version_number = record_version_number+1
   WHERE  fin_plan_version_id=p_target_plan_version_id;

   IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='Incrementing record version number of target version in pa_budget_versions';
        pa_debug.write('Acquire_Locks_For_Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,3);
   END IF;

   UPDATE PA_BUDGET_VERSIONS
   SET    record_version_number = record_version_number+1
   WHERE  budget_version_id = p_target_plan_version_id;

   IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='Closing all the cursors ';
        pa_debug.write('Acquire_Locks_For_Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,3);
   END IF;

   CLOSE target_bdgt_vers_cur;
   CLOSE source_bdgt_vers_cur;
   CLOSE target_fp_opt_cur;
   CLOSE source_fp_opt_cur;
IF P_PA_DEBUG_MODE = 'Y' THEN
   pa_debug.reset_err_stack;
END IF;
EXCEPTION
    WHEN Resource_Busy THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                               p_msg_name      => 'PA_UTIL_USER_LOCK_FAILED');

          IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:='Can not acquire lock.. exiting copy plan';
               pa_debug.write('Acquire_Locks_For_Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,5);
          END IF;

          IF source_fp_opt_cur%ISOPEN THEN
              CLOSE source_fp_opt_cur;
          END IF;

          IF source_bdgt_vers_cur%ISOPEN THEN
              CLOSE source_bdgt_vers_cur;
          END IF;

          IF target_fp_opt_cur%ISOPEN THEN
             CLOSE target_fp_opt_cur;
          END IF;

          IF target_bdgt_vers_cur%ISOPEN THEN
              CLOSE target_bdgt_vers_cur;
          END IF;

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

          x_return_status:= FND_API.G_RET_STS_ERROR;
	IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.reset_err_stack;
	END IF;
          RAISE;

    WHEN OTHERS THEN

          IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:='Can not acquire lock.. exiting copy plan';
               pa_debug.write('Acquire_Locks_For_Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,5);
          END IF;

          IF source_fp_opt_cur%ISOPEN THEN
              CLOSE source_fp_opt_cur;
          END IF;

          IF source_bdgt_vers_cur%ISOPEN THEN
              CLOSE source_bdgt_vers_cur;
          END IF;

          IF target_fp_opt_cur%ISOPEN THEN
             CLOSE target_fp_opt_cur;
          END IF;

          IF target_bdgt_vers_cur%ISOPEN THEN
              CLOSE target_bdgt_vers_cur;
          END IF;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_FP_COPY_FROM_PKG'
                                   ,p_procedure_name  => 'ACQUIRE_LOCKS_FOR_COPY_PLAN');
          IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
               pa_debug.write('Acquire_Locks_For_Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,5);

          pa_debug.reset_err_stack;
	END IF;
          RAISE;
 END Acquire_Locks_For_Copy_Plan;

  /* =======================================================================
     This is a main api which does the processing specific to copy
     plan and then will call copy_version and delete version helper apis.

     4/16/2004 Raja FP M Phase II Copy Plan does not copy 'rate schedules',
     and 'Generation Options' sub tab data.
   ========================================================================*/

  PROCEDURE Copy_Plan(
            p_source_plan_version_id    IN     NUMBER
            ,p_target_plan_version_id   IN     NUMBER
            ,p_adj_percentage           IN     NUMBER
            ,x_return_status            OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
            ,x_msg_count                OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
            ,x_msg_data                 OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
   AS

         l_adj_percentage     NUMBER;
         l_msg_count          NUMBER :=0;
         l_data               VARCHAR2(2000);
         l_msg_data           VARCHAR2(2000);
         l_error_msg_code     VARCHAR2(2000);
         l_msg_index_out      NUMBER;
         l_return_status      VARCHAR2(2000);
         l_debug_mode         VARCHAR2(30);

         l_source_fp_pref_code pa_proj_fp_options.fin_plan_preference_code%TYPE ;
         l_target_fp_pref_code pa_proj_fp_options.fin_plan_preference_code%TYPE ;
         --l_locked_by_person_id pa_budget_versions.locked_by_person_id%TYPE;
         l_project_id          pa_projects_all.project_id%TYPE;
         l_source_resource_list_id    pa_budget_versions.resource_list_id%TYPE;
         l_baselined_resource_list_id pa_budget_versions.resource_list_id%TYPE;

         --This variable contains the resource list id of baselined version

         l_baselined_version_id       pa_budget_versions.budget_version_id%TYPE;
         l_target_plan_version_id     pa_budget_versions.budget_version_id%TYPE;
         l_version_type               pa_budget_versions.version_type%TYPE;
         l_fin_plan_type_id           pa_budget_versions.fin_plan_type_id%TYPE;
         l_fp_options_id              pa_proj_fp_options.proj_fp_options_id%TYPE;
         l_target_appr_rev_plan_flag  pa_budget_versions.approved_rev_plan_type_flag%TYPE;

         -- Start of Variables defined for bug 2729498

         l_target_fin_plan_type_id     pa_budget_versions.fin_plan_type_id%TYPE;
         l_target_version_type        pa_budget_versions.version_type%TYPE;

         -- End of variables defined for bug 2729498

         Resource_Busy        EXCEPTION;
         pragma exception_init(Resource_Busy,-00054);

         -- Start of plsql tables defined for bug#2729191

         TYPE txn_currency_code_tbl_typ  IS TABLE OF
                    pa_fp_txn_currencies.txn_currency_code%TYPE INDEX BY BINARY_INTEGER;
         TYPE default_rev_curr_flag_tbl_typ  IS TABLE OF
                    pa_fp_txn_currencies.default_rev_curr_flag%TYPE INDEX BY BINARY_INTEGER;
         TYPE default_cost_curr_flag_tbl_typ  IS TABLE OF
                    pa_fp_txn_currencies.default_cost_curr_flag%TYPE INDEX BY BINARY_INTEGER;
         TYPE default_all_curr_flag_tbl_typ  IS TABLE OF
                    pa_fp_txn_currencies.default_all_curr_flag%TYPE INDEX BY BINARY_INTEGER;
         TYPE project_currency_flag_tbl_typ  IS TABLE OF
                    pa_fp_txn_currencies.project_currency_flag%TYPE INDEX BY BINARY_INTEGER;
         TYPE projfunc_currency_flag_tbl_typ  IS TABLE OF
                    pa_fp_txn_currencies.projfunc_currency_flag%TYPE INDEX BY BINARY_INTEGER;
         TYPE pc_cost_exchange_rate_tbl_typ  IS TABLE OF
                    pa_fp_txn_currencies.project_cost_exchange_rate%TYPE INDEX BY BINARY_INTEGER;
         TYPE pc_rev_exchange_rate_tbl_typ  IS TABLE OF
                    pa_fp_txn_currencies.project_rev_exchange_rate%TYPE INDEX BY BINARY_INTEGER;
         TYPE pfc_cost_exchange_rate_tbl_typ  IS TABLE OF
                    pa_fp_txn_currencies.projfunc_cost_exchange_rate%TYPE INDEX BY BINARY_INTEGER;
         TYPE pfc_rev_exchange_rate_tbl_typ  IS TABLE OF
                    pa_fp_txn_currencies.projfunc_rev_exchange_rate%TYPE INDEX BY BINARY_INTEGER;

         l_txn_currency_code_tbl        txn_currency_code_tbl_typ;
         l_default_rev_curr_flag_tbl    default_rev_curr_flag_tbl_typ;
         l_default_cost_curr_flag_tbl   default_cost_curr_flag_tbl_typ;
         l_default_all_curr_flag_tbl    default_all_curr_flag_tbl_typ;
         l_project_currency_flag_tbl    project_currency_flag_tbl_typ;
         l_projfunc_currency_flag_tbl   projfunc_currency_flag_tbl_typ;
         l_pc_cost_exchange_rate_tbl    pc_cost_exchange_rate_tbl_typ;
         l_pc_rev_exchange_rate_tbl     pc_rev_exchange_rate_tbl_typ;
         l_pfc_cost_exchange_rate_tbl   pfc_cost_exchange_rate_tbl_typ;
         l_pfc_rev_exchange_rate_tbl    pfc_rev_exchange_rate_tbl_typ;

         l_source_plan_in_mc_flag       pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;
         l_source_appr_rev_plan_flag    pa_proj_fp_options.approved_rev_plan_type_flag%TYPE; /* Bug 3276128 */

         -- End of plsql tables defined for bug#2729191

         -- Start of cursors defined for bug#2729191

         CURSOR target_fp_options_cur IS
         SELECT   proj_fp_options_id
                 ,project_id
                 ,fin_plan_type_id
                 ,plan_in_multi_curr_flag
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
         FROM    PA_PROJ_FP_OPTIONS
         WHERE   fin_plan_version_id = p_target_plan_version_id;

         target_fp_options_rec target_fp_options_cur%ROWTYPE;

         CURSOR target_txn_currencies_cur IS
         SELECT  txn_currency_code
                ,default_rev_curr_flag
                ,default_cost_curr_flag
                ,default_all_curr_flag
                ,project_currency_flag
                ,projfunc_currency_flag
                ,project_cost_exchange_rate
                ,project_rev_exchange_rate
                ,projfunc_cost_exchange_rate
                ,projfunc_rev_exchange_rate
         FROM   PA_FP_TXN_CURRENCIES
         WHERE  fin_plan_version_id = p_target_plan_version_id
         AND    proj_fp_options_id = target_fp_options_rec.proj_fp_options_id; -- bug 2779637

         -- End of cursors defined for bug#2729191
   BEGIN

      FND_MSG_PUB.INITIALIZE;
      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.init_err_stack('PA_FP_COPY_FROM_PKG.Copy_Plan');
END IF;
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.set_process('PLSQL','LOG',l_debug_mode);
END IF;
     /*
      * Check if  source_verion_id, target_version_id are NULL, if so throw
      * an error message
      */

     IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage := 'Checking for valid parameters:';
          pa_debug.write('Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF (p_source_plan_version_id IS NULL) OR
        (p_target_plan_version_id IS NULL)
     THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage := 'Source_plan='||p_source_plan_version_id;
              pa_debug.write('Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,5);
              pa_debug.g_err_stage := 'Target_plan'||p_target_plan_version_id;
              pa_debug.write('Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,5);
         END IF;

         PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;

     l_adj_percentage := NVL(p_adj_percentage,0);

     --  Doing business validations before proceeding furthur

     IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage:='Fetching the source plan preference code';
          pa_debug.write('Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     SELECT fin_plan_preference_code
           ,plan_in_multi_curr_flag      -- Bug#2729191
           ,nvl(approved_rev_plan_type_flag,'N') /* Bug#3276128 */
     INTO   l_source_fp_pref_code
           ,l_source_plan_in_mc_flag     -- Bug#2729191
           ,l_source_appr_rev_plan_flag /* Bug#3276128 */
     FROM   pa_proj_fp_options
     WHERE  fin_plan_version_id=p_source_plan_version_id;

     IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage:='Fetching the target plan preference code';
          pa_debug.write('Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     SELECT fin_plan_preference_code,nvl(approved_rev_plan_type_flag,'N')
     INTO   l_target_fp_pref_code,l_target_appr_rev_plan_flag
     FROM   pa_proj_fp_options
     WHERE  fin_plan_version_id=p_target_plan_version_id;

     IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage:='Checking the compatability of the plans';
          pa_debug.write('Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF (l_source_fp_pref_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY AND
                                 l_target_fp_pref_code = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY)
         OR ( l_source_fp_pref_code = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY AND
                                 l_target_fp_pref_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY)
         OR (l_target_fp_pref_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP)
         OR (l_source_fp_pref_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP)
     THEN
           IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage:='Versions are incompatible';
                pa_debug.write('Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,5);
           END IF;

           PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                                p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;

     /* Bug 3149010 - Included the following validation */
     /* Bug 3276128 - Included source appr rev plan flag condition.
        If source plan is appr rev, then, no issues in copying
        from the source to any type of version */
      /* 3156057: Commenting the following code as from FP.M it is allowed to copy
         mc enabled budget version into approved revenue budget versions **


     IF l_source_appr_rev_plan_flag = 'N' and l_source_plan_in_mc_flag = 'Y' and l_target_appr_rev_plan_flag = 'Y' THEN
           IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage:='Cannot copy a mc enabled version into a appr rev plan type version. Bug 3149010';
                pa_debug.write('Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,5);
           END IF;

           PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                                p_msg_name      => 'PA_FP_CP_INV_MC_TO_APPR_REV');
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

     END IF;  */

     IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage := 'Parameter validation complete';
          pa_debug.write('Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     /* Bug #2616445: Commented out the following code for checking the lock as the
        user will be able to edit plan only if it is not locked by somebody else.

      --Checking if target version is locked or not

IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.g_err_stage:='Checking if pa_budget_versions is locked';
END IF;
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;

      SELECT locked_by_person_id
             ,project_id
      INTO   l_locked_by_person_id
             ,l_project_id
      FROM   PA_BUDGET_VERSIONS
      WHERE  budget_version_id = p_target_plan_version_id;

      IF l_locked_by_person_id IS NOT NULL THEN
           PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                                p_msg_name      => 'PA_FP_VERSION_ALREADY_LOCKED');
           RAISE Resource_Busy;
      END IF; */

      IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Getting the project id';
           pa_debug.write('Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;

      SELECT project_id
      INTO   l_project_id
      FROM   PA_BUDGET_VERSIONS
      WHERE  budget_version_id = p_target_plan_version_id;

      --Acquire lock on pa_proj_fp_options and pa_budget_versions so that
      --no other process would be able to modify these tables and all
      --underlying child tables

      Acquire_Locks_For_Copy_Plan(
              p_source_plan_version_id  =>  p_source_plan_version_id
              ,p_target_plan_version_id =>  p_target_plan_version_id
              ,x_return_status          =>  l_return_status
              ,x_msg_count              =>  l_msg_count
              ,x_msg_data               =>  l_msg_data );

      -- Start of changes for bug 2729191

      -- target_fp_options_rec contains the mc flag and also the mc conversion
      -- attributes stored in the options table

      OPEN   target_fp_options_cur;
      FETCH  target_fp_options_cur INTO target_fp_options_rec;
      CLOSE  target_fp_options_cur;

      /* If target version has MC enabled and the source version isn't MC
         enabled then the target version should preserve its MC attributes
         and txn currencies. But, delete_version_helper followed by copy_version
         override the MC flag and txn currencies for the target version.
         Since this being a specific case to copy plan, store the required data
         locally and update the target version once copy_version is complete */

      IF ((target_fp_options_rec.plan_in_multi_curr_flag = 'Y' AND l_source_plan_in_mc_flag = 'N') OR
         (l_source_plan_in_mc_flag = 'Y' and l_target_appr_rev_plan_flag = 'Y' )) -- added for 3156057
      THEN

          OPEN target_txn_currencies_cur;
               IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.g_err_stage:='target_txn_currencies_cur is opened';
                    pa_debug.write('Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,3);
               END IF;

               FETCH target_txn_currencies_cur BULK COLLECT INTO
                      l_txn_currency_code_tbl
                     ,l_default_rev_curr_flag_tbl
                     ,l_default_cost_curr_flag_tbl
                     ,l_default_all_curr_flag_tbl
                     ,l_project_currency_flag_tbl
                     ,l_projfunc_currency_flag_tbl
                     ,l_pc_cost_exchange_rate_tbl
                     ,l_pc_rev_exchange_rate_tbl
                     ,l_pfc_cost_exchange_rate_tbl
                     ,l_pfc_rev_exchange_rate_tbl;

               IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.g_err_stage:='no of txn currencies fetched are '||SQL%ROWCOUNT;
                    pa_debug.write('Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,3);
               END IF;
          CLOSE target_txn_currencies_cur;

          IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:='target_txn_currencies_cur is closed';
               pa_debug.write('Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,3);
          END IF;

      END IF;
      -- End of changes for bug 2729191

      -- Calling an api to delete the existing records of target_version in
      -- pa_proj_periods_denorm, p_fin_plan_adj_lines, pa_fp_adj_elements,
      -- pa_budget_lines,pa_resource_assignments

      IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Calling the delete version api';
           pa_debug.write('Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;

      PA_FIN_PLAN_PUB.DELETE_VERSION_HELPER(
                     p_budget_version_id => p_target_plan_version_id
                     ,x_return_status    => l_return_status
                     ,x_msg_count        => l_msg_count
                     ,x_msg_data         => l_msg_data );

      /* Bug# 2647047 - Raise if return status is not success */
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      --Calling the api to copy source version to target version

      l_target_plan_version_id := p_target_plan_version_id;

      IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Calling the copy version api';
           pa_debug.write('Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;

      PA_FIN_PLAN_PUB.COPY_VERSION(
                     p_project_id          => l_project_id
                     ,p_source_version_id  => p_source_plan_version_id
                     ,p_copy_mode          => PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_WORKING
                     ,px_target_version_id => l_target_plan_version_id
                     ,p_adj_percentage     => l_adj_percentage
                     ,p_calling_module     => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN
                     ,x_return_status      => l_return_status
                     ,x_msg_count          => l_msg_count
                     ,x_msg_data           => l_msg_data);

      /* Bug# 2647047 - Raise if return status is not success */
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      -- Start of changes for bug 2729191

      IF target_fp_options_rec.plan_in_multi_curr_flag = 'Y' AND
         l_source_plan_in_mc_flag = 'N'
      THEN

          -- Delete the txn currencies that are copied from source version to target version

          IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:='Deleting the txn currencies of the target version after copy_version';
               pa_debug.write('Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,3);
          END IF;

          DELETE FROM pa_fp_txn_currencies
          WHERE fin_plan_version_id = p_target_plan_version_id
          AND   proj_fp_options_id = target_fp_options_rec.proj_fp_options_id; -- bug 2779637

          -- Update the Multi_Curr_Flag and the MC attributes of the target fp option

          IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:='Updating the target proj fp option with the MC attributes';
               pa_debug.write('Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,3);
          END IF;

          UPDATE PA_PROJ_FP_OPTIONS
          SET     plan_in_multi_curr_flag      =  target_fp_options_rec.plan_in_multi_curr_flag
                 ,projfunc_cost_rate_type      =  target_fp_options_rec.projfunc_cost_rate_type
                 ,projfunc_cost_rate_date_type =  target_fp_options_rec.projfunc_cost_rate_date_type
                 ,projfunc_cost_rate_date      =  target_fp_options_rec.projfunc_cost_rate_date
                 ,projfunc_rev_rate_type       =  target_fp_options_rec.projfunc_rev_rate_type
                 ,projfunc_rev_rate_date_type  =  target_fp_options_rec.projfunc_rev_rate_date_type
                 ,projfunc_rev_rate_date       =  target_fp_options_rec.projfunc_rev_rate_date
                 ,project_cost_rate_type       =  target_fp_options_rec.project_cost_rate_type
                 ,project_cost_rate_date_type  =  target_fp_options_rec.project_cost_rate_date_type
                 ,project_cost_rate_date       =  target_fp_options_rec.project_cost_rate_date
                 ,project_rev_rate_type        =  target_fp_options_rec.project_rev_rate_type
                 ,project_rev_rate_date_type   =  target_fp_options_rec.project_rev_rate_date_type
                 ,project_rev_rate_date        =  target_fp_options_rec.project_rev_rate_date
          WHERE  fin_plan_version_id = p_target_plan_version_id;

          -- Insert the txn currencies of the target version present earlier to copy version
          -- which are stored in the plsql tables

          IF NVL(l_txn_currency_code_tbl.last,0) > 0 THEN

               IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.g_err_stage:='Inserting the txn currencies of the target version
                                           present earlier to copy version';
                    pa_debug.write('Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,3);
               END IF;

               FORALL i IN l_txn_currency_code_tbl.first..l_txn_currency_code_tbl.last
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
                          ,projfunc_cost_exchange_rate
                          ,projfunc_rev_exchange_rate  )
                    SELECT
                           pa_fp_txn_currencies_s.NEXTVAL
                           ,target_fp_options_rec.proj_fp_options_id
                           ,target_fp_options_rec.project_id
                           ,target_fp_options_rec.fin_plan_type_id
                           ,p_target_plan_version_id
                           ,l_txn_currency_code_tbl(i)
                           ,l_default_rev_curr_flag_tbl(i)
                           ,l_default_cost_curr_flag_tbl(i)
                           ,l_default_all_curr_flag_tbl(i)
                           ,l_project_currency_flag_tbl(i)
                           ,l_projfunc_currency_flag_tbl(i)
                           ,SYSDATE
                           ,fnd_global.user_id
                           ,SYSDATE
                           ,fnd_global.user_id
                           ,fnd_global.login_id
                           ,l_pc_cost_exchange_rate_tbl(i)
                           ,l_pc_rev_exchange_rate_tbl(i)
                           ,l_pfc_cost_exchange_rate_tbl(i)
                           ,l_pfc_rev_exchange_rate_tbl(i)
                    FROM   DUAL;
          END IF;
      END IF;
      -- End of changes for bug 2729191

      IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Exiting Copy_Plan';
           pa_debug.write('Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,3);
           pa_debug.reset_err_stack;
      END IF;
  EXCEPTION
      WHEN resource_busy THEN
          IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:='Can not acquire lock.. exiting copy plan';
               pa_debug.write('Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,5);
          END IF;

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

          ROLLBACK;
          x_return_status:= FND_API.G_RET_STS_ERROR;
IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.reset_err_stack;
END IF;
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

        ROLLBACK;
        x_return_status:= FND_API.G_RET_STS_ERROR;
IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.reset_err_stack;
END IF;
   WHEN Others THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_FP_COPY_FROM_PKG'
                        ,p_procedure_name  => 'COPY_PLAN');
        IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write('Copy_Plan: ' || g_module_name,pa_debug.g_err_stage,5);
        pa_debug.reset_err_stack;
	END IF;
        ROLLBACK;
        RAISE;
  END Copy_Plan;

  /*===========================================================================
   This function is used to return fin plan amount type for given plan version
  ===========================================================================*/
  FUNCTION Get_Fin_Plan_Amount_Type (
          p_fin_plan_version_id IN pa_proj_fp_options.fin_plan_version_id%TYPE)
  RETURN  VARCHAR2
  IS
     l_amount_type  VARCHAR2(30);
  BEGIN
      SELECT DECODE(fin_plan_preference_code
                     ,PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME, 'A'
                     ,PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY,      'R'
                     ,PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY,         'C')
      INTO   l_amount_type
      FROM   PA_PROJ_FP_OPTIONS
      WHERE  fin_plan_version_id = p_fin_plan_version_id;

      RETURN l_amount_type;
  END Get_Fin_Plan_Amount_Type;


/*=============================================================================
  This procedure is used to acquire all the required locks for copy_actual
==============================================================================*/

PROCEDURE Acquire_Locks_For_Copy_Actual(
          p_plan_version_id  IN pa_proj_fp_options.fin_plan_version_id%TYPE
          ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data      OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS
       l_msg_count          NUMBER :=0;
       l_data               VARCHAR2(2000);
       l_msg_data           VARCHAR2(2000);
       l_msg_index_out      NUMBER;
       l_debug_mode         VARCHAR2(30);
       Resource_Busy        EXCEPTION;
       pragma exception_init(Resource_Busy,-00054);

       CURSOR fp_opt_cur IS
           SELECT record_version_number
           FROM  PA_PROJ_FP_OPTIONS
           WHERE fin_plan_version_id = p_plan_version_id
           FOR UPDATE NOWAIT;

       CURSOR bdgt_ver_cur IS
           SELECT record_version_number
           FROM   PA_BUDGET_VERSIONS
           WHERE  budget_version_id = p_plan_version_id
           FOR UPDATE NOWAIT;
BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.set_err_stack('PA_FP_COPY_FROM_PKG.Acquire_Lock_For_Copy_Actual');
END IF;
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

   /*
    * Acquire lock on pa_proj_fp_options and pa_budget_versions so that
    * no other process would be able to modify these tables and all
    * underlying child tables
    */

     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='Acquiring lock on pa_proj_fp_options';
         pa_debug.write('Acquire_Locks_For_Copy_Actual: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     OPEN fp_opt_cur;

     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='Acquiring lock on pa_budget_versions';
         pa_debug.write('Acquire_Locks_For_Copy_Actual: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     OPEN bdgt_ver_cur;

     --Increment the record_version_number in pa_budget_versions and
     --pa_proj_fp_options

     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='Incrementing record version number of plan version pa_proj_fp_options';
         pa_debug.write('Acquire_Locks_For_Copy_Actual: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     UPDATE PA_PROJ_FP_OPTIONS
     SET    record_version_number = record_version_number+1
     WHERE  fin_plan_version_id=p_plan_version_id;

     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='Incrementing record version number of plan version in pa_budget_versions';
         pa_debug.write('Acquire_Locks_For_Copy_Actual: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     UPDATE PA_BUDGET_VERSIONS
     SET    record_version_number = record_version_number+1
     WHERE  budget_version_id = p_plan_version_id ;

     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='Closing fp_opt_cur and bdgt_ver_cur cursors';
         pa_debug.write('Acquire_Locks_For_Copy_Actual: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     CLOSE fp_opt_cur;
     CLOSE bdgt_ver_cur;
IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.reset_err_stack;
END IF;
EXCEPTION

  WHEN Resource_Busy THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                             p_msg_name      => 'PA_UTIL_USER_LOCK_FAILED');

        IF fp_opt_cur%ISOPEN THEN
            CLOSE fp_opt_cur;
        END IF;

        IF bdgt_ver_cur%ISOPEN THEN
             CLOSE bdgt_ver_cur;
        END IF;

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:='Unable to acquire lock';
            pa_debug.write('Acquire_Locks_For_Copy_Actual: ' || g_module_name,pa_debug.g_err_stage,5);
        END IF;

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
IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.reset_err_stack;
END IF;
        RAISE;

   WHEN Others THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_FP_COPY_FROM_PKG'
                        ,p_procedure_name  => 'ACQUIRE_LOCKS_FOR_COPY_ACTUAL');

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
            pa_debug.write('Acquire_Locks_For_Copy_Actual: ' || g_module_name,pa_debug.g_err_stage,5);
            pa_debug.reset_err_stack;
	END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Acquire_Locks_For_Copy_Actual;


/*=========================================================================
  This api will be used for two cases.
  Case 1: When a new budget version is to be created from a source version.
          px_target_version_id is passed as null in this case
  Case 2: When the target budget version needs to be modified as the
          specified  source budget version.
          Non_null value for px_target_version_id is passed in this case.
  If the adjustment percentage is zero, the amounts are copied as they are.
  If adjustment percentage is non-zero, then amount coluns are copied as
  null and rollup api takes care of them.

--
--
-- 26-JUN-2003 jwhite        - Plannable Task Dev Effort:
--                             Make code changes Copy_Budget_Version
--                             procedure to
--                             enable population of new parameters on
--                             insert pa_budget_versions
--
-- 01-AUG-2003 jwhite        - Bug 3079891
--                             For Copy_Budget_Version, hardcoded
--                             the following columns to NULL:
--                             - request_id
--                             - plan_processing_code
--



 r11.5 FP.M Developement ----------------------------------

 08-JAN-2004 jwhite        Bug 3362316

                           Extensively rewrote Copy_Budget_Version
                           -  CURSOR l_bv_csr IS
                           -  INSERT INTO PA_BUDGET_VERSIONS (
                           -  UPDATE pa_budget_versions

 29-JAN-2004 sgoteti       Bug 3354518: Added the parameter
                           p_struct_elem_version_id

 16-APR-2004 rravipat      Bug 3354518 FP M Phase II Development
                           When copy_budget_version is called during copy plan, amount
                           generation related columnslike last_amt_gen_date would be
                           updated as null. This is because none of the init columns are
                           copied from source version to target.

10-Jun-05 Bug 4337221: dbora
 if the calling context is workplan, then derive the adjustment percentage
 always as 0, so that the version level rolled up quantity and cost amounts get
 copied from the source version, as it is to the target version.
--Bug 4290043.Included parameter to indicate whether to copy actual info or not.
=========================================================================*/

PROCEDURE Copy_Budget_Version(
        p_source_project_id      IN     NUMBER
       ,p_target_project_id      IN     NUMBER
       ,p_source_version_id      IN     NUMBER
       ,p_copy_mode              IN     VARCHAR2
       ,p_adj_percentage         IN     NUMBER
       ,p_calling_module         IN     VARCHAR2
       ,p_shift_days             IN     NUMBER
       ,p_copy_actuals_flag      IN     VARCHAR2
       ,px_target_version_id     IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       ,p_struct_elem_version_id IN     pa_budget_versions.budget_version_id%TYPE --Bug 3354518
       ,x_return_status          OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       ,x_msg_count              OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
       ,x_msg_data               OUT    NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
AS

    -- Variables to be used for debugging purpose

    l_msg_count       NUMBER := 0;
    l_data            VARCHAR2(2000);
    l_msg_data        VARCHAR2(2000);
    l_error_msg_code  VARCHAR2(2000);
    l_msg_index_out   NUMBER;
    l_return_status   VARCHAR2(2000);
    l_debug_mode      VARCHAR2(30);

    l_adj_percentage  NUMBER;
    l_source_project_id      pa_projects_all.project_id%TYPE;
    l_target_project_id      pa_projects_all.project_id%TYPE;
    l_version_name           pa_budget_versions.version_name%TYPE;
    l_fin_plan_type_id       pa_proj_fp_options.fin_plan_type_id%TYPE;
    l_current_profile_id     pa_budget_versions.period_profile_id%TYPE;
    l_max_version            pa_budget_versions.version_number%TYPE;
    l_version_number         pa_budget_versions.version_number%TYPE;
    l_version_type           pa_budget_versions.version_type%TYPE;
    l_budget_version_id      pa_budget_versions.budget_version_id%TYPE;
    l_budget_status_code     pa_budget_versions.budget_status_code%TYPE;
    l_current_flag           pa_budget_versions.current_flag%TYPE;
    l_current_working_flag   pa_budget_versions.current_working_flag%TYPE;
    l_baselined_by_person_id pa_budget_versions.baselined_by_person_id%TYPE;
    l_baselined_date         pa_budget_versions.baselined_date%TYPE;

    l_cost_flag      VARCHAR2(1);
    l_revenue_flag       VARCHAR2(1);

    l_ci_id                      NUMBER;

     -- jwhite, 26-JUN-2003: Added for Plannable Task Dev Effort ------------------

     l_refresh_required_flag          VARCHAR2(1)  := NULL;
     l_process_code                   VARCHAR2(30) := NULL;

     -- rravipat 3/26/2004 Added for FP M Phase II copy project impact

     l_wbs_struct_version_id          pa_budget_versions.project_structure_version_id%TYPE;
     l_source_cur_planning_period     pa_budget_versions.current_planning_period%TYPE;
     l_target_cur_planning_period     pa_budget_versions.current_planning_period%TYPE;
     l_time_phased_code               pa_proj_fp_options.cost_time_phased_code%TYPE;

     l_gl_start_period            gl_periods.period_name%TYPE;
     l_gl_end_period              gl_periods.period_name%TYPE;
     l_gl_start_Date              VARCHAR2(100);
     l_pa_start_period            pa_periods_all.period_name%TYPE;
     l_pa_end_period              pa_periods_all.period_name%TYPE;
     l_pa_start_date              VARCHAR2(100);
     l_plan_version_exists_flag   VARCHAR2(1);
     l_prj_start_date             VARCHAR2(100);
     l_prj_end_date               VARCHAR2(100);

     -- ---------------------------------------------------------------------------



    -- Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------

    CURSOR l_bv_csr IS
          SELECT   resource_list_id /* Added for bug# 2757847 */
                  ,labor_quantity   /* Added for the bug #2645579. */
                  ,raw_cost
                  ,burdened_cost
                  ,revenue
                  ,pm_product_code
                  ,pm_budget_reference
                  ,wf_status_code
                  ,adw_notify_flag
                  ,NULL --prc_generated_flag  --Bug 5099353
                  ,plan_run_date
                  ,plan_processing_code
                  ,total_borrowed_revenue
                  ,total_revenue_adj
                  ,total_lent_resource_cost
                  ,total_cost_adj
                  ,total_unassigned_time_cost
                  ,total_utilization_percent
                  ,total_utilization_hours
                  ,total_utilization_adj
                  ,total_capacity
                  ,total_head_count
                  ,total_head_count_adj
                  ,total_tp_cost_in
                  ,total_tp_cost_out
                  ,total_tp_revenue_in
                  ,total_tp_revenue_out
                  ,total_project_raw_cost
                  ,total_project_burdened_cost
                  ,total_project_revenue
                  ,period_profile_id /* Added for #2587671 */
                  ,object_type_code
                  ,object_id
               --   ,primary_cost_forecast_flag   FP M Phase II Dev changes this column should not be updated
               --   ,primary_rev_forecast_flag    FP M Phase II Dev changes this column should not be updated
               --   ,rev_partially_impl_flag      FP M Phase II Dev changes this column should not be updated
                  ,equipment_quantity
                  ,pji_summarized_flag
                  ,wp_version_flag
                  ,current_planning_period
                  ,period_mask_id
                  ,last_amt_gen_date
                  ,actual_amts_thru_period
                  ,project_structure_version_id
                  ,etc_start_date --Bug 3927244
          FROM    pa_budget_versions
          WHERE   budget_version_id = p_source_version_id;

    -- ---------------------------------------------------------------------------


    l_bv_rec   l_bv_csr%ROWTYPE;

    -- Bug 3927244
    l_src_plan_class_code pa_fin_plan_types_b.plan_class_code%TYPE;
    l_trg_plan_class_code pa_fin_plan_types_b.plan_class_code%TYPE;

    CURSOR get_plan_class_code_csr(c_budget_version_id pa_budget_versions.budget_version_id%TYPE) IS
    SELECT pfb.plan_class_code,pbv.project_id
    FROM   pa_fin_plan_types_b pfb,
           pa_budget_versions  pbv
    WHERE  pbv.budget_version_id = c_budget_version_id
    AND    pbv.fin_plan_type_id  = pfb.fin_plan_type_id;
    -- Bug 3927244


BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_pa_debug_mode = 'Y' THEN
            pa_debug.set_err_stack('PA_FP_COPY_FROM_PKG.Copy_Budget_Version');
            fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
            l_debug_mode := NVL(l_debug_mode, 'Y');
            pa_debug.set_process('PLSQL','LOG',p_pa_debug_mode);
    END IF;

    --Check if  source_verion_id is NULL, if so throw an error message

    IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage := 'Parameter Validation';
            pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_source_version_id IS NULL) OR
       (p_calling_module IS NULL)
    THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage := 'Source_plan='||p_source_version_id;
               pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
               pa_debug.g_err_stage := 'Calling_module='||p_calling_module;
               pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
         END IF;

         PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    --Throw an error if the struct element version id is not passed in workplan context
    IF p_calling_module=PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN AND
       p_struct_elem_version_id IS NULL THEN

        IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage := 'In workplan context p_struct_elem_version_id passed is '||p_struct_elem_version_id;
                pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                             p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage := 'Parameter validation complete';
            pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF p_calling_module = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN THEN
        -- Bug 4337221:
        l_adj_percentage := 0;
    ELSE
        -- Make the adjustment percentage zero if it is null

        l_adj_percentage := NVL(p_adj_percentage,0);
    END IF;

    IF p_pa_debug_mode = 'Y' THEN
            pa_debug.g_err_stage := 'Source_plan='||p_source_version_id;
            pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
            pa_debug.g_err_stage := 'Target_plan='||px_target_version_id;
            pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
            pa_debug.g_err_stage := 'Calling_module='||p_calling_module;
            pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
            pa_debug.g_err_stage := 'Adj_percentage='||l_adj_percentage;
            pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
    END IF;

    -- Get the fin plan type id, source version name, project id from
    -- pa_budget_versions using source_version_id

    IF px_target_version_id IS NULL THEN

         IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.g_err_stage := 'Fetching version name,fin_plan_type_id of source version';
                 pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
         END IF;

         SELECT NVL(p_target_project_id,project_id)
                ,NVL(p_source_project_id,project_id)
                ,version_name
                ,fin_plan_type_id
                ,version_type
                ,ci_id
                ,current_planning_period
         INTO   l_target_project_id
                ,l_source_project_id
                ,l_version_name
                ,l_fin_plan_type_id
                ,l_version_type
                ,l_ci_id
                ,l_source_cur_planning_period
         FROM   pa_budget_versions
         WHERE  budget_version_id = p_source_version_id;

         -- 3/30/2004 Raja FP M Phase II Dev Changes
         -- If source project and target project are different do not copy
         -- the current planning period from souce version. They should be
         -- defaulted to PA/GL period inwhich nvl(project start date, sysdate)
         -- falls

         IF l_source_project_id <> l_target_project_id  THEN

              --Bug 4200168. Call Pa_Prj_Period_Profile_Utils.Get_Prj_Defaults only if source
              --current planning period is not null and target time phased code is P or G.
              l_time_phased_code := PA_FIN_PLAN_UTILS.Get_Time_Phased_code(p_source_version_id);
              IF ( (l_time_phased_code = 'P'  OR l_time_phased_code = 'G') AND l_source_cur_planning_period IS NOT NULL)  THEN
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
              END IF;

              --l_time_phased_code := PA_FIN_PLAN_UTILS.Get_Time_Phased_code(p_source_version_id);

              IF l_source_cur_planning_period IS NOT NULL THEN

                  IF  l_time_phased_code = 'P' THEN
                      l_target_cur_planning_period := l_pa_start_period;
                  ELSIF l_time_phased_code = 'G'  THEN
                      l_target_cur_planning_period := l_gl_start_period;
                  END IF;

             END IF;
         ELSE
              l_target_cur_planning_period := l_source_cur_planning_period;
         END IF;

         --Get the version_number, version_name

         IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.g_err_stage := 'Fetch the maximum version number';
                 pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
         END IF;

         IF  p_copy_mode = PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_WORKING THEN

              -- Get the max version number of working versions for this plan type
              --start of changes for bug:- 2570250
              /*
              SELECT  NVL(MAX(version_number),0)
              INTO    l_max_version
              FROM    pa_budget_versions
              WHERE   project_id = l_project_id
                AND   fin_plan_type_id = l_fin_plan_type_id
                AND   budget_status_code IN (PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_WORKING,
                                                 PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_SUBMITTED); */
              PA_FIN_PLAN_UTILS.Get_Max_Budget_Version_Number
                        (p_project_id          =>   l_target_project_id
                        ,p_fin_plan_type_id    =>   l_fin_plan_type_id
                        ,p_version_type        =>   l_version_type
                        ,p_copy_mode           =>   PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_WORKING
                        ,p_ci_id               =>   l_ci_id /* FP M changes */
                        ,p_lock_required_flag  =>   'Y'
                        ,x_version_number      =>   l_max_version
                        ,x_return_status       =>   l_return_status
                        ,x_msg_count           =>   l_msg_count
                        ,x_msg_data            =>   l_msg_data );

              --end of changes for bug :- 2570250

              l_version_number := l_max_version + 1;
              l_budget_status_code := PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_WORKING;
              l_current_flag := 'N';

              -- baselined info should be null for a working version

              l_baselined_date := NULL;
              l_baselined_by_person_id := NULL;

              /* #2634622: The version name will not be appended with 'Copy' from now on.
                 From any calling place, where the version name is expected to be different,
                 an update would be done to the pa_budget_versions directly.

                 FND_MESSAGE.SET_NAME('PA','PA_FP_COPY_MESSAGE');
                 l_version_name:= l_version_name ||'-'||FND_MESSAGE.GET;
              */

              IF l_version_number = 1 AND l_ci_id is null THEN
                    l_current_working_flag := 'Y';
              ELSE
                    l_current_working_flag := 'N';
              END IF;

          ELSIF p_copy_mode = PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_BASELINED THEN

              -- Get the max version number of baselined versions for this plan type

              --start  of changes for bug :- 2570250
              /*
              SELECT  NVL(MAX(version_number),0)
              INTO    l_max_version
              FROM    pa_budget_versions
              WHERE   project_id = l_project_id
                AND   fin_plan_type_id = l_fin_plan_type_id
                AND   budget_status_code = PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_BASELINED;
              */

              PA_FIN_PLAN_UTILS.Get_Max_Budget_Version_Number
                        (p_project_id          =>   l_target_project_id
                        ,p_fin_plan_type_id    =>   l_fin_plan_type_id
                        ,p_version_type        =>   l_version_type
                        ,p_copy_mode           =>   PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_BASELINED
                        ,p_ci_id               =>   l_ci_id /* FP  M changes */
                        ,p_lock_required_flag  =>   'Y'
                        ,x_version_number      =>   l_max_version
                        ,x_return_status       =>   l_return_status
                        ,x_msg_count           =>   l_msg_count
                        ,x_msg_data            =>   l_msg_data );

              --end of changes for bug :- 2570250

              l_version_number := l_max_version+1;
              l_budget_status_code := PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_BASELINED;
              l_current_flag := 'Y';

              -- For bug 3858601
              -- Stamp employee_id in baseliend_by_person_id of pa_budget_versions table when
              -- a budget version is baselined instead of user id.

              l_baselined_date := SYSDATE;
              --l_baselined_by_person_id := FND_GLOBAL.USER_ID;

              SELECT employee_id
              INTO l_baselined_by_person_id
              FROM fnd_user
              where user_id = FND_GLOBAL.USER_ID;
              --End of bug 3858601

              -- Bug # 2615988. The message 'Copy' Should not be suffixed to
              -- the version name when the mode is 'B'.
              -- FND_MESSAGE.SET_NAME('PA','PA_FP_COPY_MESSAGE');
              -- l_version_name:= l_version_name ||'-'||FND_MESSAGE.GET;

          END IF;

          -- Fetch new budget_version_id

          IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.g_err_stage := 'Fetch new budget version id';
                  pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
          END IF;

          SELECT pa_budget_versions_s.NEXTVAL
          INTO   px_target_version_id
          FROM   DUAL;

          -- For workplan context project structure version id should be populated
          -- For Finplan the column is not maintained

          IF  p_struct_elem_version_id IS NOT NULL  AND
              p_calling_module=PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN
          THEN
               l_wbs_struct_version_id :=  p_struct_elem_version_id;

          ELSE
               l_wbs_struct_version_id := NULL;
          END IF;

     /* This fix is done during IB1 testing of FP M. There are some flows, which
 *  * are creation more than one budget version for the same workplan version.
 *  To
 *   * identify such flows, the following check is being made so that dev can
 *   fix
 *    * such issues */

     Declare
          l_exists varchar2(1);
     Begin
          Select 'Y'
          Into   l_exists
          From   pa_budget_versions a
          Where  project_structure_version_id = l_wbs_struct_version_id
          And    wp_version_flag = 'Y'
          And    exists (select 'x' from pa_budget_versions b where b.budget_version_id = p_source_version_id and b.wp_version_flag = 'Y') ;

          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:='proj sv id = ' || l_wbs_struct_version_id;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
             pa_debug.g_err_stage:='calling module = ' || p_calling_module;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
             pa_debug.g_err_stage:='copy mode = ' || p_copy_mode;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
             pa_debug.g_err_stage:='source version id = ' || p_source_version_id;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
             pa_debug.g_err_stage:='source project id / target project id = ' || l_source_project_id || ' / ' || l_target_project_id;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
         END IF;
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'DUPLICATE_WP_BEING_CREATED');
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:='Invalid Arguments Passed';
             pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
         END IF;
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     Exception
          When No_Data_Found Then
               Null;
     End;

          -- Insert a new row in pa_budget_versions

          -- Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------

          INSERT INTO PA_BUDGET_VERSIONS (
                   budget_version_id
                   ,project_id
                   ,budget_type_code
                   ,version_number
                   ,budget_status_code
                   ,last_update_date
                   ,last_updated_by
                   ,creation_date
                   ,created_by
                   ,last_update_login
                   ,current_flag
                   ,original_flag
                   ,current_original_flag
                   ,resource_accumulated_flag
                   ,resource_list_id
                   ,version_name
                   ,budget_entry_method_code
                   ,baselined_by_person_id
                   ,baselined_date
                   ,change_reason_code
                   ,labor_quantity
                   ,labor_unit_of_measure
                   ,raw_cost
                   ,burdened_cost
                   ,revenue
                   ,description
                   ,attribute_category
                   ,attribute1
                   ,attribute2
                   ,attribute3
                   ,attribute4
                   ,attribute5
                   ,attribute6
                   ,attribute7
                   ,attribute8
                   ,attribute9
                   ,attribute10
                   ,attribute11
                   ,attribute12
                   ,attribute13
                   ,attribute14
                   ,attribute15
                   ,first_budget_period
                   ,pm_product_code
                   ,pm_budget_reference
                   ,wf_status_code
                   ,adw_notify_flag
                   ,prc_generated_flag
                   ,plan_run_date
                   ,plan_processing_code
                   ,period_profile_id
                   ,fin_plan_type_id
                   ,parent_plan_version_id
                   ,project_structure_version_id
                   ,current_working_flag
                   ,total_borrowed_revenue
                   ,total_revenue_adj
                   ,total_lent_resource_cost
                   ,total_cost_adj
                   ,total_unassigned_time_cost
                   ,total_utilization_percent
                   ,total_utilization_hours
                   ,total_utilization_adj
                   ,total_capacity
                   ,total_head_count
                   ,total_head_count_adj
                   ,version_type
                   ,total_tp_cost_in
                   ,total_tp_cost_out
                   ,total_tp_revenue_in
                   ,total_tp_revenue_out
                   ,record_version_number
                   ,request_id
                   ,total_project_raw_cost
                   ,total_project_burdened_cost
                   ,total_project_revenue
                   ,locked_by_person_id
                   ,approved_cost_plan_type_flag
                   ,approved_rev_plan_type_flag
                   ,process_update_wbs_flag
                   ,object_type_code
                   ,object_id
                   ,primary_cost_forecast_flag
                   ,primary_rev_forecast_flag
                   ,rev_partially_impl_flag
                   ,equipment_quantity
                   ,pji_summarized_flag
                   ,wp_version_flag
                   ,current_planning_period
                   ,period_mask_id
                   ,last_amt_gen_date
                   ,actual_amts_thru_period
                   ,ci_id -- Raja FP M 06 JUl 04 bug 3677924
                   ,etc_start_date -- Bug 3763322
          )
          SELECT    px_target_version_id
                    ,l_target_project_id
                    ,pbv.budget_type_code
                    ,l_version_number            --local_variable
                    ,l_budget_status_code        --local_variable
                    ,sysdate
                    ,fnd_global.user_id
                    ,sysdate
                    ,fnd_global.user_id
                    ,fnd_global.login_id
                    ,l_current_flag             --local_variable
                    ,DECODE(p_copy_mode, PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_WORKING ,'N',
                            DECODE (l_version_number,1,'Y','N')) --original_flag
                    ,DECODE(p_copy_mode, PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_WORKING ,'N',
                            DECODE (l_version_number,1,'Y','N')) --current_original_flag
                    ,'N'           --resource_accumulated_flag
                    ,pbv.resource_list_id
                    ,SUBSTR(l_version_name,1,60)  --local_variable
                    ,pbv.budget_entry_method_code
                    ,l_baselined_by_person_id  --local_variable
                    ,l_baselined_date          --local_variable
                    ,pbv.change_reason_code
                    ,pbv.labor_quantity
                    ,pbv.labor_unit_of_measure
                    ,DECODE(l_adj_percentage, 0, pbv.raw_cost, NULL)
                    ,DECODE(l_adj_percentage, 0, pbv.burdened_cost, NULL)
                    ,DECODE(l_adj_percentage, 0, pbv.revenue, NULL)
                    ,pbv.description
                    ,pbv.attribute_category
                    ,pbv.attribute1
                    ,pbv.attribute2
                    ,pbv.attribute3
                    ,pbv.attribute4
                    ,pbv.attribute5
                    ,pbv.attribute6
                    ,pbv.attribute7
                    ,pbv.attribute8
                    ,pbv.attribute9
                    ,pbv.attribute10
                    ,pbv.attribute11
                    ,pbv.attribute12
                    ,pbv.attribute13
                    ,pbv.attribute14
                    ,pbv.attribute15
                    ,pbv.first_budget_period
                    ,pbv.pm_product_code
                    ,pbv.pm_budget_reference
                    ,NULL                       --Bug 5532326 : wf_status_code is not copied
                    ,pbv.adw_notify_flag
                    ,NULL --pbv.prc_generated_flag --Bug 5099353
                    ,pbv.plan_run_date
                    ,NULL                          -- bug 3079891, 01-AUG-03, jwhite: replaced pbv.plan_processing_code
                    ,period_profile_id
                    ,pbv.fin_plan_type_id
                    ,pbv.parent_plan_version_id
                    ,nvl(l_wbs_struct_version_id,project_structure_version_id) -- Raja nvl should be removed post april 07
                    ,l_current_working_flag  --local_variable
                    ,pbv.total_borrowed_revenue
                    ,pbv.total_revenue_adj
                    ,pbv.total_lent_resource_cost
                    ,pbv.total_cost_adj
                    ,pbv.total_unassigned_time_cost
                    ,pbv.total_utilization_percent
                    ,pbv.total_utilization_hours
                    ,pbv.total_utilization_adj
                    ,pbv.total_capacity
                    ,pbv.total_head_count
                    ,pbv.total_head_count_adj
                    ,pbv.version_type
                    ,pbv.total_tp_cost_in
                    ,pbv.total_tp_cost_out
                    ,pbv.total_tp_revenue_in
                    ,pbv.total_tp_revenue_out
                    ,1       --record_version_number
                    ,NULL                            -- bug 3079891, 01-AUG-03, jwhite: replaced fnd_global.conc_request_id
                    ,DECODE(l_adj_percentage, 0,
                            pbv.total_project_raw_cost, NULL)
                    ,DECODE(l_adj_percentage, 0,
                            pbv.total_project_burdened_cost, NULL)
                    ,DECODE(l_adj_percentage, 0,
                            pbv.total_project_revenue, NULL)
                    ,NULL   --locked_by_person_id
                    ,approved_cost_plan_type_flag
                    ,approved_rev_plan_type_flag
                    ,l_refresh_required_flag
                    ,pbv.object_type_code
                    ,l_target_project_id  -- object_id  bug 3594111
                    ,pbv.primary_cost_forecast_flag
                    ,pbv.primary_rev_forecast_flag
                    ,pbv.rev_partially_impl_flag
                    ,pbv.equipment_quantity
                    ,'N'--This should always be N as the PJI API will be called later and that API will look at this flag
                    --Summarization will happen only if this flag has 'N' as value.
                    ,pbv.wp_version_flag
                    ,l_target_cur_planning_period -- 3/30/2004 FP M Phase II Dev Changes
                    ,pbv.period_mask_id
                    ,pbv.last_amt_gen_date --Bug 4228859
                    ,decode(p_copy_actuals_flag,'N',null,pbv.actual_amts_thru_period) -- Bug 3927244
                    ,l_ci_id -- Raja FP M 06 JUl 04 bug 3677924
                    ,decode(p_copy_actuals_flag,'N',null,pbv.etc_start_date) -- Bug 3927244
          FROM      PA_BUDGET_VERSIONS pbv
          WHERE     pbv.budget_version_id = p_source_version_id;

    -- End, jwhite, 26-JUN-2003: Plannable Task Effort --------------------------------

    -- End: Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------


    ELSE --if target_version_id is passed then we update the version

         IF p_calling_module = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN THEN

               --To decide what amounts are to be copied from source to target
               --version set local flags using target fin plan preference code


               IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.g_err_stage := 'Get values into local flags';
                       pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
               END IF;


/* UT Fix : decoded G_PREF_COST_AND_REV_SAME as Y for revenue_flag */

               SELECT DECODE(fin_plan_preference_code,
                             PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY, 'Y',
                             PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY, 'N',
                             PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME, 'Y')  --cost_flag
                      ,DECODE(fin_plan_preference_code,
                              PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY, 'N',
                              PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY, 'Y',
                              PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME, 'Y') --revenue_flag
               INTO   l_cost_flag
                      ,l_revenue_flag
               FROM   pa_proj_fp_options
               WHERE  fin_plan_version_id = px_target_version_id;

               --Set the cost and revenue flags to 'N' if adj percentage is  nonzero.

               IF l_adj_percentage <> 0 THEN

                   l_cost_flag := 'N';
                   l_revenue_flag := 'N';

               END IF;

               --Update target version using source version values


               IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.g_err_stage := 'Updating target version';
                       pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
               END IF;

               OPEN l_bv_csr;


               IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.g_err_stage := 'l_bv_csr is opened';
                       pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
               END IF;

               FETCH l_bv_csr INTO l_bv_rec;

               -- Bug 3927244: Actuals need to be copied from budget to budget or forecast to forecast
               -- within the same project for FINPLAN versions

               OPEN  get_plan_class_code_csr(p_source_version_id);
               FETCH get_plan_class_code_csr
               INTO  l_src_plan_class_code,l_source_project_id;
               CLOSE get_plan_class_code_csr;

               OPEN  get_plan_class_code_csr(px_target_version_id);
               FETCH get_plan_class_code_csr
               INTO  l_trg_plan_class_code,l_target_project_id;
               CLOSE get_plan_class_code_csr;

               l_source_project_id := NVL(p_source_project_id,l_source_project_id);
               l_target_project_id := NVL(p_target_project_id,l_target_project_id);

               -- End: Bug 3927244

               -- Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------


               IF l_bv_csr%FOUND THEN

                  UPDATE pa_budget_versions
                  SET     resource_list_id              = l_bv_rec.resource_list_id /* Added for bug# 2757847 */
                         ,labor_quantity                = l_bv_rec.labor_quantity   /* Added for bug# 2645579 */
                         ,raw_cost                      = DECODE(l_adj_percentage, 0, DECODE(l_cost_flag,'Y',l_bv_rec.raw_cost,NULL), NULL)
                         ,burdened_cost                 = DECODE(l_adj_percentage, 0, DECODE(l_cost_flag,'Y',l_bv_rec.burdened_cost,NULL), NULL)
                         ,revenue                       = DECODE(l_adj_percentage, 0, DECODE(l_revenue_flag,'Y',l_bv_rec.revenue,NULL), NULL)
                         ,pm_product_code               = l_bv_rec.pm_product_code
                         ,pm_budget_reference           = l_bv_rec.pm_budget_reference
                         -- Bug 5532326. This column should not be copied in copy flow
                         --,wf_status_code                = l_bv_rec.wf_status_code
                         ,adw_notify_flag               = l_bv_rec.adw_notify_flag
                         ,prc_generated_flag            = NULL --l_bv_rec.prc_generated_flag --Bug 5099353
                         ,plan_run_date                 = l_bv_rec.plan_run_date
                         ,plan_processing_code          = NULL --l_bv_rec.plan_processing_code  fix for bug 4463404
                         ,total_borrowed_revenue        = l_bv_rec.total_borrowed_revenue
                         ,total_revenue_adj             = l_bv_rec.total_revenue_adj
                         ,total_lent_resource_cost      = l_bv_rec.total_lent_resource_cost
                         ,total_cost_adj                = l_bv_rec.total_cost_adj
                         ,total_unassigned_time_cost    = l_bv_rec.total_unassigned_time_cost
                         ,total_utilization_percent     = l_bv_rec.total_utilization_percent
                         ,total_utilization_hours       = l_bv_rec.total_utilization_hours
                         ,total_utilization_adj         = l_bv_rec.total_utilization_adj
                         ,total_capacity                = l_bv_rec.total_capacity
                         ,total_head_count              = l_bv_rec.total_head_count
                         ,total_head_count_adj          = l_bv_rec.total_head_count_adj
                         ,total_tp_cost_in              = l_bv_rec.total_tp_cost_in
                         ,total_tp_cost_out             = l_bv_rec.total_tp_cost_out
                         ,total_tp_revenue_in           = l_bv_rec.total_tp_revenue_in
                         ,total_tp_revenue_out          = l_bv_rec.total_tp_revenue_out
                         ,record_version_number         = record_version_number + 1
                         ,request_id                    = NULL  --FND_GLOBAL.conc_request_id  fix for bug 4463404
                         ,total_project_raw_cost        = DECODE(l_adj_percentage, 0, DECODE(l_cost_flag,'Y',l_bv_rec.total_project_raw_cost,NULL), NULL)
                         ,total_project_burdened_cost   = DECODE(l_adj_percentage, 0, DECODE(l_cost_flag,'Y',l_bv_rec.total_project_burdened_cost,NULL), NULL)
                         ,total_project_revenue         = DECODE(l_adj_percentage, 0, DECODE(l_revenue_flag,'Y',l_bv_rec.total_project_revenue,NULL), NULL)
                         ,object_type_code              = l_bv_rec.object_type_code
                         ,object_id                     = l_bv_rec.object_id
              -- FP M Phase II           ,primary_cost_forecast_flag    = l_bv_rec.primary_cost_forecast_flag
              -- FP M Phase II           ,primary_rev_forecast_flag     = l_bv_rec.primary_rev_forecast_flag
              -- FP M Phase II           ,rev_partially_impl_flag       = l_bv_rec.rev_partially_impl_flag
                         ,equipment_quantity            = l_bv_rec.equipment_quantity
                         ,pji_summarized_flag           = l_bv_rec.pji_summarized_flag
                         ,wp_version_flag               = l_bv_rec.wp_version_flag
                         ,current_planning_period       = l_bv_rec.current_planning_period
                         ,period_mask_id                = l_bv_rec.period_mask_id
                         -- Bug 3927244
                         ,last_amt_gen_date             = l_bv_rec.last_amt_gen_date --Bug 4228859
                         ,actual_amts_thru_period       = decode(p_copy_actuals_flag,'N',null,l_bv_rec.actual_amts_thru_period)
                         ,etc_start_date                = decode(p_copy_actuals_flag,'N',null,l_bv_rec.etc_start_date)
                         -- End: Bug 3927244
                         ,project_structure_version_id  = l_bv_rec.project_structure_version_id
                  WHERE  budget_version_id = px_target_version_id;

               -- END: Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------


               END IF;

               CLOSE l_bv_csr;


               IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.g_err_stage := 'l_bv_csr is closed';
                       pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
               END IF;

               END IF; -- p_calling_module

    END IF;
          -- bug fix 2933695
          -- Copy attachments which are associated with the budget version
          fnd_attached_documents2_pkg.copy_attachments
            (X_from_entity_name        => 'PA_BUDGET_VERSIONS',
             X_from_pk1_value          => to_char(p_source_version_id),
             X_to_entity_name          => 'PA_BUDGET_VERSIONS',
             X_to_pk1_value            => px_target_version_id,
             X_created_by              => FND_GLOBAL.USER_ID,
             X_last_update_login       => FND_GLOBAL.LOGIN_ID,
             X_program_application_id  => FND_GLOBAL.PROG_APPL_ID);


    IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage := 'Exiting copy_budget_version';
            pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
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
                   pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
                   pa_debug.reset_err_stack;
          END IF;
          RAISE;

     WHEN Others THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'PA_FP_COPY_FROM_PKG'
                                  ,p_procedure_name  => 'COPY_BUDGET_VERSION');

          IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
                  pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
                  pa_debug.reset_err_stack;
          END IF;

          RAISE;

END Copy_Budget_Version;



/*====================================================================================
   Bug 3354518 - FP M changes - This is an overloaded API. This API will be called
   from pa_fp_planning_transaction_pub.copy_planning_transactions.This API will be used
   to populate the global temporary table PA_FP_RA_MAP_TEMP which will be used for
   the creation of target resource assignment records.

   New columns in pa_fp_ra_map_tmp that will be used for FP M are given below
   planning_start_Date -> planning_start_date for target resource assignment id
   planning_end_Date   -> planning_end_date for target resource assignment id
   schedule_start_Date -> schedule_start_date for target resource assignment id .. For TA specifically..
   schedule_end_Date   -> schedule_end_date for target resource assignment id .. For TA specifically..
   system_reference1   -> source element version id
   system_reference2   -> target element version id
   system_reference3   -> project assignment id for the target resoruce assignment id
   system_reference4   -> resource list member id for the target resoruce assignment id

   p_src_ra_id_tbl          -> The tbl containing the source ra ids which should be copied into the target
   p_src_elem_ver_id_tbl    -> source element version ids which should be copied into the target
   p_targ_elem_ver_id_tbl   -> target element version ids corresponding to the source element version ids
   p_targ_proj_assmt_id_tbl -> target project assignment ids corresponding to the source resource assignment ids
   p_targ_rlm_id_tbl -> target resource list member ids corresponding to the source resource assignment ids

   Bug 3622134    May 12 2004  Raja
                  When target element version id is 0 target task id should be
                  initialised as 0. Select should not be fired
   Bug 3615617 - FP M IB2 changes - Raja
      For workplan context target rlm id would be passed for each source resource assignment
=====================================================================================*/
PROCEDURE create_res_task_maps(
          p_context                  IN      VARCHAR2  --Can be WORKPLAN, BUDGET
         ,p_src_ra_id_tbl            IN      SYSTEM.PA_NUM_TBL_TYPE
         ,p_src_elem_ver_id_tbl      IN      SYSTEM.PA_NUM_TBL_TYPE
         ,p_targ_elem_ver_id_tbl     IN      SYSTEM.PA_NUM_TBL_TYPE
         ,p_targ_proj_assmt_id_tbl   IN      SYSTEM.PA_NUM_TBL_TYPE
         ,p_targ_rlm_id_tbl          IN      SYSTEM.PA_NUM_TBL_TYPE -- Bug 3615617
         ,p_planning_start_date_tbl  IN      SYSTEM.PA_DATE_TBL_TYPE
         ,p_planning_end_date_tbl    IN      SYSTEM.PA_DATE_TBL_TYPE
         ,p_schedule_start_date_tbl  IN      SYSTEM.PA_DATE_TBL_TYPE
         ,p_schedule_end_date_tbl    IN      SYSTEM.PA_DATE_TBL_TYPE
         ,x_return_status            OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count                OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data                 OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
    i                                          NUMBER;
    l_targ_proj_element_id                     pa_proj_elements.proj_element_id%TYPE;
    --Start of variables used for debugging
    l_return_status                            VARCHAR2(1);
    l_msg_count                                NUMBER := 0;
    l_msg_data                                 VARCHAR2(2000);
    l_data                                     VARCHAR2(2000);
    l_msg_index_out                            NUMBER;
    l_debug_mode                               VARCHAR2(30);
    l_debug_level3                    CONSTANT NUMBER :=3;
    l_debug_level5                    CONSTANT NUMBER :=5;
    l_module_name                              VARCHAR2(200) :=  g_module_name || '.create_res_task_maps';
    l_schedule_start_date_tbl                  SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE();
    l_schedule_end_date_tbl                    SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE();
    --End of variables used for debugging
    --Bug 4201936
    l_temp                                     VARCHAR2(15);
    l_src_elem_ver_id                          pa_proj_element_versions.element_version_id%TYPE;
    l_targ_elem_ver_id_tbl                     SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    TYPE src_elem_targ_elem_map_tbl_typ IS TABLE OF NUMBER  INDEX BY VARCHAR2(15);
    l_src_elem_targ_elem_map_tbl               src_elem_targ_elem_map_tbl_typ;

BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

    -- Set curr function
IF l_debug_mode = 'Y' THEN
    pa_debug.set_curr_function(
                p_function   =>'pa_fp_copy_from_pkg.create_res_task_maps'
               ,p_debug_mode => l_debug_mode );

    -- Check for business rules violations
        pa_debug.g_err_stage:='Validating input parameters';
        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
    END IF;

    IF p_context IS NULL THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='p_context is '||p_context;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    --If the no of elements in source and target element version id tbls are not same, throw error
    IF p_src_elem_ver_id_tbl.count <> p_targ_elem_ver_id_tbl.count THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='The count in source elem ver id tbl and targ elem ver id tbl is not equal';
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    --If the no of elements in source ra id and target project assignment id tbls are not same, throw error
    IF p_targ_proj_assmt_id_tbl.count <> p_src_ra_id_tbl.count  OR
       p_targ_rlm_id_tbl.count <> p_src_ra_id_tbl.count OR -- Bug  3615617
       p_planning_start_date_tbl.count <> p_src_ra_id_tbl.count OR
       p_planning_end_date_tbl.count <> p_src_ra_id_tbl.count  OR
       (p_schedule_start_date_tbl.count <> 0 AND
         p_schedule_start_date_tbl.count <> p_src_ra_id_tbl.count) OR
       p_schedule_start_date_tbl.count <> p_schedule_end_date_tbl.count THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='The count in source ra id tbl and targ proj assmt is not equal';
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF p_src_ra_id_tbl.count=0 THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='The source resource assignment id table is emtpy. Returning';
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
            pa_debug.reset_curr_function;
        END IF;
        RETURN;
    END IF;

    IF p_schedule_start_date_tbl.count = 0 THEN
         l_schedule_start_date_tbl := p_planning_start_date_tbl;
         l_schedule_end_date_tbl := p_planning_end_date_tbl;
    ELSE
         l_schedule_start_date_tbl := p_schedule_start_date_tbl;
         l_schedule_end_date_tbl := p_schedule_end_date_tbl;
    END IF;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='About to create the mapping between source and target element version ids';
        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
    END IF;

    DELETE FROM pa_fp_ra_map_tmp;


    --When p_context is BUDGET then the copy will not happen accorss projects. The task id in the source and
    --target would be same for the corresponding resource assignments. Hence the FOR loop which creates the tbl
    --for mapping the task ids need not be executed.

    --Create the mapping between the source element version id and target element version id
    --,target proj element id and target project assignment id

    --Bug 4201936. Prepare tbls for source/target element version id both having same no. of elements as in
    --p_src_ra_id_tbl so that they can be used below for BULK insert
    IF NVL(p_context,'-99')<>'BUDGET' THEN

        l_targ_elem_ver_id_tbl.extend(p_src_ra_id_tbl.count);
        FOR i IN p_src_ra_id_tbl.first..p_src_ra_id_tbl.last LOOP

            SELECT wbs_element_version_id
            INTO   l_src_elem_ver_id
            FROM   pa_resource_assignments
            WHERE  resource_assignment_id=p_src_ra_id_tbl(i);

            l_temp := TO_CHAR(l_src_elem_ver_id);
            IF l_src_elem_targ_elem_map_tbl.EXISTS(l_temp) THEN

                l_targ_elem_ver_id_tbl(i):=l_src_elem_targ_elem_map_tbl(l_temp);

            ELSE

                FOR j IN p_src_elem_ver_id_tbl.first..p_src_elem_ver_id_tbl.last LOOP

                    IF l_src_elem_ver_id=p_src_elem_ver_id_tbl(j) THEN

                        l_targ_elem_ver_id_tbl(i):=p_targ_elem_ver_id_tbl(j);
                        l_src_elem_targ_elem_map_tbl(l_temp):=p_targ_elem_ver_id_tbl(j);
                        EXIT;

                    END IF;

                END LOOP;--FOR j IN p_src_elem_ver_id_tbl.first..p_src_elem_ver_id_tbl.last

            END IF;

        END LOOP;--FOR i IN p_src_ra_id_tbl.first..p_src_ra_id_tbl.last LOOP

    END IF;--IF NVL(p_context,'-99')<>'BUDGET' THEN

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='About to bulk insert into pa_fp_ra_map_tmp';
        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
    END IF;

    --Bulk insert into the pa_fp_ra_map_tmp table

    -- Bug 4187294: performance fix-splitting the below insert into 2 statments
    -- depending upon the context to avoid inner decode statements

    IF p_context = 'BUDGET' THEN
        FORALL i in p_src_ra_id_tbl.first..p_src_ra_id_tbl.last
        INSERT INTO pa_fp_ra_map_tmp
             ( source_res_assignment_id
              ,target_res_assignment_id
              ,source_task_id
              ,target_task_id
              ,system_reference1
              ,system_reference2
              ,system_reference3
              ,planning_start_date
              ,planning_end_date
              ,schedule_start_date
              ,schedule_end_date
              ,system_reference4      -- Bug  3615617
             )
        SELECT pra.resource_assignment_id
              ,pa_resource_assignments_s.nextval
              ,pra.task_id
              ,pra.task_id
              ,NULL
              ,NULL
              ,p_targ_proj_assmt_id_tbl(i)
              ,p_planning_start_date_tbl(i)
              ,p_planning_end_date_tbl(i)
              ,l_schedule_start_date_tbl(i)
              ,l_schedule_end_date_tbl(i)
              ,p_targ_rlm_id_tbl(i)    -- Bug  3615617
        FROM   pa_resource_assignments pra
        WHERE  pra.resource_assignment_id = p_src_ra_id_tbl(i);
    ELSE

        --Bug 4187294: Removed the calls to get_mapped_id.Used the pl/sql tbl l_targ_elem_ver_id_tbl
        --derived above.
        FORALL i in p_src_ra_id_tbl.first..p_src_ra_id_tbl.last
        INSERT INTO pa_fp_ra_map_tmp
             ( source_res_assignment_id
              ,target_res_assignment_id
              ,source_task_id
              ,target_task_id
              ,system_reference1
              ,system_reference2
              ,system_reference3
              ,planning_start_date
              ,planning_end_date
              ,schedule_start_date
              ,schedule_end_date
              ,system_reference4      -- Bug  3615617
             )
        SELECT pra.resource_assignment_id
              ,pa_resource_assignments_s.nextval
              ,pra.task_id
              ,pelm.proj_element_id
              ,pra.wbs_element_version_id
              ,l_targ_elem_ver_id_tbl(i)
              ,p_targ_proj_assmt_id_tbl(i)
              ,p_planning_start_date_tbl(i)
              ,p_planning_end_date_tbl(i)
              ,l_schedule_start_date_tbl(i)
              ,l_schedule_end_date_tbl(i)
              ,p_targ_rlm_id_tbl(i)    -- Bug  3615617
        FROM   pa_resource_assignments pra
              ,pa_proj_element_versions pelm
        WHERE  pra.resource_assignment_id = p_src_ra_id_tbl(i)
        AND    pelm.element_version_id=l_targ_elem_ver_id_tbl(i);
    END IF; -- p_context

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Exiting create_res_task_maps';
        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
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
           pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
        -- reset curr function
           pa_debug.reset_curr_function();
        END IF;
        RETURN;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;

        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'pa_fp_copy_from_pkg'
                                ,p_procedure_name => 'create_res_task_maps');

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write( l_module_name,pa_debug.g_err_stage,5);
        -- reset curr function
           pa_debug.Reset_Curr_Function();
        END IF;
        RAISE;

END create_res_task_maps;


/*=========================================================================
    This api will insert resource_assignments for the target_version based
    upon the PA_FP_RA_MAP_TABLE which contains both source_res_assignment_id,
    its parent and the corresponding target_res_assignment_id.This api will
    populate appropriate amounts based upon the target version plan
    preference code.If adjustment percentage is not zero then all amounts
    will be copied as null and will be populated by the rollup api


    --r11.5 FP.M Developement ----------------------------------
    --
    --08-JAN-04 jwhite          - Bug 3362316
    --                            Rewrote Copy_Resource_Assignments
    --                            for new FP.M columns.
    --

     3/28/2004  Raja FP M Phase II Dev Effort Copy Project Impact
     If resource list is a project specific resource list, target resource
     list member id should be derived using resource alias and target project id

     5/13/2004 Raja FP M IB2 changes Bug 3615617
     Logic to derive target resource list memer id has been moved to
     create_res_task_maps api. Target resource list member id is part
     of pa_fp_ra_map_tmp table. System_reference4 column has the value.

     --Added parameter p_rbs_map_diff_flag for Bug 3974569. This parameter can be passed as Y if the RBS mapping of
     --the target resource assignments is different from that of the source resource assignments.If this is passed as Y then
     ---->1.copy resource assignments will look at pa_rbs_plans_out_tmp table for rbs_element_id and txn_accum_header_id
     ---->of target resource assignments and it assumes that source_id in pa_rbs_plans_out_tmp corresponds to the
     ----> resource_assignment_id in the source budget version.

     --Bug 3948128. Included scheduled_delay in the list of columns that would get copied.
     --Bug 4200168: Changed the logic so that the copy is not based on pa_fp_ra_map_tmp when
     --the API is called for copying resource assignments between budget versions
 ===========================================================================*/

  PROCEDURE Copy_Resource_Assignments(
           p_source_plan_version_id    IN     NUMBER
          ,p_target_plan_version_id   IN     NUMBER
          ,p_adj_percentage           IN     NUMBER
          ,p_rbs_map_diff_flag        IN     VARCHAR2 DEFAULT 'N'
          ,p_calling_context          IN     VARCHAR2 DEFAULT NULL -- Bug 4065314
          ,x_return_status            OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                 OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
  AS
       l_msg_count           NUMBER :=0;
       l_data                VARCHAR2(2000);
       l_msg_data            VARCHAR2(2000);
       l_error_msg_code      VARCHAR2(2000);
       l_msg_index_out       NUMBER;
       l_return_status       VARCHAR2(2000);
       l_debug_mode          VARCHAR2(30);

       l_adj_percentage      NUMBER ;
       l_target_project_id   pa_projects.project_id%TYPE;
       l_cost_flag           pa_fin_plan_amount_sets.raw_cost_flag%TYPE;
       l_revenue_flag        pa_fin_plan_amount_sets.revenue_flag%TYPE;

       l_tmp                 NUMBER;
       l_source_project_id   pa_projects_all.project_id%TYPE;
       l_fin_plan_level_code pa_proj_fp_options.cost_fin_plan_level_code%TYPE;
       l_control_flag        pa_resource_lists_all_bg.control_flag%TYPE;
       l_resource_list_id    pa_proj_fp_options.cost_resource_list_id%TYPE;

       l_project_org         pa_projects_all.carrying_out_organization_id%TYPE; -- bug 6161031


  BEGIN
     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.set_err_stack('PA_FP_COPY_FROM_PKG.Copy_Resource_Assignments');
END IF;
     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');
IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.set_process('PLSQL','LOG',l_debug_mode);
END IF;


     /*
      * Check if  source_verion_id, target_version_id are NULL, if so throw
      * an error message
      */

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'Checking for valid parameters:';
        pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_source_plan_version_id IS NULL) OR
       (p_target_plan_version_id IS NULL)
    THEN

         IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage := 'Source_plan='||p_source_plan_version_id;
             pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,5);

             pa_debug.g_err_stage := 'Target_plan'||p_target_plan_version_id;
             pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,5);
         END IF;

         PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'Parameter validation complete';
        pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    --If adj_percentage is null make it zero

    l_adj_percentage := NVL(p_adj_percentage,0);

     --Fetching the flags of target version using fin_plan_prefernce_code

     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='Fetching the raw_cost,burdened_cost and revenue flags of target_version';
         pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     SELECT DECODE(pfot.fin_plan_preference_code
                   ,PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY ,'Y'
                   ,PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME , 'Y','N') --cost_flag
            ,DECODE(pfot.fin_plan_preference_code
                     ,PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY ,'Y'
                     ,PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME ,'Y','N')--revenue_flag
            ,pfot.project_id
            ,pfos.project_id
            ,nvl(pfos.cost_fin_plan_level_code, nvl(pfos.revenue_fin_plan_level_code,pfos.all_fin_plan_level_code))
            ,nvl(pfos.cost_resource_list_id, nvl(pfos.revenue_resource_list_id,pfos.all_resource_list_id))
            ,nvl(rl.control_flag,'N')
     INTO   l_cost_flag
           ,l_revenue_flag
           ,l_target_project_id
           ,l_source_project_id
           ,l_fin_plan_level_code
           ,l_resource_list_id
           ,l_control_flag
     FROM   pa_proj_fp_options pfot,--target
            pa_proj_fp_options pfos,--source
            pa_resource_lists_all_bg rl
     WHERE  pfot.fin_plan_version_id=p_target_plan_version_id
     AND    pfos.fin_plan_version_id=p_source_plan_version_id
     AND    rl.resource_list_id=nvl(pfot.cost_resource_list_id, nvl(pfot.revenue_resource_list_id,pfot.all_resource_list_id));

/*
    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='l_cost_flag ='||l_cost_flag;
        pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);
        pa_debug.g_err_stage:='l_revenue_flag ='||l_revenue_flag;
        pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);
        pa_debug.g_err_stage:='l_target_project_id ='||l_target_project_id;
        pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;
*/
    --Inserting records into pa_resource_assignments using pa_fp_ra_map_tmp

     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='Copying the source version records as target version records';
         pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;
     -- Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------

     --Bug 3974569. Need not have pa_rbs_plans_out_tmp in the FROM clause if the parameter is N
     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='p_rbs_map_diff_flag '||p_rbs_map_diff_flag;
         pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF (p_calling_context='WORKPLAN' AND nvl(p_rbs_map_diff_flag,'N') ='N') OR
         p_calling_context='CI' THEN

         IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:='Using the First RA Insert';
             pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);
         END IF;

         INSERT INTO PA_RESOURCE_ASSIGNMENTS(
                  resource_assignment_id
                  ,budget_version_id
                  ,project_id
                  ,task_id
                  ,resource_list_member_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,unit_of_measure
                  ,track_as_labor_flag
                  ,total_plan_revenue
                  ,total_plan_raw_cost
                  ,total_plan_burdened_cost
                  ,total_plan_quantity
                  ,resource_assignment_type
                  ,total_project_raw_cost
                  ,total_project_burdened_cost
                  ,total_project_revenue
                  ,standard_bill_rate
                  ,average_bill_rate
                  ,average_cost_rate
                  ,project_assignment_id
                  ,plan_error_code
                  ,average_discount_percentage
                  ,total_borrowed_revenue
                  ,total_revenue_adj
                  ,total_lent_resource_cost
                  ,total_cost_adj
                  ,total_unassigned_time_cost
                  ,total_utilization_percent
                  ,total_utilization_hours
                  ,total_utilization_adj
                  ,total_capacity
                  ,total_head_count
                  ,total_head_count_adj
                  ,total_tp_revenue_in
                  ,total_tp_revenue_out
                  ,total_tp_cost_in
                  ,total_tp_cost_out
                  ,parent_assignment_id
                  ,wbs_element_version_id
                  ,rbs_element_id
                  ,planning_start_date
                  ,planning_end_date
                  ,schedule_start_date
                  ,schedule_end_date
                  ,spread_curve_id
                  ,etc_method_code
                  ,res_type_code
                  ,attribute_category
                  ,attribute1
                  ,attribute2
                  ,attribute3
                  ,attribute4
                  ,attribute5
                  ,attribute6
                  ,attribute7
                  ,attribute8
                  ,attribute9
                  ,attribute10
                  ,attribute11
                  ,attribute12
                  ,attribute13
                  ,attribute14
                  ,attribute15
                  ,attribute16
                  ,attribute17
                  ,attribute18
                  ,attribute19
                  ,attribute20
                  ,attribute21
                  ,attribute22
                  ,attribute23
                  ,attribute24
                  ,attribute25
                  ,attribute26
                  ,attribute27
                  ,attribute28
                  ,attribute29
                  ,attribute30
                  ,fc_res_type_code
                  ,resource_class_code
                  ,organization_id
                  ,job_id
                  ,person_id
                  ,expenditure_type
                  ,expenditure_category
                  ,revenue_category_code
                  ,event_type
                  ,supplier_id
                  ,non_labor_resource
                  ,bom_resource_id
                  ,inventory_item_id
                  ,item_category_id
                  ,record_version_number
                  ,transaction_source_code
                  ,mfc_cost_type_id
                  ,procure_resource_flag
                  ,assignment_description
                  ,incurred_by_res_flag
                  ,rate_job_id
                  ,rate_expenditure_type
                  ,ta_display_flag
                  ,sp_fixed_date
                  ,person_type_code
                  ,rate_based_flag
                  ,resource_rate_based_flag  --IPM Arch Enhancements Bug 4865563
                  ,use_task_schedule_flag
                  ,rate_exp_func_curr_code
                  ,rate_expenditure_org_id
                  ,incur_by_res_class_code
                  ,incur_by_role_id
                  ,project_role_id
                  ,resource_class_flag
                  ,named_role
                  ,txn_accum_header_id
                  ,scheduled_delay --For Bug 3948128
                  )
         SELECT   /*+ ORDERED USE_NL(PFRMT,PRA) INDEX(PRA PA_RESOURCE_ASSIGNMENTS_U1)*/ pfrmt.target_res_assignment_id  --Bug 2814165
                  ,p_target_plan_version_id
                  ,l_target_project_id
                  ,pfrmt.target_task_id
                  ,pfrmt.system_reference4 -- Bug 3615617 resource_list_member_id
                  ,sysdate
                  ,fnd_global.user_id
                  ,sysdate
                  ,fnd_global.user_id
                  ,fnd_global.login_id
                  ,pra.unit_of_measure
                  ,pra.track_as_labor_flag
                  ,DECODE(l_adj_percentage,0,DECODE(l_revenue_flag,'Y',total_plan_revenue,NULL),NULL)
                  ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_plan_raw_cost,NULL),NULL)
                  ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_plan_burdened_cost,NULL),NULL)
                  ,DECODE(l_adj_percentage,0,total_plan_quantity,NULL)
                  ,pra.resource_assignment_type
                  ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_project_raw_cost,NULL),NULL)
                  ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_project_burdened_cost,NULL),NULL)
                  ,DECODE(l_adj_percentage,0,DECODE(l_revenue_flag,'Y',total_project_revenue,NULL),NULL)
                  ,standard_bill_rate
                  ,average_bill_rate
                  ,average_cost_rate
                  ,pfrmt.system_reference3 -- Project assignment id of the target (Bug 3354518)
                  ,plan_error_code
                  ,average_discount_percentage
                  ,total_borrowed_revenue
                  ,total_revenue_adj
                  ,total_lent_resource_cost
                  ,total_cost_adj
                  ,total_unassigned_time_cost
                  ,total_utilization_percent
                  ,total_utilization_hours
                  ,total_utilization_adj
                  ,total_capacity
                  ,total_head_count
                  ,total_head_count_adj
                  ,total_tp_revenue_in
                  ,total_tp_revenue_out
                  ,total_tp_cost_in
                  ,total_tp_cost_out
                  --parent assignment id in the target resource assignments contain source resource assignment id
                  --Bug 4200168
                  ,pra.resource_assignment_id
                  ,pfrmt.system_reference2 -- element version id of the target. (Bug 3354518)
                  ,pra.rbs_element_id
                  ,pfrmt.planning_start_date -- Planning start date of the target (Bug 3354518)
                  ,pfrmt.planning_end_date   -- Planning end date of the target  (Bug 3354518)
                  ,pfrmt.schedule_start_date
                  ,pfrmt.schedule_end_date
                  ,pra.spread_curve_id
                  ,pra.etc_method_code
                  ,pra.res_type_code
                  ,pra.attribute_category
                  ,pra.attribute1
                  ,pra.attribute2
                  ,pra.attribute3
                  ,pra.attribute4
                  ,pra.attribute5
                  ,pra.attribute6
                  ,pra.attribute7
                  ,pra.attribute8
                  ,pra.attribute9
                  ,pra.attribute10
                  ,pra.attribute11
                  ,pra.attribute12
                  ,pra.attribute13
                  ,pra.attribute14
                  ,pra.attribute15
                  ,pra.attribute16
                  ,pra.attribute17
                  ,pra.attribute18
                  ,pra.attribute19
                  ,pra.attribute20
                  ,pra.attribute21
                  ,pra.attribute22
                  ,pra.attribute23
                  ,pra.attribute24
                  ,pra.attribute25
                  ,pra.attribute26
                  ,pra.attribute27
                  ,pra.attribute28
                  ,pra.attribute29
                  ,pra.attribute30
                  ,pra.fc_res_type_code
                  ,pra.resource_class_code
                  ,pra.organization_id
                  ,pra.job_id
                  ,pra.person_id
                  ,pra.expenditure_type
                  ,pra.expenditure_category
                  ,pra.revenue_category_code
                  ,pra.event_type
                  ,pra.supplier_id
                  ,pra.non_labor_resource
                  ,pra.bom_resource_id
                  ,pra.inventory_item_id
                  ,pra.item_category_id
                  ,1    -- should be 1 in the target version being created
                  ,decode(p_calling_context, 'CREATE_VERSION', NULL, pra.transaction_source_code)
                  ,pra.mfc_cost_type_id
                  ,pra.procure_resource_flag
                  ,pra.assignment_description
                  ,pra.incurred_by_res_flag
                  ,pra.rate_job_id
                  ,pra.rate_expenditure_type
                  ,pra.ta_display_flag
                  -- Bug 3820625 sp_fixed_date should also move as per planning_start_date
                  -- Least and greatest are used to make sure that sp_fixed_date is with in planning start and end dates
                  ,greatest(least(pra.sp_fixed_date + (pfrmt.planning_start_date - pra.planning_start_date),
                                  pfrmt.planning_end_date),
                            pfrmt.planning_start_date)
                  ,pra.person_type_code
                  ,pra.rate_based_flag
                  ,pra.resource_rate_based_flag   --IPM Arch Enhacement Bug 4865563
                  ,pra.use_task_schedule_flag
                  ,pra.rate_exp_func_curr_code
                  ,pra.rate_expenditure_org_id
                  ,pra.incur_by_res_class_code
                  ,pra.incur_by_role_id
                  ,pra.project_role_id
                  ,pra.resource_class_flag
                  ,pra.named_role
                  ,pra.txn_accum_header_id
                  ,scheduled_delay --For Bug 3948128
         FROM     PA_FP_RA_MAP_TMP pfrmt          --Bug 2814165
                 ,PA_RESOURCE_ASSIGNMENTS pra
         WHERE    pra.resource_assignment_id = pfrmt.source_res_assignment_id
         AND      pra.budget_version_id      = p_source_plan_version_id ;


     --For Bug 3974569. Take rbs_element_id and txn_accum_header_id from pa_rbs_plans_out_tmp
     --API is called for  in WORKPLAN CONTEXT for copying from source to target with different RBSs or Resource Lists
     ELSIF p_calling_context='WORKPLAN' AND p_rbs_map_diff_flag ='Y' THEN --IF p_rbs_map_diff_flag ='N' THEN

         IF P_PA_DEBUG_MODE = 'Y' THEN

             pa_debug.g_err_stage:='Using the Second RA Insert';
             pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);


             SELECT COUNT(*)
             INTO   l_tmp
             FROM   PA_FP_RA_MAP_TMP;

             pa_debug.g_err_stage:='PA_FP_RA_MAP_TMP count '||l_tmp;
             pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);

             SELECT COUNT(*)
             INTO   l_tmp
             FROM   pa_rbs_plans_out_tmp;

             pa_debug.g_err_stage:='pa_rbs_plans_out_tmp count '||l_tmp;
             pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);

         END IF;

         INSERT INTO PA_RESOURCE_ASSIGNMENTS(
                  resource_assignment_id
                  ,budget_version_id
                  ,project_id
                  ,task_id
                  ,resource_list_member_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,unit_of_measure
                  ,track_as_labor_flag
                  ,total_plan_revenue
                  ,total_plan_raw_cost
                  ,total_plan_burdened_cost
                  ,total_plan_quantity
                  ,resource_assignment_type
                  ,total_project_raw_cost
                  ,total_project_burdened_cost
                  ,total_project_revenue
                  ,standard_bill_rate
                  ,average_bill_rate
                  ,average_cost_rate
                  ,project_assignment_id
                  ,plan_error_code
                  ,average_discount_percentage
                  ,total_borrowed_revenue
                  ,total_revenue_adj
                  ,total_lent_resource_cost
                  ,total_cost_adj
                  ,total_unassigned_time_cost
                  ,total_utilization_percent
                  ,total_utilization_hours
                  ,total_utilization_adj
                  ,total_capacity
                  ,total_head_count
                  ,total_head_count_adj
                  ,total_tp_revenue_in
                  ,total_tp_revenue_out
                  ,total_tp_cost_in
                  ,total_tp_cost_out
                  ,parent_assignment_id
                  ,wbs_element_version_id
                  ,rbs_element_id
                  ,planning_start_date
                  ,planning_end_date
                  ,schedule_start_date
                  ,schedule_end_date
                  ,spread_curve_id
                  ,etc_method_code
                  ,res_type_code
                  ,attribute_category
                  ,attribute1
                  ,attribute2
                  ,attribute3
                  ,attribute4
                  ,attribute5
                  ,attribute6
                  ,attribute7
                  ,attribute8
                  ,attribute9
                  ,attribute10
                  ,attribute11
                  ,attribute12
                  ,attribute13
                  ,attribute14
                  ,attribute15
                  ,attribute16
                  ,attribute17
                  ,attribute18
                  ,attribute19
                  ,attribute20
                  ,attribute21
                  ,attribute22
                  ,attribute23
                  ,attribute24
                  ,attribute25
                  ,attribute26
                  ,attribute27
                  ,attribute28
                  ,attribute29
                  ,attribute30
                  ,fc_res_type_code
                  ,resource_class_code
                  ,organization_id
                  ,job_id
                  ,person_id
                  ,expenditure_type
                  ,expenditure_category
                  ,revenue_category_code
                  ,event_type
                  ,supplier_id
                  ,non_labor_resource
                  ,bom_resource_id
                  ,inventory_item_id
                  ,item_category_id
                  ,record_version_number
                  ,transaction_source_code
                  ,mfc_cost_type_id
                  ,procure_resource_flag
                  ,assignment_description
                  ,incurred_by_res_flag
                  ,rate_job_id
                  ,rate_expenditure_type
                  ,ta_display_flag
                  ,sp_fixed_date
                  ,person_type_code
                  ,rate_based_flag
                  ,resource_rate_based_flag -- IPM Arch Enhacements Bug 4865563
                  ,use_task_schedule_flag
                  ,rate_exp_func_curr_code
                  ,rate_expenditure_org_id
                  ,incur_by_res_class_code
                  ,incur_by_role_id
                  ,project_role_id
                  ,resource_class_flag
                  ,named_role
                  ,txn_accum_header_id
                  ,scheduled_delay --For Bug 3948128
                  )
         SELECT   /*+ ORDERED USE_NL(PFRMT,PRA,RMAP) INDEX(PRA PA_RESOURCE_ASSIGNMENTS_U1)*/ pfrmt.target_res_assignment_id  --Bug 2814165
                  ,p_target_plan_version_id
                  ,l_target_project_id
                  ,pfrmt.target_task_id
                  ,pfrmt.system_reference4 -- Bug 3615617 resource_list_member_id
                  ,sysdate
                  ,fnd_global.user_id
                  ,sysdate
                  ,fnd_global.user_id
                  ,fnd_global.login_id
                  ,pra.unit_of_measure
                  ,pra.track_as_labor_flag
                  ,DECODE(l_adj_percentage,0,DECODE(l_revenue_flag,'Y',total_plan_revenue,NULL),NULL)
                  ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_plan_raw_cost,NULL),NULL)
                  ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_plan_burdened_cost,NULL),NULL)
                  ,DECODE(l_adj_percentage,0,total_plan_quantity,NULL)
                  ,pra.resource_assignment_type
                  ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_project_raw_cost,NULL),NULL)
                  ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_project_burdened_cost,NULL),NULL)
                  ,DECODE(l_adj_percentage,0,DECODE(l_revenue_flag,'Y',total_project_revenue,NULL),NULL)
                  ,standard_bill_rate
                  ,average_bill_rate
                  ,average_cost_rate
                  ,pfrmt.system_reference3 -- Project assignment id of the target (Bug 3354518)
                  ,plan_error_code
                  ,average_discount_percentage
                  ,total_borrowed_revenue
                  ,total_revenue_adj
                  ,total_lent_resource_cost
                  ,total_cost_adj
                  ,total_unassigned_time_cost
                  ,total_utilization_percent
                  ,total_utilization_hours
                  ,total_utilization_adj
                  ,total_capacity
                  ,total_head_count
                  ,total_head_count_adj
                  ,total_tp_revenue_in
                  ,total_tp_revenue_out
                  ,total_tp_cost_in
                  ,total_tp_cost_out
                  --parent assignment id in the target resource assignments contain source resource assignment id
                  --Bug 4200168
                  ,pra.resource_assignment_id
                  ,pfrmt.system_reference2 -- element version id of the target. (Bug 3354518)
                  ,rmap.rbs_element_id
                  ,pfrmt.planning_start_date -- Planning start date of the target (Bug 3354518)
                  ,pfrmt.planning_end_date   -- Planning end date of the target  (Bug 3354518)
                  ,pfrmt.schedule_start_date
                  ,pfrmt.schedule_end_date
                  ,pra.spread_curve_id
                  ,pra.etc_method_code
                  ,pra.res_type_code
                  ,pra.attribute_category
                  ,pra.attribute1
                  ,pra.attribute2
                  ,pra.attribute3
                  ,pra.attribute4
                  ,pra.attribute5
                  ,pra.attribute6
                  ,pra.attribute7
                  ,pra.attribute8
                  ,pra.attribute9
                  ,pra.attribute10
                  ,pra.attribute11
                  ,pra.attribute12
                  ,pra.attribute13
                  ,pra.attribute14
                  ,pra.attribute15
                  ,pra.attribute16
                  ,pra.attribute17
                  ,pra.attribute18
                  ,pra.attribute19
                  ,pra.attribute20
                  ,pra.attribute21
                  ,pra.attribute22
                  ,pra.attribute23
                  ,pra.attribute24
                  ,pra.attribute25
                  ,pra.attribute26
                  ,pra.attribute27
                  ,pra.attribute28
                  ,pra.attribute29
                  ,pra.attribute30
                  ,pra.fc_res_type_code
                  ,pra.resource_class_code
                  ,pra.organization_id
                  ,pra.job_id
                  ,pra.person_id
                  ,pra.expenditure_type
                  ,pra.expenditure_category
                  ,pra.revenue_category_code
                  ,pra.event_type
                  ,pra.supplier_id
                  ,pra.non_labor_resource
                  ,pra.bom_resource_id
                  ,pra.inventory_item_id
                  ,pra.item_category_id
                  ,1    -- should be 1 in the target version being created
                  ,decode(p_calling_context, 'CREATE_VERSION', NULL, pra.transaction_source_code)
                  ,pra.mfc_cost_type_id
                  ,pra.procure_resource_flag
                  ,pra.assignment_description
                  ,pra.incurred_by_res_flag
                  ,pra.rate_job_id
                  ,pra.rate_expenditure_type
                  ,pra.ta_display_flag
                  -- Bug 3820625 sp_fixed_date should also move as per planning_start_date
                  -- Least and greatest are used to make sure that sp_fixed_date is with in planning start and end dates
                  ,greatest(least(pra.sp_fixed_date + (pfrmt.planning_start_date - pra.planning_start_date),
                                  pfrmt.planning_end_date),
                            pfrmt.planning_start_date)
                  ,pra.person_type_code
                  ,pra.rate_based_flag
                  ,pra.resource_rate_based_flag  --IPM Arch Enhancement Bug 4865563
                  ,pra.use_task_schedule_flag
                  ,pra.rate_exp_func_curr_code
                  ,pra.rate_expenditure_org_id
                  ,pra.incur_by_res_class_code
                  ,pra.incur_by_role_id
                  ,pra.project_role_id
                  ,pra.resource_class_flag
                  ,pra.named_role
                  ,rmap.txn_accum_header_id
                  ,scheduled_delay --For Bug 3948128
         FROM     PA_FP_RA_MAP_TMP pfrmt          --Bug 2814165
                 ,PA_RESOURCE_ASSIGNMENTS pra
                 ,pa_rbs_plans_out_tmp rmap
         WHERE    pra.resource_assignment_id = pfrmt.source_res_assignment_id
         AND      pra.budget_version_id      = p_source_plan_version_id
         AND      rmap.source_id = pra.resource_assignment_id;

     --Copying BUDGET versions within a project. OR
     --Copying Budget versions across 2 projects with the planning level being project and
     ---->with the resource list being a centrally controlled one
     ELSIF ((p_calling_context IS NULL  OR p_calling_context='CREATE_VERSION') AND l_source_project_id=l_target_project_id) OR
        ((p_calling_context IS NULL  OR p_calling_context='CREATE_VERSION') AND l_source_project_id<>l_target_project_id
          AND l_fin_plan_level_code='P' AND l_control_flag='Y' ) THEN

             IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.g_err_stage:='Using the Third RA Insert';
                 pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);
             END IF;

             INSERT INTO PA_RESOURCE_ASSIGNMENTS(
                      resource_assignment_id
                      ,budget_version_id
                      ,project_id
                      ,task_id
                      ,resource_list_member_id
                      ,last_update_date
                      ,last_updated_by
                      ,creation_date
                      ,created_by
                      ,last_update_login
                      ,unit_of_measure
                      ,track_as_labor_flag
                      ,total_plan_revenue
                      ,total_plan_raw_cost
                      ,total_plan_burdened_cost
                      ,total_plan_quantity
                      ,resource_assignment_type
                      ,total_project_raw_cost
                      ,total_project_burdened_cost
                      ,total_project_revenue
                      ,standard_bill_rate
                      ,average_bill_rate
                      ,average_cost_rate
                      ,project_assignment_id
                      ,plan_error_code
                      ,average_discount_percentage
                      ,total_borrowed_revenue
                      ,total_revenue_adj
                      ,total_lent_resource_cost
                      ,total_cost_adj
                      ,total_unassigned_time_cost
                      ,total_utilization_percent
                      ,total_utilization_hours
                      ,total_utilization_adj
                      ,total_capacity
                      ,total_head_count
                      ,total_head_count_adj
                      ,total_tp_revenue_in
                      ,total_tp_revenue_out
                      ,total_tp_cost_in
                      ,total_tp_cost_out
                      ,parent_assignment_id
                      ,wbs_element_version_id
                      ,rbs_element_id
                      ,planning_start_date
                      ,planning_end_date
                      ,schedule_start_date
                      ,schedule_end_date
                      ,spread_curve_id
                      ,etc_method_code
                      ,res_type_code
                      ,attribute_category
                      ,attribute1
                      ,attribute2
                      ,attribute3
                      ,attribute4
                      ,attribute5
                      ,attribute6
                      ,attribute7
                      ,attribute8
                      ,attribute9
                      ,attribute10
                      ,attribute11
                      ,attribute12
                      ,attribute13
                      ,attribute14
                      ,attribute15
                      ,attribute16
                      ,attribute17
                      ,attribute18
                      ,attribute19
                      ,attribute20
                      ,attribute21
                      ,attribute22
                      ,attribute23
                      ,attribute24
                      ,attribute25
                      ,attribute26
                      ,attribute27
                      ,attribute28
                      ,attribute29
                      ,attribute30
                      ,fc_res_type_code
                      ,resource_class_code
                      ,organization_id
                      ,job_id
                      ,person_id
                      ,expenditure_type
                      ,expenditure_category
                      ,revenue_category_code
                      ,event_type
                      ,supplier_id
                      ,non_labor_resource
                      ,bom_resource_id
                      ,inventory_item_id
                      ,item_category_id
                      ,record_version_number
                      ,transaction_source_code
                      ,mfc_cost_type_id
                      ,procure_resource_flag
                      ,assignment_description
                      ,incurred_by_res_flag
                      ,rate_job_id
                      ,rate_expenditure_type
                      ,ta_display_flag
                      ,sp_fixed_date
                      ,person_type_code
                      ,rate_based_flag
                      ,resource_rate_based_flag --IPM Arch Enhacements Bug 4865563
                      ,use_task_schedule_flag
                      ,rate_exp_func_curr_code
                      ,rate_expenditure_org_id
                      ,incur_by_res_class_code
                      ,incur_by_role_id
                      ,project_role_id
                      ,resource_class_flag
                      ,named_role
                      ,txn_accum_header_id
                      ,scheduled_delay --For Bug 3948128
                      )
             SELECT
                       pa_resource_assignments_s.nextval
                      ,p_target_plan_version_id
                      ,l_target_project_id
                      ,pra.task_id
                      ,pra.resource_list_member_id
                      ,sysdate
                      ,fnd_global.user_id
                      ,sysdate
                      ,fnd_global.user_id
                      ,fnd_global.login_id
                      ,pra.unit_of_measure
                      ,pra.track_as_labor_flag
                      ,DECODE(l_adj_percentage,0,DECODE(l_revenue_flag,'Y',total_plan_revenue,NULL),NULL)
                      ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_plan_raw_cost,NULL),NULL)
                      ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_plan_burdened_cost,NULL),NULL)
                      ,DECODE(l_adj_percentage,0,total_plan_quantity,NULL)
                      ,pra.resource_assignment_type
                      ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_project_raw_cost,NULL),NULL)
                      ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_project_burdened_cost,NULL),NULL)
                      ,DECODE(l_adj_percentage,0,DECODE(l_revenue_flag,'Y',total_project_revenue,NULL),NULL)
                      ,standard_bill_rate
                      ,average_bill_rate
                      ,average_cost_rate
                      ,pra.project_assignment_id
                      ,plan_error_code
                      ,average_discount_percentage
                      ,total_borrowed_revenue
                      ,total_revenue_adj
                      ,total_lent_resource_cost
                      ,total_cost_adj
                      ,total_unassigned_time_cost
                      ,total_utilization_percent
                      ,total_utilization_hours
                      ,total_utilization_adj
                      ,total_capacity
                      ,total_head_count
                      ,total_head_count_adj
                      ,total_tp_revenue_in
                      ,total_tp_revenue_out
                      ,total_tp_cost_in
                      ,total_tp_cost_out
                      --parent assignment id in the target resource assignments contain source resource assignment id
                      --Bug 4200168
                      ,pra.resource_assignment_id
                      ,pra.wbs_element_version_id
                      ,pra.rbs_element_id
                      ,pra.planning_start_date -- Planning start date of the target (Bug 3354518)
                      ,pra.planning_end_date   -- Planning end date of the target  (Bug 3354518)
                      ,pra.schedule_start_date
                      ,pra.schedule_end_date
                      ,pra.spread_curve_id
                      ,pra.etc_method_code
                      ,pra.res_type_code
                      ,pra.attribute_category
                      ,pra.attribute1
                      ,pra.attribute2
                      ,pra.attribute3
                      ,pra.attribute4
                      ,pra.attribute5
                      ,pra.attribute6
                      ,pra.attribute7
                      ,pra.attribute8
                      ,pra.attribute9
                      ,pra.attribute10
                      ,pra.attribute11
                      ,pra.attribute12
                      ,pra.attribute13
                      ,pra.attribute14
                      ,pra.attribute15
                      ,pra.attribute16
                      ,pra.attribute17
                      ,pra.attribute18
                      ,pra.attribute19
                      ,pra.attribute20
                      ,pra.attribute21
                      ,pra.attribute22
                      ,pra.attribute23
                      ,pra.attribute24
                      ,pra.attribute25
                      ,pra.attribute26
                      ,pra.attribute27
                      ,pra.attribute28
                      ,pra.attribute29
                      ,pra.attribute30
                      ,pra.fc_res_type_code
                      ,pra.resource_class_code
                      ,pra.organization_id
                      ,pra.job_id
                      ,pra.person_id
                      ,pra.expenditure_type
                      ,pra.expenditure_category
                      ,pra.revenue_category_code
                      ,pra.event_type
                      ,pra.supplier_id
                      ,pra.non_labor_resource
                      ,pra.bom_resource_id
                      ,pra.inventory_item_id
                      ,pra.item_category_id
                      ,1    -- should be 1 in the target version being created
                      ,decode(p_calling_context, 'CREATE_VERSION', NULL, pra.transaction_source_code)
                      ,pra.mfc_cost_type_id
                      ,pra.procure_resource_flag
                      ,pra.assignment_description
                      ,pra.incurred_by_res_flag
                      ,pra.rate_job_id
                      ,pra.rate_expenditure_type
                      ,pra.ta_display_flag
                      ,pra.sp_fixed_date
                      ,pra.person_type_code
                      ,pra.rate_based_flag
                      ,pra.resource_rate_based_flag  --IPM Arch Enhacement Bug 4865563
                      ,pra.use_task_schedule_flag
                      ,pra.rate_exp_func_curr_code
                      ,pra.rate_expenditure_org_id
                      ,pra.incur_by_res_class_code
                      ,pra.incur_by_role_id
                      ,pra.project_role_id
                      ,pra.resource_class_flag
                      ,pra.named_role
                      ,pra.txn_accum_header_id
                      ,scheduled_delay --For Bug 3948128
             FROM     PA_RESOURCE_ASSIGNMENTS pra
             WHERE    pra.budget_version_id = p_source_plan_version_id
             AND      pra.project_id = l_source_project_id ; -- Bug 4493425

     --API is called for copying resource assignments between plan versions that dont belong to the same project
     ELSIF (p_calling_context IS NULL OR p_calling_context='CREATE_VERSION') AND l_source_project_id<>l_target_project_id THEN

         IF l_fin_plan_level_code ='P' THEN

             IF l_control_flag ='N' THEN


                 IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.g_err_stage:='Using the Fourth RA Insert';
                     pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);
                 END IF;

                 INSERT INTO PA_RESOURCE_ASSIGNMENTS(
                          resource_assignment_id
                          ,budget_version_id
                          ,project_id
                          ,task_id
                          ,resource_list_member_id
                          ,last_update_date
                          ,last_updated_by
                          ,creation_date
                          ,created_by
                          ,last_update_login
                          ,unit_of_measure
                          ,track_as_labor_flag
                          ,total_plan_revenue
                          ,total_plan_raw_cost
                          ,total_plan_burdened_cost
                          ,total_plan_quantity
                          ,resource_assignment_type
                          ,total_project_raw_cost
                          ,total_project_burdened_cost
                          ,total_project_revenue
                          ,standard_bill_rate
                          ,average_bill_rate
                          ,average_cost_rate
                          ,project_assignment_id
                          ,plan_error_code
                          ,average_discount_percentage
                          ,total_borrowed_revenue
                          ,total_revenue_adj
                          ,total_lent_resource_cost
                          ,total_cost_adj
                          ,total_unassigned_time_cost
                          ,total_utilization_percent
                          ,total_utilization_hours
                          ,total_utilization_adj
                          ,total_capacity
                          ,total_head_count
                          ,total_head_count_adj
                          ,total_tp_revenue_in
                          ,total_tp_revenue_out
                          ,total_tp_cost_in
                          ,total_tp_cost_out
                          ,parent_assignment_id
                          ,wbs_element_version_id
                          ,rbs_element_id
                          ,planning_start_date
                          ,planning_end_date
                          ,schedule_start_date
                          ,schedule_end_date
                          ,spread_curve_id
                          ,etc_method_code
                          ,res_type_code
                          ,attribute_category
                          ,attribute1
                          ,attribute2
                          ,attribute3
                          ,attribute4
                          ,attribute5
                          ,attribute6
                          ,attribute7
                          ,attribute8
                          ,attribute9
                          ,attribute10
                          ,attribute11
                          ,attribute12
                          ,attribute13
                          ,attribute14
                          ,attribute15
                          ,attribute16
                          ,attribute17
                          ,attribute18
                          ,attribute19
                          ,attribute20
                          ,attribute21
                          ,attribute22
                          ,attribute23
                          ,attribute24
                          ,attribute25
                          ,attribute26
                          ,attribute27
                          ,attribute28
                          ,attribute29
                          ,attribute30
                          ,fc_res_type_code
                          ,resource_class_code
                          ,organization_id
                          ,job_id
                          ,person_id
                          ,expenditure_type
                          ,expenditure_category
                          ,revenue_category_code
                          ,event_type
                          ,supplier_id
                          ,non_labor_resource
                          ,bom_resource_id
                          ,inventory_item_id
                          ,item_category_id
                          ,record_version_number
                          ,transaction_source_code
                          ,mfc_cost_type_id
                          ,procure_resource_flag
                          ,assignment_description
                          ,incurred_by_res_flag
                          ,rate_job_id
                          ,rate_expenditure_type
                          ,ta_display_flag
                          ,sp_fixed_date
                          ,person_type_code
                          ,rate_based_flag
                          ,resource_rate_based_flag --IPM Arch Enhacements Bug 4865563
                          ,use_task_schedule_flag
                          ,rate_exp_func_curr_code
                          ,rate_expenditure_org_id
                          ,incur_by_res_class_code
                          ,incur_by_role_id
                          ,project_role_id
                          ,resource_class_flag
                          ,named_role
                          ,txn_accum_header_id
                          ,scheduled_delay --For Bug 3948128
                          )
                 SELECT
                           pa_resource_assignments_s.nextval
                          ,p_target_plan_version_id
                          ,l_target_project_id
                          ,pra.task_id
                          ,prlmt.resource_list_member_id
                          ,sysdate
                          ,fnd_global.user_id
                          ,sysdate
                          ,fnd_global.user_id
                          ,fnd_global.login_id
                          ,pra.unit_of_measure
                          ,pra.track_as_labor_flag
                          ,DECODE(l_adj_percentage,0,DECODE(l_revenue_flag,'Y',total_plan_revenue,NULL),NULL)
                          ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_plan_raw_cost,NULL),NULL)
                          ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_plan_burdened_cost,NULL),NULL)
                          ,DECODE(l_adj_percentage,0,total_plan_quantity,NULL)
                          ,pra.resource_assignment_type
                          ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_project_raw_cost,NULL),NULL)
                          ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_project_burdened_cost,NULL),NULL)
                          ,DECODE(l_adj_percentage,0,DECODE(l_revenue_flag,'Y',total_project_revenue,NULL),NULL)
                          ,standard_bill_rate
                          ,average_bill_rate
                          ,average_cost_rate
                          ,pra.project_assignment_id
                          ,plan_error_code
                          ,average_discount_percentage
                          ,total_borrowed_revenue
                          ,total_revenue_adj
                          ,total_lent_resource_cost
                          ,total_cost_adj
                          ,total_unassigned_time_cost
                          ,total_utilization_percent
                          ,total_utilization_hours
                          ,total_utilization_adj
                          ,total_capacity
                          ,total_head_count
                          ,total_head_count_adj
                          ,total_tp_revenue_in
                          ,total_tp_revenue_out
                          ,total_tp_cost_in
                          ,total_tp_cost_out
                          --parent assignment id in the target resource assignments contain source resource assignment id
                          --Bug 4200168
                          ,pra.resource_assignment_id
                          ,pra.wbs_element_version_id
                          ,pra.rbs_element_id
                          ,pra.planning_start_date -- Planning start date of the target (Bug 3354518)
                          ,pra.planning_end_date   -- Planning end date of the target  (Bug 3354518)
                          ,pra.schedule_start_date
                          ,pra.schedule_end_date
                          ,pra.spread_curve_id
                          ,pra.etc_method_code
                          ,pra.res_type_code
                          ,pra.attribute_category
                          ,pra.attribute1
                          ,pra.attribute2
                          ,pra.attribute3
                          ,pra.attribute4
                          ,pra.attribute5
                          ,pra.attribute6
                          ,pra.attribute7
                          ,pra.attribute8
                          ,pra.attribute9
                          ,pra.attribute10
                          ,pra.attribute11
                          ,pra.attribute12
                          ,pra.attribute13
                          ,pra.attribute14
                          ,pra.attribute15
                          ,pra.attribute16
                          ,pra.attribute17
                          ,pra.attribute18
                          ,pra.attribute19
                          ,pra.attribute20
                          ,pra.attribute21
                          ,pra.attribute22
                          ,pra.attribute23
                          ,pra.attribute24
                          ,pra.attribute25
                          ,pra.attribute26
                          ,pra.attribute27
                          ,pra.attribute28
                          ,pra.attribute29
                          ,pra.attribute30
                          ,pra.fc_res_type_code
                          ,pra.resource_class_code
                          ,pra.organization_id
                          ,pra.job_id
                          ,pra.person_id
                          ,pra.expenditure_type
                          ,pra.expenditure_category
                          ,pra.revenue_category_code
                          ,pra.event_type
                          ,pra.supplier_id
                          ,pra.non_labor_resource
                          ,pra.bom_resource_id
                          ,pra.inventory_item_id
                          ,pra.item_category_id
                          ,1    -- should be 1 in the target version being created
                          ,decode(p_calling_context, 'CREATE_VERSION', NULL, pra.transaction_source_code)
                          ,pra.mfc_cost_type_id
                          ,pra.procure_resource_flag
                          ,pra.assignment_description
                          ,pra.incurred_by_res_flag
                          ,pra.rate_job_id
                          ,pra.rate_expenditure_type
                          ,pra.ta_display_flag
                          ,pra.sp_fixed_date
                          ,pra.person_type_code
                          ,pra.rate_based_flag
                          ,pra.resource_rate_based_flag  --IPM Arch Enhancement Bug 4865563
                          ,pra.use_task_schedule_flag
                          ,pra.rate_exp_func_curr_code
                          ,pra.rate_expenditure_org_id
                          ,pra.incur_by_res_class_code
                          ,pra.incur_by_role_id
                          ,pra.project_role_id
                          ,pra.resource_class_flag
                          ,pra.named_role
                          ,pra.txn_accum_header_id
                          ,scheduled_delay --For Bug 3948128
                 FROM     PA_RESOURCE_ASSIGNMENTS pra,
                          pa_resource_list_members prlms,
                          pa_resource_list_members prlmt
                 WHERE    pra.budget_version_id      = p_source_plan_version_id
                 AND      prlms.resource_list_member_id=pra.resource_list_member_id
                 AND      prlms.resource_list_id=l_resource_list_id
                 AND      prlms.object_id=l_source_project_id
                 AND      prlms.object_type='PROJECT'
                 AND      prlmt.resource_list_id=l_resource_list_id
                 AND      prlmt.object_id=l_target_project_id
                 AND      prlmt.object_type='PROJECT'
                 AND      prlmt.alias=prlms.alias;

             END IF;--IF l_control_flag ='N' THEN

         ELSIF l_fin_plan_level_code <> 'P' THEN

             IF l_control_flag ='N' THEN


                 IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.g_err_stage:='Using the FIFTH RA Insert';
                     pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);
                 END IF;

                 INSERT INTO PA_RESOURCE_ASSIGNMENTS(
                          resource_assignment_id
                          ,budget_version_id
                          ,project_id
                          ,task_id
                          ,resource_list_member_id
                          ,last_update_date
                          ,last_updated_by
                          ,creation_date
                          ,created_by
                          ,last_update_login
                          ,unit_of_measure
                          ,track_as_labor_flag
                          ,total_plan_revenue
                          ,total_plan_raw_cost
                          ,total_plan_burdened_cost
                          ,total_plan_quantity
                          ,resource_assignment_type
                          ,total_project_raw_cost
                          ,total_project_burdened_cost
                          ,total_project_revenue
                          ,standard_bill_rate
                          ,average_bill_rate
                          ,average_cost_rate
                          ,project_assignment_id
                          ,plan_error_code
                          ,average_discount_percentage
                          ,total_borrowed_revenue
                          ,total_revenue_adj
                          ,total_lent_resource_cost
                          ,total_cost_adj
                          ,total_unassigned_time_cost
                          ,total_utilization_percent
                          ,total_utilization_hours
                          ,total_utilization_adj
                          ,total_capacity
                          ,total_head_count
                          ,total_head_count_adj
                          ,total_tp_revenue_in
                          ,total_tp_revenue_out
                          ,total_tp_cost_in
                          ,total_tp_cost_out
                          ,parent_assignment_id
                          ,wbs_element_version_id
                          ,rbs_element_id
                          ,planning_start_date
                          ,planning_end_date
                          ,schedule_start_date
                          ,schedule_end_date
                          ,spread_curve_id
                          ,etc_method_code
                          ,res_type_code
                          ,attribute_category
                          ,attribute1
                          ,attribute2
                          ,attribute3
                          ,attribute4
                          ,attribute5
                          ,attribute6
                          ,attribute7
                          ,attribute8
                          ,attribute9
                          ,attribute10
                          ,attribute11
                          ,attribute12
                          ,attribute13
                          ,attribute14
                          ,attribute15
                          ,attribute16
                          ,attribute17
                          ,attribute18
                          ,attribute19
                          ,attribute20
                          ,attribute21
                          ,attribute22
                          ,attribute23
                          ,attribute24
                          ,attribute25
                          ,attribute26
                          ,attribute27
                          ,attribute28
                          ,attribute29
                          ,attribute30
                          ,fc_res_type_code
                          ,resource_class_code
                          ,organization_id
                          ,job_id
                          ,person_id
                          ,expenditure_type
                          ,expenditure_category
                          ,revenue_category_code
                          ,event_type
                          ,supplier_id
                          ,non_labor_resource
                          ,bom_resource_id
                          ,inventory_item_id
                          ,item_category_id
                          ,record_version_number
                          ,transaction_source_code
                          ,mfc_cost_type_id
                          ,procure_resource_flag
                          ,assignment_description
                          ,incurred_by_res_flag
                          ,rate_job_id
                          ,rate_expenditure_type
                          ,ta_display_flag
                          ,sp_fixed_date
                          ,person_type_code
                          ,rate_based_flag
                          ,resource_rate_based_flag --IPM Arch Enhancements Bug 4865563
                          ,use_task_schedule_flag
                          ,rate_exp_func_curr_code
                          ,rate_expenditure_org_id
                          ,incur_by_res_class_code
                          ,incur_by_role_id
                          ,project_role_id
                          ,resource_class_flag
                          ,named_role
                          ,txn_accum_header_id
                          ,scheduled_delay --For Bug 3948128
                          )
                 SELECT
                           pa_resource_assignments_s.nextval
                          ,p_target_plan_version_id
                          ,l_target_project_id
                          ,pelm.target_task_id
                          ,prlmt.resource_list_member_id
                          ,sysdate
                          ,fnd_global.user_id
                          ,sysdate
                          ,fnd_global.user_id
                          ,fnd_global.login_id
                          ,pra.unit_of_measure
                          ,pra.track_as_labor_flag
                          ,DECODE(l_adj_percentage,0,DECODE(l_revenue_flag,'Y',total_plan_revenue,NULL),NULL)
                          ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_plan_raw_cost,NULL),NULL)
                          ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_plan_burdened_cost,NULL),NULL)
                          ,DECODE(l_adj_percentage,0,total_plan_quantity,NULL)
                          ,pra.resource_assignment_type
                          ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_project_raw_cost,NULL),NULL)
                          ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_project_burdened_cost,NULL),NULL)
                          ,DECODE(l_adj_percentage,0,DECODE(l_revenue_flag,'Y',total_project_revenue,NULL),NULL)
                          ,standard_bill_rate
                          ,average_bill_rate
                          ,average_cost_rate
                          ,pra.project_assignment_id
                          ,plan_error_code
                          ,average_discount_percentage
                          ,total_borrowed_revenue
                          ,total_revenue_adj
                          ,total_lent_resource_cost
                          ,total_cost_adj
                          ,total_unassigned_time_cost
                          ,total_utilization_percent
                          ,total_utilization_hours
                          ,total_utilization_adj
                          ,total_capacity
                          ,total_head_count
                          ,total_head_count_adj
                          ,total_tp_revenue_in
                          ,total_tp_revenue_out
                          ,total_tp_cost_in
                          ,total_tp_cost_out
                          --parent assignment id in the target resource assignments contain source resource assignment id
                          --Bug 4200168
                          ,pra.resource_assignment_id
                          ,pra.wbs_element_version_id
                          ,pra.rbs_element_id
                          ,pra.planning_start_date -- Planning start date of the target (Bug 3354518)
                          ,pra.planning_end_date   -- Planning end date of the target  (Bug 3354518)
                          ,pra.schedule_start_date
                          ,pra.schedule_end_date
                          ,pra.spread_curve_id
                          ,pra.etc_method_code
                          ,pra.res_type_code
                          ,pra.attribute_category
                          ,pra.attribute1
                          ,pra.attribute2
                          ,pra.attribute3
                          ,pra.attribute4
                          ,pra.attribute5
                          ,pra.attribute6
                          ,pra.attribute7
                          ,pra.attribute8
                          ,pra.attribute9
                          ,pra.attribute10
                          ,pra.attribute11
                          ,pra.attribute12
                          ,pra.attribute13
                          ,pra.attribute14
                          ,pra.attribute15
                          ,pra.attribute16
                          ,pra.attribute17
                          ,pra.attribute18
                          ,pra.attribute19
                          ,pra.attribute20
                          ,pra.attribute21
                          ,pra.attribute22
                          ,pra.attribute23
                          ,pra.attribute24
                          ,pra.attribute25
                          ,pra.attribute26
                          ,pra.attribute27
                          ,pra.attribute28
                          ,pra.attribute29
                          ,pra.attribute30
                          ,pra.fc_res_type_code
                          ,pra.resource_class_code
                          ,pra.organization_id
                          ,pra.job_id
                          ,pra.person_id
                          ,pra.expenditure_type
                          ,pra.expenditure_category
                          ,pra.revenue_category_code
                          ,pra.event_type
                          ,pra.supplier_id
                          ,pra.non_labor_resource
                          ,pra.bom_resource_id
                          ,pra.inventory_item_id
                          ,pra.item_category_id
                          ,1    -- should be 1 in the target version being created
                          ,decode(p_calling_context, 'CREATE_VERSION', NULL, pra.transaction_source_code)
                          ,pra.mfc_cost_type_id
                          ,pra.procure_resource_flag
                          ,pra.assignment_description
                          ,pra.incurred_by_res_flag
                          ,pra.rate_job_id
                          ,pra.rate_expenditure_type
                          ,pra.ta_display_flag
                          ,pra.sp_fixed_date
                          ,pra.person_type_code
                          ,pra.rate_based_flag
                          ,pra.resource_rate_based_flag --IPM Arch Enhancements Bug 4865563
                          ,pra.use_task_schedule_flag
                          ,pra.rate_exp_func_curr_code
                          ,pra.rate_expenditure_org_id
                          ,pra.incur_by_res_class_code
                          ,pra.incur_by_role_id
                          ,pra.project_role_id
                          ,pra.resource_class_flag
                          ,pra.named_role
                          ,pra.txn_accum_header_id
                          ,scheduled_delay --For Bug 3948128
                 FROM     PA_RESOURCE_ASSIGNMENTS pra,
                          (SELECT TO_NUMBER(attribute15) source_task_id,
                                  proj_element_id  target_task_id
                           FROM   pa_proj_elements
                           WHERE  project_id = l_target_project_id
                           AND    object_type = 'PA_TASKS'
                           UNION ALL
                           SELECT 0 source_task_id,
                                  0 target_task_id
                           FROM   dual) pelm,
                          pa_resource_list_members prlms,
                          pa_resource_list_members prlmt
                 WHERE    pra.budget_version_id      = p_source_plan_version_id
                 AND      prlms.resource_list_member_id=pra.resource_list_member_id
                 AND      prlms.resource_list_id=l_resource_list_id
                 AND      prlms.object_id=l_source_project_id
                 AND      prlms.object_type='PROJECT'
                 AND      prlmt.resource_list_id=l_resource_list_id
                 AND      prlmt.object_id=l_target_project_id
                 AND      prlmt.object_type='PROJECT'
                 AND      prlmt.alias=prlms.alias
                 AND      pelm.source_task_id=pra.task_id;

             ELSE --Control Flag is Y and Planning Level is not project

                 IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.g_err_stage:='Using the Sixth RA Insert';
                     pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);
                 END IF;

                 INSERT INTO PA_RESOURCE_ASSIGNMENTS(
                          resource_assignment_id
                          ,budget_version_id
                          ,project_id
                          ,task_id
                          ,resource_list_member_id
                          ,last_update_date
                          ,last_updated_by
                          ,creation_date
                          ,created_by
                          ,last_update_login
                          ,unit_of_measure
                          ,track_as_labor_flag
                          ,total_plan_revenue
                          ,total_plan_raw_cost
                          ,total_plan_burdened_cost
                          ,total_plan_quantity
                          ,resource_assignment_type
                          ,total_project_raw_cost
                          ,total_project_burdened_cost
                          ,total_project_revenue
                          ,standard_bill_rate
                          ,average_bill_rate
                          ,average_cost_rate
                          ,project_assignment_id
                          ,plan_error_code
                          ,average_discount_percentage
                          ,total_borrowed_revenue
                          ,total_revenue_adj
                          ,total_lent_resource_cost
                          ,total_cost_adj
                          ,total_unassigned_time_cost
                          ,total_utilization_percent
                          ,total_utilization_hours
                          ,total_utilization_adj
                          ,total_capacity
                          ,total_head_count
                          ,total_head_count_adj
                          ,total_tp_revenue_in
                          ,total_tp_revenue_out
                          ,total_tp_cost_in
                          ,total_tp_cost_out
                          ,parent_assignment_id
                          ,wbs_element_version_id
                          ,rbs_element_id
                          ,planning_start_date
                          ,planning_end_date
                          ,schedule_start_date
                          ,schedule_end_date
                          ,spread_curve_id
                          ,etc_method_code
                          ,res_type_code
                          ,attribute_category
                          ,attribute1
                          ,attribute2
                          ,attribute3
                          ,attribute4
                          ,attribute5
                          ,attribute6
                          ,attribute7
                          ,attribute8
                          ,attribute9
                          ,attribute10
                          ,attribute11
                          ,attribute12
                          ,attribute13
                          ,attribute14
                          ,attribute15
                          ,attribute16
                          ,attribute17
                          ,attribute18
                          ,attribute19
                          ,attribute20
                          ,attribute21
                          ,attribute22
                          ,attribute23
                          ,attribute24
                          ,attribute25
                          ,attribute26
                          ,attribute27
                          ,attribute28
                          ,attribute29
                          ,attribute30
                          ,fc_res_type_code
                          ,resource_class_code
                          ,organization_id
                          ,job_id
                          ,person_id
                          ,expenditure_type
                          ,expenditure_category
                          ,revenue_category_code
                          ,event_type
                          ,supplier_id
                          ,non_labor_resource
                          ,bom_resource_id
                          ,inventory_item_id
                          ,item_category_id
                          ,record_version_number
                          ,transaction_source_code
                          ,mfc_cost_type_id
                          ,procure_resource_flag
                          ,assignment_description
                          ,incurred_by_res_flag
                          ,rate_job_id
                          ,rate_expenditure_type
                          ,ta_display_flag
                          ,sp_fixed_date
                          ,person_type_code
                          ,rate_based_flag
                          ,resource_rate_based_flag --IPM Arch Enhancements Bug 4865563
                          ,use_task_schedule_flag
                          ,rate_exp_func_curr_code
                          ,rate_expenditure_org_id
                          ,incur_by_res_class_code
                          ,incur_by_role_id
                          ,project_role_id
                          ,resource_class_flag
                          ,named_role
                          ,txn_accum_header_id
                          ,scheduled_delay --For Bug 3948128
                          )
                 SELECT
                           pa_resource_assignments_s.nextval
                          ,p_target_plan_version_id
                          ,l_target_project_id
                          ,pelm.target_task_id
                          ,pra.resource_list_member_id
                          ,sysdate
                          ,fnd_global.user_id
                          ,sysdate
                          ,fnd_global.user_id
                          ,fnd_global.login_id
                          ,pra.unit_of_measure
                          ,pra.track_as_labor_flag
                          ,DECODE(l_adj_percentage,0,DECODE(l_revenue_flag,'Y',total_plan_revenue,NULL),NULL)
                          ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_plan_raw_cost,NULL),NULL)
                          ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_plan_burdened_cost,NULL),NULL)
                          ,DECODE(l_adj_percentage,0,total_plan_quantity,NULL)
                          ,pra.resource_assignment_type
                          ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_project_raw_cost,NULL),NULL)
                          ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_project_burdened_cost,NULL),NULL)
                          ,DECODE(l_adj_percentage,0,DECODE(l_revenue_flag,'Y',total_project_revenue,NULL),NULL)
                          ,standard_bill_rate
                          ,average_bill_rate
                          ,average_cost_rate
                          ,pra.project_assignment_id
                          ,plan_error_code
                          ,average_discount_percentage
                          ,total_borrowed_revenue
                          ,total_revenue_adj
                          ,total_lent_resource_cost
                          ,total_cost_adj
                          ,total_unassigned_time_cost
                          ,total_utilization_percent
                          ,total_utilization_hours
                          ,total_utilization_adj
                          ,total_capacity
                          ,total_head_count
                          ,total_head_count_adj
                          ,total_tp_revenue_in
                          ,total_tp_revenue_out
                          ,total_tp_cost_in
                          ,total_tp_cost_out
                          --parent assignment id in the target resource assignments contain source resource assignment id
                          --Bug 4200168
                          ,pra.resource_assignment_id
                          ,pra.wbs_element_version_id
                          ,pra.rbs_element_id
                          ,pra.planning_start_date -- Planning start date of the target (Bug 3354518)
                          ,pra.planning_end_date   -- Planning end date of the target  (Bug 3354518)
                          ,pra.schedule_start_date
                          ,pra.schedule_end_date
                          ,pra.spread_curve_id
                          ,pra.etc_method_code
                          ,pra.res_type_code
                          ,pra.attribute_category
                          ,pra.attribute1
                          ,pra.attribute2
                          ,pra.attribute3
                          ,pra.attribute4
                          ,pra.attribute5
                          ,pra.attribute6
                          ,pra.attribute7
                          ,pra.attribute8
                          ,pra.attribute9
                          ,pra.attribute10
                          ,pra.attribute11
                          ,pra.attribute12
                          ,pra.attribute13
                          ,pra.attribute14
                          ,pra.attribute15
                          ,pra.attribute16
                          ,pra.attribute17
                          ,pra.attribute18
                          ,pra.attribute19
                          ,pra.attribute20
                          ,pra.attribute21
                          ,pra.attribute22
                          ,pra.attribute23
                          ,pra.attribute24
                          ,pra.attribute25
                          ,pra.attribute26
                          ,pra.attribute27
                          ,pra.attribute28
                          ,pra.attribute29
                          ,pra.attribute30
                          ,pra.fc_res_type_code
                          ,pra.resource_class_code
                          ,pra.organization_id
                          ,pra.job_id
                          ,pra.person_id
                          ,pra.expenditure_type
                          ,pra.expenditure_category
                          ,pra.revenue_category_code
                          ,pra.event_type
                          ,pra.supplier_id
                          ,pra.non_labor_resource
                          ,pra.bom_resource_id
                          ,pra.inventory_item_id
                          ,pra.item_category_id
                          ,1    -- should be 1 in the target version being created
                          ,decode(p_calling_context, 'CREATE_VERSION', NULL, pra.transaction_source_code)
                          ,pra.mfc_cost_type_id
                          ,pra.procure_resource_flag
                          ,pra.assignment_description
                          ,pra.incurred_by_res_flag
                          ,pra.rate_job_id
                          ,pra.rate_expenditure_type
                          ,pra.ta_display_flag
                          ,pra.sp_fixed_date
                          ,pra.person_type_code
                          ,pra.rate_based_flag
                          ,pra.resource_rate_based_flag --IPM Arch Enhancements Bug 4865563
                          ,pra.use_task_schedule_flag
                          ,pra.rate_exp_func_curr_code
                          ,pra.rate_expenditure_org_id
                          ,pra.incur_by_res_class_code
                          ,pra.incur_by_role_id
                          ,pra.project_role_id
                          ,pra.resource_class_flag
                          ,pra.named_role
                          ,pra.txn_accum_header_id
                          ,scheduled_delay --For Bug 3948128
                 FROM     PA_RESOURCE_ASSIGNMENTS pra,
                          (SELECT TO_NUMBER(attribute15) source_task_id,
                                  proj_element_id  target_task_id
                           FROM   pa_proj_elements
                           WHERE  project_id = l_target_project_id
                           AND    object_type='PA_TASKS'
                           UNION ALL
                           SELECT 0 source_task_id,
                                  0 target_task_id
                           FROM   dual) pelm
                 WHERE    pra.budget_version_id= p_source_plan_version_id
                 AND      pelm.source_task_id=pra.task_id;

             END IF;--IF l_control_flag ='N' THEN

         END IF;--ELSIF l_fin_plan_level_code <> 'P' THEN

     END IF;--IF p_rbs_map_diff_flag ='N' THEN

     l_tmp := SQL%ROWCOUNT;
     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='No. of records inserted into PRA '||l_tmp;
         pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;
     /** Bug 6161031 When we copy the resource assignments ideally we should call the
         PA_PLANNING_RESOURCE_UTILS.get_resource_defaults and use the new
         attributes. But organization_id is the only column which is depending
         on the project when the resource format contains job and doesn't contain organization_id.
         So for all resource assignments with resource format having job in workplan if the
         organiztion_id is null in the pa_resource_list_members we are overriding
         with current project carrying_out_organization_id.
     */
     IF p_calling_context='WORKPLAN' THEN

             select ppa.carrying_out_organization_id
             into l_project_org
             from pa_projects_all ppa,
                  pa_budget_versions pbv
             where pbv.budget_version_id = p_target_plan_version_id
             and pbv.project_id = ppa.project_id;

             update pa_resource_assignments
             set organization_id=l_project_org
             where resource_assignment_id in
                 (select pra.resource_assignment_id
                  from pa_resource_assignments pra,
                       pa_resource_list_members prlm
                  where pra.budget_version_id=p_target_plan_version_id
                  and   pra.resource_list_member_id=prlm.resource_list_member_id
                  and   pra.job_id  = prlm.job_id
                  and   prlm.organization_id is null);
     END IF;

     -- Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------
     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='Exiting Copy_Resource_Assignments';
         pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);
         pa_debug.reset_err_stack;  -- bug:- 2815593
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

          IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage:='Invalid Arguments Passed';
              pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,5);
              pa_debug.reset_err_stack;
	END IF;
          RAISE;

   WHEN Others THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_count     := 1;
         x_msg_data      := SQLERRM;
         FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_FP_COPY_FROM_PKG'
                          ,p_procedure_name  => 'COPY_RESOURCE_ASSIGNMENTS');

         IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,5);
             pa_debug.reset_err_stack;
	 END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END Copy_Resource_Assignments;

  --Bug 4290043.This private API will be called from  copy_budget_lines and Copy_Budget_Lines_Appr_Rev in this package
  --This API will
  ----1. Call pa_fp_upgrade_pkg.Apply_Calculate_FPM_Rules to get the missing amounts/rates in the target version
  ----2. Call PA_FP_CALC_PLAN_PKG.CheckZeroQTyNegETC to check for the negative ETC/Qty in the target version
  ----3. Update rate based flag for RAs in the target version if any RAs have to be converted to non rate based
  ----4. Update the budget lines with the missing amounts
  PROCEDURE derv_missing_amts_chk_neg_qty
  (p_budget_version_id            IN  pa_budget_versions.budget_version_id%TYPE,
   p_targ_pref_code               IN  pa_proj_fp_options.fin_plan_preference_code%TYPE,
   p_source_version_type          IN  pa_budget_versions.version_type%TYPE,
   p_target_version_type          IN  pa_budget_versions.version_type%TYPE,
   p_src_plan_class_code          IN  pa_fin_plan_types_b.plan_class_code%TYPE,
   p_derv_rates_missing_amts_flag IN  VARCHAR2,
   p_adj_percentage               IN  NUMBER,
   x_return_status                OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                     OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
   IS

    l_msg_count                    NUMBER ;
    l_data                         VARCHAR2(2000);
    l_msg_data                     VARCHAR2(2000);
    l_error_msg_code               VARCHAR2(2000);
    l_msg_index_out                NUMBER;
    l_return_status                VARCHAR2(2000);
    l_debug_mode                   VARCHAR2(30);
    l_module_name                  VARCHAR2(100);

    l_bl_id_tbl                    SYSTEM.pa_num_tbl_type;
    l_ra_id_tbl                    SYSTEM.pa_num_tbl_type;
    l_quantity_tbl                 SYSTEM.pa_num_tbl_type;
    l_txn_raw_cost_tbl             SYSTEM.pa_num_tbl_type;
    l_txn_burdened_cost_tbl        SYSTEM.pa_num_tbl_type;
    l_txn_revenue_tbl              SYSTEM.pa_num_tbl_type;
    l_rate_based_flag_tbl          SYSTEM.pa_varchar2_1_tbl_type;
    l_raw_cost_override_rate_tbl   SYSTEM.pa_num_tbl_type;
    l_burd_cost_override_rate_tbl  SYSTEM.pa_num_tbl_type;
    l_bill_override_rate_tbl       SYSTEM.pa_num_tbl_type;
    l_non_rb_ra_id_tbl             SYSTEM.pa_num_tbl_type;
    l_bl_rb_flag_chg_tbl           SYSTEM.pa_varchar2_1_tbl_type;
    l_target_pref_code             pa_proj_fp_options.fin_plan_preference_code%TYPE;
    l_prev_ra_id                   pa_resource_assignments.resource_assignment_id%TYPE;
    l_temp_flag                    VARCHAR2(1);
    l_init_quantity_tbl            SYSTEM.pa_num_tbl_type;
    l_txn_currency_code_tbl        SYSTEM.pa_varchar2_15_tbl_type;
    l_temp                         NUMBER;

    /*  Bug 5078538 --Added the out variables to avoid the uninitialized collection
        error. Note that this error is caused when the same variables are passed as
        In and In Out parameters in a api call.
    */
    l_quantity_out_tbl                 SYSTEM.pa_num_tbl_type;
    l_txn_raw_cost_out_tbl             SYSTEM.pa_num_tbl_type;
    l_txn_burdened_cost_out_tbl        SYSTEM.pa_num_tbl_type;
    l_txn_revenue_out_tbl              SYSTEM.pa_num_tbl_type;

    BEGIN

        x_msg_count := 0;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
        l_debug_mode := NVL(l_debug_mode, 'Y');
        l_module_name := 'PAFPCPFB.mis_amts_chk_neg_qty';

        -- Set curr function
        IF l_debug_mode='Y' THEN
            pa_debug.set_curr_function(
                    p_function   =>'PAFPCPFB.mis_amts_chk_neg_qty'
                   ,p_debug_mode => l_debug_mode );

            pa_debug.g_err_stage:= 'Validation Input Parameters';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,5);

        END IF;


        IF  p_budget_version_id     IS NULL OR
            p_targ_pref_code        IS NULL OR
            p_source_version_type   IS NULL OR
            p_target_version_type   IS NULL OR
            p_src_plan_class_code   IS NULL OR
            p_derv_rates_missing_amts_flag IS NULL THEN

            IF l_debug_mode='Y' THEN

                pa_debug.g_err_stage:= 'p_budget_version_id '|| p_budget_version_id;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,5);

                pa_debug.g_err_stage:= 'p_targ_pref_code '|| p_targ_pref_code;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,5);

                pa_debug.g_err_stage:= 'p_source_version_type '|| p_source_version_type;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,5);

                pa_debug.g_err_stage:= 'p_target_version_type '|| p_target_version_type;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,5);

                pa_debug.g_err_stage:= 'p_src_plan_class_code '|| p_src_plan_class_code;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,5);

                pa_debug.g_err_stage:= 'p_derv_rates_missing_amts_flag '|| p_derv_rates_missing_amts_flag;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,5);

            END IF;

            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name        => 'PA_FP_INV_PARAM_PASSED',
                                p_token1          => 'PROCEDURENAME',
                                p_value1          => l_module_name,
                                p_token2          => 'STAGE',
                                p_value2          => 'Invalid Input Params');


            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

        END IF;


        --Select the budget lines in the target that should be processed for missing amounts and negative ETC/Qty Check
        SELECT  bl.budget_line_id
            ,bl.resource_assignment_id
            ,nvl(bl.quantity,0)
            ,nvl(bl.txn_raw_cost,0)
            ,nvl(bl.txn_burdened_cost,0)
            ,nvl(bl.txn_revenue,0)
            ,nvl(ra.rate_based_flag,'N') rate_based_flag
            ,nvl(bl.init_quantity,0)
            ,bl.txn_currency_code
        BULK COLLECT INTO
             l_bl_id_tbl
            ,l_ra_id_tbl
            ,l_quantity_tbl
            ,l_txn_raw_cost_tbl
            ,l_txn_burdened_cost_tbl
            ,l_txn_revenue_tbl
            ,l_rate_based_flag_tbl
            ,l_init_quantity_tbl
            ,l_txn_currency_code_tbl
        FROM    pa_budget_lines bl
            ,pa_resource_assignments ra
        WHERE  bl.resource_assignment_id=ra.resource_assignment_id
        AND    bl.budget_version_id=p_budget_version_id
        AND    ra.budget_version_id=p_budget_version_id
        ORDER  BY bl.resource_assignment_id ,bl.quantity NULLS FIRST;

        --Retrun if no budget lines exist in the target
        IF l_bl_id_tbl.COUNT =0 THEN

            IF l_debug_mode='Y' THEN

                pa_debug.g_err_stage:= 'Budget Line count is 0';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,5);

                pa_debug.reset_curr_function;
            END IF;

            RETURN;

        END IF;

        --Derive the missing amounts/rates in the target.
        IF p_derv_rates_missing_amts_flag='Y' THEN

            IF l_debug_mode='Y' THEN

                pa_debug.g_err_stage:= 'Calling pa_fp_upgrade_pkg.Apply_Calculate_FPM_Rules';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

            END IF;

            pa_fp_upgrade_pkg.Apply_Calculate_FPM_Rules
            ( p_preference_code              => p_targ_pref_code
             ,p_resource_assignment_id_tbl   => l_ra_id_tbl
             ,p_rate_based_flag_tbl          => l_rate_based_flag_tbl
             ,p_quantity_tbl                 => l_quantity_tbl
             ,p_txn_raw_cost_tbl             => l_txn_raw_cost_tbl
             ,p_txn_burdened_cost_tbl        => l_txn_burdened_cost_tbl
             ,p_txn_revenue_tbl              => l_txn_revenue_tbl
             ,x_quantity_tbl                 => l_quantity_out_tbl           --Bug 5078538
             ,x_txn_raw_cost_tbl             => l_txn_raw_cost_out_tbl       --Bug 5078538
             ,x_txn_burdened_cost_tbl        => l_txn_burdened_cost_out_tbl  --Bug 5078538
             ,x_txn_revenue_tbl              => l_txn_revenue_out_tbl        --Bug 5078538
             ,x_raw_cost_override_rate_tbl   => l_raw_cost_override_rate_tbl
             ,x_burd_cost_override_rate_tbl  => l_burd_cost_override_rate_tbl
             ,x_bill_override_rate_tbl       => l_bill_override_rate_tbl
             ,x_non_rb_ra_id_tbl             => l_non_rb_ra_id_tbl
             ,x_return_status                => l_return_status
             ,x_msg_count                    => l_msg_count
             ,x_msg_data                     => l_msg_data);

             IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                 IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:= 'Error in pa_fp_upgrade_pkg.Apply_Calculate_FPM_Rules';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
                 END IF;
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
             END IF;

            l_quantity_tbl              :=   l_quantity_out_tbl;            --Bug 5078538
            l_txn_raw_cost_tbl          :=   l_txn_raw_cost_out_tbl;        --Bug 5078538
            l_txn_burdened_cost_tbl     :=   l_txn_burdened_cost_out_tbl;   --Bug 5078538
            l_txn_revenue_tbl           :=   l_txn_revenue_out_tbl;         --Bug 5078538

             IF p_source_version_type<>'ALL' AND
                p_src_plan_class_code <>'FORECAST' AND
                l_non_rb_ra_id_tbl.COUNT > 0 THEN


                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name        => 'PA_FP_INV_PARAM_PASSED',
                                    p_token1          => 'PROCEDURENAME',
                                    p_value1          => l_module_name,
                                    p_token2          => 'STAGE',
                                    p_value2          => 'l_non_rb_ra_id_tbl.count for Non All Fcst version is '||l_non_rb_ra_id_tbl.COUNT);


                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;

	    END IF;--IF p_derv_rates_missing_amts_flag='Y' THEN

 	 /*
 	   Bug 5726773: Commented out the below debug statement as the call to api PA_FP_CALC_PLAN_PKG.CheckZeroQTyNegETC
 	    has been commented out.
 	 */
 	 /*

            IF l_debug_mode='Y' THEN

                pa_debug.g_err_stage:= 'Calling PA_FP_CALC_PLAN_PKG.CheckZeroQTyNegETC';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

            END IF;
	*/

	/* Bug 5726773:
 	    Start of coding done for Support of negative quantity/amounts enhancement.
 	    Call to the API CheckZeroQtyNegETC has been commented out below to allow
 	    copying of -ve quantity/amounts from the source version to target version.
 	*/

        --Negative ETC/Qty for the budget lines in the target will be performed whenever the amounts in the source
        --or not copied directly (i.e. if the amounts in the source are modified while copying into target either
        --for deriving missing amounts or because of applying adj % )
	/*
        IF p_adj_percentage <> 0 OR
           p_derv_rates_missing_amts_flag ='Y' THEN

            --Call the API to check for Negative ETC. Bug 4290043
            PA_FP_CALC_PLAN_PKG.CheckZeroQTyNegETC(
                                p_calling_context            => 'PLS_TBL'
                               ,p_budget_version_id          => p_budget_version_id
                               ,p_initialize                 => 'Y'
                               ,p_resource_assignment_id_tbl => l_ra_id_tbl
                               ,p_quantity_tbl               => l_quantity_tbl
                               ,p_init_quantity_tbl          => l_init_quantity_tbl
                               ,p_txn_currency_code_tbl      => l_txn_currency_code_tbl
                               ,x_return_status              => l_return_status
                               ,x_msg_count                  => l_msg_count
                               ,x_msg_data                   => l_msg_data);

            IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                 IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:= 'Error in PA_FP_CALC_PLAN_PKG.CheckZeroQTyNegETC';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
                 END IF;
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

        END IF;--IF p_adj_percentage <> 0 OR
	 */
 	/* Bug 5726773: End of coding done for Support of negative quantity/amounts enhancement. */

        --Update the budget lines with the missing amounts/rates derived above.In the update the amount/rate
        --returned by the Apply_Calculate_FPM_Rules will be stamped on budget lines only when the rejection
        --codes do not exist for those budget lines.
        IF p_derv_rates_missing_amts_flag='Y' THEN

            IF l_debug_mode='Y' THEN

                pa_debug.g_err_stage:= 'p_source_version_type '||p_source_version_type;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                pa_debug.g_err_stage:= 'p_target_version_type '||p_target_version_type;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

            END IF;

            IF p_source_version_type='COST' THEN

                IF p_target_version_type='COST' THEN

                    FORALL kk IN 1..l_bl_id_tbl.COUNT

                        UPDATE pa_budget_lines
                        SET    txn_cost_rate_override    = DECODE(cost_rejection_code, NULL,l_raw_cost_override_rate_tbl(kk),txn_cost_rate_override),
                               burden_cost_rate_override = DECODE(burden_rejection_code, NULL,l_burd_cost_override_rate_tbl(kk),burden_cost_rate_override)
                        WHERE  budget_line_id = l_bl_id_tbl(kk);

                ELSIF p_target_version_type='ALL' THEN

                    FORALL kk IN 1..l_bl_id_tbl.COUNT

                        UPDATE pa_budget_lines
                        SET    txn_cost_rate_override    = DECODE(cost_rejection_code, NULL,l_raw_cost_override_rate_tbl(kk),txn_cost_rate_override),
                               burden_cost_rate_override = DECODE(burden_rejection_code, NULL,l_burd_cost_override_rate_tbl(kk),burden_cost_rate_override),
                               txn_revenue               = DECODE(revenue_rejection_code, NULL,l_txn_revenue_tbl(kk),txn_revenue),
                               txn_bill_rate_override    = DECODE(revenue_rejection_code, NULL,l_bill_override_rate_tbl(kk),txn_bill_rate_override)
                        WHERE  budget_line_id = l_bl_id_tbl(kk);

                END IF;

            ELSIF p_source_version_type='REVENUE' THEN

                IF p_target_version_type='REVENUE' THEN

                    FORALL kk IN 1..l_bl_id_tbl.COUNT

                        UPDATE pa_budget_lines
                        SET    txn_bill_rate_override    = DECODE(revenue_rejection_code, NULL,l_bill_override_rate_tbl(kk),txn_bill_rate_override)
                        WHERE  budget_line_id = l_bl_id_tbl(kk);

                ELSIF p_target_version_type='ALL' THEN

                    FORALL kk IN 1..l_bl_id_tbl.COUNT

                        UPDATE pa_budget_lines
                        SET    quantity                  = l_quantity_tbl(kk),
			       txn_raw_cost              = DECODE(cost_rejection_code, NULL,l_txn_raw_cost_tbl(kk),txn_raw_cost),
                               txn_burdened_cost         = DECODE(burden_rejection_code, NULL,l_txn_burdened_cost_tbl(kk),txn_burdened_cost),
                               txn_cost_rate_override    = DECODE(cost_rejection_code, NULL,l_raw_cost_override_rate_tbl(kk),txn_cost_rate_override),
                               burden_cost_rate_override = DECODE(burden_rejection_code, NULL,l_burd_cost_override_rate_tbl(kk),burden_cost_rate_override),
                               txn_bill_rate_override    = DECODE(revenue_rejection_code, NULL,l_bill_override_rate_tbl(kk),txn_bill_rate_override)
                        WHERE  budget_line_id = l_bl_id_tbl(kk);

                END IF;

            ELSIF p_source_version_type='ALL' THEN

                --In case of an All Forecast version, there can be budget lines with actuals in which revenue
                --alone is populated and other amounts are null. When these budget lines are copied into a
                --version which is not an All Forecats version then the corresponding resource assignments in the
                --target will be made non rate based. The below DML updates all such resource assignments to non rate based

                --Update the rate based flag to N for the ids in l_non_rb_ra_id_tbl
                FORALL kk IN 1..l_non_rb_ra_id_tbl.COUNT

                    UPDATE pa_resource_assignments
                    SET    rate_based_flag = 'N'
                          ,unit_of_measure = 'DOLLARS'
                    WHERE  resource_assignment_id=l_non_rb_ra_id_tbl(kk);

                --The pa_fp_upgrade_pkg.Apply_Calculate_FPM_Rules API will return a pl-sql tbl of RA ids which can
                --be made non rate based. Note that this might not be equal in length to the input l_ra_id_tbl to that API
                --The below block will prepare a pl-sql tbl l_bl_rb_flag_chg_tbl which will be equal in length to l_ra_id_tbl
                --This tbl will have Y if the ra id is made non rate based . Otherwise it will contain N
                l_bl_rb_flag_chg_tbl := SYSTEM.pa_varchar2_1_tbl_type();
                IF p_src_plan_class_code = 'FORECAST' THEN

                    IF l_debug_mode='Y' THEN

                        FOR kk IN 1..l_non_rb_ra_id_tbl.COUNT LOOP

                            pa_debug.g_err_stage:= 'l_non_rb_ra_id_tbl('||kk||')'||l_non_rb_ra_id_tbl(kk);
                            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                        END LOOP;

                        FOR kk IN 1..l_ra_id_tbl.COUNT LOOP

                            pa_debug.g_err_stage:= 'l_ra_id_tbl('||kk||')'||l_ra_id_tbl(kk);
                            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                        END LOOP;

                    END IF;

                    l_temp:=1;
                    FOR kk IN 1..l_non_rb_ra_id_tbl.COUNT LOOP

                        LOOP
                            EXIT WHEN l_non_rb_ra_id_tbl(kk)= l_ra_id_tbl(l_temp);
                            l_bl_rb_flag_chg_tbl.extend;
                            l_bl_rb_flag_chg_tbl(l_temp):='N';
                            l_temp := l_temp+1;
                        END LOOP;

                        l_prev_ra_id := l_ra_id_tbl(l_temp);
                        LOOP
                            l_bl_rb_flag_chg_tbl.extend;
                            l_bl_rb_flag_chg_tbl(l_temp) := 'Y';
                            l_temp := l_temp + 1;
                            EXIT WHEN l_temp > l_ra_id_tbl.COUNT OR l_ra_id_tbl(l_temp) <> l_prev_ra_id;

                        END LOOP;

                    END LOOP;

                END IF;

                IF l_debug_mode='Y' THEN

                    pa_debug.g_err_stage:= 'l_bl_rb_flag_chg_tbl.COUNT '||l_bl_rb_flag_chg_tbl.COUNT;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                END IF;

                FOR kk IN l_bl_rb_flag_chg_tbl.COUNT+1..l_ra_id_tbl.COUNT LOOP

                    l_bl_rb_flag_chg_tbl.extend;
                    l_bl_rb_flag_chg_tbl(kk):='N';

                END LOOP;

                IF l_debug_mode='Y' THEN

                    pa_debug.g_err_stage:= 'l_bl_rb_flag_chg_tbl.COUNT '||l_bl_rb_flag_chg_tbl.COUNT;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    pa_debug.g_err_stage:= 'l_ra_id_tbl.COUNT '||l_ra_id_tbl.COUNT;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

                    FOR kk IN 1..l_bl_rb_flag_chg_tbl.COUNT LOOP

                        pa_debug.g_err_stage:= 'l_bl_rb_flag_chg_tbl('||kk||')'||l_bl_rb_flag_chg_tbl(kk);
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                    END LOOP;

                END IF;


                --The below block will update the budget lines with missing amounts.
                ----If the resource assignment assignment is made non rate based then the amount returned by the
                ----Apply_Calculate_FPM_Rules will be stamped on budget lines. Also the rejection codes for that amount
                ----will be NULLed out accordingly
                IF p_target_version_type='COST' THEN

                    FORALL kk IN 1..l_bl_id_tbl.COUNT

                        UPDATE pa_budget_lines
                        SET    quantity                  = l_quantity_tbl(kk),
                               txn_raw_cost              = DECODE (l_bl_rb_flag_chg_tbl(kk),
                                                                   'Y',l_txn_raw_cost_tbl(kk),
                                                                   DECODE(cost_rejection_code,
                                                                          NULL,l_txn_raw_cost_tbl(kk),
                                                                          txn_raw_cost)),
                               txn_burdened_cost         = DECODE (l_bl_rb_flag_chg_tbl(kk),
                                                                   'Y',l_txn_burdened_cost_tbl(kk),
                                                                   DECODE(burden_rejection_code,
                                                                          NULL,l_txn_burdened_cost_tbl(kk),
                                                                          txn_burdened_cost)),
                               txn_cost_rate_override    = DECODE (l_bl_rb_flag_chg_tbl(kk),
                                                                   'Y',l_raw_cost_override_rate_tbl(kk),
                                                                   DECODE(cost_rejection_code,
                                                                          NULL,l_raw_cost_override_rate_tbl(kk),
                                                                          txn_cost_rate_override)),
                               burden_cost_rate_override = DECODE (l_bl_rb_flag_chg_tbl(kk),
                                                                   'Y',l_burd_cost_override_rate_tbl(kk),
                                                                   DECODE(burden_rejection_code,
                                                                          NULL,l_burd_cost_override_rate_tbl(kk),
                                                                          burden_cost_rate_override)),
                               cost_rejection_code       = DECODE (l_bl_rb_flag_chg_tbl(kk),
                                                                   'Y',NULL,
                                                                   cost_rejection_code),
                               burden_rejection_code     = DECODE (l_bl_rb_flag_chg_tbl(kk),
                                                                   'Y',NULL,
                                                                   burden_rejection_code)
                        WHERE  budget_line_id = l_bl_id_tbl(kk);



                ELSIF p_target_version_type='REVENUE' THEN

                    FORALL kk IN 1..l_bl_id_tbl.COUNT

                        UPDATE pa_budget_lines
                        SET    quantity                 = l_quantity_tbl(kk),
                               txn_revenue              = DECODE (l_bl_rb_flag_chg_tbl(kk),
                                                                  'Y',l_txn_revenue_tbl(kk),
                                                                  DECODE(revenue_rejection_code,
                                                                         NULL,l_txn_revenue_tbl(kk),
                                                                         txn_revenue)),
                               txn_bill_rate_override   = DECODE (l_bl_rb_flag_chg_tbl(kk),
                                                                  'Y',l_bill_override_rate_tbl(kk),
                                                                  DECODE(revenue_rejection_code,
                                                                         NULL,l_bill_override_rate_tbl(kk),
                                                                         txn_bill_rate_override)),
                               revenue_rejection_code   = DECODE (l_bl_rb_flag_chg_tbl(kk),
                                                                  'Y',NULL,
                                                                  revenue_rejection_code)
                        WHERE  budget_line_id = l_bl_id_tbl(kk);

                ELSIF p_target_version_type='ALL' THEN

                    FORALL kk IN 1..l_bl_id_tbl.COUNT

                        UPDATE pa_budget_lines
                        SET    quantity                  = l_quantity_tbl(kk),
                               txn_raw_cost              = DECODE (l_bl_rb_flag_chg_tbl(kk),
                                                                   'Y',l_txn_raw_cost_tbl(kk),
                                                                   DECODE(cost_rejection_code,
                                                                          NULL,l_txn_raw_cost_tbl(kk),
                                                                          txn_raw_cost)),
                               txn_burdened_cost         = DECODE (l_bl_rb_flag_chg_tbl(kk),
                                                                   'Y',l_txn_burdened_cost_tbl(kk),
                                                                   DECODE(burden_rejection_code,
                                                                          NULL,l_txn_burdened_cost_tbl(kk),
                                                                          txn_burdened_cost)),
                               txn_revenue              = DECODE (l_bl_rb_flag_chg_tbl(kk),
                                                                  'Y',l_txn_revenue_tbl(kk),
                                                                  DECODE(revenue_rejection_code,
                                                                         NULL,l_txn_revenue_tbl(kk),
                                                                         txn_revenue)),
                               txn_cost_rate_override    = DECODE (l_bl_rb_flag_chg_tbl(kk),
                                                                   'Y',l_raw_cost_override_rate_tbl(kk),
                                                                   DECODE(cost_rejection_code,
                                                                          NULL,l_raw_cost_override_rate_tbl(kk),
                                                                          txn_cost_rate_override)),
                               burden_cost_rate_override = DECODE (l_bl_rb_flag_chg_tbl(kk),
                                                                   'Y',l_burd_cost_override_rate_tbl(kk),
                                                                   DECODE(burden_rejection_code,
                                                                          NULL,l_burd_cost_override_rate_tbl(kk),
                                                                          burden_cost_rate_override)),
                               txn_bill_rate_override   = DECODE (l_bl_rb_flag_chg_tbl(kk),
                                                                  'Y',l_bill_override_rate_tbl(kk),
                                                                  DECODE(revenue_rejection_code,
                                                                         NULL,l_bill_override_rate_tbl(kk),
                                                                         txn_bill_rate_override)),
                               cost_rejection_code      = DECODE (l_bl_rb_flag_chg_tbl(kk),
                                                                   'Y',NULL,
                                                                   cost_rejection_code),
                               burden_rejection_code    = DECODE (l_bl_rb_flag_chg_tbl(kk),
                                                                   'Y',NULL,
                                                                   burden_rejection_code),
                               revenue_rejection_code   = DECODE (l_bl_rb_flag_chg_tbl(kk),
                                                                  'Y',NULL,
                                                                  revenue_rejection_code)

                        WHERE  budget_line_id = l_bl_id_tbl(kk);

                END IF;

            END IF;--IF l_source_version_type='COST' THEN

        END IF;--IF p_derv_rates_missing_amts_flag='Y' THEN

        IF l_debug_mode='Y' THEN

            pa_debug.g_err_stage:= 'Leaving '||l_module_name;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,5);

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
           pa_debug.write( l_module_name,pa_debug.g_err_stage,5);
        -- reset curr function
           pa_debug.reset_curr_function();
        END IF;
        RETURN;
        WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;

        FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'pa_fp_copy_from_pkg'
                               ,p_procedure_name  => 'derv_missing_amts_chk_neg_qty');

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write( l_module_name,pa_debug.g_err_stage,5);
        -- reset curr function
            pa_debug.reset_curr_function();
        END IF;
        RAISE;

    END derv_missing_amts_chk_neg_qty;



  /*=========================================================================
      This api inserts budget lines for target using source budget lines. If
      the adjustment percentage is zero, this api will copy from source to
      target version without modifying any amounts. If adjustment percentage is
      non-zero,then we don't copy project and project functional columns as
      these  need to be converted again and might cause rounding issues
      This is an overloaded procedure

-- r11.5 FP.M Developement ----------------------------------
--
-- 08-JAN-04 jwhite          - Bug 3362316
--                             Rewrote Copy_Budget_Lines
--
    --Bug 4290043. Introduced the paramters p_copy_actuals_flag and p_derv_rates_missing_amts_flag.
    --These will be passed from copy_version API. p_copy_actuals_flag indicates whether to copy the
    --actuals from the source version or not. p_derv_rates_missing_amts_flag indicates whether the
    --target version contains missing amounts rates which should be derived after copy
   =========================================================================*/

  PROCEDURE Copy_Budget_Lines(
             p_source_plan_version_id         IN  NUMBER
             ,p_target_plan_version_id        IN  NUMBER
             ,p_adj_percentage                IN  NUMBER
             ,p_copy_actuals_flag             IN  VARCHAR2
             ,p_derv_rates_missing_amts_flag  IN  VARCHAR2
             ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
             ,x_msg_data                      OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
   AS

         l_msg_count          NUMBER :=0;
         l_data               VARCHAR2(2000);
         l_msg_data           VARCHAR2(2000);
         l_error_msg_code     VARCHAR2(2000);
         l_msg_index_out      NUMBER;
         l_return_status      VARCHAR2(2000);
         l_debug_mode         VARCHAR2(30);

         l_source_period_profile_id  pa_budget_versions.period_profile_id%TYPE;
         l_target_period_profile_id  pa_budget_versions.period_profile_id%TYPE;

         l_revenue_flag       pa_fin_plan_amount_sets.revenue_flag%type;
         l_cost_flag          pa_fin_plan_amount_sets.raw_cost_flag%type;

         l_adj_percentage            NUMBER ;
         l_period_profiles_same_flag VARCHAR2(1);

         l_src_plan_class_code      pa_fin_plan_types_b.plan_class_code%TYPE;
         l_trg_plan_class_code      pa_fin_plan_types_b.plan_class_code%TYPE;
         l_wp_version_flag      pa_budget_versions.wp_version_flag%TYPE;

         l_etc_start_date       pa_budget_versions.etc_start_date%TYPE;
         l_temp                 NUMBER;

         l_source_version_type    pa_budget_versions.version_type%TYPE;
         l_target_version_type    pa_budget_versions.version_type%TYPE;
         l_source_project_id      pa_budget_versions.project_id%TYPE; -- Bug 4493425
         l_target_project_id      pa_budget_versions.project_id%TYPE; -- Bug 4493425

         -- Bug 4493425: Added pbv.project_id in the select.
         CURSOR get_plan_class_code_csr(c_budget_version_id pa_budget_versions.budget_version_id%TYPE) IS
         SELECT pfb.plan_class_code,nvl(pbv.wp_version_flag,'N'),etc_start_date,pbv.version_type,pbv.project_id
         FROM   pa_fin_plan_types_b pfb,
                pa_budget_versions  pbv
         WHERE  pbv.budget_version_id = c_budget_version_id
         AND    pbv.fin_plan_type_id  = pfb.fin_plan_type_id;
         -- Bug 3927244

         --Bug 4290043
         l_target_pref_code             pa_proj_fp_options.fin_plan_preference_code%TYPE;


   BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.set_err_stack('PA_FP_COPY_FROM_PKG.Copy_Budget_Lines');
END IF;
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.set_process('PLSQL','LOG',l_debug_mode);
END IF;
      -- Checking for all valid input parametrs

      IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage := 'Checking for valid parameters:';
          pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;

      IF (p_source_plan_version_id IS NULL) OR
         (p_target_plan_version_id IS NULL)
      THEN

           IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage := 'Source_plan='||p_source_plan_version_id;
               pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,5);
               pa_debug.g_err_stage := 'Target_plan'||p_target_plan_version_id;
               pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,5);
           END IF;

           PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                                p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage := 'Parameter validation complete';
          pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;
/*
      pa_debug.g_err_stage:='Source fin plan version id'||p_source_plan_version_id;
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;
      pa_debug.g_err_stage:='Target fin plan version id'||p_target_plan_version_id;
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;
*/
      --make adj percentage zero if passed as null

      l_adj_percentage := NVL(p_adj_percentage,0);
/*
       pa_debug.g_err_stage:='Adj_percentage'||l_adj_percentage;
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
       END IF;
*/
       -- Fetching the flags of target version using fin_plan_prefernce_code


       IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Fetching the raw_cost,burdened_cost and revenue flags of target_version';
           pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
       END IF;

       --Bug 4290043. Selected preference code for the target version
       SELECT DECODE(fin_plan_preference_code          -- l_revenue_flag
                       ,PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY ,'Y'
                       ,PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME ,'Y','N')
              ,DECODE(fin_plan_preference_code          -- l_cost_flag
                      ,PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY ,'Y'
                      ,PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME , 'Y','N')
              ,fin_plan_preference_code
       INTO   l_revenue_flag
              ,l_cost_flag
              ,l_target_pref_code
       FROM   pa_proj_fp_options
       WHERE  fin_plan_version_id=p_target_plan_version_id;
/*
       pa_debug.g_err_stage:='l_revenue_flag ='||l_revenue_flag;
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
       END IF;
       pa_debug.g_err_stage:='l_cost_flag ='||l_cost_flag;
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
       END IF;
*/
       -- Checking if source and target version period profiles match

       /* FPB2: REVIEW */


       IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Inserting  budget_lines';
           pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
       END IF;

       -- Bug 3927244: Actuals need to be copied from forecast to forecast within the same project for FINPLAN versions

       -- Bug 4493425: Added l_source_project_id in the INTO clause.
       OPEN  get_plan_class_code_csr(p_source_plan_version_id);
       FETCH get_plan_class_code_csr
       INTO  l_src_plan_class_code,l_wp_version_flag,l_etc_start_date,l_source_version_type,l_source_project_id;
       CLOSE get_plan_class_code_csr;

       -- Bug 4493425: Added l_target_project_id in the INTO clause.
       OPEN  get_plan_class_code_csr(p_target_plan_version_id);
       FETCH get_plan_class_code_csr
       INTO  l_trg_plan_class_code,l_wp_version_flag,l_etc_start_date,l_target_version_type,l_target_project_id;
       CLOSE get_plan_class_code_csr;


       -- Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------
       --Bug 4052403. For non rate-based transactions quantity should be same as raw cost if the version type is COST/ALL or
       --it should be revenue if the version type is REVENUE. This business rule will be taken care by the API
       --PA_FP_MULTI_CURRENCY_PKG.Round_Budget_Line_Amounts which is called after this INSERT. Note that this has to be done only
       --when adjustment% is not null since the amounts in the source will be altered only when the user enters some adj %
       --Bug 4188225. PC/PFC buckets will be copied unconditionally (Removed the condition that checks for l_adj_percentage
       --being greater than 0 in order to copy)

       --Bug 4290043.Used p_copy_actuals_flag and p_derv_rates_missing_amts_flag to decide on copying actuals/rates
       --If p_derv_rates_missing_amts_flag is Y then rates will not be copied and the derv_missing_amts_chk_neg_qty
       --API called later on will stamp them on budget lines
       --Display_quantity is being set in copy_version and copy_finplans_from_project api as well
       INSERT INTO PA_BUDGET_LINES(
                budget_line_id             /* FPB2 */
               ,budget_version_id          /* FPB2 */
               ,resource_assignment_id
               ,start_date
               ,last_update_date
               ,last_updated_by
               ,creation_date
               ,created_by
               ,last_update_login
               ,end_date
               ,period_name
               ,quantity
               ,display_quantity   --IPM Arch Enhancement Bug 4865563.
               ,raw_cost
               ,burdened_cost
               ,revenue
               ,change_reason_code
               ,description
               ,attribute_category
               ,attribute1
               ,attribute2
               ,attribute3
               ,attribute4
               ,attribute5
               ,attribute6
               ,attribute7
               ,attribute8
               ,attribute9
               ,attribute10
               ,attribute11
               ,attribute12
               ,attribute13
               ,attribute14
               ,attribute15
               ,raw_cost_source
               ,burdened_cost_source
               ,quantity_source
               ,revenue_source
               ,pm_product_code
               ,pm_budget_line_reference
               ,cost_rejection_code
               ,revenue_rejection_code
               ,burden_rejection_code
               ,other_rejection_code
               ,code_combination_id
               ,ccid_gen_status_code
               ,ccid_gen_rej_message
               ,request_id
               ,borrowed_revenue
               ,tp_revenue_in
               ,tp_revenue_out
               ,revenue_adj
               ,lent_resource_cost
               ,tp_cost_in
               ,tp_cost_out
               ,cost_adj
               ,unassigned_time_cost
               ,utilization_percent
               ,utilization_hours
               ,utilization_adj
               ,capacity
               ,head_count
               ,head_count_adj
               ,projfunc_currency_code
               ,projfunc_cost_rate_type
               ,projfunc_cost_exchange_rate
               ,projfunc_cost_rate_date_type
               ,projfunc_cost_rate_date
               ,projfunc_rev_rate_type
               ,projfunc_rev_exchange_rate
               ,projfunc_rev_rate_date_type
               ,projfunc_rev_rate_date
               ,project_currency_code
               ,project_cost_rate_type
               ,project_cost_exchange_rate
               ,project_cost_rate_date_type
               ,project_cost_rate_date
               ,project_raw_cost
               ,project_burdened_cost
               ,project_rev_rate_type
               ,project_rev_exchange_rate
               ,project_rev_rate_date_type
               ,project_rev_rate_date
               ,project_revenue
               ,txn_raw_cost
               ,txn_burdened_cost
               ,txn_currency_code
               ,txn_revenue
               ,bucketing_period_code
               ,transfer_price_rate
               ,init_quantity
               ,init_quantity_source
               ,init_raw_cost
               ,init_burdened_cost
               ,init_revenue
               ,init_raw_cost_source
               ,init_burdened_cost_source
               ,init_revenue_source
               ,project_init_raw_cost
               ,project_init_burdened_cost
               ,project_init_revenue
               ,txn_init_raw_cost
               ,txn_init_burdened_cost
               ,txn_init_revenue
               ,txn_markup_percent
               ,txn_markup_percent_override
               ,txn_discount_percentage
               ,txn_standard_bill_rate
               ,txn_standard_cost_rate
               ,txn_cost_rate_override
               ,burden_cost_rate
               ,txn_bill_rate_override
               ,burden_cost_rate_override
               ,cost_ind_compiled_set_id
               ,pc_cur_conv_rejection_code
               ,pfc_cur_conv_rejection_code
)
     SELECT     pa_budget_lines_s.nextval      /* FPB2 */
               ,p_target_plan_version_id     /* FPB2 */
               ,pra.resource_assignment_id
               ,pbl.start_date
               ,sysdate
               ,fnd_global.user_id
               ,sysdate
               ,fnd_global.user_id
               ,fnd_global.login_id
               ,pbl.end_date
               ,pbl.period_name
               ,pbl.quantity
               ,pbl.display_quantity    --IPM Arch Enhancement Bug 4865563.
               ,DECODE(l_cost_flag,'Y', raw_cost,NULL)
               ,DECODE(l_cost_flag,'Y', burdened_cost,NULL)
               ,DECODE(l_revenue_flag,'Y', revenue,NULL)
               ,pbl.change_reason_code
               ,description
               ,pbl.attribute_category
               ,pbl.attribute1
               ,pbl.attribute2
               ,pbl.attribute3
               ,pbl.attribute4
               ,pbl.attribute5
               ,pbl.attribute6
               ,pbl.attribute7
               ,pbl.attribute8
               ,pbl.attribute9
               ,pbl.attribute10
               ,pbl.attribute11
               ,pbl.attribute12
               ,pbl.attribute13
               ,pbl.attribute14
               ,pbl.attribute15
               ,DECODE(l_cost_flag,'Y',PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_COPY_P,NULL) --raw_cost_souce
               ,DECODE(l_cost_flag,'Y',PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_COPY_P,NULL) --burdened_cost_source
               ,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_COPY_P  --quantity_source
               ,DECODE(l_revenue_flag,'Y',PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_COPY_P,NULL) --revenue source
               ,pbl.pm_product_code
               ,pbl.pm_budget_line_reference
               ,DECODE(l_cost_flag, 'Y',cost_rejection_code, NULL)
               ,DECODE(l_revenue_flag, 'Y',revenue_rejection_code, NULL)
               ,DECODE(l_cost_flag,'Y',burden_rejection_code, NULL)
               ,other_rejection_code
               ,code_combination_id
               ,ccid_gen_status_code
               ,ccid_gen_rej_message
               ,fnd_global.conc_request_id
               ,borrowed_revenue
               ,tp_revenue_in
               ,tp_revenue_out
               ,revenue_adj
               ,lent_resource_cost
               ,tp_cost_in
               ,tp_cost_out
               ,cost_adj
               ,unassigned_time_cost
               ,utilization_percent
               ,utilization_hours
               ,utilization_adj
               ,capacity
               ,head_count
               ,head_count_adj
               ,projfunc_currency_code
               ,DECODE(l_cost_flag,'Y',projfunc_cost_rate_type,NULL)
               ,DECODE(l_cost_flag,'Y',projfunc_cost_exchange_rate,NULL)
               ,DECODE(l_cost_flag,'Y',projfunc_cost_rate_date_type,NULL)
               ,DECODE(l_cost_flag,'Y',projfunc_cost_rate_date,NULL)
               ,DECODE(l_revenue_flag,'Y',projfunc_rev_rate_type,NULL)
               ,DECODE(l_revenue_flag,'Y',projfunc_rev_exchange_rate,NULL)
               ,DECODE(l_revenue_flag,'Y',projfunc_rev_rate_date_type,NULL)
               ,DECODE(l_revenue_flag,'Y',projfunc_rev_rate_date,NULL)
               ,project_currency_code
               ,DECODE(l_cost_flag,'Y',project_cost_rate_type,NULL)
               ,DECODE(l_cost_flag,'Y',project_cost_exchange_rate,NULL)
               ,DECODE(l_cost_flag,'Y',project_cost_rate_date_type,NULL)
               ,DECODE(l_cost_flag,'Y',project_cost_rate_date,NULL)
               ,DECODE(l_cost_flag,'Y', project_raw_cost,NULL)
               ,DECODE(l_cost_flag,'Y', project_burdened_cost,NULL)
               ,DECODE(l_revenue_flag,'Y',project_rev_rate_type,NULL)
               ,DECODE(l_revenue_flag,'Y',project_rev_exchange_rate,NULL)
               ,DECODE(l_revenue_flag,'Y',project_rev_rate_date_type,NULL)
               ,DECODE(l_revenue_flag,'Y',project_rev_rate_date,NULL)
               ,DECODE(l_revenue_flag,'Y', project_revenue,NULL)
               ,DECODE(l_cost_flag,'Y',
                       decode(GREATEST(pbl.start_date,NVL(l_etc_start_date,pbl.start_date)),pbl.start_date,txn_raw_cost*(1+l_adj_percentage),txn_raw_cost),NULL)
               ,DECODE(l_cost_flag,'Y',
                       decode(GREATEST(pbl.start_date,NVL(l_etc_start_date,pbl.start_date)),pbl.start_date,txn_burdened_cost*(1+l_adj_percentage),txn_burdened_cost),NULL)
               ,txn_currency_code
               ,DECODE(l_revenue_flag,'Y',
                        decode(GREATEST(pbl.start_date,NVL(l_etc_start_date,pbl.start_date)),pbl.start_date,txn_revenue*(1+l_adj_percentage),txn_revenue),NULL)
               ,DECODE(l_period_profiles_same_flag,'Y',bucketing_period_code,NULL)
               ,transfer_price_rate
               ,decode(p_copy_actuals_flag,'N',NULL,pbl.init_quantity)              --init_quantity
               ,decode(p_copy_actuals_flag,'N',NULL,pbl.init_quantity_source)       --init_quantity_source
               ,DECODE(l_cost_flag,'Y',decode(p_copy_actuals_flag,'N',NULL,pbl.init_raw_cost),NULL)                   --init_raw_cost
               ,DECODE(l_cost_flag,'Y',decode(p_copy_actuals_flag,'N',NULL,pbl.init_burdened_cost),NULL)         --init_burdened_cost
               ,DECODE(l_revenue_flag,'Y',decode(p_copy_actuals_flag,'N',NULL,pbl.init_revenue),NULL)                     --init_revenue
               ,DECODE(l_cost_flag,'Y',decode(p_copy_actuals_flag,'N',NULL,pbl.init_raw_cost_source),NULL)            --init_raw_cost_source
               ,DECODE(l_cost_flag,'Y',decode(p_copy_actuals_flag,'N',NULL,pbl.init_burdened_cost_source),NULL)  --init_burdened_cost_source
               ,DECODE(l_revenue_flag,'Y',decode(p_copy_actuals_flag,'N',NULL,pbl.init_revenue_source),NULL)              --init_revenue_source
               ,DECODE(l_cost_flag,'Y',decode(p_copy_actuals_flag,'N',NULL,pbl.project_init_raw_cost),NULL)           --project_init_raw_cost
               ,DECODE(l_cost_flag,'Y',decode(p_copy_actuals_flag,'N',NULL,pbl.project_init_burdened_cost),NULL) --project_init_burdened_cost
               ,DECODE(l_revenue_flag,'Y',decode(p_copy_actuals_flag,'N',NULL,pbl.project_init_revenue),NULL)             --project_init_revenue
               ,DECODE(l_cost_flag,'Y',decode(p_copy_actuals_flag,'N',NULL,pbl.txn_init_raw_cost),NULL)               --txn_init_raw_cost
               ,DECODE(l_cost_flag,'Y',decode(p_copy_actuals_flag,'N',NULL,pbl.txn_init_burdened_cost),NULL)     --txn_init_burdened_cost
               ,DECODE(l_revenue_flag,'Y',decode(p_copy_actuals_flag,'N',NULL,pbl.txn_init_revenue),NULL)                 --txn_init_revenue
               ,txn_markup_percent
               ,txn_markup_percent_override
               ,txn_discount_percentage
               ,Decode(l_revenue_flag,'Y',DECODE(p_derv_rates_missing_amts_flag,'N',txn_standard_bill_rate,NULL),NULL) --txn_standard_bill_rate
               ,Decode(l_cost_flag,'Y',DECODE(p_derv_rates_missing_amts_flag,'N',txn_standard_cost_rate,NULL),NULL) --txn_standard_cost_rate
               ,Decode(l_cost_flag,'Y',DECODE(p_derv_rates_missing_amts_flag,'N',txn_cost_rate_override,NULL),NULL) --txn_cost_rate_override
               ,Decode(l_cost_flag,'Y',DECODE(p_derv_rates_missing_amts_flag,'N',burden_cost_rate,NULL),NULL)       --burden_cost_rate
               ,Decode(l_revenue_flag,'Y',DECODE(p_derv_rates_missing_amts_flag,'N',txn_bill_rate_override,NULL),NULL) --txn_bill_rate_override
               ,Decode(l_cost_flag,'Y',DECODE(p_derv_rates_missing_amts_flag,'N',burden_cost_rate_override,NULL),NULL) --burden_cost_rate_override
               ,cost_ind_compiled_set_id
               ,Decode(l_adj_percentage,0,pc_cur_conv_rejection_code,null)
               ,Decode(l_adj_percentage,0,pfc_cur_conv_rejection_code,null)
       FROM PA_BUDGET_LINES  pbl
            ,pa_resource_assignments pra
       WHERE pbl.resource_assignment_id = pra.parent_assignment_id
         AND pbl.budget_version_id = p_source_plan_version_id
         AND pra.budget_version_id = p_target_plan_version_id
         AND pra.project_id = l_target_project_id; -- Bug 4493425.

        l_temp:=SQL%ROWCOUNT;

       IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='No. of Budget lines inserted '||l_temp;
           pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
       END IF;

       --Populate the pa_fp_bl_map_tmp table so that the MRC API can have the mapping readily defined.
       --The logic of inserting into pa_budget_lines using pa_fp_bl_map_tmp is removed for bug  4224703
       --The below table need not be popluated for worplan versions since MRC is not maintained for
       --workplan versions
       IF l_wp_version_flag='N' THEN

           INSERT INTO pa_fp_bl_map_tmp
           (source_budget_line_id,
            target_budget_line_id)
            SELECT pbls.budget_line_id,
                   pblt.budget_line_id
            FROM   pa_budget_lines pblt,
                   pa_budget_lines pbls,
                   pa_resource_assignments prat
            WHERE  pblt.budget_version_id=p_target_plan_version_id
            AND    prat.budget_version_id=p_target_plan_version_id
            AND    prat.project_id = l_target_project_id -- Bug 4493425.
            AND    prat.resource_assignment_id=pblt.resource_assignment_id
            AND    prat.parent_assignment_id=pbls.resource_assignment_id
            AND    pblt.start_date=pbls.start_date
            AND    pblt.txn_currency_code=pbls.txn_currency_code;
            l_temp:=SQL%ROWCOUNT;

            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage:='No. of mrc mappling lines inserted '||l_temp;
                pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;

      END IF;


       -- End, Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------

       -- Bug 4035856 Call rounding api if l_adj_percentage is not zero
       IF l_adj_percentage <> 0 THEN
            PA_FP_MULTI_CURRENCY_PKG.Round_Budget_Line_Amounts
                   (  p_budget_version_id     => p_target_plan_version_id
                     ,p_calling_context       => 'COPY_VERSION'
                     ,x_return_status         => l_return_status
                     ,x_msg_count             => l_msg_count
                     ,x_msg_data              => l_msg_data);

             IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                 IF P_PA_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:= 'Error in PA_FP_MULTI_CURRENCY_PKG.Round_Budget_Line_Amounts';
                      pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,5);
                 END IF;
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
             END IF;
       END IF;

       --Bug 4290043. Call the API to correct the missing amounts in the target version in case it can have
       --missing amounts/rates
       IF p_derv_rates_missing_amts_flag = 'Y' OR
          l_adj_percentage <> 0 THEN


            derv_missing_amts_chk_neg_qty
            (p_budget_version_id            => p_target_plan_version_id,
             p_targ_pref_code               => l_target_pref_code,
             p_source_version_type          => l_source_version_type,
             p_target_version_type          => l_target_version_type,
             p_src_plan_class_code          => l_src_plan_class_code,
             p_derv_rates_missing_amts_flag => p_derv_rates_missing_amts_flag,
             p_adj_percentage               => l_adj_percentage,
             x_return_status                => l_return_status,
             x_msg_count                    => l_msg_count,
             x_msg_data                     => l_msg_data);

             IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                 IF P_PA_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:= 'Error in derv_missing_amts_chk_neg_qty';
                      pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,5);
                 END IF;
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;

       END IF;--IF p_derv_rates_missing_amts_flag = 'Y' THEN

       IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Exiting Copy_Budget_Lines';
           pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
           pa_debug.reset_err_stack;    -- bug:- 2815593
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
               pa_debug.g_err_stage:='Invalid arguments passed';
               pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,5);
                pa_debug.reset_err_stack;
	END IF;
           RAISE;

    WHEN Others THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_FP_COPY_FROM_PKG'
                            ,p_procedure_name  => 'COPY_BUDGET_LINES');

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:='Unexpected error'||SQLERRM;
            pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,6);
            pa_debug.reset_err_stack;
	END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END Copy_Budget_Lines;

/*===========================================================================
  This api copies proj period denorm res_assignment records from source
  version to target version.This api would be called only when the adjustment
  percentage is zero and period profile ids of the source and target versions
  are same.
 ==========================================================================*/

 PROCEDURE Copy_Periods_Denorm(
           p_source_plan_version_id   IN NUMBER
           ,p_target_plan_version_id  IN NUMBER
           ,p_calling_module          IN VARCHAR2
           ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count               OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data                OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 AS

       l_msg_count          NUMBER :=0;
       l_data               VARCHAR2(2000);
       l_msg_data           VARCHAR2(2000);
       l_error_msg_code     VARCHAR2(2000);
       l_msg_index_out      NUMBER;
       l_return_status      VARCHAR2(2000);
       l_debug_mode         VARCHAR2(30);
       l_ignore_amount_type pa_proj_periods_denorm.amount_type_code%TYPE;
       l_target_project_id  pa_projects.project_id%TYPE;

 BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.set_err_stack('PA_FP_COPY_FROM_PKG.Copy_Periods_Denorm');
END IF;
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.set_process('PLSQL','LOG',l_debug_mode);
END IF;
    -- Checking for all valid input parametrs


    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'Checking for valid parameters:';
        pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_source_plan_version_id IS NULL) OR
       (p_target_plan_version_id IS NULL) OR
       (p_calling_module IS NULL)
    THEN


         IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage := 'Source_plan='||p_source_plan_version_id;
             pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,5);
             pa_debug.g_err_stage := 'Target_plan = '||p_target_plan_version_id;
             pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,5);
             pa_debug.g_err_stage := 'Calling_module = '||p_calling_module;
             pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,5);
         END IF;

         PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'Parameter validation complete';
        pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;
/*
    pa_debug.g_err_stage := 'Source_plan='||p_source_plan_version_id;
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;
    pa_debug.g_err_stage := 'Target_plan = '||p_target_plan_version_id;
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;
    pa_debug.g_err_stage := 'Calling_module = '||p_calling_module;
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;
*/
      -- Evaluating which records are to be copied using amount type code of
      -- pa_proj_periods_denorm and fin paln preference code of the target  version

     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='Evaluating which records are to be copied';
         pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     SELECT DECODE(fin_plan_preference_code
                   ,PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY ,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE
                   ,PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY ,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST
                   ,PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME ,'-99') --copy both cost and revenue
            ,project_id
     INTO   l_ignore_amount_type
            ,l_target_project_id
     FROM   pa_proj_fp_options
     WHERE  fin_plan_version_id=p_target_plan_version_id;
/*
     pa_debug.g_err_stage:='l_ignore_amount_type = '||l_ignore_amount_type;
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;
     pa_debug.g_err_stage := 'l_target_project_id = '||l_target_project_id;
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;
*/
      INSERT INTO PA_PROJ_PERIODS_DENORM(
                budget_version_id
                ,project_id
                ,resource_assignment_id
                ,object_id
                ,object_type_code
                ,period_profile_id
                ,amount_type_code
                ,amount_subtype_code
                ,amount_type_id
                ,amount_subtype_id
                ,currency_type
                ,currency_code
                ,preceding_periods_amount
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
                ,period_amount52
                ,last_update_date
                ,last_updated_by
                ,creation_date
                ,created_by
                ,last_update_login
                ,parent_assignment_id)
     SELECT     p_target_plan_version_id   --budget_version_id
                ,l_target_project_id       --project_id
                ,pfrmt.target_res_assignment_id  --resource_assignment_id
/* Bug# 2677867 - Object_id shoudl always be res assgnmnt id irrespect of FP or ORG_FCST
                ,DECODE(p_calling_module
                        ,PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_ORG_FORECAST ,pfrmt.target_res_assignment_id
                        ,PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN , -1)    --object_id
*/
                ,pfrmt.target_res_assignment_id
                ,PA_FP_CONSTANTS_PKG.G_OBJECT_TYPE_RES_ASSIGNMENT    --object_type_code
                ,period_profile_id
                ,amount_type_code
                ,amount_subtype_code
                ,amount_type_id
                ,amount_subtype_id
                ,currency_type
                ,currency_code
                ,preceding_periods_amount
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
                ,period_amount52
                ,sysdate
                ,fnd_global.user_id
                ,sysdate
                ,fnd_global.user_id
                ,fnd_global.login_id
                ,pfrmt.parent_assignment_id --parent_assignment_id
     FROM    PA_PROJ_PERIODS_DENORM pppd
             ,PA_FP_RA_MAP_TMP  pfrmt
     WHERE   budget_version_id = p_source_plan_version_id
       AND   pppd.resource_assignment_id = pfrmt.source_res_assignment_id
       AND   pppd.object_type_code = PA_FP_CONSTANTS_PKG.G_OBJECT_TYPE_RES_ASSIGNMENT
       AND   pppd.amount_type_code <> l_ignore_amount_type;

     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='Exiting Copy_Periods_Denorm';
         pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
         pa_debug.reset_err_stack;  --bug:- 2815593
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
             pa_debug.g_err_stage:='Invalid arguments passed';
             pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,5);
             pa_debug.reset_err_stack;
	END IF;
         RAISE;

    WHEN Others THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_FP_COPY_FROM_PKG'
                                 ,p_procedure_name  => 'Copy_Periods_Denorm');

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:='Unexpected error'||SQLERRM;
            pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,6);
            pa_debug.reset_err_stack;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

 END Copy_Periods_Denorm;




/*===================================================================
  This api copies all the budgets from source project to target
  project.this api only take care of the non upgraded budget versions
  and is based on the existing logic in pa_project_core1.copy_project.
  The output error parameters are designed to be in sync with existing
  code in pa_project_core1.copy_project
===================================================================*/

PROCEDURE Copy_Budgets_From_Project(
                   p_from_project_id        IN  NUMBER
                   ,p_to_project_id         IN  NUMBER
                   ,p_delta                 IN  NUMBER
                   ,p_orig_template_flag    IN  VARCHAR2
                   ,p_agreement_amount      IN  NUMBER   -- Added for bug 2986930
                   ,p_baseline_funding_flag IN  VARCHAR2 -- Added for bug 2986930
                   ,x_err_code              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                   ,x_err_stage             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                   ,x_err_stack             OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

    l_return_status             VARCHAR2(2000);
    l_msg_count                 NUMBER :=0;
    l_msg_data                  VARCHAR2(2000);
    x_delta                     NUMBER;
    x_new_project_id            pa_projects.project_id%TYPE;
    x_orig_project_id           pa_projects.project_id%TYPE;
    x_orig_template_flag        pa_projects.template_flag%TYPE;
    l_agreement_amount          NUMBER; -- Added for bug 2986930
    l_baseline_funding_flag     VARCHAR2(1); -- Added for bug 2986930
BEGIN

  --Initialise the variables

  x_orig_project_id :=  p_from_project_id;
  x_new_project_id   :=  p_to_project_id;
  x_delta           :=  p_delta;
  x_orig_template_flag := p_orig_template_flag;

     /*=============================================================
       The following code has been moved from copy project
     =============================================================*/

   -- Copy budgets:  For each budget type, get baselined budget
   -- version id of the original project.  If baselined budget verion
   -- id is null, then get draft budget version id.  Copy the baselined
   -- budget or draft budget (if no baselined budget) of the original
   -- project into a new draft budget for the new project.

   --EH Changes

      BEGIN
        PA_BUDGET_FUND_PKG.Copy_Budgetary_Controls
                              (p_from_project_id    => x_orig_project_id,
                               p_to_project_id      => x_new_project_id,
                               x_return_status      => l_return_status,
                               x_msg_count          => l_msg_count,
                               x_msg_data           => l_msg_data);

          IF    (l_return_status <> 'S') Then
                  x_err_code := 725;
          --      x_err_stage := 'PA_NO_PROJ_CREATED';
                  x_err_stage := pa_project_core1.get_message_from_stack('PA_ERR_COPY_BUDGT_CONTRL');

                  x_err_stack   := x_err_stack||'->PA_BUDGET_FUND_PKG.Copy_Budgetary_Controls';
                 -- bug 3163280 rollback to copy_project;
                 return;
          END IF;

        EXCEPTION WHEN OTHERS THEN

             x_err_code := 725;
             x_err_stage := pa_project_core1.get_message_from_stack( null );
             IF x_err_stage IS NULL
             THEN
                x_err_stage := 'API: '||'PA_BUDGET_FUND_PKG.Copy_Budgetary_Controls'||
                                 ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
             END IF;
             -- bug 3163280 rollback to copy_project;
             return;
      END;

  DECLARE
        CURSOR agmt is
        SELECT 1
        FROM pa_project_fundings
        WHERE project_id = x_new_project_id;

        CURSOR c1 is
        /* Bug 3106741
           Reframed the select to use EXISTS instead of DISTINCT
        */
        SELECT t.budget_type_code
              ,t.budget_amount_code
          FROM  pa_budget_types t
         WHERE EXISTS ( SELECT 1
                          FROM pa_budget_versions v
                         WHERE v.project_id = x_orig_project_id
                           AND v.budget_type_code = t.budget_type_code)
        ORDER BY t.budget_type_code;

        c1_rec               c1%rowtype;
        x_budget_version_id  number;
        x_new_budget_ver_id  number;
        with_funding         number := 0;
        x_mark_as_original   varchar2(2);

  BEGIN
      l_baseline_funding_flag := NVL(p_baseline_funding_flag,'N'); -- Added for bug 2986930
      OPEN agmt;
           FETCH agmt into with_funding;
           IF agmt%notfound THEN
              with_funding := 0;
           END IF;

      CLOSE agmt;

      OPEN c1;

      LOOP

        x_err_stage := 'fetch budget type code';

        FETCH c1 INTO c1_rec;
        EXIT WHEN c1%notfound;

/* Added the below if condition for bug 2986930 */
       --Bug 5378256: Prevent copy and baseline of AR budget when 'baseline funding without budget' is enabled for target.
       If NOT(l_baseline_funding_flag = 'Y' and c1_rec.budget_type_code = 'AR' )
       then

        x_budget_version_id := null;
        x_mark_as_original := 'N';
        -- get latest baselined version id of the original project
        -- with the budget type of c1_rec.budget_type_code
        x_err_stage :=
             'get latest baselined version id of project '||
              x_orig_project_id ||' with budget type of '||
              c1_rec.budget_type_code;
        --EH Changes
        BEGIN
              pa_budget_utils.get_baselined_version_id
                                (x_project_id             => x_orig_project_id,
                                 x_budget_type_code       => c1_rec.budget_type_code,
                                 x_budget_version_id      => x_budget_version_id,
                                 x_err_code               => x_err_code,
                                 x_err_stage              => x_err_stage,
                                 x_err_stack              => x_err_stack);


              x_err_stage :=
                   'after get latest baselined version id of project '||
                    x_orig_project_id ||' with budget type of '||
                    c1_rec.budget_type_code;

              IF ( x_err_code < 0 ) THEN   -- Oracle error
                  x_err_code := 750;
                   IF x_err_stage IS NULL
                   THEN
                       x_err_stage := pa_project_core1.get_message_from_stack( 'PA_ERR_GET_BASLIN_VER_ID');
                   END IF;
                   x_err_stack := x_err_stack||'->pa_budget_utils.get_baselined_version_id';
                   -- bug 3163280 ROLLBACK TO copy_project;
                   RETURN;
              END IF;
        EXCEPTION WHEN OTHERS THEN
              x_err_code := 750;
--              x_err_stage := pa_project_core1.get_message_from_stack( null );
              IF x_err_stage IS NULL
              THEN
                 x_err_stage := 'API: '||'pa_budget_utils.get_baselined_version_id'||
                                  ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
              END IF;
              -- bug 3163280 rollback to copy_project;
              return;
        END;

        IF ( x_err_code = 0 ) THEN   -- got baselined budget
           x_mark_as_original := 'Y';
        END IF;

        IF (x_err_code = 10) THEN
           -- no baselined budget
           -- get draft version id of the original project
           -- with the budget type of c1_rec.budget_type_code
           x_err_stage :=
               'get draft version id of project '||
                x_orig_project_id ||' with budget type of '||
                c1_rec.budget_type_code;
           --EH Changes
           BEGIN
                pa_budget_utils.get_draft_version_id
                                 (x_project_id             => x_orig_project_id,
                                  x_budget_type_code       => c1_rec.budget_type_code,
                                  x_budget_version_id      => x_budget_version_id,
                                  x_err_code               => x_err_code,
                                  x_err_stage              => x_err_stage,
                                  x_err_stack              => x_err_stack);

                IF ( x_err_code < 0 ) THEN        -- Oracle error
                     x_err_code := 755;
                     IF x_err_stage IS NULL
                     THEN
                         x_err_stage := pa_project_core1.get_message_from_stack('PA_ERR_GET_DRFT_VER_ID');
                     END IF;
                     x_err_stack := x_err_stack||'->pa_budget_utils.get_draft_version_id';
                     -- bug 3163280 ROLLBACK TO copy_project;
                     RETURN;
                END IF;
           EXCEPTION WHEN OTHERS THEN
                x_err_code := 755;
           --  x_err_stage := pa_project_core1.get_message_from_stack( null );
                     IF x_err_stage IS NULL
                     THEN
                        x_err_stage := 'API: '||'pa_budget_utils.get_draft_version_id'||
                                         ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
                     END IF;
                     -- bug 3163280 ROLLBACK TO copy_project;
                     RETURN;
           END;
        END IF;

        IF (x_err_code = 0) THEN
           IF (x_budget_version_id is not null) THEN

              -- copy budget for new project
                x_err_stage := 'create draft budget for new project '||
                x_new_project_id || ' with budget type of '||
                c1_rec.budget_type_code;
              --EH Changes

              BEGIN

                  pa_budget_core.copy(
                         x_src_version_id          => x_budget_version_id,
                         x_amount_change_pct       => 1,
                         x_rounding_precision      => 5,
                         x_shift_days              => nvl(x_delta, 0),
                         x_dest_project_id         => x_new_project_id,
                         x_dest_budget_type_code   => c1_rec.budget_type_code,
                         x_err_code                => x_err_code,
                         x_err_stage               => x_err_stage,
                         x_err_stack               => x_err_stack );

                 if ( x_err_code > 0 or x_err_code < 0 ) then
                      x_err_code := 760;
                      IF x_err_stage IS NULL
                      THEN
                          x_err_stage := pa_project_core1.get_message_from_stack( 'PA_ERR_BUDGT_CORE_COPY');
                      END IF;
                      x_err_stack := x_err_stack||'->pa_budget_core.copy';
                      -- bug 3163280 rollback to copy_project;
                      return;         -- Application or Oracle error
                 end if;
              EXCEPTION WHEN OTHERS THEN
                 x_err_code := 760;
--                 x_err_stage := pa_project_core1.get_message_from_stack( null );
                 IF x_err_stage IS NULL
                 THEN
                    x_err_stage := 'API: '||'pa_budget_core.copy'||
                                     ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
                 END IF;
                 -- bug 3163280 rollback to copy_project;
                 return;
              END;

              IF NOT PA_BUDGET_FUND_PKG.Is_bdgt_intg_enabled (p_project_id => x_orig_project_id,p_mode => 'A') THEN

                     -- 1. Submit/Baseline budget if the original template
                     --    has baselined budget with the same budget type.
                     -- 2. Display warning message if no baselined cost
                     --    budget for PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST based revenue accrual project and
                     --    try to baseline its revenue budget.

                     IF (x_mark_as_original = 'Y' and x_orig_template_flag = 'Y' and
                         (with_funding = 1 or
                          c1_rec.budget_amount_code <> 'R')) THEN

                        x_err_stage :=
                             'get draft budget version for new project'
                             || x_new_project_id;

                        SELECT budget_version_id
                        INTO x_new_budget_ver_id
                        FROM pa_budget_versions
                        WHERE project_id = x_new_project_id
                        AND budget_status_code = PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_WORKING
                        AND budget_type_code = c1_rec.budget_type_code;

                        x_err_stage :=
                             'submit revenue budget for new project'
                             || x_new_project_id;

                        savepoint before_bill_baseline;
                        /*Bug 5378256: This condition added thru the bug 2986930, has been moved down
                         to prevent baseline alone when agreement amt is entered through quick agreement*/
                        If NOT(p_agreement_amount > 0 and c1_rec.budget_type_code = 'AR' )
                        then
--EH Changes
                        BEGIN

                             pa_budget_utils2.submit_budget(x_budget_version_id  => x_new_budget_ver_id,
                                                            x_err_code           => x_err_code,
                                                            x_err_stage          => x_err_stage,
                                                            x_err_stack          => x_err_stack);

                             IF ( x_err_code <> 0 ) THEN
                               x_err_code := 785;
                               IF x_err_stage IS NULL
                               THEN
                                   x_err_stage := pa_project_core1.get_message_from_stack( 'PA_ERR_SUBMIT_BUDGT');
                               END IF;
                               x_err_stack := x_err_stack||'->pa_budget_utils2.submit_budget';
                               ROLLBACK TO before_bill_baseline;
                               RETURN;         -- Application or Oracle error
                             END IF;
                        EXCEPTION WHEN OTHERS THEN
                           x_err_code := 785;
--                           x_err_stage := pa_project_core1.get_message_from_stack( null );
                           IF x_err_stage IS NULL
                           THEN
                              x_err_stage := 'API: '||'pa_budget_utils2.submit_budget'||
                                               ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
                           END IF;
                           ROLLBACK TO before_bill_baseline;
                           RETURN;
                        END;

                        x_err_stage :=
                             'baseline revenue budget for new project'
                             || x_new_project_id;

                        pa_budget_core.baseline(
                             x_draft_version_id=> x_new_budget_ver_id,
                             x_mark_as_original=> x_mark_as_original,
                             x_verify_budget_rules => 'Y',
                             x_err_code   => x_err_code,
                             x_err_stage  => x_err_stage,
                             x_err_stack  => x_err_stack);

                        if ( x_err_code > 0 and
                             x_err_stage = 'PA_BU_NO_BASE_COST_BUDGET') then
                             rollback to before_bill_baseline;
                             x_err_code := 0;
                        elsif ( x_err_code <> 0 ) then
                             return;         -- Application or Oracle error
                        end if;

                        x_err_stage :=
                                'reset revenue budget to working for new project'
                                || x_new_project_id;
--EH Changes
                        BEGIN

                           pa_budget_utils2.rework_budget(x_budget_version_id  => x_new_budget_ver_id,
                                                          x_err_code           => x_err_code,
                                                          x_err_stage          => x_err_stage,
                                                          x_err_stack          => x_err_stack);

                           IF ( x_err_code <> 0 ) THEN
                             x_err_code := 790;
                             IF x_err_stage IS NULL
                             THEN
                                 x_err_stage := pa_project_core1.get_message_from_stack( 'PA_ERR_REWORK_BUDGT');
                             END IF;
                             x_err_stack := x_err_stack||'->pa_budget_utils2.rework_budget';
                             ROLLBACK TO before_bill_baseline;
                             RETURN;         -- Application or Oracle error
                           END IF;
                        EXCEPTION WHEN OTHERS THEN
                           x_err_code := 790;
--                           x_err_stage := pa_project_core1.get_message_from_stack( null );
                           IF x_err_stage IS NULL
                           THEN
                              x_err_stage := 'API: '||'pa_budget_utils2.rework_budget'||
                                               ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
                           END IF;
                           ROLLBACK TO before_bill_baseline;
                           RETURN;
                        END;

                        End if; --Bug 5378256: Prevent baseline of AR budget when agreement amount is entered.

                        END IF;

      END IF;

                   END IF;
                  END IF;
        END IF; -- Added for bug 2986930
                 END LOOP;
                 CLOSE C1;

                 -- pa_budget_core.get_draft_version_id returns x_err_code = 10
                 -- when no budget version id is found, which is fine.
                 IF (x_err_code = 10) THEN
                        x_err_code := 0;
                 END IF;
            END;

END Copy_Budgets_From_Project;

/*===================================================================
  This is a main api used for copying the financila related entities
  fromsource project or template. This api takes care of the upgraded
  budget versions and takes care of all the business rules that relate
  to new financial planning module. This api would be called from
  PA_PROJECT_CORE!.COPY_PROJECT  after call to
  PA_BUDGET_CORE.COPY_BUDGETS_FROM_PROJECT
  Bug#  - 2981655 - Please see bug for the complete discussion about
  this bug. The core is, when copy_project is done with copy_budget_flag
  as N, we still have to copy the header level informations
  pa_proj_fp_options, pa_fp_txn_currencies, period profile information.
  Also, we should not be copying the planning elements for any of the
  copied options since when copy_budget_flag is N, tasks may not have
  been copied from the source project to the target project.

--
-- 14-JUL-2003 jwhite        - Bug 3045668
--                             As directed by Venkatesh, added a
--                             simple update near the end of the
--                             Copy_Finplans_From_Project to set the
--                             process_update_wbs_flag = 'N when
--                             p_copy_version_and_elements = N.

=====================================================================*/

PROCEDURE Copy_Finplans_From_Project (
          p_source_project_id           IN      NUMBER
          ,p_target_project_id          IN      NUMBER
          ,p_shift_days                 IN      NUMBER
          ,p_copy_version_and_elements  IN      VARCHAR2
          ,p_agreement_amount           IN      NUMBER  -- Added for bug 2986930
          ,x_return_status              OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                  OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                   OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS
      l_return_status      VARCHAR2(2000);
      l_msg_count          NUMBER :=0;
      l_msg_data           VARCHAR2(2000);
      l_data               VARCHAR2(2000);
      l_msg_index_out      NUMBER;
      l_err_code           NUMBER;
      l_err_stage          VARCHAR2(2000);
      l_err_stack          VARCHAR2(2000);

      l_index                     NUMBER;
      l_shift_days                NUMBER;
      l_period_type               VARCHAR2(15);

      l_proj_fp_options_id_tbl    PA_FP_COPY_FROM_PKG.PROJ_FP_OPTIONS_ID_TBL_TYP;

      l_source_template_flag      pa_projects_all.template_flag%TYPE;
      l_source_current_flag       pa_budget_versions.current_flag%TYPE;
      l_source_version_id         pa_budget_versions.budget_version_id%TYPE;
      l_source_fp_preference_code pa_proj_fp_options.fin_plan_preference_code%TYPE;
      l_source_record_version_num pa_budget_versions.record_version_number%TYPE;
      l_source_fin_plan_type_id   pa_proj_fp_options.fin_plan_type_id%TYPE;

      l_time_phased_code          pa_proj_fp_options.all_time_phased_code%TYPE;

      l_target_version_id         pa_budget_versions.budget_version_id%TYPE;
      l_target_profile_id         pa_budget_versions.period_profile_id%TYPE;
      l_target_proj_fp_options_id pa_proj_fp_options.proj_fp_options_id%TYPE;
      l_target_record_version_num pa_budget_versions.record_version_number%TYPE;
      l_version_type              pa_budget_versions.version_type%TYPE;
      l_funding_exists_flag       VARCHAR2(1);


      l_fp_option_level_code      pa_proj_fp_options.fin_plan_option_level_code%TYPE;
      l_plan_in_multi_curr_flag   pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;
      l_appr_cost_plan_type_flag  pa_proj_fp_options.approved_cost_plan_type_flag%TYPE;
      l_appr_rev_plan_type_flag   pa_proj_fp_options.approved_rev_plan_type_flag%TYPE;
      l_struct_elem_version_id    pa_proj_element_versions.element_version_id%TYPE;
      l_budget_version_ids        SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_src_budget_version_id_tbl SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();


    /* Code addition for bug 2986930 starts */
        CURSOR c_ar_chk( p_source_ver_id pa_budget_versions.budget_version_id%TYPE) IS
        SELECT 'Y'
        FROM dual
        WHERE EXISTS(SELECT NULL
                         FROM   pa_budget_versions
                         WHERE budget_version_id = p_source_ver_id
                             AND approved_rev_plan_type_flag = 'Y');

        CURSOR c_bfl IS
        SELECT baseline_funding_flag
        FROM   pa_projects
        WHERE  project_id = p_source_project_id;

    l_ar_exists              VARCHAR2(1);
    l_baseline_funding_flag  VARCHAR2(1);
    l_fc_version_created_flag VARCHAR2(1);
    /* Code addition for bug 2986930 ends */
    -- IPM Arch Enhancement - Bug 4865563
    l_fp_cols_rec                   PA_FP_GEN_AMOUNT_UTILS.FP_COLS;  --This variable will be used to call pa_resource_asgn_curr maintenance api
    l_debug_level5           NUMBER:=5;

BEGIN

    FND_MSG_PUB.INITIALIZE;
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.init_err_stack('PA_FP_COPY_FROM_PKG.Copy_Finplans_From_Project');
        pa_debug.set_process('PLSQL','LOG',p_pa_debug_mode);
    -- Check if  source project id is  NULL,if so throw an error message
        pa_debug.g_err_stage := 'Checking for valid parameters:';
        pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_source_project_id IS NULL)  OR
       (p_target_project_id IS NULL)  OR
       (p_copy_version_and_elements IS NULL)
    THEN

        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage := 'Source_project='||p_source_project_id;
           pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
           pa_debug.g_err_stage := 'Target_project='||p_target_project_id;
           pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
           pa_debug.g_err_stage := 'p_copy_version_and_elements='||p_copy_version_and_elements;
           pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                             p_token1         => 'PROCEDURENAME',
                             p_value1         => 'PA_FP_COPY_FROM_PKG.Copy_Finplans_From_Project');
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.g_err_stage := 'Parameter validation complete';
       pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
    END IF;

    --IF shift_days i/p is NULL then make it zero.

    l_shift_days := NVL(p_shift_days,0);

    --Get the structure version id of the financial structure
    l_struct_elem_version_id := PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(p_project_id => p_target_project_id );

    --Checking if source project is template

    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.g_err_stage := 'Fetching source project template flag';
       pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
    END IF;

    SELECT template_flag
    INTO   l_source_template_flag
    FROM   pa_projects_all
    WHERE  project_id = p_source_project_id;

    --Fetch project_level_funding_flag for target project to
    --baseline it or not

    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.g_err_stage := 'Fetching target funding flag';
       pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
    END IF;

    /* 2616032: Modified the way the project level funding flag is got.
       This flag indicates if funding exists for the Target Project. */

    BEGIN
            SELECT 'Y'
            INTO   l_funding_exists_flag
            FROM   DUAL
            WHERE EXISTS (SELECT 1
                          FROM pa_project_fundings
                          WHERE project_id = p_target_project_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           l_funding_exists_flag := 'N';
    END;

    /* Code addition for bug 2986930 starts */
    OPEN c_bfl;
    FETCH c_bfl into l_baseline_funding_flag;
    CLOSE c_bfl;
    /* Code addition for bug 2986930 ends */

    IF p_copy_version_and_elements = 'Y' THEN /* Bug 2981655 */

        --First Copy the budgets which aren't upgraded from source project to target project

         Copy_Budgets_From_Project(
                            p_from_project_id          =>  p_source_project_id
                            ,p_to_project_id           =>  p_target_project_id
                            ,p_delta                   =>  l_shift_days
                            ,p_orig_template_flag      =>  l_source_template_flag
                            ,p_agreement_amount        =>  p_agreement_amount  -- Added for bug 2986930
                            ,p_baseline_funding_flag   =>  l_baseline_funding_flag -- Added for bug 2986930
                            ,x_err_code                =>  l_err_code
                            ,x_err_stage               =>  l_err_stage
                            ,x_err_stack               =>  l_err_stack);

         IF l_err_code <> 0 THEN

               /* Bug# 2636723 - Error messages printed and "Raised" and not "Returned" */

            IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.g_err_stage := 'Err code returned by copy_budgets_from_project api is ' || TO_CHAR(l_err_code);
                  pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
                  pa_debug.g_err_stage := 'Err stage returned by copy_budgets_from_project api is ' || l_err_stage;
                  pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
                  pa_debug.g_err_stage := 'Err stack returned by copy_budgets_from_project api is ' || l_err_stack;
                  pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
            END IF;

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

          /* Bug# 2636723
                 RETURN; -- Application or Oracle error   */

         END IF; /* l_err_code <> 0 */

    END IF; /* p_copy_version_and_elements = 'Y' */

    --Fetch all the fp options ids to be copied from source project to
    --target into a plsql table.
    --For this call get_fp_options_to_be_copied api.

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'Calling Get_Fp_Options_To_Be_Copied api';
        pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
    END IF;

    PA_FP_COPY_FROM_PKG.Get_Fp_Options_To_Be_Copied(
               p_source_project_id    => p_source_project_id
               ,p_copy_versions       => p_copy_version_and_elements  /* Bug 2981655 */
               ,x_fp_options_ids_tbl  => l_proj_fp_options_id_tbl
               ,x_return_status       => l_return_status
               ,x_msg_count           => l_msg_count
               ,x_msg_data            => l_msg_data );

    /* Added the following check for the NOCOPY changes. */

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    --Bug :- 2570874
    IF NVL(l_proj_fp_options_id_tbl.first,0) >0 THEN  --only if something to be copied
            FOR l_index IN  l_proj_fp_options_id_tbl.first..l_proj_fp_options_id_tbl.last
            LOOP

                 --Null out local variables used previously

                 l_target_version_id := NULL;
                 l_target_proj_fp_options_id := NULL;

                 --Fetch option level code of the options_id

                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.g_err_stage := 'Fetching option level code ';
                    pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
                 END IF;

                 SELECT fin_plan_option_level_code
                        ,fin_plan_version_id
                        ,fin_plan_preference_code
                        ,fin_plan_type_id
                        ,plan_in_multi_curr_flag
                 INTO   l_fp_option_level_code
                        ,l_source_version_id
                        ,l_source_fp_preference_code
                        ,l_source_fin_plan_type_id
                        ,l_plan_in_multi_curr_flag
                 FROM   pa_proj_fp_options
                 WHERE  proj_fp_options_id = l_proj_fp_options_id_tbl(l_index);

                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.g_err_stage := 'Option level code = '||l_fp_option_level_code;
                    pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
                 END IF;


                 --Copy the budget version if option level code is plan version
                 --We call the api with .99999 as adj_percentage to prevent
                 --population of amount columns

                 IF l_fp_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION THEN

                      /* Code addition for Bug 2986930 starts */
                      OPEN c_ar_chk(l_source_version_id);
                      FETCH c_ar_chk INTO l_ar_exists;
                      CLOSE c_ar_chk;

                      IF ( NVL(p_agreement_amount,-1) > 0 and nvl(l_ar_exists,'N') <> 'Y' ) OR
                         ( NVL(p_agreement_amount,-1) < 0 and ( NVL(l_baseline_funding_flag,'N') = 'Y' AND NVl(l_ar_exists,'N') <> 'Y' ) ) OR
                         ( NVL(p_agreement_amount,-1) < 0 and NVL(l_baseline_funding_flag,'N') = 'N' )
                      THEN
                         /* Code addition for Bug 2986930 ends */

                                 IF P_PA_DEBUG_MODE = 'Y' THEN
                                     pa_debug.g_err_stage := 'Calling Copy_Budget_Version';
                                     pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
                                 END IF;

                                 l_target_version_id := NULL;

                                 PA_FP_COPY_FROM_PKG.Copy_Budget_Version(
                                          p_source_project_id       => p_source_project_id
                                          ,p_target_project_id      => p_target_project_id
                                          ,p_source_version_id      => l_source_version_id
                                          ,p_copy_mode              => PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_WORKING
                                          ,p_adj_percentage         => .99999
                                          ,p_calling_module         => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN
                                          ,p_struct_elem_version_id => l_struct_elem_version_id
                                          ,p_shift_days             => l_shift_days
                                          ,px_target_version_id     => l_target_version_id
                                          ,x_return_status          => l_return_status
                                          ,x_msg_count              => l_msg_count
                                          ,x_msg_data               => l_msg_data );

                                 IF P_PA_DEBUG_MODE = 'Y' THEN
                                    pa_debug.g_err_stage := 'l_target_version_id = '||l_target_version_id;
                                    pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
                                 END IF;

                         END IF;/* Added for bug 2986930 */
                 END IF;

                 IF  l_fp_option_level_code <> PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION   THEN
                     --Create equivalent fp option in pa_proj_fp_options for target

                     IF P_PA_DEBUG_MODE = 'Y' THEN
                             pa_debug.g_err_stage := 'Calling Create_Fp_Option';
                             pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
                     END IF;

                     PA_PROJ_FP_OPTIONS_PUB.Create_Fp_Option (
                                  px_target_proj_fp_option_id    => l_target_proj_fp_options_id
                                  ,p_source_proj_fp_option_id    => l_proj_fp_options_id_tbl(l_index)
                                  ,p_target_fp_option_level_code => l_fp_option_level_code       --same as source
                                  ,p_target_fp_preference_code   => l_source_fp_preference_code
                                  ,p_target_fin_plan_version_id  => l_target_version_id
                                  ,p_target_plan_type_id         => l_source_fin_plan_type_id    --same as source
                                  ,p_target_project_id           => p_target_project_id
                                  ,x_return_status               => l_return_status
                                  ,x_msg_count                   => l_msg_count
                                  ,x_msg_data                    => l_msg_data);

                     IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.g_err_stage := 'Calling Copy_Fp_Txn_Currencies api';
                          pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
                     END IF;

                     PA_FP_TXN_CURRENCIES_PUB.Copy_Fp_Txn_Currencies(
                             p_source_fp_option_id        => l_proj_fp_options_id_tbl(l_index)
                             ,p_target_fp_option_id       => l_target_proj_fp_options_id
                             ,p_target_fp_preference_code => NULL
                             ,p_plan_in_multi_curr_flag   => l_plan_in_multi_curr_flag
                             ,x_return_status             => l_return_status
                             ,x_msg_count                 => l_msg_count
                             ,x_msg_data                  => l_msg_data);

                 ELSIF l_fp_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION THEN

                     /* Code addition for Bug 2986930 starts */

                       IF ( NVL(p_agreement_amount,-1) > 0 AND nvl(l_ar_exists,'N') <> 'Y' ) OR
                          ( NVL(p_agreement_amount,-1) < 0 AND ( NVL(l_baseline_funding_flag,'N') = 'Y' AND NVl(l_ar_exists,'N') <> 'Y' ) ) OR
                          ( NVL(p_agreement_amount,-1) < 0 AND NVL(l_baseline_funding_flag,'N') = 'N' )
                       THEN
                     /* Code addition for Bug 2986930 ends */
                             --Create equivalent fp option in pa_proj_fp_options for target

                             IF P_PA_DEBUG_MODE = 'Y' THEN
                                     pa_debug.g_err_stage := 'Calling Create_Fp_Option';
                                     pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
                             END IF;

                             PA_PROJ_FP_OPTIONS_PUB.Create_Fp_Option (
                                    px_target_proj_fp_option_id    => l_target_proj_fp_options_id
                                    ,p_source_proj_fp_option_id    => l_proj_fp_options_id_tbl(l_index)
                                    ,p_target_fp_option_level_code => l_fp_option_level_code       --same as source
                                    ,p_target_fp_preference_code   => l_source_fp_preference_code
                                    ,p_target_fin_plan_version_id  => l_target_version_id
                                    ,p_target_plan_type_id         => l_source_fin_plan_type_id    --same as source
                                    ,p_target_project_id           => p_target_project_id
                                    ,x_return_status               => l_return_status
                                    ,x_msg_count                   => l_msg_count
                                    ,x_msg_data                    => l_msg_data);

                             -- Call copy fp txn currencies api unconditionally
                             IF P_PA_DEBUG_MODE = 'Y' THEN
                                  pa_debug.g_err_stage := 'Calling Copy_Fp_Txn_Currencies api';
                                  pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
                             END IF;

                             PA_FP_TXN_CURRENCIES_PUB.Copy_Fp_Txn_Currencies(
                                     p_source_fp_option_id        => l_proj_fp_options_id_tbl(l_index)
                                     ,p_target_fp_option_id       => l_target_proj_fp_options_id
                                     ,p_target_fp_preference_code => NULL
                                     ,p_plan_in_multi_curr_flag   => l_plan_in_multi_curr_flag
                                     ,x_return_status             => l_return_status
                                     ,x_msg_count                 => l_msg_count
                                     ,x_msg_data                  => l_msg_data);


                             --Copy resource assignments for the target plan version

                             IF P_PA_DEBUG_MODE = 'Y' THEN
                                pa_debug.g_err_stage := 'Calling Copy_Resource_Assignments';
                                pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
                             END IF;

                             PA_FP_COPY_FROM_PKG.Copy_Resource_Assignments(
                                       p_source_plan_version_id  => l_source_version_id
                                       ,p_target_plan_version_id => l_target_version_id
                                       ,p_adj_percentage         => 0.99999
                                       ,x_return_status          => l_return_status
                                       ,x_msg_count              => l_msg_count
                                       ,x_msg_data               => l_msg_data);

                             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				IF P_PA_DEBUG_MODE = 'Y' THEN
	                               pa_debug.write(g_module_name,' Return status from copy RA api is ' || l_Return_Status,3);
				END IF;
        	                       raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                             END IF;

                         -- Copying budget_lines from source to target

                             IF P_PA_DEBUG_MODE = 'Y' THEN
                                pa_debug.g_err_stage := 'Calling Copy_Budget_Lines';
                                pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
                             END IF;

                             PA_FP_COPY_FROM_PKG.Copy_Budget_Lines(
                                        p_source_project_id       => p_source_project_id
                                        ,p_target_project_id      => p_target_project_id
                                        ,p_source_plan_version_id  => l_source_version_id
                                        ,p_target_plan_version_id  => l_target_version_id
                                        ,p_shift_days              => l_shift_days
                                        ,x_return_status           => l_return_status
                                        ,x_msg_count               => l_msg_count
                                        ,x_msg_data                => l_msg_data );

                             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				IF P_PA_DEBUG_MODE = 'Y' THEN
	                               pa_debug.write(g_module_name,' Return status from copy bl api is ' || l_Return_Status,3);
				END IF;
                               raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                             END IF;

                             --Calling Convert_Txn_Currency api to complete budget lines
                             --in all respects

                             IF P_PA_DEBUG_MODE = 'Y' THEN
                                pa_debug.g_err_stage := 'Calling Convert_Txn_Currency';
                                pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
                             END IF;

                             PA_FP_MULTI_CURRENCY_PKG.Convert_Txn_Currency(
                                       p_budget_version_id  => l_target_version_id
                                       ,p_entire_version    => 'Y'
                                       ,x_return_status     => l_return_status
                                       ,x_msg_count         => l_msg_count
                                       ,x_msg_data          => l_msg_data);

                             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN -- Bug# 2634726
                               raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                             END IF;

                             -- Bug Fix: 4569365. Removed MRC code.
                             -- FPB2: MRC - Calling MRC APIs
                             /*

                             IF P_PA_DEBUG_MODE = 'Y' THEN
                                pa_debug.g_err_stage:='Calling mrc api ........ ';
                                pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
                             END IF;

                             IF PA_MRC_FINPLAN. g_mrc_enabled_for_budgets IS NULL THEN
                                    PA_MRC_FINPLAN.check_mrc_install
                                              (x_return_status      => l_return_status,
                                               x_msg_count          => l_msg_count,
                                               x_msg_data           => l_msg_data);
                             END IF;

                             IF PA_MRC_FINPLAN.g_mrc_enabled_for_budgets AND
                                    PA_MRC_FINPLAN.g_finplan_mrc_option_code = 'A' THEN

                                       PA_MRC_FINPLAN.g_calling_module := PA_MRC_FINPLAN.g_copy_projects; -- FPB2

                                       PA_MRC_FINPLAN.maintain_all_mc_budget_lines
                                              (p_fin_plan_version_id => l_target_version_id,
                                               p_entire_version      => 'Y',
                                               x_return_status       => x_return_status,
                                               x_msg_count           => x_msg_count,
                                               x_msg_data            => x_msg_data);

                                       PA_MRC_FINPLAN.g_calling_module := NULL;
                             END IF;

                             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                               RAISE g_mrc_exception;
                             END IF;
                             */

                             --Calling copy_attachments api
                             --Copy all the source version attachments to target version

                             IF P_PA_DEBUG_MODE = 'Y' THEN
                                pa_debug.g_err_stage := 'Calling Copy_Attachments api';
                                pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
                             END IF;

                /* BUG FIX 2955827
                 * copy_attachments is already done in PA_FP_COPY_FROM_PKG.Copy_Budget_Version
                              FND_ATTACHED_DOCUMENTS2_PKG.Copy_Attachments(
                                        x_from_entity_name        => 'PA_BUDGET_VERSIONS'
                                        ,x_from_pk1_value         => l_source_version_id
                                        ,x_from_pk2_value         => NULL
                                        ,x_from_pk3_value         => NULL
                                        ,x_from_pk4_value         => NULL
                                        ,x_from_pk5_value         => NULL
                                        ,x_to_entity_name         => 'PA_BUDGET_VERSIONS'
                                        ,x_to_pk1_value           => l_target_version_id
                                        ,x_to_pk2_value           => NULL
                                        ,x_to_pk3_value           => NULL
                                        ,x_to_pk4_value           => NULL
                                        ,x_to_pk5_value           => NULL
                                        ,x_created_by             => FND_GLOBAL.USER_ID
                                        ,x_last_update_login      => FND_GLOBAL.LOGIN_ID
                                        ,x_program_application_id => FND_GLOBAL.PROG_APPL_ID()
                                        ,x_program_id             => NULL
                                        ,x_request_id             => NULL
                                        ,x_automatically_added_flag => NULL);
                 END OF BUG FIX 2955827 */

       --IPM Architechture Enhancement Bug 4865563 - Start

               PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
                   (P_BUDGET_VERSION_ID              => l_target_version_id,
                    X_FP_COLS_REC                    => l_fp_cols_rec,
                    X_RETURN_STATUS                  => l_return_status,
                    X_MSG_COUNT                      => l_msg_count,
                    X_MSG_DATA                       => l_msg_data);

                    IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                                    IF P_PA_debug_mode = 'Y' THEN
                                       pa_debug.g_err_stage:= 'Error in PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DETAILS';
                                       pa_debug.write(g_module_name,pa_debug.g_err_stage,l_debug_level5);
                                    END IF;
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;

               --Calling populate_display_qty for populating display_quantity in pa_budget_lines
                   PA_BUDGET_LINES_UTILS.populate_display_qty
                   (p_budget_version_id    => l_target_version_id,
                    p_context              => 'FINANCIAL',
                    p_use_temp_table_flag  => 'N',
                    x_return_status        => l_return_status);

                IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                                    IF P_PA_debug_mode = 'Y' THEN
                                       pa_debug.g_err_stage:= 'Error in PA_BUDGET_LINES_UTILS.populate_display_qty';
                                       pa_debug.write(g_module_name,pa_debug.g_err_stage,l_debug_level5);
                                    END IF;
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                 END IF;

                           /*This piece of code calls maintain_data api with p_version_level_flag => 'N' i.e temp table mode for copying
                           overrides from the source version and with p_rollup_flag        => 'Y' for rolling up the amounts in the target
                           version */

                           DELETE pa_resource_asgn_curr_tmp;

                           /* Populating temp table with target resource_assignment_id along with txn_curr_code and
                           override rates from the source version of pa_resource_asgnc_curr */
                           /*Inserting into temp table */
                                       INSERT INTO pa_resource_asgn_curr_tmp
                                           (RESOURCE_ASSIGNMENT_ID,
                                           TXN_CURRENCY_CODE,
                                           txn_raw_cost_rate_override,
                                           txn_burden_cost_rate_override,
                                           txn_bill_rate_override)
                                           SELECT
                                             pra.resource_assignment_id,
                                             rac.txn_currency_code,
                                             rac.txn_raw_cost_rate_override,
                                             rac.txn_burden_cost_rate_override,
                                             rac.txn_bill_rate_override
                                           FROM
                                             pa_resource_asgn_curr rac,
                                             pa_resource_assignments pra
                                           WHERE
                                             pra.budget_version_id = l_target_version_id   and
                                             rac.budget_version_id = l_source_version_id  and
                                             pra.parent_assignment_id = rac.resource_assignment_id;

                           /*Calling the maintain_data api for the 2nd time to do the rollup from
                             pa_budget_lines. Note: This keeps the override rates copied in the
                             previous call, intact */
                           pa_res_asg_currency_pub.maintain_data
                           (p_fp_cols_rec        => l_fp_cols_rec,
                            p_calling_module     => 'COPY_PLAN',
                            p_rollup_flag        => 'Y', --rolling up
                            p_version_level_flag => 'N', --temp table mode
                            x_return_status      => l_return_status,
                            x_msg_data           => l_msg_count,
                            x_msg_count          => l_msg_data);

                                IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                                                IF P_PA_debug_mode = 'Y' THEN
                                                   pa_debug.g_err_stage:= 'Error in PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA while doing the rollup';
                                                   pa_debug.write(g_module_name,pa_debug.g_err_stage,l_debug_level5);
                                                END IF;
                                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                                END IF;


           --IPM Architechture Enhancement Bug 4865563 - End

                             -- Rollup the budget version
                             IF P_PA_DEBUG_MODE = 'Y' THEN
                                     pa_debug.g_err_stage := 'Calling Rollup_budget_version api';
                                     pa_debug.write( g_module_name,pa_debug.g_err_stage,3);
                             END IF;


                             PA_FP_ROLLUP_PKG.ROLLUP_BUDGET_VERSION(
                                          p_budget_version_id  => l_target_version_id
                                          ,p_entire_version    => 'Y'
                                          ,x_return_status     => l_return_status
                                          ,x_msg_count         => l_msg_count
                                          ,x_msg_data          => l_msg_data );

                             /* FP M - Reporting lines integration */
                             l_budget_version_ids.delete;
                             l_budget_version_ids   := SYSTEM.pa_num_tbl_type(l_target_version_id);

                             IF P_PA_DEBUG_MODE = 'Y' THEN
                                 pa_debug.write('Copy_Finplans_From_Project','Calling PJI_FM_XBS_ACCUM_MAINT.PLAN_CREATE ' ,5);
                                 pa_debug.write('Copy_Finplans_From_Project','p_fp_version_ids count '|| l_budget_version_ids.count(),5);
                             END IF;

                             /* We are sure that there is only one record. But just looping the std way */
                             FOR I in l_budget_version_ids.first..l_budget_version_ids.last LOOP
				IF P_PA_DEBUG_MODE = 'Y' THEN
                                pa_debug.write('Copy_Finplans_From_Project',''|| l_budget_version_ids(i),5);
				END IF;
                             END LOOP;

                             l_src_budget_version_id_tbl.delete;
                             l_src_budget_version_id_tbl   := SYSTEM.pa_num_tbl_type(l_source_version_id);
                             -- This parameter will be used when the source project is not equal to the target project.
                             --This will be passed as null in the MSP flow other wise it will be defaulted to 'P'.
                             Declare
                                l_copy_mode VARCHAR2(1);
                             Begin
                                  IF p_copy_version_and_elements = 'Y' THEN
                                       l_copy_mode := 'P';
                                  END IF;

                                  PJI_FM_XBS_ACCUM_MAINT.PLAN_CREATE (
                                         p_fp_version_ids   => l_budget_version_ids,
                                         p_fp_src_version_ids => l_src_budget_version_id_tbl,
                                         p_copy_mode   => l_copy_mode,
                                         x_return_status    => l_return_status,
                                         x_msg_code         => l_err_stack);

                                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
                                       PA_UTILS.ADD_MESSAGE(p_app_short_name      => PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_PA,
                                                            p_msg_name            => l_err_stack);

                                       RAISE  PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                                  END IF;

                             End;


                             --If source plan version is baselined and if the source
                             --project is a template submit and baseline the target
                             --plan version also if it satisfies any of the two cases
                             --case 1: Funding is available for target project
                             --case 2: version type created is cost version

                             --Fetch current_flag of source plan version to check if
                             --source version is baselined

                             IF P_PA_DEBUG_MODE = 'Y' THEN
                                pa_debug.g_err_stage := 'Fetching source version details';
                                pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
                             END IF;

                             SELECT current_flag
                                    ,record_version_number
                             INTO   l_source_current_flag
                                    ,l_source_record_version_num
                             FROM   pa_budget_versions
                             WHERE  budget_version_id = l_source_version_id;

                             --Fetch target version properties for the api calls

                             IF P_PA_DEBUG_MODE = 'Y' THEN
                                pa_debug.g_err_stage := 'Fetching target version details';
                                pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
                             END IF;

                             SELECT record_version_number
                                    ,version_type
                             INTO   l_target_record_version_num
                                    ,l_version_type
                             FROM   pa_budget_versions
                             WHERE  budget_version_id = l_target_version_id;

                             IF (l_source_template_flag = 'Y') AND
                                (l_source_current_flag = 'Y' )
                             THEN

                                  IF (nvl(l_funding_exists_flag,'N') = 'Y') OR
                                     (l_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST)
                                  THEN

                                       --submit and baseline the the plan version

                                       IF P_PA_DEBUG_MODE = 'Y' THEN
                                          pa_debug.g_err_stage := 'Calling Set_Current_Working';
                                          pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
                                       END IF;

                                       PA_FIN_PLAN_PUB.Set_Current_Working(
                                              p_project_id                  => p_target_project_id
                                              ,p_budget_version_id          => l_target_version_id
                                              ,p_record_version_number      => NULL   --l_target_record_version_num
                                              ,p_orig_budget_version_id     => l_target_version_id  --as this is the initial creation
                                              ,p_orig_record_version_number => NULL
                                              ,x_return_status              => l_return_status
                                              ,x_msg_count                  => l_msg_count
                                              ,x_msg_data                   => l_msg_data );

                                       /* Bug# 2647047 - Raise if return status is not success */
                                       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                                       END IF;

                                       IF P_PA_DEBUG_MODE = 'Y' THEN
                                               pa_debug.g_err_stage := 'Calling Submit_Current_Working';
                                               pa_debug.write( g_module_name,pa_debug.g_err_stage,3);
                                       END IF;

                                       --Bug 3964755. In copy project flow, the version need not be locked. Added the context parameter
                                       --to submit API to skip this check.
                                       PA_FIN_PLAN_PUB.Submit_Current_Working(
                                               p_calling_context       => 'COPY_PROJECT'
                                              ,p_project_id            => p_target_project_id
                                              ,p_budget_version_id     => l_target_version_id
                                              ,p_record_version_number => NULL --l_target_record_version_num
                                              ,x_return_status         => l_return_status
                                              ,x_msg_count             => l_msg_count
                                              ,x_msg_data              => l_msg_data );

                                       /* Bug# 2647047 - Raise if return status is not success */
                                       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                                       END IF;

                                       IF P_PA_DEBUG_MODE = 'Y' THEN
                                               pa_debug.g_err_stage := 'Calling Baseline';
                                               pa_debug.write( g_module_name,pa_debug.g_err_stage,3);
                                       END IF;

                                       -- Bug Fix: 4569365. Removed MRC code.
									   -- PA_MRC_FINPLAN.G_CALLING_MODULE :=  PA_MRC_FINPLAN.G_COPY_PROJECTS; /* FPB2 */

                                       PA_FIN_PLAN_PUB.Baseline(
                                               p_project_id                  => p_target_project_id
                                               ,p_budget_version_id          => l_target_version_id
                                               ,p_record_version_number      => NUll --l_target_record_version_num
                                               ,p_orig_budget_version_id     => NULL --l_target_version_id  Bug # 2680859
                                               ,p_orig_record_version_number => NULL
                                               ,x_fc_version_created_flag    => l_fc_version_created_flag
                                               ,x_return_status              => l_return_status
                                               ,x_msg_count                  => l_msg_count
                                               ,x_msg_data                   => l_msg_data );

                                       -- Bug Fix: 4569365. Removed MRC code.
									   -- PA_MRC_FINPLAN.G_CALLING_MODULE := NULL; /* MRC */

                                       /* Bug# 2647047 - Raise if return status is not success */
                                       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                                       END IF;

                                  END IF;

                             END IF;   --ifs used for baselining
                       END IF;  -- if version can be copied

                 END IF; -- if version

             END LOOP;  -- l_proj_fp_options_id_tbl

    END IF; --Bug :- 2570874

    IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage := 'Exiting Copy_Finplans_From_Project';
            pa_debug.write( g_module_name,pa_debug.g_err_stage,3);
	    pa_debug.reset_err_stack;
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

        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Invalid Arguments Passed';
           pa_debug.write( g_module_name,pa_debug.g_err_stage,5);
           pa_debug.reset_err_stack;
        END IF;
        x_return_status:= FND_API.G_RET_STS_ERROR;
        -- bug#2753123
        IF l_err_stage is NOT NULL THEN
            x_msg_data := l_err_stage ;
        END IF ;
        -- Bug Fix: 4569365. Removed MRC code.

        -- bug 3163280 ROLLBACK TO COPY_PROJECT;
        -- PA_MRC_FINPLAN.G_CALLING_MODULE := Null;
        RETURN ;

   WHEN Others THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_FP_COPY_FROM_PKG'
                        ,p_procedure_name  => 'Copy_Finplans_From_Project');

        IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
                pa_debug.write( g_module_name,pa_debug.g_err_stage,5);
                pa_debug.reset_err_stack;
        END IF;
        -- Bug Fix: 4569365. Removed MRC code.

        -- bug 3163280 ROLLBACK TO COPY_PROJECT;
        -- PA_MRC_FINPLAN.G_CALLING_MODULE := Null;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Copy_Finplans_From_Project;


/*===================================================================
  This is a private procedure called from Copy_Finplans_From_Project.
  This api populates a plsql table with all the proj_fp_options_id of
  source project that need to be copied to target project.
  Bug  2981655- Included new parameter p_copy_versions. If Y, versions
  will also be copied apart from plan type and project options. If N,
  only project and plan type options would be copied.
 ==================================================================*/
PROCEDURE Get_Fp_Options_To_Be_Copied(
           p_source_project_id    IN  NUMBER
           ,p_copy_versions       IN  VARCHAR2
           ,x_fp_options_ids_tbl  OUT NOCOPY PROJ_FP_OPTIONS_ID_TBL_TYP
           ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data            OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

       l_return_status      VARCHAR2(2000);
       l_msg_count          NUMBER :=0;
       l_msg_data           VARCHAR2(2000);
       l_data               VARCHAR2(2000);
       l_msg_index_out      NUMBER;
       l_debug_mode         VARCHAR2(30);

       l_index                      NUMBER;
       l_fin_plan_preference_code   pa_proj_fp_options.fin_plan_preference_code%TYPE;
       l_fp_options_id              pa_proj_fp_options.proj_fp_options_id%TYPE;
       l_fin_plan_version_id        pa_proj_fp_options.fin_plan_version_id%TYPE;
       l_fin_plan_type_id           pa_proj_fp_options.fin_plan_type_id%TYPE;

       l_proj_fp_options_id_tbl     PROJ_FP_OPTIONS_ID_TBL_TYP;

       CURSOR cur_for_fp_options(c_level_code pa_proj_fp_options.fin_plan_option_level_code%TYPE)  IS
              SELECT pfo.proj_fp_options_id
                    ,pfo.fin_plan_type_id
                    ,pfo.fin_plan_preference_code
              FROM   pa_proj_fp_options pfo
                    ,pa_fin_plan_types_b fin
              WHERE  project_id = p_source_project_id
              AND    fin_plan_option_level_code = c_level_code
              AND    pfo.fin_plan_type_id = fin.fin_plan_type_id(+)
                          AND    nvl(fin.use_for_workplan_flag,'N')<>'Y';


BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' THEN
            pa_debug.set_err_stack('PA_FP_COPY_FROM_PKG.Get_Fp_Options_To_Be_Copied');
            pa_debug.set_process('PLSQL','LOG',p_pa_debug_mode);
    END IF;

    -- Check if  source project id is  NULL,if so throw an error message

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'Checking for valid parameters:';
        pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_source_project_id IS NULL) OR
       (p_copy_versions IS NULL) THEN

        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage := 'Source_project='||p_source_project_id;
           pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
           pa_debug.g_err_stage := 'p_copy_versions='||p_copy_versions;
           pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                             p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.g_err_stage := 'Parameter validation complete';
       pa_debug.write( g_module_name,pa_debug.g_err_stage,3);
    END IF;

    --Fetch and store project level fp option id in proj_fp_options_id_tbl.

    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.g_err_stage := 'Fetching project level fp option id';
       pa_debug.write( g_module_name,pa_debug.g_err_stage,3);
    END IF;

    OPEN cur_for_fp_options(PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PROJECT);

       FETCH cur_for_fp_options INTO
              l_proj_fp_options_id_tbl(1)
              ,l_fin_plan_type_id
              ,l_fin_plan_preference_code;

    CLOSE cur_for_fp_options;

    --Open and fetch fp options ids of all the plan types attached to project

    IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage := 'Opening cur_for_plan_type_fp_options';
           pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
    END IF;

    OPEN cur_for_fp_options(PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE);
    LOOP

       l_fp_options_id := NULL;
       l_fin_plan_version_id := NULL;

       FETCH cur_for_fp_options INTO
              l_proj_fp_options_id_tbl(nvl(l_proj_fp_options_id_tbl.last,0)+1)
              ,l_fin_plan_type_id
              ,l_fin_plan_preference_code;

       EXIT WHEN cur_for_fp_options%NOTFOUND;

       IF p_copy_versions = 'Y' THEN /* Bug 2981655 */

            --For each plan type fetched copy the options id of baselined or
            --current working version.

            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage := 'Preference_code ='|| l_fin_plan_preference_code;
               pa_debug.write( g_module_name,pa_debug.g_err_stage,3);
            END IF;

            --For COST_AND REV_SEP plan type we have to copy both revenue and cost
            --versions.

            IF l_fin_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP THEN

                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.g_err_stage := 'Fetching baselined cost plan version';
                    pa_debug.write( g_module_name,pa_debug.g_err_stage,3);
                 END IF;

                 PA_FIN_PLAN_UTILS.Get_Baselined_Version_Info(
                           p_project_id            => p_source_project_id
                           ,p_fin_plan_type_id     => l_fin_plan_type_id
                           ,p_version_type         => PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST
                           ,x_fp_options_id        => l_fp_options_id
                           ,x_fin_plan_version_id  => l_fin_plan_version_id
                           ,x_return_status        => l_return_status
                           ,x_msg_count            => l_msg_count
                           ,x_msg_data             => l_msg_data );

                 --IF there is no baselined version existing fetch the options
                 --id current working version

                 IF (l_fp_options_id IS NULL) THEN

                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.g_err_stage := 'Baselined plan cost version does not exist';
                          pa_debug.write( g_module_name,pa_debug.g_err_stage,3);

                          pa_debug.g_err_stage := 'Fetching current cost woking plan version if any';
                          pa_debug.write( g_module_name,pa_debug.g_err_stage,3);
                       END IF;

                       PA_FIN_PLAN_UTILS.Get_Curr_Working_Version_Info(
                                 p_project_id           => p_source_project_id
                                 ,p_fin_plan_type_id    => l_fin_plan_type_id
                                 ,p_version_type        => PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST
                                 ,x_fp_options_id       => l_fp_options_id
                                 ,x_fin_plan_version_id => l_fin_plan_version_id
                                 ,x_return_status       => l_return_status
                                 ,x_msg_count           => l_msg_count
                                 ,x_msg_data            => l_msg_data );

                 END IF;

                 --Insert the fetched option id of plan version  if existing

                 IF (l_fp_options_id IS NOT NULL) THEN
                     IF P_PA_DEBUG_MODE = 'Y' THEN
                             pa_debug.g_err_stage := 'Storing option id of cost plan version fetched';
                             pa_debug.write( g_module_name,pa_debug.g_err_stage,3);
                     END IF;

                     l_proj_fp_options_id_tbl(nvl(l_proj_fp_options_id_tbl.last,0)+1) := l_fp_options_id;
                 ELSE
                     IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.g_err_stage := 'Current working cost plan version does not exist for this plan type';
                         pa_debug.write( g_module_name,pa_debug.g_err_stage,3);
                     END IF;
                 END IF;

                 --Fetch revenue version id for the plan type

                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.g_err_stage := 'Fetching baselined revenue plan version';
                    pa_debug.write( g_module_name,pa_debug.g_err_stage,3);
                 END IF;

                 PA_FIN_PLAN_UTILS.Get_Baselined_Version_Info(
                           p_project_id           => p_source_project_id
                           ,p_fin_plan_type_id    => l_fin_plan_type_id
                           ,p_version_type        => PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE
                           ,x_fp_options_id       => l_fp_options_id
                           ,x_fin_plan_version_id => l_fin_plan_version_id
                           ,x_return_status       => l_return_status
                           ,x_msg_count           => l_msg_count
                           ,x_msg_data            => l_msg_data );

                 --IF there is no baselined version existing fetch the options
                 --id current working version

                 IF (l_fp_options_id IS NULL) THEN

                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.g_err_stage := 'Baselined plan revenue version does not exist';
                          pa_debug.write( g_module_name,pa_debug.g_err_stage,3);

                          pa_debug.g_err_stage := 'Fetching current revenue woking plan version if any';
                          pa_debug.write( g_module_name,pa_debug.g_err_stage,3);
                       END IF;

                       PA_FIN_PLAN_UTILS.Get_Curr_Working_Version_Info(
                                 p_project_id           => p_source_project_id
                                 ,p_fin_plan_type_id    => l_fin_plan_type_id
                                 ,p_version_type        => PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE
                                 ,x_fp_options_id       => l_fp_options_id
                                 ,x_fin_plan_version_id => l_fin_plan_version_id
                                 ,x_return_status       => l_return_status
                                 ,x_msg_count           => l_msg_count
                                 ,x_msg_data            => l_msg_data );

                 END IF;

                 --Insert the fetched option id of plan version  if existing

                 IF (l_fp_options_id IS NOT NULL) THEN

                     IF P_PA_DEBUG_MODE = 'Y' THEN
                             pa_debug.g_err_stage := 'Storing option id of revenue plan version fetched';
                             pa_debug.write( g_module_name,pa_debug.g_err_stage,3);
                     END IF;

                     l_proj_fp_options_id_tbl(nvl(l_proj_fp_options_id_tbl.last,0)+1) := l_fp_options_id;

                 ELSE
                     IF P_PA_DEBUG_MODE = 'Y' THEN
                             pa_debug.g_err_stage := 'Current working revenue plan version does not exist for this plan type';
                             pa_debug.write( g_module_name,pa_debug.g_err_stage,3);
                     END IF;
                 END IF;

            ELSE

                  --Fetch baselined plan version id  for the plan type

                  IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.g_err_stage := 'Fetching baselined plan version if any';
                          pa_debug.write( g_module_name,pa_debug.g_err_stage,3);
                  END IF;

                  PA_FIN_PLAN_UTILS.Get_Baselined_Version_Info(
                            p_project_id           => p_source_project_id
                            ,p_fin_plan_type_id    => l_fin_plan_type_id
                            ,p_version_type        => NULL
                            ,x_fp_options_id       => l_fp_options_id
                            ,x_fin_plan_version_id => l_fin_plan_version_id
                            ,x_return_status       => l_return_status
                            ,x_msg_count           => l_msg_count
                            ,x_msg_data            => l_msg_data );

                  --IF there is no baselined version existing fetch the options
                  --id current working version

                  IF (l_fp_options_id IS NULL) THEN

                        IF P_PA_DEBUG_MODE = 'Y' THEN
                                pa_debug.g_err_stage := 'Baselined plan version does not exist';
                                pa_debug.write( g_module_name,pa_debug.g_err_stage,3);

                                pa_debug.g_err_stage := 'Fetching current woking plan version if any';
                                pa_debug.write( g_module_name,pa_debug.g_err_stage,3);
                        END IF;

                        PA_FIN_PLAN_UTILS.Get_Curr_Working_Version_Info(
                                  p_project_id            => p_source_project_id
                                  ,p_fin_plan_type_id     => l_fin_plan_type_id
                                  ,p_version_type         => NULL
                                  ,x_fp_options_id        => l_fp_options_id
                                  ,x_fin_plan_version_id  => l_fin_plan_version_id
                                  ,x_return_status        => l_return_status
                                  ,x_msg_count            => l_msg_count
                                  ,x_msg_data             => l_msg_data );

                  END IF;

                  --Insert the fetched option id of plan version if existing

                  IF (l_fp_options_id IS NOT NULL) THEN

                        IF P_PA_DEBUG_MODE = 'Y' THEN
                           pa_debug.g_err_stage := 'Storing option id of plan version fetched';
                           pa_debug.write( g_module_name,pa_debug.g_err_stage,3);
                        END IF;

                        l_proj_fp_options_id_tbl(nvl(l_proj_fp_options_id_tbl.last,0)+1) := l_fp_options_id;

                  ELSE
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                              pa_debug.g_err_stage := 'Current working plan version does not exist for this plan type';
                              pa_debug.write( g_module_name,pa_debug.g_err_stage,3);
                        END IF;
                  END IF;
            END IF; --l_fin_plan_preference_code

       END IF; /* p_copy_versions = 'Y' */

    END LOOP;
    CLOSE cur_for_fp_options;

    --Return the fp_options_id tbl;

    x_fp_options_ids_tbl := l_proj_fp_options_id_tbl;

    IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage := 'Exiting Get_Fp_Options_To_Be_Copied';
            pa_debug.write( g_module_name,pa_debug.g_err_stage,3);
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

        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Invalid Arguments Passed';
           pa_debug.write( g_module_name,pa_debug.g_err_stage,5);
           pa_debug.reset_err_stack;
        END IF;
        x_return_status:= FND_API.G_RET_STS_ERROR;

        RAISE;

   WHEN Others THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_FP_COPY_FROM_PKG'
                        ,p_procedure_name  => 'Get_Fp_Options_To_Be_Copied');

        IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
                pa_debug.write( g_module_name,pa_debug.g_err_stage,5);
                pa_debug.reset_err_stack;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Fp_Options_To_Be_Copied;


/* Bug# 2634726 -
   Private procedure (not available in specification) used by COPY_BUDGET_LINES
   (with shift days logic) to insert shifted periods data into pa_fp_cpy_period_tmp */

PROCEDURE populate_cpy_periods_tmp(p_budget_version_id PA_BUDGET_LINES.budget_version_id%type,
                                   p_period_type       PA_PROJ_FP_OPTIONS.cost_time_phased_code%TYPE,
                                   p_shift_periods     number) AS
cursor bl_periods is
    SELECT distinct bl.period_name,bl.start_date
    FROM   pa_budget_lines bl
    WHERE  budget_version_id = p_budget_version_id;

l_err_code    NUMBER;
l_err_stage   VARCHAR2(2000);
l_err_stack   VARCHAR2(2000);
l_period_name PA_BUDGET_PERIODS_V.period_name%TYPE;
l_start_date  DATE;
l_end_date    DATE;

BEGIN

DELETE FROM pa_fp_cpy_periods_tmp;

FOR i IN bl_periods LOOP

  l_period_name := NULL;
  l_start_date  := NULL;
  l_end_date    := NULL;
  l_err_code    := NULL;
  l_err_stage   := NULL;
  l_err_stack   := NULL;

  pa_budget_core.shift_periods(
                          x_start_period_date => i.start_date,
                          x_periods      => p_shift_periods,
                          x_period_name  => l_period_name,
                          x_period_type  => p_period_type,
                          x_start_date   => l_start_date,
                          x_end_date     => l_end_date,
                          x_err_code     => l_err_code,
                          x_err_stage    => l_err_stage,
                          x_err_stack    => l_err_stack);
  IF l_err_code <> 0 THEN
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.g_err_stage := 'Exception raised by pa_budget_core.shift_periods...';
       pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,5);
    END IF;

    PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                         p_msg_name      => l_err_stage);
    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
  END IF;

  If (l_period_name IS NOT NULL) then -- Added if condition for Bug 7556248  --Bug 9062715
  INSERT INTO pa_fp_cpy_periods_tmp
                      (PA_PERIOD_NAME
                      ,GL_PERIOD_NAME
                      ,PERIOD_NAME
                      ,START_DATE
                      ,END_DATE)
              VALUES
                      (decode(p_period_type,PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_P,i.period_name,'-99')
                      ,decode(p_period_type,PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_G,i.period_name,'-99')
                      ,l_period_name
                      ,l_start_date
                      ,l_end_date);
  END IF;
END LOOP;

END populate_cpy_periods_tmp;

  /*=========================================================================
   This api inserts budget lines for target using source budget lines. If
   the shift days are zero, this api will copy from source to target version
   without shifting any periods. If shift days are non-zero,then we shift
   periods according to the existing businees rules. project and projfunc
   currencies amounts copied as NULL and would be populated by
   convert_txn_currency api.
   This is an overloaded procedure as of now used during copying projects.

   21-Sep-04 Raja  Bug 3841942
                   During copy project flow, for non-time phased budgets
                   start and end date should be same as planning start and
                   end date of the resource assignment

                   2) If shift days i/p is not sufficient enough to cause
                      shift in periods changed the code to behave as if
                      shift days is zero.
   =========================================================================*/

  PROCEDURE Copy_Budget_Lines(
              p_source_project_id        IN  NUMBER
             ,p_target_project_id        IN  NUMBER
             ,p_source_plan_version_id   IN  NUMBER
             ,p_target_plan_version_id   IN  NUMBER
             ,p_shift_days               IN  NUMBER
             ,x_return_status            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_msg_count                OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
             ,x_msg_data                 OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
   AS

         l_msg_count          NUMBER :=0;
         l_data               VARCHAR2(2000);
         l_msg_data           VARCHAR2(2000);
         l_error_msg_code     VARCHAR2(2000);
         l_msg_index_out      NUMBER;
         l_return_status      VARCHAR2(2000);
         l_debug_mode         VARCHAR2(30);

         l_shift_days                   NUMBER;
         l_target_time_phased_code      pa_proj_fp_options.all_time_phased_code%TYPE;
         l_target_budget_entry_level    pa_proj_fp_options.all_fin_plan_level_code%TYPE; /* bug2726011 */
         l_target_proj_start_date       DATE; /*bug2726011*/
         l_target_proj_completion_date  DATE; /*bug2726011*/

         /* Bug# 2634726 */

         l_start_date                DATE;
         l_err_code                  NUMBER;
         l_err_stage                 VARCHAR2(2000);
         l_err_stack                 VARCHAR2(2000);
         l_periods                   NUMBER := 0;

         /* Bug# 2634726 */

   BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.set_err_stack('PA_FP_COPY_FROM_PKG.Copy_Budget_Lines');
END IF;
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.set_process('PLSQL','LOG',l_debug_mode);
END IF;
      -- Checking for all valid input parametrs

      IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage := 'Checking for valid parameters:';
           pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;

      IF (p_source_plan_version_id IS NULL) OR
         (p_target_plan_version_id IS NULL) OR
         (p_source_project_id      IS NULL) OR
         (p_target_project_id      IS NULL)
      THEN

           IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage := 'Source_plan='||p_source_plan_version_id;
                pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,5);
                pa_debug.g_err_stage := 'Target_plan'||p_target_plan_version_id;
                pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,5);
                pa_debug.g_err_stage := 'Source_project='||p_source_project_id;
                pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,5);
                pa_debug.g_err_stage := 'Target_project'||p_target_project_id;
                pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,5);
           END IF;

           PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                                p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage := 'Parameter validation complete';
           pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;

      --Make shift_days zero if passed as null

      l_shift_days := NVL(p_shift_days,0);

      IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Shift_days ='|| l_shift_days;
           pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;

      --Fetch the target versions time phased code

      l_target_time_phased_code := PA_FIN_PLAN_UTILS.get_time_phased_code(p_target_plan_version_id);
      l_target_budget_entry_level := PA_FIN_PLAN_UTILS.get_fin_plan_level_code(p_target_plan_version_id); /*bug2726011*/

      IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Time Phased Code ='|| l_target_time_phased_code;
           pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
           pa_debug.g_err_stage:='Budget Entry Level ='|| l_target_budget_entry_level;
           pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
           pa_debug.g_err_stage:='Inserting into pa_budget_lines';
           pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;

      IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage := 'Selecting project start and completion dates';
           pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;

      SELECT start_date,
             completion_date
      INTO   l_target_proj_start_date,
             l_target_proj_completion_date
      FROM   pa_projects p
      WHERE  p.project_id = p_target_project_id;

      IF l_shift_days  <> 0
      AND l_target_time_phased_code IN (PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_G,
                                        PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_P)
      THEN
          BEGIN

               IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.g_err_stage := 'Selecting project start date';
                    pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
               END IF;

               SELECT p.start_date
               INTO   l_start_date
               FROM   pa_projects p
               WHERE  p.project_id = p_source_project_id;

               IF l_start_date IS NULL THEN

                    IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.g_err_stage := 'Selecting task mininum start date';
                         pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
                    END IF;

                    SELECt min(t.start_date)
                    INTO   l_start_date
                    FROM   pa_tasks t
                    WHERE  t.project_id = p_source_project_id;

                    IF l_start_date is NULL THEN

                         IF P_PA_DEBUG_MODE = 'Y' THEN
                              pa_debug.g_err_stage := 'Selecting budget lines minimum start date';
                              pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
                         END IF;

                         SELECT min(bl.start_date)
                         INTO   l_start_Date
                         FROM   pa_budget_lines bl
                         WHERE  bl.budget_version_id = p_source_plan_version_id;

                         -- If l_start_date is null after the above select it implies
                         -- there are no budget lines. So return immediately as nothing
                         -- needs to be copied
                         IF l_start_Date IS NULL THEN
                            pa_debug.reset_err_stack;
                            RETURN;
                         END IF;

                    END IF;  /* Mininum Task start date is null */

               END IF; /* Minimum Project start date is null */
          EXCEPTION
             WHEN OTHERS THEN
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.g_err_stage := 'Error while fetching start date ' || sqlerrm;
                      pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,5);
                 END IF;
                 RAISE;
          END;

          --Based on the shift_days check how much shift is required period wise
          pa_budget_core.get_periods(
                        x_start_date1 => l_start_date,
                        x_start_date2 => l_start_date + l_shift_days,
                        x_period_type => l_target_time_phased_code,
                        x_periods     => l_periods,
                        x_err_code    => l_err_code,
                        x_err_stage   => l_err_stage,
                        x_err_stack   => l_err_stack);
          IF l_err_code <> 0 THEN
               IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.g_err_stage := 'Exception raised by pa_budget_core.get_periods...';
                    pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,5);
               END IF;

               PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                                    p_msg_name      => l_err_stage);
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;
      END IF; /* IF l_shift_days  <> 0 AND l_target_time_phased_code IN (PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_G,PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_P) */

      --If shift_days is zero or the timephasing is none.

      IF (l_shift_days = 0) OR  (l_periods = 0) OR
         (l_target_time_phased_code NOT IN (PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_G,
                                            PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_P))
      THEN
          /* If the time phasing is none, stamp the resource assignments' planning
             start and end dates for budget line start and end dates
           */
            --Display_quantity is being set in copy_version and copy_finplans_from_project api as well

           INSERT INTO PA_BUDGET_LINES(
                    budget_line_id              /* FPB2 */
                   ,budget_version_id           /* FPB2 */
                   ,resource_assignment_id
                   ,start_date
                   ,last_update_date
                   ,last_updated_by
                   ,creation_date
                   ,created_by
                   ,last_update_login
                   ,end_date
                   ,period_name
                   ,quantity
                   ,display_quantity  --IPM Arch Enhancement Bug 4865563.
                   ,raw_cost
                   ,burdened_cost
                   ,revenue
                   ,change_reason_code
                   ,description
                   ,attribute_category
                   ,attribute1
                   ,attribute2
                   ,attribute3
                   ,attribute4
                   ,attribute5
                   ,attribute6
                   ,attribute7
                   ,attribute8
                   ,attribute9
                   ,attribute10
                   ,attribute11
                   ,attribute12
                   ,attribute13
                   ,attribute14
                   ,attribute15
                   ,raw_cost_source
                   ,burdened_cost_source
                   ,quantity_source
                   ,revenue_source
                   ,pm_product_code
                   ,pm_budget_line_reference
                   ,cost_rejection_code
                   ,revenue_rejection_code
                   ,burden_rejection_code
                   ,other_rejection_code
                   ,code_combination_id
                   ,ccid_gen_status_code
                   ,ccid_gen_rej_message
                   ,request_id
                   ,borrowed_revenue
                   ,tp_revenue_in
                   ,tp_revenue_out
                   ,revenue_adj
                   ,lent_resource_cost
                   ,tp_cost_in
                   ,tp_cost_out
                   ,cost_adj
                   ,unassigned_time_cost
                   ,utilization_percent
                   ,utilization_hours
                   ,utilization_adj
                   ,capacity
                   ,head_count
                   ,head_count_adj
                   ,projfunc_currency_code
                   ,projfunc_cost_rate_type
                   ,projfunc_cost_exchange_rate
                   ,projfunc_cost_rate_date_type
                   ,projfunc_cost_rate_date
                   ,projfunc_rev_rate_type
                   ,projfunc_rev_exchange_rate
                   ,projfunc_rev_rate_date_type
                   ,projfunc_rev_rate_date
                   ,project_currency_code
                   ,project_cost_rate_type
                   ,project_cost_exchange_rate
                   ,project_cost_rate_date_type
                   ,project_cost_rate_date
                   ,project_raw_cost
                   ,project_burdened_cost
                   ,project_rev_rate_type
                   ,project_rev_exchange_rate
                   ,project_rev_rate_date_type
                   ,project_rev_rate_date
                   ,project_revenue
                   ,txn_raw_cost
                   ,txn_burdened_cost
                   ,txn_currency_code
                   ,txn_revenue
                   ,bucketing_period_code
                   -- 3/28/2004 FP M phase II Copy Project Impact
                   ,txn_standard_cost_rate
                   ,txn_cost_rate_override
                   ,cost_ind_compiled_set_id
                   ,txn_standard_bill_rate
                   ,txn_bill_rate_override
                   ,txn_markup_percent
                   ,txn_markup_percent_override
                   ,txn_discount_percentage
                   ,transfer_price_rate
                   ,init_quantity
                   ,init_quantity_source
                   ,init_raw_cost
                   ,init_burdened_cost
                   ,init_revenue
                   ,init_raw_cost_source
                   ,init_burdened_cost_source
                   ,init_revenue_source
                   ,project_init_raw_cost
                   ,project_init_burdened_cost
                   ,project_init_revenue
                   ,txn_init_raw_cost
                   ,txn_init_burdened_cost
                   ,txn_init_revenue
                   ,burden_cost_rate
                   ,burden_cost_rate_override
                   ,pc_cur_conv_rejection_code
                   ,pfc_cur_conv_rejection_code

                   )
           SELECT  pa_budget_lines_s.nextval            /* FPB2 */
                  ,p_target_plan_version_id             /* FPB2 */
                  ,pra.resource_assignment_id
                  ,DECODE(l_target_time_phased_code,
                          PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_N,nvl(l_target_proj_start_date , pbl.start_date + l_shift_days), --Bug 4739375,l_target_proj_start_date.--bug 3841942 l_target_proj_start_date,
                          pbl.start_date ) -- start_date
                  ,sysdate
                  ,fnd_global.user_id
                  ,sysdate
                  ,fnd_global.user_id
                  ,fnd_global.login_id
                 -- Commented by skkoppul for bug 7238582 and replaced this with the decode statement below
                 -- ,DECODE(l_target_time_phased_code,
                 --         PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_N, nvl(l_target_proj_completion_date, pbl.end_date + l_shift_days), --Bug 4739375,l_target_proj_completion_date,--bug 3841942 l_target_proj_completion_date,
                 --         pbl.end_date )   -- end_date
                 -- Default end date with start date if start date > end date else leave end date as is
                  ,DECODE(SIGN(DECODE(l_target_time_phased_code,PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_N,
                                      nvl(l_target_proj_start_date, pbl.start_date + l_shift_days), pbl.start_date)
                               -
                               DECODE(l_target_time_phased_code,PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_N,
                                      nvl(l_target_proj_completion_date, pbl.end_date + l_shift_days), pbl.end_date )),
                          1,
                          DECODE(l_target_time_phased_code,PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_N,
                                 nvl(l_target_proj_start_date, pbl.start_date + l_shift_days), pbl.start_date),
                          DECODE(l_target_time_phased_code,PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_N,
                                 nvl(l_target_proj_completion_date, pbl.end_date + l_shift_days), pbl.end_date))   -- end_date
                  ,pbl.period_name
                  ,pbl.quantity
                  ,pbl.display_quantity --IPM Arch Enhancement Bug 4865563.
                  ,NULL --raw_cost
                  ,NULL --burdened_cost
                  ,NULL --revenue
                  ,NULL --change_reason_code
                  ,pbl.description
                  ,pbl.attribute_category
                  ,pbl.attribute1
                  ,pbl.attribute2
                  ,pbl.attribute3
                  ,pbl.attribute4
                  ,pbl.attribute5
                  ,pbl.attribute6
                  ,pbl.attribute7
                  ,pbl.attribute8
                  ,pbl.attribute9
                  ,pbl.attribute10
                  ,pbl.attribute11
                  ,pbl.attribute12
                  ,pbl.attribute13
                  ,pbl.attribute14
                  ,pbl.attribute15
                  ,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M --raw_cost_souce
                  ,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M --burdened_cost_source
                  ,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M  --quantity_source
                  ,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M --revenue source
                  ,NULL --pm_product_code
                  ,NULL --pm_budget_line_reference
                  ,cost_rejection_code
                  ,revenue_rejection_code
                  ,burden_rejection_code
                  ,other_rejection_code
                  ,code_combination_id
                  ,ccid_gen_status_code
                  ,ccid_gen_rej_message
                  ,fnd_global.conc_request_id
                  ,borrowed_revenue
                  ,tp_revenue_in
                  ,tp_revenue_out
                  ,revenue_adj
                  ,lent_resource_cost
                  ,tp_cost_in
                  ,tp_cost_out
                  ,cost_adj
                  ,unassigned_time_cost
                  ,utilization_percent
                  ,utilization_hours
                  ,utilization_adj
                  ,capacity
                  ,head_count
                  ,head_count_adj
                  ,pbl.projfunc_currency_code
                  ,pbl.projfunc_cost_rate_type
                  ,pbl.projfunc_cost_exchange_rate
                  ,pbl.projfunc_cost_rate_date_type
                  ,pbl.projfunc_cost_rate_date
                  ,pbl.projfunc_rev_rate_type
                  ,pbl.projfunc_rev_exchange_rate
                  ,pbl.projfunc_rev_rate_date_type
                  ,pbl.projfunc_rev_rate_date
                  ,pbl.project_currency_code
                  ,pbl.project_cost_rate_type
                  ,pbl.project_cost_exchange_rate
                  ,pbl.project_cost_rate_date_type
                  ,pbl.project_cost_rate_date
                  ,NULL   --project_raw_cost
                  ,NULL   --project_burdened_cost
                  ,pbl.project_rev_rate_type
                  ,pbl.project_rev_exchange_rate
                  ,pbl.project_rev_rate_date_type
                  ,pbl.project_rev_rate_date
                  ,NULL  --project_revenue
                  ,txn_raw_cost
                  ,txn_burdened_cost
                  ,txn_currency_code
                  ,txn_revenue
                  ,NULL --bucketing_period_code
                   -- 3/28/2004 FP M phase II Copy Project Impact
                   ,NULL                                               -- txn_standard_cost_rate
                   ,nvl(txn_cost_rate_override,txn_standard_cost_rate) -- txn_cost_rate_override
                   ,cost_ind_compiled_set_id
                   ,NULL                                               -- txn_standard_bill_rate
                   ,nvl(txn_bill_rate_override,txn_standard_bill_rate) -- txn_bill_rate_override
                   ,NULL                                               -- txn_markup_percent
                   ,nvl(txn_markup_percent_override,txn_markup_percent)-- txn_markup_percent_override
                   ,txn_discount_percentage
                   ,transfer_price_rate
                   ,NULL                                               -- init_quantity
                   ,NULL                                               -- init_quantity_source
                   ,NULL                                               -- init_raw_cost
                   ,NULL                                               -- init_burdened_cost
                   ,NULL                                               -- init_revenue
                   ,NULL                                               -- init_raw_cost_source
                   ,NULL                                               -- init_burdened_cost_source
                   ,NULL                                               -- init_revenue_source
                   ,NULL                                               -- project_init_raw_cost
                   ,NULL                                               -- project_init_burdened_cost
                   ,NULL                                               -- project_init_revenue
                   ,NULL                                               -- txn_init_raw_cost
                   ,NULL                                               -- txn_init_burdened_cost
                   ,NULL                                               -- txn_init_revenue
                   ,NULL                                               -- burden_cost_rate
                   ,nvl(burden_cost_rate_override,burden_cost_rate)    -- burden_cost_rate_override
                   ,NULL                                               -- pc_cur_conv_rejection_code
                   ,NULL                                               -- pfc_cur_conv_rejection_code

           FROM   PA_BUDGET_LINES  pbl
                 ,pa_resource_assignments pra
           WHERE pbl.resource_assignment_id = pra.parent_assignment_id
           AND   pbl.budget_version_id = p_source_plan_version_id
           AND   pra.budget_version_id=p_target_plan_version_id;


       /* Start of Code Fix for Bug:4739375.*/

           IF (l_target_time_phased_code NOT IN(PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_G,
                                                PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_P)) THEN
       /*
              UPDATE pa_resource_assignments pra
              SET (pra.planning_start_date , pra.planning_end_date , pra.sp_fixed_date)
                 = (SELECT least(pra.planning_start_date + l_shift_days,
                                nvl(min(bl.start_date) , pra.planning_start_date + l_shift_days)),
                          greatest(pra.planning_end_date + l_shift_days,
                                   nvl(max(bl.end_date) , pra.planning_end_date + l_shift_days)),
                          greatest(least(pra.sp_fixed_date + l_shift_days , pra.planning_end_date + l_shift_days),
                                   pra.planning_start_date + l_shift_days)
                   FROM pa_budget_lines bl
                   WHERE bl.resource_assignment_id = pra.resource_assignment_id
                   )
              WHERE pra.budget_version_id = p_target_plan_version_id;
	    */
            /* Bug 5846751: Commented the above update and added a new update to derive the Resource Assignment's
               dates similar to that of the Budget Lines start and end dates in the above INSERT statement. */
            update pa_resource_assignments pra
               set (pra.planning_start_date, pra.planning_end_date,pra.sp_fixed_date)
                   = ( select nvl(min(bl.start_date),nvl(l_target_proj_start_date, pra.planning_start_date + l_shift_days)),
                              -- skkoppul - bug 7626463 : commented the line below and added decode statement
                              -- Default end date with start date if start date > end date else leave end date as is
                              --nvl(min(bl.end_date),nvl(l_target_proj_completion_date, pra.planning_end_date + l_shift_days)),
                              DECODE(SIGN(nvl(min(bl.start_date),nvl(l_target_proj_start_date, pra.planning_start_date + l_shift_days))
                                          -
                                          nvl(min(bl.end_date),nvl(l_target_proj_completion_date, pra.planning_end_date + l_shift_days))),
                                     1,
                                     nvl(min(bl.start_date),nvl(l_target_proj_start_date, pra.planning_start_date + l_shift_days)),
                                     nvl(min(bl.end_date),nvl(l_target_proj_completion_date, pra.planning_end_date + l_shift_days))),   -- end_date
                              decode(pra.sp_fixed_date,null,null,nvl(min(bl.start_date),nvl(l_target_proj_start_date, pra.sp_fixed_date + l_shift_days)))
                       from   pa_budget_lines bl
                       where  bl.resource_assignment_id = pra.resource_assignment_id
                     )
             where  pra.budget_version_id = p_target_plan_version_id;

           END IF;

       /*End of Code Fix for Bug:4739375*/


       ELSE

           /* Start of code fix for bug# 2634726 */

           -- Call a private api to populate pa_fp_cpy_periods_tmp table
           populate_cpy_periods_tmp(p_budget_version_id => p_source_plan_version_id,
                                    p_period_type       => l_target_time_phased_code,
                                    p_shift_periods     => l_periods);

           -- Shift the pa_periods by l_periods
           -- Bug# 2634726- The two individual inserts which read pa_periods or gl_period_statuses based
           -- on the l_target_time_phased_code condition have been merged into one insert which reads
           -- pa_fp_cpy_periods_tmp

           INSERT INTO PA_BUDGET_LINES(
                    budget_line_id              /* FPB2 */
                   ,budget_version_id           /* FPB2 */
                   ,resource_assignment_id
                   ,start_date
                   ,last_update_date
                   ,last_updated_by
                   ,creation_date
                   ,created_by
                   ,last_update_login
                   ,end_date
                   ,period_name
                   ,quantity
                   ,display_quantity  --IPM Arch Enhancement Bug 4865563
                   ,raw_cost
                   ,burdened_cost
                   ,revenue
                   ,change_reason_code
                   ,description
                   ,attribute_category
                   ,attribute1
                   ,attribute2
                   ,attribute3
                   ,attribute4
                   ,attribute5
                   ,attribute6
                   ,attribute7
                   ,attribute8
                   ,attribute9
                   ,attribute10
                   ,attribute11
                   ,attribute12
                   ,attribute13
                   ,attribute14
                   ,attribute15
                   ,raw_cost_source
                   ,burdened_cost_source
                   ,quantity_source
                   ,revenue_source
                   ,pm_product_code
                   ,pm_budget_line_reference
                   ,cost_rejection_code
                   ,revenue_rejection_code
                   ,burden_rejection_code
                   ,other_rejection_code
                   ,code_combination_id
                   ,ccid_gen_status_code
                   ,ccid_gen_rej_message
                   ,request_id
                   ,borrowed_revenue
                   ,tp_revenue_in
                   ,tp_revenue_out
                   ,revenue_adj
                   ,lent_resource_cost
                   ,tp_cost_in
                   ,tp_cost_out
                   ,cost_adj
                   ,unassigned_time_cost
                   ,utilization_percent
                   ,utilization_hours
                   ,utilization_adj
                   ,capacity
                   ,head_count
                   ,head_count_adj
                   ,projfunc_currency_code
                   ,projfunc_cost_rate_type
                   ,projfunc_cost_exchange_rate
                   ,projfunc_cost_rate_date_type
                   ,projfunc_cost_rate_date
                   ,projfunc_rev_rate_type
                   ,projfunc_rev_exchange_rate
                   ,projfunc_rev_rate_date_type
                   ,projfunc_rev_rate_date
                   ,project_currency_code
                   ,project_cost_rate_type
                   ,project_cost_exchange_rate
                   ,project_cost_rate_date_type
                   ,project_cost_rate_date
                   ,project_raw_cost
                   ,project_burdened_cost
                   ,project_rev_rate_type
                   ,project_rev_exchange_rate
                   ,project_rev_rate_date_type
                   ,project_rev_rate_date
                   ,project_revenue
                   ,txn_raw_cost
                   ,txn_burdened_cost
                   ,txn_currency_code
                   ,txn_revenue
                   ,bucketing_period_code
                   -- 3/28/2004 FP M phase II Copy Project Impact
                   ,txn_standard_cost_rate
                   ,txn_cost_rate_override
                   ,cost_ind_compiled_set_id
                   ,txn_standard_bill_rate
                   ,txn_bill_rate_override
                   ,txn_markup_percent
                   ,txn_markup_percent_override
                   ,txn_discount_percentage
                   ,transfer_price_rate
                   ,init_quantity
                   ,init_quantity_source
                   ,init_raw_cost
                   ,init_burdened_cost
                   ,init_revenue
                   ,init_raw_cost_source
                   ,init_burdened_cost_source
                   ,init_revenue_source
                   ,project_init_raw_cost
                   ,project_init_burdened_cost
                   ,project_init_revenue
                   ,txn_init_raw_cost
                   ,txn_init_burdened_cost
                   ,txn_init_revenue
                   ,burden_cost_rate
                   ,burden_cost_rate_override
                   ,pc_cur_conv_rejection_code
                   ,pfc_cur_conv_rejection_code
                   )
           SELECT  pa_budget_lines_s.nextval            /* FPB2 */
                  ,p_target_plan_version_id             /* FPB2 */
                  ,pra.resource_assignment_id
                  ,pptmp.start_date
                  ,sysdate
                  ,fnd_global.user_id
                  ,sysdate
                  ,fnd_global.user_id
                  ,fnd_global.login_id
                  ,pptmp.end_date
                  ,pptmp.period_name
                  ,pbl.quantity
                  ,pbl.display_quantity    --IPM Arch Enhancement Bug 4865563
                  ,NULL --raw_cost
                  ,NULL --burdened_cost
                  ,NULL --revenue
                  ,NULL --change_reason_code
                  ,pbl.description
                  ,pbl.attribute_category
                  ,pbl.attribute1
                  ,pbl.attribute2
                  ,pbl.attribute3
                  ,pbl.attribute4
                  ,pbl.attribute5
                  ,pbl.attribute6
                  ,pbl.attribute7
                  ,pbl.attribute8
                  ,pbl.attribute9
                  ,pbl.attribute10
                  ,pbl.attribute11
                  ,pbl.attribute12
                  ,pbl.attribute13
                  ,pbl.attribute14
                  ,pbl.attribute15
                  ,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M --raw_cost_souce
                  ,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M --burdened_cost_source
                  ,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M  --quantity_source
                  ,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M --revenue source
                  ,NULL --pm_product_code
                  ,NULL --pm_budget_line_reference
                  ,cost_rejection_code
                  ,revenue_rejection_code
                  ,burden_rejection_code
                  ,other_rejection_code
                  ,code_combination_id
                  ,ccid_gen_status_code
                  ,ccid_gen_rej_message
                  ,fnd_global.conc_request_id
                  ,borrowed_revenue
                  ,tp_revenue_in
                  ,tp_revenue_out
                  ,revenue_adj
                  ,lent_resource_cost
                  ,tp_cost_in
                  ,tp_cost_out
                  ,cost_adj
                  ,unassigned_time_cost
                  ,utilization_percent
                  ,utilization_hours
                  ,utilization_adj
                  ,capacity
                  ,head_count
                  ,head_count_adj
                  ,pbl.projfunc_currency_code
                  ,pbl.projfunc_cost_rate_type
                  ,pbl.projfunc_cost_exchange_rate
                  ,pbl.projfunc_cost_rate_date_type
                  ,pbl.projfunc_cost_rate_date
                  ,pbl.projfunc_rev_rate_type
                  ,pbl.projfunc_rev_exchange_rate
                  ,pbl.projfunc_rev_rate_date_type
                  ,pbl.projfunc_rev_rate_date
                  ,pbl.project_currency_code
                  ,pbl.project_cost_rate_type
                  ,pbl.project_cost_exchange_rate
                  ,pbl.project_cost_rate_date_type
                  ,pbl.project_cost_rate_date
                  ,NULL   --project_raw_cost
                  ,NULL   --project_burdened_cost
                  ,pbl.project_rev_rate_type
                  ,pbl.project_rev_exchange_rate
                  ,pbl.project_rev_rate_date_type
                  ,pbl.project_rev_rate_date
                  ,NULL  --project_revenue
                  ,txn_raw_cost
                  ,txn_burdened_cost
                  ,txn_currency_code
                  ,txn_revenue
                  ,NULL --bucketing_period_code
                  ,NULL                                               -- txn_standard_cost_rate
                  ,nvl(txn_cost_rate_override,txn_standard_cost_rate) -- txn_cost_rate_override
                  ,cost_ind_compiled_set_id
                  ,NULL                                               -- txn_standard_bill_rate
                  ,nvl(txn_bill_rate_override,txn_standard_bill_rate) -- txn_bill_rate_override
                  ,NULL                                               -- txn_markup_percent
                  ,nvl(txn_markup_percent_override,txn_markup_percent)-- txn_markup_percent_override
                  ,txn_discount_percentage
                  ,transfer_price_rate
                  ,NULL                                               -- init_quantity
                  ,NULL                                               -- init_quantity_source
                  ,NULL                                               -- init_raw_cost
                  ,NULL                                               -- init_burdened_cost
                  ,NULL                                               -- init_revenue
                  ,NULL                                               -- init_raw_cost_source
                  ,NULL                                               -- init_burdened_cost_source
                  ,NULL                                               -- init_revenue_source
                  ,NULL                                               -- project_init_raw_cost
                  ,NULL                                               -- project_init_burdened_cost
                  ,NULL                                               -- project_init_revenue
                  ,NULL                                               -- txn_init_raw_cost
                  ,NULL                                               -- txn_init_burdened_cost
                  ,NULL                                               -- txn_init_revenue
                  ,NULL                                               -- burden_cost_rate
                  ,nvl(burden_cost_rate_override,burden_cost_rate)    -- burden_cost_rate_override
                  ,NULL                                               -- pc_cur_conv_rejection_code
                  ,NULL                                               -- pfc_cur_conv_rejection_code
           FROM   PA_BUDGET_LINES  pbl
                  ,pa_resource_assignments pra
                  ,PA_FP_CPY_PERIODS_TMP pptmp /* Bug# 2634726 */
           WHERE pra.parent_assignment_id = pbl.resource_assignment_id
           AND   decode(l_target_time_phased_code,
                    PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_P, pptmp.pa_period_name,
                    PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_G, pptmp.gl_period_name) = pbl.period_name
           AND   pbl.budget_version_id = p_source_plan_version_id
           AND   pra.budget_version_id=p_target_plan_version_id;

           /* End of code fix for bug# 2634726 */

            -- Bug 3841942 this update is required to make sure that planning start/end dates
            -- encompass budget line start and end dates after the shift
            --Bug 4200168, The logic for deriving sp fixed date is transferred to this previous. Previously
            --it was there in copy resource assignments.
            update pa_resource_assignments pra
            set    (pra.planning_start_date, pra.planning_end_date,pra.sp_fixed_date)
                   = ( select least(pra.planning_start_date+l_shift_days,
                                       nvl(min(bl.start_date),pra.planning_start_date+l_shift_days)),
                              greatest(pra.planning_end_date+l_shift_days,
                                       nvl(max(bl.end_date),pra.planning_end_date+l_shift_days)),
                              greatest(least(pra.sp_fixed_date + l_shift_days, pra.planning_end_date+ l_shift_days),
                                        pra.planning_start_date+ l_shift_days)
                       from   pa_budget_lines bl
                       where  bl.resource_assignment_id = pra.resource_assignment_id
                     )
            where  pra.budget_version_id = p_target_plan_version_id;

      END IF; --l_target_time_phased_code

      IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Exiting Copy_Budget_Lines';
           pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
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
                pa_debug.g_err_stage:='Invalid arguments passed';
                pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,5);
                pa_debug.reset_err_stack;
          END IF;
           RAISE;

      WHEN Others THEN

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_count     := 1;
           x_msg_data      := SQLERRM;
           FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_FP_COPY_FROM_PKG'
                               ,p_procedure_name  => 'COPY_BUDGET_LINES');
           IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage:='Unexpected error'||SQLERRM;
                pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,6);
                pa_debug.reset_err_stack;
	   END IF;
           RAISE;

END Copy_Budget_Lines;

/*==================================================================
   This api is called during copy_project for the creation of new
   period profiles for the target project. The api creates new current
   period profiles for the target project using the current period
   profiles of the source project.
 ===================================================================*/

PROCEDURE Copy_Current_Period_Profiles
   (  p_target_project_id     IN   pa_projects.project_id%TYPE
     ,p_source_project_id     IN   pa_projects.project_id%TYPE
     ,p_shift_days            IN   NUMBER
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_return_status                 VARCHAR2(2000);

l_target_period_profile_id      pa_budget_versions.period_profile_id%TYPE;
l_source_period_profile_id      pa_budget_versions.period_profile_id%TYPE;
l_dummy                         NUMBER;

CURSOR current_period_profiles_cur IS
SELECT period_profile_id
FROM   pa_proj_period_profiles pp
WHERE  pp.project_id = p_source_project_id
AND    pp.current_flag = 'Y';

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF p_pa_debug_mode = 'Y' THEN
           pa_debug.set_err_stack('PA_FP_COPY_FROM_PKG.Copy_Current_Period_Profiles');
           pa_debug.set_process('PLSQL','LOG',p_pa_debug_mode);
      END IF;

      -- Check for NOT NULL parameters

      IF (p_source_project_id IS NULL)  OR
         (p_target_project_id IS NULL)  OR
         (p_shift_days        IS NULL )
      THEN
          IF p_pa_debug_mode = 'Y' THEN
              pa_debug.g_err_stage := 'Source_project ='||p_source_project_id;
              pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
              pa_debug.g_err_stage := 'Target_project ='||p_target_project_id;
              pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
              pa_debug.g_err_stage := 'p_shift_days ='||p_shift_days;
              pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
          END IF;
          PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                               p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      -- For the copied budget versions, create a new period profile
      -- by shifting existing period profile

      OPEN current_period_profiles_cur;
      LOOP

          FETCH current_period_profiles_cur INTO l_source_period_profile_id;
          EXIT WHEN current_period_profiles_cur%NOTFOUND;

          /* Bug 2987076 - Period profile would not be created if periods are not available for the shifted dates */

          PA_FP_COPY_FROM_PKG.Get_Create_Shifted_PD_Profile (
                   p_target_project_id            =>  p_target_project_id
                  ,p_source_period_profile_id     =>  l_source_period_profile_id
                  ,p_shift_days                   =>  p_shift_days
                  ,x_target_period_profile_id     =>  l_target_period_profile_id
                  ,x_return_status                =>  l_return_status
                  ,x_msg_count                    =>  l_msg_count
                  ,x_msg_data                     =>  l_msg_data    );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;

      END LOOP;
      CLOSE current_period_profiles_cur;

      IF p_pa_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Exiting Copy_Current_Period_Profiles';
              pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
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
                          ( p_pkg_name        => 'PA_FP_COPY_FROM_PKG'
                           ,p_procedure_name  => 'Copy_Current_Period_Profiles'
                           ,p_error_text      => sqlerrm);
          IF p_pa_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;
              pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
              pa_debug.reset_err_stack;
          END IF;
          RAISE;

END Copy_Current_Period_Profiles;

/*==============================================================================
   This api creates new period profile for the new project created during
   copy_project. The api does the following :

   a -> source profile duration
   b -> shift_days

   1) The source period profile is shifted by p_shift_days
   2) If the shifted period profile goes ahead of the target project end date then,
       2.1) the project end date is set as period profile end date
       2.2) the profile start date is fetched by moving 'a' periods back.
       2.3) if the profile start date goes beyond the target project start date ,
            we make the target project start date as period profile start date.
 ================================================================================*/

PROCEDURE Get_Create_Shifted_PD_Profile
   (  p_target_project_id               IN      pa_projects.project_id%TYPE
     ,p_source_period_profile_id        IN      pa_proj_period_profiles.period_profile_id%TYPE
     ,p_shift_days                      IN      NUMBER
     ,x_target_period_profile_id        OUT     NOCOPY pa_proj_period_profiles.period_profile_id%TYPE --File.Sql.39 bug 4440895
     ,x_return_status                   OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                       OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                        OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_return_status                 VARCHAR2(2000);
l_index                         NUMBER;

l_period_set_name               gl_sets_of_books.period_set_name%TYPE;
l_accounted_period_type         gl_sets_of_books.accounted_period_type%TYPE;
l_pa_period_type                pa_implementations.pa_period_type%TYPE;

l_number_of_periods             NUMBER;
l_plan_start_date               pa_periods.start_date%TYPE;
l_plan_end_date                 pa_periods.end_date%TYPE;

l_start_period                  pa_periods.period_name%TYPE;
l_start_period_start_date       pa_periods.start_date%TYPE;
l_start_period_end_date         pa_periods.end_date%TYPE;

l_end_period                    pa_periods.period_name%TYPE;
l_end_period_start_date         pa_periods.start_date%TYPE;
l_end_period_end_date           pa_periods.end_date%TYPE;

l_target_proj_gl_start_period   gl_periods.period_name%TYPE;
l_target_proj_gl_end_period     gl_periods.period_name%TYPE;
l_target_proj_pa_start_period   pa_periods.period_name%TYPE;
l_target_proj_pa_end_period     pa_periods.period_name%TYPE;

l_target_proj_start_period      pa_periods.period_name%TYPE;
l_target_proj_end_period        pa_periods.period_name%TYPE;

l_dummy_flag                    VARCHAR2(1);
l_dummy1                        VARCHAR2(30);
l_dummy2                        VARCHAR2(30);

CURSOR  source_profile_info_cur (c_period_profile_id pa_proj_period_profiles.period_profile_id%TYPE)
IS
SELECT   number_of_periods
        ,plan_period_type
        ,period_profile_type
        ,period_name1          --  profile_start_period
        ,profile_end_period_name
        ,period1_start_date    -- profile start date
        ,current_flag
FROM    pa_proj_period_profiles
WHERE   period_profile_id  = c_period_profile_id ;

source_profile_info_rec  source_profile_info_cur%ROWTYPE;

/* Bug# 2987076 */
l_create_period_profile         VARCHAR2(1) := 'Y';
l_prj_start_date                VARCHAR2(12);
l_prj_end_date                  VARCHAR2(12);
/* Bug# 2987076 */

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.set_err_stack('PA_FP_COPY_FROM_PKG.Get_Create_Shifted_PD_Profile');
      pa_debug.set_process('PLSQL','LOG',p_pa_debug_mode);
END IF;
      -- Check for NOT NULL parameters

      IF (p_target_project_id IS NULL)  OR
         (p_source_period_profile_id IS NULL) OR
         (p_shift_days IS NULL)
      THEN
          IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'p_target_project_id = '|| p_target_project_id;
                pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                pa_debug.g_err_stage:= 'p_source_period_profile_id = '|| p_source_period_profile_id;
                pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                pa_debug.g_err_stage:= 'p_shift_days = '|| p_shift_days;
                pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                pa_debug.g_err_stage:= 'Invalid Arguments Passed';
                pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          END IF;
          PA_UTILS.ADD_MESSAGE
                 (p_app_short_name => 'PA',
                  p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      -- Check for the target project if a period profile has been already created
      -- for the passed source period profile

      IF NVL(g_source_period_profile_tbl.last,0) > 0 then
              FOR i IN g_source_period_profile_tbl.first .. g_source_period_profile_tbl.last
              LOOP
                   -- If found then return the target period profile to the calling program

                   IF  g_source_period_profile_tbl(i) = p_source_period_profile_id
                   THEN
                       x_target_period_profile_id := g_target_period_profile_tbl(i);
IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.reset_err_stack;
END IF;
                       RETURN;
                   END IF;
              END LOOP;
      END IF;

      -- If no corresponding target period profile has been already created,
      -- then create one.

      -- Fetch the source period profile details
      IF p_pa_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Opening source_profile_info_cur';
              pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      OPEN source_profile_info_cur(p_source_period_profile_id);
      FETCH source_profile_info_cur INTO source_profile_info_rec;
      CLOSE source_profile_info_cur;

      BEGIN
              -- Fetching the details required to create period profile for the target project

              SELECT  b.period_set_name
                     ,DECODE(source_profile_info_rec.plan_period_type,
                             PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_PA ,pa_period_type,
                             PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_GL ,accounted_period_type) --accounted_period_type
                     ,DECODE(source_profile_info_rec.plan_period_type,
                             PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_PA ,pa_period_type,
                             PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_GL ,NULL) --pa_period_type
              INTO   l_period_set_name
                     ,l_accounted_period_type
                     ,l_pa_period_type
              FROM   pa_projects_all    p
                     -- MOAC changes
                     -- replaced with pa_implementations_all table.
                     --,pa_implementations  a
                     ,pa_implementations_all  a
                     ,gl_sets_of_books  b
              WHERE  p.project_id = p_target_project_id
              -- MOAC changes
              -- removed the nvl around the org_id.
              -- AND    NVL(p.Org_Id,-99) = NVL(a.Org_Id,-99)
              AND    p.Org_Id =a.Org_Id
              AND    a.set_of_books_id = b.set_of_books_id;
      EXCEPTION
           WHEN OTHERS THEN
                IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Unexp Error while fetching the accounted period type||SQLERRM';
                        pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                END IF;
                RAISE;
      END;


      -- Fetch the target project start and completion dates
      -- Fetch the GL/PA periods into which the target project start and completion dates fall.
      IF p_pa_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'Calling Pa_Prj_Period_Profile_Utils.Get_Prj_Defaults';
             pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      Pa_Prj_Period_Profile_Utils.Get_Prj_Defaults(
               p_project_id                 =>   p_target_project_id
              ,p_info_flag                  =>   NULL
              ,p_create_defaults            =>   'N'
              ,x_gl_start_period            =>   l_target_proj_gl_start_period
              ,x_gl_end_period              =>   l_target_proj_gl_end_period
              ,x_gl_start_Date              =>   l_dummy1     -- varchar2
              ,x_pa_start_period            =>   l_target_proj_pa_start_period
              ,x_pa_end_period              =>   l_target_proj_pa_end_period
              ,x_pa_start_date              =>   l_dummy2      -- varchar2
              ,x_plan_version_exists_flag   =>   l_dummy_flag
              ,x_prj_start_date             =>   l_prj_start_date
              ,x_prj_end_date               =>   l_prj_end_date);

      IF source_profile_info_rec.plan_period_type = 'PA' THEN

            l_target_proj_start_period :=  l_target_proj_pa_start_period;
            l_target_proj_end_period   :=  l_target_proj_pa_end_period;

      ELSIF source_profile_info_rec.plan_period_type = 'GL' THEN

            l_target_proj_start_period :=  l_target_proj_gl_start_period;
            l_target_proj_end_period   :=  l_target_proj_gl_end_period;

      END IF;

      -- Shift the source period profile start date by p_shift_days input.
      IF p_pa_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Shifting source period profile by shift days i/p';
              pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      BEGIN /* Bug 2987076 - If shifted period is not available then return without creating the period profile */

           IF    source_profile_info_rec.plan_period_type = 'PA' THEN

                    SELECT period_name
                           ,start_date
                    INTO   l_start_period
                           ,l_start_period_start_date
                    FROM   pa_periods
                    WHERE  TRUNC(source_profile_info_rec.period1_start_date + p_shift_days) BETWEEN start_date AND end_date;

           ELSIF  source_profile_info_rec.plan_period_type = 'GL' THEN

                    SELECT period_name
                           ,start_date
                    INTO   l_start_period
                           ,l_start_period_start_date
                    FROM   gl_period_statuses g
                          ,pa_implementations i
                    WHERE  g.application_id = pa_period_process_pkg.application_id
                    AND    g.set_of_books_id = i.set_of_books_id
                    AND    g.adjustment_period_flag = 'N'
                    AND    TRUNC(source_profile_info_rec.period1_start_date + p_shift_days) BETWEEN start_date AND end_date;

           END IF;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN

           IF p_pa_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:= 'Periods not available in system for the shifted dates!!!!';
                   pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                   pa_debug.g_err_stage:= 'Period profile is not created.....';
                   pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
           END IF;

           l_create_period_profile := 'N';

      END;

      IF l_create_period_profile = 'Y' THEN /* Bug 2987076 */

           -- Fetch the target profile end period by shifting the fetching the target profile start period forward
           -- by the number of periods of the source period profile
           IF p_pa_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:= 'Calling get_Shifted_period';
                   pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
           END IF;

           PA_FIN_PLAN_UTILS.Get_Shifted_Period (
                     p_period_name                   =>   l_start_period
                    ,p_plan_period_type              =>   source_profile_info_rec.plan_period_type
                    ,p_number_of_periods             =>   (source_profile_info_rec.number_of_periods -1)
                    ,x_shifted_period                =>   l_end_period
                    ,x_shifted_period_start_date     =>   l_end_period_start_date
                    ,x_shifted_period_end_date       =>   l_end_period_end_date
                    ,x_return_status                 =>   l_return_status
                    ,x_msg_count                     =>   l_msg_count
                    ,x_msg_data                      =>   l_msg_data );

           IF p_pa_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:= 'l_end_period_start_date ='||l_end_period_start_date;
                   pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                   pa_debug.g_err_stage:= 'l_prj_end_date=' || l_prj_end_date;
                   pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
           END IF;

           IF  (l_prj_end_date IS NOT NULL) AND
               (to_date(l_prj_end_date,'rrrr/mm/dd') < l_end_period_start_date)
           THEN

                 -- If the fetched end period has gone beyond the project completion date then
                 -- set the target project end period as the target profile end period

                 l_end_period := l_target_proj_end_period;

                 -- Fetch the end date of the above period

                 PA_FIN_PLAN_UTILS.Get_Period_Details(
                              p_period_name       =>   l_end_period
                             ,p_plan_period_type  =>   source_profile_info_rec.plan_period_type
                             ,x_start_date        =>   l_end_period_start_date
                             ,x_end_date          =>   l_end_period_end_date
                             ,x_return_status     =>   l_return_status
                             ,x_msg_count         =>   l_msg_count
                             ,x_msg_data          =>   l_msg_data );

                 -- Fetch the start period of the target period profile by moving backward from the end period
                 -- by the number of periods of the source period profile

                 PA_FIN_PLAN_UTILS.Get_Shifted_Period (
                             p_period_name                   =>   l_end_period
                            ,p_plan_period_type              =>   source_profile_info_rec.plan_period_type
                            ,p_number_of_periods             =>   (-source_profile_info_rec.number_of_periods+1)
                            ,x_shifted_period                =>   l_start_period
                            ,x_shifted_period_start_date     =>   l_start_period_start_date
                            ,x_shifted_period_end_date       =>   l_start_period_end_date
                            ,x_return_status                 =>   l_return_status
                            ,x_msg_count                     =>   l_msg_count
                            ,x_msg_data                      =>   l_msg_data );

                -- check if the fetched start period has gone beyond the target project start date.
                -- if so make the target project start period as the profile start period

                IF  (l_start_period_end_date < to_date(l_prj_start_date,'rrrr/mm/dd'))
                THEN
                         l_start_period := l_target_proj_start_period;

                         -- If the fetched start period doesn't fall in the project duration, then
                         -- set the project start period as the period profile start period

                         Pa_Fin_Plan_Utils.Get_Period_Details(
                                      p_period_name       =>   l_start_period
                                     ,p_plan_period_type  =>   source_profile_info_rec.plan_period_type
                                     ,x_start_date        =>   l_start_period_start_date
                                     ,x_end_date          =>   l_start_period_end_date
                                     ,x_return_status     =>   l_return_status
                                     ,x_msg_count         =>   l_msg_count
                                     ,x_msg_data          =>   l_msg_data );
                END IF;
           END IF;

           -- Call Maintain_Prj_Period_Profile

           IF p_pa_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:= 'Calling  Pa_Prj_Period_Profile_Utils.Maintain_Prj_Period_Profile';
                   pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
           END IF;

           Pa_Prj_Period_Profile_Utils.Maintain_Prj_Period_Profile(
                      p_project_id              =>   p_target_project_id
                     ,p_period_profile_type     =>   source_profile_info_rec.period_profile_type
                     ,p_plan_period_type        =>   source_profile_info_rec.plan_period_type
                     ,p_period_set_name         =>   l_period_set_name
                     ,p_gl_period_type          =>   l_accounted_period_type
                     ,p_pa_period_type          =>   l_pa_period_type
                     ,p_start_date              =>   l_start_period_start_date
                     ,px_end_date               =>   l_end_period_end_date
                     ,px_period_profile_id      =>   x_target_period_profile_id
                     ,p_commit_flag             =>   'N'
                     ,px_number_of_periods      =>   l_number_of_periods
                     ,x_plan_start_date         =>   l_plan_start_date
                     ,x_plan_end_date           =>   l_plan_end_date
                     ,x_return_status           =>   l_return_status
                     ,x_msg_count               =>   l_msg_count
                     ,x_msg_data                =>   l_msg_data );

           -- update the global pl/sqls with the source period profile and
           -- equivalent target period profile

           l_index := NVL(g_source_period_profile_tbl.last,0)+1;

           g_source_period_profile_tbl(l_index) := p_source_period_profile_id;
           g_target_period_profile_tbl(l_index) := x_target_period_profile_id;

      END IF; /* l_create_period_profile = 'Y' */

      IF p_pa_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Exiting Get_Create_Shifted_PD_Profile';
              pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
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
IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.reset_err_stack;
END IF;
           RAISE;

   WHEN others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg
                          ( p_pkg_name        => 'PA_FP_COPY_FROM_PKG'
                           ,p_procedure_name  => 'Get_Create_Shifted_PD_Profile'
                           ,p_error_text      => sqlerrm);
          IF p_pa_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;
                  pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                  pa_debug.reset_err_stack;
	END IF;
          RAISE;
END Get_Create_Shifted_PD_Profile;


/*============================================================================================================
 * This procedure should be called to copy a workplan version. Copies budget
 * versions, resource assignments  and budget lines as required for the workplan
 * version. This is added for FP M (Bug 3354518)

 * 04-Jun-04  Bug 3619687  Raja
 * When a working version is created from a published workplan version,
 * all the additional workplan settings data (plan settings, txn currencies
 * and rate schedules) should be inherited from workplan plan type.

 * 24-Sep-2004 Bug 3847386  Raja
 * Added a new parameter p_copy_act_from_str_ids_tbl. The table would contain
 * from which version actuals should be copied for the target versions if they
 * need to be copied

 ============================================================================================================*/

PROCEDURE copy_wp_budget_versions
(
       p_source_project_id            IN       pa_proj_element_versions.project_id%TYPE
      ,p_target_project_id            IN       pa_proj_element_versions.element_version_id%TYPE
      ,p_src_sv_ids_tbl               IN       SYSTEM.pa_num_tbl_type
      ,p_target_sv_ids_tbl            IN       SYSTEM.pa_num_tbl_type
      ,p_copy_act_from_str_ids_tbl    IN       SYSTEM.pa_num_tbl_type -- bug 3847386
      ,p_copy_people_flag             IN       VARCHAR2
      ,p_copy_equip_flag              IN       VARCHAR2
      ,p_copy_mat_item_flag           IN       VARCHAR2
      ,p_copy_fin_elem_flag           IN       VARCHAR2
      ,p_copy_mode                    IN       VARCHAR2             --bug 4277801
      ,x_return_status                OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_msg_count                    OUT      NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,x_msg_data                     OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) AS

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
    l_module_name                              VARCHAR2(200) :=  g_module_name || '.copy_wp_budget_versions';
    i                                          NUMBER;
    l_src_budget_version_id                    pa_budget_versions.budget_version_id%TYPE;
    --l_src_resource_list_id                     pa_resource_lists_all_bg.resource_list_id%TYPE;  //Commented out for Bug 4200168.
    --l_targ_resource_list_id                    pa_resource_lists_all_bg.resource_list_id%TYPE;  //Commented out for Bug 4200168.
    l_adj_percentage                           NUMBER;
    l_copy_mode                                VARCHAR2(1) := p_copy_mode;
    l_shift_days                               NUMBER :=0;--SHOULD BE REMOVED LATER
    l_targ_budget_version_id                   pa_budget_versions.budget_version_id%TYPE;
    l_src_proj_fp_options_id                   pa_proj_fp_options.proj_fp_options_id%TYPE;
    l_targ_proj_fp_options_id                  pa_proj_fp_options.proj_fp_options_id%TYPE;
    l_wp_plan_type_id                          pa_fin_plan_types_b.fin_plan_type_id%TYPE;
    l_targ_multi_curr_flag                     pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;
    l_pji_rollup_required                     VARCHAR(1);

  -- pjdvdsn1 compile issues, 03-FEB-2004, jwhite -------------------------

/*
    l_src_elem_version_id_tbl                  PA_PLSQL_DATATYPES.IdTabTyp;
    l_targ_elem_version_id_tbl                 PA_PLSQL_DATATYPES.IdTabTyp;
*/


    l_src_elem_version_id_tbl                  SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    l_targ_elem_version_id_tbl                 SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();

    -- ----------------------------------------------------------------------

    l_copy_external_flag                       VARCHAR2(1);

    --This table will be used in the PJI API call
    l_budget_version_ids                       SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    l_src_budget_version_id_tbl                SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();

    --Cursor for getting the source and target element version ids. This will be used in calling the
    --Copy Planning Txn API
    CURSOR l_prep_plan_txn_csr(c_source_plan_version_id pa_budget_versions.budget_version_id%TYPE
                               ,c_src_struct_ver_id pa_proj_element_versions.element_version_id%TYPE
                               ,c_targ_struct_ver_id pa_proj_element_versions.element_version_id%TYPE)
    IS
    SELECT selv.element_version_id
          ,telv.element_version_id
    FROM   pa_proj_element_versions telv
          ,pa_proj_element_versions selv
          ,pa_proj_elements spe
          ,pa_proj_elements tpe
    WHERE  spe.project_id=p_source_project_id
    AND    tpe.project_id=p_target_project_id
    AND    spe.element_number=tpe.element_number
    AND    tpe.object_type='PA_TASKS'
    AND    spe.object_type='PA_TASKS'
    AND    telv.proj_element_id = tpe.proj_element_id
    AND    selv.proj_element_id =spe.proj_element_id
    AND    selv.parent_structure_version_id=c_src_struct_ver_id
    AND    telv.parent_structure_version_id=c_targ_struct_ver_id
    AND     EXISTS  (SELECT task_id
                     FROM   pa_resource_assignments pra
                     WHERE  pra.budget_version_id=c_source_plan_version_id
                     AND    pra.task_id=spe.proj_element_id);

BEGIN
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT copy_wp_budget_versions;

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

    -- Set curr function

    IF l_debug_mode = 'Y' THEN
    pa_debug.set_curr_function(
                p_function   =>'pafpcpfb.copy_wp_budget_versions'
               ,p_debug_mode => l_debug_mode );

        pa_debug.g_err_stage:='Validating input parameters';
        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
    END IF;


    -- Source and target sv id tables should have same number of records
    -- Bug 3847386 if copy actuals from structure table is passed it
    -- should have same number of records as target sv ids table
    IF  (p_src_sv_ids_tbl.count<>p_target_sv_ids_tbl.count) OR
        (p_copy_act_from_str_ids_tbl IS NOT NULL
         AND p_src_sv_ids_tbl.count <> p_copy_act_from_str_ids_tbl.count)
    THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='p_src_sv_ids_tbl.count is'|| p_src_sv_ids_tbl.count ;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

            pa_debug.g_err_stage:='p_target_sv_ids_tbl.count is'|| p_target_sv_ids_tbl.count ;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

            IF p_copy_act_from_str_ids_tbl IS NOT NULL THEN
                pa_debug.g_err_stage:='p_copy_act_from_str_ids_tbl.count is'
                              || p_copy_act_from_str_ids_tbl.count ;
                pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;


    --If the tables are empty then return
    IF p_src_sv_ids_tbl.count=0 THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='The input tables are empty' ;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
            pa_debug.reset_curr_function;
        END IF;
        RETURN;

    END IF;


    --Source and target project ids should never be null
    IF p_source_project_id IS NULL OR
       p_target_project_id IS NULL THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='p_source_project_id is '||p_source_project_id;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

            pa_debug.g_err_stage:='p_target_project_id is '||p_target_project_id;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    --Derive the workplan fin plan type id
    pa_fp_planning_transaction_pub.add_wp_plan_type
         (p_src_project_id    =>  p_source_project_id
         ,p_targ_project_id   =>  p_target_project_id
         ,x_return_status     =>  x_return_status
         ,x_msg_count         =>  x_msg_count
         ,x_msg_data          =>  x_msg_data );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='pa_fp_planning_transaction_pub.add_wp_plan_type returned error';
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
        END IF;
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    BEGIN
        SELECT fin_plan_type_id
        INTO   l_wp_plan_type_id
        FROM   pa_fin_plan_types_b
        WHERE  use_for_workplan_flag='Y';
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Adding an error message as the wp plan type is not defined';
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_NO_WP_PLAN_TYPE');
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='About to loop thru the source version id tbl '||p_src_sv_ids_tbl.count;
        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
    END IF;

    --Loop thru the source structure version ids table and process each structure version id
    FOR i IN p_src_sv_ids_tbl.first..p_src_sv_ids_tbl.last LOOP


        --Assign null to the variables that will be used as the out parameters while calling various APIs(bug 3437643)
        l_targ_budget_version_id  :=NULL;
        l_targ_proj_fp_options_id :=NULL;

        l_src_budget_version_id  := PA_PLANNING_TRANSACTION_UTILS.Get_Wp_Budget_Version_Id(p_src_sv_ids_tbl(i));

        IF p_source_project_id <> p_target_project_id THEN

            --l_src_resource_list_id := pa_fin_plan_utils.get_resource_list_id(l_src_budget_version_id); //Commented out for bug 4200168.
            --l_targ_resource_list_id := l_src_resource_list_id;--RESOURCE FOUNDATION api TO GET THE TARGET RESOURCE LIST ID; //Commented out for bug 4200168.
            l_adj_percentage:= 0.9999;
        ELSE

            --l_src_resource_list_id := pa_fin_plan_utils.get_resource_list_id(l_src_budget_version_id); //Commented out for bug 4200168.
            --l_targ_resource_list_id := l_src_resource_list_id; //Commented out for bug 4200168.
            l_adj_percentage:= 0;
        END IF;

        --Bug 3841130. As told by sheenie copy external flag should always be N in copy_wp_budget_versions.
        l_copy_external_flag := 'N';

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Calling copy budget version';
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;

        --Call the method that copies the budget version
        pa_fp_copy_from_pkg.copy_budget_version
            ( p_source_project_id        =>     p_source_project_id
             ,p_target_project_id        =>     p_target_project_id
             ,p_source_version_id        =>     l_src_budget_version_id
             ,p_copy_mode                =>     'W'
             ,p_adj_percentage           =>     l_adj_percentage
             ,p_calling_module           =>     PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN
             ,p_shift_days               =>     l_shift_days
             ,px_target_version_id       =>     l_targ_budget_version_id
             ,p_struct_elem_version_id   =>     p_target_sv_ids_tbl(i)
             ,x_return_status            =>     x_return_status
             ,x_msg_count                =>     x_msg_count
             ,x_msg_data                 =>     x_msg_data);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Copy Budget version returned error';
                pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

        END IF;
        --Get the details required to call the Create FP Option API
        BEGIN

            SELECT proj_fp_options_id
            INTO   l_src_proj_fp_options_id
            FROM   pa_proj_fp_options
            WHERE  fin_plan_version_id=l_src_budget_version_id;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='No data found in pa_proj_fp_options for  fin_plan_version_id '
                                    ||l_src_budget_version_id;
                pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;
            RAISE;

        END;

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Create FP Option';
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;

        --Call the method to create the FP Option
        PA_PROJ_FP_OPTIONS_PUB.Create_Fp_Option
         (
           px_target_proj_fp_option_id      =>  l_targ_proj_fp_options_id
          ,p_source_proj_fp_option_id       =>  l_src_proj_fp_options_id
          ,p_target_fp_option_level_code    =>  PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION
          ,p_target_fp_preference_code      =>  PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY
          ,p_target_fin_plan_version_id     =>  l_targ_budget_version_id
          ,p_target_plan_type_id            =>  l_wp_plan_type_id
          ,p_target_project_id              =>  p_target_project_id
          ,x_return_status                  =>  x_return_status
          ,x_msg_count                      =>  x_msg_count
          ,x_msg_data                       =>  x_msg_data);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Create_Fp_Option returned error';
                pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

        END IF;

        --Derive the multi currency flag so as to call the copy planning txn currencies
        SELECT plan_in_multi_curr_flag
        INTO   l_targ_multi_curr_flag
        FROM   pa_proj_fp_options
        WHERE  proj_fp_options_id=l_targ_proj_fp_options_id;

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Calling copy fp txn currencies';
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;

        --Call the API to create the txn currencies
        PA_FP_TXN_CURRENCIES_PUB.Copy_Fp_Txn_Currencies(
              p_source_fp_option_id         =>  l_src_proj_fp_options_id
             ,p_target_fp_option_id         =>  l_targ_proj_fp_options_id
             ,p_target_fp_preference_code   =>  NULL
             ,p_plan_in_multi_curr_flag     =>  l_targ_multi_curr_flag
             ,x_return_status               =>  x_return_status
             ,x_msg_count                   =>  x_msg_count
             ,x_msg_data                    =>  x_msg_data);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Copy_Fp_Txn_Currencies returned error';
                pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

        END IF;

        --Call the PJI API to register the creation of plan version

        -- FP M - Reporting lines integration. The create API is being called even before calling the copy
        --planning txn as the copy planning txn will take care of later calling the PJI plan update API for
        --the new budget lines created
        l_budget_version_ids.delete;
        l_budget_version_ids   := SYSTEM.pa_num_tbl_type(l_targ_budget_version_id);

        l_src_budget_version_id_tbl.delete;
        l_src_budget_version_id_tbl   := SYSTEM.pa_num_tbl_type(l_src_budget_version_id);

        IF l_debug_mode = 'Y' THEN
            pa_debug.write(l_module_name,'Calling PJI_FM_XBS_ACCUM_MAINT.PLAN_CREATE ' ,5);
            pa_debug.write(l_module_name,'p_fp_version_ids count '|| l_budget_version_ids.count(),5);
        END IF;

        /* We are sure that there is only one record. But just looping the std way */
        FOR I in l_budget_version_ids.first..l_budget_version_ids.last LOOP
            pa_debug.write(l_module_name,''|| l_budget_version_ids(i),5);
        END LOOP;
         -- This parameter p_copy_mode will be used when the source project is not equal to the target project.
        --This will be passed as null in the MSP flow other wise it will be defaulted to 'P'.
        IF p_source_project_id <> p_target_project_id THEN
        PJI_FM_XBS_ACCUM_MAINT.PLAN_CREATE (
            p_fp_version_ids   => l_budget_version_ids,
            p_fp_src_version_ids => l_src_budget_version_id_tbl,
            p_copy_mode       => l_copy_mode,
            x_return_status    => l_return_status,
            x_msg_code         => l_msg_data);
        ELSE
        PJI_FM_XBS_ACCUM_MAINT.PLAN_CREATE (
            p_fp_version_ids   => l_budget_version_ids,
            x_return_status    => l_return_status,
            x_msg_code         => l_msg_data);
        END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
            PA_UTILS.ADD_MESSAGE(p_app_short_name      => PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_PA,
                               p_msg_name            => l_msg_data);
            RAISE  PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;



        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Bulk fetching the Ids for calling copy planning txn'||' '||p_src_sv_ids_tbl(i)||' '||p_target_sv_ids_tbl(i);
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;

        OPEN l_prep_plan_txn_csr( l_src_budget_version_id
                                 ,p_src_sv_ids_tbl(i)
                                 ,p_target_sv_ids_tbl(i));
        FETCH l_prep_plan_txn_csr
        BULK COLLECT INTO
        l_src_elem_version_id_tbl
       ,l_targ_elem_version_id_tbl;
        CLOSE l_prep_plan_txn_csr;

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Calling copy planning txns after uncommenting';
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;



        --Calling the  copy planning txn API
        pa_fp_planning_transaction_pub.copy_planning_transactions(
              p_context                 =>  PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN
             ,p_copy_external_flag      =>  l_copy_external_flag
             ,p_src_project_id          =>  p_source_project_id
             ,p_target_project_id       =>  p_target_project_id
             ,p_src_budget_version_id   =>  l_src_budget_version_id
             ,p_targ_budget_version_id  =>  l_targ_budget_version_id
             ,p_src_version_id_tbl      =>  l_src_elem_version_id_tbl
             ,p_targ_version_id_tbl     =>  l_targ_elem_version_id_tbl
             ,p_copy_people_flag        =>  p_copy_people_flag
             ,p_copy_equip_flag         =>  p_copy_equip_flag
             ,p_copy_mat_item_flag      =>  p_copy_mat_item_flag
             ,p_copy_fin_elem_flag      =>  p_copy_fin_elem_flag
             ,p_pji_rollup_required     =>  'N'
             ,x_return_status           =>  x_return_status
             ,x_msg_count               =>  x_msg_count
             ,x_msg_data                =>  x_msg_data);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Copy_Fp_Txn_Currencies returned error';
                pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

        END IF;

        -- Bug 3619687
        -- When this api is called to create a working workplan structure version from
        -- a published version, all the data in 'Additional Workplan settings' pages
        -- should be synchronised with workplan plan type data

        PA_FP_COPY_FROM_PKG.Update_Plan_Setup_For_WP_Copy(
                 p_project_id            =>  p_target_project_id
                 ,p_wp_version_id        =>  l_targ_budget_version_id
                 ,x_return_status        =>  x_return_status
                 ,x_msg_count            =>  x_msg_count
                 ,x_msg_data             =>  x_msg_data);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Update_Plan_Setup_For_WP_Copy returned error';
                pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        -- If copy actuals from structure id is passed progress actuals should be copied
        -- for the target version
        IF p_copy_act_from_str_ids_tbl IS NOT NULL AND
           p_copy_act_from_str_ids_tbl.EXISTS(i)  AND
           p_copy_act_from_str_ids_tbl(i) IS NOT NULL AND
           p_source_project_id = p_target_project_id
        THEN
            -- Added for bug 3850488.
            -- Copy the missing unplanned assignments.
            BEGIN
                      PA_TASK_ASSIGNMENTS_PVT.Copy_Missing_Unplanned_Asgmts(
                         p_project_id               => p_target_project_id
                        ,p_old_structure_version_id => p_copy_act_from_str_ids_tbl(i)
                        ,p_new_structure_version_id => p_target_sv_ids_tbl(i)
                        ,x_msg_count                => x_msg_count
                        ,x_msg_data                 => x_msg_data
                        ,x_return_status            => x_return_status
                      );
            EXCEPTION
                  WHEN OTHERS THEN
                  IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:='PA_TASK_ASSIGNMENTS_PVT.Copy_Missing_Unplanned_Asgmts returned error';
                      pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
            END;
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;
            -- End bug 3850488.

            -- Call copy_actuals_for_workplan
            PA_PROGRESS_PVT.copy_actuals_for_workplan(
                p_project_id              =>  p_target_project_id
               ,p_source_struct_ver_id    =>  p_copy_act_from_str_ids_tbl(i)
               ,p_target_struct_ver_id    =>  p_target_sv_ids_tbl(i)
               ,x_return_status           =>  x_return_status
               ,x_msg_count               =>  x_msg_count
               ,x_msg_data                =>  x_msg_data);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Update_Plan_Setup_For_WP_Copy returned error';
                    pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
        END IF;

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


    END LOOP;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Exiting copy_wp_budget_versions';
        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
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
       ROLLBACK TO copy_wp_budget_versions;
       x_return_status := FND_API.G_RET_STS_ERROR;

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Invalid Arguments Passed Or called api raised an error';
           pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
       -- reset curr function
          pa_debug.reset_curr_function();
       END IF;
       RETURN;
   WHEN OTHERS THEN
       ROLLBACK TO copy_wp_budget_versions;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'pa_fp_copy_from_pkg'
                               ,p_procedure_name  => 'copy_wp_budget_versions');

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
       -- reset curr function
          pa_debug.Reset_Curr_Function();
       END IF;
       RAISE;

END copy_wp_budget_versions;

  /*=========================================================================
      3156057: FP.M changes:
      If source plan is mc enabled but not appr rev and the target is appr rev,
      then this api will be called to group the source budget lines by PFC for creating target budget lines
      Logic:
      1) Get all the distinct resource_assignment_id and start_date combination for the source plan version id
      2) Fetch all the source budget lines for the given resource_assignment_id and start_date combination, ordering
          by transaction currency code (filtering out the records which have some rejection code populated,
          and sum up the amounts and quantities.
      3) For the DFF attributes, change reason and description, copy the attributes if any of the source lines for the
          given resource_assignment_id and start_date combination has the transaction currency same as the project
          functional currency. If not, then copy the attributes from the first listed source line,
          ordering by transaction currency.
      4) This api is dependant on PA_FP_RA_MAP_TMP being populated before it is called and it populates
           PA_FP_BL_MAP_TMP on which the api COPY_MC_BUDGET_LINES_APPR_REV would be dependant.
   =========================================================================*/

  --Bug 4290043. Added p_derv_rates_missing_amts_flag to indicate whether the missing amounts in the target version
  --should be derived or not after copy
   /* Bug 4865563 IPM Arch Enhancement. Display_quantity is being set in copy_version and copy_finplans_from_project apis using
        populate_display_qty api. */

  PROCEDURE Copy_Budget_Lines_Appr_Rev(
             p_source_plan_version_id        IN  NUMBER
             ,p_target_plan_version_id       IN  NUMBER
             ,p_adj_percentage               IN  NUMBER
             ,p_derv_rates_missing_amts_flag IN  VARCHAR2
             ,x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_msg_count                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
             ,x_msg_data                     OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
   AS

         l_msg_count          NUMBER :=0;
         l_data               VARCHAR2(2000);
         l_msg_data           VARCHAR2(2000);
         l_error_msg_code     VARCHAR2(2000);
         l_msg_index_out      NUMBER;
         l_return_status      VARCHAR2(2000);
         l_debug_mode         VARCHAR2(30);

         l_revenue_flag       pa_fin_plan_amount_sets.revenue_flag%type;
         l_cost_flag          pa_fin_plan_amount_sets.raw_cost_flag%type;
         l_rate_based_flag    pa_resource_assignments.rate_based_flag%type;


         l_adj_percentage            NUMBER ;

         l_quantity_tot  NUMBER;
         l_raw_cost_tot NUMBER;
         l_burdened_cost_tot NUMBER;
         l_revenue_tot NUMBER;
         l_project_raw_cost_tot NUMBER;
         l_project_burdened_cost_tot NUMBER;
         l_project_revenue_tot NUMBER;
         l_ref NUMBER ;
         l_target_budget_line_id NUMBER;
         l_project_cost_exchange_rate NUMBER;
         l_proj_rev_ex_rate NUMBER;
         l_txn_cost_rate_override NUMBER;
         l_txn_bill_rate_override NUMBER;
         l_burden_cost_rate_override NUMBER;

         /* Initialized plsql tables for bug 3709036 */

         l_budget_line_idTab                 SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE() ;
         l_quantityTab                          SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE() ;
         l_raw_costTab                           SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE() ;
         l_burdened_costTab                 SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE() ;
         l_revenueTab                           SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE() ;
         l_change_reason_codeTab       SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
         l_descriptionTab                      SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
         l_attribute_categoryTab            SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
         l_attribute1Tab                        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
         l_attribute2Tab                        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
         l_attribute3Tab                        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
         l_attribute4Tab                        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
         l_attribute5Tab                        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
         l_attribute6Tab                        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
         l_attribute7Tab                        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
         l_attribute8Tab                        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
         l_attribute9Tab                        SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
         l_attribute10Tab                      SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
         l_attribute11Tab                      SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
         l_attribute12Tab                      SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
         l_attribute13Tab                      SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
         l_attribute14Tab                      SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
         l_attribute15Tab                      SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
         l_project_raw_costTab             SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
         l_project_burdened_costTab         SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
         l_project_revenueTab               SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
         l_txn_currency_codeTab          SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
         l_projfunc_currency_codeTab   SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
         l_project_currency_codeTab     SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
         l_end_dateTab                        SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE ();
         l_period_nameTab                   SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();

         CURSOR Cur_group_source_budget_lines IS
         SELECT distinct pbl.resource_assignment_id resource_assignment_id, pbl.start_date start_date,pra.rate_based_flag
         FROM pa_budget_lines pbl, pa_resource_assignments pra
         WHERE pbl.budget_version_id = p_source_plan_version_id
         AND pra.resource_assignment_id = pbl.resource_assignment_id;

         CURSOR Cur_source_budget_lines(p_resource_assignment_id IN NUMBER, p_start_date IN DATE
         ,p_rate_based_flag IN VARCHAR2 , p_cost_flag IN VARCHAR2 , p_revenue_flag IN VARCHAR2) IS
         SELECT
                budget_line_id
               ,nvl(DECODE(p_rate_based_flag,'N',DECODE(p_cost_flag,'Y',nvl(raw_cost,0),nvl(revenue,0)),quantity),0) quantity
               ,nvl(raw_cost,0)
               ,nvl(burdened_cost,0)
               ,nvl(revenue,0)
               ,change_reason_code
               ,description
               ,attribute_category
               ,attribute1
               ,attribute2
               ,attribute3
               ,attribute4
               ,attribute5
               ,attribute6
               ,attribute7
               ,attribute8
               ,attribute9
               ,attribute10
               ,attribute11
               ,attribute12
               ,attribute13
               ,attribute14
               ,attribute15
               ,nvl(project_raw_cost,0)
               ,nvl(project_burdened_cost,0)
               ,nvl(project_revenue,0)
               ,txn_currency_code
               ,projfunc_currency_code
               ,project_currency_code
               ,end_date
               ,period_name
         FROM pa_budget_lines
         WHERE resource_assignment_id = p_resource_assignment_id
         AND start_date = p_start_date
         AND cost_rejection_code is null
         AND burden_rejection_code is null
         AND revenue_rejection_code is null
         AND other_rejection_code is null
         AND pc_cur_conv_rejection_code is null
         AND pfc_cur_conv_rejection_code is null
         ORDER BY txn_currency_code;

  /* PROCEDURE InitPLSQLTab IS
  BEGIN
                l_budget_line_idTab.delete;
                l_quantityTab.delete;
                l_raw_costTab.delete;
                l_burdened_costTab.delete;
                l_revenueTab.delete;
                l_change_reason_codeTab.delete;
                l_descriptionTab.delete;
                l_attribute_categoryTab.delete;
                l_attribute1Tab.delete;
                l_attribute2Tab.delete;
                l_attribute3Tab.delete;
                l_attribute4Tab.delete;
                l_attribute5Tab.delete;
                l_attribute6Tab.delete;
                l_attribute7Tab.delete;
                l_attribute8Tab.delete;
                l_attribute9Tab.delete;
                l_attribute10Tab.delete;
                l_attribute11Tab.delete;
                l_attribute12Tab.delete;
                l_attribute13Tab.delete;
                l_attribute14Tab.delete;
                l_attribute15Tab.delete;
                l_project_raw_costTab.delete;
                l_project_burdened_costTab.delete;
                l_project_revenueTab.delete;
                l_txn_currency_codeTab.delete;
                l_projfunc_currency_codeTab.delete;
                l_project_currency_codeTab.delete;
                l_end_dateTab.delete;
                l_period_nameTab.delete;

  END InitPLSQLTab;  ** bug 3709036 */

  l_etc_start_date  pa_budget_versions.etc_start_date%TYPE;

  --Bug 4290043.
  l_targ_pref_code         pa_proj_fp_options.fin_plan_preference_code%TYPE;
  l_source_version_type    pa_budget_versions.version_type%TYPE;
  l_target_version_type    pa_budget_versions.version_type%TYPE;
  l_src_plan_class_code    pa_fin_plan_types_b.plan_class_code%TYPE;

    BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.set_err_stack('PA_FP_COPY_FROM_PKG.Copy_Budget_Lines_Appr_Rev');
END IF;
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.set_process('PLSQL','LOG',l_debug_mode);
END IF;
      -- Checking for all valid input parametrs

      IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage := 'Checking for valid parameters:';
          pa_debug.write('Copy_Budget_Lines_Appr_Rev: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;

      IF (p_source_plan_version_id IS NULL) OR
         (p_target_plan_version_id IS NULL)
      THEN

           IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage := 'Source_plan='||p_source_plan_version_id;
               pa_debug.write('Copy_Budget_Lines_Appr_Rev: ' || g_module_name,pa_debug.g_err_stage,5);
               pa_debug.g_err_stage := 'Target_plan'||p_target_plan_version_id;
               pa_debug.write('Copy_Budget_Lines_Appr_Rev: ' || g_module_name,pa_debug.g_err_stage,5);
           END IF;

           PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                                p_msg_name      => 'PA_FP_INV_PARAM_PASSED',
                                p_token1=>'PROCEDURENAME',
                                p_value1=>'COPY_BUDGET_LINES_APPR_REV');

           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage := 'Parameter validation complete';
          pa_debug.write('Copy_Budget_Lines_Appr_Rev: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;

      --make adj percentage zero if passed as null

      l_adj_percentage := NVL(p_adj_percentage,0);

       -- Fetching the flags of target version using fin_plan_prefernce_code


       IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Fetching the raw_cost,burdened_cost and revenue flags of target_version';
           pa_debug.write('Copy_Budget_Lines_Appr_Rev: ' || g_module_name,pa_debug.g_err_stage,3);
       END IF;

       SELECT DECODE(fin_plan_preference_code          -- l_revenue_flag
                       ,PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY ,'Y'
                       ,PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME ,'Y','N')
              ,DECODE(fin_plan_preference_code          -- l_cost_flag
                      ,PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME , 'Y','N')
              ,fin_plan_preference_code
       INTO   l_revenue_flag
              ,l_cost_flag
              ,l_targ_pref_code
       FROM   pa_proj_fp_options
       WHERE  fin_plan_version_id=p_target_plan_version_id;

       --Bug 3927244
       --Bug 4290043. Selected version type too
       SELECT etc_start_date,
              version_type
       INTO   l_etc_start_date,
              l_target_version_type
       FROM   pa_budget_versions
       WHERE  budget_version_id=p_target_plan_version_id;
       --Bug 3927244

       --Bug 4290043.
       SELECT pbv.version_type,
              fin.plan_class_code
       INTO   l_source_version_type,
              l_src_plan_class_code
       FROM   pa_budget_versions pbv,
              pa_fin_plan_types_b fin
       WHERE  pbv.fin_plan_type_id=fin.fin_plan_type_id
       AND    pbv.budget_version_id = p_source_plan_version_id;

       DELETE FROM  PA_FP_BL_MAP_TMP;

       FOR rec_group_source_budget_lines IN cur_group_source_budget_lines LOOP

       -- InitPLSQLTab;  ** bug 3709036

         l_ref := 1;
         l_quantity_tot := 0;
         l_raw_cost_tot := 0;
         l_burdened_cost_tot := 0;
         l_revenue_tot := 0;
         l_project_raw_cost_tot := 0;
         l_project_burdened_cost_tot := 0;
         l_project_revenue_tot := 0;
         l_rate_based_flag := rec_group_source_budget_lines.rate_based_flag;

       SELECT pa_budget_lines_s.nextval
       INTO l_target_budget_line_id
       FROM dual;

       Open Cur_source_budget_lines(rec_group_source_budget_lines.resource_assignment_id,
                                                     rec_group_source_budget_lines.start_date,
                                                     l_rate_based_flag,
                                                     l_cost_flag,
                                                     l_revenue_flag);

       Fetch Cur_source_budget_lines bulk collect into
                l_budget_line_idTab
               ,l_quantityTab
               ,l_raw_costTab
               ,l_burdened_costTab
               ,l_revenueTab
               ,l_change_reason_codeTab
               ,l_descriptionTab
               ,l_attribute_categoryTab
               ,l_attribute1Tab
               ,l_attribute2Tab
               ,l_attribute3Tab
               ,l_attribute4Tab
               ,l_attribute5Tab
               ,l_attribute6Tab
               ,l_attribute7Tab
               ,l_attribute8Tab
               ,l_attribute9Tab
               ,l_attribute10Tab
               ,l_attribute11Tab
               ,l_attribute12Tab
               ,l_attribute13Tab
               ,l_attribute14Tab
               ,l_attribute15Tab
               ,l_project_raw_costTab
               ,l_project_burdened_costTab
               ,l_project_revenueTab
               ,l_txn_currency_codeTab
               ,l_projfunc_currency_codeTab
               ,l_project_currency_codeTab
               ,l_end_dateTab
               ,l_period_nameTab;

         Close Cur_source_budget_lines; -- bug 3709036

       IF l_budget_line_idTab.count > 0  THEN   -- bug 3709036

        FOR J in 1..l_budget_line_idTab.count LOOP  ---{

               l_quantity_tot := l_quantity_tot + l_quantityTab(j);
               l_raw_cost_tot := l_raw_cost_tot + l_raw_costTab(j);
               l_burdened_cost_tot := l_burdened_cost_tot + l_burdened_costTab(j);
               l_revenue_tot := l_revenue_tot + l_revenueTab(j);
               l_project_raw_cost_tot := l_project_raw_cost_tot + l_project_raw_costTab(j);
               l_project_burdened_cost_tot := l_project_burdened_cost_tot + l_project_burdened_costTab(j);
               l_project_revenue_tot := l_project_revenue_tot + l_project_revenueTab(j);

        IF (l_txn_currency_codeTab(j) = l_projfunc_currency_codeTab(j)
        and ( l_change_reason_codeTab(j) IS NOT NULL
               OR l_descriptionTab(j) IS NOT NULL
               OR l_attribute_categoryTab(j) IS NOT NULL
               OR l_attribute1Tab(j) IS NOT NULL
               OR l_attribute2Tab(j) IS NOT NULL
               OR l_attribute3Tab(j) IS NOT NULL
               OR l_attribute4Tab(j) IS NOT NULL
               OR l_attribute5Tab(j) IS NOT NULL
               OR l_attribute6Tab(j) IS NOT NULL
               OR l_attribute7Tab(j) IS NOT NULL
               OR l_attribute8Tab(j) IS NOT NULL
               OR l_attribute9Tab(j) IS NOT NULL
               OR l_attribute10Tab(j) IS NOT NULL
               OR l_attribute11Tab(j) IS NOT NULL
               OR l_attribute12Tab(j) IS NOT NULL
               OR l_attribute13Tab(j) IS NOT NULL
               OR l_attribute14Tab(j) IS NOT NULL
               OR l_attribute15Tab(j) IS NOT NULL )) THEN

        l_ref := j;

        END IF;

        INSERT INTO PA_FP_BL_MAP_TMP
                          ( source_budget_line_id
                           ,target_budget_line_id
                           )
                  VALUES (l_budget_line_idTab(j),
                                 l_target_budget_line_id
                                 );

        END LOOP;   ---}

                 IF l_raw_cost_tot = 0 THEN
                     l_project_cost_exchange_rate :=  1;
                 ELSE
                     l_project_cost_exchange_rate :=  l_project_raw_cost_tot/l_raw_cost_tot;
                 END IF;

                 IF l_revenue_tot = 0 THEN
                     l_proj_rev_ex_rate :=  1;
                 ELSE
                      l_proj_rev_ex_rate :=  l_project_revenue_tot/l_revenue_tot;
                 END IF;

                 IF l_quantity_tot = 0 THEN
                     l_txn_cost_rate_override :=  null;
                     l_txn_bill_rate_override :=  null;
                     l_burden_cost_rate_override := null;
                 ELSE
                     l_txn_cost_rate_override :=  l_raw_cost_tot/l_quantity_tot;
                     l_txn_bill_rate_override :=  l_revenue_tot/l_quantity_tot;
                     l_burden_cost_rate_override := l_burdened_cost_tot/l_quantity_tot;
                 END IF;

       INSERT INTO PA_BUDGET_LINES(
                budget_line_id
               ,budget_version_id
               ,resource_assignment_id
               ,start_date
               ,last_update_date
               ,last_updated_by
               ,creation_date
               ,created_by
               ,last_update_login
               ,end_date
               ,period_name
               ,quantity
               ,raw_cost
               ,burdened_cost
               ,revenue
               ,change_reason_code
               ,description
               ,attribute_category
               ,attribute1
               ,attribute2
               ,attribute3
               ,attribute4
               ,attribute5
               ,attribute6
               ,attribute7
               ,attribute8
               ,attribute9
               ,attribute10
               ,attribute11
               ,attribute12
               ,attribute13
               ,attribute14
               ,attribute15
               ,raw_cost_source
               ,burdened_cost_source
               ,quantity_source
               ,revenue_source
               ,pm_product_code
               ,pm_budget_line_reference
               ,cost_rejection_code
               ,revenue_rejection_code
               ,burden_rejection_code
               ,other_rejection_code
               ,code_combination_id
               ,ccid_gen_status_code
               ,ccid_gen_rej_message
               ,request_id
               ,borrowed_revenue
               ,tp_revenue_in
               ,tp_revenue_out
               ,revenue_adj
               ,lent_resource_cost
               ,tp_cost_in
               ,tp_cost_out
               ,cost_adj
               ,unassigned_time_cost
               ,utilization_percent
               ,utilization_hours
               ,utilization_adj
               ,capacity
               ,head_count
               ,head_count_adj
               ,projfunc_currency_code
               ,projfunc_cost_rate_type
               ,projfunc_cost_exchange_rate
               ,projfunc_cost_rate_date_type
               ,projfunc_cost_rate_date
               ,projfunc_rev_rate_type
               ,projfunc_rev_exchange_rate
               ,projfunc_rev_rate_date_type
               ,projfunc_rev_rate_date
               ,project_currency_code
               ,project_cost_rate_type
               ,project_cost_exchange_rate
               ,project_cost_rate_date_type
               ,project_cost_rate_date
               ,project_raw_cost
               ,project_burdened_cost
               ,project_rev_rate_type
               ,project_rev_exchange_rate
               ,project_rev_rate_date_type
               ,project_rev_rate_date
               ,project_revenue
               ,txn_raw_cost
               ,txn_burdened_cost
               ,txn_currency_code
               ,txn_revenue
               ,bucketing_period_code
               ,transfer_price_rate
               ,init_quantity
               ,init_quantity_source
               ,init_raw_cost
               ,init_burdened_cost
               ,init_revenue
               ,init_raw_cost_source
               ,init_burdened_cost_source
               ,init_revenue_source
               ,project_init_raw_cost
               ,project_init_burdened_cost
               ,project_init_revenue
               ,txn_init_raw_cost
               ,txn_init_burdened_cost
               ,txn_init_revenue
               ,txn_markup_percent
               ,txn_markup_percent_override
               ,txn_discount_percentage
               ,txn_standard_bill_rate
               ,txn_standard_cost_rate
               ,txn_cost_rate_override
               ,burden_cost_rate
               ,txn_bill_rate_override
               ,burden_cost_rate_override
               ,cost_ind_compiled_set_id
               ,pc_cur_conv_rejection_code
               ,pfc_cur_conv_rejection_code
)
     SELECT     l_target_budget_line_id
               ,p_target_plan_version_id
               ,pra.resource_assignment_id
               ,rec_group_source_budget_lines.start_date
               ,sysdate -- last_update_date
               ,fnd_global.user_id -- last_updated_by
               ,sysdate  -- creation_date
               ,fnd_global.user_id -- created_by
               ,fnd_global.login_id -- last_update_login
               ,l_end_dateTab(l_ref)
               ,l_period_nameTab(l_ref)
               ,l_quantity_tot
               ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y', l_raw_cost_tot,NULL),NULL) -- raw_cost
               ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y', l_burdened_cost_tot,NULL),NULL) -- burdened_cost
               ,DECODE(l_adj_percentage,0,DECODE(l_revenue_flag,'Y', l_revenue_tot,NULL),NULL) -- revenue
               ,l_change_reason_codeTab(l_ref) -- change_reason_code
               ,l_descriptionTab(l_ref)-- description
               ,l_attribute_categoryTab(l_ref)
               ,l_attribute1Tab(l_ref)
               ,l_attribute2Tab(l_ref)
               ,l_attribute3Tab(l_ref)
               ,l_attribute4Tab(l_ref)
               ,l_attribute5Tab(l_ref)
               ,l_attribute6Tab(l_ref)
               ,l_attribute7Tab(l_ref)
               ,l_attribute8Tab(l_ref)
               ,l_attribute9Tab(l_ref)
               ,l_attribute10Tab(l_ref)
               ,l_attribute11Tab(l_ref)
               ,l_attribute12Tab(l_ref)
               ,l_attribute13Tab(l_ref)
               ,l_attribute14Tab(l_ref)
               ,l_attribute15Tab(l_ref)
               ,DECODE(l_cost_flag,'Y',PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_COPY_P,NULL) --raw_cost_souce
               ,DECODE(l_cost_flag,'Y',PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_COPY_P,NULL) --burdened_cost_source
               ,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_COPY_P  --quantity_source
               ,DECODE(l_revenue_flag,'Y',PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_COPY_P,NULL) --revenue source
               ,null -- pm_product_code
               ,null
               ,null
               ,null
               ,null
               ,null
               ,null
               ,null
               ,null
               ,null
               ,null
               ,null
               ,null
               ,null
               ,null
               ,null
               ,null
               ,null
               ,null
               ,null
               ,null
               ,null
               ,null
               ,null
               ,null  -- head_count_adj
               ,l_projfunc_currency_codeTab(l_ref)
               ,DECODE(l_cost_flag,'Y','User',NULL) -- projfunc_cost_rate_type
               ,DECODE(l_cost_flag,'Y',1,NULL) -- projfunc_cost_exchange_rate
               ,null -- projfunc_cost_rate_date_type
               ,null -- projfunc_cost_rate_date
               ,'User' -- projfunc_rev_rate_type
               ,1 -- projfunc_rev_exchange_rate
               ,null -- projfunc_rev_rate_date_type
               ,null -- projfunc_rev_rate_date
               ,l_project_currency_codeTab(l_ref)
               ,DECODE(l_cost_flag,'Y','User',NULL) -- project_cost_rate_type
               ,DECODE(l_cost_flag,'Y',l_project_cost_exchange_rate,NULL) -- project_cost_exchange_rate
               ,null -- project_cost_rate_date_type
               ,null  -- project_cost_rate_date
               ,DECODE(l_adj_percentage,0,
                                DECODE(l_cost_flag,'Y', l_project_raw_cost_tot,NULL),NULL) --project_raw_cost
               ,DECODE(l_adj_percentage,0,
                              DECODE(l_cost_flag,'Y', l_project_burdened_cost_tot,NULL),NULL) -- project_burdened_cost
               ,'User' -- project_rev_rate_type
               ,l_proj_rev_ex_rate -- project_rev_exchange_rate
               ,null -- project_rev_rate_date_type
               ,null -- project_rev_rate_date
               ,DECODE(l_adj_percentage,0,
                               DECODE(l_revenue_flag,'Y', l_project_revenue_tot,NULL),NULL) -- project_revenue
               ,DECODE(l_cost_flag,'Y',
                        decode(GREATEST(rec_group_source_budget_lines.start_date,NVL(l_etc_start_date,rec_group_source_budget_lines.start_date)),rec_group_source_budget_lines.start_date
                        ,l_raw_cost_tot*(1+l_adj_percentage),l_raw_cost_tot),NULL) -- txn_raw_cost
               ,DECODE(l_cost_flag,'Y',
                        decode(GREATEST(rec_group_source_budget_lines.start_date,NVL(l_etc_start_date,rec_group_source_budget_lines.start_date)),rec_group_source_budget_lines.start_date
                        ,l_burdened_cost_tot*(1+l_adj_percentage),l_burdened_cost_tot),NULL) -- txn_burdened_cost
               ,l_projfunc_currency_codeTab(l_ref) -- txn_currency_code
               ,DECODE(l_revenue_flag,'Y',
                        decode(GREATEST(rec_group_source_budget_lines.start_date,NVL(l_etc_start_date,rec_group_source_budget_lines.start_date)),rec_group_source_budget_lines.start_date
                        ,l_revenue_tot*(1+l_adj_percentage),l_revenue_tot),NULL) -- txn_revenue
               ,null -- bucketing_period_code
               ,null -- transfer_price_rate
               ,NULL --init_quantity
               ,NULL --init_quantity_source
               ,NULL --init_raw_cost
               ,NULL --init_burdened_cost
               ,NULL --init_revenue
               ,NULL --init_raw_cost_source
               ,NULL --init_burdened_cost_source
               ,NULL --init_revenue_source
               ,NULL --project_init_raw_cost
               ,NULL --project_init_burdened_cost
               ,NULL --project_init_revenue
               ,NULL --txn_init_raw_cost
               ,NULL --txn_init_burdened_cost
               ,NULL --txn_init_revenue
               ,null  -- txn_markup_percent
               ,null -- txn_markup_percent_override
               ,null -- txn_discount_percentage
               ,null -- txn_standard_bill_rate
               ,null -- txn_standard_cost_rate
               ,DECODE(l_cost_flag,'Y',DECODE(p_derv_rates_missing_amts_flag,'N',l_txn_cost_rate_override,NULL),NULL) -- txn_cost_rate_override
               ,null -- burden_cost_rate
               ,DECODE(l_revenue_flag,'Y',DECODE(p_derv_rates_missing_amts_flag,'N',l_txn_bill_rate_override,NULL),NULL) -- txn_bill_rate_override
               ,DECODE(l_cost_flag,'Y',DECODE(p_derv_rates_missing_amts_flag,'N',l_burden_cost_rate_override,NULL),NULL) -- burden_cost_rate_override
               ,null -- cost_ind_compiled_set_id
               ,null -- pc_cur_conv_rejection_code
               ,null -- pfc_cur_conv_rejection_code
       FROM pa_resource_assignments pra
       WHERE rec_group_source_budget_lines.resource_assignment_id = pra.parent_assignment_id
       AND   pra.budget_version_id=p_target_plan_version_id;

       END IF; -- l_budget_line_idTab.count

       END LOOP;

       -- Bug 4035856 Call rounding api if l_adj_percentage is not zero
       IF l_adj_percentage <> 0 THEN
            PA_FP_MULTI_CURRENCY_PKG.Round_Budget_Line_Amounts
                   (  p_budget_version_id     => p_target_plan_version_id
                     ,p_calling_context       => 'COPY_VERSION'
                     ,x_return_status         => l_return_status
                     ,x_msg_count             => l_msg_count
                     ,x_msg_data              => l_msg_data);

             IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                 IF P_PA_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:= 'Error in PA_FP_MULTI_CURRENCY_PKG.Round_Budget_Line_Amounts';
                      pa_debug.write('Copy_Budget_Lines_Appr_Rev: ' || g_module_name,pa_debug.g_err_stage,5);
                 END IF;
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
             END IF;
       END IF;

       --Bug 4290043. Call the API to correct the missing amounts in the target version in case it can have
       --missing amounts/rates
       IF p_derv_rates_missing_amts_flag = 'Y' OR
          l_adj_percentage <> 0 THEN


            derv_missing_amts_chk_neg_qty
            (p_budget_version_id            => p_target_plan_version_id,
             p_targ_pref_code               => l_targ_pref_code,
             p_source_version_type          => l_source_version_type,
             p_target_version_type          => l_target_version_type,
             p_src_plan_class_code          => l_src_plan_class_code,
             p_derv_rates_missing_amts_flag => p_derv_rates_missing_amts_flag,
             p_adj_percentage               => l_adj_percentage,
             x_return_status                => l_return_status,
             x_msg_count                    => l_msg_count,
             x_msg_data                     => l_msg_data);

             IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                 IF P_PA_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:= 'Error in derv_missing_amts_chk_neg_qty';
                      pa_debug.write('Copy_Budget_Lines_Appr_Rev: ' || g_module_name,pa_debug.g_err_stage,5);
                 END IF;
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;

       END IF;--IF p_derv_rates_missing_amts_flag = 'Y' THEN

       IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Exiting Copy_Budget_Lines_Appr_Rev';
           pa_debug.write('Copy_Budget_Lines_Appr_Rev: ' || g_module_name,pa_debug.g_err_stage,3);
           pa_debug.reset_err_stack;    -- bug:- 2815593
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
               pa_debug.g_err_stage:='Invalid arguments passed';
               pa_debug.write('Copy_Budget_Lines_Appr_Rev: ' || g_module_name,pa_debug.g_err_stage,5);
               pa_debug.reset_err_stack;
	  END IF;
           RAISE;

    WHEN Others THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_FP_COPY_FROM_PKG'
                            ,p_procedure_name  => 'COPY_BUDGET_LINES_APPR_REV');

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:='Unexpected error'||SQLERRM;
            pa_debug.write('Copy_Budget_Lines_Appr_Rev: ' || g_module_name,pa_debug.g_err_stage,6);
             pa_debug.reset_err_stack;
	END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END Copy_Budget_Lines_Appr_Rev;

/*=============================================================================
 Bug 3619687: PJ.M:B5:BF:DEV:TRACKING BUG FOR PLAN SETTINGS CHANGE REQUEST
 When a new workplan structure version is created from a published version, this
 api is called to synchronise all the additional workplan settings related data.
 This api is called from copy_wp_budget_versions api at the end of copying all
 the budgets related data from source published version.
 Synchronisation involves:
  1) pa_fp_txn_currencies
  2) rate schedules, generation options and plan settings data
     (pa_proj_fp_options)

 Stating some of the business rules for clarity:
      i) If there is a published version, time phasing can not be changed
     ii) Planning resource list can change only if existing resource list is
         'None'. To handle this case, we would re-map the resource assignments
         data. Please note that in this case, only 'PEOPLE' resource class assignments
         would be present.
    iii) RBS can be different only if existing RBS is null.

 Bug 3725414: In update to pa_proj_fp_options, rbs_version_id column is missing

 Bug 4101153: Current Planning period should always get the value from the source version and
 not from the workplan plan type option. Removed the update to current planning period

 Bug 4337221: dbora- Excluded the quantity and cost amount columns from the update
 statement on pa_budget_versions, so that the quantity and cost amount columns gets
 copied as it is from the source version retaining the version level rolled up figures.
==============================================================================*/

PROCEDURE Update_Plan_Setup_For_WP_Copy(
           p_project_id           IN   pa_projects_all.project_id%TYPE
          ,p_wp_version_id        IN   pa_budget_versions.fin_plan_type_id%TYPE
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

    l_resource_list_change_flag  VARCHAR2(1);
    l_rbs_version_change_flag    VARCHAR2(1);
    l_people_res_class_rlm_id    pa_resource_list_members.resource_list_member_id%TYPE;
    l_equip_res_class_rlm_id     pa_resource_list_members.resource_list_member_id%TYPE;
    l_fin_res_class_rlm_id       pa_resource_list_members.resource_list_member_id%TYPE;
    l_mat_res_class_rlm_id       pa_resource_list_members.resource_list_member_id%TYPE;

    l_txn_source_id_tbl          SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    l_res_list_member_id_tbl     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    l_rbs_element_id_tbl         SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    l_txn_accum_header_id_tbl    SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

    l_budget_version_id_tbl      SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

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

    CURSOR wp_version_options_cur IS
      SELECT pfo.proj_fp_options_id
             ,pfo.rbs_version_id
             ,pfo.cost_resource_list_id
      FROM   pa_proj_fp_options  pfo
             ,pa_budget_versions bv
      WHERE  bv.budget_version_id =  p_wp_version_id
      AND    bv.project_id = pfo.project_id
      AND    pfo.fin_plan_version_id = bv.budget_version_id;

    wp_version_options_rec  wp_version_options_cur%ROWTYPE;


BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

    -- Set curr function
   IF l_debug_mode = 'Y' THEN
    pa_debug.set_curr_function(
                p_function   =>'PA_FP_COPY_FROM_PKG.Update_Plan_Setup_For_WP_Copy'
               ,p_debug_mode => l_debug_mode );

    -- Check for business rules violations
        pa_debug.g_err_stage:='Validating input parameters';
        pa_debug.write('Update_Plan_Setup_For_WP_Copy: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_project_id IS NULL) OR
       (p_wp_version_id IS NULL)
    THEN

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='p_project_id = '||p_project_id;
           pa_debug.write('Update_Plan_Setup_For_WP_Copy: ' || g_module_name,pa_debug.g_err_stage,5);

           pa_debug.g_err_stage:='p_wp_version_id = '||p_wp_version_id;
           pa_debug.write('Update_Plan_Setup_For_WP_Copy: ' || g_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                              p_token1         => 'PROCEDURENAME',
                              p_value1         => 'PA_FP_COPY_FROM_PKG.Update_Plan_Setup_For_WP_Copy');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    -- Fetch all the plan type values that could have changed
    OPEN  parent_plan_type_cur;
    FETCH parent_plan_type_cur INTO parent_plan_type_rec;
    CLOSE parent_plan_type_cur;

    -- Fetch options id for the workplan version
    OPEN  wp_version_options_cur;
    FETCH wp_version_options_cur INTO wp_version_options_rec;
    CLOSE wp_version_options_cur;

    -- Check if resource list has changed
    IF wp_version_options_rec.cost_resource_list_id <> parent_plan_type_rec.cost_resource_list_id
    THEN
        l_resource_list_change_flag := 'Y';
    ELSE
        l_resource_list_change_flag  := 'N';
    END IF;

    -- Check if rbs version has changed
    IF  nvl(wp_version_options_rec.rbs_version_id,-99) <> nvl(parent_plan_type_rec.rbs_version_id,-99)
    THEN
        l_rbs_version_change_flag := 'Y';
    ELSE
        l_rbs_version_change_flag := 'N';
    END IF;

    -- Update pa_budget_versions table data
    -- Note that period mask and planning period could have changed so this update
    -- is necessary even if resource list is not changed

    UPDATE pa_budget_versions
    SET   resource_list_id            = parent_plan_type_rec.cost_resource_list_id
         ,period_mask_id              = parent_plan_type_rec.cost_period_mask_id
/* Bug 4337221: removed from the update
         ,raw_cost                    = 0
         ,burdened_cost               = 0
         ,total_project_raw_cost      = 0
         ,total_project_burdened_cost = 0
         ,labor_quantity              = 0
         ,equipment_quantity          = 0
*/
         ,last_update_date            = SYSDATE
         ,last_updated_by             = FND_GLOBAL.user_id
         ,last_update_login           = FND_GLOBAL.login_id
         ,record_version_number       = record_version_number + 1
    WHERE budget_version_id =  p_wp_version_id;

    -- Update pa_proj_fp_options entity
    UPDATE pa_proj_fp_options
    SET   track_workplan_costs_flag           =  parent_plan_type_rec.track_workplan_costs_flag
         ,plan_in_multi_curr_flag             =  parent_plan_type_rec.plan_in_multi_curr_flag
         ,margin_derived_from_code            =  parent_plan_type_rec.margin_derived_from_code
         ,factor_by_code                      =  parent_plan_type_rec.factor_by_code
         ,cost_resource_list_id               =  parent_plan_type_rec.cost_resource_list_id
         ,select_cost_res_auto_flag           =  parent_plan_type_rec.select_cost_res_auto_flag
         ,cost_time_phased_code               =  parent_plan_type_rec.cost_time_phased_code
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
         ,rbs_version_id                      =  parent_plan_type_rec.rbs_version_id -- Bug 3725414
         ,record_version_number               =  record_version_number + 1
         ,last_update_date                    =  SYSDATE
         ,last_updated_by                     =  FND_GLOBAL.user_id
         ,last_update_login                   =  FND_GLOBAL.login_id
    WHERE proj_fp_options_id  = wp_version_options_rec.proj_fp_options_id;

    -- Copy MC currencies from plan type

    PA_FP_TXN_CURRENCIES_PUB.copy_fp_txn_currencies (
             p_source_fp_option_id        => parent_plan_type_rec.proj_fp_options_id
             ,p_target_fp_option_id       => wp_version_options_rec.proj_fp_options_id
             ,p_target_fp_preference_code => NULL
             ,p_plan_in_multi_curr_flag   => parent_plan_type_rec.plan_in_multi_curr_flag
             ,x_return_status             => x_return_status
             ,x_msg_count                 => x_msg_count
             ,x_msg_data                  => x_msg_data );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Called API PA_FP_TXN_CURRENCIES_PUB.copy_fp_txn_currencies
                                  api returned error';
           pa_debug.write('Update_Plan_Setup_For_WP_Copy:  ' || g_module_name,pa_debug.g_err_stage,5);
        END IF;
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    -- If resource list has changed, resource assingments data should be re-mapped as per
    -- the new resource list
    IF l_resource_list_change_flag = 'Y' THEN
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
               pa_debug.g_err_stage:='Called API PA_PLANNING_TRANSACTION_UTILS.Get_Res_Class_Rlm_Ids
                                      api returned error';
               pa_debug.write('Update_Plan_Setup_For_WP_Copy:  ' || g_module_name,pa_debug.g_err_stage,5);
            END IF;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        -- Update all the task planning elements with new PEOPLE rlmid
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Updaing res assignments with new PEOPLE rlmid : '
                                  || l_people_res_class_rlm_id;
            pa_debug.write('Update_Plan_Setup_For_WP_Copy: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;

        UPDATE pa_resource_assignments
        SET    resource_list_member_id  = l_people_res_class_rlm_id
        WHERE  budget_version_id = p_wp_version_id
        AND    resource_class_code = 'PEOPLE'
        AND    resource_class_flag = 'Y';
    END IF;

    -- If rbs version has changed, call pji_create for summarising the data
    IF l_rbs_version_change_flag = 'Y'
    THEN
         -- Call RBS mapping api for the entire version
         -- The api returns rbs element id, txn accum header id for each
         -- resource assignment id in the form of plsql tables
         PA_RLMI_RBS_MAP_PUB.Map_Rlmi_Rbs(
              p_budget_version_id            =>   p_wp_version_id
             ,p_resource_list_id             =>   parent_plan_type_rec.cost_resource_list_id
             ,p_rbs_version_id               =>   parent_plan_type_rec.rbs_version_id
             ,p_calling_process              =>   'RBS_REFRESH'
             ,p_calling_context              =>   'PLSQL'
             ,p_process_code                 =>   'RBS_MAP'
             ,p_calling_mode                 =>   'BUDGET_VERSION'
             ,p_init_msg_list_flag           =>   'N'
             ,p_commit_flag                  =>   'N'
             ,x_txn_source_id_tab            =>   l_txn_source_id_tbl
             ,x_res_list_member_id_tab       =>   l_res_list_member_id_tbl
             ,x_rbs_element_id_tab           =>   l_rbs_element_id_tbl
             ,x_txn_accum_header_id_tab      =>   l_txn_accum_header_id_tbl
             ,x_return_status                =>   x_return_status
             ,x_msg_count                    =>   x_msg_count
             ,x_msg_data                     =>   x_msg_data);

         -- Bug 3579153 Check return status
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Called API PA_PLANNING_TRANSACTION_UTILS.Map_Rlmi_Rbs api returned error';
                pa_debug.write('Update_Plan_Setup_For_WP_Copy:  ' || g_module_name,pa_debug.g_err_stage,5);
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
                    pa_debug.write('Update_Plan_Setup_For_WP_Copy:  ' || g_module_name,pa_debug.g_err_stage,5);
                    pa_debug.g_err_stage:='l_txn_source_id_tbl.count = ' || l_txn_source_id_tbl.count;
                    pa_debug.write('Update_Plan_Setup_For_WP_Copy:  ' || g_module_name,pa_debug.g_err_stage,5);
                    pa_debug.g_err_stage:='l_rbs_element_id_tbl.count = ' || l_rbs_element_id_tbl.count;
                    pa_debug.write('Update_Plan_Setup_For_WP_Copy:  ' || g_module_name,pa_debug.g_err_stage,5);
                    pa_debug.g_err_stage:=
                         'l_txn_accum_header_id_tbl.count = ' || l_txn_accum_header_id_tbl.count;
                    pa_debug.write('Update_Plan_Setup_For_WP_Copy:  ' || g_module_name,pa_debug.g_err_stage,5);
                 END IF;
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
             END IF;
         END IF;

         -- Check if out table has any records first
         IF nvl(l_txn_source_id_tbl.last,0) >= 1 THEN

             -- Update resource assignments data for the version
             FORALL i IN l_txn_source_id_tbl.first .. l_txn_source_id_tbl.last
                  UPDATE pa_resource_assignments
                  SET     rbs_element_id          =  l_rbs_element_id_tbl(i)
                         ,txn_accum_header_id     =  l_txn_accum_header_id_tbl(i)
                         ,record_version_number   =  record_version_number + 1
                         ,last_update_date        =  SYSDATE
                         ,last_updated_by         =  FND_GLOBAL.user_id
                         ,last_update_login       =  FND_GLOBAL.login_id
                  WHERE  budget_version_id = p_wp_version_id
                  AND    resource_assignment_id = l_txn_source_id_tbl(i);
         END IF;

         -- populating the l_budget_version_id_tbl with p_budget_version_id
         l_budget_version_id_tbl := SYSTEM.pa_num_tbl_type(p_wp_version_id);


    END IF;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Exiting Update_Plan_Setup_For_WP_Copy';
        pa_debug.write('Update_Plan_Setup_For_WP_Copy: ' || g_module_name,pa_debug.g_err_stage,3);
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
           pa_debug.write('Update_Plan_Setup_For_WP_Copy: ' || g_module_name,pa_debug.g_err_stage,5);
          -- reset curr function
           pa_debug.reset_curr_function();
       END IF;
       RETURN;
   WHEN Others THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FP_COPY_FROM_PKG'
                               ,p_procedure_name  => 'Update_Plan_Setup_For_WP_Copy');

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write('Update_Plan_Setup_For_WP_Copy: ' || g_module_name,pa_debug.g_err_stage,5);
       -- reset curr function
       pa_debug.Reset_Curr_Function();
       END IF;

       RAISE;
END Update_Plan_Setup_For_WP_Copy;

END pa_fp_copy_from_pkg;

/
