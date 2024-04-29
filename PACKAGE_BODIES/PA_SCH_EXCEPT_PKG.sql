--------------------------------------------------------
--  DDL for Package Body PA_SCH_EXCEPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_SCH_EXCEPT_PKG" as
--/* $Header: PARGEXPB.pls 120.1.12000000.2 2007/03/08 10:14:27 vgovvala ship $ */
l_empty_tab_record  EXCEPTION;  --  Variable to raise the exception if  the passing table of records is empty

-- This function will generate the exception id
FUNCTION get_nextval RETURN NUMBER
IS
 l_nextval    NUMBER;
BEGIN

 SELECT pa_schedule_exceptions_s.nextval
 INTO   l_nextval
 FROM   SYS.DUAL;

 RETURN(l_nextval);

EXCEPTION
 WHEN OTHERS
 THEN
      RAISE;
END get_nextval;

-- This procedure will insert the record into the pa_schedule_exception table
-- Input parameters
-- Parameters                   Type                 Required  Description
-- P_Sch_Except_Record_Tab      SchExceptTabTyp      YES       It contains the exception  record
--

PROCEDURE insert_rows ( p_sch_except_record_tab         IN   PA_SCHEDULE_GLOB.SchExceptTabTyp,
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
        l_duration_shift_type_code PA_PLSQL_DATATYPES.Char30TabTyp;
        l_duration_shift_unit_code PA_PLSQL_DATATYPES.Char30TabTyp;
        l_number_of_shift          PA_PLSQL_DATATYPES.NumTabTyp;
        l_start_date               PA_PLSQL_DATATYPES.DateTabTyp;
        l_end_date                 PA_PLSQL_DATATYPES.DateTabTyp;
        l_resource_calendar_percent  PA_PLSQL_DATATYPES.NumTabTyp;
        l_non_working_day_flag       PA_PLSQL_DATATYPES.Char1TabTyp;
        l_change_hours_type_code     PA_PLSQL_DATATYPES.Char30TabTyp;
        l_change_calendar_type_code  PA_PLSQL_DATATYPES.Char30TabTyp;
       -- l_change_calendar_name       PA_PLSQL_DATATYPES.Char30TabTyp;
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
-- IF (p_sch_except_record_tab.count = 0 ) THEN
 --  raise l_empty_tab_record;
-- END IF;


FOR l_J IN p_sch_except_record_tab.first..p_sch_except_record_tab.last LOOP
l_schedule_exception_id(l_J)      := get_nextval;
l_calendar_id(l_J)                := p_sch_except_record_tab(l_J).calendar_id;
l_assignment_id(l_J)              := p_sch_except_record_tab(l_J).assignment_id;
l_project_id(l_J)                 := p_sch_except_record_tab(l_J).project_id;
l_schedule_type_code(l_J)         := p_sch_except_record_tab(l_J).schedule_type_code;
l_assignment_status_code(l_J)     := p_sch_except_record_tab(l_J).assignment_status_code;
l_exception_type_code(l_J)        := p_sch_except_record_tab(l_J).exception_type_code;
l_duration_shift_type_code(l_J)   := p_sch_except_record_tab(l_J).duration_shift_type_code;
l_duration_shift_unit_code(l_J)   := p_sch_except_record_tab(l_J).duration_shift_unit_code;
l_number_of_shift(l_J)            := p_sch_except_record_tab(l_J).number_of_shift;
l_start_date(l_J)                 := trunc(p_sch_except_record_tab(l_J).start_date);
l_end_date(l_J)                   := trunc(p_sch_except_record_tab(l_J).end_date);
l_resource_calendar_percent(l_J)  := p_sch_except_record_tab(l_J).resource_calendar_percent;
l_non_working_day_flag(l_J)       := p_sch_except_record_tab(l_J).non_working_day_flag;
l_change_hours_type_code(l_J)     := p_sch_except_record_tab(l_J).change_hours_type_code;
l_change_calendar_type_code(l_J)  := p_sch_except_record_tab(l_J).change_calendar_type_code;
-- l_change_calendar_name(l_J)       := p_sch_except_record_tab(l_J).change_calendar_name;
l_change_calendar_id(l_J)         := p_sch_except_record_tab(l_J).change_calendar_id;
l_monday_hours(l_J)               := p_sch_except_record_tab(l_J).monday_hours;
l_tuesday_hours(l_J)              := p_sch_except_record_tab(l_J).tuesday_hours;
l_wednesday_hours(l_J)            := p_sch_except_record_tab(l_J).wednesday_hours;
l_thursday_hours(l_J)             := p_sch_except_record_tab(l_J).thursday_hours;
l_friday_hours(l_J)               := p_sch_except_record_tab(l_J).friday_hours;
l_saturday_hours(l_J)             := p_sch_except_record_tab(l_J).saturday_hours;
l_sunday_hours(l_J)               := p_sch_except_record_tab(l_J).sunday_hours;

END LOOP;



FORALL l_J IN p_sch_except_record_tab.first..p_sch_except_record_tab.last

 INSERT INTO PA_SCHEDULE_EXCEPTIONS
      ( schedule_exception_id   ,
        calendar_id             ,
        assignment_id           ,
        project_id              ,
        schedule_type_code      ,
        status_code             ,
        exception_type_code     ,
        duration_shift_type_code,
        duration_shift_unit_code,
        number_of_shift         ,
        start_date              ,
        end_date                ,
        resource_calendar_percent,
        non_working_day_flag    ,
        change_hours_type_code  ,
        change_calendar_type_code,
      --  change_calendar_name    ,
        change_calendar_id      ,
        monday_hours            ,
        tuesday_hours           ,
        wednesday_hours         ,
        thursday_hours          ,
        friday_hours            ,
        saturday_hours          ,
        sunday_hours            ,
        creation_date           ,
        created_by              ,
        last_update_date        ,
        last_update_by          ,
        last_update_login)
 VALUES
     (  l_schedule_exception_id(l_J)   ,
        l_calendar_id(l_J)             ,
        l_assignment_id(l_J)           ,
        l_project_id(l_J)              ,
        l_schedule_type_code(l_J)      ,
        l_assignment_status_code(l_J)  ,
        l_exception_type_code(l_J)     ,
        l_duration_shift_type_code(l_J),
        l_duration_shift_unit_code(l_J),
        l_number_of_shift(l_J)         ,
        l_start_date(l_J)              ,
        l_end_date(l_J)                  ,
        l_resource_calendar_percent(l_J) ,
        l_non_working_day_flag(l_J)    ,
        l_change_hours_type_code(l_J)  ,
        l_change_calendar_type_code(l_J),
       -- l_change_calendar_name(l_J)    ,
        l_change_calendar_id(l_J)      ,
        l_monday_hours(l_J)            ,
        l_tuesday_hours(l_J)           ,
        l_wednesday_hours(l_J)         ,
        l_thursday_hours(l_J)          ,
        l_friday_hours(l_J)            ,
        l_saturday_hours(l_J)          ,
        l_sunday_hours(l_J)            ,
        sysdate                        ,
        fnd_global.user_id             ,
        sysdate                        ,
        fnd_global.user_id             ,
        fnd_global.login_id);


EXCEPTION
 WHEN l_empty_tab_record THEN
  NULL;
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCH_EXCEPT_PKG',
                           p_procedure_name     => 'insert_rows');
  raise;

