--------------------------------------------------------
--  DDL for Package PA_FORECAST_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FORECAST_GLOBAL" AUTHID CURRENT_USER AS
/* $Header: PARFGGBS.pls 120.1 2005/08/19 16:51:34 mwasowic noship $ */
  TYPE G_implementation_details_rec
  IS RECORD (
             G_org_id                    pa_implementations.org_id%TYPE
            ,G_org_structure_version_id  pa_implementations.org_structure_version_id%TYPE
            ,G_start_organization_id     pa_implementations.start_organization_id%TYPE
            ,G_pa_period_type            pa_implementations.pa_period_type%TYPE
            ,G_gl_period_type            gl_sets_of_books.accounted_period_type%TYPE
            ,G_period_set_name           gl_sets_of_books.period_set_name%TYPE
            ,G_fcst_period_type          pa_implementations.pa_period_type%TYPE
            ,G_fcst_def_bem              pa_budget_versions.BUDGET_ENTRY_METHOD_CODE%TYPE
            ,G_fcst_res_list             pa_resource_lists.RESOURCE_LIST_ID%TYPE
            ,G_fcst_cost_rate_sch_id     pa_forecasting_options.JOB_COST_RATE_SCHEDULE_ID%TYPE
            );

  TYPE G_util_option_details_rec
  IS RECORD (
             G_gl_period_flag          pa_utilization_options.gl_period_flag%TYPE
            ,G_pa_period_flag          pa_utilization_options.pa_period_flag%TYPE
            ,G_ge_period_flag          pa_utilization_options.global_exp_period_flag%TYPE
            ,G_forecast_thru_date      pa_utilization_options.forecast_thru_date%TYPE
            ,G_actuals_thru_date       pa_utilization_options.actuals_thru_date%TYPE
            ,G_util_calc_method        VARCHAR2(30)
            );
TYPE G_who_columns_rec
  IS RECORD (
             G_last_updated_by          NUMBER(15)
            ,G_created_by               NUMBER(15)
            ,G_creation_date            DATE
            ,G_last_update_date         DATE
            ,G_last_update_login        NUMBER(15)
            ,G_program_application_id   NUMBER(15)
            ,G_request_id               NUMBER(15)
            ,G_program_id               NUMBER(15)
            );
  /*
   * Variable definitions for the Global Record types.
   */
  G_who_columns            G_who_columns_rec;
  G_implementation_details G_implementation_details_rec;

  G_fcst_global_flag    VARCHAR2(1);
  G_fcst_proceed_flag   VARCHAR2(1):= 'Y';

  PROCEDURE Initialize_Global(
                              x_msg_count     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_msg_data      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_ret_status IN OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
END PA_FORECAST_GLOBAL;
 

/
