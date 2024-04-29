--------------------------------------------------------
--  DDL for Package PA_FP_GEN_AMOUNT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_GEN_AMOUNT_UTILS" AUTHID CURRENT_USER as
/* $Header: PAFPGAUS.pls 120.7 2007/02/06 09:56:53 dthakker ship $ */
TYPE FP_COLS IS RECORD (
                X_PROJECT_ID                          PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
                X_BUDGET_VERSION_ID                   PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
                X_PROJ_FP_OPTIONS_ID                  PA_PROJ_FP_OPTIONS.PROJ_FP_OPTIONS_ID%TYPE,
                X_FIN_PLAN_TYPE_ID                    PA_PROJ_FP_OPTIONS.FIN_PLAN_TYPE_ID%TYPE,
                X_AMOUNT_SET_ID                       PA_PROJ_FP_OPTIONS.COST_AMOUNT_SET_ID%TYPE,
                X_FIN_PLAN_LEVEL_CODE                 PA_PROJ_FP_OPTIONS.COST_FIN_PLAN_LEVEL_CODE%TYPE,
                X_TIME_PHASED_CODE                    PA_PROJ_FP_OPTIONS.COST_TIME_PHASED_CODE%TYPE,
                X_RESOURCE_LIST_ID                    PA_PROJ_FP_OPTIONS.COST_RESOURCE_LIST_ID%TYPE,
                X_RES_PLANNING_LEVEL                  PA_PROJ_FP_OPTIONS.COST_RES_PLANNING_LEVEL%TYPE,
                X_RBS_VERSION_ID                      PA_PROJ_FP_OPTIONS.RBS_VERSION_ID%TYPE,
             /* X_EMP_RATE_SCH_ID                     PA_PROJ_FP_OPTIONS.COST_EMP_RATE_SCH_ID%TYPE, */
                X_COST_EMP_RATE_SCH_ID                PA_PROJ_FP_OPTIONS.COST_EMP_RATE_SCH_ID%TYPE,
                X_REV_EMP_RATE_SCH_ID                 PA_PROJ_FP_OPTIONS.REV_EMP_RATE_SCH_ID%TYPE,
             /* X_JOB_RATE_SCH_ID                     PA_PROJ_FP_OPTIONS.COST_JOB_RATE_SCH_ID%TYPE,*/
                X_COST_JOB_RATE_SCH_ID                PA_PROJ_FP_OPTIONS.COST_JOB_RATE_SCH_ID%TYPE,
                X_REV_JOB_RATE_SCH_ID                 PA_PROJ_FP_OPTIONS.REV_JOB_RATE_SCH_ID%TYPE,
             /* X_NON_LABOR_RES_RATE_SCH_ID           PA_PROJ_FP_OPTIONS.COST_NON_LABOR_RES_RATE_SCH_ID%TYPE,*/
                X_CNON_LABOR_RES_RATE_SCH_ID          PA_PROJ_FP_OPTIONS.COST_NON_LABOR_RES_RATE_SCH_ID%TYPE,
                X_RNON_LABOR_RES_RATE_SCH_ID          PA_PROJ_FP_OPTIONS.REV_NON_LABOR_RES_RATE_SCH_ID%TYPE,
             /* X_RES_CLASS_RATE_SCH_ID               PA_PROJ_FP_OPTIONS.COST_RES_CLASS_RATE_SCH_ID%TYPE,*/
                X_COST_RES_CLASS_RATE_SCH_ID          PA_PROJ_FP_OPTIONS.COST_RES_CLASS_RATE_SCH_ID%TYPE,
                X_REV_RES_CLASS_RATE_SCH_ID           PA_PROJ_FP_OPTIONS.REV_RES_CLASS_RATE_SCH_ID%TYPE,
                X_BURDEN_RATE_SCH_ID                  PA_PROJ_FP_OPTIONS.COST_BURDEN_RATE_SCH_ID%TYPE,
                X_CURRENT_PLANNING_PERIOD             PA_PROJ_FP_OPTIONS.COST_CURRENT_PLANNING_PERIOD%TYPE,
                X_PERIOD_MASK_ID                      PA_PROJ_FP_OPTIONS.COST_PERIOD_MASK_ID%TYPE,
                X_GEN_SRC_PLAN_TYPE_ID                PA_PROJ_FP_OPTIONS.GEN_SRC_COST_PLAN_TYPE_ID%TYPE,
                X_GEN_SRC_PLAN_VERSION_ID             PA_PROJ_FP_OPTIONS.GEN_SRC_COST_PLAN_VERSION_ID%TYPE,
                X_GEN_SRC_PLAN_VER_CODE               PA_PROJ_FP_OPTIONS.GEN_SRC_COST_PLAN_VER_CODE%TYPE,
                X_GEN_SRC_CODE                        PA_PROJ_FP_OPTIONS.GEN_COST_SRC_CODE%TYPE,
                X_GEN_ETC_SRC_CODE                    PA_PROJ_FP_OPTIONS.GEN_COST_ETC_SRC_CODE%TYPE,
                X_GEN_INCL_CHANGE_DOC_FLAG            PA_PROJ_FP_OPTIONS.GEN_COST_INCL_CHANGE_DOC_FLAG%TYPE,
                X_GEN_INCL_OPEN_COMM_FLAG             PA_PROJ_FP_OPTIONS.GEN_COST_INCL_OPEN_COMM_FLAG%TYPE,
                X_GEN_INCL_BILL_EVENT_FLAG            VARCHAR2(1),
                X_GEN_RET_MANUAL_LINE_FLAG            PA_PROJ_FP_OPTIONS.GEN_COST_RET_MANUAL_LINE_FLAG%TYPE,
                X_GEN_ACTUAL_AMTS_THRU_CODE           PA_PROJ_FP_OPTIONS.GEN_COST_ACTUAL_AMTS_THRU_CODE%TYPE,
                X_GEN_INCL_UNSPENT_AMT_FLAG           PA_PROJ_FP_OPTIONS.GEN_COST_INCL_UNSPENT_AMT_FLAG%TYPE,
                X_PLAN_IN_MULTI_CURR_FLAG             PA_PROJ_FP_OPTIONS.PLAN_IN_MULTI_CURR_FLAG%TYPE,
                X_ORG_ID                              PA_PROJECTS_ALL.ORG_ID%TYPE,
                X_PROJECT_CURRENCY_CODE               PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE,
                X_PROJFUNC_CURRENCY_CODE              PA_PROJECTS_ALL.PROJFUNC_CURRENCY_CODE%TYPE,
                X_SET_OF_BOOKS_ID                     PA_IMPLEMENTATIONS_ALL.SET_OF_BOOKS_ID%TYPE,
                X_RAW_COST_FLAG                       PA_FIN_PLAN_AMOUNT_SETS.RAW_COST_FLAG%TYPE,
                X_BURDENED_FLAG                       PA_FIN_PLAN_AMOUNT_SETS.BURDENED_COST_FLAG%TYPE,
                X_REVENUE_FLAG                        PA_FIN_PLAN_AMOUNT_SETS.REVENUE_FLAG%TYPE,
                X_COST_QUANTITY_FLAG                  PA_FIN_PLAN_AMOUNT_SETS.COST_QTY_FLAG%TYPE,
                X_REV_QUANTITY_FLAG                   PA_FIN_PLAN_AMOUNT_SETS.REVENUE_QTY_FLAG%TYPE,
                X_ALL_QUANTITY_FLAG                   PA_FIN_PLAN_AMOUNT_SETS.ALL_QTY_FLAG%TYPE,
                X_BILL_RATE_FLAG                      PA_FIN_PLAN_AMOUNT_SETS.BILL_RATE_FLAG%TYPE,
                X_COST_RATE_FLAG                      PA_FIN_PLAN_AMOUNT_SETS.COST_RATE_FLAG%TYPE,
                X_BURDEN_RATE_FLAG                    PA_FIN_PLAN_AMOUNT_SETS.BURDEN_RATE_FLAG%TYPE,
                X_PROJECT_STRUCTURE_VERSION_ID        PA_BUDGET_VERSIONS.PROJECT_STRUCTURE_VERSION_ID%TYPE,
                X_PLAN_CLASS_CODE                     PA_FIN_PLAN_TYPES_B.PLAN_CLASS_CODE%TYPE,
                X_VERSION_TYPE                        PA_BUDGET_VERSIONS.VERSION_TYPE%TYPE,
                X_PROJECT_VALUE                       PA_PROJECTS_ALL.PROJECT_VALUE%TYPE,
                X_TRACK_WORKPLAN_COSTS_FLAG           PA_PROJ_FP_OPTIONS.TRACK_WORKPLAN_COSTS_FLAG%TYPE,
		X_REVENUE_DERIVATION_METHOD      VARCHAR2(1), -- bug 5152892
                X_GEN_SRC_WP_VERSION_ID               NUMBER(15),
                X_GEN_SRC_WP_VER_CODE                 VARCHAR2(30));

