--------------------------------------------------------
--  DDL for Package PA_FP_COPY_ACTUALS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_COPY_ACTUALS_PUB" AUTHID CURRENT_USER as
/* $Header: PAFPCAPS.pls 120.0.12010000.2 2009/06/15 10:18:09 gboomina ship $ */
PROCEDURE COPY_ACTUALS
          (P_PROJECT_ID            IN  PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID 	   IN  PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
	   P_FP_COLS_REC           IN  PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_END_DATE              IN  DATE,
           P_INIT_MSG_FLAG         IN  VARCHAR2 default 'Y',
           P_COMMIT_FLAG           IN  VARCHAR2 default 'N',
           X_RETURN_STATUS         OUT NOCOPY   VARCHAR2,
           X_MSG_COUNT             OUT NOCOPY   NUMBER,
           X_MSG_DATA	           OUT NOCOPY   VARCHAR2);

/* Valid values for p_calling_process
   COPY_ACTUALS
   FORECAST_GENERATION
*/
PROCEDURE  CREATE_RES_ASG (
           P_PROJECT_ID            IN  PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
	   P_BUDGET_VERSION_ID     IN  PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC           IN  PA_FP_GEN_AMOUNT_UTILS.FP_COLS DEFAULT NULL,
           p_calling_process       IN  VARCHAR2 default 'COPY_ACTUALS',
           X_RETURN_STATUS         OUT NOCOPY   VARCHAR2,
           X_MSG_COUNT             OUT NOCOPY   NUMBER,
           X_MSG_DATA	           OUT NOCOPY   VARCHAR2);


PROCEDURE  UPDATE_RES_ASG (
           P_PROJECT_ID            IN  PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
	   P_BUDGET_VERSION_ID     IN  PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC           IN  PA_FP_GEN_AMOUNT_UTILS.FP_COLS DEFAULT NULL,
           p_calling_process       IN  VARCHAR2 default 'COPY_ACTUALS',
           X_RETURN_STATUS         OUT NOCOPY   VARCHAR2,
           X_MSG_COUNT             OUT NOCOPY   NUMBER,
           X_MSG_DATA	           OUT NOCOPY   VARCHAR2);

/**
  * gboomina added this method for AAI requirement
  * This procedure is called to collect actuals for a selected resource assignments or
  * for a whole budget version given.
  **/
  PROCEDURE COLLECT_ACTUALS
            (P_PROJECT_ID           IN   PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
             P_BUDGET_VERSION_ID    IN   PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
             P_RESOURCE_ASSGN_IDS   IN   SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
             P_INIT_MSG_FLAG        IN   VARCHAR2 default 'Y',
             P_COMMIT_FLAG          IN   VARCHAR2 default 'N',
             X_RETURN_STATUS        OUT  NOCOPY   VARCHAR2,
             X_MSG_COUNT            OUT  NOCOPY   NUMBER,
             X_MSG_DATA             OUT  NOCOPY   VARCHAR2);

END PA_FP_COPY_ACTUALS_PUB;

/
