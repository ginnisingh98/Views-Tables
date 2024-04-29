--------------------------------------------------------
--  DDL for Package Body PA_FP_GEN_BILLING_AMOUNTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_GEN_BILLING_AMOUNTS" as
/* $Header: PAFPGABB.pls 120.5 2007/02/06 09:54:47 dthakker ship $ */

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

FUNCTION GET_EVENT_DATE(P_EVENT_DATE       IN    DATE,
                        P_ETC_START_DATE   IN    DATE,
                        P_PLAN_CLASS_CODE  IN    VARCHAR2)
RETURN DATE IS
  x_event_date   DATE;
  x_etc_start_date   DATE;
  BEGIN
      x_event_date := p_event_date;
      x_etc_start_date := p_etc_start_date;
      IF p_plan_class_code = 'BUDGET' THEN
         RETURN x_event_date;
      ELSIF p_plan_class_code = 'FORECAST' THEN
           IF p_event_date < p_etc_start_date THEN
              RETURN x_etc_start_date;
           END IF;
      END IF;
      RETURN x_event_date;

  EXCEPTION
    WHEN OTHERS THEN
         RETURN TRUNC(SYSDATE);
  END GET_EVENT_DATE;

PROCEDURE CONVERT_TXN_AMT_TO_PC_PFC
          (P_PROJECT_ID                 IN  NUMBER,
           P_BUDGET_VERSION_ID          IN  NUMBER,
           P_RES_ASG_ID                 IN  NUMBER,
           P_START_DATE                 IN  DATE,
           P_END_DATE                   IN  DATE,
           P_CURRENCY_CODE              IN  VARCHAR2,
           P_TXN_REV_AMOUNT             IN  NUMBER,
           P_TXN_RAW_COST               IN NUMBER,
           P_TXN_BURDENED_COST          IN NUMBER,
           X_PROJFUNC_RAW_COST              OUT NOCOPY    NUMBER,
           X_PROJFUNC_BURDENED_COST         OUT NOCOPY    NUMBER,
           X_PROJFUNC_REVENUE               OUT NOCOPY    NUMBER,
           X_PROJFUNC_REJECTION             OUT NOCOPY    VARCHAR2,
           X_PROJ_RAW_COST                  OUT NOCOPY    NUMBER,
           X_PROJ_BURDENED_COST             OUT NOCOPY    NUMBER,
           X_PROJ_REVENUE                   OUT NOCOPY    NUMBER,
           X_PROJ_REJECTION                 OUT NOCOPY    VARCHAR2,
           X_RETURN_STATUS                  OUT NOCOPY    VARCHAR2,
           X_MSG_COUNT                      OUT NOCOPY    NUMBER,
           X_MSG_DATA                       OUT NOCOPY    VARCHAR2) IS

l_module_name         VARCHAR2(200) :=
         'pa.plsql.PA_FP_GEN_BILLING_AMOUNTS.CONVERT_TXN_AMT_TO_PC_PFC';

/* Local variables pa_fp_multi_currency_pkg.conv_mc_bulk */
 l_res_asn_id_tab                    pa_fp_multi_currency_pkg.number_type_tab;
 l_start_date_tab                    pa_fp_multi_currency_pkg.date_type_tab;
 l_end_date_tab                      pa_fp_multi_currency_pkg.date_type_tab;
 l_txn_currency_code_tab             pa_fp_multi_currency_pkg.char240_type_tab;
 l_txn_rw_cost_tab                   pa_fp_multi_currency_pkg.number_type_tab;
 l_txn_burdend_cost_tab              pa_fp_multi_currency_pkg.number_type_tab;
 l_txn_rev_tab                       pa_fp_multi_currency_pkg.number_type_tab;
 l_projfunc_currency_code_tab        pa_fp_multi_currency_pkg.char240_type_tab;
 l_projfunc_cost_rate_type_tab       pa_fp_multi_currency_pkg.char240_type_tab;
 l_projfunc_cost_rate_tab            pa_fp_multi_currency_pkg.number_type_tab;
 l_projfunc_cost_rate_date_tab       pa_fp_multi_currency_pkg.date_type_tab;
 l_projfunc_rev_rate_type_tab        pa_fp_multi_currency_pkg.char240_type_tab;
 l_projfunc_rev_rate_tab             pa_fp_multi_currency_pkg.number_type_tab;
 l_projfunc_rev_rate_date_tab        pa_fp_multi_currency_pkg.date_type_tab;
 l_projfunc_raw_cost_tab             pa_fp_multi_currency_pkg.number_type_tab;
 l_projfunc_burdened_cost_tab        pa_fp_multi_currency_pkg.number_type_tab;
 l_projfunc_revenue_tab              pa_fp_multi_currency_pkg.number_type_tab;
 l_projfunc_rejection_tab            pa_fp_multi_currency_pkg.char30_type_tab;
 l_proj_raw_cost_tab                 pa_fp_multi_currency_pkg.number_type_tab;
 l_proj_burdened_cost_tab            pa_fp_multi_currency_pkg.number_type_tab;
 l_proj_revenue_tab                  pa_fp_multi_currency_pkg.number_type_tab;
 l_proj_rejection_tab                pa_fp_multi_currency_pkg.char30_type_tab;
 l_proj_currency_code_tab            pa_fp_multi_currency_pkg.char240_type_tab;
 l_proj_cost_rate_type_tab           pa_fp_multi_currency_pkg.char240_type_tab;
 l_proj_cost_rate_tab                pa_fp_multi_currency_pkg.number_type_tab;
 l_proj_cost_rate_date_tab           pa_fp_multi_currency_pkg.date_type_tab;
 l_proj_rev_rate_type_tab            pa_fp_multi_currency_pkg.char240_type_tab;
 l_proj_rev_rate_tab                 pa_fp_multi_currency_pkg.number_type_tab;
 l_proj_rev_rate_date_tab            pa_fp_multi_currency_pkg.date_type_tab;
 l_user_validate_flag_tab            pa_fp_multi_currency_pkg.char240_type_tab;
/* end */

 l_count                             NUMBER;
 l_msg_count                         NUMBER;
 l_data                              VARCHAR2(1000);
 l_msg_data                          VARCHAR2(1000);
 l_msg_index_out                     NUMBER;
 l_pc_code pa_projects_all.project_currency_code%type;
 l_pfc_code pa_projects_all.project_currency_code%type;
 l_project_name      pa_projects_all.name%TYPE;
 l_task_id           pa_tasks.task_id%TYPE;
 l_task_name         pa_proj_elements.name%TYPE;
 l_resource_name     pa_resource_list_members.alias%TYPE;
BEGIN
  /* Setting initial values */
    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function     => 'CONVERT_TXN_AMT_TO_PC_PFC'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
    END IF;

    /*Bug 4151764 neet to get project_name, task_name, resource_name for the error message*/

    SELECT project_currency_code,projfunc_currency_code, name
    INTO l_pc_code , l_pfc_code, l_project_name
    FROM pa_projects_all
    WHERE project_id = p_project_id;

    IF p_res_asg_id is NULL THEN
       l_task_name := null;
       l_resource_name := null;
    ELSE
       BEGIN
          SELECT prlm.alias, nvl(ra.task_id,0)
          INTO   l_resource_name, l_task_id
          FROM   pa_resource_list_members prlm, pa_Resource_assignments ra
          WHERE  ra.resource_assignment_id = p_res_asg_id
	  AND 	 ra.resource_list_member_id = prlm.resource_list_member_id;
       EXCEPTION
          WHEN OTHERS THEN
            l_resource_name := null;
       END;

       IF l_task_id > 0 THEN
            BEGIN
               SELECT task_name
               INTO l_task_name
               FROM pa_tasks
               WHERE task_id = l_task_id;
            EXCEPTION
               WHEN OTHERS THEN
                  l_task_name := null;
            END;
       ELSE
           l_task_name := null;
       END IF;

    END IF;

      --Calling  the conv_mc_bulk api
          IF p_pa_debug_mode = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
                 (p_msg         => 'Before calling
                  pa_fp_multi_currency_pkg.conv_mc_bulk',
                  p_module_name => l_module_name,
                  p_log_level   => 5);
          END IF;

               l_res_asn_id_tab.delete;
               l_start_date_tab.delete;
               l_end_date_tab.delete;
               l_txn_currency_code_tab.delete;
               l_txn_rev_tab.delete;
               l_txn_rw_cost_tab.delete;
               l_txn_burdend_cost_tab.delete;
               l_projfunc_currency_code_tab.delete;
               l_projfunc_cost_rate_type_tab.delete;
               l_projfunc_cost_rate_tab.delete;
               l_projfunc_cost_rate_date_tab.delete;
               l_projfunc_rev_rate_type_tab.delete;
               l_projfunc_rev_rate_tab.delete;
               l_projfunc_rev_rate_date_tab.delete;
               l_projfunc_raw_cost_tab.delete;
               l_projfunc_burdened_cost_tab.delete;
               l_projfunc_revenue_tab.delete;
               l_projfunc_rejection_tab.delete;
               l_proj_raw_cost_tab.delete;
               l_proj_burdened_cost_tab.delete;
               l_proj_revenue_tab.delete;
               l_proj_rejection_tab.delete;
               l_proj_currency_code_tab.delete;
               l_proj_cost_rate_type_tab.delete;
               l_proj_cost_rate_tab.delete;
               l_proj_cost_rate_date_tab.delete;
               l_proj_rev_rate_type_tab.delete;
               l_proj_rev_rate_tab.delete;
               l_proj_rev_rate_date_tab.delete;
               l_user_validate_flag_tab.delete;

               l_res_asn_id_tab(1)        := p_res_asg_id;
               l_start_date_tab(1)        := p_start_date;
               l_end_date_tab(1)          := p_end_date;
               l_txn_currency_code_tab(1) := p_currency_code;
               l_txn_rev_tab(1)           := p_txn_rev_amount;
               /*dbms_output.put_line('----values passed to conv_mc_bulk----');
               dbms_output.put_line('l_res_asn_id_tab(1):'||l_res_asn_id_tab(1));
               dbms_output.put_line('l_start_date_tab(1):'||l_start_date_tab(1));
               dbms_output.put_line('l_end_date_tab(1):'|| l_end_date_tab(1));
               dbms_output.put_line('l_txn_currency_code_tab(1):'||l_txn_currency_code_tab(1));
               dbms_output.put_line('l_txn_rev_tab(1):'|| l_txn_rev_tab(1)); */

               -- Bug 5112436 (SQL Repository ID 16507222):
               -- Modified the sql to join on proj_fp_options_id instead
               -- of fin_plan_version_id. This avoids a Full Table Scan.

               /*when p_res_asg_id is null, need to rely on p_budget_version_id to get the
                 conversion attribute. */
               SELECT  PROJECT_REV_RATE_TYPE,
                       DECODE(opt.PROJECT_REV_RATE_TYPE,
                              'User', NULL,
                              DECODE(opt.PROJECT_REV_RATE_DATE_TYPE,
                                     'START_DATE',P_START_DATE,
                                     'END_DATE'  ,P_END_DATE,
                                     opt.PROJECT_REV_RATE_DATE)),
                       DECODE(opt.PROJECT_REV_RATE_TYPE,
                              'User', tc.PROJECT_REV_EXCHANGE_RATE,
                              NULL),
                       PROJFUNC_REV_RATE_TYPE,
                       DECODE(opt.PROJFUNC_REV_RATE_TYPE,
                              'User', NULL,
                              DECODE(opt.PROJFUNC_REV_RATE_DATE_TYPE,
                                     'START_DATE',P_START_DATE,
                                     'END_DATE'  ,P_END_DATE,
                                     opt.PROJFUNC_REV_RATE_DATE)),
                       DECODE(opt.PROJFUNC_REV_RATE_TYPE,
                              'User', tc.PROJFUNC_REV_EXCHANGE_RATE,
                              NULL)
               INTO l_proj_rev_rate_type_tab(1),
                    l_proj_rev_rate_date_tab(1),
                    l_proj_rev_rate_tab(1),
                    l_projfunc_rev_rate_type_tab(1),
                    l_projfunc_rev_rate_date_tab(1),
                    l_projfunc_rev_rate_tab(1)
               FROM pa_proj_fp_options opt,
                    pa_fp_txn_currencies tc
               WHERE opt.fin_plan_version_id = P_BUDGET_VERSION_ID
                     --AND opt.fin_plan_version_id = tc.fin_plan_version_id(+)
                     AND opt.proj_fp_options_id = tc.proj_fp_options_id(+) /* Added for Bug 5112436 */
                     AND tc.txn_currency_code(+) = p_currency_code;
               /*dbms_output.put_line('l_proj_rev_rate_type_tab(1):'|| l_proj_rev_rate_type_tab(1));
               dbms_output.put_line('l_proj_rev_rate_date_tab(1):'||l_proj_rev_rate_date_tab(1));
               dbms_output.put_line('l_proj_rev_rate_tab(1):'||l_proj_rev_rate_tab(1));
               dbms_output.put_line('l_projfunc_rev_rate_type_tab(1):'|| l_projfunc_rev_rate_type_tab(1));
               dbms_output.put_line('l_projfunc_rev_rate_date_tab(1):'||l_projfunc_rev_rate_date_tab(1));
               dbms_output.put_line('  l_projfunc_rev_rate_tab(1):'||l_projfunc_rev_rate_tab(1)); */

               l_txn_rw_cost_tab(1) := null;
               l_txn_burdend_cost_tab(1) := null;

               l_proj_currency_code_tab(1) := l_pc_code;
               l_proj_cost_rate_tab(1)    := null;
               l_proj_cost_rate_type_tab(1) := null;
               l_proj_cost_rate_date_tab(1) := null;

               l_projfunc_currency_code_tab(1) := l_pfc_code;
               l_projfunc_cost_rate_tab(1):= null;
               l_projfunc_cost_rate_type_tab(1) := null;
               l_projfunc_cost_rate_date_tab(1) := null;

               l_user_validate_flag_tab(1) := null;

               PA_FP_MULTI_CURRENCY_PKG.CONV_MC_BULK(
                                   p_resource_assignment_id_tab  => l_res_asn_id_tab
                                  ,p_start_date_tab              => l_start_date_tab
                                  ,p_end_date_tab                => l_end_date_tab
                                  ,p_txn_currency_code_tab       => l_txn_currency_code_tab
                                  ,p_txn_raw_cost_tab            => l_txn_rw_cost_tab
                                  ,p_txn_burdened_cost_tab       => l_txn_burdend_cost_tab
                                  ,p_txn_revenue_tab             => l_txn_rev_tab
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
                                  ,p_calling_module              => 'BUDGET_GENERATION' ---- Added for  Bug 5395732
                                  ,x_return_status               => x_return_status
                                  ,x_msg_count                   => x_msg_count
                                  ,x_msg_data                    => x_msg_data);
               IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
               END IF;
               IF p_pa_debug_mode = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                    (p_msg         => 'Status after calling
                     pa_fp_multi_currency_pkg.conv_mc_bulk: '
                                         ||x_return_status,
                     p_module_name => l_module_name,
                     p_log_level   => 5);
               END IF;

              if l_projfunc_rejection_tab(1) is not null then
                 l_projfunc_rejection_tab(1) := substr(l_projfunc_rejection_tab(1),1,30);
              end if;
              if l_proj_rejection_tab(1) is not null then
                 l_proj_rejection_tab(1) := substr(l_proj_rejection_tab(1),1,30);
              end if;
              x_projfunc_raw_cost         := l_projfunc_raw_cost_tab(1);
              x_projfunc_burdened_cost    := l_projfunc_burdened_cost_tab(1);
              x_projfunc_revenue          := l_projfunc_revenue_tab(1);
              x_projfunc_rejection        := l_projfunc_rejection_tab(1);
              x_proj_raw_cost             := l_proj_raw_cost_tab(1);
              x_proj_burdened_cost        := l_proj_burdened_cost_tab(1);
              x_proj_revenue              := l_proj_revenue_tab(1);
              x_proj_rejection            := l_proj_rejection_tab(1);

