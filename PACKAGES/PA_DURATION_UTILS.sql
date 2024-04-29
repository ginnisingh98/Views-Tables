--------------------------------------------------------
--  DDL for Package PA_DURATION_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_DURATION_UTILS" AUTHID CURRENT_USER AS
/*$Header: PADURUTS.pls 120.1 2005/08/19 16:21:48 mwasowic noship $*/

--
--  PROCEDURE   get_duration_old
--
--  PURPOSE
--              This procedure returns total number of hours and days for given
--              start date and end date.

g_start_date     DATE;
g_end_date       DATE;
g_duration_days  NUMBER;
g_duration_hours NUMBER;
g_sch_record_tab PA_SCHEDULE_GLOB.ScheduleTabTyp;
g_calendar_id    NUMBER;

PROCEDURE get_duration_old(p_calendar_id IN  NUMBER,
            p_start_date  IN  DATE,
            p_end_date    IN  DATE,
            x_duration_days  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_duration_hours OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_return_status  OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count      OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data       OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION get_total_hours(p_calendar_id IN NUMBER,
                         p_start_date IN DATE,
                         p_end_date IN DATE) return NUMBER;

--          07-Mar-2003    Amksingh Bug 2838700 A new procedure get_duration
--                                  is added and the previous get_duration is
--                                  renamed to get_duration_old.

PROCEDURE get_duration(p_calendar_id IN  NUMBER,
            p_start_date  IN  DATE,
            p_end_date    IN  DATE,
            x_duration_days  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_duration_hours OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_return_status  OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count      OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data       OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END PA_DURATION_UTILS ;
 

/
