--------------------------------------------------------
--  DDL for Package PA_SCH_EXCEPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_SCH_EXCEPT_PKG" AUTHID CURRENT_USER as
/* $Header: PARGEXPS.pls 120.1 2005/08/19 16:53:00 mwasowic noship $ */


PROCEDURE insert_rows ( p_sch_except_record_tab         IN   PA_SCHEDULE_GLOB.SchExceptTabTyp,
                        x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure            : Insert_rows
-- Purpose              : Create Rows in PA_SCHEDULE_EXCEPTIONS in
--                        array processing. This overloaded function.
-- Parameters           :
--                        p_sch_record_tab - Table of schedule details Records
PROCEDURE insert_rows
        ( p_calendar_id                    IN Number   DEFAULT NULL ,
        p_assignment_id                    IN Number   DEFAULT NULL ,
        p_project_id                       IN Number   DEFAULT NULL ,
        p_schedule_type_code               IN varchar2              ,
        p_assignment_status_code           IN varchar2 DEFAULT NULL ,
        p_exception_type_code              IN varchar2              ,
        p_duration_shift_type_code         IN varchar2 DEFAULT NULL ,
        p_duration_shift_unit_code         IN varchar2 DEFAULT NULL ,
        p_number_of_shift                  IN number   DEFAULT NULL ,
        p_start_date                       IN date                  ,
        p_end_date                         IN date                  ,
        p_resource_calendar_percent        IN Number   DEFAULT NULL ,
        p_non_working_day_flag             IN varchar2 DEFAULT NULL ,
        p_change_hours_type_code           IN varchar2 DEFAULT NULL ,
        p_change_calendar_type_code        IN varchar2 DEFAULT NULL ,
       -- p_change_calendar_name             IN varchar2 DEFAULT NULL ,
        p_change_calendar_id               IN number   DEFAULT NULL ,
        p_monday_hours                     IN Number   DEFAULT NULL ,
        p_tuesday_hours                    IN Number   DEFAULT NULL ,
        p_wednesday_hours                  IN Number   DEFAULT NULL ,
        p_thursday_hours                   IN Number   DEFAULT NULL ,
        p_friday_hours                     IN Number   DEFAULT NULL ,
        p_saturday_hours                   IN Number   DEFAULT NULL ,
        p_sunday_hours                     IN Number   DEFAULT NULL ,
        x_exception_id               OUT  NOCOPY Number                    , --File.Sql.39 bug 4440895
        x_return_status              OUT  NOCOPY VARCHAR2                  , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                    , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895
--
-- Procedure            : Insert_rows
-- Purpose              : Create Rows in PA_SCHEDULE_EXCEPTIONS with scalar data types.
--                        This overloaded function.
-- Parameters           :
--                        p_sch_record_tab - Table of schedule details Records


PROCEDURE update_rows ( p_sch_except_record_tab         IN   PA_SCHEDULE_GLOB.SchExceptTabTyp,
                        x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure            : update_rows
-- Purpose              : Create Rows in PA_SCHEDULE_EXCEPTIONS in
--                        array processing. This overloaded function.
-- Parameters           :
--                        p_sch_record_tab - Table of schedule details Records
PROCEDURE update_rows
      ( p_exceptrowid                      IN rowid ,
        p_schedule_exception_id            IN NUMBER,
        p_calendar_id                      IN Number   DEFAULT NULL ,
        p_assignment_id                    IN Number   DEFAULT NULL ,
        p_project_id                       IN Number   DEFAULT NULL ,
        p_schedule_type_code               IN varchar2              ,
        p_assignment_status_code           IN varchar2 DEFAULT NULL ,
        p_exception_type_code              IN varchar2              ,
        p_duration_shift_type_code         IN varchar2 DEFAULT NULL ,
        p_duration_shift_unit_code         IN varchar2 DEFAULT NULL ,
        p_number_of_shift                  IN number   DEFAULT NULL ,
        p_start_date                       IN date                  ,
        p_end_date                         IN date                  ,
        p_resource_calendar_percent        IN Number   DEFAULT NULL ,
        p_non_working_day_flag             IN varchar2 DEFAULT NULL ,
        p_change_hours_type_code           IN varchar2 DEFAULT NULL ,
        p_change_calendar_type_code        IN varchar2 DEFAULT NULL ,
     -- p_change_calendar_name             IN varchar2 DEFAULT NULL ,
        p_change_calendar_id               IN number   DEFAULT NULL ,
        p_monday_hours                     IN Number   DEFAULT NULL ,
        p_tuesday_hours                    IN Number   DEFAULT NULL ,
        p_wednesday_hours                  IN Number   DEFAULT NULL ,
        p_thursday_hours                   IN Number   DEFAULT NULL ,
        p_friday_hours                     IN Number   DEFAULT NULL ,
        p_saturday_hours                   IN Number   DEFAULT NULL ,
        p_sunday_hours                     IN Number   DEFAULT NULL ,
        x_return_status              OUT  NOCOPY VARCHAR2                  , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                    , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895
--
-- Procedure            : update_rows
-- Purpose              : Create Rows in PA_SCHEDULE_EXCEPTIONS with scalar data types.
--                        This overloaded function.
-- Parameters           :
--                        p_sch_record_tab - Table of schedule details Records
PROCEDURE update_rows
      ( p_schedule_exception_id            IN NUMBER                ,
        p_calendar_id                      IN Number   DEFAULT NULL ,
        p_assignment_id                    IN Number   DEFAULT NULL ,
        p_project_id                       IN Number   DEFAULT NULL ,
        p_schedule_type_code               IN varchar2              ,
        p_assignment_status_code           IN varchar2 DEFAULT NULL ,
        p_exception_type_code              IN varchar2              ,
        p_duration_shift_type_code         IN varchar2 DEFAULT NULL ,
        p_duration_shift_unit_code         IN varchar2 DEFAULT NULL ,
        p_number_of_shift                  IN number   DEFAULT NULL ,
        p_start_date                       IN date                  ,
        p_end_date                         IN date                  ,
        p_resource_calendar_percent        IN Number   DEFAULT NULL ,
        p_non_working_day_flag             IN varchar2 DEFAULT NULL ,
        p_change_hours_type_code           IN varchar2 DEFAULT NULL ,
        p_change_calendar_type_code        IN varchar2 DEFAULT NULL ,
     -- p_change_calendar_name             IN varchar2 DEFAULT NULL ,
        p_change_calendar_id               IN number   DEFAULT NULL ,
        p_monday_hours                     IN Number   DEFAULT NULL ,
        p_tuesday_hours                    IN Number   DEFAULT NULL ,
        p_wednesday_hours                  IN Number   DEFAULT NULL ,
        p_thursday_hours                   IN Number   DEFAULT NULL ,
        p_friday_hours                     IN Number   DEFAULT NULL ,
        p_saturday_hours                   IN Number   DEFAULT NULL ,
        p_sunday_hours                     IN Number   DEFAULT NULL ,
        x_return_status              OUT  NOCOPY VARCHAR2                  , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                    , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895
--
-- Procedure            : update_rows
-- Purpose              : Create Rows in PA_SCHEDULE_EXCEPTIONS with scalar data types.
--                        This overloaded function.
-- Parameters           :
--                        p_sch_record_tab - Table of schedule details Records

PROCEDURE delete_rows ( p_sch_except_record_tab         IN   PA_SCHEDULE_GLOB.SchExceptTabTyp,
                        x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure            : delete_rows
-- Purpose              : deletes Rows in PA_SCHEDULES in
--                        array processing. This overloaded function.
-- Parameters           :
--                        p_sch_record_tab - Table of schedule details Records

PROCEDURE delete_rows
        ( p_schedule_exception_id                    IN Number          ,
          x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE delete_rows
        ( p_exceptrowid                IN rowid,
          x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895
END PA_SCH_EXCEPT_PKG;
 

/
