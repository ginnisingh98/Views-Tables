--------------------------------------------------------
--  DDL for Package PA_PJI_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PJI_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: PAPJIUTS.pls 120.1 2005/08/19 16:41:05 mwasowic noship $ */
/* This package is created to get the utilization numbers from
   PJI data model if PJI is installed. Otherwise the utilization numbers
   will be derived from Utilization data model. */
PROCEDURE get_utilization_dtls
  ( p_org_id               IN pa_implementations_all.org_id%TYPE
                              := NULL
   ,p_organization_id      IN hr_organization_units.organization_id%TYPE
                              := NULL
   ,p_period_type          IN pa_forecasting_options_all.org_fcst_period_type%TYPE
                              := NULL
   ,p_period_set_name      IN gl_periods.period_set_name%TYPE
                              := NULL
   ,p_period_name          IN gl_periods.period_name%TYPE
                              := NULL
   ,x_utl_hours           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_utl_capacity        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_utl_percent         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_err_code            OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
END pa_pji_util_pkg;

 

/
