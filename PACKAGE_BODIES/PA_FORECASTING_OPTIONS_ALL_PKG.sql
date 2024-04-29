--------------------------------------------------------
--  DDL for Package Body PA_FORECASTING_OPTIONS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FORECASTING_OPTIONS_ALL_PKG" AS
/* $Header: PARUTFRB.pls 120.3 2005/10/27 06:13:47 nkumbi noship $ */

PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_org_id                            IN     NUMBER,
  /* Bug 4576715 begin */
  /*  x_include_admin_proj_flag           IN     VARCHAR2,
    x_gl_period_flag                    IN     VARCHAR2,
    x_pa_period_flag                    IN     VARCHAR2, */
    x_forecast_thru_date                IN     DATE,
    x_actuals_thru_date                 IN     DATE,
  /*  x_max_historical_versions           IN     NUMBER,
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
/*    x_key_member_role_id		in     NUMBER, */
    x_job_cost_rate_schedule_id		in     NUMBER,
/*    x_forecast_class_category		in     VARCHAR2, */
/* Bug 4576715 ends */
    x_org_fcst_period_type              in     VARCHAR2,
    x_start_period_name                 in     VARCHAR2,
    x_number_of_periods                 in     NUMBER,
    x_org_fcst_project_template_id      in     NUMBER,
    x_weighted_or_full_code             in     VARCHAR2
  ) AS
