--------------------------------------------------------
--  DDL for Package Body PA_FP_TXN_CURRENCIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_TXN_CURRENCIES_PUB" AS
/* $Header: PAFPTXCB.pls 120.1 2005/08/19 16:30:38 mwasowic noship $*/

Invalid_Arg_Exc EXCEPTION;
l_module_name VARCHAR2(100):= 'pa.plsql.pa_fp_txn_currencies_pub';

/*===========================================================================
  This api copies pa_fp_txn_currencies from one proj option to another.
  If p_target_fp_preference_code isn't passed then it's vale is fetched from
  pa_proj_fp_options table.

  3/30/2004 Raja FP M Phase II Dev changes
  Post FP M txn currencies can be added irrespective of MC flag status
  Changed the code such that if source option is available all the currencies
  are copied from source to target option

============================================================================*/

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE Copy_Fp_Txn_Currencies (
          p_source_fp_option_id           IN  NUMBER
          ,p_target_fp_option_id          IN  NUMBER
          ,p_target_fp_preference_code    IN  VARCHAR2
          ,p_plan_in_multi_curr_flag      IN  VARCHAR2  --Bug:- 2706430
          ,p_approved_rev_plan_type_flag  IN  VARCHAR2  --For Bug 2998696
          ,x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                     OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
AS

     /* Start of Variables to be used for debugging purpose */

     l_msg_count          NUMBER :=0;
     l_data               VARCHAR2(2000);
     l_msg_data           VARCHAR2(2000);
     l_error_msg_code     VARCHAR2(30);
     l_msg_index_out      NUMBER;
     l_return_status      VARCHAR2(2000);
     l_debug_mode         VARCHAR2(30);


     /* End of Variables to be used for debugging purpose */

    l_source_project_id        pa_projects_all.project_id%TYPE;
    l_source_fp_option_id      pa_proj_fp_options.proj_fp_options_id%TYPE;

    l_srce_cost_default_curr_code pa_fp_txn_currencies.txn_currency_code%TYPE;
    l_srce_rev_default_curr_code  pa_fp_txn_currencies.txn_currency_code%TYPE;
    l_srce_all_default_curr_code  pa_fp_txn_currencies.txn_currency_code%TYPE;
    l_only_projfunc_curr          BOOLEAN;  -- Added for #2632410.

    CURSOR target_fp_options_cur IS
           SELECT  project_id
                   ,fin_plan_type_id
                   ,fin_plan_version_id
                   ,NVL(p_target_fp_preference_code,fin_plan_preference_code) fin_plan_preference_code
                   ,nvl(p_approved_rev_plan_type_flag,nvl(approved_rev_plan_type_flag,'N')) approved_rev_plan_type_flag--For Bug 2998696
 --                  ,plan_in_multi_curr_flag  Bug:- 2706430
  /* commented out as we should be using the passed value always */
           FROM    pa_proj_fp_options
           WHERE   proj_fp_options_id = p_target_fp_option_id;

    target_fp_options_rec target_fp_options_cur%ROWTYPE;

    CURSOR proj_pf_currencies_cur(c_project_id pa_projects.project_id%TYPE) IS
           SELECT project_currency_code
                  ,projfunc_currency_code
           FROM   pa_projects_all
           WHERE  project_id = c_project_id;

    proj_pf_currencies_rec proj_pf_currencies_cur%ROWTYPE;

    CURSOR default_all_curr_code IS
           SELECT txn_currency_code
           FROM   pa_fp_txn_currencies
           WHERE  proj_fp_options_id = p_target_fp_option_id
             AND  default_all_curr_flag = 'Y';

    CURSOR default_cost_curr_code IS
           SELECT txn_currency_code
           FROM   pa_fp_txn_currencies
           WHERE  proj_fp_options_id = p_target_fp_option_id
             AND  default_cost_curr_flag = 'Y';

    CURSOR default_rev_curr_code IS
           SELECT txn_currency_code
           FROM   pa_fp_txn_currencies
           WHERE  proj_fp_options_id = p_target_fp_option_id
             AND  default_rev_curr_flag = 'Y';

BEGIN

    -- Set the error stack.
       pa_debug.set_err_stack('PA_FP_TXN_CURRENCIES_PUB.Copy_Fp_Txn_Currencies');

    -- Get the Debug mode into local variable and set it to 'Y' if its NULL
       fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
       l_debug_mode := NVL(l_debug_mode, 'Y');

    -- Initialize the return status to success
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       x_msg_count := 0;

       IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.set_process('Copy_Fp_Txn_Currencies: ' || 'PLSQL','LOG',l_debug_mode);
       END IF;

    -- Check for business rules violations

    IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='Validating input parameters';
         pa_debug.write('Copy_Fp_Txn_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    -- Check if source and target fp option ids are null

    IF (p_target_fp_option_id IS NULL)  OR
       (p_plan_in_multi_curr_flag IS NULL)
    THEN

        IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:='Target_fp_option_id = '||p_target_fp_option_id;
             pa_debug.write('Copy_Fp_Txn_Currencies: ' || l_module_name,pa_debug.g_err_stage,5);
             pa_debug.g_err_stage:='Target_fp_option_id = '||p_plan_in_multi_curr_flag;
             pa_debug.write('Copy_Fp_Txn_Currencies: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name     => 'PA_FP_INV_PARAM_PASSED');

        RAISE Invalid_Arg_Exc;

    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='Parameter validation complete';
         pa_debug.write('Copy_Fp_Txn_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    -- Fetch project id,plan type id,plan version id and preference code of target
    -- from pa_proj_fp_options

    IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='Opening target_fp_options_cur';
         pa_debug.write('Copy_Fp_Txn_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    OPEN target_fp_options_cur;
    FETCH target_fp_options_cur INTO target_fp_options_rec;
    CLOSE target_fp_options_cur;

    IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='Project_id ='||target_fp_options_rec.project_id;
         pa_debug.write('Copy_Fp_Txn_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
         pa_debug.g_err_stage:='Fin_plan_type_id ='||target_fp_options_rec.fin_plan_type_id;
         pa_debug.write('Copy_Fp_Txn_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
         pa_debug.g_err_stage:='Fin_plan_preference_code ='||target_fp_options_rec.fin_plan_preference_code;
         pa_debug.write('Copy_Fp_Txn_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
         pa_debug.g_err_stage:='Fin_plan_version_id ='||target_fp_options_rec.fin_plan_version_id;
         pa_debug.write('Copy_Fp_Txn_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    --Fetch project and project functional currencies for target project

    IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='Opening proj_pf_currencies_cur';
         pa_debug.write('Copy_Fp_Txn_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    OPEN  proj_pf_currencies_cur(target_fp_options_rec.project_id);
    FETCH proj_pf_currencies_cur INTO proj_pf_currencies_rec;
    CLOSE proj_pf_currencies_cur;

    IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='project_currency_code='||proj_pf_currencies_rec.project_currency_code;
         pa_debug.write('Copy_Fp_Txn_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
         pa_debug.g_err_stage:='projfunc_currency_code='||proj_pf_currencies_rec.projfunc_currency_code;
         pa_debug.write('Copy_Fp_Txn_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF p_source_fp_option_id IS NULL THEN

          l_source_fp_option_id := PA_PROJ_FP_OPTIONS_PUB.GET_PARENT_FP_OPTION_ID(p_target_fp_option_id);

    ELSE

         l_source_fp_option_id := p_source_fp_option_id;

    END IF;

    --Delete the existing fp txn currencies of the target fp option

    DELETE FROM pa_fp_txn_currencies
    WHERE  proj_fp_options_id = p_target_fp_option_id;

    -- p_plan_in_multi_curr_flag = 'N' condition has been added (for bug :- 2706430) to insert
    -- PC and PFC as txn currencies incase multi currency isn't enabled

    -- 3/30/2004 Raja FP M Phase II Dev changes
    -- Post FP M txn currencies can be added irrespective of MC flag status
    -- Changed the code such that if source option is available all the currencies
    -- are copied from source to target option

    IF l_source_fp_option_id IS NULL
    -- Raja 3/30/2004 FP M Phase II Dev Changes OR p_plan_in_multi_curr_flag = 'N'
    THEN

       --Calling Insert_Default_Currencies api

       IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:='Calling Insert_Default_Currencies api';
            pa_debug.write('Copy_Fp_Txn_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

        Insert_Default_Currencies(
                 p_project_id                   => target_fp_options_rec.project_id
                 ,p_fin_plan_type_id            => target_fp_options_rec.fin_plan_type_id
                 ,p_fin_plan_preference_code    => target_fp_options_rec.fin_plan_preference_code
                 ,p_fin_plan_version_id         => target_fp_options_rec.fin_plan_version_id
                 ,p_project_currency_code       => proj_pf_currencies_rec.project_currency_code
                 ,p_projfunc_currency_code      => proj_pf_currencies_rec.projfunc_currency_code
                 ,p_approved_rev_plan_type_flag => target_fp_options_rec.approved_rev_plan_type_flag
                 ,p_target_fp_option_id         => p_target_fp_option_id );

    ELSE -- Raja 3/30/2004 FP M phase II Dev changes IF p_plan_in_multi_curr_flag = 'Y' THEN

        --Fetch project id of source fp option

        IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:='Fetching source project id';
             pa_debug.write('Copy_Fp_Txn_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        SELECT project_id
        INTO   l_source_project_id
        FROM   pa_proj_fp_options
        WHERE  proj_fp_options_id = l_source_fp_option_id;

        /* #2632410: Modified the below logic to insert only Project Functional Records
           when the l_only_projfunc_curr_flg returned by Insert_Only_Projfunc_Curr is TRUE. */

        /* Getting the l_only_projfunc_curr_flg to determine if only the Project
           Functional currency has to be inserted. */

        IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage:='Calling Insert_Only_Projfunc_Curr';
              pa_debug.write('Copy_Fp_Txn_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        l_only_projfunc_curr := Insert_Only_Projfunc_Curr( p_proj_fp_options_id          => p_target_fp_option_id
                                                          ,p_approved_rev_plan_type_flag => p_approved_rev_plan_type_flag );

        IF l_only_projfunc_curr = TRUE THEN -- Call Insert Default currencies to insert only proj func record.

                IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.g_err_stage:='Calling Insert_Default_Currencies to insert projfunc record.';
                     pa_debug.write('Copy_Fp_Txn_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
                END IF;

                Insert_Default_Currencies(
                       p_project_id                   => target_fp_options_rec.project_id
                       ,p_fin_plan_type_id            => target_fp_options_rec.fin_plan_type_id
                       ,p_fin_plan_preference_code    => target_fp_options_rec.fin_plan_preference_code
                       ,p_fin_plan_version_id         => target_fp_options_rec.fin_plan_version_id
                       ,p_project_currency_code       => proj_pf_currencies_rec.project_currency_code
                       ,p_projfunc_currency_code      => proj_pf_currencies_rec.projfunc_currency_code
                       ,p_approved_rev_plan_type_flag => target_fp_options_rec.approved_rev_plan_type_flag
                       ,p_target_fp_option_id         => p_target_fp_option_id );

        ELSE -- Do the processing as it was previously

                IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.g_err_stage:='Inserting records into pa_fp_txn_currencies for the target ';
                      pa_debug.write('Copy_Fp_Txn_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
                END IF;

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
                            ,project_cost_exchange_rate --fix for bug 2613901
                            ,project_rev_exchange_rate
                            ,projfunc_cost_exchange_Rate
                            ,projfunc_rev_exchange_Rate)
                SELECT      pa_fp_txn_currencies_s.NEXTVAL
                            ,p_target_fp_option_id
                            ,target_fp_options_rec.project_id          --project_id of target fp option
                            ,target_fp_options_rec.fin_plan_type_id    --plan_type of target fp option
                            ,target_fp_options_rec.fin_plan_version_id --plan version of target fp option
                            ,txn_currency_code
                            ,default_rev_curr_flag
                            ,default_cost_curr_flag
                            ,default_all_curr_flag
                            ,project_currency_flag
                            ,projfunc_currency_flag
                            ,SYSDATE
                            ,fnd_global.user_id
                            ,SYSDATE
                            ,fnd_global.user_id
                            ,fnd_global.login_id
                            ,project_cost_exchange_rate --fix for bug 2613901
                            ,project_rev_exchange_rate
                            ,projfunc_cost_exchange_Rate
                            ,projfunc_rev_exchange_Rate
                FROM        pa_fp_txn_currencies
                WHERE       proj_fp_options_id = l_source_fp_option_id;

                IF SQL%rowcount = 0 THEN

                   --Insert default currencies if no records exist for source fp options id

                          IF P_PA_DEBUG_MODE = 'Y' THEN
                               pa_debug.g_err_stage:='Calling Insert_Default_Currencies api ';
                               pa_debug.write('Copy_Fp_Txn_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
                          END IF;

                          Insert_Default_Currencies(
                                 p_project_id                   => target_fp_options_rec.project_id
                                 ,p_fin_plan_type_id            => target_fp_options_rec.fin_plan_type_id
                                 ,p_fin_plan_preference_code    => target_fp_options_rec.fin_plan_preference_code
                                 ,p_fin_plan_version_id         => target_fp_options_rec.fin_plan_version_id
                                 ,p_project_currency_code       => proj_pf_currencies_rec.project_currency_code
                                 ,p_projfunc_currency_code      => proj_pf_currencies_rec.projfunc_currency_code
                                 ,p_approved_rev_plan_type_flag => target_fp_options_rec.approved_rev_plan_type_flag
                                 ,p_target_fp_option_id         => p_target_fp_option_id );

                ELSE

                        --If project ids are different then pass the curr codes as NULL

                        IF l_source_project_id <> target_fp_options_rec.project_id THEN

                            l_srce_all_default_curr_code:= NULL;

                            l_srce_cost_default_curr_code:= NULL;

                            l_srce_rev_default_curr_code:= NULL;

                        ELSE -- if same fetch default curr codes

                           OPEN default_all_curr_code;

                                 FETCH default_all_curr_code INTO l_srce_all_default_curr_code;

                           CLOSE default_all_curr_code;

                           OPEN default_cost_curr_code;

                                 FETCH default_cost_curr_code INTO l_srce_cost_default_curr_code;

                           CLOSE default_cost_curr_code;

                           OPEN default_rev_curr_code;

                                 FETCH default_rev_curr_code INTO l_srce_rev_default_curr_code;

                           CLOSE default_rev_curr_code;

                        END IF;

                        --Call Set_Default_Currencies private procedure

                        IF P_PA_DEBUG_MODE = 'Y' THEN
                             pa_debug.g_err_stage:='Calling Set_Default_Currencies';
                             pa_debug.write('Copy_Fp_Txn_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
                        END IF;

                        PA_FP_TXN_CURRENCIES_PUB.Set_Default_Currencies(
                                  p_target_fp_option_id            => p_target_fp_option_id
                                  ,p_target_preference_code        => target_fp_options_rec.fin_plan_preference_code
                                  ,p_approved_rev_plan_type_flag   => target_fp_options_rec.approved_rev_plan_type_flag
                                  ,p_srce_all_default_curr_code    => l_srce_all_default_curr_code
                                  ,p_srce_rev_default_curr_code    => l_srce_rev_default_curr_code
                                  ,p_srce_cost_default_curr_code   => l_srce_cost_default_curr_code
                                  ,p_project_currency_code         => proj_pf_currencies_rec.project_currency_code
                                  ,p_projfunc_currency_code        => proj_pf_currencies_rec.projfunc_currency_code );

                END IF; --sql%rowcount <> 0

        END IF; --l_only_projfunc_curr_flg = 'Y'

    END IF;  -- l_source_fp_option_id null/not null

    IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='Exiting Copy_Fp_Txn_Currencies';
         pa_debug.write('Copy_Fp_Txn_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    --Reset the error stack

    pa_debug.reset_err_stack;

EXCEPTION

     WHEN Invalid_Arg_Exc THEN

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
                pa_debug.write('Copy_Fp_Txn_Currencies: ' || l_module_name,pa_debug.g_err_stage,5);
           END IF;
           pa_debug.reset_err_stack;

           RAISE;

     WHEN Others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'PA_FP_TXN_CURRENCIES_PUB'
                                  ,p_procedure_name  => 'COPY_FP_TXN_CURRENCIES');

          IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:='Unexpeted Error';
               pa_debug.write('Copy_Fp_Txn_Currencies: ' || l_module_name,pa_debug.g_err_stage,5);
          END IF;
          pa_debug.reset_err_stack;
          RAISE ;

END Copy_Fp_Txn_Currencies;

/*===========================================================================
 This api is called from copy_fp_txn_currencies to insert default currencies
 for target fp option if source option is null and parent option is not present
=============================================================================*/

PROCEDURE Insert_Default_Currencies(
         p_project_id                   IN NUMBER
         ,p_fin_plan_type_id            IN NUMBER
         ,p_fin_plan_preference_code    IN VARCHAR2
         ,p_fin_plan_version_id         IN NUMBER
         ,p_project_currency_code       IN VARCHAR2
         ,p_projfunc_currency_code      IN VARCHAR2
         ,p_approved_rev_plan_type_flag IN VARCHAR2
         ,p_target_fp_option_id         IN NUMBER   )
AS
  l_only_proj_func_curr  BOOLEAN; -- Added for #2632410
BEGIN

        /* #2632410: Modified the below logic to insert the Project Currency Record
           when the l_only_proj_func_curr returned by Insert_Only_Projfunc_Curr is
           FALSE. */

        IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:='Calling Insert_Only_Projfunc_Curr - 1';
             pa_debug.write('Insert_Default_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        l_only_proj_func_curr := Insert_Only_Projfunc_Curr( p_proj_fp_options_id          => p_target_fp_option_id
                                                           ,p_approved_rev_plan_type_flag => p_approved_rev_plan_type_flag );--For bug 2998696

        IF l_only_proj_func_curr = FALSE THEN --Do not insert any proj currency rec if flag is TRUE

                IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.g_err_stage:='Inserting project currency as default currency ';
                     pa_debug.write('Insert_Default_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
                END IF;

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
                            ,project_cost_exchange_rate --fix for bug 2613901
                            ,project_rev_exchange_rate
                            ,projfunc_cost_exchange_Rate
                            ,projfunc_rev_exchange_Rate
                            )
                SELECT      pa_fp_txn_currencies_s.NEXTVAL
                            ,p_target_fp_option_id
                            ,p_project_id          --project_id of target fp option
                            ,p_fin_plan_type_id    --plan_type of target fp option
                            ,p_fin_plan_version_id --plan version of target fp option
                            ,p_project_currency_code
                            ,'N' --default_rev_curr_flag
                            ,'N' --default_cost_curr_flag
                            ,'N' --default_all_curr_flag
                            ,'Y'--project_currency_flag
                            ,DECODE(p_projfunc_currency_code,p_project_currency_code,'Y','N')  --projfunc_currency_flag
                            ,SYSDATE
                            ,fnd_global.user_id
                            ,SYSDATE
                            ,fnd_global.user_id
                            ,fnd_global.login_id
                            ,NULL --fix for bug 2613901
                            ,NULL
                            ,NULL
                            ,NULL
                FROM        DUAL;

        END IF; --l_only_proj_func_curr = FALSE

        /* #2632410: The Project Functional Currency record has to be inserted
           even when l_only_proj_func_curr is TRUE */

        IF (p_projfunc_currency_code <> p_project_currency_code OR
            l_only_proj_func_curr = TRUE)                    THEN

                IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.g_err_stage:='Inserting projfunc currency ';
                     pa_debug.write('Insert_Default_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
                END IF;

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
                            ,project_cost_exchange_rate --fix for bug 2613901
                            ,project_rev_exchange_rate
                            ,projfunc_cost_exchange_Rate
                            ,projfunc_rev_exchange_Rate)
                SELECT      pa_fp_txn_currencies_s.NEXTVAL
                            ,p_target_fp_option_id
                            ,p_project_id          --project_id of target fp option
                            ,p_fin_plan_type_id    --plan_type of target fp option
                            ,p_fin_plan_version_id --plan version of target fp option
                            ,p_projfunc_currency_code
                            ,'N' --default_rev_curr_flag
                            ,'N' --default_cost_curr_flag
                            ,'N' --default_all_curr_flag
                            ,DECODE(p_projfunc_currency_code,p_project_currency_code,'Y','N')  --project_currency_flag
                            ,'Y' --projfunc_currency_flag
                            ,SYSDATE
                            ,fnd_global.user_id
                            ,SYSDATE
                            ,fnd_global.user_id
                            ,fnd_global.login_id
                            ,NULL  --fix for bug 2613901
                            ,NULL
                            ,NULL
                            ,NULL
                FROM        DUAL;

        END IF;

        --To set the default currencies call Set_Default_Currencies

        IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:='Calling Set_Default_Currencies';
             pa_debug.write('Insert_Default_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        PA_FP_TXN_CURRENCIES_PUB.Set_Default_Currencies(
                  p_target_fp_option_id           => p_target_fp_option_id
                  ,p_target_preference_code       => p_fin_plan_preference_code
                  ,p_approved_rev_plan_type_flag  => p_approved_rev_plan_type_flag
                  ,p_srce_all_default_curr_code   => NULL
                  ,p_srce_rev_default_curr_code   => NULL
                  ,p_srce_cost_default_curr_code  => NULL
                  ,p_project_currency_code        => p_project_currency_code
                  ,p_projfunc_currency_code       => p_projfunc_currency_code );

        IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:='Exiting Insert_Default_Currencies ';
             pa_debug.write('Insert_Default_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

EXCEPTION
   WHEN OTHERS THEN
          IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage:='EXCEPTION Insert_Default_Currencies ' || SQLERRM;
              pa_debug.write('Insert_Default_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;
          RAISE;
END  Insert_Default_Currencies;
/*===========================================================================
 This api is called from copy_fp_txn_currencies and Insert_Default_Currencies
 this api sets the default currency flags appropriately
=============================================================================*/
PROCEDURE  Set_Default_Currencies(
      p_target_fp_option_id             IN NUMBER
      ,p_target_preference_code         IN VARCHAR2
      ,p_approved_rev_plan_type_flag    IN VARCHAR2
      ,p_srce_all_default_curr_code     IN VARCHAR2
      ,p_srce_rev_default_curr_code     IN VARCHAR2
      ,p_srce_cost_default_curr_code    IN VARCHAR2
      ,p_project_currency_code          IN VARCHAR2
      ,p_projfunc_currency_code         IN VARCHAR2 )
AS
   l_srce_cost_default_curr_code pa_fp_txn_currencies.txn_currency_code%TYPE;
   l_srce_rev_default_curr_code  pa_fp_txn_currencies.txn_currency_code%TYPE;
   l_srce_all_default_curr_code  pa_fp_txn_currencies.txn_currency_code%TYPE;
BEGIN

      IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Target_preference_code ='||p_target_preference_code;
           pa_debug.write('Set_Default_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
      END IF;


      IF p_target_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY  THEN

             IF p_srce_all_default_curr_code IS NOT NULL THEN

                 l_srce_cost_default_curr_code := p_srce_all_default_curr_code;

             END IF;

             IF p_srce_cost_default_curr_code IS NOT NULL THEN

                 l_srce_cost_default_curr_code := p_srce_cost_default_curr_code;

             END IF;

             --If l_srce_cost_default_curr_code is still NULL then set project_currency as default.

             IF l_srce_cost_default_curr_code   IS NULL THEN

                  l_srce_cost_default_curr_code := p_project_currency_code;

             END IF;

             UPDATE pa_fp_txn_currencies
                SET default_cost_curr_flag = DECODE(txn_currency_code,l_srce_cost_default_curr_code,'Y','N')
                   ,default_rev_curr_flag = 'N'
                   ,default_all_curr_flag = 'N'
             WHERE proj_fp_options_id = p_target_fp_option_id ;

      ELSIF p_target_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY THEN

             IF p_srce_all_default_curr_code IS NOT NULL THEN

                   l_srce_rev_default_curr_code := p_srce_all_default_curr_code;

             END IF;

             IF p_srce_rev_default_curr_code IS NOT NULL THEN

                l_srce_rev_default_curr_code := p_srce_rev_default_curr_code;

             END IF;

             --If l_srce_rev_default_curr_code is still NULL then set project_currency/projfunc currency
             --as default depending on approved_rev_plan_type_flag

--             IF l_srce_rev_default_curr_code IS NULL THEN  Commented out the outer if for bug 2593182 and
                                                            --shifted it to the if condition below

                  IF (nvl(p_approved_rev_plan_type_flag,'N') <> 'Y')  THEN
                      IF (l_srce_rev_default_curr_code IS NULL)  THEN

                          l_srce_rev_default_curr_code := p_project_currency_code;

		            END IF;

                  ELSE
                          l_srce_rev_default_curr_code := p_projfunc_currency_code;

                  END IF;

--             END IF;


             UPDATE pa_fp_txn_currencies
                SET default_cost_curr_flag = 'N'
                   ,default_rev_curr_flag = DECODE(txn_currency_code,l_srce_rev_default_curr_code,'Y','N')
                   ,default_all_curr_flag = 'N'
               WHERE proj_fp_options_id = p_target_fp_option_id ;

      ELSIF p_target_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME THEN

              IF p_srce_cost_default_curr_code IS NOT NULL THEN

                    l_srce_all_default_curr_code := p_srce_cost_default_curr_code;

              ELSIF p_srce_rev_default_curr_code IS NOT NULL THEN

                    l_srce_all_default_curr_code := p_srce_rev_default_curr_code;

              END IF;

	         IF p_srce_all_default_curr_code IS NOT NULL THEN

                    l_srce_all_default_curr_code := p_srce_all_default_curr_code;

              END IF;

/*              IF l_srce_all_default_curr_code IS NULL THEN

                 l_srce_all_default_curr_code := p_project_currency_code;

              END IF;
Commented out the If condition for bug 2593182 and included the if condition below
*/

              IF    p_approved_rev_plan_type_flag ='Y' THEN

                   l_srce_all_default_curr_code := p_projfunc_currency_code;

              ELSIF l_srce_all_default_curr_code IS NULL THEN /*included the if for bug 2593182*/

                   l_srce_all_default_curr_code := p_project_currency_code;

              END IF;

              UPDATE pa_fp_txn_currencies
                 SET default_cost_curr_flag =  'N'
                    ,default_rev_curr_flag  =  'N'
                    ,default_all_curr_flag  =  DECODE(txn_currency_code,l_srce_all_default_curr_code,'Y','N')
              WHERE proj_fp_options_id  =  p_target_fp_option_id ;

      ELSIF p_target_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP THEN

          IF p_srce_all_default_curr_code IS NOT NULL THEN

                l_srce_cost_default_curr_code := p_srce_all_default_curr_code;

                l_srce_rev_default_curr_code  := p_srce_all_default_curr_code;

          END IF;

          IF p_srce_rev_default_curr_code IS NOT NULL THEN

                l_srce_rev_default_curr_code := p_srce_rev_default_curr_code;

          END IF;

          IF p_srce_cost_default_curr_code IS NOT NULL THEN

                l_srce_cost_default_curr_code := p_srce_cost_default_curr_code;

          END IF;
          -- If cost_currency is null then set project currency as cost currency

          IF l_srce_cost_default_curr_code  IS  NULL THEN

                l_srce_cost_default_curr_code := p_project_currency_code;

          END IF;


          --If rev_currency is null  then projfunc currency/project currency as
          --rev currency using approved rev plan type flag

--          IF l_srce_rev_default_curr_code IS NULL THEN Commenting out for bug 2593182

             IF    p_approved_rev_plan_type_flag ='Y' THEN

                   l_srce_rev_default_curr_code := p_projfunc_currency_code;

		   ELSIF l_srce_rev_default_curr_code IS NULL THEN /*included the if for bug 2593182*/

			   l_srce_rev_default_curr_code := p_project_currency_code;

             END IF;

--          END IF;

          IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:='About to update ';
               pa_debug.write('Set_Default_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;

          UPDATE pa_fp_txn_currencies
             SET default_cost_curr_flag =  DECODE(txn_currency_code,l_srce_cost_default_curr_code,'Y','N')
                ,default_rev_curr_flag  =  DECODE(txn_currency_code,l_srce_rev_default_curr_code,'Y','N')
                ,default_all_curr_flag  =  'N'
          WHERE proj_fp_options_id  =  p_target_fp_option_id ;

      END IF; --preference code

      IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Exiting Set_Default_Currencies ';
           pa_debug.write('Set_Default_Currencies: ' || l_module_name,pa_debug.g_err_stage,3);
      END IF;

END  Set_Default_Currencies;

/*==============================================================================
  This api is used to enter the agreement currency for the control item versions
  in the pa_fp_txn_currencies table.
 ===============================================================================*/

PROCEDURE enter_agreement_curr_for_ci
   (  p_project_id              IN      pa_budget_versions.project_id%TYPE
     ,p_fin_plan_version_id     IN      pa_budget_versions.budget_Version_id%TYPE
     ,p_ci_id                   IN      pa_budget_Versions.ci_id%TYPE
     ,p_project_currency_code   IN      pa_projects.project_currency_code%TYPE
     ,p_projfunc_currency_code  IN      pa_projects.projfunc_currency_code%TYPE
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

l_agreement_num                 pa_agreements_all.agreement_num%TYPE;
l_agreement_amount              pa_agreements_all.amount%TYPE;
l_agreement_currency_code       pa_agreements_all.agreement_currency_code%TYPE;

l_project_currency_code            pa_projects_all.project_currency_code%TYPE;
l_projfunc_currency_code           pa_projects_all.projfunc_currency_code%TYPE;
l_dummy_currency_code              pa_projects_all.projfunc_currency_code%TYPE;


CURSOR version_details_cur IS
SELECT proj_fp_options_id,
       fin_plan_type_id
FROM   pa_proj_fp_options
WHERE  fin_plan_version_id = p_fin_plan_version_id
AND    project_id          = p_project_id;

version_details_rec  version_details_cur%ROWTYPE;

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      pa_debug.set_err_stack('pa_fp_txn_currencies_pub.enter_agreement_curr_for_ci');
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.set_process('enter_agreement_curr_for_ci: ' || 'PLSQL','LOG',l_debug_mode);
      END IF;

      -- Check for business rules violations

      IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:= 'Validating input parameters';
           pa_debug.write('enter_agreement_curr_for_ci: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      --Check if plan version id is null

      IF (p_project_id          IS NULL) OR
         (p_fin_plan_version_id IS NULL) OR
         (p_ci_id               IS NULL)
      THEN
           IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage:= 'p_project_id = '|| p_project_id;
                pa_debug.write('enter_agreement_curr_for_ci: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                pa_debug.g_err_stage:= 'p_fin_plan_version_id = '|| p_fin_plan_version_id;
                pa_debug.write('enter_agreement_curr_for_ci: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                pa_debug.g_err_stage:= 'p_ci_id = '|| p_ci_id;
                pa_debug.write('enter_agreement_curr_for_ci: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
           END IF;

           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_FP_INV_PARAM_PASSED');

           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      -- Using the project_id and ci_id fetch the agreement_currency

      IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage:='Fetching the agreement details';
          pa_debug.write('enter_agreement_curr_for_ci: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      Pa_Fp_Control_Items_Utils.get_fp_ci_agreement_dtls(
                  p_project_id                    =>  p_project_id
                 ,p_ci_id                         =>  p_ci_id
                 ,x_agreement_num                 =>  l_agreement_num
                 ,x_agreement_amount              =>  l_agreement_amount
                 ,x_agreement_currency_code       =>  l_agreement_currency_code
                 ,x_msg_data                      =>  l_msg_data
                 ,x_msg_count                     =>  l_msg_count
                 ,x_return_status                 =>  l_return_status );

      IF  (l_agreement_currency_code IS NULL) OR
          (l_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
              IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.g_err_stage:='Agreement_currency_code is null';
                   pa_debug.write('enter_agreement_curr_for_ci: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
              END IF;
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      -- Get the required details of the fin plan version from the fp options table

      IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Fetching the version details';
           pa_debug.write('enter_agreement_curr_for_ci: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      OPEN  version_details_cur;
      FETCH version_details_cur INTO version_details_rec;
      IF    version_details_cur%NOTFOUND THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      CLOSE version_details_cur;

      IF p_project_currency_code IS NULL OR p_projfunc_currency_code IS NULL THEN
           pa_budget_utils.Get_Project_Currency_Info
          (
             p_project_id                    => p_project_id
           , x_projfunc_currency_code        => l_projfunc_currency_code
           , x_project_currency_code         => l_project_currency_code
           , x_txn_currency_code             => l_dummy_currency_code
           , x_msg_count                     => x_msg_count
           , x_msg_data                      => x_msg_data
           , x_return_status                 => x_return_status
          );

          IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN

              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.g_err_stage:= 'Could not obtain currency info for the project';
                 pa_debug.write('enter_agreement_curr_for_ci: ' || l_module_name,
                                    pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
              END IF;
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;

      END IF;

      IF p_project_currency_code IS NOT NULL THEN
          l_project_currency_code := p_project_currency_code;
      END IF;

      IF p_projfunc_currency_code IS NOT NULL THEN
          l_projfunc_currency_code := p_projfunc_currency_code;
      END IF;


      -- Delete the entry already there (if any) for the version
      DELETE FROM PA_FP_TXN_CURRENCIES
      WHERE proj_fp_options_id = version_details_rec.proj_fp_options_id;
      -- Insert into the pa_fp_txn_currencies table

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
                  ,projfunc_rev_exchange_Rate)
      SELECT      pa_fp_txn_currencies_s.NEXTVAL
                  ,version_details_rec.proj_fp_options_id
                  ,p_project_id
                  ,version_details_rec.fin_plan_type_id
                  ,p_fin_plan_version_id
                  ,l_agreement_currency_code  -- txn_currency_code
                  ,'Y'                        -- default_rev_curr_flag
                  ,'Y'                        -- default_cost_curr_flag
                  ,'Y'                        -- default_all_curr_flag
                  ,DECODE(l_agreement_currency_code,l_project_currency_code,'Y','N')  -- project_currency_flag
                  ,DECODE(l_agreement_currency_code,l_projfunc_currency_code,'Y','N') -- projfunc_currency_flag
                  ,SYSDATE
                  ,fnd_global.user_id
                  ,SYSDATE
                  ,fnd_global.user_id
                  ,fnd_global.login_id
                  ,NULL                       -- project_cost_exchange_rate
                  ,NULL                       -- project_rev_exchange_rate
                  ,NULL                       -- projfunc_cost_exchange_Rate
                  ,NULL                       -- projfunc_rev_exchange_Rate
      FROM        DUAL;

      IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:= 'Exiting enter_agreement_curr_for_ci';
           pa_debug.write('enter_agreement_curr_for_ci: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
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

           IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage:= 'Invalid Arguments Passed';
                pa_debug.write('enter_agreement_curr_for_ci: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
           END IF;
           pa_debug.reset_err_stack;
           RAISE;

   WHEN others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'pa_fp_txn_currencies_pub'
                                  ,p_procedure_name  => 'enter_agreement_curr_for_ci');
          IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;
               pa_debug.write('enter_agreement_curr_for_ci: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          END IF;
          pa_debug.reset_err_stack;
          RAISE;
END enter_agreement_curr_for_ci;

/*===============================================================================================
Bug #2632410: The following function has been added to return the flag which indicates if only
the Project Functional currency attributes have to be inserted into pa_fp_txn_currencies table.
Only Project Functional Currency has to be inserted in the following situations:
- The Approved Revenue Flag for the Proj FP Option ID is 'Y'
- The Plan level is either 'PLAN_TYPE' or 'PLAN_VERSION'
- The Preference Code is either 'COST_AND_REV_SAME' or 'REVENUE_ONLY'
This function will be called from Copy_Fp_Txn_Currencies and also Insert_Default_Currencies to
get the l_insert_only_projfunc_curr flag.

Bug 3668370 Raja FP M changes  Even for AR versions there can be multiple txn currencies
            So, changed the api to always return false so that all the currencies from
            parent record are added
===============================================================================================*/
FUNCTION Insert_Only_Projfunc_Curr( p_proj_fp_options_id          pa_proj_fp_options.proj_fp_options_id%TYPE
                                   ,p_approved_rev_plan_type_flag pa_proj_fp_options.approved_rev_plan_type_flag%TYPE)--for bug 2998696
RETURN  BOOLEAN
IS

   l_planning_level               pa_proj_fp_options.fin_plan_option_level_code%TYPE;
   l_fp_preference_code           pa_proj_fp_options.fin_plan_preference_code%TYPE;
   l_approved_rev_plan_type_flag  pa_proj_fp_options.approved_rev_plan_type_flag%TYPE;
   l_insert_only_proj_func_curr   BOOLEAN;

BEGIN

   IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='In Insert_Only_Projfunc_Curr';
        pa_debug.write('Insert_Only_Projfunc_Curr: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
   END IF;

   l_insert_only_proj_func_curr := FALSE;

/* Bug 3668370 Raja FP M changes  Even for AR versions there can be multiple txn currencies
   -- Getting the Proj FP Option details for the Proj FP Option ID.

   IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='Getting the FP Option details';
        pa_debug.write('Insert_Only_Projfunc_Curr: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
   END IF;

   SELECT fin_plan_option_level_code
         ,fin_plan_preference_code
         ,nvl(p_approved_rev_plan_type_flag,nvl(approved_rev_plan_type_flag,'N'))--Bug 2998696
     INTO l_planning_level
         ,l_fp_preference_code
         ,l_approved_rev_plan_type_flag
     FROM pa_proj_fp_options
    WHERE proj_fp_options_id = p_proj_fp_options_id;

   IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='Approved Revenue Flag is Y';
        pa_debug.write('Insert_Only_Projfunc_Curr: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
   END IF;

   IF  l_approved_rev_plan_type_flag = 'Y'                                          AND
      (l_planning_level IN (PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE,
                            PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION))       AND
      (l_fp_preference_code IN (PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME,
                                      PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY))     THEN

         -- Approved Rev Plan Type Flag is Y
         -- Planning Level is Plan Type/Plan Version,
         -- Fin Plan Preference code is Cost_And_Rev_Same/Revenue_Only.
         -- For all the above conditions, set the  l_insert_only_proj_func_curr as TRUE

         IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage:='Setting the l_insert_only_proj_func_curr as TRUE';
              pa_debug.write('Insert_Only_Projfunc_Curr: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
         END IF;

         l_insert_only_proj_func_curr := TRUE;

   END IF;
*/
   RETURN l_insert_only_proj_func_curr;

END Insert_Only_Projfunc_Curr;

END pa_fp_txn_currencies_pub;

/
