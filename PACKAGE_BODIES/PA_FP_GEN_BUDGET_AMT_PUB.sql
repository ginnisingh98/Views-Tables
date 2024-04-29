--------------------------------------------------------
--  DDL for Package Body PA_FP_GEN_BUDGET_AMT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_GEN_BUDGET_AMT_PUB" as
/* $Header: PAFPGAMB.pls 120.20 2007/11/28 07:46:11 vgovvala ship $ */

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

/**
 * Wrapper API
 *
 * 23-MAY-05 dkuo Added parameters P_CHECK_SRC_ERRORS, X_WARNING_MESSAGE.
 *                Please check body of VALIDATE_SUPPORT_CASES in PAFPGAUB.pls
 *                for list of valid parameter values.
 **/
PROCEDURE GENERATE_BUDGET_AMT_WRP
       (P_PROJECT_ID                     IN            pa_projects_all.PROJECT_ID%TYPE,
        P_BUDGET_VERSION_ID              IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
        P_CALLED_MODE                    IN            VARCHAR2,
        P_COMMIT_FLAG                    IN            VARCHAR2,
        P_INIT_MSG_FLAG                  IN            VARCHAR2,
        P_CHECK_SRC_ERRORS_FLAG          IN            VARCHAR2,
        X_WARNING_MESSAGE                OUT NOCOPY    VARCHAR2,
        X_RETURN_STATUS                  OUT  NOCOPY   VARCHAR2,
        X_MSG_COUNT                      OUT  NOCOPY   NUMBER,
        X_MSG_DATA                   OUT  NOCOPY   VARCHAR2) IS

l_module_name         VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_BUDGET_AMT_PUB.GENERATE_BUDGET_AMT_WRP';

l_cost_version_id            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE;
l_ci_id_tab                  PA_PLSQL_DATATYPES.IdTabTyp;
l_gen_res_asg_id_tab         PA_PLSQL_DATATYPES.IdTabTyp;
l_deleted_res_asg_id_tab     PA_PLSQL_DATATYPES.IdTabTyp;
l_commit_flag                VARCHAR2(1);
l_init_msg_flag              VARCHAR2(1);
l_ret_status                 VARCHAR2(100);
l_msg_count                  NUMBER;
l_msg_data                   VARCHAR2(2000);
l_data                       VARCHAR2(2000);
l_msg_index_out              NUMBER:=0;

l_fp_cols_rec                PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
l_rev_gen_method             VARCHAR2(3);

-- Bug Fix: 4569365. Removed MRC code.
-- g_mrc_exception              EXCEPTION;

l_wp_track_cost_flag         VARCHAR2(1);

l_source_bv_id               PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE;

l_record_version_number      PA_BUDGET_VERSIONS.RECORD_VERSION_NUMBER%TYPE;

l_res_as_id                  PA_PLSQL_DATATYPES.IdTabTyp;  /* Bug 4160375 */
BEGIN
  --hr_utility.trace_on(null,'mftest');
  --hr_utility.trace('---BEGIN---');

  --Setting initial values
  IF p_init_msg_flag = 'Y' THEN
       FND_MSG_PUB.initialize;
  END IF;

  X_MSG_COUNT := 0;
  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

   IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
      PA_DEBUG.init_err_stack('PA_FP_GEN_BUDGET_AMT_PUB.GENERATE_BUDGET_AMT_WRP');
   ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
            pa_debug.set_curr_function( p_function     => 'GENERATE_BUDGET_AMT_WRP'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
   END IF;

    --Calling  the get_plan_version_dtls api
    IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_called_mode => p_called_mode,
              p_msg         => 'Before calling
                             pa_fp_gen_amount_utils.get_plan_version_dtls',
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;
    PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
             (P_PROJECT_ID         => P_PROJECT_ID,
              P_BUDGET_VERSION_ID  => P_BUDGET_VERSION_ID,
              X_FP_COLS_REC        => l_fp_cols_rec,
              X_RETURN_STATUS      => X_RETURN_STATUS,
              X_MSG_COUNT          => X_MSG_COUNT,
              X_MSG_DATA       => X_MSG_DATA);
    IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_called_mode => p_called_mode,
              p_msg         => 'Status after calling
              pa_fp_gen_amount_utils.get_plan_version_dtls: '
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    /* This API validates that the current generation is supported.
     * For a list of unsupported cases, please see comments at the
     * beginning of the VALIDATE_SUPPORT_CASES API (PAFPGAUB.pls) */

    IF p_pa_debug_mode = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
           ( p_msg         => 'Before calling
                               pa_fp_gen_amount_utils.validate_support_cases',
             p_module_name => l_module_name,
             p_log_level   => 5 );
    END IF;

    PA_FP_GEN_AMOUNT_UTILS.VALIDATE_SUPPORT_CASES (
        P_FP_COLS_REC_TGT       => l_fp_cols_rec,
        P_CHECK_SRC_ERRORS_FLAG => P_CHECK_SRC_ERRORS_FLAG,
        P_CALLING_CONTEXT       => P_CALLED_MODE, /* Added for ER 4391321 */
        X_WARNING_MESSAGE       => X_WARNING_MESSAGE,
        X_RETURN_STATUS         => X_RETURN_STATUS,
        X_MSG_COUNT             => X_MSG_COUNT,
        X_MSG_DATA              => X_MSG_DATA );

    IF p_pa_debug_mode = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
           ( p_msg         => 'Status after calling
                              pa_fp_gen_amount_utils.validate_support_cases: '
                              ||x_return_status,
             p_module_name => l_module_name,
             p_log_level   => 5 );
    END IF;
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    /* When VALIDATE_SUPPORT_CASES returns a non-null warning message,
     * we need to Return control to the page/front-end so that a warning
     * can be displayed asking the user whether or not to proceed.
     */
    IF X_WARNING_MESSAGE IS NOT NULL THEN
        -- Before returning, we always have the following check.
        IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
              PA_DEBUG.reset_err_stack;
        ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
              PA_DEBUG.Reset_Curr_Function;
        END IF;

        RETURN;
    END IF;

   --acquire version lock

    SELECT record_version_number
       INTO l_record_version_number
    FROM pa_budget_versions
    WHERE budget_version_id = p_budget_version_id;
    IF p_pa_debug_mode = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
             (p_called_mode => p_called_mode,
              p_msg         => 'Before calling pa_fin_plan_pvt.lock_unlock_version',
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;
    pa_fin_plan_pvt.lock_unlock_version
    (p_budget_version_id    => P_BUDGET_VERSION_ID,
        p_record_version_number => l_record_version_number,
        p_action                => 'L',
        p_user_id               => FND_GLOBAL.USER_ID,
        p_person_id             => NULL,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data);
    IF p_pa_debug_mode = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
             (p_called_mode => p_called_mode,
              p_msg         => 'Status after calling pa_fin_plan_pvt.lock_unlock_version:'
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
            PA_DEBUG.reset_err_stack;
        ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
    RETURN;
    END IF;

    COMMIT;

    /* we need to commit the changes so that the locked by person info
       will be available for other sessions. */

   /* This API returns generic error message that
      can be used for any other process for
      locking the main budget table */

    --Calling  the acquire_locks_for_copy_actual api
    IF p_pa_debug_mode = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
             (p_called_mode => p_called_mode,
              p_msg         => 'Before calling
                               pa_fp_copy_from_pkg.acquire_locks_for_copy_actual',
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;
    PA_FP_COPY_FROM_PKG.ACQUIRE_LOCKS_FOR_COPY_ACTUAL
               (P_PLAN_VERSION_ID   => P_BUDGET_VERSION_ID,
                X_RETURN_STATUS     => X_RETURN_STATUS,
                X_MSG_COUNT         => X_MSG_COUNT,
                X_MSG_DATA      => X_MSG_DATA);
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
         --If we can't acquire lock, customized message is thrown from within
     -- the API, so we should suppress exception error.
         IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
             PA_DEBUG.reset_err_stack;
         ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
             PA_DEBUG.Reset_Curr_Function;
         END IF;
         RETURN;
    END IF;
    IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_called_mode => p_called_mode,
              p_msg         => 'Status after calling
                              pa_fp_copy_from_pkg.acquire_locks_for_copy_actual: '
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
     END IF;

  /* Records are deleted from pa_budget_lines and PA_RESOURCE_ASSIGNMENTS
     tables when the flag is set to N */
     IF l_fp_cols_rec.x_gen_ret_manual_line_flag = 'N' THEN
         DELETE  FROM   PA_BUDGET_LINES
         WHERE          budget_version_id = p_budget_version_id ;

         DELETE  FROM   PA_RESOURCE_ASSIGNMENTS
         WHERE          budget_version_id = p_budget_version_id ;

         -- IPM: New Entity ER ------------------------------------------
         -- Call the maintenance api in DELETE mode
         IF p_pa_debug_mode = 'Y' THEN
             PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                 ( P_MSG               => 'Before calling PA_RES_ASG_CURRENCY_PUB.'
                                          || 'MAINTAIN_DATA',
                   P_CALLED_MODE       => p_called_mode,
                   P_MODULE_NAME       => l_module_name,
                   P_LOG_LEVEL         => 5 );
         END IF;
         PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA
             ( P_FP_COLS_REC           => l_fp_cols_rec,
               P_CALLING_MODULE        => 'BUDGET_GENERATION',
               P_DELETE_FLAG           => 'Y',
               P_VERSION_LEVEL_FLAG    => 'Y',
               P_CALLED_MODE           => p_called_mode,
               X_RETURN_STATUS         => x_return_status,
               X_MSG_COUNT             => x_msg_count,
               X_MSG_DATA              => x_msg_data );
         IF p_pa_debug_mode = 'Y' THEN
             PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                 ( P_MSG               => 'After calling PA_RES_ASG_CURRENCY_PUB.'
                                          || 'MAINTAIN_DATA: ' || x_return_status,
                   P_CALLED_MODE       => p_called_mode,
                   P_MODULE_NAME       => l_module_name,
                   P_LOG_LEVEL         => 5 );
         END IF;
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;
         -- END OF IPM: New Entity ER ------------------------------------------

     ELSIF l_fp_cols_rec.x_gen_ret_manual_line_flag = 'Y' THEN
        -- Bug 4344111: We should delete budget lines for all resources with
        -- non-null transaction source code and then null-out the transaction
        -- source code for these resources. Moved the logic for Bug 4160375
        -- from right before Commitments are processed to this location, and
        -- modified the SELECT statement's WHERE clause to check that the
        -- transaction_source_code IS NOT NULL (which includes the previous
        -- check that transaction_source_code was either Open Commitments,
        -- Billing Events, or Change Documents).

/* Bug 4160375  Fixed the problem of Comm. getting incremented on every round of budget generation */

        SELECT resource_assignment_id
        BULK COLLECT INTO
        l_res_as_id
        FROM PA_RESOURCE_ASSIGNMENTS
        WHERE budget_version_id = p_budget_version_id AND
              transaction_source_code IS NOT NULL;

        IF (l_res_as_id.count > 0) THEN
           FORALL i IN 1 .. l_res_as_id.count
              DELETE FROM PA_BUDGET_LINES
              WHERE resource_assignment_id = l_res_as_id(i);

           FORALL j IN 1 .. l_res_as_id.count
              UPDATE PA_RESOURCE_ASSIGNMENTS
              SET transaction_source_code = null
              WHERE resource_assignment_id = l_res_as_id(j);

           -- IPM: New Entity ER ------------------------------------------
           DELETE pa_resource_asgn_curr_tmp;

           FORALL k IN 1..l_res_as_id.count
               INSERT INTO pa_resource_asgn_curr_tmp (
                   RESOURCE_ASSIGNMENT_ID,
                   DELETE_FLAG )
               VALUES (
                   l_res_as_id(k),
                   'Y' );

           -- Call the maintenance api in DELETE mode
           IF p_pa_debug_mode = 'Y' THEN
               PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                   ( P_MSG               => 'Before calling PA_RES_ASG_CURRENCY_PUB.'
                                            || 'MAINTAIN_DATA',
                     P_CALLED_MODE       => p_called_mode,
                     P_MODULE_NAME       => l_module_name,
                     P_LOG_LEVEL         => 5 );
           END IF;
           PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA
               ( P_FP_COLS_REC           => l_fp_cols_rec,
                 P_CALLING_MODULE        => 'BUDGET_GENERATION',
                 P_DELETE_FLAG           => 'Y',
                 P_VERSION_LEVEL_FLAG    => 'N',
                 P_CALLED_MODE           => p_called_mode,
                 X_RETURN_STATUS         => x_return_status,
                 X_MSG_COUNT             => x_msg_count,
                 X_MSG_DATA              => x_msg_data );
           IF p_pa_debug_mode = 'Y' THEN
               PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                   ( P_MSG               => 'After calling PA_RES_ASG_CURRENCY_PUB.'
                                            || 'MAINTAIN_DATA: ' || x_return_status,
                     P_CALLED_MODE       => p_called_mode,
                     P_MODULE_NAME       => l_module_name,
                     P_LOG_LEVEL         => 5 );
           END IF;
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;
           -- END OF IPM: New Entity ER ------------------------------------------

        END IF;
     END IF; -- Manual lines logic

   --l_rev_gen_method := PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(p_project_id);
     l_rev_gen_method := nvl(l_fp_cols_rec.x_revenue_derivation_method,PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(p_project_id)); --Bug 5462471
   /* Checking for the planning level and calling appropriate API */
   IF l_fp_cols_rec.x_gen_src_code = 'RESOURCE_SCHEDULE' THEN
       IF l_fp_cols_rec.x_version_type = 'REVENUE'
       AND l_rev_gen_method = 'C'   THEN
        IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                  (p_called_mode => p_called_mode,
                   p_msg         => 'Before calling
                   pa_fp_gen_budget_amt_pub.gen_rev_bdgt_amt_res_sch_wrp',
                   p_module_name => l_module_name,
                   p_log_level   => 5);
            END IF;
            --hr_utility.trace('before PA_FP_GEN_BUDGET_AMT_PUB.GEN_REV_BDGT_AMT_RES_SCH_WRP');
            PA_FP_GEN_BUDGET_AMT_PUB.GEN_REV_BDGT_AMT_RES_SCH_WRP
        (P_PROJECT_ID              => P_PROJECT_ID,
            P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
                P_FP_COLS_REC              => l_fp_cols_rec,
            P_PLAN_CLASS_CODE          => l_fp_cols_rec.x_plan_class_code,
            P_GEN_SRC_CODE             => l_fp_cols_rec.x_gen_src_code,
            P_COST_PLAN_TYPE_ID        => l_fp_cols_rec.x_gen_src_plan_type_id,
        p_COST_VERSION_ID          => l_cost_version_id,
        P_RETAIN_MANUAL_FLAG       => l_fp_cols_rec.x_gen_ret_manual_line_flag,
        P_CALLED_MODE              => 'SELF_SERVICE',
        P_INC_CHG_DOC_FLAG         => l_fp_cols_rec.x_gen_incl_change_doc_flag,
        P_INC_BILL_EVENT_FLAG      => l_fp_cols_rec.x_gen_incl_bill_event_flag,
            P_INC_OPEN_COMMIT_FLAG     => l_fp_cols_rec.x_gen_incl_open_comm_flag,
        P_ACTUALS_THRU_DATE        => NULL,
            P_CI_ID_TAB                => l_ci_id_tab,
            PX_GEN_RES_ASG_ID_TAB      => l_gen_res_asg_id_tab,
            PX_DELETED_RES_ASG_ID_TAB  => l_deleted_res_asg_id_tab,
            P_COMMIT_FLAG              => P_COMMIT_FLAG,
            P_INIT_MSG_FLAG            => P_INIT_MSG_FLAG,
            X_RETURN_STATUS            => X_RETURN_STATUS,
            X_MSG_COUNT                => X_MSG_COUNT,
            X_MSG_DATA                => X_MSG_DATA);

            IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
            IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                 (p_called_mode => p_called_mode,
                  p_msg         => 'Status after calling pa_fp_gen_budget_amt_pub.'||
                       'gen_rev_bdgt_amt_res_sch_wrp:'||x_return_status,
                  p_module_name => l_module_name,
                  p_log_level   => 5);
            END IF;
    ELSE
            /* Calling Resource Schedule API */
            IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                  (p_called_mode => p_called_mode,
                   p_msg         => 'Before calling
                   pa_fp_gen_budget_amt_pub.generate_budget_amt_res_sch',
                   p_module_name => l_module_name,
                   p_log_level   => 5);
            END IF;
            --hr_utility.trace('before PA_FP_GEN_BUDGET_AMT_PUB.GENERATE_BUDGET_AMT_RES_SCH');
            PA_FP_GEN_BUDGET_AMT_PUB.GENERATE_BUDGET_AMT_RES_SCH
               (P_PROJECT_ID               => P_PROJECT_ID,
            P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
                P_FP_COLS_REC              => l_fp_cols_rec,
            P_PLAN_CLASS_CODE          => l_fp_cols_rec.x_plan_class_code,
            P_GEN_SRC_CODE             => l_fp_cols_rec.x_gen_src_code,
            P_COST_PLAN_TYPE_ID        => l_fp_cols_rec.x_gen_src_plan_type_id,
        p_COST_VERSION_ID          => l_cost_version_id,
        P_RETAIN_MANUAL_FLAG       => l_fp_cols_rec.x_gen_ret_manual_line_flag,
        P_CALLED_MODE              => 'SELF_SERVICE',
        P_INC_CHG_DOC_FLAG         => l_fp_cols_rec.x_gen_incl_change_doc_flag,
        P_INC_BILL_EVENT_FLAG      => l_fp_cols_rec.x_gen_incl_bill_event_flag,
            P_INC_OPEN_COMMIT_FLAG     => l_fp_cols_rec.x_gen_incl_open_comm_flag,
            P_CI_ID_TAB                => l_ci_id_tab,
            PX_GEN_RES_ASG_ID_TAB      => l_gen_res_asg_id_tab,
            PX_DELETED_RES_ASG_ID_TAB  => l_deleted_res_asg_id_tab,
            P_COMMIT_FLAG              => P_COMMIT_FLAG,
            P_INIT_MSG_FLAG            => P_INIT_MSG_FLAG,
            X_RETURN_STATUS            => X_RETURN_STATUS,
            X_MSG_COUNT                => X_MSG_COUNT,
            X_MSG_DATA             => X_MSG_DATA);
            --dbms_output.put_line('after PA_FP_GEN_BUDGET_AMT_PUB.GENERATE_BUDGET_AMT_RES_SCH:'||x_return_status);
            IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
            IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                  (p_called_mode => p_called_mode,
                   p_msg         => 'Status after calling
                   pa_fp_gen_budget_amt_pub.generate_budget_amt_res_sch: '
                                ||x_return_status,
                   p_module_name => l_module_name,
                   p_log_level   => 5);
            END IF;
    END IF;
   ELSIF  l_fp_cols_rec.x_gen_src_code = 'WORKPLAN_RESOURCES'
    OR l_fp_cols_rec.x_gen_src_code = 'FINANCIAL_PLAN'  THEN
        /* Calling Work Plan API */
       l_wp_track_cost_flag := Pa_Fp_wp_gen_amt_utils.get_wp_track_cost_amt_flag (p_project_id);
       IF l_fp_cols_rec.x_version_type = 'REVENUE'
       AND l_rev_gen_method = 'C'
       AND l_wp_track_cost_flag <> 'Y' THEN
          IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_called_mode => p_called_mode,
              p_msg         => 'Before calling
              pa_fp_wp_gen_budget_amt_pub.generate_wp_budget_amt',
              p_module_name => l_module_name,
              p_log_level   => 5);
          END IF;
          PA_FP_GEN_BUDGET_AMT_PUB.GEN_WP_REV_BDGT_AMT_WRP
            (P_PROJECT_ID              => P_PROJECT_ID,
            P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
            P_PLAN_CLASS_CODE          => l_fp_cols_rec.x_plan_class_code,
            P_GEN_SRC_CODE             => l_fp_cols_rec.x_gen_src_code,
            P_COST_PLAN_TYPE_ID        => l_fp_cols_rec.x_gen_src_plan_type_id,
        P_COST_VERSION_ID          => l_cost_version_id,
        P_RETAIN_MANUAL_FLAG       => l_fp_cols_rec.x_gen_ret_manual_line_flag,
        P_CALLED_MODE              => 'SELF_SERVICE',
        P_INC_CHG_DOC_FLAG         => l_fp_cols_rec.x_gen_incl_change_doc_flag,
        P_INC_BILL_EVENT_FLAG      => l_fp_cols_rec.x_gen_incl_bill_event_flag,
            P_INC_OPEN_COMMIT_FLAG     => l_fp_cols_rec.x_gen_incl_open_comm_flag,
            P_CI_ID_TAB                => l_ci_id_tab,
            PX_GEN_RES_ASG_ID_TAB      => l_gen_res_asg_id_tab,
            PX_DELETED_RES_ASG_ID_TAB  => l_deleted_res_asg_id_tab,
            P_INIT_MSG_FLAG            => P_INIT_MSG_FLAG,
            P_COMMIT_FLAG              => P_COMMIT_FLAG,
            X_RETURN_STATUS            => X_RETURN_STATUS,
            X_MSG_COUNT                => X_MSG_COUNT,
            X_MSG_DATA             => X_MSG_DATA);
          IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;
          IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_called_mode => p_called_mode,
              p_msg         => 'Status after calling
                              pa_fp_wp_gen_budget_amt_pub.generate_wp_budget_amt: '
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
          END IF;
       ELSE
         IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_called_mode => p_called_mode,
              p_msg         => 'Before calling
              pa_fp_wp_gen_budget_amt_pub.generate_wp_budget_amt',
              p_module_name => l_module_name,
              p_log_level   => 5);
          END IF;
          PA_FP_WP_GEN_BUDGET_AMT_PUB.GENERATE_WP_BUDGET_AMT
            (P_PROJECT_ID              => P_PROJECT_ID,
            P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
            P_PLAN_CLASS_CODE          => l_fp_cols_rec.x_plan_class_code,
            P_GEN_SRC_CODE             => l_fp_cols_rec.x_gen_src_code,
            P_COST_PLAN_TYPE_ID        => l_fp_cols_rec.x_gen_src_plan_type_id,
        P_COST_VERSION_ID          => l_cost_version_id,
        P_RETAIN_MANUAL_FLAG       => l_fp_cols_rec.x_gen_ret_manual_line_flag,
        P_CALLED_MODE              => 'SELF_SERVICE',
        P_INC_CHG_DOC_FLAG         => l_fp_cols_rec.x_gen_incl_change_doc_flag,
        P_INC_BILL_EVENT_FLAG      => l_fp_cols_rec.x_gen_incl_bill_event_flag,
            P_INC_OPEN_COMMIT_FLAG     => l_fp_cols_rec.x_gen_incl_open_comm_flag,
            P_CI_ID_TAB                => l_ci_id_tab,
            PX_GEN_RES_ASG_ID_TAB      => l_gen_res_asg_id_tab,
            PX_DELETED_RES_ASG_ID_TAB  => l_deleted_res_asg_id_tab,
            P_INIT_MSG_FLAG            => P_INIT_MSG_FLAG,
            P_COMMIT_FLAG              => P_COMMIT_FLAG,
            X_RETURN_STATUS            => X_RETURN_STATUS,
            X_MSG_COUNT                => X_MSG_COUNT,
            X_MSG_DATA             => X_MSG_DATA);

          IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;
          IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_called_mode => p_called_mode,
              p_msg         => 'Status after calling
                              pa_fp_wp_gen_budget_amt_pub.generate_wp_budget_amt: '
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
          END IF;
       END IF;
   END IF;

   IF l_fp_cols_rec.x_gen_incl_open_comm_flag = 'Y' THEN
      /* Calling Commitment API*/
       IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_called_mode => p_called_mode,
              p_msg         => 'Before calling
              pa_fp_gen_commitment_amounts.gen_commitment_amounts',
              p_module_name => l_module_name,
              p_log_level   => 5);
       END IF;
        PA_FP_GEN_COMMITMENT_AMOUNTS.GEN_COMMITMENT_AMOUNTS
               (P_PROJECT_ID                 => P_PROJECT_ID,
                P_BUDGET_VERSION_ID          => P_BUDGET_VERSION_ID,
                P_FP_COLS_REC                => l_fp_cols_rec,
                PX_GEN_RES_ASG_ID_TAB        => l_gen_res_asg_id_tab,
                PX_DELETED_RES_ASG_ID_TAB    => l_deleted_res_asg_id_tab,
                X_RETURN_STATUS              => X_RETURN_STATUS,
                X_MSG_COUNT                  => X_MSG_COUNT,
                X_MSG_DATA               => X_MSG_DATA);

       IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;
     IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_called_mode => p_called_mode,
              p_msg         =>'Status after calling
              pa_fp_gen_commitment_amounts.gen_commitment_amounts: '
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
      END IF;
   END IF;

    IF l_fp_cols_rec.x_gen_src_plan_version_id IS NOT NULL THEN
            l_source_bv_id := l_fp_cols_rec.x_gen_src_plan_version_id;
    ELSE
        SELECT
        DECODE(bv.version_type,
               'COST', opt.gen_src_cost_plan_version_id,
               'REVENUE',opt.gen_src_rev_plan_version_id,
               'ALL',opt.gen_src_all_plan_version_id)
        INTO    l_source_bv_id
        FROM    pa_proj_fp_options opt, pa_budget_versions bv
        WHERE   bv.budget_version_id = opt.fin_plan_version_id
        AND     bv.budget_version_id = p_budget_version_id ;
    END IF;

     IF   (l_fp_cols_rec.x_version_type = 'ALL'
             OR l_fp_cols_rec.x_version_type = 'REVENUE')
             AND l_rev_gen_method = 'C'   THEN

       -- Bug 4549862: When generating a Cost and Revenue together version
       -- from Staffing Plan with revenue accrual method of COST, the
       -- currency conversion step is performed on the PA_FP_ROLLUP_TMP
       -- table (instead of pa_budget_lines) earlier in the code flow by the
       -- GENERATE_BUDGET_AMT_RES_SCH API so that pc/pfc Commitment amounts
       -- can be honored. We should not call the currency conversion API in
       -- this case.

       IF l_fp_cols_rec.x_version_type = 'ALL' AND
          l_fp_cols_rec.x_gen_src_code <> 'RESOURCE_SCHEDULE' THEN
              /* Calling the currency conversion API*/
              IF p_pa_debug_mode = 'Y' THEN
                   pa_fp_gen_amount_utils.fp_debug
                  (p_called_mode => p_called_mode,
                   p_msg         => 'Before calling
                   pa_fp_multi_currency_pkg.convert_txn_currency',
                   p_module_name => l_module_name,
                   p_log_level   => 5);
              END IF;
              PA_FP_MULTI_CURRENCY_PKG.CONVERT_TXN_CURRENCY
                 (p_budget_version_id          => P_BUDGET_VERSION_ID,
                  p_entire_version             => 'Y',
                  p_calling_module              => 'BUDGET_GENERATION', -- Added for Bug#5395732
                  X_RETURN_STATUS              => X_RETURN_STATUS,
                  X_MSG_COUNT                  => X_MSG_COUNT,
                  X_MSG_DATA                   => X_MSG_DATA);
              IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
              END IF;
              IF p_pa_debug_mode = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                   (p_called_mode => p_called_mode,
                    p_msg         => 'Status after calling
                    pa_fp_multi_currency_pkg.convert_txn_currency: '
                              ||x_return_status,
                    p_module_name => l_module_name,
                    p_log_level   => 5);
              END IF;
       END IF;

       -- Bug 4549862: Removed ROLLUP_BUDGET_VERSION API call that used
       -- to be before the GEN_COST_BASED_REVENUE API call. The same API
       -- call is commented out in GENERATE_FCST_AMT_WRP. The Rollup API
       -- is called at the end of the generation process in the Maintain
       -- Budget Version API already. The Cost Based Revenue Generation
       -- API may have used rolled up amounts in the past, but does not
       -- currently use them. Lastly, the Change Documents process uses
       -- rolled up amounts, but the Change Document wrapper API takes
       -- care of this already.

    /* Calling gen cost based revenue api */
        IF p_pa_debug_mode = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
                 (p_called_mode => p_called_mode,
                  p_msg         => 'Before calling
                         pa_fp_rev_gen_pub.gen_cost_based_revenue',
                  p_module_name => l_module_name,
                  p_log_level   => 5);
        END IF;
        PA_FP_REV_GEN_PUB.GEN_COST_BASED_REVENUE
                    (P_BUDGET_VERSION_ID          => P_BUDGET_VERSION_ID,
                     P_FP_COLS_REC                => l_fp_cols_rec,
                     X_RETURN_STATUS              => X_RETURN_STATUS,
                     X_MSG_COUNT                  => X_MSG_COUNT,
                     X_MSG_DATA                   => X_MSG_DATA);
        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                (p_called_mode => p_called_mode,
                 p_msg         => 'Status after calling
                   pa_fp_rev_gen_pub.gen_cost_based_revenue: '
                   ||x_return_status,
                 p_module_name => l_module_name,
                 p_log_level   => 5);
        END IF;
     END IF;

     /* Calling include_change_document_wrp api */
       IF l_fp_cols_rec.x_gen_incl_change_doc_flag = 'Y' THEN
          IF l_fp_cols_rec.x_gen_src_code = 'FINANCIAL_PLAN' THEN
              IF p_pa_debug_mode = 'Y' THEN
                 pa_fp_gen_amount_utils.fp_debug
                  (p_called_mode => p_called_mode,
                   p_msg         => 'Before calling
                               pa_fp_ci_merge.copy_merged_ctrl_items',
                   p_module_name => l_module_name,
                   p_log_level   => 5);
              END IF;
              PA_FP_CI_MERGE.copy_merged_ctrl_items
               (p_project_id        => p_project_id
               ,p_source_version_id => l_source_bv_id
               ,p_target_version_id => l_fp_cols_rec.x_budget_version_id
               ,p_calling_context   => 'GENERATION' --Bug 4247703
               ,x_return_status     => x_return_status
               ,x_msg_count         => x_msg_count
               ,x_msg_data          => x_msg_data);
                IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
               END IF;
               IF p_pa_debug_mode = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                    (p_called_mode => p_called_mode,
                     p_msg         => 'Status after calling
                            pa_fp_ci_merge.copy_merged_ctrl_items: '
                              ||x_return_status,
                     p_module_name => l_module_name,
                     p_log_level   => 5);
               END IF;
          END IF;

          IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_called_mode => p_called_mode,
              p_msg         => 'Before calling PA_FP_GEN_PUB.include_change_document_wrp',
              p_module_name => l_module_name,
              p_log_level   => 5);
          END IF;
          --dbms_output.put_line('before chg_doc');
          PA_FP_GEN_PUB.INCLUDE_CHANGE_DOCUMENT_WRP
          (P_FP_COLS_REC   => l_fp_cols_rec,
           X_RETURN_STATUS => X_RETURN_STATUS,
           X_MSG_COUNT     => X_MSG_COUNT,
           X_MSG_DATA      => X_MSG_DATA);
          --dbms_output.put_line('after chg_doc:'||x_return_status);
          IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;
          IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_called_mode => p_called_mode,
              p_msg         => 'Status after calling PA_FP_GEN_PUB.include_change_document_wrp: '
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
          END IF;
      END IF;

     /*Only for ALL or Revenue version, revenue generation method can be set
       and include billing event flag can be chosen. This logic is implemented
       in both here and UI*/
     IF (l_fp_cols_rec.x_version_type = 'ALL'
         OR l_fp_cols_rec.x_version_type = 'REVENUE')
         AND (l_rev_gen_method = 'E'
         OR l_fp_cols_rec.x_gen_incl_bill_event_flag = 'Y') THEN
          /* Calling Billing Events API */
             IF p_pa_debug_mode = 'Y' THEN
                     pa_fp_gen_amount_utils.fp_debug
                       (p_called_mode => p_called_mode,
                        p_msg         => 'Before calling
                        pa_fp_gen_billing_amounts.gen_billing_amounts',
                        p_module_name => l_module_name,
                        p_log_level   => 5);
            END IF;
            PA_FP_GEN_BILLING_AMOUNTS.GEN_BILLING_AMOUNTS
             (P_PROJECT_ID                 => P_PROJECT_ID,
              P_BUDGET_VERSION_ID          => P_BUDGET_VERSION_ID,
              P_FP_COLS_REC                => l_fp_cols_rec,
              PX_GEN_RES_ASG_ID_TAB        => l_gen_res_asg_id_tab,
              PX_DELETED_RES_ASG_ID_TAB    => l_deleted_res_asg_id_tab,
              X_RETURN_STATUS              => X_RETURN_STATUS,
              X_MSG_COUNT                  => X_MSG_COUNT,
              X_MSG_DATA               => X_MSG_DATA);

            IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
            IF p_pa_debug_mode = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
                   (p_called_mode => p_called_mode,
                    p_msg         => 'Status after calling
                              pa_fp_gen_billing_amounts.gen_billing_amounts: '
                              ||x_return_status,
                    p_module_name => l_module_name,
                    p_log_level   => 5);
             END IF;
    END IF;

    IF l_fp_cols_rec.x_version_type = 'REVENUE' THEN
                  IF p_pa_debug_mode = 'Y' THEN
                     pa_fp_gen_amount_utils.fp_debug
                       (p_called_mode => p_called_mode,
                        p_msg         => 'Before calling
                        pa_fp_gen_budget_amt_pub.reset_cost_amounts',
                        p_module_name => l_module_name,
                        p_log_level   => 5);
                  END IF;
          PA_FP_GEN_BUDGET_AMT_PUB.RESET_COST_AMOUNTS
          (P_BUDGET_VERSION_ID  => P_BUDGET_VERSION_ID,
           X_RETURN_STATUS      => X_RETURN_STATUS,
           X_MSG_COUNT          => X_MSG_COUNT,
           X_MSG_DATA           => X_MSG_DATA);

          IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;
          IF p_pa_debug_mode = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
                   (p_called_mode => p_called_mode,
                    p_msg         => 'Status after calling
                              pa_fp_gen_budget_amt_pub.reset_cost_amounts: '
                              ||x_return_status,
                    p_module_name => l_module_name,
                    p_log_level   => 5);
          END IF;
    END IF;
    IF p_pa_debug_mode = 'Y' THEN
         pa_fp_gen_amount_utils.fp_debug
            (p_called_mode => p_called_mode,
             p_msg         => 'Before calling
             pa_fp_gen_fcst_amt_pub1.maintain_budget_version',
             p_module_name => l_module_name,
             p_log_level   => 5);
    END IF;
    --hr_utility.trace('before pub1.maintain bv');
    PA_FP_GEN_FCST_AMT_PUB1.MAINTAIN_BUDGET_VERSION
               (P_PROJECT_ID        => P_PROJECT_ID,
                P_BUDGET_VERSION_ID => P_BUDGET_VERSION_ID,
                X_RETURN_STATUS      => X_RETURN_STATUS,
                X_MSG_COUNT          => X_MSG_COUNT,
                X_MSG_DATA          => X_MSG_DATA);
              --hr_utility.trace('after pub1.maintain bv:'||x_return_status);
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;
    IF p_pa_debug_mode = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
           (p_called_mode => p_called_mode,
            p_msg         => 'Status after calling
                  pa_fp_gen_fcst_amt_pub1.maintain_budget_version: '
                  ||x_return_status,
            p_module_name => l_module_name,
            p_log_level   => 5);
    END IF;

    IF P_COMMIT_FLAG = 'Y' THEN
        COMMIT;
    END IF;

    IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
          PA_DEBUG.reset_err_stack;
    ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
          PA_DEBUG.Reset_Curr_Function;
    END IF;

  EXCEPTION
   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
   -- Bug Fix: 4569365. Removed MRC code.
      -- PA_MRC_FINPLAN.G_CALLING_MODULE := Null;
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
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
          PA_DEBUG.reset_err_stack;
      ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
          PA_DEBUG.Reset_Curr_Function;
      END IF;

  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      := SUBSTR(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_BUDGET_AMT_PUB'
              ,p_procedure_name => 'GENERATE_BUDGET_AMT_WRP');

     IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
         PA_DEBUG.reset_err_stack;
     ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
         PA_DEBUG.Reset_Curr_Function;
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GENERATE_BUDGET_AMT_WRP;

FUNCTION Get_Person_Id(p_res_id NUMBER)
     RETURN NUMBER IS
    x_person_id NUMBER;

  BEGIN
    SELECT person_id INTO x_person_id FROM
    PA_RESOURCE_TXN_ATTRIBUTES WHERE
    RESOURCE_ID = p_res_id;
    RETURN x_person_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
         RETURN NULL;
    WHEN OTHERS THEN
         RETURN NULL;
  END;

  PROCEDURE UPDATE_BUDG_VERSION(p_budget_version_id IN NUMBER ) IS
  BEGIN
      UPDATE PA_BUDGET_VERSIONS SET PLAN_PROCESSING_CODE = 'E'
      WHERE  BUDGET_VERSION_ID = p_budget_version_id;
    COMMIT;
  END;

/* Procedure to generate budget amount when
   planning level is Resource Schedule */
PROCEDURE  GENERATE_BUDGET_AMT_RES_SCH
          (P_PROJECT_ID                IN      PA_PROJECTS_ALL.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID         IN      PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC               IN      PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_PLAN_CLASS_CODE           IN      PA_FIN_PLAN_TYPES_B.PLAN_CLASS_CODE%TYPE,
           P_GEN_SRC_CODE              IN      PA_PROJ_FP_OPTIONS.GEN_ALL_SRC_CODE%TYPE,
           P_COST_PLAN_TYPE_ID         IN      PA_PROJ_FP_OPTIONS.GEN_SRC_COST_PLAN_TYPE_ID%TYPE,
           P_COST_VERSION_ID           IN      PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_RETAIN_MANUAL_FLAG        IN      PA_PROJ_FP_OPTIONS.GEN_COST_RET_MANUAL_LINE_FLAG%TYPE,
           P_CALLED_MODE               IN      VARCHAR2,
           P_INC_CHG_DOC_FLAG          IN      PA_PROJ_FP_OPTIONS.GEN_COST_INCL_CHANGE_DOC_FLAG%TYPE,
           P_INC_BILL_EVENT_FLAG       IN      PA_PROJ_FP_OPTIONS.GEN_REV_INCL_BILL_EVENT_FLAG%TYPE,
           P_INC_OPEN_COMMIT_FLAG      IN      PA_PROJ_FP_OPTIONS.GEN_COST_INCL_OPEN_COMM_FLAG%TYPE,
           P_ACTUALS_THRU_DATE         IN      PA_PERIODS_ALL.END_DATE%TYPE,
           P_CI_ID_TAB                 IN      PA_PLSQL_DATATYPES.IdTabTyp,
           PX_GEN_RES_ASG_ID_TAB       IN OUT  NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
           --this pl/sql table is used to update the initial res_asg_id from the generated amounts
           PX_DELETED_RES_ASG_ID_TAB   IN OUT  NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
           --this pl/sql table will have res_asg_id for which manual budget lines are already deleted
           P_COMMIT_FLAG               IN   VARCHAR2,
           P_INIT_MSG_FLAG             IN   VARCHAR2,
           X_RETURN_STATUS             OUT  NOCOPY   VARCHAR2,
           X_MSG_COUNT                 OUT  NOCOPY   NUMBER,
           X_MSG_DATA                  OUT  NOCOPY   VARCHAR2) IS

l_module_name         VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_BUDGET_AMT_PUB.GENERATE_BUDGET_AMT_RES_SCH';

l_budget_line_id PA_BUDGET_LINES.BUDGET_LINE_ID%type;

   CURSOR PROJ_DETAILS IS
   SELECT P.PROJECT_TYPE,
          P.PROJECT_CURRENCY_CODE,
          P.CARRYING_OUT_ORGANIZATION_ID,
          P.PROJECT_VALUE,
          P.JOB_BILL_RATE_SCHEDULE_ID,
          P.EMP_BILL_RATE_SCHEDULE_ID,
          P.DISTRIBUTION_RULE,
          P.BILL_JOB_GROUP_ID,
          NVL(P.ORG_ID,-99),
          P.COMPLETION_DATE,
          NVL(P.TEMPLATE_FLAG,'N'),
          P.PROJFUNC_CURRENCY_CODE,
          P.PROJFUNC_BIL_RATE_DATE_CODE,
          P.PROJFUNC_BIL_RATE_TYPE,
          P.PROJFUNC_BIL_RATE_DATE,
          P.PROJFUNC_BIL_EXCHANGE_RATE,
          P.COST_JOB_GROUP_ID,
          P.PROJECT_RATE_DATE,
          P.PROJECT_RATE_TYPE,
          P.PROJECT_BIL_RATE_DATE_CODE,
          P.PROJECT_BIL_RATE_TYPE,
          P.PROJECT_BIL_RATE_DATE,
          P.PROJECT_BIL_EXCHANGE_RATE,
          P.PROJFUNC_COST_RATE_TYPE,
          P.PROJFUNC_COST_RATE_DATE,
          P.LABOR_TP_SCHEDULE_ID,
          P.LABOR_TP_FIXED_DATE,
          P.LABOR_SCHEDULE_DISCOUNT,
          NVL(P.ASSIGN_PRECEDES_TASK,'N'),
          NVL(P.LABOR_BILL_RATE_ORG_ID,-99),
          P.LABOR_STD_BILL_RATE_SCHDL,
          P.LABOR_SCHEDULE_FIXED_DATE,
          P.LABOR_SCH_TYPE
   FROM   PA_PROJECTS_ALL P
   WHERE  PROJECT_ID = P_PROJECT_ID;

   CURSOR PROJ_ASSIGNMENTS IS
   SELECT DISTINCT PA.ASSIGNMENT_ID,
          PA.START_DATE,
          PA.RESOURCE_ID,
          PA.PROJECT_ROLE_ID,
          PA.FCST_JOB_ID,
          PA.FCST_JOB_GROUP_ID,
          PR.MEANING,
          PA.ASSIGNMENT_TYPE ,
          NVL(PA.EXPENDITURE_ORGANIZATION_ID,
          NVL(p.CARRYING_OUT_ORGANIZATION_ID,-99))
          EXPENDITURE_ORGANIZATION_ID,
          PA.EXPENDITURE_TYPE,
          PA.REVENUE_BILL_RATE,
          NVL(PA.EXPENDITURE_ORG_ID,
          NVL(p.ORG_ID,-99)) EXPENDITURE_ORG_ID,
          PA.STATUS_CODE,
          WB.BILLABLE_CAPITALIZABLE_FLAG,
          'Y' PROCESS_CODE,
      to_char(null) ERROR_MSG_CODE,
          PA.END_DATE,
          RTA.PERSON_ID,
          PA.ASSIGNMENT_NAME,
          FI.EXPENDITURE_ORGANIZATION_ID,
          DECODE(PA.EXPENDITURE_TYPE,null,NULL,'EXPENDITURE_TYPE')
   FROM   PA_PROJECT_ASSIGNMENTS PA,
          PA_WORK_TYPES_B WB,
          PA_PROJECT_ROLE_TYPES PR,
          PA_PROJECTS_ALL P,
          PA_RESOURCE_TXN_ATTRIBUTES RTA,
      PA_FORECAST_ITEMS FI
   WHERE  PA.PROJECT_ID = p_project_id
   AND    PA.PROJECT_ROLE_ID = PR.PROJECT_ROLE_ID
   AND    P.PROJECT_ID = p_project_id
   AND    WB.WORK_TYPE_ID = PA.WORK_TYPE_ID(+)
   AND    PA.RESOURCE_ID  = RTA.RESOURCE_ID(+)
   AND    DECODE(PA.STATUS_CODE,NULL,'Y',
          DECODE(PA.ASSIGNMENT_TYPE,
                 'OPEN_ASSIGNMENT',
                  PA_ASSIGNMENT_UTILS.Is_Asgmt_In_Open_Status(PA.STATUS_CODE,'OPEN_ASGMT'),
                 'STAFFED_ASSIGNMENT',
                  DECODE(PA_ASSIGNMENT_UTILS.Is_Staffed_Asgmt_Cancelled(PA.STATUS_CODE,'STAFFED_ASGMT'),
                         'Y','N','N','Y'),
                  'STAFFED_ADMIN_ASSIGNMENT',
                   DECODE(PA_ASSIGNMENT_UTILS.Is_Staffed_Asgmt_Cancelled(PA.STATUS_CODE,'STAFFED_ASGMT'),
                          'Y','N','N','Y'))) = 'Y'
   AND    PA.ASSIGNMENT_ID = FI.ASSIGNMENT_ID
   AND    FI.DELETE_FLAG = 'N'  -- Added for Bug 5029939
   AND    FI.ERROR_FLAG  = 'N'; -- Added for Bug 5029939

   /* Bug 5657334: Added org_id join in pa_periods_all to avoid multiple row selection */
   CURSOR  FCST_PA(p_prj_assignment_id NUMBER, c_act_thru_date DATE, c_exp_organization_id NUMBER, c_org_id NUMBER) IS
   SELECT  FI.EXPENDITURE_ORG_ID,
           FI.EXPENDITURE_ORGANIZATION_ID,
           FI.RCVR_PA_PERIOD_NAME,
           P.START_DATE,
           P.END_DATE,
           SUM(FI.ITEM_QUANTITY),
           MIN(FI.FORECAST_ITEM_ID)
   FROM    PA_FORECAST_ITEMS FI,
           PA_FORECAST_ITEM_DETAILS FID,
           PA_PERIODS_ALL P
   WHERE   FI.PROJECT_ORG_ID            = NVL(P.ORG_ID,-99)
   AND     P.ORG_ID                     = c_org_id               /* Bug 5657334 */
   AND     P.PERIOD_NAME                = FI.RCVR_PA_PERIOD_NAME
   AND     FI.FORECAST_ITEM_ID          = FID.FORECAST_ITEM_ID
   AND     FID.FORECAST_SUMMARIZED_CODE = 'N'
   AND     FID.NET_ZERO_FLAG            = 'N'
   AND     FI.ERROR_FLAG                = 'N'
   AND     FI.DELETE_FLAG               = 'N'
   AND     ASSIGNMENT_ID                = p_prj_assignment_id
   AND     FI.EXPENDITURE_ORG_ID        <>-88
   AND     FI.ITEM_DATE                 >= NVL(c_act_thru_date+1,FI.ITEM_DATE)
   AND     FI.EXPENDITURE_ORGANIZATION_ID = c_exp_organization_id
   GROUP BY FI.EXPENDITURE_ORG_ID,
            FI.EXPENDITURE_ORGANIZATION_ID,
            P.START_DATE,
            P.END_DATE,
            FI.RCVR_PA_PERIOD_NAME;

   CURSOR FCST_GL(p_prj_assignment_id NUMBER, c_act_thru_date DATE, c_exp_organization_id NUMBER)  IS
   SELECT FI.EXPENDITURE_ORG_ID,
          FI.EXPENDITURE_ORGANIZATION_ID,
          FI.RCVR_GL_PERIOD_NAME,
          GLP.START_DATE,
          GLP.END_DATE,
          SUM(FI.ITEM_QUANTITY),
          MIN(FI.FORECAST_ITEM_ID)
   FROM   PA_FORECAST_ITEMS FI,
          PA_FORECAST_ITEM_DETAILS FID,
          GL_PERIODS GLP
  WHERE   FI.FORECAST_ITEM_ID = FID.FORECAST_ITEM_ID
  AND     FID.FORECAST_SUMMARIZED_CODE = 'N'
  AND     FID.NET_ZERO_FLAG            = 'N'
  AND     FI.ERROR_FLAG                = 'N'
  AND     FI.DELETE_FLAG               = 'N'
  AND     GLP.PERIOD_SET_NAME          = FI.RCVR_PERIOD_SET_NAME
  AND     GLP.PERIOD_NAME              = FI.RCVR_GL_PERIOD_NAME
  AND     ASSIGNMENT_ID                = p_prj_assignment_id
  AND     FI.EXPENDITURE_ORG_ID        <> -88
  AND     FI.ITEM_DATE                 >= NVL(c_act_thru_date+1,FI.ITEM_DATE)
  AND     FI.EXPENDITURE_ORGANIZATION_ID = c_exp_organization_id
  GROUP BY FI.EXPENDITURE_ORG_ID,
           FI.EXPENDITURE_ORGANIZATION_ID,
           GLP.START_DATE,
           GLP.END_DATE,
           FI.RCVR_GL_PERIOD_NAME;

   CURSOR FCST_NONE(p_prj_assignment_id NUMBER, c_act_thru_date DATE, c_exp_organization_id NUMBER)  IS
   SELECT FI.EXPENDITURE_ORG_ID,
          FI.EXPENDITURE_ORGANIZATION_ID,
          SUM(FI.ITEM_QUANTITY),
          MIN(FI.FORECAST_ITEM_ID),
          null period_name,
          min(fi.item_Date) start_date,
          max(fi.item_Date) end_date      -- Bug 4549862: Changed min to max.
   FROM   PA_FORECAST_ITEMS FI,
          PA_FORECAST_ITEM_DETAILS FID
   WHERE   FI.FORECAST_ITEM_ID = FID.FORECAST_ITEM_ID
   AND     FID.FORECAST_SUMMARIZED_CODE = 'N'
   AND     FID.NET_ZERO_FLAG            = 'N'
   AND     FI.ERROR_FLAG                = 'N'
   AND     FI.DELETE_FLAG               = 'N'
   AND     ASSIGNMENT_ID                = p_prj_assignment_id
   AND     FI.EXPENDITURE_ORG_ID        <> -88
   AND     FI.ITEM_DATE                 >= NVL(c_act_thru_date+1,FI.ITEM_DATE)
   AND     FI.EXPENDITURE_ORGANIZATION_ID = c_exp_organization_id
   GROUP BY   FI.EXPENDITURE_ORG_ID,
              FI.EXPENDITURE_ORGANIZATION_ID;

   CURSOR   BUDGET_LINES(c_budget_version_id       PA_RESOURCE_ASSIGNMENTS.BUDGET_VERSION_ID%TYPE,
                         c_project_id              PA_RESOURCE_ASSIGNMENTS.PROJECT_ID%TYPE,
                         c_resource_assignment_id  PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE) IS
   SELECT   BL.PERIOD_NAME,
            BL.START_DATE,
            BL.BURDENED_COST
   FROM     PA_BUDGET_LINES BL,
            PA_RESOURCE_ASSIGNMENTS RA
   WHERE    BL.RESOURCE_ASSIGNMENT_ID = RA.RESOURCE_ASSIGNMENT_ID
   AND      RA.BUDGET_VERSION_ID = c_budget_version_id
   AND      RA.PROJECT_ID = c_project_id
   AND      RA.RESOURCE_LIST_MEMBER_ID = 103
   ORDER BY BL.START_DATE;

   -- M-Closeout: Bill Rate Override ER ------------------------------------------
   --   Also query up the rate API parameters per period

   /* Bug 5657334: Added org_id join in pa_periods_all to avoid multiple row selection */
   CURSOR  FCST_RATE_PA(p_prj_assignment_id NUMBER, c_act_thru_date DATE, c_exp_organization_id NUMBER, c_org_id NUMBER) IS
   SELECT  FI.EXPENDITURE_ORG_ID,
           FI.EXPENDITURE_ORGANIZATION_ID,
           FI.RCVR_PA_PERIOD_NAME,
           P.START_DATE,
           P.END_DATE,
           SUM(FI.ITEM_QUANTITY),
           MIN(FI.FORECAST_ITEM_ID),
           RA.RESOURCE_ASSIGNMENT_ID,
           RA.UNIT_OF_MEASURE,
           RA.RESOURCE_CLASS_CODE,
           RA.ORGANIZATION_ID,
           RA.JOB_ID,
           RA.PERSON_ID,
           RA.EXPENDITURE_TYPE,
           RA.NON_LABOR_RESOURCE,
           RA.BOM_RESOURCE_ID,
           RA.INVENTORY_ITEM_ID,
           RA.ITEM_CATEGORY_ID,
           RA.MFC_COST_TYPE_ID,
           RA.RATE_EXPENDITURE_TYPE,
           NVL(RA.RATE_BASED_FLAG, 'N') RATE_BASED_FLAG,
           RA.RATE_EXPENDITURE_ORG_ID,
           RLM.RES_FORMAT_ID,
           RLM.RESOURCE_LIST_MEMBER_ID,
           RLM.RESOURCE_ID,
           RLM.RESOURCE_LIST_ID,
           RLM.ALIAS
   FROM    PA_FORECAST_ITEMS FI,
           PA_FORECAST_ITEM_DETAILS FID,
           PA_PERIODS_ALL P,
           PA_RES_LIST_MAP_TMP4 TMP4,
           PA_RESOURCE_ASSIGNMENTS RA,
           PA_RESOURCE_LIST_MEMBERS RLM
   WHERE   FI.PROJECT_ORG_ID            = NVL(P.ORG_ID,-99)
   AND     P.ORG_ID                     = c_org_id               /* Bug 5657334 */
   AND     P.PERIOD_NAME                = FI.RCVR_PA_PERIOD_NAME
   AND     FI.FORECAST_ITEM_ID          = FID.FORECAST_ITEM_ID
   AND     FID.FORECAST_SUMMARIZED_CODE = 'N'
   AND     FID.NET_ZERO_FLAG            = 'N'
   AND     FI.ERROR_FLAG                = 'N'
   AND     FI.DELETE_FLAG               = 'N'
   AND     ASSIGNMENT_ID                = p_prj_assignment_id
   AND     FI.EXPENDITURE_ORG_ID        <>-88
   AND     FI.ITEM_DATE                 >= NVL(c_act_thru_date+1,FI.ITEM_DATE)
   AND     FI.EXPENDITURE_ORGANIZATION_ID = c_exp_organization_id
   AND     ASSIGNMENT_ID                = TMP4.TXN_SOURCE_ID
   AND     RA.RESOURCE_ASSIGNMENT_ID    = TMP4.TXN_RESOURCE_ASSIGNMENT_ID
   AND     RA.RESOURCE_LIST_MEMBER_ID   = RLM.RESOURCE_LIST_MEMBER_ID
   GROUP BY FI.EXPENDITURE_ORG_ID,
            FI.EXPENDITURE_ORGANIZATION_ID,
            P.START_DATE,
            P.END_DATE,
            FI.RCVR_PA_PERIOD_NAME,
            RA.RESOURCE_ASSIGNMENT_ID,
            RA.UNIT_OF_MEASURE,
            RA.RESOURCE_CLASS_CODE,
            RA.ORGANIZATION_ID,
            RA.JOB_ID,
            RA.PERSON_ID,
            RA.EXPENDITURE_TYPE,
            RA.NON_LABOR_RESOURCE,
            RA.BOM_RESOURCE_ID,
            RA.INVENTORY_ITEM_ID,
            RA.ITEM_CATEGORY_ID,
            RA.MFC_COST_TYPE_ID,
            RA.RATE_EXPENDITURE_TYPE,
            RA.RATE_BASED_FLAG,
            RA.RATE_EXPENDITURE_ORG_ID,
            RLM.RES_FORMAT_ID,
            RLM.RESOURCE_LIST_MEMBER_ID,
            RLM.RESOURCE_ID,
            RLM.RESOURCE_LIST_ID,
            RLM.ALIAS;

   CURSOR FCST_RATE_GL(p_prj_assignment_id NUMBER, c_act_thru_date DATE, c_exp_organization_id NUMBER)  IS
   SELECT FI.EXPENDITURE_ORG_ID,
          FI.EXPENDITURE_ORGANIZATION_ID,
          FI.RCVR_GL_PERIOD_NAME,
          GLP.START_DATE,
          GLP.END_DATE,
          SUM(FI.ITEM_QUANTITY),
          MIN(FI.FORECAST_ITEM_ID),
          RA.RESOURCE_ASSIGNMENT_ID,
          RA.UNIT_OF_MEASURE,
          RA.RESOURCE_CLASS_CODE,
          RA.ORGANIZATION_ID,
          RA.JOB_ID,
          RA.PERSON_ID,
          RA.EXPENDITURE_TYPE,
          RA.NON_LABOR_RESOURCE,
          RA.BOM_RESOURCE_ID,
          RA.INVENTORY_ITEM_ID,
          RA.ITEM_CATEGORY_ID,
          RA.MFC_COST_TYPE_ID,
          RA.RATE_EXPENDITURE_TYPE,
          NVL(RA.RATE_BASED_FLAG, 'N') RATE_BASED_FLAG,
          RA.RATE_EXPENDITURE_ORG_ID,
          RLM.RES_FORMAT_ID,
          RLM.RESOURCE_LIST_MEMBER_ID,
          RLM.RESOURCE_ID,
          RLM.RESOURCE_LIST_ID,
          RLM.ALIAS
   FROM   PA_FORECAST_ITEMS FI,
          PA_FORECAST_ITEM_DETAILS FID,
          GL_PERIODS GLP,
          PA_RES_LIST_MAP_TMP4 TMP4,
          PA_RESOURCE_ASSIGNMENTS RA,
          PA_RESOURCE_LIST_MEMBERS RLM
  WHERE   FI.FORECAST_ITEM_ID = FID.FORECAST_ITEM_ID
  AND     FID.FORECAST_SUMMARIZED_CODE = 'N'
  AND     FID.NET_ZERO_FLAG            = 'N'
  AND     FI.ERROR_FLAG                = 'N'
  AND     FI.DELETE_FLAG               = 'N'
  AND     GLP.PERIOD_SET_NAME          = FI.RCVR_PERIOD_SET_NAME
  AND     GLP.PERIOD_NAME              = FI.RCVR_GL_PERIOD_NAME
  AND     ASSIGNMENT_ID                = p_prj_assignment_id
  AND     FI.EXPENDITURE_ORG_ID        <> -88
  AND     FI.ITEM_DATE                 >= NVL(c_act_thru_date+1,FI.ITEM_DATE)
  AND     FI.EXPENDITURE_ORGANIZATION_ID = c_exp_organization_id
  AND     ASSIGNMENT_ID                = TMP4.TXN_SOURCE_ID
  AND     RA.RESOURCE_ASSIGNMENT_ID    = TMP4.TXN_RESOURCE_ASSIGNMENT_ID
  AND     RA.RESOURCE_LIST_MEMBER_ID   = RLM.RESOURCE_LIST_MEMBER_ID
  GROUP BY FI.EXPENDITURE_ORG_ID,
           FI.EXPENDITURE_ORGANIZATION_ID,
           GLP.START_DATE,
           GLP.END_DATE,
           FI.RCVR_GL_PERIOD_NAME,
           RA.RESOURCE_ASSIGNMENT_ID,
           RA.UNIT_OF_MEASURE,
           RA.RESOURCE_CLASS_CODE,
           RA.ORGANIZATION_ID,
           RA.JOB_ID,
           RA.PERSON_ID,
           RA.EXPENDITURE_TYPE,
           RA.NON_LABOR_RESOURCE,
           RA.BOM_RESOURCE_ID,
           RA.INVENTORY_ITEM_ID,
           RA.ITEM_CATEGORY_ID,
           RA.MFC_COST_TYPE_ID,
           RA.RATE_EXPENDITURE_TYPE,
           RA.RATE_BASED_FLAG,
           RA.RATE_EXPENDITURE_ORG_ID,
           RLM.RES_FORMAT_ID,
           RLM.RESOURCE_LIST_MEMBER_ID,
           RLM.RESOURCE_ID,
           RLM.RESOURCE_LIST_ID,
           RLM.ALIAS;


   CURSOR FCST_RATE_NONE(p_prj_assignment_id NUMBER, c_act_thru_date DATE, c_exp_organization_id NUMBER)  IS
   SELECT FI.EXPENDITURE_ORG_ID,
          FI.EXPENDITURE_ORGANIZATION_ID,
          SUM(FI.ITEM_QUANTITY),
          MIN(FI.FORECAST_ITEM_ID),
          null period_name,
          min(fi.item_Date) start_date,
          max(fi.item_Date) end_date,   -- Bug 4621534: Changed min to max.
          RA.RESOURCE_ASSIGNMENT_ID,
          RA.UNIT_OF_MEASURE,
          RA.RESOURCE_CLASS_CODE,
          RA.ORGANIZATION_ID,
          RA.JOB_ID,
          RA.PERSON_ID,
          RA.EXPENDITURE_TYPE,
          RA.NON_LABOR_RESOURCE,
          RA.BOM_RESOURCE_ID,
          RA.INVENTORY_ITEM_ID,
          RA.ITEM_CATEGORY_ID,
          RA.MFC_COST_TYPE_ID,
          RA.RATE_EXPENDITURE_TYPE,
          NVL(RA.RATE_BASED_FLAG, 'N') RATE_BASED_FLAG,
          RA.RATE_EXPENDITURE_ORG_ID,
          RLM.RES_FORMAT_ID,
          RLM.RESOURCE_LIST_MEMBER_ID,
          RLM.RESOURCE_ID,
          RLM.RESOURCE_LIST_ID,
          RLM.ALIAS
   FROM   PA_FORECAST_ITEMS FI,
          PA_FORECAST_ITEM_DETAILS FID,
          PA_RES_LIST_MAP_TMP4 TMP4,
          PA_RESOURCE_ASSIGNMENTS RA,
          PA_RESOURCE_LIST_MEMBERS RLM
   WHERE   FI.FORECAST_ITEM_ID = FID.FORECAST_ITEM_ID
   AND     FID.FORECAST_SUMMARIZED_CODE = 'N'
   AND     FID.NET_ZERO_FLAG            = 'N'
   AND     FI.ERROR_FLAG                = 'N'
   AND     FI.DELETE_FLAG               = 'N'
   AND     ASSIGNMENT_ID                = p_prj_assignment_id
   AND     FI.EXPENDITURE_ORG_ID        <> -88
   AND     FI.ITEM_DATE                 >= NVL(c_act_thru_date+1,FI.ITEM_DATE)
   AND     FI.EXPENDITURE_ORGANIZATION_ID = c_exp_organization_id
   AND     ASSIGNMENT_ID                = TMP4.TXN_SOURCE_ID
   AND     RA.RESOURCE_ASSIGNMENT_ID    = TMP4.TXN_RESOURCE_ASSIGNMENT_ID
   AND     RA.RESOURCE_LIST_MEMBER_ID   = RLM.RESOURCE_LIST_MEMBER_ID
   GROUP BY   FI.EXPENDITURE_ORG_ID,
              FI.EXPENDITURE_ORGANIZATION_ID,
              RA.RESOURCE_ASSIGNMENT_ID,
              RA.UNIT_OF_MEASURE,
              RA.RESOURCE_CLASS_CODE,
              RA.ORGANIZATION_ID,
              RA.JOB_ID,
              RA.PERSON_ID,
              RA.EXPENDITURE_TYPE,
              RA.NON_LABOR_RESOURCE,
              RA.BOM_RESOURCE_ID,
              RA.INVENTORY_ITEM_ID,
              RA.ITEM_CATEGORY_ID,
              RA.MFC_COST_TYPE_ID,
              RA.RATE_EXPENDITURE_TYPE,
              RA.RATE_BASED_FLAG,
              RA.RATE_EXPENDITURE_ORG_ID,
              RLM.RES_FORMAT_ID,
              RLM.RESOURCE_LIST_MEMBER_ID,
              RLM.RESOURCE_ID,
              RLM.RESOURCE_LIST_ID,
              RLM.ALIAS;


   CURSOR GET_RATE_API_PARAMS_CUR IS
   SELECT  DECODE(NVL(pfo.use_planning_rates_flag,'N'),'N',pfo.res_class_bill_rate_sch_id,
                          DECODE(bv.version_type,'REVENUE',pfo.rev_res_class_rate_sch_id,
                                                 'ALL'    ,pfo.rev_res_class_rate_sch_id,
                                                           NULL)) res_class_bill_rate_sch_id
          ,DECODE(NVL(pfo.use_planning_rates_flag,'N'),'N',pfo.res_class_raw_cost_sch_id,
                          DECODE(bv.version_type,'COST',pfo.cost_res_class_rate_sch_id,
                                                 'ALL' ,pfo.cost_res_class_rate_sch_id,
                                                           NULL)) res_class_raw_cost_sch_id
          ,NVL(pfo.use_planning_rates_flag,'N') use_planning_rates_flag
          ,DECODE(NVL(pfo.use_planning_rates_flag,'N'),'N',NULL,
                          DECODE(bv.version_type,'REVENUE',pfo.rev_job_rate_sch_id,
                                                 'ALL'    ,pfo.rev_job_rate_sch_id,
                                                 NULL))    rev_job_rate_sch_id
          ,DECODE(NVL(pfo.use_planning_rates_flag,'N'),'N',NULL,
                          DECODE(bv.version_type,'COST'   ,pfo.cost_job_rate_sch_id,
                                                 'ALL'    ,pfo.cost_job_rate_sch_id,
                                                 NULL))     cost_job_rate_sch_id
          ,DECODE(NVL(pfo.use_planning_rates_flag,'N'),'N',NULL,
                          DECODE(bv.version_type,'REVENUE',pfo.rev_emp_rate_sch_id,
                                                 'ALL'    ,pfo.rev_emp_rate_sch_id,
                                                 NULL))    rev_emp_rate_sch_id
          ,DECODE(NVL(pfo.use_planning_rates_flag,'N'),'N',NULL,
                          DECODE(bv.version_type,'COST'   ,pfo.cost_emp_rate_sch_id,
                                                 'ALL'    ,pfo.cost_emp_rate_sch_id,
                                                 NULL))     cost_emp_rate_sch_id
          ,DECODE(NVL(pfo.use_planning_rates_flag,'N'),'N',NULL,
                          DECODE(bv.version_type,'REVENUE',pfo.rev_non_labor_res_rate_sch_id,
                                                 'ALL'    ,pfo.rev_non_labor_res_rate_sch_id,
                                                 NULL))     rev_non_labor_res_rate_sch_id
          ,DECODE(NVL(pfo.use_planning_rates_flag,'N'),'N',NULL,
                          DECODE(bv.version_type,'COST'   ,pfo.cost_non_labor_res_rate_sch_id,
                                                 'ALL'    ,pfo.cost_non_labor_res_rate_sch_id,
                                                 NULL))     cost_non_labor_res_rate_sch_id
          ,DECODE(NVL(pfo.use_planning_rates_flag,'N'),'N',NULL,
                          DECODE(bv.version_type,'COST'   ,pfo.cost_burden_rate_sch_id,
                                                 'ALL'    ,pfo.cost_burden_rate_sch_id,
                                                 NULL))     cost_burden_rate_sch_id
          ,bv.version_type fp_budget_version_type
          ,NVL(bv.approved_rev_plan_type_flag,'N') approved_rev_plan_type_flag
          ,NVL(pfo.plan_in_multi_curr_flag,'N')    plan_in_multi_curr_flag
          ,pp.assign_precedes_task
          ,pp.bill_job_group_id
          ,pp.carrying_out_organization_id
          ,NVL(pp.multi_currency_billing_flag,'N') multi_currency_billing_flag
          ,pp.org_id
          ,pp.non_labor_bill_rate_org_id
          ,pp.project_currency_code
          ,pp.non_labor_schedule_discount
          ,pp.non_labor_schedule_fixed_date
          ,pp.non_lab_std_bill_rt_sch_id
          ,pp.project_type
          ,pp.projfunc_currency_code
          ,pp.emp_bill_rate_schedule_id
          ,pp.job_bill_rate_schedule_id
          ,pp.labor_bill_rate_org_id
          ,pp.labor_sch_type
          ,pp.non_labor_sch_type
          ,pp.name project_name
        FROM pa_proj_fp_options pfo
            ,pa_budget_versions bv
        ,pa_projects_all pp
        WHERE pfo.fin_plan_version_id = bv.budget_version_id
        AND bv.budget_version_id = p_budget_version_id
    AND pp.project_id = bv.project_id
    AND pfo.project_id = pp.project_id;

   rate_rec  get_rate_api_params_cur%ROWTYPE;

   CURSOR   CHECK_BILL_RATE_OVRD_EXISTS IS
   SELECT   'Y'
   FROM     DUAL
   WHERE    EXISTS (SELECT assignment_id
                      FROM pa_project_assignments
                     WHERE project_id = p_project_id
                       AND bill_rate_override is not null);

    l_bill_rate_ovrd_exists_flag    VARCHAR2(1) := 'N';

   -- Bug 4615787: Added 'PA_GL_' to cursor name to emphasize that
   -- it should be used when the Target timephase is either PA or GL.

   CURSOR   GROUP_TO_INSERT_INTO_PA_GL_BL IS
   SELECT   RESOURCE_ASSIGNMENT_ID,
            START_DATE,
            END_DATE,
            PERIOD_NAME,
            SUM(QUANTITY),
            TXN_CURRENCY_CODE,
            SUM(TXN_RAW_COST),
            SUM(TXN_BURDENED_COST),
            SUM(TXN_REVENUE),
            BILL_MARKUP_PERCENTAGE,
            COST_REJECTION_CODE,
            BURDEN_REJECTION_CODE,
            REVENUE_REJECTION_CODE,
            COST_IND_COMPILED_SET_ID
     FROM   pa_fp_rollup_tmp
   GROUP BY resource_assignment_id,
            txn_currency_code,
            start_date,
            end_date,
            period_name,
            BILL_MARKUP_PERCENTAGE,
            COST_REJECTION_CODE,
            BURDEN_REJECTION_CODE,
            REVENUE_REJECTION_CODE,
            COST_IND_COMPILED_SET_ID;

   -- Bug 4615787: Added cursor GROUP_TO_INSERT_INTO_NTP_BL to
   -- aggregate data correctly when the Target version is None
   -- timephased. Derived from GROUP_TO_INSERT_INTO_NTP_BL,
   -- this cursor is different in that it does not group by
   -- start_date, end_date, period_name, bill_markup_percentage,
   -- or cost_ind_compiled_set_id. In the SELECT clause, we can
   -- take the MIN(start_date), MAX(end_date), and NULL for the
   -- remaining ungrouped columns.
   -- The goal is to ensure that a single record is fetched for
   -- each (Resource Assignment Id, Txn Currency) combination.

   CURSOR   GROUP_TO_INSERT_INTO_NTP_BL IS
   SELECT   RESOURCE_ASSIGNMENT_ID,
            MIN(START_DATE),
            MAX(END_DATE),
            NULL, --PERIOD_NAME,
            SUM(QUANTITY),
            TXN_CURRENCY_CODE,
            SUM(TXN_RAW_COST),
            SUM(TXN_BURDENED_COST),
            SUM(TXN_REVENUE),
            NULL, --BILL_MARKUP_PERCENTAGE,
            COST_REJECTION_CODE,
            BURDEN_REJECTION_CODE,
            REVENUE_REJECTION_CODE,
            NULL  --COST_IND_COMPILED_SET_ID
     FROM   pa_fp_rollup_tmp
   GROUP BY resource_assignment_id,
            txn_currency_code,
            COST_REJECTION_CODE,
            BURDEN_REJECTION_CODE,
            REVENUE_REJECTION_CODE;

   -- Bug 4549862: Added cursor for when the target version is None
   -- Time Phased and the context is Forecast Generation. In this
   -- case, budget lines may exist with actuals. Fetch temp table
   -- data for which budget lines do not yet exist, which should be
   -- Inserted into pa_budget_lines.

   -- Bug 4615787: Removed start_date, end_date, period_name,
   -- bill_markup_percentage, and cost_ind_compiled_set_id from the
   -- GROUP BY clause. In the SELECT clause, take MIN(start_date),
   -- MAX(end_date), and NULL for the remaining ungrouped columns.
   -- The goal is to ensure that a single record is fetched for
   -- each (Resource Assignment Id, Txn Currency) combination.

   CURSOR   GROUP_TO_INS_INTO_NTP_FCST_BL IS
   SELECT   RESOURCE_ASSIGNMENT_ID,
            MIN(START_DATE),
            MAX(END_DATE),
            NULL, --PERIOD_NAME,
            SUM(QUANTITY),
            TXN_CURRENCY_CODE,
            SUM(TXN_RAW_COST),
            SUM(TXN_BURDENED_COST),
            SUM(TXN_REVENUE),
            NULL, --BILL_MARKUP_PERCENTAGE,
            COST_REJECTION_CODE,
            BURDEN_REJECTION_CODE,
            REVENUE_REJECTION_CODE,
            NULL  --COST_IND_COMPILED_SET_ID
     FROM   pa_fp_rollup_tmp tmp
   GROUP BY resource_assignment_id,
            txn_currency_code,
            COST_REJECTION_CODE,
            BURDEN_REJECTION_CODE,
            REVENUE_REJECTION_CODE
   HAVING ( SELECT count(*)
            FROM   pa_budget_lines bl
            WHERE  tmp.resource_assignment_id = bl.resource_assignment_id
            AND    tmp.txn_currency_code = bl.txn_currency_code ) = 0;


   -- Bug 4549862: Added cursor for when the target version is None
   -- Time Phased and the context is Forecast Generation. In this
   -- case, budget lines may exist with actuals. Fetch temp table
   -- data for which budget lines exist, which whould be Updated
   -- into pa_budget_lines.

   -- Bug 4615787: Removed start_date, end_date, period_name,
   -- bill_markup_percentage, and cost_ind_compiled_set_id from the
   -- GROUP BY clause. In the SELECT clause, take MIN(start_date),
   -- MAX(end_date), and NULL for the remaining ungrouped columns.
   -- The goal is to ensure that a single record is fetched for
   -- each (Resource Assignment Id, Txn Currency) combination.

   CURSOR   GROUP_TO_UPD_INTO_NTP_FCST_BL IS
   SELECT   RESOURCE_ASSIGNMENT_ID,
            MIN(START_DATE),
            MAX(END_DATE),
            NULL, --PERIOD_NAME,
            SUM(QUANTITY),
            TXN_CURRENCY_CODE,
            SUM(TXN_RAW_COST),
            SUM(TXN_BURDENED_COST),
            SUM(TXN_REVENUE),
            NULL, --BILL_MARKUP_PERCENTAGE,
            COST_REJECTION_CODE,
            BURDEN_REJECTION_CODE,
            REVENUE_REJECTION_CODE,
            NULL  --COST_IND_COMPILED_SET_ID
     FROM   pa_fp_rollup_tmp tmp
   GROUP BY resource_assignment_id,
            txn_currency_code,
            COST_REJECTION_CODE,
            BURDEN_REJECTION_CODE,
            REVENUE_REJECTION_CODE
   HAVING ( SELECT count(*)
            FROM   pa_budget_lines bl
            WHERE  tmp.resource_assignment_id = bl.resource_assignment_id
            AND    tmp.txn_currency_code = bl.txn_currency_code ) > 0;


   CURSOR FIND_REJECTION_CODE IS
   SELECT tmp1.resource_assignment_id,
          tmp1.start_date,
          tmp1.txn_currency_code,
          tmp1.revenue_rejection_code
   FROM   pa_fp_rollup_tmp tmp1,
          pa_fp_rollup_tmp tmp2
   WHERE  tmp2.txn_revenue IS NOT NULL
     AND  tmp1.revenue_rejection_code IS NOT NULL
     AND  tmp1.resource_assignment_id = tmp2.resource_assignment_id
     AND  tmp1.txn_currency_code = tmp2.txn_currency_code
     AND  tmp1.start_date = tmp2.start_date;
    -- END of M-closeout: Bill Rate Override ER ------------------------------------------

    l_carrying_out_organization_id  PA_PROJECTS_ALL.CARRYING_OUT_ORGANIZATION_ID%TYPE;
    l_project_currency_code         PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE;
    l_projfunc_currency_code        PA_PROJECTS_ALL.PROJFUNC_CURRENCY_CODE%TYPE;
    l_project_value                 PA_PROJECTS_ALL.PROJECT_VALUE%TYPE;
    l_job_bill_rate_schedule_id     PA_PROJECTS_ALL.JOB_BILL_RATE_SCHEDULE_ID%TYPE;
    l_emp_bill_rate_schedule_id     PA_PROJECTS_ALL.EMP_BILL_RATE_SCHEDULE_ID%TYPE;
    l_rev_gen_method                VARCHAR2(3);
    l_distribution_rule             PA_PROJECTS_ALL.DISTRIBUTION_RULE%TYPE;
    l_project_type                  PA_PROJECTS_ALL.PROJECT_TYPE%TYPE;
    l_bill_job_group_id             PA_PROJECTS_ALL.BILL_JOB_GROUP_ID%TYPE;
    l_org_id                        PA_PROJECTS_ALL.ORG_ID%TYPE;
    l_completion_date               PA_PROJECTS_ALL.COMPLETION_DATE%TYPE;
    l_template_flag                 PA_PROJECTS_ALL.TEMPLATE_FLAG%TYPE;
    l_projfunc_bil_rate_date_code   PA_PROJECTS_ALL.PROJECT_BIL_RATE_DATE_CODE%TYPE;
    l_projfunc_bil_rate_type        PA_PROJECTS_ALL.PROJECT_BIL_RATE_TYPE%TYPE;
    l_projfunc_bil_rate_date        PA_PROJECTS_ALL.PROJECT_BIL_RATE_DATE%TYPE;
    l_projfunc_bil_exchange_rate    PA_PROJECTS_ALL.PROJECT_BIL_EXCHANGE_RATE%TYPE;

    l_system_linkage                Pa_Forecast_Items.EXPENDITURE_TYPE_CLASS%TYPE;
   /* Added for Org Forecasting */

    l_cost_job_group_id            Pa_Projects_All.Cost_Job_Group_Id%TYPE;
    l_prj_rate_date                Pa_Projects_All.PROJECT_RATE_DATE%TYPE;
    l_prj_rate_type                Pa_Projects_All.PROJECT_RATE_TYPE%TYPE;
    l_prj_bil_rate_date_code       Pa_Projects_All.PROJECT_BIL_RATE_DATE_CODE%TYPE;
    l_prj_bil_rate_type            Pa_Projects_All.PROJECT_BIL_RATE_TYPE%TYPE;
    l_prj_bil_rate_date            Pa_Projects_All.PROJECT_BIL_RATE_DATE%TYPE;
    l_prj_bil_ex_rate              Pa_Projects_All.PROJECT_BIL_EXCHANGE_RATE%TYPE;
    l_prjfunc_cost_rate_type       Pa_Projects_All.PROJFUNC_COST_RATE_TYPE%TYPE;
    l_prjfunc_cost_rate_date       Pa_Projects_All.PROJFUNC_COST_RATE_DATE%TYPE;
    l_labor_tp_schedule_id         Pa_Projects_All.LABOR_TP_SCHEDULE_ID%TYPE;
    l_labor_tp_fixed_date          Pa_Projects_All.LABOR_TP_FIXED_DATE%TYPE;

    l_labor_sch_discount           Pa_Projects_All.LABOR_SCHEDULE_DISCOUNT%TYPE;
    l_asg_precedes_task            Pa_Projects_All.ASSIGN_PRECEDES_TASK%TYPE;
    l_labor_bill_rate_orgid        Pa_Projects_All.LABOR_BILL_RATE_ORG_ID%TYPE;
    l_labor_std_bill_rate_sch      Pa_Projects_All.LABOR_STD_BILL_RATE_SCHDL%TYPE;
    l_labor_sch_fixed_dt           Pa_Projects_All.LABOR_SCHEDULE_FIXED_DATE%TYPE;
    l_labor_sch_type               Pa_Projects_All.LABOR_SCH_TYPE%TYPE;


    l_budget_version_id            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE;
    l_version_number               PA_BUDGET_VERSIONS.VERSION_NUMBER%TYPE;
    l_plan_processing_code         PA_BUDGET_VERSIONS.PLAN_PROCESSING_CODE%TYPE;

    --Declaring PL/SQL tables for bulk binding
    l_proj_assignment_id            PA_PLSQL_DATATYPES.IdTabTyp;
    l_proj_start_date               PA_PLSQL_DATATYPES.DateTabTyp;
    l_proj_resource_id              PA_PLSQL_DATATYPES.IdTabTyp;
    l_proj_project_role_id          PA_PLSQL_DATATYPES.IdTabTyp;
    l_proj_fcst_job_id              PA_PLSQL_DATATYPES.IdTabTyp;
    l_proj_fcst_job_group_id        PA_PLSQL_DATATYPES.IdTabTyp;
    l_proj_meaning                  PA_PLSQL_DATATYPES.Char80TabTyp;
    l_proj_named_role               PA_PLSQL_DATATYPES.Char80TabTyp;
    l_proj_assignment_type          PA_PLSQL_DATATYPES.Char30TabTyp;
    l_proj_exp_org_id               PA_PLSQL_DATATYPES.IdTabTyp;
    l_proj_exp_organization_id      PA_PLSQL_DATATYPES.IdTabTyp;
    l_proj_expenditure_org_id       PA_PLSQL_DATATYPES.IdTabTyp;
    l_fi_exp_organization_id        PA_PLSQL_DATATYPES.IdTabTyp;
    l_proj_exp_type                 PA_PLSQL_DATATYPES.Char30TabTyp;
    l_proj_person_id                PA_PLSQL_DATATYPES.IdTabTyp;
    l_proj_revenue_bill_rate        PA_PLSQL_DATATYPES.NumTabTyp;
    l_proj_short_assignment_type    PA_PLSQL_DATATYPES.Char30TabTyp;
    l_proj_status_code              PA_PLSQL_DATATYPES.Char30TabTyp;
    l_proj_billable_flag            PA_PLSQL_DATATYPES.Char2TabTyp;
    l_proj_process_code             PA_PLSQL_DATATYPES.Char30TabTyp;
    l_proj_error_msg_code           PA_PLSQL_DATATYPES.Char30TabTyp;
    l_proj_end_date                 PA_PLSQL_DATATYPES.DateTabTyp;
    l_proj_fc_res_type_code         PA_PLSQL_DATATYPES.Char30TabTyp;

    l_role_error_code              PA_RESOURCE_ASSIGNMENTS.PLAN_ERROR_CODE%TYPE;

    l_err_code                     VARCHAR2(30);
    l_err_stack                    VARCHAR2(2000);
    l_err_stage                    VARCHAR2(2000);
    l_err_id                       NUMBER;


    l_projfunc_bill_rate           NUMBER;
    l_projfunc_raw_revenue         NUMBER;
    l_projfunc_raw_cost            NUMBER;
    l_projfunc_raw_cost_rate       NUMBER;
    l_projfunc_burdened_cost       NUMBER;
    l_projfunc_burdened_cost_rate  NUMBER;
    l_error_msg                    VARCHAR2(30);

    l_std_raw_revenue              NUMBER;
    l_rev_currency_code            PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE;
    l_billable_flag                VARCHAR2(2);

    l_rev_reject_reason            VARCHAR2(1000);
    l_cost_reject_reason           VARCHAR2(1000);
    l_burdened_reject_reason       VARCHAR2(1000);
    l_other_reject_reason          VARCHAR2(1000);

    l_resource_list_member_id      PA_RESOURCE_LIST_MEMBERS.RESOURCE_LIST_MEMBER_ID%TYPE;
    l_resource_id                  PA_RESOURCE_LIST_MEMBERS.RESOURCE_LIST_MEMBER_ID%TYPE;
    l_resource_assignment_id       PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE;
    l_track_as_labor_flag          PA_RESOURCE_LIST_MEMBERS.TRACK_AS_LABOR_FLAG%TYPE;
    l_parent_member_id             PA_RESOURCE_LIST_MEMBERS.PARENT_MEMBER_ID%TYPE;
    l_prj_res_assignment_id        PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE;

    l_fcst_opt_jobcostrate_sch_id  PA_FORECASTING_OPTIONS_ALL.JOB_COST_RATE_SCHEDULE_ID%TYPE;

    l_calling_mode                 VARCHAR2(50);
    l_rowid                        ROWID;
    l_counter                      NUMBER := 1 ;
    l_cost_cnt                     NUMBER := 1 ;

    l_created_by                   NUMBER(15) := PA_FORECAST_GLOBAL.G_who_columns.G_created_by;
    l_request_id                   NUMBER(15) := PA_FORECAST_GLOBAL.G_who_columns.G_request_id;
    l_program_id                   NUMBER(15) := PA_FORECAST_GLOBAL.G_who_columns.G_program_id;
    l_program_application_id       NUMBER(15) := PA_FORECAST_GLOBAL.G_who_columns.G_program_application_id;
    l_creation_date                DATE := PA_FORECAST_GLOBAL.G_who_columns.G_creation_date;
    l_program_update_date          DATE := PA_FORECAST_GLOBAL.G_who_columns.G_last_update_date;

    l_period_name_flag             VARCHAR2(1);
    l_period_name_tot_flag         VARCHAR2(1);
    l_current_index                PLS_INTEGER;
    l_current_index_tot            PLS_INTEGER:=1;
    l_cnt                          PLS_INTEGER;
    l_budget_lines_tbl             PA_GENERATE_FORECAST_PUB.budget_lines_tbl_type;
    l_budget_lines_tot_tbl         PA_GENERATE_FORECAST_PUB.budget_lines_tbl_type;


    l_prj_revenue_tab              PA_RATE_PVT_PKG.ProjAmt_TabTyp;
    l_prj_cost_tab                 PA_RATE_PVT_PKG.ProjAmt_TabTyp;
    l_project_id                   NUMBER(15);

    l_ret_status                   VARCHAR2(100);
    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(2000);
    l_data                         VARCHAR2(2000);
    l_msg_index_out                NUMBER:=0;
    l_init_bill_rate_flag          VARCHAR2(1);
    l_role_error_code_flag         VARCHAR2(1);
    l_prj_level_revenue            NUMBER:=0;
    l_process_fis_flag             VARCHAR2(1);
    l_asgmt_status_flag            VARCHAR2(1);
    l_commit_cnt                   NUMBER:= 0;
    l_event_error_msg              VARCHAR2(100);

    l_bl_start_date_tab            PA_PLSQL_DATATYPES.DateTabTyp;
    l_bl_end_date_tab              PA_PLSQL_DATATYPES.DateTabTyp;
    l_bl_pd_name_tab               PA_PLSQL_DATATYPES.Char30TabTyp;
    l_bl_qty_tab                   PA_PLSQL_DATATYPES.NumTabTyp;
    l_bl_rcost_tab                 PA_PLSQL_DATATYPES.NumTabTyp;
    l_bl_revenue_tab               PA_PLSQL_DATATYPES.NumTabTyp;
    l_bl_bcost_tab                 PA_PLSQL_DATATYPES.NumTabTyp;
    l_bl_cost_rej_tab              PA_PLSQL_DATATYPES.Char30TabTyp;
    l_bl_bcost_rej_tab             PA_PLSQL_DATATYPES.Char30TabTyp;
    l_bl_rev_rej_tab               PA_PLSQL_DATATYPES.Char30TabTyp;
    l_bl_oth_rej_tab               PA_PLSQL_DATATYPES.Char30TabTyp;

    l_rt_forecast_item_id_tab      PA_PLSQL_DATATYPES.IdTabTyp;
    l_rt_pd_name_tab               PA_PLSQL_DATATYPES.Char30TabTyp;
    l_rt_start_date_tab            PA_PLSQL_DATATYPES.DateTabTyp;
    l_rt_end_date_tab              PA_PLSQL_DATATYPES.DateTabTyp;

    l_rt_qty_tab                   PA_PLSQL_DATATYPES.NumTabTyp;
    l_rt_exp_org_id_tab            PA_PLSQL_DATATYPES.IdTabTyp;
    l_rt_exp_organization_id_tab   PA_PLSQL_DATATYPES.IdTabTyp;

    -- M-closeout: Bill Rate Override ER ------------------------------------------
    l_rt_res_assignment_id_tab     SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_rt_uom_tab                   SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
    l_rt_res_class_code_tab        SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
    l_rt_organization_id_tab       SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_rt_job_id_tab                SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_rt_person_id_tab             SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_rt_expenditure_type_tab      SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
    l_rt_non_labor_resource_tab    SYSTEM.pa_varchar2_20_tbl_type:=SYSTEM.pa_varchar2_20_tbl_type();
    l_rt_bom_resource_id_tab       SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_rt_inventory_item_id_tab     SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_rt_item_category_id_tab      SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_rt_mfc_cost_type_id_tab      SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_rt_rate_expenditure_type_tab SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
    l_rt_rate_based_flag_tab       SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
    l_rt_rate_exp_org_id_tab       SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_rt_res_format_id_tab         SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_rt_res_list_member_id_tab    SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_rt_resource_id_tab           SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_rt_resource_list_id_tab      SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_rt_alias_tab                 SYSTEM.pa_varchar2_80_tbl_type:=SYSTEM.pa_varchar2_80_tbl_type();
    l_mfc_cost_source              CONSTANT NUMBER := 2;
    l_txn_currency_code            VARCHAR2(100);

    l_bl_RES_ASSIGNMENT_ID_tab      SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_bl_PERIOD_NAME_tab            SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
    l_bl_QUANTITY_tab               SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_bl_TXN_CURRENCY_CODE_tab      SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
    l_bl_TXN_RAW_COST_tab           SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_bl_TXN_BURDENED_COST_tab      SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_bl_TXN_REVENUE_tab            SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_bl_BILL_MARKUP_PERCENT_tab    SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_bl_COST_REJECTION_CODE_tab    SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
    l_bl_BURDEN_REJECTION_CODE_tab  SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
    l_bl_REV_REJECTION_CODE_tab     SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
    l_bl_COST_IND_C_SET_ID_tab SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();

    l_rej_res_assignment_id_tab     SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_rej_start_date_tab            SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
    l_rej_txn_currency_code_tab     SYSTEM.pa_varchar2_80_tbl_type:=SYSTEM.pa_varchar2_80_tbl_type();
    l_rej_revenue_rej_code_tab      SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
    -- END OF M-closeout: Bill Rate Override ER ------------------------------------------

    l_rt_exp_func_raw_cst_rt_tab   PA_PLSQL_DATATYPES.NumTabTyp;
    l_rt_exp_func_raw_cst_tab      PA_PLSQL_DATATYPES.NumTabTyp;
    l_rt_exp_func_bur_cst_rt_tab   PA_PLSQL_DATATYPES.NumTabTyp;
    l_rt_exp_func_burdned_cst_tab  PA_PLSQL_DATATYPES.NumTabTyp;
    l_rt_projfunc_bill_rt_tab      PA_PLSQL_DATATYPES.NumTabTyp;
    l_rt_projfunc_raw_revenue_tab  PA_PLSQL_DATATYPES.NumTabTyp;
    l_rt_projfunc_raw_cst_tab      PA_PLSQL_DATATYPES.NumTabTyp;
    l_rt_projfunc_raw_cst_rt_tab   PA_PLSQL_DATATYPES.NumTabTyp;
    l_rt_projfunc_burdned_cst_tab  PA_PLSQL_DATATYPES.NumTabTyp;
    l_rt_projfunc_bd_cst_rt_tab    PA_PLSQL_DATATYPES.NumTabTyp;
    l_rt_rev_rejct_reason_tab      PA_PLSQL_DATATYPES.Char30TabTyp;
    l_rt_cst_rejct_reason_tab      PA_PLSQL_DATATYPES.Char30TabTyp;
    l_rt_burdned_rejct_reason_tab  PA_PLSQL_DATATYPES.Char30TabTyp;
    l_rt_others_rejct_reason_tab   PA_PLSQL_DATATYPES.Char30TabTyp;
    l_bulk_fetch_count             NUMBER:= 0;
    l_markup_percentage            NUMBER;
    l_cost_based_error_code        VARCHAR2(100);

    l_prj_asg_id_tab               PA_PLSQL_DATATYPES.IdTabTyp;
    l_avg_bill_rate_tab            PA_PLSQL_DATATYPES.NumTabTyp;

    l_rowcount number              :=0;

    l_amount_set_id                PA_PROJ_FP_OPTIONS.COST_AMOUNT_SET_ID%TYPE;
    l_fin_plan_level_code          PA_PROJ_FP_OPTIONS.COST_FIN_PLAN_LEVEL_CODE%TYPE;
    l_time_phased_code             PA_PROJ_FP_OPTIONS.COST_TIME_PHASED_CODE%TYPE;
    l_resource_list_id             PA_PROJ_FP_OPTIONS.COST_RESOURCE_LIST_ID%TYPE;
    l_res_planning_level           PA_PROJ_FP_OPTIONS.COST_RES_PLANNING_LEVEL%TYPE;
    l_rbs_version_id               PA_PROJ_FP_OPTIONS.RBS_VERSION_ID%TYPE;
    --l_plan_res_list_id             PA_PROJ_FP_OPTIONS.COST_PLAN_RES_LIST_ID%TYPE;
    l_emp_rate_sch_id              PA_PROJ_FP_OPTIONS.COST_EMP_RATE_SCH_ID%TYPE;
    l_job_rate_sch_id              PA_PROJ_FP_OPTIONS.COST_JOB_RATE_SCH_ID%TYPE;
    l_non_labor_res_rate_sch_id    PA_PROJ_FP_OPTIONS.COST_NON_LABOR_RES_RATE_SCH_ID%TYPE;
    l_res_class_rate_sch_id        PA_PROJ_FP_OPTIONS.COST_RES_CLASS_RATE_SCH_ID%TYPE;
    l_burden_rate_sch_id           PA_PROJ_FP_OPTIONS.COST_BURDEN_RATE_SCH_ID%TYPE;
    l_current_planning_period      PA_PROJ_FP_OPTIONS.COST_CURRENT_PLANNING_PERIOD%TYPE;
    l_period_mask_id               PA_PROJ_FP_OPTIONS.COST_PERIOD_MASK_ID%TYPE;
    l_gen_src_plan_type_id         PA_PROJ_FP_OPTIONS.GEN_SRC_COST_PLAN_TYPE_ID%TYPE;
    l_gen_src_plan_version_id      PA_PROJ_FP_OPTIONS.GEN_SRC_COST_PLAN_VERSION_ID%TYPE;
    l_gen_src_plan_ver_code        PA_PROJ_FP_OPTIONS.GEN_SRC_COST_PLAN_VER_CODE%TYPE;
    l_gen_src_code                 PA_PROJ_FP_OPTIONS.GEN_COST_SRC_CODE%TYPE;
    l_gen_etc_src_code             PA_PROJ_FP_OPTIONS.GEN_COST_ETC_SRC_CODE%TYPE;
    l_gen_incl_change_doc_flag     PA_PROJ_FP_OPTIONS.GEN_COST_INCL_CHANGE_DOC_FLAG%TYPE;
    l_gen_incl_open_comm_flag      PA_PROJ_FP_OPTIONS.GEN_COST_INCL_OPEN_COMM_FLAG%TYPE;
    l_gen_incl_bill_event_flag     PA_PROJ_FP_OPTIONS.GEN_REV_INCL_BILL_EVENT_FLAG%TYPE;
    l_gen_ret_manual_line_flag     PA_PROJ_FP_OPTIONS.GEN_COST_RET_MANUAL_LINE_FLAG%TYPE;
    l_gen_actual_amts_thru_code    PA_PROJ_FP_OPTIONS.GEN_COST_ACTUAL_AMTS_THRU_CODE%TYPE;
    l_gen_incl_unspent_amt_flag    PA_PROJ_FP_OPTIONS.GEN_COST_INCL_UNSPENT_AMT_FLAG%TYPE;

    l_raw_cost_flag                PA_FIN_PLAN_AMOUNT_SETS.RAW_COST_FLAG%TYPE;
    l_burdened_flag                PA_FIN_PLAN_AMOUNT_SETS.BURDENED_COST_FLAG%TYPE;
    l_revenue_flag                 PA_FIN_PLAN_AMOUNT_SETS.REVENUE_FLAG%TYPE;
    l_cost_quantity_flag           PA_FIN_PLAN_AMOUNT_SETS.COST_QTY_FLAG%TYPE;
    l_rev_quantity_flag            PA_FIN_PLAN_AMOUNT_SETS.REVENUE_QTY_FLAG%TYPE;
    l_all_quantity_flag            PA_FIN_PLAN_AMOUNT_SETS.ALL_QTY_FLAG%TYPE;
    l_bill_rate_flag               PA_FIN_PLAN_AMOUNT_SETS.BILL_RATE_FLAG%TYPE;
    l_cost_rate_flag               PA_FIN_PLAN_AMOUNT_SETS.COST_RATE_FLAG%TYPE;
    l_burden_rate_flag       PA_FIN_PLAN_AMOUNT_SETS.BURDEN_RATE_FLAG%TYPE;

    l_fp_cols_rec                  PA_FP_GEN_AMOUNT_UTILS.FP_COLS;

    l_res_assgn_id_tab             PA_PLSQL_DATATYPES.IdTabTyp;
    l_res_assgn_id_tmp_tab         SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_total_plan_quantity          number;
    l_rlm_id_tab                   PA_PLSQL_DATATYPES.IdTabTyp;

    l_last_updated_by              NUMBER := FND_GLOBAL.user_id;
    l_last_update_login            NUMBER := FND_GLOBAL.login_id;
    l_sysdate                      DATE   := SYSDATE;
    l_sysdate_trunc                DATE;
    l_proj_assgn_id_tab            PA_PLSQL_DATATYPES.IdTabTyp;
    l_proj_exp_organization_id_tab PA_PLSQL_DATATYPES.IdTabTyp;
    l_proj_res_assgn_id_tab        PA_PLSQL_DATATYPES.IdTabTyp;
    -- M-Closeout ER: Bill Rate Override ER
    l_proj_bill_rate_override_tab  SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_proj_bill_rate_cur_ovrd_tab  SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
    l_calculate_mode               VARCHAR2(30);
    l_cost_rate_multiplier         CONSTANT pa_labor_cost_multipliers.multiplier%TYPE := 1;
    l_bill_rate_multiplier         CONSTANT pa_labor_cost_multipliers.multiplier%TYPE := 1;
    l_cost_sch_type                VARCHAR2(30) := 'COST';
    l_override_organization_id     NUMBER := NULL;
    l_Final_Txn_Currency_Code      VARCHAR2(100);
    l_insert_Txn_Currency_Code     VARCHAR2(100); -- Bug 4615589
    l_return_status                VARCHAR2(1);
    l_error_code                   VARCHAR2(100);
    l_stage                        VARCHAR2(100);
    l_status                       VARCHAR2(100);
    l_entire_return_status         VARCHAR2(1);
    x_bill_rate                    NUMBER := NULL;
    x_cost_rate                    NUMBER := NULL;
    x_raw_cost                     NUMBER := NULL;
    x_cost_txn_curr_code           VARCHAR2(100) := NULL;
    x_rev_txn_curr_code            VARCHAR2(100) := NULL;
    x_burden_cost_rate             NUMBER := NULL;
    x_burden_cost                  NUMBER := NULL;
    x_raw_revenue                  NUMBER := NULL;
    x_burden_multiplier            NUMBER := NULL;
    x_bill_markup_percentage       NUMBER := NULL;
    x_raw_cost_rejection_code      VARCHAR2(30) := NULL;
    x_burden_cost_rejection_code   VARCHAR2(30) := NULL;
    x_revenue_rejection_code       VARCHAR2(30) := NULL;
    x_cost_ind_compiled_set_id     NUMBER := NULL;
    l_ce_raw_cost                  NUMBER := NULL;
    l_ce_burdened_cost             NUMBER := NULL;
    l_ce_revenue                   NUMBER := NULL;
    l_final_txn_rate_type          VARCHAR2(100);
    l_final_txn_rate_date          DATE := NULL;
    l_final_txn_exch_rate          NUMBER := NULL;
    l_final_txn_quantity           NUMBER := NULL;
    l_final_txn_revenue            NUMBER := NULL;
    l_final_txn_raw_cost           NUMBER := NULL;
    l_final_txn_burden_cost        NUMBER := NULL;

    x_dummy_rate_date  DATE;
    x_dummy_rate_type  VARCHAR2(100);
    x_dummy_exch_rate  NUMBER;
    x_dummy_cost       NUMBER;
    -- END of M-Closeout ER:  Bill Rate Override ER

    --Local PL/SQL table used for calling Calculate API
    l_calling_module                  VARCHAR2(30) := 'BUDGET_GENERATION';
    l_refresh_rates_flag              VARCHAR2(1) := 'Y';
    l_refresh_conv_rates_flag         VARCHAR2(1) := 'N';
    l_spread_required_flag            VARCHAR2(1) := 'N';
    l_conv_rates_required_flag        VARCHAR2(1) := 'N';
    l_rollup_required_flag            VARCHAR2(1) := 'N';
    l_mass_adjust_flag                VARCHAR2(1) := 'N';
    l_raTxn_rollup_api_call_flag      VARCHAR2(1) := 'N'; -- Added for IPM new entity ER
    l_quantity_adj_pct                NUMBER   := NULL;
    l_cost_rate_adj_pct               NUMBER   := NULL;
    l_burdened_rate_adj_pct           NUMBER   := NULL;
    l_bill_rate_adj_pct               NUMBER   := NULL;
    l_source_context                  pa_fp_res_assignments_tmp.source_context%TYPE := 'RESOURCE_ASSIGNMENT';

    l_delete_budget_lines_tab         SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
    l_spread_amts_flag_tab            SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
    l_txn_currency_code_tab           SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
    l_txn_currency_override_tab       SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
    l_total_qty_tab                   SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_addl_qty_tab                    SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_total_raw_cost_tab              SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_addl_raw_cost_tab               SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_total_burdened_cost_tab         SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_addl_burdened_cost_tab          SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_total_revenue_tab               SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_addl_revenue_tab                SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_raw_cost_rate_tab               SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_rw_cost_rate_override_tab       SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_b_cost_rate_tab                 SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_b_cost_rate_override_tab        SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();


    l_bill_rate_tab                   SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_bill_rate_override_tab          SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_line_start_date_tab             SYSTEM.pa_date_tbl_type:=SYSTEM.pa_date_tbl_type();
    l_line_end_date_tab               SYSTEM.pa_date_tbl_type:=SYSTEM.pa_date_tbl_type();

    l_stru_sharing_code               PA_PROJECTS_ALL.STRUCTURE_SHARING_CODE%TYPE;
    l_count                           NUMBER;
    l_count1                          NUMBER;
    l_gen_res_asg_id_tab              PA_PLSQL_DATATYPES.IdTabTyp;
    l_chk_duplicate_flag              VARCHAR2(1) := 'N';
    l_deleted_res_asg_id_tab          PA_PLSQL_DATATYPES.IdTabTyp;

    l_resource_class_id               PA_RESOURCE_CLASSES_B.RESOURCE_CLASS_ID%TYPE;
    l_dp_counter              NUMBER;
    l_dp_flag                 VARCHAR2(1);

    tmp_flag            varchar2(1);
    tmp_rlm_tab         pa_plsql_datatypes.IdTabTyp;
    tmp_task_tab                pa_plsql_datatypes.IdTabTyp;
    tmp_ra_tab                  pa_plsql_datatypes.IdTabTyp;

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
l_map_txn_source_id_tab     PA_PLSQL_DATATYPES.IdTabTyp;
l_map_rlm_id_tab            PA_PLSQL_DATATYPES.IdTabTyp;
l_map_rbs_element_id_tab        PA_PLSQL_DATATYPES.IdTabTyp;
l_map_txn_accum_header_id_tab   PA_PLSQL_DATATYPES.IdTabTyp;

    --Local PL/SQL table used for calling Calculate API
    l_t_refresh_rates_flag              VARCHAR2(1) := 'Y';
    l_t_refresh_conv_rates_flag         VARCHAR2(1) := 'N';
    l_t_spread_required_flag            VARCHAR2(1) := 'N';
    l_t_conv_rates_required_flag        VARCHAR2(1) := 'N';
    l_t_mass_adjust_flag                VARCHAR2(1) := 'N';
    l_t_quantity_adj_pct                NUMBER   := NULL;
    l_t_cost_rate_adj_pct               NUMBER   := NULL;
    l_t_burdened_rate_adj_pct           NUMBER   := NULL;
    l_t_bill_rate_adj_pct               NUMBER   := NULL;
    l_t_source_context                  pa_fp_res_assignments_tmp.source_context%TYPE := 'RESOURCE_ASSIGNMENT';

    l_t_res_assgn_id_tmp_tab            SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_t_delete_budget_lines_tab         SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
    l_t_spread_amts_flag_tab            SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
    l_t_txn_currency_code_tab           SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
    l_t_txn_currency_override_tab       SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
    l_t_total_qty_tab                   SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_t_addl_qty_tab                    SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_t_total_raw_cost_tab              SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_t_addl_raw_cost_tab               SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_t_total_burdened_cost_tab         SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_t_addl_burdened_cost_tab          SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_t_total_revenue_tab               SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_t_addl_revenue_tab                SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_t_raw_cost_rate_tab               SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_t_rw_cost_rate_override_tab       SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_t_b_cost_rate_tab                 SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_t_b_cost_rate_override_tab        SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();


    l_t_bill_rate_tab                   SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_t_bill_rate_override_tab          SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_t_line_start_date_tab             SYSTEM.pa_date_tbl_type:=SYSTEM.pa_date_tbl_type();
    l_t_line_end_date_tab               SYSTEM.pa_date_tbl_type:=SYSTEM.pa_date_tbl_type();

    l_bl_count                          NUMBER;
    l_transaction_source_code           PA_RESOURCE_ASSIGNMENTS.TRANSACTION_SOURCE_CODE%TYPE;

    -- Bug 4548733: Added new pl/sql table to hold billability flag values for
    -- Calculate API. Corresponds to p_fp_task_billable_flag_tab IN parameter.
    l_calc_billable_flag_tab            SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();

    -- Bug 4549862: Added counter to track unique budget_line_id values for
    -- the PA_FP_ROLLUP_TMP table. Will be arbitrarily initialized to 0 and
    -- then incremented by 1 prior to each Insert to the temp table.
    -- Note: these are not valid budget_line_id values in pa_budget_lines.
    -- Rather, we are using the column to index records for processing of
    -- cost-based revenue amounts, since an Index exists for the column.
    l_bl_id_counter                    NUMBER;

    -- Bug 4549862: Added pl/sql tables for budget line update.
    l_upd_bl_start_date_tab            PA_PLSQL_DATATYPES.DateTabTyp;
    l_upd_bl_end_date_tab              PA_PLSQL_DATATYPES.DateTabTyp;
    l_upd_bl_RES_ASSIGNMENT_ID_tab     SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_upd_bl_PERIOD_NAME_tab           SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
    l_upd_bl_QUANTITY_tab              SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_upd_bl_TXN_CURRENCY_CODE_tab     SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
    l_upd_bl_TXN_RAW_COST_tab          SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_upd_bl_TXN_BURDENED_COST_tab     SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_upd_bl_TXN_REVENUE_tab           SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_upd_bl_BILL_MARKUP_PRCNT_tab     SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
    l_upd_bl_COST_REJ_CODE_tab         SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
    l_upd_bl_BURDEN_REJ_CODE_tab       SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
    l_upd_bl_REV_REJ_CODE_tab          SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
    l_upd_bl_COST_IND_C_SET_ID_tab     SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();

    -- Bug 4549862: PL/SQL tables for rejection code processing
    l_rej_code_ra_id_tab            PA_PLSQL_DATATYPES.IdTabTyp;
    l_rej_code_txn_currency_tab     PA_PLSQL_DATATYPES.Char15TabTyp;
    l_rej_code_msg_name_tab         PA_PLSQL_DATATYPES.Char30TabTyp;

BEGIN
    /* Setting the initial values */
     IF p_init_msg_flag = 'Y' THEN
       FND_MSG_PUB.initialize;
     END IF;
     X_MSG_COUNT := 0;
     X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

     IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
         PA_DEBUG.init_err_stack('PA_FP_GEN_BUDGET_AMT_PUB.GENERATE_BUDGET_AMT_RES_SCH');
     ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
              pa_debug.set_curr_function( p_function     => 'GENERATE_BUDGET_AMT_RES_SCH'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
     END IF;

     -- Bug 4549862: Added counter to track unique budget_line_id values for
     -- the PA_FP_ROLLUP_TMP table. Will be arbitrarily initialized to 0 and
     -- then incremented by 1 prior to each Insert to the temp table.
     l_bl_id_counter := 0;

     -- Bug 4549862: Moved initialization of l_rev_gen_method before
     -- initialization of l_calculate_mode.

     --l_rev_gen_method := PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(p_project_id);
     l_rev_gen_method := nvl(l_fp_cols_rec.x_revenue_derivation_method,PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(p_project_id)); --Bug 5462471

     -- M-closeout: Bill Rate Override ER ------------------------------------------

     -- Check whether there exist at least 1 project assignment with
     -- bill rate override in the project.
     OPEN CHECK_BILL_RATE_OVRD_EXISTS;
     FETCH CHECK_BILL_RATE_OVRD_EXISTS INTO l_bill_rate_ovrd_exists_flag;
     CLOSE CHECK_BILL_RATE_OVRD_EXISTS;

     -- Only need to honor bill rate override and
     -- call rate API IF:
     --  a) version type is COST and REVENUE and,
     --  b) there is at least 1 project asgmt with
     --     bill rate override in the project.

     -- Bug 4549862: Modified IF condition so that the code also proceeds
     -- along the Rate API flow when target version is ALL and revenue
     -- accrual method is COST.

     IF p_fp_cols_rec.x_version_type = 'ALL' AND
      ( l_bill_rate_ovrd_exists_flag = 'Y' OR l_rev_gen_method = 'C' ) THEN

       OPEN GET_RATE_API_PARAMS_CUR;
       FETCH GET_RATE_API_PARAMS_CUR INTO rate_rec;
       CLOSE GET_RATE_API_PARAMS_CUR;

     END IF;

     -- Bug 4549862: Modified logic for initializing l_calculate_mode
     -- to 'COST'. When the version type is Cost and Revenue together
     -- and the revenue accrual method is COST or EVENT, we will be
     -- generating revenue amounts using either GEN_COST_BASED_REVENUE
     -- or GEN_BILLING_AMOUNTS, respectively. Setting l_calculate_mode
     -- to 'COST' in these cases will tell the Rate API to return only
     -- cost rates when it is called later in this API.

     IF p_fp_cols_rec.x_version_type = 'REVENUE' THEN
        l_calculate_mode  := 'REVENUE';
     ELSIF p_fp_cols_rec.x_version_type = 'COST' OR
         ( p_fp_cols_rec.x_version_type = 'ALL'  AND
           l_rev_gen_method IN ('C','E') ) THEN
        l_calculate_mode  := 'COST';
     ELSIF p_fp_cols_rec.x_version_type = 'ALL' THEN
        -- Bug 4549862: l_rev_gen_method is implicitly 'T' in this case.
        l_calculate_mode  := 'COST_REVENUE';
     END IF;

     -- Final Currency:
     -- a. For Approved Revenue, final currency = PFC
     -- b. If multi-currency is disabled, final currency = PC
     IF rate_rec.approved_rev_plan_type_flag  = 'Y' THEN
    l_Final_Txn_Currency_Code := rate_rec.projfunc_currency_code;
     ELSIF rate_rec.plan_in_multi_curr_flag = 'N' THEN
    l_Final_Txn_Currency_Code := rate_rec.project_currency_code;
     ELSE
    l_Final_Txn_Currency_Code := NULL;
     END IF;

     -- END of M-closeout: Bill Rate Override ER ----------------------------------

     /*Bug 4197666: when ret_manual_lines flag is 'N', budget lines and resource assignments
       are deleted completely for the target version. when ret_manual_lines flag is 'Y', for
       budget version,all budget lines that under resource assignment whose transaction source
       code is NOT NULL should be deleted. for forecast version, 'P' and 'G' time phased, all
       ETC budget lines should be deleted; 'N' time phased, ETC should be deleted or negated.*/
     IF p_fp_cols_rec.x_gen_ret_manual_line_flag = 'Y' THEN
        IF P_PLAN_CLASS_CODE = 'BUDGET' THEN
            DELETE FROM pa_budget_lines
            WHERE budget_version_id = p_budget_version_id
            AND budget_line_id IN
               (SELECT bl.budget_line_id
                FROM pa_budget_lines bl, pa_resource_assignments ra
                WHERE ra.budget_version_id = p_budget_version_id
                AND bl.budget_version_id = p_budget_version_id
                AND ra.transaction_source_code IS NOT NULL
                AND ra.resource_assignment_id = bl.resource_assignment_id);
        ELSIF P_PLAN_CLASS_CODE = 'FORECAST' THEN
            IF P_FP_COLS_REC.x_time_phased_code IN ('P','G') THEN
                DELETE FROM pa_budget_lines
                WHERE budget_version_id = p_budget_version_id
                AND budget_line_id IN
                   (SELECT bl.budget_line_id
                    FROM pa_budget_lines bl, pa_resource_assignments ra
                    WHERE ra.budget_version_id = p_budget_version_id
                    AND bl.budget_version_id = p_budget_version_id
                    AND ra.transaction_source_code IS NOT NULL
                    AND ra.resource_assignment_id = bl.resource_assignment_id
                    AND bl.start_date > p_actuals_thru_date);
            ELSE
                DELETE FROM pa_budget_lines
                WHERE budget_version_id = p_budget_version_id
                AND NVL(init_quantity,0) = 0
                AND NVL(init_raw_cost,0) = 0
                AND NVL(init_burdened_cost,0) = 0
                AND NVL(init_revenue,0) = 0;

                UPDATE pa_budget_lines
                SET quantity = init_quantity,
                    txn_raw_cost = txn_init_raw_cost,
                    txn_burdened_cost = txn_init_burdened_cost,
                    txn_revenue = txn_init_revenue,
                    project_raw_cost = project_init_raw_cost,
                    project_burdened_cost = project_init_burdened_cost,
                    project_revenue = project_init_revenue,
                    raw_cost = init_raw_cost,
                    burdened_cost = init_burdened_cost,
                    revenue = init_revenue,
                    txn_cost_rate_override = DECODE(NVL(init_quantity,0),0,NULL,txn_init_raw_cost/init_quantity),
                    txn_bill_rate_override = DECODE(NVL(init_quantity,0),0,NULL,txn_init_revenue/init_quantity),
                    project_cost_exchange_rate = DECODE(NVL(txn_init_raw_cost,0),0,NULL,project_init_raw_cost/txn_init_raw_cost),
                    project_rev_exchange_rate = DECODE(NVL(txn_init_revenue,0),0,NULL,project_init_revenue/txn_init_revenue),
                    projfunc_cost_exchange_rate = DECODE(NVL(txn_init_raw_cost,0),0,NULL,init_raw_cost/txn_init_raw_cost),
                    projfunc_rev_exchange_rate = DECODE(NVL(txn_init_revenue,0),0,NULL,init_revenue/txn_init_revenue)
                WHERE budget_version_id = p_budget_version_id
                AND budget_line_id IN
                   (SELECT bl.budget_line_id
                    FROM pa_budget_lines bl, pa_resource_assignments ra
                    WHERE ra.budget_version_id = p_budget_version_id
                    AND bl.budget_version_id = p_budget_version_id
                    AND ra.transaction_source_code IS NOT NULL
                    AND ra.resource_assignment_id = bl.resource_assignment_id);
            END IF;
        END IF;
     END IF;

     l_sysdate_trunc := trunc(sysdate);
     /* l_role_error_code_flag is used here
        for only checking whether to continue
        with forecasting process or not */
     l_role_error_code_flag := 'N';
     OPEN PROJ_DETAILS;
     FETCH PROJ_DETAILS INTO
               l_project_type,
               l_project_currency_code,
               l_carrying_out_organization_id,
               l_project_value,
               l_job_bill_rate_schedule_id,
               l_emp_bill_rate_schedule_id,
               l_distribution_rule,
               l_bill_job_group_id,
               l_org_id,
               l_completion_date,
               l_template_flag,
               l_projfunc_currency_code,
               l_projfunc_bil_rate_date_code,
               l_projfunc_bil_rate_type,
               l_projfunc_bil_rate_date,
               l_projfunc_bil_exchange_rate,
               l_cost_job_group_id,
               l_prj_rate_date,
               l_prj_rate_type,
               l_prj_bil_rate_date_code,
               l_prj_bil_rate_type,
               l_prj_bil_rate_date,
               l_prj_bil_ex_rate,
               l_prjfunc_cost_rate_type,
               l_prjfunc_cost_rate_date,
               l_labor_tp_schedule_id,
               l_labor_tp_fixed_date,
               l_labor_sch_discount,
               l_asg_precedes_task,
               l_labor_bill_rate_orgid,
               l_labor_std_bill_rate_sch,
               l_labor_sch_fixed_dt,
               l_labor_sch_type;

        IF    PROJ_DETAILS%NOTFOUND    THEN
             x_return_status        := FND_API.G_RET_STS_ERROR;
             l_role_error_code_flag := 'Y';
             PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_INVALID_PROJECT_ID');
        END IF;

        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
     CLOSE PROJ_DETAILS;

     -- Bug 4549862: REMOVED call to Get_Revenue_Generation_Method API.
     -- Added initialization of l_rev_gen_method at the beginning of
     -- this API using the GET_REV_GEN_METHOD wrapper API.

    /* Set plan processing code to G - G(enerated Successfully)   */

    l_plan_processing_code := 'G';
    l_budget_lines_tot_tbl.DELETE;

     OPEN PROJ_ASSIGNMENTS;
     FETCH PROJ_ASSIGNMENTS
     BULK  COLLECT INTO     l_proj_assignment_id,
                            l_proj_start_date,
                            l_proj_resource_id,
                            l_proj_project_role_id,
                            l_proj_fcst_job_id,
                            l_proj_fcst_job_group_id,
                            l_proj_meaning,
                            l_proj_assignment_type,
                            l_proj_exp_organization_id,
                            l_proj_exp_type,
                            l_proj_revenue_bill_rate,
                            l_proj_expenditure_org_id,
                            l_proj_status_code,
                            l_proj_billable_flag,
                l_proj_process_code,
                l_proj_error_msg_code,
                            l_proj_end_date,
                            l_proj_person_id,
                            l_proj_named_role,
                l_fi_exp_organization_id,
                            l_proj_fc_res_type_code;
    CLOSE PROJ_ASSIGNMENTS;

     FOR i IN 1..l_proj_person_id.count LOOP
         l_person_type_code_tab(i) := NULL;
         l_vendor_id_tab(i) := NULL;
         IF l_proj_person_id(i) IS NOT NULL THEN
             BEGIN
                 SELECT p_type.SYSTEM_PERSON_TYPE
                   INTO l_person_type_code_tab(i)
                 FROM PER_PERSON_TYPES p_type,
                      PER_PERSON_TYPE_USAGES_F p_usg
                 WHERE p_type.SYSTEM_PERSON_TYPE IN ('EMP', 'CWK')
                   AND p_type.PERSON_TYPE_ID = p_usg.PERSON_TYPE_ID
                   AND l_proj_person_id(i) = p_usg.PERSON_ID
                   AND l_proj_start_date(i) BETWEEN p_usg.EFFECTIVE_START_DATE AND p_usg.EFFECTIVE_END_DATE;
             EXCEPTION
                 WHEN OTHERS THEN
                     l_person_type_code_tab(i) := NULL;
             END;
             BEGIN
                 SELECT p_asg.vendor_id
                   INTO l_vendor_id_tab(i)
                 FROM PER_ALL_ASSIGNMENTS_F p_asg
                 WHERE l_proj_person_id(i) = p_asg.PERSON_ID
                   AND l_proj_start_date(i) BETWEEN p_asg.EFFECTIVE_START_DATE AND p_asg.EFFECTIVE_END_DATE
                   AND p_asg.PRIMARY_FLAG = 'Y';
             EXCEPTION
                 WHEN OTHERS THEN
                     l_vendor_id_tab(i) := NULL;
             END;
         END IF;
     END LOOP;

     --hr_utility.trace('l_proj_assignment_id.count:'||l_proj_assignment_id.count);
     IF p_pa_debug_mode = 'Y' THEN
         pa_fp_gen_amount_utils.fp_debug
            (p_called_mode => p_called_mode,
             p_msg         => 'l_proj_assignment_id.count:'||l_proj_assignment_id.count,
             p_module_name => l_module_name,
             p_log_level   => 5);
     END IF;

     if l_proj_resource_id.count = 0 then
        IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
            PA_DEBUG.reset_err_stack;
        ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        return;
     end if;

    /* code to populate to job and/or job group id is null */
     FOR i IN 1..l_proj_resource_id.count LOOP
     IF (l_proj_fcst_job_id(i) IS NULL)
            OR (l_proj_fcst_job_group_id(i) IS NULL) THEN
             BEGIN
                 SELECT   PR.DEFAULT_JOB_ID,PJ.JOB_GROUP_ID
                 INTO     l_proj_fcst_job_id(i),l_proj_fcst_job_group_id(i)
                 FROM     PA_PROJECT_ROLE_TYPES PR, PER_JOBS PJ
                 WHERE    PR.PROJECT_ROLE_ID = l_proj_project_role_id(i)
                 AND      PJ.JOB_ID          = PR.DEFAULT_JOB_ID;
             EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                 l_proj_process_code(i) := 'N';
                 l_proj_error_msg_code(i) := 'N';
             END;
         END IF;
      END LOOP;

    DELETE FROM PA_RES_LIST_MAP_TMP1;
    DELETE FROM PA_RES_LIST_MAP_TMP4;

        l_TXN_SOURCE_ID_tab            := l_proj_assignment_id;
        l_PERSON_ID_tab                := l_proj_person_id;
        l_JOB_ID_tab                   := l_proj_fcst_job_id;
        l_ORGANIZATION_ID_tab          := l_fi_exp_organization_id;
        l_EXPENDITURE_TYPE_tab         := l_proj_exp_type;
        l_PROJECT_ROLE_ID_tab          := l_proj_project_role_id;
        l_FC_RES_TYPE_CODE_tab         := l_proj_fc_res_type_code;
        l_NAMED_ROLE_tab               := l_proj_named_role;
        l_TXN_PLAN_START_DATE_tab      := l_proj_start_date;
        l_TXN_PLAN_END_DATE_tab        := l_proj_end_date;

    FOR bb in 1..l_TXN_SOURCE_ID_tab.count LOOP
        l_TXN_SOURCE_TYPE_CODE_tab(bb) := null;
        l_EVENT_TYPE_tab(bb)           := null;
        l_NON_LABOR_RESOURCE_tab(bb)   := null;
        l_EXPENDITURE_CATEGORY_tab(bb) := null;
        l_REVENUE_CATEGORY_CODE_tab(bb):= null;
        l_NLR_ORGANIZATION_ID_tab(bb)  := null;
        l_EVENT_CLASSIFICATION_tab(bb) := null;
        l_SYS_LINK_FUNCTION_tab(bb)    := null;
        l_RESOURCE_CLASS_CODE_tab(bb)  := 'PEOPLE';
        l_MFC_COST_TYPE_ID_tab(bb)     := null;
        l_RESOURCE_CLASS_FLAG_tab(bb)  := null;
        l_INVENTORY_ITEM_ID_tab(bb)    := null;
        l_ITEM_CATEGORY_ID_tab(bb)     := null;
        l_BOM_RESOURCE_ID_tab(bb)      := null;
        l_INCURRED_BY_RES_FLAG_tab(bb) := null;
        l_RATE_BASED_FLAG_tab(bb)      := null;
        l_TXN_TASK_ID_tab(bb)          := null;
        l_TXN_WBS_ELEMENT_VER_ID_tab(bb):= null;
        l_TXN_RBS_ELEMENT_ID_tab(bb)   := null;
       END LOOP;

    IF P_PA_DEBUG_MODE = 'Y' THEN
    PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_MSG           => 'Before calling PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS',
            P_MODULE_NAME   => l_module_name);
    END IF;
    PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS (
         P_PROJECT_ID                   => p_project_id,
     P_BUDGET_VERSION_ID        => NULL,
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

   /* Added return status check for bug 4093872 */
   IF x_return_status <> 'S' THEN
        RAISE  PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
   END IF;

          SELECT /*+ INDEX(T,PA_RES_LIST_MAP_TMP4_N1)*/ count(*) INTO l_count
          FROM PA_RES_LIST_MAP_TMP4
          WHERE RESOURCE_LIST_MEMBER_ID IS NULL and rownum=1;
          IF l_count > 0 THEN
              PA_UTILS.ADD_MESSAGE
                     (p_app_short_name => 'PA',
                      p_msg_name       => 'PA_INVALID_MAPPING_ERR');
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;

          SELECT count(*) INTO l_count
          FROM PA_RES_LIST_MAP_TMP4;
          IF p_pa_debug_mode = 'Y' THEN
              pa_fp_gen_amount_utils.fp_debug
                (p_called_mode => p_called_mode,
                p_msg         => 'After calling pa_resource_mapping.map_resource_list,'||
            'pa_res_list_map_tmp4.count has '||l_count||' rows',
                p_module_name => l_module_name,
                p_log_level   => 5);
          END IF;


       /* Calling the API to get the resource_assignment_id */
           IF p_pa_debug_mode = 'Y' THEN
                 pa_fp_gen_amount_utils.fp_debug
                       (p_called_mode => p_called_mode,
                        p_msg         => 'Before calling
                        pa_fp_gen_budget_amt_pub.create_res_asg',
                        p_module_name => l_module_name,
                        p_log_level   => 5);
           END IF;

           PA_FP_GEN_BUDGET_AMT_PUB.CREATE_RES_ASG
             (P_PROJECT_ID               => P_PROJECT_ID,
              P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
              P_STRU_SHARING_CODE        => l_stru_sharing_code,
          P_GEN_SRC_CODE             => 'RESOURCE_SCHEDULE',
              P_FP_COLS_REC              => p_FP_COLS_REC,
              X_RETURN_STATUS            => X_RETURN_STATUS,
              X_MSG_COUNT                => X_MSG_COUNT,
              X_MSG_DATA             => X_MSG_DATA);
           IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;
           IF p_pa_debug_mode = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
                   (p_called_mode => p_called_mode,
                    p_msg         => 'Status after calling
                              pa_fp_gen_budget_amt_pub.create_res_asg: '
                              ||x_return_status,
                    p_module_name => l_module_name,
                    p_log_level   => 5);
          END IF;

    /* Calling the API to update the tmp4
       table with resource_assignment_id */
         IF p_pa_debug_mode = 'Y' THEN
              pa_fp_gen_amount_utils.fp_debug
                  (p_called_mode => p_called_mode,
                   p_msg         => 'Before calling
                   pa_fp_gen_budget_amt_pub.update_res_asg',
                   p_module_name => l_module_name,
                   p_log_level   => 5);
        END IF;
        PA_FP_GEN_BUDGET_AMT_PUB.UPDATE_RES_ASG
           (P_PROJECT_ID               => P_PROJECT_ID,
            P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
            P_STRU_SHARING_CODE        => l_stru_sharing_code,
        P_GEN_SRC_CODE             => 'RESOURCE_SCHEDULE',
            P_FP_COLS_REC              => p_FP_COLS_REC,
            X_RETURN_STATUS            => X_RETURN_STATUS,
            X_MSG_COUNT                => X_MSG_COUNT,
            X_MSG_DATA                 => X_MSG_DATA);
       IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;
       IF p_pa_debug_mode = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
                  (p_called_mode => p_called_mode,
                   p_msg         => 'Status after calling
                   pa_fp_gen_budget_amt_pub.update_res_asg: '
                                         ||x_return_status,
                   p_module_name => l_module_name,
                   p_log_level   => 5);
       END IF;

    -- Bug 4549862: REMOVED old code for retaining manually added
    -- lines that was already commented out to reduce clutter.

    l_proj_res_assgn_id_tab.delete;
    l_proj_exp_organization_id_tab.delete;
    l_proj_assgn_id_tab.delete;
    l_proj_bill_rate_override_tab.delete;
    l_proj_bill_rate_cur_ovrd_tab.delete;

    SELECT  tmp4.TXN_SOURCE_ID,
            tmp4.ORGANIZATION_ID,
            tmp4.TXN_RESOURCE_ASSIGNMENT_ID,
            PA.BILL_RATE_OVERRIDE,                   -- M-Closeout ER:  Bill Rate Override ER
            PA.BILL_RATE_CURR_OVERRIDE,              -- M-Closeout ER:  Bill Rate Override ER
            nvl(WB.BILLABLE_CAPITALIZABLE_FLAG, 'N') -- M-Closeout ER:  Honor billability flag ER
    BULK    COLLECT
    INTO    l_proj_assgn_id_tab,
            l_proj_exp_organization_id_tab,
            l_proj_res_assgn_id_tab,
            l_proj_bill_rate_override_tab,  -- M-Closeout ER:  Bill Rate Override ER
            l_proj_bill_rate_cur_ovrd_tab,  -- M-Closeout ER:  Bill Rate Override ER
            l_proj_billable_flag            -- M-Closeout ER:  Honor billability flag ER
    FROM    PA_RES_LIST_MAP_TMP4 tmp4,
            PA_PROJECT_ASSIGNMENTS PA,
            PA_WORK_TYPES_B WB
    WHERE   tmp4.txn_source_id = pa.assignment_id
      AND   WB.WORK_TYPE_ID = PA.WORK_TYPE_ID(+);

    --dbms_output.put_line('From tmp4, l_proj_assgn_id_tab:'||l_proj_assgn_id_tab.count
    --                   ||';l_proj_res_assgn_id_tab.count:'||l_proj_res_assgn_id_tab.count);
    IF p_pa_debug_mode = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
                   (p_called_mode => p_called_mode,
                    p_msg         => 'From tmp4, l_proj_assgn_id_tab.count:'||l_proj_assgn_id_tab.count
                     ||';l_proj_res_assgn_id_tab.count:'||l_proj_res_assgn_id_tab.count,
                    p_module_name => l_module_name,
                    p_log_level   => 5);
    END IF;

    -- M-closeout: Bill Rate Override ER ------------------------------------------

    --   IF it is a COST and REVENUE budget or forecast AND
    --   there exist at least 1 project assignment with
    --   bill rate override in the whole project, honor bill rate
    --   override and call rate API

    -- Bug 4549862: Modified IF condition so that the code also proceeds
    -- along the Rate API flow when target version is ALL and revenue
    -- accrual method is COST.
    -- The goal is to populate the PA_FP_ROLLUP_TMP global temp table
    -- with generation data and then let control return to the Budget
    -- or Forecast wrapper API without propagating data to the budget
    -- lines. The GEN_COST_BASED_REVENUE API will expect data in the
    -- temp table, which it will use to compute revenue amounts. The
    -- cost-based revenue API will propagate data from the temp table
    -- to the budget lines. Before the cost-based revenue API is called
    -- (e.g. in GEN_COMMITMENT_AMOUNTS), inserts/updates to the budget
    -- lines should go to the PA_FP_ROLLUP_TMP table instead so that
    -- the cost-based revenue API has all of the necessary data in the
    -- temp table when it is called.
    -- Note: this info only applies when generating ALL versions from
    -- Staffing Plan with revenue accrual method of COST.

    IF p_fp_cols_rec.x_version_type = 'ALL' AND
     ( l_bill_rate_ovrd_exists_flag = 'Y' OR l_rev_gen_method = 'C' ) THEN

      IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                   (p_called_mode => p_called_mode,
                    p_msg         => 'Honoring bill rate override and call Rate API',
                    p_module_name => l_module_name,
                    p_log_level   => 5);
      END IF;

      DELETE FROM pa_fp_rollup_tmp;

      FOR j IN 1..l_proj_assgn_id_tab.count LOOP
         --dbms_output.put_line('before cursor:l_proj_res_assgn_id_tab('||j
         --              ||'):'||l_proj_res_assgn_id_tab(j)
         --          ||';p_actuals_thru_date:'||p_actuals_thru_date);
         IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                   (p_called_mode => p_called_mode,
                    p_msg         => 'before cursor:l_proj_assgn_id_tab('||j
                     ||'):'||l_proj_assgn_id_tab(j)
                     ||';p_actuals_thru_date:'||p_actuals_thru_date,
                    p_module_name => l_module_name,
                    p_log_level   => 5);

         END IF;

         l_budget_lines_tbl.delete;
         l_rt_forecast_item_id_tab.delete;
         l_rt_pd_name_tab.delete;
         l_rt_start_date_tab.delete;
         l_rt_end_date_tab.delete;
         l_rt_qty_tab.delete;
         l_rt_res_assignment_id_tab.delete;
         l_rt_uom_tab.delete;
         l_rt_res_class_code_tab.delete;
         l_rt_organization_id_tab.delete;
         l_rt_job_id_tab.delete;
         l_rt_person_id_tab.delete;
         l_rt_expenditure_type_tab.delete;
         l_rt_non_labor_resource_tab.delete;
         l_rt_bom_resource_id_tab.delete;
         l_rt_inventory_item_id_tab.delete;
         l_rt_item_category_id_tab.delete;
         l_rt_mfc_cost_type_id_tab.delete;
         l_rt_rate_expenditure_type_tab.delete;
         l_rt_rate_based_flag_tab.delete;
         l_rt_rate_exp_org_id_tab.delete;
         l_rt_res_format_id_tab.delete;

         --    0. Execute SQLs (FCST_RATE_PA, FCST_RATE_GL, FCST_RATE_NONE cursors) to
         --       determine the qty and rate API parameters per period
         --    1. Get PA_PLAN_REVENUE.GET_PLANNING_RATES API IN parameter values

         IF p_FP_COLS_REC.X_TIME_PHASED_CODE = 'P' THEN
            OPEN FCST_RATE_PA(l_proj_assgn_id_tab(j),p_actuals_thru_date,l_proj_exp_organization_id_tab(j), l_org_id);
            FETCH FCST_RATE_PA BULK COLLECT INTO
             l_rt_exp_org_id_tab,
             l_rt_exp_organization_id_tab,
             l_rt_pd_name_tab,
             l_rt_start_date_tab,
             l_rt_end_date_tab,
             l_rt_qty_tab,
             l_rt_forecast_item_id_tab,
             l_rt_res_assignment_id_tab,
             l_rt_uom_tab,
             l_rt_res_class_code_tab,
             l_rt_organization_id_tab,
             l_rt_job_id_tab,
             l_rt_person_id_tab,
             l_rt_expenditure_type_tab,
             l_rt_non_labor_resource_tab,
             l_rt_bom_resource_id_tab,
             l_rt_inventory_item_id_tab,
             l_rt_item_category_id_tab,
             l_rt_mfc_cost_type_id_tab,
             l_rt_rate_expenditure_type_tab,
             l_rt_rate_based_flag_tab,
             l_rt_rate_exp_org_id_tab,
             l_rt_res_format_id_tab,
             l_rt_res_list_member_id_tab,
             l_rt_resource_id_tab,
             l_rt_resource_list_id_tab,
             l_rt_alias_tab;
            CLOSE FCST_RATE_PA;

         ELSIF p_FP_COLS_REC.X_TIME_PHASED_CODE = 'G' THEN
            OPEN FCST_RATE_GL(l_proj_assgn_id_tab(j),p_actuals_thru_date,l_proj_exp_organization_id_tab(j));
            FETCH FCST_RATE_GL BULK COLLECT INTO
             l_rt_exp_org_id_tab,
             l_rt_exp_organization_id_tab,
             l_rt_pd_name_tab,
             l_rt_start_date_tab,
             l_rt_end_date_tab,
             l_rt_qty_tab,
             l_rt_forecast_item_id_tab,
             l_rt_res_assignment_id_tab,
             l_rt_uom_tab,
             l_rt_res_class_code_tab,
             l_rt_organization_id_tab,
             l_rt_job_id_tab,
             l_rt_person_id_tab,
             l_rt_expenditure_type_tab,
             l_rt_non_labor_resource_tab,
             l_rt_bom_resource_id_tab,
             l_rt_inventory_item_id_tab,
             l_rt_item_category_id_tab,
             l_rt_mfc_cost_type_id_tab,
             l_rt_rate_expenditure_type_tab,
             l_rt_rate_based_flag_tab,
             l_rt_rate_exp_org_id_tab,
             l_rt_res_format_id_tab,
             l_rt_res_list_member_id_tab,
             l_rt_resource_id_tab,
             l_rt_resource_list_id_tab,
             l_rt_alias_tab;
            CLOSE FCST_RATE_GL;

         ELSE
            OPEN FCST_RATE_NONE(l_proj_assgn_id_tab(j),p_actuals_thru_date,l_proj_exp_organization_id_tab(j));
            FETCH FCST_RATE_NONE BULK COLLECT INTO
             l_rt_exp_org_id_tab,
             l_rt_exp_organization_id_tab,
             l_rt_qty_tab,
             l_rt_forecast_item_id_tab,
             l_rt_pd_name_tab,
             l_rt_start_date_tab,
             l_rt_end_date_tab,
             l_rt_res_assignment_id_tab,
             l_rt_uom_tab,
             l_rt_res_class_code_tab,
             l_rt_organization_id_tab,
             l_rt_job_id_tab,
             l_rt_person_id_tab,
             l_rt_expenditure_type_tab,
             l_rt_non_labor_resource_tab,
             l_rt_bom_resource_id_tab,
             l_rt_inventory_item_id_tab,
             l_rt_item_category_id_tab,
             l_rt_mfc_cost_type_id_tab,
             l_rt_rate_expenditure_type_tab,
             l_rt_rate_based_flag_tab,
             l_rt_rate_exp_org_id_tab,
             l_rt_res_format_id_tab,
             l_rt_res_list_member_id_tab,
             l_rt_resource_id_tab,
             l_rt_resource_list_id_tab,
             l_rt_alias_tab;
            CLOSE FCST_RATE_NONE;

         END IF;

         --    2. Call PA_PLAN_REVENUE.GET_PLANNING_RATES API based on periodic data
         --       in PA/GL periods. Need to also pass in billability flag.  (Project
         --       assignments with different bill rate override currency are mapped
         --       to different budget lines.)
         FOR k in 1..l_rt_start_date_tab.COUNT LOOP

           IF p_pa_debug_mode = 'Y' THEN
              pa_fp_gen_amount_utils.fp_debug
                   (p_called_mode => p_called_mode,
                    p_msg         => 'inside FOR k in 1..l_rt_start_date_tab.COUNT LOOP ('||k
                     ||'):'||l_rt_start_date_tab(k),
                    p_module_name => l_module_name,
                    p_log_level   => 5);
           END IF;

           pa_cost.Override_exp_organization
                                (P_item_date                  => l_rt_start_date_tab(k)
                                ,P_person_id                  => l_rt_person_id_tab(k)
                                ,P_project_id                 => p_project_id
                                ,P_incurred_by_organz_id      => l_rt_organization_id_tab(k)
                                ,P_Expenditure_type           => NVL(l_rt_expenditure_type_tab(k),l_rt_rate_expenditure_type_tab(k))
                                ,X_overr_to_organization_id   => l_override_organization_id
                                ,X_return_status              => l_return_status
                                ,X_msg_count                  => x_msg_count
                                ,X_msg_data                   => x_msg_data);

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             x_return_status := l_return_status;
           END IF;

           BEGIN

             IF l_proj_bill_rate_cur_ovrd_tab(j) IS NOT NULL THEN
               l_txn_currency_code := l_proj_bill_rate_cur_ovrd_tab(j);
             ELSE
               l_txn_currency_code := rate_rec.project_currency_code;
             END IF;

             IF p_pa_debug_mode = 'Y' THEN

              pa_fp_gen_amount_utils.fp_debug
                   (p_called_mode => p_called_mode,
                    p_msg         => 'BEFORE calling pa_plan_revenue.Get_planning_Rates',
                    p_module_name => l_module_name,
                    p_log_level   => 5);
              pa_fp_gen_amount_utils.fp_debug
                   (p_called_mode => p_called_mode,
                    p_msg         => 'p_person_id:'||l_rt_person_id_tab(k),
                    p_module_name => l_module_name,
                    p_log_level   => 5);
              pa_fp_gen_amount_utils.fp_debug
                   (p_called_mode => p_called_mode,
                    p_msg         => 'p_job_id:'||l_rt_job_id_tab(k),
                    p_module_name => l_module_name,
                    p_log_level   => 5);
              pa_fp_gen_amount_utils.fp_debug
                   (p_called_mode => p_called_mode,
                    p_msg         => 'p_bill_job_grp_id:'||rate_rec.bill_job_group_id,
                    p_module_name => l_module_name,
                    p_log_level   => 5);
              pa_fp_gen_amount_utils.fp_debug
                   (p_called_mode => p_called_mode,
                    p_msg         => 'p_resource_class:'||l_rt_res_class_code_tab(k),
                    p_module_name => l_module_name,
                    p_log_level   => 5);
             END IF;

             -- Bug 4548733: Uncommented the p_billability_flag input parameter,
             -- passing it l_proj_billable_flag(j) as the value.

             pa_plan_revenue.Get_planning_Rates
                (
                                 p_project_id                           => p_project_id
                                ,p_task_id                              => 0
                                ,p_top_task_id                          => NULL
                                ,p_person_id                            => l_rt_person_id_tab(k)
                                ,p_job_id                               => l_rt_job_id_tab(k)
                                ,p_bill_job_grp_id                      => rate_rec.bill_job_group_id
                                ,p_resource_class                       => l_rt_res_class_code_tab(k)
                                ,p_planning_resource_format             => l_rt_res_format_id_tab(k)
                                ,p_use_planning_rates_flag              => NVL(rate_rec.use_planning_rates_flag, 'N')
                                ,p_rate_based_flag                      => l_rt_rate_based_flag_tab(k)
                                ,p_uom                                  => l_rt_uom_tab(k)
                                ,p_system_linkage                       => NULL
                                ,p_project_organz_id                    => rate_rec.carrying_out_organization_id
                                ,p_rev_res_class_rate_sch_id            => rate_rec.res_class_bill_rate_sch_id
                                ,p_cost_res_class_rate_sch_id           => rate_rec.res_class_raw_cost_sch_id
                                ,p_rev_task_nl_rate_sch_id              => NULL
                                ,p_rev_proj_nl_rate_sch_id              => rate_rec.non_lab_std_bill_rt_sch_id
                                ,p_rev_job_rate_sch_id                  => rate_rec.job_bill_rate_schedule_id
                                ,p_rev_emp_rate_sch_id                  => rate_rec.emp_bill_rate_schedule_id
                                ,p_plan_rev_job_rate_sch_id             => rate_rec.rev_job_rate_sch_id
                                ,p_plan_cost_job_rate_sch_id            => rate_rec.cost_job_rate_sch_id
                                ,p_plan_rev_emp_rate_sch_id             => rate_rec.rev_emp_rate_sch_id
                                ,p_plan_cost_emp_rate_sch_id            => rate_rec.cost_emp_rate_sch_id
                                ,p_plan_rev_nlr_rate_sch_id             => rate_rec.rev_non_labor_res_rate_sch_id
                                ,p_plan_cost_nlr_rate_sch_id            => rate_rec.cost_non_labor_res_rate_sch_id
                                ,p_plan_burden_cost_sch_id              => rate_rec.cost_burden_rate_sch_id
                                ,p_calculate_mode                       => l_calculate_mode
                                ,p_mcb_flag                             => rate_rec.multi_currency_billing_flag
                                ,p_cost_rate_multiplier                 => l_cost_rate_multiplier
                                ,p_bill_rate_multiplier                 => l_bill_rate_multiplier
                                ,p_quantity                             => l_rt_qty_tab(k)
                                ,p_item_date                            => l_rt_start_date_tab(k)
                                ,p_cost_sch_type                        => l_cost_sch_type
                                ,p_labor_sch_type                       => rate_rec.labor_sch_type
                                ,p_non_labor_sch_type                   => rate_rec.non_labor_sch_type
                                ,p_labor_schdl_discnt                   => NULL
                                ,p_labor_bill_rate_org_id               => rate_rec.labor_bill_rate_org_id
                                ,p_labor_std_bill_rate_schdl            => NULL
                                ,p_labor_schdl_fixed_date               => NULL
                                ,p_assignment_id                        => l_rt_res_assignment_id_tab(k)
                                ,p_project_org_id                       => rate_rec.org_id
                                ,p_project_type                         => rate_rec.project_type
                                ,p_expenditure_type                     => NVL(l_rt_expenditure_type_tab(k),l_rt_rate_expenditure_type_tab(k))
                                ,p_non_labor_resource                   => l_rt_non_labor_resource_tab(k)
                                ,p_incurred_by_organz_id                => l_rt_organization_id_tab(k)
                                ,p_override_to_organz_id                => l_override_organization_id
                                ,p_expenditure_org_id                   => NVL(l_rt_rate_exp_org_id_tab(k),rate_rec.org_id)
                                ,p_assignment_precedes_task             => rate_rec.assign_precedes_task
                                ,p_planning_transaction_id              => NULL
                                ,p_task_bill_rate_org_id                => NULL
                                ,p_project_bill_rate_org_id             => rate_rec.non_labor_bill_rate_org_id
                                ,p_nlr_organization_id                  => l_rt_organization_id_tab(k)
                                ,p_project_sch_date                     => rate_rec.non_labor_schedule_fixed_date
                                ,p_task_sch_date                        => NULL
                                ,p_project_sch_discount                 => rate_rec.non_labor_schedule_discount
                                ,p_task_sch_discount                    => NULL
                                ,p_inventory_item_id                    => l_rt_item_category_id_tab(k)
                                ,p_BOM_resource_Id                      => l_rt_bom_resource_id_tab(k)
                                ,P_mfc_cost_type_id                     => l_rt_mfc_cost_type_id_tab(k)
                                ,P_item_category_id                     => l_rt_item_category_id_tab(k)
                                ,p_mfc_cost_source                      => l_mfc_cost_source
                                ,p_cost_override_rate                   => NULL
                                ,p_revenue_override_rate                => l_proj_bill_rate_override_tab(j)
                                ,p_override_burden_cost_rate            => NULL
                                ,p_override_currency_code               => l_proj_bill_rate_cur_ovrd_tab(j)
                                ,p_txn_currency_code                    => l_txn_currency_code
                                ,p_raw_cost                             => NULL
                                ,p_burden_cost                          => NULL
                                ,p_raw_revenue                          => NULL
                                ,p_billability_flag                     => l_proj_billable_flag(j) /* Bug 4548733 */
                                ,x_bill_rate                            => x_bill_rate
                                ,x_cost_rate                            => x_cost_rate
                                ,x_burden_cost_rate                     => x_burden_cost_rate
                                ,x_burden_multiplier                    => x_burden_multiplier
                                ,x_raw_cost                             => x_raw_cost
                                ,x_burden_cost                          => x_burden_cost
                                ,x_raw_revenue                          => x_raw_revenue
                                ,x_bill_markup_percentage               => x_bill_markup_percentage
                                ,x_cost_txn_curr_code                   => x_cost_txn_curr_code
                                ,x_rev_txn_curr_code                    => x_rev_txn_curr_code
                                ,x_raw_cost_rejection_code              => x_raw_cost_rejection_code
                                ,x_burden_cost_rejection_code           => x_burden_cost_rejection_code
                                ,x_revenue_rejection_code               => x_revenue_rejection_code
                                ,x_cost_ind_compiled_set_id             => x_cost_ind_compiled_set_id
                                ,x_return_status                        => l_return_status
                                ,x_msg_data                             => x_msg_data
                                ,x_msg_count                            => x_msg_count
                                );


            IF l_return_status = 'U' THEN
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            EXCEPTION
        WHEN OTHERS THEN

                x_raw_cost_rejection_code      := SUBSTR('PA_FP_ERROR_FROM_RATE_API_CALL',1,30);
                x_burden_cost_rejection_code   := SUBSTR(SQLERRM,1,30);
                x_revenue_rejection_code       := SUBSTR('PA_FP_ERROR_FROM_RATE_API_CALL',1,30);
            IF l_return_status = 'U' THEN
             x_return_status := l_return_status;
             pa_utils.add_message
                         ( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_FP_ERROR_FROM_RATE_API_CALL'
                          ,p_token1         => 'G_PROJECT_NAME'
                          ,p_value1         => rate_rec.project_name
                          ,p_token2         => 'G_TASK_NAME'
                          ,p_value2         => null
                          ,p_token3         => 'G_RESOURCE_NAME'
                          ,p_value3         => l_rt_alias_tab(k)
                          ,p_token4         => 'TO_CHAR(L_TXN_CURRENCY_CODE)'
                          ,p_value4         => l_txn_currency_code
                          ,p_token5         => 'TO_CHAR(L_BUDGET_LINES_START_DATE)'
                          ,p_value5         => TO_CHAR(l_rt_start_date_tab(k)));
            END IF;

        x_return_status := l_return_status;
                RAISE;
            END;

           IF p_pa_debug_mode = 'Y' THEN
              pa_fp_gen_amount_utils.fp_debug
                   (p_called_mode => p_called_mode,
                    p_msg         => 'calling client extensions',
                    p_module_name => l_module_name,
                    p_log_level   => 5);
           END IF;

           --    2.5. Call client extension

           -- Bug 4549862: Changed IF condition so that l_calculate_mode is
           -- checked instead of the target version type. We should only call
           -- the cost client extensions if costs are being generated from
           -- source cost amounts, which is the case when l_calculate_mode
           -- is either 'COST_REVENUE' or 'COST'.

           IF l_calculate_mode IN ('COST_REVENUE', 'COST') THEN

              l_ce_raw_cost := x_raw_cost;

          pa_client_extn_budget.calc_raw_cost
                (  x_budget_version_id       => p_budget_version_id
                                  ,x_project_id              => p_project_id
                                  ,x_task_id                 => 0
                                  ,x_resource_list_member_id => l_rt_res_list_member_id_tab(k)
                                  ,x_resource_list_id        => l_rt_resource_list_id_tab(k)
                                  ,x_resource_id             => l_rt_resource_id_tab(k)
                                  ,x_start_date              => l_rt_start_date_tab(k)
                                  ,x_end_date                => l_rt_end_date_tab(k)
                                  ,x_period_name             => l_rt_pd_name_tab(k)
                                  ,x_quantity                => l_rt_qty_tab(k)
                                  ,x_raw_cost                => l_ce_raw_cost --  IN OUT
                                  ,x_pm_product_code         => NULL
                                  ,x_txn_currency_code       => x_cost_txn_curr_code
                                  ,x_error_code              => l_return_status
                                  ,x_error_message           => x_msg_data
                                  );

              IF l_return_status <> '0' THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

              IF NVL(l_ce_raw_cost,0) <> NVL(x_raw_cost,0) THEN
                x_raw_cost := pa_currency.round_trans_currency_amt1(x_raw_cost,x_cost_txn_curr_code);
              END IF;

              l_ce_burdened_cost  := x_burden_cost;

          -- Calling client extn for burdened amts
              pa_client_extn_budget.Calc_Burdened_Cost
                                (  x_budget_version_id       => p_budget_version_id
                                  ,x_project_id              => p_project_id
                                  ,x_task_id                 => 0
                                  ,x_resource_list_member_id => l_rt_res_list_member_id_tab(k)
                                  ,x_resource_list_id        => l_rt_resource_list_id_tab(k)
                                  ,x_resource_id             => l_rt_resource_id_tab(k)
                                  ,x_start_date              => l_rt_start_date_tab(k)
                                  ,x_end_date                => l_rt_end_date_tab(k)
                                  ,x_period_name             => l_rt_pd_name_tab(k)
                                  ,x_quantity                => l_rt_qty_tab(k)
                  ,x_raw_cost                => x_raw_cost
                                  ,x_burdened_cost           => l_ce_burdened_cost --  IN OUT
                                  ,x_pm_product_code         => NULL
                                  ,x_txn_currency_code       => x_cost_txn_curr_code
                                  ,x_error_code              => l_return_status
                                  ,x_error_message           => x_msg_data
                                  );

               IF l_return_status <> '0' THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
               END IF;

               IF NVL(l_ce_burdened_cost,0) <> NVL(x_burden_cost,0) THEN
                 x_burden_cost := pa_currency.round_trans_currency_amt1(l_ce_burdened_cost,x_cost_txn_curr_code);
               END IF;

            END IF ; -- IF p_fp_cols_rec.x_version_type IN ('ALL','COST') THEN

            -- Bug 4549862: Changed IF condition so that l_calculate_mode is
            -- checked instead of the target version type. We should only call
            -- the revenue client extension if revenue is being generated from
            -- source revenue amounts, which is the case when l_calculate_mode
            -- is either 'COST_REVENUE' or 'REVENUE'.

            IF l_calculate_mode IN ('COST_REVENUE', 'REVENUE') THEN

                l_ce_revenue := x_raw_revenue;

                -- Calling clinet extn for revenue amts
                pa_client_extn_budget.calc_revenue
                                (  x_budget_version_id       => p_budget_version_id
                                  ,x_project_id              => p_project_id
                                  ,x_task_id                 => 0
                                  ,x_resource_list_member_id => l_rt_res_list_member_id_tab(k)
                                  ,x_resource_list_id        => l_rt_resource_list_id_tab(k)
                                  ,x_resource_id             => l_rt_resource_id_tab(k)
                                  ,x_start_date              => l_rt_start_date_tab(k)
                                  ,x_end_date                => l_rt_end_date_tab(k)
                                  ,x_period_name             => l_rt_pd_name_tab(k)
                                  ,x_quantity                => l_rt_qty_tab(k)
                  ,x_raw_cost                => x_raw_cost
                  ,x_burdened_cost           => x_burden_cost
                                  ,x_revenue                 => l_ce_revenue -- IN OUT
                                  ,x_pm_product_code         => NULL
                                  ,x_txn_currency_code       => x_rev_txn_curr_code
                                  ,x_error_code              => l_return_status
                                  ,x_error_message           => x_msg_data
                                  );
                 IF l_return_status <> '0' THEN
                   x_return_status := FND_API.G_RET_STS_ERROR;
                 END IF;

                 IF NVL(l_ce_revenue,0) <> NVL(x_raw_revenue,0) THEN
                         x_raw_revenue := pa_currency.round_trans_currency_amt1(l_ce_revenue,x_rev_txn_curr_code);
                 END IF;

           END IF; -- IF p_fp_cols_rec.x_version_type IN ('ALL','REVENUE') THEN

           -- Bug 4530753: Previously, local variables were passed to the
           -- pa_multi_currency_txn.get_currency_amounts API as IN OUT
           -- parameters but never modified by this procedure. The multi-
           -- currency API seems to use the given EI date only when the
           -- other rate dates are null. Thus, to get the correct periodic
           -- rates, we should null out the following local variables:
           -- x_dummy_rate_date, x_dummy_rate_type, x_dummy_exch_rate, x_dummy_cost,
           -- l_Final_txn_rate_type, l_Final_txn_rate_date, and l_Final_txn_exch_rate.

           x_dummy_rate_date := NULL;
           x_dummy_rate_type := NULL;
           x_dummy_exch_rate := NULL;
           x_dummy_cost      := NULL;
           l_Final_txn_rate_type := NULL;
           l_Final_txn_rate_date := NULL;
           l_Final_txn_exch_rate := NULL;

           --    3. Convert amounts
           --       a. For Approved Revenue, final currency = PFC
           --       b. If multi-currency is disabled, final currency = PC
           --       c. Otherwise, rev currency should be converted into cost currency (from Rate API).
           l_insert_Txn_Currency_Code := l_Final_Txn_Currency_Code; -- Bug 4615589

           IF l_Final_Txn_Currency_Code IS NOT NULL THEN

             -- Bug 4549862: Modified IF condition so that l_calculate_mode is
             -- checked in addition to x_cost_txn_curr_code. We should only call
             -- the currency conversion API for cost amounts if costs are
             -- being generated from source cost amounts, which is the case
             -- when l_calculate_mode is either 'COST_REVENUE' or 'COST'.

             IF x_cost_txn_curr_code <> l_Final_Txn_Currency_Code AND
                l_calculate_mode IN ('COST_REVENUE', 'COST') THEN

                IF p_pa_debug_mode = 'Y' THEN
                  pa_fp_gen_amount_utils.fp_debug
                   (p_called_mode => p_called_mode,
                    p_msg         => 'convert cost from '|| x_cost_txn_curr_code ||
                                     ' to '||l_Final_Txn_Currency_Code,
                    p_module_name => l_module_name,
                    p_log_level   => 5);
                END IF;

            pa_multi_currency_txn.get_currency_amounts (
                        p_project_id                  => p_project_id
                       ,p_exp_org_id                  => NVL(l_rt_rate_exp_org_id_tab(k),rate_rec.org_id)
                       ,p_calling_module              => 'WORKPLAN'
                       ,p_task_id                     => 0
                       ,p_ei_date                     => l_rt_start_date_tab(k)
                       ,p_denom_raw_cost              => 1
                       ,p_denom_curr_code             => x_cost_txn_curr_code -- FROM currency code
                       ,p_acct_curr_code              => x_cost_txn_curr_code
                       ,p_accounted_flag              => 'N'
                       ,p_acct_rate_date              => x_dummy_rate_date
                       ,p_acct_rate_type              => x_dummy_rate_type
                       ,p_acct_exch_rate              => x_dummy_exch_rate
                       ,p_acct_raw_cost               => x_dummy_cost
                       ,p_project_curr_code           => l_Final_Txn_Currency_Code -- TO currency code
                       ,p_project_rate_type           => l_Final_txn_rate_type
                       ,p_project_rate_date           => l_Final_txn_rate_date
                       ,p_project_exch_rate           => l_Final_txn_exch_rate
                       ,p_project_raw_cost            => x_dummy_cost
                       ,p_projfunc_curr_code          => l_Final_Txn_Currency_Code -- TO currency code
                       ,p_projfunc_cost_rate_type     => x_dummy_rate_type
                       ,p_projfunc_cost_rate_date     => x_dummy_rate_date
                       ,p_projfunc_cost_exch_rate     => x_dummy_exch_rate
                       ,p_projfunc_raw_cost           => x_dummy_cost
                       ,p_system_linkage              => 'NER'
               ,p_structure_version_id        => NULL -- always NULL for finplan
                       ,p_status                      => l_status
                       ,p_stage                       => l_stage) ;


                 IF l_final_txn_exch_rate IS NULL OR l_status IS NOT NULL THEN

                            x_return_status := FND_API.G_RET_STS_ERROR;

                            pa_utils.add_message
                            ( p_app_short_name => 'PA'
                            ,p_msg_name       => 'PA_FP_PROJ_NO_TXNCONVRATE'
                            ,p_token1         => 'G_PROJECT_NAME'
                            ,p_value1         =>  rate_rec.project_name
                            ,p_token2         => 'FROMCURRENCY'
                            ,p_value2         => x_cost_txn_curr_code
                            ,p_token3         => 'TOCURRENCY'
                            ,p_value3         => l_Final_Txn_Currency_Code
                ,p_token4         => 'CONVERSION_TYPE'
                ,p_value4         => l_Final_txn_rate_type
                ,p_token5         => 'CONVERSION_DATE'
                ,p_value5         => l_Final_txn_rate_date
                            );

                            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                 END IF; -- IF l_final_txn_exch_rate IS NULL OR l_status IS NOT NULL THEN

         IF NVL(x_raw_cost,0) <> 0 THEN
                    x_raw_cost := x_raw_cost * l_final_txn_exch_rate;
                x_raw_cost := pa_currency.round_trans_currency_amt1(x_raw_cost,l_final_txn_currency_code);
         END IF;
         IF NVL(x_burden_cost,0) <> 0 THEN
                    x_burden_cost := x_burden_cost * l_final_txn_exch_rate;
                x_burden_cost := pa_currency.round_trans_currency_amt1(x_burden_cost,l_final_txn_currency_code);
         END IF;


             END IF; -- IF x_cost_txn_curr_code <> l_Final_Txn_Currency_Code THEN

             -- Bug 4549862: Modified IF condition so that l_calculate_mode is
             -- checked in addition to x_rev_txn_curr_code. We should only call
             -- the currency conversion API for revenue amounts if revenue is
             -- being generated from source revenue amounts, which is the case
             -- when l_calculate_mode is either 'COST_REVENUE' or 'REVENUE'.

             IF x_rev_txn_curr_code <> l_Final_Txn_Currency_Code AND
                l_calculate_mode IN ('COST_REVENUE', 'REVENUE') THEN

                IF p_pa_debug_mode = 'Y' THEN
                  pa_fp_gen_amount_utils.fp_debug
                   (p_called_mode => p_called_mode,
                    p_msg         => 'convert revenue from '|| x_rev_txn_curr_code ||
                                     ' to '||l_Final_Txn_Currency_Code,
                    p_module_name => l_module_name,
                    p_log_level   => 5);
                END IF;

            pa_multi_currency_txn.get_currency_amounts (
                        p_project_id                  => p_project_id
                       ,p_exp_org_id                  => NVL(l_rt_rate_exp_org_id_tab(k),rate_rec.org_id)
                       ,p_calling_module              => 'WORKPLAN'
                       ,p_task_id                     => 0
                       ,p_ei_date                     => l_rt_start_date_tab(k)
                       ,p_denom_raw_cost              => 1
                       ,p_denom_curr_code             => x_rev_txn_curr_code -- FROM currency code
                       ,p_acct_curr_code              => x_rev_txn_curr_code
                       ,p_accounted_flag              => 'N'
                       ,p_acct_rate_date              => x_dummy_rate_date
                       ,p_acct_rate_type              => x_dummy_rate_type
                       ,p_acct_exch_rate              => x_dummy_exch_rate
                       ,p_acct_raw_cost               => x_dummy_cost
                       ,p_project_curr_code           => l_Final_Txn_Currency_Code -- TO currency code
                       ,p_project_rate_type           => l_Final_txn_rate_type
                       ,p_project_rate_date           => l_Final_txn_rate_date
                       ,p_project_exch_rate           => l_Final_txn_exch_rate
                       ,p_project_raw_cost            => x_dummy_cost
                       ,p_projfunc_curr_code          => l_Final_Txn_Currency_Code -- TO currency code
                       ,p_projfunc_cost_rate_type     => x_dummy_rate_type
                       ,p_projfunc_cost_rate_date     => x_dummy_rate_date
                       ,p_projfunc_cost_exch_rate     => x_dummy_exch_rate
                       ,p_projfunc_raw_cost           => x_dummy_cost
                       ,p_system_linkage              => 'NER'
               ,p_structure_version_id        => NULL -- always NULL for finplan
                       ,p_status                      => l_status
                       ,p_stage                       => l_stage) ;


                 IF l_final_txn_exch_rate IS NULL OR l_status IS NOT NULL THEN

                            x_return_status := FND_API.G_RET_STS_ERROR;

                            pa_utils.add_message
                            ( p_app_short_name => 'PA'
                            ,p_msg_name       => 'PA_FP_PROJ_NO_TXNCONVRATE'
                            ,p_token1         => 'G_PROJECT_NAME'
                            ,p_value1         =>  rate_rec.project_name
                            ,p_token2         => 'FROMCURRENCY'
                            ,p_value2         =>x_rev_txn_curr_code
                            ,p_token3         => 'TOCURRENCY'
                            ,p_value3         => l_Final_Txn_Currency_Code
                ,p_token4         => 'CONVERSION_TYPE'
                ,p_value4         => l_Final_txn_rate_type
                ,p_token5         => 'CONVERSION_DATE'
                ,p_value5         => l_Final_txn_rate_date
                            );

                            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                 END IF; -- IF l_final_txn_exch_rate IS NULL OR l_status IS NOT NULL THEN

         IF NVL(x_raw_revenue,0) <> 0 THEN
                    x_raw_revenue := x_raw_revenue * l_final_txn_exch_rate;
                x_raw_revenue := pa_currency.round_trans_currency_amt1(x_raw_revenue,l_final_txn_currency_code);
         END IF;

              END IF; -- IF x_rev_txn_curr_code  <> <> l_Final_Txn_Currency_Code THEN

          -- Bug 4549862: Modified ELSIF condition so that l_calculate_mode
          -- also checked. We should only call the currency conversion API
          -- for revenue amounts if revenue is being generated from source
          -- revenue amounts, which is the case when l_calculate_mode is
          -- either 'COST_REVENUE' or 'REVENUE'.

          ELSIF x_cost_txn_curr_code <> x_rev_txn_curr_code AND
                l_calculate_mode IN ('COST_REVENUE', 'REVENUE') THEN

            l_insert_Txn_Currency_Code := x_cost_txn_curr_code; -- Bug 4615589

            IF p_pa_debug_mode = 'Y' THEN
                  pa_fp_gen_amount_utils.fp_debug
                   (p_called_mode => p_called_mode,
                    p_msg         => 'cost cur <> rev cur, convert revenue from '|| x_rev_txn_curr_code ||
                                     ' to '||l_insert_Txn_Currency_Code, -- Bug 4615589
                    p_module_name => l_module_name,
                    p_log_level   => 5);
            END IF;

        pa_multi_currency_txn.get_currency_amounts (
                        p_project_id                  => p_project_id
                       ,p_exp_org_id                  => NVL(l_rt_rate_exp_org_id_tab(k),rate_rec.org_id)
                       ,p_calling_module              => 'WORKPLAN'
                       ,p_task_id                     => 0
                       ,p_ei_date                     => l_rt_start_date_tab(k)
                       ,p_denom_raw_cost              => 1
                       ,p_denom_curr_code             => x_rev_txn_curr_code -- FROM currency code
                       ,p_acct_curr_code              => x_rev_txn_curr_code
                       ,p_accounted_flag              => 'N'
                       ,p_acct_rate_date              => x_dummy_rate_date
                       ,p_acct_rate_type              => x_dummy_rate_type
                       ,p_acct_exch_rate              => x_dummy_exch_rate
                       ,p_acct_raw_cost               => x_dummy_cost
                       ,p_project_curr_code           => l_insert_Txn_Currency_Code -- Bug 4615589 TO currency code
                       ,p_project_rate_type           => l_Final_txn_rate_type
                       ,p_project_rate_date           => l_Final_txn_rate_date
                       ,p_project_exch_rate           => l_Final_txn_exch_rate
                       ,p_project_raw_cost            => x_dummy_cost
                       ,p_projfunc_curr_code          => x_rev_txn_curr_code -- 4615656: Should convert based on PC rate type
                       ,p_projfunc_cost_rate_type     => x_dummy_rate_type
                       ,p_projfunc_cost_rate_date     => x_dummy_rate_date
                       ,p_projfunc_cost_exch_rate     => x_dummy_exch_rate
                       ,p_projfunc_raw_cost           => x_dummy_cost
                       ,p_system_linkage              => 'NER'
               ,p_structure_version_id        => NULL -- always NULL for finplan
                       ,p_status                      => l_status
                       ,p_stage                       => l_stage) ;


             IF l_final_txn_exch_rate IS NULL OR l_status IS NOT NULL THEN

                            x_return_status := FND_API.G_RET_STS_ERROR;

                            pa_utils.add_message
                            ( p_app_short_name => 'PA'
                            ,p_msg_name       => 'PA_FP_PROJ_NO_TXNCONVRATE'
                            ,p_token1         => 'G_PROJECT_NAME'
                            ,p_value1         =>  rate_rec.project_name
                            ,p_token2         => 'FROMCURRENCY'
                            ,p_value2         => x_rev_txn_curr_code
                            ,p_token3         => 'TOCURRENCY'
                            ,p_value3         => l_insert_Txn_Currency_Code -- Bug 4615589
                ,p_token4         => 'CONVERSION_TYPE'
                ,p_value4         => l_Final_txn_rate_type
                ,p_token5         => 'CONVERSION_DATE'
                ,p_value5         => l_Final_txn_rate_date
                            );

                            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

             END IF; -- IF l_final_txn_exch_rate IS NULL OR l_status IS NOT NULL THEN

             IF NVL(x_raw_revenue,0) <> 0 THEN
                    x_raw_revenue := x_raw_revenue * l_final_txn_exch_rate;
                x_raw_revenue := pa_currency.round_trans_currency_amt1(x_raw_revenue,l_insert_Txn_Currency_Code);  -- Bug 4615589
         END IF;

          ELSE
            l_insert_Txn_Currency_Code := x_cost_txn_curr_code; -- Bug 4615589

          END IF; -- ELSIF x_cost_txn_curr_code <> x_rev_txn_curr_code THEN

          IF p_pa_debug_mode = 'Y' THEN
                  pa_fp_gen_amount_utils.fp_debug
                   (p_called_mode => p_called_mode,
                    p_msg         => 'Populate temporary table (pa_fp_rollup_tmp) with rates and rejection code',
                    p_module_name => l_module_name,
                    p_log_level   => 5);
                  pa_fp_gen_amount_utils.fp_debug
                   (p_called_mode => p_called_mode,
                    p_msg         => 'resource assignment id:'||l_rt_res_assignment_id_tab(k),
                    p_module_name => l_module_name,
                    p_log_level   => 5);
                  pa_fp_gen_amount_utils.fp_debug
                   (p_called_mode => p_called_mode,
                    p_msg         => 'start date:'||l_rt_start_date_tab(k),
                    p_module_name => l_module_name,
                    p_log_level   => 5);
                  pa_fp_gen_amount_utils.fp_debug
                   (p_called_mode => p_called_mode,
                    p_msg         => 'txn currency code:'||l_insert_Txn_Currency_Code,
                    p_module_name => l_module_name,
                    p_log_level   => 5);
          END IF;

          --    5. Populate temporary table (pa_fp_rollup_tmp) with rates and rejection code

          -- Bug 4549862: Increment counter to a new unique id.
          l_bl_id_counter := l_bl_id_counter + 1;

          -- Bug 4549862: Added 2 additional columns to Insert statement (BUDGET_LINE_ID
          -- and BILLABLE_FLAG) for further processing by other APIs when generating
          -- ALL versions from Staffing Plan with revenue accrual method of COST.

          INSERT INTO pa_fp_rollup_tmp(
                                 RESOURCE_ASSIGNMENT_ID,
                                 START_DATE,
                                 END_DATE,
                                 PERIOD_NAME,
                                 QUANTITY,
                                 TXN_CURRENCY_CODE,
                                 TXN_RAW_COST,
                                 TXN_BURDENED_COST,
                                 TXN_REVENUE,
                                 BILL_MARKUP_PERCENTAGE,
                                 COST_REJECTION_CODE,
                                 BURDEN_REJECTION_CODE,
                                 REVENUE_REJECTION_CODE,
                                 COST_IND_COMPILED_SET_ID,
                                 BUDGET_LINE_ID,                   -- Added for Bug 4549862
                                 BILLABLE_FLAG,                    -- Added for Bug 4549862
                                 BUDGET_VERSION_ID )               -- Added for Bug 6207688
           VALUES(
                                 l_rt_res_assignment_id_tab(k),
                                 l_rt_start_date_tab(k),
                                 l_rt_end_date_tab(k),
                                 l_rt_pd_name_tab(k),
                                 l_rt_qty_tab(k),
                                 l_insert_Txn_Currency_Code, -- Bug 4615589
                                 x_raw_cost,
                                 x_burden_cost,
                                 x_raw_revenue,
                                 x_bill_markup_percentage,
                                 x_raw_cost_rejection_code,
                                 x_burden_cost_rejection_code,
                                 x_revenue_rejection_code,
                                 x_cost_ind_compiled_set_id,
                                 l_bl_id_counter,                  -- Added for Bug 4549862
                                 l_proj_billable_flag(j),          -- Added for Bug 4549862
                                 P_BUDGET_VERSION_ID );            -- Added for Bug 6207688


         END LOOP; --  FOR k in 1..l_rt_start_date_tab.COUNT LOOP

       END LOOP; -- FOR j IN 1..l_proj_assgn_id_tab.count LOOP

       -- Bug 4549862: The PA_FP_ROLLUP_TMP global temp table has now
       -- been populated with Txn generation data as well as rejection
       -- codes for raw cost, burden cost, and revenue.
       --
       -- If the revenue accrual method is COST, we should call the
       -- currency conversion API to populate pc/pfc amounts in the
       -- temp table and let control return to the Budget or Forecast
       -- wrapper API without propagating data to the budget lines.
       --
       -- If the revenue accrual method is NOT COST, then propagate
       -- temp table data to the budget lines as before.

       IF l_rev_gen_method = 'C' THEN

           -- Bug 4549862: Call currency conversion API. Passing 'N' for
           -- the p_entire_version parameter tells to the API to convert
           -- currencies in the PA_FP_ROLLUP_TMP table instead of in the
           -- PA_BUDGET_LINES table.

           IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
               (p_called_mode => p_called_mode,
                p_msg         => 'Before calling
                pa_fp_multi_currency_pkg.convert_txn_currency',
                p_module_name => l_module_name,
                p_log_level   => 5);
           END IF;
           PA_FP_MULTI_CURRENCY_PKG.CONVERT_TXN_CURRENCY
               ( p_budget_version_id       => P_BUDGET_VERSION_ID,
                 p_entire_version          => 'N',
                 p_calling_module              => 'BUDGET_GENERATION', -- Added for Bug#5395732
                 X_RETURN_STATUS           => X_RETURN_STATUS,
                 X_MSG_COUNT               => X_MSG_COUNT,
                 X_MSG_DATA                => X_MSG_DATA );
           IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;
           IF p_pa_debug_mode = 'Y' THEN
                 pa_fp_gen_amount_utils.fp_debug
                (p_called_mode => p_called_mode,
                 p_msg         => 'Status after calling
                 pa_fp_multi_currency_pkg.convert_txn_currency: '
                           ||x_return_status,
                 p_module_name => l_module_name,
                 p_log_level   => 5);
           END IF;

       END IF; -- l_rev_gen_method = 'C'


       -- Bug 4549862: At this point, for each set of requirements/assignments
       -- mapping to the same target resource, there may be multiple non-null
       -- values for each rejection code column when the target version is None
       -- timephased. However, we can only store one rejection code value per
       -- budget line. Our current approach is to randomly pick 1 rejection code
       -- value to store in each column when there are multiple values.
       -- At the same time, ff a requirement/assignment has a non-null rejection
       -- code, then all the other requirements/assignments mapping to the same
       -- target resource need to be updated with the same rejection code value,
       -- and the corresponding amounts should be nulled out.
       -- This logic applies if the target version is None timephased.

       IF p_fp_cols_rec.x_time_phased_code = 'N' THEN

           IF l_rev_gen_method = 'C' THEN

               -- A1. Logic to update cost rejection code and cost columns
           SELECT RESOURCE_ASSIGNMENT_ID,
                  TXN_CURRENCY_CODE,
                  MIN(COST_REJECTION_CODE)
           BULK COLLECT INTO
                  l_rej_code_ra_id_tab,
                  l_rej_code_txn_currency_tab,
                  l_rej_code_msg_name_tab
           FROM   pa_fp_rollup_tmp
           WHERE  cost_rejection_code is not null
               GROUP BY RESOURCE_ASSIGNMENT_ID,
                    TXN_CURRENCY_CODE;

           FORALL i IN 1..l_rej_code_ra_id_tab.COUNT
             UPDATE pa_fp_rollup_tmp
                SET TXN_RAW_COST = NULL,
                        PROJECT_RAW_COST = NULL,
                        PROJFUNC_RAW_COST = NULL,
                    COST_REJECTION_CODE = l_rej_code_msg_name_tab(i)
              WHERE resource_assignment_id = l_rej_code_ra_id_tab(i)
              AND   txn_currency_code = l_rej_code_txn_currency_tab(i);

               -- A2. Logic to update burden rejection code and cost columns
           SELECT RESOURCE_ASSIGNMENT_ID,
                  TXN_CURRENCY_CODE,
                  MIN(BURDEN_REJECTION_CODE)
           BULK COLLECT INTO
                  l_rej_code_ra_id_tab,
                  l_rej_code_txn_currency_tab,
                  l_rej_code_msg_name_tab
           FROM   pa_fp_rollup_tmp
           WHERE  burden_rejection_code is not null
               GROUP BY RESOURCE_ASSIGNMENT_ID,
                    TXN_CURRENCY_CODE;

           FORALL i IN 1..l_rej_code_ra_id_tab.COUNT
             UPDATE pa_fp_rollup_tmp
                SET TXN_BURDENED_COST = NULL,
                        PROJECT_BURDENED_COST = NULL,
                        PROJFUNC_BURDENED_COST = NULL,
                    BURDEN_REJECTION_CODE = l_rej_code_msg_name_tab(i)
              WHERE resource_assignment_id = l_rej_code_ra_id_tab(i)
              AND   txn_currency_code = l_rej_code_txn_currency_tab(i);

               -- A3. Logic to update pc currency conversion rejection code and pc amounts
           SELECT RESOURCE_ASSIGNMENT_ID,
                  TXN_CURRENCY_CODE,
                  MIN(PC_CUR_CONV_REJECTION_CODE)
           BULK COLLECT INTO
                  l_rej_code_ra_id_tab,
                  l_rej_code_txn_currency_tab,
                  l_rej_code_msg_name_tab
           FROM   pa_fp_rollup_tmp
           WHERE  pc_cur_conv_rejection_code is not null
               GROUP BY RESOURCE_ASSIGNMENT_ID,
                    TXN_CURRENCY_CODE;

           FORALL i IN 1..l_rej_code_ra_id_tab.COUNT
             UPDATE pa_fp_rollup_tmp
                SET PROJECT_RAW_COST = NULL,
                        PROJECT_BURDENED_COST = NULL,
                        PROJECT_REVENUE = NULL,
                    PC_CUR_CONV_REJECTION_CODE = l_rej_code_msg_name_tab(i)
              WHERE resource_assignment_id = l_rej_code_ra_id_tab(i)
              AND   txn_currency_code = l_rej_code_txn_currency_tab(i);

               -- A4. Logic to update pfc currency conversion rejection code and pfc amounts
           SELECT RESOURCE_ASSIGNMENT_ID,
                  TXN_CURRENCY_CODE,
                  MIN(PFC_CUR_CONV_REJECTION_CODE)
           BULK COLLECT INTO
                  l_rej_code_ra_id_tab,
                  l_rej_code_txn_currency_tab,
                  l_rej_code_msg_name_tab
           FROM   pa_fp_rollup_tmp
           WHERE  pfc_cur_conv_rejection_code is not null
               GROUP BY RESOURCE_ASSIGNMENT_ID,
                    TXN_CURRENCY_CODE;

           FORALL i IN 1..l_rej_code_ra_id_tab.COUNT
             UPDATE pa_fp_rollup_tmp
                SET PROJFUNC_RAW_COST = NULL,
                        PROJFUNC_BURDENED_COST = NULL,
                        PROJFUNC_REVENUE = NULL,
                    PFC_CUR_CONV_REJECTION_CODE = l_rej_code_msg_name_tab(i)
              WHERE resource_assignment_id = l_rej_code_ra_id_tab(i)
              AND   txn_currency_code = l_rej_code_txn_currency_tab(i);

           ELSE -- l_rev_gen_method <> 'C'

               -- B1. Logic to update cost rejection code and txn_raw_cost
           SELECT RESOURCE_ASSIGNMENT_ID,
                  TXN_CURRENCY_CODE,
                  MIN(COST_REJECTION_CODE)
           BULK COLLECT INTO
                  l_rej_code_ra_id_tab,
                  l_rej_code_txn_currency_tab,
                  l_rej_code_msg_name_tab
           FROM   pa_fp_rollup_tmp
           WHERE  cost_rejection_code is not null
               GROUP BY RESOURCE_ASSIGNMENT_ID,
                    TXN_CURRENCY_CODE;

           FORALL i IN 1..l_rej_code_ra_id_tab.COUNT
             UPDATE pa_fp_rollup_tmp
                SET TXN_RAW_COST = NULL,
                    COST_REJECTION_CODE = l_rej_code_msg_name_tab(i)
              WHERE resource_assignment_id = l_rej_code_ra_id_tab(i)
              AND   txn_currency_code = l_rej_code_txn_currency_tab(i);

               -- B2. Logic to update burden rejection code and txn_burdened_cost
           SELECT RESOURCE_ASSIGNMENT_ID,
                  TXN_CURRENCY_CODE,
                  MIN(BURDEN_REJECTION_CODE)
           BULK COLLECT INTO
                  l_rej_code_ra_id_tab,
                  l_rej_code_txn_currency_tab,
                  l_rej_code_msg_name_tab
           FROM   pa_fp_rollup_tmp
           WHERE  burden_rejection_code is not null
               GROUP BY RESOURCE_ASSIGNMENT_ID,
                    TXN_CURRENCY_CODE;

           FORALL i IN 1..l_rej_code_ra_id_tab.COUNT
             UPDATE pa_fp_rollup_tmp
                SET TXN_BURDENED_COST = NULL,
                    BURDEN_REJECTION_CODE = l_rej_code_msg_name_tab(i)
              WHERE resource_assignment_id = l_rej_code_ra_id_tab(i)
              AND   txn_currency_code = l_rej_code_txn_currency_tab(i);

               -- B3. Logic to update revenue rejection code and txn_revenue_cost.
               -- This logic differs from Step 5.5 because FIND_REJECTION_CODE
               -- matches requirement/assignment records based on start_date,
               -- which could miss records when the target is None timephased.
           SELECT DISTINCT
                  RESOURCE_ASSIGNMENT_ID,
                  TXN_CURRENCY_CODE,
                  MIN(REVENUE_REJECTION_CODE)
           BULK COLLECT INTO
                  l_rej_code_ra_id_tab,
                  l_rej_code_txn_currency_tab,
                  l_rej_code_msg_name_tab
           FROM   pa_fp_rollup_tmp
           WHERE  revenue_rejection_code is not null
               GROUP BY RESOURCE_ASSIGNMENT_ID,
                    TXN_CURRENCY_CODE;

           FORALL i IN 1..l_rej_code_ra_id_tab.COUNT
             UPDATE pa_fp_rollup_tmp
                SET TXN_REVENUE = NULL,
                    REVENUE_REJECTION_CODE = l_rej_code_msg_name_tab(i)
              WHERE resource_assignment_id = l_rej_code_ra_id_tab(i)
              AND   txn_currency_code = l_rej_code_txn_currency_tab(i);

           END IF; -- l_rev_gen_method = 'C'

       END IF; -- p_fp_cols_rec.x_time_phased_code = 'N'


       IF l_rev_gen_method = 'C' THEN

           -- Bug 4549862: Returning control to the Budget or Forecast
           -- wrapper API, which will call GEN_COST_BASED_REVENUE to
           -- finish processing the data in PA_FP_ROLLUP_TMP and write
           -- it to the budget lines.

           RETURN;

       ELSE -- l_rev_gen_method <> 'C'

           -- 5.5. If there are multiple lines with the same resource assignment
           --    id, txn currency code and start date, remove the revenue amount and stamp
           --    the rev rejection code on the lines with revenue amount.  This situation is
           --    formed if there are multiple project assignments contributing to a single
           --    budget line.  Some project assignment have bill rate override and the std rates
           --    are not available for the rest of the project assignments.
           OPEN FIND_REJECTION_CODE;
           FETCH FIND_REJECTION_CODE BULK COLLECT INTO
                    l_rej_res_assignment_id_tab,
                    l_rej_start_date_tab,
                    l_rej_txn_currency_code_tab,
                    l_rej_revenue_rej_code_tab;
           CLOSE FIND_REJECTION_CODE;

           FOR m IN 1..l_rej_res_assignment_id_tab.COUNT LOOP

             UPDATE pa_fp_rollup_tmp
                SET TXN_REVENUE = NULL,
                    REVENUE_REJECTION_CODE = l_rej_revenue_rej_code_tab(m)
              WHERE resource_assignment_id = l_rej_res_assignment_id_tab(m)
                AND start_date = l_rej_start_date_tab(m)
                AND txn_currency_code = l_rej_txn_currency_code_tab(m)
                AND (txn_revenue is not null OR
                     revenue_rejection_code is null);

           END LOOP; -- FOR m IN 1..l_rej_res_assignment_id_tab.COUNT LOOP

           IF p_pa_debug_mode = 'Y' THEN
                      pa_fp_gen_amount_utils.fp_debug
                       (p_called_mode => p_called_mode,
                        p_msg         => 'Group temp table data by res asgmt, txn cur and period.  Insert into budget lines',
                        p_module_name => l_module_name,
                        p_log_level   => 5);
           END IF;

           -- 6. Group the temporary table data by resource assignment, txn currency code and period name

           -- Bug 4549862: If the target version is None timephased and the
           -- context is Forecast generation, then budget lines containing
           -- actuals may exist. As a result, some of the data in the temp
           -- table may need to be Inserted while other data in the table
           -- may need to be Updated in pa_budget_lines.
           --
           -- Group the temporary table data by resource assignment and txn
           -- currency code using separate cursors for the Insert/Update cases.

           IF p_fp_cols_rec.x_time_phased_code = 'N' AND
              p_fp_cols_rec.x_plan_class_code = 'FORECAST' THEN

               -- Bug 4549862: Fetch data for Insert.
               OPEN GROUP_TO_INS_INTO_NTP_FCST_BL;
               FETCH GROUP_TO_INS_INTO_NTP_FCST_BL BULK COLLECT INTO
                   l_bl_RES_ASSIGNMENT_ID_tab,
                   l_bl_START_DATE_tab,
                   l_bl_END_DATE_tab,
                   l_bl_PERIOD_NAME_tab,
                   l_bl_QUANTITY_tab,
                   l_bl_TXN_CURRENCY_CODE_tab,
                   l_bl_TXN_RAW_COST_tab,
                   l_bl_TXN_BURDENED_COST_tab,
                   l_bl_TXN_REVENUE_tab,
                   l_bl_BILL_MARKUP_PERCENT_tab,
                   l_bl_COST_REJECTION_CODE_tab,
                   l_bl_BURDEN_REJECTION_CODE_tab,
                   l_bl_REV_REJECTION_CODE_tab,
                   l_bl_COST_IND_C_SET_ID_tab;
               CLOSE GROUP_TO_INS_INTO_NTP_FCST_BL;

               -- Bug 4549862: Fetch data for Update.
               OPEN GROUP_TO_UPD_INTO_NTP_FCST_BL;
               FETCH GROUP_TO_UPD_INTO_NTP_FCST_BL BULK COLLECT INTO
                   l_upd_bl_RES_ASSIGNMENT_ID_tab,
                   l_upd_bl_START_DATE_tab,
                   l_upd_bl_END_DATE_tab,
                   l_upd_bl_PERIOD_NAME_tab,
                   l_upd_bl_QUANTITY_tab,
                   l_upd_bl_TXN_CURRENCY_CODE_tab,
                   l_upd_bl_TXN_RAW_COST_tab,
                   l_upd_bl_TXN_BURDENED_COST_tab,
                   l_upd_bl_TXN_REVENUE_tab,
                   l_upd_bl_BILL_MARKUP_PRCNT_tab,
                   l_upd_bl_COST_REJ_CODE_tab,
                   l_upd_bl_BURDEN_REJ_CODE_tab,
                   l_upd_bl_REV_REJ_CODE_tab,
                   l_upd_bl_COST_IND_C_SET_ID_tab;
               CLOSE GROUP_TO_UPD_INTO_NTP_FCST_BL;

           -- Bug 4549862: If the context is Budget generation, then we do
           -- not need to worry about the existence of budget lines containing
           -- actuals, so all temp table data can be Inserted into the budget
           -- lines table. If the context is Forecast generation and the target
           -- version is timephased by either PA or GL, then budget lines with
           -- actuals will only exist for periods through the Actuals Through
           -- Date. Since the temp table will contain ETC data in this case,
           -- all temp table data can be Inserted into the budget lines table.
           -- Therefore, in the ELSE block, fetch all of the data.

           ELSE

               -- Bug 4615787: When the Target is timephased by PA or GL, we
               -- should continue to fetch pa_fp_rollup_tmp data using the
               -- GROUP_TO_INSERT_INTO_PA_GL_BL cursor. When the Target is None
               -- timephased, use the new GROUP_TO_INSERT_INTO_PA_GL_BL cursor
               -- instead so that only a single record is fetched for each
               -- (Resource Assignment Id, Txn Currency) combination.

               IF p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
                   OPEN GROUP_TO_INSERT_INTO_PA_GL_BL;
                   FETCH GROUP_TO_INSERT_INTO_PA_GL_BL BULK COLLECT INTO
                       l_bl_RES_ASSIGNMENT_ID_tab,
                       l_bl_START_DATE_tab,
                       l_bl_END_DATE_tab,
                       l_bl_PERIOD_NAME_tab,
                       l_bl_QUANTITY_tab,
                       l_bl_TXN_CURRENCY_CODE_tab,
                       l_bl_TXN_RAW_COST_tab,
                       l_bl_TXN_BURDENED_COST_tab,
                       l_bl_TXN_REVENUE_tab,
                       l_bl_BILL_MARKUP_PERCENT_tab,
                       l_bl_COST_REJECTION_CODE_tab,
                       l_bl_BURDEN_REJECTION_CODE_tab,
                       l_bl_REV_REJECTION_CODE_tab,
                       l_bl_COST_IND_C_SET_ID_tab;
                   CLOSE GROUP_TO_INSERT_INTO_PA_GL_BL;
               ELSIF p_fp_cols_rec.x_time_phased_code = 'N' THEN
                   OPEN GROUP_TO_INSERT_INTO_NTP_BL;
                   FETCH GROUP_TO_INSERT_INTO_NTP_BL BULK COLLECT INTO
                       l_bl_RES_ASSIGNMENT_ID_tab,
                       l_bl_START_DATE_tab,
                       l_bl_END_DATE_tab,
                       l_bl_PERIOD_NAME_tab,
                       l_bl_QUANTITY_tab,
                       l_bl_TXN_CURRENCY_CODE_tab,
                       l_bl_TXN_RAW_COST_tab,
                       l_bl_TXN_BURDENED_COST_tab,
                       l_bl_TXN_REVENUE_tab,
                       l_bl_BILL_MARKUP_PERCENT_tab,
                       l_bl_COST_REJECTION_CODE_tab,
                       l_bl_BURDEN_REJECTION_CODE_tab,
                       l_bl_REV_REJECTION_CODE_tab,
                       l_bl_COST_IND_C_SET_ID_tab;
                   CLOSE GROUP_TO_INSERT_INTO_NTP_BL;
               END IF; -- time phase check

           END IF; -- None timephased Forecast check


           -- 7. Insert into budget lines:  quantity, cost and revenue amounts, txn currency code,
           --    cost ind compiled set id and rejection codes
           IF l_bl_RES_ASSIGNMENT_ID_tab.COUNT > 0 THEN

              FORALL bl_index IN 1 .. l_bl_START_DATE_tab.COUNT
                  INSERT  INTO PA_BUDGET_LINES(
                                     RESOURCE_ASSIGNMENT_ID,
                                     START_DATE,
                                     LAST_UPDATE_DATE,
                                     LAST_UPDATED_BY,
                                     CREATION_DATE,
                                     CREATED_BY,
                                     LAST_UPDATE_LOGIN,
                                     END_DATE,
                                     PERIOD_NAME,
                                     QUANTITY,
                                     TXN_CURRENCY_CODE,
                                     BUDGET_LINE_ID,
                                     BUDGET_VERSION_ID,
                                    -- PROJECT_CURRENCY_CODE,
                                    -- PROJFUNC_CURRENCY_CODE,
                                     TXN_COST_RATE_OVERRIDE,
                                     TXN_BILL_RATE_OVERRIDE , -- override rate on project assignment
                                     BURDEN_COST_RATE_OVERRIDE,
                                     TXN_RAW_COST,
                                     TXN_BURDENED_COST,
                                     TXN_REVENUE,
                                     TXN_MARKUP_PERCENT_OVERRIDE,
                                     COST_REJECTION_CODE,
                                     BURDEN_REJECTION_CODE,
                                     REVENUE_REJECTION_CODE,
                                     COST_IND_COMPILED_SET_ID)
               VALUES(
                                     l_bl_RES_ASSIGNMENT_ID_tab(bl_index),
                                     l_bl_START_DATE_tab(bl_index),
                                     l_sysdate,
                                     l_last_updated_by,
                                     l_sysdate,
                                     l_last_updated_by,
                                     l_last_update_login,
                                     l_bl_END_DATE_tab(bl_index),
                                     l_bl_PERIOD_NAME_tab(bl_index),
                                     l_bl_QUANTITY_tab(bl_index),
                                     l_bl_TXN_CURRENCY_CODE_tab(bl_index),
                                     PA_BUDGET_LINES_S.nextval,
                                     P_BUDGET_VERSION_ID,
                                     DECODE(l_bl_QUANTITY_tab(bl_index), 0, NULL, l_bl_TXN_RAW_COST_tab(bl_index)/l_bl_QUANTITY_tab(bl_index)),
                                     DECODE(l_bl_QUANTITY_tab(bl_index), 0, NULL, l_bl_TXN_REVENUE_tab(bl_index)/l_bl_QUANTITY_tab(bl_index)),
                                     DECODE(l_bl_QUANTITY_tab(bl_index), 0, NULL, l_bl_TXN_BURDENED_COST_tab(bl_index)/l_bl_QUANTITY_tab(bl_index)),
                                     l_bl_TXN_RAW_COST_tab(bl_index),
                                     l_bl_TXN_BURDENED_COST_tab(bl_index),
                                     l_bl_TXN_REVENUE_tab(bl_index),
                                     l_bl_BILL_MARKUP_PERCENT_tab(bl_index),
                                     l_bl_COST_REJECTION_CODE_tab(bl_index),
                                     l_bl_BURDEN_REJECTION_CODE_tab(bl_index),
                                     l_bl_REV_REJECTION_CODE_tab(bl_index),
                                     l_bl_COST_IND_C_SET_ID_tab(bl_index));

           END IF; -- IF l_bl_RES_ASSIGNMENT_ID_tab.COUNT > 0 THEN


           -- Bug 4549862: If the target version is None timephased and the
           -- context is Forecast generation, then budget lines containing
           -- actuals may exist. As a result, some of the data in the temp
           -- table may need to be Inserted while other data in the table
           -- may need to be Updated in pa_budget_lines.
           --
           -- The following code Updates the budget lines.

           IF l_upd_bl_RES_ASSIGNMENT_ID_tab.COUNT > 0 THEN

              FORALL bl_index IN 1 .. l_upd_bl_START_DATE_tab.COUNT
          UPDATE PA_BUDGET_LINES
          SET    LAST_UPDATE_DATE  = l_sysdate,
                 LAST_UPDATED_BY   = l_last_updated_by,
                 LAST_UPDATE_LOGIN = l_last_update_login,
                 START_DATE        = LEAST(START_DATE, l_upd_bl_START_DATE_tab(bl_index)),
                 END_DATE          = GREATEST(END_DATE, l_upd_bl_END_DATE_tab(bl_index)),
                 QUANTITY          =
                     DECODE(INIT_QUANTITY, null, l_upd_bl_QUANTITY_tab(bl_index),
                            INIT_QUANTITY + NVL(l_upd_bl_QUANTITY_tab(bl_index),0)),
                 TXN_RAW_COST      =
                     DECODE(TXN_INIT_RAW_COST, null, l_upd_bl_TXN_RAW_COST_tab(bl_index),
                            TXN_INIT_RAW_COST + NVL(l_upd_bl_TXN_RAW_COST_tab(bl_index),0)),
                 TXN_BURDENED_COST =
                     DECODE(TXN_INIT_BURDENED_COST, null, l_upd_bl_TXN_BURDENED_COST_tab(bl_index),
                            TXN_INIT_BURDENED_COST + NVL(l_upd_bl_TXN_BURDENED_COST_tab(bl_index),0)),
                 TXN_REVENUE       =
                     DECODE(TXN_INIT_REVENUE, null, l_upd_bl_TXN_REVENUE_tab(bl_index),
                            TXN_INIT_REVENUE + NVL(l_upd_bl_TXN_REVENUE_tab(bl_index),0)),
                 TXN_COST_RATE_OVERRIDE      =
                     DECODE(l_upd_bl_QUANTITY_tab(bl_index), 0, NULL,
                            l_upd_bl_TXN_RAW_COST_tab(bl_index)/l_upd_bl_QUANTITY_tab(bl_index)),
                 -- override rate on project assignment
                 TXN_BILL_RATE_OVERRIDE      =
                     DECODE(l_upd_bl_QUANTITY_tab(bl_index), 0, NULL,
                            l_upd_bl_TXN_REVENUE_tab(bl_index)/l_upd_bl_QUANTITY_tab(bl_index)),
                 BURDEN_COST_RATE_OVERRIDE   =
                     DECODE(l_upd_bl_QUANTITY_tab(bl_index), 0, NULL,
                            l_upd_bl_TXN_BURDENED_COST_tab(bl_index)/l_upd_bl_QUANTITY_tab(bl_index)),
                 TXN_MARKUP_PERCENT_OVERRIDE = l_upd_bl_BILL_MARKUP_PRCNT_tab(bl_index),
                 COST_REJECTION_CODE         = l_upd_bl_COST_REJ_CODE_tab(bl_index),
                 BURDEN_REJECTION_CODE       = l_upd_bl_BURDEN_REJ_CODE_tab(bl_index),
                 REVENUE_REJECTION_CODE      = l_upd_bl_REV_REJ_CODE_tab(bl_index),
                 COST_IND_COMPILED_SET_ID    = l_upd_bl_COST_IND_C_SET_ID_tab(bl_index)
          WHERE  RESOURCE_ASSIGNMENT_ID = l_upd_bl_RES_ASSIGNMENT_ID_tab(bl_index)
          AND    TXN_CURRENCY_CODE      = l_upd_bl_TXN_CURRENCY_CODE_tab(bl_index);

           END IF; -- l_upd_bl_RES_ASSIGNMENT_ID_tab.COUNT > 0 check

       END IF; -- l_rev_gen_method check for Bug 4549862

    ELSE -- p_fp_cols_rec.x_version_type = 'ALL' AND l_bill_rate_ovrd_exists_flag = 'Y' THEN

   -- END OF M-closeout: Bill Rate Override ER

      FOR j IN 1..l_proj_assgn_id_tab.count LOOP
         --dbms_output.put_line('before cursor:l_proj_res_assgn_id_tab('||j
         --              ||'):'||l_proj_res_assgn_id_tab(j)
         --          ||';p_actuals_thru_date:'||p_actuals_thru_date);
         IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                   (p_called_mode => p_called_mode,
                    p_msg         => 'before cursor:l_proj_assgn_id_tab('||j
                     ||'):'||l_proj_assgn_id_tab(j)
                     ||';p_actuals_thru_date:'||p_actuals_thru_date,
                    p_module_name => l_module_name,
                    p_log_level   => 5);
         END IF;

       IF p_FP_COLS_REC.X_TIME_PHASED_CODE = 'P' THEN
          OPEN FCST_PA(l_proj_assgn_id_tab(j),p_actuals_thru_date,l_proj_exp_organization_id_tab(j), l_org_id);

       ELSIF p_FP_COLS_REC.X_TIME_PHASED_CODE = 'G' THEN
          OPEN FCST_GL(l_proj_assgn_id_tab(j),p_actuals_thru_date,l_proj_exp_organization_id_tab(j));

       ELSE
          OPEN FCST_NONE(l_proj_assgn_id_tab(j),p_actuals_thru_date,l_proj_exp_organization_id_tab(j));
       END IF;

       l_budget_lines_tbl.delete;
       l_rt_forecast_item_id_tab.delete;
       l_rt_pd_name_tab.delete;
       l_rt_start_date_tab.delete;
       l_rt_end_date_tab.delete;
       l_rt_qty_tab.delete;
       l_rt_exp_org_id_tab.delete;
       l_rt_exp_organization_id_tab.delete;
       l_rt_exp_func_raw_cst_rt_tab.delete;
       l_rt_exp_func_raw_cst_tab.delete;
       l_rt_exp_func_bur_cst_rt_tab.delete;
       l_rt_exp_func_burdned_cst_tab.delete;
       l_rt_projfunc_bill_rt_tab.delete;
       l_rt_projfunc_raw_revenue_tab.delete;
       l_rt_projfunc_raw_cst_tab.delete;
       l_rt_projfunc_raw_cst_rt_tab.delete;
       l_rt_projfunc_burdned_cst_tab.delete;
       l_rt_projfunc_bd_cst_rt_tab.delete;
       l_rt_rev_rejct_reason_tab.delete;
       l_rt_cst_rejct_reason_tab.delete;
       l_rt_burdned_rejct_reason_tab.delete;
       l_rt_others_rejct_reason_tab.delete;

       l_init_bill_rate_flag := 'N';

       IF p_FP_COLS_REC.X_TIME_PHASED_CODE = 'P' THEN
         FETCH FCST_PA BULK COLLECT INTO
             l_rt_exp_org_id_tab,
             l_rt_exp_organization_id_tab,
             l_rt_pd_name_tab,
             l_rt_start_date_tab,
             l_rt_end_date_tab,
             l_rt_qty_tab,
             l_rt_forecast_item_id_tab;

       ELSIF   p_FP_COLS_REC.X_TIME_PHASED_CODE = 'G' THEN
         FETCH FCST_GL BULK COLLECT INTO
             l_rt_exp_org_id_tab,
             l_rt_exp_organization_id_tab,
             l_rt_pd_name_tab,
             l_rt_start_date_tab,
             l_rt_end_date_tab,
             l_rt_qty_tab,
             l_rt_forecast_item_id_tab;
       ELSE
          FETCH FCST_NONE BULK COLLECT INTO
             l_rt_exp_org_id_tab,
             l_rt_exp_organization_id_tab,
             l_rt_qty_tab,
             l_rt_forecast_item_id_tab,
             l_rt_pd_name_tab,
             l_rt_start_date_tab,
             l_rt_end_date_tab;
       END IF;

       IF p_FP_COLS_REC.X_TIME_PHASED_CODE = 'P' THEN
          CLOSE FCST_PA;

       ELSIF p_FP_COLS_REC.X_TIME_PHASED_CODE = 'G' THEN
          CLOSE FCST_GL;

       ELSE
          CLOSE FCST_NONE;
       END IF;

       IF p_pa_debug_mode = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
                   (p_called_mode => p_called_mode,
                    p_msg         => '==j=='||j
                     ||';==l_rt_start_date_tab.count:'||l_rt_start_date_tab.count,
                    p_module_name => l_module_name,
                    p_log_level   => 5);
       END IF;
       SELECT  count(*)
       INTO    l_count
       FROM    pa_budget_lines
       WHERE   resource_assignment_id = l_proj_res_assgn_id_tab(j)
       AND     rownum <2;

       --dbms_output.put_line('==j=='||j
    --           ||';l_proj_res_assgn_id_tab(j):'||l_proj_res_assgn_id_tab(j)
    --           ||';count:'||l_count
    --               ||';l_rt_start_date_tab.count:'||l_rt_start_date_tab.count);
       IF p_pa_debug_mode = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
                   (p_called_mode => p_called_mode,
                    p_msg         => '==j=='||j
                     ||';l_proj_res_assgn_id_tab(j):'||l_proj_res_assgn_id_tab(j)
                     ||';count:'||l_count
                         ||';l_rt_start_date_tab.count:'||l_rt_start_date_tab.count,
                    p_module_name => l_module_name,
                    p_log_level   => 5);
       END IF;
       --dbms_output.put_line('l_count:'||l_count);
       --dbms_output.put_line('l_rt_start_date_tab.COUNT:'||l_rt_start_date_tab.COUNT);
       --for i in 1..l_rt_start_date_tab.count loop
    --dbms_output.put_line(i);
    --dbms_output.put_line('l_proj_res_assgn_id_tab(j):'||l_proj_res_assgn_id_tab(j));
        --dbms_output.put_line('l_rt_start_date_tab(i),:'||l_rt_start_date_tab(i));
        --dbms_output.put_line('l_rt_pd_name_tab(i):'||l_rt_pd_name_tab(i));
       --end loop;

       IF l_count = 0 THEN
          FORALL fp IN 1 .. l_rt_start_date_tab.COUNT
              INSERT  INTO PA_BUDGET_LINES(RESOURCE_ASSIGNMENT_ID,
                                 START_DATE,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATED_BY,
                                 CREATION_DATE,
                                 CREATED_BY,
                                 LAST_UPDATE_LOGIN,
                                 END_DATE,
                                 PERIOD_NAME,
                                 QUANTITY,
                                 TXN_CURRENCY_CODE,
                                 BUDGET_LINE_ID,
                                 BUDGET_VERSION_ID,
                                 PROJECT_CURRENCY_CODE,
                                 PROJFUNC_CURRENCY_CODE)
                          VALUES(l_proj_res_assgn_id_tab(j),
                                 l_rt_start_date_tab(fp),
                                 l_sysdate,
                                 l_last_updated_by,
                                 l_sysdate,
                                 l_last_updated_by,
                                 l_last_update_login,
                                 l_rt_end_date_tab(fp),
                                 l_rt_pd_name_tab(fp),
                                 l_rt_qty_tab(fp),
                 l_project_currency_code,
                                 PA_BUDGET_LINES_S.nextval,
                                 P_BUDGET_VERSION_ID,
                                 p_FP_COLS_REC.X_PROJECT_CURRENCY_CODE,
                                 p_FP_COLS_REC.X_PROJFUNC_CURRENCY_CODE);
        ELSE
          FOR fp IN 1 .. l_rt_start_date_tab.COUNT LOOP
              -- Bug 4615787: When the Target is timephased by PA or GL, budget lines
              -- are unique given (Resource Assignment Id, Currency Code, Start Date).
              -- When the Target is None timephased, budget lines should be unique
              -- given (Resource Assignment Id, Currency Code). Thus, we need to check
              -- for budget line existence differently based on Target timephase.
              IF p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
                  SELECT  count(*)
                  INTO    l_count1
                  FROM    pa_budget_lines
                  WHERE   resource_assignment_id = l_proj_res_assgn_id_tab(j)
                  AND     txn_currency_code = l_project_currency_code
                  AND     start_date = l_rt_start_date_tab(fp);
              ELSIF p_fp_cols_rec.x_time_phased_code = 'N' THEN
                  SELECT  count(*)
                  INTO    l_count1
                  FROM    pa_budget_lines
                  WHERE   resource_assignment_id = l_proj_res_assgn_id_tab(j)
                  AND     txn_currency_code = l_project_currency_code;
              END IF;
              IF  l_count1 = 0 then
                 INSERT  INTO PA_BUDGET_LINES(RESOURCE_ASSIGNMENT_ID,
                                 START_DATE,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATED_BY,
                                 CREATION_DATE,
                                 CREATED_BY,
                                 LAST_UPDATE_LOGIN,
                                 END_DATE,
                                 PERIOD_NAME,
                                 QUANTITY,
                                 TXN_CURRENCY_CODE,
                                 BUDGET_LINE_ID,
                                 BUDGET_VERSION_ID,
                                 PROJECT_CURRENCY_CODE,
                                 PROJFUNC_CURRENCY_CODE)
                          VALUES(l_proj_res_assgn_id_tab(j),
                                 l_rt_start_date_tab(fp),
                                 l_sysdate,
                                 l_last_updated_by,
                                 l_sysdate,
                                 l_last_updated_by,
                                 l_last_update_login,
                                 l_rt_end_date_tab(fp),
                                 l_rt_pd_name_tab(fp),
                                 l_rt_qty_tab(fp),
                 l_project_currency_code,
                                 PA_BUDGET_LINES_S.nextval,
                                 P_BUDGET_VERSION_ID,
                                 p_FP_COLS_REC.X_PROJECT_CURRENCY_CODE,
                                 p_FP_COLS_REC.X_PROJFUNC_CURRENCY_CODE);
              ELSE
                  -- Bug 4615787: When the Target is timephased by PA or GL, budget lines
                  -- are unique given (Resource Assignment Id, Currency Code, Start Date).
                  -- When the Target is None timephased, budget lines should be unique
                  -- given (Resource Assignment Id, Currency Code). Split Update logic into
                  -- 2 cases based on Target timephase.
                  IF p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
                       UPDATE pa_budget_lines
                       SET    quantity = nvl(quantity,0) +
                                      l_rt_qty_tab(fp)
                       WHERE  resource_assignment_id = l_proj_res_assgn_id_tab(j)
                       AND    txn_currency_code      = l_project_currency_code
                       AND    start_date = l_rt_start_date_tab(fp);
                  ELSIF p_fp_cols_rec.x_time_phased_code = 'N' THEN
                       UPDATE pa_budget_lines
                       SET    quantity   = nvl(quantity,0) + l_rt_qty_tab(fp),
                              start_date = least(start_date, l_rt_start_date_tab(fp)),
                              end_date   = greatest(end_date, l_rt_end_date_tab(fp))
                       WHERE  resource_assignment_id = l_proj_res_assgn_id_tab(j)
                       AND    txn_currency_code      = l_project_currency_code;
                  END IF; -- timephase check
              END IF;
            END LOOP; -- FOR fp IN 1 .. l_rt_start_date_tab.COUNT LOOP
         END IF;

    END LOOP; -- FOR j IN 1..l_proj_assgn_id_tab.count LOOP

   /*Duplicate res_assignment needs to be filtered before calling calculate API*/
   IF l_proj_res_assgn_id_tab.count = 0 THEN
        IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
            PA_DEBUG.reset_err_stack;
        ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
    RETURN;
   END IF;
   l_dp_counter := 0;
   FOR i IN 1..l_proj_res_assgn_id_tab.count LOOP
    l_dp_flag := 'N';
    FOR j IN 1..l_res_assgn_id_tmp_tab.count LOOP
        IF l_proj_res_assgn_id_tab(i) = l_res_assgn_id_tmp_tab(j) THEN
        l_dp_flag := 'Y';
        END IF;
    END LOOP;
    IF l_dp_flag = 'N' THEN
        l_dp_counter := l_dp_counter+1;
        l_res_assgn_id_tmp_tab.extend;
        l_res_assgn_id_tmp_tab(l_dp_counter) := l_proj_res_assgn_id_tab(i);

            -- Bug 4548733: Populate l_calc_billable_flag_tab with billability
            -- flag values to pass to Calculate API.
            l_calc_billable_flag_tab.extend;
            l_calc_billable_flag_tab(l_dp_counter) := l_proj_billable_flag(i);
    END IF;
   END LOOP;

   -- Bug 4549862: Moved initialization of l_rev_gen_method before
   -- initialization of l_calculate_mode earlier in the code.

   IF p_fp_cols_rec.x_version_type = 'REVENUE' and l_rev_gen_method = 'C' THEN
        delete from pa_fp_calc_amt_tmp2;

        FOR i IN 1..l_res_assgn_id_tmp_tab.count LOOP
        SELECT SUM(quantity)
        INTO l_total_plan_quantity
        FROM pa_budget_lines
        WHERE resource_assignment_id = l_res_assgn_id_tmp_tab(i);  /* Bug 4093872 - Column name corrected from budget_version_id to resource_assignment_id */

            INSERT INTO pa_fp_calc_amt_tmp2(
            resource_assignment_id,
            total_plan_quantity)
        VALUES(
            l_res_assgn_id_tmp_tab(i),
            l_total_plan_quantity);
    END LOOP;
        IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
            PA_DEBUG.reset_err_stack;
        ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN;
   END IF;
    --dbms_output.put_line('gen_ret_manual_line_flag: '||p_fp_cols_rec.x_gen_ret_manual_line_flag);

/* Taken off the logic of checking if the Retain manually added plan lines flag
   is set to Y or N due to the new logic added. Bug 4046530   -sbhavsar         */


        FOR i IN 1..l_res_assgn_id_tmp_tab.count LOOP

                      l_delete_budget_lines_tab.extend;
                      l_spread_amts_flag_tab.extend;
                      l_txn_currency_code_tab.extend;
                      l_txn_currency_override_tab.extend;
                      l_total_qty_tab.extend;
                      l_addl_qty_tab.extend;
                      l_total_raw_cost_tab.extend;
                      l_addl_raw_cost_tab.extend;
                      l_total_burdened_cost_tab.extend;
                      l_addl_burdened_cost_tab.extend;
                      l_total_revenue_tab.extend;
                      l_addl_revenue_tab.extend;
                      l_raw_cost_rate_tab.extend;
                      l_rw_cost_rate_override_tab.extend;
                      l_b_cost_rate_tab.extend;
                      l_b_cost_rate_override_tab.extend;
                      l_bill_rate_tab.extend;
                      l_bill_rate_override_tab.extend;
                      l_line_start_date_tab.extend;
                      l_line_end_date_tab.extend;


                      l_delete_budget_lines_tab(i)     := Null;
                      l_spread_amts_flag_tab(i)        := Null;
                      l_txn_currency_code_tab(i)       := l_project_currency_code;
                      l_txn_currency_override_tab(i)   := Null;
                      l_total_qty_tab(i)               := Null;
                      l_addl_qty_tab(i)                := Null;
                      l_total_raw_cost_tab(i)          := Null;
                      l_addl_raw_cost_tab(i)           := Null;
                      l_total_burdened_cost_tab(i)     := Null;
                      l_addl_burdened_cost_tab(i)      := Null;
                      l_total_revenue_tab(i)           := Null;
                      l_addl_revenue_tab(i)            := Null;
                      l_raw_cost_rate_tab(i)           := Null;
                      l_rw_cost_rate_override_tab(i)   := Null;
                      l_b_cost_rate_tab(i)             := Null;
                      l_b_cost_rate_override_tab(i)    := Null;
                      l_bill_rate_tab(i)               := Null;
                      l_bill_rate_override_tab(i)      := Null;
                      l_line_start_date_tab(i)         := Null;
                      l_line_end_date_tab(i)           := Null;
      END LOOP;

    -- Bug 4149684: Added p_calling_module and p_rollup_required_flag to parameter list of
    -- Calculate API with values 'BUDGET_GENERATION' and 'N', respectively, so that calling
    -- PJI rollup api is bypassed for increased performance.

     /* Calling the calculate API */
         IF p_pa_debug_mode = 'Y' THEN
              pa_fp_gen_amount_utils.fp_debug
                  (p_called_mode => p_called_mode,
                   p_msg         => 'Before calling
                   pa_fp_calc_plan_pkg.calculate',
                   p_module_name => l_module_name,
                   p_log_level   => 5);
         END IF;

         -- Bug 4548733: Added a new pl/sql table to hold billability flag values for the
         -- Calculate API and passing it via the p_fp_task_billable_flag_tab IN parameter.

         PA_FP_CALC_PLAN_PKG.calculate
                      (p_calling_module              => l_calling_module
                      ,p_project_id                  => p_project_id
                      ,p_budget_version_id           => p_budget_version_id
                      ,p_refresh_rates_flag          => l_refresh_rates_flag
                      ,p_refresh_conv_rates_flag     => l_refresh_conv_rates_flag
                      ,p_spread_required_flag        => l_spread_required_flag
                      ,p_conv_rates_required_flag    => l_conv_rates_required_flag
                      ,p_rollup_required_flag        => l_rollup_required_flag
              ,p_mass_adjust_flag            => l_mass_adjust_flag
                      ,p_quantity_adj_pct            => l_quantity_adj_pct
                      ,p_cost_rate_adj_pct           => l_cost_rate_adj_pct
                      ,p_burdened_rate_adj_pct       => l_burdened_rate_adj_pct
                      ,p_bill_rate_adj_pct           => l_bill_rate_adj_pct
                      ,p_source_context              => l_source_context
                      ,p_resource_assignment_tab     => l_res_assgn_id_tmp_tab
                      ,p_delete_budget_lines_tab     => l_delete_budget_lines_tab
                      ,p_spread_amts_flag_tab        => l_spread_amts_flag_tab
                      ,p_txn_currency_code_tab       => l_txn_currency_code_tab
                      ,p_txn_currency_override_tab   => l_txn_currency_override_tab
                      ,p_total_qty_tab               => l_total_qty_tab
                      ,p_addl_qty_tab                => l_addl_qty_tab
                      ,p_total_raw_cost_tab          => l_total_raw_cost_tab
                      ,p_addl_raw_cost_tab           => l_addl_raw_cost_tab
                      ,p_total_burdened_cost_tab     => l_total_burdened_cost_tab
                      ,p_addl_burdened_cost_tab      => l_addl_burdened_cost_tab
                      ,p_total_revenue_tab           => l_total_revenue_tab
                      ,p_addl_revenue_tab            => l_addl_revenue_tab
                      ,p_raw_cost_rate_tab           => l_raw_cost_rate_tab
                      ,p_rw_cost_rate_override_tab   => l_rw_cost_rate_override_tab
              ,p_b_cost_rate_tab             => l_b_cost_rate_tab
                      ,p_b_cost_rate_override_tab    => l_b_cost_rate_override_tab
                      ,p_bill_rate_tab               => l_bill_rate_tab
                      ,p_bill_rate_override_tab      => l_bill_rate_override_tab
                      ,p_line_start_date_tab         => l_line_start_date_tab
                      ,p_line_end_date_tab           => l_line_end_date_tab
                      ,p_fp_task_billable_flag_tab   => l_calc_billable_flag_tab     /* Added for Bug 4548733 */
                      ,p_raTxn_rollup_api_call_flag  => l_raTxn_rollup_api_call_flag, --Added for IPM new entity ER
                       X_RETURN_STATUS               => X_RETURN_STATUS,
                       X_MSG_COUNT                   => X_MSG_COUNT,
                       X_MSG_DATA                => X_MSG_DATA);

       IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;
       IF p_pa_debug_mode = 'Y' THEN
           pa_fp_gen_amount_utils.fp_debug
           (p_called_mode => p_called_mode,
           p_msg         => 'Status after calling
           pa_fp_calc_plan_pkg.calculate: '
                        ||x_return_status,
                         p_module_name => l_module_name,
                         p_log_level   => 5);
       END IF;

   -- M-closeout: Bill Rate Override ER
   END IF; -- IF p_fp_cols_rec.x_version_type = 'ALL' ...
   -- END OF M-closeout: Bill Rate Override ER

   IF P_COMMIT_FLAG = 'Y' THEN
         COMMIT;
   END IF;

   IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
        PA_DEBUG.reset_err_stack;
   ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
        PA_DEBUG.Reset_Curr_Function;
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

      IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
          PA_DEBUG.reset_err_stack;
      ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
          PA_DEBUG.Reset_Curr_Function;
      END IF;

      RAISE;

  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      := SUBSTR(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_BUDGET_AMT_PUB'
              ,p_procedure_name => 'GENERATE_BUDGET_AMT_RES_SCH');

     IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
         PA_DEBUG.reset_err_stack;
     ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
         PA_DEBUG.Reset_Curr_Function;
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END GENERATE_BUDGET_AMT_RES_SCH;

PROCEDURE CREATE_RES_ASG
          (P_PROJECT_ID          IN   PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID   IN   PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_STRU_SHARING_CODE   IN   PA_PROJECTS_ALL.STRUCTURE_SHARING_CODE%TYPE,
       P_GEN_SRC_CODE        IN   PA_PROJ_FP_OPTIONS.GEN_ALL_SRC_CODE%TYPE,
           P_FP_COLS_REC         IN   PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_WP_STRUCTURE_VER_ID IN   PA_BUDGET_VERSIONS.PROJECT_STRUCTURE_VERSION_ID%TYPE,
           X_RETURN_STATUS       OUT  NOCOPY  VARCHAR2,
           X_MSG_COUNT           OUT  NOCOPY  NUMBER,
           X_MSG_DATA            OUT  NOCOPY  VARCHAR2) IS

l_module_name         VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_BUDGET_AMT_PUB.CREATE_RES_ASG';

--Cursor used when planning type is Project
CURSOR   RES_ASG1 IS
SELECT   T.RESOURCE_LIST_MEMBER_ID,
         MIN(T.TXN_PLANNING_START_DATE),
         MAX(T.TXN_PLANNING_END_DATE)
FROM     PA_RES_LIST_MAP_TMP4 T
WHERE    NOT EXISTS
                  (SELECT   /*+ INDEX(T,PA_RES_LIST_MAP_TMP4_N1)*/
                            P.RESOURCE_LIST_MEMBER_ID
                   FROM     PA_RESOURCE_ASSIGNMENTS P
                   WHERE    P.BUDGET_VERSION_ID           = P_BUDGET_VERSION_ID
                   AND      NVL(P.TASK_ID,0)              = 0
                   AND      P.PROJECT_ASSIGNMENT_ID       = -1
                   AND      T.RESOURCE_LIST_MEMBER_ID = P.RESOURCE_LIST_MEMBER_ID)
GROUP BY T.RESOURCE_LIST_MEMBER_ID;

--Cursor used when planning type is Lowest task (Financial task only)
CURSOR   RES_ASG2 IS
SELECT   T.RESOURCE_LIST_MEMBER_ID,
         NVL(T.TXN_TASK_ID,0),
         MIN(T.TXN_PLANNING_START_DATE),
         MAX(T.TXN_PLANNING_END_DATE)
FROM     PA_RES_LIST_MAP_TMP4 T
WHERE    NOT EXISTS
                  (SELECT   /*+ INDEX(T,PA_RES_LIST_MAP_TMP4_N1)*/ 1
                   FROM     PA_RESOURCE_ASSIGNMENTS P
                   WHERE    P.BUDGET_VERSION_ID           = P_BUDGET_VERSION_ID
                   AND      NVL(P.TASK_ID,0)              = NVL(T.TXN_TASK_ID,0)
                   AND      P.PROJECT_ASSIGNMENT_ID       = -1
                   AND      T.RESOURCE_LIST_MEMBER_ID = P.RESOURCE_LIST_MEMBER_ID)
GROUP BY T.RESOURCE_LIST_MEMBER_ID,
         NVL(T.TXN_TASK_ID,0);

--Cursor used when planning type is Top task(Financial task only)
CURSOR   RES_ASG3 IS
SELECT   T.RESOURCE_LIST_MEMBER_ID,
         NVL(PAT.TOP_TASK_ID,0),
         MIN(T.TXN_PLANNING_START_DATE),
         MAX(T.TXN_PLANNING_END_DATE)
FROM     PA_RES_LIST_MAP_TMP4 T,
         PA_TASKS PAT
WHERE    NVL(T.TXN_TASK_ID,0) > 0
AND      NVL(T.TXN_TASK_ID,0) = PAT.TASK_ID
AND      NOT EXISTS
                  (SELECT   /*+ INDEX(T,PA_RES_LIST_MAP_TMP4_N1)*/ 1
                   FROM     PA_RESOURCE_ASSIGNMENTS P,PA_TASKS TS
                   WHERE    P.BUDGET_VERSION_ID           = P_BUDGET_VERSION_ID
                   AND      NVL(T.TXN_TASK_ID,0)          > 0
                   AND      TS.TASK_ID                    = NVL(T.TXN_TASK_ID,0)
                   AND      NVL(TS.TOP_TASK_ID,0)         = NVL(P.TASK_ID,0)
                   AND      P.PROJECT_ASSIGNMENT_ID       = -1
                   AND      T.RESOURCE_LIST_MEMBER_ID = P.RESOURCE_LIST_MEMBER_ID)
GROUP BY T.RESOURCE_LIST_MEMBER_ID,
         NVL(PAT.TOP_TASK_ID,0)
UNION
SELECT   T.RESOURCE_LIST_MEMBER_ID,
         0,
         MIN(T.TXN_PLANNING_START_DATE),
         MAX(T.TXN_PLANNING_END_DATE)
FROM     PA_RES_LIST_MAP_TMP4 T
WHERE    NVL(T.TXN_TASK_ID,0) = 0
AND      NOT EXISTS
                  (SELECT   /*+ INDEX(T,PA_RES_LIST_MAP_TMP4_N1)*/ 1
                   FROM     PA_RESOURCE_ASSIGNMENTS P
                   WHERE    P.BUDGET_VERSION_ID           = P_BUDGET_VERSION_ID
                   AND      NVL(T.TXN_TASK_ID,0)          = 0
                   AND      NVL(P.TASK_ID,0)              = 0
                   AND      P.RESOURCE_LIST_MEMBER_ID     = T.RESOURCE_LIST_MEMBER_ID
                   AND      P.PROJECT_ASSIGNMENT_ID       = -1)
GROUP BY T.RESOURCE_LIST_MEMBER_ID,
         0;

/*  Cursor used when planning type is Lowest task
   (both Financial task and Workplan task)  */
/* the union clause takes care of bringing the project level records. */
CURSOR   RES_ASG4 IS
SELECT   T.RESOURCE_LIST_MEMBER_ID resource_list_member_id,
         NVL(V1.MAPPED_FIN_TASK_ID,0) mapped_fin_task_id,
         NVL(V1.MAPPED_FIN_TASK_VERSION_ID,0) mapped_fin_task_version_id,
         MIN(T.TXN_PLANNING_START_DATE) txn_planning_start_date,
         MAX(T.TXN_PLANNING_END_DATE)  txn_planning_end_date
FROM     PA_RES_LIST_MAP_TMP4 T,
         PA_MAP_WP_TO_FIN_TASKS_V V1
WHERE    NOT EXISTS
                  (SELECT   /*+ INDEX(T,PA_RES_LIST_MAP_TMP4_N1)*/ 1
                   FROM     PA_RESOURCE_ASSIGNMENTS P,PA_MAP_WP_TO_FIN_TASKS_V V
                   WHERE    P.BUDGET_VERSION_ID           = P_BUDGET_VERSION_ID
                   AND      V.PARENT_STRUCTURE_VERSION_ID = P_WP_STRUCTURE_VER_ID
                   AND      nvl(T.TXN_TASK_ID,0)          = NVL(V.PROJ_ELEMENT_ID,0)
                   AND      P.PROJECT_ASSIGNMENT_ID       = -1
                   AND      T.RESOURCE_LIST_MEMBER_ID     = P.RESOURCE_LIST_MEMBER_ID
           AND      NVL(V.MAPPED_FIN_TASK_ID,0)   = NVL(P.TASK_ID,0))
AND      V1.PARENT_STRUCTURE_VERSION_ID = P_WP_STRUCTURE_VER_ID
AND      NVL(T.TXN_TASK_ID,0)           = NVL(V1.PROJ_ELEMENT_ID,0)
AND      NVL(T.TXN_TASK_ID,0) > 0
GROUP BY
         T.RESOURCE_LIST_MEMBER_ID,
         NVL(V1.MAPPED_FIN_TASK_ID,0),
         NVL(V1.MAPPED_FIN_TASK_VERSION_ID,0)
union
SELECT   T.RESOURCE_LIST_MEMBER_ID resource_list_member_id,
         0 mapped_fin_task_id,
         0 mapped_fin_task_version_id,
         MIN(T.TXN_PLANNING_START_DATE) txn_planning_start_date,
         MAX(T.TXN_PLANNING_END_DATE) txn_planning_end_date
FROM     PA_RES_LIST_MAP_TMP4 T
WHERE    NVL(T.TXN_TASK_ID,0) = 0 AND
         NOT EXISTS
                  (SELECT   /*+ INDEX(T,PA_RES_LIST_MAP_TMP4_N1)*/ 1
                   FROM     PA_RESOURCE_ASSIGNMENTS P
                   WHERE    P.BUDGET_VERSION_ID           = P_BUDGET_VERSION_ID
                   AND      P.PROJECT_ASSIGNMENT_ID       = -1
                   AND      T.RESOURCE_LIST_MEMBER_ID     = P.RESOURCE_LIST_MEMBER_ID
                   AND      NVL(P.TASK_ID,0) = 0   )
GROUP BY T.RESOURCE_LIST_MEMBER_ID,
         0,
         0;

/* Cursor used when planning type is Top task
   (both Financial task and Workplan task)*/
CURSOR   RES_ASG5 IS
SELECT   T.RESOURCE_LIST_MEMBER_ID,
         NVL(PAT.TOP_TASK_ID,0),
         NVL(pa_proj_elements_utils.get_task_version_id(
             v1.MAPPED_FIN_STR_VERSION_ID,pat.top_task_id),0),
         MIN(T.TXN_PLANNING_START_DATE),
         MAX(T.TXN_PLANNING_END_DATE)
FROM     PA_RES_LIST_MAP_TMP4 T,
         PA_TASKS PAT,
         PA_MAP_WP_TO_FIN_TASKS_V V1
WHERE    NVL(V1.MAPPED_FIN_TASK_ID,0) = PAT.TASK_ID (+)
AND      NOT EXISTS
                  (SELECT   /*+ INDEX(T,PA_RES_LIST_MAP_TMP4_N1)*/ 1
                   FROM     PA_RESOURCE_ASSIGNMENTS P,PA_TASKS TS,PA_MAP_WP_TO_FIN_TASKS_V V
                   WHERE    P.BUDGET_VERSION_ID           = P_BUDGET_VERSION_ID
                   AND      V.PARENT_STRUCTURE_VERSION_ID = P_WP_STRUCTURE_VER_ID
               AND      NVL(T.TXN_TASK_ID,0)      = NVL(V.PROJ_ELEMENT_ID,0)
                   AND      TS.TASK_ID(+)                 = NVL(V.MAPPED_FIN_TASK_ID,0)
                   AND      P.PROJECT_ASSIGNMENT_ID       = -1
                   AND      T.RESOURCE_LIST_MEMBER_ID     = P.RESOURCE_LIST_MEMBER_ID
                   AND      NVL(TS.TOP_TASK_ID,0)     = NVL(P.TASK_ID,0))
AND      V1.PARENT_STRUCTURE_VERSION_ID = P_WP_STRUCTURE_VER_ID
AND      NVL(T.TXN_TASK_ID,0)          =  NVL(V1.PROJ_ELEMENT_ID,0)
AND      NVL(T.TXN_TASK_ID,0) > 0
GROUP BY T.RESOURCE_LIST_MEMBER_ID,
         NVL(PAT.TOP_TASK_ID,0),
         NVL(pa_proj_elements_utils.get_task_version_id(
             v1.MAPPED_FIN_STR_VERSION_ID,pat.top_task_id),0)
union
SELECT   T.RESOURCE_LIST_MEMBER_ID resource_list_member_id,
         0,
         0,
         MIN(T.TXN_PLANNING_START_DATE) txn_planning_start_date,
         MAX(T.TXN_PLANNING_END_DATE) txn_planning_end_date
FROM     PA_RES_LIST_MAP_TMP4 T
WHERE    NVL(T.TXN_TASK_ID,0) = 0 AND
     NOT EXISTS
                  (SELECT   /*+ INDEX(T,PA_RES_LIST_MAP_TMP4_N1)*/ 1
                   FROM     PA_RESOURCE_ASSIGNMENTS P
                   WHERE    P.BUDGET_VERSION_ID           = P_BUDGET_VERSION_ID
                   AND      P.PROJECT_ASSIGNMENT_ID       = -1
                   AND      T.RESOURCE_LIST_MEMBER_ID     = P.RESOURCE_LIST_MEMBER_ID
                   AND      NVL(P.TASK_ID,0)              = 0)
GROUP BY T.RESOURCE_LIST_MEMBER_ID, 0,
         0;



l_stru_sharing_code         PA_PROJECTS_ALL.STRUCTURE_SHARING_CODE%TYPE;
l_unique_rlm_id_tab         PA_PLSQL_DATATYPES.IdTabTyp;
l_res_list_member_id        PA_PLSQL_DATATYPES.IdTabTyp;
l_task_id                   PA_PLSQL_DATATYPES.IdTabTyp;
l_mapped_fin_task_version_id PA_PLSQL_DATATYPES.IdTabTyp;
l_start_date_tab            PA_PLSQL_DATATYPES.DateTabTyp;
l_end_date_tab              PA_PLSQL_DATATYPES.DateTabTyp;
l_last_updated_by           NUMBER := FND_GLOBAL.user_id;
l_last_update_login         NUMBER := FND_GLOBAL.login_id;
l_sysdate                   DATE   := SYSDATE;
l_ret_status                VARCHAR2(100);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);
l_data                      VARCHAR2(2000);
l_msg_index_out             NUMBER:=0;
l_project_id                NUMBER(15);

--Local Variables for calling get_resource_defaults API
l_da_resource_list_members_tab             SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
l_da_resource_class_flag_tab               SYSTEM.PA_VARCHAR2_1_TBL_TYPE;
l_da_resource_class_code_tab               SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_da_resource_class_id_tab         SYSTEM.PA_NUM_TBL_TYPE;
l_da_res_type_code_tab                 SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_da_person_id_tab             SYSTEM.PA_NUM_TBL_TYPE;
l_da_job_id_tab                SYSTEM.PA_NUM_TBL_TYPE;
l_da_person_type_code_tab          SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_da_named_role_tab            SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
l_da_bom_resource_id_tab           SYSTEM.PA_NUM_TBL_TYPE;
l_da_non_labor_resource_tab        SYSTEM.PA_VARCHAR2_20_TBL_TYPE;
l_da_inventory_item_id_tab         SYSTEM.PA_NUM_TBL_TYPE;
l_da_item_category_id_tab          SYSTEM.PA_NUM_TBL_TYPE;
l_da_project_role_id_tab           SYSTEM.PA_NUM_TBL_TYPE;
l_da_organization_id_tab           SYSTEM.PA_NUM_TBL_TYPE;
l_da_fc_res_type_code_tab          SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_da_expenditure_type_tab          SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_da_expenditure_category_tab              SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_da_event_type_tab            SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_da_revenue_category_code_tab             SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_da_supplier_id_tab               SYSTEM.PA_NUM_TBL_TYPE;
l_da_spread_curve_id_tab           SYSTEM.PA_NUM_TBL_TYPE;
l_da_etc_method_code_tab           SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_da_mfc_cost_type_id_tab          SYSTEM.PA_NUM_TBL_TYPE;
l_da_incurred_by_res_flag_tab              SYSTEM.PA_VARCHAR2_1_TBL_TYPE;
l_da_incur_by_res_cls_code_tab             SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_da_incur_by_role_id_tab          SYSTEM.PA_NUM_TBL_TYPE;
l_da_unit_of_measure_tab           SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_da_org_id_tab                SYSTEM.PA_NUM_TBL_TYPE;
l_da_rate_based_flag_tab           SYSTEM.PA_VARCHAR2_1_TBL_TYPE;
l_da_rate_expenditure_type_tab             SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_da_rate_func_curr_code_tab               SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_da_incur_by_res_type_tab         SYSTEM.PA_VARCHAR2_30_TBL_TYPE;

/* Performance-Variables to replace the literals in the Insert into
   pa_resource_assignments stmts. */
l_task_id_01                               NUMBER:=0;
l_proj_asg_id_minus1             NUMBER:=-1;
l_res_as_type_USER_ENTERED         VARCHAR2(30):='USER_ENTERED';
l_rec_ver_number_1                         NUMBER:=1;

l_count                                    NUMBER;
l_count1                                   NUMBER;
l_wp_version_flag                          pa_budget_Versions.wp_version_flag%TYPE;
l_gen_src_code                             pa_proj_fp_options.gen_all_src_code%TYPE := null;

--Bug 4052036. This tbl will hold the ra ids that are inserted in this API
l_ins_ra_id_tbl                            SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
BEGIN
    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    l_project_id := p_project_id;

    IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.SET_CURR_FUNCTION
            ( p_function     => 'CREATE_RES_ASG',
              p_debug_mode   =>  p_pa_debug_mode );
    END IF;

    l_stru_sharing_code :=
        PA_PROJECT_STRUCTURE_UTILS.GET_STRUCTURE_SHARING_CODE
            ( P_PROJECT_ID=> P_PROJECT_ID );

    /* bug 4160375 The generation source code should always be populated
       whenever the planning resources are created. The source could be
       the primary source (FP / WP / Res Sch) or the additional options. */

    l_gen_src_code := p_gen_src_code;

    IF P_FP_COLS_REC.X_FIN_PLAN_LEVEL_CODE = 'P' OR P_GEN_SRC_CODE = 'RESOURCE_SCHEDULE' THEN
      OPEN RES_ASG1;
      FETCH    RES_ASG1
      BULK     COLLECT
      INTO     l_res_list_member_id,
               l_start_date_tab,
               l_end_date_tab;
      CLOSE RES_ASG1;

      IF l_res_list_member_id.count = 0 THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
         END IF;
         RETURN;
      END IF;

      SELECT NVL(wp_version_flag,'N')
      INTO   l_wp_version_flag
      FROM   pa_budget_versions
      WHERE  budget_version_id=P_BUDGET_VERSION_ID;

      FORALL i IN 1..l_res_list_member_id.count
        INSERT INTO PA_RESOURCE_ASSIGNMENTS(RESOURCE_ASSIGNMENT_ID,
                                            BUDGET_VERSION_ID,
                                            PROJECT_ID,
                                            TASK_ID,
                                            RESOURCE_LIST_MEMBER_ID,
                                            LAST_UPDATE_DATE,
                                            LAST_UPDATED_BY,
                                            CREATION_DATE,
                                            CREATED_BY,
                                            LAST_UPDATE_LOGIN,
                                            PROJECT_ASSIGNMENT_ID,
                                            resource_assignment_type,
                                            record_version_number,
                                            planning_start_date,
                                            planning_end_date,
                                            transaction_source_code)
                                    VALUES (PA_RESOURCE_ASSIGNMENTS_S.nextval,
                                            P_BUDGET_VERSION_ID,
                                            P_PROJECT_ID,
                                            l_task_id_01,
                                            l_res_list_member_id(i),
                                            l_sysdate,
                                            l_last_updated_by,
                                            l_sysdate,
                                            l_last_updated_by,
                                            l_last_update_login,
                                            l_proj_asg_id_minus1 ,
                                            l_res_as_type_USER_ENTERED,
                                            l_rec_ver_number_1 ,
                                            l_start_date_tab(i),
                                            l_end_date_tab(i),
                                            l_gen_src_code )
                                    RETURNING resource_assignment_id BULK COLLECT INTO l_ins_ra_id_tbl;

    ELSIF   P_FP_COLS_REC.X_FIN_PLAN_LEVEL_CODE = 'L'
            AND (l_stru_sharing_code IS NULL OR
                 l_stru_sharing_code = 'SHARE_FULL' OR
                  P_GEN_SRC_CODE IN ( 'FINANCIAL_PLAN',
                  'OPEN_COMMITMENTS','BILLING_EVENTS'  )) THEN

      OPEN RES_ASG2;
      FETCH    RES_ASG2
      BULK     COLLECT
      INTO     l_res_list_member_id,
               l_task_id,
               l_start_date_tab,
               l_end_date_tab;
      CLOSE RES_ASG2;

      IF l_res_list_member_id.count = 0 then
         IF P_PA_DEBUG_MODE = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
         END IF;
         RETURN;
      END IF;

      FORALL i IN 1..l_res_list_member_id.count
        INSERT INTO PA_RESOURCE_ASSIGNMENTS(RESOURCE_ASSIGNMENT_ID,
                                            BUDGET_VERSION_ID,
                                            PROJECT_ID,
                                            TASK_ID,
                                            RESOURCE_LIST_MEMBER_ID,
                                            LAST_UPDATE_DATE,
                                            LAST_UPDATED_BY,
                                            CREATION_DATE,
                                            CREATED_BY,
                                            LAST_UPDATE_LOGIN,
                                            PROJECT_ASSIGNMENT_ID,
                                            resource_assignment_type,
                                            record_version_number,
                                            planning_start_date,
                                            planning_end_date,
                                            transaction_source_code)
                                    VALUES (PA_RESOURCE_ASSIGNMENTS_S.nextval,
                                            P_BUDGET_VERSION_ID,
                                            P_PROJECT_ID,
                                            l_task_id(i),
                                            l_res_list_member_id(i),
                                            l_sysdate,
                                            l_last_updated_by,
                                            l_sysdate,
                                            l_last_updated_by,
                                            l_last_update_login,
                                            l_proj_asg_id_minus1,
                                            l_res_as_type_USER_ENTERED,
                                            l_rec_ver_number_1,
                                            l_start_date_tab(i),
                                            l_end_date_tab(i),
                                            l_gen_src_code )
                                    RETURNING resource_assignment_id BULK COLLECT INTO l_ins_ra_id_tbl;
   ELSIF  P_FP_COLS_REC.X_FIN_PLAN_LEVEL_CODE = 'T'
          AND (  l_stru_sharing_code IS NULL OR
                 l_stru_sharing_code = 'SHARE_FULL' OR
         P_GEN_SRC_CODE IN ( 'FINANCIAL_PLAN',
                 'OPEN_COMMITMENTS','BILLING_EVENTS'  )) THEN

       OPEN RES_ASG3;
       FETCH    RES_ASG3
       BULK     COLLECT
       INTO     l_res_list_member_id,
                l_task_id,
                l_start_date_tab,
                l_end_date_tab;
       CLOSE RES_ASG3;

      IF l_res_list_member_id.count = 0 then
         IF P_PA_DEBUG_MODE = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
         END IF;
         RETURN;
      END IF;
      FORALL i IN 1..l_res_list_member_id.count
        INSERT INTO PA_RESOURCE_ASSIGNMENTS(RESOURCE_ASSIGNMENT_ID,
                                            BUDGET_VERSION_ID,
                                            PROJECT_ID,
                                            TASK_ID,
                                            RESOURCE_LIST_MEMBER_ID,
                                            LAST_UPDATE_DATE,
                                            LAST_UPDATED_BY,
                                            CREATION_DATE,
                                            CREATED_BY,
                                            LAST_UPDATE_LOGIN,
                                            PROJECT_ASSIGNMENT_ID,
                                            resource_assignment_type,
                                            record_version_number,
                                            planning_start_date,
                                            planning_end_date,
                                            transaction_source_code)
                                    VALUES (PA_RESOURCE_ASSIGNMENTS_S.nextval,
                                            P_BUDGET_VERSION_ID,
                                            P_PROJECT_ID,
                                            l_task_id(i),
                                            l_res_list_member_id(i),
                                            l_sysdate,
                                            l_last_updated_by,
                                            l_sysdate,
                                            l_last_updated_by,
                                            l_last_update_login,
                                            l_proj_asg_id_minus1,
                                            l_res_as_type_USER_ENTERED,
                                            l_rec_ver_number_1,
                                            l_start_date_tab(i),
                                            l_end_date_tab(i),
                                            l_gen_src_code )
                                    RETURNING resource_assignment_id BULK COLLECT INTO l_ins_ra_id_tbl;

  ELSIF   P_FP_COLS_REC.X_FIN_PLAN_LEVEL_CODE = 'L'
          AND l_stru_sharing_code IS NOT NULL THEN
      --dbms_output.put('before res_asg4 cursor');

      --dbms_output.put('p_wp_structure_ver_id'||p_wp_structure_ver_id);
      --insert into ltmp4 select * from PA_RES_LIST_MAP_TMP4;
      --insert into lra select * from pa_resource_assignments where budget_version_id = p_budget_version_id;
      OPEN RES_ASG4;
      FETCH    RES_ASG4
      BULK     COLLECT
      INTO     l_res_list_member_id,
               l_task_id,
               l_mapped_fin_task_version_id,
               l_start_date_tab,
               l_end_date_tab;
      CLOSE RES_ASG4;

     IF l_res_list_member_id.count = 0 then
         IF P_PA_DEBUG_MODE = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
         END IF;
        RETURN;
     END IF;
     IF P_PA_DEBUG_MODE = 'Y' THEN
        FOR i IN 1..l_res_list_member_id.count LOOP
        pa_fp_gen_amount_utils.fp_debug
                  (p_msg         => 'in res_asg4:@@rlm in cursor:'||l_res_list_member_id(i)
                                    ||'; @@task in cursor:'||l_task_id(i)
                    ||';@@start date in cursor:'||l_start_date_tab(i)
                    ||';@@end date in cursor:'||l_end_date_tab(i),
                   p_module_name => l_module_name,
                   p_log_level   => 5);
    END LOOP;
     END IF;
     --dbms_output.put_line('before insert in pa ra');
     --FOR i IN 1..l_res_list_member_id.count LOOP
    --dbms_output.put_line('--i--'||i);
    --dbms_output.put_line('l_res_list_member_id:'||l_res_list_member_id(i));
        --dbms_output.put_line('l_task_id:'||l_task_id(i));
     --END LOOP;
     --commit;
     FORALL i IN 1..l_res_list_member_id.count
        INSERT INTO PA_RESOURCE_ASSIGNMENTS(RESOURCE_ASSIGNMENT_ID,
                                            BUDGET_VERSION_ID,
                                            PROJECT_ID,
                                            TASK_ID,
                                            RESOURCE_LIST_MEMBER_ID,
                                            LAST_UPDATE_DATE,
                                            LAST_UPDATED_BY,
                                            CREATION_DATE,
                                            CREATED_BY,
                                            LAST_UPDATE_LOGIN,
                                            PROJECT_ASSIGNMENT_ID,
                                            resource_assignment_type,
                                            planning_start_Date,
                                            planning_end_date,
                                            record_version_number,
                                            wbs_element_version_id,
                                            transaction_source_code)
                                    VALUES (PA_RESOURCE_ASSIGNMENTS_S.nextval,
                                            P_BUDGET_VERSION_ID,
                                            P_PROJECT_ID,
                                            l_task_id(i),
                                            l_res_list_member_id(i),
                                            l_sysdate,
                                            l_last_updated_by,
                                            l_sysdate,
                                            l_last_updated_by,
                                            l_last_update_login,
                                            l_proj_asg_id_minus1,
                                            l_res_as_type_USER_ENTERED,
                                            l_start_date_tab(i),
                                            l_end_date_tab(i),
                                            l_rec_ver_number_1,
                                            DECODE(l_wp_version_flag,'Y',l_mapped_fin_task_version_id(i),
                                                   NULL),
                                            l_gen_src_code )
                                    RETURNING resource_assignment_id BULK COLLECT INTO l_ins_ra_id_tbl;

   ELSIF  P_FP_COLS_REC.X_FIN_PLAN_LEVEL_CODE = 'T' AND l_stru_sharing_code IS NOT NULL THEN

       OPEN RES_ASG5;
       FETCH    RES_ASG5
       BULK     COLLECT
       INTO     l_res_list_member_id,
                l_task_id,
                l_mapped_fin_task_version_id,
                l_start_date_tab,
                l_end_date_tab;
       CLOSE RES_ASG5;

    IF l_res_list_member_id.count = 0 then
         IF P_PA_DEBUG_MODE = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
         END IF;
       RETURN;
    END IF;
    FORALL i IN 1..l_res_list_member_id.count
        INSERT INTO PA_RESOURCE_ASSIGNMENTS(RESOURCE_ASSIGNMENT_ID,
                                            BUDGET_VERSION_ID,
                                            PROJECT_ID,
                                            TASK_ID,
                                            RESOURCE_LIST_MEMBER_ID,
                                            LAST_UPDATE_DATE,
                                            LAST_UPDATED_BY,
                                            CREATION_DATE,
                                            CREATED_BY,
                                            LAST_UPDATE_LOGIN,
                                            PROJECT_ASSIGNMENT_ID,
                                            resource_assignment_type,
                                            record_version_number,
                                            wbs_element_version_id,
                                            planning_start_date,
                                            planning_end_date,
                                            transaction_source_code)
                                    VALUES (PA_RESOURCE_ASSIGNMENTS_S.nextval,
                                            P_BUDGET_VERSION_ID,
                                            P_PROJECT_ID,
                                            l_task_id(i),
                                            l_res_list_member_id(i),
                                            l_sysdate,
                                            l_last_updated_by,
                                            l_sysdate,
                                            l_last_updated_by,
                                            l_last_update_login,
                                            l_proj_asg_id_minus1,
                                            l_res_as_type_USER_ENTERED,
                                            l_rec_ver_number_1,
                                            DECODE(l_wp_version_flag,'Y',l_mapped_fin_task_version_id(i),
                                                   NULL),
                                            l_start_date_tab(i),
                                            l_end_date_tab(i),
                                            l_gen_src_code )
                                    RETURNING resource_assignment_id BULK COLLECT INTO l_ins_ra_id_tbl;
   END IF;

   IF SQL%ROWCOUNT = 0 THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
         END IF;
      RETURN;
   END IF;
   --dbms_output.put_line('before res_list_map');
    /* we need to pass only distinct
    RLM ids to the get res defa API */
    DELETE from pa_res_list_map_tmp1;

    FORALL pp in 1 .. l_res_list_member_id.count
    INSERT INTO  pa_res_list_map_tmp1
                (txn_resource_list_member_id)
           VALUES
                (l_res_list_member_id(pp));

    l_unique_rlm_id_tab.delete;

    SELECT DISTINCT txn_resource_list_member_id
    BULK   COLLECT
    INTO   l_unique_rlm_id_tab
    FROM   pa_res_list_map_tmp1;

    DELETE FROM pa_res_list_map_tmp1;

    FOR kk in 1 .. l_unique_rlm_id_tab.count LOOP
         l_da_resource_list_members_tab.extend;
         l_da_resource_list_members_tab(kk) := l_unique_rlm_id_tab(kk);
    END LOOP;

    --Calling resource defualt API
          IF p_pa_debug_mode = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
                   (p_msg         => 'Before calling
                    pa_planning_resource_utils.get_resource_defaults',
                    p_module_name => l_module_name,
                    p_log_level   => 5);
         END IF;
     --dbms_output.put_line('before get_resource_defaults:'||x_return_status);
     --dbms_output.put_line('project_id:'||p_project_id);
     --dbms_output.put_line('l_da_resource_list_members_tab.count'||l_da_resource_list_members_tab.count);
     --for i in 1..l_da_resource_list_members_tab.count loop
     --dbms_output.put_line('l_da_resource_list_members_tab(i)'||l_da_resource_list_members_tab(i));
     --end loop;
     PA_PLANNING_RESOURCE_UTILS.get_resource_defaults (
     P_resource_list_members      => l_da_resource_list_members_tab,
     P_project_id         => p_project_id,
     X_resource_class_flag    => l_da_resource_class_flag_tab,
     X_resource_class_code    => l_da_resource_class_code_tab,
     X_resource_class_id      => l_da_resource_class_id_tab,
     X_res_type_code          => l_da_res_type_code_tab,
     X_incur_by_res_type          => l_da_incur_by_res_type_tab,
     X_person_id              => l_da_person_id_tab,
     X_job_id             => l_da_job_id_tab,
     X_person_type_code           => l_da_person_type_code_tab,
     X_named_role         => l_da_named_role_tab,
     X_bom_resource_id        => l_da_bom_resource_id_tab,
     X_non_labor_resource         => l_da_non_labor_resource_tab,
     X_inventory_item_id      => l_da_inventory_item_id_tab,
     X_item_category_id           => l_da_item_category_id_tab,
     X_project_role_id        => l_da_project_role_id_tab,
     X_organization_id        => l_da_organization_id_tab,
     X_fc_res_type_code           => l_da_fc_res_type_code_tab,
     X_expenditure_type           => l_da_expenditure_type_tab,
     X_expenditure_category   => l_da_expenditure_category_tab,
     X_event_type         => l_da_event_type_tab,
     X_revenue_category_code      => l_da_revenue_category_code_tab,
     X_supplier_id        => l_da_supplier_id_tab,
     X_spread_curve_id        => l_da_spread_curve_id_tab,
     X_etc_method_code        => l_da_etc_method_code_tab,
     X_mfc_cost_type_id           => l_da_mfc_cost_type_id_tab,
     X_incurred_by_res_flag   => l_da_incurred_by_res_flag_tab,
     X_incur_by_res_class_code    => l_da_incur_by_res_cls_code_tab,
     X_incur_by_role_id           => l_da_incur_by_role_id_tab,
     X_unit_of_measure        => l_da_unit_of_measure_tab,
     X_org_id             => l_da_org_id_tab,
     X_rate_based_flag        => l_da_rate_based_flag_tab,
     X_rate_expenditure_type      => l_da_rate_expenditure_type_tab,
     X_rate_func_curr_code    => l_da_rate_func_curr_code_tab,
     X_msg_data           => X_MSG_DATA,
     X_msg_count              => X_MSG_COUNT,
     X_return_status          => X_RETURN_STATUS);
     --dbms_output.put_line('after get_resource_defaults:'||x_return_status);
     IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;
     IF p_pa_debug_mode = 'Y' THEN
          pa_fp_gen_amount_utils.fp_debug
                (p_msg         => 'Status after calling
                 pa_planning_resource_utils.get_resource_defaults'
                                          ||x_return_status,
                 p_module_name => l_module_name,
                 p_log_level   => 5);
       END IF;

     IF p_gen_src_code = 'RESOURCE_SCHEDULE' THEN
        FOR jj in 1..l_da_spread_curve_id_tab.count LOOP
             l_da_spread_curve_id_tab(jj) := null;
        END LOOP;
     END IF;

    -- IPM: At the time of resource creation, the resource_rate_based_flag
    -- should be set based on the default rate_based_flag for the resource.
    -- Modified the Update statement below to set resource_rate_based_flag.

    --Bug 4052036. Changed the check in the where clause to identify the resource assignments that got inserted
    --thru this API.
    FORALL i IN 1 .. l_da_resource_list_members_tab.count
        UPDATE PA_RESOURCE_ASSIGNMENTS
        SET    RESOURCE_CLASS_FLAG         = l_da_resource_class_flag_tab(i),
               RESOURCE_CLASS_CODE         = l_da_resource_class_code_tab(i),
               RES_TYPE_CODE               = l_da_res_type_code_tab(i),
               PERSON_ID                   = l_da_person_id_tab(i),
               JOB_ID                      = l_da_job_id_tab(i),
               PERSON_TYPE_CODE            = l_da_person_type_code_tab(i),
               NAMED_ROLE                  = l_da_named_role_tab(i),
               BOM_RESOURCE_ID             = l_da_bom_resource_id_tab(i),
               NON_LABOR_RESOURCE          = l_da_non_labor_resource_tab(i),
               INVENTORY_ITEM_ID           = l_da_inventory_item_id_tab(i),
               ITEM_CATEGORY_ID            = l_da_item_category_id_tab(i),
               PROJECT_ROLE_ID             = l_da_project_role_id_tab(i),
               ORGANIZATION_ID             = l_da_organization_id_tab(i),
               FC_RES_TYPE_CODE            = l_da_fc_res_type_code_tab(i),
               EXPENDITURE_TYPE            = l_da_expenditure_type_tab(i),
               EXPENDITURE_CATEGORY        = l_da_expenditure_category_tab(i),
               EVENT_TYPE                  = l_da_event_type_tab(i),
               REVENUE_CATEGORY_CODE       = l_da_revenue_category_code_tab(i),
               SUPPLIER_ID                 = l_da_supplier_id_tab(i),
               SPREAD_CURVE_ID             = l_da_spread_curve_id_tab(i),
               ETC_METHOD_CODE             = l_da_etc_method_code_tab(i),
               MFC_COST_TYPE_ID            = l_da_mfc_cost_type_id_tab(i),
               INCURRED_BY_RES_FLAG        = l_da_incurred_by_res_flag_tab(i),
               INCUR_BY_RES_CLASS_CODE     = l_da_incur_by_res_cls_code_tab(i),
               INCUR_BY_ROLE_ID            = l_da_incur_by_role_id_tab(i),
               UNIT_OF_MEASURE             = l_da_unit_of_measure_tab(i),
               RATE_BASED_FLAG             = l_da_rate_based_flag_tab(i),
               RESOURCE_RATE_BASED_FLAG    = l_da_rate_based_flag_tab(i), -- Added for IPM ER
               RATE_EXPENDITURE_TYPE       = l_da_rate_expenditure_type_tab(i),
               RATE_EXP_FUNC_CURR_CODE     = l_da_rate_func_curr_code_tab(i),
               LAST_UPDATE_DATE            = l_sysdate,
               LAST_UPDATED_BY             = l_last_updated_by,
               CREATION_DATE               = l_sysdate,
               CREATED_BY                  = l_last_updated_by,
               LAST_UPDATE_LOGIN           = l_last_update_login,
               RATE_EXPENDITURE_ORG_ID     = l_da_org_id_tab(i)
        WHERE  budget_version_id           = p_budget_version_id
        AND    RESOURCE_LIST_MEMBER_ID     = l_da_resource_list_members_tab(i)
        AND    (resource_assignment_id
                BETWEEN l_ins_ra_id_tbl(l_ins_ra_id_tbl.FIRST) AND l_ins_ra_id_tbl(l_ins_ra_id_tbl.LAST));

    IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_Curr_Function;
    END IF;
  RETURN;

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
          PA_DEBUG.Reset_Curr_Function;
      END IF;
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      := SUBSTR(SQLERRM,1,240);
      -- dbms_output.put_line('inside excep create res asg');
      -- dbms_output.put_line(SUBSTR(SQLERRM,1,240));
     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_BUDGET_AMT_PUB'
              ,p_procedure_name => 'CREATE_RES_ASG');

     IF P_PA_DEBUG_MODE = 'Y' THEN
         PA_DEBUG.Reset_Curr_Function;
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

 END CREATE_RES_ASG;


/* Procedure to update the reosurce_assignment_id
   in the resource assignment table*/
PROCEDURE UPDATE_RES_ASG
          (P_PROJECT_ID          IN   PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID   IN   PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_STRU_SHARING_CODE   IN   PA_PROJECTS_ALL.STRUCTURE_SHARING_CODE%TYPE,
       P_GEN_SRC_CODE        IN   PA_PROJ_FP_OPTIONS.GEN_ALL_SRC_CODE%TYPE,
           P_FP_COLS_REC         IN   PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
       P_WP_STRUCTURE_VER_ID IN   PA_BUDGET_VERSIONS.PROJECT_STRUCTURE_VERSION_ID%TYPE,
           X_RETURN_STATUS       OUT  NOCOPY  VARCHAR2,
           X_MSG_COUNT           OUT  NOCOPY  NUMBER,
           X_MSG_DATA            OUT  NOCOPY  VARCHAR2) IS

l_module_name         VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_BUDGET_AMT_PUB.UPDATE_RES_ASG';

l_stru_sharing_code            PA_PROJECTS_ALL.STRUCTURE_SHARING_CODE%TYPE;

l_res_assgn_id_tab             PA_PLSQL_DATATYPES.IdTabTyp;
l_res_assgn_id_del_tab         PA_PLSQL_DATATYPES.IdTabTyp;
l_rlm_id_tab                   PA_PLSQL_DATATYPES.IdTabTyp;
l_txn_task_id_tab              PA_PLSQL_DATATYPES.IdTabTyp;
l_txn_top_task_id_tab          PA_PLSQL_DATATYPES.IdTabTyp;
l_txn_sub_task_id_tab          PA_PLSQL_DATATYPES.IdTabTyp;
l_mapped_task_id_tab           PA_PLSQL_DATATYPES.IdTabTyp;

l_count number;
l_project_id                   NUMBER(15);

tmp_count       number;
tmp_ra_id_tab       PA_PLSQL_DATATYPES.IdTabTyp;    -- PA_PLSQL_DATATYPES.Char30TabTyp;
tmp_rlm_id_tab       PA_PLSQL_DATATYPES.IdTabTyp;
tmp_task_id_tab      PA_PLSQL_DATATYPES.IdTabTyp;

l_txn_res_asg_id_tab      PA_PLSQL_DATATYPES.IdTabTyp;
l_txn_plan_start_date_tab PA_PLSQL_DATATYPES.DateTabTyp;
l_txn_plan_end_date_tab   PA_PLSQL_DATATYPES.DateTabTyp;

l_txn_resource_asg_id_tab  PA_PLSQL_DATATYPES.IdTabTyp;

/* Variables for Manually Added Plan Lines logic */
l_etc_start_date               DATE;
l_spread_curve_id              pa_spread_curves_b.spread_curve_id%TYPE;
BEGIN
  X_MSG_COUNT := 0;
  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

  IF p_pa_debug_mode = 'Y' THEN
       pa_debug.set_curr_function( p_function     => 'UPDATE_RES_ASG'
                                  ,p_debug_mode   =>  p_pa_debug_mode);
  END IF;
  l_project_id := p_project_id;

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
    AND      NVL(T.TXN_TASK_ID,0)      > 0
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

    -- Bug 4159172: Moved manual lines logic from CREATE_RES_ASG to after
    -- txn_resource_assignments have been updated in tmp4 so that we can
    -- delete tmp4 records for manually added resources based on txn ra_ids
    -- instead of txn_task_id. Checking for txn_task_id is not sufficient
    -- (e.g. when Target is planned at a higher level than the source or when
    -- the structure is Partially Shared).

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
        END IF;
    END IF; -- end manual lines logic

    --Bug 6163120. Commented out the join on txn_budget_version_id
    --as its not populated in this table.
    SELECT  txn_resource_assignment_id,
            min(txn_planning_start_date),
            max(txn_planning_end_date)
    BULK    COLLECT
    INTO    l_txn_res_asg_id_tab,
            l_txn_plan_start_date_tab,
            l_txn_plan_end_date_tab
    FROM    PA_RES_LIST_MAP_TMP4
    --WHERE   txn_budget_version_id = p_budget_version_id
    GROUP BY txn_resource_assignment_id;

    FORALL j IN 1..l_txn_res_asg_id_tab.count
        UPDATE PA_RESOURCE_ASSIGNMENTS
        SET    PLANNING_START_DATE    = l_txn_plan_start_date_tab(j),
               PLANNING_END_DATE      = l_txn_plan_end_date_tab(j)
        WHERE  RESOURCE_ASSIGNMENT_ID = l_txn_res_asg_id_tab(j);

    -- Bug 4159172: Moved update of sp_fixed_date from CREATE_RES_ASG to here.

    SELECT  spread_curve_id
    INTO    l_spread_curve_id
    FROM    pa_spread_curves_b
    WHERE   spread_curve_code = 'FIXED_DATE';

    UPDATE   PA_RESOURCE_ASSIGNMENTS
    SET      SP_FIXED_DATE = PLANNING_START_DATE
    WHERE    SP_FIXED_DATE IS NULL
    AND      SPREAD_CURVE_ID = l_spread_curve_id
    AND      budget_version_id = p_budget_version_id
    AND EXISTS ( SELECT /*+ INDEX(tmp,PA_RES_LIST_MAP_TMP4_N2)*/ 1
                 FROM   pa_res_list_map_tmp4 tmp
                 WHERE  tmp.txn_resource_assignment_id = resource_assignment_id
                 AND    rownum = 1 );

    -- Bug 3973015: Added the NOT EXISTS condition to the WHERE clause
    -- to reflect new Retain Manually Added Lines logic. The transaction
    -- source code should only be set if it is NULL and there are no
    -- budget lines for the resource assignment id.
    -- Update 12/1/04: We have changed how the Retain Manually Added
    -- Lines logic is handled, so replaced previous update logic.

    --Bug 4198901 : Spread curve should be null when generate from source plan where actual exist
    -- added update for spread_curve_id /sp_fixed_date
    UPDATE PA_RESOURCE_ASSIGNMENTS
    SET    transaction_source_code = p_gen_src_code,
           sp_fixed_date = decode (p_gen_src_code, 'RESOURCE_SCHEDULE', NULL, sp_fixed_date),
           spread_curve_id = decode (p_gen_src_code, 'RESOURCE_SCHEDULE', NULL, spread_curve_id)
    WHERE  budget_version_id = p_budget_version_id
    AND EXISTS ( SELECT /*+ INDEX(tmp,PA_RES_LIST_MAP_TMP4_N2)*/ 1
                 FROM   pa_res_list_map_tmp4 tmp
                 WHERE  tmp.txn_resource_assignment_id = resource_assignment_id
                 AND    rownum = 1 );

  IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_Curr_Function;
  END IF;
  RETURN;

 EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      := SUBSTR(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_BUDGET_AMT_PUB'
              ,p_procedure_name => 'UPDATE_RES_ASG');
    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.Reset_Curr_Function;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END UPDATE_RES_ASG;

/*Procedure to delete the manually entered budget line records
    PX_RES_ASG_ID_TAB        ->this pl sql table will have res asg id
    for which the budget lines has to be deleted.
    PX_DELETED_RES_ASG_ID_TAB->this pl sql table will have res asg ids
    for which the budget_lines are deleted by this API.

    These two pl sql tables are used to make sure that
    we are not deleting budget lines records that was generated
    by the previous source in the same run.
*/
PROCEDURE DEL_MANUAL_BDGT_LINES
         ( P_PROJECT_ID               IN       PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID        IN       PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           PX_RES_ASG_ID_TAB          IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
           PX_DELETED_RES_ASG_ID_TAB  IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
           X_RETURN_STATUS            OUT   NOCOPY  VARCHAR2,
           X_MSG_COUNT                OUT   NOCOPY  NUMBER,
           X_MSG_DATA                 OUT   NOCOPY  VARCHAR2) IS
l_module_name         VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_BUDGET_AMT_PUB.DEL_MANUAL_BDGT_LINES';

 l_del_res_asg_id_tab  PA_PLSQL_DATATYPES.IdTabTyp;
 l_exist_flag          VARCHAR2(1) := 'N';
 l_count               NUMBER;

BEGIN

  X_MSG_COUNT := 0;
  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

  IF p_pa_debug_mode = 'Y' THEN
       pa_debug.set_curr_function( p_function     => 'DEL_MANUAL_BDGT_LINES'
                                  ,p_debug_mode   =>  p_pa_debug_mode);
  END IF;

  FOR i IN 1..PX_RES_ASG_ID_TAB.count LOOP
     l_del_res_asg_id_tab(i) := PX_RES_ASG_ID_TAB(i);
  END LOOP;

  IF PX_RES_ASG_ID_TAB.count > 0 THEN
    FOR i IN 1..PX_RES_ASG_ID_TAB.count LOOP
       l_exist_flag := 'N';
       FOR j IN  1..PX_DELETED_RES_ASG_ID_TAB.count LOOP
          IF  PX_RES_ASG_ID_TAB(i) = PX_DELETED_RES_ASG_ID_TAB(j) THEN
              l_exist_flag := 'Y';
              EXIT;
          END IF;
       END LOOP;

       IF  l_exist_flag = 'N' THEN
           l_del_res_asg_id_tab(l_del_res_asg_id_tab.count+1) := PX_RES_ASG_ID_TAB(i);
       END IF;
    END LOOP;
  END IF;

    -- Deleting the PL/SQL table
    PX_DELETED_RES_ASG_ID_TAB.delete;

    FOR k in 1..l_del_res_asg_id_tab.count LOOP
        PX_DELETED_RES_ASG_ID_TAB(k) := l_del_res_asg_id_tab(k);
    END LOOP;

    FORALL i in 1..PX_DELETED_RES_ASG_ID_TAB.count
      DELETE FROM PA_BUDGET_LINES
      WHERE  RESOURCE_ASSIGNMENT_ID = PX_DELETED_RES_ASG_ID_TAB(i);

      IF p_pa_debug_mode = 'Y' THEN
           pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Before calling
                                  pa_fp_rollup_pkg.rollup_budget_version',
                p_module_name => l_module_name,
                p_log_level   => 5);
      END IF;
      PA_FP_ROLLUP_PKG.ROLLUP_BUDGET_VERSION
          (p_budget_version_id          => P_BUDGET_VERSION_ID,
           p_entire_version             =>  'Y',
           X_RETURN_STATUS              => X_RETURN_STATUS,
           X_MSG_COUNT                  => X_MSG_COUNT,
           X_MSG_DATA                   => X_MSG_DATA);

              IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
              END IF;
      IF p_pa_debug_mode = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
                   (p_msg         => 'Status after calling
                              pa_fp_rollup_pkg.rollup_budget_version: '
                              ||x_return_status,
                    p_module_name => l_module_name,
                    p_log_level   => 5);
      END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_Curr_Function;
    END IF;

 EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      := SUBSTR(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_BUDGET_AMT_PUB'
              ,p_procedure_name => 'DEL_MANUAL_BDGT_LINES');

     IF P_PA_DEBUG_MODE = 'Y' THEN
         PA_DEBUG.Reset_Curr_Function;
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END DEL_MANUAL_BDGT_LINES;

PROCEDURE UPDATE_INIT_AMOUNTS
          (P_PROJECT_ID         IN            PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID  IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_RES_ASG_ID_TAB     IN            PA_PLSQL_DATATYPES.IdTabTyp,
           --this pl/sql table will have newly created res_asg_id from the source
           X_RETURN_STATUS      OUT   NOCOPY  VARCHAR2,
           X_MSG_COUNT          OUT   NOCOPY  NUMBER,
           X_MSG_DATA           OUT   NOCOPY  VARCHAR2) IS

l_module_name         VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_BUDGET_AMT_PUB.UPDATE_INIT_AMOUNTS';

BEGIN

  X_MSG_COUNT := 0;
  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

  IF p_pa_debug_mode = 'Y' THEN
       pa_debug.set_curr_function( p_function     => 'UPDATE_INIT_AMOUNTS'
                                  ,p_debug_mode   =>  p_pa_debug_mode);
  END IF;

  FORALL i IN 1..P_RES_ASG_ID_TAB.count
  UPDATE PA_BUDGET_LINES
  SET    INIT_QUANTITY                 = QUANTITY,
         INIT_QUANTITY_SOURCE          = QUANTITY_SOURCE,
         INIT_RAW_COST                 = RAW_COST,
         INIT_BURDENED_COST            = BURDENED_COST,
         INIT_REVENUE                  = REVENUE,
         INIT_RAW_COST_SOURCE          = RAW_COST_SOURCE,
         INIT_BURDENED_COST_SOURCE     = BURDENED_COST_SOURCE,
         INIT_REVENUE_SOURCE           = REVENUE_SOURCE,
         PROJECT_INIT_RAW_COST         = PROJECT_RAW_COST,
         PROJECT_INIT_BURDENED_COST    = PROJECT_BURDENED_COST,
         PROJECT_INIT_REVENUE          = PROJECT_REVENUE,
         TXN_INIT_RAW_COST             = TXN_RAW_COST,
         TXN_INIT_BURDENED_COST        = TXN_BURDENED_COST,
         TXN_INIT_REVENUE              = TXN_REVENUE
  WHERE  RESOURCE_ASSIGNMENT_ID        = P_RES_ASG_ID_TAB(i);

    IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_Curr_Function;
    END IF;

EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      := SUBSTR(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_BUDGET_AMT_PUB'
              ,p_procedure_name => 'UPDATE_INIT_AMOUNTS');

     IF P_PA_DEBUG_MODE = 'Y' THEN
         PA_DEBUG.Reset_Curr_Function;
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END UPDATE_INIT_AMOUNTS;

/* Procedure to update the latest amount
   generation date in the budget versions table*/
PROCEDURE UPDATE_BV_FOR_GEN_DATE
          (P_PROJECT_ID         IN    PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID  IN    PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_ETC_START_DATE     IN    PA_BUDGET_VERSIONS.ETC_START_DATE%TYPE,
           X_RETURN_STATUS      OUT   NOCOPY  VARCHAR2,
           X_MSG_COUNT          OUT   NOCOPY  NUMBER,
           X_MSG_DATA           OUT   NOCOPY  VARCHAR2) IS

l_module_name         VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_BUDGET_AMT_PUB.UPDATE_BV_FOR_GEN_DATE';

l_last_updated_by           NUMBER := FND_GLOBAL.user_id;
l_last_update_login         NUMBER := FND_GLOBAL.login_id;
l_sysdate                   DATE   := SYSDATE;

BEGIN

   X_MSG_COUNT := 0;
   X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

  IF p_pa_debug_mode = 'Y' THEN
       pa_debug.set_curr_function( p_function     => 'UPDATE_BV_FOR_GEN_DATE'
                                  ,p_debug_mode   =>  p_pa_debug_mode);
  END IF;

   UPDATE PA_BUDGET_VERSIONS
   SET    LAST_AMT_GEN_DATE         = l_sysdate,
          LAST_UPDATE_DATE          = l_sysdate,
          LAST_UPDATED_BY           = l_last_updated_by,
          CREATION_DATE             = l_sysdate,
          CREATED_BY                = l_last_updated_by,
          LAST_UPDATE_LOGIN         = l_last_update_login,
          record_version_number     = nvl(record_version_number,0)+1,
          ETC_START_DATE            = p_etc_start_date
   WHERE  BUDGET_VERSION_ID         = P_BUDGET_VERSION_ID;

    IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_Curr_Function;
    END IF;

 EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      := SUBSTR(SQLERRM,1,240);
     rollback;
     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_BUDGET_AMT_PUB'
              ,p_procedure_name => 'UPDATE_BV_FOR_GEN_DATE');

     IF P_PA_DEBUG_MODE = 'Y' THEN
         PA_DEBUG.Reset_Curr_Function;
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END UPDATE_BV_FOR_GEN_DATE;

PROCEDURE GET_GENERATED_RES_ASG
           (P_PROJECT_ID          IN      PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID    IN      PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           PX_GEN_RES_ASG_ID_TAB  IN OUT  NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
           P_CHK_DUPLICATE_FLAG   IN      VARCHAR2,
           X_RETURN_STATUS        OUT   NOCOPY  VARCHAR2,
           X_MSG_COUNT            OUT   NOCOPY  NUMBER,
           X_MSG_DATA             OUT   NOCOPY  VARCHAR2) IS
l_module_name         VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_BUDGET_AMT_PUB.GET_GENERATED_RES_ASG';

l_gen_res_asg_id_tab     PA_PLSQL_DATATYPES.IdTabTyp;
l_cmt_res_id_tab         PA_PLSQL_DATATYPES.IdTabTyp;
l_exist_flag             VARCHAR2(1);

BEGIN
     X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
     X_MSG_COUNT := 0;

     IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function     => 'GET_GENERATED_RES_ASG'
                                   ,p_debug_mode   =>  p_pa_debug_mode);
     END IF;

    /* For first time call PA_GEN_RES_ASG_ID_TAB will
       be empty so it is bulk collected from tmp4 table*/
    IF P_CHK_DUPLICATE_FLAG = 'N' THEN
         SELECT  DISTINCT TXN_RESOURCE_ASSIGNMENT_ID
         BULK    COLLECT
         INTO    PX_GEN_RES_ASG_ID_TAB
         FROM    PA_RES_LIST_MAP_TMP4;
    END IF;

   /*Code checking for duplicate res_asg_id */
   FOR i IN 1..PX_GEN_RES_ASG_ID_TAB.count LOOP
       l_gen_res_asg_id_tab(i) := PX_GEN_RES_ASG_ID_TAB(i);
   END LOOP;

   SELECT  DISTINCT TXN_RESOURCE_ASSIGNMENT_ID
   BULK    COLLECT
   INTO    l_cmt_res_id_tab
   FROM    PA_RES_LIST_MAP_TMP4;

   IF l_cmt_res_id_tab.count > 0 THEN
      FOR k IN 1..l_cmt_res_id_tab.count LOOP
          l_exist_flag := 'N';
          FOR kk IN 1..l_gen_res_asg_id_tab.count LOOP
              IF l_gen_res_asg_id_tab(kk) = l_cmt_res_id_tab(k) THEN
                 l_exist_flag := 'Y';
                 EXIT;
              END IF;
          END LOOP;
          IF l_exist_flag = 'N' THEN
             PX_GEN_RES_ASG_ID_TAB(PX_GEN_RES_ASG_ID_TAB.count+1) :=  l_cmt_res_id_tab(k);
          END IF;
       END LOOP;
   END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_Curr_Function;
    END IF;

 EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      := SUBSTR(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_BUDGET_AMT_PUB'
              ,p_procedure_name => 'GET_GENERATED_RES_ASG');

     IF P_PA_DEBUG_MODE = 'Y' THEN
         PA_DEBUG.Reset_Curr_Function;
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END GET_GENERATED_RES_ASG;


/******************************************************************************
This api is called in calculate flow to add the currencies in budget lines
table for a budget version as txn currencies in pa_fp_txn_currencies table

AUG 10 2004  Raja       Bug 3815266
                        Re-written the entire code to take care of both finplan
                        and workplan contexts. Previously refresh_wp_settings
                        was being called for workplan context. This has been
                        removed and re-structured the code such that there is
                        no code duplication
OCT 10 2004 Raja        Bug 3919127
                        In copy projet flow first published version is being
                        created and later its copy as working version. Add the
                        missing currencies to all the workplan versions
******************************************************************************/
PROCEDURE INSERT_TXN_CURRENCY
          (P_PROJECT_ID          IN    PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID   IN    PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC         IN    PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           X_RETURN_STATUS       OUT   NOCOPY   VARCHAR2,
           X_MSG_COUNT           OUT   NOCOPY   NUMBER,
           X_MSG_DATA            OUT   NOCOPY   VARCHAR2) IS
l_module_name         VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_BUDGET_AMT_PUB.INSERT_TXN_CURRENCY';

l_txn_curr_code_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
l_budget_version_id_tbl     PA_PLSQL_DATATYPES.NumTabTyp;
l_proj_fp_options_id_tbl    PA_PLSQL_DATATYPES.NumTabTyp;

l_fp_cols_rec               PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
l_pc                        pa_budget_lines.txn_currency_code%type;
l_pfc                       pa_budget_lines.txn_currency_code%type;

l_last_updated_by           NUMBER := FND_GLOBAL.user_id;
l_last_update_login         NUMBER := FND_GLOBAL.login_id;
l_sysdate                   DATE   := SYSDATE;

l_wp_version_flag           pa_budget_versions.wp_version_flag%type;

BEGIN
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT := 0;

    IF p_pa_debug_mode = 'Y' THEN
       pa_debug.set_curr_function( p_function     => 'INSERT_TXN_CURRENCY'
                                  ,p_debug_mode   =>  p_pa_debug_mode);
    END IF;

    l_fp_cols_rec := P_FP_COLS_REC;

    /* get the plan version dtls if
      the record does have the version dtls */
     IF (   l_fp_cols_rec.x_proj_fp_options_id is null
             OR l_fp_cols_rec.x_fin_plan_type_id is null
             OR p_project_id is null) THEN

        IF p_pa_debug_mode = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
                  (p_msg         => 'Before calling
                              pa_fp_gen_amount_utils.get_plan_version_dtls',
                   p_module_name => l_module_name,
                   p_log_level   => 5);
        END IF;

        PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
            (P_PROJECT_ID          => P_PROJECT_ID,
             P_BUDGET_VERSION_ID   => P_BUDGET_VERSION_ID,
             X_FP_COLS_REC         => l_fp_cols_rec,
             X_RETURN_STATUS       => X_RETURN_STATUS,
             X_MSG_COUNT           => X_MSG_COUNT,
             X_MSG_DATA            => X_MSG_DATA);

        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
        IF p_pa_debug_mode = 'Y' THEN
              pa_fp_gen_amount_utils.fp_debug
                  (p_msg         => 'Status after calling
                          pa_fp_gen_amount_utils.get_plan_version_dtls: '
                          ||x_return_status,
                   p_module_name => l_module_name,
                   p_log_level   => 5);
        END IF;
     END IF;

     l_pc  := l_FP_COLS_REC.X_PROJECT_CURRENCY_CODE;
     l_pfc := l_FP_COLS_REC.X_PROJFUNC_CURRENCY_CODE;

     /*  If the version is a workplan version, then the missing
         currencies should first be added to the workplan plan
         type and then all the working workplan versions*/

     SELECT nvl(wp_version_flag,'N')
     INTO   l_wp_version_flag
     FROM   pa_budget_versions
     WHERE  budget_version_id = p_budget_version_id;

     IF l_wp_version_flag = 'N' THEN

         -- if the version is finplan version its sufficient to add the
         -- currencies for this version alone
         l_proj_fp_options_id_tbl(1) := l_fp_cols_rec.X_PROJ_FP_OPTIONS_ID;
         l_budget_version_id_tbl(1)  := P_BUDGET_VERSION_ID;
     ELSE
         -- New Currencies should be added to both workplan plan type and
         -- all the working workplan versions

         -- fetch all the working workplan versions
         -- bug 3919127 do not restrict workplan versions based on the
         -- structure version status
         SELECT bv.budget_version_id
                ,pfo.proj_fp_options_id
         BULK COLLECT INTO
                l_budget_version_id_tbl,
                l_proj_fp_options_id_tbl
         FROM   pa_budget_versions bv,
                --bug 3919127 pa_proj_elem_ver_structure ver,
                pa_proj_fp_options pfo
         WHERE bv.project_id = p_project_id
           AND bv.wp_version_flag = 'Y'
/* bug 3919127
           AND bv.project_id = ver.project_id
           AND bv.project_structure_version_id = ver.element_version_id
           AND (PA_WORKPLAN_ATTR_UTILS.Check_Wp_Versioning_Enabled(p_project_id) = 'N' OR
                  ver.status_code IN('STRUCTURE_WORKING'))
*/
           AND pfo.project_id = p_project_id
           AND pfo.fin_plan_version_id = bv.budget_version_id;

         -- Add plan type record to the plsql tables
         SELECT proj_fp_options_id,
                null
         INTO   l_proj_fp_options_id_tbl(nvl(l_proj_fp_options_id_tbl.count,0) + 1),
                l_budget_version_id_tbl(nvl(l_proj_fp_options_id_tbl.count,0) + 1)
         FROM   pa_proj_fp_options
         WHERE  project_id = p_project_id AND
                fin_plan_type_id = l_fp_cols_rec.X_FIN_PLAN_TYPE_ID AND
                fin_plan_option_level_code = 'PLAN_TYPE';
     END IF;

     -- For each of the fp option in the pl sql tables enter all the missing currencies

     -- Add the currency for each of the workplan versions
     FOR i IN l_proj_fp_options_id_tbl.first .. l_proj_fp_options_id_tbl.last
     LOOP

         l_txn_curr_code_tab.DELETE; -- this is really not necessary but kept here for clarity

         -- Bulk collect all the txn currencies that should be added
         SELECT DISTINCT BL.TXN_CURRENCY_CODE
         BULK   COLLECT
         INTO   l_txn_curr_code_tab
         FROM   PA_BUDGET_LINES BL
         WHERE  BL.BUDGET_VERSION_ID = P_BUDGET_VERSION_ID
         AND     NOT EXISTS
                (SELECT   1
                 FROM     PA_FP_TXN_CURRENCIES TC
                 WHERE TC.proj_fp_options_id = l_proj_fp_options_id_tbl(i) AND
                       TC.txn_currency_code = BL.txn_currency_code);

         FORALL j IN 1..l_txn_curr_code_tab.count
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
                      l_proj_fp_options_id_tbl(i),
                      l_fp_cols_rec.X_PROJECT_ID,
                      l_fp_cols_rec.X_FIN_PLAN_TYPE_ID,
                      l_budget_version_id_tbl(i),
                      l_txn_curr_code_tab(j),
                      'N',
                      'N',
                      'N',
                      Decode(l_txn_curr_code_tab(j),l_pc,'Y','N'),
                      Decode(l_txn_curr_code_tab(j),l_pfc,'Y','N'),
                      l_sysdate,
                      l_last_updated_by,
                      l_last_update_login,
                      l_last_updated_by,
                      l_sysdate );

     END LOOP; -- FOR j IN l_proj_fp_options_id_tbl.first .. l_proj_fp_options_id_tbl.last

    IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_Curr_Function;
    END IF;

 EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      := SUBSTR(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_BUDGET_AMT_PUB'
              ,p_procedure_name => 'INSERT_TXN_CURRENCY');

     IF P_PA_DEBUG_MODE = 'Y' THEN
         PA_DEBUG.Reset_Curr_Function;
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END INSERT_TXN_CURRENCY;

PROCEDURE RESET_COST_AMOUNTS
          (P_BUDGET_VERSION_ID  IN    PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           X_RETURN_STATUS      OUT   NOCOPY  VARCHAR2,
           X_MSG_COUNT          OUT   NOCOPY  NUMBER,
           X_MSG_DATA           OUT   NOCOPY  VARCHAR2) IS
l_module_name         VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_BUDGET_AMT_PUB.RESET_COST_AMOUNTS';
BEGIN

     X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
     X_MSG_COUNT := 0;

     IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function     => 'RESET_COST_AMOUNTS'
                                   ,p_debug_mode   =>  p_pa_debug_mode);
     END IF;

    UPDATE  PA_BUDGET_LINES
    SET     RAW_COST                    = null,
            BURDENED_COST               = null,
            PROJECT_RAW_COST            = null,
            PROJECT_BURDENED_COST       = null,
            TXN_RAW_COST                = null,
            TXN_BURDENED_COST           = null,
            PROJFUNC_COST_RATE_TYPE     = null,
            PROJFUNC_COST_EXCHANGE_RATE = null,
            PROJFUNC_COST_RATE_DATE_TYPE= null,
            PROJFUNC_COST_RATE_DATE     = null,
            PROJECT_COST_RATE_TYPE      = null,
            PROJECT_COST_EXCHANGE_RATE  = null,
            PROJECT_COST_RATE_DATE_TYPE = null,
            PROJECT_COST_RATE_DATE      = null
    WHERE   BUDGET_VERSION_ID     = P_BUDGET_VERSION_ID;

    IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_Curr_Function;
    END IF;

 EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      := SUBSTR(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_BUDGET_AMT_PUB'
              ,p_procedure_name => 'RESET_COST_AMOUNTS');

     IF P_PA_DEBUG_MODE = 'Y' THEN
         PA_DEBUG.Reset_Curr_Function;
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END RESET_COST_AMOUNTS;

PROCEDURE GEN_REV_BDGT_AMT_RES_SCH_WRP
    (P_PROJECT_ID                    IN            pa_projects_all.PROJECT_ID%TYPE,
    P_BUDGET_VERSION_ID          IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
    P_FP_COLS_REC                    IN            PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
    P_PLAN_CLASS_CODE                IN            PA_FIN_PLAN_TYPES_B.PLAN_CLASS_CODE%TYPE,
    P_GEN_SRC_CODE                   IN            PA_PROJ_FP_OPTIONS.GEN_ALL_SRC_CODE%TYPE,
    P_COST_PLAN_TYPE_ID              IN            PA_PROJ_FP_OPTIONS.GEN_SRC_COST_PLAN_TYPE_ID%TYPE,
    P_COST_VERSION_ID                IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
    P_RETAIN_MANUAL_FLAG             IN            PA_PROJ_FP_OPTIONS.GEN_COST_RET_MANUAL_LINE_FLAG%TYPE,
    P_CALLED_MODE                    IN            VARCHAR2,
    P_INC_CHG_DOC_FLAG               IN            PA_PROJ_FP_OPTIONS.GEN_COST_INCL_CHANGE_DOC_FLAG%TYPE,
    P_INC_BILL_EVENT_FLAG            IN            PA_PROJ_FP_OPTIONS.GEN_REV_INCL_BILL_EVENT_FLAG%TYPE,
    P_INC_OPEN_COMMIT_FLAG           IN            PA_PROJ_FP_OPTIONS.GEN_COST_INCL_OPEN_COMM_FLAG%TYPE,
    P_ACTUALS_THRU_DATE              IN            PA_PERIODS_ALL.END_DATE%TYPE,
    P_CI_ID_TAB                      IN            PA_PLSQL_DATATYPES.IdTabTyp,
    PX_GEN_RES_ASG_ID_TAB            IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
    PX_DELETED_RES_ASG_ID_TAB        IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
    P_COMMIT_FLAG                    IN            VARCHAR2,
    P_INIT_MSG_FLAG                  IN            VARCHAR2,
    X_RETURN_STATUS                  OUT  NOCOPY   VARCHAR2,
    X_MSG_COUNT                      OUT  NOCOPY   NUMBER,
    X_MSG_DATA                       OUT  NOCOPY   VARCHAR2) IS

 l_module_name         VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_BUDGET_AMT_PUB.GEN_REV_BDGT_AMT_RES_SCH_WRP';

 /*local variable for calling get planning rates*/
 l_res_asg_id_tab           SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_ra_quantity_tab          SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_task_id_tab              PA_PLSQL_DATATYPES.IdTabTyp;
 l_res_list_member_id_tab       PA_PLSQL_DATATYPES.IdTabTyp;
 l_txn_currency_code_tab        SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
 l_ra_start_date_tab            PA_PLSQL_DATATYPES.DateTabTyp;
 l_uom_tab              pa_plsql_datatypes.Char30TabTyp;
 l_rate_based_flag_tab          pa_plsql_datatypes.Char30TabTyp;
 l_resource_class_code_tab      pa_plsql_datatypes.Char30TabTyp;
 l_organization_id_tab          pa_plsql_datatypes.Char30TabTyp;
 l_job_id_tab               PA_PLSQL_DATATYPES.IdTabTyp;
 l_person_id_tab            PA_PLSQL_DATATYPES.IdTabTyp;
 l_expenditure_type_tab         pa_plsql_datatypes.Char30TabTyp;
 l_non_labor_resource_tab       pa_plsql_datatypes.Char30TabTyp;
 l_bom_resource_id_tab          PA_PLSQL_DATATYPES.IdTabTyp;
 l_inventory_item_id_tab        PA_PLSQL_DATATYPES.IdTabTyp;
 l_item_category_id_tab         PA_PLSQL_DATATYPES.IdTabTyp;
 l_mfc_cost_type_id_tab         PA_PLSQL_DATATYPES.IdTabTyp;
 l_rate_incur_by_organz_id_tab      PA_PLSQL_DATATYPES.IdTabTyp;
 l_rate_ovrd_to_organz_id_tab       PA_PLSQL_DATATYPES.IdTabTyp;
 l_rate_expenditure_org_id_tab      PA_PLSQL_DATATYPES.IdTabTyp;
 l_rate_expenditure_type_tab        pa_plsql_datatypes.Char30TabTyp;
 l_rate_organization_id_tab     PA_PLSQL_DATATYPES.IdTabTyp;
 l_project_assignment_id_tab        PA_PLSQL_DATATYPES.IdTabTyp;

 l_assign_precedes_task_tab     pa_plsql_datatypes.Char30TabTyp;
 l_bill_job_group_id_tab        PA_PLSQL_DATATYPES.IdTabTyp;
 l_carry_out_organiz_id_tab     PA_PLSQL_DATATYPES.IdTabTyp;
 l_multi_currency_bill_flag_tab     pa_plsql_datatypes.Char30TabTyp;
 l_org_id_tab               PA_PLSQL_DATATYPES.IdTabTyp;
 l_non_lab_bill_rate_org_id_tab     PA_PLSQL_DATATYPES.IdTabTyp;
 l_non_lab_sch_discount_tab     PA_PLSQL_DATATYPES.NumTabTyp;
 l_non_lab_sch_fixed_date_tab       PA_PLSQL_DATATYPES.DateTabTyp;
 l_project_type_tab         pa_plsql_datatypes.Char30TabTyp;
 l_lab_bill_rate_org_id_tab     PA_PLSQL_DATATYPES.IdTabTyp;

 l_lab_sch_FIXED_DATE_tab       PA_PLSQL_DATATYPES.DateTabTyp;
 l_top_task_id_tab          PA_PLSQL_DATATYPES.IdTabTyp;
 l_scheduled_start_date_tab     PA_PLSQL_DATATYPES.DateTabTyp;
 l_labor_scheduled_discount_tab     PA_PLSQL_DATATYPES.NumTabTyp;
 l_labor_sch_type_tab           pa_plsql_datatypes.Char30TabTyp;
 l_non_labor_sch_type_tab       pa_plsql_datatypes.Char30TabTyp;

 l_rev_res_class_rt_sch_id_tab      PA_PLSQL_DATATYPES.IdTabTyp;
 l_cost_res_class_rt_sch_id_tab     PA_PLSQL_DATATYPES.IdTabTyp;

 l_res_format_id_tab            PA_PLSQL_DATATYPES.IdTabTyp;

 l_bill_rate                number;
 l_cost_rate                number;
 l_burden_cost_rate         number;
 l_burden_multiplier            number;
 l_raw_cost             number;
 l_burden_cost              number;
 l_raw_revenue              number;
 l_bill_markup_percentage       number;
 l_cost_txn_curr_code           varchar2(30);
 l_rev_txn_curr_code            varchar2(30);
 l_raw_cost_rejection_code      varchar2(30);
 l_burden_cost_rejection_code       varchar2(30);
 l_revenue_rejection_code       varchar2(30);
 l_cost_ind_compiled_set_id     number;

  /*Local PL/SQL table used for calling Calculate API*/
 l_calling_module                  VARCHAR2(30) := 'BUDGET_GENERATION';
 l_refresh_rates_flag              VARCHAR2(1) := 'Y';
 l_refresh_conv_rates_flag         VARCHAR2(1) := 'N';
 l_spread_required_flag            VARCHAR2(1) := 'N';
 l_conv_rates_required_flag        VARCHAR2(1) := 'N';
 l_rollup_required_flag            VARCHAR2(1) := 'N';
 l_mass_adjust_flag                VARCHAR2(1) := 'N';
 l_quantity_adj_pct                NUMBER   := NULL;
 l_cost_rate_adj_pct               NUMBER   := NULL;
 l_burdened_rate_adj_pct           NUMBER   := NULL;
 l_bill_rate_adj_pct               NUMBER   := NULL;
 l_source_context                  pa_fp_res_assignments_tmp.source_context%TYPE := 'RESOURCE_ASSIGNMENT';

 l_delete_budget_lines_tab         SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
 l_spread_amts_flag_tab            SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
 l_txn_currency_override_tab       SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
 l_addl_qty_tab                    SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_total_raw_cost_tab              SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_addl_raw_cost_tab               SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_total_burdened_cost_tab         SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_addl_burdened_cost_tab          SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_total_revenue_tab               SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_addl_revenue_tab                SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_raw_cost_rate_tab               SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_rw_cost_rate_override_tab       SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_b_cost_rate_tab                 SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_b_cost_rate_override_tab        SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_bill_rate_tab                   SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_bill_rate_override_tab          SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_line_start_date_tab             SYSTEM.pa_date_tbl_type:=SYSTEM.pa_date_tbl_type();
 l_line_end_date_tab               SYSTEM.pa_date_tbl_type:=SYSTEM.pa_date_tbl_type();
/*end variable for calculate*/

 l_msg_count                       NUMBER;
 l_msg_data                        VARCHAR2(2000);
 l_data                            VARCHAR2(2000);
 l_msg_index_out                   NUMBER:=0;
BEGIN
    IF p_init_msg_flag = 'Y' THEN
        FND_MSG_PUB.initialize;
    END IF;
    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
        PA_DEBUG.init_err_stack('PA_FP_GEN_BUDGET_AMT_PUB.GEN_REV_BDGT_AMT_RES_SCH_WRP');
    ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
        pa_debug.set_curr_function( p_function     => 'GEN_REV_BDGT_AMT_RES_SCH_WRP',
                                     p_debug_mode   =>  p_pa_debug_mode);
    END IF;


    IF p_pa_debug_mode = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Before calling
                pa_fp_gen_budget_amt_pub.generate_budget_amt_res_sch',
                p_module_name => l_module_name,
                p_log_level   => 5);
    END IF;
    PA_FP_GEN_BUDGET_AMT_PUB.GENERATE_BUDGET_AMT_RES_SCH
        (P_PROJECT_ID              => P_PROJECT_ID,
        P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
        P_FP_COLS_REC              => P_FP_COLS_REC,
        P_PLAN_CLASS_CODE          => P_PLAN_CLASS_CODE,
        P_GEN_SRC_CODE             => P_GEN_SRC_CODE,
        P_COST_PLAN_TYPE_ID        => P_COST_PLAN_TYPE_ID,
    P_COST_VERSION_ID          => P_COST_VERSION_ID,
    P_RETAIN_MANUAL_FLAG       => P_RETAIN_MANUAL_FLAG,
    P_CALLED_MODE          => P_CALLED_MODE,
    P_INC_CHG_DOC_FLAG         => P_INC_CHG_DOC_FLAG,
    P_INC_BILL_EVENT_FLAG      => P_INC_BILL_EVENT_FLAG,
        P_INC_OPEN_COMMIT_FLAG     => P_INC_OPEN_COMMIT_FLAG,
        P_ACTUALS_THRU_DATE    => P_ACTUALS_THRU_DATE,
        P_CI_ID_TAB                => P_CI_ID_TAB,
        PX_GEN_RES_ASG_ID_TAB      => PX_GEN_RES_ASG_ID_TAB,
        PX_DELETED_RES_ASG_ID_TAB  => PX_DELETED_RES_ASG_ID_TAB,
        P_COMMIT_FLAG              => P_COMMIT_FLAG,
        P_INIT_MSG_FLAG            => P_INIT_MSG_FLAG,
        X_RETURN_STATUS            => X_RETURN_STATUS,
        X_MSG_COUNT                => X_MSG_COUNT,
        X_MSG_DATA                 => X_MSG_DATA);
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;
    IF p_pa_debug_mode = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Status after calling
             pa_fp_gen_budget_amt_pub.generate_budget_amt_res_sch: '
                              ||x_return_status,
             p_module_name => l_module_name,
             p_log_level   => 5);
    END IF;

    SELECT /*+ INDEX(tmp,PA_FP_CALC_AMT_TMP2_N2)*/
    tmp.RESOURCE_ASSIGNMENT_ID,
        tmp.total_plan_quantity,
    ra.task_id,
    ra.resource_list_member_id,
    P_FP_COLS_REC.x_project_currency_code,
    ra.planning_start_date,
    ra.unit_of_measure,
    ra.rate_based_flag,
    ra.resource_class_code,
        ra.organization_id,
        ra.job_id,
        ra.person_id,
        ra.expenditure_type,
        ra.non_labor_resource,
        ra.bom_resource_id,
        ra.inventory_item_id,
        ra.item_category_id,
        ra.mfc_cost_type_id,
        ra.organization_id,
        null,
        ra.rate_expenditure_org_id,
        ra.rate_expenditure_type,
        ra.organization_id,
    ra.project_assignment_id,

        proj.assign_precedes_task,
        proj.bill_job_group_id,
        proj.carrying_out_organization_id,
        proj.multi_currency_billing_flag,
        proj.org_id,
        proj.non_labor_bill_rate_org_id,
        proj.non_labor_schedule_discount,
        proj.non_labor_schedule_fixed_date,
        proj.project_type,
        proj.labor_bill_rate_org_id,

        t.LABOR_SCHEDULE_FIXED_DATE,
        t.top_task_id,
    t.scheduled_start_date,
    t.labor_schedule_discount,
    t.labor_sch_type,
    t.non_labor_sch_type,

    decode(fp.use_planning_rates_flag,'N',fp.res_class_bill_rate_sch_id,
               fp.rev_res_class_rate_sch_id),
        decode(fp.use_planning_rates_flag,'N',fp.res_class_raw_cost_sch_id,
               NULL),

    res_format_id
    BULK COLLECT INTO
    l_res_asg_id_tab,
    l_ra_quantity_tab,
    l_task_id_tab,
    l_res_list_member_id_tab,
    l_txn_currency_code_tab,
    l_ra_start_date_tab,
    l_uom_tab,
    l_rate_based_flag_tab,
    l_resource_class_code_tab,
        l_organization_id_tab,
        l_job_id_tab,
        l_person_id_tab,
        l_expenditure_type_tab,
        l_non_labor_resource_tab,
        l_bom_resource_id_tab,
        l_inventory_item_id_tab,
        l_item_category_id_tab,
        l_mfc_cost_type_id_tab,
        l_rate_incur_by_organz_id_tab,
        l_rate_ovrd_to_organz_id_tab,
        l_rate_expenditure_org_id_tab,
        l_rate_expenditure_type_tab,
        l_rate_organization_id_tab,
    l_project_assignment_id_tab,

    l_assign_precedes_task_tab,
    l_bill_job_group_id_tab,
        l_carry_out_organiz_id_tab,
        l_multi_currency_bill_flag_tab,
        l_org_id_tab,
        l_non_lab_bill_rate_org_id_tab,
        l_non_lab_sch_discount_tab,
        l_non_lab_sch_fixed_date_tab,
        l_project_type_tab,

        l_lab_bill_rate_org_id_tab,
        l_lab_sch_FIXED_DATE_tab,
        l_top_task_id_tab,
    l_scheduled_start_date_tab,
    l_labor_scheduled_discount_tab,
    l_labor_sch_type_tab,
    l_non_labor_sch_type_tab,

    l_rev_res_class_rt_sch_id_tab,
        l_cost_res_class_rt_sch_id_tab,

    l_res_format_id_tab
    FROM pa_fp_calc_amt_tmp2 tmp, pa_resource_assignments ra,
     pa_projects_all proj, pa_tasks t,
         pa_proj_fp_options fp,
     pa_resource_list_members rlm
    WHERE tmp.resource_assignment_id = ra.resource_assignment_id
      AND ra.project_id = proj.project_id
      AND ra.task_id = t.task_id(+)
          AND fp.fin_plan_version_id = ra.budget_version_id
      AND ra.resource_list_member_id = rlm.resource_list_member_id;

    FOR i IN 1..l_res_asg_id_tab.count LOOP
        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Before calling pa_plan_revenue.Get_planning_Rates',
                 p_module_name => l_module_name,
                 p_log_level   => 5);
    END IF;
        PA_PLAN_REVENUE.GET_PLANNING_RATES(
        p_project_id                 => p_project_id,
            p_task_id                    => l_task_id_tab(i),
            p_top_task_id                => l_top_task_id_tab(i),
            p_person_id                  => l_person_id_tab(i),
            p_job_id                     => l_job_id_tab(i),
            p_bill_job_grp_id            => l_bill_job_group_id_tab(i),
            p_resource_class             => l_resource_class_code_tab(i),
            p_planning_resource_format   => l_res_format_id_tab(i),
            p_use_planning_rates_flag    => 'N',
            p_rate_based_flag            => l_rate_based_flag_tab(i),
            p_uom                        => l_uom_tab(i),
            p_system_linkage             => NULL,
            p_project_organz_id          => l_carry_out_organiz_id_tab(i),
            p_rev_res_class_rate_sch_id  => l_rev_res_class_rt_sch_id_tab(i),
            p_cost_res_class_rate_sch_id => l_cost_res_class_rt_sch_id_tab(i),
            p_calculate_mode             => 'REVENUE',
            p_mcb_flag                   => l_multi_currency_bill_flag_tab(i),
            p_quantity                   => l_ra_quantity_tab(i),
            p_item_date                  => l_ra_start_date_tab(i),
            p_cost_sch_type              => 'COST',
            p_labor_sch_type             => l_labor_sch_type_tab(i),
            p_non_labor_sch_type         => l_non_labor_sch_type_tab(i),
            --p_labor_schdl_discnt         => NULL,
            p_labor_bill_rate_org_id     => l_lab_bill_rate_org_id_tab(i),
            --p_labor_std_bill_rate_schdl  => NULL,
            p_labor_schdl_fixed_date     => l_LAb_SCH_FIXED_DATE_tab(i),
            p_assignment_id              => l_project_assignment_id_tab(i),
            p_project_org_id             => l_org_id_tab(i),
            p_project_type               => l_project_type_tab(i),
            p_expenditure_type           => nvl(l_expenditure_type_tab(i),l_rate_expenditure_type_tab(i)),
            p_non_labor_resource         => l_non_labor_resource_tab(i),
            p_incurred_by_organz_id      => nvl(l_rate_incur_by_organz_id_tab(i),l_organization_id_tab(i)),
            p_override_to_organz_id      => l_rate_ovrd_to_organz_id_tab(i),
            p_expenditure_org_id         => nvl(l_rate_expenditure_org_id_tab(i),l_org_id_tab(i)),
            p_assignment_precedes_task   => l_assign_precedes_task_tab(i),
            p_planning_transaction_id    => l_res_asg_id_tab(i),
            --,p_task_bill_rate_org_id      => l_task_bill_rate_org_id,
            p_project_bill_rate_org_id   => l_non_lab_bill_rate_org_id_tab(i),
            p_nlr_organization_id        => nvl(l_organization_id_tab(i),l_carry_out_organiz_id_tab(i)),
            p_project_sch_date           => l_non_lab_sch_fixed_date_tab(i),
            p_task_sch_date              => l_scheduled_start_date_tab(i),
            p_project_sch_discount       => l_non_lab_sch_discount_tab(i),
            p_task_sch_discount          => l_labor_scheduled_discount_tab(i),
            p_inventory_item_id          => l_inventory_item_id_tab(i),
            p_BOM_resource_Id            => l_bom_resource_id_tab(i),
            p_mfc_cost_type_id           => l_mfc_cost_type_id_tab(i),
            p_item_category_id           => l_item_category_id_tab(i),
            --,p_mfc_cost_source            => l_mfc_cost_source,
            --,p_cost_override_rate         => l_rw_cost_rate_override,
            --,p_revenue_override_rate      => l_bill_rate_override,
            --,p_override_burden_cost_rate  => l_burden_cost_rate_override,
            --,p_override_currency_code     => l_txn_currency_code_override,
            p_txn_currency_code          => l_txn_currency_code_tab(i),
            p_raw_cost                   => NULL,
            p_burden_cost                => NULL,
            p_raw_revenue                => NULL,
            x_bill_rate                  => l_bill_rate,
            x_cost_rate                  => l_cost_rate,
            x_burden_cost_rate           => l_burden_cost_rate,
            x_burden_multiplier          => l_burden_multiplier,
            x_raw_cost                   => l_raw_cost,
            x_burden_cost                => l_burden_cost,
            x_raw_revenue                => l_raw_revenue,
            x_bill_markup_percentage     => l_bill_markup_percentage,
            x_cost_txn_curr_code         => l_cost_txn_curr_code,
            x_rev_txn_curr_code          => l_rev_txn_curr_code,
            x_raw_cost_rejection_code    => l_raw_cost_rejection_code,
            x_burden_cost_rejection_code => l_burden_cost_rejection_code,
            x_revenue_rejection_code     => l_revenue_rejection_code,
            x_cost_ind_compiled_set_id   => l_cost_ind_compiled_set_id,
            x_return_status              => x_return_status,
            x_msg_data                   => x_msg_data,
            x_msg_count                  => x_msg_count);
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                 (p_msg         => 'Status after calling pa_plan_revenue.Get_planning_Rates'
                                   ||x_return_status,
                  p_module_name => l_module_name,
                  p_log_level   => 5);
        END IF;

        l_total_revenue_tab.extend;
    l_total_revenue_tab(i) := l_burden_cost;

    END LOOP;

    FOR i IN 1..l_res_asg_id_tab.count LOOP
    l_delete_budget_lines_tab.extend;
        l_spread_amts_flag_tab.extend;
        --l_txn_currency_code_tab.extend;
        l_txn_currency_override_tab.extend;
        --l_total_qty_tab.extend;
        l_addl_qty_tab.extend;
        l_total_raw_cost_tab.extend;
        l_addl_raw_cost_tab.extend;
        l_total_burdened_cost_tab.extend;
        l_addl_burdened_cost_tab.extend;
        l_addl_revenue_tab.extend;
        l_raw_cost_rate_tab.extend;
        l_rw_cost_rate_override_tab.extend;
        l_b_cost_rate_tab.extend;
        l_b_cost_rate_override_tab.extend;
        l_bill_rate_tab.extend;
        l_bill_rate_override_tab.extend;
        l_line_start_date_tab.extend;
        l_line_end_date_tab.extend;

        l_delete_budget_lines_tab(i)     := Null;
        l_spread_amts_flag_tab(i)        := Null;
        --l_txn_currency_code_tab(i)       := l_txn_currency_code_tab(i)
        l_txn_currency_override_tab(i)   := Null;
        --l_total_qty_tab(i)               := Null;
        l_addl_qty_tab(i)                := Null;
        l_total_raw_cost_tab(i)          := Null;
        l_addl_raw_cost_tab(i)           := Null;
        l_total_burdened_cost_tab(i)     := Null;
        l_addl_burdened_cost_tab(i)      := Null;
        l_addl_revenue_tab(i)            := Null;
        l_raw_cost_rate_tab(i)           := Null;
        l_rw_cost_rate_override_tab(i)   := Null;
        l_b_cost_rate_tab(i)             := Null;
        l_b_cost_rate_override_tab(i)    := Null;
        l_bill_rate_tab(i)               := Null;
        l_bill_rate_override_tab(i)      := Null;
        l_line_start_date_tab(i)         := Null;
        l_line_end_date_tab(i)           := Null;
    END LOOP;

    -- Bug 4149684: Added p_calling_module and p_rollup_required_flag to parameter list of
    -- Calculate API with values 'BUDGET_GENERATION' and 'N', respectively, so that calling
    -- PJI rollup api is bypassed for increased performance.

    /* Calling the calculate API */
    IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
            (p_called_mode => p_called_mode,
                p_msg          => 'Before calling
                pa_fp_calc_plan_pkg.calculate',
                p_module_name  => l_module_name,
                p_log_level    => 5);
    END IF;
    PA_FP_CALC_PLAN_PKG.calculate
        (p_calling_module              => l_calling_module
        ,p_project_id                  => p_project_id
        ,p_budget_version_id           => p_budget_version_id
        ,p_refresh_rates_flag          => l_refresh_rates_flag
        ,p_refresh_conv_rates_flag     => l_refresh_conv_rates_flag
        ,p_spread_required_flag        => l_spread_required_flag
        ,p_conv_rates_required_flag    => l_conv_rates_required_flag
        ,p_rollup_required_flag        => l_rollup_required_flag
    ,p_mass_adjust_flag            => l_mass_adjust_flag
        ,p_quantity_adj_pct            => l_quantity_adj_pct
        ,p_cost_rate_adj_pct           => l_cost_rate_adj_pct
        ,p_burdened_rate_adj_pct       => l_burdened_rate_adj_pct
        ,p_bill_rate_adj_pct           => l_bill_rate_adj_pct
        ,p_source_context              => l_source_context
        ,p_resource_assignment_tab     => l_res_asg_id_tab
        ,p_delete_budget_lines_tab     => l_delete_budget_lines_tab
        ,p_spread_amts_flag_tab        => l_spread_amts_flag_tab
        ,p_txn_currency_code_tab       => l_txn_currency_code_tab
        ,p_txn_currency_override_tab   => l_txn_currency_override_tab
        ,p_total_qty_tab               => l_ra_quantity_tab --l_total_qty_tab
        ,p_addl_qty_tab                => l_addl_qty_tab
        ,p_total_raw_cost_tab          => l_total_raw_cost_tab
        ,p_addl_raw_cost_tab           => l_addl_raw_cost_tab
        ,p_total_burdened_cost_tab     => l_total_burdened_cost_tab
        ,p_addl_burdened_cost_tab      => l_addl_burdened_cost_tab
        ,p_total_revenue_tab           => l_total_revenue_tab
        ,p_addl_revenue_tab            => l_addl_revenue_tab
        ,p_raw_cost_rate_tab           => l_raw_cost_rate_tab
        ,p_rw_cost_rate_override_tab   => l_rw_cost_rate_override_tab
    ,p_b_cost_rate_tab             => l_b_cost_rate_tab
        ,p_b_cost_rate_override_tab    => l_b_cost_rate_override_tab
        ,p_bill_rate_tab               => l_bill_rate_tab
        ,p_bill_rate_override_tab      => l_bill_rate_override_tab
        ,p_line_start_date_tab         => l_line_start_date_tab
        ,p_line_end_date_tab           => l_line_end_date_tab
        ,X_RETURN_STATUS               => X_RETURN_STATUS
        ,X_MSG_COUNT                   => X_MSG_COUNT
        ,X_MSG_DATA              => X_MSG_DATA);
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;
    IF p_pa_debug_mode = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
            (p_called_mode => p_called_mode,
            p_msg         => 'Status after calling
                             pa_fp_calc_plan_pkg.calculate: '
                            ||x_return_status,
            p_module_name => l_module_name,
            p_log_level   => 5);
    END IF;

    IF P_COMMIT_FLAG = 'Y' THEN
        COMMIT;
    END IF;

    IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
        PA_DEBUG.reset_err_stack;
    ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
        PA_DEBUG.Reset_Curr_Function;
    END IF;

EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
    -- Bug Fix: 4569365. Removed MRC code.
    --      PA_MRC_FINPLAN.G_CALLING_MODULE := Null;
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count = 1 THEN
            PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE
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

        IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
            PA_DEBUG.reset_err_stack;
        ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;

     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data      := SUBSTR(SQLERRM,1,240);
        FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_BUDGET_AMT_PUB'
              ,p_procedure_name => 'GEN_REV_BDGT_AMT_RES_SCH_WRP');

        IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
            PA_DEBUG.reset_err_stack;
        ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GEN_REV_BDGT_AMT_RES_SCH_WRP;

PROCEDURE GEN_WP_REV_BDGT_AMT_WRP
    (P_PROJECT_ID                    IN            PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
    P_BUDGET_VERSION_ID          IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
    P_PLAN_CLASS_CODE                IN            PA_FIN_PLAN_TYPES_B.PLAN_CLASS_CODE%TYPE,
    P_GEN_SRC_CODE                   IN            PA_PROJ_FP_OPTIONS.GEN_ALL_SRC_CODE%TYPE,
    P_COST_PLAN_TYPE_ID              IN            PA_PROJ_FP_OPTIONS.GEN_SRC_COST_PLAN_TYPE_ID%TYPE,
    P_COST_VERSION_ID                IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
    P_RETAIN_MANUAL_FLAG             IN            VARCHAR2,
    P_CALLED_MODE                    IN            VARCHAR2,
    P_INC_CHG_DOC_FLAG               IN            VARCHAR2,
    P_INC_BILL_EVENT_FLAG            IN            VARCHAR2,
    P_INC_OPEN_COMMIT_FLAG           IN            VARCHAR2,
    P_CI_ID_TAB                      IN            PA_PLSQL_DATATYPES.IdTabTyp,
    P_INIT_MSG_FLAG                  IN            VARCHAR2,
    P_COMMIT_FLAG                    IN            VARCHAR2,
    PX_DELETED_RES_ASG_ID_TAB        IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
    PX_GEN_RES_ASG_ID_TAB            IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
    X_RETURN_STATUS                  OUT  NOCOPY   VARCHAR2,
    X_MSG_COUNT                      OUT  NOCOPY   NUMBER,
    X_MSG_DATA                       OUT  NOCOPY   VARCHAR2) IS
 l_module_name         VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_BUDGET_AMT_PUB.GEN_WP_REV_BDGT_AMT_WRP';

 /*local variable for calling get planning rates*/
 l_res_asg_id_tab           SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_ra_quantity_tab          SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_task_id_tab              PA_PLSQL_DATATYPES.IdTabTyp;
 l_res_list_member_id_tab       PA_PLSQL_DATATYPES.IdTabTyp;
 l_txn_currency_code_tab        SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
 l_ra_start_date_tab            PA_PLSQL_DATATYPES.DateTabTyp;
 l_uom_tab              pa_plsql_datatypes.Char30TabTyp;
 l_rate_based_flag_tab          pa_plsql_datatypes.Char30TabTyp;
 l_resource_class_code_tab      pa_plsql_datatypes.Char30TabTyp;
 l_organization_id_tab          pa_plsql_datatypes.Char30TabTyp;
 l_job_id_tab               PA_PLSQL_DATATYPES.IdTabTyp;
 l_person_id_tab            PA_PLSQL_DATATYPES.IdTabTyp;
 l_expenditure_type_tab         pa_plsql_datatypes.Char30TabTyp;
 l_non_labor_resource_tab       pa_plsql_datatypes.Char30TabTyp;
 l_bom_resource_id_tab          PA_PLSQL_DATATYPES.IdTabTyp;
 l_inventory_item_id_tab        PA_PLSQL_DATATYPES.IdTabTyp;
 l_item_category_id_tab         PA_PLSQL_DATATYPES.IdTabTyp;
 l_mfc_cost_type_id_tab         PA_PLSQL_DATATYPES.IdTabTyp;
 l_rate_incur_by_organz_id_tab      PA_PLSQL_DATATYPES.IdTabTyp;
 l_rate_ovrd_to_organz_id_tab       PA_PLSQL_DATATYPES.IdTabTyp;
 l_rate_expenditure_org_id_tab      PA_PLSQL_DATATYPES.IdTabTyp;
 l_rate_expenditure_type_tab        pa_plsql_datatypes.Char30TabTyp;
 l_rate_organization_id_tab     PA_PLSQL_DATATYPES.IdTabTyp;
 l_project_assignment_id_tab        PA_PLSQL_DATATYPES.IdTabTyp;

 l_assign_precedes_task_tab     pa_plsql_datatypes.Char30TabTyp;
 l_bill_job_group_id_tab        PA_PLSQL_DATATYPES.IdTabTyp;
 l_carry_out_organiz_id_tab     PA_PLSQL_DATATYPES.IdTabTyp;
 l_multi_currency_bill_flag_tab     pa_plsql_datatypes.Char30TabTyp;
 l_org_id_tab               PA_PLSQL_DATATYPES.IdTabTyp;
 l_non_lab_bill_rate_org_id_tab     PA_PLSQL_DATATYPES.IdTabTyp;
 l_non_lab_sch_discount_tab     PA_PLSQL_DATATYPES.NumTabTyp;
 l_non_lab_sch_fixed_date_tab       PA_PLSQL_DATATYPES.DateTabTyp;
 l_project_type_tab         pa_plsql_datatypes.Char30TabTyp;
 l_lab_bill_rate_org_id_tab     PA_PLSQL_DATATYPES.IdTabTyp;

 l_lab_sch_FIXED_DATE_tab       PA_PLSQL_DATATYPES.DateTabTyp;
 l_top_task_id_tab          PA_PLSQL_DATATYPES.IdTabTyp;
 l_scheduled_start_date_tab     PA_PLSQL_DATATYPES.DateTabTyp;
 l_labor_scheduled_discount_tab     PA_PLSQL_DATATYPES.NumTabTyp;
 l_labor_sch_type_tab           pa_plsql_datatypes.Char30TabTyp;
 l_non_labor_sch_type_tab       pa_plsql_datatypes.Char30TabTyp;

 l_rev_res_class_rt_sch_id_tab      PA_PLSQL_DATATYPES.IdTabTyp;
 l_cost_res_class_rt_sch_id_tab     PA_PLSQL_DATATYPES.IdTabTyp;

 l_res_format_id_tab            PA_PLSQL_DATATYPES.IdTabTyp;

 l_bill_rate                number;
 l_cost_rate                number;
 l_burden_cost_rate         number;
 l_burden_multiplier            number;
 l_raw_cost             number;
 l_burden_cost              number;
 l_raw_revenue              number;
 l_bill_markup_percentage       number;
 l_cost_txn_curr_code           varchar2(30);
 l_rev_txn_curr_code            varchar2(30);
 l_raw_cost_rejection_code      varchar2(30);
 l_burden_cost_rejection_code       varchar2(30);
 l_revenue_rejection_code       varchar2(30);
 l_cost_ind_compiled_set_id     number;

  /*Local PL/SQL table used for calling Calculate API*/
 l_calling_module                  VARCHAR2(30) := 'BUDGET_GENERATION';
 l_refresh_rates_flag              VARCHAR2(1) := 'Y';
 l_refresh_conv_rates_flag         VARCHAR2(1) := 'N';
 l_spread_required_flag            VARCHAR2(1) := 'N';
 l_conv_rates_required_flag        VARCHAR2(1) := 'N';
 l_rollup_required_flag            VARCHAR2(1) := 'N';
 l_mass_adjust_flag                VARCHAR2(1) := 'N';
 l_quantity_adj_pct                NUMBER   := NULL;
 l_cost_rate_adj_pct               NUMBER   := NULL;
 l_burdened_rate_adj_pct           NUMBER   := NULL;
 l_bill_rate_adj_pct               NUMBER   := NULL;
 l_source_context                  pa_fp_res_assignments_tmp.source_context%TYPE := 'RESOURCE_ASSIGNMENT';

 l_delete_budget_lines_tab         SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
 l_spread_amts_flag_tab            SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
 l_txn_currency_override_tab       SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
 l_addl_qty_tab                    SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_total_raw_cost_tab              SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_addl_raw_cost_tab               SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_total_burdened_cost_tab         SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_addl_burdened_cost_tab          SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_total_revenue_tab               SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_addl_revenue_tab                SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_raw_cost_rate_tab               SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_rw_cost_rate_override_tab       SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_b_cost_rate_tab                 SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_b_cost_rate_override_tab        SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_bill_rate_tab                   SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_bill_rate_override_tab          SYSTEM.pa_num_tbl_type:= SYSTEM.pa_num_tbl_type();
 l_line_start_date_tab             SYSTEM.pa_date_tbl_type:=SYSTEM.pa_date_tbl_type();
 l_line_end_date_tab               SYSTEM.pa_date_tbl_type:=SYSTEM.pa_date_tbl_type();
/*end variable for calculate*/

 l_msg_count                    NUMBER;
 l_msg_data                     VARCHAR2(2000);
 l_data                         VARCHAR2(2000);
 l_msg_index_out                NUMBER:=0;
BEGIN
    IF p_init_msg_flag = 'Y' THEN
        FND_MSG_PUB.initialize;
    END IF;
    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
        PA_DEBUG.init_err_stack('PA_FP_GEN_BUDGET_AMT_PUB.GEN_REV_BDGT_AMT_RES_SCH_WRP');
    ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
        pa_debug.set_curr_function(p_function     => 'GEN_WP_REV_BDGT_AMT_WRP',
                                   p_debug_mode   =>  p_pa_debug_mode);
    END IF;

    IF p_pa_debug_mode = 'Y' THEN
    pa_fp_gen_amount_utils.fp_debug
             (p_called_mode => p_called_mode,
              p_msg         => 'Before calling
              pa_fp_wp_gen_budget_amt_pub.generate_wp_budget_amt',
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;
    PA_FP_WP_GEN_BUDGET_AMT_PUB.GENERATE_WP_BUDGET_AMT
    (P_PROJECT_ID              => P_PROJECT_ID,
        P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
        P_PLAN_CLASS_CODE          => P_PLAN_CLASS_CODE,
        P_GEN_SRC_CODE             => P_GEN_SRC_CODE,
        P_COST_PLAN_TYPE_ID        => P_COST_PLAN_TYPE_ID,
    P_COST_VERSION_ID          => P_COST_VERSION_ID,
    P_RETAIN_MANUAL_FLAG       => P_RETAIN_MANUAL_FLAG,
    P_CALLED_MODE              => P_CALLED_MODE,
    P_INC_CHG_DOC_FLAG         => P_INC_CHG_DOC_FLAG,
    P_INC_BILL_EVENT_FLAG      => P_INC_BILL_EVENT_FLAG,
        P_INC_OPEN_COMMIT_FLAG     => P_INC_OPEN_COMMIT_FLAG,
        P_CI_ID_TAB                => P_CI_ID_TAB,
        PX_GEN_RES_ASG_ID_TAB      => PX_GEN_RES_ASG_ID_TAB,
        PX_DELETED_RES_ASG_ID_TAB  => PX_DELETED_RES_ASG_ID_TAB,
        P_INIT_MSG_FLAG            => P_INIT_MSG_FLAG,
        P_COMMIT_FLAG              => P_COMMIT_FLAG,
        X_RETURN_STATUS            => X_RETURN_STATUS,
        X_MSG_COUNT                => X_MSG_COUNT,
        X_MSG_DATA             => X_MSG_DATA);
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;
    IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_called_mode => p_called_mode,
              p_msg         => 'Status after calling pa_fp_wp_gen_budget_amt_pub.generate_wp_budget_amt:'
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;

    SELECT
    tmp.RESOURCE_ASSIGNMENT_ID,
        tmp.total_plan_quantity,
    ra.task_id,
    ra.resource_list_member_id,
        tmp.txn_currency_code,
    ra.planning_start_date,
    ra.unit_of_measure,
    ra.rate_based_flag,
    ra.resource_class_code,
        ra.organization_id,
        ra.job_id,
        ra.person_id,
        ra.expenditure_type,
        ra.non_labor_resource,
        ra.bom_resource_id,
        ra.inventory_item_id,
        ra.item_category_id,
        ra.mfc_cost_type_id,
        ra.organization_id,
        null,
        ra.rate_expenditure_org_id,
        ra.rate_expenditure_type,
        ra.organization_id,
    ra.project_assignment_id,

        proj.assign_precedes_task,
        proj.bill_job_group_id,
        proj.carrying_out_organization_id,
        proj.multi_currency_billing_flag,
        proj.org_id,
        proj.non_labor_bill_rate_org_id,
        proj.non_labor_schedule_discount,
        proj.non_labor_schedule_fixed_date,
        proj.project_type,
        proj.labor_bill_rate_org_id,

        t.LABOR_SCHEDULE_FIXED_DATE,
        t.top_task_id,
    t.scheduled_start_date,
    t.labor_schedule_discount,
    t.labor_sch_type,
    t.non_labor_sch_type,

    decode(fp.use_planning_rates_flag,'N',fp.res_class_bill_rate_sch_id,
               fp.rev_res_class_rate_sch_id),
        decode(fp.use_planning_rates_flag,'N',fp.res_class_raw_cost_sch_id,
               NULL),

    res_format_id
    BULK COLLECT INTO
    l_res_asg_id_tab,
    l_ra_quantity_tab,
    l_task_id_tab,
    l_res_list_member_id_tab,
    l_txn_currency_code_tab,
    l_ra_start_date_tab,
    l_uom_tab,
    l_rate_based_flag_tab,
    l_resource_class_code_tab,
        l_organization_id_tab,
        l_job_id_tab,
        l_person_id_tab,
        l_expenditure_type_tab,
        l_non_labor_resource_tab,
        l_bom_resource_id_tab,
        l_inventory_item_id_tab,
        l_item_category_id_tab,
        l_mfc_cost_type_id_tab,
        l_rate_incur_by_organz_id_tab,
        l_rate_ovrd_to_organz_id_tab,
        l_rate_expenditure_org_id_tab,
        l_rate_expenditure_type_tab,
        l_rate_organization_id_tab,
    l_project_assignment_id_tab,

    l_assign_precedes_task_tab,
    l_bill_job_group_id_tab,
        l_carry_out_organiz_id_tab,
        l_multi_currency_bill_flag_tab,
        l_org_id_tab,
        l_non_lab_bill_rate_org_id_tab,
        l_non_lab_sch_discount_tab,
        l_non_lab_sch_fixed_date_tab,
        l_project_type_tab,

        l_lab_bill_rate_org_id_tab,
        l_lab_sch_FIXED_DATE_tab,
        l_top_task_id_tab,
    l_scheduled_start_date_tab,
    l_labor_scheduled_discount_tab,
    l_labor_sch_type_tab,
    l_non_labor_sch_type_tab,

    l_rev_res_class_rt_sch_id_tab,
        l_cost_res_class_rt_sch_id_tab,

    l_res_format_id_tab
    FROM pa_fp_calc_amt_tmp2 tmp, pa_resource_assignments ra,
     pa_projects_all proj, pa_tasks t,
         pa_proj_fp_options fp,
     pa_resource_list_members rlm
    WHERE tmp.resource_assignment_id = ra.resource_assignment_id
      AND ra.project_id = proj.project_id
      AND ra.task_id = t.task_id(+)
          AND fp.fin_plan_version_id = ra.budget_version_id
      AND ra.resource_list_member_id = rlm.resource_list_member_id;

    FOR i IN 1..l_res_asg_id_tab.count LOOP
        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Before calling pa_plan_revenue.Get_planning_Rates',
                 p_module_name => l_module_name,
                 p_log_level   => 5);
    END IF;
        PA_PLAN_REVENUE.GET_PLANNING_RATES(
        p_project_id                 => p_project_id,
            p_task_id                    => l_task_id_tab(i),
            p_top_task_id                => l_top_task_id_tab(i),
            p_person_id                  => l_person_id_tab(i),
            p_job_id                     => l_job_id_tab(i),
            p_bill_job_grp_id            => l_bill_job_group_id_tab(i),
            p_resource_class             => l_resource_class_code_tab(i),
            p_planning_resource_format   => l_res_format_id_tab(i),
            p_use_planning_rates_flag    => 'N',
            p_rate_based_flag            => l_rate_based_flag_tab(i),
            p_uom                        => l_uom_tab(i),
            p_system_linkage             => NULL,
            p_project_organz_id          => l_carry_out_organiz_id_tab(i),
            p_rev_res_class_rate_sch_id  => l_rev_res_class_rt_sch_id_tab(i),
            p_cost_res_class_rate_sch_id => l_cost_res_class_rt_sch_id_tab(i),
            p_calculate_mode             => 'REVENUE',
            p_mcb_flag                   => l_multi_currency_bill_flag_tab(i),
            p_quantity                   => l_ra_quantity_tab(i),
            p_item_date                  => l_ra_start_date_tab(i),
            p_cost_sch_type              => 'COST',
            p_labor_sch_type             => l_labor_sch_type_tab(i),
            p_non_labor_sch_type         => l_non_labor_sch_type_tab(i),
            --p_labor_schdl_discnt         => NULL,
            p_labor_bill_rate_org_id     => l_lab_bill_rate_org_id_tab(i),
            --p_labor_std_bill_rate_schdl  => NULL,
            p_labor_schdl_fixed_date     => l_LAb_SCH_FIXED_DATE_tab(i),
            p_assignment_id              => l_project_assignment_id_tab(i),
            p_project_org_id             => l_org_id_tab(i),
            p_project_type               => l_project_type_tab(i),
            p_expenditure_type           => nvl(l_expenditure_type_tab(i),l_rate_expenditure_type_tab(i)),
            p_non_labor_resource         => l_non_labor_resource_tab(i),
            p_incurred_by_organz_id      => nvl(l_rate_incur_by_organz_id_tab(i),l_organization_id_tab(i)),
            p_override_to_organz_id      => l_rate_ovrd_to_organz_id_tab(i),
            p_expenditure_org_id         => nvl(l_rate_expenditure_org_id_tab(i),l_org_id_tab(i)),
            p_assignment_precedes_task   => l_assign_precedes_task_tab(i),
            p_planning_transaction_id    => l_res_asg_id_tab(i),
            --,p_task_bill_rate_org_id      => l_task_bill_rate_org_id,
            p_project_bill_rate_org_id   => l_non_lab_bill_rate_org_id_tab(i),
            p_nlr_organization_id        => nvl(l_organization_id_tab(i),l_carry_out_organiz_id_tab(i)),
            p_project_sch_date           => l_non_lab_sch_fixed_date_tab(i),
            p_task_sch_date              => l_scheduled_start_date_tab(i),
            p_project_sch_discount       => l_non_lab_sch_discount_tab(i),
            p_task_sch_discount          => l_labor_scheduled_discount_tab(i),
            p_inventory_item_id          => l_inventory_item_id_tab(i),
            p_BOM_resource_Id            => l_bom_resource_id_tab(i),
            p_mfc_cost_type_id           => l_mfc_cost_type_id_tab(i),
            p_item_category_id           => l_item_category_id_tab(i),
            --,p_mfc_cost_source            => l_mfc_cost_source,
            --,p_cost_override_rate         => l_rw_cost_rate_override,
            --,p_revenue_override_rate      => l_bill_rate_override,
            --,p_override_burden_cost_rate  => l_burden_cost_rate_override,
            --,p_override_currency_code     => l_txn_currency_code_override,
            p_txn_currency_code          => l_txn_currency_code_tab(i),
            p_raw_cost                   => NULL,
            p_burden_cost                => NULL,
            p_raw_revenue                => NULL,
            x_bill_rate                  => l_bill_rate,
            x_cost_rate                  => l_cost_rate,
            x_burden_cost_rate           => l_burden_cost_rate,
            x_burden_multiplier          => l_burden_multiplier,
            x_raw_cost                   => l_raw_cost,
            x_burden_cost                => l_burden_cost,
            x_raw_revenue                => l_raw_revenue,
            x_bill_markup_percentage     => l_bill_markup_percentage,
            x_cost_txn_curr_code         => l_cost_txn_curr_code,
            x_rev_txn_curr_code          => l_rev_txn_curr_code,
            x_raw_cost_rejection_code    => l_raw_cost_rejection_code,
            x_burden_cost_rejection_code => l_burden_cost_rejection_code,
            x_revenue_rejection_code     => l_revenue_rejection_code,
            x_cost_ind_compiled_set_id   => l_cost_ind_compiled_set_id,
            x_return_status              => x_return_status,
            x_msg_data                   => x_msg_data,
            x_msg_count                  => x_msg_count);
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                 (p_msg         => 'Status after calling pa_plan_revenue.Get_planning_Rates'
                                   ||x_return_status,
                  p_module_name => l_module_name,
                  p_log_level   => 5);
        END IF;

        l_total_revenue_tab.extend;
    l_total_revenue_tab(i) := l_burden_cost;

    END LOOP;

    FOR i IN 1..l_res_asg_id_tab.count LOOP
    l_delete_budget_lines_tab.extend;
        l_spread_amts_flag_tab.extend;
        --l_txn_currency_code_tab.extend;
        l_txn_currency_override_tab.extend;
        --l_total_qty_tab.extend;
        l_addl_qty_tab.extend;
        l_total_raw_cost_tab.extend;
        l_addl_raw_cost_tab.extend;
        l_total_burdened_cost_tab.extend;
        l_addl_burdened_cost_tab.extend;
        l_addl_revenue_tab.extend;
        l_raw_cost_rate_tab.extend;
        l_rw_cost_rate_override_tab.extend;
        l_b_cost_rate_tab.extend;
        l_b_cost_rate_override_tab.extend;
        l_bill_rate_tab.extend;
        l_bill_rate_override_tab.extend;
        l_line_start_date_tab.extend;
        l_line_end_date_tab.extend;

        l_delete_budget_lines_tab(i)     := Null;
        l_spread_amts_flag_tab(i)        := Null;
        --l_txn_currency_code_tab(i)       := l_txn_currency_code_tab(i)
        l_txn_currency_override_tab(i)   := Null;
        --l_total_qty_tab(i)               := Null;
        l_addl_qty_tab(i)                := Null;
        l_total_raw_cost_tab(i)          := Null;
        l_addl_raw_cost_tab(i)           := Null;
        l_total_burdened_cost_tab(i)     := Null;
        l_addl_burdened_cost_tab(i)      := Null;
        l_addl_revenue_tab(i)            := Null;
        l_raw_cost_rate_tab(i)           := Null;
        l_rw_cost_rate_override_tab(i)   := Null;
        l_b_cost_rate_tab(i)             := Null;
        l_b_cost_rate_override_tab(i)    := Null;
        l_bill_rate_tab(i)               := Null;
        l_bill_rate_override_tab(i)      := Null;
        l_line_start_date_tab(i)         := Null;
        l_line_end_date_tab(i)           := Null;
    END LOOP;

    -- Bug 4149684: Added p_calling_module and p_rollup_required_flag to parameter list of
    -- Calculate API with values 'BUDGET_GENERATION' and 'N', respectively, so that calling
    -- PJI rollup api is bypassed for increased performance.

    /* Calling the calculate API */
    IF p_pa_debug_mode = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
           (p_called_mode => p_called_mode,
            p_msg          => 'Before calling pa_fp_calc_plan_pkg.calculate',
            p_module_name  => l_module_name,
            p_log_level    => 5);
    END IF;
    PA_FP_CALC_PLAN_PKG.calculate
        (p_calling_module              => l_calling_module
        ,p_project_id                  => p_project_id
        ,p_budget_version_id           => p_budget_version_id
        ,p_refresh_rates_flag          => l_refresh_rates_flag
        ,p_refresh_conv_rates_flag     => l_refresh_conv_rates_flag
        ,p_spread_required_flag        => l_spread_required_flag
        ,p_conv_rates_required_flag    => l_conv_rates_required_flag
        ,p_rollup_required_flag        => l_rollup_required_flag
    ,p_mass_adjust_flag            => l_mass_adjust_flag
        ,p_quantity_adj_pct            => l_quantity_adj_pct
        ,p_cost_rate_adj_pct           => l_cost_rate_adj_pct
        ,p_burdened_rate_adj_pct       => l_burdened_rate_adj_pct
        ,p_bill_rate_adj_pct           => l_bill_rate_adj_pct
        ,p_source_context              => l_source_context
        ,p_resource_assignment_tab     => l_res_asg_id_tab
        ,p_delete_budget_lines_tab     => l_delete_budget_lines_tab
        ,p_spread_amts_flag_tab        => l_spread_amts_flag_tab
        ,p_txn_currency_code_tab       => l_txn_currency_code_tab
        ,p_txn_currency_override_tab   => l_txn_currency_override_tab
        ,p_total_qty_tab               => l_ra_quantity_tab --l_total_qty_tab
        ,p_addl_qty_tab                => l_addl_qty_tab
        ,p_total_raw_cost_tab          => l_total_raw_cost_tab
        ,p_addl_raw_cost_tab           => l_addl_raw_cost_tab
        ,p_total_burdened_cost_tab     => l_total_burdened_cost_tab
        ,p_addl_burdened_cost_tab      => l_addl_burdened_cost_tab
        ,p_total_revenue_tab           => l_total_revenue_tab
        ,p_addl_revenue_tab            => l_addl_revenue_tab
        ,p_raw_cost_rate_tab           => l_raw_cost_rate_tab
        ,p_rw_cost_rate_override_tab   => l_rw_cost_rate_override_tab
    ,p_b_cost_rate_tab             => l_b_cost_rate_tab
        ,p_b_cost_rate_override_tab    => l_b_cost_rate_override_tab
        ,p_bill_rate_tab               => l_bill_rate_tab
        ,p_bill_rate_override_tab      => l_bill_rate_override_tab
        ,p_line_start_date_tab         => l_line_start_date_tab
        ,p_line_end_date_tab           => l_line_end_date_tab
        ,X_RETURN_STATUS               => X_RETURN_STATUS
        ,X_MSG_COUNT                   => X_MSG_COUNT
        ,X_MSG_DATA              => X_MSG_DATA);
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;
    IF p_pa_debug_mode = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
            (p_called_mode => p_called_mode,
            p_msg         => 'Status after calling
                             pa_fp_calc_plan_pkg.calculate: '
                            ||x_return_status,
            p_module_name => l_module_name,
            p_log_level   => 5);
    END IF;

    IF P_COMMIT_FLAG = 'Y' THEN
        COMMIT;
    END IF;

    IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
        PA_DEBUG.reset_err_stack;
    ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
        PA_DEBUG.Reset_Curr_Function;
    END IF;

EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
    -- Bug Fix: 4569365. Removed MRC code.
    --      PA_MRC_FINPLAN.G_CALLING_MODULE := Null;
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count = 1 THEN
            PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE
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

        IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
            PA_DEBUG.reset_err_stack;
        ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data      := SUBSTR(SQLERRM,1,240);
        FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_BUDGET_AMT_PUB'
              ,p_procedure_name => 'GEN_WP_REV_BDGT_AMT_WRP');

        IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
            PA_DEBUG.reset_err_stack;
        ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GEN_WP_REV_BDGT_AMT_WRP;

END PA_FP_GEN_BUDGET_AMT_PUB;

/
