--------------------------------------------------------
--  DDL for Package Body PA_FP_GEN_AMOUNT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_GEN_AMOUNT_UTILS" as
/* $Header: PAFPGAUB.pls 120.11 2007/02/06 09:56:17 dthakker ship $ */

l_module_name VARCHAR2(100) := 'pa.plsql.pa_fp_gen_amount_utils';
Invalid_Arg_Exc  EXCEPTION;

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE GET_PLAN_VERSION_DTLS
          (P_PROJECT_ID 	            IN            PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID 	            IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           X_FP_COLS_REC                    OUT  NOCOPY   FP_COLS,
           X_RETURN_STATUS                  OUT  NOCOPY   VARCHAR2,
           X_MSG_COUNT                      OUT  NOCOPY   NUMBER,
           X_MSG_DATA                       OUT  NOCOPY   VARCHAR2)

IS

l_module_name         VARCHAR2(200) := 'pa.plsql.pa_fp_gen_amount_utils.get_plan_version_dtls';

        l_debug_mode      VARCHAR2(30);
        l_msg_count       NUMBER := 0;
        l_data            VARCHAR2(2000);
        l_msg_data        VARCHAR2(2000);
        l_error_msg_code  VARCHAR2(30);
        l_msg_index_out   NUMBER;
        l_return_status   VARCHAR2(2000);

BEGIN

        X_MSG_COUNT := 0;

        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

       IF p_pa_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function     => 'GET_PLAN_VERSION_DTLS'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
       END IF;

       --dbms_output.put_line('in utils before select');

  SELECT
  OPT.PROJECT_ID,
  BV.BUDGET_VERSION_ID,
  OPT.PROJ_FP_OPTIONS_ID,
  OPT.FIN_PLAN_TYPE_ID,
  DECODE(BV.VERSION_TYPE,'COST', OPT.COST_AMOUNT_SET_ID,
                         'REVENUE',OPT.REVENUE_AMOUNT_SET_ID,
                         'ALL',OPT.ALL_AMOUNT_SET_ID),
  DECODE(BV.VERSION_TYPE,'COST', OPT.COST_FIN_PLAN_LEVEL_CODE,
                         'REVENUE',OPT.REVENUE_FIN_PLAN_LEVEL_CODE,
                         'ALL',OPT.ALL_FIN_PLAN_LEVEL_CODE),
  DECODE(BV.VERSION_TYPE,'COST', OPT.COST_TIME_PHASED_CODE,
                         'REVENUE',OPT.REVENUE_TIME_PHASED_CODE,
                         'ALL',OPT.ALL_TIME_PHASED_CODE),
  DECODE(BV.VERSION_TYPE,'COST', OPT.COST_RESOURCE_LIST_ID,
                         'REVENUE',OPT.REVENUE_RESOURCE_LIST_ID,
                         'ALL',OPT.ALL_RESOURCE_LIST_ID),
  DECODE(BV.VERSION_TYPE,'COST', OPT.COST_RES_PLANNING_LEVEL,
                         'REVENUE',OPT.REVENUE_RES_PLANNING_LEVEL,
                         'ALL',OPT.ALL_RES_PLANNING_LEVEL),
  OPT.RBS_VERSION_ID,
  decode(nvl(opt.use_planning_rates_flag,'N'),'N',null,
         'Y',DECODE(BV.VERSION_TYPE,
               'COST', OPT.COST_EMP_RATE_SCH_ID,
               'ALL',OPT.COST_EMP_RATE_SCH_ID,
                null)),
  decode(nvl(opt.use_planning_rates_flag,'N'),'N',null,
         'Y',DECODE(BV.VERSION_TYPE,
                         'REVENUE',OPT.REV_EMP_RATE_SCH_ID,
                         'ALL',OPT.REV_EMP_RATE_SCH_ID,
                          null)),
  decode(nvl(opt.use_planning_rates_flag,'N'),'N',null,
         'Y',DECODE(BV.VERSION_TYPE,'COST', OPT.COST_JOB_RATE_SCH_ID,
                         'ALL',OPT.COST_JOB_RATE_SCH_ID,
                          null)),
  decode(nvl(opt.use_planning_rates_flag,'N'),'N',null,
         'Y',DECODE(BV.VERSION_TYPE,'REVENUE',OPT.REV_JOB_RATE_SCH_ID,
                         'ALL',OPT.REV_JOB_RATE_SCH_ID,
                          null)),
  decode(nvl(opt.use_planning_rates_flag,'N'),'N',null,
         'Y',DECODE(BV.VERSION_TYPE,'COST', OPT.COST_NON_LABOR_RES_RATE_SCH_ID,
                         'ALL', OPT.COST_NON_LABOR_RES_RATE_SCH_ID,
                          null)),
   decode(nvl(opt.use_planning_rates_flag,'N'),'N',null,
          'Y',DECODE(BV.VERSION_TYPE,'REVENUE',OPT.REV_NON_LABOR_RES_RATE_SCH_ID,
                         'ALL', OPT.REV_NON_LABOR_RES_RATE_SCH_ID,
                          null)),
    decode(nvl(opt.use_planning_rates_flag,'N'),'N',null,
           'Y',DECODE(BV.VERSION_TYPE,'COST', OPT.COST_RES_CLASS_RATE_SCH_ID,
                         'ALL',OPT.COST_RES_CLASS_RATE_SCH_ID,
                          null)),
    decode(nvl(opt.use_planning_rates_flag,'N'),'N',null,
           'Y',DECODE(BV.VERSION_TYPE,'REVENUE',OPT.REV_RES_CLASS_RATE_SCH_ID,
                         'ALL',OPT.REV_RES_CLASS_RATE_SCH_ID,
                          null)),
  DECODE(BV.VERSION_TYPE,'COST', OPT.COST_BURDEN_RATE_SCH_ID,
                         'ALL', OPT.COST_BURDEN_RATE_SCH_ID,
                          null),
  DECODE(BV.VERSION_TYPE,'COST', OPT.COST_CURRENT_PLANNING_PERIOD,
                         'REVENUE',OPT.REV_CURRENT_PLANNING_PERIOD,
                         'ALL',OPT.ALL_CURRENT_PLANNING_PERIOD),
  DECODE(BV.VERSION_TYPE,'COST', OPT.COST_PERIOD_MASK_ID,
                         'REVENUE',OPT.REV_PERIOD_MASK_ID,
                         'ALL',OPT.ALL_PERIOD_MASK_ID),
  DECODE(BV.VERSION_TYPE,'COST', OPT.GEN_SRC_COST_PLAN_TYPE_ID,
                         'REVENUE',OPT.GEN_SRC_REV_PLAN_TYPE_ID,
                         'ALL',OPT.GEN_SRC_ALL_PLAN_TYPE_ID),
  DECODE(BV.VERSION_TYPE,'COST', OPT.GEN_SRC_COST_PLAN_VERSION_ID,
                         'REVENUE',OPT.GEN_SRC_REV_PLAN_VERSION_ID,
                         'ALL',OPT.GEN_SRC_ALL_PLAN_VERSION_ID),
  DECODE(BV.VERSION_TYPE,'COST', OPT1.GEN_SRC_COST_PLAN_VER_CODE,
                         'REVENUE',OPT1.GEN_SRC_REV_PLAN_VER_CODE,
                         'ALL',OPT1.GEN_SRC_ALL_PLAN_VER_CODE),
  DECODE(BV.VERSION_TYPE,'COST', OPT.GEN_COST_SRC_CODE,
                         'REVENUE',OPT.GEN_REV_SRC_CODE,
                         'ALL',OPT.GEN_ALL_SRC_CODE),
  DECODE(BV.VERSION_TYPE,'COST', OPT.GEN_COST_ETC_SRC_CODE,
                         'REVENUE',OPT.GEN_REV_ETC_SRC_CODE,
                         'ALL',OPT.GEN_ALL_ETC_SRC_CODE),
  DECODE(BV.VERSION_TYPE,'COST', OPT.GEN_COST_INCL_CHANGE_DOC_FLAG,
                         'REVENUE',OPT.GEN_REV_INCL_CHANGE_DOC_FLAG,
                         'ALL',OPT.GEN_ALL_INCL_CHANGE_DOC_FLAG),
  DECODE(BV.VERSION_TYPE,'COST', OPT.GEN_COST_INCL_OPEN_COMM_FLAG,
                         'REVENUE','N',
                         'ALL',OPT.GEN_ALL_INCL_OPEN_COMM_FLAG),
  DECODE(BV.VERSION_TYPE,'COST','N',
                         'REVENUE',OPT.GEN_REV_INCL_BILL_EVENT_FLAG,
                         'ALL',OPT.GEN_ALL_INCL_BILL_EVENT_FLAG),
  DECODE(BV.VERSION_TYPE,'COST', OPT.GEN_COST_RET_MANUAL_LINE_FLAG,
                         'REVENUE',OPT.GEN_REV_RET_MANUAL_LINE_FLAG,
                         'ALL',OPT.GEN_ALL_RET_MANUAL_LINE_FLAG),
  DECODE(BV.VERSION_TYPE,'COST', OPT.GEN_COST_ACTUAL_AMTS_THRU_CODE,
                         'REVENUE',OPT.GEN_REV_ACTUAL_AMTS_THRU_CODE,
                         'ALL',OPT.GEN_ALL_ACTUAL_AMTS_THRU_CODE),
  DECODE(BV.VERSION_TYPE,'COST', OPT.GEN_COST_INCL_UNSPENT_AMT_FLAG,
                         'REVENUE','N',
                         'ALL',OPT.GEN_ALL_INCL_UNSPENT_AMT_FLAG),
  OPT.PLAN_IN_MULTI_CURR_FLAG,
  decode(OPT.REVENUE_DERIVATION_METHOD,
       'COST','C',
       'WORK','T',
       'EVENT','E'), --Bug 5462471
  NVL(P.ORG_ID,-99)      ORG_ID,
  P.PROJECT_CURRENCY_CODE,
  P.PROJFUNC_CURRENCY_CODE,
  I.SET_OF_BOOKS_ID,
  FP.RAW_COST_FLAG,
  FP.BURDENED_COST_FLAG,
  FP.REVENUE_FLAG,
  FP.COST_QTY_FLAG,
  FP.REVENUE_QTY_FLAG,
  FP.ALL_QTY_FLAG,
  FP.BILL_RATE_FLAG,
  FP.COST_RATE_FLAG,
  FP.BURDEN_RATE_FLAG,
  DECODE(BV.WP_VERSION_FLAG,'Y',BV.PROJECT_STRUCTURE_VERSION_ID,
         PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(opt.project_id )),
  FB.PLAN_CLASS_CODE,
  BV.VERSION_TYPE,
  P.PROJECT_VALUE,
  OPT.TRACK_WORKPLAN_COSTS_FLAG,
  DECODE(BV.VERSION_TYPE,'COST', OPT.GEN_SRC_COST_WP_VERSION_ID,
                         'REVENUE',OPT.GEN_SRC_REV_WP_VERSION_ID,
                         'ALL',OPT.GEN_SRC_ALL_WP_VERSION_ID),
  DECODE(OPT1.FIN_PLAN_PREFERENCE_CODE,
         'COST_ONLY',OPT1.GEN_SRC_COST_WP_VER_CODE,
         'REVENUE_ONLY',OPT1.GEN_SRC_REV_WP_VER_CODE,
         'COST_AND_REV_SAME',OPT1.GEN_SRC_ALL_WP_VER_CODE,
         'COST_AND_REV_SEP',( DECODE(BV.VERSION_TYPE,
                            'COST', OPT1.GEN_SRC_COST_WP_VER_CODE,
                            'REVENUE',OPT1.GEN_SRC_REV_WP_VER_CODE)))
  INTO          X_FP_COLS_REC.X_PROJECT_ID,
                X_FP_COLS_REC.X_BUDGET_VERSION_ID,
                X_FP_COLS_REC.X_PROJ_FP_OPTIONS_ID,
                X_FP_COLS_REC.X_FIN_PLAN_TYPE_ID,
                X_FP_COLS_REC.X_AMOUNT_SET_ID,
                X_FP_COLS_REC.X_FIN_PLAN_LEVEL_CODE,
                X_FP_COLS_REC.X_TIME_PHASED_CODE,
                X_FP_COLS_REC.X_RESOURCE_LIST_ID,
                X_FP_COLS_REC.X_RES_PLANNING_LEVEL,
                X_FP_COLS_REC.X_RBS_VERSION_ID,
                X_FP_COLS_REC.X_COST_EMP_RATE_SCH_ID,
                X_FP_COLS_REC.X_REV_EMP_RATE_SCH_ID,
                X_FP_COLS_REC.X_COST_JOB_RATE_SCH_ID,
                X_FP_COLS_REC.X_REV_JOB_RATE_SCH_ID,
                X_FP_COLS_REC.X_CNON_LABOR_RES_RATE_SCH_ID,
                X_FP_COLS_REC.X_RNON_LABOR_RES_RATE_SCH_ID,
                X_FP_COLS_REC.X_COST_RES_CLASS_RATE_SCH_ID,
                X_FP_COLS_REC.X_REV_RES_CLASS_RATE_SCH_ID,
                X_FP_COLS_REC.X_BURDEN_RATE_SCH_ID,
                X_FP_COLS_REC.X_CURRENT_PLANNING_PERIOD,
                X_FP_COLS_REC.X_PERIOD_MASK_ID,
                X_FP_COLS_REC.X_GEN_SRC_PLAN_TYPE_ID,
                X_FP_COLS_REC.X_GEN_SRC_PLAN_VERSION_ID,
                X_FP_COLS_REC.X_GEN_SRC_PLAN_VER_CODE,
                X_FP_COLS_REC.X_GEN_SRC_CODE,
                X_FP_COLS_REC.X_GEN_ETC_SRC_CODE,
                X_FP_COLS_REC.X_GEN_INCL_CHANGE_DOC_FLAG,
                X_FP_COLS_REC.X_GEN_INCL_OPEN_COMM_FLAG,
                X_FP_COLS_REC.X_GEN_INCL_BILL_EVENT_FLAG,
                X_FP_COLS_REC.X_GEN_RET_MANUAL_LINE_FLAG,
                X_FP_COLS_REC.X_GEN_ACTUAL_AMTS_THRU_CODE,
                X_FP_COLS_REC.X_GEN_INCL_UNSPENT_AMT_FLAG,
                X_FP_COLS_REC.X_PLAN_IN_MULTI_CURR_FLAG,
                X_FP_COLS_REC.X_REVENUE_DERIVATION_METHOD,--Bug 5462471
                X_FP_COLS_REC.X_ORG_ID,
                X_FP_COLS_REC.X_PROJECT_CURRENCY_CODE,
                X_FP_COLS_REC.X_PROJFUNC_CURRENCY_CODE,
                X_FP_COLS_REC.X_SET_OF_BOOKS_ID,
                X_FP_COLS_REC.X_RAW_COST_FLAG,
                X_FP_COLS_REC.X_BURDENED_FLAG,
                X_FP_COLS_REC.X_REVENUE_FLAG,
                X_FP_COLS_REC.X_COST_QUANTITY_FLAG,
                X_FP_COLS_REC.X_REV_QUANTITY_FLAG,
                X_FP_COLS_REC.X_ALL_QUANTITY_FLAG,
                X_FP_COLS_REC.X_BILL_RATE_FLAG,
                X_FP_COLS_REC.X_COST_RATE_FLAG,
                X_FP_COLS_REC.X_BURDEN_RATE_FLAG,
                X_FP_COLS_REC.X_PROJECT_STRUCTURE_VERSION_ID,
                X_FP_COLS_REC.X_PLAN_CLASS_CODE,
                X_FP_COLS_REC.X_VERSION_TYPE,
                X_FP_COLS_REC.X_PROJECT_VALUE,
                X_FP_COLS_REC.X_TRACK_WORKPLAN_COSTS_FLAG,
                X_FP_COLS_REC.X_GEN_SRC_WP_VERSION_ID,
                X_FP_COLS_REC.X_GEN_SRC_WP_VER_CODE
  FROM          PA_BUDGET_VERSIONS BV, PA_PROJ_FP_OPTIONS OPT, PA_PROJ_FP_OPTIONS OPT1,
                PA_PROJECTS_ALL P, PA_IMPLEMENTATIONS_ALL I,
                PA_FIN_PLAN_AMOUNT_SETS FP,
                PA_FIN_PLAN_TYPES_B FB
  WHERE         BV.BUDGET_VERSION_ID      = P_BUDGET_VERSION_ID
  AND           OPT.PROJECT_ID            = BV.PROJECT_ID
  AND           OPT.FIN_PLAN_TYPE_ID      = BV.FIN_PLAN_TYPE_ID
  AND           OPT.FIN_PLAN_VERSION_ID   = P_BUDGET_VERSION_ID
  AND           P.PROJECT_ID              = BV.PROJECT_ID
  AND           I.ORG_ID                  = P.ORG_ID -- R12 MOAC 4447573: NVL(I.ORG_ID,-99) = NVL(P.ORG_ID,-99)
  AND           FP.FIN_PLAN_AMOUNT_SET_ID =
      DECODE(BV.VERSION_TYPE,'COST', OPT.COST_AMOUNT_SET_ID,
                         'REVENUE',OPT.REVENUE_AMOUNT_SET_ID,
                         'ALL',OPT.ALL_AMOUNT_SET_ID)
  AND           FB.FIN_PLAN_TYPE_ID = BV.FIN_PLAN_TYPE_ID
  AND           OPT1.PROJECT_ID     = BV.PROJECT_ID
  AND           OPT1.FIN_PLAN_OPTION_LEVEL_CODE = 'PLAN_TYPE'
  AND           OPT1.FIN_PLAN_TYPE_ID      = BV.FIN_PLAN_TYPE_ID;
