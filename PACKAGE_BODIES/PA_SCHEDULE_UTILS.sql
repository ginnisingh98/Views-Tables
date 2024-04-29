--------------------------------------------------------
--  DDL for Package Body PA_SCHEDULE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_SCHEDULE_UTILS" as
/* $Header: PARGUTLB.pls 120.2 2005/08/25 03:40:56 sunkalya noship $  */

P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

l_empty_tab_record    EXCEPTION; -- Variable to raise the exception if  the passing table of records is empty

-- This procedure will copy the one record from another
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Sch_Record_Tab             ScheduleTabTyp YES       It contains the schedule records
-- P_Start_Id                   NUMBER           YES     stat id of the schedule record for which schedule is to be copied
-- P_End_id                     NUMBER           YES     end id of the schedule to which schedule is to be copied
-- In Out parameters
-- X_Sch_Record_Tab             ScheduleTabTyp YES       It stores the copied scheduled records
--

PROCEDURE copy_schedule_rec_tab ( p_sch_record_tab         IN   PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                  p_start_id               IN   NUMBER,
                                  p_end_id                 IN   NUMBER,
                                  x_sch_record_tab         IN OUT  NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                  x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data               OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

   l_oidx        NUMBER;
   l_iidx        NUMBER;

BEGIN
   l_oidx       := 1;
   l_iidx       := p_start_id;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_sch_record_tab.delete;

/* Checking for the empty table of record */
IF (p_sch_record_tab.count = 0 ) THEN
  raise l_empty_tab_record;
END IF;

/* Copying all the structure elements */
Loop

x_sch_record_tab(l_oidx).schrowid                      := p_sch_record_tab(l_iidx).schrowid;
x_sch_record_tab(l_oidx).schedule_id                   := p_sch_record_tab(l_iidx).schedule_id;
x_sch_record_tab(l_oidx).calendar_id                   := p_sch_record_tab(l_iidx).calendar_id;
x_sch_record_tab(l_oidx).assignment_id                 := p_sch_record_tab(l_iidx).assignment_id;
x_sch_record_tab(l_oidx).project_id                    := p_sch_record_tab(l_iidx).project_id;
x_sch_record_tab(l_oidx).schedule_type_code            := p_sch_record_tab(l_iidx).schedule_type_code;
x_sch_record_tab(l_oidx).assignment_status_code        := p_sch_record_tab(l_iidx).assignment_status_code;
x_sch_record_tab(l_oidx).system_status_code            := p_sch_record_tab(l_iidx).system_status_code;
x_sch_record_tab(l_oidx).start_date                    := p_sch_record_tab(l_iidx).start_date;
x_sch_record_tab(l_oidx).end_date                      := p_sch_record_tab(l_iidx).end_date;
x_sch_record_tab(l_oidx).monday_hours                  := p_sch_record_tab(l_iidx).monday_hours;
x_sch_record_tab(l_oidx).tuesday_hours                 := p_sch_record_tab(l_iidx).tuesday_hours;
x_sch_record_tab(l_oidx).wednesday_hours               := p_sch_record_tab(l_iidx).wednesday_hours;
x_sch_record_tab(l_oidx).thursday_hours                := p_sch_record_tab(l_iidx).thursday_hours;
x_sch_record_tab(l_oidx).friday_hours                  := p_sch_record_tab(l_iidx).friday_hours;
x_sch_record_tab(l_oidx).saturday_hours                := p_sch_record_tab(l_iidx).saturday_hours;
x_sch_record_tab(l_oidx).sunday_hours                  := p_sch_record_tab(l_iidx).sunday_hours;
x_sch_record_tab(l_oidx).change_type_code              := p_sch_record_tab(l_iidx).change_type_code;


IF (p_end_id = l_iidx)then
   EXIT;
ELSE
   l_iidx := p_sch_record_tab.next(l_iidx);
   l_oidx := l_oidx + 1;
END IF;

END LOOP;


EXCEPTION
 WHEN l_empty_tab_record THEN
  null;
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCHEDULE_UTILS',
                           p_procedure_name     => 'copy_schedule_rec_tab');
  raise;

END copy_schedule_rec_tab;


-- This procedure will append the records
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Sch_Record_Tab             ScheduleTabTyp YES       It contains the schedule records
-- P_Start_Id                   NUMBER           YES     stat id of the schedule record
-- P_End_id                     NUMBER           YES     end id of the schedule record
-- In Out parameters
-- PX_Sch_Record_Tab            ScheduleTabTyp YES       It stores the added scheduled records
--

PROCEDURE add_schedule_rec_tab  ( p_sch_record_tab         IN  PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                  p_start_id               IN  NUMBER,
                                  p_end_id                 IN  NUMBER,
                                  px_sch_record_tab        IN OUT NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                  x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data               OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
   l_oidx        NUMBER;
   l_iidx        NUMBER;
   l_cnt         NUMBER;

BEGIN
   l_iidx       := p_start_id;
   l_cnt   := px_sch_record_tab.count;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

/* Validating the rows in the table for Null */
 IF (l_cnt = 0 ) THEN
   l_oidx := 1;
 ELSE
  l_oidx  := px_sch_record_tab.last + 1;
 END IF;

/* Appending all the structure elements */
Loop

 px_sch_record_tab(l_oidx).schrowid                      := p_sch_record_tab(l_iidx).schrowid;
 px_sch_record_tab(l_oidx).schedule_id                   := p_sch_record_tab(l_iidx).schedule_id;
 px_sch_record_tab(l_oidx).calendar_id                   := p_sch_record_tab(l_iidx).calendar_id;
 px_sch_record_tab(l_oidx).assignment_id                 := p_sch_record_tab(l_iidx).assignment_id;
 px_sch_record_tab(l_oidx).project_id                    := p_sch_record_tab(l_iidx).project_id;
 px_sch_record_tab(l_oidx).schedule_type_code            := p_sch_record_tab(l_iidx).schedule_type_code;
 px_sch_record_tab(l_oidx).assignment_status_code        := p_sch_record_tab(l_iidx).assignment_status_code;
 px_sch_record_tab(l_oidx).system_status_code            := p_sch_record_tab(l_iidx).system_status_code;
 px_sch_record_tab(l_oidx).start_date                    := p_sch_record_tab(l_iidx).start_date;
 px_sch_record_tab(l_oidx).end_date                      := p_sch_record_tab(l_iidx).end_date;
 px_sch_record_tab(l_oidx).monday_hours                  := p_sch_record_tab(l_iidx).monday_hours;
 px_sch_record_tab(l_oidx).tuesday_hours                 := p_sch_record_tab(l_iidx).tuesday_hours;
 px_sch_record_tab(l_oidx).wednesday_hours               := p_sch_record_tab(l_iidx).wednesday_hours;
 px_sch_record_tab(l_oidx).thursday_hours                := p_sch_record_tab(l_iidx).thursday_hours;
 px_sch_record_tab(l_oidx).friday_hours                  := p_sch_record_tab(l_iidx).friday_hours;
 px_sch_record_tab(l_oidx).saturday_hours                := p_sch_record_tab(l_iidx).saturday_hours;
 px_sch_record_tab(l_oidx).sunday_hours                  := p_sch_record_tab(l_iidx).sunday_hours;
 px_sch_record_tab(l_oidx).change_type_code              := p_sch_record_tab(l_iidx).change_type_code;

IF (p_end_id = l_iidx)then
   EXIT;
ELSE
   l_iidx := p_sch_record_tab.next(l_iidx);
   l_oidx := l_oidx + 1;
END IF;

END LOOP;

EXCEPTION
 WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCHEDULE_UTILS',
                           p_procedure_name     => 'add_schedule_rec_tab');
  raise;

END add_schedule_rec_tab;


-- This procedure will delete  the records
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Start_Id                   NUMBER           YES     stat id of the schedule record
-- P_End_id                     NUMBER           YES     end id of the schedule record
--                                                       marked for deletion
-- In Out parameters
-- PX_Sch_Record_Tab           ScheduleTabTyp  YES       It stores the scheduled recordswhich are marked for deletion
--

PROCEDURE  mark_del_sch_rec_tab ( p_start_id               IN  NUMBER,
                                  p_end_id                 IN  NUMBER,
                                  px_sch_record_tab        IN OUT NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                  x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data               OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
   l_iidx        NUMBER;

BEGIN
   l_iidx       := p_start_id;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

/* Marking for deletion  */
LOOP

 px_sch_record_tab(l_iidx).change_type_code  := 'D';


IF (p_end_id = l_iidx)then
   EXIT;
ELSE
   l_iidx := px_sch_record_tab.next(l_iidx);
END IF;

END LOOP;

EXCEPTION
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCHEDULE_UTILS',
                           p_procedure_name     => 'mark_del_sch_rec_tab');
  raise;