/* Bug4151764  Added token-values for the error msg in case of rejection */
              IF x_projfunc_rejection is not null then
                 x_return_status        := FND_API.G_RET_STS_ERROR;
                 PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                      p_msg_name       => x_projfunc_rejection,
                       p_token1         => 'PROJECT' ,
                       p_value1         => l_project_name,
                       p_token2         => 'TASK',
                       p_value2         => l_task_name,
                       p_token3         => 'RESOURCE_NAME',
                       p_value3         => l_resource_name,
                       p_token4         => 'RATE_DATE',
                       p_value4         => l_projfunc_rev_rate_date_tab(1),
                       p_token5         => 'TXN_CURRENCY',
                       p_value5         => l_txn_currency_code_tab(1));
              end if;

              IF x_proj_rejection is not null then
                 x_return_status        := FND_API.G_RET_STS_ERROR;
                 PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                      p_msg_name       => x_proj_rejection,
                       p_token1         => 'PROJECT' ,
                       p_value1         => l_project_name,
                       p_token2         => 'TASK',
                       p_value2         => l_task_name,
                       p_token3         => 'RESOURCE_NAME',
                       p_value3         => l_resource_name,
                       p_token4         => 'RATE_DATE',
                       p_value4         => l_proj_rev_rate_date_tab(1),
                       p_token5         => 'TXN_CURRENCY',
                       p_value5         => l_txn_currency_code_tab(1));
              end if;
         /* dbms_output.put_line('Value of x_projfunc_raw_cost: '||x_projfunc_raw_cost);
         dbms_output.put_line('Value of x_projfunc_burdened_cost: '||x_projfunc_burdened_cost);
         dbms_output.put_line('Value of x_projfunc_revenue: '||x_projfunc_revenue);
         dbms_output.put_line('Value of x_projfunc_rejection: '||x_projfunc_rejection);
         dbms_output.put_line('Value of x_proj_raw_cost: '||x_proj_raw_cost);
         dbms_output.put_line('Value of x_proj_burdened_cost: '||x_proj_burdened_cost);
         dbms_output.put_line('Value of x_proj_revenue: '||x_proj_revenue);
         dbms_output.put_line('Value of x_proj_rejection: '||x_proj_rejection); */

    IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_curr_function;
    END IF;
 EXCEPTION
   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
   -- Bug Fix: 4569365. Removed MRC code.
   --   PA_MRC_FINPLAN.G_CALLING_MODULE := Null;
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

      x_return_status := FND_API.G_RET_STS_ERROR;
      IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_curr_function;
      END IF;
      RAISE;

    WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      := SUBSTR(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_BILLING_AMOUNTS'
              ,p_procedure_name => 'CONVERT_TXN_AMT_TO_PC_PFC');

     IF P_PA_DEBUG_MODE = 'Y' THEN
         PA_DEBUG.Reset_curr_function;
     END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END CONVERT_TXN_AMT_TO_PC_PFC;


PROCEDURE GEN_BILLING_AMOUNTS
          (P_PROJECT_ID                     IN              PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID              IN              PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC                    IN              PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_ETC_START_DATE      IN
              PA_BUDGET_VERSIONS.ETC_START_DATE%TYPE,
           PX_GEN_RES_ASG_ID_TAB            IN OUT NOCOPY   PA_PLSQL_DATATYPES.IdTabTyp,
           PX_DELETED_RES_ASG_ID_TAB        IN OUT NOCOPY   PA_PLSQL_DATATYPES.IdTabTyp,
           X_RETURN_STATUS                  OUT   NOCOPY    VARCHAR2,
           X_MSG_COUNT                      OUT   NOCOPY    NUMBER,
           X_MSG_DATA                       OUT   NOCOPY    VARCHAR2) IS

l_module_name         VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_BILLING_AMOUNTS.GEN_BILLING_AMOUNTS';

--Cursor used to sum the revenue amount
CURSOR   SUM_BILL_CRSR(c_tphase        PA_PROJ_FP_OPTIONS.COST_TIME_PHASED_CODE%TYPE,
                  c_appl_id            GL_PERIOD_STATUSES.APPLICATION_ID%TYPE,
                  c_set_of_books_id    PA_IMPLEMENTATIONS_ALL.SET_OF_BOOKS_ID%TYPE,
                  c_org_id             PA_PROJECTS_ALL.ORG_ID%TYPE,
                  c_multi_flag         PA_PROJ_FP_OPTIONS.PLAN_IN_MULTI_CURR_FLAG%TYPE,
                  c_etc_start_date     PA_BUDGET_VERSIONS.ETC_START_DATE%TYPE,
                  c_plan_class_code    PA_FIN_PLAN_TYPES_B.PLAN_CLASS_CODE%TYPE)
IS
SELECT   /*+ INDEX(TMP,PA_RES_LIST_MAP_TMP4_N2)*/
         P.RESOURCE_ASSIGNMENT_ID,
         V.BILL_TRANS_CURRENCY_CODE,
         PAP.PERIOD_NAME,
         PAP.START_DATE,
         PAP.END_DATE,
         SUM(DECODE(ET.EVENT_TYPE_CLASSIFICATION,
                    'WRITE OFF', -1 * NVL(V.BILL_TRANS_REV_AMOUNT,0),
                    'REALIZED_LOSSES',  -1 * NVL(V.BILL_TRANS_REV_AMOUNT,0),
                    NVL(V.BILL_TRANS_REV_AMOUNT,0)))
FROM     PA_EVENTS_DELIVERABLE_V V,
         PA_EVENT_TYPES ET,
         PA_RES_LIST_MAP_TMP4 TMP,
         PA_RESOURCE_ASSIGNMENTS P,
         PA_PERIODS PAP
WHERE    TMP.TXN_SOURCE_ID         = V.EVENT_ID
AND      V.EVENT_TYPE              = ET.EVENT_TYPE
AND      V.PROJECT_ID              = P_PROJECT_ID
AND      P.RESOURCE_ASSIGNMENT_ID  = TMP.TXN_RESOURCE_ASSIGNMENT_ID
AND      P.BUDGET_VERSION_ID       = P_BUDGET_VERSION_ID
AND      c_tphase                  = 'P'
AND      V.EVENT_DATE             >= NVL(c_etc_start_date, V.EVENT_DATE)
AND      V.EVENT_DATE  BETWEEN  PAP.START_DATE AND PAP.END_DATE
GROUP BY P.RESOURCE_ASSIGNMENT_ID,
         V.BILL_TRANS_CURRENCY_CODE,
         PAP.PERIOD_NAME,
         PAP.START_DATE,
         PAP.END_DATE
UNION ALL
SELECT   /*+ INDEX(TMP,PA_RES_LIST_MAP_TMP4_N2)*/
         P.RESOURCE_ASSIGNMENT_ID,
         V.BILL_TRANS_CURRENCY_CODE,
         GLP.PERIOD_NAME,
         GLP.START_DATE,
         GLP.END_DATE,
         SUM(DECODE(ET.EVENT_TYPE_CLASSIFICATION,
                    'WRITE OFF', -1 * NVL(V.BILL_TRANS_REV_AMOUNT,0),
                    'REALIZED_LOSSES',  -1 * NVL(V.BILL_TRANS_REV_AMOUNT,0),
                    NVL(V.BILL_TRANS_REV_AMOUNT,0)))
FROM     PA_EVENTS_DELIVERABLE_V V,
         PA_EVENT_TYPES ET,
         PA_RES_LIST_MAP_TMP4 TMP,
         PA_RESOURCE_ASSIGNMENTS P,
         GL_PERIOD_STATUSES GLP
WHERE    TMP.TXN_SOURCE_ID         = V.EVENT_ID
AND      V.EVENT_TYPE              = ET.EVENT_TYPE
AND      V.PROJECT_ID              = P_PROJECT_ID
AND      P.RESOURCE_ASSIGNMENT_ID  = TMP.TXN_RESOURCE_ASSIGNMENT_ID
AND      P.BUDGET_VERSION_ID       = P_BUDGET_VERSION_ID
AND      c_tphase                  = 'G'
AND      V.EVENT_DATE             >= NVL(c_etc_start_date, V.EVENT_DATE)
AND      V.EVENT_DATE  BETWEEN  GLP.START_DATE AND GLP.END_DATE
AND      GLP.APPLICATION_ID         = c_appl_id
AND      GLP.SET_OF_BOOKS_ID        = c_set_of_books_id
AND      GLP.ADJUSTMENT_PERIOD_FLAG = 'N'
GROUP BY P.RESOURCE_ASSIGNMENT_ID,
         V.BILL_TRANS_CURRENCY_CODE,
         GLP.PERIOD_NAME,
         GLP.START_DATE,
         GLP.END_DATE
UNION ALL
SELECT   /*+ INDEX(TMP,PA_RES_LIST_MAP_TMP4_N2)*/
         P.RESOURCE_ASSIGNMENT_ID,
         V.BILL_TRANS_CURRENCY_CODE,
         TO_CHAR(NULL),
         GET_EVENT_DATE(V.EVENT_DATE,c_etc_start_date,c_plan_class_code),
         GET_EVENT_DATE(V.EVENT_DATE,c_etc_start_date,c_plan_class_code),
         SUM(DECODE(ET.EVENT_TYPE_CLASSIFICATION,
                    'WRITE OFF', -1 * NVL(V.BILL_TRANS_REV_AMOUNT,0),
                    'REALIZED_LOSSES',  -1 * NVL(V.BILL_TRANS_REV_AMOUNT,0),
                    NVL(V.BILL_TRANS_REV_AMOUNT,0)))
FROM     PA_EVENTS_DELIVERABLE_V V,
         PA_EVENT_TYPES ET,
         PA_RES_LIST_MAP_TMP4 TMP,
         PA_RESOURCE_ASSIGNMENTS P
WHERE    TMP.TXN_SOURCE_ID         = V.EVENT_ID
AND      V.EVENT_TYPE              = ET.EVENT_TYPE
AND      V.PROJECT_ID              = P_PROJECT_ID
AND      V.EVENT_DATE             >= NVL(c_etc_start_date, V.EVENT_DATE)
AND      P.RESOURCE_ASSIGNMENT_ID  = TMP.TXN_RESOURCE_ASSIGNMENT_ID
AND      P.BUDGET_VERSION_ID       = P_BUDGET_VERSION_ID
AND      c_tphase                  = 'N'
GROUP BY P.RESOURCE_ASSIGNMENT_ID,
         V.BILL_TRANS_CURRENCY_CODE,
         TO_CHAR(null),
         GET_EVENT_DATE(V.EVENT_DATE,c_etc_start_date,c_plan_class_code),
         GET_EVENT_DATE(V.EVENT_DATE,c_etc_start_date,c_plan_class_code);


l_res_asg_id                PA_PLSQL_DATATYPES.IdTabTyp;
l_currency_code             PA_PLSQL_DATATYPES.Char15TabTyp;
l_tphase                    PA_PLSQL_DATATYPES.Char30TabTyp;
l_billstart_date                PA_PLSQL_DATATYPES.DateTabTyp;
l_billend_date                PA_PLSQL_DATATYPES.DateTabTyp;
l_rev_sum                   PA_PLSQL_DATATYPES.NumTabTyp;

l_stru_sharing_code         PA_PROJECTS_ALL.STRUCTURE_SHARING_CODE%TYPE;

l_icount                    NUMBER := 0;
l_ucount                    NUMBER := 0;
l_budget_line_id            PA_BUDGET_LINES.BUDGET_LINE_ID%TYPE;

l_appl_id                   NUMBER;

l_last_updated_by           NUMBER := FND_GLOBAL.user_id;
l_last_update_login         NUMBER := FND_GLOBAL.login_id;
l_sysdate                   DATE   := SYSDATE;
l_ret_status                VARCHAR2(100);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);
l_data                      VARCHAR2(2000);
l_msg_index_out             NUMBER:=0;

l_res_assgn_id_tab          PA_PLSQL_DATATYPES.IdTabTyp;
l_rlm_id_tab                PA_PLSQL_DATATYPES.IdTabTyp;
l_DELETED_RES_ASG_ID_TAB    PA_PLSQL_DATATYPES.IdTabTyp;

l_gen_res_asg_id_tab        PA_PLSQL_DATATYPES.IdTabTyp;
l_chk_duplicate_flag        VARCHAR2(1) := 'N';

l_resource_class_id         PA_RESOURCE_CLASSES_B.RESOURCE_CLASS_ID%TYPE;

l_count number;

l_resource_asg_id             NUMBER;
l_start_date                  DATE;
l_end_date                    DATE;
l_curr_code                   pa_budget_lines.txn_currency_code%type;
l_txn_curr_code               pa_budget_lines.txn_currency_code%type;
l_bill_trans_rev_amount       NUMBER;
l_time_phase                  VARCHAR2(30);
l_projfunc_raw_cost           NUMBER;
l_projfunc_burdened_cost      NUMBER;
l_projfunc_revenue            NUMBER;
l_projfunc_rejection_code     VARCHAR2(50);
l_proj_raw_cost               NUMBER;
l_proj_burdened_cost          NUMBER;
l_proj_revenue                NUMBER;
l_proj_rejection_code         VARCHAR2(50);

l_approved_rev_plan_type_flag    PA_BUDGET_VERSIONS.APPROVED_REV_PLAN_TYPE_FLAG%TYPE;

