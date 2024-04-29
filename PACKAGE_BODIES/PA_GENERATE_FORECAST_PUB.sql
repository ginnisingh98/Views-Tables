--------------------------------------------------------
--  DDL for Package Body PA_GENERATE_FORECAST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_GENERATE_FORECAST_PUB" AS
/* $Header: PARRFGPB.pls 120.3 2006/03/22 20:40:29 nkumbi noship $ */

  FUNCTION Get_Person_Id(p_res_id NUMBER)
     RETURN NUMBER IS
    x_person_id NUMBER;
  BEGIN
    SELECT person_id INTO x_person_id FROM
    PA_RESOURCE_TXN_ATTRIBUTES WHERE
    RESOURCE_ID = p_res_id;
    RETURN x_person_id;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  WHEN OTHERS THEN
    RETURN NULL;
  END;

  PROCEDURE UPDATE_BUDG_VERSION(p_budget_version_id IN NUMBER ) IS
  BEGIN
    UPDATE PA_BUDGET_VERSIONS SET PLAN_PROCESSING_CODE = 'E'
      WHERE
    BUDGET_VERSION_ID = p_budget_version_id;
    COMMIT;
  END;

--History:
--    23-Mar-06     nkumbi      Stubbed out the procedure as PAWFGPF workflow is obsolete in R12
  PROCEDURE Submit_Project_Forecast(p_project_id    IN  NUMBER,
                                    x_msg_count     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                    x_msg_data      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                    x_return_status OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
  BEGIN
    NULL;
   END Submit_Project_Forecast;

  PROCEDURE Set_Error_Details(p_return_status IN     VARCHAR2,
                              x_msg_count     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_msg_data      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_data          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_msg_index_out    OUT    NOCOPY NUMBER       ) IS  --File.Sql.39 bug 4440895
    l_msg_count NUMBER;
    l_msg_data  VARCHAR2(2000);
    l_data      VARCHAR2(2000);
    l_msg_index_out NUMBER;

  BEGIN
    PA_DEBUG.set_err_stack('Set_Error_Details');
    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF fnd_msg_pub.count_msg = 1 THEN
          PA_INTERFACE_UTILS_PUB.Get_Messages (
                                        p_encoded        => FND_API.G_TRUE,
                                        p_msg_index      => 1,
                                        p_msg_count      => 1 ,
                                        p_msg_data       => l_msg_data ,
                                        p_data           => l_data,
                                        p_msg_index_out  => l_msg_index_out );
             x_msg_data := l_data;
             x_msg_count := 1;
        ELSE
          x_msg_count := fnd_msg_pub.count_msg;
        END IF;
    END IF;
    PA_DEBUG.reset_err_stack;
    RETURN;
  EXCEPTION
  WHEN OTHERS THEN
   RAISE;
  END Set_Error_Details;


  PROCEDURE Maintain_Budget_Version(p_project_id           IN  NUMBER,
                                    p_plan_processing_code IN  VARCHAR2,
                                    x_budget_version_id    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                    x_msg_count            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                    x_msg_data             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                    x_return_status        OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
     CURSOR BUDGET_VERSION IS
               SELECT BUDGET_VERSION_ID, PLAN_PROCESSING_CODE
               FROM  PA_BUDGET_VERSIONS
               WHERE PROJECT_ID = p_project_id AND
                     BUDGET_TYPE_CODE = 'FORECASTING_BUDGET_TYPE';
     l_ret_status VARCHAR2(100);
     l_created_by    NUMBER(15) := PA_FORECAST_GLOBAL.G_who_columns.G_created_by;
     l_request_id    NUMBER(15) := PA_FORECAST_GLOBAL.G_who_columns.G_request_id;
     l_program_id    NUMBER(15) := PA_FORECAST_GLOBAL.G_who_columns.G_program_id;
     l_program_application_id NUMBER(15) := PA_FORECAST_GLOBAL.G_who_columns.G_program_application_id;
     l_creation_date        DATE := PA_FORECAST_GLOBAL.G_who_columns.G_creation_date;
     l_program_update_date  DATE := PA_FORECAST_GLOBAL.G_who_columns.G_last_update_date;

     l_fcst_def_bem                 PA_BUDGET_VERSIONS.BUDGET_ENTRY_METHOD_CODE%TYPE;
     l_fcst_res_list                PA_RESOURCE_LISTS_ALL_BG.RESOURCE_LIST_ID%TYPE;
     l_fcst_period_type             VARCHAR2(30);

     l_plan_processing_code PA_BUDGET_VERSIONS.PLAN_PROCESSING_CODE%TYPE;
     l_rowid                ROWID;
     l_msg_data             VARCHAR2(2000);
     l_data                 VARCHAR2(2000);
     l_msg_index_out        NUMBER:=0;
     l_msg_count            NUMBER;


  BEGIN
    PA_DEBUG.set_err_stack('Maintain_Budget_Version');
    l_ret_status := FND_API.G_RET_STS_SUCCESS;

    PA_FORECAST_GLOBAL.Initialize_Global(
                                          x_msg_count  => x_msg_count,
                                          x_msg_data   => l_msg_data,
                                          x_ret_status => l_ret_status );
--          l_msg_count := x_msg_count;
    IF l_ret_status <> FND_API.G_RET_STS_SUCCESS THEN

          PA_GENERATE_FORECAST_PUB.Set_Error_Details(
                              p_return_status => l_ret_status,
                              x_msg_count     => l_msg_count,
                              x_msg_data      => l_msg_data,
                              x_data          => l_data,
                              x_msg_index_out => l_msg_index_out );

       x_msg_count     := l_msg_count;
       x_msg_data      := l_msg_data;
       x_return_status := l_ret_status;
       PA_DEBUG.reset_err_stack;
       RETURN;
    END IF;

    l_fcst_def_bem := PA_FORECAST_GLOBAL.G_implementation_details.G_fcst_def_bem;
    l_fcst_res_list:= PA_FORECAST_GLOBAL.G_implementation_details.G_fcst_res_list;
    l_fcst_period_type:=PA_FORECAST_GLOBAL.G_implementation_details.G_fcst_period_type;

    l_created_by             := PA_FORECAST_GLOBAL.G_who_columns.G_created_by;
    l_request_id             := PA_FORECAST_GLOBAL.G_who_columns.G_request_id;
    l_program_id             := PA_FORECAST_GLOBAL.G_who_columns.G_program_id;
    l_program_application_id := PA_FORECAST_GLOBAL.G_who_columns.G_program_application_id;
    l_creation_date          := PA_FORECAST_GLOBAL.G_who_columns.G_creation_date;
    l_program_update_date    := PA_FORECAST_GLOBAL.G_who_columns.G_last_update_date;

    OPEN BUDGET_VERSION;
    FETCH BUDGET_VERSION INTO
               x_budget_version_id,
               l_plan_processing_code;
   IF BUDGET_VERSION%NOTFOUND THEN
     PA_DEBUG.g_err_stage := '630: before calling PA_BUDGET_VERSIONS_PKG.INSERT_ROW';
     PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
     PA_BUDGET_VERSIONS_PKG.Insert_Row(
                       X_ROWID                        => l_rowid,
                       X_BUDGET_VERSION_ID            => x_budget_version_id,
                       X_PROJECT_ID                   => p_project_id,
                       X_BUDGET_TYPE_CODE             => 'FORECASTING_BUDGET_TYPE',
                       X_VERSION_NUMBER               => 1,
                       X_BUDGET_STATUS_CODE           => 'W',
                       X_LAST_UPDATE_DATE             => l_program_update_date,
                       X_LAST_UPDATED_BY              => l_created_by,
                       X_CREATION_DATE                => l_creation_date,
                       X_CREATED_BY                   => l_created_by,
                       X_LAST_UPDATE_LOGIN            => l_request_id,
                       X_CURRENT_FLAG                 => 'X',
                       X_ORIGINAL_FLAG                => 'X',
                       X_CURRENT_ORIGINAL_FLAG        => 'X',
                       X_RESOURCE_ACCUMULATED_FLAG    => 'X',
                       X_RESOURCE_LIST_ID             => l_fcst_res_list,
                       X_VERSION_NAME                 => NULL,
                       X_BUDGET_ENTRY_METHOD_CODE     => l_fcst_def_bem,
                       X_BASELINED_BY_PERSON_ID       => NULL,
                       X_BASELINED_DATE               => NULL,
                       X_CHANGE_REASON_CODE           => NULL,
                       X_LABOR_QUANTITY               => 0,
                       X_LABOR_UNIT_OF_MEASURE        => 0,
                       X_RAW_COST                     => 0,
                       X_BURDENED_COST                => 0,
                       X_REVENUE                      => 0,
                       X_DESCRIPTION                  => NULL,
                       X_ATTRIBUTE_CATEGORY           => NULL,
                       X_ATTRIBUTE1                   => NULL,
                       X_ATTRIBUTE2                   => NULL,
                       X_ATTRIBUTE3                   => NULL,
                       X_ATTRIBUTE4                   => NULL,
                       X_ATTRIBUTE5                   => NULL,
                       X_ATTRIBUTE6                   => NULL,
                       X_ATTRIBUTE7                   => NULL,
                       X_ATTRIBUTE8                   => NULL,
                       X_ATTRIBUTE9                   => NULL,
                       X_ATTRIBUTE10                  => NULL,
                       X_ATTRIBUTE11                  => NULL,
                       X_ATTRIBUTE12                  => NULL,
                       X_ATTRIBUTE13                  => NULL,
                       X_ATTRIBUTE14                  => NULL,
                       X_ATTRIBUTE15                  => NULL,
                       X_FIRST_BUDGET_PERIOD          => NULL,
                       X_PM_PRODUCT_CODE              => NULL,
                       X_PM_BUDGET_REFERENCE          => NULL,
                       X_WF_STATUS_CODE               => NULL,
                       X_PLAN_PROCESSING_CODE         => p_plan_processing_code);
     PA_DEBUG.g_err_stage := '660: after calling PA_BUDGET_VERSIONS_PKG.INSERT_ROW';
     PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
   ELSE
     IF l_plan_processing_code = 'P' THEN
       l_ret_status := FND_API.G_RET_STS_ERROR;
       PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                             p_msg_name       => 'PA_FCST_IN_PROCESS');

        PA_GENERATE_FORECAST_PUB.Set_Error_Details(
                              p_return_status => l_ret_status,
                              x_msg_count     => l_msg_count,
                              x_msg_data      => l_msg_data,
                              x_data          => l_data,
                              x_msg_index_out => l_msg_index_out );

       x_msg_count     := l_msg_count;
       x_msg_data      := l_msg_data;
       x_return_status := l_ret_status;
        CLOSE BUDGET_VERSION;
        PA_DEBUG.reset_err_stack;
        RETURN;
     END IF;
     PA_DEBUG.g_err_stage := '680: before updating PA_BUDGET_VERSIONS';
     PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

     UPDATE PA_BUDGET_VERSIONS SET
            PLAN_PROCESSING_CODE      = p_plan_processing_code,
            BUDGET_ENTRY_METHOD_CODE  = l_fcst_def_bem
       WHERE
     BUDGET_VERSION_ID = x_budget_version_id;

     PA_DEBUG.g_err_stage := '690: after updating PA_BUDGET_VERSIONS';
     PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

  END IF;
  CLOSE BUDGET_VERSION;
  x_return_status := l_ret_status;
  PA_DEBUG.reset_err_stack;
  RETURN;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE;
END Maintain_Budget_Version;


  PROCEDURE Generate_Forecast(p_project_id      IN  NUMBER
                             ,p_debug_mode      IN  VARCHAR2
                             ,x_return_status   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                             ,x_msg_count       OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                             ,x_msg_data        OUT NOCOPY VARCHAR2) IS  --File.Sql.39 bug 4440895

  l_budget_line_id PA_BUDGET_LINES.BUDGET_LINE_ID%type; /* FPB2 */
  CURSOR PROJ_DETAILS IS
   SELECT P.PROJECT_TYPE,P.PROJECT_CURRENCY_CODE,P.CARRYING_OUT_ORGANIZATION_ID,
        P.PROJECT_VALUE, P.JOB_BILL_RATE_SCHEDULE_ID, P.EMP_BILL_RATE_SCHEDULE_ID,
        P.DISTRIBUTION_RULE,P.BILL_JOB_GROUP_ID,NVL(P.ORG_ID,-99),P.COMPLETION_DATE,
        NVL(P.TEMPLATE_FLAG,'N'),
        P.PROJFUNC_CURRENCY_CODE,
        P.PROJFUNC_BIL_RATE_DATE_CODE,
        P.PROJFUNC_BIL_RATE_TYPE,
        P.PROJFUNC_BIL_RATE_DATE,
        P.PROJFUNC_BIL_EXCHANGE_RATE,
        P.COST_JOB_GROUP_ID,
        P.PROJECT_RATE_DATE,
        P.PROJECT_RATE_TYPE,
        P.PROJECT_BIL_RATE_DATE_CODE,
        P.PROJECT_BIL_RATE_TYPE,
        P.PROJECT_BIL_RATE_DATE,
        P.PROJECT_BIL_EXCHANGE_RATE,
        P.PROJFUNC_COST_RATE_TYPE,
        P.PROJFUNC_COST_RATE_DATE,
        P.LABOR_TP_SCHEDULE_ID,
        P.LABOR_TP_FIXED_DATE,
        P.LABOR_SCHEDULE_DISCOUNT,
        NVL(P.ASSIGN_PRECEDES_TASK,'N'),
        NVL(P.LABOR_BILL_RATE_ORG_ID,-99),
        P.LABOR_STD_BILL_RATE_SCHDL,
        P.LABOR_SCHEDULE_FIXED_DATE,
        P.LABOR_SCH_TYPE
        FROM
    PA_PROJECTS_ALL P WHERE PROJECT_ID = P_PROJECT_ID;

  CURSOR PROJ_ASSIGNMENTS IS
   SELECT PA.ASSIGNMENT_ID, PA.START_DATE,PA.RESOURCE_ID,PA.PROJECT_ROLE_ID,
   PA.FCST_JOB_ID,PA.FCST_JOB_GROUP_ID,PR.MEANING,
   PA.ASSIGNMENT_TYPE ,
   PA.EXPENDITURE_ORGANIZATION_ID,
   PA.EXPENDITURE_TYPE,
   PA.REVENUE_BILL_RATE,
   PA.EXPENDITURE_ORG_ID,
   PA.STATUS_CODE,
   WB.BILLABLE_CAPITALIZABLE_FLAG --Added for the bug 2420564
    FROM
   PA_PROJECT_ASSIGNMENTS PA,
   PA_WORK_TYPES_B WB,
   PA_PROJECT_ROLE_TYPES PR
       WHERE
  PA.PROJECT_ID = p_project_id AND
  PA.PROJECT_ROLE_ID = PR.PROJECT_ROLE_ID AND
  WB.WORK_TYPE_ID = PA.WORK_TYPE_ID(+);   --Added for the bug 2420564

   CURSOR FCST_PA(p_prj_assignment_id NUMBER) IS
          SELECT FI.EXPENDITURE_ORG_ID,FI.EXPENDITURE_ORGANIZATION_ID,
                     FI.RCVR_PA_PERIOD_NAME,
                     P.START_DATE,P.END_DATE,SUM(FI.ITEM_QUANTITY),
                     MIN(FI.FORECAST_ITEM_ID)
                 FROM
   PA_FORECAST_ITEMS FI,
   PA_FORECAST_ITEM_DETAILS FID,
   PA_PERIODS_ALL P
                 WHERE
   FI.PROJECT_ORG_ID            = NVL(P.ORG_ID,-99) AND
   P.PERIOD_NAME                = FI.RCVR_PA_PERIOD_NAME AND
   FI.FORECAST_ITEM_ID          = FID.FORECAST_ITEM_ID AND
   FID.FORECAST_SUMMARIZED_CODE = 'N' AND
   FID.NET_ZERO_FLAG            = 'N' AND
   FI.ERROR_FLAG                = 'N' AND
   FI.DELETE_FLAG               = 'N' AND
   ASSIGNMENT_ID                = p_prj_assignment_id AND
   FI.EXPENDITURE_ORG_ID <> -88 /* Added this condition for bug 3151420 */
   GROUP BY
   FI.EXPENDITURE_ORG_ID,FI.EXPENDITURE_ORGANIZATION_ID,
   P.START_DATE,P.END_DATE,FI.RCVR_PA_PERIOD_NAME;

  CURSOR FCST_GL(p_prj_assignment_id NUMBER)  IS
         SELECT FI.EXPENDITURE_ORG_ID, FI.EXPENDITURE_ORGANIZATION_ID,
           FI.RCVR_GL_PERIOD_NAME,
           GLP.START_DATE, GLP.END_DATE,SUM(FI.ITEM_QUANTITY),
                     MIN(FI.FORECAST_ITEM_ID)
  FROM
  PA_FORECAST_ITEMS FI,
  PA_FORECAST_ITEM_DETAILS FID,
  GL_PERIODS GLP,         /* Added the ending comma for Bug 3512491 */
  PA_IMPLEMENTATIONS IMP, /* Added the table for Bug 3512491 */
  GL_SETS_OF_BOOKS SOB    /* Added the table for Bug 3512491 */
  WHERE
  FI.FORECAST_ITEM_ID = FID.FORECAST_ITEM_ID AND
  FID.FORECAST_SUMMARIZED_CODE = 'N' AND
  FID.NET_ZERO_FLAG            = 'N' AND
  FI.ERROR_FLAG                = 'N' AND
  FI.DELETE_FLAG               = 'N' AND
  SOB.SET_OF_BOOKS_ID          = IMP.SET_OF_BOOKS_ID AND /* Added the join for Bug 3512491 */
  GLP.PERIOD_SET_NAME          = SOB.PERIOD_SET_NAME AND /* Modified the join for Bug 3512491 */
  GLP.PERIOD_NAME              = FI.RCVR_GL_PERIOD_NAME  AND
  ASSIGNMENT_ID                = p_prj_assignment_id AND
  FI.EXPENDITURE_ORG_ID <> -88 /* Added this condition for bug 3151420 */
  GROUP BY
  FI.EXPENDITURE_ORG_ID, FI.EXPENDITURE_ORGANIZATION_ID,
  GLP.START_DATE, GLP.END_DATE, FI.RCVR_GL_PERIOD_NAME;

  CURSOR BUDGET_LINES(c_budget_version_id PA_RESOURCE_ASSIGNMENTS.BUDGET_VERSION_ID%TYPE,
                      c_project_id        PA_RESOURCE_ASSIGNMENTS.PROJECT_ID%TYPE,
                      c_resource_assignment_id
     PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE) IS
         SELECT BL.PERIOD_NAME,BL.START_DATE,
             BL.BURDENED_COST FROM PA_BUDGET_LINES BL,
                       PA_RESOURCE_ASSIGNMENTS RA WHERE
                       BL.RESOURCE_ASSIGNMENT_ID = RA.RESOURCE_ASSIGNMENT_ID AND
                       RA.BUDGET_VERSION_ID = c_budget_version_id AND
                       RA.PROJECT_ID = c_project_id  AND
                       RA.RESOURCE_LIST_MEMBER_ID = 103
         ORDER BY BL.START_DATE;

    l_carrying_out_organization_id PA_PROJECTS_ALL.CARRYING_OUT_ORGANIZATION_ID%TYPE;
    l_project_currency_code        PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE;
    l_projfunc_currency_code       PA_PROJECTS_ALL.PROJFUNC_CURRENCY_CODE%TYPE;
    l_project_value                PA_PROJECTS_ALL.PROJECT_VALUE%TYPE;
    l_job_bill_rate_schedule_id    PA_PROJECTS_ALL.JOB_BILL_RATE_SCHEDULE_ID%TYPE;
    l_emp_bill_rate_schedule_id    PA_PROJECTS_ALL.EMP_BILL_RATE_SCHEDULE_ID%TYPE;
    l_rev_gen_method               VARCHAR2(3);
    l_distribution_rule            PA_PROJECTS_ALL.DISTRIBUTION_RULE%TYPE;
    l_project_type                 PA_PROJECTS_ALL.PROJECT_TYPE%TYPE;
    l_bill_job_group_id            PA_PROJECTS_ALL.BILL_JOB_GROUP_ID%TYPE;
    l_org_id                       PA_PROJECTS_ALL.ORG_ID%TYPE;
    l_completion_date              PA_PROJECTS_ALL.COMPLETION_DATE%TYPE;
    l_template_flag                PA_PROJECTS_ALL.TEMPLATE_FLAG%TYPE;
    l_projfunc_bil_rate_date_code   PA_PROJECTS_ALL.PROJECT_BIL_RATE_DATE_CODE%TYPE;
    l_projfunc_bil_rate_type        PA_PROJECTS_ALL.PROJECT_BIL_RATE_TYPE%TYPE;
    l_projfunc_bil_rate_date        PA_PROJECTS_ALL.PROJECT_BIL_RATE_DATE%TYPE;
    l_projfunc_bil_exchange_rate    PA_PROJECTS_ALL.PROJECT_BIL_EXCHANGE_RATE%TYPE;

    l_system_linkage                Pa_Forecast_Items.EXPENDITURE_TYPE_CLASS%TYPE;
   /* Added for Org Forecasting */

  l_cost_job_group_id Pa_Projects_All.Cost_Job_Group_Id%TYPE;
  l_prj_rate_date Pa_Projects_All.PROJECT_RATE_DATE%TYPE;
  l_prj_rate_type Pa_Projects_All.PROJECT_RATE_TYPE%TYPE;
  l_prj_bil_rate_date_code Pa_Projects_All.PROJECT_BIL_RATE_DATE_CODE%TYPE;
  l_prj_bil_rate_type Pa_Projects_All.PROJECT_BIL_RATE_TYPE%TYPE;
  l_prj_bil_rate_date Pa_Projects_All.PROJECT_BIL_RATE_DATE%TYPE;
  l_prj_bil_ex_rate Pa_Projects_All.PROJECT_BIL_EXCHANGE_RATE%TYPE;
  l_prjfunc_cost_rate_type Pa_Projects_All.PROJFUNC_COST_RATE_TYPE%TYPE;
  l_prjfunc_cost_rate_date Pa_Projects_All.PROJFUNC_COST_RATE_DATE%TYPE;
  l_labor_tp_schedule_id Pa_Projects_All.LABOR_TP_SCHEDULE_ID%TYPE;
  l_labor_tp_fixed_date Pa_Projects_All.LABOR_TP_FIXED_DATE%TYPE;

  l_labor_sch_discount Pa_Projects_All.LABOR_SCHEDULE_DISCOUNT%TYPE;
  l_asg_precedes_task Pa_Projects_All.ASSIGN_PRECEDES_TASK%TYPE;
  l_labor_bill_rate_orgid Pa_Projects_All.LABOR_BILL_RATE_ORG_ID%TYPE;
  l_labor_std_bill_rate_sch Pa_Projects_All.LABOR_STD_BILL_RATE_SCHDL%TYPE;
  l_labor_sch_fixed_dt Pa_Projects_All.LABOR_SCHEDULE_FIXED_DATE%TYPE;
  l_labor_sch_type Pa_Projects_All.LABOR_SCH_TYPE%TYPE;

   l_rt_pfunc_rev_rt_date_tab    PA_PLSQL_DATATYPES.DateTabTyp ;
   l_rt_pfunc_rev_rt_type_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
   l_rt_pfunc_rev_ex_rt_tab      PA_PLSQL_DATATYPES.NumTabTyp;
   l_rt_pfunc_rev_rt_dt_code_tab PA_PLSQL_DATATYPES.Char30TabTyp;

  l_rt_system_linkage_tab        PA_PLSQL_DATATYPES.Char30TabTyp;


   lx_rt_pfunc_rev_rt_date_tab   PA_PLSQL_DATATYPES.DateTabTyp ;
   lx_rt_pfunc_rev_rt_type_tab   PA_PLSQL_DATATYPES.Char30TabTyp;
   lx_rt_pfunc_rev_ex_rt_tab     PA_PLSQL_DATATYPES.NumTabTyp;

   l_rt_pfunc_cost_rt_date_tab   PA_PLSQL_DATATYPES.DateTabTyp;
   l_rt_pfunc_cost_rt_type_tab   PA_PLSQL_DATATYPES.Char30TabTyp;

   lx_rt_pfunc_cost_rt_date_tab  PA_PLSQL_DATATYPES.DateTabTyp;
   lx_rt_pfunc_cost_rt_type_tab  PA_PLSQL_DATATYPES.Char30TabTyp;
   lx_rt_pfunc_cost_ex_rt_tab    PA_PLSQL_DATATYPES.NumTabTyp;


   l_rt_proj_cost_rt_date_tab    PA_PLSQL_DATATYPES.DateTabTyp;
   l_rt_proj_cost_rt_type_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
   l_rt_proj_rev_rt_date_tab     PA_PLSQL_DATATYPES.DateTabTyp;
   l_rt_proj_rev_rt_type_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
   l_rt_proj_rev_rt_dt_code_tab  PA_PLSQL_DATATYPES.Char30TabTyp;
   l_rt_proj_rev_ex_rt_tab       PA_PLSQL_DATATYPES.NumTabTyp;

   lx_rt_proj_cost_rt_date_tab   PA_PLSQL_DATATYPES.DateTabTyp;
   lx_rt_proj_cost_rt_type_tab   PA_PLSQL_DATATYPES.Char30TabTyp;
   lx_rt_proj_cost_ex_rt_tab     PA_PLSQL_DATATYPES.NumTabTyp;
   lx_rt_proj_rev_rt_date_tab    PA_PLSQL_DATATYPES.DateTabTyp;
   lx_rt_proj_rev_rt_type_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
   lx_rt_proj_rev_ex_rt_tab      PA_PLSQL_DATATYPES.NumTabTyp;

  lx_rt_proj_bill_rate_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_proj_raw_revenue_tab     PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_proj_raw_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_proj_raw_cost_rt_tab     PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_proj_bd_cost_rt_tab      PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_proj_bd_cost_tab         PA_PLSQL_DATATYPES.NumTabTyp;

   lx_rt_expfunc_curr_code_tab       PA_PLSQL_DATATYPES.Char15TabTyp;
   lx_rt_expfunc_cost_rt_date_tab PA_PLSQL_DATATYPES.DateTabTyp;
   lx_rt_expfunc_cost_rt_type_tab PA_PLSQL_DATATYPES.Char30TabTyp;
   lx_rt_expfunc_cost_ex_rt_tab  PA_PLSQL_DATATYPES.NumTabTyp;

   lx_rt_cost_txn_curr_code_tab  PA_PLSQL_DATATYPES.Char15TabTyp;
   lx_rt_rev_txn_curr_code_tab   PA_PLSQL_DATATYPES.Char15TabTyp;
   lx_rt_txn_rev_bill_rt_tab     PA_PLSQL_DATATYPES.NumTabTyp;
   lx_rt_txn_raw_revenue_tab     PA_PLSQL_DATATYPES.NumTabTyp;
   lx_rt_txn_raw_cost_rt_tab     PA_PLSQL_DATATYPES.NumTabTyp ;
   lx_rt_txn_raw_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
   lx_rt_txn_bd_cost_rt_tab      PA_PLSQL_DATATYPES.NumTabTyp;
   lx_rt_txn_bd_cost_tab         PA_PLSQL_DATATYPES.NumTabTyp;


   /* Added for Org Forecasting */

    l_budget_version_id            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE;
    l_version_number               PA_BUDGET_VERSIONS.VERSION_NUMBER%TYPE;
    l_plan_processing_code         PA_BUDGET_VERSIONS.PLAN_PROCESSING_CODE%TYPE;

    l_prj_assignment_id            PA_PROJECT_ASSIGNMENTS.ASSIGNMENT_ID%TYPE;
    l_prj_start_date               PA_PROJECT_ASSIGNMENTS.START_DATE%TYPE;
    l_prj_resource_id              PA_PROJECT_ASSIGNMENTS.RESOURCE_ID%TYPE;
    l_prj_project_role_id          PA_PROJECT_ASSIGNMENTS.PROJECT_ROLE_ID%TYPE;
    l_prj_fcst_job_id              PA_PROJECT_ASSIGNMENTS.FCST_JOB_ID%TYPE;
    l_prj_fcst_job_group_id        PA_PROJECT_ASSIGNMENTS.FCST_JOB_GROUP_ID%TYPE;
    l_prj_meaning                  PA_PROJECT_ROLE_TYPES.MEANING%TYPE;
    l_prj_assignment_type          PA_PROJECT_ASSIGNMENTS.ASSIGNMENT_TYPE%TYPE;
    l_prj_exp_org_id               PA_PROJECT_ASSIGNMENTS.EXPENDITURE_ORG_ID%TYPE;
    l_prj_exp_organization_id      PA_PROJECT_ASSIGNMENTS.EXPENDITURE_ORGANIZATION_ID%TYPE;
    l_prj_expenditure_org_id       PA_PROJECT_ASSIGNMENTS.EXPENDITURE_ORG_ID%TYPE;
    l_prj_exp_type                 PA_PROJECT_ASSIGNMENTS.EXPENDITURE_TYPE%TYPE;
    l_prj_person_id                PA_PROJECT_ASSIGNMENTS.RESOURCE_ID%TYPE;
    l_prj_revenue_bill_rate        PA_PROJECT_ASSIGNMENTS.REVENUE_BILL_RATE%TYPE;
    l_prj_short_assignment_type    PA_PROJECT_ASSIGNMENTS.ASSIGNMENT_TYPE%TYPE;
    l_prj_status_code              PA_PROJECT_ASSIGNMENTS.STATUS_CODE%TYPE;




    l_fcst_def_bem                 PA_BUDGET_VERSIONS.BUDGET_ENTRY_METHOD_CODE%TYPE;
    l_fcst_res_list                PA_RESOURCE_LISTS_ALL_BG.RESOURCE_LIST_ID%TYPE;
    l_fcst_period_type             VARCHAR2(30);

    l_fcst_exp_org_id              PA_FORECAST_ITEMS.EXPENDITURE_ORGANIZATION_ID%TYPE;
    l_fcst_period_name             PA_PERIODS.PERIOD_NAME%TYPE;
    l_fcst_start_date              PA_PERIODS.START_DATE%TYPE;
    l_fcst_end_date                PA_PERIODS.END_DATE%TYPE;
    l_fcst_item_quantity           PA_FORECAST_ITEMS.ITEM_QUANTITY%TYPE;
    l_role_error_code              PA_RESOURCE_ASSIGNMENTS.PLAN_ERROR_CODE%TYPE;

    l_err_code                     VARCHAR2(30);
    l_err_stack                    VARCHAR2(2000);
    l_err_stage                    VARCHAR2(2000);
    l_err_id                       NUMBER;

    l_exp_func_raw_cost_rate         NUMBER;
    l_exp_func_raw_cost              NUMBER;
    l_exp_func_burdened_cost_rate    NUMBER;
    l_exp_func_burdened_cost         NUMBER;
    l_projfunc_bill_rate                 NUMBER;
    l_projfunc_raw_revenue               NUMBER;
    l_projfunc_raw_cost                  NUMBER;
    l_projfunc_raw_cost_rate             NUMBER;
    l_projfunc_burdened_cost             NUMBER;
    l_projfunc_burdened_cost_rate        NUMBER;
    l_error_msg                      VARCHAR2(30);

    l_std_raw_revenue                NUMBER;
    l_rev_currency_code              PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE;
    l_billable_flag                  VARCHAR2(2);--Added for the bug 2420564

    l_rev_reject_reason               VARCHAR2(1000);
    l_cost_reject_reason              VARCHAR2(1000);
    l_burdened_reject_reason          VARCHAR2(1000);
    l_other_reject_reason             VARCHAR2(1000);

    l_resource_list_member_id      PA_RESOURCE_LIST_MEMBERS.RESOURCE_LIST_MEMBER_ID%TYPE;
    l_resource_id                  PA_RESOURCE_LIST_MEMBERS.RESOURCE_LIST_MEMBER_ID%TYPE;
    l_resource_assignment_id       PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE;
    l_track_as_labor_flag  PA_RESOURCE_LIST_MEMBERS.TRACK_AS_LABOR_FLAG%TYPE;
    l_parent_member_id     PA_RESOURCE_LIST_MEMBERS.PARENT_MEMBER_ID%TYPE;
    l_prj_res_assignment_id        PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE;

    l_fcst_opt_jobcostrate_sch_id  PA_FORECASTING_OPTIONS_ALL.JOB_COST_RATE_SCHEDULE_ID%TYPE;

    l_calling_mode                 VARCHAR2(50);
    l_rowid                        ROWID;
  l_counter       NUMBER := 1 ;
  l_cost_cnt      NUMBER := 1 ;

  l_created_by    NUMBER(15) := PA_FORECAST_GLOBAL.G_who_columns.G_created_by;
  l_request_id    NUMBER(15) := PA_FORECAST_GLOBAL.G_who_columns.G_request_id;
  l_program_id    NUMBER(15) := PA_FORECAST_GLOBAL.G_who_columns.G_program_id;
  l_program_application_id NUMBER(15) := PA_FORECAST_GLOBAL.G_who_columns.G_program_application_id;
  l_creation_date        DATE := PA_FORECAST_GLOBAL.G_who_columns.G_creation_date;
  l_program_update_date  DATE := PA_FORECAST_GLOBAL.G_who_columns.G_last_update_date;

  l_period_name_flag  varchar2(1);
  l_period_name_tot_flag  varchar2(1);
  l_current_index PLS_INTEGER;
  l_current_index_tot PLS_INTEGER:=1;
  l_cnt           PLS_INTEGER;
  l_budget_lines_tbl     PA_GENERATE_FORECAST_PUB.budget_lines_tbl_type;
  l_budget_lines_tot_tbl PA_GENERATE_FORECAST_PUB.budget_lines_tbl_type;

  /* Updating the ROLE LEVEL TOTAL in PA_RESOURCE_ASSIGNMENTS */
  l_tot_quantity NUMBER;
  l_tot_revenue  NUMBER;
  l_tot_bcost    NUMBER;
  l_tot_cost     NUMBER;

  /* For Storing PROJECT LEVEL TOTAL in PA_RESOURCE_ASSIGNMENTS */
  l_tot_prj_quantity NUMBER:=0;
  l_tot_prj_revenue  NUMBER:=0;
  l_tot_prj_bcost    NUMBER:=0;
  l_tot_prj_cost     NUMBER:=0;


  l_prj_revenue_tab  PA_RATE_PVT_PKG.ProjAmt_TabTyp;
  l_prj_cost_tab     PA_RATE_PVT_PKG.ProjAmt_TabTyp;
  l_project_id       NUMBER;

  l_ret_status       VARCHAR2(100);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_data             VARCHAR2(2000);
  l_msg_index_out        NUMBER:=0;
  l_init_bill_rate_flag VARCHAR2(1);
  l_role_error_code_flag VARCHAR2(1);
  l_prj_level_revenue NUMBER:=0;
  l_process_fis_flag   VARCHAR2(1);
  l_asgmt_status_flag  VARCHAR2(1);
  l_commit_size        NUMBER:= PA_GENERATE_FORECAST_PUB.G_commit_cnt;
  l_commit_cnt         NUMBER:= 0;
  l_event_error_msg    VARCHAR2(100);

  l_bl_start_date_tab  PA_PLSQL_DATATYPES.DateTabTyp;
  l_bl_end_date_tab    PA_PLSQL_DATATYPES.DateTabTyp;
  l_bl_pd_name_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
  l_bl_qty_tab         PA_PLSQL_DATATYPES.NumTabTyp;
  l_bl_rcost_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_bl_revenue_tab     PA_PLSQL_DATATYPES.NumTabTyp;
  l_bl_bcost_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_bl_cost_rej_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
  l_bl_bcost_rej_tab   PA_PLSQL_DATATYPES.Char30TabTyp;
  l_bl_rev_rej_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
  l_bl_oth_rej_tab     PA_PLSQL_DATATYPES.Char30TabTyp;

  l_rt_forecast_item_id_tab     PA_PLSQL_DATATYPES.IdTabTyp;
  l_rt_pd_name_tab              PA_PLSQL_DATATYPES.Char30TabTyp;
  l_rt_start_date_tab           PA_PLSQL_DATATYPES.DateTabTyp;
  l_rt_end_date_tab             PA_PLSQL_DATATYPES.DateTabTyp;

  l_rt_qty_tab                  PA_PLSQL_DATATYPES.NumTabTyp;
  l_rt_exp_org_id_tab           PA_PLSQL_DATATYPES.IdTabTyp;
  l_rt_exp_organization_id_tab  PA_PLSQL_DATATYPES.IdTabTyp;

  l_rt_exp_func_raw_cst_rt_tab  PA_PLSQL_DATATYPES.NumTabTyp;
  l_rt_exp_func_raw_cst_tab     PA_PLSQL_DATATYPES.NumTabTyp;
  l_rt_exp_func_bur_cst_rt_tab  PA_PLSQL_DATATYPES.NumTabTyp;
  l_rt_exp_func_burdned_cst_tab PA_PLSQL_DATATYPES.NumTabTyp;
  l_rt_projfunc_bill_rt_tab         PA_PLSQL_DATATYPES.NumTabTyp;
  l_rt_projfunc_raw_revenue_tab     PA_PLSQL_DATATYPES.NumTabTyp;
  l_rt_projfunc_raw_cst_tab         PA_PLSQL_DATATYPES.NumTabTyp;
  l_rt_projfunc_raw_cst_rt_tab      PA_PLSQL_DATATYPES.NumTabTyp;
  l_rt_projfunc_burdned_cst_tab     PA_PLSQL_DATATYPES.NumTabTyp;
  l_rt_projfunc_bd_cst_rt_tab  PA_PLSQL_DATATYPES.NumTabTyp;
  l_rt_rev_rejct_reason_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
  l_rt_cst_rejct_reason_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
  l_rt_burdned_rejct_reason_tab PA_PLSQL_DATATYPES.Char30TabTyp;
  l_rt_others_rejct_reason_tab  PA_PLSQL_DATATYPES.Char30TabTyp;
  l_bulk_fetch_count            NUMBER:= 0;
  l_markup_percentage           NUMBER;
  l_cost_based_error_code       VARCHAR2(100);

  l_prj_asg_id_tab      PA_PLSQL_DATATYPES.IdTabTyp;
  l_avg_bill_rate_tab   PA_PLSQL_DATATYPES.NumTabTyp;
  /*Code Changes for Bug No.2984871 start */
  l_rowcount number :=0;
  /*Code Changes for Bug No.2984871 end */
  BEGIN
    PA_DEBUG.init_err_stack('PA_GENERATE_FORECAST_PUB.Generate_Forecast');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_ret_status := FND_API.G_RET_STS_SUCCESS;

    l_counter := l_counter + 1;
    PA_DEBUG.g_err_stage := '100: before calling global';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    l_commit_size := l_commit_size + 1;

    BEGIN
      PA_FORECAST_GLOBAL.Initialize_Global(
                                         x_msg_count  => x_msg_count,
                                         x_msg_data   => x_msg_data,
                                         x_ret_status => x_return_status);
    EXCEPTION
    WHEN OTHERS THEN
      RAISE;
    END;

    l_ret_status := x_return_status;

    PA_DEBUG.g_err_stage := '200: after calling global';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    IF l_ret_status <> FND_API.G_RET_STS_SUCCESS THEN
      PA_GENERATE_FORECAST_PUB.Set_Error_Details(
                              p_return_status => l_ret_status,
                              x_msg_count     => l_msg_count,
                              x_msg_data      => l_msg_data,
                              x_data          => l_data,
                              x_msg_index_out => l_msg_index_out );

       x_msg_count     := l_msg_count;
       x_msg_data      := l_msg_data;
       x_return_status := l_ret_status;
       PA_DEBUG.Reset_Err_stack;
       RETURN;
    END IF;


    l_fcst_def_bem := PA_FORECAST_GLOBAL.G_implementation_details.G_fcst_def_bem;
    l_fcst_res_list:= PA_FORECAST_GLOBAL.G_implementation_details.G_fcst_res_list;
    l_fcst_period_type:=PA_FORECAST_GLOBAL.G_implementation_details.G_fcst_period_type;
    l_fcst_opt_jobcostrate_sch_id:= PA_FORECAST_GLOBAL.G_implementation_details.G_fcst_cost_rate_sch_id;


    PA_DEBUG.g_err_stage := '205: Project ID                  :'||p_project_id;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := '210: Default budget entry method :'||l_fcst_def_bem;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := '220: Default resource list       :'||l_fcst_res_list;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := '230: Forecasting Period Type     :'||l_fcst_period_type;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

  l_created_by             := PA_FORECAST_GLOBAL.G_who_columns.G_created_by;
  l_request_id             := PA_FORECAST_GLOBAL.G_who_columns.G_request_id;
  l_program_id             := PA_FORECAST_GLOBAL.G_who_columns.G_program_id;
  l_program_application_id := PA_FORECAST_GLOBAL.G_who_columns.G_program_application_id;
  l_creation_date          := PA_FORECAST_GLOBAL.G_who_columns.G_creation_date;
  l_program_update_date    := PA_FORECAST_GLOBAL.G_who_columns.G_last_update_date;
    PA_DEBUG.g_err_stage   := '300: before fetching project cursor';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    /* l_role_error_code_flag is used here for only checking whether to
       continue with forecasting process or not */
    l_role_error_code_flag := 'N';
    OPEN PROJ_DETAILS;
    FETCH PROJ_DETAILS INTO
               l_project_type,
               l_project_currency_code,
               l_carrying_out_organization_id,
               l_project_value,
               l_job_bill_rate_schedule_id,
               l_emp_bill_rate_schedule_id,
               l_distribution_rule,
               l_bill_job_group_id,
               l_org_id,
               l_completion_date,
               l_template_flag,
               l_projfunc_currency_code,
               l_projfunc_bil_rate_date_code,
               l_projfunc_bil_rate_type,
               l_projfunc_bil_rate_date,
               l_projfunc_bil_exchange_rate,
               l_cost_job_group_id,
               l_prj_rate_date,
               l_prj_rate_type,
               l_prj_bil_rate_date_code,
               l_prj_bil_rate_type,
               l_prj_bil_rate_date,
               l_prj_bil_ex_rate,
               l_prjfunc_cost_rate_type,
               l_prjfunc_cost_rate_date,
               l_labor_tp_schedule_id,
               l_labor_tp_fixed_date,
               l_labor_sch_discount,
               l_asg_precedes_task,
               l_labor_bill_rate_orgid,
               l_labor_std_bill_rate_sch,
               l_labor_sch_fixed_dt,
               l_labor_sch_type;

    IF PROJ_DETAILS%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      l_ret_status    := x_return_status;
      l_role_error_code_flag := 'Y';
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                            p_msg_name       => 'PA_INVALID_PROJECT_ID');
    ELSIF l_template_flag = 'Y' THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      l_ret_status    := x_return_status;
      l_role_error_code_flag := 'Y';
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FCST_NOT_APPL_TMPL');
    END IF;
    IF l_role_error_code_flag  = 'Y' THEN
      PA_GENERATE_FORECAST_PUB.Set_Error_Details(
                              p_return_status => l_ret_status,
                              x_msg_count     => l_msg_count,
                              x_msg_data      => l_msg_data,
                              x_data          => l_data,
                              x_msg_index_out => l_msg_index_out );

       x_msg_count     := l_msg_count;
       x_msg_data      := l_msg_data;
       x_return_status := l_ret_status;
      PA_DEBUG.reset_err_stack;
      CLOSE PROJ_DETAILS;
      RETURN;
    END IF;
    CLOSE PROJ_DETAILS;
    PA_DEBUG.g_err_stage := '400: after  fetching project cursor';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := '410: before calling for rev gen md';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    BEGIN

      PA_RATE_PVT_PKG.Get_Revenue_Generation_Method(
                                                   P_PROJECT_ID         => p_project_id,
                                                   P_DISTRIBUTION_RULE  => l_distribution_rule,
                                                   X_REV_GEN_METHOD     => l_rev_gen_method,
                                                   X_ERROR_MSG          => l_error_msg );
    EXCEPTION
    WHEN OTHERS THEN
      RAISE;
    END;
    IF l_error_msg IS NOT NULL THEN
      l_ret_status    := FND_API.G_RET_STS_ERROR;

      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                            p_msg_name       => l_error_msg );

      PA_GENERATE_FORECAST_PUB.Set_Error_Details(
                              p_return_status => l_ret_status,
                              x_msg_count     => l_msg_count,
                              x_msg_data      => l_msg_data,
                              x_data          => l_data,
                              x_msg_index_out => l_msg_index_out );

       x_msg_count     := l_msg_count;
       x_msg_data      := l_msg_data;
       x_return_status := l_ret_status;
       PA_DEBUG.reset_err_stack;
      RETURN;
    END IF;


    PA_DEBUG.g_err_stage := '500: before calling  budget version cursor';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

    BEGIN
      PA_GENERATE_FORECAST_PUB.Maintain_Budget_Version(
                                    p_project_id           => p_project_id,
                                    p_plan_processing_code => 'P',
                                    x_budget_version_id    => l_budget_version_id,
                                    x_msg_count            => x_msg_count,
                                    x_msg_data             => x_msg_data,
                                    x_return_status        => x_return_status );
    EXCEPTION
    WHEN OTHERS THEN
      RAISE;
    END;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      l_ret_status := x_return_status;
      PA_GENERATE_FORECAST_PUB.Set_Error_Details(
                              p_return_status => l_ret_status,
                              x_msg_count     => l_msg_count,
                              x_msg_data      => l_msg_data,
                              x_data          => l_data,
                              x_msg_index_out => l_msg_index_out );

       x_msg_count     := l_msg_count;
       x_msg_data      := l_msg_data;
       x_return_status := l_ret_status;

       PA_DEBUG.g_err_stage := '550: The plan_processing_code may be P - PA_FCST_IN_PROCESS ';
       PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

       PA_DEBUG.reset_err_stack;
       RETURN;
    END IF;

  /* Deleting PA_BUDGET_LINES and PA_RESOURCE_ASSIGNMENTS   */

     DELETE FROM PA_BUDGET_LINES WHERE
         RESOURCE_ASSIGNMENT_ID IN
         (SELECT RESOURCE_ASSIGNMENT_ID FROM PA_RESOURCE_ASSIGNMENTS
                 WHERE
                 BUDGET_VERSION_ID = l_budget_version_id );

     DELETE FROM PA_RESOURCE_ASSIGNMENTS WHERE
         BUDGET_VERSION_ID = l_budget_version_id;
    /* Commit the changes so that no other process pick up the same project for Forecasting */

    COMMIT;

     PA_DEBUG.g_err_stage := '690: Budget Version ID :'||l_budget_version_id;
     PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
     PA_DEBUG.g_err_stage := '695: return status  :'||x_return_status;
     PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

     PA_DEBUG.g_err_stage := '700: before fetching PA_PROJ_ASSIGNMENT cursor';
     PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

  /* Set plan processing code to G - G(enerated Successfully)   */

  l_plan_processing_code := 'G';
  l_budget_lines_tot_tbl.DELETE;

  OPEN PROJ_ASSIGNMENTS;
  LOOP
    FETCH PROJ_ASSIGNMENTS INTO
                           l_prj_assignment_id,
                           l_prj_start_date,
                           l_prj_resource_id,
                           l_prj_project_role_id,
                           l_prj_fcst_job_id,
                           l_prj_fcst_job_group_id,
                           l_prj_meaning,
                           l_prj_assignment_type,
                           l_prj_exp_organization_id,
                           l_prj_exp_type,
                           l_prj_revenue_bill_rate,
                           l_prj_expenditure_org_id,
                           l_prj_status_code,
                           l_billable_flag; --Added for the bug 2420564;
   IF PROJ_ASSIGNMENTS%NOTFOUND THEN
      EXIT;
   END IF;
   l_role_error_code := NULL;
   l_role_error_code_flag  := 'N';

     PA_DEBUG.g_err_stage := '750: Assignment Id :'||l_prj_assignment_id;
     PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

   /* The following check is added to avoid processing of assignment records if the status
      is cancelled  */

   l_process_fis_flag := 'Y';
   IF l_prj_status_code IS NOT NULL THEN
      IF l_prj_assignment_type = 'OPEN_ASSIGNMENT' THEN
        l_asgmt_status_flag := PA_ASSIGNMENT_UTILS.Is_Asgmt_In_Open_Status(
                              l_prj_status_code,
                              'OPEN_ASGMT');
        IF l_asgmt_status_flag = 'N' THEN
          l_process_fis_flag := 'N';
        END IF;
      ELSIF ( l_prj_assignment_type = 'STAFFED_ASSIGNMENT' OR
              l_prj_assignment_type = 'STAFFED_ADMIN_ASSIGNMENT' ) THEN
        l_asgmt_status_flag := PA_ASSIGNMENT_UTILS.Is_Staffed_Asgmt_Cancelled(
                              l_prj_status_code,
                              'STAFFED_ASGMT');
        IF l_asgmt_status_flag = 'Y' THEN
          l_process_fis_flag := 'N';
        END IF;
      END IF;
   END IF;

   IF l_process_fis_flag = 'Y' AND l_prj_assignment_type = 'OPEN_ASSIGNMENT' AND
      ( l_prj_fcst_job_id IS NULL OR l_prj_fcst_job_group_id IS NULL ) THEN
     PA_DEBUG.g_err_stage := '800: before fetching deflt jobid and job group id from roles';
     PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      BEGIN
       SELECT PR.DEFAULT_JOB_ID,PJ.JOB_GROUP_ID INTO
              l_prj_fcst_job_id,l_prj_fcst_job_group_id FROM
              PA_PROJECT_ROLE_TYPES PR, PER_JOBS PJ
                 WHERE
              PR.PROJECT_ROLE_ID = l_prj_project_role_id AND
              PJ.JOB_ID          = PR.DEFAULT_JOB_ID;
       EXCEPTION
       WHEN NO_DATA_FOUND THEN
          l_role_error_code := 'PA_FCST_NOJOB_FOR_ROLE';
          l_role_error_code_flag := 'Y';
          l_plan_processing_code := 'E';
      WHEN OTHERS THEN
        UPDATE_BUDG_VERSION(p_budget_version_id => l_budget_version_id);
        RAISE;
      END;
     PA_DEBUG.g_err_stage := '850: after fetching PA_PROJ_ASSIGNMENT cursor';
     PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
   END IF;

     PA_DEBUG.g_err_stage := '900: before fetching the RLM ID';
     PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

       l_parent_member_id := NULL;
       l_track_as_labor_flag := NULL;
       l_resource_list_member_id := NULL;
       l_resource_id := NULL;
   IF l_process_fis_flag = 'Y' THEN
     BEGIN
       SELECT RLM.RESOURCE_LIST_MEMBER_ID INTO
              l_resource_list_member_id
                        FROM
       PA_RESOURCE_LIST_MEMBERS RLM, PA_RESOURCES R, PA_RESOURCE_TXN_ATTRIBUTES RT
                       WHERE
       RLM.RESOURCE_LIST_ID     = l_fcst_res_list AND
       RLM.RESOURCE_ID          = R.RESOURCE_ID AND
       RT.RESOURCE_ID           = R.RESOURCE_ID AND
       RT.PROJECT_ROLE_ID       = l_prj_project_role_id;
       PA_DEBUG.g_err_stage := '950: after  fetching the RLM ID';
       PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
       PA_DEBUG.g_err_stage := '960: RLM ID from TABLE :'||l_resource_list_member_id;
       PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
       EXCEPTION
       WHEN NO_DATA_FOUND THEN
          l_resource_list_member_id := NULL;
          PA_DEBUG.g_err_stage := '1000: before calling PA_CREATE_RESOURCE.CREATE_RESOURCE_LIST_MEMBER';
          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
          PA_CREATE_RESOURCE.ADD_RESOUCE_LIST_MEMBER
                         (P_RESOURCE_LIST_ID          => l_fcst_res_list,
                          P_RESOURCE_NAME             => l_prj_meaning,
                          P_RESOURCE_TYPE_CODE        => 'PROJECT_ROLE',
                          P_ALIAS                     => SUBSTR(l_prj_meaning,1,30),
                          P_SORT_ORDER                => NULL,
                          P_DISPLAY_FLAG              => NULL,
                          P_ENABLED_FLAG              => NULL,
                          P_PERSON_ID                 => NULL,
                          P_JOB_ID                    => NULL,
                          P_PROJ_ORGANIZATION_ID      => NULL,
                          P_VENDOR_ID                 => NULL,
                          P_EXPENDITURE_TYPE          => NULL,
                          P_EVENT_TYPE                => NULL,
                          P_EXPENDITURE_CATEGORY      => NULL,
                          P_REVENUE_CATEGORY_CODE     => NULL,
                          P_NON_LABOR_RESOURCE        => NULL,
                          P_SYSTEM_LINKAGE            => NULL,
                          P_PARENT_MEMBER_ID          => l_parent_member_id,
                          P_RESOURCE_LIST_MEMBER_ID   => l_resource_list_member_id,
                          P_TRACK_AS_LABOR_FLAG       => l_track_as_labor_flag,
                          P_ERR_CODE                  => l_err_id,
                          P_ERR_STAGE                 => l_err_stage,
                          P_ERR_STACK                 => l_err_stack,
                          P_PROJECT_ROLE_ID           => l_prj_project_role_id,
                          P_RESOURCE_ID               => l_resource_id);
          PA_DEBUG.g_err_stage := '1050: after  calling PA_CREATE_RESOURCE.CREATE_RESOURCE_LIST_MEMBER';
          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
          l_commit_cnt := l_commit_cnt + 1;
       END;
     END IF;
     PA_DEBUG.g_err_stage := '1060: RLM ID from API :'||l_resource_list_member_id;
     PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
  l_current_index := 1;
  l_tot_quantity := 0;
  l_tot_revenue  := 0;
  l_tot_bcost    := 0;
  l_tot_cost     := 0;
  IF l_process_fis_flag =  'Y' THEN
    IF l_prj_assignment_type = 'OPEN_ASSIGNMENT' THEN
       l_calling_mode := 'ROLE';
       l_prj_person_id := NULL;
       l_prj_short_assignment_type := 'R';
       IF l_prj_exp_organization_id IS NULL THEN
          l_prj_exp_organization_id :=  l_carrying_out_organization_id;
       END IF;
       IF l_prj_expenditure_org_id IS NULL THEN
          l_prj_expenditure_org_id := l_org_id;
       END IF;
    ELSIF ( l_prj_assignment_type = 'STAFFED_ASSIGNMENT' OR
            l_prj_assignment_type = 'STAFFED_ADMIN_ASSIGNMENT' ) THEN
       l_calling_mode := 'ASSIGNMENT';
       l_prj_short_assignment_type := 'A';
       l_prj_person_id       := GET_PERSON_ID(l_prj_resource_id);
       IF l_prj_person_id IS NULL THEN
         l_role_error_code := 'PA_FCST_NO_PERSON_ID';
         l_role_error_code_flag := 'Y';
         l_plan_processing_code := 'E';
       END IF;
     END IF;
  END IF;
  PA_DEBUG.g_err_stage := '1100: before Fetching Forecasting cursor';
  PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

  IF l_process_fis_flag = 'Y' THEN
    IF l_fcst_period_type = 'PA' THEN
      OPEN FCST_PA(l_prj_assignment_id);
    ELSE
      OPEN FCST_GL(l_prj_assignment_id);
    END IF;
  l_budget_lines_tbl.delete;

  l_rt_forecast_item_id_tab.delete;
  l_rt_pd_name_tab.delete;
  l_rt_start_date_tab.delete;
  l_rt_end_date_tab.delete;
  l_rt_qty_tab.delete;
  l_rt_exp_org_id_tab.delete;
  l_rt_exp_organization_id_tab.delete;
  l_rt_exp_func_raw_cst_rt_tab.delete;
  l_rt_exp_func_raw_cst_tab.delete;
  l_rt_exp_func_bur_cst_rt_tab.delete;
  l_rt_exp_func_burdned_cst_tab.delete;
  l_rt_projfunc_bill_rt_tab.delete;
  l_rt_projfunc_raw_revenue_tab.delete;
  l_rt_projfunc_raw_cst_tab.delete;
  l_rt_projfunc_raw_cst_rt_tab.delete;
  l_rt_projfunc_burdned_cst_tab.delete;
  l_rt_projfunc_bd_cst_rt_tab.delete;
  l_rt_rev_rejct_reason_tab.delete;
  l_rt_cst_rejct_reason_tab.delete;
  l_rt_burdned_rejct_reason_tab.delete;
  l_rt_others_rejct_reason_tab.delete;

  l_init_bill_rate_flag := 'N';
   /* the following LOOP is a dummy loop to take care of NO_DATA_FOUND error */
   LOOP
    IF l_fcst_period_type = 'PA' THEN

      FETCH FCST_PA BULK COLLECT INTO

             l_rt_exp_org_id_tab,
             l_rt_exp_organization_id_tab,
             l_rt_pd_name_tab,
             l_rt_start_date_tab,
             l_rt_end_date_tab,
             l_rt_qty_tab,
             l_rt_forecast_item_id_tab;
    ELSE
      FETCH FCST_GL BULK COLLECT INTO
             l_rt_exp_org_id_tab,
             l_rt_exp_organization_id_tab,
             l_rt_pd_name_tab,
             l_rt_start_date_tab,
             l_rt_end_date_tab,
             l_rt_qty_tab,
             l_rt_forecast_item_id_tab;
    END IF;
    l_bulk_fetch_count := l_rt_exp_org_id_tab.count;
    PA_DEBUG.g_err_stage := '1100A: aft Fetching Fcst cursor : '||l_rt_exp_org_id_tab.count;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    IF l_bulk_fetch_count = 0 THEN
       EXIT;
    END IF;
      /* Initial bill rate API will be called always, because of the
         billing client extn changes ( check for l_prj_revenue_bill_rate IS NULL
             is removed ) and Bill rate override in the Assignment level */
      l_prj_revenue_bill_rate := NULL;
         /* Added for Org Forecasting changes */
         BEGIN
           SELECT EXPENDITURE_TYPE_CLASS INTO l_system_linkage FROM
           Pa_Forecast_Items WHERE
           Forecast_Item_Id = l_rt_forecast_item_id_tab(1);
           EXCEPTION
           WHEN NO_DATA_FOUND THEN
             PA_DEBUG.g_err_stage := 'no data found in FI while getting exp type class';
             PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
             UPDATE_BUDG_VERSION(p_budget_version_id => l_budget_version_id );
             RAISE;
         END;
         /* Added for Org Forecasting changes */
      IF l_role_error_code IS NULL THEN
        BEGIN
          PA_DEBUG.g_err_stage := '1105: before calling init bill rate';
          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
          PA_RATE_PVT_PKG.get_initial_bill_rate(
                        p_assignment_type               => l_prj_short_assignment_type,
                        p_asgn_start_date               => l_prj_start_date,
                        p_project_id                    => p_project_id,
                        p_quantity                      => 1,
                        p_expenditure_org_id            => l_rt_exp_org_id_tab(1),
                        p_expenditure_type              => l_prj_exp_type,
                        p_expenditure_organization_id   => l_rt_exp_organization_id_tab(1),
                        p_person_id                     => l_prj_person_id,
                        p_assignment_id                 => l_prj_assignment_id,
                        p_forecast_item_id              => l_rt_forecast_item_id_tab(1),
                        p_forecast_job_id               => l_prj_fcst_job_id,
                        p_forecast_job_group_id         => l_prj_fcst_job_group_id,
                        p_project_org_id                => l_org_id,
                        p_expenditure_currency_code     => NULL,
                        p_project_type                  => l_project_type,
                        p_task_id                       => NULL,
                        p_bill_rate_multiplier          => NULL,
                        p_project_bill_job_group_id     => l_bill_job_group_id,
                        p_emp_bill_rate_schedule_id     => l_emp_bill_rate_schedule_id,
                        p_job_bill_rate_schedule_id     => l_job_bill_rate_schedule_id,
                        x_projfunc_bill_rate                => l_prj_revenue_bill_rate,
                        x_projfunc_raw_revenue              => l_std_raw_revenue,
                        x_rev_currency_code             => l_rev_currency_code,
                        x_markup_percentage             => l_markup_percentage,
                        x_return_status                 => x_return_status,
                        x_msg_count                     => x_msg_count,
                        x_msg_data                      => x_msg_data,
                        p_forecasting_type              => 'PROJECT_FORECASTING',
                        p_assign_precedes_task          => l_asg_precedes_task,
                        p_system_linkage                => l_system_linkage,
                        p_labor_schdl_discnt            => l_labor_sch_discount,
                        p_labor_bill_rate_org_id        => l_labor_bill_rate_orgid,
                        p_labor_std_bill_rate_schdl     => l_labor_std_bill_rate_sch,
                        p_labor_schedule_fixed_date     => l_labor_sch_fixed_dt,
                        p_labor_sch_type                => l_labor_sch_type,
                        p_projfunc_currency_code        => l_projfunc_currency_code,
                        p_projfunc_rev_rt_dt_code       => l_projfunc_bil_rate_date_code,
                        p_projfunc_rev_rt_date          => l_projfunc_bil_rate_date,
                        p_projfunc_rev_rt_type          => l_projfunc_bil_rate_type,
                        p_projfunc_rev_exch_rt          => l_projfunc_bil_exchange_rate,
                        p_projfunc_cst_rt_date          => l_prjfunc_cost_rate_date,
                        p_projfunc_cst_rt_type          => l_prjfunc_cost_rate_type,
                        p_project_currency_code         => l_project_currency_code,
                        p_project_rev_rt_dt_code        => l_prj_bil_rate_date_code,
                        p_project_rev_rt_date           => l_prj_bil_rate_date,
                        p_project_rev_rt_type           => l_prj_bil_rate_type,
                        p_project_rev_exch_rt           => l_prj_bil_ex_rate,
                        p_project_cst_rt_date           => l_prj_rate_date,
                        p_project_cst_rt_type           => l_prj_rate_type           );

           PA_DEBUG.g_err_stage := '1105: after calling init bill rate';
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
         EXCEPTION
         WHEN OTHERS THEN
           UPDATE_BUDG_VERSION(p_budget_version_id => l_budget_version_id );
           RAISE;
         END;
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
           l_plan_processing_code := 'E';
           l_role_error_code      := SUBSTR(x_msg_data,1,30);
         END IF;
      END IF;

      l_init_bill_rate_flag := 'Y';

    l_error_msg := NULL;
    l_projfunc_raw_revenue   := 0;
    l_projfunc_raw_cost      := 0;
    l_projfunc_raw_cost_rate := 0;
    l_projfunc_burdened_cost := 0;
     /* Rate API should not be called if any role level error occurs for REQUIREMENT but
        not for  STAFFED ASSIGNMENT */
     IF l_role_error_code_flag = 'N' THEN
       BEGIN
         /* Added for Org Forecasting changes */
         BEGIN
           SELECT EXPENDITURE_TYPE_CLASS INTO l_system_linkage FROM
           Pa_Forecast_Items WHERE
           Forecast_Item_Id = l_rt_forecast_item_id_tab(1);
           EXCEPTION
           WHEN NO_DATA_FOUND THEN
             PA_DEBUG.g_err_stage := 'no data found in FI while getting exp type class';
             PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
             UPDATE_BUDG_VERSION(p_budget_version_id => l_budget_version_id );
             RAISE;
         END;
         l_rt_system_linkage_tab.delete;
         l_rt_pfunc_rev_rt_dt_code_tab.delete;
         l_rt_pfunc_rev_rt_date_tab.delete;
         l_rt_pfunc_rev_rt_type_tab.delete;
         l_rt_pfunc_rev_ex_rt_tab.delete;
         l_rt_pfunc_cost_rt_date_tab.delete;
         l_rt_pfunc_cost_rt_type_tab.delete;
         l_rt_proj_rev_rt_dt_code_tab.delete;
         l_rt_proj_rev_rt_date_tab.delete;
         l_rt_proj_rev_rt_type_tab.delete;
         l_rt_proj_rev_ex_rt_tab.delete;
         l_rt_proj_cost_rt_date_tab.delete;
         l_rt_proj_cost_rt_type_tab.delete;

         FOR l_tmp_idx IN 1 .. l_rt_start_date_tab.COUNT LOOP
           l_rt_system_linkage_tab(l_tmp_idx) := l_system_linkage;

           l_rt_pfunc_rev_rt_dt_code_tab(l_tmp_idx) := l_projfunc_bil_rate_date_code;
           l_rt_pfunc_rev_rt_date_tab(l_tmp_idx) := l_projfunc_bil_rate_date;
           l_rt_pfunc_rev_rt_type_tab(l_tmp_idx) := l_projfunc_bil_rate_type;
           l_rt_pfunc_rev_ex_rt_tab(l_tmp_idx) := l_projfunc_bil_exchange_rate;
           l_rt_pfunc_cost_rt_date_tab(l_tmp_idx) := l_prjfunc_cost_rate_date;
           l_rt_pfunc_cost_rt_type_tab(l_tmp_idx) := l_prjfunc_cost_rate_type;

           l_rt_proj_rev_rt_dt_code_tab(l_tmp_idx) := l_prj_bil_rate_date_code;
           l_rt_proj_rev_rt_date_tab(l_tmp_idx) := l_prj_bil_rate_date;
           l_rt_proj_rev_rt_type_tab(l_tmp_idx) := l_prj_bil_rate_type;
           l_rt_proj_rev_ex_rt_tab(l_tmp_idx) := l_prj_bil_ex_rate;
           l_rt_proj_cost_rt_date_tab(l_tmp_idx) := l_prj_rate_date;
           l_rt_proj_cost_rt_type_tab(l_tmp_idx) := l_prj_rate_type;
           l_rt_others_rejct_reason_tab(l_tmp_idx) := NULL;
         END LOOP;
         /* Added for Org Forecasting changes */

         PA_DEBUG.g_err_stage := '1200: bef calling RATE API calc_rate_amount ';
         PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
         /* dbms_output.put_line('bef calling Rate API ');
         dbms_output.put_line('st dt :'||l_rt_start_date_tab.count);
         dbms_output.put_line(' p_projfunc_rev_rt_dt_code_tab ' || l_rt_pfunc_rev_rt_dt_code_tab.COUNT);
         dbms_output.put_line(' p_projfunc_rev_rt_date_tab    ' || l_rt_pfunc_rev_rt_date_tab.COUNT);
         dbms_output.put_line(' p_projfunc_rev_rt_type_tab    ' || l_rt_pfunc_rev_rt_type_tab.COUNT);
         dbms_output.put_line(' p_projfunc_rev_exch_rt_tab    ' || l_rt_pfunc_rev_ex_rt_tab.COUNT);
         dbms_output.put_line(' p_projfunc_cst_rt_date_tab    ' || l_rt_pfunc_cost_rt_date_tab.COUNT);
         dbms_output.put_line(' p_projfunc_cst_rt_type_tab    ' || l_rt_pfunc_cost_rt_type_tab.COUNT);
         dbms_output.put_line(' x_projfunc_rev_rt_date_tab    ' || lx_rt_pfunc_cost_rt_date_tab.COUNT);
         dbms_output.put_line(' x_projfunc_rev_rt_type_tab    ' || lx_rt_pfunc_rev_rt_type_tab.COUNT);
         dbms_output.put_line(' x_projfunc_rev_exch_rt_tab    ' || lx_rt_pfunc_rev_ex_rt_tab.COUNT);
         dbms_output.put_line(' x_projfunc_cst_rt_date_tab    ' || lx_rt_pfunc_cost_rt_date_tab.COUNT);
         dbms_output.put_line(' x_projfunc_cst_rt_type_tab    ' || lx_rt_pfunc_cost_rt_type_tab.COUNT);
         dbms_output.put_line(' x_projfunc_cst_exch_rt_tab    ' || lx_rt_pfunc_cost_ex_rt_tab.COUNT);
         dbms_output.put_line(' p_project_rev_rt_dt_code_tab  ' || l_rt_proj_rev_rt_dt_code_tab.COUNT);
         dbms_output.put_line(' p_project_rev_rt_date_tab     ' || l_rt_proj_rev_rt_date_tab.COUNT);
         dbms_output.put_line(' p_project_rev_rt_type_tab     ' || l_rt_proj_rev_rt_type_tab.COUNT);
         dbms_output.put_line(' p_project_rev_exch_rt_tab     ' || l_rt_proj_rev_ex_rt_tab.COUNT);
         dbms_output.put_line(' p_project_cst_rt_date_tab     ' || l_rt_proj_cost_rt_date_tab.COUNT);
         dbms_output.put_line(' p_project_cst_rt_type_tab     ' || l_rt_proj_cost_rt_type_tab.COUNT); */
         PA_RATE_PVT_PKG.Calc_Rate_Amount(
                         P_CALLING_MODE                   =>  l_calling_mode,
                         P_RATE_CALC_DATE_TAB             =>  l_rt_start_date_tab,
                         P_ITEM_ID                        =>  l_prj_assignment_id,
                         P_ASGN_START_DATE                =>  l_prj_start_date,
                         P_PROJECT_ID                     =>  p_project_id,
                         P_FORECAST_ITEM_ID_TAB           =>  l_rt_forecast_item_id_tab,
                         P_QUANTITY_TAB                   =>  l_rt_qty_tab,
                         P_FORECAST_JOB_ID                =>  l_prj_fcst_job_id,
                         P_FORECAST_JOB_GROUP_ID          =>  l_prj_fcst_job_group_id,
                         P_PERSON_ID                      =>  l_prj_person_id,
                         P_EXPENDITURE_ORG_ID_TAB         =>  l_rt_exp_org_id_tab,
                         P_EXPENDITURE_TYPE               =>  l_prj_exp_type,
                         P_EXPENDITURE_ORGZ_ID_TAB        =>  l_rt_exp_organization_id_tab,
                         P_PROJECT_ORG_ID                 =>  l_org_id,
                         P_LABOR_COST_MULTI_NAME          => NULL,
                         P_PROJ_COST_JOB_GROUP_ID         => NULL,
                         P_JOB_COST_RATE_SCHEDULE_ID      => l_fcst_opt_jobcostrate_sch_id,
                         P_PROJECT_TYPE                   => l_project_type,
                         P_TASK_ID                        => NULL,
                         P_PROJFUNC_CURRENCY_CODE         => l_projfunc_currency_code,
                         P_BILL_RATE_MULTIPLIER           => NULL,
                         P_PROJECT_BILL_JOB_GROUP_ID      => l_bill_job_group_id,
                         P_EMP_BILL_RATE_SCHEDULE_ID      => l_emp_bill_rate_schedule_id,
                         P_JOB_BILL_RATE_SCHEDULE_ID      => l_job_bill_rate_schedule_id,
                         P_DISTRIBUTION_RULE              => l_distribution_rule,
                         p_amount_calc_mode               =>  'ALL',
                         P_system_linkage                 => l_rt_system_linkage_tab,
                         p_assign_precedes_task           => l_asg_precedes_task,
                         p_labor_schdl_discnt             => l_labor_sch_discount,
                         p_labor_bill_rate_org_id         => l_labor_bill_rate_orgid,
                         p_labor_std_bill_rate_schdl      => l_labor_std_bill_rate_sch,
                         p_labor_schedule_fixed_date      => l_labor_sch_fixed_dt,
                         p_labor_sch_type                 => l_labor_sch_type,
                         X_EXP_FUNC_RAW_CST_RT_TAB        => l_rt_exp_func_raw_cst_rt_tab,
                         X_EXP_FUNC_RAW_CST_TAB           => l_rt_exp_func_raw_cst_tab,
                         X_EXP_FUNC_BURDNED_CST_RT_TAB    => l_rt_exp_func_bur_cst_rt_tab,
                         X_EXP_FUNC_BURDNED_CST_TAB       => l_rt_exp_func_burdned_cst_tab,
                         X_PROJFUNC_BILL_RT_TAB               => l_rt_projfunc_bill_rt_tab,
                         X_PROJFUNC_RAW_REVENUE_TAB           => l_rt_projfunc_raw_revenue_tab,
                         X_PROJFUNC_RAW_CST_TAB               => l_rt_projfunc_raw_cst_tab,
                         X_PROJFUNC_RAW_CST_RT_TAB            => l_rt_projfunc_raw_cst_rt_tab,
                         X_PROJFUNC_BURDNED_CST_TAB           => l_rt_projfunc_burdned_cst_tab,
                         X_PROJFUNC_BURDNED_CST_RT_TAB        => l_rt_projfunc_bd_cst_rt_tab,
                         p_projfunc_rev_rt_dt_code_tab => l_rt_pfunc_rev_rt_dt_code_tab,
                         p_projfunc_rev_rt_date_tab    => l_rt_pfunc_rev_rt_date_tab,
                         p_projfunc_rev_rt_type_tab    => l_rt_pfunc_rev_rt_type_tab,
                         p_projfunc_rev_exch_rt_tab    => l_rt_pfunc_rev_ex_rt_tab,
                         p_projfunc_cst_rt_date_tab    => l_rt_pfunc_cost_rt_date_tab,
                         p_projfunc_cst_rt_type_tab    => l_rt_pfunc_cost_rt_type_tab,
                         x_projfunc_rev_rt_date_tab    => lx_rt_pfunc_rev_rt_date_tab,
                         x_projfunc_rev_rt_type_tab    => lx_rt_pfunc_rev_rt_type_tab,
                         x_projfunc_rev_exch_rt_tab    => lx_rt_pfunc_rev_ex_rt_tab,
                         x_projfunc_cst_rt_date_tab    => lx_rt_pfunc_cost_rt_date_tab,
                         x_projfunc_cst_rt_type_tab    => lx_rt_pfunc_cost_rt_type_tab,
                         x_projfunc_cst_exch_rt_tab    => lx_rt_pfunc_cost_ex_rt_tab,
                         p_project_currency_code       => l_project_currency_code,
                         p_project_rev_rt_dt_code_tab  => l_rt_proj_rev_rt_dt_code_tab,
                         p_project_rev_rt_date_tab     => l_rt_proj_rev_rt_date_tab,
                         p_project_rev_rt_type_tab     => l_rt_proj_rev_rt_type_tab,
                         p_project_rev_exch_rt_tab     => l_rt_proj_rev_ex_rt_tab,
                         p_project_cst_rt_date_tab     => l_rt_proj_cost_rt_date_tab,
                         p_project_cst_rt_type_tab     => l_rt_proj_cost_rt_type_tab,
                         x_project_bill_rt_tab         => lx_rt_proj_bill_rate_tab,
                         x_project_raw_revenue_tab     => lx_rt_proj_raw_revenue_tab,
                         x_project_rev_rt_date_tab     => lx_rt_proj_rev_rt_date_tab,
                         x_project_rev_rt_type_tab     => lx_rt_proj_rev_rt_type_tab,
                         x_project_rev_exch_rt_tab     => lx_rt_proj_rev_ex_rt_tab,
                         x_project_raw_cst_tab         => lx_rt_proj_raw_cost_tab,
                         x_project_raw_cst_rt_tab      => lx_rt_proj_raw_cost_rt_tab,
                         x_project_burdned_cst_tab     => lx_rt_proj_bd_cost_tab,
                         x_project_burdned_cst_rt_tab  => lx_rt_proj_bd_cost_rt_tab,
                         x_project_cst_rt_date_tab     => lx_rt_proj_cost_rt_date_tab,
                         x_project_cst_rt_type_tab     => lx_rt_proj_cost_rt_type_tab,
                         x_project_cst_exch_rt_tab     => lx_rt_proj_cost_ex_rt_tab,
                         x_exp_func_curr_code_tab      => lx_rt_expfunc_curr_code_tab,
                         x_exp_func_cst_rt_date_tab    => lx_rt_expfunc_cost_rt_date_tab,
                         x_exp_func_cst_rt_type_tab    => lx_rt_expfunc_cost_rt_type_tab,
                         x_exp_func_cst_exch_rt_tab    => lx_rt_expfunc_cost_ex_rt_tab,
                         x_cst_txn_curr_code_tab       => lx_rt_cost_txn_curr_code_tab,
                         x_txn_raw_cst_rt_tab          => lx_rt_txn_raw_cost_rt_tab,
                         x_txn_raw_cst_tab             => lx_rt_txn_raw_cost_tab,
                         x_txn_burdned_cst_rt_tab      => lx_rt_txn_bd_cost_rt_tab,
                         x_txn_burdned_cst_tab         => lx_rt_txn_bd_cost_tab,
                         x_rev_txn_curr_code_tab       => lx_rt_rev_txn_curr_code_tab,
                         x_txn_rev_bill_rt_tab         => lx_rt_txn_rev_bill_rt_tab,
                         x_txn_rev_raw_revenue_tab     => lx_rt_txn_raw_revenue_tab,
                         X_ERROR_MSG                      => l_error_msg,
                         X_REV_REJCT_REASON_TAB           => l_rt_rev_rejct_reason_tab,
                         X_CST_REJCT_REASON_TAB           => l_rt_cst_rejct_reason_tab,
                         X_BURDNED_REJCT_REASON_TAB       => l_rt_burdned_rejct_reason_tab,
                         X_OTHERS_REJCT_REASON_TAB        => l_rt_others_rejct_reason_tab,
                         X_RETURN_STATUS                  => x_return_status,
                         X_MSG_COUNT                      => x_msg_count,
                         X_MSG_DATA                       => x_msg_data  );
        /*Added for the bug 2420564*/
                      IF l_billable_flag = 'N' THEN
                           FOR l_rt_tab_cnt IN 1 .. l_rt_pd_name_tab.count LOOP
                        lx_rt_txn_raw_revenue_tab(l_rt_tab_cnt) := 0;
                        l_rt_projfunc_raw_revenue_tab(l_rt_tab_cnt) := 0;
                        lx_rt_proj_raw_revenue_tab(l_rt_tab_cnt) := 0;
                         END LOOP;
                         END IF;
         /*End of fix for bug 2420564*/

            /* dbms_output.put_line('aft calling Rate API '); */
            PA_DEBUG.g_err_stage := '1200: aft calling RATE API calc_rate_amount ';
            PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
         EXCEPTION
         WHEN OTHERS THEN
           UPDATE_BUDG_VERSION(p_budget_version_id => l_budget_version_id );
           RAISE;
         END;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          l_plan_processing_code := 'E';
          IF l_role_error_code IS NULL THEN
            l_role_error_code := 'PA_FCST_NO_DISP_ERR';
          END IF;
        END IF;

      /* The err msg PA_FCST_NO_DISP_ERR is used to show the error icon in the
         pages and the actual error messages will be stored in budget lines table. */

    END IF;

    FOR l_rt_tab_cnt IN 1 .. l_rt_pd_name_tab.count LOOP

      l_projfunc_raw_revenue   := 0;
      l_projfunc_raw_cost      := 0;
      l_projfunc_raw_cost_rate := 0;
      l_projfunc_burdened_cost := 0;
      l_fcst_item_quantity := 0;

      l_fcst_period_name       := l_rt_pd_name_tab(l_rt_tab_cnt);
      l_fcst_item_quantity     := l_rt_qty_tab(l_rt_tab_cnt);

      /* Bug 2084872 : Changed to check if data exists , b/c for Role level error
         Rate API will not be called and all the Rate API PL/SQL tables will be empty. */

      IF l_rt_projfunc_raw_revenue_tab.exists(l_rt_tab_cnt) THEN
        l_projfunc_raw_revenue       := NVL(l_rt_projfunc_raw_revenue_tab(l_rt_tab_cnt),0);
      ELSE
        l_projfunc_raw_revenue     := 0;
      END IF;
      IF l_rt_projfunc_raw_cst_tab.exists(l_rt_tab_cnt) THEN
        l_projfunc_raw_cost          := NVL(l_rt_projfunc_raw_cst_tab(l_rt_tab_cnt),0);
      ELSE
        l_projfunc_raw_cost          := 0;
      END IF;
      IF l_rt_projfunc_raw_cst_rt_tab.exists(l_rt_tab_cnt) THEN
        l_projfunc_raw_cost_rate     := NVL(l_rt_projfunc_raw_cst_rt_tab(l_rt_tab_cnt),0);
      ELSE
        l_projfunc_raw_cost_rate     := 0;
      END IF;
      IF l_rt_projfunc_burdned_cst_tab.exists(l_rt_tab_cnt) THEN
        l_projfunc_burdened_cost     := NVL(l_rt_projfunc_burdned_cst_tab(l_rt_tab_cnt),0);
      ELSE
        l_projfunc_burdened_cost     := 0;
      END IF;

      l_fcst_start_date        := l_rt_start_date_tab(l_rt_tab_cnt);
      l_fcst_end_date          := l_rt_end_date_tab(l_rt_tab_cnt);
      IF l_rt_cst_rejct_reason_tab.exists(l_rt_tab_cnt) THEN
        l_cost_reject_reason     := l_rt_cst_rejct_reason_tab(l_rt_tab_cnt);
      ELSE
         l_cost_reject_reason := NULL;
      END IF;
      IF l_rt_rev_rejct_reason_tab.exists(l_rt_tab_cnt) THEN
        l_rev_reject_reason      := l_rt_rev_rejct_reason_tab(l_rt_tab_cnt);
      ELSE
        l_rev_reject_reason := NULL;
      END IF;
      IF l_rt_burdned_rejct_reason_tab.exists(l_rt_tab_cnt) THEN
        l_burdened_reject_reason := l_rt_burdned_rejct_reason_tab(l_rt_tab_cnt);
      ELSE
        l_burdened_reject_reason := NULL;
      END IF;
      IF l_rt_others_rejct_reason_tab.exists(l_rt_tab_cnt) THEN
        l_other_reject_reason    := l_rt_others_rejct_reason_tab(l_rt_tab_cnt);
      ELSE
        l_other_reject_reason    := NULL;
      END IF;


    PA_DEBUG.g_err_stage := '1300: after  calling RATE API';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

    PA_DEBUG.g_err_stage := '1350: before checking in the PL/SQL TABLE';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

   l_period_name_flag := 'N';
   FOR l_cnt IN 1 .. l_budget_lines_tbl.COUNT LOOP
      IF l_budget_lines_tbl(l_cnt).period_name = l_fcst_period_name THEN
         l_budget_lines_tbl(l_cnt).raw_cost := l_budget_lines_tbl(l_cnt).raw_cost + l_projfunc_raw_cost;
         l_budget_lines_tbl(l_cnt).burdened_cost := l_budget_lines_tbl(l_cnt).burdened_cost
                                                   + l_projfunc_burdened_cost;
         l_budget_lines_tbl(l_cnt).revenue := l_budget_lines_tbl(l_cnt).revenue + l_projfunc_raw_revenue;
         l_budget_lines_tbl(l_cnt).quantity := l_budget_lines_tbl(l_cnt).quantity + l_fcst_item_quantity;
         l_period_name_flag := 'Y';
         EXIT;
      END IF;
   END LOOP;
   IF l_period_name_flag = 'N' THEN
     l_budget_lines_tbl(l_current_index).period_name := l_fcst_period_name;
     l_budget_lines_tbl(l_current_index).start_date := l_fcst_start_date;
     l_budget_lines_tbl(l_current_index).end_date:= l_fcst_end_date;
     l_budget_lines_tbl(l_current_index).raw_cost := l_projfunc_raw_cost;
     l_budget_lines_tbl(l_current_index).burdened_cost := l_projfunc_burdened_cost;
     l_budget_lines_tbl(l_current_index).quantity := l_fcst_item_quantity;
     l_budget_lines_tbl(l_current_index).revenue := l_projfunc_raw_revenue;
     l_budget_lines_tbl(l_current_index).cost_rejection_code := l_cost_reject_reason;
     l_budget_lines_tbl(l_current_index).revenue_rejection_code := l_rev_reject_reason;
     l_budget_lines_tbl(l_current_index).burden_rejection_code := l_burdened_reject_reason;
     l_budget_lines_tbl(l_current_index).other_rejection_code  := l_other_reject_reason;
     l_current_index := l_current_index + 1;
   END IF;

    PA_DEBUG.g_err_stage := '1400: after  checking in the PL/SQL TABLE';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

    PA_DEBUG.g_err_stage := '1450: before checking in the PL/SQL TABLE for TOTALS';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

    l_period_name_tot_flag := 'N';
   FOR l_cnt IN 1 .. l_budget_lines_tot_tbl.COUNT LOOP
      IF l_budget_lines_tot_tbl(l_cnt).period_name = l_fcst_period_name THEN
         l_budget_lines_tot_tbl(l_cnt).raw_cost := l_budget_lines_tot_tbl(l_cnt).raw_cost + l_projfunc_raw_cost;
         l_budget_lines_tot_tbl(l_cnt).burdened_cost := l_budget_lines_tot_tbl(l_cnt).burdened_cost
                                                   + l_projfunc_burdened_cost;
         l_budget_lines_tot_tbl(l_cnt).revenue := l_budget_lines_tot_tbl(l_cnt).revenue + l_projfunc_raw_revenue;
         l_budget_lines_tot_tbl(l_cnt).quantity := l_budget_lines_tot_tbl(l_cnt).quantity + l_fcst_item_quantity;
         l_period_name_tot_flag := 'Y';
         EXIT;
      END IF;
   END LOOP;
   IF l_period_name_tot_flag = 'N' THEN
     l_budget_lines_tot_tbl(l_current_index_tot).period_name := l_fcst_period_name;
     l_budget_lines_tot_tbl(l_current_index_tot).start_date := l_fcst_start_date;
     l_budget_lines_tot_tbl(l_current_index_tot).end_date:= l_fcst_end_date;
     l_budget_lines_tot_tbl(l_current_index_tot).raw_cost := l_projfunc_raw_cost;
     l_budget_lines_tot_tbl(l_current_index_tot).burdened_cost := l_projfunc_burdened_cost;
     l_budget_lines_tot_tbl(l_current_index_tot).quantity := l_fcst_item_quantity;
     l_budget_lines_tot_tbl(l_current_index_tot).revenue := l_projfunc_raw_revenue;
     l_current_index_tot := l_current_index_tot + 1;
   END IF;
   l_tot_quantity := l_tot_quantity + l_fcst_item_quantity;
   l_tot_cost     := l_tot_cost     + l_projfunc_raw_cost;
   l_tot_revenue  := l_tot_revenue  + l_projfunc_raw_revenue;
   l_tot_bcost    := l_tot_bcost    + l_projfunc_burdened_cost;

    PA_DEBUG.g_err_stage := '1500: before checking in the PL/SQL TABLE for TOTALS';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

  END LOOP;  -- after arriving at pdwise totals

