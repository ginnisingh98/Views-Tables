--------------------------------------------------------
--  DDL for Package PA_FP_FCST_GEN_AMT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_FCST_GEN_AMT_UTILS" AUTHID CURRENT_USER as
/* $Header: PAFPGFUS.pls 120.3 2007/02/06 09:59:37 dthakker noship $ */
PROCEDURE COMPARE_ETC_SRC_TARGET_FP_OPT
          (P_PROJECT_ID                     IN            PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_WP_SRC_PLAN_VER_ID 	    IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_SRC_PLAN_VER_ID 	    IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_TARGET_PLAN_VER_ID 	    IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           X_SAME_PLANNING_OPTION_FLAG      OUT  NOCOPY   VARCHAR2,
           X_RETURN_STATUS                  OUT  NOCOPY   VARCHAR2,
           X_MSG_COUNT                      OUT  NOCOPY   NUMBER,
           X_MSG_DATA	                    OUT  NOCOPY   VARCHAR2);

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
 	          P_CALLING_MODULE   IN  VARCHAR2 DEFAULT 'FORECAST_GENERATION' )
 	 RETURN BOOLEAN;

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
 	         P_CALLING_MODULE   IN  VARCHAR2 DEFAULT 'FORECAST_GENERATION' )
 	 RETURN NUMBER;

END PA_FP_FCST_GEN_AMT_UTILS;

/
