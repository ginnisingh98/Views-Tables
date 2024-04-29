--------------------------------------------------------
--  DDL for Package PA_FORECASTING_OPTIONS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FORECASTING_OPTIONS_ALL_PKG" AUTHID CURRENT_USER AS
/* $Header: PARUTFRS.pls 120.2 2005/10/27 06:13:28 nkumbi noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
    x_org_id                            IN     NUMBER,
    /* Bug 4576715 begin */
    /* x_include_admin_proj_flag           IN     VARCHAR2,
    x_gl_period_flag                    IN     VARCHAR2,
    x_pa_period_flag                    IN     VARCHAR2,  */
    x_forecast_thru_date                  IN     DATE,
    x_actuals_thru_date                   IN     DATE,
    /* x_max_historical_versions           IN     NUMBER,
    x_util_calc_method                  IN     VARCHAR2,  */
    x_default_assign_exp_typ_class     IN     VARCHAR2,
    x_default_assign_exp_type           IN     VARCHAR2,
    x_default_tp_amount_type            IN     VARCHAR2,
    x_bill_unassign_time_flag           IN     VARCHAR2,
    x_nonbill_unassign_time_flag        IN     VARCHAR2,
    x_bill_unassign_proj_id             IN     NUMBER,
    x_bill_unassign_exp_type_class      IN     VARCHAR2,
    x_bill_unassign_exp_type            IN     VARCHAR2,
    x_nonbill_unassign_proj_id          IN     NUMBER,
    x_nonbill_unassign_exp_typ_cls      IN     VARCHAR2,
    x_nonbill_unassign_exp_type         IN     VARCHAR2,
    X_CREATION_DATE                     in     DATE,
    X_CREATED_BY                        in     NUMBER,
    X_LAST_UPDATE_DATE                  in     DATE,
    X_LAST_UPDATED_BY                   in     NUMBER,
    X_LAST_UPDATE_LOGIN                 in     NUMBER,
    /*FOLLOWING 3 NEW PARAMETERS ADDED MARCH 12,2001 BY NAVEEN GUPTA
    IN ORDER TO INSERT DATA FOR FIELDS KEY_MEMBER_ROLE_ID,JOB_COST_RATE_SCHEDULE_ID AND FORECAST_CLASS_CATEGORY
    RESPECTIVELY IN TABLE PA_FORECASTING_OPTIONS_ALL*/
    /* x_key_member_role_id                in     NUMBER, */
    x_job_cost_rate_schedule_id         in     NUMBER,
    /* x_forecast_class_category           in     VARCHAR2, */
    /* Bug 4576715 ends */
    x_org_fcst_period_type              in     VARCHAR2,
    x_start_period_name                 in     VARCHAR2,
    x_number_of_periods                 in     NUMBER,
    x_org_fcst_project_template_id      in     NUMBER,
    x_weighted_or_full_code             in     VARCHAR2
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    /* Bug 4576715 begin */
    /* x_include_admin_proj_flag           IN     VARCHAR2,
    x_gl_period_flag                    IN     VARCHAR2,
    x_pa_period_flag                    IN     VARCHAR2, */
    x_forecast_thru_date                IN     DATE,
    x_actuals_thru_date                 IN     DATE,
    /* x_max_historical_versions           IN     NUMBER,
    x_util_calc_method                  IN     VARCHAR2, */
    x_default_assign_exp_typ_class     IN     VARCHAR2,
    x_default_assign_exp_type           IN     VARCHAR2,
    x_default_tp_amount_type            IN     VARCHAR2,
    x_bill_unassign_time_flag           IN     VARCHAR2,
    x_nonbill_unassign_time_flag        IN     VARCHAR2,
    x_bill_unassign_proj_id             IN     NUMBER,
    x_bill_unassign_exp_type_class      IN     VARCHAR2,
    x_bill_unassign_exp_type            IN     VARCHAR2,
    x_nonbill_unassign_proj_id          IN     NUMBER,
    x_nonbill_unassign_exp_typ_cls      IN     VARCHAR2,
    x_nonbill_unassign_exp_type         IN     VARCHAR2,
    X_CREATION_DATE                     in     DATE,
    X_CREATED_BY                        in     NUMBER,
    X_LAST_UPDATE_DATE                  in     DATE,
    X_LAST_UPDATED_BY                   in     NUMBER,
    X_LAST_UPDATE_LOGIN                 in     NUMBER,
    /*FOLLOWING 3 NEW PARAMETERS ADDED MARCH 12,2001 BY NAVEEN GUPTA
    IN ORDER TO INSERT DATA FOR FIELDS KEY_MEMBER_ROLE_ID,JOB_COST_RATE_SCHEDULE_ID AND FORECAST_CLASS_CATEGORY
    RESPECTIVELY  IN TABLE PA_FORECASTING_OPTIONS_ALL*/
    /* x_key_member_role_id                in     NUMBER, */
    x_job_cost_rate_schedule_id         in     NUMBER,
    /* x_forecast_class_category           in     VARCHAR2, */
    /* Bug 4576715 ends */
    x_org_fcst_period_type              in     VARCHAR2,
    x_start_period_name                 in     VARCHAR2,
    x_number_of_periods                 in     NUMBER,
    x_org_fcst_project_template_id      in     NUMBER,
    x_weighted_or_full_code             in     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    /* Bug 4576715 begin */
    /* x_include_admin_proj_flag           IN     VARCHAR2,
    x_gl_period_flag                    IN     VARCHAR2,
    x_pa_period_flag                    IN     VARCHAR2,  */
    x_forecast_thru_date                IN     DATE,
    x_actuals_thru_date                 IN     DATE,
    /* x_max_historical_versions           IN     NUMBER,
    x_util_calc_method                  IN     VARCHAR2, */
    x_default_assign_exp_typ_class     IN     VARCHAR2,
    x_default_assign_exp_type           IN     VARCHAR2,
    x_default_tp_amount_type            IN     VARCHAR2,
    x_bill_unassign_time_flag           IN     VARCHAR2,
    x_nonbill_unassign_time_flag        IN     VARCHAR2,
    x_bill_unassign_proj_id             IN     NUMBER,
    x_bill_unassign_exp_type_class      IN     VARCHAR2,
    x_bill_unassign_exp_type            IN     VARCHAR2,
    x_nonbill_unassign_proj_id          IN     NUMBER,
    x_nonbill_unassign_exp_typ_cls      IN     VARCHAR2,
    x_nonbill_unassign_exp_type         IN     VARCHAR2,
    X_CREATION_DATE                     in     DATE,
    X_CREATED_BY                        in     NUMBER,
    X_LAST_UPDATE_DATE                  in     DATE,
    X_LAST_UPDATED_BY                   in     NUMBER,
    X_LAST_UPDATE_LOGIN                 in     NUMBER,
    /*FOLLOWING 3 NEW PARAMETERS ADDED MARCH 12,2001 BY NAVEEN GUPTA
    IN ORDER TO INSERT DATA FOR FIELDS KEY_MEMBER_ROLE_ID,JOB_COST_RATE_SCHEDULE_ID AND FORECAST_CLASS_CATEGORY
    RESPECTIVELY  IN TABLE PA_FORECASTING_OPTIONS_ALL*/
    /* x_key_member_role_id                in     NUMBER, */
    x_job_cost_rate_schedule_id         in     NUMBER,
    /* x_forecast_class_category           in     VARCHAR2, */
    /* Bug 4576715 ends */
    x_org_fcst_period_type              in     VARCHAR2,
    x_start_period_name                 in     VARCHAR2,
    x_number_of_periods                 in     NUMBER,
    x_org_fcst_project_template_id      in     NUMBER,
    x_weighted_or_full_code             in     VARCHAR2
  );


  PROCEDURE delete_row ( x_rowid          IN     VARCHAR2) ;

END pa_forecasting_options_all_pkg;
 

/