PROCEDURE GET_PLAN_VERSION_DTLS
          (P_PROJECT_ID 	            IN            PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE DEFAULT NULL,
           P_BUDGET_VERSION_ID 	            IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           X_FP_COLS_REC                    OUT  NOCOPY   FP_COLS,
           X_RETURN_STATUS                  OUT  NOCOPY   VARCHAR2,
           X_MSG_COUNT                      OUT  NOCOPY   NUMBER,
           X_MSG_DATA	                    OUT  NOCOPY   VARCHAR2);

PROCEDURE CHK_CMT_TXN_CURRENCY
          (P_PROJECT_ID                     IN            NUMBER,
           P_PROJ_CURRENCY_CODE             IN            VARCHAR2,
	   X_MSG_COUNT                      OUT NOCOPY    NUMBER,
           X_MSG_DATA                       OUT NOCOPY    VARCHAR2,
	   X_RETURN_STATUS                  OUT NOCOPY    VARCHAR2);

PROCEDURE Get_Curr_Original_Version_Info(
          p_project_id              IN   pa_projects_all.project_id%TYPE,
          p_fin_plan_type_id        IN   pa_budget_versions.fin_plan_type_id%TYPE,
          p_version_type            IN   pa_budget_versions.version_type%TYPE,
          p_status_code             IN   VARCHAR2    DEFAULT 'CURRENT_ORIGINAL',
          x_fp_options_id           OUT  NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE,
          x_fin_plan_version_id     OUT  NOCOPY pa_proj_fp_options.fin_plan_version_id%TYPE,
          x_return_status           OUT  NOCOPY VARCHAR2,
          x_msg_count               OUT  NOCOPY NUMBER,
          x_msg_data                OUT  NOCOPY VARCHAR2);

