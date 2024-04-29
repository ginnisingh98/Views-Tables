--------------------------------------------------------
--  DDL for Package PA_FP_GEN_FCST_AMT_PUB1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_GEN_FCST_AMT_PUB1" AUTHID CURRENT_USER as
/* $Header: PAFPFG2S.pls 120.1 2007/02/06 09:51:07 dthakker ship $ */

PROCEDURE POPULATE_GEN_RATE
          (P_SOURCE_RES_ASG_ID       IN            PA_BUDGET_LINES.RESOURCE_ASSIGNMENT_ID%TYPE,
           P_TARGET_RES_ASG_ID       IN            PA_BUDGET_LINES.RESOURCE_ASSIGNMENT_ID%TYPE,
           P_TXN_CURRENCY_CODE       IN            PA_BUDGET_LINES.TXN_CURRENCY_CODE%TYPE,
           X_RETURN_STATUS           OUT  NOCOPY   VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY   NUMBER,
           X_MSG_DATA                OUT  NOCOPY   VARCHAR2);

PROCEDURE CHK_UPD_RATE_BASED_FLAG
          (P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC             IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           X_RETURN_STATUS           OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY NUMBER,
           X_MSG_DATA                OUT  NOCOPY VARCHAR2);

PROCEDURE CALL_SUMM_POP_TMPS
          (P_PROJECT_ID              IN          PA_PROJECTS_ALL.PROJECT_ID%TYPE,
           P_CALENDAR_TYPE           IN          VARCHAR2,
           P_RECORD_TYPE             IN          VARCHAR2,
           P_RESOURCE_LIST_ID        IN          NUMBER,
           P_STRUCT_VER_ID           IN          NUMBER,
           P_ACTUALS_THRU_DATE       IN          PA_PERIODS_ALL.END_DATE%TYPE,
           P_DATA_TYPE_CODE          IN          VARCHAR2,
           X_RETURN_STATUS           OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY NUMBER,
           X_MSG_DATA                OUT  NOCOPY VARCHAR2);

PROCEDURE GEN_AVERAGE_OF_ACTUALS_WRP
          (P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_TASK_ID                 IN          PA_RESOURCE_ASSIGNMENTS.TASK_ID%TYPE,
           P_ACTUALS_THRU_DATE       IN          DATE,
           P_FP_COLS_REC             IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_ACTUALS_FROM_PERIOD     IN          PA_PERIODS_ALL.PERIOD_NAME%TYPE,
           P_ACTUALS_TO_PERIOD       IN          PA_PERIODS_ALL.PERIOD_NAME%TYPE,
           P_ETC_FROM_PERIOD         IN          PA_PERIODS_ALL.PERIOD_NAME%TYPE,
           P_ETC_TO_PERIOD           IN          PA_PERIODS_ALL.PERIOD_NAME%TYPE,
           X_RETURN_STATUS           OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY NUMBER,
           X_MSG_DATA                OUT  NOCOPY VARCHAR2);

PROCEDURE GET_ETC_REMAIN_BDGT_AMTS
          (P_ETC_SOURCE_CODE         IN          VARCHAR2,
           P_RESOURCE_ASSIGNMENT_ID  IN          NUMBER,
           P_TASK_ID                 IN          NUMBER,
           P_RESOURCE_LIST_MEMBER_ID IN          NUMBER,
           P_ACTUALS_THRU_DATE       IN          PA_PERIODS_ALL.END_DATE%TYPE,
           P_FP_COLS_REC             IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_WP_STRUCTURE_VERSION_ID IN          PA_PROJ_ELEM_VER_STRUCTURE.ELEMENT_VERSION_ID%TYPE,
           X_RETURN_STATUS           OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY NUMBER,
           X_MSG_DATA                OUT  NOCOPY VARCHAR2);

PROCEDURE GET_ETC_BDGT_COMPLETE_AMTS
          (P_ETC_SOURCE_CODE         IN          VARCHAR2,
           P_ETC_SRC_BUDGET_VER_ID   IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_RESOURCE_ASSIGNMENT_ID  IN          NUMBER,
           P_TASK_ID                 IN          NUMBER,
           P_RESOURCE_LIST_MEMBER_ID IN          NUMBER,
           P_ACTUALS_THRU_DATE       IN          PA_PERIODS_ALL.END_DATE%TYPE,
           P_FP_COLS_REC             IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_WP_STRUCTURE_VERSION_ID IN          PA_PROJ_ELEM_VER_STRUCTURE.ELEMENT_VERSION_ID%TYPE,
           X_RETURN_STATUS           OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY NUMBER,
           X_MSG_DATA                OUT  NOCOPY VARCHAR2);