END mark_del_sch_rec_tab;


-- This procedure will seperate delete or non delete records
-- Input parameters
-- Parameters                   Type                Required  Description
-- P_Sch_Record_Tab             ScheduleTabTyp      YES       It contains the schedule records
-- Out parameters
-- X_Del_Sch_Record_Tab         ScheduleTabTyp      YES       It stores scheduled records which are marked for deletion
-- X_Sch_Record_Tab             ScheduleTabTyp      YES       It stores scheduled records whic are marked for insertion
--                                                            and updation
--

PROCEDURE sep_del_sch_rec_tab   ( p_sch_record_tab         IN   PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                  x_del_sch_rec_tab        IN OUT  NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                  x_sch_record_tab         OUT  NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                  x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data               OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
   l_didx        NUMBER;
   l_cidx        NUMBER;
   l_iidx        NUMBER;
BEGIN

   IF (x_del_sch_rec_tab.COUNT > 0) THEN
	l_didx     := x_del_sch_rec_tab.count + 1; --Added for bug 4176968

	 -- l_didx     := x_del_sch_rec_tab.FIRST + 1; Commented for bug 4176968
   ELSE
     l_didx     := 1;
   END IF;

   l_cidx       := 1;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (p_sch_record_tab.count = 0 ) THEN
    Raise l_empty_tab_record;
   ELSE
    l_iidx       := p_sch_record_tab.first;
   END IF;

/* Seprating the rows which are marked for deletion  */
Loop

  IF (p_sch_record_tab(l_iidx).change_type_code = 'D' ) THEN

    x_del_sch_rec_tab(l_didx).schrowid                      := p_sch_record_tab(l_iidx).schrowid;
    x_del_sch_rec_tab(l_didx).schedule_id                   := p_sch_record_tab(l_iidx).schedule_id;
    x_del_sch_rec_tab(l_didx).calendar_id                   := p_sch_record_tab(l_iidx).calendar_id;
    x_del_sch_rec_tab(l_didx).assignment_id                 := p_sch_record_tab(l_iidx).assignment_id;
    x_del_sch_rec_tab(l_didx).project_id                    := p_sch_record_tab(l_iidx).project_id;
    x_del_sch_rec_tab(l_didx).schedule_type_code            := p_sch_record_tab(l_iidx).schedule_type_code;
    x_del_sch_rec_tab(l_didx).assignment_status_code        := p_sch_record_tab(l_iidx).assignment_status_code;
    x_del_sch_rec_tab(l_didx).system_status_code            := p_sch_record_tab(l_iidx).system_status_code;
    x_del_sch_rec_tab(l_didx).start_date                    := p_sch_record_tab(l_iidx).start_date;
    x_del_sch_rec_tab(l_didx).end_date                      := p_sch_record_tab(l_iidx).end_date;
    x_del_sch_rec_tab(l_didx).monday_hours                  := p_sch_record_tab(l_iidx).monday_hours;
    x_del_sch_rec_tab(l_didx).tuesday_hours                 := p_sch_record_tab(l_iidx).tuesday_hours;
    x_del_sch_rec_tab(l_didx).wednesday_hours               := p_sch_record_tab(l_iidx).wednesday_hours;
    x_del_sch_rec_tab(l_didx).thursday_hours                := p_sch_record_tab(l_iidx).thursday_hours;
    x_del_sch_rec_tab(l_didx).friday_hours                  := p_sch_record_tab(l_iidx).friday_hours;
    x_del_sch_rec_tab(l_didx).saturday_hours                := p_sch_record_tab(l_iidx).saturday_hours;
    x_del_sch_rec_tab(l_didx).sunday_hours                  := p_sch_record_tab(l_iidx).sunday_hours;
    x_del_sch_rec_tab(l_didx).change_type_code              := p_sch_record_tab(l_iidx).change_type_code;

    l_didx := l_didx + 1;

  ELSE

    x_sch_record_tab(l_cidx).schrowid                      := p_sch_record_tab(l_iidx).schrowid;
    x_sch_record_tab(l_cidx).schedule_id                   := p_sch_record_tab(l_iidx).schedule_id;
    x_sch_record_tab(l_cidx).calendar_id                   := p_sch_record_tab(l_iidx).calendar_id;
    x_sch_record_tab(l_cidx).assignment_id                 := p_sch_record_tab(l_iidx).assignment_id;
    x_sch_record_tab(l_cidx).project_id                    := p_sch_record_tab(l_iidx).project_id;
    x_sch_record_tab(l_cidx).schedule_type_code            := p_sch_record_tab(l_iidx).schedule_type_code;
    x_sch_record_tab(l_cidx).assignment_status_code        := p_sch_record_tab(l_iidx).assignment_status_code;
    x_sch_record_tab(l_cidx).system_status_code            := p_sch_record_tab(l_iidx).system_status_code;
    x_sch_record_tab(l_cidx).start_date                    := p_sch_record_tab(l_iidx).start_date;
    x_sch_record_tab(l_cidx).end_date                      := p_sch_record_tab(l_iidx).end_date;
    x_sch_record_tab(l_cidx).monday_hours                  := p_sch_record_tab(l_iidx).monday_hours;
    x_sch_record_tab(l_cidx).tuesday_hours                 := p_sch_record_tab(l_iidx).tuesday_hours;
    x_sch_record_tab(l_cidx).wednesday_hours               := p_sch_record_tab(l_iidx).wednesday_hours;
    x_sch_record_tab(l_cidx).thursday_hours                := p_sch_record_tab(l_iidx).thursday_hours;
    x_sch_record_tab(l_cidx).friday_hours                  := p_sch_record_tab(l_iidx).friday_hours;
    x_sch_record_tab(l_cidx).saturday_hours                := p_sch_record_tab(l_iidx).saturday_hours;
    x_sch_record_tab(l_cidx).sunday_hours                  := p_sch_record_tab(l_iidx).sunday_hours;
    x_sch_record_tab(l_cidx).change_type_code              := p_sch_record_tab(l_iidx).change_type_code;

    l_cidx := l_cidx + 1;

  END IF;

  IF (l_iidx = p_sch_record_tab.last) THEN
     EXIT;
  ELSE
     l_iidx := p_sch_record_tab.next(l_iidx);
  END IF;

END LOOP;

EXCEPTION
 WHEN l_empty_tab_record THEN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  NULL;
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCHEDULE_UTILS',
                           p_procedure_name     => 'sep_del_sch_rec_tab');
  raise;

END sep_del_sch_rec_tab;

-- This procedure will update records
-- Input parameters
-- Parameters                   Type           Required Description
-- P_Project_Id                 NUMBER         YES      project id of the associated calendar
-- P_Calendar_Id                NUMBER         YES      Id for that calendar which is associated to this assignmen
-- P_Assignment_Id              NUMBER         YES      Assignment id of the schedule records
-- P_Schedule_Type_Code         VARCHAR2       YES      It is schedule type code e.g changed hours/changed duration
-- P_Assignment_Status_Code     VARCHAR2       YES      Status of the assignment e.g OPEN/CONFIRM/PROVISIONAL
-- P_Start_Date                 DATE           YES      stat date of the schedule from which schedule is to be updated
-- P_End_Date                   DATE           YES      end date of the schedule to which schedule is to be updated
-- P_Monday_Hours               NUMBER         YES      No. of hours of this day
-- P_Tuesday_Hours              NUMBER         YES      No. of hours of this day
-- P_Wednesday_Hours            NUMBER         YES      No. of hours of this day
-- P_Thursday_Hours             NUMBER         YES      No. of hours of this day
-- P_Friday_Hours               NUMBER         YES      No. of hours of this day
-- P_Saturday_Hours             NUMBER         YES      No. of hours of this day
-- P_Sunday_Hours               NUMBER         YES      No. of hours of this day
-- P_Change_Type_Code           VARCHAR2       YES      It is change dtype code e.g U,I or D i.e. update insert
-- In Out parameters
-- PX_Sch_Record_Tab            ScheduleTabTyp YES       It stores the updated scheduled records
--

