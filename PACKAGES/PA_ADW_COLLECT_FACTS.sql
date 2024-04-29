--------------------------------------------------------
--  DDL for Package PA_ADW_COLLECT_FACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ADW_COLLECT_FACTS" AUTHID CURRENT_USER AS
/* $Header: PAADWCFS.pls 120.1 2005/08/19 16:15:27 mwasowic noship $ */

   -- Standard who
   x_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   x_last_update_date        NUMBER(15) := FND_GLOBAL.USER_ID;
   x_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
   x_last_update_login       NUMBER(15) := FND_GLOBAL.LOGIN_ID;
   x_request_id              NUMBER(15) := FND_GLOBAL.CONC_REQUEST_ID;
   x_program_application_id  NUMBER(15) := FND_GLOBAL.PROG_APPL_ID;
   x_program_id              NUMBER(15) := FND_GLOBAL.CONC_PROGRAM_ID;


   FUNCTION Initialize RETURN NUMBER;

   PROCEDURE get_fact_act_cmts
                         (x_project_num_from     IN     VARCHAR2,
                          x_project_num_to       IN     VARCHAR2,
			  x_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_stack            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_code             IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE update_tasks_act_cmt
			 (x_task_id			IN NUMBER,
			  x_pa_period_key		IN VARCHAR2,
			  x_expense_organization_id	IN NUMBER,
			  x_owner_organization_id	IN NUMBER,
			  x_resource_list_member_id	IN NUMBER,
			  x_service_type_code		IN VARCHAR2,
			  x_expenditure_type		IN VARCHAR2,
			  x_user_col1			IN VARCHAR2,
			  x_user_col2			IN VARCHAR2,
			  x_user_col3			IN VARCHAR2,
			  x_user_col4			IN VARCHAR2,
			  x_user_col5			IN VARCHAR2,
			  x_user_col6			IN VARCHAR2,
			  x_user_col7			IN VARCHAR2,
			  x_user_col8			IN VARCHAR2,
			  x_user_col9			IN VARCHAR2,
			  x_user_col10			IN VARCHAR2,
			  x_accume_revenue		IN NUMBER,
			  x_accume_raw_cost		IN NUMBER,
			  x_accume_burdened_cost	IN NUMBER,
			  x_accume_quantity		IN NUMBER,
			  x_accume_labor_hours		IN NUMBER,
			  x_accume_billable_raw_cost	IN NUMBER,
			  x_acc_billable_burdened_cost	IN NUMBER,
			  x_accume_billable_quantity	IN NUMBER,
			  x_accume_billable_labor_hours	IN NUMBER,
			  x_accume_cmt_raw_cost		IN NUMBER,
			  x_accume_cmt_burdened_cost	IN NUMBER,
			  x_accume_cmt_quantity		IN NUMBER,
			  x_unit_of_measure		IN VARCHAR2,
                          x_err_stage                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_stack                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_code                    IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE update_prj_act_cmt
			 (x_project_id			IN NUMBER,
			  x_pa_period_key		IN VARCHAR2,
			  x_expense_organization_id	IN NUMBER,
			  x_owner_organization_id	IN NUMBER,
			  x_resource_list_member_id	IN NUMBER,
			  x_service_type_code		IN VARCHAR2,
			  x_expenditure_type		IN VARCHAR2,
			  x_user_col1			IN VARCHAR2,
			  x_user_col2			IN VARCHAR2,
			  x_user_col3			IN VARCHAR2,
			  x_user_col4			IN VARCHAR2,
			  x_user_col5			IN VARCHAR2,
			  x_user_col6			IN VARCHAR2,
			  x_user_col7			IN VARCHAR2,
			  x_user_col8			IN VARCHAR2,
			  x_user_col9			IN VARCHAR2,
			  x_user_col10			IN VARCHAR2,
			  x_accume_revenue		IN NUMBER,
			  x_accume_raw_cost		IN NUMBER,
			  x_accume_burdened_cost	IN NUMBER,
			  x_accume_quantity		IN NUMBER,
			  x_accume_labor_hours		IN NUMBER,
			  x_accume_billable_raw_cost	IN NUMBER,
			  x_acc_billable_burdened_cost	IN NUMBER,
			  x_accume_billable_quantity	IN NUMBER,
			  x_accume_billable_labor_hours	IN NUMBER,
			  x_accume_cmt_raw_cost		IN NUMBER,
			  x_accume_cmt_burdened_cost	IN NUMBER,
			  x_accume_cmt_quantity		IN NUMBER,
			  x_unit_of_measure		IN VARCHAR2,
                          x_err_stage                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_stack                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_code                    IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE get_fact_budgets
                         (x_project_num_from     IN     VARCHAR2,
                          x_project_num_to       IN     VARCHAR2,
			  x_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_stack            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_code             IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE update_tasks_budgets
			 (x_task_id			IN NUMBER,
			  x_pa_period_key		IN VARCHAR2,
			  x_budget_type_code       	IN VARCHAR2,
			  x_resource_list_member_id	IN NUMBER,
			  x_service_type_code		IN VARCHAR2,
                          x_owner_organization_id       IN NUMBER,
                          x_expenditure_type            IN VARCHAR2,
			  x_user_col1			IN VARCHAR2,
			  x_user_col2			IN VARCHAR2,
			  x_user_col3			IN VARCHAR2,
			  x_user_col4			IN VARCHAR2,
			  x_user_col5			IN VARCHAR2,
			  x_user_col6			IN VARCHAR2,
			  x_user_col7			IN VARCHAR2,
			  x_user_col8			IN VARCHAR2,
			  x_user_col9			IN VARCHAR2,
			  x_user_col10			IN VARCHAR2,
			  x_bgt_revenue		        IN NUMBER,
			  x_bgt_raw_cost		IN NUMBER,
			  x_bgt_burdened_cost	        IN NUMBER,
			  x_bgt_quantity		IN NUMBER,
			  x_bgt_labor_quantity		IN NUMBER,
			  x_bgt_unit_of_measure		IN VARCHAR2,
                          x_err_stage                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_stack                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_code                    IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE update_prj_budgets
			 (x_project_id			IN NUMBER,
			  x_pa_period_key		IN VARCHAR2,
			  x_budget_type_code       	IN VARCHAR2,
			  x_resource_list_member_id	IN NUMBER,
			  x_service_type_code		IN VARCHAR2,
                          x_owner_organization_id       IN NUMBER,
                          x_expenditure_type            IN VARCHAR2,
			  x_user_col1			IN VARCHAR2,
			  x_user_col2			IN VARCHAR2,
			  x_user_col3			IN VARCHAR2,
			  x_user_col4			IN VARCHAR2,
			  x_user_col5			IN VARCHAR2,
			  x_user_col6			IN VARCHAR2,
			  x_user_col7			IN VARCHAR2,
			  x_user_col8			IN VARCHAR2,
			  x_user_col9			IN VARCHAR2,
			  x_user_col10			IN VARCHAR2,
			  x_bgt_revenue		        IN NUMBER,
			  x_bgt_raw_cost		IN NUMBER,
			  x_bgt_burdened_cost	        IN NUMBER,
			  x_bgt_quantity		IN NUMBER,
			  x_bgt_labor_quantity		IN NUMBER,
			  x_bgt_unit_of_measure		IN VARCHAR2,
                          x_err_stage                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_stack                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_code                    IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

END PA_ADW_COLLECT_FACTS;

 

/
