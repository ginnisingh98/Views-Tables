--------------------------------------------------------
--  DDL for Package PA_SCHEDULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_SCHEDULE_PVT" AUTHID CURRENT_USER as
/* $Header: PARGPVTS.pls 120.7.12010000.3 2009/08/23 19:55:51 vbkumar ship $ */
TempIDTab    SYSTEM.PA_NUM_TBL_TYPE;

TYPE WorkPatternRecord IS RECORD (
  assignment_id        NUMBER,
  start_date           DATE,
  end_date             DATE,
  monday_hours         NUMBER,
  tuesday_hours        NUMBER,
  wednesday_hours      NUMBER,
  thursday_hours       NUMBER,
  friday_hours         NUMBER,
  saturday_hours       NUMBER,
  sunday_hours         NUMBER);

TYPE WorkPatternTabTyp IS TABLE OF WorkPatternRecord INDEX BY BINARY_INTEGER;

--SUBTYPE DayOfWeekType IS VARCHAR2(3); bug 5926172
SUBTYPE DayOfWeekType IS VARCHAR2(15);

-- Procedure            : merge_work_pattern
-- Purpose              : Merges same work pattern
-- Parameters           :
--
PROCEDURE merge_work_pattern(
				 p_project_id     IN NUMBER,
				 p_assignment_id IN NUMBER,
				 x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
				 x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
				 x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				);
/* Added below for 7663765 */
PROCEDURE get_existing_schedule ( p_calendar_id            IN   NUMBER,
                                  p_assignment_id	   IN NUMBER,
                                  p_start_date             IN   DATE,
                                  p_end_date               IN   DATE,
                                  x_sch_record_tab         OUT  NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
				  x_difference_days        IN NUMBER,
                                  x_shift_unit_code        IN VARCHAR2,
                                  x_return_status          OUT  NOCOPY VARCHAR2,
                                  x_msg_count              OUT  NOCOPY NUMBER,
                                  x_msg_data               OUT  NOCOPY VARCHAR2 );

