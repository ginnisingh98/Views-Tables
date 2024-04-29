--------------------------------------------------------
--  DDL for Package Body PA_FP_GEN_FCST_AMT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_GEN_FCST_AMT_PUB" as
/* $Header: PAFPFGPB.pls 120.16.12010000.3 2009/08/03 05:42:51 kmaddi ship $ */


P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

-----------------------------------------------------------------------
--------- Forward declarations for local/private procedures -----------
-----------------------------------------------------------------------

PROCEDURE UPD_REV_CALCULATION_ERR
          (P_PROJECT_ID              IN          PA_PROJECTS_ALL.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC             IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_ETC_START_DATE          IN          DATE,
           P_CALLED_MODE             IN          VARCHAR2 DEFAULT 'SELF_SERVICE',
           X_RETURN_STATUS           OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY NUMBER,
           X_MSG_DATA                OUT  NOCOPY VARCHAR2 );

------------------------------------------------------------------------------
--------- END OF Forward declarations for local/private procedures -----------
------------------------------------------------------------------------------

/**GENERATE_FCST_AMT_WRP is called from PA_FP_GEN_FCST_PG_PKG.UPD_VER_DTLS_AND_GEN_AMT,
  *which was called directly from forecast generation page.
 **/
PROCEDURE GENERATE_FCST_AMT_WRP
       (   P_PROJECT_ID              IN          PA_PROJECTS_ALL.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC             IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_CALLED_MODE             IN          VARCHAR2,
           P_COMMIT_FLAG             IN          VARCHAR2,
           P_INIT_MSG_FLAG           IN          VARCHAR2,
           P_VERSION_TYPE            IN          PA_BUDGET_VERSIONS.VERSION_TYPE%TYPE,
           P_UNSPENT_AMT_FLAG        IN          PA_PROJ_FP_OPTIONS.GEN_COST_INCL_UNSPENT_AMT_FLAG%TYPE,
           P_UNSPENT_AMT_PERIOD      IN          VARCHAR2,
           P_INCL_CHG_DOC_FLAG       IN          PA_PROJ_FP_OPTIONS.GEN_COST_INCL_CHANGE_DOC_FLAG%TYPE,
           P_INCL_OPEN_CMT_FLAG      IN          PA_PROJ_FP_OPTIONS.GEN_COST_INCL_OPEN_COMM_FLAG%TYPE,
           P_INCL_BILL_EVT_FLAG      IN          PA_PROJ_FP_OPTIONS.GEN_REV_INCL_BILL_EVENT_FLAG%TYPE,
           P_RET_MANUAL_LNS_FLAG     IN          PA_PROJ_FP_OPTIONS.GEN_COST_RET_MANUAL_LINE_FLAG%TYPE,
           P_PLAN_TYPE_ID            IN          PA_PROJ_FP_OPTIONS.FIN_PLAN_TYPE_ID%TYPE,
           P_PLAN_VERSION_ID         IN          PA_PROJ_FP_OPTIONS.FIN_PLAN_VERSION_ID%TYPE,
           P_PLAN_VERSION_NAME       IN          PA_BUDGET_VERSIONS.VERSION_NAME%TYPE,
           P_ETC_PLAN_TYPE_ID        IN          PA_PROJ_FP_OPTIONS.FIN_PLAN_TYPE_ID%TYPE,
           P_ETC_PLAN_VERSION_ID     IN          PA_PROJ_FP_OPTIONS.FIN_PLAN_VERSION_ID%TYPE,
           P_ETC_PLAN_VERSION_NAME   IN          PA_BUDGET_VERSIONS.VERSION_NAME%TYPE,
           P_ACTUALS_FROM_PERIOD     IN          VARCHAR2,
           P_ACTUALS_TO_PERIOD       IN          VARCHAR2,
           P_ETC_FROM_PERIOD         IN          VARCHAR2,
           P_ETC_TO_PERIOD           IN          VARCHAR2,
           P_ACTUALS_THRU_PERIOD     IN          PA_BUDGET_VERSIONS.ACTUAL_AMTS_THRU_PERIOD%TYPE,
           P_ACTUALS_THRU_DATE       IN          PA_PERIODS_ALL.END_DATE%TYPE,
           P_WP_STRUCTURE_VERSION_ID IN          PA_PROJ_ELEM_VER_STRUCTURE.ELEMENT_VERSION_ID%TYPE,
           X_RETURN_STATUS           OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY NUMBER,
           X_MSG_DATA                OUT  NOCOPY VARCHAR2) IS

l_module_name                VARCHAR2(200) := 'pa.plsql.pa_fp_gen_fcst_amt_pub.generate_fcst_amt_wrp';
l_cost_version_id            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE;
l_ci_id_tab                  PA_PLSQL_DATATYPES.IdTabTyp;
l_gen_res_asg_id_tab         PA_PLSQL_DATATYPES.IdTabTyp;
l_deleted_res_asg_id_tab     PA_PLSQL_DATATYPES.IdTabTyp;

l_rev_gen_method             VARCHAR2(3);
l_error_msg                  VARCHAR2(30);
l_msg_count                  NUMBER;
l_msg_data                   VARCHAR2(2000);
l_data                       VARCHAR2(2000);
l_msg_index_out              NUMBER:=0;

l_count                      NUMBER;
l_dummy                      NUMBER;
l_task_count                 NUMBER;

l_src_plan_class_code        pa_fin_plan_types_b.plan_class_code%type;
l_src_version_type           pa_budget_versions.version_type%type;
lx_deleted_res_asg_id_tab  PA_PLSQL_DATATYPES.IdTabTyp;
lx_gen_res_asg_id_tab      PA_PLSQL_DATATYPES.IdTabTyp;

-- Bug 4592564: Removed variables for Unspent Amounts option.

-- Added as part of fix for Bug 4232094
l_budget_generation_flow_flag  VARCHAR2(1) := 'N';

l_call_maintain_data_api       VARCHAR2(1);

--Bug 8557807
l_ci_id_tbl                    SYSTEM.pa_num_tbl_type:=SYSTEM.PA_NUM_TBL_TYPE();
l_translated_msgs_tbl          SYSTEM.pa_varchar2_2000_tbl_type;
l_translated_err_msg_count     NUMBER;
l_translated_err_msg_level_tbl SYSTEM.pa_varchar2_30_tbl_type;
l_budget_version_id_tbl        SYSTEM.pa_num_tbl_type:=SYSTEM.PA_NUM_TBL_TYPE();
l_impl_cost_flag_tbl           SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
l_impl_rev_flag_tbl            SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();

BEGIN
    /* hr_utility.trace_on(null,'mftest');
    hr_utility.trace('---BEGIN---'); */
    IF P_INIT_MSG_FLAG = 'Y' THEN
        FND_MSG_PUB.initialize;
    END IF;
    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function     => 'GENERATE_FCST_AMT_WRP',
                                    p_debug_mode   =>  p_pa_debug_mode);
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_called_mode => P_CALLED_MODE,
                p_msg         =>
                 'Before calling PA_FP_GEN_BUDGET_AMT_PUB.UPDATE_BV_FOR_GEN_DATE',
                p_module_name => l_module_name);
    END IF;
    PA_FP_GEN_BUDGET_AMT_PUB.UPDATE_BV_FOR_GEN_DATE
               (P_PROJECT_ID                 => P_PROJECT_ID,
                P_BUDGET_VERSION_ID          => P_BUDGET_VERSION_ID,
                P_ETC_START_DATE             => P_ACTUALS_THRU_DATE + 1,
                X_RETURN_STATUS              => X_RETURN_STATUS,
                X_MSG_COUNT                  => X_MSG_COUNT,
                X_MSG_DATA                   => X_MSG_DATA);
    IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_called_mode => P_CALLED_MODE,
                p_msg         => 'After calling PA_FP_GEN_BUDGET_AMT_PUB.UPDATE_BV_FOR_GEN_DATE,
                            ret status: '||x_return_status,
                p_module_name => l_module_name);
    END IF;

    DELETE FROM PA_FP_CALC_AMT_TMP1;
    DELETE FROM PA_FP_CALC_AMT_TMP2;
    IF p_fp_cols_rec.x_gen_incl_open_comm_flag = 'Y' THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE           => P_CALLED_MODE,
                P_MSG                   => 'Before calling pa_fp_commitment_amounts.'||
                                           'get_commitment_amts',
                P_MODULE_NAME           => l_module_name);
        END IF;
        PA_FP_COMMITMENT_AMOUNTS.GET_COMMITMENT_AMTS
                  (P_PROJECT_ID                 => P_PROJECT_ID,
                   P_BUDGET_VERSION_ID          => P_BUDGET_VERSION_ID,
                   P_FP_COLS_REC                => p_fp_cols_rec,
                   PX_GEN_RES_ASG_ID_TAB        => l_gen_res_asg_id_tab,
                   PX_DELETED_RES_ASG_ID_TAB    => l_deleted_res_asg_id_tab,
                   X_RETURN_STATUS              => X_RETURN_STATUS,
                   X_MSG_COUNT                  => X_MSG_COUNT,
                   X_MSG_DATA                   => X_MSG_DATA);
        --dbms_output.put_line('??x_msg_count:'||x_msg_count);
        x_msg_count := 0;
        IF p_pa_debug_mode = 'Y' THEN
             PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE           => P_CALLED_MODE,
                P_MSG                   => 'After calling pa_fp_commitment_amounts.'||
                                           'get_commitment_amts: '||x_return_status,
                P_MODULE_NAME           => l_module_name);
        END IF;
        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    END IF;

    IF p_etc_plan_type_id IS NOT NULL AND
       p_etc_plan_version_id IS NOT NULL THEN

        SELECT plan_class_code
        INTO l_src_plan_class_code
        FROM pa_fin_plan_types_b
        WHERE fin_plan_type_id = P_ETC_PLAN_TYPE_ID;

        SELECT version_type
        INTO l_src_version_type
        FROM pa_budget_versions
        WHERE budget_version_id = P_ETC_PLAN_VERSION_ID;

    END IF;

    -- Bug 4130319: Moved initialization of l_rev_gen_method from below.
    -- Before, it was being set after the call to COPY_ACTUALS for the
    -- Event-based Revenue and Resource Schedule cases.
       l_rev_gen_method := nvl(P_FP_COLS_REC.X_REVENUE_DERIVATION_METHOD,PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(p_project_id)); --Bug 5462471
    --l_rev_gen_method := PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(p_project_id);

    -- Bug 4114589: We call the Copy Actuals API for these two cases here,
    -- and postpone calling it until after CREATE_RES_ASG and UPDATE_RES_ASG
    -- have been called in the remaining two cases (see conditional logic below).
    IF (P_FP_COLS_REC.X_VERSION_TYPE = 'REVENUE' AND  l_rev_gen_method = 'E') OR
       (P_FP_COLS_REC.X_GEN_ETC_SRC_CODE = 'RESOURCE_SCHEDULE') THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE       => P_CALLED_MODE,
                P_MSG               => 'Before calling pa_fp_copy_actuals_pub.copy_actuals',
                P_MODULE_NAME       => l_module_name);
        END IF;
        PA_FP_COPY_ACTUALS_PUB.COPY_ACTUALS
              (P_PROJECT_ID               => P_PROJECT_ID,
               P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
               P_FP_COLS_REC              => P_fp_cols_rec,
               P_END_DATE                 => P_ACTUALS_THRU_DATE,
               P_INIT_MSG_FLAG            => 'N',
               P_COMMIT_FLAG              => 'N',
               X_RETURN_STATUS            => X_RETURN_STATUS,
               X_MSG_COUNT                => X_MSG_COUNT,
               X_MSG_DATA                 => X_MSG_DATA);
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE       => P_CALLED_MODE,
                P_MSG               => 'After calling pa_fp_copy_actuals_pub.copy_actuals:'
                                       ||x_return_status,
                P_MODULE_NAME       => l_module_name);
        END IF;
        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    END IF;

  --dbms_output.put_line('++P_FP_COLS_REC.X_GEN_ETC_SRC_CODE is :' ||P_FP_COLS_REC.X_GEN_ETC_SRC_CODE);
    IF P_FP_COLS_REC.X_VERSION_TYPE = 'REVENUE' AND  l_rev_gen_method = 'E' THEN
        /*Skip both resource_schedule and task_level_sel*/
        l_dummy := 1;
    ELSIF P_FP_COLS_REC.X_GEN_ETC_SRC_CODE = 'RESOURCE_SCHEDULE' THEN
        -- Bug 4222555: When the Target is a Revenue version and the accrual
        -- method is Cost, we need to call the GEN_REV_BDGT_AMT_RES_SCH_WRP API.
        IF p_fp_cols_rec.x_version_type = 'REVENUE' AND l_rev_gen_method = 'C' THEN
            IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                    ( p_called_mode => p_called_mode,
                      p_msg         => 'Before calling
                      pa_fp_gen_budget_amt_pub.gen_rev_bdgt_amt_res_sch_wrp',
                      p_module_name => l_module_name,
                      p_log_level   => 5 );
            END IF;
             --hr_utility.trace('before PA_FP_GEN_BUDGET_AMT_PUB.GEN_REV_BDGT_AMT_RES_SCH_WRP');
            PA_FP_GEN_BUDGET_AMT_PUB.GEN_REV_BDGT_AMT_RES_SCH_WRP
                ( P_PROJECT_ID               => P_PROJECT_ID,
                  P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
                  P_FP_COLS_REC              => P_fp_cols_rec,
                  P_PLAN_CLASS_CODE          => P_fp_cols_rec.x_plan_class_code,
                  P_GEN_SRC_CODE             => P_fp_cols_rec.x_gen_etc_src_code,
                  P_COST_PLAN_TYPE_ID        => P_fp_cols_rec.x_gen_src_plan_type_id,
                  p_COST_VERSION_ID          => l_cost_version_id,
                  P_RETAIN_MANUAL_FLAG       => P_fp_cols_rec.x_gen_ret_manual_line_flag,
                  P_CALLED_MODE              => P_CALLED_MODE,
                  P_INC_CHG_DOC_FLAG         => P_fp_cols_rec.x_gen_incl_change_doc_flag,
                  P_INC_BILL_EVENT_FLAG      => P_fp_cols_rec.x_gen_incl_bill_event_flag,
                  P_INC_OPEN_COMMIT_FLAG     => P_fp_cols_rec.x_gen_incl_open_comm_flag,
                  P_ACTUALS_THRU_DATE        => P_ACTUALS_THRU_DATE,
                  P_CI_ID_TAB                => l_ci_id_tab,
                  PX_GEN_RES_ASG_ID_TAB      => l_gen_res_asg_id_tab,
                  PX_DELETED_RES_ASG_ID_TAB  => l_deleted_res_asg_id_tab,
                  P_COMMIT_FLAG              => 'N',
                  P_INIT_MSG_FLAG            => 'N',
                  X_RETURN_STATUS            => X_RETURN_STATUS,
                  X_MSG_COUNT                => X_MSG_COUNT,
                  X_MSG_DATA                 => X_MSG_DATA );
            IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
            IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                    ( p_called_mode => p_called_mode,
                      p_msg         => 'Status after calling pa_fp_gen_budget_amt_pub.'||
                                       'gen_rev_bdgt_amt_res_sch_wrp:'||x_return_status,
                      p_module_name => l_module_name,
                      p_log_level   => 5 );
            END IF;
        ELSE
            IF p_pa_debug_mode = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                    P_CALLED_MODE       => P_CALLED_MODE,
                    P_MSG               => 'Before calling pa_fp_gen_budget_amt_pub.'||
                                           'generate_budget_amt_res_sch',
                    P_MODULE_NAME       => l_module_name);
            END IF;
            PA_FP_GEN_BUDGET_AMT_PUB.GENERATE_BUDGET_AMT_RES_SCH
                  (P_PROJECT_ID               => P_PROJECT_ID,
                   P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
                   P_FP_COLS_REC              => P_fp_cols_rec,
                   P_PLAN_CLASS_CODE          => P_fp_cols_rec.x_plan_class_code,
                   P_GEN_SRC_CODE             => P_fp_cols_rec.x_gen_etc_src_code,
                   P_COST_PLAN_TYPE_ID        => P_fp_cols_rec.x_gen_src_plan_type_id,
                   p_COST_VERSION_ID          => l_cost_version_id,
                   P_RETAIN_MANUAL_FLAG       => P_fp_cols_rec.x_gen_ret_manual_line_flag,
                   P_CALLED_MODE              => P_CALLED_MODE,
                   P_INC_CHG_DOC_FLAG         => P_fp_cols_rec.x_gen_incl_change_doc_flag,
                   P_INC_BILL_EVENT_FLAG      => P_fp_cols_rec.x_gen_incl_bill_event_flag,
                   P_INC_OPEN_COMMIT_FLAG     => P_fp_cols_rec.x_gen_incl_open_comm_flag,
                   P_ACTUALS_THRU_DATE        => P_ACTUALS_THRU_DATE,
                   P_CI_ID_TAB                => l_ci_id_tab,
                   PX_GEN_RES_ASG_ID_TAB      => l_gen_res_asg_id_tab,
                   PX_DELETED_RES_ASG_ID_TAB  => l_deleted_res_asg_id_tab,
                   P_COMMIT_FLAG              => 'N',
                   P_INIT_MSG_FLAG            => 'N',
                   X_RETURN_STATUS            => X_RETURN_STATUS,
                   X_MSG_COUNT                => X_MSG_COUNT,
                   X_MSG_DATA                 => X_MSG_DATA);
            IF p_pa_debug_mode = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                    P_CALLED_MODE       => P_CALLED_MODE,
                    P_MSG               => 'After calling pa_fp_gen_budget_amt_pub.'||
                                           'generate_budget_amt_res_sch: '||x_return_status,
                    P_MODULE_NAME       => l_module_name);
            END IF;
            IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
        END IF; -- cost-based revenue check
    ELSIF P_FP_COLS_REC.X_VERSION_TYPE = 'REVENUE' AND
          p_etc_plan_type_id IS NOT NULL AND
          l_src_plan_class_code = 'FORECAST' AND
         (l_src_version_type = 'COST' OR l_src_version_type = 'ALL')  THEN

        -- Added as part of fix for Bug 4232094
        l_budget_generation_flow_flag := 'Y';

        /* For revenue fcst generation, source can only be cost and all.
           From revenue version is provented from UI.
           Revenue fcst generation should follow the budget generation logic.*/
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE    => P_CALLED_MODE,
                P_MSG            =>
                'Before calling PA_FP_WP_GEN_BUDGET_AMT_PUB.'||
                                    'GENERATE_WP_BUDGET_AMT',
                P_MODULE_NAME    => l_module_name);
        END IF;
        PA_FP_WP_GEN_BUDGET_AMT_PUB.GENERATE_WP_BUDGET_AMT
           (P_PROJECT_ID               => P_PROJECT_ID,
            P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
            P_PLAN_CLASS_CODE          => 'FORECAST',
            P_GEN_SRC_CODE             => 'FINANCIAL_PLAN',
            P_COST_PLAN_TYPE_ID        => NULL,
            P_COST_VERSION_ID          => NULL,
            P_RETAIN_MANUAL_FLAG       => P_RET_MANUAL_LNS_FLAG,
            P_CALLED_MODE              => P_CALLED_MODE,
            P_INC_CHG_DOC_FLAG         => P_INCL_CHG_DOC_FLAG,
            P_INC_BILL_EVENT_FLAG      => P_INCL_BILL_EVT_FLAG,
            P_INC_OPEN_COMMIT_FLAG     => P_INCL_OPEN_CMT_FLAG,
            --P_CI_ID_TAB
            P_INIT_MSG_FLAG            => 'N',
            P_COMMIT_FLAG              => 'N',
            P_CALLING_CONTEXT          => 'FORECAST_GENERATION',
            P_ETC_PLAN_TYPE_ID         =>  P_ETC_PLAN_TYPE_ID,
            P_ETC_PLAN_VERSION_ID      =>  P_ETC_PLAN_VERSION_ID,
            --P_ETC_PLAN_VERSION_NAME
            P_ACTUALS_THRU_DATE        => P_ACTUALS_THRU_DATE,
            PX_DELETED_RES_ASG_ID_TAB  => lx_deleted_res_asg_id_tab,
            PX_GEN_RES_ASG_ID_TAB      => lx_gen_res_asg_id_tab,
            X_RETURN_STATUS            => X_RETURN_STATUS,
            X_MSG_COUNT                => X_MSG_COUNT,
            X_MSG_DATA                 => X_MSG_DATA );
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE    => P_CALLED_MODE,
                P_MSG            =>
                'After calling PA_FP_WP_GEN_BUDGET_AMT_PUB.'||
                'GENERATE_WP_BUDGET_AMT: '||x_return_status,
                P_MODULE_NAME    => l_module_name);
        END IF;
        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    ELSE
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE       => P_CALLED_MODE,
                P_MSG               => 'Before calling pa_fp_gen_fcst_amt_pub.'||
                                            'gen_fcst_task_level_amt',
                P_MODULE_NAME       => l_module_name);
        END IF;
        PA_FP_GEN_FCST_AMT_PUB.GEN_FCST_TASK_LEVEL_AMT
            (P_PROJECT_ID              => P_PROJECT_ID,
            P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
            P_FP_COLS_REC              => P_FP_COLS_REC,
            P_WP_STRUCTURE_VERSION_ID  => P_WP_STRUCTURE_VERSION_ID,
            P_ETC_FP_PLAN_VERSION_ID   => P_ETC_PLAN_VERSION_ID,
            P_ACTUALS_THRU_DATE        => P_ACTUALS_THRU_DATE,
            P_ACTUALS_FROM_PERIOD      => P_ACTUALS_FROM_PERIOD,
            P_ACTUALS_TO_PERIOD        => P_ACTUALS_TO_PERIOD,
            P_ETC_FROM_PERIOD          => P_ETC_FROM_PERIOD,
            P_ETC_TO_PERIOD            => P_ETC_TO_PERIOD,
            X_RETURN_STATUS            => X_RETURN_STATUS,
            X_MSG_COUNT                => X_MSG_COUNT,
            X_MSG_DATA                 => X_MSG_DATA);

        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE       => P_CALLED_MODE,
                P_MSG               => 'After calling pa_fp_gen_fcst_amt_pub.'||
                                       'gen_fcst_task_level_amt: '||x_return_status,
                P_MODULE_NAME       => l_module_name);
        END IF;
        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    END IF;

    --hr_utility.trace('p_fp_cols_rec.x_gen_incl_open_comm_flag:'||p_fp_cols_rec.x_gen_incl_open_comm_flag);
    /* IF p_pa_debug_mode = 'Y' THEN
         pa_fp_gen_amount_utils.fp_debug
        (p_msg         => 'Value of gen_incl_open_comm_flag: '||p_fp_cols_rec.x_gen_incl_open_comm_flag,
         p_module_name => l_module_name,
         p_log_level   => 5);
    END IF;*/

    /*IF p_pa_debug_mode = 'Y' THEN
         pa_fp_gen_amount_utils.fp_debug
        (p_msg         => 'Value of gen_incl_change_doc_flag: '||p_fp_cols_rec.x_gen_incl_change_doc_flag,
         p_module_name => l_module_name,
         p_log_level   => 5);
    END IF;*/

    IF p_fp_cols_rec.x_gen_incl_open_comm_flag = 'Y' THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE      => P_CALLED_MODE,
                P_MSG              => 'Before calling PA_FP_GEN_COMMITMENT_AMOUNTS.'||
                                      'GEN_COMMITMENT_AMOUNTS',
                P_MODULE_NAME      => l_module_name);
        END IF;
        PA_FP_GEN_COMMITMENT_AMOUNTS.GEN_COMMITMENT_AMOUNTS
            (P_PROJECT_ID                 => P_PROJECT_ID,
             P_BUDGET_VERSION_ID          => P_BUDGET_VERSION_ID,
             P_FP_COLS_REC                => p_fp_cols_rec,
             PX_GEN_RES_ASG_ID_TAB        => l_gen_res_asg_id_tab,
             PX_DELETED_RES_ASG_ID_TAB    => l_deleted_res_asg_id_tab,
             X_RETURN_STATUS              => X_RETURN_STATUS,
             X_MSG_COUNT                  => X_MSG_COUNT,
             X_MSG_DATA                   => X_MSG_DATA);
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE            => P_CALLED_MODE,
                P_MSG                    => 'After calling PA_FP_GEN_COMMITMENT_AMOUNTS.'||
                                            'GEN_COMMITMENT_AMOUNTS: '||x_return_status,
                P_MODULE_NAME            => l_module_name);
        END IF;
        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    END IF;--p_fp_cols_rec.x_gen_incl_open_comm_flag = 'Y'

    --dbms_output.put_line('++Before reven++');
    --dbms_output.put_line('??x_msg_count:'||x_msg_count);
       /* IF p_pa_debug_mode = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Value of version_type: '||p_fp_cols_rec.x_version_type,
             p_module_name => l_module_name,
             p_log_level   => 5);
        END IF;*/
--------------FOR REVENUE: FROM PAFPGAMB.pls------
    IF  (p_fp_cols_rec.x_version_type = 'ALL'
         OR p_fp_cols_rec.x_version_type = 'REVENUE')
         AND l_rev_gen_method = 'C'   THEN

        -- Bug 4232094: When the Target version is Revenue with accrual method
        -- of Cost, time phasing is None, and the code did not go through the
        -- budget generation flow (PAFPWPGB), then we need to call the currency
        -- conversion API.

        -- Bug 4549862: When generating a Cost and Revenue together version
        -- from Staffing Plan with revenue accrual method of COST, the
        -- currency conversion step is performed on the PA_FP_ROLLUP_TMP
        -- table (instead of pa_budget_lines) earlier in the code flow by the
        -- GENERATE_BUDGET_AMT_RES_SCH API so that pc/pfc Commitment amounts
        -- can be honored. We should not call the currency conversion API in
        -- this case.

        IF ( p_fp_cols_rec.x_version_type = 'ALL' AND
             p_fp_cols_rec.x_gen_etc_src_code <> 'RESOURCE_SCHEDULE' ) OR
          (l_budget_generation_flow_flag = 'N' AND
           p_fp_cols_rec.x_version_type = 'REVENUE' AND
           l_rev_gen_method = 'C' AND
           p_fp_cols_rec.x_time_phased_code = 'N') THEN
                --Calling the currency conversion API
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
                 p_calling_module              => 'FORECAST_GENERATION', -- Added for Bug#5395732
                 X_RETURN_STATUS              => X_RETURN_STATUS,
                 X_MSG_COUNT                  => X_MSG_COUNT,
                 X_MSG_DATA                    => X_MSG_DATA);
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

        /* Calling rollup budget version api
           rollup amounts for the version level not required as the
           amounts are derived from budget lines data
        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_called_mode => p_called_mode,
              p_msg         => 'Before calling
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
             (p_called_mode => p_called_mode,
              p_msg         => 'Status after calling
              pa_fp_rollup_pkg.rollup_budget_version: '
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
        END IF;
        IF p_pa_debug_mode = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Value of project_value: '||p_fp_cols_rec.x_project_value,
             p_module_name => l_module_name,
             p_log_level   => 5);
        END IF;
        IF  p_fp_cols_rec.x_project_value IS NULL THEN
            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_FCST_NO_PRJ_VALUE');
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
        the error for project value null chk is handled in
         gen cost based revenue gen API */
        --Calling gen cost based revenue api
        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                (p_called_mode => p_called_mode,
                p_msg         => 'Before calling
                       pa_fp_rev_gen_pub.gen_cost_based_revenue',
                p_module_name => l_module_name,
                p_log_level   => 5);
        END IF;
      --hr_utility.trace('---calling cost based rev gen---');
        PA_FP_REV_GEN_PUB.GEN_COST_BASED_REVENUE
                (P_BUDGET_VERSION_ID          => P_BUDGET_VERSION_ID,
                P_FP_COLS_REC                => p_fp_cols_rec,
                P_ETC_START_DATE             => P_ACTUALS_THRU_DATE + 1,
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
                        pa_fp_rev_gen_pub.gen_cost_based_revenue'
                        ||x_return_status,
                 p_module_name => l_module_name,
                 p_log_level   => 5);
        END IF;
     END IF;

    -- Bug 4592564: Removed Unspent Amounts API call and related logic for
    -- getting the Source Approved Budget version.

     /*Only for ALL or Revenue version, revenue generation method can be set
       and include billing event flag can be chosen. This logic is implemented
       in both here and UI*/
     IF (p_fp_cols_rec.x_version_type = 'ALL'
         OR p_fp_cols_rec.x_version_type = 'REVENUE')
         AND (l_rev_gen_method = 'E'
         OR p_fp_cols_rec.x_gen_incl_bill_event_flag = 'Y') THEN
        --Calling Billing Events API
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
              P_FP_COLS_REC                => p_fp_cols_rec,
              PX_GEN_RES_ASG_ID_TAB        => l_gen_res_asg_id_tab,
              P_ETC_START_DATE             => P_ACTUALS_THRU_DATE + 1,
              PX_DELETED_RES_ASG_ID_TAB    => l_deleted_res_asg_id_tab,
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
                              pa_fp_gen_billing_amounts.gen_billing_amounts: '
                              ||x_return_status,
                 p_module_name => l_module_name,
                 p_log_level   => 5);
        END IF;
    END IF;

    IF p_fp_cols_rec.x_version_type = 'REVENUE' THEN
        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                (p_called_mode => p_called_mode,
                 p_msg         => 'Before calling
                        pa_fp_gen_budget_amt_pub.reset_cost_amounts',
                 p_module_name => l_module_name,
                 p_log_level   => 5);
        END IF;
        --hr_utility.trace('######Calling RESET_COST_AMOUNTS');
        PA_FP_GEN_BUDGET_AMT_PUB.RESET_COST_AMOUNTS
            (P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
             X_RETURN_STATUS      => X_RETURN_STATUS,
             X_MSG_COUNT          => X_MSG_COUNT,
             X_MSG_DATA         => X_MSG_DATA);
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
    --dbms_output.put_line('??x_msg_count:'||x_msg_count);
    --dbms_output.put_line('++Exiting rev part++');