/* Plan_ver_code is selected at PLAN_TYPE instead of PLAN_VERSION */

       --dbms_output.put_line('in utils after select');

    IF p_pa_debug_mode = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
    END IF;

EXCEPTION
   WHEN Invalid_Arg_Exc THEN
        X_MSG_COUNT := FND_MSG_PUB.count_msg;
        X_RETURN_STATUS:= FND_API.G_RET_STS_ERROR;
        IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        -- Bug 4621171: Removed RAISE statement.

      WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_data      := SUBSTR(SQLERRM,1,240);
           FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_AMOUNT_UTILS'
              ,p_procedure_name => 'GET_PLAN_VERSION_DTLS');
           IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
                   (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                    p_module_name => l_module_name,
                    p_log_level   => 5);
                PA_DEBUG.Reset_Curr_Function;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

 END GET_PLAN_VERSION_DTLS;

PROCEDURE CHK_CMT_TXN_CURRENCY
          (P_PROJECT_ID                     IN            NUMBER,
           P_PROJ_CURRENCY_CODE             IN            VARCHAR2,
	   X_MSG_COUNT                      OUT NOCOPY    NUMBER,
           X_MSG_DATA                       OUT NOCOPY    VARCHAR2,
	   X_RETURN_STATUS                  OUT NOCOPY    VARCHAR2)
IS
   l_flag varchar2(1):='N';
l_module_name         VARCHAR2(200) := 'pa.plsql.pa_fp_gen_amount_utils.chk_cmt_txn_currency';
BEGIN

    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

       IF p_pa_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function     => 'CHK_CMT_TXN_CURRENCY'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
       END IF;

   BEGIN
   SELECT 'Y'
   INTO   l_flag
   FROM   PA_COMMITMENT_TXNS
   WHERE  PROJECT_ID = P_PROJECT_ID
   AND    DENOM_CURRENCY_CODE <> P_PROJ_CURRENCY_CODE
   AND    NVL(generation_error_flag,'N') = 'N'
   AND    ROWNUM < 2;
   x_return_status := FND_API.G_RET_STS_ERROR;
   PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                         p_msg_name       => 'PA_FP_CMT_MUL_CURRENCY');

    IF p_pa_debug_mode = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
    END IF;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF p_pa_debug_mode = 'Y' THEN
          PA_DEBUG.Reset_Curr_Function;
      END IF;
   WHEN Invalid_Arg_Exc THEN
        X_MSG_COUNT := FND_MSG_PUB.count_msg;
        X_RETURN_STATUS:= FND_API.G_RET_STS_ERROR;
        IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RAISE;

  WHEN OTHERS THEN
     --dbms_output.put_line('inside excep');
     --dbms_output.put_line(SUBSTR(SQLERRM,1,240));
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      := SUBSTR(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_AMOUNT_UTILS'
              ,p_procedure_name => 'CHK_CMT_TXN_CURRENCY');
    IF p_pa_debug_mode = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

END CHK_CMT_TXN_CURRENCY;

PROCEDURE Get_Curr_Original_Version_Info(
          p_project_id              IN
          pa_projects_all.project_id%TYPE,
          p_fin_plan_type_id        IN
          pa_budget_versions.fin_plan_type_id%TYPE,
          p_version_type            IN
          pa_budget_versions.version_type%TYPE,
          p_status_code             IN   VARCHAR2,
          x_fp_options_id           OUT  NOCOPY
          pa_proj_fp_options.proj_fp_options_id%TYPE,
          x_fin_plan_version_id     OUT  NOCOPY
          pa_proj_fp_options.fin_plan_version_id%TYPE,
          x_return_status           OUT  NOCOPY VARCHAR2,
          x_msg_count               OUT  NOCOPY NUMBER,
          x_msg_data                OUT  NOCOPY VARCHAR2)
AS

l_module_name         VARCHAR2(200) := 'pa.plsql.pa_fp_gen_amount_utils.Get_Curr_Original_Version_Info';

    --Start of variables used for debugging
    l_msg_count          NUMBER :=0;
    l_data               VARCHAR2(2000);
    l_msg_data           VARCHAR2(2000);
    l_error_msg_code     VARCHAR2(30);
    l_msg_index_out      NUMBER;
    l_return_status      VARCHAR2(2000);
    l_debug_mode         VARCHAR2(30);
    --End of variables used for debugging

    l_fp_preference_code
         pa_proj_fp_options.fin_plan_preference_code%TYPE;
    l_version_type
         pa_budget_versions.version_type%TYPE;
    l_current_original_version_id
         pa_budget_versions.budget_version_id%TYPE;
    l_fp_options_id
         pa_proj_fp_options.proj_fp_options_id%TYPE;

BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function     => 'Get_Curr_Original_Version_Info'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
    END IF;

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

    -- Check for business rules violations

    IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Validating input parameters';

       pa_fp_gen_amount_utils.fp_debug
               (p_msg         => pa_debug.g_err_stage,
                p_module_name => l_module_name,
                p_log_level   => 5);
    END IF;

    IF (p_project_id       IS NULL) OR
       (p_fin_plan_type_id IS NULL)
    THEN

             IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Project_id = '||p_project_id;
                pa_fp_gen_amount_utils.fp_debug
                 (p_msg         => pa_debug.g_err_stage,
                  p_module_name => l_module_name,
                  p_log_level   => 5);

                pa_debug.g_err_stage:='Fin_plan_type_id = '||p_fin_plan_type_id;
                pa_fp_gen_amount_utils.fp_debug
                 (p_msg         => pa_debug.g_err_stage,
                  p_module_name => l_module_name,
                  p_log_level   => 5);
             END IF;

             PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    --Fetch fin plan preference code

    IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Fetching fin plan preference code ';
       pa_fp_gen_amount_utils.fp_debug
                 (p_msg         => pa_debug.g_err_stage,
                  p_module_name => l_module_name,
                  p_log_level   => 5);
    END IF;

    SELECT fin_plan_preference_code
    INTO   l_fp_preference_code
    FROM   pa_proj_fp_options
    WHERE  project_id = p_project_id
    AND    fin_plan_type_id = p_fin_plan_type_id
    AND    fin_plan_option_level_code =
           PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE;

    IF (l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP)
        AND (p_version_type IS NULL) THEN

          --In this case version_type should be passed and so raise error

          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Version_Type = '||p_version_type;
             pa_fp_gen_amount_utils.fp_debug
                 (p_msg         => pa_debug.g_err_stage,
                  p_module_name => l_module_name,
                  p_log_level   => 5);
          END IF;

          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                      p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Parameter validation complete ';
       pa_fp_gen_amount_utils.fp_debug
                 (p_msg         => pa_debug.g_err_stage,
                  p_module_name => l_module_name,
                  p_log_level   => 5);
    END IF;

    --Fetch  l_element_type ifn't passed and could be derived

    IF p_version_type IS NULL THEN

      IF l_fp_preference_code =
         PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME THEN

         l_version_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL;

      ELSIF l_fp_preference_code =
         PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY THEN

         l_version_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST;

      ELSIF l_fp_preference_code =
          PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY THEN

         l_version_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE;

      END IF;

    END IF;

    --Fetch the current original version

    BEGIN

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Fetching current original Version';
           pa_fp_gen_amount_utils.fp_debug
                 (p_msg         => pa_debug.g_err_stage,
                  p_module_name => l_module_name,
                  p_log_level   => 5);
        END IF;

        IF p_status_code = 'CURRENT_BASELINED'
           OR p_status_code = 'CURRENT_APPROVED' THEN
            SELECT budget_version_id
            INTO   l_current_original_version_id
            FROM   pa_budget_versions
            WHERE  project_id = p_project_id
            AND    fin_plan_type_id = p_fin_plan_type_id
            AND    version_type = NVL(p_version_type,l_version_type)
            AND    budget_status_code = 'B'
            AND    current_flag = 'Y';
        ELSIF p_status_code = 'ORIGINAL_BASELINED'
              OR p_status_code = 'ORIGINAL_APPROVED' THEN
            SELECT budget_version_id
            INTO   l_current_original_version_id
            FROM   pa_budget_versions
            WHERE  project_id = p_project_id
            AND    fin_plan_type_id = p_fin_plan_type_id
            AND    version_type = NVL(p_version_type,l_version_type)
            AND    budget_status_code = 'B'
            AND    current_original_flag = 'Y';
        END IF;

        --Fetch fp options id using plan version id

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Fetching fp option id';
           pa_fp_gen_amount_utils.fp_debug
                 (p_msg         => pa_debug.g_err_stage,
                  p_module_name => l_module_name,
                  p_log_level   => 5);
        END IF;

        SELECT proj_fp_options_id
        INTO   l_fp_options_id
        FROM   pa_proj_fp_options
        WHERE  fin_plan_version_id = l_current_original_version_id;

    EXCEPTION

      WHEN NO_DATA_FOUND THEN

             l_current_original_version_id := NULL;
             l_fp_options_id := NULL;

    END;

    -- return the parameters to calling programme
    x_fin_plan_version_id := l_current_original_version_id;
    x_fp_options_id := l_fp_options_id;

    IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Exiting Get_Curr_Original_Version_Info';
       pa_fp_gen_amount_utils.fp_debug
                 (p_msg         => pa_debug.g_err_stage,
                  p_module_name => l_module_name,
                  p_log_level   => 5);
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

               x_msg_data := l_data;
               x_msg_count := l_msg_count;
          ELSE
              x_msg_count := l_msg_count;
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;

          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Invalid Arguments Passed';
             pa_fp_gen_amount_utils.fp_debug
                 (p_msg         => pa_debug.g_err_stage,
                  p_module_name => l_module_name,
                  p_log_level   => 5);

             -- reset error stack
          PA_DEBUG.Reset_Curr_Function;
          END IF;
          RETURN;

     WHEN Others THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'PA_FP_GEN_AMOUNT_UTILS'
                                  ,p_procedure_name  => 'Get_Curr_Original_Version_Info');

          IF l_debug_mode = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
                   (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                    p_module_name => l_module_name,
                    p_log_level   => 5);
                PA_DEBUG.Reset_Curr_Function;
          END IF;
          RAISE;
END Get_Curr_Original_Version_Info;

PROCEDURE VALIDATE_PLAN_VERSION
          (P_PROJECT_ID                     IN
           PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_SRC_BDGT_VERSION_ID            IN
           PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_TRGT_BDGT_VERSION_ID           IN
           PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
	   X_MSG_COUNT                      OUT NOCOPY    NUMBER,
           X_MSG_DATA                       OUT NOCOPY    VARCHAR2,
	   X_RETURN_STATUS                  OUT NOCOPY    VARCHAR2) IS

l_fp_cols_rec                PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
l_module_name         VARCHAR2(200) := 'pa.plsql.pa_fp_gen_amount_utils.validate_plan_version';

BEGIN

    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' THEN
         pa_debug.set_curr_function( p_function     => 'VALIDATE_PLAN_VERSION'
                                    ,p_debug_mode   =>  p_pa_debug_mode);
    END IF;

--Calling the Util API
      IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                               PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS',
              p_module_name => l_module_name,
              p_log_level   => 5);
     END IF;
  PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
                         (P_PROJECT_ID           => P_PROJECT_ID,
                          P_BUDGET_VERSION_ID    => P_SRC_BDGT_VERSION_ID,
                          X_FP_COLS_REC          => l_fp_cols_rec,
                          X_RETURN_STATUS        => X_RETURN_STATUS,
                          X_MSG_COUNT            => X_MSG_COUNT,
                          X_MSG_DATA	         => X_MSG_DATA);
     IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;
     IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling
                              PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS: '
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
      END IF;
     --dbms_output.put_line('Status of get plan version dtls api: '||X_RETURN_STATUS);

     IF l_fp_cols_rec.X_TIME_PHASED_CODE <> 'P' OR l_fp_cols_rec.X_TIME_PHASED_CODE <> 'G' THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                               p_msg_name       => 'PA_FP_INV_TIME_PHASE_CODE');
     END IF;

    IF p_pa_debug_mode = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
    END IF;