PROCEDURE update_sch_rec_tab  ( px_sch_record_tab           IN  OUT NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                p_project_id                IN       NUMBER   DEFAULT NULL,
                                p_calendar_id               IN       NUMBER   DEFAULT NULL,
                                p_assignment_id             IN       NUMBER   DEFAULT NULL,
                                p_schedule_type_code        IN       VARCHAR2 DEFAULT NULL,
                                p_assignment_status_code    IN       VARCHAR2 DEFAULT NULL,
                                p_system_status_code        IN       VARCHAR2 DEFAULT NULL,
                                p_start_date                IN       DATE     DEFAULT NULL,
                                p_end_date                  IN       DATE     DEFAULT NULL,
                                p_monday_hours              IN       NUMBER   DEFAULT NULL,
                                p_tuesday_hours             IN       NUMBER   DEFAULT NULL,
                                p_wednesday_hours           IN       NUMBER   DEFAULT NULL,
                                p_thursday_hours            IN       NUMBER   DEFAULT NULL,
                                p_friday_hours              IN       NUMBER   DEFAULT NULL,
                                p_saturday_hours            IN       NUMBER   DEFAULT NULL,
                                p_sunday_hours              IN       NUMBER   DEFAULT NULL,
                                p_change_type_code          IN       VARCHAR2 DEFAULT NULL,
                                x_return_status             OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count                 OUT      NOCOPY NUMBER , --File.Sql.39 bug 4440895
                                x_msg_data                  OUT      NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

l_iidx   NUMBER;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF (px_sch_record_tab.count = 0) THEN
    Raise l_empty_tab_record;
   ELSE
    l_iidx := px_sch_record_tab.first;
   END IF;


LOOP

/* Updating the Rows with the given data */
px_sch_record_tab(l_iidx).project_id              := NVL(p_project_id,px_sch_record_tab(l_iidx).project_id);
px_sch_record_tab(l_iidx).calendar_id             := NVL(p_calendar_id,px_sch_record_tab(l_iidx).calendar_id);
px_sch_record_tab(l_iidx).assignment_id           := NVL(p_assignment_id,px_sch_record_tab(l_iidx).assignment_id);
px_sch_record_tab(l_iidx).schedule_type_code      := NVL(p_schedule_type_code,px_sch_record_tab(l_iidx).schedule_type_code);
px_sch_record_tab(l_iidx).assignment_status_code  := NVL(p_assignment_status_code,px_sch_record_tab(l_iidx).assignment_status_code);
px_sch_record_tab(l_iidx).system_status_code      := NVL(p_system_status_code,px_sch_record_tab(l_iidx).system_status_code);
px_sch_record_tab(l_iidx).start_date              := NVL(p_start_date,px_sch_record_tab(l_iidx).start_date);
px_sch_record_tab(l_iidx).end_date                := NVL(p_end_date,px_sch_record_tab(l_iidx).end_date);
px_sch_record_tab(l_iidx).monday_hours            := NVL(p_monday_hours,px_sch_record_tab(l_iidx).monday_hours);
px_sch_record_tab(l_iidx).tuesday_hours           := NVL(p_tuesday_hours,px_sch_record_tab(l_iidx).tuesday_hours);
px_sch_record_tab(l_iidx).wednesday_hours         := NVL(p_wednesday_hours,px_sch_record_tab(l_iidx).wednesday_hours);
px_sch_record_tab(l_iidx).thursday_hours          := NVL(p_thursday_hours,px_sch_record_tab(l_iidx).thursday_hours);
px_sch_record_tab(l_iidx).friday_hours            := NVL(p_friday_hours,px_sch_record_tab(l_iidx).friday_hours);
px_sch_record_tab(l_iidx).saturday_hours          := NVL(p_saturday_hours,px_sch_record_tab(l_iidx).saturday_hours);
px_sch_record_tab(l_iidx).sunday_hours            := NVL(p_sunday_hours,px_sch_record_tab(l_iidx).sunday_hours);
px_sch_record_tab(l_iidx).change_type_code        := NVL(p_change_type_code,px_sch_record_tab(l_iidx).change_type_code);

IF (l_iidx = px_sch_record_tab.last) THEN
  EXIT;
ELSE
  l_iidx := px_sch_record_tab.next(l_iidx);
END IF;

END LOOP;

EXCEPTION
  WHEN l_empty_tab_record THEN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   NULL;
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCHEDULE_UTILS',
                           p_procedure_name     => 'update_sch_rec_tab');
  raise;


END update_sch_rec_tab;

-- This procedure will apply percentage on the basis of resource availabilty
-- Input parameters
-- Parameters                   Type           Required Description
-- P_Percentage                 NUMBER         YES      It is percentage
-- In Out parameters
-- PX_Sch_Record_Tab            ScheduleTabTyp YES      It stores the updated scheduled records
--
PROCEDURE apply_percentage    ( px_sch_record_tab           IN  OUT NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                p_percentage                IN       NUMBER   ,
                                x_return_status             OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count                 OUT      NOCOPY NUMBER , --File.Sql.39 bug 4440895
                                x_msg_data                  OUT      NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

l_iidx   NUMBER;

BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
 IF (px_sch_record_tab.count = 0) THEN
   Raise l_empty_tab_record;
 ELSE
  l_iidx := px_sch_record_tab.first;
 END IF;

LOOP

/* Applying percentage on the Rows with the given data */
px_sch_record_tab(l_iidx).monday_hours            := (p_percentage/100) * ( px_sch_record_tab(l_iidx).monday_hours);
px_sch_record_tab(l_iidx).tuesday_hours           := (p_percentage/100)  * ( px_sch_record_tab(l_iidx).tuesday_hours);
px_sch_record_tab(l_iidx).wednesday_hours         := (p_percentage/100) * ( px_sch_record_tab(l_iidx).wednesday_hours);
px_sch_record_tab(l_iidx).thursday_hours          := (p_percentage/100) * ( px_sch_record_tab(l_iidx).thursday_hours);
px_sch_record_tab(l_iidx).friday_hours            := (p_percentage/100) * ( px_sch_record_tab(l_iidx).friday_hours);
px_sch_record_tab(l_iidx).saturday_hours          := (p_percentage/100) * ( px_sch_record_tab(l_iidx).saturday_hours);
px_sch_record_tab(l_iidx).sunday_hours            := (p_percentage/100) * ( px_sch_record_tab(l_iidx).sunday_hours);

IF (l_iidx = px_sch_record_tab.last) THEN
  EXIT;
ELSE
  l_iidx := px_sch_record_tab.next(l_iidx);
END IF;

END LOOP;

EXCEPTION
 WHEN l_empty_tab_record THEN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   NULL;
 WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCHEDULE_UTILS',
                           p_procedure_name     => 'apply_percentage');
  raise;


END apply_percentage;


-- This procedure will copy the exception records
-- Input parameters
-- Parameters                   Type                 Required  Description
-- P_Except_Record              SchExceptRecord      YES       It contains the exceptions
-- Out Parameters
-- X_Except_Record              SchExceptRecord      YES       It stores the copied exception records
--

PROCEDURE copy_except_record (   p_except_record           IN   PA_SCHEDULE_GLOB.SchExceptRecord,
                                  x_except_record          OUT  NOCOPY PA_SCHEDULE_GLOB.SchExceptRecord,
                                  x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data               OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS


BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

/* Copying all the structure elements */

x_except_record.exceptRowid                   := p_except_record.exceptRowid;
x_except_record.schedule_exception_id         := p_except_record.schedule_exception_id;
x_except_record.calendar_id                   := p_except_record.calendar_id;
x_except_record.assignment_id                 := p_except_record.assignment_id;
x_except_record.project_id                    := p_except_record.project_id;
x_except_record.exception_type_code           := p_except_record.exception_type_code;
x_except_record.schedule_type_code            := p_except_record.schedule_type_code;
x_except_record.assignment_status_code        := p_except_record.assignment_status_code;
x_except_record.start_date                    := p_except_record.start_date;
x_except_record.end_date                      := p_except_record.end_date;
x_except_record.resource_calendar_percent     := p_except_record.resource_calendar_percent;
x_except_record.non_working_day_flag          := p_except_record.non_working_day_flag;
x_except_record.change_hours_type_code        := p_except_record.change_hours_type_code;
x_except_record.change_calendar_type_code     := p_except_record.change_calendar_type_code;
--x_except_record.change_calendar_name          := p_except_record.change_calendar_name;
x_except_record.change_calendar_id            := p_except_record.change_calendar_id;
x_except_record.duration_shift_type_code      := p_except_record.duration_shift_type_code;
x_except_record.duration_shift_unit_code      := p_except_record.duration_shift_unit_code;
x_except_record.number_of_shift               := p_except_record.number_of_shift;
x_except_record.monday_hours                  := p_except_record.monday_hours;
x_except_record.tuesday_hours                 := p_except_record.tuesday_hours;
x_except_record.wednesday_hours               := p_except_record.wednesday_hours;
x_except_record.thursday_hours                := p_except_record.thursday_hours;
x_except_record.friday_hours                  := p_except_record.friday_hours;
x_except_record.saturday_hours                := p_except_record.saturday_hours;
x_except_record.sunday_hours                  := p_except_record.sunday_hours;

EXCEPTION
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCHEDULE_UTILS',
                           p_procedure_name     => 'copy_except_record');
  raise;

