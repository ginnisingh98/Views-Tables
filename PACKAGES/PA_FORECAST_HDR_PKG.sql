--------------------------------------------------------
--  DDL for Package PA_FORECAST_HDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FORECAST_HDR_PKG" AUTHID CURRENT_USER as
--/* $Header: PARFFIHS.pls 120.1 2005/08/19 16:51:26 mwasowic noship $ */

PROCEDURE insert_rows ( p_forecast_hdr_tab                    IN  PA_FORECAST_GLOB.FIHdrTabTyp,
                        x_return_status                       OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_msg_count                           OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data                            OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895



--
-- Procedure : Insert_Rows
-- This procedure will insert the record in pa_forecast_items  table
-- Input parameters
-- Parameters
--


PROCEDURE update_rows ( p_forecast_hdr_tab                    IN  PA_FORECAST_GLOB.FIHdrTabTyp,
                        x_return_status                       OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_msg_count                           OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data                            OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure : Update_Rows
-- This procedure will update  the record in pa_forecast_items table
-- Input parameters
-- Parameters
--



PROCEDURE update_schedule_rows ( p_schedule_tab                        IN  PA_FORECAST_GLOB.ScheduleTabTyp,
                                 x_return_status                       OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 x_msg_count                           OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 x_msg_data                            OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--
-- Procedure : Update_Schedule_Rows
-- This procedure will update  the record in pa_schedules table
-- Input parameters
-- Parameters
--

PROCEDURE update_rows(p_assignment_id IN NUMBER,
                 p_forecast_amt_calc_flag IN VARCHAR2,
                 x_return_status    OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                 x_msg_count        OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                 x_msg_data         OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END PA_FORECAST_HDR_PKG;
 

/
