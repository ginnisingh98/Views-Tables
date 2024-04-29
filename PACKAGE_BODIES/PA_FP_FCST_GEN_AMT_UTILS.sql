--------------------------------------------------------
--  DDL for Package Body PA_FP_FCST_GEN_AMT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_FCST_GEN_AMT_UTILS" as
/* $Header: PAFPGFUB.pls 120.3 2007/02/06 09:59:05 dthakker noship $ */

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

/**
 * This procedure verifies that the following attributes match for the specified
 * Source plan version(s) and Target plan version:
 *    i.    Fully shared WBS (if source WP bvid not null) -- Bug 4251201
 *    ii.   Resource List
 *    iii.  Time Phasing
 *    iv.   Planning Level
 *    v.    Multi-Currency Option
 * With the exception of multi-currency and planning level, attributes are said
 * to match if equal.
 * The following table defines the conditions under which multi-currency matches:
 *    Source   Target   Match
 *      Y        Y        Y
 *      N        Y        Y
 *      N        N        Y
 *      Y        N        N
 * Note that the only case for multi-currency mismatch is when the Source is
 * multi-currency enabled and the Target is not. Additionally, note that when
 * both Source versions are supplied, we check that multi-currency matches
 * between each Source and the Target (Source multi-currency options do not
 * have to match each other).
 * The following table defines when planning levels *do not* match:
 *    Source   Target   Match
 *      L        T        N
 *      L        P        N
 *      T        P        N
 * All other planning level combinations (i.e. when the source is planned at
 * the same or higher level compared to the target) are considered to match.
 *
 * The parameters P_PROJECT_ID and P_FP_TARGET_PLAN_VER_ID must be non-null.
 * If at least one of P_WP_SRC_PLAN_VER_ID and P_FP_SRC_PLAN_VER_ID is non-null
 * and the attributes match for all specified plan versions, then the OUT
 * parameter X_SAME_PLANNING_OPTION_FLAG will have value 'Y'.Otherwise,
 * X_SAME_PLANNING_OPTION_FLAG will have value 'N'.
 */
PROCEDURE COMPARE_ETC_SRC_TARGET_FP_OPT
          (P_PROJECT_ID                     IN            PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_WP_SRC_PLAN_VER_ID 	    IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_SRC_PLAN_VER_ID 	    IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_TARGET_PLAN_VER_ID 	    IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           X_SAME_PLANNING_OPTION_FLAG      OUT  NOCOPY   VARCHAR2,
           X_RETURN_STATUS                  OUT  NOCOPY   VARCHAR2,
           X_MSG_COUNT                      OUT  NOCOPY   NUMBER,
           X_MSG_DATA	                    OUT  NOCOPY   VARCHAR2)