/* Added for Bulk Insert     */
   /* The following logic is from the PA_BUDGET_LINES_V_PKG to take care of the
      bulk insert into PA_BUDGET_LINES for performance */

       BEGIN
           SELECT resource_assignment_id
               INTO   l_resource_assignment_id
               FROM   pa_resource_assignments a
               WHERE  a.budget_version_id = l_budget_version_id
               AND    a.project_id = p_project_id
               AND    nvl(a.task_id,0) = 0
               AND    a.resource_list_member_id = l_resource_list_member_id
               AND    a.project_assignment_id = l_prj_assignment_id;
       EXCEPTION
       WHEN NO_DATA_FOUND THEN
           SELECT pa_resource_assignments_s.nextval
           INTO l_resource_assignment_id
         FROM sys.dual;
         INSERT INTO pa_resource_assignments(
              resource_assignment_id,
              budget_version_id,
              project_id,
              task_id,
              resource_list_member_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              unit_of_measure,
              track_as_labor_flag,
              project_assignment_id,
              standard_bill_rate
             ) VALUES
            (     l_resource_assignment_id ,
                  l_budget_version_id,
                  p_project_id,
                  0,
                  l_resource_list_member_id,
                  SYSDATE,
                  l_created_by,
                  SYSDATE,
                  l_created_by,
                  l_request_id,
                  NULL,
                  NULL,
                  l_prj_assignment_id,
                  l_prj_revenue_bill_rate
          );
       END;

     l_bl_start_date_tab.delete;
     l_bl_end_date_tab.delete;
     l_bl_pd_name_tab.delete;
     l_bl_qty_tab.delete;
     l_bl_rcost_tab.delete;
     l_bl_revenue_tab.delete;
     l_bl_bcost_tab.delete;
     l_bl_cost_rej_tab.delete;
     l_bl_bcost_rej_tab.delete;
     l_bl_rev_rej_tab.delete;
     l_bl_oth_rej_tab.delete;


    PA_DEBUG.g_err_stage := '1525: bef populating  tabs for BL ins for RLM 101';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

    FOR l_counter IN 1 .. L_BUDGET_LINES_TBL.COUNT LOOP

    PA_DEBUG.g_err_stage := 'st dt :'||to_char(l_budget_lines_tbl(l_counter).start_date,
                                        'dd-mon-yyyy');
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        l_bl_start_date_tab(l_counter)   := l_budget_lines_tbl(l_counter).start_date;
        l_bl_end_date_tab(l_counter)     := l_budget_lines_tbl(l_counter).end_date;
        l_bl_pd_name_tab(l_counter)      := l_budget_lines_tbl(l_counter).period_name;
        l_bl_qty_tab(l_counter)          := l_budget_lines_tbl(l_counter).quantity;
        l_bl_rcost_tab(l_counter)        := l_budget_lines_tbl(l_counter).raw_cost;
        l_bl_bcost_tab(l_counter)        := l_budget_lines_tbl(l_counter).burdened_cost;
        l_bl_revenue_tab(l_counter)      := l_budget_lines_tbl(l_counter).revenue;
        l_bl_cost_rej_tab(l_counter)     := l_budget_lines_tbl(l_counter).cost_rejection_code;
        l_bl_bcost_rej_tab(l_counter)    := l_budget_lines_tbl(l_counter).burden_rejection_code;
        l_bl_rev_rej_tab(l_counter)      := l_budget_lines_tbl(l_counter).revenue_rejection_code;
        l_bl_oth_rej_tab(l_counter)      := l_budget_lines_tbl(l_counter).other_rejection_code;
    END LOOP;

    PA_DEBUG.g_err_stage := '1530: aft populating  tabs for BL ins for RLM 101 : ' ||
                                                       L_BUDGET_LINES_TBL.COUNT;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

    PA_DEBUG.g_err_stage := '1540: bef bulk ins into BL for RLM 101';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := 'res asg id  :'|| l_resource_assignment_id;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

    FORALL l_ins_temp IN 1 .. L_BUDGET_LINES_TBL.COUNT
       INSERT INTO PA_BUDGET_LINES(
                             BUDGET_LINE_ID,    /* FPB2 */
                             BUDGET_VERSION_ID, /* FPB2 */
                             RESOURCE_ASSIGNMENT_ID,
                             START_DATE            ,
                             LAST_UPDATE_DATE      ,
                             LAST_UPDATED_BY       ,
                             CREATION_DATE         ,
                             CREATED_BY            ,
                             LAST_UPDATE_LOGIN     ,
                             END_DATE              ,
                             PERIOD_NAME           ,
                             QUANTITY              ,
                             RAW_COST              ,
                             BURDENED_COST         ,
                             REVENUE               ,
                             COST_REJECTION_CODE   ,
                             REVENUE_REJECTION_CODE,
                             BURDEN_REJECTION_CODE ,
                             OTHER_REJECTION_CODE  ,
                             RAW_COST_SOURCE       ,
                             BURDENED_COST_SOURCE  ,
                             QUANTITY_SOURCE       ,
                             REVENUE_SOURCE        ,
                             TXN_CURRENCY_CODE     ) /* FPB2 - Bug 2753426 */
         VALUES (
                             pa_budget_lines_s.nextval,          /* FPB2 */
                             l_budget_version_id,       /* FPB2 */
                             l_resource_assignment_id,
                             l_bl_start_date_tab(l_ins_temp),
                             l_program_update_date,
                             l_created_by,
                             l_creation_date,
                             l_created_by,
                             l_request_id,
                             l_bl_end_date_tab(l_ins_temp),
                             l_bl_pd_name_tab(l_ins_temp),
                             l_bl_qty_tab(l_ins_temp),
                             l_bl_rcost_tab(l_ins_temp),
                             l_bl_bcost_tab(l_ins_temp),
                             l_bl_revenue_tab(l_ins_temp),
                             l_bl_cost_rej_tab(l_ins_temp),
                             l_bl_rev_rej_tab(l_ins_temp),
                             l_bl_bcost_rej_tab(l_ins_temp),
                             l_bl_oth_rej_tab(l_ins_temp)  ,
                             'M','M','M','M'                           ,
                             l_projfunc_currency_code);

	/*Code Changes for Bug No.2984871 start */
	l_rowcount:=sql%rowcount;
	/*Code Changes for Bug No.2984871 end */

    PA_DEBUG.g_err_stage := '1550: aft bulk ins into BL for RLM 101 : '||
                                                 l_rowcount;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    /* Bug 2984871: replaced sql%rowcount with l_rowcount */
    l_commit_cnt := l_commit_cnt + l_rowcount;
    IF l_commit_cnt >= l_commit_size THEN
      COMMIT;
      l_commit_cnt := 0;
    END IF;


