--------------------------------------------------------
--  DDL for Package Body PA_FP_MULTI_CURRENCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_MULTI_CURRENCY_PKG" AS
--$Header: PAFPMCPB.pls 120.3.12010000.2 2010/04/21 11:15:07 kmaddi ship $
/* Perf Bug: 3683132 */
  g_cache_fp_plan_version_id   Number;
  g_cache_fp_txn_cur_code      Varchar2(100);
  g_cache_fp_context           Varchar2(100);
  g_cache_fp_mode              Varchar2(100);
  g_fp_projfunc_cost_exchng_rt   Number;
  g_fp_projfunc_rev_exchng_rt    Number;
  g_fp_project_cost_exchng_rt    Number;
  g_fp_project_rev_exchng_rt     Number;
  g_module_name VARCHAR2(100) := 'pa.plsql.PA_FP_MULTI_CURRENCY_PKG';

  P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

/* Perf Bug: 3683132 */
/*====================================================================+
 | Bug 4094376: Refreshed global variables g_cache_fp_plan_version_id |
 |              g_cache_fp_txn_cur_code.                              |
 +====================================================================*/
FUNCTION get_fp_cur_details( p_budget_version_id   Number
            ,p_txn_currency_code       Varchar2
            ,p_context                 Varchar2 default 'COST'
            ,p_mode                    Varchar2 default 'PROJECT' ) RETURN NUMBER IS

    CURSOR cur_details IS
    SELECT c.projfunc_cost_exchange_rate
          ,c.projfunc_rev_exchange_rate
          ,c.project_cost_exchange_rate
          ,c.project_rev_exchange_rate
    FROM pa_fp_txn_currencies c
        ,pa_proj_fp_options fp
    WHERE fp.fin_plan_version_id = p_budget_version_id
    AND   fp.fin_plan_version_id = c.fin_plan_version_id
    AND   fp.proj_fp_options_id = c.proj_fp_options_id
    AND   c.txn_currency_code = p_txn_currency_code ;

    l_projfunc_cost_exchange_rate   Number;
    l_projfunc_rev_exchange_rate    Number;
    l_project_cost_exchange_rate    Number;
    l_project_rev_exchange_rate     Number;
    l_return_exchg_rate             Number;
BEGIN
    IF p_budget_version_id is NOT NULL AND p_txn_currency_code is NOT NULL Then
      IF  (p_budget_version_id = g_cache_fp_plan_version_id
        AND p_txn_currency_code = g_cache_fp_txn_cur_code ) THEN
        l_projfunc_cost_exchange_rate   := g_fp_projfunc_cost_exchng_rt;
            l_projfunc_rev_exchange_rate    := g_fp_projfunc_rev_exchng_rt;
            l_project_cost_exchange_rate    := g_fp_project_cost_exchng_rt;
            l_project_rev_exchange_rate := g_fp_project_rev_exchng_rt;
      ELSE
        l_projfunc_cost_exchange_rate   := NULL;
            l_projfunc_rev_exchange_rate    := NULL;
            l_project_cost_exchange_rate    := NULL;
            l_project_rev_exchange_rate := NULL;
        OPEN cur_details;
        FETCH cur_details INTO
            l_projfunc_cost_exchange_rate
                    ,l_projfunc_rev_exchange_rate
                    ,l_project_cost_exchange_rate
                    ,l_project_rev_exchange_rate ;
        CLOSE cur_details;

        /** assign the values to global variables **/
                g_cache_fp_plan_version_id     := p_budget_version_id;
                g_cache_fp_txn_cur_code        := p_txn_currency_code;
        g_fp_projfunc_cost_exchng_rt   := l_projfunc_cost_exchange_rate;
                g_fp_projfunc_rev_exchng_rt    := l_projfunc_rev_exchange_rate;
                g_fp_project_cost_exchng_rt    := l_project_cost_exchange_rate;
                g_fp_project_rev_exchng_rt     := l_project_rev_exchange_rate;
      END IF;
    END IF;

    If p_context = 'COST' Then
        If p_mode = 'PROJECT' Then
            l_return_exchg_rate := l_project_cost_exchange_rate;
        Elsif p_mode = 'PROJFUNC' Then
            l_return_exchg_rate := l_projfunc_cost_exchange_rate;
        End If;
    Else
        If p_mode = 'PROJECT' Then
                    l_return_exchg_rate := l_project_rev_exchange_rate;
                Elsif p_mode = 'PROJFUNC' Then
                    l_return_exchg_rate := l_projfunc_rev_exchange_rate;
                End If;
    End If;

    RETURN l_return_exchg_rate;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;

END get_fp_cur_details;


