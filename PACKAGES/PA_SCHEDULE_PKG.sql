--------------------------------------------------------
--  DDL for Package PA_SCHEDULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_SCHEDULE_PKG" AUTHID CURRENT_USER as
/* $Header: PARGSCHS.pls 120.2 2006/05/01 21:39:42 msachan noship $ */

--Bug 5126919: Added parameter p_total_hours. This will contain the total hours for
--which the schedule should be created. This will be used to make sure that schedule is created
--correctly (for the whole p_total_hours) even after rounding.
PROCEDURE insert_rows ( p_sch_record_tab         IN   PA_SCHEDULE_GLOB.ScheduleTabTyp,
                        x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data                   OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        p_total_hours                IN   NUMBER DEFAULT NULL); --Bug 5126919

--
-- Procedure            : Insert_rows
-- Purpose              : Create Rows in PA_SCHEDULES in
--                        array processing. This overloaded function.
-- Parameters           :
--                        p_sch_record_tab - Table of schedule details Records

PROCEDURE insert_rows
        ( p_calendar_id                    IN Number    DEFAULT NULL        ,
        p_assignment_id                    IN Number    DEFAULT NULL        ,
        p_project_id                       IN Number    DEFAULT NULL        ,
        p_schedule_type_code               IN varchar2                      ,
        p_assignment_status_code           IN varchar2  DEFAULT NULL        ,
        p_start_date                       IN date                          ,
        p_end_date                         IN date                          ,
        p_monday_hours                     IN Number                        ,
        p_tuesday_hours                    IN Number                        ,
        p_wednesday_hours                  IN Number                        ,
        p_thursday_hours                   IN Number                        ,
        p_friday_hours                     IN Number                        ,
        p_saturday_hours                   IN Number                        ,
        p_sunday_hours                     IN Number                        ,
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure            : Insert_rows
-- Purpose              : Create Rows in PA_SCHEDULES with scalar data types.
--                        This overloaded function.
-- Parameters           :
--                        p_sch_record_tab - Table of schedule details Records


PROCEDURE update_rows ( p_sch_record_tab         IN   PA_SCHEDULE_GLOB.ScheduleTabTyp,
                        x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure            : update_rows
-- Purpose              : Create Rows in PA_SCHEDULES in
--                        array processing. This overloaded function.
-- Parameters           :
--                        p_sch_record_tab - Table of schedule details Records

PROCEDURE update_rows
        ( p_schrowid                      In rowid,
          p_schedule_id                    IN Number          ,
         p_calendar_id                    IN Number      DEFAULT NULL    ,
        p_assignment_id                    IN Number     DEFAULT NULL     ,
        p_project_id                       IN Number     DEFAULT NULL      ,
        p_schedule_type_code               IN varchar2   DEFAULT NULL    ,
        p_assignment_status_code           IN varchar2   DEFAULT NULL     ,
        p_start_date                       IN date       DEFAULT NULL     ,
        p_end_date                         IN date       DEFAULT NULL      ,
        p_monday_hours                     IN Number     DEFAULT NULL      ,
        p_tuesday_hours                    IN Number     DEFAULT NULL     ,
        p_wednesday_hours                  IN Number     DEFAULT NULL      ,
        p_thursday_hours                   IN Number     DEFAULT NULL     ,
        p_friday_hours                     IN Number     DEFAULT NULL      ,
        p_saturday_hours                   IN Number     DEFAULT NULL     ,
        p_sunday_hours                     IN Number     DEFAULT NULL      ,
        x_return_status              OUT  NOCOPY VARCHAR2          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE update_rows
        ( p_schedule_id                    IN Number          ,
         p_calendar_id                    IN Number      DEFAULT NULL    ,
        p_assignment_id                    IN Number     DEFAULT NULL     ,
        p_project_id                       IN Number     DEFAULT NULL      ,
        p_schedule_type_code               IN varchar2   DEFAULT NULL    ,
        p_assignment_status_code           IN varchar2   DEFAULT NULL     ,
        p_start_date                       IN date       DEFAULT NULL     ,
        p_end_date                         IN date       DEFAULT NULL      ,
        p_monday_hours                     IN Number     DEFAULT NULL      ,
        p_tuesday_hours                    IN Number     DEFAULT NULL     ,
        p_wednesday_hours                  IN Number     DEFAULT NULL      ,
        p_thursday_hours                   IN Number     DEFAULT NULL     ,
        p_friday_hours                     IN Number     DEFAULT NULL      ,
        p_saturday_hours                   IN Number     DEFAULT NULL     ,
        p_sunday_hours                     IN Number     DEFAULT NULL      ,
        x_return_status              OUT  NOCOPY VARCHAR2          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure            : update_rows
-- Purpose              : Create Rows in PA_SCHEDULES with scalar data types.
--                        This overloaded function.
-- Parameters           :
--                        p_sch_record_tab - Table of schedule details Records

PROCEDURE delete_rows ( p_sch_record_tab         IN   PA_SCHEDULE_GLOB.ScheduleTabTyp,
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
        ( p_schedule_id                    IN Number          ,
          x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE delete_rows
        ( p_schrowid                    IN rowid ,
          x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

END PA_SCHEDULE_PKG;

 

/
