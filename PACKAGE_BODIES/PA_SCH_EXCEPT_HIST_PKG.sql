--------------------------------------------------------
--  DDL for Package Body PA_SCH_EXCEPT_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_SCH_EXCEPT_HIST_PKG" as
/* $Header: PARGHISB.pls 120.1 2005/08/19 16:53:04 mwasowic noship $*/

  l_empty_tab_record  EXCEPTION;  --  Variable to raise the exception if  the passing table of records is empty

-- This procedure will insert the record in pa_schedule_except_history
-- Input parameters
-- Parameters                   Type                 Required  Description
-- P_Sch_Except_Record_Tab      SchExceptTabTyp      YES       It contains the exception  record
--

PROCEDURE insert_rows (
  p_sch_except_record_tab      IN   PA_SCHEDULE_GLOB.SchExceptTabTyp,
  p_change_id                  IN   PA_SCHEDULE_EXCEPT_HISTORY.change_id%type,
  x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

        l_schedule_exception_id    PA_PLSQL_DATATYPES.IdTabTyp;
        l_calendar_id              PA_PLSQL_DATATYPES.IdTabTyp;
        l_assignment_id            PA_PLSQL_DATATYPES.IdTabTyp;
        l_project_id               PA_PLSQL_DATATYPES.IdTabTyp;
        l_schedule_type_code       PA_PLSQL_DATATYPES.Char30TabTyp;
        l_assignment_status_code   PA_PLSQL_DATATYPES.Char30TabTyp;
        l_exception_type_code      PA_PLSQL_DATATYPES.Char30TabTyp;
        l_start_date               PA_PLSQL_DATATYPES.DateTabTyp;
        l_end_date                 PA_PLSQL_DATATYPES.DateTabTyp;
        l_resource_calendar_percent  PA_PLSQL_DATATYPES.NumTabTyp;
        l_non_working_day_flag    PA_PLSQL_DATATYPES.Char1TabTyp;
        l_change_hours_type_code     PA_PLSQL_DATATYPES.Char30TabTyp;
        l_change_calendar_type_code PA_PLSQL_DATATYPES.Char30TabTyp;
        l_change_calendar_id       PA_PLSQL_DATATYPES.NumTabTyp;
        l_monday_hours             PA_PLSQL_DATATYPES.NumTabTyp;
        l_tuesday_hours            PA_PLSQL_DATATYPES.NumTabTyp;
        l_wednesday_hours          PA_PLSQL_DATATYPES.NumTabTyp;
        l_thursday_hours           PA_PLSQL_DATATYPES.NumTabTyp;
        l_friday_hours             PA_PLSQL_DATATYPES.NumTabTyp;
        l_saturday_hours           PA_PLSQL_DATATYPES.NumTabTyp;
        l_sunday_hours             PA_PLSQL_DATATYPES.NumTabTyp;


BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

/* Checking for the empty table of record */
IF (p_sch_except_record_tab.count = 0 ) THEN
  raise l_empty_tab_record;
END IF;

FOR l_J IN p_sch_except_record_tab.first..p_sch_except_record_tab.last LOOP

l_schedule_exception_id(l_j)   := p_sch_except_record_tab(l_j).schedule_exception_id;
l_calendar_id(l_J)             := p_sch_except_record_tab(l_J).calendar_id;
l_assignment_id(l_J)           := p_sch_except_record_tab(l_J).assignment_id;
l_project_id(l_J)              := p_sch_except_record_tab(l_J).project_id;
l_schedule_type_code(l_J)      := p_sch_except_record_tab(l_J).schedule_type_code;
l_assignment_status_code(l_J)  := p_sch_except_record_tab(l_J).assignment_status_code;
l_exception_type_code(l_J)     := p_sch_except_record_tab(l_J).exception_type_code;
l_start_date(l_J)              := p_sch_except_record_tab(l_J).start_date;
l_end_date(l_J)                := p_sch_except_record_tab(l_J).end_date;
l_resource_calendar_percent(l_J) :=  p_sch_except_record_tab(l_J).resource_calendar_percent;
l_non_working_day_flag(l_J)   :=  p_sch_except_record_tab(l_J).non_working_day_flag;
l_change_hours_type_code(l_J)    :=  p_sch_except_record_tab(l_J).change_hours_type_code;
l_change_calendar_type_code(l_J) := p_sch_except_record_tab(l_J).change_calendar_type_code;
l_change_calendar_id(l_J)      := p_sch_except_record_tab(l_J).change_calendar_id;
l_monday_hours(l_J)            := p_sch_except_record_tab(l_J).monday_hours;
l_tuesday_hours(l_J)           := p_sch_except_record_tab(l_J).tuesday_hours;
l_wednesday_hours(l_J)         := p_sch_except_record_tab(l_J).wednesday_hours;
l_thursday_hours(l_J)          := p_sch_except_record_tab(l_J).thursday_hours;
l_friday_hours(l_J)            := p_sch_except_record_tab(l_J).friday_hours;
l_saturday_hours(l_J)          := p_sch_except_record_tab(l_J).saturday_hours;
l_sunday_hours(l_J)            := p_sch_except_record_tab(l_J).sunday_hours;

END LOOP;


FORALL l_J IN p_sch_except_record_tab.first..p_sch_except_record_tab.last
 INSERT INTO PA_SCHEDULE_EXCEPT_HISTORY
      ( schedule_exception_id             ,
        calendar_id             ,
        assignment_id           ,
        project_id              ,
        schedule_type_code      ,
        status_code             ,
        exception_type_code   ,
        start_date              ,
        end_date                ,
        resource_calendar_percent  ,
        non_working_day_flag    ,
        change_hours_type_code  ,
        change_calendar_type_code,
        change_calendar_id      ,
        monday_hours            ,
        tuesday_hours           ,
        wednesday_hours         ,
        thursday_hours          ,
        friday_hours            ,
        saturday_hours          ,
        sunday_hours            ,
        change_id               ,
        creation_date           ,
        created_by              ,
        last_update_date        ,
        last_update_by          ,
        last_update_login  )
 VALUES
     (  l_schedule_exception_id(l_J)   ,
        l_calendar_id(l_J)             ,
        l_assignment_id(l_J)           ,
        l_project_id(l_J)              ,
        l_schedule_type_code(l_J)      ,
        l_assignment_status_code(l_J)  ,
        l_exception_type_code(l_J)     ,
        l_start_date(l_J)              ,
        l_end_date(l_J)                ,
        l_resource_calendar_percent(l_J) ,
        l_non_working_day_flag(l_J)    ,
        l_change_hours_type_code(l_J)  ,
        l_change_calendar_type_code(l_J),
        l_change_calendar_id(l_J)      ,
        l_monday_hours(l_J)            ,
        l_tuesday_hours(l_J)           ,
        l_wednesday_hours(l_J)         ,
        l_thursday_hours(l_J)          ,
        l_friday_hours(l_J)            ,
        l_saturday_hours(l_J)          ,
        l_sunday_hours(l_J)            ,
        p_change_id                    ,
        sysdate                        ,
        fnd_global.user_id             ,
        sysdate                        ,
        fnd_global.user_id             ,
        fnd_global.login_id );

EXCEPTION
 WHEN l_empty_tab_record THEN
  NULL;
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCH_EXCEPT_HIST_PKG',
                           p_procedure_name     => 'insert_rows');
 raise;