IS
    l_module_name VARCHAR2(100) := 'pa.plsql.PA_FP_FCST_GEN_AMT_UTILS.COMPARE_ETC_SRC_TARGET_FP_OPT';
    l_log_level                 CONSTANT PLS_INTEGER := 5;
    l_count			NUMBER;
    l_msg_count			NUMBER;
    l_data			VARCHAR2(1000);
    l_msg_data			VARCHAR2(1000);
    l_msg_index_out             NUMBER;

    l_stru_sharing_code         PA_PROJECTS_ALL.STRUCTURE_SHARING_CODE%TYPE;
    l_fp_cols_rec_target        PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
    l_fp_cols_rec_src           PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;

    IF p_pa_debug_mode = 'Y' THEN
	PA_DEBUG.SET_CURR_FUNCTION( p_function   => 'COMPARE_ETC_SRC_TARGET_FP_OPT',
                                    p_debug_mode => p_pa_debug_mode );
    END IF;

    /* Initialize the planning option flag */
    x_same_planning_option_flag := 'N';

    /* Enforce that p_project_id and p_fp_target_plan_ver_id are non-null */
    IF p_project_id IS NULL OR p_fp_target_plan_ver_id IS NULL THEN
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_INV_PARAM_PASSED' );
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    /* Check that the project has Fully Shared WBS,
     * and that one of p_wp_src_plan_ver_id or p_fp_src_plan_ver_id is non-null */

    -- Bug 4251201: We should only check that the WBS is Fully Shared
    -- when the passed Workplan budget_version_id parameter is not null.

    l_stru_sharing_code :=
        PA_PROJECT_STRUCTURE_UTILS.GET_STRUCTURE_SHARING_CODE( p_project_id => p_project_id );
    IF (p_wp_src_plan_ver_id IS NULL AND p_fp_src_plan_ver_id IS NULL)  OR
       (p_wp_src_plan_ver_id IS NOT NULL AND l_stru_sharing_code <> 'SHARE_FULL') THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RETURN;
    END IF;

    /* CAll API to get Target data into l_fp_cols_rec_target. */
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'Before calling PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS',
              p_module_name => l_module_name,
              p_log_level   => l_log_level );
    END IF;
    PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS( p_project_id        => p_project_id,
                                                  p_budget_version_id => p_fp_target_plan_ver_id,
                                                  x_fp_cols_rec       => l_fp_cols_rec_target,
                                                  x_return_status     => x_return_status,
                                                  x_msg_count         => x_msg_count,
                                                  x_msg_data          => x_msg_data );
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'Status after calling
                                PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS: '
                                || x_return_status,
              p_module_name => l_module_name,
              p_log_level   => l_log_level );
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    /* Re-Initialize flag */
    x_same_planning_option_flag := 'Y';

    /* Check Source workplan attributes against Target plan */
    IF p_wp_src_plan_ver_id IS NOT NULL THEN

        /* CAll API to get Source data into l_fp_cols_rec_src */
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( p_msg         => 'Before calling PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS',
                  p_module_name => l_module_name,
                  p_log_level   => l_log_level );
        END IF;
        PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS( p_project_id        => p_project_id,
                                                      p_budget_version_id => p_wp_src_plan_ver_id,
                                                      x_fp_cols_rec       => l_fp_cols_rec_src,
                                                      x_return_status     => x_return_status,
                                                      x_msg_count         => x_msg_count,
                                                      x_msg_data          => x_msg_data );
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( p_msg         => 'Status after calling
                                    PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS: '
                                    || x_return_status,
                  p_module_name => l_module_name,
                  p_log_level   => l_log_level );
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        /* Verify that Source and Target plan attributes of interest match */
        IF l_fp_cols_rec_src.x_resource_list_id <> l_fp_cols_rec_target.x_resource_list_id OR
           l_fp_cols_rec_src.x_time_phased_code <> l_fp_cols_rec_target.x_time_phased_code OR
          (l_fp_cols_rec_src.x_fin_plan_level_code = 'L' AND
           l_fp_cols_rec_target.x_fin_plan_level_code IN ('T','P')) OR
          (l_fp_cols_rec_src.x_fin_plan_level_code = 'T' AND
           l_fp_cols_rec_target.x_fin_plan_level_code = 'P' ) OR
          (l_fp_cols_rec_src.x_plan_in_multi_curr_flag = 'Y' AND
           l_fp_cols_rec_target.x_plan_in_multi_curr_flag = 'N') THEN
            x_same_planning_option_flag := 'N';
            IF p_pa_debug_mode = 'Y' THEN
                PA_DEBUG.RESET_CURR_FUNCTION;
            END IF;
            RETURN;
        END IF;
    END IF;

    /* Check Source financial plan attributes against Target plan */
    IF p_fp_src_plan_ver_id IS NOT NULL THEN

        /* CAll API to get Source data into l_fp_cols_rec_src */
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( p_msg         => 'Before calling PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS',
                  p_module_name => l_module_name,
                  p_log_level   => l_log_level );
        END IF;
        PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS( p_project_id        => p_project_id,
                                                      p_budget_version_id => p_fp_src_plan_ver_id,
                                                      x_fp_cols_rec       => l_fp_cols_rec_src,
                                                      x_return_status     => x_return_status,
                                                      x_msg_count         => x_msg_count,
                                                      x_msg_data          => x_msg_data );
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( p_msg         => 'Status after calling
                                    PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS: '
                                    || x_return_status,
                  p_module_name => l_module_name,
                  p_log_level   => l_log_level );
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        /* Verify that Source and Target plan attributes of interest match */
        IF l_fp_cols_rec_src.x_resource_list_id <> l_fp_cols_rec_target.x_resource_list_id OR
           l_fp_cols_rec_src.x_time_phased_code <> l_fp_cols_rec_target.x_time_phased_code OR
          (l_fp_cols_rec_src.x_fin_plan_level_code = 'L' AND
           l_fp_cols_rec_target.x_fin_plan_level_code IN ('T','P')) OR
          (l_fp_cols_rec_src.x_fin_plan_level_code = 'T' AND
           l_fp_cols_rec_target.x_fin_plan_level_code = 'P' ) OR
          (l_fp_cols_rec_src.x_plan_in_multi_curr_flag = 'Y' AND
           l_fp_cols_rec_target.x_plan_in_multi_curr_flag = 'N') THEN
            x_same_planning_option_flag := 'N';
        END IF;
    END IF;

    IF p_pa_debug_mode = 'Y' THEN
      	PA_DEBUG.RESET_CURR_FUNCTION;
    END IF;
EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count = 1 THEN
            PA_INTERFACE_UTILS_PUB.GET_MESSAGES
                ( p_encoded       => FND_API.G_TRUE,
                  p_msg_index     => 1,
                  p_msg_count     => l_msg_count,
                  p_msg_data      => l_msg_data,
                  p_data          => l_data,
                  p_msg_index_out => l_msg_index_out );
            x_msg_data := l_data;
            x_msg_count := l_msg_count;
        ELSE
            x_msg_count := l_msg_count;
        END IF;

        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( p_msg         => 'Invalid Arguments Passed',
                  p_module_name => l_module_name,
                  p_log_level   => l_log_level );
	    PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        FND_MSG_PUB.ADD_EXC_MSG
            ( p_pkg_name       => 'PA_FP_FCST_GEN_AMT_UTILS',
              p_procedure_name => 'COMPARE_ETC_SRC_TARGET_FP_OPT',
              p_error_text     => substr(sqlerrm,1,240) );

	IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                  p_module_name => l_module_name,
                  p_log_level   => l_log_level );
   	    PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END COMPARE_ETC_SRC_TARGET_FP_OPT;

/***
 	  * For Remaining Plan, Work Quantity, and non-Commitment ETC,
 	  * whether an ETC quantity/amount should be generated or not
 	  * is a function of its sign (i.e. positive or negative) in
 	  * relation to the sign of the (plan) amount it is derived from.
 	  * This function tests whether plan and ETC quantity/amounts
 	  * having matching signs.
 	  *
 	  * The function behaves as follows:
 	  * Returns TRUE if (plan >= 0 and etc > 0) or (plan < 0 and etc < 0).
 	  * Returns FALSE otherwise.
 	  *
 	  * Parameters:
 	  *   P_PLAN_QTY_OR_AMT
 	  *      The plan quantity or amount used to compute the value
 	  *      of p_etc_qty_or_amt.
 	  *   P_ETC_QTY_OR_AMT
 	  *      The ETC quantity or amount computed from p_plan_qty_or_amt.
 	  *   P_CALLING_MODULE
 	  *      The module calling this function. Valid values include:
 	  *      'FORECAST_GENERATION'
 	  *      'WORKPLAN'
 	  *      This parameter can be used later to change the behavior
 	  *      of this function based on the needs of a calling module.
 	  */
 	 FUNCTION PLAN_ETC_SIGNS_MATCH
 	        ( P_PLAN_QTY_OR_AMT  IN  NUMBER,
 	          P_ETC_QTY_OR_AMT   IN  NUMBER,
 	          P_CALLING_MODULE   IN  VARCHAR2 ) RETURN BOOLEAN
 	 IS
 	 BEGIN
 	     RETURN (p_plan_qty_or_amt >= 0 AND p_etc_qty_or_amt > 0) OR
 	            (p_plan_qty_or_amt < 0  AND p_etc_qty_or_amt < 0);
 	 END PLAN_ETC_SIGNS_MATCH;

 	 /*
 	  * For Workplan progress, this function computes the ETC quantity based
 	  * on Planned and Actual Qty by applying the following rules. This function
 	  * is another variation of function PLAN_ETC_SIGNS_MATCH in this package.
 	  *
 	  * 1. If actual > plan and plan is negative, ETC = Plan - Actual
 	  * 2. If actual > plan and plan is positive, ETC = 0
 	  * 3. If actual < plan and plan is negative, ETC = 0
 	  * 4. If actual < plan and plan is positive, ETC = Plan - Actual
 	  * 5. If actual = plan, ETC = 0
 	  *
 	  * Parameters:
 	  *   P_PLAN_QTY_OR_AMT
 	  *      The plan quantity or amount used to compute the value
 	  *      of p_etc_qty_or_amt.
 	  *   P_ACT_QTY_OR_AMT
 	  *      The actual quantity or amount computed from p_plan_qty_or_amt.
 	  *   P_CALLING_MODULE
 	  *      The module calling this function. Valid values include:
 	  *      'FORECAST_GENERATION'
 	  *      'WORKPLAN'
 	  *      This parameter can be used later to change the behavior
 	  *      of this function based on the needs of a calling module.
 	  */
 	 FUNCTION GET_ETC_FROM_PLAN_ACT
 	       ( P_PLAN_QTY_OR_AMT  IN  NUMBER,
 	         P_ACT_QTY_OR_AMT   IN  NUMBER,
 	         P_CALLING_MODULE   IN  VARCHAR2 DEFAULT 'FORECAST_GENERATION' ) RETURN NUMBER
 	 IS
 	     l_etc_qty_or_amt  NUMBER;
 	 BEGIN
 	     l_etc_qty_or_amt := nvl(p_plan_qty_or_amt,0) - nvl(p_act_qty_or_amt,0);
 	     IF NOT PLAN_ETC_SIGNS_MATCH
 	            (p_plan_qty_or_amt,l_etc_qty_or_amt,p_calling_module) THEN
 	         l_etc_qty_or_amt := 0;
 	     END IF;
 	     RETURN l_etc_qty_or_amt;
 	 END get_etc_from_plan_act;

END PA_FP_FCST_GEN_AMT_UTILS;

/
