--------------------------------------------------------
--  DDL for Package PA_WP_EXCEPTION_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_WP_EXCEPTION_UTILS" AUTHID CURRENT_USER as
/*$Header: PAWPXCUS.pls 120.1 2005/08/19 17:08:07 mwasowic noship $*/

-- API name                      : get_wp_exception_value
-- Type                          : Utils Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--
--  25-JUN-01   HSIU             -Created
--

  procedure get_wp_exception_value
  (
    p_object_type             IN      VARCHAR2,
    p_object_id               IN      NUMBER,
    p_measure_id              IN      NUMBER,
    p_period_type             IN      VARCHAR2,
    x_measure_value           OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_period_name             OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_return_status           OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count               OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_msg_data                OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


  PROCEDURE get_ITD_workplan_effort_var
  (
    p_object_type             IN      VARCHAR2,
    p_object_id               IN      NUMBER,
    p_measure_id              IN      NUMBER,
    p_period_type             IN      VARCHAR2,
    x_measure_value           OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_period_name             OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_return_status           OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count               OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_msg_data                OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  PROCEDURE get_forecast_wp_eff_var
  (
    p_object_type             IN      VARCHAR2,
    p_object_id               IN      NUMBER,
    p_measure_id              IN      NUMBER,
    p_period_type             IN      VARCHAR2,
    x_measure_value           OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_period_name             OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_return_status           OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count               OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_msg_data                OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  PROCEDURE get_cur_fc_to_pri_effort_var
  (
    p_object_type             IN      VARCHAR2,
    p_object_id               IN      NUMBER,
    p_measure_id              IN      NUMBER,
    p_period_type             IN      VARCHAR2,
    x_measure_value           OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_period_name             OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_return_status           OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count               OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_msg_data                OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  PROCEDURE get_sch_bsln_fin_var
  (
    p_object_type             IN      VARCHAR2,
    p_object_id               IN      NUMBER,
    p_measure_id              IN      NUMBER,
    p_period_type             IN      VARCHAR2,
    x_measure_value           OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_period_name             OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_return_status           OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count               OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_msg_data                OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  PROCEDURE get_sch_bsln_st_var
  (
    p_object_type             IN      VARCHAR2,
    p_object_id               IN      NUMBER,
    p_measure_id              IN      NUMBER,
    p_period_type             IN      VARCHAR2,
    x_measure_value           OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_period_name             OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_return_status           OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count               OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_msg_data                OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  PROCEDURE get_sch_pri_pub_ver_fin_var
  (
    p_object_type             IN      VARCHAR2,
    p_object_id               IN      NUMBER,
    p_measure_id              IN      NUMBER,
    p_period_type             IN      VARCHAR2,
    x_measure_value           OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_period_name             OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_return_status           OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count               OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_msg_data                OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  PROCEDURE get_sch_pri_pub_ver_st_var
  (
    p_object_type             IN      VARCHAR2,
    p_object_id               IN      NUMBER,
    p_measure_id              IN      NUMBER,
    p_period_type             IN      VARCHAR2,
    x_measure_value           OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_period_name             OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_return_status           OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count               OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_msg_data                OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  PROCEDURE get_sch_est_fin_var
  (
    p_object_type             IN      VARCHAR2,
    p_object_id               IN      NUMBER,
    p_measure_id              IN      NUMBER,
    p_period_type             IN      VARCHAR2,
    x_measure_value           OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_period_name             OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_return_status           OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count               OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_msg_data                OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  PROCEDURE get_sch_est_st_var
  (
    p_object_type             IN      VARCHAR2,
    p_object_id               IN      NUMBER,
    p_measure_id              IN      NUMBER,
    p_period_type             IN      VARCHAR2,
    x_measure_value           OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_period_name             OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_return_status           OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count               OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_msg_data                OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

end PA_WP_EXCEPTION_UTILS;

 

/