END insert_rows;

-- This procedure will insert the record in pa_schedule_except_history
-- Input parameters
-- Parameters                   Type           Required Description
-- P_Schedule_Exception_Id      NUMBER         YES      Id for the exception record in schedule
-- P_Calendar_Id                NUMBER         YES      Id for that calendar which is associated to this assignment
-- P_Assignment_Id              NUMBER         YES      Assignment id of the exception records
-- P_Project_Id                 NUMBER         YES      project id of the associated calendar
-- P_Schedule_Type_Code         VARCHAR2       YES      It is schedule type code e.g changed hours/changed duration
-- P_Assignment_Status_Code     VARCHAR2       YES      Status of the assignment e.g OPEN/CONFIRM/PROVISIONAL
-- P_Exception_Type_Code        VARCHAR2       YES      It is exception type code e.g changed hours/changed duration
-- P_Start_Date                 DATE           YES      stat date of the exceptions
-- P_End_Date                   DATE           YES      end date of the exception
-- P_Resource_Calendar_Percent  NUMBER         YES      it is the resource calendar percentage
-- P_Non_Working_Flag           VARCHAR2       YES      It is non working day flag which means should include or no
--                                                      t i.e Y,N.
-- P_Change_Hours_Type_Code     VARCHAR2       YES      It is change hours type code which is used when changeing t
--                                                      he  hours e.g. HOURS or PERCENTAGE
-- P_Monday_Hours               NUMBER         YES      No. of hours of this day
-- P_Tuesday_Hours              NUMBER         YES      No. of hours of this day
-- P_Wednesday_Hours            NUMBER         YES      No. of hours of this day
-- P_Thursday_Hours             NUMBER         YES      No. of hours of this day
-- P_Friday_Hours               NUMBER         YES      No. of hours of this day
-- P_Saturday_Hours             NUMBER         YES      No. of hours of this day
-- P_Sunday_Hours               NUMBER         YES      No. of hours of this day
--

