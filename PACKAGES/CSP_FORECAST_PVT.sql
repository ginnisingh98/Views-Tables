--------------------------------------------------------
--  DDL for Package CSP_FORECAST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_FORECAST_PVT" AUTHID CURRENT_USER AS
/* $Header: cspvpfos.pls 115.9 2002/11/26 08:00:40 hhaugeru ship $ */

TYPE t_number_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_date_table IS TABLE OF DATE INDEX BY BINARY_INTEGER;

FUNCTION  period_end_date(
  p_organization_id     IN  NUMBER,
  p_period_type         IN  NUMBER,
  p_period_start_date   IN  DATE)
  RETURN DATE;

PROCEDURE period_start_dates(
  p_start_date          IN  DATE,
  p_period_type         IN  NUMBER,
  p_number_of_periods   IN  NUMBER,
  p_organization_id     IN  NUMBER,
  x_period_start_dates      OUT NOCOPY csp_forecast_pvt.t_date_table);

PROCEDURE simple_average(
  p_usage_history       IN  csp_forecast_pvt.t_number_table,
  p_history_periods     IN  NUMBER,
  p_forecast_periods    IN  NUMBER,
  x_forecast_quantities OUT NOCOPY csp_forecast_pvt.t_number_table);

PROCEDURE weighted_average(
      p_usage_history           IN  csp_forecast_pvt.t_number_table,
      p_history_periods         IN  NUMBER,
      p_forecast_periods        IN  NUMBER,
      p_weighted_avg            IN  csp_forecast_pvt.t_number_table,
      x_forecast_quantities     OUT NOCOPY csp_forecast_pvt.t_number_table);

PROCEDURE exponential_smoothing(
  p_usage_history           IN  csp_forecast_pvt.t_number_table,
  p_history_periods         IN  NUMBER,
  p_forecast_periods        IN  NUMBER,
  p_alpha                   IN  NUMBER,
  x_forecast_quantities     OUT NOCOPY csp_forecast_pvt.t_number_table);

PROCEDURE trend_enhanced(
  p_usage_history           IN  csp_forecast_pvt.t_number_table,
  p_history_periods         IN  NUMBER,
  p_forecast_periods        IN  NUMBER,
  p_alpha                   IN  NUMBER,
  p_beta                    IN  NUMBER,
  x_forecast_quantities     OUT NOCOPY csp_forecast_pvt.t_number_table);

PROCEDURE create_forecast(
  p_api_version         IN  NUMBER,
  p_parts_loop_id       IN  NUMBER,
  p_organization_id     IN  NUMBER,
  p_subinventory_code   IN  VARCHAR2 DEFAULT '-',
  p_inventory_item_id   IN  NUMBER,
  p_start_date          IN  DATE,
  x_start_date          OUT NOCOPY DATE,
  x_end_date            OUT NOCOPY DATE,
  x_period_type         OUT NOCOPY NUMBER,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2);

PROCEDURE rollback_forecast;

END csp_forecast_pvt;


 

/