PROCEDURE GET_ETC_EARNED_VALUE_AMTS
          (P_ETC_SOURCE_CODE         IN          VARCHAR2,
           P_RESOURCE_ASSIGNMENT_ID  IN          NUMBER,
           P_TASK_ID                 IN          NUMBER,
           P_RESOURCE_LIST_MEMBER_ID IN          NUMBER,
           P_ACTUALS_THRU_DATE       IN          PA_PERIODS_ALL.END_DATE%TYPE,
           P_FP_COLS_REC             IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_WP_STRUCTURE_VERSION_ID IN          PA_PROJ_ELEM_VER_STRUCTURE.ELEMENT_VERSION_ID%TYPE,
           X_RETURN_STATUS           OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY NUMBER,
           X_MSG_DATA                OUT  NOCOPY VARCHAR2);

PROCEDURE GET_ETC_WORK_QTY_AMTS
          (P_PROJECT_ID              IN          PA_PROJECTS_ALL.PROJECT_ID%TYPE,
           P_PROJ_CURRENCY_CODE      IN          VARCHAR2,
           P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_TASK_ID                 IN          NUMBER,
           P_TARGET_RES_LIST_ID      IN          NUMBER,
           P_ACTUALS_THRU_DATE       IN          PA_PERIODS_ALL.END_DATE%TYPE,
           P_FP_COLS_REC             IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_WP_STRUCTURE_VERSION_ID IN          PA_PROJ_ELEM_VER_STRUCTURE.ELEMENT_VERSION_ID%TYPE,
           X_RETURN_STATUS           OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY NUMBER,
           X_MSG_DATA                OUT  NOCOPY VARCHAR2 );

PROCEDURE NONE_ETC_SRC
          (P_PROJECT_ID              IN          PA_PROJECTS_ALL.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_RESOURCE_LIST_ID        IN          NUMBER,
           P_TASK_ID                 IN          NUMBER,
           X_RETURN_STATUS           OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY NUMBER,
           X_MSG_DATA                OUT  NOCOPY VARCHAR2 );

PROCEDURE MAINTAIN_BUDGET_VERSION
          (P_PROJECT_ID              IN          PA_PROJECTS_ALL.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_ETC_START_DATE          IN          DATE  DEFAULT NULL,
	   P_CALL_MAINTAIN_DATA_API  IN          VARCHAR2 DEFAULT 'Y',
           X_RETURN_STATUS           OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY NUMBER,
           X_MSG_DATA                OUT  NOCOPY VARCHAR2 );


FUNCTION GET_ETC_WP_DTLS
          (P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_CONTEXT                 IN          VARCHAR2)
          RETURN VARCHAR2;

FUNCTION GET_ETC_FP_PTYPE_DTLS
          (P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_CONTEXT                 IN          VARCHAR2)
          RETURN VARCHAR2;

FUNCTION GET_ETC_FP_PVERSION_DTLS
          (P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_CONTEXT                 IN          VARCHAR2)
          RETURN VARCHAR2;

PROCEDURE GET_WP_ACTUALS_FOR_RA
          (P_FP_COLS_SRC_REC         IN PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_FP_COLS_TGT_REC         IN PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_SRC_RES_ASG_ID          IN PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE,
           P_TASK_ID                 IN PA_TASKS.TASK_ID%TYPE,
           P_RES_LIST_MEM_ID         IN PA_RESOURCE_LIST_MEMBERS.RESOURCE_LIST_MEMBER_ID%TYPE,
           P_ACTUALS_THRU_DATE       IN DATE,
           X_ACT_QUANTITY            OUT NOCOPY NUMBER,
           X_ACT_TXN_CURRENCY_CODE   OUT NOCOPY PA_BUDGET_LINES.TXN_CURRENCY_CODE%TYPE,
           X_ACT_TXN_RAW_COST        OUT NOCOPY NUMBER,
           X_ACT_TXN_BRDN_COST       OUT NOCOPY NUMBER,
           X_ACT_PC_RAW_COST         OUT NOCOPY NUMBER,
           X_ACT_PC_BRDN_COST        OUT NOCOPY NUMBER,
           X_ACT_PFC_RAW_COST        OUT NOCOPY NUMBER,
           X_ACT_PFC_BRDN_COST       OUT NOCOPY NUMBER,
           X_RETURN_STATUS           OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY NUMBER,
           X_MSG_DATA                OUT  NOCOPY VARCHAR2 );

-- Start Bug 5726785
PROCEDURE call_clnt_extn_and_update_bl
 	     (   p_project_id                IN  pa_projects_all.project_id%TYPE
 	         ,p_budget_version_id        IN  pa_budget_versions.budget_version_id%TYPE
 	         ,x_call_maintain_data_api  OUT  NOCOPY VARCHAR2
 	         ,x_return_status            OUT  NOCOPY VARCHAR2
 	         ,x_msg_count                OUT  NOCOPY NUMBER
 	         ,x_msg_data                 OUT  NOCOPY VARCHAR2 );
-- End Bug 5726785

END PA_FP_GEN_FCST_AMT_PUB1;

/
