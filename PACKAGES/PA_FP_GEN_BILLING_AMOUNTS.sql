--------------------------------------------------------
--  DDL for Package PA_FP_GEN_BILLING_AMOUNTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_GEN_BILLING_AMOUNTS" AUTHID CURRENT_USER as
/* $Header: PAFPGABS.pls 120.1 2005/07/26 18:05:18 appldev noship $ */

FUNCTION GET_EVENT_DATE(P_EVENT_DATE       IN    DATE,
                        P_ETC_START_DATE   IN    DATE,
                        P_PLAN_CLASS_CODE  IN    VARCHAR2)
RETURN DATE;

PROCEDURE CONVERT_TXN_AMT_TO_PC_PFC
          (P_PROJECT_ID                 IN  NUMBER,
	   P_BUDGET_VERSION_ID		IN  NUMBER,
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
           X_MSG_DATA	                    OUT NOCOPY    VARCHAR2);

PROCEDURE GEN_BILLING_AMOUNTS
          (P_PROJECT_ID                     IN              PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID 	            IN              PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC                    IN              PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_ETC_START_DATE      IN
              PA_BUDGET_VERSIONS.ETC_START_DATE%TYPE DEFAULT NULL,
           PX_GEN_RES_ASG_ID_TAB            IN OUT NOCOPY   PA_PLSQL_DATATYPES.IdTabTyp,
           PX_DELETED_RES_ASG_ID_TAB        IN OUT NOCOPY   PA_PLSQL_DATATYPES.IdTabTyp,
           X_RETURN_STATUS                  OUT   NOCOPY    VARCHAR2,
           X_MSG_COUNT                      OUT   NOCOPY    NUMBER,
           X_MSG_DATA	                    OUT   NOCOPY    VARCHAR2);

PROCEDURE GET_BILLING_EVENT_AMT_IN_PFC
	  (P_PROJECT_ID      		IN pa_projects_all.project_id%type,
	   P_BUDGET_VERSION_ID          IN pa_budget_versions.budget_version_id%type,
           P_FP_COLS_REC                IN PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
   	   P_PROJFUNC_CURRENCY_CODE     IN pa_projects_all.projfunc_currency_code%type,
           P_PROJECT_CURRENCY_CODE      IN pa_projects_all.project_currency_code%type,
           X_PROJFUNC_REVENUE       	OUT NOCOPY    NUMBER,
           X_PROJECT_REVENUE       	OUT NOCOPY    NUMBER,
           X_RETURN_STATUS         	OUT NOCOPY    VARCHAR2,
           X_MSG_COUNT              	OUT NOCOPY    NUMBER,
           X_MSG_DATA	             	OUT NOCOPY    VARCHAR2);

-- Added 3/15/05
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
           X_MSG_DATA                       OUT   NOCOPY    VARCHAR2);

-- Added 3/15/05
PROCEDURE UPD_TMP4_TXN_RA_ID_AND_ML
          (P_PROJECT_ID             IN              PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID      IN              PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC            IN              PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
	   P_GEN_SRC_CODE           IN              PA_PROJ_FP_OPTIONS.GEN_ALL_SRC_CODE%TYPE,
           P_WP_STRUCTURE_VER_ID    IN              PA_BUDGET_VERSIONS.PROJECT_STRUCTURE_VERSION_ID%TYPE DEFAULT NULL,
           X_RETURN_STATUS          OUT   NOCOPY    VARCHAR2,
           X_MSG_COUNT              OUT   NOCOPY    NUMBER,
           X_MSG_DATA               OUT   NOCOPY    VARCHAR2);

 END PA_FP_GEN_BILLING_AMOUNTS;

 

/