END insert_rows;


-- This procedure will insert the record into the pa_schedule_exception table
-- Input parameters
-- Parameters                   Type           Required Description
-- P_Calendar_Id                NUMBER         YES      Id for that calendar which is associated to this assignmen
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
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
 l_t_schedule_exception_id  NUMBER;
BEGIN
/* 1799636 following line of code was commented to enhance the performance  */
-- l_t_schedule_exception_id := get_nextval;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

/*Bug 5854571: Added following for inserting l_t_schedule_exception_id
as schedule_exception_id into PA_SCHEDULE_EXCEPTIONS */
SELECT pa_schedule_exceptions_s.nextval
INTO l_t_schedule_exception_id
FROM dual;


 INSERT INTO PA_SCHEDULE_EXCEPTIONS
      ( schedule_exception_id   ,
        calendar_id             ,
        assignment_id           ,
        project_id              ,
        schedule_type_code      ,
        status_code             ,
        exception_type_code     ,
        duration_shift_type_code,
        duration_shift_unit_code,
        number_of_shift         ,
        start_date              ,
        end_date                ,
        resource_calendar_percent,
        non_working_day_flag    ,
        change_hours_type_code  ,
        change_calendar_type_code,
      --  change_calendar_name    ,
        change_calendar_id      ,
        monday_hours            ,
        tuesday_hours           ,
        wednesday_hours         ,
        thursday_hours          ,
        friday_hours            ,
        saturday_hours          ,
        sunday_hours            ,
        creation_date           ,
        created_by              ,
        last_update_date        ,
        last_update_by          ,
        last_update_login)
 VALUES
       (l_t_schedule_exception_id, -- removed pa_schedule_exceptions_s.nextval /*Bug 5854571*/
        p_calendar_id                ,
        p_assignment_id              ,
        p_project_id                 ,
        p_schedule_type_code         ,
        p_assignment_status_code     ,
        p_exception_type_code        ,
        p_duration_shift_type_code   ,
        p_duration_shift_unit_code   ,
        p_number_of_shift            ,
        trunc(p_start_date)          ,
        trunc(p_end_date)            ,
        p_resource_calendar_percent  ,
        p_non_working_day_flag       ,
        p_change_hours_type_code     ,
        p_change_calendar_type_code  ,
        --p_change_calendar_name       ,
        p_change_calendar_id         ,
        p_monday_hours               ,
        p_tuesday_hours              ,
        p_wednesday_hours            ,
        p_thursday_hours             ,
        p_friday_hours               ,
        p_saturday_hours             ,
        p_sunday_hours               ,
        sysdate                      ,
        fnd_global.user_id           ,
        sysdate                      ,
        fnd_global.user_id           ,
        fnd_global.login_id);

 x_exception_id  := l_t_schedule_exception_id;

