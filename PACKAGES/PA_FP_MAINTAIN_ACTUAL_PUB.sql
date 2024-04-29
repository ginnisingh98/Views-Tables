--------------------------------------------------------
--  DDL for Package PA_FP_MAINTAIN_ACTUAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_MAINTAIN_ACTUAL_PUB" AUTHID CURRENT_USER as
/* $Header: PAFPMAPS.pls 120.0 2005/05/29 17:17:06 appldev noship $ */

TYPE l_amt_dtls_rec_typ IS RECORD
(       PERIOD_NAME                        PA_BUDGET_LINES.PERIOD_NAME%TYPE := null,
        START_DATE                         PA_BUDGET_LINES.START_DATE%TYPE := null,
        END_DATE                           PA_BUDGET_LINES.END_DATE%TYPE := null,
        TXN_RAW_COST                       PA_BUDGET_LINES.TXN_RAW_COST%TYPE := 0,
        TXN_BURDENED_COST                  PA_BUDGET_LINES.TXN_BURDENED_COST%TYPE := 0,
        TXN_REVENUE                        PA_BUDGET_LINES.TXN_REVENUE%TYPE := 0,
        PROJECT_RAW_COST                   PA_BUDGET_LINES.PROJECT_RAW_COST%TYPE := 0,
        PROJECT_BURDENED_COST              PA_BUDGET_LINES.PROJECT_BURDENED_COST%TYPE := 0,
        PROJECT_REVENUE                    PA_BUDGET_LINES.PROJECT_REVENUE%TYPE := 0,
        PROJECT_FUNC_RAW_COST              PA_BUDGET_LINES.RAW_COST%TYPE  := 0,
        PROJECT_FUNC_BURDENED_COST         PA_BUDGET_LINES.BURDENED_COST%TYPE := 0,
        PROJECT_FUNC_REVENUE               PA_BUDGET_LINES.REVENUE%TYPE := 0,
        QUANTITY                           PA_BUDGET_LINES.QUANTITY%TYPE := 0);

/* PLSQL table types */

TYPE l_amt_dtls_tbl_typ is TABLE OF
     l_amt_dtls_rec_typ INDEX BY BINARY_INTEGER;


PROCEDURE MAINTAIN_ACTUAL_AMT_WRP
     (P_PROJECT_ID_TAB         IN          SYSTEM.PA_NUM_TBL_TYPE,
      P_WP_STR_VERSION_ID_TAB  IN          SYSTEM.PA_NUM_TBL_TYPE,
      P_ACTUALS_THRU_DATE      IN          SYSTEM.PA_DATE_TBL_TYPE,
      P_CALLING_CONTEXT        IN          VARCHAR2,
      P_COMMIT_FLAG            IN          VARCHAR2 DEFAULT 'N',
      P_INIT_MSG_FLAG          IN          VARCHAR2 DEFAULT 'Y',
      P_CALLING_MODE           IN          VARCHAR2 DEFAULT 'SELF_SERVICE',
      P_EXTRACTION_TYPE        IN          VARCHAR2 DEFAULT 'FULL',
      X_RETURN_STATUS          OUT NOCOPY  VARCHAR2,
      X_MSG_COUNT              OUT NOCOPY  NUMBER,
      X_MSG_DATA               OUT NOCOPY  VARCHAR2);

PROCEDURE UPD_REPORTING_LINES_WRP
               (p_calling_module           IN         Varchar2
               ,p_activity_code            IN         Varchar2
               ,p_budget_version_id        IN         Number
               ,p_resource_assignment_id   IN         Number
               ,p_budget_line_id_tab       IN         pa_plsql_datatypes.IdTabTyp
               ,p_calling_mode             IN         varchar2 default 'SELF_SERVICE'
               ,x_msg_data                 OUT NOCOPY Varchar2
               ,x_msg_count                OUT NOCOPY Number
               ,x_return_status            OUT NOCOPY Varchar2);

PROCEDURE MAINTAIN_ACTUAL_AMT_RA
     (P_PROJECT_ID              IN          PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
      P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
      P_RESOURCE_ASSIGNMENT_ID  IN          PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE,
      P_TXN_CURRENCY_CODE       IN          PA_BUDGET_LINES.TXN_CURRENCY_CODE%TYPE,
      P_AMT_DTLS_REC_TAB        IN          PA_FP_MAINTAIN_ACTUAL_PUB.l_amt_dtls_tbl_typ,
      P_CALLING_CONTEXT         IN          VARCHAR2,
      P_TXN_AMT_TYPE_CODE       IN          VARCHAR2 DEFAULT 'ACTUAL_TXN',
      P_CALLING_MODE            IN          VARCHAR2 DEFAULT 'SELF_SERVICE',
      P_EXTRACTION_TYPE         IN          VARCHAR2 DEFAULT 'FULL',
      P_OPEN_PD_PLAN_AMT_FLAG   IN          VARCHAR2 DEFAULT 'N',
      P_OPEN_PD_END_DATE        IN          DATE     DEFAULT NULL,
      X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
      X_MSG_COUNT               OUT NOCOPY  NUMBER,
      X_MSG_DATA                OUT NOCOPY  VARCHAR2);

PROCEDURE SYNC_UP_PLANNING_DATES
     (P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
      P_CALLING_CONTEXT         IN          VARCHAR2 DEFAULT 'SYNC_VERSION_LEVEL',
      X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
      X_MSG_COUNT               OUT NOCOPY  NUMBER,
      X_MSG_DATA                OUT NOCOPY  VARCHAR2);

PROCEDURE BLK_UPD_REPORTING_LINES_WRP
     (P_BUDGET_VERSION_ID      IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
      P_ENTIRE_VERSION_FLAG    IN          VARCHAR2 DEFAULT 'N',
      P_RES_ASG_ID_TAB         IN          PA_PLSQL_DATATYPES.IDTABTYP,
      P_ACTIVITY_CODE          IN          VARCHAR2 DEFAULT 'UPDATE',
      X_RETURN_STATUS          OUT NOCOPY  VARCHAR2,
      X_MSG_COUNT              OUT NOCOPY  NUMBER,
      X_MSG_DATA               OUT NOCOPY  VARCHAR2);

PROCEDURE SYNC_UP_PLANNING_DATES_NONE_TP
     (P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
      P_FP_COLS_REC             IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
      X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
      X_MSG_COUNT               OUT NOCOPY  NUMBER,
      X_MSG_DATA                OUT NOCOPY  VARCHAR2);

END PA_FP_MAINTAIN_ACTUAL_PUB;

 

/
