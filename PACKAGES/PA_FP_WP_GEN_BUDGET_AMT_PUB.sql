--------------------------------------------------------
--  DDL for Package PA_FP_WP_GEN_BUDGET_AMT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_WP_GEN_BUDGET_AMT_PUB" AUTHID CURRENT_USER as
/* $Header: PAFPWPGS.pls 120.0 2005/05/29 13:32:24 appldev noship $ */
PROCEDURE GENERATE_WP_BUDGET_AMT
          (P_PROJECT_ID                   IN            PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID 	          IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_PLAN_CLASS_CODE              IN            PA_FIN_PLAN_TYPES_B.PLAN_CLASS_CODE%TYPE DEFAULT 'Budget',
           P_GEN_SRC_CODE                 IN            PA_PROJ_FP_OPTIONS.GEN_ALL_SRC_CODE%TYPE
                                                            DEFAULT 'WORKPLAN_RESOURCES',
           P_COST_PLAN_TYPE_ID            IN            PA_PROJ_FP_OPTIONS.GEN_SRC_COST_PLAN_TYPE_ID%TYPE,
	   P_COST_VERSION_ID              IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE DEFAULT NULL,
 	   P_RETAIN_MANUAL_FLAG           IN            VARCHAR2 DEFAULT NULL,
 	   P_CALLED_MODE                  IN            VARCHAR2 DEFAULT 'SELF_SERVICE',
	   P_INC_CHG_DOC_FLAG             IN            VARCHAR2 DEFAULT 'N',
	   P_INC_BILL_EVENT_FLAG          IN            VARCHAR2 DEFAULT 'N',
           P_INC_OPEN_COMMIT_FLAG         IN            VARCHAR2 DEFAULT 'N',
           P_CI_ID_TAB                    IN            PA_PLSQL_DATATYPES.IdTabTyp
                                                            DEFAULT PA_PLSQL_DATATYPES.EmptyIdTab,
           P_INIT_MSG_FLAG                IN           VARCHAR2 DEFAULT 'Y',
           P_COMMIT_FLAG                  IN           VARCHAR2 DEFAULT 'N',
           P_CALLING_CONTEXT              IN           VARCHAR2 DEFAULT 'BUDGET_GENERATION',
           P_ETC_PLAN_TYPE_ID             IN           PA_PROJ_FP_OPTIONS.FIN_PLAN_TYPE_ID%TYPE DEFAULT NULL,
           P_ETC_PLAN_VERSION_ID          IN           PA_PROJ_FP_OPTIONS.FIN_PLAN_VERSION_ID%TYPE DEFAULT NULL,
           P_ETC_PLAN_VERSION_NAME        IN           PA_BUDGET_VERSIONS.VERSION_NAME%TYPE DEFAULT NULL,
           P_ACTUALS_THRU_DATE            IN           PA_PERIODS_ALL.END_DATE%TYPE DEFAULT NULL,
           PX_DELETED_RES_ASG_ID_TAB      IN  OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
           PX_GEN_RES_ASG_ID_TAB          IN  OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
           X_RETURN_STATUS                OUT NOCOPY   VARCHAR2,
           X_MSG_COUNT                    OUT NOCOPY   NUMBER,
           X_MSG_DATA	                  OUT NOCOPY   VARCHAR2);

PROCEDURE MAINTAIN_BUDGET_LINES
          (P_PROJECT_ID                   IN           PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_SOURCE_BV_ID                 IN           PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_TARGET_BV_ID                 IN           PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_CALLING_CONTEXT              IN           VARCHAR2 DEFAULT 'BUDGET_GENERATION',
           P_ACTUALS_THRU_DATE            IN           PA_PERIODS_ALL.END_DATE%TYPE DEFAULT NULL,
           P_RETAIN_MANUAL_FLAG           IN           VARCHAR2 DEFAULT 'N',
           X_RETURN_STATUS                OUT NOCOPY   VARCHAR2,
           X_MSG_COUNT                    OUT NOCOPY   NUMBER,
           X_MSG_DATA	                  OUT NOCOPY   VARCHAR2);

PROCEDURE GET_CALC_API_FLAG_PARAMS
   (P_PROJECT_ID                   IN           PA_PROJECTS_ALL.PROJECT_ID%TYPE,
    P_FP_COLS_REC_SOURCE           IN           PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
    P_FP_COLS_REC_TARGET           IN           PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
    P_CALLING_CONTEXT              IN           VARCHAR2 DEFAULT 'BUDGET_GENERATION',
    X_CALCULATE_API_CODE           OUT NOCOPY   VARCHAR2,
    X_RETURN_STATUS                OUT NOCOPY   VARCHAR2,
    X_MSG_COUNT                    OUT NOCOPY   NUMBER,
    X_MSG_DATA                     OUT NOCOPY   VARCHAR2);

END PA_FP_WP_GEN_BUDGET_AMT_PUB;

 

/