/*||  Change History :
  ||  Who             When            What
  ||  NAVEEN         12-MAR-2001      Passing 3 more parameters namely x_key_member_role_id, x_job_cost_rate_schedule_id
  ||                                  and x_forecast_class_category to the procedure in order to add data for
  ||                                  fields key_member_role_id,job_cost_rate_schedule_id,forecast_class_category
  ||                                  in the table
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     pa_forecasting_options_all
      WHERE  nvl(org_id,-99) = nvl(x_org_id,-99);

    l_rowid NUMBER;  -- used to restore x_row_id for NOCOPY changes

  BEGIN
    l_rowid := x_rowid;
    INSERT INTO pa_forecasting_options_all (
      org_id,
    /* Bug 4576715 begin */
    /*  include_admin_proj_flag,
      gl_period_flag,
      pa_period_flag, */
      forecast_thru_date,
      actuals_thru_date,
     /* max_historical_versions,
      util_calc_method, */
      default_assign_exp_type_class,
      default_assign_exp_type,
      default_tp_amount_type,
      bill_unassign_time_flag,
      nonbill_unassign_time_flag,
      bill_unassign_proj_id,
      bill_unassign_exp_type_class,
      bill_unassign_exp_type,
      nonbill_unassign_proj_id,
      nonbill_unassign_exp_typ_cls,
      nonbill_unassign_exp_type,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
   /*   key_member_role_id, */
      job_cost_rate_schedule_id,
   /*   forecast_class_category, */
   /* Bug 4576715 ends */
      org_fcst_period_type,
      start_period_name,
      number_of_periods,
      org_fcst_project_template_id,
      weighted_or_Full_code
    ) VALUES (
      x_org_id,
    /* Bug 4576715 begins */
    /*  x_include_admin_proj_flag,
      x_gl_period_flag,
      x_pa_period_flag, */
      x_forecast_thru_date,
      x_actuals_thru_date,
   /*   x_max_historical_versions,
      x_util_calc_method,*/
      x_default_assign_exp_typ_class,
      x_default_assign_exp_type,
      x_default_tp_amount_type,
      x_bill_unassign_time_flag,
      x_nonbill_unassign_time_flag,
      x_bill_unassign_proj_id,
      x_bill_unassign_exp_type_class,
      x_bill_unassign_exp_type,
      x_nonbill_unassign_proj_id,
      x_nonbill_unassign_exp_typ_cls,
      x_nonbill_unassign_exp_type,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
   /*   x_key_member_role_id, */
      x_job_cost_rate_schedule_id,
   /*   x_forecast_class_category, */
   /* Bug 4576715 ends */
      x_org_fcst_period_type,
      x_start_period_name,
      x_number_of_periods,
      x_org_fcst_project_template_id,
      x_weighted_or_full_code
    );
    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

  EXCEPTION
    WHEN OTHERS THEN
      x_rowid := l_rowid;
      RAISE;
  END insert_row;
  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    /* Bug 4576715 begins */
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
   /* x_key_member_role_id                in     NUMBER, */
    x_job_cost_rate_schedule_id         in     NUMBER,
   /* x_forecast_class_category           in     VARCHAR2, */
   /* Bug 4576715 ends */
    x_org_fcst_period_type              in     VARCHAR2,
    x_start_period_name                 in     VARCHAR2,
    x_number_of_periods                 in     NUMBER,
    x_org_fcst_project_template_id      in     NUMBER,
    x_weighted_or_full_code             in     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 16-OCT-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  NAVEEN         12-MAR-2001      Passing 3 more parameters namely x_key_member_role_id, x_job_cost_rate_schedule_id
  ||                                  and x_forecast_class_category to the procedure in order to pass values for
  ||                                  fields key_member_role_id,job_cost_rate_schedule_id,forecast_class_category
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        org_id,
       /* Bug 4576715 begin */
       /* include_admin_proj_flag,
        gl_period_flag,
        pa_period_flag, */
        forecast_thru_date,
        actuals_thru_date,
        /* max_historical_versions,
        util_calc_method, */
        default_assign_exp_type_class,
        default_assign_exp_type,
        default_tp_amount_type,
        bill_unassign_time_flag,
        nonbill_unassign_time_flag,
        bill_unassign_proj_id,
        bill_unassign_exp_type_class,
        bill_unassign_exp_type,
        nonbill_unassign_proj_id,
        nonbill_unassign_exp_typ_cls,
        nonbill_unassign_exp_type,
        /* key_member_role_id, */
        job_cost_rate_schedule_id,
        /* forecast_class_category, */
	/* Bug 4576715 ends */
        org_fcst_period_type,
        start_period_name,
        number_of_periods,
        org_fcst_project_template_id,
        weighted_or_full_code
      FROM  pa_forecasting_options_all
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;
    tlinfo c1%ROWTYPE;
  BEGIN
    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;
    IF (
        (nvl(tlinfo.org_id,-99) = nvl(x_org_id,-99))
      --  AND (tlinfo.include_admin_proj_flag = x_include_admin_proj_flag) Bug 4576715
      --  AND (tlinfo.gl_period_flag = x_gl_period_flag) Bug 4576715
      --  AND (tlinfo.pa_period_flag = x_pa_period_flag) Bug 4576715
        AND (tlinfo.forecast_thru_date = x_forecast_thru_date)
        AND (tlinfo.actuals_thru_date  = x_actuals_thru_date)
       -- AND (tlinfo.max_historical_versions = x_max_historical_versions) Bug 4576715
       -- AND (tlinfo.util_calc_method = x_util_calc_method) Bug 4576715
        AND (tlinfo.default_assign_exp_type_class = x_default_assign_exp_typ_class)
        AND (tlinfo.default_assign_exp_type = x_default_assign_exp_type)
        AND (tlinfo.default_tp_amount_type = x_default_tp_amount_type)
        AND (tlinfo.bill_unassign_time_flag = x_bill_unassign_time_flag)
        AND (tlinfo.nonbill_unassign_time_flag = x_nonbill_unassign_time_flag)
       -- AND (tlinfo.key_member_role_id = x_key_member_role_id) Bug 4576715
        AND (tlinfo.job_cost_rate_schedule_id = x_job_cost_rate_schedule_id)
       -- AND (tlinfo.forecast_class_category = x_forecast_class_category) Bug 4576715
        AND (tlinfo.org_fcst_period_type = x_org_fcst_period_Type)
        AND (tlinfo.start_period_name = x_start_period_name)
        AND (tlinfo.number_of_periods = x_number_of_periods)
        AND (tlinfo.org_fcst_project_template_id = x_org_fcst_project_template_id)
        AND (tlinfo.weighted_or_full_code = x_weighted_or_full_code)
        AND ((tlinfo.bill_unassign_proj_id = x_bill_unassign_proj_id) OR ((tlinfo.bill_unassign_proj_id IS NULL) AND (X_bill_unassign_proj_id IS NULL)))
        AND ((tlinfo.bill_unassign_exp_type_class = x_bill_unassign_exp_type_class) OR ((tlinfo.bill_unassign_exp_type_class IS NULL) AND (X_bill_unassign_exp_type_class IS NULL)))
        AND ((tlinfo.bill_unassign_exp_type = x_bill_unassign_exp_type) OR ((tlinfo.bill_unassign_exp_type IS NULL) AND (X_bill_unassign_exp_type IS NULL)))
        AND ((tlinfo.nonbill_unassign_proj_id = x_nonbill_unassign_proj_id) OR ((tlinfo.nonbill_unassign_proj_id IS NULL) AND (X_nonbill_unassign_proj_id IS NULL)))
        AND ((tlinfo.nonbill_unassign_exp_typ_cls = x_nonbill_unassign_exp_typ_cls) OR ((tlinfo.nonbill_unassign_exp_typ_cls IS NULL) AND (X_nonbill_unassign_exp_typ_cls IS NULL)))
        AND ((tlinfo.nonbill_unassign_exp_type = x_nonbill_unassign_exp_type) OR ((tlinfo.nonbill_unassign_exp_type IS NULL) AND (X_nonbill_unassign_exp_type IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    END IF;
    RETURN;
  END lock_row;
  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
   /* Bug 4576715 begin */
   /* x_include_admin_proj_flag           IN     VARCHAR2,
    x_gl_period_flag                    IN     VARCHAR2,
    x_pa_period_flag                    IN     VARCHAR2, */
    x_forecast_thru_date                IN     DATE,
    x_actuals_thru_date                 IN     DATE,
   /*   x_max_historical_versions           IN     NUMBER,
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
    /* x_key_member_role_id                in     NUMBER, */
    x_job_cost_rate_schedule_id         in     NUMBER,
    /* x_forecast_class_category           in     VARCHAR2, */
    /* Bug 4576715 ends */
    x_org_fcst_period_type              in     VARCHAR2,
    x_start_period_name                 in     VARCHAR2,
    x_number_of_periods                 in     NUMBER,
    x_org_fcst_project_template_id      in     NUMBER,
    x_weighted_or_full_code             in     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 16-OCT-2000
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  NAVEEN	     12-MAR-2001      Passing 3 more parameters namely x_key_member_role_id, x_job_cost_rate_schedule_id
  ||                                  and x_forecast_class_category to the procedure in order to update
  ||                                  fields key_member_role_id,job_cost_rate_schedule_id,forecast_class_category
  ||                                  in the table
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    UPDATE pa_forecasting_options_all
      SET
        org_id                            = x_org_id,
	/* Bug 4576715 begin */
        /* include_admin_proj_flag           = x_include_admin_proj_flag,
        gl_period_flag                    = x_gl_period_flag,
        pa_period_flag                    = x_pa_period_flag, */
        forecast_thru_date                = x_forecast_thru_date,
        actuals_thru_date                 = x_actuals_thru_date,
        /* max_historical_versions           = x_max_historical_versions,
        util_calc_method                  = x_util_calc_method, */
        default_assign_exp_type_class     = x_default_assign_exp_typ_class,
        default_assign_exp_type           = x_default_assign_exp_type,
        default_tp_amount_type            = x_default_tp_amount_type,
        bill_unassign_time_flag           = x_bill_unassign_time_flag,
        nonbill_unassign_time_flag        = x_nonbill_unassign_time_flag,
        bill_unassign_proj_id             = x_bill_unassign_proj_id,
        bill_unassign_exp_type_class      = x_bill_unassign_exp_type_class,
        bill_unassign_exp_type            = x_bill_unassign_exp_type,
        nonbill_unassign_proj_id          = x_nonbill_unassign_proj_id,
        nonbill_unassign_exp_typ_cls      = x_nonbill_unassign_exp_typ_cls,
        nonbill_unassign_exp_type         = x_nonbill_unassign_exp_type,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        /* key_member_role_id		  = x_key_member_role_id, */
        job_cost_rate_schedule_id	  = x_job_cost_rate_schedule_id,
        /* forecast_class_category           = x_forecast_class_category, */
	/* Bug 4576715 ends */
        org_fcst_period_type              = x_org_fcst_period_type,
        start_period_name                 = x_start_period_name,
        number_of_periods                 = x_number_of_periods,
        org_fcst_project_template_id      = x_org_fcst_project_template_id,
        weighted_or_full_code             = x_weighted_or_full_code
      WHERE rowid = x_rowid;
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END update_row;
  PROCEDURE delete_row ( x_rowid          IN     VARCHAR2  ) AS
  /*
  ||  Created By :
  ||  Created On : 16-OCT-2000
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    DELETE FROM pa_forecasting_options_all
    WHERE rowid = x_rowid;
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END delete_row;
END pa_forecasting_options_all_pkg;

/
