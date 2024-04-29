--------------------------------------------------------
--  DDL for Package PA_FP_GEN_FCST_AMT_PUB3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_GEN_FCST_AMT_PUB3" AUTHID CURRENT_USER as
/* $Header: PAFPFG3S.pls 120.1.12010000.2 2009/05/25 14:46:14 gboomina ship $ */

/**Valid values for param:P_ETC_SOURCE_CODE
  * --ETC_WP
  * --ETC_FP
  * --TARGET_FP
  **/
PROCEDURE GET_ETC_REMAIN_BDGT_AMTS
	  (P_SRC_RES_ASG_ID		IN PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE,
	   P_TGT_RES_ASG_ID		IN PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE,
	   P_FP_COLS_SRC_REC		IN PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
	   P_FP_COLS_TGT_REC		IN PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
	   P_TASK_ID			IN PA_TASKS.TASK_ID%TYPE,
	   P_RESOURCE_LIST_MEMBER_ID	IN PA_RESOURCE_LIST_MEMBERS.RESOURCE_LIST_MEMBER_ID%TYPE,
	   P_ETC_SOURCE_CODE		IN PA_TASKS.GEN_ETC_SOURCE_CODE%TYPE,
	   P_WP_STRUCTURE_VERSION_ID    IN PA_PROJ_ELEM_VER_STRUCTURE.ELEMENT_VERSION_ID%TYPE,
	   P_ACTUALS_THRU_DATE 		IN PA_PERIODS_ALL.END_DATE%TYPE,
	   P_PLANNING_OPTIONS_FLAG	IN VARCHAR2,
	   X_RETURN_STATUS		OUT  NOCOPY VARCHAR2,
	   X_MSG_COUNT			OUT  NOCOPY NUMBER,
	   X_MSG_DATA	           	OUT  NOCOPY VARCHAR2);

PROCEDURE CHECK_SINGLE_CURRENCY
	  (P_TGT_RES_ASG_ID		IN PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE,
	   X_SINGLE_CURRENCY_FLAG	OUT  NOCOPY VARCHAR2,
	   X_RETURN_STATUS		OUT  NOCOPY VARCHAR2,
	   X_MSG_COUNT			OUT  NOCOPY NUMBER,
	   X_MSG_DATA	           	OUT  NOCOPY VARCHAR2);

/* Bug 4369741: Replaced single planning options flag parameter with
 * 2 separate parameters - 1 for Workplan and 1 for Financial Plan. */

PROCEDURE GET_ETC_COMMITMENT_AMTS
	  (P_FP_COLS_TGT_REC		IN PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
	   P_WP_PLANNING_OPTIONS_FLAG	IN VARCHAR2, /* Added for Bug 4369741 */
	   P_FP_PLANNING_OPTIONS_FLAG	IN VARCHAR2, /* Added for Bug 4369741 */
	   X_RETURN_STATUS		OUT  NOCOPY VARCHAR2,
	   X_MSG_COUNT			OUT  NOCOPY NUMBER,
	   X_MSG_DATA	           	OUT  NOCOPY VARCHAR2);

PROCEDURE GET_ETC_REMAIN_BDGT_AMTS_BLK(
            P_SRC_RES_ASG_ID_TAB        IN  PA_PLSQL_DATATYPES.IdTabTyp,
            P_TGT_RES_ASG_ID_TAB        IN  PA_PLSQL_DATATYPES.IdTabTyp,
            P_FP_COLS_SRC_REC_FP        IN  PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
            P_FP_COLS_SRC_REC_WP        IN  PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
            P_FP_COLS_TGT_REC           IN  PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
            P_TASK_ID_TAB               IN  PA_PLSQL_DATATYPES.IdTabTyp,
            P_RES_LIST_MEMBER_ID_TAB    IN  PA_PLSQL_DATATYPES.IdTabTyp,
            P_ETC_SOURCE_CODE_TAB       IN  PA_PLSQL_DATATYPES.Char30TabTyp,
            P_WP_STRUCTURE_VERSION_ID   IN  PA_PROJ_ELEM_VER_STRUCTURE.ELEMENT_VERSION_ID%TYPE,
            P_ACTUALS_THRU_DATE         IN  PA_PERIODS_ALL.END_DATE%TYPE,
            P_PLANNING_OPTIONS_FLAG     IN  VARCHAR2,
            X_RETURN_STATUS             OUT NOCOPY VARCHAR2,
            X_MSG_COUNT                 OUT NOCOPY NUMBER,
            X_MSG_DATA                  OUT NOCOPY VARCHAR2);

-- gboomina added for Bug 8318932 - Start
-- AAI Enhancement
   PROCEDURE GET_ETC_FROM_SRC_BDGT
             (P_FP_COLS_SRC_FP_REC                                                                IN PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
              P_FP_COLS_SRC_WP_REC                                                                IN PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
              P_FP_COLS_TGT_REC                                                                        IN PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
              P_ACTUALS_THRU_DATE                                                                 IN PA_PERIODS_ALL.END_DATE%TYPE,
              X_RETURN_STATUS                                                                                OUT  NOCOPY VARCHAR2,
              X_MSG_COUNT                                                                                                OUT  NOCOPY NUMBER,
              X_MSG_DATA                                                                           OUT  NOCOPY VARCHAR2);

   PROCEDURE PROCESS_PA_GL_DATES
             (
              p_start_date                IN         DATE,
              p_end_date                  IN         DATE,
              p_org_id                    IN         NUMBER,
              X_GL_GREATER_FLAG           OUT NOCOPY VARCHAR2,
              X_RETURN_STATUS             OUT NOCOPY VARCHAR2,
              X_MSG_COUNT                 OUT NOCOPY NUMBER,
              X_MSG_DATA                  OUT NOCOPY VARCHAR2
              );
-- gboomina added for Bug 8318932 - End

END PA_FP_GEN_FCST_AMT_PUB3;

/