EXCEPTION

      WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_data      := SUBSTR(SQLERRM,1,240);
           FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_AMOUNT_UTILS'
              ,p_procedure_name => 'VALIDATE_PLAN_VERSION');
           IF p_pa_debug_mode = 'Y' THEN
               PA_DEBUG.Reset_Curr_Function;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END VALIDATE_PLAN_VERSION;

PROCEDURE GET_VALUES_FOR_PLANNING_RATE
          (P_PROJECT_ID                  IN
               PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID           IN
               PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_RESOURCE_ASSIGNMENT_ID      IN
               PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE,
           P_TASK_ID                     IN
               PA_TASKS.TASK_ID%TYPE,
	   P_RESOURCE_LIST_MEMBER_ID     IN
               PA_RESOURCE_ASSIGNMENTS.resource_list_member_id%TYPE,
	   P_TXN_CURRENCY_CODE           IN
               PA_BUDGET_LINES.txn_currency_code%TYPE,
           X_RES_FORMAT_ID               OUT   NOCOPY
               PA_RESOURCE_LIST_MEMBERS.RES_FORMAT_ID%TYPE,
           X_RESOURCE_ASN_REC            OUT   NOCOPY  RESOURCE_ASN_REC,
           X_PA_TASKS_REC                OUT   NOCOPY  PA_TASKS_REC,
           X_PA_PROJECTS_ALL_REC         OUT   NOCOPY  PA_PROJECTS_ALL_REC,
           X_PROJ_FP_OPTIONS_REC         OUT   NOCOPY  PROJ_FP_OPTIONS_REC,
	   X_RETURN_STATUS               OUT   NOCOPY  VARCHAR2,
           X_MSG_COUNT                   OUT   NOCOPY  NUMBER,
           X_MSG_DATA	                 OUT   NOCOPY  VARCHAR2) IS

l_module_name         VARCHAR2(200) := 'pa.plsql.pa_fp_gen_amount_utils.get_values_for_planning_rate';

  CURSOR get_resource_asn_csr (c_resource_assignment_id IN NUMBER) IS
     SELECT project_id
           ,task_id
           ,unit_of_measure
           ,resource_class_code
           ,organization_id
           ,job_id
           ,person_id
           ,expenditure_type
           ,non_labor_resource
           ,bom_resource_id
           ,inventory_item_id
           ,item_category_id
           ,mfc_cost_type_id
           ,rate_based_flag
           ,rate_expenditure_org_id
           ,rate_expenditure_type
       FROM pa_resource_assignments ra
      WHERE ra.resource_assignment_id = c_resource_assignment_id;

  --get_resource_asn_rec    get_resource_asn_csr%ROWTYPE;

  CURSOR get_tasks_csr(c_task_id IN NUMBER) IS
     SELECT non_labor_bill_rate_org_id
           ,non_labor_schedule_discount
           ,non_labor_schedule_fixed_date
           ,non_lab_std_bill_rt_sch_id
           ,emp_bill_rate_schedule_id
           ,job_bill_rate_schedule_id
           ,labor_bill_rate_org_id
           ,labor_sch_type
           ,non_labor_sch_type
           ,top_task_id
       FROM pa_tasks t
      WHERE t.task_id = c_task_id;

  --get_tasks_rec           get_tasks_csr%ROWTYPE;

  CURSOR get_projects_all_csr (c_proj_id IN NUMBER) IS
    SELECT assign_precedes_task
          ,bill_job_group_id
          ,carrying_out_organization_id
          ,multi_currency_billing_flag
          ,org_id
          ,non_labor_bill_rate_org_id
          ,project_currency_code
          ,non_labor_schedule_discount
          ,non_labor_schedule_fixed_date
          ,non_lab_std_bill_rt_sch_id
          ,project_type
          ,projfunc_currency_code
          ,emp_bill_rate_schedule_id
          ,job_bill_rate_schedule_id
          ,labor_bill_rate_org_id
          ,labor_sch_type
          ,non_labor_sch_type
      FROM pa_projects_all ppa
     WHERE ppa.project_id = c_proj_id;


  --get_projects_all_rec    get_projects_all_csr%ROWTYPE;




   CURSOR get_proj_fp_options_csr IS
    SELECT decode(pfo.use_planning_rates_flag,'N',
           pfo.res_class_bill_rate_sch_id,
           decode(bv.version_type,'REVENUE',
           pfo.rev_res_class_rate_sch_id,
           'ALL'    ,pfo.rev_res_class_rate_sch_id,
              NULL)) res_class_bill_rate_sch_id
          ,decode(pfo.use_planning_rates_flag,'N',
           pfo.res_class_raw_cost_sch_id,
          decode(bv.version_type,'COST',
          pfo.cost_res_class_rate_sch_id, 'ALL',
          pfo.cost_res_class_rate_sch_id,
          NULL)) res_class_raw_cost_sch_id
          ,pfo.use_planning_rates_flag
          ,decode(pfo.use_planning_rates_flag,'N',null,
          decode(bv.version_type,'REVENUE',
          pfo.rev_job_rate_sch_id, 'ALL',
          pfo.rev_job_rate_sch_id, NULL)) rev_job_rate_sch_id
          ,decode(pfo.use_planning_rates_flag,'N',null,
          decode(bv.version_type,'COST',
          pfo.cost_job_rate_sch_id, 'ALL',
          pfo.cost_job_rate_sch_id, NULL)) cost_job_rate_sch_id
          ,decode(pfo.use_planning_rates_flag,'N',null,
          decode(bv.version_type,'REVENUE',
          pfo.rev_emp_rate_sch_id, 'ALL',
          pfo.rev_emp_rate_sch_id, NULL))    rev_emp_rate_sch_id
          ,decode(pfo.use_planning_rates_flag,'N',null,
          decode(bv.version_type,'COST',
          pfo.cost_emp_rate_sch_id, 'ALL',
          pfo.cost_emp_rate_sch_id, NULL))     cost_emp_rate_sch_id
          ,decode(pfo.use_planning_rates_flag,'N',null,
          decode(bv.version_type,'REVENUE',
          pfo.rev_non_labor_res_rate_sch_id, 'ALL',
          pfo.rev_non_labor_res_rate_sch_id, NULL))
          rev_non_labor_res_rate_sch_id
          ,decode(pfo.use_planning_rates_flag,'N',null,
          decode(bv.version_type,'COST'   ,
          pfo.cost_non_labor_res_rate_sch_id,'ALL',
          pfo.cost_non_labor_res_rate_sch_id, NULL))
          cost_non_labor_res_rate_sch_id
          ,decode(pfo.use_planning_rates_flag,'N',null,
          decode(bv.version_type,'COST',
          pfo.cost_burden_rate_sch_id,'ALL',
          pfo.cost_burden_rate_sch_id, NULL))
          cost_burden_rate_sch_id
          ,bv.version_type
      FROM pa_proj_fp_options pfo,
           pa_budget_versions bv
      WHERE pfo.fin_plan_version_id = bv.budget_version_id
      AND bv.budget_version_id = p_budget_version_id;

     --get_proj_fp_options_rec    get_proj_fp_options_csr%ROWTYPE;


/*
  --Local variables for pa_resource_assignments table
    g_project_id                       pa_resource_assignments.project_id%TYPE;
    l_rate_task_id                     pa_resource_assignments.task_id%TYPE;
    l_unit_of_measure                  pa_resource_assignments.unit_of_measure%TYPE;
    l_resource_class_code              pa_resource_assignments.resource_class_code%TYPE;
    l_organization_id                  pa_resource_assignments.organization_id%TYPE;
    l_job_id                           pa_resource_assignments.job_id%TYPE;
    l_person_id                        pa_resource_assignments.person_id%TYPE;
    l_expenditure_type                 pa_resource_assignments.expenditure_type%TYPE;
    l_non_labor_resource               pa_resource_assignments.non_labor_resource%TYPE;
    l_bom_resource_id                  pa_resource_assignments.bom_resource_id%TYPE;
    l_inventory_item_id                pa_resource_assignments.inventory_item_id%TYPE;
    l_item_category_id                 pa_resource_assignments.item_category_id%TYPE;
    l_mfc_cost_type_id                 pa_resource_assignments.mfc_cost_type_id%TYPE;
    l_rate_based_flag                  pa_resource_assignments.rate_based_flag%TYPE;
    l_rate_incurred_by_organz_id       pa_resource_assignments.rate_incurred_by_organz_id%TYPE;
    l_rate_override_to_organz_id       pa_resource_assignments.rate_override_to_organz_id%TYPE;
    l_rate_expenditure_org_id          pa_resource_assignments.rate_expenditure_org_id%TYPE;
    l_rate_expenditure_type            pa_resource_assignments.rate_expenditure_type%TYPE;
    l_rate_organization_id             pa_resource_assignments.rate_organization_id%TYPE;
    l_nlr_organization_id              pa_resource_assignments.organization_id%TYPE;

-- Local variables for pa_tasks table
    l_task_bill_rate_org_id            pa_tasks.non_labor_bill_rate_org_id%TYPE;
    l_task_sch_discount                pa_tasks.non_labor_schedule_discount%TYPE;
    l_task_sch_date                    pa_tasks.non_labor_schedule_fixed_date%TYPE;
    l_task_nl_std_bill_rt_sch_id       pa_tasks.non_lab_std_bill_rt_sch_id%TYPE;
    l_task_emp_bill_rate_sch_id        pa_tasks.emp_bill_rate_schedule_id%TYPE;
    l_task_job_bill_rate_sch_id        pa_tasks.job_bill_rate_schedule_id%TYPE;
    l_task_lab_bill_rate_org_id        pa_tasks.labor_bill_rate_org_id%TYPE;
    l_task_lab_sch_type                pa_tasks.labor_sch_type%TYPE;
    l_task_non_labor_sch_type          pa_tasks.non_labor_sch_type%TYPE;
    l_top_task_id                      pa_tasks.top_task_id%TYPE;
    l_lab_sch_type                     pa_tasks.emp_bill_rate_schedule_id%TYPE;

-- Local variables for pa_projects_all table
    l_assign_precedes_task             pa_projects_all.assign_precedes_task%TYPE;
    l_bill_job_group_id                pa_projects_all.bill_job_group_id%TYPE;
    l_carrying_out_organization_id     pa_projects_all.carrying_out_organization_id%TYPE;
    l_multi_currency_billing_flag      pa_projects_all.multi_currency_billing_flag%TYPE;
    l_org_id                           pa_projects_all.org_id%TYPE;
    l_project_bill_rate_org_id         pa_projects_all.non_labor_bill_rate_org_id%TYPE;
    l_project_sch_discount             pa_projects_all.non_labor_schedule_discount%TYPE;
    l_project_sch_date                 pa_projects_all.non_labor_schedule_fixed_date%TYPE;
    l_proj_nl_std_bill_rt_sch_id       pa_projects_all.non_lab_std_bill_rt_sch_id%TYPE;
    l_project_type                     pa_projects_all.project_type%TYPE;
    l_project_currency_code            pa_projects_all.project_currency_code%TYPE;
    l_projfunc_currency_code           pa_projects_all.projfunc_currency_code%TYPE;
    l_proj_emp_bill_rate_sch_id        pa_projects_all.emp_bill_rate_schedule_id%TYPE;
    l_proj_job_bill_rate_sch_id        pa_projects_all.job_bill_rate_schedule_id%TYPE;
    l_proj_lab_bill_rate_org_id        pa_projects_all.labor_bill_rate_org_id%TYPE;
    l_proj_lab_sch_type                pa_projects_all.labor_sch_type%TYPE;
    l_proj_non_labor_sch_type          pa_projects_all.non_labor_sch_type%TYPE;
    l_non_labor_sch_type               pa_projects_all.non_labor_sch_type%TYPE;
    l_lab_bill_rate_org_id             pa_projects_all.labor_bill_rate_org_id%TYPE;
    l_job_bill_rate_sch_id             pa_projects_all.job_bill_rate_schedule_id%TYPE;
    l_emp_bill_rate_sch_id             pa_projects_all.emp_bill_rate_schedule_id%TYPE;

-- Local variables for pa_resource_list_members table
    l_res_format_id                    pa_resource_list_members.res_format_id%TYPE;

-- Local variables for pa_proj_fp_options table
    l_fp_res_cl_bill_rate_sch_id       pa_proj_fp_options.res_class_bill_rate_sch_id%TYPE;
    l_fp_res_cl_raw_cost_sch_id        pa_proj_fp_options.res_class_raw_cost_sch_id%TYPE;
    l_fp_use_planning_rt_flag          pa_proj_fp_options.use_planning_rates_flag%TYPE;
    l_fp_rev_job_rate_sch_id           pa_proj_fp_options.rev_job_rate_sch_id%TYPE;
    l_fp_cost_job_rate_sch_id          pa_proj_fp_options.cost_job_rate_sch_id%TYPE;
    l_fp_rev_emp_rate_sch_id           pa_proj_fp_options.rev_emp_rate_sch_id%TYPE;
    l_fp_cost_emp_rate_sch_id          pa_proj_fp_options.cost_emp_rate_sch_id%TYPE;
    l_fp_rev_non_lab_rs_rt_sch_id      pa_proj_fp_options.rev_non_labor_res_rate_sch_id%TYPE;
    l_fp_cost_non_lab_rs_rt_sch_id     pa_proj_fp_options.cost_non_labor_res_rate_sch_id%TYPE;
    l_fp_cost_burden_rate_sch_id       pa_proj_fp_options.cost_burden_rate_sch_id%TYPE;
    l_fp_budget_version_type           pa_budget_versions.version_type%TYPE;

-- Local variables for pa_fp_rollup_tmp table
    l_txn_currency_code                 pa_fp_rollup_tmp.txn_currency_code%TYPE := NULL;
    l_txn_plan_quantity                 pa_fp_rollup_tmp.quantity%TYPE := NULL;
    l_budget_lines_start_date           pa_fp_rollup_tmp.start_date%TYPE := NULL;
    l_budget_line_id                    pa_fp_rollup_tmp.budget_line_id%TYPE := NULL;
    l_burden_cost_rate_override         pa_fp_rollup_tmp.burden_cost_rate_override%TYPE := NULL;
    l_rw_cost_rate_override             pa_fp_rollup_tmp.rw_cost_rate_override%TYPE := NULL;
    l_bill_rate_override                pa_fp_rollup_tmp.bill_rate_override%TYPE := NULL;
    l_txn_raw_cost                      pa_fp_rollup_tmp.txn_raw_cost%TYPE := NULL;
    l_txn_burdened_cost                 pa_fp_rollup_tmp.txn_burdened_cost%TYPE := NULL;
    l_txn_revenue                       pa_fp_rollup_tmp.txn_revenue%TYPE := NULL;


    l_txn_currency_code_override        pa_fp_res_assignments_tmp.txn_currency_code_override%TYPE;
    l_assignment_id                     pa_project_assignments.assignment_id%TYPE := NULL;
    l_cost_rate_multiplier              CONSTANT pa_labor_cost_multipliers.multiplier%TYPE := 1;

    l_bill_rate_multiplier              CONSTANT NUMBER := 1;
    l_cost_sch_type                     VARCHAR2(30) := 'COST';
    l_mfc_cost_source                   CONSTANT NUMBER := 2;
    l_calculate_mode                    VARCHAR2(60); */

    l_count			        NUMBER;
    l_msg_count		                NUMBER;
    l_data			        VARCHAR2(2000);
    l_msg_data		                VARCHAR2(2000);
    l_msg_index_out                     NUMBER;