EXCEPTION
 WHEN OTHERS THEN
 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCH_EXCEPT_PKG',
                           p_procedure_name     => 'insert_rows');
 raise;


END insert_rows;



-- This procedure will update the record into the pa_schedule_exception table
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Sch_Except_Record_Tab      TABLETYPE      YES       It contains the exception  record
--

PROCEDURE update_rows ( p_sch_except_record_tab      IN   PA_SCHEDULE_GLOB.SchExceptTabTyp,
                        x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
        l_exceptrowid              PA_PLSQL_DATATYPES.RowidTabTyp;
        l_schedule_exception_id    PA_PLSQL_DATATYPES.IdTabTyp;
        l_calendar_id              PA_PLSQL_DATATYPES.IdTabTyp;
        l_assignment_id            PA_PLSQL_DATATYPES.IdTabTyp;
        l_project_id               PA_PLSQL_DATATYPES.IdTabTyp;
        l_schedule_type_code       PA_PLSQL_DATATYPES.Char30TabTyp;
        l_assignment_status_code   PA_PLSQL_DATATYPES.Char30TabTyp;
        l_exception_type_code      PA_PLSQL_DATATYPES.Char30TabTyp;
        l_duration_shift_type_code PA_PLSQL_DATATYPES.Char30TabTyp;
        l_duration_shift_unit_code PA_PLSQL_DATATYPES.Char30TabTyp;
        l_number_of_shift          PA_PLSQL_DATATYPES.NumTabTyp;
        l_start_date               PA_PLSQL_DATATYPES.DateTabTyp;
        l_end_date                 PA_PLSQL_DATATYPES.DateTabTyp;
        l_resource_calendar_percent  PA_PLSQL_DATATYPES.NumTabTyp;
        l_non_working_day_flag       PA_PLSQL_DATATYPES.Char1TabTyp;
        l_change_hours_type_code     PA_PLSQL_DATATYPES.Char30TabTyp;
        l_change_calendar_type_code  PA_PLSQL_DATATYPES.Char30TabTyp;
        -- l_change_calendar_name       PA_PLSQL_DATATYPES.Char30TabTyp;
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
l_exceptrowid(l_j)             := p_sch_except_record_tab(l_j).exceptRowid;
l_schedule_exception_id(l_J)   := p_sch_except_record_tab(l_J).schedule_exception_id;
l_calendar_id(l_J)             := p_sch_except_record_tab(l_J).calendar_id;
l_assignment_id(l_J)           := p_sch_except_record_tab(l_J).assignment_id;
l_project_id(l_J)              := p_sch_except_record_tab(l_J).project_id;
l_schedule_type_code(l_J)      := p_sch_except_record_tab(l_J).schedule_type_code;
l_assignment_status_code(l_J)  := p_sch_except_record_tab(l_J).assignment_status_code;
l_exception_type_code(l_J)        := p_sch_except_record_tab(l_J).exception_type_code;
l_duration_shift_type_code(l_J)   := p_sch_except_record_tab(l_J).duration_shift_type_code;
l_duration_shift_unit_code(l_J)   := p_sch_except_record_tab(l_J).duration_shift_unit_code;
l_number_of_shift(l_J)            := p_sch_except_record_tab(l_J).number_of_shift;
l_start_date(l_J)                 := trunc(p_sch_except_record_tab(l_J).start_date);
l_end_date(l_J)                   := trunc(p_sch_except_record_tab(l_J).end_date);
l_resource_calendar_percent(l_J)  := p_sch_except_record_tab(l_J).resource_calendar_percent;
l_non_working_day_flag(l_J)       := p_sch_except_record_tab(l_J).non_working_day_flag;
l_change_hours_type_code(l_J)     := p_sch_except_record_tab(l_J).change_hours_type_code;
l_change_calendar_type_code(l_J)  := p_sch_except_record_tab(l_J).change_calendar_type_code;
-- l_change_calendar_name(l_J)       := p_sch_except_record_tab(l_J).change_calendar_name;
l_change_calendar_id(l_J)         := p_sch_except_record_tab(l_J).change_calendar_id;
l_monday_hours(l_J)            := p_sch_except_record_tab(l_J).monday_hours;
l_tuesday_hours(l_J)           := p_sch_except_record_tab(l_J).tuesday_hours;
l_wednesday_hours(l_J)         := p_sch_except_record_tab(l_J).wednesday_hours;
l_thursday_hours(l_J)          := p_sch_except_record_tab(l_J).thursday_hours;
l_friday_hours(l_J)            := p_sch_except_record_tab(l_J).friday_hours;
l_saturday_hours(l_J)          := p_sch_except_record_tab(l_J).saturday_hours;
l_sunday_hours(l_J)            := p_sch_except_record_tab(l_J).sunday_hours;

END LOOP;

FORALL l_J IN p_sch_except_record_tab.first..p_sch_except_record_tab.last
 UPDATE PA_SCHEDULE_EXCEPTIONS
 SET
        calendar_id               = l_calendar_id(l_J),
        assignment_id             = l_assignment_id(l_J),
        project_id                = l_project_id(l_J),
        schedule_type_code        = l_schedule_type_code(l_J),
        status_code               = l_assignment_status_code(l_J),
        exception_type_code       = l_exception_type_code(l_J),
	duration_shift_type_code  = l_duration_shift_type_code(l_J),
        duration_shift_unit_code  = l_duration_shift_unit_code(l_J),
        number_of_shift           = l_number_of_shift(l_J),
        start_date                = l_start_date(l_J),
        end_date                  = l_end_date(l_J),
        resource_calendar_percent = l_resource_calendar_percent(l_J),
        non_working_day_flag      = l_non_working_day_flag(l_J) ,
        change_hours_type_code    = l_change_hours_type_code(l_J) ,
        change_calendar_type_code = l_change_calendar_type_code(l_J),
      --  change_calendar_name      = l_change_calendar_name(l_J),
        change_calendar_id        = l_change_calendar_id(l_J),
        monday_hours              = l_monday_hours(l_J),
        tuesday_hours             = l_tuesday_hours(l_J),
        wednesday_hours           = l_wednesday_hours(l_J),
        thursday_hours            = l_thursday_hours(l_J),
        friday_hours              = l_friday_hours(l_J),
        saturday_hours            = l_saturday_hours(l_J),
        sunday_hours              = l_sunday_hours(l_J),
        last_update_date          = sysdate,
        last_update_by            = fnd_global.user_id,
        last_update_login         = fnd_global.login_id
 WHERE  rowid                     = l_exceptrowid(l_J);

EXCEPTION
 WHEN l_empty_tab_record THEN
  NULL;
 WHEN OTHERS THEN
 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCH_EXCEPT_PKG',
                           p_procedure_name     => 'update_rows');
 raise;


