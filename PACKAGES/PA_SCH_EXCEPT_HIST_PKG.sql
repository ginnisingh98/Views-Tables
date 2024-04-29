--------------------------------------------------------
--  DDL for Package PA_SCH_EXCEPT_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_SCH_EXCEPT_HIST_PKG" AUTHID CURRENT_USER as
/* $Header: PARGHISS.pls 120.1 2005/08/19 16:53:09 mwasowic noship $ */


PROCEDURE insert_rows (
  p_sch_except_record_tab      IN   PA_SCHEDULE_GLOB.SchExceptTabTyp,
  p_change_id                  IN   PA_SCHEDULE_EXCEPT_HISTORY.change_id%type,
  x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure            : Insert_rows
-- Purpose              : Create Rows in PA_SCHEDULE_EXCEPT_HISTORY in
--                        array processing. This overloaded function.
-- Parameters           :
--                        p_sch_record_tab - Table of schedule details Records

PROCEDURE insert_rows
      ( p_schedule_exception_id            IN Number                        ,
        p_calendar_id                      IN Number   DEFAULT NULL         ,
        p_assignment_id                    IN Number   DEFAULT NULL         ,
        p_project_id                       IN Number   DEFAULT NULL         ,
        p_schedule_type_code               IN varchar2                      ,
        p_assignment_status_code           IN varchar2 DEFAULT NULL         ,
        p_exception_type_code              IN varchar2                      ,
        p_start_date                       IN date                          ,
        p_end_date                         IN date                          ,
        p_resource_calendar_percent        IN Number                        ,
        p_non_working_day_flag             IN varchar2                      ,
        p_change_hours_type_code           IN varchar2                      ,
        p_monday_hours                     IN Number DEFAULT NULL           ,
        p_tuesday_hours                    IN Number DEFAULT NULL           ,
        p_wednesday_hours                  IN Number DEFAULT NULL           ,
        p_thursday_hours                   IN Number DEFAULT NULL           ,
        p_friday_hours                     IN Number DEFAULT NULL           ,
        p_saturday_hours                   IN Number DEFAULT NULL           ,
        p_sunday_hours                     IN Number DEFAULT NULL           ,
        p_change_id       IN PA_SCHEDULE_EXCEPT_HISTORY.change_id%type ,
        x_return_status                    OUT  NOCOPY VARCHAR2                    , --File.Sql.39 bug 4440895
        x_msg_count                        OUT  NOCOPY NUMBER                      , --File.Sql.39 bug 4440895
        x_msg_data                         OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure            : Insert_rows
-- Purpose              : Create Rows in PA_SCHEDULE_EXCEPT_HISTORY with scalar data types.
--                        This overloaded function.
-- Parameters           :
--                        p_sch_record_tab - Table of schedule details Records


END PA_SCH_EXCEPT_HIST_PKG;
 

/