END copy_except_record;

-- This procedure will update the exception records
-- Input parameters
-- Parameters                   Type           Required Description
-- P_Project_Id                 NUMBER         YES      project id of the associated calendar
-- P_Calendar_Id                NUMBER         YES      Id for that calendar which is associated to this assignmen
-- P_Assignment_Id              NUMBER         YES      Assignment id of the exception records
-- P_Schedule_Type_Code         VARCHAR2       YES      It is schedule type code e.g changed hours/changed duration
-- P_Assignment_Status_Code     VARCHAR2       YES      Status of the assignment e.g OPEN/CONFIRM/PROVISIONAL
-- P_Start_Date                 DATE           YES      stat date of the schedule from which exception is to
--                                                      be updated
-- P_End_Date                   DATE           YES      end date of the schedule to which exception is to be updated
-- P_Resource_Calendar_Percent  NUMBER         YES      it is the resource calendar percentage
-- P_Non_Working_Flag           VARCHAR2       YES      It is non working day flag which means should include or not
--                                                      i.e Y,N.
-- P_Change_Hours_Type_Code     VARCHAR2       YES      It is change hours type code which is used when changeing the
--                                                       hours e.g. HOURS or PERCENTAGE
-- P_Monday_Hours               NUMBER         YES      No. of hours of this day
-- P_Tuesday_Hours              NUMBER         YES      No. of hours of this day
-- P_Wednesday_Hours            NUMBER         YES      No. of hours of this day
-- P_Thursday_Hours             NUMBER         YES      No. of hours of this day
-- P_Friday_Hours               NUMBER         YES      No. of hours of this day
-- P_Saturday_Hours             NUMBER         YES      No. of hours of this day
-- P_Sunday_Hours               NUMBER         YES      No. of hours of this day
-- In Out parameters
-- PX_Except_Record             SchExceptRecord YES       It stores the updated exception records
--
PROCEDURE update_except_record( px_except_record           IN  OUT NOCOPY PA_SCHEDULE_GLOB.SchExceptRecord,
                                p_project_id                IN       NUMBER   DEFAULT NULL,
                                p_calendar_id               IN       NUMBER   DEFAULT NULL,
                                p_assignment_id             IN       NUMBER   DEFAULT NULL,
                                p_schedule_type_code        IN       VARCHAR2 DEFAULT NULL,
                                p_assignment_status_code    IN       VARCHAR2 DEFAULT NULL,
                                p_start_date                IN       DATE     DEFAULT NULL,
                                p_end_date                  IN       DATE     DEFAULT NULL,
                                p_resource_calendar_percent IN       NUMBER   DEFAULT NULL,
                                p_non_working_day_flag      IN       VARCHAR2 DEFAULT NULL,
                                p_change_hours_type_code    IN       VARCHAR2 DEFAULT NULL,
                                p_monday_hours              IN       NUMBER   DEFAULT NULL,
                                p_tuesday_hours             IN       NUMBER   DEFAULT NULL,
                                p_wednesday_hours           IN       NUMBER   DEFAULT NULL,
                                p_thursday_hours            IN       NUMBER   DEFAULT NULL,
                                p_friday_hours              IN       NUMBER   DEFAULT NULL,
                                p_saturday_hours            IN       NUMBER   DEFAULT NULL,
                                p_sunday_hours              IN       NUMBER   DEFAULT NULL,
                                x_return_status             OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count                 OUT      NOCOPY NUMBER , --File.Sql.39 bug 4440895
                                x_msg_data                  OUT      NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS


BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

px_except_record.project_id              := NVL(p_project_id,px_except_record.project_id);
px_except_record.calendar_id             := NVL(p_calendar_id,px_except_record.calendar_id);
px_except_record.assignment_id           := NVL(p_assignment_id,px_except_record.assignment_id);
px_except_record.schedule_type_code      := NVL(p_schedule_type_code,px_except_record.schedule_type_code);
px_except_record.assignment_status_code  := NVL(p_assignment_status_code,px_except_record.assignment_status_code);
px_except_record.start_date              := NVL(p_start_date,px_except_record.start_date);
px_except_record.end_date                := NVL(p_end_date,px_except_record.end_date);
px_except_record.monday_hours            := NVL(p_monday_hours,px_except_record.monday_hours);
px_except_record.tuesday_hours           := NVL(p_tuesday_hours,px_except_record.tuesday_hours);
px_except_record.wednesday_hours         := NVL(p_wednesday_hours,px_except_record.wednesday_hours);
px_except_record.thursday_hours          := NVL(p_thursday_hours,px_except_record.thursday_hours);
px_except_record.friday_hours            := NVL(p_friday_hours,px_except_record.friday_hours);
px_except_record.saturday_hours          := NVL(p_saturday_hours,px_except_record.saturday_hours);
px_except_record.sunday_hours            := NVL(p_sunday_hours,px_except_record.sunday_hours);

EXCEPTION
  WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCHEDULE_UTILS',
                           p_procedure_name     => 'update_except_record');
  raise;


END update_except_record;

-- This procedure will print the passed message it is overloaded procedure
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Level1                     NUMBER         YES       it is level used for suppresing the message
-- P_Msg1                       VARCHAR2       YES       it is used to take message text
--

PROCEDURE log_message( level1          IN NUMBER,
                       msg1            IN   VARCHAR2)

IS
BEGIN
/*
  IF( level1 <= 10 ) THEN
    IF ( level1 = 2 ) THEN
      DBMS_OUTPUT.PUT_LINE('2...........'||msg1);
    ELSE
     DBMS_OUTPUT.PUT_LINE(msg1);
    END IF;
  END IF;
*/

IF (P_DEBUG_MODE ='Y') THEN
  PA_DEBUG.WRITE_LOG(
    x_module => 'pa.plsql.pa_schedule_pub',
    x_msg => msg1,
    x_log_level => 6);
  pa_debug.write_file('print_message: ' || 'Log :'||msg1);
 end if;
END log_message;

PROCEDURE debug(p_module IN VARCHAR2,
                p_msg IN VARCHAR2,
                p_log_level IN NUMBER DEFAULT 6) IS
BEGIN
    -- dbms_output.put_line('log : ' || p_module || ' : ' || p_msg);
    IF (P_DEBUG_MODE ='Y') THEN
     PA_DEBUG.WRITE_LOG(
       x_module => p_module,
       x_msg => p_msg,
       x_log_level => p_log_level);
     pa_debug.write_file('print_message: ' || 'Log :'||p_msg);
     end if;
END debug;


PROCEDURE debug(p_msg IN VARCHAR2) IS
BEGIN
   --  dbms_output.put_line('log : '||'pa.plsql.pa_schedule_pvt'|| ' : ' || p_msg);
   IF (P_DEBUG_MODE ='Y') THEN
     PA_DEBUG.WRITE_LOG(
       x_module => 'pa.plsql.pa_schedule_pvt',
       x_msg => p_msg,
       x_log_level => 6);
     pa_debug.write_file('print_message: ' || 'Log :'||p_msg);
     End If;
END debug;


-- This procedure will print the passed message and the structure of the table of records. it is overloaded procedure
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Level1                     NUMBER         YES       it is level used for suppresing the message
-- P_Msg1                       VARCHAR2       YES       it is used to take message text
-- P_Wr_Tab                     ScheduleTabTyp YES       it is used to print the table structure column
--

PROCEDURE log_message( level1          IN NUMBER,
                       msg1            IN   VARCHAR2,
                       wr_tab         IN PA_SCHEDULE_GLOB.ScheduleTabTyp)