BEGIN

    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' THEN
         pa_debug.set_curr_function( p_function     => 'GET_VALUES_FOR_PLANNING_RATE'
                                    ,p_debug_mode   =>  p_pa_debug_mode);
    END IF;


    OPEN  get_resource_asn_csr(p_resource_assignment_id);
    FETCH get_resource_asn_csr INTO x_resource_asn_rec;
    CLOSE  get_resource_asn_csr;

/*    g_project_id                       := get_resource_asn_rec.project_id;
    l_rate_task_id                     := get_resource_asn_rec.task_id;
    l_unit_of_measure                  := get_resource_asn_rec.unit_of_measure;
    l_resource_class_code              := get_resource_asn_rec.resource_class_code;
    l_organization_id                  := get_resource_asn_rec.organization_id;
    l_job_id                           := get_resource_asn_rec.job_id;
    l_person_id                        := get_resource_asn_rec.person_id;
    l_expenditure_type                 := get_resource_asn_rec.expenditure_type;
    l_non_labor_resource               := get_resource_asn_rec.non_labor_resource;
    l_bom_resource_id                  := get_resource_asn_rec.bom_resource_id;
    l_inventory_item_id                := get_resource_asn_rec.inventory_item_id;
    l_item_category_id                 := get_resource_asn_rec.item_category_id;
    l_mfc_cost_type_id                 := get_resource_asn_rec.mfc_cost_type_id;
    l_rate_based_flag                  := get_resource_asn_rec.rate_based_flag;
    l_rate_incurred_by_organz_id       := get_resource_asn_rec.rate_incurred_by_organz_id;
    l_rate_override_to_organz_id       := get_resource_asn_rec.rate_override_to_organz_id;
    l_rate_expenditure_org_id          := get_resource_asn_rec.rate_expenditure_org_id;
    l_rate_expenditure_type            := get_resource_asn_rec.rate_expenditure_type;
    l_rate_organization_id             := get_resource_asn_rec.rate_organization_id; */

   OPEN get_projects_all_csr(p_project_id);
   FETCH get_projects_all_csr INTO x_pa_projects_all_rec;
   CLOSE get_projects_all_csr;

/*    l_assign_precedes_task             := get_projects_all_rec.assign_precedes_task;
    l_bill_job_group_id                := get_projects_all_rec.bill_job_group_id;
    l_carrying_out_organization_id     := get_projects_all_rec.carrying_out_organization_id;
    l_multi_currency_billing_flag      := get_projects_all_rec.multi_currency_billing_flag;
    l_org_id                           := get_projects_all_rec.org_id;
    l_project_bill_rate_org_id         := get_projects_all_rec.non_labor_bill_rate_org_id;
    l_project_currency_code            := get_projects_all_rec.project_currency_code;
    l_project_sch_discount             := get_projects_all_rec.non_labor_schedule_discount;
    l_project_sch_date                 := get_projects_all_rec.non_labor_schedule_fixed_date;
    l_proj_nl_std_bill_rt_sch_id       := get_projects_all_rec.non_lab_std_bill_rt_sch_id;
    l_project_type                     := get_projects_all_rec.project_type;
    l_projfunc_currency_code           := get_projects_all_rec.projfunc_currency_code;
    l_proj_emp_bill_rate_sch_id        := get_projects_all_rec.emp_bill_rate_schedule_id;
    l_proj_job_bill_rate_sch_id        := get_projects_all_rec.job_bill_rate_schedule_id;
    l_proj_lab_bill_rate_org_id        := get_projects_all_rec.labor_bill_rate_org_id;
    l_proj_lab_sch_type                := get_projects_all_rec.labor_sch_type;
    l_proj_non_labor_sch_type          := get_projects_all_rec.non_labor_sch_type; */


       OPEN   get_tasks_csr(p_task_id);
       FETCH  get_tasks_csr INTO x_pa_tasks_rec;
       CLOSE  get_tasks_csr;

/*
      IF get_tasks_csr%NOTFOUND THEN

        l_task_bill_rate_org_id            := NULL;
        l_task_sch_discount                := NULL;
        l_task_sch_date                    := NULL;
        l_task_nl_std_bill_rt_sch_id       := NULL;
        l_task_emp_bill_rate_sch_id        := NULL;
        l_task_job_bill_rate_sch_id        := NULL;
        l_task_lab_bill_rate_org_id        := NULL;
        l_task_lab_sch_type                := NULL;
        l_task_non_labor_sch_type          := NULL;
        l_top_task_id                      := NULL;
        l_rate_task_id                 := NULL;

       --If task level attributes are not found
       --then the following atributes can be taken from the project level

         l_emp_bill_rate_sch_id     := l_proj_emp_bill_rate_sch_id;
         l_job_bill_rate_sch_id     := l_proj_job_bill_rate_sch_id;
         l_lab_bill_rate_org_id     := l_proj_lab_bill_rate_org_id;
         l_lab_sch_type             := l_proj_lab_sch_type;
         l_non_labor_sch_type       := l_proj_non_labor_sch_type;

      ELSE

         l_task_bill_rate_org_id            := get_tasks_rec.non_labor_bill_rate_org_id;
         l_task_sch_discount                := get_tasks_rec.non_labor_schedule_discount;
         l_task_sch_date                    := get_tasks_rec.non_labor_schedule_fixed_date;
         l_task_nl_std_bill_rt_sch_id       := get_tasks_rec.non_lab_std_bill_rt_sch_id;
         l_task_emp_bill_rate_sch_id        := get_tasks_rec.emp_bill_rate_schedule_id;
         l_task_job_bill_rate_sch_id        := get_tasks_rec.job_bill_rate_schedule_id;
         l_task_lab_bill_rate_org_id        := get_tasks_rec.labor_bill_rate_org_id;
         l_task_lab_sch_type                := get_tasks_rec.labor_sch_type;
         l_task_non_labor_sch_type          := get_tasks_rec.non_labor_sch_type;
         l_top_task_id                      := get_tasks_rec.top_task_id;

         --Task level attributes are found
         --the following atributes can be taken from the task level

         l_emp_bill_rate_sch_id             := l_task_emp_bill_rate_sch_id;
         l_job_bill_rate_sch_id             := l_task_job_bill_rate_sch_id;
         l_lab_bill_rate_org_id             := l_task_lab_bill_rate_org_id;
         l_lab_sch_type                     := l_task_lab_sch_type;
         l_non_labor_sch_type               := l_task_non_labor_sch_type;

      END IF; */


     SELECT  res_format_id
     INTO    x_res_format_id
     FROM    pa_resource_list_members
     WHERE   resource_list_member_id = p_resource_list_member_id;

    OPEN  get_proj_fp_options_csr;
    FETCH get_proj_fp_options_csr INTO x_proj_fp_options_rec;
    CLOSE get_proj_fp_options_csr;

/*
    l_fp_res_cl_bill_rate_sch_id       := get_proj_fp_options_rec.res_class_bill_rate_sch_id;
    l_fp_res_cl_raw_cost_sch_id        := get_proj_fp_options_rec.res_class_raw_cost_sch_id;
    l_fp_use_planning_rt_flag          := get_proj_fp_options_rec.use_planning_rates_flag;
    l_fp_rev_job_rate_sch_id           := get_proj_fp_options_rec.rev_job_rate_sch_id;
    l_fp_cost_job_rate_sch_id          := get_proj_fp_options_rec.cost_job_rate_sch_id;
    l_fp_rev_emp_rate_sch_id           := get_proj_fp_options_rec.rev_emp_rate_sch_id;
    l_fp_cost_emp_rate_sch_id          := get_proj_fp_options_rec.cost_emp_rate_sch_id;
    l_fp_rev_non_lab_rs_rt_sch_id      := get_proj_fp_options_rec.rev_non_labor_res_rate_sch_id;
    l_fp_cost_non_lab_rs_rt_sch_id     := get_proj_fp_options_rec.cost_non_labor_res_rate_sch_id;
    l_fp_cost_burden_rate_sch_id       := get_proj_fp_options_rec.cost_burden_rate_sch_id;
    l_fp_budget_version_type           := get_proj_fp_options_rec.version_type;

    IF l_fp_budget_version_type = 'REVENUE' THEN
      x_calculate_mode  := 'REVENUE';
    ELSIF l_fp_budget_version_type = 'COST' THEN
      x_calculate_mode  := 'COST';
    ELSIF l_fp_budget_version_type = 'ALL' THEN
      x_calculate_mode  := 'COST_REVENUE';
    END IF;

    l_nlr_organization_id  := NVL(l_organization_id,l_rate_organization_id);

    IF l_txn_currency_code_override IS NULL THEN
        l_txn_currency_code_override := l_txn_currency_code;
    ELSE
       l_txn_currency_code := l_txn_currency_code_override;
    END IF;

      --Calling  the Get_planning_Rates api
        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_called_mode => p_called_mode,
              p_msg         => 'Before calling
                                pa_plan_revenue.Get_planning_Rates',
              p_module_name => l_module_name,
              p_log_level   => 5);
        END IF;
        PA_PLAN_REVENUE.GET_PLANNING_RATES (
                        p_project_id                           => g_project_id
                       ,p_task_id                              => l_rate_task_id
                       ,p_top_task_id                          => l_top_task_id
                       ,p_person_id                            => l_person_id
                       ,p_job_id                               => l_job_id
                       ,p_bill_job_grp_id                      => l_bill_job_group_id
                       ,p_resource_class                       => l_resource_class_code
                       ,p_planning_resource_format             => l_res_format_id
                       ,p_use_planning_rates_flag              => l_fp_use_planning_rt_flag
                       ,p_rate_based_flag                      => l_rate_based_flag
                       ,p_uom                                  => l_unit_of_measure
                       ,p_system_linkage                       => NULL
                       ,p_project_organz_id                    => l_carrying_out_organization_id
                       ,p_rev_res_class_rate_sch_id            => l_fp_res_cl_bill_rate_sch_id
                       ,p_cost_res_class_rate_sch_id           => l_fp_res_cl_raw_cost_sch_id
                       ,p_rev_task_nl_rate_sch_id              => l_task_nl_std_bill_rt_sch_id
                       ,p_rev_proj_nl_rate_sch_id              => l_proj_nl_std_bill_rt_sch_id
                       ,p_rev_job_rate_sch_id                  => l_job_bill_rate_sch_id
                       ,p_rev_emp_rate_sch_id                  => l_emp_bill_rate_sch_id
                       ,p_plan_rev_job_rate_sch_id             => l_fp_rev_job_rate_sch_id
                       ,p_plan_cost_job_rate_sch_id            => l_fp_cost_job_rate_sch_id
                       ,p_plan_rev_emp_rate_sch_id             => l_fp_rev_emp_rate_sch_id
                       ,p_plan_cost_emp_rate_sch_id            => l_fp_cost_emp_rate_sch_id
                       ,p_plan_rev_nlr_rate_sch_id             => l_fp_rev_non_lab_rs_rt_sch_id
                       ,p_plan_cost_nlr_rate_sch_id            => l_fp_cost_non_lab_rs_rt_sch_id
                       ,p_plan_burden_cost_sch_id              => l_fp_cost_burden_rate_sch_id
                       ,p_calculate_mode                       => l_calculate_mode
                       ,p_mcb_flag                             => l_multi_currency_billing_flag
                       ,p_cost_rate_multiplier                 => l_cost_rate_multiplier
                       ,p_bill_rate_multiplier                 => l_bill_rate_multiplier
                       ,p_quantity                             => l_txn_plan_quantity
                       ,p_item_date                            => l_budget_lines_start_date
                       ,p_cost_sch_type                        => l_cost_sch_type
                       ,p_labor_sch_type                       => l_lab_sch_type
                       ,p_non_labor_sch_type                   => l_non_labor_sch_type
                       ,p_labor_schdl_discnt                   => NULL
                       ,p_labor_bill_rate_org_id               => l_lab_bill_rate_org_id
                       ,p_labor_std_bill_rate_schdl            => NULL
                       ,p_labor_schdl_fixed_date               => NULL
                       ,p_assignment_id                        => l_assignment_id
                       ,p_project_org_id                       => l_org_id
                       ,p_project_type                         => l_project_type
                       ,p_expenditure_type                     => nvl(l_expenditure_type,
                                                                      l_rate_expenditure_type)
                       ,p_non_labor_resource                   => l_non_labor_resource
                       ,p_incurred_by_organz_id                => l_organization_id
                       ,p_override_to_organz_id                => l_organization_id
                       ,p_expenditure_org_id                   => nvl(l_rate_expenditure_org_id,
                                                                      l_org_id)
                       ,p_assignment_precedes_task             => l_assign_precedes_task
                       ,p_planning_transaction_id              => l_budget_line_id
                       ,p_task_bill_rate_org_id                => l_task_bill_rate_org_id
                       ,p_project_bill_rate_org_id             => l_project_bill_rate_org_id
                       ,p_nlr_organization_id                  => nvl(l_nlr_organization_id,
                                                                      l_carrying_out_organization_id)
                       ,p_project_sch_date                     => l_project_sch_date
                       ,p_task_sch_date                        => l_task_sch_date
                       ,p_project_sch_discount                 => l_project_sch_discount
                       ,p_task_sch_discount                    => l_task_sch_discount
                       ,p_inventory_item_id                    => l_inventory_item_id
                       ,p_BOM_resource_Id                      => l_bom_resource_id
                       ,P_mfc_cost_type_id                     => l_mfc_cost_type_id
                       ,P_item_category_id                     => l_item_category_id
                       ,p_mfc_cost_source                      => l_mfc_cost_source
                       ,p_cost_override_rate                   => l_rw_cost_rate_override
                       ,p_revenue_override_rate                => l_bill_rate_override
                       ,p_override_burden_cost_rate            => l_burden_cost_rate_override
                       ,p_override_currency_code               => l_txn_currency_code_override
                       ,p_txn_currency_code                    => l_txn_currency_code
                       ,p_raw_cost                             => l_txn_raw_cost
                       ,p_burden_cost                          => l_txn_burdened_cost
                       ,p_raw_revenue                          => l_txn_revenue
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
                       ,x_return_status                        => x_return_status
                       ,x_msg_data                             => x_msg_data
                       ,x_msg_count                            => x_msg_count);
                  IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;
                  IF p_pa_debug_mode = 'Y' THEN
                     pa_fp_gen_amount_utils.fp_debug
                     (p_called_mode => p_called_mode,
                      p_msg         => 'Status after calling
                              pa_plan_revenue.Get_planning_Rates'
                              ||x_return_status,
                      p_module_name => l_module_name,
                      p_log_level   => 5);
                  END IF;
           --dbms_output.put_line('Status of Get_planning_Rates api: '||X_RETURN_STATUS);

 */

    IF p_pa_debug_mode = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
    END IF;

EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count = 1 THEN
            PA_INTERFACE_UTILS_PUB.get_messages
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
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Invalid Arguments Passed',
              p_module_name => l_module_name,
              p_log_level   => 5);
              PA_DEBUG.Reset_Curr_Function;
        END IF;
        RAISE;

  WHEN OTHERS THEN
     --dbms_output.put_line('inside excep');
     --dbms_output.put_line(SUBSTR(SQLERRM,1,240));
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      := SUBSTR(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_AMOUNT_UTILS'
              ,p_procedure_name => 'GET_VALUES_FOR_PLANNING_RATE');
     IF p_pa_debug_mode = 'Y' THEN
         PA_DEBUG.Reset_Curr_Function;
     END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GET_VALUES_FOR_PLANNING_RATE;

PROCEDURE FP_DEBUG
          (P_CALLED_MODE    IN   VARCHAR2,
           P_MSG            IN   VARCHAR2,
           P_MODULE_NAME    IN   VARCHAR2,
           P_LOG_LEVEL      IN   NUMBER) IS
BEGIN
       pa_debug.g_err_stage := p_msg;
       IF p_called_mode = 'SELF_SERVICE' THEN
            pa_debug.write
                   (x_module   => p_module_name,
                    x_msg      => pa_debug.g_err_stage,
                    x_log_level=> p_log_level);
       ELSIF p_called_mode = 'CONCURRENT' THEN
            pa_debug.write_file(x_msg => pa_debug.g_err_stage);
       END IF;

END FP_DEBUG;


FUNCTION GET_ETC_START_DATE(P_BUDGET_VERSION_ID PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE)
 RETURN DATE IS
  x_etc_start_date     PA_BUDGET_VERSIONS.ETC_START_DATE%TYPE;
 BEGIN
     SELECT etc_start_date
     INTO   x_etc_start_date
     FROM   pa_budget_versions
     WHERE  budget_version_id = p_budget_version_id
     AND    etc_start_date is not null;

     RETURN x_etc_start_date;

 EXCEPTION
    WHEN OTHERS THEN
         RETURN x_etc_start_date;
 END;

FUNCTION GET_ACTUALS_THRU_DATE(P_BUDGET_VERSION_ID PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE)
RETURN DATE IS
  x_actuals_thru_date     PA_BUDGET_VERSIONS.ETC_START_DATE%TYPE;
 BEGIN
     SELECT (etc_start_date)-1
     INTO   x_actuals_thru_date
     FROM   pa_budget_versions
     WHERE  budget_version_id = p_budget_version_id
     AND    etc_start_date is not null;

     RETURN x_actuals_thru_date;

 EXCEPTION
    WHEN OTHERS THEN
         RETURN x_actuals_thru_date;
 END;

FUNCTION GET_RL_UNCATEGORIZED_FLAG(P_RESOURCE_LIST_ID PA_BUDGET_VERSIONS.RESOURCE_LIST_ID%TYPE)
RETURN VARCHAR2 IS
  x_rl_uncategorized_flag     VARCHAR2(1);
 BEGIN

   SELECT  NVL(UNCATEGORIZED_FLAG,'N')
   INTO    x_rl_uncategorized_flag
   FROM    pa_resource_lists_all_bg
   WHERE   resource_list_id = p_resource_list_id;

   RETURN  x_rl_uncategorized_flag;

 EXCEPTION
    WHEN OTHERS THEN
         RETURN 'N';
 END;


FUNCTION GET_UC_RES_LIST_RLM_ID(P_RESOURCE_LIST_ID PA_BUDGET_VERSIONS.RESOURCE_LIST_ID%TYPE,
P_RESOURCE_CLASS_CODE pa_resource_list_members.RESOURCE_CLASS_CODE%TYPE)
RETURN NUMBER IS
  x_uc_res_list_rlm_id     NUMBER;
 BEGIN

    SELECT    resource_list_member_id
    INTO      x_uc_res_list_rlm_id
    FROM      pa_resource_list_members
    WHERE     resource_class_code = P_RESOURCE_CLASS_CODE
    AND       object_type = 'RESOURCE_LIST'
    AND       resource_list_id = p_resource_list_id;

    RETURN x_uc_res_list_rlm_id;

 EXCEPTION
    WHEN OTHERS THEN
         RETURN -1;
 END;

FUNCTION GET_RLM_ID(P_PROJECT_ID PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
		    P_RESOURCE_LIST_ID PA_BUDGET_VERSIONS.RESOURCE_LIST_ID%TYPE,
                    P_RESOURCE_CLASS_CODE pa_resource_assignments.resource_class_code%type)
RETURN NUMBER IS
    l_control_flag VARCHAR2(10);
    x_rlm_id     NUMBER;
BEGIN
    SELECT NVL(control_flag,'N')
    INTO l_control_flag
    FROM pa_resource_lists_all_bg
    WHERE resource_list_id = P_RESOURCE_LIST_ID;

    IF l_control_flag =  'Y' THEN
	select resource_list_member_id
               into x_rlm_id
	from pa_resource_list_members
	where object_type = 'RESOURCE_LIST'
	      and object_id = p_resource_list_id
	      and resource_list_id = p_resource_list_id
	      and resource_class_code = P_RESOURCE_CLASS_CODE
	      and RESOURCE_CLASS_FLAG='Y';
    ELSE
	select resource_list_member_id
               into x_rlm_id
	from pa_resource_list_members
	where object_type = 'PROJECT'
	      and object_id = p_project_id
	      and resource_list_id = p_resource_list_id
	      and resource_class_code = P_RESOURCE_CLASS_CODE
	      and RESOURCE_CLASS_FLAG='Y';
    END IF;

    RETURN x_rlm_id;

 EXCEPTION
    WHEN OTHERS THEN
         RETURN -1;
 END;

/**This API is to validate all support cases in budget/forecast generation. *
  *As of 6/27/2005, the unsupported cases are:
  *1.Forecast/Budget generation from cost-disabled Workplan is not supported.
  *  ADDED FOR ER 4391254:
  *  The only exception is that we allow Budget generation from cost-disabled
  *  Workplan if the Target is a Cost-only version, the Structure is 'Fully-
  *  Shared', and the following source/target planning options are equal:
  *   a)Resource List
  *   b)Time phase
  *   c)Planning Level
  *   d)Multi-currency flag
  *  Note that when the generation option is 'Task Level Selection', we will
  *  raise an error only when at least one of the tasks has ETC generation
  *  source as 'WORKPLAN_RESOURCES' or 'WORK_QUANTITY'.
  *2.For Forecast/Budget generation from Staffing Plan:
  *   1)Revenue versions can't be generated.
  *   2)Versions with Resource List of None can't be generated.
  * --Bug 5325254
  *3.Forecast generation from non-timephased Workplan is not supported.
  *  Note: Earlier, we restricted forecast generation from non-timephased
  *  financial plans as well. However, this restriction has been relaxed
  *  to support CDM's requirements.
  *4.Forecast/Budget generation from:
  *  ADDED FOR ER 4391321:
  *   1)Workplan and/or Financial Plan that has any rejection code in the
  *     budget lines should result in a warning or error from the UI and
  *     Concurrent Program, respectively.
  *   2)Staffing Plan that has any Forecast Items with ERROR_FLAG = 'Y'
  *     should result in a warning or error from the UI and Concurrent
  *     Program, respectively.
  *5.Forecast/Budget Generation,where Revenue Derivation Method of target
  *  is different from source, is not supported. ER: 5152892
  *PARAMETERS:
  *
  *P_CALLING_CONTEXT
  *-----------------
  *  'CONCURRENT'  : this api is being called from a Concurrent Program.
  *  'SELF_SERVICE': this api is being called from the Self-Service pages.
  *
  *Added for ER 4391321:
  *
  *P_CHECK_SRC_ERRORS_FLAG
  *-----------------------
  *  'Y': when source is FP or WP, check source budget line rejection codes.
  *       when source is Staffing Plan, check ERROR_FLAG for forecast items.
  *  'N': do not check source rejection codes or ERROR_FLAG values.
  *By default, P_CHECK_SRC_ERRORS_FLAG is 'Y'.
  *
  *X_WARNING_MESSAGE
  *----------------------
  *  NULL: P_CHECK_SRC_ERRORS_FLAG = 'N', OR
  *        P_CHECK_SRC_ERRORS_FLAG = 'Y' and source passed rejection code /
  *        ERROR_FLAG validation.
  *  Otherwise, contains the translated warning message text.
  *X_WARNING_MESSAGE will be null whenever P_CALLING_CONTEXT = 'CONCURRENT'.
  **/


PROCEDURE VALIDATE_SUPPORT_CASES
       (P_FP_COLS_REC_TGT               IN  PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
        P_CALLING_CONTEXT               IN  VARCHAR2,
        P_CHECK_SRC_ERRORS_FLAG         IN  VARCHAR2,
        X_WARNING_MESSAGE               OUT NOCOPY  VARCHAR2,
        X_RETURN_STATUS                 OUT NOCOPY  VARCHAR2,
        X_MSG_COUNT                     OUT NOCOPY  NUMBER,
        X_MSG_DATA                      OUT NOCOPY  VARCHAR2)
IS
  l_module_name  VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_AMOUNT_UTILS.VALIDATE_SUPPORT_CASES';

  l_wp_track_cost_flag           VARCHAR2(1);
  l_rev_gen_method               VARCHAR2(1);
  l_plan_class_code              PA_FIN_PLAN_TYPES_B.PLAN_CLASS_CODE%TYPE;

  l_source_wp_ver_id             PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE;
  l_stru_sharing_code            PA_PROJECTS_ALL.STRUCTURE_SHARING_CODE%TYPE;
  l_source_fp_ver_id             PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE;
  l_fp_cols_rec_source           PA_FP_GEN_AMOUNT_UTILS.FP_COLS;

  l_gen_src_code                 PA_PROJ_FP_OPTIONS.GEN_COST_SRC_CODE%TYPE;
  l_count                        NUMBER;

  l_fp_cols_rec_tgt              PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
  x_fp_cols_rec_tgt              PA_FP_GEN_AMOUNT_UTILS.FP_COLS;

  -- This flag tracks if we still need to perform defaulting
  -- logic for the source version id. This flag is only relevant
  -- if the Target is a Budget.
  l_default_bdgt_src_ver_flag    VARCHAR2(1);

  l_uncategorized_flag           PA_RESOURCE_LISTS_ALL_BG.UNCATEGORIZED_FLAG%TYPE;

  l_dummy                        NUMBER;

  l_msg_count                    NUMBER;
  l_data                         VARCHAR2(2000);
  l_msg_data                     VARCHAR2(2000);
  l_msg_index_out                NUMBER;

  -- ER 4391321: Variables for validation Case 4
  l_bl_rejection_code_count      NUMBER;
  l_raise_error_flag             VARCHAR2(1);
  l_pa_gl_token_value            VARCHAR2(30);
  l_warning_message_code         VARCHAR2(30);

  lc_message_code_WP            CONSTANT VARCHAR2(30) := 'WP';
  lc_message_code_FP            CONSTANT VARCHAR2(30) := 'FP';
  lc_message_code_SP            CONSTANT VARCHAR2(30) := 'SP';
  lc_message_code_WPFP          CONSTANT VARCHAR2(30) := 'WPFP';