/* Added for Bulk Insert     */


  /* Update only if some fis are processed for the current assignment id */
    IF  L_BUDGET_LINES_TBL.COUNT > 0 THEN
     UPDATE PA_RESOURCE_ASSIGNMENTS SET
     TOTAL_PLAN_REVENUE       = NVL(TOTAL_PLAN_REVENUE,0) + l_tot_revenue,
     TOTAL_PLAN_RAW_COST      = NVL(TOTAL_PLAN_RAW_COST,0) + l_tot_cost,
     TOTAL_PLAN_BURDENED_COST = NVL(TOTAL_PLAN_BURDENED_COST,0) + l_tot_bcost,
     TOTAL_PLAN_QUANTITY      = NVL(TOTAL_PLAN_QUANTITY,0) + l_tot_quantity,
     PLAN_ERROR_CODE          = l_role_error_code
     WHERE
     RESOURCE_ASSIGNMENT_ID = l_resource_assignment_id;

     l_tot_prj_revenue := l_tot_prj_revenue + l_tot_revenue;
     l_tot_prj_cost    := l_tot_prj_cost    + l_tot_cost;
     l_tot_prj_bcost   := l_tot_prj_bcost   + l_tot_bcost;
     l_tot_prj_quantity:= l_tot_prj_quantity+ l_tot_quantity;
    END IF;
    EXIT;
    /* the above exit is to avoid getting unique constraint error in PA_BUDGET_LINES,
       if there is no exit stmt. the bulk insert will try to do insert the same records  */
   END LOOP;
   /*  the above  dummy for loop is to avoid NO_DATA_FOUND error,
       if there are no fis to be proecessed   */

    /* the cursor should be closed regardless of fis are processed or not to avoid
           cursor already open error   */

    IF l_fcst_period_type = 'PA' THEN
      CLOSE FCST_PA;
    ELSE
      CLOSE FCST_GL;
    END IF;
  END IF;        -- l_process_fis_flag check


   IF l_commit_cnt >= l_commit_size THEN
      COMMIT;
      l_commit_cnt := 0;
   END IF;
  END LOOP;       -- for Assignments
  CLOSE PROJ_ASSIGNMENTS;
    PA_DEBUG.g_err_stage := '1800: after  fetching all project assignments records';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

  l_prj_res_assignment_id := NULL;