l_count1                      NUMBER;
l_project_id_tab               PA_PLSQL_DATATYPES.IdTabTyp;
--Local pl/sql table to call Map_Rlmi_Rbs api
l_TXN_SOURCE_ID_tab            PA_PLSQL_DATATYPES.IdTabTyp;
l_TXN_SOURCE_TYPE_CODE_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
l_PERSON_ID_tab                PA_PLSQL_DATATYPES.IdTabTyp;
l_JOB_ID_tab                   PA_PLSQL_DATATYPES.IdTabTyp;
l_ORGANIZATION_ID_tab          PA_PLSQL_DATATYPES.IdTabTyp;
l_VENDOR_ID_tab                PA_PLSQL_DATATYPES.IdTabTyp;
l_EXPENDITURE_TYPE_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
l_EVENT_TYPE_tab               PA_PLSQL_DATATYPES.Char30TabTyp;
l_NON_LABOR_RESOURCE_tab       PA_PLSQL_DATATYPES.Char20TabTyp;
l_EXPENDITURE_CATEGORY_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
l_REVENUE_CATEGORY_CODE_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
l_NLR_ORGANIZATION_ID_tab      PA_PLSQL_DATATYPES.IdTabTyp;
l_EVENT_CLASSIFICATION_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
l_SYS_LINK_FUNCTION_tab        PA_PLSQL_DATATYPES.Char30TabTyp;
l_PROJECT_ROLE_ID_tab          PA_PLSQL_DATATYPES.IdTabTyp;
l_RESOURCE_CLASS_CODE_tab      PA_PLSQL_DATATYPES.Char30TabTyp;
l_MFC_COST_TYPE_ID_tab         PA_PLSQL_DATATYPES.IDTabTyp;
l_RESOURCE_CLASS_FLAG_tab      PA_PLSQL_DATATYPES.Char1TabTyp;
l_FC_RES_TYPE_CODE_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
l_INVENTORY_ITEM_ID_tab        PA_PLSQL_DATATYPES.IDTabTyp;
l_ITEM_CATEGORY_ID_tab         PA_PLSQL_DATATYPES.IDTabTyp;
l_PERSON_TYPE_CODE_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
l_BOM_RESOURCE_ID_tab          PA_PLSQL_DATATYPES.IDTabTyp;
l_NAMED_ROLE_tab               PA_PLSQL_DATATYPES.Char80TabTyp;
l_INCURRED_BY_RES_FLAG_tab     PA_PLSQL_DATATYPES.Char1TabTyp;
l_RATE_BASED_FLAG_tab          PA_PLSQL_DATATYPES.Char1TabTyp;
l_TXN_TASK_ID_tab              PA_PLSQL_DATATYPES.IdTabTyp;
l_TXN_WBS_ELEMENT_VER_ID_tab   PA_PLSQL_DATATYPES.IdTabTyp;
l_TXN_RBS_ELEMENT_ID_tab       PA_PLSQL_DATATYPES.IdTabTyp;
l_TXN_PLAN_START_DATE_tab      PA_PLSQL_DATATYPES.DateTabTyp;
l_TXN_PLAN_END_DATE_tab        PA_PLSQL_DATATYPES.DateTabTyp;
--out param from PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS
l_map_txn_source_id_tab         PA_PLSQL_DATATYPES.IdTabTyp;
l_map_rlm_id_tab                PA_PLSQL_DATATYPES.IdTabTyp;
l_map_rbs_element_id_tab        PA_PLSQL_DATATYPES.IdTabTyp;
l_map_txn_accum_header_id_tab   PA_PLSQL_DATATYPES.IdTabTyp;

-- Variables added for Bug 5059327
l_txn_raw_cost                  PA_BUDGET_LINES.TXN_RAW_COST%TYPE;
-- IPM: Added local variable to pass variable values of the
--      p_calling_module parameter of the MAINTAIN_DATA API.
l_calling_module                VARCHAR2(30);
/* String constants for valid calling module values */
lc_BudgetGeneration             CONSTANT VARCHAR2(30) := 'BUDGET_GENERATION';
lc_ForecastGeneration           CONSTANT VARCHAR2(30) := 'FORECAST_GENERATION';

