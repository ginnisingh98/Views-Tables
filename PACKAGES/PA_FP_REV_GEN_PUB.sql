--------------------------------------------------------
--  DDL for Package PA_FP_REV_GEN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_REV_GEN_PUB" AUTHID CURRENT_USER as
/* $Header: PAFPGCRS.pls 120.1 2005/09/01 23:55:13 appldev noship $ */

PROCEDURE GEN_COST_BASED_REVENUE
          (P_BUDGET_VERSION_ID   IN           PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC         IN           PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_ETC_START_DATE      IN
              PA_BUDGET_VERSIONS.ETC_START_DATE%TYPE DEFAULT NULL,
           X_RETURN_STATUS       OUT   NOCOPY VARCHAR2,
           X_MSG_COUNT           OUT   NOCOPY NUMBER,
           X_MSG_DATA	         OUT   NOCOPY VARCHAR2);

/**
 * Created as part of fix for Bug 4549862.
 *
 * This private procedure is meant to be used by GEN_COST_BASED_REVENUE
 * when generating a Cost and Revenue together version with source of
 * Staffing Plan and revenue accrual method of COST.
 *
 * This procedure propagates generation data stored in PA_FP_ROLLUP_TMP
 * and Inserts/Updates it into PA_BUDGET_LINES. This includes txn/pc/pfc
 * amounts, rate overrides, pc/pfc exchange rates, cost/revenue rate types,
 * and rejection codes.
 *
 * This API should always be called by GEN_COST_BASED_REVENUE before
 * returning with return status of Success.
 **/
PROCEDURE PUSH_RES_SCH_DATA_TO_BL
          (P_BUDGET_VERSION_ID   IN           PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC         IN           PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_ETC_START_DATE      IN           PA_BUDGET_VERSIONS.ETC_START_DATE%TYPE,
           P_PLAN_CLASS_CODE     IN           PA_FIN_PLAN_TYPES_B.PLAN_CLASS_CODE%TYPE,
           X_RETURN_STATUS       OUT   NOCOPY VARCHAR2,
           X_MSG_COUNT           OUT   NOCOPY NUMBER,
           X_MSG_DATA            OUT   NOCOPY VARCHAR2);

END PA_FP_REV_GEN_PUB;

 

/