-----------------------------------

    -- Start Bug 8557807.
    -- The change orders are getting lost when forecast is generated as system
    -- deletes all the budget line and regenerates the same but in doing so
    -- the system is  not regenrating the change order changes and hence it
    -- not visible for next include nor its amounts are seen budget.
    IF P_fp_cols_rec.x_gen_ret_manual_line_flag <> 'Y' THEN

      IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                               pa_fp_ci_merge.implement_change_document',
              p_module_name => l_module_name,
              p_log_level   => 5);
      END IF;

      SELECT pfmci.ci_id
      BULK   COLLECT
      INTO   l_ci_id_tbl
      FROM  pa_fp_merged_ctrl_items pfmci
      WHERE pfmci.plan_version_id = P_FP_COLS_REC.X_BUDGET_VERSION_ID
      AND NOT EXISTS ( SELECT 1 FROM pa_fp_merged_ctrl_items pfmci1
                       WHERE pfmci1.plan_version_id = P_FP_COLS_REC.X_GEN_SRC_PLAN_VERSION_ID
                       AND  pfmci.ci_id = pfmci1.ci_id);

      l_budget_version_id_tbl.extend;
      l_budget_version_id_tbl(1) := P_FP_COLS_REC.X_BUDGET_VERSION_ID;

      DELETE
      FROM pa_fp_merged_ctrl_items pfmci
      WHERE pfmci.plan_version_id = P_FP_COLS_REC.X_BUDGET_VERSION_ID
      AND NOT EXISTS ( SELECT 1 FROM pa_fp_merged_ctrl_items pfmci1
                       WHERE pfmci1.plan_version_id = P_FP_COLS_REC.X_GEN_SRC_PLAN_VERSION_ID
                       AND  pfmci.ci_id = pfmci1.ci_id);


    	PA_FP_CI_MERGE.implement_change_document
      (p_context                      =>
       'INCLUDE',
       p_calling_context              =>
       'FORECAST_GENERATION',
       p_ci_id_tbl                    =>
       l_ci_id_tbl,
       p_budget_version_id_tbl        =>
       l_budget_version_id_tbl,
       p_impl_cost_flag_tbl           =>
       l_impl_cost_flag_tbl,
       p_impl_rev_flag_tbl            =>
       l_impl_rev_flag_tbl,
       p_raTxn_rollup_api_call_flag   =>
       'N',
       x_translated_msgs_tbl          =>
       l_translated_msgs_tbl,
       x_translated_err_msg_count     =>
       l_translated_err_msg_count,
       x_translated_err_msg_level_tbl =>
       l_translated_err_msg_level_tbl,
       x_return_status                =>
       x_return_status,
       x_msg_count                    =>
       x_msg_count,
       x_msg_data                     =>
       x_msg_data);


			IF p_pa_debug_mode = 'Y' THEN
			    pa_fp_gen_amount_utils.fp_debug
			     (p_msg => 'Status after calling pa_fp_ci_merge.implement_change_document'
			                      ||x_return_status,
			      p_module_name => l_module_name,
			      p_log_level   => 5);
      END IF;

			IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
			     RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
			END IF;

    END IF;
    -- End Bug 8557807.


    /* calling the change document merge API after calling
       the cost based revenue generation API for bug 3815353   */

    IF p_fp_cols_rec.x_gen_incl_change_doc_flag = 'Y' THEN
      IF p_etc_plan_version_id IS NOT NULL THEN
        SELECT count(*)
        INTO   l_task_count
        FROM   pa_tasks
        WHERE  project_id = p_project_id
        AND    gen_etc_source_code = 'FINANCIAL_PLAN'
        AND    gen_etc_source_code IS NOT NULL;

        IF l_task_count > 0 THEN
             IF p_pa_debug_mode = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_called_mode => p_called_mode,
                p_msg         => 'Before calling
                            pa_fp_ci_merge.copy_merged_ctrl_items',
                p_module_name => l_module_name,
                p_log_level   => 5);
             END IF;
             PA_FP_CI_MERGE.copy_merged_ctrl_items
             (  p_project_id        => p_project_id
               ,p_source_version_id => p_etc_plan_version_id
               ,p_target_version_id => p_fp_cols_rec.x_budget_version_id
               ,p_calling_context   =>'GENERATION' --Bug 4247703
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
       END IF;
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE           => P_CALLED_MODE,
                P_MSG                   => 'Before calling pa_fp_gen_pub.'||
                                           'include_change_document_wrp',
                P_MODULE_NAME           => l_module_name);
            END IF;
        --dbms_output.put_line('++Before chg doc++');
        PA_FP_GEN_PUB.INCLUDE_CHANGE_DOCUMENT_WRP
                (P_FP_COLS_REC   => p_fp_cols_rec,
                X_RETURN_STATUS => X_RETURN_STATUS,
                X_MSG_COUNT     => X_MSG_COUNT,
                X_MSG_DATA      => X_MSG_DATA);
        --dbms_output.put_line('++After chg doc is: '||x_return_status);
        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE           => P_CALLED_MODE,
                P_MSG                   => 'After calling pa_fp_gen_pub.'||
                                           'include_change_document_wrp:'||x_return_status,
                P_MODULE_NAME           => l_module_name);
        END IF;

    END IF;

    -- Bug 4247669: We should not update the budget lines after calling
    -- the MAINTAIN_BUDGET_VERSION API because it calls the PJI create
    -- and delete APIs. Hence, moved UPDATE_TOTAL_PLAN_AMTS call before
    -- the MAINTAIN_BUDGET_VERSION call.

    /*Due to the request from workplan team, this part gets handled in
      PA_FP_MAINTAIN_ACTUAL_PUB.MAINTAIN_ACTUAL_AMT_RA. Hence commented
      out this part */

    -- Bug 4232094: Uncommented the UPDATE_TOTAL_PLAN_AMTS API call to
    -- address Issue 2 of the bug concerning inccorect ETC amounts being
    -- displayed. In addition, added IF condition so that the API call
    -- happens only when the Target is None timephased.

    -- Bug 4292083: Commenting the UPDATE_TOTAL_PLAN_AMTS API call again
    -- in favor of a different approach to updating the plan amounts. See
    -- bug updates for more details.

    /* Begin Comment for Bug 4292083 ************************************************

    IF p_fp_cols_rec.x_time_phased_code = 'N' THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                    P_CALLED_MODE           => P_CALLED_MODE,
                    P_MSG                   => 'Before calling pa_fp_gen_fcst_amt_pub.'||
                                               'update_total_plan_amts',
                    P_MODULE_NAME           => l_module_name);
        END IF;
        PA_FP_GEN_FCST_AMT_PVT.UPDATE_TOTAL_PLAN_AMTS
              (P_BUDGET_VERSION_ID   => P_BUDGET_VERSION_ID,
               X_RETURN_STATUS       => X_RETURN_STATUS,
               X_MSG_COUNT           => X_MSG_COUNT,
               X_MSG_DATA            => X_MSG_DATA);
        --dbms_output.put_line('Status of update total plan amts api: '||X_RETURN_STATUS);
        --dbms_output.put_line('??x_msg_count:'||x_msg_count);
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                    P_CALLED_MODE           => P_CALLED_MODE,
                    P_MSG                   => 'AFTER CALLING PA_FP_GEN_FCST_AMT_PUB.'||
                                               'UPDATE_TOTAL_PLAN_AMTS:'||x_return_status,
                    P_MODULE_NAME           => l_module_name);
        END IF;
        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    END IF;

    ** End Comment for Bug 4292083 **************************************************/

    -- Call API to update pa_budget_lines.other_rejection_code
    -- with any ETC revenue amount calculation errors.
    -- See bug 5203622 for more details.
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_MSG                   => 'Before calling PA_FP_GEN_FCST_AMT_PUB.' ||
                                       'UPD_REV_CALCULATION_ERR',
            P_CALLED_MODE           => p_called_mode,
            P_MODULE_NAME           => l_module_name);
    END IF;
    PA_FP_GEN_FCST_AMT_PUB.UPD_REV_CALCULATION_ERR
          (P_PROJECT_ID              => p_project_id,
           P_BUDGET_VERSION_ID       => p_budget_version_id,
           P_FP_COLS_REC             => p_fp_cols_rec,
           P_ETC_START_DATE          => p_actuals_thru_date + 1,
           P_CALLED_MODE             => p_called_mode,
           X_RETURN_STATUS           => X_RETURN_STATUS,
           X_MSG_COUNT               => X_MSG_COUNT,
           X_MSG_DATA                => X_MSG_DATA);
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_MSG                   => 'After calling PA_FP_GEN_FCST_AMT_PUB.' ||
                                       'UPD_REV_CALCULATION_ERR: '||x_return_status,
            P_CALLED_MODE           => p_called_mode,
            P_MODULE_NAME           => l_module_name);
    END IF;

--Start Bug 5726785

 	     PA_FP_GEN_FCST_AMT_PUB1.call_clnt_extn_and_update_bl
 	         (p_project_id       =>  p_project_id
 	         ,p_budget_version_id   =>  p_budget_version_id
 	         ,x_call_maintain_data_api => l_call_maintain_data_api
 	         ,x_return_status    => x_return_status
 	         ,x_msg_count        => x_msg_count
 	         ,x_msg_data         => x_msg_data);

 	         IF p_pa_debug_mode = 'Y' THEN
 	             PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
 	                 P_CALLED_MODE       => P_CALLED_MODE,
 	                 P_MSG               => 'After calling pa_fp_gen_fcst_amt_pub.'||
 	                                        'call_clnt_extn_and_update_bl '||x_return_status,
 	                 P_MODULE_NAME       => l_module_name);
 	         END IF;
 	         IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
 	             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
 	         END IF;



 	 --End Bug 5726785


    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE           => P_CALLED_MODE,
                P_MSG                   => 'Before calling PA_FP_GEN_FCST_AMT_PUB1.'||
                                            'MAINTAIN_BUDGET_VERSION',
                P_MODULE_NAME           => l_module_name);
    END IF;
    --dbms_output.put_line('++Before pub1.maintain_bv++');
    PA_FP_GEN_FCST_AMT_PUB1.MAINTAIN_BUDGET_VERSION
       (P_PROJECT_ID            => P_PROJECT_ID,
        P_BUDGET_VERSION_ID     => P_BUDGET_VERSION_ID,
        P_ETC_START_DATE        => P_ACTUALS_THRU_DATE + 1,
	P_CALL_MAINTAIN_DATA_API => L_CALL_MAINTAIN_DATA_API,
        X_RETURN_STATUS         => x_return_status,
        X_MSG_COUNT            => x_msg_count,
        X_MSG_DATA             => x_msg_data );
    --dbms_output.put_line('++AFter pub1.maintain_bv++:'||x_return_status);
    --dbms_output.put_line('??x_msg_count:'||x_msg_count);
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE           => P_CALLED_MODE,
                P_MSG                   => 'After calling PA_FP_GEN_FCST_AMT_PUB1.'||
                                            'MAINTAIN_BUDGET_VERSION: '||x_return_status,
                P_MODULE_NAME           => l_module_name);
    END IF;
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF P_COMMIT_FLAG = 'Y' THEN
        COMMIT;
    END IF;
    IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.Reset_Curr_Function;
    END IF;
    --dbms_output.put_line('??END: x_msg_count:'||x_msg_count);
    /*temp */
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        x_msg_count := 0;
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
                 x_msg_data  := l_data;
                 x_msg_count := l_msg_count;
          ELSE
                x_msg_count := l_msg_count;
          END IF;
          ROLLBACK;

          x_return_status := FND_API.G_RET_STS_ERROR;
          IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE           => P_CALLED_MODE,
                P_MSG                   => 'Invalid Arguments Passed',
                P_MODULE_NAME           => l_module_name);
              PA_DEBUG.Reset_Curr_Function;
          END IF;
          RAISE;

      WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_data      := SUBSTR(SQLERRM,1,240);
           FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_FCST_AMT_PUB'
              ,p_procedure_name => 'GENERATE_FCST_AMT_WRP');
           IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE           => P_CALLED_MODE,
                P_MSG                   => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                P_MODULE_NAME           => l_module_name);
                PA_DEBUG.Reset_Curr_Function;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GENERATE_FCST_AMT_WRP;

PROCEDURE GEN_FCST_TASK_LEVEL_AMT
          (P_PROJECT_ID              IN PA_PROJECTS_ALL.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID       IN PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC             IN PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_WP_STRUCTURE_VERSION_ID IN PA_PROJ_ELEM_VER_STRUCTURE.ELEMENT_VERSION_ID%TYPE,
           P_ETC_FP_PLAN_VERSION_ID  IN PA_PROJ_FP_OPTIONS.FIN_PLAN_VERSION_ID%TYPE,
           P_ACTUALS_THRU_DATE       IN PA_PERIODS_ALL.END_DATE%TYPE,
           P_ACTUALS_FROM_PERIOD     IN VARCHAR2,
           P_ACTUALS_TO_PERIOD       IN VARCHAR2,
           P_ETC_FROM_PERIOD         IN VARCHAR2,
           P_ETC_TO_PERIOD           IN VARCHAR2,
           X_RETURN_STATUS           OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY NUMBER,
           X_MSG_DATA                OUT  NOCOPY VARCHAR2) IS

l_module_name         VARCHAR2(200) := 'pa.plsql.pa_fp_gen_fcst_amt_pub.gen_fcst_task_level_amt';

l_latest_published_fwbs_id      NUMBER;
l_proj_struc_sharing_code       VARCHAR2(30);

l_wp_version_id                 NUMBER;
l_fp_cols_rec_target            PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
l_fp_cols_rec_wp                PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
l_fp_cols_rec_fp                PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
l_fp_cols_rec_approved          PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
l_resource_list_id      NUMBER;
l_struct_ver_id         NUMBER;
l_calendar_type         VARCHAR2(3);
l_record_type           VARCHAR2(10);

l_calling_context       VARCHAR2(30);

CURSOR  traverse_tasks_cur(c_gen_etc_src_code PA_PROJ_FP_OPTIONS.GEN_COST_SRC_CODE%TYPE) IS
SELECT  task_id,
        DECODE(c_gen_etc_src_code,
               NULL,NVL(gen_etc_source_code,'NONE'),
               c_gen_etc_src_code)
FROM    pa_tasks t
WHERE   project_id = P_PROJECT_ID;

CURSOR  traverse_top_tasks_cur(c_gen_etc_src_code PA_PROJ_FP_OPTIONS.GEN_COST_SRC_CODE%TYPE) IS
        SELECT  task_id,
        DECODE(c_gen_etc_src_code,
               NULL,NVL(gen_etc_source_code,'NONE'),
               c_gen_etc_src_code)
        FROM    pa_tasks t
        WHERE   project_id = P_PROJECT_ID and
                parent_task_id is null;

l_temp_top_task_id              PA_TASKS.TOP_TASK_ID%TYPE;
CURSOR  traverse_child_tasks_cur IS
        SELECT  task_id
        FROM    pa_tasks t
        WHERE   project_id = P_PROJECT_ID and
                top_task_id = l_temp_top_task_id and
                task_id <> top_task_id; -- don't want to retrieve the current node

l_top_task_id_tab               PA_PLSQL_DATATYPES.NumTabTyp; -- ETC Enhancements 10/2004
l_child_task_id_tab             PA_PLSQL_DATATYPES.NumTabTyp; -- ETC Enhancements 10/2004
l_top_gen_etc_src_code_tab      pa_plsql_datatypes.Char30TabTyp; -- ETC Enhancements 10/2004
l_task_id_tab                   PA_PLSQL_DATATYPES.NumTabTyp;
l_gen_etc_source_code_tab       pa_plsql_datatypes.Char30TabTyp;
l_curr_task_id                  PA_TASKS.TASK_ID%TYPE;
l_curr_etc_source               PA_TASKS.GEN_ETC_SOURCE_CODE%TYPE;
l_curr_etc_ver_id               NUMBER;
l_curr_etc_method_code          VARCHAR2(30);
l_curr_src_ra_id                NUMBER;
l_curr_tgt_ra_id                NUMBER;
l_curr_rlm_id                   NUMBER;
l_txn_amt_rec                   PA_FP_GEN_FCST_AMT_PUB.TXN_AMT_REC_TYP;
l_work_qty_cnt                  NUMBER:= 0;

/* Indices for ETC method PL/SQL tables */
l_rb_index                     BINARY_INTEGER;
l_bc_index                     BINARY_INTEGER;
l_ev_index                     BINARY_INTEGER;

/* PL/SQL tables for Remaining Budget - Performance Bug 4194849 */
l_rb_src_ra_id_tab             PA_PLSQL_DATATYPES.IdTabTyp;
l_rb_tgt_ra_id_tab             PA_PLSQL_DATATYPES.IdTabTyp;
l_rb_task_id_tab               PA_PLSQL_DATATYPES.IdTabTyp;
l_rb_rlm_id_tab                PA_PLSQL_DATATYPES.IdTabTyp;
l_rb_etc_source_tab            PA_PLSQL_DATATYPES.Char30TabTyp;

/* PL/SQL tables for Budget To Complete - Performance Bug 4194849 */
l_bc_src_ra_id_tab            PA_PLSQL_DATATYPES.IdTabTyp;
l_bc_tgt_ra_id_tab            PA_PLSQL_DATATYPES.IdTabTyp;
l_bc_task_id_tab              PA_PLSQL_DATATYPES.IdTabTyp;
l_bc_rlm_id_tab               PA_PLSQL_DATATYPES.IdTabTyp;
l_bc_etc_source_tab           PA_PLSQL_DATATYPES.Char30TabTyp;

/* PL/SQL tables for Earned Value - Performance Bug 4194849 */
l_ev_src_ra_id_tab             PA_PLSQL_DATATYPES.IdTabTyp;
l_ev_tgt_ra_id_tab             PA_PLSQL_DATATYPES.IdTabTyp;
l_ev_task_id_tab               PA_PLSQL_DATATYPES.IdTabTyp;
l_ev_rlm_id_tab                PA_PLSQL_DATATYPES.IdTabTyp;
l_ev_etc_source_tab            PA_PLSQL_DATATYPES.Char30TabTyp;

-- Bug 4114589: When populating temporary table data, we need to process
-- tasks with source of Average of Actuals separately after copying actuals.
l_avg_actuals_task_id_tab       PA_PLSQL_DATATYPES.IdTabTyp;

-- Bug 4089850: Modified traverse_tasks_rlm_cur so that we no longer
-- join with pa_tasks to get the ETC source code. Instead, we return
-- the transaction_source_code from tmp1.

CURSOR  traverse_tasks_rlm_cur (c_gen_etc_source_code VARCHAR2) IS
SELECT  tmp1.task_id,
        NVL(c_gen_etc_source_code, NVL(tmp1.transaction_source_code,'NONE')),
        tmp1.resource_assignment_id,
        tmp1.target_res_asg_id,
        tmp1.resource_list_member_id,
        tmp1.etc_method_code
FROM    PA_FP_CALC_AMT_TMP1 tmp1;

l_task_id_tab2                  PA_PLSQL_DATATYPES.NumTabTyp;
l_gen_etc_source_code_tab2      pa_plsql_datatypes.Char30TabTyp;
l_src_ra_id_tab2                PA_PLSQL_DATATYPES.NumTabTyp;
l_tgt_ra_id_tab2                PA_PLSQL_DATATYPES.NumTabTyp;
l_rlm_id_tab2                   PA_PLSQL_DATATYPES.NumTabTyp;
l_etc_method_tab2               pa_plsql_datatypes.Char30TabTyp;

-- gboomina Bug 8318932 AAI Enhancement - Start
CURSOR get_copy_etc_from_plan_csr
IS
SELECT COPY_ETC_FROM_PLAN_FLAG
FROM PA_PROJ_FP_OPTIONS
WHERE FIN_PLAN_VERSION_ID = P_BUDGET_VERSION_ID;

l_copy_etc_from_plan_flag PA_PROJ_FP_OPTIONS.COPY_ETC_FROM_PLAN_FLAG%TYPE;
-- gboomina Bug 8318932 AAI Enhancement - End

l_gen_etc_source_code_override  VARCHAR2(30);

--in param for PPA_FP_MAP_BV_PUB.GEN_MAP_BV_TO_TARGET_RL to
--get baselined cost.
l_approved_fp_version_id        pa_proj_fp_options.fin_plan_version_id%TYPE;
l_approved_fp_options_id        pa_proj_fp_options.proj_fp_options_id%TYPE;

l_fin_plan_type_id              pa_proj_fp_options.fin_plan_type_id%TYPE;
l_version_type                  VARCHAR2(15);

l_plan_level                    VARCHAR2(15);

l_amt_dtls_tbl                  pa_fp_maintain_actual_pub.l_amt_dtls_tbl_typ;

/*For None Time Phase*/
l_start_date                DATE;
l_end_date                  DATE;

--local PL/SQL table used for calling Calculate API
l_refresh_rates_flag          VARCHAR2(1);
l_refresh_conv_rates_flag     VARCHAR2(1);
l_spread_required_flag        VARCHAR2(1);
l_conv_rates_required_flag    VARCHAR2(1);
l_raTxn_rollup_api_call_flag  VARCHAR2(1); -- Added for IPM new entity ER

l_source_context              VARCHAR2(30) :='RESOURCE_ASSIGNMENT';
l_cal_ra_id_tab               SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_cal_src_ra_id_tab           SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_cal_rate_based_flag_tab     SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
l_cal_rlm_id_tab              SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_cal_task_id_tab             SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_cal_etc_method_code_tab     SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
l_cal_rcost_rate_override_tab SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_cal_bcost_rate_override_tab SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_cal_bill_rate_override_tab  SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_delete_budget_lines_tab     SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
l_spread_amts_flag_tab        SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
l_cal_txn_currency_code_tab   SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
l_txn_currency_override_tab   SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
l_cal_etc_qty_tab             SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_addl_qty_tab                SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_cal_etc_raw_cost_tab        SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_addl_raw_cost_tab           SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_cal_etc_burdened_cost_tab   SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_addl_burdened_cost_tab      SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_cal_etc_revenue_tab         SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_addl_revenue_tab            SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_raw_cost_rate_tab           SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_b_cost_rate_tab             SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_bill_rate_tab               SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_line_start_date_tab         SYSTEM.pa_date_tbl_type:=SYSTEM.pa_date_tbl_type();
l_line_end_date_tab           SYSTEM.pa_date_tbl_type:=SYSTEM.pa_date_tbl_type();
l_input_period_rates_tbl      PA_FP_FCST_GEN_CLIENT_EXT.l_pds_rate_dtls_tab;
l_period_rates_tbl            PA_FP_FCST_GEN_CLIENT_EXT.l_pds_rate_dtls_tab;
l_cal_unit_of_measure_tab     SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();

L_RES_ASG_UOM_UPDATE_TAB        PA_PLSQL_DATATYPES.IdTabTyp;

l_target_class_rlm_id           NUMBER;
l_rev_gen_method                VARCHAR2(10);

l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000);
l_data                          VARCHAR2(2000);
l_msg_index_out                 NUMBER:=0;

l_count_tmp                     NUMBER;
l_test                          NUMBER;
p_called_mode                   varchar2(20) := 'SELF_SERVICE';
l_dummy                         NUMBER;
l_date date;
l_count number;
l_task_index                    NUMBER; -- used for populating task pl/sql tables

l_fcst_etc_qty NUMBER;
l_fcst_etc_raw_cost NUMBER;
l_fcst_etc_burdened_cost NUMBER;
l_fcst_etc_revenue NUMBER;
l_init_qty NUMBER;
l_init_raw_cost NUMBER;
l_init_burdened_cost NUMBER;
l_init_revenue NUMBER;

l_fp_cols_rec_src               PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
/* Bug 4369741: Replaced l_planning_options_flag with 2 separate
 * planning options flags for WP and FP later in the declaration. */
--l_planning_options_flag       VARCHAR2(1);
l_ra_txn_source_code            PA_RESOURCE_ASSIGNMENTS.TRANSACTION_SOURCE_CODE%TYPE;
l_bl_count                      NUMBER;

l_cnt                           NUMBER := 1;
l_cal_ra_id_tab_tmp             SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_cal_txn_curr_code_tab_tmp     SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
l_cal_rate_based_flag_tab_tmp   SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
l_cal_rlm_id_tab_tmp            SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_cal_task_id_tab_tmp           SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_cal_unit_of_measure_tab_tmp   SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
l_cal_etc_method_code_tab_tmp   SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
l_cal_etc_qty_tab_tmp           SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_cal_etc_raw_cost_tab_tmp      SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_cal_etc_brdn_cost_tab_tmp     SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_cal_etc_revenue_tab_tmp       SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();

l_fcst_gen_src_code             PA_PROJ_FP_OPTIONS.GEN_COST_SRC_CODE%TYPE;

l_etc_start_date               DATE;

/* Bug 3968748: Variables for populating PA_FP_GEN_RATE_TMP */
l_ext_period_name_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
l_ext_raw_cost_rate_tab        PA_PLSQL_DATATYPES.NumTabTyp;
l_ext_burdened_cost_rate_tab   PA_PLSQL_DATATYPES.NumTabTyp;
l_ext_revenue_bill_rate_tab    PA_PLSQL_DATATYPES.NumTabTyp;

l_entered_flag                 VARCHAR2(1) := 'N';
l_proceed_flag                 VARCHAR2(1) := 'Y';

-- Bug 4346172: l_use_src_rates_flag will be 'Y' when the src/tgt planning
-- options match, and when the source ETC method is not EARNED_VALUE.
l_use_src_rates_flag           VARCHAR2(1);

/* Variables Added for ER 4376722 */
l_billable_flag_tab            SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
l_billable_flag_tab_tmp        SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
l_cal_src_ra_id_tab_tmp        SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();

-- This index is used in billability logic to track the running index of the _tmp tables
l_tmp_index                    NUMBER;

/* Variables Added for Bug 4369741 */
l_wp_planning_options_flag      VARCHAR2(1);
l_fp_planning_options_flag      VARCHAR2(1);

l_gen_etc_src_code_tab_tmp      SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
l_gen_etc_src_code_tab          SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();

-- Bug 4346172: As part of the fix, added join on pa_fp_calc_amt_tmp1
-- to get the correct source ETC method code.
-- As a result of further testing, discovered that the original fix
-- introduced a duplicate resource error when Commitments are included.
-- PROBLEM:
-- Normally, there should be 1 record per target_res_asg_id in the
-- PA_FP_CALC_AMT_TMP1 table. However, when Commitments are included,
-- extra PA_FP_CALC_AMT_TMP1 records are added for commitment records.
-- As a result, the query returned 2 records for target resources with
-- commitments and ETC.
-- SOLUTION:
-- Ignore records in the PA_FP_CALC_AMT_TMP1 table with transaction
-- source code of 'OPEN_COMMITMENTS'. This will ensure that the query
-- retrieves at most 1 record per target_res_asg_id. Note that we do
-- not need to worry about the scenario when there is a commitment
-- record in the temp table but no ETC record, since the purpose of
-- this query is to get ETC amounts (and Commitments are generated
-- later by a separate API).

-- ER 4376722: To carry out the Task Billability logic, we need to
-- modify the queries to fetch the task billable_flag for each target
-- resource. Since ra.task_id can be NULL or 0, we take the outer
-- join: NVL(ra.task_id,0) = ta.task_id (+). By default, tasks are
-- billable, so we SELECT NVL(ta.billable_flag,'Y').

-- Bug 4571025: To avoid TMP2 records matching multiple TMP1 records,
-- added the following additional WHERE clause join condition to ETC
-- amount cursors (etc_amts_cur_wp_opt_same, etc_amts_cur_fp_opt_same,
-- etc_amts_cur_wp_fp_opt_diff, and etc_amts_cur_wp_fp_opt_same):
--   AND tmp_ra.resource_assignment_id = tmp.resource_assignment_id

/* Bug 4369741: Added cursor etc_amts_cur_wp_fp_opt_same to be used in
 * the following scenarios:
 * 1. Target ETC generation source = 'WORKPLAN_RESOURCES'
 *    l_wp_planning_options_flag = Y
 * 2. Target ETC generation source = 'FINANCIAL_PLAN'
 *    l_fp_planning_options_flag = Y
 * 3. Target ETC generation source = 'TASK_LEVEL_SEL'
 *    l_wp_planning_options_flag = Y
 *    l_fp_planning_options_flag = Y
 * When the ETC generation source is Workplan or Financial Plan,
 * 'WORKPLAN_RESOURCES' or 'FINANCIAL_PLAN' should be passed for the
 * c_gen_etc_source_code cursor parameter, respectively.
 * When the ETC generation source is Task Level Selection, the
 * c_gen_etc_source_code cursor parameter should be NULL so that the
 * cursor picks up each task's generation source. */

CURSOR etc_amts_cur_wp_fp_opt_same
    (c_gen_etc_source_code VARCHAR2 DEFAULT NULL) IS
SELECT /*+ INDEX(tmp,PA_FP_CALC_AMT_TMP2_N1)
           INDEX(tmp_ra,PA_FP_CALC_AMT_TMP1_N1) */
     tmp.RESOURCE_ASSIGNMENT_ID,
     tmp.TARGET_RES_ASG_ID,
     tmp.ETC_CURRENCY_CODE,
     ra.rate_based_flag,
     ra.resource_list_member_id,
     ra.task_id,
     ra.unit_of_measure,
     tmp_ra.etc_method_code,
     SUM(tmp.ETC_PLAN_QUANTITY),
     SUM(tmp.ETC_TXN_RAW_COST),
     SUM(tmp.ETC_TXN_BURDENED_COST),
     SUM(tmp.ETC_TXN_REVENUE),
     NVL(ta.billable_flag,'Y'),                       /* Added for ER 4376722 */
     nvl(c_gen_etc_source_code,                       /* Added for Bug 4369741 */
         nvl(tmp_ra.transaction_source_code, 'NONE'))
FROM PA_FP_CALC_AMT_TMP1 tmp_ra,
     PA_FP_CALC_AMT_TMP2 tmp,
     PA_RESOURCE_ASSIGNMENTS ra,
     pa_tasks ta                                      /* Added for ER 4376722 */
WHERE tmp.target_res_asg_id = ra.resource_assignment_id
      AND tmp.TRANSACTION_SOURCE_CODE = 'ETC'
      AND tmp_ra.target_res_asg_id = tmp.target_res_asg_id
      AND tmp_ra.transaction_source_code <> 'OPEN_COMMITMENTS' /* Bug 4346172 */
      and NVL(ra.task_id,0) = ta.task_id (+)          /* Added for ER 4376722 */
      --and ta.project_id = P_PROJECT_ID              /* Added for ER 4376722 */
      AND ra.budget_version_id = P_BUDGET_VERSION_ID  /* Added for Bug 4369741 Perf */
      AND ra.project_id = P_PROJECT_ID                /* Added for Bug 4369741 Perf */
      AND tmp_ra.resource_assignment_id = tmp.resource_assignment_id /* Added for Bug 4571025 */
GROUP BY tmp.RESOURCE_ASSIGNMENT_ID,
         tmp.TARGET_RES_ASG_ID,
         tmp.ETC_CURRENCY_CODE,
         ra.rate_based_flag,
         ra.resource_list_member_id,
         ra.task_id,
         ra.unit_of_measure,
         tmp_ra.etc_method_code,
         NVL(ta.billable_flag,'Y'),                  /* Added for ER 4376722 */
         nvl(c_gen_etc_source_code,                  /* Added for Bug 4369741 */
             nvl(tmp_ra.transaction_source_code, 'NONE'));

-- 5/10/05 : When planning options do not match, we potentially
-- have many source resources mapping to each target resource. As
-- such, we cannot determine a single source ETC method. Thus,
-- replaced ra.etc_method_code with NULL in the SELECT clause below.

/* Bug 4369741: Added cursor etc_amts_cur_wp_fp_opt_diff to be used in
 * the following scenarios:
 * 1. Target ETC generation source = 'WORKPLAN_RESOURCES'
 *    l_wp_planning_options_flag = N
 * 2. Target ETC generation source = 'FINANCIAL_PLAN'
 *    l_fp_planning_options_flag = N
 * 3. Target ETC generation source = 'TASK_LEVEL_SEL'
 *    l_wp_planning_options_flag = N
 *    l_fp_planning_options_flag = N
 * When the ETC generation source is Workplan or Financial Plan,
 * 'WORKPLAN_RESOURCES' or 'FINANCIAL_PLAN' should be passed for the
 * c_gen_etc_source_code cursor parameter, respectively.
 * When the ETC generation source is Task Level Selection, the
 * c_gen_etc_source_code cursor parameter should be NULL so that the
 * cursor picks up each task's generation source. */

CURSOR etc_amts_cur_wp_fp_opt_diff
    (c_gen_etc_source_code VARCHAR2 DEFAULT NULL) IS
SELECT /*+ INDEX(tmp,PA_FP_CALC_AMT_TMP2_N1)
           INDEX(tmp_ra,PA_FP_CALC_AMT_TMP1_N1) */
     sum(1*null),
     tmp.TARGET_RES_ASG_ID,
     tmp.ETC_CURRENCY_CODE,
     ra.rate_based_flag,
     ra.resource_list_member_id,
     ra.task_id,
     ra.unit_of_measure,
     null, --ra.etc_method_code,
     SUM(tmp.ETC_PLAN_QUANTITY),
     SUM(tmp.ETC_TXN_RAW_COST),
     SUM(tmp.ETC_TXN_BURDENED_COST),
     SUM(tmp.ETC_TXN_REVENUE),
     NVL(ta.billable_flag,'Y'),                     /* Added for ER 4376722 */
     nvl(c_gen_etc_source_code,                     /* Added for Bug 4369741 */
         nvl(tmp_ra.transaction_source_code, 'NONE'))