PROCEDURE VALIDATE_PLAN_VERSION
          (P_PROJECT_ID                     IN            PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_SRC_BDGT_VERSION_ID            IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_TRGT_BDGT_VERSION_ID           IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
	   X_MSG_COUNT                      OUT NOCOPY    NUMBER,
           X_MSG_DATA                       OUT NOCOPY    VARCHAR2,
	   X_RETURN_STATUS                  OUT NOCOPY    VARCHAR2);

TYPE RESOURCE_ASN_REC IS RECORD (
    x_project_id                       pa_resource_assignments.project_id%TYPE,
    x_rate_task_id                     pa_resource_assignments.task_id%TYPE,
    x_unit_of_measure                  pa_resource_assignments.unit_of_measure%TYPE,
    x_resource_class_code              pa_resource_assignments.resource_class_code%TYPE,
    x_organization_id                  pa_resource_assignments.organization_id%TYPE,
    x_job_id                           pa_resource_assignments.job_id%TYPE,
    x_person_id                        pa_resource_assignments.person_id%TYPE,
    x_expenditure_type                 pa_resource_assignments.expenditure_type%TYPE,
    x_non_labor_resource               pa_resource_assignments.non_labor_resource%TYPE,
    x_bom_resource_id                  pa_resource_assignments.bom_resource_id%TYPE,
    x_inventory_item_id                pa_resource_assignments.inventory_item_id%TYPE,
    x_item_category_id                 pa_resource_assignments.item_category_id%TYPE,
    x_mfc_cost_type_id                 pa_resource_assignments.mfc_cost_type_id%TYPE,
    x_rate_based_flag                  pa_resource_assignments.rate_based_flag%TYPE,
    x_rate_expenditure_org_id          pa_resource_assignments.rate_expenditure_org_id%TYPE,
    x_rate_expenditure_type            pa_resource_assignments.rate_expenditure_type%TYPE);