BEGIN
    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function => 'VALIDATE_SUPPORT_CASES',
                                    p_debug_mode => p_pa_debug_mode);
    END IF;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT := 0;
    X_WARNING_MESSAGE := NULL;

    -- Initialize local copy of target version details
    l_fp_cols_rec_tgt := P_FP_COLS_REC_TGT;
    l_default_bdgt_src_ver_flag := 'Y';

    l_wp_track_cost_flag :=
        PA_FP_WP_GEN_AMT_UTILS.GET_WP_TRACK_COST_AMT_FLAG(l_fp_cols_rec_tgt.X_PROJECT_ID);

    --l_rev_gen_method :=
    --    PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(l_fp_cols_rec_tgt.X_PROJECT_ID);
    l_rev_gen_method := nvl(l_fp_cols_rec_tgt.x_revenue_derivation_method,PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(l_fp_cols_rec_tgt.X_PROJECT_ID)); -- Bug 5462471
    l_plan_class_code := l_fp_cols_rec_tgt.X_PLAN_CLASS_CODE;
    IF l_plan_class_code = 'BUDGET' THEN
        l_gen_src_code := l_fp_cols_rec_tgt.X_GEN_SRC_CODE;
    ELSE
        l_gen_src_code := l_fp_cols_rec_tgt.X_GEN_ETC_SRC_CODE;
    END IF;

    /* Case 1: Source is cost-disabled Workplan */
    IF l_wp_track_cost_flag = 'N' AND
       l_gen_src_code = 'WORKPLAN_RESOURCES' THEN

        --  Added for ER 4391254
        IF l_plan_class_code = 'BUDGET' THEN

	    l_stru_sharing_code :=
	        PA_PROJECT_STRUCTURE_UTILS.GET_STRUCTURE_SHARING_CODE
	            ( p_project_id => l_fp_cols_rec_tgt.X_PROJECT_ID );

            -- For the special case when the Target is a Cost-only Budget
            -- and the structure is Fully Shared, try to default the source
            -- version if it is Null and we have not done defaulting earlier.

            IF l_fp_cols_rec_tgt.x_version_type = 'COST' AND
               l_stru_sharing_code = 'SHARE_FULL' AND
               l_default_bdgt_src_ver_flag = 'Y' AND
               l_fp_cols_rec_tgt.X_GEN_SRC_WP_VERSION_ID IS NULL THEN

                IF p_pa_debug_mode = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                        (p_called_mode => p_calling_context,
                         p_msg         => 'Before calling
                                          PA_FP_GEN_AMOUNT_UTILS.DEFAULT_BDGT_SRC_VER',
                         p_module_name => l_module_name,
                         p_log_level   => 5);
                END IF;
                /* The version defaulting API passes updated Target version details
                 * record back as an OUT parameter. */
                PA_FP_GEN_AMOUNT_UTILS.DEFAULT_BDGT_SRC_VER
                    ( P_FP_COLS_REC_TGT  => l_fp_cols_rec_tgt,
                      P_CALLING_CONTEXT  => p_calling_context,
                      X_FP_COLS_REC_TGT  => x_fp_cols_rec_tgt,
                      X_RETURN_STATUS    => X_RETURN_STATUS,
                      X_MSG_COUNT        => X_MSG_COUNT,
                      X_MSG_DATA         => X_MSG_DATA );
                IF p_pa_debug_mode = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                        (p_called_mode => p_calling_context,
                         p_msg         => 'Status after calling
                                          PA_FP_GEN_AMOUNT_UTILS.DEFAULT_BDGT_SRC_VER: '
                                          ||x_return_status,
                         p_module_name => l_module_name,
                         p_log_level   => 5);
                END IF;
                IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;
                l_fp_cols_rec_tgt := x_fp_cols_rec_tgt;
                l_default_bdgt_src_ver_flag := 'N';
            END IF; -- defaulting logic

            l_source_wp_ver_id := l_fp_cols_rec_tgt.X_GEN_SRC_WP_VERSION_ID;

            -- Defaulting logic should raise an error if source version is Null.
            -- However, we sill still check that it is not Null to be cautious.

            IF l_fp_cols_rec_tgt.x_version_type = 'COST' AND
               l_source_wp_ver_id IS NOT NULL AND
               l_stru_sharing_code = 'SHARE_FULL' THEN
                /* Get version details for Source Workplan */
                IF p_pa_debug_mode = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                        (p_called_mode => p_calling_context,
                         p_msg         => 'Before calling
                                          PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS',
                         p_module_name => l_module_name,
                         p_log_level   => 5);
                END IF;
                PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
                    ( P_PROJECT_ID           => l_fp_cols_rec_tgt.X_PROJECT_ID,
                      P_BUDGET_VERSION_ID    => l_source_wp_ver_id,
                      X_FP_COLS_REC          => l_fp_cols_rec_source,
                      X_RETURN_STATUS        => X_RETURN_STATUS,
                      X_MSG_COUNT            => X_MSG_COUNT,
                      X_MSG_DATA             => X_MSG_DATA );
                IF p_pa_debug_mode = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                        (p_called_mode => p_calling_context,
                         p_msg         => 'Status after calling
                                          PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS: '
                                          ||x_return_status,
                         p_module_name => l_module_name,
                         p_log_level   => 5);
                END IF;
                IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

                /* If source/target planning options are equal, then this
                 * is a supported generation, so do nothing, and proceed
                 * with checking remaining validation cases. Otherwise, the
                 * generation is not supported, so Raise and error. */

                IF (l_fp_cols_rec_tgt.X_RESOURCE_LIST_ID =
                    l_fp_cols_rec_source.X_RESOURCE_LIST_ID
                    AND l_fp_cols_rec_tgt.X_TIME_PHASED_CODE =
                        l_fp_cols_rec_source.X_TIME_PHASED_CODE
                    AND l_fp_cols_rec_tgt.X_FIN_PLAN_LEVEL_CODE =
                        l_fp_cols_rec_source.X_FIN_PLAN_LEVEL_CODE
                    AND l_fp_cols_rec_tgt.X_PLAN_IN_MULTI_CURR_FLAG =
                        l_fp_cols_rec_source.X_PLAN_IN_MULTI_CURR_FLAG) THEN
                    l_dummy := 1;
                ELSE
                    PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                          p_msg_name       => 'PA_BDGT_WP_CST_DIS_ERR');
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;
            ELSE
                /* This budget does not satisfy the special exception conditions.
                 * Thus, this generation scenario is not supported. Raise an error. */

                PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_BDGT_WP_CST_DIS_ERR');
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF; -- l_source_wp_ver_id NULL check
        --  End changes for ER 4391254
        ELSE
            -- l_plan_class_code = 'FORECAST':
            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_FCST_WP_CST_DIS_ERR');
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF; -- budget/forecast logic
    END IF;
    IF l_wp_track_cost_flag = 'N' AND
       l_gen_src_code = 'TASK_LEVEL_SEL' THEN
        SELECT COUNT(*) INTO l_count
        FROM   pa_tasks
        WHERE  project_id = l_fp_cols_rec_tgt.X_PROJECT_ID
        AND   (gen_etc_source_code = 'WORKPLAN_RESOURCES'
               OR gen_etc_source_code = 'WORK_QUANTITY')
        AND    rownum < 2;

        IF l_count > 0 THEN
            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_FCST_WP_CST_DIS_ERR');
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    END IF; -- Validation Case 1


    /* Case 2.1: Source is Staffing Plan and Target is a Revenue-only version */
    IF l_gen_src_code = 'RESOURCE_SCHEDULE' AND
       l_fp_cols_rec_tgt.X_VERSION_TYPE = 'REVENUE' THEN
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                              p_msg_name       => 'PA_RES_SCH_REV_ERR');
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF; -- Validation Case 2.1

    /* Case 2.2: Source is Staffing Plan and Target Resource List is None */
    IF l_gen_src_code = 'RESOURCE_SCHEDULE' THEN
        BEGIN
            SELECT nvl(UNCATEGORIZED_FLAG,'N')
            INTO   l_uncategorized_flag
            FROM   pa_resource_lists
            WHERE  resource_list_id = l_fp_cols_rec_tgt.X_RESOURCE_LIST_ID;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_uncategorized_flag := 'N';
        END;
        /* Uncategorized flag of 'Y' implies resource list is None */
        IF l_uncategorized_flag = 'Y' THEN
            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_RES_SCH_UNCAT_RES_LIST_ERR');
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    END IF; -- Validation Case 2.2

    /* Case 3: Source is WP with time phase = None, Target is a forecast */
    IF l_plan_class_code = 'FORECAST' AND
       (l_gen_src_code = 'WORKPLAN_RESOURCES' OR
        --l_gen_src_code = 'FINANCIAL_PLAN' OR --Bug 5325254
        l_gen_src_code = 'TASK_LEVEL_SEL') THEN

        -- If source version id is null, we cannot check source time phase
        l_source_wp_ver_id := l_fp_cols_rec_tgt.X_GEN_SRC_WP_VERSION_ID;
        --l_source_fp_ver_id := l_fp_cols_rec_tgt.X_GEN_SRC_PLAN_VERSION_ID; --Bug 5325254

        /* Do Workplan Source Validation */
        IF l_source_wp_ver_id IS NOT NULL AND
           l_gen_src_code IN ('WORKPLAN_RESOURCES','TASK_LEVEL_SEL') THEN

            IF l_gen_src_code = 'TASK_LEVEL_SEL' THEN
                SELECT COUNT(*) INTO l_count
                FROM   pa_tasks
                WHERE  project_id = l_fp_cols_rec_tgt.X_PROJECT_ID
                AND   (gen_etc_source_code = 'WORKPLAN_RESOURCES'
                       OR gen_etc_source_code = 'WORK_QUANTITY')
                AND    rownum < 2;
            END IF;

            IF l_gen_src_code = 'WORKPLAN_RESOURCES' OR
              (l_gen_src_code = 'TASK_LEVEL_SEL' AND l_count > 0) THEN

                /* Get version details for Source Workplan */
                IF p_pa_debug_mode = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                        (p_called_mode => p_calling_context,
                         p_msg         => 'Before calling
                                          PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS',
                         p_module_name => l_module_name,
                         p_log_level   => 5);
                END IF;
                PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
                                    (P_PROJECT_ID           => l_fp_cols_rec_tgt.X_PROJECT_ID,
                                     P_BUDGET_VERSION_ID    => l_source_wp_ver_id,
                                     X_FP_COLS_REC          => l_fp_cols_rec_source,
                                     X_RETURN_STATUS        => X_RETURN_STATUS,
                                     X_MSG_COUNT            => X_MSG_COUNT,
                                     X_MSG_DATA             => X_MSG_DATA);
                IF p_pa_debug_mode = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                        (p_called_mode => p_calling_context,
                         p_msg         => 'Status after calling
                                          PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS: '
                                          ||x_return_status,
                         p_module_name => l_module_name,
                         p_log_level   => 5);
                END IF;
                IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

                IF l_fp_cols_rec_source.x_time_phased_code = 'N' THEN
	            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
	                                  p_msg_name       => 'PA_WP_FP_NON_TIME_PHASED_ERR');
	            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;
            END IF;
        END IF; -- Workplan Source Validation

        /*Bug 5325254 : NO LONGER Do Financial Plan Source Validation */
        /******************** BEGIN COMMENTING ********************
        IF l_source_fp_ver_id IS NOT NULL AND
           l_gen_src_code IN ('FINANCIAL_PLAN','TASK_LEVEL_SEL') THEN

            IF l_gen_src_code = 'TASK_LEVEL_SEL' THEN
                SELECT COUNT(*) INTO l_count
                FROM   pa_tasks
                WHERE  project_id = l_fp_cols_rec_tgt.X_PROJECT_ID
                AND    gen_etc_source_code = 'FINANCIAL_PLAN'
                AND    rownum < 2;
            END IF;

            IF l_gen_src_code = 'FINANCIAL_PLAN' OR
              (l_gen_src_code = 'TASK_LEVEL_SEL' AND l_count > 0) THEN

                -- Get version details for Source Financial Plan
                IF p_pa_debug_mode = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                        (p_called_mode => p_calling_context,
                         p_msg         => 'Before calling
                                          PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS',
                         p_module_name => l_module_name,
                         p_log_level   => 5);
                END IF;
                PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
                                    (P_PROJECT_ID           => l_fp_cols_rec_tgt.X_PROJECT_ID,
                                     P_BUDGET_VERSION_ID    => l_source_fp_ver_id,
                                     X_FP_COLS_REC          => l_fp_cols_rec_source,
                                     X_RETURN_STATUS        => X_RETURN_STATUS,
                                     X_MSG_COUNT            => X_MSG_COUNT,
                                     X_MSG_DATA             => X_MSG_DATA);
                IF p_pa_debug_mode = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                        (p_called_mode => p_calling_context,
                         p_msg         => 'Status after calling
                                          PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS: '
                                          ||x_return_status,
                         p_module_name => l_module_name,
                         p_log_level   => 5);
                END IF;
                IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

                IF l_fp_cols_rec_source.x_time_phased_code = 'N' THEN
	            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
	                                  p_msg_name       => 'PA_WP_FP_NON_TIME_PHASED_ERR');
	            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;
            END IF;
        END IF; -- Financial Plan Source Validation
        ********************* END COMMENTING ********************/

    END IF; -- Validation Case 3

    /* Default budget source version if needed.
     * Note that we did this earlier inside Case 1, where it was necessary
     * to selectively call the defaulting API based on the case introduced
     * for ER 4391254.
     * At this point, we are doing defaulting for the remainder of the API.
     * FUTURE VALIDATION CASES THAT NEED SPECIAL ORDERING WITH RESPECT TO
     * THE DEFAULTING LOGIC SHOULD BE PLACED ABOVE THIS POINT. */

    IF l_plan_class_code = 'BUDGET' THEN

        -- Try to default the source version if both the WP and FP source
        -- versions are Null and we have not done defaulting earlier.
        IF l_default_bdgt_src_ver_flag = 'Y' AND
           l_fp_cols_rec_tgt.X_GEN_SRC_WP_VERSION_ID IS NULL AND
           l_fp_cols_rec_tgt.X_GEN_SRC_PLAN_VERSION_ID IS NULL THEN

            IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                    (p_called_mode => p_calling_context,
                     p_msg         => 'Before calling
                                      PA_FP_GEN_AMOUNT_UTILS.DEFAULT_BDGT_SRC_VER',
                     p_module_name => l_module_name,
                     p_log_level   => 5);
            END IF;
            /* The version defaulting API passes updated Target version details
             * record back as an OUT parameter. */
            PA_FP_GEN_AMOUNT_UTILS.DEFAULT_BDGT_SRC_VER
                ( P_FP_COLS_REC_TGT  => l_fp_cols_rec_tgt,
                  P_CALLING_CONTEXT  => p_calling_context,
                  X_FP_COLS_REC_TGT  => x_fp_cols_rec_tgt,
                  X_RETURN_STATUS    => X_RETURN_STATUS,
                  X_MSG_COUNT        => X_MSG_COUNT,
                  X_MSG_DATA         => X_MSG_DATA );
            IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                    (p_called_mode => p_calling_context,
                     p_msg         => 'Status after calling
                                      PA_FP_GEN_AMOUNT_UTILS.DEFAULT_BDGT_SRC_VER: '
                                      ||x_return_status,
                     p_module_name => l_module_name,
                     p_log_level   => 5);
            END IF;
            IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            l_fp_cols_rec_tgt := x_fp_cols_rec_tgt;

        END IF; -- defaulting logic
    END IF; -- l_plan_class_code check

    -- Whether we had to default the budget source version or not,
    -- we no longer need to worry about defaulting it after this point.
    l_default_bdgt_src_ver_flag := 'N';

    -- ADDED FOR ER 4391321:
    /* Case 4: Check if Forecast/Budget generation from source that has errors */
    IF P_CHECK_SRC_ERRORS_FLAG = 'Y' THEN

        -- Initialize the warning message code local variable to Null.
        -- We will use this to track the error state regardless of calling
        -- context. Further processing will be based on this variable.
        l_warning_message_code := NULL;

        /* Case 4.1: Check WP/FP source budget lines do not have rejection codes. */
        IF l_gen_src_code = 'WORKPLAN_RESOURCES' OR
           l_gen_src_code = 'FINANCIAL_PLAN' OR
           l_gen_src_code = 'TASK_LEVEL_SEL' THEN

            -- If source version id is null, we cannot check budget line rejection codes
            l_source_wp_ver_id := l_fp_cols_rec_tgt.X_GEN_SRC_WP_VERSION_ID;
            l_source_fp_ver_id := l_fp_cols_rec_tgt.X_GEN_SRC_PLAN_VERSION_ID;

            /* Do Workplan Source Validation */
            IF l_source_wp_ver_id IS NOT NULL AND
               l_gen_src_code IN ('WORKPLAN_RESOURCES','TASK_LEVEL_SEL') THEN

                -- When l_gen_src_code is 'WORKPLAN_RESOURCES', all target resources
                -- are generated from the source Workplan. When l_gen_src_code is
                -- 'TASK_LEVEL_SEL', target resources are generated from the source
                -- specified by the gen_etc_source_code of the target task. Thus, in
                -- the latter case, we need to check if any tasks are generated by
                -- the source Workplan.

                IF l_gen_src_code = 'TASK_LEVEL_SEL' THEN
                    BEGIN
                        SELECT 1 INTO l_count
                        FROM DUAL
                        WHERE EXISTS
                            ( SELECT null
                              FROM   pa_tasks
                              WHERE  project_id = l_fp_cols_rec_tgt.X_PROJECT_ID
                              AND    gen_etc_source_code IN ('WORKPLAN_RESOURCES','WORK_QUANTITY') );
                    EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_count := 0;
		    END; -- select l_count
                END IF;

                IF l_gen_src_code = 'WORKPLAN_RESOURCES' OR
                  (l_gen_src_code = 'TASK_LEVEL_SEL' AND l_count > 0) THEN

                    /* Check if any wp source budget line has a non-null rejection code */
                    BEGIN
                        SELECT 1 INTO l_bl_rejection_code_count
                        FROM DUAL
                        WHERE EXISTS
                            ( SELECT null
                              FROM   pa_budget_lines
                              WHERE  budget_version_id = l_source_wp_ver_id
                              AND  ( cost_rejection_code IS NOT NULL
                                     OR revenue_rejection_code IS NOT NULL
                                     OR burden_rejection_code IS NOT NULL
                                     OR other_rejection_code IS NOT NULL
                                     OR pc_cur_conv_rejection_code IS NOT NULL
                                     OR pfc_cur_conv_rejection_code IS NOT NULL ) );
                    EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_bl_rejection_code_count := 0;
		    END; -- select l_bl_rejection_code_count

                    IF l_bl_rejection_code_count > 0 THEN
                        l_warning_message_code := lc_message_code_WP;
                    END IF; -- rejection code count check
                END IF;
            END IF; -- Workplan Source Validation

            /* Do Financial Plan Source Validation */
            IF l_source_fp_ver_id IS NOT NULL AND
               l_gen_src_code IN ('FINANCIAL_PLAN','TASK_LEVEL_SEL') THEN

                -- When l_gen_src_code is 'FINANCIAL_PLAN', all target resources are
                -- generated from the source Financial Plan. When l_gen_src_code is
                -- 'TASK_LEVEL_SEL', target resources are generated from the source
                -- specified by the gen_etc_source_code of the target task. Thus, in
                -- the latter case, we need to check if any tasks are generated by
                -- the source Financial Plan.

                IF l_gen_src_code = 'TASK_LEVEL_SEL' THEN
                    BEGIN
                        SELECT 1 INTO l_count
                        FROM DUAL
                        WHERE EXISTS
                            ( SELECT null
                              FROM   pa_tasks
                              WHERE  project_id = l_fp_cols_rec_tgt.X_PROJECT_ID
                              AND    gen_etc_source_code = 'FINANCIAL_PLAN' );
                    EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_count := 0;
		    END; -- select l_count
                END IF;

                IF l_gen_src_code = 'FINANCIAL_PLAN' OR
                  (l_gen_src_code = 'TASK_LEVEL_SEL' AND l_count > 0) THEN

                    /* Check if any fp source budget line has a non-null rejection code */
                    BEGIN
                        SELECT 1 INTO l_bl_rejection_code_count
                        FROM DUAL
                        WHERE EXISTS
                            ( SELECT null
                              FROM   pa_budget_lines
                              WHERE  budget_version_id = l_source_fp_ver_id
                              AND  ( cost_rejection_code IS NOT NULL
                                     OR revenue_rejection_code IS NOT NULL
                                     OR burden_rejection_code IS NOT NULL
                                     OR other_rejection_code IS NOT NULL
                                     OR pc_cur_conv_rejection_code IS NOT NULL
                                     OR pfc_cur_conv_rejection_code IS NOT NULL ) );
                    EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_bl_rejection_code_count := 0;
		    END; -- select l_bl_rejection_code_count

                    IF l_bl_rejection_code_count > 0 THEN
                        /* If Target is a Forecast version with source as
                         * Task-Level Selection, both WP and FP sources may
                         * have budget lines with rejection codes. Check this. */
                        IF l_warning_message_code = lc_message_code_WP THEN
                            l_warning_message_code := lc_message_code_WPFP;
                        ELSE
                            l_warning_message_code := lc_message_code_FP;
                        END IF;
                    END IF; -- rejection code count check
                END IF;
            END IF; -- Financial Plan Source Validation

            IF l_warning_message_code IS NOT NULL THEN
                -- At this point, l_warning_message_code can be either:
                -- lc_message_code_WP, lc_message_code_FP, or lc_message_code_WPFP.
                -- Push the appropriate error message onto the stack depending
                -- on the Calling Context. Raise an exception if the context is
                -- 'CONCURRENT' (program).

		IF l_warning_message_code = lc_message_code_WP THEN
		    IF p_calling_context = 'SELF_SERVICE' THEN
		        PA_UTILS.ADD_MESSAGE
		            ( p_app_short_name => 'PA',
		              p_msg_name       => 'PA_SRC_WP_REJ_CODE_WARN' );
		    ELSIF p_calling_context = 'CONCURRENT' THEN
		        PA_UTILS.ADD_MESSAGE
		            ( p_app_short_name => 'PA',
		              p_msg_name       => 'PA_SRC_WP_REJ_CODE_ERR' );
		        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
		    END IF;
		ELSIF l_warning_message_code = lc_message_code_FP THEN
		    IF p_calling_context = 'SELF_SERVICE' THEN
		        PA_UTILS.ADD_MESSAGE
		            ( p_app_short_name => 'PA',
		              p_msg_name       => 'PA_SRC_FP_REJ_CODE_WARN' );
		    ELSIF p_calling_context = 'CONCURRENT' THEN
		        PA_UTILS.ADD_MESSAGE
		            ( p_app_short_name => 'PA',
		              p_msg_name       => 'PA_SRC_FP_REJ_CODE_ERR' );
		        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
		    END IF;
		ELSIF l_warning_message_code = lc_message_code_WPFP THEN
		    IF p_calling_context = 'SELF_SERVICE' THEN
		        PA_UTILS.ADD_MESSAGE
		            ( p_app_short_name => 'PA',
		              p_msg_name       => 'PA_SRC_WPFP_REJ_CODE_WARN' );
		    ELSIF p_calling_context = 'CONCURRENT' THEN
		        PA_UTILS.ADD_MESSAGE
		            ( p_app_short_name => 'PA',
		              p_msg_name       => 'PA_SRC_WPFP_REJ_CODE_ERR' );
		        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
		    END IF;
		END IF; -- l_warning_message_code check
            END IF; -- l_warning_message_code is not null

        END IF; -- Validation Case 4.1


        /* Case 4.2: Check Staffing Plan source forecast items do not have ERROR_FLAG = 'Y'. */

        IF l_gen_src_code = 'RESOURCE_SCHEDULE' THEN

            BEGIN
                SELECT 1 INTO l_count
                FROM DUAL
                WHERE EXISTS
                    ( SELECT null
                      FROM   PA_FORECAST_ITEMS
                      WHERE  project_id = l_fp_cols_rec_tgt.X_PROJECT_ID
                      AND    error_flag = 'Y' );
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_count := 0;
	    END; -- select l_count

	    IF l_count > 0 THEN

                l_warning_message_code := lc_message_code_SP;

                /* The error flag can only be 'Y' if the Target timephasing
                 * is PA or GL. Set the message token value appropriately. */
		l_pa_gl_token_value := null;
		IF l_fp_cols_rec_tgt.x_time_phased_code = 'P' THEN
		    l_pa_gl_token_value := 'PA';
		ELSIF l_fp_cols_rec_tgt.x_time_phased_code = 'G' THEN
		    l_pa_gl_token_value := 'GL';
		END IF;

                IF p_calling_context = 'SELF_SERVICE' THEN
                    PA_UTILS.ADD_MESSAGE
                        ( p_app_short_name => 'PA',
                          p_msg_name       => 'PA_SRC_SP_ERROR_FLAG_WARN',
                          p_token1         => 'PA_GL',
                          p_value1         => l_pa_gl_token_value );
                ELSIF p_calling_context = 'CONCURRENT' THEN
                    PA_UTILS.ADD_MESSAGE
                        ( p_app_short_name => 'PA',
                          p_msg_name       => 'PA_SRC_SP_ERROR_FLAG_ERR',
                          p_token1         => 'PA_GL',
                          p_value1         => l_pa_gl_token_value );
	            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;
	    END IF;

        END IF; -- Validation Case 4.2