PROCEDURE insert_rows
       (p_schedule_exception_id            IN Number                         ,
        p_calendar_id                      IN Number   DEFAULT NULL          ,
        p_assignment_id                    IN Number   DEFAULT NULL          ,
        p_project_id                       IN Number   DEFAULT NULL          ,
        p_schedule_type_code               IN varchar2                       ,
        p_assignment_status_code           IN varchar2 DEFAULT NULL          ,
        p_exception_type_code              IN varchar2                       ,
        p_start_date                       IN date                           ,
        p_end_date                         IN date                           ,
        p_resource_calendar_percent        IN Number                         ,
        p_non_working_day_flag             IN varchar2                       ,
        p_change_hours_type_code           IN varchar2                       ,
        p_monday_hours                     IN Number DEFAULT NULL            ,
        p_tuesday_hours                    IN Number DEFAULT NULL            ,
        p_wednesday_hours                  IN Number DEFAULT NULL            ,
        p_thursday_hours                   IN Number DEFAULT NULL            ,
        p_friday_hours                     IN Number DEFAULT NULL            ,
        p_saturday_hours                   IN Number DEFAULT NULL            ,
        p_sunday_hours                     IN Number DEFAULT NULL            ,
        p_change_id       IN PA_SCHEDULE_EXCEPT_HISTORY.change_id%type ,
        x_return_status              OUT  NOCOPY VARCHAR2                           , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                             , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2                     ) --File.Sql.39 bug 4440895
IS

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

 INSERT INTO PA_SCHEDULE_EXCEPT_HISTORY
      ( schedule_exception_id   ,
        calendar_id             ,
        assignment_id           ,
        project_id              ,
        schedule_type_code      ,
        status_code             ,
        exception_type_code     ,
        start_date              ,
        end_date                ,
        resource_calendar_percent  ,
        non_working_day_flag    ,
        change_hours_type_code     ,
        monday_hours            ,
        tuesday_hours           ,
        wednesday_hours         ,
        thursday_hours          ,
        friday_hours            ,
        saturday_hours          ,
        sunday_hours            ,
        change_id               ,
        creation_date           ,
        created_by              ,
        last_update_date        ,
        last_update_by          ,
        last_update_login  )
 VALUES(p_schedule_exception_id      ,
        p_calendar_id                ,
        p_assignment_id              ,
        p_project_id                 ,
        p_schedule_type_code         ,
        p_assignment_status_code     ,
        p_exception_type_code        ,
        p_start_date                 ,
        p_end_date                   ,
        p_resource_calendar_percent  ,
        p_non_working_day_flag       ,
        p_change_hours_type_code     ,
        p_monday_hours               ,
        p_tuesday_hours              ,
        p_wednesday_hours            ,
        p_thursday_hours             ,
        p_friday_hours               ,
        p_saturday_hours             ,
        p_sunday_hours               ,
        p_change_id                  ,
        sysdate                      ,
        fnd_global.user_id           ,
        sysdate                      ,
        fnd_global.user_id           ,
        fnd_global.login_id);

EXCEPTION
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCH_EXCEPT_HIST_PKG',
                           p_procedure_name     => 'insert_rows');
 raise;

END insert_rows;


END PA_SCH_EXCEPT_HIST_PKG;

/