FROM PA_FP_CALC_AMT_TMP1 tmp_ra,                    /* Added for Bug 4369741 */
   PA_FP_CALC_AMT_TMP2 tmp,
   PA_RESOURCE_ASSIGNMENTS ra,
   pa_tasks ta                                      /* Added for ER 4376722 */
WHERE tmp.target_res_asg_id = ra.resource_assignment_id
    AND tmp.TRANSACTION_SOURCE_CODE = 'ETC'
    and NVL(ra.task_id,0) = ta.task_id (+)          /* Added for ER 4376722 */
    --and ta.project_id = P_PROJECT_ID              /* Added for ER 4376722 */
    AND tmp_ra.target_res_asg_id = tmp.target_res_asg_id     /* Added for Bug 4369741 */
    AND tmp_ra.transaction_source_code <> 'OPEN_COMMITMENTS' /* Added for Bug 4369741 */
    AND ra.budget_version_id = P_BUDGET_VERSION_ID  /* Added for Bug 4369741 Perf */
    AND ra.project_id = P_PROJECT_ID                /* Added for Bug 4369741 Perf */
    AND tmp_ra.resource_assignment_id = tmp.resource_assignment_id /* Added for Bug 4571025 */
GROUP BY
tmp.TARGET_RES_ASG_ID,
       tmp.ETC_CURRENCY_CODE,
       ra.rate_based_flag,
       ra.resource_list_member_id,
       ra.task_id,
       ra.unit_of_measure,
       null, --ra.etc_method_code,
       NVL(ta.billable_flag,'Y'),                   /* Added for ER 4376722 */
       nvl(c_gen_etc_source_code,                   /* Added for Bug 4369741 */
           nvl(tmp_ra.transaction_source_code, 'NONE'));

/* Bug 4369741: Added cursor etc_amts_cur_wp_opt_same to be used in
 * the following scenario:
 * 1. Target ETC generation source = 'TASK_LEVEL_SEL'
 *    l_wp_planning_options_flag = Y
 *    l_fp_planning_options_flag = N
 * This cursor's SELECT statement uses the etc_amts_cur_wp_fp_opt_same
 * cursor's SELECT statement for resources with Workplan source UNION
 * ALL the etc_amts_cur_wp_fp_opt_diff cursor's SELECT statement for
 * resources with non-Workplan source. */

CURSOR etc_amts_cur_wp_opt_same IS
SELECT /*+ INDEX(tmp,PA_FP_CALC_AMT_TMP2_N1)
           INDEX(tmp_ra,PA_FP_CALC_AMT_TMP1_N1) */
     tmp.RESOURCE_ASSIGNMENT_ID,
     tmp.TARGET_RES_ASG_ID,
     tmp.ETC_CURRENCY_CODE,
     ra.rate_based_flag,
     ra.resource_list_member_id,
     ra.task_id,
     ra.unit_of_measure,
     tmp_ra.etc_method_code,
     SUM(tmp.ETC_PLAN_QUANTITY),
     SUM(tmp.ETC_TXN_RAW_COST),
     SUM(tmp.ETC_TXN_BURDENED_COST),
     SUM(tmp.ETC_TXN_REVENUE),
     NVL(ta.billable_flag,'Y'),                       /* Added for ER 4376722 */
     tmp_ra.transaction_source_code                   /* Added for Bug 4369741 */
FROM PA_FP_CALC_AMT_TMP1 tmp_ra,
     PA_FP_CALC_AMT_TMP2 tmp,
     PA_RESOURCE_ASSIGNMENTS ra,
     pa_tasks ta                                      /* Added for ER 4376722 */
WHERE tmp.target_res_asg_id = ra.resource_assignment_id
      AND tmp.TRANSACTION_SOURCE_CODE = 'ETC'
      AND tmp_ra.target_res_asg_id = tmp.target_res_asg_id
      AND tmp_ra.transaction_source_code = 'WORKPLAN_RESOURCES' /* Added for Bug 4369741 */
      and NVL(ra.task_id,0) = ta.task_id (+)          /* Added for ER 4376722 */
      --and ta.project_id = P_PROJECT_ID              /* Added for ER 4376722 */
      AND ra.budget_version_id = P_BUDGET_VERSION_ID  /* Added for Bug 4369741 Perf */
      AND ra.project_id = P_PROJECT_ID                /* Added for Bug 4369741 Perf */
      AND tmp_ra.resource_assignment_id = tmp.resource_assignment_id /* Added for Bug 4571025 */
GROUP BY tmp.RESOURCE_ASSIGNMENT_ID,
         tmp.TARGET_RES_ASG_ID,
         tmp.ETC_CURRENCY_CODE,
         ra.rate_based_flag,
         ra.resource_list_member_id,
         ra.task_id,
         ra.unit_of_measure,
         tmp_ra.etc_method_code,
         NVL(ta.billable_flag,'Y'),                  /* Added for ER 4376722 */
         tmp_ra.transaction_source_code              /* Added for Bug 4369741 */
UNION ALL
SELECT /*+ INDEX(tmp,PA_FP_CALC_AMT_TMP2_N1)
           INDEX(tmp_ra,PA_FP_CALC_AMT_TMP1_N1) */
     sum(1*null),
     tmp.TARGET_RES_ASG_ID,
     tmp.ETC_CURRENCY_CODE,
     ra.rate_based_flag,
     ra.resource_list_member_id,
     ra.task_id,
     ra.unit_of_measure,
     null, --ra.etc_method_code,
     SUM(tmp.ETC_PLAN_QUANTITY),
     SUM(tmp.ETC_TXN_RAW_COST),
     SUM(tmp.ETC_TXN_BURDENED_COST),
     SUM(tmp.ETC_TXN_REVENUE),
     NVL(ta.billable_flag,'Y'),                     /* Added for ER 4376722 */
     tmp_ra.transaction_source_code                 /* Added for Bug 4369741 */
FROM PA_FP_CALC_AMT_TMP1 tmp_ra,                    /* Added for Bug 4369741 */
   PA_FP_CALC_AMT_TMP2 tmp,
   PA_RESOURCE_ASSIGNMENTS ra,
   pa_tasks ta                                      /* Added for ER 4376722 */
WHERE tmp.target_res_asg_id = ra.resource_assignment_id
    AND tmp.TRANSACTION_SOURCE_CODE = 'ETC'
    and NVL(ra.task_id,0) = ta.task_id (+)          /* Added for ER 4376722 */
    --and ta.project_id = P_PROJECT_ID              /* Added for ER 4376722 */
    AND tmp_ra.target_res_asg_id = tmp.target_res_asg_id       /* Added for Bug 4369741 */
    AND tmp_ra.transaction_source_code <> 'OPEN_COMMITMENTS'   /* Added for Bug 4369741 */
    AND tmp_ra.transaction_source_code <> 'WORKPLAN_RESOURCES' /* Added for Bug 4369741 */
    AND ra.budget_version_id = P_BUDGET_VERSION_ID  /* Added for Bug 4369741 Perf */
    AND ra.project_id = P_PROJECT_ID                /* Added for Bug 4369741 Perf */
    AND tmp_ra.resource_assignment_id = tmp.resource_assignment_id /* Added for Bug 4571025 */
GROUP BY
tmp.TARGET_RES_ASG_ID,
       tmp.ETC_CURRENCY_CODE,
       ra.rate_based_flag,
       ra.resource_list_member_id,
       ra.task_id,
       ra.unit_of_measure,
       null, --ra.etc_method_code,
       NVL(ta.billable_flag,'Y'),                   /* Added for ER 4376722 */
       tmp_ra.transaction_source_code;              /* Added for Bug 4369741 */

/* Bug 4369741: Added cursor etc_amts_cur_fp_opt_same to be used in
 * the following scenario:
 * 1. Target ETC generation source = 'TASK_LEVEL_SEL'
 *    l_wp_planning_options_flag = N
 *    l_fp_planning_options_flag = Y
 * This cursor's SELECT statement uses the etc_amts_cur_wp_fp_opt_same
 * cursor's SELECT statement for resources with Financial Plan source
 * UNION ALL the etc_amts_cur_wp_fp_opt_diff cursor's SELECT statement for
 * resources with non Financial Plan source. */

CURSOR etc_amts_cur_fp_opt_same IS
SELECT /*+ INDEX(tmp,PA_FP_CALC_AMT_TMP2_N1)
           INDEX(tmp_ra,PA_FP_CALC_AMT_TMP1_N1) */
     tmp.RESOURCE_ASSIGNMENT_ID,
     tmp.TARGET_RES_ASG_ID,
     tmp.ETC_CURRENCY_CODE,
     ra.rate_based_flag,
     ra.resource_list_member_id,
     ra.task_id,
     ra.unit_of_measure,
     tmp_ra.etc_method_code,
     SUM(tmp.ETC_PLAN_QUANTITY),
     SUM(tmp.ETC_TXN_RAW_COST),
     SUM(tmp.ETC_TXN_BURDENED_COST),
     SUM(tmp.ETC_TXN_REVENUE),
     NVL(ta.billable_flag,'Y'),                       /* Added for ER 4376722 */
     tmp_ra.transaction_source_code                   /* Added for Bug 4369741 */
FROM PA_FP_CALC_AMT_TMP1 tmp_ra,
     PA_FP_CALC_AMT_TMP2 tmp,
     PA_RESOURCE_ASSIGNMENTS ra,
     pa_tasks ta                                      /* Added for ER 4376722 */
WHERE tmp.target_res_asg_id = ra.resource_assignment_id
      AND tmp.TRANSACTION_SOURCE_CODE = 'ETC'
      AND tmp_ra.target_res_asg_id = tmp.target_res_asg_id
      AND tmp_ra.transaction_source_code = 'FINANCIAL_PLAN' /* Added for Bug 4369741 */
      and NVL(ra.task_id,0) = ta.task_id (+)          /* Added for ER 4376722 */
      --and ta.project_id = P_PROJECT_ID              /* Added for ER 4376722 */
      AND ra.budget_version_id = P_BUDGET_VERSION_ID  /* Added for Bug 4369741 Perf */
      AND ra.project_id = P_PROJECT_ID                /* Added for Bug 4369741 Perf */
      AND tmp_ra.resource_assignment_id = tmp.resource_assignment_id /* Added for Bug 4571025 */
GROUP BY tmp.RESOURCE_ASSIGNMENT_ID,
         tmp.TARGET_RES_ASG_ID,
         tmp.ETC_CURRENCY_CODE,
         ra.rate_based_flag,
         ra.resource_list_member_id,
         ra.task_id,
         ra.unit_of_measure,
         tmp_ra.etc_method_code,
         NVL(ta.billable_flag,'Y'),                  /* Added for ER 4376722 */
         tmp_ra.transaction_source_code              /* Added for Bug 4369741 */
UNION ALL
SELECT /*+ INDEX(tmp,PA_FP_CALC_AMT_TMP2_N1)
           INDEX(tmp_ra,PA_FP_CALC_AMT_TMP1_N1) */
     sum(1*null),
     tmp.TARGET_RES_ASG_ID,
     tmp.ETC_CURRENCY_CODE,
     ra.rate_based_flag,
     ra.resource_list_member_id,
     ra.task_id,
     ra.unit_of_measure,
     null, --ra.etc_method_code,
     SUM(tmp.ETC_PLAN_QUANTITY),
     SUM(tmp.ETC_TXN_RAW_COST),
     SUM(tmp.ETC_TXN_BURDENED_COST),
     SUM(tmp.ETC_TXN_REVENUE),
     NVL(ta.billable_flag,'Y'),                     /* Added for ER 4376722 */
     tmp_ra.transaction_source_code                 /* Added for Bug 4369741 */
FROM PA_FP_CALC_AMT_TMP1 tmp_ra,                    /* Added for Bug 4369741 */
   PA_FP_CALC_AMT_TMP2 tmp,
   PA_RESOURCE_ASSIGNMENTS ra,
   pa_tasks ta                                      /* Added for ER 4376722 */
WHERE tmp.target_res_asg_id = ra.resource_assignment_id
    AND tmp.TRANSACTION_SOURCE_CODE = 'ETC'
    and NVL(ra.task_id,0) = ta.task_id (+)          /* Added for ER 4376722 */
    --and ta.project_id = P_PROJECT_ID              /* Added for ER 4376722 */
    AND tmp_ra.target_res_asg_id = tmp.target_res_asg_id      /* Added for Bug 4369741 */
    AND tmp_ra.transaction_source_code <> 'OPEN_COMMITMENTS'  /* Added for Bug 4369741 */
    AND tmp_ra.transaction_source_code <> 'FINANCIAL_PLAN'    /* Added for Bug 4369741 */
    AND ra.budget_version_id = P_BUDGET_VERSION_ID  /* Added for Bug 4369741 Perf */
    AND ra.project_id = P_PROJECT_ID                /* Added for Bug 4369741 Perf */
    AND tmp_ra.resource_assignment_id = tmp.resource_assignment_id /* Added for Bug 4571025 */
GROUP BY
tmp.TARGET_RES_ASG_ID,
       tmp.ETC_CURRENCY_CODE,
       ra.rate_based_flag,
       ra.resource_list_member_id,
       ra.task_id,
       ra.unit_of_measure,
       null, --ra.etc_method_code,
       NVL(ta.billable_flag,'Y'),                   /* Added for ER 4376722 */
       tmp_ra.transaction_source_code;              /* Added for Bug 4369741 */

/* Bug 4654157 and 4670253: Variables for enforcing positive total plan quantity */
l_index                        NUMBER; -- index for _tmp tables
l_total_plan_qty               NUMBER;
l_cal_rcost_rate_ovrd_tab_tmp  SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_cal_bcost_rate_ovrd_tab_tmp  SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_cal_bill_rate_ovrd_tab_tmp   SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();

-- IPM: New Entity ER ------------------------------------------
-- Stores ids of resources with Financial Plan as the ETC generation source
l_fp_ra_id_tab                 SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
-- Stores ids of resources with Workplan as the ETC generation source
l_wp_ra_id_tab                 SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
-- Stores ids of non-billable resources with Financial Plan as the ETC generation source
l_non_billable_fp_ra_id_tab    SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();

-- Defining a table of tables to process tables in a loop.
TYPE SystemPaNumTblTypeTabType
IS TABLE OF SYSTEM.pa_num_tbl_type INDEX BY BINARY_INTEGER;

l_ra_id_tab_table              SystemPaNumTblTypeTabType;
l_planning_options_flag_tab    PA_PLSQL_DATATYPES.Char1TabTyp;
l_src_version_id_tab           PA_PLSQL_DATATYPES.NumTabTyp;

 /***
  * Added in IPM
  * Variable   : L_REMOVE_RECORD_FLAG_TAB
  * Background : There are a growing number of cases where it is
  *              necessary to skip certain records in further
  *              processing. The strategy up till now has been
  *              to copy non-skipped records into a set of temporary
  *              pl/sql tables and then copy back to the original
  *              tables. This table is being introduced to reduce
  *              the number of times tables are copied back and forth.
  * Usage    : - Records in this table should be in a 1-to-1 mapping
  *              with planning txns given by the l_cal_ra_id_tab and
  *              l_cal_txn_curr_code_tab tables.
  *            - By default, initialize all records in this table to 'N'.
  *            - Any time it becomes necessary for a planning txn
  *              to be skipped in further processing, the corresponding
  *              record in this table should be set to 'Y'.
  *            - Downstream generation code should check this table
  *              at the beginning of logical processing blocks.
  *
  * Variable   : L_REMOVE_RECORDS_FLAG
  * Usage    : - By default, initialize this flag to 'N'.
  *            - Set this flag to 'Y' if any record in the associated
  *              l_remove_record_flag_tab table is set to 'Y'.
  *            - Before the Calculate or Maintain_Actual_Amt_Ra APIs
  *              are called, if this flag is 'Y', then records with
  *              l_remove_record_flag_tab(i) = 'Y' should be filtered
  *              from the main pl/sql tables.
  *
  * Variable   : L_REV_ONLY_SRC_TXN_FLAG_TAB
  * Background : As of IPM, it is possible to plan for just revenue
  *              amounts (without cost amounts) in a Cost and Revenue
  *              Together version. Pre-IPM, quantity was always set to
  *              raw cost for non-rate-based transactions. However, in
  *              the revenue only case, we store quantity as revenue.
  *              In order to handle this correctly, it is necessary to
  *              know if ETC revenue exists without ETC raw cost. This
  *              latter piece of information is initially available
  *              after querying for the ETC numbers. However, it may
  *              be lost once the generation logic begins processing
  *              and manipulating the amounts. Hence, this table is being
  *              introduced to track which transactions have only ETC
  *              revenue amounts.
  * Usage    : - Records in this table should be in a 1-to-1 mapping
  *              with planning txns given by the l_cal_ra_id_tab and
  *              l_cal_txn_curr_code_tab tables.
  *            - By default, initialize all records in this table to 'N'.
  *            - Set records whose corresponding planning txns have only
  *              ETC revenue amounts (i.e. Null ETC raw cost) to 'Y'.
  */

-- Added in IPM to track if a record in the existing set of
-- pl/sql tables needs to be removed.
l_remove_record_flag_tab       PA_PLSQL_DATATYPES.Char1TabTyp;
l_remove_records_flag          VARCHAR2(1);

-- Added in IPM to track if only ETC revenue is available.
-- Note that this table should be initialized after ETC is
-- fetched but before assignments to ETC raw cost begin.
l_rev_only_src_txn_flag_tab        PA_PLSQL_DATATYPES.Char1TabTyp;

/* This user-defined exception is used to skip processing of
 * a planning transaction within a loop */
continue_loop                 EXCEPTION;

l_source_version_type_tab      PA_PLSQL_DATATYPES.Char30TabTyp;
l_target_version_type          PA_BUDGET_VERSIONS.VERSION_TYPE%TYPE;

BEGIN
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT := 0;
    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function     => 'GEN_FCST_TASK_LEVEL_AMT',
                                    p_debug_mode   =>  p_pa_debug_mode);
    END IF;
    l_latest_published_fwbs_id := PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_FIN_STRUC_VER_ID(P_PROJECT_ID);
    l_proj_struc_sharing_code := NVL(PA_PROJECT_STRUCTURE_UTILS.
                get_Structure_sharing_code(P_PROJECT_ID),'SHARE_FULL');
        /*IF p_pa_debug_mode = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Value of l_latest_published_fwbs_id: '||l_latest_published_fwbs_id,
             p_module_name => l_module_name,
             p_log_level   => 5);
        END IF;*/
        /*IF p_pa_debug_mode = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Value of l_proj_struc_sharing_code: '||l_proj_struc_sharing_code,
             p_module_name => l_module_name,
             p_log_level   => 5);
        END IF;*/
        /*IF p_pa_debug_mode = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Value of p_wp_structure_version_id: '||p_wp_structure_version_id,
             p_module_name => l_module_name,
             p_log_level   => 5);
        END IF;*/

    IF p_fp_cols_rec.x_version_type = 'REVENUE' THEN
        l_fcst_gen_src_code := p_fp_cols_rec.x_gen_etc_src_code;
    END IF;

    IF p_fp_cols_rec.x_version_type = 'REVENUE' AND
       l_fcst_gen_src_code IN ('NONE','AVERAGE_ACTUALS') THEN

        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE       => P_CALLED_MODE,
                P_MSG               => 'Before calling pa_fp_copy_actuals_pub.copy_actuals',
                P_MODULE_NAME       => l_module_name);
        END IF;
        PA_FP_COPY_ACTUALS_PUB.COPY_ACTUALS
              (P_PROJECT_ID               => P_PROJECT_ID,
               P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
               P_FP_COLS_REC              => P_fp_cols_rec,
               P_END_DATE                 => P_ACTUALS_THRU_DATE,
               P_INIT_MSG_FLAG            => 'N',
               P_COMMIT_FLAG              => 'N',
               X_RETURN_STATUS            => X_RETURN_STATUS,
               X_MSG_COUNT                => X_MSG_COUNT,
               X_MSG_DATA                 => X_MSG_DATA);
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE       => P_CALLED_MODE,
                P_MSG               => 'After calling pa_fp_copy_actuals_pub.copy_actuals:'
                                       ||x_return_status,
                P_MODULE_NAME       => l_module_name);
        END IF;
        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        IF l_fcst_gen_src_code = 'NONE' THEN
            IF p_pa_debug_mode = 'Y' THEN
                PA_DEBUG.Reset_Curr_Function;
            END IF;
            RETURN;
        END IF;

        IF l_fcst_gen_src_code = 'AVERAGE_ACTUALS' THEN
            IF p_pa_debug_mode = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                    P_CALLED_MODE       => P_CALLED_MODE,
                    P_MSG               => 'Before calling PA_FP_GEN_FCST_AMT_PUB.'||
                   'GEN_AVERAGE_OF_ACTUALS_WRP for Revenue only version',
                    P_MODULE_NAME       => l_module_name);
            END IF;

            /* hr_utility.trace('Values passed to call GEN_AVERAGE_OF_ACTUALS_WRP api');
            hr_utility.trace('P_BUDGET_VERSION_ID: '||P_BUDGET_VERSION_ID);
            hr_utility.trace('l_curr_task_id: '||l_curr_task_id);
            hr_utility.trace('P_ACTUALS_THRU_DATE: '||P_ACTUALS_THRU_DATE);
            hr_utility.trace('P_ACTUALS_FROM_PERIOD: '||P_ACTUALS_FROM_PERIOD);
            hr_utility.trace('P_ACTUALS_TO_PERIOD: '||P_ACTUALS_TO_PERIOD);
            hr_utility.trace('P_ETC_FROM_PERIOD: '||P_ETC_FROM_PERIOD);
            hr_utility.trace('P_ETC_TO_PERIOD: '||P_ETC_TO_PERIOD);   */

            /* When the task id is passed as NULL, the wrapper API generates
               the ETC numbers for all the target version planning resources
               based on the average value of the actual txn data. */

            PA_FP_GEN_FCST_AMT_PUB1.GEN_AVERAGE_OF_ACTUALS_WRP
                    (P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
                     P_TASK_ID                  => NULL,
                     P_ACTUALS_THRU_DATE        => P_ACTUALS_THRU_DATE,
                     P_FP_COLS_REC              => P_FP_COLS_REC,
                     P_ACTUALS_FROM_PERIOD      => P_ACTUALS_FROM_PERIOD,
                     P_ACTUALS_TO_PERIOD        => P_ACTUALS_TO_PERIOD,
                     P_ETC_FROM_PERIOD          => P_ETC_FROM_PERIOD,
                     P_ETC_TO_PERIOD            => P_ETC_TO_PERIOD,
                     X_RETURN_STATUS            => X_RETURN_STATUS,
                     X_MSG_COUNT                => X_MSG_COUNT,
                     X_MSG_DATA                 => X_MSG_DATA );
              -- hr_utility.trace('Return status after calling GEN_AVERAGE_OF_ACTUALS_WRP: '
              -- ||x_return_status);
            IF p_pa_debug_mode = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                    P_CALLED_MODE       => P_CALLED_MODE,
                    P_MSG               => 'After calling PA_FP_GEN_FCST_AMT_PUB.'||
                                           'GEN_AVERAGE_OF_ACTUALS_WRP: '||x_return_status,
                    P_MODULE_NAME       => l_module_name);
            END IF;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF p_pa_debug_mode = 'Y' THEN
                    PA_DEBUG.Reset_Curr_Function;
                END IF;
                raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            IF p_pa_debug_mode = 'Y' THEN
                PA_DEBUG.Reset_Curr_Function;
            END IF;

            RETURN;
       END IF;       -- for average actual check
       /* the processing should continue when the target plan version type is
          REVENUE and the ETC Revenue generation source is either 'FINANCIAL_PLAN'
          or 'WORKPLAN_RESOURCES'. */

    END IF; -- for revenue check

    IF P_WP_STRUCTURE_VERSION_ID IS NOT NULL THEN
        l_wp_version_id := Pa_Fp_wp_gen_amt_utils.get_wp_version_id
            ( p_project_id                    => P_PROJECT_ID,
              p_plan_type_id                  => -1,
              p_proj_str_ver_id               => P_WP_STRUCTURE_VERSION_ID );

        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE           => P_CALLED_MODE,
                P_MSG                   => 'Before calling PA_FP_GEN_AMOUNT_UTILS.'||
                                           'GET_PLAN_VERSION_DTL',
                P_MODULE_NAME           => l_module_name);
        END IF;
        PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS(
                P_PROJECT_ID            => P_PROJECT_ID,
                P_BUDGET_VERSION_ID     => l_wp_version_id,
                X_FP_COLS_REC           => l_fp_cols_rec_wp,
                X_RETURN_STATUS         => x_return_status,
                X_MSG_COUNT             => x_msg_count,
                X_MSG_DATA              => x_msg_data);
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE           => P_CALLED_MODE,
                P_MSG                   => 'After calling PA_FP_GEN_AMOUNT_UTILS.'||
                                           'GET_PLAN_VERSION_DTL:'||x_return_status,
                P_MODULE_NAME           => l_module_name);
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    END IF;

        /*IF p_pa_debug_mode = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Value of p_etc_fp_plan_version_id: '||p_etc_fp_plan_version_id,
             p_module_name => l_module_name,
             p_log_level   => 5);
        END IF;*/

    IF P_ETC_FP_PLAN_VERSION_ID IS NOT NULL THEN
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE           => P_CALLED_MODE,
                P_MSG                   => 'Before calling PA_FP_GEN_AMOUNT_UTILS.'||
                                           'GET_PLAN_VERSION_DTLS',
                P_MODULE_NAME           => l_module_name);
        END IF;
        PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS(
                P_PROJECT_ID            => P_PROJECT_ID,
                P_BUDGET_VERSION_ID     => P_ETC_FP_PLAN_VERSION_ID,
                X_FP_COLS_REC           => l_fp_cols_rec_fp,
                X_RETURN_STATUS         => x_return_status,
                X_MSG_COUNT             => x_msg_count,
                X_MSG_DATA              => x_msg_data);
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE           => P_CALLED_MODE,
                P_MSG                   => 'After calling PA_FP_GEN_AMOUNT_UTILS.'||
                                           'GET_PLAN_VERSION_DTLS: '||x_return_status,
                P_MODULE_NAME           => l_module_name);
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    END IF;

    l_fp_cols_rec_target :=  P_FP_COLS_REC;
    l_calendar_type := l_fp_cols_rec_target.X_TIME_PHASED_CODE;

    /**l_record_type: XXXX
      *1st X: 'Y',data will be returned in periods;
      *       'N',ITD amounts will be returned;
      *2nd X: 'Y',data will be returned by planning resources at
      *        entered level(periodic/total);
      *3rd X:  'Y',data is returned by tasks;
      *4th X:  'N',amt will be gotten at entered level, no rollup is done.**/
    IF (l_calendar_type = 'G' OR l_calendar_type = 'P') THEN
        l_record_type := 'Y';
    ELSE
        l_record_type := 'N';
    END IF;
    l_record_type := l_record_type||'Y'||'Y'||'N';

    --*****Populate pji tmp1,fcst tmp1 tables from workplan version******--
    -- hr_utility.trace('P_WP_STRUCTURE_VERSION_ID: '||P_WP_STRUCTURE_VERSION_ID);
    IF P_WP_STRUCTURE_VERSION_ID IS NOT NULL THEN
        l_resource_list_id := l_fp_cols_rec_wp.X_RESOURCE_LIST_ID;
        l_struct_ver_id := l_fp_cols_rec_wp.X_PROJECT_STRUCTURE_VERSION_ID;

        /*IF p_pa_debug_mode = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Value of l_resource_list_id: '||l_resource_list_id,
             p_module_name => l_module_name,
             p_log_level   => 5);
        END IF;*/
        /*IF p_pa_debug_mode = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Value of l_struct_ver_id: '||l_struct_ver_id,
             p_module_name => l_module_name,
             p_log_level   => 5);
        END IF;*/

        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE           => P_CALLED_MODE,
                P_MSG                   => 'Before calling PA_FP_GEN_FCST_AMT_PUB1.'||
                                           'CALL_SUMM_POP_TMPS',
                P_MODULE_NAME           => l_module_name);
        END IF;

/* hr_utility.trace('1.l_calendar_type: '||l_calendar_type);
hr_utility.trace('1.l_record_type: '||l_record_type);
hr_utility.trace('1.l_resource_list_id: '||l_resource_list_id);
hr_utility.trace('1.l_struct_ver_id: '||l_struct_ver_id);
hr_utility.trace('1.P_ACTUALS_THRU_DATE: '||P_ACTUALS_THRU_DATE);   */

        PA_FP_GEN_FCST_AMT_PUB1.CALL_SUMM_POP_TMPS(
                P_PROJECT_ID            => P_PROJECT_ID,
                P_CALENDAR_TYPE         => l_calendar_type,
                P_RECORD_TYPE           => l_record_type,
                P_RESOURCE_LIST_ID      => l_resource_list_id,
                P_STRUCT_VER_ID         => l_struct_ver_id,
                P_ACTUALS_THRU_DATE     => P_ACTUALS_THRU_DATE,
                P_DATA_TYPE_CODE        => 'ETC_WP',
                X_RETURN_STATUS         => x_return_status,
                X_MSG_COUNT             => x_msg_count,
                X_MSG_DATA              => x_msg_data );
        -- hr_utility.trace('1.Status after calling call_summ_pop_tmps api: '||x_return_status);
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE           => P_CALLED_MODE,
                P_MSG                   => 'After calling PA_FP_GEN_FCST_AMT_PUB1.'||
                                           'CALL_SUMM_POP_TMPS:'||x_return_status,
                P_MODULE_NAME           => l_module_name);
        END IF;
        --dbms_output.put_line('After calling pji api: '||x_return_status);
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
     END IF; -- for wp_structure_version_id check

    --*****Populate pji tmp1,fcst tmp1 tables from ETC financial version******--
    -- hr_utility.trace('P_ETC_FP_PLAN_VERSION_ID: '||P_ETC_FP_PLAN_VERSION_ID);
    IF P_ETC_FP_PLAN_VERSION_ID IS NOT NULL THEN
        l_resource_list_id := l_fp_cols_rec_fp.X_RESOURCE_LIST_ID;
        l_struct_ver_id := l_fp_cols_rec_fp.X_PROJECT_STRUCTURE_VERSION_ID;

        /*IF p_pa_debug_mode = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Value of l_resource_list_id: '||l_resource_list_id,
             p_module_name => l_module_name,
             p_log_level   => 5);
        END IF;*/
        /*IF p_pa_debug_mode = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Value of l_struct_ver_id: '||l_struct_ver_id,
             p_module_name => l_module_name,
             p_log_level   => 5);
        END IF;*/

        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE           => P_CALLED_MODE,
                P_MSG                   => 'Before calling PA_FP_GEN_FCST_AMT_PUB1.'||
                                           'CALL_SUMM_POP_TMPS',
                P_MODULE_NAME           => l_module_name);
        END IF;

