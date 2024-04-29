--------------------------------------------------------
--  DDL for Package PA_FP_GEN_BUDGET_AMT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_GEN_BUDGET_AMT_PUB" AUTHID CURRENT_USER as
/* $Header: PAFPGAMS.pls 120.2 2005/07/15 10:57:09 appldev noship $ */

/**
 * Wrapper API
 *
 * 23-MAY-05 dkuo Added parameters P_CHECK_SRC_ERRORS, X_WARNING_MESSAGE.
 *                Please check body of VALIDATE_SUPPORT_CASES in PAFPGAUB.pls
 *                for list of valid parameter values.
 **/
PROCEDURE GENERATE_BUDGET_AMT_WRP
       (P_PROJECT_ID                     IN            pa_projects_all.PROJECT_ID%TYPE,
        P_BUDGET_VERSION_ID 	         IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
        P_CALLED_MODE                    IN            VARCHAR2 DEFAULT 'SELF_SERVICE',
        P_COMMIT_FLAG                    IN            VARCHAR2 DEFAULT 'N',
        P_INIT_MSG_FLAG                  IN            VARCHAR2 DEFAULT 'Y',
        P_CHECK_SRC_ERRORS_FLAG          IN            VARCHAR2 DEFAULT 'Y',
        X_WARNING_MESSAGE                OUT NOCOPY    VARCHAR2,
        X_RETURN_STATUS                  OUT  NOCOPY   VARCHAR2,
        X_MSG_COUNT                      OUT  NOCOPY   NUMBER,
        X_MSG_DATA	                 OUT  NOCOPY   VARCHAR2);


PROCEDURE GENERATE_BUDGET_AMT_RES_SCH
          (P_PROJECT_ID                     IN            pa_projects_all.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID 	            IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC                    IN            PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_PLAN_CLASS_CODE                IN            PA_FIN_PLAN_TYPES_B.PLAN_CLASS_CODE%TYPE,
           P_GEN_SRC_CODE                   IN            PA_PROJ_FP_OPTIONS.GEN_ALL_SRC_CODE%TYPE,
           P_COST_PLAN_TYPE_ID              IN            PA_PROJ_FP_OPTIONS.GEN_SRC_COST_PLAN_TYPE_ID%TYPE,
	   P_COST_VERSION_ID                IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
 	   P_RETAIN_MANUAL_FLAG             IN            PA_PROJ_FP_OPTIONS.GEN_COST_RET_MANUAL_LINE_FLAG%TYPE,
 	   P_CALLED_MODE                    IN            VARCHAR2 := 'SELF_SERVICE',
	   P_INC_CHG_DOC_FLAG               IN            PA_PROJ_FP_OPTIONS.GEN_COST_INCL_CHANGE_DOC_FLAG%TYPE,
	   P_INC_BILL_EVENT_FLAG            IN            PA_PROJ_FP_OPTIONS.GEN_REV_INCL_BILL_EVENT_FLAG%TYPE,
           P_INC_OPEN_COMMIT_FLAG           IN            PA_PROJ_FP_OPTIONS.GEN_COST_INCL_OPEN_COMM_FLAG%TYPE,
           P_ACTUALS_THRU_DATE              IN            PA_PERIODS_ALL.END_DATE%TYPE DEFAULT NULL,
           P_CI_ID_TAB                      IN            PA_PLSQL_DATATYPES.IdTabTyp,
           PX_GEN_RES_ASG_ID_TAB            IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
           PX_DELETED_RES_ASG_ID_TAB        IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
           P_COMMIT_FLAG                    IN            VARCHAR2,
           P_INIT_MSG_FLAG                  IN            VARCHAR2,
           X_RETURN_STATUS                  OUT  NOCOPY   VARCHAR2,
           X_MSG_COUNT                      OUT  NOCOPY   NUMBER,
           X_MSG_DATA	                    OUT  NOCOPY   VARCHAR2);

PROCEDURE CREATE_RES_ASG
          (P_PROJECT_ID                 IN           PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID 	        IN           PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_STRU_SHARING_CODE          IN           PA_PROJECTS_ALL.STRUCTURE_SHARING_CODE%TYPE,
           P_GEN_SRC_CODE                   IN            PA_PROJ_FP_OPTIONS.GEN_ALL_SRC_CODE%TYPE,
           P_FP_COLS_REC                    IN       PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
	   P_WP_STRUCTURE_VER_ID	IN   PA_BUDGET_VERSIONS.PROJECT_STRUCTURE_VERSION_ID%TYPE DEFAULT NULL,
           X_RETURN_STATUS              OUT  NOCOPY  VARCHAR2,
           X_MSG_COUNT                  OUT  NOCOPY  NUMBER,
           X_MSG_DATA	                OUT  NOCOPY  VARCHAR2);