--Case 5: Forecast/Budget Generation,where Revenue Derivation Method of target
   --is different from source, is not supported. ER: 5152892

   IF (l_fp_cols_rec_tgt.X_GEN_SRC_PLAN_VERSION_ID IS NOT NULL
           AND l_gen_src_code = 'FINANCIAL_PLAN'
           AND l_fp_cols_rec_tgt.X_VERSION_TYPE IN ('REVENUE','ALL')) THEN

                   -- Get version details for Source Financial Plan
                   IF p_pa_debug_mode = 'Y' THEN
                       pa_fp_gen_amount_utils.fp_debug
                           (p_called_mode => p_calling_context,
                            p_msg         => 'Before calling
                                             PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS',
                            p_module_name => l_module_name,
                            p_log_level   => 5);
                   END IF;
                   PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
                                       (P_PROJECT_ID           => l_fp_cols_rec_tgt.X_PROJECT_ID,
                                        P_BUDGET_VERSION_ID    => l_fp_cols_rec_tgt.X_GEN_SRC_PLAN_VERSION_ID,
                                        X_FP_COLS_REC          => l_fp_cols_rec_source,
                                        X_RETURN_STATUS        => X_RETURN_STATUS,
                                        X_MSG_COUNT            => X_MSG_COUNT,
                                        X_MSG_DATA             => X_MSG_DATA);
                   IF p_pa_debug_mode = 'Y' THEN
                       pa_fp_gen_amount_utils.fp_debug
                           (p_called_mode => p_calling_context,
                            p_msg         => 'Status after calling
                                             PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS: '
                                             ||x_return_status,
                            p_module_name => l_module_name,
                            p_log_level   => 5);
                   END IF;
                   IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                   END IF;
                   IF (l_fp_cols_rec_source.X_VERSION_TYPE = 'ALL'
                      AND nvl(l_fp_cols_rec_source.x_revenue_derivation_method,'W')
                        <>nvl(l_fp_cols_rec_tgt.x_revenue_derivation_method,'W')) THEN
                       PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                             p_msg_name       => 'PA_REV_DER_MTD_DIFF');
                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                   END IF;
   END IF; -- Case 5 validation

        /* If the validation fails, the transaction should be rolled back.
         * When the context is Concurrent Program, an Exception is raised,
         * so the exception handler will perform the rollback. When the
         * context is Self-Service, we report the error by using the OUT
         * parameter X_WARNING_MESSAGE without raising an Exception.
         * We handle the latter case below by performing the rollback and
         * fetching the translated message text. */

        IF l_warning_message_code IS NOT NULL AND
           p_calling_context = 'SELF_SERVICE' THEN

            l_msg_count := FND_MSG_PUB.count_msg;

            -- Error handling logic.
            -- 2 possibilities:
            -- 1) This API was called with non-empty message stack.
            -- 2) This API pushed multiple messages onto the stack.
            -- In both cases, we should only have 1 message on the stack.
            IF l_msg_count <> 1 THEN
                IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                        ( p_called_mode => p_calling_context,
                          p_msg         => 'Source data contains errors, but the number of ' ||
                                           'messages on the error stack is not equal to 1.',
                          p_module_name => l_module_name,
                          p_log_level   => 5 );
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            PA_INTERFACE_UTILS_PUB.get_messages
                ( p_encoded        => FND_API.G_FALSE, --TRUE,
                  p_msg_index      => 1,
                  --p_msg_count      => 1,
                  --p_msg_data       => l_msg_data ,
                  p_data           => X_WARNING_MESSAGE,
                  p_msg_index_out  => l_msg_index_out);

	    IF P_PA_DEBUG_MODE = 'Y' THEN
	        PA_DEBUG.RESET_CURR_FUNCTION;
	    END IF;

            ROLLBACK;
	    RETURN;
        END IF;

    END IF; -- P_CHECK_SRC_ERRORS_FLAG check

    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.RESET_CURR_FUNCTION;
    END IF;
EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count = 1 THEN
            PA_INTERFACE_UTILS_PUB.get_messages
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

        x_return_status := FND_API.G_RET_STS_ERROR;

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_called_mode => p_calling_context,
                  p_msg         => 'Invalid Arguments Passed',
                  p_module_name => l_module_name,
                  p_log_level   => 5 );
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;

        ROLLBACK;
        RAISE;
     WHEN OTHERS THEN
        rollback;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_GEN_AMOUNT_UTILS',
                     p_procedure_name  => 'VALIDATE_SUPPORT_CASES',
                     p_error_text      => substr(sqlerrm,1,240));

        IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_called_mode => p_calling_context,
                p_msg         => 'Unexpected Error'||substr(sqlerrm,1,240),
                p_module_name => l_module_name,
                p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END VALIDATE_SUPPORT_CASES;


/**
 * This API performs defaulting logic for a Budget's source workplan
 * or financial plan version. It is adapted from the defaulting logic
 * in of the GENERATE_WP_BUDGET_AMT API in PAFPWPGB.pls version 115.73.
 *
 * Currently, nothing happens if the target version is a Forecast.
 *
 * PARAMETERS:
 *
 * P_CALLING_CONTEXT
 * -----------------
 *  'CONCURRENT'  : this api is being called from a Concurrent Program.
 *  'SELF_SERVICE': this api is being called from the Self-Service pages.
 *
 * X_FP_COLS_REC_TGT
 * -----------------
 *   This is the target version's details after the defaulting logic.
 *   If no defaulting occurs, this will be the same as P_FP_COLS_REC_TGT.
 */
PROCEDURE DEFAULT_BDGT_SRC_VER
       (P_FP_COLS_REC_TGT               IN  PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
        P_CALLING_CONTEXT               IN  VARCHAR2,
        X_FP_COLS_REC_TGT               OUT NOCOPY  PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
        X_RETURN_STATUS                 OUT NOCOPY  VARCHAR2,
        X_MSG_COUNT                     OUT NOCOPY  NUMBER,
        X_MSG_DATA                      OUT NOCOPY  VARCHAR2)