END update_rows;


-- This procedure will update the record into the pa_schedule_exception table
-- Input parameters
-- Parameters                   Type           Required Description
-- P_Exceptrowid                ROWID          YES      Id for the exception records
-- P_Schedule_Exception_Id      NUMBER         YES      Id for the schedule records
-- P_Calendar_Id                NUMBER         YES      Id for that calendar which is associated to this assignmen
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
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

 UPDATE PA_SCHEDULE_EXCEPTIONS
 SET
        calendar_id               = p_calendar_id,
        assignment_id             = p_assignment_id,
        project_id                = p_project_id,
        schedule_type_code        = p_schedule_type_code,
        status_code               = p_assignment_status_code,
        exception_type_code       = p_exception_type_code,
        duration_shift_type_code  = p_duration_shift_type_code,
        duration_shift_unit_code  = p_duration_shift_unit_code,
        number_of_shift           = p_number_of_shift,
        start_date                = trunc(p_start_date),
        end_date                  = trunc(p_end_date),
        resource_calendar_percent = p_resource_calendar_percent   ,
        non_working_day_flag      = p_non_working_day_flag     ,
        change_hours_type_code    = p_change_hours_type_code      ,
        change_calendar_type_code = p_change_calendar_type_code,
        -- change_calendar_name      = p_change_calendar_name,
        change_calendar_id        = p_change_calendar_id,
        monday_hours              = p_monday_hours,
        tuesday_hours             = p_tuesday_hours,
        wednesday_hours           = p_wednesday_hours,
        thursday_hours            = p_thursday_hours,
        friday_hours              = p_friday_hours,
        saturday_hours            = p_saturday_hours,
        sunday_hours              = p_sunday_hours,
        last_update_date          = sysdate,
        last_update_by            = fnd_global.user_id,
        last_update_login         = fnd_global.login_id
 WHERE  rowid = p_exceptrowid;