BEGIN
  /* Setting initial values */
    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function     => 'GEN_BILLING_AMOUNTS'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
    END IF;

   l_stru_sharing_code :=
   PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(P_PROJECT_ID=> P_PROJECT_ID);

  /* dbms_output.put_line('Value for struct sharing code:
                          '||l_stru_sharing_code);*/

 /* Deleting all the records from the temporary table */
   DELETE FROM PA_RES_LIST_MAP_TMP1;
   DELETE FROM PA_RES_LIST_MAP_TMP4;

    -- hr_utility.trace_on(null,'GOD');
   SELECT   RESOURCE_CLASS_ID
   INTO     l_resource_class_id
   FROM     PA_RESOURCE_CLASSES_B
   WHERE    RESOURCE_CLASS_CODE = 'FINANCIAL_ELEMENTS';



                     SELECT    PROJECT_ID,
                               nvl(TASK_ID,0),
                               EVENT_ID,
                               EVENT_TYPE,
                               'BILLING_EVENTS',
                               ORGANIZATION_ID,
                               INVENTORY_ITEM_ID,
                               event_date,
                               event_date,
                               DECODE(EVENT_TYPE,null,NULL,'EVENT_TYPE'),
                               'FINANCIAL_ELEMENTS'
                     BULK COLLECT
                     INTO      l_project_id_tab,
                               l_TXN_TASK_ID_tab,
                               l_TXN_SOURCE_ID_tab,
                               l_EVENT_TYPE_tab,
                               l_TXN_SOURCE_TYPE_CODE_tab,
                               l_ORGANIZATION_ID_tab,
                               l_INVENTORY_ITEM_ID_tab,
                               l_TXN_PLAN_START_DATE_tab,
                               l_TXN_PLAN_END_DATE_tab,
                               l_FC_RES_TYPE_CODE_tab,
                               l_RESOURCE_CLASS_CODE_tab
                     FROM      PA_EVENTS_DELIVERABLE_V
                     WHERE     PROJECT_ID = P_PROJECT_ID;

   IF l_TXN_SOURCE_ID_tab.count = 0 THEN
      IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_curr_function;
      END IF;
      RETURN;
   END IF;

       FOR bb in 1..l_TXN_SOURCE_ID_tab.count LOOP
                 l_PERSON_ID_tab(bb)             := null;
                 l_JOB_ID_tab(bb)                := null;
                 l_VENDOR_ID_tab(bb)             := null;
                 l_EXPENDITURE_TYPE_tab(bb)      := null;
                 l_NON_LABOR_RESOURCE_tab(bb)    := null;
                 l_EXPENDITURE_CATEGORY_tab(bb)  := null;
                 l_REVENUE_CATEGORY_CODE_tab(bb) := null;
                 l_NLR_ORGANIZATION_ID_tab(bb)   := null;
                 l_EVENT_CLASSIFICATION_tab(bb)  := null;
                 l_SYS_LINK_FUNCTION_tab(bb)     := null;
                 l_PROJECT_ROLE_ID_tab(bb)       := null;
                 l_MFC_COST_TYPE_ID_tab(bb)      := null;
                 l_RESOURCE_CLASS_FLAG_tab(bb)   := null;
                 l_ITEM_CATEGORY_ID_tab(bb)      := null;
                 l_PERSON_TYPE_CODE_tab(bb)      := null;
                 l_BOM_RESOURCE_ID_tab(bb)       := null;
                 l_NAMED_ROLE_tab(bb)            := null;
                 l_INCURRED_BY_RES_FLAG_tab(bb)  := null;
                 l_RATE_BASED_FLAG_tab(bb)       := null;
                 l_TXN_WBS_ELEMENT_VER_ID_tab(bb):= null;
                 l_TXN_RBS_ELEMENT_ID_tab(bb)    := null;
       END LOOP;
     --dbms_output.put_line('l_TXN_SOURCE_ID_tab.count: '||l_TXN_SOURCE_ID_tab.count);
    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_MSG           => 'Before calling PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS',
            P_MODULE_NAME   => l_module_name);
    END IF;
    PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS (
         P_PROJECT_ID                   => p_project_id,
         P_BUDGET_VERSION_ID            => NULL,
         P_RESOURCE_LIST_ID             => P_FP_COLS_REC.X_RESOURCE_LIST_ID,
         P_RBS_VERSION_ID               => NULL,
         P_CALLING_PROCESS              => 'BUDGET_GENERATION',
         P_CALLING_CONTEXT              => 'PLSQL',
         P_PROCESS_CODE                 => 'RES_MAP',
         P_CALLING_MODE                 => 'PLSQL_TABLE',
         P_INIT_MSG_LIST_FLAG           => 'N',
         P_COMMIT_FLAG                  => 'N',
         P_TXN_SOURCE_ID_TAB            => l_TXN_SOURCE_ID_tab,
         P_TXN_SOURCE_TYPE_CODE_TAB     => l_TXN_SOURCE_TYPE_CODE_tab,
         P_PERSON_ID_TAB                => l_PERSON_ID_tab,
         P_JOB_ID_TAB                   => l_JOB_ID_tab,
         P_ORGANIZATION_ID_TAB          => l_ORGANIZATION_ID_tab,
         P_VENDOR_ID_TAB                => l_VENDOR_ID_tab,
         P_EXPENDITURE_TYPE_TAB         => l_EXPENDITURE_TYPE_tab,
         P_EVENT_TYPE_TAB               => l_EVENT_TYPE_tab,
         P_NON_LABOR_RESOURCE_TAB       => l_NON_LABOR_RESOURCE_tab,
         P_EXPENDITURE_CATEGORY_TAB     => l_EXPENDITURE_CATEGORY_tab,
         P_REVENUE_CATEGORY_CODE_TAB    =>l_REVENUE_CATEGORY_CODE_tab,
         P_NLR_ORGANIZATION_ID_TAB      =>l_NLR_ORGANIZATION_ID_tab,
         P_EVENT_CLASSIFICATION_TAB     => l_EVENT_CLASSIFICATION_tab,
         P_SYS_LINK_FUNCTION_TAB        => l_SYS_LINK_FUNCTION_tab,
         P_PROJECT_ROLE_ID_TAB          => l_PROJECT_ROLE_ID_tab,
         P_RESOURCE_CLASS_CODE_TAB      => l_RESOURCE_CLASS_CODE_tab,
         P_MFC_COST_TYPE_ID_TAB         => l_MFC_COST_TYPE_ID_tab,
         P_RESOURCE_CLASS_FLAG_TAB      => l_RESOURCE_CLASS_FLAG_tab,
         P_FC_RES_TYPE_CODE_TAB         => l_FC_RES_TYPE_CODE_tab,
         P_INVENTORY_ITEM_ID_TAB        => l_INVENTORY_ITEM_ID_tab,
         P_ITEM_CATEGORY_ID_TAB         => l_ITEM_CATEGORY_ID_tab,
         P_PERSON_TYPE_CODE_TAB         => l_PERSON_TYPE_CODE_tab,
         P_BOM_RESOURCE_ID_TAB          =>l_BOM_RESOURCE_ID_tab,
         P_NAMED_ROLE_TAB               =>l_NAMED_ROLE_tab,
         P_INCURRED_BY_RES_FLAG_TAB     =>l_INCURRED_BY_RES_FLAG_tab,
         P_RATE_BASED_FLAG_TAB          =>l_RATE_BASED_FLAG_tab,
         P_TXN_TASK_ID_TAB              =>l_TXN_TASK_ID_tab,
         P_TXN_WBS_ELEMENT_VER_ID_TAB   => l_TXN_WBS_ELEMENT_VER_ID_tab,
         P_TXN_RBS_ELEMENT_ID_TAB       => l_TXN_RBS_ELEMENT_ID_tab,
         P_TXN_PLAN_START_DATE_TAB      => l_TXN_PLAN_START_DATE_tab,
         P_TXN_PLAN_END_DATE_TAB        => l_TXN_PLAN_END_DATE_tab,
         X_TXN_SOURCE_ID_TAB            =>l_map_txn_source_id_tab,
         X_RES_LIST_MEMBER_ID_TAB       =>l_map_rlm_id_tab,
         X_RBS_ELEMENT_ID_TAB           =>l_map_rbs_element_id_tab,
         X_TXN_ACCUM_HEADER_ID_TAB      =>l_map_txn_accum_header_id_tab,
         X_RETURN_STATUS                => x_return_status,
         X_MSG_COUNT                    => x_msg_count,
         X_MSG_DATA                     => x_msg_data );
    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_MSG           => 'After calling PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS: '||
                               x_return_status,
            P_MODULE_NAME   => l_module_name);
    END IF;
    /*dbms_output.put_line('After calling PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS: '||x_return_status);
    dbms_output.put_line('l_map_rlm_id_tab.count: '||l_map_rlm_id_tab.count);*/
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

      SELECT   /*+ INDEX(PA_RES_LIST_MAP_TMP4,PA_RES_LIST_MAP_TMP4_N1)*/
               count(*) INTO l_count1
      FROM     PA_RES_LIST_MAP_TMP4
      WHERE    RESOURCE_LIST_MEMBER_ID IS NULL and rownum=1;
      IF l_count1 > 0 THEN
           PA_UTILS.ADD_MESSAGE
              (p_app_short_name => 'PA',
               p_msg_name       => 'PA_INVALID_MAPPING_ERR');
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

       /*dbms_output.put_line('Status of mapping api:
                              '||X_RETURN_STATUS);*/
       --select count(*) into l_count from PA_RES_LIST_MAP_TMP4;
          -- hr_utility.trace('tmp4 count aft mapping api call '||l_count);
       --dbms_output.put_line('tmp4 count :'||l_count);
   /* Calling the API to get the resource_assignment_id */
       IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                               pa_fp_gen_budget_amt_pub.create_res_asg',
              p_module_name => l_module_name,
              p_log_level   => 5);
       END IF;
       PA_FP_GEN_BUDGET_AMT_PUB.CREATE_RES_ASG
           (P_PROJECT_ID               => P_PROJECT_ID,
            P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
            P_STRU_SHARING_CODE        => l_stru_sharing_code,
            P_GEN_SRC_CODE             => 'BILLING_EVENTS',
            P_FP_COLS_REC              => P_FP_COLS_REC,
            X_RETURN_STATUS            => X_RETURN_STATUS,
            X_MSG_COUNT                => X_MSG_COUNT,
            X_MSG_DATA                 => X_MSG_DATA);
       IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;
           /*dbms_output.put_line('Status of create res asg api:
          '||X_RETURN_STATUS);*/

   /* Calling the API to update the tmp4
      table with resource_assignment_id */
       IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                               pa_fp_gen_budget_amt_pub.update_res_asg',
              p_module_name => l_module_name,
              p_log_level   => 5);
       END IF;
       PA_FP_GEN_BUDGET_AMT_PUB.UPDATE_RES_ASG
           (P_PROJECT_ID               => P_PROJECT_ID,
            P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
            P_STRU_SHARING_CODE        => l_stru_sharing_code,
            P_GEN_SRC_CODE             => 'BILLING_EVENTS',
            P_FP_COLS_REC              => P_FP_COLS_REC,
            X_RETURN_STATUS            => X_RETURN_STATUS,
            X_MSG_COUNT                => X_MSG_COUNT,
            X_MSG_DATA                 => X_MSG_DATA);
       IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;
       IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling
                              pa_fp_gen_budget_amt_pub.update_res_asg'
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
       END IF;
          /*dbms_output.put_line('Status of update res asg api:
          '||X_RETURN_STATUS);*/

  /* Calling Del manual bdgt lines api
       IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                               pa_fp_gen_budget_amt_pub.del_manual_bdgt_lines',
              p_module_name => l_module_name,
              p_log_level   => 5);
       END IF;
       PA_FP_GEN_BUDGET_AMT_PUB.DEL_MANUAL_BDGT_LINES
           (P_PROJECT_ID               => P_PROJECT_ID,
            P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
            PX_RES_ASG_ID_TAB           => l_res_assgn_id_tab,
            PX_DELETED_RES_ASG_ID_TAB   => l_DELETED_RES_ASG_ID_TAB,
            X_RETURN_STATUS            => X_RETURN_STATUS,
            X_MSG_COUNT                => X_MSG_COUNT,
            X_MSG_DATA                 => X_MSG_DATA);
       IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;
       IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling
                              pa_fp_gen_budget_amt_pub.del_manual_bdgt_lines'
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
       END IF;
          --dbms_output.put_line('Status of del manual bdgt lines api:
          --                   '||X_RETURN_STATUS);

      --Calling get generated res asg api
       IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                               pa_fp_gen_budget_amt_pub.get_generated_res_asg',
              p_module_name => l_module_name,
              p_log_level   => 5);
       END IF;
       PA_FP_GEN_BUDGET_AMT_PUB.GET_GENERATED_RES_ASG
           (P_PROJECT_ID               => P_PROJECT_ID,
            P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
           PX_GEN_RES_ASG_ID_TAB       => l_gen_res_asg_id_tab,
           P_CHK_DUPLICATE_FLAG       => l_chk_duplicate_flag,
            X_RETURN_STATUS            => X_RETURN_STATUS,
            X_MSG_COUNT                => X_MSG_COUNT,
            X_MSG_DATA                 => X_MSG_DATA);
       IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;
       IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling
                              pa_fp_gen_budget_amt_pub.get_generated_res_asg'
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
       END IF;
    --dbms_output.put_line('Status of get generated res asg api:
    --                     '||X_RETURN_STATUS);
    --dbms_output.put_line('Count of res asg id tab after calling
    --get gen res asg api: '||l_gen_res_asg_id_tab.count);

      PX_GEN_RES_ASG_ID_TAB.delete;
      PX_GEN_RES_ASG_ID_TAB := l_gen_res_asg_id_tab;
    */
    l_appl_id := PA_PERIOD_PROCESS_PKG.Application_id;
    --dbms_output.put_line('Value of application id: '||l_appl_id);

            l_res_asg_id.delete;
            l_currency_code.delete;
            l_tphase.delete;
            l_billstart_date.delete;
            l_billend_date.delete;
            l_rev_sum.delete;

   /* for billing events, the resource class is always FINANCIAL_ELEMENTS and
       the UOM is always CURRENCY. So, the revenue amount is used for quantity
       attribute and the txn bill rate override value will be 1. */
   OPEN     SUM_BILL_CRSR(P_FP_COLS_REC.X_TIME_PHASED_CODE,
                        l_appl_id,
                        P_FP_COLS_REC.X_SET_OF_BOOKS_ID,
                        P_FP_COLS_REC.X_ORG_ID,
                        P_FP_COLS_REC.X_PLAN_IN_MULTI_CURR_FLAG,
                        P_ETC_START_DATE,
                        P_FP_COLS_REC.X_PLAN_CLASS_CODE);

   FETCH    SUM_BILL_CRSR
   BULK     COLLECT
   INTO     l_res_asg_id,
            l_currency_code,
            l_tphase,
            l_billstart_date,
            l_billend_date,
            l_rev_sum;

  CLOSE SUM_BILL_CRSR;
   /*dbms_output.put_line('after cursor fetch :'||l_res_asg_id.count);
   dbms_output.put_line('aft cursor fetch rev sum:'||l_rev_sum(1)); */
 -- hr_utility.trace('aft cursor fetch '||l_res_asg_id.count);
   SELECT NVL(approved_rev_plan_type_flag,'N')
   INTO   l_approved_rev_plan_type_flag
   FROM   pa_budget_versions
   WHERE  budget_version_id = p_budget_version_id;

    /* dbms_output.put_line('plan_in_multi_curr_flag: '||p_fp_cols_rec.x_plan_in_multi_curr_flag);
   dbms_output.put_line('approved_rev_plan_type_flag: '||l_approved_rev_plan_type_flag);  */

  FOR i in 1..l_res_asg_id.count LOOP
   l_resource_asg_id       := l_res_asg_id(i);
   l_start_date            := l_billstart_date(i);
   l_end_date              := l_billend_date(i);
   l_curr_code             := l_currency_code(i);
   l_txn_curr_code         := l_currency_code(i);
   l_bill_trans_rev_amount := l_rev_sum(i);
   l_time_phase            := l_tphase(i);
 /* hr_utility.trace('curr code :'||l_curr_code );
hr_utility.trace('txn rev amt :'||l_bill_trans_rev_amount );
hr_utility.trace('pc   code :'||p_fp_cols_rec.x_project_currency_code );
hr_utility.trace('pfc   code :'||p_fp_cols_rec.x_projfunc_currency_code );  */
  /* if multi curr flag is not enabled
     then the bill_trans_currency_code is chked against PC currency code.
     If they are not same then convert it to PC currency code */
   IF ( p_fp_cols_rec.x_plan_in_multi_curr_flag = 'N'  AND
        l_txn_curr_code <> p_fp_cols_rec.x_project_currency_code ) OR
      ( l_approved_rev_plan_type_flag = 'Y'  AND
        l_txn_curr_code <> p_fp_cols_rec.x_projfunc_currency_code ) THEN
       /* Call the conversion API to convert
          bill_trans_currency_code to project currency code*/

        l_curr_code := p_fp_cols_rec.x_projfunc_currency_code;

      --Calling  the convert_currency_code api
          IF p_pa_debug_mode = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
                   (p_msg         => 'Before calling
                    pa_fp_gen_billing_amounts.CONVERT_TXN_AMT_TO_PC_PFC',
                    p_module_name => l_module_name,
                    p_log_level   => 5);
          END IF;
        PA_FP_GEN_BILLING_AMOUNTS.CONVERT_TXN_AMT_TO_PC_PFC
          (P_PROJECT_ID             =>  p_project_id,
           P_BUDGET_VERSION_ID      =>  p_budget_version_id,
           P_RES_ASG_ID             =>  l_resource_asg_id,
           P_START_DATE             =>  l_start_date,
           P_END_DATE               =>  l_end_date,
           P_CURRENCY_CODE          =>  l_txn_curr_code,
           P_TXN_RAW_COST           =>  NULL,
           P_TXN_BURDENED_COST      =>  NULL,
           P_TXN_REV_AMOUNT         =>  l_bill_trans_rev_amount,
           X_PROJFUNC_RAW_COST      =>  l_projfunc_raw_cost,
           X_PROJFUNC_BURDENED_COST =>  l_projfunc_burdened_cost,
           X_PROJFUNC_REVENUE       =>  l_projfunc_revenue,
           X_PROJFUNC_REJECTION     =>  l_projfunc_rejection_code,
           X_PROJ_RAW_COST          =>  l_proj_raw_cost,
           X_PROJ_BURDENED_COST     =>  l_proj_burdened_cost,
           X_PROJ_REVENUE           =>  l_proj_revenue,
           X_PROJ_REJECTION         =>  l_proj_rejection_code,
           X_RETURN_STATUS          =>  x_return_status,
           X_MSG_COUNT              =>  x_MSG_COUNT,
           X_MSG_DATA               =>  x_MSG_DATA);
           IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;
           IF p_pa_debug_mode = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                     (p_msg         => 'Status after calling
                      pa_fp_gen_billing_amounts.CONVERT_TXN_AMT_TO_PC_PFC:'
                                                    ||x_return_status,
                      p_module_name => l_module_name,
                                     p_log_level   => 5);
           END IF;

           /* Setting PC values */
           IF ( p_fp_cols_rec.x_plan_in_multi_curr_flag = 'N'  AND
                l_txn_curr_code <> p_fp_cols_rec.x_project_currency_code ) THEN
                l_curr_code := p_fp_cols_rec.x_project_currency_code;
                l_bill_trans_rev_amount := l_proj_revenue;
           END IF;
           /* Setting PFC values */
           IF  ( l_approved_rev_plan_type_flag = 'Y'  AND
                 l_txn_curr_code <> p_fp_cols_rec.x_projfunc_currency_code ) THEN
                l_curr_code := p_fp_cols_rec.x_projfunc_currency_code;
                l_bill_trans_rev_amount := l_projfunc_revenue;
           END IF;

      END IF;
     /*  dbms_output.put_line('PFC Currency Code: '||p_fp_cols_rec.x_projfunc_currency_code);
      dbms_output.put_line('PFC Rev amount: '||l_projfunc_revenue);
      dbms_output.put_line('Currency Code: '||l_curr_code);
      dbms_output.put_line('Rev amount(l_bill_trans_rev_amount): '||l_bill_trans_rev_amount);*/

    -- Added for Bug 5059327:
    -- Update the currency code table with the actual value
    -- so that later code will know which (resource_assignment_id,
    -- txn_currency_code)'s have commmitments.
    l_currency_code(i) := l_curr_code;

    --Checking for budget_line_id
    -- For Bug 5059327, also get the txn raw cost amount.
    -- Beginning in IPM, the following rule applies at the
    -- budget line level to non-rate-based transactions in
    -- Cost and Revenue Together versions:
    -- i)  If txn_raw_cost is Null, then (quantity = txn_revenue)
    -- ii) If txn_raw_cost is not Null, then (quantity = txn_raw_cost)
    -- For forecasts, check ETC txn_raw_cost instead of txn_raw_cost.

    BEGIN
        IF P_FP_COLS_REC.X_TIME_PHASED_CODE = 'N' THEN
            SELECT   BUDGET_LINE_ID,
                     TXN_RAW_COST - NVL(TXN_INIT_RAW_COST,0)
            INTO     l_budget_line_id,
                     l_txn_raw_cost
            FROM     PA_BUDGET_LINES BL
            WHERE    BL.RESOURCE_ASSIGNMENT_ID = l_resource_asg_id
            AND      BL.TXN_CURRENCY_CODE      = l_curr_code;
        ELSE -- P_FP_COLS_REC.X_TIME_PHASED_CODE IN ('P','G')
            SELECT   BUDGET_LINE_ID,
                     TXN_RAW_COST
            INTO     l_budget_line_id,
                     l_txn_raw_cost
            FROM     PA_BUDGET_LINES BL
            WHERE    BL.RESOURCE_ASSIGNMENT_ID = l_resource_asg_id
            AND      BL.TXN_CURRENCY_CODE      = l_curr_code
            AND      BL.START_DATE             = l_start_date;
        END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
            l_budget_line_id := null;
            l_txn_raw_cost   := null;
           -- dbms_output.put_line('inside no data fnd bl');
    END;

   /* Checking for the existing record in pa_budget_lines table */
   IF l_budget_line_id IS NULL THEN
   /* if the record does not exist then insert
      the record into the pa_budget_lines table */
          -- dbms_output.put_line('inside insert      bl');

        -- For Cost and Revenue Together versions, non-rate-based
        -- planning transactions with only revenue amounts should
        -- have budget line cost override rates stamped as 0. This
        -- behavior is introduced in IPM. Note that Billing Events
        -- are always non-rate-based, so the rate_based_flag does
        -- not need to be checked here.

        INSERT INTO PA_BUDGET_LINES (
            RESOURCE_ASSIGNMENT_ID,
            START_DATE,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            END_DATE,
            TXN_CURRENCY_CODE,
            TXN_REVENUE,
            BUDGET_LINE_ID,
            BUDGET_VERSION_ID,
            PROJECT_CURRENCY_CODE,
            PROJFUNC_CURRENCY_CODE,
            QUANTITY,
            TXN_BILL_RATE_OVERRIDE,
            TXN_COST_RATE_OVERRIDE,    -- Added for Bug 5059327
            BURDEN_COST_RATE_OVERRIDE, -- Added for Bug 5059327
            PERIOD_NAME )
        VALUES (
            l_resource_asg_id,
            l_start_date,
            l_sysdate,
            l_last_updated_by,
            l_sysdate,
            l_last_updated_by,
            l_last_update_login,
            l_end_date,
            l_curr_code,
            l_bill_trans_rev_amount,
            PA_BUDGET_LINES_S.nextval,
            P_BUDGET_VERSION_ID,
            p_FP_COLS_REC.X_PROJECT_CURRENCY_CODE,
            p_FP_COLS_REC.X_PROJFUNC_CURRENCY_CODE,
            l_bill_trans_rev_amount,
            1,
            decode(p_fp_cols_rec.x_version_type,'ALL',0,null), -- Added for Bug 5059327
            decode(p_fp_cols_rec.x_version_type,'ALL',0,null), -- Added for Bug 5059327
            l_time_phase );

    ELSIF l_budget_line_id IS NOT NULL THEN
        /* if the record does exist then update
          the record in the pa_budget_lines table */
          /* dbms_output.put_line('inside update      bl');
          dbms_output.put_line('budget line id in update '||
      l_budget_line_id);     */

        IF p_fp_cols_rec.x_version_type = 'REVENUE' OR
         ( p_fp_cols_rec.x_version_type = 'ALL' AND
           nvl(l_txn_raw_cost,0) = 0 ) THEN

           UPDATE  PA_BUDGET_LINES
           SET   LAST_UPDATE_DATE       = l_sysdate
           ,     LAST_UPDATED_BY        = l_last_updated_by
           ,     LAST_UPDATE_LOGIN      = l_last_update_login
           ,     TXN_REVENUE            = NVL(TXN_REVENUE,0) + l_bill_trans_rev_amount
           ,     quantity               = nvl(quantity,0) + l_bill_trans_rev_amount
           WHERE BUDGET_LINE_ID         = l_budget_line_id;

        ELSIF ( p_fp_cols_rec.x_version_type = 'ALL' AND
                nvl(l_txn_raw_cost,0) <> 0 ) THEN

            -- In this case, the update is occuring for a non-rate-based
            -- planning txn with quantity = raw cost. Update the revenue
            -- and recompute the bill rate override.

            UPDATE  PA_BUDGET_LINES
            SET   LAST_UPDATE_DATE       = l_sysdate
            ,     LAST_UPDATED_BY        = l_last_updated_by
            ,     LAST_UPDATE_LOGIN      = l_last_update_login
            ,     TXN_REVENUE            = NVL(TXN_REVENUE,0) + l_bill_trans_rev_amount
            ,     txn_bill_rate_override =
                      decode(p_fp_cols_rec.x_time_phased_code,'N',
                             decode((nvl(quantity,0)-nvl(init_quantity,0)),0,null,
                                    (NVL(TXN_REVENUE,0) + l_bill_trans_rev_amount)
                                     /(nvl(quantity,0)-nvl(init_quantity,0)) ),
                             decode( nvl(quantity,0),0,null,
                                    (NVL(TXN_REVENUE,0) + l_bill_trans_rev_amount)/quantity ))
            --,     quantity               = nvl(quantity,0) + l_bill_trans_rev_amount
            WHERE BUDGET_LINE_ID         = l_budget_line_id;

        END IF; -- version_type check
    END IF; -- budget line exists check
  END LOOP;

          /*dbms_output.put_line('No.of records inserted into
          bdgt lines table: '||l_icount);
          dbms_output.put_line('No.of records updated into
          bdgt lines table:  '||l_ucount);*/
   IF P_FP_COLS_REC.X_PLAN_IN_MULTI_CURR_FLAG = 'Y' THEN
       IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                               pa_fp_gen_budget_amt_pub.insert_txn_currency',
              p_module_name => l_module_name,
              p_log_level   => 5);
       END IF;
       PA_FP_GEN_BUDGET_AMT_PUB.INSERT_TXN_CURRENCY
          (P_PROJECT_ID               => P_PROJECT_ID,
           P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
           P_FP_COLS_REC              => P_FP_COLS_REC,
           X_RETURN_STATUS            => X_RETURN_STATUS,
           X_MSG_COUNT                => X_MSG_COUNT,
           X_MSG_DATA                 => X_MSG_DATA);
       IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;
       IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling
                              pa_fp_gen_budget_amt_pub.insert_txn_currency'
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
       END IF;
      /* dbms_output.put_line('Status of insert txn currency api:
                           '||X_RETURN_STATUS);*/
    END IF;

    -- Added 11/30/2004 by dkuo to synch billing event dates
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'Before calling PA_FP_MAINTAIN_ACTUAL_PUB.' ||
                               'SYNC_UP_PLANNING_DATES',
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;
    PA_FP_MAINTAIN_ACTUAL_PUB.SYNC_UP_PLANNING_DATES
        ( P_BUDGET_VERSION_ID   => p_budget_version_id,
          P_CALLING_CONTEXT     => 'GEN_BILLING_EVENTS',
          X_RETURN_STATUS       => x_return_Status,
          X_MSG_COUNT           => x_msg_count,
          X_MSG_DATA	        => x_msg_data );
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'Aft calling PA_FP_MAINTAIN_ACTUAL_PUB.' ||
                               'SYNC_UP_PLANNING_DATES return status ' ||
                               x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    -- Bug 5059327: In IPM, the following business rule was
    -- introduced for non-rate-based planning transactions:
    --   When planning cost and revenue together, if the user
    --   enters only revenue amounts, then no cost amounts
    --   should be generated.
    -- The approach taken by the Calculate API to support
    -- this case is to populate the new entity record with
    -- 1 for the bill rate override and 0 for the cost rate
    -- overrides. The same overrides are stamped at the
    -- budget line level as well.
    --
    -- Fix Overview
    -- ------------
    -- 1. Earlier, when populating budget lines, stamp bill
    --    rate override as 1 and cost rate overrides as 0
    --    in the budget lines where appropriate.
    -- 2. Call the maintain_data API in Insert mode to set
    --    bill rate override as 1 and cost rate overrides
    --    as 0 for (non-rate-based) planning transactions
    --    with only revenue amounts in all budget lines that
    --    do not have rejection codes. This applies only to
    --    Cost and Revenue Together versions.

    IF p_fp_cols_rec.x_version_type = 'ALL' THEN
        DELETE pa_fp_rollup_tmp;
        DELETE pa_resource_asgn_curr_tmp;

        -- Use pa_fp_rollup_tmp to get DISTINCT records later.
        FORALL i IN 1..l_res_asg_id.count
            INSERT INTO pa_fp_rollup_tmp (
                RESOURCE_ASSIGNMENT_ID,
                TXN_CURRENCY_CODE )
            VALUES (
                l_res_asg_id(i),
                l_currency_code(i) );

        -- Populate temp table with overrides for 'revenue-only' txns.
        -- Note that the Select handles both budget and forecasts as
        -- well PA/GL-timephased and non-timephased versions.
        INSERT INTO pa_resource_asgn_curr_tmp (
            RESOURCE_ASSIGNMENT_ID,
            TXN_CURRENCY_CODE,
            TXN_RAW_COST_RATE_OVERRIDE,
            TXN_BURDEN_COST_RATE_OVERRIDE,
            TXN_BILL_RATE_OVERRIDE )
        SELECT bl.resource_assignment_id,
               bl.txn_currency_code,
               0,
               0,
               1
        FROM   pa_budget_lines bl,
              (SELECT DISTINCT resource_assignment_id, txn_currency_code
               FROM pa_fp_rollup_tmp) tmp
        WHERE  bl.resource_assignment_id = tmp.resource_assignment_id
        AND    bl.txn_currency_code = tmp.txn_currency_code
        AND    bl.budget_version_id = p_budget_version_id
        AND    bl.cost_rejection_code is null
        AND    bl.revenue_rejection_code is null
        AND    bl.burden_rejection_code is null
        AND    bl.other_rejection_code is null
        AND    bl.pc_cur_conv_rejection_code is null
        AND    bl.pfc_cur_conv_rejection_code is null
        GROUP BY bl.resource_assignment_id,
                 bl.txn_currency_code
        HAVING NVL(sum(txn_raw_cost)-nvl(sum(txn_init_raw_cost),0),0) = 0;

        l_count := SQL%ROWCOUNT;
        IF l_count > 0 THEN

            IF p_fp_cols_rec.x_plan_class_code = 'BUDGET' THEN
                l_calling_module := lc_BudgetGeneration;
            ELSIF p_fp_cols_rec.x_plan_class_code = 'FORECAST' THEN
                l_calling_module := lc_ForecastGeneration;
            END IF;

            -- CALL the maintenance api in INSERT mode
            IF p_pa_debug_mode = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                    P_MSG                   => 'Before calling PA_RES_ASG_CURRENCY_PUB.' ||
                                               'MAINTAIN_DATA',
                  --P_CALLED_MODE           => p_called_mode,
                    P_MODULE_NAME           => l_module_name);
            END IF;
            PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA
                  ( P_FP_COLS_REC           => p_fp_cols_rec,
                    P_CALLING_MODULE        => l_calling_module,
                    P_VERSION_LEVEL_FLAG    => 'N',
                    P_ROLLUP_FLAG           => 'N', -- 'N' indicates Insert
                  --P_CALLED_MODE           => p_called_mode,
                    X_RETURN_STATUS         => x_return_status,
                    X_MSG_COUNT             => x_msg_count,
                    X_MSG_DATA              => x_msg_data );
            IF p_pa_debug_mode = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                    P_MSG                   => 'After calling PA_RES_ASG_CURRENCY_PUB.' ||
                                               'MAINTAIN_DATA: '||x_return_status,
                  --P_CALLED_MODE           => p_called_mode,
                    P_MODULE_NAME           => l_module_name);
            END IF;
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
        END IF; -- IF l_count > 0 THEN
    END IF; --IF p_fp_cols_rec.x_version_type = 'ALL' THEN
    -- End Bug Fix 5059327

    IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_curr_function;
    END IF;
 EXCEPTION
   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
   -- Bug Fix: 4569365. Removed MRC code.
   --   PA_MRC_FINPLAN.G_CALLING_MODULE := Null;
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

      x_return_status := FND_API.G_RET_STS_ERROR;

      IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_curr_function;
      END IF;

      RAISE;

    WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      := SUBSTR(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_BILLING_AMOUNTS'
              ,p_procedure_name => 'GEN_BILLING_AMOUNTS');

     IF P_PA_DEBUG_MODE = 'Y' THEN
         PA_DEBUG.Reset_curr_function;
     END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GEN_BILLING_AMOUNTS;

