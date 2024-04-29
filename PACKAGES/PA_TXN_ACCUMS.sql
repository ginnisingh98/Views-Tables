--------------------------------------------------------
--  DDL for Package PA_TXN_ACCUMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TXN_ACCUMS" AUTHID CURRENT_USER AS
/* $Header: PATXNACS.pls 120.2 2006/11/10 19:35:03 degupta noship $ */

   -- Standard who
   x_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   x_last_update_date        NUMBER(15) := FND_GLOBAL.USER_ID;
   x_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
   x_last_update_login       NUMBER(15) := FND_GLOBAL.LOGIN_ID;
   x_request_id              NUMBER(15) := FND_GLOBAL.CONC_REQUEST_ID;
   x_program_application_id  NUMBER(15) := FND_GLOBAL.PROG_APPL_ID;
   x_program_id              NUMBER(15) := FND_GLOBAL.CONC_PROGRAM_ID;


   -- Variable to store the accumulation configuration

   raw_cost_flag                VARCHAR2(1);
   burdened_cost_flag           VARCHAR2(1);
   quantity_flag                VARCHAR2(1);
   labor_hours_flag             VARCHAR2(1);
   billable_raw_cost_flag       VARCHAR2(1);
   billable_burdened_cost_flag  VARCHAR2(1);
   billable_quantity_flag       VARCHAR2(1);
   billable_labor_hours_flag    VARCHAR2(1);
   revenue_flag                 VARCHAR2(1);
   cmt_raw_cost_flag            VARCHAR2(1);
   cmt_burdened_cost_flag       VARCHAR2(1);

   FUNCTION Initialize RETURN NUMBER;
   FUNCTION cmt_line_id RETURN NUMBER;

   pragma RESTRICT_REFERENCES (cmt_line_id, WNDS, WNPS );

   PROCEDURE get_accum_configurations
			( x_project_id              IN NUMBER,
			  x_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_code             IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE update_resource_flag
                      (x_start_project_id      IN  NUMBER,
                       x_end_project_id       IN  NUMBER,
                       x_start_pa_date        IN  DATE,
                       x_end_pa_date          IN  DATE,
                       x_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       x_err_code             IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE refresh_txn_accum
                        ( x_start_project_id        IN  NUMBER,
                          x_end_project_id          IN  NUMBER,
                          x_start_pa_date           IN  DATE,
                          x_end_pa_date             IN  DATE,
                          x_transaction_type        IN  VARCHAR2 DEFAULT NULL,
                          x_system_linkage_function IN  VARCHAR2 DEFAULT NULL,
			  x_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_code             IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE refresh_act_txn_accum
                        ( x_start_project_id        IN  NUMBER,
                          x_end_project_id          IN  NUMBER,
                          x_start_pa_date           IN  DATE,
                          x_end_pa_date             IN  DATE,
                          x_system_linkage_function IN  VARCHAR2 DEFAULT NULL,
			  x_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_code             IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE delete_act_txn_accum_details
                        ( x_start_project_id        IN  NUMBER,
                          x_end_project_id          IN  NUMBER,
                          x_start_pa_date           IN  DATE,
                          x_end_pa_date             IN  DATE,
                          x_system_linkage_function IN  VARCHAR2 DEFAULT NULL,
			  x_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_code             IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE refresh_rev_txn_accum
			( x_start_project_id        IN  NUMBER,
			  x_end_project_id          IN  NUMBER,
			  x_start_pa_date           IN  DATE,
			  x_end_pa_date             IN  DATE,
			  x_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			  x_err_code             IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE delete_rev_txn_accum_details
			( x_start_project_id        IN  NUMBER,
			  x_end_project_id          IN  NUMBER,
			  x_start_pa_date           IN  DATE,
			  x_end_pa_date             IN  DATE,
			  x_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			  x_err_code             IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE refresh_cmt_txn_accum
			( x_start_project_id        IN  NUMBER,
			  x_end_project_id          IN  NUMBER,
			  x_start_pa_date           IN  DATE,
			  x_end_pa_date             IN  DATE,
			  x_system_linkage_function IN  VARCHAR2 DEFAULT NULL,
			  x_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			  x_err_code             IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE update_act_txn_accum
                        ( x_start_project_id        IN  NUMBER,
                          x_end_project_id          IN  NUMBER,
                          x_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_code             IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE delete_cmt_txn_accum_details
			( x_start_project_id        IN  NUMBER,
			  x_end_project_id          IN  NUMBER,
			  x_start_pa_date           IN  DATE,
			  x_end_pa_date             IN  DATE,
			  x_system_linkage_function IN  VARCHAR2 DEFAULT NULL,
			  x_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			  x_err_code             IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

  PROCEDURE create_txn_accum_details
                         (x_txn_accum_id          IN  NUMBER,
                          x_line_type             IN  VARCHAR2,
                          x_expenditure_item_id   IN  NUMBER DEFAULT NULL,
                          x_line_num              IN  NUMBER DEFAULT NULL,
                          x_event_num             IN  NUMBER DEFAULT NULL,
                          x_cmt_line_id           IN  NUMBER DEFAULT NULL,
                          x_project_id            IN  NUMBER DEFAULT NULL,
                          x_task_id               IN  NUMBER DEFAULT NULL,
			  x_err_stage          IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_code           IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

  PROCEDURE create_txn_accum
		       ( x_project_id                IN  NUMBER,
		         x_task_Id                   IN  NUMBER,
		         x_pa_period                 IN  VARCHAR2,
		         x_gl_period                 IN  VARCHAR2,
		         x_week_ending_date          IN  DATE,
		         x_month_ending_date         IN  DATE,
		         x_person_id                 IN  NUMBER   DEFAULT NULL,
		         x_job_id                    IN  NUMBER   DEFAULT NULL,
		         x_vendor_id                 IN  VARCHAR2 DEFAULT NULL,
		         x_expenditure_type          IN  VARCHAR2 DEFAULT NULL,
		         x_organization_id           IN  NUMBER   DEFAULT NULL,
		         x_non_labor_resource        IN  VARCHAR2 DEFAULT NULL,
			 x_non_labor_resource_org_id IN  NUMBER   DEFAULT NULL,
		         x_expenditure_category      IN  VARCHAR2 DEFAULT NULL,
		         x_revenue_category          IN  VARCHAR2 DEFAULT NULL,
		         x_event_type                IN  VARCHAR2 DEFAULT NULL,
		         x_event_type_classification IN  VARCHAR2 DEFAULT NULL,
			 x_system_linkage_function   IN  VARCHAR2 DEFAULT NULL,
			 x_line_type                 IN  VARCHAR2 DEFAULT NULL,
			 x_cost_ind_compiled_set_id  IN  NUMBER   DEFAULT NULL,
			 x_rev_ind_compiled_set_id   IN  NUMBER   DEFAULT NULL,
			 x_inv_ind_compiled_set_id   IN  NUMBER   DEFAULT NULL,
			 x_cmt_ind_compiled_set_id   IN  NUMBER   DEFAULT NULL,
			 x_txn_accum_id           IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
			 x_err_stage              IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			 x_err_code               IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE delete_cmt_txns
			( x_start_project_id        IN  NUMBER,
			  x_end_project_id          IN  NUMBER,
			  x_start_pa_date           IN  DATE,
			  x_end_pa_date             IN  DATE,
			  x_system_linkage_function IN  VARCHAR2 DEFAULT NULL,
			  x_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			  x_err_code             IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

  PROCEDURE create_cmt_txns
			( x_start_project_id        IN  NUMBER,
			  x_end_project_id          IN  NUMBER,
			  x_system_linkage_function IN  VARCHAR2 DEFAULT NULL,
			  x_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			  x_err_code             IN OUT NOCOPY NUMBER,
                          x_use_tmp_table           IN  VARCHAR2 DEFAULT 'N'); --File.Sql.39 bug 4440895

  PROCEDURE accum_act_txn
                       ( x_txn_accum_id               IN  NUMBER,
                         x_tot_raw_cost               IN  NUMBER,
                         x_tot_burdened_cost          IN  NUMBER,
                         x_tot_quantity               IN  NUMBER,
                         x_tot_billable_raw_cost      IN  NUMBER,
                         x_tot_billable_burdened_cost IN  NUMBER,
                         x_tot_billable_quantity      IN  NUMBER,
                         x_unit_of_measure            IN  VARCHAR2,
			 x_err_stage               IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                         x_err_code                IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

  PROCEDURE accum_rev_txn
		       ( x_txn_accum_id           IN  NUMBER,
			 x_tot_revenue            IN  NUMBER,
                         x_unit_of_measure        IN  VARCHAR2,
			 x_err_stage           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			 x_err_code            IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

  PROCEDURE accum_cmt_txn
		       ( x_txn_accum_id           IN  NUMBER,
			 x_tot_cmt_raw_cost       IN  NUMBER,
			 x_tot_cmt_burdened_cost  IN  NUMBER,
			 x_err_stage           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			 x_err_code            IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895
  PROCEDURE accum_cdls
                        ( x_start_project_id        IN  NUMBER,
                          x_end_project_id          IN  NUMBER,
                          x_start_pa_date           IN  DATE,
                          x_end_pa_date             IN  DATE,
                          x_system_linkage_function IN  VARCHAR2 DEFAULT NULL,
			  x_mode                    IN  VARCHAR2 DEFAULT 'I',
                          x_cdl_line_type           IN  VARCHAR2 DEFAULT 'R', -- patchSet L Reburdening
			  x_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_code             IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895
  PROCEDURE accum_rdls
                        ( x_start_project_id        IN  NUMBER,
                          x_end_project_id          IN  NUMBER,
                          x_start_pa_date           IN  DATE,
                          x_end_pa_date             IN  DATE,
			  x_mode                    IN  VARCHAR2 DEFAULT 'I',
			  x_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_code             IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895
  PROCEDURE accum_erdls
                        ( x_start_project_id        IN  NUMBER,
                          x_end_project_id          IN  NUMBER,
                          x_start_pa_date           IN  DATE,
                          x_end_pa_date             IN  DATE,
			  x_mode                    IN  VARCHAR2 DEFAULT 'I',
			  x_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_code             IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895
  PROCEDURE accum_revenue
                        ( x_start_project_id        IN  NUMBER,
                          x_end_project_id          IN  NUMBER,
                          x_start_pa_date           IN  DATE,
                          x_end_pa_date             IN  DATE,
			  x_mode                    IN VARCHAR2  DEFAULT 'I',
			  x_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_code             IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

  PROCEDURE accum_commitments
                        ( x_start_project_id        IN  NUMBER,
                          x_end_project_id          IN  NUMBER,
                          x_system_linkage_function IN  VARCHAR2 DEFAULT NULL,
	            x_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_code             IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

END PA_TXN_ACCUMS;

 

/
