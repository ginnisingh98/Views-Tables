--------------------------------------------------------
--  DDL for Package CSF_TASKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_TASKS_PUB" AUTHID CURRENT_USER AS
/* $Header: CSFPTSKS.pls 120.21.12010000.17 2013/03/04 06:44:20 rkamasam ship $ */

  -- Update Parent Task Actions
  g_action_normal_to_parent   CONSTANT PLS_INTEGER := 1;
  g_action_parent_to_normal   CONSTANT PLS_INTEGER := 2;

  -- Update Customer Confirmation Actions
  g_action_conf_to_required   CONSTANT PLS_INTEGER := 1;
  g_action_conf_to_received   CONSTANT PLS_INTEGER := 2;
  g_action_conf_not_required  CONSTANT PLS_INTEGER := 3;

  -- Customer Confirmation Initiation
  g_dispatcher_initiated      CONSTANT PLS_INTEGER := 1;
  g_customer_initiated        CONSTANT PLS_INTEGER := 2;

  g_reschedule VARCHAR2(1) := NULL;


  -- Task Information - Important Information of Task from JTF_TASKS_B
  TYPE tasks_rec_type IS RECORD (
    row_id                    VARCHAR2 (18)
  , task_id                   jtf_tasks_b.task_id%TYPE
  , object_version_number     jtf_tasks_b.object_version_number%TYPE
  , task_status_id            jtf_tasks_b.task_status_id%TYPE
  , task_status               VARCHAR2 (30)
  , scheduled_start_date      jtf_tasks_b.scheduled_start_date%TYPE
  , scheduled_end_date        jtf_tasks_b.scheduled_end_date%TYPE
  , planned_start_date        jtf_tasks_b.planned_start_date%TYPE
  , planned_end_date          jtf_tasks_b.planned_end_date%TYPE
  , planned_effort            jtf_tasks_b.planned_effort%TYPE
  , planned_effort_uom        jtf_tasks_b.planned_effort_uom%TYPE
  , status_schedulable_flag   VARCHAR2 (1)
  , type_schedulable_flag     VARCHAR2 (1)
  , status_assigned_flag      VARCHAR2 (1)
  , resource_name             VARCHAR2 (4000)
  , task_split_flag           jtf_tasks_b.task_split_flag%TYPE
  , parent_task_id            jtf_tasks_b.parent_task_id%TYPE
  , updated_flag              VARCHAR2 (1)
  );

  TYPE tasks_tbl_type IS TABLE OF tasks_rec_type;

  /**
   * Validates the Task Status Transition based on the Old Status and
   * the Chosen Responsibility.
   * <br>
   * If Old Task Status is provided, then validation is done to check whether
   * there exists a Transition from the given Old Status to the given New Status
   * for the signed in responsibility (FND_GLOBAL.RESP_ID).
   * <br>
   * If Old Task Status is not provided, then check is made to find out whether
   * the New Status as the Initial Status is allowed or not for the responsibility.
   *
   * @param   p_state_type      Type of Statuses API should deal with (Default TASK_STATUS)
   * @param   p_old_status_id   Current Task Status ID from which Transition is initiated.
   * @param   p_new_status_id   Proposed New Task Status ID.
   * @return Returns FND_API.G_TRUE/G_FALSE depending on the possibility
   */
  FUNCTION validate_state_transition (
    p_state_type      VARCHAR2 DEFAULT 'TASK_STATUS'
  , p_old_status_id   NUMBER   DEFAULT NULL
  , p_new_status_id   NUMBER
  )
    RETURN VARCHAR2;

  /**
   * Returns the set of Valid Task Statuses possible from the given Old Task Statuses.
   * <br>
   * Always used in conjunction with VALIDATE_STATE_TRANSITION to find the valid
   * statuses possible from the old status if the Task Status Transition to the proposed
   * new status is not allowed.
   * <br>
   * If Old Status is given, then the possible New Task Statuses is returned separated
   * by FND_GLOBAL.LOCAL_CHR(10). If Old Status is not given, then the possible New Task
   * Statuses as the Initial Status is returned separated by FND_GLOBAL.LOCAL_CHR(10).
   *
   * @param   p_state_type      Type of Statuses API should deal with (Default TASK_STATUS)
   * @param   p_old_status_id   Current Task Status ID from which Transition is initiated.
   * @return List of Valid Statuses (VARCHAR2).
   */
  FUNCTION get_valid_statuses (
    p_state_type      VARCHAR2 DEFAULT 'TASK_STATUS'
  , p_old_status_id   NUMBER   DEFAULT NULL
  )
    RETURN VARCHAR2;

  /**
   * Validates whether the transition from the given Old Status to the new
   * Status is possible. If its not possible, it raises an error
   * (FND_API.G_EXC_ERROR) after pushing the appropriate message into the
   * stack. It leverages VALIDATE_STATE_TRANSITION and GET_VALID_STATUSES
   * for the operation.
   */
  PROCEDURE validate_status_change(
    p_old_status_id NUMBER
  , p_new_status_id NUMBER
  );

  /**
   * Returns the Translated Task Status Name given the Task Status ID.
   *
   * @param    p_task_status_id   Task Status ID
   * @return  Translated Task Status Name
   */
  FUNCTION get_task_status_name (p_task_status_id NUMBER)
    RETURN VARCHAR2;

  /**
   * Returns the constant Task Type ID used for Departure Tasks.
   *
   * @return  Departure Task Type ID (20)
   */
  FUNCTION get_dep_task_type_id
    RETURN NUMBER;

  /**
   * Returns the constant Task Type ID used for Arrival Tasks.
   *
   * @return  Arrival Task Type ID (21)
   */
  FUNCTION get_arr_task_type_id
    RETURN NUMBER;

  /**
   * Checks whether the given Task can be closed and returns True or False
   * accordingly.
   *
   * A Task can be closed only when
   *   1. There exists a Transition from the current Task Status to the Closed Status
   *   2. There are no Active / Open Task Assignments ( In-Planning, Planned, Assigned, Working)
   *   3. If the profile "CSFW: Update Schedulable Task" is set to Yes, then the Debrief if
   *      any linked to any of the Task Assignments of the Task should be in COMPLETED status.
   * <br>
   * The message stack will be populated with the proper message to indicate the
   * reason why the Task is not closable.
   *
   * @param    x_return_status           Return Status of the Procedure.
   * @param    x_msg_count               Number of Messages in the Stack.
   * @param    x_msg_data                Stack of Error Messages.
   * @param    p_task_id                 Task ID of the Task to be checked
   * @return  True / False
   */
  FUNCTION is_task_closable (
    x_return_status   OUT NOCOPY      VARCHAR2
  , x_msg_count       OUT NOCOPY      NUMBER
  , x_msg_data        OUT NOCOPY      VARCHAR2
  , p_task_id         IN              NUMBER
  )
    RETURN BOOLEAN;

  /**
   * Checks whether the given Task can be closed and returns True or False
   * accordingly.
   * @deprecated Use IS_TASK_CLOSABLE (SR Team is still calling this version)
   */
  FUNCTION task_is_closable (
    x_return_status   OUT NOCOPY      VARCHAR2
  , x_msg_count       OUT NOCOPY      NUMBER
  , x_msg_data        OUT NOCOPY      VARCHAR2
  , p_task_id         IN              NUMBER
  )
    RETURN BOOLEAN;

  /**
   * Checks whether the given parameters of a Task (created or not yet created)
   * will make the task schedulable or not and returns True or False
   * accordingly.
   *
   * A Task is schedulable only when
   *   1. Task doesnt have Deleted Flag set to 'Y'.
   *   2. Task has Planned Window set properly - both Planned Start and Planned End.
   *   3. Task has Planned Effort.
   *   4. Task Status is schedulable (Task Status should have SCHEDULE_FLAG = 'Y')
   *   5. Task Type is schedulable (Task Type should have SCHEDULABLE_FLAG = 'Y')
   *   6. Task Type belongs to the DISPATCH Rule.
   * <br>
   *
   * @param    p_deleted_flag            Whether the Task is already deleted
   * @param    p_planned_start_date      Planned Start date
   * @param    p_planned_end_date        Planned End date
   * @param    p_planned_effort          Planned Effort
   * @param    p_task_type_id            Task Type ID
   * @param    p_task_status_id          Task Status ID
   * @param    x_reason_code             If the Task is not schedulable, WHY ?
   *
   * @return  True / False
   */
  FUNCTION check_schedulable(
    p_deleted_flag       IN         VARCHAR2
  , p_planned_start_date IN         DATE
  , p_planned_end_date   IN         DATE
  , p_planned_effort     IN         NUMBER
  , p_task_type_id       IN         NUMBER
  , p_task_status_id     IN         NUMBER
  , x_reason_code        OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN;

  /**
   * Checks whether the given Task is schedulable or not and returns True or False
   * accordingly.
   *
   * A Task is schedulable only when
   *   1. Task doesnt have Deleted Flag set to 'Y'.
   *   2. Task has Planned Window set properly - both Planned Start and Planned End.
   *   3. Task has Planned Effort.
   *   4. Task Status is schedulable (Task Status should have SCHEDULE_FLAG = 'Y')
   *   5. Task Type is schedulable (Task Type should have SCHEDULABLE_FLAG = 'Y')
   *   6. Task Type belongs to the DISPATCH Rule.
   * <br>
   * The message stack will be populated with the proper message to indicate the
   * reason (one among the six) why the Task is not schedulable.
   *
   * @param    x_return_status           Return Status of the Procedure.
   * @param    x_msg_count               Number of Messages in the Stack.
   * @param    x_msg_data                Stack of Error Messages.
   * @param    p_task_id                 Task ID of the Task to be checked
   * @return  True / False
   */
  FUNCTION is_task_schedulable (
    x_return_status   OUT NOCOPY      VARCHAR2
  , x_msg_count       OUT NOCOPY      NUMBER
  , x_msg_data        OUT NOCOPY      VARCHAR2
  , p_task_id         IN              NUMBER
  )
    RETURN BOOLEAN;

  /**
   * Checks whether the given Task is already scheduled or not.
   *
   * A Task is already scheduled when
   *   1. Task has Scheduled Start and End Date stamped.
   *   2. Task has Assignments which are not in Cancelled Status
   *
   * @param    x_return_status           Return Status of the Procedure.
   * @param    x_msg_count               Number of Messages in the Stack.
   * @param    x_msg_data                Stack of Error Messages.
   * @param    p_task_id                 Task ID of the Task to be checked
   * @return  True / False
   */
  FUNCTION is_task_scheduled (
    x_return_status   OUT NOCOPY      VARCHAR2
  , x_msg_count       OUT NOCOPY      NUMBER
  , x_msg_data        OUT NOCOPY      VARCHAR2
  , p_task_id         IN              NUMBER
  )
    RETURN BOOLEAN;

  /**
   * Checks whether the given Task is escalated or not.
   *
   * A Task is escalated when
   *   1. There exists a Task Reference in JTF_TASK_REFERENCES
   *      linked to the given Task with Object Type as TASK and Reference Code as ESC.
   *   2. The referred Task should have Task Type ID as 22 (Escalated Task Type) and
   *       and should be open (Not Closed, Completed or Cancelled).
   *
   * @param    p_task_id                 Task ID of the Task to be checked
   * @return  True / False
   */
  FUNCTION is_task_escalated(p_task_id NUMBER)
    RETURN BOOLEAN;


  /**
   * Checks whether the given Task Type has Field Service Rule attached.
   *
   * @param    p_task_type_id         Task Type ID to be checked
   * @return  FND_API.G_TRUE / FND_API.G_FALSE
   */
  FUNCTION has_field_service_rule (p_task_type_id NUMBER)
    RETURN VARCHAR2;

  /**
   * Create a new Field Service Task
   *
   * Create a new Task by calling JTF_TASKS_PUB API. The only difference is that
   * the task to be created has to be Schedulable as per Field Service Standards.
   * Uses the same logic as that of IS_TASK_SCHEDULABLE.
   *
   * Right now P_PARENT_TASK_ID, P_PARENT_TASK_NUMBER, P_TASK_SPLIT_FLAG,
   * P_CHILD_SEQUENCE_NUM, P_CHILD_POSITION, P_ENABLE_WORKFLOW and P_ABORT_WORKFLOW
   * wont be used and its just in the signature as JTF Task API hasnt exposed any
   * API wherein all parameters can be passed in a single shot.
   * Note that JTF_TASKS_PUB.UPDATE_TASK cant be invoked as the caller module always
   * assumes that the OBJECT_VERSION_NUMBER of the newly created task is 1.
   */
  PROCEDURE create_task (
    p_api_version               IN           NUMBER
  , p_init_msg_list             IN           VARCHAR2  DEFAULT NULL
  , p_commit                    IN           VARCHAR2  DEFAULT NULL
  , x_return_status             OUT  NOCOPY  VARCHAR2
  , x_msg_count                 OUT  NOCOPY  NUMBER
  , x_msg_data                  OUT  NOCOPY  VARCHAR2
  , p_task_id                   IN           NUMBER    DEFAULT NULL
  , p_task_name                 IN           VARCHAR2
  , p_description               IN           VARCHAR2  DEFAULT NULL
  , p_task_type_name            IN           VARCHAR2  DEFAULT NULL
  , p_task_type_id              IN           NUMBER    DEFAULT NULL
  , p_task_status_name          IN           VARCHAR2  DEFAULT NULL
  , p_task_status_id            IN           NUMBER    DEFAULT NULL
  , p_task_priority_name        IN           VARCHAR2  DEFAULT NULL
  , p_task_priority_id          IN           NUMBER    DEFAULT NULL
  , p_owner_type_name           IN           VARCHAR2  DEFAULT NULL
  , p_owner_type_code           IN           VARCHAR2  DEFAULT NULL
  , p_owner_id                  IN           NUMBER    DEFAULT NULL
  , p_owner_territory_id        IN           NUMBER    DEFAULT NULL
  , p_owner_status_id           IN           NUMBER    DEFAULT NULL
  , p_assigned_by_name          IN           VARCHAR2  DEFAULT NULL
  , p_assigned_by_id            IN           NUMBER    DEFAULT NULL
  , p_customer_number           IN           VARCHAR2  DEFAULT NULL
  , p_customer_id               IN           NUMBER    DEFAULT NULL
  , p_cust_account_number       IN           VARCHAR2  DEFAULT NULL
  , p_cust_account_id           IN           NUMBER    DEFAULT NULL
  , p_address_id                IN           NUMBER    DEFAULT NULL
  , p_address_number            IN           VARCHAR2  DEFAULT NULL
  , p_location_id               IN           NUMBER    DEFAULT NULL
  , p_planned_start_date        IN           DATE      DEFAULT NULL
  , p_planned_end_date          IN           DATE      DEFAULT NULL
  , p_scheduled_start_date      IN           DATE      DEFAULT NULL
  , p_scheduled_end_date        IN           DATE      DEFAULT NULL
  , p_actual_start_date         IN           DATE      DEFAULT NULL
  , p_actual_end_date           IN           DATE      DEFAULT NULL
  , p_timezone_id               IN           NUMBER    DEFAULT NULL
  , p_timezone_name             IN           VARCHAR2  DEFAULT NULL
  , p_source_object_type_code   IN           VARCHAR2  DEFAULT NULL
  , p_source_object_id          IN           NUMBER    DEFAULT NULL
  , p_source_object_name        IN           VARCHAR2  DEFAULT NULL
  , p_duration                  IN           NUMBER    DEFAULT NULL
  , p_duration_uom              IN           VARCHAR2  DEFAULT NULL
  , p_planned_effort            IN           NUMBER    DEFAULT NULL
  , p_planned_effort_uom        IN           VARCHAR2  DEFAULT NULL
  , p_actual_effort             IN           NUMBER    DEFAULT NULL
  , p_actual_effort_uom         IN           VARCHAR2  DEFAULT NULL
  , p_percentage_complete       IN           NUMBER    DEFAULT NULL
  , p_reason_code               IN           VARCHAR2  DEFAULT NULL
  , p_private_flag              IN           VARCHAR2  DEFAULT NULL
  , p_publish_flag              IN           VARCHAR2  DEFAULT NULL
  , p_restrict_closure_flag     IN           VARCHAR2  DEFAULT NULL
  , p_multi_booked_flag         IN           VARCHAR2  DEFAULT NULL
  , p_milestone_flag            IN           VARCHAR2  DEFAULT NULL
  , p_holiday_flag              IN           VARCHAR2  DEFAULT NULL
  , p_billable_flag             IN           VARCHAR2  DEFAULT NULL
  , p_bound_mode_code           IN           VARCHAR2  DEFAULT NULL
  , p_soft_bound_flag           IN           VARCHAR2  DEFAULT NULL
  , p_workflow_process_id       IN           NUMBER    DEFAULT NULL
  , p_notification_flag         IN           VARCHAR2  DEFAULT NULL
  , p_notification_period       IN           NUMBER    DEFAULT NULL
  , p_notification_period_uom   IN           VARCHAR2  DEFAULT NULL
  , p_alarm_start               IN           NUMBER    DEFAULT NULL
  , p_alarm_start_uom           IN           VARCHAR2  DEFAULT NULL
  , p_alarm_on                  IN           VARCHAR2  DEFAULT NULL
  , p_alarm_count               IN           NUMBER    DEFAULT NULL
  , p_alarm_interval            IN           NUMBER    DEFAULT NULL
  , p_alarm_interval_uom        IN           VARCHAR2  DEFAULT NULL
  , p_palm_flag                 IN           VARCHAR2  DEFAULT NULL
  , p_wince_flag                IN           VARCHAR2  DEFAULT NULL
  , p_laptop_flag               IN           VARCHAR2  DEFAULT NULL
  , p_device1_flag              IN           VARCHAR2  DEFAULT NULL
  , p_device2_flag              IN           VARCHAR2  DEFAULT NULL
  , p_device3_flag              IN           VARCHAR2  DEFAULT NULL
  , p_costs                     IN           NUMBER    DEFAULT NULL
  , p_currency_code             IN           VARCHAR2  DEFAULT NULL
  , p_escalation_level          IN           VARCHAR2  DEFAULT NULL
  , p_attribute1                IN           VARCHAR2  DEFAULT NULL
  , p_attribute2                IN           VARCHAR2  DEFAULT NULL
  , p_attribute3                IN           VARCHAR2  DEFAULT NULL
  , p_attribute4                IN           VARCHAR2  DEFAULT NULL
  , p_attribute5                IN           VARCHAR2  DEFAULT NULL
  , p_attribute6                IN           VARCHAR2  DEFAULT NULL
  , p_attribute7                IN           VARCHAR2  DEFAULT NULL
  , p_attribute8                IN           VARCHAR2  DEFAULT NULL
  , p_attribute9                IN           VARCHAR2  DEFAULT NULL
  , p_attribute10               IN           VARCHAR2  DEFAULT NULL
  , p_attribute11               IN           VARCHAR2  DEFAULT NULL
  , p_attribute12               IN           VARCHAR2  DEFAULT NULL
  , p_attribute13               IN           VARCHAR2  DEFAULT NULL
  , p_attribute14               IN           VARCHAR2  DEFAULT NULL
  , p_attribute15               IN           VARCHAR2  DEFAULT NULL
  , p_attribute_category        IN           VARCHAR2  DEFAULT NULL
  , p_date_selected             IN           VARCHAR2  DEFAULT NULL
  , p_category_id               IN           NUMBER    DEFAULT NULL
  , p_show_on_calendar          IN           VARCHAR2  DEFAULT NULL
  , p_task_assign_tbl           IN           jtf_tasks_pub.task_assign_tbl   DEFAULT jtf_tasks_pub.g_miss_task_assign_tbl
  , p_task_depends_tbl          IN           jtf_tasks_pub.task_depends_tbl  DEFAULT jtf_tasks_pub.g_miss_task_depends_tbl
  , p_task_rsrc_req_tbl         IN           jtf_tasks_pub.task_rsrc_req_tbl DEFAULT jtf_tasks_pub.g_miss_task_rsrc_req_tbl
  , p_task_refer_tbl            IN           jtf_tasks_pub.task_refer_tbl    DEFAULT jtf_tasks_pub.g_miss_task_refer_tbl
  , p_task_dates_tbl            IN           jtf_tasks_pub.task_dates_tbl    DEFAULT jtf_tasks_pub.g_miss_task_dates_tbl
  , p_task_notes_tbl            IN           jtf_tasks_pub.task_notes_tbl    DEFAULT jtf_tasks_pub.g_miss_task_notes_tbl
  , p_task_recur_rec            IN           jtf_tasks_pub.task_recur_rec    DEFAULT jtf_tasks_pub.g_miss_task_recur_rec
  , p_task_contacts_tbl         IN           jtf_tasks_pub.task_contacts_tbl DEFAULT jtf_tasks_pub.g_miss_task_contacts_tbl
  , p_template_id               IN           NUMBER    DEFAULT NULL
  , p_template_group_id         IN           NUMBER    DEFAULT NULL
  , p_enable_workflow           IN           VARCHAR2  DEFAULT NULL
  , p_abort_workflow            IN           VARCHAR2  DEFAULT NULL
  , p_task_split_flag           IN           VARCHAR2  DEFAULT NULL
  , p_parent_task_number        IN           VARCHAR2  DEFAULT NULL
  , p_parent_task_id            IN           NUMBER    DEFAULT NULL
  , p_child_position            IN           VARCHAR2  DEFAULT NULL
  , p_child_sequence_num        IN           NUMBER    DEFAULT NULL
  , x_task_id                   OUT  NOCOPY  NUMBER
  );

  /**
   * Update an existing Task with new Task Attributes
   *
   * Given the Task ID and Task Object Version Number, it calls JTF Task API
   * to update the Task with the new Attributes. It is actually a two step
   * process
   *    1. Updating the Task with the new Task Attributes except Task Status
   *    2. Updating the Task with the new Task Status (if not FND_API.G_MISS_NUM)
   *       by calling UPDATE_TASK_STATUS.
   * <br>
   * Because of the two step process, the returned Task Object Version Number might
   * be incremented by 2 when user might have expected an increment of only 1.
   * <br>
   * Except Task ID, Task Object Version Number, Task Split Flag, all other
   * parameters are optional. Task Split Flag is also made mandatory to call
   * this version of UPDATE_TASK so that there is some difference between this
   * version and the other overloaded version of UPDATE_TASK which is required
   * by Service Team. The overloaded version ends up calling this version only.
   */
  PROCEDURE update_task(
    p_api_version               IN              NUMBER
  , p_init_msg_list             IN              VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                    IN              VARCHAR2 DEFAULT fnd_api.g_false
  , p_validation_level          IN              NUMBER   DEFAULT NULL
  , x_return_status             OUT    NOCOPY   VARCHAR2
  , x_msg_count                 OUT    NOCOPY   NUMBER
  , x_msg_data                  OUT    NOCOPY   VARCHAR2
  , p_task_id                   IN              NUMBER
  , p_object_version_number     IN OUT NOCOPY   NUMBER
  , p_task_number               IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_name                 IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_description               IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_planned_start_date        IN              DATE     DEFAULT fnd_api.g_miss_date
  , p_planned_end_date          IN              DATE     DEFAULT fnd_api.g_miss_date
  , p_scheduled_start_date      IN              DATE     DEFAULT fnd_api.g_miss_date
  , p_scheduled_end_date        IN              DATE     DEFAULT fnd_api.g_miss_date
  , p_actual_start_date         IN              DATE     DEFAULT fnd_api.g_miss_date
  , p_actual_end_date           IN              DATE     DEFAULT fnd_api.g_miss_date
  , p_timezone_id               IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_source_object_type_code   IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_source_object_id          IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_source_object_name        IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_status_id            IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_task_type_id              IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_task_priority_id          IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_owner_type_code           IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_owner_id                  IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_owner_territory_id        IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_owner_status_id           IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_assigned_by_id            IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_customer_id               IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_cust_account_id           IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_address_id                IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_location_id               IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_duration                  IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_duration_uom              IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_planned_effort            IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_planned_effort_uom        IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_actual_effort             IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_actual_effort_uom         IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_percentage_complete       IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_reason_code               IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_private_flag              IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_publish_flag              IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_restrict_closure_flag     IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_attribute1                IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_attribute2                IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_attribute3                IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_attribute4                IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_attribute5                IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_attribute6                IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_attribute7                IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_attribute8                IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_attribute9                IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_attribute10               IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_attribute11               IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_attribute12               IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_attribute13               IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_attribute14               IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_attribute15               IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_attribute_category        IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_date_selected             IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_category_id               IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_multi_booked_flag         IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_milestone_flag            IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_holiday_flag              IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_billable_flag             IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_bound_mode_code           IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_soft_bound_flag           IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_workflow_process_id       IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_notification_flag         IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_notification_period       IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_notification_period_uom   IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_alarm_start               IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_alarm_start_uom           IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_alarm_on                  IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_alarm_count               IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_alarm_fired_count         IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_alarm_interval            IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_alarm_interval_uom        IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_palm_flag                 IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_wince_flag                IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_laptop_flag               IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_device1_flag              IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_device2_flag              IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_device3_flag              IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_show_on_calendar          IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_costs                     IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_currency_code             IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_escalation_level          IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_parent_task_id            IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_parent_task_number        IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_split_flag           IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_child_position            IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_child_sequence_num        IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_enable_workflow           IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_abort_workflow            IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_find_overlap              IN              VARCHAR2 DEFAULT NULL
  );

  /**
   *  Delete an existing Task given the Task ID.
   * <br>
   * Doesnt do anything extra except for calling JTF Task API. Is existing just for the
   * sake of making this package complete and may be for future uses.
   * <br>
   * Either Task ID or Task Number has to be provided for it to be successful.
   * <br>
   * @param  p_api_version               API Version (1.0)
   * @param  p_init_msg_list             Initialize Message List
   * @param  p_commit                    Commit the Work
   * @param  x_return_status             Return Status of the Procedure.
   * @param  x_msg_count                 Number of Messages in the Stack.
   * @param  x_msg_data                  Stack of Error Messages.
   * @param  p_task_id                   Task ID of the Task to be deleted
   * @param  p_task_number               Task Number of the Task to be deleted
   * @param  p_object_version_number     Object Version of the Task to be deleted
   * @param  p_delete_future_recurrences Delete all Tasks following the same recurrence rule as this one.

   */
  PROCEDURE delete_task (
    p_api_version                 IN              NUMBER
  , p_init_msg_list               IN              VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                      IN              VARCHAR2 DEFAULT fnd_api.g_false
  , x_return_status               OUT NOCOPY      VARCHAR2
  , x_msg_count                   OUT NOCOPY      NUMBER
  , x_msg_data                    OUT NOCOPY      VARCHAR2
  , p_task_id                     IN              NUMBER   DEFAULT NULL
  , p_task_number                 IN              VARCHAR2 DEFAULT NULL
  , p_object_version_number       IN              NUMBER   DEFAULT NULL
  , p_delete_future_recurrences   IN              VARCHAR2 DEFAULT fnd_api.g_false
  );

  /**
   * Close an existing Task
   *
   * Closes an existing Task by updating the Task Status to be Closed as defined by
   * the profile "CSF: Default Auto Close Task Status (CSF_DFLT_AUTO_CLOSE_TASK_STATUS)"
   *
   * @param  p_api_version               API Version (1.0)
   * @param  p_init_msg_list             Initialize Message List
   * @param  p_commit                    Commit the Work
   * @param  x_return_status             Return Status of the Procedure.
   * @param  x_msg_count                 Number of Messages in the Stack.
   * @param  x_msg_data                  Stack of Error Messages.
   * @param  p_task_id                   Task ID of the Task to be closed
   */
  PROCEDURE close_task (
    p_api_version     IN           NUMBER
  , p_init_msg_list   IN           VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit          IN           VARCHAR2 DEFAULT fnd_api.g_false
  , x_return_status   OUT  NOCOPY  VARCHAR2
  , x_msg_count       OUT  NOCOPY  NUMBER
  , x_msg_data        OUT  NOCOPY  VARCHAR2
  , p_task_id         IN           NUMBER
  );

  /**
   * Update the Task Status with the given Status and propagate to the
   * Task Assignments also if required.
   * <br>
   * Task is updated with the new Status if the Transition from the current status
   * to the new status is allowed as determined by VALIDATE_STATE_TRANSITION.
   * Transition validation is done only when Validation Level is passed as FULL.
   *
   * If the new Status of the Task is CANCELLED, then all Assignments which are open
   * (Working, Accepted, Assigned, In-Planning, Planned, On-Hold) needs to be
   * cancelled too. Other Assignments of the Task will not be updated.
   * <br>
   * If the new Status of the Task is CLOSED, then we have to validate if the Task
   * can be closed. For this, there should not be any Open Task Assignments linked
   * to the Task. Moreover, if the Profile "CSFW: Update Schedulable Task" is set to
   * Yes, then the debrief linked with the Assignments should have been COMPLETED.
   * Otherwise Task cant be closed. If all verifications passes, then Task and the
   * open Assignments are closed. Same logic as that of TASK_IS_CLOSABLE. Have to
   * make it one.
   *
   * @param  p_api_version               API Version (1.0)
   * @param  p_init_msg_list             Initialize Message List
   * @param  p_commit                    Commit the Work
   * @param  p_validation_level          Validate the given Parameters
   * @param  x_return_status             Return Status of the Procedure.
   * @param  x_msg_count                 Number of Messages in the Stack.
   * @param  x_msg_data                  Stack of Error Messages.
   * @param  p_task_id                   Task ID of the Task to be Updated
   * @param  p_task_status_id            New Task Status ID for the Task.
   * @param  p_object_version_number     Current Task Version and also container for new one.
   */
  PROCEDURE update_task_status (
    p_api_version             IN              NUMBER
  , p_init_msg_list           IN              VARCHAR2 DEFAULT NULL
  , p_commit                  IN              VARCHAR2 DEFAULT NULL
  , p_validation_level        IN              NUMBER   DEFAULT NULL
  , x_return_status           OUT NOCOPY      VARCHAR2
  , x_msg_count               OUT NOCOPY      NUMBER
  , x_msg_data                OUT NOCOPY      VARCHAR2
  , p_task_id                 IN              NUMBER
  , p_task_status_id          IN              NUMBER
  , p_object_version_number   IN OUT NOCOPY   NUMBER
  );

  PROCEDURE autoreject_task (
    p_api_version             IN              NUMBER
  , p_init_msg_list           IN              VARCHAR2 DEFAULT NULL
  , p_commit                  IN              VARCHAR2 DEFAULT NULL
  , p_validation_level        IN              NUMBER   DEFAULT NULL
  , x_return_status           OUT NOCOPY      VARCHAR2
  , x_msg_count               OUT NOCOPY      NUMBER
  , x_msg_data                OUT NOCOPY      VARCHAR2
  , p_task_id                 IN              NUMBER
  , p_task_status_id          IN              NUMBER
  , p_object_version_number   IN OUT NOCOPY   NUMBER
  , p_reject_message          IN              VARCHAR2
  );


  /**
   * Commits the Tasks as per the given the Query Criteria or only the given Task.
   *
   * This API can be used in four different ways
   *   1. <b> Giving Query ID </b> to be used to retrieve the Tasks which should be
   *      validated and committed. For this, pass only P_QUERY_ID which will identify the
   *      query to be used from CSF_DC_QUERIES_B. Auto Commit Task Concurrent Program uses it.
   *
   *   2. <b> Giving Resource and Dates </b> which will be used to get the valid Task Assignments
   *      and committing them. Pass P_RESOURCE_ID, P_RESOURCE_TYPE, P_SCHEDULED_START_DATE
   *      and P_SCHEDULED_END_DATE to implement this feature of getting the candidates.
   *      Plan Board and Gantt uses this when a Resource is clicked and Committed.
   *
   *   3. <b> A single Task </b> can be committed too. Use P_TASK_ID to implement this feature.
   *      Planboard / Gantt / Task List Right Click on a Task uses this feature.
   *
   *   4. <b> This is called from AUTO COMMIT concurrent program for committing tasks from
   *	   selected territories by dispatcher. The parameters that are used along with Territories
   *	   are horizon and horizon UOM.
   *
   * <br>
   * Whenever a Task in the candidate list is a Parent Task, then the Child Tasks of the
   * Parent Task are processed in place of the Parent Task. Parent Task will be committed
   * thru the Automatic Task Propagation Mechanism.
   * <br>
   * Each Task is validated before it is committed
   *   1. There should be a valid Status Transition from the current status to Assigned Status.
   *   2. If the Task requires Customer Confirmation, it should be set to RECEIVED ('R').
   *   3. If the Task Assignment belongs to a Trip, the Trip shouldnt be blocked.
   *   4. The Task should have Scheduled Dates stamped.
   *
   * <br>
   * If a Task is not committed, then the stack will have the proper reason why it is committed.
   * Even if the Task is committed, then the stack is populated with the success message.
   *
   * @param  p_api_version               API Version (1.0)
   * @param  p_init_msg_list             Initialize Message List
   * @param  p_commit                    Commit the Work
   * @param  x_return_status             Return Status of the Procedure.
   * @param  x_msg_count                 Number of Messages in the Stack.
   * @param  x_msg_data                  Stack of Error Messages.
   * @param  p_resource_id               Resource ID
   * @param  p_resource_type             Resource Type
   * @param  p_scheduled_start_date      Scheduled Start Date of Tasks to be considered
   * @param  p_scheduled_end_date        Scheduled End Date of Tasks to be considered
   * @param  p_query_id                  Query ID to be used to pick up Tasks
   * @param  p_trip_id                   Trip containing the Tasks to be committed.
   * @param  p_task_id                   Task ID for one single task.
   * @param  p_task_source	    		 This will have value 'TERRITORY OR TASK_LIST_QUERY' used in AUTO COMMIT CP
   * @param  p_commit_horizon			 This is used in  AUTO COMMIT CP when p_task_source is 'TERRITORY'
   * @param  p_commit_horizon_uom		 This is used in  AUTO COMMIT CP when p_commit_horizon is not null
   * @param  p_from_task_id				 This is used in  AUTO COMMIT CP for reducing tasks in each CP (PARALLEL PROCESSING)
   * @param  p_to_task_id				 This is used in  AUTO COMMIT CP for reducing tasks in each CP (PARALLEL PROCESSING)


   */
  PROCEDURE commit_schedule (
    p_api_version            IN           NUMBER
  , p_init_msg_list          IN           VARCHAR2  DEFAULT NULL
  , p_commit                 IN           VARCHAR2  DEFAULT NULL
  , x_return_status          OUT  NOCOPY  VARCHAR2
  , x_msg_count              OUT  NOCOPY  NUMBER
  , x_msg_data               OUT  NOCOPY  VARCHAR2
  , p_resource_id            IN           NUMBER    DEFAULT NULL
  , p_resource_type          IN           VARCHAR2  DEFAULT NULL
  , p_scheduled_start_date   IN           DATE      DEFAULT NULL
  , p_scheduled_end_date     IN           DATE      DEFAULT NULL
  , p_query_id               IN           NUMBER    DEFAULT NULL
  , p_trip_id                IN           NUMBER    DEFAULT NULL
  , p_task_id                IN           NUMBER    DEFAULT NULL
  , p_task_source	         IN           VARCHAR2  DEFAULT NULL
  , p_commit_horizon		 IN  		  NUMBER    DEFAULT NULL
  , p_commit_horizon_uom	 IN  		  VARCHAR2  DEFAULT NULL
  , p_from_task_id			 IN  		  NUMBER    DEFAULT NULL
  , p_to_task_id			 IN  		  NUMBER    DEFAULT NULL
  , p_commit_horizon_from	 IN  		  NUMBER   	DEFAULT NULL
  , p_commit_uom_from	 	 IN  		  VARCHAR2 	DEFAULT NULL
  );

  /**
   * Given a set of Tasks, the API identifies the tasks which have been modified and
   * which are not by comparing the values in the collection with that in DB.
   *
   * The passed collection of Task Data itself will be updated with the new Task
   * Data and Updated Flag as 'Y' corresponding to the modified Task Record.
   *
   * @param  p_api_version               API Version (1.0)
   * @param  p_init_msg_list             Initialize Message List
   * @param  x_return_status             Return Status of the Procedure.
   * @param  x_msg_count                 Number of Messages in the Stack.
   * @param  x_msg_data                  Stack of Error Messages.
   * @param  x_collection                A Table of Tasks and its data
   * @param  x_count                     Number of Tasks modified.
   */
  PROCEDURE identify_modified_tasks (
    p_api_version     IN               NUMBER
  , p_init_msg_list   IN               VARCHAR2 DEFAULT fnd_api.g_false
  , x_return_status   OUT      NOCOPY  VARCHAR2
  , x_msg_count       OUT      NOCOPY  NUMBER
  , x_msg_data        OUT      NOCOPY  VARCHAR2
  , x_collection      IN  OUT  NOCOPY  tasks_tbl_type
  , x_count           OUT      NOCOPY  NUMBER
  );

  /**
   * Validates the passed dates against System Date.
   * If Start Date is less than System Date or NULL, then it is set to System Date.
   * If End Date is less than System Date or NULL, it is set to System Date + Planscope.
   *
   * @param x_start   Start Date of the Plan Window
   * @param x_end     End Date of the Plan Window.
   */
  PROCEDURE validate_planned_dates (x_start IN OUT NOCOPY DATE, x_end IN OUT NOCOPY DATE);

  /**
   * Moves the given Task to Scheduled Status by updating the Task and also
   * creating an Assignment with the given Resource Details.
   *
   * Suppose Old Task Assignment ID is provided, then the Old Task Assignment
   * is automatically cancelled.
   * <br>
   * Tries to validate the new Task Status by checking whether there exists any Transition
   * from the old status to tbe new one. After that updates the Task with the given
   * Status and Scheduled Timings. After that creates a new Task Assignment (or reuses Cancelled
   * Task Assignments for the Task) with the given Resource and Travel Information.
   *
   * @param  p_api_version                 API Version (1.0)
   * @param  p_init_msg_list               Initialize Message List
   * @param  p_commit                      Commit the Work
   * @param  x_return_status               Return Status of the Procedure.
   * @param  x_msg_count                   Number of Messages in the Stack.
   * @param  x_msg_data                    Stack of Error Messages.
   * @param  p_task_id                     Task ID of the Task to be Updated
   * @param  p_object_version_number       Current Task Version and also container for new one.
   * @param  p_task_status_id              New Task Status ID
   * @param  p_scheduled_start_date        New Scheduled Start Date (NULL if change not needed).
   * @param  p_scheduled_end_date          New Scheduled End Date (NULL if change not needed).
   * @param  p_planned_start_date          Planned Start Date of task.
   * @param  p_planned_end_date            Planned End Date of task.
   * @param  p_old_task_assignment_id      Old Task Assignment to be Cancelled.
   * @param  p_old_ta_object_version       Object Version of Old Task Assignment to be Cancelled.
   * @param  p_assignment_status_id        New Task Assignment Status ID
   * @param  p_resource_id                 Resource ID who will perform the Task
   * @param  p_resource_type               Type of the Resource who will perform the Task
   * @param  p_object_capacity_id          Trip ID
   * @param  p_sched_travel_distance       Scheduled Travel Distance
   * @param  p_sched_travel_duration       Scheduled Travel Duration
   * @param  p_sched_travel_duration_uom   Scheduled Travel Duration UOM
   * @param  x_task_assignment_id          Task Assignment created for the Task
   * @param  x_ta_object_version_number    Object Version Number of Task Assignment created
   */
  PROCEDURE assign_task(
    p_api_version                 IN              NUMBER
  , p_init_msg_list               IN              VARCHAR2 DEFAULT NULL
  , p_commit                      IN              VARCHAR2 DEFAULT NULL
  , x_return_status               OUT    NOCOPY   VARCHAR2
  , x_msg_count                   OUT    NOCOPY   NUMBER
  , x_msg_data                    OUT    NOCOPY   VARCHAR2
  , p_task_id                     IN              NUMBER
  , p_object_version_number       IN OUT NOCOPY   NUMBER
  , p_task_status_id              IN              NUMBER
  , p_scheduled_start_date        IN              DATE
  , p_scheduled_end_date          IN              DATE
  , p_planned_start_date          IN              DATE     DEFAULT FND_API.G_MISS_DATE
  , p_planned_end_date            IN              DATE     DEFAULT FND_API.G_MISS_DATE
  , p_old_task_assignment_id      IN              NUMBER   DEFAULT NULL
  , p_old_ta_object_version       IN              NUMBER   DEFAULT NULL
  , p_assignment_status_id        IN              NUMBER
  , p_resource_id                 IN              NUMBER
  , p_resource_type               IN              VARCHAR2
  , p_object_capacity_id          IN              NUMBER
  , p_sched_travel_distance       IN              NUMBER
  , p_sched_travel_duration       IN              NUMBER
  , p_sched_travel_duration_uom   IN              VARCHAR2
  , p_planned_effort              IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_planned_effort_uom          IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , x_task_assignment_id          OUT NOCOPY      NUMBER
  , x_ta_object_version_number    OUT NOCOPY      NUMBER
  );

  /**
   * Unschedules the Task by moving the Task to the given Task Status ID and also cancels
   * the given Assignment by moving it to the given Assignment Status ID.
   *
   * Suppose Task Status is passed as NULL, then the Task Status is not updated.
   * Suppose Assignment Status is passed as NULL, then the default Cancelled Status is used.
   * <br>
   * validates the given Task Status by checking the Transition. Also if the new Task Status
   * has Cancelled Flag checked, and if the Task is a Child Task, then Parent Task ID and
   * Task Split Flag column of the Task is cleared.
   *
   * @param  p_api_version                 API Version (1.0)
   * @param  p_init_msg_list               Initialize Message List
   * @param  p_commit                      Commit the Work
   * @param  x_return_status               Return Status of the Procedure.
   * @param  x_msg_count                   Number of Messages in the Stack.
   * @param  x_msg_data                    Stack of Error Messages.
   * @param  p_task_id                     Task ID of the Task to be Updated
   * @param  p_object_version_number       Current Task Version and also container for new one.
   * @param  p_task_status_id              New Task Status ID
   * @param  p_task_assignment_id          Task Assignment to be cancelled
   * @param  p_ta_object_version_number    Object Version Number of Task Assignment to be cancelled
   * @param  p_assignment_status_id        New Assignment Status to be used to cancel the Assignments
   */
  PROCEDURE unassign_task(
    p_api_version                IN              NUMBER
  , p_init_msg_list              IN              VARCHAR2 DEFAULT NULL
  , p_commit                     IN              VARCHAR2 DEFAULT NULL
  , x_return_status              OUT    NOCOPY   VARCHAR2
  , x_msg_count                  OUT    NOCOPY   NUMBER
  , x_msg_data                   OUT    NOCOPY   VARCHAR2
  , p_task_id                    IN              NUMBER
  , p_object_version_number      IN OUT NOCOPY   NUMBER
  , p_task_status_id             IN              NUMBER
  , p_task_assignment_id         IN              NUMBER
  , p_ta_object_version_number   IN OUT NOCOPY   NUMBER
  , p_assignment_status_id       IN              NUMBER
  );

  /**
   * Updates the affected Task along with the Assignment.
   *
   * When Tasks in a Trip are affected by Scheduling / Unscheduling a
   * Task into/from the Trip, the Task's Scheduled Dates and Travel
   * Data are updated as specified. Trip Data is not touched and Task
   * Assignment still resides in the same Trip.
   *
   * <b> Parameters and the optionality of the parameter. </b>
   *    Parameter                     NULL        FND_MISS_%   other
   *    ---------------------------   ---------   ----------   ------
   *    p_scheduled_start_date        No Change   NA           Update
   *    p_scheduled_end_date          No Change   NA           Update
   *    p_sched_travel_distance       No Change   NA           Update
   *    p_sched_travel_duration       No Change   NA           Update
   *    p_sched_travel_duration_uom   No Change   NA           Update
   *
   * <b>Key</b>
   *    NA        - Not Applicable (Value should be passed)
   *    No Change - Whatever value is there in DB for the column is retained.
   *    Update    - Column is updated with the new value in the DB
   *
   * @param  p_api_version                 API Version (1.0)
   * @param  p_init_msg_list               Initialize Message List
   * @param  p_commit                      Commit the Work
   * @param  x_return_status               Return Status of the Procedure.
   * @param  x_msg_count                   Number of Messages in the Stack.
   * @param  x_msg_data                    Stack of Error Messages.
   * @param  p_task_id                     Task ID of the Task to be Updated
   * @param  p_object_version_number       Current Task Version and also container for new one.
   * @param  p_scheduled_start_date        New Scheduled Start Date (NULL if change not needed).
   * @param  p_scheduled_end_date          New Scheduled End Date (NULL if change not needed).
   * @param  p_task_assignment_id          Task Assignment ID to be updated
   * @param  p_ta_object_version_number    Current Assignment Version and also container for new one.
   * @param  p_sched_travel_distance       Travel Distance (NULL if change not needed).
   * @param  p_sched_travel_duration       Travel Duration (NULL if change not needed).
   * @param  p_sched_travel_duration_uom   Travel Duration UOM (NULL if change not needed).
   */
  PROCEDURE update_task_and_assignment(
    p_api_version                 IN              NUMBER
  , p_init_msg_list               IN              VARCHAR2 DEFAULT NULL
  , p_commit                      IN              VARCHAR2 DEFAULT NULL
  , x_return_status               OUT    NOCOPY   VARCHAR2
  , x_msg_count                   OUT    NOCOPY   NUMBER
  , x_msg_data                    OUT    NOCOPY   VARCHAR2
  , p_task_id                     IN              NUMBER
  , p_object_version_number       IN OUT NOCOPY   NUMBER
  , p_scheduled_start_date        IN              DATE
  , p_scheduled_end_date          IN              DATE
  , p_task_assignment_id          IN              NUMBER
  , p_ta_object_version_number    IN OUT NOCOPY   NUMBER
  , p_sched_travel_distance       IN              NUMBER
  , p_sched_travel_duration       IN              NUMBER
  , p_sched_travel_duration_uom   IN              VARCHAR2
  );

  /**
   * Updates the given Task with the given information or Transforms the task
   * so that it becomes a Normal Task from a Parent Task or a Parent Task
   * from a Normal Task.
   *
   * <b> Transforming a Normal Task into a Parent Task (ScheduleOption) </b>
   *    Action should be passed as <b> CSF_TASKS_PUB.G_ACTION_NORMAL_TO_PARENT </b>
   *    Task Split Flag is changed as 'M'.
   *
   *    Parameter                     NULL        FND_MISS_%   other
   *    ---------------------------   ---------   ----------   ------
   *    p_action                      NA          NA           Process Action
   *    p_task_status_id              No Change   NA           Update
   *    p_scheduled_start_date        NA          NA           Update
   *    p_scheduled_end_date          NA          NA           Update
   *
   * <b> Updating a Parent Task </b>
   *    Action should be passed as <b> CSF_TASKS_PUB.G_ACTION_UPDATE_PARENT </b>
   *    Task Split Flag is not updated.
   *
   *    Parameter                     NULL        FND_MISS_%   other
   *    ---------------------------   ---------   ----------   ------
   *    p_action                      NA          NA           Process Action
   *    p_task_status_id              No Change   NA           Update
   *    p_scheduled_start_date        No Change   NA           Update
   *    p_scheduled_end_date          No Change   NA           Update
   *
   * <b> Transforming a Parent Task into a Normal Task (UnscheduleTask) </b>
   *    Action should be passed as <b> CSF_TASKS_PUB.G_ACTION_PARENT_TO_NORMAL </b>
   *    Task Split Flag of the Task will be cleared.
   *
   *    Parameter                     NULL        FND_MISS_%   other
   *    ---------------------------   ---------   ----------   ------
   *    p_action                      NA          NA           Process Action
   *    p_task_status_id              No Change   NA           Update
   *    p_scheduled_start_date        ** Parameter not used. Column Cleared **
   *    p_scheduled_end_date          ** Parameter not used. Column Cleared **
   *
   * <b>Key</b>
   *    NA        - Not Applicable (Value should be passed)
   *    No Change - Whatever value is there in DB for the column is retained.
   *    Update    - Column is updated with the new value in the DB
   *
   * @param  p_api_version                 API Version (1.0)
   * @param  p_init_msg_list               Initialize Message List
   * @param  p_commit                      Commit the Work
   * @param  x_return_status               Return Status of the Procedure.
   * @param  x_msg_count                   Number of Messages in the Stack.
   * @param  x_msg_data                    Stack of Error Messages.
   * @param  p_task_id                     Task ID of the Task to be Updated
   * @param  p_object_version_number       Current Task Version and also container for new one.
   * @param  p_action                      Action to be processed
   * @param  p_task_status_id              New Task Status ID
   * @param  p_planned_start_date          Planned Start Date
   * @param  p_planned_end_date            Planned End Date
   */
  PROCEDURE update_task_longer_than_shift (
    p_api_version             IN              NUMBER
  , p_init_msg_list           IN              VARCHAR2 DEFAULT NULL
  , p_commit                  IN              VARCHAR2 DEFAULT NULL
  , x_return_status           OUT    NOCOPY   VARCHAR2
  , x_msg_count               OUT    NOCOPY   NUMBER
  , x_msg_data                OUT    NOCOPY   VARCHAR2
  , p_task_id                 IN              NUMBER
  , p_object_version_number   IN OUT NOCOPY   NUMBER
  , p_planned_start_date      IN              DATE     DEFAULT FND_API.G_MISS_DATE
  , p_planned_end_date        IN              DATE     DEFAULT FND_API.G_MISS_DATE
  , p_action                  IN              PLS_INTEGER
  , p_task_status_id          IN              NUMBER   DEFAULT fnd_api.g_miss_num
  );

  /**
   * Creates a Child Task (and Assignment) from the given Parent Task
   * with the given Scheduled Timings and Duration in the given Trip.
   *
   * Creates a Child Task by copying most of the attributes from the given
   * Parent Task and also an assignment. Moreover the Confirmation and Confirmation
   * Counter is copied from the Parent Task.
   *
   * @param  p_api_version               API Version (1.0)
   * @param  p_init_msg_list             Initialize Message List
   * @param  p_commit                    Commit the Work
   * @param  x_return_status             Return Status of the Procedure.
   * @param  x_msg_count                 Number of Messages in the Stack.
   * @param  x_msg_data                  Stack of Error Messages.
   * @param  p_parent_task_id            Parent Task Identifier
   * @param  p_task_status_id            Task Status ID of the Child Task
   * @param  p_planned_effort            Planned Effort of the Child Task
   * @param  p_planned_effort_uom        Planned Effort UOM of the Child Task
   * @param  p_bound_mode_flag           Bound Mode
   * @param  p_soft_bound_flag           Soft Bound
   * @param  p_scheduled_start_date      Scheduled Start Date of Child Task
   * @param  p_scheduled_end_date        Scheduled End Date of Child Task
   * @param  p_assignment_status_id      Task Assignment Status
   * @param  p_resource_id               Resource ID of the Child Task
   * @param  p_resource_type_code        Resource Type of the Child Task
   * @param  p_object_capacity_id        Trip ID of the Child Task
   * @param  p_sched_travel_distance     Scheduled Travel Distance of Child Task
   * @param  p_sched_travel_duration     Scheduled Travel Duration of Child Task
   * @param  p_sched_travel_duration_uom Scheduled Travel Duration UOM of Child Task
   * @param  x_task_id                   New Task Identifier of the Child Task
   * @param  x_object_version_number     Object Version of the Task created.
   * @param  x_task_assignment_id        Task Assignment created
   * @param  p_child_position            Position of the Child Task ('F', 'M', 'L', 'N')
   * @param  p_child_sequence_num        Sequence Number among the Child Tasks
   * @param  x_task_id                   The Task Id of the created Task
   * @param  x_object_version_number     Object Version Number of created task
   * @param  x_task_assignment_id        Task Assignment ID of the created Assignment
   */
  PROCEDURE create_child_task(
    p_api_version                 IN              NUMBER
  , p_init_msg_list               IN              VARCHAR2 DEFAULT NULL
  , p_commit                      IN              VARCHAR2 DEFAULT NULL
  , x_return_status               OUT NOCOPY      VARCHAR2
  , x_msg_count                   OUT NOCOPY      NUMBER
  , x_msg_data                    OUT NOCOPY      VARCHAR2
  , p_parent_task_id              IN              NUMBER
  , p_task_status_id              IN              NUMBER
  , p_planned_effort              IN              NUMBER
  , p_planned_effort_uom          IN              VARCHAR2
  , p_bound_mode_code             IN              VARCHAR2
  , p_soft_bound_flag             IN              VARCHAR2
  , p_scheduled_start_date        IN              DATE
  , p_scheduled_end_date          IN              DATE
  , p_assignment_status_id        IN              NUMBER
  , p_resource_id                 IN              NUMBER
  , p_resource_type               IN              VARCHAR2
  , p_object_capacity_id          IN              NUMBER
  , p_sched_travel_distance       IN              NUMBER
  , p_sched_travel_duration       IN              NUMBER
  , p_sched_travel_duration_uom   IN              VARCHAR2
  , p_child_position              IN              VARCHAR2 DEFAULT NULL
  , p_child_sequence_num          IN              NUMBER   DEFAULT NULL
  , x_task_id                     OUT NOCOPY      NUMBER
  , x_object_version_number       OUT NOCOPY      NUMBER
  , x_task_assignment_id          OUT NOCOPY      NUMBER
  );

  /**
   * Updates the customer confirmation for normal/child/parent task
   *
   * @param  p_api_version                   API Version (1.0)
   * @param  p_init_msg_list                 Initialize Message List
   * @param  p_commit                        Commit the Work
   * @param  x_return_status                 Return Status of the Procedure
   * @param  x_msg_count                     Number of Messages in the Stack
   * @param  x_msg_data                      Stack of Error Messages
   * @param  p_task_id                       Task to be processed
   * @param  p_object_version_number         Object version of input task
   * @param  p_action                        Whether Required/Received/Not Required
   * @param  p_initiated                     Whether Customer or Dispatcher
   */
  PROCEDURE update_cust_confirmation(
    p_api_version                 IN              NUMBER
  , p_init_msg_list               IN              VARCHAR2 DEFAULT NULL
  , p_commit                      IN              VARCHAR2 DEFAULT NULL
  , x_return_status               OUT NOCOPY      VARCHAR2
  , x_msg_count                   OUT NOCOPY      NUMBER
  , x_msg_data                    OUT NOCOPY      VARCHAR2
  , p_task_id                     IN              NUMBER
  , p_object_version_number       IN OUT NOCOPY   NUMBER
  , p_action                      IN              PLS_INTEGER
  , p_initiated                   IN              PLS_INTEGER
  );

  /**
   * Gets the Location ID of the Task given the Task ID / Party Site ID / Location ID
   * <br>
   * 1. If Location ID is passed, the function just returns the value.
   * 2. If Party Site ID is passed, then the function returns the Location ID tied to the
   *    Party Site.
   * 3. If Task ID alone is given, then the function finds out whether the Task's Location
   *    ID is stamped. If yes, then returns it.. otherwise returns the Location ID tied
   *    to the Task's Party Site.
   *
   * @param  p_task_id          Task ID
   * @param  p_party_site_id    Party Site ID of the Task
   * @param  p_location_id      Location ID of the Task
   */
  FUNCTION get_task_location_id (
    p_task_id       IN NUMBER
  , p_party_site_id IN NUMBER DEFAULT NULL
  , p_location_id   IN NUMBER DEFAULT NULL
  )
    RETURN NUMBER;

  /**
   * Gets the Address of the Task given the Task ID / Party Site ID / Location ID
   * <br>
   * 1. If Location ID is passed, it will be directly used.
   * 2. If Party Site ID is passed, then the function retrieves the Location ID tied to the
   *    Party Site and returns the Address.
   * 3. If Task ID alone is given, then the function finds out whether the Task's Location
   *    ID is stamped. If yes, then returns the address of the Location.. Otherwise
   *    returns the address of the location tied to the Task's Party Site.
   *
   * @param  p_task_id          Task ID
   * @param  p_party_site_id    Party Site ID of the Task
   * @param  p_location_id      Location ID of the Task
   * @param  p_short_flag       Address Format - Short Format / Long Format
   */
  FUNCTION get_task_address (
    p_task_id       IN NUMBER
  , p_party_site_id IN NUMBER   DEFAULT NULL
  , p_location_id   IN NUMBER   DEFAULT NULL
  , p_short_flag    IN VARCHAR2 DEFAULT 'Y'
  )
    RETURN VARCHAR2;

  /**
   * Gets the Task Effort conditionally converted to the Default UOM as given by
   * the profile CSF: Default Effort UOM by calling
   * CSF_UTIL_PVT.GET_EFFORT_IN_DEFAULT_UOM function.
   * <br>
   * All parameters are optional. If Planned Effort, Planned Effort UOM and Task
   * Split Flag are passed, then it helps in better performance as JTF_TASKS_B
   * wont be queried to get those information. In case of better flexibility,
   * the caller can just pass the Task ID and the API will fetch the required
   * information. If case none of the required parameters are passed, the API returns
   * NULL.
   * <br>
   * Parent Task / Normal Tasks are created by the Teleservice Operators and therefore
   * its always better to represent them in the UOM they had given initially. Tasks
   * created as part of the Background processes like Child Tasks are always created
   * in Minutes by Scheduler and therefore it is incumbent upon us to represent
   * them in a proper UOM. Thus this API will convert the Planned Effort to the default
   * UOM only for Child Tasks and will merely act as a Concatenation Operator for
   * other Tasks. If you want to overrule this and want conversion to Default UOM
   * to take place for all Tasks, pass p_always_convert as FND_API.G_TRUE
   *
   * Also refer to the documentation on CSF_UTIL_PVT.GET_EFFORT_IN_DEFAULT_UOM.
   * <br>
   *
   * @param p_planned_effort      Planned Effort to be converted
   * @param p_planned_effort_uom  UOM of the above Effort
   * @param p_task_split_flag     Determines whether the Task is Child / Other
   * @param p_task_id             Task ID of the Task whose effort is to be converted
   * @param p_always_convert      Overrule the condition and convert for all Tasks.
   *
   * @result Planned Effort appro converted to Default UOM.
   */
  FUNCTION get_task_effort_in_default_uom(
    p_planned_effort       NUMBER     DEFAULT NULL
  , p_planned_effort_uom   VARCHAR2   DEFAULT NULL
  , p_task_split_flag      VARCHAR2   DEFAULT '@' -- NULL not used as NULL is a valid value
  , p_task_id              NUMBER     DEFAULT NULL
  , p_always_convert       VARCHAR2   DEFAULT NULL
  )
    RETURN VARCHAR2;

  /**
   * Given the Service Request Incident ID or Task ID, Contact
   * Details are fetched. If the profile CSF: Default Source for
   * Contact is set to SR, then SR is queried. Otherwise Task is
   * queried.
   *
   * @param p_incident_id   Service Request ID
   * @param p_task_id       Task Id
   * @param x_last_name     Last Name
   * @param x_first_name    First Name
   * @param x_title         Title
   * @param x_phone         Phone Number of the Contact Person
   * @param x_phone_ext     Phone Extension
   * @param x_email_address Email Address of the Contact Person
   */
  PROCEDURE get_contact_details(
    p_incident_id    IN        NUMBER
  , p_task_id        IN        NUMBER    DEFAULT NULL
  , x_last_name     OUT NOCOPY VARCHAR2
  , x_first_name    OUT NOCOPY VARCHAR2
  , x_title         OUT NOCOPY VARCHAR2
  , x_phone         OUT NOCOPY VARCHAR2
  , x_phone_ext     OUT NOCOPY VARCHAR2
  , x_email_address OUT NOCOPY VARCHAR2
  );

  /**
   * Given the Service Request Incident ID or the Task ID, Contact
   * Person Name and Phone are fetched. The Name and Phone are
   * separated by @@
   *
   * @param p_incident_id  Service Request ID
   * @param p_task_id      Task ID
   */
  FUNCTION get_contact_details(
    p_incident_id  NUMBER
  , p_task_id      NUMBER    DEFAULT NULL
  ) RETURN VARCHAR2;

  procedure update_personal_task(
	      	p_api_version               in number
	      , p_init_msg_list        in varchar2
          , p_commit             in varchar2
          , p_task_id                    in NUMBER
          , p_task_name                  in varchar2
          , x_version     in out nocopy number
	      , p_description                in VARCHAR2
	      , p_task_type_id             in number
	      , p_task_status_id           in number
	      , p_task_priority_id    in number
	      , p_owner_id                   in number
	      , p_owner_type_code            in varchar2
	      , p_address_id                 in number
	      , p_customer_id               in number
	      , p_planned_start_date         in date
	      , p_planned_end_date          in date
	      , p_scheduled_start_date       in date
	      , p_scheduled_end_date         in date
	      , p_source_object_type_code   in varchar2
	      , p_planned_effort             in number
	      , p_planned_effort_uom         in varchar2
	      , p_bound_mode_code            in varchar2
	      , p_soft_bound_flag           in varchar2
	      , p_type                       in varchar2
        , p_trip                     in number
	      , x_return_status              out nocopy varchar2
	      , x_msg_count                  out nocopy number
	      , x_msg_data                   out nocopy varchar2
        );

procedure  create_personal_task(
		    p_api_version                   in number
	      , p_init_msg_list        in varchar2
		  , p_commit             in varchar2
          , p_task_name                in varchar2
	      , p_description               in varchar2
	      , p_task_type_name           in varchar2
	      , p_task_type_id              in number
	      , p_task_status_name          in varchar2
	      , p_task_status_id              in number
	      , p_task_priority_name        in varchar2
	      , p_task_priority_id            in number
	      , p_owner_id                   in number
	      , p_owner_type_code           in varchar2
	      , p_address_id                  in number
	      , p_customer_id                 in number
	      , p_planned_start_date         in date
	      , p_planned_end_date           in date
	      , p_scheduled_start_date      in date
	      , p_scheduled_end_date         in date
	      , p_source_object_type_code    in varchar2
	      , p_planned_effort             in number
	      , p_planned_effort_uom        in varchar2
	      , p_bound_mode_code            in varchar2
	      , p_soft_bound_flag            in varchar2
	      , p_task_assign_tbl           jtf_tasks_pub.task_assign_tbl
	      , p_type                     in varchar2
          , p_trip                     in number
	      , x_return_status             out nocopy varchar2
	      , x_msg_count                 out nocopy number
	      , x_msg_data                  out nocopy varchar2
	      , x_task_id                    out nocopy number
	      );

 -- Inst_flexfld_rec_type : This type is used to pass record information
 -- for flexfields used in CSFDCTKS.
 -- flex field are ITEM_INSTANCE for SERVICE FLEX FIELD it is updated in CSFDCLIB.old
 -- flex field FOR tasks in updated in update_task_attr procedure in this package
 TYPE Inst_flexfld_rec_type IS RECORD (
   l_flex_fl_table       varchar2(255) DEFAULT NULL
	,l_task_id             number DEFAULT NULL
	,l_att_catogary        varchar2(255) DEFAULT NULL
	,l_task_ovn            number DEFAULT NULL
  ,l_instance_id 		     number DEFAULT NULL
  ,l_party_id            number DEFAULT NULL
  ,l_obj_ver_number	     number DEFAULT NULL
	,l_context 			       varchar2(255)
	,ATTRIBUTE1 		       varchar2(255)
	,ATTRIBUTE2 		       varchar2(255)
	,ATTRIBUTE3            varchar2(255)
	,ATTRIBUTE4            varchar2(255)
	,ATTRIBUTE5 		       varchar2(255)
	,ATTRIBUTE6            varchar2(255)
	,ATTRIBUTE7            varchar2(255)
	,ATTRIBUTE8 		       varchar2(255)
	,ATTRIBUTE9            varchar2(255)
	,ATTRIBUTE10           varchar2(255)
	,ATTRIBUTE11		       varchar2(255)
	,ATTRIBUTE12           varchar2(255)
	,ATTRIBUTE13           varchar2(255)
	,ATTRIBUTE14		       varchar2(255)
	,ATTRIBUTE15           varchar2(255)
	,ATTRIBUTE16           varchar2(255)
	,ATTRIBUTE17           varchar2(255)
	,ATTRIBUTE18           varchar2(255)
	,ATTRIBUTE19           varchar2(255)
	,ATTRIBUTE20           varchar2(255)
	,ATTRIBUTE21           varchar2(255)
	,ATTRIBUTE22           varchar2(255)
	,ATTRIBUTE23		       varchar2(255)
	,ATTRIBUTE24           varchar2(255)
	,ATTRIBUTE25           varchar2(255)
	,ATTRIBUTE26           varchar2(255)
	,ATTRIBUTE27           varchar2(255)
	,ATTRIBUTE28           varchar2(255)
	,ATTRIBUTE29           varchar2(255)
	,ATTRIBUTE30           varchar2(255)
  );

  TYPE l_inst_flex_fld_tbl IS TABLE OF Inst_flexfld_rec_type;

  PROCEDURE set_desc_field_attr(
	 p_inst_flex_fld_tbl IN  csf_tasks_pub.Inst_flexfld_rec_type
	,p_return_status     OUT NOCOPY      VARCHAR2
	,p_msg_count         OUT NOCOPY      NUMBER
	,p_msg_data          OUT NOCOPY      VARCHAR2
  ,p_obj_ver_no        OUT NOCOPY      NUMBER
  );

  /**
   * This procedure is called from CSFDCTKS.fmb--Dates package
   * this procedure updates planned start/end, planned effort
   * scheduled dates ,priority and flex field for task
   * @param  p_api_version                   API Version (1.0)
   * @param  p_init_msg_list                 Initialize Message List
   * @param  p_commit                        Commit the Work
   * @param  x_return_status                 Return Status of the Procedure
   * @param  x_msg_count                     Number of Messages in the Stack
   * @param  x_msg_data                      Stack of Error Messages
   * @param  p_task_id              				 Task Id
   * @param  p_object_version_number     		 Object version number for task
   * @param  p_scheduled_start_date          New Scheduled Start Date (NULL if change not needed).
   * @param  p_scheduled_end_date            New Scheduled End Date (NULL if change not needed).
   * @param  p_planned_start_date            Planned Start Date of task.
   * @param  p_planned_end_date              Planned End Date of task.
   * @param  p_task_priority_id        	  	 Task priority Id
   * @param  p_planned_effort		             Planned effort for task
   * @param  p_planned_effort_uom	  		     Planned effort  UOM for task
   * @param  ATTRIBUTE1 		   		 	         Column can be used for Task Flex field
   * @param  ATTRIBUTE2 		  			         Column can be used for Task Flex field
   * @param  ATTRIBUTE3              		     Column can be used for Task Flex field
   * @param  ATTRIBUTE4              		     Column can be used for Task Flex field
   * @param  ATTRIBUTE5 		        	       Column can be used for Task Flex field
   * @param  ATTRIBUTE6                      Column can be used for Task Flex field
   * @param  ATTRIBUTE7                      Column can be used for Task Flex field
   * @param  ATTRIBUTE8 		                 Column can be used for Task Flex field
   * @param  ATTRIBUTE9               	     Column can be used for Task Flex field
   * @param  ATTRIBUTE10                     Column can be used for Task Flex field
   * @param  ATTRIBUTE11		                 Column can be used for Task Flex field
   * @param  ATTRIBUTE12                     Column can be used for Task Flex field
   * @param  ATTRIBUTE13                     Column can be used for Task Flex field
   * @param  ATTRIBUTE14		                 Column can be used for Task Flex field
   * @param  ATTRIBUTE15                     Column can be used for Task Flex field
   * @param  ATTRIBUTE_CATEGORY		           Catgory column for flex field
   */

  PROCEDURE update_task_attr(
    p_api_version             IN              NUMBER
  , p_init_msg_list           IN              VARCHAR2 DEFAULT NULL
  , p_commit                  IN              VARCHAR2 DEFAULT NULL
  , x_return_status           OUT NOCOPY      VARCHAR2
  , x_msg_count               OUT NOCOPY      NUMBER
  , x_msg_data                OUT NOCOPY      VARCHAR2
  , p_task_id                 IN              NUMBER
  , p_object_version_number   IN OUT NOCOPY   NUMBER
  , p_scheduled_start_date    IN              DATE 		DEFAULT NULL
  , p_scheduled_end_date      IN              DATE 		DEFAULT NULL
  , p_planned_start_date      IN              DATE 		DEFAULT NULL
  , p_planned_end_date        IN              DATE 		DEFAULT NULL
  , p_task_priority_id        IN              NUMBER  	DEFAULT NULL
  , p_planned_effort		  IN	     	  NUMBER 	DEFAULT NULL
  , p_planned_effort_uom	  IN	    	  VARCHAR2  DEFAULT NULL
  , ATTRIBUTE1 		   		  IN    		  VARCHAR2 DEFAULT NULL
  , ATTRIBUTE2 		  		  IN    		  VARCHAR2 DEFAULT NULL
  , ATTRIBUTE3                IN              VARCHAR2 DEFAULT NULL
  , ATTRIBUTE4                IN              VARCHAR2 DEFAULT NULL
  , ATTRIBUTE5 		          IN              VARCHAR2 DEFAULT NULL
  , ATTRIBUTE6                IN	          VARCHAR2 DEFAULT NULL
  , ATTRIBUTE7                IN	          VARCHAR2 DEFAULT NULL
  , ATTRIBUTE8 		          IN              VARCHAR2 DEFAULT NULL
  , ATTRIBUTE9                IN              VARCHAR2 DEFAULT NULL
  , ATTRIBUTE10               IN              VARCHAR2 DEFAULT NULL
  , ATTRIBUTE11		          IN              VARCHAR2 DEFAULT NULL
  , ATTRIBUTE12               IN              VARCHAR2 DEFAULT NULL
  , ATTRIBUTE13               IN	          VARCHAR2 DEFAULT NULL
  , ATTRIBUTE14		          IN	          VARCHAR2 DEFAULT NULL
  , ATTRIBUTE15               IN              VARCHAR2 DEFAULT NULL
  , ATTRIBUTE_CATEGORY		  IN    		  VARCHAR2 DEFAULT NULL
  );

  PROCEDURE get_site_details_for_task
  ( p_task_id       IN NUMBER
  , p_party_id 		IN NUMBER
  , p_party_site_id IN NUMBER DEFAULT NULL
  , p_location_id   IN NUMBER DEFAULT NULL
  , p_party_site_no  OUT NOCOPY  VARCHAR
  , p_party_site_nm  OUT NOCOPY VARCHAR
  , p_party_site_add OUT NOCOPY VARCHAR
  , p_party_site_ph  OUT NOCOPY VARCHAR
  );
  FUNCTION return_primary_phone
  (
	party_id  IN number
  ) return varchar2 ;

  PROCEDURE create_achrs( x_return_status    out nocopy varchar2 );
  PROCEDURE CREATE_ACC_HRS( p_task_id                     IN NUMBER
							            , x_return_status              OUT NOCOPY VARCHAR2
							            , x_msg_count                  OUT NOCOPY NUMBER
							            , x_msg_data                   OUT NOCOPY VARCHAR2);
END csf_tasks_pub;

/