TYPE PA_TASKS_REC IS RECORD (
    x_task_bill_rate_org_id            pa_tasks.non_labor_bill_rate_org_id%TYPE,
    x_task_sch_discount                pa_tasks.non_labor_schedule_discount%TYPE,
    x_task_sch_date                    pa_tasks.non_labor_schedule_fixed_date%TYPE,
    x_task_nl_std_bill_rt_sch_id       pa_tasks.non_lab_std_bill_rt_sch_id%TYPE,
    x_task_emp_bill_rate_sch_id        pa_tasks.emp_bill_rate_schedule_id%TYPE,
    x_task_job_bill_rate_sch_id        pa_tasks.job_bill_rate_schedule_id%TYPE,
    x_task_lab_bill_rate_org_id        pa_tasks.labor_bill_rate_org_id%TYPE,
    x_task_lab_sch_type                pa_tasks.labor_sch_type%TYPE,
    x_task_non_labor_sch_type          pa_tasks.non_labor_sch_type%TYPE,
    x_top_task_id                      pa_tasks.top_task_id%TYPE);

TYPE PA_PROJECTS_ALL_REC IS RECORD (
    x_assign_precedes_task             pa_projects_all.assign_precedes_task%TYPE,
    x_bill_job_group_id                pa_projects_all.bill_job_group_id%TYPE,
    x_carrying_out_organization_id     pa_projects_all.carrying_out_organization_id%TYPE,
    x_multi_currency_billing_flag      pa_projects_all.multi_currency_billing_flag%TYPE,
    x_org_id                           pa_projects_all.org_id%TYPE,
    x_non_labor_bill_rate_org_id       pa_projects_all.non_labor_bill_rate_org_id%TYPE,
    x_project_currency_code            pa_projects_all.project_currency_code%TYPE,
    x_non_labor_schedule_discount      pa_projects_all.non_labor_schedule_discount%TYPE,
    x_non_labor_sch_fixed_date         pa_projects_all.non_labor_schedule_fixed_date%TYPE,
    x_non_lab_std_bill_rt_sch_id       pa_projects_all.non_lab_std_bill_rt_sch_id%TYPE,
    x_project_type                     pa_projects_all.project_type%TYPE,
    x_projfunc_currency_code           pa_projects_all.projfunc_currency_code%TYPE,
    x_emp_bill_rate_schedule_id        pa_projects_all.emp_bill_rate_schedule_id%TYPE,
    x_job_bill_rate_schedule_id        pa_projects_all.job_bill_rate_schedule_id%TYPE,
    x_labor_bill_rate_org_id           pa_projects_all.labor_bill_rate_org_id%TYPE,
    x_labor_sch_type                   pa_projects_all.labor_sch_type%TYPE,
    x_non_labor_sch_type               pa_projects_all.non_labor_sch_type%TYPE);

TYPE PROJ_FP_OPTIONS_REC IS RECORD (
    x_fp_res_cl_bill_rate_sch_id       pa_proj_fp_options.res_class_bill_rate_sch_id%TYPE,
    x_fp_res_cl_raw_cost_sch_id        pa_proj_fp_options.res_class_raw_cost_sch_id%TYPE,
    x_fp_use_planning_rt_flag          pa_proj_fp_options.use_planning_rates_flag%TYPE,
    x_fp_rev_job_rate_sch_id           pa_proj_fp_options.rev_job_rate_sch_id%TYPE,
    x_fp_cost_job_rate_sch_id          pa_proj_fp_options.cost_job_rate_sch_id%TYPE,
    x_fp_rev_emp_rate_sch_id           pa_proj_fp_options.rev_emp_rate_sch_id%TYPE,
    x_fp_cost_emp_rate_sch_id          pa_proj_fp_options.cost_emp_rate_sch_id%TYPE,
    x_fp_rev_non_lab_rs_rt_sch_id      pa_proj_fp_options.rev_non_labor_res_rate_sch_id%TYPE,
    x_fp_cost_non_lab_rs_rt_sch_id     pa_proj_fp_options.cost_non_labor_res_rate_sch_id%TYPE,
    x_fp_cost_burden_rate_sch_id       pa_proj_fp_options.cost_burden_rate_sch_id%TYPE,
    x_fp_budget_version_type           pa_budget_versions.version_type%TYPE);