PROCEDURE GET_BILLING_EVENT_AMT_IN_PFC
          (P_PROJECT_ID                 IN pa_projects_all.project_id%type,
           P_BUDGET_VERSION_ID          IN pa_budget_versions.budget_version_id%type,
           P_FP_COLS_REC                IN PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_PROJFUNC_CURRENCY_CODE     IN pa_projects_all.projfunc_currency_code%type,
           P_PROJECT_CURRENCY_CODE      IN pa_projects_all.project_currency_code%type,
           X_PROJFUNC_REVENUE           OUT NOCOPY    NUMBER,
           X_PROJECT_REVENUE       	OUT NOCOPY    NUMBER,
           X_RETURN_STATUS              OUT NOCOPY    VARCHAR2,
           X_MSG_COUNT                  OUT NOCOPY    NUMBER,
           X_MSG_DATA                   OUT NOCOPY    VARCHAR2) IS
  l_module_name                 VARCHAR2(200) :=
         'pa.plsql.PA_FP_GEN_BILLING_AMOUNTS.GET_BILLING_EVENT_AMT_IN_PFC';
  l_event_date_tab              PA_PLSQL_DATATYPES.DateTabTyp;
  l_txn_currency_code_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
  l_txn_rev_amt_tab             PA_PLSQL_DATATYPES.NumTabTyp;
  l_projfunc_rev_amt_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_project_rev_amt_tab         PA_PLSQL_DATATYPES.NumTabTyp;

  l_projfunc_raw_cost           NUMBER;
  l_projfunc_burdened_cost      NUMBER;
  l_projfunc_revenue            NUMBER;
  l_projfunc_rejection_code     VARCHAR2(50);
  l_proj_raw_cost               NUMBER;
  l_proj_burdened_cost          NUMBER;
  l_proj_revenue                NUMBER;
  l_proj_rejection_code         VARCHAR2(50);

  l_conversion_required_flag    VARCHAR2(1);

  l_etc_start_date              DATE;

  l_txn_source_id_count         NUMBER;
  --out param from MAP_BILLING_EVENT_RLMI_RBS
  l_map_txn_source_id_tab         PA_PLSQL_DATATYPES.IdTabTyp;
  l_map_rlm_id_tab                PA_PLSQL_DATATYPES.IdTabTyp;
  l_map_rbs_element_id_tab        PA_PLSQL_DATATYPES.IdTabTyp;
  l_map_txn_accum_header_id_tab   PA_PLSQL_DATATYPES.IdTabTyp;

  l_msg_count                  NUMBER;
  l_msg_data                   VARCHAR2(2000);
  l_data                       VARCHAR2(2000);
  l_msg_index_out              NUMBER:=0;