/* hr_utility.trace('2.l_calendar_type: '||l_calendar_type);
hr_utility.trace('2.l_record_type: '||l_record_type);
hr_utility.trace('2.l_resource_list_id: '||l_resource_list_id);
hr_utility.trace('2.l_struct_ver_id: '||l_struct_ver_id);
hr_utility.trace('2.P_ACTUALS_THRU_DATE: '||P_ACTUALS_THRU_DATE);   */

        PA_FP_GEN_FCST_AMT_PUB1.CALL_SUMM_POP_TMPS(
                P_PROJECT_ID            => P_PROJECT_ID,
                P_CALENDAR_TYPE         => l_calendar_type,
                P_RECORD_TYPE           => l_record_type,
                P_RESOURCE_LIST_ID      => l_resource_list_id,
                P_STRUCT_VER_ID         => l_struct_ver_id,
                P_ACTUALS_THRU_DATE     => P_ACTUALS_THRU_DATE,
                P_DATA_TYPE_CODE        => 'ETC_FP',
                X_RETURN_STATUS         => x_return_status,
                X_MSG_COUNT             => x_msg_count,
                X_MSG_DATA              => x_msg_data );
        -- hr_utility.trace('2.Status after calling call_summ_pop_tmps api: '||x_return_status);
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE           => P_CALLED_MODE,
                P_MSG                   => 'After calling PA_FP_GEN_FCST_AMT_PUB1.'||
                                           'CALL_SUMM_POP_TMPS:'||x_return_status,
                P_MODULE_NAME           => l_module_name);
        END IF;
        --dbms_output.put_line('After calling pji api: '||x_return_status);
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
     END IF; -- for P_ETC_FP_PLAN_VERSION_ID check

    --*****Populate pji tmp1,fcst tmp1 tables from target financial version******--
    l_resource_list_id := l_fp_cols_rec_target.X_RESOURCE_LIST_ID;
    l_struct_ver_id := l_fp_cols_rec_target.X_PROJECT_STRUCTURE_VERSION_ID;
        /*IF p_pa_debug_mode = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Value of l_resource_list_id: '||l_resource_list_id,
             p_module_name => l_module_name,
             p_log_level   => 5);
        END IF;
        IF p_pa_debug_mode = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Value of l_struct_ver_id: '||l_struct_ver_id,
             p_module_name => l_module_name,
             p_log_level   => 5);
        END IF;*/
    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE           => P_CALLED_MODE,
                P_MSG                   => 'Before calling PA_FP_GEN_FCST_AMT_PUB1.'||
                                           'CALL_SUMM_POP_TMPS',
                P_MODULE_NAME           => l_module_name);
    END IF;
/* hr_utility.trace('3.l_calendar_type: '||l_calendar_type);
hr_utility.trace('3.l_record_type: '||l_record_type);
hr_utility.trace('3.l_resource_list_id: '||l_resource_list_id);
hr_utility.trace('3.l_struct_ver_id: '||l_struct_ver_id);
hr_utility.trace('3.P_ACTUALS_THRU_DATE: '||P_ACTUALS_THRU_DATE);  */
    PA_FP_GEN_FCST_AMT_PUB1.CALL_SUMM_POP_TMPS(
                P_PROJECT_ID            => P_PROJECT_ID,
                P_CALENDAR_TYPE         => l_calendar_type,
                P_RECORD_TYPE           => l_record_type,
                P_RESOURCE_LIST_ID      => l_resource_list_id,
                P_STRUCT_VER_ID         => l_struct_ver_id,
                P_ACTUALS_THRU_DATE     => P_ACTUALS_THRU_DATE,
                P_DATA_TYPE_CODE        => 'TARGET_FP',
                X_RETURN_STATUS         => x_return_status,
                X_MSG_COUNT             => x_msg_count,
                X_MSG_DATA              => x_msg_data );
    -- hr_utility.trace('3.Status after calling call_summ_pop_tmps api: '||x_return_status);
    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE           => P_CALLED_MODE,
                P_MSG                   => 'After calling PA_FP_GEN_FCST_AMT_PUB1.'||
                                           'CALL_SUMM_POP_TMPS:'||x_return_status,
                P_MODULE_NAME           => l_module_name);
    END IF;
    --dbms_output.put_line('  --After calling pji get_summarized api: '||x_return_status);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    /**traverse each node in latest published finanical WBS,
      *check for each task's etc source code, do corresponding
      *operations.**/

    /* 10/11/2004 ETC Enhancements:
       For Top Task planning, copy ETC method from Top Task to all of its children
    */
    -- hr_utility.trace('FIN_PLAN_LEVEL_CODE: '||l_fp_cols_rec_target.X_FIN_PLAN_LEVEL_CODE);
    /* Planning level : top task */
    if l_fp_cols_rec_target.X_FIN_PLAN_LEVEL_CODE = 'T' then
        OPEN traverse_top_tasks_cur(l_fcst_gen_src_code);
        FETCH traverse_top_tasks_cur
        BULK COLLECT
        INTO  l_top_task_id_tab,
              l_top_gen_etc_src_code_tab;
        CLOSE traverse_top_tasks_cur;
/* hr_utility.trace('l_top_task_id_tab,count: '||l_top_task_id_tab.count);
hr_utility.trace('l_top_gen_etc_src_code_tab.count: '||l_top_gen_etc_src_code_tab.count); */
        l_task_index := 0;
        FOR i in 1..l_top_task_id_tab.last LOOP
            /* Add the Top Task to pl/sql tables */
            l_task_id_tab(l_task_index) := l_top_task_id_tab(i);
            l_gen_etc_source_code_tab(l_task_index) := l_top_gen_etc_src_code_tab(i);
            l_task_index := l_task_index + 1;
            l_temp_top_task_id := l_top_task_id_tab(i);
            l_child_task_id_tab.DELETE;

            OPEN traverse_child_tasks_cur;
            FETCH traverse_child_tasks_cur
            BULK COLLECT
            INTO l_child_task_id_tab;
            CLOSE traverse_child_tasks_cur;

            -- hr_utility.trace('l_child_task_id_tab.count: '||l_child_task_id_tab.count);
            FOR j in 1..l_child_task_id_tab.count LOOP
                /* Add the Top Task's childen to pl/sql tables */
                l_task_id_tab(l_task_index) := l_child_task_id_tab(j);
                l_gen_etc_source_code_tab(l_task_index) := l_top_gen_etc_src_code_tab(i);
                l_task_index := l_task_index + 1;
            END LOOP;
        END LOOP;
    ELSIF   l_fp_cols_rec_target.X_FIN_PLAN_LEVEL_CODE IN ('L','P') THEN
        /* Lowest task or Project */
        OPEN traverse_tasks_cur(l_fcst_gen_src_code);
        FETCH traverse_tasks_cur
        BULK COLLECT
        INTO  l_task_id_tab,
              l_gen_etc_source_code_tab;
        CLOSE traverse_tasks_cur;
    END IF; -- for plan level check

    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE           => P_CALLED_MODE,
                P_MSG                   => 'In traverse cursor, we have how many records?'||
                l_task_id_tab.count,
                P_MODULE_NAME           => l_module_name);
    END IF;
    IF l_task_id_tab.count = 0 THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN;
    END IF;
     /* hr_utility.trace('--Before traverse any task node');
    hr_utility.trace('--we have :'||l_task_id_tab.count||' task ids');  */
    FOR i IN l_task_id_tab.first..l_task_id_tab.last LOOP
        -- hr_utility.trace(i||'th task->');

        l_curr_task_id := l_task_id_tab(i);
        l_curr_etc_source := l_gen_etc_source_code_tab(i);

        /* hr_utility.trace('--task id is:'||l_task_id_tab(i));
        hr_utility.trace('--curr etc source is fin/wp/wkqty/avgact:'||
        l_gen_etc_source_code_tab(i));  */
        --dbms_output.put_line('--task id is:'||l_task_id_tab(i));
        --dbms_output.put_line('--curr etc source is fin/wp/wkqty/avgact:'||l_gen_etc_source_code_tab(i));
       /* IF p_pa_debug_mode = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Value of l_curr_etc_source: '||l_curr_etc_source,
             p_module_name => l_module_name,
             p_log_level   => 5);
        END IF;*/
        -- hr_utility.trace('l_curr_etc_source: '||l_curr_etc_source);
        IF l_curr_etc_source = 'AVERAGE_ACTUALS' THEN
            -- Bug 4114589: Processing of tasks with source of Average of Actuals
            -- has moved to after the resource mapping and Copy Actuals API call.
            l_avg_actuals_task_id_tab(l_avg_actuals_task_id_tab.count+1) := l_curr_task_id;
        ELSIF l_curr_etc_source = 'FINANCIAL_PLAN'
              OR l_curr_etc_source = 'WORKPLAN_RESOURCES' THEN
            l_proceed_flag := 'Y';
            IF l_curr_etc_source = 'WORKPLAN_RESOURCES' AND
               l_proj_struc_sharing_code = 'SPLIT_NO_MAPPING' THEN
                IF l_entered_flag = 'Y' THEN
                    l_proceed_flag := 'N';
                ELSE
                    l_proceed_flag := 'Y';
                    l_entered_flag := 'Y';
                END IF;
            END IF;
            IF l_proceed_flag = 'Y' THEN
                IF l_curr_etc_source = 'FINANCIAL_PLAN' THEN
                    l_calling_context := 'FINANCIAL_PLAN';
                ELSIF l_curr_etc_source = 'WORKPLAN_RESOURCES' THEN
                    l_calling_context := 'WORK_PLAN';
                END IF;

                /*IF p_pa_debug_mode = 'Y' THEN
                     pa_fp_gen_amount_utils.fp_debug
                    (p_msg         => 'Value of l_calling_context: '||l_calling_context,
                     p_module_name => l_module_name,
                     p_log_level   => 5);
                END IF;*/

                /**Calling the total_plan_txn_amts api to get the total
                  *transaction amts for a given task**/
                IF P_PA_DEBUG_MODE = 'Y' THEN
                    PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                        P_CALLED_MODE       => P_CALLED_MODE,
                        P_MSG               => 'Before calling pa_fp_gen_fcst_amt_pub.'||
                                               'get_total_plan_txn_amts',
                        P_MODULE_NAME       => l_module_name);
                END IF;
                --dbms_output.put_line('--Before GET_TOTAL--');
                --dbms_output.put_line('--P_PROJECT_ID:'||p_project_id);
                --dbms_output.put_line('--P_BUDGET_VERSION_ID:'||P_BUDGET_VERSION_ID);
                --dbms_output.put_line('--l_wp_version_id:'||l_wp_version_id);
                --dbms_output.put_line('--P_ETC_FP_PLAN_VERSION_ID:'||P_ETC_FP_PLAN_VERSION_ID);
                --dbms_output.put_line('--l_fp_cols_rec_wp:'||l_fp_cols_rec_wp.X_PROJ_FP_OPTIONS_ID);
                --dbms_output.put_line('--l_fp_cols_rec_fp:'||l_fp_cols_rec_fp.X_PROJ_FP_OPTIONS_ID);
                --dbms_output.put_line('--P_FP_COLS_REC:'||P_FP_COLS_REC.X_PROJ_FP_OPTIONS_ID);
                --dbms_output.put_line('--l_curr_task_id:'||l_curr_task_id);
                --dbms_output.put_line('--l_calling_context:'||l_calling_context);

                BEGIN
                PA_FP_GEN_FCST_AMT_PVT.GET_TOTAL_PLAN_TXN_AMTS
                      ( P_PROJECT_ID                => P_PROJECT_ID,
                        P_BUDGET_VERSION_ID         => P_BUDGET_VERSION_ID,
                        P_BV_ID_ETC_WP              => l_wp_version_id,
                        P_BV_ID_ETC_FP              => P_ETC_FP_PLAN_VERSION_ID,
                        P_FP_COLS_REC_ETC_WP        => l_fp_cols_rec_wp,
                        P_FP_COLS_REC_ETC_FP        => l_fp_cols_rec_fp,
                        P_FP_COLS_REC               => P_FP_COLS_REC,
                        P_TASK_ID                   => l_curr_task_id,
                        --P_RES_LIST_MEMBER_ID      => NULL,
                        --P_TXN_CURRENCY_CODE       => NULL,
                        P_LATEST_PUBLISH_FP_WBS_ID  => l_latest_published_fwbs_id,
                        P_CALLING_CONTEXT           => l_calling_context,
                        X_TXN_AMT_REC               => l_txn_amt_rec,
                        X_RETURN_STATUS             => x_return_status,
                        X_MSG_COUNT                 => x_msg_count,
                        X_MSG_DATA                  => x_msg_data );
                EXCEPTION
                WHEN no_data_found THEN
                    IF p_pa_debug_mode = 'Y' THEN
                         PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                            P_CALLED_MODE           => P_CALLED_MODE,
                            P_MSG                   => 'PA_FP_GEN_FCST_AMT_PVT.GET_TOTAL_PLAN_TXN_AMTS '||
                                                       'throws out no_data_found exception',
                            P_MODULE_NAME           => l_module_name);
                    END IF;
                END;
                IF p_pa_debug_mode = 'Y' THEN
                    PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                        P_CALLED_MODE       => P_CALLED_MODE,
                        P_MSG               => 'After calling pa_fp_gen_fcst_amt_pub.'||
                                               'get_total_plan_txn_amts: '||x_return_status,
                        P_MODULE_NAME       => l_module_name);
                END IF;
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    IF p_pa_debug_mode = 'Y' THEN
                        PA_DEBUG.Reset_Curr_Function;
                    END IF;
                    raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;
            END IF;
        ELSIF l_curr_etc_source = 'WORK_QUANTITY' THEN
            /*IF p_pa_debug_mode = 'Y' THEN
                 pa_fp_gen_amount_utils.fp_debug
                (p_msg         => 'Value of l_curr_etc_source: '||l_curr_etc_source,
                 p_module_name => l_module_name,
                 p_log_level   => 5);
            END IF;
            IF p_pa_debug_mode = 'Y' THEN
                 pa_fp_gen_amount_utils.fp_debug
                (p_msg         => 'Value of l_work_qty_cnt: '||l_work_qty_cnt,
                 p_module_name => l_module_name,
                 p_log_level   => 5);
            END IF;
            IF p_pa_debug_mode = 'Y' THEN
                 pa_fp_gen_amount_utils.fp_debug
                (p_msg         => 'Value of l_proj_struc_sharing_code: '||l_proj_struc_sharing_code,
                 p_module_name => l_module_name,
                 p_log_level   => 5);
            END IF;*/
            IF l_work_qty_cnt = 0 THEN
                IF l_proj_struc_sharing_code = 'SPLIT_NO_MAPPING' THEN
                    l_work_qty_cnt := 1;
                    l_curr_task_id := NULL;
                END IF;
                IF P_PA_DEBUG_MODE = 'Y' THEN
                    PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                        P_CALLED_MODE   => P_CALLED_MODE,
                        P_MSG           => 'Before calling pa_fp_gen_fcst_amt_pub1.'||
                                           'GET_ETC_WORK_QTY_AMTS',
                        P_MODULE_NAME   => l_module_name);
                END IF;
                /*WORK_QTY_AMTS are generated at task level, so P_RESOURCE_ASSIGNMENT and
                  P_RESOURCE_LIST_MEMBER_ID are not needed*/
                PA_FP_GEN_FCST_AMT_PUB1.GET_ETC_WORK_QTY_AMTS(
                        P_PROJECT_ID                    => P_PROJECT_ID,
                        P_PROJ_CURRENCY_CODE            => P_FP_COLS_REC.X_PROJECT_CURRENCY_CODE,
                        P_BUDGET_VERSION_ID             => P_BUDGET_VERSION_ID,
                        P_TASK_ID                       => l_curr_task_id,
                        P_TARGET_RES_LIST_ID            => l_fp_cols_rec_target.X_RESOURCE_LIST_ID,
                        P_ACTUALS_THRU_DATE             => P_ACTUALS_THRU_DATE,
                        P_FP_COLS_REC                   => P_FP_COLS_REC,
                        P_WP_STRUCTURE_VERSION_ID       => P_WP_STRUCTURE_VERSION_ID,
                        X_RETURN_STATUS                 => x_return_status,
                        X_MSG_COUNT                     => x_msg_count,
                        X_MSG_DATA                      => x_msg_data);
                IF p_pa_debug_mode = 'Y' THEN
                    PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                        P_CALLED_MODE   => P_CALLED_MODE,
                        P_MSG           => 'After calling pa_fp_gen_fcst_amt_pub1.'||
                                           'GET_ETC_WORK_QTY_AMTS: '||x_return_status,
                        P_MODULE_NAME   => l_module_name);
                END IF;
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;
            END IF;
        ELSIF l_curr_etc_source = 'NONE' THEN
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                    P_CALLED_MODE       => P_CALLED_MODE,
                    P_MSG               => 'Before calling pa_fp_gen_fcst_amt_pub1.none_etc_src',
                    P_MODULE_NAME       => l_module_name);
            END IF;
            PA_FP_GEN_FCST_AMT_PUB1.NONE_ETC_SRC(
                        P_PROJECT_ID            => P_PROJECT_ID,
                        P_BUDGET_VERSION_ID     => P_BUDGET_VERSION_ID,
                        P_RESOURCE_LIST_ID      => l_fp_cols_rec_target.X_RESOURCE_LIST_ID,
                        P_TASK_ID               => l_curr_task_id,
                        X_RETURN_STATUS         => x_return_status,
                        X_MSG_COUNT             => x_msg_count,
                        X_MSG_DATA              => x_msg_data );
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF p_pa_debug_mode = 'Y' THEN
                    PA_DEBUG.Reset_Curr_Function;
                END IF;
                raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
        END IF;
    END LOOP;

    --Bug 6407972
    --Bug 5929269. If the plan version into whihc amounts are being forecasted has
    --Top Task Planning level then the task ids in PA_FP_FCST_GEN_TMP1 should be updated
    --to the top task ids since the ETC should now be calculated for top tasks
    IF p_fp_cols_rec.x_fin_plan_level_code = 'T' THEN

        UPDATE pa_fp_fcst_gen_tmp1 tmp
        SET    tmp.project_element_id = (SELECT pt.top_task_id
                                         FROM   pa_tasks pt
                                         WHERE  tmp.project_element_id = pt.task_id)
        WHERE  tmp.data_type_code     = 'ETC_FP'
        AND    tmp.project_element_id
        IN
        (SELECT  pt.task_id
         FROM    pa_tasks pt
         WHERE   pt.top_task_id  IN (SELECT tmp1.task_id
                                     FROM   pa_fp_calc_amt_tmp1 tmp1
                                     WHERE  tmp1.budget_version_id =
                                            p_etc_fp_plan_version_id)
         AND     pt.task_id NOT IN (SELECT tmp1.task_id
                                    FROM   pa_fp_calc_amt_tmp1 tmp1
                                    WHERE  tmp1.budget_version_id =
                                           p_etc_fp_plan_version_id)
         AND     pt.project_id=p_project_id
         AND     pt.task_id<>pt.top_task_id
        );

    END IF;

    /* Call resource mapping API on source transaction resources.
       The planning resources from the generation source must be mapped to the
       target forecast verion resource list before calculating the ETC numbers.
       The ETC calculation is based on the rate based flag of the target
       planning resource. */

    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_CALLED_MODE       => P_CALLED_MODE,
            P_MSG               => 'Before calling pa_fp_gen_fcst_rmap_pkg.fcst_src_txns_rmap',
            P_MODULE_NAME       => l_module_name);
    END IF;
        -- hr_utility.trace('before fcst src txns rmap');
    PA_FP_GEN_FCST_RMAP_PKG.FCST_SRC_TXNS_RMAP
          (P_PROJECT_ID               => P_PROJECT_ID,
           P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
           P_FP_COLS_REC              => P_fp_cols_rec,
           X_RETURN_STATUS            => X_RETURN_STATUS,
           X_MSG_COUNT                => X_MSG_COUNT,
           X_MSG_DATA                 => X_MSG_DATA);
        -- hr_utility.trace('after fcst src txns rmap');
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_CALLED_MODE       => P_CALLED_MODE,
            P_MSG               => 'After calling pa_fp_gen_fcst_rmap_pkg.fcst_src_txns_rmap'
                                   ||x_return_status,
            P_MODULE_NAME       => l_module_name);
    END IF;
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    -- Bug 4114589: Moved from beginning of GENERATE_FCST_AMT_WRP to after
    -- resource mapping, which also calls CREATE_RES_ASG and UPDATE_RES_ASG
    -- via call to MAINTAIN_RES_ASG, so that planning dates from the source
    -- are honored when possible, since resources created by the Copy Actuals
    -- API use task/project-level default dates.
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_CALLED_MODE       => P_CALLED_MODE,
            P_MSG               => 'Before calling pa_fp_copy_actuals_pub.copy_actuals',
            P_MODULE_NAME       => l_module_name);
    END IF;
    PA_FP_COPY_ACTUALS_PUB.COPY_ACTUALS
          (P_PROJECT_ID               => P_PROJECT_ID,
           P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
           P_FP_COLS_REC              => P_fp_cols_rec,
           P_END_DATE                 => P_ACTUALS_THRU_DATE,
           P_INIT_MSG_FLAG            => 'N',
           P_COMMIT_FLAG              => 'N',
           X_RETURN_STATUS            => X_RETURN_STATUS,
           X_MSG_COUNT                => X_MSG_COUNT,
           X_MSG_DATA                 => X_MSG_DATA);
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_CALLED_MODE       => P_CALLED_MODE,
            P_MSG               => 'After calling pa_fp_copy_actuals_pub.copy_actuals:'
                                   ||x_return_status,
            P_MODULE_NAME       => l_module_name);
    END IF;
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    -- Now that we have copied the actuals, we do the delayed processing
    -- for tasks with source of Average of Actuals.
    FOR i IN 1..l_avg_actuals_task_id_tab.count LOOP
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE       => P_CALLED_MODE,
                P_MSG               => 'Before calling PA_FP_GEN_FCST_AMT_PUB.'||
                                       'GEN_AVERAGE_OF_ACTUALS_WRP',
                P_MODULE_NAME       => l_module_name);
        END IF;
        /* hr_utility.trace('Values passed to call GEN_AVERAGE_OF_ACTUALS_WRP api');
        hr_utility.trace('P_BUDGET_VERSION_ID: '||P_BUDGET_VERSION_ID);
        hr_utility.trace('l_curr_task_id: '||l_curr_task_id);
        hr_utility.trace('P_ACTUALS_THRU_DATE: '||P_ACTUALS_THRU_DATE);
        hr_utility.trace('P_ACTUALS_FROM_PERIOD: '||P_ACTUALS_FROM_PERIOD);
        hr_utility.trace('P_ACTUALS_TO_PERIOD: '||P_ACTUALS_TO_PERIOD);
        hr_utility.trace('P_ETC_FROM_PERIOD: '||P_ETC_FROM_PERIOD);
        hr_utility.trace('P_ETC_TO_PERIOD: '||P_ETC_TO_PERIOD);   */
        PA_FP_GEN_FCST_AMT_PUB1.GEN_AVERAGE_OF_ACTUALS_WRP
                (P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
                 P_TASK_ID                  => l_avg_actuals_task_id_tab(i),
                 P_ACTUALS_THRU_DATE        => P_ACTUALS_THRU_DATE,
                 P_FP_COLS_REC              => P_FP_COLS_REC,
                 P_ACTUALS_FROM_PERIOD      => P_ACTUALS_FROM_PERIOD,
                 P_ACTUALS_TO_PERIOD        => P_ACTUALS_TO_PERIOD,
                 P_ETC_FROM_PERIOD          => P_ETC_FROM_PERIOD,
                 P_ETC_TO_PERIOD            => P_ETC_TO_PERIOD,
                 X_RETURN_STATUS            => X_RETURN_STATUS,
                 X_MSG_COUNT                => X_MSG_COUNT,
                 X_MSG_DATA                 => X_MSG_DATA );
          -- hr_utility.trace('Return status after calling GEN_AVERAGE_OF_ACTUALS_WRP: '
          -- ||x_return_status);
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE       => P_CALLED_MODE,
                P_MSG               => 'After calling PA_FP_GEN_FCST_AMT_PUB.'||
                                       'GEN_AVERAGE_OF_ACTUALS_WRP: '||x_return_status,
                P_MODULE_NAME       => l_module_name);
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF p_pa_debug_mode = 'Y' THEN
                PA_DEBUG.Reset_Curr_Function;
            END IF;
            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    END LOOP;
    -- Bug 4114589: End changes.

    --dbms_output.put_line('--next, we will get all etc amts for each task');
    /***********************************************************
        *Above gets all the plan amounts for any specifc tasks
        *Below will get all the etc amounts for the tasks.
     ***********************************************************/

    /**From latest approved version, by calling gen_map_bv_to_target_rl
      *we get PA_FP_CALC_AMT_TMP3 popuated, from it, we can get the
      *baselined cost**/

    /* select count(*) into l_test from Pa_fp_CALC_AMT_TMP1;
    hr_utility.trace('fp calc amt tmp1 tab count '||l_test);
    select count(*) into l_test from Pa_fp_CALC_AMT_TMP2;
    hr_utility.trace('fp calc amt tmp2 tab count '||l_test);   */

    DELETE FROM PA_FP_CALC_AMT_TMP3;
