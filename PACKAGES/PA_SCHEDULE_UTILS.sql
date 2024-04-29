--------------------------------------------------------
--  DDL for Package PA_SCHEDULE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_SCHEDULE_UTILS" AUTHID CURRENT_USER as
/* $Header: PARGUTLS.pls 120.1 2005/08/19 16:53:47 mwasowic noship $ */

PROCEDURE copy_schedule_rec_tab ( p_sch_record_tab         IN   PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                  p_start_id               IN   NUMBER,
                                  p_end_id                 IN   NUMBER,
                                  x_sch_record_tab         IN OUT NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                  x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data               OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure            : Copy_schedule_rec_tab
-- Purpose              : Copying Rows from one table to another in
--                        array processing.
-- Parameters           :
--                        p_sch_record_tab - Table of schedule details Records

PROCEDURE add_schedule_rec_tab  ( p_sch_record_tab         IN      PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                  p_start_id               IN      NUMBER,
                                  p_end_id                 IN      NUMBER,
                                  px_sch_record_tab        IN OUT NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                  x_return_status          OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count              OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data               OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure            : Add_schedule_rec_tab
-- Purpose              : Adding Rows from one table to another in
--                        array processing.
-- Parameters           :
--                        p_sch_record_tab - Table of schedule details Records

PROCEDURE mark_del_sch_rec_tab (  p_start_id               IN      NUMBER,
                                  p_end_id                 IN      NUMBER,
                                  px_sch_record_tab        IN OUT NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                  x_return_status          OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count              OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data               OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure            : Mark_del_sch_rec_tab
-- Purpose              : Marking Rows for deletion in
--                        array processing.
-- Parameters           :
--                        px_sch_record_tab - Table of schedule details Records

PROCEDURE sep_del_sch_rec_tab   ( p_sch_record_tab         IN   PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                  x_del_sch_rec_tab        IN OUT  NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                  x_sch_record_tab         OUT  NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                  x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data               OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure            : Sep_del_sch_rec_tab
-- Purpose              : Seprating Rows from deleted one to non deleted one in
--                        array processing.
-- Parameters           :
--                        p_sch_record_tab - Table of schedule details Records

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
                                x_msg_data                  OUT      NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure            : Update_sch_rec_tab
-- Purpose              : Updating Rows with the given date in
--                        array processing.
-- Parameters           :
--                        px_sch_record_tab - Table of schedule details Records

PROCEDURE apply_percentage    ( px_sch_record_tab           IN  OUT NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                p_percentage                IN       NUMBER   ,
                                x_return_status             OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count                 OUT      NOCOPY NUMBER , --File.Sql.39 bug 4440895
                                x_msg_data                  OUT      NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure            : Apply_percentage
-- Purpose              : Applying the percentage availabilty factor on the resource schedule. But can be used to
--                        apply percentage of availablity on the work pattern of the schedul in
--                        array processing.
-- Parameters           :
--                        px_sch_record_tab - Table of schedule details Records

PROCEDURE copy_except_record (   p_except_record           IN   PA_SCHEDULE_GLOB.SchExceptRecord,
                                  x_except_record          OUT NOCOPY PA_SCHEDULE_GLOB.SchExceptRecord,
                                  x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data               OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure            : Copy_Except_Record
-- Purpose              :It copy the record in array processing.
-- Parameters           :

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
                                x_msg_data                  OUT      NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895
--
-- Procedure            :Update_Except_Record
-- Purpose              : This procedure will update the record in array processing.
-- Parameters           :

PROCEDURE log_message( level1          IN NUMBER,
                       msg1            IN   VARCHAR2);
--
-- Procedure            : Log_Message
-- Purpose              : This procedure will print message with the given lavel It is oveloaded procedure.
--
--                       .
-- Parameters           :

PROCEDURE debug(p_module IN VARCHAR2,
                p_msg IN VARCHAR2,
                p_log_level IN NUMBER DEFAULT 6);


PROCEDURE debug(p_msg IN VARCHAR2);

PROCEDURE log_message( level1          IN NUMBER,
                       msg1            IN   VARCHAR2,
                       wr_tab         IN PA_SCHEDULE_GLOB.ScheduleTabTyp);
--
-- Procedure            : Log_message
-- Purpose              : This procedure will print value of structure of passing array  with the given lavel
--                        it is oveloaded procedure
--
-- Parameters           :


PROCEDURE validate_date_range( p_from_date          IN    DATE,
                               p_to_date            IN    DATE,
                               x_return_status      OUT   NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
                               x_error_message_code OUT   NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
--
-- Procedure            : Validate_date_range
-- Purpose              : This procedure will validate the passing date
--
-- Parameters           :

FUNCTION get_num_hours( p_project_id          IN    NUMBER,
                        p_assignment_id       IN    NUMBER) RETURN NUMBER;
--
-- Function             : Get_num_hours
-- Purpose              : This function returns the number of hours scheduled
--                        for this assignment.  We are also requiring
--                        project_id for performance.


FUNCTION get_res_calendar( p_resource_id IN NUMBER,
			   p_start_date IN DATE,
			   p_end_date IN DATE) RETURN NUMBER;

-- Function             : Get_res_calendar
-- Purpose              : Returns the calendar_id for the
--                        calendar associated with this resource for the
--      		  start and end date specified.  Returns null
-- 		 	  if 0 or more than 1 calendar is specified for
--      		  the given dates.


-- Function             : get_res_calendar_name
-- Purpose              : Returns the calendar_name for the
--                        calendar associated with this resource for the
--      		  given date.  Returns null
-- 		 	  if 0 or more than 1 calendar is specified for
--      		  the given dates.
FUNCTION get_res_calendar_name( p_resource_id IN NUMBER,
			        p_date        IN DATE,
              p_person_id IN NUMBER DEFAULT NULL)  RETURN VARCHAR2;


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
   p_in_system_status_code IN pa_project_statuses.project_system_status_code%TYPE) return VARCHAR2;

PROCEDURE check_calendar(p_resource_id  IN NUMBER := null,
                         p_jtf_resource_id IN NUMBER := null,
                         p_start_date   IN DATE,
                         p_end_date     IN DATE,
                         x_return_status   OUT NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
                         x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                         x_msg_data        OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE check_calendar(p_calendar_id IN NUMBER,
                         p_start_date  IN DATE,
                         p_end_date    IN DATE,
                         x_return_status   OUT NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
                         x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                         x_msg_data        OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


PROCEDURE check_calendar(p_calendar_type IN VARCHAR2,
                         p_calendar_id   IN NUMBER := null,
                         p_resource_id   IN NUMBER := null,
                         p_start_date    IN DATE,
                         p_end_date    IN DATE,
                         x_return_status   OUT NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
                         x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                         x_msg_data        OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

END PA_SCHEDULE_UTILS;
 

/