BEGIN
    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function     => ' GET_BILLING_EVENT_AMT_IN_PFC',
                                    p_debug_mode   =>  p_pa_debug_mode);
    END IF;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT := 0;

    -- Initialize pc/pfc revenue out parameters.
    X_PROJFUNC_REVENUE := 0;
    X_PROJECT_REVENUE  := 0;

    SELECT etc_start_date
      INTO l_etc_start_date
    FROM pa_budget_versions
    WHERE budget_version_id = P_BUDGET_VERSION_ID;

    -- Bug 4067837: Added check for Retain Manual Lines flag. If the flag
    -- is 'N', then we fetch Billing Event amounts using the original query.
    -- If the flag is 'Y', then we do the following:
    --    * Call the Mapping API to populate the tmp4 table
    --    * Update the tmp4 table with txn_resource_assignment_ids,
    --      and remove records for manually added resources.
    --    * Fetch Billing Event amounts using the original query, but
    --      modified to join with the tmp4 table so that we only pick up
    --      events that are mapped to non-manually-added resources.

    IF p_fp_cols_rec.x_gen_ret_manual_line_flag = 'N' THEN
        SELECT V.EVENT_DATE,
               V.BILL_TRANS_CURRENCY_CODE,
               SUM(DECODE(ET.EVENT_TYPE_CLASSIFICATION,
                          'WRITE OFF', -1 * NVL(V.BILL_TRANS_REV_AMOUNT,0),
                          'REALIZED_LOSSES',  -1 * NVL(V.BILL_TRANS_REV_AMOUNT,0),
                          NVL(V.BILL_TRANS_REV_AMOUNT,0))),
               SUM(DECODE(ET.EVENT_TYPE_CLASSIFICATION,
                          'WRITE OFF', -1 * NVL(V.PROJFUNC_REVENUE_AMOUNT,0),
                          'REALIZED_LOSSES',  -1 * NVL(V.PROJFUNC_REVENUE_AMOUNT,0),
                          NVL(V.PROJFUNC_REVENUE_AMOUNT,0))),
               SUM(DECODE(ET.EVENT_TYPE_CLASSIFICATION,
                          'WRITE OFF', -1 * NVL(V.PROJECT_REVENUE_AMOUNT,0),
                          'RZED_LOSSES',  -1 * NVL(V.PROJECT_REVENUE_AMOUNT,0),
                          NVL(V.PROJECT_REVENUE_AMOUNT,0)))
        BULK COLLECT
        INTO   l_event_date_tab,
               l_txn_currency_code_tab,
               l_txn_rev_amt_tab,
               l_projfunc_rev_amt_tab,
               l_project_rev_amt_tab
        FROM   PA_EVENTS_DELIVERABLE_V V,
               PA_EVENT_TYPES ET
        WHERE  V.PROJECT_ID  = P_PROJECT_ID
        AND    V.EVENT_DATE >= NVL(l_etc_start_date, V.EVENT_DATE)
        AND    V.EVENT_TYPE = ET.EVENT_TYPE
        AND    NVL(V.BILL_TRANS_REV_AMOUNT,0) <> 0
        GROUP BY V.EVENT_DATE,
                 V.BILL_TRANS_CURRENCY_CODE;
    ELSIF p_fp_cols_rec.x_gen_ret_manual_line_flag = 'Y' THEN
        -- Call the Billing Events mapping API wrapper to populate the tm4
        -- table with the mapping from billing events to target resources.
        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_msg         => 'Before calling pa_fp_gen_billing_amounts.
                                    MAP_BILLING_EVENT_RLMI_RBS',
                  p_module_name => l_module_name,
                  p_log_level   => 5 );
        END IF;
        PA_FP_GEN_BILLING_AMOUNTS.MAP_BILLING_EVENT_RLMI_RBS
            ( P_PROJECT_ID               =>  p_project_id,
              P_BUDGET_VERSION_ID        =>  p_budget_version_id,
              P_FP_COLS_REC              =>  p_fp_cols_rec,
              X_TXN_SOURCE_ID_COUNT      =>  l_txn_source_id_count,
              X_TXN_SOURCE_ID_TAB        =>  l_map_txn_source_id_tab,
              X_RES_LIST_MEMBER_ID_TAB   =>  l_map_rlm_id_tab,
              X_RBS_ELEMENT_ID_TAB       =>  l_map_rbs_element_id_tab,
              X_TXN_ACCUM_HEADER_ID_TAB  =>  l_map_txn_accum_header_id_tab,
              X_RETURN_STATUS            =>  x_return_status,
              X_MSG_COUNT                =>  x_msg_count,
              X_MSG_DATA                 =>  x_msg_data );
        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_msg         => 'Status after calling pa_fp_gen_billing_amounts.
                                    MAP_BILLING_EVENT_RLMI_RBS:'
                                    ||x_return_status,
                  p_module_name => l_module_name,
                  p_log_level   => 5 );
        END IF;
        -- X_TXN_SOURCE_ID_COUNT = 0 means there are no events to process.
        IF l_txn_source_id_count = 0 THEN
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.Reset_curr_function;
            END IF;
            RETURN;
        END IF;

        -- Bug 4297225: As of this bug fix, we no longer join pa_res_list_tmp4
        -- with pa_resource_assignments using the Target resource assignment id.
        -- However, we still need to call the UPD_TMP4_TXN_RA_ID_AND_ML API to
        -- handle the Retain Manually Added Plan Lines logic for the tmp4 table,
        -- which is still used when fetching Billing Event amounts downstream.

        -- Call API to update tmp4 with txn_resource_assignment_ids and to
        -- clear records for manually added resources from the tmp4 table.
        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_msg         => 'Before calling pa_fp_gen_billing_amounts.
                                    UPD_TMP4_TXN_RA_ID_AND_ML',
                  p_module_name => l_module_name,
                  p_log_level   => 5 );
        END IF;
        PA_FP_GEN_BILLING_AMOUNTS.UPD_TMP4_TXN_RA_ID_AND_ML
            ( P_PROJECT_ID               =>  p_project_id,
              P_BUDGET_VERSION_ID        =>  p_budget_version_id,
              P_FP_COLS_REC              =>  p_fp_cols_rec,
              P_GEN_SRC_CODE             => 'BILLING_EVENTS',
              X_RETURN_STATUS            =>  x_return_status,
              X_MSG_COUNT                =>  x_msg_count,
              X_MSG_DATA                 =>  x_msg_data );
        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_msg         => 'Status after calling pa_fp_gen_billing_amounts.
                                    UPD_TMP4_TXN_RA_ID_AND_ML:'
                                    ||x_return_status,
                  p_module_name => l_module_name,
                  p_log_level   => 5 );
        END IF;

        -- Bug 4297225: Billing Events may map to Target resources that have not
        -- been created yet. Still, we should include the amounts for such Billing
        -- Events in the total amount returned by this API. To this end, the join
        -- between pa_resource_assignments with pa_res_list_tmp4 has been commented
        -- out in the query below that gets Billing Event amounts.

        SELECT /*+ INDEX(TMP,PA_RES_LIST_MAP_TMP4_N2)*/
               V.EVENT_DATE,
               V.BILL_TRANS_CURRENCY_CODE,
               SUM(DECODE(ET.EVENT_TYPE_CLASSIFICATION,
                          'WRITE OFF', -1 * NVL(V.BILL_TRANS_REV_AMOUNT,0),
                          'REALIZED_LOSSES',  -1 * NVL(V.BILL_TRANS_REV_AMOUNT,0),
                          NVL(V.BILL_TRANS_REV_AMOUNT,0))),
               SUM(DECODE(ET.EVENT_TYPE_CLASSIFICATION,
                          'WRITE OFF', -1 * NVL(V.PROJFUNC_REVENUE_AMOUNT,0),
                          'REALIZED_LOSSES',  -1 * NVL(V.PROJFUNC_REVENUE_AMOUNT,0),
                          NVL(V.PROJFUNC_REVENUE_AMOUNT,0))),
               SUM(DECODE(ET.EVENT_TYPE_CLASSIFICATION,
                          'WRITE OFF', -1 * NVL(V.PROJECT_REVENUE_AMOUNT,0),
                          'RZED_LOSSES',  -1 * NVL(V.PROJECT_REVENUE_AMOUNT,0),
                          NVL(V.PROJECT_REVENUE_AMOUNT,0)))
        BULK COLLECT
        INTO   l_event_date_tab,
               l_txn_currency_code_tab,
               l_txn_rev_amt_tab,
               l_projfunc_rev_amt_tab,
               l_project_rev_amt_tab
        FROM   PA_EVENTS_DELIVERABLE_V V,
               PA_EVENT_TYPES ET,
               PA_RES_LIST_MAP_TMP4 TMP
            --,PA_RESOURCE_ASSIGNMENTS RA
        WHERE  V.PROJECT_ID  = P_PROJECT_ID
        AND    V.EVENT_DATE >= NVL(l_etc_start_date, V.EVENT_DATE)
        AND    V.EVENT_TYPE = ET.EVENT_TYPE
        AND    NVL(V.BILL_TRANS_REV_AMOUNT,0) <> 0
        AND    TMP.TXN_SOURCE_ID = V.EVENT_ID
      --AND    RA.RESOURCE_ASSIGNMENT_ID = TMP.TXN_RESOURCE_ASSIGNMENT_ID
      --AND    RA.BUDGET_VERSION_ID = P_BUDGET_VERSION_ID
        GROUP BY V.EVENT_DATE,
                 V.BILL_TRANS_CURRENCY_CODE;
    END IF; -- manual lines check

    -- End changes for Bug 4067837

    FOR i IN 1..l_event_date_tab.count LOOP
        l_conversion_required_flag := 'N';

        IF l_txn_currency_code_tab(i) = P_PROJFUNC_CURRENCY_CODE THEN
            l_projfunc_revenue := l_txn_rev_amt_tab(i);
        ELSIF l_projfunc_rev_amt_tab(i) <> 0 THEN
            l_projfunc_revenue := l_projfunc_rev_amt_tab(i);
        ELSE
            l_conversion_required_flag := 'Y';
        END IF;

        IF l_txn_currency_code_tab(i) = P_PROJECT_CURRENCY_CODE THEN
            l_proj_revenue := l_txn_rev_amt_tab(i);
        ELSIF l_project_rev_amt_tab(i) <> 0 THEN
            l_proj_revenue := l_project_rev_amt_tab(i);
        ELSE
            l_conversion_required_flag := 'Y';
        END IF;

        IF l_conversion_required_flag = 'Y' THEN
            IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                   (p_msg         => 'Before calling
                       pa_fp_gen_billing_amounts.CONVERT_TXN_AMT_TO_PC_PFC',
                       p_module_name => l_module_name,
                    p_log_level   => 5);
            END IF;
            PA_FP_GEN_BILLING_AMOUNTS.CONVERT_TXN_AMT_TO_PC_PFC
               (P_PROJECT_ID             =>  P_PROJECT_ID,
                P_BUDGET_VERSION_ID      =>  P_BUDGET_VERSION_ID,
                P_RES_ASG_ID             =>  NULL,
                P_START_DATE             =>  l_event_date_tab(i),
                P_END_DATE               =>  l_event_date_tab(i),
                P_CURRENCY_CODE          =>  l_txn_currency_code_tab(i),
                P_TXN_RAW_COST           =>  NULL,
                P_TXN_BURDENED_COST      =>  NULL,
                P_TXN_REV_AMOUNT         =>  l_txn_rev_amt_tab(i),
                X_PROJFUNC_RAW_COST      =>  l_projfunc_raw_cost,
                X_PROJFUNC_BURDENED_COST =>  l_projfunc_burdened_cost,
                X_PROJFUNC_REVENUE       =>  l_projfunc_revenue,
                X_PROJFUNC_REJECTION     =>  l_projfunc_rejection_code,
                X_PROJ_RAW_COST          =>  l_proj_raw_cost,
                X_PROJ_BURDENED_COST     =>  l_proj_burdened_cost,
                X_PROJ_REVENUE           =>  l_proj_revenue,
                X_PROJ_REJECTION         =>  l_proj_rejection_code,
                X_RETURN_STATUS          =>  x_return_status,
                X_MSG_COUNT              =>  x_MSG_COUNT,
                X_MSG_DATA               =>  x_MSG_DATA);
            IF p_pa_debug_mode = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
                  (p_msg         => 'Status after calling
                       pa_fp_gen_billing_amounts.CONVERT_TXN_AMT_TO_PC_PFC:'
                       ||x_return_status,
                   p_module_name => l_module_name,
                   p_log_level   => 5);
           END IF;
           IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;
        END IF;

        X_PROJFUNC_REVENUE := X_PROJFUNC_REVENUE + NVL(l_projfunc_revenue,0);
        X_PROJECT_REVENUE  := X_PROJECT_REVENUE + NVL(l_proj_revenue,0);
    END LOOP;

    IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.Reset_Curr_Function;
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
                 x_msg_data  := l_data;
                 x_msg_count := l_msg_count;
          ELSE
                x_msg_count := l_msg_count;
          END IF;
          ROLLBACK;

          x_return_status := FND_API.G_RET_STS_ERROR;
          IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Invalid Arguments Passed',
                p_module_name => l_module_name,
                p_log_level   => 5);
          PA_DEBUG.Reset_Curr_Function;
          END IF;
          RAISE;

      WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_data      := SUBSTR(SQLERRM,1,240);
           FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_BILLING_AMOUNTS',
               p_procedure_name => 'GET_BILLING_EVENT_AMT_IN_PFC');
           IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                p_module_name => l_module_name,
                p_log_level   => 5);
                PA_DEBUG.Reset_Curr_Function;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END GET_BILLING_EVENT_AMT_IN_PFC;


/**
 * This procedure calls the PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS API
 * with all of the parameter information for Billing Events.
 *
 * The logic for this procedure has been taken directly from the
 * GEN_BILLING_AMOUNTS API (PAFPGABB.pls version 115.28).
 *
 * This API has been created for the GET_BILLING_EVENT_AMT_IN_PFC
 * API to address bug 4067836.
 */
PROCEDURE MAP_BILLING_EVENT_RLMI_RBS
          (P_PROJECT_ID                     IN              PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID              IN              PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC                    IN              PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           X_TXN_SOURCE_ID_COUNT            OUT   NOCOPY    NUMBER,
           X_TXN_SOURCE_ID_TAB              OUT   NOCOPY    PA_PLSQL_DATATYPES.IdTabTyp,
           X_RES_LIST_MEMBER_ID_TAB         OUT   NOCOPY    PA_PLSQL_DATATYPES.IdTabTyp,
           X_RBS_ELEMENT_ID_TAB             OUT   NOCOPY    PA_PLSQL_DATATYPES.IdTabTyp,
           X_TXN_ACCUM_HEADER_ID_TAB        OUT   NOCOPY    PA_PLSQL_DATATYPES.IdTabTyp,
           X_RETURN_STATUS                  OUT   NOCOPY    VARCHAR2,
           X_MSG_COUNT                      OUT   NOCOPY    NUMBER,
           X_MSG_DATA                       OUT   NOCOPY    VARCHAR2) IS

l_module_name         VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_BILLING_AMOUNTS.MAP_BILLING_EVENT_RLMI_RBS';

l_ret_status                VARCHAR2(100);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);
l_data                      VARCHAR2(2000);
l_msg_index_out             NUMBER:=0;

l_count1                      NUMBER;
l_project_id_tab               PA_PLSQL_DATATYPES.IdTabTyp;
--Local pl/sql table to call Map_Rlmi_Rbs api
l_TXN_SOURCE_ID_tab            PA_PLSQL_DATATYPES.IdTabTyp;
l_TXN_SOURCE_TYPE_CODE_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
l_PERSON_ID_tab                PA_PLSQL_DATATYPES.IdTabTyp;
l_JOB_ID_tab                   PA_PLSQL_DATATYPES.IdTabTyp;
l_ORGANIZATION_ID_tab          PA_PLSQL_DATATYPES.IdTabTyp;
l_VENDOR_ID_tab                PA_PLSQL_DATATYPES.IdTabTyp;
l_EXPENDITURE_TYPE_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
l_EVENT_TYPE_tab               PA_PLSQL_DATATYPES.Char30TabTyp;
l_NON_LABOR_RESOURCE_tab       PA_PLSQL_DATATYPES.Char20TabTyp;
l_EXPENDITURE_CATEGORY_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
l_REVENUE_CATEGORY_CODE_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
l_NLR_ORGANIZATION_ID_tab      PA_PLSQL_DATATYPES.IdTabTyp;
l_EVENT_CLASSIFICATION_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
l_SYS_LINK_FUNCTION_tab        PA_PLSQL_DATATYPES.Char30TabTyp;
l_PROJECT_ROLE_ID_tab          PA_PLSQL_DATATYPES.IdTabTyp;
l_RESOURCE_CLASS_CODE_tab      PA_PLSQL_DATATYPES.Char30TabTyp;
l_MFC_COST_TYPE_ID_tab         PA_PLSQL_DATATYPES.IDTabTyp;
l_RESOURCE_CLASS_FLAG_tab      PA_PLSQL_DATATYPES.Char1TabTyp;
l_FC_RES_TYPE_CODE_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
l_INVENTORY_ITEM_ID_tab        PA_PLSQL_DATATYPES.IDTabTyp;
l_ITEM_CATEGORY_ID_tab         PA_PLSQL_DATATYPES.IDTabTyp;
l_PERSON_TYPE_CODE_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
l_BOM_RESOURCE_ID_tab          PA_PLSQL_DATATYPES.IDTabTyp;
l_NAMED_ROLE_tab               PA_PLSQL_DATATYPES.Char80TabTyp;
l_INCURRED_BY_RES_FLAG_tab     PA_PLSQL_DATATYPES.Char1TabTyp;
l_RATE_BASED_FLAG_tab          PA_PLSQL_DATATYPES.Char1TabTyp;
l_TXN_TASK_ID_tab              PA_PLSQL_DATATYPES.IdTabTyp;
l_TXN_WBS_ELEMENT_VER_ID_tab   PA_PLSQL_DATATYPES.IdTabTyp;
l_TXN_RBS_ELEMENT_ID_tab       PA_PLSQL_DATATYPES.IdTabTyp;
l_TXN_PLAN_START_DATE_tab      PA_PLSQL_DATATYPES.DateTabTyp;
l_TXN_PLAN_END_DATE_tab        PA_PLSQL_DATATYPES.DateTabTyp;
--out param from PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS
l_map_txn_source_id_tab         PA_PLSQL_DATATYPES.IdTabTyp;
l_map_rlm_id_tab                PA_PLSQL_DATATYPES.IdTabTyp;
l_map_rbs_element_id_tab        PA_PLSQL_DATATYPES.IdTabTyp;
l_map_txn_accum_header_id_tab   PA_PLSQL_DATATYPES.IdTabTyp;