PROCEDURE UPDATE_RES_ASG
          (P_PROJECT_ID                 IN           PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID 	    IN           PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_STRU_SHARING_CODE          IN           PA_PROJECTS_ALL.STRUCTURE_SHARING_CODE%TYPE,
           P_GEN_SRC_CODE                   IN            PA_PROJ_FP_OPTIONS.GEN_ALL_SRC_CODE%TYPE,
           P_FP_COLS_REC                    IN       PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_WP_STRUCTURE_VER_ID	IN   PA_BUDGET_VERSIONS.PROJECT_STRUCTURE_VERSION_ID%TYPE DEFAULT NULL,
           X_RETURN_STATUS              OUT  NOCOPY  VARCHAR2,
           X_MSG_COUNT                  OUT  NOCOPY  NUMBER,
           X_MSG_DATA	                OUT  NOCOPY  VARCHAR2);


PROCEDURE DEL_MANUAL_BDGT_LINES
           (P_PROJECT_ID                    IN             PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID 	            IN             PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           PX_RES_ASG_ID_TAB                IN OUT NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp,
           PX_DELETED_RES_ASG_ID_TAB        IN OUT NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp,
           X_RETURN_STATUS                  OUT   NOCOPY   VARCHAR2,
           X_MSG_COUNT                      OUT   NOCOPY   NUMBER,
           X_MSG_DATA	                    OUT   NOCOPY   VARCHAR2);

PROCEDURE UPDATE_INIT_AMOUNTS
          (P_PROJECT_ID                     IN            PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID 	            IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_RES_ASG_ID_TAB                 IN            PA_PLSQL_DATATYPES.IdTabTyp,
           X_RETURN_STATUS                  OUT   NOCOPY  VARCHAR2,
           X_MSG_COUNT                      OUT   NOCOPY  NUMBER,
           X_MSG_DATA	                    OUT   NOCOPY  VARCHAR2);


PROCEDURE UPDATE_BV_FOR_GEN_DATE
          (P_PROJECT_ID                     IN
           PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID 	            IN
           PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_ETC_START_DATE                 IN
           PA_BUDGET_VERSIONS.ETC_START_DATE%TYPE DEFAULT NULL,
           X_RETURN_STATUS                  OUT   NOCOPY  VARCHAR2,
           X_MSG_COUNT                      OUT   NOCOPY  NUMBER,
           X_MSG_DATA	                    OUT   NOCOPY  VARCHAR2);

PROCEDURE GET_GENERATED_RES_ASG
           (P_PROJECT_ID                    IN             PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID 	            IN             PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           PX_GEN_RES_ASG_ID_TAB            IN OUT NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp,
           P_CHK_DUPLICATE_FLAG             IN             VARCHAR2 := 'N',
           X_RETURN_STATUS                  OUT   NOCOPY   VARCHAR2,
           X_MSG_COUNT                      OUT   NOCOPY   NUMBER,
           X_MSG_DATA	                    OUT   NOCOPY   VARCHAR2);

PROCEDURE INSERT_TXN_CURRENCY
          (P_PROJECT_ID                     IN            PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE DEFAULT NULL,
           P_BUDGET_VERSION_ID 	            IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC                    IN            PA_FP_GEN_AMOUNT_UTILS.FP_COLS DEFAULT NULL,
           X_RETURN_STATUS                  OUT   NOCOPY  VARCHAR2,
           X_MSG_COUNT                      OUT   NOCOPY  NUMBER,
           X_MSG_DATA	                    OUT   NOCOPY  VARCHAR2);

PROCEDURE RESET_COST_AMOUNTS
          (P_BUDGET_VERSION_ID 	            IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           X_RETURN_STATUS                  OUT   NOCOPY  VARCHAR2,
           X_MSG_COUNT                      OUT   NOCOPY  NUMBER,
           X_MSG_DATA	                    OUT   NOCOPY  VARCHAR2);