/* the following code is commented. We are not going to use the
   baselined budget cost for ETC gen method Plan to Complete. */
    /* IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_CALLED_MODE       => P_CALLED_MODE,
            P_MSG               => 'Before calling PA_FIN_PLAN_UTILS.'||
                                   'Get_Appr_Cost_Plan_Type_Info',
            P_MODULE_NAME       => l_module_name);
    END IF;
    PA_FIN_PLAN_UTILS.Get_Appr_Cost_Plan_Type_Info(
         p_project_id               => P_PROJECT_ID,
         x_plan_type_id             => l_fin_plan_type_id,
         x_return_status            => x_return_status,
         x_msg_count                => x_msg_count,
         x_msg_data                 => x_msg_data);

    --dbms_output.put_line('l_fin_plan_type_id is '||l_fin_plan_type_id);
    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_CALLED_MODE       => P_CALLED_MODE,
            P_MSG               => 'After calling PA_FIN_PLAN_UTILS.'||
                                   'Get_Appr_Cost_Plan_Type_Info: '||x_return_status,
            P_MODULE_NAME       => l_module_name);
    END IF;
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;
    IF (l_fin_plan_type_id IS NULL) THEN
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_GENFCST_NO_COST_PTYPE');
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    SELECT DECODE( FIN_PLAN_PREFERENCE_CODE,'COST_ONLY', 'COST' ,
                   'COST_AND_REV_SEP', 'COST',
                   'COST_AND_REV_SAME', 'ALL') INTO l_version_type
    FROM pa_proj_fp_options
    WHERE fin_plan_type_id = l_fin_plan_type_id
          AND fin_plan_option_level_code = 'PLAN_TYPE'
          AND project_id = P_PROJECT_ID;

    --dbms_output.put_line('--l_version_type: '||l_version_type);
    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_CALLED_MODE       => P_CALLED_MODE,
            P_MSG               => 'Before calling PA_FP_GEN_AMOUNT_UTILS.'||
                                   'Get_Curr_Original_Version_Info',
            P_MODULE_NAME       => l_module_name);
    END IF;
    PA_FP_GEN_AMOUNT_UTILS.Get_Curr_Original_Version_Info(
          p_project_id              => P_PROJECT_ID,
          p_fin_plan_type_id        => l_fin_plan_type_id,
          p_version_type            => l_version_type,
          p_status_code             => 'CURRENT_APPROVED',
          x_fp_options_id           => l_approved_fp_options_id,
          x_fin_plan_version_id     => l_approved_fp_version_id,
          x_return_status           => x_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data);
    --dbms_output.put_line('--!after PA_FP_GEN_AMOUNT_UTILS.Get_Curr_Original_Version_Info'||x_return_status);
  --dbms_output.put_line('--l_approved_fp_version_id is:'||l_approved_fp_version_id);
    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_CALLED_MODE       => P_CALLED_MODE,
            P_MSG               => 'After calling PA_FP_GEN_AMOUNT_UTILS.'||
                                   'Get_Curr_Original_Version_Info: '||x_return_status,
            P_MODULE_NAME       => l_module_name);
    END IF;
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;
    IF (l_approved_fp_version_id IS NULL) THEN
      --dbms_output.put_line('--l_approved_fp_version_id is NULL');
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_GENFCST_NO_APPR_FPVER');
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_CALLED_MODE       => P_CALLED_MODE,
            P_MSG               => 'Before calling PA_FP_GEN_AMOUNT_UTILS.'||
                                   'GET_PLAN_VERSION_DTLS',
            P_MODULE_NAME       => l_module_name);
    END IF;
  --dbms_output.put_line('--before PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS');
    PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS(
                P_PROJECT_ID            => P_PROJECT_ID,
                P_BUDGET_VERSION_ID     => l_approved_fp_version_id,
                X_FP_COLS_REC           => l_fp_cols_rec_approved,
                X_RETURN_STATUS         => x_return_status,
                X_MSG_COUNT             => x_msg_count,
                X_MSG_DATA              => x_msg_data);
    --dbms_output.put_line('--after PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS :'||x_return_status);
    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_CALLED_MODE       => P_CALLED_MODE,
            P_MSG               => 'After calling PA_FP_GEN_AMOUNT_UTILS.'||
                                   'GET_PLAN_VERSION_DTLS: '||x_return_status,
            P_MODULE_NAME       => l_module_name);
    END IF;
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_CALLED_MODE       => P_CALLED_MODE,
            P_MSG               => 'Before calling PA_FP_MAP_BV_PUB.'||
                                   'GEN_MAP_BV_TO_TARGET_RL',
            P_MODULE_NAME       => l_module_name);
    END IF;
  --dbms_output.put_line('--before MAP_BV_TO_TARGET_RL');
--hr_utility.trace('bef call PA_FP_MAP_BV_PUB.GEN_MAP_BV_TO_TARGET_RL api');
    PA_FP_MAP_BV_PUB.GEN_MAP_BV_TO_TARGET_RL
         (P_SOURCE_BV_ID            => l_approved_fp_version_id,
          P_TARGET_FP_COLS_REC      => P_FP_COLS_REC,
          P_ETC_FP_COLS_REC         => l_fp_cols_rec_wp,
          P_CB_FP_COLS_REC          => l_fp_cols_rec_approved,
          X_RETURN_STATUS           => x_return_status,
          X_MSG_COUNT               => x_msg_count,
          X_MSG_DATA                => x_msg_data);
  --dbms_output.put_line('--PA_FP_MAP_BV_PUB.GEN_MAP_BV_TO_TARGET_RL:' ||x_return_status);
--hr_utility.trace('aft call GEN_MAP_BV_TO_TARGET_RL api:'||x_return_status);
    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_CALLED_MODE       => P_CALLED_MODE,
            P_MSG               => 'After calling PA_FP_MAP_BV_PUB.'||
                                   'GEN_MAP_BV_TO_TARGET_RL: '||x_return_status,
            P_MODULE_NAME       => l_module_name);
    END IF;
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_CALLED_MODE       => P_CALLED_MODE,
            P_MSG               => 'Before calling PA_FP_MAP_BV_PUB.'||
                                   'GEN_MAP_BV_TO_TARGET_RL(2nd time)',
            P_MODULE_NAME       => l_module_name);
    END IF;
    PA_FP_MAP_BV_PUB.GEN_MAP_BV_TO_TARGET_RL
         (P_SOURCE_BV_ID            => l_approved_fp_version_id,
          P_TARGET_FP_COLS_REC      => P_FP_COLS_REC,
          P_ETC_FP_COLS_REC         => l_fp_cols_rec_fp,
          P_CB_FP_COLS_REC          => l_fp_cols_rec_approved,
          X_RETURN_STATUS           => x_return_status,
          X_MSG_COUNT               => x_msg_count,
          X_MSG_DATA                => x_msg_data);
    --tmp3's basedline value will be used in method api
    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_CALLED_MODE       => P_CALLED_MODE,
            P_MSG               => 'After calling PA_FP_MAP_BV_PUB.'||
                                   'GEN_MAP_BV_TO_TARGET_RL:(2nd time) '||x_return_status,
            P_MODULE_NAME       => l_module_name);
    END IF;
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF; */
/*End baselined comments*/

    /* For Forecast Generation of Revenue-only plans, we should honor the
     * target's gen source code instead of the gen source codes specified
     * at the task level. */
    IF p_fp_cols_rec.x_version_type = 'REVENUE' THEN
        l_gen_etc_source_code_override := l_fcst_gen_src_code;
    ELSE
        l_gen_etc_source_code_override := NULL;
    END IF;

    --select count(*) into l_count_tmp from PA_FP_CALC_AMT_TMP1;
    --dbms_output.put_line('l_count_tmp:'||l_count_tmp);
    --hr_utility.trace('bef cursor for etc amt calc');
    OPEN traverse_tasks_rlm_cur(l_gen_etc_source_code_override);
    FETCH traverse_tasks_rlm_cur
    BULK COLLECT
    INTO  l_task_id_tab2,
          l_gen_etc_source_code_tab2,
          l_src_ra_id_tab2,
          l_tgt_ra_id_tab2,
          l_rlm_id_tab2,
          l_etc_method_tab2;
    CLOSE traverse_tasks_rlm_cur;
            /*IF p_pa_debug_mode = 'Y' THEN
                 pa_fp_gen_amount_utils.fp_debug
                (p_msg         => 'Value of l_ra_id_tab2.count: '||l_ra_id_tab2.count,
                 p_module_name => l_module_name,
                 p_log_level   => 5);
            END IF;*/
    --dbms_output.put_line('++l_ra_id_tab2.count:'||l_ra_id_tab2.count);
    --dbms_output.put_line('++l_ra_id_tab2.first:'||l_ra_id_tab2.first);
    --dbms_output.put_line('++l_ra_id_tab2.last:'||l_ra_id_tab2.last);
    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_CALLED_MODE       => P_CALLED_MODE,
            P_MSG               => 'second traverse cursor, we have how many records?'
                                   ||l_src_ra_id_tab2.count,
            P_MODULE_NAME       => l_module_name);
    END IF;

    /*Check the planning options */

    -- Bug 4369741: Initialize planning options flags to 'N'
    l_wp_planning_options_flag := 'N';
    l_fp_planning_options_flag := 'N';

    /* Bug 4369741: Call the COMPARE_ETC_SRC_TARGET_FP_OPT API separately
     * for Workplan and Financial Plan source(s) as needed and store the
     * results in l_wp_planning_options_flag and l_fp_planning_options_flag. */

    IF l_wp_version_id IS NOT NULL AND
       p_fp_cols_rec.x_gen_etc_src_code IN ('WORKPLAN_RESOURCES','TASK_LEVEL_SEL') THEN

        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE => P_CALLED_MODE,
                P_MSG  => 'Before calling PA_FP_FCST_GEN_AMT_UTILS.'||
                          'COMPARE_ETC_SRC_TARGET_FP_OPT',
                P_MODULE_NAME => l_module_name);
        END IF;
        PA_FP_FCST_GEN_AMT_UTILS.COMPARE_ETC_SRC_TARGET_FP_OPT
              (P_PROJECT_ID                     => P_PROJECT_ID,
               P_WP_SRC_PLAN_VER_ID             => l_wp_version_id,
               P_FP_SRC_PLAN_VER_ID             => NULL,                       /* Bug 4369741 */
               P_FP_TARGET_PLAN_VER_ID          => P_BUDGET_VERSION_ID,
               X_SAME_PLANNING_OPTION_FLAG      => l_wp_planning_options_flag, /* Bug 4369741 */
               X_RETURN_STATUS                  => X_RETURN_STATUS,
               X_MSG_COUNT                      => X_MSG_COUNT,
               X_MSG_DATA                       => X_MSG_DATA);
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE => P_CALLED_MODE,
                P_MSG  => 'After calling PA_FP_FCST_GEN_AMT_UTILS.'||
                          'COMPARE_ETC_SRC_TARGET_FP_OPT:'||l_wp_planning_options_flag,
                P_MODULE_NAME => l_module_name);
        END IF;
        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    END IF; -- get WP planning options flags

    IF p_etc_fp_plan_version_id IS NOT NULL AND
       p_fp_cols_rec.x_gen_etc_src_code IN ('FINANCIAL_PLAN','TASK_LEVEL_SEL') THEN

        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE => P_CALLED_MODE,
                P_MSG  => 'Before calling PA_FP_FCST_GEN_AMT_UTILS.'||
                          'COMPARE_ETC_SRC_TARGET_FP_OPT',
                P_MODULE_NAME => l_module_name);
        END IF;
        PA_FP_FCST_GEN_AMT_UTILS.COMPARE_ETC_SRC_TARGET_FP_OPT
              (P_PROJECT_ID                     => P_PROJECT_ID,
               P_WP_SRC_PLAN_VER_ID             => null,                       /* Bug 4369741 */
               P_FP_SRC_PLAN_VER_ID             => P_ETC_FP_PLAN_VERSION_ID,
               P_FP_TARGET_PLAN_VER_ID          => P_BUDGET_VERSION_ID,
               X_SAME_PLANNING_OPTION_FLAG      => l_fp_planning_options_flag, /* Bug 4369741 */
               X_RETURN_STATUS                  => X_RETURN_STATUS,
               X_MSG_COUNT                      => X_MSG_COUNT,
               X_MSG_DATA                       => X_MSG_DATA);
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE => P_CALLED_MODE,
                P_MSG  => 'After calling PA_FP_FCST_GEN_AMT_UTILS.'||
                          'COMPARE_ETC_SRC_TARGET_FP_OPT:'||l_fp_planning_options_flag,
                P_MODULE_NAME => l_module_name);
        END IF;
        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    END IF; -- get FP planning options flags


        /* hr_utility.trace('l_src_ra_id_tab2.COUNT  :'||l_src_ra_id_tab2.COUNT);
        hr_utility.trace('before for loop   :');  */

    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_CALLED_MODE => P_CALLED_MODE,
            P_MSG  => 'Before calling PA_FP_GEN_FCST_AMT_PVT.'||
                      'UPD_TGT_RATE_BASED_FLAG',
            P_MODULE_NAME => l_module_name);
    END IF;
    PA_FP_GEN_FCST_AMT_PVT.UPD_TGT_RATE_BASED_FLAG(
           P_FP_COLS_REC             => P_FP_COLS_REC,
           X_RETURN_STATUS           => x_return_status,
           X_MSG_COUNT               => x_msg_count,
           X_MSG_DATA                => x_msg_data);
    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_CALLED_MODE       => P_CALLED_MODE,
            P_MSG               => 'After calling PA_FP_GEN_FCST_AMT_PVT.'||
                                   'UPD_TGT_RATE_BASED_FLAG: '||x_return_status,
            P_MODULE_NAME       => l_module_name);
    END IF;
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    /* Initialize indices for ETC method PL/SQL tables */
    l_rb_index  := 0;
    l_bc_index := 0;
    l_ev_index  := 0;

    FOR i IN 1..l_src_ra_id_tab2.COUNT LOOP
        /*hr_utility.trace('===i===='||i);
        hr_utility.trace('task id :'||l_task_id_tab2(i));
        hr_utility.trace('rlm id :'||l_rlm_id_tab2(i));
        hr_utility.trace('src ra id :'||l_src_ra_id_tab2(i));
        hr_utility.trace('gen etc src code:'||l_gen_etc_source_code_tab2(i));
        hr_utility.trace('gen etc mtd code:'||l_etc_method_tab2(i));  */

        l_curr_task_id := l_task_id_tab2(i);
        l_curr_etc_source := l_gen_etc_source_code_tab2(i);
        l_curr_src_ra_id := l_src_ra_id_tab2(i);
        l_curr_tgt_ra_id := l_tgt_ra_id_tab2(i);
        l_curr_rlm_id := l_rlm_id_tab2(i);
        l_curr_etc_method_code := l_etc_method_tab2(i);
            /*IF p_pa_debug_mode = 'Y' THEN
                 pa_fp_gen_amount_utils.fp_debug
                (p_msg         => 'Value of l_curr_task_id: '||l_curr_task_id,
                 p_module_name => l_module_name,
                 p_log_level   => 5);
            END IF;
            IF p_pa_debug_mode = 'Y' THEN
                 pa_fp_gen_amount_utils.fp_debug
                (p_msg         => 'Value of l_curr_etc_source: '||l_curr_etc_source,
                 p_module_name => l_module_name,
                 p_log_level   => 5);
            END IF;
            IF p_pa_debug_mode = 'Y' THEN
                 pa_fp_gen_amount_utils.fp_debug
                (p_msg         => 'Value of l_curr_ra_id: '||l_curr_ra_id,
                 p_module_name => l_module_name,
                 p_log_level   => 5);
            END IF;
            IF p_pa_debug_mode = 'Y' THEN
                 pa_fp_gen_amount_utils.fp_debug
                (p_msg         => 'Value of l_curr_rlm_id: '||l_curr_rlm_id,
                 p_module_name => l_module_name,
                 p_log_level   => 5);
            END IF;
            IF p_pa_debug_mode = 'Y' THEN
                 pa_fp_gen_amount_utils.fp_debug
                (p_msg         => 'Value of l_curr_etc_method_code: '||l_curr_etc_method_code,
                 p_module_name => l_module_name,
                 p_log_level   => 5);
            END IF;*/
        --dbms_output.put_line('@l_curr_task_id:'|| l_curr_task_id);
        --dbms_output.put_line('@l_curr_etc_src:'|| l_curr_etc_source);
        --dbms_output.put_line('@l_curr_rlm_id'||l_curr_rlm_id);
        --dbms_output.put_line('@l_curr_ra_id'||l_curr_ra_id);
        --dbms_output.put_line('@l_curr_etc_method:'|| l_curr_etc_method_code);

        IF l_curr_etc_source = 'FINANCIAL_PLAN'
        OR l_curr_etc_source = 'WORKPLAN_RESOURCES' THEN

            IF l_curr_etc_method_code = 'REMAINING_BUDGET' THEN
                l_rb_index := l_rb_index + 1;
                l_rb_src_ra_id_tab(l_rb_index)  := l_curr_src_ra_id;
                l_rb_tgt_ra_id_tab(l_rb_index)  := l_curr_tgt_ra_id;
                l_rb_task_id_tab(l_rb_index)    := l_curr_task_id;
                l_rb_rlm_id_tab(l_rb_index)     := l_curr_rlm_id;
                l_rb_etc_source_tab(l_rb_index) := l_curr_etc_source;
            ELSIF l_curr_etc_method_code = 'BUDGET_TO_COMPLETE' THEN
                l_bc_index := l_bc_index + 1;
                l_bc_src_ra_id_tab(l_bc_index)  := l_curr_src_ra_id;
                l_bc_tgt_ra_id_tab(l_bc_index)  := l_curr_tgt_ra_id;
                l_bc_task_id_tab(l_bc_index)    := l_curr_task_id;
                l_bc_rlm_id_tab(l_bc_index)     := l_curr_rlm_id;
                l_bc_etc_source_tab(l_bc_index) := l_curr_etc_source;
            ELSIF l_curr_etc_method_code = 'EARNED_VALUE' THEN
                l_ev_index := l_ev_index + 1;
                l_ev_src_ra_id_tab(l_ev_index)  := l_curr_src_ra_id;
                l_ev_tgt_ra_id_tab(l_ev_index)  := l_curr_tgt_ra_id;
                l_ev_task_id_tab(l_ev_index)    := l_curr_task_id;
                l_ev_rlm_id_tab(l_ev_index)     := l_curr_rlm_id;
                l_ev_etc_source_tab(l_ev_index) := l_curr_etc_source;
            END IF;
        END IF;
    END LOOP;

    -- gboomina Bug 8318932 AAI Enhancement - Start
    OPEN get_copy_etc_from_plan_csr;
    FETCH get_copy_etc_from_plan_csr INTO l_copy_etc_from_plan_flag;
    CLOSE get_copy_etc_from_plan_csr;

    IF NVL(l_copy_etc_from_plan_flag,'N') = 'N' THEN
    -- gboomina Bug 8318932 AAI Enhancement - End

    IF l_rb_src_ra_id_tab.count > 0 THEN
        /* Bug 4369741: Pass NULL for the P_PLANNING_OPTIONS_FLAG parameter
         * to make explicit the fact that the ETC method APIs do not make
         * use of the planning options flag. All of the planning options logic
         * is present in this API itself. */
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE   => P_CALLED_MODE,
                P_MSG           => 'Before calling pa_fp_gen_fcst_amt_pub3.'||
                                   'GET_ETC_REMAIN_BDGT_AMTS_BLK',
                P_MODULE_NAME   => l_module_name);
        END IF;
        PA_FP_GEN_FCST_AMT_PUB3.GET_ETC_REMAIN_BDGT_AMTS_BLK(
            P_SRC_RES_ASG_ID_TAB            => l_rb_src_ra_id_tab,
            P_TGT_RES_ASG_ID_TAB            => l_rb_tgt_ra_id_tab,
            P_FP_COLS_SRC_REC_FP            => l_fp_cols_rec_fp,
            P_FP_COLS_SRC_REC_WP            => l_fp_cols_rec_wp,
            P_FP_COLS_TGT_REC               => P_FP_COLS_REC,
            P_TASK_ID_TAB                   => l_rb_task_id_tab,
            P_RES_LIST_MEMBER_ID_TAB        => l_rb_rlm_id_tab,
            P_ETC_SOURCE_CODE_TAB           => l_rb_etc_source_tab,
            P_WP_STRUCTURE_VERSION_ID       => P_WP_STRUCTURE_VERSION_ID,
            P_ACTUALS_THRU_DATE             => P_ACTUALS_THRU_DATE,
            P_PLANNING_OPTIONS_FLAG         => NULL,                      /* Bug 4369741 */
            X_RETURN_STATUS                 => x_return_status,
            X_MSG_COUNT                     => x_msg_count,
            X_MSG_DATA                      => x_msg_data);
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE   => P_CALLED_MODE,
                P_MSG           => 'After calling pa_fp_gen_fcst_amt_pub3.'||
                                   'GET_ETC_REMAIN_BDGT_AMTS_BLK: '||x_return_status,
                P_MODULE_NAME   => l_module_name);
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    END IF;

    IF l_bc_src_ra_id_tab.count > 0 THEN
        /* Bug 4369741: Pass NULL for the P_PLANNING_OPTIONS_FLAG parameter
         * to make explicit the fact that the ETC method APIs do not make
         * use of the planning options flag. All of the planning options logic
         * is present in this API itself. */
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE   => P_CALLED_MODE,
                P_MSG           => 'Before calling pa_fp_gen_fcst_amt_pub4.'||
                                   'GET_ETC_BDGT_COMPLETE_AMTS_BLK',
                P_MODULE_NAME   => l_module_name);
        END IF;
        PA_FP_GEN_FCST_AMT_PUB4.GET_ETC_BDGT_COMPLETE_AMTS_BLK(
            P_SRC_RES_ASG_ID_TAB            => l_bc_src_ra_id_tab,
            P_TGT_RES_ASG_ID_TAB            => l_bc_tgt_ra_id_tab,
            P_FP_COLS_SRC_REC_FP            => l_fp_cols_rec_fp,
            P_FP_COLS_SRC_REC_WP            => l_fp_cols_rec_wp,
            P_FP_COLS_TGT_REC               => P_FP_COLS_REC,
            P_TASK_ID_TAB                   => l_bc_task_id_tab,
            P_RES_LIST_MEMBER_ID_TAB        => l_bc_rlm_id_tab,
            P_ETC_SOURCE_CODE_TAB           => l_bc_etc_source_tab,
            P_WP_STRUCTURE_VERSION_ID       => P_WP_STRUCTURE_VERSION_ID,
            P_ACTUALS_THRU_DATE             => P_ACTUALS_THRU_DATE,
            P_PLANNING_OPTIONS_FLAG         => NULL,                      /* Bug 4369741 */
            X_RETURN_STATUS                 => x_return_status,
            X_MSG_COUNT                     => x_msg_count,
            X_MSG_DATA                      => x_msg_data);
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE   => P_CALLED_MODE,
                P_MSG           => 'After calling pa_fp_gen_fcst_amt_pub4.'||
                                   'GET_ETC_BDGT_COMPLETE_AMTS_BLK: '||x_return_status,
                P_MODULE_NAME   => l_module_name);
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    END IF;

    IF l_ev_src_ra_id_tab.count > 0 THEN
        /* Bug 4369741: Pass NULL for the P_PLANNING_OPTIONS_FLAG parameter
         * to make explicit the fact that the ETC method APIs do not make
         * use of the planning options flag. All of the planning options logic
         * is present in this API itself. */
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE   => P_CALLED_MODE,
                P_MSG           => 'Before calling pa_fp_gen_fcst_amt_pub5.'||
                                   'GET_ETC_EARNED_VALUE_AMTS_BLK',
                P_MODULE_NAME   => l_module_name);
        END IF;
        PA_FP_GEN_FCST_AMT_PUB5.GET_ETC_EARNED_VALUE_AMTS_BLK(
            P_SRC_RES_ASG_ID_TAB            => l_ev_src_ra_id_tab,
            P_TGT_RES_ASG_ID_TAB            => l_ev_tgt_ra_id_tab,
            P_FP_COLS_SRC_REC_FP            => l_fp_cols_rec_fp,
            P_FP_COLS_SRC_REC_WP            => l_fp_cols_rec_wp,
            P_FP_COLS_TGT_REC               => P_FP_COLS_REC,
            P_TASK_ID_TAB                   => l_ev_task_id_tab,
            P_RES_LIST_MEMBER_ID_TAB        => l_ev_rlm_id_tab,
            P_ETC_SOURCE_CODE_TAB           => l_ev_etc_source_tab,
            P_WP_STRUCTURE_VERSION_ID       => P_WP_STRUCTURE_VERSION_ID,
            P_ACTUALS_THRU_DATE             => P_ACTUALS_THRU_DATE,
            P_PLANNING_OPTIONS_FLAG         => NULL,                      /* Bug 4369741 */
            X_RETURN_STATUS                 => x_return_status,
            X_MSG_COUNT                     => x_msg_count,
            X_MSG_DATA                      => x_msg_data);
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE   => P_CALLED_MODE,
                P_MSG           => 'After calling pa_fp_gen_fcst_amt_pub5.'||
                                   'GET_ETC_EARNED_VALUE_AMTS_BLK: '||x_return_status,
                P_MODULE_NAME   => l_module_name);
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    END IF;

    IF p_fp_cols_rec.x_gen_incl_open_comm_flag = 'Y' THEN

        /* Bug 4369741: Modified parameters of GET_ETC_COMMITMENT_AMTS
         * API to reflect spec change from a single planning options
         * flag to 2 separate flags for Workplan and Financial Plan sources. */

        -- hr_utility.trace('after for loop   :');
          IF P_PA_DEBUG_MODE = 'Y' THEN
                        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                            P_CALLED_MODE   => P_CALLED_MODE,
                            P_MSG           => 'Before calling PA_FP_GEN_FCST_AMT_PUB3.'||
                                               'GET_ETC_COMMITMENT_AMTS',
                            P_MODULE_NAME   => l_module_name);
          END IF;
        -- hr_utility.trace('before pub3 cmt amts:');
          PA_FP_GEN_FCST_AMT_PUB3.GET_ETC_COMMITMENT_AMTS
          (P_FP_COLS_TGT_REC            => p_fp_cols_rec,
           P_WP_PLANNING_OPTIONS_FLAG   => l_wp_planning_options_flag,  /* Bug 4369741 */
           P_FP_PLANNING_OPTIONS_FLAG   => l_fp_planning_options_flag,  /* Bug 4369741 */
           X_RETURN_STATUS              => x_return_status,
           X_MSG_COUNT                  => x_msg_count,
           X_MSG_DATA                   => x_msg_data);

         -- hr_utility.trace('after pub3 cmt amts:');

           IF p_pa_debug_mode = 'Y' THEN
                        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                            P_CALLED_MODE   => P_CALLED_MODE,
                            P_MSG           => 'After calling PA_FP_GEN_FCST_AMT_PUB3.'||
                                               'GET_ETC_COMMITMENT_AMTS: '||x_return_status,
                            P_MODULE_NAME   => l_module_name);
           END IF;
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;
	 END IF;
       -- gboomina Bug 8318932 for AAI Enhancement - Start
       ELSE
               IF P_PA_DEBUG_MODE = 'Y' THEN
                   PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                       P_CALLED_MODE   => P_CALLED_MODE,
                       P_MSG           => 'Before calling pa_fp_gen_fcst_amt_pub3.'||
                                          'GET_ETC_FROM_SRC_BDGT',
                       P_MODULE_NAME   => l_module_name);
               END IF;
               PA_FP_GEN_FCST_AMT_PUB3.GET_ETC_FROM_SRC_BDGT(
                   P_FP_COLS_SRC_FP_REC            => l_fp_cols_rec_fp,
                   P_FP_COLS_SRC_WP_REC            => l_fp_cols_rec_wp,
                   P_FP_COLS_TGT_REC               => l_fp_cols_rec_target,
                   P_ACTUALS_THRU_DATE             => P_ACTUALS_THRU_DATE,
                   X_RETURN_STATUS                 => x_return_status,
                   X_MSG_COUNT                     => x_msg_count,
                   X_MSG_DATA                      => x_msg_data);
               IF p_pa_debug_mode = 'Y' THEN
                   PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                       P_CALLED_MODE   => P_CALLED_MODE,
                       P_MSG           => 'After calling pa_fp_gen_fcst_amt_pub3.'||
                                          'GET_ETC_FROM_SRC_BDGT: '||x_return_status,
                       P_MODULE_NAME   => l_module_name);
               END IF;
               IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
               END IF;

       END IF; -- IF l_fp_cols_rec_target.X_COPY_ETC_FROM_PLAN_FLAG
       -- gboomina Bug 8318932 for AAI Enhancement - End

    --hr_utility.trace('After processing all etc source!');
    --dbms_output.put_line('--before mapping++');
    /**After calling apis based on each res_asg_id's gen_method, we have all the plan totals and
      *ETC amounts populated in tmp2 table, now, we need to map the amounts to the target fin
      *plan's resource list, summ up, call calculate to spread into pa_budget_lines if time_phase
      *is not null, otherwise, we need to populate into pa_budget_lines by ourselves**/

    /* select count(*) into l_count_tmp from PA_FP_CALC_AMT_TMP1;
    hr_utility.trace('tmp1 count :'|| l_count_tmp);
    select count(*) into l_count_tmp from PA_FP_CALC_AMT_TMP2;
    hr_utility.trace('tmp2 count :'|| l_count_tmp);  */
    --delete from calc_amt_tmp11;
    --insert into calc_amt_tmp11 select * from pa_fp_calc_amt_tmp1;

    --select count(*) into l_count_tmp from PA_FP_CALC_AMT_TMP1;
    --hr_utility.trace('***PA_FP_CALC_AMT_TMP1.count'||l_count_tmp);
    --select count(*) into l_count_tmp from PA_FP_CALC_AMT_TMP2;
    --hr_utility.trace('**PA_FP_CALC_AMT_TMP2.count'||l_count_tmp);
    --hr_utility.trace('**P_FP_COLS_REC.X_TIME_PHASED_CODE:'||P_FP_COLS_REC.X_TIME_PHASED_CODE);

    --l_rev_gen_method := PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(p_project_id);
      l_rev_gen_method := nvl(P_FP_COLS_REC.X_REVENUE_DERIVATION_METHOD,PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(p_project_id)); --Bug 5462471
    IF l_fp_cols_rec_target.x_version_type = 'REVENUE' and l_rev_gen_method = 'C' THEN
        IF p_fp_cols_rec.X_GEN_RET_MANUAL_LINE_FLAG = 'N' THEN
            SELECT DISTINCT target_res_asg_id
            BULK COLLECT INTO l_res_asg_uom_update_tab
            FROM PA_FP_CALC_AMT_TMP2
            WHERE transaction_source_code = 'ETC';
        ELSIF p_fp_cols_rec.X_GEN_RET_MANUAL_LINE_FLAG = 'Y' THEN
            IF p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
                l_etc_start_date :=
                    PA_FP_GEN_AMOUNT_UTILS.GET_ETC_START_DATE(p_budget_version_id);

                SELECT /*+ INDEX(tmp1,PA_FP_CALC_AMT_TMP1_N1)*/
                       DISTINCT tmp1.target_res_asg_id
                BULK COLLECT
                INTO   l_res_asg_uom_update_tab
                FROM   PA_FP_CALC_AMT_TMP1 tmp1,
                       pa_resource_assignments ra
                WHERE  ra.budget_version_id = p_budget_version_id
                AND    ra.resource_assignment_id = tmp1.target_res_asg_id
                AND    ( ra.transaction_source_code IS NOT NULL
                         OR ( ra.transaction_source_code IS NULL
                              AND NOT EXISTS ( SELECT 1
                                               FROM   pa_budget_lines bl
                                               WHERE  bl.resource_assignment_id =
                                                      ra.resource_assignment_id
                                               AND    bl.start_date >= l_etc_start_date
                                               AND    rownum = 1 )))
                AND EXISTS ( SELECT /*+ INDEX(tmp2,PA_FP_CALC_AMT_TMP2_N1)*/ 1
                             FROM   PA_FP_CALC_AMT_TMP2 tmp2
                             WHERE  tmp2.target_res_asg_id = tmp1.target_res_asg_id
                             AND    tmp2.transaction_source_code = 'ETC'
                             AND    rownum = 1 );
            ELSIF p_fp_cols_rec.x_time_phased_code = 'N' THEN
                SELECT /*+ INDEX(tmp1,PA_FP_CALC_AMT_TMP1_N1)*/
                       DISTINCT tmp1.target_res_asg_id
                BULK COLLECT
                INTO   l_res_asg_uom_update_tab
                FROM   PA_FP_CALC_AMT_TMP1 tmp1,
                       pa_resource_assignments ra
                WHERE  ra.budget_version_id = p_budget_version_id
                AND    ra.resource_assignment_id = tmp1.target_res_asg_id
                AND    ( ra.transaction_source_code IS NOT NULL
                         OR ( ra.transaction_source_code IS NULL
                              AND NOT EXISTS ( SELECT 1
                                               FROM   pa_budget_lines bl
                                               WHERE  bl.resource_assignment_id =
                                                      ra.resource_assignment_id
                                               AND    NVL(bl.quantity,0) <>
                                                      NVL(bl.init_quantity,0)
                                               AND    rownum = 1 )))
                AND EXISTS ( SELECT /*+ INDEX(tmp2,PA_FP_CALC_AMT_TMP2_N1)*/ 1
                             FROM   PA_FP_CALC_AMT_TMP2 tmp2
                             WHERE  tmp2.target_res_asg_id = tmp1.target_res_asg_id
                             AND    tmp2.transaction_source_code = 'ETC'
                             AND    rownum = 1 );
            END IF; -- time phase check
        END IF;

        FORALL i IN 1..l_res_asg_uom_update_tab.count
            UPDATE pa_resource_assignments
            SET unit_of_measure = 'DOLLARS',
                rate_based_flag = 'N'
            WHERE resource_assignment_id = l_res_asg_uom_update_tab(i);
    END IF;

    l_cal_ra_id_tab.delete;
    l_cal_txn_currency_code_tab.delete;
    l_cal_unit_of_measure_tab.delete;
    l_cal_etc_qty_tab.delete;
    l_cal_etc_raw_cost_tab.delete;
    l_cal_etc_burdened_cost_tab.delete;
    l_cal_rate_based_flag_tab.delete;

    l_cal_rlm_id_tab.delete;
    l_cal_task_id_tab.delete;
    l_cal_etc_method_code_tab.delete;

    --select count(*) into l_count_tmp from PA_FP_CALC_AMT_TMP2;
    --hr_utility.trace('?????PA_FP_CALC_AMT_TMP2.count'||l_count_tmp);

    -- select count(*) into l_test from PA_FP_CALC_AMT_TMP2 where
    --          TRANSACTION_SOURCE_CODE = 'ETC';
    -- hr_utility.trace('calc amt tmp2 count with src code as ETC:'||l_test);

    IF ( l_fp_planning_options_flag = 'Y' AND
         P_FP_COLS_REC.x_gen_etc_src_code = 'FINANCIAL_PLAN' ) OR
       ( l_wp_planning_options_flag = 'Y' AND
         P_FP_COLS_REC.x_gen_etc_src_code = 'WORKPLAN_RESOURCES' ) THEN
        OPEN  etc_amts_cur_wp_fp_opt_same
            ( p_fp_cols_rec.x_gen_etc_src_code );
        FETCH etc_amts_cur_wp_fp_opt_same
        BULK COLLECT
        INTO  l_cal_src_ra_id_tab_tmp,                        /* Modified during ER 4376722 */
              l_cal_ra_id_tab_tmp,
              l_cal_txn_curr_code_tab_tmp,
              l_cal_rate_based_flag_tab_tmp,
              l_cal_rlm_id_tab_tmp,
              l_cal_task_id_tab_tmp,
              l_cal_unit_of_measure_tab_tmp,
              l_cal_etc_method_code_tab_tmp,
              l_cal_etc_qty_tab_tmp,
              l_cal_etc_raw_cost_tab_tmp,
              l_cal_etc_brdn_cost_tab_tmp,
              l_cal_etc_revenue_tab_tmp,
              l_billable_flag_tab_tmp,                        /* Added for ER 4376722 */
              l_gen_etc_src_code_tab_tmp;                     /* Added for Bug 4369741 */
        CLOSE etc_amts_cur_wp_fp_opt_same;
    ELSIF ( l_fp_planning_options_flag = 'N' AND
            P_FP_COLS_REC.x_gen_etc_src_code = 'FINANCIAL_PLAN' ) OR
          ( l_wp_planning_options_flag = 'N' AND
            P_FP_COLS_REC.x_gen_etc_src_code = 'WORKPLAN_RESOURCES' ) THEN
        OPEN  etc_amts_cur_wp_fp_opt_diff
            ( p_fp_cols_rec.x_gen_etc_src_code );
        FETCH etc_amts_cur_wp_fp_opt_diff
        BULK COLLECT
        INTO  l_cal_src_ra_id_tab_tmp,                        /* Modified during ER 4376722 */
              l_cal_ra_id_tab_tmp,
              l_cal_txn_curr_code_tab_tmp,
              l_cal_rate_based_flag_tab_tmp,
              l_cal_rlm_id_tab_tmp,
              l_cal_task_id_tab_tmp,
              l_cal_unit_of_measure_tab_tmp,
              l_cal_etc_method_code_tab_tmp,
              l_cal_etc_qty_tab_tmp,
              l_cal_etc_raw_cost_tab_tmp,
              l_cal_etc_brdn_cost_tab_tmp,
              l_cal_etc_revenue_tab_tmp,
              l_billable_flag_tab_tmp,                        /* Added for ER 4376722 */
              l_gen_etc_src_code_tab_tmp;                     /* Added for Bug 4369741 */
        CLOSE etc_amts_cur_wp_fp_opt_diff;
    ELSIF P_FP_COLS_REC.x_gen_etc_src_code = 'TASK_LEVEL_SEL' THEN
	IF l_wp_planning_options_flag = 'Y' AND
	   l_fp_planning_options_flag = 'Y' THEN
            OPEN  etc_amts_cur_wp_fp_opt_same;
            FETCH etc_amts_cur_wp_fp_opt_same
            BULK COLLECT
            INTO  l_cal_src_ra_id_tab_tmp,                        /* Modified during ER 4376722 */
                  l_cal_ra_id_tab_tmp,
                  l_cal_txn_curr_code_tab_tmp,
                  l_cal_rate_based_flag_tab_tmp,
                  l_cal_rlm_id_tab_tmp,
                  l_cal_task_id_tab_tmp,
                  l_cal_unit_of_measure_tab_tmp,
                  l_cal_etc_method_code_tab_tmp,
                  l_cal_etc_qty_tab_tmp,
                  l_cal_etc_raw_cost_tab_tmp,
                  l_cal_etc_brdn_cost_tab_tmp,
                  l_cal_etc_revenue_tab_tmp,
                  l_billable_flag_tab_tmp,                        /* Added for ER 4376722 */
                  l_gen_etc_src_code_tab_tmp;                     /* Added for Bug 4369741 */
            CLOSE etc_amts_cur_wp_fp_opt_same;
	ELSIF l_wp_planning_options_flag = 'Y' AND
	      l_fp_planning_options_flag = 'N' THEN
            OPEN  etc_amts_cur_wp_opt_same;
            FETCH etc_amts_cur_wp_opt_same
            BULK COLLECT
            INTO  l_cal_src_ra_id_tab_tmp,                        /* Modified during ER 4376722 */
                  l_cal_ra_id_tab_tmp,
                  l_cal_txn_curr_code_tab_tmp,
                  l_cal_rate_based_flag_tab_tmp,
                  l_cal_rlm_id_tab_tmp,
                  l_cal_task_id_tab_tmp,
                  l_cal_unit_of_measure_tab_tmp,
                  l_cal_etc_method_code_tab_tmp,
                  l_cal_etc_qty_tab_tmp,
                  l_cal_etc_raw_cost_tab_tmp,
                  l_cal_etc_brdn_cost_tab_tmp,
                  l_cal_etc_revenue_tab_tmp,
                  l_billable_flag_tab_tmp,                        /* Added for ER 4376722 */
                  l_gen_etc_src_code_tab_tmp;                     /* Added for Bug 4369741 */
            CLOSE etc_amts_cur_wp_opt_same;
	ELSIF l_wp_planning_options_flag = 'N' AND
	      l_fp_planning_options_flag = 'Y' THEN
            OPEN  etc_amts_cur_fp_opt_same;
            FETCH etc_amts_cur_fp_opt_same
            BULK COLLECT
            INTO  l_cal_src_ra_id_tab_tmp,                        /* Modified during ER 4376722 */
                  l_cal_ra_id_tab_tmp,
                  l_cal_txn_curr_code_tab_tmp,
                  l_cal_rate_based_flag_tab_tmp,
                  l_cal_rlm_id_tab_tmp,
                  l_cal_task_id_tab_tmp,
                  l_cal_unit_of_measure_tab_tmp,
                  l_cal_etc_method_code_tab_tmp,
                  l_cal_etc_qty_tab_tmp,
                  l_cal_etc_raw_cost_tab_tmp,
                  l_cal_etc_brdn_cost_tab_tmp,
                  l_cal_etc_revenue_tab_tmp,
                  l_billable_flag_tab_tmp,                        /* Added for ER 4376722 */
                  l_gen_etc_src_code_tab_tmp;                     /* Added for Bug 4369741 */
            CLOSE etc_amts_cur_fp_opt_same;
	ELSIF l_wp_planning_options_flag = 'N' AND
	      l_fp_planning_options_flag = 'N' THEN
            OPEN  etc_amts_cur_wp_fp_opt_diff;
            FETCH etc_amts_cur_wp_fp_opt_diff
            BULK COLLECT
            INTO  l_cal_src_ra_id_tab_tmp,                        /* Modified during ER 4376722 */
                  l_cal_ra_id_tab_tmp,
                  l_cal_txn_curr_code_tab_tmp,
                  l_cal_rate_based_flag_tab_tmp,
                  l_cal_rlm_id_tab_tmp,
                  l_cal_task_id_tab_tmp,
                  l_cal_unit_of_measure_tab_tmp,
                  l_cal_etc_method_code_tab_tmp,
                  l_cal_etc_qty_tab_tmp,
                  l_cal_etc_raw_cost_tab_tmp,
                  l_cal_etc_brdn_cost_tab_tmp,
                  l_cal_etc_revenue_tab_tmp,
                  l_billable_flag_tab_tmp,                        /* Added for ER 4376722 */
                  l_gen_etc_src_code_tab_tmp;                     /* Added for Bug 4369741 */
            CLOSE etc_amts_cur_wp_fp_opt_diff;
        END IF;
    ELSE
        -- error handling code stub
        l_dummy := 1;
    END IF; -- fetch ETC data
    --hr_utility.trace('????l_cal_ra_id_tab.count:'||l_cal_ra_id_tab.count);