BEGIN
  /* Setting initial values */
    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function     => 'MAP_BILLING_EVENT_RLMI_RBS'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
    END IF;

 /* Deleting all the records from the temporary table */
   DELETE FROM PA_RES_LIST_MAP_TMP1;
   DELETE FROM PA_RES_LIST_MAP_TMP4;

                     SELECT    PROJECT_ID,
                               nvl(TASK_ID,0),
                               EVENT_ID,
                               EVENT_TYPE,
                               'BILLING_EVENTS',
                               ORGANIZATION_ID,
                               INVENTORY_ITEM_ID,
                               event_date,
                               event_date,
                               DECODE(EVENT_TYPE,null,NULL,'EVENT_TYPE'),
                               'FINANCIAL_ELEMENTS'
                     BULK COLLECT
                     INTO      l_project_id_tab,
                               l_TXN_TASK_ID_tab,
                               l_TXN_SOURCE_ID_tab,
                               l_EVENT_TYPE_tab,
                               l_TXN_SOURCE_TYPE_CODE_tab,
                               l_ORGANIZATION_ID_tab,
                               l_INVENTORY_ITEM_ID_tab,
                               l_TXN_PLAN_START_DATE_tab,
                               l_TXN_PLAN_END_DATE_tab,
                               l_FC_RES_TYPE_CODE_tab,
                               l_RESOURCE_CLASS_CODE_tab
                     FROM      PA_EVENTS_DELIVERABLE_V
                     WHERE     PROJECT_ID = P_PROJECT_ID;

    x_txn_source_id_count := l_TXN_SOURCE_ID_tab.count;

    IF l_TXN_SOURCE_ID_tab.count = 0 THEN
       IF P_PA_DEBUG_MODE = 'Y' THEN
           PA_DEBUG.Reset_curr_function;
       END IF;
       RETURN;
    END IF;

       FOR bb in 1..l_TXN_SOURCE_ID_tab.count LOOP
                 l_PERSON_ID_tab(bb)             := null;
                 l_JOB_ID_tab(bb)                := null;
                 l_VENDOR_ID_tab(bb)             := null;
                 l_EXPENDITURE_TYPE_tab(bb)      := null;
                 l_NON_LABOR_RESOURCE_tab(bb)    := null;
                 l_EXPENDITURE_CATEGORY_tab(bb)  := null;
                 l_REVENUE_CATEGORY_CODE_tab(bb) := null;
                 l_NLR_ORGANIZATION_ID_tab(bb)   := null;
                 l_EVENT_CLASSIFICATION_tab(bb)  := null;
                 l_SYS_LINK_FUNCTION_tab(bb)     := null;
                 l_PROJECT_ROLE_ID_tab(bb)       := null;
                 l_MFC_COST_TYPE_ID_tab(bb)      := null;
                 l_RESOURCE_CLASS_FLAG_tab(bb)   := null;
                 l_ITEM_CATEGORY_ID_tab(bb)      := null;
                 l_PERSON_TYPE_CODE_tab(bb)      := null;
                 l_BOM_RESOURCE_ID_tab(bb)       := null;
                 l_NAMED_ROLE_tab(bb)            := null;
                 l_INCURRED_BY_RES_FLAG_tab(bb)  := null;
                 l_RATE_BASED_FLAG_tab(bb)       := null;
                 l_TXN_WBS_ELEMENT_VER_ID_tab(bb):= null;
                 l_TXN_RBS_ELEMENT_ID_tab(bb)    := null;
       END LOOP;
     --dbms_output.put_line('l_TXN_SOURCE_ID_tab.count: '||l_TXN_SOURCE_ID_tab.count);
    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_MSG           => 'Before calling PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS',
            P_MODULE_NAME   => l_module_name);
    END IF;
    PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS (
         P_PROJECT_ID                   => p_project_id,
         P_BUDGET_VERSION_ID            => NULL,
         P_RESOURCE_LIST_ID             => P_FP_COLS_REC.X_RESOURCE_LIST_ID,
         P_RBS_VERSION_ID               => NULL,
         P_CALLING_PROCESS              => 'BUDGET_GENERATION',
         P_CALLING_CONTEXT              => 'PLSQL',
         P_PROCESS_CODE                 => 'RES_MAP',
         P_CALLING_MODE                 => 'PLSQL_TABLE',
         P_INIT_MSG_LIST_FLAG           => 'N',
         P_COMMIT_FLAG                  => 'N',
         P_TXN_SOURCE_ID_TAB            => l_TXN_SOURCE_ID_tab,
         P_TXN_SOURCE_TYPE_CODE_TAB     => l_TXN_SOURCE_TYPE_CODE_tab,
         P_PERSON_ID_TAB                => l_PERSON_ID_tab,
         P_JOB_ID_TAB                   => l_JOB_ID_tab,
         P_ORGANIZATION_ID_TAB          => l_ORGANIZATION_ID_tab,
         P_VENDOR_ID_TAB                => l_VENDOR_ID_tab,
         P_EXPENDITURE_TYPE_TAB         => l_EXPENDITURE_TYPE_tab,
         P_EVENT_TYPE_TAB               => l_EVENT_TYPE_tab,
         P_NON_LABOR_RESOURCE_TAB       => l_NON_LABOR_RESOURCE_tab,
         P_EXPENDITURE_CATEGORY_TAB     => l_EXPENDITURE_CATEGORY_tab,
         P_REVENUE_CATEGORY_CODE_TAB    =>l_REVENUE_CATEGORY_CODE_tab,
         P_NLR_ORGANIZATION_ID_TAB      =>l_NLR_ORGANIZATION_ID_tab,
         P_EVENT_CLASSIFICATION_TAB     => l_EVENT_CLASSIFICATION_tab,
         P_SYS_LINK_FUNCTION_TAB        => l_SYS_LINK_FUNCTION_tab,
         P_PROJECT_ROLE_ID_TAB          => l_PROJECT_ROLE_ID_tab,
         P_RESOURCE_CLASS_CODE_TAB      => l_RESOURCE_CLASS_CODE_tab,
         P_MFC_COST_TYPE_ID_TAB         => l_MFC_COST_TYPE_ID_tab,
         P_RESOURCE_CLASS_FLAG_TAB      => l_RESOURCE_CLASS_FLAG_tab,
         P_FC_RES_TYPE_CODE_TAB         => l_FC_RES_TYPE_CODE_tab,
         P_INVENTORY_ITEM_ID_TAB        => l_INVENTORY_ITEM_ID_tab,
         P_ITEM_CATEGORY_ID_TAB         => l_ITEM_CATEGORY_ID_tab,
         P_PERSON_TYPE_CODE_TAB         => l_PERSON_TYPE_CODE_tab,
         P_BOM_RESOURCE_ID_TAB          =>l_BOM_RESOURCE_ID_tab,
         P_NAMED_ROLE_TAB               =>l_NAMED_ROLE_tab,
         P_INCURRED_BY_RES_FLAG_TAB     =>l_INCURRED_BY_RES_FLAG_tab,
         P_RATE_BASED_FLAG_TAB          =>l_RATE_BASED_FLAG_tab,
         P_TXN_TASK_ID_TAB              =>l_TXN_TASK_ID_tab,
         P_TXN_WBS_ELEMENT_VER_ID_TAB   => l_TXN_WBS_ELEMENT_VER_ID_tab,
         P_TXN_RBS_ELEMENT_ID_TAB       => l_TXN_RBS_ELEMENT_ID_tab,
         P_TXN_PLAN_START_DATE_TAB      => l_TXN_PLAN_START_DATE_tab,
         P_TXN_PLAN_END_DATE_TAB        => l_TXN_PLAN_END_DATE_tab,
         X_TXN_SOURCE_ID_TAB            =>x_txn_source_id_tab,
         X_RES_LIST_MEMBER_ID_TAB       =>x_res_list_member_id_tab,
         X_RBS_ELEMENT_ID_TAB           =>x_rbs_element_id_tab,
         X_TXN_ACCUM_HEADER_ID_TAB      =>x_txn_accum_header_id_tab,
         X_RETURN_STATUS                => x_return_status,
         X_MSG_COUNT                    => x_msg_count,
         X_MSG_DATA                     => x_msg_data );
    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_MSG           => 'After calling PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS: '||
                               x_return_status,
            P_MODULE_NAME   => l_module_name);
    END IF;

    /*dbms_output.put_line('After calling PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS: '||x_return_status);
    dbms_output.put_line('l_map_rlm_id_tab.count: '||l_map_rlm_id_tab.count);*/
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

      SELECT   /*+ INDEX(PA_RES_LIST_MAP_TMP4,PA_RES_LIST_MAP_TMP4_N1)*/
               count(*) INTO l_count1
      FROM     PA_RES_LIST_MAP_TMP4
      WHERE    RESOURCE_LIST_MEMBER_ID IS NULL and rownum=1;
      IF l_count1 > 0 THEN
           PA_UTILS.ADD_MESSAGE
              (p_app_short_name => 'PA',
               p_msg_name       => 'PA_INVALID_MAPPING_ERR');
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_curr_function;
    END IF;

 EXCEPTION
   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
   -- Bug Fix: 4569365. Removed MRC code.
   --   PA_MRC_FINPLAN.G_CALLING_MODULE := Null;
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

      x_return_status := FND_API.G_RET_STS_ERROR;

      IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_curr_function;
      END IF;

      RAISE;

    WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      := SUBSTR(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_BILLING_AMOUNTS'
              ,p_procedure_name => 'MAP_BILLING_EVENT_RLMI_RBS');

     IF P_PA_DEBUG_MODE = 'Y' THEN
         PA_DEBUG.Reset_curr_function;
     END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END MAP_BILLING_EVENT_RLMI_RBS;

/**
 * This procedure updates PA_RES_LIST_TMP4 records with the proper
 * txn_resource_assignment_id. Additionally, if the Retain Manually
 * Added Plan Lines option is enabled, then records for manually
 * added resources are deleted from the tmp4 table.
 *
 * The logic for this procedure has been taken directly from the
 * UPDATE_RES_ASG API (PAFPGAMB.pls version 115.90).
 *
 * This API has been created for the GET_BILLING_EVENT_AMT_IN_PFC
 * API to address bug 4067836.
 *
 * Note: parameter P_WP_STRUCTURE_VER_ID has Default value of Null.
 */
PROCEDURE UPD_TMP4_TXN_RA_ID_AND_ML
          (P_PROJECT_ID             IN              PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID      IN              PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC            IN              PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
	   P_GEN_SRC_CODE           IN              PA_PROJ_FP_OPTIONS.GEN_ALL_SRC_CODE%TYPE,
           P_WP_STRUCTURE_VER_ID    IN              PA_BUDGET_VERSIONS.PROJECT_STRUCTURE_VERSION_ID%TYPE,
           X_RETURN_STATUS          OUT   NOCOPY    VARCHAR2,
           X_MSG_COUNT              OUT   NOCOPY    NUMBER,
           X_MSG_DATA               OUT   NOCOPY    VARCHAR2) IS

l_module_name         VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_BILLING_AMOUNTS.UPD_TMP4_TXN_RA_ID_AND_ML';

l_etc_start_date               DATE;
l_stru_sharing_code            PA_PROJECTS_ALL.STRUCTURE_SHARING_CODE%TYPE;

l_res_assgn_id_tab             PA_PLSQL_DATATYPES.IdTabTyp;
l_rlm_id_tab                   PA_PLSQL_DATATYPES.IdTabTyp;
l_txn_task_id_tab              PA_PLSQL_DATATYPES.IdTabTyp;
l_txn_top_task_id_tab	       PA_PLSQL_DATATYPES.IdTabTyp;
l_txn_sub_task_id_tab	       PA_PLSQL_DATATYPES.IdTabTyp;
l_mapped_task_id_tab           PA_PLSQL_DATATYPES.IdTabTyp;


l_ret_status                   VARCHAR2(100);
l_msg_count                    NUMBER;
l_msg_data                     VARCHAR2(2000);
l_data                         VARCHAR2(2000);
l_msg_index_out                NUMBER:=0;
BEGIN
  /* Setting initial values */
    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function     => 'UPD_TMP4_TXN_RA_ID_AND_ML'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
    END IF;

  l_stru_sharing_code := PA_PROJECT_STRUCTURE_UTILS.
                    get_Structure_sharing_code(P_PROJECT_ID=> P_PROJECT_ID);

  IF P_FP_COLS_REC.X_FIN_PLAN_LEVEL_CODE = 'P' or
     P_GEN_SRC_CODE = 'RESOURCE_SCHEDULE' THEN

    /* Updating the TMP4 table with resource_assignment_id */
    SELECT  /*+ INDEX(T,PA_RES_LIST_MAP_TMP4_N1)*/
            distinct P.RESOURCE_ASSIGNMENT_ID,
            P.RESOURCE_LIST_MEMBER_ID
    BULK    COLLECT
    INTO    l_res_assgn_id_tab,
            l_rlm_id_tab
    FROM    PA_RESOURCE_ASSIGNMENTS P,
            PA_RES_LIST_MAP_TMP4 T
    WHERE   P.BUDGET_VERSION_ID           = P_BUDGET_VERSION_ID
    AND     NVL(P.TASK_ID,0)              = 0
    AND     P.PROJECT_ASSIGNMENT_ID       = -1
    AND     T.RESOURCE_LIST_MEMBER_ID     = P.RESOURCE_LIST_MEMBER_ID;

     FORALL  i IN 1..l_res_assgn_id_tab.count
       UPDATE  /*+ INDEX(PA_RES_LIST_MAP_TMP4,PA_RES_LIST_MAP_TMP4_N1)*/
               PA_RES_LIST_MAP_TMP4
       SET     TXN_RESOURCE_ASSIGNMENT_ID  = l_res_assgn_id_tab(i)
       WHERE   RESOURCE_LIST_MEMBER_ID     = l_rlm_id_tab(i);
       /* AND     NVL(TXN_TASK_ID,0)          = l_txn_task_id_tab(i);
          task id check is not required. commented for bug 3475017  */

  /* Updating the TMP4 table with resource_assignment_id
     when planning level is Lowest task (Financial task only)*/
  ELSIF   P_FP_COLS_REC.X_FIN_PLAN_LEVEL_CODE = 'L'
          AND (  l_stru_sharing_code IS NULL OR
                 l_stru_sharing_code = 'SHARE_FULL' OR
		 P_GEN_SRC_CODE IN ( 'FINANCIAL_PLAN',
                 'OPEN_COMMITMENTS','BILLING_EVENTS'  )) THEN

    SELECT  /*+ INDEX(T,PA_RES_LIST_MAP_TMP4_N1)*/
            P.RESOURCE_ASSIGNMENT_ID,
            P.RESOURCE_LIST_MEMBER_ID,
            NVL(T.TXN_TASK_ID,0)
    BULK    COLLECT
    INTO    l_res_assgn_id_tab,
            l_rlm_id_tab,
            l_txn_task_id_tab
    FROM    PA_RESOURCE_ASSIGNMENTS P,
            PA_RES_LIST_MAP_TMP4 T
    WHERE   P.BUDGET_VERSION_ID           = P_BUDGET_VERSION_ID
    AND     NVL(P.TASK_ID,0)              = NVL(T.TXN_TASK_ID,0)
    AND     P.PROJECT_ASSIGNMENT_ID       = -1
    AND     T.RESOURCE_LIST_MEMBER_ID     = P.RESOURCE_LIST_MEMBER_ID;

    FORALL  i IN 1..l_res_assgn_id_tab.count
       UPDATE  /*+ INDEX(PA_RES_LIST_MAP_TMP4,PA_RES_LIST_MAP_TMP4_N1)*/
               PA_RES_LIST_MAP_TMP4
       SET     TXN_RESOURCE_ASSIGNMENT_ID  = l_res_assgn_id_tab(i)
       WHERE   RESOURCE_LIST_MEMBER_ID     = l_rlm_id_tab(i)
       AND     NVL(TXN_TASK_ID,0)          = l_txn_task_id_tab(i);

  /* Updating the TMP4 table with resource_assignment_id
     when planning level is Top task (Financial task only)*/
  ELSIF  P_FP_COLS_REC.X_FIN_PLAN_LEVEL_CODE = 'T'
         AND (   l_stru_sharing_code IS NULL  OR
                 l_stru_sharing_code = 'SHARE_FULL' OR
	 	 P_GEN_SRC_CODE IN ( 'FINANCIAL_PLAN',
                 'OPEN_COMMITMENTS','BILLING_EVENTS'  )) THEN

    SELECT  /*+ INDEX(T,PA_RES_LIST_MAP_TMP4_N1)*/
            P.RESOURCE_ASSIGNMENT_ID,
            P.RESOURCE_LIST_MEMBER_ID,
 	    NVL(P.TASK_ID,0),
	    NVL(T.TXN_TASK_ID,0)
    BULK    COLLECT
    INTO    l_res_assgn_id_tab,
            l_rlm_id_tab,
	    l_txn_top_task_id_tab,
            l_txn_sub_task_id_tab
    FROM    PA_RESOURCE_ASSIGNMENTS P,
            PA_RES_LIST_MAP_TMP4 T,
            PA_TASKS TS
    WHERE   P.BUDGET_VERSION_ID           = P_BUDGET_VERSION_ID
    AND     TS.TASK_ID(+)                 = NVL(T.TXN_TASK_ID,0)
    AND     NVL(P.TASK_ID,0)              = NVL(TS.TOP_TASK_ID,0)
    AND     P.PROJECT_ASSIGNMENT_ID       = -1
    AND     T.RESOURCE_LIST_MEMBER_ID     = P.RESOURCE_LIST_MEMBER_ID;

    FORALL i IN 1..l_res_assgn_id_tab.count
       UPDATE  /*+ INDEX(PA_RES_LIST_MAP_TMP4,PA_RES_LIST_MAP_TMP4_N1)*/
               PA_RES_LIST_MAP_TMP4 tmp4
       SET     TXN_RESOURCE_ASSIGNMENT_ID  = l_res_assgn_id_tab(i)
       WHERE   RESOURCE_LIST_MEMBER_ID     = l_rlm_id_tab(i)
       	 AND   NVL(TXN_TASK_ID,0) = l_txn_sub_task_id_tab(i);

