--------------------------------------------------------
--  DDL for Package PA_ACCUM_SRW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ACCUM_SRW" AUTHID CURRENT_USER AS
/* $Header: PAACSRWS.pls 120.1 2005/08/19 16:14:30 mwasowic noship $ */

   -- Standard who
   x_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   x_last_update_date        NUMBER(15) := FND_GLOBAL.USER_ID;
   x_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
   x_last_update_login       NUMBER(15) := FND_GLOBAL.LOGIN_ID;
   x_request_id              NUMBER(15) := FND_GLOBAL.CONC_REQUEST_ID;
   x_program_application_id  NUMBER(15) := FND_GLOBAL.PROG_APPL_ID;
   x_program_id              NUMBER(15) := FND_GLOBAL.CONC_PROGRAM_ID;

   TYPE numbertabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE periodtabtype IS TABLE OF pa_project_accum_headers.accum_period%TYPE
		      INDEX BY BINARY_INTEGER;
   TYPE budgettypetabtype IS TABLE OF pa_project_accum_budgets.budget_type_code%TYPE
		      INDEX BY BINARY_INTEGER;

   number_of_projects             BINARY_INTEGER :=0;

   FUNCTION get_number_of_projects RETURN NUMBER;

   -- define a PL/SQL table for each project to report for

   PROJECT_ID                     numbertabtype;

   -- Define a PL/SQL table for Each Number you want to report
   -- variables to hold the numbers before the processing is done

   ACCUM_PERIOD_PRE               periodtabtype;

   RAW_COST_ITD_PRE               numbertabtype;
   RAW_COST_YTD_PRE               numbertabtype;
   RAW_COST_PP_PRE                numbertabtype;
   RAW_COST_PTD_PRE               numbertabtype;
   BILLABLE_RAW_COST_ITD_PRE      numbertabtype;
   BILLABLE_RAW_COST_YTD_PRE      numbertabtype;
   BILLABLE_RAW_COST_PP_PRE       numbertabtype;
   BILLABLE_RAW_COST_PTD_PRE      numbertabtype;
   BURDENED_COST_ITD_PRE          numbertabtype;
   BURDENED_COST_YTD_PRE          numbertabtype;
   BURDENED_COST_PP_PRE           numbertabtype;
   BURDENED_COST_PTD_PRE          numbertabtype;
   BILLABLE_BURDENED_COST_ITD_PRE numbertabtype;
   BILLABLE_BURDENED_COST_YTD_PRE numbertabtype;
   BILLABLE_BURDENED_COST_PP_PRE  numbertabtype;
   BILLABLE_BURDENED_COST_PTD_PRE numbertabtype;
   QUANTITY_ITD_PRE               numbertabtype;
   QUANTITY_YTD_PRE               numbertabtype;
   QUANTITY_PP_PRE                numbertabtype;
   QUANTITY_PTD_PRE               numbertabtype;
   LABOR_HOURS_ITD_PRE            numbertabtype;
   LABOR_HOURS_YTD_PRE            numbertabtype;
   LABOR_HOURS_PP_PRE             numbertabtype;
   LABOR_HOURS_PTD_PRE            numbertabtype;
   BILLABLE_QUANTITY_ITD_PRE      numbertabtype;
   BILLABLE_QUANTITY_YTD_PRE      numbertabtype;
   BILLABLE_QUANTITY_PP_PRE       numbertabtype;
   BILLABLE_QUANTITY_PTD_PRE      numbertabtype;
   BILLABLE_LABOR_HOURS_ITD_PRE   numbertabtype;
   BILLABLE_LABOR_HOURS_YTD_PRE   numbertabtype;
   BILLABLE_LABOR_HOURS_PP_PRE    numbertabtype;
   BILLABLE_LABOR_HOURS_PTD_PRE   numbertabtype;
   REVENUE_ITD_PRE                numbertabtype;
   REVENUE_YTD_PRE                numbertabtype;
   REVENUE_PP_PRE                 numbertabtype;
   REVENUE_PTD_PRE                numbertabtype;

   -- Commitment figures

   CMT_RAW_COST_ITD_PRE           numbertabtype;
   CMT_RAW_COST_YTD_PRE           numbertabtype;
   CMT_RAW_COST_PP_PRE            numbertabtype;
   CMT_RAW_COST_PTD_PRE           numbertabtype;
   CMT_BURDENED_COST_ITD_PRE      numbertabtype;
   CMT_BURDENED_COST_YTD_PRE      numbertabtype;
   CMT_BURDENED_COST_PP_PRE       numbertabtype;
   CMT_BURDENED_COST_PTD_PRE      numbertabtype;
   CMT_QUANTITY_ITD_PRE           numbertabtype;
   CMT_QUANTITY_YTD_PRE           numbertabtype;
   CMT_QUANTITY_PP_PRE            numbertabtype;
   CMT_QUANTITY_PTD_PRE           numbertabtype;

   -- Post processing figures

   ACCUM_PERIOD_PST               periodtabtype;

   RAW_COST_ITD_PST               numbertabtype;
   RAW_COST_YTD_PST               numbertabtype;
   RAW_COST_PP_PST                numbertabtype;
   RAW_COST_PTD_PST               numbertabtype;
   BILLABLE_RAW_COST_ITD_PST      numbertabtype;
   BILLABLE_RAW_COST_YTD_PST      numbertabtype;
   BILLABLE_RAW_COST_PP_PST       numbertabtype;
   BILLABLE_RAW_COST_PTD_PST      numbertabtype;
   BURDENED_COST_ITD_PST          numbertabtype;
   BURDENED_COST_YTD_PST          numbertabtype;
   BURDENED_COST_PP_PST           numbertabtype;
   BURDENED_COST_PTD_PST          numbertabtype;
   BILLABLE_BURDENED_COST_ITD_PST numbertabtype;
   BILLABLE_BURDENED_COST_YTD_PST numbertabtype;
   BILLABLE_BURDENED_COST_PP_PST  numbertabtype;
   BILLABLE_BURDENED_COST_PTD_PST numbertabtype;
   QUANTITY_ITD_PST               numbertabtype;
   QUANTITY_YTD_PST               numbertabtype;
   QUANTITY_PP_PST                numbertabtype;
   QUANTITY_PTD_PST               numbertabtype;
   LABOR_HOURS_ITD_PST            numbertabtype;
   LABOR_HOURS_YTD_PST            numbertabtype;
   LABOR_HOURS_PP_PST             numbertabtype;
   LABOR_HOURS_PTD_PST            numbertabtype;
   BILLABLE_QUANTITY_ITD_PST      numbertabtype;
   BILLABLE_QUANTITY_YTD_PST      numbertabtype;
   BILLABLE_QUANTITY_PP_PST       numbertabtype;
   BILLABLE_QUANTITY_PTD_PST      numbertabtype;
   BILLABLE_LABOR_HOURS_ITD_PST   numbertabtype;
   BILLABLE_LABOR_HOURS_YTD_PST   numbertabtype;
   BILLABLE_LABOR_HOURS_PP_PST    numbertabtype;
   BILLABLE_LABOR_HOURS_PTD_PST   numbertabtype;
   REVENUE_ITD_PST                numbertabtype;
   REVENUE_YTD_PST                numbertabtype;
   REVENUE_PP_PST                 numbertabtype;
   REVENUE_PTD_PST                numbertabtype;

   -- Commitment figures

   CMT_RAW_COST_ITD_PST           numbertabtype;
   CMT_RAW_COST_YTD_PST           numbertabtype;
   CMT_RAW_COST_PP_PST            numbertabtype;
   CMT_RAW_COST_PTD_PST           numbertabtype;
   CMT_BURDENED_COST_ITD_PST      numbertabtype;
   CMT_BURDENED_COST_YTD_PST      numbertabtype;
   CMT_BURDENED_COST_PP_PST       numbertabtype;
   CMT_BURDENED_COST_PTD_PST      numbertabtype;
   CMT_QUANTITY_ITD_PST           numbertabtype;
   CMT_QUANTITY_YTD_PST           numbertabtype;
   CMT_QUANTITY_PP_PST            numbertabtype;
   CMT_QUANTITY_PTD_PST           numbertabtype;

   -- Budgets figure. Please note that there may be more
   -- than one budget for each project

   -- figures before processing

   number_of_budgets_pre          BINARY_INTEGER := 0;   -- Number of budgets found before accumlation
   FUNCTION get_number_of_budgets_pre RETURN NUMBER;     -- Number of budgets accumulated before processing

   PROJECT_ID_PRE                 numbertabtype;
   BUDGET_TYPE_CODE_PRE           budgettypetabtype;

   BASE_RAW_COST_ITD_PRE          numbertabtype;
   BASE_RAW_COST_YTD_PRE          numbertabtype;
   BASE_RAW_COST_PP_PRE           numbertabtype;
   BASE_RAW_COST_PTD_PRE          numbertabtype;
   BASE_BURDENED_COST_ITD_PRE     numbertabtype;
   BASE_BURDENED_COST_YTD_PRE     numbertabtype;
   BASE_BURDENED_COST_PP_PRE      numbertabtype;
   BASE_BURDENED_COST_PTD_PRE     numbertabtype;
   ORIG_RAW_COST_ITD_PRE          numbertabtype;
   ORIG_RAW_COST_YTD_PRE          numbertabtype;
   ORIG_RAW_COST_PP_PRE           numbertabtype;
   ORIG_RAW_COST_PTD_PRE          numbertabtype;
   ORIG_BURDENED_COST_ITD_PRE     numbertabtype;
   ORIG_BURDENED_COST_YTD_PRE     numbertabtype;
   ORIG_BURDENED_COST_PP_PRE      numbertabtype;
   ORIG_BURDENED_COST_PTD_PRE     numbertabtype;
   BASE_REVENUE_ITD_PRE           numbertabtype;
   BASE_REVENUE_YTD_PRE           numbertabtype;
   BASE_REVENUE_PP_PRE            numbertabtype;
   BASE_REVENUE_PTD_PRE           numbertabtype;
   ORIG_REVENUE_ITD_PRE           numbertabtype;
   ORIG_REVENUE_YTD_PRE           numbertabtype;
   ORIG_REVENUE_PP_PRE            numbertabtype;
   ORIG_REVENUE_PTD_PRE           numbertabtype;
   ORIG_LABOR_HOURS_ITD_PRE       numbertabtype;
   ORIG_LABOR_HOURS_YTD_PRE       numbertabtype;
   ORIG_LABOR_HOURS_PP_PRE        numbertabtype;
   ORIG_LABOR_HOURS_PTD_PRE       numbertabtype;
   BASE_LABOR_HOURS_ITD_PRE       numbertabtype;
   BASE_LABOR_HOURS_YTD_PRE       numbertabtype;
   BASE_LABOR_HOURS_PP_PRE        numbertabtype;
   BASE_LABOR_HOURS_PTD_PRE       numbertabtype;
   ORIG_QUANTITY_YTD_PRE          numbertabtype;
   ORIG_QUANTITY_ITD_PRE          numbertabtype;
   ORIG_QUANTITY_PP_PRE           numbertabtype;
   ORIG_QUANTITY_PTD_PRE          numbertabtype;
   BASE_QUANTITY_YTD_PRE          numbertabtype;
   BASE_QUANTITY_ITD_PRE          numbertabtype;
   BASE_QUANTITY_PP_PRE           numbertabtype;
   BASE_QUANTITY_PTD_PRE          numbertabtype;
   ORIG_LABOR_HOURS_TOT_PRE       numbertabtype;
   BASE_LABOR_HOURS_TOT_PRE       numbertabtype;
   ORIG_QUANTITY_TOT_PRE          numbertabtype;
   BASE_QUANTITY_TOT_PRE          numbertabtype;
   BASE_RAW_COST_TOT_PRE          numbertabtype;
   BASE_BURDENED_COST_TOT_PRE     numbertabtype;
   ORIG_RAW_COST_TOT_PRE          numbertabtype;
   ORIG_BURDENED_COST_TOT_PRE     numbertabtype;
   BASE_REVENUE_TOT_PRE           numbertabtype;
   ORIG_REVENUE_TOT_PRE           numbertabtype;

   --Figures after processing is done

   number_of_budgets_pst          BINARY_INTEGER := 0;   -- Number of budgets found after accumlation
   FUNCTION get_number_of_budgets_pst RETURN NUMBER;     -- Number of budgets accumulated after processing

   PROJECT_ID_PST                 numbertabtype;
   BUDGET_TYPE_CODE_PST           budgettypetabtype;

   BASE_RAW_COST_ITD_PST          numbertabtype;
   BASE_RAW_COST_YTD_PST          numbertabtype;
   BASE_RAW_COST_PP_PST           numbertabtype;
   BASE_RAW_COST_PTD_PST          numbertabtype;
   BASE_BURDENED_COST_ITD_PST     numbertabtype;
   BASE_BURDENED_COST_YTD_PST     numbertabtype;
   BASE_BURDENED_COST_PP_PST      numbertabtype;
   BASE_BURDENED_COST_PTD_PST     numbertabtype;
   ORIG_RAW_COST_ITD_PST          numbertabtype;
   ORIG_RAW_COST_YTD_PST          numbertabtype;
   ORIG_RAW_COST_PP_PST           numbertabtype;
   ORIG_RAW_COST_PTD_PST          numbertabtype;
   ORIG_BURDENED_COST_ITD_PST     numbertabtype;
   ORIG_BURDENED_COST_YTD_PST     numbertabtype;
   ORIG_BURDENED_COST_PP_PST      numbertabtype;
   ORIG_BURDENED_COST_PTD_PST     numbertabtype;
   BASE_REVENUE_ITD_PST           numbertabtype;
   BASE_REVENUE_YTD_PST           numbertabtype;
   BASE_REVENUE_PP_PST            numbertabtype;
   BASE_REVENUE_PTD_PST           numbertabtype;
   ORIG_REVENUE_ITD_PST           numbertabtype;
   ORIG_REVENUE_YTD_PST           numbertabtype;
   ORIG_REVENUE_PP_PST            numbertabtype;
   ORIG_REVENUE_PTD_PST           numbertabtype;
   ORIG_LABOR_HOURS_ITD_PST       numbertabtype;
   ORIG_LABOR_HOURS_YTD_PST       numbertabtype;
   ORIG_LABOR_HOURS_PP_PST        numbertabtype;
   ORIG_LABOR_HOURS_PTD_PST       numbertabtype;
   BASE_LABOR_HOURS_ITD_PST       numbertabtype;
   BASE_LABOR_HOURS_YTD_PST       numbertabtype;
   BASE_LABOR_HOURS_PP_PST        numbertabtype;
   BASE_LABOR_HOURS_PTD_PST       numbertabtype;
   ORIG_QUANTITY_YTD_PST          numbertabtype;
   ORIG_QUANTITY_ITD_PST          numbertabtype;
   ORIG_QUANTITY_PP_PST           numbertabtype;
   ORIG_QUANTITY_PTD_PST          numbertabtype;
   BASE_QUANTITY_YTD_PST          numbertabtype;
   BASE_QUANTITY_ITD_PST          numbertabtype;
   BASE_QUANTITY_PP_PST           numbertabtype;
   BASE_QUANTITY_PTD_PST          numbertabtype;
   ORIG_LABOR_HOURS_TOT_PST       numbertabtype;
   BASE_LABOR_HOURS_TOT_PST       numbertabtype;
   ORIG_QUANTITY_TOT_PST          numbertabtype;
   BASE_QUANTITY_TOT_PST          numbertabtype;
   BASE_RAW_COST_TOT_PST          numbertabtype;
   BASE_BURDENED_COST_TOT_PST     numbertabtype;
   ORIG_RAW_COST_TOT_PST          numbertabtype;
   ORIG_BURDENED_COST_TOT_PST     numbertabtype;
   BASE_REVENUE_TOT_PST           numbertabtype;
   ORIG_REVENUE_TOT_PST           numbertabtype;

   -- TXNS accumulation number

   -- Pre processing numbers

   TXN_RAW_COST_PRE               numbertabtype;
   TXN_BILLABLE_RAW_COST_PRE      numbertabtype;
   TXN_BURDENED_COST_PRE          numbertabtype;
   TXN_BILLABLE_BURDENED_COST_PRE numbertabtype;
   TXN_QUANTITY_PRE               numbertabtype;
   TXN_LABOR_HOURS_PRE            numbertabtype;
   TXN_BILLABLE_QUANTITY_PRE      numbertabtype;
   TXN_BILLABLE_LABOR_HOURS_PRE   numbertabtype;
   TXN_REVENUE_PRE                numbertabtype;

   -- Post processing numbers

   TXN_RAW_COST_PST               numbertabtype;
   TXN_BILLABLE_RAW_COST_PST      numbertabtype;
   TXN_BURDENED_COST_PST          numbertabtype;
   TXN_BILLABLE_BURDENED_COST_PST numbertabtype;
   TXN_QUANTITY_PST               numbertabtype;
   TXN_LABOR_HOURS_PST            numbertabtype;
   TXN_BILLABLE_QUANTITY_PST      numbertabtype;
   TXN_BILLABLE_LABOR_HOURS_PST   numbertabtype;
   TXN_REVENUE_PST                numbertabtype;

   PROCEDURE get_project_summary_numbers
                      (X_PROJECT_ACCUM_ID  IN NUMBER,
                       X_PRE_POST_FLAG     IN VARCHAR2,
                       X_TABLE_INDEX       IN NUMBER,
                       X_ERR_STACK      IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_ERR_STAGE      IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_ERR_CODE       IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE report_project_summary_numbers
		      (X_TABLE_INDEX IN NUMBER,
                       X_PROJECT_ID OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_ACCUM_PERIOD_B OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_RAW_COST_ITD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_RAW_COST_YTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_RAW_COST_PP_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_RAW_COST_PTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_RAW_COST_ITD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_RAW_COST_YTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_RAW_COST_PP_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_RAW_COST_PTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BURDENED_COST_ITD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BURDENED_COST_YTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BURDENED_COST_PP_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BURDENED_COST_PTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_BURDENED_COST_ITD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_BURDENED_COST_YTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_BURDENED_COST_PP_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_BURDENED_COST_PTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_QUANTITY_ITD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_QUANTITY_YTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_QUANTITY_PP_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_QUANTITY_PTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_LABOR_HOURS_ITD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_LABOR_HOURS_YTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_LABOR_HOURS_PP_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_LABOR_HOURS_PTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_QUANTITY_ITD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_QUANTITY_YTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_QUANTITY_PP_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_QUANTITY_PTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_LABOR_HOURS_ITD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_LABOR_HOURS_YTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_LABOR_HOURS_PP_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_LABOR_HOURS_PTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_REVENUE_ITD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_REVENUE_YTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_REVENUE_PP_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_REVENUE_PTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_CMT_RAW_COST_ITD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_CMT_RAW_COST_YTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_CMT_RAW_COST_PP_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_CMT_RAW_COST_PTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_CMT_BURDENED_COST_ITD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_CMT_BURDENED_COST_YTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_CMT_BURDENED_COST_PP_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_CMT_BURDENED_COST_PTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_CMT_QUANTITY_ITD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_CMT_QUANTITY_YTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_CMT_QUANTITY_PP_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_CMT_QUANTITY_PTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_ACCUM_PERIOD_A OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_RAW_COST_ITD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_RAW_COST_YTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_RAW_COST_PP_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_RAW_COST_PTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_RAW_COST_ITD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_RAW_COST_YTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_RAW_COST_PP_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_RAW_COST_PTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BURDENED_COST_ITD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BURDENED_COST_YTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BURDENED_COST_PP_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BURDENED_COST_PTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_BURDENED_COST_ITD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_BURDENED_COST_YTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_BURDENED_COST_PP_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_BURDENED_COST_PTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_QUANTITY_ITD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_QUANTITY_YTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_QUANTITY_PP_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_QUANTITY_PTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_LABOR_HOURS_ITD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_LABOR_HOURS_YTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_LABOR_HOURS_PP_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_LABOR_HOURS_PTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_QUANTITY_ITD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_QUANTITY_YTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_QUANTITY_PP_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_QUANTITY_PTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_LABOR_HOURS_ITD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_LABOR_HOURS_YTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_LABOR_HOURS_PP_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_LABOR_HOURS_PTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_REVENUE_ITD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_REVENUE_YTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_REVENUE_PP_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_REVENUE_PTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_CMT_RAW_COST_ITD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_CMT_RAW_COST_YTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_CMT_RAW_COST_PP_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_CMT_RAW_COST_PTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_CMT_BURDENED_COST_ITD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_CMT_BURDENED_COST_YTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_CMT_BURDENED_COST_PP_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_CMT_BURDENED_COST_PTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_CMT_QUANTITY_ITD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_CMT_QUANTITY_YTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_CMT_QUANTITY_PP_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_CMT_QUANTITY_PTD_A OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE get_project_budget_numbers
                      (X_PROJECT_ACCUM_ID  IN NUMBER,
		       X_PRE_POST_FLAG     IN VARCHAR2,
                       X_ERR_STACK      IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_ERR_STAGE      IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_ERR_CODE       IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE report_project_budget_numbers
		      (X_TABLE_INDEX IN NUMBER,
		       X_PROJECT_ID OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BUDGET_TYPE_CODE OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		       X_BASE_RAW_COST_ITD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_RAW_COST_YTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_RAW_COST_PP_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_RAW_COST_PTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_BURDENED_COST_ITD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_BURDENED_COST_YTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_BURDENED_COST_PP_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_BURDENED_COST_PTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_RAW_COST_ITD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_RAW_COST_YTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_RAW_COST_PP_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_RAW_COST_PTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_BURDENED_COST_ITD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_BURDENED_COST_YTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_BURDENED_COST_PP_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_BURDENED_COST_PTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_REVENUE_ITD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_REVENUE_YTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_REVENUE_PP_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_REVENUE_PTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_REVENUE_ITD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_REVENUE_YTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_REVENUE_PP_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_REVENUE_PTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_LABOR_HOURS_ITD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_LABOR_HOURS_YTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_LABOR_HOURS_PP_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_LABOR_HOURS_PTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_LABOR_HOURS_ITD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_LABOR_HOURS_YTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_LABOR_HOURS_PP_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_LABOR_HOURS_PTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_QUANTITY_YTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_QUANTITY_ITD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_QUANTITY_PP_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_QUANTITY_PTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_QUANTITY_YTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_QUANTITY_ITD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_QUANTITY_PP_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_QUANTITY_PTD_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_LABOR_HOURS_TOT_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_LABOR_HOURS_TOT_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_QUANTITY_TOT_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_QUANTITY_TOT_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_RAW_COST_TOT_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_BURDENED_COST_TOT_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_RAW_COST_TOT_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_BURDENED_COST_TOT_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_REVENUE_TOT_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_REVENUE_TOT_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_RAW_COST_ITD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_RAW_COST_YTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_RAW_COST_PP_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_RAW_COST_PTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_BURDENED_COST_ITD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_BURDENED_COST_YTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_BURDENED_COST_PP_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_BURDENED_COST_PTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_RAW_COST_ITD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_RAW_COST_YTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_RAW_COST_PP_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_RAW_COST_PTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_BURDENED_COST_ITD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_BURDENED_COST_YTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_BURDENED_COST_PP_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_BURDENED_COST_PTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_REVENUE_ITD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_REVENUE_YTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_REVENUE_PP_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_REVENUE_PTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_REVENUE_ITD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_REVENUE_YTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_REVENUE_PP_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_REVENUE_PTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_LABOR_HOURS_ITD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_LABOR_HOURS_YTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_LABOR_HOURS_PP_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_LABOR_HOURS_PTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_LABOR_HOURS_ITD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_LABOR_HOURS_YTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_LABOR_HOURS_PP_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_LABOR_HOURS_PTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_QUANTITY_YTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_QUANTITY_ITD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_QUANTITY_PP_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_QUANTITY_PTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_QUANTITY_YTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_QUANTITY_ITD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_QUANTITY_PP_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_QUANTITY_PTD_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_LABOR_HOURS_TOT_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_LABOR_HOURS_TOT_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_QUANTITY_TOT_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_QUANTITY_TOT_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_RAW_COST_TOT_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_BURDENED_COST_TOT_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_RAW_COST_TOT_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_BURDENED_COST_TOT_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_BASE_REVENUE_TOT_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		       X_ORIG_REVENUE_TOT_A OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
		       );

   PROCEDURE get_project_txn_numbers
                      (X_PROJECT_ID        IN NUMBER,
                       X_PRE_POST_FLAG     IN VARCHAR2,
                       X_TABLE_INDEX       IN NUMBER,
                       X_ERR_STACK      IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_ERR_STAGE      IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_ERR_CODE       IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE report_project_txn_numbers
		      (X_TABLE_INDEX IN NUMBER,
                       X_PROJECT_ID OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_RAW_COST_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_RAW_COST_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BURDENED_COST_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_BURDENED_COST_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_QUANTITY_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_LABOR_HOURS_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_QUANTITY_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_LABOR_HOURS_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_REVENUE_B OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_RAW_COST_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_RAW_COST_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BURDENED_COST_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_BURDENED_COST_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_QUANTITY_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_LABOR_HOURS_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_QUANTITY_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_BILLABLE_LABOR_HOURS_A OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_REVENUE_A OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

END PA_ACCUM_SRW;

 

/
