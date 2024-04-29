--------------------------------------------------------
--  DDL for Package PA_ACCUM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ACCUM_API" AUTHID CURRENT_USER AS
/* $Header: PAAAPIS.pls 120.1 2005/08/19 16:13:22 mwasowic noship $ */
  -- Actuals accumulation API

  PROCEDURE get_proj_txn_accum
		 (x_project_id                IN         NUMBER,
		  x_task_id                   IN         NUMBER   DEFAULT NULL,
		  x_period_type               IN         VARCHAR2 DEFAULT 'P',
		  x_from_period_name          IN         VARCHAR2 DEFAULT NULL,
		  x_prd_start_date	      IN         DATE     DEFAULT NULL,
		  x_prd_end_date	      IN         DATE     DEFAULT NULL,
		  x_revenue                IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_raw_cost               IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_burdened_cost          IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_quantity               IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_labor_hours            IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_billable_raw_cost      IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_billable_burdened_cost IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_billable_quantity      IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_billable_labor_hours   IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_cmt_raw_cost           IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_cmt_burdened_cost      IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
                  x_unit_of_measure        IN OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_stage              IN OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_code               IN OUT        NOCOPY NUMBER); --File.Sql.39 bug 4440895

  PROCEDURE get_proj_res_accum
		 (x_project_id                IN         NUMBER,
		  x_task_id                   IN         NUMBER   DEFAULT NULL,
		  x_resource_list_member_id   IN         NUMBER   DEFAULT NULL,
		  x_period_type               IN         VARCHAR2 DEFAULT 'P',
		  x_from_period_name          IN         VARCHAR2 DEFAULT NULL,
		  x_prd_start_date	      IN         DATE     DEFAULT NULL,
		  x_prd_end_date	      IN         DATE     DEFAULT NULL,
		  x_revenue                IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_raw_cost               IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_burdened_cost          IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_quantity               IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_labor_hours            IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_billable_raw_cost      IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_billable_burdened_cost IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_billable_quantity      IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_billable_labor_hours   IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_cmt_raw_cost           IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_cmt_burdened_cost      IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_unit_of_measure        IN OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_stage              IN OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_code               IN OUT        NOCOPY NUMBER); --File.Sql.39 bug 4440895

  PROCEDURE get_proj_accum_actuals
		 (x_project_id                IN         NUMBER,
		  x_task_id                   IN         NUMBER   DEFAULT NULL,
		  x_resource_list_member_id   IN         NUMBER   DEFAULT NULL,
		  x_period_type               IN         VARCHAR2 DEFAULT 'P',
		  x_from_period_name          IN         VARCHAR2 DEFAULT NULL,
		  x_prd_start_date	      IN         DATE     DEFAULT NULL,
		  x_prd_end_date	      IN         DATE     DEFAULT NULL,
		  x_revenue                IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_raw_cost               IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_burdened_cost          IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_quantity               IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_labor_hours            IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_billable_raw_cost      IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_billable_burdened_cost IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_billable_quantity      IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_billable_labor_hours   IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_cmt_raw_cost           IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_cmt_burdened_cost      IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_unit_of_measure        IN OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_stage              IN OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_code               IN OUT        NOCOPY NUMBER); --File.Sql.39 bug 4440895

PROCEDURE get_proj_accum_budgets
		 (x_project_id              		IN         NUMBER,
		  x_task_id       			IN         NUMBER   DEFAULT NULL,
		  x_resource_list_member_id   	IN         NUMBER   DEFAULT NULL,
		  x_period_type               		IN         VARCHAR2 DEFAULT 'P',
		  x_from_period_name          	IN         VARCHAR2 DEFAULT NULL,
		  x_to_period_name            	IN         VARCHAR2 DEFAULT NULL,
		  x_budget_type_code		IN	VARCHAR2 DEFAULT NULL,
		  x_base_raw_cost                  	IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_base_burdened_cost             	IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_base_revenue                   	IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_base_quantity 		IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_base_labor_quantity            	IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_unit_of_measure 		IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		  x_orig_raw_cost                  	IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_orig_burdened_cost             	IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_orig_revenue                   	IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_orig_quantity                  	IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_orig_labor_quantity		IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_err_stage              		IN OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  	  x_err_code               		IN OUT        NOCOPY NUMBER); --File.Sql.39 bug 4440895


END PA_ACCUM_API;

 

/