PROCEDURE conv_mc_bulk ( p_resource_assignment_id_tab  IN
                             pa_fp_multi_currency_pkg.number_type_tab
                          ,p_start_date_tab              IN
                             pa_fp_multi_currency_pkg.date_type_tab
                          ,p_end_date_tab                IN
                             pa_fp_multi_currency_pkg.date_type_tab
                          ,p_txn_currency_code_tab       IN
                             pa_fp_multi_currency_pkg.char240_type_tab
                          ,p_txn_raw_cost_tab            IN
                             pa_fp_multi_currency_pkg.number_type_tab
                          ,p_txn_burdened_cost_tab       IN
                             pa_fp_multi_currency_pkg.number_type_tab
                          ,p_txn_revenue_tab             IN
                             pa_fp_multi_currency_pkg.number_type_tab
                          ,p_projfunc_currency_code_tab  IN
                             pa_fp_multi_currency_pkg.char240_type_tab
                          ,p_projfunc_cost_rate_type_tab IN
                             pa_fp_multi_currency_pkg.char240_type_tab
                          ,p_projfunc_cost_rate_tab      IN OUT NOCOPY
                             pa_fp_multi_currency_pkg.number_type_tab
                          ,p_projfunc_cost_rate_date_tab IN
                             pa_fp_multi_currency_pkg.date_type_tab
                          ,p_projfunc_rev_rate_type_tab  IN
                             pa_fp_multi_currency_pkg.char240_type_tab
                          ,p_projfunc_rev_rate_tab       IN OUT NOCOPY
                             pa_fp_multi_currency_pkg.number_type_tab
                          ,p_projfunc_rev_rate_date_tab  IN
                             pa_fp_multi_currency_pkg.date_type_tab
                          ,x_projfunc_raw_cost_tab       OUT NOCOPY
                             pa_fp_multi_currency_pkg.number_type_tab
                          ,x_projfunc_burdened_cost_tab  OUT NOCOPY
                             pa_fp_multi_currency_pkg.number_type_tab
                          ,x_projfunc_revenue_tab        OUT NOCOPY
                             pa_fp_multi_currency_pkg.number_type_tab
                          ,x_projfunc_rejection_tab      OUT NOCOPY
                             pa_fp_multi_currency_pkg.char30_type_tab
                          ,p_proj_currency_code_tab      IN
                             pa_fp_multi_currency_pkg.char240_type_tab
                          ,p_proj_cost_rate_type_tab     IN
                             pa_fp_multi_currency_pkg.char240_type_tab
                          ,p_proj_cost_rate_tab          IN OUT NOCOPY
                             pa_fp_multi_currency_pkg.number_type_tab
                          ,p_proj_cost_rate_date_tab     IN
                             pa_fp_multi_currency_pkg.date_type_tab
                          ,p_proj_rev_rate_type_tab      IN
                             pa_fp_multi_currency_pkg.char240_type_tab
                          ,p_proj_rev_rate_tab           IN OUT NOCOPY
                             pa_fp_multi_currency_pkg.number_type_tab
                          ,p_proj_rev_rate_date_tab      IN
                             pa_fp_multi_currency_pkg.date_type_tab
                          ,x_proj_raw_cost_tab           OUT NOCOPY
                             pa_fp_multi_currency_pkg.number_type_tab
                          ,x_proj_burdened_cost_tab      OUT NOCOPY
                             pa_fp_multi_currency_pkg.number_type_tab
                          ,x_proj_revenue_tab            OUT NOCOPY
                             pa_fp_multi_currency_pkg.number_type_tab
                          ,x_proj_rejection_tab          OUT NOCOPY
                             pa_fp_multi_currency_pkg.char30_type_tab
                          ,p_user_validate_flag_tab      IN
                             pa_fp_multi_currency_pkg.char240_type_tab
                           ,p_calling_module              IN
                            VARCHAR2  DEFAULT   'UPDATE_PLAN_TRANSACTION' -- Added for bug#5395732
                          ,x_return_status               OUT NOCOPY  --File.Sql.39 bug 4440895
                             VARCHAR2
                          ,x_msg_count                   OUT NOCOPY  --File.Sql.39 bug 4440895
                             NUMBER
                          ,x_msg_data                    OUT NOCOPY  --File.Sql.39 bug 4440895
                             VARCHAR2) IS

  l_converted_amount  NUMBER;
  l_numerator         NUMBER;
  l_denominator       NUMBER;
  l_rate              NUMBER;
  l_tab_count         NUMBER;
  l_done_flag         VARCHAR2(1);
  l_cached_count      NUMBER;
  l_stage             NUMBER;
  l_debug_mode        VARCHAR2(30);
  l_number            NUMBER;

  l_project_name      pa_projects_all.name%TYPE;
  l_task_name         pa_proj_elements.name%TYPE;
  l_resource_name     pa_resource_list_members.alias%TYPE;
  l_resource_assignment_id pa_resource_assignments.resource_assignment_id%TYPE;

  l_allow_user_rate_type VARCHAR2(1);
  l_call_closest_flag varchar2(1) := 'F'; -- Added for Bug#5395732

  CachedRowTab pa_fp_multi_currency_pkg.cached_row_tab;

    /** Bug fix: 4199085 . No need to use this curosr as we are not adding the error msg to stack
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
            AND prl.resource_list_member_id(+) = pra.resource_list_member_id;
    **/

  BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    --l_debug_mode := NVL(l_debug_mode,'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.init_err_stack('PA_FP_MULTI_CURRENCY_PKG.conv_mc_bulk');
       pa_debug.set_process('PLSQL','LOG',l_debug_mode);
    END IF;

    pa_debug.g_err_stage := 'Entered PA_FP_MULTI_CURRENCY_PKG.conv_mc_bulk';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    l_tab_count := p_txn_currency_code_tab.COUNT;
    l_cached_count := CachedRowTab.COUNT;

    l_stage := 100;
    --hr_utility.trace(to_char(l_stage));

    IF l_tab_count = 0 THEN
       pa_debug.g_err_stage := to_char(l_stage)||': No records selected -- Returning';
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
       END IF;
       RETURN;
    END IF;

       pa_debug.g_err_stage := to_char(l_stage)||': Records selected '||to_char(l_tab_count);
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
       END IF;


    FOR i in p_txn_currency_code_tab.first..p_txn_currency_code_tab.last LOOP

             --hr_utility.trace('p_resource_assignment_id_tab  => '||to_char(p_resource_assignment_id_tab(i)));
             --hr_utility.trace('p_start_date_tab              => '||p_start_date_tab(i));
             --hr_utility.trace('p_end_date_tab                => '||p_end_date_tab(i));
             --hr_utility.trace('p_txn_currency_code_tab       => '||p_txn_currency_code_tab(i));
             --hr_utility.trace('p_txn_raw_cost_tab            => '||to_char(p_txn_raw_cost_tab(i)));
             --hr_utility.trace('p_txn_burdened_cost_tab       => '||to_char(p_txn_burdened_cost_tab(i)));
             --hr_utility.trace('p_txn_revenue_tab             => '||to_char(p_txn_revenue_tab(i)));
             --hr_utility.trace('p_projfunc_currency_code_tab  => '||p_projfunc_currency_code_tab(i));
             --hr_utility.trace('p_projfunc_cost_rate_type_tab => '||p_projfunc_cost_rate_type_tab(i));
             --hr_utility.trace('p_projfunc_cost_rate_tab      => '||p_projfunc_cost_rate_tab(i));
             --hr_utility.trace('p_projfunc_cost_rate_date_tab => '||p_projfunc_cost_rate_date_tab(i));
             --hr_utility.trace('p_projfunc_rev_rate_type_tab  => '||p_projfunc_rev_rate_type_tab(i));
             --hr_utility.trace('p_projfunc_rev_rate_tab       => '||p_projfunc_rev_rate_tab(i));
             --hr_utility.trace('p_projfunc_rev_rate_date_tab  => '||p_projfunc_rev_rate_date_tab(i));
             --hr_utility.trace('p_proj_currency_code_tab      => '||p_proj_currency_code_tab(i));
             --hr_utility.trace('p_proj_cost_rate_type_tab     => '||p_proj_cost_rate_type_tab(i));
             --hr_utility.trace('p_proj_cost_rate_tab          => '||p_proj_cost_rate_tab(i));
             --hr_utility.trace('p_proj_cost_rate_date_tab     => '||p_proj_cost_rate_date_tab(i));
             --hr_utility.trace('p_proj_rev_rate_type_tab      => '||p_proj_rev_rate_type_tab(i));
             --hr_utility.trace('p_proj_rev_rate_tab           => '||p_proj_rev_rate_tab(i));
             --hr_utility.trace('p_proj_rev_rate_date_tab      => '||p_proj_rev_rate_date_tab(i));

         x_projfunc_raw_cost_tab(i)      := NULL;
         x_projfunc_burdened_cost_tab(i) := NULL;
         x_projfunc_revenue_tab(i)       := NULL;
         x_projfunc_rejection_tab(i)     := NULL;
         x_proj_raw_cost_tab(i)          := NULL;
         x_proj_burdened_cost_tab(i)     := NULL;
         x_proj_revenue_tab(i)           := NULL;
         x_proj_rejection_tab(i)         := NULL;

    /* Bug fix:4199085 This cursor is being executed 50000 times. After verifying the code, the
         * the values l_project_name,l_task_name,l_resource_name are not being used any more
         * as we setting the rejection code instead of adding to error msg stack.
     * so commenting out the opening of this cursor
            open get_line_info(p_resource_assignment_id_tab(i));
            l_stage := 110;
            fetch get_line_info into l_project_name, l_task_name, l_resource_name;
            close get_line_info;
    **/

      -- Convert TxnCurrency to ProjectFunctionalCurrency
      l_stage := 200;
      --hr_utility.trace(to_char(l_stage));
      IF p_txn_currency_code_tab(i)       = p_projfunc_currency_code_tab(i) THEN
           l_stage := 300;
           --hr_utility.trace(to_char(l_stage));
           p_projfunc_cost_rate_tab(i)    := NULL;
           x_projfunc_raw_cost_tab(i)     := p_txn_raw_cost_tab(i);
           x_projfunc_burdened_cost_tab(i):= p_txn_burdened_cost_tab(i);
           p_projfunc_rev_rate_tab(i)     := NULL;
           x_projfunc_revenue_tab(i)      := p_txn_revenue_tab(i);

           l_number := x_projfunc_raw_cost_tab(i);
           --hr_utility.trace('x_projfunc_raw_cost_tab(i) = '||to_char(l_number));
           l_number := x_projfunc_burdened_cost_tab(i);
           --hr_utility.trace('x_projfunc_burdened_cost_tab(i) = '||to_char(l_number));
      ELSE
        l_stage := 400;
        --hr_utility.trace(to_char(l_stage));
        -- Convert TxnCost to ProjectFunctional Cost
        IF NVL(p_txn_raw_cost_tab(i),0) <> 0 OR NVL(p_txn_burdened_cost_tab(i),0) <> 0 THEN
          l_stage := 500;
          --hr_utility.trace(to_char(l_stage));
      pa_debug.g_err_stage := to_char(l_stage);
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;

          IF p_projfunc_cost_rate_type_tab(i) = 'User' THEN
             l_stage := 600;
             --hr_utility.trace(to_char(l_stage));
             l_allow_user_rate_type := pa_multi_currency.is_user_rate_type_allowed
                                       ( p_txn_currency_code_tab(i)
                                        ,p_projfunc_currency_code_tab(i)
                                        ,p_projfunc_cost_rate_date_tab(i));
             IF l_allow_user_rate_type = 'Y' THEN
                IF p_projfunc_cost_rate_tab(i) IS NOT NULL THEN
                   l_stage := 700;
                   --hr_utility.trace(to_char(l_stage));
                   x_projfunc_raw_cost_tab(i)      :=  p_txn_raw_cost_tab(i) *
                                                       NVL(p_projfunc_cost_rate_tab(i),1);
                   x_projfunc_burdened_cost_tab(i) := p_txn_burdened_cost_tab(i) *
                                                       NVL(p_projfunc_cost_rate_tab(i),1);
           /* Rounding Enhancements */
           x_projfunc_raw_cost_tab(i) := pa_currency.round_trans_currency_amt1(x_projfunc_raw_cost_tab(i),p_projfunc_currency_code_tab(i));
           x_projfunc_burdened_cost_tab(i) := pa_currency.round_trans_currency_amt1(x_projfunc_burdened_cost_tab(i),p_projfunc_currency_code_tab(i));
                ELSE
                   l_stage := 800;
                   --hr_utility.trace(to_char(l_stage));
                   pa_debug.g_err_stage := to_char(l_stage)||': ProjFunc Cost Rate Not Defined';
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                   END IF;
                   /*
                   pa_utils.add_message
                        ( p_app_short_name => 'PA',
                          p_msg_name       => 'PA_FP_PF_COST_RATE_NOT_DEFINED',
                          p_token1         => 'PROJECT' ,
                          p_value1         => l_project_name,
                          p_token2         => 'TASK',
                          p_value2         => l_task_name,
                          p_token3         => 'RESOURCE_NAME',
                          p_value3         => l_resource_name,
                          p_token4         => 'START_DATE',
                          p_value4         => p_start_date_tab(i));
                   fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                              p_data  => x_msg_data);
                   x_msg_count := fnd_msg_pub.count_msg;
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   */
                   x_projfunc_rejection_tab(i) := 'PA_FP_PF_COST_RATE_NOT_DEFINED';
                END IF;
             ELSE
                l_stage := 810;
                   --hr_utility.trace(to_char(l_stage));
                   pa_debug.g_err_stage := to_char(l_stage)||': Cost Rate type of User not allowed in ProjFunc Currency';
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                   END IF;
                   /*
                   pa_utils.add_message
                        ( p_app_short_name => 'PA',
                          p_msg_name       => 'PA_FP_PFC_USR_RATE_NOT_ALLOWED',
                          p_token1         => 'PROJECT' ,
                          p_value1         => l_project_name,
                          p_token2         => 'TASK',
                          p_value2         => l_task_name,
                          p_token3         => 'RESOURCE_NAME',
                          p_value3         => l_resource_name,
                          p_token4         => 'START_DATE',
                          p_value4         => p_start_date_tab(i),
                          p_token5         => 'TXN_CURRENCY',
                          p_value5         => p_txn_currency_code_tab(i));
                   fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                              p_data  => x_msg_data);
                   x_msg_count := fnd_msg_pub.count_msg;
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   */
                   x_projfunc_rejection_tab(i) := 'PA_FP_PFC_USR_RATE_NOT_ALLOWED';
             END IF;
          ELSE
             l_stage := 900;
             --hr_utility.trace(to_char(l_stage));
          pa_debug.g_err_stage := to_char(l_stage);
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
          END IF;

             l_done_flag := 'N';
             IF nvl(CachedRowTab.COUNT,0) <> 0 THEN
                l_stage := 1000;
                --hr_utility.trace(to_char(l_stage));
                FOR j in CachedRowTab.First..CachedRowTab.Last LOOP
                    IF CachedRowTab(j).from_currency = p_txn_currency_code_tab(i) AND
                       CachedRowTab(j).to_currency = p_projfunc_currency_code_tab(i) AND
                       CachedRowTab(j).rate_date = p_projfunc_cost_rate_date_tab(i) AND
                       CachedRowTab(j).rate_type = p_projfunc_cost_rate_type_tab(i) AND
                       CachedRowTab(j).line_type = 'COST' THEN
                          l_stage := 1100;
                          --hr_utility.trace(to_char(l_stage));
                          p_projfunc_cost_rate_tab(i) := CachedRowTab(j).rate;
                          x_projfunc_raw_cost_tab(i)  := nvl(p_txn_raw_cost_tab(i),0) *
                                                          (round(CachedRowTab(j).numerator/
                                                          CachedRowTab(j).denominator,20));
                          x_projfunc_burdened_cost_tab(i):= nvl(p_txn_burdened_cost_tab(i),0) *
                                                          (round(CachedRowTab(j).numerator/
                                                          CachedRowTab(j).denominator,20));
                      /* Rounding Enhancements */
                          x_projfunc_raw_cost_tab(i) := pa_currency.round_trans_currency_amt1
                            (x_projfunc_raw_cost_tab(i),p_projfunc_currency_code_tab(i));
                          x_projfunc_burdened_cost_tab(i) := pa_currency.round_trans_currency_amt1
                            (x_projfunc_burdened_cost_tab(i),p_projfunc_currency_code_tab(i));

                          l_done_flag := 'Y';
                          EXIT;
                    END IF; -- Cost Rate found
                END LOOP; -- cached cost rates
             END IF; -- CachedRowTab.COUNT > 0
             IF l_done_flag = 'N' THEN
                l_stage := 1200;
                --hr_utility.trace(to_char(l_stage));
         pa_debug.g_err_stage := to_char(l_stage);
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
             END IF;

                IF nvl(p_txn_raw_cost_tab(i),0) <> 0 THEN
                   l_stage := 1300;
                   --hr_utility.trace(to_char(l_stage));
           pa_debug.g_err_stage := 'pfc cost rate date' || p_projfunc_cost_rate_date_tab(i);
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
           END IF;

           pa_debug.g_err_stage := 'pfc cost rate type' || p_projfunc_cost_rate_type_tab(i);
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
           END IF;
                   l_converted_amount  := gl_currency_api.convert_amount_sql
                                          ( X_FROM_CURRENCY   => p_txn_currency_code_tab(i)
                                           ,X_TO_CURRENCY     => p_projfunc_currency_code_tab(i)
                                           ,X_CONVERSION_DATE => p_projfunc_cost_rate_date_tab(i)
                                           ,X_CONVERSION_TYPE => p_projfunc_cost_rate_type_tab(i)
                                           ,X_AMOUNT          => p_txn_raw_cost_tab(i));
                   IF l_converted_amount = -1 THEN
                        /* Added the If block for Bug#5395732 */
                         IF (p_calling_module IN ('BUDGET_GENERATION','FORECAST_GENERATION','UPDATE_PLAN_TRANSACTION')) THEN --Bug 9586291
                               l_converted_amount := GL_CURRENCY_API.convert_closest_amount_sql
                                        (  x_from_currency => p_txn_currency_code_tab(i)
                                          ,x_to_currency => p_projfunc_currency_code_tab(i)
                                          ,x_conversion_date => p_projfunc_cost_rate_date_tab(i)
                                          ,x_conversion_type => p_projfunc_cost_rate_type_tab(i)
                                          ,x_user_rate => 1
                                          ,x_amount => p_txn_raw_cost_tab(i)
                                          ,x_max_roll_days => -1)  ;
                               l_call_closest_flag := 'T';
                         END IF;
                      IF l_converted_amount = -1 THEN

                      l_stage := 1400;
                      --hr_utility.trace(to_char(l_stage));
                      pa_debug.g_err_stage := to_char(l_stage)||': No Exchange Rate exists for the given ProjFunc currency attributes. Please change the Currency attributes';
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                      END IF;
                      /*
                      pa_utils.add_message
                     ( p_app_short_name => 'PA',
                       p_msg_name       => 'PA_FP_NO_PF_EXCH_RATE_EXISTS',
                       p_token1         => 'PROJECT' ,
                       p_value1         => l_project_name,
                       p_token2         => 'TASK',
                       p_value2         => l_task_name,
                       p_token3         => 'RESOURCE_NAME',
                       p_value3         => l_resource_name,
                       p_token4         => 'RATE_DATE',
                       p_value4         => p_projfunc_cost_rate_date_tab(i),
                       p_token5         => 'TXN_CURRENCY',
                       p_value5         => p_txn_currency_code_tab(i));
                       fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                                  p_data  => x_msg_data);
                       x_msg_count := fnd_msg_pub.count_msg;
                       x_return_status := FND_API.G_RET_STS_ERROR;
                       */
                       x_projfunc_rejection_tab(i) := 'PA_FP_NO_PF_EXCH_RATE_EXISTS';
                    END IF;
                   ELSIF l_converted_amount = -2 THEN
                      l_stage := 1500;
                      --hr_utility.trace(to_char(l_stage));
                      pa_debug.g_err_stage := to_char(l_stage)||'The Currency you have entered is not valid. Please re-enter the Currency';
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                      END IF;
                      /*
                      pa_utils.add_message
                     ( p_app_short_name => 'PA',
                       p_msg_name       => 'PA_FP_CURR_NOT_VALID',
                       p_token1         => 'PROJECT' ,
                       p_value1         => l_project_name,
                       p_token2         => 'TASK',
                       p_value2         => l_task_name,
                       p_token3         => 'RESOURCE_NAME',
                       p_value3         => l_resource_name,
                       p_token4         => 'RATE_DATE',
                       p_value4         => p_projfunc_cost_rate_date_tab(i),
                       p_token5         => 'TXN_CURRENCY',
                       p_value5         => p_txn_currency_code_tab(i));
                       fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                                  p_data  => x_msg_data);
                       x_msg_count := fnd_msg_pub.count_msg;
                       x_return_status := FND_API.G_RET_STS_ERROR;
                      */
                      x_projfunc_rejection_tab(i) := 'PA_FP_CURR_NOT_VALID';
                    --Commented for Bug#5395732                   ELSE
                   END IF; -- Added for Bug#5395732

                      l_stage := 1700;
              pa_debug.g_err_stage := to_char(l_stage);
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                  END IF;
                   IF l_converted_amount <> -1 AND l_converted_amount <> -2 THEN -- Added for Bug#5395732
                      --hr_utility.trace(to_char(l_stage));
                     IF l_call_closest_flag = 'T' THEN -- Added for Bug#5395732
                                 l_numerator :=  GL_CURRENCY_API.get_closest_rate_numerator_sql
                                          ( p_txn_currency_code_tab(i)
                                           ,p_projfunc_currency_code_tab(i)
                                           ,p_projfunc_cost_rate_date_tab(i)
                                           ,p_projfunc_cost_rate_type_tab(i)
                                           ,-1);
                     ELSE
                          l_numerator   := gl_currency_api.get_rate_numerator_sql
                                           ( X_FROM_CURRENCY   => p_txn_currency_code_tab(i)
                                            ,X_TO_CURRENCY     => p_projfunc_currency_code_tab(i)
                                            ,X_CONVERSION_DATE => p_projfunc_cost_rate_date_tab(i)
                                            ,X_CONVERSION_TYPE => p_projfunc_cost_rate_type_tab(i));

                          l_stage := 1800;
                     END IF;
                      --hr_utility.trace(to_char(l_stage));
                       IF l_call_closest_flag = 'T' THEN -- Added for Bug#5395732
                                 l_denominator :=  GL_CURRENCY_API.get_closest_rate_denom_sql
                                          ( p_txn_currency_code_tab(i)
                                           ,p_projfunc_currency_code_tab(i)
                                           ,p_projfunc_cost_rate_date_tab(i)
                                           ,p_projfunc_cost_rate_type_tab(i)
                                           ,-1);
                         ELSE
                          l_denominator := gl_currency_api.get_rate_denominator_sql
                                           ( X_FROM_CURRENCY   => p_txn_currency_code_tab(i)
                                            ,X_TO_CURRENCY     => p_projfunc_currency_code_tab(i)
                                            ,X_CONVERSION_DATE => p_projfunc_cost_rate_date_tab(i)
                                            ,X_CONVERSION_TYPE => p_projfunc_cost_rate_type_tab(i));
                        END IF;

                      IF l_numerator > 0 AND l_denominator > 0 THEN
                      l_stage := 1900;
                      --hr_utility.trace(to_char(l_stage));
                         p_projfunc_cost_rate_tab(i) := round(l_numerator/l_denominator,20);
                         l_stage := 1950;
                         --hr_utility.trace(to_char(l_stage));
                         x_projfunc_raw_cost_tab(i)  := p_txn_raw_cost_tab(i) *
                                                        p_projfunc_cost_rate_tab(i);
                        /* Rounding Enhancements */
                        x_projfunc_raw_cost_tab(i) := pa_currency.round_trans_currency_amt1
                                                (x_projfunc_raw_cost_tab(i),p_projfunc_currency_code_tab(i));
                      END IF;

                      IF nvl(p_txn_burdened_cost_tab(i),0) <> 0 THEN
                      l_stage := 2000;
                      --hr_utility.trace(to_char(l_stage));
                         x_projfunc_burdened_cost_tab(i) := (nvl(p_txn_burdened_cost_tab(i),0) * p_projfunc_cost_rate_tab(i));
                        /* Rounding Enhancements */
                        x_projfunc_burdened_cost_tab(i) := pa_currency.round_trans_currency_amt1
                                                (x_projfunc_burdened_cost_tab(i),p_projfunc_currency_code_tab(i));
                      END IF;

                      l_stage := 2100;
                      --hr_utility.trace(to_char(l_stage));
                      l_cached_count := nvl(CachedRowTab.count,0) + 1;
                      CachedRowTab(l_cached_count).from_currency := p_txn_currency_code_tab(i);
                      CachedRowTab(l_cached_count).to_currency   := p_projfunc_currency_code_tab(i);
                      CachedRowTab(l_cached_count).numerator     := l_numerator;
                      CachedRowTab(l_cached_count).denominator   := l_denominator;
                      CachedRowTab(l_cached_count).rate          := p_projfunc_cost_rate_tab(i);
                      CachedRowTab(l_cached_count).rate_date     := p_projfunc_cost_rate_date_tab(i);
                      CachedRowTab(l_cached_count).rate_type     := p_projfunc_cost_rate_type_tab(i);
                      CachedRowTab(l_cached_count).line_type     := 'COST';
                      --Commented for Bug#5395732                   END IF; -- l_converted_amount values
                     END IF; -- Added for Bug#5395732
                     l_call_closest_flag := 'N'; -- Added for Bug#5395732 Resetting.

                ELSE -- Raw Cost IS NULL or 0
                   l_stage := 2200;
                   --hr_utility.trace(to_char(l_stage));
            pa_debug.g_err_stage := to_char(l_stage);
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                END IF;

           pa_debug.g_err_stage := 'pfc cost rate date' || p_projfunc_cost_rate_date_tab(i);
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
           END IF;

           pa_debug.g_err_stage := 'pfc cost rate type' || p_projfunc_cost_rate_type_tab(i);
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
           END IF;

                   l_converted_amount  := gl_currency_api.convert_amount_sql
                                          ( X_FROM_CURRENCY   => p_txn_currency_code_tab(i)
                                           ,X_TO_CURRENCY     => p_projfunc_currency_code_tab(i)
                                           ,X_CONVERSION_DATE => p_projfunc_cost_rate_date_tab(i)
                                           ,X_CONVERSION_TYPE => p_projfunc_cost_rate_type_tab(i)
                                           ,X_AMOUNT          => p_txn_burdened_cost_tab(i));
                   IF l_converted_amount = -1 THEN
                        /* Added the If block for Bug#5395732 */
                         IF (p_calling_module IN ('BUDGET_GENERATION','FORECAST_GENERATION','UPDATE_PLAN_TRANSACTION')) THEN  --Bug 9586291
                               l_converted_amount := GL_CURRENCY_API.convert_closest_amount_sql
                                        (  x_from_currency => p_txn_currency_code_tab(i)
                                          ,x_to_currency => p_projfunc_currency_code_tab(i)
                                          ,x_conversion_date => p_projfunc_cost_rate_date_tab(i)
                                          ,x_conversion_type => p_projfunc_cost_rate_type_tab(i)
                                          ,x_user_rate => 1
                                          ,x_amount => p_txn_burdened_cost_tab(i)
                                          ,x_max_roll_days => -1)  ;
                               l_call_closest_flag := 'T';
                         END IF;
                     IF l_converted_amount = -1 THEN
                      l_stage := 2300;
                      --hr_utility.trace(to_char(l_stage));
                      pa_debug.g_err_stage := to_char(l_stage)||': No Exchange Rate exists for the given ProjFunc currency attributes. Please change the Currency attributes';
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                      END IF;
                      /*
                      pa_utils.add_message
                     ( p_app_short_name => 'PA',
                       p_msg_name       => 'PA_FP_NO_PF_EXCH_RATE_EXISTS',
                       p_token1         => 'PROJECT' ,
                       p_value1         => l_project_name,
                       p_token2         => 'TASK',
                       p_value2         => l_task_name,
                       p_token3         => 'RESOURCE_NAME',
                       p_value3         => l_resource_name,
                       p_token4         => 'RATE_DATE',
                       p_value4         => p_projfunc_cost_rate_date_tab(i),
                       p_token5         => 'TXN_CURRENCY',
                       p_value5         => p_txn_currency_code_tab(i));
                       fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                                  p_data  => x_msg_data);
                       x_msg_count := fnd_msg_pub.count_msg;
                       x_return_status := FND_API.G_RET_STS_ERROR;
                      */
                      x_projfunc_rejection_tab(i) := 'PA_FP_NO_PF_EXCH_RATE_EXISTS';
                     END IF;

                   ELSIF l_converted_amount = -2 THEN
                      l_stage := 2400;
                      --hr_utility.trace(to_char(l_stage));
                      pa_debug.g_err_stage := to_char(l_stage)||'The Currency you have entered is not valid. Please re-enter the Currency';
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                      END IF;
                      /*
                      pa_utils.add_message
                     ( p_app_short_name => 'PA',
                       p_msg_name       => 'PA_FP_CURR_NOT_VALID',
                       p_token1         => 'PROJECT' ,
                       p_value1         => l_project_name,
                       p_token2         => 'TASK',
                       p_value2         => l_task_name,
                       p_token3         => 'RESOURCE_NAME',
                       p_value3         => l_resource_name,
                       p_token4         => 'RATE_DATE',
                       p_value4         => p_projfunc_cost_rate_date_tab(i),
                       p_token5         => 'TXN_CURRENCY',
                       p_value5         => p_txn_currency_code_tab(i));
                       fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                                  p_data  => x_msg_data);
                       x_msg_count := fnd_msg_pub.count_msg;
                       x_return_status := FND_API.G_RET_STS_ERROR;
                      */
                      x_projfunc_rejection_tab(i) := 'PA_FP_CURR_NOT_VALID';

                      --Commented for Bug#5395732                   ELSE
                      END IF; -- Added for Bug#5395732

                      l_stage := 2600;
                      --hr_utility.trace(to_char(l_stage));
                  IF l_converted_amount <> -1 AND l_converted_amount <> -2 THEN -- Added for Bug#5395732
                         IF l_call_closest_flag = 'T' THEN -- Added for Bug#5395732
                                 l_numerator :=  GL_CURRENCY_API.get_closest_rate_numerator_sql
                                          ( p_txn_currency_code_tab(i)
                                           ,p_projfunc_currency_code_tab(i)
                                           ,p_projfunc_cost_rate_date_tab(i)
                                           ,p_projfunc_cost_rate_type_tab(i)
                                           ,-1);
                         ELSE
                          l_numerator   := gl_currency_api.get_rate_numerator_sql
                                           ( X_FROM_CURRENCY   => p_txn_currency_code_tab(i)
                                            ,X_TO_CURRENCY     => p_projfunc_currency_code_tab(i)
                                            ,X_CONVERSION_DATE => p_projfunc_cost_rate_date_tab(i)
                                            ,X_CONVERSION_TYPE => p_projfunc_cost_rate_type_tab(i));
                        END IF;
                      l_stage := 2700;
                      --hr_utility.trace(to_char(l_stage));
                      IF l_call_closest_flag = 'T' THEN -- Added for Bug#5395732
                                 l_denominator :=  GL_CURRENCY_API.get_closest_rate_denom_sql
                                          ( p_txn_currency_code_tab(i)
                                           ,p_projfunc_currency_code_tab(i)
                                           ,p_projfunc_cost_rate_date_tab(i)
                                           ,p_projfunc_cost_rate_type_tab(i)
                                           ,-1);
                         ELSE
                          l_denominator := gl_currency_api.get_rate_denominator_sql
                                           ( X_FROM_CURRENCY   => p_txn_currency_code_tab(i)
                                            ,X_TO_CURRENCY     => p_projfunc_currency_code_tab(i)
                                            ,X_CONVERSION_DATE => p_projfunc_cost_rate_date_tab(i)
                                            ,X_CONVERSION_TYPE => p_projfunc_cost_rate_type_tab(i));
                        END IF;

                      IF l_numerator > 0 AND l_denominator > 0 THEN
                      l_stage := 2800;
                      --hr_utility.trace(to_char(l_stage));
                         p_projfunc_cost_rate_tab(i) := round(l_numerator/l_denominator,20);
                      l_stage := 2850;
                      --hr_utility.trace(to_char(l_stage));
                      x_projfunc_burdened_cost_tab(i)  := p_txn_burdened_cost_tab(i) *
                                                          p_projfunc_cost_rate_tab(i);
            /* Rounding Enhancements */
                        x_projfunc_burdened_cost_tab(i) := pa_currency.round_trans_currency_amt1
                                                (x_projfunc_burdened_cost_tab(i),p_projfunc_currency_code_tab(i));
                      END IF;

                      l_stage := 2900;
                      --hr_utility.trace(to_char(l_stage));
                      l_cached_count := nvl(CachedRowTab.count,0) + 1;
                      CachedRowTab(l_cached_count).from_currency := p_txn_currency_code_tab(i);
                      CachedRowTab(l_cached_count).to_currency   := p_projfunc_currency_code_tab(i);
                      CachedRowTab(l_cached_count).numerator     := l_numerator;
                      CachedRowTab(l_cached_count).denominator   := l_denominator;
                      CachedRowTab(l_cached_count).rate          := p_projfunc_cost_rate_tab(i);
                      CachedRowTab(l_cached_count).rate_date     := p_projfunc_cost_rate_date_tab(i);
                      CachedRowTab(l_cached_count).rate_type     := p_projfunc_cost_rate_type_tab(i);
                      CachedRowTab(l_cached_count).line_type     := 'COST';
                      --Commented for Bug#5395732                   END IF; -- l_converted_amount values
                     END IF; -- Added for Bug#5395732
                     l_call_closest_flag := 'N'; -- Added for Bug#5395732 Resetting.
                END IF; -- Raw cost is NULL or 0
             END IF; -- Rate not found in Cache
          END IF; -- rate_type <> 'User'
        END IF; -- txn_raw or Burdened Cost <> 0


        l_stage := 3000;
        --hr_utility.trace(to_char(l_stage));
        -- Convert TxnRevenue to ProjectFunctionalRevenue
        IF NVL(p_txn_revenue_tab(i),0) <> 0 THEN
          l_stage := 3100;
          --hr_utility.trace(to_char(l_stage));
          IF p_projfunc_rev_rate_type_tab(i) = 'User' THEN
             l_stage := 3200;
             --hr_utility.trace(to_char(l_stage));
             l_allow_user_rate_type := pa_multi_currency.is_user_rate_type_allowed
                                       ( p_txn_currency_code_tab(i)
                                        ,p_projfunc_currency_code_tab(i)
                                        ,p_projfunc_rev_rate_date_tab(i));
             IF l_allow_user_rate_type = 'Y' THEN
                IF p_projfunc_rev_rate_tab(i) IS NOT NULL THEN
                   x_projfunc_revenue_tab(i) :=  p_txn_revenue_tab(i) *
                                                 NVL(p_projfunc_rev_rate_tab(i),1);
           /* Rounding Enhancements */
                   x_projfunc_revenue_tab(i) := pa_currency.round_trans_currency_amt1
                            (x_projfunc_revenue_tab(i),p_projfunc_currency_code_tab(i));
                ELSE
                   pa_debug.g_err_stage := to_char(l_stage)||': ProjFunc Revenue Rate Not Defined';
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                   END IF;
                   /*
                   pa_utils.add_message
                        ( p_app_short_name => 'PA',
                          p_msg_name       => 'PA_FP_PF_REV_RATE_NOT_DEFINED',
                          p_token1         => 'PROJECT' ,
                          p_value1         => l_project_name,
                          p_token2         => 'TASK',
                          p_value2         => l_task_name,
                          p_token3         => 'RESOURCE_NAME',
                          p_value3         => l_resource_name,
                          p_token4         => 'START_DATE',
                          p_value4         => p_start_date_tab(i));
                   fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                              p_data  => x_msg_data);
                   x_msg_count := fnd_msg_pub.count_msg;
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   */
                   x_projfunc_rejection_tab(i) := 'PA_FP_PF_REV_RATE_NOT_DEFINED';
                END IF;
              ELSE
                l_stage := 3210;
                   --hr_utility.trace(to_char(l_stage));
                   pa_debug.g_err_stage := to_char(l_stage)||': Revenue Rate type of User not allowed in ProjFunc Currency';
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                   END IF;
                   /*
                   pa_utils.add_message
                        ( p_app_short_name => 'PA',
                          p_msg_name       => 'PA_FP_PFR_USR_RATE_NOT_ALLOWED',
                          p_token1         => 'PROJECT' ,
                          p_value1         => l_project_name,
                          p_token2         => 'TASK',
                          p_value2         => l_task_name,
                          p_token3         => 'RESOURCE_NAME',
                          p_value3         => l_resource_name,
                          p_token4         => 'START_DATE',
                          p_value4         => p_start_date_tab(i),
                          p_token5         => 'TXN_CURRENCY',
                          p_value5         => p_txn_currency_code_tab(i));
                   fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                              p_data  => x_msg_data);
                   x_msg_count := fnd_msg_pub.count_msg;
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   */
                   x_projfunc_rejection_tab(i) := 'PA_FP_PFR_USR_RATE_NOT_ALLOWED';
             END IF;
          ELSE
             l_stage := 3300;
             --hr_utility.trace(to_char(l_stage));
             l_done_flag := 'N';
             IF nvl(CachedRowTab.COUNT,0) <> 0 THEN
                l_stage := 3400;
                --hr_utility.trace(to_char(l_stage));
                FOR j in CachedRowTab.First..CachedRowTab.Last LOOP
                    IF CachedRowTab(j).from_currency = p_txn_currency_code_tab(i) AND
                       CachedRowTab(j).to_currency = p_projfunc_currency_code_tab(i) AND
                       CachedRowTab(j).rate_date = p_projfunc_rev_rate_date_tab(i) AND
                       CachedRowTab(j).rate_type = p_projfunc_rev_rate_type_tab(i) AND
                       CachedRowTab(j).line_type = 'REVENUE' THEN
                          l_stage := 3500;
                          --hr_utility.trace(to_char(l_stage));
                          p_projfunc_rev_rate_tab(i) := CachedRowTab(j).rate;
                          x_projfunc_revenue_tab(i)  := nvl(p_txn_revenue_tab(i),0) *
                                                          (round(CachedRowTab(j).numerator/
                                                          CachedRowTab(j).denominator,20));
              /* Rounding Enhancements */
                      x_projfunc_revenue_tab(i) := pa_currency.round_trans_currency_amt1
                                                        (x_projfunc_revenue_tab(i),p_projfunc_currency_code_tab(i));
                          l_done_flag := 'Y';
                          EXIT;
                    END IF; -- RevenueRateFound
                END LOOP; -- CachedRevenueRates
             END IF; -- CachedRowTab.COUNT > 0
             IF l_done_flag = 'N' THEN
                   l_stage := 3600;
                   --hr_utility.trace(to_char(l_stage));
                   l_converted_amount  := gl_currency_api.convert_amount_sql
                                          ( X_FROM_CURRENCY   => p_txn_currency_code_tab(i)
                                           ,X_TO_CURRENCY     => p_projfunc_currency_code_tab(i)
                                           ,X_CONVERSION_DATE => p_projfunc_rev_rate_date_tab(i)
                                           ,X_CONVERSION_TYPE => p_projfunc_rev_rate_type_tab(i)
                                           ,X_AMOUNT          => p_txn_revenue_tab(i));

                   IF l_converted_amount = -1 THEN
                        /* Added the If block for Bug#5395732 */
                         IF (p_calling_module IN ('BUDGET_GENERATION','FORECAST_GENERATION','UPDATE_PLAN_TRANSACTION')) THEN  --Bug 9586291
                               l_converted_amount := GL_CURRENCY_API.convert_closest_amount_sql
                                        (  x_from_currency => p_txn_currency_code_tab(i)
                                          ,x_to_currency => p_projfunc_currency_code_tab(i)
                                          ,x_conversion_date => p_projfunc_rev_rate_date_tab(i)
                                          ,x_conversion_type => p_projfunc_rev_rate_type_tab(i)
                                          ,x_user_rate => 1
                                          ,x_amount => p_txn_revenue_tab(i)
                                          ,x_max_roll_days => -1)  ;
                               l_call_closest_flag := 'T';
                         END IF;
                     IF l_converted_amount = -1 THEN
                      l_stage := 3700;
                      --hr_utility.trace(to_char(l_stage));
                      pa_debug.g_err_stage := to_char(l_stage)||': No Exchange Rate exists for the given Projfunc currency attributes. Please change the Currency attributes';
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                      END IF;
                      /*
                      pa_utils.add_message
                     ( p_app_short_name => 'PA',
                       p_msg_name       => 'PA_FP_NO_PF_EXCH_RATE_EXISTS',
                       p_token1         => 'PROJECT' ,
                       p_value1         => l_project_name,
                       p_token2         => 'TASK',
                       p_value2         => l_task_name,
                       p_token3         => 'RESOURCE_NAME',
                       p_value3         => l_resource_name,
                       p_token4         => 'RATE_DATE',
                       p_value4         => p_projfunc_rev_rate_date_tab(i),
                       p_token5         => 'TXN_CURRENCY',
                       p_value5         => p_txn_currency_code_tab(i));
                       fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                                  p_data  => x_msg_data);
                       x_msg_count := fnd_msg_pub.count_msg;
                       x_return_status := FND_API.G_RET_STS_ERROR;
                       */
                       x_projfunc_rejection_tab(i) := 'PA_FP_NO_PF_EXCH_RATE_EXISTS';
                     END IF;
                   ELSIF l_converted_amount = -2 THEN
                      l_stage := 3800;
                      --hr_utility.trace(to_char(l_stage));
                      pa_debug.g_err_stage := to_char(l_stage)||'The Currency you have entered is not valid. Please re-enter the Currency';
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                      END IF;
                      /*
                      pa_utils.add_message
                     ( p_app_short_name => 'PA',
                       p_msg_name       => 'PA_FP_CURR_NOT_VALID',
                       p_token1         => 'PROJECT' ,
                       p_value1         => l_project_name,
                       p_token2         => 'TASK',
                       p_value2         => l_task_name,
                       p_token3         => 'RESOURCE_NAME',
                       p_value3         => l_resource_name,
                       p_token4         => 'RATE_DATE',
                       p_value4         => p_projfunc_rev_rate_date_tab(i),
                       p_token5         => 'TXN_CURRENCY',
                       p_value5         => p_txn_currency_code_tab(i));
                       fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                                  p_data  => x_msg_data);
                       x_msg_count := fnd_msg_pub.count_msg;
                       x_return_status := FND_API.G_RET_STS_ERROR;
                      */
                      x_projfunc_rejection_tab(i) := 'PA_FP_CURR_NOT_VALID';

                      -- Commented for Bug#5395732                   ELSE
                      END IF; -- Added for Bug#5395732

                      l_stage := 4000;
                      --hr_utility.trace(to_char(l_stage));
                      IF l_converted_amount <> -1 AND l_converted_amount <> -2 THEN -- Added for Bug#5395732
                             IF l_call_closest_flag = 'T' THEN -- Added for Bug#5395732
                                     l_numerator :=  GL_CURRENCY_API.get_closest_rate_numerator_sql
                                              ( p_txn_currency_code_tab(i)
                                               ,p_projfunc_currency_code_tab(i)
                                               ,p_projfunc_rev_rate_date_tab(i)
                                               ,p_projfunc_rev_rate_type_tab(i)
                                               ,-1);
                             ELSE

                              l_numerator   := gl_currency_api.get_rate_numerator_sql
                                               ( X_FROM_CURRENCY   => p_txn_currency_code_tab(i)
                                                ,X_TO_CURRENCY     => p_projfunc_currency_code_tab(i)
                                                ,X_CONVERSION_DATE => p_projfunc_rev_rate_date_tab(i)
                                                ,X_CONVERSION_TYPE => p_projfunc_rev_rate_type_tab(i));
                             END IF;
                      l_stage := 4100;
                      --hr_utility.trace(to_char(l_stage));
                       IF l_call_closest_flag = 'T' THEN -- Added for Bug#5395732
                                 l_denominator :=  GL_CURRENCY_API.get_closest_rate_denom_sql
                                          ( p_txn_currency_code_tab(i)
                                           ,p_projfunc_currency_code_tab(i)
                                           ,p_projfunc_rev_rate_date_tab(i)
                                           ,p_projfunc_rev_rate_type_tab(i)
                                           ,-1);
                         ELSE
                          l_denominator := gl_currency_api.get_rate_denominator_sql
                                           ( X_FROM_CURRENCY   => p_txn_currency_code_tab(i)
                                            ,X_TO_CURRENCY     => p_projfunc_currency_code_tab(i)
                                            ,X_CONVERSION_DATE => p_projfunc_rev_rate_date_tab(i)
                                            ,X_CONVERSION_TYPE => p_projfunc_rev_rate_type_tab(i));
                        END IF;
                      IF l_numerator > 0 AND l_denominator > 0 THEN
                         l_stage := 4200;
                         --hr_utility.trace(to_char(l_stage));
                         p_projfunc_rev_rate_tab(i) := round(l_numerator/l_denominator,20);
                         l_stage := 4250;
                         --hr_utility.trace(to_char(l_stage));
                         x_projfunc_revenue_tab(i)  := p_txn_revenue_tab(i) *
                                                       p_projfunc_rev_rate_tab(i);
             /* Rounding Enhancements */
                     x_projfunc_revenue_tab(i) := pa_currency.round_trans_currency_amt1
                                                        (x_projfunc_revenue_tab(i),p_projfunc_currency_code_tab(i));
                      END IF;

                      l_stage := 4300;
                      --hr_utility.trace(to_char(l_stage));
                      l_cached_count := nvl(CachedRowTab.count,0) + 1;
                      CachedRowTab(l_cached_count).from_currency := p_txn_currency_code_tab(i);
                      CachedRowTab(l_cached_count).to_currency   := p_projfunc_currency_code_tab(i);
                      CachedRowTab(l_cached_count).numerator     := l_numerator;
                      CachedRowTab(l_cached_count).denominator   := l_denominator;
                      CachedRowTab(l_cached_count).rate          := p_projfunc_rev_rate_tab(i);
                      CachedRowTab(l_cached_count).rate_date     := p_projfunc_rev_rate_date_tab(i);
                      CachedRowTab(l_cached_count).rate_type     := p_projfunc_rev_rate_type_tab(i);
                      CachedRowTab(l_cached_count).line_type     := 'REVENUE';
                      -- Commented for Bug#5395732                   END IF; -- l_converted_amount values
                     END IF; -- Added for Bug#5395732
                    l_call_closest_flag := 'N'; -- Added for Bug#5395732 Resetting.
             END IF; -- RevenueRate not found in Cache
          END IF; -- RevenueRateType <> 'User'
        END IF; -- TxnRevenue <> 0
      END IF; -- TxnCurrencyCode <> ProjFuncCurrencyCode

      l_stage := 4400;
      --hr_utility.trace(to_char(l_stage));
      -- Convert TxnCurrency to ProjectCurrency

      IF p_txn_currency_code_tab(i)       = p_proj_currency_code_tab(i) THEN
           l_stage := 4500;
           --hr_utility.trace(to_char(l_stage));
           p_proj_cost_rate_tab(i)    := NULL;
           x_proj_raw_cost_tab(i)     := p_txn_raw_cost_tab(i);
           x_proj_burdened_cost_tab(i):= p_txn_burdened_cost_tab(i);
           p_proj_rev_rate_tab(i)     := NULL;
           x_proj_revenue_tab(i)      := p_txn_revenue_tab(i);
      ELSE
        l_stage := 4600;
        --hr_utility.trace(to_char(l_stage));
        -- Convert TxnCost to ProjectCost
        IF NVL(p_txn_raw_cost_tab(i),0) <> 0 OR NVL(p_txn_burdened_cost_tab(i),0) <> 0 THEN
          l_stage := 4700;
          --hr_utility.trace(to_char(l_stage));
          IF p_proj_cost_rate_type_tab(i) = 'User' THEN
             l_stage := 4800;
             --hr_utility.trace(to_char(l_stage));
             l_allow_user_rate_type := pa_multi_currency.is_user_rate_type_allowed
                                       ( p_txn_currency_code_tab(i)
                                        ,p_proj_currency_code_tab(i)
                                        ,p_proj_cost_rate_date_tab(i));
             IF l_allow_user_rate_type = 'Y' THEN
                IF p_proj_cost_rate_tab(i) IS NOT NULL THEN
                   l_stage := 4900;
                   --hr_utility.trace(to_char(l_stage));
                   x_proj_raw_cost_tab(i)      :=  p_txn_raw_cost_tab(i) *
                                                       NVL(p_proj_cost_rate_tab(i),1);
                   x_proj_burdened_cost_tab(i) := p_txn_burdened_cost_tab(i) *
                                                       NVL(p_proj_cost_rate_tab(i),1);
           /* Rounding Enhancements */
                   x_proj_raw_cost_tab(i) := pa_currency.round_trans_currency_amt1
                                                        (x_proj_raw_cost_tab(i),p_proj_currency_code_tab(i));
           x_proj_burdened_cost_tab(i) := pa_currency.round_trans_currency_amt1
                                                        (x_proj_burdened_cost_tab(i),p_proj_currency_code_tab(i));
                ELSE
                   l_stage := 5000;
                   --hr_utility.trace(to_char(l_stage));
                   pa_debug.g_err_stage := to_char(l_stage)||': Project Cost Rate Not Defined';
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                   END IF;
                   /*
                   pa_utils.add_message
                        ( p_app_short_name => 'PA',
                          p_msg_name       => 'PA_FP_PJ_COST_RATE_NOT_DEFINED',
                          p_token1         => 'PROJECT' ,
                          p_value1         => l_project_name,
                          p_token2         => 'TASK',
                          p_value2         => l_task_name,
                          p_token3         => 'RESOURCE_NAME',
                          p_value3         => l_resource_name,
                          p_token4         => 'START_DATE',
                          p_value4         => p_start_date_tab(i));
                   fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                              p_data  => x_msg_data);
                   x_msg_count := fnd_msg_pub.count_msg;
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   */
                   x_proj_rejection_tab(i) := 'PA_FP_PJ_COST_RATE_NOT_DEFINED';
                END IF;
            ELSE
                l_stage := 810;
                   --hr_utility.trace(to_char(l_stage));
                   pa_debug.g_err_stage := to_char(l_stage)||': Cost Rate type of User not allowed in Project Currency';
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                   END IF;
                   /*
                   pa_utils.add_message
                        ( p_app_short_name => 'PA',
                          p_msg_name       => 'PA_FP_PJC_USR_RATE_NOT_ALLOWED',
                          p_token1         => 'PROJECT' ,
                          p_value1         => l_project_name,
                          p_token2         => 'TASK',
                          p_value2         => l_task_name,
                          p_token3         => 'RESOURCE_NAME',
                          p_value3         => l_resource_name,
                          p_token4         => 'START_DATE',
                          p_value4         => p_start_date_tab(i),
                          p_token5         => 'TXN_CURRENCY',
                          p_value5         => p_txn_currency_code_tab(i));
                   fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                              p_data  => x_msg_data);
                   x_msg_count := fnd_msg_pub.count_msg;
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   */
                   x_proj_rejection_tab(i) := 'PA_FP_PJC_USR_RATE_NOT_ALLOWED';
             END IF;
          ELSE
             l_stage := 5100;
             --hr_utility.trace(to_char(l_stage));
             l_done_flag := 'N';
             IF nvl(CachedRowTab.COUNT,0) <> 0 THEN
                l_stage := 5200;
                --hr_utility.trace(to_char(l_stage));
                FOR j in CachedRowTab.First..CachedRowTab.Last LOOP
                    IF CachedRowTab(j).from_currency = p_txn_currency_code_tab(i) AND
                       CachedRowTab(j).to_currency = p_proj_currency_code_tab(i) AND
                       CachedRowTab(j).rate_date = p_proj_cost_rate_date_tab(i) AND
                       CachedRowTab(j).rate_type = p_proj_cost_rate_type_tab(i) AND
                       CachedRowTab(j).line_type = 'COST' THEN
                          l_stage := 5300;
                          --hr_utility.trace(to_char(l_stage));
                          p_proj_cost_rate_tab(i) := CachedRowTab(j).rate;
                          x_proj_raw_cost_tab(i)  := nvl(p_txn_raw_cost_tab(i),0) *
                                                          (round(CachedRowTab(j).numerator/
                                                          CachedRowTab(j).denominator,20));
                          x_proj_burdened_cost_tab(i):= nvl(p_txn_burdened_cost_tab(i),0) *
                                                          (round(CachedRowTab(j).numerator/
                                                          CachedRowTab(j).denominator,20));
              /* Rounding Enhancements */
                      x_proj_raw_cost_tab(i) := pa_currency.round_trans_currency_amt1
                                                        (x_proj_raw_cost_tab(i),p_proj_currency_code_tab(i));
                      x_proj_burdened_cost_tab(i) := pa_currency.round_trans_currency_amt1
                                                        (x_proj_burdened_cost_tab(i),p_proj_currency_code_tab(i));
                          l_done_flag := 'Y';
                          EXIT;
                    END IF; -- Cost Rate found
                END LOOP; -- cached cost rates
             END IF; -- CachedRowTab.COUNT > 0
             IF l_done_flag = 'N' THEN
                l_stage := 5400;
                --hr_utility.trace(to_char(l_stage));
                IF nvl(p_txn_raw_cost_tab(i),0) <> 0 THEN
                   l_stage := 5500;
                   --hr_utility.trace(to_char(l_stage));
                   l_converted_amount  := gl_currency_api.convert_amount_sql
                                          ( X_FROM_CURRENCY   => p_txn_currency_code_tab(i)
                                           ,X_TO_CURRENCY     => p_proj_currency_code_tab(i)
                                           ,X_CONVERSION_DATE => p_proj_cost_rate_date_tab(i)
                                           ,X_CONVERSION_TYPE => p_proj_cost_rate_type_tab(i)
                                           ,X_AMOUNT          => p_txn_raw_cost_tab(i));

                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.g_err_stage := '5500.1 x_from_currency '|| p_txn_currency_code_tab(i) || 'x_to_currency ' || p_proj_currency_code_tab(i);
                      pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                      pa_debug.g_err_stage := 'x_conversion_date ' || p_proj_cost_rate_date_tab(i) || 'x_conversion_type ' || p_proj_cost_rate_type_tab(i);
                      pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                      pa_debug.g_err_stage := 'X_AMOUNT ' || p_txn_raw_cost_tab(i) || 'l_converted_amount ' || l_converted_amount;
                      pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                   END IF;
                   IF l_converted_amount = -1 THEN
                        /* Added the If block for Bug#5395732 */
                         IF (p_calling_module IN ('BUDGET_GENERATION','FORECAST_GENERATION','UPDATE_PLAN_TRANSACTION')) THEN  --Bug 9586291
                               l_converted_amount := GL_CURRENCY_API.convert_closest_amount_sql
                                        (  x_from_currency => p_txn_currency_code_tab(i)
                                          ,x_to_currency => p_proj_currency_code_tab(i)
                                          ,x_conversion_date => p_proj_cost_rate_date_tab(i)
                                          ,x_conversion_type => p_proj_cost_rate_type_tab(i)
                                          ,x_user_rate => 1
                                          ,x_amount => p_txn_raw_cost_tab(i)
                                          ,x_max_roll_days => -1)  ;
                               l_call_closest_flag := 'T';
                               IF P_PA_DEBUG_MODE = 'Y' THEN
                                  pa_debug.g_err_stage := '5500.2 x_from_currency '|| p_txn_currency_code_tab(i) || 'x_to_currency ' || p_proj_currency_code_tab(i);
                                  pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                                  pa_debug.g_err_stage := 'x_conversion_date ' || p_proj_cost_rate_date_tab(i) || 'x_conversion_type ' || p_proj_cost_rate_type_tab(i);
                                  pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                                  pa_debug.g_err_stage := 'X_AMOUNT ' || p_txn_raw_cost_tab(i) || 'l_converted_amount ' || l_converted_amount;
                                  pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                               END IF;
                         END IF;
                     IF l_converted_amount = -1 THEN
                      l_stage := 5600;
                      --hr_utility.trace(to_char(l_stage));
                      pa_debug.g_err_stage := to_char(l_stage)||': No Exchange Rate exists for the given Project currency attributes. Please change the Currency attributes';
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                      END IF;
                      /*
                      pa_utils.add_message
                     ( p_app_short_name => 'PA',
                       p_msg_name       => 'PA_FP_NO_PJ_EXCH_RATE_EXISTS',
                       p_token1         => 'PROJECT' ,
                       p_value1         => l_project_name,
                       p_token2         => 'TASK',
                       p_value2         => l_task_name,
                       p_token3         => 'RESOURCE_NAME',
                       p_value3         => l_resource_name,
                       p_token4         => 'RATE_DATE',
                       p_value4         => p_proj_cost_rate_date_tab(i),
                       p_token5         => 'TXN_CURRENCY',
                       p_value5         => p_txn_currency_code_tab(i));
                       fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                                  p_data  => x_msg_data);
                       x_msg_count := fnd_msg_pub.count_msg;
                       x_return_status := FND_API.G_RET_STS_ERROR;
                      */
                      x_proj_rejection_tab(i) := 'PA_FP_NO_PJ_EXCH_RATE_EXISTS';
                     END IF;
                   ELSIF l_converted_amount = -2 THEN
                      l_stage := 5700;
                      --hr_utility.trace(to_char(l_stage));
                      /*
                      pa_utils.add_message
                      (p_app_short_name => 'PA',
                       p_msg_name       => 'PA_FP_CURR_NOT_VALID',
                       p_token1         => 'PROJECT' ,
                       p_value1         => l_project_name,
                       p_token2         => 'TASK',
                       p_value2         => l_task_name,
                       p_token3         => 'RESOURCE_NAME',
                       p_value3         => l_resource_name,
                       p_token4         => 'RATE_DATE',
                       p_value4         => p_proj_cost_rate_date_tab(i),
                       p_token5         => 'TXN_CURRENCY',
                       p_value5         => p_txn_currency_code_tab(i));
                       fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                                  p_data  => x_msg_data);
                       x_msg_count := fnd_msg_pub.count_msg;
                       x_return_status := FND_API.G_RET_STS_ERROR;
                      */
                      x_proj_rejection_tab(i) := 'PA_FP_CURR_NOT_VALID';
                     -- Commented for Bug#5395732                   ELSE
                    END IF; -- Added for Bug#5395732


                      l_stage := 5900;
                      --hr_utility.trace(to_char(l_stage));
                  IF l_converted_amount <> -1 AND l_converted_amount <> -2 THEN -- Added for Bug#5395732
                         IF l_call_closest_flag = 'T' THEN -- Added for Bug#5395732
                                 l_numerator :=  GL_CURRENCY_API.get_closest_rate_numerator_sql
                                          ( p_txn_currency_code_tab(i)
                                           ,p_proj_currency_code_tab(i)
                                           ,p_proj_cost_rate_date_tab(i)
                                           ,p_proj_cost_rate_type_tab(i)
                                           ,-1);
                         ELSE
                          l_numerator   := gl_currency_api.get_rate_numerator_sql
                                           ( X_FROM_CURRENCY   => p_txn_currency_code_tab(i)
                                            ,X_TO_CURRENCY     => p_proj_currency_code_tab(i)
                                            ,X_CONVERSION_DATE => p_proj_cost_rate_date_tab(i)
                                            ,X_CONVERSION_TYPE => p_proj_cost_rate_type_tab(i));
                        END IF;
                      l_stage := 6000;
                      --hr_utility.trace(to_char(l_stage));
                      IF l_call_closest_flag = 'T' THEN -- Added for Bug#5395732
                                 l_denominator :=  GL_CURRENCY_API.get_closest_rate_denom_sql
                                          ( p_txn_currency_code_tab(i)
                                           ,p_proj_currency_code_tab(i)
                                           ,p_proj_cost_rate_date_tab(i)
                                           ,p_proj_cost_rate_type_tab(i)
                                           ,-1);
                         ELSE
                          l_denominator := gl_currency_api.get_rate_denominator_sql
                                           ( X_FROM_CURRENCY   => p_txn_currency_code_tab(i)
                                            ,X_TO_CURRENCY     => p_proj_currency_code_tab(i)
                                            ,X_CONVERSION_DATE => p_proj_cost_rate_date_tab(i)
                                            ,X_CONVERSION_TYPE => p_proj_cost_rate_type_tab(i));
                        END IF;
                      IF l_numerator > 0 AND l_denominator > 0 THEN
                         l_stage := 6100;
                         --hr_utility.trace(to_char(l_stage));
                         p_proj_cost_rate_tab(i) := round(l_numerator/l_denominator,20);
                         l_stage := 6150;
                         --hr_utility.trace(to_char(l_stage));
                         x_proj_raw_cost_tab(i)  := p_txn_raw_cost_tab(i) *
                                                    p_proj_cost_rate_tab(i);

             /* Rounding Enhancements */
                     x_proj_raw_cost_tab(i) := pa_currency.round_trans_currency_amt1
                                                        (x_proj_raw_cost_tab(i),p_proj_currency_code_tab(i));

                      END IF;

                      IF nvl(p_txn_burdened_cost_tab(i),0) <> 0 THEN
                         l_stage := 6200;
                         --hr_utility.trace(to_char(l_stage));
                         x_proj_burdened_cost_tab(i) := (nvl(p_txn_burdened_cost_tab(i),0) *
                                                              p_proj_cost_rate_tab(i));
             /* Rounding Enhancements */
                     x_proj_burdened_cost_tab(i) := pa_currency.round_trans_currency_amt1
                                                        (x_proj_burdened_cost_tab(i),p_proj_currency_code_tab(i));
                      END IF;

                      l_stage := 6300;
                      --hr_utility.trace(to_char(l_stage));
                      l_cached_count := nvl(CachedRowTab.count,0) + 1;
                      CachedRowTab(l_cached_count).from_currency := p_txn_currency_code_tab(i);
                      CachedRowTab(l_cached_count).to_currency   := p_proj_currency_code_tab(i);
                      CachedRowTab(l_cached_count).numerator     := l_numerator;
                      CachedRowTab(l_cached_count).denominator   := l_denominator;
                      CachedRowTab(l_cached_count).rate          := p_proj_cost_rate_tab(i);
                      CachedRowTab(l_cached_count).rate_date     := p_proj_cost_rate_date_tab(i);
                      CachedRowTab(l_cached_count).rate_type     := p_proj_cost_rate_type_tab(i);
                      CachedRowTab(l_cached_count).line_type     := 'COST';
                      -- Commented for Bug#5395732                   END IF; -- l_converted_amount values
                     END IF; -- Added for Bug#5395732
                     l_call_closest_flag := 'N'; -- Added for Bug#5395732 Resetting.
                ELSE -- Raw Cost IS NULL or 0
                   l_stage := 6400;
                   --hr_utility.trace(to_char(l_stage));
                   l_converted_amount  := gl_currency_api.convert_amount_sql
                                          ( X_FROM_CURRENCY   => p_txn_currency_code_tab(i)
                                           ,X_TO_CURRENCY     => p_proj_currency_code_tab(i)
                                           ,X_CONVERSION_DATE => p_proj_cost_rate_date_tab(i)
                                           ,X_CONVERSION_TYPE => p_proj_cost_rate_type_tab(i)
                                           ,X_AMOUNT          => p_txn_burdened_cost_tab(i));
                   IF l_converted_amount = -1 THEN
                        /* Added the If block for Bug#5395732 */
                         IF (p_calling_module IN ('BUDGET_GENERATION','FORECAST_GENERATION','UPDATE_PLAN_TRANSACTION')) THEN  --Bug 9586291
                               l_converted_amount := GL_CURRENCY_API.convert_closest_amount_sql
                                        (  x_from_currency => p_txn_currency_code_tab(i)
                                          ,x_to_currency => p_proj_currency_code_tab(i)
                                          ,x_conversion_date => p_proj_cost_rate_date_tab(i)
                                          ,x_conversion_type => p_proj_cost_rate_type_tab(i)
                                          ,x_user_rate => 1
                                          ,x_amount => p_txn_burdened_cost_tab(i)
                                          ,x_max_roll_days => -1)  ;
                               l_call_closest_flag := 'T';
                         END IF;
                      IF l_converted_amount = -1 THEN

                      l_stage := 6500;
                      --hr_utility.trace(to_char(l_stage));
                      pa_debug.g_err_stage := to_char(l_stage)||': No Exchange Rate exists for the given Project currency attributes. Please change the Currency attributes';
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                      END IF;
                      /*
                      pa_utils.add_message
                      (p_app_short_name => 'PA',
                       p_msg_name       => 'PA_FP_NO_PJ_EXCH_RATE_EXISTS',
                       p_token1         => 'PROJECT' ,
                       p_value1         => l_project_name,
                       p_token2         => 'TASK',
                       p_value2         => l_task_name,
                       p_token3         => 'RESOURCE_NAME',
                       p_value3         => l_resource_name,
                       p_token4         => 'RATE_DATE',
                       p_value4         => p_proj_cost_rate_date_tab(i),
                       p_token5         => 'TXN_CURRENCY',
                       p_value5         => p_txn_currency_code_tab(i));
                       fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                                  p_data  => x_msg_data);
                       x_msg_count := fnd_msg_pub.count_msg;
                       x_return_status := FND_API.G_RET_STS_ERROR;
                      */
                      x_proj_rejection_tab(i) := 'PA_FP_NO_PJ_EXCH_RATE_EXISTS';
                      END IF;
                   ELSIF l_converted_amount = -2 THEN
                      l_stage := 6600;
                      --hr_utility.trace(to_char(l_stage));
                      pa_debug.g_err_stage := to_char(l_stage)||'The Currency you have entered is not valid. Please re-enter the Currency';
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                      END IF;
                      /*
                      pa_utils.add_message
                     ( p_app_short_name => 'PA',
                       p_msg_name       => 'PA_FP_CURR_NOT_VALID',
                       p_token1         => 'PROJECT' ,
                       p_value1         => l_project_name,
                       p_token2         => 'TASK',
                       p_value2         => l_task_name,
                       p_token3         => 'RESOURCE_NAME',
                       p_value3         => l_resource_name,
                       p_token4         => 'RATE_DATE',
                       p_value4         => p_proj_cost_rate_date_tab(i),
                       p_token5         => 'TXN_CURRENCY',
                       p_value5         => p_txn_currency_code_tab(i));
                       fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                                  p_data  => x_msg_data);
                       x_msg_count := fnd_msg_pub.count_msg;
                       x_return_status := FND_API.G_RET_STS_ERROR;
                      */
                      x_proj_rejection_tab(i) := 'PA_FP_CURR_NOT_VALID';

                      -- Commented for Bug#5395732                   ELSE
                      END IF; -- Added for Bug#5395732

                      l_stage := 6800;
                      --hr_utility.trace(to_char(l_stage));
                  IF l_converted_amount <> -1 AND l_converted_amount <> -2 THEN -- Added for Bug#5395732
                         IF l_call_closest_flag = 'T' THEN -- Added for Bug#5395732
                                 l_numerator :=  GL_CURRENCY_API.get_closest_rate_numerator_sql
                                          ( p_txn_currency_code_tab(i)
                                           ,p_proj_currency_code_tab(i)
                                           ,p_proj_cost_rate_date_tab(i)
                                           ,p_proj_cost_rate_type_tab(i)
                                           ,-1);
                         ELSE
                          l_numerator   := gl_currency_api.get_rate_numerator_sql
                                           ( X_FROM_CURRENCY   => p_txn_currency_code_tab(i)
                                            ,X_TO_CURRENCY     => p_proj_currency_code_tab(i)
                                            ,X_CONVERSION_DATE => p_proj_cost_rate_date_tab(i)
                                            ,X_CONVERSION_TYPE => p_proj_cost_rate_type_tab(i));
                         END IF;
                      l_stage := 6900;
                      --hr_utility.trace(to_char(l_stage));
                       IF l_call_closest_flag = 'T' THEN -- Added for Bug#5395732
                                 l_denominator :=  GL_CURRENCY_API.get_closest_rate_denom_sql
                                          ( p_txn_currency_code_tab(i)
                                           ,p_proj_currency_code_tab(i)
                                           ,p_proj_cost_rate_date_tab(i)
                                           ,p_proj_cost_rate_type_tab(i)
                                           ,-1);
                         ELSE

                          l_denominator := gl_currency_api.get_rate_denominator_sql
                                           ( X_FROM_CURRENCY   => p_txn_currency_code_tab(i)
                                            ,X_TO_CURRENCY     => p_proj_currency_code_tab(i)
                                            ,X_CONVERSION_DATE => p_proj_cost_rate_date_tab(i)
                                            ,X_CONVERSION_TYPE => p_proj_cost_rate_type_tab(i));
                       END IF;
                      IF l_numerator > 0 AND l_denominator > 0 THEN
                         l_stage := 7000;
                         --hr_utility.trace(to_char(l_stage));
                         p_proj_cost_rate_tab(i) := round(l_numerator/l_denominator,20);
                         l_stage := 7050;
                         --hr_utility.trace(to_char(l_stage));
                         x_proj_burdened_cost_tab(i)  := p_txn_burdened_cost_tab(i) *
                                                         p_proj_cost_rate_tab(i);

             /* Rounding Enhancements */
                     x_proj_burdened_cost_tab(i) := pa_currency.round_trans_currency_amt1
                                                        (x_proj_burdened_cost_tab(i),p_proj_currency_code_tab(i));
                      END IF;

                      l_stage := 7100;
                      --hr_utility.trace(to_char(l_stage));
                      l_cached_count := nvl(CachedRowTab.count,0) + 1;
                      CachedRowTab(l_cached_count).from_currency := p_txn_currency_code_tab(i);
                      CachedRowTab(l_cached_count).to_currency   := p_proj_currency_code_tab(i);
                      CachedRowTab(l_cached_count).numerator     := l_numerator;
                      CachedRowTab(l_cached_count).denominator   := l_denominator;
                      CachedRowTab(l_cached_count).rate          := p_proj_cost_rate_tab(i);
                      CachedRowTab(l_cached_count).rate_date     := p_proj_cost_rate_date_tab(i);
                      CachedRowTab(l_cached_count).rate_type     := p_proj_cost_rate_type_tab(i);
                      CachedRowTab(l_cached_count).line_type     := 'COST';
                      -- Commented for Bug#5395732                   END IF; -- l_converted_amount values
                     END IF; -- Added for Bug#5395732
                     l_call_closest_flag := 'N'; -- Added for Bug#5395732 Resetting.
                END IF; -- Raw cost is NULL or 0
             END IF; -- Rate not found in Cache
          END IF; -- rate_type <> 'User'
        END IF; -- txn_raw or Burdened Cost <> 0


        l_stage := 7200;
        --hr_utility.trace(to_char(l_stage));
        -- Convert TxnRevenue to ProjectRevenue
        IF NVL(p_txn_revenue_tab(i),0) <> 0 THEN
          l_stage := 7300;
          --hr_utility.trace(to_char(l_stage));
          IF p_proj_rev_rate_type_tab(i) = 'User' THEN
             l_stage := 7400;
             --hr_utility.trace(to_char(l_stage));
             l_allow_user_rate_type := pa_multi_currency.is_user_rate_type_allowed
                                       ( p_txn_currency_code_tab(i)
                                        ,p_proj_currency_code_tab(i)
                                        ,p_proj_rev_rate_date_tab(i));
             IF l_allow_user_rate_type = 'Y' THEN
                IF p_proj_rev_rate_tab(i) IS NOT NULL THEN
                   x_proj_revenue_tab(i) :=  p_txn_revenue_tab(i) *
                                             NVL(p_proj_rev_rate_tab(i),1);
            /* Rounding Enhancements */
                    x_proj_revenue_tab(i) := pa_currency.round_trans_currency_amt1
                                                        (x_proj_revenue_tab(i),p_proj_currency_code_tab(i));
                ELSE
                   pa_debug.g_err_stage := to_char(l_stage)||': Project Revenue Rate Not Defined';
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                   END IF;
                   /*
                   pa_utils.add_message
                        ( p_app_short_name => 'PA',
                          p_msg_name       => 'PA_FP_PJ_REV_RATE_NOT_DEFINED',
                          p_token1         => 'PROJECT' ,
                          p_value1         => l_project_name,
                          p_token2         => 'TASK',
                          p_value2         => l_task_name,
                          p_token3         => 'RESOURCE_NAME',
                          p_value3         => l_resource_name,
                          p_token4         => 'START_DATE',
                          p_value4         => p_start_date_tab(i));
                   fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                              p_data  => x_msg_data);
                   x_msg_count := fnd_msg_pub.count_msg;
                   x_return_status := FND_API.G_RET_STS_ERROR;
                  */
                  x_proj_rejection_tab(i) := 'PA_FP_PJ_REV_RATE_NOT_DEFINED';
                END IF;
             ELSE
                l_stage := 810;
                   --hr_utility.trace(to_char(l_stage));
                   pa_debug.g_err_stage := to_char(l_stage)||': Revenue Rate type of User not allowed in Project Currency';
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                   END IF;
                   /*
                   pa_utils.add_message
                        ( p_app_short_name => 'PA',
                          p_msg_name       => 'PA_FP_PJC_USR_RATE_NOT_ALLOWED',
                          p_token1         => 'PROJECT' ,
                          p_value1         => l_project_name,
                          p_token2         => 'TASK',
                          p_value2         => l_task_name,
                          p_token3         => 'RESOURCE_NAME',
                          p_value3         => l_resource_name,
                          p_token4         => 'START_DATE',
                          p_value4         => p_start_date_tab(i),
                          p_token5         => 'TXN_CURRENCY',
                          p_value5         => p_txn_currency_code_tab(i));
                   fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                              p_data  => x_msg_data);
                   x_msg_count := fnd_msg_pub.count_msg;
                   x_return_status := FND_API.G_RET_STS_ERROR;
                  */
                  x_proj_rejection_tab(i) := 'PA_FP_PJC_USR_RATE_NOT_ALLOWED';
             END IF;
          ELSE
             l_stage := 7500;
             --hr_utility.trace(to_char(l_stage));
             l_done_flag := 'N';

             IF nvl(CachedRowTab.COUNT,0) <> 0 THEN
                l_stage := 7600;
                --hr_utility.trace(to_char(l_stage));
                FOR j in CachedRowTab.First..CachedRowTab.Last LOOP
                    IF CachedRowTab(j).from_currency = p_txn_currency_code_tab(i) AND
                       CachedRowTab(j).to_currency = p_proj_currency_code_tab(i) AND
                       CachedRowTab(j).rate_date = p_proj_rev_rate_date_tab(i) AND
                       CachedRowTab(j).rate_type = p_proj_rev_rate_type_tab(i) AND
                       CachedRowTab(j).line_type = 'REVENUE' THEN
                          l_stage := 7700;
                          --hr_utility.trace(to_char(l_stage));
                          p_proj_rev_rate_tab(i) := CachedRowTab(j).rate;
                          x_proj_revenue_tab(i)  := nvl(p_txn_revenue_tab(i),0) *
                                                          (round(CachedRowTab(j).numerator/
                                                          CachedRowTab(j).denominator,20));
              /* Rounding Enhancements */
                          x_proj_revenue_tab(i) := pa_currency.round_trans_currency_amt1
                                                        (x_proj_revenue_tab(i),p_proj_currency_code_tab(i));
                          l_done_flag := 'Y';
                          EXIT;
                    END IF; -- RevenueRateFound
                END LOOP; -- CachedRevenueRates
             END IF; -- CachedRowTab.COUNT > 0
             IF l_done_flag = 'N' THEN
                   l_stage := 7700;
                   --hr_utility.trace(to_char(l_stage));
                   l_converted_amount  := gl_currency_api.convert_amount_sql
                                          ( X_FROM_CURRENCY   => p_txn_currency_code_tab(i)
                                           ,X_TO_CURRENCY     => p_proj_currency_code_tab(i)
                                           ,X_CONVERSION_DATE => p_proj_rev_rate_date_tab(i)
                                           ,X_CONVERSION_TYPE => p_proj_rev_rate_type_tab(i)
                                           ,X_AMOUNT          => p_txn_revenue_tab(i));

                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.g_err_stage := '7700.1 x_from_currency '|| p_txn_currency_code_tab(i) || 'x_to_currency ' || p_proj_currency_code_tab(i);
                         pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                         pa_debug.g_err_stage := 'x_conversion_date ' || p_proj_rev_rate_date_tab(i) || 'x_conversion_type ' || p_proj_rev_rate_type_tab(i);
                         pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                         pa_debug.g_err_stage := 'X_AMOUNT ' || p_txn_revenue_tab(i) || 'l_converted_amount ' || l_converted_amount;
                         pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                      END IF;
                   IF l_converted_amount = -1 THEN
                         /* Added the If block for Bug#5395732 */
                         IF (p_calling_module IN ('BUDGET_GENERATION','FORECAST_GENERATION','UPDATE_PLAN_TRANSACTION')) THEN  --Bug 9586291
                               l_converted_amount := GL_CURRENCY_API.convert_closest_amount_sql
                                        (  x_from_currency => p_txn_currency_code_tab(i)
                                          ,x_to_currency => p_proj_currency_code_tab(i)
                                          ,x_conversion_date => p_proj_rev_rate_date_tab(i)
                                          ,x_conversion_type => p_proj_rev_rate_type_tab(i)
                                          ,x_user_rate => 1
                                          ,x_amount => p_txn_revenue_tab(i)
                                          ,x_max_roll_days => -1)  ;
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.g_err_stage := '7700.2 x_from_currency '|| p_txn_currency_code_tab(i) || 'x_to_currency ' || p_proj_currency_code_tab(i);
                         pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                         pa_debug.g_err_stage := 'x_conversion_date ' || p_proj_rev_rate_date_tab(i) || 'x_conversion_type ' || p_proj_rev_rate_type_tab(i);
                         pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                         pa_debug.g_err_stage := 'X_AMOUNT ' || p_txn_revenue_tab(i) || 'l_converted_amount ' || l_converted_amount;
                         pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                      END IF;
                               l_call_closest_flag := 'T';
                         END IF;
                      IF l_converted_amount = -1 THEN
                      l_stage := 7800;
                      --hr_utility.trace(to_char(l_stage));
                      pa_debug.g_err_stage := to_char(l_stage)||': No Exchange Rate exists for the given Project currency attributes. Please change the Currency attributes';
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                      END IF;
                      /*
                      pa_utils.add_message
                     ( p_app_short_name => 'PA',
                       p_msg_name       => 'PA_FP_NO_PJ_EXCH_RATE_EXISTS',
                       p_token1         => 'PROJECT' ,
                       p_value1         => l_project_name,
                       p_token2         => 'TASK',
                       p_value2         => l_task_name,
                       p_token3         => 'RESOURCE_NAME',
                       p_value3         => l_resource_name,
                       p_token4         => 'RATE_DATE',
                       p_value4         => p_proj_rev_rate_date_tab(i),
                       p_token5         => 'TXN_CURRENCY',
                       p_value5         => p_txn_currency_code_tab(i));
                       fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                                  p_data  => x_msg_data);
                       x_msg_count := fnd_msg_pub.count_msg;
                       x_return_status := FND_API.G_RET_STS_ERROR;
                      */
                      x_proj_rejection_tab(i) := 'PA_FP_NO_PJ_EXCH_RATE_EXISTS';
                    END IF;
                   ELSIF l_converted_amount = -2 THEN
                      l_stage := 7900;
                      --hr_utility.trace(to_char(l_stage));
                      pa_debug.g_err_stage := to_char(l_stage)||'The Currency you have entered is not valid. Please re-enter the Currency';
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
                      END IF;
                      /*
                      pa_utils.add_message
                     ( p_app_short_name => 'PA',
                       p_msg_name       => 'PA_FP_CURR_NOT_VALID',
                       p_token1         => 'PROJECT' ,
                       p_value1         => l_project_name,
                       p_token2         => 'TASK',
                       p_value2         => l_task_name,
                       p_token3         => 'RESOURCE_NAME',
                       p_value3         => l_resource_name,
                       p_token4         => 'RATE_DATE',
                       p_value4         => p_proj_rev_rate_date_tab(i),
                       p_token5         => 'TXN_CURRENCY',
                       p_value5         => p_txn_currency_code_tab(i));
                       fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                                  p_data  => x_msg_data);
                       x_msg_count := fnd_msg_pub.count_msg;
                       x_return_status := FND_API.G_RET_STS_ERROR;
                      */
                      x_proj_rejection_tab(i) := 'PA_FP_CURR_NOT_VALID';
                   -- Commented for Bug#5395732                   ELSE
                    END IF; -- Added for Bug#5395732

                      l_stage := 8100;
                      --hr_utility.trace(to_char(l_stage));
                  IF l_converted_amount <> -1 AND l_converted_amount <> -2 THEN -- Added for Bug#5395732
                         IF l_call_closest_flag = 'T' THEN -- Added for Bug#5395732
                                 l_numerator :=  GL_CURRENCY_API.get_closest_rate_numerator_sql
                                          ( p_txn_currency_code_tab(i)
                                           ,p_proj_currency_code_tab(i)
                                           ,p_proj_rev_rate_date_tab(i)
                                           ,p_proj_rev_rate_type_tab(i)
                                           ,-1);
                         ELSE

                          l_numerator   := gl_currency_api.get_rate_numerator_sql
                                           ( X_FROM_CURRENCY   => p_txn_currency_code_tab(i)
                                            ,X_TO_CURRENCY     => p_proj_currency_code_tab(i)
                                            ,X_CONVERSION_DATE => p_proj_rev_rate_date_tab(i)
                                            ,X_CONVERSION_TYPE => p_proj_rev_rate_type_tab(i));
                        END IF;

                      l_stage := 8200;
                      --hr_utility.trace(to_char(l_stage));
                      IF l_call_closest_flag = 'T' THEN -- Added for Bug#5395732
                                 l_denominator :=  GL_CURRENCY_API.get_closest_rate_denom_sql
                                          ( p_txn_currency_code_tab(i)
                                           ,p_proj_currency_code_tab(i)
                                           ,p_proj_rev_rate_date_tab(i)
                                           ,p_proj_rev_rate_type_tab(i)
                                           ,-1);
                         ELSE
                          l_denominator := gl_currency_api.get_rate_denominator_sql
                                           ( X_FROM_CURRENCY   => p_txn_currency_code_tab(i)
                                            ,X_TO_CURRENCY     => p_proj_currency_code_tab(i)
                                            ,X_CONVERSION_DATE => p_proj_rev_rate_date_tab(i)
                                            ,X_CONVERSION_TYPE => p_proj_rev_rate_type_tab(i));
                        END IF;
                      IF l_numerator > 0 AND l_denominator > 0 THEN
                         l_stage := 8300;
                         --hr_utility.trace(to_char(l_stage));
                         p_proj_rev_rate_tab(i) := round(l_numerator/l_denominator,20);
                         l_stage := 8350;
                         --hr_utility.trace(to_char(l_stage));
                         x_proj_revenue_tab(i)  := p_txn_revenue_tab(i) *
                                                   p_proj_rev_rate_tab(i);
             /* Rounding Enhancements */
                         x_proj_revenue_tab(i) := pa_currency.round_trans_currency_amt1
                                                        (x_proj_revenue_tab(i),p_proj_currency_code_tab(i));
                      END IF;

                      l_stage := 8400;
                      --hr_utility.trace(to_char(l_stage));
                      l_cached_count := nvl(CachedRowTab.count,0) + 1;
                      CachedRowTab(l_cached_count).from_currency := p_txn_currency_code_tab(i);
                      CachedRowTab(l_cached_count).to_currency   := p_proj_currency_code_tab(i);
                      CachedRowTab(l_cached_count).numerator     := l_numerator;
                      CachedRowTab(l_cached_count).denominator   := l_denominator;
                      CachedRowTab(l_cached_count).rate          := p_proj_rev_rate_tab(i);
                      CachedRowTab(l_cached_count).rate_date     := p_proj_rev_rate_date_tab(i);
                      CachedRowTab(l_cached_count).rate_type     := p_proj_rev_rate_type_tab(i);
                      CachedRowTab(l_cached_count).line_type     := 'REVENUE';
                    -- Commented for Bug#5395732                   END IF; -- l_converted_amount values
                     END IF; -- Added for Bug#5395732
                     l_call_closest_flag := 'N'; -- Added for Bug#5395732 Resetting.
             END IF; -- RevenueRate not found in Cache
          END IF; -- RevenueRateType <> 'User'
        END IF; -- TxnRevenue <> 0
      END IF; -- TxnCurrencyCode <> ProjCurrencyCode

      l_stage := 8500;
      --hr_utility.trace(to_char(l_stage));
         --hr_utility.trace('x_projfunc_raw_cost_tab(i)      := '||to_char(x_projfunc_raw_cost_tab(i)));
         --hr_utility.trace('x_projfunc_burdened_cost_tab(i) := '||to_char(x_projfunc_burdened_cost_tab(i)));
         --hr_utility.trace('x_projfunc_revenue_tab(i)       := '||to_char(x_projfunc_revenue_tab(i)));
         --hr_utility.trace('x_proj_raw_cost_tab(i)          := '||to_char(x_proj_raw_cost_tab(i)));
         --hr_utility.trace('x_proj_burdened_cost_tab(i)     := '||to_char(x_proj_burdened_cost_tab(i)));
         --hr_utility.trace('x_proj_revenue_tab(i)           := '||to_char(x_proj_revenue_tab(i)));
         --hr_utility.trace('x_proj_rejection_tab(i)         := '||to_char(x_proj_rejection_tab(i)));
         --hr_utility.trace('x_projfunc_rejection_tab(i)     := '||to_char(x_projfunc_rejection_tab(i)));
    END LOOP;
      l_stage := 8600;
      --hr_utility.trace(to_char(l_stage));
      pa_debug.g_err_stage := 'Leaving PA_FP_MULTI_CURRENCY_PKG.conv_mc_bulk';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
      x_msg_count := FND_MSG_PUB.Count_Msg;
      IF x_msg_count = 1 THEN
       IF x_msg_data IS NOT NULL THEN
            FND_MESSAGE.SET_ENCODED (x_msg_data);
            x_msg_data := FND_MESSAGE.GET;
       END IF;
      END IF;
      /* bug 4227840: wrapping the setting of debug error stack call to
       * pa_debug under the debug enbaling check
       */
      IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.reset_err_stack;
      END IF;

  EXCEPTION WHEN OTHERS THEN
       fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                  p_data  => x_msg_data);
       x_msg_count := FND_MSG_PUB.Count_Msg;
       IF x_msg_count = 1 THEN
        IF x_msg_data IS NOT NULL THEN
             FND_MESSAGE.SET_ENCODED (x_msg_data);
             x_msg_data := FND_MESSAGE.GET;
        END IF;
       END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_msg_pub.add_exc_msg
           ( p_pkg_name       => 'PA_FP_MULTI_CURRENCY_PKG'
            ,p_procedure_name => 'conv_mc_bulk' );
        pa_debug.g_err_stage := 'Stage : '||to_char(l_stage)||' '||substr(SQLERRM,1,240);
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('conv_mc_bulk: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;
        --hr_utility.trace('PA_FP_MULTI_CURRENCY_PKG.conv_mc_bulk -- Stage : ' ||to_char(l_stage)||' '||substr(SQLERRM,1,240));
        /* bug 4227840: wrapping the setting of debug error stack call to
         * pa_debug under the debug enbaling check
         */
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.reset_err_stack;
        END IF;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END conv_mc_bulk;

  PROCEDURE convert_txn_currency
            ( p_budget_version_id  IN pa_budget_versions.budget_version_id%TYPE
             ,p_entire_version     IN VARCHAR2 DEFAULT 'N'
         ,p_budget_line_id     IN NUMBER   DEFAULT NULL
             ,p_source_context     IN VARCHAR2 DEFAULT 'BUDGET_VERSION'
             ,p_calling_module           IN  VARCHAR2  DEFAULT   'UPDATE_PLAN_TRANSACTION'-- Added for Bug#5395732
             ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_msg_count          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
             ,x_msg_data           OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
  IS

  l_txn_row_id_tab              pa_fp_multi_currency_pkg.rowid_type_tab;
  l_resource_assignment_id_tab  pa_fp_multi_currency_pkg.number_type_tab;
  l_start_date_tab              pa_fp_multi_currency_pkg.date_type_tab;
  l_end_date_tab                pa_fp_multi_currency_pkg.date_type_tab;
  l_txn_currency_code_tab       pa_fp_multi_currency_pkg.char240_type_tab;
  l_txn_raw_cost_tab            pa_fp_multi_currency_pkg.number_type_tab;
  l_txn_burdened_cost_tab       pa_fp_multi_currency_pkg.number_type_tab;
  l_txn_revenue_tab             pa_fp_multi_currency_pkg.number_type_tab;
  l_projfunc_currency_code_tab  pa_fp_multi_currency_pkg.char240_type_tab;
  l_projfunc_cost_rate_type_tab pa_fp_multi_currency_pkg.char240_type_tab;
  l_projfunc_cost_rate_tab      pa_fp_multi_currency_pkg.number_type_tab;
  l_projfunc_cost_rt_dt_typ_tab pa_fp_multi_currency_pkg.char240_type_tab;
  l_projfunc_cost_rate_date_tab pa_fp_multi_currency_pkg.date_type_tab;
  l_projfunc_rev_rate_type_tab  pa_fp_multi_currency_pkg.char240_type_tab;
  l_projfunc_rev_rate_tab       pa_fp_multi_currency_pkg.number_type_tab;
  l_projfunc_rev_rt_dt_typ_tab  pa_fp_multi_currency_pkg.char240_type_tab;
  l_projfunc_rev_rate_date_tab  pa_fp_multi_currency_pkg.date_type_tab;
  l_projfunc_raw_cost_tab       pa_fp_multi_currency_pkg.number_type_tab;
  l_projfunc_burdened_cost_tab  pa_fp_multi_currency_pkg.number_type_tab;
  l_projfunc_revenue_tab        pa_fp_multi_currency_pkg.number_type_tab;
  l_projfunc_rejection_tab      pa_fp_multi_currency_pkg.char30_type_tab;
  l_proj_currency_code_tab      pa_fp_multi_currency_pkg.char240_type_tab;
  l_proj_cost_rate_type_tab     pa_fp_multi_currency_pkg.char240_type_tab;
  l_proj_cost_rate_tab          pa_fp_multi_currency_pkg.number_type_tab;
  l_proj_cost_rt_dt_typ_tab     pa_fp_multi_currency_pkg.char240_type_tab;
  l_proj_cost_rate_date_tab     pa_fp_multi_currency_pkg.date_type_tab;
  l_proj_rev_rate_type_tab      pa_fp_multi_currency_pkg.char240_type_tab;
  l_proj_rev_rate_tab           pa_fp_multi_currency_pkg.number_type_tab;
  l_proj_rev_rt_dt_typ_tab      pa_fp_multi_currency_pkg.char240_type_tab;
  l_proj_rev_rate_date_tab      pa_fp_multi_currency_pkg.date_type_tab;
  l_proj_raw_cost_tab           pa_fp_multi_currency_pkg.number_type_tab;
  l_proj_burdened_cost_tab      pa_fp_multi_currency_pkg.number_type_tab;
  l_proj_revenue_tab            pa_fp_multi_currency_pkg.number_type_tab;
  l_proj_rejection_tab          pa_fp_multi_currency_pkg.char30_type_tab;
  l_user_validate_flag_tab      pa_fp_multi_currency_pkg.char240_type_tab;
  l_status_flag_tab             pa_fp_multi_currency_pkg.char240_type_tab;

  /* Perf Bug: 3683132 */
  l_fp_cur_projfunc_cost_rt_tab   pa_fp_multi_currency_pkg.number_type_tab;
  l_fp_cur_projfunc_rev_rt_tab    pa_fp_multi_currency_pkg.number_type_tab;
  l_fp_cur_project_cost_rt_tab    pa_fp_multi_currency_pkg.number_type_tab;
  l_fp_cur_project_rev_rt_tab     pa_fp_multi_currency_pkg.number_type_tab;

  /* Bug fix:4259098 */
  l_init_quantity_tab           pa_fp_multi_currency_pkg.number_type_tab;
  l_txn_init_raw_cost_tab       pa_fp_multi_currency_pkg.number_type_tab;
  l_txn_init_burden_cost_tab    pa_fp_multi_currency_pkg.number_type_tab;
  l_txn_init_revenue_tab        pa_fp_multi_currency_pkg.number_type_tab;
  l_pfc_init_raw_cost_tab	pa_fp_multi_currency_pkg.number_type_tab;
  l_pfc_init_burden_cost_tab 	pa_fp_multi_currency_pkg.number_type_tab;
  l_pfc_init_revenue_tab	pa_fp_multi_currency_pkg.number_type_tab;
  l_proj_init_raw_cost_tab	pa_fp_multi_currency_pkg.number_type_tab;
  l_proj_init_burden_cost_tab	pa_fp_multi_currency_pkg.number_type_tab;
  l_proj_init_revenue_tab	pa_fp_multi_currency_pkg.number_type_tab;

  l_return_status VARCHAR2(240);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);

  l_entire_return_status VARCHAR2(240);
  l_entire_msg_count NUMBER;
  l_entire_msg_data  VARCHAR2(2000);

  l_rowcount number;
  l_stage NUMBER;

  l_debug_mode       VARCHAR2(30); /* Bug 4227840 */

  CURSOR get_fp_options_data IS
  select v.project_id
        ,v.fin_plan_type_id
        ,o.projfunc_cost_rate_type
        ,o.projfunc_cost_rate_date_type
        ,o.projfunc_cost_rate_date
        ,o.projfunc_rev_rate_type
        ,o.projfunc_rev_rate_date_type
        ,o.projfunc_rev_rate_date
        ,o.project_cost_rate_type
        ,o.project_cost_rate_date_type
        ,o.project_cost_rate_date
        ,o.project_rev_rate_type
        ,o.project_rev_rate_date_type
        ,o.project_rev_rate_date
    from pa_proj_fp_options o
        ,pa_budget_versions v
   where v.budget_version_id   = p_budget_version_id
     and o.project_id          = v.project_id
     and nvl(o.fin_plan_type_id,0)    = nvl(v.fin_plan_type_id,0)
     and o.fin_plan_version_id = v.budget_version_id;

  CURSOR get_project_lvl_data IS
  select segment1
        ,project_currency_code
        ,projfunc_currency_code
    from pa_projects_all
   where project_id = g_project_id;

  CURSOR all_budget_lines IS
  select a.rowid
        ,a.resource_assignment_id
        ,a.start_date
        ,a.end_date
        ,a.txn_currency_code
        ,a.txn_raw_cost
        ,a.txn_burdened_cost
        ,a.txn_revenue
        ,nvl(a.projfunc_currency_code,g_projfunc_currency_code)
        ,nvl(a.projfunc_cost_rate_type,g_projfunc_cost_rate_type)
        ,DECODE(a.projfunc_cost_exchange_rate,null,
                                            DECODE(nvl(a.projfunc_cost_rate_type,g_projfunc_cost_rate_type),'User',
                                                              --get_fp_cur_details( p_budget_version_id,a.txn_currency_code,'COST','PROJFUNC' ),
                                -9999,
                                                                          a.projfunc_cost_exchange_rate),
                                            a.projfunc_cost_exchange_rate)
                                                                            projfunc_cost_exchange_rate
        ,DECODE(nvl(a.projfunc_cost_rate_type,g_projfunc_cost_rate_type),'User',NULL,
                nvl(a.projfunc_cost_rate_date_type,g_projfunc_cost_rate_date_type))
        ,DECODE(nvl(a.projfunc_cost_rate_date_type,
                    g_projfunc_cost_rate_date_type),
                'START_DATE',a.start_date,
                'END_DATE'  ,a.end_date,
                nvl(a.projfunc_cost_rate_date,g_projfunc_cost_rate_date))
                                                         projfunc_cost_rate_date
        ,nvl(a.projfunc_rev_rate_type,g_projfunc_rev_rate_type)
        ,DECODE(a.projfunc_rev_exchange_rate,null,
                                            DECODE(nvl(a.projfunc_rev_rate_type,g_projfunc_rev_rate_type),'User',
                                                                          -9999, ---c.projfunc_rev_exchange_rate,
                                                                          a.projfunc_rev_exchange_rate),
                                            a.projfunc_rev_exchange_rate)
                                                                            projfunc_rev_exchange_rate
        ,DECODE(nvl(a.projfunc_rev_rate_type,g_projfunc_rev_rate_type),'User',NULL,
                nvl(a.projfunc_rev_rate_date_type,g_projfunc_rev_rate_date_type))
        ,DECODE(nvl(a.projfunc_rev_rate_date_type,g_projfunc_rev_rate_date_type),
                'START_DATE',a.start_date,
                'END_DATE'  ,a.end_date,
                nvl(a.projfunc_rev_rate_date,g_projfunc_rev_rate_date))
                                                          projfunc_rev_rate_date
        ,nvl(a.project_currency_code,g_proj_currency_code)
        ,nvl(a.project_cost_rate_type,g_proj_cost_rate_type)
        ,DECODE(a.project_cost_exchange_rate,null,
                                            DECODE(nvl(a.project_cost_rate_type,g_proj_cost_rate_type),'User',
                                                                          -9999,  --c.project_cost_exchange_rate,
                                                                          a.project_cost_exchange_rate),
                                            a.project_cost_exchange_rate)
                                                                            project_cost_exchange_rate
        ,DECODE(nvl(a.project_cost_rate_type,g_proj_cost_rate_type),'User',NULL,
                nvl(a.project_cost_rate_date_type,g_proj_cost_rate_date_type))
        ,DECODE(nvl(a.project_cost_rate_date_type,g_proj_cost_rate_date_type),
                'START_DATE',a.start_date,
                'END_DATE'  ,a.end_date,
                nvl(a.project_cost_rate_date,g_proj_cost_rate_date))
                                                          project_cost_rate_date
        ,nvl(a.project_rev_rate_type,g_proj_rev_rate_type)
        ,DECODE(a.project_rev_exchange_rate,null,
                                            DECODE(nvl(a.project_rev_rate_type,g_proj_rev_rate_type),'User',
                                                                          -9999, --c.project_rev_exchange_rate,
                                                                          a.project_rev_exchange_rate),
                                            a.project_rev_exchange_rate)
                                                                            project_rev_exchange_rate
        ,DECODE(nvl(a.project_rev_rate_type,g_proj_rev_rate_type),'User',NULL,
                nvl(a.project_rev_rate_date_type,g_proj_rev_rate_date_type))
        ,DECODE(nvl(a.project_rev_rate_date_type,g_proj_rev_rate_date_type),
                'START_DATE',a.start_date,
                'END_DATE'  ,a.end_date,
                nvl(a.project_rev_rate_date,g_proj_rev_rate_date))
                                                           project_rev_rate_date
    /* Perf Bug: 3683132 */
    ,get_fp_cur_details( p_budget_version_id,a.txn_currency_code,'COST','PROJFUNC' ) fp_cur_projfunc_cost_rate
    ,get_fp_cur_details( p_budget_version_id,a.txn_currency_code,'REV','PROJFUNC' ) fp_cur_projfunc_rev_rate
    ,get_fp_cur_details( p_budget_version_id,a.txn_currency_code,'COST','PROJECT' ) fp_cur_project_cost_rate
    ,get_fp_cur_details( p_budget_version_id,a.txn_currency_code,'REV','PROJECT' ) fp_cur_project_rev_rate
    /* Bug fix:4259098 */
        ,a.init_quantity
        ,a.txn_init_raw_cost
        ,a.txn_init_burdened_cost
        ,a.txn_init_revenue
	,a.init_raw_cost
        ,a.init_burdened_cost
        ,a.init_revenue
        ,a.project_init_raw_cost
        ,a.project_init_burdened_cost
        ,a.project_init_revenue
    from pa_budget_lines a
    ,pa_budget_versions bv
        --,pa_fp_txn_currencies c
   where a.budget_version_id = p_budget_version_id
   and   bv.budget_version_id = a.budget_version_id
     and EXISTS (select null
        from pa_resource_assignments b
        where b.resource_assignment_id = a.resource_assignment_id
        and   b.budget_version_id = a.budget_version_id
        )
     /** Perf Bug: 3683132 a.budget_version_id = c.fin_plan_version_id (+)
     and a.txn_currency_code = c.txn_currency_code  (+)
     and a.resource_assignment_id in (select b.resource_assignment_id
                                        from pa_resource_assignments b
                                       where b.resource_assignment_id =
                                                        a.resource_assignment_id
                                         and b.budget_version_id =
                                                            p_budget_version_id)
     **/
     and (((NVL(p_source_context,'BUDGET_VERSION') = 'BUDGET_LINE')
      and a.budget_line_id = p_budget_line_id)
     OR
      (NVL(p_source_context,'BUDGET_VERSION') <> 'BUDGET_LINE')
     )
     /* Bug fix: 4085192 Select all budget lines only on or after the ETC STart date, if ETC date is populated */
     AND ((bv.ETC_START_DATE IS NULL)
               OR (bv.ETC_START_DATE IS NOT NULL
                   AND ((a.start_date > bv.ETC_START_DATE )
                        OR (bv.ETC_START_DATE between a.start_date and a.end_date)
                       )
                  )
           )
   order by a.resource_assignment_id,
             a.start_date,
             a.txn_currency_code;

  CURSOR rollup_lines IS
  select r.rowid
        ,r.resource_assignment_id
        ,r.start_date
        ,r.end_date
        ,r.txn_currency_code
        ,nvl(r.txn_raw_cost,0)
        ,nvl(r.txn_burdened_cost,0)
        ,nvl(r.txn_revenue,0)
        ,nvl(r.projfunc_currency_code,g_projfunc_currency_code)
        ,nvl(r.projfunc_cost_rate_type,g_projfunc_cost_rate_type)
        ,DECODE(r.projfunc_cost_exchange_rate,null,
                                            DECODE(nvl(r.projfunc_cost_rate_type,g_projfunc_cost_rate_type),'User',
                                                                          -9999,  --c.projfunc_cost_exchange_rate,
                                                                          r.projfunc_cost_exchange_rate),
                                            r.projfunc_cost_exchange_rate)
                                                                            projfunc_cost_exchange_rate
        ,DECODE(nvl(r.projfunc_cost_rate_type,g_projfunc_cost_rate_type),'User',Null,
                nvl(r.projfunc_cost_rate_date_type,g_projfunc_cost_rate_date_type))
        ,DECODE(nvl(r.projfunc_cost_rate_date_type,
                    g_projfunc_cost_rate_date_type),
                'START_DATE',r.start_date,
                'END_DATE'  ,r.end_date,
                nvl(r.projfunc_cost_rate_date,g_projfunc_cost_rate_date))
                                                         projfunc_cost_rate_date
        ,nvl(r.projfunc_rev_rate_type,g_projfunc_rev_rate_type)
        ,DECODE(r.projfunc_rev_exchange_rate,null,
                                            DECODE(nvl(r.projfunc_rev_rate_type,g_projfunc_rev_rate_type),'User',
                                                                          -9999,  ---c.projfunc_rev_exchange_rate,
                                                                          r.projfunc_rev_exchange_rate),
                                            r.projfunc_rev_exchange_rate)
                                                                            projfunc_rev_exchange_rate
        ,DECODE(nvl(r.projfunc_rev_rate_type,g_projfunc_rev_rate_type),'User',NULL,
                nvl(r.projfunc_rev_rate_date_type,g_projfunc_rev_rate_date_type))
        ,DECODE(nvl(r.projfunc_rev_rate_date_type,g_projfunc_rev_rate_date_type),
                'START_DATE',r.start_date,
                'END_DATE'  ,r.end_date,
                nvl(r.projfunc_rev_rate_date,g_projfunc_rev_rate_date))
                                                          projfunc_rev_rate_date
        ,nvl(r.project_currency_code,g_proj_currency_code)
        ,nvl(r.project_cost_rate_type,g_proj_cost_rate_type)
        ,DECODE(r.project_cost_exchange_rate,null,
                                            DECODE(nvl(r.project_cost_rate_type,g_proj_cost_rate_type),'User',
                                                                          -9999,  --c.project_cost_exchange_rate,
                                                                          r.project_cost_exchange_rate),
                                            r.project_cost_exchange_rate)
                                                                            project_cost_exchange_rate
        ,DECODE(nvl(r.project_cost_rate_type,g_proj_cost_rate_type),'User',NULL,
                nvl(r.project_cost_rate_date_type,g_proj_cost_rate_date_type))
        ,DECODE(nvl(r.project_cost_rate_date_type,g_proj_cost_rate_date_type),
                'START_DATE',r.start_date,
                'END_DATE'  ,r.end_date,
                nvl(r.project_cost_rate_date,g_proj_cost_rate_date))
                                                          project_cost_rate_date
        ,nvl(r.project_rev_rate_type,g_proj_rev_rate_type)
        ,DECODE(r.project_rev_exchange_rate,null,
                                            DECODE(nvl(r.project_rev_rate_type,g_proj_rev_rate_type),'User',
                                                                          -9999,  --c.project_rev_exchange_rate,
                                                                          r.project_rev_exchange_rate),
                                            r.project_rev_exchange_rate)
                                                                            project_rev_exchange_rate
        ,DECODE(nvl(r.project_rev_rate_type,g_proj_rev_rate_type),'User',NULL,
                nvl(r.project_rev_rate_date_type,g_proj_rev_rate_date_type))
        ,DECODE(nvl(r.project_rev_rate_date_type,g_proj_rev_rate_date_type),
                'START_DATE',r.start_date,
                'END_DATE'  ,r.end_date,
                nvl(r.project_rev_rate_date,g_proj_rev_rate_date))
                                                           project_rev_rate_date
        /* Perf Bug: 3683132 */
        ,get_fp_cur_details( p_budget_version_id,r.txn_currency_code,'COST','PROJFUNC' ) fp_cur_projfunc_cost_rate
        ,get_fp_cur_details( p_budget_version_id,r.txn_currency_code,'REV','PROJFUNC' ) fp_cur_projfunc_rev_rate
        ,get_fp_cur_details( p_budget_version_id,r.txn_currency_code,'COST','PROJECT' ) fp_cur_project_cost_rate
        ,get_fp_cur_details( p_budget_version_id,r.txn_currency_code,'REV','PROJECT' ) fp_cur_project_rev_rate
	/* Bug fix:4259098 */
	,r.init_quantity
        ,r.txn_init_raw_cost
        ,r.txn_init_burdened_cost
        ,r.txn_init_revenue
	,r.init_raw_cost
        ,r.init_burdened_cost
        ,r.init_revenue
        ,r.project_init_raw_cost
        ,r.project_init_burdened_cost
        ,r.project_init_revenue
    from pa_fp_rollup_tmp r
         --,pa_fp_txn_currencies c
   where nvl(r.delete_flag,'N') = 'N'
     /** Perf Bug: 3683132 and p_budget_version_id = c.fin_plan_version_id (+)
     and r.txn_currency_code = c.txn_currency_code (+)
     **/
   order by r.resource_assignment_id,
            r.start_date,
            r.txn_currency_code;

  BEGIN

   /** Bug fix: 3849908 initialization of msg stack here removes all the error msgs added during the calculate api and spread process
    * so commenting out
    *fnd_msg_pub.initialize;
    **/

   l_entire_return_status := FND_API.G_RET_STS_SUCCESS;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
   l_debug_mode := NVL(l_debug_mode, 'Y');

    /* bug 4227840: wrapping the setting of debug error stack call to
     * pa_debug under the debug enbaling check
     */
    IF l_debug_mode = 'Y' THEN
        pa_debug.set_err_stack('convert_txn_currency');
        pa_debug.set_process('PLSQL','LOG',l_debug_mode);
    END IF;

   -- Get default attributes for currency conversion from version level
   -- proj_fp_options
   l_stage := 100;
   IF NOT get_fp_options_data%ISOPEN THEN
      OPEN get_fp_options_data;
   ELSE
      CLOSE get_fp_options_data;
      OPEN get_fp_options_data;
   END IF;

   BEGIN
     l_stage := 200;
     FETCH get_fp_options_data INTO
            g_project_id
           ,g_fin_plan_type_id
           ,g_projfunc_cost_rate_type
           ,g_projfunc_cost_rate_date_type
           ,g_projfunc_cost_rate_date
           ,g_projfunc_rev_rate_type
           ,g_projfunc_rev_rate_date_type
           ,g_projfunc_rev_rate_date
           ,g_proj_cost_rate_type
           ,g_proj_cost_rate_date_type
           ,g_proj_cost_rate_date
           ,g_proj_rev_rate_type
           ,g_proj_rev_rate_date_type
           ,g_proj_rev_rate_date;
   EXCEPTION WHEN NO_DATA_FOUND THEN
     /* bug 4227840: wrapping the setting of debug error stack call to
      * pa_debug under the debug enbaling check
      */
     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.reset_err_stack;
     END IF;
     RAISE;
   END;

   pa_debug.g_err_stage := 'pfc cost rate date' || g_projfunc_cost_rate_date;
   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.write('convert_txn_currency: ' || g_module_name,pa_debug.g_err_stage,3);
   END IF;

   pa_debug.g_err_stage := 'pfc cost rate type' || g_projfunc_cost_rate_type;
   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.write('convert_txn_currency: ' || g_module_name,pa_debug.g_err_stage,3);
   END IF;

   pa_debug.g_err_stage := 'pfc cost rate date type' || g_projfunc_cost_rate_date_type;
   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.write('convert_txn_currency: ' || g_module_name,pa_debug.g_err_stage,3);
   END IF;

   pa_debug.g_err_stage := 'pfc rev rate date' || g_projfunc_rev_rate_date;
   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.write('convert_txn_currency: ' || g_module_name,pa_debug.g_err_stage,3);
   END IF;

   pa_debug.g_err_stage := 'pfc rev rate type' || g_projfunc_rev_rate_type;
   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.write('convert_txn_currency: ' || g_module_name,pa_debug.g_err_stage,3);
   END IF;

   pa_debug.g_err_stage := 'pfc rev rate date type' || g_projfunc_rev_rate_date_type;
   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.write('convert_txn_currency: ' || g_module_name,pa_debug.g_err_stage,3);
   END IF;

  CLOSE get_fp_options_data;

     l_stage := 200;
  -- Get project level Info
  IF NOT get_project_lvl_data%ISOPEN THEN
     OPEN get_project_lvl_data;
  ELSE
     CLOSE get_project_lvl_data;
     OPEN get_project_lvl_data;
  END IF;
  l_stage := 300;
  BEGIN
    l_stage := 400;
    FETCH get_project_lvl_data INTO
          g_project_number
         ,g_proj_currency_code
         ,g_projfunc_currency_code;
  EXCEPTION WHEN OTHERS THEN
    RAISE;
  END;

  --hr_utility.trace('ProjectCurr=> '||g_proj_currency_code);
  --hr_utility.trace('ProjFuncCurr=> '||g_projfunc_currency_code);

  IF p_entire_version = 'Y' THEN
     l_stage := 500;
     IF NOT all_budget_lines%ISOPEN THEN
        OPEN all_budget_lines;
     ELSE
        CLOSE all_budget_lines;
        OPEN all_budget_lines;
     END IF;
  ELSE
     l_stage := 600;
     IF NOT rollup_lines%ISOPEN THEN
        OPEN rollup_lines;
     ELSE
        CLOSE rollup_lines;
        OPEN rollup_lines;
     END IF;
  END IF;
  l_stage := 700;
  LOOP
  BEGIN

     --Reset PL/SQL Tables.

       l_txn_row_id_tab.delete;
       l_resource_assignment_id_tab.delete;
       l_start_date_tab.delete;
       l_end_date_tab.delete;
       l_txn_currency_code_tab.delete;
       l_txn_raw_cost_tab.delete;
       l_txn_burdened_cost_tab.delete;
       l_txn_revenue_tab.delete;
       l_projfunc_currency_code_tab.delete;
       l_projfunc_cost_rate_type_tab.delete;
       l_projfunc_cost_rate_tab.delete;
       l_projfunc_cost_rt_dt_typ_tab.delete;
       l_projfunc_cost_rate_date_tab.delete;
       l_projfunc_rev_rate_type_tab.delete;
       l_projfunc_rev_rate_tab.delete;
       l_projfunc_rev_rt_dt_typ_tab.delete;
       l_projfunc_rev_rate_date_tab.delete;
       l_projfunc_raw_cost_tab.delete;
       l_projfunc_burdened_cost_tab.delete;
       l_projfunc_revenue_tab.delete;
       l_projfunc_rejection_tab.delete;
       l_proj_currency_code_tab.delete;
       l_proj_cost_rate_type_tab.delete;
       l_proj_cost_rate_tab.delete;
       l_proj_cost_rt_dt_typ_tab.delete;
       l_proj_cost_rate_date_tab.delete;
       l_proj_rev_rate_type_tab.delete;
       l_proj_rev_rate_tab.delete;
       l_proj_rev_rt_dt_typ_tab.delete;
       l_proj_rev_rate_date_tab.delete;
       l_proj_raw_cost_tab.delete;
       l_proj_burdened_cost_tab.delete;
       l_proj_revenue_tab.delete;
       l_proj_rejection_tab.delete;
       l_user_validate_flag_tab.delete;
       l_status_flag_tab.delete;
       /* Perf Bug: 3683132 */
       l_fp_cur_projfunc_cost_rt_tab.delete;
       l_fp_cur_projfunc_rev_rt_tab.delete;
       l_fp_cur_project_cost_rt_tab.delete;
       l_fp_cur_project_rev_rt_tab.delete;
	/* Bug fix:4259098 */
	l_init_quantity_tab.delete;
  	l_txn_init_raw_cost_tab.delete;
  	l_txn_init_burden_cost_tab.delete;
  	l_txn_init_revenue_tab.delete;
	l_pfc_init_raw_cost_tab.delete;
  	l_pfc_init_burden_cost_tab.delete;
  	l_pfc_init_revenue_tab.delete;
  	l_proj_init_raw_cost_tab.delete;
  	l_proj_init_burden_cost_tab.delete;
  	l_proj_init_revenue_tab.delete;

    IF p_entire_version = 'Y' THEN
       l_stage := 800;
       FETCH all_budget_lines
       BULK COLLECT INTO
             l_txn_row_id_tab
            ,l_resource_assignment_id_tab
            ,l_start_date_tab
            ,l_end_date_tab
            ,l_txn_currency_code_tab
            ,l_txn_raw_cost_tab
            ,l_txn_burdened_cost_tab
            ,l_txn_revenue_tab
            ,l_projfunc_currency_code_tab
            ,l_projfunc_cost_rate_type_tab
            ,l_projfunc_cost_rate_tab
            ,l_projfunc_cost_rt_dt_typ_tab
            ,l_projfunc_cost_rate_date_tab
            ,l_projfunc_rev_rate_type_tab
            ,l_projfunc_rev_rate_tab
            ,l_projfunc_rev_rt_dt_typ_tab
            ,l_projfunc_rev_rate_date_tab
            ,l_proj_currency_code_tab
            ,l_proj_cost_rate_type_tab
            ,l_proj_cost_rate_tab
            ,l_proj_cost_rt_dt_typ_tab
            ,l_proj_cost_rate_date_tab
            ,l_proj_rev_rate_type_tab
            ,l_proj_rev_rate_tab
            ,l_proj_rev_rt_dt_typ_tab
            ,l_proj_rev_rate_date_tab
        /* Perf Bug: 3683132 */
        ,l_fp_cur_projfunc_cost_rt_tab
            ,l_fp_cur_projfunc_rev_rt_tab
            ,l_fp_cur_project_cost_rt_tab
            ,l_fp_cur_project_rev_rt_tab  /* Bug fix: 4204134 LIMIT 1000; */
	    ,l_init_quantity_tab
            ,l_txn_init_raw_cost_tab
            ,l_txn_init_burden_cost_tab
            ,l_txn_init_revenue_tab
	    ,l_pfc_init_raw_cost_tab
            ,l_pfc_init_burden_cost_tab
            ,l_pfc_init_revenue_tab
            ,l_proj_init_raw_cost_tab
            ,l_proj_init_burden_cost_tab
            ,l_proj_init_revenue_tab;
    ELSE
       l_stage := 900;
       FETCH rollup_lines
       BULK COLLECT INTO
             l_txn_row_id_tab
            ,l_resource_assignment_id_tab
            ,l_start_date_tab
            ,l_end_date_tab
            ,l_txn_currency_code_tab
            ,l_txn_raw_cost_tab
            ,l_txn_burdened_cost_tab
            ,l_txn_revenue_tab
            ,l_projfunc_currency_code_tab
            ,l_projfunc_cost_rate_type_tab
            ,l_projfunc_cost_rate_tab
            ,l_projfunc_cost_rt_dt_typ_tab
            ,l_projfunc_cost_rate_date_tab
            ,l_projfunc_rev_rate_type_tab
            ,l_projfunc_rev_rate_tab
            ,l_projfunc_rev_rt_dt_typ_tab
            ,l_projfunc_rev_rate_date_tab
            ,l_proj_currency_code_tab
            ,l_proj_cost_rate_type_tab
            ,l_proj_cost_rate_tab
            ,l_proj_cost_rt_dt_typ_tab
            ,l_proj_cost_rate_date_tab
            ,l_proj_rev_rate_type_tab
            ,l_proj_rev_rate_tab
            ,l_proj_rev_rt_dt_typ_tab
            ,l_proj_rev_rate_date_tab
         /* Perf Bug: 3683132 */
        ,l_fp_cur_projfunc_cost_rt_tab
            ,l_fp_cur_projfunc_rev_rt_tab
            ,l_fp_cur_project_cost_rt_tab
            ,l_fp_cur_project_rev_rt_tab   /* Bug fix: 4204134 LIMIT 1000; */
	    ,l_init_quantity_tab
            ,l_txn_init_raw_cost_tab
            ,l_txn_init_burden_cost_tab
            ,l_txn_init_revenue_tab
	    ,l_pfc_init_raw_cost_tab
            ,l_pfc_init_burden_cost_tab
            ,l_pfc_init_revenue_tab
            ,l_proj_init_raw_cost_tab
            ,l_proj_init_burden_cost_tab
            ,l_proj_init_revenue_tab;

    END IF;

    L_ROWCOUNT := l_txn_row_id_tab.count;

    EXIT WHEN l_rowcount = 0;

    IF l_rowcount > 0 THEN

       l_stage := 1000;
    /* Perf Bug: 3683132 */
    FOR i IN l_resource_assignment_id_tab.FIRST .. l_resource_assignment_id_tab.LAST LOOP
	/* Bug fix:4259098 */
	-- calculate the ETC costs and pass this costs for pc and pfc conversion
	l_txn_raw_cost_tab(i)      := NVL(l_txn_raw_cost_tab(i),0) - NVL(l_txn_init_raw_cost_tab(i),0);
	If l_txn_raw_cost_tab(i) = 0 Then
		l_txn_raw_cost_tab(i) := NULL;
	End If;

        l_txn_burdened_cost_tab(i) := NVL(l_txn_burdened_cost_tab(i),0) - NVL(l_txn_init_burden_cost_tab(i),0);
	If l_txn_burdened_cost_tab(i) = 0 Then
		l_txn_burdened_cost_tab(i) := NULL;
	End If;

        l_txn_revenue_tab(i)       := NVL(l_txn_revenue_tab(i),0) - NVL(l_txn_init_revenue_tab(i),0);
	If l_txn_revenue_tab(i) = 0 Then
		l_txn_revenue_tab(i) := NULL;
	End If;
	/* end of bug fix:4259098 */

        IF l_projfunc_cost_rate_type_tab(i) = 'User' Then
            	If l_projfunc_cost_rate_tab(i) = -9999 Then
            		l_projfunc_cost_rate_tab(i) := l_fp_cur_projfunc_cost_rt_tab(i);
            	End If;
        End If;
        IF l_projfunc_rev_rate_type_tab(i) = 'User' Then
                If l_projfunc_rev_rate_tab(i) = -9999 Then
                        l_projfunc_rev_rate_tab(i) := l_fp_cur_projfunc_rev_rt_tab(i);
                End If;
        End If;

        IF l_proj_cost_rate_type_tab(i) = 'User' Then
                If l_proj_cost_rate_tab(i) = -9999 Then
                        l_proj_cost_rate_tab(i) := l_fp_cur_project_cost_rt_tab(i);
        	End If;
        End If;
        IF l_proj_rev_rate_type_tab(i) = 'User' Then
                If l_proj_rev_rate_tab(i) = -9999 Then
                        l_proj_rev_rate_tab(i) := l_fp_cur_project_rev_rt_tab(i);
                End If;
        End If;
    END LOOP;
    /* End of Perf Bug: 3683132 */

       --hr_utility.trace('Calling conv_mc_bulk...');
       pa_fp_multi_currency_pkg.conv_mc_bulk (
          p_resource_assignment_id_tab  => l_resource_assignment_id_tab
         ,p_start_date_tab              => l_start_date_tab
         ,p_end_date_tab                => l_end_date_tab
         ,p_txn_currency_code_tab       => l_txn_currency_code_tab
         ,p_txn_raw_cost_tab            => l_txn_raw_cost_tab
         ,p_txn_burdened_cost_tab       => l_txn_burdened_cost_tab
         ,p_txn_revenue_tab             => l_txn_revenue_tab
         ,p_projfunc_currency_code_tab  => l_projfunc_currency_code_tab
         ,p_projfunc_cost_rate_type_tab => l_projfunc_cost_rate_type_tab
         ,p_projfunc_cost_rate_tab      => l_projfunc_cost_rate_tab
         ,p_projfunc_cost_rate_date_tab => l_projfunc_cost_rate_date_tab
         ,p_projfunc_rev_rate_type_tab  => l_projfunc_rev_rate_type_tab
         ,p_projfunc_rev_rate_tab       => l_projfunc_rev_rate_tab
         ,p_projfunc_rev_rate_date_tab  => l_projfunc_rev_rate_date_tab
         ,x_projfunc_raw_cost_tab       => l_projfunc_raw_cost_tab
         ,x_projfunc_burdened_cost_tab  => l_projfunc_burdened_cost_tab
         ,x_projfunc_revenue_tab        => l_projfunc_revenue_tab
         ,x_projfunc_rejection_tab      => l_projfunc_rejection_tab
         ,p_proj_currency_code_tab      => l_proj_currency_code_tab
         ,p_proj_cost_rate_type_tab     => l_proj_cost_rate_type_tab
         ,p_proj_cost_rate_tab          => l_proj_cost_rate_tab
         ,p_proj_cost_rate_date_tab     => l_proj_cost_rate_date_tab
         ,p_proj_rev_rate_type_tab      => l_proj_rev_rate_type_tab
         ,p_proj_rev_rate_tab           => l_proj_rev_rate_tab
         ,p_proj_rev_rate_date_tab      => l_proj_rev_rate_date_tab
         ,x_proj_raw_cost_tab           => l_proj_raw_cost_tab
         ,x_proj_burdened_cost_tab      => l_proj_burdened_cost_tab
         ,x_proj_revenue_tab            => l_proj_revenue_tab
         ,x_proj_rejection_tab          => l_proj_rejection_tab
         ,p_user_validate_flag_tab      => l_user_validate_flag_tab
         ,p_calling_module              => p_calling_module -- Added for Bug#5395732
         ,x_return_status               => l_return_status
         ,x_msg_count                   => l_msg_count
         ,x_msg_data                    => l_msg_data);

       l_entire_msg_count := nvl(l_entire_msg_count,0) + nvl(l_msg_count,0);
       l_entire_msg_data  := l_msg_data;

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             l_stage := 1200;
             l_entire_return_status := l_return_status;
          END IF;


       IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          l_stage := 1300;
	  IF l_txn_row_id_tab.COUNT  > 0 THEN --{
             /* Bug fix:4259098: re-calculate the plan cost by adding the actuals to the etc */
                FOR i IN l_txn_row_id_tab.FIRST .. l_txn_row_id_tab.LAST LOOP
                   l_projfunc_raw_cost_tab(i) := NVL(l_projfunc_raw_cost_tab(i),0) + NVL(l_pfc_init_raw_cost_tab(i),0);
                   If l_projfunc_raw_cost_tab(i) = 0 Then
                        l_projfunc_raw_cost_tab(i) := null;
                   End If;

                   l_projfunc_burdened_cost_tab(i) := NVL(l_projfunc_burdened_cost_tab(i),0) + NVL(l_pfc_init_burden_cost_tab(i),0);
                   If l_projfunc_burdened_cost_tab(i) = 0 Then
                        l_projfunc_burdened_cost_tab(i) := NULL;
                   End If;

                   l_projfunc_revenue_tab(i) :=  NVL(l_projfunc_revenue_tab(i),0) + NVL(l_pfc_init_revenue_tab(i),0);
                   If l_projfunc_revenue_tab(i) = 0 Then
                        l_projfunc_revenue_tab(i) := NULL;
                   End If;

                   l_proj_raw_cost_tab(i) := NVL(l_proj_raw_cost_tab(i),0) + NVL(l_proj_init_raw_cost_tab(i),0);
                   If l_proj_raw_cost_tab(i) = 0 Then
                        l_proj_raw_cost_tab(i) := NULL;
                   End If;

                   l_proj_burdened_cost_tab(i) := NVL(l_proj_burdened_cost_tab(i),0) + NVL(l_proj_init_burden_cost_tab(i),0);
                   If l_proj_burdened_cost_tab(i) = 0 Then
                        l_proj_burdened_cost_tab(i) := NULL;
                   End If;
                   l_proj_revenue_tab(i) := NVL(l_proj_revenue_tab(i),0) + NVL(l_proj_init_revenue_tab(i),0);
                   If l_proj_revenue_tab(i) = 0 Then
                        l_proj_revenue_tab(i) := NULL;
                   End If;
                END LOOP;
	  END IF;  --}
	  /* end of bug fix:4259098 */
          IF p_entire_version = 'Y' THEN
             l_stage := 1400;

            L_ROWCOUNT := l_projfunc_currency_code_tab.count;

            IF l_rowcount > 0 THEN
             --hr_utility.trace('Updating pa_budget_lines...');
             FORALL i in 1..l_rowcount
               UPDATE pa_budget_lines
                  SET projfunc_currency_code       = l_projfunc_currency_code_tab(i)
                     ,projfunc_cost_rate_type      = l_projfunc_cost_rate_type_tab(i)
                     ,projfunc_cost_exchange_rate  = l_projfunc_cost_rate_tab(i)
                     ,projfunc_cost_rate_date_type = l_projfunc_cost_rt_dt_typ_tab(i)
                     ,projfunc_cost_rate_date      = DECODE(l_projfunc_cost_rt_dt_typ_tab(i),
                                                     'FIXED_DATE',l_projfunc_cost_rate_date_tab(i),
                                                     NULL)
                     ,projfunc_rev_rate_type       = l_projfunc_rev_rate_type_tab(i)
                     ,projfunc_rev_exchange_rate   = l_projfunc_rev_rate_tab(i)
                     ,projfunc_rev_rate_date_type  = l_projfunc_rev_rt_dt_typ_tab(i)
                     ,projfunc_rev_rate_date       = DECODE(l_projfunc_rev_rt_dt_typ_tab(i),
                                                     'FIXED_DATE',l_projfunc_rev_rate_date_tab(i),
                                                     NULL)
                     ,raw_cost                     = l_projfunc_raw_cost_tab(i)
                     ,burdened_cost                = l_projfunc_burdened_cost_tab(i)
                     ,revenue                      = l_projfunc_revenue_tab(i)
                     ,pfc_cur_conv_rejection_code  = l_projfunc_rejection_tab(i)
                     ,project_currency_code        = l_proj_currency_code_tab(i)
                     ,project_cost_rate_type       = l_proj_cost_rate_type_tab(i)
                     ,project_cost_exchange_rate   = l_proj_cost_rate_tab(i)
                     ,project_cost_rate_date_type  = l_proj_cost_rt_dt_typ_tab(i)
                     ,project_cost_rate_date       = DECODE(l_proj_cost_rt_dt_typ_tab(i),
                                                     'FIXED_DATE',l_proj_cost_rate_date_tab(i),
                                                     NULL)
                     ,project_rev_rate_type        = l_proj_rev_rate_type_tab(i)
                     ,project_rev_exchange_rate    = l_proj_rev_rate_tab(i)
                     ,project_rev_rate_date_type   = l_proj_rev_rt_dt_typ_tab(i)
                     ,project_rev_rate_date        = DECODE(l_proj_rev_rt_dt_typ_tab(i),
                                                     'FIXED_DATE',l_proj_rev_rate_date_tab(i),
                                                     NULL)
                     ,project_raw_cost             = l_proj_raw_cost_tab(i)
                     ,project_burdened_cost        = l_proj_burdened_cost_tab(i)
                     ,project_revenue              = l_proj_revenue_tab(i)
                     ,pc_cur_conv_rejection_code   = l_proj_rejection_tab(i)
               WHERE rowid                         = l_txn_row_id_tab(i);
             END IF;
          ELSE

           L_ROWCOUNT := l_projfunc_currency_code_tab.count;

           IF l_rowcount > 0 THEN
             --hr_utility.trace('Updating pa_fp_rollup_tmp...');
             l_stage := 1500;
             FORALL i in 1..l_rowcount
               UPDATE pa_fp_rollup_tmp
                  SET projfunc_currency_code       = l_projfunc_currency_code_tab(i)
                     ,projfunc_cost_rate_type      = l_projfunc_cost_rate_type_tab(i)
                     ,projfunc_cost_exchange_rate  = l_projfunc_cost_rate_tab(i)
                     ,projfunc_cost_rate_date_type = l_projfunc_cost_rt_dt_typ_tab(i)
                     ,projfunc_cost_rate_date      = DECODE(l_projfunc_cost_rt_dt_typ_tab(i),
                                                     'FIXED_DATE',l_projfunc_cost_rate_date_tab(i),
                                                     NULL)
                     ,projfunc_rev_rate_type       = l_projfunc_rev_rate_type_tab(i)
                     ,projfunc_rev_exchange_rate   = l_projfunc_rev_rate_tab(i)
                     ,projfunc_rev_rate_date_type  = l_projfunc_rev_rt_dt_typ_tab(i)
                     ,projfunc_rev_rate_date       = DECODE(l_projfunc_rev_rt_dt_typ_tab(i),
                                                     'FIXED_DATE',l_projfunc_rev_rate_date_tab(i),
                                                     NULL)
                     ,projfunc_raw_cost            = l_projfunc_raw_cost_tab(i)
                     ,projfunc_burdened_cost       = l_projfunc_burdened_cost_tab(i)
                     ,projfunc_revenue             = l_projfunc_revenue_tab(i)
                     ,pfc_cur_conv_rejection_code  = l_projfunc_rejection_tab(i)
                     ,project_currency_code        = l_proj_currency_code_tab(i)
                     ,project_cost_rate_type       = l_proj_cost_rate_type_tab(i)
                     ,project_cost_exchange_rate   = l_proj_cost_rate_tab(i)
                     ,project_cost_rate_date_type  = l_proj_cost_rt_dt_typ_tab(i)
                     ,project_cost_rate_date       = DECODE(l_proj_cost_rt_dt_typ_tab(i),
                                                     'FIXED_DATE',l_proj_cost_rate_date_tab(i),
                                                     NULL)
                     ,project_rev_rate_type        = l_proj_rev_rate_type_tab(i)
                     ,project_rev_exchange_rate    = l_proj_rev_rate_tab(i)
                     ,project_rev_rate_date_type   = l_proj_rev_rt_dt_typ_tab(i)
                     ,project_rev_rate_date        = DECODE(l_proj_rev_rt_dt_typ_tab(i),
                                                     'FIXED_DATE',l_proj_rev_rate_date_tab(i),
                                                     NULL)
                     ,project_raw_cost             = l_proj_raw_cost_tab(i)
                     ,project_burdened_cost        = l_proj_burdened_cost_tab(i)
                     ,project_revenue              = l_proj_revenue_tab(i)
                     ,pc_cur_conv_rejection_code   = l_proj_rejection_tab(i)
               WHERE rowid                         = l_txn_row_id_tab(i);
           END IF;
          END IF; -- entire_version or not
       END IF; -- returned success
    END IF; -- rowcount > 0

  EXCEPTION WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                  p_data  => x_msg_data);
       x_msg_count := FND_MSG_PUB.Count_Msg;
       IF x_msg_count = 1 THEN
        IF x_msg_data IS NOT NULL THEN
             FND_MESSAGE.SET_ENCODED (x_msg_data);
             x_msg_data := FND_MESSAGE.GET;
        END IF;
       END IF;

        fnd_msg_pub.add_exc_msg
           ( p_pkg_name       => 'PA_FP_MULTI_CURRENCY_PKG'
            ,p_procedure_name => 'convert_txn_currency' );
        pa_debug.g_err_stage := 'Stage : '||to_char(l_stage)||' '||substr(SQLERRM,1,240);
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('convert_txn_currency: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;
        --hr_utility.trace('PA_FP_MULTI_CURRENCY_PKG.convert_txn_currency -- Stage : ' ||to_char(l_stage)||' '||substr(SQLERRM,1,240));
        /* bug 4227840: wrapping the setting of debug error stack call to
         * pa_debug under the debug enbaling check
         */
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.reset_err_stack;
        END IF;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  END LOOP;

  IF p_entire_version = 'Y' THEN
     CLOSE all_budget_lines;
  ELSE
     CLOSE rollup_lines;
  END IF;

       x_return_status := l_entire_return_status;
       fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                  p_data  => x_msg_data);
       x_msg_count := FND_MSG_PUB.Count_Msg;
       IF x_msg_count = 1 THEN
        IF x_msg_data IS NOT NULL THEN
             FND_MESSAGE.SET_ENCODED (x_msg_data);
             x_msg_data := FND_MESSAGE.GET;
        END IF;
       END IF;

       /* bug 4227840: wrapping the setting of debug error stack call to
       * pa_debug under the debug enbaling check
       */
      IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.reset_err_stack;
      END IF;

  EXCEPTION WHEN OTHERS THEN
       fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                  p_data  => x_msg_data);
       x_msg_count := FND_MSG_PUB.Count_Msg;
       IF x_msg_count = 1 THEN
        IF x_msg_data IS NOT NULL THEN
             FND_MESSAGE.SET_ENCODED (x_msg_data);
             x_msg_data := FND_MESSAGE.GET;
        END IF;
       END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_msg_pub.add_exc_msg
           ( p_pkg_name       => 'PA_FP_MULTI_CURRENCY_PKG'
            ,p_procedure_name => 'convert_txn_currency' );
        pa_debug.g_err_stage := 'Stage : '||to_char(l_stage)||' '||substr(SQLERRM,1,240);
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('convert_txn_currency: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;
        --hr_utility.trace('PA_FP_MULTI_CURRENCY_PKG.convert_txn_currency -- Stage : ' ||to_char(l_stage)||' '||substr(SQLERRM,1,240));
        /* bug 4227840: wrapping the setting of debug error stack call to
         * pa_debug under the debug enbaling check
         */
        IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.reset_err_stack;
        END IF;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END convert_txn_currency;

/*=============================================================================
 This api is used to Round budget line amounts as per the currency precision/
 MAU (Minimum Accountable Unit). Quantity would be rounded to 5 decimal points.
 The api would be called from Copy Version Amounts flow with non-zero adj %
 The api is also called Change Order Revenue amount partial implementation.

 p_calling_context -> COPY_VERSION, CHANGE_ORDER_MERGE
 The parameters p_bls_inserted_after_id  will be used only
 when p_calling_context is CHANGE_ORDER_MERGE
 p_bls_inserted_after_id : This value will be used to find out the budget lines that
                           got inserted in this flow. All the budget lines with
                           1. budget line id > p_bls_inserted_after_id AND
                           2. budget_Version_id = p_budget_version_id
                           will be considered as inserted in this flow.

 Tracking bug No: 4035856  Rravipat  Initial creation
==============================================================================*/

PROCEDURE Round_Budget_Line_Amounts(
           p_budget_version_id      IN   pa_budget_versions.budget_version_id%TYPE
          ,p_bls_inserted_after_id  IN   pa_budget_lines.budget_line_id%TYPE        DEFAULT NULL
          ,p_calling_context        IN   VARCHAR2
          ,x_return_status          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count              OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data               OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

    -- variables used for debugging
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER := 0;
    l_msg_data           VARCHAR2(2000);
    l_data               VARCHAR2(2000);
    l_msg_index_out      NUMBER;
    l_debug_mode         VARCHAR2(30);

    -- nested tables to hold amount and currency columns
    l_txn_row_id_tab              pa_fp_multi_currency_pkg.rowid_type_tab;
    l_resource_assignment_id_tab  pa_fp_multi_currency_pkg.number_type_tab;
    l_start_date_tab              pa_fp_multi_currency_pkg.date_type_tab;
    l_quantity_tab                pa_fp_multi_currency_pkg.number_type_tab;

    --Code changes for bug 4200168 starts here.
    --l_txn_currency_code_tab       pa_fp_multi_currency_pkg.char30_type_tab;
    -- l_txn_raw_cost_tab            pa_fp_multi_currency_pkg.number_type_tab;
    --l_txn_burdened_cost_tab       pa_fp_multi_currency_pkg.number_type_tab;
    --l_txn_revenue_tab             pa_fp_multi_currency_pkg.number_type_tab;
    l_txn_currency_code_tab       SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
    l_txn_raw_cost_tab            SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    l_txn_burdened_cost_tab       SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    l_txn_revenue_tab             SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

    /*l_projfunc_currency_code_tab  pa_fp_multi_currency_pkg.char30_type_tab;
    l_projfunc_raw_cost_tab       pa_fp_multi_currency_pkg.number_type_tab;
    l_projfunc_burdened_cost_tab  pa_fp_multi_currency_pkg.number_type_tab;
    l_projfunc_revenue_tab        pa_fp_multi_currency_pkg.number_type_tab;
    l_proj_currency_code_tab      pa_fp_multi_currency_pkg.char30_type_tab;
    l_proj_raw_cost_tab           pa_fp_multi_currency_pkg.number_type_tab;
    l_proj_burdened_cost_tab      pa_fp_multi_currency_pkg.number_type_tab;
    l_proj_revenue_tab            pa_fp_multi_currency_pkg.number_type_tab;*/

    l_projfunc_currency_code_tab  SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
    l_proj_currency_code_tab      SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();

    l_projfunc_raw_cost_tab       SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    l_projfunc_burdened_cost_tab  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    l_projfunc_revenue_tab        SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

    l_proj_raw_cost_tab           SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    l_proj_burdened_cost_tab      SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    l_proj_revenue_tab            SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

    --these tables below are introduced to store values when the txn, projfunc and project currency are not equal
    -- for any budget line.

	l_projfunc_raw_cost_tmp_tab      SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
	l_prjfnc_burdened_cost_tmp_tab   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
	l_projfunc_revenue_tmp_tab		 SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
	l_proj_raw_cost_tmp_tab          SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
	l_proj_burdened_cost_tmp_tab	 SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
	l_proj_revenue_tmp_tab			 SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    l_pfc_tmp_tab                    SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();  --store the projfunc currency code.
    l_pc_tmp_tab                     SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();  -- store the proj currency code.
    --Code changes for bug 4200168 ends here.

 --Bug 4052403
    l_rate_based_flag_tab         pa_plsql_datatypes.Char1TabTyp;
    l_version_type                pa_budget_versions.version_type%TYPE;

    -- cursor to fetch budget line amounts
    -- Changes in this cursor might have to be done in budget_line_amounts_cur1 also
    -- Bug 4052403. Selected rate_based_flag
    CURSOR budget_line_amounts_cur IS
    SELECT pbl.ROWID, pbl.resource_assignment_id,pbl.start_date, pbl.quantity,
           pbl.raw_cost, pbl.burdened_cost, pbl.revenue,pbl.projfunc_currency_code,
           pbl.project_raw_cost, pbl.project_burdened_cost, pbl.project_revenue, pbl.project_currency_code,
           pbl.txn_raw_cost, pbl.txn_burdened_cost, pbl.txn_revenue, pbl.txn_currency_code, pra.rate_based_flag
    FROM  pa_budget_lines pbl,
          pa_resource_assignments pra
    WHERE pbl.budget_version_id = p_budget_version_id
    AND   pra.resource_assignment_id=pbl.resource_assignment_id
    ORDER BY pbl.txn_currency_code;

    -- This cursor is same as budget_line_amounts_cur. This will be used in CHANGE_ORDER_MERGE context
    -- Changes in this cursor might have to be done in budget_line_amounts_cur also
    -- Bug 4052403. Selected rate_based_flag
    CURSOR budget_line_amounts_cur1
    IS
    SELECT pbl.ROWID, pbl.resource_assignment_id,pbl.start_date, pbl.quantity,
           pbl.raw_cost, pbl.burdened_cost, pbl.revenue,pbl.projfunc_currency_code,
           pbl.project_raw_cost, pbl.project_burdened_cost, pbl.project_revenue, pbl.project_currency_code,
           pbl.txn_raw_cost, pbl.txn_burdened_cost, pbl.txn_revenue, pbl.txn_currency_code, pra.rate_based_flag
    FROM  pa_budget_lines  pbl,
          pa_resource_assignments pra
    WHERE pbl.budget_version_id = p_budget_version_id
    AND   pra.resource_assignment_id=pbl.resource_assignment_id
    AND   budget_line_id > p_bls_inserted_after_id
    ORDER BY pbl.txn_currency_code;

BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

    /* bug 4227840: wrapping the setting of debug error stack call to
    * pa_debug under the debug enbaling check
    */
   IF l_debug_mode = 'Y' THEN
        -- set curr function
        pa_debug.set_curr_function(
                    p_function   =>'PA_FP_MULTI_CURRENCY_PKG.Round_Budget_Line_Amounts'
                   ,p_debug_mode => l_debug_mode );
    END IF;

    -- check for business rules violations
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Validating input parameters';
        pa_debug.write('Round_Budget_Line_Amounts: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_budget_version_id IS NULL) OR (p_calling_context IS NULL) OR
       (p_calling_context NOT IN ('COPY_VERSION','CHANGE_ORDER_MERGE'))
    THEN

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='p_budget_version_id = '||p_budget_version_id;
           pa_debug.write('Round_Budget_Line_Amounts: ' || g_module_name,pa_debug.g_err_stage,5);

           pa_debug.g_err_stage:='p_calling_context = '||p_calling_context;
           pa_debug.write('Round_Budget_Line_Amounts: ' || g_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                              p_token1         => 'PROCEDURENAME',
                              p_value1         => 'PA_FP_MULTI_CURRENCY_PKG.Round_Budget_Line_Amounts',
                              p_token2         => 'STAGE',
                              p_value2         => 'p_budget_version_id  '||p_budget_version_id ||' p_calling_context '||p_calling_context );

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    IF p_calling_context='CHANGE_ORDER_MERGE' AND
       nvl(p_bls_inserted_after_id,0) <= 0 THEN

        IF l_debug_mode = 'Y' THEN

           pa_debug.g_err_stage:='p_bls_inserted_after_id = '||p_bls_inserted_after_id;
           pa_debug.write('Round_Budget_Line_Amounts: ' || g_module_name,pa_debug.g_err_stage,5);

        END IF;

        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                              p_token1         => 'PROCEDURENAME',
                              p_value1         => 'PA_FP_MULTI_CURRENCY_PKG.Round_Budget_Line_Amounts',
                              p_token2         => 'STAGE',
                              p_value2         => 'p_bls_inserted_after_id '||p_bls_inserted_after_id);


        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    --Bug 4052403. Select the version type of the budget version for which the API is called
    SELECT version_type
    INTO   l_version_type
    FROM   pa_budget_versions
    WHERE  budget_version_id=p_budget_version_id;

    -- open and fetch PC,PFC and txn cur amounts of the budget version
    IF p_calling_context='CHANGE_ORDER_MERGE' THEN

        OPEN budget_line_amounts_cur1;

    ELSE

        OPEN budget_line_amounts_cur;

    END IF;

    LOOP

        l_txn_row_id_tab.delete;
        l_resource_assignment_id_tab.delete;
        l_start_date_tab.delete;
        l_quantity_tab.delete;
        l_projfunc_raw_cost_tab.delete;
        l_projfunc_burdened_cost_tab.delete;
        l_projfunc_revenue_tab.delete;
        l_projfunc_currency_code_tab.delete;
        l_proj_raw_cost_tab.delete;
        l_proj_burdened_cost_tab.delete;
        l_proj_revenue_tab.delete;
        l_proj_currency_code_tab.delete;
        l_txn_raw_cost_tab.delete;
        l_txn_burdened_cost_tab.delete;
        l_txn_revenue_tab.delete;
        l_txn_currency_code_tab.delete;
        l_rate_based_flag_tab.delete;--Bug 4052403
        l_projfunc_raw_cost_tmp_tab.delete;     -- Added for bug 4290451.
        l_prjfnc_burdened_cost_tmp_tab.delete;  -- Added for bug 4290451.
        l_projfunc_revenue_tmp_tab.delete;      -- Added for bug 4290451.
        l_proj_raw_cost_tmp_tab.delete;         -- Added for bug 4290451.
        l_proj_burdened_cost_tmp_tab.delete;    -- Added for bug 4290451.
        l_proj_revenue_tmp_tab.delete;          -- Added for bug 4290451.
        l_pfc_tmp_tab.delete;                   -- Added for bug 4290451.
        l_pc_tmp_tab.delete;                    -- Added for bug 4290451.


        IF p_calling_context='CHANGE_ORDER_MERGE' THEN

            FETCH budget_line_amounts_cur1
            BULK COLLECT INTO
                  l_txn_row_id_tab
                 ,l_resource_assignment_id_tab
                 ,l_start_date_tab
                 ,l_quantity_tab
                 ,l_projfunc_raw_cost_tab
                 ,l_projfunc_burdened_cost_tab
                 ,l_projfunc_revenue_tab
                 ,l_projfunc_currency_code_tab
                 ,l_proj_raw_cost_tab
                 ,l_proj_burdened_cost_tab
                 ,l_proj_revenue_tab
                 ,l_proj_currency_code_tab
                 ,l_txn_raw_cost_tab
                 ,l_txn_burdened_cost_tab
                 ,l_txn_revenue_tab
                 ,l_txn_currency_code_tab
                 ,l_rate_based_flag_tab;
             /* Bug fix: 4204134 LIMIT 1000; */

        ELSE

            FETCH budget_line_amounts_cur
            BULK COLLECT INTO
                 l_txn_row_id_tab
                 ,l_resource_assignment_id_tab
                 ,l_start_date_tab
                 ,l_quantity_tab
                 ,l_projfunc_raw_cost_tab
                 ,l_projfunc_burdened_cost_tab
                 ,l_projfunc_revenue_tab
                 ,l_projfunc_currency_code_tab
                 ,l_proj_raw_cost_tab
                 ,l_proj_burdened_cost_tab
                 ,l_proj_revenue_tab
                 ,l_proj_currency_code_tab
                 ,l_txn_raw_cost_tab
                 ,l_txn_burdened_cost_tab
                 ,l_txn_revenue_tab
                 ,l_txn_currency_code_tab
                 ,l_rate_based_flag_tab ;
             /* Bug fix: 4204134 LIMIT 1000; */

        END IF;

        -- exit if there are no rows to be processed
        EXIT WHEN l_txn_row_id_tab.count = 0;

       --Code changes for bug 4200168 starts here.
       l_txn_raw_cost_tab :=
                       Pa_currency.round_currency_amt_nested_blk(l_txn_raw_cost_tab,
                                                             l_txn_currency_code_tab);
       l_txn_burdened_cost_tab :=
                       Pa_currency.round_currency_amt_nested_blk(l_txn_burdened_cost_tab,
                                                             l_txn_currency_code_tab);
       l_txn_revenue_tab :=
                       Pa_currency.round_currency_amt_nested_blk(l_txn_revenue_tab,
                                                             l_txn_currency_code_tab);
      --Code changes for bug 4200168 ends here.

        --PC and PFC amounts will be derived/rounded by the Multi Currency API when the context is
        --COPY_VERSION. MC API will be called from the calling API in this context
        IF p_calling_context <> 'COPY_VERSION' THEN

            -- If PFC currency is equal to txn currency copy the rounded txn amount
            -- as PFC amount else call rounding util api
            FOR i IN l_txn_row_id_tab.first .. l_txn_row_id_tab.last
            LOOP

                --Code addition for bug#4290451.starts here.
                l_projfunc_raw_cost_tmp_tab.extend;
                l_prjfnc_burdened_cost_tmp_tab.extend;
                l_projfunc_revenue_tmp_tab.extend;
                l_proj_raw_cost_tmp_tab.extend;
                l_proj_burdened_cost_tmp_tab.extend;
                l_proj_revenue_tmp_tab.extend;
                l_pfc_tmp_tab.extend;
                l_pc_tmp_tab.extend;
                --Code addition for bug#4290451.ends here.

                --Code changes for bug 4200168 starts here.
                IF l_txn_currency_code_tab(i) = l_projfunc_currency_code_tab(i) THEN
                    l_projfunc_raw_cost_tab(i)                  := l_txn_raw_cost_tab(i);
                    l_projfunc_burdened_cost_tab(i)             := l_txn_burdened_cost_tab(i);
                    l_projfunc_revenue_tab(i)                   := l_txn_revenue_tab(i);
                     --Added for bug 4290451
                    l_projfunc_raw_cost_tmp_tab(i)              := l_txn_raw_cost_tab(i);
                    l_prjfnc_burdened_cost_tmp_tab(i)           := l_txn_burdened_cost_tab(i);
                    l_projfunc_revenue_tmp_tab(i)               :=l_txn_revenue_tab(i);
                    l_pfc_tmp_tab(i)                            := l_projfunc_currency_code_tab(i);
                ELSE
                    l_projfunc_raw_cost_tmp_tab(i)              := l_projfunc_raw_cost_tab(i) ;
                    l_prjfnc_burdened_cost_tmp_tab(i)           := l_projfunc_burdened_cost_tab(i) ;
                    l_projfunc_revenue_tmp_tab(i)               := l_projfunc_revenue_tab(i) ;
                    l_pfc_tmp_tab(i)                            := l_projfunc_currency_code_tab(i);
                END IF;

                IF l_proj_currency_code_tab(i) = l_projfunc_currency_code_tab(i) THEN
                    l_proj_raw_cost_tab(i)                      := l_projfunc_raw_cost_tab(i);
                    l_proj_burdened_cost_tab(i)                 := l_projfunc_burdened_cost_tab(i);
                    l_proj_revenue_tab(i)                       := l_projfunc_revenue_tab(i);
                    --Added for bug 4290451
                    l_proj_raw_cost_tmp_tab(i)                  := l_projfunc_raw_cost_tab(i);
                    l_proj_burdened_cost_tmp_tab(i)             := l_projfunc_burdened_cost_tab(i);
                    l_proj_revenue_tmp_tab(i)                   := l_projfunc_revenue_tab(i);
                    l_pc_tmp_tab(i)                             := l_proj_currency_code_tab(i);
                ELSIF l_proj_currency_code_tab(i) = l_txn_currency_code_tab(i) THEN
                    l_proj_raw_cost_tab(i)                      := l_txn_raw_cost_tab(i);
                    l_proj_burdened_cost_tab(i)                 := l_txn_burdened_cost_tab(i);
                    l_proj_revenue_tab(i)                       := l_txn_revenue_tab(i);
                    --Added for bug 4290451
                    l_proj_raw_cost_tmp_tab(i)                  := l_txn_raw_cost_tab(i);
                    l_proj_burdened_cost_tmp_tab(i)             := l_txn_burdened_cost_tab(i);
                    l_proj_revenue_tmp_tab(i)                   := l_txn_revenue_tab(i);
                    l_pc_tmp_tab(i)                             := l_proj_currency_code_tab(i);
                ELSE
                    l_proj_raw_cost_tmp_tab(i)                  := l_proj_raw_cost_tab(i);
                    l_proj_burdened_cost_tmp_tab(i)             := l_proj_burdened_cost_tab(i);
                    l_proj_revenue_tmp_tab(i)                   := l_proj_revenue_tab(i);
                    l_pc_tmp_tab(i)                             := l_proj_currency_code_tab(i);
                END IF;
            END LOOP;

            l_projfunc_raw_cost_tmp_tab :=
                       Pa_currency.round_currency_amt_nested_blk(l_projfunc_raw_cost_tmp_tab,
                                                             l_pfc_tmp_tab);
            l_prjfnc_burdened_cost_tmp_tab :=
                   Pa_currency.round_currency_amt_nested_blk(l_prjfnc_burdened_cost_tmp_tab,
                                                         l_pfc_tmp_tab);
            l_projfunc_revenue_tmp_tab :=
                   Pa_currency.round_currency_amt_nested_blk(l_projfunc_revenue_tmp_tab,
                                                         l_pfc_tmp_tab);

            l_proj_raw_cost_tmp_tab :=
                   Pa_currency.round_currency_amt_nested_blk(l_proj_raw_cost_tmp_tab,
                                                         l_pc_tmp_tab);
            l_proj_burdened_cost_tmp_tab :=
                   Pa_currency.round_currency_amt_nested_blk(l_proj_burdened_cost_tmp_tab,
                                                         l_pc_tmp_tab);
            l_proj_revenue_tmp_tab :=
                   Pa_currency.round_currency_amt_nested_blk(l_proj_revenue_tmp_tab,
                                                         l_pc_tmp_tab);


            IF l_projfunc_raw_cost_tmp_tab.FIRST > 0 OR l_proj_raw_cost_tmp_tab.FIRST> 0 THEN

                FOR i IN l_txn_row_id_tab.first .. l_txn_row_id_tab.last
                LOOP
                    IF i BETWEEN l_projfunc_raw_cost_tmp_tab.FIRST AND l_projfunc_raw_cost_tmp_tab.LAST THEN
                        l_projfunc_raw_cost_tab(i)          :=  l_projfunc_raw_cost_tmp_tab(i);
                        l_projfunc_burdened_cost_tab(i)     :=  l_prjfnc_burdened_cost_tmp_tab(i);
                        l_projfunc_revenue_tab(i)      :=  l_projfunc_revenue_tmp_tab(i);
                    END IF;
                    IF i BETWEEN l_proj_raw_cost_tmp_tab.FIRST AND l_proj_raw_cost_tmp_tab.LAST THEN
                        l_proj_raw_cost_tab(i)              :=  l_proj_raw_cost_tmp_tab(i);
                        l_proj_burdened_cost_tab(i)         :=  l_proj_burdened_cost_tmp_tab(i);
                        l_proj_revenue_tab(i)               :=  l_proj_revenue_tmp_tab(i);
                    END IF;
                END LOOP;
            END IF;
            --Code changes for bug 4200168 ends here.
        END IF; --IF p_calling_context <> 'COPY_VERSION' THEN

        -- Update pa_budget_lines with the rounded amounts
        --Bug 4052403. In the Updates below, made sure that for non rate-based planning transactions, the quanity is updated to
        --raw cost/revenue as the case may be
        IF p_calling_context = 'COPY_VERSION' THEN
            -- Update txn currency amounts well, PC and PFC amounts would be null at this point of time
            -- Stamp cost rate, burden cost rate and bill rate as overrides
            FORALL i in l_txn_row_id_tab.first .. l_txn_row_id_tab.last
            UPDATE PA_BUDGET_LINES
            SET    --While deriving the override rates below, the expression used here for calculating quantity is used.
                   --Hence whenever this derivation is changed, the change has to be reflected below in override rate
                   --derivation also
                    quantity                     = Decode(l_rate_based_flag_tab(i),
                                                          'N',Decode(l_version_type,
                                                                     'REVENUE',l_txn_revenue_tab(i),
                                                                     l_txn_raw_cost_tab(i)),
                                                           round(l_quantity_tab(i),5))
                   ,txn_raw_cost                 = l_txn_raw_cost_tab(i)
                   ,txn_burdened_cost            = l_txn_burdened_cost_tab(i)
                   ,txn_revenue                  = l_txn_revenue_tab(i)
                   ,txn_cost_rate_override       = Decode(Decode(l_rate_based_flag_tab(i),
                                                          'N',Decode(l_version_type,
                                                                     'REVENUE',l_txn_revenue_tab(i),
                                                                     l_txn_raw_cost_tab(i)),
                                                           round(l_quantity_tab(i),5)),
                                                           null, null,
                                                           0,0,
                                                           l_txn_raw_cost_tab(i)/(Decode(l_rate_based_flag_tab(i),
                                                                                         'N',Decode(l_version_type,
                                                                                                    'REVENUE',l_txn_revenue_tab(i),
                                                                                                     l_txn_raw_cost_tab(i)),
                                                                                          round(l_quantity_tab(i),5))))
                   ,burden_cost_rate_override    = Decode(Decode(l_rate_based_flag_tab(i),
                                                                 'N',Decode(l_version_type,
                                                                            'REVENUE',l_txn_revenue_tab(i),
                                                                             l_txn_raw_cost_tab(i)),
                                                                  round(l_quantity_tab(i),5)),
                                                          null, null,
                                                          0,0,
                                                          l_txn_burdened_cost_tab(i)/(Decode(l_rate_based_flag_tab(i),
                                                                                             'N',Decode(l_version_type,
                                                                                                        'REVENUE',l_txn_revenue_tab(i),
                                                                                                        l_txn_raw_cost_tab(i)),
                                                                                              round(l_quantity_tab(i),5))))
                   ,txn_bill_rate_override       = Decode(Decode(l_rate_based_flag_tab(i),
                                                                 'N',Decode(l_version_type,
                                                                            'REVENUE',l_txn_revenue_tab(i),
                                                                             l_txn_raw_cost_tab(i)),
                                                                  round(l_quantity_tab(i),5)),
                                                                  null, null,
                                                                  0,0,
                                                                  l_txn_revenue_tab(i)/(Decode(l_rate_based_flag_tab(i),
                                                                                               'N',Decode(l_version_type,
                                                                                                          'REVENUE',l_txn_revenue_tab(i),
                                                                                                          l_txn_raw_cost_tab(i)),
                                                                                               round(l_quantity_tab(i),5))))
            WHERE  rowid = l_txn_row_id_tab(i);
        ELSIF p_calling_context = 'CHANGE_ORDER_MERGE' THEN
            -- Update TXN,PFC,PC amounts Stampe cost rate, budrden cost rate and bill rate as overrides
            -- If any line is affected by change order merge, then cur conv rate type is stamped as 'USER'
            -- All other lines would have rounded amounts any way and the program should not alter them
            -- So only exchange rate column is updated for those lines with 'USER' as the rate type
            FORALL i in l_txn_row_id_tab.first .. l_txn_row_id_tab.last
            UPDATE PA_BUDGET_LINES
            SET     quantity                     = Decode(l_rate_based_flag_tab(i),
                                                          'N',Decode(l_version_type,
                                                                     'REVENUE',l_txn_revenue_tab(i),
                                                                     l_txn_raw_cost_tab(i)),
                                                           round(l_quantity_tab(i),5))
                   ,raw_cost                     = l_projfunc_raw_cost_tab(i)
                   ,burdened_cost                = l_projfunc_burdened_cost_tab(i)
                   ,revenue                      = l_projfunc_revenue_tab(i)
                   ,project_raw_cost             = l_proj_raw_cost_tab(i)
                   ,project_burdened_cost        = l_proj_burdened_cost_tab(i)
                   ,project_revenue              = l_proj_revenue_tab(i)
                   ,txn_raw_cost                 = l_txn_raw_cost_tab(i)
                   ,txn_burdened_cost            = l_txn_burdened_cost_tab(i)
                   ,txn_revenue                  = l_txn_revenue_tab(i)
                   ,txn_cost_rate_override       = Decode(Decode(l_rate_based_flag_tab(i),
                                                          'N',Decode(l_version_type,
                                                                     'REVENUE',l_txn_revenue_tab(i),
                                                                     l_txn_raw_cost_tab(i)),
                                                           round(l_quantity_tab(i),5)),
                                                           null, null,
                                                           0,0,
                                                           l_txn_raw_cost_tab(i)/(Decode(l_rate_based_flag_tab(i),
                                                                                         'N',Decode(l_version_type,
                                                                                                    'REVENUE',l_txn_revenue_tab(i),
                                                                                                     l_txn_raw_cost_tab(i)),
                                                                                          round(l_quantity_tab(i),5))))
                   ,burden_cost_rate_override    = Decode(Decode(l_rate_based_flag_tab(i),
                                                                 'N',Decode(l_version_type,
                                                                            'REVENUE',l_txn_revenue_tab(i),
                                                                             l_txn_raw_cost_tab(i)),
                                                                  round(l_quantity_tab(i),5)),
                                                          null, null,
                                                          0,0,
                                                          l_txn_burdened_cost_tab(i)/(Decode(l_rate_based_flag_tab(i),
                                                                                             'N',Decode(l_version_type,
                                                                                                        'REVENUE',l_txn_revenue_tab(i),
                                                                                                        l_txn_raw_cost_tab(i)),
                                                                                              round(l_quantity_tab(i),5))))
                   ,txn_bill_rate_override       = Decode(Decode(l_rate_based_flag_tab(i),
                                                                 'N',Decode(l_version_type,
                                                                            'REVENUE',l_txn_revenue_tab(i),
                                                                             l_txn_raw_cost_tab(i)),
                                                                  round(l_quantity_tab(i),5)),
                                                                  null, null,
                                                                  0,0,
                                                                  l_txn_revenue_tab(i)/(Decode(l_rate_based_flag_tab(i),
                                                                                               'N',Decode(l_version_type,
                                                                                                          'REVENUE',l_txn_revenue_tab(i),
                                                                                                          l_txn_raw_cost_tab(i)),
                                                                                               round(l_quantity_tab(i),5))))
                   ,projfunc_rev_exchange_rate   = Decode(projfunc_rev_rate_type, 'User',
                                                             Decode(l_txn_revenue_tab(i), null, null, 0,0, l_projfunc_revenue_tab(i)/l_txn_revenue_tab(i))
                                                             ,null)
                   ,project_cost_exchange_rate   = Decode(project_cost_rate_type, 'User',
                                                             Decode(l_txn_raw_cost_tab(i), null, null, 0,0, l_proj_raw_cost_tab(i)/l_txn_raw_cost_tab(i))
                                                             ,null)
                   ,project_rev_exchange_rate    = Decode(project_rev_rate_type, 'User',
                                                             Decode(l_txn_revenue_tab(i), null, null, 0,0, l_proj_revenue_tab(i)/l_txn_revenue_tab(i))
                                                             ,null)
            WHERE  rowid = l_txn_row_id_tab(i);

        END IF;

    END LOOP; -- Budget line amounts Cur loop
    IF p_calling_context='CHANGE_ORDER_MERGE' THEN

        CLOSE budget_line_amounts_cur1;

    ELSE

        CLOSE budget_line_amounts_cur;

    END IF;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Exiting Round_Budget_Line_Amounts';
        pa_debug.write('Round_Budget_Line_Amounts: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    /* bug 4227840: wrapping the setting of debug error stack call to
     * pa_debug under the debug enbaling check
     */
    IF l_debug_mode = 'Y' THEN
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
           pa_debug.write('Round_Budget_Line_Amounts: ' || g_module_name,pa_debug.g_err_stage,5);

       END IF;
       /* bug 4227840: wrapping the setting of debug error stack call to
        * pa_debug under the debug enbaling check
        */
       IF l_debug_mode = 'Y' THEN
           -- reset curr function
           pa_debug.reset_curr_function();
       END IF;
       RETURN;
   WHEN Others THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FP_MULTI_CURRENCY_PKG'
                               ,p_procedure_name  => 'Round_Budget_Line_Amounts');

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write('Round_Budget_Line_Amounts: ' || g_module_name,pa_debug.g_err_stage,5);
       END IF;

       /* bug 4227840: wrapping the setting of debug error stack call to
        * pa_debug under the debug enbaling check
        */
       IF l_debug_mode = 'Y' THEN
           -- reset curr function
           pa_debug.Reset_Curr_Function();
       END IF;
       RAISE;
END Round_Budget_Line_Amounts;

-->This API is written as part of rounding changes. This API will be called from PAFPCIMB.implement_ci_into_single_ver
-->API when partial implementation happens.
---->p_agr_currency_code,p_project_currency_code and p_projfunc_currency_code should be valid and not null
---->All the p_...tbl input parameters should have same no. of elemeents
---->p_txn...tbls will be rounded based on p_agr_currency_code, p_project_...tbls will be rounded based on
     --p_project_currency_code and p_projfunc_...tbls will be rounded based on p_projfunc_currency_code
---->px_quantity_tbl will be rounded to have max 5 digits after decimal point
PROCEDURE round_amounts
( px_quantity_tbl               IN OUT  NOCOPY SYSTEM.pa_num_tbl_type
 ,p_agr_currency_code           IN OUT         NOCOPY pa_budget_lines.txn_currency_code%TYPE          --File.Sql.39 bug 4440895
 ,px_txn_raw_cost_tbl           IN OUT  NOCOPY SYSTEM.pa_num_tbl_type
 ,px_txn_burdened_cost_tbl      IN OUT  NOCOPY SYSTEM.pa_num_tbl_type
 ,px_txn_revenue_tbl            IN OUT  NOCOPY SYSTEM.pa_num_tbl_type
 ,p_project_currency_code       IN OUT         NOCOPY pa_budget_lines.project_currency_code%TYPE      --File.Sql.39 bug 4440895
 ,px_project_raw_cost_tbl       IN OUT  NOCOPY SYSTEM.pa_num_tbl_type
 ,px_project_burdened_cost_tbl  IN OUT  NOCOPY SYSTEM.pa_num_tbl_type
 ,px_project_revenue_tbl        IN OUT  NOCOPY SYSTEM.pa_num_tbl_type
 ,p_projfunc_currency_code      IN OUT         NOCOPY pa_budget_lines.projfunc_currency_code%TYPE     --File.Sql.39 bug 4440895
 ,px_projfunc_raw_cost_tbl      IN OUT  NOCOPY SYSTEM.pa_num_tbl_type
 ,px_projfunc_burdened_cost_tbl IN OUT  NOCOPY SYSTEM.pa_num_tbl_type
 ,px_projfunc_revenue_tbl       IN OUT  NOCOPY SYSTEM.pa_num_tbl_type
 ,x_return_status                  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                      OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                       OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
    --Start of variables used for debugging
    l_return_status                            VARCHAR2(1);
    l_msg_count                                NUMBER := 0;
    l_msg_data                                 VARCHAR2(2000);
    l_data                                     VARCHAR2(2000);
    l_msg_index_out                            NUMBER;
    l_debug_mode                               VARCHAR2(30);
    l_debug_level3                    CONSTANT NUMBER :=3;
    l_debug_level5                    CONSTANT NUMBER :=5;
    l_module_name                              VARCHAR2(200) :=   'PAFPMCPB.round_amounts';

    --Code changes for bug 4200168 starts here.
    l_agr_currency_code_tbl  SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
    l_project_currency_code_tbl SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
    l_projfunc_currency_code_tbl SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
    --Code changes for bug 4200168 ends here.

BEGIN
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

    /* bug 4227840: wrapping the setting of debug error stack call to
     * pa_debug under the debug enbaling check
     */
    IF l_debug_mode = 'Y' THEN
        -- Set curr function
        pa_debug.set_curr_function(
                    p_function   =>'pafpmcpb.round_amounts'
                   ,p_debug_mode => l_debug_mode );
    END IF;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Validating input parameters';
        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
    END IF;

    --Currency codes should not be valid
    IF p_agr_currency_code IS NULL OR
       p_project_currency_code IS NULL OR
       p_projfunc_currency_code IS NULL THEN

        IF l_debug_mode = 'Y' THEN

            pa_debug.g_err_stage:='p_agr_currency_code '||p_agr_currency_code;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

            pa_debug.g_err_stage:='p_project_currency_code '||p_project_currency_code;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

            pa_debug.g_err_stage:='p_projfunc_currency_code '||p_projfunc_currency_code;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name        => 'PA_FP_INV_PARAM_PASSED',
                            p_token1          => 'PROCEDURENAME',
                            p_value1          => 'PAFPMCPB.ROUND_AMOUNTS',
                            p_token2          => 'STAGE',
                            p_value2          => 'Currency Codes are Invalid');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    --All the amount tbls should be equal in length
    IF px_txn_raw_cost_tbl.COUNT <> px_txn_burdened_cost_tbl.COUNT OR
       px_txn_raw_cost_tbl.COUNT <> px_txn_revenue_tbl.COUNT OR
       px_txn_raw_cost_tbl.COUNT <> px_project_raw_cost_tbl.COUNT OR
       px_txn_raw_cost_tbl.COUNT <> px_project_burdened_cost_tbl.COUNT OR
       px_txn_raw_cost_tbl.COUNT <> px_project_revenue_tbl.COUNT OR
       px_txn_raw_cost_tbl.COUNT <> px_projfunc_raw_cost_tbl.COUNT OR
       px_txn_raw_cost_tbl.COUNT <> px_projfunc_burdened_cost_tbl.COUNT OR
       px_txn_raw_cost_tbl.COUNT <> px_projfunc_revenue_tbl.COUNT OR
       px_txn_raw_cost_tbl.COUNT <> px_quantity_tbl.COUNT  THEN

        IF l_debug_mode = 'Y' THEN

            pa_debug.g_err_stage:='px_txn_raw_cost_tbl.COUNT '||px_txn_raw_cost_tbl.COUNT;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

            pa_debug.g_err_stage:='px_txn_burdened_cost_tbl.COUNT '||px_txn_burdened_cost_tbl.COUNT;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

            pa_debug.g_err_stage:='px_txn_revenue_tbl.COUNT '||px_txn_revenue_tbl.COUNT;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

            pa_debug.g_err_stage:='px_project_raw_cost_tbl.COUNT '||px_project_raw_cost_tbl.COUNT;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

            pa_debug.g_err_stage:='px_project_burdened_cost_tbl.COUNT '||px_project_burdened_cost_tbl.COUNT;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

            pa_debug.g_err_stage:='px_project_revenue_tbl.COUNT '||px_project_revenue_tbl.COUNT;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

            pa_debug.g_err_stage:='px_projfunc_raw_cost_tbl.COUNT '||px_projfunc_raw_cost_tbl.COUNT;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

            pa_debug.g_err_stage:='px_projfunc_burdened_cost_tbl.COUNT '||px_projfunc_burdened_cost_tbl.COUNT;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

            pa_debug.g_err_stage:='px_projfunc_revenue_tbl.COUNT '||px_projfunc_revenue_tbl.COUNT;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name        => 'PA_FP_INV_PARAM_PASSED',
                            p_token1          => 'PROCEDURENAME',
                            p_value1          => 'PAFPMCPB.ROUND_AMOUNTS',
                            p_token2          => 'STAGE',
                            p_value2          => 'Amount tbls are inconsistent');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    IF px_txn_raw_cost_tbl.COUNT=0 THEN

        IF l_debug_mode = 'Y' THEN

            pa_debug.g_err_stage:='Input tbls are empty. Returning';
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);

        END IF;
        /* bug 4227840: wrapping the setting of debug error stack call to
         * pa_debug under the debug enbaling check
         */
        IF l_debug_mode = 'Y' THEN
            pa_debug.reset_curr_function;
        END IF;
        RETURN;

    END IF;

    --Round the quantity
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Rounding Quantity';
        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
    END IF;

    FOR i IN 1..px_quantity_tbl.COUNT LOOP

        IF px_quantity_tbl(i)<>0 THEN

            px_quantity_tbl(i):=round(px_quantity_tbl(i),5);

        END IF;

    END LOOP;

    --In 3 for loops written below all the txn/pc/pfc amounts will be rounded. 3 For loops are written to take advantage
    --of caching logic in Pa_currency.round_trans_currency_amt1

    --Round the agr currency amounts.
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Rounding agr amounts';
        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
    END IF;

    --Code changes for bug 4200168 starts here.

    FOR i IN 1..px_txn_raw_cost_tbl.COUNT LOOP
       l_agr_currency_code_tbl.extend;        --added for bug#4290451

       l_agr_currency_code_tbl(i) := p_agr_currency_code;


    END LOOP;

             px_txn_raw_cost_tbl := Pa_currency.round_currency_amt_nested_blk(px_txn_raw_cost_tbl,
                                                                             l_agr_currency_code_tbl);

             px_txn_burdened_cost_tbl := Pa_currency.round_currency_amt_nested_blk(px_txn_burdened_cost_tbl,
                                                                                  l_agr_currency_code_tbl);

             px_txn_revenue_tbl := Pa_currency.round_currency_amt_nested_blk(px_txn_revenue_tbl,
                                                                            l_agr_currency_code_tbl);
     --Code changes for bug 4200168 ends here.



    --Round the project currency amounts.
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Rounding project amounts';
        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
    END IF;

    IF p_agr_currency_code=p_project_currency_code THEN

        px_project_raw_cost_tbl      :=  px_txn_raw_cost_tbl     ;
        px_project_burdened_cost_tbl :=  px_txn_burdened_cost_tbl;
        px_project_revenue_tbl       :=  px_txn_revenue_tbl      ;

    ELSE
        --Code changes for bug 4200168 starts here.
        FOR i IN 1..px_project_raw_cost_tbl.COUNT LOOP
               l_project_currency_code_tbl.extend;    --added for bug#4290451
               l_project_currency_code_tbl(i) := p_project_currency_code;
        END LOOP;

             px_project_raw_cost_tbl := Pa_currency.round_currency_amt_nested_blk(px_project_raw_cost_tbl,
                                                                             l_project_currency_code_tbl);

             px_project_burdened_cost_tbl := Pa_currency.round_currency_amt_nested_blk(px_project_burdened_cost_tbl,
                                                                                  l_project_currency_code_tbl);

             px_project_revenue_tbl := Pa_currency.round_currency_amt_nested_blk(px_project_revenue_tbl,
                                                                            l_project_currency_code_tbl);
       --Code changes for bug 4200168 starts here.
    END IF;

    --Round the Project Functional Currency Amounts
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Rounding project functional amounts';
        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
    END IF;

    IF p_agr_currency_code=p_projfunc_currency_code THEN

        px_projfunc_raw_cost_tbl      :=  px_txn_raw_cost_tbl     ;
        px_projfunc_burdened_cost_tbl :=  px_txn_burdened_cost_tbl;
        px_projfunc_revenue_tbl       :=  px_txn_revenue_tbl      ;

    ELSIF p_project_currency_code=p_projfunc_currency_code THEN

        px_projfunc_raw_cost_tbl      :=  px_project_raw_cost_tbl     ;
        px_projfunc_burdened_cost_tbl :=  px_project_burdened_cost_tbl;
        px_projfunc_revenue_tbl       :=  px_project_revenue_tbl      ;

    ELSE
        --Code changes for bug 4200168 starts here.
        FOR i IN 1..px_projfunc_raw_cost_tbl.COUNT LOOP
               l_projfunc_currency_code_tbl.extend;     --added for bug#4290451
               l_projfunc_currency_code_tbl(i) := p_projfunc_currency_code;
        END LOOP;
            px_projfunc_raw_cost_tbl := Pa_currency.round_currency_amt_nested_blk(px_projfunc_raw_cost_tbl,
                                                                             l_projfunc_currency_code_tbl);

             px_projfunc_burdened_cost_tbl := Pa_currency.round_currency_amt_nested_blk(px_projfunc_burdened_cost_tbl,
                                                                                  l_projfunc_currency_code_tbl);

             px_projfunc_revenue_tbl := Pa_currency.round_currency_amt_nested_blk(px_projfunc_revenue_tbl,
                                                                            l_projfunc_currency_code_tbl);
       --Code changes for bug 4200168 starts here.
    END IF;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Exiting round_amounts';
        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
    END IF;
    /* bug 4227840: wrapping the setting of debug error stack call to
     * pa_debug under the debug enbaling check
     */
    IF l_debug_mode = 'Y' THEN
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
           pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

       END IF;
       /* bug 4227840: wrapping the setting of debug error stack call to
        * pa_debug under the debug enbaling check
        */
       IF l_debug_mode = 'Y' THEN
           -- reset curr function
           pa_debug.reset_curr_function();
       END IF;
       RETURN;
   WHEN OTHERS THEN

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FP_MULTI_CURRENCY_PKG'
                               ,p_procedure_name  => 'round_amounts');

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
       END IF;
       /* bug 4227840: wrapping the setting of debug error stack call to
        * pa_debug under the debug enbaling check
        */
       IF l_debug_mode = 'Y' THEN
           -- reset curr function
           pa_debug.Reset_Curr_Function();
       END IF;
       RAISE;

END round_amounts;

END PA_FP_MULTI_CURRENCY_PKG;

/