IS
BEGIN
 null;
 /*
 IF (pa_schedule_utils.l_print_log )  then
 IF ( level1 <= 1000 ) then
    IF ( wr_tab.count > 0 ) then
      FOR i IN wr_tab.first..wr_tab.last LOOP

        DBMS_OUTPUT.PUT_LINE(msg1||'  '||to_char(wr_tab(i).start_date)||'  '||to_char(wr_tab(i).end_date)
           ||' chg_typ: ' ||wr_tab(i).change_type_code||' mon_hrs: '
           ||to_char(wr_tab(i).monday_hours)||'cal id '||to_char(wr_tab(i).calendar_id));
       END LOOP;
    ELSE
      DBMS_OUTPUT.PUT_LINE(msg1||' COUNT is '||wr_tab.count);
    END IF;
 END IF;
 END IF;
*/
END log_message;

-- This procedure will validate the passed date
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_From_Date                  DATE           YES       it is from date
-- P_To_Date                    DATE           YES       it is to date
--

PROCEDURE validate_date_range( p_from_date          IN    DATE,
                               p_to_date            IN    DATE,
                               x_return_status      OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                               x_error_message_code OUT   NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN

 -- Storing the value for error tracking
  x_return_status := FND_API.G_RET_STS_SUCCESS;

/* validating the date for starting date should not be more then the ending date */
  IF (( p_from_date IS NOT NULL ) AND ( p_to_date IS NOT NULL )) THEN
    IF (p_from_date <= p_to_date ) THEN
      NULL;
    ELSE
     x_return_status      := FND_API.G_RET_STS_ERROR;
     x_error_message_code := 'PA_SCH_INVALID_DATE_RANGE';
     --DBMS_OUTPUT.PUT_LINE('DATE ERROR '||x_return_status);
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     x_return_status      := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCHEDULE_UTILS',
                           p_procedure_name     => 'validate_date_range');
  raise;

END validate_date_range;

-- Function             : Get_num_hours
-- Purpose              : This function returns the number of hours scheduled
--                        for this assignment.  We are also requiring
--                        project_id for performance.

FUNCTION get_num_hours( p_project_id          IN    NUMBER,
                        p_assignment_id       IN    NUMBER) RETURN NUMBER
IS
  l_num_hours NUMBER := null;

BEGIN
   SELECT sum(item_quantity)
    INTO l_num_hours
    FROM pa_forecast_items
    WHERE assignment_id = p_assignment_id
    AND delete_flag = 'N';

  l_num_hours := NVL(l_num_hours, 0);
  return(l_num_hours);

END get_num_hours;


-- Function             : Get_res_calendar
-- Purpose              : Returns the calendar_id for the
--                        calendar associated with this resource for the
--      		  start and end date specified.  Returns null
-- 		 	  if 0 or more than 1 calendar is specified for
--      		  the given dates.
FUNCTION get_res_calendar( p_resource_id IN NUMBER,
			   p_start_date IN DATE,
			   p_end_date IN DATE) RETURN NUMBER
IS
  l_cal_id NUMBER;
  l_tc_start_date DATE;
  l_tc_end_date DATE;
  l_jtf_res_id NUMBER;
  l_temp_start_date DATE;
  l_temp_end_date DATE;
  l_invalid_resource_id EXCEPTION;
  l_count NUMBER;
  x_return_status VARCHAR2(30);
  x_msg_data VARCHAR2(250);

   -- jmarques: 1965288: local vars
   l_resource_organization_id NUMBER;
   l_resource_ou_id NUMBER;
   l_calendar_id NUMBER;

   -- jmarques: 1786935: Modified cursor to include resource_type_code
   -- since resource_id is not unique. Also, added calendar_id > 0
   -- condition so that calendar_id, resource_id index would be used.

  CURSOR C1 IS SELECT  calendar_id
               FROM    jtf_cal_resource_assign jtf_res
               WHERE   jtf_res.resource_id = l_jtf_res_id
               AND     jtf_res.resource_type_code = 'RS_EMPLOYEE'
               AND     jtf_res.primary_calendar_flag = 'Y'
               AND     jtf_res.calendar_id > 0
               AND     ( ( l_tc_start_date BETWEEN trunc(jtf_res.start_date_time) AND
                           nvl(trunc(jtf_res.end_date_time),l_tc_end_date))
               OR      ( l_tc_end_date   BETWEEN jtf_res.start_date_time AND
                           nvl(trunc(jtf_res.end_date_time),l_tc_end_date))
               OR      ( l_tc_start_date < jtf_res.start_date_time AND
                           l_tc_end_date > nvl(trunc(jtf_res.end_date_time),l_tc_end_date)) ) ;

BEGIN
  -- Calling resource API That will return the resource id
  PA_RESOURCE_UTILS.get_crm_res_id( p_project_player_id  => NULL,
                                    p_resource_id   => p_resource_id,
                                    x_jtf_resource_id => l_jtf_res_id,
                                    x_return_status => x_return_status,
                                    x_error_message_code  => x_msg_data );

  IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
      RAISE l_invalid_resource_id;
  END IF;

  PA_SCHEDULE_UTILS.log_message(1,'JTF Res ID: ' || l_jtf_res_id);
  PA_SCHEDULE_UTILS.log_message(1,'status ... '||x_return_status);

   -- 1965288: Work around for CRM bug (cannot create future dated resources).
   -- If the jtf_resource_id is null, then we need to use the default
   -- calendar instead of going to the jtf_cal_resource_assign table.

   -- Start 1965288 bugfix.
   if (l_jtf_res_id is null) then

      -- Get resource's organization on their
      -- min(resource_effective_start_date)
      select resource_organization_id
      into l_resource_organization_id
      from pa_resources_denorm
      where resource_effective_start_date =
        (select min(res1.resource_effective_start_date)
         from pa_resources_denorm res1
         where res1.resource_id = p_resource_id)
      and resource_id = p_resource_id;

      -- Get default calendar using organization id.
      pa_resource_utils.get_org_defaults(
           p_organization_id => l_resource_organization_id,
           x_default_ou => l_resource_ou_id,
           x_default_cal_id =>  l_calendar_id,
           x_return_status => x_return_status);

      if (l_calendar_id is null) then
         l_calendar_id := fnd_profile.value_specific('PA_PRM_DEFAULT_CALENDAR');
      end if;

      return l_calendar_id;

   -- End 1965288 bug fix.

   else
      -- Taking care if the passing start or end date is null if the dates are null take the value from table

      -- jmarques: 1786935: Modified cursor to include resource_type_code
      -- since resource_id is not unique. Also, added calendar_id > 0
      -- condition so that calendar_id, resource_id index would be used.

      IF (p_start_date IS NULL OR p_end_date IS NULL) THEN
          SELECT  MIN(start_date_time),MAX(NVL(end_date_time,TO_DATE('01/01/2050','MM/DD/YYYY')))
          INTO    l_temp_start_date,l_temp_end_date
          FROM    jtf_cal_resource_assign
          WHERE   jtf_cal_resource_assign.resource_id = l_jtf_res_id
          AND     jtf_cal_resource_assign.resource_type_code = 'RS_EMPLOYEE'
          AND     jtf_cal_resource_assign.calendar_id > 0
          AND     jtf_cal_resource_assign.primary_calendar_flag = 'Y';
      END IF;

      PA_SCHEDULE_UTILS.log_message(1,'Start date ... '||to_char(l_temp_start_date)||to_char(p_start_date));
      PA_SCHEDULE_UTILS.log_message(1,'end date  ... '||to_char(l_temp_end_date)||to_char(p_end_date));
      IF (p_start_date IS NULL ) THEN
          l_tc_start_date := l_temp_start_date;
      ELSE
          l_tc_start_date := p_start_date;
      END IF;

      IF (p_end_date IS NULL ) THEN
          l_tc_end_date := l_temp_end_date;
      ELSE
          l_tc_end_date := p_end_date;
      END IF;

      l_count := 0;
      FOR v_c1 IN C1 LOOP
        l_cal_id := v_c1.calendar_id;
        l_count := l_count + 1;
      END LOOP;

      IF l_count = 1 THEN
        return l_cal_id;
      ELSE
        return null;
      END IF;
   END IF;

END get_res_calendar;


-- Function             : Get_res_calendar_name
-- Purpose              : Returns the calendar_name for the
--                        calendar associated with this resource for the
--      		  given date.  Returns null
-- 		 	  if 0 or more than 1 calendar is specified for
--      		  the given dates.

