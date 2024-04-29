--------------------------------------------------------
--  DDL for Package GMS_BUDGET_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_BUDGET_CORE" AUTHID CURRENT_USER AS
-- $Header: gmsbubcs.pls 115.6 2002/11/28 08:06:03 srkotwal ship $

  g_project_start_date    date;

  procedure baseline (x_draft_version_id  	in     number,
                      x_mark_as_original  		in     varchar2,
		      x_verify_budget_rules	in	varchar2 default 'Y',
	              x_err_code          		in out NOCOPY number,
                      x_err_stage         		in out NOCOPY varchar2,
                      x_err_stack         		in out NOCOPY varchar2);

  procedure copy (x_src_version_id      in     number,
                  x_amount_change_pct   in     number,
                  x_rounding_precision  in     number,
                  x_shift_days          in     number,
                  x_dest_project_id     in     number,
                  x_dest_award_id	in     number,
                  x_dest_budget_type_code    in     varchar2,
                  x_err_code            in out NOCOPY number,
                  x_err_stage           in out NOCOPY varchar2,
                  x_err_stack           in out NOCOPY varchar2);

  procedure verify (x_budget_version_id   in     number,
                    x_err_code            in out NOCOPY number,
                    x_err_stage           in out NOCOPY varchar2,
                    x_err_stack           in out NOCOPY varchar2);

  procedure copy_lines (x_src_version_id      in     number,
                        x_amount_change_pct   in     number,
                        x_rounding_precision  in     number,
                        x_shift_days          in     number,
                        x_dest_version_id     in     number,
                        x_err_code            in out NOCOPY number,
                        x_err_stage           in out NOCOPY varchar2,
                        x_err_stack           in out NOCOPY varchar2,
                        x_pm_flag             in varchar2 default 'N') ;
  PROCEDURE start_end_period (
      x_project_id                  IN       NUMBER,
      x_award_id                    IN       NUMBER,
      x_version_id                  IN       NUMBER,
      x_current_budget_version_id   IN       NUMBER,
      x_budget_entry_method_code    IN       VARCHAR2,
      x_time_phase_type_code        IN       VARCHAR2,
      x_resource_list_id            IN       NUMBER,
      x_resource_list_name          IN       VARCHAR2,
      x_start_period_name           OUT NOCOPY      VARCHAR2,
      x_start_date                  IN OUT NOCOPY   DATE,
      x_end_period_name             OUT NOCOPY      VARCHAR2,
      x_end_date                    IN OUT NOCOPY   DATE,
      x_err_code                    IN OUT NOCOPY   NUMBER,
      x_err_stage                   IN OUT NOCOPY   VARCHAR2,
      x_err_stack                   IN OUT NOCOPY   VARCHAR2
   );

  procedure copy_actual (x_project_id		     in     number,
                         x_award_id		     in	    number,
			 x_version_id                in     number,
			 x_budget_entry_method_code  in     varchar2,
			 x_resource_list_id          in     number,
			 x_start_period		     in     varchar2,
			 x_end_period		     in     varchar2,
		         x_err_code                  in out NOCOPY number,
		         x_err_stage	  	     in out NOCOPY varchar2,
		         x_err_stack         	     in out NOCOPY varchar2,
                         x_funding_status            out NOCOPY    number); -- Bug 1831151
   PROCEDURE get_proj_txn_accum (
      x_project_id                  IN       NUMBER,
      x_task_id                     IN       NUMBER DEFAULT NULL,
      x_current_budget_version_id   IN       NUMBER,
      x_period_type                 IN       VARCHAR2 DEFAULT 'P',
      x_from_period_name            IN       VARCHAR2 DEFAULT NULL,
      x_prd_start_date              IN       DATE DEFAULT NULL,
      x_prd_end_date                IN       DATE DEFAULT NULL,
      x_burdened_cost               IN OUT NOCOPY   NUMBER,
      x_billable_burdened_cost      IN OUT NOCOPY   NUMBER,
      x_unit_of_measure             IN OUT NOCOPY   VARCHAR2,
      x_err_stage                   IN OUT NOCOPY   VARCHAR2,
      x_err_code                    IN OUT NOCOPY   NUMBER
   );

   PROCEDURE get_proj_res_accum (
      x_project_id                  IN       NUMBER,
      x_task_id                     IN       NUMBER DEFAULT NULL,
      x_current_budget_version_id   IN       NUMBER,
      x_resource_list_member_id     IN       NUMBER DEFAULT NULL,
      x_period_type                 IN       VARCHAR2 DEFAULT 'P',
      x_from_period_name            IN       VARCHAR2 DEFAULT NULL,
      x_prd_start_date              IN       DATE DEFAULT NULL,
      x_prd_end_date                IN       DATE DEFAULT NULL,
      x_burdened_cost               IN OUT NOCOPY   NUMBER,
      x_billable_burdened_cost      IN OUT NOCOPY   NUMBER,
      x_unit_of_measure             IN OUT NOCOPY   VARCHAR2,
      x_err_stage                   IN OUT NOCOPY   VARCHAR2,
      x_err_code                    IN OUT NOCOPY   NUMBER
   );

   PROCEDURE get_proj_accum_actuals (
      x_project_id                  IN       NUMBER,
      x_task_id                     IN       NUMBER DEFAULT NULL,
      x_current_budget_version_id   IN       NUMBER,
      x_resource_list_member_id     IN       NUMBER DEFAULT NULL,
      x_period_type                 IN       VARCHAR2 DEFAULT 'P',
      x_from_period_name            IN       VARCHAR2 DEFAULT NULL,
      x_prd_start_date              IN       DATE DEFAULT NULL,
      x_prd_end_date                IN       DATE DEFAULT NULL,
      x_burdened_cost               IN OUT NOCOPY   NUMBER,
      x_billable_burdened_cost      IN OUT NOCOPY   NUMBER,
      x_unit_of_measure             IN OUT NOCOPY   VARCHAR2,
      x_err_stage                   IN OUT NOCOPY   VARCHAR2,
      x_err_code                    IN OUT NOCOPY   NUMBER
   );


 procedure copy_draft_lines  (x_src_version_id           in     number,
                               x_time_phased_type_code    in     varchar2,
                               x_entry_level_code         in     varchar2,
                               x_dest_version_id          in     number,
                               x_err_code                 in out NOCOPY number,
                               x_err_stage                in out NOCOPY varchar2,
                               x_err_stack                in out NOCOPY varchar2,
                               x_pm_flag                  in     varchar2 );


END gms_budget_core;

 

/