EXCEPTION
 WHEN OTHERS THEN
 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCH_EXCEPT_PKG',
                           p_procedure_name     => 'update_rows');
 raise;

END update_rows;

-- This procedure will update the record into the pa_schedule_exception table
-- Input parameters
-- Parameters                   Type           Required Description
-- P_Schedule_Exception_Id      NUMBER         YES      Id for the schedule records
-- P_Calendar_Id                NUMBER         YES      Id for that calendar which is associated to this assignmen
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
       --  p_change_calendar_name             IN varchar2 DEFAULT NULL ,
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
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

 UPDATE PA_SCHEDULE_EXCEPTIONS
 SET
        calendar_id             = p_calendar_id,
        assignment_id           = p_assignment_id,
        project_id              = p_project_id,
        schedule_type_code      = p_schedule_type_code,
        status_code             = p_assignment_status_code,
        exception_type_code       = p_exception_type_code,
        duration_shift_type_code  = p_duration_shift_type_code,
        duration_shift_unit_code  = p_duration_shift_unit_code,
        number_of_shift           = p_number_of_shift,
        start_date                = trunc(p_start_date),
        end_date                  = trunc(p_end_date),
        resource_calendar_percent = p_resource_calendar_percent   ,
        non_working_day_flag      = p_non_working_day_flag     ,
        change_hours_type_code    = p_change_hours_type_code      ,
        change_calendar_type_code = p_change_calendar_type_code,
       -- change_calendar_name      = p_change_calendar_name,
        change_calendar_id        = p_change_calendar_id,
        monday_hours            = p_monday_hours,
        tuesday_hours           = p_tuesday_hours,
        wednesday_hours         = p_wednesday_hours,
        thursday_hours          = p_thursday_hours,
        friday_hours            = p_friday_hours,
        saturday_hours          = p_saturday_hours,
        sunday_hours            = p_sunday_hours,
        last_update_date        = sysdate,
        last_update_by          = fnd_global.user_id,
        last_update_login       = fnd_global.login_id
 WHERE  schedule_exception_id = p_schedule_exception_id;


