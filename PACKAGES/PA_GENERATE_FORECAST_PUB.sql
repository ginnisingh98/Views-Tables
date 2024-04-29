--------------------------------------------------------
--  DDL for Package PA_GENERATE_FORECAST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_GENERATE_FORECAST_PUB" AUTHID CURRENT_USER AS
/* $Header: PARRFGPS.pls 120.1 2005/08/19 17:00:19 mwasowic noship $ */
   TYPE Budget_Lines_Rec_Type
            IS RECORD(
                       PERIOD_NAME           PA_PERIODS.PERIOD_NAME%TYPE,
                       START_DATE            PA_PERIODS.START_DATE%TYPE,
                       END_DATE              PA_PERIODS.END_DATE%TYPE,
                       QUANTITY              PA_BUDGET_LINES.QUANTITY%TYPE,
                       RAW_COST              PA_BUDGET_LINES.RAW_COST%TYPE,
                       BURDENED_COST         PA_BUDGET_LINES.BURDENED_COST%TYPE,
                       REVENUE               PA_BUDGET_LINES.REVENUE%TYPE,
                       COST_REJECTION_CODE   PA_BUDGET_LINES.COST_REJECTION_CODE%TYPE,
                       BURDEN_REJECTION_CODE PA_BUDGET_LINES.BURDEN_REJECTION_CODE%TYPE,
                       REVENUE_REJECTION_CODE PA_BUDGET_LINES.REVENUE_REJECTION_CODE%TYPE,
                       OTHER_REJECTION_CODE   PA_BUDGET_LINES.REVENUE_REJECTION_CODE%TYPE,
                       ERROR_CODE            PA_RESOURCE_ASSIGNMENTS.PLAN_ERROR_CODE%TYPE);

 TYPE BUDGET_LINES_TBL_TYPE IS TABLE OF BUDGET_LINES_REC_TYPE
 INDEX BY BINARY_INTEGER;


  PROCEDURE Maintain_Budget_Version(p_project_id           IN  NUMBER,
                                    p_plan_processing_code IN  VARCHAR2,
                                    x_budget_version_id    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                    x_msg_count            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                    x_msg_data             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                    x_return_status        OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

  PROCEDURE Generate_Forecast(p_project_id       IN  NUMBER,
                              p_debug_mode       IN  VARCHAR2 DEFAULT 'N',
                              x_return_status    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_msg_count        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_msg_data         OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

  PROCEDURE Submit_Project_Forecast(p_project_id    IN  NUMBER,
                                    x_msg_count     OUT NOCOPY NUMBER,  --File.Sql.39 bug 4440895
                                    x_msg_data      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                    x_return_status OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

  PROCEDURE Set_Error_Details(p_return_status    IN  VARCHAR2,
                              x_msg_count        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_msg_data         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_data             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_msg_index_out    OUT NOCOPY NUMBER    ); --File.Sql.39 bug 4440895
  /* Global variables   */
 G_commit_cnt NUMBER := 500;
 FUNCTION get_forecast_gen_date(p_project_id IN pa_projects_all.project_id%TYPE)
 RETURN DATE;

END PA_GENERATE_FORECAST_PUB;
 

/
