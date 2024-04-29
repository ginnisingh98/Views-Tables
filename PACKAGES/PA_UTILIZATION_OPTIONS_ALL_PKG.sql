--------------------------------------------------------
--  DDL for Package PA_UTILIZATION_OPTIONS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_UTILIZATION_OPTIONS_ALL_PKG" AUTHID CURRENT_USER AS
/* $Header: PARUTOPS.pls 120.1 2005/08/19 17:03:05 mwasowic noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
    x_org_id                            IN     NUMBER,
    x_gl_period_flag                    IN     VARCHAR2,
    x_pa_period_flag                    IN     VARCHAR2,
    x_global_exp_period_flag            IN     VARCHAR2,
    x_forecast_thru_date                IN     DATE,
    x_actuals_thru_date                 IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_gl_period_flag                    IN     VARCHAR2,
    x_pa_period_flag                    IN     VARCHAR2,
    x_global_exp_period_flag            IN     VARCHAR2,
    x_forecast_thru_date                IN     DATE,
    x_actuals_thru_date                 IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_gl_period_flag                    IN     VARCHAR2,
    x_pa_period_flag                    IN     VARCHAR2,
    x_global_exp_period_flag            IN     VARCHAR2,
    x_forecast_thru_date                IN     DATE,
    x_actuals_thru_date                 IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

END pa_utilization_options_all_pkg;
 

/