IS
  l_module_name  VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_AMOUNT_UTILS.DEFAULT_BDGT_SRC_VER';

  l_plan_class_code              PA_FIN_PLAN_TYPES_B.PLAN_CLASS_CODE%TYPE;
  l_gen_src_code                 PA_PROJ_FP_OPTIONS.GEN_COST_SRC_CODE%TYPE;

  -- Variables for Budget Generation source version defaulting logic
  l_wp_status                    PA_PROJ_FP_OPTIONS.GEN_SRC_COST_WP_VER_CODE%TYPE;
  l_wp_id                        PA_BUDGET_VERSIONS.PROJECT_STRUCTURE_VERSION_ID%TYPE := NULL;
  l_source_id                    PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE;
  l_versioning_enabled           PA_PROJ_WORKPLAN_ATTR.WP_ENABLE_VERSION_flag%TYPE;

  -- ER 3491321: While doing unit testing, discovered a type-mismatch error
  -- which was not reached during unit testing for ER 4391254, where this bug
  -- was introduced. Previous type was GEN_SRC_COST_PLAN_VERSION_ID%TYPE.

  l_gen_src_plan_ver_code        PA_PROJ_FP_OPTIONS.GEN_SRC_COST_PLAN_VER_CODE%TYPE;

  l_fp_options_id                PA_PROJ_FP_OPTIONS.PROJ_FP_OPTIONS_ID%TYPE;
  l_version_type                 PA_BUDGET_VERSIONS.VERSION_TYPE%TYPE;

  l_update_details_flag          VARCHAR2(1);
  l_dummy                        NUMBER;

  l_msg_count                    NUMBER;
  l_data                         VARCHAR2(2000);
  l_msg_data                     VARCHAR2(2000);
  l_msg_index_out                NUMBER;
BEGIN
    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function
            ( p_function => 'DEFAULT_BDGT_SRC_VER',
              p_debug_mode => p_pa_debug_mode );
    END IF;

    -- Initialize OUT parameters with default values
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT := 0;
    X_FP_COLS_REC_TGT := P_FP_COLS_REC_TGT;

    l_plan_class_code := P_FP_COLS_REC_TGT.X_PLAN_CLASS_CODE;
    IF l_plan_class_code = 'BUDGET' THEN
        l_gen_src_code := P_FP_COLS_REC_TGT.X_GEN_SRC_CODE;
    ELSE
        l_gen_src_code := P_FP_COLS_REC_TGT.X_GEN_ETC_SRC_CODE;
    END IF;


    /* This logic is adapted from GENERATE_WP_BUDGET_AMT in PAFPWPGB.pls. */
    IF l_plan_class_code = 'BUDGET' THEN

        l_update_details_flag := 'Y';

        IF (l_gen_src_code = 'WORKPLAN_RESOURCES') THEN
            /*Get latest published/current working/baselined work plan version id*/
            IF P_FP_COLS_REC_TGT.x_gen_src_wp_version_id is not NULL THEN
                --l_update_details_flag := 'N';
                l_source_id := P_FP_COLS_REC_TGT.x_gen_src_wp_version_id;
                /* the x_gen_src_wp_version_id is the budget version id
                   corresponding to the work plan structure version id selected
                   as the source for the budget generation when the budget
                   generation source is Work plan. */
                SELECT project_structure_version_id
                INTO   l_wp_id
                FROM   pa_budget_versions
                WHERE  budget_version_id = l_source_id;
            ELSE
                l_versioning_enabled :=
                    PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED
                        ( P_FP_COLS_REC_TGT.X_PROJECT_ID );
                IF l_versioning_enabled = 'Y' THEN
                    l_wp_status := P_FP_COLS_REC_TGT.x_gen_src_wp_ver_code;
                    --dbms_output.put_line('ver code val :'||l_wp_status );
                    IF (l_wp_status = 'LAST_PUBLISHED') THEN
                        l_wp_id := PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION
                                       ( P_PROJECT_ID => P_FP_COLS_REC_TGT.X_PROJECT_ID );
                        IF l_wp_id is null THEN
                            PA_UTILS.ADD_MESSAGE
                                ( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_LATEST_WPID_NULL');
                            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                        END IF;
                    ELSIF (l_wp_status = 'CURRENT_WORKING') THEN
                        --dbms_output.put_line('inside cw  chk  :');
                        l_wp_id := PA_PROJECT_STRUCTURE_UTILS.GET_CURRENT_WORKING_VER_ID
                                       ( P_PROJECT_ID => P_FP_COLS_REC_TGT.X_PROJECT_ID);
                        IF l_wp_id is null THEN
                            --dbms_output.put_line('cw id is null  calling latest pub  :');
                            l_wp_id := PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION
                                           ( P_PROJECT_ID => P_FP_COLS_REC_TGT.X_PROJECT_ID );
                        END IF;
                        --dbms_output.put_line('wp id value : '||l_wp_id);
                        IF l_wp_id is null THEN
                            PA_UTILS.ADD_MESSAGE
                                ( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_CW_WPID_NULL');
                            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                        END IF;
                    -- Changed 'BASELINE', which was INCORRECT, to 'BASELINED' (dkuo)
                    ELSIF (l_wp_status = 'BASELINED') THEN
                        l_wp_id := PA_PROJECT_STRUCTURE_UTILS.GET_BASELINE_STRUCT_VER
                                       ( P_PROJECT_ID => P_FP_COLS_REC_TGT.X_PROJECT_ID );
                        IF l_wp_id is null THEN
                            PA_UTILS.ADD_MESSAGE
                                ( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_BASELINED_WPID_NULL');
                            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                        END IF;
                    END IF;
                ELSE
                    l_wp_id := PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION
                                   ( P_PROJECT_ID => P_FP_COLS_REC_TGT.X_PROJECT_ID );
                    IF l_wp_id is null THEN
                        PA_UTILS.ADD_MESSAGE
                            ( p_app_short_name => 'PA',
                              p_msg_name       => 'PA_LATEST_WPID_NULL');
                        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;
                END IF;
                /*Get the budget version id for the requried work plan version id
                 *SOURCE: work plan budget version id: l_source_id
                 *TARGET: financial budget version id: P_FP_COLS_REC_TGT.X_BUDGET_VERSION_ID*/

                l_source_id := Pa_Fp_wp_gen_amt_utils.get_wp_version_id
                                   ( p_project_id      => P_FP_COLS_REC_TGT.X_PROJECT_ID,
                                     p_plan_type_id    => null,
                                     p_proj_str_ver_id => l_wp_id );
            END IF;

             --dbms_output.put_line('l_source_id:    '||l_source_id );
             --l_txn_currency_flag := '1';

             l_version_type := P_FP_COLS_REC_TGT.x_version_type;
            /*As of now, we have the l_wp_id as wp struct version id
             * l_source_id as wp fin version id
             * Now, we need to update back to pa_proj_fp_options*/
            IF l_version_type = 'COST' THEN
                UPDATE PA_PROJ_FP_OPTIONS
                SET    GEN_SRC_COST_WP_VERSION_ID = l_source_id
                WHERE  fin_plan_version_id = P_FP_COLS_REC_TGT.X_BUDGET_VERSION_ID;
            ELSIF l_version_type = 'ALL' THEN
                UPDATE PA_PROJ_FP_OPTIONS
                SET    GEN_SRC_ALL_WP_VERSION_ID = l_source_id
                WHERE  fin_plan_version_id = P_FP_COLS_REC_TGT.X_BUDGET_VERSION_ID;
            ELSIF l_version_type = 'REVENUE' THEN
                UPDATE PA_PROJ_FP_OPTIONS
                SET    GEN_SRC_REV_WP_VERSION_ID = l_source_id
                WHERE  fin_plan_version_id = P_FP_COLS_REC_TGT.X_BUDGET_VERSION_ID;
            END IF;

            /*project structure version id is populated when create new version.
            IF ( l_stru_sharing_code = 'SHARE_FULL' OR
                 l_stru_sharing_code = 'SHARE_PARTIAL' ) AND
               P_FP_COLS_REC_TGT.X_FIN_PLAN_LEVEL_CODE <> 'P' THEN
                UPDATE PA_BUDGET_VERSIONS
                SET    project_structure_version_id = l_wp_id
                WHERE  budget_version_id = P_FP_COLS_REC_TGT.X_BUDGET_VERSION_ID;
            END IF;*/
        ELSIF (l_gen_src_code = 'FINANCIAL_PLAN') THEN
            IF P_FP_COLS_REC_TGT.x_gen_src_plan_version_id IS NOT NULL THEN
                --l_update_details_flag := 'N';
                l_source_id := P_FP_COLS_REC_TGT.x_gen_src_plan_version_id;
            ELSE
                l_gen_src_plan_ver_code :=  P_FP_COLS_REC_TGT.X_GEN_SRC_PLAN_VER_CODE;
                IF l_gen_src_plan_ver_code = 'CURRENT_BASELINED'
                   OR l_gen_src_plan_ver_code = 'ORIGINAL_BASELINED'
                   OR l_gen_src_plan_ver_code = 'CURRENT_APPROVED'
                   OR l_gen_src_plan_ver_code = 'ORIGINAL_APPROVED' THEN
                   /*Get the current baselined or original baselined version*/
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_fp_gen_amount_utils.fp_debug
                           ( p_called_mode => p_calling_context,
                             p_msg         => 'Before calling
                                              pa_fp_gen_amount_utils.Get_Curr_Original_Version_Info',
                             p_module_name => l_module_name,
                             p_log_level   => 5 );
                    END IF;
                    pa_fp_gen_amount_utils.Get_Curr_Original_Version_Info(
                        p_project_id                => P_FP_COLS_REC_TGT.X_PROJECT_ID,
                        p_fin_plan_type_id          => P_FP_COLS_REC_TGT.X_GEN_SRC_PLAN_TYPE_ID,
                        p_version_type              => 'COST',
                        p_status_code               => l_gen_src_plan_ver_code,
                        x_fp_options_id             => l_fp_options_id,
                        x_fin_plan_version_id       => l_source_id,
                        x_return_status             => x_return_status,
                        x_msg_count                 => x_msg_count,
                        x_msg_data                  => x_msg_data );
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_fp_gen_amount_utils.fp_debug
                           ( p_called_mode => p_calling_context,
                             p_msg         => 'Status after calling
                                               pa_fp_gen_amount_utils.Get_Curr_Original_Version_Info'
                                               ||x_return_status,
                             p_module_name => l_module_name,
                             p_log_level   => 5 );
                    END IF;
                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;

                ELSIF l_gen_src_plan_ver_code = 'CURRENT_WORKING' THEN
                   /*Get the current working version*/
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_fp_gen_amount_utils.fp_debug
                            ( p_called_mode => p_calling_context,
                              p_msg         => 'Before calling
                                                pa_fin_plan_utils.Get_Curr_Working_Version_Info',
                              p_module_name => l_module_name,
                              p_log_level   => 5 );
                    END IF;
                    pa_fin_plan_utils.Get_Curr_Working_Version_Info
                        ( p_project_id                => P_FP_COLS_REC_TGT.X_PROJECT_ID,
                          p_fin_plan_type_id          => P_FP_COLS_REC_TGT.X_GEN_SRC_PLAN_TYPE_ID,
                          p_version_type              => 'COST',
                          x_fp_options_id             => l_fp_options_id,
                          x_fin_plan_version_id       => l_source_id,
                          x_return_status             => x_return_status,
                          x_msg_count                 => x_msg_count,
                          x_msg_data                  => x_msg_data );
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_fp_gen_amount_utils.fp_debug
                            ( p_called_mode => p_calling_context,
                              p_msg         => 'Status after calling
                                               pa_fin_plan_utils.Get_Curr_Working_Version_Info'
                                               ||x_return_status,
                              p_module_name => l_module_name,
                              p_log_level   => 5 );
                    END IF;
                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;
                 ELSE
                     l_dummy := 1;
                 END IF;

                 IF l_source_id IS NULL THEN
                     PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                           p_msg_name       => 'PA_SRC_FP_VER_NULL');
                     raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                 END IF;
            END IF;
            --dbms_output.put_line('==l_source_id:'||l_source_id);

            l_version_type := P_FP_COLS_REC_TGT.x_version_type;
            /*As of now, we have l_source_id as fin version id
             * Now, we need to update back to pa_proj_fp_options*/
            IF l_version_type = 'COST' THEN
                UPDATE PA_PROJ_FP_OPTIONS
                SET GEN_SRC_COST_PLAN_VERSION_ID = l_source_id
                WHERE fin_plan_version_id = P_FP_COLS_REC_TGT.X_BUDGET_VERSION_ID;
            ELSIF l_version_type = 'ALL' THEN
                UPDATE PA_PROJ_FP_OPTIONS
                SET GEN_SRC_ALL_PLAN_VERSION_ID = l_source_id
                WHERE fin_plan_version_id = P_FP_COLS_REC_TGT.X_BUDGET_VERSION_ID;
            ELSIF l_version_type = 'REVENUE' THEN
                UPDATE PA_PROJ_FP_OPTIONS
                SET GEN_SRC_REV_PLAN_VERSION_ID = l_source_id
                WHERE fin_plan_version_id = P_FP_COLS_REC_TGT.X_BUDGET_VERSION_ID;
            END IF;
        END IF; -- end gen_src_code-based logic


        /* Get updated Target version details */
        -- Currently, l_update_details_flag is always 'Y', but may change in the future.
        IF l_update_details_flag = 'Y' THEN
            IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                    (p_called_mode => p_calling_context,
                     p_msg         => 'Before calling
                                      PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS',
                     p_module_name => l_module_name,
                     p_log_level   => 5);
            END IF;
            PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
                                (P_PROJECT_ID           => P_FP_COLS_REC_TGT.X_PROJECT_ID,
                                 P_BUDGET_VERSION_ID    => P_FP_COLS_REC_TGT.X_BUDGET_VERSION_ID,
                                 X_FP_COLS_REC          => X_FP_COLS_REC_TGT,
                                 X_RETURN_STATUS        => X_RETURN_STATUS,
                                 X_MSG_COUNT            => X_MSG_COUNT,
                                 X_MSG_DATA             => X_MSG_DATA);
            IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                    (p_called_mode => p_calling_context,
                     p_msg         => 'Status after calling
                                      PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS: '
                                      ||x_return_status,
                     p_module_name => l_module_name,
                     p_log_level   => 5);
            END IF;
            IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
        END IF; -- l_update_details_flag check

    END IF; -- defaulting logic

    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.RESET_CURR_FUNCTION;
    END IF;
EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count = 1 THEN
            PA_INTERFACE_UTILS_PUB.get_messages
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

        x_return_status := FND_API.G_RET_STS_ERROR;

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_called_mode => p_calling_context,
                  p_msg         => 'Invalid Arguments Passed',
                  p_module_name => l_module_name,
                  p_log_level   => 5 );
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;

        ROLLBACK;
        RAISE;
     WHEN OTHERS THEN
        rollback;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_GEN_AMOUNT_UTILS',
                     p_procedure_name  => 'DEFAULT_BDGT_SRC_VER',
                     p_error_text      => substr(sqlerrm,1,240));

        IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_called_mode => p_calling_context,
                p_msg         => 'Unexpected Error'||substr(sqlerrm,1,240),
                p_module_name => l_module_name,
                p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END DEFAULT_BDGT_SRC_VER;



END  PA_FP_GEN_AMOUNT_UTILS;

/