IF p_fp_cols_rec.x_gen_ret_manual_line_flag = 'Y' THEN

    FOR i in 1..l_cal_ra_id_tab_tmp.count LOOP
        SELECT transaction_source_code
        INTO l_ra_txn_source_code
        FROM pa_resource_assignments
        WHERE resource_assignment_id = l_cal_ra_id_tab_tmp(i);

        l_bl_count := 0;

        -- Bug 4301959: Modified the Retain Manually Added Lines logic to
        -- handle the non-time phased case separately, using the (quantity <>
        -- actual quantity) check instead of (start_date > etc_start_date).

        IF l_ra_txn_source_code IS NULL THEN
            IF p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
                SELECT count(*)
                INTO   l_bl_count
                FROM   pa_budget_lines
                WHERE  resource_assignment_id = l_cal_ra_id_tab_tmp(i)
                AND    start_date > p_actuals_thru_date;
            ELSIF p_fp_cols_rec.x_time_phased_code = 'N' THEN
                SELECT count(*)
                INTO   l_bl_count
                FROM   pa_budget_lines
                WHERE  resource_assignment_id = l_cal_ra_id_tab_tmp(i)
                AND    NVL(quantity,0) <> NVL(init_quantity,0);
            END IF;
        END IF;

          /* hr_utility.trace('blines count for res asg id '||
              l_bl_count  || '   for res asg '||l_cal_ra_id_tab_tmp(i));  */

        /* modified the logic for handling retain manually added lines
           for bug 3968630. If the txn source code for the planning resource is
           not null (generated - not manually entered), then the existing
           plan lines should be deleted and amounts should be generated from the
           generation source. */

            IF ( l_ra_txn_source_code IS NULL AND l_bl_count > 0 ) THEN
                /* Mannually entered lines do exist, so they will be honored,
                   source records will be dropped */
                l_dummy := 1;
            ELSE
                /* Mannually entered lines don't exist, so source records will
                   be honored */
                -- gboomina Bug 8318932 for AAI Enhancement - Start
                -- Avoiding the deletion of budget lines created when l_copy_etc_from_plan_flag is checked
                IF (p_fp_cols_rec.x_time_phased_code = 'P'
                   OR p_fp_cols_rec.x_time_phased_code = 'G')
                   AND NVL(l_copy_etc_from_plan_flag,'N') = 'N' THEN
                    DELETE FROM pa_budget_lines
                    WHERE resource_assignment_id = l_cal_ra_id_tab_tmp(i)
                      AND start_date > p_actuals_thru_date;
                END IF;
                -- gboomina Bug 8318932 for AAI Enhancement - End
                -- hr_utility.trace('inside table population ');

                l_cal_ra_id_tab.EXTEND;
                l_cal_txn_currency_code_tab.EXTEND;
                l_cal_rate_based_flag_tab.EXTEND;
                l_cal_rlm_id_tab.EXTEND;
                l_cal_task_id_tab.EXTEND;
                l_cal_unit_of_measure_tab.EXTEND;
                l_cal_etc_method_code_tab.EXTEND;
                l_cal_etc_qty_tab.EXTEND;
                l_cal_etc_raw_cost_tab.EXTEND;
                l_cal_etc_burdened_cost_tab.EXTEND;
                l_cal_etc_revenue_tab.EXTEND;
                l_billable_flag_tab.EXTEND;  /* Added for ER 4376722 */
                l_cal_src_ra_id_tab.EXTEND;  /* Modified during ER 4376722 */
                l_gen_etc_src_code_tab.EXTEND; /* Added for Bug 4369741 */

                l_cal_ra_id_tab(l_cnt) := l_cal_ra_id_tab_tmp(i);
                l_cal_txn_currency_code_tab(l_cnt) := l_cal_txn_curr_code_tab_tmp(i);
                l_cal_rate_based_flag_tab(l_cnt) := l_cal_rate_based_flag_tab_tmp(i);
                l_cal_rlm_id_tab(l_cnt) := l_cal_rlm_id_tab_tmp(i);
                l_cal_task_id_tab(l_cnt) := l_cal_task_id_tab_tmp(i);
                l_cal_unit_of_measure_tab(l_cnt) := l_cal_unit_of_measure_tab_tmp(i);
                l_cal_etc_method_code_tab(l_cnt) := l_cal_etc_method_code_tab_tmp(i);
                l_cal_etc_qty_tab(l_cnt) := l_cal_etc_qty_tab_tmp(i);
                l_cal_etc_raw_cost_tab(l_cnt) := l_cal_etc_raw_cost_tab_tmp(i);
                l_cal_etc_burdened_cost_tab(l_cnt) := l_cal_etc_brdn_cost_tab_tmp(i);
                l_cal_etc_revenue_tab(l_cnt) := l_cal_etc_revenue_tab_tmp(i);
                l_billable_flag_tab(l_cnt) := l_billable_flag_tab_tmp(i); /* Added for ER 4376722 */
                l_cal_src_ra_id_tab(l_cnt) := l_cal_src_ra_id_tab_tmp(i); /* Modified during ER 4376722 */
                l_gen_etc_src_code_tab(l_cnt) := l_gen_etc_src_code_tab_tmp(i); /* Added for Bug 4369741 */

                l_cnt := l_cnt + 1;
            END IF;
    END LOOP;
        -- hr_utility.trace('after the for loop for calc api ');
    /* End the logic to handle mannually updated lines*/

ELSE

                l_cal_ra_id_tab := l_cal_ra_id_tab_tmp;
                l_cal_txn_currency_code_tab := l_cal_txn_curr_code_tab_tmp;
                l_cal_rate_based_flag_tab := l_cal_rate_based_flag_tab_tmp;
                l_cal_rlm_id_tab := l_cal_rlm_id_tab_tmp;
                l_cal_task_id_tab := l_cal_task_id_tab_tmp;
                l_cal_unit_of_measure_tab := l_cal_unit_of_measure_tab_tmp;
                l_cal_etc_method_code_tab := l_cal_etc_method_code_tab_tmp;
                l_cal_etc_qty_tab := l_cal_etc_qty_tab_tmp;
                l_cal_etc_raw_cost_tab := l_cal_etc_raw_cost_tab_tmp;
                l_cal_etc_burdened_cost_tab := l_cal_etc_brdn_cost_tab_tmp;
                l_cal_etc_revenue_tab := l_cal_etc_revenue_tab_tmp;
                l_billable_flag_tab := l_billable_flag_tab_tmp; /* Added for ER 4376722 */
                l_cal_src_ra_id_tab := l_cal_src_ra_id_tab_tmp; /* Modified during ER 4376722 */
                l_gen_etc_src_code_tab := l_gen_etc_src_code_tab_tmp; /* Added for Bug 4369741 */

END IF; -- manual lines condition


    -- IPM: New Entity ER ------------------------------------------
    IF l_fp_planning_options_flag = 'Y' OR
       l_wp_planning_options_flag = 'Y' THEN

        -- Sort resource assignment ids into two pl/sql tables
        -- based on whether the ETC generation source is FP or WP.
        -- Also, track non-billable resources whose source is FP.
        FOR i IN 1..l_cal_ra_id_tab.count LOOP
            IF l_gen_etc_src_code_tab(i) = 'FINANCIAL_PLAN' THEN
                l_fp_ra_id_tab.EXTEND;
                l_fp_ra_id_tab(l_fp_ra_id_tab.count) := l_cal_ra_id_tab(i);

                IF l_billable_flag_tab(i) = 'N' THEN
                    l_non_billable_fp_ra_id_tab.EXTEND;
                    l_non_billable_fp_ra_id_tab(l_non_billable_fp_ra_id_tab.count)
                        := l_cal_ra_id_tab(i);
                END IF;
            ELSIF l_gen_etc_src_code_tab(i) = 'WORKPLAN_RESOURCES' THEN
                l_wp_ra_id_tab.EXTEND;
                l_wp_ra_id_tab(l_wp_ra_id_tab.count) := l_cal_ra_id_tab(i);
            END IF;
        END LOOP;

        -- Index 1 stores Financial Plan data.
        l_ra_id_tab_table(1) := l_fp_ra_id_tab;
        l_planning_options_flag_tab(1) := l_fp_planning_options_flag;
        l_src_version_id_tab(1) := p_etc_fp_plan_version_id;

        -- Index 2 stores Workplan data.
        l_ra_id_tab_table(2) := l_wp_ra_id_tab;
        l_planning_options_flag_tab(2) := l_wp_planning_options_flag;
        l_src_version_id_tab(2) := l_wp_version_id;

        FOR i IN 1..l_ra_id_tab_table.count LOOP

            IF l_ra_id_tab_table(i).count > 0 AND
               l_planning_options_flag_tab(i) = 'Y' THEN

                DELETE pa_resource_asgn_curr_tmp;

                -- As per the copy_table_records API specification, when calling the
                -- maintenance API in temp table Copy mode, populate the temp table
                -- with distinct target ra_id values (without txn_currency_code values).

                INSERT INTO pa_resource_asgn_curr_tmp
                    ( resource_assignment_id )
                SELECT DISTINCT column_value
                FROM TABLE( CAST( l_ra_id_tab_table(i) AS SYSTEM.pa_num_tbl_type ));

                -- Call the maintenance api in COPY mode
                IF p_pa_debug_mode = 'Y' THEN
                    PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                        P_MSG                   => 'Before calling PA_RES_ASG_CURRENCY_PUB.' ||
                                                   'MAINTAIN_DATA',
                        P_CALLED_MODE           => p_called_mode,
                        P_MODULE_NAME           => l_module_name);
                END IF;
                PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA
                      ( P_FP_COLS_REC           => l_fp_cols_rec_target,
                        P_CALLING_MODULE        => 'FORECAST_GENERATION',
                        P_COPY_FLAG             => 'Y',
                        P_SRC_VERSION_ID        => l_src_version_id_tab(i),
                        P_COPY_MODE             => 'COPY_OVERRIDES',
                        P_VERSION_LEVEL_FLAG    => 'N',
                        P_CALLED_MODE           => p_called_mode,
                        X_RETURN_STATUS         => x_return_status,
                        X_MSG_COUNT             => x_msg_count,
                        X_MSG_DATA              => x_msg_data );
                IF p_pa_debug_mode = 'Y' THEN
                    PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                        P_MSG                   => 'After calling PA_RES_ASG_CURRENCY_PUB.' ||
                                                   'MAINTAIN_DATA: '||x_return_status,
                        P_CALLED_MODE           => p_called_mode,
                        P_MODULE_NAME           => l_module_name);
                END IF;
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;
            END IF; -- planning options flag check
        END LOOP; -- FOR i IN 1..l_ra_id_tab_table.count LOOP

        -- Ensure that non-billable tasks do not have bill rate overrides
        -- in the new entity table by re-Inserting new entity records with
        -- existing cost rate overrides but Null bill rate overrides for
        -- non-billable tasks.
        -- Note: Processing resources with Workplan as the source is not
        -- required since workplans are guaranteed to store only costs.

        IF l_fp_planning_options_flag = 'Y' AND
           l_non_billable_fp_ra_id_tab.count > 0 AND
           l_fp_cols_rec_fp.x_version_type = 'ALL' AND
           l_fp_cols_rec_target.x_version_type IN ('REVENUE','ALL') THEN

            DELETE pa_resource_asgn_curr_tmp;

	    -- Note: An outer join on pa_tasks is not needed in the query
	    -- below because we are only interested in updating resources
	    -- for non-billable tasks. Project-level tasks that require an
	    -- outer join are always billable.
	    INSERT INTO pa_resource_asgn_curr_tmp
	        ( RESOURCE_ASSIGNMENT_ID,
	          TXN_CURRENCY_CODE,
	          TXN_RAW_COST_RATE_OVERRIDE,
	          TXN_BURDEN_COST_RATE_OVERRIDE )
	    SELECT rbc.resource_assignment_id,
	           rbc.txn_currency_code,
	           rbc.txn_raw_cost_rate_override,
	           rbc.txn_burden_cost_rate_override
	    FROM   pa_resource_asgn_curr rbc
	    WHERE  rbc.budget_version_id = p_budget_version_id
	    AND    rbc.txn_bill_rate_override IS NOT NULL
	    AND EXISTS ( SELECT null
	                 FROM   TABLE(CAST( l_non_billable_fp_ra_id_tab AS SYSTEM.pa_num_tbl_type ))
	                 WHERE  rbc.resource_assignment_id = column_value );

            l_count := SQL%ROWCOUNT;

            IF l_count > 0 THEN
                -- CALL the maintenance api in INSERT mode
                IF p_pa_debug_mode = 'Y' THEN
                    PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                        P_MSG                   => 'Before calling PA_RES_ASG_CURRENCY_PUB.' ||
                                                   'MAINTAIN_DATA',
                        P_CALLED_MODE           => p_called_mode,
                        P_MODULE_NAME           => l_module_name);
                END IF;
                PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA
                      ( P_FP_COLS_REC           => l_fp_cols_rec_target,
                        P_CALLING_MODULE        => 'FORECAST_GENERATION',
                        P_VERSION_LEVEL_FLAG    => 'N',
                        P_ROLLUP_FLAG           => 'N', -- 'N' indicates Insert
                        P_CALLED_MODE           => p_called_mode,
                        X_RETURN_STATUS         => x_return_status,
                        X_MSG_COUNT             => x_msg_count,
                        X_MSG_DATA              => x_msg_data );
                IF p_pa_debug_mode = 'Y' THEN
                    PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                        P_MSG                   => 'After calling PA_RES_ASG_CURRENCY_PUB.' ||
                                                   'MAINTAIN_DATA: '||x_return_status,
                        P_CALLED_MODE           => p_called_mode,
                        P_MODULE_NAME           => l_module_name);
                END IF;
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;
            END IF; -- IF l_count > 0 THEN
        END IF; -- logic to null out bill rate overrides for non-billable tasks

    END IF; -- logic to copy source pa_resource_asgn_curr overrides
    -- END OF IPM: New Entity ER ------------------------------------------


    IF l_fp_cols_rec_target.x_version_type = 'REVENUE' and l_rev_gen_method = 'C' THEN
        l_cal_etc_revenue_tab := l_cal_etc_burdened_cost_tab;
    END IF;
             /*IF p_pa_debug_mode = 'Y' THEN
                 pa_fp_gen_amount_utils.fp_debug
                (p_msg         => 'Value of l_rev_gen_method: '||l_rev_gen_method,
                 p_module_name => l_module_name,
                 p_log_level   => 5);
            END IF;
             IF p_pa_debug_mode = 'Y' THEN
                 pa_fp_gen_amount_utils.fp_debug
                (p_msg         => 'Value of l_cal_etc_revenue_tab.count: '||l_cal_etc_revenue_tab.count,
                 p_module_name => l_module_name,
                 p_log_level   => 5);
            END IF;
             IF p_pa_debug_mode = 'Y' THEN
                 pa_fp_gen_amount_utils.fp_debug
                (p_msg         => 'Value of l_cal_ra_id_tab.count: '||l_cal_ra_id_tab.count,
                 p_module_name => l_module_name,
                 p_log_level   => 5);
            END IF;*/
     -- hr_utility.trace('==Before calling calculate api in the loop');
     -- hr_utility.trace('==l_cal_ra_id tab count bef calculate api '||l_cal_ra_id_tab.count);


    /* ER 4376722: When the Target is a Revenue-only Forecast, we do not
     * generate quantity or amounts for non-rate-based resources of
     * non-billable tasks. The simple algorithm to do this is as follows:
     *
     * 0. Clear out any data in the _tmp tables.
     * 1. Copy records for
     *    a) billable tasks
     *    b) rate-based resources of non-billable tasks
     *       into _tmp tables.
     * 2. Copy records from _tmp tables back to non-temporary tables.
     *
     * The result is that we do not process records for non-rate-based
     * resources of non-billable task afterwards. Hence, quantity and
     * amounts for these resources will not be generated. */

    IF l_fp_cols_rec_target.x_version_type = 'REVENUE' THEN

        -- 0. Clear out any data in the _tmp tables.
        l_cal_src_ra_id_tab_tmp.delete;
        l_cal_ra_id_tab_tmp.delete;
        l_cal_txn_curr_code_tab_tmp.delete;
        l_cal_rate_based_flag_tab_tmp.delete;
        l_cal_rlm_id_tab_tmp.delete;
        l_cal_task_id_tab_tmp.delete;
        l_cal_unit_of_measure_tab_tmp.delete;
        l_cal_etc_method_code_tab_tmp.delete;
        l_cal_etc_qty_tab_tmp.delete;
        l_cal_etc_raw_cost_tab_tmp.delete;
        l_cal_etc_brdn_cost_tab_tmp.delete;
        l_cal_etc_revenue_tab_tmp.delete;
        l_billable_flag_tab_tmp.delete;

        -- 1. Copy records for billable tasks into _tmp tables.
        l_tmp_index := 0;
        FOR i IN 1..l_cal_ra_id_tab.count LOOP
            IF l_billable_flag_tab(i) = 'Y' OR
              (l_billable_flag_tab(i) = 'N' AND
               l_cal_rate_based_flag_tab(i) = 'Y') THEN

                l_cal_src_ra_id_tab_tmp.extend;
                l_cal_ra_id_tab_tmp.extend;
                l_cal_txn_curr_code_tab_tmp.extend;
                l_cal_rate_based_flag_tab_tmp.extend;
                l_cal_rlm_id_tab_tmp.extend;
                l_cal_task_id_tab_tmp.extend;
                l_cal_unit_of_measure_tab_tmp.extend;
                l_cal_etc_method_code_tab_tmp.extend;
                l_cal_etc_qty_tab_tmp.extend;
                l_cal_etc_raw_cost_tab_tmp.extend;
                l_cal_etc_brdn_cost_tab_tmp.extend;
                l_cal_etc_revenue_tab_tmp.extend;
                l_billable_flag_tab_tmp.extend;

                l_tmp_index := l_tmp_index + 1;
                l_cal_src_ra_id_tab_tmp(l_tmp_index)       := l_cal_src_ra_id_tab(i);
                l_cal_ra_id_tab_tmp(l_tmp_index)           := l_cal_ra_id_tab(i);
                l_cal_txn_curr_code_tab_tmp(l_tmp_index)   := l_cal_txn_currency_code_tab(i);
                l_cal_rate_based_flag_tab_tmp(l_tmp_index) := l_cal_rate_based_flag_tab(i);
                l_cal_rlm_id_tab_tmp(l_tmp_index)          := l_cal_rlm_id_tab(i);
                l_cal_task_id_tab_tmp(l_tmp_index)         := l_cal_task_id_tab(i);
                l_cal_unit_of_measure_tab_tmp(l_tmp_index) := l_cal_unit_of_measure_tab(i);
                l_cal_etc_method_code_tab_tmp(l_tmp_index) := l_cal_etc_method_code_tab(i);
                l_cal_etc_qty_tab_tmp(l_tmp_index)         := l_cal_etc_qty_tab(i);
                l_cal_etc_raw_cost_tab_tmp(l_tmp_index)    := l_cal_etc_raw_cost_tab(i);
                l_cal_etc_brdn_cost_tab_tmp(l_tmp_index)   := l_cal_etc_burdened_cost_tab(i);
                l_cal_etc_revenue_tab_tmp(l_tmp_index)     := l_cal_etc_revenue_tab(i);
                l_billable_flag_tab_tmp(l_tmp_index)       := l_billable_flag_tab(i);
            END IF;
        END LOOP;

        -- 2. Copy records from _tmp_ tables back to non-temporary tables.
        l_cal_src_ra_id_tab         := l_cal_src_ra_id_tab_tmp;
        l_cal_ra_id_tab             := l_cal_ra_id_tab_tmp;
        l_cal_txn_currency_code_tab := l_cal_txn_curr_code_tab_tmp;
        l_cal_rate_based_flag_tab   := l_cal_rate_based_flag_tab_tmp;
        l_cal_rlm_id_tab            := l_cal_rlm_id_tab_tmp;
        l_cal_task_id_tab           := l_cal_task_id_tab_tmp;
        l_cal_unit_of_measure_tab   := l_cal_unit_of_measure_tab_tmp;
        l_cal_etc_method_code_tab   := l_cal_etc_method_code_tab_tmp;
        l_cal_etc_qty_tab           := l_cal_etc_qty_tab_tmp;
        l_cal_etc_raw_cost_tab      := l_cal_etc_raw_cost_tab_tmp;
        l_cal_etc_burdened_cost_tab := l_cal_etc_brdn_cost_tab_tmp;
        l_cal_etc_revenue_tab       := l_cal_etc_revenue_tab_tmp;
        l_billable_flag_tab         := l_billable_flag_tab_tmp;

    END IF; -- ER 4376722 billability logic for REVENUE Forecast

    -- Initialize l_remove_record_flag
    l_remove_records_flag := 'N';

    -- Initialize l_remove_record_flag_tab
    FOR i IN 1..l_cal_ra_id_tab.count LOOP
        l_remove_record_flag_tab(i) := 'N';
    END LOOP;

    -- Initialize l_source_version_type_tab
    -- Initialize l_rev_only_src_txn_flag_tab
    FOR i IN 1..l_cal_ra_id_tab.count LOOP

        IF l_gen_etc_src_code_tab(i) = 'FINANCIAL_PLAN' THEN
            l_source_version_type_tab(i) := l_fp_cols_rec_fp.x_version_type;
        ELSIF l_gen_etc_src_code_tab(i) IN ('WORKPLAN_RESOURCES','WORK_QUANTITY') THEN
            l_source_version_type_tab(i) := l_fp_cols_rec_wp.x_version_type;
        ELSE -- l_gen_etc_src_code_tab(i) = 'NONE'
            l_source_version_type_tab(i) := null;
        END IF;

        l_rev_only_src_txn_flag_tab(i) := 'N';

        -- NOTE: Generation from Revenue-only versions not supported.
        -- This case has been added in case of future changes.
        IF l_source_version_type_tab(i) = 'REVENUE' OR
         ( l_source_version_type_tab(i) = 'ALL' AND
           nvl(l_cal_etc_raw_cost_tab(i),0) = 0 ) THEN
            l_rev_only_src_txn_flag_tab(i) := 'Y';
        END IF;
    END LOOP;

    l_target_version_type := l_fp_cols_rec_target.x_version_type;

    -- Added for IPM :
    -- This loop processes each planning txn, based on the source/target
    -- version type combination, and does the following:
    -- 1. Updates l_remove_record_flag_tab

    FOR i in 1..l_cal_ra_id_tab.count LOOP

        -- 1. Update l_remove_record_flag_tab based on source/target version types.
        IF l_source_version_type_tab(i) = 'ALL' AND l_target_version_type = 'COST' THEN
            IF l_cal_rate_based_flag_tab(i) = 'N' THEN
                IF l_rev_only_src_txn_flag_tab(i) = 'Y' THEN
                    l_remove_record_flag_tab(i) := 'Y';
                    l_remove_records_flag := 'Y';
                END IF;
            END IF;
        ELSIF l_source_version_type_tab(i) = 'ALL' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'T' THEN
            -- Set quantity to revenue in the main processing loop later.
            -- Do nothing for now.
            l_dummy := 1;
        ELSIF l_source_version_type_tab(i) = 'ALL' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'C' THEN
            IF l_cal_rate_based_flag_tab(i) = 'N' THEN
                IF l_rev_only_src_txn_flag_tab(i) = 'Y' THEN
                    l_remove_record_flag_tab(i) := 'Y';
                    l_remove_records_flag := 'Y';
                END IF;
            END IF;
        ELSIF l_source_version_type_tab(i) = 'ALL' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'E' THEN
            /*Revenue is only based on billing events, which is handled seperately*/
            l_dummy := 1;
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.RESET_CURR_FUNCTION;
            END IF;
            RETURN;
        ELSIF l_source_version_type_tab(i) = 'ALL' AND
              l_target_version_type = 'ALL' AND
              l_rev_gen_method = 'T' THEN
            -- Set quantity to revenue in the main processing loop later.
            -- Do nothing for now.
            l_dummy := 1;
        ELSIF l_source_version_type_tab(i) = 'ALL' AND
              l_target_version_type = 'ALL' AND
              l_rev_gen_method = 'C' THEN
            IF l_cal_rate_based_flag_tab(i) = 'N' THEN
                IF l_rev_only_src_txn_flag_tab(i) = 'Y' THEN
                    l_remove_record_flag_tab(i) := 'Y';
                    l_remove_records_flag := 'Y';
                END IF;
            END IF;
        ELSIF l_source_version_type_tab(i) = 'ALL' AND
              l_target_version_type = 'ALL' AND
              l_rev_gen_method = 'E' THEN
            IF l_cal_rate_based_flag_tab(i) = 'N' THEN
                IF l_rev_only_src_txn_flag_tab(i) = 'Y' THEN
                    l_remove_record_flag_tab(i) := 'Y';
                    l_remove_records_flag := 'Y';
                END IF;
            END IF;
        END IF;

    END LOOP; -- IPM filtering logic

    -- Added for IPM : In a Cost and Revenue Together version,
    -- if a non-billable, non-rate-based planning txn has only
    -- ETC revenue amounts, then filter out the record as if the
    -- Target were a Revenue-only version.

    IF l_target_version_type = 'ALL' THEN
        FOR i IN 1..l_cal_ra_id_tab.count LOOP
            IF l_billable_flag_tab(i) = 'N' AND
               l_rev_only_src_txn_flag_tab(i) = 'Y' AND
               l_cal_rate_based_flag_tab(i) = 'N' THEN
                l_remove_record_flag_tab(i) := 'Y';
                l_remove_records_flag := 'Y';
            END IF;
        END LOOP;
    END IF; -- Added billability logic for ALL versions in IPM

    -- Added for IPM : Properly size pl/sql system tables
    -- outside of the loop so that skipping records using
    -- the continue_loop exception does not throw the loop
    -- iterator and table sizes out of sync.

    IF l_cal_ra_id_tab.count > 0 THEN
        l_cal_rcost_rate_override_tab.extend(l_cal_ra_id_tab.count);
        l_cal_bcost_rate_override_tab.extend(l_cal_ra_id_tab.count);
        l_cal_bill_rate_override_tab.extend(l_cal_ra_id_tab.count);
    END IF;

    FOR i in 1..l_cal_ra_id_tab.count LOOP
    BEGIN

        -- Added in IPM:
        -- Before processing the current planning txn, check if the
        -- record should be skipped. If so, continue with next record.
        IF l_remove_record_flag_tab(i) = 'Y' THEN
            RAISE continue_loop;
        END IF;

        -- Bug 4346172: In general, when source/target planning options match,
        -- we use the source version's periodic planning rates to calculate the
        -- amounts. However, when the ETC method is Earned Value, we honor the
        -- actuals rates. The l_use_src_rates_flag captures this information.

        -- Bug 4369741: Extended IF condition logic to set l_use_src_rates_flag
        -- based on 2 separate planning options flags (for WP and FP) and the
        -- ETC generation source stored in l_gen_etc_src_code_tab.

        IF l_cal_etc_method_code_tab(i) <> 'EARNED_VALUE' AND
           (( l_fp_planning_options_flag = 'Y' AND
              l_gen_etc_src_code_tab(i) = 'FINANCIAL_PLAN' ) OR
            ( l_wp_planning_options_flag = 'Y' AND
              l_gen_etc_src_code_tab(i) = 'WORKPLAN_RESOURCES' )) THEN
	    l_use_src_rates_flag := 'Y';
        ELSE
	    l_use_src_rates_flag := 'N';
	END IF;


        IF l_cal_rate_based_flag_tab(i) = 'N' THEN
            -- Bug 4232094, 4232253: For Cost-based Revenue generation, quantity should
            -- equal burdened cost. We make use of this modified l_cal_etc_qty_tab later
            -- for another part of the bug fix.
            IF l_fp_cols_rec_target.x_version_type = 'REVENUE' and l_rev_gen_method = 'C' THEN
                -- IPM : Earlier, the code checks if cost amounts exists and
                -- skips processing if they do not exist. Hence, the assignment
                -- below should only be reached when it makes sense to do so.
                l_cal_etc_qty_tab(i) := l_cal_etc_burdened_cost_tab(i);
            ELSE
                -- IPM : When only revenue amounts exist, quantity should equal revenue
                -- for non-rate-based transactions. Based on record filtering logic
                -- upstream, this should only happen under the following conditions:
                -- * Source is an 'ALL' version
                -- * Target is either a 'REVENUE' or 'ALL' version
                -- * Revenue accrual method is 'T' (work-based)
                IF l_rev_only_src_txn_flag_tab(i) = 'Y' THEN
                    l_cal_etc_qty_tab(i) := l_cal_etc_revenue_tab(i);
                ELSE
                    l_cal_etc_qty_tab(i) := l_cal_etc_raw_cost_tab(i);
                END IF;

            END IF;
        END IF;

         -- hr_utility.trace('==inside the loop for calling calcualte   ');

        -- Modified for IPM : Instead of extending the table size by 1 on
        -- each loop iteration, we now extend all at once before the loop.
        --l_cal_rcost_rate_override_tab.extend;
        --l_cal_bcost_rate_override_tab.extend;

        -- ER 5726773: Instead of requiring l_cal_etc_qty_tab(i) be positive,
 	-- relax the condition to ensure it is non-zero.
 	IF l_cal_etc_qty_tab(i) <> 0 THEN
            l_cal_rcost_rate_override_tab(i) := l_cal_etc_raw_cost_tab(i)/l_cal_etc_qty_tab(i);
            l_cal_bcost_rate_override_tab(i) := l_cal_etc_burdened_cost_tab(i)/l_cal_etc_qty_tab(i);
        ELSE
            l_cal_rcost_rate_override_tab(i) := NULL;
            l_cal_bcost_rate_override_tab(i) := NULL;
        END IF;
        -- Modified for IPM : Instead of extending the table size by 1 on
        -- each loop iteration, we now extend all at once before the loop.
        --l_cal_bill_rate_override_tab.extend;
        l_cal_bill_rate_override_tab(i) := NULL;
        IF l_fp_cols_rec_target.x_version_type = 'REVENUE' and l_rev_gen_method = 'C' THEN
            l_cal_bill_rate_override_tab(i) :=  l_cal_bcost_rate_override_tab(i);
            l_cal_etc_raw_cost_tab(i) := NULL;
            l_cal_etc_burdened_cost_tab(i) := NULL;
            l_cal_rcost_rate_override_tab(i) := NULL;
            l_cal_bcost_rate_override_tab(i) := NULL;
        END IF;

        -- Added in IPM :
        -- For the case given below, set bill rate override to 1
        -- so that revenue will equal quantity (and not be rederived).
        -- If the target is an ALL version, then also set the
        -- cost rate overrides to 0 so the Calculate API does not
        -- default them to 1 and then compute cost amounts.

        IF l_rev_only_src_txn_flag_tab(i) = 'Y' AND
           l_cal_rate_based_flag_tab(i) = 'N' AND
           l_target_version_type IN ('REVENUE','ALL') AND
           l_rev_gen_method = 'T' THEN
            l_cal_bill_rate_override_tab(i) := 1;
            IF l_target_version_type = 'ALL' THEN
                l_cal_rcost_rate_override_tab(i) := 0;
                l_cal_bcost_rate_override_tab(i) := 0;
            END IF;
        END IF;


        -- Bug 4216423: We now need to populate PA_FP_GEN_RATE_TMP with cost
        -- rates for both rate-based and non-rate based resources when generating
        -- work-based revenue for a Revenue-only target version.

        -- Added in IPM : When generating revenue-only, non-rate-based txns
        -- for ALL versions with work-based revenue accrual, do not use periodic
        -- source rates. Instead, populate the temp table with bill rate
        -- override as 1 and cost rate overrides as 0.

        IF  l_use_src_rates_flag = 'Y' AND
            NOT ( p_fp_cols_rec.x_version_type = 'REVENUE' AND l_rev_gen_method = 'T' ) AND
            NOT ( p_fp_cols_rec.x_version_type = 'ALL' AND l_rev_gen_method = 'T' AND
                  l_rev_only_src_txn_flag_tab(i) = 'Y' AND l_cal_rate_based_flag_tab(i) = 'N') THEN

           -- hr_utility.trace('==inside plan option same flag = Y  ');
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                    P_CALLED_MODE   => P_CALLED_MODE,
                    P_MSG           =>
                    'Before calling PA_FP_GEN_FCST_AMT_PUB1.POPULATE_GEN_RATE',
                    P_MODULE_NAME   => l_module_name);
            END IF;
            PA_FP_GEN_FCST_AMT_PUB1.POPULATE_GEN_RATE
               (P_SOURCE_RES_ASG_ID => l_cal_src_ra_id_tab(i),
                P_TARGET_RES_ASG_ID => l_cal_ra_id_tab(i),
                P_TXN_CURRENCY_CODE => l_cal_txn_currency_code_tab(i),
                X_RETURN_STATUS     => x_return_status,
                X_MSG_COUNT         => x_msg_count,
                X_MSG_DATA          => x_msg_data);
            IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                    P_CALLED_MODE   => P_CALLED_MODE,
                    P_MSG           =>
                    'After calling PA_FP_GEN_FCST_AMT_PUB1.POPULATE_GEN_RATE: '||x_return_status,
                    P_MODULE_NAME   => l_module_name);
            END IF;

            /* Populate the period rates table for the Client Extension API */

            -- Bug 4320954: When we fetch data from and update data to the
            -- PA_FP_GEN_RATE_TMP table for the Client Extension API, we need
            -- to check both the target_res_asg_id AND the TXN_CURRENCY_CODE
            -- in the WHERE clause so that the plan currency is honored.

            SELECT /*+ INDEX(PA_FP_GEN_RATE_TMP,PA_FP_GEN_RATE_TMP_N1)*/
                   period_name,
                   raw_cost_rate,
                   burdened_cost_rate,
                   revenue_bill_rate
            BULK COLLECT
            INTO   l_ext_period_name_tab,
                   l_ext_raw_cost_rate_tab,
                   l_ext_burdened_cost_rate_tab,
                   l_ext_revenue_bill_rate_tab
            FROM   pa_fp_gen_rate_tmp
            WHERE  target_res_asg_id = l_cal_ra_id_tab(i)
            AND    txn_currency_code = l_cal_txn_currency_code_tab(i);

            l_input_period_rates_tbl.delete;
            FOR j IN 1..l_ext_period_name_tab.count LOOP
                l_input_period_rates_tbl(j).period_name := l_ext_period_name_tab(j);
                l_input_period_rates_tbl(j).raw_cost_rate := l_ext_raw_cost_rate_tab(j);
                l_input_period_rates_tbl(j).burdened_cost_rate := l_ext_burdened_cost_rate_tab(j);
                l_input_period_rates_tbl(j).revenue_bill_rate := l_ext_revenue_bill_rate_tab(j);
            END LOOP;
        ELSIF ( p_fp_cols_rec.x_version_type = 'REVENUE' AND l_rev_gen_method = 'T' ) THEN
            /* Populate the period rates table for the Client Extension API */
            l_input_period_rates_tbl.delete;
            l_input_period_rates_tbl(1).raw_cost_rate := l_cal_rcost_rate_override_tab(i);
            l_input_period_rates_tbl(1).burdened_cost_rate := l_cal_bcost_rate_override_tab(i);

            IF l_rev_only_src_txn_flag_tab(i) = 'Y' AND
               l_cal_rate_based_flag_tab(i) = 'N' THEN
                 l_input_period_rates_tbl(1).revenue_bill_rate := l_cal_bill_rate_override_tab(i);
            END IF;

        --  Added in IPM : This handles a corner case.
        ELSIF ( p_fp_cols_rec.x_version_type = 'ALL' AND l_rev_gen_method = 'T' AND
                 l_rev_only_src_txn_flag_tab(i) = 'Y' AND l_cal_rate_based_flag_tab(i) = 'N') THEN

            /* Populate the period rates table for the Client Extension API */
            l_input_period_rates_tbl.delete;
            l_input_period_rates_tbl(1).raw_cost_rate := l_cal_rcost_rate_override_tab(i);
            l_input_period_rates_tbl(1).burdened_cost_rate := l_cal_bcost_rate_override_tab(i);
            l_input_period_rates_tbl(1).revenue_bill_rate := l_cal_bill_rate_override_tab(i);

        END IF;


        /* ER 4376722: When the Target is a Revenue-only Forecast, we
         * generate quantity but not revenue for rate-based resources of
         * non-billable tasks. To do this, null out revenue amounts,
         * overrides, and possible periodic rates for rate-based
         * resources of non-billable tasks.
         * Note that we handle the case of non-rated-based resources
         * of non-billable tasks earlier in the code. */

        IF l_fp_cols_rec_target.x_version_type = 'REVENUE' THEN
            -- Null out revenue amounts for non-billable tasks
            IF l_billable_flag_tab(i) = 'N' AND
               l_cal_rate_based_flag_tab(i) = 'Y' THEN

                l_cal_etc_revenue_tab(i) := NULL;
                l_cal_bill_rate_override_tab(i) := NULL;

                FOR j IN 1..l_input_period_rates_tbl.count LOOP
                    -- null out cost rates in case of Work-based revenue
                    l_input_period_rates_tbl(j).raw_cost_rate := NULL;
                    l_input_period_rates_tbl(j).burdened_cost_rate := NULL;
                    l_input_period_rates_tbl(j).revenue_bill_rate := NULL;
                END LOOP;
            END IF;
        END IF; -- ER 4376722 billability logic for REVENUE Forecast


        /* ER 4376722: When the Target is a Cost and Revenue together
         * version, we do not generate revenue for non-billable tasks.
         * To do this, null out revenue amounts, overrides, and possible
         * periodic rates for non-billable tasks. Since we call the
         * Client Extension, it's possible for revenue to be overriden
         * for non-billable tasks. */

        IF l_fp_cols_rec_target.x_version_type = 'ALL' THEN
            -- Null out revenue amounts for non-billable tasks
            IF l_billable_flag_tab(i) = 'N' THEN

                l_cal_etc_revenue_tab(i) := NULL;
                l_cal_bill_rate_override_tab(i) := NULL;

                FOR j IN 1..l_input_period_rates_tbl.count LOOP
                    l_input_period_rates_tbl(j).revenue_bill_rate := NULL;
                END LOOP;
            END IF;
        END IF; -- ER 4376722 billability logic for ALL versions


        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE   => P_CALLED_MODE,
                P_MSG           =>
                'Before calling pa_fp_fcst_gen_client_ext.fcst_gen_client_extn',
                P_MODULE_NAME   => l_module_name);
        END IF;
        /*For client_extn, many attributes are passed as NULL is because
          this API is still under developmen and some parameters are not
          available.Null values will be replaced later*/
        /* Call PA_FP_GEN_FCST_AMT_PUB1.POPULATE_GEN_RATE to populate
           pa_fp_gen_rate_tmp, which is used to populate input parameter
           P_PERIOD_RATES_TBL */

        -- hr_utility.trace('==before calling client extn api ');

        --This code has been commented due to bug 5726785 where the client extension
 	 --call has been made be passing the existing and also the periodic level amounts.

 	 /*        PA_FP_FCST_GEN_CLIENT_EXT.FCST_GEN_CLIENT_EXTN
           (P_PROJECT_ID                => P_PROJECT_ID,
            P_BUDGET_VERSION_ID         => P_BUDGET_VERSION_ID,
            P_RESOURCE_ASSIGNMENT_ID    => l_cal_ra_id_tab(i),
            P_TASK_ID                   => l_cal_task_id_tab(i),
            P_TASK_PERCENT_COMPLETE     => NULL,
            P_PROJECT_PERCENT_COMPLETE  => NULL,
            P_RESOURCE_LIST_MEMBER_ID   => l_cal_rlm_id_tab(i),
            P_UNIT_OF_MEASURE           => l_cal_unit_of_measure_tab(i), -- NEW PARAM
            P_TXN_CURRENCY_CODE         => l_cal_txn_currency_code_tab(i),
            P_ETC_QTY                   => l_cal_etc_qty_tab(i),
            P_ETC_RAW_COST              => l_cal_etc_raw_cost_tab(i),
            P_ETC_BURDENED_COST         => l_cal_etc_burdened_cost_tab(i),
            P_ETC_REVENUE               => l_cal_etc_revenue_tab(i),
            P_ETC_SOURCE                => NULL,
            P_ETC_GEN_METHOD            => l_cal_etc_method_code_tab(i),
            P_ACTUAL_THRU_DATE          => P_ACTUALS_THRU_DATE,
            P_ETC_START_DATE            => P_ACTUALS_THRU_DATE+1,
            P_ETC_END_DATE              => NULL,
            P_PLANNED_WORK_QTY          => NULL,
            P_ACTUAL_WORK_QTY           => NULL,
            P_ACTUAL_QTY                => NULL,
            P_ACTUAL_RAW_COST           => NULL,
            P_ACTUAL_BURDENED_COST      => NULL,
            P_ACTUAL_REVENUE            => NULL,
            P_PERIOD_RATES_TBL          => l_input_period_rates_tbl, --  NEW PARAM
            X_ETC_QTY                   => l_fcst_etc_qty,
            X_ETC_RAW_COST              => l_fcst_etc_raw_cost,
            X_ETC_BURDENED_COST         => l_fcst_etc_burdened_cost,
            X_ETC_REVENUE               => l_fcst_etc_revenue,
            X_PERIOD_RATES_TBL          => l_period_rates_tbl, -- NEW PARAM
            X_RETURN_STATUS             => x_return_status,
            X_MSG_DATA                  => x_msg_data,
            X_MSG_COUNT                 => x_msg_count);

       -- hr_utility.trace('==after calling client extn api ');

        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE   => P_CALLED_MODE,
                P_MSG           =>
                'After calling pa_fp_fcst_gen_client_ext.fcst_gen_client_extn: '
                                ||x_return_status,
                P_MODULE_NAME   => l_module_name);
        END IF;
        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF; */

	-- Code in client extn kept here to avoid further changes in code after client extn.
	/* bug fix 5726773 : commenting out unecessary client-extension related code */
	/*
 	         l_fcst_etc_qty := l_cal_etc_qty_tab(i);
 	         l_fcst_etc_raw_cost := l_cal_etc_raw_cost_tab(i);
 	         l_fcst_etc_burdened_cost := l_cal_etc_burdened_cost_tab(i);
 	         l_fcst_etc_revenue := l_cal_etc_revenue_tab(i);

 	         IF l_input_period_rates_tbl.count > 0 and
 	            l_period_rates_tbl.count = 0 THEN
 	         FOR j IN 1..l_input_period_rates_tbl.count LOOP
 	             l_period_rates_tbl(j).period_name := l_input_period_rates_tbl(j).period_name;
 	             l_period_rates_tbl(j).raw_cost_rate := l_input_period_rates_tbl(j).raw_cost_rate;
 	             l_period_rates_tbl(j).burdened_cost_rate := l_input_period_rates_tbl(j).burdened_cost_rate;
 	             l_period_rates_tbl(j).revenue_bill_rate := l_input_period_rates_tbl(j).revenue_bill_rate;
 	         END LOOP;
		 END IF;
 	 */
	/* end bug fix 5726773 */
	 -- Code in client extn kept here to avoid further changes in code after client extn.

        -- Bug 3968748: We need to populate the PA_FP_GEN_RATE_TMP table with
        -- burdened cost rates for non-rate-based resources for Calculate API
        -- when generating work-based revenue for a Revenue-only target version.

        -- Bug 4216423: We now need to populate PA_FP_GEN_RATE_TMP with cost
        -- rates for both rate-based and non-rate based resources when generating
        -- work-based revenue for a Revenue-only target version.

        IF  l_use_src_rates_flag = 'Y' OR
            ( p_fp_cols_rec.x_version_type = 'REVENUE' AND l_rev_gen_method = 'T' ) OR
            -- Added Condition for IPM
            ( p_fp_cols_rec.x_version_type = 'ALL' AND l_rev_gen_method = 'T' AND
              l_rev_only_src_txn_flag_tab(i) = 'Y' AND l_cal_rate_based_flag_tab(i) = 'N') THEN

            -- Bug 4320954: When we fetch data from and update data to the
            -- PA_FP_GEN_RATE_TMP table for the Client Extension API, we need
            -- to check both the target_res_asg_id AND the TXN_CURRENCY_CODE
            -- in the WHERE clause so that the plan currency is honored.

            DELETE /*+ INDEX(PA_FP_GEN_RATE_TMP,PA_FP_GEN_RATE_TMP_N1)*/
            FROM   pa_fp_gen_rate_tmp
            WHERE target_res_asg_id = l_cal_ra_id_tab(i)
            AND   txn_currency_code = l_cal_txn_currency_code_tab(i);

            l_ext_period_name_tab.delete;
            l_ext_raw_cost_rate_tab.delete;
            l_ext_burdened_cost_rate_tab.delete;
            l_ext_revenue_bill_rate_tab.delete;

	    /* bug fix 5726773: Use l_input_period_rates_tbl instead of l_period_rates_tbl */
	    FOR j IN 1..l_input_period_rates_tbl.count LOOP
		l_ext_period_name_tab(j) := l_input_period_rates_tbl(j).period_name;
		l_ext_raw_cost_rate_tab(j) := l_input_period_rates_tbl(j).raw_cost_rate;
		l_ext_burdened_cost_rate_tab(j) := l_input_period_rates_tbl(j).burdened_cost_rate;
                l_ext_revenue_bill_rate_tab(j) := l_input_period_rates_tbl(j).revenue_bill_rate;
	    END LOOP;

	    FORALL j IN 1..l_ext_period_name_tab.count
	        INSERT INTO PA_FP_GEN_RATE_TMP
	             ( SOURCE_RES_ASG_ID,
	               TXN_CURRENCY_CODE,
	               PERIOD_NAME,
	               RAW_COST_RATE,
	               BURDENED_COST_RATE,
	               REVENUE_BILL_RATE,
	               TARGET_RES_ASG_ID )
	        VALUES
	             ( l_cal_src_ra_id_tab(i),
	               l_cal_txn_currency_code_tab(i),
                       l_ext_period_name_tab(j),
                       l_ext_raw_cost_rate_tab(j),
                       l_ext_burdened_cost_rate_tab(j),
                       l_ext_revenue_bill_rate_tab(j),
	               l_cal_ra_id_tab(i) );
        END IF;

       /* hr_utility.trace('==etc qty aft client extn api  '||l_fcst_etc_qty);
       hr_utility.trace('==etc cost aft client extn api '||l_fcst_etc_raw_cost);
       hr_utility.trace('==etc bd cost aft client extn api '||l_fcst_etc_burdened_cost);
       hr_utility.trace('==etc rev  aft client extn api '||l_fcst_etc_revenue);  */

 /* bug fix 5726773 : commenting out unecessary client-extension related code */
 	 /*
        l_cal_etc_qty_tab(i)           := l_fcst_etc_qty;
        l_cal_etc_raw_cost_tab(i)      := l_fcst_etc_raw_cost;
        l_cal_etc_burdened_cost_tab(i) := l_fcst_etc_burdened_cost;
        l_cal_etc_revenue_tab(i)       := l_fcst_etc_revenue;
	*/
