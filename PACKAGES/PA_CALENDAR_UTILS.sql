--------------------------------------------------------
--  DDL for Package PA_CALENDAR_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CALENDAR_UTILS" AUTHID CURRENT_USER as
/* $Header: PARGCALS.pls 120.1 2005/08/19 16:52:53 mwasowic noship $ */

/* Added nocopy for this variable for bug#2674619 */
PROCEDURE get_calendar_shifts ( p_calendar_id         IN   NUMBER,
                                x_cal_record_tab      OUT  NOCOPY PA_SCHEDULE_GLOB.CalendarTabTyp,
                                x_return_status       OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count           OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data            OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure            : Get_calendar_shifts
-- Purpose              : Getting the shifts which are assigned to a passing calendar in
--                        array processing.
-- Parameters           :
--                        x_cal_record_tab - Table of Calendar details Records

/* Added nocopy for this variable for bug#2674619 */
PROCEDURE get_calendar_except ( p_calendar_id                IN   NUMBER,
                                x_cal_except_record_tab      OUT  NOCOPY PA_SCHEDULE_GLOB.CalExceptionTabTyp,
                                x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure            : Get_calendar_except
-- Purpose              : Getting the exceptions which are assigned to a passing calendar in
--                        array processing.
-- Parameters           :
--                        x_cal_except_record_tab - Table of Exception  details Records

/* Added nocopy for this variable for bug#2674619 */
PROCEDURE gen_calendar_sch    ( p_calendar_id         IN   NUMBER,
                                p_cal_record_tab      IN   PA_SCHEDULE_GLOB.CalendarTabTyp,
                                x_sch_record_tab      OUT  NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                x_return_status       OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count           OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data            OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure            : Gen_calendar_sch
-- Purpose              : Generating calendar schedule based on the calendar shift details in
--                        array processing.
-- Parameters           :
--                        p_cal_record_tab - Table of Calendar details Records
--                        x_sch_record_tab - Table of Schedule details Records

/* Added nocopy for this variable for bug#2674619 */
PROCEDURE apply_calendar_except ( p_calendar_id                IN      NUMBER,
                                  p_cal_except_record_tab      IN      PA_SCHEDULE_GLOB.CalExceptionTabTyp,
                                  p_sch_record_tab             IN      PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                  x_sch_record_tab             IN OUT  NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                  x_return_status              OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count                  OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data                   OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure            : Apply_calendar_except
-- Purpose              : Applying calendar exceptions on the  calendar schedule in
--                        array processing.
-- Parameters           :
--                        p_cal_except_record_tab - Table of Exception  details Records
--                        p_sch_record_tab        - Table of Schedule  details Records
--                        x_sch_record_tab        - Table of Schedule  details Records

PROCEDURE  Check_Calendar_Name_Or_Id
      ( p_calendar_id         IN JTF_CALENDARS_VL.calendar_id%TYPE
       ,p_calendar_name       IN JTF_CALENDARS_VL.calendar_name%TYPE
       ,p_check_id_flag       IN VARCHAR2 := 'A'
       ,x_calendar_id         OUT NOCOPY JTF_CALENDARS_VL.calendar_id%TYPE --File.Sql.39 bug 4440895
       ,x_return_status  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       ,x_error_message_code OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

--
-- Procedure            : Check_Name_Or_Id
-- Purpose              : This procedure validate the calendar Id or Calendar name against the JTF_CALENDARS_VL table
--
-- Parameters           :
--

END PA_CALENDAR_UTILS;
 

/