EXCEPTION
 WHEN OTHERS THEN
 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCH_EXCEPT_PKG',
                           p_procedure_name     => 'update_rows');
 raise;

END update_rows;

-- This procedure will delete the records in pa_schedule_exceptions table
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Sch_Except_Record_Tab      TABLETYPE      YES       It contains the exception  record
--

PROCEDURE delete_rows ( p_sch_except_record_tab         IN   PA_SCHEDULE_GLOB.SchExceptTabTyp,
                        x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
        l_schedule_exception_id              PA_PLSQL_DATATYPES.IdTabTyp;

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

 /* Checking for the empty table of record */
IF (p_sch_except_record_tab.count = 0 ) THEN
  raise l_empty_tab_record;
END IF;

FOR l_J IN p_sch_except_record_tab.first..p_sch_except_record_tab.last LOOP
l_schedule_exception_id(l_J) := p_sch_except_record_tab(l_J).schedule_exception_id;

END LOOP;

FORALL l_J IN l_schedule_exception_id.first..l_schedule_exception_id.last
DELETE FROM PA_SCHEDULE_EXCEPTIONS WHERE schedule_exception_id = l_schedule_exception_id(l_J);

EXCEPTION
 WHEN OTHERS THEN
 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCH_EXCEPT_PKG',
                           p_procedure_name     => 'delete_rows');
 raise;

END delete_rows;

-- This procedure will delete the records in pa_schedule_exceptions table
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Schedule_Exception_Id      NUMBER         YES       It schedule exception id
--

PROCEDURE delete_rows
        ( p_schedule_exception_id                    IN Number          ,
        x_return_status              OUT  NOCOPY VARCHAR2          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

DELETE
  FROM PA_SCHEDULE_EXCEPTIONS
  WHERE schedule_exception_id = p_schedule_exception_id;

EXCEPTION
 WHEN OTHERS THEN
 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCH_EXCEPT_PKG',
                           p_procedure_name     => 'delete_rows');
 raise;

END delete_rows;

-- This procedure will delete the records in pa_schedule_exceptions table
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Exceptrowid                ROWID          YES       It exception row id
--

PROCEDURE delete_rows
        ( p_exceptrowid              IN rowid               ,
        x_return_status              OUT  NOCOPY VARCHAR2          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

DELETE
  FROM PA_SCHEDULE_EXCEPTIONS
  WHERE rowid = p_exceptrowid;

EXCEPTION
 WHEN OTHERS THEN
 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCH_EXCEPT_PKG',
                           p_procedure_name     => 'delete_rows');
 raise;


END delete_rows;
END PA_SCH_EXCEPT_PKG;

/