/* end bug fix 5726773 */

        IF (l_use_src_rates_flag = 'Y' OR
           (p_fp_cols_rec.x_version_type = 'REVENUE' AND l_rev_gen_method = 'T'))
           AND l_cal_rate_based_flag_tab(i) = 'Y' THEN
            l_cal_etc_raw_cost_tab(i)      := NULL;
            l_cal_etc_burdened_cost_tab(i) := NULL;
            l_cal_etc_revenue_tab(i)       := NULL;

            l_cal_rcost_rate_override_tab(i) := NULL;
            l_cal_bcost_rate_override_tab(i) := NULL;
        END IF;

        /*Bug fix: 4258968: for none rate based resources, bill markup should be applied
          on top of raw cost, not revenue. So,nullify revenue here*/

        IF (p_fp_cols_rec.x_version_type = 'REVENUE' OR p_fp_cols_rec.x_version_type = 'ALL')
           AND l_rev_gen_method = 'T'
           AND l_cal_rate_based_flag_tab(i) = 'N' THEN
            l_cal_etc_revenue_tab(i)        := NULL;
            l_cal_bill_rate_override_tab(i) := NULL;
        END IF;

        /* Start bug 3826548
           The following code has been added as a short term fix only.
           The Calculate API expects the total amounts for populating the
           budget lines for the ETC periods. Inside the Calculate API, they
           derived the actual amounts and subtract it from the passed total
           amounts. This fix is being patched for only testing the forecast
           generation process with the following assumptions.

           1. There is going to be only one txn currency for the actual txn
              for the planning resource. - Actual amt currency.
           2. ETC source - Work Plan/Financial Plan - The Plan amount for the
              planning resource should be planned in only one txn currency.
              (For Work plan, it is always going to be only one txn currency.
               But, this may change in the future.) - Plan amt currency.
           3. The Actual amt currency and the Plan amt currency should be same.

          The above fix will not cover all the cases. If we are going to have
          actual txn amounts in multiple currencies or if the ETC source total
          plan amount is going to be planned in multiple currencies, we will
          generate the ETC amount in Project Currency. In this case, if we  have
          three different actual txn currencies and one planning currency for the
          planning currency (which is different from the actual txn currencies),
          then the actual amount cannot be derived from the budget lines for the
          target version. B/c, the Calculate/Spread API gets the actual amounts
          based on the txn currency passed from the fcst gen code. In this case,
          we wont get any amounts.

          The fcst gen process will not give better performance results. B/c,
          from the fcst gen process, we are going to add the actual amount by
          reading the budget line data. Then, the Calculate/Spread API is going
          to select the same data and subtract the amounts from the total amount.

          Permanent Fix : The 'Calculate/Spread' API should spread only the amount
          passed from the fcst generation process and should not manipulate the
          data in any way. We have the p_calling_module parameter and this
          parameter should be used to avoid any manipulation to the passed data.

          If we go with the above strategy then the following code to select the
          actual amount (and adding the actual amount to the ETC amounts) should be
          removed and the changes should be made in the
          Calculate API/Spread API.

          If we are going to address this issue using a different strategy then
          the code changes should be made in Fcst gen/Calculate/Spread API.

          End bug 3826548
        */

        /* bug fix start */

        -- Bug 4211776, 4194849: Commented out logic for addition of actuals.