PROCEDURE get_calendar_schedule ( p_calendar_id            IN   NUMBER,
                                  p_start_date             IN   DATE,
                                  p_end_date               IN   DATE,
                                  x_sch_record_tab         OUT  NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                  x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data               OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure            : get_calendar_schedule
-- Purpose              : Gets schedule details for Calendar.
-- Parameters           :
--


PROCEDURE get_assignment_schedule ( p_assignment_id            IN   NUMBER,
                                  p_start_date             IN   DATE,
                                  p_end_date               IN   DATE,
                                  x_sch_record_tab         OUT  NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                  x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data               OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure            : get_assignment_schedule
-- Purpose              : Gets schedule details for project assignment.
-- Parameters           :
--


PROCEDURE get_assignment_schedule ( p_assignment_id            IN   NUMBER,
                                  x_sch_record_tab         OUT  NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                  x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data               OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure            : get_assignment_schedule
-- Purpose              : Gets schedule details for project assignment.
-- Parameters           :
--

PROCEDURE get_resource_schedule ( p_source_id              IN   NUMBER,
                                  p_source_type            IN   VARCHAR2,
                                  p_start_date             IN   DATE,
                                  p_end_date               IN   DATE,
                                  x_sch_record_tab         IN OUT  NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                  x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data               OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895
--
-- Procedure            : get_resource_schedule
-- Purpose              : Gets schedule details for project resource.
-- Parameters           :
--

PROCEDURE apply_schedule_change( p_chg_sch_record_tab    IN  PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                 p_del_sch_record_tab    IN  PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                 x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 x_msg_data               OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure            : apply_schedule_change
-- Purpose              : Applys the resultant schedule details after applying exceptions on
--                        the schedule related tables.
-- Parameters           :
--

PROCEDURE create_new_schedule(
                     p_sch_except_record  IN     pa_schedule_glob.SchExceptRecord,
                     p_sch_record         IN     pa_schedule_glob.ScheduleRecord,
                     x_sch_record_tab     IN OUT NOCOPY pa_schedule_glob.ScheduleTabTyp,
		     x_difference_days    IN NUMBER,  /* Added for 7663765 */
		     x_shift_unit_code   IN VARCHAR2,  /* Added for 7663765 */
                     x_return_status      OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                     x_msg_count          OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
                     x_msg_data           OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                     );
--
-- Procedure            : create_new_schedule
-- Purpose              :
-- Parameters           :
--

PROCEDURE create_new_calendar(
                            p_sch_except_record  IN     pa_schedule_glob.SchExceptRecord,
                            p_sch_record         IN     pa_schedule_glob.ScheduleRecord,
                            x_sch_record_tab     IN OUT NOCOPY pa_schedule_glob.ScheduleTabTyp,
                            x_return_status      OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_msg_count          OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            x_msg_data           OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                            );

--
-- Procedure            : create_new_calendar
-- Purpose              :
-- Parameters           :
--


PROCEDURE create_new_hours(
                     p_sch_except_record  IN     pa_schedule_glob.SchExceptRecord,
                     p_sch_record         IN     pa_schedule_glob.ScheduleRecord,
                     x_sch_record_tab     IN OUT NOCOPY pa_schedule_glob.ScheduleTabTyp,
                     x_return_status      OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                     x_msg_count          OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
                     x_msg_data           OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                     );

--
-- Procedure            : create_new_hours
-- Purpose              :
-- Parameters           :
--


PROCEDURE create_new_duration(
                     p_sch_except_record  IN     pa_schedule_glob.SchExceptRecord,
                     p_sch_record         IN     pa_schedule_glob.ScheduleRecord,
                     x_sch_record_tab     IN OUT NOCOPY pa_schedule_glob.ScheduleTabTyp,
		     x_difference_days     IN NUMBER, /* Added for 7663765 */
		     x_shift_unit_code     IN VARCHAR2, /* Added for 7663765 */
                     x_return_status      OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                     x_msg_count          OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
                     x_msg_data           OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                     );

--
-- Procedure            : create_new_hours
-- Purpose              :
-- Parameters           :
--

PROCEDURE create_new_pattern(
                     p_sch_except_record  IN     pa_schedule_glob.SchExceptRecord,
                     p_sch_record         IN     pa_schedule_glob.ScheduleRecord,
                     x_sch_record_tab     IN OUT NOCOPY pa_schedule_glob.ScheduleTabTyp,
                     x_return_status      OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                     x_msg_count          OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
                     x_msg_data           OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                     );

--
-- Procedure            : create_new_hours
-- Purpose              :
-- Parameters           :
--

PROCEDURE create_new_status(
                   p_sch_except_record  IN     pa_schedule_glob.SchExceptRecord,
                   p_sch_record         IN     pa_schedule_glob.ScheduleRecord,
                   x_sch_record_tab     IN OUT NOCOPY pa_schedule_glob.ScheduleTabTyp,
                   x_return_status      OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                   x_msg_count          OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
                   x_msg_data           OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                   );

--
-- Procedure            : create_new_hours
-- Purpose              :
-- Parameters           :
--

PROCEDURE apply_change_duration (
                 p_sch_record_tab    IN     pa_schedule_glob.ScheduleTabTyp,
                 p_sch_except_record IN     pa_schedule_glob.SchExceptRecord,
                 x_sch_record_tab    IN OUT NOCOPY pa_schedule_glob.ScheduleTabTyp,
                 x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                 x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                 x_msg_data          OUT  NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895
--
-- Procedure            : apply_change_duration
-- Purpose              :
-- Parameters           :
--

PROCEDURE apply_other_changes (
                 p_sch_record_tab    IN     pa_schedule_glob.ScheduleTabTyp,
                 p_sch_except_record IN     pa_schedule_glob.SchExceptRecord,
                 x_sch_record_tab    IN OUT NOCOPY pa_schedule_glob.ScheduleTabTyp,
                 x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                 x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                 x_msg_data          OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895
--
-- Procedure            : apply_other_changes
-- Purpose              :
-- Parameters           :
--

PROCEDURE apply_assignment_change (
                 p_record_version_number  IN  NUMBER,
                 chg_tr_sch_rec_tab    IN     PA_SCHEDULE_GLOB.ScheduleTabTyp,
                 sch_except_record_tab IN     PA_SCHEDULE_GLOB.SchExceptTabTyp,
                 p_called_by_proj_party          IN  VARCHAR2         := 'N', -- Added for Bug 6631033
                 x_return_status       OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                 x_msg_count           OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
                 x_msg_data            OUT    NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895
--
-- Procedure            : apply_assignment_change
-- Purpose              : Update the column for multiple flag in PA_PROJECT_ASSIGNMENTS table if the assignment
--                        has more than one status but it will keep only one status
-- Parameters           :
--

PROCEDURE get_periodic_start_end(
				        p_start_date                 IN  DATE,
					    p_end_date                   IN  DATE,
						p_project_assignment_id      IN NUMBER,
				        p_task_assignment_id_tbl     IN  SYSTEM.PA_NUM_TBL_TYPE,
					    x_min_start_date             OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                        x_max_end_date               OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                                            p_project_id             IN NUMBER,
                                            p_budget_version_id      IN NUMBER,
					    x_return_status              OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
					    x_msg_count                  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
					    x_msg_data                   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
					     );
-- Procedure            : get_periodic_start_end
-- Purpose              : Get Periodic Start/End Dates for Task Assignments.

PROCEDURE create_opn_asg_schedule(p_project_id   IN  NUMBER,
					    p_calendar_id            IN  NUMBER,
					    p_assignment_id          IN  NUMBER,
					    p_start_date             IN  DATE,
					    p_end_date               IN  DATE,
					    p_assignment_status_code IN  VARCHAR2,
					    p_work_type_id           IN  NUMBER:=NULL,
					    p_task_id                IN  NUMBER:=NULL,
					    p_task_percentage        IN  NUMBER:=NULL,
					    p_sum_tasks_flag         IN  VARCHAR2,
					    p_task_assignment_id_tbl IN  SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
                                            p_budget_version_id      IN NUMBER:=NULL,
					    x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
					    x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
					    x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
					    );

-- Procedure            : create_opn_asg_schedule
-- Purpose              : Create schedule for open assignments
PROCEDURE create_opn_asg_schedule(
                        p_project_id             IN  NUMBER :=NULL,
                        p_asgn_creation_mode          IN     VARCHAR2 := NULL, /* Added for Bug 6145532 */
					    p_calendar_id            IN  NUMBER :=NULL,
					    p_assignment_id_tbl      IN  PA_ASSIGNMENTS_PUB.assignment_id_tbl_type,
                        p_assignment_source_id   IN  NUMBER :=NULL,
					    p_start_date             IN  DATE:=NULL,
					    p_end_date               IN  DATE   := NULL,
					    p_assignment_status_code IN  VARCHAR2:= NULL,
					    p_sum_tasks_flag         IN  VARCHAR2 default null,
					    p_task_assignment_id_tbl IN  SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
                                            p_budget_version_id      IN NUMBER:=NULL,
					    x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
					    x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
					    x_msg_data               OUT NOCOPY VARCHAR2);  --File.Sql.39 bug 4440895


-- Procedure            : create_opn_asg_schedule
-- Purpose              : Add multiple open assignment schedules. Copy
--                        assignment schedules from an open or staffed
--                        assignment.
PROCEDURE create_stf_asg_schedule(p_project_id               IN  NUMBER,
					    p_schedule_basis_flag        IN  VARCHAR2,
					    p_project_party_id           IN  NUMBER,
					    p_calendar_id                IN  NUMBER,
					    p_assignment_id              IN  NUMBER,
					    p_open_assignment_id         IN  NUMBER,
					    p_resource_calendar_percent  IN  NUMBER,
				          p_start_date                 IN  DATE,
					    p_end_date                   IN  DATE,
					    p_assignment_status_code     IN  VARCHAR2,
					    p_work_type_id               IN  NUMBER,
					    p_task_id                    IN  NUMBER,
					    p_task_percentage            IN  NUMBER,
					    p_sum_tasks_flag             IN  VARCHAR2 default null,
				        p_task_assignment_id_tbl IN  SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
                        p_budget_version_id      IN NUMBER:=NULL,
					    x_return_status              OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
					    x_msg_count                  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
					    x_msg_data                   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
					     );


-- Procedure            : create_stf_asg_schedule
-- Purpose              : Create schedule for staffed assignments.


PROCEDURE delete_asgn_schedules ( p_assignment_id IN NUMBER,
                                  p_perm_delete IN VARCHAR2 := FND_API.G_TRUE,
                                  p_change_id IN NUMBER := null,
                                  x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count OUT NOCOPY NUMBER , --File.Sql.39 bug 4440895
                                  x_msg_data  OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure            : Delete_Asgn_Schedules
-- Purpose              : This procedure will delete the schedule,exception records corresponding to
--                        the passed assignment id
--
-- Parameters           :

PROCEDURE update_sch_wf_failure(
         p_assignment_id IN NUMBER,
         p_record_version_number IN NUMBER,
				 x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
				 x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
				 x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				);

-- Effects: Changes the schedule statuses of the assignment to the
-- appropriate failure status.

PROCEDURE update_sch_wf_success(
         p_assignment_id IN NUMBER,
         p_record_version_number IN NUMBER,
				 x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
				 x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
				 x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				);

-- Effects: Changes the schedule statuses of the assignment to the
-- appropriate success status.

PROCEDURE revert_to_last_approved(
         p_assignment_id IN NUMBER,
         p_change_id IN NUMBER,
				 x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
				 x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
				 x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				);

-- Effects: Reverts the schedule back to the last approved schedule.
-- Impl Notes: Copies schedule records with p_assignment_id, from schedules
-- history to schedules table.  Do not update if there are
-- no records with last_approved_flag = 'Y'.  Delete those records from
-- pa_schedule_history.  Be sure to use delete schedule API to remove old
-- schedules.  Also, call create_timeline.

PROCEDURE update_history_table(
         p_assignment_id IN NUMBER,
         p_change_id IN NUMBER,
				 x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
				 x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
				 x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				);

-- Effects: Adds schedule records for p_assignment_id to pa_schedules_history
-- if they do not already exist.
-- Impl Notes: If records already exist in pa_schedule_history with change_id,
-- then do nothing.  Otherwise, uncheck any records with last_approved_flag
-- and copy schedule records there with correct change_id with
-- last_approved_flag checked.


--
-- Procedure : Update_asgmt_changed_items_tab
-- Purpose   : Poplulates new and old values for schedule changes to pa_asgmt_changed_items
--             table which stores the assignment_changes that are pending approval.
-- Parameter
--             p_populate_mode : SAVED/ASSIGNMENT_UPDATED/SCHEDULE_UPDATED
--
PROCEDURE update_asgmt_changed_items_tab
( p_assignment_id               IN  NUMBER
 ,p_populate_mode               IN  VARCHAR2                                                := 'SAVED'
 ,p_change_id                   IN  NUMBER
 ,p_exception_type_code         IN  VARCHAR2                                                := NULL
 ,p_start_date                  IN  DATE                                                    := NULL
 ,p_end_date                    IN  DATE                                                    := NULL
 ,p_requirement_status_code     IN  VARCHAR2                                                := NULL
 ,p_assignment_status_code      IN  VARCHAR2                                                := NULL
 ,p_start_date_tbl              IN  SYSTEM.PA_DATE_TBL_TYPE := NULL
 ,p_end_date_tbl                IN  SYSTEM.PA_DATE_TBL_TYPE := NULL
 ,p_monday_hours_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_tuesday_hours_tbl           IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_wednesday_hours_tbl         IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_thursday_hours_tbl          IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_friday_hours_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_saturday_hours_tbl          IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_sunday_hours_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_non_working_day_flag        IN  VARCHAR2                                                := 'N'
 ,p_change_hours_type_code      IN  VARCHAR2                                                := NULL
 ,p_hrs_per_day                 IN  NUMBER                                                  := NULL
 ,p_calendar_percent            IN  NUMBER                                                  := NULL
 ,p_change_calendar_type_code   IN  VARCHAR2                                                := NULL
 ,p_change_calendar_name        IN  VARCHAR2                                                := NULL
 ,p_change_calendar_id          IN  NUMBER                                                  := NULL
 ,p_duration_shift_type_code    IN  VARCHAR2                                                := NULL
 ,p_duration_shift_unit_code    IN  VARCHAR2                                                := NULL
 ,p_number_of_shift             IN  NUMBER                                                  := NULL
 ,x_return_status               OUT NOCOPY VARCHAR2);       --File.Sql.39 bug 4440895


-- Procedure  : check_overcommitment_single
-- Purpose		: First checks if this assignment alone causes resource
--              overcommitment. If Yes, then stores self-conflict and user
--              action in PA_ASSIGNMENT_CONFLICT_HIST.
PROCEDURE check_overcommitment_single( p_assignment_id     IN   NUMBER,
            p_resolve_conflict_action_code			IN		VARCHAR2,
            p_conflict_group_id           IN    NUMBER := NULL,
            x_overcommitment_flag               OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_conflict_group_id           OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT  NOCOPY VARCHAR2 );  --File.Sql.39 bug 4440895


-- Procedure  : check_overcommitment_mult
-- Purpose		: First checks if this assignment alone causes resource
--              overcommitment. If Yes, then stores self-conflict and user
--              action in PA_ASSIGNMENT_CONFLICT_HIST.
PROCEDURE check_overcommitment_mult(p_item_type  IN PA_WF_PROCESSES.item_type%TYPE,
            p_item_key           IN   PA_WF_PROCESSES.item_key%TYPE,
            p_conflict_group_id                 IN   NUMBER := NULL,
            p_resolve_conflict_action_code			IN		VARCHAR2,
            x_overcommitment_flag               OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_conflict_group_id                 OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT  NOCOPY VARCHAR2 );  --File.Sql.39 bug 4440895


-- Procedure  : check_self_conflict
-- Purpose		: Check if the assignment is causing self conflict.
--
PROCEDURE check_self_conflict(p_assignment_id   IN  NUMBER,
            p_resource_id            IN    NUMBER,
            p_start_date             IN    DATE,
            p_end_date               IN    DATE,
            x_self_conflict_flag     OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


-- Procedure  : resolve_conflicts
-- Purpose		: Resolves remaining conflicts by taking action chosen to user
--              detailed in PA_ASSIGNMENT_CONFLICT_HIST. Updates
--              processed_flag in the table once complete.
PROCEDURE resolve_conflicts( p_conflict_group_id   IN   NUMBER,
            p_assignment_id     IN   NUMBER,
            x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT  NOCOPY VARCHAR2 );  --File.Sql.39 bug 4440895


PROCEDURE insert_work_pattern_record( p_assignment_id   IN   NUMBER,
            p_item_quantity     IN   NUMBER,
            p_item_date         IN   DATE,
            p_week_end_date      IN   DATE,
            x_work_pattern_tbl  IN OUT NOCOPY WorkPatternTabTyp,
            x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


PROCEDURE update_work_pattern_record(p_overcom_quantity     IN   NUMBER,
            p_count             IN   NUMBER,
            p_item_date         IN   DATE,
            x_work_pattern_tbl  IN OUT NOCOPY WorkPatternTabTyp,
            x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


PROCEDURE insert_work_pattern_tab(p_cur_work_pattern_tbl  IN  WorkPatternTabTyp,
            x_work_pattern_tbl  IN OUT NOCOPY WorkPatternTabTyp,
            x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


-- Procedure  : overcom_post_aprvl_processing
-- Purpose		: Completes post-processing for overcommitment module after
--              approval is complete.
PROCEDURE overcom_post_aprvl_processing(p_conflict_group_id  IN  NUMBER,
            p_fnd_user_name     IN   VARCHAR2,
            x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT  NOCOPY VARCHAR2 );  --File.Sql.39 bug 4440895


-- Procedure  : will_resolve_conflicts_by_rmvl
-- Purpose		: Returns 'Y' if user has chosen to remove one or more
--              conflicts.
PROCEDURE will_resolve_conflicts_by_rmvl(p_conflict_group_id  IN  NUMBER,
            x_resolve_conflicts_by_rmvl  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data                   OUT  NOCOPY VARCHAR2 );  --File.Sql.39 bug 4440895


-- Procedure  : has_resolved_conflicts_by_rmvl
-- Purpose		: Returns 'Y' if remove conflicts has been sucessful.
PROCEDURE has_resolved_conflicts_by_rmvl(p_conflict_group_id  IN  NUMBER,
            p_assignment_id              IN   NUMBER,
            x_resolve_conflicts_by_rmvl  OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


-- Procedure  : cancel_overcom_txn_items
-- Purpose		: Cancels transaction items marked with CANCEL_TXN_ITEM.
--              Updates processed_flag in the table once complete.
PROCEDURE cancel_overcom_txn_items (p_conflict_group_id  IN  NUMBER,
            x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT  NOCOPY VARCHAR2 );  --File.Sql.39 bug 4440895


-- Procedure  : revert_overcom_txn_items
-- Purpose		: Reverts transaction items marked with REVERT_TXN_ITEM.
--              Updates processed_flag in the table once complete.
PROCEDURE revert_overcom_txn_items (p_conflict_group_id  IN  NUMBER,
            x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT  NOCOPY VARCHAR2 );  --File.Sql.39 bug 4440895


-- Procedure  : get_conflicting_asgmt_count
-- Purpose		: Returns number of assignments causing conflict including
--              self conflict.
PROCEDURE get_conflicting_asgmt_count (p_conflict_group_id  IN  NUMBER,
            x_assignment_count  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT  NOCOPY VARCHAR2 );  --File.Sql.39 bug 4440895


PROCEDURE has_action_taken_on_conflicts (p_conflict_group_id  IN
NUMBER,
            x_action_taken         OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_return_status        OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count            OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data             OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE check_asgmt_apprvl_working (p_conflict_group_id  IN
NUMBER,
            x_result               OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_return_status        OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count            OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data             OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

-- Procedure  : sum_task_assignments
-- Purpose	  : Sums the task assignments given a schedule of working days and output a
-- 			  	new project schedule spanning from p_start_date to p_end_date
--Bug 5126919: Added parameter x_total_hours which will contain the total hours for which the x_schedule_tbl
--will be prepared.
PROCEDURE sum_task_assignments (
	p_task_assignments_tbl	IN	SYSTEM.PA_NUM_TBL_TYPE			,
	p_schedule_tbl			IN	PA_SCHEDULE_GLOB.ScheduleTabTyp	,
	p_start_date			IN	DATE							,
	p_end_date				IN	DATE							,
	x_total_hours			OUT	NOCOPY	NUMBER                          , -- Bug 5126919
	x_schedule_tbl			OUT	NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp	, --File.Sql.39 bug 4440895
	x_return_status			OUT	NOCOPY VARCHAR2						,		 --File.Sql.39 bug 4440895
	x_msg_count				OUT	NOCOPY NUMBER							, --File.Sql.39 bug 4440895
	x_msg_data				OUT	NOCOPY VARCHAR2					 --File.Sql.39 bug 4440895
);

-- Procedure  : set_hours_by_day_of_wee
-- Purpose	  : sets the number of hours in a given schedule record for a particular
-- 			  	day of the week
PROCEDURE set_hours_by_day_of_week (
		 p_schedule_record		  IN OUT NOCOPY	  PA_SCHEDULE_GLOB.ScheduleRecord  ,
		 p_day_of_week			  IN	  		  PA_SCHEDULE_PVT.DayOfWeekType	   ,
		 p_hours				  IN	  		  NUMBER);

-- Function		: Get_changed_item_name_text
-- Purpose		: Returns the changed item name display text for
--			        p_exception_type_code.
FUNCTION get_changed_item_name_text( p_exception_type_code IN VARCHAR2)
         RETURN VARCHAR2;


-- Function		: Get_date_range_text
-- Purpose		: Returns the display text for the date range of the
--			        assignment.
FUNCTION Get_date_range_text ( p_start_date IN DATE,
                             p_end_date IN DATE) RETURN VARCHAR2;


-- Function		: Get_old_value_text
-- Purpose		: Returns the display text for the old schedule value
--			        of the assignment.
FUNCTION Get_old_value_text (p_exception_type_code IN VARCHAR2,
                             p_assignment_id IN NUMBER,
                             p_start_date IN DATE,
                             p_end_date IN DATE) RETURN VARCHAR2;

-- Function		: Get_new_value_text
-- Purpose		: Returns the display text for the new schedule value
--			  of the assignment.
FUNCTION Get_new_value_text (p_exception_type_code        IN VARCHAR2,
                             p_new_calendar_id            IN NUMBER,
                             p_new_start_date             IN DATE,
                             p_new_end_date               IN DATE,
			     p_new_status_code            IN VARCHAR2,
                             p_new_change_calendar_id     IN NUMBER,
                             p_new_monday_hours           IN NUMBER,
                             p_new_tuesday_hours          IN NUMBER,
                             p_new_wednesday_hours        IN NUMBER,
                             p_new_thursday_hours         IN NUMBER,
                             p_new_friday_hours           IN NUMBER,
                             p_new_saturday_hours         IN NUMBER,
                             p_new_sunday_hours           IN NUMBER,
                             p_new_change_hours_type_code IN VARCHAR2,
                             p_new_non_working_day_flag   IN VARCHAR2,
                             p_new_hours_per_day          IN NUMBER,
                             p_new_calendar_percent       IN NUMBER,
                             p_new_change_cal_type_code   IN VARCHAR2 := null,
                             p_new_change_calendar_name   IN VARCHAR2 := null)
RETURN VARCHAR2;

-- Function		: get_num_days_of_conflict
-- Purpose		: Return number of days in assignment that are in conflict with
--              existing confirmed assignments, and potentially in conflict
--              with other assignments in transaction including itself.
FUNCTION get_num_days_of_conflict (p_assignment_id IN NUMBER,
                 p_resource_id   IN NUMBER,
                 p_conflict_group_id IN NUMBER) RETURN NUMBER;


-- Function		: column_val_conflict_exists
-- Purpose		: Returns value to display in 'Conflict Exists' column ('Yes',
--              'No')
FUNCTION column_val_conflict_exists (p_conflict_group_id IN NUMBER,
                             p_assignment_id IN NUMBER ) RETURN VARCHAR2;


-- Function		: column_val_conflict_action
-- Purpose		: Returns value to display in 'Action on Approval' column
--              ('Remove Conflicts', Continue with Conflicts', ''). A
--              self-conflict would imply 'Continue with Conflicts'. No value
--              would be shown for those assignments not causing
--              overcommitment.
FUNCTION column_val_conflict_action (p_conflict_group_id IN NUMBER,
                             p_assignment_id IN NUMBER ) RETURN VARCHAR2;


-- Function		: check_conflict_proj_affected
-- Purpose		: Returns a value to the View Conflicts page to filter for
--              the assignments that are in conflict with the assignments in
--              a particular conflicting project.
FUNCTION check_conflict_proj_affected (p_conflict_group_id IN NUMBER,
                             p_assignment_id IN NUMBER,
                             p_conflict_project_id IN NUMBER) RETURN VARCHAR2;

-- Function		: check_self_conflict_exist
-- Purpose		: Returns a value to the View Conflicts page to filter for
--              the assignments with self_conflict_flag = 'Y' and being chosen to
--              remove conflicts.
FUNCTION check_self_conflict_exist(p_conflict_group_id IN NUMBER,
                             p_assignment_id IN NUMBER) RETURN VARCHAR2;

--
-- Returns ak attribute label corresponding p_region_code, p_attribute_code
--
FUNCTION get_ak_attribute_label (p_region_code    IN VARCHAR2,
                                 p_attribute_code IN VARCHAR2)
RETURN VARCHAR2;

-- Function		: get_day_of_week
-- Purpose		: Determines the day of the week given a particular date
FUNCTION get_day_of_week (p_date IN DATE) RETURN PA_SCHEDULE_PVT.DayOfWeekType;

-- Function		: check_self_conflict_exist
-- Purpose		: Returns the number of hours in a given schedule record for a
-- 				  particular day of the week
FUNCTION get_hours_by_day_of_week (
		 p_schedule_record		  IN	  PA_SCHEDULE_GLOB.ScheduleRecord  ,
		 p_day_of_week			  IN	  PA_SCHEDULE_PVT.DayOfWeekType )
		 RETURN NUMBER;

END PA_SCHEDULE_PVT;

/