PROCEDURE GEN_REV_BDGT_AMT_RES_SCH_WRP
          (P_PROJECT_ID                     IN            pa_projects_all.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID 	            IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC                    IN            PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_PLAN_CLASS_CODE                IN            PA_FIN_PLAN_TYPES_B.PLAN_CLASS_CODE%TYPE,
           P_GEN_SRC_CODE                   IN            PA_PROJ_FP_OPTIONS.GEN_ALL_SRC_CODE%TYPE,
           P_COST_PLAN_TYPE_ID              IN            PA_PROJ_FP_OPTIONS.GEN_SRC_COST_PLAN_TYPE_ID%TYPE,
	   P_COST_VERSION_ID                IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
 	   P_RETAIN_MANUAL_FLAG             IN            PA_PROJ_FP_OPTIONS.GEN_COST_RET_MANUAL_LINE_FLAG%TYPE,
 	   P_CALLED_MODE                    IN            VARCHAR2 := 'SELF_SERVICE',
	   P_INC_CHG_DOC_FLAG               IN            PA_PROJ_FP_OPTIONS.GEN_COST_INCL_CHANGE_DOC_FLAG%TYPE,
	   P_INC_BILL_EVENT_FLAG            IN            PA_PROJ_FP_OPTIONS.GEN_REV_INCL_BILL_EVENT_FLAG%TYPE,
           P_INC_OPEN_COMMIT_FLAG           IN            PA_PROJ_FP_OPTIONS.GEN_COST_INCL_OPEN_COMM_FLAG%TYPE,
           P_ACTUALS_THRU_DATE              IN            PA_PERIODS_ALL.END_DATE%TYPE DEFAULT NULL,
           P_CI_ID_TAB                      IN            PA_PLSQL_DATATYPES.IdTabTyp,
           PX_GEN_RES_ASG_ID_TAB            IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
           PX_DELETED_RES_ASG_ID_TAB        IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
           P_COMMIT_FLAG                    IN            VARCHAR2,
           P_INIT_MSG_FLAG                  IN            VARCHAR2,
           X_RETURN_STATUS                  OUT  NOCOPY   VARCHAR2,
           X_MSG_COUNT                      OUT  NOCOPY   NUMBER,
           X_MSG_DATA	                    OUT  NOCOPY   VARCHAR2);

PROCEDURE GEN_WP_REV_BDGT_AMT_WRP
	  (P_PROJECT_ID                     IN            PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID 	            IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_PLAN_CLASS_CODE                IN            PA_FIN_PLAN_TYPES_B.PLAN_CLASS_CODE%TYPE
                                                              default 'Budget',
           P_GEN_SRC_CODE                   IN            PA_PROJ_FP_OPTIONS.GEN_ALL_SRC_CODE%TYPE
                                                              default 'WORKPLAN_RESOURCES',
           P_COST_PLAN_TYPE_ID              IN            PA_PROJ_FP_OPTIONS.GEN_SRC_COST_PLAN_TYPE_ID%TYPE,
	   P_COST_VERSION_ID                IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE
                                                              default null,
 	   P_RETAIN_MANUAL_FLAG             IN            VARCHAR2 default null,
 	   P_CALLED_MODE                    IN            VARCHAR2 default 'SELF_SERVICE',
	   P_INC_CHG_DOC_FLAG               IN            VARCHAR2 default 'N',
	   P_INC_BILL_EVENT_FLAG            IN            VARCHAR2 default 'N',
           P_INC_OPEN_COMMIT_FLAG           IN            VARCHAR2 default 'N',
           P_CI_ID_TAB                      IN            PA_PLSQL_DATATYPES.IdTabTyp
                                                              default PA_PLSQL_DATATYPES.EmptyIdTab,
           P_INIT_MSG_FLAG                  IN            VARCHAR2 default 'Y',
           P_COMMIT_FLAG                    IN            VARCHAR2 default 'N',
           PX_DELETED_RES_ASG_ID_TAB        IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
           PX_GEN_RES_ASG_ID_TAB            IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
           X_RETURN_STATUS                  OUT  NOCOPY   VARCHAR2,
           X_MSG_COUNT                      OUT  NOCOPY   NUMBER,
           X_MSG_DATA	                    OUT  NOCOPY   VARCHAR2);

END PA_FP_GEN_BUDGET_AMT_PUB;

 

/