PROCEDURE GET_VALUES_FOR_PLANNING_RATE
          (P_PROJECT_ID                  IN    PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID           IN    PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_RESOURCE_ASSIGNMENT_ID      IN    PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE,
           P_TASK_ID                     IN    PA_TASKS.TASK_ID%TYPE,
	   P_RESOURCE_LIST_MEMBER_ID     IN    PA_RESOURCE_ASSIGNMENTS.resource_list_member_id%TYPE,
	   P_TXN_CURRENCY_CODE           IN    PA_BUDGET_LINES.txn_currency_code%TYPE,
           X_RES_FORMAT_ID               OUT   NOCOPY PA_RESOURCE_LIST_MEMBERS.RES_FORMAT_ID%TYPE,
           X_RESOURCE_ASN_REC            OUT   NOCOPY  RESOURCE_ASN_REC,
           X_PA_TASKS_REC                OUT   NOCOPY  PA_TASKS_REC,
           X_PA_PROJECTS_ALL_REC         OUT   NOCOPY  PA_PROJECTS_ALL_REC,
           X_PROJ_FP_OPTIONS_REC         OUT   NOCOPY  PROJ_FP_OPTIONS_REC,
	   X_RETURN_STATUS               OUT   NOCOPY  VARCHAR2,
           X_MSG_COUNT                   OUT   NOCOPY  NUMBER,
           X_MSG_DATA	                 OUT   NOCOPY  VARCHAR2);

PROCEDURE FP_DEBUG
          (P_CALLED_MODE    IN   VARCHAR2 DEFAULT 'SELF_SERVICE',
           /*p_called_mode values are SELF_SERVICE or CONCURRENT */
           P_MSG            IN   VARCHAR2,
           P_MODULE_NAME    IN   VARCHAR2 DEFAULT NULL,
           P_LOG_LEVEL      IN   NUMBER   DEFAULT 5);

FUNCTION GET_ETC_START_DATE(P_BUDGET_VERSION_ID PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE)
RETURN DATE;

FUNCTION GET_ACTUALS_THRU_DATE(P_BUDGET_VERSION_ID PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE)
RETURN DATE;

FUNCTION GET_RL_UNCATEGORIZED_FLAG(P_RESOURCE_LIST_ID PA_BUDGET_VERSIONS.RESOURCE_LIST_ID%TYPE)
RETURN VARCHAR2;

FUNCTION GET_UC_RES_LIST_RLM_ID(P_RESOURCE_LIST_ID PA_BUDGET_VERSIONS.RESOURCE_LIST_ID%TYPE,
          P_RESOURCE_CLASS_CODE pa_resource_list_members.RESOURCE_CLASS_CODE%TYPE)
RETURN NUMBER;
/* This function returns the RLM ID for the given
   project id + res list id + resource class level resource combination. */
FUNCTION GET_RLM_ID(P_PROJECT_ID PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
		    P_RESOURCE_LIST_ID PA_BUDGET_VERSIONS.RESOURCE_LIST_ID%TYPE,
                    P_RESOURCE_CLASS_CODE pa_resource_assignments.resource_class_code%type)
RETURN NUMBER;

/**
 * 30-JUN-05 dkuo added parameters P_CHECK_SRC_ERRORS, X_WARNING_MESSAGE.
 * See procedure body for documentation on parameters and API functionality.
 **/
PROCEDURE VALIDATE_SUPPORT_CASES
       (P_FP_COLS_REC_TGT               IN  PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
        P_CALLING_CONTEXT               IN  VARCHAR2 DEFAULT 'SELF_SERVICE',
        P_CHECK_SRC_ERRORS_FLAG         IN  VARCHAR2 DEFAULT 'Y',
        X_WARNING_MESSAGE               OUT NOCOPY  VARCHAR2,
        X_RETURN_STATUS                 OUT NOCOPY  VARCHAR2,
        X_MSG_COUNT                     OUT NOCOPY  NUMBER,
        X_MSG_DATA                      OUT NOCOPY  VARCHAR2);

PROCEDURE DEFAULT_BDGT_SRC_VER
       (P_FP_COLS_REC_TGT               IN  PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
        P_CALLING_CONTEXT               IN  VARCHAR2 DEFAULT 'SELF_SERVICE',
        X_FP_COLS_REC_TGT               OUT NOCOPY  PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
        X_RETURN_STATUS                 OUT NOCOPY  VARCHAR2,
        X_MSG_COUNT                     OUT NOCOPY  NUMBER,
        X_MSG_DATA                      OUT NOCOPY  VARCHAR2);

END  PA_FP_GEN_AMOUNT_UTILS;

/
