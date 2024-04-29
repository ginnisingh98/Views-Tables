--------------------------------------------------------
--  DDL for Package PA_FORECAST_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FORECAST_DTLS_PKG" AUTHID CURRENT_USER as
--/* $Header: PARFFIDS.pls 120.1 2005/08/19 16:51:17 mwasowic noship $ */


PROCEDURE insert_rows ( p_forecast_dtls_tab                   IN  PA_FORECAST_GLOB.FIDtlTabTyp,
                        x_return_status                       OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_msg_count                           OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data                            OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure : Insert_Rows
-- This procedure will insert the record in pa_forecast_items  table
-- Parameters



PROCEDURE update_rows ( p_forecast_dtls_tab                   IN  PA_FORECAST_GLOB.FIDtlTabTyp,
                        x_return_status                       OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_msg_count                           OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data                            OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure : Update_Rows
-- This procedure will update  the record in pa_forecast_items table
-- Parameters
--

END PA_FORECAST_DTLS_PKG;
 

/