/* Updating the TMP4 table with resource_assignment_id when
   planning level is Lowest task (both Financial task and Workplan task)*/

ELSIF   P_FP_COLS_REC.X_FIN_PLAN_LEVEL_CODE = 'L' AND l_stru_sharing_code IS NOT NULL THEN
   SELECT  resource_assignment_id,
           resource_list_member_id,
           txn_task_id,
           mapped_fin_task_id
    BULK     COLLECT INTO
             l_res_assgn_id_tab,
             l_rlm_id_tab,
             l_txn_task_id_tab,
             l_mapped_task_id_tab
    FROM
(
    SELECT   /*+ INDEX(T,PA_RES_LIST_MAP_TMP4_N1)*/
             P.RESOURCE_ASSIGNMENT_ID resource_assignment_id,
             P.RESOURCE_LIST_MEMBER_ID resource_list_member_id,
             NVL(T.TXN_TASK_ID,0) txn_task_id ,
             NVL(V.MAPPED_FIN_TASK_ID,0) mapped_fin_task_id
    FROM     PA_RESOURCE_ASSIGNMENTS P,
             PA_RES_LIST_MAP_TMP4 T,
             PA_MAP_WP_TO_FIN_TASKS_V V
    WHERE    P.BUDGET_VERSION_ID           = P_BUDGET_VERSION_ID
    AND      V.PARENT_STRUCTURE_VERSION_ID = P_WP_STRUCTURE_VER_ID
    AND      NVL(T.TXN_TASK_ID,0)          = NVL(V.PROJ_ELEMENT_ID,0)
    AND      P.PROJECT_ASSIGNMENT_ID       = -1
    AND      T.RESOURCE_LIST_MEMBER_ID     = P.RESOURCE_LIST_MEMBER_ID
    AND      NVL(P.TASK_ID,0)              = NVL(V.MAPPED_FIN_TASK_ID,0)
    AND      NVL(T.TXN_TASK_ID,0)	   > 0
    union
    SELECT   /*+ INDEX(T,PA_RES_LIST_MAP_TMP4_N1)*/
             P.RESOURCE_ASSIGNMENT_ID resource_assignment_id,
             P.RESOURCE_LIST_MEMBER_ID resource_list_member_id,
             0 txn_task_id,
             0 mapped_fin_task_id
    FROM     PA_RESOURCE_ASSIGNMENTS P,
             PA_RES_LIST_MAP_TMP4 T
    WHERE    P.BUDGET_VERSION_ID           = P_BUDGET_VERSION_ID
    AND      P.PROJECT_ASSIGNMENT_ID       = -1
    AND      T.RESOURCE_LIST_MEMBER_ID     = P.RESOURCE_LIST_MEMBER_ID
    AND      NVL(P.TASK_ID,0)                = 0  );

     --@@
         IF P_PA_DEBUG_MODE = 'Y' THEN
          for i in 1..l_res_assgn_id_tab.count loop
              pa_fp_gen_amount_utils.fp_debug
                         (p_msg         => 'within update when share partial and planning at lowest task i:'
					  ||i||'; ra id in cursor:'||l_res_assgn_id_tab(i)
 					  ||';rlm id in cursor:'||l_rlm_id_tab(i)
					  ||';task id in cursor:'||l_txn_task_id_tab(i)
				          ||';mapped task id in cursor:'||l_mapped_task_id_tab(i),
                          p_module_name => l_module_name,
                          p_log_level   => 5);
           end loop;
          END IF;
     --@@

    --dbms_output.put_line('@@l_res_assgn_id_tab.count'||l_res_assgn_id_tab.count);
    --dbms_output.put_line('@@l_res_assgn_id_tab(1):'||l_res_assgn_id_tab(1));
    --dbms_output.put_line('@@l_res_assgn_id_tab(2):'||l_res_assgn_id_tab(2));
    --dbms_output.put_line('@@l_res_assgn_id_tab(3):'||l_res_assgn_id_tab(3));
    --dbms_output.put_line('@@l_res_assgn_id_tab(4):'||l_res_assgn_id_tab(4));
    --dbms_output.put_line('@@l_rlm_id_tab(1):'||l_rlm_id_tab(1));
    --dbms_output.put_line('@@l_rlm_id_tab(2):'||l_rlm_id_tab(2));
    --dbms_output.put_line('@@l_rlm_id_tab(1):'||l_rlm_id_tab(3));
    --dbms_output.put_line('@@l_rlm_id_tab(2):'||l_rlm_id_tab(4));
    --dbms_output.put_line('@@l_txn_task_id_tab(1):'||l_txn_task_id_tab(1));
    --dbms_output.put_line('@@l_txn_task_id_tab(2):'||l_txn_task_id_tab(2));
    --dbms_output.put_line('@@l_txn_task_id_tab(3):'||l_txn_task_id_tab(3));
    --dbms_output.put_line('@@l_txn_task_id_tab(4):'||l_txn_task_id_tab(4));
    --select count(*) into tmp_count from   PA_RES_LIST_MAP_TMP4;
    --dbms_output.put_line('@@l_count of tmp4:'||tmp_count);
    --select txn_resource_assignment_id,resource_list_member_id, txn_task_id
    --bulk collect into tmp_ra_id_tab, tmp_rlm_id_tab, tmp_task_id_tab
    --from   PA_RES_LIST_MAP_TMP4;
    --dbms_output.put_line('@@tmp_ra_id_tab.count'||tmp_ra_id_tab.count);
    --dbms_output.put_line('@@tmp_ra_id_tab(1):'||tmp_ra_id_tab(1));
    --dbms_output.put_line('@@tmp_ra_id_tab(2):'||tmp_ra_id_tab(2));
    --dbms_output.put_line('@@tmp_ra_id_tab(3):'||tmp_ra_id_tab(3));
    --dbms_output.put_line('@@tmp_rlm_id_tab(1):'||tmp_rlm_id_tab(1));
    --dbms_output.put_line('@@tmp_rlm_id_tab(2):'||tmp_rlm_id_tab(2));
    --dbms_output.put_line('@@tmp_rlm_id_tab(3):'||tmp_rlm_id_tab(3));
    --dbms_output.put_line('@@tmp_task_id_tab(1):'||tmp_task_id_tab(1));
    --dbms_output.put_line('@@tmp_task_id_tab(2):'||tmp_task_id_tab(2));
    --dbms_output.put_line('@@tmp_task_id_tab(3):'||tmp_task_id_tab(3));

    FORALL  i IN 1..l_res_assgn_id_tab.count
       UPDATE  /*+ INDEX(PA_RES_LIST_MAP_TMP4,PA_RES_LIST_MAP_TMP4_N1)*/
               PA_RES_LIST_MAP_TMP4
       SET     TXN_RESOURCE_ASSIGNMENT_ID  = l_res_assgn_id_tab(i)
       WHERE   RESOURCE_LIST_MEMBER_ID     = l_rlm_id_tab(i)
       AND     NVL(TXN_TASK_ID,0)          = l_txn_task_id_tab(i);

 ELSIF   P_FP_COLS_REC.X_FIN_PLAN_LEVEL_CODE = 'T'
         AND l_stru_sharing_code IS NOT NULL THEN
   SELECT  resource_assignment_id,
           resource_list_member_id,
           txn_task_id,
           mapped_fin_task_id
    BULK     COLLECT INTO
             l_res_assgn_id_tab,
             l_rlm_id_tab,
             l_txn_task_id_tab,
             l_mapped_task_id_tab
    FROM
(
    SELECT  /*+ INDEX(T,PA_RES_LIST_MAP_TMP4_N1)*/
            P.RESOURCE_ASSIGNMENT_ID resource_assignment_id,
            P.RESOURCE_LIST_MEMBER_ID resource_list_member_id,
            NVL(T.TXN_TASK_ID,0) txn_task_id,
            NVL(V.MAPPED_FIN_TASK_ID,0) mapped_fin_task_id
    FROM    PA_RESOURCE_ASSIGNMENTS P,
            PA_RES_LIST_MAP_TMP4 T,
            PA_MAP_WP_TO_FIN_TASKS_V V,
            PA_TASKS TS
    WHERE   P.BUDGET_VERSION_ID           = P_BUDGET_VERSION_ID
    AND     V.PARENT_STRUCTURE_VERSION_ID = P_WP_STRUCTURE_VER_ID
    AND     t.txn_task_id                 = v.PROJ_ELEMENT_ID
    AND     NVL(TS.top_TASK_ID,0)         = NVL(p.task_id,0)
    AND     TS.TASK_ID(+)                 = NVL(V.MAPPED_FIN_TASK_ID,0)
    AND     P.PROJECT_ASSIGNMENT_ID       = -1
    AND     T.RESOURCE_LIST_MEMBER_ID     = P.RESOURCE_LIST_MEMBER_ID
    AND     NVL(T.TXN_TASK_ID,0) > 0
    union
    SELECT   /*+ INDEX(T,PA_RES_LIST_MAP_TMP4_N1)*/
             DISTINCT P.RESOURCE_ASSIGNMENT_ID resource_assignment_id,
             P.RESOURCE_LIST_MEMBER_ID resource_list_member_id,
             0 txn_task_id,
             0 mapped_fin_task_id
    FROM     PA_RESOURCE_ASSIGNMENTS P,
             PA_RES_LIST_MAP_TMP4 T
    WHERE    P.BUDGET_VERSION_ID           = P_BUDGET_VERSION_ID
    AND      P.PROJECT_ASSIGNMENT_ID       = -1
    AND      T.RESOURCE_LIST_MEMBER_ID     = P.RESOURCE_LIST_MEMBER_ID
    AND      NVL(P.TASK_ID,0)              = 0
    AND      NVL(T.TXN_TASK_ID,0)          = NVL(P.TASK_ID,0)     );

    FORALL  i IN 1..l_res_assgn_id_tab.count
       UPDATE  /*+ INDEX(PA_RES_LIST_MAP_TMP4,PA_RES_LIST_MAP_TMP4_N1)*/
               PA_RES_LIST_MAP_TMP4
       SET     TXN_RESOURCE_ASSIGNMENT_ID  = l_res_assgn_id_tab(i)
       WHERE   RESOURCE_LIST_MEMBER_ID     = l_rlm_id_tab(i)
       AND     NVL(TXN_TASK_ID,0)          = l_txn_task_id_tab(i);

   END IF;

    /* If the Retain Manually Added Plan Lines option is enabled, we remove
     * all rows in the PA_RES_LIST_MAP_TMP4 table with target resources that
     * have manually added plan lines. Thus, after this point, we can use the
     * mapping table without checking for the manually added lines condition. */
    IF p_fp_cols_rec.x_gen_ret_manual_line_flag = 'Y' THEN
        IF p_fp_cols_rec.x_plan_class_code = 'BUDGET' THEN
            DELETE FROM pa_res_list_map_tmp4 tmp
            WHERE EXISTS
                ( SELECT /*+ INDEX(tmp,PA_RES_LIST_MAP_TMP4_N2)*/ 1
                  FROM   pa_resource_assignments ra
                  WHERE  ra.budget_version_id = p_budget_version_id
                  AND    ra.resource_assignment_id = tmp.txn_resource_assignment_id
                  AND    ra.transaction_source_code IS NULL
                  AND EXISTS
                        ( SELECT 1
                          FROM   pa_budget_lines bl
                          WHERE  bl.resource_assignment_id = ra.resource_assignment_id
                          AND    rownum = 1 ));
        ELSIF p_fp_cols_rec.x_plan_class_code = 'FORECAST' THEN
            l_etc_start_date := PA_FP_GEN_AMOUNT_UTILS.GET_ETC_START_DATE
                                    ( p_budget_version_id );
            IF p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
                DELETE FROM pa_res_list_map_tmp4 tmp
                WHERE EXISTS
                    ( SELECT /*+ INDEX(tmp,PA_RES_LIST_MAP_TMP4_N2)*/ 1
                      FROM   pa_resource_assignments ra
                      WHERE  ra.budget_version_id = p_budget_version_id
                      AND    ra.resource_assignment_id = tmp.txn_resource_assignment_id
                      AND    ra.transaction_source_code IS NULL
                      AND EXISTS
                            ( SELECT 1
                              FROM   pa_budget_lines bl
                              WHERE  bl.resource_assignment_id = ra.resource_assignment_id
                              AND    bl.start_date >= l_etc_start_date
                              AND    rownum = 1 ));
            ELSIF p_fp_cols_rec.x_time_phased_code = 'N' THEN
                DELETE FROM pa_res_list_map_tmp4 tmp
                WHERE EXISTS
                    ( SELECT /*+ INDEX(tmp,PA_RES_LIST_MAP_TMP4_N2)*/ 1
                      FROM   pa_resource_assignments ra
                      WHERE  ra.budget_version_id = p_budget_version_id
                      AND    ra.resource_assignment_id = tmp.txn_resource_assignment_id
                      AND    ra.transaction_source_code IS NULL
                      AND EXISTS
                            ( SELECT 1
                              FROM   pa_budget_lines bl
                              WHERE  bl.resource_assignment_id = ra.resource_assignment_id
                              AND    NVL(quantity,0) <> NVL(init_quantity,0)
                              AND    rownum = 1 ));
            END IF;
        END IF;
    END IF; -- end manual lines logic

    IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_curr_function;
    END IF;
EXCEPTION
   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
   -- Bug Fix: 4569365. Removed MRC code.
   --   PA_MRC_FINPLAN.G_CALLING_MODULE := Null;
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

      x_return_status := FND_API.G_RET_STS_ERROR;

      IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_curr_function;
      END IF;

      RAISE;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      := SUBSTR(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_BILLING_AMOUNTS'
              ,p_procedure_name => 'UPD_TMP4_TXN_RA_ID_AND_ML');

     IF P_PA_DEBUG_MODE = 'Y' THEN
         PA_DEBUG.Reset_curr_function;
     END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END UPD_TMP4_TXN_RA_ID_AND_ML;


END PA_FP_GEN_BILLING_AMOUNTS;

/
