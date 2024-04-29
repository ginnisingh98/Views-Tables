--------------------------------------------------------
--  DDL for Package PA_PLAN_MATRIX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PLAN_MATRIX" AUTHID CURRENT_USER AS
/* $Header: PARPLMXS.pls 120.1 2005/08/19 16:58:12 mwasowic noship $ */
    TYPE amount_type_record IS RECORD( amount_type_code    varchar2(30),
                                       amount_subtype_code varchar2(30),
                                       amount_type_id      number(15),
                                       amount_subtype_id   number(15));

    TYPE amount_type_tabtyp IS TABLE OF AMOUNT_TYPE_RECORD INDEX BY BINARY_INTEGER;

    PROCEDURE Maintain_Plan_Matrix
    		      (
                       p_amount_type_tab   IN  pa_plan_matrix.amount_type_tabtyp,
                       p_period_profile_id IN  NUMBER,
                       p_prior_period_flag IN  VARCHAR2,
                       p_commit_Flag       IN  VARCHAR2 DEFAULT 'N',
                       x_return_status     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       x_msg_count         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       x_msg_data          OUT NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
                       p_budget_version_id IN  NUMBER,
                       p_project_id        IN  NUMBER,
                       p_debug_mode        IN VARCHAR2 DEFAULT 'N',
                       p_add_msg_in_stack  IN VARCHAR2 DEFAULT 'N',
                       p_calling_module	   IN VARCHAR2 DEFAULT 'ORG_FORECAST'
                      );

   PROCEDURE Get_Period_Info
     		       (
       			p_bucketing_period_code		IN VARCHAR2,
       			p_st_dt_4_st_pd			IN DATE,
       			p_st_dt_4_end_pd		IN DATE,
       			p_plan_period_type		IN VARCHAR2,
       			p_project_id			IN NUMBER,
       			p_budget_version_id		IN NUMBER,
       			p_resource_assignment_id 	IN NUMBER,
       			p_transaction_currency_code	IN VARCHAR2,
       			x_start_date			OUT NOCOPY DATE, --File.Sql.39 bug 4440895
       			x_end_date			OUT NOCOPY DATE, --File.Sql.39 bug 4440895
       			x_period_name			OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       			x_return_status     		OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     			x_msg_count         		OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data          		OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                       );

    PROCEDURE Populate_Budget_Lines
  		       (
  			p_bucketing_period_code		IN VARCHAR2,
  			p_st_dt_4_st_pd			IN DATE,
  			p_st_dt_4_end_pd		IN DATE,
  			p_plan_period_type		IN VARCHAR2,
  			p_project_id			IN NUMBER,
  			p_budget_version_id		IN NUMBER,
  			p_project_currency_code		IN VARCHAR2,
  			p_projfunc_currency_code	IN VARCHAR2,
  			x_return_status     		OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			x_msg_count         		OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data          		OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                       );

END Pa_Plan_Matrix;

 

/