/*
        SELECT sum(init_quantity),
               sum(txn_init_raw_cost),
               sum(txn_init_burdened_cost),
               sum(txn_init_revenue)
          INTO l_init_qty,
               l_init_raw_cost,
               l_init_burdened_cost,
               l_init_revenue
        FROM pa_budget_lines
        WHERE resource_assignment_id = l_cal_ra_id_tab(i)
              AND txn_currency_code = l_cal_txn_currency_code_tab(i);

        l_cal_etc_qty_tab(i) := NVL(l_cal_etc_qty_tab(i),0) +
                                NVL(l_init_qty,0);

        IF p_fp_cols_rec.x_version_type = 'COST' THEN
            l_cal_etc_raw_cost_tab(i) := NVL(l_cal_etc_raw_cost_tab(i),0)  +
                                         NVL(l_init_raw_cost,0);
            l_cal_etc_burdened_cost_tab(i) := NVL(l_cal_etc_burdened_cost_tab(i),0) +
                                              NVL(l_init_burdened_cost,0);
        ELSIF p_fp_cols_rec.x_version_type = 'REVENUE' THEN
            l_cal_etc_revenue_tab(i) := NVL(l_cal_etc_revenue_tab(i),0) +
                                        NVL(l_init_revenue,0);
        ELSIF p_fp_cols_rec.x_version_type = 'ALL' THEN
            l_cal_etc_raw_cost_tab(i) := NVL(l_cal_etc_raw_cost_tab(i),0) +
                                         NVL(l_init_raw_cost,0);
            l_cal_etc_burdened_cost_tab(i) := NVL(l_cal_etc_burdened_cost_tab(i),0) +
                                              NVL(l_init_burdened_cost,0);
            l_cal_etc_revenue_tab(i) := NVL(l_cal_etc_revenue_tab(i),0) +
                                        NVL(l_init_revenue,0);
        END IF;
*/

       /* bug fix end */
         --hr_utility.trace('==Before calculate, l_cal_ra_id_tab('||i||'):'||l_cal_ra_id_tab(i));
         --hr_utility.trace('==Before calculate, l_cal_txn_currency_code_tab('||i||'):'||l_cal_txn_currency_code_tab(i));
         --hr_utility.trace('==Before calculate, l_cal_etc_qty_tab('||i||'):'||l_cal_etc_qty_tab(i));
         --hr_utility.trace('==Before calculate, l_cal_etc_raw_cost_tab('||i||'):'||l_cal_etc_raw_cost_tab(i));
         --hr_utility.trace('==Before calculate, l_cal_etc_burdened_cost_tab('||i||'):'||l_cal_etc_burdened_cost_tab(i));
         --hr_utility.trace('==Before calculate, l_cal_etc_revenue_tab('||i||'):'||l_cal_etc_revenue_tab(i));
         --hr_utility.trace('==Before calculate, l_cal_rcost_rate_override_tab('||i||'):'||l_cal_rcost_rate_override_tab(i));
         --hr_utility.trace('==Before calculate, l_cal_bcost_rate_override_tab('||i||'):'||l_cal_bcost_rate_override_tab(i));
         --hr_utility.trace('==Before calculate, l_cal_bill_rate_override_tab('||i||'):'||l_cal_bill_rate_override_tab(i));
         -- dbms_output.put_line('==Before calculate, l_cal_ra_id_tab('||i||'):'||l_cal_ra_id_tab(i));
         --dbms_output.put_line('==Before calculate, l_cal_txn_currency_code_tab('||i||'):'||l_cal_txn_currency_code_tab(i));
         --dbms_output.put_line('==Before calculate, l_cal_etc_qty_tab('||i||'):'||l_cal_etc_qty_tab(i));
         --dbms_output.put_line('==Before calculate, l_cal_etc_raw_cost_tab('||i||'):'||l_cal_etc_raw_cost_tab(i));
         --dbms_output.put_line('==Before calculate, l_cal_etc_burdened_cost_tab('||i||'):'||l_cal_etc_burdened_cost_tab(i));

    -- Added in IPM: The continue_loop Exception is used within the
    -- loop to skip further processing of the current planning txn.
    EXCEPTION
        WHEN CONTINUE_LOOP THEN
            l_dummy := 1;
        WHEN OTHERS THEN
            RAISE;
    END;
    END LOOP;


    -- Added in IPM. If there are any pl/sql table records that need to
    -- be removed, use a separate set of _tmp_ tables to filter them out.

    IF l_remove_records_flag = 'Y' THEN

        -- 0. Clear out any data in the _tmp_ tables.
        l_cal_src_ra_id_tab_tmp.delete;
        l_cal_ra_id_tab_tmp.delete;
        l_cal_txn_curr_code_tab_tmp.delete;
        l_cal_rate_based_flag_tab_tmp.delete;
        l_cal_rlm_id_tab_tmp.delete;
        l_cal_task_id_tab_tmp.delete;
        l_cal_unit_of_measure_tab_tmp.delete;
        l_cal_etc_method_code_tab_tmp.delete;
        l_cal_etc_qty_tab_tmp.delete;
        l_cal_etc_raw_cost_tab_tmp.delete;
        l_cal_etc_brdn_cost_tab_tmp.delete;
        l_cal_etc_revenue_tab_tmp.delete;
        l_billable_flag_tab_tmp.delete;
        l_cal_rcost_rate_ovrd_tab_tmp.delete;
        l_cal_bcost_rate_ovrd_tab_tmp.delete;
        l_cal_bill_rate_ovrd_tab_tmp.delete;

        -- 1. Copy records into _tmp_ tables
        l_index := 1;
        FOR i in 1..l_cal_ra_id_tab.count LOOP
            IF l_remove_record_flag_tab(i) <> 'Y' THEN

                l_cal_src_ra_id_tab_tmp.extend;
                l_cal_ra_id_tab_tmp.extend;
                l_cal_txn_curr_code_tab_tmp.extend;
                l_cal_rate_based_flag_tab_tmp.extend;
                l_cal_rlm_id_tab_tmp.extend;
                l_cal_task_id_tab_tmp.extend;
                l_cal_unit_of_measure_tab_tmp.extend;
                l_cal_etc_method_code_tab_tmp.extend;
                l_cal_etc_qty_tab_tmp.extend;
                l_cal_etc_raw_cost_tab_tmp.extend;
                l_cal_etc_brdn_cost_tab_tmp.extend;
                l_cal_etc_revenue_tab_tmp.extend;
                l_billable_flag_tab_tmp.extend;
                l_cal_rcost_rate_ovrd_tab_tmp.extend;
                l_cal_bcost_rate_ovrd_tab_tmp.extend;
                l_cal_bill_rate_ovrd_tab_tmp.extend;

                l_cal_src_ra_id_tab_tmp(l_index) := l_cal_src_ra_id_tab(i);
                l_cal_ra_id_tab_tmp(l_index) := l_cal_ra_id_tab(i);
                l_cal_txn_curr_code_tab_tmp(l_index) := l_cal_txn_currency_code_tab(i);
                l_cal_rate_based_flag_tab_tmp(l_index) := l_cal_rate_based_flag_tab(i);
                l_cal_rlm_id_tab_tmp(l_index) := l_cal_rlm_id_tab(i);
                l_cal_task_id_tab_tmp(l_index) := l_cal_task_id_tab(i);
                l_cal_unit_of_measure_tab_tmp(l_index) := l_cal_unit_of_measure_tab(i);
                l_cal_etc_method_code_tab_tmp(l_index) := l_cal_etc_method_code_tab(i);
                l_cal_etc_qty_tab_tmp(l_index) := l_cal_etc_qty_tab(i);
                l_cal_etc_raw_cost_tab_tmp(l_index) := l_cal_etc_raw_cost_tab(i);
                l_cal_etc_brdn_cost_tab_tmp(l_index) := l_cal_etc_burdened_cost_tab(i);
                l_cal_etc_revenue_tab_tmp(l_index) := l_cal_etc_revenue_tab(i);
                l_billable_flag_tab_tmp(l_index) := l_billable_flag_tab(i);
                l_cal_rcost_rate_ovrd_tab_tmp(l_index) := l_cal_rcost_rate_override_tab(i);
                l_cal_bcost_rate_ovrd_tab_tmp(l_index) := l_cal_bcost_rate_override_tab(i);
                l_cal_bill_rate_ovrd_tab_tmp(l_index) := l_cal_bill_rate_override_tab(i);

                l_index := l_index + 1;
            END IF;
        END LOOP;

        -- 2. Copy records from _tmp_ tables back to non-temporary tables.
        l_cal_src_ra_id_tab := l_cal_src_ra_id_tab_tmp;
        l_cal_ra_id_tab := l_cal_ra_id_tab_tmp;
        l_cal_txn_currency_code_tab := l_cal_txn_curr_code_tab_tmp;
        l_cal_rate_based_flag_tab := l_cal_rate_based_flag_tab_tmp;
        l_cal_rlm_id_tab := l_cal_rlm_id_tab_tmp;
        l_cal_task_id_tab := l_cal_task_id_tab_tmp;
        l_cal_unit_of_measure_tab := l_cal_unit_of_measure_tab_tmp;
        l_cal_etc_method_code_tab := l_cal_etc_method_code_tab_tmp;
        l_cal_etc_qty_tab := l_cal_etc_qty_tab_tmp;
        l_cal_etc_raw_cost_tab := l_cal_etc_raw_cost_tab_tmp;
        l_cal_etc_burdened_cost_tab := l_cal_etc_brdn_cost_tab_tmp;
        l_cal_etc_revenue_tab := l_cal_etc_revenue_tab_tmp;
        l_billable_flag_tab := l_billable_flag_tab_tmp;
        l_cal_rcost_rate_override_tab := l_cal_rcost_rate_ovrd_tab_tmp;
        l_cal_bcost_rate_override_tab := l_cal_bcost_rate_ovrd_tab_tmp;
        l_cal_bill_rate_override_tab := l_cal_bill_rate_ovrd_tab_tmp;

    END IF; -- IF l_remove_records_flag = 'Y' THEN

    -- End IPM filtering logic.

    /*********************************************************************
 	   ER 5726773: Commenting out logic that filters out planning
 	               transaction records with: (total plan quantity <= 0).

    -- Bug 4654157 and 4670253 : Before calling the Calculate API, we should ensure that only
    -- target resources with Total Plan Quantity >= 0 are passed. Total Plan Quantity
    -- is the sum of Actual Quantity (from target budget lines) + ETC Quantity.

    l_index := 1;

    l_cal_ra_id_tab_tmp.delete;
    l_cal_txn_curr_code_tab_tmp.delete;
    l_cal_rate_based_flag_tab_tmp.delete;
    l_cal_rlm_id_tab_tmp.delete;
    l_cal_task_id_tab_tmp.delete;
    l_cal_unit_of_measure_tab_tmp.delete;
    l_cal_etc_method_code_tab_tmp.delete;
    l_cal_etc_qty_tab_tmp.delete;
    l_cal_etc_raw_cost_tab_tmp.delete;
    l_cal_etc_brdn_cost_tab_tmp.delete;
    l_cal_etc_revenue_tab_tmp.delete;
    l_cal_rcost_rate_ovrd_tab_tmp.delete;
    l_cal_bcost_rate_ovrd_tab_tmp.delete;
    l_cal_bill_rate_ovrd_tab_tmp.delete;

    FOR i in 1..l_cal_ra_id_tab.count LOOP
	-- Bug 4670253: Added NVL around actual quantity sum to
        -- ensure that l_init_qty is not null.
        BEGIN
            SELECT nvl(sum(nvl(init_quantity,0)),0)
            INTO   l_init_qty
            FROM   pa_budget_lines
            WHERE  resource_assignment_id = l_cal_ra_id_tab(i)
            AND    txn_currency_code = l_cal_txn_currency_code_tab(i);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_init_qty := 0;
        END;

        l_total_plan_qty := l_init_qty + nvl(l_cal_etc_qty_tab(i),0);

        IF nvl(l_total_plan_qty,0) > 0 THEN
	    l_cal_ra_id_tab_tmp.EXTEND;
	    l_cal_txn_curr_code_tab_tmp.EXTEND;
	    l_cal_rate_based_flag_tab_tmp.EXTEND;
	    l_cal_rlm_id_tab_tmp.EXTEND;
	    l_cal_task_id_tab_tmp.EXTEND;
	    l_cal_unit_of_measure_tab_tmp.EXTEND;
	    l_cal_etc_method_code_tab_tmp.EXTEND;
	    l_cal_etc_qty_tab_tmp.EXTEND;
	    l_cal_etc_raw_cost_tab_tmp.EXTEND;
	    l_cal_etc_brdn_cost_tab_tmp.EXTEND;
	    l_cal_etc_revenue_tab_tmp.EXTEND;
	    l_cal_rcost_rate_ovrd_tab_tmp.EXTEND;
	    l_cal_bcost_rate_ovrd_tab_tmp.EXTEND;
	    l_cal_bill_rate_ovrd_tab_tmp.EXTEND;

	    l_cal_ra_id_tab_tmp(l_index) := l_cal_ra_id_tab(i);
	    l_cal_txn_curr_code_tab_tmp(l_index) := l_cal_txn_currency_code_tab(i);
	    l_cal_rate_based_flag_tab_tmp(l_index) := l_cal_rate_based_flag_tab(i);
	    l_cal_rlm_id_tab_tmp(l_index) := l_cal_rlm_id_tab(i);
	    l_cal_task_id_tab_tmp(l_index) := l_cal_task_id_tab(i);
	    l_cal_unit_of_measure_tab_tmp(l_index) := l_cal_unit_of_measure_tab(i);
	    l_cal_etc_method_code_tab_tmp(l_index) := l_cal_etc_method_code_tab(i);
	    l_cal_etc_qty_tab_tmp(l_index) := l_cal_etc_qty_tab(i);
	    l_cal_etc_raw_cost_tab_tmp(l_index) := l_cal_etc_raw_cost_tab(i);
	    l_cal_etc_brdn_cost_tab_tmp(l_index) := l_cal_etc_burdened_cost_tab(i);
	    l_cal_etc_revenue_tab_tmp(l_index) := l_cal_etc_revenue_tab(i);
	    l_cal_rcost_rate_ovrd_tab_tmp(l_index) := l_cal_rcost_rate_override_tab(i);
	    l_cal_bcost_rate_ovrd_tab_tmp(l_index) := l_cal_bcost_rate_override_tab(i);
	    l_cal_bill_rate_ovrd_tab_tmp(l_index) := l_cal_bill_rate_override_tab(i);

            l_index := l_index + 1;
        END IF; -- l_total_plan_qty > 0

    END LOOP; -- FOR i in 1..l_cal_ra_id_tab.count LOOP

    l_cal_ra_id_tab := l_cal_ra_id_tab_tmp;
    l_cal_txn_currency_code_tab := l_cal_txn_curr_code_tab_tmp;
    l_cal_rate_based_flag_tab := l_cal_rate_based_flag_tab_tmp;
    l_cal_rlm_id_tab := l_cal_rlm_id_tab_tmp;
    l_cal_task_id_tab := l_cal_task_id_tab_tmp;
    l_cal_unit_of_measure_tab := l_cal_unit_of_measure_tab_tmp;
    l_cal_etc_method_code_tab := l_cal_etc_method_code_tab_tmp;
    l_cal_etc_qty_tab := l_cal_etc_qty_tab_tmp;
    l_cal_etc_raw_cost_tab := l_cal_etc_raw_cost_tab_tmp;
    l_cal_etc_burdened_cost_tab := l_cal_etc_brdn_cost_tab_tmp;
    l_cal_etc_revenue_tab := l_cal_etc_revenue_tab_tmp;
    l_cal_rcost_rate_override_tab := l_cal_rcost_rate_ovrd_tab_tmp;
    l_cal_bcost_rate_override_tab := l_cal_bcost_rate_ovrd_tab_tmp;
    l_cal_bill_rate_override_tab := l_cal_bill_rate_ovrd_tab_tmp;

    -- End Bug Fix 4654157 and 4670253

    ER 5726773: End of commented out section.
*********************************************************************/

    IF P_FP_COLS_REC.X_TIME_PHASED_CODE='N' AND
       ( p_fp_cols_rec.x_version_type = 'COST' OR
         ( p_fp_cols_rec.x_version_type = 'REVENUE' AND
           l_rev_gen_method IN ('C','E') ) ) THEN

        FOR i in 1..l_cal_ra_id_tab.count LOOP
            SELECT  planning_start_date,
                    planning_end_date
            INTO    l_start_date,
                    l_end_date
            FROM    pa_resource_assignments
            WHERE   resource_assignment_id = l_cal_ra_id_tab(i);

            /*Start of the rounding handing*/
            IF l_cal_rate_based_flag_tab(i) = 'Y' THEN
                l_cal_etc_qty_tab(i) := pa_fin_plan_utils2.round_quantity
                                (p_quantity => l_cal_etc_qty_tab(i));
            ELSE
                l_cal_etc_qty_tab(i) :=  pa_currency.round_trans_currency_amt1
                                (x_amount       => l_cal_etc_qty_tab(i),
                                 x_curr_Code    => l_cal_txn_currency_code_tab(i));
            END IF;
            l_cal_etc_raw_cost_tab(i) := pa_currency.round_trans_currency_amt1
                    (x_amount       => l_cal_etc_raw_cost_tab(i),
                     x_curr_Code    => l_cal_txn_currency_code_tab(i));
            l_cal_etc_burdened_cost_tab(i) := pa_currency.round_trans_currency_amt1
                    (x_amount       => l_cal_etc_burdened_cost_tab(i),
                     x_curr_Code    => l_cal_txn_currency_code_tab(i));
            /*End of the rounding handling*/

	    /*dbms_output.put_line('ra_id = ' || l_cal_ra_id_tab(i) ||
	                         ',qty = ' || l_cal_etc_qty_tab(i) ||
	                         ', rc = ' || l_cal_etc_raw_cost_tab(i) ||
	                         ', bc = ' || l_cal_etc_burdened_cost_tab(i));*/

            l_amt_dtls_tbl.delete;
            l_amt_dtls_tbl(1).period_name := null;
            l_amt_dtls_tbl(1).start_date := l_start_date;
            l_amt_dtls_tbl(1).end_date := l_end_date;
            l_amt_dtls_tbl(1).quantity := l_cal_etc_qty_tab(i);
            l_amt_dtls_tbl(1).txn_raw_cost := l_cal_etc_raw_cost_tab(i);
            l_amt_dtls_tbl(1).txn_burdened_cost := l_cal_etc_burdened_cost_tab(i);
            l_amt_dtls_tbl(1).txn_revenue := null;
            l_amt_dtls_tbl(1).project_raw_cost := null;
            l_amt_dtls_tbl(1).project_burdened_cost := null;
            l_amt_dtls_tbl(1).project_revenue := null;
            l_amt_dtls_tbl(1).project_func_raw_cost := null;
            l_amt_dtls_tbl(1).project_func_burdened_cost := null;
            l_amt_dtls_tbl(1).project_func_revenue := null;

            -- ER 4376722: Note that we do not need to check task billability
            -- at this point; the billability logic performed upstream should
            -- be sufficient. The IF statement below is the only point within
            -- this None timephase logic block where Revenue is updated by an
            -- assignment. However, the assignment statement is safe, because
            -- the billable_flag cannot be 'N' at this point - if it were 'N',
            -- then the billability logic upstream would have removed the
            -- current record from the pl/sql tables.

            -- if then introduced for bug 4232253
            IF p_fp_cols_rec.x_version_type = 'REVENUE' AND
               l_cal_rate_based_flag_tab(i) = 'N' THEN
                -- Earlier, l_cal_etc_qty value has been set to raw cost or
                -- burdened cost based on the revenue accrual method.
                l_amt_dtls_tbl(1).txn_revenue :=  l_amt_dtls_tbl(1).quantity;
            END IF;

            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                    P_CALLED_MODE   => P_CALLED_MODE,
                    P_MSG           => 'Before calling PA_FP_MAINTAIN_ACTUAL_PUB.'||
                                       'MAINTAIN_ACTUAL_AMT_RA',
                    P_MODULE_NAME   => l_module_name);
            END IF;
            PA_FP_MAINTAIN_ACTUAL_PUB.MAINTAIN_ACTUAL_AMT_RA (
                P_PROJECT_ID                => P_PROJECT_ID,
                P_BUDGET_VERSION_ID         => P_BUDGET_VERSION_ID,
                P_RESOURCE_ASSIGNMENT_ID    => l_cal_ra_id_tab(i),
                P_TXN_CURRENCY_CODE         => l_cal_txn_currency_code_tab(i),
                P_AMT_DTLS_REC_TAB          => l_amt_dtls_tbl,
                P_CALLING_CONTEXT           => 'FP_GEN_FCST_COPY_ACTUAL',
                P_TXN_AMT_TYPE_CODE         => 'PLANNING_TXN',
                X_RETURN_STATUS             => x_return_Status,
                X_MSG_COUNT                 => x_msg_count,
                X_MSG_DATA                  => x_msg_data );
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                    P_CALLED_MODE   => P_CALLED_MODE,
                    P_MSG           => 'After calling PA_FP_MAINTAIN_ACTUAL_PUB.'||
                                       'MAINTAIN_ACTUAL_AMT_RA: '||x_return_status,
                    P_MODULE_NAME   => l_module_name);
            END IF;
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
        END LOOP;
        IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN;
    END IF;

    /*
        select count(*) into l_count from
        pa_budget_lines where budget_version_id = P_BUDGET_VERSION_ID;

    hr_utility.trace('==before calculate=== no of bdgt lines'||
             l_count );
    Initializing every pl sql table to null for calling calculate API */

    FOR i in 1..l_cal_ra_id_tab.count LOOP
            l_delete_budget_lines_tab.extend;
            l_spread_amts_flag_tab.extend;
            l_txn_currency_override_tab.extend;
            l_addl_qty_tab.extend;
            l_addl_raw_cost_tab.extend;
            l_addl_burdened_cost_tab.extend;
            l_addl_revenue_tab.extend;
            l_raw_cost_rate_tab.extend;
            l_b_cost_rate_tab.extend;
            l_bill_rate_tab.extend;
            l_line_start_date_tab.extend;
            l_line_end_date_tab.extend;

            l_delete_budget_lines_tab(i)    :=  Null;
            l_spread_amts_flag_tab(i)       :=  'Y';
            l_txn_currency_override_tab(i)  :=  Null;
            l_addl_qty_tab(i)               :=  Null;
            l_addl_raw_cost_tab(i)          :=  Null;
            l_addl_burdened_cost_tab(i)     :=  Null;
            l_addl_revenue_tab(i)           :=  Null;
            l_raw_cost_rate_tab(i)          :=  Null;
            l_b_cost_rate_tab(i)            :=  Null;
            l_bill_rate_tab(i)              :=  Null;
            l_line_start_date_tab(i)        :=  Null;
            l_line_end_date_tab(i)          :=  Null;
            -- --dbms_output.put_line('----'||i||'-----');
            -- --dbms_output.put_line(l_resource_assignment_id_tab(i));
            -- --dbms_output.put_line(l_quantity_tab(i));
    END LOOP;
    l_refresh_rates_flag := 'N';
    l_refresh_conv_rates_flag := 'N';
    l_spread_required_flag := 'Y';
    l_conv_rates_required_flag := 'Y';
    l_raTxn_rollup_api_call_flag := 'N'; -- Added for IPM new entity ER

    -- Bug 3991151: Before calling the Calculate API, we need to copy source
    -- attributes (including the spread_curve_id) to target resources where
    -- applicable.

    /* Populate target ra_ids in tmp1 for COPY_SRC_ATTRS_TO_TARGET_FCST */
    DELETE pa_res_list_map_tmp1;
    FORALL i in 1..l_cal_ra_id_tab.count
        INSERT INTO pa_res_list_map_tmp1
               ( txn_resource_assignment_id )
        VALUES ( l_cal_ra_id_tab(i) );

    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'Before calling PA_FP_GEN_PUB.' ||
                               'COPY_SRC_ATTRS_TO_TARGET_FCST',
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;
    PA_FP_GEN_PUB.COPY_SRC_ATTRS_TO_TARGET_FCST
        ( P_FP_COLS_REC    => p_fp_cols_rec,
          X_RETURN_STATUS  => x_return_status,
          X_MSG_COUNT      => x_msg_count,
          X_MSG_DATA       => x_msg_data );
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'Status after calling PA_FP_GEN_PUB.' ||
                               'COPY_SRC_ATTRS_TO_TARGET_FCST: ' ||
                               x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;
    -- Bug 3991151: End changes.

    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_CALLED_MODE   => P_CALLED_MODE,
            P_MSG           => 'Before calling PA_FP_CALC_PLAN_PKG.calculate',
            P_MODULE_NAME   => l_module_name);
    END IF;
    /* select etc_start_date into l_date from
       pa_budget_versions where budget_version_id = P_BUDGET_VERSION_ID;

    hr_utility.trace('==before calculate=== etc start date '||
             to_char(l_date,'dd-mon-yyyy') );
    hr_utility.trace('==Entering Calculate=================='); */

    /* p_calling module parameter added for bug 3796136  to
       spread ETC amount only after the actual thru period end date
       and update the planning end date in res asg table.
       This logic is handled in the calculate API based on this
       new parameter. */

    PA_FP_CALC_PLAN_PKG.calculate(
        p_calling_module                => 'FORECAST_GENERATION',
        P_PROJECT_ID                    => P_PROJECT_ID,
        P_BUDGET_VERSION_ID             => P_BUDGET_VERSION_ID,
        P_REFRESH_RATES_FLAG            => l_refresh_rates_flag,
        P_REFRESH_CONV_RATES_FLAG       => l_refresh_conv_rates_flag,
        P_SPREAD_REQUIRED_FLAG          => l_spread_required_flag,
        P_CONV_RATES_REQUIRED_FLAG      => l_conv_rates_required_flag,
        P_ROLLUP_REQUIRED_FLAG          => 'N',
        --P_MASS_ADJUST_FLAG
        --P_QUANTITY_ADJ_PCT
        --P_COST_RATE_ADJ_PCT
        --P_BURDENED_RATE_ADJ_PCT
        --P_BILL_RATE_ADJ_PCT
        P_SOURCE_CONTEXT                => l_source_context,
        P_RESOURCE_ASSIGNMENT_TAB       => l_cal_ra_id_tab,
        P_DELETE_BUDGET_LINES_TAB       => l_delete_budget_lines_tab,
        P_SPREAD_AMTS_FLAG_TAB          => l_spread_amts_flag_tab,
        P_TXN_CURRENCY_CODE_TAB         => l_cal_txn_currency_code_tab,
        P_TXN_CURRENCY_OVERRIDE_TAB     => l_txn_currency_override_tab,
        P_TOTAL_QTY_TAB                 => l_cal_etc_qty_tab,
        P_ADDL_QTY_TAB                  => l_addl_qty_tab,
        P_TOTAL_RAW_COST_TAB            => l_cal_etc_raw_cost_tab,
        P_ADDL_RAW_COST_TAB             => l_addl_raw_cost_tab,
        P_TOTAL_BURDENED_COST_TAB       => l_cal_etc_burdened_cost_tab,
        P_ADDL_BURDENED_COST_TAB        => l_addl_burdened_cost_tab,
        P_TOTAL_REVENUE_TAB             => l_cal_etc_revenue_tab,
        P_ADDL_REVENUE_TAB              => l_addl_revenue_tab,
        P_RAW_COST_RATE_TAB             => l_raw_cost_rate_tab,
        P_RW_COST_RATE_OVERRIDE_TAB     => l_cal_rcost_rate_override_tab,
        P_B_COST_RATE_TAB               => l_b_cost_rate_tab,
        P_B_COST_RATE_OVERRIDE_TAB      => l_cal_bcost_rate_override_tab,
        P_BILL_RATE_TAB                 => l_bill_rate_tab,
        P_BILL_RATE_OVERRIDE_TAB        => l_cal_bill_rate_override_tab,
        P_LINE_START_DATE_TAB           => l_line_start_date_tab,
        P_LINE_END_DATE_TAB             => l_line_start_date_tab,
        P_RATXN_ROLLUP_API_CALL_FLAG    => l_raTxn_rollup_api_call_flag,
        X_RETURN_STATUS                 => x_return_status,
        X_MSG_COUNT                     => x_msg_count,
        X_MSG_DATA                      => x_msg_data );

    -- hr_utility.trace('==Leaving Calculate==================:'||x_return_status);

    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_CALLED_MODE   => P_CALLED_MODE,
            P_MSG           => 'After calling PA_FP_CALC_PLAN_PKG.calculate: '||
                               x_return_status,
            P_MODULE_NAME   => l_module_name);
    END IF;
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.Reset_Curr_Function;
    END IF;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
          --dbms_output.put_line('--INSIDE  PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc');
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
          IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE   => P_CALLED_MODE,
                P_MSG           => 'Invalid Arguments Passed',
                P_MODULE_NAME   => l_module_name);
          PA_DEBUG.Reset_Curr_Function;
          END IF;
          RAISE;

      WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_data      := SUBSTR(SQLERRM,1,240);
           FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_FCST_AMT_PUB'
              ,p_procedure_name => 'GEN_FCST_TASK_LEVEL_AMT');
           IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                    P_CALLED_MODE   => P_CALLED_MODE,
                    P_MSG           => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                    P_MODULE_NAME   => l_module_name);
                PA_DEBUG.Reset_Curr_Function;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END  GEN_FCST_TASK_LEVEL_AMT;

PROCEDURE MAINTAIN_RES_ASG(
                P_PROJECT_ID         IN          PA_PROJECTS_ALL.PROJECT_ID%TYPE,
                P_BUDGET_VERSION_ID  IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
                P_FP_COLS_REC        IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
                X_RETURN_STATUS      OUT  NOCOPY VARCHAR2,
                X_MSG_COUNT          OUT  NOCOPY NUMBER,
                X_MSG_DATA           OUT  NOCOPY VARCHAR2)
IS
l_module_name          VARCHAR2(200) := 'pa.plsql.pa_fp_gen_fcst_amt_pub.maintain_res_asg';

l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000);
l_data                          VARCHAR2(2000);
l_msg_index_out                 NUMBER:=0;

l_count                         number;
BEGIN
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT := 0;
    IF p_pa_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function     => 'MAINTAIN_RES_ASG',
                                      p_debug_mode   =>  p_pa_debug_mode);
    END IF;

    DELETE FROM PA_FP_PLANNING_RES_TMP1;
    IF P_FP_COLS_REC.X_FIN_PLAN_LEVEL_CODE = 'L' THEN
    -- hr_utility.trace('inside lowest task in maintain res asg :');
    /* PA_FP_PLANNING_RES_TMP1 will have res asg id column with
       > 0 value - actual res asg id from WP or FP budget version
       source, all negative res asg values are inserted either for
       tasks with etc source as WORK_QUANTITY or the etc is NONE or NULL. */
        INSERT INTO PA_FP_PLANNING_RES_TMP1 (
                TASK_ID,
                RESOURCE_LIST_MEMBER_ID,
                RESOURCE_ASSIGNMENT_ID,
                planning_start_date,
                planning_end_date )
        (SELECT MAPPED_FIN_TASK_ID,
                TARGET_RLM_ID,
                to_number(NULL),
                min(planning_start_date),
                max(planning_end_date)
        FROM PA_FP_CALC_AMT_TMP1
        GROUP BY mapped_fin_task_id,TARGET_RLM_ID,to_number(NULL));
    ELSIF P_FP_COLS_REC.X_FIN_PLAN_LEVEL_CODE = 'P' THEN
    -- hr_utility.trace('inside proj    lvl in maintain res asg :');
        INSERT INTO PA_FP_PLANNING_RES_TMP1 (
                TASK_ID,
                RESOURCE_LIST_MEMBER_ID,
                RESOURCE_ASSIGNMENT_ID,
                planning_start_date,
                planning_end_date )
        (SELECT 0,
                TARGET_RLM_ID,
                to_number(NULL),
                min(planning_start_date),
                max(planning_end_date)
        FROM PA_FP_CALC_AMT_TMP1
                group by 0, TARGET_RLM_ID,
                to_number(NULL) );
    ELSIF P_FP_COLS_REC.X_FIN_PLAN_LEVEL_CODE = 'T' THEN
    -- hr_utility.trace('inside top task in maintain res asg :');
        INSERT INTO PA_FP_PLANNING_RES_TMP1 (
                TASK_ID,
                RESOURCE_LIST_MEMBER_ID,
                RESOURCE_ASSIGNMENT_ID,
                planning_start_date,
                planning_end_date )
        (SELECT MAPPED_FIN_TASK_ID,
                TARGET_RLM_ID,
                to_number(NULL),
                min(planning_start_date),
                max(planning_end_date)
        FROM PA_FP_CALC_AMT_TMP1 group by
        mapped_fin_task_id,TARGET_RLM_ID,
                to_number(NULL) );
    END IF;
    -- select count(*) into l_count from PA_FP_PLANNING_RES_TMP1;
    -- hr_utility.trace('in maintain res asg plan res tmp1 count :'||l_count);
    IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG           => 'Before calling pa_fp_copy_actuals_pub.create_res_asg',
                P_MODULE_NAME   => l_module_name,
                p_log_level => 5);
    END IF;
    PA_FP_COPY_ACTUALS_PUB.CREATE_RES_ASG (
                P_PROJECT_ID            => P_PROJECT_ID,
                P_BUDGET_VERSION_ID     => P_BUDGET_VERSION_ID,
                P_FP_COLS_REC           => P_FP_COLS_REC,
                P_CALLING_PROCESS       => 'FORECAST_GENERATION',
                X_RETURN_STATUS         => x_return_status,
                X_MSG_COUNT             => x_msg_count,
                X_MSG_DATA              => x_msg_data );
    IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG           => 'After calling create_res_asg,return status is: '||x_return_status,
                P_MODULE_NAME   => l_module_name,
                p_log_level => 5);
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG           => 'Before calling pa_fp_copy_actuals_pub.update_res_asg',
                P_MODULE_NAME   => l_module_name,
                p_log_level => 5);
    END IF;
    PA_FP_COPY_ACTUALS_PUB.UPDATE_RES_ASG (
                P_PROJECT_ID            => P_PROJECT_ID,
                P_BUDGET_VERSION_ID     => P_BUDGET_VERSION_ID,
                P_FP_COLS_REC           => P_FP_COLS_REC,
                P_CALLING_PROCESS       => 'FORECAST_GENERATION',
                X_RETURN_STATUS         => x_return_status,
                X_MSG_COUNT             => x_msg_count,
                X_MSG_DATA              => x_msg_data );
    IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG           => 'After calling update_res_asg,return status is: '||x_return_status,
                P_MODULE_NAME   => l_module_name,
                p_log_level => 5);
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.Reset_Curr_Function;
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
                 x_msg_data  := l_data;
                 x_msg_count := l_msg_count;
          ELSE
                x_msg_count := l_msg_count;
          END IF;
          ROLLBACK;

          x_return_status := FND_API.G_RET_STS_ERROR;
          IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG           => 'Invalid Arguments Passed',
                P_MODULE_NAME   => l_module_name,
                p_log_level => 5);
          PA_DEBUG.Reset_Curr_Function;
          END IF;
          RAISE;

      WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_data      := SUBSTR(SQLERRM,1,240);
           FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_FCST_AMT_PUB'
              ,p_procedure_name => 'MAINTAIN_RES_ASG');
           IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG           => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                P_MODULE_NAME   => l_module_name,
                p_log_level => 5);
                PA_DEBUG.Reset_Curr_Function;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END MAINTAIN_RES_ASG;


/**
 * This procedure updates pa_budget_lines.other_rejection_code
 * for the purpose of signalling ETC revenue amount calculation
 * errors. See bug 5203622.
 *
 * Pre-Conditions:
 * 1. At this point, other_rejection_code values should be stored
 *    in the txn_currency_code column of the pa_fp_calc_amt_tmp2
 *    table for planning txns with ETC revenue calculation errors.
 *
 *    Note: The etc_currency_code column (not txn_currency_code)
 *    to store the currency for ETC records in pa_fp_calc_amt_tmp2.
 *
 * Also worth noting is that this procedure is package-private.
 */
PROCEDURE UPD_REV_CALCULATION_ERR
          (P_PROJECT_ID              IN          PA_PROJECTS_ALL.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC             IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_ETC_START_DATE          IN          DATE,
           P_CALLED_MODE             IN          VARCHAR2 DEFAULT 'SELF_SERVICE',
           X_RETURN_STATUS           OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY NUMBER,
           X_MSG_DATA                OUT  NOCOPY VARCHAR2 )
IS
    l_package_name                 VARCHAR2(30) := 'PA_FP_GEN_FCST_AMT_PUB';
    l_procedure_name               VARCHAR2(30) := 'UPD_REV_CALCULATION_ERR';
    l_module_name                  VARCHAR2(100);

    l_log_level                    NUMBER := 5;
    l_msg_count                    NUMBER;
    l_data                         VARCHAR2(1000);
    l_msg_data                     VARCHAR2(1000);
    l_msg_index_out                NUMBER;
BEGIN
    l_module_name := 'pa.plsql.' || l_package_name || '.' || l_procedure_name;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;

    IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.SET_CURR_FUNCTION( p_function   => l_procedure_name,
                                    p_debug_mode => p_pa_debug_mode );
    END IF;

    -- Print values of Input Parameters to debug log
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'Input Parameters for '
                               || l_module_name || '():',
              p_called_mode => p_called_mode,
              p_module_name => l_module_name,
              p_log_level   => l_log_level );
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'P_PROJECT_ID:['||p_project_id||']',
              p_called_mode => p_called_mode,
              p_module_name => l_module_name,
              p_log_level   => l_log_level );
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'P_BUDGET_VERSION_ID:['||p_budget_version_id||']',
              p_called_mode => p_called_mode,
              p_module_name => l_module_name,
              p_log_level   => l_log_level );
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'P_ETC_START_DATE:['||p_etc_start_date||']',
              p_called_mode => p_called_mode,
              p_module_name => l_module_name,
              p_log_level   => l_log_level );
    END IF; -- IF p_pa_debug_mode = 'Y' THEN

    -- Validate input parameters
    IF p_project_id is NULL OR
       p_budget_version_id is NULL OR
       p_etc_start_date is NULL THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( p_msg         => 'Input Parameter Validation FAILED',
                  p_called_mode => p_called_mode,
                  p_module_name => l_module_name,
                  p_log_level   => l_log_level );
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RETURN;
    END IF;

    -- Update pa_budget_lines with any other_rejection_codes stored
    -- in the txn_currency_code column of the task level selection
    -- forecast generation processing table pa_fp_calc_amt_tmp2.

    UPDATE pa_budget_lines bl
    SET    bl.other_rejection_code =
         ( SELECT tmp2.txn_currency_code
           FROM   pa_fp_calc_amt_tmp2 tmp2
           WHERE  tmp2.transaction_source_code = 'ETC'
           AND    tmp2.txn_currency_code is not null
           AND    bl.resource_assignment_id = tmp2.target_res_asg_id
           AND    bl.txn_currency_code = tmp2.etc_currency_code )
    WHERE bl.budget_version_id = p_budget_version_id
    AND   nvl(bl.quantity,0) <> nvl(bl.init_quantity,0) -- ETC lines only
    AND EXISTS
         ( SELECT null
           FROM   pa_fp_calc_amt_tmp2 tmp2
           WHERE  tmp2.transaction_source_code = 'ETC'
           AND    tmp2.txn_currency_code is not null
           AND    bl.resource_assignment_id = tmp2.target_res_asg_id
           AND    bl.txn_currency_code = tmp2.etc_currency_code );

    IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.RESET_CURR_FUNCTION;
    END IF;
EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count = 1 THEN
            PA_INTERFACE_UTILS_PUB.GET_MESSAGES
                ( p_encoded        => FND_API.G_TRUE,
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

        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF p_pa_debug_mode = 'Y' THEN
           PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            (p_msg         => 'Invalid Arguments Passed',
             p_module_name => l_module_name,
             p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        FND_MSG_PUB.ADD_EXC_MSG
                   ( p_pkg_name        => l_package_name,
                     p_procedure_name  => l_procedure_name,
                     p_error_text      => substr(sqlerrm,1,240));

        IF p_pa_debug_mode = 'Y' THEN
           PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
             p_module_name => l_module_name,
             p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END UPD_REV_CALCULATION_ERR;


END PA_FP_GEN_FCST_AMT_PUB;

/