/* create res assignment record   for RLM Is 103 for storing Periodwise TOTALS */
    PA_DEBUG.g_err_stage := '1900: before getting RA Id for RLM Id 103';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
  IF l_budget_lines_tot_tbl.count > 0 THEN
    BEGIN
      SELECT RESOURCE_ASSIGNMENT_ID
               INTO   l_prj_res_assignment_id
               FROM   PA_RESOURCE_ASSIGNMENTS A
               WHERE  A.BUDGET_VERSION_ID = l_budget_version_id
               AND    A.PROJECT_ID = p_project_id
               AND    nvl(a.task_id,0) = 0             -- to make use of the index
               AND    A.PROJECT_ASSIGNMENT_ID = -1
               AND    A.RESOURCE_LIST_MEMBER_ID = 103;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        SELECT pa_resource_assignments_s.nextval
          INTO l_prj_res_assignment_id
        FROM sys.dual;
        insert into pa_resource_assignments(
              resource_assignment_id,
              budget_version_id,
              project_id,
              task_id,
              resource_list_member_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              unit_of_measure,
              track_as_labor_flag,
              project_assignment_id) VALUES
          (l_prj_res_Assignment_Id ,
                  l_budget_version_id,
                  p_project_id,
                  0,                     -- Task Id
                  103,                   -- RLM Id for project level totals
                  SYSDATE,
                  l_created_by,
                  SYSDATE,
                  l_created_by,
                  l_request_id,
                  NULL,                    -- x_unit_of_measure
                  NULL,
                    -1 );                  -- x_track_as_labor_flag
     END;

     PA_DEBUG.g_err_stage := '2000: after getting RA Id for RLM Id 103';
     PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
     /* Create budget lines to store periodwise totals from the table */

     PA_DEBUG.g_err_stage := '2100: bef populate tabs for ins into BL RLMId 103: '||
                             'BL tot tbl cnt:'||l_budget_lines_tot_tbl.count;
     PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

     l_bl_start_date_tab.delete;
     l_bl_end_date_tab.delete;
     l_bl_pd_name_tab.delete;
     l_bl_qty_tab.delete;
     l_bl_rcost_tab.delete;
     l_bl_revenue_tab.delete;
     l_bl_bcost_tab.delete;

     /* populating the tables for bulk insert  */

     FOR cnt_temp IN 1 .. l_budget_lines_tot_tbl.count LOOP

        l_bl_revenue_tab(cnt_temp)      := NULL;

        l_bl_start_date_tab(cnt_temp)   := l_budget_lines_tot_tbl(cnt_temp).start_date;
        l_bl_end_date_tab(cnt_temp)     := l_budget_lines_tot_tbl(cnt_temp).end_date;
        l_bl_pd_name_tab(cnt_temp)      := l_budget_lines_tot_tbl(cnt_temp).period_name;
        l_bl_qty_tab(cnt_temp)          := l_budget_lines_tot_tbl(cnt_temp).quantity;
        l_bl_rcost_tab(cnt_temp)        := l_budget_lines_tot_tbl(cnt_temp).raw_cost;
        l_bl_bcost_tab(cnt_temp)        := l_budget_lines_tot_tbl(cnt_temp).burdened_cost;
        IF l_rev_gen_method = 'T' THEN
           l_bl_revenue_tab(cnt_temp)      := l_budget_lines_tot_tbl(cnt_temp).revenue;
        END IF;
     END LOOP;

     PA_DEBUG.g_err_stage := '2125:aft populating tables for insert into BL RLMId 103 and bef bulk ins';
     PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

     FORALL l_ins_temp IN 1 .. l_budget_lines_tot_tbl.count
       INSERT INTO PA_BUDGET_LINES(
                             BUDGET_LINE_ID,            /* FPB2 */
                             BUDGET_VERSION_ID,         /* FPB2 */
                             RESOURCE_ASSIGNMENT_ID,
                             START_DATE            ,
                             LAST_UPDATE_DATE      ,
                             LAST_UPDATED_BY       ,
                             CREATION_DATE         ,
                             CREATED_BY            ,
                             LAST_UPDATE_LOGIN     ,
                             END_DATE              ,
                             PERIOD_NAME           ,
                             QUANTITY              ,
                             RAW_COST              ,
                             BURDENED_COST         ,
                             REVENUE               ,
                             RAW_COST_SOURCE       ,
                             BURDENED_COST_SOURCE  ,
                             QUANTITY_SOURCE       ,
                             REVENUE_SOURCE        ,
                             TXN_CURRENCY_CODE     ) /* FPB2 - Bug 2753426 */
         VALUES (
                             pa_budget_lines_s.nextval,          /* FPB2 */
                             l_budget_version_id,       /* FPB2 */
                             l_prj_res_assignment_id,
                             l_bl_start_date_tab(l_ins_temp),
                             l_program_update_date,
                             l_created_by,
                             l_creation_date,
                             l_created_by,
                             l_request_id,
                             l_bl_end_date_tab(l_ins_temp),
                             l_bl_pd_name_tab(l_ins_temp),
                             l_bl_qty_tab(l_ins_temp),
                             l_bl_rcost_tab(l_ins_temp),
                             l_bl_bcost_tab(l_ins_temp),
                             l_bl_revenue_tab(l_ins_temp),
                             'M','M','M','M'                  ,
                             l_projfunc_currency_code); /* FPB2 - Bug 2753426 */
	/*Code Changes for Bug No.2984871 start */
	   l_rowcount:=sql%rowcount;
	/*Code Changes for Bug No.2984871 end */
	   COMMIT;

     /* Bug 2984871: replaced SQL%ROWCOUNT with l_rowcount in the below line */
     PA_DEBUG.g_err_stage := '2200: after bulk inserting into BLines for RLMId 103:'||l_rowcount;
     PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

     PA_DEBUG.g_err_stage := '2300: before checking for REV GEN Md';
     PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

     IF l_rev_gen_method = 'E' THEN
       IF l_project_value IS NULL THEN
          PA_DEBUG.g_err_stage := '2400: no prj value : bef updating err msg in event Based';
          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

          UPDATE PA_RESOURCE_ASSIGNMENTS SET PLAN_ERROR_CODE  = 'PA_FCST_NO_PRJ_VALUE'
            WHERE
          RESOURCE_ASSIGNMENT_ID =l_prj_res_assignment_id;

          l_plan_processing_code := 'E';

          PA_DEBUG.g_err_stage := '2450: no prj value : aft updating err msg in event Based';
          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        ELSE
          l_prj_revenue_tab.delete;
          PA_DEBUG.g_err_stage := '2400: before calling PA_RATE_PVT_PKG.CALC_EVENT_BASED_REVENUE';
          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

          BEGIN
            PA_RATE_PVT_PKG.CALC_EVENT_BASED_REVENUE(
                       p_project_id                  => p_project_id,
                       p_rev_amt                     => l_project_value,
                       p_completion_date             => l_completion_date,
                       p_project_currency_code       => l_project_currency_code,
                       p_projfunc_currency_code      => l_projfunc_currency_code,
                       p_projfunc_bil_rate_date_code => l_projfunc_bil_rate_date_code,
                       px_projfunc_bil_rate_type     => l_projfunc_bil_rate_type,
                       px_projfunc_bil_rate_date     => l_projfunc_bil_rate_date,
                       px_projfunc_bil_exchange_rate => l_projfunc_bil_exchange_rate,
                       x_projfunc_revenue_tab        => l_prj_revenue_tab,
                       x_error_code                  => l_event_error_msg);
          EXCEPTION
          WHEN OTHERS THEN
            UPDATE_BUDG_VERSION( p_budget_version_id => l_budget_version_id );
            RAISE;
          END;

          PA_DEBUG.g_err_stage := '2450: after calling PA_RATE_PVT_PKG.CALC_EVENT_BASED_REVENUE';
          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
          IF l_event_error_msg IS NULL THEN
            PA_DEBUG.g_err_stage := '2500: before upserting in PA_BUDGET_LINES';
            PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

            FOR l_counter IN  1 .. l_prj_revenue_tab.count LOOP
              UPDATE PA_BUDGET_LINES SET REVENUE = l_prj_revenue_tab(l_counter).amount
                WHERE
              RESOURCE_ASSIGNMENT_ID =  l_prj_res_assignment_id AND
              PERIOD_NAME            =  l_prj_revenue_tab(l_counter).period_name;
              IF SQL%ROWCOUNT = 0 THEN

                 /* FPB2 */
                 select pa_budget_lines_s.nextval
                 into   l_budget_line_id
                 from   dual;

                INSERT INTO PA_BUDGET_LINES(
                        BUDGET_LINE_ID,         /* FPB2 */
                        BUDGET_VERSION_ID,      /* FPB2 */
                        RESOURCE_ASSIGNMENT_ID,
                        START_DATE,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        END_DATE,
                        PERIOD_NAME,
                        QUANTITY,
                        RAW_COST,
                        BURDENED_COST,
                        REVENUE,
                        TXN_CURRENCY_CODE) /* FPB2 - Bug 2753426 */
                  VALUES(
                    l_budget_line_id,           /* FPB2 */
                    l_budget_version_id,        /* FPB2 */
                    l_prj_res_assignment_id,
                    l_prj_revenue_tab(l_counter).start_date,
                    l_program_update_date,
                    l_created_by,
                    l_creation_date,
                    l_created_by,
                    l_request_id,
                    l_prj_revenue_tab(l_counter).end_date,
                    l_prj_revenue_tab(l_counter).period_name,
                    0,
                    0,
                    0,
                    l_prj_revenue_tab(l_counter).amount,
                    l_projfunc_currency_code); /* FPB2 - Bug 2753426 */
                END IF;
                l_commit_cnt := l_commit_cnt + 1;
                IF l_commit_cnt >= l_commit_size THEN
                  COMMIT;
                  l_commit_cnt := 0;
                END IF;

              END LOOP;
              PA_DEBUG.g_err_stage := '2600: after upserting in PA_BUDGET_LINES for event based';
              PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
         ELSE
           PA_DEBUG.g_err_stage := '2500: no prj value : bef updating err msg in Event Based';
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

           UPDATE PA_RESOURCE_ASSIGNMENTS SET PLAN_ERROR_CODE  = 'PA_FCST_PDS_NOT_DEFINED'
             WHERE
           RESOURCE_ASSIGNMENT_ID =l_prj_res_assignment_id;

           l_plan_processing_code := 'E';

           PA_DEBUG.g_err_stage := '2600: no prj value : aft updating err msg in Event Based';
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;  -- for if l_event_error_msg
       END IF;    -- if the project value is null
  ELSIF l_rev_gen_method = 'C' THEN
    IF l_project_value IS NOT NULL THEN
      l_cost_cnt := 1;
      l_prj_cost_tab.delete;
      l_prj_revenue_tab.delete;
      PA_DEBUG.g_err_stage := '2700: Inside REV GEN MD C - before fetching BUDGET_LINES into Table';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      OPEN BUDGET_LINES(l_budget_version_id,p_project_id,l_prj_res_assignment_id);
      LOOP
        FETCH BUDGET_LINES INTO l_prj_cost_tab(l_cost_cnt).period_name,
                              l_prj_cost_tab(l_cost_cnt).start_date,
                              l_prj_cost_tab(l_cost_cnt).amount;
         IF BUDGET_LINES%NOTFOUND THEN
            EXIT;
         END IF;
         l_cost_cnt := l_cost_cnt + 1;
      END LOOP;

      CLOSE BUDGET_LINES;

      PA_DEBUG.g_err_stage := '2750: after fetching BUDGET_LINES into PL/SQL table';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

      PA_DEBUG.g_err_stage := '2800: before calling PA_RATE_PVT_PKG.CALC_COST_BASED_REVENUE';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      l_cost_based_error_code := NULL;
      BEGIN
        PA_RATE_PVT_PKG.CALC_COST_BASED_REVENUE(
                        p_project_id                  => p_project_id,
                        p_rev_amt                     => l_project_value,
                        p_projfunc_cost_tab           => l_prj_cost_tab,
                        x_projfunc_revenue_tab        => l_prj_revenue_tab,
                        x_error_code                  => l_cost_based_error_code,
                        p_project_currency_code       => l_project_currency_code,
                        p_projfunc_currency_code      => l_projfunc_currency_code,
                        p_projfunc_bil_rate_date_code => l_projfunc_bil_rate_date_code,
                        px_projfunc_bil_rate_type     => l_projfunc_bil_rate_type,
                        px_projfunc_bil_rate_date     => l_projfunc_bil_rate_date,
                        px_projfunc_bil_exchange_rate => l_projfunc_bil_exchange_rate);
      EXCEPTION
      WHEN OTHERS THEN
        UPDATE_BUDG_VERSION( p_budget_version_id => l_budget_version_id );
        RAISE;
      END;

      PA_DEBUG.g_err_stage := '2850: after calling PA_RATE_PVT_PKG.CALC_COST_BASED_REVENUE';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      IF l_cost_based_error_code IS NULL THEN
        PA_DEBUG.g_err_stage := '2900: bef upd PA_BUDGET_LINES for COST_BASED_REVENUE';
        PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

        FOR l_cost_cnt IN 1 .. l_prj_revenue_tab.count LOOP
           UPDATE PA_BUDGET_LINES SET REVENUE = l_prj_revenue_tab(l_cost_cnt).amount
                  WHERE
            RESOURCE_ASSIGNMENT_ID =l_prj_res_assignment_id AND
            PERIOD_NAME            =l_prj_revenue_tab(l_cost_cnt).period_name;

            l_commit_cnt := l_commit_cnt + 1;
            IF l_commit_cnt >= l_commit_size THEN
               COMMIT;
               l_commit_cnt := 0;
            END IF;
        END LOOP;
        PA_DEBUG.g_err_stage := '2950: after updating PA_BUDGET_LINES for COST_BASED_REVENUE';
        PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      ELSE
        l_plan_processing_code := 'E';
        PA_DEBUG.g_err_stage := '2900: bef upd PA_RES_ASG for err code n  COST_BASED_REVENUE';
        PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        UPDATE PA_RESOURCE_ASSIGNMENTS SET PLAN_ERROR_CODE  = l_cost_based_error_code
          WHERE
        RESOURCE_ASSIGNMENT_ID =l_prj_res_assignment_id;
      END IF;
    ELSE
        PA_DEBUG.g_err_stage := '2900: no prj value : bef updating err msg in Cost Based';
        PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

        UPDATE PA_RESOURCE_ASSIGNMENTS SET PLAN_ERROR_CODE  = 'PA_FCST_NO_PRJ_VALUE'
          WHERE
        RESOURCE_ASSIGNMENT_ID =l_prj_res_assignment_id;

        l_plan_processing_code := 'E';

        PA_DEBUG.g_err_stage := '2950: no prj value : aft updating err msg in Cost Based';
        PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

     END IF;            --   project value not null
  END IF;               -- Rev gen method
  COMMIT;
    PA_DEBUG.g_err_stage := '3000: before updating PA_RESOURCE_ASSIGNMENTS for REVENUE';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

    /* Update Total Revenue in PA_RESOURCE_ASSIGNMENTS */

    UPDATE PA_RESOURCE_ASSIGNMENTS RA SET
      ( RA.TOTAL_PLAN_REVENUE,
        RA.TOTAL_PLAN_QUANTITY,
        RA.TOTAL_PLAN_RAW_COST,
        RA.TOTAL_PLAN_BURDENED_COST )
       = (SELECT SUM(BL.REVENUE),
                                                SUM(BL.QUANTITY),
                                                SUM(BL.RAW_COST),
                                                SUM(BL.BURDENED_COST) FROM
                                   PA_BUDGET_LINES BL WHERE
                                   BL.RESOURCE_ASSIGNMENT_ID = l_prj_res_assignment_id )
      WHERE RA.RESOURCE_ASSIGNMENT_ID = l_prj_res_assignment_id ;

    UPDATE PA_RESOURCE_ASSIGNMENTS RA SET
      AVERAGE_COST_RATE =
         DECODE(TOTAL_PLAN_BURDENED_COST,0,NULL,TOTAL_PLAN_BURDENED_COST ) / TOTAL_PLAN_QUANTITY,
      AVERAGE_BILL_RATE =
         DECODE(TOTAL_PLAN_REVENUE,0,NULL,TOTAL_PLAN_REVENUE )  / TOTAL_PLAN_QUANTITY
    WHERE
      BUDGET_VERSION_ID       = l_budget_version_id     AND
      TOTAL_PLAN_QUANTITY > 0;

    /* Calculate the STD bill rate for the Project Level   */

       SELECT SUM( DECODE(STANDARD_BILL_RATE,0,NULL,STANDARD_BILL_RATE) * TOTAL_PLAN_QUANTITY )
         INTO l_prj_level_revenue
       FROM PA_RESOURCE_ASSIGNMENTS
       WHERE
         BUDGET_VERSION_ID      =  l_budget_version_id     AND
         RESOURCE_ASSIGNMENT_ID <> l_prj_res_assignment_id;

      IF l_tot_prj_quantity > 0 AND l_prj_level_revenue IS NOT NULL THEN
        UPDATE PA_RESOURCE_ASSIGNMENTS SET
          STANDARD_BILL_RATE = l_prj_level_revenue  / l_tot_prj_quantity
        WHERE
          BUDGET_VERSION_ID       = l_budget_version_id     AND
          RESOURCE_ASSIGNMENT_ID  = l_prj_res_assignment_id;
      END IF;

    UPDATE PA_RESOURCE_ASSIGNMENTS RA SET
      AVERAGE_DISCOUNT_PERCENTAGE =
      ((STANDARD_BILL_RATE - AVERAGE_BILL_RATE)/STANDARD_BILL_RATE) * 100
    WHERE
      BUDGET_VERSION_ID       = l_budget_version_id     AND
      STANDARD_BILL_RATE      <> 0                       AND
      AVERAGE_BILL_RATE       <> 0;

    PA_DEBUG.g_err_stage := '3100: after updating PA_RESOURCE_ASSIGNMENTS for REVENUE';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

    PA_DEBUG.g_err_stage := '3200: before updating PA_BUDGET_VERSIONS for PLAN_PROCESSING_CODE';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

    UPDATE PA_BUDGET_VERSIONS SET PLAN_PROCESSING_CODE = l_plan_processing_code,
    PLAN_RUN_DATE = SYSDATE
    WHERE BUDGET_VERSION_ID = l_budget_version_id;

    PA_DEBUG.g_err_stage := '3300: after updating PA_BUDGET_VERSIONS for PLAN_PROCESSING_CODE';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
  ELSE                   -- else for l_budget_lines_tot_tbl.count greater than zero
    /* The budget version record will be deleted if no forecast lines are generated,
       this change is made to avoid the error from the page.    */
    DELETE  FROM PA_BUDGET_VERSIONS WHERE BUDGET_VERSION_ID = l_budget_version_id;
  END IF;   -- end if for l_budget_lines_tot_tbl.count greater than zero

  /* API call added for updating Average Bill rate in Project Assignments table. */
     l_prj_asg_id_tab.DELETE;
     l_avg_bill_rate_tab.DELETE;
     BEGIN
        /* we should avoid records with Project Assignment Id having the value of
           -1. This res asg record is used to store the project level totals. */
        SELECT project_assignment_id,
            ROUND(average_bill_rate,2) average_bill_rate
            BULK COLLECT INTO
            l_prj_asg_id_tab, l_avg_bill_rate_tab
            FROM pa_resource_assignments WHERE
            budget_version_id = l_budget_version_id AND
            project_assignment_id > 0 AND
            average_bill_rate IS NOT NULL;
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
          NULL;
     END;
     IF l_prj_asg_id_tab.COUNT > 0 THEN
        PA_ASSIGNMENTS_PVT.Update_Revenue_Bill_Rate(
                        p_assignment_id_tbl     => l_prj_asg_id_tab,
                        p_revenue_bill_rate_tbl => l_avg_bill_rate_tab,
                        x_return_status         => x_return_status );
     END IF;
  COMMIT;

   PA_GENERATE_FORECAST_PUB.Set_Error_Details(
                              p_return_status => l_ret_status,
                              x_msg_count     => l_msg_count,
                              x_msg_data      => l_msg_data,
                              x_data          => l_data,
                              x_msg_index_out => l_msg_index_out );
    x_msg_count     := l_msg_count;
    x_msg_data      := l_msg_data;
    x_return_status := l_ret_status;
    PA_DEBUG.g_err_stage := '3400: after Commiting';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
  PA_DEBUG.reset_err_stack;
  RETURN;
  EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    UPDATE_BUDG_VERSION( p_budget_version_id => l_budget_version_id );
    RAISE;
  END Generate_Forecast;

FUNCTION get_forecast_gen_date(p_project_id IN pa_projects_all.project_id%TYPE)
 RETURN DATE IS
 l_run_date DATE:= NULL;
BEGIN
   SELECT plan_run_date INTO l_run_date
   FROM pa_budget_versions
   WHERE project_id = p_project_id AND
   budget_type_code = 'FORECASTING_BUDGET_TYPE';
   RETURN l_run_date;
EXCEPTION
WHEN OTHERS THEN
     RETURN l_run_date;
END get_forecast_gen_date;

END PA_GENERATE_FORECAST_PUB;

/