FUNCTION get_res_calendar_name( p_resource_id IN NUMBER,
			        p_date IN DATE,
              p_person_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2
IS
  l_calendar_name VARCHAR2(50) := NULL;
  l_resource_id NUMBER := NULL;
BEGIN

  IF p_person_id IS NOT NULL THEN
     SELECT resource_id
     INTO l_resource_id
     FROM PA_RESOURCES_DENORM
     WHERE person_id = p_person_id
     AND rownum = 1;
  ELSE l_resource_id := p_resource_id;
  END IF;

  IF l_resource_id IS NULL THEN
    RETURN NULL;
  END IF;

  SELECT  jtf_cal.calendar_name
  INTO    l_calendar_name
  FROM    jtf_cal_resource_assign jtf_cal_res,
          jtf_calendars_vl jtf_cal,
          pa_resources res
  WHERE  res.resource_id = l_resource_id
         AND  jtf_cal_res.resource_id = res.jtf_resource_id
         AND  jtf_cal_res.resource_type_code = 'RS_EMPLOYEE'
         AND  jtf_cal_res.primary_calendar_flag = 'Y'
         AND  jtf_cal_res.calendar_id > 0
         AND  p_date BETWEEN jtf_cal_res.start_date_time
              AND nvl(jtf_cal_res.end_date_time, p_date+1)
         AND  jtf_cal_res.calendar_id = jtf_cal.calendar_id;

  return l_calendar_name;

  EXCEPTION
    WHEN  NO_DATA_FOUND THEN
      return l_calendar_name;
    WHEN OTHERS THEN
      return l_calendar_name;

END get_res_calendar_name;


-- Returns 'Y' if requirement/assignment is in the desired system
-- status for the entire duration of the requirement/assignment.
-- Otherwise returns 'N'.
-- p_assignment_id - assignment/requirement id
-- p_status_type - The value is either 'OPEN_ASGMT'
--   or 'STAFFED_ASGMT'.  Please see pa_project_statuses.status_type
--   for list of current values.
-- p_in_system_status_code - Desired system status code.

FUNCTION check_input_system_status
  (p_assignment_id IN pa_project_assignments.assignment_id%TYPE,
   p_status_type IN pa_project_statuses.status_type%TYPE,
   p_in_system_status_code IN pa_project_statuses.project_system_status_code%TYPE)
   return VARCHAR2 IS

   l_flag VARCHAR2(1) := 'Y';
   CURSOR l_sch_csr IS
      SELECT status_code
      FROM pa_schedules
      WHERE assignment_id = p_assignment_id;

BEGIN
   FOR l_sch_rec IN l_sch_csr LOOP
      l_flag := pa_assignment_utils.check_input_system_status(
                   p_status_code => l_sch_rec.status_code,
                   p_status_type => p_status_type,
                   p_in_system_status_code => p_in_system_status_code);
      IF l_flag = 'N' THEN
        RETURN l_flag;
      END IF;
   END LOOP;
   RETURN l_flag;
EXCEPTION
    WHEN OTHERS THEN
    RAISE;
END check_input_system_status;

-- Returns x_return_status = FND_API.G_RET_STS_SUCCESS if calendar(s)
-- assigned to p_resource_id or jtf_resource_id are valid.  By valid we mean:
-- * For all primary calendars assigned to the resource,
--   min(start_date_time) <= max(p_start_date,sysdate-avail duration) and
--   max(end_date_time) >= min(p_end_date, sysdate+avail duration).
--   Otherwise, adds error: PA_NO_ACTIVE_CALENDAR
-- * All active calendars must be contiguous.  If they overlap, then
--   adds error: PA_OVERLAPPING_CALENDARS. If there is a gap, then
--   adds error: PA_NO_ACTIVE_CALENDAR
-- * For all primary calendars assigned to the resource that overlap
--   p_start_date to p_end_date, call check_calendar(calendar_id)
--   passing in max(start_date_time,max(p_start_date,sysdate-avail duration))
--   and min(end_date_time,min(p_end_date,sysdate+avail duration)).
-- Otherwise x_return_status <> FND_API.G_RET_STS_SUCCESS.
PROCEDURE check_calendar(p_resource_id  IN NUMBER := null,
                         p_jtf_resource_id IN NUMBER := null,
                         p_start_date   IN DATE,
                         p_end_date     IN DATE,
                         x_return_status   OUT NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
                         x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                         x_msg_data        OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
  l_first_cal_flag VARCHAR2(1) := 'Y';
  l_msg_index_out NUMBER;
  l_avail_duration NUMBER := FND_NUMBER.CANONICAL_TO_NUMBER(FND_PROFILE.VALUE('PA_AVAILABILITY_DURATION'));
  l_start_date DATE;
  l_end_date DATE;
  l_cal_start_date DATE;
  l_cal_end_date DATE;
  l_prev_cal_start_date DATE;
  l_prev_cal_end_date DATE;
  l_error_start_date DATE;
  l_error_end_date DATE;
  l_check_cal_start_date DATE;
  l_check_cal_end_date DATE;
  l_no_active_calendar EXCEPTION;
  l_duplicate_calendars EXCEPTION;
  l_invalid_param EXCEPTION;
  l_error_message VARCHAR2(200);
  --Bug: 4537865
  l_new_msg_data  VARCHAR2(2000);
  --Bug: 4537865

  -- The select statement takes care of two cases (passing in
  -- p_jtf_resource_id and passing in p_resource_id)
  CURSOR C_CAL IS
     SELECT calendar_id, start_date_time, end_date_time
     FROM (
        SELECT jtf_res.calendar_id calendar_id,
               NVL(jtf_res.start_date_time, l_start_date) start_date_time,
               NVL(jtf_res.end_date_time, l_end_date) end_date_time
        FROM jtf_cal_resource_assign jtf_res, pa_resources pa_res
        WHERE pa_res.resource_id = p_resource_id
        and jtf_res.resource_id = pa_res.jtf_resource_id
        and jtf_res.resource_type_code = 'RS_EMPLOYEE'
        and jtf_res.calendar_id > -1
        and jtf_res.primary_calendar_flag = 'Y'
        and NVL(jtf_res.start_date_time,l_start_date) <= l_end_date
        and NVL(jtf_res.end_date_time,l_end_date) >= l_start_date
        and p_resource_id is not null
        UNION ALL
        SELECT jtf_res.calendar_id calendar_id,
               NVL(jtf_res.start_date_time, l_start_date) start_date_time,
               NVL(jtf_res.end_date_time, l_end_date) end_date_time
        FROM jtf_cal_resource_assign jtf_res
        WHERE jtf_res.resource_id = p_jtf_resource_id
        and jtf_res.resource_type_code = 'RS_EMPLOYEE'
        and jtf_res.calendar_id > -1
        and jtf_res.primary_calendar_flag = 'Y'
        and NVL(jtf_res.start_date_time,l_start_date) <= l_end_date
        and NVL(jtf_res.end_date_time,l_end_date) >= l_start_date
        and p_jtf_resource_id is not null)
     order by start_date_time;

  rec_cal c_cal%ROWTYPE;
BEGIN
  log_message(1,'Entering check_calendar for resource');
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if (p_resource_id is not null and p_jtf_resource_id is not null) then
     l_error_message := 'p_resource_id and p_jtf_resource_id cannot both be not null.';
     raise l_invalid_param;
  end if;

  if (p_resource_id is null and p_jtf_resource_id is null) then
     l_error_message := 'p_resource_id and p_jtf_resource_id cannot both be null.';
     raise l_invalid_param;
  end if;

  l_start_date := ADD_MONTHS(sysdate,-(l_avail_duration*12));
  if (p_start_date > l_start_date) then
     l_start_date := p_start_date;
  end if;
  log_message(1,'l_start_date: ' || l_start_date);

  l_end_date := ADD_MONTHS(sysdate,(l_avail_duration*12));
  if (l_end_date > p_end_date) then
     l_end_date := p_end_date;
  end if;
  log_message(1,'l_end_date: ' || l_end_date);

  -- Bug 2202654: No need to check calendar if l_start_date or l_end_date is outside
  -- the window.
  if (l_start_date > ADD_MONTHS(sysdate,(l_avail_duration*12))
     OR l_end_date < ADD_MONTHS(sysdate,-(l_avail_duration*12))) then
    RETURN;
  end if;

  log_message(1,'Entering calendar loop');
  FOR rec_cal in c_cal LOOP
     if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
        l_cal_start_date := trunc(rec_cal.start_date_time);
        l_cal_end_date := trunc(rec_cal.end_date_time);
        log_message(1,'l_cal_start_date: ' || l_cal_start_date);
        log_message(1,'l_cal_end_date: ' || l_cal_end_date);

        if (l_first_cal_flag = 'Y' and l_cal_start_date > l_start_date) then
           l_error_start_date := l_start_date;
           l_error_end_date := l_cal_start_date-1;
           raise l_no_active_calendar;

        elsif (l_first_cal_flag = 'N' and
               l_cal_start_date > l_prev_cal_end_date+1) then
           l_error_start_date := l_prev_cal_end_date+1;
           l_error_end_date := l_cal_start_date-1;
           raise l_no_active_calendar;

        elsif (l_first_cal_flag = 'N' and
               l_cal_start_date < l_prev_cal_end_date+1) then
           l_error_start_date := l_cal_start_date;
           if (l_prev_cal_start_date > l_cal_start_date) then
              l_error_start_date := l_prev_cal_start_date;
           end if;
           l_error_end_date := l_prev_cal_end_date;
           raise l_duplicate_calendars;
        end if;

        l_first_cal_flag := 'N';
        l_prev_cal_start_date := l_cal_start_date;
        l_prev_cal_end_date := l_cal_end_date;

        l_check_cal_start_date := l_cal_start_date;
        if (l_cal_start_date < l_start_date) then
           l_check_cal_start_date := l_start_date;
        end if;
        log_message(1,'l_check_cal_start_date: ' || l_check_cal_start_date);

        l_check_cal_end_date := l_cal_end_date;
        if (l_cal_end_date > l_end_date) then
           l_check_cal_end_date := l_end_date;
        end if;
        log_message(1,'l_check_cal_end_date: ' || l_check_cal_end_date);

        check_calendar(
                    p_calendar_id => rec_cal.calendar_id,
                    p_start_date => l_check_cal_start_date,
                    p_end_date => l_check_cal_end_date,
                    x_return_status => x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data);
     END IF;
  END LOOP;
  log_message(1,'Done calendar loop');

  if (l_first_cal_flag = 'Y') then
     l_error_start_date := l_start_date;
     l_error_end_date := l_end_date;
		 raise l_no_active_calendar;
  -- Bug 2202654: Added trunc() before doing date comparison.
  elsif (trunc(l_end_date) > trunc(l_prev_cal_end_date)) then
    l_error_start_date := l_prev_cal_end_date + 1;
    l_error_end_date := l_end_date;
    raise l_no_active_calendar;
  end if;

  log_message(1,'Leaving check_calendar for resource');
EXCEPTION
   WHEN l_invalid_param THEN
     PA_SCHEDULE_UTILS.log_message(1,'ERROR in check_calendar: '|| l_error_message);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count := 1;
     x_msg_data  := substr(l_error_message,1,240);
     FND_MSG_PUB.add_exc_msg( p_pkg_name => 'PA_SCHEDULE_UTILS',
       p_procedure_name   => 'check_calendar');
       If x_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
            (p_encoded        => FND_API.G_TRUE,
             p_msg_index      => 1,
             p_msg_count      => x_msg_count,
             p_msg_data       => x_msg_data,
           --p_data           => x_msg_data,		* Bug: 4537865
	     p_data	      => l_new_msg_data,	--Bug: 4537865
             p_msg_index_out  => l_msg_index_out );

       --Bug: 4537865
       x_msg_data := l_new_msg_data;
       --Bug: 4537865
       End If;
       RAISE;
   WHEN l_no_active_calendar THEN
     PA_SCHEDULE_UTILS.log_message(1,'ERROR: l_no_active_calendar');
     PA_UTILS.add_message('PA','PA_NO_ACTIVE_CALENDAR',
          'START_DATE', l_error_start_date,
          'END_DATE', l_error_end_date);
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_data := 'PA_NO_ACTIVE_CALENDAR';
     x_msg_count := FND_MSG_PUB.Count_Msg;
     If x_msg_count = 1 THEN
        pa_interface_utils_pub.get_messages
          (p_encoded        => FND_API.G_TRUE,
           p_msg_index      => 1,
           p_msg_count      => x_msg_count,
           p_msg_data       => x_msg_data,
         --p_data           => x_msg_data,		* bug: 4537865
           p_data	    => l_new_msg_data,		--bug: 4537865
           p_msg_index_out  => l_msg_index_out );
	--Bug: 4537865
	x_msg_data := l_new_msg_data;
	--Bug: 4537865
     End If;
   WHEN l_duplicate_calendars THEN
     PA_SCHEDULE_UTILS.log_message(1,'ERROR: l_duplicate_calendars');
     PA_UTILS.add_message('PA','PA_DUPLICATE_CALENDARS',
          'START_DATE', l_error_start_date,
          'END_DATE', l_error_end_date);
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_data := 'PA_DUPLICATE_CALENDARS';
     x_msg_count := FND_MSG_PUB.Count_Msg;
     If x_msg_count = 1 THEN
        pa_interface_utils_pub.get_messages
          (p_encoded        => FND_API.G_TRUE,
           p_msg_index      => 1,
           p_msg_count      => x_msg_count,
           p_msg_data       => x_msg_data,
         --p_data           => x_msg_data,		* bug: 4537865
	   p_data	    => l_new_msg_data,		--bug: 4537865
           p_msg_index_out  => l_msg_index_out );
	--bug: 4537865
	x_msg_data := l_new_msg_data;
	--bug: 4537865
     End If;
   WHEN OTHERS THEN
     PA_SCHEDULE_UTILS.log_message(1,'ERROR in check_calendar: '||sqlerrm);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count := 1;
     x_msg_data  := substr(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg( p_pkg_name => 'PA_SCHEDULE_UTILS',
       p_procedure_name   => 'check_calendar');
       If x_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
            (p_encoded        => FND_API.G_TRUE,
             p_msg_index      => 1,
             p_msg_count      => x_msg_count,
             p_msg_data       => x_msg_data,
           --p_data           => x_msg_data,		* bug: 4537865
	     p_data	      => l_new_msg_data,	--bug: 4537865
             p_msg_index_out  => l_msg_index_out );
	--bug: 4537865
	x_msg_data := l_new_msg_data;
	--bug: 4537865
       End If;
       RAISE;
END check_calendar;

-- Returns x_return_status = FND_API.G_RET_STS_SUCCESS if p_calendar_id
-- is valid between p_start_date and p_end_date.  By valid we mean:
-- * A schedule record exists for the calendar.
--   Otherwise, adds error: PA_MISSING_CALENDAR_SCHEDULES
-- * The calendar start date is <= p_start_date.
--   Otherwise, adds error: PA_CALENDAR_NOT_ACTIVE
-- * The calendar end date is >= p_end_date.
--   Otherwise, adds error: PA_CALENDAR_NOT_ACTIVE
-- * The calendar has at least 1 non-zero shift.
--   Otherwise, adds error: PA_CAL_MISSING_VALID_SHIFT
-- Otherwise x_return_status <> FND_API.G_RET_STS_SUCCESS.
PROCEDURE check_calendar(p_calendar_id IN NUMBER,
                         p_start_date  IN DATE,
                         p_end_date    IN DATE,
                         x_return_status   OUT NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
                         x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                         x_msg_data        OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
   l_sch_exists_flag VARCHAR2(1) := 'N';
   l_msg_index_out NUMBER;

   -- These vars are for fetching from cursor.
   l_min_start_date DATE;
   l_max_end_date DATE;
   l_max_total_hours NUMBER;

   l_missing_calendar_schedules EXCEPTION;
   l_calendar_not_active EXCEPTION;
   l_cal_missing_valid_shift EXCEPTION;

   l_error_start_date DATE;
   l_error_end_date DATE;
   --bug: 4537865
   l_new_msg_data	VARCHAR2(2000);
   --bug: 4537865

   CURSOR C_SCH IS
     select trunc(min(start_date)) min_start_date,
            trunc(max(end_date)) max_end_date,
            max(monday_hours) + max(tuesday_hours) + max(wednesday_hours) +
            max(thursday_hours) + max(friday_hours) + max(saturday_hours) +
            max(sunday_hours) max_total_hours
     from pa_schedules
     where schedule_type_code = 'CALENDAR'
     and calendar_id = p_calendar_id;

BEGIN
  log_message(1,'Entering check_calendar for calendar');
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  open c_sch;
  fetch c_sch
    into l_min_start_date, l_max_end_date, l_max_total_hours;
  if c_sch%NOTFOUND then
    close c_sch;
    raise l_missing_calendar_schedules;
  end if;
  close c_sch;

  if (l_min_start_date is null) then
    raise l_missing_calendar_schedules;
  end if;

  log_message(1,'l_min_start_date: ' || l_min_start_date);
  log_message(1,'l_max_end_date: ' || l_max_end_date);
  log_message(1,'l_max_total_hours: ' || l_max_total_hours);

  if (l_min_start_date > p_start_date) then
     l_error_start_date := p_start_date;
     l_error_end_date := l_min_start_date - 1;
     raise l_calendar_not_active;
  end if;

  if (l_max_end_date < p_end_date) then
     l_error_start_date := l_max_end_date + 1;
     l_error_end_date := p_end_date;
     raise l_calendar_not_active;
  end if;

  if (l_max_total_hours = 0) then
     raise l_cal_missing_valid_shift;
  end if;

  log_message(1,'Leaving check_calendar for calendar');
EXCEPTION
   WHEN l_missing_calendar_schedules THEN
     PA_SCHEDULE_UTILS.log_message(1,'ERROR: l_missing_calendar_schedules');
     PA_UTILS.add_message('PA','PA_MISSING_CALENDAR_SCHEDULES');
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_data := 'PA_MISSING_CALENDAR_SCHEDULES';
     x_msg_count := FND_MSG_PUB.Count_Msg;
     If x_msg_count = 1 THEN
        pa_interface_utils_pub.get_messages
          (p_encoded        => FND_API.G_TRUE,
           p_msg_index      => 1,
           p_msg_count      => x_msg_count,
           p_msg_data       => x_msg_data,
         --p_data           => x_msg_data,		* Bug: 4537865
	   p_data	    => l_new_msg_data,		--Bug: 4537865
           p_msg_index_out  => l_msg_index_out );
	--bug: 4537865
	x_msg_data := l_new_msg_data;
	--bug: 4537865
     End If;
   WHEN l_calendar_not_active THEN
     PA_SCHEDULE_UTILS.log_message(1,'ERROR: l_calendar_not_active');
     PA_UTILS.add_message('PA','PA_CALENDAR_NOT_ACTIVE',
          'START_DATE', l_error_start_date,
          'END_DATE', l_error_end_date);
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_data := 'PA_CALENDAR_NOT_ACTIVE';
     x_msg_count := FND_MSG_PUB.Count_Msg;
     If x_msg_count = 1 THEN
        pa_interface_utils_pub.get_messages
          (p_encoded        => FND_API.G_TRUE,
           p_msg_index      => 1,
           p_msg_count      => x_msg_count,
           p_msg_data       => x_msg_data,
         --p_data           => x_msg_data,		* Bug: 4537865
	   p_data	    => l_new_msg_data,		--Bug: 4537865
           p_msg_index_out  => l_msg_index_out );
	--Bug: 4537865
	x_msg_data := l_new_msg_data;
	--Bug: 4537865
     End If;
   WHEN l_cal_missing_valid_shift THEN
     PA_SCHEDULE_UTILS.log_message(1,'ERROR: l_cal_missing_valid_shift');
     PA_UTILS.add_message('PA','PA_CAL_MISSING_VALID_SHIFT');
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_data := 'PA_CAL_MISSING_VALID_SHIFT';
     x_msg_count := FND_MSG_PUB.Count_Msg;
     If x_msg_count = 1 THEN
        pa_interface_utils_pub.get_messages
          (p_encoded        => FND_API.G_TRUE,
           p_msg_index      => 1,
           p_msg_count      => x_msg_count,
           p_msg_data       => x_msg_data,
         --p_data           => x_msg_data,		* Bug: 4537865
	   p_data	    => l_new_msg_data,		--Bug: 4537865
           p_msg_index_out  => l_msg_index_out );
	--Bug: 4537865
	x_msg_data := l_new_msg_data;
	--Bug: 4537865
     End If;
   WHEN OTHERS THEN
     PA_SCHEDULE_UTILS.log_message(1,'ERROR in check_calendar: '||sqlerrm);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count := 1;
     x_msg_data  := substr(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg( p_pkg_name => 'PA_SCHEDULE_UTILS',
       p_procedure_name   => 'check_calendar');
       If x_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
            (p_encoded        => FND_API.G_TRUE,
             p_msg_index      => 1,
             p_msg_count      => x_msg_count,
             p_msg_data       => x_msg_data,
           --p_data           => x_msg_data,		* Bug: 4537865
	     p_data	      => l_new_msg_data,	--Bug: 4537865
             p_msg_index_out  => l_msg_index_out );
	--Bug: 4537865
	x_msg_data := l_new_msg_data;
	--Bug: 4537865
       End If;
       RAISE;
END check_calendar;

-- If p_calendar_type = 'RESOURCE', then checks calendars assigned
-- to p_resource_id between p_start_date and p_end_date.
-- Otherwise, checks p_calendar_id between p_start_date and p_end_date.
-- See other check_calendar procedures for more details.
PROCEDURE check_calendar(p_calendar_type IN VARCHAR2,
                         p_calendar_id   IN NUMBER := null,
                         p_resource_id   IN NUMBER := null,
                         p_start_date    IN DATE,
                         p_end_date    IN DATE,
                         x_return_status   OUT NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
                         x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                         x_msg_data        OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
  l_invalid_param EXCEPTION;
  l_error_message VARCHAR2(200);
  l_msg_index_out NUMBER;
  --Bug: 4537865
  l_new_msg_data  VARCHAR2(2000);
  --Bug: 4537865

BEGIN
  log_message(1,'Entering check_calendar main');
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if (p_calendar_type = 'RESOURCE') then
     if (p_resource_id is null) then
        l_error_message := 'p_resource_id cannot be null if p_calendar_type = RESOURCE.';
        raise l_invalid_param;
     end if;

     check_calendar(p_resource_id => p_resource_id,
                    p_start_date => p_start_date,
                    p_end_date => p_end_date,
                    x_return_status => x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data);

  else
     if (p_calendar_id is null) then
        l_error_message := 'p_calendar_id cannot be null if p_calendar_type <> RESOURCE.';
        raise l_invalid_param;
     end if;

     if (p_start_date is null) then
        l_error_message := 'p_start_date cannot be null if p_calendar_type <> RESOURCE.';
        raise l_invalid_param;
     end if;

     if (p_end_date is null) then
        l_error_message := 'p_end_date cannot be null if p_calendar_type <> RESOURCE.';
        raise l_invalid_param;
     end if;

     check_calendar(p_calendar_id => p_calendar_id,
                    p_start_date => p_start_date,
                    p_end_date => p_end_date,
                    x_return_status => x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data);
  end if;
  log_message(1,'Leaving check_calendar main');
EXCEPTION
   WHEN l_invalid_param THEN
     PA_SCHEDULE_UTILS.log_message(1,'ERROR in check_calendar: '|| l_error_message);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count := 1;
     x_msg_data  := substr(l_error_message,1,240);
     FND_MSG_PUB.add_exc_msg( p_pkg_name => 'PA_SCHEDULE_UTILS',
       p_procedure_name   => 'check_calendar');
       If x_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
            (p_encoded        => FND_API.G_TRUE,
             p_msg_index      => 1,
             p_msg_count      => x_msg_count,
             p_msg_data       => x_msg_data,
           --p_data           => x_msg_data,		* Bug: 4537865
	     p_data	      => l_new_msg_data,	--Bug: 4537865
             p_msg_index_out  => l_msg_index_out );
	--Bug: 4537865
	x_msg_data := l_new_msg_data;
	--Bug: 4537865
       End If;
       RAISE;
   WHEN OTHERS THEN
     PA_SCHEDULE_UTILS.log_message(1,'ERROR in check_calendar: '||sqlerrm);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count := 1;
     x_msg_data  := substr(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg( p_pkg_name => 'PA_SCHEDULE_UTILS',
       p_procedure_name   => 'check_calendar');
       If x_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
            (p_encoded        => FND_API.G_TRUE,
             p_msg_index      => 1,
             p_msg_count      => x_msg_count,
             p_msg_data       => x_msg_data,
           --p_data           => x_msg_data,		Bug: 4537865
	     p_data	      => l_new_msg_data,	--Bug: 4537865
             p_msg_index_out  => l_msg_index_out );
	--Bug: 4537865
	x_msg_data := l_new_msg_data;
	--Bug: 4537865
       End If;
       RAISE;

END check_calendar;


END PA_SCHEDULE_UTILS;

/
